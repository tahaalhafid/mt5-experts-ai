# Cross-Surface Lineage Consistency Forensic Report

Generated: 2026-04-09 01:25 (+03:00)  
Scope: Last 10 entered trades from prior forensic package baseline.

## Executive Summary
Factual extraction shows that core trade direction/symbol and several regime fields remain stable, but per-trade lineage degrades materially when moving from decision/open surfaces into learning-event and memory surfaces. The dominant weakness is identity flattening in downstream learning artifacts: decision linkage becomes partial, strategy identity collapses toward normalized labels, and SR context frequently collapses to generic buckets.  

Inference: the current learning surfaces remain usable for aggregate motif statistics, but are lossy for high-fidelity per-trade forensic reconstruction.

## Scope and Method
- Baseline trade set: `forensic_exports/last10_trades_forensic_20260409_001811/last10_trades_master_table.json`
- Compared surfaces:
- `..\\..\\Files\\AI\\ai_institutional_learning_decision_context.jsonl`
- `..\\..\\Files\\AI\\ai_institutional_learning_events.jsonl`
- `..\\..\\Files\\AI\\ai_institutional_learning_memory.json`
- `..\\..\\Files\\AI\\ai_strategy_memory_events.jsonl`
- `..\\..\\Files\\AI\\council_feedback.json`
- `..\\..\\Files\\AI\\atas_governed_advisory_status.json`
- `..\\..\\Files\\AI\\atas_governed_advisory_effectiveness.json`
- `..\\..\\Files\\AI\\ai_trade_feedback.json`
- Optional runtime log aid: `..\\Logs\\20260408.log`

## Produced Machine-Readable Deliverables
- `last10_trade_lineage_consistency_table.csv`
- `last10_trade_lineage_consistency_table.json`
- `last10_trade_lineage_per_trade_matrix.json`
- `lineage_raw_source_references.json`

## Last-10 Trade Matrix Summary
- Trades audited: 10/10
- Identity linkage class: `DRIFTED` in 10/10
- Strategy identity class: `FLATTENED` in 10/10
- Regime/environment class: `PRESERVED` in 3/10, `DRIFTED` in 7/10
- Support/resistance lineage class: `PRESERVED` in 2/10, `FLATTENED` in 8/10
- Advisory lineage class: `PRESERVED` in 1/10, `PARTIALLY_PRESERVED` in 9/10
- Attribution lineage class: `FLATTENED` in 10/10
- Learning lineage class: `FLATTENED` in 10/10

## Per-Trade Consistency Snapshot
| Trade Index | Decision ID | Close Deal ID | Identity | Strategy | Regime/Env | SR | Advisory | Attribution | Learning | Most Important Lineage Loss |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | XAUUSD-1775687836-100535-352 | 7663218973 | DRIFTED | FLATTENED | PRESERVED | FLATTENED | PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 2 | XAUUSD-1775687230-100525-350 | 7663065838 | DRIFTED | FLATTENED | DRIFTED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 3 | XAUUSD-1775687230-100525-350 | 7662984954 | DRIFTED | FLATTENED | DRIFTED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 4 | XAUUSD-1775686536-100513-342 | 7662783422 | DRIFTED | FLATTENED | DRIFTED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 5 | XAUUSD-1775683413-100461-310 | 7661956776 | DRIFTED | FLATTENED | DRIFTED | PRESERVED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 6 | XAUUSD-1775681784-100434-290 | 7660947990 | DRIFTED | FLATTENED | DRIFTED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 7 | XAUUSD-1775678857-100385-256 | 7659899479 | DRIFTED | FLATTENED | PRESERVED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 8 | XAUUSD-1775676870-100352-228 | 7659306455 | DRIFTED | FLATTENED | DRIFTED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 9 | XAUUSD-1775674237-100308-192 | 7658357635 | DRIFTED | FLATTENED | PRESERVED | PRESERVED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |
| 10 | XAUUSD-1775664074-100139-38 | 7653114362 | DRIFTED | FLATTENED | DRIFTED | FLATTENED | PARTIALLY_PRESERVED | FLATTENED | FLATTENED | Learning event missing decision/deal precision |

## Cross-surface lineage integrity findings
### 1) Fields that stay consistent across surfaces (factual)
- `symbol` preserved in 10/10.
- `direction` preserved in 10/10.
- `structure_bucket` preserved in 10/10.
- `volatility_regime` preserved in 10/10.
- success/failure outcome class preserved in 10/10.

### 2) Fields that commonly degrade (factual)
- decision linkage remains only partial (`decision_id_linkage_status=PARTIALLY_PRESERVED` in 10/10).
- ticket/deal/position lineage drifts in 10/10 (close and position fields transformed/inconsistent in downstream learning events).
- timestamps are only partially preserved in 10/10.
- regime label drift appears in 7/10.
- advisory lineage is mostly partial (9/10), largely because snapshots/aggregates are not per-trade ledgers.

### 3) Fields that collapse to generic values (factual)
- strategy name flattened in 10/10.
- learning identity flattened in 10/10.
- motif tags flattened in 10/10.
- primary attribution normalized in 8/10.
- SR interaction flattened in 8/10.
- canonical level state missing in 9/10.

### 4) Strategy identity over-normalization (factual + interpretation)
- Factual: trade-open context often shows specific strategy IDs (for example `sweep_reversal`), but learning events/memory frequently store normalized `sweep_detector`.
- Inference: strategy-family aggregation is functional for motif rollups but weakens per-strategy forensic discrimination.

### 5) Support/Resistance context retention (factual + interpretation)
- Factual: decision context stores specific SR buckets (for example rejection/confluence states), while learning motif keys frequently contain `SR_UNKNOWN`.
- Inference: SR context is materially under-retained in downstream memory for post-trade root-cause precision.

### 6) Learning memory fidelity and usability (inference based on factual counts)
- Per-trade forensic fidelity: weak (identity/attribution flattening is systematic).
- Aggregate memory utility: still acceptable for bounded directional motif tracking, not ideal for precise trade-by-trade reconstruction.

## Missing / Unavailable / Unverifiable
- `ai_performance_journal.jsonl` not ingested in this audit due governed live-locked exclusion rule.
- Advisory effectiveness is aggregate by design, so per-trade advisory-field lineage from this surface is unverifiable.
- Some close-event fields in council/feedback are intentionally sparse or blank, limiting high-granularity lineage confirmation.

## Factual vs Inferred Labels
- Factual extracted data is stored directly in:
- `last10_trade_lineage_consistency_table.json`
- `last10_trade_lineage_per_trade_matrix.json`
- Inferred interpretation statements are explicitly marked in this report and derived from factual classifications/counts only.

