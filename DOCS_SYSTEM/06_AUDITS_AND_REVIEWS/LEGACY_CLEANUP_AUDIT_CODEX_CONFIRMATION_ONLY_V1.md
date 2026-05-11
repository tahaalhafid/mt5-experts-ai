# LEGACY_CLEANUP_AUDIT_CODEX_CONFIRMATION_ONLY_V1

## A. Executive Verdict

Final verdict: `CLEANUP_AUDIT_PARTIALLY_CONFIRMED_WITH_DISCREPANCIES`.

The cleanup audit is directionally correct: Package A is complete and runtime-validation pending; Zone 2-A/2-B are legacy compiled-plan surfaces unreachable through active COUNCIL routing; the live council pre-AI and governor owners are `RunCouncilPreAIFilter()` and `EvaluateCouncilAIGovernor()`; `runtime_honesty_surfaces.mqh` correctly documents disconnected/dormant surfaces; DQ is structurally inert; and the KEEP list is mostly correct.

Two material discrepancies prevent a full "ready" confirmation:

1. Package B is not safe as a simple define-only package. `strategy_runtime.mqh` excludes `EvaluateCompiledPlan()` when `STRATEGY_RUNTIME_DISABLE_ZONE2` is defined, but `decision_mode_router.mqh` still has unguarded calls at lines 120 and 177. A define-only isolation can therefore create a compile-time undefined-function failure unless the router compatibility path is also guarded or a stub is provided.
2. `council_pre_ai_gate.mqh` and `council_governor.mqh` are disconnected, but current source and the latest compile log do not support the report phrase "compiled into the binary". No `#include` references to either file were found, and the latest compile log contains neither file.

This was a confirmation-only audit. No cleanup package was implemented. No compile was run. No runtime JSON/JSONL files were modified.

Governed backup was created before writing this report:

- `D:\MT5_Project_Backups\system_backup_LEGACY_CLEANUP_AUDIT_CODEX_CONFIRMATION_ONLY_V1_PREPATCH_20260511_021710.zip`
- Included roots: `MQL5/Experts/AI`, `MQL5/Files/AI`
- Excluded live-locked files: `MQL5/Files/AI/ai_performance_journal.jsonl`, `MQL5/Files/AI/archive_pre_strategy_memory_v1/ai_performance_journal.jsonl`
- Excluded dot-prefixed path components included `.claude`, `.continue`, `.git`, `.vscode`, `.venv`, `.gitkeep`

## B. Package A Status Confirmation

Package A status: `COMPLETED_ALREADY_RUNTIME_VALIDATION_PENDING`.

Evidence:

| Claim | Classification | Evidence |
|---|---|---|
| Broad rollback substring no longer exists in `PJ_LineRequiresImmediateFlush()` | CONFIRMED | `performance_journal.mqh:1658-1659` now checks explicit values only; no `StringFind(u, "ROLLBACK") >= 0` match remains in the function |
| `SOFT_ROLLBACK_WARNING` check exists | CONFIRMED | `performance_journal.mqh:1658` |
| `HARD_ROLLBACK_TRIGGER` check exists | CONFIRMED | `performance_journal.mqh:1659` |
| Runtime proof still pending | CONFIRMED | PIML current anchor says Package A completed and `buffered_records_total > 0` remains pending EA reload |

## C. Zone 2 / STRATEGY_RUNTIME_DISABLE_ZONE2 Confirmation

Evidence:

| Claim | Classification | Evidence |
|---|---|---|
| Zone 2-A line range is guarded | CONFIRMED | `strategy_runtime.mqh:275-279` introduces Zone 2-A and `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2`; `strategy_runtime.mqh:564` closes it |
| Zone 1 trigger island is outside the Zone 2-A guard | CONFIRMED | `strategy_runtime.mqh:567-713` is after `#endif` at line 564 and before the Zone 2-B guard at line 722 |
| Zone 1 contains `DetectBollingerReclaimTrigger()` | CONFIRMED | `strategy_runtime.mqh:572` |
| Zone 1 contains `DetectSweepDetectorTrigger()` | CONFIRMED | `strategy_runtime.mqh:616` |
| Zone 2-B line range is guarded | CONFIRMED | `strategy_runtime.mqh:716-722` introduces Zone 2-B and the second `#ifndef`; `strategy_runtime.mqh:1627` closes it |
| `EvaluateCompiledPlan()` is inside Zone 2-B | CONFIRMED | `strategy_runtime.mqh:1595-1627` |
| `EvaluateCompiledPlan()` call sites are only in router legacy branches | CONFIRMED | `decision_mode_router.mqh:120`, `decision_mode_router.mqh:177`; `rg` found no other `.mqh` or `.mq5` call sites |
| No COUNCIL pipeline call site directly consumes Zone 2 | CONFIRMED | `decision_mode_router.mqh:133-167` calls `RunCouncilModePipeline()` for COUNCIL; no `EvaluateCompiledPlan()` call in council runtime/aggregator/pre-filter/governor/core trade files |
| Package B is compile-isolation, not deletion | CONFIRMED | The existing guard excludes compilation without deleting source |
| Package B is safe as "one define only" | CONTRADICTED | `decision_mode_router.mqh:120` and `177` remain unguarded calls to `EvaluateCompiledPlan()`; if `EvaluateCompiledPlan()` is excluded by the define, compile can fail |

