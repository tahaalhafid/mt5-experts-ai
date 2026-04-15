#ifndef __DASHBOARD_STATE_COLLECTOR_MQH__
#define __DASHBOARD_STATE_COLLECTOR_MQH__

#include "config_loader.mqh"
#include "dashboard_source_registry.mqh"

DashboardSourceDefinition g_dashboard_source_defs[];
DashboardCollectedSourceState g_dashboard_sources[];
bool g_dashboard_sources_initialized = false;
datetime g_dashboard_last_full_reload = 0;
datetime g_dashboard_last_page_entry_reload = 0;

string DashboardNowString()
{
   return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

string DashboardShortText(string value, int max_len = 118)
{
   string text = TrimString(value);
   if(StringLen(text) <= max_len)
      return text;

   return StringSubstr(text, 0, max_len - 3) + "...";
}

string DashboardEscapeJsonValue(string value)
{
   string text = value;
   StringReplace(text, "\\", "\\\\");
   StringReplace(text, "\"", "\\\"");
   StringReplace(text, "\r", " ");
   StringReplace(text, "\n", " ");
   return text;
}

string DashboardJsonBool(const bool value)
{
   return (value ? "true" : "false");
}

int DashboardRefreshWindowSeconds(DashboardRefreshClass refresh_class)
{
   switch(refresh_class)
   {
      case DASHBOARD_REFRESH_BOOT_ONLY:       return 86400;
      case DASHBOARD_REFRESH_SLOW_POLL:       return DASHBOARD_SLOW_POLL_SECONDS;
      case DASHBOARD_REFRESH_NORMAL_POLL:     return DASHBOARD_NORMAL_POLL_SECONDS;
      case DASHBOARD_REFRESH_ON_DEMAND:       return 86400;
      case DASHBOARD_REFRESH_PAGE_ENTRY_ONLY: return DASHBOARD_PAGE_ENTRY_SECONDS;
   }

   return DASHBOARD_NORMAL_POLL_SECONDS;
}

int DashboardStaleWindowSeconds(DashboardRefreshClass refresh_class)
{
   switch(refresh_class)
   {
      case DASHBOARD_REFRESH_BOOT_ONLY:       return DASHBOARD_STALE_BOOT_ONLY_SECONDS;
      case DASHBOARD_REFRESH_SLOW_POLL:       return DASHBOARD_STALE_SLOW_POLL_SECONDS;
      case DASHBOARD_REFRESH_NORMAL_POLL:     return DASHBOARD_STALE_NORMAL_POLL_SECONDS;
      case DASHBOARD_REFRESH_ON_DEMAND:       return DASHBOARD_STALE_ON_DEMAND_SECONDS;
      case DASHBOARD_REFRESH_PAGE_ENTRY_ONLY: return DASHBOARD_STALE_PAGE_ENTRY_SECONDS;
   }

   return DASHBOARD_STALE_NORMAL_POLL_SECONDS;
}

datetime DashboardParseTimestamp(const string raw_value)
{
   string value = TrimString(raw_value);
   if(StringLen(value) == 0)
      return 0;

   StringReplace(value, "T", " ");
   StringReplace(value, "Z", "");
   StringReplace(value, "-", ".");
   if(StringLen(value) >= 19)
      value = StringSubstr(value, 0, 19);

   return StringToTime(value);
}

bool DashboardInferTimestamp(const string json, string &out_timestamp)
{
   string keys[13] =
   {
      "evaluated_at",
      "last_state_change",
      "last_detection_time",
      "gateway_snapshot_updated_at",
      "last_refresh_time",
      "last_review_time",
      "event_time",
      "last_seen_modified_time",
      "timestamp",
      "updated_at",
      "last_checked",
      "last_updated",
      "rebuilt_at"
   };

   out_timestamp = "";

   for(int i = 0; i < 13; i++)
   {
      if(ExtractJsonStringField(json, keys[i], out_timestamp))
         return true;
   }

   return false;
}

bool DashboardReadRuntimeFile(const string runtime_path, string &out_text)
{
   out_text = "";
   if(StringLen(runtime_path) == 0)
      return false;

   return LoadTextFile(runtime_path, out_text);
}

bool DashboardTryReadFallbackText(const string source_id, string &out_text)
{
   out_text = "";
   string path = "";

   if(source_id == "SRC_RUNTIME_GOVERNANCE_STATUS")
      path = "AI\\runtime_governance_status.txt";
   else if(source_id == "SRC_AI_ACTIVATION_READINESS")
      path = "AI\\ai_activation_readiness_status.txt";
   else if(source_id == "SRC_EXPORT_RELEASE_GATE_STATUS")
      path = "AI\\export_release_gate_status.txt";
   else if(source_id == "SRC_TRANSFER_PACKAGE5_STATUS")
      path = "AI\\strategy_transfer_package5_status.txt";
   else if(source_id == "SRC_TRANSFER_PACKAGE5_PILOT_CYCLE")
      path = "AI\\strategy_transfer_package5_pilot_cycle.txt";
   else if(source_id == "SRC_TRANSFER_PACKAGEC_STATUS")
      path = "AI\\strategy_transfer_packageC_status.txt";
   else if(source_id == "SRC_DIAGNOSTIC_RUNTIME_SUMMARY")
      path = "AI\\diagnostic_runtime_summary.txt";
   else if(source_id == "SRC_EXECUTION_AUTHORITY_STATUS")
      path = "AI\\execution_authority_status.txt";
   else if(source_id == "SRC_ACTIVE_OPERATING_COHORT")
      path = "AI\\active_operating_cohort.txt";
   else if(source_id == "SRC_OPERATING_RISK_ENVELOPE_STATUS")
      path = "AI\\operating_risk_envelope_status.txt";
   else if(source_id == "SRC_LAST_MEANINGFUL_RUNTIME_EVENT")
      path = "AI\\last_meaningful_runtime_event.txt";
   else if(source_id == "SRC_FACTORY_OPERATIONAL_EVIDENCE")
      path = "AI\\factory_operational_evidence_status.txt";
   else if(source_id == "SRC_AI_OPERATIONAL_REVIEW")
      path = "AI\\ai_operational_review_status.txt";

   if(StringLen(path) == 0)
      return false;

   return LoadTextFile(path, out_text);
}

void DashboardResetCollectedSource(DashboardCollectedSourceState &state, const DashboardSourceDefinition &def)
{
   state.source_id = def.source_id;
   state.display_path = def.display_path;
   state.runtime_path = def.runtime_path;
   state.tier = def.tier;
   state.refresh_class = def.refresh_class;
   state.authority_type = def.authority_type;
   state.direct_render_allowed = def.direct_render_allowed;
   state.source_present = false;
   state.parse_ok = false;
   state.partial = false;
   state.placeholder_only = false;
   state.zero_record = false;
   state.mixed_plane = false;
   state.stale = false;
   state.runtime_file_allowed = (StringLen(def.runtime_path) > 0);
   state.timestamp_value = "";
   state.timestamp_epoch = 0;
   state.last_poll_time = 0;
   state.raw_text = "";
   state.fallback_text = "";
   state.summary_text = "";
   state.reason_text = "";
}

bool DashboardSourceHasRequiredKeys(const string json, const string key1, const string key2 = "", const string key3 = "")
{
   if(StringLen(key1) > 0 && StringFind(json, "\"" + key1 + "\"") < 0)
      return false;
   if(StringLen(key2) > 0 && StringFind(json, "\"" + key2 + "\"") < 0)
      return false;
   if(StringLen(key3) > 0 && StringFind(json, "\"" + key3 + "\"") < 0)
      return false;
   return true;
}

bool DashboardBuildTradeJournalSummaryJson(const string journal_text, string &summary_json)
{
   summary_json = "";

   string trimmed = TrimString(journal_text);
   if(StringLen(trimmed) == 0)
   {
      summary_json = "{";
      summary_json += "\"artifact_role\":\"DASHBOARD_TRADE_JOURNAL_SUMMARY\",";
      summary_json += "\"artifact_authority_class\":\"LOCAL_DERIVED_OPERATIONAL_SUMMARY\",";
      summary_json += "\"summary_version\":\"PHASE12_TRADE_SUMMARY_V1\",";
      summary_json += "\"source_scope\":\"AI\\\\ai_performance_journal.jsonl\",";
      summary_json += "\"closed_trade_records\":0,";
      summary_json += "\"wins\":0,";
      summary_json += "\"losses\":0,";
      summary_json += "\"flat\":0,";
      summary_json += "\"win_rate\":0.000,";
      summary_json += "\"net_realized_pl\":0.00,";
      summary_json += "\"last_trade_result\":\"\",";
      summary_json += "\"last_trade_time\":\"\",";
      summary_json += "\"last_trade_direction\":\"\",";
      summary_json += "\"last_trade_family\":\"\",";
      summary_json += "\"coverage_partial\":true,";
      summary_json += "\"coverage_note\":\"Journal present but empty. Close-record summary is not yet populated.\",";
      summary_json += "\"evaluated_at\":\"" + DashboardNowString() + "\"";
      summary_json += "}";
      return true;
   }

   string normalized_text = journal_text;
   // Runtime loaders may collapse line breaks; recover JSONL boundaries for trade summary derivation.
   if(StringFind(normalized_text, "\n") < 0 && StringFind(normalized_text, "}{") >= 0)
      StringReplace(normalized_text, "}{", "}\n{");

   string lines[];
   int total_lines = StringSplit(normalized_text, '\n', lines);

   int close_records = 0;
   int wins = 0;
   int losses = 0;
   int flat = 0;
   int malformed_lines = 0;
   double net_realized_pl = 0.0;
   string last_trade_result = "";
   string last_trade_time = "";
   string last_trade_direction = "";
   string last_trade_family = "";

   for(int i = 0; i < total_lines; i++)
   {
      string line = TrimString(lines[i]);
      if(StringLen(line) == 0)
         continue;

      string record_type = "";
      if(!ExtractJsonStringField(line, "record_type", record_type))
      {
         malformed_lines++;
         continue;
      }

      if(record_type != "TRADE")
         continue;

      close_records++;

      string result = "";
      ExtractJsonStringField(line, "trade_result", result);
      if(StringLen(result) == 0)
         ExtractJsonStringField(line, "result", result);
      StringToUpper(result);

      if(result == "WIN")
         wins++;
      else if(result == "LOSS")
         losses++;
      else if(result == "FLAT" || result == "BREAK_EVEN" || result == "BREAKEVEN")
         flat++;

      double profit = 0.0;
      if(ExtractJsonDoubleField(line, "profit", profit))
         net_realized_pl += profit;

      string ts = "";
      if(StringLen(ts) == 0)
         ExtractJsonStringField(line, "ts", ts);
      if(StringLen(ts) == 0)
         ExtractJsonStringField(line, "timestamp", ts);

      string direction = "";
      ExtractJsonStringField(line, "executed_direction", direction);
      if(StringLen(direction) == 0)
         ExtractJsonStringField(line, "direction", direction);

      string family = "";
      ExtractJsonStringField(line, "exit_class", family);
      if(StringLen(family) == 0)
         ExtractJsonStringField(line, "failure_class", family);
      if(StringLen(family) == 0)
         ExtractJsonStringField(line, "active_mode", family);

      last_trade_result = result;
      last_trade_time = ts;
      last_trade_direction = direction;
      last_trade_family = family;
   }

   double win_rate = 0.0;
   int resolved_trades = wins + losses;
   if(resolved_trades > 0)
      win_rate = ((double)wins / (double)resolved_trades);

   bool coverage_partial = (malformed_lines > 0 || close_records <= 0);

   summary_json = "{";
   summary_json += "\"artifact_role\":\"DASHBOARD_TRADE_JOURNAL_SUMMARY\",";
   summary_json += "\"artifact_authority_class\":\"LOCAL_DERIVED_OPERATIONAL_SUMMARY\",";
   summary_json += "\"summary_version\":\"PHASE12_TRADE_SUMMARY_V1\",";
   summary_json += "\"source_scope\":\"AI\\\\ai_performance_journal.jsonl\",";
   summary_json += "\"closed_trade_records\":" + IntegerToString(close_records) + ",";
   summary_json += "\"wins\":" + IntegerToString(wins) + ",";
   summary_json += "\"losses\":" + IntegerToString(losses) + ",";
   summary_json += "\"flat\":" + IntegerToString(flat) + ",";
   summary_json += "\"win_rate\":" + DoubleToString(win_rate, 3) + ",";
   summary_json += "\"net_realized_pl\":" + DoubleToString(net_realized_pl, 2) + ",";
   summary_json += "\"last_trade_result\":\"" + DashboardEscapeJsonValue(last_trade_result) + "\",";
   summary_json += "\"last_trade_time\":\"" + DashboardEscapeJsonValue(last_trade_time) + "\",";
   summary_json += "\"last_trade_direction\":\"" + DashboardEscapeJsonValue(last_trade_direction) + "\",";
   summary_json += "\"last_trade_family\":\"" + DashboardEscapeJsonValue(last_trade_family) + "\",";
   summary_json += "\"coverage_partial\":" + DashboardJsonBool(coverage_partial) + ",";
   summary_json += "\"coverage_note\":\"" + DashboardEscapeJsonValue("Close-record summary is internal-only, journal-derived, and may remain partial when journal coverage is incomplete.") + "\",";
   summary_json += "\"evaluated_at\":\"" + DashboardNowString() + "\"";
   summary_json += "}";
   return true;
}

void DashboardAssessSourceSemantics(DashboardCollectedSourceState &state)
{
   if(!state.source_present)
   {
      state.reason_text = "Required source file is missing.";
      return;
   }

   if(!state.parse_ok)
   {
      state.partial = true;
      state.reason_text = "Source parse failed; healthy interpretation is suppressed.";
      return;
   }

   string json = state.raw_text;
   string text_value = "";
   bool bool_value = false;
   int int_value = 0;

   if(state.source_id == "SRC_RUNTIME_GOVERNANCE_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "governance_state", "trading_allowed");
      if(ExtractJsonStringField(json, "reason_code", text_value))
         state.reason_text = text_value;
      if(ExtractJsonBoolField(json, "strategy_transfer_runtime_freeze_active", bool_value) && bool_value)
         state.summary_text = "Runtime Frozen";
   }
   else if(state.source_id == "SRC_AI_ACTIVATION_READINESS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "authority_state", "readiness_state");
      if(ExtractJsonStringField(json, "readiness_reason_code", text_value))
         state.reason_text = text_value;
   }
   else if(state.source_id == "SRC_EXPORT_RELEASE_GATE_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "overall_gate_result", "external_delivery_allowed");
      if(ExtractJsonStringField(json, "default_gate_result_reason", text_value))
         state.reason_text = DashboardShortText(text_value);
   }
   else if(state.source_id == "SRC_TRANSFER_PACKAGE5_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "package5_state", "pilot_cycle_defined");
      if(ExtractJsonStringField(json, "status_note", text_value))
         state.reason_text = DashboardShortText(text_value);
   }
   else if(state.source_id == "SRC_TRANSFER_PACKAGE5_PILOT_CYCLE")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "pilot_cycle_defined", "live_pilot_execution_started");
      state.reason_text = "Pilot structure is visibility only and does not imply live execution.";
   }
   else if(state.source_id == "SRC_TRANSFER_PACKAGEC_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "package_c_state", "pilot_evidence_design_defined");
      state.reason_text = "Package C remains bounded to truth reconciliation and pilot evidence design.";
   }
   else if(state.source_id == "SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "pilot_evidence_mode", "covered_candidate_count");
      state.reason_text = "Pilot evidence remains evidence-only and not live.";
   }
   else if(state.source_id == "SRC_DIAGNOSTIC_RUNTIME_SUMMARY")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "final_decision", "final_blocked");
      if(ExtractJsonStringField(json, "final_block_reason_code", text_value))
         state.reason_text = text_value;
   }
   else if(state.source_id == "SRC_FACTORY_INTAKE_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "edge_factory_state", "edge_factory_intake_ready");
      state.reason_text = "Factory visibility is structural only and not runtime authority.";
   }
   else if(state.source_id == "SRC_SOURCE_INTAKE_GATEWAY_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "gateway_file_present", "gateway_record_count");
      if(ExtractJsonIntField(json, "gateway_record_count", int_value) && int_value == 0)
         state.zero_record = true;
      if(ExtractJsonBoolField(json, "gateway_snapshot_emitted", bool_value) && bool_value && state.zero_record)
         state.placeholder_only = true;
      if(ExtractJsonStringField(json, "gateway_status_truth_note", text_value))
         state.reason_text = DashboardShortText(text_value);
      string artifact_plane_role = "";
      if(ExtractJsonStringField(json, "artifact_plane_role", artifact_plane_role) && StringFind(artifact_plane_role, "MIXED") >= 0)
         state.mixed_plane = true;
   }
   else if(state.source_id == "SRC_EDGE_FACTORY_DECOMPOSITION_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "edge_factory_decomposition_ready");
      state.reason_text = "Factory decomposition detail is bounded secondary detail only.";
   }
   else if(state.source_id == "SRC_EDGE_FACTORY_MANIFEST")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "registered_material_total", "edge_factory_state");
      state.mixed_plane = true;
      state.placeholder_only = true;
      state.reason_text = "Summary Only, Not Primary Truth";
   }
   else if(state.source_id == "SRC_EDGE_FACTORY_INTERNAL_INTELLIGENCE_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "internal_intelligence_output_present", "intelligence_record_count");
      if(ExtractJsonIntField(json, "intelligence_record_count", int_value) && int_value == 0)
         state.zero_record = true;
      if(ExtractJsonBoolField(json, "artifact_snapshot_emitted", bool_value) && bool_value && state.zero_record)
         state.placeholder_only = true;
      if(ExtractJsonStringField(json, "last_error_code_or_note", text_value))
         state.reason_text = DashboardShortText(text_value);
   }
   else if(state.source_id == "SRC_DASHBOARD_PHASE0_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "phase0_design_lock_defined");
      state.reason_text = "Architecture Defined, Not Operationally Active applies only before Phase 1 render.";
   }
   else if(state.source_id == "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "strategy_transfer_runtime_freeze_active");
      state.reason_text = "Historical freeze provenance only.";
   }
   else if(state.source_id == "SRC_EXECUTION_QUALITY_VALIDATION")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "decisions_total", "executed_trades_total");
      if(ExtractJsonStringField(json, "dominant_block_layer", text_value))
         state.reason_text = "Dominant decision block: " + DashboardShortText(text_value, 80);
   }
   else if(state.source_id == "SRC_OPERATIONAL_INTEGRITY_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "overall_state", "overall_reason");
      if(ExtractJsonStringField(json, "overall_reason", text_value))
         state.reason_text = DashboardShortText(text_value, 100);

      string freshness_state = "";
      if(ExtractJsonStringField(json, "freshness_gate_state", freshness_state) && freshness_state != "FRESH")
      {
         string dominant_surface = "";
         string dominant_reason = "";
         ExtractJsonStringField(json, "dominant_stale_surface", dominant_surface);
         ExtractJsonStringField(json, "dominant_stale_reason", dominant_reason);
         state.summary_text = "Critical-surface freshness: " + DashboardShortText(freshness_state, 32);
         state.reason_text = DashboardShortText(DashboardValueOr(dominant_surface, "surface") + " | " + DashboardValueOr(dominant_reason, "stale"), 100);
      }
   }
   else if(state.source_id == "SRC_EXECUTION_AUTHORITY_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "execution_authority_source", "execution_authority_cutover_state", "active_operating_cohort_defined");
      if(ExtractJsonStringField(json, "execution_block_reason_code", text_value))
         state.reason_text = DashboardShortText(text_value, 96);
      if(ExtractJsonBoolField(json, "execution_globally_blocked", bool_value) && bool_value)
         state.summary_text = "Execution globally blocked";
      else
         state.summary_text = "Cohort-governed execution authority";
   }
   else if(state.source_id == "SRC_ACTIVE_OPERATING_COHORT")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "active_operating_cohort_id", "active_operating_cohort_state", "candidate_count");
      if(ExtractJsonStringField(json, "cohort_scope_note", text_value))
         state.reason_text = DashboardShortText(text_value, 96);
      if(ExtractJsonIntField(json, "candidate_count", int_value) && int_value == 0)
         state.zero_record = true;
      state.summary_text = "Active operating cohort visibility";
   }
   else if(state.source_id == "SRC_OPERATING_RISK_ENVELOPE_STATUS")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "operating_risk_envelope_state", "envelope_clear_for_new_entries");
      if(ExtractJsonStringField(json, "current_block_reason_text", text_value) && StringLen(text_value) > 0)
         state.reason_text = DashboardShortText(text_value, 100);
      else if(ExtractJsonStringField(json, "current_block_reason_code", text_value) && StringLen(text_value) > 0)
         state.reason_text = DashboardShortText(text_value, 100);
      if(ExtractJsonBoolField(json, "envelope_clear_for_new_entries", bool_value) && !bool_value)
         state.summary_text = "Operating guardrail blocked";
      else
         state.summary_text = "Operating envelope clear";
   }
   else if(state.source_id == "SRC_LAST_MEANINGFUL_RUNTIME_EVENT")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "event_type", "event_time");
      if(ExtractJsonStringField(json, "short_note", text_value))
         state.reason_text = DashboardShortText(text_value, 96);
      if(ExtractJsonStringField(json, "event_type", text_value))
         state.summary_text = "Latest event: " + DashboardShortText(text_value, 60);
   }
   else if(state.source_id == "SRC_FACTORY_OPERATIONAL_EVIDENCE")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "decisions_total", "evidence_completeness_state");
      if(ExtractJsonStringField(json, "evidence_completeness_note", text_value))
         state.reason_text = DashboardShortText(text_value, 100);
      if(ExtractJsonStringField(json, "evidence_completeness_state", text_value))
         state.summary_text = "Factory evidence: " + DashboardShortText(text_value, 60);
   }
   else if(state.source_id == "SRC_AI_OPERATIONAL_REVIEW")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "authority_state", "interpretability_state");
      if(ExtractJsonStringField(json, "advisory_scope_note", text_value))
         state.reason_text = DashboardShortText(text_value, 100);
      if(ExtractJsonStringField(json, "interpretability_state", text_value))
         state.summary_text = "AI review: " + DashboardShortText(text_value, 60);
   }
   else if(state.source_id == "SRC_AI_TRADE_FEEDBACK")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "result", "profit");
      if(ExtractJsonStringField(json, "result", text_value))
         state.summary_text = "Last trade result: " + text_value;
   }
   else if(state.source_id == "SRC_TRADE_JOURNAL_SUMMARY")
   {
      state.partial = !DashboardSourceHasRequiredKeys(json, "closed_trade_records", "wins", "losses");
      if(ExtractJsonIntField(json, "closed_trade_records", int_value) && int_value == 0)
         state.zero_record = true;
      if(ExtractJsonBoolField(json, "coverage_partial", bool_value) && bool_value)
         state.placeholder_only = true;
      if(ExtractJsonStringField(json, "coverage_note", text_value))
         state.reason_text = DashboardShortText(text_value, 102);
      state.summary_text = "Internal close-record summary only.";
   }
   else
   {
      state.partial = false;
   }

   if(StringLen(state.reason_text) == 0)
      state.reason_text = state.summary_text;
}

