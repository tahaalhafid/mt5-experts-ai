#ifndef __TRADE_FEEDBACK_MQH__
#define __TRADE_FEEDBACK_MQH__

#include "config_loader.mqh"
#include "market_regime.mqh"
#include "regime_classification_layer_v1.mqh"

#include "exit_intelligence.mqh"
#include "journal_analytics.mqh"
#define TRADE_FEEDBACK_LAST_DEAL_PATH "AI\\ai_last_recorded_feedback_deal.txt"

struct TradeFeedbackRecord
{
   string symbol;

   string plan_id;
   string main_trigger_name;

   string plan_mode;
   string decision_engine_mode;
   string execution_archetype;
   string experiment_family;
   string experiment_note;
   string bias_direction;

   bool   allow_triggerless_entry;
   bool   use_soft_filters;
   bool   use_hard_blocks;

   string direction;   // BUY / SELL / UNKNOWN
   string result;      // WIN / LOSS / FLAT

   double profit;
   double spread_points;

   // Evidence completeness: execution price/protection surfaces
   double requested_entry_price;
   double actual_entry_fill_price;
   double exit_fill_price;
   double initial_stop_loss;
   double initial_take_profit;
   double slippage_points;
   string requested_entry_price_source;   // DIRECT_OBSERVED / DERIVED_* / UNAVAILABLE_*
   string actual_entry_fill_price_source; // DIRECT_OBSERVED / DERIVED_* / UNAVAILABLE_*
   string exit_fill_price_source;         // DIRECT_OBSERVED / DERIVED_* / UNAVAILABLE_*
   string initial_protection_source;      // DIRECT_OBSERVED / DERIVED_* / UNAVAILABLE_*
   string slippage_source;                // DERIVED_* / UNAVAILABLE_*
   string stop_target_modifications_state;// NOT_CAPTURED / OBSERVED
   double max_favorable_excursion_points;
   double max_adverse_excursion_points;
   string excursion_source;               // DIRECT_OBSERVED / DERIVED_* / UNAVAILABLE_*

   // Decision-envelope observability at entry (non-authoritative evidence carry-forward)
   double base_confidence_score_at_entry;
   double final_confidence_score_at_entry;
   double policy_risk_score_at_entry;
   double regime_fit_score_at_entry;
   double learning_confidence_delta_at_entry;
   double learning_caution_delta_at_entry;
   string learning_state_code_at_entry;
   int    learning_evidence_count_at_entry;
   bool   learning_evidence_threshold_met_at_entry;
   bool   learning_zero_influence_due_to_insufficient_evidence_at_entry;
   double advisory_shaping_delta_at_entry; // bounded contextual shaping only
   string advisory_shaping_delta_source;
   string decision_acceptance_posture_at_entry;
   string decision_reasoning_flags_at_entry;

   string regime_summary;
   string trend_state;
   string volatility_state;
   string spread_state;
   string structure_state;

   // Regime Classification Layer v1
   string regime_label;
   double regime_confidence;
   double tradability_score;
   string rc_volatility_state;
   string rc_structure_state;
   string rc_summary_reason;



   // Correlation / unified journal fields (optional)
   string decision_id;
   string correlated_decision_id;


   // Strong correlation identifiers (best-effort)
   ulong  position_id;
   ulong  entry_deal_id;
   ulong  entry_order_id;
   ulong  close_deal_id;
   string correlation_method;
   double correlation_quality;

   // Exit intelligence (optional)
   string exit_class;
   string exit_quality;
   string exit_reason_summary;
   string exit_basis;



   // Outcome linkage (from TRADE_OPEN)
   string linked_entry_quality_label;
   string linked_strategy_regime_fit_label;
   string linked_decision_quality_label;
   string linked_entry_edge_label;
   string linked_follow_through_quality_label;
   string linked_execution_geometry_label;
   double linked_expected_rr_estimate;
   string linked_decision_quality_version;

   // L3 institutional learning linkage (contextual evidence only)
   bool   linked_learning_context_found;
   string linked_learning_motif_key;
   string linked_runtime_strategy_id;
   string linked_runtime_strategy_family;
   string linked_support_resistance_bucket;
   string linked_support_resistance_state;
   string linked_canonical_level_state;
   double linked_nearest_support_price;
   double linked_nearest_resistance_price;
   int    linked_nearest_support_distance_points;
   int    linked_nearest_resistance_distance_points;
   string linked_level_interaction_type;
   bool   linked_level_context_supported;
   bool   linked_level_context_obstructed;
   bool   linked_level_context_degraded;
   string linked_support_resistance_observation_source;
   bool   linked_sr_confluence_flag;
   bool   linked_sr_rejection_risk_flag;
   bool   linked_sr_continuation_obstructed_flag;
   bool   linked_sr_canonical_near_flag;
   bool   linked_sr_conflicted_flag;
   bool   linked_advisory_available;
   bool   linked_advisory_eligible;
   bool   linked_advisory_shadow_attached;
   string linked_advisory_state;
   string linked_advisory_outcome;
   string linked_advisory_attachment_state;
   string linked_advisory_gate_reason_code;
   string linked_advisory_ineligibility_reason_code;
   string linked_advisory_block_class;
   string linked_advisory_usage_state;
   string linked_advisory_zero_effect_reason;
   bool   linked_advisory_contradiction_flag;
   double linked_advisory_relevance_score;

   // Outcome vs quality summary (rule-based)
   string outcome_vs_entry_quality;
   string outcome_vs_execution_geometry;
   string outcome_vs_expected_rr;
   string outcome_quality_summary;

   // L3 attribution outputs (bounded, non-authoritative)
   string learning_primary_attribution;
   string learning_secondary_attribution;
   string learning_attribution_reason_codes;

   string policy_state;
   string policy_state_reason;

   string failure_class;
   string failure_reason_summary;
   double failure_severity;
   string failure_basis;
   datetime close_time;
};

//---------------------------------------------------------
// De-dup state helpers (ticket + close_time)
//---------------------------------------------------------
bool SaveLastRecordedDealState(string relativePath, ulong dealTicket, datetime closeTime)
{
   // Ensure AI subfolder exists (FileOpen does not create folders).
   FolderCreate("AI");

   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   // Format: <ticket>|<close_time>
   FileWriteString(h, (string)dealTicket + "|" + IntegerToString((int)closeTime) + "\n");
   FileClose(h);
   return true;
}

