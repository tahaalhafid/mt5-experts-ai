# BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1

**Status:** AUDIT_COMPLETE
**Date:** 2026-05-09
**Scope:** Post-IRREW / PCEA V1C / IFR / FVG_TPB functional audit of best_strategy_id
**Method:** Full source inspection — council_aggregator.mqh, council_mode_types.mqh, council_ai_governor.mqh, council_governor.mqh, council_pre_ai_filter.mqh, council_mode_runtime.mqh, council_v1_state_composer.mqh, level_awareness_brake.mqh, main_ea.mq5
**Authority:** READ-ONLY. No changes, no patches, no compile, no reload.

---

## A. Executive Verdict

**PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP**

The core post-IRREW doctrine (best_strategy_id = thesis identity; V1 = permission authority; Risk = protection authority; Execution = survivability authority; Attribution = learning authority) is **substantially upheld** after FVG_TPB / IFR integration. No trade is ever executed because best_strategy_id says so. No trade is ever approved because best_strategy_id says so. The pre-AI filter, cohort admission gate, risk envelope, and execution layer all operate independently.

However, **three concrete caveats require cleanup** before full semantic clarity is achieved:

1. **`LAB_InferFamilyFromStrategyId` does not know about `fvg_tpb`** — returns "UNKNOWN". This means if fvg_tpb ever becomes best_strategy_id, the cohort admission check fails with "UNKNOWN family not in cohort" rather than "IMBALANCE_FILL_REVERSAL not in cohort". The symptom is the same (execution blocked) but the diagnostic trace is incorrect and opaque.

2. **Cohort admission is coupled to best_strategy_id family** — `RuntimeOperatingCohortAdmissionAllowsExecution` uses `LAB_InferFamilyFromStrategyId(best_strategy_id)` to gate execution. This makes best_strategy_id EXECUTION-BLOCKING when its family is not in the operating cohort. This is a structural property of the current admission architecture, not a new bug. But it violates the intended doctrine that best_strategy_id is thesis identity only.

3. **WAIT-deciding strategies can be selected as best_strategy_id** — The aggregator selects best_strategy_id by highest post-V1 weight with no filter on trigger_present or BUY/SELL decision. A strategy saying WAIT with a positive weight is eligible. This is a semantic gap in the meaning of "best" — the current field name implies the leading thesis, but the selection may reflect the highest-weighted silent voter.

**None of these caveats cause incorrect trade execution.** V1 retains permission authority in all cases. Execution is protected by the pre-AI filter, cohort admission (which in this case adds a secondary guard), and the risk envelope. The caveats are semantic and diagnostic, with one latent execution-blocking scenario (fvg_tpb as best_strategy_id).

**Reload is safe.** No blocker found.

---

## B. Current Functional Meaning of best_strategy_id

`best_strategy_id` is the strategy_id of the strategy with the **highest post-V1 family-adjusted weight** among all valid, enabled strategies after the aggregation loop. It is:

- Selected **during** council aggregation
- Used for **thesis identity** in feedback, reporting, and V1C ledger
- Used as **candidate name** for cohort admission gating (execution-blocking implication)
- Used as **signal identity** in the Council Setup Lifecycle gate when that flag is enabled
- Used in governor logging and advisory context (no live authority)
- NOT used to make the final BUY/SELL/WAIT/REJECT decision
- NOT used to determine stop/entry price
- NOT used in the pre-AI structural gates (DSN, CRR, HIGH_CONVICTION)

The name "best_strategy_id" is semantically **slightly misleading** under the current implementation: it means "highest-weighted strategy after V1 adjustment," not "best performing strategy" or "triggering thesis." A WAIT-deciding strategy can be best_strategy_id if it has the highest remaining weight.

---

## C. When It Is Computed

**Timing:** During `BuildCouncilAggregateReport` (council_aggregator.mqh). This runs in pipeline stage 3, after all 18 strategy reports are built (stage 2) and before the pre-AI filter (stage 4), governor (stage 3E), and final decision (stage 8).

best_strategy_id is computed **before** the final decision is known. It does not change after final_decision is set. It is fixed for the duration of the bar once BuildCouncilAggregateReport completes.

---

## D. Who Computes It

| Component | File | Lines | Role |
|---|---|---|---|
| `BuildCouncilAggregateReport` | council_aggregator.mqh | 191–365 | **Producer** — runs the selection loop |
| `CouncilAIGovPickBestStrategy` | council_ai_governor.mqh | 37–48 | **Reader** — extracts best_strategy_id from agg struct |
| `RuntimeInferDecisionCandidateFromRouted` | main_ea.mq5 | 2995–3016 | **Authority consumer** — derives candidateName from best_strategy_id |

---

## E. Field Inventory

