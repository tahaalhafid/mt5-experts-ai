# Support/Resistance Chart Visualization Contract v1

## Scope
This contract defines a bounded MT5 chart overlay for support/resistance comparison only.

It is visualization-only and non-authoritative.

## Authority
- MT5 runtime remains the sole authority for execution/risk/governance.
- External ATAS data remains non-authoritative.
- No chart object in this layer can alter trade admission, execution, risk, governor, or AI authority behavior.

## Layering
### Layer A (green): `FINAL_RUNTIME_RELIED_ON`
Source:
- `UnifiedDecisionConfidence` produced by MT5 runtime in `BuildUnifiedDecisionConfidence(...)`.

Primary fields:
- `nearest_support_price`
- `nearest_resistance_price`
- `nearest_support_distance_points`
- `nearest_resistance_distance_points`
- `canonical_level_state`
- `sr_interaction_bucket`
- `level_interaction_type`
- `level_context_supported`
- `level_context_obstructed`
- `level_context_degraded`
- `support_resistance_observation_source`

Classification:
- `FINAL_RUNTIME_RELIED_ON`
- `BLOCKED_OR_INELIGIBLE`
- `UNAVAILABLE`

### Layer B (red): `ATAS_REFERENCE`
Source:
- `gAtasGovernedAdvisoryStatus` (ATAS governed advisory status surface).

Primary fields:
- `nearest_support_price`
- `nearest_resistance_price`
- `gate_reason_code`
- `gate_payload_present`
- `gate_shadow_attached`
- `gate_freshness_valid`
- `gate_source_valid`
- `gate_symbol_mapping_valid`
- `gate_session_valid`
- `gate_translation_valid`
- `advisory_eligible`

Classification:
- `ATAS_REFERENCE`
- `BLOCKED_OR_INELIGIBLE`
- `UNAVAILABLE`

## Visual Semantics
- Final runtime relied-on lines: green, stronger prominence.
- ATAS comparison lines: red, secondary prominence.
- Labels:
  - `FINAL_SUPPORT`
  - `FINAL_RESISTANCE`
  - `ATAS_SUPPORT`
  - `ATAS_RESISTANCE`

## Unavailable/Blocked Handling
- The overlay never fabricates missing levels.
- If final levels are unavailable/blocked, final lines are not drawn.
- If ATAS levels are unavailable/blocked, ATAS lines are not drawn.
- Status label reports classification and reason.

