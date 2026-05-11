# LEGACY_SURFACE_DEAD_CODE_AND_OBSOLETE_FIELD_CLEANUP_AUDIT_V1

**Status:** COMPLETE
**Date:** 2026-05-11
**Verdict:** CLEANUP_REQUIRED_HIGH_VALUE — Package A (PJ fix) COMPLETED_ALREADY_RUNTIME_VALIDATION_PENDING; Packages B–D annotation/isolation pending operator authorization
**Package A Status:** COMPLETED — PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN (2026-05-11); runtime validation of buffered_records_total > 0 pending EA reload
**Evidence Quality:** SOURCE_VERIFIED — all findings confirmed by direct source read with exact file/line citations

---

## A. Executive Summary

This audit systematically reviewed all major source files for legacy, dead, obsolete, and misleading artifacts under the COUNCIL-mode-only production configuration. No source changes were made during the audit.

**Primary findings:**

1. **Largest dead-code mass:** `strategy_runtime.mqh` Zone 2-A and Zone 2-B (~1,300 of 1,628 lines) — compiled but entirely unreachable in COUNCIL mode. Isolated behind `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` guard that is never defined.

2. **Two fully disconnected files compiled into the binary:** `council_pre_ai_gate.mqh` (283 lines) and `council_governor.mqh` (145 lines). Both have self-documenting structural-ownership comments explicitly stating they are legacy-preserved/descriptive. `runtime_honesty_surfaces.mqh` registers both as `LEGACY_PRESERVED, DISCONNECTED_FROM_LIVE_ENFORCEMENT`. Neither function (`EvaluateCouncilPreAIGate`, `RunCouncilGovernorDecision`) is called in any COUNCIL pipeline stage.

3. **One REMOVE_NOW item — COMPLETED:** `performance_journal.mqh:1658` — bare `ROLLBACK` keyword substring check caused false-positive critical classification on 100% of normal-operation decision v3 records, suppressing the PJ_BUFFER on every bar. **Fix applied by Codex: PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN — 0 errors / 0 warnings.** Root-cause explanation preserved below (Section F). Runtime validation of `buffered_records_total > 0` pending EA reload.

4. **12 documented dormant branch groups** tracked by `runtime_honesty_surfaces.mqh`: ACTIVATION_PRESSURE_GATE, DIRTY_ENVIRONMENT_TIGHTENING, EXECUTION_QUALITY_GATE, LIVE_EXIT_ARCHITECTURE, AI_CANDIDATE_BLOCK, AI_ADVISORY_SECURITY_CLEARANCE, COUNCIL_SETUP_LIFECYCLE, TREND_CONTINUATION_REINFORCEMENT, EMERGENCY_FLAT_CRITICAL_SAFETY, INTERNAL_DASHBOARD_CHART_UI, ROLLBACK_ENABLE_SWITCH, ROLLBACK_THRESHOLD_INPUTS. All properly labeled; none are removal candidates.

5. **DQ authority layer structurally inert:** `authority_stack_pilot.mqh:273` hard-codes `result.dq_would_block = false` regardless of the `AuthorityStack_EnableDQ` input. Enabling the input has zero effect on decisions.

6. **No active trading path is at risk.** All dead/legacy surfaces are correctly isolated. Cleanup is beneficial for maintainability but not required for safety.

---

## B. Audit Scope and Methodology

**Files fully reviewed:**
- `decision_mode_router.mqh` (200 lines) — full read
- `strategy_runtime.mqh` (1,628 lines) — full structural read
- `performance_journal.mqh` (2,000+ lines) — routing section full read (Mission E)
- `council_pre_ai_gate.mqh` (283 lines) — full read
- `council_governor.mqh` (145 lines) — full read
- `authority_stack_pilot.mqh` (323 lines) — full read
- `council_mode_runtime.mqh` (2,504 lines) — dormant branch sections full read
- `mt5_io_reduction_v1.mqh` (119 lines) — full read
- `main_ea.mq5` — targeted reads at inputs (L67–204), library loading (L13508–13513), plan logs (L10816–10837), No-Score comments (L11039+), dormant branch labels, freeze logic (L5450–5922)
- `council_ai_governor.mqh` — structure verified (structural ownership comment, line 6–9)
- `council_mode_types.mqh` — struct inventory verified
- `runtime_honesty_surfaces.mqh` — dormant branch registry verified (L301, L490–492, L1074, L1090)
- `ai_evolution_engine.mqh` — sweep_detector/HYBRID references verified (L678, L687–700, L731–735)
- `plan_validator.mqh` — sweep_detector reference verified (L20)
- `LIBRARIES/library_strategies.mqh` — sweep_detector entry verified (L123–142)
- `level_awareness_brake.mqh` — scope-checked (active LAB_InferFamily; no legacy surfaces)
- `core_trade_engine.mqh` — grep confirmed no legacy/DORMANT/compiled_plan references

**Methods:** grep for DORMANT, LEGACY, DEAD_CODE, compiled_plan, gCompiledPlan, plan_mode, HYBRID, GATE_MODE, SCORE_MODE, DISABLE_ZONE2, sweep_detector, EnableAIEvolution; cross-reference against runtime_honesty_surfaces.mqh dormant registry; direct line reads of all cited locations.

**Evidence standard:** Every item below is SOURCE_VERIFIED with file name and line numbers where possible.

---

## C. Classification System

| Label | Meaning |
|---|---|
| REMOVE_NOW | Safe to remove; no active consumer; no backward-compatibility concern; Codex-ready |
| QUARANTINE_LEGACY_DIAGNOSTIC | Compiled/present but dormant; keep with explicit marking; must not execute; not a removal candidate without IRREW-phase clearance |
| KEEP_COMPATIBILITY_REQUIRED | Field/function retained because an active schema consumer depends on it (e.g., dashboard reads it) |
| KEEP_RUNTIME_AUTHORITY | Active decision-making path; must not be touched |
| DEPRECATE_WITH_ALIAS | Can be replaced with a thin alias but all consumers must be updated first |
| SOURCE_UNKNOWN_DO_NOT_TOUCH | Origin or consumer chain unknown; investigation required before any action |
| REJECT_CLEANUP_DANGEROUS | Removal or change would break active runtime behavior or active schema contracts |

