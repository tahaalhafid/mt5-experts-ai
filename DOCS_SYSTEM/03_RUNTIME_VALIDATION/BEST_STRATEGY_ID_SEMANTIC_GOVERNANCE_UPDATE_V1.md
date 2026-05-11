# BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1

**Status:** ACCEPTED — DOCUMENTED  
**Date:** 2026-05-09  
**Classification:** SEMANTIC / IDENTITY / GOVERNANCE WORK  
**Scope:** Post-IRREW / PCEA V1C / IFR / FVG_TPB governance and semantic boundary update  
**Authority:** DOCUMENTATION ONLY — No MT5 source change. No runtime change. No compile. No reload.  
**Governed by:** PROJECT_INTELLIGENCE_MEMORY_LAYER.md (PIML) — sole authoritative project memory  
**Based on:** BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1 (verdict: PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP)

---

## 1. Executive Summary

The BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1 is accepted as directionally aligned with the PCEA/IRREW doctrine. The full 10-section source inspection confirmed that:

- `best_strategy_id` operates **substantially** as thesis/attribution identity. It does not directly authorize BUY, SELL, WAIT, or REJECT.
- The pre-AI filter (V1 permission layer) does not read `best_strategy_id` for DSN, CRR, or HIGH_CONVICTION decisions.
- The risk envelope does not consume thesis identity fields.
- Core execution (`core_trade_engine.mqh`) has zero references to `best_strategy_id`, `primary_executor_id`, or any council thesis field.
- All `fvg_/ifr_` attribution fields are write-only to the ledger and have no decision authority.
- Governor `target_strategy_id` and `change_vote_weights` are advisory and are never applied by any runtime code.

**One semantic caveat exists:** Cohort admission (`RuntimeOperatingCohortAdmissionAllowsExecution`) infers execution candidate family from `best_strategy_id`. This gives `best_strategy_id` an indirect execution-blocking role when its inferred family is outside the operating cohort.

**This caveat is not a reload blocker.** It does not cause false execution. It produces the correct behavioral outcome (blocks IFR-led trades because IFR is not in cohort) through an impure semantic mechanism. The caveat requires governance documentation and a deferred cleanup roadmap, not immediate source intervention.

**Immediate cleanup completed:** `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1` — `fvg_tpb` now correctly maps to `IMBALANCE_FILL_REVERSAL` in `LAB_InferFamilyFromStrategyId`. Compile-verified. Diagnostic clarity improved; no permission or cohort change made.

**System status: DEVELOPING — unchanged.**

---

## 2. Accepted Doctrine

The following doctrine is formally adopted for this project. It governs how each authority layer relates to strategy identity and how semantic boundaries must be maintained in all future implementation packages.

```
best_strategy_id   = thesis / attribution identity
V1                 = permission authority
Risk               = protection authority
Execution          = survivability authority
Attribution        = learning authority
```

**Operationally:**

| Doctrine line | What it means in the codebase |
|---|---|
| `best_strategy_id = thesis identity` | Identifies the strategy with the highest post-V1 adjusted weight in the current bar's council evaluation. Names the leading alpha signal for attribution, diagnostics, logging, and ledger. Does not name the "executor" or the "permitted trader." |
| `V1 = permission authority` | `RunCouncilPreAIFilter` holds structural gate authority (DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE, NO_TRADE). These gates operate independently of `best_strategy_id`. Score gates remain diagnostic-only post-A2. V1 is the only layer authorized to emit a final permission decision. |
| `Risk = protection authority` | The operating risk envelope (`gOperatingRiskEnvelope`) and risk-level state govern whether execution is attempted. This check is independent of thesis identity; it operates on envelope state, not candidate name. |
| `Execution = survivability authority` | `core_trade_engine.mqh` governs stop, TP, and lot sizing from OHLCV data and risk parameters. It has zero references to `best_strategy_id`, `primary_executor_id`, playbook state, or any council thesis field. The execution layer has no knowledge of council identity. |
| `Attribution = learning authority` | SCM (Strategy Confidence Memory), performance journal, feedback records, opportunity ledger, and `fvg_/ifr_` fields all reference `best_strategy_id` for post-trade learning. These paths are write-only from the decision layer's perspective. No attribution field is consumed by any permission, risk, or execution gate. |

