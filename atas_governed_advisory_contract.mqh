#ifndef __ATAS_GOVERNED_ADVISORY_CONTRACT_MQH__
#define __ATAS_GOVERNED_ADVISORY_CONTRACT_MQH__

//---------------------------------------------------------
// ATAS governed advisory constants
//---------------------------------------------------------
#define ATAS_GOVERNED_ADVISORY_SCHEMA_VERSION "ATAS_GOVERNED_ADVISORY_V1"
#define ATAS_GOVERNED_ADVISORY_STATUS_VERSION "ATAS_GOVERNED_ADVISORY_STATUS_V1"
#define ATAS_GOVERNED_ADVISORY_EFFECTIVENESS_VERSION "ATAS_GOVERNED_ADVISORY_EFFECTIVENESS_V1"

//---------------------------------------------------------
// Advisory state
//---------------------------------------------------------
enum AtasGovernedAdvisoryState
{
   ATAS_ADVISORY_UNSET = 0,
   ATAS_ADVISORY_UNAVAILABLE,
   ATAS_ADVISORY_INELIGIBLE,
   ATAS_ADVISORY_OK,
   ATAS_ADVISORY_CAUTION,
   ATAS_ADVISORY_STRONG_CAUTION,
   ATAS_ADVISORY_INSUFFICIENT_EVIDENCE
};

//---------------------------------------------------------
// Advisory outcome
//---------------------------------------------------------
enum AtasGovernedAdvisoryOutcome
{
   ATAS_ADVISORY_OUTCOME_IGNORE = 0,
   ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY,
   ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR,
   ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION,
   ATAS_ADVISORY_OUTCOME_BLOCK_CANDIDATE_ELIGIBLE
};

//---------------------------------------------------------
// Rollout mode
//---------------------------------------------------------
enum AtasGovernedAdvisoryRolloutMode
{
   ATAS_ADVISORY_ROLLOUT_OBSERVE_ONLY = 0,
   ATAS_ADVISORY_ROLLOUT_SOFT_INFLUENCE = 1,
   ATAS_ADVISORY_ROLLOUT_HOLD_REEVALUATE = 2
};

string AtasGovernedAdvisoryStateToText(const AtasGovernedAdvisoryState state)
{
   if(state == ATAS_ADVISORY_UNAVAILABLE) return "ATAS_ADVISORY_UNAVAILABLE";
   if(state == ATAS_ADVISORY_INELIGIBLE) return "ATAS_ADVISORY_INELIGIBLE";
   if(state == ATAS_ADVISORY_OK) return "ATAS_ADVISORY_OK";
   if(state == ATAS_ADVISORY_CAUTION) return "ATAS_ADVISORY_CAUTION";
   if(state == ATAS_ADVISORY_STRONG_CAUTION) return "ATAS_ADVISORY_STRONG_CAUTION";
   if(state == ATAS_ADVISORY_INSUFFICIENT_EVIDENCE) return "ATAS_ADVISORY_INSUFFICIENT_EVIDENCE";
   return "ATAS_ADVISORY_UNSET";
}

string AtasGovernedAdvisoryOutcomeToText(const AtasGovernedAdvisoryOutcome outcome)
{
   if(outcome == ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY) return "DISPLAY_ONLY";
   if(outcome == ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR) return "FLAG_FOR_OPERATOR";
   if(outcome == ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION) return "HOLD_FOR_REEVALUATION";
   if(outcome == ATAS_ADVISORY_OUTCOME_BLOCK_CANDIDATE_ELIGIBLE) return "BLOCK_CANDIDATE_ELIGIBLE";
   return "IGNORE_ADVISORY";
}

string AtasGovernedAdvisoryRolloutModeToText(const AtasGovernedAdvisoryRolloutMode mode)
{
   if(mode == ATAS_ADVISORY_ROLLOUT_SOFT_INFLUENCE) return "ATAS_ADVISORY_ROLLOUT_SOFT_INFLUENCE";
   if(mode == ATAS_ADVISORY_ROLLOUT_HOLD_REEVALUATE) return "ATAS_ADVISORY_ROLLOUT_HOLD_REEVALUATE";
   return "ATAS_ADVISORY_ROLLOUT_OBSERVE_ONLY";
}

