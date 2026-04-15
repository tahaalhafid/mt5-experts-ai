# OPERATION_GUARDRAILS.md

## Mandatory Pre-Read Status

This file MUST be read before any future diagnosis, surgery, or execution step.
AGENTS.md MUST also be read before any execution step.

Every future report produced under this program must explicitly state:

```
Read AGENTS.md: yes
Read OPERATION_GUARDRAILS.md: yes
```

---

## System Authority Locks (Non-Negotiable)

### MT5 is sole authority

MT5 remains the sole runtime authority, decision authority, risk authority, governor authority, and execution authority for this system.

No ATAS advisory context, no AI review surface, no plan file, no dashboard output, and no external adapter component may override, bypass, or silently escalate MT5 authority.

### ATAS is bounded external intelligence only

ATAS contributes microstructure advisory context only — order flow evidence, liquidity/absorption/imbalance signals. It carries zero runtime authority. It cannot generate trades, override decisions, mutate the risk envelope, or govern execution.

ATAS advisory role is permanently capped at BOUNDED_CONTEXT or SHADOW_ONLY consumption mode. Neither mode allows autonomous trade generation. ATAS dark state (no advisory) is acceptable and governed. MT5 continues independently on base environment.

### AI advisory is not AI authority

The presence of AI review, AI readiness surfaces, or AI advisory outputs does NOT imply AI execution authority. AI advisory surfaces remain non-authoritative unless explicitly unlocked through governed plan changes.

---

## Phase Discipline Rules

### Six-Phase Program Ledger

| Phase | Name | Status |
|-------|------|--------|
| Phase 1 | Revive Direct Write primary path | COMPLETE |
| Phase 2 | Live stabilization / runtime verification of the primary path | COMPLETE |
| Phase 3 | Advisory review on live/fresh primary data | COMPLETE (diagnostic complete; live attachment observation still desirable but not a blocker) |
| Phase 4 | Dormant-branch containment / structural clutter containment | COMPLETE — Phase 4-A COMPLETE (2026-04-14); Phase 4-B COMPLETE (2026-04-14) |
| Phase 5 | strategy_runtime containment / compatibility isolation | STRUCTURAL CONTAINMENT COMPLETE (2026-04-14) — guard shell in place; STRATEGY_RUNTIME_DISABLE_ZONE2 not activated |
| Phase 6 | Advisory apparatus compression and legacy-retirement preparation | NOT_STARTED |

### Phase transition rules

- A phase is COMPLETE only when: real file creation, freshness, rotation/movement, and meaningful runtime truth are ALL confirmed.
- Source-code presence or config correctness alone does NOT constitute phase completion.
- A phase is BLOCKED when a specific identified blocker prevents completion. The blocker must be named.
- Do NOT silently advance to the next phase. State explicitly why the current phase is complete before transitioning.
- Do NOT perform work from a future phase while a current phase is blocked.

---

## Surgery Discipline Rules

### Minimum-change rule

Apply the smallest correct patch that solves the real problem. Do not:
- refactor surrounding code
- clean up adjacent files opportunistically
- improve beyond what is strictly required
- add features not asked for

### No hidden scope expansion

Every edit must be explicitly justified by the current phase's requirements. If an edit touches something outside that justification, stop and state the ambiguity before proceeding.

### No broad waves

Do not bundle multiple large surgeries together. One phase at a time. One correction at a time within that phase.

### Stop on material ambiguity

If evidence is inconclusive, if authority boundaries are unclear, or if a proposed change may have effects beyond the stated scope, STOP and report the ambiguity before acting.

---

## Runtime Truth Requirements

### File existence is not liveness

A file existing on disk is not sufficient evidence that the path is live. Required for a live path:
- recent `written_at` timestamp (within the freshness window)
- advancing `packet_id` or `sequence` across reads
- matching schema version
- MT5-side status confirming ingestion (not just file presence)

### Source correctness is not runtime correctness

Code that is correctly structured and compiled does not guarantee runtime behavior. Always verify at the runtime artifact level, not just the source level.

### Legacy fallback is not primary path success

If MT5 is consuming data from a legacy fallback surface (`atas_runtime_context.json`) rather than the primary Direct Write surface (`atas_microstructure_context.json`), Phase 1 is NOT complete. The primary path must be the live path.

---

## Specific Guardrails Per Phase

### Phase 1 specific
- Phase 1 is complete ONLY when `atas_microstructure_context.json` exists with fresh, rotating `written_at` values
- `atas_microstructure_status.json` must also exist reflecting a live writer
- The legacy surface (`atas_runtime_context.json`) existence is not a substitute
- ATAS indicator type resolution must be confirmed by the indicator actually producing output — not inferred from deployment state alone

### Phase 2 specific
- Do not declare the path stable from one read. Verify across at least two distinct read moments.
- Verify primary path is being consumed (not legacy fallback) by checking MT5-side status
- Verify advisory freshness (not shadow_not_attached, not EXPIRED)
- Do not expand into structural cleanup during Phase 2

