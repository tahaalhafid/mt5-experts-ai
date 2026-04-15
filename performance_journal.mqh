#ifndef __PERFORMANCE_JOURNAL_MQH__
#define __PERFORMANCE_JOURNAL_MQH__

#include "core_logger.mqh"
#include "config_loader.mqh"
#include "decision_mode_router.mqh"
#include "regime_classification_layer_v1.mqh"
#include "unified_confidence.mqh"
#include "trade_feedback.mqh"

struct AdvisoryEnvelopeFields
{
   string advisory_state;
   string advisory_outcome;
   string advisory_attachment_state;
   string advisory_gate_reason_code;
   string advisory_ineligibility_reason_code;
   string advisory_block_class;
   string advisory_usage_state;
   string advisory_zero_effect_reason;
};

struct DecisionReasoningFields
{
   string decision_acceptance_posture;
   string decision_reasoning_flags_csv;
};


//---------------------------------------------------------
// Wrapper usage map (Phase 9B)
// Active (runtime):
// - JournalAppendDecision() -> PJ_BuildDecisionJson() (current unified builder)
// - JournalAppendTradeOpen() -> PJ_BuildTradeOpenJsonV5()
// - JournalAppendTrade() -> PJ_BuildTradeJsonV4()
// Shadow records:
// - JournalAppendShadowDecisionReplay() -> V5
// - JournalAppendShadowComparison() -> V5
// Legacy builders/wrappers retained for backward compatibility: V2/V3/V4 where present.
// Council attribution records: JournalAppendCouncilAttribution(), JournalAppendCouncilOutcomeAttribution()
//---------------------------------------------------------
//---------------------------------------------------------
// Unified Performance Journal (JSONL append-only)
//---------------------------------------------------------
#define PERF_JOURNAL_PATH "AI\\ai_performance_journal.jsonl"
#define DECISION_ENVELOPE_TRACE_PATH "AI\\ai_decision_envelope_trace.jsonl"
#define DECISION_ENVELOPE_STATUS_PATH "AI\\ai_decision_envelope_observability_status.json"
#define TRADE_EVIDENCE_STATUS_PATH "AI\\ai_trade_evidence_completeness_status.json"

string PJ_NowAsText()
{
   return TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
}

bool PJ_AppendJsonLine(string relativePath, string jsonLine)
{
   int handle = FileOpen(relativePath, FILE_WRITE|FILE_READ|FILE_TXT|FILE_ANSI);
   if(handle == INVALID_HANDLE) return false;
   FileSeek(handle, 0, SEEK_END);
   FileWriteString(handle, jsonLine);
   FileWriteString(handle, "\n");
   FileClose(handle);
   return true;
}
bool PJ_AppendJsonLine(string relativePath, string jsonLine, string &logMessage)
{
   bool ok = PJ_AppendJsonLine(relativePath, jsonLine);
   if(!ok)
      logMessage = "PJ_AppendJsonLine failed | path=" + relativePath;
   return ok;
}

bool PJ_CreateEmptyJournalFile(const string relativePath, string &logMessage)
{
   logMessage = "";
   FolderCreate("AI");

   int handle = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(handle == INVALID_HANDLE)
   {
      logMessage = "performance_journal_bootstrap_failed";
      return false;
   }

   FileClose(handle);
   logMessage = "performance_journal_bootstrapped_empty";
   return true;
}

bool PJ_EnsureJournalBootstrap(string &logMessage)
{
   logMessage = "";

   if(FileIsExist(PERF_JOURNAL_PATH))
   {
      logMessage = "performance_journal_present";
      return true;
   }

   return PJ_CreateEmptyJournalFile(PERF_JOURNAL_PATH, logMessage);
}

bool PJ_IsDirectionText(string s)
{
   s = TrimString(s);
   StringToUpper(s);
   return (s == "BUY" || s == "SELL");
}

string PJ_NormalizeDirectionText(string s)
{
   s = TrimString(s);
   StringToUpper(s);

   if(s == "LONG")
      s = "BUY";
   else if(s == "SHORT")
      s = "SELL";
   else if(s == "UNKNOWN" || s == "NONE" || s == "NULL" || s == "N/A")
      s = "";

   if(s == "BUY" || s == "SELL")
      return s;

   return "";
}

string PJ_NormalizeTradeResultText(string s)
{
   s = TrimString(s);
   StringToUpper(s);

   if(s == "PROFIT")
      s = "WIN";
   else if(s == "LOSE")
      s = "LOSS";
   else if(s == "BREAKEVEN" || s == "BREAK_EVEN" || s == "BE")
      s = "FLAT";

   if(s == "WIN" || s == "LOSS" || s == "FLAT" || s == "PENDING" || s == "NOT_EXECUTED")
      return s;

   return "";
}

string PJ_JournalSemanticsVersion()
{
   return "S4_JOURNAL_V1";
}

double PJ_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}

double PJ_Clamp01(double v) { return PJ_Clamp(v, 0.0, 1.0); }


string PJ_LastZoneCoverageLabel = "";
double PJ_LastZoneCoverageDiversity = 0.0;
double PJ_LastZoneCoverageConcentration = 0.0;

void PJ_SetZoneCoverageSnapshot(string label, double diversity, double concentration)
{
   PJ_LastZoneCoverageLabel = label;
   PJ_LastZoneCoverageDiversity = PJ_Clamp01(diversity);
   PJ_LastZoneCoverageConcentration = PJ_Clamp01(concentration);
}

string PJ_ZoneCoverageJsonFields()
{
   if(StringLen(PJ_LastZoneCoverageLabel) <= 0)
      return "";

   string s = "";
   s += ",\"zone_coverage\":\"" + PJ_PJ_EscapeJsonMini(PJ_LastZoneCoverageLabel) + "\"";
   s += ",\"coverage_diversity\":" + DoubleToString(PJ_LastZoneCoverageDiversity, 2);
   s += ",\"coverage_concentration\":" + DoubleToString(PJ_LastZoneCoverageConcentration, 2);

   // one-shot snapshot (avoid stale carry)
   PJ_LastZoneCoverageLabel = "";
   PJ_LastZoneCoverageDiversity = 0.0;
   PJ_LastZoneCoverageConcentration = 0.0;
   return s;
}


static string PJ_LastDecisionFinalBlockingLayer = "";
static string PJ_LastDecisionFinalBlockReasonCode = "";
static string PJ_LastDecisionExecutionPath = "";
static string PJ_LastDecisionValidationOutcomeClass = "";
static string PJ_LastDecisionRejectionFamily = "";

string PJ_NormalizeValidationOutcomeClass(string value)
{
   value = TrimString(value);
   StringToUpper(value);

   if(value == "EXECUTED_TRADE_OPEN")
      return value;

   if(value == "BLOCKED" || value == "REJECT" || value == "WAIT" || value == "EXECUTED" || value == "OPEN_FAILURE" || value == "APPROVED_ENTRY_INTENT" || value == "UNCLASSIFIED")
      return value;

   return "UNCLASSIFIED";
}

string PJ_NormalizeRejectionFamily(string value)
{
   value = TrimString(value);
   StringToUpper(value);

   if(value == "PRE_AI" || value == "CONFIRMATION" || value == "CONFLICT" || value == "QUALITY" || value == "NO_TRADE_ENVIRONMENT")
      return value;

   return "";
}

void PJ_SetDecisionValidationContext(
   string finalBlockingLayer,
   string finalBlockReasonCode,
   string executionPath,
   string validationOutcomeClass,
   string rejectionFamily
)
{
   PJ_LastDecisionFinalBlockingLayer = TrimString(finalBlockingLayer);
   PJ_LastDecisionFinalBlockReasonCode = TrimString(finalBlockReasonCode);
   PJ_LastDecisionExecutionPath = TrimString(executionPath);
   PJ_LastDecisionValidationOutcomeClass = PJ_NormalizeValidationOutcomeClass(validationOutcomeClass);
   PJ_LastDecisionRejectionFamily = PJ_NormalizeRejectionFamily(rejectionFamily);
}

string PJ_DecisionValidationJsonFields()
{
   string finalBlockingLayer = PJ_LastDecisionFinalBlockingLayer;
   string finalBlockReasonCode = PJ_LastDecisionFinalBlockReasonCode;
   string executionPath = PJ_LastDecisionExecutionPath;
   string validationOutcomeClass = PJ_NormalizeValidationOutcomeClass(PJ_LastDecisionValidationOutcomeClass);
   string rejectionFamily = PJ_NormalizeRejectionFamily(PJ_LastDecisionRejectionFamily);

   PJ_LastDecisionFinalBlockingLayer = "";
   PJ_LastDecisionFinalBlockReasonCode = "";
   PJ_LastDecisionExecutionPath = "";
   PJ_LastDecisionValidationOutcomeClass = "";
   PJ_LastDecisionRejectionFamily = "";

   string s = "";
   s += ",\"validation_semantics_version\":\"H3_EXECUTION_VALIDATION_V1\"";
   s += ",\"final_blocking_layer\":\"" + PJ_PJ_EscapeJsonMini(finalBlockingLayer) + "\"";
   s += ",\"final_block_reason_code\":\"" + PJ_PJ_EscapeJsonMini(finalBlockReasonCode) + "\"";
   s += ",\"execution_path\":\"" + PJ_PJ_EscapeJsonMini(executionPath) + "\"";
   s += ",\"validation_outcome_class\":\"" + PJ_PJ_EscapeJsonMini(validationOutcomeClass) + "\"";
   s += ",\"validation_rejection_family\":\"" + PJ_PJ_EscapeJsonMini(rejectionFamily) + "\"";
   return s;
}

bool PJ_WriteJsonTextFile(const string relativePath, const string jsonText)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileWriteString(h, jsonText);
   FileClose(h);
   return true;
}

