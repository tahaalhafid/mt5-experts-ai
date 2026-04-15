# Support/Resistance Quality Upgrade Contract v1

## Scope
Bounded contextual-quality upgrade only. This contract is non-authoritative and does not alter:
- trade admission authority
- execution authority
- risk/governor authority
- external source authority posture

## Primary Objective
Preserve stronger S/R context fidelity per decision and per trade where bounded data exists, and explicitly mark unavailable fields where it does not.

## New/Strengthened S/R Fields

Decision-envelope and trade-open/close evidence now preserve:
- `nearest_support_price`
- `nearest_resistance_price`
- `nearest_support_distance_points`
- `nearest_resistance_distance_points`
- `level_interaction_type`
- `level_context_supported`
- `level_context_obstructed`
- `level_context_degraded`
- `support_resistance_confluence_state`
- `canonical_level_state`
- `sr_interaction_bucket`
- `sr_confluence_flag`
- `sr_rejection_risk_flag`
- `sr_continuation_obstructed_flag`
- `sr_canonical_near_flag`
- `sr_conflicted_flag`
- `support_resistance_observation_source`

## Level Interaction Classification
`level_interaction_type` emits one bounded class:
- `LEVEL_CONTEXT_SUPPORTED`
- `LEVEL_CONTEXT_OBSTRUCTED`
- `LEVEL_CONTEXT_MIXED_CONFLICTED`
- `LEVEL_CONTEXT_DEGRADED`
- `LEVEL_CONTEXT_NEUTRAL`
- `LEVEL_CONTEXT_UNAVAILABLE`

## Evidence Source Markers
S/R quality fields are tagged via source markers:
- `DIRECT_OBSERVED_CANONICAL`
- `SEMANTIC_ONLY_NO_CANONICAL_LEVELS`
- `UNAVAILABLE_NOT_CAPTURED`

## Fallback Rules
If exact numeric S/R values are unavailable, categorical fidelity must still be preserved via:
- interaction type
- confluence/conflict/obstruction/rejection flags
- explicit unavailable source marker

No synthetic S/R prices may be fabricated.

