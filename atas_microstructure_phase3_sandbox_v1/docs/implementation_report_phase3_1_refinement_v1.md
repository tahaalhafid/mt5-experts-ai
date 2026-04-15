# ATAS Microstructure Program - Phase 3.1 Refinement Report v1

## Scope
This package is a bounded Phase 3.1 refinement only:
- candidate-state quality/maturity improvements
- source completeness + freshness-aligned lineage continuity improvements
- mapper/trace/reason-code refinement
- validation/reporting refinement

No Phase 4 governance engine, no export composer, no MT5 live-consumption expansion, and no MT5 authority behavior changes are included.

## What Was Refined
1. Generator refinements:
- Added source-state assessment layer with explicit state classes:
  - `FRESH`
  - `STALE`
  - `EXPIRED`
  - `MISSING`
  - `PARTIAL_BUT_USABLE`
  - `PARTIAL_BUT_DEGRADED`
- Added source completeness, freshness, and lineage continuity summaries to candidate quality outputs.
- Improved mapper metadata across families:
  - completeness bucket
  - candidate usability state
  - source state summary
  - explicit direct/unsupported field names
- Refined `QualityValidityStateMapper` to include source-state-aware quality/completeness and gated-candidate reasoning.

2. Validation refinements:
- Validator extended with Phase 3.1 quality evaluation:
  - family population score
  - source coverage score
  - freshness quality score
  - explainability score
  - stale-vs-missing breakdown
  - lineage continuity summary
- PASS/PARTIAL_PASS/FAIL semantics now tied to boundary safety plus quality/freshness/explainability quality.
- Added human-readable validator summary artifact.

3. Tooling refinements:
- Fixed Phase 3 pipeline runner default bundle path resolution to actual `MQL5/Files/AI/...`.
- Added refinement-cycle runner for repeated bounded refresh checks.

## Key Outputs
Under `MQL5/Files/AI/atas_micro_phase3_candidate/`:
- `phase3_source_completeness_summary_latest.json`
- `phase3_freshness_lineage_summary_latest.json`
- `phase3_validation_human_summary_latest.md`
- `phase3_1_refinement_cycles_latest.json`
- `phase3_1_refinement_cycles_stream.jsonl`

## Current Snapshot Interpretation
Latest refinement cycles show:
- strong field population in families
- source completeness structurally present
- freshness quality low due to expired runtime source windows
- lineage continuity partial where packet chain stages diverge or are missing

This is an expected truthful result for stale windows and confirms the refinement now reports degraded conditions explicitly instead of masking them.

## Deferred (Intentionally)
- Any Phase 4 governance enforcement engine
- Any export composer/publisher logic
- Any MT5 consumption expansion
- Any authority or operating-model changes
