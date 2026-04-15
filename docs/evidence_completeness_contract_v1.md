# Evidence Completeness Contract v1

## Scope
This contract defines bounded, non-authoritative forensic evidence fields emitted for per-trade analysis.

It does not change:
- execution authority
- risk/governor authority
- trade admission semantics
- external authority posture

## Surface Classification
- Runtime authority truth: MT5 runtime execution/governance decisions (unchanged).
- Status truth: bounded status summaries (non-authoritative).
- Evidence truth: append-only trade/decision evidence records.
- Derived forensic truth: deterministic derived fields from bounded evidence.

## Primary Evidence Surfaces
- `AI/ai_performance_journal.jsonl` (append-only record stream)
- `AI/ai_trade_evidence_completeness_status.json` (latest completeness status snapshot)

## Trade Evidence Fields (v1)
For each closed trade forensic record, the following are emitted where available:

Direct/derived price lifecycle fields:
- `requested_entry_price`
- `actual_entry_fill_price`
- `exit_fill_price`
- `initial_stop_loss`
- `initial_take_profit`
- `slippage_points`
- `stop_target_modifications_state`
- `max_favorable_excursion_points`
- `max_adverse_excursion_points`

Confidence/policy/regime envelope at entry:
- `base_confidence_score_at_entry`
- `final_confidence_score_at_entry`
- `policy_risk_score_at_entry`
- `regime_fit_score_at_entry`
- `learning_confidence_delta_at_entry`
- `learning_caution_delta_at_entry`
- `learning_state_code_at_entry`
- `learning_evidence_count_at_entry`
- `learning_evidence_threshold_met_at_entry`
- `learning_zero_influence_due_to_insufficient_evidence_at_entry`
- `advisory_shaping_delta_at_entry`
- `decision_acceptance_posture_at_entry`
- `decision_reasoning_flags_at_entry`

Support/resistance and advisory context at entry:
- `support_resistance_confluence_state`
- `canonical_level_state`
- `sr_interaction_bucket`
- `sr_confluence_flag`
- `sr_rejection_risk_flag`
- `sr_continuation_obstructed_flag`
- `sr_canonical_near_flag`
- `sr_conflicted_flag`
- `advisory_contradiction_flag`
- `advisory_relevance_score`

Exit attribution support fields:
- `exit_reason`
- `exit_class`
- `result`
- `profit`

## Availability and Provenance Markers
Every key evidence field must carry bounded provenance markers where applicable:
- `DIRECT_OBSERVED`
- `DERIVED_FROM_*`
- `UNAVAILABLE_NOT_CAPTURED`
- `UNAVAILABLE_NOT_DERIVABLE`
- `NOT_CAPTURED_IN_BOUNDED_SURFACES`

## Unavailable by Design (Current Bounded Scope)
The following remain out of bounded capture unless existing runtime surfaces provide them later:
- nearest support numeric level
- nearest resistance numeric level
- explicit numeric distance-to-level values
- full stop/target modification timeline
- full MFE/MAE lifecycle path beyond bounded placeholders

These must remain explicitly marked unavailable, not silently omitted.