---

## 3. Current Functional Meaning of best_strategy_id

`best_strategy_id` is computed during `BuildCouncilAggregateReport` (council_aggregator.mqh, stage 3 of the pipeline). It is fixed for the duration of the bar once aggregation completes.

**Selection algorithm:**

The field is set to the `strategy_id` of the strategy with the highest `postV1Weight` among all valid, enabled, non-BLOCKED strategies:

```
postV1Weight = vote_weight × role_influence_multiplier × eligibility_multiplier × V1_FSW_multiplier

Selected if: postV1Weight > 0.0  AND  postV1Weight > any previously seen value
```

**Critical properties of the selection:**

| Property | Behavior |
|---|---|
| Selector input | Post-V1 adjusted weight (`postV1Weight`) — NOT `score_final` |
| Score involvement | `score_final` tracked separately as `bestScore` (diagnostic only, feeds `council_quality` math) |
| Direction filter | NOT enforced — WAIT-deciding strategies with positive weight are eligible |
| `trigger_present` filter | NOT enforced — non-triggering strategies are eligible |
| BLOCKED exclusion | ENFORCED — BLOCKED → weight=0.0 → excluded by `weight > 0.0` check |
| Hostile exclusion | ENFORCED — hostile path sets `vote_weight=0.0` → excluded |
| OBSERVE_ONLY exclusion | NOT enforced — OBSERVE_ONLY × 0.15 discounts but does not exclude |
| Empty result | Possible if all weights = 0.0 (all BLOCKED) — empty string is valid |

**Allowed uses:**
- Thesis attribution in feedback, SCM, performance journal, ledger records
- Diagnostic output (dashboard, decision signature, runtime reports)
- Advisory context (governor, AI advisory packet, family inference for advisory)
- Council setup lifecycle signal identity (flag-gated, conditional)

**Forbidden interpretations:**
- `best_strategy_id` is NOT the strategy that was permitted to trade
- `best_strategy_id` is NOT the strategy that was executed
- `best_strategy_id` is NOT the output of the permission layer
- `best_strategy_id` appearing in a record does NOT mean that strategy's signal was approved
- A record showing `best_strategy_id = "fvg_tpb"` does NOT mean FVG_TPB was permitted or executed
- `best_strategy_id` must NOT be interpreted as trade authorization of any kind

**`best_strategy_id` in the ledger:** When a record shows `best_strategy_id = X`, the record also contains `final_decision`, `suppression_reason`, `runtime_authority_status`, and `actual_trade`. These fields collectively describe what happened. `best_strategy_id` alone is insufficient to infer trade outcome.

---

## 4. Current Caveat: Cohort Admission Authority Leakage

### 4.1 The Leakage Path

`RuntimeInferDecisionCandidateFromRouted` (main_ea.mq5, lines 2995–3016) reads `agg.best_strategy_id` and sets:

```
gCurrentDecisionCandidateName   = best_strategy_id
gCurrentDecisionCandidateFamily = LAB_InferFamilyFromStrategyId(best_strategy_id)
```

`RuntimeOperatingCohortAdmissionAllowsExecution` (main_ea.mq5, lines 3018–3047) then checks `OperatingCohortFamilyAllowed(candidateFamily)`. If the inferred family is not in the operating cohort `{LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT}`, execution is blocked.

**This makes `best_strategy_id` execution-blocking in one structural scenario:** when its inferred family is outside the operating cohort.

### 4.2 Current Behavior for FVG_TPB

Before `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1`:
- `LAB_InferFamilyFromStrategyId("fvg_tpb")` → `"UNKNOWN"` (registry gap)
- Cohort check → `"UNKNOWN"` not in cohort → execution blocked
- Diagnostic trace: `"candidate_not_in_active_operating_cohort"` with `candidateFamily="UNKNOWN"` — **misleading**

