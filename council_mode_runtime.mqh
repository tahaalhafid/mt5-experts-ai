#ifndef __COUNCIL_MODE_RUNTIME_MQH__
#define __COUNCIL_MODE_RUNTIME_MQH__

#include "mt5_io_reduction_v1.mqh"
#include "council_mode_types.mqh"
#include "core_market_data.mqh"
#include "council_environment.mqh"
#include "council_strategies.mqh"
#include "council_aggregator.mqh"
#include "council_pre_ai_filter.mqh"
#include "council_memory.mqh"
#include "council_failure_detector.mqh"
#include "council_ai_governor.mqh"
#include "council_feedback.mqh"
#include "council_txt_reporter.mqh"
#include "council_attribution_intelligence.mqh"

//=========================================================
// Phase B — TREND_CONTINUATION Confirmation Reinforcement (opt-in, default OFF)
//=========================================================
input bool   EnableCouncilTrendContinuationConfirmationReinforcement = false;
input double CouncilTrendContReinforceMinConsensusStrength          = 0.85;
input double CouncilTrendContReinforceMaxConflict                   = 0.12;
input double CouncilTrendContReinforceMinEnvironmentScore           = 0.80;
input double CouncilTrendContReinforceMinCouncilQuality             = 0.75;
input double CouncilTrendContReinforceMinZoneConfidence             = 0.85;

int g_mt5io_trendcont_last_write_bar = -100000;

struct ContinuationConfirmationReinforcementAssessment
{
   bool   valid;
   bool   applied;
   bool   rescued;

   string reason_code;

   string zone_name;
   string regime_label;
   string decision_direction;
   string best_strategy_id;

   double zone_confidence;
   double consensus_strength;
   double conflict_score;
   double environment_score;
   double council_quality;
};

void InitContinuationConfirmationReinforcementAssessment(ContinuationConfirmationReinforcementAssessment &a)
{
   a.valid             = false;
   a.applied           = false;
   a.rescued           = false;
   a.reason_code       = "data_unavailable_no_reinforcement";
   a.zone_name         = "";
   a.regime_label      = "";
   a.decision_direction= "";
   a.best_strategy_id  = "";
   a.zone_confidence   = 0.0;
   a.consensus_strength= 0.0;
   a.conflict_score    = 0.0;
   a.environment_score = 0.0;
   a.council_quality   = 0.0;
}

