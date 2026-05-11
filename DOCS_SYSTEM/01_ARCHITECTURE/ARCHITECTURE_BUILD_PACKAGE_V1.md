# ARCHITECTURE_BUILD_PACKAGE_V1

**Package type:** ARCHITECTURE_BUILD — Documentation and specification only
**Date:** 2026-05-08
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No Nautilus change.
**Based on:** PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md + PROJECT_INTELLIGENCE_MEMORY_LAYER.md
**System status:** DEVELOPING — unchanged
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred to any document or layer

---

## 1. Executive Summary

The registry foundation is complete. All 17 council strategies and all 3 active playbooks are registered under PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1 (PCEA). The packet inventory is current as of 2026-05-08.

**The next work is architecture consolidation, not more micro-testing.**

The registry revealed that the system has one formally accepted packet (MSR FAILURE_MODE_PACKET for LHR E[R] degradation) and zero accepted playbook confirmation chains. This is the correct starting point for build-out: evidence is sparse, honest, and properly labeled. The absence of accepted packets is not a failure — it is an accurate reflection of the evidence state, and it tells us precisely what must be built before any runtime-facing implementation is warranted.

This package converts the registry into a build-plan structure:

- Five large work packages replace a proliferation of micro-tasks.
- The Opportunity Ledger alignment specification defines future observation fields without touching any runtime file.
- The Event Order Contract prevents late evidence from being counted against earlier decisions.
- Shadow playbook state observation is specified as a future Codex task candidate — but is not implemented here.
- Design review criteria are defined so that future runtime-facing work has measurable entry conditions.

**No runtime authority is granted by this package.** Nothing in this document modifies MT5 behavior, changes any weight or gate, or creates any execution permission. The entire package is documentation, specification, and build-plan structure.

---

## 2. Current Architecture Assets

### 2.1 Documentation Layer

| Asset | Location | Status |
|---|---|---|
| PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) | MQL5/Experts/AI/ | AUTHORITATIVE — sole governed project memory |
| PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md | MQL5/Experts/AI/ | COMPLETE — 17/17 strategies; 3/3 playbooks |
| ARCHITECTURE_BUILD_PACKAGE_V1.md | MQL5/Experts/AI/ | THIS DOCUMENT |
| AGENTS.md | MQL5/Experts/AI/ | Active |
| OPERATION_GUARDRAILS.md | MQL5/Experts/AI/ | Active |

### 2.2 PIML Architecture Sections (key references)

| Section | Content | Status |
|---|---|---|
| §16 | IRREW architecture design + 8-phase roadmap | DESIGN_COMPLETE |
| §19–21 | trend_momentum Nautilus cert (Phase 3, cert 1) | COMPLETE |
| §22 | TPC cert + Packet Semantics + Phase 4A discipline | COMPLETE |
| §23 | Phase 4A Redesign — Option F selected | DESIGN_COMPLETE |
| §24 | bollinger_reclaim + sweep_reversal XAUUSD certs | COMPLETE |
| §25 | PCEA V1 formal adoption | COMPLETE |
| §26 | breakdown_momentum_v1 cert | COMPLETE |
| §27 | lower_high_rejection_v1 cert | COMPLETE |
| §28 | micro_structure_reentry_v1 cert | COMPLETE |
| §29 | range_edge_fade cert + H1 falsification | COMPLETE |
| REG.1–REG.9 | Playbook Governance and Registry Rules | COMPLETE |

### 2.3 Runtime Layer

| Component | Location | Status |
|---|---|---|
| main_ea.mq5 | MQL5/Experts/AI/ | RUNTIME_AUTHORITY — not modified by this package |
| council_strategies.mqh | MQL5/Experts/AI/ | Phase 5A gate applied; runtime validation pending |
| council_mode_runtime.mqh | MQL5/Experts/AI/ | Active |
| council_pre_ai_filter.mqh | MQL5/Experts/AI/ | Active |
| council_aggregator.mqh | MQL5/Experts/AI/ | Active |
| ai_opportunity_ledger.jsonl | MQL5/Files/AI/ | ACTIVE — Phase 2 live; below 200-record threshold |
| ai_opportunity_summary.json | MQL5/Files/AI/ | ACTIVE |
| ai_strategy_memory.json | MQL5/Files/AI/ | ACTIVE |
| ai_performance_journal.jsonl | MQL5/Files/AI/ | ACTIVE |

### 2.4 Evidence Layer (Nautilus)

| Strategy | Cert Date | Cert Label | Phase 3 Count |
|---|---|---|---|
| bollinger_reclaim | 2026-05-08 | EDGE_WEAK_BUT_RECOVERABLE | 1 |
| trend_pullback_cont_v1 | 2026-05-07 | EDGE_SUPPORTED (standalone; sparse) | 2 |
| sweep_reversal | 2026-05-08 | EDGE_WEAK_BUT_RECOVERABLE | 3 |
| trend_momentum | 2026-05-07 | EDGE_WEAK_BUT_RECOVERABLE | 4 |
| breakdown_momentum_v1 | 2026-05-08 | EDGE_WEAK_BUT_RECOVERABLE / NOT_CONFIRMED (TC) | 5 |
| lower_high_rejection_v1 | 2026-05-08 | EDGE_WEAK_BUT_RECOVERABLE | 6 |
| micro_structure_reentry_v1 | 2026-05-08 | EDGE_WEAK_BUT_RECOVERABLE (SELL) / NOT_CONFIRMED (BUY) | 7 |
| range_edge_fade | 2026-05-08 | EDGE_WEAK_BUT_RECOVERABLE | 7/17 |
| momentum_breakout_cont_v1 | LIVE (no Nautilus) | EDGE_REJECTED (live 9.1% WR) | FROZEN |

**Uncertified (Phase 3 not run):** mfi_reversal_assist, mean_reversion_bounce, fake_break_reversal, range_compression_breakout, volatility_squeeze_release, volatility_breakout, expansion_continuation, micro_range_expansion — all DATA_INSUFFICIENT, 0 live closed outcomes.

### 2.5 Packet Inventory (system total)

| Status | Count | Detail |
|---|---|---|
| Formally ACCEPTED | 1 | MSR FAILURE_MODE_PACKET for LHR E[R] degradation (−0.068R ≥ threshold −0.06R; N=4,268) |
| Research designation | 1 | TPC CONFIRM_PACKET_SPARSE — EDGE_SUPPORTED but structural sparsity (1.4% TM co-presence) |
| RESEARCH_ONLY (per cert) | Multiple | counter-trend sweeps, BUY×TD, LHR TC proxy, SELL×TREND_UP (MSR), REF LATE period — all below formal thresholds |
| Formally REJECTED | Many | Zone proxy gates, ubiquitous co-presence, quality flag inversions — per-strategy details in registry |
| DATA_INSUFFICIENT | 9 strategies | All uncertified strategies; 0 live closed outcomes |

### 2.6 Playbook Inventory

| Playbook | State | Accepted Chain Packets | Reason Not VALID |
|---|---|---|---|
| RBSR (Range Boundary Sweep Reversal) | PLAYBOOK_FORMING | 0 | No CONFIRMATION_PACKET; SR/BR co-presence ubiquitous (88–94%); no WR lift from chain co-presence |
| TPC (Trend Pullback Continuation) | PLAYBOOK_FORMING | 0 formal | CONFIRM_PACKET_SPARSE (TPC) is research designation only; mandatory gate would cause 98.6% TC starvation |
| VCR (Volatility Compression Release) | PLAYBOOK_NOT_PRESENT | 0 | Zero evidence at any level; 0 live entries across all 5 VCR strategies |