string PJ_BuildDecisionEnvelopeTraceJson(
   string decision_id,
   RoutedRuntimeEvaluation &routed,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string finalDecision,
   string finalBlockingLayer,
   string finalBlockReasonCode,
   string executionPath
)
{
   bool hasSRContext = (StringLen(TrimString(conf.support_resistance_confluence_state)) > 0 &&
                        TrimString(conf.support_resistance_confluence_state) != "UNSET");
   bool hasAdvisoryContext = (conf.advisory_relevance_score > 0.0 ||
                              conf.advisory_contradiction_flag ||
                              conf.advisory_hold_bias_active);
   string advisoryAvailability = (hasAdvisoryContext ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   string srAvailability = (hasSRContext ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   if(StringLen(TrimString(conf.support_resistance_observation_source)) > 0)
      srAvailability = conf.support_resistance_observation_source;

   string json = "{";
   json += "\"record_type\":\"DECISION_ENVELOPE_TRACE\",";
   json += "\"record_semantics_version\":\"S4_DECISION_ENVELOPE_TRACE_V1\",";
   json += "\"artifact_role\":\"DECISION_ENVELOPE_EVIDENCE\",";
   json += "\"artifact_authority_class\":\"DERIVED_OBSERVABILITY_ONLY\",";
   json += "\"non_authoritative_notice\":\"Descriptive observability only. No execution/risk/governor authority.\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"active_mode\":\"" + PJ_PJ_EscapeJsonMini(routed.active_mode) + "\",";
   json += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(conf.direction)) + "\",";
   json += "\"runtime_decision\":\"" + PJ_PJ_EscapeJsonMini(PJ_DecisionText(eval.decision)) + "\",";
   json += "\"policy_result\":\"" + PJ_PJ_EscapeJsonMini(policy_result) + "\",";
   json += "\"final_decision\":\"" + PJ_PJ_EscapeJsonMini(finalDecision) + "\",";
   json += "\"final_blocking_layer\":\"" + PJ_PJ_EscapeJsonMini(finalBlockingLayer) + "\",";
   json += "\"final_block_reason_code\":\"" + PJ_PJ_EscapeJsonMini(finalBlockReasonCode) + "\",";
   json += "\"execution_path\":\"" + PJ_PJ_EscapeJsonMini(executionPath) + "\",";
   json += "\"base_confidence_score\":" + DoubleToString(PJ_Clamp01(conf.base_confidence_score), 4) + ",";
   json += "\"final_confidence_score\":" + DoubleToString(PJ_Clamp01(conf.confidence_score), 4) + ",";
   json += "\"confidence_delta_from_base\":" + DoubleToString(conf.confidence_score - conf.base_confidence_score, 4) + ",";
   json += "\"policy_risk_score\":" + DoubleToString(PJ_Clamp01(conf.policy_risk_score), 4) + ",";
   json += "\"regime_fit_score\":" + DoubleToString(PJ_Clamp01(conf.regime_fit_score), 4) + ",";
   json += "\"learning_confidence_delta\":" + DoubleToString(PJ_Clamp(conf.learning_confidence_delta, -0.08, 0.08), 4) + ",";
   json += "\"learning_caution_score\":" + DoubleToString(PJ_Clamp01(conf.learning_caution_score), 4) + ",";
   json += "\"learning_state_code\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_state_code) + "\",";
   json += "\"learning_evidence_count\":" + IntegerToString(conf.learning_evidence_count) + ",";
   json += "\"learning_evidence_threshold_met\":" + PJ_BoolText(conf.learning_evidence_threshold_met) + ",";
   json += "\"learning_zero_influence_due_to_insufficient_evidence\":" + PJ_BoolText(conf.learning_zero_influence_due_to_insufficient_evidence) + ",";
   json += "\"learning_reason_codes_csv\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_reason_codes_csv) + "\",";
   json += "\"learning_contradiction_signal\":" + PJ_BoolText(conf.learning_contradiction_signal) + ",";
   json += "\"learning_hold_bias\":" + PJ_BoolText(conf.learning_hold_bias) + ",";
   json += "\"learning_reevaluation_bias\":" + PJ_BoolText(conf.learning_reevaluation_bias) + ",";
   json += "\"advisory_relevance_score\":" + DoubleToString(PJ_Clamp01(conf.advisory_relevance_score), 4) + ",";
   json += "\"advisory_contradiction_flag\":" + PJ_BoolText(conf.advisory_contradiction_flag) + ",";
   json += "\"advisory_hold_bias_active\":" + PJ_BoolText(conf.advisory_hold_bias_active) + ",";
   json += "\"advisory_available\":" + PJ_BoolText(conf.advisory_available) + ",";
   json += "\"advisory_eligible\":" + PJ_BoolText(conf.advisory_eligible) + ",";
   json += "\"advisory_shadow_attached\":" + PJ_BoolText(conf.advisory_shadow_attached) + ",";
   json += "\"advisory_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_state) + "\",";
   json += "\"advisory_outcome\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_outcome) + "\",";
   json += "\"advisory_attachment_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_attachment_state) + "\",";
   json += "\"advisory_gate_reason_code\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_gate_reason_code) + "\",";
   json += "\"advisory_ineligibility_reason_code\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_ineligibility_reason_code) + "\",";
   json += "\"advisory_block_class\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_block_class) + "\",";
   json += "\"advisory_usage_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_usage_state) + "\",";
   json += "\"advisory_zero_effect_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_zero_effect_reason) + "\",";
   json += "\"support_resistance_confluence_state\":\"" + PJ_PJ_EscapeJsonMini(conf.support_resistance_confluence_state) + "\",";
   json += "\"canonical_level_state\":\"" + PJ_PJ_EscapeJsonMini(conf.canonical_level_state) + "\",";
   json += "\"sr_interaction_bucket\":\"" + PJ_PJ_EscapeJsonMini(conf.sr_interaction_bucket) + "\",";
   json += "\"nearest_support_price\":" + DoubleToString(conf.nearest_support_price, 5) + ",";
   json += "\"nearest_resistance_price\":" + DoubleToString(conf.nearest_resistance_price, 5) + ",";
   json += "\"nearest_support_distance_points\":" + IntegerToString(conf.nearest_support_distance_points) + ",";
   json += "\"nearest_resistance_distance_points\":" + IntegerToString(conf.nearest_resistance_distance_points) + ",";
   json += "\"level_interaction_type\":\"" + PJ_PJ_EscapeJsonMini(conf.level_interaction_type) + "\",";
   json += "\"level_context_supported\":" + PJ_BoolText(conf.level_context_supported) + ",";
   json += "\"level_context_obstructed\":" + PJ_BoolText(conf.level_context_obstructed) + ",";
   json += "\"level_context_degraded\":" + PJ_BoolText(conf.level_context_degraded) + ",";
   json += "\"sr_confluence_flag\":" + PJ_BoolText(conf.sr_confluence_flag) + ",";
   json += "\"sr_rejection_risk_flag\":" + PJ_BoolText(conf.sr_rejection_risk_flag) + ",";
   json += "\"sr_continuation_obstructed_flag\":" + PJ_BoolText(conf.sr_continuation_obstructed_flag) + ",";
   json += "\"sr_canonical_near_flag\":" + PJ_BoolText(conf.sr_canonical_near_flag) + ",";
   json += "\"sr_conflicted_flag\":" + PJ_BoolText(conf.sr_conflicted_flag) + ",";
   json += "\"decision_acceptance_posture\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_acceptance_posture) + "\",";
   json += "\"decision_reasoning_flags_csv\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_reasoning_flags_csv) + "\",";
   json += "\"advisory_observation_source\":\"" + PJ_PJ_EscapeJsonMini(advisoryAvailability) + "\",";
   json += "\"support_resistance_observation_source\":\"" + PJ_PJ_EscapeJsonMini(srAvailability) + "\"";
   json += "}";
   return json;
}

bool JournalAppendDecisionEnvelopeTrace(
   string decision_id,
   RoutedRuntimeEvaluation &routed,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string finalDecision,
   string finalBlockingLayer,
   string finalBlockReasonCode,
   string executionPath,
   string &logMessage
)
{
   logMessage = "";
   string json = PJ_BuildDecisionEnvelopeTraceJson(
      decision_id,
      routed,
      conf,
      eval,
      policy_result,
      finalDecision,
      finalBlockingLayer,
      finalBlockReasonCode,
      executionPath
   );

   if(!PJ_AppendLine(DECISION_ENVELOPE_TRACE_PATH, json + "\n"))
   {
      logMessage = "Decision envelope trace append failed";
      return false;
   }

   string statusJson = "{";
   statusJson += "\"status_surface\":\"DECISION_ENVELOPE_OBSERVABILITY_STATUS\",";
   statusJson += "\"updated_at\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   statusJson += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   statusJson += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(conf.direction)) + "\",";
   statusJson += "\"decision_acceptance_posture\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_acceptance_posture) + "\",";
   statusJson += "\"confidence_delta_from_base\":" + DoubleToString(conf.confidence_score - conf.base_confidence_score, 4) + ",";
   statusJson += "\"learning_state_code\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_state_code) + "\",";
   statusJson += "\"learning_evidence_threshold_met\":" + PJ_BoolText(conf.learning_evidence_threshold_met) + ",";
   statusJson += "\"support_resistance_observed\":" + PJ_BoolText(StringLen(TrimString(conf.support_resistance_confluence_state)) > 0 && TrimString(conf.support_resistance_confluence_state) != "UNSET") + ",";
   statusJson += "\"advisory_observed\":" + PJ_BoolText(conf.advisory_relevance_score > 0.0 || conf.advisory_contradiction_flag || conf.advisory_hold_bias_active) + ",";
   statusJson += "\"advisory_available\":" + PJ_BoolText(conf.advisory_available) + ",";
   statusJson += "\"advisory_eligible\":" + PJ_BoolText(conf.advisory_eligible) + ",";
   statusJson += "\"advisory_shadow_attached\":" + PJ_BoolText(conf.advisory_shadow_attached) + ",";
   statusJson += "\"advisory_usage_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_usage_state) + "\",";
   statusJson += "\"advisory_zero_effect_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_zero_effect_reason) + "\",";
   statusJson += "\"level_interaction_type\":\"" + PJ_PJ_EscapeJsonMini(conf.level_interaction_type) + "\",";
   statusJson += "\"nearest_support_captured\":" + PJ_BoolText(conf.nearest_support_price > 0.0 || conf.nearest_support_distance_points >= 0) + ",";
   statusJson += "\"nearest_resistance_captured\":" + PJ_BoolText(conf.nearest_resistance_price > 0.0 || conf.nearest_resistance_distance_points >= 0) + ",";
   statusJson += "\"classification\":\"NON_AUTHORITATIVE_STATUS\"";
   statusJson += "}";
   PJ_WriteJsonTextFile(DECISION_ENVELOPE_STATUS_PATH, statusJson);

   logMessage = "Decision envelope trace appended";
   return true;
}





//---------------------------------------------------------
// Level Awareness v2 — Environmental Brake snapshot (one-shot)
//---------------------------------------------------------
string PJ_LastLevelBrakeVerdict = "";
string PJ_LastLevelBrakeReason  = "";
double PJ_LastLevelBrakeRoom    = 0.0;
double PJ_LastLevelBrakeRejRisk = 0.0;
string PJ_LastLevelBrakeSummary = "";

void PJ_SetLevelBrakeSnapshot(string verdict, string reason, double room_score, double rejection_risk, string summary)
{
   PJ_LastLevelBrakeVerdict = verdict;
   PJ_LastLevelBrakeReason  = reason;
   PJ_LastLevelBrakeRoom    = PJ_Clamp01(room_score);
   PJ_LastLevelBrakeRejRisk = PJ_Clamp01(rejection_risk);
   PJ_LastLevelBrakeSummary = summary;
}

string PJ_LevelBrakeJsonFields()
{
   if(StringLen(PJ_LastLevelBrakeVerdict) <= 0)
      return "";

   string s = "";
   s += ",\"level_brake_verdict\":\"" + PJ_PJ_EscapeJsonMini(PJ_LastLevelBrakeVerdict) + "\"";
   s += ",\"level_brake_reason\":\"" + PJ_PJ_EscapeJsonMini(PJ_LastLevelBrakeReason) + "\"";
   s += ",\"breakout_room_score\":" + DoubleToString(PJ_LastLevelBrakeRoom, 2);
   s += ",\"rejection_risk_score\":" + DoubleToString(PJ_LastLevelBrakeRejRisk, 2);
   s += ",\"location_context_summary\":\"" + PJ_PJ_EscapeJsonMini(PJ_LastLevelBrakeSummary) + "\"";

   // one-shot snapshot (avoid stale carry)
   PJ_LastLevelBrakeVerdict = "";
   PJ_LastLevelBrakeReason  = "";
   PJ_LastLevelBrakeRoom    = 0.0;
   PJ_LastLevelBrakeRejRisk = 0.0;
   PJ_LastLevelBrakeSummary = "";

   return s;
}
// Simple FNV-1a 32-bit string hash (stable, low-risk)
uint PJ_Fnv1a32(string s)
{
   uint h = 2166136261;
   int n = StringLen(s);

   for(int i = 0; i < n; i++)
   {
      ushort ch = StringGetCharacter(s, i);
      h ^= (uint)ch;
      h *= 16777619;
   }
   return h;
}

string PJ_EscapeJsonMini(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", " ");
   StringReplace(s, "\n", " ");
   StringReplace(s, "\t", " ");
   return s;
}

// Backward-compat alias (legacy typo in some builds)
string PJ_PJ_EscapeJsonMini(string s) { return PJ_EscapeJsonMini(s); }

bool PJ_IsJsonLineProbablyValid(string line)
{
   if(StringLen(line) <= 0)
      return false;

   // Strip trailing CR/LF for validation.
   while(StringLen(line) > 0)
   {
      ushort ch = StringGetCharacter(line, StringLen(line) - 1);
      if(ch == '\r' || ch == '\n')
         line = StringSubstr(line, 0, StringLen(line) - 1);
      else
         break;
   }

   if(StringLen(line) < 2)
      return false;

   if(StringGetCharacter(line, 0) != '{' || StringGetCharacter(line, StringLen(line) - 1) != '}')
      return false;

   // Minimal quote-balance check (ignore escaped quotes).
   int quotes = 0;
   bool escaped = false;
   for(int i = 0; i < StringLen(line); i++)
   {
      ushort ch = StringGetCharacter(line, i);
      if(escaped)
      {
         escaped = false;
         continue;
      }
      if(ch == '\\')
      {
         escaped = true;
         continue;
      }
      if(ch == '\"')
         quotes++;
   }
   if((quotes % 2) != 0)
      return false;

   return true;
}

bool PJ_FileEndsWithNewline(string relativePath)
{
   int h = FileOpen(relativePath, FILE_READ | FILE_BIN);
   if(h == INVALID_HANDLE)
      return true; // treat missing as "ok"
   int sz = (int)FileSize(h);
   if(sz <= 0)
   {
      FileClose(h);
      return true;
   }
   FileSeek(h, sz - 1, SEEK_SET);
   int b = FileReadInteger(h, CHAR_VALUE);
   FileClose(h);
   return (b == '\n');
}

bool PJ_AppendLine(string relativePath, string line)
{
   if(!PJ_IsJsonLineProbablyValid(line))
   {
      // Do not crash trading; just drop malformed journal line and keep a trace.
      Print("PJ_AppendLine: dropped malformed JSONL line for ", relativePath);
      int rh = FileOpen("AI\\\\ai_journal_rejects.txt", FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(rh == INVALID_HANDLE)
         rh = FileOpen("AI\\\\ai_journal_rejects.txt", FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(rh != INVALID_HANDLE)
      {
         FileSeek(rh, 0, SEEK_END);
         FileWriteString(rh, line + "\n");
         FileClose(rh);
      }
      return false;
   }

   // Ensure JSONL invariant: exactly one record per line.
   while(StringLen(line) > 0)
   {
      ushort ch = StringGetCharacter(line, StringLen(line) - 1);
      if(ch == '\r' || ch == '\n')
         line = StringSubstr(line, 0, StringLen(line) - 1);
      else
         break;
   }
   line += "\n";

   string prefix = "";
   if(!PJ_FileEndsWithNewline(relativePath))
      prefix = "\n";

   int h = FileOpen(relativePath, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);

   if(h == INVALID_HANDLE)
   {
      h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(h == INVALID_HANDLE)
         return false;

      FileWriteString(h, line);
      FileClose(h);
      return true;
   }

   FileSeek(h, 0, SEEK_END);
   if(StringLen(prefix) > 0)
      FileWriteString(h, prefix);
   FileWriteString(h, line);
   FileClose(h);
   return true;
}

string PJ_PlanFingerprint(RuntimePlan &plan)
{
   string key =
      plan.plan_id + "|" +
      plan.plan_mode + "|" +
      plan.decision_engine_mode + "|" +
      plan.execution_archetype + "|" +
      plan.experiment_family + "|" +
      plan.experiment_note;

   uint h = PJ_Fnv1a32(key);
   return StringFormat("%s|%08X", plan.plan_id, h);
}

string PJ_NowIso()
{
   return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

string PJ_MakeDecisionId()
{
   static uint seq = 0;
   seq++;

   long t = (long)TimeCurrent();
   string sym = _Symbol;
   int bars = Bars(_Symbol, PERIOD_M1);

   return StringFormat("%s-%ld-%d-%u", sym, t, bars, seq);
}

string PJ_DecisionText(RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY)  return "BUY";
   if(d == RUNTIME_ENTER_SELL) return "SELL";
   if(d == RUNTIME_REJECT)     return "REJECT";
   return "WAIT";
}

string PJ_BoolText(bool v) { return (v ? "true" : "false"); }

string PJ_U64(ulong v)
{
   return StringFormat("%I64u", v);
}


//---------------------------------------------------------
// Phase 8A: Council attribution cache (restart-safe linkage best-effort)
//---------------------------------------------------------
static string gPJ_LastCouncilDecisionId = "";
static CouncilDecisionAttribution gPJ_LastCouncilAttribution;

void PJ_CacheCouncilAttribution(string decision_id, CouncilDecisionAttribution &a)
{
   gPJ_LastCouncilDecisionId = decision_id;
   gPJ_LastCouncilAttribution = a;
}

bool PJ_GetCachedCouncilAttribution(string decision_id, CouncilDecisionAttribution &outA)
{
   InitCouncilDecisionAttribution(outA);

   if(StringLen(decision_id) <= 0) return false;
   if(decision_id != gPJ_LastCouncilDecisionId) return false;
   if(!gPJ_LastCouncilAttribution.available) return false;

   outA = gPJ_LastCouncilAttribution;
   return true;
}

void PJ_InjectCouncilAttributionFieldsIntoTradeOpenJson(string decision_id, string &json)
{
   CouncilDecisionAttribution a;
   if(!PJ_GetCachedCouncilAttribution(decision_id, a))
      return;

   int n = StringLen(json);
   if(n <= 0) return;

   bool hadClosing = (StringGetCharacter(json, n - 1) == '}');
   if(hadClosing)
      json = StringSubstr(json, 0, n - 1);

   json += ",\"dominant_strategy_id\":\"" + PJ_PJ_EscapeJsonMini(a.dominant_strategy_id) + "\"";
   json += ",\"aligned_strategy_count\":" + IntegerToString(a.aligned_count);
   json += ",\"opposing_strategy_count\":" + IntegerToString(a.opposing_count);
   json += ",\"neutral_strategy_count\":" + IntegerToString(a.neutral_count);
   json += ",\"attribution_confidence\":" + DoubleToString(PJ_Clamp01(a.attribution_confidence), 3);
   json += ",\"attribution_summary\":\"" + PJ_PJ_EscapeJsonMini(a.attribution_summary) + "\"";

   json += ",\"aligned_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(a.aligned_strategy_ids) + "\"";
   json += ",\"opposing_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(a.opposing_strategy_ids) + "\"";
   json += ",\"neutral_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(a.neutral_strategy_ids) + "\"";
   json += ",\"strategies_compact\":\"" + PJ_PJ_EscapeJsonMini(a.strategies_compact) + "\"";

   if(hadClosing)
      json += "}";
}


string PJ_BuildDecisionJson(
   RuntimePlan &plan,
   string activeMode,
   TimeframeSnapshot &m1,
   RegimeClassification &regime,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string council_summary,
   string governor_state,
   string evolution_version
)
{
   string fp = PJ_PlanFingerprint(plan);

   string json = "{";
   json += "\"record_type\":\"DECISION\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"DECISION\",";
   json += "\"decision_event_type\":\"DECISION_EVALUATION\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"tf\":\"M1\",";
   json += "\"plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(fp) + "\",";
   json += "\"plan_id\":\"" + PJ_PJ_EscapeJsonMini(plan.plan_id) + "\",";
   json += "\"active_mode\":\"" + PJ_PJ_EscapeJsonMini(activeMode) + "\",";
   json += "\"regime_label\":\"" + PJ_PJ_EscapeJsonMini(regime.regime_label) + "\",";
   json += "\"regime_confidence\":" + DoubleToString(regime.regime_confidence, 3) + ",";
   json += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(conf.direction)) + "\",";
   json += "\"raw_signal_score\":" + DoubleToString(conf.raw_signal_score, 3) + ",";
   json += "\"confidence_score\":" + DoubleToString(conf.confidence_score, 3) + ",";
   json += "\"regime_fit_score\":" + DoubleToString(conf.regime_fit_score, 3) + ",";
   json += "\"execution_quality_score\":" + DoubleToString(conf.execution_quality_score, 3) + ",";
   json += "\"policy_risk_score\":" + DoubleToString(conf.policy_risk_score, 3) + ",";
   json += "\"final_permission\":" + PJ_BoolText(conf.final_permission) + ",";
   json += "\"final_decision\":\"" + PJ_PJ_EscapeJsonMini(PJ_DecisionText(eval.decision)) + "\",";
   json += "\"policy_result\":\"" + PJ_PJ_EscapeJsonMini(policy_result) + "\",";
   json += "\"entry_quality\":\"\",";
   json += "\"council_summary\":\"" + PJ_PJ_EscapeJsonMini(council_summary) + "\",";
   json += "\"governor_state\":\"" + PJ_PJ_EscapeJsonMini(governor_state) + "\",";
   json += "\"evolution_version\":\"" + PJ_PJ_EscapeJsonMini(evolution_version) + "\",";
   json += "\"exit_class\":\"\",";
   json += "\"final_decision_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.final_decision_reason) + "\",";
   json += "\"spread_points\":" + DoubleToString(m1.spread_points, 1);
   json += PJ_ZoneCoverageJsonFields();
   json += PJ_LevelBrakeJsonFields();
   json += "}";
   return json;
}

string PJ_BuildDecisionJsonV2(
   string decision_id,
   RuntimePlan &plan,
   string activeMode,
   TimeframeSnapshot &m1,
   RegimeClassification &regime,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string policy_state,
   string policy_state_reason,
   string failure_class,
   string failure_reason_summary,
   double failure_severity,
   string failure_basis,
   string council_summary,
   string governor_state,
   string evolution_version
)
{
   string fp = PJ_PlanFingerprint(plan);

   string json = "{";
   json += "\"record_type\":\"DECISION\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"DECISION\",";
   json += "\"decision_event_type\":\"DECISION_EVALUATION\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"tf\":\"M1\",";
   json += "\"plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(fp) + "\",";
   json += "\"plan_id\":\"" + PJ_PJ_EscapeJsonMini(plan.plan_id) + "\",";
   json += "\"active_mode\":\"" + PJ_PJ_EscapeJsonMini(activeMode) + "\",";
   json += "\"policy_state\":\"" + PJ_PJ_EscapeJsonMini(policy_state) + "\",";
   json += "\"policy_state_reason\":\"" + PJ_PJ_EscapeJsonMini(policy_state_reason) + "\",";
   json += "\"regime_label\":\"" + PJ_PJ_EscapeJsonMini(regime.regime_label) + "\",";
   json += "\"regime_confidence\":" + DoubleToString(regime.regime_confidence, 3) + ",";
   json += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(conf.direction)) + "\",";
   json += "\"raw_signal_score\":" + DoubleToString(conf.raw_signal_score, 3) + ",";
   json += "\"confidence_score\":" + DoubleToString(conf.confidence_score, 3) + ",";
   json += "\"regime_fit_score\":" + DoubleToString(conf.regime_fit_score, 3) + ",";
   json += "\"execution_quality_score\":" + DoubleToString(conf.execution_quality_score, 3) + ",";
   json += "\"policy_risk_score\":" + DoubleToString(conf.policy_risk_score, 3) + ",";
   json += "\"final_permission\":" + PJ_BoolText(conf.final_permission) + ",";
   json += "\"final_decision\":\"" + PJ_PJ_EscapeJsonMini(PJ_DecisionText(eval.decision)) + "\",";
   json += "\"policy_result\":\"" + PJ_PJ_EscapeJsonMini(policy_result) + "\",";
   json += "\"failure_class\":\"" + PJ_PJ_EscapeJsonMini(failure_class) + "\",";
   json += "\"failure_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(failure_reason_summary) + "\",";
   json += "\"failure_severity\":" + DoubleToString(PJ_Clamp01(failure_severity), 3) + ",";
   json += "\"failure_basis\":\"" + PJ_PJ_EscapeJsonMini(failure_basis) + "\",";
json += "\"entry_quality_score\":" + DoubleToString(conf.entry_quality_score, 3) + ",";
json += "\"timing_quality_score\":" + DoubleToString(conf.timing_quality_score, 3) + ",";
json += "\"location_quality_score\":" + DoubleToString(conf.location_quality_score, 3) + ",";
json += "\"volatility_fit_score\":" + DoubleToString(conf.volatility_fit_score, 3) + ",";
json += "\"entry_quality_label\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_quality_label) + "\",";
json += "\"entry_quality_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_quality_reason) + "\",";
json += "\"entry_quality_flags\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_quality_flags) + "\",";
json += "\"strategy_regime_fit_score\":" + DoubleToString(conf.strategy_regime_fit_score, 3) + ",";
json += "\"strategy_regime_fit_label\":\"" + PJ_PJ_EscapeJsonMini(conf.strategy_regime_fit_label) + "\",";
json += "\"strategy_regime_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.strategy_regime_reason) + "\",";
json += "\"decision_quality_score\":" + DoubleToString(conf.decision_quality_score, 3) + ",";
json += "\"decision_quality_label\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_quality_label) + "\",";
json += "\"decision_quality_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_quality_reason) + "\",";
   json += "\"council_summary\":\"" + PJ_PJ_EscapeJsonMini(council_summary) + "\",";
   json += "\"governor_state\":\"" + PJ_PJ_EscapeJsonMini(governor_state) + "\",";
   json += "\"evolution_version\":\"" + PJ_PJ_EscapeJsonMini(evolution_version) + "\",";
   json += "\"exit_class\":\"\",";
   json += "\"final_decision_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.final_decision_reason) + "\",";
   json += "\"spread_points\":" + DoubleToString(m1.spread_points, 1);
   json += PJ_DecisionValidationJsonFields();
   json += "}";
   return json;
}

bool JournalAppendDecisionV2(
   string decision_id,
   RuntimePlan &plan,
   string activeMode,
   TimeframeSnapshot &m1,
   RegimeClassification &regime,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string policy_state,
   string policy_state_reason,
   string failure_class,
   string failure_reason_summary,
   double failure_severity,
   string failure_basis,
   string council_summary,
   string governor_state,
   string evolution_version,
   string &logMessage
)
{
   logMessage = "";

   string json = PJ_BuildDecisionJsonV2(
      decision_id,
      plan, activeMode, m1, regime, conf, eval,
      policy_result, policy_state, policy_state_reason,
      failure_class, failure_reason_summary, failure_severity, failure_basis,
      council_summary, governor_state, evolution_version
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (decision v2)";
      return false;
   }

   logMessage = "Performance journal appended (decision v2)";
   return true;
}

bool JournalAppendDecision(
   RuntimePlan &plan,
   string activeMode,
   TimeframeSnapshot &m1,
   RegimeClassification &regime,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string council_summary,
   string governor_state,
   string evolution_version,
   string &logMessage
)
{
   logMessage = "";

   string json = PJ_BuildDecisionJson(
      plan, activeMode, m1, regime, conf, eval,
      policy_result, council_summary, governor_state, evolution_version
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (decision)";
      return false;
   }

   logMessage = "Performance journal appended (decision)";
   return true;
}


//---------------------------------------------------------
// Decision journal v3 (adds clustering + rollback hooks fields)
//---------------------------------------------------------
string PJ_BuildDecisionJsonV3(
   string decision_id,
   RuntimePlan &plan,
   string activeMode,
   TimeframeSnapshot &m1,
   RegimeClassification &regime,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string policy_state,
   string policy_state_reason,
   string failure_class,
   string failure_reason_summary,
   double failure_severity,
   string failure_basis,
   string council_summary,
   string governor_state,
   string evolution_version,
   // analytics hooks
   string rollback_signal_state,
   double rollback_signal_score,
   string rollback_signal_reason,
   bool failure_cluster_detected,
   string dominant_failure_class,
   int dominant_failure_count,
   double failure_cluster_score,
   string dominant_regime,
   string regime_perf_summary
)
{
   string fp = PJ_PlanFingerprint(plan);

   string json = "{";
   json += "\"record_type\":\"DECISION\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"DECISION\",";
   json += "\"decision_event_type\":\"DECISION_EVALUATION\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(fp) + "\",";
   json += "\"plan_id\":\"" + PJ_PJ_EscapeJsonMini(plan.plan_id) + "\",";
   json += "\"active_mode\":\"" + PJ_PJ_EscapeJsonMini(activeMode) + "\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"tf\":\"M1\",";
   json += "\"regime_label\":\"" + PJ_PJ_EscapeJsonMini(regime.regime_label) + "\",";
   json += "\"regime_confidence\":" + DoubleToString(PJ_Clamp01(regime.regime_confidence), 3) + ",";
   json += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(conf.direction)) + "\",";
   json += "\"raw_signal_score\":" + DoubleToString(PJ_Clamp(conf.raw_signal_score, -1.0, 1.0), 3) + ",";
   json += "\"confidence_score\":" + DoubleToString(PJ_Clamp01(conf.confidence_score), 3) + ",";
   json += "\"regime_fit_score\":" + DoubleToString(PJ_Clamp01(conf.regime_fit_score), 3) + ",";
   json += "\"execution_quality_score\":" + DoubleToString(PJ_Clamp01(conf.execution_quality_score), 3) + ",";
   json += "\"policy_risk_score\":" + DoubleToString(PJ_Clamp01(conf.policy_risk_score), 3) + ",";

   // Strategy Intelligence + Execution Estimation (v7A)
   json += "\"entry_quality_score\":" + DoubleToString(PJ_Clamp01(conf.entry_quality_score), 3) + ",";
   json += "\"timing_quality_score\":" + DoubleToString(PJ_Clamp01(conf.timing_quality_score), 3) + ",";
   json += "\"location_quality_score\":" + DoubleToString(PJ_Clamp01(conf.location_quality_score), 3) + ",";
   json += "\"volatility_fit_score\":" + DoubleToString(PJ_Clamp01(conf.volatility_fit_score), 3) + ",";
   json += "\"entry_quality_label\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_quality_label) + "\",";
   json += "\"entry_quality_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_quality_reason) + "\",";
   json += "\"entry_quality_flags\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_quality_flags) + "\",";

   json += "\"strategy_regime_fit_score\":" + DoubleToString(PJ_Clamp01(conf.strategy_regime_fit_score), 3) + ",";
   json += "\"strategy_regime_fit_label\":\"" + PJ_PJ_EscapeJsonMini(conf.strategy_regime_fit_label) + "\",";
   json += "\"strategy_regime_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.strategy_regime_reason) + "\",";

   json += "\"rr_location_score\":" + DoubleToString(PJ_Clamp01(conf.rr_location_score), 3) + ",";
   json += "\"entry_edge_score\":" + DoubleToString(PJ_Clamp01(conf.entry_edge_score), 3) + ",";
   json += "\"entry_edge_label\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_edge_label) + "\",";
   json += "\"entry_edge_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.entry_edge_reason) + "\",";

   json += "\"follow_through_quality_score\":" + DoubleToString(PJ_Clamp01(conf.follow_through_quality_score), 3) + ",";
   json += "\"follow_through_quality_label\":\"" + PJ_PJ_EscapeJsonMini(conf.follow_through_quality_label) + "\",";
   json += "\"follow_through_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.follow_through_reason) + "\",";

   json += "\"decision_quality_score\":" + DoubleToString(PJ_Clamp01(conf.decision_quality_score), 3) + ",";
   json += "\"decision_quality_label\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_quality_label) + "\",";
   json += "\"decision_quality_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_quality_reason) + "\",";
   json += "\"decision_quality_version\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_quality_version) + "\",";

   // L3 institutional learning overlay (bounded, non-authoritative)
   json += "\"base_confidence_score\":" + DoubleToString(PJ_Clamp01(conf.base_confidence_score), 4) + ",";
   json += "\"confidence_delta_from_base\":" + DoubleToString(conf.confidence_score - conf.base_confidence_score, 4) + ",";
   json += "\"learning_confidence_delta\":" + DoubleToString(PJ_Clamp(conf.learning_confidence_delta, -0.08, 0.08), 4) + ",";
   json += "\"learning_caution_score\":" + DoubleToString(PJ_Clamp01(conf.learning_caution_score), 4) + ",";
   json += "\"learning_context_fit_score\":" + DoubleToString(PJ_Clamp01(conf.learning_context_fit_score), 4) + ",";
   json += "\"learning_evidence_count\":" + IntegerToString(conf.learning_evidence_count) + ",";
   json += "\"learning_state_code\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_state_code) + "\",";
   json += "\"learning_evidence_threshold_met\":" + PJ_BoolText(conf.learning_evidence_threshold_met) + ",";
   json += "\"learning_zero_influence_due_to_insufficient_evidence\":" + PJ_BoolText(conf.learning_zero_influence_due_to_insufficient_evidence) + ",";
   json += "\"learning_motif_key\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_motif_key) + "\",";
   json += "\"learning_reason_codes_csv\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_reason_codes_csv) + "\",";
   json += "\"learning_contradiction_signal\":" + PJ_BoolText(conf.learning_contradiction_signal) + ",";
   json += "\"learning_hold_bias\":" + PJ_BoolText(conf.learning_hold_bias) + ",";
   json += "\"learning_reevaluation_bias\":" + PJ_BoolText(conf.learning_reevaluation_bias) + ",";
   json += "\"learning_strength_band\":\"" + PJ_PJ_EscapeJsonMini(conf.learning_strength_band) + "\",";
   json += "\"advisory_relevance_score\":" + DoubleToString(PJ_Clamp01(conf.advisory_relevance_score), 4) + ",";
   json += "\"advisory_contradiction_flag\":" + PJ_BoolText(conf.advisory_contradiction_flag) + ",";
   json += "\"advisory_hold_bias_active\":" + PJ_BoolText(conf.advisory_hold_bias_active) + ",";
   json += "\"advisory_available\":" + PJ_BoolText(conf.advisory_available) + ",";
   json += "\"advisory_eligible\":" + PJ_BoolText(conf.advisory_eligible) + ",";
   json += "\"advisory_shadow_attached\":" + PJ_BoolText(conf.advisory_shadow_attached) + ",";
   json += "\"advisory_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_state) + "\",";
   json += "\"advisory_outcome\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_outcome) + "\",";
   json += "\"advisory_attachment_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_attachment_state) + "\",";
   json += "\"advisory_gate_reason_code\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_gate_reason_code) + "\",";
   json += "\"advisory_ineligibility_reason_code\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_ineligibility_reason_code) + "\",";
   json += "\"advisory_block_class\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_block_class) + "\",";
   json += "\"advisory_usage_state\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_usage_state) + "\",";
   json += "\"advisory_zero_effect_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.advisory_zero_effect_reason) + "\",";
   json += "\"support_resistance_confluence_state\":\"" + PJ_PJ_EscapeJsonMini(conf.support_resistance_confluence_state) + "\",";
   json += "\"canonical_level_state\":\"" + PJ_PJ_EscapeJsonMini(conf.canonical_level_state) + "\",";
   json += "\"sr_interaction_bucket\":\"" + PJ_PJ_EscapeJsonMini(conf.sr_interaction_bucket) + "\",";
   json += "\"nearest_support_price\":" + DoubleToString(conf.nearest_support_price, 5) + ",";
   json += "\"nearest_resistance_price\":" + DoubleToString(conf.nearest_resistance_price, 5) + ",";
   json += "\"nearest_support_distance_points\":" + IntegerToString(conf.nearest_support_distance_points) + ",";
   json += "\"nearest_resistance_distance_points\":" + IntegerToString(conf.nearest_resistance_distance_points) + ",";
   json += "\"level_interaction_type\":\"" + PJ_PJ_EscapeJsonMini(conf.level_interaction_type) + "\",";
   json += "\"level_context_supported\":" + PJ_BoolText(conf.level_context_supported) + ",";
   json += "\"level_context_obstructed\":" + PJ_BoolText(conf.level_context_obstructed) + ",";
   json += "\"level_context_degraded\":" + PJ_BoolText(conf.level_context_degraded) + ",";
   json += "\"support_resistance_observation_source\":\"" + PJ_PJ_EscapeJsonMini(conf.support_resistance_observation_source) + "\",";
   json += "\"sr_confluence_flag\":" + PJ_BoolText(conf.sr_confluence_flag) + ",";
   json += "\"sr_rejection_risk_flag\":" + PJ_BoolText(conf.sr_rejection_risk_flag) + ",";
   json += "\"sr_continuation_obstructed_flag\":" + PJ_BoolText(conf.sr_continuation_obstructed_flag) + ",";
   json += "\"sr_canonical_near_flag\":" + PJ_BoolText(conf.sr_canonical_near_flag) + ",";
   json += "\"sr_conflicted_flag\":" + PJ_BoolText(conf.sr_conflicted_flag) + ",";
   json += "\"decision_acceptance_posture\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_acceptance_posture) + "\",";
   json += "\"decision_reasoning_flags_csv\":\"" + PJ_PJ_EscapeJsonMini(conf.decision_reasoning_flags_csv) + "\",";

   json += "\"expected_stop_distance\":" + DoubleToString(conf.expected_stop_distance, 1) + ",";
   json += "\"expected_target_distance\":" + DoubleToString(conf.expected_target_distance, 1) + ",";
   json += "\"expected_rr_estimate\":" + DoubleToString(conf.expected_rr_estimate, 3) + ",";
   json += "\"adverse_excursion_risk_score\":" + DoubleToString(PJ_Clamp01(conf.adverse_excursion_risk_score), 3) + ",";
   json += "\"favorable_excursion_potential_score\":" + DoubleToString(PJ_Clamp01(conf.favorable_excursion_potential_score), 3) + ",";
   json += "\"execution_geometry_score\":" + DoubleToString(PJ_Clamp01(conf.execution_geometry_score), 3) + ",";
   json += "\"execution_geometry_label\":\"" + PJ_PJ_EscapeJsonMini(conf.execution_geometry_label) + "\",";
   json += "\"execution_geometry_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.execution_geometry_reason) + "\",";

   json += "\"final_permission\":" + PJ_BoolText(conf.final_permission) + ",";
   json += "\"final_decision\":\"" + PJ_PJ_EscapeJsonMini(PJ_DecisionText(eval.decision)) + "\",";
   json += "\"policy_result\":\"" + PJ_PJ_EscapeJsonMini(policy_result) + "\",";
   json += "\"policy_state\":\"" + PJ_PJ_EscapeJsonMini(policy_state) + "\",";
   json += "\"policy_state_reason\":\"" + PJ_PJ_EscapeJsonMini(policy_state_reason) + "\",";
   json += "\"failure_class\":\"" + PJ_PJ_EscapeJsonMini(failure_class) + "\",";
   json += "\"failure_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(failure_reason_summary) + "\",";
   json += "\"failure_severity\":" + DoubleToString(PJ_Clamp01(failure_severity), 3) + ",";
   json += "\"failure_basis\":\"" + PJ_PJ_EscapeJsonMini(failure_basis) + "\",";
   json += "\"council_summary\":\"" + PJ_PJ_EscapeJsonMini(council_summary) + "\",";
   json += "\"governor_state\":\"" + PJ_PJ_EscapeJsonMini(governor_state) + "\",";
   json += "\"evolution_version\":\"" + PJ_PJ_EscapeJsonMini(evolution_version) + "\",";
   json += "\"entry_quality\":\"\",";
   json += "\"exit_class\":\"\",";
   json += "\"rollback_signal_state\":\"" + PJ_PJ_EscapeJsonMini(rollback_signal_state) + "\",";
   json += "\"rollback_signal_score\":" + DoubleToString(PJ_Clamp01(rollback_signal_score), 3) + ",";
   json += "\"rollback_signal_reason\":\"" + PJ_PJ_EscapeJsonMini(rollback_signal_reason) + "\",";
   json += "\"failure_cluster_detected\":" + PJ_BoolText(failure_cluster_detected) + ",";
   json += "\"dominant_failure_class\":\"" + PJ_PJ_EscapeJsonMini(dominant_failure_class) + "\",";
   json += "\"dominant_failure_count\":" + IntegerToString(dominant_failure_count) + ",";
   json += "\"failure_cluster_score\":" + DoubleToString(PJ_Clamp01(failure_cluster_score), 3) + ",";
   json += "\"dominant_regime\":\"" + PJ_PJ_EscapeJsonMini(dominant_regime) + "\",";
   json += "\"regime_perf_summary\":\"" + PJ_PJ_EscapeJsonMini(regime_perf_summary) + "\",";
   json += "\"final_decision_reason\":\"" + PJ_PJ_EscapeJsonMini(conf.final_decision_reason) + "\",";
   json += "\"spread_points\":" + DoubleToString(m1.spread_points, 1);
   json += "}";
   return json;
}