double CouncilTrendContClamp01(const double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

bool BestStrategyIsTrendContinuationFamily(const string bestStrategyId)
{
   if(StringLen(bestStrategyId) <= 0) return false;

   string s = bestStrategyId;
   StringToLower(s);

   // Strict allowlist + conservative pattern support for continuation-family naming.
   if(s == "trend_momentum") return true;
   if(s == "momentum_breakout_cont_v1") return true;
   if(s == "micro_structure_reentry_v1") return true;

   // Conservative patterns
   bool hasTrendOrMomentum = (StringFind(s, "trend") >= 0) || (StringFind(s, "momentum") >= 0) || (StringFind(s, "reentry") >= 0);
   bool hasContinuationHint = (StringFind(s, "_cont") >= 0) || (StringFind(s, "continuation") >= 0) || (StringFind(s, "reentry") >= 0);
   bool isMeanReclaim = (StringFind(s, "mean") >= 0) || (StringFind(s, "reclaim") >= 0);

   return (hasTrendOrMomentum && hasContinuationHint && !isMeanReclaim);
}

bool DirectionRegimeAligned(const string direction, const string regimeSummary)
{
   if(StringLen(direction) <= 0) return false;
   if(StringLen(regimeSummary) <= 0) return false;

   string r = regimeSummary;
   StringToLower(r);

   bool up   = (StringFind(r, "trend_up") >= 0)   || (StringFind(r, "bull") >= 0);
   bool down = (StringFind(r, "trend_down") >= 0) || (StringFind(r, "bear") >= 0);

   if(up && !down)   return (direction == "BUY");
   if(down && !up)   return (direction == "SELL");

   // Ambiguous regime summary -> do not reinforce.
   return false;
}

string BuildTrendContinuationReinforcementStatusText(const ContinuationConfirmationReinforcementAssessment &a)
{
   string s = "";
   s += "trend_cont_confirmation_reinforcement\n";
   s += "applied: " + (a.applied ? "true" : "false") + "\n";
   s += "rescued: " + (a.rescued ? "true" : "false") + "\n";
   s += "reason_code: " + a.reason_code + "\n";
   s += "zone_name: " + a.zone_name + "\n";
   s += "regime_label: " + a.regime_label + "\n";
   s += "direction: " + a.decision_direction + "\n";
   s += "best_strategy_id: " + a.best_strategy_id + "\n";
   s += "zone_confidence: " + DoubleToString(a.zone_confidence, 2) + "\n";
   s += "consensus_strength: " + DoubleToString(a.consensus_strength, 2) + "\n";
   s += "conflict_score: " + DoubleToString(a.conflict_score, 2) + "\n";
   s += "environment_score: " + DoubleToString(a.environment_score, 2) + "\n";
   s += "council_quality: " + DoubleToString(a.council_quality, 2) + "\n";
   return s;
}

string CouncilTrendContJsonEscape(const string in)
{
   string out = in;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\n", "\\n");
   StringReplace(out, "\r", "\\r");
   return out;
}

string BuildTrendContinuationReinforcementStatusJson(const ContinuationConfirmationReinforcementAssessment &a)
{
   string j = "{";
   j += "\"applied\":" + (a.applied ? "true" : "false") + ",";
   j += "\"rescued\":" + (a.rescued ? "true" : "false") + ",";
   j += "\"reason_code\":\"" + CouncilTrendContJsonEscape(a.reason_code) + "\",";
   j += "\"zone_name\":\"" + CouncilTrendContJsonEscape(a.zone_name) + "\",";
   j += "\"regime_label\":\"" + CouncilTrendContJsonEscape(a.regime_label) + "\",";
   j += "\"direction\":\"" + CouncilTrendContJsonEscape(a.decision_direction) + "\",";
   j += "\"best_strategy_id\":\"" + CouncilTrendContJsonEscape(a.best_strategy_id) + "\",";
   j += "\"zone_confidence\":" + DoubleToString(a.zone_confidence, 4) + ",";
   j += "\"consensus_strength\":" + DoubleToString(a.consensus_strength, 4) + ",";
   j += "\"conflict_score\":" + DoubleToString(a.conflict_score, 4) + ",";
   j += "\"environment_score\":" + DoubleToString(a.environment_score, 4) + ",";
   j += "\"council_quality\":" + DoubleToString(a.council_quality, 4);
   j += "}";
   return j;
}

void SaveTrendContinuationReinforcementStatusBestEffort(const ContinuationConfirmationReinforcementAssessment &a)
{
   int currentBar = Bars(_Symbol, PERIOD_M1);
   bool gateActive = (EnableMT5IOReductionV1 && EnableTrendContGate);
   if(gateActive && g_mt5io_trendcont_last_write_bar >= 0)
   {
      int interval = MT5IO_TrendContStatusIntervalBars();
      if((currentBar - g_mt5io_trendcont_last_write_bar) < interval)
      {
         g_mt5io_trendcont_deferred_count++;
         return;
      }
   }

   string txtPath  = "AI\\council_trend_cont_confirmation_status.txt";
   string jsonPath = "AI\\council_trend_cont_confirmation_status.json";

   int h1 = FileOpen(txtPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h1 != INVALID_HANDLE)
   {
      FileWriteString(h1, BuildTrendContinuationReinforcementStatusText(a));
      FileClose(h1);
   }

   int h2 = FileOpen(jsonPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h2 != INVALID_HANDLE)
   {
      FileWriteString(h2, BuildTrendContinuationReinforcementStatusJson(a));
      FileClose(h2);
   }
   g_mt5io_trendcont_last_write_bar = currentBar;
   g_mt5io_trendcont_write_count++;
}

void ResolveTrendContReinforceThresholds(double &minConsensus, double &maxConflict, double &minEnv, double &minQuality, double &minZoneConf)
{
   minConsensus = CouncilTrendContClamp01(CouncilTrendContReinforceMinConsensusStrength);
   maxConflict  = CouncilTrendContClamp01(CouncilTrendContReinforceMaxConflict);
   minEnv       = CouncilTrendContClamp01(CouncilTrendContReinforceMinEnvironmentScore);
   minQuality   = CouncilTrendContClamp01(CouncilTrendContReinforceMinCouncilQuality);
   minZoneConf  = CouncilTrendContClamp01(CouncilTrendContReinforceMinZoneConfidence);
}

bool EvaluateTrendContinuationConfirmationReinforcement(
   const CouncilAggregateReport &agg,
   const CouncilEnvironmentReport &env,
   const CouncilPreAIGateReport &pre,
   ContinuationConfirmationReinforcementAssessment &a
)
{
   InitContinuationConfirmationReinforcementAssessment(a);

   // NO-SCORE HARD-LOCK:
   // Trend continuation reinforcement used score-like thresholds as a rescue-pass path.
   // It is disabled as live authority. Reactivation requires source review,
   // code change, recompile, and No-Score compliance audit.
   return false;

   // [DORMANT_BRANCH: TREND_CONTINUATION_REINFORCEMENT] flag=false; entire reinforcement evaluator dormant; returns false unconditionally; rescue path for missing confirmation role inactive
   if(!EnableCouncilTrendContinuationConfirmationReinforcement)
      return false;

   a.applied = true;

   // Apply ONLY when we are about to reject solely due to confirmation-role incompleteness.
   if(pre.passed) { a.reason_code = "data_unavailable_no_reinforcement"; return false; }
   if(pre.reason != "Confirmation role missing") { a.reason_code = "data_unavailable_no_reinforcement"; return false; }

   a.zone_name          = env.zone_name;
   a.regime_label       = env.regime_summary;
   a.zone_confidence    = env.zone_confidence;
   a.environment_score  = env.total_score;
   a.council_quality    = agg.council_quality;
   a.consensus_strength = agg.consensus_strength;
   a.conflict_score     = agg.conflict_score;
   a.best_strategy_id   = agg.best_strategy_id;
   a.decision_direction = agg.dominant_side;

   if(a.zone_name != "TREND_CONTINUATION")
   { a.reason_code = "not_trend_continuation"; return false; }

   if(a.decision_direction != "BUY" && a.decision_direction != "SELL")
   { a.reason_code = "data_unavailable_no_reinforcement"; return false; }

   a.valid = true;

   double minConsensus = 0.0, maxConflict = 0.0, minEnv = 0.0, minQuality = 0.0, minZoneConf = 0.0;
   ResolveTrendContReinforceThresholds(minConsensus, maxConflict, minEnv, minQuality, minZoneConf);

   if(!DirectionRegimeAligned(a.decision_direction, a.regime_label))
   { a.reason_code = "direction_regime_mismatch"; return false; }

   if(a.consensus_strength < minConsensus)
   { a.reason_code = "consensus_not_strong_enough"; return false; }

   if(a.conflict_score > maxConflict)
   { a.reason_code = "conflict_too_high"; return false; }

   if(a.environment_score < minEnv)
   { a.reason_code = "environment_not_clean_enough"; return false; }

   if(a.council_quality < minQuality)
   { a.reason_code = "council_quality_too_low"; return false; }

   if(a.zone_confidence < minZoneConf)
   { a.reason_code = "zone_confidence_too_low"; return false; }

   if(!BestStrategyIsTrendContinuationFamily(a.best_strategy_id))
   { a.reason_code = "best_strategy_not_continuation_family"; return false; }

   a.rescued = true;
   a.reason_code = "reinforced_pass";
   return true;
}

string CouncilEnvironmentHardConditionDetail(const CouncilEnvironmentReport &env)
{
   if(!env.liquidity_ok)
      return "liquidity_not_ok";

   if(!env.spread_ok)
      return "spread_not_ok";

   if(!env.volatility_ok)
      return "volatility_not_ok";

   return "hard_conditions_failed";
}

//---------------------------------------------------------
// Opportunity Ledger — instrumentation globals
// OPPORTUNITY_LEDGER_IMPLEMENTATION_V1A_PLUS
// Write-only. No decision path reads these globals.
//---------------------------------------------------------
bool                       g_opp_counters_initialized    = false;
StrategyOpportunityCounter g_opportunity_counters[COUNCIL_MAX_STRATEGIES];
int                        g_unique_m1_bar_count         = 0;
int                        g_total_trigger_writes        = 0;
datetime                   g_last_seen_m1_bar_time       = 0;
datetime                   g_last_summary_flush_bar_time = 0;
int                        g_last_summary_flush_bar_count= 0;
int                        g_last_trigger_flush_count    = 0;
int                        g_ol_rbsr_state_seen_count    = 0;
int                        g_ol_tpc_state_seen_count     = 0;
int                        g_ol_vcr_state_seen_count     = 0;
int                        g_ol_ifr_state_seen_count     = 0;  // IFR / IMBALANCE_FILL_REVERSAL
int                        g_ol_late_evidence_seen_count = 0;
int                        g_ol_event_order_invalid_seen_count = 0;
int                        g_ol_registry_unknown_strategy_seen_count = 0;

//---------------------------------------------------------
// Opportunity Ledger helper functions
//---------------------------------------------------------
string OpportunityJsonEscape(const string in)
{
   string out = in;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\n", "\\n");
   StringReplace(out, "\r", "\\r");
   StringReplace(out, "\t", "\\t");
   return out;
}

void InitOpportunityCounters(StrategyOpportunityCounter &counters[], int count)
{
   for(int i = 0; i < count; i++)
   {
      counters[i].strategy_id                          = "";
      counters[i].strategy_family                      = "";
      counters[i].current_role                         = "";
      counters[i].evaluations_seen                     = 0;
      counters[i].valid_context_seen                   = 0;
      counters[i].setup_conditions_seen                = 0;
      counters[i].trigger_seen                         = 0;
      counters[i].trigger_blocked_by_dsn               = 0;
      counters[i].trigger_blocked_by_crr               = 0;
      counters[i].trigger_blocked_by_no_trade          = 0;
      counters[i].trigger_blocked_by_quality_gate      = 0;
      counters[i].trigger_blocked_by_veto              = 0;
      counters[i].trigger_blocked_by_direction         = 0;
      counters[i].trigger_blocked_by_regime            = 0;
      counters[i].trigger_rejected_by_central_decision = 0;
      counters[i].trigger_executed                     = 0;
      counters[i].win_count                            = 0;
      counters[i].loss_count                           = 0;
      counters[i].open_count                           = 0;
      counters[i].sum_mae_pts                          = 0.0;
      counters[i].sum_mfe_pts                          = 0.0;
      counters[i].mae_count                            = 0;
      counters[i].mfe_count                            = 0;
      counters[i].last_seen_timestamp                  = "";
      counters[i].last_trigger_timestamp               = "";
      counters[i].last_written_bar_time                = "";
      counters[i].write_failures                       = 0;
      counters[i].no_confirm_seen                      = 0;
      counters[i].same_family_confirm_seen             = 0;
      counters[i].cross_family_confirm_seen            = 0;
      counters[i].multi_family_confirm_seen            = 0;
   }
}

void IncrementEvaluationCounter(
   StrategyOpportunityCounter      &counter,
   const CouncilStrategyReport     &report,
   const CouncilEnvironmentReport  &env,
   const CouncilPreAIGateReport    &pre,
   CouncilDecision                  final_decision,
   const OL_CrossFamilyEvidence    &cfe
)
{
   counter.evaluations_seen++;

   if(StringLen(report.strategy_id) > 0)
      counter.strategy_id = report.strategy_id;
   if(StringLen(report.strategy_family) > 0)
      counter.strategy_family = report.strategy_family;
   if(StringLen(report.role_name) > 0)
      counter.current_role = report.role_name;

   if(env.valid && env.tradable)
      counter.valid_context_seen++;

   if(report.confidence > 0.0 || report.score_final > 0.0)
      counter.setup_conditions_seen++;

   counter.last_seen_timestamp = TimeToString(TimeCurrent(),
                                              TIME_DATE|TIME_MINUTES|TIME_SECONDS);

   if(report.trigger_present)
   {
      counter.trigger_seen++;
      counter.last_trigger_timestamp = counter.last_seen_timestamp;

      // Direction and regime are independent dimensions
      if(report.counter_trend)
         counter.trigger_blocked_by_direction++;
      if(report.blocked_by_zone)
         counter.trigger_blocked_by_regime++;

      // Primary gate classification (mutually exclusive primary reason)
      string gate = pre.structural_reject_gate;
      if(gate == "DIVERSITY_SAFETY_NET")
         counter.trigger_blocked_by_dsn++;
      else if(gate == "CONFIRM_ROLE_REQUIRED")
         counter.trigger_blocked_by_crr++;
      else if(gate == "NO_TRADE_ZONE" || gate == "ENVIRONMENT_HARD_CONDITION")
         counter.trigger_blocked_by_no_trade++;
      else if(!pre.passed &&
              (final_decision == COUNCIL_DECISION_REJECT ||
               final_decision == COUNCIL_DECISION_WAIT))
         counter.trigger_rejected_by_central_decision++;
      else if(final_decision == COUNCIL_DECISION_BUY ||
              final_decision == COUNCIL_DECISION_SELL)
         counter.trigger_executed++;

      // Cross-family confirm summary counters (Phase 4A-i)
      // Attribution evidence only — no decision influence.
      if(cfe.confirm_structure_type == "NONE")
         counter.no_confirm_seen++;
      else if(cfe.confirm_structure_type == "SAME_FAMILY_CONFIRM")
         counter.same_family_confirm_seen++;
      else if(cfe.confirm_structure_type == "CROSS_FAMILY_CONFIRM")
         counter.cross_family_confirm_seen++;
      else if(cfe.confirm_structure_type == "MULTI_FAMILY_CONFIRM")
         counter.multi_family_confirm_seen++;
   }
}

//---------------------------------------------------------
// OL_ComputeCrossFamilyEvidence
// PHASE_4A_I_LEDGER_EXTENSION_V1
// Classifies confirmation structure for one council bar.
// Called once per bar before the per-strategy write loop.
// Attribution evidence only — no score, no gate, no weight.
//---------------------------------------------------------
OL_CrossFamilyEvidence OL_ComputeCrossFamilyEvidence(
   CouncilStrategyReport       &reports[],
   int                          reportCount,
   const CouncilRuntimeResult  &runtime
)
{
   OL_CrossFamilyEvidence cfe;
   cfe.primary_executor_id              = "";
   cfe.primary_executor_family          = "";
   cfe.same_family_confirm_present      = false;
   cfe.cross_family_confirm_present     = false;
   cfe.cross_family_confirm_strategy_id = "";
   cfe.cross_family_confirm_family      = "";
   cfe.confirm_structure_type           = "NONE";
   cfe.confirm_family_count             = 0;
   cfe.confirm_strategy_count           = 0;

   string dom = runtime.aggregate.dominant_side;
   if(dom != "BUY" && dom != "SELL")
      return cfe;

   //--- Step 1: infer primary executor ---
   // Priority 1 (authoritative): aggregate.best_strategy_id follows aggregator
   // weight/contribution semantics — use it if the report is a safe, non-BLOCKED,
   // dominant-side match. This aligns attribution with actual council authority.
   // Priority 2 (heuristic fallback): lead-capable role (TREND_JUDGE, SCOUT) with
   // highest score_final, used only when best_strategy_id is empty or has no safe match.
   // If neither resolves: leave primary_executor_id/family empty — no aggressive inference.
   string aggBestId = runtime.aggregate.best_strategy_id;
   if(StringLen(aggBestId) > 0)
   {
      for(int i = 0; i < reportCount && i < COUNCIL_MAX_STRATEGIES; i++)
      {
         if(reports[i].strategy_id != aggBestId) continue;
         if(!reports[i].valid || !reports[i].enabled) break;
         if(reports[i].eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED) break;
         bool supportsDom =
            (dom == "BUY"  && reports[i].decision == COUNCIL_DECISION_BUY) ||
            (dom == "SELL" && reports[i].decision == COUNCIL_DECISION_SELL);
         if(!supportsDom) break;  // best_strategy_id is counter-direction — leave primary empty
         cfe.primary_executor_id     = reports[i].strategy_id;
         cfe.primary_executor_family = reports[i].strategy_family;
         break;
      }
   }

   // Heuristic fallback: lead-capable role by score_final.
   // Used only when aggregate.best_strategy_id is empty or its report has no safe
   // dominant-side match. Documented as heuristic — not treated as authoritative.
   if(StringLen(cfe.primary_executor_id) == 0)
   {
      double bestLeadScore  = -1.0;
      string bestLeadId     = "";
      string bestLeadFamily = "";
      for(int i = 0; i < reportCount && i < COUNCIL_MAX_STRATEGIES; i++)
      {
         if(!reports[i].valid || !reports[i].enabled) continue;
         if(reports[i].eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED) continue;
         bool supportsDom =
            (dom == "BUY"  && reports[i].decision == COUNCIL_DECISION_BUY) ||
            (dom == "SELL" && reports[i].decision == COUNCIL_DECISION_SELL);
         if(!supportsDom) continue;
         if(reports[i].role != COUNCIL_ROLE_TREND_JUDGE &&
            reports[i].role != COUNCIL_ROLE_SCOUT) continue;
         if(reports[i].score_final > bestLeadScore)
         {
            bestLeadScore  = reports[i].score_final;
            bestLeadId     = reports[i].strategy_id;
            bestLeadFamily = reports[i].strategy_family;
         }
      }
      if(StringLen(bestLeadId) > 0)
      {
         cfe.primary_executor_id     = bestLeadId;
         cfe.primary_executor_family = bestLeadFamily;
      }
      // If still empty: leave primary_executor_id/family as "" — no aggressive fallback.
   }

   //--- Step 2: find CONFIRM strategies supporting dominant side ---
   // Eligibility filter: ACTIVE or REDUCED only.
   // OBSERVE_ONLY excluded — weak/background confirms must not produce an unqualified
   // cross_family_confirm_present=true that misrepresents evidence strength.
   // BLOCKED excluded. UNSET excluded.
   // confirm_strategy_count and confirm_family_count track ACTIVE+REDUCED confirms only.
   // This is ledger classification only — does not change CRR or confirm_role_present.
   string cfFamilies = "";

   for(int i = 0; i < reportCount && i < COUNCIL_MAX_STRATEGIES; i++)
   {
      if(!reports[i].valid || !reports[i].enabled) continue;
      if(reports[i].eligibility_state != COUNCIL_ELIGIBILITY_ACTIVE &&
         reports[i].eligibility_state != COUNCIL_ELIGIBILITY_REDUCED) continue;
      if(reports[i].role != COUNCIL_ROLE_CONFIRM) continue;

      bool supportsDom =
         (dom == "BUY"  && reports[i].decision == COUNCIL_DECISION_BUY) ||
         (dom == "SELL" && reports[i].decision == COUNCIL_DECISION_SELL);
      if(!supportsDom) continue;

      cfe.confirm_strategy_count++;

      // Track distinct confirm families
      bool familyNew = true;
      if(StringLen(cfFamilies) > 0)
      {
         string padded = "," + cfFamilies + ",";
         string target = "," + reports[i].strategy_family + ",";
         if(StringFind(padded, target) >= 0)
            familyNew = false;
      }
      if(familyNew)
      {
         cfFamilies += (StringLen(cfFamilies) > 0 ? "," : "") + reports[i].strategy_family;
         cfe.confirm_family_count++;
      }

      // Classify same/cross family only when primary is known
      if(StringLen(cfe.primary_executor_family) == 0)
      {
         // Cannot classify safely — primary family unknown; no cross-family claim
         cfe.same_family_confirm_present = true;  // conservative: treat as same-family
      }
      else if(reports[i].strategy_family == cfe.primary_executor_family)
      {
         cfe.same_family_confirm_present = true;
      }
      else
      {
         cfe.cross_family_confirm_present = true;
         if(StringLen(cfe.cross_family_confirm_strategy_id) == 0)
         {
            cfe.cross_family_confirm_strategy_id = reports[i].strategy_id;
            cfe.cross_family_confirm_family      = reports[i].strategy_family;
         }
      }
   }

   //--- Step 3: classify confirm_structure_type ---
   if(cfe.confirm_strategy_count == 0)
      cfe.confirm_structure_type = "NONE";
   else if(cfe.cross_family_confirm_present && cfe.same_family_confirm_present)
      cfe.confirm_structure_type = "MULTI_FAMILY_CONFIRM";
   else if(cfe.cross_family_confirm_present)
      cfe.confirm_structure_type = "CROSS_FAMILY_CONFIRM";
   else
      cfe.confirm_structure_type = "SAME_FAMILY_CONFIRM";

   return cfe;
}

//---------------------------------------------------------
// Playbook architecture helpers - V1C
// Ledger-only shadow state. No decision, score, gate, risk,
// execution, role, trigger, or weight authority.
//---------------------------------------------------------
void OL_InitPlaybookShadowState(OL_PlaybookShadowState &pss, const string playbook_id)
{
   pss.playbook_id                  = playbook_id;
   pss.playbook_state               = "PLAYBOOK_NOT_PRESENT";
   pss.primary_packet_id            = "";
   pss.completed_links_json         = "[]";
   pss.missing_links_json           = "[]";
   pss.contradicted_links_json      = "[]";
   pss.failure_mode_present         = false;
   pss.failure_mode_type            = "";
   pss.required_evidence_present    = false;
   pss.supporting_evidence_present  = false;
   pss.optional_evidence_present    = false;
   pss.room_state                   = "UNKNOWN";
   pss.stop_geometry_state          = "UNKNOWN";
   pss.pre_decision_available       = false;
   pss.late_evidence                = false;
   pss.attribution_note             = "";
   pss.state_reason                 = "NO_PLAYBOOK_EVIDENCE";
}

void OL_InitEventOrderTrace(OL_EventOrderTrace &eot)
{
   eot.context_timestamp              = "";
   eot.location_timestamp             = "";
   eot.trigger_timestamp              = "";
   eot.confirm_timestamp              = "";
   eot.failure_mode_timestamp         = "";
   eot.room_timestamp                 = "";
   eot.stop_geometry_timestamp        = "";
   eot.playbook_state_timestamp       = "";
   eot.decision_timestamp             = "";
   eot.pre_decision_available         = false;
   eot.late_evidence                  = false;
   eot.event_order_valid              = false;
   eot.event_order_violation_reason   = "TIMESTAMP_SOURCE_UNAVAILABLE";
}

string OL_RuntimeAuthorityStatus()
{
   return "NONE";
}

bool OL_StrategyTriggeredOrVoted(const CouncilStrategyReport &report)
{
   if(!report.valid || !report.enabled)
      return false;
   if(report.eligibility_state != COUNCIL_ELIGIBILITY_ACTIVE &&
      report.eligibility_state != COUNCIL_ELIGIBILITY_REDUCED)
      return false;
   if(report.trigger_present)
      return true;
   if(report.decision == COUNCIL_DECISION_BUY ||
      report.decision == COUNCIL_DECISION_SELL)
      return true;
   return false;
}

bool OL_FVGAttributionRecordAvailable(const CouncilStrategyReport &report)
{
   if(!report.valid || !report.enabled)
      return false;
   return (report.strategy_id == "fvg_tpb" && g_fvg_attribution.has_data);
}

bool OL_StrategySupportsDirection(const CouncilStrategyReport &report, const string direction)
{
   if(!OL_StrategyTriggeredOrVoted(report))
      return false;
   if(direction == "BUY")
      return (report.decision == COUNCIL_DECISION_BUY);
   if(direction == "SELL")
      return (report.decision == COUNCIL_DECISION_SELL);
   return false;
}

int OL_FindStrategyReportIndex(
   CouncilStrategyReport &reports[],
   int                    reportCount,
   const string           strategy_id
)
{
   if(StringLen(strategy_id) <= 0)
      return -1;

   for(int i = 0; i < reportCount && i < COUNCIL_MAX_STRATEGIES; i++)
   {
      if(reports[i].strategy_id == strategy_id)
         return i;
   }
   return -1;
}

bool OL_StrategyIdTriggeredOrVoted(
   CouncilStrategyReport &reports[],
   int                    reportCount,
   const string           strategy_id
)
{
   int idx = OL_FindStrategyReportIndex(reports, reportCount, strategy_id);
   if(idx < 0)
      return false;
   return OL_StrategyTriggeredOrVoted(reports[idx]);
}

string OL_FirstStrategyDirection(
   CouncilStrategyReport &reports[],
   int                    reportCount,
   const string           strategy_id
)
{
   int idx = OL_FindStrategyReportIndex(reports, reportCount, strategy_id);
   if(idx < 0)
      return "";
   if(!OL_StrategyTriggeredOrVoted(reports[idx]))
      return "";
   if(reports[idx].decision == COUNCIL_DECISION_BUY)
      return "BUY";
   if(reports[idx].decision == COUNCIL_DECISION_SELL)
      return "SELL";
   return "";
}

bool OL_StrategyIdSupportsDirection(
   CouncilStrategyReport &reports[],
   int                    reportCount,
   const string           strategy_id,
   const string           direction
)
{
   int idx = OL_FindStrategyReportIndex(reports, reportCount, strategy_id);
   if(idx < 0)
      return false;
   return OL_StrategySupportsDirection(reports[idx], direction);
}

string OL_LinkJson(
   const string a,
   const string b,
   const string c,
   const string d,
   const string e
)
{
   string j = "[";
   int n = 0;
   string vals[5];
   vals[0] = a;
   vals[1] = b;
   vals[2] = c;
   vals[3] = d;
   vals[4] = e;

   for(int i = 0; i < 5; i++)
   {
      if(StringLen(vals[i]) <= 0)
         continue;
      if(n > 0)
         j += ",";
      j += "\"" + OpportunityJsonEscape(vals[i]) + "\"";
      n++;
   }
   j += "]";
   return j;
}

string OL_FirstPresentStrategy(
   CouncilStrategyReport &reports[],
   int                    reportCount,
   const string           a,
   const string           b,
   const string           c,
   const string           d,
   const string           e
)
{
   string ids[5];
   ids[0] = a;
   ids[1] = b;
   ids[2] = c;
   ids[3] = d;
   ids[4] = e;

   for(int i = 0; i < 5; i++)
   {
      if(StringLen(ids[i]) <= 0)
         continue;
      if(OL_StrategyIdTriggeredOrVoted(reports, reportCount, ids[i]))
         return ids[i];
   }
   return "";
}

string OL_PacketRegistryStatusForStrategy(const string strategy_id)
{
   string sid = strategy_id;
   StringToLower(sid);

   if(sid == "sweep_reversal")             return "RESEARCH_ONLY";
   if(sid == "bollinger_reclaim")          return "RESEARCH_ONLY";
   if(sid == "mfi_reversal_assist")        return "DATA_INSUFFICIENT";
   if(sid == "range_edge_fade")            return "RESEARCH_ONLY";

   if(sid == "trend_momentum")             return "RESEARCH_ONLY";
   if(sid == "trend_pullback_cont_v1")     return "ACCEPTED_RESEARCH";
   if(sid == "breakdown_momentum_v1")      return "RESEARCH_ONLY";
   if(sid == "lower_high_rejection_v1")    return "RESEARCH_ONLY";
   if(sid == "micro_structure_reentry_v1") return "RESEARCH_ONLY";

   if(sid == "range_compression_breakout") return "DATA_INSUFFICIENT";
   if(sid == "volatility_squeeze_release") return "DATA_INSUFFICIENT";
   if(sid == "volatility_breakout")        return "DATA_INSUFFICIENT";
   if(sid == "expansion_continuation")     return "DATA_INSUFFICIENT";
   if(sid == "micro_range_expansion")      return "DATA_INSUFFICIENT";
   if(sid == "momentum_breakout_cont_v1")  return "FROZEN_OR_LEGACY";

   if(sid == "mean_reversion_bounce")     return "RESEARCH_ONLY";
   if(sid == "fake_break_reversal")       return "RESEARCH_ONLY";

   // FVG_TPB: external candidate admitted by operator authorization
   // INEC certification: ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE, N=2442, WR=43.41%
   if(sid == "fvg_tpb")                  return "ALPHA_TRIGGER_ADMITTED_IFR";

   return "UNKNOWN";
}

string OL_PrimaryPlaybookForStrategy(const string strategy_id)
{
   string sid = strategy_id;
   StringToLower(sid);

   if(sid == "sweep_reversal" ||
      sid == "bollinger_reclaim" ||
      sid == "mfi_reversal_assist" ||
      sid == "range_edge_fade" ||
      sid == "mean_reversion_bounce" ||
      sid == "fake_break_reversal")
      return "RANGE_BOUNDARY_SWEEP_RECLAIM";

   if(sid == "trend_momentum" ||
      sid == "trend_pullback_cont_v1" ||
      sid == "breakdown_momentum_v1" ||
      sid == "lower_high_rejection_v1" ||
      sid == "micro_structure_reentry_v1")
      return "TREND_PULLBACK_CONTINUATION";

   if(sid == "range_compression_breakout" ||
      sid == "volatility_squeeze_release" ||
      sid == "volatility_breakout" ||
      sid == "expansion_continuation" ||
      sid == "micro_range_expansion")
      return "VOLATILITY_COMPRESSION_RELEASE";

   // FVG_TPB assigned to IFR playbook lane (operator-authorized)
   if(sid == "fvg_tpb")
      return "IMBALANCE_FILL_REVERSAL";

   return "PLAYBOOK_ASSIGNMENT_UNVERIFIED";
}

bool IRREW_MasterDevEnabled(const bool masterFlag)
{
   return masterFlag;
}

bool IRREW_SubFlagActive(const bool masterFlag, const bool subFlag)
{
   return (masterFlag && subFlag);
}

string IRREW_PacketClassForStrategy(const string strategy_id)
{
   string sid = strategy_id;
   StringToLower(sid);

   if(sid == "fvg_tpb" ||
      sid == "sweep_reversal" ||
      sid == "trend_momentum" ||
      sid == "volatility_breakout" ||
      sid == "expansion_continuation")
      return "ALPHA_TRIGGER_PACKET";

   if(sid == "trend_pullback_cont_v1" ||
      sid == "bollinger_reclaim" ||
      sid == "range_edge_fade" ||
      sid == "mean_reversion_bounce" ||
      sid == "micro_structure_reentry_v1" ||
      sid == "breakdown_momentum_v1" ||
      sid == "fake_break_reversal")
      return "CONFIRMATION_PACKET";

   if(sid == "mfi_reversal_assist" ||
      sid == "lower_high_rejection_v1" ||
      sid == "momentum_breakout_cont_v1")
      return "FAILURE_MODE_PACKET";

   if(sid == "range_compression_breakout" ||
      sid == "volatility_squeeze_release" ||
      sid == "micro_range_expansion")
      return "ROOM_PACKET";

   return "UNKNOWN_PACKET";
}

string IRREW_PacketStatusForStrategy(const string strategy_id)
{
   string status = OL_PacketRegistryStatusForStrategy(strategy_id);
   if(status == "UNKNOWN")
      return "UNREGISTERED";
   return status;
}

string IRREW_PacketIdentityState(const string strategy_id)
{
   string packetClass = IRREW_PacketClassForStrategy(strategy_id);
   if(packetClass == "UNKNOWN_PACKET")
      return "UNKNOWN_PACKET";
   return "REGISTERED_PACKET_IDENTITY";
}

string IRREW_PlaybookForStrategy(const string strategy_id)
{
   return OL_PrimaryPlaybookForStrategy(strategy_id);
}

bool IRREW_PlaybookStateVocabularyAllowed(const string playbook_id, const string state)
{
   if(StringLen(TrimString(playbook_id)) <= 0)
      return false;

   return (state == "PLAYBOOK_NOT_PRESENT" ||
           state == "PLAYBOOK_FORMING" ||
           state == "PLAYBOOK_VALID" ||
           state == "PLAYBOOK_CONTRADICTED" ||
           state == "PLAYBOOK_INVALID" ||
           state == "PLAYBOOK_LATE");
}

bool IRREW_IsPacketStructurallyUnknown(const string packet_state)
{
   return (packet_state == "UNKNOWN_PACKET");
}

bool IRREW_IsPacketRejected(const string packet_status)
{
   return (packet_status == "REJECTED_PACKET");
}

void IRREW_BuildPacketRegistryConsumption(
   const string strategy_id,
   CouncilPacketRegistryConsumptionReport &outReport
)
{
   InitCouncilPacketRegistryConsumptionReport(outReport);
   outReport.packet_class = IRREW_PacketClassForStrategy(strategy_id);
   outReport.packet_registry_status = IRREW_PacketStatusForStrategy(strategy_id);
   outReport.packet_identity_state = IRREW_PacketIdentityState(strategy_id);
}

void IRREW_BuildPlaybookConsumption(
   const string strategy_id,
   const string playbook_state,
   CouncilPlaybookConsumptionReport &outReport
)
{
   InitCouncilPlaybookConsumptionReport(outReport);
   outReport.playbook_id = IRREW_PlaybookForStrategy(strategy_id);
   if(IRREW_PlaybookStateVocabularyAllowed(outReport.playbook_id, playbook_state))
      outReport.playbook_state = playbook_state;
   else
      outReport.playbook_state = "PLAYBOOK_NOT_PRESENT";
   outReport.playbook_thesis_complete = (outReport.playbook_state == "PLAYBOOK_VALID");
}

int IRREW_DevelopmentWaitPriority(const string reason)
{
   if(StringFind(reason, "IRREW_PHASE4B") == 0)
      return 5;
   if(StringFind(reason, "IRREW_PHASE4A") == 0)
      return 4;
   if(StringFind(reason, "IRREW_PHASE4C") == 0)
      return 3;
   if(StringFind(reason, "IRREW_RCEM") == 0)
      return 2;
   if(StringFind(reason, "IRREW_EXECUTION_GEOMETRY") == 0)
      return 1;
   return 0;
}

void IRREW_AddDevelopmentWaitReason(
   CouncilIRREWDevelopmentActionReport &action,
   const string reason,
   const string flagName
)
{
   string r = TrimString(reason);
   if(StringLen(r) <= 0)
      return;

   if(StringLen(action.irrew_development_wait_reasons_all) > 0)
      action.irrew_development_wait_reasons_all += ";";
   action.irrew_development_wait_reasons_all += r;

   action.development_wait_requested = true;
   if(StringLen(action.primary_development_wait_reason) <= 0 ||
      IRREW_DevelopmentWaitPriority(r) > IRREW_DevelopmentWaitPriority(action.primary_development_wait_reason))
   {
      action.primary_development_wait_reason = r;
      action.irrew_dev_flag_that_fired = flagName;
   }
}

void IRREW_BuildInitialDevelopmentActionReport(
   const CouncilAggregateReport &agg,
   const CouncilFailurePatternReport &failDet,
   const CouncilDecision baselineDecision,
   CouncilIRREWDevelopmentActionReport &outReport
)
{
   InitCouncilIRREWDevelopmentActionReport(outReport);
   outReport.baseline_decision_before_irrew_dev = CouncilDecisionToText(baselineDecision);
   outReport.final_decision_after_irrew_dev = CouncilDecisionToText(baselineDecision);

   bool hasFailureTag = (StringLen(TrimString(failDet.dominant_failure_tag)) > 0 &&
                         failDet.dominant_failure_tag != "NONE");
   outReport.failure_mode_present = (failDet.valid && hasFailureTag);
   outReport.failure_mode_type = outReport.failure_mode_present ? failDet.dominant_failure_tag : "";
   outReport.failure_packet_id = outReport.failure_mode_present ? "council_failure_detector" : "";
   outReport.failure_mode_direction = agg.dominant_side;
   outReport.pre_decision_available = failDet.valid;
   outReport.failure_mode_action_candidate =
      outReport.failure_mode_present ? "RISK_WARNING_CANDIDATE" : "";
}

bool IRREW_DecisionIsDirectional(const CouncilDecision d)
{
   return (d == COUNCIL_DECISION_BUY || d == COUNCIL_DECISION_SELL);
}

double IRREW_ReportEffectiveWeight(const CouncilStrategyReport &s)
{
   double w = s.vote_weight;
   if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
      w = 0.0;
   else if(s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      w = 0.0;
   else if(s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
      w *= 0.75;
   return CouncilClamp(w);
}

string IRREW_PrimaryThesisFamily(const CouncilAggregateReport &agg)
{
   string family = LAB_InferFamilyFromStrategyId(agg.primary_thesis_strategy_id);
   if(StringLen(TrimString(family)) <= 0 || family == "UNKNOWN")
      family = agg.execution_admission_family;
   return family;
}

bool IRREW_IsConfirmationCompatibleRole(const CouncilStrategyRole role)
{
   return (role == COUNCIL_ROLE_CONFIRM);
}

bool IRREW_HasCrossFamilyRoleConfirmation(
   CouncilStrategyReport &reports[],
   int reportCount,
   const string primaryFamily,
   const string direction
)
{
   string pf = TrimString(primaryFamily);
   if(StringLen(pf) <= 0 || pf == "UNKNOWN")
      return false;

   for(int i = 0; i < reportCount; i++)
   {
      CouncilStrategyReport s = reports[i];
      if(!s.valid || !s.enabled || !s.trigger_present)
         continue;

      if(direction == "BUY" && s.decision != COUNCIL_DECISION_BUY)
         continue;
      if(direction == "SELL" && s.decision != COUNCIL_DECISION_SELL)
         continue;
      if(direction != "BUY" && direction != "SELL")
         continue;

      if(s.strategy_family == pf)
         continue;
      if(!IRREW_IsConfirmationCompatibleRole(s.role))
         continue;
      if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED ||
         s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
         continue;
      if(IRREW_ReportEffectiveWeight(s) <= 0.0)
         continue;

      CouncilPacketRegistryConsumptionReport packetAudit;
      IRREW_BuildPacketRegistryConsumption(s.strategy_id, packetAudit);
      if(IRREW_IsPacketRejected(packetAudit.packet_registry_status))
         continue;
      if(IRREW_IsPacketStructurallyUnknown(packetAudit.packet_identity_state))
         continue;

      return true;
   }

   return false;
}

bool IRREW_IsPhase4AContext(const CouncilAggregateReport &agg, const CouncilEnvironmentReport &env)
{
   bool scopedZone =
      (env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
       env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION ||
       env.zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION);

   bool scopedConsensus =
      (agg.consensus_type == COUNCIL_CONSENSUS_NARROW ||
       agg.consensus_type == COUNCIL_CONSENSUS_DIVERSE ||
       agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION);

   return (scopedZone && (agg.trend_judge_supportive || scopedConsensus));
}

void IRREW_EvaluatePhase4ADev(
   CouncilStrategyReport &reports[],
   int reportCount,
   const CouncilAggregateReport &agg,
   const CouncilEnvironmentReport &env,
   const CouncilDecision baselineDecision,
   CouncilIRREWDevelopmentActionReport &action
)
{
   if(!IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPhase4ADev))
      return;
   if(!IRREW_DecisionIsDirectional(baselineDecision))
      return;
   if(!IRREW_IsPhase4AContext(agg, env))
      return;

   string primaryFamily = IRREW_PrimaryThesisFamily(agg);
   if(!IRREW_HasCrossFamilyRoleConfirmation(reports, reportCount, primaryFamily, agg.dominant_side))
   {
      action.advisory_wait_preference = true;
      IRREW_AddDevelopmentWaitReason(
         action,
         "IRREW_PHASE4A_DEV_WAIT_MISSING_CROSS_FAMILY_ROLE_CONFIRM",
         "EnableIRREWPhase4ADev"
      );
   }
}

void IRREW_EvaluatePhase4BDev(
   const CouncilAggregateReport &agg,
   const CouncilEnvironmentReport &env,
   const CouncilFailurePatternReport &failDet,
   const CouncilDecision baselineDecision,
   CouncilIRREWDevelopmentActionReport &action
)
{
   if(!IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPhase4BDev))
      return;
   if(!IRREW_DecisionIsDirectional(baselineDecision))
      return;
   if(!IRREW_IsPhase4AContext(agg, env))
      return;

   bool failureOrExhaustion = (agg.exhaustion_warning ||
                               (failDet.valid && failDet.exhaustion_risk_detected));
   if(!failureOrExhaustion)
      return;

   action.v1_caution_present = true;
   action.risk_warning_present = true;
   action.advisory_wait_preference = true;
   if(StringLen(action.failure_mode_action_candidate) <= 0)
      action.failure_mode_action_candidate = "DEVELOPMENT_WAIT_CANDIDATE";
   IRREW_AddDevelopmentWaitReason(
      action,
      "IRREW_PHASE4B_DEV_WAIT_FAILURE_EXHAUSTION",
      "EnableIRREWPhase4BDev"
   );
}

string IRREW_DeriveThesisQualityState(
   const CouncilAggregateReport &agg,
   const CouncilFailurePatternReport &failDet,
   const CouncilDecision baselineDecision
)
{
   if(!IRREW_DecisionIsDirectional(baselineDecision))
      return "THESIS_QUALITY_UNCERTAIN";

   if(failDet.valid && (failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_HIGH ||
                        failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_CRITICAL))
      return "THESIS_QUALITY_CONTRADICTED";

   if(!agg.confirm_role_present || agg.consensus_type == COUNCIL_CONSENSUS_NONE)
      return "THESIS_QUALITY_INCOMPLETE";

   if(agg.consensus_type == COUNCIL_CONSENSUS_NARROW)
      return "THESIS_QUALITY_THIN";

   if(agg.consensus_type == COUNCIL_CONSENSUS_DIVERSE ||
      agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION)
      return "THESIS_QUALITY_CLEAR";

   return "THESIS_QUALITY_UNCERTAIN";
}

void IRREW_EvaluatePhase4CDev(
   const CouncilAggregateReport &agg,
   const CouncilFailurePatternReport &failDet,
   const CouncilDecision baselineDecision,
   CouncilIRREWDevelopmentActionReport &action
)
{
   action.thesis_quality_state = IRREW_DeriveThesisQualityState(agg, failDet, baselineDecision);

   if(!IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPhase4CDev))
      return;
   if(!IRREW_DecisionIsDirectional(baselineDecision))
      return;

   if(action.thesis_quality_state == "THESIS_QUALITY_THIN" ||
      action.thesis_quality_state == "THESIS_QUALITY_UNCERTAIN")
   {
      action.advisory_wait_preference = true;
      action.v1_caution_present = true;
      return;
   }

   if(action.thesis_quality_state == "THESIS_QUALITY_CONTRADICTED" ||
      action.thesis_quality_state == "THESIS_QUALITY_INCOMPLETE")
   {
      action.v1_caution_present = true;
      action.risk_warning_present = true;
      action.advisory_wait_preference = true;
      IRREW_AddDevelopmentWaitReason(
         action,
         "IRREW_PHASE4C_DEV_WAIT_THESIS_QUALITY",
         "EnableIRREWPhase4CDev"
      );
   }
}