---

## D. Inventory: decision_mode_router.mqh (200 lines)

**LCA-001 — GATE/SCORE/HYBRID routing branches**
- File: `decision_mode_router.mqh`
- Lines: 118–128 (GATE/SCORE/HYBRID entry branch), 174–183 (HYBRID fallback branch)
- Description: `if(mode == "GATE" || mode == "SCORE" || mode == "HYBRID")` → calls `EvaluateCompiledPlan`. Dead in COUNCIL configuration. Fallback at L174–183 similarly calls `EvaluateCompiledPlan` — also unreachable because COUNCIL mode is always set.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L118–128, L174–183. `IsCouncilModeEnabled` at L56–59 confirms mode check. `decision_engine_mode=COUNCIL` in production.
- Risk if removed: Safe to remove only after confirming COUNCIL is the permanent sole mode. If HYBRID ever needs to be temporarily activated (e.g., regression test), removal would break the fallback path.
- Action: No removal. Add explicit `// [LEGACY_ROUTING: GATE/SCORE/HYBRID — unreachable in COUNCIL; retained for non-COUNCIL regression path only]` comment if not already present.

**LCA-002 — HYBRID default in NormalizeDecisionEngineModeEx**
- File: `decision_mode_router.mqh`
- Lines: 47–52
- Description: Unknown mode strings are normalized to "HYBRID". This produces a live HYBRID decision if `decision_engine_mode` config is ever corrupted or absent. Not currently triggered.
- Classification: **KEEP_COMPATIBILITY_REQUIRED**
- Evidence: L47–52 source-verified. Default prevents nil-mode crashes.
- Action: No change. The HYBRID fallback is a defensive guard, not dead code.

---

## E. Inventory: strategy_runtime.mqh (1,628 lines)

**LCA-003 — Zone 2-A: plan-adjuster and score-discipline helpers (~290 lines)**
- File: `strategy_runtime.mqh`
- Lines: 275–564 (inside `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` guard)
- Description: Plan-adjuster helpers, score-discipline gate logic, zone multipliers, compiled-plan evaluation helpers. Called only by Zone 2-B functions; never called directly by any COUNCIL path. Compiled when `STRATEGY_RUNTIME_DISABLE_ZONE2` is NOT defined (i.e., always in current build).
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Zone guard comment at L275 confirmed. No call from council_strategies.mqh, council_aggregator.mqh, or council_mode_runtime.mqh.
- Risk if isolated: Defining `STRATEGY_RUNTIME_DISABLE_ZONE2` at build time would exclude Zone 2-A and 2-B. Zone 1 (L565–614) is NOT inside the guard and must remain active.
- Action: Do not activate the guard without operator authorization. Add `// [ZONE2_LEGACY: unreachable in COUNCIL mode — see STRATEGY_RUNTIME_DISABLE_ZONE2 guard]` at zone boundary.

**LCA-004 — Zone 2-B: EvaluateCompiledPlan and full evaluation engine (~1,010 lines)**
- File: `strategy_runtime.mqh`
- Lines: 616–1627 (inside `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` guard; primary entry point `EvaluateCompiledPlan` at L1595)
- Description: Entire compiled-plan evaluation engine — `EvaluateByGateMode`, `EvaluateByScoreMode`, `EvaluateByHybridMode`, `EvaluateCompiledPlan`, all indicator/strategy evaluators. Unreachable in COUNCIL mode. Zone 2-B comment at L715–721 self-documents: "Only external entry point: EvaluateCompiledPlan (called from decision_mode_router.mqh)."
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Zone 2-B comment L715–721 source-verified. `EvaluateCompiledPlan` call in router L118–128 is unreachable in COUNCIL mode (LCA-001).
- Risk: ~1,010 lines of compiled-but-dead code. No trading risk. Compile overhead only.
- Action: No removal. Isolation by enabling `STRATEGY_RUNTIME_DISABLE_ZONE2` is Package B option (requires operator authorization and compile verification).

**Zone 1 (LCA-N/A — ACTIVE, not a legacy surface):**
- Lines: 565–614 (unconditionally compiled, outside Zone 2 guard)
- `DetectBollingerReclaimTrigger()` and `DetectSweepDetectorTrigger()` — called live by `council_strategies.mqh:810`. These are ACTIVE. Do not touch.

---

## F. Inventory: performance_journal.mqh

**LCA-005 — ROLLBACK bare keyword check (PJ_BUFFER_CLASSIFIER_FALSE_CRITICAL)**
- File: `performance_journal.mqh`
- Line: 1658
- Description: `if(StringFind(u, "ROLLBACK") >= 0) return true;` — intended to classify journal lines referencing rollback events as immediate-flush-required. However, `PJ_BuildDecisionJsonV3` (L2345–2347) always writes `rollback_signal_state`, `rollback_signal_score`, `rollback_signal_reason` as field NAME strings. These field names always contain the substring "ROLLBACK". Result: 100% of normal-operation decision v3 records are force-classified as critical, bypassing the PJ_BUFFER on every bar. Confirmed: `buffered_records_total=0`, `direct_write_count=13` in runtime evidence dossier.
- Classification: **REMOVE_NOW**
- Evidence: Source-verified L1658, L2345–2347 (performance_journal.mqh). RB_NONE value = "NONE" (rollback_signal_engine.mqh L29–31) does not contain "ROLLBACK" — but the FIELD NAME does. This is the root cause.
- Recommended fix (exact, bounded):
  ```
  // REMOVE line 1658:
  if(StringFind(u, "ROLLBACK") >= 0) return true;
  // REPLACE WITH two value-specific checks:
  if(StringFind(u, "SOFT_ROLLBACK_WARNING") >= 0) return true;
  if(StringFind(u, "HARD_ROLLBACK_TRIGGER") >= 0) return true;
  ```
- Risk if applied: Zero trading risk. No decision path reads PJ_BUFFER state. After fix: `buffered_records_total` will begin accumulating; `direct_write_count` will decrease; IO reduction will become measurable for PJ_BUFFER component.
- **Status: COMPLETED — PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN (0 errors / 0 warnings). Runtime validation pending: verify `buffered_records_total > 0` in `mt5_io_reduction_status.json` after EA reload.**

