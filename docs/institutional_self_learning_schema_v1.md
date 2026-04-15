# Institutional Self-Learning Schema v1

## Surface Classification
- Runtime authority truth: MT5 decision/execution/risk/governor sources (unchanged).
- Runtime status: `AI/ai_institutional_learning_status.json` (+ `.txt`).
- Evidence truth: `AI/ai_institutional_learning_events.jsonl`, `AI/ai_institutional_learning_decision_context.jsonl`.
- Derived learning truth: `AI/ai_institutional_learning_memory.json`.

## Decision Context Record (`ai_institutional_learning_decision_context.jsonl`)
Each line is one JSON object:
- `record_type` = `DECISION_CONTEXT`
- `captured_at`
- `decision_id`
- `symbol`
- `strategy_id`
- `strategy_family`
- `direction`
- `regime_bucket`
- `volatility_bucket`
- `structure_bucket`
- `setup_quality_bucket`
- `sr_interaction_bucket`
- `advisory_contradiction_flag`
- `advisory_hold_bias_active`
- `advisory_relevance_score`
- `advisory_reason_summary`
- `decision_quality_label`
- `entry_quality_label`
- `entry_edge_label`
- `follow_through_label`
- `execution_geometry_label`
- `expected_rr_estimate`
- `motif_key`

## Learning Event Record (`ai_institutional_learning_events.jsonl`)
Each line is one JSON object:
- `record_type` = `LEARNING_EVENT`
- `event_family` = `INSTITUTIONAL_SELF_LEARNING`
- `captured_at`
- `symbol`
- `decision_id`
- `correlated_decision_id`
- `position_id`
- `close_deal_id`
- `trade_result`
- `profit`
- `regime_label`
- `volatility_state`
- `structure_state`
- `strategy_id`
- `strategy_family`
- `direction`
- `motif_key`
- `setup_quality_bucket`
- `sr_interaction_bucket`
- `advisory_contradiction_flag`
- `advisory_relevance_score`
- `primary_attribution`
- `secondary_attribution`
- `attribution_reason_codes_csv`
- `non_authoritative_notice`

## Derived Memory (`ai_institutional_learning_memory.json`)
Top-level:
- `artifact_role` = `AI_INSTITUTIONAL_LEARNING_MEMORY`
- `artifact_authority_class` = `DERIVED_LEARNING_TRUTH_NON_EXECUTION`
- `summary_version`
- `trust_rule`
- `generated_at`
- `motif_count`
- `total_events`
- `motifs` (array)

Motif object fields:
- `motif_key`
- `strategy_id`
- `strategy_family`
- `direction`
- `regime_bucket`
- `volatility_bucket`
- `structure_bucket`
- `setup_quality_bucket`
- `sr_interaction_bucket`
- `advisory_contradiction_flag`
- `evidence_count`
- `wins`
- `losses`
- `flats`
- `net_edge_ewma`
- `caution_ewma`
- `context_fit_ewma`
- `recent_outcomes`
- `last_primary_attribution`
- `last_secondary_attribution`
- `last_reason_codes_csv`
- `last_updated`

## Runtime Status (`ai_institutional_learning_status.json`)
- `artifact_role` = `AI_INSTITUTIONAL_LEARNING_STATUS`
- `artifact_authority_class` = `NON_AUTHORITATIVE_DERIVED_LEARNING_STATUS`
- `summary_version`
- `trust_rule`
- `update_source`
- `learning_enabled`
- `initialized`
- `motif_count`
- `total_events`
- `state_code`
- `reason_codes_csv`
- `last_motif_key`
- `last_evidence_count`
- `last_confidence_delta`
- `last_caution_score`
- `last_context_fit_score`
- `last_contradiction_signal`
- `last_hold_bias`
- `last_reevaluation_bias`
- `last_strength_band`
- `non_authoritative_notice`
- `evaluated_at`

## Confidence Envelope Extensions (`UnifiedDecisionConfidence`)
- `learning_confidence_delta`
- `learning_caution_score`
- `learning_context_fit_score`
- `learning_evidence_count`
- `learning_motif_key`
- `learning_reason_codes_csv`
- `learning_contradiction_signal`
- `learning_hold_bias`
- `learning_reevaluation_bias`
- `learning_strength_band`

These fields are bounded and non-authoritative. They must not be interpreted as execution permission or risk/governor control.