string IRREW_RCEMStateForContext(const CouncilAggregateReport &agg, const CouncilEnvironmentReport &env)
{
   string family = agg.execution_admission_family;

   if(env.zone_type == COUNCIL_ZONE_NO_TRADE)
      return "BLOCKED";

   if(family == "IMBALANCE_FILL_REVERSAL")
      return "OBSERVE_ONLY";

   if(family == "TREND_CONTINUATION" &&
      env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)
      return "OBSERVE_ONLY";

   if(family == "MEAN_RECLAIM" &&
      env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION)
      return "REDUCED";

   return "ALLOWED_BY_NO_CERTIFIED_RESTRICTION";
}

void IRREW_EvaluateRCEMDev(
   const CouncilAggregateReport &agg,
   const CouncilEnvironmentReport &env,
   const CouncilDecision baselineDecision,
   CouncilIRREWDevelopmentActionReport &action
)
{
   if(!IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWRCEMDev))
      return;
   if(!IRREW_DecisionIsDirectional(baselineDecision))
      return;

   string state = IRREW_RCEMStateForContext(agg, env);
   if(state == "REDUCED")
   {
      action.v1_caution_present = true;
      action.advisory_wait_preference = true;
   }
   else if(state == "OBSERVE_ONLY" || state == "BLOCKED")
   {
      action.v1_caution_present = true;
      action.risk_warning_present = true;
      action.advisory_wait_preference = true;
      IRREW_AddDevelopmentWaitReason(
         action,
         "IRREW_RCEM_DEV_WAIT_CATEGORICAL_ELIGIBILITY",
         "EnableIRREWRCEMDev"
      );
   }
}

