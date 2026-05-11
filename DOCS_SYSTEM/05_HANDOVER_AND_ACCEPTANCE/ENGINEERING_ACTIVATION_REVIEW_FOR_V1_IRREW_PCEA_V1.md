# ENGINEERING_ACTIVATION_REVIEW_FOR_V1_IRREW_PCEA_V1

**Review Type:** Architecture-to-implementation activation review
**Authority:** Engineering Completion Mode (approved)
**Management Decision:** APPROVE_ENGINEERING_COMPLETION_MODE
**Management Directive:** Controlled Activation is accepted. Controlled Inaction is not accepted.
**Date:** 2026-05-09
**System Status at Review:** DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING

---

## A. Executive Verdict

The build is correctly at DEVELOPMENT_COMPLETE. The activation review confirms:

1. **No components were incorrectly deactivated.** Everything that should be live is live.
2. **Risk State Policy Engine is LIVE and ENFORCED.** Previously listed as "consumption in live path unclear." Source read confirms `block_new_trades → OperatingEnvelopeSetBlock → return` at `main_ea.mq5:L2720-2727`. This is a positive finding — not a defect.
3. **Phase 4A/4B/4C remain genuinely blocked** — not over-deferral. Real evidence dependencies confirmed by engineering analysis (TPC fire rate risk, MFI calibration, OL auditability sequencing).
4. **RCEM is documentation-only.** Zone_type routing only in source; no regime_label matrix. This is not a dev-complete defect — the evidence base to populate a regime matrix does not yet exist.
5. **Failure Detector is correctly advisory-only via governor.** Direct enforcement promotion would introduce uncalibrated false negatives. Advisory mode is correct for current evidence level.
6. **Six components confirmed ALREADY_ACTIVE** with no activation gap.
7. **Four components confirmed RUNTIME_DEBT** — correctly deferred; each has a clear, non-arbitrary unblock condition.
8. **Two components confirmed PERMANENTLY_EXCLUDED/DEACTIVATED** — DQ (A3-Revised) and IFR operating cohort.
9. **Zero components found INCORRECTLY_INACTIVE.** No hidden unacknowledged deactivation exists.

**Verdict on management directive:** The current state reflects controlled activation throughout. No evidence of controlled inaction was found. The DEVELOPMENT_COMPLETE declaration is engineering-justified.

---

## B. Current Build Diagnosis

### B1. Execution Pipeline (source-verified)

```
OnTick()
  → OperatingEnvelopeEvaluate()
      [1] risk_policy_guard_active check — LIVE BLOCK (main_ea.mq5:L2720-2727)
      [2] RunCouncilModePipeline()
            BuildCouncilEnvironmentReport()       → env
            RunCouncilStrategySet()               → reports[18 strategies]
            BuildCouncilAggregateReport()         → agg
            BuildCouncilMemorySummary()           → mem
            BuildCouncilFailurePatternReport()    → failDet [advisory]
            BuildCouncilGovernorStateReport()     → preSentinel
            EvaluateCouncilAIGovernor()           → gov [advisory; feeds threshold hints]
            RunCouncilPreAIFilter()               → pre [gate: DSN + CRR + DOMINANT_SIDE]
                                                       A2 score gates = diagnostic only
            ApplyAuthorityStackPilot()            → authority decision
                                                       P4 LIVE (ERA_EXRA_AGREE_DEGRADED → REJECT)
                                                       V1 LIVE (OBSERVE_ONLY/WAIT/UNDEFINED → REJECT)
                                                       DQ HARDCODED_FALSE (A3-Revised)
            OL write path                         → OL_V1C_PLAYBOOK_SHADOW active
            Final Decision                        → BUY / SELL / WAIT / REJECT
```

### B2. Authority Layer Status (source-verified)

| Authority | Status | Effect | Source |
|---|---|---|---|
| P4 (ERA_EXRA_AGREE_DEGRADED) | LIVE | → REJECT | `authority_stack_pilot.mqh`; `main_ea.mq5:L92` |
| V1 (OBSERVE_ONLY/WAIT/UNDEFINED posture) | LIVE | → REJECT | `authority_stack_pilot.mqh`; `main_ea.mq5:L93` |
| DQ (proxy diagnostic) | HARDCODED_FALSE | No effect | `authority_stack_pilot.mqh:L271-273`; `main_ea.mq5:L91` |
| A1 (V1C constructive eligibility) | LIVE — flag=true | Enables V1 eligibility path | `main_ea.mq5:L105` |
| A2 (score gate demotion) | ACTIVE (demotion confirmed) | Score gates observe; do not enforce | `council_pre_ai_filter.mqh:L157` |
| A3-Revised (DQ quarantine) | ACTIVE | DQ force-false at source | `authority_stack_pilot.mqh:L271-273` |
| No-Score Hard-Lock (6 surfaces) | ACTIVE | Trend continuation reinforcement blocked | `council_mode_runtime.mqh:L195-199` |
| Risk State Policy Engine | LIVE — ENFORCING | block_new_trades → OperatingEnvelopeSetBlock | `main_ea.mq5:L2720-2727` |