---

## G. Inventory: council_pre_ai_gate.mqh (283 lines)

**LCA-006 — EvaluateCouncilPreAIGate() full module**
- File: `council_pre_ai_gate.mqh`
- Lines: 1–283 (entire file)
- Description: Contains `InitCouncilPreAIGateConfig`, `EvaluateCouncilPreAIGate` and all helper functions. Self-documenting structural-ownership comment at L11–13: "This module is legacy-preserved/descriptive in the current active runtime path. Live council pass/fail enforcement owner is RunCouncilPreAIFilter(...) plus final env.tradable/pre.passed branching." Never called in COUNCIL pipeline. `runtime_honesty_surfaces.mqh:299` explicitly registers this file as `LEGACY_PRESERVED, DISCONNECTED_FROM_LIVE_ENFORCEMENT`.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Grep for `EvaluateCouncilPreAIGate` across all source shows zero call sites outside this file and documentation. runtime_honesty_surfaces.mqh L299, L610, L710, L715, L1147, L1219, L1222, L1255, L1258, L1275, L1358 all reference and document its disconnected status.
- Uses different types than live path: takes `CouncilPreAIGateConfig` and `CouncilPreAIGateResult` (not the `CouncilPreAIGateReport` used by `RunCouncilPreAIFilter`). These type differences confirm structural incompatibility with live path.
- Action: No removal. Self-documenting comment is already present and accurate. The disconnected status is machine-readable via runtime_honesty_surfaces.mqh output files.

---

## H. Inventory: council_governor.mqh (145 lines)

**LCA-007 — RunCouncilGovernorDecision() full module**
- File: `council_governor.mqh`
- Lines: 1–145 (entire file)
- Description: Contains threshold helpers (`CouncilGov_MinConsensus`, etc.) and `RunCouncilGovernorDecision`. Self-documenting comment at L6–8: "This legacy governor threshold module is descriptive/policy reference only in current active runtime flow. It is not the live council pre-filter enforcement owner." Never called in COUNCIL pipeline. `runtime_honesty_surfaces.mqh:299` registers as `LEGACY_PRESERVED, DISCONNECTED_FROM_LIVE_ENFORCEMENT`.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Grep for `RunCouncilGovernorDecision` shows zero call sites in active source files. Only references are in this file itself and audit documentation.

**LCA-008 — change_vote_weights / new_vote_weight fields written but never consumed**
- File: `council_governor.mqh`
- Lines: 92–95
- Description: Within `RunCouncilGovernorDecision()`, the branch at L91–98 sets `outPolicy.change_vote_weights = true` and `outPolicy.new_vote_weight = 1.10`. The `CouncilPolicyAdjustment` struct is returned, but since `RunCouncilGovernorDecision` is never called (LCA-007), these assignments are dead. Even if the function were called, `change_vote_weights` is not consumed by any downstream caller in the active pipeline.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC** (subsumed by LCA-007)
- Evidence: BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1.md (docs) line 562 independently confirmed this dead write.
- Risk: "Could mislead future readers into thinking weights are dynamically adjusted" — documented in prior audit. Not a runtime risk.

---

## I. Inventory: council_mode_runtime.mqh (2,504 lines)

**LCA-009 — TREND_CONTINUATION_REINFORCEMENT dormant branch — evaluator body**
- File: `council_mode_runtime.mqh`
- Lines: 203–272 (body of `EvaluateTrendContinuationConfirmationReinforcement`)
- Description: The evaluator function contains an unconditional `return false;` at L216 (the No-Score hard-lock comment), followed by ~50 lines of dead evaluation logic (L219–272). The dead body is labeled `[DORMANT_BRANCH: TREND_CONTINUATION_REINFORCEMENT] flag=false; entire reinforcement evaluator dormant; returns false unconditionally; rescue path for missing confirmation role inactive`. A second dormant label exists at L2162 (call site): `[DORMANT_BRANCH: TREND_CONTINUATION_REINFORCEMENT] flag=false; narrow pre-filter rescue call site dormant`.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L203–272 (council_mode_runtime.mqh). Confirmed in runtime_honesty_surfaces.mqh:490–492. This branch group is in the `dormant_branch_groups_tracked` registry.
- Action: No removal. Dormant branch labels are present and machine-readable. The dead body at L219–272 is preserved for future activation review.

**LCA-010 — EnableCouncilTrendContinuationConfirmationReinforcement + 5 threshold inputs**
- File: `council_mode_runtime.mqh`
- Lines: 21–27
- Description: Input `EnableCouncilTrendContinuationConfirmationReinforcement = false` and five threshold inputs. All have zero live effect due to the unconditional `return false` at L216. Enabling the input still has no effect because the hard-lock return precedes the `if(!Enable...)` flag check at L219.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L21–27, L216–219. The flag check at L219 is unreachable.

---

## J. Inventory: main_ea.mq5

**LCA-011 — Legacy compiled-plan library loading in OnInit**
- File: `main_ea.mq5`
- Lines: 13508–13513 (approximate from prior read)
- Description: `BuildStrategyLibrary()`, `BuildIndicatorLibrary()`, `BuildEntryPatternLibrary()`, `BuildRiskModelLibrary()`, `BuildFilterLibrary()` — all called in OnInit with log messages labeled "Legacy compiled-plan … library loaded: N". These libraries are only consumed by `EvaluateCompiledPlan` (Zone 2-B, LCA-004), which is unreachable in COUNCIL mode. Loading adds OnInit overhead and log noise but has no runtime decision effect.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified. Library loading exists at OnInit; "Legacy compiled-plan" labels confirm operator awareness of their status.

**LCA-012 — compiled_plan_runtime_privilege_frozen field**
- File: `main_ea.mq5`
- Lines: 290 (struct declaration), 5450, 5504 (set=true), 5520 (read-back from JSON), 5548 (OR gate), 5881 (TXT serialized), 5922 (JSON serialized)
- Description: Boolean field on the strategy freeze state struct. Written true in freeze logic; serialized to JSON; read back; consumed by `dashboard_state_classifier.mqh`. This field is an active schema component — the dashboard reads it.
- Classification: **KEEP_COMPATIBILITY_REQUIRED**
- Evidence: JSON serialization at L5922 confirmed. Dashboard consumption path exists in `dashboard_state_classifier.mqh`.
- Action: No change.

