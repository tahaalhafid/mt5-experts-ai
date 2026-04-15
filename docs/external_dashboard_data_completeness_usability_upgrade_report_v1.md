# External Dashboard Data-Completeness and Usability Upgrade Report v1

## Scope

Bounded upgrade to the existing external read-only dashboard unit only.

No changes to:

- trading/entry/exit/execution logic
- risk/governor/authority boundaries
- AI posture
- Databento/Fusion state
- semantic-adapter authority posture
- advisory authority posture

## What was improved

### Last Trades hydration

- Added stronger multi-surface precedence across:
  - institutional trade lineage
  - institutional events
  - decision envelope trace
  - decision context
  - strategy memory events
  - trade feedback
  - advisory status (bounded fallback)
- Added state classification at field level:
  - `DIRECT`, `DERIVED`, `UNAVAILABLE`, `STALE`, `NOT_PRODUCED`
- Reduced avoidable flattening:
  - strategy exact identity prioritized before family/bucket fallbacks
  - richer S/R fields pulled where available
  - advisory eligibility/usage/posture visibility expanded

### Forensics hydration

- Replaced single flat surface table with grouped sections:
  - Lineage
  - Evidence Completeness
  - Decision Envelope Observability
  - Advisory Diagnostics
  - Learning Status
  - Runtime Authority / Readiness
  - Adapter Runtime
- Added explicit classification per surface:
  - `AVAILABLE`, `STALE`, `MISSING`, `NOT_YET_PRODUCED`, `BLOCKED`, `INELIGIBLE`, `EMPTY_BUT_VALID`
- Added reason code, update timestamp, and age seconds output.

### Levels comparative metrics

- Added explicit FINAL vs ATAS comparison metrics:
  - absolute difference
  - difference in points
  - relation (`CONFLUENCE_NEAR`, `DIVERGED`, `FINAL_ONLY`, `ATAS_ONLY`)
- Preserved architecture truth:
  - FINAL = runtime-relied-on
  - ATAS = comparison/reference only

### Inspect deep inspection

- Upgraded inspect from loose row listing to merged per-item view with:
  - identity
  - strategy
  - regime
  - support/resistance context
  - advisory context
  - attribution
  - learning
  - decision posture
  - timing/freshness
- Explicit missing values remain visible as `UNAVAILABLE`/`NOT_PRODUCED`.

## Files changed in dashboard unit

- `external_dashboard/app/sources.py`
- `external_dashboard/app/aggregator.py`
- `external_dashboard/app/main.py`
- `external_dashboard/templates/trades.html`
- `external_dashboard/templates/forensics.html`
- `external_dashboard/templates/levels.html`
- `external_dashboard/templates/inspect.html`
- `external_dashboard/static/style.css`

## MT5 source impact

- No MT5 source files were modified in this upgrade.
- No MT5 compile step was required for this dashboard-only patch.

## Remaining unavailable fields

Some per-trade fields remain unavailable when upstream runtime surfaces do not currently emit them for that specific trade instance (for example, missing trade-linked captures for older records). These are intentionally shown explicitly as `UNAVAILABLE` or `NOT_PRODUCED` rather than inferred/fabricated.

## Run instructions

Unchanged from existing dashboard setup:

- `MQL5/Experts/AI/external_dashboard/run_external_dashboard.ps1`