If later authorized, the narrowest define placement would be `strategy_runtime.mqh:3`, immediately after:

```mql5
#define __STRATEGY_RUNTIME_MQH__
```

However, that define alone is not Codex-ready. A safe Package B must also include one explicitly authorized compatibility handling decision:

- Guard the GATE/SCORE/HYBRID branches in `decision_mode_router.mqh` under the same define and return a deterministic unsupported-legacy-mode result, or
- Provide a compile-only stub `EvaluateCompiledPlan()` under `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2`.

Both choices affect non-COUNCIL compatibility behavior and need operator authorization.

## D. decision_mode_router Legacy Path Confirmation

| Claim | Classification | Evidence |
|---|---|---|
| GATE/SCORE/HYBRID branches call `EvaluateCompiledPlan()` | CONFIRMED | `decision_mode_router.mqh:118-120` |
| COUNCIL mode bypasses those branches | CONFIRMED | `decision_mode_router.mqh:133-167` runs `RunCouncilModePipeline()` |
| Unknown-mode fallback calls `EvaluateCompiledPlan()` and reports HYBRID | CONFIRMED | `decision_mode_router.mqh:174-183` |
| HYBRID fallback is compatibility-required and should not be removed casually | CONFIRMED | `decision_mode_router.mqh:37-53` normalizes unknown modes to HYBRID; removal would change non-COUNCIL defensive fallback semantics |

## E. council_pre_ai_gate Disconnected Status Confirmation

| Claim | Classification | Evidence |
|---|---|---|
| `EvaluateCouncilPreAIGate()` has no live COUNCIL call sites | CONFIRMED | `rg` found only the function definition in `council_pre_ai_gate.mqh:78-83`; live path uses `RunCouncilPreAIFilter()` at `council_mode_runtime.mqh:2153` |
| Live pass/fail owner is `RunCouncilPreAIFilter()` | CONFIRMED | `council_pre_ai_filter.mqh:88-96`; `council_mode_runtime.mqh:2128-2153` |
| File is self-documented as legacy-preserved/descriptive | CONFIRMED | `council_pre_ai_gate.mqh:10-12` |
| File is included/compiled into `main_ea.ex5` | CONTRADICTED | No `#include "council_pre_ai_gate.mqh"` was found in current `.mq5/.mqh`; latest compile log contains no `council_pre_ai_gate.mqh` include line |
| Package C comment-only annotation is safe | CONFIRMED_WITH_CAVEAT | Safe as documentation, but if the file is not included, compile verification will not prove runtime impact; it remains source-documentation cleanup only |

## F. council_governor Disconnected Status Confirmation

| Claim | Classification | Evidence |
|---|---|---|
| `RunCouncilGovernorDecision()` has no live COUNCIL call sites | CONFIRMED | `rg` found only its definition in `council_governor.mqh:36-41`; live path uses `EvaluateCouncilAIGovernor()` at `council_mode_runtime.mqh:2140` |
| `change_vote_weights` / `new_vote_weight` writes are not executed in live path | CONFIRMED | Dead writes are in disconnected function at `council_governor.mqh:91-98`; no live caller found |
| Live governor owner is `EvaluateCouncilAIGovernor()` | CONFIRMED | `council_ai_governor.mqh:176`; called at `council_mode_runtime.mqh:2140` |
| File is self-documented as legacy reference | CONFIRMED | `council_governor.mqh:6-8` |
| File is included/compiled into `main_ea.ex5` | CONTRADICTED | No `#include "council_governor.mqh"` was found in current `.mq5/.mqh`; latest compile log contains no `council_governor.mqh` include line |
| Package C comment-only annotation is safe | CONFIRMED_WITH_CAVEAT | Safe as documentation, but likely not binary-affecting unless include topology changes later |

## G. runtime_honesty_surfaces Confirmation