| Field | Location | Struct | Producer | Authority | Pre/Post Decision | Written to Ledger |
|---|---|---|---|---|---|---|
| `best_strategy_id` | council_mode_types.mqh:329 | CouncilAggregateReport | BuildCouncilAggregateReport | **CONDITIONAL AUTHORITY** (cohort admission path) | Pre-decision | YES (V1C, diagnostic) |
| `support_strategy_ids` | council_mode_types.mqh:330 | CouncilAggregateReport | BuildCouncilAggregateReport | Attribution only | Pre-decision | NO |
| `best_strategy_id` | council_mode_types.mqh:661 | CouncilMemorySummary | BuildCouncilMemorySummaryFromFeedback | Attribution only | Post-decision (historical) | Indirectly (memory) |
| `target_strategy_id` | council_mode_types.mqh:737 | CouncilPolicyAdjustment | EvaluateCouncilAIGovernor + council_governor | Advisory only — NEVER applied | Pre-decision | Feedback log only |
| `primary_executor_id` | council_mode_runtime.mqh (OL_CrossFamilyEvidence) | OL_CrossFamilyEvidence | OL_ComputeCrossFamilyEvidence | Attribution only — no decision path reads it | Post-decision | YES (V1C ledger) |
| `primary_packet_id` | council_mode_runtime.mqh (OL_PlaybookShadowState) | OL_PlaybookShadowState | OL_ComputePlaybookShadowStates | Attribution only | Post-decision | YES (V1C ledger) |
| `strategy_id` | council_mode_types.mqh | CouncilStrategyReport | Each BuildCouncilStrategy_* | Strategy identity | Pre-decision | YES |
| `strategy_family` | council_mode_types.mqh | CouncilStrategyReport | Each BuildCouncilStrategy_* | V1 FSW multiplier input | Pre-decision | YES |
| `vote_weight` | council_mode_types.mqh | CouncilStrategyReport | BuildCouncilStrategy_* | **AUTHORITY-BEARING** (best_strategy_id selection, consensus weight) | Pre-decision | YES (as baseline_weight) |
| `score_final` | council_mode_types.mqh | CouncilStrategyReport | BuildCouncilStrategy_* | Diagnostic only (council_quality calc) | Pre-decision | YES |
| `confidence` | council_mode_types.mqh | CouncilStrategyReport | BuildCouncilStrategy_* | Diagnostic only | Pre-decision | YES |
| `trigger_present` | council_mode_types.mqh | CouncilStrategyReport | BuildCouncilStrategy_* | Ledger write condition | Pre-decision | YES (determines write condition) |
| `decision` | council_mode_types.mqh | CouncilStrategyReport | BuildCouncilStrategy_* | **AUTHORITY-BEARING** (consensus direction, votes) | Pre-decision | YES |
| `eligibility_state` | council_mode_types.mqh | CouncilStrategyReport | CouncilApplyStrategyEligibility | **AUTHORITY-BEARING** (weight multiplier) | Pre-decision | YES |
| `council_quality` | council_mode_types.mqh | CouncilAggregateReport | BuildCouncilAggregateReport | Diagnostic gate only (pre_ai_would_have_gated_quality) | Pre-decision | YES |
| `final_decision` | council_mode_types.mqh | CouncilRuntimeResult | RunCouncilModePipeline | **AUTHORITY-BEARING** (BUY/SELL/WAIT/REJECT determination) | Post-aggregation | YES |
| `suppression_reason` | council_mode_types.mqh | CouncilPreAIGateReport | RunCouncilPreAIFilter | Attribution only (diagnostic) | Post-decision | YES |
| `playbook_id` | OL_PlaybookShadowState | council_mode_runtime.mqh | OL_ComputePlaybookShadowStates | Attribution only | Post-decision | YES (V1C) |
| `playbook_state` | OL_PlaybookShadowState | council_mode_runtime.mqh | OL_ComputePlaybookShadowStates | Attribution only | Post-decision | YES (V1C) |
| `runtime_authority_status` | OL functions | council_mode_runtime.mqh | OL_RuntimeAuthorityStatus() | Attribution only | Post-decision | YES |

**Absent fields** (do not exist in current codebase):
- `best_strategy_family` — NOT PRESENT
- `best_strategy_role` — NOT PRESENT
- `best_strategy_direction` — NOT PRESENT
- `best_strategy_score` — NOT PRESENT
- `best_strategy_weight` — NOT PRESENT
- `best_strategy_quality` — NOT PRESENT
- `leading_strategy_id` — NOT PRESENT

---

## F. Computation Logic

### F1. Aggregator Selection (council_aggregator.mqh lines 169–286)

```
// Initialization
double bestScore       = -1.0;      // track highest score_final (diagnostic only)
double bestContribution = -1.0;     // track highest post-V1 weight (best_strategy_id selector)
string bestStrategy    = "";

// Per-strategy loop
for each valid, enabled strategy report s:

   // Base weight
   weight = s.vote_weight × CouncilRoleInfluenceMultiplier(s.role)

   // Eligibility reduction
   if(BLOCKED)   weight = 0.0
   if(OBS_ONLY)  weight *= 0.15
   if(REDUCED)   weight *= 0.75

   // V1 FSW multiplier
   postV1Weight = weight × CouncilV1_FamilySoftWeightMultiplier(family)

   // best_strategy_id selection (NO SCORE, NO DIRECTION, NO TRIGGER FILTER)
   if(postV1Weight > 0.0 && postV1Weight > bestContribution):
      bestContribution = postV1Weight
      bestStrategy = s.strategy_id

   // bestScore tracks highest score_final separately (diagnostic only)
   if(s.score_final > bestScore): bestScore = s.score_final
```

**Critical audit points:**

| Question | Answer |
|---|---|
| Uses vote_weight? | YES — primary selector input |
| Uses post-V1 adjusted weight? | YES — postV1Weight is the actual selector |
| Uses score_final? | NO — score_final tracked separately in bestScore (diagnostic only) |
| Filters by decision BUY/SELL? | NO — WAIT strategies with positive weight can be selected |
| Filters by trigger_present? | NO — strategies without triggers can be selected |
| Filters by eligibility? | PARTIAL — BLOCKED → weight=0 excluded; OBS_ONLY/REDUCED discounted but not excluded |
| Filters by role? | NO — role contributes multiplier but no role is excluded from selection |
| Can WAIT strategy be best? | YES — if it has highest post-V1 weight |
| Can hostile FVG_TPB be best? | NO — vote_weight=0.0 in hostile path → weight=0.0 → excluded |
| Can non-hostile WAIT fvg_tpb be best? | YES — vote_weight=0.65, post-V1 weight=0.585, possible if higher than all others |
| Selection uses pre-policy or post-policy? | POST-V1 (postV1Weight after FSW multiplier) |

### F2. V1 FSW Multipliers by Family (council_v1_state_composer.mqh lines 971–1112)

| Family | V1 Role | Multiplier |
|---|---|---|
| IMBALANCE_FILL_REVERSAL | CONDITIONAL | **0.90 (hardcoded, bypasses ctx)** |
| NATIVE families | NATIVE | 1.00–1.05 depending on posture |
| CONDITIONAL families | CONDITIONAL | 0.90 default |
| DEPRIORITIZED families | DEPRIORITIZED | 0.85 |
| INFORMATIONAL families | INFORMATIONAL | 1.00 |
| UNKNOWN families | UNKNOWN | 1.00 (no adjustment) |

Note: IMBALANCE_FILL_REVERSAL gets its 0.90 multiplier hardcoded at line 1020 before any ctx lookup. This is correct — it prevents V1 state from accidentally granting native status to a new external family.

### F3. fvg_tpb Effective Weight Calculation

- base vote_weight = 0.65
- SCOUT role multiplier = 1.00
- Eligibility ACTIVE (REV/RMR) or OBSERVE_ONLY (TC) or REDUCED (BREAKOUT)
- V1 FSW multiplier = 0.90 (CONDITIONAL, hardcoded)

