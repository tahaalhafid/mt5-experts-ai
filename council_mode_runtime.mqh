#ifndef __COUNCIL_MODE_RUNTIME_MQH__
#define __COUNCIL_MODE_RUNTIME_MQH__

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

//---------------------------------------------------------
// Main runtime pipeline
//---------------------------------------------------------
bool RunCouncilModePipeline(
   CouncilRuntimeResult &runtime,
   string feedbackFile,
   string reportFile,
   string memoryFile,
   string &logMessage
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
   CouncilStrategyReport s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17;
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

   runtime.env = env;

   //-----------------------------------------------------
   // 2) STRATEGIES
   //-----------------------------------------------------
   RunCouncilStrategySet(env, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, s16, s17);

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

   //-----------------------------------------------------
   // 3) AGGREGATOR
   //-----------------------------------------------------
   if(!BuildCouncilAggregateReport(reports, reportCount, env, agg))
   {
      logMessage = "Council runtime failed: aggregate stage failed";
      return false;
   }

   runtime.aggregate = agg;

   //-----------------------------------------------------
   // 3B) ZONE COVERAGE (passive intelligence)
   //-----------------------------------------------------
   BuildZoneCoverageReport(reports, reportCount, env, runtime.zone_coverage);


   //-----------------------------------------------------
   // 4) PRE-AI FILTER
   //-----------------------------------------------------
   if(!RunCouncilPreAIFilter(agg, env, pre))
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

   //-----------------------------------------------------
   // 5) LOAD MEMORY FROM HISTORICAL FEEDBACK
   //-----------------------------------------------------
   string memLog = "";
   if(!BuildCouncilMemorySummaryFromFeedback(feedbackFile, mem, memLog))
   {
      // keep going with empty/default memory state
      memLog = "Council memory unavailable, continuing with empty detector context";
   }

   //-----------------------------------------------------
   // 6) FAILURE DETECTOR
   //-----------------------------------------------------
   if(!BuildCouncilFailurePatternReport(mem, env, agg, failDet))
   {
      logMessage = "Council runtime failed: failure detector stage failed";
      return false;
   }

   runtime.failure_detector = failDet;

   //-----------------------------------------------------
   // 7) GOVERNOR STATE + AI GOVERNOR
   //-----------------------------------------------------
   BuildCouncilGovernorStateReport(env, agg, pre, govState);

   if(!EvaluateCouncilAIGovernor(env, agg, pre, failDet, gov))
   {
      logMessage = "Council runtime failed: governor stage failed";
      return false;
   }

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
   fb.record_type = "DECISION_SNAPSHOT";
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