# Lineage Fidelity Repair Implementation Report v1

## Scope
Bounded lineage-fidelity repair only:
- preserve per-trade forensic identity across learning/reporting surfaces
- keep existing aggregated learning memory intact
- no trading/risk/governor/authority behavior expansion

## Implemented Repair Areas

### 1) Canonical lineage + dual representation
- Added high-fidelity per-trade lineage stream:
  - `AI/ai_institutional_learning_trade_lineage.jsonl`
- Kept aggregated motif memory unchanged:
  - `AI/ai_institutional_learning_memory.json`
- Added canonical key:
  - `decision=<decision_id>|position=<position_id>|close_deal=<close_deal_id>`

### 2) Strategy identity preservation
- `ILV1_RecordClosedTradeOutcome(...)` now:
  - resolves missing decision IDs from correlated ID and deal comments
  - attempts strategy recovery from `ai_strategy_memory_events.jsonl` TRADE_OPEN by decision ID
  - prefers linked runtime strategy identity when available
- `main_ea.mq5` now passes linked runtime strategy identity to strategy-memory close writer.
- Strategy-memory close event now records lineage source (`ILV1_CONTEXT_LINKED` or fallback source).

### 3) Support/resistance fidelity preservation
- Extended decision context to store:
  - raw `support_resistance_confluence_state`
  - `canonical_level_state`
  - SR flags (confluence/rejection/obstruction/canonical-near/conflicted)
- Trade feedback linkage now carries SR bucket + raw SR state + canonical state + SR flags.
- Learning event and high-fidelity lineage event now preserve these SR dimensions.

### 4) Attribution split preservation
- Learning event now emits:
  - runtime attribution (`runtime_primary_attribution`, `runtime_secondary_attribution`)
  - aggregated attribution (`aggregated_primary_attribution`, `aggregated_secondary_attribution`)
- High-fidelity lineage event preserves both representations plus reason codes.

### 5) Cross-surface lineage diagnostics
- Added diagnostics status surface:
  - `AI/ai_institutional_learning_lineage_status.json`
- Status includes per-trade classification with explicit reason codes for degraded lineage.

### 6) 64-bit linkage preservation repair
- Repaired lossy ID serialization in trade feedback + learning events:
  - removed narrowing casts to signed int for `position_id`, `entry_deal_id`, `entry_order_id`, `close_deal_id`.

## Safety and Governance
- No authority transfer added.
- No execution/risk/governor decision authority granted to learning/advisory surfaces.
- No Databento/Fusion activation.
- No semantic adapter bypass.

## Compile Verification Note
- MetaEditor CLI returned exit code 0 but did not emit compiler log artifacts in this environment.
- A compile attempt log and static symbol consistency checks were recorded in:
  - `compile_lineage_fidelity_repair.log`

## Recommended Next Validation
Run one bounded closed-trade replay/live-close cycle and verify:
1. `ai_institutional_learning_trade_lineage.jsonl` receives full lineage fields.
2. `ai_institutional_learning_lineage_status.json` reports expected statuses.
3. `ai_strategy_memory_events.jsonl` TRADE_CLOSE includes lineage IDs and strategy identity source.
4. Aggregated memory remains populated and bounded.