| Claim | Classification | Evidence |
|---|---|---|
| Registers disconnected modules | CONFIRMED | `runtime_honesty_surfaces.mqh:299` lists `council_pre_ai_gate.mqh` and `council_governor.mqh` as `LEGACY_PRESERVED` and `DISCONNECTED_FROM_LIVE_ENFORCEMENT` |
| Tracks dormant branch groups | CONFIRMED | `runtime_honesty_surfaces.mqh:301` lists 12 dormant groups |
| Should not be removed | CONFIRMED | It is an active honesty/visibility surface; it emits ownership vocabulary and disconnected-module state at lines 710-715, 1219-1222, 1255-1258, 1275, 1357-1358 |
| Useful as machine-readable honesty documentation | CONFIRMED | JSON/text emission includes `proven_disconnected_modules`, `dormant_branch_groups_tracked`, and enforcement-owner labels |

## H. Dormant Inputs Confirmation

The audit's Package D table is confirmed as 7 inputs across 2 files, not 7 inputs all in `main_ea.mq5`.

| Input | File/Line | Classification |
|---|---:|---|
| `EnableCouncilSetupLifecycle=false` | `main_ea.mq5:71` | CONFIRMED |
| `EnableCouncilExecutionQualityGate=false` | `main_ea.mq5:76` | CONFIRMED |
| `EnableCouncilDirtyEnvironmentTightening=false` | `main_ea.mq5:90` | CONFIRMED |
| `AuthorityStack_EnableDQ=false` | `main_ea.mq5:93` | CONFIRMED |
| `EnableAIEvolution=false` | `main_ea.mq5:126` | CONFIRMED |
| `EnableInternalDashboardChartUI=false` | `main_ea.mq5:192` | CONFIRMED |
| `EnableCouncilTrendContinuationConfirmationReinforcement=false` | `council_mode_runtime.mqh:21` | CONFIRMED |

Package D is comment-only. Inline comments on `input` declarations should compile, but they may affect readability in MetaEditor/source display. They should not change EA input behavior unless the comments are malformed.

## I. DQ Inert Status Confirmation

| Claim | Classification | Evidence |
|---|---|---|
| `AuthorityStack_EnableDQ` is structurally inert | CONFIRMED | `main_ea.mq5:93` default false; `authority_stack_pilot.mqh:270-273` computes DQ proxy then hard-codes `result.dq_would_block=false` |
| P4 remains active | CONFIRMED | `authority_stack_pilot.mqh:267-268`, `281-294` |
| V1 remains active | CONFIRMED | `authority_stack_pilot.mqh:275-277`, `296-308` |
| DQ cleanup should be annotation/clarity only | CONFIRMED | Removal would alter observability fields; active decision behavior is already force-false |

## J. KEEP Items Confirmation

| KEEP Item | Classification | Evidence |
|---|---|---|
| Zone 1 | CONFIRMED | `strategy_runtime.mqh:567-713`; council calls `DetectSweepDetectorTrigger()` at `council_strategies.mqh:810` and `DetectBollingerReclaimTrigger()` at `council_strategies.mqh:915` |
| `council_ai_governor.mqh` | CONFIRMED | Active `EvaluateCouncilAIGovernor()` at `council_ai_governor.mqh:176`, called at `council_mode_runtime.mqh:2140` |
| `level_awareness_brake.mqh` | CONFIRMED | Active `LAB_InferFamilyFromStrategyId()` at `level_awareness_brake.mqh:61`; many `main_ea.mq5` consumers, including line 3090 |
| `core_trade_engine.mqh` | CONFIRMED | Active trade/open/manage functions at `core_trade_engine.mqh:421`, `479`, `934`, `1078`; called from `main_ea.mq5:13086`, `13204`, `13788`, `13792` |
| No-Score hard-lock comments | CONFIRMED | Multiple active-source policy comments, e.g. `main_ea.mq5:11040`, `11142`, `11247`, `11376`, `11483` |
| `compiled_plan_runtime_privilege_frozen` | CONFIRMED | Produced in `main_ea.mq5:290`, `5450`, `5504`, `5922`; consumed by dashboard classifier at `dashboard_state_classifier.mqh:399-400`, `444-445` |
| HYBRID default fallback | CONFIRMED | `decision_mode_router.mqh:37-53`, `174-183`; compatibility fallback, not active under COUNCIL |

## K. Discrepancy Table

