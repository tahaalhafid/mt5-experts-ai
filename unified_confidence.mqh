#ifndef __UNIFIED_CONFIDENCE_MQH__
#define __UNIFIED_CONFIDENCE_MQH__

#include "strategy_runtime.mqh"

//---------------------------------------------------------
// Unified Confidence Architecture (decision-quality envelope)
//---------------------------------------------------------
struct UnifiedDecisionConfidence
{
   // Strategy Intelligence Layer v1
   double entry_quality_score;        // 0..1
   double timing_quality_score;       // 0..1
   double location_quality_score;     // 0..1
   double volatility_fit_score;       // 0..1
   string entry_quality_label;
   string entry_quality_reason;
   string entry_quality_flags;

   double strategy_regime_fit_score;  // 0..1
   string strategy_regime_fit_label;
   string strategy_regime_reason;

   double decision_quality_score;     // 0..1
   string decision_quality_label;
   string decision_quality_reason;
   string decision_quality_version;   // DQ_V1 / DQ_V2

   // Entry Edge / Follow-through (v2)
   double rr_location_score;                // 0..1
   double entry_edge_score;                 // 0..1
   string entry_edge_label;
   string entry_edge_reason;
   double follow_through_quality_score;     // 0..1
   string follow_through_quality_label;
   string follow_through_reason;

   // Execution Estimation (v3)
   double expected_stop_distance;            // points
   double expected_target_distance;          // points
   double expected_rr_estimate;              // ratio
   double adverse_excursion_risk_score;      // 0..1
   double favorable_excursion_potential_score; // 0..1
   double execution_geometry_score;          // 0..1
   string execution_geometry_label;
   string execution_geometry_reason;

   // Institutional learning (L3 bounded, non-authoritative)
   double learning_confidence_delta;   // capped: [-0.08..+0.08]
   double learning_caution_score;      // capped: [0..0.10]
   double learning_context_fit_score;  // 0..1
   int    learning_evidence_count;     // motif evidence count
   string learning_motif_key;          // context-keyed motif id
   string learning_reason_codes_csv;   // deterministic reason codes
   bool   learning_contradiction_signal;
   bool   learning_hold_bias;
   bool   learning_reevaluation_bias;
   string learning_strength_band;      // NONE / WEAK / MODERATE / STRONG

   string direction;               // BUY / SELL / WAIT / REJECT
   double raw_signal_score;        // -1..+1 (fallback-friendly)
   double base_confidence_score;   // pre-learning baseline confidence (0..1)
   double confidence_score;        // 0..1
   double regime_fit_score;        // 0..1
   double execution_quality_score; // 0..1 (placeholder v1)
   double policy_risk_score;       // 0..1 (placeholder v1)
   double advisory_relevance_score; // 0..1 (observability-only)
   bool   advisory_contradiction_flag;
   bool   advisory_hold_bias_active;
   string support_resistance_confluence_state;
   string canonical_level_state;
   string sr_interaction_bucket;
   double nearest_support_price;
   double nearest_resistance_price;
   int    nearest_support_distance_points;
   int    nearest_resistance_distance_points;
   string level_interaction_type;
   bool   level_context_supported;
   bool   level_context_obstructed;
   bool   level_context_degraded;
   string support_resistance_observation_source;
   bool   sr_confluence_flag;
   bool   sr_rejection_risk_flag;
   bool   sr_continuation_obstructed_flag;
   bool   sr_canonical_near_flag;
   bool   sr_conflicted_flag;
   bool   advisory_available;
   bool   advisory_eligible;
   bool   advisory_shadow_attached;
   string advisory_state;
   string advisory_outcome;
   string advisory_attachment_state;
   string advisory_gate_reason_code;
   string advisory_ineligibility_reason_code;
   string advisory_block_class;
   string advisory_usage_state;
   string advisory_zero_effect_reason;
   string learning_state_code;     // APPLIED / INSUFFICIENT_EVIDENCE / ...
   bool   learning_evidence_threshold_met;
   bool   learning_zero_influence_due_to_insufficient_evidence;
   string decision_acceptance_posture; // STANDARD / CAUTIOUS / DEGRADED / EXCEPTIONAL
   string decision_reasoning_flags_csv;
   bool   final_permission;        // true if execution allowed
   string final_decision_reason;   // short reason
};