### B3. Strategy Count and Eligibility (source-verified)

| Field | Value |
|---|---|
| Total strategies | 18 (17 legacy + fvg_tpb) |
| Operating cohort | LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT |
| IFR cohort | PERMANENTLY_EXCLUDED |
| Frozen strategy | momentum_breakout_cont_v1 (vote_weight=0.00) |
| Score authority | REMOVED from all live decision paths (No-Score V1 complete) |

### B4. PCEA Status (source-verified)

| Field | Value |
|---|---|
| OL schema version | OL_V1C_PLAYBOOK_SHADOW |
| OL records at review | 38+ (BTCUSD; XAUUSD pending) |
| Playbook shadow computation | OL_InitPlaybookShadowState, OL_ComputePlaybookShadowStates — attribution only |
| Playbook runtime authority | NONE — PLAYBOOK_RUNTIME_AUTHORITY_FIREWALL_V1 confirmed |
| Registered playbooks | RBSR (FORMING), TPC (FORMING), VCR (NOT_PRESENT) |

---

## C. Component Activation Table

| # | Component | Activation Type | Source Evidence |
|---|---|---|---|
| 1 | V1 Permission Authority Stack (P4 + V1) | ALREADY_ACTIVE | `authority_stack_pilot.mqh`; `main_ea.mq5:L90-94` |
| 2 | DQ diagnostic (A3-Revised) | PERMANENTLY_DEACTIVATED | `authority_stack_pilot.mqh:L271-273`; EnableDQ=false |
| 3 | A1 V1C constructive eligibility | ALREADY_ACTIVE | `main_ea.mq5:L105` — flag=true confirmed |
| 4 | A2 score gate demotion | ALREADY_ACTIVE | `council_pre_ai_filter.mqh:L157` — pre_ai_score_gates_demoted=true |
| 5 | No-Score Hard-Lock (6 surfaces) | ALREADY_ACTIVE | `council_mode_runtime.mqh:L195-199` — unconditional return false |
| 6 | Risk State Policy Engine | ALREADY_ACTIVE (LIVE ENFORCEMENT) | `main_ea.mq5:L2720-2727` — block_new_trades → OperatingEnvelopeSetBlock |
| 7 | Failure Detector (advisory via governor) | ALREADY_ACTIVE | `council_mode_runtime.mqh:L1591`; feeds `EvaluateCouncilAIGovernor():L1613` |
| 8 | PCEA OL_V1C_PLAYBOOK_SHADOW | ALREADY_ACTIVE | 38+ BTCUSD records; playbook shadow computed; firewall confirmed |
| 9 | FVG_TPB strategy #18 (source) | ALREADY_ACTIVE | Compile-clean; `council_strategies.mqh`; zone routing active |
| 10 | FVG_TPB first trigger validation | RUNTIME_DEBT | RDL-001; XAUUSD market hours required |
| 11 | IFR cohort exclusion | PERMANENTLY_EXCLUDED | Operating cohort hardcoded; IFR excluded by architecture decision |
| 12 | execution_admission_family (LAB fix) | ALREADY_ACTIVE | LAB_InferFamily fix confirmed; fvg_tpb → IFR → correctly blocked from admission |
| 13 | EQ-DIAG fields (sl_vs_m5_atr_ratio, level_context_at_entry) | ALREADY_ACTIVE | `performance_journal.mqh:L3118-3119` — live in TRADE records |
| 14 | mae_pts / mfe_pts | ALREADY_ACTIVE (-1 placeholders); RUNTIME_DEBT (real values) | `council_mode_runtime.mqh:L1252-1253`; real values pending completed trades |
| 15 | stop_anchor_state | PERMANENTLY_REMOVED | Never implemented; removed from criteria (SRR resolution) |
| 16 | Phase 4A (cross-family CRR) | RUNTIME_DEBT | NOT implemented; TPC 0 BTCUSD triggers; evidence blocker genuine |
| 17 | Phase 4B (exhaustion veto) | RUNTIME_DEBT | NOT implemented; MFI 2 entries; calibration blocker genuine |
| 18 | Phase 4C (quality soft gate) | RUNTIME_DEBT | A2 demoted; OL needs 200+ records; sequencing blocker genuine |
| 19 | RCEM (regime-conditioned eligibility) | DEVELOPMENT_FLAGGED — documentation only | Zone_type routing only in source; no regime_label matrix implemented |
| 20 | EEWP (evidence-earned weights) | REJECTED_UNTIL_EVIDENCE | Design-only; blocked on OL + ≥8 Nautilus certs + Phase 4 runtime sample |
| 21 | SPC shadow policies (SPC-001 to SPC-010) | REJECTED (all BLOCKED/EARLY_RESEARCH) | No source implementation; all evidence prerequisites unmet |