void IRREW_ApplyDevelopmentWaitProtocol(
   CouncilRuntimeResult &runtime,
   CouncilIRREWDevelopmentActionReport &action
)
{
   bool changedToWait = false;
   if(action.development_wait_requested && IRREW_DecisionIsDirectional(runtime.final_decision))
   {
      runtime.final_decision = COUNCIL_DECISION_WAIT;
      changedToWait = true;
   }

   action.final_decision_after_irrew_dev = CouncilDecisionToText(runtime.final_decision);
   runtime.irrew_development = action;

   if(changedToWait)
   {
      runtime.summary = "IRREW development WAIT | " + runtime.summary;
      runtime.detailed_reason +=
         " | irrew_dev_wait_primary=" + action.primary_development_wait_reason +
         " | irrew_dev_wait_all=" + action.irrew_development_wait_reasons_all;
   }
}

void OL_ComputeEventOrderTrace(OL_EventOrderTrace &eot)
{
   OL_InitEventOrderTrace(eot);
   eot.playbook_state_timestamp     = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   eot.pre_decision_available       = false;
   eot.late_evidence                = false;
   eot.event_order_valid            = false;
   eot.event_order_violation_reason = "POST_DECISION_SHADOW_ASSEMBLY";
}

void OL_ApplyPlaybookTimingFlags(OL_PlaybookShadowState &pss, const OL_EventOrderTrace &eot)
{
   pss.pre_decision_available = eot.pre_decision_available;
   pss.late_evidence          = eot.late_evidence;
   if(StringLen(pss.attribution_note) <= 0)
      pss.attribution_note = "V1C_POST_DECISION_SHADOW_NO_RUNTIME_AUTHORITY";
}

void OL_ComputePlaybookShadowStates(
   CouncilStrategyReport       &reports[],
   int                          reportCount,
   const CouncilRuntimeResult  &runtime,
   const OL_EventOrderTrace    &eot,
   OL_PlaybookShadowState      &rbsr,
   OL_PlaybookShadowState      &tpc,
   OL_PlaybookShadowState      &vcr,
   OL_PlaybookShadowState      &ifr
)
{
   OL_InitPlaybookShadowState(rbsr, "RANGE_BOUNDARY_SWEEP_RECLAIM");
   OL_InitPlaybookShadowState(tpc,  "TREND_PULLBACK_CONTINUATION");
   OL_InitPlaybookShadowState(vcr,  "VOLATILITY_COMPRESSION_RELEASE");
   OL_InitPlaybookShadowState(ifr,  "IMBALANCE_FILL_REVERSAL");

   bool rbsr_anchor  = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "sweep_reversal");
   bool rbsr_reclaim = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "bollinger_reclaim");
   bool rbsr_mfi     = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "mfi_reversal_assist");
   bool rbsr_range   = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "range_edge_fade");
   bool rbsr_mrb     = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "mean_reversion_bounce");
   bool rbsr_fbr     = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "fake_break_reversal");
   bool rbsr_any     = (rbsr_anchor || rbsr_reclaim || rbsr_mfi || rbsr_range || rbsr_mrb || rbsr_fbr);
   string rbsr_anchor_dir = OL_FirstStrategyDirection(reports, reportCount, "sweep_reversal");
   bool rbsr_failure = false;
   if(StringLen(rbsr_anchor_dir) > 0 && rbsr_mfi)
   {
      string opposite = (rbsr_anchor_dir == "BUY") ? "SELL" : "BUY";
      rbsr_failure = OL_StrategyIdSupportsDirection(reports, reportCount, "mfi_reversal_assist", opposite);
   }

   rbsr.primary_packet_id = OL_FirstPresentStrategy(reports, reportCount,
                                                    "sweep_reversal",
                                                    "bollinger_reclaim",
                                                    "range_edge_fade",
                                                    "mfi_reversal_assist",
                                                    "mean_reversion_bounce");
   if(StringLen(rbsr.primary_packet_id) == 0 && rbsr_fbr)
      rbsr.primary_packet_id = "fake_break_reversal";
   if(!rbsr_any)
   {
      rbsr.playbook_state          = "PLAYBOOK_NOT_PRESENT";
      rbsr.missing_links_json      = OL_LinkJson("RBSR_ALPHA_SWEEP", "RBSR_RECLAIM_CONFIRM", "", "", "");
      rbsr.state_reason            = "NO_RBSR_PACKET_EVIDENCE";
      rbsr.attribution_note        = "RBSR packets absent from ACTIVE/REDUCED triggered-or-voting reports";
   }
   else if(rbsr_failure)
   {
      rbsr.playbook_state          = "PLAYBOOK_CONTRADICTED";
      rbsr.completed_links_json    = OL_LinkJson(rbsr_anchor ? "RBSR_ALPHA_SWEEP" : "",
                                                 (rbsr_reclaim || rbsr_range) ? "RBSR_RECLAIM_CONFIRM" : "",
                                                 (rbsr_mrb || rbsr_fbr) ? "RBSR_SECONDARY_RECLAIM_EVIDENCE" : "",
                                                 "", "");
      rbsr.missing_links_json      = OL_LinkJson(!rbsr_anchor ? "RBSR_ALPHA_SWEEP" : "",
                                                 (!(rbsr_reclaim || rbsr_range || rbsr_mrb || rbsr_fbr)) ? "RBSR_RECLAIM_CONFIRM" : "",
                                                 "PRE_DECISION_EVENT_ORDER", "", "");
      rbsr.contradicted_links_json = OL_LinkJson("RBSR_MFI_COUNTER_DIRECTION", "", "", "", "");
      rbsr.failure_mode_present    = true;
      rbsr.failure_mode_type       = "MFI_COUNTER_DIRECTION";
      rbsr.supporting_evidence_present = (rbsr_reclaim || rbsr_range || rbsr_mrb || rbsr_fbr);
      rbsr.optional_evidence_present   = rbsr_mfi;
      rbsr.state_reason            = "RBSR_FAILURE_MODE_PRESENT";
      rbsr.attribution_note        = "Contradiction is categorical only; no block or score effect";
   }
   else
   {
      rbsr.playbook_state          = "PLAYBOOK_FORMING";
      rbsr.completed_links_json    = OL_LinkJson(rbsr_anchor ? "RBSR_ALPHA_SWEEP" : "",
                                                 rbsr_reclaim ? "RBSR_BOLLINGER_RECLAIM" : "",
                                                 rbsr_range ? "RBSR_RANGE_EDGE_FADE" : "",
                                                 rbsr_mfi ? "RBSR_MFI_CONTEXT" : "",
                                                 (rbsr_mrb || rbsr_fbr) ? "RBSR_SECONDARY_RECLAIM_EVIDENCE" : "");
      rbsr.missing_links_json      = OL_LinkJson(!rbsr_anchor ? "RBSR_ALPHA_SWEEP" : "",
                                                 (!(rbsr_reclaim || rbsr_range || rbsr_mrb || rbsr_fbr)) ? "RBSR_RECLAIM_CONFIRM" : "",
                                                 "PRE_DECISION_EVENT_ORDER",
                                                 "FORMAL_CONFIRMATION_PACKET",
                                                 "");
      rbsr.supporting_evidence_present = (rbsr_reclaim || rbsr_range || rbsr_mrb || rbsr_fbr);
      rbsr.optional_evidence_present   = rbsr_mfi;
      rbsr.state_reason            = "RBSR_CATEGORICAL_FORMING_ONLY";
      rbsr.attribution_note        = "VALID state withheld: required pre-decision links and formal confirmation are not proven";
   }

   bool tpc_anchor    = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "trend_momentum");
   bool tpc_sparse    = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "trend_pullback_cont_v1");
   bool tpc_bdm       = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "breakdown_momentum_v1");
   bool tpc_lhr       = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "lower_high_rejection_v1");
   bool tpc_msr       = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "micro_structure_reentry_v1");
   bool tpc_any       = (tpc_anchor || tpc_sparse || tpc_bdm || tpc_lhr || tpc_msr);
   bool tpc_failure   = (runtime.aggregate.exhaustion_warning && tpc_anchor);

   tpc.primary_packet_id = OL_FirstPresentStrategy(reports, reportCount,
                                                   "trend_momentum",
                                                   "trend_pullback_cont_v1",
                                                   "lower_high_rejection_v1",
                                                   "micro_structure_reentry_v1",
                                                   "breakdown_momentum_v1");
   if(!tpc_any)
   {
      tpc.playbook_state          = "PLAYBOOK_NOT_PRESENT";
      tpc.missing_links_json      = OL_LinkJson("TPC_TREND_CONTEXT", "TPC_PULLBACK_OR_REENTRY_CONFIRM", "", "", "");
      tpc.state_reason            = "NO_TPC_PACKET_EVIDENCE";
      tpc.attribution_note        = "TPC packets absent from ACTIVE/REDUCED triggered-or-voting reports";
   }
   else if(tpc_failure)
   {
      tpc.playbook_state          = "PLAYBOOK_CONTRADICTED";
      tpc.completed_links_json    = OL_LinkJson(tpc_anchor ? "TPC_TREND_CONTEXT" : "",
                                                (tpc_sparse || tpc_bdm || tpc_lhr || tpc_msr) ? "TPC_CONFIRM_OR_REENTRY" : "",
                                                "", "", "");
      tpc.missing_links_json      = OL_LinkJson("PRE_DECISION_EVENT_ORDER", "FORMAL_CONFIRMATION_PACKET", "", "", "");
      tpc.contradicted_links_json = OL_LinkJson("TPC_EXHAUSTION_WARNING", "", "", "", "");
      tpc.failure_mode_present    = true;
      tpc.failure_mode_type       = "EXHAUSTION_WARNING";
      tpc.supporting_evidence_present = (tpc_sparse || tpc_bdm || tpc_lhr || tpc_msr);
      tpc.optional_evidence_present   = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "mfi_reversal_assist");
      tpc.state_reason            = "TPC_FAILURE_MODE_PRESENT";
      tpc.attribution_note        = "Exhaustion warning is recorded only as categorical shadow evidence";
   }
   else
   {
      tpc.playbook_state          = "PLAYBOOK_FORMING";
      tpc.completed_links_json    = OL_LinkJson(tpc_anchor ? "TPC_TREND_CONTEXT" : "",
                                                tpc_sparse ? "TPC_SPARSE_CONFIRM" : "",
                                                tpc_lhr ? "TPC_LOWER_HIGH_REJECTION" : "",
                                                tpc_msr ? "TPC_MICRO_STRUCTURE_REENTRY" : "",
                                                tpc_bdm ? "TPC_BREAKDOWN_MOMENTUM" : "");
      tpc.missing_links_json      = OL_LinkJson(!tpc_anchor ? "TPC_TREND_CONTEXT" : "",
                                                (!(tpc_sparse || tpc_bdm || tpc_lhr || tpc_msr)) ? "TPC_PULLBACK_OR_REENTRY_CONFIRM" : "",
                                                "PRE_DECISION_EVENT_ORDER",
                                                "FORMAL_CONFIRMATION_PACKET",
                                                "");
      tpc.supporting_evidence_present = (tpc_sparse || tpc_bdm || tpc_lhr || tpc_msr);
      tpc.optional_evidence_present   = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "mfi_reversal_assist");
      tpc.state_reason            = "TPC_CATEGORICAL_FORMING_ONLY";
      tpc.attribution_note        = "VALID state withheld: TPC confirmation remains sparse/architectural evidence only";
   }

   bool vcr_anchor = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "range_compression_breakout");
   bool vcr_sqz    = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "volatility_squeeze_release");
   bool vcr_vol    = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "volatility_breakout");
   bool vcr_exp    = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "expansion_continuation");
   bool vcr_micro  = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "micro_range_expansion");
   bool vcr_any    = (vcr_anchor || vcr_sqz || vcr_vol || vcr_exp || vcr_micro);

   vcr.primary_packet_id = OL_FirstPresentStrategy(reports, reportCount,
                                                   "range_compression_breakout",
                                                   "volatility_squeeze_release",
                                                   "volatility_breakout",
                                                   "expansion_continuation",
                                                   "micro_range_expansion");
   if(!vcr_any)
   {
      vcr.playbook_state          = "PLAYBOOK_NOT_PRESENT";
      vcr.missing_links_json      = OL_LinkJson("VCR_COMPRESSION_CONTEXT", "VCR_RELEASE_CONFIRM", "", "", "");
      vcr.state_reason            = "NO_VCR_PACKET_EVIDENCE";
      vcr.attribution_note        = "VCR packets absent from ACTIVE/REDUCED triggered-or-voting reports";
   }
   else
   {
      vcr.playbook_state          = "PLAYBOOK_FORMING";
      vcr.completed_links_json    = OL_LinkJson(vcr_anchor ? "VCR_COMPRESSION_CONTEXT" : "",
                                                vcr_sqz ? "VCR_SQUEEZE_RELEASE" : "",
                                                vcr_vol ? "VCR_VOLATILITY_BREAKOUT" : "",
                                                vcr_exp ? "VCR_EXPANSION_CONTINUATION" : "",
                                                vcr_micro ? "VCR_MICRO_RANGE_EXPANSION" : "");
      vcr.missing_links_json      = OL_LinkJson(!vcr_anchor ? "VCR_COMPRESSION_CONTEXT" : "",
                                                (!(vcr_sqz || vcr_vol || vcr_exp || vcr_micro)) ? "VCR_RELEASE_CONFIRM" : "",
                                                "PRE_DECISION_EVENT_ORDER",
                                                "FORMAL_CONFIRMATION_PACKET",
                                                "");
      vcr.supporting_evidence_present = (vcr_sqz || vcr_vol || vcr_exp || vcr_micro);
      vcr.state_reason            = "VCR_CATEGORICAL_FORMING_ONLY";
      vcr.attribution_note        = "VALID state withheld: VCR is data-insufficient shadow architecture evidence";
   }

   OL_ApplyPlaybookTimingFlags(rbsr, eot);
   OL_ApplyPlaybookTimingFlags(tpc,  eot);
   OL_ApplyPlaybookTimingFlags(vcr,  eot);

   // IFR — IMBALANCE_FILL_REVERSAL shadow state
   // fvg_tpb is the sole IFR anchor strategy (ALPHA_TRIGGER, operator-admitted).
   // IFR state is FORMING when fvg_tpb triggers; NOT_PRESENT otherwise.
   // VALID is withheld: no pre-decision event-order proof and no CONFIRMATION_PACKET yet.
   bool ifr_anchor = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "fvg_tpb");
   int ifr_idx = OL_FindStrategyReportIndex(reports, reportCount, "fvg_tpb");
   if(!ifr_anchor && ifr_idx >= 0 && OL_FVGAttributionRecordAvailable(reports[ifr_idx]))
      ifr_anchor = true;

   ifr.primary_packet_id = ifr_anchor ? "fvg_tpb" : "";

   if(!ifr_anchor)
   {
      ifr.playbook_state          = "PLAYBOOK_NOT_PRESENT";
      ifr.missing_links_json      = OL_LinkJson("IFR_ALPHA_ANCHOR", "IFR_FILL_CONFIRM", "", "", "");
      ifr.state_reason            = "NO_IFR_ANCHOR_EVIDENCE";
      ifr.attribution_note        = "IFR anchor (fvg_tpb) not triggered or voting this bar";
   }
   else
   {
      ifr.playbook_state          = "PLAYBOOK_FORMING";
      ifr.completed_links_json    = OL_LinkJson("IFR_ALPHA_ANCHOR", "", "", "", "");
      ifr.missing_links_json      = OL_LinkJson("", "IFR_FILL_CONFIRM", "PRE_DECISION_EVENT_ORDER",
                                                "FORMAL_CONFIRMATION_PACKET", "");
      ifr.required_evidence_present   = true;  // alpha anchor present
      ifr.supporting_evidence_present = false; // no confirmation chain yet
      ifr.state_reason            = "IFR_ALPHA_ONLY_FORMING";
      ifr.attribution_note        = "VALID withheld: IFR confirmation chain not established; fvg_tpb anchor present";
   }
   OL_ApplyPlaybookTimingFlags(ifr, eot);
}