bool JournalAppendDecisionV3(
   string decision_id,
   RuntimePlan &plan,
   string activeMode,
   TimeframeSnapshot &m1,
   RegimeClassification &regime,
   UnifiedDecisionConfidence &conf,
   RuntimeEvaluation &eval,
   string policy_result,
   string policy_state,
   string policy_state_reason,
   string failure_class,
   string failure_reason_summary,
   double failure_severity,
   string failure_basis,
   string council_summary,
   string governor_state,
   string evolution_version,
   string rollback_signal_state,
   double rollback_signal_score,
   string rollback_signal_reason,
   bool failure_cluster_detected,
   string dominant_failure_class,
   int dominant_failure_count,
   double failure_cluster_score,
   string dominant_regime,
   string regime_perf_summary,
   string &logMessage
)
{
   logMessage = "";

   string json = PJ_BuildDecisionJsonV3(
      decision_id,
      plan,
      activeMode,
      m1,
      regime,
      conf,
      eval,
      policy_result,
      policy_state,
      policy_state_reason,
      failure_class,
      failure_reason_summary,
      failure_severity,
      failure_basis,
      council_summary,
      governor_state,
      evolution_version,
      rollback_signal_state,
      rollback_signal_score,
      rollback_signal_reason,
      failure_cluster_detected,
      dominant_failure_class,
      dominant_failure_count,
      failure_cluster_score,
      dominant_regime,
      regime_perf_summary
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (decision v3)";
      return false;
   }

   logMessage = "Performance journal appended (decision v3)";
   return true;
}


