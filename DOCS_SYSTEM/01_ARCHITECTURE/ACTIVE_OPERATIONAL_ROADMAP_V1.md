# ACTIVE_OPERATIONAL_ROADMAP_V1

**Date:** 2026-05-12
**Mission type:** Project roadmap reorder and state correction
**System status:** DEVELOPING
**Production Ready:** FALSE
**Authority:** MT5 remains sole runtime authority. No source changes. No compile. No MT5 reload. No Codex. No merge.

---

## A. Executive Verdict

```
ACTIVE_OPERATIONAL_ROADMAP_CREATED_PENDING_DOCS_BRANCH_COMMIT
```

This document consolidates the fragmented task landscape into a single ordered operational
sequence. Key corrections applied:

1. **TTM Squeeze stale recommendation corrected:** TTM_SQUEEZE_VCR_INEC_V1 completed INEC
   and was classified `RESEARCH_ONLY_PACKET`. Gate 2 is NOT AUTHORIZED. Any prior
   recommendation to "authorize Gate 2 for TTM Squeeze" is stale and has been superseded.

2. **actual_trade=0 / confirm_role_present=false elevated:** This is the top functional
   trading blocker. It requires investigation and diagnosis before any other trading path
   is meaningful.

3. **SIOL implementation not authorized:** SIOL design is complete (architecture document
   created). SIOL Phase 1 offline scanner is a future option pending operator confirmation.
   No runtime authority.

4. **NR7 shadow validated small-N:** Runtime field confirmed in OL. Live influence still
   NOT authorized. No stop override. No OCO.

5. **Git/docs hygiene:** PIML and DOCS_SYSTEM docs must not be committed on the
   source branch (`split/source-before-gemini-worker-policy`). Route through `main`.

---

## B. Corrected Priority Order

### Priority 0 — Git/Docs Hygiene

Ensure runtime review docs, PIML updates, and this roadmap are not committed to the
source branch. If currently untracked on source branch, route to `main` via separate
docs worktree or direct main-branch commit.

**Rules:**
- Do not use `git add .` or `git add -A`
- Do not commit `main_ea.ex5` or `.claude/settings.local.json`
- Docs/PIML belong on `main`; source changes belong on `split/source-before-gemini-worker-policy`

**Current state:** PIML, DOCS_SYSTEM_INDEX, runtime review report, and this roadmap are
all untracked on the source branch. Commit them to `main`.

---

### Priority 1 — Runtime Stability and NR7 Shadow Proof

**Goal:** Confirm NR7 shadow runtime instrumentation is correct across a meaningful sample.

**Target:** ≥30 post-reload OL records containing `nr7_shadow_state`

**Current:** 3/30 (all NONE — valid for RMR zone, short 49-min window)

**Required validations:**
- All 5 enum values observed at least once (NONE, RAW, ATR_FILTERED, SERIES, FILTERED_SERIES)
- No runtime errors from the NR7 computation path
- No behavior change: baseline_decision=final_decision across records
- No IRREW dev flags accidentally enabled

**Trigger to advance:** 30 post-reload OL records accumulated.

**Owner:** MT5 runtime (passive accumulation), Claude (analysis when threshold met)

---

### Priority 2 — Investigate actual_trade=0 / confirm_role_present=false

**Goal:** Produce a diagnosis of why every OL record has actual_trade=false.

**Current state:** 57/57 OL records — actual_trade=false. confirm_role_present=false
in every council report. The Pre-AI filter rejects on "Confirmation role missing" in
all observed sessions.

**Investigation questions (read-only, no changes):**

1. Is `confirm_role_present=false` the intended behavior under O3_FIRST_OPERATING_COHORT_V1
   (FAMILY_LEVEL admission — LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION,
   COMPRESSION_BREAKOUT) given current market regime?

2. Which strategy role would satisfy `confirm_role_present=true`? Is any current strategy
   designated as a CONFIRM role in the ACTIVE cohort?

3. Is this a configuration issue (cohort families lack CONFIRM-role strategies) or an
   evidence gap (CONFIRM strategies not triggering)?

