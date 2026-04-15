# Dashboard Truth/Hydration Repair Review v1

## Scope
- Bounded external dashboard truth-consistency and hydration repair only.
- No MT5 trading/execution/risk/governor/authority logic changes.
- Dashboard remains read-only and non-authoritative.

## Root Cause: ATAS Truth Inconsistency
- `levels()` previously treated ATAS packet `level_candidates` presence as `AVAILABLE`.
- This allowed ATAS red-line availability even when status surfaces reported non-live states (`SHADOW_NOT_ATTACHED`, `EXPIRED`, ineligible advisory).
- Result: cross-page inconsistency between Overview/Context and Levels.

## Repair Applied
- Added unified ATAS truth gate (`_atas_reference_truth(...)`) and consumed it in:
  - `overview()`
  - `context()`
  - `levels()`
- Levels now draw ATAS live comparison layer only when `ATAS_LIVE_REFERENCE_AVAILABLE`.
- Historical packet levels are retained as diagnostic-only (`atas_diagnostic_historical`) and not treated as live-usable reference.

## Last Trades Hydration Improvements
- Improved per-row linking precedence using decision-base indexing across:
  - decision envelope trace
  - institutional learning decision context
  - strategy memory events (`TRADE_OPEN`)
  - institutional learning events
  - trade lineage
  - trade feedback
- Preserved richer strategy identity when available before aggregated buckets.
- Preserved richer S/R context and added state/source visibility:
  - `sr_interaction_bucket_state`
  - `canonical_level_state_state`
  - `level_interaction_type_state`
  - `support_resistance_observation_source`
- Expanded confidence/risk/fit/learning state display with DIRECT/DERIVED/UNAVAILABLE/NOT_PRODUCED semantics.

## Context vs Levels Consistency
- Added explicit `final_runtime_levels` and `atas_reference_truth` sections to Context page.
- Context now explains decision-envelope fallback precedence for final runtime S/R.
- Levels page now reflects same truth model and explicitly separates live ATAS vs historical diagnostic packet values.

## Inspect Upgrade
- Added decision-record fallback search when no direct trade-lineage match is found.
- Added deep merged view built from decision-envelope, decision-context, strategy-memory, and lineage surfaces.

## Forensics/Lineage Clarity
- Added `health_state` per surface (`HEALTHY`, `DEGRADED`, `AGGREGATION_ONLY`, `RISK`).
- Added health summary cards and legend.
- Preserves blunt classification honesty for stale/missing/ineligible/blocked states.

## Rejections Fidelity
- Added direction state (`DIRECT`/`DERIVED`/`UNAVAILABLE`) and additional contextual fields:
  - `decision_acceptance_posture`
  - `advisory_usage_state`
  - `sr_interaction_bucket`
- Keeps unavailable values explicit when source surfaces do not provide those fields.

## Remaining Weak/Unavailable Fields (Expected)
- Some historical rows still carry flattened strategy buckets (surface-limited historic lineage).
- S/R can remain `UNAVAILABLE` or `SR_UNKNOWN` when upstream envelopes/contexts never emitted concrete level fields for that decision.
- Advisory fields remain `NOT_EVALUATED` or unavailable when advisory gate path was not invoked for a given decision cycle.
- Rejection posture may remain unavailable where no matching decision-envelope record exists for the rejected decision id/base.
