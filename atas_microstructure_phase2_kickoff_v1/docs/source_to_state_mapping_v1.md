# Phase 2 Kickoff Source-to-State Mapping v1

## Purpose
Define a program-facing ATAS data access map and source-to-state bindings for Phase 2 kickoff without introducing engine semantics.

## Source Family Classification

| Source Family | Read Pattern | Producer Class | Typical Freshness Risk | Notes |
|---|---|---|---|---|
| `observation_event_stream` | Event-driven file drop | External ATAS exporter chain | medium | Primary ingress packet cadence, packet ids advance by event |
| `exporter_snapshot_status` | Snapshot-driven | Future exporter one-shot/status writer | high | Can lag observation if orchestration cadence stalls |
| `adapter_snapshot_status` | Snapshot-driven | Semantic adapter status writer | high | Tracks adapter accept/reject state and packet age |
| `runtime_context_snapshot` | Snapshot-driven | Adapter output consumed by MT5 | medium | Main normalized context packet surface |
| `runtime_context_status_cached` | Cached state | MT5 intake status writer | medium/high | Attachment/freshness verdict surface, can lag if polling cadence drifts |
| `advisory_status_cached` | Cached state | MT5 governed advisory layer | medium/high | Eligibility/attachment verdict and bounded advisory details |
| `capture_telemetry_cadence` | Timer/cadence-driven | Local validation/capture utilities | low/medium | Diagnostic only, non-authoritative |
| `diagnostic_event_streams` | Event-driven append-only | Validation runners/monitors | low/medium | Traceability and cycle-level forensics |

## Source Access Rules

1. Event-driven families must be read as append/newest-event aware.
2. Snapshot families must be read as latest-state with freshness guard checks.
3. Cached state families must include stale/lag classification, not assumed-live.
4. Timer/cadence families must remain diagnostic-only and non-authoritative.

## Source-to-State Bindings

### `OrderFlowState`
- Primary direct-read families:
  - `runtime_context_snapshot`
  - `observation_event_stream`
- Future-derived candidates:
  - `diagnostic_event_streams` (windowed consistency scores)
- Mandatory freshness gate:
  - `event_time` and `fresh_until` parse success + age bounded

### `LiquidityState`
- Primary direct-read families:
  - `runtime_context_snapshot`
  - `observation_event_stream`
- Supporting optional direct-read:
  - `advisory_status_cached` (nearest distances when present)
- Future-derived candidates:
  - depth/spread pressure and void-state quality

### `LevelInteractionState`
- Primary direct-read families:
  - `advisory_status_cached`
  - `runtime_context_snapshot`
- Supporting direct-read:
  - `observation_event_stream` level behavior candidates
- Future-derived candidates:
  - rejection/obstruction/conflict classification normalization

### `MicrostructureEnvironmentEvidence`
- Primary direct-read families:
  - `runtime_context_snapshot`
  - `observation_event_stream`
- Supporting direct-read:
  - `advisory_status_cached` contradiction markers
- Future-derived candidates:
  - non-binding environment cleanliness and context consistency tags

### `QualityValidityState`
- Primary direct-read families:
  - `runtime_context_status_cached`
  - `adapter_snapshot_status`
  - `exporter_snapshot_status`
  - `advisory_status_cached`
- Supporting direct-read:
  - `capture_telemetry_cadence`
- Future-derived candidates:
  - multi-stage lag gradient, completeness confidence

## Staleness and Cadence Notes
- Observation freshness alone is insufficient; runtime context and MT5 intake status must cohere by packet lineage.
- Exporter and adapter statuses are treated as potentially stale snapshots and must be gated by `last_run_timestamp` and packet linkage.
- Advisory eligibility must not be inferred from payload presence alone; gating fields remain mandatory.

## Explicit Boundary Compliance
- This mapping does not assign final regime meaning, final canonical level meaning, or tradability ownership to ATAS.
- This mapping is non-operative scaffolding for later engine phases.