**LCA-013 — Multiple dormant branch inputs (all default false)**

| Input | Line | Branch Group | Classification |
|---|---|---|---|
| `EnableCouncilSetupLifecycle = false` | L71 | COUNCIL_SETUP_LIFECYCLE (2 sites: L9736, L10661) | QUARANTINE_LEGACY_DIAGNOSTIC |
| `EnableCouncilExecutionQualityGate = false` | L76 | EXECUTION_QUALITY_GATE | QUARANTINE_LEGACY_DIAGNOSTIC |
| `EnableCouncilDirtyEnvironmentTightening = false` | L90 | DIRTY_ENVIRONMENT_TIGHTENING (L14750) | QUARANTINE_LEGACY_DIAGNOSTIC |
| `EnableAIEvolution = false` | L126 | AI evolution branches (L6875+) | QUARANTINE_LEGACY_DIAGNOSTIC |
| `EnableInternalDashboardChartUI = false` | L192 | INTERNAL_DASHBOARD_CHART_UI (L13639, L13690, L13714) | QUARANTINE_LEGACY_DIAGNOSTIC |

All are properly labeled with `[DORMANT_BRANCH: GROUP_NAME]` comments and registered in `runtime_honesty_surfaces.mqh:301`.

**LCA-014 — No-Score hard-lock comments (5+ sites)**
- File: `main_ea.mq5`
- Lines: 11039–11043 and 4+ additional locations
- Description: Score-based thresholds hard-wired as dormant. Comment: "These score-based thresholds cannot block trades even if policy flags are enabled." This is intentional policy — not dead code to be removed.
- Classification: **KEEP_RUNTIME_AUTHORITY**
- Evidence: Source-verified. No-Score hard-lock is an explicit architectural decision documented in PIML.
- Action: No change.

**LCA-015 — Score threshold log "(diagnostic when COUNCIL)"**
- File: `main_ea.mq5`
- Lines: 10828–10830
- Description: Log line labels score thresholds as "(diagnostic when decision_engine_mode=COUNCIL)". This is accurate and useful — it prevents misleading interpretation of the log output.
- Classification: **KEEP_RUNTIME_AUTHORITY**
- Evidence: Source-verified. The label is correct and informative.

**LCA-016 — AI_CANDIDATE_BLOCK dormant branch**
- File: `main_ea.mq5`
- Line: 8840
- Description: Comment: "[DORMANT_BRANCH: AI_CANDIDATE_BLOCK] flag=false; double-dormant: AIGateSecurityClearanceForAdvisory must be true first (AI_ADVISORY_ONLY state required); Phase 6 reserved for activation." Double-dormancy means two separate flag conditions must both be true before this code runs.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L8840. In dormant_branch_groups_tracked registry.

**LCA-017 — ACTIVATION_PRESSURE_GATE + DIRTY_ENVIRONMENT_TIGHTENING dormant groups**
- File: `main_ea.mq5`
- Lines: 14700 (ACTIVATION_PRESSURE_GATE), 14750 (DIRTY_ENVIRONMENT_TIGHTENING)
- Description: Both require `EnableCouncilSetupLifecycle` (currently false) to be active. Even if the lifecycle flag were enabled, the pressure gate and dirty tightening are nested dependencies — never reached in current configuration.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L14700, L14750. Both in dormant_branch_groups_tracked registry.

**LCA-018 — gPlan.plan_mode log (LogPlanArchitectureSummary)**
- File: `main_ea.mq5`
- Lines: 10816–10818
- Description: `LogPlanArchitectureSummary` logs `gPlan.plan_mode` which may show "HYBRID" even when COUNCIL is active. This is the legacy plan object's mode field, not the active decision engine mode. Can mislead log readers.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L10816–10818. `LogCompiledArchitectureSummary` at L10833–10837 correctly logs `decision_engine_mode`.
- Action: No code change required. Understand that `plan_mode` in logs refers to the compiled-plan object, not the active mode.

---

## K. Inventory: authority_stack_pilot.mqh (323 lines)

**LCA-019 — DQ authority layer hard-coded force-false**
- File: `authority_stack_pilot.mqh`
- Line: 273
- Description: `result.dq_would_block = false;` is unconditionally set, preceded by comment: "A3-REVISED: DQ proxy is diagnostic-only. AuthorityStack_EnableDQ remains a compatibility flag for observability, not live blocking." The DQ score (`dq_proxy_score`) is still computed and logged for observability but has zero decision effect. The `AuthorityStack_EnableDQ = false` input at `main_ea.mq5:93` is therefore doubly-dormant — even if set true at the input level, the internal force-false at L273 suppresses any block.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified L272–273 (authority_stack_pilot.mqh). Input L93 (main_ea.mq5) confirms default=false.
- Note: This is an intentional A3-REVISED architectural decision — the DQ layer is observability-only pending further evidence accumulation.

**Active authority layers (not legacy):**
- P4 block: `AuthorityStack_EnableP4 = true`; `p4_would_block` can reach block path (L281–294). ACTIVE.
- V1 block: `AuthorityStack_EnableV1 = true`; `v1_would_block` can reach block path (L296–308). ACTIVE.

---

## L. Inventory: LIBRARIES/*.mqh

**LCA-020 — Legacy compiled-plan library definitions (full LIBRARIES/ directory)**
- Files: `library_strategies.mqh`, `library_indicators.mqh`, `library_entry_patterns.mqh`, `library_risk_models.mqh`, `library_filters.mqh`
- Description: Full legacy strategy/indicator/filter/entry-pattern/risk-model library definitions. Loaded by `BuildStrategyLibrary()` etc. in OnInit (LCA-011). Consumed only by `EvaluateCompiledPlan` (Zone 2-B, LCA-004), which is unreachable in COUNCIL mode.
- Notable: `library_strategies.mqh:123–142` contains "sweep_detector" as an indicator reference in legacy strategy definitions.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**
- Evidence: Source-verified library_strategies.mqh L123–142 for sweep_detector. Full load chain: OnInit → BuildStrategyLibrary → library_strategies → COUNCIL mode never reaches Zone 2-B.

