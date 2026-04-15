# Phase 3 Governance Compatibility Note v1

## Intent
This package provides candidate-state intelligence scaffolding only. It does not alter operating model or MT5 authority boundaries.

## Compatibility Assertions
- MT5 remains sole runtime/decision/risk/governor/execution authority.
- ATAS outputs remain non-authoritative candidate evidence.
- No final regime ownership fields are emitted.
- No canonical support/resistance ownership fields are emitted.
- No tradability verdict fields are emitted.
- No decision-package or execution command fields are emitted.
- No semantic-adapter bypass is introduced.
- No MT5 runtime code is modified by this package.

## Phase Boundary
- Phase 3 includes mapper prototypes and candidate bundles only.
- Context Governance Layer enforcement and export composer logic remain deferred.

## Boundary Enforcement in Tooling
- Validator checks forbidden boundary fields.
- Candidate bundle includes explicit `pre_governance` and `pre_export_composer` flags.
- Boundary summary artifacts are emitted on each validation run.
