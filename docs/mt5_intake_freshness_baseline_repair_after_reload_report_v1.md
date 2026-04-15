# MT5 Intake Freshness-Baseline Repair + Post-Reload Proof (Bounded)

## Scope
- Task: MT5 intake freshness-baseline semantics repair + post-reload runtime proof.
- Boundaries preserved: no trading/entry/exit/execution/risk/governor/authority behavior changes.

## Pre-change backup
- `backup_archives/pre_change_20260410_103235_mt5_intake_freshness_baseline_repair.zip`
- Governed scope included: `MQL5/Experts/AI`, `MQL5/Files/AI`
- Explicit exclusion: `MQL5/Files/AI/ai_performance_journal.jsonl` (live-locked governance rule)

## Defect identified
- `AtasParseTimestamp(...)` returns UTC-aligned epoch values for ISO timestamps with timezone offsets.
- Freshness comparison baseline in intake/status path used `TimeCurrent()` semantics.
- This can produce false-expired outcomes when evaluated against UTC-normalized packet times.

## Code-level repair applied
- File: `MQL5/Experts/AI/atas_intake_layer.mqh`
- Added helper:
  - `AtasFreshnessBaselineUtcNow()` -> `TimeGMT()` baseline, fallback `TimeCurrent()` when needed.
- Updated freshness/admission baseline:
  - `AtasLoadAndValidatePacket(...)`: `now_ts = AtasFreshnessBaselineUtcNow()`
- Updated status packet age baseline:
  - `AtasEmitRuntimeContextStatus(...)`: `now_ts = AtasFreshnessBaselineUtcNow()`
- Added status diagnostics:
  - `status_timestamp_utc`
  - `freshness_baseline = "TIME_GMT_UTC"`
- Strictness unchanged:
  - freshness windows and fail-closed gates were not relaxed.

## Compile evidence
- Log: `logs/compile_mt5_intake_freshness_baseline_repair.log`
- Result: `0 errors, 2 warnings`
- Important activation evidence:
  - `main_ea.ex5` timestamp remained `2026.04.10 09:24:49`
  - repeated post-fix CLI compile attempts did not register new compile events in `logs/metaeditor.log` beyond `10:46:38`
  - no new compiler log artifact was produced by those later attempts

## Runtime activation / reload evidence
- Terminal restart performed.
- Terminal journal evidence:
  - `logs/20260410.log` contains restart at `11:07:31`.
  - `Experts: expert main_ea (XAUUSD,H1) loaded successfully` appears at `11:17:24`.
- Runtime activation conclusion:
  - EA process reattached on chart after restart, but patched binary activation is still not proven because `main_ea.ex5` did not refresh and emitted status JSON does not contain newly added fields (`status_timestamp_utc`, `freshness_baseline`).

## Post-reload bounded validation artifacts
- `MQL5/Files/AI/atas_live_capture/periodic_validation_cycles_20260410_111501.jsonl`
- `MQL5/Files/AI/atas_live_capture/periodic_validation_summary_20260410_111501.json`
- `MQL5/Files/AI/atas_live_capture/freshness_isolation_report_20260410_111501.json`
- Additional post-attach validation set:
  - `MQL5/Files/AI/atas_live_capture/periodic_validation_cycles_20260410_113314.jsonl`
  - `MQL5/Files/AI/atas_live_capture/periodic_validation_summary_20260410_113314.json`
  - `MQL5/Files/AI/atas_live_capture/freshness_isolation_report_20260410_113314.json`

## Observed outcome in validation window (6 cycles)
- In both validation windows, exporter and adapter advanced repeatedly.
- `atas_runtime_context.json` advanced (`atas_ind_1775810xxx` range in later run).
- `atas_runtime_context_status.json` lagged and stayed behind context packet progression:
  - latest run showed status pinned at `atas_ind_1775809184` while context advanced beyond it.
- MT5 status remained:
  - `freshness_state = EXPIRED`
  - `acceptance_state = SHADOW_NOT_ATTACHED`
  - `rejection_reason = FRESHNESS_WINDOW_EXPIRED`
- Freshness isolation in latest run still reports:
  - `alignment = ALIGNED_WITH_LOCALIZED_EVENT_TIME_IGNORING_TZ`
  - positive UTC freshness margin while expired in all cycles (`freshness_margin_positive_while_expired = 6`)

## Current diagnosis
- Primary semantic fix is implemented in source and compiled.
- EA did reattach after restart, but runtime still behaves like pre-fix binary:
  - status payload omits newly added diagnostics fields
  - stale timezone-alignment signature persists in cycle telemetry
- Immediate blocker for definitive repair proof:
  - patched source is not yet proven active in the loaded runtime binary.

## Next bounded step
- Perform a confirmed binary refresh path (successful full compile that updates `main_ea.ex5` timestamp), then reload `main_ea` and rerun 6-10 cycle validation.
- Confirm all of:
  - `status_timestamp_utc` and `freshness_baseline` appear in `atas_runtime_context_status.json`
  - false-expired cases disappear for truly fresh UTC packets
  - whether `SHADOW_ATTACHED` occurs when independent quality/attachment gates are genuinely satisfied.
