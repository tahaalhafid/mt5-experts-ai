# SR Chart Visualization Implementation Report v1

## 1) Executive summary
Implemented a bounded MT5 chart overlay for support/resistance visualization only.

The overlay draws:
- final MT5 runtime relied-on support/resistance levels as the primary green layer
- ATAS comparison/reference support/resistance levels as the secondary red layer

No trading, execution, risk, governor, AI authority, or external authority behavior was changed.

## 2) Backup evidence
Pre-change backup:
- `backup_archives/pre_change_20260409_042516_sr_chart_visualization.zip`

Post-change backup:
- `backup_archives/post_change_20260409_043957_sr_chart_visualization_scope.zip`

Locked file exclusion preserved:
- `MQL5/Files/AI/ai_performance_journal.jsonl`

## 3) Files reviewed
- `main_ea.mq5`
- `unified_confidence.mqh`
- `council_mode_types.mqh`
- `atas_governed_advisory_contract.mqh`
- `atas_governed_advisory_layer.mqh`
- `atas_governed_advisory_artifacts.mqh`

## 4) Files modified
- `main_ea.mq5`

## 5) Files created
- `docs/sr_chart_visualization_contract_v1.md`
- `docs/sr_chart_visualization_implementation_report_v1.md`
- `compile_sr_chart_visualization_20260409_043106.log`

## 6) Files intentionally not modified
- execution/trade routing logic
- risk/governor logic
- AI authority/readiness logic
- ATAS advisory authority model
- Databento/Fusion/hybrid activation paths
- semantic-adapter posture

## 7) Final runtime relied-on SR surface
`FINAL_RUNTIME_RELIED_ON` lines are driven by MT5 decision-ready `UnifiedDecisionConfidence` in `BuildUnifiedDecisionConfidence(...)`:
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

## 8) ATAS comparison/reference surface
`ATAS_REFERENCE` lines are driven by `gAtasGovernedAdvisoryStatus`:
- `nearest_support_price`
- `nearest_resistance_price`
- gate/eligibility/attachment fields for diagnostics and classification

## 9) Data precedence logic
1. Final runtime lines (green): MT5 `UnifiedDecisionConfidence` (authoritative decision-ready context).
2. ATAS comparison lines (red): `gAtasGovernedAdvisoryStatus` (non-authoritative comparison/reference).
3. If either surface is blocked/ineligible/unavailable, lines for that layer are omitted and status text is shown.

## 10) Blocked/ineligible/unavailable handling
Classification states implemented:
- `FINAL_RUNTIME_RELIED_ON`
- `ATAS_REFERENCE`
- `BLOCKED_OR_INELIGIBLE`
- `UNAVAILABLE`

No unavailable/blocked level is fabricated as a line.
Status label reports class and reason.

## 11) Visual separation
- Final runtime lines: green, width 3, solid.
- ATAS reference lines: red, width 1, dotted.
- Explicit labels:
  - `FINAL_SUPPORT`
  - `FINAL_RESISTANCE`
  - `ATAS_SUPPORT`
  - `ATAS_RESISTANCE`

## 12) Color confirmation
- Final runtime relied-on layer is green.
- ATAS comparison/reference layer is red.

## 13) Authority boundary preservation
The overlay is chart-only observability:
- no execution permission mutation
- no risk/governor mutation
- no advisory authority escalation
- no external authority transfer

MT5 remains runtime authority; ATAS remains non-authoritative comparison input.

## 14) Compile results
Compiled `main_ea.mq5` with MetaEditor CLI log output:
- `compile_sr_chart_visualization_20260409_043106.log`
- Result: `0 errors, 2 warnings`
- `main_ea.ex5` updated at `2026-04-09 04:37:31` (size `2241226`)

## 15) Residual risks
- Final and ATAS levels may coincide when runtime accepted external context unchanged; visual distinction still preserved by layer/color/style.
- If upstream surfaces omit level values, chart intentionally shows status-only fallback.

## 16) Recommended next bounded runtime validation step
Run one bounded live observation and verify on-chart:
- final green lines track decision-ready levels
- red ATAS lines appear only when ATAS reference is available/eligible
- blocked/unavailable states produce status-only output without fabricated lines

## 17) Scope confirmation
This patch is visualization-only and does not redesign dashboard/runtime strategy.