void OL_CopyPlaybookShadowState(const OL_PlaybookShadowState &src, OL_PlaybookShadowState &dst)
{
   dst.playbook_id                 = src.playbook_id;
   dst.playbook_state              = src.playbook_state;
   dst.primary_packet_id           = src.primary_packet_id;
   dst.completed_links_json        = src.completed_links_json;
   dst.missing_links_json          = src.missing_links_json;
   dst.contradicted_links_json     = src.contradicted_links_json;
   dst.failure_mode_present        = src.failure_mode_present;
   dst.failure_mode_type           = src.failure_mode_type;
   dst.required_evidence_present   = src.required_evidence_present;
   dst.supporting_evidence_present = src.supporting_evidence_present;
   dst.optional_evidence_present   = src.optional_evidence_present;
   dst.room_state                  = src.room_state;
   dst.stop_geometry_state         = src.stop_geometry_state;
   dst.pre_decision_available      = src.pre_decision_available;
   dst.late_evidence               = src.late_evidence;
   dst.attribution_note            = src.attribution_note;
   dst.state_reason                = src.state_reason;
}

void OL_SelectPlaybookStateForStrategy(
   const string                    strategy_id,
   const OL_PlaybookShadowState   &rbsr,
   const OL_PlaybookShadowState   &tpc,
   const OL_PlaybookShadowState   &vcr,
   const OL_PlaybookShadowState   &ifr,
   OL_PlaybookShadowState         &out_state
)
{
   string mapped = OL_PrimaryPlaybookForStrategy(strategy_id);
   if(mapped == rbsr.playbook_id)
   {
      OL_CopyPlaybookShadowState(rbsr, out_state);
      return;
   }
   if(mapped == tpc.playbook_id)
   {
      OL_CopyPlaybookShadowState(tpc, out_state);
      return;
   }
   if(mapped == vcr.playbook_id)
   {
      OL_CopyPlaybookShadowState(vcr, out_state);
      return;
   }
   if(mapped == ifr.playbook_id)
   {
      OL_CopyPlaybookShadowState(ifr, out_state);
      return;
   }

   OL_InitPlaybookShadowState(out_state, "PLAYBOOK_ASSIGNMENT_UNVERIFIED");
   out_state.primary_packet_id       = strategy_id;
   out_state.attribution_note        = "Strategy has no verified V1C primary playbook assignment";
   out_state.state_reason            = "PLAYBOOK_ASSIGNMENT_UNVERIFIED";
}

void OL_ResetPlaybookSummaryCounters()
{
   g_ol_rbsr_state_seen_count                 = 0;
   g_ol_tpc_state_seen_count                  = 0;
   g_ol_vcr_state_seen_count                  = 0;
   g_ol_ifr_state_seen_count                  = 0;
   g_ol_late_evidence_seen_count              = 0;
   g_ol_event_order_invalid_seen_count        = 0;
   g_ol_registry_unknown_strategy_seen_count  = 0;
}

void OL_UpdatePlaybookSummaryCounters(
   const OL_PlaybookShadowState  &pss,
   const OL_EventOrderTrace      &eot,
   const string                   strategy_id
)
{
   if(pss.playbook_id == "RANGE_BOUNDARY_SWEEP_RECLAIM")
      g_ol_rbsr_state_seen_count++;
   else if(pss.playbook_id == "TREND_PULLBACK_CONTINUATION")
      g_ol_tpc_state_seen_count++;
   else if(pss.playbook_id == "VOLATILITY_COMPRESSION_RELEASE")
      g_ol_vcr_state_seen_count++;
   else if(pss.playbook_id == "IMBALANCE_FILL_REVERSAL")
      g_ol_ifr_state_seen_count++;

   if(eot.late_evidence)
      g_ol_late_evidence_seen_count++;
   if(!eot.event_order_valid)
      g_ol_event_order_invalid_seen_count++;
   if(OL_PacketRegistryStatusForStrategy(strategy_id) == "UNKNOWN")
      g_ol_registry_unknown_strategy_seen_count++;
}