AtasGovernedAdvisoryRolloutMode AtasGovernedAdvisoryRolloutModeFromInput(const int value)
{
   if(value <= 0) return ATAS_ADVISORY_ROLLOUT_OBSERVE_ONLY;
   if(value == 1) return ATAS_ADVISORY_ROLLOUT_SOFT_INFLUENCE;
   return ATAS_ADVISORY_ROLLOUT_HOLD_REEVALUATE;
}

//---------------------------------------------------------
// Advisory packet
//---------------------------------------------------------
struct AtasGovernedAdvisoryPacket
{
   bool     valid;

   string   advisory_packet_id;
   string   advisory_schema_version;
   string   advisory_source;
   string   advisory_mode;
   datetime advisory_generation_time;
   string   advisory_eligibility_state;
   AtasGovernedAdvisoryState advisory_state;

   double   advisory_relevance_score;
   double   advisory_confluence_score;
   string   advisory_confidence_band;
   string   advisory_direction_class;
   string   advisory_strength_band;
   string   advisory_reason_codes_csv;
   string   advisory_summary_short;

   bool     contradiction_flag;
   bool     caution_bias;
   bool     reevaluation_bias;
   bool     hold_bias;
   bool     confirmation_support_flag;
   string   advisory_attachment_state;
   string   advisory_ineligibility_reason_code;
   string   advisory_block_class;
   string   advisory_usage_state;
   string   advisory_zero_effect_reason;

   string   translation_state_summary;
   string   support_resistance_confluence_state;
   string   canonical_level_context_summary;
   string   external_level_confluence_summary;
   string   advisory_level_context_state_csv;
   double   nearest_support_price;
   double   nearest_resistance_price;
   int      nearest_support_distance_points;
   int      nearest_resistance_distance_points;
   string   level_interaction_type;
   bool     level_context_supportive;
   bool     level_context_obstructive;
   bool     level_context_degraded;
   string   sr_observation_source;

   string   packet_lineage_shadow_packet_id;
   string   packet_lineage_trace_id;

   string   source_symbol;
   string   source_symbol_original;
   string   execution_symbol;
   string   source_mode;
   string   session_context;
   string   freshness_state;
   string   price_space_relation;

   bool     semantic_only_mode;
   bool     price_anchor_fields_suppressed;
   bool     cross_instrument_translation_applied;
   double   source_reference_price;
   double   execution_reference_price;
   double   cross_instrument_basis_value;

   int      level_candidate_count;
   string   candidate_decision_id;
   string   candidate_direction;
   string   candidate_strategy_family;
};

//---------------------------------------------------------
// Deterministic relevance gate result
//---------------------------------------------------------
struct AtasGovernedAdvisoryGateResult
{
   bool     gate_applied;
   bool     advisory_eligible;
   AtasGovernedAdvisoryOutcome gate_outcome;
   string   gate_reason_code;

   bool     payload_present;
   bool     shadow_attached;
   bool     freshness_valid;
   bool     source_valid;
   bool     symbol_mapping_valid;
   bool     session_valid;
   bool     translation_valid;
   bool     semantic_only_fallback_used;
   bool     structural_relevance_valid;
   bool     level_context_relevance_valid;

   bool     contradiction_flag;
   string   advisory_attachment_state;
   string   advisory_ineligibility_reason_code;
   string   advisory_block_class;
   bool     hold_applied;
   int      effective_hold_bars;
   int      effective_hold_limit_per_signature;
   AtasGovernedAdvisoryRolloutMode effective_rollout_mode;
   bool     reserved_future_block_eligible;

   double   effective_relevance_score;
   double   effective_confluence_score;
   string   gate_note;
};

//---------------------------------------------------------
// Hold state
//---------------------------------------------------------
struct AtasGovernedAdvisoryHoldState
{
   bool     active;
   string   candidate_signature;
   string   decision_id;
   string   direction;
   string   advisory_packet_id;
   string   hold_reason_code;
   datetime held_at;
   int      release_bar_index;
   int      holds_used_for_signature;
   int      signature_anchor_bar_index;
};