4. Does the council architecture require a strategy with `role_name=CONFIRM` AND
   `trigger_present=YES` to set `confirm_role_present=true`?

5. In the current OL window, which strategies fire `trigger_present=YES`?
   (Answer: mfi_reversal_assist [role=EXHAUSTION_JUDGE], trend_momentum [role=TREND_JUDGE],
   fvg_tpb [role=SCOUT] — NONE are role=CONFIRM)

**Working hypothesis:** No strategy with role=CONFIRM is firing in observed sessions.
mfi_reversal_assist (EXHAUSTION_JUDGE), trend_momentum (TREND_JUDGE/OBSERVE_ONLY),
and fvg_tpb (SCOUT) are the only trigger-present strategies — none satisfy CONFIRM.
Strategies with role=CONFIRM (bollinger_reclaim, mean_reversion_bounce, range_edge_fade,
TPC, micro_structure_reentry) are not triggering.

**Do not patch. Produce diagnosis only.**

**Owner:** Claude (investigation)

---

### Priority 3 — Confirmation Packet Gap Resolution

**Goal:** Identify what can realistically serve as a CONFIRMATION_PACKET to unblock
execution without artificial or weak confirmation.

**Constraints:**
- Do NOT reuse TTM Squeeze (`TTM_SQUEEZE_VCR_INEC_RESEARCH_ONLY` — rejected)
- Must materially improve WR lift ≥+2pp AND E[R] lift ≥+0.04R when co-present
- Must be OHLCV-expressible
- Must fit existing playbook architecture

**Existing candidates to review:**

| Candidate | Status | Notes |
|---|---|---|
| trend_pullback_cont_v1 (TPC) | REDUCED / OBSERVE_ONLY in non-TC | Low co-presence rate (1.4% with trend_momentum in TC zone). Needs ≥5 TC-zone firings. |
| fvg_tpb | thesis/advisory active, OUTSIDE O3 cohort | IMBALANCE_FILL_REVERSAL family. Has CRR blocking. Needs admission review. |
| mfi_reversal_assist | ~3–4 readings, Phase 4B | Role=EXHAUSTION_JUDGE (not CONFIRM). Would need role reclassification or different integration. |
| NR7 context | Not a strategy slot — observability only | Could serve as LOCATION_PACKET co-presence, not direct CONFIRM |
| New external search | Not authorized yet | Requires GEMINI delegated research restart with new gap framing |
| bollinger_reclaim | role=CONFIRM, trigger_present=NO | Not firing in observed sessions. Needs trigger condition review. |

**No implementation authorized.** Research and diagnosis only.

**Owner:** Claude (review) + Operator (authorization)

---

### Priority 4 — Runtime Evidence Accumulation

**Goal:** Passive accumulation of OL records, strategy firings, and shadow state data.

**Thresholds to track:**

| Milestone | Current | Target | Gap |
|---|---|---|---|
| OL records total | 57 | ≥200 (Phase 4C first review) | 143 |
| OL records total | 57 | ≥500 (RCEM review) | 443 |
| Post-reload NR7 shadow records | 3 | ≥30 (schema proof) | 27 |
| NR7-context records (non-NONE) | 0 | ≥20 (Gate 3A1 prerequisite) | 20 |
| Actual trades in OL | 0 | ≥1 (unblocks Gate 3A1 start) | 1 |
| MFI readings | ~3–4 | ≥5 (Phase 4B prerequisite) | 1–2 |
| TPC firings in TC zone | sparse | ≥5 (Phase 4A prerequisite) | ~5 |
| NR7 non-NONE states observed | 0 | all 4 observed at least once | 4 |

**Owner:** MT5 runtime (passive), Claude (tracking when milestones hit)

---

### Priority 5 — SIOL Phase 1 Offline Scanner

**Goal:** Build and run an offline Python scanner to produce a system intelligence
snapshot from existing OL/PJ/status JSON files.

**Current state:** DESIGN_COMPLETE — architecture document created (pending repository
persistence). Implementation: NOT_AUTHORIZED.