bool WriteOpportunityLedgerRecord(
   string                         filePath,
   const CouncilStrategyReport   &report,
   const CouncilRuntimeResult    &runtime,
   StrategyOpportunityCounter    &counter,
   const OL_CrossFamilyEvidence  &cfe,
   const OL_PlaybookShadowState  &pss,
   const OL_EventOrderTrace      &eot
)
{
   // Deduplication: one record per strategy per M1 bar
   string current_bar_str = TimeToString(iTime(_Symbol, PERIOD_M1, 0),
                                          TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   if(counter.last_written_bar_time == current_bar_str)
      return false;

   string ts         = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   string structGate = runtime.pre_ai_gate.structural_reject_gate;
   bool   dsn_b      = (structGate == "DIVERSITY_SAFETY_NET");
   bool   crr_b      = (structGate == "CONFIRM_ROLE_REQUIRED");
   bool   ntr_b      = (structGate == "NO_TRADE_ZONE" ||
                         structGate == "ENVIRONMENT_HARD_CONDITION");
   string packetStatus             = OL_PacketRegistryStatusForStrategy(report.strategy_id);
   string primaryPlaybookCandidate = OL_PrimaryPlaybookForStrategy(report.strategy_id);
   bool   ledgerPreDecision        = (pss.pre_decision_available && eot.pre_decision_available);
   bool   ledgerLateEvidence       = (pss.late_evidence || eot.late_evidence);
   CouncilPacketRegistryConsumptionReport packetAudit;
   CouncilPlaybookConsumptionReport playbookAudit;
   IRREW_BuildPacketRegistryConsumption(report.strategy_id, packetAudit);
   IRREW_BuildPlaybookConsumption(report.strategy_id, pss.playbook_state, playbookAudit);

   string j = "{";
   j += "\"ts\":\"" + OpportunityJsonEscape(ts) + "\",";
   j += "\"bar_time\":\"" + OpportunityJsonEscape(current_bar_str) + "\",";
   j += "\"symbol\":\"" + OpportunityJsonEscape(_Symbol) + "\",";
   j += "\"record_version\":\"OL_V1C_IRREW_DEV_V1\",";
   j += "\"nr7_shadow_state\":\"" + OpportunityJsonEscape(runtime.env.nr7_shadow_state) + "\",";
   j += "\"zone\":\"" + OpportunityJsonEscape(runtime.env.zone_name) + "\",";
   j += "\"zone_type_int\":" + IntegerToString((int)runtime.env.zone_type) + ",";
   j += "\"zone_confidence\":" + DoubleToString(runtime.env.zone_confidence, 4) + ",";
   j += "\"regime_label\":\"" + OpportunityJsonEscape(runtime.env.era_label_v1) + "\",";
   j += "\"era_label\":\"" + OpportunityJsonEscape(runtime.env.era_label_v1) + "\",";
   j += "\"environment_score\":" + DoubleToString(runtime.env.total_score, 4) + ",";
   j += "\"ceis_score\":" + DoubleToString(runtime.env.ceis_source_score, 4) + ",";
   j += "\"ceis_signal_count\":" + IntegerToString(runtime.env.ceis_signal_count) + ",";
   j += "\"exhaustion_warning\":" + (runtime.aggregate.exhaustion_warning ? "true" : "false") + ",";
   j += "\"strategy_id\":\"" + OpportunityJsonEscape(report.strategy_id) + "\",";
   j += "\"strategy_family\":\"" + OpportunityJsonEscape(report.strategy_family) + "\",";
   j += "\"current_role\":\"" + OpportunityJsonEscape(report.role_name) + "\",";
   j += "\"eligibility_state\":\"" + OpportunityJsonEscape(report.eligibility_text) + "\",";
   j += "\"direction_bias\":\"" + OpportunityJsonEscape(report.direction_bias) + "\",";
   j += "\"valid_context_present\":" +
        ((runtime.env.valid && runtime.env.tradable) ? "true" : "false") + ",";
   j += "\"setup_present\":" +
        ((report.confidence > 0.0 || report.score_final > 0.0) ? "true" : "false") + ",";
   j += "\"trigger_present\":" + (report.trigger_present ? "true" : "false") + ",";
   j += "\"direction\":\"" + OpportunityJsonEscape(CouncilDecisionToText(report.decision)) + "\",";
   j += "\"direction_allowed\":" + (!report.counter_trend ? "true" : "false") + ",";
   j += "\"regime_allowed\":" + (!report.blocked_by_zone ? "true" : "false") + ",";
   j += "\"counter_trend\":" + (report.counter_trend ? "true" : "false") + ",";
   j += "\"confidence_score\":" + DoubleToString(report.confidence, 4) + ",";
   j += "\"trigger_quality\":" + DoubleToString(report.trigger_quality, 4) + ",";
   j += "\"confirmation_quality\":" + DoubleToString(report.confirmation_quality, 4) + ",";
   j += "\"score_final\":" + DoubleToString(report.score_final, 4) + ",";
   j += "\"baseline_weight\":" + DoubleToString(report.vote_weight, 4) + ",";
   j += "\"applied_weight\":" + DoubleToString(report.vote_weight, 4) + ",";
   j += "\"zone_alignment_score\":" + DoubleToString(report.zone_alignment_score, 4) + ",";
   j += "\"consensus_type\":\"" +
        OpportunityJsonEscape(CouncilConsensusTypeToText(runtime.aggregate.consensus_type)) + "\",";
   j += "\"consensus_strength\":" + DoubleToString(runtime.aggregate.consensus_strength, 4) + ",";
   j += "\"conflict_score\":" + DoubleToString(runtime.aggregate.conflict_score, 4) + ",";
   j += "\"council_quality\":" + DoubleToString(runtime.aggregate.council_quality, 4) + ",";
   j += "\"family_diversity_score\":" +
        DoubleToString(runtime.aggregate.family_diversity_score, 4) + ",";
   j += "\"dominant_side\":\"" +
        OpportunityJsonEscape(runtime.aggregate.dominant_side) + "\",";
   j += "\"active_strategies_count\":" +
        IntegerToString(runtime.aggregate.active_strategies) + ",";
   j += "\"confirm_role_present\":" +
        (runtime.aggregate.confirm_role_present ? "true" : "false") + ",";
   j += "\"dsn_blocked\":" + (dsn_b ? "true" : "false") + ",";
   j += "\"crr_blocked\":" + (crr_b ? "true" : "false") + ",";
   j += "\"no_trade_blocked\":" + (ntr_b ? "true" : "false") + ",";
   j += "\"quality_soft_gated\":false,";
   j += "\"pre_ai_would_have_gated_quality\":" +
        (runtime.pre_ai_gate.pre_ai_would_have_gated_quality ? "true" : "false") + ",";
   j += "\"pre_ai_would_have_gated_consensus\":" +
        (runtime.pre_ai_gate.pre_ai_would_have_gated_consensus ? "true" : "false") + ",";
   j += "\"pre_ai_would_have_gated_conflict\":" +
        (runtime.pre_ai_gate.pre_ai_would_have_gated_conflict ? "true" : "false") + ",";
   j += "\"suppression_reason\":\"" + OpportunityJsonEscape(structGate) + "\",";
   j += "\"structural_gate_detail\":\"" +
        OpportunityJsonEscape(runtime.pre_ai_gate.structural_reject_gate_detail) + "\",";
   j += "\"central_decision\":\"" +
        OpportunityJsonEscape(CouncilDecisionToText(runtime.final_decision)) + "\",";
   j += "\"filter_passed\":" + (runtime.pre_ai_gate.passed ? "true" : "false") + ",";
   j += "\"actual_trade\":false,";
   j += "\"ticket_id\":-1,";
   j += "\"entry_price\":0.0,";
   j += "\"exit_price\":0.0,";
   j += "\"result\":\"\",";
   j += "\"mae_pts\":-1.0,";
   j += "\"mfe_pts\":-1.0,";
   j += "\"sl_tp_reason\":\"\",";
   j += "\"post_trade_attribution\":\"\",";
   j += "\"nautilus_agrees\":null,";
   j += "\"nautilus_note\":\"\",";
   // Phase 4A-i: Cross-family confirmation evidence (attribution only — no decision authority)
   j += "\"primary_executor_id\":\"" + OpportunityJsonEscape(cfe.primary_executor_id) + "\",";
   j += "\"primary_executor_family\":\"" + OpportunityJsonEscape(cfe.primary_executor_family) + "\",";
   j += "\"same_family_confirm_present\":" + (cfe.same_family_confirm_present ? "true" : "false") + ",";
   j += "\"cross_family_confirm_present\":" + (cfe.cross_family_confirm_present ? "true" : "false") + ",";
   j += "\"cross_family_confirm_strategy_id\":\"" + OpportunityJsonEscape(cfe.cross_family_confirm_strategy_id) + "\",";
   j += "\"cross_family_confirm_family\":\"" + OpportunityJsonEscape(cfe.cross_family_confirm_family) + "\",";
   j += "\"confirm_structure_type\":\"" + OpportunityJsonEscape(cfe.confirm_structure_type) + "\",";
   j += "\"confirm_family_count\":" + IntegerToString(cfe.confirm_family_count) + ",";
   j += "\"confirm_strategy_count\":" + IntegerToString(cfe.confirm_strategy_count) + ",";
   // V1C playbook architecture shadow fields (write-only attribution)
   j += "\"playbook_id\":\"" + OpportunityJsonEscape(pss.playbook_id) + "\",";
   j += "\"playbook_state\":\"" + OpportunityJsonEscape(pss.playbook_state) + "\",";
   j += "\"primary_packet_id\":\"" + OpportunityJsonEscape(pss.primary_packet_id) + "\",";
   j += "\"packet_registry_status\":\"" + OpportunityJsonEscape(packetStatus) + "\",";
   j += "\"primary_playbook_candidate\":\"" + OpportunityJsonEscape(primaryPlaybookCandidate) + "\",";
   j += "\"runtime_authority_status\":\"" + OpportunityJsonEscape(OL_RuntimeAuthorityStatus()) + "\",";
   j += "\"irrew_schema_version\":\"" + OpportunityJsonEscape(runtime.irrew_development.irrew_schema_version) + "\",";
   j += "\"primary_thesis_strategy_id\":\"" + OpportunityJsonEscape(runtime.execution_admission.primary_thesis_strategy_id) + "\",";
   j += "\"execution_admission_family\":\"" + OpportunityJsonEscape(runtime.execution_admission.execution_admission_family) + "\",";
   j += "\"execution_admission_source\":\"" + OpportunityJsonEscape(runtime.execution_admission.execution_admission_source) + "\",";
   j += "\"execution_admission_reason\":\"" + OpportunityJsonEscape(runtime.execution_admission.execution_admission_reason) + "\",";
   j += "\"packet_class\":\"" + OpportunityJsonEscape(packetAudit.packet_class) + "\",";
   j += "\"packet_identity_state\":\"" + OpportunityJsonEscape(packetAudit.packet_identity_state) + "\",";
   j += "\"packet_registry_status_irrew\":\"" + OpportunityJsonEscape(packetAudit.packet_registry_status) + "\",";
   j += "\"playbook_consumption_id\":\"" + OpportunityJsonEscape(playbookAudit.playbook_id) + "\",";
   j += "\"playbook_consumption_state\":\"" + OpportunityJsonEscape(playbookAudit.playbook_state) + "\",";
   j += "\"playbook_thesis_complete\":" + (playbookAudit.playbook_thesis_complete ? "true" : "false") + ",";
   j += "\"thesis_quality_state\":\"" + OpportunityJsonEscape(runtime.irrew_development.thesis_quality_state) + "\",";
   j += "\"irrew_failure_mode_present\":" + (runtime.irrew_development.failure_mode_present ? "true" : "false") + ",";
   j += "\"irrew_failure_mode_type\":\"" + OpportunityJsonEscape(runtime.irrew_development.failure_mode_type) + "\",";
   j += "\"failure_packet_id\":\"" + OpportunityJsonEscape(runtime.irrew_development.failure_packet_id) + "\",";
   j += "\"failure_mode_direction\":\"" + OpportunityJsonEscape(runtime.irrew_development.failure_mode_direction) + "\",";
   j += "\"irrew_pre_decision_available\":" + (runtime.irrew_development.pre_decision_available ? "true" : "false") + ",";
   j += "\"failure_mode_action_candidate\":\"" + OpportunityJsonEscape(runtime.irrew_development.failure_mode_action_candidate) + "\",";
   j += "\"irrew_master_dev_enabled\":" + (IRREW_MasterDevEnabled(EnableIRREWDevelopmentConsumption) ? "true" : "false") + ",";
   j += "\"irrew_phase4a_dev_active\":" + (IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPhase4ADev) ? "true" : "false") + ",";
   j += "\"irrew_phase4b_dev_active\":" + (IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPhase4BDev) ? "true" : "false") + ",";
   j += "\"irrew_phase4c_dev_active\":" + (IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPhase4CDev) ? "true" : "false") + ",";
   j += "\"irrew_rcem_dev_active\":" + (IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWRCEMDev) ? "true" : "false") + ",";
   j += "\"irrew_execution_geometry_dev_active\":" + (IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWExecutionGeometryDev) ? "true" : "false") + ",";
   j += "\"irrew_playbook_advisory_dev_active\":" + (IRREW_SubFlagActive(EnableIRREWDevelopmentConsumption, EnableIRREWPlaybookAdvisoryDev) ? "true" : "false") + ",";
   j += "\"v1_caution_present\":" + (runtime.irrew_development.v1_caution_present ? "true" : "false") + ",";
   j += "\"risk_warning_present\":" + (runtime.irrew_development.risk_warning_present ? "true" : "false") + ",";
   j += "\"advisory_wait_preference\":" + (runtime.irrew_development.advisory_wait_preference ? "true" : "false") + ",";
   j += "\"development_wait_requested\":" + (runtime.irrew_development.development_wait_requested ? "true" : "false") + ",";
   j += "\"baseline_decision_before_irrew_dev\":\"" + OpportunityJsonEscape(runtime.irrew_development.baseline_decision_before_irrew_dev) + "\",";
   j += "\"final_decision_after_irrew_dev\":\"" + OpportunityJsonEscape(runtime.irrew_development.final_decision_after_irrew_dev) + "\",";
   j += "\"irrew_development_wait_reasons_all\":\"" + OpportunityJsonEscape(runtime.irrew_development.irrew_development_wait_reasons_all) + "\",";
   j += "\"primary_development_wait_reason\":\"" + OpportunityJsonEscape(runtime.irrew_development.primary_development_wait_reason) + "\",";
   j += "\"irrew_dev_flag_that_fired\":\"" + OpportunityJsonEscape(runtime.irrew_development.irrew_dev_flag_that_fired) + "\",";
   j += "\"completed_links\":" + pss.completed_links_json + ",";
   j += "\"missing_links\":" + pss.missing_links_json + ",";
   j += "\"contradicted_links\":" + pss.contradicted_links_json + ",";
   j += "\"failure_mode_present\":" + (pss.failure_mode_present ? "true" : "false") + ",";
   j += "\"failure_mode_type\":\"" + OpportunityJsonEscape(pss.failure_mode_type) + "\",";
   j += "\"required_evidence_present\":" + (pss.required_evidence_present ? "true" : "false") + ",";
   j += "\"supporting_evidence_present\":" + (pss.supporting_evidence_present ? "true" : "false") + ",";
   j += "\"optional_evidence_present\":" + (pss.optional_evidence_present ? "true" : "false") + ",";
   j += "\"room_state\":\"" + OpportunityJsonEscape(pss.room_state) + "\",";
   j += "\"stop_geometry_state\":\"" + OpportunityJsonEscape(pss.stop_geometry_state) + "\",";
   j += "\"pre_decision_available\":" + (ledgerPreDecision ? "true" : "false") + ",";
   j += "\"late_evidence\":" + (ledgerLateEvidence ? "true" : "false") + ",";
   j += "\"event_order_valid\":" + (eot.event_order_valid ? "true" : "false") + ",";
   j += "\"event_order_violation_reason\":\"" + OpportunityJsonEscape(eot.event_order_violation_reason) + "\",";
   j += "\"context_timestamp\":\"" + OpportunityJsonEscape(eot.context_timestamp) + "\",";
   j += "\"location_timestamp\":\"" + OpportunityJsonEscape(eot.location_timestamp) + "\",";
   j += "\"trigger_timestamp\":\"" + OpportunityJsonEscape(eot.trigger_timestamp) + "\",";
   j += "\"confirm_timestamp\":\"" + OpportunityJsonEscape(eot.confirm_timestamp) + "\",";
   j += "\"failure_mode_timestamp\":\"" + OpportunityJsonEscape(eot.failure_mode_timestamp) + "\",";
   j += "\"room_timestamp\":\"" + OpportunityJsonEscape(eot.room_timestamp) + "\",";
   j += "\"stop_geometry_timestamp\":\"" + OpportunityJsonEscape(eot.stop_geometry_timestamp) + "\",";
   j += "\"playbook_state_timestamp\":\"" + OpportunityJsonEscape(eot.playbook_state_timestamp) + "\",";
   j += "\"decision_timestamp\":\"" + OpportunityJsonEscape(eot.decision_timestamp) + "\",";
   j += "\"state_reason\":\"" + OpportunityJsonEscape(pss.state_reason) + "\",";
   j += "\"attribution_note\":\"" + OpportunityJsonEscape(pss.attribution_note) + "\"";
   // V1C FVG_TPB attribution fields — write-only; only present for fvg_tpb records
   if(report.strategy_id == "fvg_tpb" && g_fvg_attribution.has_data)
   {
      j += ",\"fvg_direction\":\"" + OpportunityJsonEscape(g_fvg_attribution.fvg_direction) + "\"";
      j += ",\"fvg_gap_low\":" + DoubleToString(g_fvg_attribution.fvg_gap_low, _Digits);
      j += ",\"fvg_gap_high\":" + DoubleToString(g_fvg_attribution.fvg_gap_high, _Digits);
      j += ",\"fvg_regime_context\":\"" + OpportunityJsonEscape(g_fvg_attribution.fvg_regime_context) + "\"";
      j += ",\"fvg_subset_classification\":\"" + OpportunityJsonEscape(g_fvg_attribution.fvg_subset_classification) + "\"";
      j += ",\"fvg_hostile_gate_fired\":" + (g_fvg_attribution.fvg_hostile_gate_fired ? "true" : "false");
      j += ",\"fvg_size_atr\":" + DoubleToString(g_fvg_attribution.fvg_size_atr, 4);
      j += ",\"fvg_age_bars\":" + IntegerToString(g_fvg_attribution.fvg_age_bars);
      j += ",\"fvg_active_zone_count\":" + IntegerToString(g_fvg_attribution.fvg_active_zone_count);
      j += ",\"fvg_mitigation_pct\":" + DoubleToString(g_fvg_attribution.fvg_mitigation_pct, 4);
      j += ",\"ifr_playbook_state\":\"" + OpportunityJsonEscape(pss.playbook_state) + "\"";
   }
   j += "}";

   // Append to JSONL (FILE_READ|FILE_WRITE creates file if absent; does not truncate)
   int h = FileOpen(filePath, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(h == INVALID_HANDLE)
   {
      counter.write_failures++;
      Print("OL_WriteRecord: FileOpen failed: ", filePath, " err=", GetLastError());
      return false;
   }
   FileSeek(h, 0, SEEK_END);
   uint bw = FileWriteString(h, j + "\n");
   FileFlush(h);
   FileClose(h);

   if(bw == 0)
   {
      counter.write_failures++;
      Print("OL_WriteRecord: WriteString returned 0 for strategy=", report.strategy_id);
      return false;
   }

   // Update dedup key only after confirmed successful write
   counter.last_written_bar_time = current_bar_str;
   return true;
}