void DashboardFinalizeSourceFreshness(DashboardCollectedSourceState &state)
{
   if(!state.source_present || !state.parse_ok)
   {
      state.stale = false;
      return;
   }

   if(StringLen(state.timestamp_value) == 0)
   {
      state.stale = true;
      return;
   }

   state.timestamp_epoch = DashboardParseTimestamp(state.timestamp_value);
   if(state.timestamp_epoch <= 0)
   {
      state.stale = true;
      return;
   }

   state.stale = ((TimeCurrent() - state.timestamp_epoch) > DashboardStaleWindowSeconds(state.refresh_class));
}

bool DashboardLoadOneSource(const DashboardSourceDefinition &def, DashboardCollectedSourceState &state)
{
   DashboardResetCollectedSource(state, def);
   state.last_poll_time = TimeCurrent();

   if(StringLen(def.runtime_path) == 0)
   {
      state.source_present = true;
      state.parse_ok = true;
      state.summary_text = def.bounded_usage_note;
      state.reason_text = "Embedded contract context only; no runtime file read performed.";
      state.runtime_file_allowed = false;
      state.stale = false;
      return true;
   }

   string raw_text = "";
   state.source_present = DashboardReadRuntimeFile(def.runtime_path, raw_text);
   if(!state.source_present)
   {
      DashboardTryReadFallbackText(def.source_id, state.fallback_text);
      state.parse_ok = false;
      state.partial = true;
      state.reason_text = "Source file missing.";
      return false;
   }

   if(def.source_id == "SRC_TRADE_JOURNAL_SUMMARY")
   {
      string summary_json = "";
      if(!DashboardBuildTradeJournalSummaryJson(raw_text, summary_json))
      {
         state.raw_text = "";
         state.parse_ok = false;
         state.partial = true;
         state.reason_text = "Trade journal summary parsing failed.";
         return false;
      }

      state.raw_text = summary_json;
      state.parse_ok = (StringLen(TrimString(summary_json)) > 0);
      if(DashboardInferTimestamp(summary_json, state.timestamp_value))
      {
      }
      DashboardAssessSourceSemantics(state);
      DashboardFinalizeSourceFreshness(state);
      return true;
   }

   state.raw_text = raw_text;
   state.parse_ok = (StringLen(TrimString(raw_text)) > 0);

   DashboardTryReadFallbackText(def.source_id, state.fallback_text);

   string timestamp_value = "";
   if(DashboardInferTimestamp(raw_text, timestamp_value))
      state.timestamp_value = timestamp_value;

   DashboardAssessSourceSemantics(state);
   DashboardFinalizeSourceFreshness(state);
   return true;
}

