# Trace, Suppression, and Diagnostics Contracts v1

## Artifact Families
- `trace_summary`
- `suppression_summary`
- `recent_diagnostics_snapshot`
- `context_decision_basis_summary`

## 1) Trace Summary Contract
- Schema: `schemas/trace_summary_v1.schema.json`
- Required:
  - `trace_id`
  - `packet_id`
  - stage timeline timestamps
  - stage outcomes
  - first failing gate
- Role: forensic lineage and sequence tracking.

## 2) Suppression Summary Contract
- Schema: `schemas/suppression_summary_v1.schema.json`
- Required:
  - `suppression_id`
  - `packet_id`
  - `suppressed_field_families`
  - `suppression_reason_codes`
  - `suppression_scope`
- Role: explicit declaration of what was withheld and why.

## 3) Recent Diagnostics Snapshot Contract
- Schema: `schemas/recent_diagnostics_snapshot_v1.schema.json`
- Required:
  - current chain state
  - freshness posture
  - attachment posture
  - advisory eligibility posture
  - status/source packet coherency summary
- Role: compact operational truth snapshot.

## 4) Context Decision Basis Summary Contract
- Schema: `schemas/context_decision_basis_summary_v1.schema.json`
- Required:
  - what ATAS provided
  - what was suppressed/ignored
  - bounded influence state
  - explicit non-authoritative note
- Role: explanatory context, not decision ownership.

## Hard Safety Rules Across All Families
- No family may expose execution/risk/governor commands.
- No family may assert final market/regime/tradability ownership.
- Historical-only data must remain clearly classified and non-live.