### Phase 3 specific
- Advisory review is read-only analysis — no advisory configuration changes
- Do not change consumption mode, overlay weight, or advisory gating logic
- Do not compress the advisory apparatus during Phase 3

### Phase 4 specific
- Dormant-branch containment is ISOLATION, not DELETION
- No code deletion without explicit consumer safety analysis
- `strategy_runtime.mqh` is mixed-role — contains both dead council paths and live utility functions. It is NOT uniformly dead.
- Confirm consumer dependency before any isolation action

### Phase 5 specific
- `strategy_runtime.mqh` containment must be approached with extreme caution
- Mixed-role classification stands until proven otherwise for each function individually
- Conditional compile guards preferred over removal

### Phase 6 specific
- Advisory compression must not be bundled carelessly
- Legacy retirement requires explicit consumer audit first
- A surface is not retired until all consumers are confirmed to have a working primary alternative

---

## Legacy Compatibility Surfaces

The following surfaces are currently the ONLY data MT5 reads for ATAS context. They must not be removed or retired until `atas_microstructure_context.json` is live and confirmed consumed:

- `MQL5/Files/AI/atas_runtime_context.json` — legacy read surface (currently stale but still the defined intake path fallback context)
- `MQL5/Files/AI/atas_runtime_context_status.json` — legacy status mirror

Note: MT5 intake (`atas_intake_layer.mqh`) reads exclusively from `atas_microstructure_context.json` (primary Direct Write target) and has NO fallback to `atas_runtime_context.json`. The primary path is now LIVE. ATAS is no longer dark — MT5 evaluates the primary file and writes `atas_microstructure_status.json` on each heartbeat cycle. Advisory remains SHADOW_NOT_ATTACHED only when ATAS is not running concurrently or is outside London/NY session hours.

---

## Known Active Risks (as of 2026-04-13)

| Risk | Severity | Phase |
|------|----------|-------|
| ~~`AtasObservationExporterIndicator` TypeNameResolver failure — indicator not producing output~~ | ~~HIGH~~ | RESOLVED (Phase 1) |
| `TryReadCandleSnapshot` reflection-based candle access may fail silently in ATAS 8.0.12.353 | MEDIUM | Phase 1 (deferred — writer producing output, not confirmed root cause) |
| ~~MT5 EA not running on XAUUSD — consumer side dark, `atas_microstructure_status.json` absent~~ | ~~HIGH~~ | RESOLVED (Phase 2) |
| Governor threshold ambiguity — whether `RunCouncilGovernorDecision()` policy reaches `EvaluateCouncilPreAIGate()` cfg | MEDIUM | Deferred |
| Rollback monitoring never armed — `ai_rollback_state.json` empty | LOW | Deferred |
| Runtime freeze active — no trade data flowing | HIGH | Operational |

---

## Backup Requirement (from AGENTS.md)

Before any modification to source files, a backup must be created at:
`terminal-root/backup_archives/pre_change_<YYYYMMDD_HHMMSS>_<short_scope>.zip`

Backup must cover both:
- `MQL5/Experts/AI`
- `MQL5/Files/AI`

Exclude `MQL5/Files/AI/ai_performance_journal.jsonl` (live-locked append-only runtime journal).

---

## File Classification Reference

| File | Class | Notes |
|------|-------|-------|
| `atas_microstructure_context.json` | PLAN_OR_CONFIGURATION_AUTHORITY (when live) | Primary Direct Write target — LIVE as of 2026-04-13 |
| `atas_microstructure_status.json` | RUNTIME_AUTHORITATIVE_STATUS (when live) | MT5 evaluation status — LIVE as of 2026-04-13 19:50 UTC |
| `atas_runtime_context.json` | HISTORICAL_LINEAGE_OR_EVIDENCE | Last written 2026-04-10, schema V1 (legacy) |
| `atas_runtime_context_status.json` | DERIVED_OR_VISIBILITY_ONLY | Legacy status, stale since 2026-04-10 |
| `ai_current_plan.json` | PLAN_OR_CONFIGURATION_AUTHORITY | plan_v076, freeze active |
| `ai_governor_state.json` | RUNTIME_AUTHORITATIVE_STATUS | Currently empty — adaptive capability dormant |
| `ai_rollback_state.json` | RUNTIME_AUTHORITATIVE_STATUS | Currently empty — safety mechanism dormant |
| `ai_performance_journal.jsonl` | JOURNAL_OR_SUPPORT_ARTIFACT | Live-locked, do not read during operation |
| `AGENTS.md` | EXECUTION_AUTHORITY | Governance document — mandatory pre-read |
| `OPERATION_GUARDRAILS.md` | EXECUTION_AUTHORITY | This file — mandatory pre-read |