void InitUnifiedDecisionConfidence(UnifiedDecisionConfidence &c)
{
   c.direction               = "WAIT";
   c.raw_signal_score        = 0.0;
   c.base_confidence_score   = 0.5;
   c.confidence_score        = 0.5;
   c.regime_fit_score        = 0.5;
   c.execution_quality_score = 0.5;
   c.policy_risk_score       = 0.5;
   c.advisory_relevance_score = 0.0;
   c.advisory_contradiction_flag = false;
   c.advisory_hold_bias_active = false;
   c.support_resistance_confluence_state = "UNSET";
   c.canonical_level_state = "UNSET";
   c.sr_interaction_bucket = "SR_UNKNOWN";
   c.nearest_support_price = 0.0;
   c.nearest_resistance_price = 0.0;
   c.nearest_support_distance_points = -1;
   c.nearest_resistance_distance_points = -1;
   c.level_interaction_type = "LEVEL_CONTEXT_UNSET";
   c.level_context_supported = false;
   c.level_context_obstructed = false;
   c.level_context_degraded = false;
   c.support_resistance_observation_source = "UNAVAILABLE_NOT_CAPTURED";
   c.sr_confluence_flag = false;
   c.sr_rejection_risk_flag = false;
   c.sr_continuation_obstructed_flag = false;
   c.sr_canonical_near_flag = false;
   c.sr_conflicted_flag = false;
   c.advisory_available = false;
   c.advisory_eligible = false;
   c.advisory_shadow_attached = false;
   c.advisory_state = "ATAS_ADVISORY_UNSET";
   c.advisory_outcome = "IGNORE_ADVISORY";
   c.advisory_attachment_state = "ADVISORY_NOT_EVALUATED";
   c.advisory_gate_reason_code = "not_evaluated";
   c.advisory_ineligibility_reason_code = "NOT_EVALUATED";
   c.advisory_block_class = "NOT_EVALUATED";
   c.advisory_usage_state = "ADVISORY_NOT_EVALUATED";
   c.advisory_zero_effect_reason = "NOT_EVALUATED";
   c.learning_state_code = "";
   c.learning_evidence_threshold_met = false;
   c.learning_zero_influence_due_to_insufficient_evidence = false;
   c.decision_acceptance_posture = "STANDARD";
   c.decision_reasoning_flags_csv = "";
   c.final_permission        = false;
   c.final_decision_reason   = "";

   // Strategy Intelligence defaults (non-disruptive)
   c.entry_quality_score        = 0.0;
   c.timing_quality_score       = 0.0;
   c.location_quality_score     = 0.0;
   c.volatility_fit_score       = 0.0;
   c.entry_quality_label        = "";
   c.entry_quality_reason       = "";
   c.entry_quality_flags        = "";

   c.strategy_regime_fit_score  = 0.0;
   c.strategy_regime_fit_label  = "";
   c.strategy_regime_reason     = "";

   c.decision_quality_score     = 0.0;
   c.decision_quality_label     = "";
   c.decision_quality_reason    = "";
   c.decision_quality_version   = "";

   c.rr_location_score            = 0.0;
   c.entry_edge_score             = 0.0;
   c.entry_edge_label             = "";
   c.entry_edge_reason            = "";
   c.follow_through_quality_score = 0.0;
   c.follow_through_quality_label = "";
   c.follow_through_reason        = "";

   c.expected_stop_distance                = 0.0;
   c.expected_target_distance              = 0.0;
   c.expected_rr_estimate                  = 0.0;
   c.adverse_excursion_risk_score          = 0.0;
   c.favorable_excursion_potential_score   = 0.0;
   c.execution_geometry_score              = 0.0;
   c.execution_geometry_label              = "";
   c.execution_geometry_reason             = "";

   c.learning_confidence_delta    = 0.0;
   c.learning_caution_score       = 0.0;
   c.learning_context_fit_score   = 0.5;
   c.learning_evidence_count      = 0;
   c.learning_motif_key           = "";
   c.learning_reason_codes_csv    = "";
   c.learning_contradiction_signal = false;
   c.learning_hold_bias           = false;
   c.learning_reevaluation_bias   = false;
   c.learning_strength_band       = "NONE";
}

string UnifiedDirectionText(RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY)  return "BUY";
   if(d == RUNTIME_ENTER_SELL) return "SELL";
   if(d == RUNTIME_REJECT)     return "REJECT";
   return "WAIT";
}

double UnifiedRawSignalScore(RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY)  return 1.0;
   if(d == RUNTIME_ENTER_SELL) return -1.0;
   return 0.0;
}

#endif