### 2.7 Phase Gate Status

| Phase | Status | Blocker |
|---|---|---|
| Phase 2 (Opportunity Ledger) | ACTIVE — immature | Below 200-record threshold |
| Phase 3 (Nautilus certs) | IN_PROGRESS — 7/17 | 10 strategies uncertified; VCR family not started |
| Phase 4A (Cross-family CRR) | BLOCKED | Architectural decision required; TPC sparsity is structural |
| Phase 4B (Exhaustion veto) | BLOCKED | mfi_reversal_assist 0 live entries |
| Phase 4C (Quality soft gate) | BLOCKED | Opportunity Ledger below 200-record threshold |
| Phase 5A | APPLIED / NAUTILUS_CHALLENGED | Runtime validation pending |
| Phase 5B+ | NOT_AUTHORIZED | Requires Phase 3 certs per strategy |
| Phase 6 (EEWP weights) | DESIGN_ONLY | Blocked on Phase 2 + Phase 3 (≥8 certs) + Phase 4 runtime |

---

## 3. What We Are Building

The target architecture is a **non-runtime staged evidence model**. Each layer must be built in order. No layer grants runtime execution authority. V1 (the MT5 EA) is the sole permission authority and remains so permanently.

```
Layer 0 — Registry Layer                           [COMPLETE]
│
│  PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md
│  All 17 strategies, 3 playbooks, packet inventory
│  Governance Firewall GF-1 through GF-12
│
▼
Layer 1 — Attribution / Ledger Alignment Layer     [SPECIFICATION_REQUIRED]
│
│  Future Opportunity Ledger fields for playbook / packet observation
│  Event Order Contract (evidence must precede decision)
│  Timestamp fields proving causal ordering
│  No ledger code change authorized yet
│
▼
Layer 2 — Shadow Playbook State Layer              [FUTURE_CODEX_TASK_REQUIRED]
│
│  Shadow observation: emit categorical playbook state per bar
│  No decision impact, no score, no gate, no weight
│  Pure attribution data: "what playbook state was active when this decision fired?"
│  Requires ledger alignment fields (Layer 1) as prerequisite
│
▼
Layer 3 — Design Review Layer                      [FUTURE_REVIEW_REQUIRED]
│
│  Minimum evidence thresholds before any runtime-facing proposal
│  No-score / no-gate audit checklist
│  Rollback criteria per proposed change
│  Production readiness exclusion rules
│  Operator review and authorization gate
│
▼
Layer 4 — Future Bounded Codex Implementation Layer  [IF_AND_ONLY_IF_AUTHORIZED]

   Only reachable after all of the following:
   - Layer 1 specification approved and implemented
   - Layer 2 accumulating data with ≥200 records
   - Layer 3 review criteria met for the specific proposed change
   - Explicit operator authorization for a bounded Codex task
   - One file, one change, per task
```

**This package builds Layer 0's consolidation artifacts and specifies Layers 1–3.** It does not build Layer 4. No runtime behavior is modified at any layer in this package.

**Clarification on scope:** The current package creates the map and the specifications. Future layers are specified here but not implemented. Every transition from one layer to the next requires a new operator decision. This document cannot authorize that transition — it can only prepare the specifications so the decision can be made with full information.

---

## 4. Large Work Packages

### Package A — Registry Consolidation Package

**Purpose:** Establish PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md as the single canonical reference for all strategy/playbook evidence state. Eliminate fragmented per-task evidence tracking.

**Deliverables:**

| Deliverable | Status | Location |
|---|---|---|
| Strategy packet map (all 17 × cert label × best subset × accepted packets) | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §5 |
| Playbook map (3 playbooks × state × chain links × accepted packets) | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §4 |
| Accepted/rejected/research/pending packet inventory | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §7–8 |
| Missing evidence inventory by strategy | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §9 |
| Governance Firewall (GF-1 through GF-12) | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §2 |
| Packet taxonomy (13 types, acceptance/rejection rules) | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §3 |
| Forbidden conclusions list | COMPLETE | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md §11 |
| No-runtime firewall declaration | COMPLETE | Registry footer |

**Status:** COMPLETE (registry created 2026-05-08)

**Remaining gap:** breakdown_momentum_v1 cert has several fields listed as SOURCE_READ_REQUIRED in the master table (Variant A exact metrics). These are documentation gaps only — they do not affect the cert label (EDGE_WEAK_BUT_RECOVERABLE aggregate / NOT_CONFIRMED TC proxy) or the playbook assignment (NONE). Fill-in required before using BDM cert data for any evidence chain decisions; no action needed now.

**Package A does not require any further Nautilus tests or source reads to be usable.** The registry is operational as-is. Fill-in of SOURCE_READ_REQUIRED fields is a maintenance task, not a blocking condition.

---

### Package B — Ledger Alignment Specification Package

**Purpose:** Define the future Opportunity Ledger fields required to observe packet presence and playbook state per-decision bar. This specification enables Layer 2 (shadow observation) without touching any runtime file now.

**Background:** The current Opportunity Ledger (`ai_opportunity_ledger.jsonl`) captures trigger-level evidence per strategy. It does not currently capture:
- Which playbook context was active at the time of decision
- Whether a causal chain link was present (vs. absent)
- Whether evidence was available before the decision (vs. evaluated after)
- What playbook state the system was in when the decision fired

**Deliverables:**

| Deliverable | Status |
|---|---|
| Packet presence fields (per strategy, per bar) | SPECIFICATION_COMPLETE (§5) |
| Causal link fields (which chain links were satisfied) | SPECIFICATION_COMPLETE (§5) |
| Event timestamp fields (proving ordering) | SPECIFICATION_COMPLETE (§5) |
| Playbook state fields (categorical only) | SPECIFICATION_COMPLETE (§5) |
| Missing/contradicted link fields | SPECIFICATION_COMPLETE (§5) |
| Late evidence flags | SPECIFICATION_COMPLETE (§5) |
| Pre-decision availability flags | SPECIFICATION_COMPLETE (§5) |
| Outcome attribution fields | SPECIFICATION_COMPLETE (§5) |
| Ledger schema version control | SPECIFICATION_REQUIRED — designate V1B schema vs future V1C |

**Status:** SPECIFICATION_COMPLETE in §5 of this document. Implementation requires a future Codex task (OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 — listed in §11). No ledger code change is authorized here.

**Dependency:** This package is prerequisite for Package D (Shadow Observation). Package D cannot begin until ledger fields from Package B are live and accumulating data.

---

### Package C — Event Order Contract Package

**Purpose:** Define and formalize the required ordering of evidence events so that future shadow observation never counts late evidence as valid confirmation. This is a specification deliverable, not a runtime change.

**Core problem being solved:** Without a formal event order contract, it is possible (in future shadow or runtime implementation) to evaluate a confirmation packet *after* the trade decision was made and retroactively classify the decision as "confirmed." This would produce false positive signal quality assessments. The Event Order Contract prevents this.

**Deliverables:**

| Deliverable | Status |
|---|---|
| Context timing rule (zone/regime must be established before any signal) | SPECIFICATION_COMPLETE (§6) |
| Location timing rule (zone position must be known before trigger evaluates) | SPECIFICATION_COMPLETE (§6) |
| Trigger timing rule (trigger fires only after context + location confirmed) | SPECIFICATION_COMPLETE (§6) |
| Confirmation timing rule (confirmation signal must exist before decision) | SPECIFICATION_COMPLETE (§6) |
| Failure-mode timing rule (failure mode evaluated contemporaneously with decision) | SPECIFICATION_COMPLETE (§6) |
| Room/stop geometry timing rule (stop and TP must be calculable before execution) | SPECIFICATION_COMPLETE (§6) |
| Playbook state emission rule (playbook state assembled from pre-decision evidence only) | SPECIFICATION_COMPLETE (§6) |
| Late-evidence rejection rule (evidence discovered after decision cannot validate it) | SPECIFICATION_COMPLETE (§6) |