//---------------------------------------------------------
// Phase 8A: Council Attribution Records (compact, analytics-friendly)
//---------------------------------------------------------
string PJ_BuildCouncilAttributionJson(
   string decision_id,
   CouncilRuntimeResult &council,
   string regime_label
)
{
   CouncilDecisionAttribution a = council.attribution;

   string json = "{";
   json += "\"record_type\":\"COUNCIL_ATTRIBUTION\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"COUNCIL_ATTRIBUTION\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"regime_label\":\"" + PJ_PJ_EscapeJsonMini(regime_label) + "\",";
   json += "\"final_decision\":\"" + PJ_PJ_EscapeJsonMini(CouncilDecisionToText(council.final_decision)) + "\",";
   json += "\"dominant_strategy_id\":\"" + PJ_PJ_EscapeJsonMini(a.dominant_strategy_id) + "\",";
   json += "\"dominant_strategy_role\":\"" + PJ_PJ_EscapeJsonMini(a.dominant_strategy_role) + "\",";
   json += "\"dominant_strategy_eligibility_state\":\"" + PJ_PJ_EscapeJsonMini(a.dominant_strategy_eligibility_state) + "\",";
   json += "\"aligned_strategy_count\":" + IntegerToString(a.aligned_count) + ",";
   json += "\"opposing_strategy_count\":" + IntegerToString(a.opposing_count) + ",";
   json += "\"neutral_strategy_count\":" + IntegerToString(a.neutral_count) + ",";
   json += "\"consensus_strength\":" + DoubleToString(PJ_Clamp01(a.consensus_strength), 3) + ",";
   json += "\"conflict_score\":" + DoubleToString(PJ_Clamp01(a.conflict_score), 3) + ",";
   json += "\"attribution_confidence\":" + DoubleToString(PJ_Clamp01(a.attribution_confidence), 3) + ",";
   json += "\"aligned_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(a.aligned_strategy_ids) + "\",";
   json += "\"opposing_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(a.opposing_strategy_ids) + "\",";
   json += "\"neutral_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(a.neutral_strategy_ids) + "\",";
   json += "\"strategies_compact\":\"" + PJ_PJ_EscapeJsonMini(a.strategies_compact) + "\",";
   json += "\"attribution_summary\":\"" + PJ_PJ_EscapeJsonMini(a.attribution_summary) + "\"";
   json += "}";
   return json;
}

bool JournalAppendCouncilAttribution(
   string decision_id,
   CouncilRuntimeResult &council,
   string regime_label,
   string &logMessage
)
{
   logMessage = "";

   if(StringLen(decision_id) <= 0 || !council.attribution.available)
   {
      logMessage = "Council attribution unavailable";
      return false;
   }

   string json = PJ_BuildCouncilAttributionJson(decision_id, council, regime_label);

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (council attribution)";
      return false;
   }

   logMessage = "Performance journal appended (council attribution)";
   return true;
}


bool PJ_ExtractDominantRoleEligFromCompact(string dominantId, string strategies_compact, string &outRole, string &outElig)
{
   outRole = "UNKNOWN_ROLE";
   outElig = "ELIGIBLE_UNKNOWN";

   dominantId = TrimString(dominantId);
   strategies_compact = TrimString(strategies_compact);
   if(StringLen(dominantId) <= 0 || StringLen(strategies_compact) <= 0) return false;

   string parts[];
   int n = StringSplit(strategies_compact, ';', parts);
   for(int i=0;i<n;i++)
   {
      string one = TrimString(parts[i]);
      if(StringLen(one) <= 0) continue;

      string cols[];
      int c = StringSplit(one, '|', cols);

      // v2: id|dir|align|role|elig|w|c|r
      if(c >= 5)
      {
         string sid = TrimString(cols[0]);
         if(sid != dominantId) continue;

         outRole = TrimString(cols[3]);
         outElig = TrimString(cols[4]);

         if(StringLen(outRole) <= 0) outRole = "UNKNOWN_ROLE";
         if(StringLen(outElig) <= 0) outElig = "ELIGIBLE_UNKNOWN";
         return true;
      }
   }
   return false;
}

void PJ_ComputeCouncilCorrectnessSummary(
   string result,
   string outcome_quality_summary,
   int aligned_count,
   int opposing_count,
   double &aligned_correctness_score,
   double &opposition_correctness_score,
   bool &dissent_credit_candidate,
   bool &misleading_alignment_candidate,
   string &summary
)
{
   result = TrimString(result);
   outcome_quality_summary = TrimString(outcome_quality_summary);

   bool isWin = (result == "WIN");
   bool isLoss = !isWin;

   bool isHQWin  = (StringFind(outcome_quality_summary, "HIGH_QUALITY_WIN") >= 0);
   bool isLQLoss = (StringFind(outcome_quality_summary, "LOW_QUALITY_LOSS") >= 0);
   bool isAGLoss = (StringFind(outcome_quality_summary, "ADVERSE_GEOMETRY_LOSS") >= 0);

   aligned_correctness_score = 0.0;
   opposition_correctness_score = 0.0;

   if(isWin)
      aligned_correctness_score = (isHQWin ? 1.0 : 0.7);

   if(isLoss)
      opposition_correctness_score = ((isLQLoss || isAGLoss) ? 1.0 : 0.7);

   dissent_credit_candidate = (opposing_count > 0 && isLoss);
   misleading_alignment_candidate = (aligned_count > 0 && isLoss);

   summary =
      "aligned_score=" + DoubleToString(aligned_correctness_score, 2) +
      " | opp_score=" + DoubleToString(opposition_correctness_score, 2) +
      " | dissent_credit=" + string(dissent_credit_candidate ? "true" : "false") +
      " | misleading_align=" + string(misleading_alignment_candidate ? "true" : "false");
}

// Outcome attribution record built at trade close (best-effort linkage via TRADE_OPEN metadata)
string PJ_BuildCouncilOutcomeAttributionJson(
   const TradeFeedbackRecord &fb,
   string dominant_strategy_id,
   int aligned_count,
   int opposing_count,
   int neutral_count,
   double attribution_confidence,
   string aligned_strategy_ids,
   string opposing_strategy_ids,
   string neutral_strategy_ids,
   string strategies_compact
)
{
   string json = "{";
   json += "\"record_type\":\"COUNCIL_OUTCOME_ATTRIBUTION\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"COUNCIL_ATTRIBUTION\",";
   json += "\"trade_event_type\":\"TRADE_CLOSE\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(TimeToString(fb.close_time, TIME_DATE | TIME_SECONDS)) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(fb.symbol) + "\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_id) + "\",";
   json += "\"correlated_decision_id\":\"" + PJ_PJ_EscapeJsonMini(fb.correlated_decision_id) + "\",";
   json += "\"plan_id\":\"" + PJ_PJ_EscapeJsonMini(fb.plan_id) + "\",";
   json += "\"active_mode\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_engine_mode) + "\",";
   json += "\"position_id\":" + PJ_U64(fb.position_id) + ",";
   json += "\"close_deal_id\":" + PJ_U64(fb.close_deal_id) + ",";
   json += "\"regime_label\":\"" + PJ_PJ_EscapeJsonMini(fb.regime_label) + "\",";
   json += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(fb.direction)) + "\",";
   json += "\"executed_direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(fb.direction)) + "\",";
   json += "\"trade_result\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeTradeResultText(fb.result)) + "\",";
   json += "\"result\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeTradeResultText(fb.result)) + "\",";
   json += "\"profit\":" + DoubleToString(fb.profit, 2) + ",";
   json += "\"failure_class\":\"" + PJ_PJ_EscapeJsonMini(fb.failure_class) + "\",";
   json += "\"outcome_quality_summary\":\"" + PJ_PJ_EscapeJsonMini(fb.outcome_quality_summary) + "\",";

   string domRole = "UNKNOWN_ROLE";
   string domElig = "ELIGIBLE_UNKNOWN";
   PJ_ExtractDominantRoleEligFromCompact(dominant_strategy_id, strategies_compact, domRole, domElig);

   double aligned_score = 0.0;
   double opp_score = 0.0;
   bool dissent_credit = false;
   bool misleading_align = false;
   string correctness_summary = "";
   PJ_ComputeCouncilCorrectnessSummary(fb.result, fb.outcome_quality_summary, aligned_count, opposing_count,
      aligned_score, opp_score, dissent_credit, misleading_align, correctness_summary);

   json += "\"dominant_strategy_id\":\"" + PJ_PJ_EscapeJsonMini(dominant_strategy_id) + "\",";
   json += "\"dominant_strategy_role\":\"" + PJ_PJ_EscapeJsonMini(domRole) + "\",";
   json += "\"dominant_strategy_eligibility_state\":\"" + PJ_PJ_EscapeJsonMini(domElig) + "\",";
   json += "\"aligned_correctness_score\":" + DoubleToString(PJ_Clamp01(aligned_score), 3) + ",";
   json += "\"opposition_correctness_score\":" + DoubleToString(PJ_Clamp01(opp_score), 3) + ",";
   json += "\"dissent_credit_candidate\":" + string(dissent_credit ? "true" : "false") + ",";
   json += "\"misleading_alignment_candidate\":" + string(misleading_align ? "true" : "false") + ",";
   json += "\"attribution_correctness_summary\":\"" + PJ_PJ_EscapeJsonMini(correctness_summary) + "\",";
   json += "\"aligned_strategy_count\":" + IntegerToString(aligned_count) + ",";
   json += "\"opposing_strategy_count\":" + IntegerToString(opposing_count) + ",";
   json += "\"neutral_strategy_count\":" + IntegerToString(neutral_count) + ",";
   json += "\"attribution_confidence\":" + DoubleToString(PJ_Clamp01(attribution_confidence), 3) + ",";
   json += "\"aligned_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(aligned_strategy_ids) + "\",";
   json += "\"opposing_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(opposing_strategy_ids) + "\",";
   json += "\"neutral_strategy_ids\":\"" + PJ_PJ_EscapeJsonMini(neutral_strategy_ids) + "\",";
   json += "\"strategies_compact\":\"" + PJ_PJ_EscapeJsonMini(strategies_compact) + "\"";
   json += "}";
   return json;
}

