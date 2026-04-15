# Freshness, Provenance, Confidence Ceiling, and Suppression Taxonomy v1

## Freshness Rules
- Baseline comparison timezone: `UTC`.
- Required fields for freshness evaluation:
  - `event_time_utc`
  - `fresh_until_utc`
  - `evaluated_at_utc`
- Freshness states:
  - `FRESH`
  - `STALE`
  - `EXPIRED`
  - `UNKNOWN`
- Mandatory contract rule:
  - `FRESHNESS_WINDOW_EXPIRED` is valid only when `evaluated_at_utc > fresh_until_utc`.

## Provenance Requirements
- Every packet family must carry:
  - `packet_id`
  - `trace_id`
  - `source_platform`
  - `source_mode`
  - `produced_by`
  - `schema_version`
  - stage-specific generation timestamp
- Intermediate stages must preserve upstream lineage:
  - `upstream_packet_id`
  - `upstream_trace_id`

## Confidence Ceiling Semantics
- Core packet confidence (`packet_confidence`) is evidence confidence, not authority confidence.
- Extended interpretive confidence must be capped:
  - `interpretive_confidence_ceiling <= 0.49`
- Contract meaning:
  - Extended interpretive outputs may shape diagnostics/research but cannot represent final MT5 decision confidence.

## Suppression Reason Taxonomy
- `SCHEMA_INVALID`
- `MALFORMED_PAYLOAD`
- `SYMBOL_MISMATCH`
- `SOURCE_MODE_FORBIDDEN`
- `QUALITY_TOO_LOW`
- `FRESHNESS_WINDOW_EXPIRED`
- `PACKET_STALE`
- `OVERLAY_DISABLED`
- `BASE_ENVIRONMENT_UNAVAILABLE`
- `EXECUTION_REFERENCE_MISSING`
- `EXECUTION_REFERENCE_STALE`
- `TRANSLATION_INVALID`
- `SEMANTIC_ONLY_FALLBACK_ACTIVE`
- `ATTACHMENT_BLOCKED`
- `INELIGIBLE_BY_POLICY`
- `NOT_PRODUCED`
- `UNKNOWN`

## Availability States (Required in Diagnostics)
- `DIRECT`
- `DERIVED`
- `UNAVAILABLE`
- `STALE`
- `NOT_PRODUCED`
- `SUPPRESSED`
- `INELIGIBLE`