bool SaveOpportunitySummary(
   string                           filePath,
   StrategyOpportunityCounter       &counters[],
   int                              count
)
{
   string ts = TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);

   string j = "{";
   j += "\"schema_version\":\"OL_SUMMARY_V1C_IRREW_DEV_V1\",";
   j += "\"symbol\":\"" + OpportunityJsonEscape(_Symbol) + "\",";
   j += "\"last_updated\":\"" + OpportunityJsonEscape(ts) + "\",";
   j += "\"unique_m1_bar_count\":" + IntegerToString(g_unique_m1_bar_count) + ",";
   j += "\"total_trigger_writes\":" + IntegerToString(g_total_trigger_writes) + ",";
   j += "\"playbook_architecture_schema\":\"OL_V1C_IRREW_DEV_V1\",";
   j += "\"runtime_authority_status\":\"" + OpportunityJsonEscape(OL_RuntimeAuthorityStatus()) + "\",";
   j += "\"rbsr_state_seen_count\":" + IntegerToString(g_ol_rbsr_state_seen_count) + ",";
   j += "\"tpc_state_seen_count\":" + IntegerToString(g_ol_tpc_state_seen_count) + ",";
   j += "\"vcr_state_seen_count\":" + IntegerToString(g_ol_vcr_state_seen_count) + ",";
   j += "\"ifr_state_seen_count\":" + IntegerToString(g_ol_ifr_state_seen_count) + ",";
   j += "\"late_evidence_seen_count\":" + IntegerToString(g_ol_late_evidence_seen_count) + ",";
   j += "\"event_order_invalid_seen_count\":" + IntegerToString(g_ol_event_order_invalid_seen_count) + ",";
   j += "\"registry_unknown_strategy_seen_count\":" + IntegerToString(g_ol_registry_unknown_strategy_seen_count) + ",";
   j += "\"strategies\":{";

   for(int i = 0; i < count; i++)
   {
      string key = (StringLen(counters[i].strategy_id) > 0)
                   ? counters[i].strategy_id
                   : ("idx_" + IntegerToString(i));
      if(i > 0) j += ",";
      j += "\"" + OpportunityJsonEscape(key) + "\":{";
      j += "\"strategy_id\":\"" + OpportunityJsonEscape(counters[i].strategy_id) + "\",";
      j += "\"strategy_family\":\"" + OpportunityJsonEscape(counters[i].strategy_family) + "\",";
      j += "\"current_role\":\"" + OpportunityJsonEscape(counters[i].current_role) + "\",";
      j += "\"evaluations_seen\":" + IntegerToString(counters[i].evaluations_seen) + ",";
      j += "\"valid_context_seen\":" + IntegerToString(counters[i].valid_context_seen) + ",";
      j += "\"setup_conditions_seen\":" + IntegerToString(counters[i].setup_conditions_seen) + ",";
      j += "\"trigger_seen\":" + IntegerToString(counters[i].trigger_seen) + ",";
      j += "\"trigger_blocked_by_dsn\":" + IntegerToString(counters[i].trigger_blocked_by_dsn) + ",";
      j += "\"trigger_blocked_by_crr\":" + IntegerToString(counters[i].trigger_blocked_by_crr) + ",";
      j += "\"trigger_blocked_by_no_trade\":" + IntegerToString(counters[i].trigger_blocked_by_no_trade) + ",";
      j += "\"trigger_blocked_by_quality_gate\":" + IntegerToString(counters[i].trigger_blocked_by_quality_gate) + ",";
      j += "\"trigger_blocked_by_veto\":" + IntegerToString(counters[i].trigger_blocked_by_veto) + ",";
      j += "\"trigger_blocked_by_direction\":" + IntegerToString(counters[i].trigger_blocked_by_direction) + ",";
      j += "\"trigger_blocked_by_regime\":" + IntegerToString(counters[i].trigger_blocked_by_regime) + ",";
      j += "\"trigger_rejected_by_central_decision\":" + IntegerToString(counters[i].trigger_rejected_by_central_decision) + ",";
      j += "\"trigger_executed\":" + IntegerToString(counters[i].trigger_executed) + ",";
      j += "\"win_count\":" + IntegerToString(counters[i].win_count) + ",";
      j += "\"loss_count\":" + IntegerToString(counters[i].loss_count) + ",";
      j += "\"open_count\":" + IntegerToString(counters[i].open_count) + ",";
      j += "\"sum_mae_pts\":" + DoubleToString(counters[i].sum_mae_pts, 2) + ",";
      j += "\"sum_mfe_pts\":" + DoubleToString(counters[i].sum_mfe_pts, 2) + ",";
      j += "\"mae_count\":" + IntegerToString(counters[i].mae_count) + ",";
      j += "\"mfe_count\":" + IntegerToString(counters[i].mfe_count) + ",";
      j += "\"write_failures\":" + IntegerToString(counters[i].write_failures) + ",";
      j += "\"no_confirm_seen\":" + IntegerToString(counters[i].no_confirm_seen) + ",";
      j += "\"same_family_confirm_seen\":" + IntegerToString(counters[i].same_family_confirm_seen) + ",";
      j += "\"cross_family_confirm_seen\":" + IntegerToString(counters[i].cross_family_confirm_seen) + ",";
      j += "\"multi_family_confirm_seen\":" + IntegerToString(counters[i].multi_family_confirm_seen) + ",";
      j += "\"last_seen_timestamp\":\"" + OpportunityJsonEscape(counters[i].last_seen_timestamp) + "\",";
      j += "\"last_trigger_timestamp\":\"" + OpportunityJsonEscape(counters[i].last_trigger_timestamp) + "\",";
      j += "\"last_written_bar_time\":\"" + OpportunityJsonEscape(counters[i].last_written_bar_time) + "\"";
      j += "}";
   }
   j += "}}";

   int h = FileOpen(filePath, FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(h == INVALID_HANDLE)
   {
      Print("OL_SaveSummary: FileOpen failed: ", filePath, " err=", GetLastError());
      return false;
   }
   uint bw = FileWriteString(h, j);
   FileFlush(h);
   FileClose(h);

   if(bw == 0)
   {
      Print("OL_SaveSummary: WriteString returned 0 for ", filePath);
      return false;
   }
   return true;
}

