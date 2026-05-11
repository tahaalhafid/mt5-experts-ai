#ifndef __COUNCIL_FEEDBACK_MQH__
#define __COUNCIL_FEEDBACK_MQH__

#include "config_loader.mqh"
#include "council_mode_types.mqh"

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
string CouncilFeedbackBoolText(bool v)
{
   return (v ? "true" : "false");
}

string CouncilFeedbackEscape(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", "");
   StringReplace(s, "\n", " ");
   StringReplace(s, "\t", " ");
   return s;
}


string CouncilFeedbackU64(ulong v)
{
   return StringFormat("%I64u", v);
}

string CouncilFeedbackQualityBandFromScore(double v)
{
   if(v >= 0.75)
      return "HIGH";

   if(v >= 0.50)
      return "MEDIUM";

   return "LOW";
}

string CouncilFeedbackSetupTypeFromStyle(string preferredStyle)
{
   preferredStyle = TrimString(preferredStyle);

   if(preferredStyle == "REVERSAL")
      return "REVERSAL";

   if(preferredStyle == "CONTINUATION")
      return "CONTINUATION";

   if(preferredStyle == "MEAN_RECLAIM")
      return "MEAN_RECLAIM";

   if(preferredStyle == "BREAKOUT")
      return "BREAKOUT";

   if(preferredStyle == "DEFENSIVE")
      return "DEFENSIVE";

   return "UNSPECIFIED";
}

string CouncilFeedbackInferFailureTag(CouncilFeedbackRecord &r)
{
   string result = TrimString(r.trade_result);

   if(result != "LOSS")
      return "";

   if(r.exhaustion_warning)
      return "EXHAUSTION_IGNORED_FAILURE";

   if(r.conflict_score >= 0.40)
      return "HIGH_CONFLICT_FAILURE";

   if(r.confirm_role_present == false && r.council_quality > 0.0)
      return "NO_CONFIRM_ROLE_FAILURE";

   if(r.council_quality < 0.55)
      return "LOW_QUALITY_ENTRY";

   if(r.zone_confidence < 0.45)
      return "ZONE_MISMATCH_FAILURE";

   if(r.setup_type == "CONTINUATION")
      return "LATE_CONTINUATION_FAILURE";

   if(r.setup_type == "REVERSAL")
      return "WEAK_REVERSAL_FAILURE";

   return "UNCLASSIFIED_FAILURE";
}