//---------------------------------------------------------
// Runtime status artifact
//---------------------------------------------------------
struct AtasGovernedAdvisoryStatus
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   trust_rule;
   string   update_source;

   bool     advisory_integration_enabled;
   bool     advisory_invocation_allowed;
   bool     advisory_eligible;
   AtasGovernedAdvisoryRolloutMode rollout_mode;

   string   advisory_packet_id;
   AtasGovernedAdvisoryState advisory_state;
   AtasGovernedAdvisoryOutcome advisory_outcome;
   double   advisory_relevance_score;
   double   advisory_confluence_score;
   bool     contradiction_flag;
   bool     hold_bias_active;
   bool     confirmation_support_flag;
   string   advisory_reason_codes_csv;
   string   advisory_summary;
   string   advisory_attachment_state;
   string   advisory_ineligibility_reason_code;
   string   advisory_block_class;
   string   advisory_usage_state;
   string   advisory_zero_effect_reason;
   string   support_resistance_confluence_state;
   string   advisory_level_context_state_csv;
   string   translation_state_summary;
   double   nearest_support_price;
   double   nearest_resistance_price;
   int      nearest_support_distance_points;
   int      nearest_resistance_distance_points;
   string   level_interaction_type;
   bool     level_context_supportive;
   bool     level_context_obstructive;
   bool     level_context_degraded;
   string   sr_observation_source;

   string   candidate_decision_id;
   string   candidate_direction;
   string   candidate_strategy_family;

   string   source_symbol;
   string   source_symbol_original;
   string   execution_symbol;
   string   source_mode;
   string   freshness_state;
   bool     semantic_only_mode;
   bool     price_anchor_fields_suppressed;
   bool     cross_instrument_translation_applied;
   double   source_reference_price;
   double   execution_reference_price;
   double   cross_instrument_basis_value;
   int      level_candidate_count;

   string   gate_reason_code;
   string   gate_block_class;
   string   gate_ineligibility_reason_code;
   string   gate_attachment_state;
   string   gate_note;
   bool     gate_payload_present;
   bool     gate_shadow_attached;
   bool     gate_freshness_valid;
   bool     gate_source_valid;
   bool     gate_symbol_mapping_valid;
   bool     gate_session_valid;
   bool     gate_translation_valid;
   bool     gate_semantic_only_fallback_used;
   bool     gate_structural_relevance_valid;
   bool     gate_level_context_relevance_valid;
   bool     hold_applied;
   bool     current_hold_active;
   string   current_hold_signature;
   int      current_hold_release_bar_index;
   int      current_hold_count_for_signature;

   string   non_authoritative_notice;
   datetime evaluated_at;
};

//---------------------------------------------------------
// Effectiveness artifact
//---------------------------------------------------------
struct AtasGovernedAdvisoryEffectiveness
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   review_window_note;
   string   note;

   int      advisory_total;
   int      advisory_ok_total;
   int      advisory_caution_total;
   int      advisory_strong_caution_total;
   int      advisory_insufficient_evidence_total;
   int      advisory_hold_total;
   int      advisory_flag_total;
   int      advisory_display_only_total;
   int      advisory_semantic_only_total;
   int      advisory_translation_applied_total;
   int      advisory_translation_suppressed_total;
   int      advisory_contradiction_total;
   int      advisory_confirmation_total;

   datetime rebuilt_at;
};