---

## D. Components That Must Be Implemented Before Development Complete

**Assessment:** DEVELOPMENT_COMPLETE was declared on 2026-05-09 (DEVELOPMENT_COMPLETE_DECLARATION_V1). This activation review was conducted under Engineering Completion Mode as a retroactive architectural verification. No gap was found that would invalidate the declaration.

**Items confirmed live at declaration time:**

| Item | Verified Status |
|---|---|
| Risk State Policy Engine enforcement | CONFIRMED LIVE — block_new_trades → OperatingEnvelopeSetBlock |
| A1 flag=true (V1C constructive eligibility) | CONFIRMED LIVE — EnableV1ConstructivePolicyEligibility=true |
| No-Score Hard-Lock on 6 surfaces | CONFIRMED LIVE — unconditional return false |
| A2 score gate demotion | CONFIRMED LIVE — pre_ai_score_gates_demoted=true |
| PCEA OL_V1C_PLAYBOOK_SHADOW write path | CONFIRMED LIVE — 38+ records |
| FVG_TPB source implementation | CONFIRMED LIVE — compile-clean |
| IFR cohort exclusion + LAB_InferFamily fix | CONFIRMED LIVE — correctly blocking IFR admission |
| EQ-DIAG fields in TRADE records | CONFIRMED LIVE — sl_vs_m5_atr_ratio + level_context_at_entry |

**Conclusion:** No components were found that should have been implemented before dev-complete but were not. Phase 4A/4B/4C are correctly classified as post-dev-complete runtime debt. The DEVELOPMENT_COMPLETE declaration is engineering-justified and stands without amendment.

**One new confirmation added by this review:** Risk State Policy Engine live enforcement was previously unverified. It is now source-confirmed as LIVE. This strengthens the dev-complete assessment; it does not require any change.

---

## E. Components That Can Remain Runtime Debt

All items below are correctly deferred because their unblock conditions are genuine engineering dependencies, not over-caution:

| RDL # | Component | Unblock Condition | Engineering Justification |
|---|---|---|---|
| RDL-001 | FVG_TPB first XAUUSD trigger | XAUUSD market hours; EA attached | Source ready; cannot force market event |
| RDL-002 | fvg_/ifr_ OL serialization | Depends on RDL-001 | Serialization format in source; needs first trigger to populate |
| RDL-003 | Phase 5A bollinger_reclaim SELL gate validation | XAUUSD TREND_UP session | Gate is live in source; needs market condition to observe |
| RDL-004 | IFR playbook state XAUUSD | Depends on RDL-001 | Playbook shadow computing; needs XAUUSD fvg_tpb trigger |
| RDL-005 | OL 200-record threshold (Phase 4C unblock) | Accumulate 162+ more records | Evidence dependency for quality gate auditability |
| RDL-006 | Phase 4A TPC fire rate | TPC ≥5 distinct triggers + ≥20% eligible-bar rate confirmed | TC execution collapse risk is real — not conservative caution |
| RDL-007 | Phase 4B MFI ≥5 signal entries | mfi_reversal_assist ≥5 readings in OL | Veto threshold cannot be calibrated without observed signal distribution |
| RDL-008 | Phase 5A bollinger_reclaim SELL gate validation | XAUUSD TREND_UP session | Gate is live; validation is market-dependent |
| RDL-009 | V1C K1/K3 runtime confirmation | XAUUSD session with A1=true | Binary ready; needs live XAUUSD session |
| RDL-010 | No-Score A2 field in DECISION records (XAUUSD) | XAUUSD reload + first DECISION record | Substantially done per source; needs reload event |
| RDL-011 | EQ-DIAG in TRADE records (mae/mfe real values) | Completed XAUUSD trade | Fields live; -1.0 placeholders until trade completes |
| RDL-012 | V1C K1-K3 XAUUSD post-cleanup coverage | XAUUSD session | Binary ready; needs live session |
| RDL-013 | expected_rr_estimate XAUUSD confirmation | XAUUSD session | Compile-verified; needs runtime event |

**Engineering assessment of Phase 4A/4B/4C blockers:**