After `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1`:
- `LAB_InferFamilyFromStrategyId("fvg_tpb")` → `"IMBALANCE_FILL_REVERSAL"`
- Cohort check → `"IMBALANCE_FILL_REVERSAL"` not in cohort → execution blocked
- Diagnostic trace: `"candidate_not_in_active_operating_cohort"` with `candidateFamily="IMBALANCE_FILL_REVERSAL"` — **correct and auditable**

**The behavioral outcome is identical in both cases: execution is blocked.** The LAB fix improves diagnostic clarity only. It does not promote FVG_TPB. It does not add IMBALANCE_FILL_REVERSAL to the cohort.

### 4.3 Semantic Purity Problem

The IRREW doctrine requires:

> `best_strategy_id` describes who formed the thesis.  
> It must **not** be the source of execution-admission family.

The current architecture uses `best_strategy_id` as the identity from which `candidateFamily` is derived for the cohort gate. This conflates two separate concerns:

- **Thesis identity:** Which strategy had the highest alpha signal on this bar?
- **Execution admission identity:** Which family is the council nominating for execution?

These are the same under normal conditions (the 17 original strategies all belong to admitted families), but diverge when a non-admitted strategy (like `fvg_tpb`) achieves the highest weight.

**The separation should be structural, not coincidental.** A `best_strategy_id` from an out-of-cohort family should not silently block execution through the admission path — it should be blocked explicitly by a gate that reads aggregate direction rather than thesis identity.

### 4.4 Current Safety Assessment

**SAFE under current operating conditions.** Under normal competition, `fvg_tpb` with post-V1 weight 0.585 (REV/RMR active zone) is below most competing strategies' effective weights. The probability of `fvg_tpb` becoming `best_strategy_id` is low. Even if it does, the behavioral outcome (execution blocked, IFR not in cohort) is correct. No false execution results from this caveat.

**MEDIUM severity in principle.** The leakage path is a structural design property, not a new bug introduced by FVG_TPB. FVG_TPB made it visible by being the first admitted strategy whose family (IMBALANCE_FILL_REVERSAL) is not in the operating cohort.

---

## 5. Immediate Cleanup Completed

### LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1

**Status:** COMPLETE — COMPILE_VERIFIED

| Field | Value |
|---|---|
| Fix ID | LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1 |
| File modified | `level_awareness_brake.mqh` |
| Function modified | `LAB_InferFamilyFromStrategyId()` |
| Line added | `if(strategy_id == "fvg_tpb") return "IMBALANCE_FILL_REVERSAL";` (before fallback `return "UNKNOWN"`) |
| Compile result | 0 errors, 0 warnings |
| Binary timestamp | 2026-05-09 12:50:10 |
| Binary size | 2,660,892 bytes |
| Pre-fix backup | `D:\MT5_Project_Backups\pre_change_20260509_124349_LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1.zip` |
| Local backup | `level_awareness_brake.mqh.bak_20260509_124349` |
| Report | `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1_REPORT.md` |

**Functional effect:** `LAB_InferFamilyFromStrategyId("fvg_tpb")` now returns `"IMBALANCE_FILL_REVERSAL"` instead of the fallback `"UNKNOWN"`. All downstream consumers that infer strategy family from strategy_id now produce the correct trace for fvg_tpb (cohort admission diagnostic, SCM, AI advisory packet, performance journal family field).

**What did NOT change:**

| Component | Changed? |
|---|---|
| Gates (DSN, CRR, HIGH_CONVICTION, DOMINANT_SIDE) | NO |
| Operating cohort composition | NO — IMBALANCE_FILL_REVERSAL still not admitted |
| FVG_TPB vote_weight, role, eligibility | NO |
| V1 permission logic | NO |
| Aggregation logic | NO |
| Risk logic | NO |
| Execution logic | NO |
| Any runtime JSON/JSONL file | NO |
| Council quality thresholds | NO |
| Cohort admission logic | NO — same gate, better diagnostic trace only |

**After this fix:** If `fvg_tpb` is ever `best_strategy_id` and the council produces a BUY/SELL decision, the cohort admission gate correctly reports `"IMBALANCE_FILL_REVERSAL not in active operating cohort"` and blocks execution — with an accurate, auditable trace instead of the opaque `"UNKNOWN family"` trace.

