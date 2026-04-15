# Dashboard Runtime Truth Root-Cause Repair Review v2

## Executive Summary
This patch repaired remaining dashboard/runtime truth gaps with a root-cause-first approach.  
The primary defects were cross-surface decision identity linkage drift and a forensics classification bug that mis-labeled non-advisory surfaces as ineligible.  
Repairs were applied at source/propagation depth first (including MT5-side lineage emission hardening), then dashboard hydration/display was aligned to that corrected chain.

No trading, execution, risk, governor, authority, AI posture, Databento/Fusion, semantic-adapter authority, or advisory authority behavior was changed.

## Scope and Boundaries
- In scope: lineage linkage, hydration precedence, classification integrity, inspect/rejection fidelity, ATAS truth hygiene verification.
- Out of scope: strategy behavior, decision policy semantics, authority boundaries, runtime control behavior.

## Root Cause Matrix (Gap-by-Gap)
| Gap | Observed Weakness | Root Cause Classification | Evidence | Repair Depth |
|---|---|---|---|---|
| Last Trades lossy rows | Flattened strategy/SR in rows where richer context existed | `SOURCE_VALID_BUT_NOT_LINKED`, `SOURCE_VALID_BUT_PRECEDENCE_WRONG`, partial `DASHBOARD_HYDRATION_WEAKNESS` | Decision ID variants across surfaces (e.g. `...-10016` vs `...-100165-80`) broke direct joins | Source + propagation + dashboard precedence |
| Rejections coarse detail | Direction and context often `UNKNOWN` | Mixed `SOURCE_VALID_BUT_NOT_LINKED` + `LEGITIMATELY_UNAVAILABLE` | Some rejection IDs resolve with context; many have no retained context rows in current artifact horizon | Dashboard linkage improved; genuine unavailability preserved |
| Inspect weak results | Query frequently produced low-value output | `DASHBOARD_HYDRATION_WEAKNESS`, `SOURCE_VALID_BUT_NOT_LINKED` | Numeric identifiers existed in lineage/events but lookup did not reliably back-link decision context | Dashboard lookup and merge logic strengthened |
| Forensics degraded/ineligible pockets | False `INELIGIBLE` on non-advisory surfaces | `SOURCE_VALID_BUT_CLASSIFIED_WRONGLY` | Generic classifier treated `advisory_eligible=false` as ineligibility even for non-advisory status files | Classification logic corrected |
| ATAS truth hygiene | Potential page-to-page inconsistency risk | Prior issue already fixed; current state verified as truthful | Context/Levels share same ATAS live-valid truth gate: `ATAS_REFERENCE_NOT_ATTACHED` + `FRESHNESS_WINDOW_EXPIRED` | Verification only (no regression, no authority changes) |

## What Was Repaired at Source / Propagation / Classification Level

### 1) MT5-side lineage continuity hardening
File: `MQL5/Experts/AI/institutional_learning_layer_v1.mqh`
- Added deterministic decision-link helpers:
  - `ILV1_BuildDecisionLinkKey(...)`
  - `ILV1_DecisionIdMatchScore(...)`
- Upgraded context/open-strategy resolution:
  - `ILV1_FindContextByDecisionId(...)`
  - `ILV1_FindStrategyOpenByDecisionId(...)`
  now support scored matching across decision-id variants.
- Added `decision_link_key` emission to:
  - decision-context artifacts
  - learning event artifacts
  - trade lineage artifacts

Impact: richer per-trade context survives identifier drift instead of collapsing to weaker aggregated fallback.

### 2) Dashboard lineage/hydration precedence hardening
File: `MQL5/Experts/AI/external_dashboard/app/aggregator.py`
- Added stamp-key linkage and deterministic fallback ladder:
  - exact decision id
  - decision base
  - decision stamp key
- Applied to trades, rejections, and inspect merge paths.
- Added explicit linkage-state surfaces:
  - `decision_link_state` (trades)
  - `context_link_state` (rejections)

Impact: rows now reveal whether data is direct vs derived instead of silently degrading.

### 3) Forensics classification correctness fix
File: `MQL5/Experts/AI/external_dashboard/app/aggregator.py`
- `_classify_surface(...)` now applies advisory ineligible/blocked semantics only to advisory-relevant surfaces.

Impact: non-advisory status surfaces no longer falsely appear `INELIGIBLE`.

## What Was Repaired at Dashboard Hydration / Display Level
- `external_dashboard/templates/trades.html` now displays `decision_link_state`.
- `external_dashboard/templates/rejections.html` now displays `context_link_state`.

These are truth-surfacing diagnostics; not cosmetic filling and not synthetic fallbacks.

## Gap Outcomes

### Last Trades
- Improved:
  - exact strategy identity now hydrates from richer sources when linkable (`sweep_reversal`, `trend_momentum`, etc.)
  - S/R bucket fidelity improved (`SR_CANONICAL_NEAR`, `SR_REJECTION_RISK`, `SR_CONTINUATION_OBSTRUCTED`)
  - posture/advisory/confidence fields hydrate where produced upstream
- Still weak:
  - fields absent in upstream artifacts remain explicitly unavailable (not fabricated)

### Rejections
- Improved:
  - stronger context linking where resolvable
  - explicit `context_link_state` for transparency
- Still weak:
  - many rows remain `UNKNOWN` direction due genuine source non-production within retained rejection context artifacts

### Inspect
- Improved:
  - better identifier search paths (`decision_id`, `ticket/deal/position`-style numeric back-link)
  - richer merged per-item records from lineage/events/context/envelope/memory
- Still weak:
  - entries with no corresponding retained context remain explicitly unavailable

### Forensics
- Improved:
  - reduced false degraded/ineligible classification caused by classifier bug
  - clearer availability/health signaling per section
- Still weak:
  - truly stale or degraded upstream surfaces remain flagged honestly

### ATAS Truth Hygiene
- Verified:
  - live-valid vs historical separation remains intact
  - no non-live ATAS packet levels are promoted as live-usable ATAS reference
  - Levels/Context ATAS truth state remains coherent

## Compile Verification (Touched MT5 Source)
- Target: `MQL5/Experts/AI/main_ea.mq5`
- Compiler log: `MQL5/Experts/AI/compile_dashboard_root_cause_truth_repair.log`
- Result: `0 errors, 2 warnings`
- Warnings:
  - `main_ea.mq5(13510,50)` implicit conversion int->string
  - `main_ea.mq5(13999,59)` implicit conversion int->string

## Authority and Governance Confirmation
- MT5 runtime authority remains unchanged.
- Dashboard remains read-only and non-authoritative.
- No execution/risk/governor/trading decision behavior was changed.
- No AI authority uplift and no Databento/Fusion activation changes.

## Remaining Weak Areas (Truthful)
1. Rejection rows with no retained decision-context companion records remain coarse.
2. Some legacy/historical artifacts still carry flattened attribution/strategy snapshots; this is surfaced as derived, not masked as direct.
3. Old sessions without newly emitted `decision_link_key` can only be linked via base/stamp heuristics.

## Recommended Next Bounded Validation Step
Run one short live MT5 session and verify fresh artifacts include `decision_link_key` end-to-end, then re-check:
- Last Trades linkage-state distribution (`DIRECT` should rise),
- Rejections direction/context hydration for new rejects,
- Inspect deep-search hit quality on newly produced records.

