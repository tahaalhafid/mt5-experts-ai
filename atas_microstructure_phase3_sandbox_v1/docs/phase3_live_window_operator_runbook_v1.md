# Phase 3 Live-Window Operator Runbook v1

## Live Verification Run Order
Run from `MQL5/Experts/AI`:
1. `powershell -ExecutionPolicy Bypass -File .\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_weekend_safe_prelive_pass.ps1 -MarketState LIVE_WINDOW -Cycles 5 -IntervalSeconds 1`

## Rollback / Stop Rule
Stop the run and hold `PARTIALLY_CLOSED` if any occur:
- `phase3_validation_latest.json` result is `FAIL`
- continuity score drops below `0.50`
- open blocker count increases versus pre-run baseline
- forbidden boundary hit appears in validator output

## Evidence Collection Order
Collect in this order:
1. raw monitored surfaces (`atas_observation_export.json`, `acquisition_input_payload.json`, `atas_export_payload.json`, `exporter_status.json`, `adapter_status.json`, `atas_runtime_context.json`, `atas_runtime_context_status.json`)
2. Phase 3 candidate outputs (`phase3_candidate_state_bundle_latest.json`, `phase3_validation_latest.json`, `phase3_freshness_lineage_summary_latest.json`, `phase3_source_completeness_summary_latest.json`, `phase3_closure_blocker_consolidation_latest.json`)
3. closure comparison and gate pack (`phase3_closure_before_after_comparison_latest.json`, `phase3_weekend_safe_prelive_status_latest.json`, `phase3_weekend_safe_verification_pack_latest.md`)

## Post-Run Evaluation Order
1. confirm validator result and blocker count
2. confirm lineage state and continuity/freshness/completeness/explainability scores
3. evaluate closure gates `G1..G5` in `phase3_weekend_safe_prelive_status_latest.json`
4. keep `PARTIALLY_CLOSED` unless every gate is met with fresh live evidence