**Phase 4A (cross-family CRR):** The TC confirmation gap is structurally real: 5 of 6 TC CONFIRM strategies are TREND_CONTINUATION family (same as TREND_JUDGE). Only TPC (TREND_PULLBACK_CONT family) satisfies cross-family CRR in TC zone. If TPC fires infrequently, enabling cross-family CRR produces starvation — fewer TC trades but not better-selected ones, because the constraint is structural scarcity rather than quality filtering. This is not a conservative deferral; it is correct engineering. TPC ≥5 distinct triggers at ≥20% eligible-bar rate is the minimum evidence to confirm CRR is quality-filtering rather than starving.

**Phase 4B (exhaustion veto):** The mfi_reversal_assist threshold of `exhaustion_signal_strength ≥ 0.70` was defined in design documents without any observed signal strength distribution from live XAUUSD data. Any specific threshold chosen now is arbitrary and may be too tight (never fires) or too loose (fires on noise). 2 current entries is insufficient to observe distribution shape. 5 entries is a minimum for distribution orientation; threshold calibration requires more.

**Phase 4C (quality soft gate):** Reactivating a quality gate before the Opportunity Ledger has sufficient records creates unauditable suppression — trades are blocked but whether they would have been wins or losses cannot be determined. The OL is the instrument of auditability. 200 records is the minimum to establish whether quality gate would have been selective rather than systematically penalizing one regime type.

---

## F. Components That Should Be Rejected

| Component | Rejection Type | Reason |
|---|---|---|
| DQ diagnostic restoration | PERMANENTLY_DEACTIVATED | A3-Revised; force-false hardcoded; do not reverse without dedicated operator-authorized architecture decision |
| stop_anchor_state (EQ-DIAG criterion) | PERMANENTLY_REMOVED | Never implemented; criterion formally removed (SRR correction); not a gap |
| EEWP implementation now | REJECTED_UNTIL_EVIDENCE | Requires OL live (done) + ≥8 Nautilus certs + ≥50 Phase-4-era decisions — Phase 4 not yet implemented |
| SPC-001 through SPC-010 | REJECTED_FOR_NOW | All BLOCKED or EARLY_RESEARCH; no evidence basis for any; should not appear on Codex queue |
| IFR operating cohort restoration | PERMANENTLY_EXCLUDED | Architecture decision; no promotion pathway without separate operator-authorized decision |
| Automatic weight changes (EEWP shortcut) | PERMANENTLY_REJECTED | All weight changes require operator authorization + bounded Codex task; no exceptions |
| OBSERVE_ONLY multiplier change (×0.15 → ×0.00) | DEFERRED_UNTIL_OL_AUDIT | Deliberate design choice; requires OL audit showing harmful consensus distortion before any change |

---

## G. Playbook Runtime Consumption Recommendation

**Current State:**
- PCEA V1C: `OL_V1C_PLAYBOOK_SHADOW` — live; 38+ BTCUSD records
- Playbook states computed via `OL_ComputePlaybookShadowStates()` — attribution layer
- `PLAYBOOK_RUNTIME_AUTHORITY_FIREWALL_V1`: `runtime_authority_status="NONE"` in all OL records — confirmed
- Registered playbooks: RBSR (FORMING), TPC (FORMING), VCR (NOT_PRESENT)

**Recommendation: MAINTAIN_CURRENT_STATE — no source changes**

The playbook shadow is correctly an attribution-and-classification layer that accumulates context for forward analysis. It receives no decision authority and outputs no gate signals. This is architecturally correct at the current evidence stage.

**Promotion pathway for production acceptance (not an implementation task — a research milestone):** After 200+ OL records with playbook shadow context:
1. Does playbook classification (FORMING vs ESTABLISHED) correlate with win rate in those sessions?
2. Does FORMING context in TC zone predict worse decision quality than ESTABLISHED?
3. Does playbook attribution add signal that is not captured by regime_label + zone_type alone?

Until those questions are answered from real data, the firewall stays. Any promotion of playbook state to a categorical V1 input requires: OL evidence → analysis → operator review → operator authorization → bounded Codex task.

**No source changes for PCEA in this activation review.**

---

## H. Failure Detector Mode Recommendation

**Current State:**
- `BuildCouncilFailurePatternReport()` called at `council_mode_runtime.mqh:L1591`
- Computes: `pressure_level` (NONE/LOW/MEDIUM/HIGH/CRITICAL), `zone_mismatch_detected`, `low_quality_cluster_detected`, `confirmation_gap_detected`, `exhaustion_risk_detected`, `continuation_fragile`, `reversal_fragile`
- `CouncilFailureResolveRecommendedState()` → DEFENSIVE / EXHAUSTION_SENSITIVE / NORMAL
- Output fed to `EvaluateCouncilAIGovernor()` at `L1613`
- Governor outputs advisory: `tighten_entry`, `prefer_reversal`, `prefer_continuation`, `defensive_bias` flags
- Governor flags are advisory — they inform threshold hints; they do not directly block trades