//---------------------------------------------------------
// Main runtime pipeline
//---------------------------------------------------------
bool RunCouncilModePipeline(
   CouncilRuntimeResult &runtime,
   string feedbackFile,
   string reportFile,
   string memoryFile,
   string &logMessage,
   string decision_id = ""
)
{
   logMessage = "";
   InitCouncilRuntimeResult(runtime);

   //-----------------------------------------------------
   // Build snapshots
   //-----------------------------------------------------
   TimeframeSnapshot m1;
   TimeframeSnapshot m5;

   if(!BuildTimeframeSnapshot(PERIOD_M1, m1))
   {
      logMessage = "Council runtime failed: M1 snapshot failed";
      return false;
   }

   if(!BuildTimeframeSnapshot(PERIOD_M5, m5))
   {
      logMessage = "Council runtime failed: M5 snapshot failed";
      return false;
   }

   //-----------------------------------------------------
   // Local stage objects
   //-----------------------------------------------------
   CouncilEnvironmentReport env;
   CouncilStrategyReport s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18;
   CouncilStrategyReport reports[COUNCIL_MAX_STRATEGIES];
   const int reportCount = ArraySize(reports);
   CouncilAggregateReport agg;
   CouncilPreAIGateReport pre;
   CouncilFeedbackRecord fb;
   CouncilPolicyAdjustment gov;
   CouncilMemorySummary mem;
   CouncilGovernorStateReport govState;
   CouncilFailurePatternReport failDet;

   InitCouncilEnvironmentReport(env);
   InitCouncilStrategyReport(s1);
   InitCouncilStrategyReport(s2);
   InitCouncilStrategyReport(s3);
   InitCouncilStrategyReport(s4);
   InitCouncilStrategyReport(s5);
   InitCouncilStrategyReport(s6);
   InitCouncilStrategyReport(s7);
   InitCouncilStrategyReport(s8);
   InitCouncilStrategyReport(s9);
   InitCouncilStrategyReport(s10);
   InitCouncilStrategyReport(s11);
   InitCouncilStrategyReport(s12);
   InitCouncilAggregateReport(agg);
   InitCouncilPreAIGateReport(pre);
   InitCouncilFeedbackRecord(fb);
   InitCouncilPolicyAdjustment(gov);
   InitCouncilGovernorStateReport(govState);
   InitCouncilFailurePatternReport(failDet);

   //-----------------------------------------------------
   // 1) ENVIRONMENT
   //-----------------------------------------------------
   if(!BuildCouncilEnvironmentReport(m1, m5, env))
   {
      logMessage = "Council runtime failed: environment stage failed";
      return false;
   }

   env.era_label_v1 = gRegime.regime_label;

   runtime.env = env;

   CouncilV1EarlyInfluenceContext v1Early;
   CouncilV1_InitEarlyInfluenceContext(v1Early);
   CouncilV1_ComposeShadowStateEarly(
      "COUNCIL",
      true,
      gRegime.regime_label,
      env.zone_type,
      v1Early
   );

   //-----------------------------------------------------
   // 2) STRATEGIES
   //-----------------------------------------------------
   RunCouncilStrategySet(env, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17, s18);

      reports[0] = s1;
   reports[1] = s2;
   reports[2] = s3;
   reports[3] = s4;
   reports[4] = s5;
   reports[5] = s6;
   reports[6] = s7;
   reports[7] = s8;
   reports[8] = s9;
   reports[9] = s10;
   reports[10] = s11;
   reports[11] = s12;
   reports[12] = s13;
   reports[13] = s14;
   reports[14] = s15;
   reports[15] = s16;
   reports[16] = s17;
   reports[17] = s18;  // fvg_tpb — IMBALANCE_FILL_REVERSAL lane

   CouncilV1ConstructiveEligibilitySummary v1Policy;
   InitCouncilV1ConstructiveEligibilitySummary(v1Policy);
   CouncilV1_ApplyPolicyEligibilityOverride(
      reports,
      reportCount,
      v1Early,
      EnableV1ConstructivePolicyEligibility,
      v1Policy
   );

   //-----------------------------------------------------
   // 3) AGGREGATOR
   //-----------------------------------------------------
   if(!BuildCouncilAggregateReport(
      reports,
      reportCount,
      env,
      v1Early,
      EnableV1LiveInfluencePhase1,
      EnableV1PolicyGuidedParticipation,
      v1Policy,
      agg
   ))
   {
      logMessage = "Council runtime failed: aggregate stage failed";
      return false;
   }

   runtime.aggregate = agg;
   IRREW_ResolveAdmissionIdentity(reports, reportCount, agg, runtime.execution_admission);
   runtime.aggregate.primary_thesis_strategy_id = runtime.execution_admission.primary_thesis_strategy_id;
   runtime.aggregate.execution_admission_family = runtime.execution_admission.execution_admission_family;
   runtime.aggregate.execution_admission_source = runtime.execution_admission.execution_admission_source;
   runtime.aggregate.execution_admission_reason = runtime.execution_admission.execution_admission_reason;
   IRREW_BuildPacketRegistryConsumption(agg.best_strategy_id, runtime.packet_registry);
   IRREW_BuildPlaybookConsumption(agg.best_strategy_id, "PLAYBOOK_NOT_PRESENT", runtime.playbook_consumption);

   //-----------------------------------------------------
   // 3B) ZONE COVERAGE (passive intelligence)
   //-----------------------------------------------------
   BuildZoneCoverageReport(reports, reportCount, env, runtime.zone_coverage);


   //-----------------------------------------------------
   // [3C] MEMORY LOAD — policy input (PLAN-4 Stage 1: moved before filter)
   //-----------------------------------------------------
   string memLog = "";
   if(!BuildCouncilMemorySummaryFromFeedback(feedbackFile, mem, memLog))
   {
      // keep going with empty/default memory state
      memLog = "Council memory unavailable, continuing with empty detector context";
   }

   //-----------------------------------------------------
   // [3D] FAILURE DETECTOR — policy input (PLAN-4 Stage 1: moved before filter)
   //-----------------------------------------------------
   if(!BuildCouncilFailurePatternReport(mem, env, agg, failDet))
   {
      logMessage = "Council runtime failed: failure detector stage failed";
      return false;
   }

   runtime.failure_detector = failDet;

   //-----------------------------------------------------
   // [3E] POLICY LAYER — PRE-FILTER (PLAN-4 Stage 1)
   // Governor produces threshold-adjustment vector for RunCouncilPreAIFilter().
   // Enforcement owner: RunCouncilPreAIFilter() — governor is threshold-input supplier ONLY.
   // Gate sentinel: pre-filter position, valid=true, passed=true (gate not yet evaluated).
   // Three structural gates remain governor-independent: NO_TRADE, diversity, confirm-role.
   //-----------------------------------------------------
   CouncilPreAIGateReport preSentinel;
   InitCouncilPreAIGateReport(preSentinel);
   preSentinel.valid  = true;   // required: governor validity check passes
   preSentinel.passed = true;   // neutral: gate not yet evaluated, prevents spurious GATE_FAILED case

   BuildCouncilGovernorStateReport(env, agg, preSentinel, govState);

   if(!EvaluateCouncilAIGovernor(env, agg, preSentinel, failDet, gov))
   {
      logMessage = "Council runtime failed: governor stage failed";
      return false;
   }

   runtime.governor_state = govState.operating_state_text;
   runtime.governor_state_source = "STAGE_D_CATEGORICAL_GOVERNOR";
   runtime.governor_categorical_state_active = govState.valid;

   //-----------------------------------------------------
   // 4) PRE-AI FILTER (PLAN-4 Stage 1: now receives governor policy adjustment)
   //-----------------------------------------------------
   if(!RunCouncilPreAIFilter(agg, env, gov, runtime.zone_coverage, pre))
   {
      logMessage = "Council runtime failed: pre-AI gate stage failed";
      return false;
   }

   //-----------------------------------------------------
   // Phase B) TREND_CONTINUATION confirmation reinforcement (opt-in, narrow)
   //-----------------------------------------------------
   // [DORMANT_BRANCH: TREND_CONTINUATION_REINFORCEMENT] flag=false; narrow pre-filter rescue call site dormant; confirmation-role rescue path never reached
   if(EnableCouncilTrendContinuationConfirmationReinforcement && !pre.passed && pre.reason == "Confirmation role missing")
   {
      ContinuationConfirmationReinforcementAssessment reinf;
      bool rescued = EvaluateTrendContinuationConfirmationReinforcement(agg, env, pre, reinf);
      SaveTrendContinuationReinforcementStatusBestEffort(reinf);
      if(rescued)
      {
         pre.passed = true;
         pre.filtered_decision = (agg.dominant_side == "BUY") ? COUNCIL_DECISION_BUY : COUNCIL_DECISION_SELL;
         pre.reason = "Council case accepted (trend cont reinforcement)";
         pre.summary = "Pre-AI reinforced pass | zone=" + env.zone_name;
      }
   }

   runtime.pre_ai_gate = pre;
   if(!env.tradable)
   {
      runtime.pre_ai_gate.structural_reject_gate = "ENVIRONMENT_HARD_CONDITION";
      runtime.pre_ai_gate.structural_reject_gate_detail = CouncilEnvironmentHardConditionDetail(env);
      runtime.pre_ai_gate.pre_ai_structural_passed = false;
   }
   runtime.c1_tc_active              = gov.c1_tc_active;
   runtime.c1_high_conviction_active = gov.c1_high_conviction_active;
   runtime.c1_overextension_active   = gov.c1_overextension_active;
   runtime.c1_pre_governor_candidate = gov.c1_pre_governor_candidate;
   runtime.c1_shadowed_by_exhaustion = gov.c1_shadowed_by_exhaustion;
   runtime.c1_shadow_reason          = gov.c1_shadow_reason;

   //-----------------------------------------------------
   // 8) FINAL DECISION
   //-----------------------------------------------------
   runtime.valid = true;

   if(!env.tradable)
   {
      runtime.final_decision  = COUNCIL_DECISION_REJECT;
      runtime.summary         = "Council rejected by environment";
      runtime.detailed_reason =
         env.reject_reason +
         " | zone=" + env.zone_name +
         " | gov_state=" + govState.operating_state_text +
         " | fail_pressure=" + failDet.pressure_label;
   }
   else if(!pre.passed)
   {
      runtime.final_decision  = pre.filtered_decision;
      runtime.summary         = "Council rejected by pre-AI gate";
      runtime.detailed_reason =
         pre.reason +
         " | zone=" + env.zone_name +
         " | consensus=" + agg.consensus_label +
         " | gov_state=" + govState.operating_state_text +
         " | fail_pressure=" + failDet.pressure_label +
         " | governor=" + gov.summary;
   }
   else
   {
      runtime.final_decision = pre.filtered_decision;
      runtime.summary        = agg.summary;
      runtime.detailed_reason =
         "Council pipeline passed"
         " | zone=" + env.zone_name +
         " | pref_style=" + env.preferred_style_text +
         " | best_strategy=" + agg.best_strategy_id +
         " | support=" + agg.support_strategy_ids +
         " | consensus=" + agg.consensus_label +
         " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
         " | gov_state=" + govState.operating_state_text +
         " | fail_pressure=" + failDet.pressure_label +
         " | governor=" + gov.summary;
   }

   
   IRREW_BuildInitialDevelopmentActionReport(
      agg,
      failDet,
      runtime.final_decision,
      runtime.irrew_development
   );
   CouncilIRREWDevelopmentActionReport irrewAction;
   irrewAction = runtime.irrew_development;
   IRREW_EvaluatePhase4ADev(reports, reportCount, agg, env, runtime.final_decision, irrewAction);
   IRREW_EvaluatePhase4BDev(agg, env, failDet, runtime.final_decision, irrewAction);
   IRREW_EvaluatePhase4CDev(agg, failDet, runtime.final_decision, irrewAction);
   IRREW_EvaluateRCEMDev(agg, env, runtime.final_decision, irrewAction);
   IRREW_ApplyDevelopmentWaitProtocol(runtime, irrewAction);

   //-----------------------------------------------------
   // Phase 8A: Attribution provenance (best-effort)
   //-----------------------------------------------------
   CouncilBuildDecisionAttributionV1(
      reports,
      reportCount,
      agg,
      env,
      runtime.final_decision,
      runtime.attribution
   );

//-----------------------------------------------------
   // 9) FEEDBACK SNAPSHOT
   //-----------------------------------------------------
   fb.symbol               = _Symbol;
   fb.plan_id              = "";
   fb.mode_name            = "COUNCIL";
   fb.record_type          = "DECISION_SNAPSHOT";
   fb.decision_id          = decision_id;
   fb.final_decision       = CouncilDecisionToText(runtime.final_decision);
   fb.executed_direction   = "";
   fb.trade_result         = "PENDING";
   fb.profit               = 0.0;

   fb.environment_score    = env.total_score;
   fb.council_quality      = agg.council_quality;
   fb.consensus_strength   = agg.consensus_strength;
   fb.conflict_score       = agg.conflict_score;

   fb.zone_name            = env.zone_name;
   fb.zone_confidence      = env.zone_confidence;
   fb.preferred_style      = env.preferred_style_text;
   fb.governor_state       = govState.operating_state_text;
   fb.consensus_label      = agg.consensus_label;

   fb.best_strategy_id     = agg.best_strategy_id;
   fb.support_strategy_ids = agg.support_strategy_ids;
   fb.regime_summary       = env.regime_summary;
   fb.explanation          = runtime.detailed_reason;

   fb.failure_tag            = failDet.dominant_failure_tag;
   fb.quality_band           =
      (agg.council_quality >= 0.75) ? "HIGH" :
      (agg.council_quality >= 0.55) ? "MEDIUM" : "LOW";
   fb.setup_type             = env.preferred_style_text;
   fb.confirm_role_present   = agg.confirm_role_present;
   fb.trend_judge_supportive = agg.trend_judge_supportive;
   fb.exhaustion_warning     = agg.exhaustion_warning;

   fb.c1_tc_active                 = gov.c1_tc_active;
   fb.c1_high_conviction_active    = gov.c1_high_conviction_active;
   fb.c1_overextension_active      = gov.c1_overextension_active;
   fb.c1_pre_governor_candidate    = gov.c1_pre_governor_candidate;
   fb.c1_shadowed_by_exhaustion    = gov.c1_shadowed_by_exhaustion;
   fb.c1_shadow_reason             = gov.c1_shadow_reason;

   fb.c2_overextension_m5_active   = pre.c2_overextension_m5_active;
   fb.c2_consensus_tightening_applied = pre.c2_consensus_tightening_applied;
   fb.c2_consensus_tightening_delta   = pre.c2_consensus_tightening_delta;
   fb.c2_pre_consensus_requirement    = pre.c2_pre_consensus_requirement;
   fb.c2_post_consensus_requirement   = pre.c2_post_consensus_requirement;
   fb.c2_effective_on_outcome         = pre.c2_effective_on_outcome;
   fb.c2_gate_outcome                 = pre.c2_gate_outcome;

   fb.c3_low_structure_tc_active   = pre.c3_low_structure_tc_active;
   fb.c3_structure_score           = pre.c3_structure_score;
   fb.c3_logic_applied             = pre.c3_logic_applied;
   fb.c3_effective_on_outcome      = pre.c3_effective_on_outcome;
   fb.c3_gate_outcome              = pre.c3_gate_outcome;

   fb.c123_obstacle_semantics_version = CouncilC123ObstacleSemanticsVersion();
   fb.c123_obstacle_summary           = BuildC123ObstacleSummary(gov, pre);

   fb.close_time           = TimeCurrent();

   //-----------------------------------------------------
   // 10) SAVE FEEDBACK
   //-----------------------------------------------------
   string fbLog = "";
   SaveCouncilFeedbackRecord(feedbackFile, fb, fbLog);

   //-----------------------------------------------------
   // 11) REBUILD MEMORY AFTER CURRENT SNAPSHOT SAVE
   //-----------------------------------------------------
   memLog = "";
   BuildCouncilMemorySummaryFromFeedback(feedbackFile, mem, memLog);
   SaveCouncilMemorySummaryText(memoryFile, mem);

   //-----------------------------------------------------
   // 11B) BUILD + SAVE AUDIT SUMMARY (BEST-EFFORT)
   //-----------------------------------------------------
   CouncilAuditSummary audit;
   string auditLog = "";
   if(BuildCouncilAuditSummaryFromFiles(
         feedbackFile,
         "AI\\ai_performance_journal.jsonl",
         500,
         800,
         audit,
         auditLog
      ))
   {
      CouncilMemorySaveTextFile("AI\\council_audit_summary.txt", audit.summary_text);
      CouncilMemorySaveTextFile("AI\\council_audit_summary.json", audit.summary_json);
   }
   else
   {
      if(StringLen(auditLog) > 0)
         logMessage += " | audit: " + auditLog;
   }


   //-----------------------------------------------------
   // 12) TXT REPORT
   //-----------------------------------------------------
   string reportLog = "";
   SaveCouncilSystemReportEx2(reportFile, env, reports, reportCount, agg, pre, failDet, gov, fb, mem, reportLog);

   //-----------------------------------------------------
   // Stage 18.5: OPPORTUNITY LEDGER INSTRUMENTATION
   // OPPORTUNITY_LEDGER_IMPLEMENTATION_V1A_PLUS
   // Write-only. Post-decision. No feedback into pipeline.
   //-----------------------------------------------------
   if(!g_opp_counters_initialized)
   {
      InitOpportunityCounters(g_opportunity_counters, COUNCIL_MAX_STRATEGIES);
      g_unique_m1_bar_count         = 0;
      g_total_trigger_writes        = 0;
      g_last_seen_m1_bar_time       = 0;
      g_last_summary_flush_bar_time = 0;
      g_last_summary_flush_bar_count= 0;
      g_last_trigger_flush_count    = 0;
      OL_ResetPlaybookSummaryCounters();
      g_opp_counters_initialized    = true;
   }

   datetime ol_bar = iTime(_Symbol, PERIOD_M1, 0);
   if(ol_bar != g_last_seen_m1_bar_time)
   {
      g_unique_m1_bar_count++;
      g_last_seen_m1_bar_time = ol_bar;
      if(g_unique_m1_bar_count == 1)
         Print("OL_Stage18_FIRST_BAR: bar=", TimeToString(ol_bar, TIME_DATE|TIME_MINUTES),
               " count=1 total_writes=", g_total_trigger_writes);
   }

   // Phase 4A-i: compute cross-family evidence once per bar (attribution only)
   OL_CrossFamilyEvidence ol_cfe = OL_ComputeCrossFamilyEvidence(reports, reportCount, runtime);

   // V1C: compute playbook architecture shadow state after final_decision is set.
   // Write-only Stage 18.5 instrumentation; no feedback into council runtime.
   OL_EventOrderTrace ol_eot;
   OL_ComputeEventOrderTrace(ol_eot);
   OL_PlaybookShadowState ol_rbsr;
   OL_PlaybookShadowState ol_tpc;
   OL_PlaybookShadowState ol_vcr;
   OL_PlaybookShadowState ol_ifr;
   OL_ComputePlaybookShadowStates(reports, reportCount, runtime, ol_eot, ol_rbsr, ol_tpc, ol_vcr, ol_ifr);

   for(int ol_i = 0; ol_i < reportCount && ol_i < COUNCIL_MAX_STRATEGIES; ol_i++)
   {
      IncrementEvaluationCounter(
         g_opportunity_counters[ol_i],
         reports[ol_i],
         runtime.env,
         runtime.pre_ai_gate,
         runtime.final_decision,
         ol_cfe
      );

      bool ol_fvg_attribution_record = OL_FVGAttributionRecordAvailable(reports[ol_i]);
      if(reports[ol_i].trigger_present || ol_fvg_attribution_record)
      {
         OL_PlaybookShadowState ol_pss;
         OL_SelectPlaybookStateForStrategy(reports[ol_i].strategy_id, ol_rbsr, ol_tpc, ol_vcr, ol_ifr, ol_pss);

         bool ol_wrote = WriteOpportunityLedgerRecord(
            "AI\\ai_opportunity_ledger.jsonl",
            reports[ol_i],
            runtime,
            g_opportunity_counters[ol_i],
            ol_cfe,
            ol_pss,
            ol_eot
         );
         if(ol_wrote)
         {
            g_total_trigger_writes++;
            OL_UpdatePlaybookSummaryCounters(ol_pss, ol_eot, reports[ol_i].strategy_id);
         }
      }
   }

   // OL trigger/event records remain immediate. Only this derived summary is rate-limited.
   bool ol_rate_enabled = (EnableMT5IOReductionV1 && EnableOLSummaryRateLimit);
   int ol_summary_bar_interval = (ol_rate_enabled ? MT5IO_OLSummaryIntervalBars() : 5);
   int ol_summary_record_interval = (ol_rate_enabled ? MT5IO_OLSummaryWriteEveryNRecords() : 50);

   bool ol_flush_periodic = (g_unique_m1_bar_count > 0 &&
                              (g_unique_m1_bar_count == 1 ||
                               (g_unique_m1_bar_count - g_last_summary_flush_bar_count) >= ol_summary_bar_interval) &&
                              ol_bar != g_last_summary_flush_bar_time);
   bool ol_flush_trigger  = (g_total_trigger_writes > 0 &&
                              g_total_trigger_writes % ol_summary_record_interval == 0 &&
                              g_total_trigger_writes != g_last_trigger_flush_count);

   if(ol_flush_periodic || ol_flush_trigger)
   {
      Print("OL_Stage18_FLUSHING: count=", g_unique_m1_bar_count,
            " periodic=", ol_flush_periodic, " trigger=", ol_flush_trigger);
      int ol_count = (reportCount < COUNCIL_MAX_STRATEGIES) ? reportCount : COUNCIL_MAX_STRATEGIES;
      bool ol_ok = SaveOpportunitySummary(
         "AI\\ai_opportunity_summary.json",
         g_opportunity_counters,
         ol_count
      );
      if(ol_ok && ol_flush_periodic)
      {
         g_last_summary_flush_bar_time = ol_bar;
         g_last_summary_flush_bar_count = g_unique_m1_bar_count;
      }
      if(ol_ok && ol_flush_trigger)
         g_last_trigger_flush_count = g_total_trigger_writes;
      if(ol_ok)
      {
         g_mt5io_ol_summary_write_count++;
         g_mt5io_last_ol_summary_write_time = TimeCurrent();
      }
   }
   else if(ol_rate_enabled)
   {
      g_mt5io_ol_summary_deferred_count++;
   }

   //-----------------------------------------------------
   // FINAL LOG
   //-----------------------------------------------------
   logMessage =
      "Council runtime completed"
      " | zone=" + env.zone_name +
      " | style=" + env.preferred_style_text +
      " | gov_state=" + govState.operating_state_text +
      " | fail_pressure=" + failDet.pressure_label +
      " | decision=" + CouncilDecisionToText(runtime.final_decision) +
      " | env_score=" + DoubleToString(env.total_score, 2) +
      " | zone_conf=" + DoubleToString(env.zone_confidence, 2) +
      " | council_quality=" + DoubleToString(agg.council_quality, 2) +
      " | consensus=" + DoubleToString(agg.consensus_strength, 2) +
      " | diversity=" + DoubleToString(agg.family_diversity_score, 2);

   return true;
}

#endif
