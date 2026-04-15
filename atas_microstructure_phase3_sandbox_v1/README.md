# ATAS Microstructure Intelligence Engine Program - Phase 3 Sandbox v1

## Scope
Phase 3 bounded implementation only:
- candidate state population
- mapper prototypes for five approved state families
- engine-local reason codes and traces
- candidate-level quality/suppression-aware derivation
- extended validation harness for boundary checks

## Explicit Non-Goals
- No export composer truth-building.
- No MT5 live-consumption expansion.
- No MT5 authority/decision/risk/governor/execution changes.
- No Databento/Fusion or AI authority changes.
- No final regime/canonical-level/tradability ownership from ATAS.

## Package Contents
- `contracts/`: family contract and forbidden boundary definitions
- `reason_codes/`: engine-local reason code taxonomy
- `schemas/`: candidate bundle schema
- `tools/`: generator and validator
- `docs/`: governance note and implementation report
- `samples/`: optional candidate examples

## Run: Candidate Bundle Generator
From `MQL5/Experts/AI`:

```powershell
python .\atas_microstructure_phase3_sandbox_v1\tools\generate_phase3_candidate_bundle.py
```

## Run: Phase 3 Validator
```powershell
python .\atas_microstructure_phase3_sandbox_v1\tools\validate_phase3_candidate_bundle.py `
  --bundle .\..\Files\AI\atas_micro_phase3_candidate\phase3_candidate_state_bundle_latest.json
```

## Run: Phase 3.1 Refinement Cycles
```powershell
powershell -ExecutionPolicy Bypass -File .\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_1_refinement_cycles.ps1 `
  -Cycles 3 -IntervalSeconds 1
```

## Run: Phase 3 Closure Before/After Comparison
```powershell
python .\atas_microstructure_phase3_sandbox_v1\tools\build_phase3_closure_before_after_comparison.py `
  --output-dir .\..\Files\AI\atas_micro_phase3_candidate
```

## Output Location
Generated artifacts are written to:
- `MQL5/Files/AI/atas_micro_phase3_candidate/`

Including:
- candidate bundle latest + stream
- mapper trace latest + stream
- validation latest + stream
- validation human summary
- coverage/source/unsupported/provisional/governance summaries
- source completeness summary
- freshness + lineage continuity summary
- refinement cycle summary latest + stream
- closure blocker consolidation summary
- closure before/after comparison (json + md)
