# DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1

**Plan type:** MANAGEMENT / ARCHITECTURE GOVERNANCE — Planning only
**Date:** 2026-05-09
**Authority:** PLANNING ONLY — No MT5 source change. No runtime change. No compile. No reload.
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory
**System status:** DEVELOPING — unchanged
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred

**Reference documents reviewed:**
- IRREW_PCEA_PENDING_WORK_STATUS_UPDATE_FAST_V1.md (today's fast status survey — primary input)
- PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md
- ARCHITECTURE_BUILD_PACKAGE_V1.md
- IMPLEMENTATION_SPEC_PACKAGE_V1.md
- SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md
- BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1.md
- FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_REPORT.md
- BTCUSD_INTERIM_POST_RELOAD_FVG_TPB_RUNTIME_SANITY_AND_FIX_REVIEW_V1_REPORT.md
- V1C_CLEANUP_PACKAGE_V1_REPORT.md
- IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1.md
- PROJECT_INTELLIGENCE_MEMORY_LAYER.md (key sections)

---

## 1. Executive Decision Frame

### 1.1 The Problem This Plan Solves

The current development posture creates an indefinite loop: every source change generates a runtime confirmation requirement, which requires market activity, which may take days or weeks, which then blocks the next change, creating a long-serialized chain where development velocity is gated entirely by live market exposure. This loop has resulted in a system where many compile-clean packages are perpetually marked RUNTIME_PENDING, yet no overall development completion target exists.

The operator proposes breaking this loop with a two-stage doctrine:

**Stage 1 — DEVELOPMENT_COMPLETE:** All required source changes implemented, compiled clean, documented, and reviewed. Runtime debts are explicitly recorded but do not block development closure. Development considers itself done when the *build* is complete and the *handover package* is ready — not when live runtime has confirmed every individual change.

**Stage 2 — PRODUCTION_READY:** Production readiness follows a strict post-delivery acceptance checklist. No production transition occurs until the checklist passes. Any checklist failure reopens investigation for the specific failed item. The checklist is non-negotiable.

### 1.2 Why This Is Safe

This doctrine is safe because:

1. **The V1 permission architecture is intact.** The EA's decision layers (DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE, score gates) are the protection mechanism. They do not depend on runtime observation of individual packages to be structurally sound.

2. **The PCEA authority firewall is implemented.** `runtime_authority_status="NONE"` is universal. Playbook state, packet state, and shadow observations are write-only. No shadow field drives any execution, gate, or weight.

3. **The risk envelope is independent.** The operating risk envelope and Level Brake protect execution integrity regardless of whether runtime confirmation has been recorded for any individual package.

4. **Behavior-changing changes remain restricted.** Only explicitly authorized, architecturally-required behavior-changing changes are permitted before delivery. Each must be compiled, reviewed, and explicitly named in the production checklist.

5. **No production claim is made during development.** DEVELOPING status is held through the entire development closure phase. Production transition requires checklist passage. No intermediate phase can be claimed production-ready.

### 1.3 Recommended Governance Label

```
ENGINEERING_COMPLETION_MODE_WITH_PRODUCTION_ACCEPTANCE_CHECKLIST
```

This label means:
- Development proceeds to completion without waiting for runtime evidence after every package
- Every behavior-changing change is explicitly documented, compiled, and added to the checklist
- Production acceptance is MANDATORY before any production transition
- Checklist failure reopens the relevant investigation
- No production readiness is claimed until all checklist items pass

### 1.4 What This Doctrine Does NOT Mean

| NOT authorized | Reason |
|---|---|
| Skipping review of behavior-changing changes | All behavior changes must be reviewed before inclusion in the delivery build |
| Bundling undeclared scope into packages | One change per package; scope must be declared before implementation |
| Deploying to live accounts before checklist passes | Production acceptance checklist is non-optional |
| Treating "compile-clean" as equivalent to "runtime-safe" | Compile-clean is necessary but insufficient for production transition |
| Retroactively claiming runtime confirmation from BTCUSD/interim sessions | BTCUSD and short interim sessions do not satisfy XAUUSD validation requirements |

---

## 2. Current System Status

### 2.1 Architecture Layer Status

| Layer | Authority | Current Status |
|---|---|---|
| V1 Permission Authority | RunCouncilPreAIFilter (DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE) | ACTIVE — not modified; not proposed for modification |
| Risk Authority | gOperatingRiskEnvelope + Level Brake | ACTIVE — not proposed for modification |
| Execution Authority | core_trade_engine.mqh | ACTIVE — not proposed for modification; zero references to council thesis fields confirmed |
| Attribution Authority | Opportunity Ledger, Performance Journal, SCM | ACTIVE — V1C schema live; 38+ records |

### 2.2 PCEA / V1C / FVG_TPB / Governance Status

| Component | Status |
|---|---|
| PCEA V1 formal adoption | DONE — PIML §25; registry complete |
| V1C playbook shadow architecture | DONE — compile-clean 2026-05-08; K1/K2/K3 cleanup 2026-05-09 |
| OL_V1C_PLAYBOOK_SHADOW schema | LIVE — 38+ records confirmed |
| FVG_TPB strategy #18 | DONE — compile-clean 2026-05-09; BTCUSD sanity PASS |
| LAB family registry fix | DONE — runtime confirmed (registry_unknown=0) |
| best_strategy_id semantic governance | DOCUMENTED — doctrine accepted; leakage caveat recorded; cleanup items A/B/C cataloged |
| PLAYBOOK_RUNTIME_AUTHORITY_FIREWALL_V1 | CONFIRMED — runtime_authority_status="NONE" universal |
| Strategy registry (17+1) | DONE — PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md |
| Playbook registry (3+IFR) | DONE — 3 playbooks registered; IFR lane defined |
| Phase 2 Ledger | ACTIVE — below 200-record Phase 4C threshold |
| Phase 5A bollinger_reclaim gate | SOURCE_APPLIED / NAUTILUS_CHALLENGED |
| Nautilus certs | PARTIAL — 7/17 Nautilus + 1 live-rejected; 9 uncertified |
| Phase 4A/4B/4C | ALL BLOCKED — per architecture; see Section 5 |

### 2.3 Architecture Track Classification

**ARCHITECTURE_TRACK_PARTIAL_WITH_RUNTIME_GAPS**

Development has a solid foundation: all required architectural frameworks (PCEA, V1C, IRREW, INEC_LAB_V1, FVG_TPB) are implemented and compile-clean. The gaps are:
1. Runtime debt items (validation not yet performed on XAUUSD)
2. Several architecture decisions pending (Phase 4A, Phase 4B threshold, Phase 4C timing)
3. SOURCE_READ_REQUIRED items that may generate additional small packages
4. Deferred cleanup items (semantic cleanup A/B/C)

None of these gaps prevent development from being closed — they all qualify as runtime debts, deferred items, or bounded pending investigations that should be explicitly listed and passed to production acceptance.

---

## 3. Development Completion Definition

### 3.1 DEVELOPMENT_COMPLETE Means

Development is complete when ALL of the following are true:

| Criterion | Verification Method |
|---|---|
| DEV-C-01 | All required source changes are implemented with 0 errors / 0 warnings per compile log | Compile log archive |
| DEV-C-02 | No open reload blockers exist (all reload-blocking bugs resolved) | Package report list |
| DEV-C-03 | No known decision-path leakage (playbook/packet/shadow fields not read by V1, risk, or execution) | Grep verification |
| DEV-C-04 | No unreviewed authority transfer | Package scope review per change |
| DEV-C-05 | Strategy registry current (all 18 strategies documented) | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md |
| DEV-C-06 | Playbook registry current (all 4 playbooks: RBSR, TPC, VCR, IFR) | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md |
| DEV-C-07 | V1 / IRREW / PCEA doctrine documented and formally adopted in PIML | PIML sections |
| DEV-C-08 | Production acceptance checklist created (this document Section 9) | This document |
| DEV-C-09 | Runtime debt ledger created (this document Section 8) | This document |
| DEV-C-10 | Rollback plan documented and rollback archives verified at last known clean state | Backup archive table |
| DEV-C-11 | All SOURCE_READ_REQUIRED items from status survey resolved (verified or explicitly deferred with rationale) | Resolution package |
| DEV-C-12 | Operator receives final handover package (this plan + runtime debt ledger + checklist + last clean archive path) | Handover document |

### 3.2 What DEVELOPMENT_COMPLETE Does NOT Mean

- It does NOT mean production is ready
- It does NOT mean all runtime debts are cleared
- It does NOT mean live performance is validated
- It does NOT mean every MT5 EA path has been exercised on XAUUSD
- It does NOT mean the system has been run through a full trading week

### 3.3 Minimum Build Quality Standard

For development completion, the binary must be:

1. Compiled with 0 errors, 0 warnings (or only pre-existing warnings explicitly documented)
2. All changes included in a final governed archive
3. No authority leakage confirmed by grep (council_aggregator, council_pre_ai_filter, council_ai_governor, core_trade_engine, main_ea — zero reads from shadow/playbook/packet fields)
4. Final binary timestamp documented in handover package

---

## 4. Production Readiness Definition

### 4.1 PRODUCTION_READY Means

Production readiness may only be claimed when ALL of the following are true:

| Criterion | Evidence Source |
|---|---|
| PROD-R-01 | Production acceptance checklist (Section 9) fully passed | Checklist execution record |
| PROD-R-02 | XAUUSD runtime validation complete — first fvg_tpb trigger confirmed, fvg_/ifr_ fields serialize correctly, IFR state = PLAYBOOK_FORMING, PLAYBOOK_VALID never emitted | Live XAUUSD session logs + ledger records |
| PROD-R-03 | No FileOpen / JSON / array / pointer / zero-divide errors in XAUUSD EA journal within ≥72-hour window | EA journal log review |
| PROD-R-04 | No abnormal termination attributable to any package in the delivery build (beyond operator-initiated stops) | EA journal log review |
| PROD-R-05 | No unauthorized playbook authority detected (runtime_authority_status="NONE" in all records) | Ledger record sample |
| PROD-R-06 | No score authority regression (pre-AI filter not reading playbook/packet state; council_quality formula unchanged) | Source diff review |
| PROD-R-07 | No CRR/DSN/HIGH_CONVICTION drift (thresholds unchanged from pre-delivery baseline unless explicitly authorized) | Source diff review |
| PROD-R-08 | No cohort promotion for IMBALANCE_FILL_REVERSAL (fvg_tpb blocked from execution by Level Brake; no IFR cohort gate added) | Source diff review + ledger records |
| PROD-R-09 | Execution behavior stable across ≥ 5 trade decisions on XAUUSD (BUY/SELL or REJECT all correctly reasoned) | EA journal + performance journal |
| PROD-R-10 | MT5 Strategy Tester fixed-replay validation complete covering at least 30 days of XAUUSD M5 data | Strategy Tester report |
| PROD-R-11 | Spread / slippage assumptions not violated (live spread ≤ 15pt for XAUUSD; no structural slippage above 3pt per trade) | Live session logs |
| PROD-R-12 | Phase 5A gate runtime validation complete — at least one bollinger_reclaim SELL suppression in TREND_UP observed and correctly handled | Live XAUUSD + ledger |
| PROD-R-13 | Live demo sample accumulated: ≥ 15 XAUUSD completed trades (W/L) with ledger records | Performance journal |
| PROD-R-14 | Operator explicitly grants production transition approval | Operator sign-off |

### 4.2 What PRODUCTION_READY Does NOT Mean

- It does NOT mean guaranteed profitability or minimum WR
- It does NOT mean all IRREW phases are complete (Phase 4A/4B/4C/6 may still be deferred)
- It does NOT mean all Nautilus certifications are complete
- It does NOT mean all shadow policy candidates have been evaluated
- It does NOT mean VCR strategies have ever fired

---

## 5. Remaining Modifications Required Before Development Completion

Classification codes:
- **RDC** = REQUIRED_BEFORE_DEV_COMPLETE
- **RDP** = REQUIRED_BEFORE_PRODUCTION (not dev complete, production acceptance only)
- **DPD** = DEFERRED_POST_DELIVERY
- **NR** = NOT_RECOMMENDED
- **SRR** = SOURCE_READ_REQUIRED (resolve first, then reclassify)

### 5.1 Master Modification Table

| # | Package ID | Layer | Files Likely Involved | Behavior-Changing? | Authority-Bearing? | Classification | Reason | Risk if Skipped | Owner | Review? | Compile? | Runtime Confirm (Acceptance)? | Checklist Item? |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| M-01 | SOURCE_READ_REQUIRED_RESOLUTION_V1 | Diagnostic | PIML read + council_ai_governor.mqh read + authority_stack_pilot.mqh read + ai_performance_journal.jsonl read | NO | NO | **RDC** | Must resolve 9 SRR items from status survey before declaring dev complete; some may generate small bounded packages | Cannot declare complete with open unknowns | Claude | YES | NO | NO | NO |
| M-02 | NO_SCORE_A2_STATUS_VERIFICATION_V1 | Decision layers | PIML No-Score section + council_pre_ai_filter.mqh + authority_stack_pilot.mqh | NO (verify only) | NO | **RDC** | Confirm pre-AI score gate is correctly demoted or identify missing implementation | Score authority regression undetected | Claude | YES | NO | YES (checklist C-06) | YES |
| M-03 | STAGE_D_GOVERNOR_STATUS_VERIFICATION_V1 | Governor | PIML + council_ai_governor.mqh | NO (verify only) | NO | **RDC** | Confirm governor categorical redesign status; classify as done or new package required | Governor authority gap unresolved | Claude | YES | NO | NO | NO |
| M-04 | EQ_DIAG_AND_STOP_GEOMETRY_STATUS_VERIFICATION_V1 | Execution / Observability | PIML + council_mode_types.mqh + core_trade_engine.mqh | NO (verify only) | NO | **RDC** | Determine if EQ-DIAG fields and stop geometry fields (sl_vs_m5_atr_ratio, level_context_at_entry, stop_anchor_state) are already implemented or deferred | Execution geometry observability gap undocumented | Claude | YES | NO | NO | NO |
| M-05 | XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1 | Attribution / Validation | Read-only (no source change) | NO | NO | **RDP** | First XAUUSD fvg_tpb trigger; fvg_/ifr_ serialization; IFR state; hostile branch; PLAYBOOK_VALID suppression | Largest unknown in acceptance checklist | Claude / Operator | YES | NO | YES — IS the validation | YES |
| M-06 | RUNTIME_DEBT_LEDGER_V1 | Documentation | This document Section 8 | NO | NO | **RDC** | Required for development handover | Cannot hand over without explicit debt record | Claude | YES | NO | NO | NO |
| M-07 | PRODUCTION_ACCEPTANCE_CHECKLIST_V1 | Documentation | This document Section 9 | NO | NO | **RDC** | Required for production gate | Cannot transition without checklist | Claude | YES | NO | NO | NO |
| M-08 | RCEM_V1_DOCUMENTATION_UPDATE | Documentation / PIML | PIML | NO | NO | **DPD** | Encode RCEM design intent per strategy; requires 8th Nautilus cert (currently 7/17); near-ready | No runtime impact; documentation gap only | Claude | YES | NO | NO | NO |
| M-09 | PHASE_4A_ARCHITECTURE_DECISION_PACKAGE_V1 | Council filter | council_pre_ai_filter.mqh | YES — if cross-family CRR activated | YES — V1 permission layer | **DPD** | TPC co-presence structural (1.4%); mandatory gate would cause 98.6% TC starvation; architecture decision required before any implementation; Option F accepted diagnostically but no implementation authorized | TC zone unconfirmed; structural quality gap in CONFIRM coverage | Claude (design) + Operator (authorize) | YES | YES (if implemented) | YES | YES (if implemented) |
| M-10 | PHASE_4B_EXHAUSTION_VETO_DESIGN_V1 | Runtime + filter | council_mode_runtime.mqh + council_pre_ai_filter.mqh | YES — when activated | YES — can REJECT trades | **DPD** | mfi_reversal_assist needs ≥5 signal-strength readings; currently 2; threshold calibration impossible without live data | TC zone unprotected from exhaustion; risk mitigated by existing governor | Claude (design when 5 entries) + Operator (authorize) | YES | YES (if implemented) | YES | YES (if implemented) |
| M-11 | PHASE_4C_QUALITY_SOFT_GATE_V1 | Pre-AI filter | council_pre_ai_filter.mqh | YES — WAIT decisions added | YES — V1 permission layer | **DPD** | Ledger must reach 200 records before gate can be evidence-validated; currently ~38–76+ records | Low-quality decisions not softly gated; governor partially compensates | Claude (design when threshold met) + Operator (authorize) | YES | YES (if implemented) | YES | YES (if implemented) |
| M-12 | PHASE_5B_PLUS_RESTRICTION_GATES_V1 | Strategy layer | council_strategies.mqh | YES — restricts hostile subsets | LOW — strategy-level filter | **DPD** | Requires per-strategy Nautilus cert + operator auth for each gate; 9 uncertified strategies; Phase 5B+ is not authorized at this time | Some strategies fire in hostile regimes; Phase 5A is a partial remedy; governor provides coarse protection | Claude (design per cert) + Operator (per gate) | YES (per gate) | YES (per gate) | YES (per gate) | YES (per gate) |
| M-13 | EXECUTION_ADMISSION_IDENTITY_DECOUPLING_V1 (Cleanup A) | Main EA cohort | main_ea.mq5 | YES — changes family inference path for cohort check | YES — cohort admission | **DPD** | Current path (best_strategy_id → LAB_InferFamily → cohort check) is safe but semantically impure; behavioral outcome correct; cleanup is architectural hygiene | Risk is low under current conditions; fvg_tpb cohort blocking correct either way | Codex + Claude review | YES | YES | YES | NO (behavioral change must not alter cohort outcomes) |
| M-14 | PRIMARY_THESIS_STRATEGY_ID_RENAME_DESIGN_V1 (Cleanup B) | Attribution / diagnostics | multiple files (23+ occurrences) | NO — semantic/naming only | NO | **DPD** | Cosmetic rename; no behavioral impact; high cross-file surface area makes it risky without careful preparation | Semantic impurity persists; no runtime risk | Claude (design) + Codex | YES | YES | NO | NO |
| M-15 | PRIMARY_THESIS_SELECTION_CONTRACT_V1 (Cleanup C) | Aggregator | council_aggregator.mqh | MINOR — adds trigger_present + direction filter to selection | NO direct | **DPD** | Clarifies selection algorithm; closes edge case where non-triggering strategy wins best_strategy_id | Thesis identity misleads attribution in edge cases | Claude (design) + Codex | YES | YES | NO | YES (verify selection correctness) |
| M-16 | VCR_FAMILY_HANDLING_DECISION_V1 | Documentation | PIML | NO | NO | **DPD** | 5 VCR strategies have 0 live entries; COMPRESSION/EXP zones must activate first; no intervention possible without zone activation | VCR permanently at PLAYBOOK_NOT_PRESENT; acceptable until zones activate | Claude | YES | NO | NO | NO |
| M-17 | SPC_EVALUATION_FRAMEWORK_COMPLETION | Attribution analysis | ai_opportunity_ledger.jsonl (external Python/analysis) | NO — observation only | NO | **DPD** | SPC-001 through SPC-010 require ≥50 V1C executed outcomes; not yet accumulated; evaluation is research-only | Shadow policies cannot be assessed; no runtime impact | Claude / INEC_LAB_V1 | YES | NO | NO | NO |
| M-18 | STOP_GEOMETRY_EQ_DIAG_V1 (if not implemented) | Execution observability | council_mode_types.mqh + council_mode_runtime.mqh | YES (if not yet added) | NO direct | **SRR → then reclassify** | EQ-DIAG-V1 status unknown from reviewed packages; must confirm whether sl_vs_m5_atr_ratio, level_context_at_entry, stop_anchor_state are already live | Execution geometry unobservable in ledger if not implemented | Claude (verify) → then Codex (if needed) | YES | YES (if needed) | YES | YES |
| M-19 | NO_SCORE_HARD_LOCK_PACKAGE_VERIFICATION | Diagnostic | council_mode_runtime.mqh L198–199 (known hard-lock) | NO (verify only) | NO | **RDC** | Confirm score-authority hard-lock is in place and not accidentally bypassed by any subsequent change | Score authority regression | Claude | YES | NO | YES (checklist D-01) | YES |
| M-20 | FINAL_GOVERNED_SYSTEM_ARCHIVE_V1 | Governance | Full system zip | NO | NO | **RDC** | Pre-delivery governed archive at declared DEVELOPMENT_COMPLETE state | Cannot roll back without a clean archive | Claude / Operator | YES | NO | NO | NO |

---

## 6. Behavior-Changing Changes That May Be Allowed Before Delivery

The following behavior-changing changes are candidates for inclusion in the development build if their preconditions can be met during the development window. Each is authorized only if explicitly separately approved by the operator through a bounded package decision.

### BC-01 — Phase 4C Quality Soft Gate Activation

| Field | Value |
|---|---|
| Expected behavior change | NARROW consensus decisions with council_quality < 0.50 will receive COUNCIL_DECISION_WAIT instead of proceeding to trade |
| Why architecturally required | IRREW Phase 4C; currently diagnostic-only; approved in architecture design §I Change I-3 |
| Authority touched | V1 permission layer (council_pre_ai_filter.mqh) — adds WAIT path |
| Precondition | Ledger must accumulate ≥200 records AND records must be examined to confirm suppressed trades would not have been wins at a higher rate than unsuppressed |
| How to prevent unsafe activation | Soft gate only (WAIT not REJECT); council_quality threshold 0.50 not 0.55; NARROW consensus only |
| Review required | YES — scope review + source diff before implementation |
| Checklist item | PAC-E-04: Confirm no new REJECT decisions from quality gate; only WAIT |

### BC-02 — Phase 4B Exhaustion Veto (mfi_reversal_assist)

| Field | Value |
|---|---|
| Expected behavior change | In TC/BREAKOUT zones with exhaustion_signal_strength ≥ calibrated_threshold AND exhaustion_direction ≠ dominant_side: REJECT emitted from new veto path |
| Why architecturally required | IRREW Phase 4B; prevents harmful trend continuation trades in exhausted markets; approved in architecture §G |
| Authority touched | V1 permission layer (new REJECT path); council_mode_runtime.mqh + council_mode_types.mqh |
| Precondition | mfi_reversal_assist must accumulate ≥5 live signal-strength readings; threshold calibrated from actual distribution; NOT from hypothetical range |
| How to prevent unsafe activation | Threshold design requires observed distribution, not assumed values; operator must authorize specific threshold in bounded Codex task |
| Review required | YES — mandatory; threshold must be derived from data, not guessed |
| Checklist item | PAC-E-05: Confirm veto only fires in TC/BREAKOUT + correct direction; never fires in REV/RMR; threshold rational |

### BC-03 — Phase 5B+ Hostile Regime Restriction Gates (per strategy)

| Field | Value |
|---|---|
| Expected behavior change | Per-strategy gates in council_strategies.mqh prevent trigger firing in confirmed hostile regime subsets (e.g., breakdown_momentum_v1 restricted to TREND_DOWN; lower_high_rejection_v1 SELL-only reinforcement) |
| Why architecturally required | IRREW Phase 5B+; each gate requires Nautilus cert + operator authorization; prevents strategies from firing in regimes where E[R] is confirmed negative |
| Authority touched | Strategy-level trigger eligibility (pre-aggregation); LOW authority — restricts trigger, does not add REJECT to V1 |
| Precondition | Nautilus cert for specific strategy must confirm hostile subset; operator must authorize specific gate in bounded Codex task; one gate per task |
| How to prevent unsafe activation | One strategy, one gate, one Codex task; no bundling; each gate reviewed against Nautilus evidence before authorization |
| Review required | YES — per gate |
| Checklist item | PAC-G-03 per strategy: Confirm gate fires only in authorized hostile subset; confirm no strategy blocked in non-hostile zone |

### BC-04 — V1 Constructive Eligibility A1 Flag Enablement

| Field | Value |
|---|---|
| Expected behavior change | `EnableV1ConstructivePolicyEligibility=true` would allow V1 policy to downgrade strategy eligibility_state before aggregation; changes effective postV1Weight for affected strategies |
| Why architecturally required | V1 policy eligibility is part of the IRREW V1 architecture; currently implemented but disabled |
| Authority touched | Pre-aggregation eligibility state; indirect effect on postV1Weight and best_strategy_id selection |
| Precondition | V1 policy eligibility field presence must be confirmed in DECISION records (v1_policy_* fields); policy behavior must be reviewed against observed FSW field evidence; operator must authorize activation |
| How to prevent unsafe activation | Flag remains false by default; operator must explicitly set to true; V1 never upgrades (only downgrades) eligibility |
| Review required | YES — review v1_policy_* DECISION fields before enabling |
| Checklist item | PAC-D-05: Confirm v1_policy_ fields present; confirm no eligibility upgrades; confirm no postV1Weight increases from V1 policy |

**None of BC-01 through BC-04 are authorized by this plan. This section defines candidates only. Each requires a separate bounded operator authorization before implementation.**

---

## 7. Items That Must Remain Forbidden Before Production

The following items remain forbidden. No development package, planning document, or architecture proposal changes their forbidden status unless a separate, explicitly governed operator decision exists.

| Item | Forbidden Because |
|---|---|
| Production-ready claim at any point before checklist passes | Production acceptance checklist is non-negotiable |
| Runtime playbook authority (playbook state driving BUY/SELL/WAIT/REJECT) | PCEA V1 GF-9; PLAYBOOK_RUNTIME_AUTHORITY_FIREWALL_V1 |
| Playbook gates (blocking or permitting trades based on playbook state) | No evidence basis; PCEA V1 §11 forbidden conclusions |
| Packet gates (blocking or permitting trades based on packet status) | GF-5; no packet gate authorized |
| playbook_score or completion percentage | PIML REG.6 R1; no numeric playbook score authorized |
| council_quality bonus for any playbook/packet/cross-family condition | Advisory Correction §23.A; score authority rejected |
| HIGH_CONVICTION threshold change | No evidence basis; IRREW §N explicitly forbids |
| CRR/DSN gate threshold change | Phase 4A BLOCKED; IRREW §N explicitly forbids |
| IMBALANCE_FILL_REVERSAL cohort promotion | IFR permanently withheld from cohort; PLAYBOOK_VALID permanently suppressed for IFR |
| Automatic weight changes | Phase 6 DESIGN_ONLY; all weight changes require operator authorization per bounded Codex task |
| Strategy promotion/demotion without Nautilus evidence + operator auth | GF-5; no promotion without cert + live N ≥ 15 + operator auth |
| P4 blocking options 2/3/4 (dirty environment gate enforcement) | Pending frequency/impact evidence + explicit approval per option |
| Level Brake weakening or LAB gate modification | Level Brake protects cohort integrity; no change authorized |
| New strategy injection beyond FVG_TPB | Factory admission lock; no general admission without standalone plan |
| Risk posture weakening of any kind | Risk authority is protection layer; changes require independent risk review |
| Score authority of any kind in decision layers | Core IRREW/PCEA/No-Score doctrine; hard-locked |
| Shadow policy implementation without separate bounded authorization | Each SPC requires separate operator authorization per GFS-1 |
| DQ threshold activation in authority_stack_pilot.mqh | A3-Revised quarantined DQ; DQ is diagnostic-only |

---

## 8. Runtime Debt Ledger

The Runtime Debt Ledger records what has been compiled and reviewed but not yet validated at runtime. These items do not block development completion. Every item in this ledger MUST be resolved before production readiness can be claimed.

---

### RDL-001 — XAUUSD FVG_TPB First Trigger

| Field | Value |
|---|---|
| Related package | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 + BTCUSD sanity review |
| What is unconfirmed | fvg_tpb trigger has never fired on XAUUSD; fvg_/ifr_ JSON field serialization path never exercised on XAUUSD |
| Why it does not block dev complete | Implementation is compile-clean; BTCUSD sanity confirmed no runtime errors; decision-path isolation confirmed; JSON code path exists and is syntactically correct |
| Why it blocks production readiness | A JSON serialization bug, array-bounds error, or FileOpen failure in fvg_/ifr_ code paths could corrupt the ledger silently; cannot verify without a live trigger |
| Required validation method | Live XAUUSD — EA must observe first fvg_tpb trigger on XAUUSD M5 |
| Pass criteria | Record appears in ai_opportunity_ledger.jsonl with strategy_id="fvg_tpb", correct fvg_* fields, playbook_id="IMBALANCE_FILL_REVERSAL", playbook_state="PLAYBOOK_FORMING", runtime_authority_status="NONE"; no parse errors |
| Fail action | Investigate serialization bug; apply bounded fix; re-validate |

---

### RDL-002 — fvg_/ifr_ JSON Field Serialization Integrity on XAUUSD

| Field | Value |
|---|---|
| Related package | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 + V1C_CLEANUP |
| What is unconfirmed | All fvg_* and ifr_* conditional JSON fields serialize correctly in a real XAUUSD trigger event; no double-comma or syntax error in conditional block |
| Why it does not block dev complete | BTCUSD session showed 0 fvg_tpb triggers; JSON code path compiles cleanly; conditional serialization logic is structurally sound |
| Why it blocks production readiness | Silent JSON corruption would cause strict json.loads() parse failures in analytics; P2.A history shows double-comma bugs can be subtle |
| Required validation method | Live XAUUSD — strict json.loads() parse of the first fvg_tpb ledger record |
| Pass criteria | json.loads() succeeds; all fvg_* fields present with correct types; no double-comma |
| Fail action | Apply bounded JSON separator fix; re-validate |

---

### RDL-003 — FVG_TPB Hostile SELL_TREND_DOWN Branch

| Field | Value |
|---|---|
| Related package | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 |
| What is unconfirmed | When fvg_tpb trigger fires in SELL_TREND_DOWN context, FSW multiplier reduction correctly applies (0.90 CONDITIONAL → reduced weight) and no trade is enabled that shouldn't be |
| Why it does not block dev complete | FSW multiplier logic in council_v1_state_composer.mqh is compile-verified; BTCUSD run showed no trade execution from fvg_tpb |
| Why it blocks production readiness | Hostile branch is the highest-risk code path for fvg_tpb; IFR is not in cohort so execution should be blocked, but the FSW path must also correctly reduce influence in the harmful direction |
| Required validation method | Live XAUUSD — observe at least one fvg_tpb trigger in TREND_DOWN + SELL condition; verify FSW multiplier in ledger record |
| Pass criteria | fvg_tpb subset_class="HOSTILE" in ledger; FSW multiplier confirms reduction; no execution (cohort gate blocks) |
| Fail action | Investigate FSW branch; apply bounded fix if needed |

---

### RDL-004 — IFR Playbook State Distribution (PLAYBOOK_VALID Never Emitted)

| Field | Value |
|---|---|
| Related package | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 + V1C |
| What is unconfirmed | In XAUUSD sessions, playbook_state for IFR records is always PLAYBOOK_FORMING; PLAYBOOK_VALID is never emitted; no IFR state drives any execution decision |
| Why it does not block dev complete | Code explicitly withholds PLAYBOOK_VALID for IFR; logic is compile-verified; BTCUSD run showed ifr_state_seen_count=0 (no triggers) |
| Why it blocks production readiness | If a code path erroneously emits PLAYBOOK_VALID for IFR in XAUUSD context, this violates the architecture firewall and could mislead future analysis or future implementations |
| Required validation method | Live XAUUSD — ≥10 fvg_tpb trigger records in ledger; verify playbook_state distribution |
| Pass criteria | All IFR records show playbook_state ∈ {PLAYBOOK_NOT_PRESENT, PLAYBOOK_FORMING}; PLAYBOOK_VALID count = 0; runtime_authority_status="NONE" in all |
| Fail action | Immediate investigation of IFR state assignment logic; ARCHITECTURE_TRACK_BLOCKED_BY_AUTHORITY_LEAKAGE |

---

### RDL-005 — Ledger Maturity for Phase 4C (200-Record Threshold)

| Field | Value |
|---|---|
| Related package | Phase 4C (IRREW architecture); Opportunity Ledger Phase 2 |
| What is unconfirmed | Ledger has not yet reached 200 records required for Phase 4C quality soft gate evidence base |
| Why it does not block dev complete | Phase 4C is DEFERRED_POST_DELIVERY; ledger accumulation is ongoing; no source change is pending on this threshold |
| Why it blocks production readiness | Quality soft gate cannot be activated without evidence base; if Phase 4C is in scope for production, evidence base must be met first |
| Required validation method | Ledger record count ≥ 200 executed trigger records (BUY/SELL/WAIT decisions, not just evaluation records) |
| Pass criteria | ai_opportunity_ledger.jsonl contains ≥200 records with trigger_present=true; diverse regime/zone coverage |
| Fail action | Continue XAUUSD session accumulation; do not activate Phase 4C before threshold |

---

### RDL-006 — Phase 4A TPC Co-Presence Architecture Decision

| Field | Value |
|---|---|
| Related package | Phase 4A (IRREW architecture); TPC certification |
| What is unconfirmed | Whether cross-family CRR can be safely activated given TPC co-presence rate of 1.4%; and what architecture option (Option F or alternative) the operator selects |
| Why it does not block dev complete | Phase 4A is DEFERRED_POST_DELIVERY; current system operates without cross-family CRR; operator has not yet selected implementation path |
| Why it blocks production readiness | TC zone trades are structurally unconfirmed by cross-family signal; TC performance may suffer under adverse conditions without CRR protection |
| Required validation method | Architecture decision by operator → bounded implementation package → compile → MT5 Strategy Tester replay → live XAUUSD validation |
| Pass criteria | TPC co-presence rate in live V1C ledger ≥ 5% (or alternative path authorized); CRR gate does not cause TC execution collapse below 50% of pre-gate rate |
| Fail action | Do not activate Phase 4A; continue monitoring TPC live fire rate; reconsider architecture |

---

### RDL-007 — Phase 4B MFI ≥5 Signal Strength Readings

| Field | Value |
|---|---|
| Related package | Phase 4B (IRREW architecture); mfi_reversal_assist |
| What is unconfirmed | mfi_reversal_assist has 2 live entries; 5 are required before any exhaustion veto threshold can be designed |
| Why it does not block dev complete | Phase 4B is DEFERRED_POST_DELIVERY; current system has no exhaustion veto; governor provides coarse protection |
| Why it blocks production readiness | Exhaustion veto protects TC/BREAKOUT zone from false continuation signals; without it, TC trades may occur in exhausted markets |
| Required validation method | Live XAUUSD — accumulate ≥5 mfi_reversal_assist signal-strength readings; design threshold from actual distribution |
| Pass criteria | ≥5 mfi_reversal_assist trigger records in V1C ledger with exhaustion_signal_strength values; distribution charted; threshold selected from data |
| Fail action | Continue monitoring; do not design threshold from fewer than 5 readings |

---

### RDL-008 — Phase 5A Gate Runtime Validation

| Field | Value |
|---|---|
| Related package | Phase 5A (bollinger_reclaim SELL_TREND_UP gate; BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A) |
| What is unconfirmed | Gate is SOURCE_APPLIED; no SELL_TREND_UP suppression has been observed; NAUTILUS_CHALLENGED (gated-out subset marginally outperformed allowed subset in Nautilus) |
| Why it does not block dev complete | Gate is in the binary; compile-clean; behavioral scope is narrow (one direction filter in one strategy); documented as NAUTILUS_CHALLENGED |
| Why it blocks production readiness | If gate is suppressing profitable trades (which Nautilus suggests may be the case), it is harmful and should be reviewed before production; operator must decide whether to accept the gate or remove it with evidence |
| Required validation method | Live XAUUSD — observe ≥10 bollinger_reclaim evaluation bars in TREND_UP regime; verify SELL suppression occurring; compare live WR of allowed vs suppressed subset after 30+ events |
| Pass criteria | Gate fires correctly; suppression rate consistent with Nautilus TREND_UP baseline; no unexpected behavior; operator reviews NAUTILUS_CHALLENGED status and authorizes retention or removal |
| Fail action | If gate is suppressing profitable trades materially → investigate removal in bounded package |

---

### RDL-009 — V1C K1 / K3 XAUUSD Confirmation

| Field | Value |
|---|---|
| Related package | V1C_CLEANUP_PACKAGE_V1 (K1: late_evidence semantic fix; K3: bollinger_reclaim packet status fix) |
| What is unconfirmed | K2 confirmed by BTCUSD run (registry_unknown=0); K1 (late_evidence_seen_count should be 0 post-fix) and K3 (bollinger_reclaim records should show RESEARCH_ONLY) require XAUUSD bollinger_reclaim triggers |
| Why it does not block dev complete | K1/K3 are semantic fixes with no decision impact; BTCUSD run confirmed binary is current |
| Why it blocks production readiness | K1 ensures late_evidence field discriminates correctly for future SPC evaluation; K3 ensures packet_registry_status is accurate in ledger analytics |
| Required validation method | Live XAUUSD — ≥5 bollinger_reclaim trigger records with packet_registry_status="RESEARCH_ONLY" and late_evidence_seen_count reflecting only genuine late evidence |
| Pass criteria | All post-cleanup bollinger_reclaim records show packet_registry_status="RESEARCH_ONLY"; late_evidence_seen_count remains low (< 5% of trigger records) |
| Fail action | Investigate remaining K1/K3 code path issues |

---

### RDL-010 — No-Score A2 Pre-AI Score Gate Demotion (if unimplemented)

| Field | Value |
|---|---|
| Related package | No-Score V1 architecture |
| What is unconfirmed | Pre-AI score gate demotion (A2) exact implementation status — SOURCE_READ_REQUIRED from status survey |
| Why it does not block dev complete | Score authority hard-lock is confirmed at council_mode_runtime.mqh L198–199; if A2 is unimplemented as a distinct stage, the hard-lock provides the same protection |
| Why it blocks production readiness | Any residual pre-AI score gate that could influence execution must be confirmed demoted; unresolved source read means we cannot verify |
| Required validation method | Source read of council_pre_ai_filter.mqh + authority_stack_pilot.mqh; confirm no score value drives REJECT/WAIT path in V1 layer |
| Pass criteria | No code path in V1 permission layer reads score_final or any numerical score as a gate condition (only categorical labels); diagnostic-only flags confirmed |
| Fail action | Implement A2 demotion as bounded Codex task if score gate found active |

---

### RDL-011 — EQ-DIAG and Stop Geometry Fields

| Field | Value |
|---|---|
| Related package | PLAN-ARCH-DR P3.2-S (expected_rr_estimate repair); EQ-DIAG-V1 (if separate) |
| What is unconfirmed | Whether sl_vs_m5_atr_ratio, level_context_at_entry, stop_anchor_state are implemented in ledger records or deferred |
| Why it does not block dev complete | Stop geometry observability is observability-layer only; execution behavior unaffected whether or not these fields are populated |
| Why it blocks production readiness | Without stop geometry observability in ledger, post-trade analysis cannot verify stop placement quality or ATR ratio compliance |
| Required validation method | Source read of council_mode_types.mqh + ai_opportunity_ledger.jsonl record fields; confirm presence or absence |
| Pass criteria | Fields present in OL_V1C schema records with non-zero values (or explicitly documented as deferred with rationale) |
| Fail action | Implement as bounded Codex observability task if absent; or formally record as DEFERRED |

---

### RDL-012 — V1C K1 Through K3 Full Session Coverage

| Field | Value |
|---|---|
| Related package | V1C_CLEANUP_PACKAGE_V1 |
| What is unconfirmed | Whether 7 pre-cleanup bollinger_reclaim records (showing REJECTED) and 2 pre-cleanup mean_reversion_bounce records (showing UNKNOWN) may affect analytics cross-run comparisons |
| Why it does not block dev complete | Pre-cleanup records are preserved in JSONL as historical; new records are correctly classified; no runtime impact |
| Why it blocks production readiness | Historical records with incorrect schema may cause parse failures in strict analytics; must verify analytics handle mixed schemas |
| Required validation method | Ledger replay analysis; confirm analytics tool parses both pre/post-cleanup records without failures |
| Pass criteria | Analytics parses all records; pre-cleanup records flagged as legacy; no analytics crash from mixed packet_registry_status values |
| Fail action | Add schema-version filter to analytics; or backfill documentation of pre-cleanup records as LEGACY |

---

### RDL-013 — PLAN-ARCH-DR P3.2 (Strategy Intelligence) Runtime Confirmation

| Field | Value |
|---|---|
| Related package | PLAN-ARCH-DR Stage P3.2 |
| What is unconfirmed | strategy_intelligence_enabled=false in plan_v076; ComputeEntryQualityV1() never called in current configuration; council_zone rebinding unconfirmed in live operation |
| Why it does not block dev complete | P3.2 is correctly compiled; plan_v076 flag is intentionally false; no active code path exercised |
| Why it blocks production readiness | If production plan enables strategy_intelligence_enabled, P3.2 path must have been runtime-confirmed first |
| Required validation method | Enable strategy_intelligence_enabled in test plan → observe DECISION records for v1_shadow_scoring_quarantine_version="V1_SCORING_QUARANTINE_V3_ENFORCEMENT" and DQ_V3 fields |
| Pass criteria | DQ_V3 fields present; council_zone used as trendish/rangish source (not gRegime) in council-active bars |
| Fail action | Investigate P3.2 code path if plan enables the feature |

---

## 9. Production Acceptance Checklist

This checklist must be executed and all items must PASS before production transition is authorized. Items marked **[BLOCKS PRODUCTION]** prevent production transition if they fail. Items marked **[BLOCKS INVESTIGATION]** do not prevent transition but reopen the specific investigation area.

---

### Category A — Build / Compile

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-A-01 | Final binary timestamp matches last authorized compile | main_ea.ex5 LastWriteTime matches compile log timestamp | main_ea.ex5 metadata + compile log | Re-compile from governed source | **[BLOCKS PRODUCTION]** |
| PAC-A-02 | Compile log shows 0 errors | `Result: 0 errors` in compile log | Compile log (.log file) | Investigate and fix errors | **[BLOCKS PRODUCTION]** |
| PAC-A-03 | Compile log shows 0 warnings or only pre-documented warnings | Warnings count matches pre-documented baseline | Compile log | Document new warnings or fix | **[BLOCKS PRODUCTION]** |
| PAC-A-04 | Final governed archive exists at declared baseline | Archive size > 0; key files present in archive | Archive (.zip) listing | Create new governed archive | **[BLOCKS PRODUCTION]** |
| PAC-A-05 | Archive contains council_mode_types.mqh, council_mode_runtime.mqh, council_strategies.mqh, level_awareness_brake.mqh with expected sizes | Each file size matches live file | Archive vs live diff | Re-archive | **[BLOCKS PRODUCTION]** |

---

### Category B — Source Scope / Diff

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-B-01 | Files changed vs clean baseline are exactly as declared | File-by-file diff matches package scope declarations | Git diff or archive diff | Investigate undeclared changes | **[BLOCKS PRODUCTION]** |
| PAC-B-02 | No changes to council_aggregator.mqh beyond authorized scope | Zero unauthorized hunks | Source diff | Revert unauthorized changes | **[BLOCKS PRODUCTION]** |
| PAC-B-03 | No changes to core_trade_engine.mqh | Zero changes | Source diff | Revert | **[BLOCKS PRODUCTION]** |
| PAC-B-04 | No changes to main_ea.mq5 risk/execution paths beyond authorized PLAN-ARCH-DR scope | Zero unauthorized execution changes | Source diff | Revert | **[BLOCKS PRODUCTION]** |
| PAC-B-05 | V1 permission gates (DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE) unchanged from authorized baseline | Gate thresholds and logic match documented values | Source diff of council_pre_ai_filter.mqh | Revert unauthorized changes | **[BLOCKS PRODUCTION]** |

---

### Category C — Authority Boundary

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-C-01 | Zero fvg_/ifr_/playbook_/packet_ reads in council_aggregator.mqh | Grep count = 0 for read operations | Grep output | Investigate and remove | **[BLOCKS PRODUCTION]** |
| PAC-C-02 | Zero fvg_/ifr_/playbook_/packet_ reads in council_pre_ai_filter.mqh | Grep count = 0 for read operations | Grep output | Investigate and remove | **[BLOCKS PRODUCTION]** |
| PAC-C-03 | Zero fvg_/ifr_/playbook_/packet_ reads in council_ai_governor.mqh | Grep count = 0 for read operations | Grep output | Investigate and remove | **[BLOCKS PRODUCTION]** |
| PAC-C-04 | Zero fvg_/ifr_/playbook_/packet_ reads in core_trade_engine.mqh | Grep count = 0 | Grep output | Investigate and remove | **[BLOCKS PRODUCTION]** |
| PAC-C-05 | OL_RuntimeAuthorityStatus() always returns "NONE" | Function body returns literal "NONE" unconditionally | Source read council_mode_runtime.mqh | Fix function | **[BLOCKS PRODUCTION]** |
| PAC-C-06 | runtime_authority_status="NONE" in all sampled ledger records | 100% of checked records | 30-record ledger sample | Investigate any exception | **[BLOCKS PRODUCTION]** |

---

### Category D — No-Score / Score Authority

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-D-01 | Score authority hard-lock in place (council_mode_runtime.mqh L198–199 or equivalent) | Hard-lock lines present and unmodified | Source read | Reinstate hard-lock | **[BLOCKS PRODUCTION]** |
| PAC-D-02 | council_quality formula unchanged from authorized baseline | Formula constants and inputs match documented baseline | Source diff + PIML §aggregator reference | Revert | **[BLOCKS PRODUCTION]** |
| PAC-D-03 | No pre-AI score gate active (A2 confirmed or N/A documented) | council_pre_ai_filter: no numeric score drives REJECT/WAIT | Source read + PAC-B-05 cross-check | Implement A2 demotion if active | **[BLOCKS PRODUCTION]** |
| PAC-D-04 | DQ (Dynamic Quality) in authority_stack_pilot is diagnostic-only | No live BLOCKED_DQ branch present; DQ flag is compatibility-only | Source read authority_stack_pilot.mqh | Reinstate A3-Revised quarantine | **[BLOCKS PRODUCTION]** |
| PAC-D-05 | V1 FSW multipliers do not upgrade any strategy's weight above baseline | All FSW multipliers ≤ 1.00 in worst-case scenario | Source read council_v1_state_composer.mqh; FSW clamp [0.85, 1.05] confirmed | Investigate if any multiplier > 1.00 for non-CONFIRM roles | **[BLOCKS INVESTIGATION]** |

---

### Category E — V1 Permission Authority

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-E-01 | DSN gate threshold unchanged | Family diversity threshold = documented baseline | Source read council_pre_ai_filter.mqh | Revert | **[BLOCKS PRODUCTION]** |
| PAC-E-02 | CRR gate logic unchanged | CRR logic matches documented baseline (role-check only; cross-family upgrade NOT activated unless Phase 4A authorized) | Source read | Revert | **[BLOCKS PRODUCTION]** |
| PAC-E-03 | HIGH_CONVICTION thresholds unchanged | consensus ≥ 0.75, familyCount ≥ 2, familyDiv ≥ 0.60, conflict ≤ 0.25 | Source read council_aggregator.mqh | Revert | **[BLOCKS PRODUCTION]** |
| PAC-E-04 | If Phase 4C gate included: only WAIT emitted, not REJECT | Quality soft gate emits COUNCIL_DECISION_WAIT only; never COUNCIL_DECISION_REJECT | Source read; live log sample | Fix gate | **[BLOCKS PRODUCTION]** |
| PAC-E-05 | If Phase 4B veto included: veto fires only in TC/BREAKOUT and correct direction | Veto scope: TC + BREAKOUT zones; exhaustion_direction ≠ dominant_side | Source read; live log sample | Fix veto scope | **[BLOCKS PRODUCTION]** |
| PAC-E-06 | NO_TRADE zone handling unchanged | COUNCIL_ZONE_NO_TRADE path unchanged; tradability thresholds unchanged | Source diff | Revert unauthorized changes | **[BLOCKS PRODUCTION]** |

---

### Category F — Risk / Execution Safety

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-F-01 | core_trade_engine.mqh unchanged | Zero changes to stop, TP, lot-sizing logic | Source diff | Revert | **[BLOCKS PRODUCTION]** |
| PAC-F-02 | Level Brake (level_awareness_brake.mqh) unchanged except LAB family registry fix | Only fvg_tpb family inference change; all gate logic unchanged | Source diff | Revert unauthorized changes | **[BLOCKS PRODUCTION]** |
| PAC-F-03 | gOperatingRiskEnvelope not weakened | Risk envelope thresholds unchanged from documented baseline | Source read + PIML risk section | Revert | **[BLOCKS PRODUCTION]** |
| PAC-F-04 | Operating cohort unchanged: {LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT} | Cohort family list matches documented baseline | Source read main_ea.mq5 OperatingCohortFamilyAllowed() | Revert | **[BLOCKS PRODUCTION]** |
| PAC-F-05 | IMBALANCE_FILL_REVERSAL not added to operating cohort | "IMBALANCE_FILL_REVERSAL" absent from OperatingCohortFamilyAllowed() | Source read main_ea.mq5 | Remove if present — CRITICAL | **[BLOCKS PRODUCTION]** |
| PAC-F-06 | No MQL5 runtime errors in ≥72h XAUUSD session | Zero array-out-of-bounds, zero divide, zero pointer, zero FileOpen errors in EA journal | EA journal log (72h window) | Investigate any error | **[BLOCKS PRODUCTION]** |
| PAC-F-07 | No abnormal termination attributable to delivery build changes | Only operator-stop terminations (error code 2 = operator close); no crash codes | EA journal log | Investigate crash | **[BLOCKS PRODUCTION]** |

---

### Category G — Strategy Registry

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-G-01 | COUNCIL_MAX_STRATEGIES = 18 | council_mode_types.mqh line defines 18 | Source read | Investigate mismatch | **[BLOCKS PRODUCTION]** |
| PAC-G-02 | All 18 strategies appear in ai_opportunity_summary.json | strategy_count = 18; all 18 IDs present | Summary file | Investigate missing strategy | **[BLOCKS PRODUCTION]** |
| PAC-G-03 | momentum_breakout_cont_v1 has vote_weight = 0.00 and decision = WAIT always | Source read council_strategies.mqh; live summary confirms 0 triggers/executions | Source + summary | Investigate if unfrozen | **[BLOCKS PRODUCTION]** |
| PAC-G-04 | registry_unknown_strategy_seen_count = 0 in summary | No UNKNOWN family inferences | ai_opportunity_summary.json | Investigate UNKNOWN; update LAB registry | **[BLOCKS PRODUCTION]** |
| PAC-G-05 | If Phase 5B+ gates included: each gate only affects declared hostile subset for declared strategy | Per-gate grep in council_strategies.mqh; ledger records show correct suppression | Source read + ledger | Fix gate scope | **[BLOCKS PRODUCTION]** |

---

### Category H — Playbook Registry

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-H-01 | Playbook IDs in live records match registry: RANGE_BOUNDARY_SWEEP_RECLAIM / TREND_PULLBACK_CONTINUATION / VOLATILITY_COMPRESSION_RELEASE / IMBALANCE_FILL_REVERSAL | All 4 IDs recognized; no UNKNOWN_PLAYBOOK in records | Ledger sample; source read OL_PrimaryPlaybookForStrategy() | Fix unregistered mapping | **[BLOCKS PRODUCTION]** |
| PAC-H-02 | PLAYBOOK_VALID never emitted for IMBALANCE_FILL_REVERSAL in any ledger record | IFR records: playbook_state ∈ {NOT_PRESENT, FORMING} only | ≥10 IFR ledger records (XAUUSD required) | Immediate investigation — CRITICAL | **[BLOCKS PRODUCTION]** |
| PAC-H-03 | PLAYBOOK_VALID for RBSR/TPC/VCR does not drive any execution decision | Cross-check final_decision vs playbook_state; no correlation | Ledger record analysis | Investigate authority leakage | **[BLOCKS PRODUCTION]** |
| PAC-H-04 | VCR playbook state = PLAYBOOK_NOT_PRESENT or PLAYBOOK_FORMING (no forced VALID without data) | VCR strategies: trigger_seen ≥ 0 (may be 0); no fabricated VALID | Ledger sample | Investigate | **[BLOCKS INVESTIGATION]** |

---

### Category I — FVG_TPB / IFR

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-I-01 | fvg_tpb first XAUUSD trigger: record appears in ledger | strategy_id="fvg_tpb" in ≥1 ledger record from XAUUSD session | ai_opportunity_ledger.jsonl | Investigate trigger logic | **[BLOCKS PRODUCTION]** |
| PAC-I-02 | fvg_tpb XAUUSD ledger record: json.loads() succeeds | Zero parse errors on fvg_tpb records | Python json.loads() on record | Fix JSON serialization | **[BLOCKS PRODUCTION]** |
| PAC-I-03 | fvg_tpb XAUUSD: playbook_id="IMBALANCE_FILL_REVERSAL" and playbook_state="PLAYBOOK_FORMING" | Exact field values confirmed | Ledger record | Fix IFR state assignment | **[BLOCKS PRODUCTION]** |
| PAC-I-04 | fvg_tpb XAUUSD: runtime_authority_status="NONE" | "NONE" confirmed in all fvg_tpb records | Ledger record | CRITICAL — investigate authority leakage | **[BLOCKS PRODUCTION]** |
| PAC-I-05 | fvg_tpb cohort blocking confirmed: no actual trade opened when fvg_tpb is best_strategy_id alone | actual_trade=false in all fvg_tpb-best records | Ledger + journal records | CRITICAL — investigate cohort gate | **[BLOCKS PRODUCTION]** |
| PAC-I-06 | ifr_state_seen_count in summary: only FORMING state seen | ifr_state_seen_count > 0 only for FORMING states | ai_opportunity_summary.json | Investigate if VALID or other non-FORMING states appear | **[BLOCKS PRODUCTION]** |

---

### Category J — best_strategy_id / Thesis Identity

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-J-01 | best_strategy_id not read by council_pre_ai_filter.mqh | Grep count = 0 for best_strategy_id in filter file | Grep output | Investigate read — authority leakage | **[BLOCKS PRODUCTION]** |
| PAC-J-02 | best_strategy_id not read by council_aggregator.mqh | Grep count = 0 | Grep output | Investigate | **[BLOCKS PRODUCTION]** |
| PAC-J-03 | Cohort family derived from best_strategy_id returns correct family for all 18 strategies | Test LAB_InferFamilyFromStrategyId for all 18 IDs; no UNKNOWN returns | Source read + registry_unknown=0 in summary | Fix LAB registry | **[BLOCKS PRODUCTION]** |
| PAC-J-04 | Cohort decision for fvg_tpb: IMBALANCE_FILL_REVERSAL not in cohort → blocked | Live XAUUSD: when fvg_tpb is best_strategy_id, execution is blocked; log shows candidateFamily="IMBALANCE_FILL_REVERSAL" + not_in_cohort | Live XAUUSD EA journal | Investigate cohort gate | **[BLOCKS PRODUCTION]** |

---

### Category K — V1C / Ledger / JSON

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-K-01 | schema_version in all post-cleanup records = "OL_V1C_PLAYBOOK_SHADOW" | Confirmed in ≥30 post-cleanup records | Ledger sample | Investigate schema version | **[BLOCKS PRODUCTION]** |
| PAC-K-02 | summary schema_version = "OL_SUMMARY_V1C_PLAYBOOK_SHADOW" | ai_opportunity_summary.json schema_version field | Summary file | Investigate | **[BLOCKS PRODUCTION]** |
| PAC-K-03 | All post-cleanup bollinger_reclaim records: packet_registry_status="RESEARCH_ONLY" | K3 confirmed in ≥5 bollinger_reclaim records | Ledger records | Investigate K3 fix | **[BLOCKS INVESTIGATION]** |
| PAC-K-04 | No double-comma JSON defects in ai_performance_journal.jsonl (P2.A closure maintained) | json.loads() succeeds on ≥20 post-delivery records | Python json.loads() batch | Fix provenance helper functions | **[BLOCKS PRODUCTION]** |
| PAC-K-05 | Ledger write-failures = 0 for all 18 strategies | write_failures=0 in summary for all strategies | ai_opportunity_summary.json | Investigate FileOpen/write failure | **[BLOCKS PRODUCTION]** |

---

### Category L — Runtime Stability

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-L-01 | EA loads clean on XAUUSD M5 | Terminal log: "expert main_ea (XAUUSD,M5) loaded successfully" | Terminal log | Debug load failure | **[BLOCKS PRODUCTION]** |
| PAC-L-02 | init() completes without errors | EA journal: governance/risk ready messages appear | EA journal | Debug init path | **[BLOCKS PRODUCTION]** |
| PAC-L-03 | ≥ 72 continuous hours without abnormal termination | Terminal log: no unintended termination codes | Terminal log | Investigate | **[BLOCKS PRODUCTION]** |
| PAC-L-04 | All 18 strategies appear in decision-cycle logs | active_strategies_count=18 in decision entries | EA journal | Investigate missing strategy | **[BLOCKS PRODUCTION]** |
| PAC-L-05 | MT5 Strategy Tester fixed-replay over 30 days XAUUSD M5 without crash | Tester completes 30-day window; 0 runtime errors in log | Strategy Tester log | Investigate crash | **[BLOCKS PRODUCTION]** |

---

### Category M — Trading Metrics

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-M-01 | Live/demo WR not below hard floor over first 15 completed trades | WR ≥ 30% (hard floor — signals execution failure, not just market conditions) | Performance journal W/L | Investigate execution quality | **[BLOCKS INVESTIGATION]** |
| PAC-M-02 | No single trade with loss > 3× expected stop distance | Loss per trade ≤ 3× ATR-based stop estimate | Performance journal MAE | Investigate execution | **[BLOCKS PRODUCTION]** |
| PAC-M-03 | Spread at execution ≤ 15pt for XAUUSD | Spread recorded at entry ≤ 15pt | Performance journal / broker data | Do not trade during wide spread conditions | **[BLOCKS INVESTIGATION]** |
| PAC-M-04 | No trade opened without a decision BUY/SELL in corresponding journal record | Every open trade has a paired DECISION record with final_decision ∈ {BUY, SELL} | Journal cross-reference | Investigate orphaned trade | **[BLOCKS PRODUCTION]** |

---

### Category N — Rollback / Recovery

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-N-01 | Final governed archive exists and is accessible | Archive file readable; unzip succeeds | Archive test | Re-create archive | **[BLOCKS PRODUCTION]** |
| PAC-N-02 | Archive contains council_mode_types.mqh at expected post-delivery size | File size matches live | Archive listing | Re-archive | **[BLOCKS PRODUCTION]** |
| PAC-N-03 | Pre-delivery (pre-FVG_TPB) clean archive exists | D:\MT5_Project_Backups\* — at least one pre-FVG_TPB zip present | Archive inventory | Document as missing; accept risk | **[BLOCKS INVESTIGATION]** |
| PAC-N-04 | Rollback procedure documented: steps to revert to pre-delivery binary | Written rollback procedure in handover package | Handover document | Document before production | **[BLOCKS PRODUCTION]** |

---

### Category O — Operator Handover

| ID | Check | Pass Criteria | Evidence Source | Fail Response | Severity |
|---|---|---|---|---|---|
| PAC-O-01 | This plan (DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1.md) exists and is current | File present; last modified ≤ 7 days before handover | File system | Update plan | **[BLOCKS PRODUCTION]** |
| PAC-O-02 | IRREW_PCEA_PENDING_WORK_STATUS_UPDATE_FAST_V1.md exists and is current | File present; reflects current package state | File system | Update status report | **[BLOCKS PRODUCTION]** |
| PAC-O-03 | Runtime Debt Ledger (Section 8 of this document) reviewed by operator | Operator confirms debts are understood and accepted | Operator sign-off | Complete review | **[BLOCKS PRODUCTION]** |
| PAC-O-04 | Operator grants explicit production transition approval | Written approval (email / session log) | Approval record | Do not transition | **[BLOCKS PRODUCTION]** |

---

## 10. Tester / Nautilus / Live Validation Split

### 10.1 What Each Method Can and Cannot Close

| Validation Method | Can Close | Cannot Close |
|---|---|---|
| **Nautilus replay (INEC_LAB_V1)** | Edge evidence questions (WR, E[R], regime breakdown per strategy); packet classification; strategy certification label; SPC hypothesis direction | MT5 EA runtime safety; JSON serialization integrity; MQL5 error-free operation; broker/live execution conditions |
| **MT5 Strategy Tester (fixed-replay, fixed parameters)** | EA code path coverage (all 18 strategies evaluated); JSON write logic; OL_V1C schema emission; crash/error absence across 30+ day window; stop/TP geometry; decision pipeline flow | Live broker spread/slippage; real fvg_tpb trigger in market context; live risk envelope behavior under real P&L |
| **MT5 Strategy Tester (optimization)** | Parameter sensitivity exploration (useful for research; not for acceptance) | Any acceptance criterion — optimization cannot close acceptance items; results are in-sample |
| **Live XAUUSD terminal** | fvg_tpb first trigger; fvg_/ifr_ serialization; hostile branch; XAUUSD-specific runtime stability; broker execution; real spread/slippage; IFR cohort blocking; Phase 5A gate suppression | Broad code path coverage (limited by market conditions); exhaustive error testing |
| **Ledger replay (post-session analysis)** | SPC hypothesis evaluation (after sufficient records); packet presence analysis; playbook state distribution; event order contract compliance | Runtime errors; execution safety; broker conditions |

### 10.2 Acceptance Gateway Mapping

| Acceptance category | Minimum validator | Additional validator |
|---|---|---|
| Build quality (compile, archive, diff) | Claude review + compile log | — |
| Authority boundary (grep checks) | Claude grep | — |
| No-score / score authority | Source read + Claude | — |
| Decision-path isolation | Grep + source read | Strategy Tester (logs) |
| EA runtime stability (crash-free) | MT5 Strategy Tester fixed-replay | Live XAUUSD ≥72h |
| FVG_TPB serialization | **Live XAUUSD only** | — (cannot substitute) |
| IFR state / PLAYBOOK_VALID suppression | **Live XAUUSD only** | — |
| Hostile branch behavior | **Live XAUUSD only** | — |
| Phase 5A suppression | Live XAUUSD + ledger analysis | — |
| Live WR threshold (hard floor) | Live XAUUSD ≥15 trades | — |
| Edge certification | Nautilus (INEC_LAB_V1) | — |
| SPC hypothesis evaluation | Ledger replay + Nautilus | — |

### 10.3 Important Clarifications

**Optimization may assist exploration, but fixed-parameter replay is required for acceptance.**
Optimization runs produce in-sample results that cannot substitute for fixed-parameter replay acceptance. Any optimization used for development research must be followed by a fixed-parameter tester run before the result is accepted as evidence.

**Nautilus can close evidence/edge questions but cannot close MT5 terminal runtime safety.**
A strategy's WR ≥ 40% in Nautilus proves edge evidence. It does not prove that the MQL5 EA correctly serializes JSON, handles array bounds, or survives 72 hours without crash on XAUUSD M5.

**MT5 Strategy Tester can close many EA runtime-path checks but not broker/live execution conditions.**
The Strategy Tester confirms code path stability. It cannot simulate live broker spread spikes, requotes, partial fills, or XAUUSD weekend gap behavior.

**Live XAUUSD confirmation remains required before production.**
Checklist items PAC-F-06, PAC-I-01 through PAC-I-06, PAC-L-01 through PAC-L-04, and PAC-M-01 through PAC-M-04 can only be closed by live XAUUSD terminal sessions. No substitute is accepted.

---

## 11. Investigation Reopen Rules

Any of the following events after development handover or during production acceptance MUST immediately reopen investigation for the affected item. Reopening is not optional.

| Event | Severity | Scope Reopened |
|---|---|---|
| Compile regression (any new error or new warning) | CRITICAL | Full package diff review |
| MT5 EA abnormal termination not attributable to operator stop | CRITICAL | Session log analysis; all packages in delivery build |
| JSON corruption in ai_opportunity_ledger.jsonl or ai_performance_journal.jsonl | CRITICAL | Serialization path review; P2.A history |
| PLAYBOOK_VALID emitted for IMBALANCE_FILL_REVERSAL | CRITICAL — ARCHITECTURE_TRACK_BLOCKED_BY_AUTHORITY_LEAKAGE | IFR state assignment code path |
| runtime_authority_status ≠ "NONE" in any record | CRITICAL — ARCHITECTURE_TRACK_BLOCKED_BY_AUTHORITY_LEAKAGE | OL_RuntimeAuthorityStatus() + full pipeline review |
| fvg_tpb trade executed (actual_trade=true in ledger) | CRITICAL | Cohort gate path; Level Brake; main_ea.mq5 |
| Score authority regression (any score value driving REJECT/WAIT in V1 filter) | CRITICAL | council_pre_ai_filter.mqh + authority_stack_pilot.mqh + hard-lock |
| best_strategy_id used directly as execution permission (e.g., read by filter or engine) | CRITICAL | council_pre_ai_filter.mqh grep; main_ea.mq5 grep |
| Cohort family inference returns UNKNOWN for any registered strategy | HIGH | LAB_InferFamilyFromStrategyId() registry |
| IMBALANCE_FILL_REVERSAL added to operating cohort | CRITICAL | main_ea.mq5 OperatingCohortFamilyAllowed() |
| CRR or DSN gate thresholds changed without explicit Phase 4A authorization | HIGH | council_pre_ai_filter.mqh diff |
| HIGH_CONVICTION thresholds changed without explicit authorization | HIGH | council_aggregator.mqh diff |
| Risk/execution abnormality (loss > 3× stop on any trade) | HIGH | Performance journal + core_trade_engine.mqh |
| MQL5 array-out-of-bounds in EA journal | HIGH | Identify source file and line |
| council_quality bonus from playbook/packet state | HIGH | council_aggregator.mqh |
| Phase 4A/4B/4C activation without operator authorization | HIGH | Source diff + filter review |
| Live WR ≤ 30% over 20 consecutive completed trades | MEDIUM | Strategy performance analysis; regime breakdown |
| Spread at execution > 15pt more than 20% of trades | MEDIUM | Broker conditions review; consider off-session restriction |
| Nautilus result contradicts accepted cert label by > 5pp WR | MEDIUM | INEC_LAB_V1 replay re-run; cert re-classification |
| Unexplained abnormal termination (not operator stop) | HIGH | Full journal review |
| write_failures > 0 in opportunity_summary.json | HIGH | FileOpen path review |

---

## 12. Recommended Execution Sequence

### Stage 1 — Complete Source / Design Backlog (Engineering Completion)

**Target:** Resolve all REQUIRED_BEFORE_DEV_COMPLETE items. No runtime evidence required for these steps.

| Step | Action | Owner | Est. Complexity |
|---|---|---|---|
| 1.1 | Execute SOURCE_READ_REQUIRED_RESOLUTION_V1: targeted reads of council_ai_governor.mqh, council_pre_ai_filter.mqh, authority_stack_pilot.mqh, PIML No-Score section, EQ-DIAG status | Claude | LOW |
| 1.2 | Based on 1.1: classify each SRR item as DONE, SMALL_PACKAGE_NEEDED, or DEFERRED | Claude | LOW |
| 1.3 | For each SMALL_PACKAGE_NEEDED: execute as bounded Codex task (scope ≤ 2 files, 0 authority change) | Codex | LOW-MEDIUM |
| 1.4 | Confirm No-Score A2 status (verify pre-AI score gate demoted or document as N/A) | Claude + Codex | LOW |
| 1.5 | Confirm Stage D Governor status (categorical redesign done or N/A) | Claude | LOW |
| 1.6 | Confirm EQ-DIAG fields status (implemented or formally defer) | Claude | LOW |
| 1.7 | If any behavior-changing candidates (BC-01 through BC-04) are authorized by operator: implement via bounded Codex tasks one at a time | Codex | MEDIUM |
| 1.8 | Create MASTER_DEVELOPMENT_CLOSURE_BACKLOG_V1 if step 1.1–1.6 reveals additional packages | Claude | LOW |
| 1.9 | Create final governed archive at DEVELOPMENT_COMPLETE state | Claude / Operator | LOW |
| 1.10 | Produce DEVELOPMENT_COMPLETE_HANDOVER_PACKAGE_V1 (this plan + debt ledger + archive path + binary timestamp) | Claude | LOW |

### Stage 2 — Compile and Adversarial Review

**Target:** Final binary at DEVELOPMENT_COMPLETE state passes all static checks.

| Step | Action | Owner |
|---|---|---|
| 2.1 | Final compile of all packages; confirm 0 errors / 0 warnings (or documented pre-existing warnings) | Codex |
| 2.2 | Grep verification: zero playbook/packet/fvg_/ifr_ reads in council_aggregator, council_pre_ai_filter, council_ai_governor, core_trade_engine, main_ea | Claude |
| 2.3 | Source diff against declared baseline: confirm all changes are declared in package scope | Claude |
| 2.4 | Score authority hard-lock confirmation: council_mode_runtime.mqh hard-lock verified | Claude |
| 2.5 | Cohort gate confirmation: IMBALANCE_FILL_REVERSAL absent from OperatingCohortFamilyAllowed | Claude |
| 2.6 | Run PAC-A-01 through PAC-E-06 statically (source read checks) | Claude |
| 2.7 | Document compile log file and binary timestamp in handover | Claude |

### Stage 3 — MT5 Strategy Tester Fixed Replay

**Target:** 30-day XAUUSD M5 crash-free replay; code paths exercised; JSON writes verified.

| Step | Action | Owner |
|---|---|---|
| 3.1 | Load delivery binary in MT5 Strategy Tester on XAUUSD M5 | Operator |
| 3.2 | Fixed parameters; 30-day window; every-tick mode or OHLC mode | Operator |
| 3.3 | Review tester log for MQL5 errors, crashes, JSON failures | Claude |
| 3.4 | Confirm all 18 strategies appear in tester outputs | Claude |
| 3.5 | Sample tester-generated ledger records for schema and parse validity | Claude |
| 3.6 | Run PAC-L-05 and PAC-B-01 through PAC-B-05 from tester evidence | Claude |

### Stage 4 — Nautilus / Ledger Replay (Where Needed)

**Target:** Close any SRR cert gaps or SPC analysis questions.

| Step | Action | Owner |
|---|---|---|
| 4.1 | Run remaining Nautilus certifications if any behavior-changing package requires edge evidence (e.g., Phase 5B+ gate authorization) | INEC_LAB_V1 |
| 4.2 | Run RCEM_V1_DOCUMENTATION_UPDATE if 8th cert threshold is met | Claude |
| 4.3 | Ledger replay of accumulated V1C records for SPC-001 if ≥50 executed outcomes exist | Claude + INEC_LAB_V1 |

### Stage 5 — Handover as DEVELOPMENT_COMPLETE / PRODUCTION_CANDIDATE_BUILD

**Target:** Formal handover to production acceptance phase.

| Step | Action | Owner |
|---|---|---|
| 5.1 | Operator reviews DEVELOPMENT_COMPLETE_HANDOVER_PACKAGE_V1 | Operator |
| 5.2 | Operator acknowledges runtime debt ledger | Operator |
| 5.3 | Operator formally approves DEVELOPMENT_COMPLETE designation | Operator |
| 5.4 | System is labeled: DEVELOPMENT_COMPLETE / PRODUCTION_CANDIDATE_BUILD | Both |
| 5.5 | Production acceptance phase begins | Operator |

### Stage 6 — Production Acceptance Checklist on Live/Demo XAUUSD

**Target:** All PAC items pass; runtime debts cleared.

| Step | Action | Owner |
|---|---|---|
| 6.1 | Load delivery binary on XAUUSD M5 live/demo terminal | Operator |
| 6.2 | Run ≥72h continuous XAUUSD session | Operator |
| 6.3 | Execute all PAC categories A through O | Claude + Operator |
| 6.4 | Wait for first fvg_tpb trigger on XAUUSD; validate PAC-I-01 through PAC-I-06 | Claude |
| 6.5 | Accumulate ≥15 completed trades; validate PAC-M-01 through PAC-M-04 | Operator |
| 6.6 | Validate Phase 5A gate if SELL_TREND_UP conditions occur | Claude |
| 6.7 | Document all PAC item outcomes | Claude |

### Stage 7 — Production-Ready Decision or Reopen Investigation

| Outcome | Action |
|---|---|
| All PAC items PASS | Operator grants production transition approval; PRODUCTION_READY declared |
| Any [BLOCKS PRODUCTION] item FAILS | Reopen investigation for that item; fix; re-validate that item; other PAC items retain PASS status |
| Any [BLOCKS INVESTIGATION] item FAILS | Reopen investigation for that item; production transition may proceed after operator reviews risk |
| 3+ [BLOCKS PRODUCTION] items FAIL | Full architecture review before any production transition |

---

## 13. Recommended Immediate Next Action

**The immediate next action depends on operator priority:**

### Option A: Validate First, Then Close Development (Lower Risk)

Execute `XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1` now (read-only observation). This closes the largest single unknown (FVG_TPB XAUUSD runtime) before any further development packages. If PAC-I-01 through PAC-I-06 pass during this session, they are pre-cleared before development closure, reducing the production acceptance burden.

**Recommended if:** The operator wants to reduce production acceptance risk and the XAUUSD market is open or opening soon.

### Option B: Source Resolution First, Then Validate (Higher Velocity)

Execute `SOURCE_READ_REQUIRED_RESOLUTION_V1` now: read council_ai_governor.mqh, council_pre_ai_filter.mqh (No-Score A2), authority_stack_pilot.mqh, PIML No-Score section, and EQ-DIAG status in a targeted session. This immediately reclassifies the 9 SOURCE_READ_REQUIRED items from the status survey into either DONE, SMALL_PACKAGE, or DEFERRED, allowing the development backlog to be finalized.

**Recommended if:** The operator wants to establish the complete development backlog before any live session, and wants to know the full scope of remaining work first.

### Recommendation: Option B First, Then Option A

Execute source resolution first (Option B) — it is bounded, fast (targeted reads of 4–5 files), and defines the full development backlog. Once the backlog is defined, any remaining bounded packages can be compiled, and then the XAUUSD validation session (Option A) runs against the final development-complete binary rather than an intermediate one.

**Sequence:**
1. SOURCE_READ_REQUIRED_RESOLUTION_V1 (1–2 sessions; no source change)
2. MASTER_DEVELOPMENT_CLOSURE_BACKLOG_V1 (document the full remaining work)
3. Any small bounded packages arising from step 1 (compile each)
4. FINAL_GOVERNED_ARCHIVE_V1
5. XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1 (first major production acceptance step)

---

## 14. Final Recommendation

```
APPROVE_ENGINEERING_COMPLETION_MODE_WITH_RUNTIME_DEBT_LEDGER
```

**Why this recommendation:**

1. **The architecture is sound and the firewall is live.** V1 is the permission authority. Risk is the protection authority. Execution is survivability authority. Attribution is learning authority. These boundaries are enforced in source and confirmed in runtime. Development can proceed to completion without endangering the permission structure.

2. **The runtime loop cannot resolve itself without live XAUUSD market time.** Waiting for runtime evidence after every individual package means development velocity is gated entirely by live market exposure rate. This is not an acceptable development posture for a system where many packages have negligible runtime risk (documentation, SRR resolution, small semantic fixes).

3. **The two-stage doctrine protects production readiness without blocking development.** Development completion is defined by the build quality and the handover package. Production readiness is defined by the acceptance checklist. These are structurally separate. No production transition can bypass the checklist.

4. **Behavior-changing changes are restricted to architecturally-required items.** The doctrine does not authorize open-ended experimentation. Each behavior-changing change (BC-01 through BC-04) requires separate operator authorization and is explicitly named in the production checklist.

5. **The Runtime Debt Ledger makes the risk explicit and auditable.** Every known unvalidated item is documented with pass/fail criteria and fail actions. The operator receives this ledger at handover and acknowledges it. No item is hidden.

6. **Investigation reopen rules prevent drift after handover.** Any critical failure reopens the relevant investigation automatically. The checklist is not a one-time gate that can be circumvented — it is a structured, item-by-item accountability mechanism.

**What this recommendation does NOT authorize:**

- Skipping production acceptance checklist
- Deploying before PAC-I-01 through PAC-I-06 (FVG_TPB XAUUSD) pass
- Removing any item from the Runtime Debt Ledger without resolution
- Treating DEVELOPMENT_COMPLETE as equivalent to PRODUCTION_READY

---

```
PLAN_ID:                     DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1
DATE:                        2026-05-09
GOVERNANCE_LABEL:            ENGINEERING_COMPLETION_MODE_WITH_PRODUCTION_ACCEPTANCE_CHECKLIST
FINAL_RECOMMENDATION:        APPROVE_ENGINEERING_COMPLETION_MODE_WITH_RUNTIME_DEBT_LEDGER
SOURCE_CHANGED:              NO
COMPILE_RUN:                 NO
RELOAD_PERFORMED:            NO
SYSTEM_STATUS:               DEVELOPING
DEV_COMPLETE_STATUS:         NOT_YET_DECLARED — source resolution and backlog definition required first
PRODUCTION_READY_STATUS:     NOT_CLAIMED — acceptance checklist not yet executed
IMMEDIATE_NEXT_ACTION:       SOURCE_READ_REQUIRED_RESOLUTION_V1 → MASTER_DEVELOPMENT_CLOSURE_BACKLOG_V1
RUNTIME_DEBT_ITEMS:          13 (RDL-001 through RDL-013)
PAC_ITEMS_TOTAL:             57 items across 15 categories (A–O)
BEHAVIOR_CHANGE_CANDIDATES:  4 (BC-01 through BC-04) — none authorized by this plan
FORBIDDEN_ITEMS:             20 categories explicitly confirmed forbidden
AUTHORITY_STATUS:            V1 (MT5 EA) — permanent runtime authority; no transfer
PIML_UPDATE_REQUIRED:        NO — unless operator requests formal adoption
```