**Distinction from Risk State Policy Engine:**
The failure detector is session-context failure pattern recognition (recent trade cluster analysis — zone mismatch, quality cluster, confirmation gaps). The risk state policy engine is position-level performance state (P/L trajectory, drawdown, loss streak — ComputeRiskPolicyStateV1). These are complementary layers. The failure detector feeds the governor advisory; the risk state engine enforces the OperatingEnvelope block. This separation is architecturally sound.

**Recommendation: MAINTAIN_CURRENT_ADVISORY_MODE — no source changes**

Promoting the failure detector to direct enforcement (VETO path) before evidence accumulates what failure patterns actually predict bad outcomes would introduce uncalibrated false negatives. The governor advisory pathway is the correct mechanism for indirect influence.

**Future pathway (post-production-acceptance research):** After 200+ OL records:
- Analyze whether `pressure_level=HIGH/CRITICAL` sessions correlate with losing runs not caught by the risk state engine
- If correlation is strong: design a bounded Codex task to elevate `pressure_level=CRITICAL` to a soft enforcement gate
- This requires: OL evidence analysis → operator authorization → bounded Codex task

**No source changes for failure detector in this activation review.**

---

## I. RCEM Recommendation

**Current State:**
- RCEM (Regime-Conditioned Eligibility Matrix): DOCUMENTATION_ONLY
- Source implementation: zone_type routing only (`eligible_for_zone` / `blocked_by_zone` per zone_type in `council_strategies.mqh`)
- No `regime_label` eligibility array exists in any source file
- Per-strategy eligibility is zone-type based (e.g., bollinger_reclaim ACTIVE in RMR and REV) — not regime-conditioned

**Gap analysis:** The PIML and IRREW design documents describe a 17-strategy × N-regime matrix. The source implements zone_type routing only. This is a documentation/source divergence.

**Assessment:** This is NOT a dev-complete defect. RCEM as a regime_label matrix requires Nautilus certification evidence to populate with non-arbitrary values. Without that evidence base, implementing a matrix now would encode guesses as architecture — which is worse than the current zone_type routing.

**Recommendation: DOCUMENTATION_RECONCILIATION (no source change; PIML update)**

For production acceptance, add a PIML entry clarifying:
- "RCEM V1" in prior PIML entries refers to the zone_type routing table in council_strategies.mqh
- Per-strategy regime_label conditioning is Phase 4+ territory, requiring Nautilus certification evidence
- The correct implementation path is: one gate per strategy per Nautilus evidence (granular, bounded Codex tasks) — not a full matrix

**Future implementation path (per-strategy, evidence-driven):**
When breakdown_momentum_v1 Nautilus certification recommends TREND_DOWN-only restriction, a bounded Codex task adds `regime_label == "TREND_DOWN"` check inside `BuildCouncilStrategy_BreakdownMomentumV1()` — exactly as bollinger_reclaim received a TREND_UP SELL gate (Phase 5A). This per-strategy gate pattern IS the RCEM implementation; it just builds incrementally from evidence.

**No source changes for RCEM in this activation review.**

---

## J. SPC Recommendation

**Current State:**
- SPC-001 through SPC-010: all BLOCKED or EARLY_RESEARCH per PIML
- No SPC source implementation exists in any file

**Recommendation: FULL_DEFERRAL — no SPC work until post-production-acceptance**

None of the 10 shadow policy candidates have an evidence basis that would justify implementation. Every SPC requires: accumulated OL records → analysis showing the policy would have improved decisions → operator authorization → bounded Codex task. That evidence accumulation phase is only beginning.

SPCs must not appear on any Codex implementation queue at this time. Their status in PIML is correctly BLOCKED/EARLY_RESEARCH.

---

## K. Stop Geometry / EQ-DIAG Recommendation

**Current State:**
- `sl_vs_m5_atr_ratio`: LIVE in TRADE records (`performance_journal.mqh:L3118`)
- `level_context_at_entry`: LIVE in TRADE records (`performance_journal.mqh:L3119`)
- `stop_anchor_state`: NEVER IMPLEMENTED — removed from criteria (SRR resolution confirmed); not a gap
- `mae_pts` / `mfe_pts`: `-1.0` placeholders in OL records (`council_mode_runtime.mqh:L1252-1253`); real values pending completed trades
- Stop geometry logic (`core_trade_engine.mqh`): unchanged — not a dev-complete or PAC pre-requisite

**Recommendation: MAINTAIN_CURRENT_STATE — no source changes**

EQ-DIAG fields are live at the correct level. stop_anchor_state removal is confirmed and correct — this was a criterion from a design doc that was never implemented and has been formally removed. mae_pts/mfe_pts will populate naturally as trades complete; no source change is needed.

