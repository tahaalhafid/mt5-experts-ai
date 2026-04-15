# Lineage Fidelity Schema v1

## Surface Classification
- Runtime authority truth: MT5 execution/governor/risk modules (unchanged by this patch).
- Derived learning truth: `AI/ai_institutional_learning_memory.json`.
- Evidence stream:
  - `AI/ai_institutional_learning_decision_context.jsonl`
  - `AI/ai_institutional_learning_events.jsonl`
  - `AI/ai_institutional_learning_trade_lineage.jsonl` (new high-fidelity layer)
- Status:
  - `AI/ai_institutional_learning_status.json`
  - `AI/ai_institutional_learning_lineage_status.json` (new diagnostics)

## Extended Decision Context Fields
Added to `ai_institutional_learning_decision_context.jsonl`:
- `support_resistance_confluence_state`
- `canonical_level_state`
- `sr_confluence_flag`
- `sr_rejection_risk_flag`
- `sr_continuation_obstructed_flag`
- `sr_canonical_near_flag`
- `sr_conflicted_flag`

## Extended Learning Event Fields
Added to `ai_institutional_learning_events.jsonl`:
- `trade_lineage_key`
- `position_id` (full-width)
- `entry_deal_id` (full-width)
- `close_deal_id` (full-width)
- `entry_time`
- `exit_time`
- `runtime_strategy_id_exact`
- `runtime_strategy_family_exact`
- `feedback_strategy_id`
- `aggregated_strategy_bucket`
- `support_resistance_confluence_state`
- `canonical_level_state`
- SR flags
- `advisory_reason_summary`
- `runtime_primary_attribution`
- `runtime_secondary_attribution`
- `aggregated_primary_attribution`
- `aggregated_secondary_attribution`

## New High-Fidelity Trade Lineage Event
File: `AI/ai_institutional_learning_trade_lineage.jsonl`

Core fields:
- `trade_lineage_key`
- `decision_id`
- `correlated_decision_id`
- `position_id`
- `entry_deal_id`
- `close_deal_id`
- `symbol`
- `direction`
- `entry_time`
- `exit_time`
- strategy exact + family + aggregated bucket
- regime/volatility/structure
- SR bucket + raw state + canonical level state + SR flags
- advisory contradiction/relevance/summary
- runtime + aggregated attribution pairs
- `attribution_reason_codes_csv`
- per-trade lineage consistency statuses:
  - `identity_linkage_status`
  - `strategy_lineage_status`
  - `sr_lineage_status`
  - `advisory_lineage_status`
  - `attribution_lineage_status`

## Trade Feedback Extended Fields
Added in `TradeFeedbackRecord` and serialized output:
- `linked_runtime_strategy_id`
- `linked_runtime_strategy_family`
- `linked_support_resistance_bucket`
- `linked_support_resistance_state`
- `linked_canonical_level_state`
- SR lineage flags

Also repaired:
- `position_id`, `entry_deal_id`, `entry_order_id`, `close_deal_id` JSON serialization now preserves full-width values.

## Strategy Memory Close Event Extension
`SCM_RecordClosedTradeOutcome(...)` now supports optional lineage metadata:
- `position_id`
- `close_deal_id`
- `entry_deal_id`
- `close_time`
- `trade_lineage_key`
- `strategy_identity_source`

Backward compatibility:
- existing callers remain compatible via default arguments.