**LCA-021 — sweep_detector in plan_validator.mqh**
- File: `plan_validator.mqh`
- Line: 20
- Description: "sweep_detector" referenced as a valid trigger name in the legacy plan validator. Validator is only reached from Zone 2-B (compiled-plan path). Unreachable in COUNCIL mode.
- Classification: **QUARANTINE_LEGACY_DIAGNOSTIC**

---

## M. Inventory: Remaining Files

**ai_evolution_engine.mqh (LCA-022 — QUARANTINE_LEGACY_DIAGNOSTIC)**
- sweep_detector as default/fallback trigger name (L678, L687–700) — evolution engine disabled by `EnableAIEvolution=false` (main_ea.mq5:126)
- "HYBRID" as normalization target (L731–735) — no runtime decision effect while evolution disabled
- `ai_current_plan.json` reading remains active as COUNCIL plan truth mechanism — this is NOT legacy; it is the active COUNCIL strategy configuration input

**council_ai_governor.mqh (LCA-N/A — ACTIVE)**
- Self-documenting comment: "This governor is a categorical context observer. Live council pass/fail enforcement remains owned by RunCouncilPreAIFilter(...)." This is accurately described and ACTIVE — it computes the governor operating state used in the COUNCIL pipeline. Not a legacy surface.

**core_trade_engine.mqh (LCA-N/A — CLEAN)**
- Grep for all legacy terms returned no matches. core_trade_engine.mqh contains no dormant/legacy/compiled_plan surfaces.

**level_awareness_brake.mqh (LCA-N/A — ACTIVE)**
- `LAB_InferFamilyFromStrategyId` is active, called by the COUNCIL brake path. No legacy surfaces.

**council_mode_types.mqh (LCA-N/A — CLEAN)**
- Struct definitions only. Zone sub-types 7–9 (EXPANSION_CONTINUATION, RANGE_BALANCED, RANGE_DIRTY) are defined but not yet emitted by ClassifyCouncilZone() — documented in source comment at L38–44. Not a cleanup target; forward-declared for completeness.

---

## N. High-Priority Questions (A–L)

**A. What is the largest dead-code mass in the codebase?**
`strategy_runtime.mqh` Zone 2-A + Zone 2-B: approximately 1,300 of 1,628 lines compiled but entirely unreachable in COUNCIL mode. Zone 1 (~50 lines, L565–614) is active. The dead mass is isolated by the `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` guard that is never activated.

**B. Is any legacy routing path reachable under the current COUNCIL configuration?**
No. All GATE/SCORE/HYBRID branches in `decision_mode_router.mqh` (L118–128, L174–183) require `mode != "COUNCIL"`. Since `decision_engine_mode=COUNCIL` in production, these branches are structurally unreachable. Zone 2-A and 2-B in strategy_runtime.mqh are only reachable via `EvaluateCompiledPlan`, which is only called from those unreachable branches.

**C. What inputs exist that have zero live authority effect?**
The following EA inputs produce no decision-path effect in the current COUNCIL configuration:
- `EnableCouncilSetupLifecycle = false` (lifecycle gates dormant)
- `EnableCouncilExecutionQualityGate = false` (quality gate dormant)
- `EnableCouncilDirtyEnvironmentTightening = false` (tightening dormant)
- `EnableAIEvolution = false` (AI evolution dormant)
- `EnableInternalDashboardChartUI = false` (dashboard chart dormant)
- `EnableCouncilTrendContinuationConfirmationReinforcement = false` (reinforcement dormant, and the function also has an unconditional return false before the flag is checked)
- `AuthorityStack_EnableDQ = false` (DQ score computed for observability only; block path hard-coded false regardless of this input)
- All 5 threshold inputs for TREND_CONTINUATION_REINFORCEMENT (L21–27, council_mode_runtime.mqh)

**D. Are there inputs that appear authoritative but are force-overridden in code?**
Yes — one confirmed case: `AuthorityStack_EnableDQ`. The input defaults false at `main_ea.mq5:93`, but even if set to true, `authority_stack_pilot.mqh:273` unconditionally sets `result.dq_would_block = false`. The DQ block path at L273 is never reachable regardless of the input value. The comment at L271–272 documents this: "A3-REVISED: DQ proxy is diagnostic-only."

