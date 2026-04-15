
#ifndef __RISK_STATE_POLICY_ENGINE_MQH__
#define __RISK_STATE_POLICY_ENGINE_MQH__

#include "config_loader.mqh"
#include "performance_memory.mqh"
#include "regime_classification_layer_v1.mqh"
#include "unified_confidence.mqh"


#include "journal_analytics.mqh"
double RP_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}

double RP_Clamp01(double v) { return RP_Clamp(v, 0.0, 1.0); }

//---------------------------------------------------------
// Risk State Policy Engine v1 (conservative)
// - Computes global policy state from robust signals (streaks/underperformance)
// - Applies minimal tightening/blocking to permission only
//---------------------------------------------------------
enum RiskPolicyState
{
   RISK_NORMAL = 0,
   RISK_CAUTIOUS,
   RISK_DEFENSIVE,
   RISK_LOCKDOWN,
   RISK_RECOVERY
};

struct RiskPolicySnapshot
{
   RiskPolicyState state;
   string state_text;
   string reason;

   double extra_confidence_min;   // + to required confidence
   double extra_tradability_min;  // + to required tradability

   bool   block_new_trades;       // hard block
};

string RiskPolicyStateText(RiskPolicyState s)
{
   if(s == RISK_CAUTIOUS)  return "CAUTIOUS";
   if(s == RISK_DEFENSIVE) return "DEFENSIVE";
   if(s == RISK_LOCKDOWN)  return "LOCKDOWN";
   if(s == RISK_RECOVERY)  return "RECOVERY";
   return "NORMAL";
}

void InitRiskPolicySnapshot(RiskPolicySnapshot &s)
{
   s.state = RISK_NORMAL;
   s.state_text = "NORMAL";
   s.reason = "";

   s.extra_confidence_min = 0.0;
   s.extra_tradability_min = 0.0;
   s.block_new_trades = false;
}

struct RiskThresholds
{
   int    cautious_losses;
   int    defensive_losses;
   int    lockdown_losses;

   double defensive_recent_winrate; // 0..100
   double lockdown_recent_winrate;  // 0..100

   int    recovery_bars;            // bars to stay in RECOVERY after lockdown clears
};

void LoadDefaultRiskThresholds(RiskThresholds &t)
{
   t.cautious_losses = 2;
   t.defensive_losses = 3;
   t.lockdown_losses = 4;

   t.defensive_recent_winrate = 40.0;
   t.lockdown_recent_winrate = 25.0;

   t.recovery_bars = 10;
}

bool ParseRiskThresholdsFromPlan(RuntimePlan &plan, RiskThresholds &t)
{
   LoadDefaultRiskThresholds(t);

   string obj = plan.risk_state_thresholds;
   obj = TrimString(obj);
   if(StringLen(obj) <= 0)
      return true;

   int iv = 0;
   double dv = 0.0;

   if(ExtractJsonIntField(obj, "cautious_losses", iv))
      t.cautious_losses = MathMax(1, iv);

   if(ExtractJsonIntField(obj, "defensive_losses", iv))
      t.defensive_losses = MathMax(1, iv);

   if(ExtractJsonIntField(obj, "lockdown_losses", iv))
      t.lockdown_losses = MathMax(1, iv);

   if(ExtractJsonDoubleField(obj, "defensive_recent_winrate", dv))
      t.defensive_recent_winrate = RP_Clamp(dv, 0.0, 100.0);

   if(ExtractJsonDoubleField(obj, "lockdown_recent_winrate", dv))
      t.lockdown_recent_winrate = RP_Clamp(dv, 0.0, 100.0);

   if(ExtractJsonIntField(obj, "recovery_bars", iv))
      t.recovery_bars = MathMax(1, iv);

   // Ensure ordering is sensible (never invert)
   if(t.defensive_losses < t.cautious_losses) t.defensive_losses = t.cautious_losses;
   if(t.lockdown_losses < t.defensive_losses) t.lockdown_losses = t.defensive_losses;

   return true;
}

