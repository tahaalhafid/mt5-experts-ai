# ATAS Microstructure Program Risk Register v1

## Scope
- Phase coverage: `Phase 0 + Phase 1`
- Focus: authority and meaning safety, contract quality, and downstream integration risk.

| Risk ID | Risk | Trigger | Impact | Control (Phase 0/1) | Owner | Status |
|---|---|---|---|---|---|---|
| R-001 | Meaning authority drift | ATAS outputs interpreted as final market/regime/tradability meaning | Authority boundary break | Boundary lock doc + governance contract + forbidden field families | Program governance | Open (controlled) |
| R-002 | Operational authority drift | External status interpreted as execution/risk/governor command | Runtime safety failure | Non-authoritative contract markers + no control surfaces defined | MT5 authority owner | Open (controlled) |
| R-003 | Semantic sprawl | Unbounded optional interpretive fields in early packets | Low reliability, unclear traceability | Core/Extended split + ownership map + confidence ceiling | ATAS contract owner | Open (controlled) |
| R-004 | Packet bloat | Extended packet treated as required | Fragile runtime coupling | Core packet minimal mandatory subset; extended optional/non-binding | Integration owner | Open (controlled) |
| R-005 | Non-traceable inference | Interpretive outputs with weak provenance | Audit failure | Mandatory provenance block + trace/suppression contracts | Diagnostics owner | Open (controlled) |
| R-006 | Premature dependence on optional fields | MT5 or dashboards assume extended fields always exist | Runtime instability | Explicit availability states + governance rules + suppression taxonomy | Consumer owners | Open (controlled) |
| R-007 | Freshness misclassification | Clock/timestamp mismatch across stages | False attachment/suppression outcomes | Freshness rule set with baseline semantics and source fields | Intake/export owners | Open |
| R-008 | Historical packet reuse as live | Old packet presented as live-valid | Misleading runtime context | Live-valid states in engine status + historical-only classification | Status owner | Open (controlled) |
| R-009 | Unsupported fallback behavior | Missing field silently defaulted to authoritative-looking value | False confidence | Required `UNAVAILABLE/NOT_PRODUCED/SUPPRESSED` semantics | Contract owner | Open (controlled) |
| R-010 | Traceability gaps across stages | Packet ID/trace ID not preserved | Forensic and debugging gaps | Required lineage fields in all packet families | Program engineering | Open |

## Residual Notes
- This register is foundational and intentionally conservative.
- Mitigation execution beyond contract/foundation is deferred to later engine phases.