**Status:** SPECIFICATION_COMPLETE in §6. This contract becomes enforceable when ledger fields (Package B) are live. No implementation now.

---

### Package D — Shadow Observation Package

**Purpose:** Define the future observation-only playbook and packet state recording system. Shadow observation records what playbook state was active at each decision point without influencing any decision, score, gate, or weight.

**What shadow observation is:**
- A read-only attribution recording layer
- Emits categorical playbook state (PLAYBOOK_NOT_PRESENT / PLAYBOOK_FORMING / PLAYBOOK_VALID / etc.) per bar
- Records which chain links were present, absent, or contradicted
- Records whether failure-mode signals were active
- All records are post-decision or contemporaneous — never pre-decision inputs to any gate

**What shadow observation is NOT:**
- Not a score
- Not a gate
- Not a weight modifier
- Not a confirmation requirement for execution
- Not a quality modifier for council_quality
- Not a HIGH_CONVICTION requirement
- Not a CRR/DSN gate input
- Not a playbook completion percentage

**Deliverables:**

| Deliverable | Status |
|---|---|
| Shadow packet state emitter spec | FUTURE_CODEX_TASK_REQUIRED |
| Shadow playbook state emitter spec | FUTURE_CODEX_TASK_REQUIRED |
| No-decision-impact verification criteria | SPECIFICATION_COMPLETE (§7) |
| Validation output format | FUTURE_CODEX_TASK_REQUIRED |
| Rollback procedure if shadow data corrupts ledger | FUTURE_REVIEW_REQUIRED |

**Status:** FUTURE_CODEX_TASK_REQUIRED. Not authorized here. Prerequisite: Package B ledger fields live and accumulating ≥50 records.

**Key constraint:** Shadow observation must be implemented in strict isolation from the decision pipeline. Any code path that reads shadow state before or during a decision violates the isolation contract. The implementation must be verified to have zero runtime effect before deployment. This verification is a Package E (Design Review) responsibility.

---

### Package E — Design Review / Readiness Package

**Purpose:** Define the review criteria that must be met before any runtime-facing implementation is proposed or authorized. Package E is the gate between the evidence/observation work (Packages A–D) and any future runtime change.

**Background:** The IRREW phases (§16 PIML) provide an 8-phase roadmap. Package E specifies what "phase clearance" actually means at the evidence level. Each phase should have measurable entry criteria, not just a checklist of prior phase completion.

**Deliverables:**