**Scope when authorized:**
- Read OL JSONL, PJ JSONL, runtime status JSON files (read-only)
- No MT5 IO, no source changes, no compile
- Produce: `system_intelligence_snapshot.json`, `system_intelligence_report.md`,
  `readiness_gate_state.json`
- Output to `nautilus_lab/outputs/`

**Blocked by:** Operator authorization.

**Owner:** Operator (authorization) → Codex (implementation if authorized)

---

### Priority 6 — Phase-Specific Reviews

Re-open ONLY when thresholds are met. Do not attempt prematurely.

| Phase | Prerequisite | Current State | Action When Ready |
|---|---|---|---|
| Phase 4B (MFI exhaustion veto) | MFI ≥5 readings, then ≥30 warning events | ~3–4/5 readings | Reopen analysis after next 2 MFI fires |
| Phase 4C (RCEM first look) | OL ≥200 records | 57/200 | Track passively |
| Phase 4A (TPC cross-family CRR) | TPC ≥5 firings in TC zone | sparse | Track passively |
| RCEM (Regime-Correlated Execution Model) | OL ≥500 records | 57/500 | Long-term |
| ExecutionGeometry | room_state / stop_geometry_state ≠ UNKNOWN; enough outcomes | All UNKNOWN | Deferred |
| PlaybookAdvisory | Playbook states stabilize, actual trades present | Below PLAYBOOK_VALID | Deferred |

---

### Priority 7 — NR7 Promotion Review

**Conditions before review:**
- ≥30 post-shadow OL records (schema proof, in progress)
- ≥20 NR7-context records (non-NONE states observed)
- ≥1 actual trade outcome in OL
- Attribution shows lift (offline analysis at Gate 3A0/3B level)

**If conditions met — review path:**
1. Run Gate 3A0 offline attribution (nautilus_lab scripts)
2. Assess stop geometry counterfactual (Gate 3B)
3. Consider LOCATION_PACKET advisory (advisory read-only, no live trade influence)
4. Do NOT proceed to: live stop override, OCO alpha trigger, or risk/execution changes

**What is NOT authorized regardless of evidence:**
- Live stop geometry override
- OCO pending order module
- ALPHA_TRIGGER_PACKET live influence
- NR7 as execution authority

**Owner:** Claude (attribution analysis) + Operator (any promotion gate authorization)

---

### Priority 8 — Live Influence (Deferred)

Not in scope until all lower priorities have produced evidence. Requires separate
gate authorization from operator. Includes:

- Advisory influence on execution (read-only shadow advice)
- Live stop geometry override (core_trade_engine.mqh changes)
- OCO alpha trigger (new pending order infrastructure)
- Any risk or execution authority changes

**Owner:** Operator (gate authorization required before any work begins)

---

## C. Active Blocker List

| # | Blocker | Type | Priority to Address |
|---|---|---|---|
| 1 | actual_trade=true=0 — confirm_role_present=false | FUNCTIONAL_TRADING_BLOCKER | P2 |
| 2 | No CONFIRMATION_PACKET certified | ARCHITECTURAL_GAP | P3 |
| 3 | TTM Squeeze RESEARCH_ONLY — VCR gap still open | STRATEGY_GAP | P3 |
| 4 | Playbook shadow fields absent from OL schema | OBSERVABILITY_ANOMALY | Deferred |
| 5 | event_order_valid=false — no LOCATION/TIMING packet | OBSERVABILITY_ANOMALY | P7 (after evidence) |
| 6 | PJ buffer stall (buffered=6, flushed=0) | IO_ANOMALY_NON_BLOCKING | Track only |
| 7 | NR7 non-NONE states not yet observed | EVIDENCE_GAP | P1/P4 |
| 8 | Docs/PIML untracked on source branch | GIT_HYGIENE | P0 |

---

## D. Full Task Table