bool JournalAppendCouncilOutcomeAttribution(
   const TradeFeedbackRecord &fb,
   string dominant_strategy_id,
   int aligned_count,
   int opposing_count,
   int neutral_count,
   double attribution_confidence,
   string aligned_strategy_ids,
   string opposing_strategy_ids,
   string neutral_strategy_ids,
   string strategies_compact,
   string &logMessage
)
{
   logMessage = "";

   if(StringLen(fb.decision_id) <= 0 || fb.position_id == 0)
   {
      logMessage = "Council outcome attribution skipped (missing ids)";
      return false;
   }

   if(StringLen(dominant_strategy_id) <= 0 && StringLen(aligned_strategy_ids) <= 0 && StringLen(strategies_compact) <= 0)
   {
      logMessage = "Council outcome attribution skipped (no council meta)";
      return false;
   }

   string json = PJ_BuildCouncilOutcomeAttributionJson(
      fb,
      dominant_strategy_id,
      aligned_count,
      opposing_count,
      neutral_count,
      attribution_confidence,
      aligned_strategy_ids,
      opposing_strategy_ids,
      neutral_strategy_ids,
      strategies_compact
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (council outcome attribution)";
      return false;
   }

   logMessage = "Performance journal appended (council outcome attribution)";
   return true;
}

string PJ_BuildTradeJson(TradeFeedbackRecord &fb)
{
   string json = "{";
   json += "\"record_type\":\"TRADE\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"TRADE_LIFECYCLE\",";
   json += "\"trade_event_type\":\"TRADE_CLOSE\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_id) + "\",";
   json += "\"correlated_decision_id\":\"" + PJ_PJ_EscapeJsonMini(fb.correlated_decision_id) + "\",";
   json += "\"policy_state\":\"" + PJ_PJ_EscapeJsonMini(fb.policy_state) + "\",";
   json += "\"policy_state_reason\":\"" + PJ_PJ_EscapeJsonMini(fb.policy_state_reason) + "\",";
   json += "\"failure_class\":\"" + PJ_PJ_EscapeJsonMini(fb.failure_class) + "\",";
   json += "\"failure_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(fb.failure_reason_summary) + "\",";
   json += "\"failure_severity\":" + DoubleToString(PJ_Clamp01(fb.failure_severity), 3) + ",";
   json += "\"failure_basis\":\"" + PJ_PJ_EscapeJsonMini(fb.failure_basis) + "\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(TimeToString(fb.close_time, TIME_DATE | TIME_SECONDS)) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(fb.symbol) + "\",";
   json += "\"tf\":\"M1\",";
   json += "\"plan_id\":\"" + PJ_PJ_EscapeJsonMini(fb.plan_id) + "\",";
   json += "\"active_mode\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_engine_mode) + "\",";
   json += "\"regime_label\":\"" + PJ_PJ_EscapeJsonMini(fb.regime_label) + "\",";
   json += "\"regime_confidence\":" + DoubleToString(fb.regime_confidence, 3) + ",";
   json += "\"direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(fb.direction)) + "\",";
   json += "\"executed_direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(fb.direction)) + "\",";
   json += "\"position_id\":" + PJ_U64(fb.position_id) + ",";
   json += "\"entry_deal_id\":" + PJ_U64(fb.entry_deal_id) + ",";
   json += "\"entry_order_id\":" + PJ_U64(fb.entry_order_id) + ",";
   json += "\"close_deal_id\":" + PJ_U64(fb.close_deal_id) + ",";
   json += "\"correlation_method\":\"" + PJ_PJ_EscapeJsonMini(fb.correlation_method) + "\",";
   json += "\"correlation_quality\":" + DoubleToString(PJ_Clamp01(fb.correlation_quality), 3) + ",";
   json += "\"base_confidence_score_at_entry\":" + DoubleToString(PJ_Clamp01(fb.base_confidence_score_at_entry), 4) + ",";
   json += "\"confidence_score\":" + DoubleToString(PJ_Clamp01(fb.final_confidence_score_at_entry), 4) + ",";
   json += "\"policy_risk_score_at_entry\":" + DoubleToString(PJ_Clamp01(fb.policy_risk_score_at_entry), 4) + ",";
   json += "\"regime_fit_score_at_entry\":" + DoubleToString(PJ_Clamp01(fb.regime_fit_score_at_entry), 4) + ",";
   json += "\"learning_confidence_delta_at_entry\":" + DoubleToString(PJ_Clamp(fb.learning_confidence_delta_at_entry, -0.08, 0.08), 4) + ",";
   json += "\"learning_caution_delta_at_entry\":" + DoubleToString(PJ_Clamp01(fb.learning_caution_delta_at_entry), 4) + ",";
   json += "\"learning_state_code_at_entry\":\"" + PJ_PJ_EscapeJsonMini(fb.learning_state_code_at_entry) + "\",";
   json += "\"learning_evidence_count_at_entry\":" + IntegerToString(fb.learning_evidence_count_at_entry) + ",";
   json += "\"learning_evidence_threshold_met_at_entry\":" + PJ_BoolText(fb.learning_evidence_threshold_met_at_entry) + ",";
   json += "\"learning_zero_influence_due_to_insufficient_evidence_at_entry\":" + PJ_BoolText(fb.learning_zero_influence_due_to_insufficient_evidence_at_entry) + ",";
   json += "\"advisory_shaping_delta_at_entry\":" + DoubleToString(PJ_Clamp01(fb.advisory_shaping_delta_at_entry), 4) + ",";
   json += "\"advisory_shaping_delta_source\":\"" + PJ_PJ_EscapeJsonMini(fb.advisory_shaping_delta_source) + "\",";
   json += "\"decision_acceptance_posture_at_entry\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_acceptance_posture_at_entry) + "\",";
   json += "\"decision_reasoning_flags_at_entry\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_reasoning_flags_at_entry) + "\",";
   json += "\"requested_entry_price\":" + DoubleToString(fb.requested_entry_price, 5) + ",";
   json += "\"actual_entry_fill_price\":" + DoubleToString(fb.actual_entry_fill_price, 5) + ",";
   json += "\"exit_fill_price\":" + DoubleToString(fb.exit_fill_price, 5) + ",";
   json += "\"initial_stop_loss\":" + DoubleToString(fb.initial_stop_loss, 5) + ",";
   json += "\"initial_take_profit\":" + DoubleToString(fb.initial_take_profit, 5) + ",";
   json += "\"slippage_points\":" + DoubleToString(fb.slippage_points, 2) + ",";
   json += "\"requested_entry_price_source\":\"" + PJ_PJ_EscapeJsonMini(fb.requested_entry_price_source) + "\",";
   json += "\"actual_entry_fill_price_source\":\"" + PJ_PJ_EscapeJsonMini(fb.actual_entry_fill_price_source) + "\",";
   json += "\"exit_fill_price_source\":\"" + PJ_PJ_EscapeJsonMini(fb.exit_fill_price_source) + "\",";
   json += "\"initial_protection_source\":\"" + PJ_PJ_EscapeJsonMini(fb.initial_protection_source) + "\",";
   json += "\"slippage_source\":\"" + PJ_PJ_EscapeJsonMini(fb.slippage_source) + "\",";
   json += "\"stop_target_modifications_state\":\"" + PJ_PJ_EscapeJsonMini(fb.stop_target_modifications_state) + "\",";
   json += "\"max_favorable_excursion_points\":" + DoubleToString(fb.max_favorable_excursion_points, 2) + ",";
   json += "\"max_adverse_excursion_points\":" + DoubleToString(fb.max_adverse_excursion_points, 2) + ",";
   json += "\"excursion_source\":\"" + PJ_PJ_EscapeJsonMini(fb.excursion_source) + "\",";
   json += "\"support_resistance_confluence_state\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_support_resistance_state) + "\",";
   json += "\"canonical_level_state\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_canonical_level_state) + "\",";
   json += "\"sr_interaction_bucket\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_support_resistance_bucket) + "\",";
   json += "\"nearest_support_price\":" + DoubleToString(fb.linked_nearest_support_price, 5) + ",";
   json += "\"nearest_resistance_price\":" + DoubleToString(fb.linked_nearest_resistance_price, 5) + ",";
   json += "\"nearest_support_distance_points\":" + IntegerToString(fb.linked_nearest_support_distance_points) + ",";
   json += "\"nearest_resistance_distance_points\":" + IntegerToString(fb.linked_nearest_resistance_distance_points) + ",";
   json += "\"level_interaction_type\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_level_interaction_type) + "\",";
   json += "\"level_context_supported\":" + PJ_BoolText(fb.linked_level_context_supported) + ",";
   json += "\"level_context_obstructed\":" + PJ_BoolText(fb.linked_level_context_obstructed) + ",";
   json += "\"level_context_degraded\":" + PJ_BoolText(fb.linked_level_context_degraded) + ",";
   json += "\"support_resistance_observation_source\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_support_resistance_observation_source) + "\",";
   json += "\"sr_confluence_flag\":" + PJ_BoolText(fb.linked_sr_confluence_flag) + ",";
   json += "\"sr_rejection_risk_flag\":" + PJ_BoolText(fb.linked_sr_rejection_risk_flag) + ",";
   json += "\"sr_continuation_obstructed_flag\":" + PJ_BoolText(fb.linked_sr_continuation_obstructed_flag) + ",";
   json += "\"sr_canonical_near_flag\":" + PJ_BoolText(fb.linked_sr_canonical_near_flag) + ",";
   json += "\"sr_conflicted_flag\":" + PJ_BoolText(fb.linked_sr_conflicted_flag) + ",";
   json += "\"advisory_available\":" + PJ_BoolText(fb.linked_advisory_available) + ",";
   json += "\"advisory_eligible\":" + PJ_BoolText(fb.linked_advisory_eligible) + ",";
   json += "\"advisory_shadow_attached\":" + PJ_BoolText(fb.linked_advisory_shadow_attached) + ",";
   json += "\"advisory_state\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_state) + "\",";
   json += "\"advisory_outcome\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_outcome) + "\",";
   json += "\"advisory_attachment_state\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_attachment_state) + "\",";
   json += "\"advisory_gate_reason_code\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_gate_reason_code) + "\",";
   json += "\"advisory_ineligibility_reason_code\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_ineligibility_reason_code) + "\",";
   json += "\"advisory_block_class\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_block_class) + "\",";
   json += "\"advisory_usage_state\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_usage_state) + "\",";
   json += "\"advisory_zero_effect_reason\":\"" + PJ_PJ_EscapeJsonMini(fb.linked_advisory_zero_effect_reason) + "\",";
   json += "\"advisory_contradiction_flag\":" + PJ_BoolText(fb.linked_advisory_contradiction_flag) + ",";
   json += "\"advisory_relevance_score\":" + DoubleToString(PJ_Clamp01(fb.linked_advisory_relevance_score), 3) + ",";
   json += "\"final_permission\":true,";
   json += "\"final_decision\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(fb.direction)) + "\",";
   json += "\"policy_result\":\"\",";
   json += "\"entry_quality\":\"\",";
   json += "\"council_summary\":\"\",";
   json += "\"governor_state\":\"\",";
   json += "\"evolution_version\":\"\",";
   json += "\"trade_result\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeTradeResultText(fb.result)) + "\",";
   json += "\"result\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeTradeResultText(fb.result)) + "\",";
   json += "\"exit_class\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeTradeResultText(fb.result)) + "\",";
   json += "\"exit_reason\":\"" + PJ_PJ_EscapeJsonMini(fb.exit_reason_summary) + "\",";
   json += "\"profit\":" + DoubleToString(fb.profit, 2) + ",";
   json += "\"spread_points\":" + DoubleToString(fb.spread_points, 1);
   json += "}";
   return json;
}

bool JournalAppendTrade(TradeFeedbackRecord &fb, string &logMessage)
{
   logMessage = "";

   string json = PJ_BuildTradeJson(fb);

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (trade)";
      return false;
   }

   bool hasRequested = (StringLen(TrimString(fb.requested_entry_price_source)) > 0 &&
                        StringFind(TrimString(fb.requested_entry_price_source), "UNAVAILABLE") < 0);
   bool hasEntryFill = (StringLen(TrimString(fb.actual_entry_fill_price_source)) > 0 &&
                        StringFind(TrimString(fb.actual_entry_fill_price_source), "UNAVAILABLE") < 0);
   bool hasExitFill = (StringLen(TrimString(fb.exit_fill_price_source)) > 0 &&
                       StringFind(TrimString(fb.exit_fill_price_source), "UNAVAILABLE") < 0);
   bool hasInitialProtection = (StringLen(TrimString(fb.initial_protection_source)) > 0 &&
                                StringFind(TrimString(fb.initial_protection_source), "UNAVAILABLE") < 0);
   bool hasSlippage = (StringLen(TrimString(fb.slippage_source)) > 0 &&
                       StringFind(TrimString(fb.slippage_source), "UNAVAILABLE") < 0);
   bool hasNearestSupport = (fb.linked_nearest_support_price > 0.0 || fb.linked_nearest_support_distance_points >= 0);
   bool hasNearestResistance = (fb.linked_nearest_resistance_price > 0.0 || fb.linked_nearest_resistance_distance_points >= 0);
   bool hasAdvisoryReliability = (StringLen(TrimString(fb.linked_advisory_attachment_state)) > 0 &&
                                  fb.linked_advisory_attachment_state != "ADVISORY_NOT_EVALUATED");

   string statusJson = "{";
   statusJson += "\"status_surface\":\"TRADE_EVIDENCE_COMPLETENESS_STATUS\",";
   statusJson += "\"updated_at\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   statusJson += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(fb.decision_id) + "\",";
   statusJson += "\"position_id\":" + PJ_U64(fb.position_id) + ",";
   statusJson += "\"trade_result\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeTradeResultText(fb.result)) + "\",";
   statusJson += "\"requested_entry_price_captured\":" + PJ_BoolText(hasRequested) + ",";
   statusJson += "\"actual_entry_fill_captured\":" + PJ_BoolText(hasEntryFill) + ",";
   statusJson += "\"exit_fill_captured\":" + PJ_BoolText(hasExitFill) + ",";
   statusJson += "\"initial_protection_captured\":" + PJ_BoolText(hasInitialProtection) + ",";
   statusJson += "\"slippage_derived\":" + PJ_BoolText(hasSlippage) + ",";
   statusJson += "\"support_resistance_context_captured\":" + PJ_BoolText(StringLen(TrimString(fb.linked_support_resistance_state)) > 0) + ",";
   statusJson += "\"nearest_support_captured\":" + PJ_BoolText(hasNearestSupport) + ",";
   statusJson += "\"nearest_resistance_captured\":" + PJ_BoolText(hasNearestResistance) + ",";
   statusJson += "\"advisory_reliability_context_captured\":" + PJ_BoolText(hasAdvisoryReliability) + ",";
   statusJson += "\"decision_envelope_posture_captured\":" + PJ_BoolText(StringLen(TrimString(fb.decision_acceptance_posture_at_entry)) > 0) + ",";
   statusJson += "\"non_authoritative_notice\":\"Evidence/status only. Runtime execution authority unchanged.\"";
   statusJson += "}";
   PJ_WriteJsonTextFile(TRADE_EVIDENCE_STATUS_PATH, statusJson);

   logMessage = "Performance journal appended (trade)";
   return true;
}


//---------------------------------------------------------
// Trade Open correlation record (append-only)
//---------------------------------------------------------
string PJ_BuildTradeOpenJson(string decision_id, ulong entry_deal_id, ulong entry_order_id, ulong position_id)
{
   string json = "{";
   json += "\"record_type\":\"TRADE_OPEN\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"TRADE_LIFECYCLE\",";
   json += "\"trade_event_type\":\"TRADE_OPEN\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"entry_deal_id\":" + PJ_U64(entry_deal_id) + ",";
   json += "\"entry_order_id\":" + PJ_U64(entry_order_id) + ",";
   json += "\"position_id\":" + PJ_U64(position_id);
   json += "}";
   return json;
}

