# External Read-Only Dashboard (MT5 Governed Runtime)

This external dashboard is a local read-only observability unit for the governed MT5 runtime.

## Governance posture

- MT5 remains sole authority for decision/execution/risk/governance.
- External dashboard is display/analysis only.
- No trade, risk, governor, or authority controls are exposed.
- No write-back into runtime control surfaces is performed.

## Features

- System Overview
- Current Market/Runtime Context
- Last Trades (limit selectable)
- Rejections / Non-Entry
- Forensics / Evidence
- Levels Comparative (FINAL runtime vs ATAS reference)
- Search / Inspect (`decision_id`, `position_id`, `ticket`)
- ATAS Live Chain diagnostics (`/atas-live`)

## Data root

The app reads from:

- `.../Terminal/<id>/MQL5/Files/AI`
- `.../Terminal/<id>/MQL5/Files/AI/external_adapter/atas_semantic_adapter`

The app auto-resolves this from its local path under:

- `MQL5/Experts/AI/external_dashboard`

## Local run

### Option A: PowerShell script

```powershell
.\run_external_dashboard.ps1
```

### Option B: manual

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install --upgrade pip
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
```

Open:

- `http://127.0.0.1:8010`

## Endpoints

- HTML:
  - `/`
  - `/context`
  - `/trades`
  - `/rejections`
  - `/forensics`
  - `/levels`
  - `/inspect`
  - `/atas-live`
- JSON API:
  - `/api/overview`
  - `/api/context`
  - `/api/trades?limit=10`
  - `/api/rejections?limit=20`
  - `/api/forensics`
  - `/api/levels`
  - `/api/inspect?q=<token>`
  - `/api/atas-live?limit=120`
- Health:
  - `/health`

## Notes

- Missing/optional files are shown explicitly as `UNAVAILABLE`.
- Stale or absent surfaces are represented as status badges/reason fields.
- Locked `ai_performance_journal.jsonl` is intentionally not required by this dashboard.

## Optional ATAS real-time capture monitor

Diagnostic-only capture monitor (read-only over pipeline inputs) can be started with:

```powershell
.\run_atas_live_capture.ps1 -Iterations 0 -IntervalSec 2
```

This writes bounded telemetry files under:

- `MQL5/Files/AI/atas_live_capture/`

## Optional periodic propagation validation (diagnostic-only)

To run bounded exporter+adapter periodic validation with per-cycle freshness/attachment isolation:

```powershell
.\run_atas_periodic_validation.ps1 -Cycles 6 -CycleIntervalSec 8 -RefreshMonitorOnce
```

This produces:

- `MQL5/Files/AI/atas_live_capture/periodic_validation_cycles_<timestamp>.jsonl`
- `MQL5/Files/AI/atas_live_capture/periodic_validation_summary_<timestamp>.json`
- `MQL5/Files/AI/atas_live_capture/freshness_isolation_report_<timestamp>.json`
- plus `*_latest.*` mirrors for quick dashboard/API inspection

## Managed live propagation runner (bounded, manual start/stop)

This runner is a local, non-authoritative managed service that periodically executes:

- exporter one-shot
- adapter one-shot

It is intentionally bounded and operator-controlled (manual start/stop), and it does not expose any execution/risk/governor controls.

Start:

```powershell
.\run_atas_live_propagation.ps1 -IntervalSec 5 -MaxCycles 0
```

Stop:

```powershell
.\stop_atas_live_propagation.ps1
```

Optional force stop:

```powershell
.\stop_atas_live_propagation.ps1 -Force
```

Telemetry surfaces:

- `MQL5/Files/AI/atas_live_capture/atas_propagation_runner_status.json`
- `MQL5/Files/AI/atas_live_capture/atas_propagation_runner_events.jsonl`

The runner uses a lock file to prevent concurrent instances:

- `MQL5/Files/AI/atas_live_capture/atas_propagation_runner.lock`
