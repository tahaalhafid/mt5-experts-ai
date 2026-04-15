# ATAS Path Reclassification Note v1

## Active Path (New Direction)
`ATAS C# direct writer -> MQL5/Files/AI/atas_microstructure_context.json -> MT5 thin direct intake (shadow/advisory only)`

## Legacy Path (Retained, Not Active Future Path)
The following remain in repository as legacy/reference and are not required by the active direct-write path:

- `MQL5/Files/AI/external_adapter/atas_semantic_adapter/future_exporter/` (legacy exporter staging path)
- `MQL5/Files/AI/external_adapter/atas_semantic_adapter/runtime/` legacy bridge/runtime support surfaces
- `MQL5/Files/AI/external_adapter/atas_semantic_adapter/src/` legacy adapter source
- `atas_one_shot_exporter_run.log` legacy one-shot exporter evidence
- `atas_one_shot_adapter_run.log` legacy one-shot adapter evidence
- Phase 3 exporter/adapter continuity tooling under:
  - `atas_microstructure_phase3_sandbox_v1/tools/`
  - `atas_microstructure_phase3_sandbox_v1/docs/`

## Research/Sandbox Retention
Sandbox/closure assets are retained as evidence/reference only and do not define the new active ATAS runtime direction.

## Transitional Mirrors
- `MQL5/Files/AI/atas_runtime_context.json` is retained as a transitional mirror of the new primary context surface.
- `MQL5/Files/AI/atas_runtime_context_status.json` is retained as a transitional mirror of the new primary status surface.