//---------------------------------------------------------
// File helpers
//---------------------------------------------------------
bool SaveCouncilTextFile(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

bool AppendCouncilFeedbackJsonObject(string relativePath, string oneObjectJson)
{
   if(StringLen(relativePath) <= 0)
      return true;

   // -----------------------------------------------------------------
   // FAST PATH: O(1) tail-append for normal existing file.
   // Opens in binary mode for byte-precise seek.
   // Verifies the last byte is ] before overwriting it.
   // Falls through to safe path on any edge case or malformed tail.
   // File format confirmed: ends with \r\n] (CRLF, ] at sz-1).
   // -----------------------------------------------------------------
   int hb = FileOpen(relativePath, FILE_READ | FILE_WRITE | FILE_BIN | FILE_ANSI);
   if(hb != INVALID_HANDLE)
   {
      int sz = (int)FileSize(hb);
      if(sz > 5)
      {
         FileSeek(hb, sz - 1, SEEK_SET);
         int lastByte = FileReadInteger(hb, CHAR_VALUE);
         if(lastByte == ']')
         {
            FileSeek(hb, sz - 1, SEEK_SET);
            FileWriteString(hb, ",\r\n" + oneObjectJson + "\r\n]");
            FileClose(hb);
            return true;
         }
      }
      FileClose(hb);
      // Fall through: file missing, empty, too small, or malformed tail.
   }

   // -----------------------------------------------------------------
   // SAFE PATH: full read + rebuild + rewrite.
   // Handles first record, empty file, bare [] array, and malformed tail.
   // -----------------------------------------------------------------
   int h = FileOpen(relativePath, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
   {
      h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(h == INVALID_HANDLE)
         return false;

      FileWriteString(h, "[\n" + oneObjectJson + "\n]");
      FileClose(h);
      return true;
   }

   string oldText = "";
   while(!FileIsEnding(h))
      oldText += FileReadString(h);

   FileClose(h);

   oldText = TrimString(oldText);

   string newText = "";

   if(StringLen(oldText) < 2 || oldText == "[]")
   {
      newText = "[\n" + oneObjectJson + "\n]";
   }
   else
   {
      int endBracket = StringFind(oldText, "]", StringLen(oldText) - 2);
      if(endBracket < 0)
      {
         newText = "[\n" + oneObjectJson + "\n]";
      }
      else
      {
         string prefix = StringSubstr(oldText, 0, endBracket);

         if(StringFind(prefix, "{") >= 0)
            newText = prefix + ",\n" + oneObjectJson + "\n]";
         else
            newText = "[\n" + oneObjectJson + "\n]";
      }
   }

   return SaveCouncilTextFile(relativePath, newText);
}

//---------------------------------------------------------
// Enrichment helper
//---------------------------------------------------------
void FinalizeCouncilFeedbackMemoryFields(CouncilFeedbackRecord &r)
{
   NormalizeCouncilFeedbackRecordSemantics(r);

   if(StringLen(TrimString(r.c123_obstacle_semantics_version)) <= 0)
      r.c123_obstacle_semantics_version = CouncilC123ObstacleSemanticsVersion();

   if(StringLen(TrimString(r.quality_band)) <= 0 && r.council_quality > 0.0)
      r.quality_band = CouncilFeedbackQualityBandFromScore(r.council_quality);

   if(StringLen(TrimString(r.setup_type)) <= 0 &&
      StringLen(TrimString(r.preferred_style)) > 0)
   {
      r.setup_type = CouncilFeedbackSetupTypeFromStyle(r.preferred_style);
   }

   if(StringLen(TrimString(r.failure_tag)) <= 0)
      r.failure_tag = CouncilFeedbackInferFailureTag(r);
}

//---------------------------------------------------------
// Fill helpers
//---------------------------------------------------------
void FillCouncilFeedbackFromEnvironment(
   CouncilEnvironmentReport &env,
   CouncilFeedbackRecord &r
)
{
   r.environment_score = env.total_score;
   r.regime_summary    = env.regime_summary;

   r.zone_name         = env.zone_name;
   r.zone_confidence   = env.zone_confidence;
   r.preferred_style   = env.preferred_style_text;

   if(StringLen(TrimString(r.setup_type)) <= 0)
      r.setup_type = CouncilFeedbackSetupTypeFromStyle(env.preferred_style_text);

   string extra =
      "ENV summary=" + env.summary +
      " | zone=" + env.zone_name +
      " | zone_conf=" + DoubleToString(env.zone_confidence, 2) +
      " | pref_style=" + env.preferred_style_text +
      " | blocked_style=" + env.blocked_style_text +
      " | exhaustion=" + string(env.exhaustion_hint ? "true" : "false") +
      " | reject_reason=" + env.reject_reason;

   if(StringLen(TrimString(r.explanation)) > 0)
      r.explanation += " || ";

   r.explanation += extra;
}

void FillCouncilFeedbackFromStrategySlot(
   CouncilStrategyReport &s,
   int slot,
   CouncilFeedbackRecord &r
)
{
   string part =
      "S" + IntegerToString(slot) +
      "[" + s.strategy_id +
      " | role=" + s.role_name +
      " | eligibility=" + s.eligibility_text +
      " | decision=" + CouncilDecisionToText(s.decision) +
      " | score=" + DoubleToString(s.score_final, 2) +
      " | zone_align=" + DoubleToString(s.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(s.priority_score, 2) +
      " | reason=" + s.short_reason + "]";

   if(StringLen(TrimString(r.explanation)) > 0)
      r.explanation += " || ";

   r.explanation += part;
}

void FillCouncilFeedbackFromAggregate(
   CouncilAggregateReport &agg,
   CouncilFeedbackRecord &r
)
{
   r.final_decision       = agg.dominant_side;
   r.council_quality      = agg.council_quality;
   r.consensus_strength   = agg.consensus_strength;
   r.conflict_score       = agg.conflict_score;
   r.best_strategy_id     = agg.best_strategy_id;
   r.support_strategy_ids = agg.support_strategy_ids;
   r.consensus_label      = agg.consensus_label;

   r.confirm_role_present   = agg.confirm_role_present;
   r.trend_judge_supportive = agg.trend_judge_supportive;
   r.exhaustion_warning     = agg.exhaustion_warning;

   if(agg.dominant_side != "BUY" && agg.dominant_side != "SELL")
      r.final_decision = "WAIT";

   if(StringLen(TrimString(r.quality_band)) <= 0)
      r.quality_band = CouncilFeedbackQualityBandFromScore(agg.council_quality);

   if(StringLen(TrimString(r.explanation)) > 0)
      r.explanation += " || ";

   r.explanation +=
      "AGG summary=" + agg.summary +
      " | dominant=" + agg.dominant_side +
      " | consensus_label=" + agg.consensus_label +
      " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
      " | zone_align=" + DoubleToString(agg.zone_alignment_score, 2) +
      " | confirm=" + string(agg.confirm_role_present ? "true" : "false") +
      " | trend_judge=" + string(agg.trend_judge_supportive ? "true" : "false") +
      " | exhaustion_warn=" + string(agg.exhaustion_warning ? "true" : "false");
}

void FillCouncilFeedbackFromPreAIFilter(
   CouncilPreAIGateReport &gate,
   CouncilFeedbackRecord &r
)
{
   r.c2_overextension_m5_active      = gate.c2_overextension_m5_active;
   r.c2_consensus_tightening_applied = gate.c2_consensus_tightening_applied;
   r.c2_consensus_tightening_delta   = gate.c2_consensus_tightening_delta;
   r.c2_pre_consensus_requirement    = gate.c2_pre_consensus_requirement;
   r.c2_post_consensus_requirement   = gate.c2_post_consensus_requirement;
   r.c2_effective_on_outcome         = gate.c2_effective_on_outcome;
   r.c2_gate_outcome                 = gate.c2_gate_outcome;

   r.c3_low_structure_tc_active      = gate.c3_low_structure_tc_active;
   r.c3_structure_score              = gate.c3_structure_score;
   r.c3_logic_applied                = gate.c3_logic_applied;
   r.c3_effective_on_outcome         = gate.c3_effective_on_outcome;
   r.c3_gate_outcome                 = gate.c3_gate_outcome;

   if(StringLen(TrimString(r.explanation)) > 0)
      r.explanation += " || ";

   r.explanation +=
      "PRE_AI passed=" + string(gate.passed ? "true" : "false") +
      " | decision=" + CouncilDecisionToText(gate.filtered_decision) +
      " | summary=" + gate.summary;
}

void FillCouncilFeedbackFromGovernor(
   CouncilPolicyAdjustment &gov,
   CouncilFeedbackRecord &r
)
{
   r.governor_state = gov.target_operating_state_text;
   r.c1_tc_active              = gov.c1_tc_active;
   r.c1_high_conviction_active = gov.c1_high_conviction_active;
   r.c1_overextension_active   = gov.c1_overextension_active;
   r.c1_pre_governor_candidate = gov.c1_pre_governor_candidate;
   r.c1_shadowed_by_exhaustion = gov.c1_shadowed_by_exhaustion;
   r.c1_shadow_reason          = gov.c1_shadow_reason;

   if(StringLen(TrimString(r.explanation)) > 0)
      r.explanation += " || ";

   r.explanation +=
      "GOV summary=" + gov.summary +
      " | gov_state=" + gov.target_operating_state_text +
      " | target=" + gov.target_strategy_id +
      " | suggest_mode_exit=" + string(gov.suggest_mode_exit ? "true" : "false");
}

void FillCouncilFeedbackTradeResult(
   bool tradeExecuted,
   string executedDirection,
   string tradeResult,
   double realizedProfit,
   CouncilFeedbackRecord &r
)
{
   r.executed_direction = tradeExecuted ? CouncilFeedbackNormalizeDirectionText(executedDirection) : "";
   r.trade_result       = CouncilFeedbackNormalizeTradeResultText(tradeResult);
   r.profit             = realizedProfit;
   r.close_time         = TimeCurrent();

   if(!tradeExecuted && StringLen(TrimString(r.trade_result)) <= 0)
      r.trade_result = "NOT_EXECUTED";

   FinalizeCouncilFeedbackMemoryFields(r);
}

//---------------------------------------------------------
// JSON build
//---------------------------------------------------------
string CouncilFeedbackRecordToJson(CouncilFeedbackRecord &r)
{
   FinalizeCouncilFeedbackMemoryFields(r);

   string json = "{";

   json += "\"symbol\":\"" + CouncilFeedbackEscape(r.symbol) + "\",";
   json += "\"plan_id\":\"" + CouncilFeedbackEscape(r.plan_id) + "\",";
   json += "\"record_type\":\"" + CouncilFeedbackEscape(r.record_type) + "\",";
   json += "\"record_semantics_version\":\"" + CouncilFeedbackEscape(CouncilFeedbackRecordSemanticsVersion()) + "\",";
   json += "\"mode_name\":\"" + CouncilFeedbackEscape(r.mode_name) + "\",";

   json += "\"decision_id\":\"" + CouncilFeedbackEscape(r.decision_id) + "\",";
   json += "\"correlated_decision_id\":\"" + CouncilFeedbackEscape(r.correlated_decision_id) + "\",";
   json += "\"position_id\":" + CouncilFeedbackU64(r.position_id) + ",";
   json += "\"close_deal_id\":" + CouncilFeedbackU64(r.close_deal_id) + ",";
   json += "\"correlation_method\":\"" + CouncilFeedbackEscape(r.correlation_method) + "\",";
   json += "\"correlation_quality\":" + DoubleToString(r.correlation_quality, 4) + ",";

   json += "\"final_decision\":\"" + CouncilFeedbackEscape(r.final_decision) + "\",";
   json += "\"executed_direction\":\"" + CouncilFeedbackEscape(r.executed_direction) + "\",";
   json += "\"trade_result\":\"" + CouncilFeedbackEscape(r.trade_result) + "\",";
   json += "\"profit\":" + DoubleToString(r.profit, 2) + ",";

   json += "\"environment_score\":" + DoubleToString(r.environment_score, 4) + ",";
   json += "\"council_quality\":" + DoubleToString(r.council_quality, 4) + ",";
   json += "\"consensus_strength\":" + DoubleToString(r.consensus_strength, 4) + ",";
   json += "\"conflict_score\":" + DoubleToString(r.conflict_score, 4) + ",";

   json += "\"zone_name\":\"" + CouncilFeedbackEscape(r.zone_name) + "\",";
   json += "\"zone_confidence\":" + DoubleToString(r.zone_confidence, 4) + ",";
   json += "\"preferred_style\":\"" + CouncilFeedbackEscape(r.preferred_style) + "\",";
   json += "\"governor_state\":\"" + CouncilFeedbackEscape(r.governor_state) + "\",";
   json += "\"consensus_label\":\"" + CouncilFeedbackEscape(r.consensus_label) + "\",";

   json += "\"best_strategy_id\":\"" + CouncilFeedbackEscape(r.best_strategy_id) + "\",";
   json += "\"support_strategy_ids\":\"" + CouncilFeedbackEscape(r.support_strategy_ids) + "\",";
   json += "\"regime_summary\":\"" + CouncilFeedbackEscape(r.regime_summary) + "\",";
   json += "\"explanation\":\"" + CouncilFeedbackEscape(r.explanation) + "\",";

   json += "\"failure_tag\":\"" + CouncilFeedbackEscape(r.failure_tag) + "\",";
   json += "\"quality_band\":\"" + CouncilFeedbackEscape(r.quality_band) + "\",";
   json += "\"setup_type\":\"" + CouncilFeedbackEscape(r.setup_type) + "\",";
   json += "\"confirm_role_present\":" + CouncilFeedbackBoolText(r.confirm_role_present) + ",";
   json += "\"trend_judge_supportive\":" + CouncilFeedbackBoolText(r.trend_judge_supportive) + ",";
   json += "\"exhaustion_warning\":" + CouncilFeedbackBoolText(r.exhaustion_warning) + ",";
   json += "\"c1_tc_active\":" + CouncilFeedbackBoolText(r.c1_tc_active) + ",";
   json += "\"c1_high_conviction_active\":" + CouncilFeedbackBoolText(r.c1_high_conviction_active) + ",";
   json += "\"c1_overextension_active\":" + CouncilFeedbackBoolText(r.c1_overextension_active) + ",";
   json += "\"c1_pre_governor_candidate\":" + CouncilFeedbackBoolText(r.c1_pre_governor_candidate) + ",";
   json += "\"c1_shadowed_by_exhaustion\":" + CouncilFeedbackBoolText(r.c1_shadowed_by_exhaustion) + ",";
   json += "\"c1_shadow_reason\":\"" + CouncilFeedbackEscape(r.c1_shadow_reason) + "\",";
   json += "\"c2_overextension_m5_active\":" + CouncilFeedbackBoolText(r.c2_overextension_m5_active) + ",";
   json += "\"c2_consensus_tightening_applied\":" + CouncilFeedbackBoolText(r.c2_consensus_tightening_applied) + ",";
   json += "\"c2_consensus_tightening_delta\":" + DoubleToString(r.c2_consensus_tightening_delta, 4) + ",";
   json += "\"c2_pre_consensus_requirement\":" + DoubleToString(r.c2_pre_consensus_requirement, 4) + ",";
   json += "\"c2_post_consensus_requirement\":" + DoubleToString(r.c2_post_consensus_requirement, 4) + ",";
   json += "\"c2_effective_on_outcome\":" + CouncilFeedbackBoolText(r.c2_effective_on_outcome) + ",";
   json += "\"c2_gate_outcome\":\"" + CouncilFeedbackEscape(r.c2_gate_outcome) + "\",";
   json += "\"c3_low_structure_tc_active\":" + CouncilFeedbackBoolText(r.c3_low_structure_tc_active) + ",";
   json += "\"c3_structure_score\":" + DoubleToString(r.c3_structure_score, 4) + ",";
   json += "\"c3_logic_applied\":" + CouncilFeedbackBoolText(r.c3_logic_applied) + ",";
   json += "\"c3_effective_on_outcome\":" + CouncilFeedbackBoolText(r.c3_effective_on_outcome) + ",";
   json += "\"c3_gate_outcome\":\"" + CouncilFeedbackEscape(r.c3_gate_outcome) + "\",";
   json += "\"c123_obstacle_summary\":\"" + CouncilFeedbackEscape(r.c123_obstacle_summary) + "\",";
   json += "\"c123_obstacle_semantics_version\":\"" + CouncilFeedbackEscape(r.c123_obstacle_semantics_version) + "\",";

   json += "\"close_time\":" + IntegerToString((int)r.close_time);

   json += "}";

   return json;
}

//---------------------------------------------------------
// High-level writer
//---------------------------------------------------------
bool SaveCouncilFeedbackRecord(
   string relativePath,
   CouncilFeedbackRecord &r,
   string &logMessage
)
{
   logMessage = "";

   FinalizeCouncilFeedbackMemoryFields(r);

   string one = CouncilFeedbackRecordToJson(r);
   if(!AppendCouncilFeedbackJsonObject(relativePath, one))
   {
      logMessage = "Council feedback append failed";
      return false;
   }

   logMessage =
      "Council feedback recorded"
      " | decision=" + r.final_decision +
      " | zone=" + r.zone_name +
      " | gov_state=" + r.governor_state +
      " | result=" + r.trade_result +
      " | quality=" + DoubleToString(r.council_quality, 2) +
      " | band=" + r.quality_band +
      " | setup=" + r.setup_type +
      " | failure=" + r.failure_tag +
      " | obstacles=" + r.c123_obstacle_summary +
      " | best_strategy=" + r.best_strategy_id;

   return true;
}

//---------------------------------------------------------
// Text summary builder
//---------------------------------------------------------
string BuildCouncilFeedbackSummary(CouncilFeedbackRecord &r)
{
   FinalizeCouncilFeedbackMemoryFields(r);

   string s = "";

   s += "COUNCIL FEEDBACK SUMMARY\n";
   s += "symbol: " + r.symbol + "\n";
   s += "mode_name: " + r.mode_name + "\n";
   s += "plan_id: " + r.plan_id + "\n";
   s += "record_type: " + r.record_type + "\n";
   s += "decision_id: " + r.decision_id + "\n";
   s += "correlated_decision_id: " + r.correlated_decision_id + "\n";
   s += "position_id: " + (string)r.position_id + "\n";
   s += "close_deal_id: " + (string)r.close_deal_id + "\n";
   s += "correlation_method: " + r.correlation_method + "\n";
   s += "correlation_quality: " + DoubleToString(r.correlation_quality, 4) + "\n";
   s += "close_time: " + TimeToString(r.close_time, TIME_DATE | TIME_SECONDS) + "\n";

   s += "final_decision: " + r.final_decision + "\n";
   s += "executed_direction: " + r.executed_direction + "\n";
   s += "trade_result: " + r.trade_result + "\n";
   s += "profit: " + DoubleToString(r.profit, 2) + "\n";

   s += "environment_score: " + DoubleToString(r.environment_score, 4) + "\n";
   s += "council_quality: " + DoubleToString(r.council_quality, 4) + "\n";
   s += "consensus_strength: " + DoubleToString(r.consensus_strength, 4) + "\n";
   s += "conflict_score: " + DoubleToString(r.conflict_score, 4) + "\n";

   s += "zone_name: " + r.zone_name + "\n";
   s += "zone_confidence: " + DoubleToString(r.zone_confidence, 4) + "\n";
   s += "preferred_style: " + r.preferred_style + "\n";
   s += "governor_state: " + r.governor_state + "\n";
   s += "consensus_label: " + r.consensus_label + "\n";

   s += "best_strategy_id: " + r.best_strategy_id + "\n";
   s += "support_strategy_ids: " + r.support_strategy_ids + "\n";
   s += "regime_summary: " + r.regime_summary + "\n";

   s += "failure_tag: " + r.failure_tag + "\n";
   s += "quality_band: " + r.quality_band + "\n";
   s += "setup_type: " + r.setup_type + "\n";
   s += "confirm_role_present: " + string(r.confirm_role_present ? "true" : "false") + "\n";
   s += "trend_judge_supportive: " + string(r.trend_judge_supportive ? "true" : "false") + "\n";
   s += "exhaustion_warning: " + string(r.exhaustion_warning ? "true" : "false") + "\n";
   s += "c1_tc_active: " + string(r.c1_tc_active ? "true" : "false") + "\n";
   s += "c1_high_conviction_active: " + string(r.c1_high_conviction_active ? "true" : "false") + "\n";
   s += "c1_overextension_active: " + string(r.c1_overextension_active ? "true" : "false") + "\n";
   s += "c1_pre_governor_candidate: " + string(r.c1_pre_governor_candidate ? "true" : "false") + "\n";
   s += "c1_shadowed_by_exhaustion: " + string(r.c1_shadowed_by_exhaustion ? "true" : "false") + "\n";
   s += "c1_shadow_reason: " + r.c1_shadow_reason + "\n";
   s += "c2_overextension_m5_active: " + string(r.c2_overextension_m5_active ? "true" : "false") + "\n";
   s += "c2_consensus_tightening_applied: " + string(r.c2_consensus_tightening_applied ? "true" : "false") + "\n";
   s += "c2_consensus_tightening_delta: " + DoubleToString(r.c2_consensus_tightening_delta, 4) + "\n";
   s += "c2_pre_consensus_requirement: " + DoubleToString(r.c2_pre_consensus_requirement, 4) + "\n";
   s += "c2_post_consensus_requirement: " + DoubleToString(r.c2_post_consensus_requirement, 4) + "\n";
   s += "c2_effective_on_outcome: " + string(r.c2_effective_on_outcome ? "true" : "false") + "\n";
   s += "c2_gate_outcome: " + r.c2_gate_outcome + "\n";
   s += "c3_low_structure_tc_active: " + string(r.c3_low_structure_tc_active ? "true" : "false") + "\n";
   s += "c3_structure_score: " + DoubleToString(r.c3_structure_score, 4) + "\n";
   s += "c3_logic_applied: " + string(r.c3_logic_applied ? "true" : "false") + "\n";
   s += "c3_effective_on_outcome: " + string(r.c3_effective_on_outcome ? "true" : "false") + "\n";
   s += "c3_gate_outcome: " + r.c3_gate_outcome + "\n";
   s += "c123_obstacle_summary: " + r.c123_obstacle_summary + "\n";
   s += "c123_obstacle_semantics_version: " + r.c123_obstacle_semantics_version + "\n";

   s += "explanation: " + r.explanation + "\n";

   return s;
}

#endif
