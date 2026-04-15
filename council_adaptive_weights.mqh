#ifndef __COUNCIL_ADAPTIVE_WEIGHTS_MQH__
#define __COUNCIL_ADAPTIVE_WEIGHTS_MQH__

#include "core_logger.mqh"
#include "council_mode_types.mqh"

//---------------------------------------------------------
// Adaptive Council Weighting Hooks (v1)
// - explainable, conservative
// - enabled via plan.council_adaptive_weights_enabled
//---------------------------------------------------------
struct CouncilAdaptiveWeightingState
{
   bool   enabled;
   string profile;
   string reason;
};

static CouncilAdaptiveWeightingState gCouncilAW;

void CouncilAdaptiveWeights_Init()
{
   gCouncilAW.enabled = false;
   gCouncilAW.profile = "OFF";
   gCouncilAW.reason  = "";
}

void CouncilAdaptiveWeights_Set(bool enabled, string profile, string reason)
{
   gCouncilAW.enabled = enabled;
   gCouncilAW.profile = (enabled ? profile : "OFF");
   gCouncilAW.reason  = reason;
}

bool CouncilAdaptiveWeights_IsEnabled()
{
   return gCouncilAW.enabled;
}

string CouncilAdaptiveWeights_Profile()
{
   return gCouncilAW.profile;
}

string CouncilAdaptiveWeights_Reason()
{
   return gCouncilAW.reason;
}

// Returns multiplier around [0.75..1.25] (clamped), v1 conservative.
double CouncilAdaptiveWeights_StrategyMultiplier(
   CouncilStrategyReport &s,
   CouncilEnvironmentReport &env,
   string &outSummary
)
{
   outSummary = "";

   if(!gCouncilAW.enabled)
      return 1.0;

   double m = 1.0;

   // Simple style alignment rules (v1):
   // - If environment is TREND and strategy is trend-biased => small boost
   // - If environment is RANGE and strategy is reversal/mean => small boost
   // - If environment is NOISY/LOW_QUALITY => dampen aggressive votes
   bool envTrend = (env.zone_name == "TREND" || env.preferred_style == COUNCIL_STYLE_CONTINUATION);
   bool envRange = (env.zone_name == "RANGE" || env.preferred_style == COUNCIL_STYLE_MEAN_RECLAIM || env.preferred_style == COUNCIL_STYLE_REVERSAL);

   bool stratTrend = (s.strategy_family == "TREND" || StringFind(s.strategy_id, "trend") >= 0);
   bool stratMean  = (s.strategy_family == "MEAN" || StringFind(s.strategy_id, "mean") >= 0 || StringFind(s.strategy_id, "reclaim") >= 0);

   if(envTrend && stratTrend) m += 0.08;
   if(envRange && stratMean)  m += 0.06;

   if(env.total_score <= 0.35) m -= 0.08; // low tradability environment
   if(env.volatility_ok == false) m -= 0.05;
   if(s.conflict_score >= 0.45) m -= 0.06;

   if(m < 0.75) m = 0.75;
   if(m > 1.25) m = 1.25;

   outSummary =
      "aw=" + gCouncilAW.profile +
      "|m=" + DoubleToString(m, 2) +
      "|env=" + env.zone_name +
      "|sid=" + s.strategy_id;

   return m;
}


//---------------------------------------------------------
// Phase 8A: Attribution hooks (metadata only, no behavior change)
//---------------------------------------------------------
#define CAW_MAX_HINTS 24

struct CouncilAttributionWeightHint
{
   string strategy_id;
   double trust_hint;         // 0..1 (higher => more trust)
   double dissent_trust_hint; // 0..1 (higher => more trust when dissenting)
   double dampening_hint;     // 0..1 (higher => more dampening)
   double correctness_hint;   // 0..1 (higher => more correctness readiness)
   string reason;
};

static CouncilAttributionWeightHint gCawHints[CAW_MAX_HINTS];
static int gCawHintsCount = 0;

void CouncilAdaptiveWeights_ResetAttributionHints()
{
   gCawHintsCount = 0;
   for(int i = 0; i < CAW_MAX_HINTS; i++)
   {
      gCawHints[i].strategy_id = "";
      gCawHints[i].trust_hint = 0.0;
      gCawHints[i].dissent_trust_hint = 0.0;
      gCawHints[i].dampening_hint = 0.0;
      gCawHints[i].correctness_hint = 0.0;
      gCawHints[i].reason = "";
   }
}

void CouncilAdaptiveWeights_RecordAttributionHint(
   string strategy_id,
   double trust_hint,
   double dampening_hint,
   string reason
)
{
   strategy_id = TrimString(strategy_id);
   if(StringLen(strategy_id) <= 0) return;
   if(gCawHintsCount >= CAW_MAX_HINTS) return;

   gCawHints[gCawHintsCount].strategy_id = strategy_id;
   gCawHints[gCawHintsCount].trust_hint = CouncilClamp(trust_hint);
   gCawHints[gCawHintsCount].dampening_hint = CouncilClamp(dampening_hint);
   gCawHints[gCawHintsCount].reason = reason;
   gCawHintsCount++;
}

bool CouncilAdaptiveWeights_GetAttributionHint(
   string strategy_id,
   double &trust_hint,
   double &dampening_hint,
   string &reason
)
{
   trust_hint = 0.0;
   dampening_hint = 0.0;
   reason = "";

   strategy_id = TrimString(strategy_id);
   if(StringLen(strategy_id) <= 0) return false;

   for(int i = 0; i < gCawHintsCount; i++)
   {
      if(gCawHints[i].strategy_id == strategy_id)
      {
         trust_hint = gCawHints[i].trust_hint;
         dampening_hint = gCawHints[i].dampening_hint;
         reason = gCawHints[i].reason;
         return true;
      }
   }
   return false;
}


#endif
