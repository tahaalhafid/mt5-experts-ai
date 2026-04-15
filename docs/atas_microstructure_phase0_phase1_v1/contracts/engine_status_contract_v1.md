# Engine Status Contract v1

## Artifact
- Family: `engine_status`
- Schema file: `schemas/engine_status_v1.schema.json`
- Version: `ATAS_ENGINE_STATUS_V1`

## Purpose
Provide stage-by-stage non-authoritative health and gate diagnostics for the ATAS chain.

## Required Sections
- `identity_lineage`
- `stage_status`
  - `observation_stage`
  - `exporter_stage`
  - `adapter_stage`
  - `mt5_intake_stage`
  - `advisory_stage`
- `first_failing_gate`
- `freshness_diagnostics`
- `packet_progression`
- `classification`

## Stage Status Enum
- `LIVE_VALID`
- `FRESH`
- `STALE`
- `EXPIRED`
- `HISTORICAL_ONLY`
- `NOT_ATTACHED`
- `BLOCKED`
- `INELIGIBLE`
- `ERROR`
- `UNKNOWN`

## Mandatory Rule
- Engine status is diagnostics-only and non-authoritative.
- Engine status cannot carry execution, risk, or governor command semantics.