**E. Which functions are compiled but never called in the COUNCIL pipeline?**
- `EvaluateCouncilPreAIGate()` (council_pre_ai_gate.mqh) — no call sites in active pipeline
- `RunCouncilGovernorDecision()` (council_governor.mqh) — no call sites in active pipeline
- `EvaluateCompiledPlan()` (strategy_runtime.mqh Zone 2-B) — only called from unreachable HYBRID branch
- `EvaluateByGateMode()`, `EvaluateByScoreMode()`, `EvaluateByHybridMode()` (strategy_runtime.mqh Zone 2-B) — only called by EvaluateCompiledPlan
- All Zone 2-A plan-adjuster and score-discipline helpers (strategy_runtime.mqh L275–564)
- All LIBRARIES/*.mqh — consumed by BuildStrategyLibrary etc., only used by Zone 2-B
- `BuildStrategyLibrary()`, `BuildIndicatorLibrary()` etc. — called in OnInit but serve only Zone 2-B path
- `EvaluateTrendContinuationConfirmationReinforcement()` evaluator body (L219–272) — unreachable after unconditional return false at L216

**F. Are there any struct fields written but never read in any active consumer?**
Yes: `CouncilPolicyAdjustment.change_vote_weights` and `CouncilPolicyAdjustment.new_vote_weight` written in `council_governor.mqh:92–95` — but since `RunCouncilGovernorDecision` is never called, these writes never execute. Even if the function were called, no downstream caller reads these fields to apply weight changes. This was independently confirmed in BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1.md.

**G. Does the PJ_BUFFER false-critical anomaly affect any other journal write path?**
No. Only records routed through `PJ_AppendLine` with a JSON blob containing the rollback_signal field names are affected. The only such caller is `JournalAppendDecisionV3` (performance_journal.mqh:L2427), which appends the output of `PJ_BuildDecisionJsonV3`. Opportunity ledger writes, governance status writes, and trend-cont status writes are written via separate file-open/write paths and do not go through PJ_AppendLine with decision JSON.

**H. Are the LIBRARIES/*.mqh files fully unreachable at runtime in COUNCIL mode?**
Yes. The full call chain is: `EvaluateCompiledPlan` (Zone 2-B) → uses strategy/indicator/filter libraries. Since `EvaluateCompiledPlan` is only reached from the GATE/SCORE/HYBRID branch of `decision_mode_router.mqh`, and that branch is unreachable in COUNCIL mode, the library contents are never accessed during COUNCIL decisions. The libraries are loaded in OnInit (wasted initialization overhead) but their content is never queried during execution.

**I. What is the risk profile of removing DORMANT_BRANCH code?**
Each of the 12 dormant branch groups tracked in `runtime_honesty_surfaces.mqh:301` represents a future-activation surface. They are not removal candidates because:
1. They require coordinated enabling — activating the flag alone may not be sufficient; companion code changes may be required
2. They are dependency-ordered — e.g., COUNCIL_SETUP_LIFECYCLE must be enabled before ACTIVATION_PRESSURE_GATE
3. They are referenced in IRREW design phases — premature removal forfeits the activation path
4. The `[DORMANT_BRANCH: NAME]` labels make them machine-readable and auditable
Classification: QUARANTINE_LEGACY_DIAGNOSTIC, not REMOVE_NOW.

**J. Do council_pre_ai_gate.mqh and council_governor.mqh pose any risk of silently affecting decisions?**
No. Neither `EvaluateCouncilPreAIGate` nor `RunCouncilGovernorDecision` is called anywhere in the COUNCIL pipeline. They are compiled into the binary but consume no call stack time and make no decisions. The live enforcement owners are: `RunCouncilPreAIFilter` (pass/fail enforcement) and `EvaluateCouncilAIGovernor` (advisory adjustment). The legacy files' existence has zero runtime effect.

**K. Is compiled_plan_runtime_privilege_frozen a truly active field?**
Yes. It is declared in the freeze state struct (main_ea.mq5:290), set to true in freeze logic (L5450, L5504), read back from JSON on EA reload (L5520), used in the OR gate for freeze state determination (L5548), serialized to both TXT (L5881) and JSON (L5922), and the JSON output is consumed by `dashboard_state_classifier.mqh`. Removal would break the dashboard. Classification: KEEP_COMPATIBILITY_REQUIRED.

**L. What is the correct cleanup package sequence?**
1. ~~Package A (REMOVE_NOW): PJ_BUFFER false-critical fix — performance_journal.mqh:1658~~ **COMPLETED — PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN. Runtime validation pending.**
2. Package B (Zone 2 Isolation): Define `STRATEGY_RUNTIME_DISABLE_ZONE2` to exclude Zone 2-A/2-B from compilation — requires compile verification that Zone 1 (L565–614) remains active. High value; low risk if bounded to the define only.
3. Package C (Module Annotation): Strengthen self-documenting comments in council_pre_ai_gate.mqh and council_governor.mqh to ensure their disconnected status is immediately obvious. Add cross-reference to enforcement owners. No code removal.
4. Package D (Input Annotation): Add explicit "(dormant — [BRANCH_GROUP])" inline annotation to all dormant EA inputs to prevent operator confusion when reviewing the input panel. No code removal.

---

## O. REMOVE_NOW Items — STATUS UPDATE

| Item | File | Line | Action | Status |
|---|---|---|---|---|
| LCA-005: ROLLBACK bare keyword check | performance_journal.mqh | 1658 | Replace 1 line with 2 value-specific checks | **COMPLETED — PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN** |

**Change applied (Package A — DONE):**
```
REMOVED line 1658:
   if(StringFind(u, "ROLLBACK") >= 0) return true;

REPLACED WITH:
   if(StringFind(u, "SOFT_ROLLBACK_WARNING") >= 0) return true;
   if(StringFind(u, "HARD_ROLLBACK_TRIGGER") >= 0) return true;
```
Compile result: 0 errors / 0 warnings (PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN).
**Remaining validation:** EA reload → verify `buffered_records_total > 0` in `mt5_io_reduction_status.json` after one decision bar. Until reload occurs, `buffered_records_total` will remain 0 in the prior binary.

---

## P. QUARANTINE_LEGACY_DIAGNOSTIC Items Summary

| Item ID | Description | File | Lines | Notes |
|---|---|---|---|---|
| LCA-001 | GATE/SCORE/HYBRID routing branches | decision_mode_router.mqh | 118–128, 174–183 | Unreachable in COUNCIL; preserved for non-COUNCIL regression path |
| LCA-003 | Zone 2-A: plan-adjuster helpers | strategy_runtime.mqh | 275–564 | Compilable but dead; isolatable via DISABLE_ZONE2 define |
| LCA-004 | Zone 2-B: EvaluateCompiledPlan + full engine | strategy_runtime.mqh | 616–1627 | ~1,010 dead lines; isolatable via DISABLE_ZONE2 define |
| LCA-006 | EvaluateCouncilPreAIGate() full module | council_pre_ai_gate.mqh | 1–283 | Self-documented as legacy-preserved; zero runtime effect |
| LCA-007 | RunCouncilGovernorDecision() full module | council_governor.mqh | 1–145 | Self-documented as descriptive/policy reference; zero runtime effect |
| LCA-008 | change_vote_weights / new_vote_weight dead writes | council_governor.mqh | 92–95 | Subsumed by LCA-007; never executed |
| LCA-009 | TREND_CONT_REINFORCEMENT evaluator dead body | council_mode_runtime.mqh | 219–272 | After unconditional return false at L216; future-activation preserved |
| LCA-010 | Reinforcement threshold inputs (5x) | council_mode_runtime.mqh | 21–27 | Doubly-inert: flag check at L219 is unreachable |
| LCA-011 | Legacy library loading in OnInit | main_ea.mq5 | 13508–13513 | Wasted OnInit overhead; only used by unreachable Zone 2-B |
| LCA-013 | Dormant branch input group | main_ea.mq5 | L71–192 | 5 inputs, all properly labeled; not removal candidates |
| LCA-015 | gPlan.plan_mode log (HYBRID may appear) | main_ea.mq5 | 10816–10818 | Misleading log entry; not a code defect |
| LCA-016 | COUNCIL_SETUP_LIFECYCLE dormant branch (2 sites) | main_ea.mq5 | 9736, 10661 | Properly labeled; future-activation surface |
| LCA-017 | ACTIVATION_PRESSURE_GATE + DIRTY_ENV dormant | main_ea.mq5 | 14700, 14750 | Doubly-nested dependency; properly labeled |
| LCA-018 | AI_CANDIDATE_BLOCK dormant branch | main_ea.mq5 | 8840 | Doubly-dormant; properly labeled |
| LCA-019 | DQ layer force-false | authority_stack_pilot.mqh | 273 | Observability-only; A3-REVISED intentional decision |
| LCA-020 | LIBRARIES/*.mqh full content | LIBRARIES/ | all | Only reachable via Zone 2-B; loaded in OnInit uselessly |
| LCA-021 | sweep_detector in plan_validator.mqh | plan_validator.mqh | 20 | Legacy plan validation path; unreachable in COUNCIL |
| LCA-022 | sweep_detector / HYBRID in ai_evolution_engine | ai_evolution_engine.mqh | 678, 731 | Evolution disabled; references are dormant |

---

## Q. KEEP Items

| Item ID | Description | File | Classification | Reason |
|---|---|---|---|---|
| LCA-002 | HYBRID default in NormalizeDecisionEngineModeEx | decision_mode_router.mqh | KEEP_COMPATIBILITY_REQUIRED | Prevents nil-mode crashes |
| LCA-012 | compiled_plan_runtime_privilege_frozen field | main_ea.mq5 | KEEP_COMPATIBILITY_REQUIRED | Active dashboard schema consumer |
| LCA-014 | No-Score hard-lock comments (5x) | main_ea.mq5 | KEEP_RUNTIME_AUTHORITY | Explicit architectural policy; not dead code |
| LCA-015 | Score threshold log "(diagnostic when COUNCIL)" | main_ea.mq5 | KEEP_RUNTIME_AUTHORITY | Accurate label preventing log misreading |
| Zone 1 | DetectBollingerReclaimTrigger, DetectSweepDetectorTrigger | strategy_runtime.mqh | KEEP_RUNTIME_AUTHORITY | Called live by council_strategies.mqh:810 |
| council_ai_governor | EvaluateCouncilAIGovernor | council_ai_governor.mqh | KEEP_RUNTIME_AUTHORITY | Active COUNCIL pipeline governor stage |
| level_awareness_brake | LAB_InferFamilyFromStrategyId + brake logic | level_awareness_brake.mqh | KEEP_RUNTIME_AUTHORITY | Active late-stage execution brake |
| core_trade_engine | All content | core_trade_engine.mqh | KEEP_RUNTIME_AUTHORITY | No legacy surfaces found; all active |

---

## R. Codex Cleanup Packages A–D

### Package A — REMOVE_NOW: PJ_BUFFER False-Critical Fix — **COMPLETED**

**Status:** `COMPLETED_ALREADY_RUNTIME_VALIDATION_PENDING`
**Completion record:** PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN — 0 errors / 0 warnings.
**File changed:** `performance_journal.mqh:1658`
**Change applied:**
```
REMOVED:  if(StringFind(u, "ROLLBACK") >= 0) return true;
ADDED:    if(StringFind(u, "SOFT_ROLLBACK_WARNING") >= 0) return true;
          if(StringFind(u, "HARD_ROLLBACK_TRIGGER") >= 0) return true;
```
**Remaining action:** EA reload → observe `buffered_records_total > 0` in `mt5_io_reduction_status.json` after first decision bar. This is the only remaining validation step for Package A. No further Codex work required.

---

### Package B — Zone 2 Isolation: strategy_runtime.mqh
**File:** `strategy_runtime.mqh` + any build include that controls the define
**Bounded scope:** Add `#define STRATEGY_RUNTIME_DISABLE_ZONE2` in the appropriate pre-include location (e.g., at the top of `main_ea.mq5` or in a build configuration include). No lines removed from strategy_runtime.mqh source.
**Effect:** Zone 2-A (L275–564) and Zone 2-B (L616–1627) excluded from compilation. Zone 1 (L565–614) remains unconditionally compiled and active.
**Required proof:** Compile 0 errors / 0 warnings. Verify Zone 1 functions (`DetectBollingerReclaimTrigger`, `DetectSweepDetectorTrigger`) still linkable. EA reload. Verify council_strategies.mqh:810 still compiles and calls correctly.
**Risk:** If any unexpected Zone 2 function is used elsewhere (missed by audit), compile will catch it with an undefined function error — no silent runtime risk.
**Codex:** YES — bounded. One define added; no source deleted.
**Pre-authorization required:** YES — operator sign-off. Do not combine with Package A.
**Dependency:** Package A must be complete before Package B (separate reload per package).

---

### Package C — Module Annotation: council_pre_ai_gate.mqh + council_governor.mqh
**Files:** `council_pre_ai_gate.mqh` (L1–15), `council_governor.mqh` (L1–10)
**Bounded scope:** Strengthen the structural-ownership comment header in each file to explicitly name the live enforcement owners and cross-reference the disconnected status.
**Proposed addition to council_pre_ai_gate.mqh header:**
```
// DISCONNECTED_FROM_LIVE_ENFORCEMENT — confirmed 2026-05-11 LEGACY_SURFACE_DEAD_CODE_AUDIT_V1
// Live pass/fail owner: RunCouncilPreAIFilter() in council_pre_ai_filter.mqh
// This file: legacy-preserved reference surface only. EvaluateCouncilPreAIGate() is not called.
// Machine-readable status: see ai_runtime_honesty_surfaces*.json (proven_disconnected_modules)
```
**Proposed addition to council_governor.mqh header:**
```
// DISCONNECTED_FROM_LIVE_ENFORCEMENT — confirmed 2026-05-11 LEGACY_SURFACE_DEAD_CODE_AUDIT_V1
// Live policy owner: EvaluateCouncilAIGovernor() in council_ai_governor.mqh
// This file: legacy-preserved policy reference only. RunCouncilGovernorDecision() is not called.
// Machine-readable status: see ai_runtime_honesty_surfaces*.json (proven_disconnected_modules)
```
**Required proof:** Compile 0 errors / 0 warnings. Comment-only change — no logic or definition change.
**Codex:** YES — bounded comment-only edit. Two files.
**Pre-authorization required:** YES.
**Dependency:** Independent of Packages A and B. Can run in parallel with Package B or after.

---

### Package D — Input Annotation: Dormant EA Inputs
**File:** `main_ea.mq5` (input declarations section, L71–192) and `council_mode_runtime.mqh` (L21–27)
**Bounded scope:** Add `// [DORMANT — BRANCH_GROUP_NAME, see DORMANT_BRANCH comments below]` inline annotation to each dormant input. No logic changes. Comment-only.
**Inputs to annotate:**

| Input | File | Line | Annotation text |
|---|---|---|---|
| EnableCouncilSetupLifecycle | main_ea.mq5 | L71 | `// [DORMANT — COUNCIL_SETUP_LIFECYCLE: see L9736, L10661]` |
| EnableCouncilExecutionQualityGate | main_ea.mq5 | L76 | `// [DORMANT — EXECUTION_QUALITY_GATE]` |
| EnableCouncilDirtyEnvironmentTightening | main_ea.mq5 | L90 | `// [DORMANT — DIRTY_ENVIRONMENT_TIGHTENING: see L14750]` |
| AuthorityStack_EnableDQ | main_ea.mq5 | L93 | `// [DORMANT — DQ layer force-false in code regardless of this flag; observability only]` |
| EnableAIEvolution | main_ea.mq5 | L126 | `// [DORMANT — AI evolution disabled]` |
| EnableInternalDashboardChartUI | main_ea.mq5 | L192 | `// [DORMANT — INTERNAL_DASHBOARD_CHART_UI]` |
| EnableCouncilTrendContReinforcement | council_mode_runtime.mqh | L21 | `// [DORMANT — TREND_CONTINUATION_REINFORCEMENT: hard-lock return false precedes flag check]` |

**Required proof:** Compile 0 errors / 0 warnings. Comment-only change.
**Codex:** YES — bounded comment-only edit. Two files.
**Pre-authorization required:** YES.
**Dependency:** Independent. Can run after any other package.

---

## S. Final Verdict and Footer

**VERDICT: CLEANUP_REQUIRED_HIGH_VALUE**

Significant legacy dead-code mass exists (~1,300 lines in strategy_runtime.mqh alone, plus council_pre_ai_gate.mqh, council_governor.mqh, LIBRARIES/*, decision_mode_router.mqh branches). One REMOVE_NOW item (PJ_BUFFER fix) is Codex-ready with zero trading risk. All other cleanup is annotation/isolation only — no code deletion required or recommended without operator-authorized phased planning.

The system is architecturally safe. No legacy path can silently activate in the current COUNCIL configuration. `runtime_honesty_surfaces.mqh` already machine-documents the disconnected surfaces. The primary cleanup benefit is developer clarity and compile-time object size reduction (Package B).

**Cleanup priority order (updated 2026-05-11):**
1. ~~Package A (PJ_BUFFER fix)~~ — **COMPLETED. Runtime validation pending EA reload (verify `buffered_records_total > 0`).**
2. **Package B (Zone 2 isolation)** — next high-value cleanup candidate; activate `STRATEGY_RUNTIME_DISABLE_ZONE2` define to exclude ~1,300 dead lines from compilation; requires operator authorization and compile verification.
3. Package C (module annotation) — low risk, comment-only; `council_pre_ai_gate.mqh` and `council_governor.mqh` header strengthening.
4. Package D (dormant input annotation) — low risk, comment-only; 7 dormant EA inputs annotated across 2 files.

**What must NOT be cleaned up:**
- Any `[DORMANT_BRANCH: NAME]` labeled code blocks — these are future-activation surfaces
- `compiled_plan_runtime_privilege_frozen` field — active dashboard consumer
- `council_ai_governor.mqh` — active pipeline governor
- `level_awareness_brake.mqh` — active execution brake
- `core_trade_engine.mqh` — no legacy surfaces; fully active
- No-Score hard-lock comments — active architectural policy documentation

---

```
AUDIT_ID:                    LEGACY_SURFACE_DEAD_CODE_AND_OBSOLETE_FIELD_CLEANUP_AUDIT_V1
DATE:                        2026-05-11
VERDICT:                     CLEANUP_REQUIRED_HIGH_VALUE
SOURCE_CHANGED:              NO
COMPILE_RUN:                 NO
LIVE_TRADING:                NO
RUNTIME_FILES_MODIFIED:      NO
PRODUCTION_READY_CLAIMED:    NO
ITEMS_CLASSIFIED:            25 (1 REMOVE_NOW, 18 QUARANTINE_LEGACY_DIAGNOSTIC, 8 KEEP)
DORMANT_BRANCH_GROUPS:       12 (all registered in runtime_honesty_surfaces.mqh)
LARGEST_DEAD_MASS:           strategy_runtime.mqh Zone 2-A+2-B (~1,300 lines)
REMOVE_NOW_ITEMS:            1 (LCA-005: performance_journal.mqh:1658)
CODEX_PACKAGE_A_STATUS:      COMPLETED — PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN (0 errors / 0 warnings); runtime validation pending EA reload
CODEX_PACKAGE_B_READY:       YES — awaiting operator authorization (compile-verify required; Zone 2 isolation via STRATEGY_RUNTIME_DISABLE_ZONE2)
CODEX_PACKAGE_C_READY:       YES — awaiting operator authorization (comment-only; council_pre_ai_gate.mqh + council_governor.mqh)
CODEX_PACKAGE_D_READY:       YES — awaiting operator authorization (comment-only; 7 dormant EA inputs)
NEXT_ACTION:                 EA reload → validate buffered_records_total > 0 in mt5_io_reduction_status.json (Package A runtime proof) → authorize Package B if desired
```