| Audit Claim | Codex Classification | Evidence / Reason |
|---|---|---|
| Package A complete, runtime validation pending | CONFIRMED | `performance_journal.mqh:1658-1659`; PIML anchor |
| Zone 2 unreachable in active COUNCIL path | CONFIRMED | Only router calls `EvaluateCompiledPlan()`; COUNCIL branch uses `RunCouncilModePipeline()` |
| Package B is one-define safe | CONTRADICTED | `decision_mode_router.mqh:120` and `177` are unguarded calls to a function that the define would exclude |
| `council_pre_ai_gate.mqh` compiled into binary | CONTRADICTED | No include reference and absent from latest compile log |
| `council_governor.mqh` compiled into binary | CONTRADICTED | No include reference and absent from latest compile log |
| Package C comment-only annotation safe | PARTIALLY_CONFIRMED | Safe as source documentation, but likely not compile/binary-impacting unless include topology changes |
| Package D has 7 dormant inputs | PARTIALLY_CONFIRMED | 7 inputs across 2 files; only 6 are in `main_ea.mq5` |
| `runtime_honesty_surfaces.mqh` should stay | CONFIRMED | Active machine-readable honesty surface |
| DQ inert status | CONFIRMED | `result.dq_would_block=false` at `authority_stack_pilot.mqh:273` |

## L. Package B Readiness Judgment

Package B is not ready as written.

Confirmed safe concept:

- Zone 2 isolation is a compile-isolation package, not deletion.
- Zone 1 is outside the guard and should remain active.

Blocking readiness issue:

- Adding `#define STRATEGY_RUNTIME_DISABLE_ZONE2` alone can exclude `EvaluateCompiledPlan()` while `decision_mode_router.mqh` still calls it in GATE/SCORE/HYBRID and fallback branches.

Required revised Package B decision:

1. Define placement if authorized: `strategy_runtime.mqh:3`, immediately after the include guard define.
2. Add an explicit non-COUNCIL compatibility handling plan:
   - guard router legacy branches, or
   - provide a stub `EvaluateCompiledPlan()` under the disable define.
3. Compile verification is mandatory.
4. Do not combine with cleanup deletion.

Readiness: `PACKAGE_B_NEEDS_MORE_PROOF_AND_REVISED_SCOPE`.

## M. Package C/D Readiness Judgment

Package C:

- Safe as comment-only source annotation.
- Caveat: `council_pre_ai_gate.mqh` and `council_governor.mqh` appear disconnected and not included; comment edits may not affect compiled binary.
- Readiness: `READY_AS_DOCUMENTATION_ONLY_WITH_INCLUDE_CAVEAT`.

Package D:

- Safe as comment-only input annotation.
- Caveat: 7 inputs are across 2 files, not all in `main_ea.mq5`.
- Compile still required if authorized, because comments near `input` declarations can break syntax if malformed.
- Readiness: `READY_COMMENT_ONLY_WITH_LINE_SCOPE_CORRECTION`.

## N. Risks If Cleanup Proceeds

| Risk | Severity | Notes |
|---|---:|---|
| Package B define-only compile break | HIGH | Most important risk; unguarded router calls remain |
| Loss of non-COUNCIL fallback semantics | MEDIUM | Guarding/stubbing `EvaluateCompiledPlan()` changes GATE/SCORE/HYBRID compatibility behavior |
| False confidence from "compiled into binary" claim | MEDIUM | Disconnected files appear not included; comments there are documentation-only |
| Operator confusion from dormant inputs | LOW | Package D helps clarity but must stay comment-only |
| Removing KEEP items | HIGH | Zone 1, live governor, LAB, core trade engine, hard-lock comments, HYBRID fallback, and `compiled_plan_runtime_privilege_frozen` must remain |

## O. Recommended Next Operator Decision

Recommended decision:

1. Do not proceed with Package B as a one-define change.
2. Authorize a revised Package B design review first, explicitly deciding how non-COUNCIL router compatibility should behave when Zone 2 is disabled.
3. Package C may be authorized as documentation-only, but do not expect binary impact unless the files are included later.
4. Package D may be authorized as comment-only annotation across exactly two files: `main_ea.mq5` and `council_mode_runtime.mqh`.
5. Continue Package A runtime validation after reload: verify `buffered_records_total > 0`, `flushed_records_total > 0`, `batched_flush_count > 0`, and `io_reduction_error_count=0`.

## P. Final Decision

`CLEANUP_AUDIT_PARTIALLY_CONFIRMED_WITH_DISCREPANCIES`

No cleanup execution was performed. No source file was modified. No compile was run. No runtime JSON/JSONL file was touched. Production Ready is not claimed.

PIML_READ: YES
PIML_UPDATE: NO
PIML_SECTIONS: NONE