bool LoadLastRecordedDealState(string relativePath, ulong &dealTicket, datetime &closeTime, bool &isValid)
{
   dealTicket = 0;
   closeTime  = 0;
   isValid    = false;

   int h = FileOpen(relativePath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   string txt = "";
   while(!FileIsEnding(h))
      txt += FileReadString(h);

   FileClose(h);

   txt = TrimString(txt);
   if(StringLen(txt) <= 0)
      return false;

   // Backward compatible: allow plain ticket only.
   int sep = StringFind(txt, "|");
   if(sep < 0)
   {
      dealTicket = (ulong)StringToInteger(txt);
      closeTime  = 0;
      isValid    = (dealTicket > 0);
      return isValid;
   }

   string a = TrimString(StringSubstr(txt, 0, sep));
   string b = TrimString(StringSubstr(txt, sep + 1));
   if(StringLen(a) <= 0)
      return false;

   dealTicket = (ulong)StringToInteger(a);
   closeTime  = (datetime)StringToInteger(b);
   isValid    = (dealTicket > 0);
   return isValid;
}

// Legacy wrappers (kept for compatibility)
bool SaveLastRecordedDealTicket(string relativePath, ulong dealTicket)
{
   return SaveLastRecordedDealState(relativePath, dealTicket, 0);
}
bool LoadLastRecordedDealTicket(string relativePath, ulong &dealTicket)
{
   datetime t = 0;
   bool ok = false;
   bool valid = false;
   ok = LoadLastRecordedDealState(relativePath, dealTicket, t, valid);
   return (ok && valid);
}

// Public wrappers (used by orchestrator to commit dedup state after full handling)
bool TradeFeedback_LoadLastRecordedDealTicket(ulong &dealTicket)
{
   return LoadLastRecordedDealTicket(TRADE_FEEDBACK_LAST_DEAL_PATH, dealTicket);
}
bool TradeFeedback_CommitLastRecordedDealTicket(ulong dealTicket)
{
   // Best-effort: persist ticket + close time if available in history selection.
   datetime ct = 0;
   if(dealTicket > 0)
      ct = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);
   return SaveLastRecordedDealState(TRADE_FEEDBACK_LAST_DEAL_PATH, dealTicket, ct);
}

//---------------------------------------------------------
// JSON helpers
//---------------------------------------------------------
string EscapeJsonMini(string s)
{
   string out = s;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\r", "\\r");
   StringReplace(out, "\n", "\\n");
   StringReplace(out, "\t", "\\t");
   return out;
}

string BoolToJsonText(bool v)
{
   return (v ? "true" : "false");
}

string TF_U64Text(ulong v)
{
   return (string)v;
}

bool ExtractDecisionIdFromComment(string comment, string &outId)
{
   outId = "";
   string s = TrimString(comment);
   if(StringLen(s) <= 0) return false;

   // Expected compact marker: D:<id> or D=<id>
   int p = StringFind(s, "D:");
   if(p < 0) p = StringFind(s, "D=");
   if(p < 0) return false;

   p += 2;
   int n = StringLen(s);

   int end = p;
   for(; end < n; end++)
   {
      ushort ch = StringGetCharacter(s, end);
      if(ch == ' ' || ch == '|' || ch == ';' || ch == ',' || ch == '\t')
         break;
   }

   outId = StringSubstr(s, p, end - p);
   outId = TrimString(outId);
   return (StringLen(outId) > 0);
}

bool TF_EnrichFromTradeOpenEvidenceByPositionId(const ulong position_id, TradeFeedbackRecord &r)
{
   if(position_id == 0)
      return false;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 1400, lines))
      return false;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE_OPEN"))
         continue;

      ulong pid = 0;
      if(!JA_ExtractJsonULong(ln, "position_id", pid))
         continue;
      if(pid != position_id)
         continue;

      double v = 0.0;
      bool b = false;

      if(JA_ExtractJsonDouble(ln, "requested_entry_price", v))
      {
         r.requested_entry_price = v;
         r.requested_entry_price_source = "DERIVED_FROM_TRADE_OPEN_RECORD";
      }

      if(JA_ExtractJsonDouble(ln, "actual_entry_fill_price", v) && v > 0.0)
      {
         if(r.actual_entry_fill_price <= 0.0)
         {
            r.actual_entry_fill_price = v;
            r.actual_entry_fill_price_source = "DERIVED_FROM_TRADE_OPEN_RECORD";
         }
      }

      if(JA_ExtractJsonDouble(ln, "initial_stop_loss", v) && v > 0.0)
      {
         r.initial_stop_loss = v;
         r.initial_protection_source = "DERIVED_FROM_TRADE_OPEN_RECORD";
      }
      if(JA_ExtractJsonDouble(ln, "initial_take_profit", v) && v > 0.0)
      {
         r.initial_take_profit = v;
         r.initial_protection_source = "DERIVED_FROM_TRADE_OPEN_RECORD";
      }

      if(JA_ExtractJsonDouble(ln, "entry_slippage_points", v) && v >= 0.0)
      {
         r.slippage_points = v;
         r.slippage_source = "DERIVED_FROM_TRADE_OPEN_RECORD";
      }

      if(JA_ExtractJsonDouble(ln, "base_confidence_score", v))
         r.base_confidence_score_at_entry = v;
      if(JA_ExtractJsonDouble(ln, "final_confidence_score", v))
         r.final_confidence_score_at_entry = v;
      if(JA_ExtractJsonDouble(ln, "policy_risk_score", v))
         r.policy_risk_score_at_entry = v;
      if(JA_ExtractJsonDouble(ln, "regime_fit_score", v))
         r.regime_fit_score_at_entry = v;
      if(JA_ExtractJsonDouble(ln, "learning_confidence_delta", v))
         r.learning_confidence_delta_at_entry = v;
      if(JA_ExtractJsonDouble(ln, "learning_caution_score", v))
         r.learning_caution_delta_at_entry = v;
      if(JA_ExtractJsonDouble(ln, "advisory_relevance_score", v))
      {
         r.advisory_shaping_delta_at_entry = v;
         r.advisory_shaping_delta_source = "DERIVED_FROM_TRADE_OPEN_RECORD";
      }

      r.learning_state_code_at_entry = JA_ExtractJsonString(ln, "learning_state_code");
      r.decision_acceptance_posture_at_entry = JA_ExtractJsonString(ln, "decision_acceptance_posture");
      r.decision_reasoning_flags_at_entry = JA_ExtractJsonString(ln, "decision_reasoning_flags_csv");
      r.linked_support_resistance_state = JA_ExtractJsonString(ln, "support_resistance_confluence_state");
      r.linked_canonical_level_state = JA_ExtractJsonString(ln, "canonical_level_state");
      r.linked_support_resistance_bucket = JA_ExtractJsonString(ln, "sr_interaction_bucket");
      if(StringLen(TrimString(r.linked_support_resistance_bucket)) <= 0)
         r.linked_support_resistance_bucket = JA_ExtractJsonString(ln, "support_resistance_confluence_state");
      if(JA_ExtractJsonDouble(ln, "nearest_support_price", v) && v > 0.0)
         r.linked_nearest_support_price = v;
      if(JA_ExtractJsonDouble(ln, "nearest_resistance_price", v) && v > 0.0)
         r.linked_nearest_resistance_price = v;
      if(JA_ExtractJsonDouble(ln, "nearest_support_distance_points", v))
         r.linked_nearest_support_distance_points = (int)v;
      if(JA_ExtractJsonDouble(ln, "nearest_resistance_distance_points", v))
         r.linked_nearest_resistance_distance_points = (int)v;
      r.linked_level_interaction_type = JA_ExtractJsonString(ln, "level_interaction_type");
      r.linked_support_resistance_observation_source = JA_ExtractJsonString(ln, "support_resistance_observation_source");
      r.linked_advisory_state = JA_ExtractJsonString(ln, "advisory_state");
      r.linked_advisory_outcome = JA_ExtractJsonString(ln, "advisory_outcome");
      r.linked_advisory_attachment_state = JA_ExtractJsonString(ln, "advisory_attachment_state");
      r.linked_advisory_gate_reason_code = JA_ExtractJsonString(ln, "advisory_gate_reason_code");
      r.linked_advisory_ineligibility_reason_code = JA_ExtractJsonString(ln, "advisory_ineligibility_reason_code");
      r.linked_advisory_block_class = JA_ExtractJsonString(ln, "advisory_block_class");
      r.linked_advisory_usage_state = JA_ExtractJsonString(ln, "advisory_usage_state");
      r.linked_advisory_zero_effect_reason = JA_ExtractJsonString(ln, "advisory_zero_effect_reason");

      if(JA_ExtractJsonBool(ln, "learning_evidence_threshold_met", b))
         r.learning_evidence_threshold_met_at_entry = b;
      if(JA_ExtractJsonBool(ln, "learning_zero_influence_due_to_insufficient_evidence", b))
         r.learning_zero_influence_due_to_insufficient_evidence_at_entry = b;
      if(JA_ExtractJsonBool(ln, "sr_confluence_flag", b))
         r.linked_sr_confluence_flag = b;
      if(JA_ExtractJsonBool(ln, "sr_rejection_risk_flag", b))
         r.linked_sr_rejection_risk_flag = b;
      if(JA_ExtractJsonBool(ln, "sr_continuation_obstructed_flag", b))
         r.linked_sr_continuation_obstructed_flag = b;
      if(JA_ExtractJsonBool(ln, "sr_canonical_near_flag", b))
         r.linked_sr_canonical_near_flag = b;
      if(JA_ExtractJsonBool(ln, "sr_conflicted_flag", b))
         r.linked_sr_conflicted_flag = b;
      if(JA_ExtractJsonBool(ln, "level_context_supported", b))
         r.linked_level_context_supported = b;
      if(JA_ExtractJsonBool(ln, "level_context_obstructed", b))
         r.linked_level_context_obstructed = b;
      if(JA_ExtractJsonBool(ln, "level_context_degraded", b))
         r.linked_level_context_degraded = b;
      if(JA_ExtractJsonBool(ln, "advisory_available", b))
         r.linked_advisory_available = b;
      if(JA_ExtractJsonBool(ln, "advisory_eligible", b))
         r.linked_advisory_eligible = b;
      if(JA_ExtractJsonBool(ln, "advisory_shadow_attached", b))
         r.linked_advisory_shadow_attached = b;
      if(JA_ExtractJsonBool(ln, "advisory_contradiction_flag", b))
         r.linked_advisory_contradiction_flag = b;
      if(JA_ExtractJsonBool(ln, "advisory_hold_bias_active", b))
      {
         if(b)
            r.decision_reasoning_flags_at_entry =
               (StringLen(TrimString(r.decision_reasoning_flags_at_entry)) > 0
                  ? (r.decision_reasoning_flags_at_entry + ",ADVISORY_HOLD_BIAS_ACTIVE")
                  : "ADVISORY_HOLD_BIAS_ACTIVE");
      }

      int iv = (int)JA_ExtractJsonDouble(ln, "learning_evidence_count");
      if(iv > 0)
         r.learning_evidence_count_at_entry = iv;

      return true;
   }

   return false;
}