---

## 6. Playbook Runtime Authority Firewall

The following fields are **shadow / ledger / attribution only**. They operate exclusively in the post-decision write path. They have no feedback into the pre-decision pipeline.

**Shadow and ledger-only fields:**

| Field | Location | Authority |
|---|---|---|
| `playbook_id` | `OL_PlaybookShadowState` | Attribution only — written to ledger |
| `playbook_state` | `OL_PlaybookShadowState` | Attribution only — written to ledger |
| `primary_packet_id` | `OL_PlaybookShadowState` | Attribution only — written to ledger |
| `fvg_direction` | `SFVGTriggerAttribution` | Attribution only — written to ledger when fvg_tpb triggers |
| `fvg_gap_low` / `fvg_gap_high` | `SFVGTriggerAttribution` | Attribution only |
| `fvg_regime_context` | `SFVGTriggerAttribution` | Attribution only |
| `fvg_subset_classification` | `SFVGTriggerAttribution` | Attribution only |
| `fvg_hostile_gate_fired` | `SFVGTriggerAttribution` | Attribution only |
| `fvg_size_atr`, `fvg_age_bars` | `SFVGTriggerAttribution` | Attribution only |
| `ifr_playbook_state` | V1C ledger | Attribution only |
| V1C shadow fields (all `ol_*`) | `council_mode_runtime.mqh` | Attribution only — no pre-decision read |
| `runtime_authority_status` | OL functions | Always `"NONE"` — confirmation field, not decision input |

**These fields must never feed:**

- Structural gates (DSN, CRR, DOMINANT_SIDE, NO_TRADE)
- Cohort admission checks
- Vote weights or effective weight computation
- `council_quality` calculation
- `consensus_strength` or `conflict_score` thresholds
- HIGH_CONVICTION determination
- Risk approval
- Execution approval
- Stop/target geometry
- Order permission
- Any other pre-decision input

**Canonical governance rule:**

> Playbook State may describe thesis completeness.  
> It must not authorize execution.

`PLAYBOOK_FORMING` means the alpha anchor is present. It is not a trade signal.  
`PLAYBOOK_VALID` is currently withheld for IFR by design (no CONFIRMATION_PACKET defined). When eventually emitted, it remains attribution only.  
`PLAYBOOK_CONTRADICTED` means the playbook thesis was contradicted. It does not mean block — V1 has already decided.  
`PLAYBOOK_NOT_PRESENT` means the playbook anchor was not triggered. It is an absence of evidence, not evidence of absence.

**Static validation (audit-confirmed):** Zero `fvg_/ifr_` references exist in `council_aggregator.mqh`, `council_pre_ai_filter.mqh`, `council_ai_governor.mqh`, `core_trade_engine.mqh`, or the BUY/SELL execution path in `main_ea.mq5`. Firewall is intact as of 2026-05-09.

---

## 7. New Strategy Identity Registry Rule

**Formal governance rule — effective immediately:**

No new strategy may be considered structurally integrated into the council unless all of the following identity properties are explicitly established at implementation time:

| Requirement | What must be documented |
|---|---|
| 1. `strategy_id` registered | The exact string ID used in `strategy_id` fields throughout the codebase |
| 2. `strategy_family` registered | The exact family name string (e.g., `"IMBALANCE_FILL_REVERSAL"`) |
| 3. `LAB_InferFamilyFromStrategyId` entry | A mapping line added to `level_awareness_brake.mqh:LAB_InferFamilyFromStrategyId` — REQUIRED at implementation time |
| 4. Packet role documented | Whether the strategy functions as ALPHA_TRIGGER_PACKET, CONFIRMATION_PACKET, LOCATION_PACKET, etc., or is marked `NONE` |
| 5. Playbook relationship documented | Which playbook the strategy belongs to, or `NONE` if standalone |
| 6. `runtime_authority_status` explicit | Must be `NONE` unless separately authorized through operator approval + bounded Codex task |
| 7. V1C/ledger mapping defined | If the strategy emits attribution fields beyond the standard ledger record (e.g., `fvg_/ifr_` fields), those fields must be listed and classified as attribution-only |
| 8. Cohort status explicit | One of: `ADMITTED / NOT_ADMITTED / CONDITIONAL / FORBIDDEN` — must be stated, not implied |
| 9. Rollback and trace behavior documented | How the strategy can be removed, frozen, or downgraded; what ledger trace it leaves after freeze |

