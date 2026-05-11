# OPERATION_GUARDRAILS.md

## Mandatory Pre-Read Status

This file MUST be read before any future diagnosis, surgery, or execution step.
AGENTS.md MUST also be read before any execution step.

Every future report produced under this program must explicitly state:

```
Read AGENTS.md: yes
Read OPERATION_GUARDRAILS.md: yes
```

Every execution mission report must also end with the PIML monitoring lines:

```
PIML_READ: YES / NO
PIML_UPDATE: YES / NO
PIML_SECTIONS: <brief section refs — only if update was YES>
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

## Known Active Risks (as of 2026-04-22)
> Architecture model: three primary computation chains (MarketRegimeSnapshot / gRegime-RegimeClassificationV1 / council zone). Any framing that treats this as a two-device architecture is incomplete. See PLAN-ARCH-DR in PIML and Regime Authority Discipline in AGENTS.md.

| Risk | Severity | Phase |
|------|----------|-------|
| ~~`AtasObservationExporterIndicator` TypeNameResolver failure — indicator not producing output~~ | ~~HIGH~~ | RESOLVED (Phase 1) |
| `TryReadCandleSnapshot` reflection-based candle access may fail silently in ATAS 8.0.12.353 | MEDIUM | Phase 1 (deferred — writer producing output, not confirmed root cause) |
| ~~MT5 EA not running on XAUUSD — consumer side dark, `atas_microstructure_status.json` absent~~ | ~~HIGH~~ | RESOLVED (Phase 2) |
| Governor threshold ambiguity — whether `RunCouncilGovernorDecision()` policy reaches `EvaluateCouncilPreAIGate()` cfg | MEDIUM | Deferred |
| Rollback monitoring never armed — `ai_rollback_state.json` empty | LOW | Deferred |
| Runtime freeze active — `strategy_transfer_runtime_freeze_active=true` (factory-first admission policy lock in plan_v076); trades ARE flowing under active cohort governance; this is NOT a trade data blockage; the freeze governs strategy transfer admission only | LOW | Operational |
| CouncilDirtyEnvironmentGate asymmetry — gRegime=COMPRESSION blocks AFTER council has routed to TREND_CONTINUATION; no reconciliation clause; ERA post-routing veto of ExRA decision | HARMFUL | PLAN-ARCH-DR Stage P4 (data-dependent) |
| ~~AI scope key mismatch~~ — **RESOLVED (P3.1A IMPLEMENTED + RUNTIME_CONFIRMED 2026-04-25).** `CouncilAIAdvisoryBuildCandidateScope()` now uses V2 ExRA-primary key format (`COUNCIL\|V2\|<direction>\|<zone_text>\|<best_strategy_id>`). Council-mode advisory scope is now ExRA-keyed. | RESOLVED | PLAN-ARCH-DR Stage P3.1A CLOSED |
| ~~Strategy intelligence mismatch~~ — **RESOLVED (P3.2 IMPLEMENTED + COMPILE_VERIFIED 2026-04-25).** `ComputeEntryQualityV1()` now uses ExRA council zone for trendish/rangish classification when `activeMode=="COUNCIL"` and zone_type is not UNDEFINED; ERA fallback preserved for non-council and UNDEFINED-zone paths. Runtime confirmation is plan-gated (`strategy_intelligence_enabled` not yet set true in plan_v076). | RESOLVED (compile) / PLAN_GATED (runtime) | PLAN-ARCH-DR Stage P3.2 COMPILE_VERIFIED |
| Journal analytics mismatch — journal_analytics.mqh reads regime_label (gRegime) only; council-mode performance analytics stratified by admission authority, not routing authority | ANALYTICS_MISMATCH | PLAN-ARCH-DR downstream of P2.B (bridge field is prerequisite infrastructure; analytics consumer update is a separate downstream stage) |
| ~~Dead fallback~~ — **RESOLVED (P3.3 IMPLEMENTED + COMPILE_VERIFIED 2026-04-22).** Permanently dead string-search clauses removed from `CouncilIsCompressionContext()` and `CouncilIsExpansionContext()` in `council_strategies.mqh`. Both functions now contain only the active zone_type enum condition. | RESOLVED | PLAN-ARCH-DR Stage P3.3 CLOSED |
| ~~Institutional learning motif key contamination~~ — **RESOLVED (P3.1B IMPLEMENTED + RUNTIME_CONFIRMED 2026-04-25).** `ILV1_DecisionContext` now carries `zone_bucket`; `ILV1_BuildMotifKey()` now emits `keyver=2\|...\|zone=<zone_text>\|...`; V2 silent orphaning active (no migration; old v1 motifs accumulate separately). | RESOLVED | PLAN-ARCH-DR Stage P3.1B CLOSED |
| ~~Malformed journal/runtime contract~~ — **RESOLVED 2026-04-22 (P2.A FULLY_CLOSED).** Three provenance helper functions in `performance_journal.mqh` (lines 160–185) corrected; double-comma defect eliminated at source. Current TRADE records (post 2026-04-22 19:55) parse cleanly under strict json.loads(). Historical TRADE records written before 2026-04-22 19:55 still contain double commas — replay/analytics consumers reading pre-fix history must apply substring/regex extraction for those records only. New capability work may assume clean JSON contract from current runtime TRADE records. | RESOLVED | PLAN-RC Stage P2.A FULLY_CLOSED (2026-04-22) |

---

## Three-Chain Architecture Guardrails

These rules apply specifically to the three primary computation chains (MarketRegimeSnapshot / gRegime-RegimeClassificationV1 / council zone) and their derivative network.

### Forbidden framing

- **No two-device framing.** Do not describe this system as having "two regime systems" or "dual-regime." Three primary chains are active. MarketRegimeSnapshot is a distinct chain upstream of council zone, not equivalent to gRegime.
- **No hard label-based invalidation.** `gRegime=COMPRESSION` does NOT invalidate council routing. `council_zone=COMPRESSION` does not override gRegime admission authority. Disagreement between gRegime and council zone is a measurement difference, not a conflict requiring resolution.
- **No bridge-for-control.** Never add logic of the form "if gRegime=X, override or restrict council zone routing." That pattern reproduces the CouncilDirtyEnvironmentGate violation (P4). Bridge is measurement-only.
- **No coherence/disagreement output on the decision path.** Do not add coherence scoring, disagreement signals, or cross-authority validation into the live decision path. ERA and ExRA operate at different layers and are not required to agree.

### Mandatory checks before any capability elevation

Before implementing any new surface that consumes regime state in council mode:
1. Declare whether the surface is ERA-governed or ExRA-governed. Undeclared cross-reads are forbidden.
2. If the surface involves AI advisory, advisory scope, or learning motifs — it must be ExRA-governed (council zone keyed). The current P3.1A+P3.1B bundle must be implemented before any new AI advisory or learning infrastructure is added in council mode.
3. If the surface involves admission, structural governance, failure classification, or analytics stratification — it is ERA-governed (gRegime keyed).
4. P2.A serialization defect RESOLVED (2026-04-22). Current TRADE records (post 2026-04-22 19:55) parse cleanly under strict json.loads() — new consumers built on current runtime records may assume a clean JSON contract. Historical TRADE records before 2026-04-22 19:55 still contain double commas before the provenance block — replay/analytics consumers reading pre-fix journal history must apply substring/regex extraction for those records only.
5. Capability elevation must not proceed on top of incorrect architecture assumptions. Confirm which chain is the correct authority for the new surface before implementation.

---

## PIML Usage Protocol

`PROJECT_INTELLIGENCE_MEMORY_LAYER.md` is the governed execution/intelligence memory for this project. These rules govern its use in execution missions.

### State Anchor Rule

The file contains a `## CURRENT STATE ANCHOR` block near the top (after Section 0). This is the **default entry point** for any mission asking about current status, next step, waiting condition, frozen boundaries, or active plan state.