void DashboardCollectorEnsureInitialized()
{
   if(g_dashboard_sources_initialized)
      return;

   int count = DashboardBuildSourceRegistry(g_dashboard_source_defs);
   ArrayResize(g_dashboard_sources, count);

   for(int i = 0; i < count; i++)
      DashboardResetCollectedSource(g_dashboard_sources[i], g_dashboard_source_defs[i]);

   g_dashboard_sources_initialized = true;
}

bool DashboardSourceRepollDue(const DashboardCollectedSourceState &state, const DashboardSourceDefinition &def, bool force_reload, bool page_entry_refresh)
{
   if(def.tier == DASHBOARD_SOURCE_TIER_D_NEVER_RENDER_DIRECTLY || def.refresh_class == DASHBOARD_REFRESH_ON_DEMAND)
      return false;

   if(force_reload)
      return true;

   if(state.last_poll_time <= 0)
      return true;

   if(def.refresh_class == DASHBOARD_REFRESH_PAGE_ENTRY_ONLY)
      return page_entry_refresh;

   return ((TimeCurrent() - state.last_poll_time) >= DashboardRefreshWindowSeconds(def.refresh_class));
}

void DashboardCollectorPoll(bool force_reload = false, bool page_entry_refresh = false)
{
   DashboardCollectorEnsureInitialized();

   for(int i = 0; i < ArraySize(g_dashboard_source_defs); i++)
   {
      if(DashboardSourceRepollDue(g_dashboard_sources[i], g_dashboard_source_defs[i], force_reload, page_entry_refresh))
         DashboardLoadOneSource(g_dashboard_source_defs[i], g_dashboard_sources[i]);
   }

   if(force_reload)
      g_dashboard_last_full_reload = TimeCurrent();
   if(page_entry_refresh)
      g_dashboard_last_page_entry_reload = TimeCurrent();
}