| Task | Priority | Current Status | Blocker | Trigger to Reopen | Owner Layer | Next Action |
|---|---|---|---|---|---|---|
| Commit PIML/DOCS to main branch | P0 | PENDING_COMMIT | On source branch | Now | Git layer | Route to main via docs worktree |
| Correct stale TTM recommendation in all reports | P0 | IN_PROGRESS | None | Now | Claude | Verify all corrections applied |
| Run main_ea; accumulate 30 post-NR7 OL records | P1 | 3/30 | None (passive) | EA restart | MT5 runtime | Reload EA and observe |
| Validate NR7 non-NONE states (4 enum values) | P1 | 0/4 observed | Insufficient runtime | More OL records | MT5 runtime + Claude | Watch future OL records |
| Confirm IRREW flags clean over ≥30 records | P1 | PASS so far (3 records) | None | More records | MT5 runtime | Passive |
| Diagnose actual_trade=0 root cause | P2 | OPEN_INVESTIGATION | No diagnosis yet | Now (read-only) | Claude | Read council source for CONFIRM role logic |
| Identify CONFIRM-role strategy trigger conditions | P2 | UNKNOWN | No investigation | Now (read-only) | Claude | Review bollinger_reclaim trigger logic |
| Review TPC co-presence for CONFIRMATION_PACKET | P3 | SPARSE (1.4% co-presence) | TPC ≥5 firings in TC | TC firings accumulate | Claude | Track passively |
| Review fvg_tpb for confirmation role | P3 | OUTSIDE_O3_COHORT | Admission review | Operator review | Claude + Operator | Assess admission feasibility |
| Review bollinger_reclaim trigger conditions | P3 | NOT_FIRING | Unknown trigger gap | Diagnosis from P2 | Claude | Part of P2 investigation |
| Accumulate OL to ≥200 records | P4 | 57/200 | None (passive) | EA running | MT5 runtime | Passive accumulation |
| Accumulate OL to ≥500 records (RCEM) | P4 | 57/500 | None (passive) | EA running | MT5 runtime | Long-term passive |
| Track MFI readings toward ≥5 | P4 | ~3–4/5 | None | Next MFI fires | MT5 runtime + Claude | ~1–2 more firings needed |
| Track TPC firings in TC zone | P4 | sparse | None | TC regime appearance | MT5 runtime | Passive |
| SIOL Phase 1 offline scanner implementation | P5 | DESIGN_COMPLETE_IMPL_NOT_AUTH | Operator authorization | Operator confirms | Operator | Await confirmation |
| Phase 4B MFI exhaustion veto review | P6 | BLOCKED (3–4/5 readings) | MFI ≥5 then ≥30 events | MFI threshold met | Claude | Reopen after threshold |
| Phase 4C RCEM first review | P6 | BLOCKED (57/200 OL) | OL ≥200 | OL count met | Claude | Reopen when ≥200 |
| Phase 4A TPC cross-family CRR | P6 | BLOCKED (sparse TPC) | TPC ≥5 in TC zone | TPC threshold met | Claude | Reopen when ≥5 |
| RCEM full review | P6 | BLOCKED (57/500 OL) | OL ≥500 | OL count met | Claude | Long-term |
| ExecutionGeometry analysis | P6 | BLOCKED (all UNKNOWN) | room/stop fields populated + outcomes | Fields populated | SIOL future layer + Claude | Deferred |
| PlaybookAdvisory | P6 | BLOCKED (below PLAYBOOK_VALID) | Playbook thresholds met | Playbook evidence | Claude | Deferred |
| NR7 Gate 3A0 offline attribution re-run | P7 | DEFERRED | ≥30 post-shadow OL + actual trades | P1+P4 thresholds met | Claude | Rerun when N sufficient |
| NR7 Gate 3B stop counterfactual | P7 | DEFERRED | MAE data in PJ V3 schema | PJ V3 activated | Claude | Deferred |
| NR7 Gate 3A1 (nr7_active OL bool) | P7 | DEFERRED | ≥20 NR7-context + actual trades + Gate 3A0 results | All prerequisites met | Operator + Claude | Deferred |
| Advisory influence design | P8 | NOT_AUTHORIZED | All P1–P7 evidence first | Operator gate authorization | Operator | Deferred |
| Live stop geometry override | P8 | NOT_AUTHORIZED | Gate 3B MAE evidence | Operator gate authorization | Operator | Deferred |
| OCO alpha trigger module | P8 | NOT_AUTHORIZED | OCO infrastructure design + Gate authorization | Operator gate authorization | Operator | Deferred |

