# Decision Envelope Observability Contract v1

## Purpose
Provide auditable, non-authoritative visibility into how pre-entry decision confidence was shaped before runtime execution attempt.

This contract is descriptive only and must not be used as execution/risk/governor authority.

## Primary Surfaces
- `AI/ai_decision_envelope_trace.jsonl` (append-only per-decision trace)
- `AI/ai_decision_envelope_observability_status.json` (latest status snapshot)
- `AI/ai_performance_journal.jsonl` (decision + trade records with envelope carry-forward)

## Required Envelope Fields
- `base_confidence_score`
- `final_confidence_score`
- `confidence_delta_from_base`
- `policy_risk_score`
- `regime_fit_score`
- `learning_confidence_delta`
- `learning_caution_score`
- `learning_state_code`
- `learning_evidence_count`
- `learning_evidence_threshold_met`
- `learning_zero_influence_due_to_insufficient_evidence`
- `advisory_relevance_score`
- `advisory_contradiction_flag`
- `advisory_hold_bias_active`
- `support_resistance_confluence_state`
- `canonical_level_state`
- `sr_interaction_bucket`
- `sr_confluence_flag`
- `sr_rejection_risk_flag`
- `sr_continuation_obstructed_flag`
- `sr_canonical_near_flag`
- `sr_conflicted_flag`
- `decision_acceptance_posture`
- `decision_reasoning_flags_csv`

## Acceptance Posture Classification (Observability Only)
- `STANDARD`
- `CAUTIOUS`
- `DEGRADED`
- `EXCEPTIONAL`
- `BLOCKED`
- `NON_ENTRY`

## Reasoning Flag Examples
Flags are additive and descriptive:
- `CONTRADICTION_SIGNAL`
- `LEVEL_SENSITIVE_ACCEPTANCE`
- `CONFIDENCE_REDUCED_ACCEPTANCE`
- `REGIME_FIT_IMPAIRED_ACCEPTANCE`
- `CAUTION_SHAPING_ACTIVE`
- `EXCEPTIONAL_CONTEXT_ALIGNMENT`

## Availability Classification
Fields should be treated as:
- directly observed
- deterministic derivation
- unavailable/not captured

No field may be fabricated to fill a gap.

## Governance Lock
Observability outputs:
- do not approve/deny trades directly
- do not alter governor/risk authority
- do not bypass existing policy gates
- do not transfer authority to external/advisory surfaces