string TradeFeedbackRecordToJson(TradeFeedbackRecord &r)
{
   string json = "{";
   json += "\"symbol\":\"" + EscapeJsonMini(r.symbol) + "\",";
   json += "\"plan_id\":\"" + EscapeJsonMini(r.plan_id) + "\",";
   json += "\"main_trigger_name\":\"" + EscapeJsonMini(r.main_trigger_name) + "\",";

   json += "\"plan_mode\":\"" + EscapeJsonMini(r.plan_mode) + "\",";
   json += "\"decision_engine_mode\":\"" + EscapeJsonMini(r.decision_engine_mode) + "\",";
   json += "\"execution_archetype\":\"" + EscapeJsonMini(r.execution_archetype) + "\",";
   json += "\"experiment_family\":\"" + EscapeJsonMini(r.experiment_family) + "\",";
   json += "\"experiment_note\":\"" + EscapeJsonMini(r.experiment_note) + "\",";
   json += "\"bias_direction\":\"" + EscapeJsonMini(r.bias_direction) + "\",";

   json += "\"allow_triggerless_entry\":" + BoolToJsonText(r.allow_triggerless_entry) + ",";
   json += "\"use_soft_filters\":" + BoolToJsonText(r.use_soft_filters) + ",";
   json += "\"use_hard_blocks\":" + BoolToJsonText(r.use_hard_blocks) + ",";

   json += "\"direction\":\"" + EscapeJsonMini(r.direction) + "\",";
   json += "\"result\":\"" + EscapeJsonMini(r.result) + "\",";
   json += "\"profit\":" + DoubleToString(r.profit, 2) + ",";
   json += "\"spread_points\":" + DoubleToString(r.spread_points, 2) + ",";
   json += "\"requested_entry_price\":" + DoubleToString(r.requested_entry_price, 5) + ",";
   json += "\"actual_entry_fill_price\":" + DoubleToString(r.actual_entry_fill_price, 5) + ",";
   json += "\"exit_fill_price\":" + DoubleToString(r.exit_fill_price, 5) + ",";
   json += "\"initial_stop_loss\":" + DoubleToString(r.initial_stop_loss, 5) + ",";
   json += "\"initial_take_profit\":" + DoubleToString(r.initial_take_profit, 5) + ",";
   json += "\"slippage_points\":" + DoubleToString(r.slippage_points, 2) + ",";
   json += "\"requested_entry_price_source\":\"" + EscapeJsonMini(r.requested_entry_price_source) + "\",";
   json += "\"actual_entry_fill_price_source\":\"" + EscapeJsonMini(r.actual_entry_fill_price_source) + "\",";
   json += "\"exit_fill_price_source\":\"" + EscapeJsonMini(r.exit_fill_price_source) + "\",";
   json += "\"initial_protection_source\":\"" + EscapeJsonMini(r.initial_protection_source) + "\",";
   json += "\"slippage_source\":\"" + EscapeJsonMini(r.slippage_source) + "\",";
   json += "\"stop_target_modifications_state\":\"" + EscapeJsonMini(r.stop_target_modifications_state) + "\",";
   json += "\"max_favorable_excursion_points\":" + DoubleToString(r.max_favorable_excursion_points, 2) + ",";
   json += "\"max_adverse_excursion_points\":" + DoubleToString(r.max_adverse_excursion_points, 2) + ",";
   json += "\"excursion_source\":\"" + EscapeJsonMini(r.excursion_source) + "\",";
   json += "\"base_confidence_score_at_entry\":" + DoubleToString(r.base_confidence_score_at_entry, 4) + ",";
   json += "\"final_confidence_score_at_entry\":" + DoubleToString(r.final_confidence_score_at_entry, 4) + ",";
   json += "\"policy_risk_score_at_entry\":" + DoubleToString(r.policy_risk_score_at_entry, 4) + ",";
   json += "\"regime_fit_score_at_entry\":" + DoubleToString(r.regime_fit_score_at_entry, 4) + ",";
   json += "\"learning_confidence_delta_at_entry\":" + DoubleToString(r.learning_confidence_delta_at_entry, 4) + ",";
   json += "\"learning_caution_delta_at_entry\":" + DoubleToString(r.learning_caution_delta_at_entry, 4) + ",";
   json += "\"learning_state_code_at_entry\":\"" + EscapeJsonMini(r.learning_state_code_at_entry) + "\",";
   json += "\"learning_evidence_count_at_entry\":" + IntegerToString(r.learning_evidence_count_at_entry) + ",";
   json += "\"learning_evidence_threshold_met_at_entry\":" + string(r.learning_evidence_threshold_met_at_entry ? "true" : "false") + ",";
   json += "\"learning_zero_influence_due_to_insufficient_evidence_at_entry\":" + string(r.learning_zero_influence_due_to_insufficient_evidence_at_entry ? "true" : "false") + ",";
   json += "\"advisory_shaping_delta_at_entry\":" + DoubleToString(r.advisory_shaping_delta_at_entry, 4) + ",";
   json += "\"advisory_shaping_delta_source\":\"" + EscapeJsonMini(r.advisory_shaping_delta_source) + "\",";
   json += "\"decision_acceptance_posture_at_entry\":\"" + EscapeJsonMini(r.decision_acceptance_posture_at_entry) + "\",";
   json += "\"decision_reasoning_flags_at_entry\":\"" + EscapeJsonMini(r.decision_reasoning_flags_at_entry) + "\",";

   json += "\"regime_summary\":\"" + EscapeJsonMini(r.regime_summary) + "\",";
   json += "\"trend_state\":\"" + EscapeJsonMini(r.trend_state) + "\",";
   json += "\"volatility_state\":\"" + EscapeJsonMini(r.volatility_state) + "\",";
   json += "\"spread_state\":\"" + EscapeJsonMini(r.spread_state) + "\",";
   json += "\"structure_state\":\"" + EscapeJsonMini(r.structure_state) + "\",";

   json += "\"regime_label\":\"" + EscapeJsonMini(r.regime_label) + "\",";
   json += "\"regime_confidence\":" + DoubleToString(r.regime_confidence, 3) + ",";
   json += "\"tradability_score\":" + DoubleToString(r.tradability_score, 3) + ",";
   json += "\"volatility_state_rc\":\"" + EscapeJsonMini(r.rc_volatility_state) + "\",";
   json += "\"structure_state_rc\":\"" + EscapeJsonMini(r.rc_structure_state) + "\",";
   json += "\"summary_reason\":\"" + EscapeJsonMini(r.rc_summary_reason) + "\",";
   json += "\"decision_id\":\"" + EscapeJsonMini(r.decision_id) + "\",";
   json += "\"correlated_decision_id\":\"" + EscapeJsonMini(r.correlated_decision_id) + "\",";
   json += "\"position_id\":" + TF_U64Text(r.position_id) + ",";
   json += "\"entry_deal_id\":" + TF_U64Text(r.entry_deal_id) + ",";
   json += "\"entry_order_id\":" + TF_U64Text(r.entry_order_id) + ",";
   json += "\"close_deal_id\":" + TF_U64Text(r.close_deal_id) + ",";
   json += "\"correlation_method\":\"" + EscapeJsonMini(r.correlation_method) + "\",";
   json += "\"correlation_quality\":" + DoubleToString(r.correlation_quality, 3) + ",";
   json += "\"exit_class\":\"" + EscapeJsonMini(r.exit_class) + "\",";
   json += "\"exit_quality\":\"" + EscapeJsonMini(r.exit_quality) + "\",";
   json += "\"exit_reason_summary\":\"" + EscapeJsonMini(r.exit_reason_summary) + "\",";
   json += "\"exit_basis\":\"" + EscapeJsonMini(r.exit_basis) + "\",";

   json += "\"linked_entry_quality_label\":\"" + EscapeJsonMini(r.linked_entry_quality_label) + "\",";
   json += "\"linked_strategy_regime_fit_label\":\"" + EscapeJsonMini(r.linked_strategy_regime_fit_label) + "\",";
   json += "\"linked_decision_quality_label\":\"" + EscapeJsonMini(r.linked_decision_quality_label) + "\",";
   json += "\"linked_entry_edge_label\":\"" + EscapeJsonMini(r.linked_entry_edge_label) + "\",";
   json += "\"linked_follow_through_quality_label\":\"" + EscapeJsonMini(r.linked_follow_through_quality_label) + "\",";
   json += "\"linked_execution_geometry_label\":\"" + EscapeJsonMini(r.linked_execution_geometry_label) + "\",";
   json += "\"linked_expected_rr_estimate\":" + DoubleToString(r.linked_expected_rr_estimate, 3) + ",";
   json += "\"linked_decision_quality_version\":\"" + EscapeJsonMini(r.linked_decision_quality_version) + "\",";
   json += "\"linked_learning_context_found\":" + string(r.linked_learning_context_found ? "true" : "false") + ",";
   json += "\"linked_learning_motif_key\":\"" + EscapeJsonMini(r.linked_learning_motif_key) + "\",";
   json += "\"linked_runtime_strategy_id\":\"" + EscapeJsonMini(r.linked_runtime_strategy_id) + "\",";
   json += "\"linked_runtime_strategy_family\":\"" + EscapeJsonMini(r.linked_runtime_strategy_family) + "\",";
   json += "\"linked_support_resistance_bucket\":\"" + EscapeJsonMini(r.linked_support_resistance_bucket) + "\",";
   json += "\"linked_support_resistance_state\":\"" + EscapeJsonMini(r.linked_support_resistance_state) + "\",";
   json += "\"linked_canonical_level_state\":\"" + EscapeJsonMini(r.linked_canonical_level_state) + "\",";
   json += "\"linked_nearest_support_price\":" + DoubleToString(r.linked_nearest_support_price, 5) + ",";
   json += "\"linked_nearest_resistance_price\":" + DoubleToString(r.linked_nearest_resistance_price, 5) + ",";
   json += "\"linked_nearest_support_distance_points\":" + IntegerToString(r.linked_nearest_support_distance_points) + ",";
   json += "\"linked_nearest_resistance_distance_points\":" + IntegerToString(r.linked_nearest_resistance_distance_points) + ",";
   json += "\"linked_level_interaction_type\":\"" + EscapeJsonMini(r.linked_level_interaction_type) + "\",";
   json += "\"linked_level_context_supported\":" + string(r.linked_level_context_supported ? "true" : "false") + ",";
   json += "\"linked_level_context_obstructed\":" + string(r.linked_level_context_obstructed ? "true" : "false") + ",";
   json += "\"linked_level_context_degraded\":" + string(r.linked_level_context_degraded ? "true" : "false") + ",";
   json += "\"linked_support_resistance_observation_source\":\"" + EscapeJsonMini(r.linked_support_resistance_observation_source) + "\",";
   json += "\"linked_sr_confluence_flag\":" + string(r.linked_sr_confluence_flag ? "true" : "false") + ",";
   json += "\"linked_sr_rejection_risk_flag\":" + string(r.linked_sr_rejection_risk_flag ? "true" : "false") + ",";
   json += "\"linked_sr_continuation_obstructed_flag\":" + string(r.linked_sr_continuation_obstructed_flag ? "true" : "false") + ",";
   json += "\"linked_sr_canonical_near_flag\":" + string(r.linked_sr_canonical_near_flag ? "true" : "false") + ",";
   json += "\"linked_sr_conflicted_flag\":" + string(r.linked_sr_conflicted_flag ? "true" : "false") + ",";
   json += "\"linked_advisory_available\":" + string(r.linked_advisory_available ? "true" : "false") + ",";
   json += "\"linked_advisory_eligible\":" + string(r.linked_advisory_eligible ? "true" : "false") + ",";
   json += "\"linked_advisory_shadow_attached\":" + string(r.linked_advisory_shadow_attached ? "true" : "false") + ",";
   json += "\"linked_advisory_state\":\"" + EscapeJsonMini(r.linked_advisory_state) + "\",";
   json += "\"linked_advisory_outcome\":\"" + EscapeJsonMini(r.linked_advisory_outcome) + "\",";
   json += "\"linked_advisory_attachment_state\":\"" + EscapeJsonMini(r.linked_advisory_attachment_state) + "\",";
   json += "\"linked_advisory_gate_reason_code\":\"" + EscapeJsonMini(r.linked_advisory_gate_reason_code) + "\",";
   json += "\"linked_advisory_ineligibility_reason_code\":\"" + EscapeJsonMini(r.linked_advisory_ineligibility_reason_code) + "\",";
   json += "\"linked_advisory_block_class\":\"" + EscapeJsonMini(r.linked_advisory_block_class) + "\",";
   json += "\"linked_advisory_usage_state\":\"" + EscapeJsonMini(r.linked_advisory_usage_state) + "\",";
   json += "\"linked_advisory_zero_effect_reason\":\"" + EscapeJsonMini(r.linked_advisory_zero_effect_reason) + "\",";
   json += "\"linked_advisory_contradiction_flag\":" + string(r.linked_advisory_contradiction_flag ? "true" : "false") + ",";
   json += "\"linked_advisory_relevance_score\":" + DoubleToString(r.linked_advisory_relevance_score, 3) + ",";
   json += "\"outcome_vs_entry_quality\":\"" + EscapeJsonMini(r.outcome_vs_entry_quality) + "\",";
   json += "\"outcome_vs_execution_geometry\":\"" + EscapeJsonMini(r.outcome_vs_execution_geometry) + "\",";
   json += "\"outcome_vs_expected_rr\":\"" + EscapeJsonMini(r.outcome_vs_expected_rr) + "\",";
   json += "\"outcome_quality_summary\":\"" + EscapeJsonMini(r.outcome_quality_summary) + "\",";
   json += "\"learning_primary_attribution\":\"" + EscapeJsonMini(r.learning_primary_attribution) + "\",";
   json += "\"learning_secondary_attribution\":\"" + EscapeJsonMini(r.learning_secondary_attribution) + "\",";
   json += "\"learning_attribution_reason_codes\":\"" + EscapeJsonMini(r.learning_attribution_reason_codes) + "\",";

   json += "\"policy_state\":\"" + EscapeJsonMini(r.policy_state) + "\",";
   json += "\"policy_state_reason\":\"" + EscapeJsonMini(r.policy_state_reason) + "\",";
   json += "\"failure_class\":\"" + EscapeJsonMini(r.failure_class) + "\",";
   json += "\"failure_reason_summary\":\"" + EscapeJsonMini(r.failure_reason_summary) + "\",";
   json += "\"failure_severity\":" + DoubleToString(r.failure_severity, 3) + ",";
   json += "\"failure_basis\":\"" + EscapeJsonMini(r.failure_basis) + "\",";

   json += "\"close_time\":" + IntegerToString((int)r.close_time);
   json += "}";

   return json;
}

