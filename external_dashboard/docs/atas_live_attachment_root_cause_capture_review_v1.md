# ATAS Live-Attachment Root Cause + Real-Time Capture Review v1

## Executive Summary
This bounded task investigated why ATAS remained non-live/non-attached while ATAS observation writes were active, then added a diagnostic-only real-time ATAS capture package.

Primary finding is **mixed root cause**:
1. **First failing gate in normal live operation** is exporter orchestration:
   - observation file updates live,
   - exporter/adapter are explicitly one-shot/manual and were not running continuously,
   - downstream packet stayed historical.
2. After a manual one-shot exporter+adapter pass, MT5 context updated but intake status still evaluated as expired/not-attached for the same new packet, indicating an intake-side freshness/timekeeping normalization issue (or equivalent freshness admission mismatch).

No authority boundaries were changed.

## Scope and Safety
- Non-authoritative diagnostics only.
- No trading/entry/exit/execution/risk/governor logic changes.
- No advisory authority expansion.
- No Databento/Fusion activation changes.
- No semantic-adapter authority posture changes.

## Stage-by-Stage Diagnosis

### 1) Observation stage (`atas_observation_export.json`)
- **Observed:** live-updating packet IDs and fresh file mtime.
- **Evidence:** acquisition source file and indicator status changed in real time.
- **Diagnosis:** source observation is active.

### 2) Exporter stage (`acquisition_input_payload.json`, `atas_export_payload.json`, `exporter_status.json`)
- **Observed initially:** stale by ~157k seconds while observation was fresh.
- **Code/config evidence:** `future_exporter` is one-shot, with `allow_daemon=false`, `allow_watcher=false`, `allow_webhook=false`.
- **Diagnosis:** no continuous handoff process running; exporter output remained historical.

### 3) Adapter stage (`adapter_status.json`, `atas_runtime_context.json`)
- **Observed initially:** stale together with exporter stage.
- **After manual one-shot run:** adapter accepted and wrote fresh `atas_runtime_context.json`.
- **Diagnosis:** adapter path itself works in one-shot; stale state came from orchestration gap upstream.

### 4) MT5 intake/status stage (`atas_runtime_context_status.json`)
- **Observed:** status remained `SHADOW_NOT_ATTACHED` and `EXPIRED`.
- **After fresh adapter write:** status later moved to new packet id but still emitted `FRESHNESS_WINDOW_EXPIRED`.
- **Evidence snapshot:**
  - context packet: `atas_ind_1775793003`
  - context `event_time`: `2026-04-10T03:50:03Z`
  - context `fresh_until`: `2026-04-10T03:53:03Z`
  - status packet (same): `atas_ind_1775793003`
  - status verdict: `EXPIRED`, `FRESHNESS_WINDOW_EXPIRED`
- **Diagnosis:** intake freshness gate is the blocking gate after one-shot freshness propagation. Evidence indicates a timekeeping/freshness normalization mismatch in intake admission timing.

### 5) Advisory stage (`atas_governed_advisory_status.json`)
- **Observed:** remained ineligible/not attached because intake state remained expired/not-attached.
- **Diagnosis:** advisory ineligibility is downstream consequence of intake non-attachment.

## Which Gate Fails First
- **Normal live state before manual one-shot:** exporter gate fails first (`HISTORICAL_ONLY`, packet lags observation).
- **After manual one-shot propagation:** intake freshness gate fails (`EXPIRED` / `FRESHNESS_WINDOW_EXPIRED`), keeping advisory ineligible.

## Real-Time ATAS Capture/Telemetry Added

### Added monitor
- `MQL5/Experts/AI/external_dashboard/tools/atas_live_capture_monitor.py`
- `MQL5/Experts/AI/external_dashboard/run_atas_live_capture.ps1`

The monitor is read-only over chain inputs and writes diagnostic-only capture outputs.

### Added capture output surfaces
Under `MQL5/Files/AI/atas_live_capture/`:
- `atas_live_chain_status.json`
- `atas_live_event_stream.jsonl` (bounded append-only with retention cap)
- `atas_live_field_inventory.json`
- `latest_observation_snapshot.json`
- `latest_exporter_snapshot.json`
- `latest_acquisition_input_snapshot.json`
- `latest_producer_input_snapshot.json`
- `latest_adapter_snapshot.json`
- `latest_context_snapshot.json`
- `latest_mt5_intake_snapshot.json`
- `latest_advisory_snapshot.json`

### Added dashboard diagnostics page (read-only)
- Route: `/atas-live`
- API: `/api/atas-live`
- Nav entry added in dashboard sidebar.
- Uses capture surfaces above; does not control runtime.

## Live/State Classifications Implemented
The capture package distinguishes:
- `LIVE_VALID`
- `STALE`
- `EXPIRED`
- `HISTORICAL_ONLY`
- `ABSENT`
- `NOT_ATTACHED`
- `BLOCKED`
- `INELIGIBLE`
- `DEFAULTED_OR_INVALID`
- `SUPPRESSED`

## Real-Time Fields Now Visible
Across stage snapshots and chain status:
- packet IDs, timestamps, file mtimes/ages
- source/execution symbols
- translation/suppression states
- basis capture states
- acceptance/rejection reason codes
- stage freshness and first failing gate
- required-field inventory per stage

## What Remains Missing / Weak
1. No continuous exporter+adapter runner exists by design in current config posture (manual one-shot only).
2. Intake freshness rejection on newly propagated packet remains unresolved and should be investigated in MT5 time normalization/freshness logic.
3. Advisory remains ineligible while intake remains non-attached.

## Validation Notes
- One-shot exporter run: `EXPORTER_WRITE_SUCCESS`
- One-shot adapter run: `ACCEPTED_SHADOW_ONLY`
- Telemetry monitor ran for bounded iterations and produced chain/event outputs.
- Current chain verdict from telemetry: first failing gate = exporter (`HISTORICAL_ONLY`) during ongoing live observation updates.

## Governance Confirmation
- MT5 remains sole runtime authority.
- ATAS remains non-authoritative.
- Capture is diagnostic-only and read-only relative to runtime control surfaces.
- No authority semantics were changed.

## Recommended Next Bounded Runtime Validation Step
Run a short controlled interval with:
1. ATAS observation active,
2. periodic exporter+adapter one-shot (or approved bounded orchestrator),
3. telemetry monitor active.

Then compare intake freshness verdict against context event/fresh-until at each cycle to isolate the exact timekeeping admission mismatch condition in MT5 intake.