| Zone | Eligibility | Effective weight |
|---|---|---|
| REV / RMR | ACTIVE | 0.65 × 1.00 × 1.00 × 0.90 = **0.585** |
| TC | OBSERVE_ONLY | 0.65 × 1.00 × 0.15 × 0.90 = **0.088** |
| BREAKOUT | REDUCED | 0.65 × 1.00 × 0.75 × 0.90 = **0.439** |

Comparison with lowest-weight competing strategies in REV zone:
- sweep_reversal: 0.60 × 1.00 = 0.60 (LIQUIDITY_REVERSAL NATIVE ~1.00) = ~0.60–0.618
- fvg_tpb at 0.585 is **below sweep_reversal at 0.60** even before native bonus

In practice, fvg_tpb becoming best_strategy_id requires that nearly all other active strategies have weight reduced below 0.585, which requires unusual V1 policy state or eligibility conditions.

---

## G. Producer → Aggregator → V1 → Risk → Execution → Attribution Flow

```
Stage 1: Strategy reports built (council_mode_runtime.mqh stage 2)
   → s1...s17 (17 existing strategies) + s18 (fvg_tpb)
   → Each report: strategy_id, family, role, vote_weight, score_final,
                  trigger_present, decision, eligibility_state
   → best_strategy_id: DOES NOT EXIST YET

Stage 2: V1 policy eligibility applied (before aggregation)
   → CouncilV1_ApplyPolicyEligibilityOverride modifies eligibility states
   → IMBALANCE_FILL_REVERSAL → CONDITIONAL role
   → best_strategy_id: DOES NOT EXIST YET

Stage 3: BuildCouncilAggregateReport (council_aggregator.mqh)
   → READS: all 18 strategy reports
   → COMPUTES: best_strategy_id = ID of strategy with highest postV1Weight > 0
   → OUTPUTS: CouncilAggregateReport.best_strategy_id
   → TIMING: BEFORE final_decision is set
   → AUTHORITY: NONE at this stage — pure computation
   → best_strategy_id: NOW AVAILABLE

Stage 3E: EvaluateCouncilAIGovernor
   → READS: agg.best_strategy_id via CouncilAIGovPickBestStrategy
   → WRITES: outAction.target_strategy_id = bestStrategyId (advisory only)
   → EFFECT: None on any live gate. Governor is threshold-input supplier only.
   → AUTHORITY of target_strategy_id: NONE — never applied

Stage 4: RunCouncilPreAIFilter
   → READS: agg (consensus_type, conflict_score, council_quality — diagnostic only)
   → READS: structural gates: dominant_side, confirm_role_present, family_diversity
   → Does NOT read best_strategy_id
   → DECIDES: REJECT / WAIT / BUY / SELL based on structural gates
   → best_strategy_id: NOT CONSUMED for permission decision

Stage 8: Final Decision
   → runtime.final_decision = pre.filtered_decision OR REJECT (if !env.tradable)
   → best_strategy_id: NOT involved in final_decision

Stage 9 (main_ea.mq5): RuntimeInferDecisionCandidateFromRouted
   → READS: routed.council.aggregate.best_strategy_id (line 3004)
   → SETS: gCurrentDecisionCandidateName = best_strategy_id
   → SETS: gCurrentDecisionCandidateFamily = LAB_InferFamilyFromStrategyId(best_strategy_id)
   → *** AUTHORITY IMPLICATION: family used in cohort admission gate ***

Stage 10: RuntimeOperatingCohortAdmissionAllowsExecution (line 14245/14762)
   → READS: gCurrentDecisionCandidateFamily (derived from best_strategy_id)
   → CHECKS: OperatingCohortFamilyAllowed(family)
   → BLOCKS execution if family not in cohort
   → *** AUTHORITY-BEARING USE OF best_strategy_id ***
   → Cohort = {LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT}
   → IMBALANCE_FILL_REVERSAL NOT in cohort
   → LAB_InferFamilyFromStrategyId("fvg_tpb") = "UNKNOWN" → ALSO not in cohort

Stage 11 (if execution proceeds): ExecuteRuntimeBuy / ExecuteRuntimeSell
   → best_strategy_id used for SCM (Strategy Confidence Memory) recording
   → best_strategy_id used for Council Setup Lifecycle gate candidate (if flag enabled)
   → Attribution only (SCM), Conditional gate (lifecycle)
   → core_trade_engine.mqh: NOT INVOLVED with best_strategy_id

Stage 18.5: Opportunity Ledger write
   → best_strategy_id in diagnostic_runtime_summary (JSON + text reports)
   → primary_executor_id in OL_CrossFamilyEvidence (separate, for attribution)
   → primary_packet_id in OL_PlaybookShadowState (for IFR/RBSR/TPC/VCR attribution)
   → fvg_/ifr_ fields written for fvg_tpb records only
   → All attribution only — no decision authority
```

**Does best_strategy_id exist at each stage?**

| Stage | best_strategy_id available? | Can it affect next stage? |
|---|---|---|
| Strategy build | NO | N/A |
| V1 eligibility | NO | N/A |
| Aggregation (start) | NO | N/A |
| Aggregation (end) | **YES (just computed)** | Feeds governor (advisory) |
| Pre-AI filter | YES (in agg) | NOT READ by filter |
| Final decision | YES | NOT USED for decision |
| main_ea cohort check | YES | **YES — BLOCKING if family not in cohort** |
| Execution | YES | Used for SCM (attribution) and lifecycle gate (conditional) |
| Ledger | YES | Written to diagnostic/attribution fields |

---

## H. Consumer Table

