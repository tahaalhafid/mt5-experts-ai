# Phase 4 Legacy ATAS Consumer Cutover — Implementation Report (v1)

## Scope
Surgical consumer cutover only. No decision-path, authority, governor, rollback, or ATAS advisory behavior changes.

## Primary vs Fallback Pattern Implemented
- Primary context: `MQL5/Files/AI/atas_microstructure_context.json`
- Primary status: `MQL5/Files/AI/atas_microstructure_status.json`
- Legacy fallback context: `MQL5/Files/AI/atas_runtime_context.json`
- Legacy fallback status: `MQL5/Files/AI/atas_runtime_context_status.json`

## Consumers Cut Over
- `MQL5/Experts/AI/main_ea.mq5`
  - SR overlay ATAS status/context readers now use primary-direct-write first with legacy fallback.
  - `source_surface` reporting now reflects the surface actually used.
- `MQL5/Experts/AI/external_dashboard/app/aggregator.py`
  - Overview/context/levels paths now load direct-write primary surfaces first with legacy fallback.
  - Forensics targets now list primary surfaces as primary and legacy surfaces as optional transitional.
- `MQL5/Experts/AI/external_dashboard/tools/atas_live_capture_monitor.py`
  - Intake context/status reads now use primary-direct-write first with legacy fallback.
- `MQL5/Experts/AI/external_dashboard/tools/atas_live_propagation_runner.py`
  - Snapshot context/status reads now use primary-direct-write first with legacy fallback.
- `MQL5/Experts/AI/external_dashboard/tools/atas_periodic_propagation_validation.py`
  - Cycle context/status reads now use primary-direct-write first with legacy fallback.

## Compatibility Notes
- Legacy files are preserved and still used as fallback.
- No legacy file retirement/removal/rename was performed.
- No path/key removals were made in emitted runtime artifacts.

## Verification
- Python syntax verification passed:
  - `external_dashboard/app/aggregator.py`
  - `external_dashboard/tools/atas_live_capture_monitor.py`
  - `external_dashboard/tools/atas_live_propagation_runner.py`
  - `external_dashboard/tools/atas_periodic_propagation_validation.py`

## Explicit Non-Changes
- No MT5 authority boundary changes.
- No live decision semantics changes.
- No council ordering changes.
- No rollback arming or threshold behavior changes.
- No ATAS rollout mode behavior changes.
