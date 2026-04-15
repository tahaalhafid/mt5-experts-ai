#ifndef __ATAS_GOVERNED_ADVISORY_ARTIFACTS_MQH__
#define __ATAS_GOVERNED_ADVISORY_ARTIFACTS_MQH__

#include "atas_governed_advisory_contract.mqh"

string AtasGovernedAdvisoryStatusTxtPath()        { return "AI\\atas_governed_advisory_status.txt"; }
string AtasGovernedAdvisoryStatusJsonPath()       { return "AI\\atas_governed_advisory_status.json"; }
string AtasGovernedAdvisoryEffectivenessTxtPath() { return "AI\\atas_governed_advisory_effectiveness.txt"; }
string AtasGovernedAdvisoryEffectivenessJsonPath(){ return "AI\\atas_governed_advisory_effectiveness.json"; }
string AtasGovernedAdvisoryLastPacketJsonPath()   { return "AI\\atas_governed_advisory_last_packet.json"; }

string AtasGovAdvisoryEscapeJson(const string src)
{
   string s = src;
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", " ");
   StringReplace(s, "\n", " ");
   return s;
}

string AtasGovAdvisoryBoolText(const bool v)
{
   return (v ? "true" : "false");
}

bool AtasGovAdvisoryWriteTextFileAll(const string relPath, const string text)
{
   int h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

string BuildAtasGovernedAdvisoryStatusText(const AtasGovernedAdvisoryStatus &st)
{
   string t = "";
   t += "artifact_role=" + st.artifact_role + "\n";
   t += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   t += "summary_version=" + st.summary_version + "\n";
   t += "trust_rule=" + st.trust_rule + "\n";
   t += "update_source=" + st.update_source + "\n";
   t += "advisory_integration_enabled=" + AtasGovAdvisoryBoolText(st.advisory_integration_enabled) + "\n";
   t += "advisory_invocation_allowed=" + AtasGovAdvisoryBoolText(st.advisory_invocation_allowed) + "\n";
   t += "advisory_eligible=" + AtasGovAdvisoryBoolText(st.advisory_eligible) + "\n";
   t += "rollout_mode=" + AtasGovernedAdvisoryRolloutModeToText(st.rollout_mode) + "\n";
   t += "advisory_packet_id=" + st.advisory_packet_id + "\n";
   t += "advisory_state=" + AtasGovernedAdvisoryStateToText(st.advisory_state) + "\n";
   t += "advisory_outcome=" + AtasGovernedAdvisoryOutcomeToText(st.advisory_outcome) + "\n";
   t += "advisory_relevance_score=" + DoubleToString(st.advisory_relevance_score, 3) + "\n";
   t += "advisory_confluence_score=" + DoubleToString(st.advisory_confluence_score, 3) + "\n";
   t += "contradiction_flag=" + AtasGovAdvisoryBoolText(st.contradiction_flag) + "\n";
   t += "hold_bias_active=" + AtasGovAdvisoryBoolText(st.hold_bias_active) + "\n";
   t += "confirmation_support_flag=" + AtasGovAdvisoryBoolText(st.confirmation_support_flag) + "\n";
   t += "advisory_reason_codes_csv=" + st.advisory_reason_codes_csv + "\n";
   t += "advisory_summary=" + st.advisory_summary + "\n";
   t += "advisory_attachment_state=" + st.advisory_attachment_state + "\n";
   t += "advisory_ineligibility_reason_code=" + st.advisory_ineligibility_reason_code + "\n";
   t += "advisory_block_class=" + st.advisory_block_class + "\n";
   t += "advisory_usage_state=" + st.advisory_usage_state + "\n";
   t += "advisory_zero_effect_reason=" + st.advisory_zero_effect_reason + "\n";
   t += "support_resistance_confluence_state=" + st.support_resistance_confluence_state + "\n";
   t += "advisory_level_context_state_csv=" + st.advisory_level_context_state_csv + "\n";
   t += "translation_state_summary=" + st.translation_state_summary + "\n";
   t += "nearest_support_price=" + DoubleToString(st.nearest_support_price, 5) + "\n";
   t += "nearest_resistance_price=" + DoubleToString(st.nearest_resistance_price, 5) + "\n";
   t += "nearest_support_distance_points=" + IntegerToString(st.nearest_support_distance_points) + "\n";
   t += "nearest_resistance_distance_points=" + IntegerToString(st.nearest_resistance_distance_points) + "\n";
   t += "level_interaction_type=" + st.level_interaction_type + "\n";
   t += "level_context_supportive=" + AtasGovAdvisoryBoolText(st.level_context_supportive) + "\n";
   t += "level_context_obstructive=" + AtasGovAdvisoryBoolText(st.level_context_obstructive) + "\n";
   t += "level_context_degraded=" + AtasGovAdvisoryBoolText(st.level_context_degraded) + "\n";
   t += "sr_observation_source=" + st.sr_observation_source + "\n";
   t += "candidate_decision_id=" + st.candidate_decision_id + "\n";
   t += "candidate_direction=" + st.candidate_direction + "\n";
   t += "candidate_strategy_family=" + st.candidate_strategy_family + "\n";
   t += "source_symbol=" + st.source_symbol + "\n";
   t += "source_symbol_original=" + st.source_symbol_original + "\n";
   t += "execution_symbol=" + st.execution_symbol + "\n";
   t += "source_mode=" + st.source_mode + "\n";
   t += "freshness_state=" + st.freshness_state + "\n";
   t += "semantic_only_mode=" + AtasGovAdvisoryBoolText(st.semantic_only_mode) + "\n";
   t += "price_anchor_fields_suppressed=" + AtasGovAdvisoryBoolText(st.price_anchor_fields_suppressed) + "\n";
   t += "cross_instrument_translation_applied=" + AtasGovAdvisoryBoolText(st.cross_instrument_translation_applied) + "\n";
   t += "source_reference_price=" + DoubleToString(st.source_reference_price, 5) + "\n";
   t += "execution_reference_price=" + DoubleToString(st.execution_reference_price, 5) + "\n";
   t += "cross_instrument_basis_value=" + DoubleToString(st.cross_instrument_basis_value, 5) + "\n";
   t += "level_candidate_count=" + IntegerToString(st.level_candidate_count) + "\n";
   t += "gate_reason_code=" + st.gate_reason_code + "\n";
   t += "gate_block_class=" + st.gate_block_class + "\n";
   t += "gate_ineligibility_reason_code=" + st.gate_ineligibility_reason_code + "\n";
   t += "gate_attachment_state=" + st.gate_attachment_state + "\n";
   t += "gate_note=" + st.gate_note + "\n";
   t += "gate_payload_present=" + AtasGovAdvisoryBoolText(st.gate_payload_present) + "\n";
   t += "gate_shadow_attached=" + AtasGovAdvisoryBoolText(st.gate_shadow_attached) + "\n";
   t += "gate_freshness_valid=" + AtasGovAdvisoryBoolText(st.gate_freshness_valid) + "\n";
   t += "gate_source_valid=" + AtasGovAdvisoryBoolText(st.gate_source_valid) + "\n";
   t += "gate_symbol_mapping_valid=" + AtasGovAdvisoryBoolText(st.gate_symbol_mapping_valid) + "\n";
   t += "gate_session_valid=" + AtasGovAdvisoryBoolText(st.gate_session_valid) + "\n";
   t += "gate_translation_valid=" + AtasGovAdvisoryBoolText(st.gate_translation_valid) + "\n";
   t += "gate_semantic_only_fallback_used=" + AtasGovAdvisoryBoolText(st.gate_semantic_only_fallback_used) + "\n";
   t += "gate_structural_relevance_valid=" + AtasGovAdvisoryBoolText(st.gate_structural_relevance_valid) + "\n";
   t += "gate_level_context_relevance_valid=" + AtasGovAdvisoryBoolText(st.gate_level_context_relevance_valid) + "\n";
   t += "hold_applied=" + AtasGovAdvisoryBoolText(st.hold_applied) + "\n";
   t += "current_hold_active=" + AtasGovAdvisoryBoolText(st.current_hold_active) + "\n";
   t += "current_hold_signature=" + st.current_hold_signature + "\n";
   t += "current_hold_release_bar_index=" + IntegerToString(st.current_hold_release_bar_index) + "\n";
   t += "current_hold_count_for_signature=" + IntegerToString(st.current_hold_count_for_signature) + "\n";
   t += "non_authoritative_notice=" + st.non_authoritative_notice + "\n";
   t += "evaluated_at=" + TimeToString(st.evaluated_at, TIME_DATE | TIME_SECONDS) + "\n";
   return t;
}

string BuildAtasGovernedAdvisoryStatusJson(const AtasGovernedAdvisoryStatus &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + AtasGovAdvisoryEscapeJson(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + AtasGovAdvisoryEscapeJson(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + AtasGovAdvisoryEscapeJson(st.summary_version) + "\"";
   j += ",\"trust_rule\":\"" + AtasGovAdvisoryEscapeJson(st.trust_rule) + "\"";
   j += ",\"update_source\":\"" + AtasGovAdvisoryEscapeJson(st.update_source) + "\"";
   j += ",\"advisory_integration_enabled\":" + AtasGovAdvisoryBoolText(st.advisory_integration_enabled);
   j += ",\"advisory_invocation_allowed\":" + AtasGovAdvisoryBoolText(st.advisory_invocation_allowed);
   j += ",\"advisory_eligible\":" + AtasGovAdvisoryBoolText(st.advisory_eligible);
   j += ",\"rollout_mode\":\"" + AtasGovAdvisoryEscapeJson(AtasGovernedAdvisoryRolloutModeToText(st.rollout_mode)) + "\"";
   j += ",\"advisory_packet_id\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_packet_id) + "\"";
   j += ",\"advisory_state\":\"" + AtasGovAdvisoryEscapeJson(AtasGovernedAdvisoryStateToText(st.advisory_state)) + "\"";
   j += ",\"advisory_outcome\":\"" + AtasGovAdvisoryEscapeJson(AtasGovernedAdvisoryOutcomeToText(st.advisory_outcome)) + "\"";
   j += ",\"advisory_relevance_score\":" + DoubleToString(st.advisory_relevance_score, 3);
   j += ",\"advisory_confluence_score\":" + DoubleToString(st.advisory_confluence_score, 3);
   j += ",\"contradiction_flag\":" + AtasGovAdvisoryBoolText(st.contradiction_flag);
   j += ",\"hold_bias_active\":" + AtasGovAdvisoryBoolText(st.hold_bias_active);
   j += ",\"confirmation_support_flag\":" + AtasGovAdvisoryBoolText(st.confirmation_support_flag);
   j += ",\"advisory_reason_codes_csv\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_reason_codes_csv) + "\"";
   j += ",\"advisory_summary\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_summary) + "\"";
   j += ",\"advisory_attachment_state\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_attachment_state) + "\"";
   j += ",\"advisory_ineligibility_reason_code\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_ineligibility_reason_code) + "\"";
   j += ",\"advisory_block_class\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_block_class) + "\"";
   j += ",\"advisory_usage_state\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_usage_state) + "\"";
   j += ",\"advisory_zero_effect_reason\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_zero_effect_reason) + "\"";
   j += ",\"support_resistance_confluence_state\":\"" + AtasGovAdvisoryEscapeJson(st.support_resistance_confluence_state) + "\"";
   j += ",\"advisory_level_context_state_csv\":\"" + AtasGovAdvisoryEscapeJson(st.advisory_level_context_state_csv) + "\"";
   j += ",\"translation_state_summary\":\"" + AtasGovAdvisoryEscapeJson(st.translation_state_summary) + "\"";
   j += ",\"nearest_support_price\":" + DoubleToString(st.nearest_support_price, 5);
   j += ",\"nearest_resistance_price\":" + DoubleToString(st.nearest_resistance_price, 5);
   j += ",\"nearest_support_distance_points\":" + IntegerToString(st.nearest_support_distance_points);
   j += ",\"nearest_resistance_distance_points\":" + IntegerToString(st.nearest_resistance_distance_points);
   j += ",\"level_interaction_type\":\"" + AtasGovAdvisoryEscapeJson(st.level_interaction_type) + "\"";
   j += ",\"level_context_supportive\":" + AtasGovAdvisoryBoolText(st.level_context_supportive);
   j += ",\"level_context_obstructive\":" + AtasGovAdvisoryBoolText(st.level_context_obstructive);
   j += ",\"level_context_degraded\":" + AtasGovAdvisoryBoolText(st.level_context_degraded);
   j += ",\"sr_observation_source\":\"" + AtasGovAdvisoryEscapeJson(st.sr_observation_source) + "\"";
   j += ",\"candidate_decision_id\":\"" + AtasGovAdvisoryEscapeJson(st.candidate_decision_id) + "\"";
   j += ",\"candidate_direction\":\"" + AtasGovAdvisoryEscapeJson(st.candidate_direction) + "\"";
   j += ",\"candidate_strategy_family\":\"" + AtasGovAdvisoryEscapeJson(st.candidate_strategy_family) + "\"";
   j += ",\"source_symbol\":\"" + AtasGovAdvisoryEscapeJson(st.source_symbol) + "\"";
   j += ",\"source_symbol_original\":\"" + AtasGovAdvisoryEscapeJson(st.source_symbol_original) + "\"";
   j += ",\"execution_symbol\":\"" + AtasGovAdvisoryEscapeJson(st.execution_symbol) + "\"";
   j += ",\"source_mode\":\"" + AtasGovAdvisoryEscapeJson(st.source_mode) + "\"";
   j += ",\"freshness_state\":\"" + AtasGovAdvisoryEscapeJson(st.freshness_state) + "\"";
   j += ",\"semantic_only_mode\":" + AtasGovAdvisoryBoolText(st.semantic_only_mode);
   j += ",\"price_anchor_fields_suppressed\":" + AtasGovAdvisoryBoolText(st.price_anchor_fields_suppressed);
   j += ",\"cross_instrument_translation_applied\":" + AtasGovAdvisoryBoolText(st.cross_instrument_translation_applied);
   j += ",\"source_reference_price\":" + DoubleToString(st.source_reference_price, 5);
   j += ",\"execution_reference_price\":" + DoubleToString(st.execution_reference_price, 5);
   j += ",\"cross_instrument_basis_value\":" + DoubleToString(st.cross_instrument_basis_value, 5);
   j += ",\"level_candidate_count\":" + IntegerToString(st.level_candidate_count);
   j += ",\"gate_reason_code\":\"" + AtasGovAdvisoryEscapeJson(st.gate_reason_code) + "\"";
   j += ",\"gate_block_class\":\"" + AtasGovAdvisoryEscapeJson(st.gate_block_class) + "\"";
   j += ",\"gate_ineligibility_reason_code\":\"" + AtasGovAdvisoryEscapeJson(st.gate_ineligibility_reason_code) + "\"";
   j += ",\"gate_attachment_state\":\"" + AtasGovAdvisoryEscapeJson(st.gate_attachment_state) + "\"";
   j += ",\"gate_note\":\"" + AtasGovAdvisoryEscapeJson(st.gate_note) + "\"";
   j += ",\"gate_payload_present\":" + AtasGovAdvisoryBoolText(st.gate_payload_present);
   j += ",\"gate_shadow_attached\":" + AtasGovAdvisoryBoolText(st.gate_shadow_attached);
   j += ",\"gate_freshness_valid\":" + AtasGovAdvisoryBoolText(st.gate_freshness_valid);
   j += ",\"gate_source_valid\":" + AtasGovAdvisoryBoolText(st.gate_source_valid);
   j += ",\"gate_symbol_mapping_valid\":" + AtasGovAdvisoryBoolText(st.gate_symbol_mapping_valid);
   j += ",\"gate_session_valid\":" + AtasGovAdvisoryBoolText(st.gate_session_valid);
   j += ",\"gate_translation_valid\":" + AtasGovAdvisoryBoolText(st.gate_translation_valid);
   j += ",\"gate_semantic_only_fallback_used\":" + AtasGovAdvisoryBoolText(st.gate_semantic_only_fallback_used);
   j += ",\"gate_structural_relevance_valid\":" + AtasGovAdvisoryBoolText(st.gate_structural_relevance_valid);
   j += ",\"gate_level_context_relevance_valid\":" + AtasGovAdvisoryBoolText(st.gate_level_context_relevance_valid);
   j += ",\"hold_applied\":" + AtasGovAdvisoryBoolText(st.hold_applied);
   j += ",\"current_hold_active\":" + AtasGovAdvisoryBoolText(st.current_hold_active);
   j += ",\"current_hold_signature\":\"" + AtasGovAdvisoryEscapeJson(st.current_hold_signature) + "\"";
   j += ",\"current_hold_release_bar_index\":" + IntegerToString(st.current_hold_release_bar_index);
   j += ",\"current_hold_count_for_signature\":" + IntegerToString(st.current_hold_count_for_signature);
   j += ",\"non_authoritative_notice\":\"" + AtasGovAdvisoryEscapeJson(st.non_authoritative_notice) + "\"";
   j += ",\"evaluated_at\":\"" + AtasGovAdvisoryEscapeJson(TimeToString(st.evaluated_at, TIME_DATE | TIME_SECONDS)) + "\"";
   j += "}";
   return j;
}

string BuildAtasGovernedAdvisoryEffectivenessText(const AtasGovernedAdvisoryEffectiveness &st)
{
   string t = "";
   t += "artifact_role=" + st.artifact_role + "\n";
   t += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   t += "summary_version=" + st.summary_version + "\n";
   t += "review_window_note=" + st.review_window_note + "\n";
   t += "note=" + st.note + "\n";
   t += "advisory_total=" + IntegerToString(st.advisory_total) + "\n";
   t += "advisory_ok_total=" + IntegerToString(st.advisory_ok_total) + "\n";
   t += "advisory_caution_total=" + IntegerToString(st.advisory_caution_total) + "\n";
   t += "advisory_strong_caution_total=" + IntegerToString(st.advisory_strong_caution_total) + "\n";
   t += "advisory_insufficient_evidence_total=" + IntegerToString(st.advisory_insufficient_evidence_total) + "\n";
   t += "advisory_hold_total=" + IntegerToString(st.advisory_hold_total) + "\n";
   t += "advisory_flag_total=" + IntegerToString(st.advisory_flag_total) + "\n";
   t += "advisory_display_only_total=" + IntegerToString(st.advisory_display_only_total) + "\n";
   t += "advisory_semantic_only_total=" + IntegerToString(st.advisory_semantic_only_total) + "\n";
   t += "advisory_translation_applied_total=" + IntegerToString(st.advisory_translation_applied_total) + "\n";
   t += "advisory_translation_suppressed_total=" + IntegerToString(st.advisory_translation_suppressed_total) + "\n";
   t += "advisory_contradiction_total=" + IntegerToString(st.advisory_contradiction_total) + "\n";
   t += "advisory_confirmation_total=" + IntegerToString(st.advisory_confirmation_total) + "\n";
   t += "rebuilt_at=" + TimeToString(st.rebuilt_at, TIME_DATE | TIME_SECONDS) + "\n";
   return t;
}

string BuildAtasGovernedAdvisoryEffectivenessJson(const AtasGovernedAdvisoryEffectiveness &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + AtasGovAdvisoryEscapeJson(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + AtasGovAdvisoryEscapeJson(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + AtasGovAdvisoryEscapeJson(st.summary_version) + "\"";
   j += ",\"review_window_note\":\"" + AtasGovAdvisoryEscapeJson(st.review_window_note) + "\"";
   j += ",\"note\":\"" + AtasGovAdvisoryEscapeJson(st.note) + "\"";
   j += ",\"advisory_total\":" + IntegerToString(st.advisory_total);
   j += ",\"advisory_ok_total\":" + IntegerToString(st.advisory_ok_total);
   j += ",\"advisory_caution_total\":" + IntegerToString(st.advisory_caution_total);
   j += ",\"advisory_strong_caution_total\":" + IntegerToString(st.advisory_strong_caution_total);
   j += ",\"advisory_insufficient_evidence_total\":" + IntegerToString(st.advisory_insufficient_evidence_total);
   j += ",\"advisory_hold_total\":" + IntegerToString(st.advisory_hold_total);
   j += ",\"advisory_flag_total\":" + IntegerToString(st.advisory_flag_total);
   j += ",\"advisory_display_only_total\":" + IntegerToString(st.advisory_display_only_total);
   j += ",\"advisory_semantic_only_total\":" + IntegerToString(st.advisory_semantic_only_total);
   j += ",\"advisory_translation_applied_total\":" + IntegerToString(st.advisory_translation_applied_total);
   j += ",\"advisory_translation_suppressed_total\":" + IntegerToString(st.advisory_translation_suppressed_total);
   j += ",\"advisory_contradiction_total\":" + IntegerToString(st.advisory_contradiction_total);
   j += ",\"advisory_confirmation_total\":" + IntegerToString(st.advisory_confirmation_total);
   j += ",\"rebuilt_at\":\"" + AtasGovAdvisoryEscapeJson(TimeToString(st.rebuilt_at, TIME_DATE | TIME_SECONDS)) + "\"";
   j += "}";
   return j;
}

string BuildAtasGovernedAdvisoryPacketJson(const AtasGovernedAdvisoryPacket &p, const AtasGovernedAdvisoryGateResult &g)
{
   string j = "{";
   j += "\"artifact_role\":\"ATAS_GOVERNED_ADVISORY_LAST_PACKET\"";
   j += ",\"artifact_authority_class\":\"NON_AUTHORITATIVE_DERIVED_ATAS_ADVISORY\"";
   j += ",\"schema_version\":\"" + AtasGovAdvisoryEscapeJson(ATAS_GOVERNED_ADVISORY_SCHEMA_VERSION) + "\"";
   j += ",\"advisory_packet_id\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_packet_id) + "\"";
   j += ",\"advisory_source\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_source) + "\"";
   j += ",\"advisory_mode\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_mode) + "\"";
   j += ",\"advisory_generation_time\":\"" + AtasGovAdvisoryEscapeJson(TimeToString(p.advisory_generation_time, TIME_DATE | TIME_SECONDS)) + "\"";
   j += ",\"advisory_eligibility_state\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_eligibility_state) + "\"";
   j += ",\"advisory_state\":\"" + AtasGovAdvisoryEscapeJson(AtasGovernedAdvisoryStateToText(p.advisory_state)) + "\"";
   j += ",\"advisory_relevance_score\":" + DoubleToString(p.advisory_relevance_score, 3);
   j += ",\"advisory_confluence_score\":" + DoubleToString(p.advisory_confluence_score, 3);
   j += ",\"advisory_confidence_band\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_confidence_band) + "\"";
   j += ",\"advisory_direction_class\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_direction_class) + "\"";
   j += ",\"advisory_strength_band\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_strength_band) + "\"";
   j += ",\"advisory_reason_codes_csv\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_reason_codes_csv) + "\"";
   j += ",\"advisory_summary_short\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_summary_short) + "\"";
   j += ",\"contradiction_flag\":" + AtasGovAdvisoryBoolText(p.contradiction_flag);
   j += ",\"caution_bias\":" + AtasGovAdvisoryBoolText(p.caution_bias);
   j += ",\"reevaluation_bias\":" + AtasGovAdvisoryBoolText(p.reevaluation_bias);
   j += ",\"hold_bias\":" + AtasGovAdvisoryBoolText(p.hold_bias);
   j += ",\"confirmation_support_flag\":" + AtasGovAdvisoryBoolText(p.confirmation_support_flag);
   j += ",\"advisory_attachment_state\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_attachment_state) + "\"";
   j += ",\"advisory_ineligibility_reason_code\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_ineligibility_reason_code) + "\"";
   j += ",\"advisory_block_class\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_block_class) + "\"";
   j += ",\"advisory_usage_state\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_usage_state) + "\"";
   j += ",\"advisory_zero_effect_reason\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_zero_effect_reason) + "\"";
   j += ",\"translation_state_summary\":\"" + AtasGovAdvisoryEscapeJson(p.translation_state_summary) + "\"";
   j += ",\"support_resistance_confluence_state\":\"" + AtasGovAdvisoryEscapeJson(p.support_resistance_confluence_state) + "\"";
   j += ",\"canonical_level_context_summary\":\"" + AtasGovAdvisoryEscapeJson(p.canonical_level_context_summary) + "\"";
   j += ",\"external_level_confluence_summary\":\"" + AtasGovAdvisoryEscapeJson(p.external_level_confluence_summary) + "\"";
   j += ",\"advisory_level_context_state_csv\":\"" + AtasGovAdvisoryEscapeJson(p.advisory_level_context_state_csv) + "\"";
   j += ",\"nearest_support_price\":" + DoubleToString(p.nearest_support_price, 5);
   j += ",\"nearest_resistance_price\":" + DoubleToString(p.nearest_resistance_price, 5);
   j += ",\"nearest_support_distance_points\":" + IntegerToString(p.nearest_support_distance_points);
   j += ",\"nearest_resistance_distance_points\":" + IntegerToString(p.nearest_resistance_distance_points);
   j += ",\"level_interaction_type\":\"" + AtasGovAdvisoryEscapeJson(p.level_interaction_type) + "\"";
   j += ",\"level_context_supportive\":" + AtasGovAdvisoryBoolText(p.level_context_supportive);
   j += ",\"level_context_obstructive\":" + AtasGovAdvisoryBoolText(p.level_context_obstructive);
   j += ",\"level_context_degraded\":" + AtasGovAdvisoryBoolText(p.level_context_degraded);
   j += ",\"sr_observation_source\":\"" + AtasGovAdvisoryEscapeJson(p.sr_observation_source) + "\"";
   j += ",\"packet_lineage_shadow_packet_id\":\"" + AtasGovAdvisoryEscapeJson(p.packet_lineage_shadow_packet_id) + "\"";
   j += ",\"packet_lineage_trace_id\":\"" + AtasGovAdvisoryEscapeJson(p.packet_lineage_trace_id) + "\"";
   j += ",\"source_symbol\":\"" + AtasGovAdvisoryEscapeJson(p.source_symbol) + "\"";
   j += ",\"source_symbol_original\":\"" + AtasGovAdvisoryEscapeJson(p.source_symbol_original) + "\"";
   j += ",\"execution_symbol\":\"" + AtasGovAdvisoryEscapeJson(p.execution_symbol) + "\"";
   j += ",\"source_mode\":\"" + AtasGovAdvisoryEscapeJson(p.source_mode) + "\"";
   j += ",\"session_context\":\"" + AtasGovAdvisoryEscapeJson(p.session_context) + "\"";
   j += ",\"freshness_state\":\"" + AtasGovAdvisoryEscapeJson(p.freshness_state) + "\"";
   j += ",\"price_space_relation\":\"" + AtasGovAdvisoryEscapeJson(p.price_space_relation) + "\"";
   j += ",\"semantic_only_mode\":" + AtasGovAdvisoryBoolText(p.semantic_only_mode);
   j += ",\"price_anchor_fields_suppressed\":" + AtasGovAdvisoryBoolText(p.price_anchor_fields_suppressed);
   j += ",\"cross_instrument_translation_applied\":" + AtasGovAdvisoryBoolText(p.cross_instrument_translation_applied);
   j += ",\"source_reference_price\":" + DoubleToString(p.source_reference_price, 5);
   j += ",\"execution_reference_price\":" + DoubleToString(p.execution_reference_price, 5);
   j += ",\"cross_instrument_basis_value\":" + DoubleToString(p.cross_instrument_basis_value, 5);
   j += ",\"level_candidate_count\":" + IntegerToString(p.level_candidate_count);
   j += ",\"candidate_decision_id\":\"" + AtasGovAdvisoryEscapeJson(p.candidate_decision_id) + "\"";
   j += ",\"candidate_direction\":\"" + AtasGovAdvisoryEscapeJson(p.candidate_direction) + "\"";
   j += ",\"candidate_strategy_family\":\"" + AtasGovAdvisoryEscapeJson(p.candidate_strategy_family) + "\"";
   j += ",\"gate_applied\":" + AtasGovAdvisoryBoolText(g.gate_applied);
   j += ",\"gate_outcome\":\"" + AtasGovAdvisoryEscapeJson(AtasGovernedAdvisoryOutcomeToText(g.gate_outcome)) + "\"";
   j += ",\"gate_reason_code\":\"" + AtasGovAdvisoryEscapeJson(g.gate_reason_code) + "\"";
   j += ",\"gate_attachment_state\":\"" + AtasGovAdvisoryEscapeJson(g.advisory_attachment_state) + "\"";
   j += ",\"gate_ineligibility_reason_code\":\"" + AtasGovAdvisoryEscapeJson(g.advisory_ineligibility_reason_code) + "\"";
   j += ",\"gate_block_class\":\"" + AtasGovAdvisoryEscapeJson(g.advisory_block_class) + "\"";
   j += ",\"advisory_eligible\":" + AtasGovAdvisoryBoolText(g.advisory_eligible);
   j += ",\"gate_payload_present\":" + AtasGovAdvisoryBoolText(g.payload_present);
   j += ",\"gate_shadow_attached\":" + AtasGovAdvisoryBoolText(g.shadow_attached);
   j += ",\"gate_freshness_valid\":" + AtasGovAdvisoryBoolText(g.freshness_valid);
   j += ",\"gate_source_valid\":" + AtasGovAdvisoryBoolText(g.source_valid);
   j += ",\"gate_symbol_mapping_valid\":" + AtasGovAdvisoryBoolText(g.symbol_mapping_valid);
   j += ",\"gate_session_valid\":" + AtasGovAdvisoryBoolText(g.session_valid);
   j += ",\"gate_translation_valid\":" + AtasGovAdvisoryBoolText(g.translation_valid);
   j += ",\"gate_semantic_only_fallback_used\":" + AtasGovAdvisoryBoolText(g.semantic_only_fallback_used);
   j += ",\"gate_structural_relevance_valid\":" + AtasGovAdvisoryBoolText(g.structural_relevance_valid);
   j += ",\"gate_level_context_relevance_valid\":" + AtasGovAdvisoryBoolText(g.level_context_relevance_valid);
   j += ",\"effective_rollout_mode\":\"" + AtasGovAdvisoryEscapeJson(AtasGovernedAdvisoryRolloutModeToText(g.effective_rollout_mode)) + "\"";
   j += ",\"effective_hold_bars\":" + IntegerToString(g.effective_hold_bars);
   j += ",\"reserved_future_block_eligible\":" + AtasGovAdvisoryBoolText(g.reserved_future_block_eligible);
   j += ",\"evaluated_at\":\"" + AtasGovAdvisoryEscapeJson(TimeToString(p.advisory_generation_time, TIME_DATE | TIME_SECONDS)) + "\"";
   j += "}";
   return j;
}

void SaveAtasGovernedAdvisoryArtifactsBestEffort(const AtasGovernedAdvisoryStatus &status,
                                                 const AtasGovernedAdvisoryEffectiveness &effectiveness,
                                                 const AtasGovernedAdvisoryPacket &packet,
                                                 const AtasGovernedAdvisoryGateResult &gate)
{
   AtasGovAdvisoryWriteTextFileAll(AtasGovernedAdvisoryStatusTxtPath(), BuildAtasGovernedAdvisoryStatusText(status));
   AtasGovAdvisoryWriteTextFileAll(AtasGovernedAdvisoryStatusJsonPath(), BuildAtasGovernedAdvisoryStatusJson(status));
   AtasGovAdvisoryWriteTextFileAll(AtasGovernedAdvisoryEffectivenessTxtPath(), BuildAtasGovernedAdvisoryEffectivenessText(effectiveness));
   AtasGovAdvisoryWriteTextFileAll(AtasGovernedAdvisoryEffectivenessJsonPath(), BuildAtasGovernedAdvisoryEffectivenessJson(effectiveness));
   AtasGovAdvisoryWriteTextFileAll(AtasGovernedAdvisoryLastPacketJsonPath(), BuildAtasGovernedAdvisoryPacketJson(packet, gate));
}

#endif