**Purpose of this rule:** FVG_TPB was implemented without adding its family mapping to `LAB_InferFamilyFromStrategyId`. This created an `"UNKNOWN"` family trace in cohort admission diagnostics, SCM, and advisory fields. The fix was minimal (one line), but the gap should not have existed. This rule prevents future strategy integrations from creating silent identity opacity in the family inference layer.

**This rule applies to all future strategy admissions, including:**
- Any strategy admitted under a new or lifted factory_admission_lock
- Any external INEC-certified strategy converted to a bounded Codex implementation
- Any existing strategy whose family classification changes

---

## 8. Explicit Non-Authorizations

This governance update does **NOT** authorize any of the following. Each item is stated explicitly to prevent inference from silence.

**Permission layer:**
- No V1 permission logic change of any kind
- No CRR gate modification
- No DSN gate modification
- No HIGH_CONVICTION condition change
- No DOMINANT_SIDE logic change
- No score gate re-activation or authority restoration
- No P4 phase implementation (4A cross-family CRR, 4B exhaustion veto, 4C quality gate)

**Weight and quality:**
- No vote_weight change for any strategy
- No effective_weight formula change
- No `council_quality` threshold change
- No V1 FSW multiplier change for any family
- No `consensus_strength` threshold change

**Strategy and family status:**
- No cohort promotion for IMBALANCE_FILL_REVERSAL
- No cohort admission for FVG_TPB
- No IMBALANCE_FILL_REVERSAL admission of any kind
- No runtime playbook authority of any kind (IFR, RBSR, TPC, VCR)
- No factory admission lock general lift
- No new strategy injection
- No role change for any existing strategy

**Architecture:**
- No decoupling of cohort admission from `best_strategy_id` now
- No introduction of `execution_admission_family` field now
- No rename of `best_strategy_id` now
- No aggregator filter for `trigger_present` or `decision BUY/SELL` now
- No Level Brake change
- No risk envelope change
- No execution geometry change
- No stop/target modification

**System status:**
- No production readiness claim
- No maturity upgrade from DEVELOPING

---

## 9. Deferred Semantic Cleanup Roadmap

The following items are formally recorded as deferred. They are **not authorized for implementation** by this package. Each requires a separate operator authorization, a bounded design task, and (where applicable) a compile-verified Codex implementation.

### A. EXECUTION_ADMISSION_IDENTITY_DECOUPLING_V1

**What it is:** Structural decoupling of cohort admission from `best_strategy_id`.

**Current state:** `RuntimeOperatingCohortAdmissionAllowsExecution` uses `LAB_InferFamilyFromStrategyId(best_strategy_id)` to derive `candidateFamily` for the cohort check.

**Target state:** Introduce a separate `execution_admission_family` field derived from the council aggregate direction (dominant_side), not from thesis identity. `best_strategy_id` remains descriptive; the cohort gate reads a dedicated admission identity field.

**Why deferred:** Requires changes to main_ea.mq5 (cohort admission path) and council_aggregator.mqh (new field). Needs full consumer map and regression analysis. No urgency under current conditions (correct behavioral outcome despite impure mechanism). Must wait for Phase 4 design window and sufficient runtime data.

**Prerequisites before design:**
- Opportunity Ledger live with ≥ 200 records (confirms which strategies actually lead thesis on eligible bars)
- Phase 4 design window open (Phase 4A/4B/4C blockers cleared)
- Operator authorization for a separate decoupling task

### B. PRIMARY_THESIS_STRATEGY_ID_RENAME_DESIGN_V1

**What it is:** Rename `best_strategy_id` to `primary_thesis_strategy_id` across all consumers.

**Motivation:** The name `best_strategy_id` implies "best strategy selected to execute." The correct meaning is "thesis identity — the highest-weighted strategy in the current bar's council evaluation." The rename aligns the field name with IRREW doctrine.