// v2: richer metadata for restart-safe correlation/analytics
string PJ_BuildTradeOpenJsonV2(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume
)
{
   string json = "{";
   json += "\"record_type\":\"TRADE_OPEN\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"TRADE_LIFECYCLE\",";
   json += "\"trade_event_type\":\"TRADE_OPEN\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"tf\":\"" + PJ_PJ_EscapeJsonMini(tf) + "\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"entry_deal_id\":" + PJ_U64(entry_deal_id) + ",";
   json += "\"entry_order_id\":" + PJ_U64(entry_order_id) + ",";
   json += "\"position_id\":" + PJ_U64(position_id) + ",";
   json += "\"magic\":" + IntegerToString((int)magic) + ",";
   json += "\"order_type\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(order_type)) + "\",";
   json += "\"executed_direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(order_type)) + "\",";
   json += "\"entry_time\":\"" + PJ_PJ_EscapeJsonMini(TimeToString(entry_time, TIME_DATE | TIME_SECONDS)) + "\",";
   json += "\"volume\":" + DoubleToString(volume, 2);
   json += "}";
   return json;
}

bool JournalAppendTradeOpen(string decision_id, ulong entry_deal_id, ulong entry_order_id, ulong position_id, string &logMessage)
{
   logMessage = "";

   string json = PJ_BuildTradeOpenJson(decision_id, entry_deal_id, entry_order_id, position_id);

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (trade_open)";
      return false;
   }

   logMessage = "Performance journal appended (trade_open)";
   return true;
}

bool JournalAppendTradeOpenV2(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   string &logMessage
)
{
   logMessage = "";

   string json = PJ_BuildTradeOpenJsonV2(
      decision_id, entry_deal_id, entry_order_id, position_id,
      magic, order_type, tf, entry_time, volume
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (trade_open v2)";
      return false;
   }

   logMessage = "Performance journal appended (trade_open v2)";
   return true;
}

string PJ_BuildTradeOpenJsonV3(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   string entry_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label
)
{
   // Backward-compatible wrapper: v3 -> v4 with missing fields defaulted
   return PJ_BuildTradeOpenJsonV4(
      decision_id,
      entry_deal_id,
      entry_order_id,
      position_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      0.0,
      0.0,
      strategy_regime_fit_score,
      decision_quality_score,
      entry_quality_label,
      "",
      "",
      strategy_regime_fit_label,
      decision_quality_label
   );
}

string PJ_BuildTradeOpenJsonV4(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double entry_edge_score,
   double follow_through_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   string entry_quality_label,
   string entry_edge_label,
   string follow_through_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label
)
{
   string json = "{";
   json += "\"record_type\":\"TRADE_OPEN\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"TRADE_LIFECYCLE\",";
   json += "\"trade_event_type\":\"TRADE_OPEN\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"decision_id\":\"" + PJ_PJ_EscapeJsonMini(decision_id) + "\",";
   json += "\"entry_deal_id\":" + PJ_U64(entry_deal_id) + ",";
   json += "\"entry_order_id\":" + PJ_U64(entry_order_id) + ",";
   json += "\"position_id\":" + PJ_U64(position_id) + ",";
   json += "\"magic\":" + IntegerToString((int)magic) + ",";
   json += "\"order_type\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(order_type)) + "\",";
   json += "\"executed_direction\":\"" + PJ_PJ_EscapeJsonMini(PJ_NormalizeDirectionText(order_type)) + "\",";
   json += "\"timeframe\":\"" + PJ_PJ_EscapeJsonMini(tf) + "\",";
   json += "\"entry_time\":\"" + PJ_PJ_EscapeJsonMini(TimeToString(entry_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS)) + "\",";
   json += "\"volume\":" + DoubleToString(volume, 2) + ",";

   json += "\"entry_quality_score\":" + DoubleToString(entry_quality_score, 3) + ",";
   json += "\"entry_edge_score\":" + DoubleToString(entry_edge_score, 3) + ",";
   json += "\"follow_through_quality_score\":" + DoubleToString(follow_through_quality_score, 3) + ",";
   json += "\"strategy_regime_fit_score\":" + DoubleToString(strategy_regime_fit_score, 3) + ",";
   json += "\"decision_quality_score\":" + DoubleToString(decision_quality_score, 3) + ",";

   json += "\"entry_quality_label\":\"" + PJ_PJ_EscapeJsonMini(entry_quality_label) + "\",";
   json += "\"entry_edge_label\":\"" + PJ_PJ_EscapeJsonMini(entry_edge_label) + "\",";
   json += "\"follow_through_quality_label\":\"" + PJ_PJ_EscapeJsonMini(follow_through_quality_label) + "\",";
   json += "\"strategy_regime_fit_label\":\"" + PJ_PJ_EscapeJsonMini(strategy_regime_fit_label) + "\",";
   json += "\"decision_quality_label\":\"" + PJ_PJ_EscapeJsonMini(decision_quality_label) + "\"";
   json += "}";
   return json;
}


string PJ_BuildTradeOpenJsonV5(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double entry_edge_score,
   double follow_through_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   double expected_rr_estimate,
   double execution_geometry_score,
   string execution_geometry_label,
   string entry_quality_label,
   string entry_edge_label,
   string follow_through_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   double requested_entry_price,
   double requested_stop_loss,
   double requested_take_profit,
   double actual_fill_price,
   double slippage_points,
   double base_confidence_score,
   double final_confidence_score,
   double policy_risk_score,
   double regime_fit_score,
   double learning_confidence_delta,
   double learning_caution_score,
   string learning_state_code,
   int learning_evidence_count,
   bool learning_evidence_threshold_met,
   bool learning_zero_influence_due_to_insufficient_evidence,
   double advisory_relevance_score,
   bool advisory_contradiction_flag,
   bool advisory_hold_bias_active,
   string support_resistance_confluence_state,
   string canonical_level_state,
   string sr_interaction_bucket,
   bool sr_confluence_flag,
   bool sr_rejection_risk_flag,
   bool sr_continuation_obstructed_flag,
   bool sr_canonical_near_flag,
   bool sr_conflicted_flag,
   double nearest_support_price,
   double nearest_resistance_price,
   int nearest_support_distance_points,
   int nearest_resistance_distance_points,
   string level_interaction_type,
   bool level_context_supported,
   bool level_context_obstructed,
   bool level_context_degraded,
   string support_resistance_observation_source,
   bool advisory_available,
   bool advisory_eligible,
   bool advisory_shadow_attached,
   AdvisoryEnvelopeFields &advisory,
   DecisionReasoningFields &decision_reasoning
)
{
   string json = PJ_BuildTradeOpenJsonV4(
      decision_id,
      entry_deal_id,
      entry_order_id,
      position_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      entry_edge_score,
      follow_through_quality_score,
      strategy_regime_fit_score,
      decision_quality_score,
      entry_quality_label,
      entry_edge_label,
      follow_through_quality_label,
      strategy_regime_fit_label,
      decision_quality_label
   );

   // Inject new v7A fields at end (keep JSON valid)
   // Replace trailing '}' with extra fields.
   int n = StringLen(json);
   if(n > 0 && StringGetCharacter(json, n - 1) == '}')
      json = StringSubstr(json, 0, n - 1);

   // Inject cached council attribution (Phase 8A/8B) if available.
   PJ_InjectCouncilAttributionFieldsIntoTradeOpenJson(decision_id, json);

   json += ",\"expected_rr_estimate\":" + DoubleToString(expected_rr_estimate, 3);
   json += ",\"execution_geometry_score\":" + DoubleToString(execution_geometry_score, 3);
   json += ",\"execution_geometry_label\":\"" + PJ_EscapeJsonMini(execution_geometry_label) + "\"";

   bool hasRequestedEntry = (requested_entry_price > 0.0);
   bool hasActualFill = (actual_fill_price > 0.0);
   bool hasInitialProtection = (requested_stop_loss > 0.0 || requested_take_profit > 0.0);
   bool canDeriveSlippage = (hasRequestedEntry && hasActualFill && slippage_points >= 0.0);
   string requestedEntrySource = (hasRequestedEntry ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   string actualFillSource = (hasActualFill ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   string initialProtectionSource = (hasInitialProtection ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   string slippageSource = (canDeriveSlippage ? "DERIVED_FROM_REQUEST_AND_FILL" : "UNAVAILABLE_NOT_DERIVABLE");

   json += ",\"requested_entry_price\":" + DoubleToString(requested_entry_price, 5);
   json += ",\"actual_entry_fill_price\":" + DoubleToString(actual_fill_price, 5);
   json += ",\"initial_stop_loss\":" + DoubleToString(requested_stop_loss, 5);
   json += ",\"initial_take_profit\":" + DoubleToString(requested_take_profit, 5);
   json += ",\"entry_slippage_points\":" + DoubleToString(MathMax(0.0, slippage_points), 2);
   json += ",\"requested_entry_price_source\":\"" + PJ_EscapeJsonMini(requestedEntrySource) + "\"";
   json += ",\"actual_entry_fill_price_source\":\"" + PJ_EscapeJsonMini(actualFillSource) + "\"";
   json += ",\"initial_protection_source\":\"" + PJ_EscapeJsonMini(initialProtectionSource) + "\"";
   json += ",\"entry_slippage_source\":\"" + PJ_EscapeJsonMini(slippageSource) + "\"";
   json += ",\"stop_target_modifications_state\":\"NOT_CAPTURED_IN_BOUNDED_SURFACES\"";
   json += ",\"max_favorable_excursion_points\":0.0";
   json += ",\"max_adverse_excursion_points\":0.0";
   json += ",\"excursion_source\":\"UNAVAILABLE_NOT_CAPTURED\"";

   bool hasSRContext = (StringLen(TrimString(support_resistance_confluence_state)) > 0 &&
                        TrimString(support_resistance_confluence_state) != "UNSET");
   bool hasAdvisoryContext = (advisory_relevance_score > 0.0 || advisory_contradiction_flag || advisory_hold_bias_active);
   string advisoryObservationSource = (hasAdvisoryContext ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   string supportResistanceObservationSource = (hasSRContext ? "DIRECT_OBSERVED" : "UNAVAILABLE_NOT_CAPTURED");
   string srObservationSourceOut = supportResistanceObservationSource;
   if(StringLen(TrimString(support_resistance_observation_source)) > 0)
      srObservationSourceOut = support_resistance_observation_source;
   json += ",\"base_confidence_score\":" + DoubleToString(PJ_Clamp01(base_confidence_score), 4);
   json += ",\"final_confidence_score\":" + DoubleToString(PJ_Clamp01(final_confidence_score), 4);
   json += ",\"confidence_delta_from_base\":" + DoubleToString(final_confidence_score - base_confidence_score, 4);
   json += ",\"policy_risk_score\":" + DoubleToString(PJ_Clamp01(policy_risk_score), 4);
   json += ",\"regime_fit_score\":" + DoubleToString(PJ_Clamp01(regime_fit_score), 4);
   json += ",\"learning_confidence_delta\":" + DoubleToString(PJ_Clamp(learning_confidence_delta, -0.08, 0.08), 4);
   json += ",\"learning_caution_score\":" + DoubleToString(PJ_Clamp01(learning_caution_score), 4);
   json += ",\"learning_state_code\":\"" + PJ_EscapeJsonMini(learning_state_code) + "\"";
   json += ",\"learning_evidence_count\":" + IntegerToString(learning_evidence_count);
   json += ",\"learning_evidence_threshold_met\":" + PJ_BoolText(learning_evidence_threshold_met);
   json += ",\"learning_zero_influence_due_to_insufficient_evidence\":" + PJ_BoolText(learning_zero_influence_due_to_insufficient_evidence);
   json += ",\"advisory_relevance_score\":" + DoubleToString(PJ_Clamp01(advisory_relevance_score), 4);
   json += ",\"advisory_contradiction_flag\":" + PJ_BoolText(advisory_contradiction_flag);
   json += ",\"advisory_hold_bias_active\":" + PJ_BoolText(advisory_hold_bias_active);
   json += ",\"support_resistance_confluence_state\":\"" + PJ_EscapeJsonMini(support_resistance_confluence_state) + "\"";
   json += ",\"canonical_level_state\":\"" + PJ_EscapeJsonMini(canonical_level_state) + "\"";
   json += ",\"sr_interaction_bucket\":\"" + PJ_EscapeJsonMini(sr_interaction_bucket) + "\"";
   json += ",\"sr_confluence_flag\":" + PJ_BoolText(sr_confluence_flag);
   json += ",\"sr_rejection_risk_flag\":" + PJ_BoolText(sr_rejection_risk_flag);
   json += ",\"sr_continuation_obstructed_flag\":" + PJ_BoolText(sr_continuation_obstructed_flag);
   json += ",\"sr_canonical_near_flag\":" + PJ_BoolText(sr_canonical_near_flag);
   json += ",\"sr_conflicted_flag\":" + PJ_BoolText(sr_conflicted_flag);
   json += ",\"nearest_support_price\":" + DoubleToString(nearest_support_price, 5);
   json += ",\"nearest_resistance_price\":" + DoubleToString(nearest_resistance_price, 5);
   json += ",\"nearest_support_distance_points\":" + IntegerToString(nearest_support_distance_points);
   json += ",\"nearest_resistance_distance_points\":" + IntegerToString(nearest_resistance_distance_points);
   json += ",\"level_interaction_type\":\"" + PJ_EscapeJsonMini(level_interaction_type) + "\"";
   json += ",\"level_context_supported\":" + PJ_BoolText(level_context_supported);
   json += ",\"level_context_obstructed\":" + PJ_BoolText(level_context_obstructed);
   json += ",\"level_context_degraded\":" + PJ_BoolText(level_context_degraded);
   json += ",\"advisory_available\":" + PJ_BoolText(advisory_available);
   json += ",\"advisory_eligible\":" + PJ_BoolText(advisory_eligible);
   json += ",\"advisory_shadow_attached\":" + PJ_BoolText(advisory_shadow_attached);
   json += ",\"advisory_state\":\"" + PJ_EscapeJsonMini(advisory.advisory_state) + "\"";
   json += ",\"advisory_outcome\":\"" + PJ_EscapeJsonMini(advisory.advisory_outcome) + "\"";
   json += ",\"advisory_attachment_state\":\"" + PJ_EscapeJsonMini(advisory.advisory_attachment_state) + "\"";
   json += ",\"advisory_gate_reason_code\":\"" + PJ_EscapeJsonMini(advisory.advisory_gate_reason_code) + "\"";
   json += ",\"advisory_ineligibility_reason_code\":\"" + PJ_EscapeJsonMini(advisory.advisory_ineligibility_reason_code) + "\"";
   json += ",\"advisory_block_class\":\"" + PJ_EscapeJsonMini(advisory.advisory_block_class) + "\"";
   json += ",\"advisory_usage_state\":\"" + PJ_EscapeJsonMini(advisory.advisory_usage_state) + "\"";
   json += ",\"advisory_zero_effect_reason\":\"" + PJ_EscapeJsonMini(advisory.advisory_zero_effect_reason) + "\"";
   json += ",\"decision_acceptance_posture\":\"" + PJ_EscapeJsonMini(decision_reasoning.decision_acceptance_posture) + "\"";
   json += ",\"decision_reasoning_flags_csv\":\"" + PJ_EscapeJsonMini(decision_reasoning.decision_reasoning_flags_csv) + "\"";
   json += ",\"advisory_observation_source\":\"" + PJ_EscapeJsonMini(advisoryObservationSource) + "\"";
   json += ",\"support_resistance_observation_source\":\"" + PJ_EscapeJsonMini(srObservationSourceOut) + "\"";

   json += ",\"validation_semantics_version\":\"H3_EXECUTION_VALIDATION_V1\"";
   json += ",\"final_blocking_layer\":\"\"";
   json += ",\"final_block_reason_code\":\"\"";
   json += ",\"execution_path\":\"TRADE_OPEN_EXECUTED\"";
   json += ",\"validation_outcome_class\":\"EXECUTED_TRADE_OPEN\"";
   json += ",\"validation_rejection_family\":\"\"";
   json += "}";

   return json;
}

bool JournalAppendTradeOpenV5(
   RuntimePlan &plan,
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double entry_edge_score,
   double follow_through_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   double expected_rr_estimate,
   double execution_geometry_score,
   string execution_geometry_label,
   string entry_quality_label,
   string entry_edge_label,
   string follow_through_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   double requested_entry_price,
   double requested_stop_loss,
   double requested_take_profit,
   double actual_fill_price,
   double slippage_points,
   double base_confidence_score,
   double final_confidence_score,
   double policy_risk_score,
   double regime_fit_score,
   double learning_confidence_delta,
   double learning_caution_score,
   string learning_state_code,
   int learning_evidence_count,
   bool learning_evidence_threshold_met,
   bool learning_zero_influence_due_to_insufficient_evidence,
   double advisory_relevance_score,
   bool advisory_contradiction_flag,
   bool advisory_hold_bias_active,
   string support_resistance_confluence_state,
   string canonical_level_state,
   string sr_interaction_bucket,
   bool sr_confluence_flag,
   bool sr_rejection_risk_flag,
   bool sr_continuation_obstructed_flag,
   bool sr_canonical_near_flag,
   bool sr_conflicted_flag,
   double nearest_support_price,
   double nearest_resistance_price,
   int nearest_support_distance_points,
   int nearest_resistance_distance_points,
   string level_interaction_type,
   bool level_context_supported,
   bool level_context_obstructed,
   bool level_context_degraded,
   string support_resistance_observation_source,
   bool advisory_available,
   bool advisory_eligible,
   bool advisory_shadow_attached,
   AdvisoryEnvelopeFields &advisory,
   DecisionReasoningFields &decision_reasoning
)
{
   string record =
      PJ_BuildTradeOpenJsonV5(
         decision_id,
         entry_deal_id,
         entry_order_id,
         position_id,
         magic,
         order_type,
         tf,
         entry_time,
         volume,
         entry_quality_score,
         entry_edge_score,
         follow_through_quality_score,
         strategy_regime_fit_score,
         decision_quality_score,
         expected_rr_estimate,
         execution_geometry_score,
         execution_geometry_label,
         entry_quality_label,
         entry_edge_label,
         follow_through_quality_label,
         strategy_regime_fit_label,
         decision_quality_label,
         requested_entry_price,
         requested_stop_loss,
         requested_take_profit,
         actual_fill_price,
         slippage_points,
         base_confidence_score,
         final_confidence_score,
         policy_risk_score,
         regime_fit_score,
         learning_confidence_delta,
         learning_caution_score,
         learning_state_code,
         learning_evidence_count,
         learning_evidence_threshold_met,
         learning_zero_influence_due_to_insufficient_evidence,
         advisory_relevance_score,
         advisory_contradiction_flag,
         advisory_hold_bias_active,
         support_resistance_confluence_state,
         canonical_level_state,
         sr_interaction_bucket,
         sr_confluence_flag,
         sr_rejection_risk_flag,
         sr_continuation_obstructed_flag,
         sr_canonical_near_flag,
         sr_conflicted_flag,
         nearest_support_price,
         nearest_resistance_price,
         nearest_support_distance_points,
         nearest_resistance_distance_points,
         level_interaction_type,
         level_context_supported,
         level_context_obstructed,
         level_context_degraded,
         support_resistance_observation_source,
         advisory_available,
         advisory_eligible,
         advisory_shadow_attached,
         advisory,
         decision_reasoning
      );

   return PJ_AppendLine(PERF_JOURNAL_PATH, record);
}

bool JournalAppendTradeOpenV3(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   string entry_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   string &logMessage
)
{
   return JournalAppendTradeOpenV4(
      decision_id,
      entry_deal_id,
      entry_order_id,
      position_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      0.0,
      0.0,
      strategy_regime_fit_score,
      decision_quality_score,
      entry_quality_label,
      "",
      "",
      strategy_regime_fit_label,
      decision_quality_label,
      logMessage
   );
}

bool JournalAppendTradeOpenV4(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   ulong position_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double entry_edge_score,
   double follow_through_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   string entry_quality_label,
   string entry_edge_label,
   string follow_through_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   string &logMessage
)
{
   string json = PJ_BuildTradeOpenJsonV4(
      decision_id,
      entry_deal_id,
      entry_order_id,
      position_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      entry_edge_score,
      follow_through_quality_score,
      strategy_regime_fit_score,
      decision_quality_score,
      entry_quality_label,
      entry_edge_label,
      follow_through_quality_label,
      strategy_regime_fit_label,
      decision_quality_label
   );

   if(!PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json, logMessage))
   {
      logMessage = "Performance journal append failed (trade open v4)";
      return false;
   }
   logMessage = "Performance journal appended (trade open v4)";
   return true;
}


//---------------------------------------------------------
// Shadow evaluation records (foundation only)
//---------------------------------------------------------
string PJ_BuildShadowDecisionJson(
   string shadow_decision_id,
   string shadow_plan_fingerprint,
   string shadow_decision_result,
   double shadow_confidence_score,
   string shadow_reason_summary,
   string shadow_vs_production_relation,
   string production_decision_id
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"shadow_plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(shadow_plan_fingerprint) + "\",";
   json += "\"shadow_decision_result\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_result) + "\",";
   json += "\"shadow_confidence_score\":" + DoubleToString(PJ_Clamp01(shadow_confidence_score), 3) + ",";
   json += "\"shadow_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(shadow_reason_summary) + "\",";
   json += "\"shadow_vs_production_relation\":\"" + PJ_PJ_EscapeJsonMini(shadow_vs_production_relation) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\"";
   json += "}";
   return json;
}

bool JournalAppendShadowDecision(
   string shadow_decision_id,
   string shadow_plan_fingerprint,
   string shadow_decision_result,
   double shadow_confidence_score,
   string shadow_reason_summary,
   string shadow_vs_production_relation,
   string production_decision_id,
   string &logMessage
)
{
   logMessage = "";

   string json = PJ_BuildShadowDecisionJson(
      shadow_decision_id,
      shadow_plan_fingerprint,
      shadow_decision_result,
      shadow_confidence_score,
      shadow_reason_summary,
      shadow_vs_production_relation,
      production_decision_id
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json + "\n"))
   {
      logMessage = "Performance journal append failed (shadow)";
      return false;
   }

   logMessage = "Performance journal appended (shadow)";
   return true;
}



//---------------------------------------------------------
// Shadow replay journaling (Phase 5A)
//---------------------------------------------------------
string PJ_BuildShadowDecisionReplayJson(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   bool shadow_final_permission,
   string shadow_reason
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_DECISION\",";
   json += "\"timestamp\":\"" + PJ_NowAsText() + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"shadow_plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(shadow_plan_fingerprint) + "\",";
   json += "\"shadow_mode\":\"" + PJ_PJ_EscapeJsonMini(shadow_mode) + "\",";
   json += "\"shadow_decision\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision) + "\",";
   json += "\"shadow_direction\":\"" + PJ_PJ_EscapeJsonMini(shadow_direction) + "\",";
   json += "\"shadow_confidence_score\":" + DoubleToString(PJ_Clamp01(shadow_confidence), 3) + ",";
   json += "\"shadow_raw_signal_score\":" + DoubleToString(shadow_raw_signal, 3) + ",";
   json += "\"shadow_regime_fit_score\":" + DoubleToString(PJ_Clamp01(shadow_regime_fit), 3) + ",";
   json += "\"shadow_final_permission\":" + string(shadow_final_permission ? "true" : "false") + ",";
   json += "\"shadow_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(shadow_reason) + "\"";
   json += "}";
   return json;
}

bool JournalAppendShadowDecisionReplay(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   bool shadow_final_permission,
   string shadow_reason,
   string &logMessage
)
{
   logMessage = "";
   string json = PJ_BuildShadowDecisionReplayJson(
      shadow_decision_id,
      production_decision_id,
      shadow_plan_fingerprint,
      shadow_mode,
      shadow_decision,
      shadow_direction,
      shadow_confidence,
      shadow_raw_signal,
      shadow_regime_fit,
      shadow_final_permission,
      shadow_reason
   );

   bool ok = PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json);
   logMessage = "Journal | SHADOW_DECISION | ok=" + string(ok ? "true" : "false");
   return ok;
}

string PJ_BuildShadowComparisonJson(
   string shadow_decision_id,
   string production_decision_id,
   string relation_class,
   bool agreement,
   double confidence_delta,
   int permission_delta,
   string comparison_summary,
   string comparison_basis
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_COMPARISON\",";
   json += "\"timestamp\":\"" + PJ_NowAsText() + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"relation_class\":\"" + PJ_PJ_EscapeJsonMini(relation_class) + "\",";
   json += "\"decision_agreement\":" + string(agreement ? "true" : "false") + ",";
   json += "\"confidence_delta\":" + DoubleToString(confidence_delta, 3) + ",";
   json += "\"permission_delta\":" + IntegerToString(permission_delta) + ",";
   json += "\"comparison_summary\":\"" + PJ_PJ_EscapeJsonMini(comparison_summary) + "\",";
   json += "\"comparison_basis\":\"" + PJ_PJ_EscapeJsonMini(comparison_basis) + "\"";
   json += "}";
   return json;
}

bool JournalAppendShadowComparison(
   string shadow_decision_id,
   string production_decision_id,
   string relation_class,
   bool agreement,
   double confidence_delta,
   int permission_delta,
   string comparison_summary,
   string comparison_basis,
   string &logMessage
)
{
   logMessage = "";
   string json = PJ_BuildShadowComparisonJson(
      shadow_decision_id,
      production_decision_id,
      relation_class,
      agreement,
      confidence_delta,
      permission_delta,
      comparison_summary,
      comparison_basis
   );

   bool ok = PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json);
   logMessage = "Journal | SHADOW_COMPARISON | ok=" + string(ok ? "true" : "false");
   return ok;
}