**For production acceptance (PAC item):** Verify that at least one completed XAUUSD trade record contains non-placeholder mae_pts/mfe_pts values, and that sl_vs_m5_atr_ratio and level_context_at_entry fields appear in TRADE records with non-null values.

**No source changes for stop geometry / EQ-DIAG in this activation review.**

---

## L. execution_admission_family Recommendation

**Current State:**
- `RuntimeInferDecisionCandidateFromRouted()` → `LAB_InferFamily()` → cohort check
- Operating cohort: `{LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT}`
- IFR (`IMBALANCE_FILL_REVERSAL`): excluded from cohort
- LAB_InferFamily fix confirmed: `fvg_tpb` → `IMBALANCE_FILL_REVERSAL` → cohort check → correctly blocked from execution admission

**Clarification on fvg_tpb behavior:**
IFR cohort exclusion applies to execution admission (best_strategy_id path), not voting. fvg_tpb contributes votes and can shift council consensus direction. It cannot be the admitted primary executor via best_strategy_id / execution_admission_family if IFR is excluded from the admission cohort. This is architecturally coherent.

**Recommendation: MAINTAIN_CURRENT_STATE + RUNTIME_VALIDATION_REQUIRED**

The IFR exclusion is correct and must not be reversed without a dedicated operator-authorized architecture decision. The LAB fix is confirmed correct at source level.

**Runtime validation needed (RDL-001/RDL-002):** After first XAUUSD fvg_tpb trigger, verify:
1. OL record shows `strategy_id="fvg_tpb"` (trigger observed)
2. execution_admission_family does NOT show IFR in the decision path
3. If a trade fires, confirm the mechanism is via council consensus direction (not IFR execution admission)

**No source changes for execution_admission_family in this activation review.**

---

## M. IFR / FVG_TPB Recommendation

### FVG_TPB (Strategy #18)

| Field | Value |
|---|---|
| Status | ACTIVE — compile-clean; source in `council_strategies.mqh` |
| Role | SCOUT; family: IMBALANCE_FILL_REVERSAL; vote_weight=0.65 |
| Nautilus INEC certification | WR=43.41%, N=2,442 — strongest certification in registry |
| Zone routing | Active per strategy meta; eligible_for_zone assigned |
| First XAUUSD trigger | PENDING (RDL-001) |

### IFR Cohort

| Field | Value |
|---|---|
| Status | PERMANENTLY_EXCLUDED from operating cohort |
| Operating cohort | {LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT} |
| Effect | fvg_tpb votes count toward council consensus; IFR family cannot be the execution-admitted primary executor |
| Promotion pathway | Not authorized; requires dedicated operator-authorized architecture decision |

**Recommendation:**

1. **No change to IFR exclusion.** Permanently excluded; requires dedicated architecture decision with promotion criteria before any change.
2. **Monitor fvg_tpb trigger behavior** after first XAUUSD trigger (RDL-001).
3. **Validate IFR playbook state** in XAUUSD session (RDL-004).
4. **IFR promotion pathway (deferred research):** Define criteria once OL accumulates ≥50 fvg_tpb triggered records with WR ≥ 43% sustained + stable playbook state → operator authorization → bounded Codex task to add IFR to cohort. This is Phase 5B+ territory; not authorized now.

**No source changes for IFR / FVG_TPB in this activation review.**

---

## N. Development-Complete Checklist

| # | Criterion | Status | Evidence Source |
|---|---|---|---|
| DEV-C-01 | 0 errors / 0 warnings (latest compile) | CONFIRMED | `compile_lab_infer_family_registry_fvg_tpb_fix_v1_20260509_124554.log` |
| DEV-C-02 | No-Score V1 complete (A1/A2/A3/Pkg1/Pkg2/Hard-Lock) | CONFIRMED | All stages source-verified; Hard-Lock at `council_mode_runtime.mqh:L195-199` |
| DEV-C-03 | V1 Permission Authority Stack active (P4+V1) | CONFIRMED | `main_ea.mq5:L90-94`; A1 flag=true at L105 |
| DEV-C-04 | PCEA V1C schema live (OL_V1C_PLAYBOOK_SHADOW) | CONFIRMED | 38+ BTCUSD records; playbook shadow active |
| DEV-C-05 | PLAYBOOK_RUNTIME_AUTHORITY_FIREWALL_V1 confirmed | CONFIRMED | runtime_authority_status="NONE" in all OL records |
| DEV-C-06 | FVG_TPB strategy #18 implemented + compile-clean | CONFIRMED | `council_strategies.mqh`; 0 errors, 0 warnings |
| DEV-C-07 | IFR cohort exclusion confirmed + LAB_InferFamily fix | CONFIRMED | IFR excluded; fvg_tpb → IFR → blocked from admission |
| DEV-C-08 | Phase 5A bollinger_reclaim SELL gate applied | CONFIRMED | `council_strategies.mqh`; binary 2026-05-06 17:11:10 |
| DEV-C-09 | EQ-DIAG fields in TRADE records | CONFIRMED | `performance_journal.mqh:L3118-3119` |
| DEV-C-10 | Archive created | CONFIRMED | `FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_20260509_215951.zip`; 9.87 MB; 1,134 entries |
| DEV-C-11 | Risk State Policy Engine live enforcement | CONFIRMED (this review) | `main_ea.mq5:L2720-2727` — block_new_trades → OperatingEnvelopeSetBlock |
| DEV-C-12 | Handover package created | CONFIRMED | `DEVELOPMENT_COMPLETE_HANDOVER_PACKAGE_V1.md` |

