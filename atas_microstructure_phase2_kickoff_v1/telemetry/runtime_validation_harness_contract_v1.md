# Runtime Validation Harness Contract v1

## Scope
This harness validates Phase 2 kickoff candidate state bundles and emits diagnostics telemetry. It does not execute strategy, risk, governor, or authority behavior.

## Required Inputs
- Candidate bundle JSON conforming to:
  - `schemas/state_bundle_phase2_kickoff_v1.schema.json`
- Interface scaffold:
  - `interfaces/state_interface_scaffolding_v1.json`
- Binding matrix:
  - `maps/source_to_state_binding_matrix_v1.json`

## Optional Inputs
- Phase 1 core packet sample for compatibility check.
- Phase 1 extended packet sample for compatibility check.

## Required Outputs
- Latest validation report (JSON)
- Append-only validation stream (JSONL)

## Mandatory Checks
1. Candidate bundle top-level schema checks.
2. Required state families present.
3. Mandatory fields present per state family.
4. Basic type checks per field.
5. Forbidden ownership/authority-like fields absent.
6. Per-family completeness and issue classification.
7. Optional Phase 1 core/extended contract compatibility checks.

## Non-Authoritative Constraint
- Harness output is diagnostics-only.
- Harness output cannot approve or deny trading actions.
- Harness output cannot alter MT5 authority semantics.