- Read the `CURRENT STATE ANCHOR` first for these questions — not the full file
- Only escalate to deeper sections (Section 7.2, Section 2) if the anchor is insufficient
- After any execution that changes project truth at the anchor level, update the anchor immediately before closing the mission report

Anchor-level changes that require an immediate anchor update: compile result, observation window start/close, plan state change, waiting gate resolution, new deferred branch, milestone completion, next-step change.

### Selective-Read Rule

Read only the minimum needed:
- Active execution-plan entry for the current plan (Section 7.2)
- Relevant architecture subtree (Section 2) — only the specific node(s), not the whole tree
- Relevant functional/dependency area — only if directly needed
- Any specific section explicitly referenced by the mission brief

Do NOT read the whole file. If the mission has no use for the memory file, skip the read entirely.

### Auto-Update Rule

After every execution mission, ask: **Did this mission change any project truth that belongs in the memory file?**

**YES** → update the directly impacted section(s) immediately before closing the mission report.
**NO** → no update required. Do not create artificial memory work.

Truth changes that require a PIML update:
- Source file created or deleted → update Section 9 (File Index) references
- Subsystem materially evolved → update affected Section 2 (Architecture) node(s)
- Plan stage completed or plan status changed → update Section 7.2 entry immediately
- Plan closed → convert to Archival Summary Template, create linked .txt, move to Section 7.3
- New dependency or consumer relationship confirmed → update Section 4 (Dependency Map)

### Update Scope Rule

Update only the directly impacted section(s). Never sweep the whole file. Never redesign the file structure — only update data inside the existing structure.

---

## Backup Requirement (from AGENTS.md)

Before any modification to source files, a backup must be created at the external governed root:
`D:\MT5_Project_Backups\pre_change_<YYYYMMDD_HHMMSS>_<short_scope>.zip`