**DEV-C-11 note:** Previously listed as "consumption in live path unclear" in pre-review research. This activation review source-confirmed it as LIVE and ENFORCING. No prior record existed confirming the enforcement path — this review closes that gap.

**All 12 DEV-C criteria are confirmed.** DEVELOPMENT_COMPLETE status is validated.

---

## O. Production Acceptance Checklist Remains Separate

The Production Acceptance Checklist (PAC-A through PAC-O; 57 items) is defined in `DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1.md`. It is independent of this activation review.

**This activation review does not start the PAC.** The PAC requires:
1. XAUUSD validation complete (RDL-001 through RDL-013 substantially resolved)
2. Minimum 50 post-reload XAUUSD DECISION and TRADE records observed
3. Full 57-item audit by operator
4. Any checklist failure reopens investigation (REOPEN_INVESTIGATION_AND_CORRECTION policy)

**Current PAC status:** NOT STARTED. Do not begin PAC items until XAUUSD validation is substantially complete.

---

## P. Final Engineering Directive: What Should Codex Implement Next?

Ordered by dependency and readiness. All items require operator authorization before Codex task creation.

---

### P1 — XAUUSD Validation (No Codex Task — Operator Action)

**Action:** Attach EA to XAUUSD M5 chart. Execute `XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1`.
**Why first:** Resolves RDL-001 through RDL-013. All subsequent unblock conditions depend on XAUUSD session evidence.
**Source changes needed:** None.
**Authorization required:** Operator (attach chart, observe runtime).

---

### P2 — Phase 4C: Quality Soft Gate Reactivation (Blocked: OL ≥200 records)

```
Unblock condition:  OL record count ≥ 200
File:               council_pre_ai_filter.mqh
Change:             council_quality < 0.50 + NARROW consensus → WAIT (not diagnostic)
Codex task type:    Bounded (one gate condition, one file, no other changes)
Authorization:      Operator reviews 200+ OL records; confirms quality gate
                    would have correctly suppressed NARROW-quality decisions
                    without systematically penalizing a single regime
```

---

### P3 — Phase 4A: Cross-Family CRR Upgrade (Blocked: TPC ≥5 triggers + ≥20% eligible-bar rate)

```
Unblock condition:  TPC (trend_pullback_cont_v1) ≥5 distinct live triggers confirmed;
                    ≥20% of eligible TC-zone bars produce a TPC trigger
File:               council_pre_ai_filter.mqh (cross-family check logic)
Change:             confirm_role_present = confirmSupportsDominant
                    AND (confirm_family != primary_executor_family)
                    Same-family confirm: adds 0.03 to council_quality; does NOT satisfy CRR gate
Codex task type:    Bounded (cross-family check logic only; no aggregator/strategy/weight changes)
Authorization:      Operator reviews TPC fire rate; explicitly authorizes Phase 4A only after
                    confirming TC execution will not collapse to near-zero
Risk:               If TPC fires at <5% eligible-bar rate, CRR enables structural starvation.
                    DO NOT authorize unless TPC rate is confirmed sustained.
```

---

### P4 — Phase 4B: Exhaustion Veto (Blocked: MFI ≥5 signal entries)

```
Unblock condition:  mfi_reversal_assist ≥5 distinct signal strength readings in OL records
                    (sufficient to observe distribution shape and set non-arbitrary threshold)
File:               council_mode_runtime.mqh, council_mode_types.mqh
Change:             EvaluateExhaustionVeto() inserted between aggregation and pre-AI filter;
                    threshold derived from observed distribution, not from design doc default
Codex task type:    Bounded (veto logic path only; one new function; no other changes)
Authorization:      Operator reviews MFI signal distribution from ≥5 OL records;
                    determines calibrated threshold; explicitly authorizes Phase 4B
Risk:               Arbitrary threshold (e.g., ≥0.70 from design doc) may be
                    too tight (never fires) or too loose (fires on noise) without
                    observed distribution. Do not authorize until distribution is seen.
```