bool AppendTradeFeedbackRecord(string relativePath, TradeFeedbackRecord &r)
{
   string one = TradeFeedbackRecordToJson(r);

   int h = FileOpen(relativePath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
   {
      h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(h == INVALID_HANDLE)
         return false;

      FileWriteString(h, "[\n" + one + "\n]");
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
      newText = "[\n" + one + "\n]";
   }
   else
   {
      int endBracket = -1;

      for(int i = StringLen(oldText) - 1; i >= 0; i--)
      {
         if(StringGetCharacter(oldText, i) == ']')
         {
            endBracket = i;
            break;
         }
      }

      if(endBracket < 0)
      {
         newText = "[\n" + one + "\n]";
      }
      else
      {
         string prefix = TrimString(StringSubstr(oldText, 0, endBracket));
         if(StringFind(prefix, "{") >= 0)
            newText = prefix + ",\n" + one + "\n]";
         else
            newText = "[\n" + one + "\n]";
      }
   }

   h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, newText);
   FileClose(h);
   return true;
}

//---------------------------------------------------------
// Result / direction helpers
//---------------------------------------------------------
string ProfitToResult(double profit)
{
   if(profit > 0.0) return "WIN";
   if(profit < 0.0) return "LOSS";
   return "FLAT";
}

string DealTypeToDirection(long dealType)
{
   if(dealType == DEAL_TYPE_BUY)  return "BUY";
   if(dealType == DEAL_TYPE_SELL) return "SELL";
   return "UNKNOWN";
}