The backup destination must be external to the MQL5/terminal project tree. Do not create backup archives inside the terminal installation tree or any in-tree path.

Historical backups created under `terminal-root/backup_archives/` remain valid for rollback purposes. They are grandfathered as past artifacts and do not need to be moved. The external-path policy is forward-looking only.

Backup must cover both:
- `MQL5/Experts/AI`
- `MQL5/Files/AI`

Exclude `MQL5/Files/AI/ai_performance_journal.jsonl` (live-locked append-only runtime journal).

**PIML Backup Exception:** `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` and its linked archival `.txt` files (`plans/archive/`) are governed internal memory artifacts — not runtime, source, or execution authority files. Editing these files does not require a backup before edit. This exception is narrow and must not be generalised to any other project file. The duty to read, update, and keep PIML edits bounded and accurate is unaffected.

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

---

## No-Score Dormant Risk Hard-Lock (2026-04-30)

The following score-authority surfaces have been hard-locked at the source level as part of the No-Score V1 program. These gates were previously dormant (flag-default=false) but could be reactivated via plan JSON or EA input without recompile. They are now permanently non-executing until a deliberate source-code change, recompile, and No-Score compliance audit are performed.

### Hard-Locked Surfaces

| Surface | File | Lock Type | Former Activation Gate |
|---------|------|-----------|------------------------|
| `EvaluateCouncilDirtyEnvironmentTightening` | `main_ea.mq5` | `return;` after Init | EA input `EnableCouncilDirtyEnvironmentTightening` |
| `EvaluateTrendContinuationConfirmationReinforcement` | `council_mode_runtime.mqh` | `return false;` after Init | EA input `EnableCouncilTrendContinuationConfirmationReinforcement` |
| `RuntimePolicyAllowsTrade` — regime gate | `main_ea.mq5` | `return false;` commented out | plan `regime_policy_enabled` |
| `RuntimePolicyAllowsTrade` — DQ gate | `main_ea.mq5` | `return false;` commented out | plan `decision_quality_policy_enabled && strategy_intelligence_enabled` |
| `RegimeFilterAllows` — regime gate | `main_ea.mq5` | `return false;` commented out | plan `enable_regime_filter` |
| `RegimeFilterAllows` — DQ gate | `main_ea.mq5` | `return false;` commented out | plan `decision_quality_policy_enabled && strategy_intelligence_enabled` |
| `CooldownAllowsNewTrade` — DQ gate | `main_ea.mq5` | `return false;` commented out | plan `decision_quality_policy_enabled && strategy_intelligence_enabled` |
| `SessionAllowsNewTrade` — DQ gate | `main_ea.mq5` | `return false;` commented out | plan `decision_quality_policy_enabled && strategy_intelligence_enabled` |
| `CapacityAllowsNewTrade` — DQ gate | `main_ea.mq5` | `return false;` commented out | plan `decision_quality_policy_enabled && strategy_intelligence_enabled` |

### Governance Rule

**Score-authority gates that were dormant under the No-Score V1 program must not be re-enabled by changing plan JSON, EA inputs, or any runtime configuration.** Reactivation of any hard-locked gate requires:
1. Source code review confirming No-Score V1 compliance of the gate
2. Code change to remove the hard-lock `return` or uncomment the `return false;` lines
3. Recompile and binary update
4. No-Score V1 closure audit to confirm compliance

Compile baseline: `compile_no_score_dormant_risk_hard_lock_20260430_120651.log` — 0 errors, 2 warnings (pre-existing warning 94 lines 14340/14839).

---

## PIML Authority / No Duplicate Phase State (2026-04-30)

`PROJECT_INTELLIGENCE_MEMORY_LAYER.md` is the sole official project phase and status memory for this system.

### Rules

- PIML is the single source of truth for all project phase state, program stage status, milestone status, and next-step state.
- Claude memory files (`.claude/projects/.../memory/`) must not maintain independent stage-status ledgers or duplicate phase-state claims.
- Claude memory may only contain non-authoritative pointers to PIML, plus feedback and reference content that is not phase-state (e.g., work-mode discipline, schema field mappings).
- Any phase or status update must be written to PIML only — not to Claude memory as a parallel ledger.
- If Claude memory content conflicts with PIML, PIML wins. The Claude memory entry is the stale one.
- Runtime journal (`ai_performance_journal.jsonl`) wins for runtime-evidence facts.
- Operational governance truth resides in `OPERATION_GUARDRAILS.md` and `AGENTS.md`.

### Governance Correction Record

On 2026-04-30, Claude memory files `project_phase_state.md` and `project_no_score_audit.md` were identified as maintaining independent phase-state ledgers duplicating PIML content. Both files were quarantined to pointer-only. No trading source changes were made. PIML remains the sole authoritative phase/status source.