**Scope:** 23+ occurrences across `council_mode_types.mqh`, `council_aggregator.mqh`, `council_ai_governor.mqh`, `council_mode_runtime.mqh`, `main_ea.mq5`, `council_feedback.mqh`, `council_txt_reporter.mqh`, `council_governor.mqh`.

**Why deferred:** High-occurrence rename across multiple files. Must not be done piecemeal. Requires a complete consumer map and coordinated multi-file Codex task. No runtime benefit until the rename is complete and consistent. Recommended at IRREW Phase 6 weight cleanup milestone when a multi-file maintenance window is already open.

**Prerequisites before implementation:**
- Complete consumer map (all 23+ occurrences documented)
- Operator authorization for the rename task
- At minimum IRREW Phase 4 complete (so the rename does not interfere with Phase 4 changes)

### C. PRIMARY_THESIS_SELECTION_CONTRACT_V1

**What it is:** Tighten the aggregator selection logic so `best_strategy_id` (or `primary_thesis_strategy_id` after rename) only selects from strategies that have a directional thesis on the current bar.

**Target filter:** A strategy qualifies for thesis selection only if:
- `trigger_present = true`
- `decision = BUY` or `decision = SELL` (not WAIT)
- `eligibility_state != BLOCKED`
- `eligibility_state != OBSERVE_ONLY`
- `postV1Weight > 0.0`

**Empty string behavior:** If no strategy meets the contract, `primary_thesis_strategy_id = ""` (no leading thesis on this bar). All downstream consumers of `best_strategy_id` must be updated to handle the empty case gracefully (most already have fallback logic).

**Why deferred:** Requires council_aggregator.mqh change and main_ea.mq5 fallback audit. Impact on Council Setup Lifecycle gate (which arms on `best_strategy_id`) needs careful analysis. Must follow the rename (B) to reduce confusion. Cannot be implemented before the empty-string consumer audit is complete.

**Prerequisites before design:**
- Deferred item B (rename) complete or co-designed
- Consumer audit confirming all 23+ sites handle empty `best_strategy_id`
- Opportunity Ledger data showing what fraction of bars have a qualifying thesis strategy

---

## 10. Runtime / Reload Implication

**Reload status: ALLOWED WITH CAVEATS (unchanged from prior audit verdict)**

This governance package does not change reload authorization status in either direction. The reload recommendation from `BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1` stands: `RELOAD_SAFE — NO BLOCKER FOUND`.

The compiled binary as of 2026-05-09 12:50:10 (post `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1`) is the current authoritative binary. MT5 has not yet been reloaded with this binary. Runtime validation of FVG_TPB and the LAB fix is pending operator-initiated EA reload.

**This package does not change any source file.** No recompile is required as a result of this governance update.

**System status: DEVELOPING — unchanged.** No intermediate phase completion at any point in the FVG_TPB / IFR / LAB fix sequence changes system status. Production readiness requires criteria stated in IRREW design: all Phase 3 certifications complete, Phase 4 live, 200+ trades under IRREW architecture, stable WR ≥ 42% for 60 days.

---

## 11. Required Future Validation

After operator-initiated EA reload, the following observations should confirm correct behavior of all packages in the FVG_TPB / IFR / LAB fix sequence:

| Check | Expected observation |
|---|---|
| fvg_tpb appears in `ai_opportunity_summary.json` | `ifr_state_seen_count ≥ 1` within first session |
| fvg_tpb family trace | Any LAB-family log referencing fvg_tpb shows `IMBALANCE_FILL_REVERSAL`, not `UNKNOWN` |
| IMBALANCE_FILL_REVERSAL cohort check | If fvg_tpb is ever best_strategy_id, cohort trace shows `"IMBALANCE_FILL_REVERSAL not in cohort"` |
| fvg_/ifr_ attribution fields | Any fvg_tpb ledger record with trigger_present=true contains `fvg_direction`, `fvg_gap_low`, `fvg_gap_high`, `ifr_playbook_state` fields |
| IFR playbook state | `ifr_playbook_state = "PLAYBOOK_FORMING"` or `"PLAYBOOK_NOT_PRESENT"` — `PLAYBOOK_VALID` must NOT appear |
| runtime_authority_status | All records show `"NONE"` — no exception |
| No decision path reads playbook fields | Confirm `final_decision` does not correlate with `playbook_state` across records |
| No score/gate/weight behavior change | Council behavior reports should show no change in DSN/CRR/HIGH_CONVICTION/consensus rates vs pre-FVG_TPB baseline |
| No execution caused by fvg_tpb alone | `actual_trade = true` records must also have a cohort-admitted family as best_strategy_id |

