# ATAS Live-Chain Full Repair Review V1

## Scope
- Patch target: bounded ATAS live-chain repair in managed runner mode.
- Governance posture preserved:
  - MT5 remains sole runtime authority.
  - ATAS remains non-authoritative.
  - Fail-closed gates remain active.
  - No trading/risk/governor decision semantics were changed.

## Implemented Repairs

### 1) MT5 timestamp semantics normalization
- Updated:
  - `atas_intake_layer.mqh` (`AtasParseTimestamp`)
  - `atas_governed_advisory_layer.mqh` (`AtasGovAdvisoryParseTimestamp`)
- Repair details:
  - Normalized ISO parsing for `Z`, `+HH:MM`, `+HHMM`, `+HH`.
  - Added deterministic epoch conversion from parsed calendar fields.
  - Removed old local-offset correction path that could misalign timezone semantics.
  - Preserved strict fail-closed behavior: malformed timestamp still rejects.

### 2) Status/context coherence heartbeat (status-only)
- Updated:
  - `atas_intake_layer.mqh`: added `AtasRefreshRuntimeContextStatusHeartbeat(...)`.
  - `main_ea.mq5`:
    - added input `AtasStatusHeartbeatIntervalSec` (default `5`).
    - added `RefreshAtasRuntimeStatusHeartbeatBestEffort()`.
    - heartbeat wired into both `OnTick()` and `OnTimer()`.
- Behavior:
  - Status-only refresh path re-validates latest `atas_runtime_context.json` using existing gates.
  - Emits `atas_runtime_context_status.json` without altering trade decision routing.

### 3) Managed runner cadence repair (manual start/stop)
- Added:
  - `external_dashboard/tools/atas_live_propagation_runner.py`
  - `external_dashboard/run_atas_live_propagation.ps1`
  - `external_dashboard/stop_atas_live_propagation.ps1`
- Runner properties:
  - bounded periodic exporter + adapter one-shot loop.
  - lockfile to prevent concurrent runners.
  - stop signal support.
  - telemetry outputs:
    - `MQL5/Files/AI/atas_live_capture/atas_propagation_runner_status.json`
    - `MQL5/Files/AI/atas_live_capture/atas_propagation_runner_events.jsonl`

### 4) Documentation update
- Updated:
  - `external_dashboard/README.md` with managed runner operational instructions.

## Gate Matrix (post-change observed)
- Observation stage: live-valid advancing.
- Exporter stage: advancing under managed cadence; occasional lag observed.
- Adapter stage: advancing; intermittent `QUALITY_TOO_LOW` may appear but accepted cycles exist.
- MT5 intake/status stage: remained stale in runtime proof window (`FRESHNESS_WINDOW_EXPIRED` persisted from old status packet).
- Advisory eligibility: remained blocked due `atas_shadow_not_attached`.

## Validation Evidence

### Scenario 1 (ATAS live + managed runner)
- Managed runner executed `10` cycles:
  - `atas_propagation_runner_status.json` shows `cycles_completed=10`.
  - runner events captured exporter/adapter/context packet progression.
- Periodic validation run captured:
  - `periodic_validation_cycles_20260410_090141.jsonl`
  - `periodic_validation_summary_20260410_090141.json`
  - `freshness_isolation_report_20260410_090141.json`
- Latest classification in periodic summary:
  - `MIXED_FAILURE`
  - first failing gate: intake/status not reflecting newest adapter packet.

### Scenario 2 (runner stopped / lapse check)
- Runner stopped (`MAX_CYCLES_REACHED` then no active propagation service).
- Fresh capture probe still reports chain not live-valid and fail-closed behavior preserved.
- No forced attachment observed.

## Compile Verification (touched MT5 chain)
- Compile log generated:
  - `logs/compile_main_ea_atas_live_chain_full_repair_s.log`
- Compiler result line:
  - `result 0 errors, 2 warnings`
- Note:
  - Existing `main_ea.ex5` timestamp did not advance during this environment run; runtime reload/deployment alignment remains required for activation proof of the new heartbeat path in live MT5 session.

## Remaining Limitation
- In current observed runtime window, MT5 status packet (`atas_runtime_context_status.json`) stayed on an older packet id and stale timestamp path.
- This indicates the newly patched MT5 source has not yet been proven active in the running EA instance (reload/deploy alignment still required).