void InitAtasGovernedAdvisoryPacket(AtasGovernedAdvisoryPacket &p)
{
   p.valid = false;
   p.advisory_packet_id = "";
   p.advisory_schema_version = ATAS_GOVERNED_ADVISORY_SCHEMA_VERSION;
   p.advisory_source = "ATAS";
   p.advisory_mode = "GOVERNED_BOUNDED_NON_AUTHORITATIVE";
   p.advisory_generation_time = 0;
   p.advisory_eligibility_state = "UNSET";
   p.advisory_state = ATAS_ADVISORY_UNSET;

   p.advisory_relevance_score = 0.0;
   p.advisory_confluence_score = 0.0;
   p.advisory_confidence_band = "LOW";
   p.advisory_direction_class = "NEUTRAL";
   p.advisory_strength_band = "NONE";
   p.advisory_reason_codes_csv = "";
   p.advisory_summary_short = "";

   p.contradiction_flag = false;
   p.caution_bias = false;
   p.reevaluation_bias = false;
   p.hold_bias = false;
   p.confirmation_support_flag = false;
   p.advisory_attachment_state = "ADVISORY_NOT_EVALUATED";
   p.advisory_ineligibility_reason_code = "NOT_EVALUATED";
   p.advisory_block_class = "NOT_EVALUATED";
   p.advisory_usage_state = "ADVISORY_NOT_EVALUATED";
   p.advisory_zero_effect_reason = "NOT_EVALUATED";

   p.translation_state_summary = "UNKNOWN";
   p.support_resistance_confluence_state = "UNSET";
   p.canonical_level_context_summary = "";
   p.external_level_confluence_summary = "";
   p.advisory_level_context_state_csv = "";
   p.nearest_support_price = 0.0;
   p.nearest_resistance_price = 0.0;
   p.nearest_support_distance_points = -1;
   p.nearest_resistance_distance_points = -1;
   p.level_interaction_type = "LEVEL_CONTEXT_UNSET";
   p.level_context_supportive = false;
   p.level_context_obstructive = false;
   p.level_context_degraded = false;
   p.sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";

   p.packet_lineage_shadow_packet_id = "";
   p.packet_lineage_trace_id = "";

   p.source_symbol = "";
   p.source_symbol_original = "";
   p.execution_symbol = "";
   p.source_mode = "";
   p.session_context = "";
   p.freshness_state = "UNKNOWN";
   p.price_space_relation = "";

   p.semantic_only_mode = false;
   p.price_anchor_fields_suppressed = false;
   p.cross_instrument_translation_applied = false;
   p.source_reference_price = 0.0;
   p.execution_reference_price = 0.0;
   p.cross_instrument_basis_value = 0.0;

   p.level_candidate_count = 0;
   p.candidate_decision_id = "";
   p.candidate_direction = "";
   p.candidate_strategy_family = "";
}

void InitAtasGovernedAdvisoryGateResult(AtasGovernedAdvisoryGateResult &g)
{
   g.gate_applied = false;
   g.advisory_eligible = false;
   g.gate_outcome = ATAS_ADVISORY_OUTCOME_IGNORE;
   g.gate_reason_code = "not_evaluated";

   g.payload_present = false;
   g.shadow_attached = false;
   g.freshness_valid = false;
   g.source_valid = false;
   g.symbol_mapping_valid = false;
   g.session_valid = false;
   g.translation_valid = false;
   g.semantic_only_fallback_used = false;
   g.structural_relevance_valid = false;
   g.level_context_relevance_valid = false;

   g.contradiction_flag = false;
   g.advisory_attachment_state = "ADVISORY_NOT_EVALUATED";
   g.advisory_ineligibility_reason_code = "NOT_EVALUATED";
   g.advisory_block_class = "NOT_EVALUATED";
   g.hold_applied = false;
   g.effective_hold_bars = 0;
   g.effective_hold_limit_per_signature = 0;
   g.effective_rollout_mode = ATAS_ADVISORY_ROLLOUT_OBSERVE_ONLY;
   g.reserved_future_block_eligible = false;

   g.effective_relevance_score = 0.0;
   g.effective_confluence_score = 0.0;
   g.gate_note = "";
}

void InitAtasGovernedAdvisoryHoldState(AtasGovernedAdvisoryHoldState &h)
{
   h.active = false;
   h.candidate_signature = "";
   h.decision_id = "";
   h.direction = "";
   h.advisory_packet_id = "";
   h.hold_reason_code = "";
   h.held_at = 0;
   h.release_bar_index = -100000;
   h.holds_used_for_signature = 0;
   h.signature_anchor_bar_index = -100000;
}