---

## 12. Final Governance Decision

```
PACKAGE_ID:                      BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1
STATUS:                          ACCEPTED — DOCUMENTED
CLASSIFICATION:                  SEMANTIC / IDENTITY / GOVERNANCE WORK
DATE:                            2026-05-09

AUDIT_ACCEPTED:                  BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1
AUDIT_VERDICT:                   PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP
AUDIT_VERDICT_ACCEPTED:          YES

DOCTRINE_ACCEPTED:               YES
  best_strategy_id               = thesis / attribution identity
  V1                             = permission authority
  Risk                           = protection authority
  Execution                      = survivability authority
  Attribution                    = learning authority

AUTHORITY_LEAKAGE_DOCUMENTED:    YES — cohort admission path (indirect, latent, correct outcome)
LEAKAGE_SEVERITY:                MEDIUM (latent; correct behavior; semantically impure)
LEAKAGE_IS_BLOCKER:              NO

IMMEDIATE_CLEANUP_COMPLETED:     LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1
CLEANUP_COMPILE_STATUS:          VERIFIED — 0 errors, 0 warnings
CLEANUP_COHORT_CHANGE:           NO
CLEANUP_PERMISSION_CHANGE:       NO

PLAYBOOK_FIREWALL_ENFORCED:      YES — playbook/fvg_/ifr_ fields are attribution only
FIREWALL_STATIC_VALIDATION:      CONFIRMED — zero fvg_/ifr_ references in decision path

STRATEGY_REGISTRY_RULE_ADDED:    YES — 9-point registry requirement for all future strategies

DEFERRED_CLEANUP_RECORDED:       YES
  A: EXECUTION_ADMISSION_IDENTITY_DECOUPLING_V1 — deferred
  B: PRIMARY_THESIS_STRATEGY_ID_RENAME_DESIGN_V1 — deferred
  C: PRIMARY_THESIS_SELECTION_CONTRACT_V1 — deferred

AUTHORIZED_BY_THIS_PACKAGE:      documentation, governance rules, deferred roadmap
NOT_AUTHORIZED:                  all MT5 source changes, all runtime changes, all weight/gate/
                                 score/risk/execution/strategy/cohort changes

SOURCE_CHANGED:                  NO
RUNTIME_JSON_CHANGED:            NO
COMPILE_RUN:                     NO
MT5_RELOAD:                      NO
SYSTEM_STATUS:                   DEVELOPING
PRODUCTION_READY_CLAIMED:        NO
```

---

## References

| # | Reference | Status |
|---|---|---|
| 1 | BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1.md | FOUND — reviewed |
| 2 | LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1_REPORT.md | FOUND — reviewed |
| 3 | FVG_TPB_RELOAD_BLOCKER_FIX_PACKAGE_V1_REPORT.md | FOUND — reviewed |
| 4 | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_REPORT.md | FOUND — reviewed |
| 5 | FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1.md | FOUND — reviewed |
| 6 | IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1.md | FOUND — reviewed |
| 7 | PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md | FOUND — reviewed |
| 8 | ARCHITECTURE_BUILD_PACKAGE_V1.md | ARTIFACT_NOT_FOUND — not located in AI directory; key facts available from PIML and other packages |
| 9 | IMPLEMENTATION_SPEC_PACKAGE_V1.md | ARTIFACT_NOT_FOUND — not located in AI directory; key facts available from PIML and other packages |
| 10 | SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md | FOUND — reviewed |
| 11 | PROJECT_INTELLIGENCE_MEMORY_LAYER.md | FOUND — reviewed |