---

## E. Threshold Table

| Metric | Current | Required | Gap | Action When Met |
|---|---|---|---|---|
| Post-NR7 OL records | 3 | ≥30 | 27 | P1 complete; run Gate 3A0 re-analysis |
| OL records total | 57 | ≥200 | 143 | Open Phase 4C first review |
| OL records total | 57 | ≥500 | 443 | Open RCEM full review |
| NR7-context records (non-NONE) | 0 | ≥20 | 20 | Enable Gate 3A1 prerequisite check |
| Actual trades in OL | 0 | ≥1 | 1 | Unblocks Gate 3A1 start; unblocks most Phase 4 reviews |
| MFI readings | ~3–4 | ≥5 | 1–2 | Open Phase 4B review |
| TPC firings in TC zone | sparse | ≥5 | ~5 | Open Phase 4A cross-family CRR |
| NR7 enum values observed | 0/4 non-NONE | all 4 | 4 | P1 full validation complete |
| CONFIRMATION_PACKET certified | 0 | ≥1 | 1 | Unblocks confirm_role_present; enables actual trades |
| Playbook RBSR WR lift | below threshold | ≥+2pp lift AND ≥+0.04R | open | Unblocks PLAYBOOK_VALID for RBSR |
| council_memory executed_records | 0 | ≥1 | 1 | Enables council learning loop |

---

## F. What This Document Does NOT Authorize

- No source file changes (no .mqh, no .mq5 edits)
- No compile
- No MT5 reload
- No Codex implementation tasks
- No runtime file modification
- No IRREW dev flag activation
- No live NR7 influence (stop geometry, OCO, advisory)
- No Production Ready claim
- No SIOL implementation (design only)
- No branch merge

---

## G. Git/Docs Workflow Note

Files produced in this session (all untracked on `split/source-before-gemini-worker-policy`):

| File | Destination Branch | Status |
|---|---|---|
| `DOCS_SYSTEM/01_ARCHITECTURE/ACTIVE_OPERATIONAL_ROADMAP_V1.md` | `main` | CREATED — needs commit |
| `DOCS_SYSTEM/03_RUNTIME_VALIDATION/FULL_DAY_RUNTIME_EVIDENCE_REVIEW_AND_STATE_UPDATE_V1.md` | `main` | CREATED — needs commit |
| `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | `main` | UPDATED — needs commit |
| `DOCS_SYSTEM/DOCS_SYSTEM_INDEX.md` | `main` | UPDATED — needs commit |

Do NOT commit any of these to `split/source-before-gemini-worker-policy`.
Do NOT include `main_ea.ex5`, `.claude/settings.local.json`, or any `.bak_*` files.

---

```
ROADMAP_ID:                 ACTIVE_OPERATIONAL_ROADMAP_V1
DATE:                       2026-05-12
SYSTEM_STATUS:              DEVELOPING
PRODUCTION_READY:           FALSE
TOP_BLOCKER:                actual_trade=true=0 / confirm_role_present=false (P2)
TTM_STATUS:                 RESEARCH_ONLY_PACKET — Gate 2 NOT AUTHORIZED (stale recs corrected)
NR7_STATUS:                 SHADOW_RUNTIME_VALIDATED_SMALL_N — live influence NOT authorized
SIOL_STATUS:                DESIGN_COMPLETE — implementation NOT authorized
OL_RECORDS:                 57 (all actual_trade=false)
ACTIVE_ANOMALIES:           3
SOURCE_CHANGED:             NO
COMPILE_RUN:                NO
MT5_RELOAD:                 NO
VERDICT:                    ACTIVE_OPERATIONAL_ROADMAP_CREATED_PENDING_DOCS_BRANCH_COMMIT
```