//---------------------------------------------------------
// Compute risk state (bar-level), with minimal memory for recovery
//---------------------------------------------------------
bool ComputeRiskPolicyStateV1(
   RuntimePlan &plan,
   PerformanceSnapshot &perf,
   RiskPolicySnapshot &out,
   string &debugReason
)
{
   InitRiskPolicySnapshot(out);
   debugReason = "";

   if(!plan.risk_state_policy_enabled)
   {
      out.state = RISK_NORMAL;
      out.state_text = "NORMAL";
      out.reason = "disabled";
      return true;
   }

   RiskThresholds th;
   ParseRiskThresholdsFromPlan(plan, th);

   static int recoveryBarsLeft = 0;

   RiskPolicyState state = RISK_NORMAL;
   string reason = "";

   // Primary triggers: streak + underperformance + recent win-rate
   if(perf.consecutive_losses >= th.lockdown_losses)
   {
      state = RISK_LOCKDOWN;
      reason = "lockdown:consecutive_losses";
   }
   else if(perf.recent_closed_trades >= 8 && perf.recent_win_rate <= th.lockdown_recent_winrate)
   {
      state = RISK_LOCKDOWN;
      reason = "lockdown:recent_winrate";
   }
   else if(perf.consecutive_losses >= th.defensive_losses || perf.underperformance)
   {
      state = RISK_DEFENSIVE;
      reason = (perf.underperformance ? "defensive:underperformance" : "defensive:consecutive_losses");
   }
   else if(perf.consecutive_losses >= th.cautious_losses)
   {
      state = RISK_CAUTIOUS;
      reason = "cautious:consecutive_losses";
   }

   // Recovery hysteresis: if we were in lockdown and cleared streak, ease back gradually
   if(state == RISK_LOCKDOWN)
   {
      recoveryBarsLeft = th.recovery_bars;
   }
   else if(recoveryBarsLeft > 0)
   {
      // If we are not currently in lockdown but have recovery bars left, switch to RECOVERY.
      state = RISK_RECOVERY;
      reason = "recovery:hysteresis";
      recoveryBarsLeft--;
   }

   out.state = state;
   out.state_text = RiskPolicyStateText(state);
   out.reason = reason;

   // Conservative effects
   if(state == RISK_NORMAL)
   {
      out.extra_confidence_min = 0.0;
      out.extra_tradability_min = 0.0;
      out.block_new_trades = false;
   }
   else if(state == RISK_CAUTIOUS)
   {
      out.extra_confidence_min = 0.05;
      out.extra_tradability_min = 0.05;
      out.block_new_trades = false;
   }
   else if(state == RISK_DEFENSIVE)
   {
      out.extra_confidence_min = 0.10;
      out.extra_tradability_min = 0.10;
      out.block_new_trades = false;
   }
   else if(state == RISK_LOCKDOWN)
   {
      out.extra_confidence_min = 1.0;
      out.extra_tradability_min = 1.0;
      out.block_new_trades = true;
   }
   else // RECOVERY
   {
      out.extra_confidence_min = 0.07;
      out.extra_tradability_min = 0.07;
      out.block_new_trades = false;
   }

   debugReason =
      "policy_state=" + out.state_text +
      "|reason=" + out.reason +
      "|loss_streak=" + IntegerToString(perf.consecutive_losses) +
      "|recent_wr=" + DoubleToString(perf.recent_win_rate, 1);

   return true;
}

//---------------------------------------------------------
// Decision-level tightening using unified confidence/regime
//---------------------------------------------------------
bool RiskPolicyAllowsDecisionV1(
   RuntimePlan &plan,
   RiskPolicySnapshot &risk,
   UnifiedDecisionConfidence &conf,
   RegimeClassification &reg,
   string &blockReason
)
{
   blockReason = "";

   if(!plan.risk_state_policy_enabled)
      return true;

   if(risk.block_new_trades)
   {
      blockReason = "risk_state_lockdown";
      return false;
   }

   // Only gate BUY/SELL. WAIT/REJECT should still be allowed.
   if(conf.direction != "BUY" && conf.direction != "SELL")
      return true;

   double confMin = RP_Clamp01(plan.regime_confidence_min + risk.extra_confidence_min);
   double tradMin = RP_Clamp01(plan.regime_tradability_min + risk.extra_tradability_min);

   // If plan has no mins configured, keep this guard soft.
   if(confMin > 0.0 && conf.confidence_score < confMin)
   {
      blockReason = "risk_state_confidence_below_min";
      return false;
   }

   if(tradMin > 0.0 && reg.tradability_score < tradMin)
   {
      blockReason = "risk_state_tradability_below_min";
      return false;
   }

   if(risk.state == RISK_DEFENSIVE)
   {
      // Defensive: avoid worst regimes explicitly (conservative, not overly strict)
      if(reg.regime_label == "RANGE_DIRTY" || reg.regime_label == "NO_TRADE")
      {
         blockReason = "risk_state_defensive_blocks_regime";
         return false;
      }
   }

   if(risk.state == RISK_RECOVERY)
   {
      // Recovery: still avoid very dirty environments
      if(reg.regime_label == "RANGE_DIRTY" || reg.regime_label == "NO_TRADE")
      {
         blockReason = "risk_state_recovery_blocks_regime";
         return false;
      }
   }

   return true;
}

//---------------------------------------------------------
// Optional failure clustering adjustment (v1, conservative)
//---------------------------------------------------------
void RiskPolicyApplyFailureClusterV1(FailureClusterResult &cluster, RiskPolicySnapshot &out)
{
   if(!cluster.clustered_failure_detected)
      return;

   // Conservative: only tighten, do not relax
   if(out.state == RISK_NORMAL)
   {
      out.state = RISK_CAUTIOUS;
      out.state_text = RiskPolicyStateText(out.state);
      out.reason = "failure_cluster->CAUTIOUS|" + cluster.cluster_reason_summary;
      out.extra_confidence_min = MathMax(out.extra_confidence_min, 0.05);
      out.extra_tradability_min = MathMax(out.extra_tradability_min, 0.05);
      return;
   }

   if(out.state == RISK_CAUTIOUS && cluster.failure_cluster_score >= 0.55)
   {
      out.state = RISK_DEFENSIVE;
      out.state_text = RiskPolicyStateText(out.state);
      out.reason = "failure_cluster->DEFENSIVE|" + cluster.cluster_reason_summary;
      out.extra_confidence_min = MathMax(out.extra_confidence_min, 0.10);
      out.extra_tradability_min = MathMax(out.extra_tradability_min, 0.10);
      return;
   }

   if(out.state == RISK_DEFENSIVE && cluster.failure_cluster_score >= 0.80)
   {
      out.state = RISK_LOCKDOWN;
      out.state_text = RiskPolicyStateText(out.state);
      out.reason = "failure_cluster->LOCKDOWN|" + cluster.cluster_reason_summary;
      out.block_new_trades = true;
      return;
   }
}

#endif