string InvertDirection(string direction)
{
   if(direction == "BUY")  return "SELL";
   if(direction == "SELL") return "BUY";
   return "UNKNOWN";
}

//---------------------------------------------------------
// Determine original position direction
//---------------------------------------------------------
bool ResolveClosedPositionDirection(ulong closeDealTicket, string &direction)
{
   direction = "UNKNOWN";

   if(closeDealTicket == 0)
      return false;

   long entry = HistoryDealGetInteger(closeDealTicket, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT)
      return false;

   ulong positionId = (ulong)HistoryDealGetInteger(closeDealTicket, DEAL_POSITION_ID);
   if(positionId == 0)
   {
      // fallback: invert close deal type
      long closeType = HistoryDealGetInteger(closeDealTicket, DEAL_TYPE);
      direction = InvertDirection(DealTypeToDirection(closeType));
      return (direction != "UNKNOWN");
   }

   int total = HistoryDealsTotal();

   datetime bestTime = 0;
   ulong bestTicket = 0;
   string bestDirection = "UNKNOWN";

   for(int i = 0; i < total; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0 || dealTicket == closeDealTicket)
         continue;

      ulong pid = (ulong)HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(pid != positionId)
         continue;

      long dEntry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
      if(dEntry != DEAL_ENTRY_IN)
         continue;

      long dType = HistoryDealGetInteger(dealTicket, DEAL_TYPE);
      string dir = DealTypeToDirection(dType);
      if(dir == "UNKNOWN")
         continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);

      if(bestTicket == 0 || dealTime < bestTime)
      {
         bestTicket = dealTicket;
         bestTime = dealTime;
         bestDirection = dir;
      }
   }

   if(bestDirection != "UNKNOWN")
   {
      direction = bestDirection;
      return true;
   }

   // final fallback: invert close deal type
   long closeType = HistoryDealGetInteger(closeDealTicket, DEAL_TYPE);
   direction = InvertDirection(DealTypeToDirection(closeType));
   return (direction != "UNKNOWN");
}


