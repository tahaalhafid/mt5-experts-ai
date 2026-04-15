# ATAS Microstructure Intelligence Engine Program - Phase 2 Kickoff v1

## Scope
This package implements Phase 2 kickoff foundations only:
- internal data access layer map
- internal state interface scaffolding
- source-to-state binding matrix
- runtime telemetry and validation harness definitions

## Explicit Non-Goals
- No intelligence engine behavior implementation.
- No MT5 runtime authority change.
- No MT5 decision/risk/governor/execution behavior change.
- No Databento/Fusion activation.
- No semantic-adapter bypass.
- No raw external direct runtime ingestion into MT5.

## Boundary Posture
- MT5 remains sole runtime/decision/risk/governor/execution authority.
- ATAS remains non-authoritative external microstructure contributor.
- Core/Extended contract split from Phase 1 remains unchanged.

## Package Layout
- `docs/`: human-readable mapping, governance compatibility, kickoff report
- `maps/`: machine-readable source families and source-to-state matrix
- `interfaces/`: non-operative state interface contracts for five state families
- `schemas/`: candidate bundle schema for kickoff validation
- `telemetry/`: telemetry hook definitions and harness contract
- `tools/`: local schema/contract validation utility
- `samples/`: non-operative example candidate state bundle

## Local Validation Harness
Run from `MQL5/Experts/AI`:

```powershell
python .\atas_microstructure_phase2_kickoff_v1\tools\validate_phase2_kickoff.py `
  --candidate-bundle .\atas_microstructure_phase2_kickoff_v1\samples\state_bundle_candidate_example.json
```

Optional Phase 1 compatibility checks:

```powershell
python .\atas_microstructure_phase2_kickoff_v1\tools\validate_phase2_kickoff.py `
  --candidate-bundle .\atas_microstructure_phase2_kickoff_v1\samples\state_bundle_candidate_example.json `
  --phase1-core-packet ..\..\Files\AI\atas_runtime_context.json `
  --phase1-extended-packet ..\..\Files\AI\external_adapter\atas_semantic_adapter\runtime\producer_input\atas_export_payload.json
```

Outputs are written to:
- `MQL5/Files/AI/atas_micro_phase2_validation/phase2_state_validation_latest.json`
- `MQL5/Files/AI/atas_micro_phase2_validation/phase2_state_validation_stream.jsonl`