| Consumer | File | Lines | Reads | Why | Type | Changes Behavior? | Verdict |
|---|---|---|---|---|---|---|---|
| `CouncilAIGovPickBestStrategy` | council_ai_governor.mqh | 41 | best_strategy_id → bestStrategyId | Governor advisory context | LOGGING | Sets target_strategy_id (advisory, never applied) | **SAFE_ADVISORY** |
| `EvaluateCouncilAIGovernor` (case 0–5) | council_ai_governor.mqh | 222–354 | bestStrategyId (read from agg) | Records governor recommendation | LOGGING | target_strategy_id: never applied | **SAFE_ADVISORY** |
| `council_governor.mqh` BuildCouncilGovernorPolicy | council_governor.mqh | 94 | agg.best_strategy_id | Advisory weight suggestion | ADVISORY | change_vote_weights never consumed | **SAFE_ADVISORY** |
| `RuntimeInferDecisionCandidateFromRouted` | main_ea.mq5 | 3004 | agg.best_strategy_id → candidateName | Sets execution candidate name | **EXECUTION PATH** | Sets gCurrentDecisionCandidateName | **AMBIGUOUS → see below** |
| `RuntimeOperatingCohortAdmissionAllowsExecution` | main_ea.mq5 | 3018–3047 | candidateFamily (derived from best_strategy_id) | Cohort family check | **EXECUTION GATE** | YES — blocks execution if family not in cohort | **AUTHORITY_LEAKAGE** |
| Council Setup Lifecycle | main_ea.mq5 | 14554, 15062 | best_strategy_id as _sid | Signal identity for lifecycle arm/confirm | CONDITIONAL GATE (flag-gated) | YES when flag enabled | **AMBIGUOUS** |
| `CouncilLifecycleUpdateOnNonEntryDecision` | main_ea.mq5 | 14165 | best_strategy_id | Lifecycle invalidation on non-entry | CONDITIONAL LIFECYCLE | YES when flag enabled | **AMBIGUOUS** |
| `SCM_RecordDecisionEvent` | main_ea.mq5 | 14656–14673 | best_strategy_id as sid | Observer-only confidence memory | ATTRIBUTION | NO — observer-only | **SAFE_ATTRIBUTION** |
| `SCM_RecordTradeOpenEvent` | main_ea.mq5 | 14700–14714 | best_strategy_id as sid | Observer-only confidence memory | ATTRIBUTION | NO — observer-only | **SAFE_ATTRIBUTION** |
| `gDiagnosticRuntimeSummary.best_strategy_id` | main_ea.mq5 | 3264 | agg.best_strategy_id | Diagnostic snapshot | DIAGNOSTIC | NO | **SAFE_DIAGNOSTIC** |
| Dashboard display | main_ea.mq5 | 3484, 3554, 3633 | diagnostic struct field | Dashboard rendering | DIAGNOSTIC | NO | **SAFE_DIAGNOSTIC** |
| Fallback candidate name | main_ea.mq5 | 3659–3661 | diagnostic struct field | Name fallback for logging | LOGGING | NO — fallback for empty name | **SAFE_DIAGNOSTIC** |
| Performance journal | main_ea.mq5 | 5244 | agg.best_strategy_id | Journal entry | LOGGING | NO | **SAFE_ATTRIBUTION** |
| Decision signature | main_ea.mq5 | 7803–7816 | agg.best_strategy_id | Scope/signature building | LOGGING | NO | **SAFE_DIAGNOSTIC** |
| AI advisory packet | main_ea.mq5 | 8482–8544 | LAB_InferFamily(best_strategy_id) | relevant_strategy_family for advisory | ADVISORY | Advisory only — not execution | **SAFE_ADVISORY** |
| Live family inference | main_ea.mq5 | 10043 | agg.best_strategy_id | Family for live validation report | DIAGNOSTIC | NO | **SAFE_DIAGNOSTIC** |
| Feedback enrichment | main_ea.mq5 | 15667–15779 | best_strategy_id from feedback record | Post-trade attribution enrichment | ATTRIBUTION | NO | **SAFE_ATTRIBUTION** |
| Replay validation summary | main_ea.mq5 | 10269, 3897 | best_strategy_id | Replay validation report | ATTRIBUTION | NO | **SAFE_ATTRIBUTION** |
| Council feedback record | council_feedback.mqh | 355 | gov.target_strategy_id | Feedback log record | LOGGING | NO | **SAFE_DIAGNOSTIC** |
| Council txt reporter | council_txt_reporter.mqh | 328 | gov.target_strategy_id | Report output | DIAGNOSTIC | NO | **SAFE_DIAGNOSTIC** |

**Summary by verdict:**

| Verdict | Count | Consumers |
|---|---|---|
| SAFE_ATTRIBUTION | 7 | SCM, feedback, replay, performance journal |
| SAFE_DIAGNOSTIC | 6 | Dashboard, signature, diagnostic summary |
| SAFE_ADVISORY | 4 | Governor, txt reporter, advisory packet |
| AMBIGUOUS | 3 | Cohort admission path, lifecycle gate, lifecycle update |
| AUTHORITY_LEAKAGE | 1 | `RuntimeOperatingCohortAdmissionAllowsExecution` |
| BUG | 0 | None |