//---------------------------------------------------------
// Resolve entry deal ticket for closed position (best-effort)
//---------------------------------------------------------
bool ResolveEntryDealTicket(ulong closeDealTicket, ulong &entryDealTicket, ulong &positionId)
{
   entryDealTicket = 0;
   positionId = 0;

   if(closeDealTicket == 0)
      return false;

   long entry = HistoryDealGetInteger(closeDealTicket, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT)
      return false;

   positionId = (ulong)HistoryDealGetInteger(closeDealTicket, DEAL_POSITION_ID);
   if(positionId == 0)
      return false;

   int total = HistoryDealsTotal();

   datetime bestTime = 0;
   ulong bestTicket = 0;

   for(int i = 0; i < total; i++)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0 || dealTicket == closeDealTicket)
         continue;

      ulong pid = (ulong)HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID);
      if(pid != positionId)
         continue;

      long dEntry = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);
      if(dEntry != DEAL_ENTRY_IN)
         continue;

      datetime dealTime = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);

      if(bestTicket == 0 || dealTime < bestTime)
      {
         bestTicket = dealTicket;
         bestTime = dealTime;
      }
   }

   entryDealTicket = bestTicket;
   return (entryDealTicket != 0);
}

//---------------------------------------------------------
// Build feedback record
//---------------------------------------------------------
bool BuildTradeFeedbackRecord(
   ulong dealTicket,
   ulong magic,
   RuntimePlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   TradeFeedbackRecord &r
)
{
   if(dealTicket == 0)
      return false;

   string symbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
   long   mg     = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
   long   entry  = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

   if(symbol != _Symbol || (ulong)mg != magic || entry != DEAL_ENTRY_OUT)
      return false;

   double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);

   MarketRegimeSnapshot reg;
   BuildMarketRegimeSnapshot(m1, m5, reg);

   string resolvedDirection = "UNKNOWN";
   ResolveClosedPositionDirection(dealTicket, resolvedDirection);

   r.symbol            = symbol;

   r.plan_id           = plan.plan_id;
   r.main_trigger_name = plan.main_trigger_name;

   r.plan_mode             = plan.plan_mode;
   r.decision_engine_mode  = plan.decision_engine_mode;
   r.execution_archetype   = plan.execution_archetype;
   r.experiment_family     = plan.experiment_family;
   r.experiment_note       = plan.experiment_note;
   r.bias_direction        = plan.bias_direction;

   r.allow_triggerless_entry = plan.allow_triggerless_entry;
   r.use_soft_filters        = plan.use_soft_filters;
   r.use_hard_blocks         = plan.use_hard_blocks;

   r.direction         = resolvedDirection;
   r.result            = ProfitToResult(profit);

   r.profit            = profit;
   r.spread_points     = m1.spread_points;
   r.requested_entry_price = 0.0;
   r.actual_entry_fill_price = 0.0;
   r.exit_fill_price = 0.0;
   r.initial_stop_loss = 0.0;
   r.initial_take_profit = 0.0;
   r.slippage_points = 0.0;
   r.requested_entry_price_source = "UNAVAILABLE_NOT_CAPTURED";
   r.actual_entry_fill_price_source = "UNAVAILABLE_NOT_CAPTURED";
   r.exit_fill_price_source = "UNAVAILABLE_NOT_CAPTURED";
   r.initial_protection_source = "UNAVAILABLE_NOT_CAPTURED";
   r.slippage_source = "UNAVAILABLE_NOT_DERIVABLE";
   r.stop_target_modifications_state = "NOT_CAPTURED_IN_BOUNDED_SURFACES";
   r.max_favorable_excursion_points = 0.0;
   r.max_adverse_excursion_points = 0.0;
   r.excursion_source = "UNAVAILABLE_NOT_CAPTURED";
   r.base_confidence_score_at_entry = 0.0;
   r.final_confidence_score_at_entry = 0.0;
   r.policy_risk_score_at_entry = 0.0;
   r.regime_fit_score_at_entry = 0.0;
   r.learning_confidence_delta_at_entry = 0.0;
   r.learning_caution_delta_at_entry = 0.0;
   r.learning_state_code_at_entry = "";
   r.learning_evidence_count_at_entry = 0;
   r.learning_evidence_threshold_met_at_entry = false;
   r.learning_zero_influence_due_to_insufficient_evidence_at_entry = false;
   r.advisory_shaping_delta_at_entry = 0.0;
   r.advisory_shaping_delta_source = "UNAVAILABLE_NOT_CAPTURED";
   r.decision_acceptance_posture_at_entry = "";
   r.decision_reasoning_flags_at_entry = "";

   double exitFill = HistoryDealGetDouble(dealTicket, DEAL_PRICE);
   if(exitFill > 0.0)
   {
      r.exit_fill_price = exitFill;
      r.exit_fill_price_source = "DIRECT_OBSERVED";
   }

   r.regime_summary    = reg.summary;
   r.trend_state       = reg.trend_state;
   r.volatility_state  = reg.volatility_state;
   r.spread_state      = reg.spread_state;
   r.structure_state   = reg.structure_state;

   // Regime Classification Layer v1
   RegimeClassification rc;
   BuildRegimeClassificationV1(m1, m5, rc);

   r.regime_label        = rc.regime_label;
   r.regime_confidence   = rc.regime_confidence;
   r.tradability_score   = rc.tradability_score;
   r.rc_volatility_state = rc.volatility_state;
   r.rc_structure_state  = rc.structure_state;
   r.rc_summary_reason   = rc.summary_reason;

      // Correlation + policy/failure placeholders
   r.decision_id = "";
   r.correlated_decision_id = "";

   r.position_id = 0;
   r.entry_deal_id = 0;
   r.entry_order_id = 0;
   r.close_deal_id = dealTicket;
   r.correlation_method = "NONE";
   r.correlation_quality = 0.0;

   string dealComment = HistoryDealGetString(dealTicket, DEAL_COMMENT);
   ExtractDecisionIdFromComment(dealComment, r.decision_id);

   ulong entryDeal = 0;
   ulong pid = 0;
   if(ResolveEntryDealTicket(dealTicket, entryDeal, pid))
   {
      r.position_id = pid;
      r.entry_deal_id = entryDeal;
      r.correlation_method = "POSITION_ID";
      r.correlation_quality = 0.80;

      double entryFill = HistoryDealGetDouble(entryDeal, DEAL_PRICE);
      if(entryFill > 0.0)
      {
         r.actual_entry_fill_price = entryFill;
         r.actual_entry_fill_price_source = "DIRECT_OBSERVED";
      }

      double entrySL = HistoryDealGetDouble(entryDeal, DEAL_SL);
      double entryTP = HistoryDealGetDouble(entryDeal, DEAL_TP);
      if(entrySL > 0.0 || entryTP > 0.0)
      {
         r.initial_stop_loss = entrySL;
         r.initial_take_profit = entryTP;
         r.initial_protection_source = "DIRECT_OBSERVED";
      }
   }
   else if(StringLen(r.decision_id) > 0)
   {
      r.correlation_method = "COMMENT";
      r.correlation_quality = 0.60;
   }

   r.policy_state = "";
   r.policy_state_reason = "";

   r.failure_class = "";
   r.failure_reason_summary = "";
   r.failure_severity = 0.0;
   r.failure_basis = "";

   r.close_time = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);

   // Exit intelligence (optional, rule-based)
   ExitIntelligence ei;
   ClassifyExitIntelligenceV1(dealTicket, r.profit, r.regime_label, r.rc_volatility_state, ei);
   r.exit_class = ei.exit_class;
   r.exit_quality = ei.exit_quality;
   r.exit_reason_summary = ei.exit_reason_summary;
   r.exit_basis = ei.exit_basis;

   // L3 linkage defaults (safe, bounded, deterministic)
   r.linked_entry_quality_label = "";
   r.linked_strategy_regime_fit_label = "";
   r.linked_decision_quality_label = "";
   r.linked_entry_edge_label = "";
   r.linked_follow_through_quality_label = "";
   r.linked_execution_geometry_label = "";
   r.linked_expected_rr_estimate = 0.0;
   r.linked_decision_quality_version = "";

   r.linked_learning_context_found = false;
   r.linked_learning_motif_key = "";
   r.linked_runtime_strategy_id = "";
   r.linked_runtime_strategy_family = "";
   r.linked_support_resistance_bucket = "";
   r.linked_support_resistance_state = "";
   r.linked_canonical_level_state = "";
   r.linked_nearest_support_price = 0.0;
   r.linked_nearest_resistance_price = 0.0;
   r.linked_nearest_support_distance_points = -1;
   r.linked_nearest_resistance_distance_points = -1;
   r.linked_level_interaction_type = "LEVEL_CONTEXT_UNSET";
   r.linked_level_context_supported = false;
   r.linked_level_context_obstructed = false;
   r.linked_level_context_degraded = false;
   r.linked_support_resistance_observation_source = "UNAVAILABLE_NOT_CAPTURED";
   r.linked_sr_confluence_flag = false;
   r.linked_sr_rejection_risk_flag = false;
   r.linked_sr_continuation_obstructed_flag = false;
   r.linked_sr_canonical_near_flag = false;
   r.linked_sr_conflicted_flag = false;
   r.linked_advisory_available = false;
   r.linked_advisory_eligible = false;
   r.linked_advisory_shadow_attached = false;
   r.linked_advisory_state = "ATAS_ADVISORY_UNSET";
   r.linked_advisory_outcome = "IGNORE_ADVISORY";
   r.linked_advisory_attachment_state = "ADVISORY_NOT_EVALUATED";
   r.linked_advisory_gate_reason_code = "not_evaluated";
   r.linked_advisory_ineligibility_reason_code = "NOT_EVALUATED";
   r.linked_advisory_block_class = "NOT_EVALUATED";
   r.linked_advisory_usage_state = "ADVISORY_NOT_EVALUATED";
   r.linked_advisory_zero_effect_reason = "NOT_EVALUATED";
   r.linked_advisory_contradiction_flag = false;
   r.linked_advisory_relevance_score = 0.0;

   r.outcome_vs_entry_quality = "";
   r.outcome_vs_execution_geometry = "";
   r.outcome_vs_expected_rr = "";
   r.outcome_quality_summary = "";

   r.learning_primary_attribution = "";
   r.learning_secondary_attribution = "";
   r.learning_attribution_reason_codes = "";

   TF_EnrichFromTradeOpenEvidenceByPositionId(r.position_id, r);

   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point > 0.0 && r.requested_entry_price > 0.0 && r.actual_entry_fill_price > 0.0)
   {
      r.slippage_points = MathAbs(r.actual_entry_fill_price - r.requested_entry_price) / point;
      r.slippage_source = "DERIVED_FROM_REQUEST_AND_FILL";
   }


   return true;
}

