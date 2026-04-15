# Lineage Fidelity Contract v1

## Purpose
Define canonical, governance-safe cross-surface trade lineage so a closed trade can be reconciled across runtime, learning, and forensic surfaces without losing per-trade identity.

## Governance Boundaries (Locked)
- MT5 remains sole runtime authority for decision, execution, risk, and governance.
- External/advisory/learning surfaces remain non-authoritative.
- Semantic adapter remains mandatory.
- No Databento activation.
- No Fusion activation.
- No external authority transfer.

## Canonical Trade Lineage Key
Canonical key format:

`decision=<decision_id>|position=<position_id>|close_deal=<close_deal_id>`

Key generation rules:
- `decision_id` uses resolved runtime decision identifier when available.
- `position_id` and `close_deal_id` are carried as full-width unsigned values (no narrowing cast).
- Missing values are explicit, never silently dropped.

## Dual Representation Model
1. High-fidelity forensic lineage (per-trade, non-authoritative):
- `AI/ai_institutional_learning_trade_lineage.jsonl`
- preserves trade-level identity, strategy exact identity, S/R detail, advisory detail, and attribution detail.

2. Aggregated learning memory (bounded, non-authoritative):
- `AI/ai_institutional_learning_memory.json`
- continues motif compression/aggregation for bounded confidence/caution/context-fit shaping.

Contract rule:
- Aggregation may normalize.
- Normalization must not destroy original per-trade forensic lineage.

## Required Preserved Dimensions (when available)
- Trade identity: `decision_id`, `correlated_decision_id`, `position_id`, `entry_deal_id`, `close_deal_id`, symbol, direction, entry/exit time.
- Strategy lineage:
  - `runtime_strategy_id_exact`
  - `runtime_strategy_family_exact`
  - `feedback_strategy_id`
  - `aggregated_strategy_bucket`
- Regime/environment lineage:
  - regime, volatility, structure
  - contradiction markers
- Support/resistance lineage:
  - `sr_interaction_bucket`
  - `support_resistance_confluence_state`
  - `canonical_level_state`
  - confluence/rejection/obstruction/canonical-near/conflicted flags
- Attribution lineage:
  - runtime primary/secondary attribution
  - aggregated primary/secondary attribution
  - attribution reason codes
- Advisory lineage:
  - contradiction, relevance, advisory summary

## Consistency Diagnostics Surface
- `AI/ai_institutional_learning_lineage_status.json`
- non-authoritative diagnostics with explicit statuses and reason codes:
  - identity linkage status
  - strategy lineage status
  - SR lineage status
  - advisory lineage status
  - attribution lineage status

Status values are bounded forensic labels only:
- `PRESERVED`
- `PARTIALLY_PRESERVED`
- `FLATTENED`
- `MISSING`

## Non-Authority Clause
All lineage surfaces are strictly forensic/diagnostic/learning-evidence surfaces.
They must not directly approve, deny, size, execute, cancel, or risk-govern trades.
