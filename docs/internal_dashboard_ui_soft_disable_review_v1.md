# Internal Dashboard UI Soft-Disable Review v1

## Scope

Bounded visual-path change only for internal MT5 chart dashboard UI.

## Change summary

- Added `EnableInternalDashboardChartUI` input in `main_ea.mq5` (default: `false`).
- Preserved dashboard collector/state processing path while UI is disabled.
- Routed timer behavior:
  - UI enabled: existing `DashboardPhase1OnTimer()` path unchanged.
  - UI disabled: `DashboardProcessPendingActions()` only (no chart rendering).
- Routed chart-event behavior:
  - UI enabled: existing `DashboardPhase1OnChartEvent(...)` behavior unchanged.
  - UI disabled: chart dashboard click handling bypassed.
- Ensured chart objects are cleared when UI is disabled by calling `DashboardRemoveAllRendering()`.

## Preserved behavior

- Dashboard non-visual collectors and page model refresh remain active.
- Runtime status/evidence producers remain unchanged.
- Trading/execution/risk/governor/authority logic remains unchanged.

## Governance result

The internal dashboard chart UI is now soft-disabled by default to reduce chart clutter, while observability surfaces remain available for the external read-only dashboard unit.