//---------------------------------------------------------
// Shadow Replay v1 (Policy Mirroring extensions)
//---------------------------------------------------------
string PJ_BuildShadowDecisionReplayJsonV2(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   bool shadow_final_permission,
   bool shadow_policy_permission,
   string shadow_policy_reason,
   string shadow_policy_state,
   string shadow_reason
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_DECISION\",";
   json += "\"timestamp\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"shadow_plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(shadow_plan_fingerprint) + "\",";
   json += "\"shadow_mode\":\"" + PJ_PJ_EscapeJsonMini(shadow_mode) + "\",";
   json += "\"shadow_decision\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision) + "\",";
   json += "\"shadow_direction\":\"" + PJ_PJ_EscapeJsonMini(shadow_direction) + "\",";
   json += "\"shadow_confidence_score\":" + DoubleToString(shadow_confidence, 3) + ",";
   json += "\"shadow_raw_signal_score\":" + DoubleToString(shadow_raw_signal, 3) + ",";
   json += "\"shadow_regime_fit_score\":" + DoubleToString(shadow_regime_fit, 3) + ",";
   json += "\"shadow_policy_permission\":" + (shadow_policy_permission ? "true" : "false") + ",";
   json += "\"shadow_policy_reason\":\"" + PJ_PJ_EscapeJsonMini(shadow_policy_reason) + "\",";
   json += "\"shadow_policy_state\":\"" + PJ_PJ_EscapeJsonMini(shadow_policy_state) + "\",";
   json += "\"shadow_final_permission\":" + (shadow_final_permission ? "true" : "false") + ",";
   json += "\"shadow_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(shadow_reason) + "\"";
   json += "}\n";
   return json;
}



bool JournalAppendShadowDecisionReplayV3(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   double shadow_entry_quality_score,
   double shadow_strategy_regime_fit_score,
   double shadow_decision_quality_score,
   string shadow_entry_quality_label,
   string shadow_strategy_regime_fit_label,
   string shadow_decision_quality_label,
   bool shadow_final_permission,
   bool shadow_policy_permission,
   string shadow_policy_reason,
   string shadow_policy_state,
   string shadow_reason_summary,
   string &logMessage
)
{
   // Backward-compatible wrapper: v3 -> v4 with missing fields defaulted
   return JournalAppendShadowDecisionReplayV4(
      shadow_decision_id,
      production_decision_id,
      shadow_plan_fingerprint,
      shadow_mode,
      shadow_decision,
      shadow_direction,
      shadow_confidence,
      shadow_raw_signal,
      shadow_regime_fit,
      shadow_entry_quality_score,
      0.0,
      0.0,
      shadow_strategy_regime_fit_score,
      shadow_decision_quality_score,
      shadow_entry_quality_label,
      "",
      "",
      shadow_strategy_regime_fit_label,
      shadow_decision_quality_label,
      shadow_final_permission,
      shadow_policy_permission,
      shadow_policy_reason,
      shadow_policy_state,
      shadow_reason_summary,
      logMessage
   );
}

bool JournalAppendShadowDecisionReplayV4(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   double shadow_entry_quality_score,
   double shadow_entry_edge_score,
   double shadow_follow_through_quality_score,
   double shadow_strategy_regime_fit_score,
   double shadow_decision_quality_score,
   string shadow_entry_quality_label,
   string shadow_entry_edge_label,
   string shadow_follow_through_quality_label,
   string shadow_strategy_regime_fit_label,
   string shadow_decision_quality_label,
   bool shadow_final_permission,
   bool shadow_policy_permission,
   string shadow_policy_reason,
   string shadow_policy_state,
   string shadow_reason_summary,
   string &logMessage
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_DECISION\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"shadow_plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(shadow_plan_fingerprint) + "\",";
   json += "\"shadow_mode\":\"" + PJ_PJ_EscapeJsonMini(shadow_mode) + "\",";
   json += "\"shadow_decision\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision) + "\",";
   json += "\"shadow_direction\":\"" + PJ_PJ_EscapeJsonMini(shadow_direction) + "\",";
   json += "\"shadow_confidence_score\":" + DoubleToString(shadow_confidence, 3) + ",";
   json += "\"shadow_raw_signal_score\":" + DoubleToString(shadow_raw_signal, 3) + ",";
   json += "\"shadow_regime_fit_score\":" + DoubleToString(shadow_regime_fit, 3) + ",";

   json += "\"shadow_entry_quality_score\":" + DoubleToString(shadow_entry_quality_score, 3) + ",";
   json += "\"shadow_entry_edge_score\":" + DoubleToString(shadow_entry_edge_score, 3) + ",";
   json += "\"shadow_follow_through_quality_score\":" + DoubleToString(shadow_follow_through_quality_score, 3) + ",";
   json += "\"shadow_strategy_regime_fit_score\":" + DoubleToString(shadow_strategy_regime_fit_score, 3) + ",";
   json += "\"shadow_decision_quality_score\":" + DoubleToString(shadow_decision_quality_score, 3) + ",";

   json += "\"shadow_entry_quality_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_entry_quality_label) + "\",";
   json += "\"shadow_entry_edge_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_entry_edge_label) + "\",";
   json += "\"shadow_follow_through_quality_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_follow_through_quality_label) + "\",";
   json += "\"shadow_strategy_regime_fit_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_strategy_regime_fit_label) + "\",";
   json += "\"shadow_decision_quality_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_quality_label) + "\",";

   json += "\"shadow_final_permission\":" + (shadow_final_permission ? "true" : "false") + ",";
   json += "\"shadow_policy_permission\":" + (shadow_policy_permission ? "true" : "false") + ",";
   json += "\"shadow_policy_reason\":\"" + PJ_PJ_EscapeJsonMini(shadow_policy_reason) + "\",";
   json += "\"shadow_policy_state\":\"" + PJ_PJ_EscapeJsonMini(shadow_policy_state) + "\",";
   json += "\"shadow_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(shadow_reason_summary) + "\"";
   json += "}";

   if(!PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json, logMessage))
   {
      logMessage = "Performance journal append failed (shadow decision v4)";
      return false;
   }

   logMessage = "Performance journal appended (shadow decision v4)";
   return true;
}