| Deliverable | Status |
|---|---|
| Minimum evidence thresholds per phase (tabulated below) | SPECIFICATION_COMPLETE |
| Sample size requirements per proposed runtime change | SPECIFICATION_COMPLETE |
| Ledger alignment success criteria (what counts as "sufficient ledger evidence") | SPECIFICATION_COMPLETE |
| No-score / no-gate audit checklist (verify shadow doesn't leak into decision) | FUTURE_REVIEW_REQUIRED |
| Rollback criteria per proposed change type | SPECIFICATION_COMPLETE |
| Production readiness exclusion rules | SPECIFICATION_COMPLETE |

**Evidence thresholds before any runtime implementation:**

| Phase | Minimum Evidence Required Before Starting |
|---|---|
| Phase 4A (cross-family CRR redesign) | Operator selects architectural path (Option F or alternative); ≥50 ledger records with cross-family confirm fields active |
| Phase 4B (exhaustion veto) | mfi_reversal_assist ≥5 live signal-strength readings; veto threshold calibrated from observed distribution; ≥50 ledger records capturing exhaustion_signal_strength field |
| Phase 4C (quality soft gate) | Opportunity Ledger ≥200 trigger_present=true records; FSW audit complete; ≥50 ledger records in NARROW consensus conditions analyzed for suppression quality |
| Phase 5B+ (strategy restriction gates) | Nautilus Phase 3 cert for the specific strategy; E[R] degradation ≥−0.06R in hostile condition with N≥50; degradation confirmed across ≥2 time windows; operator authorization issued |
| Phase 6 (EEWP weights) | Phase 2 live (≥200 records); Phase 3 ≥8 strategies certified (currently 7); Phase 4 at least one sub-task complete with ≥50 post-change decisions; operator explicitly authorizes per-strategy weight change |

**Rollback criteria:**

| Change Type | Rollback Trigger |
|---|---|
| Any strategy gate | Live WR drops below pre-gate level by >3pp over 50 trades following gate activation |
| Any weight change | Live WR deviates from Nautilus cert WR by >5pp over 30 post-change trades |
| Shadow ledger fields | Any detected influence on decision pipeline (even statistical); immediate revert |
| Phase 4A CRR change | TC execution rate drops below 50% of pre-change rate over 30 decisions |
| Phase 4C quality gate | Win rate of suppressed trades (from ledger) > win rate of executed trades; gate is suppressing quality, not noise |

**Production readiness exclusion rules (all must be true for status upgrade from DEVELOPING):**
1. All 17 Phase 3 certifications complete (currently 7/17)
2. IRREW Phase 4 live and runtime-validated with ≥200 decisions
3. Opportunity Ledger live with ≥200 records and FSW audit complete
4. System WR ≥ 42% stable for 60 consecutive calendar days under IRREW
5. Phase 6 EEWP calibrated and validated with ≥50 post-adjustment decisions per strategy changed
6. No active rollback triggers pending
7. Explicit operator authorization to upgrade status

**Status:** SPECIFICATION_COMPLETE for evidence thresholds, rollback criteria, and exclusion rules. No-score/no-gate audit checklist is FUTURE_REVIEW_REQUIRED — cannot be written until shadow implementation candidate exists.

---

## 5. Opportunity Ledger Alignment Specification

This section defines the future ledger fields required for playbook and packet observation. **No ledger code change is authorized here.** This is a specification for a future Codex task (OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 — see §11).

All fields below are additions to the existing ledger record schema. Existing fields remain unchanged.

### 5.1 Playbook Identification Fields

| Field | Type | Description | When populated |
|---|---|---|---|
| playbook_id | string | Primary playbook active at decision bar | Pre-decision (zone + context) |
| playbook_state | string | Categorical: PLAYBOOK_NOT_PRESENT / PLAYBOOK_FORMING / PLAYBOOK_VALID / PLAYBOOK_CONTRADICTED / PLAYBOOK_LATE / PLAYBOOK_INVALID | Pre-decision (assembled from chain link fields) |
| playbook_state_basis | string | Which chain links drove the state classification | Pre-decision |
| secondary_playbook_id | string | Secondary playbook if applicable (e.g., both RBSR and TPC signals present) | Pre-decision |

### 5.2 Packet Presence Fields

| Field | Type | Description | When populated |
|---|---|---|---|
| packet_alpha_present | bool | ALPHA_TRIGGER packet fires for primary strategy | Pre-decision |
| packet_alpha_strategy_id | string | Which strategy provided the alpha trigger | Pre-decision |
| packet_alpha_direction | string | BUY / SELL / NONE | Pre-decision |
| packet_location_present | bool | LOCATION_PACKET fires (zone or context quality filter active) | Pre-decision |
| packet_location_gate_passed | bool | Strategy passes its location gate | Pre-decision |
| packet_confirm_present | bool | CONFIRMATION_PACKET fires (cross-signal confirmation) | Pre-decision |
| packet_confirm_strategy_id | string | Which strategy provided confirmation | Pre-decision |
| packet_confirm_cross_family | bool | True if confirmation is from a different family than alpha | Pre-decision |
| packet_failure_mode_present | bool | Any FAILURE_MODE_PACKET condition is active | Pre-decision |
| packet_failure_mode_type | string | Which failure mode triggered (e.g., MSR_LHR_COPRESENCE, REGIME_INVERSION) | Pre-decision |
| packet_quality_discriminant | string | POSITIVE / NEGATIVE / INVERTED / NOT_EVALUATED | Pre-decision |
| packet_timing_flag | string | EARLY_PERIOD / LATE_PERIOD / WITHIN_NORMAL / NOT_EVALUATED | Pre-decision |
| packet_regime_flag | string | BEST_REGIME / NEUTRAL_REGIME / HOSTILE_REGIME per strategy cert | Pre-decision |
| packet_direction_flag | string | BEST_DIRECTION / WEAK_DIRECTION per strategy cert | Pre-decision |

### 5.3 Causal Chain Link Fields

| Field | Type | Description |
|---|---|---|
| completed_links | string[] | Array of chain links satisfied (e.g., ["ALPHA_TRIGGER","LOCATION"]) |
| missing_links | string[] | Chain links not satisfied at decision time |
| contradicted_links | string[] | Chain links with evidence contradicting the playbook thesis |
| chain_completeness_score | int | Count of completed_links / total expected chain links (0–N, NOT a percentage score, NOT used for decisions) |

**Note on chain_completeness_score:** This is an integer count for attribution analysis only. It must not be used as a threshold, a gate condition, a council_quality input, or any form of execution modifier. Recording a count does not authorize using it.

### 5.4 Event Timestamp Fields

| Field | Type | Description |
|---|---|---|
| context_timestamp | ISO8601 | When zone / regime context was established for this bar |
| location_timestamp | ISO8601 | When zone position / location gate evaluated |
| trigger_timestamp | ISO8601 | When the primary alpha trigger fired |
| confirm_timestamp | ISO8601 | When confirmation signal evaluated (null if absent) |
| failure_mode_timestamp | ISO8601 | When failure mode signal evaluated (null if absent) |
| room_timestamp | ISO8601 | When room-to-target was calculated |
| stop_geometry_timestamp | ISO8601 | When stop loss level was calculated |
| playbook_state_timestamp | ISO8601 | When playbook state was assembled |
| pre_decision_available | bool | True if playbook_state was assembled before execution decision |
| late_evidence | bool | True if any packet evidence post-dates the decision timestamp |

### 5.5 Outcome Attribution Fields

| Field | Type | Description |
|---|---|---|
| final_decision | string | REJECT / WAIT / BUY / SELL |
| outcome | string | WIN / LOSS / OPEN / SUPPRESSED |
| outcome_r | float | Realized R multiple (null if OPEN/SUPPRESSED) |
| attribution_note | string | Human-readable note on which packets contributed to decision quality assessment |
| playbook_correct_prediction | bool | Whether the playbook state at decision time predicted the outcome correctly (for future calibration; not a gate) |
| post_decision_playbook_state | string | Playbook state evaluated after the outcome is known (for comparison to pre-decision state) |

### 5.6 Schema Version and Write Contract

| Constraint | Value |
|---|---|
| Write trigger | trigger_present = true (unchanged from V1B schema) |
| Schema version field | `ledger_schema_version: "V1C_PLAYBOOK"` (future designation) |
| Backward compatibility | All V1B fields preserved; new fields added as optional (null-safe) |
| Null policy | If a packet was not evaluated, set the presence field to false and the strategy_id field to "" |
| No runtime authority | These fields record observations. No field here may be read by the decision pipeline. |

**Implementation status: NOT_AUTHORIZED HERE.** Ledger schema change requires OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 Codex task (§11) with bounded scope, compile verification, and 30-decision validation window.

---

## 6. Event Order Contract

The Event Order Contract defines the required ordering for all evidence events within a single decision bar. This contract is the specification that the future shadow observation implementation (Package D) must enforce. It cannot be violated in any future ledger or runtime implementation.

### 6.1 Required Event Sequence

```
Step 1 — CONTEXT
  Zone is determined (TREND_CONTINUATION, RANGE_MEAN_RECLAIM, REV, BREAKOUT_EXPANSION, etc.)
  Regime label is determined (TREND_UP, TREND_DOWN, RANGE_NEUTRAL)
  Era label is determined
  Council environment report is complete
  Timestamp: context_timestamp
  ──────────────────────────────────────────────────────
  GATE: Nothing below this line may evaluate until Step 1 is complete.

Step 2 — LOCATION
  Zone position (where in the zone structure is price?)
  Range boundary proximity (is price near a playbook-relevant location?)
  LOCATION_PACKET evaluated: does this bar satisfy a location gate?
  Timestamp: location_timestamp
  ──────────────────────────────────────────────────────
  GATE: No trigger may fire until Step 2 is complete.

Step 3 — TRIGGER
  Primary alpha trigger evaluates (e.g., sweep_reversal, trend_momentum)
  Trigger fires or does not fire
  Direction determined: BUY / SELL / NONE
  Timestamp: trigger_timestamp
  ──────────────────────────────────────────────────────
  GATE: No confirmation or failure mode may evaluate until Step 3 fires.

Step 4 — CONFIRMATION / CONTRADICTION
  CONFIRMATION_PACKET strategy evaluates (e.g., TPC within same bar window)
  FAILURE_MODE_PACKET strategy evaluates (e.g., MSR co-presence check for LHR)
  Results: confirm_present=T/F, failure_mode_present=T/F
  Timestamps: confirm_timestamp, failure_mode_timestamp
  ──────────────────────────────────────────────────────
  GATE: Confirmation must be contemporaneous or pre-trigger. Post-trigger confirmation
        does not satisfy this step for a pre-decision packet evaluation.

Step 5 — ROOM AND STOP GEOMETRY
  Room to target calculated: distance to TP given zone structure
  Stop loss level calculated: ATR14(Wilder,M1,shift=1) × 1.20
  RR computed
  Timestamp: room_timestamp, stop_geometry_timestamp
  ──────────────────────────────────────────────────────
  GATE: No execution may proceed without room and stop geometry confirmed.

Step 6 — PLAYBOOK STATE ASSEMBLY
  Completed/missing/contradicted chain links counted
  Playbook state label assigned from categorical rules only:
    PLAYBOOK_NOT_PRESENT — anchor strategy not firing
    PLAYBOOK_FORMING — anchor present but confirmation absent/insufficient
    PLAYBOOK_VALID — anchor + confirmation satisfied; no failure mode
    PLAYBOOK_CONTRADICTED — failure mode overrides confirmation
    PLAYBOOK_LATE — improvement observed only in late period (temporal flag)
    PLAYBOOK_INVALID — chain logic is structurally impossible in this context
  Timestamp: playbook_state_timestamp
  pre_decision_available = True
  ──────────────────────────────────────────────────────
  GATE: Playbook state must be assembled BEFORE it is written to ledger.
        It must NEVER be written to any field that the decision pipeline reads.

Step 7 — V1 DECISION (runtime authority — not influenced by playbook state)
  council_pre_ai_filter evaluates DSN, CRR, DOMINANT_SIDE
  council_ai_governor evaluates threshold adjustments (advisory only)
  Final decision: REJECT / WAIT / BUY / SELL
  ──────────────────────────────────────────────────────
  ISOLATION REQUIREMENT: V1 decision pipeline has NO read dependency on
  Steps 1–6 except via existing published fields (env, agg, gov).
  Playbook state fields are NOT passed to V1 decision layers.
  Shadow fields are written AFTER V1 decision or to a completely separate
  ledger path that V1 cannot read.

Step 8 — ATTRIBUTION
  Ledger record written with all fields from Steps 1–7
  post_decision_playbook_state recorded (for calibration analysis, not gates)
  Outcome recorded when trade closes (WIN/LOSS/OPEN)
  playbook_correct_prediction populated post-outcome
```

### 6.2 Hard Rules

| Rule | Statement |
|---|---|
| EOC-1 | Late evidence cannot validate an earlier trade. If a confirmation signal fires after the decision bar, it does not count as pre-decision confirmation. |
| EOC-2 | Playbook state assembled in Step 6 must be computed entirely from Steps 1–5. No post-decision evidence may contribute to a pre-decision playbook state label. |
| EOC-3 | The V1 decision pipeline (Step 7) must have zero read dependency on playbook state fields. Verified by code inspection before any shadow implementation is deployed. |
| EOC-4 | Timestamps must be captured at the actual event evaluation time, not reconstructed from trade entry or outcome data. |
| EOC-5 | If any event in the sequence cannot be timestamped reliably, the pre_decision_available field must be set to False and late_evidence must be set to True. This prevents retroactive validation. |
| EOC-6 | The Event Order Contract must be enforced in code review of any future Codex task that touches ledger write logic. A task that writes playbook fields without enforcing this order must be blocked. |

---

## 7. Playbook State Interface — Future Concept Only

This section defines a clean future interface between the playbook observation layer (Layer 2) and any future V1 consumption (Layer 4 — if and only if authorized after extensive evidence accumulation).

**Current status: FUTURE_CONCEPT_ONLY. No runtime consumption is authorized now. No runtime consumption will be authorized from this document alone.**

### 7.1 Interface Fields

If a future authorized design allows V1 to consume playbook state, it must consume only the following abstracted fields — never raw strategy votes, never packet presence booleans directly, never chain completeness counts.

| Field | Type | Description |
|---|---|---|
| playbook_id | string | Which playbook is active |
| playbook_state | string (categorical) | PLAYBOOK_NOT_PRESENT / PLAYBOOK_FORMING / PLAYBOOK_VALID / PLAYBOOK_CONTRADICTED / PLAYBOOK_LATE / PLAYBOOK_INVALID |
| missing_link | bool | True if at least one required chain link is absent |
| contradicted_link | bool | True if at least one chain link has contradicting evidence |
| failure_mode_present | bool | True if a formally accepted FAILURE_MODE_PACKET is active |
| execution_geometry_state | string | FAVORABLE / MARGINAL / UNFAVORABLE (room + stop assessment) |
| pre_decision_available | bool | True if playbook_state was assembled before the V1 decision |
| late_evidence | bool | True if any packet evidence is post-decision |

### 7.2 What Future V1 Consumption Must NOT Do

If playbook state is ever authorized for V1 consumption, the following constraints are permanently binding:

| Constraint | Reason |
|---|---|
| Must not add playbook_state to council_quality formula | council_quality is an Allocation layer signal; playbook state is a Thesis layer signal; layer leakage prohibited |
| Must not make PLAYBOOK_VALID a requirement for execution | Starvation risk; current playbook states are FORMING or NOT_PRESENT — mandatory gate would halt the system |
| Must not score playbook states numerically | Categorical labels are the only authorized form; numerical scores create hidden threshold dependencies |
| Must not let playbook_state override DSN / CRR gates | DSN and CRR are Risk layer (Layer 2) gates; playbook state is Thesis layer (Layer 1); a Thesis signal cannot override a Risk gate |
| Must not allow playbook completion percentage | "60% complete" creates pressure to promote packets to reach a threshold; packet evidence is binary (accepted / research-only / rejected) |
| Must not implement before ≥200 shadow records with playbook state populated | The calibration baseline must exist before consumption is designed |

### 7.3 Design Philosophy

The clean interface exists for one reason: V1 currently consumes raw strategy vote weights and family diversity scores as a proxy for thesis quality. This is an architectural debt — the system has no way to distinguish "8 strategies voted BUY in the same family (same-family cluster)" from "8 strategies voted BUY across 4 independent evidence families (genuine convergence)." Playbook state, if ever authorized as a V1 input, should replace this proxy with a cleaner signal: is there a structured causal chain active, or is the system just executing because votes accumulated?

This philosophy must not be implemented until the shadow observation layer has demonstrated that playbook states are stable, predictive, and pre-decision available across ≥200 bars.

---

## 8. Packet Admission and Rejection Rules

This section consolidates the admission rules from the registry into the architectural reference format. These rules apply to all current and future packet claims.

### 8.1 Packet Status Taxonomy

| Status | Definition | Runtime Authority |
|---|---|---|
| ACCEPTED_PACKET | Measured evidence contribution meets formal threshold (per type); N sufficient; mechanically plausible | NONE — evidence label only |
| REJECTED_PACKET | Acceptance rule explicitly violated in correct direction; OR co-presence ubiquitous without lift; OR gate degrades outcomes | NONE — rejection label only |
| RESEARCH_ONLY_PACKET | Positive signal exists but formal thresholds not fully met; N < 50 for specific condition; or single isolated condition | NONE — bounded hypothesis only; no gate; no weight |
| PENDING_CERTIFICATION_PACKET | Strategy not yet run through Nautilus Phase 3; evidence collection not started | NONE |
| DATA_INSUFFICIENT_PACKET | Sample N < 30 in relevant subset; or < 14 calendar days; or 0 live closed outcomes | NONE |
| PARKED_PACKET | No current playbook need; hypothesis not blocked, just deprioritized | NONE — revisit when playbook need identified |
| CONFIRM_PACKET_SPARSE | Special research designation for TPC: EDGE_SUPPORTED standalone but structural sparsity (1.4% TM co-presence) prevents mandatory gate | NONE — research designation only |

### 8.2 Admission Thresholds by Packet Type

| Packet Type | WR Threshold | E[R] Threshold | N Threshold | Additional |
|---|---|---|---|---|
| ALPHA_TRIGGER | ≥ 40% | > 0 | ≥ 50 | Mechanically plausible regime/direction |
| LOCATION | Lift ≥ +2pp vs baseline | Lift ≥ +0.04R OR WR met alone | ≥ 50 gated | Either criterion sufficient |
| CONFIRMATION | Lift ≥ +2pp | Lift ≥ +0.04R | ≥ 50 | Both criteria required simultaneously; co-presence < 80% |
| FAILURE_MODE | Degradation ≥ −3pp | Degradation ≥ −0.06R | ≥ 50 | Either criterion sufficient |
| QUALITY_DISCRIMINANT | High-quality group WR ≥ +2pp above low-quality group | — | ≥ 30 per group | Not inverted |
| TIMING | Target period WR ≥ 40% | ≥ 0 | ≥ 50 | Persists across ≥ 2 sub-windows |
| REGIME | ≥ 40% | ≥ 0 | ≥ 50 | Mechanically plausible (no geometric constraint) |
| DIRECTION | Lift ≥ +2pp vs overall | Positive | ≥ 50 | Asymmetry material, not marginal |
| CAUSAL_CHAIN | Bi-directional lift (both members) | Both positive | ≥ 50 each | Causal mechanism documented |
| PLAYBOOK_ANCHOR | As for ALPHA_TRIGGER | > 0 | ≥ 50 | In playbook's core context specifically |

### 8.3 Layer Ownership

Every packet must have a layer assignment. Packets are not layer-neutral — they represent evidence at a specific layer in the decision architecture.

| Packet Type | Layer | Role in Architecture |
|---|---|---|
| ALPHA_TRIGGER | Layer 1 — Thesis | The "why this trade" signal |
| LOCATION | Layer 1 — Thesis | Zone quality filter on the thesis |
| CONFIRMATION | Layer 1 — Thesis | Independent corroborating evidence |
| FAILURE_MODE | Layer 2 — Risk | Evidence of when the thesis destroys value |
| QUALITY_DISCRIMINANT | Layer 3 — Allocation | Meta-signal for effective weight |
| TIMING | Layer 5 — Attribution | When does the edge concentrate? |
| REGIME | Layer 1 / Layer 3 | Conditioning context for thesis or allocation |
| DIRECTION | Layer 1 / Layer 3 | Directional bias within thesis |
| CAUSAL_CHAIN | Layer 1 — Thesis | Chain structure evidence |
| PLAYBOOK_ANCHOR | Layer 1 — Thesis | Playbook foundation |

### 8.4 What Packets Cannot Do

| Prohibited Action | Rule |
|---|---|
| Become a gate condition in council_pre_ai_filter | No packet status enters the risk/execution filter |
| Modify council_quality | council_quality is an internal aggregator computation; packet labels are external evidence |
| Change consensus_type classification | Consensus is computed from vote weights; packets are evidence labels |
| Authorize weight changes | Weight changes require Phase 6 EEWP + operator authorization |
| Override degradation_hint flags | Degradation hints are live runtime flags; cannot be cleared by Nautilus evidence |
| Make a RESEARCH_ONLY strategy a mandatory confirmer | Research designation means the hypothesis is open, not confirmed |

---

## 9. Registry Gap Analysis

Using PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md as source. No new tests conducted. All gaps labeled by type. Compact tables.

### 9.1 Missing Source Identity

| Strategy | Gap | Severity |
|---|---|---|
| breakdown_momentum_v1 | Variant A exact WR/E[R]/N not reproduced in registry (SOURCE_READ_REQUIRED) | LOW — cert label is definitive; full metrics in PIML §26 |
| trend_momentum | Variant A unrestricted metrics not in registry (SOURCE_READ_REQUIRED) | LOW — Variant B and subset data sufficient for design decisions |

No blocking gaps. Both strategies have definitive cert labels. Fill-in is a maintenance read task.

### 9.2 Missing Certifications

| Strategy | Family | Zone | Priority | Reason for Priority |
|---|---|---|---|---|
| range_compression_breakout | COMPRESSION_BREAKOUT | COMPRESSION/EXP | MEDIUM | VCR playbook anchor; no VCR evidence exists |
| mean_reversion_bounce | MEAN_RECLAIM | RMR | LOW-MEDIUM | RBSR secondary confirm; RMR evidence is thin after bollinger_reclaim challenge |
| fake_break_reversal | LIQUIDITY_REVERSAL | RMR | LOW-MEDIUM | RBSR SCOUT secondary; complementary to sweep_reversal |
| mfi_reversal_assist | MOM_REVERSAL_ASSIST | REV | BLOCKED | 0 live entries; cert not useful until live signal distribution observable |
| volatility_squeeze_release | COMPRESSION_BREAKOUT | COMPRESSION/EXP | LOW | Depends on range_compression_breakout cert first |
| volatility_breakout | VOL_BREAKOUT | EXP | LOW | VCR secondary; lowest priority after RCB |
| expansion_continuation | EXP_CONTINUATION | EXP | LOW | VCR secondary |
| micro_range_expansion | MICRO_RANGE_BREAK | EXP | LOW | VCR secondary |

Total uncertified (excluding FROZEN): 8 strategies. VCR family (4 strategies) represents the largest uncertified block.

### 9.3 Missing Playbook Assignments

| Strategy | Current Assignment | Gap |
|---|---|---|
| breakdown_momentum_v1 | NONE | No playbook assigned — cert showed regime inversion, no chain role viable |
| mfi_reversal_assist | RBSR (design intent) | No evidence supports this assignment; 0 entries; assignment is design-intent only |
| mean_reversion_bounce | RBSR (design intent) | 0 closed outcomes; assignment is design-intent only |
| fake_break_reversal | RBSR (design intent) | 0 entries; assignment is design-intent only |

BDM (breakdown_momentum_v1) with NONE assignment is the most significant gap — it is an active TC-zone SELL strategy with no playbook home. Evidence suggests it fires best in RANGE_NEUTRAL (an inverted result). Design review needed: does BDM belong in a RANGE_NEUTRAL extension of RBSR or TPC, or is it a standalone strategy without playbook context?

### 9.4 Missing Ledger Fields

| Gap | Current State | Required For | Status |
|---|---|---|---|
| playbook_id field | Not in ledger schema | Shadow playbook observation | SPECIFICATION_COMPLETE here; IMPLEMENTATION = FUTURE_CODEX_TASK |
| playbook_state field | Not in ledger schema | Shadow playbook observation | Same |
| packet_*_present fields | Not in ledger schema | Packet attribution | Same |
| Event timestamp sequence fields | Not in ledger schema | Event Order Contract enforcement | Same |
| pre_decision_available flag | Not in ledger schema | EOC-5 violation detection | Same |
| post_decision_playbook_state | Not in ledger schema | Calibration comparison | Same |

All ledger field gaps are specification-complete (§5). Implementation pending OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 Codex task authorization.

### 9.5 Missing Event-Order Proof

| Gap | Status |
|---|---|
| No system currently records whether confirmation fired before or after decision | SPECIFICATION_COMPLETE here (§6); proof requires timestamp fields (§5) |
| No system currently validates that failure mode evaluation was contemporaneous | Same |
| No system currently verifies playbook state was assembled before V1 decision | Same |

This entire gap class depends on Package B (ledger fields) being implemented first.

### 9.6 Missing Sample Sizes

| Strategy | Live N | Minimum Required | Gap |
|---|---|---|---|
| mfi_reversal_assist | 0 | ≥15 for basic evidence; ≥5 signal readings for Phase 4B | BLOCKED on first live entry |
| mean_reversion_bounce | 0 closed | ≥15 | Needs live accumulation |
| fake_break_reversal | 0 | ≥15 | Needs live accumulation |
| lower_high_rejection_v1 | 0 (live) | ≥15 | May have accumulated since last snapshot; monitor |
| micro_range_expansion | 0 | ≥15 | Needs live accumulation |
| VCR family (all 4) | 0 | ≥15 each | Needs live accumulation |
| trend_pullback_cont_v1 | 0 (live) | ≥5 for Phase 4A re-evaluation | Monitoring window open post-reload |

### 9.7 Contradicted Hypotheses

| Hypothesis | Strategy | Status | Implication |
|---|---|---|---|
| H1: REF SELL×TREND_DOWN contains positive signal | range_edge_fade | FALSIFIED — N=2, geometric constraint | No further SELL×TD tests; BUY×TD RESEARCH_ONLY secondary |
| Zone proxy gate improves bollinger_reclaim | bollinger_reclaim | CONTRADICTED — RANGE era = NOT_CONFIRMED | Design-intent vs. actual-behavior mismatch; gate not recommended by evidence |
| Zone proxy gate improves range_edge_fade | range_edge_fade | CONTRADICTED — RANGE_NEUTRAL gate degrades outcomes | Same design-intent mismatch as bollinger_reclaim |
| TREND_DOWN is best regime for BDM (SELL_ONLY) | breakdown_momentum_v1 | CONTRADICTED — regime inversion | TREND_DOWN is BDM's worst context |
| Quality score predicts actual trade quality | 5 consecutive certs | PATTERN_CONFIRMED_CONTRADICTED | Quality score inversion is systematic across families |
| Phase 5A SELL/TREND_UP gate reduces losses | bollinger_reclaim | NAUTILUS_CHALLENGED — gated subset marginally outperforms | Gate is SOURCE_APPLIED; runtime validation pending |
| TPC mandatory CRR gate is viable | trend_pullback_cont_v1 | CONTRADICTED — 98.6% starvation | Old architectural assumption retired; Option F path |

### 9.8 Research-Only Unresolved Hypotheses

These hypotheses have positive signal but fall below formal acceptance thresholds. Each requires a specific future test with a bounded hypothesis to advance or retire.

| Hypothesis | Supporting Evidence | Gap to Acceptance | Next Step If Pursued |
|---|---|---|---|
| Counter-trend sweeps are the active edge for sweep_reversal | WR=40.49%, E[R]=+0.012R, N=2,319 | E[R] below +0.04R ALPHA_TRIGGER threshold | New test: counter-trend only, extended dataset; need E[R] ≥ +0.04R to accept |
| RANGE_NEUTRAL×SELL is EDGE_SUPPORTED for trend_momentum | WR=44.37%, E[R]=+0.109R, N=1,402 | Bucket-specific; overall Variant B is WEAK not SUPPORTED | RCEM design: REDUCED weighting for non-RN×SELL conditions |
| TPC co-fires with TM produce superior outcomes | TM+TPC combined WR=45.61% vs TM alone 41.11% | Co-presence 1.4% — structural sparsity | Phase 4A Option F: track as quality enhancement, not gate |
| BUY×TREND_DOWN for range_edge_fade is viable | WR=40.31%, E[R]=+0.008R, N=191 | E[R] too thin (+0.008R below +0.04R threshold) | Not pursued under anti-swamp rule; revisit if extended dataset available |
| LHR SELL in TC proxy has near-breakeven E[R] | WR=40.15%, E[R]=+0.0037R, N=1,751 | E[R] below +0.04R for DIRECTION_PACKET | Co-presence test with TM if TPC remains sparse |

### 9.9 Runtime-Forbidden Gaps

These are items that appear as architectural gaps but cannot be addressed through any runtime change given current evidence levels.

| Gap | Why Forbidden Now | Clearance Condition |
|---|---|---|
| Regime-conditioned weights (RCEM enforcement) | No evidence baseline for 10 uncertified strategies; Phase 1 RCEM is documentation only | Phase 3 complete for ≥8 strategies + Phase 6 EEWP design |
| Cross-family CRR enforcement | TPC structural sparsity; architectural decision pending | Phase 4A path selected + implemented |
| OBSERVE_ONLY multiplier change (×0.15 → ×0.00) | Requires Opportunity Ledger audit ≥200 records | Phase 4C clearance |
| Exhaustion veto (EXHAUSTION_JUDGE blocks TC) | MFI 0 entries; no signal distribution | Phase 4B clearance |
| council_quality floor enforcement | Phase 4C blocked | Phase 2 maturity + Phase 4C implementation |
| BDM TREND_DOWN restriction | CONTRADICTED — TREND_DOWN is BDM's worst regime | No restriction authorized by current evidence |

---

## 10. What Not To Do Next

This section is binding on future task construction. The items below are prohibited as default next actions.

**Do not run more small micro-tests as the default action.** Micro-tests are warranted only when a specific REG.6 rule (R1–R5) applies AND the hypothesis is mechanically plausible AND the test result would change an architectural decision. The current research-only hypotheses do not meet this bar without further evidence that the test outcome matters.

**Do not run full Phase 3 certification for every remaining strategy by habit.** The 10 uncertified strategies should be certified in priority order. VCR anchor (range_compression_breakout) is the highest-priority uncertified strategy because it unlocks a blank playbook. The other 9 can follow evidence need, not calendar cadence.

**Do not optimize subsets.** The pattern across 8 certifications is that best-subset WR exceeds full-sample WR by 3–5pp but fails to meet formal ALPHA_TRIGGER thresholds. Subset optimization without a formal test protocol produces confirmation bias, not evidence.

**Do not tune parameters.** No gate threshold, weight value, ATR multiplier, or EMA period may be adjusted to improve Nautilus replay metrics. Parameter tuning on replay data is overfitting. The MT5 source is the ground truth; Nautilus is validation, not optimization.

**Do not promote packets by narrative.** A packet that is RESEARCH_ONLY is not promoted to ACCEPTED by strong language, by analogy to another strategy, or by appealing to the intuitive logic of the playbook. Promotion requires measured evidence meeting the formal threshold.

**Do not create playbook scores.** Playbook state is categorical only. "PLAYBOOK_FORMING" does not become a 0.6 score. A playbook that is 5/7 chain links complete is not "71% done" — it is still PLAYBOOK_FORMING because the formal CONFIRMATION_PACKET has not been accepted. Scores invite threshold optimization; categorical labels require formal acceptance.

**Do not convert failure-mode findings into gates.** MSR co-presence predicting LHR E[R] degradation is an accepted FAILURE_MODE_PACKET. This is research evidence that the combination is harmful. It does not authorize a gate in MT5 source preventing MSR from being active when LHR fires. Converting a failure-mode into a gate requires its own evidence standard and a bounded Codex task.

**Do not let the registry become runtime authority.** The registry records evidence states. Evidence states are inputs to operator decisions. Operator decisions produce bounded Codex tasks. Codex tasks produce MT5 source changes. No step in this chain may be skipped, and the registry document itself is not an authorization at any step.

**Do not claim production readiness at any intermediate phase completion.** System status remains DEVELOPING. The criteria are enumerated in Package E. None of them are currently met.

---

## 11. Future Codex Task Candidates

The following Codex tasks are defined as candidates. None are authorized here. None will be implemented from this document. They are listed to make future authorization decisions fast and bounded.

When the operator is ready to authorize one, it should be issued as a bounded Codex task with a single file scope, a compile verification requirement, and a 30-decision validation window before the next task begins.

---

### Candidate 1: OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1

| Field | Value |
|---|---|
| Type | Instrumentation-only |
| Purpose | Add playbook and packet observation fields to ai_opportunity_ledger.jsonl without affecting runtime decision |
| Files affected | council_mode_types.mqh (new struct fields); council_mode_runtime.mqh (write logic only) |
| Runtime effect | NONE — new fields are written to ledger; no field is read by decision pipeline |
| Evidence prerequisite | Opportunity Ledger currently live (already met); Phase 2 below 200-record threshold |
| Validation | Compile 0 errors/0 warnings; new fields appear in ledger records; decision outcomes unchanged across 30 decisions |
| Schema version | Designate ledger records written after this task as V1C_PLAYBOOK |
| Status | NOT_AUTHORIZED HERE |
| EOC enforcement | Must enforce Event Order Contract §6 — playbook_state must be assembled from pre-decision evidence only; pre_decision_available flag required |
| Rollback | Remove new fields and revert to V1B schema if any ledger write overhead exceeds 2ms/bar or any field influences decision path |

---

### Candidate 2: PLAYBOOK_STATE_SHADOW_EMITTER_V1

| Field | Value |
|---|---|
| Type | Shadow observation only |
| Purpose | Emit categorical playbook state per decision bar based on chain link completion; write to ledger only; never read by decision pipeline |
| Files affected | council_mode_runtime.mqh (shadow emitter function); possibly council_mode_types.mqh (PlaybookState enum) |
| Runtime effect | NONE — read-only evaluation of existing signals; write to ledger field only |
| Evidence prerequisite | OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 complete (Candidate 1 prerequisite) |
| Validation | Compile 0 errors/0 warnings; playbook_state field populated in ≥50 consecutive ledger records; values are categorical strings matching PCEA labels; no change in execution rate, WR, or any runtime metric |
| Prerequisite runtime check | Code review must confirm zero read dependency from V1 decision layers on PlaybookState field before deployment |
| Status | NOT_AUTHORIZED HERE |
| Rollback | Remove emitter function and revert playbook_state to empty string if any evidence of decision pipeline contamination |

---

### Candidate 3: EVENT_ORDER_TRACE_FIELDS_V1

| Field | Value |
|---|---|
| Type | Attribution instrumentation |
| Purpose | Record ISO8601 timestamps for each event in the Event Order Contract sequence (§6); enables post-hoc verification that evidence was available before decisions |
| Files affected | council_mode_types.mqh (timestamp fields in OpportunityRecord); council_mode_runtime.mqh (timestamp population) |
| Runtime effect | NONE — timestamps are recorded in ledger; not read by decision pipeline |
| Evidence prerequisite | OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 complete (Candidate 1 prerequisite); same ledger write path |
| Validation | Compile 0 errors/0 warnings; context_timestamp ≤ location_timestamp ≤ trigger_timestamp in all records (monotonic ordering); pre_decision_available=True in ≥90% of records |
| Status | NOT_AUTHORIZED HERE |
| Rollback | Remove timestamp fields if any write introduces latency in decision path > 1ms/bar (measured by pre/post comparison) |

---

### Candidate 4: PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1

| Field | Value |
|---|---|
| Type | Diagnostic and reporting only |
| Purpose | Compare registry packet states (from PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md) to observed runtime evidence (from Opportunity Ledger); identify systematic discrepancies between research expectations and live behavior |
| Files affected | NONE — this is a Python analysis script in nautilus_lab/ or a standalone reporting script; no MT5 files changed |
| Runtime effect | NONE |
| Evidence prerequisite | OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 complete; ≥200 ledger records with playbook fields populated |
| Output | Comparison report: per-strategy packet_*_present rates vs. Nautilus cert predictions; playbook_state distribution vs. expected state given strategy firing rates; alerts for systematic deviations |
| Status | NOT_AUTHORIZED HERE |
| Governance note | This check can reveal if the live system systematically differs from registry predictions. If it does, PIML must be updated to reflect actual live behavior before any further runtime changes. |

---

### Candidate 5 (Lower Priority): RCEM_V1_DOCUMENTATION_UPDATE

| Field | Value |
|---|---|
| Type | PIML documentation only (no source change) |
| Purpose | Formalize the Regime-Conditioned Eligibility Matrix (RCEM) v1 from Phase 3 evidence; document allowed/reduced/observe/blocked states per strategy × regime pair |
| Files affected | PROJECT_INTELLIGENCE_MEMORY_LAYER.md only (new §30 or subsection of §16) |
| Runtime effect | NONE — documentation only; RCEM is not yet enforced in source |
| Evidence prerequisite | Phase 3 certs complete for ≥8 strategies (currently 7); operator review of RCEM table |
| Status | NOT_AUTHORIZED HERE — Phase 3 at 7/17; one more cert would meet the ≥8 threshold |

---

## 12. Recommended Next Real Action

**Next recommended architecture action: IMPLEMENTATION_SPEC_PACKAGE_V1**

Create `IMPLEMENTATION_SPEC_PACKAGE_V1.md` as a second standalone MD file that turns the five Codex task candidates (§11) into detailed non-executed implementation specifications.

`IMPLEMENTATION_SPEC_PACKAGE_V1.md` should define, for each candidate Codex task:
- Exact struct fields to add (with MQL5 types)
- Exact function signatures for new write functions
- Exact write call insertion points in the existing runtime (file + approximate line range)
- Exact validation criteria (compile flags, runtime behavior checks)
- Exact rollback procedure

The implementation spec file is not an authorization to implement. It removes all ambiguity about what the implementation would look like, so that when the operator is ready to authorize a Codex task, the bounded scope is already fully defined and the implementation can proceed without design delays.

**This is the single recommended next action.** No more micro-tests by default. No more strategy certifications by default (unless VCR anchor cert is prioritized). The architecture needs specification depth before it needs more evidence breadth.

---

## 13. Completion Checklist

| Item | Status |
|---|---|
| Registry reviewed (PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md) | COMPLETE |
| Current architecture assets documented (§2) | COMPLETE |
| Target architecture model defined (§3) | COMPLETE |
| Package A — Registry Consolidation | COMPLETE |
| Package B — Ledger Alignment Specification | COMPLETE |
| Package C — Event Order Contract | COMPLETE |
| Package D — Shadow Observation | SPECIFIED (future Codex task) |
| Package E — Design Review / Readiness | SPECIFIED (future review) |
| Opportunity Ledger alignment fields defined (§5) | COMPLETE |
| Event Order Contract defined (§6) | COMPLETE |
| Playbook State Interface specified (§7) | COMPLETE |
| Packet Admission and Rejection Rules documented (§8) | COMPLETE |
| Registry Gap Analysis completed (§9) | COMPLETE |
| What Not To Do Next documented (§10) | COMPLETE |
| Future Codex Task Candidates listed (§11) | COMPLETE — 5 candidates |
| Recommended next real action stated (§12) | COMPLETE |
| No MT5 source files modified | VERIFIED |
| No runtime behavior changes | VERIFIED |
| No Nautilus scripts or certifications modified | VERIFIED |
| No compile executed | VERIFIED |
| No approval requested during execution | VERIFIED |
| All uncertainties labeled (SOURCE_READ_REQUIRED, FUTURE_CODEX_TASK_REQUIRED, FUTURE_REVIEW_REQUIRED, BLOCKED) | VERIFIED |
| Package complete | VERIFIED |

---

## Package Footer

```
PACKAGE_ID:                      ARCHITECTURE_BUILD_PACKAGE_V1
PACKAGE_DATE:                    2026-05-08
PACKAGE_TYPE:                    ARCHITECTURE_BUILD — documentation and specification only
BASED_ON:                        PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md + PIML §16–29
LARGE_PACKAGES_DEFINED:          5 (A=Registry, B=Ledger Spec, C=Event Order, D=Shadow, E=Review)
CODEX_TASK_CANDIDATES:           5 (Candidates 1–5 in §11)
LEDGER_FIELDS_SPECIFIED:         29 new fields across 5 categories (§5)
EVENT_ORDER_STEPS:               8 steps; 6 hard rules (§6)
REGISTRY_GAPS_CLASSIFIED:        9 gap types; 8 certification gaps; 7 contradicted hypotheses
FORMALLY_ACCEPTED_PACKETS:       1 (MSR FAILURE_MODE for LHR) — unchanged from registry
PLAYBOOK_STATES:                 RBSR=FORMING; TPC=FORMING; VCR=NOT_PRESENT
PHASE_4A_STATUS:                 BLOCKED — architectural decision required
PHASE_4B_STATUS:                 BLOCKED — MFI 0 live entries
PHASE_4C_STATUS:                 BLOCKED — Opportunity Ledger < 200 records
SYSTEM_STATUS:                   DEVELOPING — unchanged
MT5_SOURCE_CHANGED:              NO
RUNTIME_CHANGED:                 NO
NAUTILUS_CHANGED:                NO
COMPILE_EXECUTED:                NO
APPROVAL_REQUESTED:              NO
NEXT_RECOMMENDED_ACTION:         IMPLEMENTATION_SPEC_PACKAGE_V1
GOVERNED_BY:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md
RUNTIME_AUTHORITY:               V1 (MT5 EA) — permanent; not transferred to this package
```