//---------------------------------------------------------
//---------------------------------------------------------
// Find latest closed deal (DEAL_ENTRY_OUT) that is strictly newer than last recorded
//---------------------------------------------------------
bool FindLatestClosedDealTicketEx(
   ulong magic,
   ulong lastRecordedTicket,
   datetime lastRecordedTime,
   ulong &dealTicket,
   datetime &dealTime
)
{
   dealTicket = 0;
   dealTime   = 0;

   // Ensure history is selected (robust across terminals).
   HistorySelect(0, TimeCurrent());

   int total = HistoryDealsTotal();
   if(total <= 0)
      return false;

   datetime bestTime = 0;
   ulong bestTicket = 0;

   for(int i = 0; i < total; i++)
   {
      ulong tk = HistoryDealGetTicket(i);
      if(tk == 0)
         continue;

      string sym = HistoryDealGetString(tk, DEAL_SYMBOL);
      if(sym != _Symbol)
         continue;

      long mg = HistoryDealGetInteger(tk, DEAL_MAGIC);
      if((ulong)mg != magic)
         continue;

      long entry = HistoryDealGetInteger(tk, DEAL_ENTRY);
      if(entry != DEAL_ENTRY_OUT)
         continue;

      datetime t = (datetime)HistoryDealGetInteger(tk, DEAL_TIME);

      // Hard dedup: require strictly newer by time, then ticket as tie-breaker.
      bool isNew = false;
      if(lastRecordedTicket == 0 && lastRecordedTime == 0)
         isNew = true; // bootstrap handled by caller
      else if(t > lastRecordedTime)
         isNew = true;
      else if(t == lastRecordedTime && tk > lastRecordedTicket)
         isNew = true;

      if(!isNew)
         continue;

      if(bestTicket == 0 || t > bestTime || (t == bestTime && tk > bestTicket))
      {
         bestTicket = tk;
         bestTime   = t;
      }
   }

   dealTicket = bestTicket;
   dealTime   = bestTime;
   return (dealTicket != 0);
}

bool FindLatestClosedDealTicket(ulong magic, ulong lastRecorded, ulong &dealTicket)
{
   datetime dummyTime = 0;
   return FindLatestClosedDealTicketEx(magic, lastRecorded, 0, dealTicket, dummyTime);
}


bool WriteTextFile(string relativePath, string txt)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, txt);
   FileClose(h);
   return true;
}