void InitAtasGovernedAdvisoryStatus(AtasGovernedAdvisoryStatus &s)
{
   s.artifact_role = "ATAS_GOVERNED_ADVISORY_STATUS";
   s.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_ATAS_ADVISORY";
   s.summary_version = ATAS_GOVERNED_ADVISORY_STATUS_VERSION;
   s.trust_rule = "advisory_only_non_authoritative_no_execution_no_risk_no_governor";
   s.update_source = "RUNTIME_CANDIDATE_EVALUATION";

   s.advisory_integration_enabled = false;
   s.advisory_invocation_allowed = false;
   s.advisory_eligible = false;
   s.rollout_mode = ATAS_ADVISORY_ROLLOUT_OBSERVE_ONLY;

   s.advisory_packet_id = "";
   s.advisory_state = ATAS_ADVISORY_UNSET;
   s.advisory_outcome = ATAS_ADVISORY_OUTCOME_IGNORE;
   s.advisory_relevance_score = 0.0;
   s.advisory_confluence_score = 0.0;
   s.contradiction_flag = false;
   s.hold_bias_active = false;
   s.confirmation_support_flag = false;
   s.advisory_reason_codes_csv = "";
   s.advisory_summary = "";
   s.advisory_attachment_state = "ADVISORY_NOT_EVALUATED";
   s.advisory_ineligibility_reason_code = "NOT_EVALUATED";
   s.advisory_block_class = "NOT_EVALUATED";
   s.advisory_usage_state = "ADVISORY_NOT_EVALUATED";
   s.advisory_zero_effect_reason = "NOT_EVALUATED";
   s.support_resistance_confluence_state = "UNSET";
   s.advisory_level_context_state_csv = "";
   s.translation_state_summary = "UNKNOWN";
   s.nearest_support_price = 0.0;
   s.nearest_resistance_price = 0.0;
   s.nearest_support_distance_points = -1;
   s.nearest_resistance_distance_points = -1;
   s.level_interaction_type = "LEVEL_CONTEXT_UNSET";
   s.level_context_supportive = false;
   s.level_context_obstructive = false;
   s.level_context_degraded = false;
   s.sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";

   s.candidate_decision_id = "";
   s.candidate_direction = "";
   s.candidate_strategy_family = "";

   s.source_symbol = "";
   s.source_symbol_original = "";
   s.execution_symbol = "";
   s.source_mode = "";
   s.freshness_state = "UNKNOWN";
   s.semantic_only_mode = false;
   s.price_anchor_fields_suppressed = false;
   s.cross_instrument_translation_applied = false;
   s.source_reference_price = 0.0;
   s.execution_reference_price = 0.0;
   s.cross_instrument_basis_value = 0.0;
   s.level_candidate_count = 0;

   s.gate_reason_code = "not_evaluated";
   s.gate_block_class = "NOT_EVALUATED";
   s.gate_ineligibility_reason_code = "NOT_EVALUATED";
   s.gate_attachment_state = "ADVISORY_NOT_EVALUATED";
   s.gate_note = "";
   s.gate_payload_present = false;
   s.gate_shadow_attached = false;
   s.gate_freshness_valid = false;
   s.gate_source_valid = false;
   s.gate_symbol_mapping_valid = false;
   s.gate_session_valid = false;
   s.gate_translation_valid = false;
   s.gate_semantic_only_fallback_used = false;
   s.gate_structural_relevance_valid = false;
   s.gate_level_context_relevance_valid = false;
   s.hold_applied = false;
   s.current_hold_active = false;
   s.current_hold_signature = "";
   s.current_hold_release_bar_index = -100000;
   s.current_hold_count_for_signature = 0;
   s.non_authoritative_notice = "ATAS advisory is bounded contextual intelligence only; MT5 runtime authority remains canonical.";
   s.evaluated_at = 0;
}

void InitAtasGovernedAdvisoryEffectiveness(AtasGovernedAdvisoryEffectiveness &e)
{
   e.artifact_role = "ATAS_GOVERNED_ADVISORY_EFFECTIVENESS";
   e.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_ATAS_ADVISORY_EVIDENCE";
   e.summary_version = ATAS_GOVERNED_ADVISORY_EFFECTIVENESS_VERSION;
   e.review_window_note = "runtime_since_startup";
   e.note = "bounded_advisory_effectiveness_observability_only";

   e.advisory_total = 0;
   e.advisory_ok_total = 0;
   e.advisory_caution_total = 0;
   e.advisory_strong_caution_total = 0;
   e.advisory_insufficient_evidence_total = 0;
   e.advisory_hold_total = 0;
   e.advisory_flag_total = 0;
   e.advisory_display_only_total = 0;
   e.advisory_semantic_only_total = 0;
   e.advisory_translation_applied_total = 0;
   e.advisory_translation_suppressed_total = 0;
   e.advisory_contradiction_total = 0;
   e.advisory_confirmation_total = 0;
   e.rebuilt_at = 0;
}

#endif
