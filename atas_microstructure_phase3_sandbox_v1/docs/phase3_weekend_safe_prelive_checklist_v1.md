# Phase 3 Weekend-Safe Pre-Live Checklist v1

## Scope
This checklist is for market-closed preparation only.  
It does not replace real live-window verification.

## Required Live-Window Surfaces
All of the following must exist and refresh during the same live window:
- `atas_observation_export.json`
- `acquisition_input_payload.json`
- `atas_export_payload.json`
- `exporter_status.json`
- `adapter_status.json`
- `atas_runtime_context.json`
- `atas_runtime_context_status.json`
- `phase3_candidate_state_bundle_latest.json`
- `phase3_validation_latest.json`
- `phase3_freshness_lineage_summary_latest.json`
- `phase3_source_completeness_summary_latest.json`
- `phase3_closure_blocker_consolidation_latest.json`
- `phase3_closure_before_after_comparison_latest.json`

## Required Command Sequence
Run in this order from `MQL5/Experts/AI`:
1. `powershell -ExecutionPolicy Bypass -File .\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_candidate_pipeline.ps1`
2. `powershell -ExecutionPolicy Bypass -File .\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_1_refinement_cycles.ps1 -Cycles 5 -IntervalSeconds 1`
3. `python .\atas_microstructure_phase3_sandbox_v1\tools\build_phase3_closure_before_after_comparison.py --output-dir .\..\..\Files\AI\atas_micro_phase3_candidate`
4. `python .\atas_microstructure_phase3_sandbox_v1\tools\build_phase3_weekend_safe_prelive_pack.py --output-dir .\..\..\Files\AI\atas_micro_phase3_candidate --market-state LIVE_WINDOW`

## Closure Gate Criteria (PARTIALLY_CLOSED -> CLOSED)
Promotion to `CLOSED` requires all:
- validator result is `PASS`
- open blocker count is `0`
- lineage state is `COHERENT_FRESH`
- no expired required source/family freshness states
- fresh live-window evidence shows coherent packet progression across observation -> acquisition -> exporter -> adapter -> runtime -> runtime status

## Evidence That Keeps It PARTIALLY_CLOSED
Any one of the following keeps closure partial:
- any blocker remains open
- validator result is `PARTIAL_PASS` or `FAIL`
- lineage remains `PARTIAL_INCOMPLETE` or `DIVERGED`
- any required surface is stale/expired/missing
- market remains closed and fresh propagation cannot be proven