int DashboardFindSourceStateIndex(const string source_id)
{
   for(int i = 0; i < ArraySize(g_dashboard_sources); i++)
   {
      if(g_dashboard_sources[i].source_id == source_id)
         return i;
   }

   return -1;
}

bool DashboardGetSourceState(const string source_id, DashboardCollectedSourceState &out_state)
{
   int index = DashboardFindSourceStateIndex(source_id);
   if(index < 0)
      return false;

   out_state = g_dashboard_sources[index];
   return true;
}

string DashboardSourceRawText(const string source_id)
{
   int index = DashboardFindSourceStateIndex(source_id);
   if(index < 0)
      return "";

   return g_dashboard_sources[index].raw_text;
}

bool DashboardGetString(const string source_id, const string key, string &out_value)
{
   out_value = "";
   string raw = DashboardSourceRawText(source_id);
   if(StringLen(raw) == 0)
      return false;

   return ExtractJsonStringField(raw, key, out_value);
}

bool DashboardGetBool(const string source_id, const string key, bool &out_value)
{
   string raw = DashboardSourceRawText(source_id);
   if(StringLen(raw) == 0)
      return false;

   return ExtractJsonBoolField(raw, key, out_value);
}

bool DashboardGetInt(const string source_id, const string key, int &out_value)
{
   string raw = DashboardSourceRawText(source_id);
   if(StringLen(raw) == 0)
      return false;

   return ExtractJsonIntField(raw, key, out_value);
}

bool DashboardGetDouble(const string source_id, const string key, double &out_value)
{
   string raw = DashboardSourceRawText(source_id);
   if(StringLen(raw) == 0)
      return false;

   return ExtractJsonDoubleField(raw, key, out_value);
}

bool DashboardSourceAvailable(const string source_id)
{
   DashboardCollectedSourceState state;
   if(!DashboardGetSourceState(source_id, state))
      return false;

   return (state.source_present && state.parse_ok);
}

#endif
