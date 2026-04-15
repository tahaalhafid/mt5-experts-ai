# External Dashboard Unit + Internal UI Soft-Disable Implementation Report v1

## Executive summary

Implemented a new local read-only external dashboard unit at `MQL5/Experts/AI/external_dashboard/` and soft-disabled MT5 internal dashboard chart rendering by default, while preserving dashboard collectors/status generation and all runtime authority boundaries.

## Backup evidence

- Pre-change governed backup:
  - `backup_archives/pre_change_20260410_012326_external_dashboard_unit.zip`
- Post-change governed scope archive:
  - `backup_archives/post_change_20260410_014552_external_dashboard_unit_scope.zip`
- Exclusions applied in governed archives:
  - existing `.zip` artifacts
  - `MQL5/Files/AI/ai_performance_journal.jsonl` (live-locked exclusion rule)
  - generated `external_dashboard/.venv` and `__pycache__` (post-change scope hygiene)

## Files reviewed

- `main_ea.mq5`
- `dashboard_renderer.mqh`
- `dashboard_navigation_controller.mqh`
- runtime/evidence surfaces under `MQL5/Files/AI` (read-only inspection)

## Files modified

- `main_ea.mq5`
  - Added `EnableInternalDashboardChartUI` input (default false)
  - Soft-disable visual chart rendering path while preserving non-visual dashboard collectors/status refresh
- `external_dashboard/app/main.py`
  - FastAPI app bootstrap/routes + template response compatibility update

## Files created

- `external_dashboard/requirements.txt`
- `external_dashboard/run_external_dashboard.ps1`
- `external_dashboard/README.md`
- `external_dashboard/app/__init__.py`
- `external_dashboard/app/sources.py`
- `external_dashboard/app/aggregator.py`
- `external_dashboard/templates/base.html`
- `external_dashboard/templates/overview.html`
- `external_dashboard/templates/context.html`
- `external_dashboard/templates/trades.html`
- `external_dashboard/templates/rejections.html`
- `external_dashboard/templates/forensics.html`
- `external_dashboard/templates/levels.html`
- `external_dashboard/templates/inspect.html`
- `external_dashboard/static/style.css`
- `external_dashboard/static/app.js`
- `external_dashboard/docs/external_dashboard_architecture_v1.md`
- `external_dashboard/docs/external_dashboard_data_contract_v1.md`
- `docs/internal_dashboard_ui_soft_disable_review_v1.md`

## Files intentionally not modified

- Trading/execution/risk/governor modules and formulas
- AI authority/readiness governance logic
- semantic adapter authority contract
- Databento/Fusion activation state
- external advisory authority posture

## Stack choice

- Chosen stack: FastAPI + Jinja2 + lightweight JS polling
- Reason: local-first, low-friction deployment, easy bounded read-only data ingestion, no extra service complexity

## Dashboard read surfaces

Primary read roots:

- `MQL5/Files/AI`
- `MQL5/Files/AI/external_adapter/atas_semantic_adapter`

Key surfaces consumed include:

- Runtime authority/status posture:
  - `runtime_governance_status.json`
  - `execution_authority_status.json`
  - `operational_integrity_status.json`
  - `ai_activation_readiness_status.json`
- Context/envelope/advisory:
  - `diagnostic_runtime_summary.json`
  - `ai_decision_envelope_trace.jsonl`
  - `atas_runtime_context.json`
  - `atas_runtime_context_status.json`
  - `atas_governed_advisory_status.json`
  - `atas_governed_advisory_effectiveness.json`
- Trade/lineage/evidence:
  - `ai_institutional_learning_trade_lineage.jsonl`
  - `ai_institutional_learning_events.jsonl`
  - `ai_strategy_memory_events.jsonl`
  - `ai_trade_feedback.json`
  - forensic status surfaces
  - adapter runtime status artifacts

## Implemented pages/views

- System Overview
- Current Market/Runtime Context
- Last Trades
- Rejections/Non-Entry
- Forensics/Evidence
- Levels Comparative (FINAL vs ATAS)
- Search/Inspect
- JSON API mirrors for each view
- `/health` endpoint

## Read-only and non-authoritative guarantees

- No write-back route implemented.
- No runtime mutation command endpoint exists.
- No trade/risk/governor controls exposed.
- Missing/optional fields are surfaced as `UNAVAILABLE` explicitly.

## Internal MT5 dashboard cleanup performed

- Soft-disabled internal chart dashboard UI by default (`EnableInternalDashboardChartUI=false`).
- Kept dashboard collector/page-build path active through `DashboardProcessPendingActions()`.
- Disabled chart click handling when UI gate is off.
- Explicitly clears chart dashboard objects while disabled.

## Internal MT5 components intentionally preserved

- Dashboard collector polling logic
- Dashboard page model building
- Dashboard status/evidence production chain
- Existing dashboard-related runtime integrity domain semantics

## Authority boundary preservation

- MT5 remains sole execution/risk/governance authority.
- External dashboard remains display-only.
- No advisory authority elevation introduced.
- No Databento/Fusion/hybrid activation changes.

## Compile/build status

- MT5 compile command used:
  - `C:\Program Files\MetaTrader 5\MetaEditor64.exe /compile:"...\\MQL5\\Experts\\AI\\main_ea.mq5" /log:"...\\backup_archives\\compile_main_ea_20260410_014757.log"`
- Process exit code observed:
  - `1` (MetaEditor CLI quirk; not authoritative for success)
- Compile log:
  - `backup_archives/compile_main_ea_20260410_014757.log`
- Result from log:
  - `0 errors, 2 warnings`
  - warnings: implicit int->string conversions (pre-existing)
  - build artifact updated: `MQL5/Experts/AI/main_ea.ex5`

## How to run locally

From `MQL5/Experts/AI/external_dashboard`:

1. `.\run_external_dashboard.ps1`
2. Open `http://127.0.0.1:8010`

## Residual risks

- Data quality is bounded by availability/freshness of runtime file surfaces.
- Some optional surfaces may remain absent at runtime and display as `UNAVAILABLE`.
- UI soft-disable assumes chart rendering is the only clutter source; any other chart overlays remain governed by their own gates.

## Recommended next bounded validation step

Run one live session with MT5 active and confirm:

1. Internal chart clutter is removed with default UI gate off.
2. Dashboard collector/status surfaces continue updating.
3. External dashboard pages reflect live surface changes without write-back behavior.