---

### P5 — breakdown_momentum_v1 Phase 5B Restriction (Blocked: Nautilus certification)

```
Unblock condition:  Nautilus INEC_LAB_V1 Phase 3 certification for breakdown_momentum_v1
                    confirms edge improvement under TREND_DOWN-only restriction
File:               council_strategies.mqh
Change:             Add regime_label == "TREND_DOWN" gate inside
                    BuildCouncilStrategy_BreakdownMomentumV1() — same pattern as
                    bollinger_reclaim Phase 5A SELL-in-TREND_UP gate
Codex task type:    Bounded (one strategy, one regime gate, one file)
Authorization:      Nautilus evidence + operator authorization
```

---

### P6 — RCEM Documentation Reconciliation (No Source Change — PIML Update)

```
Action:             Add PIML entry (§30 or PAC preparation section) clarifying:
                    - "RCEM V1" = zone_type routing in council_strategies.mqh (current source truth)
                    - Per-strategy regime_label conditioning is Phase 4+ territory
                    - The per-strategy gate pattern (Phase 5A, Phase 5B) IS the RCEM implementation
                    - No full matrix will be implemented; gates accumulate incrementally from evidence
Authorization:      Operator PIML update (no Codex task needed)
```

---

### P7 — IFR Promotion Pathway Design (Deferred Research — Not Actionable Now)

```
Status:             DESIGN_RESEARCH_ONLY — not actionable until OL evidence exists
Unblock condition:  ≥50 fvg_tpb triggered OL records + sustained WR ≥43% + stable playbook state
Action when ready:  Define criteria → operator authorization → bounded Codex task to add IFR to cohort
```

---

### P8 — EEWP (Design-Only — No Implementation Path)

```
Status:             DESIGN_ONLY
Unblock:            OL live (done) + ≥8 Nautilus certs (0/8 complete) + ≥50 Phase-4-era decisions
                    (Phase 4 not yet implemented — none of these conditions are met)
Action:             None until Phase 4 is live and certifications accumulate
```

---

### Immediate Operator Actions (Not Codex Tasks)

| # | Action | Unblocks |
|---|---|---|
| 1 | Attach EA to XAUUSD M5 chart | RDL-001 through RDL-013 |
| 2 | Run Nautilus INEC_LAB_V1 Phase 3 for breakdown_momentum_v1 | P5 (Phase 5B) |
| 3 | Monitor TPC fire rate in XAUUSD session | P3 (Phase 4A) unblock condition |
| 4 | Monitor MFI signal entry count in OL records | P4 (Phase 4B) unblock condition |
| 5 | Monitor OL record count (target: 200) | P2 (Phase 4C) unblock condition |

---

## Footer

```
REVIEW_ID:                    ENGINEERING_ACTIVATION_REVIEW_FOR_V1_IRREW_PCEA_V1
DATE:                         2026-05-09
AUTHORITY:                    Engineering Completion Mode — APPROVED
MANAGEMENT_DIRECTIVE:         Controlled Activation accepted; Controlled Inaction not accepted
SYSTEM_STATUS:                DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
SOURCE_CHANGED:               NO
COMPILE_RUN:                  NO
RELOAD_RUN:                   NO
PRODUCTION_READY_CLAIMED:     NO

COMPONENTS_ALREADY_ACTIVE:    V1 Auth Stack (P4+V1), A1 flag, A2 demotion, No-Score Hard-Lock,
                              Risk State Policy Engine, Failure Detector (advisory),
                              PCEA OL_V1C_PLAYBOOK_SHADOW, FVG_TPB source,
                              IFR exclusion + LAB fix, EQ-DIAG TRADE fields
COMPONENTS_RUNTIME_DEBT:      Phase 4A, Phase 4B, Phase 4C, FVG_TPB first trigger,
                              mae/mfe real values
COMPONENTS_PERMANENTLY_EXCLUDED: DQ (A3-Revised), IFR operating cohort, stop_anchor_state
COMPONENTS_REJECTED:          EEWP now, SPC-001-010, auto weight changes
COMPONENTS_DEVELOPMENT_FLAGGED: RCEM (documentation reconciliation only)

NEW_FINDING:                  Risk State Policy Engine LIVE enforcement confirmed
                              (main_ea.mq5:L2720-2727 — block_new_trades → OperatingEnvelopeSetBlock)
                              Previously: "consumption in live path unclear"
                              Corrected: CONFIRMED LIVE AND ENFORCING

DEV_COMPLETE_VALIDATED:       YES — all 12 DEV-C criteria confirmed
NEXT_CODEX_TASK:              Phase 4C quality soft gate (blocked: OL ≥200 records)
NEXT_OPERATOR_ACTION:         Attach EA to XAUUSD chart — XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1
```
