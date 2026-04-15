# Field Families and Ownership Map v1

## Ownership Classes
- `MT5_RUNTIME_AUTHORITY_ONLY`
- `ATAS_EXTERNAL_NON_AUTHORITATIVE`
- `EXTERNAL_DERIVED_STATUS`
- `MT5_DERIVED_RUNTIME_STATUS`
- `EVIDENCE_AND_FORENSICS_ONLY`

## Family Map

| Family | Description | Canonical Owner | Allowed In | Forbidden Meaning |
|---|---|---|---|---|
| `identity_lineage` | `packet_id`, `trace_id`, stage lineage ids | Shared lineage contract (non-authoritative) | Core, Extended, Engine Status, Trace | Any authority inference |
| `source_binding` | `source_symbol`, `source_symbol_original`, `execution_symbol`, source platform/mode | ATAS external chain | Core, Extended, Engine Status | Final tradability ownership |
| `time_freshness` | `event_time`, `created_time`, `fresh_until`, evaluated timestamps | ATAS emits, MT5 validates | Core, Engine Status, Diagnostics | Gate bypass semantics |
| `microstructure_observation` | sweep/absorption/delta/imbalance/stability states | ATAS external chain | Core, Extended | Final market meaning ownership |
| `cross_instrument_basis_evidence` | source/execution reference prices, basis value, suppression flags | ATAS external chain | Core, Extended, Suppression | Final canonical level ownership |
| `quality_confidence` | quality state, packet confidence, confidence ceiling | ATAS emits, contracts govern | Core, Extended, Engine Status | Decision authority uplift |
| `governed_advisory_context` | caution/hold/reeval/contradiction context | MT5 advisory derivation | Extended, Decision Basis Summary | Execution/risk/governor control |
| `interpretive_hints` | optional context-fit hints and motif-like tags | ATAS research layer | Extended only | Regime/tradability verdict |
| `suppression_diagnostics` | suppression class/reason taxonomies | MT5+external diagnostics contracts | Suppression, Trace, Diagnostics | Suppression removal by display |
| `engine_health` | stage states, first failing gate, lag metrics | Engine status writer | Engine Status, Diagnostics | Runtime authority mutation |
| `decision_basis_summary` | non-binding explanation of what ATAS contributed | Diagnostics contract | Context Decision Basis Summary | Final decision package ownership |

## Explicit Forbidden Families in ATAS Outputs
- Final decision verdict family (`SEND_BUY`, `SEND_SELL`, `BLOCK_TRADE_FINAL`).
- Final tradability ownership family.
- Final regime ownership family (`REGIME_FINAL`, `REGIME_OWNER`).
- Final canonical level ownership family (`CANONICAL_LEVEL_FINAL_OWNER`).
- Risk/governor override family.

## Split Rule
- `context_packet_core`:
  - strict, bounded, minimal, freshness/provenance-centric.
  - only candidate for future bounded MT5 consumption path.
- `context_packet_extended`:
  - optional interpretive envelope.
  - research-grade and non-binding by contract.
