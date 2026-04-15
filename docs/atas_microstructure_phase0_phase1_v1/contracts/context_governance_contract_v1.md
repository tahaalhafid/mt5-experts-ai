# Context Governance Contract v1

## Artifact
- Version: `ATAS_CONTEXT_GOVERNANCE_CONTRACT_V1`
- Machine-readable: `schemas/context_governance_contract_v1.json`

## Purpose
Define mandatory governance semantics for context packet production, validation, and downstream usage classification.

## Core Governance Rules
1. MT5 runtime authority is immutable in this phase.
2. Semantic adapter boundary is mandatory.
3. Raw external feed direct-to-MT5 is forbidden.
4. Core/Extended split is mandatory.
5. Extended interpretive fields are optional and non-binding.

## Freshness Gate Rules
- Freshness baseline timezone: UTC.
- Required fields for gate evaluation:
  - `event_time_utc`
  - `fresh_until_utc`
  - `evaluated_at_utc`
- Expiry verdict requires strict timestamp evidence.

## Provenance Gate Rules
- Missing `packet_id` or `trace_id` -> reject as malformed.
- Missing `source_mode` or symbol binding -> reject as malformed.
- Upstream lineage IDs must be preserved across transformation stages.

## Confidence Governance
- Core evidence confidence remains evidence-only.
- Extended interpretive confidence ceiling is mandatory.
- Confidence does not imply authority transfer.

## Suppression Governance
- Suppression reason taxonomy is mandatory.
- Suppression summary must be emitted when fields are withheld/suppressed.
- Historical-only data must not be represented as live-valid context.

## Output Family Rules
- Required families:
  - `context_packet_core`
  - `context_packet_extended`
  - `engine_status`
  - `trace_summary`
  - `suppression_summary`
  - `recent_diagnostics_snapshot`
  - `context_decision_basis_summary`
