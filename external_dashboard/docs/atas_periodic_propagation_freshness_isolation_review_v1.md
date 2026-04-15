# ATAS Periodic Propagation Validation + MT5 Freshness Isolation (Bounded)

## Executive Summary
This bounded task ran controlled periodic exporter/adapter propagation cycles against live ATAS observation flow and isolated MT5 intake freshness behavior using cycle-level packet/timestamp evidence.

Outcome is a **mixed failure**:
- **Cadence/orchestration remains non-continuous** (one-shot driven), with exporter occasionally lagging newest observation packet under live writes.
- **MT5 intake freshness verdict remains `EXPIRED`/`SHADOW_NOT_ATTACHED` even when propagated packet `fresh_until` is still in the future under UTC interpretation**, indicating a timestamp semantics defect.
- **Status/advisory surfaces update on MT5 decision/evaluation cadence**, so they can lag context writes by multiple propagation cycles.

No authority boundaries were changed.

## Controlled Validation Method
- Added bounded diagnostic runner:
  - `external_dashboard/tools/atas_periodic_propagation_validation.py`
  - wrapper: `external_dashboard/run_atas_periodic_validation.ps1`
- Per cycle:
  1. capture observation packet/timestamps
  2. run exporter one-shot
  3. run adapter one-shot
  4. capture context, context_status, advisory status
  5. compute progression/freshness/attachment diagnostics
- Output written to:
  - `MQL5/Files/AI/atas_live_capture/periodic_validation_cycles_<ts>.jsonl`
  - `MQL5/Files/AI/atas_live_capture/periodic_validation_summary_<ts>.json`
  - `MQL5/Files/AI/atas_live_capture/freshness_isolation_report_<ts>.json`
  - plus `*_latest` mirrors

## Cycle Windows Observed
- Window A: `periodic_validation_cycles_20260410_072848.jsonl` (6 cycles)
- Window B: `periodic_validation_cycles_20260410_073330.jsonl` (5 cycles)
- Window C: `periodic_validation_cycles_20260410_073821.jsonl` (1 cycle)
- Window D: `periodic_validation_cycles_20260410_074030.jsonl` (2 cycles)
- **Total cycles observed: 14**

## Per-Stage Progression Findings
- Observation stage:
  - live packet progression confirmed in all windows.
- Exporter stage:
  - consumed newest observation in most cycles, but lagged in live-race cycles (`exporter_lag` observed).
- Adapter stage:
  - consumed newest exporter payload when run.
  - intermittent adapter rejections occurred in earlier windows (`REJECTED: QUALITY_TOO_LOW`) and were captured in cycle logs.
- MT5 context:
  - context file advanced when adapter accepted.
- MT5 intake status + advisory:
  - status packet and advisory eligibility frequently lagged newest context packet until MT5 evaluation tick.
  - remained `EXPIRED` + `SHADOW_NOT_ATTACHED` after update.

## First Failing Gate in Periodic Flow
- First failing gate varies by cycle:
  - exporter lag gate in live-race cycles,
  - intake packet-lag gate when status not yet refreshed.
- Operationally, the blocking gate for attachment remained:
  - **intake freshness rejection** (`FRESHNESS_WINDOW_EXPIRED`).

## Freshness-Gate Isolation (Key Evidence)
- Latest isolated cycle evidence (from `freshness_isolation_report_20260410_073821.json`):
  - `event_time = 2026-04-10T04:38:32.1166646+00:00`
  - `fresh_until = 2026-04-10T04:41:32.3666646+00:00`
  - `status_evaluated_at = 2026.04.10 07:37:16`
  - computed `fresh_margin_seconds_at_eval_utc = +256` (still fresh under UTC interpretation)
  - emitted `packet_age_ms = 10849000` (~3h)
  - packet-age alignment result:
    - `ALIGNED_WITH_LOCALIZED_EVENT_TIME_IGNORING_TZ`
- This shows the intake/status aging path is effectively treating timezone-bearing packet timestamps as localized/no-timezone, producing expired verdicts.

## Isolation Classification
- Determined class: **MIXED_FAILURE**
- Confirmed components:
  - `EXPORTER_CADENCE_OR_ORCHESTRATION_GAP`
  - `INTAKE_READING_OLD_CONTEXT` (status refresh cadence lag vs context writes)
  - `INTAKE_FRESHNESS_REJECTION_ACTIVE`
  - `TIMESTAMP_FIELD_MISMATCH`
  - `TIMEZONE_OR_CLOCK_SKEW` (timestamp normalization semantics)

## Whether a Safe Bounded Fix Was Applied
- **No MT5 runtime logic fix applied in this task.**
- Reason:
  - task scope prioritized controlled validation + root-cause isolation,
  - fix candidate is clear and should be applied as a separate bounded patch with recompile/reload validation.

## Exact Next Safe Fix to Apply
- In MT5 intake timestamp normalization (`atas_intake_layer.mqh`, `AtasParseTimestamp(...)`), correct timezone normalization baseline so timezone-bearing ATAS timestamps are compared correctly against MT5 runtime clock.
- Targeted fix class:
  - **TIMESTAMP_FIELD_MISMATCH / TIMEZONE_OR_CLOCK_SKEW**
- Preserve fail-closed behavior; do not relax freshness thresholds.

## Advisory Eligibility During Test Window
- Advisory remained blocked:
  - `advisory_eligible = false`
  - gate reason remained `atas_shadow_not_attached`
  - downstream consequence of intake non-attachment.

## Governance Confirmation
- No trading/entry/exit/execution/risk/governor logic changes.
- No authority boundary changes.
- No Databento/Fusion/semantic-adapter posture changes.
- Diagnostics remain non-authoritative.