bool JournalAppendShadowDecisionReplayV5(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   double shadow_entry_quality_score,
   double shadow_entry_edge_score,
   double shadow_follow_through_quality_score,
   double shadow_strategy_regime_fit_score,
   double shadow_decision_quality_score,
   double shadow_expected_rr_estimate,
   double shadow_execution_geometry_score,
   string shadow_execution_geometry_label,
   string shadow_entry_quality_label,
   string shadow_entry_edge_label,
   string shadow_follow_through_quality_label,
   string shadow_strategy_regime_fit_label,
   string shadow_decision_quality_label,
   bool shadow_final_permission,
   bool shadow_policy_permission,
   string shadow_policy_reason,
   string shadow_policy_state,
   string shadow_reason_summary,
   string &logMessage
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_DECISION\",";
   json += "\"timestamp\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"shadow_plan_fingerprint\":\"" + PJ_PJ_EscapeJsonMini(shadow_plan_fingerprint) + "\",";
   json += "\"shadow_mode\":\"" + PJ_PJ_EscapeJsonMini(shadow_mode) + "\",";
   json += "\"shadow_decision\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision) + "\",";
   json += "\"shadow_direction\":\"" + PJ_PJ_EscapeJsonMini(shadow_direction) + "\",";
   json += "\"shadow_confidence_score\":" + DoubleToString(shadow_confidence, 3) + ",";
   json += "\"shadow_raw_signal_score\":" + DoubleToString(shadow_raw_signal, 3) + ",";
   json += "\"shadow_regime_fit_score\":" + DoubleToString(shadow_regime_fit, 3) + ",";
   json += "\"shadow_entry_quality_score\":" + DoubleToString(shadow_entry_quality_score, 3) + ",";
   json += "\"shadow_entry_edge_score\":" + DoubleToString(shadow_entry_edge_score, 3) + ",";
   json += "\"shadow_follow_through_quality_score\":" + DoubleToString(shadow_follow_through_quality_score, 3) + ",";
   json += "\"shadow_strategy_regime_fit_score\":" + DoubleToString(shadow_strategy_regime_fit_score, 3) + ",";
   json += "\"shadow_decision_quality_score\":" + DoubleToString(shadow_decision_quality_score, 3) + ",";
   json += "\"shadow_expected_rr_estimate\":" + DoubleToString(shadow_expected_rr_estimate, 3) + ",";
   json += "\"shadow_execution_geometry_score\":" + DoubleToString(shadow_execution_geometry_score, 3) + ",";
   json += "\"shadow_execution_geometry_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_execution_geometry_label) + "\",";
   json += "\"shadow_entry_quality_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_entry_quality_label) + "\",";
   json += "\"shadow_entry_edge_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_entry_edge_label) + "\",";
   json += "\"shadow_follow_through_quality_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_follow_through_quality_label) + "\",";
   json += "\"shadow_strategy_regime_fit_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_strategy_regime_fit_label) + "\",";
   json += "\"shadow_decision_quality_label\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_quality_label) + "\",";
   json += "\"shadow_final_permission\":" + (shadow_final_permission ? "true" : "false") + ",";
   json += "\"shadow_policy_permission\":" + (shadow_policy_permission ? "true" : "false") + ",";
   json += "\"shadow_policy_reason\":\"" + PJ_PJ_EscapeJsonMini(shadow_policy_reason) + "\",";
   json += "\"shadow_policy_state\":\"" + PJ_PJ_EscapeJsonMini(shadow_policy_state) + "\",";
   json += "\"shadow_reason_summary\":\"" + PJ_PJ_EscapeJsonMini(shadow_reason_summary) + "\"";
   json += "}";

   if(!PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json, logMessage))
   {
      logMessage = "Performance journal append failed (shadow decision v5)";
      return false;
   }
   return true;
}

bool JournalAppendShadowDecisionReplayV2(
   string shadow_decision_id,
   string production_decision_id,
   string shadow_plan_fingerprint,
   string shadow_mode,
   string shadow_decision,
   string shadow_direction,
   double shadow_confidence,
   double shadow_raw_signal,
   double shadow_regime_fit,
   bool shadow_final_permission,
   bool shadow_policy_permission,
   string shadow_policy_reason,
   string shadow_policy_state,
   string shadow_reason,
   string &logMessage
)
{

// Backward-compatible wrapper
return JournalAppendShadowDecisionReplayV3(
   shadow_decision_id,
   production_decision_id,
   shadow_plan_fingerprint,
   shadow_mode,
   shadow_decision,
   shadow_direction,
   shadow_confidence,
   shadow_raw_signal,
   shadow_regime_fit,
   0.0, 0.0, 0.0,
   "", "", "",
   shadow_final_permission,
   shadow_policy_permission,
   shadow_policy_reason,
   shadow_policy_state,
   shadow_reason,
   logMessage
);

}

string PJ_BuildShadowComparisonJsonV2(
   string shadow_decision_id,
   string production_decision_id,
   string relation_class,
   bool decision_agreement,
   double confidence_delta,
   int permission_delta,
   int shadow_permission_delta_vs_production,
   string comparison_summary,
   string comparison_basis
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_COMPARISON\",";
   json += "\"timestamp\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"relation_class\":\"" + PJ_PJ_EscapeJsonMini(relation_class) + "\",";
   json += "\"decision_agreement\":" + (decision_agreement ? "true" : "false") + ",";
   json += "\"confidence_delta\":" + DoubleToString(confidence_delta, 3) + ",";
   json += "\"permission_delta\":" + IntegerToString(permission_delta) + ",";
   json += "\"shadow_permission_delta_vs_production\":" + IntegerToString(shadow_permission_delta_vs_production) + ",";
   json += "\"comparison_summary\":\"" + PJ_PJ_EscapeJsonMini(comparison_summary) + "\",";
   json += "\"comparison_basis\":\"" + PJ_PJ_EscapeJsonMini(comparison_basis) + "\"";
   json += "}\n";
   return json;
}



bool JournalAppendShadowComparisonV3(
   string production_decision_id,
   string shadow_decision_id,
   string production_decision,
   string shadow_decision,
   string relation_class,
   double confidence_delta,
   int permission_delta,
   int shadow_permission_delta_vs_production,
   double entry_quality_delta,
   double regime_fit_delta,
   double decision_quality_delta,
   string comparison_summary,
   string &logMessage
)
{
   // Backward-compatible wrapper: v3 -> v4 with missing deltas defaulted
   return JournalAppendShadowComparisonV4(
      production_decision_id,
      shadow_decision_id,
      production_decision,
      shadow_decision,
      relation_class,
      confidence_delta,
      permission_delta,
      shadow_permission_delta_vs_production,
      entry_quality_delta,
      0.0,
      0.0,
      regime_fit_delta,
      decision_quality_delta,
      comparison_summary,
      logMessage
   );
}

bool JournalAppendShadowComparisonV4(
   string production_decision_id,
   string shadow_decision_id,
   string production_decision,
   string shadow_decision,
   string relation_class,
   double confidence_delta,
   int permission_delta,
   int shadow_permission_delta_vs_production,
   double entry_quality_delta,
   double entry_edge_delta,
   double follow_through_quality_delta,
   double regime_fit_delta,
   double decision_quality_delta,
   string comparison_summary,
   string &logMessage
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_COMPARISON\",";
   json += "\"ts\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision\":\"" + PJ_PJ_EscapeJsonMini(production_decision) + "\",";
   json += "\"shadow_decision\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision) + "\",";
   json += "\"relation_class\":\"" + PJ_PJ_EscapeJsonMini(relation_class) + "\",";
   json += "\"confidence_delta\":" + DoubleToString(confidence_delta, 3) + ",";
   json += "\"permission_delta\":" + IntegerToString(permission_delta) + ",";
   json += "\"shadow_permission_delta_vs_production\":" + IntegerToString(shadow_permission_delta_vs_production) + ",";
   json += "\"entry_quality_delta\":" + DoubleToString(entry_quality_delta, 3) + ",";
   json += "\"entry_edge_delta\":" + DoubleToString(entry_edge_delta, 3) + ",";
   json += "\"follow_through_quality_delta\":" + DoubleToString(follow_through_quality_delta, 3) + ",";
   json += "\"regime_fit_delta\":" + DoubleToString(regime_fit_delta, 3) + ",";
   json += "\"decision_quality_delta\":" + DoubleToString(decision_quality_delta, 3) + ",";
   json += "\"comparison_summary\":\"" + PJ_PJ_EscapeJsonMini(comparison_summary) + "\"";
   json += "}";

   if(!PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json, logMessage))
   {
      logMessage = "Performance journal append failed (shadow comparison v4)";
      return false;
   }

   logMessage = "Performance journal appended (shadow comparison v4)";
   return true;
}


bool JournalAppendShadowComparisonV5(
   string shadow_decision_id,
   string production_decision_id,
   string relation_class,
   bool agreement,
   string production_decision,
   string shadow_decision,
   string production_direction,
   string shadow_direction,
   double confidence_delta,
   int permission_delta,
   double entry_quality_delta,
   double regime_fit_delta,
   double decision_quality_delta,
   double entry_edge_delta,
   double follow_through_quality_delta,
   double expected_rr_delta,
   double execution_geometry_delta,
   string comparison_summary,
   string comparison_basis,
   string &logMessage
)
{
   string json = "{";
   json += "\"record_type\":\"SHADOW_COMPARISON\",";
   json += "\"timestamp\":\"" + PJ_PJ_EscapeJsonMini(PJ_NowIso()) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"shadow_decision_id\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision_id) + "\",";
   json += "\"production_decision_id\":\"" + PJ_PJ_EscapeJsonMini(production_decision_id) + "\",";
   json += "\"relation_class\":\"" + PJ_PJ_EscapeJsonMini(relation_class) + "\",";
   json += "\"decision_agreement\":" + (agreement ? "true" : "false") + ",";
   json += "\"production_decision\":\"" + PJ_PJ_EscapeJsonMini(production_decision) + "\",";
   json += "\"shadow_decision\":\"" + PJ_PJ_EscapeJsonMini(shadow_decision) + "\",";
   json += "\"production_direction\":\"" + PJ_PJ_EscapeJsonMini(production_direction) + "\",";
   json += "\"shadow_direction\":\"" + PJ_PJ_EscapeJsonMini(shadow_direction) + "\",";
   json += "\"confidence_delta\":" + DoubleToString(confidence_delta, 3) + ",";
   json += "\"permission_delta\":" + IntegerToString(permission_delta) + ",";
   json += "\"entry_quality_delta\":" + DoubleToString(entry_quality_delta, 3) + ",";
   json += "\"regime_fit_delta\":" + DoubleToString(regime_fit_delta, 3) + ",";
   json += "\"decision_quality_delta\":" + DoubleToString(decision_quality_delta, 3) + ",";
   json += "\"entry_edge_delta\":" + DoubleToString(entry_edge_delta, 3) + ",";
   json += "\"follow_through_quality_delta\":" + DoubleToString(follow_through_quality_delta, 3) + ",";
   json += "\"expected_rr_delta\":" + DoubleToString(expected_rr_delta, 3) + ",";
   json += "\"execution_geometry_delta\":" + DoubleToString(execution_geometry_delta, 3) + ",";
   json += "\"comparison_summary\":\"" + PJ_PJ_EscapeJsonMini(comparison_summary) + "\",";
   json += "\"comparison_basis\":\"" + PJ_PJ_EscapeJsonMini(comparison_basis) + "\"";
   json += "}";

   if(!PJ_AppendJsonLine("AI\\ai_performance_journal.jsonl", json, logMessage))
   {
      logMessage = "Performance journal append failed (shadow comparison v5)";
      return false;
   }
   return true;
}

bool JournalAppendShadowComparisonV2(
   string shadow_decision_id,
   string production_decision_id,
   string relation_class,
   bool decision_agreement,
   double confidence_delta,
   int permission_delta,
   int shadow_permission_delta_vs_production,
   string comparison_summary,
   string comparison_basis,
   string &logMessage
)
{
   // Backward-compatible wrapper: V2 -> V4 (older schema did not persist decisions/deltas)
   string summary = comparison_summary;
   if(StringLen(comparison_basis) > 0)
      summary += " | basis=" + comparison_basis;
   summary += " | agreement=" + string(decision_agreement ? "true" : "false");

   return JournalAppendShadowComparisonV4(
      production_decision_id,
      shadow_decision_id,
      "N/A",
      "N/A",
      relation_class,
      confidence_delta,
      permission_delta,
      shadow_permission_delta_vs_production,
      0.0,
      0.0,
      0.0,
      0.0,
      0.0,
      summary,
      logMessage
   );
}

//---------------------------------------------------------
// Governance Review record (analytics-only)
//---------------------------------------------------------
string PJ_BuildGovernanceReviewJson(
   string dominant_issue,
   bool overgovernance_detected,
   double overgovernance_score,
   double evidence_strength,
   bool insufficient_evidence,
   string recommended_action_class,
   string summary_reason
)
{
   string json = "{";
   json += "\"record_type\":\"GOVERNANCE_REVIEW\",";
   json += "\"timestamp\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"overgovernance_detected\":" + (overgovernance_detected ? "true" : "false") + ",";
   json += "\"overgovernance_score\":" + DoubleToString(overgovernance_score, 3) + ",";
   json += "\"dominant_governance_issue\":\"" + PJ_PJ_EscapeJsonMini(dominant_issue) + "\",";
   json += "\"governance_evidence_strength\":" + DoubleToString(evidence_strength, 3) + ",";
   json += "\"insufficient_governance_evidence\":" + (insufficient_evidence ? "true" : "false") + ",";
   json += "\"recommended_action_class\":\"" + PJ_PJ_EscapeJsonMini(recommended_action_class) + "\",";
   json += "\"governance_summary_reason\":\"" + PJ_PJ_EscapeJsonMini(summary_reason) + "\"";
   json += "}\n";
   return json;
}

bool JournalAppendGovernanceReview(
   string dominant_issue,
   bool overgovernance_detected,
   double overgovernance_score,
   double evidence_strength,
   bool insufficient_evidence,
   string recommended_action_class,
   string summary_reason,
   string &logMessage
)
{
   logMessage = "";
   string json = PJ_BuildGovernanceReviewJson(
      dominant_issue,
      overgovernance_detected,
      overgovernance_score,
      evidence_strength,
      insufficient_evidence,
      recommended_action_class,
      summary_reason
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json))
   {
      logMessage = "JournalAppendGovernanceReview failed";
      return false;
   }
   return true;
}

//---------------------------------------------------------
// Evolution meta record (to measure passivity / NO_ACTION rates)
//---------------------------------------------------------
string PJ_BuildEvolutionMetaJson(
   string evolution_action,
   string proposal_risk_class,
   double proposal_confidence,
   int sample_size_used,
   bool insufficient_evidence,
   string summary_reason
)
{
   string json = "{";
   json += "\"record_type\":\"EVOLUTION_META\",";
   json += "\"record_semantics_version\":\"" + PJ_JournalSemanticsVersion() + "\",";
   json += "\"event_family\":\"EVOLUTION\",";
   json += "\"timestamp\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"symbol\":\"" + PJ_PJ_EscapeJsonMini(_Symbol) + "\",";
   json += "\"evolution_action\":\"" + PJ_PJ_EscapeJsonMini(evolution_action) + "\",";
   json += "\"proposal_risk_class\":\"" + PJ_PJ_EscapeJsonMini(proposal_risk_class) + "\",";
   json += "\"proposal_confidence\":" + DoubleToString(proposal_confidence, 3) + ",";
   json += "\"sample_size_used\":" + IntegerToString(sample_size_used) + ",";
   json += "\"insufficient_evidence\":" + (insufficient_evidence ? "true" : "false") + ",";
   json += "\"summary_reason\":\"" + PJ_PJ_EscapeJsonMini(summary_reason) + "\"";
   json += "}\n";
   return json;
}

bool JournalAppendEvolutionMeta(
   string evolution_action,
   string proposal_risk_class,
   double proposal_confidence,
   int sample_size_used,
   bool insufficient_evidence,
   string summary_reason,
   string &logMessage
)
{
   logMessage = "";
   string json = PJ_BuildEvolutionMetaJson(
      evolution_action,
      proposal_risk_class,
      proposal_confidence,
      sample_size_used,
      insufficient_evidence,
      summary_reason
   );

   if(!PJ_AppendLine(PERF_JOURNAL_PATH, json))
   {
      logMessage = "JournalAppendEvolutionMeta failed";
      return false;
   }
   return true;
}

#endif
