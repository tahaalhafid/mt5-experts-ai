# ATAS Direct Write Minimal Diagnostics Note v1

## Intent
Diagnostics are reduced to the minimum needed to operate and verify the direct-write path.

## Writer Status Surface
File: `MQL5/Files/AI/atas_microstructure_writer_status.json`

Primary fields:
- `write_status` (`WRITTEN` or `REJECTED`)
- `last_rejection_reason`
- `last_packet_id`
- `last_file_timestamp_utc`
- `output_path`
- `source_symbol`
- `execution_symbol`
- `source_mode`
- `packet_validity`
- `quality_state`
- `confidence_ceiling`

## MT5 Intake Status Surface
File: `MQL5/Files/AI/atas_microstructure_status.json`

Primary fields:
- `last_acceptance_state`
- `last_rejection_reason`
- `packet_age_ms`
- `freshness_state`
- `shadow_attached`
- `last_packet_id`
- `trace_id`
- `source_symbol`
- `execution_symbol`
- `source_mode`
- `consumption_mode`
- `summary`
- `evaluated_at`

## Minimal Gate Semantics
- Missing/invalid/stale direct packet -> intake rejects and MT5 base logic continues unchanged.
- Fresh/valid packet -> bounded non-authoritative shadow attachment only.
