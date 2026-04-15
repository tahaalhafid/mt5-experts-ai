# Systems Inventory Map v1 (Phase 0 Baseline)

## Inventory Objective
Map the current ATAS-related and MT5-consumer surfaces and classify each by truth/authority role.

## Source Plane (MT5-side)
| Surface Group | Primary Files | Class | Owner |
|---|---|---|---|
| Intake + runtime contract | `atas_intake_layer.mqh`, `atas_runtime_contract.mqh` | `EXECUTION_ADJACENT_CONTRACT_AND_STATUS_WRITER` | MT5 runtime code |
| Governed advisory contract/layer | `atas_governed_advisory_contract.mqh`, `atas_governed_advisory_layer.mqh`, `atas_governed_advisory_artifacts.mqh` | `RUNTIME_AUTHORITATIVE_STATUS_DERIVATION_NON_AUTHORITATIVE_ADVISORY` | MT5 runtime code |
| Runtime entrypoint consumer | `main_ea.mq5` | `EXECUTION_AUTHORITY_HOST` | MT5 runtime code |

## External Adapter Plane
| Surface Group | Primary Paths | Class | Owner |
|---|---|---|---|
| ATAS indicator exporter | `MQL5/Files/AI/external_adapter/atas_semantic_adapter/atas_indicator_exporter/` | `EXTERNAL_OBSERVATION_SOURCE` | External ATAS path |
| Future exporter | `.../future_exporter/src`, `.../future_exporter/runtime` | `EXTERNAL_TRANSFORM_AND_STATUS` | External adapter |
| Semantic adapter | `.../src`, `.../runtime` | `EXTERNAL_NORMALIZATION_AND_STATUS` | External adapter |

## Runtime/Status Surfaces
| Surface | Path | Class | Notes |
|---|---|---|---|
| ATAS runtime context packet | `MQL5/Files/AI/atas_runtime_context.json` | `NON_AUTHORITATIVE_EXTERNAL_SHADOW_INPUT` | Source packet for MT5 intake validation |
| ATAS runtime context status | `MQL5/Files/AI/atas_runtime_context_status.json` | `RUNTIME_AUTHORITATIVE_STATUS` | MT5-evaluated acceptance/freshness status |
| Governed advisory status | `MQL5/Files/AI/atas_governed_advisory_status.json` | `DERIVED_OR_VISIBILITY_ONLY` | Bounded non-authoritative advisory summary |
| Governed advisory effectiveness | `MQL5/Files/AI/atas_governed_advisory_effectiveness.json` | `HISTORICAL_LINEAGE_OR_EVIDENCE` | Aggregate advisory counters |
| Runtime governance status | `MQL5/Files/AI/runtime_governance_status.json` | `RUNTIME_AUTHORITATIVE_STATUS` | Operating governance posture |
| Execution authority status | `MQL5/Files/AI/execution_authority_status.json` | `RUNTIME_AUTHORITATIVE_STATUS` | Runtime authority state |

## Pipeline Packet/Status Surfaces
| Stage | Surface | Path | Class |
|---|---|---|---|
| Observation source | `atas_observation_export.json` | `.../future_exporter/runtime/acquisition_source/` | `EXTERNAL_OBSERVATION_SOURCE` |
| Acquisition input | `acquisition_input_payload.json` | `.../future_exporter/runtime/acquisition_input/` | `EXTERNAL_TRANSFORM_INTERMEDIATE` |
| Producer input | `atas_export_payload.json` | `.../runtime/producer_input/` | `EXTERNAL_TRANSFORM_INTERMEDIATE` |
| Exporter status | `exporter_status.json` | `.../future_exporter/runtime/` | `DERIVED_STATUS` |
| Adapter status | `adapter_status.json` | `.../runtime/` | `DERIVED_STATUS` |

## Evidence / Diagnostics Surfaces
| Surface Group | Path | Class |
|---|---|---|
| ATAS live capture stream | `MQL5/Files/AI/atas_live_capture/` | `HISTORICAL_LINEAGE_OR_EVIDENCE` |
| Evidence archive snapshots | `MQL5/Files/AI/external_adapter/atas_semantic_adapter/runtime/evidence_archive/` | `HISTORICAL_LINEAGE_OR_EVIDENCE` |
| External dashboard views | `MQL5/Experts/AI/external_dashboard/` | `DERIVED_OR_VISIBILITY_ONLY` |

## MT5 Environment Consumers
| Consumer | Inbound Surface | Consumption Posture |
|---|---|---|
| MT5 intake layer | `atas_runtime_context.json` | Strict validation + fail-closed to `SHADOW_NOT_ATTACHED` |
| Governed advisory layer | `atas_runtime_context_status.json` + candidate context | Bounded advisory only |
| SR visualization path | Status/context/advisory surfaces | Display-only diagnostics and comparison |

## Baseline Snapshot Pack
- Snapshot root: `MQL5/Files/AI/atas_micro_baseline/`
- Current snapshot: `p0p1_20260410_171057`
- Manifest: `baseline_snapshot_manifest.json`