**The single AUTHORITY_LEAKAGE finding:**
`RuntimeOperatingCohortAdmissionAllowsExecution` (main_ea.mq5:3018–3047) uses `candidateFamily = LAB_InferFamilyFromStrategyId(best_strategy_id)` to check if the "candidate" is admitted to execute. If best_strategy_id is `fvg_tpb`, `LAB_InferFamilyFromStrategyId("fvg_tpb")` returns `"UNKNOWN"` (the registry doesn't include fvg_tpb). "UNKNOWN" is not in `{LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT}`, so `OperatingCohortFamilyAllowed` returns false. Execution is blocked with "candidate_not_in_active_operating_cohort".

This makes best_strategy_id EXECUTION-BLOCKING in one specific scenario: fvg_tpb has the highest post-V1 weight AND the final_decision is BUY or SELL.

**Important context:** Even if `LAB_InferFamilyFromStrategyId` is fixed to return "IMBALANCE_FILL_REVERSAL" for fvg_tpb, the execution would still be blocked because IMBALANCE_FILL_REVERSAL is not in the operating cohort. So the authority leakage path produces the CORRECT behavioral outcome (block IFR-led execution because IFR is not in cohort) but through the WRONG semantic mechanism (best_strategy_id should not be what determines cohort membership — the aggregate direction should).

---

## I. Score Authority Map

| Field | Produced By | Consumed For best_strategy_id? | Consumed For final_decision? | Consumed For CRR/DSN? | Consumed For Execution? | Classification |
|---|---|---|---|---|---|---|
| `score_final` | BuildCouncilStrategy_* | **NO** (explicit comment: "no-score selection") | **NO** | NO | NO | Diagnostic — feeds council_quality math only |
| `bestScore` (aggregator local) | BuildCouncilAggregateReport | NO (it's tracked separately from bestContribution) | NO | NO | NO | Diagnostic — used only in council_quality calculation |
| `bestContribution` (aggregator local) | BuildCouncilAggregateReport | **YES** — this IS the best_strategy_id selector | NO | NO | NO | Authority for best_strategy_id selection only |
| `council_quality` | BuildCouncilAggregateReport | NO | Diagnostic gate only (pre_ai_would_have_gated_quality = true but no live REJECT) | NO | NO | Diagnostic only (score gates demoted by A2) |
| `vote_weight` | BuildCouncilStrategy_* | YES (feeds bestContribution) | YES (feeds buy/sell weight totals → consensus) | NO | NO (indirectly via consensus) | Authority-bearing for consensus direction and best selection |
| `confidence` | BuildCouncilStrategy_* | NO | NO | NO | NO | Diagnostic only |
| `trigger_quality` | BuildCouncilStrategy_* | NO | NO | NO | NO | Diagnostic only |
| `confirmation_quality` | BuildCouncilStrategy_* | NO | NO | NO | NO | Diagnostic only |
| `zone_alignment_score` | BuildCouncilStrategy_* | NO | NO | NO | NO | Diagnostic only |
| `postV1Weight` (aggregator local) | BuildCouncilAggregateReport | **YES** — the actual selector | YES (feeds buy/sell weight totals) | NO | NO | Authority-bearing for consensus and best_strategy_id |
| `consensus_strength` | BuildCouncilAggregateReport | NO | NO (diagnostic gate — demoted) | Feeds HIGH_CONVICTION check | NO | PARTIALLY authority-bearing (HIGH_CONVICTION) |
| `conflict_score` | BuildCouncilAggregateReport | NO | NO (diagnostic gate — demoted) | Feeds HIGH_CONVICTION check | NO | Diagnostic only post-A2 |

**Key distinction for score_final:**
- Score_final IS written to the ledger
- Score_final IS used to compute bestScore
- bestScore IS used to adjust council_quality (diagnostic)
- BUT: best_strategy_id is NOT selected based on score_final (line 279–286 comment and code explicitly use bestContribution = postV1Weight, not bestScore)
- Score_final does NOT determine final_decision
- Score_final does NOT determine permission or execution

**Score fields are diagnostic/attribution only post-A2.** The no-score selection for best_strategy_id was the correct design choice from Package 1.

---

## J. IRREW Doctrine Check

### J1. best_strategy_id = thesis identity only?

**PARTIALLY. With one exception.**

Best_strategy_id is thesis identity in the council pipeline, governor, and all attribution paths. But it bleeds into execution authority via `RuntimeInferDecisionCandidateFromRouted` → `RuntimeOperatingCohortAdmissionAllowsExecution`.

When best_strategy_id's family is not in the operating cohort (e.g., if fvg_tpb is best_strategy_id), the execution is blocked. This means best_strategy_id IS currently an execution-blocking authority in that scenario.

Under normal operating conditions (the 17 original strategies dominate weight), this path never triggers. But it is a structural design property that exists.

**Verdict: PASS_WITH_CAVEAT**

### J2. V1 = permission authority?

**YES.** RunCouncilPreAIFilter retains full structural gate authority. Gates DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE, NO_TRADE all operate independently of best_strategy_id. Score gates remain diagnostic-only (post-A2). The pre-AI filter does NOT read best_strategy_id.

**Verdict: PASS**

### J3. Risk = protection authority?

**YES.** The operating risk envelope (`gOperatingRiskEnvelope`) blocks execution through `RuntimeOperatingCohortAdmissionAllowsExecution` but this is checked separately from best_strategy_id (it checks the risk envelope state, not the candidate identity). Verified: council_pre_ai_filter.mqh and core_trade_engine.mqh have zero references to best_strategy_id.

**Verdict: PASS**

### J4. Execution = survivability authority?

**YES.** `core_trade_engine.mqh` has zero references to best_strategy_id, primary_executor_id, or any council thesis field. All stop/TP/lot sizing decisions are made from OHLCV data and risk parameters, not strategy identity.

**Verdict: PASS**

### J5. Attribution = learning authority?

**YES.** All fvg_/ifr_ fields in the opportunity ledger are write-only. The V1C record contains best_strategy_id, primary_executor_id, and primary_packet_id for post-trade attribution but none of these fields are consumed by any decision layer. SCM, performance journal, and feedback records all reference best_strategy_id for attribution only.

**Verdict: PASS**

### J6. Layer leakage summary

| Layer | Has authority leakage? | From what? |
|---|---|---|
| V1 permission (pre-AI filter) | NO | Clean — does not read best_strategy_id |
| Aggregation | NO | best_strategy_id is output, not circular |
| Governor | NO | target_strategy_id is advisory, never applied |
| Cohort admission (execution gate) | **YES** | Uses best_strategy_id family for family-level admission check |
| Risk envelope | NO | Checks envelope state, not best_strategy_id |
| Core execution | NO | Zero council thesis fields consumed |
| Attribution/ledger | NO | Write-only from decision layer's perspective |

**Net: ONE layer leakage — cohort admission gate uses best_strategy_id as candidate identity.** Under current operating conditions, this produces correct behavior (blocks IFR-led execution because IFR is not in cohort) but through the wrong semantic mechanism.

---

## K. FVG_TPB / IFR Specific Findings

### K1. Can fvg_tpb become best_strategy_id when non-hostile and eligible?

**YES — conditionally.** With post-V1 weight 0.585 in active zones, fvg_tpb can become best_strategy_id if all higher-weighted strategies have lower effective weight (e.g., eligibility-blocked, OBSERVE_ONLY with 0.15×, or V1-deprioritized). Under normal competition, fvg_tpb at 0.585 is below most existing strategies' weights.

### K2. Can hostile SELL_TREND_DOWN become best_strategy_id?

**NO.** In the hostile path, `r.vote_weight = 0.0` is explicitly set before CouncilFinalizeStrategyReport is called. The aggregator applies role multiplier: 0.0 × 1.00 = 0.0. V1 FSW: 0.0 × 0.90 = 0.0. The selector condition `weight > 0.0` is false. Hostile fvg_tpb is permanently excluded from best_strategy_id selection.

**This is correct and safe.**

### K3. If FVG_TPB is best_strategy_id, does that imply trade permission?

**NO — but it does imply a specific execution blocker.** best_strategy_id does not grant permission. The pre-AI structural gates determine BUY/SELL permission independently. However, IF the final_decision is BUY/SELL AND fvg_tpb is best_strategy_id, the cohort admission check will fail because `LAB_InferFamilyFromStrategyId("fvg_tpb")` returns "UNKNOWN", which is not in the cohort. Execution is blocked.

**Net effect:** If fvg_tpb were to become best_strategy_id, the trade would be blocked by cohort admission (not by any FVG-specific logic). The block reason would be "candidate_not_in_active_operating_cohort" — a misleading diagnostic because the actual issue is that IFR is not yet cohort-admitted, not that the council made an error.

### K4. Does IFR family CONDITIONAL/REDUCED status affect best selection?

**YES — via V1 FSW multiplier.** IMBALANCE_FILL_REVERSAL receives a hardcoded 0.90 multiplier (CONDITIONAL). This reduces fvg_tpb's effective weight from 0.65 to 0.585, making it less likely to be best_strategy_id compared to NATIVE families.

### K5. Does IFR family status affect CRR/DSN/HIGH_CONVICTION?

**NO.** The pre-AI filter checks for the presence of CONFIRM role strategies (CRR), family diversity score (DSN), and consensus strength (HIGH_CONVICTION). These do not reference fvg_tpb's family classification or best_strategy_id. fvg_tpb's SCOUT role with positive weight CAN contribute to family diversity (reducing DSN risk if it's from a new family) and to consensus strength.

### K6. Does IFR playbook state affect best selection?

**NO.** OL_PlaybookShadowState and its playbook_state field are computed AFTER the aggregation loop, in Stage 18.5 (post-decision). They are write-only to the ledger. They have no feedback into the aggregation or gate layers.

### K7. Are fvg_/ifr_ fields consumed only by ledger/summary?

**YES — confirmed by static validation.** zero fvg_/ifr_ references in council_aggregator.mqh, council_pre_ai_filter.mqh, council_ai_governor.mqh, core_trade_engine.mqh, main_ea.mq5.

### K8. Can FVG_TPB become primary thesis while V1 still rejects the trade?

**YES — and this is correct behavior.** fvg_tpb can be best_strategy_id (highest weight) while:
1. The pre-AI filter rejects the trade (DSN failure, CRR failure, DOMINANT_SIDE issue)
2. The final_decision is REJECT or WAIT
3. No execution occurs

In this case, the ledger records best_strategy_id="fvg_tpb" with final_decision=REJECT and suppression_reason identifying the gate that blocked it. This is exactly what the IFR playbook attribution system is designed to capture: V1 rejected despite fvg_tpb forming thesis.

### K9. Is that behavior correctly recorded and interpreted?

**YES.** The V1C record contains:
- `best_strategy_id = "fvg_tpb"`
- `final_decision = "WAIT" or "REJECT"`
- `suppression_reason = "DIVERSITY_SAFETY_NET" or "CONFIRM_ROLE_REQUIRED"`
- `playbook_state = "PLAYBOOK_FORMING"`
- `runtime_authority_status = "MT5_UNCHANGED"`

This gives the full picture: fvg_tpb wanted to trade, V1 blocked it, IFR is in FORMING state. Completely auditable.

### K10. Conflict between best_strategy_id=fvg_tpb and playbook_state=FORMING?

**NO conflict — by design.** FORMING is the maximum IFR state and explicitly represents "alpha anchor present but confirmation chain not established." When fvg_tpb is best_strategy_id and playbook_state=FORMING, it means: "fvg_tpb is the leading weight contributor; IFR has an active alpha signal; V1 has not yet confirmed." This is the intended behavior. FORMING is not an error state.

---

## L. Failure Modes

| # | Mode | Possible? | Why | Severity | Mitigation |
|---|---|---|---|---|---|
| 1 | WAIT strategy becomes best_strategy_id | **YES** | Aggregator does not filter by decision type; positive-weight WAIT strategy eligible | LOW | Semantic gap only — does not cause false trades; final_decision determined independently |
| 2 | BLOCKED strategy becomes best_strategy_id | **NO** | BLOCKED → weight=0.0 → excluded by `weight > 0.0` check | N/A | Built-in |
| 3 | Hostile attribution becomes best_strategy_id | **NO (post-fix)** | Hostile gate sets vote_weight=0.0; excluded by weight>0 check | N/A | Correct in current impl |
| 4 | trigger_present=false strategy becomes best_strategy_id | **YES** | trigger_present not checked; positive-weight non-triggering strategy eligible | LOW | Semantic gap; does not affect execution |
| 5 | OBSERVE_ONLY strategy becomes best_strategy_id | **YES (rare)** | OBSERVE_ONLY × 0.15 not excluded; could be highest if all others blocked/lower | MEDIUM | Unlikely under normal conditions; would mean "thesis" is a silent observer |
| 6 | zero-weight strategy becomes best_strategy_id | **NO** | `weight > 0.0` check excludes it | N/A | Built-in |
| 7 | family UNKNOWN strategy becomes best_strategy_id | **YES** | fvg_tpb returns "UNKNOWN" from LAB_InferFamilyFromStrategyId; would be UNKNOWN best | MEDIUM | **Latent bug: requires LAB registry update** |
| 8 | best_strategy_id contradicts consensus_direction | **YES** | If best strategy says WAIT but BUY wins by weight majority | LOW | Not a problem — best is by individual weight, not direction agreement |
| 9 | best_strategy_id contradicts final_decision | **YES** | Very common: best can be a WAIT strategy while final_decision=BUY | LOW | By design — best is not decision; attribution only |
| 10 | best_strategy_id used downstream as execution owner | **YES (partially)** | Cohort admission path uses best_strategy_id family | **HIGH (latent)** | Requires semantic cleanup — see Section N |
| 11 | Ledger records best_strategy_id misleadingly | **POSSIBLE** | If WAIT-deciding strategy is best, ledger shows it as thesis which may not reflect the actual triggering strategies | MEDIUM | Acceptable until contract tightened |
| 12 | V1 rejects but attribution suggests strategy "won" | **NOT A BUG** | V1C explicitly records suppression_reason; FORMING is the correct state | N/A | Designed correctly |
| 13 | best_strategy_id changes due score defaulting / finalizer | **NO** | CouncilFinalizeStrategyReport only sets fields not yet set; does not change vote_weight (selection input) | N/A | Safe |
| 14 | best_strategy_id uses stale report data | **NO** | All reports are fresh per pipeline run; static state in fvg_tpb is within-session only | N/A | Cold-start limitation documented separately |

**Most critical active failure mode:** Failure mode 7 + 10 combined: if fvg_tpb becomes best_strategy_id, cohort admission blocks execution with misleading reason "UNKNOWN family" rather than the true reason "IMBALANCE_FILL_REVERSAL not in cohort." The execution outcome is correct (blocked) but the diagnostic trace is wrong.

---

## M. Recommended Semantic Contract

### M1. Ideal best_strategy_id contract

1. `best_strategy_id` = thesis identity only. It identifies which strategy contributed the leading alpha signal.
2. Selection should be from strategies with:
   - trigger_present=true AND decision=BUY or SELL
   - eligibility not BLOCKED
   - post-policy weight > 0
   - not hostile-suppressed (vote_weight=0)
3. If no such strategy exists: best_strategy_id = "" (empty — no thesis)
4. WAIT-deciding strategies: should NOT be selected as best_strategy_id (thesis without direction is not a thesis)
5. OBSERVE_ONLY strategies: should NOT be best_strategy_id (they are observers, not thesis leaders)
6. Cohort admission should NOT use best_strategy_id — it should use the dominant_side and aggregate direction
7. Ledger must include both best_strategy_id AND the triggering strategy IDs

### M2. Current implementation vs ideal contract

| Contract point | Current behavior | Gap |
|---|---|---|
| Trigger-present filter | NOT enforced | GAP — WAIT strategies eligible |
| Direction filter (BUY/SELL) | NOT enforced | GAP — WAIT strategies eligible |
| BLOCKED exclusion | ENFORCED (weight=0) | OK |
| Hostile exclusion | ENFORCED (weight=0 in hostile path) | OK |
| OBSERVE_ONLY exclusion | NOT enforced (0.15× reduces but doesn't exclude) | GAP (rare) |
| Post-policy weight selector | ENFORCED | OK |
| Cohort admission decoupled | NOT decoupled | AUTHORITY LEAKAGE GAP |
| Empty string when no thesis | POSSIBLE (if all weights=0) | OK |
| Ledger completeness | PARTIAL (best_strategy_id + trigger_present per-strategy in separate records) | Acceptable |

### M3. Recommended future rename

Current name `best_strategy_id` suggests "best strategy selected to trade." The field semantically means "thesis identity" in IRREW doctrine. Recommended rename (non-breaking, can be applied in a future cleanup package):

- `primary_thesis_strategy_id` — clearest semantic alignment with IRREW doctrine
- OR `leading_alpha_strategy_id` — emphasizes it's the alpha signal, not the permitted executor

Any rename must update all 23+ occurrences across council_mode_types.mqh, council_aggregator.mqh, council_ai_governor.mqh, council_mode_runtime.mqh, main_ea.mq5, council_feedback.mqh, council_txt_reporter.mqh, council_governor.mqh.

---

## N. Required Fixes

### N1. HIGH PRIORITY: Update LAB_InferFamilyFromStrategyId for fvg_tpb

**File:** level_awareness_brake.mqh
**Function:** `LAB_InferFamilyFromStrategyId`
**Location:** Line 61+
**Fix:** Add `if(strategy_id == "fvg_tpb") return "IMBALANCE_FILL_REVERSAL";` before the fallback `return "UNKNOWN"`
**Why required:** Every consumer of `LAB_InferFamilyFromStrategyId("fvg_tpb")` currently gets "UNKNOWN". This causes:
- Incorrect diagnostic trace in cohort admission ("UNKNOWN" vs "IMBALANCE_FILL_REVERSAL")
- Incorrect family classification in SCM, AI advisory, performance journal
- Misleading AI advisory packet (relevant_strategy_family = "UNKNOWN" instead of correct family)

**Note:** Even after this fix, IMBALANCE_FILL_REVERSAL is not in the operating cohort. If fvg_tpb is best_strategy_id, execution would still be blocked with "candidate_not_in_active_operating_cohort" but the diagnostic would be correct ("IMBALANCE_FILL_REVERSAL not in cohort" instead of "UNKNOWN family not in cohort").

**Authorization status:** This is a minimal maintenance fix touching one .mqh file (no council logic, no gate, no aggregation). Bounded Codex task: add one line to LAB_InferFamilyFromStrategyId.

### N2. MEDIUM PRIORITY: Document cohort admission path's use of best_strategy_id

**Scope:** Architecture documentation only
**Action:** Update PIML and/or report to acknowledge that `RuntimeOperatingCohortAdmissionAllowsExecution` uses best_strategy_id as the candidate identity, making best_strategy_id execution-blocking when its family is not in the operating cohort.
**This is a property of the current architecture, not introduced by FVG_TPB.** It is a pre-existing design choice that becomes visible now because fvg_tpb's family (IMBALANCE_FILL_REVERSAL) is not in the cohort.

### N3. LOW PRIORITY: Consider aggregator trigger_present filter

**Scope:** council_aggregator.mqh best_strategy_id selection logic
**Action:** Add `trigger_present` and `decision != WAIT` filter to the best_strategy_id selection at lines 282–286
**Current:** Any positive-weight strategy can be best_strategy_id regardless of trigger or direction
**Improved:** Only strategies that triggered AND have directional decisions (BUY/SELL) qualify
**Impact:** Makes best_strategy_id semantically "leading thesis" rather than "highest-weighted participant"
**Caveat:** Could result in best_strategy_id="" on bars where no strategy triggers but council still approves (based on aggregate direction). Need to evaluate impact on downstream consumers that assume non-empty best_strategy_id.
**Authorization status:** NOT authorized as part of this audit. Requires separate design + operator approval.

---

## O. Non-Blocking Improvements

1. **LAB_InferFamilyFromStrategyId registry maintenance policy**: Establish that any new strategy admission must add a registry entry to LAB_InferFamilyFromStrategyId as part of its implementation package. FVG_TPB missed this in FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1.

2. **best_strategy_id "empty thesis" semantic**: Document clearly that empty best_strategy_id ("") is valid and means "no leading thesis identified in this council evaluation." Some downstream consumers use fallback logic (lines 3659–3662 in main_ea.mq5 fall back to previous candidate name) — this is acceptable but should be documented.

3. **governor change_vote_weights flag**: The `CouncilPolicyAdjustment.change_vote_weights` and `new_vote_weight` fields in council_governor.mqh line 93–95 are set but never consumed by any runtime code. This is the correct behavior (governor is advisory only) but the dead code could mislead future readers into thinking weights are dynamically adjusted. Consider marking as explicitly advisory or removing the assignment.

4. **Rename `bestContribution` to `bestWeight` in aggregator**: The local variable name `bestContribution` at council_aggregator.mqh:170 is slightly misleading. Renaming to `bestWeight` would make it clear it tracks the highest post-V1 weight, not "contribution" to consensus.

---

## P. What Must Not Be Concluded

1. **Do NOT conclude that FVG_TPB broke the cohort admission path.** The cohort admission mechanism using best_strategy_id family was in place before FVG_TPB. FVG_TPB merely exposed the latent issue by introducing a strategy with an out-of-cohort family.

2. **Do NOT conclude that best_strategy_id=fvg_tpb means a trade was authorized.** best_strategy_id appearing as fvg_tpb in any record only means fvg_tpb had the highest post-V1 weight on that bar. The record will also show final_decision=REJECT or WAIT (since even if pre-AI passes, cohort admission blocks the actual execution).

3. **Do NOT conclude that score_final determines best_strategy_id.** The aggregator explicitly uses weight, not score. The comment at line 279 is authoritative: "Package 1 -- authority-facing best_strategy_id is selected by no-score live contribution, not score_final."

4. **Do NOT conclude that governor target_strategy_id has any live authority.** `change_vote_weights` and `new_vote_weight` in CouncilPolicyAdjustment are never applied anywhere. They are advisory artifacts.

5. **Do NOT conclude that IFR FORMING state requires architectural intervention.** FORMING is the correct and expected state for IFR until a CONFIRMATION_PACKET is defined. VALID is permanently withheld by design.

6. **Do NOT conclude that this audit approves promotion of IMBALANCE_FILL_REVERSAL into the operating cohort.** The cohort composition is a separate governance decision requiring Nautilus evidence, live runtime data, and operator authorization. This audit only identifies the semantic mismatch.

---

## Q. Final Recommendation

**Verdict: PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP**

### Q1. Is reload still allowed?

**YES.** No blocker found. The AUTHORITY_LEAKAGE finding (cohort admission path) produces the CORRECT behavioral outcome for fvg_tpb (execution blocked because IFR not in cohort). The LAB_InferFamilyFromStrategyId gap is a diagnostic clarity issue, not a safety issue.

### Q2. Does this audit reveal any blocker?

**NO.** The only required fix (LAB_InferFamilyFromStrategyId update for fvg_tpb) is a maintenance fix, not a safety blocker. The system functions as designed under current operating conditions.

### Q3. Does best_strategy_id currently affect permission?

**NO — directly.** The pre-AI filter does not read best_strategy_id. Permission gates (DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE) are independent.

**YES — indirectly via cohort admission.** If fvg_tpb is best_strategy_id, the cohort admission gate blocks execution. This is an indirect execution effect. Under normal competition, fvg_tpb (0.585 effective weight) is unlikely to be best_strategy_id.

### Q4. Does best_strategy_id currently affect execution?

**YES — through cohort admission path.** This is the primary AUTHORITY_LEAKAGE finding. The severity is LOW under current conditions (fvg_tpb unlikely to be best) but MEDIUM in principle.

### Q5. Does best_strategy_id need rename or contract clarification?

**YES — future cleanup.** The name implies "best strategy selected to execute." The correct meaning is "highest-weighted strategy in the current bar's council evaluation." Rename to `primary_thesis_strategy_id` in a future bounded cleanup task after sufficient runtime evidence is accumulated.

### Q6. Are score fields still authority-bearing?

**NO.** Score fields (score_final, council_quality, confidence) are diagnostic only post-A2. The no-score weight-based selection for best_strategy_id is correct and intact. Score gates are explicitly demoted to diagnostics.

### Q7. What exact follow-up package is recommended?

**Required (bounded single-file fix):**
- `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1`: Add `if(strategy_id == "fvg_tpb") return "IMBALANCE_FILL_REVERSAL";` to level_awareness_brake.mqh:LAB_InferFamilyFromStrategyId. One line, one file, no compile risk.

**Non-urgent (deferred to IRREW Phase 4/6 cleanup window):**
- Document cohort admission authority leakage path in architecture notes
- Consider aggregator trigger_present + direction filter for best_strategy_id semantics
- Consider rename to primary_thesis_strategy_id at IRREW Phase 6 weight cleanup milestone

**Do not authorize:**
- Promoting IMBALANCE_FILL_REVERSAL into operating cohort without Nautilus evidence and live runtime sample
- Changing cohort admission logic to bypass best_strategy_id family check
- Any modification to V1 permission gates, aggregation logic, or stop geometry

---

## Audit Footer

```
AUDIT_ID:                        BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1
AUDIT_DATE:                      2026-05-09
FILES_INSPECTED:                 council_aggregator.mqh, council_mode_types.mqh,
                                 council_ai_governor.mqh, council_governor.mqh,
                                 council_pre_ai_filter.mqh, council_mode_runtime.mqh,
                                 council_v1_state_composer.mqh, level_awareness_brake.mqh,
                                 main_ea.mq5 (selected sections)
VERDICT:                         PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP
RELOAD_ALLOWED:                  YES
BLOCKER_FOUND:                   NO
AUTHORITY_LEAKAGE_FOUND:         YES — cohort admission path (indirect, latent)
SEVERITY:                        MEDIUM (latent, produces correct behavior today)
REQUIRED_FIX:                    LAB_InferFamilyFromStrategyId: add fvg_tpb → IMBALANCE_FILL_REVERSAL
SCORE_FIELDS_AUTHORITY_BEARING:  NO (demoted to diagnostic post-A2)
BEST_STRATEGY_ID_AFFECTS_DECISION: NO (direct); YES (indirect via cohort admission)
BEST_STRATEGY_ID_AFFECTS_EXEC:   YES (via cohort admission family check)
FVG_TPB_HOSTILE_BUG:             NO — hostile path correctly sets weight=0.0
FVG_TPB_WAIT_BUG:                NO — WAIT fvg_tpb can be best but does not cause trade
IFR_FORMING_STATE_CORRECT:       YES — VALID withheld by design
GOVERNOR_ADVISORY_CONFIRMED:     YES — change_vote_weights never applied
FOLLOW_UP_PACKAGE:               LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1 (bounded, one-line)
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
MT5_RELOAD:                      NO
```