//---------------------------------------------------------
// Save latest closed trade feedback to JSON file + return record
//---------------------------------------------------------
bool SaveLatestClosedTradeFeedbackEx(
   ulong magic,
   RuntimePlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   string outputJsonPath,
   TradeFeedbackRecord &outRecord,
   string &logMessage
)
{
   logMessage = "";

   // Forensic tracing: load last recorded deal state.
   ulong lastRecordedTicket = 0;
   datetime lastRecordedTime = 0;
   bool stateValid = false;
   bool stateLoaded = LoadLastRecordedDealState(TRADE_FEEDBACK_LAST_DEAL_PATH, lastRecordedTicket, lastRecordedTime, stateValid);

   if(!stateLoaded || !stateValid)
   {
      // Safe bootstrap: establish baseline without processing historical deals.
      ulong baselineTicket = 0;
      datetime baselineTime = 0;

      if(FindLatestClosedDealTicketEx(magic, 0, 0, baselineTicket, baselineTime) && baselineTicket > 0)
      {
         SaveLastRecordedDealState(TRADE_FEEDBACK_LAST_DEAL_PATH, baselineTicket, baselineTime);
         logMessage =
            "ClosedDealTrace | bootstrap_baseline_set=1"
            " | baseline_deal=" + (string)baselineTicket +
            " | baseline_time=" + IntegerToString((int)baselineTime) +
            " | path=" + TRADE_FEEDBACK_LAST_DEAL_PATH;
         return false;
      }

      logMessage =
         "ClosedDealTrace | bootstrap_baseline_set=0"
         " | no_history_deals=1"
         " | path=" + TRADE_FEEDBACK_LAST_DEAL_PATH;
      return false;
   }

   // Candidate selection (must be strictly newer than last recorded).
   ulong dealTicket = 0;
   datetime dealTime = 0;

   if(!FindLatestClosedDealTicketEx(magic, lastRecordedTicket, lastRecordedTime, dealTicket, dealTime))
   {
      logMessage =
         "ClosedDealTrace | last_recorded=" + (string)lastRecordedTicket +
         " | last_time=" + IntegerToString((int)lastRecordedTime) +
         " | candidate=0"
         " | path=" + TRADE_FEEDBACK_LAST_DEAL_PATH;
      return false;
   }

   // Hard guard (paranoia): do not process if not strictly newer.
   bool isNew = (dealTime > lastRecordedTime) || (dealTime == lastRecordedTime && dealTicket > lastRecordedTicket);
   if(!isNew)
   {
      logMessage =
         "ClosedDealTrace | duplicate_skipped=1"
         " | last_recorded=" + (string)lastRecordedTicket +
         " | last_time=" + IntegerToString((int)lastRecordedTime) +
         " | candidate=" + (string)dealTicket +
         " | cand_time=" + IntegerToString((int)dealTime);
      return false;
   }

   TradeFeedbackRecord r;
   if(!BuildTradeFeedbackRecord(dealTicket, magic, plan, m1, m5, r))
   {
      logMessage =
         "ClosedDealTrace | candidate_rejected=1"
         " | candidate=" + (string)dealTicket +
         " | cand_time=" + IntegerToString((int)dealTime) +
         " | reason=build_failed_or_mismatch";
      return false;
   }

   string json = TradeFeedbackRecordToJson(r);

   if(!WriteTextFile(outputJsonPath, json))
   {
      logMessage =
         "ClosedDealTrace | write_failed=1"
         " | candidate=" + (string)dealTicket +
         " | path_out=" + outputJsonPath;
      return false;
   }

   // NOTE: Dedup state is committed by orchestrator after journaling/outcome attribution.

   outRecord = r;
   logMessage =
      "Trade feedback saved | deal=" + (string)dealTicket +
      " | close_time=" + IntegerToString((int)dealTime) +
      " | result=" + r.result;
   return true;
}


// Backward compatible wrapper
bool SaveLatestClosedTradeFeedback(
   ulong magic,
   RuntimePlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   string outputJsonPath,
   string &logMessage
)
{
   TradeFeedbackRecord dummy;
   return SaveLatestClosedTradeFeedbackEx(magic, plan, m1, m5, outputJsonPath, dummy, logMessage);
}



//---------------------------------------------------------
// Outcome quality summary v1 (conservative, rule-based)
//---------------------------------------------------------
void ComputeOutcomeQualitySummaryV1(
   double profit,
   string decision_quality_label,
   string entry_edge_label,
   string execution_geometry_label,
   double expected_rr_estimate,
   string &out_vs_entry_quality,
   string &out_vs_exec_geometry,
   string &out_vs_expected_rr,
   string &out_summary
)
{
   out_vs_entry_quality = "UNKNOWN_OUTCOME_CONTEXT";
   out_vs_exec_geometry = "UNKNOWN_OUTCOME_CONTEXT";
   out_vs_expected_rr   = "UNKNOWN_OUTCOME_CONTEXT";
   out_summary          = "UNKNOWN_OUTCOME_CONTEXT";

   bool hasAny = (StringLen(decision_quality_label) > 0 || StringLen(entry_edge_label) > 0 || StringLen(execution_geometry_label) > 0);
   if(!hasAny)
      return;

   bool win = (profit >= 0.0);

   bool highDQ = (decision_quality_label == "HIGH_QUALITY_DECISION" || decision_quality_label == "GOOD_DECISION");
   bool lowDQ  = (decision_quality_label == "LOW_QUALITY_DECISION" || decision_quality_label == "BLOCK_WORTHY_DECISION");

   bool strongEdge = (entry_edge_label == "STRONG_ENTRY_EDGE" || entry_edge_label == "ADEQUATE_ENTRY_EDGE");
   bool thinEdge   = (entry_edge_label == "THIN_ENTRY_EDGE");
   bool poorEdge   = (entry_edge_label == "POOR_ENTRY_EDGE" || entry_edge_label == "NEGATIVE_ENTRY_EDGE");

   bool strongGeom = (execution_geometry_label == "STRONG_EXECUTION_GEOMETRY" || execution_geometry_label == "ACCEPTABLE_EXECUTION_GEOMETRY");
   bool thinGeom   = (execution_geometry_label == "THIN_EXECUTION_GEOMETRY");
   bool badGeom    = (execution_geometry_label == "POOR_EXECUTION_GEOMETRY" || execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY");

   if(win)
   {
      if(highDQ && strongEdge && strongGeom)
         out_summary = "HIGH_QUALITY_WIN";
      else if(thinEdge || thinGeom)
         out_summary = "THIN_EDGE_WIN";
      else if(poorEdge || lowDQ || badGeom)
         out_summary = "LOW_QUALITY_WIN";
      else
         out_summary = "HIGH_QUALITY_WIN";

      out_vs_entry_quality = (highDQ && strongEdge) ? "HIGH_QUALITY_WIN" : "LOW_QUALITY_WIN";
      out_vs_exec_geometry = (strongGeom) ? "HIGH_QUALITY_WIN" : (badGeom ? "ADVERSE_GEOMETRY_LOSS" : "THIN_EDGE_WIN");
   }
   else
   {
      if(badGeom)
         out_summary = "ADVERSE_GEOMETRY_LOSS";
      else if(highDQ && strongEdge && strongGeom)
         out_summary = "HIGH_QUALITY_LOSS";
      else if(poorEdge || lowDQ)
         out_summary = "LOW_QUALITY_LOSS";
      else
         out_summary = "LOW_QUALITY_LOSS";

      out_vs_entry_quality = (highDQ && strongEdge) ? "HIGH_QUALITY_LOSS" : "LOW_QUALITY_LOSS";
      out_vs_exec_geometry = (badGeom) ? "ADVERSE_GEOMETRY_LOSS" : "LOW_QUALITY_LOSS";
   }

   // expected RR context (very conservative)
   if(expected_rr_estimate > 0.0)
   {
      if(expected_rr_estimate >= 1.6)
         out_vs_expected_rr = win ? "HIGH_QUALITY_WIN" : "HIGH_QUALITY_LOSS";
      else if(expected_rr_estimate >= 1.1)
         out_vs_expected_rr = win ? "THIN_EDGE_WIN" : "LOW_QUALITY_LOSS";
      else
         out_vs_expected_rr = win ? "LOW_QUALITY_WIN" : "LOW_QUALITY_LOSS";
   }
}

#endif
