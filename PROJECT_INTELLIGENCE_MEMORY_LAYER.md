# PROJECT INTELLIGENCE MEMORY LAYER (PIML)

> Official governed project memory and execution-intelligence file.

This file is not a casual note file. It is the structured memory, architecture, execution, dependency, and edge-definition layer for the project.

Primary consumer layers:

- Claude (execution / investigation / architectural reading)
- Codex (implementation / bounded execution)

Secondary purpose:

- preserve architectural truth
- preserve execution continuity
- reduce rediscovery cost
- make targeted deep work possible on one precise section at a time

This file is designed to be filled in stages. Phase 1 = build the storage architecture. Phase 2 = populate each section through focused execution missions.

---

## 0. FILE GOVERNANCE

### 0.1 Identity

- File Name: PROJECT_INTELLIGENCE_MEMORY_LAYER.md
- Short Name: PIML
- Role: governed memory / architecture / execution / edge registry / dependency map
- Scope: whole project
- Authority Type: reference and coordination layer only

### 0.2 Consumer Boundary

Primary Consumers:

- Claude
- Codex

Human Owner:

- Project owner

- Not intended as public documentation
- Not intended as marketing documentation
- Not intended as generic README

### 0.3 Update Discipline

- Every major section should be updateable independently
- Updates must preserve numbering stability where possible
- New entries should append rather than rewrite history unless replacing incorrect truth
- Contradictions must be marked explicitly

### 0.4 Truth Markers

Use these truth labels consistently:

- CONFIRMED_RUNTIME_TRUTH
- CONFIRMED_SOURCE_TRUTH
- CONFIRMED_ARCHITECTURAL_DECISION
- WORKING_ASSUMPTION
- HISTORICAL_CONTEXT
- OPEN_QUESTION
- REJECTED_PATH
- DEFERRED_PATH

### 0.5 Cross-Reference Rule

Every major node should support cross-links using stable IDs such as:

- ARCH-1.2.3
- FUNC-2.4.1
- EDGE-5.3.2
- PLAN-7.1.4
- DEP-4.2.1
- RISK-8.3.1

---

## CURRENT STATE ANCHOR

> Fast-read state surface. For status, next-step, waiting-condition, or frozen-boundary questions — read this block first. Do not read deeper sections unless this block is insufficient.
> Update immediately after any execution that changes project truth at this level.

- **RAM_IO_REDUCTION_AND_PENDING_ACTIVATION_PHASES_READINESS_REVIEW_V1 — REVIEW_COMPLETE (2026-05-11):** Post-fix IO/RAM reduction proof + trade-quality phase readiness review. Runtime window: XAUUSD reload 01:24:23 → ~03:10 (~1h46m). IO Verdict: `RAM_IO_VALIDATION_PASS_PJ_BUFFER_PROVEN`. Trade-Quality Verdict: `TRADE_QUALITY_PHASES_NOT_READY_DO_NOT_ENABLE`. **PJ Buffer post-fix: PROVEN ACTIVE** — `buffered_records_total=8` (was 0 pre-fix), `batched_flush_count=2`, `max_buffer_depth_observed=4`, `direct_write_count=1` (trade-open critical only), `immediate_flush_count=1` (trade-open triggered correct flush), `io_reduction_error_count=0`. Root cause confirmed resolved: bare ROLLBACK classifier was forcing all records critical; fix now classifies only SOFT_ROLLBACK_WARNING and HARD_ROLLBACK_TRIGGER as critical. **OL_RATE PROVEN** — `ol_summary_deferred_count=3`, `write_count=1`. **GOV_HEARTBEAT PROVEN** — `heartbeat_count=5` at 300s. **GOV_DIRTY NOT DEFERRING** (pre-existing issue, `deferred_count=0`). **TRENDCONT_GATE UNKNOWN** (no events in RANGE_MEAN_RECLAIM zone). **Critical event behavior correct** — trade-open at 02:18:39 (bollinger_reclaim BUY) triggered `immediate_flush_count=1`. Trade closed at 03:08:33 as WIN (SUCCESS_MOTIF_CONFIRMED). **IRREW dev flags all FALSE** — IO validation uncontaminated. **All 7 trade-quality phases blocked:** Phase 4A (TPC 0 firings in TC zone), Phase 4B (MFI 1 reading — first ever, calibration insufficient), Phase 4C (39/200 OL records), RCEM (no certified regime matrix), ExecutionGeometry (room_state/stop_geometry_state UNKNOWN in all OL), PlaybookAdvisory (all FORMING, event_order invalid by architecture), FVG_TPB (OBSERVE_ONLY — not in cohort). Next action: continue XAUUSD accumulation; re-check OL count (target ≥200), MFI trigger count (target ≥5), TPC TC-zone firings (target ≥5) after 24–48h. Report: `DOCS_SYSTEM/03_RUNTIME_VALIDATION/RAM_IO_REDUCTION_AND_PENDING_ACTIVATION_PHASES_READINESS_REVIEW_V1.md`.

- **DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1 — REVIEW_COMPLETE (2026-05-11):** Deep spider-web dependency matrix investigation of `decision_mode_router.mqh`, `strategy_runtime.mqh` Zone 2, `EvaluateCompiledPlan()`, and the legacy GATE/SCORE/HYBRID router branches. Read-only. No source changes. Verdict: `PACKAGE_B_READY_BUT_STUB_REQUIRED`. **Core finding:** `EvaluateCompiledPlan()` is defined inside Zone 2-B (strategy_runtime.mqh:1595, inside `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2`). It is called unconditionally at decision_mode_router.mqh:120 (GATE/SCORE/HYBRID branch) and decision_mode_router.mqh:177 (fallback). Both call sites have NO compile guard. Activating `STRATEGY_RUNTIME_DISABLE_ZONE2` alone → compile error (undefined function). **Recommended Package B approach:** `PACKAGE_B_STUB_EVALUATECOMPILEDPLAN` — add `#define STRATEGY_RUNTIME_DISABLE_ZONE2` at strategy_runtime.mqh:3; add stub `EvaluateCompiledPlan()` under `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2` immediately after strategy_runtime.mqh:1627 (Zone 2-B closing `#endif`); stub sets `eval.decision = RUNTIME_REJECT; eval.reason = "Zone2 disabled — COUNCIL-only build"`. **Single file modification:** `strategy_runtime.mqh` only. `decision_mode_router.mqh` unchanged. COUNCIL runtime path completely unaffected (router:133–172 runs `RunCouncilModePipeline()` — never reaches the guarded calls). Zone 1 Trigger Island (strategy_runtime.mqh:567–713) confirmed OUTSIDE Zone 2 guards — `DetectBollingerReclaimTrigger()`, `DetectSweepDetectorTrigger()`, `DetectEMATrendAlignmentTrigger()` remain unconditionally compiled. Stub type requirements (`CompiledPlan`, `TimeframeSnapshot`, `RuntimeEvaluation`, `RUNTIME_REJECT`) all in Zone 1 base (L1–269) — always compiled — no missing types. **Codex package spec written:** `ZONE2_COMPILE_ISOLATION_V1` — see Section K of review. **Status:** DESIGN_COMPLETE — AWAITING_OPERATOR_AUTHORIZATION. Backup required immediately before Codex execution. Compile verification mandatory (0 errors / 0 warnings). Report: `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1.md`.

- **LEGACY_SURFACE_DEAD_CODE_AND_OBSOLETE_FIELD_CLEANUP_AUDIT_V1 — AUDIT_COMPLETE (2026-05-11):** Deep forensic cleanup audit of all major source files for legacy, dead, obsolete, and misleading artifacts under COUNCIL-mode-only production configuration. No source changes. Verdict: `CLEANUP_REQUIRED_HIGH_VALUE`. 25 items classified across 1 REMOVE_NOW, 18 QUARANTINE_LEGACY_DIAGNOSTIC, 8 KEEP. **Largest dead-code mass:** `strategy_runtime.mqh` Zone 2-A + Zone 2-B — ~1,300 of 1,628 lines compiled but entirely unreachable in COUNCIL mode; isolated by `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` guard that is never activated. **Two fully disconnected files compiled into binary:** `council_pre_ai_gate.mqh` (283 lines) and `council_governor.mqh` (145 lines) — both self-documented as legacy-preserved/descriptive, registered in `runtime_honesty_surfaces.mqh` as `LEGACY_PRESERVED, DISCONNECTED_FROM_LIVE_ENFORCEMENT`; functions `EvaluateCouncilPreAIGate()` and `RunCouncilGovernorDecision()` have zero call sites in COUNCIL pipeline. **12 documented dormant branch groups** all properly labeled and machine-readable via runtime_honesty_surfaces output: ACTIVATION_PRESSURE_GATE, DIRTY_ENVIRONMENT_TIGHTENING, EXECUTION_QUALITY_GATE, LIVE_EXIT_ARCHITECTURE, AI_CANDIDATE_BLOCK, AI_ADVISORY_SECURITY_CLEARANCE, COUNCIL_SETUP_LIFECYCLE, TREND_CONTINUATION_REINFORCEMENT, EMERGENCY_FLAT_CRITICAL_SAFETY, INTERNAL_DASHBOARD_CHART_UI, ROLLBACK_ENABLE_SWITCH, ROLLBACK_THRESHOLD_INPUTS. **DQ authority layer structurally inert:** `authority_stack_pilot.mqh:273` hard-codes `dq_would_block=false` regardless of `AuthorityStack_EnableDQ` input — enabling the input has zero decision effect. **PJ_BUFFER false-critical (PJ_BUFFER_CLASSIFIER_FALSE_CRITICAL — Mission E):** `performance_journal.mqh:1658` bare `ROLLBACK` substring check forces immediate-flush on 100% of decision v3 records because rollback_signal field NAME strings in the JSON always contain "ROLLBACK". This is the confirmed root cause of `buffered_records_total=0` in the IO reduction dossier. **Codex Packages:** Package A **COMPLETED** — PJ_BUFFER_CLASSIFIER_FIX_COMPLETE_COMPILE_CLEAN (0 errors / 0 warnings); runtime validation of `buffered_records_total > 0` pending EA reload. Package B (Zone 2 isolation — PACKAGE_B_DESIGN_COMPLETE_STUB_APPROACH — AWAITING_OPERATOR_AUTHORIZATION; deep dependency matrix review complete; see DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1 for Codex package spec ZONE2_COMPILE_ISOLATION_V1). Package C (module annotation for council_pre_ai_gate.mqh + council_governor.mqh — comment-only, awaiting authorization). Package D (input annotation for 7 dormant EA inputs — comment-only, awaiting authorization). No trading path at risk. All active paths confirmed: council_ai_governor.mqh, RunCouncilPreAIFilter, authority_stack_pilot P4/V1 layers, level_awareness_brake, core_trade_engine. Report: `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/LEGACY_SURFACE_DEAD_CODE_AND_OBSOLETE_FIELD_CLEANUP_AUDIT_V1.md`.

- **MT5_IO_REDUCTION_RUNTIME_EVIDENCE_DOSSIER_V1 — DOSSIER_COMPLETE (2026-05-11):** Runtime evidence dossier for MT5_IO_REDUCTION_V1 Package 2. Runtime window: 2026-05-10 22:19:41 → 2026-05-11 00:24:51 (~2h05m) on BTCUSD,M5. Verdict: `IO_REDUCTION_PROVEN_ACTIVE_1`. Key findings: (1) **OL_RATE PROVEN ACTIVE** — `ol_summary_deferred_count=5`, `summary_write_throttle_count=5`, `ol_summary_write_count=1` = 83% write suppression rate; OL_Stage18 log entries corroborate at 22:46:05. (2) **GOV_HEARTBEAT PROVEN ACTIVE** — `governance_heartbeat_count=7` over 2h05m at 300s interval confirmed; ~78% reduction vs per-M1-bar baseline (27 writes vs ~125 per-bar). (3) **GOV_DIRTY NOT DEFERRING** — `governance_deferred_count=0`; dirty key changed on every evaluation in this session; mechanism is active but not suppressing writes because governance state is not stable bar-to-bar. (4) **PJ_BUFFER ZERO ACTIVITY — ANOMALY** — `buffered_records_total=0`, `flushed_records_total=0`, `batched_flush_count=0`, `immediate_flush_count=0`; all 13 PJ writes are direct (`direct_write_count=13` exactly matches 13 "Performance journal appended (decision v3)" Experts log entries). PJ DECISION records appear to bypass `PJ_AppendLine()` buffer-routing path and call `PJ_WriteLineDirect()` directly. This is the primary anomaly requiring source investigation. (5) **TRENDCONT_GATE** — no dedicated counter data; UNKNOWN. (6) **DET NOT UPDATED** — `ai_decision_envelope_trace.jsonl` not written since before reload (mtime 04:29:10 vs reload 22:19:41); 0 new DET records in current session. (7) **IO_ERROR_COUNT=0** — clean; no Experts log errors. (8) **Actual IO reduction magnitude:** Only OL_RATE and GOV_HEARTBEAT are proven; actual reduction is below the projected 60–73% because PJ_BUFFER is inactive. Rollback not recommended (`io_reduction_error_count=0`, no trading impact). Required next action: source read of PJ DECISION write call site in `council_mode_runtime.mqh` or `main_ea.mq5` to resolve bypass anomaly (no source changes). Report: `DOCS_SYSTEM/03_RUNTIME_VALIDATION/MT5_IO_REDUCTION_RUNTIME_EVIDENCE_DOSSIER_V1.md`.

- **UNEXPECTED_BTCUSD_DEMO_TRADES_AFTER_IO_REDUCTION_RELOAD_FORENSIC_V1 — FORENSIC_COMPLETE (2026-05-10):** Emergency forensic investigation of 2 BTCUSD demo trades (SELL 03:35:12 and BUY 04:26:32 on 2026-05-10) discovered after IO Reduction Package 2 reload. Verdict: `TRADES_CAUSED_BY_RUNTIME_EXECUTION_ENABLED_ON_BTCUSD` / `NO_ROLLBACK_NEEDED_IO_REDUCTION_SAFE`. Timeline proof decisive: both trades occurred 17+ hours before IO Reduction Package 2 binary (built 21:24:19); causality is impossible. IRREW dev flags confirmed all false for both trades from OL records (irrew_master_dev_enabled=false, all 6 sub-flags false, baseline_decision==final_decision, dev_flag_that_fired=""). Trade 1: breakdown_momentum_v1 SELL signal in TREND_CONTINUATION / TREND_DOWN zone, NARROW consensus, filter_passed=true; entry 80721.50, SL 80768.13, closed at SL 03:39:58 (~4 bars), failure_class=VOLATILITY_SPIKE_FAILURE. Trade 2: sweep_reversal (SCOUT/LIQUIDITY_REVERSAL) + bollinger_reclaim cross-family confirm, BUY in TREND_CONTINUATION / TREND_DOWN zone, DIVERSE consensus, filter_passed=true; entry 80596.50, SL 80545.88, closed at SL 04:36:40 (~10 bars), failure_class=VOLATILITY_SPIKE_FAILURE. Both trades legitimate V1 COUNCIL architecture decisions with no gate bypass and no system fault. EA was attached to BTCUSD from 2026.05.09 17:48 with EnableRuntimeExecution=true and active O3_FIRST_OPERATING_COHORT_V1. Visibility gap explained: trades opened and closed 4-10 min during overnight hours before operator was monitoring. IO Reduction error count=0; all PJ buffer counters=0; Package 2 is safe. No rollback authorized. Operator action: decide whether BTCUSD execution should remain enabled (current zone=NO_TRADE as of investigation time). Report: `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/UNEXPECTED_BTCUSD_DEMO_TRADES_AFTER_IO_REDUCTION_RELOAD_FORENSIC_V1.md`.

- **FORCED_ENGINEERING_ACTIVATION_OF_ALL_TARGET_ARCHITECTURE_DESIGNS_V1 - IMPLEMENTED + COMPILE_VERIFIED (2026-05-10 00:39:43):** Revised forced-activation plan executed as staged source packages A-D, with Package E report/PIML update. Prior "Development Complete" was valid under the earlier shadow/firewall doctrine but too broad under the new forced-activation definition: several designed V1/IRREW/PCEA components were still ledger-only or registry-only. New default-off inputs added: `EnableIRREWDevelopmentConsumption` master switch plus Phase 4A/4B/4C/RCEM/execution-geometry/playbook-advisory sub-flags. Master switch rule implemented: all runtime-changing development actions are inert unless master=true and the specific sub-flag=true. Source-level capabilities now active behind development flags: role-based Phase 4A cross-family confirmation WAIT, Phase 4B failure/exhaustion WAIT, categorical Phase 4C thesis-quality WAIT/caution, categorical RCEM WAIT/caution, and separate execution-geometry pre-order WAIT. Audit-only capabilities now active: packet registry resolver, playbook resolver, `primary_thesis_strategy_id`, `execution_admission_family`, IRREW schema `OL_V1C_IRREW_DEV_V1`, counterfactual WAIT trace fields, and packet/playbook/failure attribution in opportunity ledger records. Cohort admission now reads `execution_admission_family` when present and falls back to `best_strategy_id` family only if absent. `IMBALANCE_FILL_REVERSAL` remains outside the operating cohort; FVG_TPB/IFR may be thesis/advisory active but cannot execute without separate cohort admission. `PLAYBOOK_VALID` remains thesis completeness only and is not permission, cohort admission, order approval, risk bypass, execution approval, or V1 bypass. SPC runtime paths and EEWP remain rejected for this build; no production-ready claim. Compile logs: `compile_forced_engineering_activation_pkg_a_20260510_001155.log`, `compile_forced_engineering_activation_pkg_b_20260510_002107.log`, `compile_forced_engineering_activation_pkg_c_20260510_002819.log`, `compile_forced_engineering_activation_pkg_d_20260510_003542.log` all report 0 errors / 0 warnings. Final binary timestamp: 2026-05-10 00:39:43. Runtime reload and Production Acceptance remain pending.

- **DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1 - AUDIT_COMPLETE_FIXES_COMPILE_CLEAN (2026-05-10 06:22:51):** Dataflow producer-consumer audit found no verified IRREW/V1/PCEA decision-path defect requiring source correction. Verified log-only cleanup applied in `main_ea.mq5`: legacy compiled-plan library counts, main trigger, and score thresholds are now explicitly labeled as compiled-plan diagnostics under COUNCIL routing; no gates, scores, risk, execution, strategy logic, or IRREW flags changed. Documentation network drift corrected by moving `POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1_REPORT.md` from root to `DOCS_SYSTEM/02_IMPLEMENTATION_REPORTS/`; DOCS_SYSTEM index/manifest updated. Audit report created at `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1_REPORT.md`. Compile log `compile_dataflow_experts_docs_strategy_gap_v1_20260510_061821.log` reports 0 errors / 0 warnings; MetaEditor process exit code remained 1, consistent with prior clean-log process caveat. Binary timestamp: 2026-05-10 06:22:51. Largest strategy coverage gap identified: VCR / volatility-compression-release and breakout/expansion coverage remains the least evidenced playbook lane. Production Acceptance and XAUUSD attach validation remain pending; no Production Ready claim.

- **MT5_IO_REDUCTION_V1_PACKAGE3_FORENSIC_REVIEW - PASS_RELOAD_ALLOWED_WITH_CAVEATS (2026-05-10):** Claude Package 3 forensic review of MT5_IO_REDUCTION_V1 Package 2 complete. Verdict: PASS_RELOAD_ALLOWED_WITH_CAVEATS. All 10 primary checks passed at source level: trading behavior unchanged (source-verified); critical evidence remains immediate (PJ classifier + OL_WriteRecord source-verified); non-critical buffering bounded and safe; event ordering preserved via critical preflush; OnDeinit flush wired at main_ea.mq5:13655; EnableMT5IOReductionV1=false restores direct-write (source-verified); IO counters diagnostic-only (zero references in any trading authority file); runtime JSON/JSONL unmodified (backup timestamp scan SCOPE_CLEAN — 0 unexpected source files modified); no authority path changed; reload can proceed. 7 non-blocking caveats documented (critical-event classifier is substring-based but covers all required events; periodic flush modulo arithmetic acceptable; PJ_FileEndsWithNewline adds 1 extra read-only FileOpen per direct write; governance heartbeat 300s default acceptable; ai_decision_envelope_trace.jsonl buffering consistent with classification; JSON quote-balance check is heuristic; IO status rate-limited 60s). No blocking findings. No source changes in Package 3. Runtime validation per Section P checklist still required. Production Ready = FALSE. Report: `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/MT5_IO_REDUCTION_V1_PACKAGE3_FORENSIC_REVIEW.md`.

- **MT5_IO_REDUCTION_V1_PACKAGE2 - IMPLEMENTED + COMPILE_VERIFIED (2026-05-10 21:24:19):** Primary MT5-side IO reduction implementation complete. New helper `mt5_io_reduction_v1.mqh` adds observability-only counters and default-enabled rollback switches: `EnableMT5IOReductionV1=true`, `EnablePJBuffer=true`, `PJFlushIntervalBars=5`, `PJBufferMaxRecords=20`, `EnableGovernanceDirtyFlag=true`, `RuntimeGovernanceHeartbeatSeconds=300`, `EnableTrendContGate=true`, `TrendContStatusIntervalBars=5`, `EnableOLSummaryRateLimit=true`, `OLSummaryWriteEveryNRecords=5`, `OLSummaryIntervalBars=10`. Source changes are limited to telemetry/file-output behavior in `main_ea.mq5`, `performance_journal.mqh`, and `council_mode_runtime.mqh`: non-critical performance journal and decision-envelope trace records can buffer and batch-flush; critical trade/risk/execution/guardrail/truth/rollback/authority/cohort/risk-envelope/FileOpen/FileWrite evidence forces direct write or immediate preflush; runtime governance status now uses dirty-key gating with timestamp/evaluated_at excluded plus 300-second heartbeat; trend-cont status is bar-interval gated; Opportunity Ledger trigger/event JSONL remains immediate while only `ai_opportunity_summary.json` is rate-limited. New observability snapshot: `AI\mt5_io_reduction_status.json` (`OBSERVABILITY_ONLY_NON_AUTHORITATIVE`). `EnableMT5IOReductionV1=false` is the runtime rollback switch. Compile log `compile_mt5_io_reduction_v1_package2_20260510_211952.log` reports 0 errors / 0 warnings; MetaEditor process exit code was 1 but clean log and binary updated. Expected IO reduction category: MEDIUM pending runtime measurement. No strategy/V1/IRREW/PCEA/risk/execution/stop/target/lot/cohort/score/CRR/DSN/HIGH_CONVICTION/No-Score/DQ behavior changed. Runtime validation debt remains: verify counters, critical preflush/direct-write, governance heartbeat, OL summary throttling, and legacy direct behavior when disabled. Production Ready = FALSE. Report: `DOCS_SYSTEM/02_IMPLEMENTATION_REPORTS/MT5_IO_REDUCTION_V1_PACKAGE2_IMPLEMENTATION_REPORT.md`.

- **MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_PACKAGE_1_V1 — PACKAGE1_SPEC_COMPLETE (2026-05-10):** PRIMARY MT5 load-reduction objective. Architecture spec complete for `MT5_IO_REDUCTION_V1` — 5-component system targeting MT5-side FileOpen/Close reduction. Source IO inventory complete: 179 FileOpen/Write/Close calls across 23 .mqh files + main_ea.mq5; ~22,000–25,000 FileOpen/Close cycles/day. Five components: (1) PJ_BUFFER — RAM buffer for non-critical journal records, flush on TRADE_OPEN/CLOSE/RISK_BLOCK/TRUTH_NOT_READY; (2) HONESTY_GATE — interval gate every N bars for 7 static honesty surfaces (currently 10,080 unnecessary rewrites/day); (3) GOV_DIRTY — dirty-flag suppression for governance status (no-op writes on stable state); (4) TRENDCONT_GATE — interval gate for trend continuation status report; (5) OL_RATE — opportunity ledger summary rate limiter. All 5 components independently controlled by EA input flags; setting all flags to off values restores exact legacy behavior without recompile. Expected reduction: 60–73% fewer FileOpen/Close cycles per M1 bar; 90% reduction in honesty surface writes; 99% reduction in governance status writes on stable state. Files to modify: `performance_journal.mqh`, `main_ea.mq5`, `council_mode_runtime.mqh` only. Sidecar (Stage 2S) reclassified as SECONDARY — it reduces dashboard-side IO only, not MT5-side IO. Spec document: `MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1.md` (AI root). `MT5_EXE_MIGRATION_PLAN.md` Stage 3 added. DOCS_SYSTEM index updated. No source changed by Package 1; no compile run by Package 1; no IRREW flags changed; MT5 authority unchanged; no production-ready claim. Package 2 (Codex implementation): IMPLEMENTED + COMPILE_VERIFIED; runtime validation pending.

- **MT5_EXE_RAM_SIDECAR_MIGRATION_MASTER_PLAN_PACKAGE_1_V1 — PACKAGE1_SPEC_COMPLETE (2026-05-10) [SECONDARY]:** Package 1 (Claude planning/spec) complete for optional read-only EXE/RAM sidecar. Sidecar is a standalone Python background process (FastAPI, localhost:17001) that caches `MQL5/Files/AI/` outputs in RAM and serves them via local HTTP API. Three-category file manifest defined: Category A/B (small/medium status files, full load mtime-invalidated), Category C (large JSONL, tail cursor only — avoids loading 34MB performance journal). Category D (excluded always): `ai_runtime_secrets.json`, `ai_current_plan.json`, `ai_previous_plan_backup.json`, `ai_evolution_state.json`. Sidecar writes only to `EXE_RUNTIME_CACHE/` (outside `MQL5/Files/AI/`). `ArtifactStore` in `sources.py` gets optional `SidecarClient` proxy with 150ms timeout + transparent fallback to direct reads. No change to `.mq5`/`.mqh` source, aggregator, IRREW flags, or any trading logic. Resolves DEC-WRITE-001/002, DEC-CONC-001, DEC-PATH-001, DEC-SECRET-001/002/003 from Stage 2R pending decision register. Package 2 (Codex implementation) authorized — no approval gates mid-task. Spec: `DOCS_SYSTEM/01_ARCHITECTURE/MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1.md`. Stage 2S added to `MT5_EXE_MIGRATION_PLAN.md`. DOCS_SYSTEM index updated (01_ARCHITECTURE: 7 files, total: 34). No source changed; no compile run; MT5 authority unchanged; no production-ready claim.

- **MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1 — TESTER_PARTIAL_EVIDENCE_REQUIRES_LIVE_XAUUSD (2026-05-10):** Read-only maximum-depth Strategy Tester and source analysis validation mission. Tester environment confirmed ready with caveats (terminal running at PID 7112 during open market hours — tester must be UI-initiated to avoid lock conflict). Binary confirmed: `main_ea.ex5` 2026-05-10 06:22:51. File isolation confirmed: no `FILE_COMMON` flag — tester writes to agent-isolated directory, not live `MQL5/Files/AI/`. 16 of 17 validation targets confirmed via static IRREW architecture analysis. Key architecture findings: `IRREW_SubFlagActive` is a pure AND gate (no evaluator fires when master=false); `IRREW_ApplyDevelopmentWaitProtocol` converts directional decisions → WAIT only (cannot promote REJECT); Phase4C THIN/UNCERTAIN states are advisory-only (no `development_wait_requested=true`); RCEM REDUCED is advisory-only (no WAIT); Playbook Advisory dev has no evaluator function in current source (OL-serialized only at `council_mode_runtime.mqh:L1767`). 1 TESTER_REQUIRED item: XAUUSD M5 OL records with `fvg_tpb` `evaluations_seen > 0` (XAUUSD M5 tester cache confirmed available). 9 tester `.set` files created in `MQL5/Profiles/Tester/`; 9 INI configs created in `MQL5/Experts/AI/TESTER_CONFIGS/`. No source changed; no compile run; no IRREW flags changed. Full report: `DOCS_SYSTEM/03_RUNTIME_VALIDATION/MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1.md`. Next operator action: run tester UI with provided `.set` files; attach EA to XAUUSD M5 per `DOCS_SYSTEM/03_RUNTIME_VALIDATION/XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1.md`.

- **STRATEGY_REHABILITATION_AND_CONFIRM_ENGINEERING_EXECUTION_PLAN_V1 — PLAN_ACCEPTED | PACKAGE_1_IMPLEMENTED_COMPILE_VERIFIED | PACKAGE_2_IMPLEMENTED_COMPILE_VERIFIED | PACKAGE_3_IMPLEMENTED_COMPILE_VERIFIED (2026-05-06):** Full institutional blueprint for strategy rehabilitation and CONFIRM layer reengineering. Package 1, Package 2, and Package 3 operator authorizations received and implemented. **STATUS: PACKAGE_1_COMPILE_VERIFIED; PACKAGE_2_COMPILE_VERIFIED; PACKAGE_3_COMPILE_VERIFIED; RUNTIME_CONFIRMATION_PENDING.**

  **A. EXECUTIVE INTENT —** Next phase: REHABILITATE_EXISTING_STRATEGIES_FIRST. System does not need more strategies. It needs existing strategies to stop losing value, to fire in meaningful ways, and to confirm each other independently. The CONFIRM layer is technically present but functionally weak: in RMR (dominant zone), only one reliable CONFIRM exists (bollinger_reclaim); in TC zone, the CONFIRM layer is actively harmful (momentum_breakout_cont_v1). Three bounded packages, executed sequentially with compile-verify between each. CRR/DSN/zone-classifier/governor/core_trade_engine: NOT TOUCHED in any package. **Strategy expansion: NOT AUTHORIZED at this stage.** Maturity: DEVELOPING. Production-ready: NOT CLAIMED.

  **B. ACCEPTED BASELINE —** (1) System coherent but not edge-positive. (2) Maturity = DEVELOPING. (3) Issue = SUFFICIENT_BUT_CALIBRATION_WEAK + CONFIRM_LAYER_WEAKNESS + SOME_HARMFUL_STRATEGIES. (4) CRR/DSN are correct structural protection — not to be weakened. (5) Zone classifier: not to be changed. (6) Score-authority restoration: forbidden (hard-locked in council_mode_runtime.mqh L198–199). (7) bollinger_reclaim: CORE_EDGE_CANDIDATE (9W/12L = 43.5%, 27 entries). (8) trend_momentum: UNDER_REPAIR after guard V1 (5W/12L = 29.4%, 17 entries post-guard). (9) TPC: architecturally promising, zero executions, trigger over-tight. (10) mfi_reversal_assist: dormant (34 obs, 0 entries). (11) CONFIRM layer requires major redesign. Refinements from this review: sweep_detector "isolation" question resolved (see C); CONFIRM weakness in TC zone is more severe than previously assessed — after Package 1 freeze, TC zone has effectively NO functional BUY CONFIRM except TPC (never fired) and micro_structure_reentry_v1 (1 entry); TPC pullback zone is over-constrained at ATR×0.25 (source-verified council_strategies.mqh L1211); trend_momentum has a second confirmed failure mode REGIME_LABEL_M1_INCOHERENCE (identified 2026-05-06 01:35 SELL loss).

  **C. SWEEP_DETECTOR / SWEEP_REVERSAL VERDICT —** sweep_detector (STI_0039) is classified INDICATOR_FRAGMENT, not a council strategy (source: library_indicators.mqh). It exists as the base trigger function `DetectSweepDetectorTrigger()` in strategy_runtime.mqh L616–647 (live, Zone 1 Trigger Island, unconditionally compiled). The current council equivalent is sweep_reversal (SCOUT, LIQUIDITY_REVERSAL family, vote_weight=0.60, L783 council_strategies.mqh) which calls the same trigger. The legacy ai_strategy_memory.json entry "sweep_detector" (26W/22L, 54.2% WR, total_observations=0) is from the pre-council plan-based execution era — sweep_detector was the MAIN TRIGGER in plan_v076 SCORE/HYBRID/GATE mode without CRR/DSN/zone routing. That execution context no longer exists. Current sweep_reversal (council) achieves 43.2% WR (35 entries, degradation_hint=TRUE). **VERDICT: No revival or recovery action needed. sweep_reversal IS the modern council version. sweep_detector legacy edge was real but context changed.** Action: preserve sweep_reversal at current state; monitor next 50 entries; review only if WR falls below 35% sustained.

  **D. STRATEGY REHABILITATION MAP —** Classification by evidence: PRESERVE_CORE_EDGE: bollinger_reclaim (MEAN_RECLAIM, CONFIRM, RMR, 43.5% WR — preserve unchanged). PRESERVE_MONITOR: sweep_reversal (LIQUIDITY_REVERSAL, SCOUT, 42.9% WR, degradation_hint — observe 50 more entries). OBSERVE_UNDER_REPAIR: trend_momentum (TREND_CONTINUATION, TREND_JUDGE, TC, guard V1 live, 29.4% WR — observe guard results; second failure mode REGIME_LABEL_M1_INCOHERENCE identified but deferred). FREEZE_STRATEGICALLY_APPROVED_IN_PLAN (implementation requires separate operator authorization): momentum_breakout_cont_v1 (TREND_CONTINUATION, CONFIRM, TC only, 1W/10L 9.1% WR — trigger fires on large-body late-continuation candle ≥0.55×ATR closing above prior high; same failure mode as trend_momentum but without any guard; no guard can correct this trigger). REDESIGN_TRIGGER (Package 2): trend_pullback_cont_v1 (TREND_PULLBACK_CONTINUATION, CONFIRM, TC+RMR_trend, 0 entries — pullback zone ATR×0.25 over-constrained); micro_structure_reentry_v1 (TREND_CONTINUATION, CONFIRM, TC only, 1 entry — add not_late guard). REDESIGN_TRIGGER (Package 3): mfi_reversal_assist (MOMENTUM_REVERSAL_ASSIST, EXHAUSTION_JUDGE, REV/RMR, 0 entries — MFI threshold <45/>55 nearly impossible; redesign to <55/>45). OBSERVE_INSUFFICIENT_DATA: breakdown_momentum_v1 (TREND_CONTINUATION, CONFIRM, TC, SELL_ONLY, 30% 10 entries); lower_high_rejection_v1 (TREND_CONTINUATION, CONFIRM, TC, SELL_ONLY, 0 entries); range_edge_fade (MEAN_RECLAIM, CONFIRM, Range, 0% 2 entries); mean_reversion_bounce (MEAN_RECLAIM, CONFIRM, Range, 0 entries 8 obs). ACTIVATE_VERIFY (Package 3): fake_break_reversal (LIQUIDITY_REVERSAL, SCOUT, REV/RMR, 0 entries). LOW_PRIORITY_ZONE_RARE: range_compression_breakout, volatility_squeeze_release, volatility_breakout, expansion_continuation, micro_range_expansion (all 0 entries; activation zones are rare — deferred).

  **E. CONFIRM LAYER REENGINEERING PLAN —** Current CONFIRM weaknesses: TC zone post-freeze has NO functional BUY CONFIRM (only micro_structure_reentry_v1 barely fires; TPC never fires; breakdown/lower_high SELL_ONLY only). RMR zone has bollinger_reclaim as sole reliable CONFIRM (mean_reversion_bounce + range_edge_fade barely fire; all MEAN_RECLAIM family — no cross-family diversity). REV zone mfi_reversal_assist is dormant. Same-family vs cross-family rules: same-family CONFIRM is acceptable when the trigger mechanism is genuinely different (e.g., bollinger_reclaim vs mean_reversion_bounce — different signal types despite same family); cross-family CONFIRM is required in TC zone because all TREND_CONTINUATION CONFIRM strategies share the same family as trend_momentum TREND_JUDGE (no diversity_score increase without cross-family vote). TPC (TREND_PULLBACK_CONTINUATION) is the only designed cross-family CONFIRM in TC zone — activating TPC via Package 2 is the direct fix. TC CONFIRM after full implementation: TPC (cross-family TREND_PULLBACK_CONTINUATION, BOTH directions) + micro_structure_reentry_v1 (hardened, BOTH directions) + breakdown_momentum_v1 (SELL_ONLY, observe) + lower_high_rejection_v1 (SELL_ONLY, observe). RMR CONFIRM after full implementation: bollinger_reclaim (primary) + TPC V2B (cross-family, trend eras) + mean_reversion_bounce (Package 3). REV CONFIRM after full implementation: mfi_reversal_assist (redesigned, EXHAUSTION_JUDGE) + sweep_reversal (SCOUT) + fake_break_reversal (SCOUT, Package 3). RANGE_MOMENTUM_CONFIRM: NOT AUTHORIZED at this stage — existing evidence gap is TC cross-family confirm (addressed by TPC) not range momentum; revisit after Package 3.

  **F. PACKAGE 1 — STRATEGY_HARM_REMOVAL_AND_STABILIZATION_V1 — MOMENTUM_BREAKOUT_CONT_V1_FREEZE_PACKAGE IMPLEMENTED + COMPILE_VERIFIED (2026-05-06 04:25:05):**
  Objective: Remove momentum_breakout_cont_v1 from live CONFIRM execution. Smallest, safest, most evidence-backed action. No new behaviors introduced.
  Included strategies: momentum_breakout_cont_v1 only.
  Affected files: council_strategies.mqh ONLY — function BuildCouncilStrategy_MomentumBreakoutContinuation() (~L1651–1708).
  Forbidden: all other strategy functions; aggregator; pre-AI filter; governor; core_trade_engine; strategy_runtime.mqh; main_ea.mq5; JSON files; DetectMomentumBreakoutContinuationTrigger() NOT to be deleted (retained for future redesign).
  Exact change (Codex blueprint): In BuildCouncilStrategy_MomentumBreakoutContinuation(), insert the following block immediately after CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM); and BEFORE the zone guard block (currently at ~L1666):
  `// FREEZE_V1 — momentum_breakout_cont_v1 demoted from active CONFIRM. 2026-05-06.`
  `// Evidence: 1W/10L (9.1% WR). Trigger fires on large-body late-continuation candle >=0.55*ATR`
  `// closing above prior high — worst entry timing. Same failure mode as trend_momentum, no guard.`
  `// See PIML STRATEGY_REHABILITATION_AND_CONFIRM_ENGINEERING_EXECUTION_PLAN_V1.`
  `r.decision = COUNCIL_DECISION_WAIT;`
  `r.short_reason = "Frozen: study/rework status";`
  `r.explanation = "momentum_breakout_cont_v1 frozen pending redesign (SRCEV1)";`
  `r.score_final = 0.0;`
  `r.vote_weight = 0.0;`
  `CouncilFinalizeStrategyReport(r);`
  `r.vote_weight = 0.0;` (source-truth correction: finalizer resets vote_weight <= 0.0)
  `return;`
  Pre-implementation: backup MQL5\Experts\AI\ + MQL5\Files\AI\ to D:\MT5_Project_Backups\pre_change_<YYYYMMDD_HHMMSS>_mbcv1_freeze.zip (STOP if fails).
  Compile: main_ea.mq5 → 0 errors / 0 warnings. Log: compile_mbcv1_freeze_<YYYYMMDD_HHMMSS>.log. Binary timestamp must advance.
  Risk: VERY LOW — removing false-confirmation; no valid edge lost.
  Rollback: remove the 10-line FREEZE_V1 block; recompile; reload (~2 minutes).
  Closure evidence: council_report.txt shows short_reason="Frozen: study/rework status" for momentum_breakout_cont_v1 on every bar; no new entries in ai_strategy_memory.json for this strategy after reload.
  Implementation update: `council_strategies.mqh` changed only in `BuildCouncilStrategy_MomentumBreakoutContinuation()`. `momentum_breakout_cont_v1` now hard-returns `WAIT` with `short_reason="Frozen: study/rework status"`, `score_final=0.0`, and final `vote_weight=0.0`. `DetectMomentumBreakoutContinuationTrigger()` retained unchanged for future redesign. Package 2 and Package 3: NOT IMPLEMENTED. DSN/CRR/zone classifier/V1/P4/DQ/stop geometry/order execution/runtime JSON/plan JSON/operating cohort: NOT CHANGED. Compile log: `compile_mbcv1_freeze_20260506_042020.log` — 0 errors / 0 warnings; `main_ea.ex5` advanced 2026-05-05 15:43:22 → 2026-05-06 04:25:05. Runtime confirmation pending after EA reload.

  **G. PACKAGE 2 — TC_CONFIRM_RESTORATION_AND_TPC_ACTIVATION_V1 — IMPLEMENTED + COMPILE_VERIFIED (2026-05-06 05:00:55):**
  Objective: Repair TPC's over-tight pullback trigger to enable cross-family confirmation in TC zone and TREND_ERA_RANGE_EXRA. Add not_late guard to micro_structure_reentry_v1.
  Included strategies: trend_pullback_cont_v1 (trigger fix); micro_structure_reentry_v1 (guard addition).
  Affected files: council_strategies.mqh ONLY — two trigger functions: DetectTrendPullbackContinuationTrigger() (~L1106–1180); DetectTrendPullbackContinuationTriggerDiag() (~L1181–1253, V2B variant); DetectMicroStructureReentryTrigger() (~L1517–1578).
  Forbidden: zone routing logic; council_aggregator.mqh; council_pre_ai_filter.mqh; strategy_runtime.mqh; core_trade_engine.mqh; main_ea.mq5 inputs; JSON files; TPC role/family/weight.
  Exact changes (Codex blueprint):
  Change 1 — TPC pullback zone widening (BOTH trigger variants): Change `atrM1 * 0.25` → `atrM1 * 0.70` in the pullback bool conditions. BUY: `bool pullback = (c2 < o2) && (l2 <= emaFastM5 + atrM1 * 0.70) && (l2 >= emaSlowM5 - atrM1 * 0.50);` SELL: `bool pullback = (c2 > o2) && (h2 >= emaFastM5 - atrM1 * 0.70) && (h2 <= emaSlowM5 + atrM1 * 0.50);` Inner lower/upper bound (emaSlowM5 ± 0.50 ATR) unchanged. Rationale: M5 EMA20 zone band of 0.25 ATR is too tight for M1 bars; 0.70 ATR represents the same pullback-to-EMA concept in realistic M1 bar geometry. Apply to BOTH DetectTrendPullbackContinuationTrigger() and DetectTrendPullbackContinuationTriggerDiag() — identical logic.
  Change 2 — micro_structure_reentry not_late guard: In DetectMicroStructureReentryTrigger(), after ATR retrieval and before the trendDir==CORE_BUY block, insert: `double ema20Msr = 0.0; RT_GetEMA(PERIOD_M1, 20, 1, ema20Msr); double c1Msr = RT_Close(PERIOD_M1, 1); const double MSR_NOT_LATE_MULT = 1.20; bool msrNotLateBuy = (ema20Msr <= 0.0) ? true : ((c1Msr - ema20Msr) <= atr * MSR_NOT_LATE_MULT); bool msrNotLateSell = (ema20Msr <= 0.0) ? true : ((ema20Msr - c1Msr) <= atr * MSR_NOT_LATE_MULT);` Then AND msrNotLateBuy / msrNotLateSell into the respective BUY/SELL return blocks. ATR fail-open: if ema20 unavailable, guard does not fire.
  Risk: LOW-MEDIUM. TPC widening may produce entries in previously-excluded contexts; not_late guard on MSR reduces firing frequency slightly. First 20–30 TPC executions must be monitored closely.
  Rollback: revert the two trigger function changes; recompile; reload (~5 minutes).
  Closure evidence: TPC short_reason "Trend pullback -> continuation" appears in council_report.txt in TC or RMR+trend era; ai_strategy_memory.json shows TPC entries within 48 hours of reload.
  Implementation update: `council_strategies.mqh` changed only. Required functions changed: `DetectTrendPullbackContinuationTrigger()`, `DetectTrendPullbackContinuationTriggerDiag()`, `DetectMicroStructureReentryTrigger()`. Conditional/current-source-required function changed: `BuildCouncilStrategy_MicroStructureReentry()` to preserve late-guard trigger reasons that were otherwise overwritten by the generic invalid-trigger reason. TPC fast EMA pullback proximity bound widened `0.25 -> 0.70` in both base and diagnostic/V2B trigger variants; slow EMA `0.50`, confirm candle logic, not_late `1.20`, quality formula, role/family/weight, V2B dispatch, and zone gates unchanged. `micro_structure_reentry_v1` now has a hardening-only EMA20(M1) not_late guard using existing ATR(M1,14,shift=1); EMA failure is fail-open, ATR behavior remains fail-closed. Package 1 freeze remains implemented and unchanged. `DetectMomentumBreakoutContinuationTrigger()` retained unchanged. Package 3: NOT IMPLEMENTED. DSN/CRR/zone classifier/V1/P4/DQ/stop geometry/order execution/runtime JSON/plan JSON/operating cohort: NOT CHANGED. Compile log: `compile_tc_confirm_restoration_tpc_activation_v1_20260506_045636.log` — 0 errors / 0 warnings; `main_ea.ex5` advanced 2026-05-06 04:25:05 -> 2026-05-06 05:00:55. Runtime confirmation pending after EA reload.

  **H. PACKAGE 3 — RANGE_CONFIRM_STRENGTHENING_AND_EXHAUSTION_REVIVAL_V1 — IMPLEMENTED + COMPILE_VERIFIED (2026-05-06 05:26:41):**
  Objective: Redesign mfi_reversal_assist to practical thresholds; activate mean_reversion_bounce and range_edge_fade more reliably; verify and activate fake_break_reversal.
  Included strategies: mfi_reversal_assist; mean_reversion_bounce; range_edge_fade; fake_break_reversal.
  Affected files: council_strategies.mqh ONLY — strategy function bodies for the above four strategies.
  Forbidden: zone routing logic for any strategy; council_aggregator.mqh; council_pre_ai_filter.mqh; core_trade_engine.mqh; main_ea.mq5 inputs; JSON files.
  Exact changes (Codex blueprint):
  Change 1 — mfi_reversal_assist trigger redesign: In BuildCouncilStrategy_MFIReversalAssist(), change the trigger threshold lines (currently council_strategies.mqh ~L1389–1390): FROM: `bool buySignal = (mfi1 > mfi2 && mfi1 < 45.0 && RT_BullishRejection(PERIOD_M1, 1));` `bool sellSignal = (mfi1 < mfi2 && mfi1 > 55.0 && RT_BearishRejection(PERIOD_M1, 1));` TO: `// MFI Exhaustion Assist V2 — threshold widened from extreme (<45/>55) to elevated (<55/>45).` `// Original never fired in 34 observations. V2 represents momentum-fading (turning from elevated)` `// rather than deep-extreme reversal — a realistic exhaustion observation for M1 XAUUSD.` `bool buySignal = (mfi1 > mfi2 && mfi1 < 55.0 && RT_BullishRejection(PERIOD_M1, 1));` `bool sellSignal = (mfi1 < mfi2 && mfi1 > 45.0 && RT_BearishRejection(PERIOD_M1, 1));` Directional turning condition (mfi1>mfi2/mfi1<mfi2) preserved. Candle rejection condition preserved.
  Change 2 — mean_reversion_bounce: Read full function body before editing. Verify range bounds buffer calculation (currently `buf = MathMax(4.0, atrPts * 0.18) * _Point`). If trigger rarely fires due to overly tight buffer, consider widening to `atrPts * 0.30`. Determine from source reading whether this is the constraining condition.
  Change 3 — range_edge_fade: Read full function body before editing. Verify trigger conditions. If functionally sound, no change needed — observe first execution cycle.
  Change 4 — fake_break_reversal: Read full function body before editing. Verify no hard-disabled block exists. If trigger is sound and no disable present, no source change needed — strategy should activate naturally in reversal context.
  IMPORTANT: Codex must read each target function in FULL before editing. Do not edit based on assumptions.
  Risk: LOW-MEDIUM. mfi_reversal_assist is EXHAUSTION_JUDGE with REDUCED eligibility in most zones — DSN/CRR still gate final execution. mean_reversion_bounce and range_edge_fade are range-hard-gated — cannot fire outside range context.
  Rollback: revert strategy function bodies; recompile; reload (~5 minutes).
  Closure evidence: mfi_reversal_assist shows first entries in ai_strategy_memory.json within 48 hours; mean_reversion_bounce fires in range context in council_report.txt.
  Implementation update: `council_strategies.mqh` changed only. Changed strategies/functions: `mfi_reversal_assist` via `BuildCouncilStrategy_MFIReversalAssist()` threshold adjustment (`BUY: mfi1 < 45.0 -> mfi1 < 55.0`; `SELL: mfi1 > 55.0 -> mfi1 > 45.0`) and `mean_reversion_bounce` via `BuildCouncilStrategy_MeanReversionBounce()` range-bound proximity buffer widening (`atrPts * 0.18 -> atrPts * 0.30`). Inspected but not changed: `range_edge_fade` (`RANGE_EDGE_FADE_NO_SAFE_CHANGE`) and `fake_break_reversal` (`FAKE_BREAK_REVERSAL_ACTIVE_NO_SOURCE_CHANGE`). Package 1 freeze remains implemented and unchanged. Package 2 TPC/MSR changes remain implemented and unchanged. DSN/CRR/zone classifier/V1/P4/DQ/stop geometry/order execution/runtime JSON/plan JSON/operating cohort: NOT CHANGED. Compile log: `compile_range_confirm_strengthening_exhaustion_revival_v1_20260506_052231.log` — 0 errors / 0 warnings; `main_ea.ex5` advanced 2026-05-06 05:20:44 -> 2026-05-06 05:26:41. Runtime confirmation pending after EA reload.

  **I. FORBIDDEN CHANGES (ALL PACKAGES) —** council_pre_ai_filter.mqh (CRR/DSN): NOT TOUCHED. council_aggregator.mqh: NOT TOUCHED. council_ai_governor.mqh: NOT TOUCHED. core_trade_engine.mqh: NOT TOUCHED. main_ea.mq5 inputs: NOT TOUCHED. Zone classifier (ClassifyCouncilZone): NOT TOUCHED. Operating cohort / factory admission JSON: NOT TOUCHED. Strategy roles: NOT TOUCHED. Strategy families: NOT TOUCHED. Strategy vote_weights (except momentum_breakout_cont_v1 which is set to 0 via FREEZE_V1 block): NOT TOUCHED. DetectMomentumBreakoutContinuationTrigger() function body: NOT DELETED (retained for future redesign). Score authority: NOT RESTORED. CRR/DSN thresholds: NOT LOWERED. Operating cohort / factory admission: NOT CHANGED.

  **J. CODEX EXECUTION INSTRUCTIONS —** This plan is your sole authority for strategy rehabilitation. Read this PIML entry in full before beginning any package. Package sequencing is mandatory: Package 1 → compile-verify → observe → Package 2 → compile-verify → observe → Package 3. Do NOT skip verification steps. Do NOT implement any package before receiving a separate explicit operator implementation command for that package. Do NOT implement multiple packages in a single session. Read each target function in FULL before editing. Verify current line numbers from source (line numbers cited are approximate — verify from function name search). Use backup-compile-verify protocol for each package. Do not implement if compilation produces any new warning or error. Do not touch any file not listed in each package's "Affected files" section. Do not delete any trigger functions — freeze strategies via function body logic, not deletion. After each package: update PIML with status IMPLEMENTED_COMPILE_VERIFIED before proceeding to the next.

  **K. CLAUDE REVIEW CHECKPOINTS —** After Package 1: read council_report.txt to verify momentum_breakout_cont_v1 shows "Frozen: study/rework status" on every bar; verify ai_strategy_memory.json shows no new entries for momentum_breakout_cont_v1. After Package 2: read council_report.txt over 24–48 hours to confirm TPC trigger appears ("Trend pullback -> continuation") in TC zone or RMR+trend era bars; read ai_strategy_memory.json for TPC entry count. After Package 3: assess first mfi_reversal_assist entries for direction accuracy and quality; confirm no regression in bollinger_reclaim WR. Before Package 3: read fake_break_reversal source function in full to verify no hidden disable block before authorizing Codex.

  **L. MANAGEMENT DELIVERY CONTEXT —** Current maturity: DEVELOPING. Cannot claim edge-positive trading. System aggregate WR 40.7% on XAUUSD is marginal at RR=1.5 break-even. What can be shown NOW: architecture overview (17-strategy council, zone routing, family governance, structural gates); sound governance evidence (CRR/DSN, operating cohort, factory admission); baseline stats as developing system. What cannot be claimed: edge-positive trading; WR sufficient for live capital; CONFIRM independence (currently weak); scalability or capital readiness. After Package 1: "Harm removal complete. Active harmful strategy frozen. Architecture stable." After Package 2: "CONFIRM layer functional in primary execution zones. Tracking forward win rate." After Package 3: "All major strategy roles now functional. Minimum viable architecture coverage." Evidence for STABILIZING: net P/L toward neutral over 50+ post-package trades; trend_momentum WR >38% over 30+ post-guard entries; TPC first 20 entries WR >35%; bollinger_reclaim maintaining WR >40% over 50+ entries; no active CONFIRM strategy below 15% WR. Evidence for PRE_PRODUCTION_CANDIDATE: positive net P/L over 100+ trades; aggregate WR >43%; at least 2 independent strategies WR >40% over 30+ entries each; DIVERSE/HIGH_CONVICTION consensus in ≥20% of executed trades; zero active CONFIRM strategies below 20% WR; management briefing with evidence audit complete.

  **M. RISK AND CONTRADICTION SECTION —** Risk: Freezing momentum_breakout_cont_v1 creates TC CONFIRM gap (MEDIUM — mitigated by Package 2 which addresses the gap; false-confirm removal is net positive). Risk: TPC pullback zone widening 0.25→0.70 ATR introduces lower-quality pullbacks (MEDIUM — existing not_late guard ATR×1.20 and lower bound emaSlowM5±0.50 ATR still exclude excessive pullbacks; first 20–30 TPC executions require monitoring). Risk: mfi_reversal_assist threshold widening produces false exhaustion signals (LOW-MEDIUM — structurally contained by EXHAUSTION_JUDGE role with REDUCED eligibility; DSN/CRR still gate). Risk: sweep_reversal edge genuinely degrading (LOW now — 43% WR over 35 entries is within variance; deferred until 50 more entries). Contradictions: (1) DSN gate stated as `family_diversity < 0.30 AND consensus ≠ HIGH_CONVICTION → REJECT`, yet trend_momentum executes with NARROW consensus and single-family votes — the exact bypass mechanism requires source re-verification before Package 2 (if TPC fires and increases diversity, does DIVERSE consensus become achievable?). (2) ai_strategy_memory.json sweep_detector entry (26W/22L) is from legacy era with total_observations=0 — these numbers do not represent current council execution. (3) trend_momentum 2026-05-06 loss (SELL, -$19.20, regime_label=TREND_DOWN but trend_state=RANGE): confirmed second failure mode REGIME_LABEL_M1_INCOHERENCE; not_late guard V1 did not prevent this loss; potential future guard: require trend_state ≠ RANGE when regime_label = TREND_UP/DOWN — deferred pending guard V1 data. Unknowns: TPC V2B fire rate after trigger widening (unknown until Package 2 deploys); whether regime_label/trend_state incoherence is systematic or episodic for trend_momentum (needs more loss classification data); whether breakdown_momentum_v1 and lower_high_rejection_v1 have genuine edge (30% WR on 10 entries is within variance — needs 30+ entries).

  **N. FOOTER —** `PLAN_ID: STRATEGY_REHABILITATION_AND_CONFIRM_ENGINEERING_EXECUTION_PLAN_V1` | `PLAN_DATE: 2026-05-06` | `STATUS: PLAN_ACCEPTED` | `SOURCE_CHANGED: NO (PIML documentation update only)` | `CODE_IMPLEMENTATION: NOT YET AUTHORIZED` | `COMPILE_RUN: NO` | `STRATEGY_TESTER_USED: NO` | `DECISION_SAMPLE_SIZE: 7017` | `TRADE_SAMPLE_SIZE: 145 (59W/86L)` | `STRATEGY_COUNT: 17` | `CONFIRM_STRATEGY_COUNT: 9 (incl. TPC and mfi as EXHAUSTION_JUDGE)` | `LEGACY_SWEEP_STATUS: RESOLVED — sweep_reversal IS the council version; no revival needed` | `MOMENTUM_BREAKOUT_CONT_STATUS: FREEZE STRATEGICALLY APPROVED IN PLAN; IMPLEMENTATION STILL REQUIRES SEPARATE OPERATOR AUTHORIZATION` | `TREND_MOMENTUM_STATUS: UNDER_REPAIR (guard V1 live; second failure mode REGIME_LABEL_M1_INCOHERENCE identified, deferred)` | `TPC_STATUS: REDESIGN_TRIGGER REQUIRED — pullback zone 0.25→0.70 ATR (Package 2)` | `MFI_REVIVAL_STATUS: REDESIGN_TRIGGER REQUIRED — threshold <45/>55 → <55/>45 (Package 3)` | `CONFIRM_LAYER_STATUS: WEAK but repairable with 3 packages; no new strategies needed` | `STRATEGY_EXPANSION_AUTHORIZED: NO` | `PRIMARY_NEXT_PHASE: REHABILITATE_EXISTING_STRATEGIES_FIRST` | `CURRENT_MATURITY: DEVELOPING` | `PRODUCTION_READY_CLAIMED: NO` | `RECOMMENDED_FINAL_DECISION: REHABILITATE_EXISTING_STRATEGIES_FIRST` | `FIRST_EXECUTION_PACKAGE: MOMENTUM_BREAKOUT_CONT_V1_FREEZE_PACKAGE` | `NEXT_TASK: Await separate operator authorization for MOMENTUM_BREAKOUT_CONT_V1_FREEZE_PACKAGE implementation`

- **TREND_MOMENTUM_ENTRY_TIMING_GUARD_V1 — IMPLEMENTED + COMPILE_VERIFIED (2026-05-05 15:43:22):** BEHAVIOR_CHANGED: YES — trend_momentum trigger only. Root cause source-confirmed: `DetectEMATrendAlignmentTrigger()` (strategy_runtime.mqh L649–686) was a state predicate with no freshness guard. 7/9 all-time trend_momentum losses tagged LATE_CONTINUATION_FAILURE; 5W/11L = 31.25% win rate (ai_strategy_memory.json, 24 total_entries), below break-even at RR=1.5. Change: added `not_late` guard to `DetectEMATrendAlignmentTrigger()` — BUY: `(close[M1,1] - EMA20[M1]) <= ATR(M1,14) * 1.20`; SELL: `(EMA20[M1] - close[M1,1]) <= ATR(M1,14) * 1.20`. ATR fail-open: if ATR unavailable, guard does not fire. Failure reason embeds distance/ATR ratio: `"EMA aligned BUY but late: dist>ATR*1.20 ratio=<value>"`. Multiplier 1.20 matches sibling `DetectTrendPullbackContinuationTrigger()` (council_strategies.mqh L1136/L1158). File changed: `strategy_runtime.mqh` only — 3 edits to `DetectEMATrendAlignmentTrigger()`: (1) inserted ATR retrieval + notLateBuy/notLateSell guard variables after L664; (2) added `&& notLateBuy` to BUY condition at L680; (3) added `&& notLateSell` to SELL condition at L689; (4) replaced terminal reason with guard-aware branched reason including ratio. DSN/CRR/TPC/zone classifier/V1/P4/DQ/stop geometry/order execution/aggregator/pre-AI filter/governor/runtime JSON: NOT CHANGED. Backup: `D:\MT5_Project_Backups\pre_change_20260505_153343_tm_entry_guard_v1.zip` (43.97 MB). Compile log: `compile_tm_entry_guard_v1_20260505_153905.log` — **0 errors / 0 warnings**; `main_ea.ex5` timestamp advanced from 2026-05-05 03:18:45 → 2026-05-05 15:43:22. Runtime validation: monitor `council_report.txt` short_reason for trend_momentum entries. Passing bars show `"EMA trend aligned bullish/bearish"`; filtered bars show `"EMA aligned BUY/SELL but late: dist>ATR*1.20 ratio=X.XX"`. Success criteria: LATE_CONTINUATION_FAILURE share of closed trend_momentum losses decreases; win rate moves toward ≥40% over next 30–50 executions. Rollback: revert 3 edits to `DetectEMATrendAlignmentTrigger()`, recompile → 0 errors, reload EA (~3 min).

- **TPC_V2B_FAILURE_LOCATION_DIAG_V1 — IMPLEMENTED + COMPILE_VERIFIED (2026-05-05):** Diagnostic-only. Zero behavioral change. Zero trading logic change. Added `DetectTrendPullbackContinuationTriggerDiag(string eraLabel)` to `council_strategies.mqh` after line 1176. Function is identical in condition logic and return values (valid/dir/quality) to base `DetectTrendPullbackContinuationTrigger()`. Only difference: `tr.reason` string is specific to failure location in V2B path instead of generic. Dispatch: ternary at line 1299 routes V2B path (`zone=RANGE_MEAN_RECLAIM && eraIsTrendV1=true`) to diagnostic function; all other paths (TC zone, non-V2B) call unchanged base function. eraLabel included in reason string for observation context (not used in any condition). Failure classifications emitted: `"No trigger [V2B era=X]: direction check failed"` / `"No trigger [V2B era=X]: pullback candle failed"` / `"No trigger [V2B era=X]: confirm candle failed"` / `"No trigger [V2B era=X]: not_late check failed"` / `"Trend pullback -> continuation (SELL/BUY) [V2B era=X]"` (trigger fired). Base function `DetectTrendPullbackContinuationTrigger()` lines 1106–1176: unchanged. DSN/CRR/ClassifyCouncilZone/V1/P4/DQ/Stop Geometry/Level Brake/SL/TP/risk/order execution/plan JSON/runtime JSON: unchanged. Backup: `D:\MT5_Project_Backups\pre_change_20260505_030753_tpc_v2b_failure_location_diag_v1.zip` (17.74 MB). Compile: `compile_tpc_v2b_failure_location_diag_v1_<ts>.log` — **0 errors / 0 warnings**. Observation target: monitor `short_reason` for `trend_pullback_cont_v1` in council_report.txt on first TREND_UP/TREND_DOWN + RANGE_MEAN_RECLAIM bars after reload. 10–20 V2B-context bars sufficient for classification. Classification outcome determines next repair step: direction-check-failed → proceed with era-aware trigger repair; geometry-failed → evaluate geometry calibration vs. accept as correct behavior; mixed → report distribution.

- **EDGE THROUGHPUT REPAIR V2B — TREND_PULLBACK_CONFIRM_BRIDGE IMPLEMENTED + COMPILE_VERIFIED (2026-05-04 18:36:13):** V2B corrects the TARGET_CONTEXT_MISMATCH from V2A by routing `gRegime.regime_label` (V1 ERA truth) into `CouncilEnvironmentReport.era_label_v1` and using it as the zone-gate condition in `trend_pullback_cont_v1`. Three files changed: (1) `council_mode_types.mqh` — `string era_label_v1;` field added to `CouncilEnvironmentReport` struct after `reject_reason`, initialized to `""` in `InitCouncilEnvironmentReport()`; (2) `council_mode_runtime.mqh:349` — `env.era_label_v1 = gRegime.regime_label;` inserted after `BuildCouncilEnvironmentReport()` success and BEFORE `runtime.env = env;` — same file already owns `gRegime` access at line 356 (no new hidden dependency); (3) `council_strategies.mqh:1193` — hard TC-only gate replaced with V2B bridge: `zoneAllowed = TC OR (RMR AND eraIsTrendV1)` where `eraIsTrendV1 = (era_label_v1 == "TREND_UP" || era_label_v1 == "TREND_DOWN")`. No function signature changes. `BuildCouncilEnvironmentReport()` unchanged. `CouncilAssignStrategyMeta` unchanged (already assigns ACTIVE eligibility for CONFIRM+RMR). `blocked_by_zone` check at line ~1210 unchanged — passes cleanly for CONFIRM+RMR. `DetectTrendPullbackContinuationTrigger()` unchanged. DSN/CRR/ClassifyCouncilZone/authority/DQ/score/SL/TP/stop-geometry/order-execution unchanged. Backup: `D:\MT5_Project_Backups\pre_change_20260504_182624_edge_repair_v2b.zip` (16.97 MB). Compile log: `compile_edge_repair_v2b_20260504_183138.log` — 0 errors / 0 warnings / `main_ea.ex5` timestamp advanced to 2026-05-04 18:36:13. Closure: **V2B_COMPILE_VERIFIED_EFFECT_PENDING**. Runtime effect observable only when a live DECISION occurs with `choke_v1_era_label=TREND_UP or TREND_DOWN` AND `choke_v1_zone=RANGE_MEAN_RECLAIM`. Do not claim `V2B_EFFECT_CONFIRMED` until `choke_v1_confirm_role_present=true` and `choke_v1_structural_gate=PASSED_STRUCTURAL` are observed in that context. `choke_v1_tpc_confirm_fired` remains non-authoritative (CouncilRuntimeResult carries no strategy array). Component 3 (Quality guard): DEFERRED — observe 5-session post-V2B sample. **SESSION_E_LIVE_INVESTIGATION COMPLETE (2026-05-05): V2B_GATE_WORKING_TRIGGER_NOT_MET.** Target decisions XAUUSD-1777920555-100067-17 (18:49:15 UTC) and XAUUSD-1777920889-100072-18 (18:54:49 UTC) confirmed as V2B target-context bars (era_label_v1=TREND_DOWN, zone=RANGE_MEAN_RECLAIM, zone_confidence=0.38, choke_v1_tpc_blocked_reason=STRATEGY_REPORTS_NOT_IN_AGGREGATE). Both records absent from council_feedback.json — root cause: council_feedback.json uses periodic sampling (~every 11 global decisions), NOT per-decision writes; these two bars fell between sampling intervals. Per-strategy analysis via council_report.txt format + adjacent records: (1) V2B zone gate CONFIRMED WORKING — TPC explanation field in council_report.txt carries era_v1 value; for era=RANGE_BALANCED → short_reason="Non-trend zone" (gate blocks); for era=TREND_DOWN → gate passes (zoneAllowed=true). (2) TPC trigger NOT FIRED on both target bars — proof: diversity=0.387 = 1 family = log(2)/log(6); TPC family=TREND_PULLBACK_CONTINUATION is distinct from TREND_CONTINUATION; if TPC triggered → 2 families → diversity=0.613; observed 0.387 → TPC was in WAIT. (3) CRR root cause classification: CONFIRM_LAYER_TRIGGER_ABSENT_IN_TRENDING_BARS. Role inventory in RMR zone: bollinger_reclaim (CONFIRM, ACTIVE, zone_align=1.00) — "No Bollinger reclaim" trigger; mean_reversion_bounce (CONFIRM, ACTIVE, zone_align=1.00) — trigger absent; range_edge_fade (CONFIRM, ACTIVE, zone_align=1.00) — trigger absent; trend_pullback_cont_v1 (CONFIRM, REDUCED, zone_align=0.95) — V2B gate passes, trigger absent; 5× TREND_CONTINUATION CONFIRM strategies (momentum_breakout, micro_reentry, breakdown_momentum, lower_high_rejection, volatility_squeeze) — hard-gated or inactive outside TC/compression zone. All 9 CONFIRM-role strategies: WAIT. (4) Single voting family source: TREND_CONTINUATION (trend_momentum, role=TREND_JUDGE, eligibility=OBSERVE_ONLY, 0.15× weight). OBSERVE_ONLY does NOT satisfy confirm_role_present; TREND_JUDGE role ≠ CONFIRM role. (5) Systematic pattern confirmed: records 100031-7, 100065-16, 100067-17, 100072-18 all TREND_BEAR+RMR(conf=0.38) → all CRR. Exception: record 100042-10 (BUY, HIGH_CONVICTION, diversity=0.61, confirm=true) — HIGH_CONVICTION bypasses CRR gate. (6) V2C classification: V2C_DIAGNOSTIC_ONLY_JUSTIFIED — bottleneck is trigger conditions, not zone gate. V2C scope if pursued: TPC trigger sensitivity in TREND_ERA_RANGE_EXRA — examine whether TPC's pullback entry conditions should fire on the bar where price>EMA20 (which defines RMR and IS the pullback state). Do not lower CRR gate. Do not reclassify trend_momentum to CONFIRM. (7) Observation window: OPEN. PASSED_STRUCTURAL not yet reached. Closure condition unchanged: choke_v1_confirm_role_present=true AND structural_gate=PASSED_STRUCTURAL in TREND_ERA context required.

- **V2B STRATEGY TESTER DIAGNOSTIC — ABANDONED_UNDER_CURRENT_ARCHITECTURE (2026-05-04):** Strategy Tester diagnostic path attempted and classified `BLOCKED_BY_TESTER_GOVERNANCE_SETUP`. Root cause: MT5 Strategy Tester agent uses an isolated file system; pre-placed files in on-disk sandbox (`Agent-127.0.0.1-3000\MQL5\Files\AI\`) are NOT accessible to the EA via `FileIsExist`/`FileOpen`. Evidence: `PJ_EnsureJournalBootstrap` reported `empty_valid_surface_created` during the test run yet no `ai_performance_journal.jsonl` appeared in the on-disk sandbox post-run — confirming writes go to an ephemeral isolated FS, not the observable directory. EA loaded compiled default plan_v001 (HYBRID mode), reached `TRUTH_NOT_READY / active_plan_missing` on every bar, and produced ZERO DECISION records. V2B bridge code (COUNCIL mode, `council_strategies.mqh:1193`) was never reached. `DateRange=0` defect in tester config also caused wrong date window (2025.11.01–2025.12.01 with empty history instead of Jan 2025). Classification: NOT a V2B failure, NOT an EA failure, NOT an edge failure — governed runtime truth-surface requirement is architecturally incompatible with the current tester file isolation model without source changes or governance bypass (both forbidden). Tester artifacts deleted: `tester_v2b_diag.ini`, `tester_smoke.ini`, sandbox copies of `ai_current_plan.json` and `ai_evolution_state.json`. System-generated tester log `tester\logs\20260504.log` (69508 bytes) left as forensic reference. **V2B remains IMPLEMENTED + COMPILE_VERIFIED + LIVE_EFFECT_PENDING.** Validation path: `LIVE_ONLY` — observing live DECISION records for `choke_v1_era_label ∈ {TREND_UP, TREND_DOWN}` AND `choke_v1_zone=RANGE_MEAN_RECLAIM` AND `choke_v1_confirm_role_present=true`. Future tester harness (EA self-seeding plan from compiled defaults on first tick, or separate governance path) is an out-of-scope project decision.

- **EDGE THROUGHPUT REPAIR V2A — COMPONENT 2 IMPLEMENTED + COMPILE_VERIFIED (2026-05-04 16:51:42):** Component 1 (TREND_PULLBACK_CONFIRM_BRIDGE): BLOCKED — MANDATORY_TARGETING_VALIDATION outcome = TARGET_CONTEXT_MISMATCH. env.regime_summary (MarketRegimeSnapshot) and gRegime.regime_label (V1 ERA) are different classifiers; during actual pullbacks MRS returns "RANGE" (price > ema20) while V1 labels TREND_DOWN (EMA stacking only). Bridge checking TREND_BULL/BEAR in env.regime_summary would not fire on the primary TREND_ERA_RANGE_EXRA scenario. Alternative for follow-up: add era_label_v1 field to CouncilEnvironmentReport populated from gRegime.regime_label before BuildCouncilStrategies() — separate scope decision required. Component 2 (CHOKE_ATTRIBUTION_V1): 9 diagnostic fields (choke_v1_structural_gate, choke_v1_gate_detail, choke_v1_dominant_side_raw, choke_v1_confirm_role_present, choke_v1_family_diversity_score, choke_v1_era_label, choke_v1_zone, choke_v1_tpc_confirm_fired, choke_v1_tpc_blocked_reason) appended to every DECISION record. PJ_SetChokeAttributionV1() called before all 6 JournalAppendDecisionV3 sites — no stale state. Era label = gRegime.regime_label (per-decision, not cached). tpc_confirm_fired=false / tpc_blocked_reason="STRATEGY_REPORTS_NOT_IN_AGGREGATE" at all sites (CouncilRuntimeResult carries no strategy report array). Sentinel "UPSTREAM_BLOCK" used at regime-filter-block site (dummyRouted). Append-only schema change — no existing field renamed or reordered. Component 3 (Quality guard): DEFERRED — observe 5-session post-bridge sample. No authority/gate/zone-classifier/DQ/score/SL/TP/stop-geometry/order changes. Runtime confirmation pending.

- **THREE-POINT POST-SESSION STABILIZATION PACKAGE — IMPLEMENTED + COMPILE_VERIFIED (2026-05-04 15:03:46):** Applied diagnostic/analytics corrections following 2026-05-04 session post-mortem (3 trades: 2W/1L, 87 DECISION records, 94% reject rate, CC V1 clean 8-hour runtime). Point 1 — Timeframe/Instance Clarification (REPORT_ONLY): Terminal log confirmed active binary loaded on (XAUUSD,M1) at 04:53:52 and removed from (XAUUSD,M5) at 12:52:35 — analysis concludes the M5 removal is cleanup of the old crashed-binary chart instance (crashed at 02:58:33 on M5), NOT a duplicate concurrent execution. Active trading instance during Crash Containment V1 session was M1-chart only. DUPLICATE_INSTANCE_RISK: LOW (no second-instance load event after 04:53). EA is functionally chart-TF-agnostic (OnTick hardcodes PERIOD_M1+PERIOD_M5 regardless of chart); tf="M1" journal field is intentionally hardcoded. Operator action: before next session, confirm only one main_ea instance attached; prefer M1 chart for TF consistency. No source change for Point 1. Point 2 — Journal Coverage Patch: `best_strategy` field was missing from all DECISION records despite value existing at call site. Added `string best_strategy_id = ""` as optional parameter to `PJ_BuildDecisionJsonV3` (after `regime_perf_summary`) and `JournalAppendDecisionV3` (after `&logMessage`, before default-taking callers). JSON field `"best_strategy"` now written in DECISION records via `PJ_PJ_EscapeJsonMini`. Primary call site `main_ea.mq5:5205` passes `routed.council.aggregate.best_strategy_id`; 5 other call sites use default `""`. Verified: `initial_stop_distance_points`, `m5_atr14_at_entry_points`, `sl_vs_m5_atr_ratio` already present in TRADE_OPEN records (EQ-DIAG-V1 confirmed); `exit_reason` already written as `exit_reason_summary` in TRADE records; quality scores (0.0) are intentional No-Score V1 behavior. No decision gates, no score authority, no behavior change. Files: `performance_journal.mqh`, `main_ea.mq5`. Point 3 — bollinger_reclaim Family Mapping: `ILV1_InferStrategyFamily()` in `institutional_learning_layer_v1.mqh:231` was returning UNKNOWN for `bollinger_reclaim` because pattern-match checked "mean" but not "reclaim". Canonical family MEAN_RECLAIM confirmed in `council_strategies.mqh:898`. Impact was DIAGNOSTIC_ONLY — execution authority, V1 routing (council_strategies.mqh), DSN, CRR, and order execution unaffected (both winning trades executed correctly as MEAN_RECLAIM). Fix: added exact-match `if(strategy_id == "bollinger_reclaim") return "MEAN_RECLAIM";` as first check in `ILV1_InferStrategyFamily`. Now decision_context JSONL records and learning attribution correctly show MEAN_RECLAIM for bollinger_reclaim. No authority, No-Score, SL/TP, risk, order execution, P4/V1/DQ, Level Brake, pre-AI gates, Stop Geometry, dashboard/ATAS, plan/runtime JSON changes. MQL5 signature constraint resolved: default optional param must come after mandatory by-reference params. Governed backup: `D:\MT5_Project_Backups\pre_change_20260504_143746_three_point_stabilization_package.zip` (11.58 MB). Compile log: `compile_three_point_stabilization_package_20260504_145848.log` — 0 errors / 0 warnings / `main_ea.ex5` timestamp advanced to 2026-05-04 15:03:46. Runtime confirmation pending: after next reload, verify `best_strategy` present in DECISION records and bollinger_reclaim shows family=MEAN_RECLAIM in decision_context.

- **LIVE RUNTIME VALIDATION — PARTIAL_PASS_CRITICAL_INCIDENT (2026-05-04):** Binary `main_ea.ex5` 2026-05-03 01:12:05 / 2,564,226 bytes / 0 errors / 0 warnings is the current active binary. Observation window: 2026-05-04 01:39–02:58 local. Runtime continuity CONFIRMED: `state=COHORT_GOVERNED_ACTIVE` at 01:35:25; first fresh post-binary DECISION `XAUUSD-1777858754-100040-2` at ts=`2026.05.04 01:39:14`; plan_fingerprint=plan_v076|D82B5640; active_mode=COUNCIL; authority_stack_enabled_layers=P4,V1; authority_dq_would_block=false; pre_ai_score_gates_demoted=true; v1_score_quarantine_dq_role=DISABLED; v1_policy_constructive_active=true; v1_fsw_enabled=true; v1_fsw_phase2_active=true. Hard-Lock regression PASS: dormant strings (regime_policy, dq_policy, strategy_intelligence, continuation_reinforcement, dirty_env_block) absent from final_decision_reason/policy_result/council_summary. **Observability Trio RUNTIME_CONFIRMED** (supersedes RUNTIME_PENDING status): level_brake_fired=false/level_brake_reason_code=NONE, structural_reject_gate=DIVERSITY_SAFETY_NET/pre_ai_structural_passed=false, governor_categorical_state_active=true/governor_state_source=STAGE_D_CATEGORICAL_GOVERNOR all present in first DECISION. SRVIZ_STATUS at M5 bar cadence (FINAL_RUNTIME_RELIED_ON / FINAL_SOURCE=COUNCIL_ENV_LEVEL_BRAKE_CONTEXT) — normal, not spam. **Stop Geometry V1 Option B — EFFECT_OBSERVED** (supersedes RUNTIME_PENDING): TRADE_OPEN XAUUSD-1777860759-100073-10 (BUY 02:14:48): initial_stop_distance_points=440.0, m5_atr14_at_entry_points=629.07, sl_vs_m5_atr_ratio=0.6994≈0.70 — M5 floor (629.07×0.70=440.35) is the binding constraint, confirming Option B geometry live. **EQ-DIAG-V1 RUNTIME_CONFIRMED** (supersedes RUNTIME_PENDING): open-side all fields populated (initial_stop_distance_points=440.0, m5_atr14=629.07, sl_vs_m5_atr_ratio=0.6994, level_context_at_entry=LEVEL_CONTEXT_DEGRADED, entry_geometry_warning=LEVEL_CONTEXT_DEGRADED, expected_rr_estimate=1.684, execution_geometry_score=0.744); close-side MFE=347.0 pts, MAE=189.0 pts, excursion_source=DIRECT_TICK_DERIVED (best quality). **Edge Repair V1 RANGE_ERA_TREND_EXRA — NOT_OBSERVED_YET** (market-conditional, compile-verified, observation window remains open). Trade: BUY 4615.09, SL 4610.69, WIN profit=1.3 USD, trailed SL hit 4615.22 (break-even+), exit_reason=closed_by_sl, MFE 347 pts, MAE 189 pts; ILV1 attributed SUCCESS_MOTIF_CONFIRMED. **CRITICAL — Abnormal termination at 02:58:33.020 (RI level=2):** Last log entry; EA terminated abnormally ~11 minutes after WIN trade feedback (deal=8048870447) was processed and ~2 minutes after final regime evaluation (REVERSAL_RISK). Sequence: 02:47:19 ILV1 SUCCESS_MOTIF_CONFIRMED → 02:47:19 journal appended → 02:51:03 feedback saved WIN → 02:54:23 council closed trade recorded → 02:56:40 regime REVERSAL_RISK → **02:58:33.020 Abnormal termination (RI 2)**. EA was NOT in active trade at time of crash. Whether EA auto-restarted is UNCONFIRMED. Cause unknown; investigation required before next trading session. No source modification, no compile, no parameter change pending investigation.

- **CRASH CONTAINMENT V1 — DASHBOARD DISABLED-CLEANUP ONE-SHOT — IMPLEMENTED + COMPILE_VERIFIED (2026-05-04 04:45:31):** Applied bounded runtime-safety containment after 2026-05-04 RI level=2 abnormal termination. Changed disabled-dashboard OnTimer path so DashboardRemoveAllRendering() runs once per EA load instead of every second when EnableInternalDashboardChartUI=false. No authority, trading logic, Stop Geometry, Edge Repair, EQ-DIAG, P4/V1/DQ, Level Brake, pre-AI, aggregation, strategy, risk, order execution, dashboard internals, ATAS internals, plan/runtime JSON, or journal schema changed. Compile log `compile_crash_containment_v1_dashboard_cleanup_20260504_044104.log`: 0 errors / 0 warnings; `main_ea.ex5` timestamp advanced to 2026-05-04 04:45:31. Runtime confirmation pending through next 90+ minute live session. Root cause is not claimed fixed until runtime proves no recurrence.

- **NO-SCORE DORMANT RISK HARD-LOCK PACKAGE - RUNTIME_SMOKE_CONFIRMED ADDENDUM (2026-04-30 14:20:47):** Supersedes the earlier runtime-pending note for the 2026-04-30 12:11:06 Hard-Lock binary. Fresh strict-parsed DECISION proof inspected before Observability Trio edits: `decision_id=XAUUSD-1777558847-100741-3`, `ts=2026.04.30 14:20:47`, `symbol=XAUUSD`, `final_decision=REJECT`, `policy_result=WAIT`, `authority_stack_status=NOT_EVALUATED`; `active_mode=COUNCIL`, `authority_stack_enabled_layers=P4,V1`, `authority_dq_would_block=false`, `authority_stack_primary_layer=NONE`, `authority_stack_blocking_authority=NONE`, `v1_policy_constructive_active=true`, `v1_fsw_enabled=true`, `v1_fsw_phase2_active=true`, `pre_ai_score_gates_demoted=true`, `v1_score_quarantine_dq_role=DISABLED`, `p4_dirty_env_legacy_gate_enabled=false`; no dormant hard-lock strings (`regime_policy`, `dq_policy`, `strategy_intelligence`, `continuation_reinforcement`, `dirty_env_block`) appeared in `final_decision_reason`, `policy_result`, or `council_summary`. HARD_LOCK_PACKAGE is runtime-smoke-confirmed.

- **OBSERVABILITY TRIO PACKAGE - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED (2026-04-30 15:17:02 / confirmed 2026-05-04):** Observability-only V1 starvation diagnostics implemented without authority change. DECISION serialization now carries Level Brake diagnostic fields, structural pre-AI rejection annotation fields, environment hard-condition rejection annotation, and Stage D categorical governor state fields. Level Brake blocking logic, structural pre-AI gate order/thresholds, `env.tradable` / `hardConditions`, P4/V1 authority, Package 1 no-score aggregation, Package 2 DQ cleanup, and DQ diagnostic-only posture are unchanged. Governor remains non-authoritative; no score authority restored. Compile log `compile_observability_trio_v1_20260430_150801.log`: 0 errors / 2 unchanged known warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-04-30 15:17:02. **Runtime confirmed 2026-05-04:** All three pillars present in first fresh post-binary DECISION (`XAUUSD-1777858754-100040-2`, ts=01:39:14): level_brake_fired=false/level_brake_reason_code=NONE ✓; structural_reject_gate=DIVERSITY_SAFETY_NET/pre_ai_structural_passed=false ✓; governor_categorical_state_active=true/governor_state_source=STAGE_D_CATEGORICAL_GOVERNOR ✓. See Live Runtime Validation anchor entry.

- **DCSDG-V1 DASHBOARD COLLECTOR SOFT-DISABLE GUARD - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING (2026-04-30 17:20:08):** Operational containment patch before the 250/500 validation window. `main_ea.mq5` adds `EnableDashboardRuntimeCollector=false` by default and gates `DashboardProcessPendingActions()` in the disabled-chart `OnTimer()` branch so dashboard collector/page-build remains dormant when `EnableInternalDashboardChartUI=false` unless explicitly enabled. `RefreshAtasRuntimeStatusHeartbeatBestEffort()` remains unconditional; `DashboardPhase1OnTimer()` behavior when chart UI is enabled is unchanged; `DashboardRemoveAllRendering()` still runs while chart UI is disabled. This does not reopen No-Score architecture and does not change trading authority, P4/V1/DQ, Level Brake, pre-AI gates, risk, execution, ATAS heartbeat, or journal truth. Existing dashboard collector/page-build behavior is recoverable without source rollback by setting `EnableDashboardRuntimeCollector=true` or by enabling chart UI. Future EXE/RAM/dashboard migration is separate and not implemented; crash investigation remains separate and still required if abnormal terminations recur. Compile log `compile_dcsdg_v1_20260430_171147.log`: 0 errors / 2 unchanged known warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-04-30 17:20:08. Runtime smoke remains pending because latest inspected DECISION `XAUUSD-1777563474-100045-2` at `2026.04.30 15:37:54` predates the DCSDG binary.

- **INPUT DEFAULT ALIGNMENT PATCH - IMPLEMENTED + COMPILE_VERIFIED (2026-04-30 17:48:10):** `main_ea.mq5` input defaults aligned for the current validation runtime. Dashboard chart UI default remains `false`; dashboard runtime collector default remains `false`; V1 constructive eligibility and V1-FSW participation/influence inputs now default `true`; DQ authority default remains `false` where present; dirty environment tightening default remains `false` where present. No `AuthorityStack_Enable` or `EnableCouncilTrendContinuationConfirmationReinforcement` input declaration exists, so no input was invented. No trading logic, authority logic, risk, execution, journal truth, dashboard internals, or No-Score architecture changed; backup-to-current diff shows only three input-default lines changed. Compile log `compile_input_defaults_alignment_20260430_173916.log`: 0 errors / 2 unchanged known warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-04-30 17:48:10. Runtime reload or applying compiled defaults in MT5 inputs is still required because saved chart input values may override source defaults. Latest inspected DECISION `XAUUSD-1777563474-100045-2` at `2026.04.30 15:37:54` predates this binary, so no runtime confirmation is claimed.

- **AI RUNTIME QUIET / VALIDATION DEFAULT PATCH - IMPLEMENTED + COMPILE_VERIFIED (2026-04-30 20:58:01):** `main_ea.mq5` AI validation defaults aligned to off/non-authoritative mode for the validation window: `EnableAIEvolution=false`, `AIGateSecurityClearanceForShadow=false`, and `EnableAICouncilContextualAdvisory=false`; existing candidate block and advisory security clearance defaults remain false. H6 AI evolution/readiness/log path now uses `aiH6RuntimeEnabled` so the H6 performance snapshot, AI readiness checks, and repeated `AI authority gate blocked AI activity` log path remain dormant when AI validation/evolution paths are disabled. No AI authority enabled; no P4/V1/DQ/Level Brake/pre-AI/aggregation/risk/execution logic changed; DCSDG-V1 and input-default alignment preserved. Feedback-coupling verification from source confirmed `EnableAIEvolution=false` does not gate `EnableTradeFeedbackLogging`, `SaveLatestClosedTradeFeedbackEx`, `ClosedDealTrace`, `JournalAppendTrade`, `JournalAppendTradeOpen`, institutional learning outcome capture, or `AI\ai_trade_feedback.json` writer reachability. Latest ~20 DECISION records and recent trade/feedback artifacts were inspected before the patch; SL sizing was not changed and remains pending design review. Compile log `compile_ai_runtime_quiet_defaults_20260430_205201.log`: 0 errors / 2 unchanged warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-04-30 20:58:01. Runtime reload or applying compiled defaults in MT5 inputs is still required because saved chart input values may override source defaults; no post-compile DECISION was available at update time, so runtime confirmation is not claimed.

- **POST-AI-QUIET VALIDATION SAMPLE CLOSURE AUDIT — VALIDATION_SAMPLE_ACCEPTABLE_WITH_RESIDUALS (2026-05-01):** Current accepted closure sample inspected after AI Runtime Quiet / Validation Defaults Patch and DCSDG-V1. Sample size: 170 DECISION records, 7 trade opens, 7 closes. First record: XAUUSD-1777583764-100023-2 (2026-04-30 21:16:04); latest record: XAUUSD-1777655940-101106-245 (2026-05-01 17:19:00). Binary: 2026-04-30 20:58:01. plan_fingerprint=plan_v076|D82B5640 stable across all 170. No-Score chain A1/A2/A3-Revised/Package1/Package2/StageD preserved: pre_ai_score_gates_demoted=true, v1_score_quarantine_dq_role=DISABLED across all records; no score values in final_decision_reason, policy_result, or council_summary. Hard-Lock preserved: dormant strings (regime_policy, dq_policy, strategy_intelligence, continuation_reinforcement, dirty_env_block) absent from final_decision_reason, policy_result, council_summary in all 170 records. Observability Trio fields present: Level Brake diagnostic fields, structural pre-AI gate annotation, and Stage D categorical governor state fields confirmed present. DQ remains disabled: authority_dq_would_block=false, v1_score_quarantine_dq_role=DISABLED. Authority stack layers confirmed P4,V1. AI disabled-path quiet status: CONFIRMED — 0 AI authority gate or evolution messages in 20260501.log; ClosedDealTrace firing confirmed independent of AI flags. Dashboard containment: CONFIRMED — DCSDG-V1 effective; 0 collector/page-build activity observed; ATAS heartbeat (rate-limited 5s) unaffected. P4 behavior: 6 blocks (3.5% of 170), all protective: REVERSAL_RISK_LOW_TRADABILITY ×4, RANGE_DIRTY_DEGRADED_RISK ×2; all during ERA_EXRA_AGREE_DEGRADED divergence state. Level Brake behavior: 6 fires (3.5%), all continuation_entry_blocked_by_near_opposing_level, obstacle classes SEVERE/HARD/MODERATE; all legitimate SR-obstruction blocks. Trade behavior: 7 trades executed, 3 WIN (TP), 4 LOSS (SL), net +27.20; all 7 LEVEL_CONTEXT_DEGRADED (no canonical SR anchor at entry); SL distances 1.29–2.58 pts on XAUUSD (non-resilient to intra-bar volatility); 2 losses closed under 60 seconds. Crash status: 0 main_ea crashes post-binary in 20260430.log (20:58–23:59) or 20260501.log; 6 April 30 pre-binary crashes confirmed not attributable to current binary. Residuals: (1) SL geometry review needed — all 7 executed trades LEVEL_CONTEXT_DEGRADED, SL sizing too tight for XAUUSD intra-bar volatility regime; (2) V1 UNDEFINED_STATE — RANGE ERA + TREND_CONTINUATION ExRA combination absent from V1 policy matrix → OBSERVE_ONLY posture → V1 blocks; 4 occurrences in sample (2 post-binary); (3) single symbol/session diversity limit — observation window is XAUUSD M5 only. No production-ready claim. Next phase: STOP GEOMETRY INTELLIGENCE REVIEW + V1 UNDEFINED_STATE gap investigation + continued multi-symbol/session observation.

- **EQ-DIAG-V1 — IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED (2026-05-02 22:54:34 / confirmed 2026-05-04):** Diagnostic-only edge-quality evidence package implemented. `trade_feedback.mqh` now attempts closed-trade MAE/MFE capture from `CopyTicksRange()` over the trade lifetime first (`DIRECT_TICK_DERIVED`), then `CopyRates(PERIOD_M1)` high/low fallback (`BAR_M1_DERIVED`), otherwise preserves `0.0` excursions with `UNAVAILABLE_NOT_CAPTURED`; no entry/exit/SL/TP-only inference is used. `performance_journal.mqh` now adds TRADE_OPEN-only diagnostics: `initial_stop_distance_points`, `m5_atr14_at_entry_points`, `sl_vs_m5_atr_ratio`, `level_context_at_entry`, level-context boolean flags, and `entry_geometry_warning`. No SL/TP construction change, no ATR timeframe switch for stop placement, no TradeATRMultiplier/TradeATRPeriod/TradeRR/ExtraStopBufferPoints change, no authority/P4/V1/DQ/Level Brake/pre-AI/aggregation/risk/execution/order/dashboard/ATAS/plan/runtime JSON change. Compile log `compile_eq_diag_v1_20260502_225020.log`: 0 errors / 2 unchanged known warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-05-02 22:54:34. **Runtime confirmed 2026-05-04 (trade XAUUSD-1777860759-100073-10):** Open-side: initial_stop_distance_points=440.0, m5_atr14_at_entry_points=629.07, sl_vs_m5_atr_ratio=0.6994, level_context_at_entry=LEVEL_CONTEXT_DEGRADED, level_context_degraded_at_entry=true, entry_geometry_warning=LEVEL_CONTEXT_DEGRADED, expected_rr_estimate=1.684, execution_geometry_score=0.744 ✓. Close-side: max_favorable_excursion_points=347.0, max_adverse_excursion_points=189.0, excursion_source=DIRECT_TICK_DERIVED (best quality tier) ✓. Both sides confirmed. See Live Runtime Validation anchor entry.

- **STOP GEOMETRY V1 — OPTION B HYBRID M1/M5 ATR FLOOR — IMPLEMENTED + COMPILE_VERIFIED + EFFECT_OBSERVED (2026-05-02 23:56:01 / effect confirmed 2026-05-04):** Added `TradeM5AtrFloorFraction=0.70` and an optional completed-bar M5 ATR floor into `BuildBuyTradeLevels()` / `BuildSellTradeLevels()`. `finalStopDistance` now uses `max(brokerMinDistance, M1_ATR * TradeATRMultiplier, M5_ATR * TradeM5AtrFloorFraction)` when the M5 floor is available and positive; `TradeM5AtrFloorFraction <= 0.0` is a runtime rollback switch that leaves the M5 floor at `0.0` and preserves the M1 ATR / broker-min path. M5 ATR read failure is non-fatal. No authority change. No P4/V1/DQ/Level Brake/pre-AI/aggregation/risk/strategy/order-execution/journal-schema/dashboard/ATAS/plan/runtime JSON change. `TradeATRMultiplier`, `TradeRR`, and `ExtraStopBufferPoints` unchanged. This is a protection-geometry change that can increase fixed-lot dollar risk when the M5 floor is binding. EQ-DIAG-V1 is the validation surface for `sl_vs_m5_atr_ratio` and MAE/MFE. Compile log `compile_stop_geometry_v1_option_b_20260502_235138.log`: 0 errors / 2 unchanged warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-05-02 23:56:01. **Effect confirmed 2026-05-04 (trade XAUUSD-1777860759-100073-10):** sl_vs_m5_atr_ratio=0.6994 ≈ 0.70 confirms M5 floor (629.07 × 0.70 = 440.35 pts) was the binding constraint for this trade's 440 pt stop. M5 floor operative and live.

- **EDGE REPAIR V1 — RANGE_ERA_TREND_EXRA VOCABULARY FILL — IMPLEMENTED + COMPILE_VERIFIED + NOT_OBSERVED_YET (2026-05-03 00:49:24 / observation window open):** Added bounded categorical V1 state for RANGE ERA + TREND/EXPANSION ExRA mismatch. New state `RANGE_ERA_TREND_EXRA` uses `STAGED` posture to avoid `UNDEFINED_STATE` / `OBSERVE_ONLY` blanket while preserving structural gates, P4, V1 authority boundaries, DQ disabled state, Level Brake, Stop Geometry V1, pre-AI gates, and No-Score doctrine. Policy mapping allows `MEAN_RECLAIM`, conditionally stages `TREND_CONTINUATION,LIQUIDITY_REVERSAL`, and deprioritizes `COMPRESSION_BREAKOUT`; specialist role map keeps `TREND_CONTINUATION` conditional rather than native/FULL. This is a low-impact V1 policy-mapping behavior change, not a score or authority-boundary change. Compile log `compile_edge_repair_v1_range_era_trend_exra_20260503_004500.log`: 0 errors / 2 unchanged warning 94 entries; `main_ea.ex5` timestamp advanced to 2026-05-03 00:49:24. Continuity confirmed 2026-05-04 (runtime live, 8+ decisions recorded post-binary). RANGE ERA + TREND/EXPANSION ExRA condition did not occur in 2026-05-04 observation window — market-conditional, not a failure. Observation window remains open.

- **WARNING-94 CLEANUP - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED (2026-05-03 01:12:05 / runtime confirmed 2026-05-04):** Removed the two remaining known compile warning-94 implicit conversions in `main_ea.mq5` by replacing the Level Brake SCM observer direction checks with explicit string comparisons against `"BUY"`. No authority, trading logic, Stop Geometry, Edge Repair, P4/V1/DQ, Level Brake, pre-AI, aggregation, risk, order execution, dashboard, ATAS, plan/runtime JSON, or journal schema changes. Compile log `compile_warning94_cleanup_20260503_010513.log`: 0 errors / 0 warnings; `main_ea.ex5` timestamp advanced to 2026-05-03 01:12:05. **Runtime confirmed 2026-05-04:** Binary loaded at EA reinit 01:26:37; state=COHORT_GOVERNED_ACTIVE at 01:35:25; full decision+trade+feedback lifecycle completed; trade executed, WIN, feedback recorded. This is the current active binary. Abnormal termination at 02:58:33 occurred with this binary — investigation required (see Live Runtime Validation anchor entry).

- **Baseline:** SVS Slice 1 + Slice 2 source-complete (2026-04-18). CEIS 7-signal layer live and operational. PIML execution-plan registry populated (PLAN-1, PLAN-2, PLAN-4, PLAN-5, PLAN-6). Protocol files (AGENTS.md, OPERATION_GUARDRAILS.md) fully updated with PIML discipline.
- **Active plans:** PLAN-1 CEIS — `ACTIVE` (observation window open) | PLAN-2 SVS — `RUNTIME_GATE_CLOSED` (2026-04-23 03:35:00) — binary 03:10 loaded at 03:19:43; brake event at 03:35:00.738: "Runtime SELL blocked by level brake | reclaim_entry_conflicts_with_rejection_zone" (oppClass=STRONG, obst=HARD_OBSTACLE, room=0.07, rej=0.86, srRes=8, srSup=8) — LAB intercepted council-passed SELL signal; SRE 8+8 zones fully populated; SRVIZ_STATUS FINAL_STATE=FINAL_RUNTIME_RELIED_ON on every post-reload bar; FINAL_SOURCE=COUNCIL_ENV_LEVEL_BRAKE_CONTEXT confirmed. Backup `pre_change_20260423_030348_plan2_svs_compile_gate.zip` (2939 files, COMPLIANT). structural_sr_engine.mqh + level_awareness_brake.mqh freeze lifts. Deferred (non-blocking): Rule A WEAK/MEDIUM non-trigger not directly observed; H4 source_tf_rank=3 not directly confirmed from log text | PLAN-4 Stage 1 — `OBSERVATION_GATE_CLOSED` (2026-04-20) | PLAN-4 Stage 2 — `COMPILE_VERIFIED + PARTIALLY_CLOSED` (unified branch compile clean 2026-04-20, EA reloaded — original C1/Stage 2A footprint doctrine reopened 2026-04-23 after forensic re-evaluation found C1 structurally shadowed as a distinct live footprint; Stage 2B **CLOSED** 2026-04-21 (arithmetic confirmed + CONFIRMED_FROM_RUNTIME: quality=0.68 matches corrected trace; no disconfirming evidence); C3 REBOUND 2026-04-21 + COMPILE_VERIFIED + OBSERVATION_OPEN pending first TC+NOISY bar) | PLAN-5 — `COMPILE_VERIFIED + FORENSIC_REEVALUATION_OPEN` (unified branch compile clean 2026-04-20, EA reloaded — 2026-04-23 forensic review found the original C1+C2 minimum-footprint gate unstable as written: C1 distinct footprint shadowed by governor ordering; C2 exact trigger non-durable in current runtime surfaces) | PLAN-6 — `STAGE0_COMPLETE + STAGE1_CLOSED + STAGE3_IMPLEMENTED` (Stage 1 closed 2026-04-21; Stage 3 IMPLEMENTED + COMPILE_VERIFIED + PARTIAL_RUNTIME_CONFIRMED 2026-04-21: COMPRESSION branch added to ClassifyCouncilZone() + COMPRESSION threshold block in filter; gRegime=COMPRESSION (REGIME_CLASSIFICATION_V1 legacy stack) confirmed in trade journal at 2026.04.21 19:14:06 (WIN SELL profit=49.2 regime_label=COMPRESSION conf=0.62). NOTE: this is NOT council_zone=COMPRESSION — regime_label is produced by RC_RegimeLabelToText() in regime_classification_layer_v1.mqh (REGIME_COMPRESSION=5), independent of ClassifyCouncilZone(). council_zone=COMPRESSION OBSERVATION_CLOSED (2026-04-23 02:45:02): full council_report.txt COMPRESSION bar captured. zone_name="COMPRESSION", zone_confidence=0.57 (formula correct: 0.42 + structure_score(1.00) × 0.15 = 0.57; plan's stated [0.42, 0.51] range was incomplete — actual max is 0.57 with structure_score=1.00), preferred_style=BREAKOUT, blocked_style=CONTINUATION, momentum_score=0.21 (<0.45 ✓), volatility_score=0.45 (<0.55 ✓). COMPRESSION-native strategy alignment CONFIRMED: range_compression_breakout zone_alignment_score=0.91 (COMPRESSION_BREAKOUT family, highest of 17 strategies), volatility_squeeze_release zone_alignment_score=0.93 (highest of 17). C8/C5 purpose of Stage 3 demonstrated. Pre-AI filter path confirmed: filter summary explicitly zone=COMPRESSION; max_allowed_conflict=0.28 (DEFENSIVE governor tightened COMPRESSION base 0.45 → 0.28; base not directly observable at 0.45 when DEFENSIVE active but COMPRESSION filter path confirmed active). Stage 3 FORMALLY CLOSED. Backup: `pre_change_20260421_190112_plan6_stage3.zip` [NON-COMPLIANT with full-system backup expectation: 185/2930 files = 6.3% coverage; missing external_dashboard, external_adapter, docs; adequate for Stage 3 source rollback only].)
- **Regime contradiction branch (new):** PLAN-RC — `IMPLEMENTED + COMPILE_VERIFIED + FORENSIC_ACCEPTED_WITH_OBSERVATION` (2026-04-21). Full-system cold backup verified: `pre_change_20260421_224731_regime_contradiction_full_system.zip` (2931 entries, 18,636,232 bytes). Forensic engineering review complete (2026-04-21): causally correct, 7 emission points covered (perf_journal 4 DECISION + 3 CLOSE, trade_feedback inline), backward-compatible (fallback defaults at main_ea.mq5 lines 3665–3675), edge-safe (no trade admission/scoring/governance changes). Runtime verification PENDING: last journal entry 20:44:59 precedes 23:07 compile — provenance fields not yet observed in live records. Residual architecture gap acknowledged: dual-regime (gRegime vs MarketRegimeSnapshot) still independent systems — repair labels provenance, does not consolidate. Dual-regime consolidation deferred to Stage 4+.
- **Regime architecture declaration (new):** PLAN-ARCH-DR — `STAGE_P3_3_COMPLETE + ZONE_TEXT_MAPPING_FIXED` (2026-04-22): ERA=gRegime + ExRA=council zone declared. 6 violations classified. Three-chain doctrine declared. P2.A FULLY CLOSED. P3.3 IMPLEMENTED + COMPILE_VERIFIED (2026-04-22 21:57) — dead string-search fallbacks removed from CouncilIsCompressionContext() + CouncilIsExpansionContext() in council_strategies.mqh; 0 errors / 2 pre-existing warnings; behavioral impact NONE. Zone text mapping fix IMPLEMENTED + COMPILE_VERIFIED (2026-04-22 22:17): CouncilZoneTypeToText() in council_mode_types.mqh extended with 4 missing cases (COMPRESSION, EXPANSION_CONTINUATION, RANGE_BALANCED, RANGE_DIRTY); was previously returning "UNDEFINED" for all zone values ≥6; behavioral impact on execution paths NONE (all execution-critical consumers use zone_type enum directly); observability surfaces (council_report.txt, diagnostic_runtime_summary.json, failure_detector penalty label) now emit correct text; advisory signature (atas_governed_advisory_layer.mqh:156) now receives "COMPRESSION" instead of "|UNDEFINED" for COMPRESSION zone bars (behavioral benefit when ATAS active). Stage 3 observation was observationally blocked by this gap — zone_name="UNDEFINED" was emitted for all COMPRESSION zone bars; observation criterion now unblocked (EA reload required to confirm). Backup: `pre_change_20260422_221241_zone_text_mapping_fix.zip` (2938 files, 36,903,814 bytes — COMPLIANT full-system). Next gate: P2.B (Stage 3 RESOLVED 2026-04-23; remaining blockers: PLAN-2 SVS compile gate + C1/C2/C3 footprints).
- **Deep architecture truth correction (2026-04-22):** VERIFIED_FROM_SOURCE + VERIFIED_FROM_RUNTIME. The regime/zone topic is deeper than the earlier dual-surface summary: three primary chains are active for this topic - `MarketRegimeSnapshot`, `RegimeClassificationV1`/`gRegime`, and council environment -> zone/zone_semantic - plus a derivative network spanning legacy strategy runtime, zone coverage, dirty-environment gate, strategy intelligence, learning, analytics, replay arbitration, dashboard aggregation, AI advisory identity, strategy memory, and a dormant reinforcement path. P2.A remains bounded in execution authority (no trade admission/governor/risk/authority drift found), but the prior closure claim is no longer sufficient: active DECISION/TRADE lines in `ai_performance_journal.jsonl` are malformed around the new provenance fields (double comma before provenance block and missing comma before the next field), so substring-based consumers still observe the fields while strict JSON contract integrity is broken. Replay blank provenance is additionally explained by source priority: `RefreshReplayValidationArtifactsBestEffort()` prefers the diagnostic surface, and `diagnostic_runtime_summary.json` carries zone context but no regime provenance fields.
- **Waiting gate (PLAN-2):** RESOLVED 2026-04-23 03:35. Brake event confirmed in MQL5/Logs/20260423.log at 03:35:00.738. structural_sr_engine.mqh + level_awareness_brake.mqh unfrozen. Remaining deferred items (Rule A WEAK/MEDIUM non-trigger; H4 source_tf_rank=3) are observational enhancements only — not blockers.
- **PLAN-4 Stage 1 gate: `GATE_CLOSED` (2026-04-20). Causal investigation: COMPLETE (2026-04-20).** G1 end-to-end confirmed. VOLATILITY_SPIKE_FAILURE (journal label) is visible symptom only — root causes confirmed: (1) LATE_CONTINUATION_FAILURE in TREND_CONTINUATION zone (T3, T4) — council's highest-conviction signals (env=0.96–0.98, consensus=1.00, TrendJudge=TRUE) fire at trend maturity peaks; AGGRESSIVE governor case fires at same peak (env-triggered), amplifying admission at worst timing point; (2) SR-unanchored stop failure in RANGE_MEAN_RECLAIM (T1) — no canonical level anchor; T2 won with identical zone/strategy/governor but against CANONICAL_RESISTANCE_NEAR (level_context_supported=True). Stop geometry is NOT the primary discriminator: WIN avg stop=3.09pt, LOSS avg stop=2.96pt — functionally identical across 85 matched pairs. LEVEL_CONTEXT_DEGRADED at entry: 13 LOSS / 2 WIN (87% loss rate). NARROW council type is the most available late-continuation marker (T4: diversity=0.39). Stage 2 impact on today's 4-trade session: ZERO (all consensus=1.00, conflict=0.00 — Stage 2 threshold deltas irrelevant to observed losses).
- **PLAN-4 Stage 2 — MERGE_INTO_UNIFIED_BRANCH (design gate 2026-04-20):** Stage 2 is VALID and its design is fully preserved. Design gate concluded Stage 2 should be merged into the same compile cycle as PLAN-5 corrections (C1/C2/C3) — both target `council_ai_governor.mqh` and `council_pre_ai_filter.mqh`. No Stage 2 redesign required. CRITICAL_DEFENSIVE governor wiring + zone coverage soft gate proceed as designed, co-authored with C1/C2/C3 in one branch.
- **PLAN-5 approved scope (executive memo 2026-04-20):** (A) Late continuation vulnerability — does council reach max confidence too late in trend life? Does TREND_CONTINUATION admission lack maturity/leg-exhaustion concept? (B) SR-anchor-dependent stop adequacy — are losses materially associated with SR-unanchored stop placement, not stop size? (C) AGGRESSIVE governor alignment — does AGGRESSIVE posture fire where EXHAUSTION_SENSITIVE should? Is this a genuine alignment flaw? (D) Related surfaces if directly relevant: continuation_obstacle usage, NARROW-type weakness quantification, trend maturity proxies in source. READ/ANALYZE/DESIGN only — no implementation, no threshold retuning, no Council redesign, no Stage 2 execution, no stop-size modification, no dormant-branch activation.
- **PLAN-5 must NOT become:** broad Council redesign, Stage 2 replacement, exit-system redesign, generic stop optimization, new AI branch, adaptive-weights activation, disguised implementation phase.
- **PLAN-5 FINDINGS (2026-04-20 — CONFIRMED):** Three ranked structural weaknesses confirmed from source + runtime: (1-RANK1) TREND_CONTINUATION zone has zero trend-age signal — zone fires identically at bar 5 and bar 55 of same trend; `continuation_bias` computed from structure/momentum/!exhaustion_hint only — no trend-age component (CONFIRMED_FROM_SOURCE council_environment.mqh:441-446). (2-RANK2) AGGRESSIVE governor fires at late-trend signature (HIGH_CONVICTION + diversity≥0.60 + conflict≤0.20) with zero enforcement tightening — `change_pre_ai_thresholds = false` in AGGRESSIVE case (CONFIRMED_FROM_SOURCE council_ai_governor.mqh:371-388). T3 CONFIRMED_FROM_RUNTIME as AGGRESSIVE at entry. AGGRESSIVE is the only governor case with no threshold constraint — paradox: more perfect the Council alignment, less it questions timing. (3-RANK3) `atas_level_context_degraded` has 87% loss rate (13 LOSS / 2 WIN) but is CONFIRMED architecturally isolated — zero references in council_pre_ai_filter.mqh, council_strategies.mqh, council_ai_governor.mqh, council_mode_runtime.mqh. Data flows to env and journal, stops there. `ceis_overextension_m5` (weight 0.30) is labeled "Primary LATE_CONTINUATION_FAILURE detector" in source but cannot solo-trigger G3 rider (threshold 0.70 composite) — requires 3+ simultaneous CEIS signals. Stop geometry confirmed NOT discriminator: WIN avg stop 3.09pt vs LOSS avg stop 2.96pt (85 matched pairs).
- **PLAN-5 RECOMMENDED NEXT MOVE:** PLAN-5 Phase 1 design gate — three targeted corrections to scope (NOT execute yet): (a) AGGRESSIVE governor: add `!env.ceis_overextension_m5` precondition (or `env.ceis_source_score < 0.45`) — demotes to NORMAL when overextension active; (b) G3 rider: solo overextension floor — when `ceis_overextension_m5 == true`, add `+0.08` to `min_required_consensus` independently of composite score; (c) TREND_CONTINUATION soft SR gate: when LEVEL_CONTEXT_DEGRADED in TREND_CONTINUATION zone, add `+0.05` consensus + `+0.03` quality. All three corrections use existing struct fields, existing enforcement patterns, existing detectors — no new logic. Stage 2 fate: determine merge vs sequential after Phase 1 scope is confirmed.
- **Frozen:** `structural_sr_engine.mqh`, `level_awareness_brake.mqh`, `council_aggregator.mqh` (PLAN-2 gate — no edits until SVS compile verified). Stop rules, G1/G3 thresholds, governor calibration, execution authority model — all frozen. `council_pre_ai_filter.mqh`, `council_mode_runtime.mqh`, `council_ai_governor.mqh` — unified branch edits compile-verified (2026-04-20 + 2026-04-21 C3 rebind), frozen pending C1+C2 footprint observation. Stage 2B defect: FIXED 2026-04-21 (block relocated to after RANGE_MEAN_RECLAIM absolute block; compile-verified; CONFIRMED_FROM_RUNTIME via quality=0.68 threshold trace match). C3 rebind: COMPLETE 2026-04-21 — rebound from `atas_level_context_degraded` (ATAS governance-disabled, always false) to `env.structure_score < 0.70` (internal NOISY structure proxy; fires when structure_state==NOISY in TC zone; OBSERVATION_OPEN pending first TC+NOISY bar). Backup: `pre_change_20260421_105824_c3_rebind.zip`. `council_environment.mqh` — Stage 1 observation CLOSED (2026-04-21); unfrozen for Stage 3+. PLAN-6 scope frozen to Stage 0–7 as described in memo; stop/exit redesign, adaptive weights, AI/ATAS authority expansion, dormant-branch activation all remain frozen.
- **Immediate next step:** Two active priorities: (1) PLAN-5 / PLAN-4 Stage 2 unified branch blocker doctrine rewrite before further sequencing. Forensic re-evaluation (2026-04-23): VERIFIED_FROM_SOURCE + VERIFIED_FROM_RUNTIME. Post-unified compile XAUUSD runtime produced 212 decision snapshots; TREND_CONTINUATION occurred 31 times, all `NARROW`, 0 `HIGH_CONVICTION`, 0 `NOISY`. C1 distinct footprint is structurally shadowed: `env.ceis_overextension_m5` forces `agg.exhaustion_warning`, and governor selects `EXHAUSTION_SENSITIVE` before the AGGRESSIVE branch, so a separate live C1 footprint cannot emerge as currently framed. C2 source scope is broader than the current gate (`env.ceis_overextension_m5` adds +0.08 consensus globally, not just in TC/HIGH_CONVICTION), but exact overextension is not durably persisted in `council_feedback.json`, `ai_performance_journal.jsonl`, or `ai_decision_envelope_trace.jsonl`, so historical C2 activation cannot be directly proven. C3 rebind is valid and historically reachable (27 XAUUSD `TREND_CONTINUATION+NOISY` archive events) but absent post-rebind/post-unified runtime (0 `TC+NOISY` in 132 post-rebind decision snapshots; 28 recent `NOISY` snapshots routed to `RANGE_MEAN_RECLAIM` / `NO_TRADE` / `UNDEFINED`). Result: the old "wait for C1+C2+C3 footprints" gate is no longer stable as written. (2) PLAN-RC / PLAN-ARCH-DR — P2.A CLOSED (2026-04-22). P2.B RUNTIME_CONFIRMED (2026-04-25 14:58:40): DECISION BTCUSD-1777129120-100035-12, active_mode=COUNCIL; 5 ExRA fields strict-parsed (zone_name=RANGE_MEAN_RECLAIM, zone_type=4=COUNCIL_ZONE_RANGE_MEAN_RECLAIM, zone_confidence=0.5200, preferred_style=MEAN_RECLAIM, blocked_style=BREAKOUT); ERA distinct (regime_label=RANGE_BALANCED, regime_confidence=0.580, regime_tradability=0.6354, provenance intact); 0 double-commas; C1/C2/C3 C123_OBSERVABILITY_V1 intact; authority boundary confirmed (final_decision=REJECT by council_pre_ai_rejection; bridge fields measurement-only). Cross-ref: diagnostic_runtime_summary.json zone_name=RANGE_MEAN_RECLAIM consistent. P3.1A+P3.1B implementation gate NOW OPEN. Actual C1/C2/C3 trigger events (pre_governor_candidate=true, tightening_applied=true, low_structure_tc_active=true) still market-dependent for PLAN-4/PLAN-5 observation window — SEPARATE from P2.B gate.
- **PLAN-5 DESIGN GATE FINDINGS (2026-04-20 — new, not in prior investigation):** Filter relaxes thresholds for HIGH_CONVICTION (-0.03 consensus, +0.05 conflict max, lines 96–100). TREND_CONT + HIGH_CONVICTION effective thresholds: consensus=0.52, conflict=0.45 — most permissive configuration in filter. AGGRESSIVE governor adds zero tightening on top → compounding permissiveness at late-trend signature. C1 (AGGRESSIVE exclusion) is SEMANTIC correction only; C2 (solo overextension floor) provides ENFORCEMENT correction — they are a required pair. C3 (SR-context gate) fully independent. HIGH_CONVICTION relaxation block must be bypassed by C2 placement (C2 must go AFTER HIGH_CONVICTION block, specifically AFTER G3 at line 152+). ATAS dark-mode → C3 silent (acceptable). C1 demotion leaves Case 7 residual +1.05 vote weight (acceptable). Stage 2 C3-zone-coverage-gate shares zone-adaptive section with C3 — co-locate with explicit section comments.
- **PLAN-4 Stage 1 — what was wired:** Governor policy path moved before pre-AI filter (3C→3D→3E→4). Filter upgraded to receive `CouncilPolicyAdjustment &gov`. Floor enforcement (`MathMax`/`MathMin`) applied after zone-adaptive. G3 CEIS rider (`ceis_source_score ≥ 0.70 → max_conflict -0.05`). Three structural gates remain governor-independent. Contract fields populated in all 6 threshold-setting cases.
- **Deferred:** SVS Slice 3+, Phase 6 (advisory compression / legacy retirement), CEIS sub-signal tuning, STRATEGY_RUNTIME_DISABLE_ZONE2 activation, adaptive weights activation. PLAN-4 Stage 2 CRITICAL_DEFENSIVE + zone coverage gate now wired (unified branch, source complete 2026-04-20). C2 delta (0.08) marked CALIBRATION_PENDING — no recalibration until observation window completes.
- **Last completed milestone:** PLAN-6 Stage 3 IMPLEMENTED + COMPILE_VERIFIED + PARTIAL_RUNTIME_CONFIRMED (2026-04-21): COMPRESSION zone detection branch added to ClassifyCouncilZone() in council_environment.mqh (lines 460–472); COMPRESSION threshold block added to council_pre_ai_filter.mqh (lines 96–105). Compile: main_ea.ex5 timestamp 19:12, post-19:01 source edits, 0 errors 2 pre-existing warnings (lines 13332/13821, int→string). First gRegime=COMPRESSION in journal: 2026.04.21 19:14:06 (WIN SELL profit=49.2 regime_label=COMPRESSION conf=0.62, from REGIME_CLASSIFICATION_V1 — NOT council_zone). council_zone=COMPRESSION still OBSERVATION_OPEN (requires council_report zone evidence). Full runtime journal: 97 trades total (41 wins, 56 losses); recent_failure_pressure=0.06 (NONE) → Stage 2A CRITICAL pressure not yet reached despite 56 historical losses. Stage 2B CLOSED (arithmetic confirmed: quality=0.68 trace). Backup: `pre_change_20260421_190112_plan6_stage3.zip` (615KB, 185 files, NON-COMPLIANT full-system — corrected backup required before next modification). Prior: C3 rebind + Stage 2B fix COMPILE_VERIFIED (2026-04-21); backup `pre_change_20260421_105824_c3_rebind.zip`. Prior: PLAN-6 Stage 1 CLOSED (2026-04-21). Prior: Unified branch compile-verified (2026-04-20); backup `pre_change_20260420_160325_plan5_stage1_unified.zip`.
- **Prior milestone:** P3.2/P3.2-S SNAPSHOT CACHING REPAIR IMPLEMENTED + COMPILE_VERIFIED (2026-04-26): Root cause confirmed — `gHasLastSnapshots = true` was only set at main_ea.mq5:13038 (M5-failure branch), never in OnTick() success path. `CacheLastSnapshots()` (line 12712) defined but 0 callers — permanently blocking strategy intelligence in normal market conditions (M5 always succeeds). Repair: added `gLastM1Snapshot = m1; gLastM5Snapshot = m5; gHasLastSnapshots = true;` (3 lines) after M5-failure block in OnTick(). Compile `compile_snapshot_caching_repair_20260426_000744.log`: 0 errors, 2 pre-existing warnings at 13860/14354 (+4 shift confirms only 4 lines added). Plan flags confirmed in ai_current_plan.json and parser-correct. P3.2 + P3.2-S Fix 2: RUNTIME_PENDING — EA reload required, then qualifying DECISION with `decision_quality_version = "DQ_V2"/"DQ_V3"` (P3.2) and `expected_rr_estimate` in [0.10, 5.00] on BUY/SELL DECISION (P3.2-S Fix 2). Backup: `D:\MT5_Project_Backups\pre_change_20260426_000744_snapshot_caching_repair.zip` (22,090,317 bytes). Prior: P2.B DUAL-TRUTH BRIDGE RUNTIME_CONFIRMED (2026-04-25 14:58:40): DECISION BTCUSD-1777129120-100035-12 (active_mode=COUNCIL); zone_name=RANGE_MEAN_RECLAIM, zone_type=4, zone_confidence=0.5200; ERA side: regime_label=RANGE_BALANCED (ERA≠ExRA confirmed); strict JSON PASS, 0 double-commas; P3.1A+P3.1B implementation gate NOW OPEN. Prior: C1/C2/C3 EVIDENCE CONTRACT RUNTIME_CONFIRMED (2026-04-23 07:01). Prior: PLAN-2 SVS RUNTIME_GATE_CLOSED (2026-04-23 03:35). Prior: PLAN-6 Stage 3 OBSERVATION_CLOSED (2026-04-23 02:45:02). Prior: Zone text mapping fix + P3.3 COMPILE_VERIFIED (2026-04-22). Prior: P2.A FULLY CLOSED (2026-04-22).

---

- **DIRTY AUTHORITY CONTAINMENT AUDIT (2026-04-26) — CLASSIFIED:** `council_environment.mqh` (LastWriteTime 2026-04-21 19:01:47) and `council_pre_ai_filter.mqh` (LastWriteTime 2026-04-23 06:23:21) appear dirty relative to git HEAD (single initial commit `cf74be4`). Audit confirmed: (1) Both files contain exclusively changes from closed/confirmed plans: PLAN-6 Stage 1 (NO_TRADE repair + hardConditions), PLAN-1 CEIS (CouncilGetEMA/MFI helpers + EvaluateCEISSourceSignals 7-signal layer), PLAN-4 Stage 1 (G1 governor floors + G3 CEIS rider), PLAN-5 (C2/C3 obstacle evidence + C3 rebind + C2 solo floor), PLAN-6 Stage 3 (COMPRESSION zone + thresholds). (2) PLAN-6 Stage 3 COMPRESSION changes are EXACTLY present in both files and match the Stage 3 plan precisely. (3) Both files were compiled into the V1-B0+B binary at 15:39:38 (include chain confirmed via compile log: council_mode_runtime.mqh → both files). (4) Both files were already compiled into prior binaries (council_environment.mqh into PLAN-6 Stage 3 binary 2026-04-21 ~19:12; council_pre_ai_filter.mqh into P4 Option 1 binary 2026-04-26 02:07:26) and runtime-confirmed before V1-B0+B. (5) No unclassified changes present. Dirty state is structural: project uses single-commit git history; all plan implementations are uncommitted relative to initial baseline. **No action required. V1 observation window unaffected.**

- **V1-B0+B COUNCIL-ONLY SHADOW STATE + POLICY ANNOTATION (2026-04-26 15:39:38) — IMPLEMENTED + COMPILE_VERIFIED + V1-B RUNTIME_CONFIRMED + V1-B0 RUNTIME_SIGNAL_PENDING:** `council_v1_state_composer.mqh` created as pure derived/visibility-only state + policy annotation logic. `strategy_intelligence_layer_v1.mqh` now has compatibility-preserving overloads so live COUNCIL strategy-regime-fit style inference can use ExRA `CouncilZoneType` while existing callers retain the old ERA fallback behavior. `main_ea.mq5` includes the composer, calls `ApplyV1ShadowStateAnnotation()` before all 6 active `JournalAppendDecisionV3()` paths, and passes `routed.council.env.zone_type` to the live zone-aware `ComputeStrategyRegimeFitV1()` overload. `performance_journal.mqh` emits DECISION-only `v1_shadow_*` fields after P4 and before `direction`: semantics version, state label, ERA/ExRA posture, divergence class, policy posture, allowed/deprioritized/conditional families, reason code, authority class, action taken, and shadow boolean. COUNCIL-only doctrine preserved: non-COUNCIL or invalid council context emits `V1_NOT_APPLICABLE_NON_COUNCIL` / `OBSERVE_ONLY` / `NON_COUNCIL_MODE`; no ExRA is invented outside valid COUNCIL. No Version 1 live authority, no policy matrix authority, no specialist suppression, no DQ/P4 activation, no score/coherence/matrix confidence fields, no final decision/permission/risk/governor/routing/pre-AI/plan/config change. Compile log `compile_v1_b0_b_shadow_state_policy_annotation_20260426_153526.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-26 15:39:38. **V1-B RUNTIME_CONFIRMED (2026-04-26):** Three distinct states confirmed in post-compile journal records: DIRTY_ERA_DEGRADED_EXRA (18:58:25, REDUCED, DIRTY_DEGRADED), RANGE_ERA_RANGE_EXRA (19:06:30 + 19:48:12, STAGED, RANGE_ALIGNED), TREND_ERA_RANGE_EXRA (16:13:58, REDUCED, ERA_TREND_EXRA_RANGE). All 13 `v1_shadow_*` fields present; `policy_is_shadow=true`, `authority_class=DERIVED_VISIBILITY_ONLY`, `action_taken=OBSERVED_ONLY` on every record; no `state_confidence` field; `deprioritized_families` (not `suppressed_families`); state labels match source policy matrix exactly. **V1-B0 RUNTIME_SIGNAL_PENDING:** Zone-aware `SI_InferStyleTag` overload and 5-arg `ComputeStrategyRegimeFitV1` wired and compiled; no runtime record yet shows ERA/ExRA divergence (all observed cases produce same style from both paths). Confirmation trigger: first DECISION with `era_posture=TREND` + `exra_posture=EXRA_RANGE_OR_COMPRESSION` + `style=MEAN_REVERT` (would diverge from ERA-only path which produces TREND_FOLLOW). **Next step:** V1 observation window — 50–100 DECISION records; collect state distribution, policy posture frequencies, divergence class frequencies; close V1-B0 when first TREND_ERA_RANGE_EXRA record with MEAN_REVERT style appears. First controlled influence candidate (after observation window complete): ILV1 zone_bucket scoring adjustment on STAGED/WAIT states — narrow, additive, reversible. Do NOT activate DQ gating or policy-based admission until multiple observation windows complete.

- **V1 VOCABULARY FIX — COMPRESSION_ERA_RANGE_EXRA (2026-04-27 00:02:08) — COMPILE_VERIFIED + RUNTIME_CONFIRMED (2026-04-27 01:57:11):** V1 vocabulary defect confirmed: `era_posture=="COMPRESSION"` + `zone_type ∈ {RANGE_MEAN_RECLAIM, RANGE_BALANCED, RANGE_DIRTY}` produced `state_label="UNDEFINED_STATE"` instead of a meaningful state. Root cause: `CouncilV1_ComposeStateLabel()` COMPRESSION branch guards on `zone_type` ∈ {COMPRESSION, BREAKOUT_EXPANSION, EXPANSION_CONTINUATION} only — ExRA range zones (RMR/RB/RD) fall through despite `exra_posture="EXRA_RANGE_OR_COMPRESSION"` being a valid combination. Note: divergence_class was NOT affected (correctly returns `ERA_EXRA_BOTH_DEGRADED` via posture-string logic regardless of state_label). Fix: additive `COMPRESSION_ERA_RANGE_EXRA` state label in three functions of `council_v1_state_composer.mqh`. Backup: `pre_change_20260426_235419_v1_compression_era_range_exra.zip` (17,579,867 bytes). Compile log `compile_v1_compression_era_range_exra_20260426_235419.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-27 00:02:08. **RUNTIME_CONFIRMED via XAUUSD-1777254857-100055-10 (ts=01:57:11, line 6520):** regime=COMPRESSION, zone=RANGE_MEAN_RECLAIM (zone_type=4) — all required V1 fields verified: `v1_shadow_state_label=COMPRESSION_ERA_RANGE_EXRA` ✓, `era_posture=COMPRESSION` ✓, `exra_posture=EXRA_RANGE_OR_COMPRESSION` ✓, `divergence_class=ERA_EXRA_BOTH_DEGRADED` ✓, `policy_posture=STAGED` ✓, `policy_reason_code=COMPRESSION_ERA_RANGE_EXRA` ✓, `role_native_families=MEAN_RECLAIM` ✓, `role_conditional_families=COMPRESSION_BREAKOUT,LIQUIDITY_REVERSAL` ✓, `role_deprioritized_families=TREND_CONTINUATION` ✓, `role_informational_families=""` (empty — no longer "ALL") ✓, authority triple confirmed ✓. Record also confirms: (1) final_decision=BUY was produced by council pipeline independently of V1 shadow — no V1 fields in final_decision_reason; (2) failure_basis=execution_open_failed is MT5 execution permission issue, not V1 failure, does not invalidate closure. Post-fix UNDEFINED_STATE audit (26 total): 6 pre-fix COMPRESSION+EXRA_RANGE_OR_COMPRESSION records eliminated — ZERO post-binary; remaining UNDEFINED_STATE: EXRA_NO_TRADE (9 post-binary, structural/expected), REVERSAL+EXRA_RANGE_OR_COMPRESSION (2 post-binary, residual gap), ERA_UNDEFINED (pre-binary). Residual gaps (deferred): REVERSAL ERA + EXRA_RANGE_OR_COMPRESSION; EXRA_NO_TRADE; COMPRESSION ERA + TREND_CONTINUATION zone.

- **V1 COMPLETE SHADOW OBSERVABILITY PACKAGE (2026-04-26 21:34:20) — IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED (2026-04-27) | ADVERSARIAL_REMEDIATION COMPILE_VERIFIED + RUNTIME_CONFIRMED (2026-04-27):** V1-C/D/E/F shadow-only DECISION observability extension compiled. `council_v1_state_composer.mqh` enriches V1-B state annotation with `V1_POLICY_SPECIALIST_MAP_V1` role-map fields, live-family role/alignment, counterfactual action/reason, promotion readiness, and `V1_SCORING_QUARANTINE_V1` diagnostics. No Version 1 live authority, no specialist suppression/influence, no policy matrix authority, no DQ/P4 activation, no final decision/permission/risk/governor/routing/pre-AI/execution/plan/config change. Compile log `compile_v1_complete_policy_specialist_quarantine_20260426_213024.log`: 0 errors / 2 pre-existing warnings; timestamp 2026-04-26 21:34:20. **ADVERSARIAL REMEDIATION (2026-04-26 22:41:00):** 6 falsification hypotheses tested; 5 FALSIFIED; 1 confirmed defect: `v1_shadow_live_family` MISLEADING_NAME — represents council aggregate's best CANDIDATE family at eval time, NOT executed trade family. Fix: additive `v1_shadow_live_family_semantics` field (7 lines in PJ_V1ShadowStateJsonFields(), zero struct/signature changes). Compile log `compile_v1_adversarial_remediation_20260426_222646.log`: 0 errors / 2 pre-existing warnings; timestamp 2026-04-26 22:41:00. Backup: `pre_change_20260426_222646_v1_adversarial_remediation.zip`. **RUNTIME_CONFIRMED (2026-04-27):** `v1_shadow_live_family_semantics=COUNCIL_AGGREGATE_BEST_STRATEGY_FAMILY_NOT_EXECUTED_FAMILY` confirmed in post-22:41:00 records including all REJECT records (lines 6518, 6519, 6521-6525) and the BUY record (line 6520). Field correctly appears on all DECISION records including REJECTs where no trade executed — semantics are unambiguous. All V1 C/D/E/F fields confirmed present: role_native/conditional/deprioritized/informational families, live_family/role/alignment, counterfactual_action/reason, promotion_readiness, scoring_quarantine_version, dq_policy_enabled=false, score_authority_warning, live_family_semantics. Authority triple confirmed on every record: authority_class=DERIVED_VISIBILITY_ONLY, action_taken=OBSERVED_ONLY, policy_is_shadow=true. V1 C/D/E/F RUNTIME_CONFIRMED.

- **V1-FSW PHASE 1 FAMILY SOFT-WEIGHT LIVE INFLUENCE SPINE (2026-04-27 04:25:27) — IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING:** Bounded live influence spine compiled for COUNCIL aggregation only. `EnableV1LiveInfluencePhase1` is an EA input and defaults false; with the flag false all V1-FSW multipliers remain 1.00, deltas remain zero, and action emits `DISABLED_NO_ADJUSTMENT`. When explicitly enabled later, V1-FSW may indirectly change `final_decision` only through bounded aggregation weight influence; it does not directly assign/override `final_decision` or `final_permission`. Implementation adds early V1 context, delimiter-safe exact CSV family role matching, per-strategy soft multipliers clamped [0.85, 1.03], and DECISION-only `v1_fsw_*` fields including `v1_fsw_strategy_attributions`. `v1_shadow_*` authority fields remain `DERIVED_VISIBILITY_ONLY` / `OBSERVED_ONLY` / `policy_is_shadow=true`; `v1_fsw_authority_class=BOUNDED_PARTICIPATION_INFLUENCE_ONLY`. Scoring quarantine version advanced to `V1_SCORING_QUARANTINE_V2_FSW`. No P4, DQ, AI, ATAS, risk, governor, pre-AI threshold, direct permission, or plan/config activation. Compile log `compile_v1_fsw_phase1_20260427_041701.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-27 04:25:27. Runtime pending because `terminal64` was not running after compile; fresh post-binary DECISION record still required.

- **V1-FSW PHASE 1 FAMILY SOFT-WEIGHT LIVE INFLUENCE SPINE — RUNTIME CLOSURE UPDATE (2026-04-27) — IMPLEMENTED + RUNTIME_CONFIRMED_ACTIVE_EFFECTIVE:** Supersedes the runtime-pending note above. Strict parse of `ai_performance_journal.jsonl` after binary 2026-04-27 04:25:27 found 45 V1-FSW DECISION records, 0 parse errors, and 14 records with `v1_fsw_total_weight_delta != 0`. Evidence record `XAUUSD-1777287329-100509-60` confirms active bounded influence: `sweep_reversal|LIQUIDITY_REVERSAL|CONDITIONAL|0.90|0.4264|0.3838|-0.0426`; `v1_fsw_enabled=true`; `v1_fsw_action_taken=SPECIALIST_WEIGHT_ADJUSTED`; `v1_fsw_was_active_at_decision=true`. V1-FSW remains bounded specialist/family participation influence only; no direct `final_decision` or `final_permission` override, no hard veto, no zero multiplier, and no P4/DQ/AI/ATAS/risk/governor/pre-AI/plan activation.
- **V1 PHASE 2+3 — POLICY-GUIDED PARTICIPATION EXPANSION + SCORING QUARANTINE ENFORCEMENT (2026-04-27) — ARCHITECTURE_PREPARED_CODEX_READY:** Current accepted mission and source preflight define a bounded COUNCIL-only extension over the runtime-confirmed V1-FSW spine. Scope: Phase 2 state-specific multiplier expansion gated by `EnableV1LiveInfluencePhase1 && EnableV1PolicyGuidedParticipation`, vocabulary fixes for `REVERSAL_ERA_RANGE_EXRA` and `ANY_ERA_NO_TRADE_ZONE`, corrected mapped-vs-nonzero impact observability, unknown-family diagnostics, and Phase 3 exact `v1_score_quarantine_*` DECISION fields. Boundaries: no direct final decision/permission override, no hard veto, no zero multiplier, no DQ/P4/Dirty Gate/AI/ATAS/risk/governor/pre-AI activation, no plan JSON edit, no production-ready claim.
- **V1 PHASE 2+3 — POLICY-GUIDED PARTICIPATION EXPANSION + SCORING QUARANTINE ENFORCEMENT (2026-04-27 14:42:54) — IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING:** Source implementation complete and compile clean. Added `EnableV1PolicyGuidedParticipation=false` and `EnableV1ScoreQuarantineDiagnostics=true` EA inputs; Phase 2 remains gated by Phase 1 + Phase 2 flags. `council_v1_state_composer.mqh` now handles `REVERSAL_ERA_RANGE_EXRA` and `ANY_ERA_NO_TRADE_ZONE`, preserves exact CSV-token role matching, expands Phase 2 multipliers with clamp [0.85, 1.05], and keeps unknown/informational families at 1.00. `council_aggregator.mqh` now separates `v1_fsw_mapped_strategy_count` from `v1_fsw_nonzero_impact_count`, preserves `v1_fsw_influenced_strategy_count` as the mapped-count alias, adds role-specific nonzero counts, `v1_fsw_unknown_family_warning`, corrected `v1_fsw_was_active_at_decision`, and corrected action semantics. `performance_journal.mqh` emits exact `v1_score_quarantine_*` fields and advances `v1_shadow_scoring_quarantine_version` to `V1_SCORING_QUARANTINE_V3_ENFORCEMENT`. Compile log `compile_v1_phase2_phase3_20260427_143427.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-27 14:42:54. Runtime pending because `terminal64` was not running after compile; fresh post-binary DECISION required. No direct final decision/permission override, no hard veto, no zero multiplier, no DQ/P4/Dirty Gate/AI/ATAS/risk/governor/pre-AI/plan activation, no production-ready claim. **RUNTIME_CONFIRMED_ACTIVE_EFFECTIVE (2026-04-27):** Phase 2 ACTIVE_EFFECTIVE confirmed — TREND_ERA_TREND_EXRA bar (journal line 6595–6596): `trend_momentum|TREND_CONTINUATION|NATIVE|1.05|0.7740|0.8127|+0.0387`; NATIVE+STAGED=1.03 confirmed (lines 6579–6584); CONDITIONAL=0.90 confirmed (delta −0.0008). ANY_ERA_NO_TRADE_ZONE bypass confirmed across 11 records. Phase 3 Scoring Quarantine V3 confirmed across all 23 post-binary records. Count semantics FAMILY_MAPPED_NO_EFFECTIVE_WEIGHT_IMPACT confirmed (lines 6593–6594). Phase 2+3 formally closed. PIML corrected 2026-04-28.
- **V1 PHASE 2.5 UNKNOWN FAMILY MAPPING (2026-04-28 03:06:59) — IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING:** One-file additive role-map append only in `council_v1_state_composer.mqh::CouncilV1_ApplySpecialistRoleMapForState()`. The five previously unknown V1-FSW families are now mapped across existing state role CSVs: `MOMENTUM_REVERSAL_ASSIST`, `TREND_PULLBACK_CONTINUATION`, `VOL_BREAKOUT`, `EXPANSION_CONTINUATION`, `MICRO_RANGE_BREAK`. No state labels, functions, structs, multiplier clamp, strategy scoring, eligibility, governor, pre-AI, risk, DQ, P4, AI/ATAS, execution, direct final_decision, or final_permission logic changed. Clamp remains [0.85, 1.05]. `v1_fsw_unknown_family_warning` is expected to clear on fresh non-bypass COUNCIL records with `v1_fsw_phase2_active=true`; runtime remains pending because post-compile journal rotation did not occur (`terminal64` started, journal last write 2026-04-28 01:48:25 predates binary). Compile log `compile_v1_phase25_unknown_family_mapping_20260428_030232.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; backup `D:\MT5_Project_Backups\pre_change_20260428_025805_v1_phase25_unknown_family_mapping.zip` (2335 files, 12,681,193 bytes). **RUNTIME_CONFIRMED_ACTIVE_WIRING + ACTIVE_EFFECTIVE_PENDING (2026-04-28 11:46:24):** Proof record XAUUSD-1777376784-100565-2 (journal line 6600), RANGE_ERA_RANGE_EXRA, Phase 2 enabled. All 5 Phase 2.5 families correctly mapped: `MICRO_RANGE_BREAK=NATIVE|1.03`, `MOMENTUM_REVERSAL_ASSIST=CONDITIONAL|0.90`, `TREND_PULLBACK_CONTINUATION/VOL_BREAKOUT/EXPANSION_CONTINUATION=DEPRIORITIZED|0.85`. `v1_fsw_unknown_family_warning=""` (VP2_5-01 CONFIRMED). No regression to confirmed families (VP2_5-07 CONFIRMED). ACTIVE_EFFECTIVE pending: all 17 strategies had pre_weight=0.0000 in first post-binary record — market-conditional (first non-zero strategy weight bar required). Observation window open. PIML corrected 2026-04-28.
- **AUTHORITY STACK PILOT (2026-04-29 01:34:56) — IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED_ACTIVE_EFFECTIVE:** Bounded live authority stack source-wired after `EvaluateDecisionModeRouted()` and before BUY/SELL/REJECT/WAIT branch handling. Stack order is P4 -> DQ proxy -> V1 and can convert only baseline BUY/SELL decisions to `RUNTIME_REJECT`; baseline REJECT/WAIT remains `NOT_EVALUATED`. Added EA rollback flags `EnableAuthorityStackPilot=true`, `AuthorityStack_EnableP4=true`, `AuthorityStack_EnableDQ=true`, `AuthorityStack_EnableV1=true`, `AuthorityStack_DQProxyThreshold=0.34`. P4 blocks only `ERA_EXRA_AGREE_DEGRADED`; `EnableCouncilDirtyEnvironmentTightening` remains false. DQ is `DQ_PROXY_ACTIVE` from current-tick `council_quality`, `consensus_strength`, and `zone_confidence`, not full DQ V3. V1 blocks only OBSERVE_ONLY/WAIT/UNDEFINED posture or `UNDEFINED_STATE`; FULL/STAGED/REDUCED/RESTRICTED pass. Authority-blocked decisions append `AUTHORITY_STACK_<P4|DQ|V1>` to the reason and journal `authority_stack_*` fields. Compile log `compile_authority_stack_pilot_20260429_012844.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-29 01:34:56. **RUNTIME_CONFIRMED_ACTIVE_EFFECTIVE (2026-04-29):** 70+ fresh post-binary DECISION records confirmed (journal range 02:07:59–09:47:30, last write 10:51). PASSED events (e.g. XAUUSD-1777432074-100794-16 ts=03:11:14: SELL, authority_stack_status=PASSED, dq_proxy=0.8211, v1_posture=REDUCED, p4_div=ERA_CLEAN_EXRA_DEGRADED, changed_outcome=False) confirm correct pass-through. BLOCKED_P4 events (XAUUSD-1777446042-101027-61 ts=07:00:42 and XAUUSD-1777449715-101088-76 ts=08:01:55): final_decision=REJECT, final_decision_reason=AUTHORITY_STACK_P4, authority_stack_status=BLOCKED_P4, changed_outcome=True, p4_div=ERA_EXRA_AGREE_DEGRADED — confirm P4 actively converts BUY/SELL to REJECT on ERA_EXRA_AGREE_DEGRADED. v1_fsw_enabled=True and v1_fsw_phase2_active=True in 100% of records. **FULL_V1_CONFIG_ACTIVE confirmed 2026-04-29:** All 14 required posture items RUNTIME_CONFIRMED (EnableAuthorityStackPilot/P4/DQ/V1=true, DQProxyThreshold=0.34, EnableCouncilDirtyEnvironmentTightening=false, EnableV1LiveInfluencePhase1=true, EnableV1PolicyGuidedParticipation=true, EnableV1ScoreQuarantineDiagnostics=true, decision_engine_mode=COUNCIL, DQ V3 authority absent, legacy dirty gate dormant, P4 ERA_EXRA_AGREE_DEGRADED only). Screenshot showing EnableV1LiveInfluencePhase1=false and EnableV1PolicyGuidedParticipation=false was a MetaEditor properties-dialog artifact — runtime evidence shows both active in 100% of post-binary records. Minor journal gaps (non-blocking): (1) `final_blocking_layer` not serialized to JSON — information present via final_decision_reason=AUTHORITY_STACK_P4; (2) `authority_blocking_authority` field name absent — information present via authority_stack_status=BLOCKED_P4; (3) WAIT-pair records (#44, #54) inherit authority_stack_* fields from same-tick blocked BUY/SELL decision — journaling inheritance, not authority safety issue. V1 OBSERVE_ONLY authority block: MARKET_CONDITIONAL_PENDING (all OBSERVE_ONLY posture bars in 70-record window were pre-AI filter rejections, NOT_EVALUATED by authority stack; confirmation requires BUY/SELL passing pre-AI filter during OBSERVE_ONLY V1 posture).
- **V1 CONSTRUCTIVE ELIGIBILITY LAYER A1 (2026-04-29 12:56:02) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING:** Stage A1 source implementation complete. Added `EnableV1ConstructivePolicyEligibility=false` EA input and a downgrade-only V1 constructive policy eligibility pass between strategy detection and aggregation. V1 early state/policy context is now composed immediately after council environment build; strategy reports are then policy-conditioned before aggregation. The override uses exact CSV role matching, never upgrades existing eligibility, preserves scores/vote weights/triggers/direction/family/FSW multipliers, and emits additive `v1_policy_*` DECISION fields. Aggregation formulas, pre-AI thresholds, governor, risk, execution, authority stack, DQ/P4/AI/ATAS, plan JSON, and strategy detector logic are unchanged. Compile log `compile_v1_constructive_eligibility_a1_20260429_125131.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-29 12:56:02. Runtime pending because `terminal64` was not running and latest `ai_performance_journal.jsonl` write 2026-04-29 10:51:42 predates the rebuilt binary. Stage A1 only; pre-AI score-threshold gates remain score-sovereign and Stage A2 is still required. No production-ready or full V1 completion claim.

- **V1 CONSTRUCTIVE ELIGIBILITY LAYER A1 RUNTIME ADDENDUM (2026-04-29 13:39:12) - RUNTIME_CONFIRMED_ACTIVE_EFFECT:** Runtime evidence record `XAUUSD-1777469952-100166-2` confirms A1 active before aggregation: `v1_policy_constructive_active=true`, `v1_policy_score_role=LOCAL_RANKING_WITHIN_POLICY_ELIGIBLE_SUBSET`, and `v1_policy_score_sovereignty_blocked=true`. Multiple CONDITIONAL / DEPRIORITIZED strategy families were downgraded before aggregation, including ACTIVE -> REDUCED cases in `v1_policy_strategy_attributions`. A1 remains Stage A1 only; it does not demote pre-AI score-threshold gates by itself.

- **STAGE A2 PRE-AI FILTER DEMOTION (2026-04-29 14:47:58) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED:** Stage A2 source implementation compile-verified. Pre-AI Gates 3/4/5 (`council_quality`, `consensus_strength`, `conflict_score`) are demoted from hard pass/block authority to diagnostics using `pre_ai_score_gates_demoted`, observed metric fields, and `pre_ai_would_have_gated_*` evidence fields in DECISION JSON. Structural validators remain authoritative: NO_TRADE, environment score floor, diversity safety net, confirmation role, dominant side, and final filtered decision assignment. A1 remains active upstream; authority stack remains unchanged and post-filter; P4/DQ/V1 stack semantics unchanged. Compile log `compile_stage_a2_pre_ai_demotion_20260429_144302.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-29 14:47:58. **RUNTIME_CONFIRMED (2026-04-29): Primary proof record XAUUSD-1777475303-100056-1 (line 6685, ts=15:11:56, SELL, council_quality=0.5042 < old Gate 3 threshold 0.55, pre_ai_would_have_gated_quality=True, final_decision=SELL, authority_stack_status=PASSED, dq_proxy=0.7251). Active effect: 1/9 fresh DECISION records (11.1%); pre-A2 would have blocked this SELL via Gate 3. All 7 A2 fields present on all 9 DECISION records. `v1_policy_score_role=LOCAL_RANKING_WITHIN_POLICY_ELIGIBLE_SUBSET` on all 9 records — score is a ranker, not a gate. Structural validators (Gates 6/7/8) intact and independently blocking quality-weak bars (7 REJECT records blocked by diversity/confirm_role/dominant_side — A2 demoted quality gate would also have fired but structural gate is sufficient). C2 diagnostic `A2_SCORE_GATE_DEMOTED_NO_OUTCOME_EFFECT` emitted on L6692-L6695 confirming correct observability reporting. Full V1 config confirmed: p4_dirty_env_legacy_gate_enabled=False on all 9, authority_stack evaluated on PASS records, v1_policy_constructive_active=True on all 9. P4 authority: ERA_EXRA_AGREE_DEGRADED correctly blocked L6696 (p4_would_block=True). DQ backstop at 0.34: not blocking passing records (dq_proxy=0.72–0.79 on trade records) — structural gates providing adequate protection at current quality levels. Note: `v1_policy_score_could_not_admit_suppressed=True` on all 9 records including PASS records — constructive eligibility consistently limited under current postures (monitor, not blocking).** A3 remains required for DQ proxy recalibration / conflict-risk treatment, and later task `Score Function Quarantine & Dead Code Inventory` remains registered for score-like function/field classification. No production-ready, V1 complete, or full score-sovereignty-removal claim.

- **A3-REVISED DQ PROXY QUARANTINE (2026-04-29 20:05:03) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED_WIRING (2026-04-29 20:35:25):** Old A3 DQ threshold recalibration is superseded by the official No Score in Decision Layers directive. `authority_stack_pilot.mqh` now keeps DQ proxy computation and journal compatibility fields (`authority_dq_proxy_score`, `authority_dq_threshold`, `authority_dq_would_block`) but forces live DQ authority to diagnostic-only: `authority_dq_would_block=false` hardcoded at line 273, no `BLOCKED_DQ` branch remains, and DQ cannot mutate `decision`, `blocked`, `primary_layer`, `blocking_authority`, `blocking_reason`, `changed_outcome`, or equivalent authority-status fields. `AuthorityStack_EnableDQ` remains a diagnostic compatibility flag only. P4 and V1 remain authority-stack blocking layers; P4 still blocks only `ERA_EXRA_AGREE_DEGRADED`, and V1 remains categorical posture/state authority. Compile log `compile_a3_revised_dq_proxy_quarantine_20260429_200024.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-29 20:05:03. **RUNTIME_CONFIRMED_WIRING (2026-04-29 20:35:25): Single fresh post-binary record `XAUUSD-1777494925-100177-2` (L6697, ts=20:35:25, REJECT baseline, NOT_EVALUATED): `authority_dq_would_block=False`, no `BLOCKED_DQ`/`AUTHORITY_STACK_DQ` anywhere in 285-field record, `v1_score_quarantine_dq_role=DISABLED`, `v1_shadow_score_authority_warning=NONE`. Dead code confirmed: `return "AUTHORITY_STACK_DQ"` at main_ea.mq5:5112 is permanently unreachable — no code path sets `primary_layer="DQ"` in current implementation. P4 continuity: P4 observability shows ERA_EXRA_AGREE_DEGRADED on this bar (p4_dirty_env_would_block=True) but authority stack NOT_EVALUATED (REJECT baseline reached pre-AI first). A2 continuity: all 7 fields present, pre_ai_score_gates_demoted=True. UPGRADE TO ACTIVE_EFFECT PENDING: requires BUY/SELL baseline with dq_proxy_score < 0.34 that passes authority stack without blocking. **EA INPUT REGRESSION DETECTED: `EnableV1LiveInfluencePhase1=false`, `EnableV1PolicyGuidedParticipation=false`, `EnableV1ConstructivePolicyEligibility=false` in new binary — A1 and V1-FSW Phase 1+2 DISABLED (input reset during recompilation). These flags need to be restored to true. DQ quarantine itself is unaffected (hardcoded in source, flag-independent).** `authority_stack_enabled_layers=P4,DQ,V1` (cosmetic — DQ appears due to enableDQ flag but has zero blocking authority). Remaining score-authority targets: env.total_score gate (Stage B), score_final in aggregation (Stage C), governor score-input cleanup (Stage D), dead code cleanup (Stage E).

- **NO-SCORE CORE PACKAGE 1 REVISED (2026-04-29 22:20:02) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_SMOKE_CONFIRMED (2026-04-29 23:20:11):** Bounded three-source-file package compile-verified and smoke-confirmed. `council_environment.mqh:544` removes `env.total_score` from live tradability authority (`r.tradable=hardConditions`); `council_pre_ai_filter.mqh` removes pre-AI Gate 2 `env.total_score` live rejection authority and leaves environment score diagnostic-only (comment block inserted at line 406); `council_aggregator.mqh:205` removes `score_final` and `awMul` from live aggregation weight construction (`weight = vote_weight * roleMultiplier`, then existing categorical eligibility and V1-FSW multipliers), quarantines adaptive weights from live weight at the formula level (not just flag-dependent) with `ADAPTIVE_WEIGHTS_QUARANTINED_NO_LIVE_WEIGHT_EFFECT` diagnostic note, and changes authority-facing `best_strategy_id` selection from `score_final` winner to highest positive no-score post-eligibility/post-V1-FSW live contribution so `level_awareness_brake.mqh:309` and other consumers receive no-score strategy context. `score_final` remains diagnostic/research/local-ranking only; `bestScore` remains diagnostic for council_quality formula (`bestScoreSafe * 0.15` in aggregator line 527), whose live gate authority was demoted by A2 and whose DQ proxy path was quarantined by A3-Revised. A1/A2/A3-Revised preserved; authority_stack_pilot.mqh unchanged; DQ remains diagnostic-only; P4/V1 remain categorical authority layers; governor, risk engine, strategy detectors, AI/ATAS, plan JSON, Level Awareness Brake, and all other files unchanged. Compile log `compile_no_score_core_package1_revised_20260429_221149.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-29 22:20:02. **RUNTIME_SMOKE_CONFIRMED (2026-04-29 23:20:11): Fresh DECISION record `EURUSD-1777504811-100014-3` (ts=23:20:11, post-binary 22:20:02): `v1_policy_constructive_active=true` (A1 restored), `v1_fsw_enabled=true`, `v1_fsw_phase2_active=true` (V1-FSW Phase 1+2 restored), `pre_ai_score_gates_demoted=true` (A2 active), `authority_dq_would_block=false` (A3-Revised active), `authority_stack_primary_layer=NONE`, `authority_stack_status=NOT_EVALUATED` (REJECT baseline before stack — structurally correct for NO_TRADE zone), `v1_score_quarantine_dq_role=DISABLED`, `v1_score_quarantine_warning=""`, no BLOCKED_DQ. `zone_name=NO_TRADE`, `v1_policy_posture=OBSERVE_ONLY`, `final_decision=REJECT` — correct pipeline behavior. pre_ai_would_have_gated_quality=true (obs quality=0.0866) and pre_ai_would_have_gated_consensus=true both confirm A2 demotion is active (would-have-gated diagnostics emitted, no actual block). Active-effect BUY/SELL proof (Package 1 no-score aggregation visible in a trade direction record) remains useful but market-conditional and not required for this closure.** Not production-ready and not full no-score completion. Remaining known work: governor dead-output documentation, risk-state conditional score-gate quarantine note, dead pre-AI filter threshold machinery removal, unreachable AUTHORITY_STACK_DQ string cleanup, misleading AuthorityStack_EnableDQ=true default cleanup — targeted in NO-SCORE RESIDUE PACKAGE 2.

- **NO-SCORE RESIDUE PACKAGE 2 (2026-04-30 00:14:48) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_SMOKE_CONFIRMED (2026-04-30 01:47:16):** Surgical residue cleanup compile-verified. `council_pre_ai_filter.mqh` removed the confirmed-dead adaptive threshold machinery between base diagnostic threshold assignment and the Stage A2 reset block; the A2 reset/evidence contract remains intact and continues to set `pre_ai_score_gates_demoted`, observed score fields, and would-have-gated diagnostics. Structural validators remain authoritative and unchanged: NO_TRADE, diversity, confirm-role, dominant-side, and final filtered decision assignment. `main_ea.mq5` removed the unreachable `AUTHORITY_STACK_DQ` fallback branch and changed `AuthorityStack_EnableDQ` default to `false`, so corrected/default input should emit `authority_stack_enabled_layers=P4,V1` while DQ proxy fields remain diagnostic-only. `authority_stack_pilot.mqh` was not modified and still cannot set DQ as `primary_layer`, `blocking_authority`, `BLOCKED_DQ`, or a live decision mutator. A1/A2/A3-Revised/Package 1 preserved; no strategy, aggregation, governor, risk, execution, plan JSON, runtime JSON, AI/ATAS, dashboard, or level-brake source changed. Governor threshold-output residue is now documented as a dead-output/dormant producer after A2/Package 2 and remains unmodified pending Stage D categorical redesign. Risk-state score residues are dormant/dead under current source/plan evidence (`risk_state_policy_enabled` default false and absent from active `plan_v076`) and remain unmodified. Compile log `compile_no_score_residue_package2_20260430_000621.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-30 00:14:48. **RUNTIME_SMOKE_CONFIRMED (2026-04-30 01:47:16): Four fresh post-binary DECISION records parsed (XAUUSD, ts range 01:42:15–01:47:16). Primary active-effect proof: records XAUUSD-1777513352-100043-5 (ts=01:42:32) and XAUUSD-1777513636-100048-6 (ts=01:47:16) both show `authority_stack_status=BLOCKED_P4`, `authority_stack_baseline_decision=BUY`, `authority_stack_changed_outcome=True` — P4 categorical ERA_EXRA_AGREE_DEGRADED gate intercepted BUY signals generated by no-score aggregation (weight = vote_weight * roleMultiplier * eligibilityFactor * v1Mul). `authority_stack_enabled_layers=P4,V1` on all 4 records — DQ string removed from layers as expected post-Package 2 `AuthorityStack_EnableDQ=false` default. `authority_dq_would_block=False` on all 4 records (A3-Revised active). `dq_proxy_score=0.7517` on BLOCKED_P4 records — confirmed diagnostic only, no blocking path. A1 continuity: `v1_policy_constructive_active=True` on all 4. A2 continuity: `pre_ai_score_gates_demoted=True` on all 4, would-have-gated fields present. A3-Revised continuity: `v1_score_quarantine_dq_role=DISABLED`. Package 1 continuity: no-score aggregation producing directional BUY signals visible in baseline_decision. No AUTHORITY_STACK_DQ string present in any record. Full chain A1→A2→A3-Revised→Package 1→Package 2 confirmed simultaneously in a single observation window.** Not production-ready; full No-Score V1, governor redesign, risk engine redesign, and all score-function removal are not claimed.

- **STAGE D GOVERNOR CATEGORICAL REDESIGN (2026-04-30 03:28:09) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_SMOKE_CONFIRMED (2026-04-30 03:50:51):** `council_ai_governor.mqh` is now a categorical context observer only. Governor state selection no longer uses score-like inputs (`council_quality`, `consensus_strength`, `conflict_score`, `zone_confidence`, confidence/DQ/proxy/fit terms absent by source search) and now uses categorical context: tradability, council zone enum, consensus type label, exhaustion flag, overextension flag, gate pass state, and `two_or_more_dominant_families`. `council_mode_types.mqh` adds additive `CouncilAggregateReport.two_or_more_dominant_families` with false initialization; `council_aggregator.mqh` populates it from existing dominant-side family counts without changing Package 1 no-score aggregation (`weight = s.vote_weight * roleMultiplier`, no `score_final` or `awMul` reactivation). Governor cases no longer assign dead threshold/vote outputs (`change_pre_ai_thresholds`, `new_min_*`, `new_max_conflict`, `change_vote_weights`, `new_vote_weight`, `confidence_of_adjustment`, `adjustment_intensity`); stale-compatible struct fields remain initialized by defaults. Score-based Case 7 removed; mode-exit diagnostic is categorical (`dominant_side=="NONE"` or no active strategies). No live reject/allow/threshold/vote/pre-AI/authority-stack path was added; `governor_state` journal contract is unchanged. A1/A2/A3-Revised/Package 1/Package 2 preserved; `authority_stack_pilot.mqh`, `main_ea.mq5`, `council_pre_ai_filter.mqh`, risk, strategy detectors, plan/runtime JSON, dashboard, AI/ATAS unchanged. Compile log `compile_stage_d_governor_categorical_20260430_031932.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-30 03:28:09. **RUNTIME_SMOKE_CONFIRMED (2026-04-30 03:50:51): Fresh post-binary DECISION record XAUUSD-1777521051-100111-2 (ts=2026.04.30 03:50:51, post-binary 03:28:09). active_mode=COUNCIL; authority_stack_enabled_layers=P4,V1 (DQ absent — Package 2 AuthorityStack_EnableDQ=false confirmed); authority_dq_would_block=false (A3-Revised active); no BLOCKED_DQ, no primary_layer=DQ; authority_stack_status=NOT_EVALUATED — REJECT baseline, pre-AI structural gate fired before stack evaluation, correct pipeline behavior; v1_policy_constructive_active=true (A1 active); v1_fsw_enabled=true, v1_fsw_phase2_active=true (V1-FSW Phase 1+2 active); pre_ai_score_gates_demoted=true (A2 active); v1_score_quarantine_dq_role=DISABLED (A3-Revised active); p4_dirty_env_legacy_gate_enabled=false. Full A1→A2→A3-Revised→Package 1→Package 2→Stage D continuity chain confirmed. OBSERVABILITY ITEM: governor_state field is present but empty on this smoke record — classified as a governor observability gap for the No-Score V1 Closure Audit, not a runtime blocker; Stage D does not add live decision authority and governor_state content is non-authoritative in all cases.** Stage D is a categorical context redesign, not live authority; not production-ready; not full No-Score completion. Remaining No-Score residues deferred: failure detector internals, risk dormant gates, diagnostic `council_quality`/`bestScore`, and adaptive weights future redesign. Immediate next step: No-Score Dormant Risk Hard-Lock Package.

- **NO-SCORE DORMANT RISK HARD-LOCK PACKAGE (2026-04-30 12:11:06) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING:** Six dormant score-authority gate locations hard-locked at source level across `main_ea.mq5` and `council_mode_runtime.mqh`. Surfaces hard-locked: (1) `EvaluateCouncilDirtyEnvironmentTightening` (void) — unconditional `return;` after `InitCouncilDirtyEnvironmentAssessment(out)`, Init defaults `gate_applied=false; pass=true; verdict="BYPASS"` ensure caller `if(gate_applied && !pass)` never fires even if `EnableCouncilDirtyEnvironmentTightening=true`; (2) `EvaluateTrendContinuationConfirmationReinforcement` (bool) — unconditional `return false;` after `InitContinuationConfirmationReinforcementAssessment(a)`, entire score-based rescue-pass path (council_quality/consensus_strength/conflict_score/zone_confidence/environment_score thresholds) made unreachable even if `EnableCouncilTrendContinuationConfirmationReinforcement=true`; (3) `RuntimePolicyAllowsTrade` regime gate — 3× `return false;` commented `// [NO-SCORE HARD-LOCKED]` for `regime_confidence_below_min`, `tradability_below_min`, `regime_not_allowed` under `plan.regime_policy_enabled`; `reason=` diagnostic assignments preserved; (4) `RuntimePolicyAllowsTrade` DQ gate — 9× `return false;` commented per identical 67-line DQ block under `plan.decision_quality_policy_enabled && plan.strategy_intelligence_enabled`; (5) `RegimeFilterAllows` regime gate — NEW FINDING not in closure audit — 3× `return false;` commented for `regime_confidence_below_min`, `regime_tradability_below_min`, `regime_not_allowed` under `plan.enable_regime_filter`; called live at main_ea.mq5:13959; (6) All 5 DQ block instances across `CooldownAllowsNewTrade`, `SessionAllowsNewTrade`, `CapacityAllowsNewTrade`, `RuntimePolicyAllowsTrade`, `RegimeFilterAllows` — replaced simultaneously via `replace_all=true` with hard-lock header comment; 9× `return false;` per instance commented. All score-field `reason=` assignments preserved as diagnostics. `OPERATION_GUARDRAILS.md` updated with hard-lock governance section (9-surface table, reactivation requires source review + code change + recompile + No-Score V1 audit). Backup: `D:\MT5_Project_Backups\pre_change_20260430_114544_no_score_dormant_risk_hard_lock.zip`. Compile log: `compile_no_score_dormant_risk_hard_lock_20260430_120651.log` — 0 errors / 2 pre-existing warning 94 at lines 14340/14839; binary timestamp 2026-04-30 12:11:06. Runtime smoke requires EA reload in MT5; verify `authority_stack_enabled_layers=P4,V1`, `authority_dq_would_block=false`, `v1_policy_constructive_active=true`, `pre_ai_score_gates_demoted=true`, and no `regime_policy_*` or `dq_policy_*` strings in `final_decision_reason` on fresh DECISION post-binary 12:11:06. **RUNTIME_SMOKE_CONFIRMED (2026-04-30 14:20:47):** Pre-edit confirmation using record `XAUUSD-1777558847-100741-3` (ts=14:20:47, binary 12:11:06): all hard-lock invariants confirmed — `authority_stack_enabled_layers=P4,V1`, `authority_dq_would_block=false`, `pre_ai_score_gates_demoted=true`, `v1_policy_constructive_active=true`, no regime_policy_* or dq_policy_* in `final_decision_reason`.

- **OBSERVABILITY TRIO V1 (2026-04-30 15:17:02) - IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_SMOKE_CONFIRMED (2026-04-30 15:37:54):** Three diagnostic-only observability surfaces added. (1) Level Brake explanation: 6 fields (`level_brake_fired`, `level_brake_reason_code`, `level_brake_obstruction_class`, `level_brake_room_points`, `level_brake_rejection_risk`, `level_brake_sr_resolution_count`) emitted on every DECISION — explain whether Level Brake was involved and at what SR level. (2) Structural pre-AI gate annotation: 3 fields (`structural_reject_gate`, `structural_reject_gate_detail`, `pre_ai_structural_passed`) — classify whether pre-AI structural pass was achieved before the authority stack. (3) Governor categorical state serialization: 3 fields (`governor_state`, `governor_state_source`, `governor_categorical_state_active`) — emit Stage D governor state string (previously empty) with source attribution. No live authority, scoring, DQ, plan, V1, P4, execution, or risk logic changed. Compile log `compile_observability_trio_v1_20260430_150801.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; binary timestamp 2026-04-30 15:17:02. **RUNTIME_SMOKE_CONFIRMED (2026-04-30 15:37:54):** Proof record `XAUUSD-1777563474-100045-2` (ts=15:37:54, post-binary 15:17:02, symbol=XAUUSD). All 12 new fields present and correctly typed. Level Brake fields: `level_brake_fired=false`, `level_brake_reason_code=NONE`, `level_brake_obstruction_class=NONE`, `level_brake_room_points=-1`, `level_brake_rejection_risk=0.00`, `level_brake_sr_resolution_count=0` — sentinel defaults, no Level Brake event (P4 blocked before execution). Structural fields: `structural_reject_gate=PASSED_STRUCTURAL`, `structural_reject_gate_detail=direction=BUY`, `pre_ai_structural_passed=true` — BUY passed all structural gates before authority stack. Governor fields: `governor_state=EXHAUSTION_SENSITIVE` (non-empty — governor observability gap from Stage D smoke is now resolved), `governor_state_source=STAGE_D_CATEGORICAL_GOVERNOR`, `governor_categorical_state_active=true`. All hard-lock/no-score invariants preserved: `active_mode=COUNCIL`, `authority_stack_enabled_layers=P4,V1`, `authority_dq_would_block=false`, `v1_policy_constructive_active=true`, `pre_ai_score_gates_demoted=true`, `v1_score_quarantine_dq_role=DISABLED`, `p4_dirty_env_legacy_gate_enabled=false`. Record is a P4-blocked BUY: `authority_stack_status=BLOCKED_P4`, `authority_stack_baseline_decision=BUY`, `authority_p4_divergence_observed=ERA_EXRA_AGREE_DEGRADED` (ERA=RANGE_DIRTY, tradability=0.2544, ExRA=RANGE_MEAN_RECLAIM, zone_confidence=0.52). **REPEATED BUY→BLOCKED_P4 PATTERN (2026-04-30, 3 instances confirmed):** No-Score council generated HIGH_CONVICTION BUY signals (bollinger_reclaim MEAN_RECLAIM, Consensus=1.00, Conflict=0.00) that passed structural gates and V1 (REDUCED posture, v1_would_block=false), but were blocked by P4 categorical authority (ERA_EXRA_AGREE_DEGRADED). Prior instances: XAUUSD-1777513352 (ERA=COMPRESSION, COMPRESSION_LOW_TRADABILITY) and XAUUSD-1777513636 (ERA=COMPRESSION, COMPRESSION_LOW_TRADABILITY). All three: ERA_EXRA_AGREE_DEGRADED, RANGE_MEAN_RECLAIM ExRA zone, DQ disabled, P4 sole blocking layer, Level Brake not involved (blocked before execution). Current interpretation: categorical protection in degraded ERA context; not score authority; not regression. Track P4_BLOCKED_BUY rate in 250/500 validation window as potential bottleneck metric — P4 is correctly protecting but consistently suppressing otherwise clean ExRA signals in the current degraded-ERA market condition. One successful BUY executed 09:26:45 (XAUUSD-1777541098, TREND_UP ERA, TREND_CONTINUATION ExRA, WIN) confirms system can produce and execute trades when ERA environment is clean. **PERFORMANCE AUDIT NOTE:** Experts log analysis identified likely runtime overhead sources: (1) SRVIZ_STATUS emitted on every M5 bar close (not only decisions), including ATAS `atas_microstructure_status.json` file read on each emission — consistently returns PACKET_INVALID as ATAS is not running; (2) Full 17-strategy council pipeline evaluated on every M5 bar regardless of NO_TRADE zone or cooldown; (3) Large 285+-field JSON journal append on every M5 bar. Two abnormal terminations observed today (14:22:22 and 15:42:23, severity=2). No source changes made; optimization package deferred pending operator review and explicit authorization.

- **PIML AUTHORITY CONSOLIDATION / CLAUDE MEMORY QUARANTINE (2026-04-30) - GOVERNANCE_CORRECTION_APPLIED:** Claude memory files `project_phase_state.md` and `project_no_score_audit.md` were identified as maintaining independent phase-state ledgers that duplicated PIML content — a governance drift. Correction applied: both files quarantined to non-authoritative pointer-only content pointing to this file (PIML). `MEMORY.md` index updated: stale dangling pointer to non-existent `project_phase6a_dashboard_fixes.md` removed; remaining phase-state entries relabeled as pointers; PIML-is-authoritative authority note added. `OPERATION_GUARDRAILS.md` updated with new section "PIML Authority / No Duplicate Phase State" stating PIML as sole official phase/status memory, forbidding parallel Claude memory ledgers, and requiring all phase/status updates to go to PIML only. No trading source files modified. No compile. No runtime artifact changes. No production-ready claim. PIML remains sole authoritative phase/status source.

- **V1 NO-SCORE BEHAVIORAL VALIDATION — INITIAL LONG-RUNTIME REVIEW (2026-04-30) — ARCHITECTURE_HOLDING:** Runtime journal analysis performed on 54 DECISION records captured under Stage D binary (2026-04-30 03:28:09), window 03:50:51–10:44:02, XAUUSD M1 only. Hard-Lock binary (12:11:06) was compiled AFTER journal capture ended — Hard-Lock RUNTIME_PENDING remains unresolved. CLASSIFICATION: NO-SCORE V1 BEHAVIORAL VALIDATION — ARCHITECTURE HOLDING. Key findings: (1) NO-SCORE INTEGRITY CLEAN across all 54 records: `authority_stack_enabled_layers=P4,V1` (DQ absent) 54/54; `authority_dq_would_block=False` 54/54; `v1_score_quarantine_dq_role=DISABLED` 54/54; `v1_policy_constructive_active=True` 54/54 (A1); `pre_ai_score_gates_demoted=True` 54/54 (A2); `v1_fsw_enabled=True` + `v1_fsw_phase2_active=True` 54/54; `v1_policy_score_role=LOCAL_RANKING_WITHIN_POLICY_ELIGIBLE_SUBSET` 54/54; `v1_constructive_policy_version=V1_CONSTRUCTIVE_ELIGIBILITY_V1` 54/54; `v1_fsw_unknown_family_warning=''` 54/54 (Phase 2.5 mapping clean); policy/shadow state labels perfectly matched 54/54. (2) HARD-LOCK REGRESSION CHECK CLEAN: zero `regime_policy`, `dq_policy`, `strategy_intelligence`, `continuation_reinforcement`, or `dirty_env_block` in any `final_decision_reason` or `council_summary`. (3) DECISION DISTRIBUTION: BUY=3 (5.6%), REJECT=51 (94.4%); authority_stack NOT_EVALUATED=49 (structural pre-AI path), PASSED=3, BLOCKED_V1=2; BLOCKED_P4=0; DQ completely absent. (4) POSTURE BEHAVIOR: FULL (n=6): BUY=3 REJECT=3 (50% productive); STAGED (n=14): REJECT=14; REDUCED (n=28): REJECT=28; OBSERVE_ONLY (n=6): REJECT=6 (correctly blocked). OBSERVE_ONLY non-executable confirmed. FULL aligned states producing opportunities. (5) BUY/SELL BASELINES: 3 BUY baselines (all TREND_CONTINUATION/TREND_UP/FULL/NO_DIRTY_CONTEXT; old gates would NOT have fired); 2 SELL baselines BLOCKED_V1_CORRECT (COMPRESSION+TREND_CONTINUATION UNDEFINED_STATE→OBSERVE_ONLY; ExhaustionWarn=true; late-continuation pattern). (6) P4 BEHAVIOR: ERA_EXRA_AGREE_DEGRADED observed=22 (observational P4 fires); BLOCKED_P4 in authority stack=0 (all 22 were structural pre-AI REJECT before stack evaluation); no ERA_EXRA_AGREE_DEGRADED record ever reached BUY/SELL baseline. P4 not dominating — structural gates more conservative in this session. (7) OLD SCORE GATE DIAGNOSTIC: would_have_gated_quality=True on 87% (47/54); would_have_gated_consensus=True on 56% (30/54); all on non-BUY records (old gates would have been highly restrictive but structural gates provide equivalent rejection here); zero A2 active-effect in this window (0/3 BUY records had quality/consensus concern). (8) TRADE: 1 TRADE_OPEN (XAUUSD-1777541098 BUY 09:27:01, entry=4567.59, SL=4564.88, TP=4571.72, 0.1 lot, LEVEL_CONTEXT_DEGRADED at entry) matched with 1 TRADE_CLOSE (09:30:40, exit=4571.72, WIN +41.3, closed_by_tp, duration=3.5 min) — architecture-consistent; 2 additional BUY decisions blocked by Level Awareness Brake (policy_result=BLOCKED:LEVEL_BRAKE, no TRADE_OPEN generated, final_decision=BUY in DECISION record — Level Brake is an execution-time gate downstream of DECISION record emission). (9) GOVERNOR_STATE OBSERVABILITY: `governor_state=''` on ALL 54 records — confirmed harmless observability gap (Stage D serialization gap, not a Stage D malfunction); useful to patch later. (10) UNDEFINED_STATE: 4 records (2 = COMPRESSION+TREND_CONTINUATION known residual gap, 2 = ERA_UNDEFINED known gap) — all OBSERVE_ONLY→REJECT, safe containment; deferred vocabulary patches documented. (11) SPREAD: 15–23 points avg=19.4 (XAUUSD gold points). (12) V1_FSW_UNKNOWN_FAMILY_WARNING empty on 54/54 (Phase 2.5 clean). NEXT STEP: Reload EA with Hard-Lock binary (12:11:06) to capture runtime smoke; verify `authority_stack_enabled_layers=P4,V1`, `authority_dq_would_block=false`, `v1_policy_constructive_active=true`, `pre_ai_score_gates_demoted=true`, and no `regime_policy_*` or `dq_policy_*` in `final_decision_reason`. After Hard-Lock smoke confirmed, proceed to 250/500-record validation window on multi-symbol session.

- **P4 OPTION 1 DIRTY ENVIRONMENT OBSERVABILITY PATCH (2026-04-26 02:07:26) — IMPLEMENTED + COMPILE_VERIFIED + SAMPLE_ANALYSIS_COMPLETE (78 records, 2026-04-26):** DECISION-only P4 annotation added for counterfactual legacy dirty-environment would-block measurement. `performance_journal.mqh` now emits `p4_dirty_env_*` fields after P2.B dual-truth fields and before `direction`, including ERA/ExRA raw measurements, threshold evidence, divergence state, `p4_dirty_env_legacy_gate_enabled`, and `p4_dirty_env_action_taken="OBSERVED_ONLY"`. `main_ea.mq5` now computes the observation with a pure helper that ignores `EnableCouncilDirtyEnvironmentTightening` for measurement while recording its current value; legacy BUY/SELL dirty blocking branches, dirty status writers, lifecycle clearing, final decision fields, risk/governor/routing/pre-AI thresholds, and trade admission are unchanged. No dedicated dirty status artifact added. Compile log `compile_p4_dirty_environment_observability_patch_20260426_020321.log`: 0 errors / 2 unchanged pre-existing int-to-string warnings; `main_ea.ex5` timestamp 2026-04-26 02:07:26. **SAMPLE ANALYSIS (78 records):** would_block=true 29/78 (37.2%), would_block=false 49/78 (62.8%). Reason codes: PASS 49, DIRTY_LOW_TRADABILITY 9, TRANSITIONAL_LOW_COUNCIL_QUALITY 8, DIRTY_LOW_ENVIRONMENT_SCORE 6, COMPRESSION_LOW_TRADABILITY 3, REVERSAL_RISK_LOW_TRADABILITY 3. Divergence: ERA_CLEAN_EXRA_DEGRADED 43, ERA_EXRA_AGREE_DEGRADED 28, NO_DIRTY_CONTEXT 6, ERA_DIRTY_EXRA_CLEAN_OR_ROUTE_NATIVE **1 (1.3%)**. For would_block=true: REJECT 27/29 (93.1% redundant), BUY 1, SELL 1. Two live trade cases: Case 1 SELL (ERA=REVERSAL_RISK, trad=0.4485, GOOD_DECISION 0.702, R:R=2.655, execution_open_failed — gate would have blocked valid signal); Case 2 BUY (ERA=COMPRESSION, ExRA=TREND_CONTINUATION — AGENTS.md Rule 7 specimen, MARGINAL_DECISION 0.634, R:R=0.522, POOR geometry, WEAK_ENTRY, LOSS −3.65). **VERDICT: BLOCKING NOT AUTHORIZED.** ERA_DIRTY_EXRA_CLEAN divergence rate 1.3% is far below 10% acceptance threshold; 93.1% redundancy; 0 net trade benefit (Case 1 harmful + Case 2 low-quality). **NEXT MILESTONE: Extend collection to 500+ P4 records. If divergence rate stays <5% at 500 records → proceed to Option 3 design (decommission legacy gate, ExRA-only replacement). If divergence rises to ≥10% → proceed to Option 2 design (ERA+ExRA coordination clause). Do NOT enable EnableCouncilDirtyEnvironmentTightening.** P4 remains data-collection only; Options 2/3/4 and any blocking behavior require evidence sample and explicit user approval.

- **P3.2/P3.2-S SNAPSHOT CACHING REPAIR (2026-04-26) — IMPLEMENTED + COMPILE_VERIFIED:** `gHasLastSnapshots = true` now set in OnTick() success path (main_ea.mq5:13043–13045). Root cause: `CacheLastSnapshots()` defined at line 12712 but 0 callers; `gHasLastSnapshots = true` only at line 13038 (M5-failure path) — permanently false in normal operation (M5 always succeeds). Additional confirmed: plan flags in ai_current_plan.json correct and parser-reads-correctly (config_loader.mqh lines 1272–1303 match keys exactly); plan loaded at 23:12:17 and 23:26:48 after flag edit; NormalizePlanJsonString is structural-only (does not strip fields); AutoApplyPlan/AIEvolution cannot overwrite plan (same plan_id rejection + AI_OFF). Compile log `compile_snapshot_caching_repair_20260426_000744.log`: 0 errors, 2 pre-existing int→string warnings at 13860/14354 (+4 confirms only 4 lines added). EA reload required. P3.2 closure criteria: any DECISION with `decision_quality_version = "DQ_V2"/"DQ_V3"` — **RUNTIME_CONFIRMED (2026-04-26)**: DQ_V2 and DQ_V3 both present in ai_performance_journal.jsonl post-binary records. P3.2-S Fix 2 closure criteria: BUY/SELL DECISION with `expected_rr_estimate` in [0.10, 5.00] — **RUNTIME_CONFIRMED (2026-04-26)**: SELL Case 1 rr=2.655 and BUY Case 2 rr=0.522, both within [0.10, 5.00]; range guard functioning correctly, no clamping/rejection observed. P3.2 and P3.2-S Fix 2 are CLOSED. Backup: `D:\MT5_Project_Backups\pre_change_20260426_000744_snapshot_caching_repair.zip` (22,090,317 bytes).
- **P4 DIRTY ENVIRONMENT GATE — FORENSIC_READINESS + DESIGN_READY (2026-04-26):** Architecture violation confirmed from source: `EvaluateCouncilDirtyEnvironmentTightening()` (main_ea.mq5:9707) is a POST-ROUTE ERA veto of ExRA routing decisions. Gate reads `gRegime.regime_label` (ERA) and `gRegime.tradability_score` (ERA) for 3 of 5 blocking conditions; remaining 2 use ExRA council aggregate (mixed authority). Five blocking conditions target ERA labels RANGE_DIRTY/COMPRESSION/REVERSAL_RISK applied after council routing — this directly violates AGENTS.md Cross-Authority Rule 7. Gate is DORMANT (`EnableCouncilDirtyEnvironmentTightening = false`; `council_dirty_environment_status.json` absent; zero historical fire events). `CouncilTransitionalMinCouncilQuality = 0.72` default is higher than all ExRA pre-AI filter quality floors (0.55–0.58) — would block ExRA-passed decisions from a wrong authority layer. Lifecycle clear cascade on block is also contaminated. Secondary dirty-env surfaces (`risk_state_policy_engine.mqh:282,292` admission block; `strategy_intelligence_layer_v1.mqh:420–424` DIRTY_ENV flag; `execution_estimator_v1.mqh:135,149` penalties) are ERA-correct or observability-only — NOT part of the violation. Four design options defined: Option 0 (leave dormant — current), Option 1 (observability annotation only — remove `return` from BLOCK paths, write assessment to artifact), Option 2 (coordination clause — ERA+ExRA agreement required before block), Option 3 (move to ERA admission gate — architecturally correct), Option 4 (ExRA-native quality gate using `env.zone_type == COUNCIL_ZONE_RANGE_DIRTY`). Acceptance criteria set: 30+ DECISION records with ERA=RANGE_DIRTY/COMPRESSION after P3.2 runtime; ERA/ExRA cross-table; divergence rate >10% required before Options 2/3/4. P3.2 runtime confirmation is prerequisite (entry_quality_flags DIRTY_ENV cross-cut). Authorized next step: Option 1 (observability patch) AFTER P3.2 runtime confirmed. No blocking implementation authorized until empirical acceptance criteria met. Do NOT enable `EnableCouncilDirtyEnvironmentTightening` in current form.
- **POST-REPAIR STABILIZATION AUDIT (2026-04-26) — PASSED WITH MINOR NON-BLOCKING NOTES:** Full end-to-end contract audit performed against binary 2026-04-26 02:07:26 (P4 Option 1 binary, containing all patches). ALL SIX contract layers continuously emitted in fresh runtime records: C123 ✓, P2.B ERA/ExRA ✓, P3.1A scope V2 ✓ (council_ai_advisory_status.json candidate_scope=COUNCIL|V2|BUY|TREND_CONTINUATION|momentum_breakout_cont_v1), P3.1B motif key ✓, P3.2 DQ versioning ✓, P3.2-S rr_estimate ✓, P4 Option 1 OBSERVED_ONLY ✓. No authority drift: execution, governor, risk, routing, pre-AI all unchanged. No hidden veto, no lifecycle clearing from observational fields, gate dormant. Three genuine non-blocking findings: (F3) council audit linkage 0% (pre-existing gap), (F4) trade feedback close missing P3.2/P3.2-S decision link (pre-existing), (F5) sweep_detector memory anomaly (non-executing). Two stale documentation items: (F1) "Runtime freeze/no trade data flowing" risk entry now inaccurate, (F7) P3.1/P3.2 risk table rows stale. NOTE: Stabilization report also incorrectly listed F2 (P2.A TRADE double-comma) as open — this was a report error; P2.A JSON fix was FULLY_CLOSED 2026-04-22 (source confirmed at performance_journal.mqh lines 160-185; 6 recent TRADE records all strict-parse clean; AGENTS.md Rule 8 and OPERATION_GUARDRAILS.md risk table entry are stale documentation needing governance maintenance). No source edits required. **Active execution blocker: NONE. P4 extended collection is NOT the active execution objective.** **Governance contradiction audit (2026-04-26) resolved three report errors in the stabilization report — see below.** Next candidate: **PLAN-5 Shadow Validation Design** (shadow-testing C1/C2/C3 structural corrections — NOT "Version 1 Shadow Feasibility"; those are distinct tracks). Version 1 (Decision State Composer / Policy Matrix / Hierarchical Gate-and-Policy) is a future program with no formal PIML entry; must be separately scoped before any feasibility work begins.
- **Latest implementation milestone (2026-04-25 15:37:51):** P3.1A+B AI advisory + institutional learning deconfliction bundle IMPLEMENTED + COMPILE_VERIFIED. P3.1B RUNTIME_CONFIRMED (2026-04-26): BUY DECISION `BTCUSD-1777194109-100423-83` contains `learning_motif_key=keyver=2|strategy=momentum_breakout_cont_v1|direction=BUY|regime=COMPRESSION|zone=TREND_CONTINUATION|vol=HIGH_VOL|struct=CLEAN|setup=SETUP_NEUTRAL|sr=SR_SEMANTIC|contradiction=0` — keyver=2 ✓, zone=TREND_CONTINUATION (ExRA-keyed) ✓, learning motif no longer keyed solely by gRegime bucket. P3.1A (V2 advisory scope format) RUNTIME_CONFIRMED (2026-04-25 16:51:37 per Section 7.2 + confirmed 2026-04-26 via council_ai_advisory_status.json candidate_scope="COUNCIL|V2|BUY|TREND_CONTINUATION|momentum_breakout_cont_v1"): scope key is built and written to council_ai_advisory_status.json on every BUY/SELL candidate bar regardless of ATAS attachment state; ATAS darkness does not prevent scope key emission; correct confirmation artifact is council_ai_advisory_status.json not DECISION records. Source changes: council AI advisory scope now `COUNCIL|V2|<direction>|<zone_text>|<best_strategy_id>` and advisory signature now `V2|<direction>|<zone_text>|<strategy_family>|<best_strategy_id>` using council zone as ExRA primary key in valid council context; `zone_semantic` removed from advisory identity key material. Institutional learning now carries `zone_bucket` in `ILV1_DecisionContext`, persists/parses it in decision context records, and builds motif keys as `keyver=2|strategy=...|direction=...|regime=...|zone=...|vol=...|struct=...|setup=...|sr=...|contradiction=...`. Transition policy: clean V2 silent orphaning; no migration, no backfill, no dual-read, no v1 compatibility bridge. Compile log `compile_p3_1ab_advisory_learning_deconfliction_20260425_153348.log`: 0 errors / 2 unchanged pre-existing warnings; `main_ea.ex5` timestamp 2026-04-25 15:37:51. No execution/risk/governor/routing/pre-AI/P3.2/P4 authority change.

- **PLAN-5 execution update (2026-04-23 06:40:20; supersedes older PLAN-5 wording above where they differ):** `IMPLEMENTATION_SURFACES_REPAIRED + COMPILE_VERIFIED + OBSERVATION_OPEN`. Governed backup: `D:\MT5_Project_Backups\pre_change_20260423_061358_c123_obstacle_repair.zip` (2938 selected files / 2938 archive entries / 18,230,809 bytes). C1/C2/C3 evidence contract is now wired through governor, pre-AI gate, decision snapshot, diagnostic runtime summary, and DECISION-only journal emission. C1 remains behaviorally unresolved and is emitted only as a shadowed pre-governor candidate condition; C2 is now durably observable/traceable once the next decision emits; C3 is now durably checkable once the next TC+low-structure case emits. Compile log `compile_c123_obstacle_repair_20260423_064120.log`: 0 errors, 2 unchanged warnings.
- **Immediate next step override (2026-04-23):** Capture the first post-compile runtime emission from the rebuilt 06:40 binary and verify the new C1/C2/C3 evidence contract end to end in all three target surfaces: `council_feedback.json` DECISION_SNAPSHOT, `ai_performance_journal.jsonl` DECISION, and `diagnostic_runtime_summary.json`. Only after those fields are observed and strict-parsed live should the project declare the blocker-doctrine implementation surfaces fully live or restate the downstream P2.B gate.
- **Latest milestone addendum (2026-04-23 06:40:20):** PLAN-5 truthful obstacle-repair implementation surfaces compile-verified. `council_ai_governor.mqh`, `council_pre_ai_filter.mqh`, `council_mode_runtime.mqh`, `council_feedback.mqh`, `council_memory.mqh`, `performance_journal.mqh`, `main_ea.mq5`, and `council_mode_types.mqh` now emit or carry C1 atomic pre-governor ingredients plus shadowing, C2 overextension tightening before/after thresholds plus local effect flag, C3 low-structure TC logic/effect flags, and compact `c123_obstacle_*` summary/version fields. `terminal64` was not running after compile, so current `council_feedback.json` (04:50), `diagnostic_runtime_summary.json` (04:53), and latest DECISION in `ai_performance_journal.jsonl` (04:54) strict-parse successfully but predate the rebuilt 06:40 binary and therefore do not yet prove live emission of the new fields.
- **GOVERNANCE DOCS MAINTENANCE + PLAN-5 STAGE IDENTITY RESOLVED (2026-04-26):** AGENTS.md Rule 8 corrected: P2.A FULLY_CLOSED — double-comma defect repaired 2026-04-22, current TRADE records parse cleanly, pre-fix historical records require substring/regex workaround only. OPERATION_GUARDRAILS.md: "Malformed journal" risk row → RESOLVED; "Runtime freeze active — no trade data flowing" description → corrected (strategy_transfer policy lock, trades ARE flowing); P3.1A/P3.1B/P3.2/P3.3 risk rows → RESOLVED; Three-chain guardrails item 4 → updated with P2.A RESOLVED note. Backup: `D:\MT5_Project_Backups\pre_change_20260426_121526_governance_docs_p2a_stage_identity_cleanup.zip` (2946 files, 17,149,165 bytes). **PLAN-5 Stage 2 identity resolved:** C1/C2/C3 Shadow Validation Design = **PLAN-5 Stage 2 — Acceptance Criteria Rewrite + Shadow Validation Design** — NOT a new separate plan. Stage 1 forensic re-evaluation IS the gate that opens Stage 2. Stage 2 deliverables (design-only; no source edits without authorization): (1) rewrite C1/C2/C3 acceptance criteria; (2) design shadow-mode behavioral corrections (council_ai_governor.mqh + council_pre_ai_filter.mqh); (3) define shadow observation gate. State: DESIGN_IDENTIFIED — authorization required before Stage 2 design session opens.

---

## 1. MASTER PROJECT IDENTITY

### 1.1 Official System Identity

- System Name:
- Official Runtime Identity:
- Official Architectural Identity:
- Operational Mode:
- Current Strategic Decision:

### 1.2 Project Mission

- Primary mission:
- Operational mission:
- Intelligence mission:
- Governance mission:

### 1.3 System-Level Boundaries

- What the system is:
- What the system is not:
- What is inside authority:
- What is outside authority:

### 1.4 Runtime Truth Summary

- Core runtime owner:
- Execution authority owner:
- Risk authority owner:
- External shadow role:
- Preserved but non-active branches:

### 1.5 Current Global Status

- Current stage:
- Current frozen baseline:
- Current active development program:
- Current deferred branches:

---

## 2. MASTER ARCHITECTURE TREE

> This section is the deepest available architecture map of the project. It is the backbone against which all future functional, dependency, edge, and risk sections will be anchored.
>
> Truth status: CONFIRMED_SOURCE_TRUTH unless marked otherwise.
> All nodes populated from direct source inspection (2026-04-18).

---

### 2.0 Architecture Tree Rules

Every node includes: node ID | name | type | parent | purpose | authority relation | dependencies | main files | main outputs.

Truth markers used per node:
- CONFIRMED_RUNTIME_TRUTH — verified from runtime surfaces
- CONFIRMED_SOURCE_TRUTH — verified from source code inspection
- CONFIRMED_ARCHITECTURAL_DECISION — explicit design decision
- WORKING_ASSUMPTION — inferred but not fully proven
- HISTORICAL_CONTEXT — past state, no longer primary
- DEFERRED_PATH — planned but not yet active

---

### 2.1 Root Architecture Tree

---

#### ARCH-1 — Core Runtime Architecture

- **Node ID**: ARCH-1
- **Name**: Core Runtime Architecture
- **Type**: ROOT DOMAIN
- **Parent**: none
- **Purpose**: All surfaces that directly own, gate, or execute trading actions. Runtime authority hierarchy. The MT5 process is sole execution authority. All other domains serve or feed this domain but cannot override it.
- **Authority relation**: EXECUTION_AUTHORITY
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-1.1, ARCH-1.2, ARCH-1.3

---

#### ARCH-1.1 — MT5 Runtime Entry Point

- **Node ID**: ARCH-1.1
- **Name**: MT5 Runtime Entry Point
- **Type**: EXECUTION AUTHORITY SURFACE
- **Parent**: ARCH-1
- **Purpose**: The sole runtime owner. Owns the event loop (OnTick, OnDeinit, OnInit). Orchestrates all downstream calls. No other file holds execution authority.
- **Authority relation**: PRIMARY EXECUTION AUTHORITY — cannot be delegated or bypassed
- **Dependencies**: all downstream stacks via include chain
- **Main files**: `main_ea.mq5`
- **Main outputs**: trade orders (BUY/SELL/none), runtime status emissions, dashboard updates
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-1.1.1, ARCH-1.1.2, ARCH-1.1.3

---

#### ARCH-1.1.1 — OnTick Decision Loop

- **Node ID**: ARCH-1.1.1
- **Name**: OnTick Decision Loop
- **Type**: RUNTIME ENTRY FUNCTION
- **Parent**: ARCH-1.1
- **Purpose**: Per-tick orchestration. Calls the decision mode router, receives RoutedRuntimeEvaluation, applies risk policy check, calls level awareness brake, executes or withholds trade. Single point where all intelligence stacks converge to produce a binary trade/no-trade outcome.
- **Authority relation**: EXECUTION AUTHORITY — sole call site for trade submission
- **Dependencies**: ARCH-1.2 (governance chain), ARCH-2 (intelligence stacks), ARCH-1.3 (risk/brake)
- **Main files**: `main_ea.mq5`
- **Main outputs**: `CTrade` order submission or no-op
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.1.2 — Trade Execution Bridge

- **Node ID**: ARCH-1.1.2
- **Name**: Trade Execution Bridge
- **Type**: EXECUTION UTILITY
- **Parent**: ARCH-1.1
- **Purpose**: Wraps MT5 CTrade order submission with symbol-normalized price math, stop validation, and position sizing. Handles entry/SL/TP level computation.
- **Authority relation**: EXECUTION_AUTHORITY (delegated from OnTick, within MT5 only)
- **Dependencies**: MT5 CTrade library
- **Main files**: `core_trade_engine.mqh`
- **Main outputs**: normalized TradeLevels struct, order execution result
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.1.3 — Input Parameter Layer

- **Node ID**: ARCH-1.1.3
- **Name**: Input Parameter Layer
- **Type**: CONFIGURATION SURFACE
- **Parent**: ARCH-1.1
- **Purpose**: MT5 input parameters that gate optional features (council setup lifecycle, execution quality gate, activation pressure gate, lot size, magic number). All council feature flags live here as opt-in inputs, default OFF.
- **Authority relation**: PLAN_OR_CONFIGURATION_AUTHORITY
- **Main files**: `main_ea.mq5` (input declarations), `config_loader.mqh` (compiled plan consumption)
- **Main outputs**: feature gate booleans, CompiledPlan struct population
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.2 — Runtime Governance Chain

- **Node ID**: ARCH-1.2
- **Name**: Runtime Governance Chain
- **Type**: GOVERNANCE DOMAIN
- **Parent**: ARCH-1
- **Purpose**: Controls how the runtime decides what mode to operate in, what plan parameters to follow, and what policy state applies to admissions. Not the execution authority itself — feeds the execution authority.
- **Authority relation**: PLAN_OR_CONFIGURATION_AUTHORITY + governance enforcement
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-1.2.1, ARCH-1.2.2, ARCH-1.2.3

---

#### ARCH-1.2.1 — Plan and Config Authority

- **Node ID**: ARCH-1.2.1
- **Name**: Plan and Config Authority
- **Type**: CONFIGURATION AUTHORITY
- **Parent**: ARCH-1.2
- **Purpose**: Loads the compiled trading plan (CompiledPlan struct). Defines decision engine mode (GATE/SCORE/HYBRID/COUNCIL), strategy cohort, active strategies list, council flags, adaptive weight flags. Is the source of plan-level runtime configuration.
- **Authority relation**: PLAN_OR_CONFIGURATION_AUTHORITY
- **Dependencies**: none (reads config files)
- **Main files**: `config_loader.mqh`
- **Main outputs**: `CompiledPlan` struct consumed by decision router and strategies
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.2.2 — Decision Mode Router

- **Node ID**: ARCH-1.2.2
- **Name**: Decision Mode Router
- **Type**: ROUTING AUTHORITY
- **Parent**: ARCH-1.2
- **Purpose**: Dispatches the per-tick evaluation to the appropriate decision engine based on `CompiledPlan.decision_engine_mode`. Modes: GATE, SCORE, HYBRID, COUNCIL. COUNCIL is the primary active mode. Produces unified `RoutedRuntimeEvaluation` that feeds OnTick.
- **Authority relation**: RUNTIME routing authority — does not hold execution authority itself
- **Dependencies**: ARCH-1.2.1 (plan), ARCH-2.3 (council pipeline), ARCH-4.6 (legacy strategy runtime for non-council modes)
- **Main files**: `decision_mode_router.mqh`
- **Main outputs**: `RoutedRuntimeEvaluation` (active_mode, base_eval, council result, summary)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.2.3 — Risk Policy Engine

- **Node ID**: ARCH-1.2.3
- **Name**: Risk Policy Engine
- **Type**: RISK GOVERNANCE
- **Parent**: ARCH-1.2
- **Purpose**: Computes global policy state from trade performance signals (streaks, underperformance, drawdown). Produces `RiskPolicySnapshot` (NORMAL/CAUTIOUS/DEFENSIVE/LOCKDOWN/RECOVERY) which adjusts confidence minimums and may hard-block new trades.
- **Authority relation**: RISK_AUTHORITY — can block trade admission, cannot generate trades
- **Dependencies**: `performance_memory.mqh`, `journal_analytics.mqh`, `unified_confidence.mqh`, `regime_classification_layer_v1.mqh`
- **Main files**: `risk_state_policy_engine.mqh`
- **Main outputs**: `RiskPolicySnapshot` struct (state, extra_confidence_min, block_new_trades)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.3 — Risk / Admission / Block Surfaces

- **Node ID**: ARCH-1.3
- **Name**: Risk / Admission / Block Surfaces
- **Type**: ADMISSION CONTROL DOMAIN
- **Parent**: ARCH-1
- **Purpose**: All surfaces that can produce HARD_REJECT or BLOCK outcomes before a trade is submitted. These surfaces have veto authority over individual trade candidates but do not generate trade direction themselves.
- **Authority relation**: VETO_AUTHORITY over individual trades — not trade generation authority
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-1.3.1, ARCH-1.3.2, ARCH-1.3.3

---

#### ARCH-1.3.1 — Risk Policy Admission Gate

- **Node ID**: ARCH-1.3.1
- **Name**: Risk Policy Admission Gate
- **Type**: HARD BLOCK SURFACE
- **Parent**: ARCH-1.3
- **Purpose**: Applies `RiskPolicySnapshot.block_new_trades` flag. If policy state is LOCKDOWN, no new trades are submitted regardless of council decision. Also applies extra confidence/tradability minimums in cautious/defensive states.
- **Authority relation**: RISK_AUTHORITY — hard block capability
- **Main files**: `risk_state_policy_engine.mqh`, `main_ea.mq5` (application site)
- **Main outputs**: block / allow decision at admission checkpoint
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-1.3.2 — Level Awareness Brake (SVS Layer 6 Brake)

- **Node ID**: ARCH-1.3.2
- **Name**: Level Awareness Brake
- **Type**: STRUCTURAL HARD-REJECT SURFACE
- **Parent**: ARCH-1.3
- **Purpose**: Final structural veto before order submission. Consumes SVS structural zone intelligence. Evaluates 6 brake rules (A–F) against the trade direction and structural environment. Binary output: ALLOW or HARD_REJECT. Is SVS Layer 6 in the Structural Visibility Stack.
- **Authority relation**: VETO_AUTHORITY — structural hard-reject only, never generates trade direction
- **Dependencies**: ARCH-2.2 (SVS engine + query interface), ARCH-2.3 (rt council result for exhaustion_warning, zone_semantic)
- **Main files**: `level_awareness_brake.mqh`
- **Main outputs**: `LevelAwarenessBrakeReport` (brake_verdict ALLOW/HARD_REJECT, brake_reason_code, location_context_summary, structural_profile)
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Cross-ref**: ARCH-2.2.7 (brake consumption as SVS layer)

---

#### ARCH-1.3.3 — Council Pre-AI Filter

- **Node ID**: ARCH-1.3.3
- **Name**: Council Pre-AI Filter
- **Type**: COUNCIL QUALITY GATE
- **Parent**: ARCH-1.3
- **Purpose**: Enforces minimum quality thresholds on the council aggregate before the final council decision is accepted. Adaptive thresholds per zone type, consensus type, family diversity. Can produce REJECT outcome for weak council cases. Primary enforcement point for council admission quality.
- **Authority relation**: VETO_AUTHORITY within council pipeline — rejects low-quality council cases
- **Dependencies**: ARCH-2.3.3 (aggregate report), ARCH-2.3.1 (environment report)
- **Main files**: `council_pre_ai_filter.mqh`
- **Main outputs**: `CouncilPreAIGateReport` (passed bool, filtered_decision, thresholds applied, reason)
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Cross-ref**: ARCH-2.3.4

---

#### ARCH-2 — Intelligence Stacks

- **Node ID**: ARCH-2
- **Name**: Intelligence Stacks
- **Type**: ROOT DOMAIN
- **Parent**: none (sibling of ARCH-1)
- **Purpose**: All systems that produce structured intelligence to inform, guide, filter, or veto trading decisions. None of these stacks hold execution authority — they are advisory and enforcement-support systems.
- **Authority relation**: INTELLIGENCE_SUPPORT only — feeds ARCH-1, never replaces it
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.1 (CEIS), ARCH-2.2 (SVS), ARCH-2.3 (Council)

---

#### ARCH-2.1 — CEIS — Council Exhaustion Intelligence Stack

- **Node ID**: ARCH-2.1
- **Name**: CEIS — Council Exhaustion Intelligence Stack
- **Type**: INTELLIGENCE STACK
- **Parent**: ARCH-2
- **Purpose**: Detects market exhaustion across multiple timeframes and horizons. Produces a 7-signal composite exhaustion reading that feeds into aggregator, pre-AI filter, failure detector, and council quality scoring. Cleanly separable from SVS — one read-only touchpoint in brake (Rule C exhaustion_warning via aggregate).
- **Authority relation**: INTELLIGENCE_SUPPORT — advisory, non-authoritative. Cannot generate trades.
- **CEIS/SVS boundary**: CLEANLY_SEPARABLE. Brake reads `rt.aggregate.exhaustion_warning` (Rule C) only. CEIS reads no SVS fields.
- **Main files**: `council_environment.mqh` (CEIS signal computation embedded in env builder)
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.1.1, ARCH-2.1.2, ARCH-2.1.3, ARCH-2.1.4

---

#### ARCH-2.1.1 — CEIS Environment Report Producer

- **Node ID**: ARCH-2.1.1
- **Name**: CEIS Environment Report Producer
- **Type**: SIGNAL COMPUTATION HOST
- **Parent**: ARCH-2.1
- **Purpose**: The `BuildCouncilEnvironmentReport()` function in `council_environment.mqh` is the CEIS computation host. It computes all 7 CEIS sub-signals, assembles the composite `ceis_source_score`, and embeds them into `CouncilEnvironmentReport`. CEIS is architecturally co-located with the environment layer, not a separate file.
- **Authority relation**: INTELLIGENCE_SUPPORT
- **Main files**: `council_environment.mqh`
- **Main outputs**: Populated CEIS fields inside `CouncilEnvironmentReport`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2 — CEIS Sub-Signal Layer (7 signals)

- **Node ID**: ARCH-2.1.2
- **Name**: CEIS Sub-Signal Layer
- **Type**: MULTI-HORIZON SIGNAL ARRAY
- **Parent**: ARCH-2.1
- **Purpose**: The 7 discrete exhaustion sub-signals, each targeting a distinct market horizon. Each is a bool field in `CouncilEnvironmentReport`. Together they feed the composite `ceis_source_score`.
- **Authority relation**: INTELLIGENCE_SUPPORT
- **Main files**: `council_environment.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.1.2.1 through ARCH-2.1.2.7

---

#### ARCH-2.1.2.1 — M1 Spike Reversal Signal

- **Node ID**: ARCH-2.1.2.1
- **Name**: M1 Spike Reversal Signal
- **Type**: TACTICAL SIGNAL (M1 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: Detects M1 wick-dominant candle with high volume and high momentum — candle-pattern exhaustion evidence. Preserved as the original `exhaustion_hint` signal (pre-CEIS evolution). Weight: highest tactical relevance.
- **Field**: `ceis_spike_reversal_m1` (also surfaces as `exhaustion_hint` for legacy consumption)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2.2 — M5 EMA Overextension Signal

- **Node ID**: ARCH-2.1.2.2
- **Name**: M5 EMA Overextension Signal
- **Type**: STRUCTURAL SIGNAL (M5 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: Detects M5 price distance from EMA20 >= 2.0 * ATR14_M5. Identifies price that has moved too far from mean — prone to mean reversion. Primary LATE_CONTINUATION_FAILURE protection signal.
- **Field**: `ceis_overextension_m5`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2.3 — M5 MFI Exhaustion Signal

- **Node ID**: ARCH-2.1.2.3
- **Name**: M5 MFI Exhaustion Signal
- **Type**: MOMENTUM SIGNAL (M5 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: M5 Money Flow Index turning from extreme (declining from >55 or rising from <45). Detects tactical momentum reversal at M5 level. Does NOT fire hard gates alone — requires M15 confluence for tactical gates.
- **Field**: `ceis_mfi_exhaustion_m5`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2.4 — M15 MFI Exhaustion Signal

- **Node ID**: ARCH-2.1.2.4
- **Name**: M15 MFI Exhaustion Signal
- **Type**: MOMENTUM SIGNAL (M15 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: M15 MFI turning from extreme (same logic, higher stability than M5). Provides medium-term momentum confirmation. M5+M15 MFI confluence fires tactical gates (single M5 MFI alone does not — avoids single-horizon flicker).
- **Field**: `ceis_mfi_exhaustion_m15`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2.5 — H1 MFI Structural Exhaustion Signal

- **Node ID**: ARCH-2.1.2.5
- **Name**: H1 MFI Structural Exhaustion Signal
- **Type**: STRUCTURAL SIGNAL (H1 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: H1 MFI at extreme (>65 or <35, strict thresholds). Multi-hour structural overbought/oversold context. Fires independently in aggregator exhaustion_warning — H1 structural exhaustion is architecturally sufficient context regardless of M5 tactical state.
- **Field**: `ceis_mfi_exhaustion_h1`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2.6 — H4 MFI Context Signal

- **Node ID**: ARCH-2.1.2.6
- **Name**: H4 MFI Context Signal
- **Type**: MACRO CONTEXT SIGNAL (H4 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: H4 MFI at extreme turning (>68 or <32, most strict). Macro structural context only. Contributes to `ceis_source_score` only — does NOT fire tactical gates directly. Provides macro weight to composite score.
- **Field**: `ceis_mfi_context_h4`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.2.7 — M5 Momentum Fade Signal

- **Node ID**: ARCH-2.1.2.7
- **Name**: M5 Momentum Fade Signal
- **Type**: VELOCITY SIGNAL (M5 horizon)
- **Parent**: ARCH-2.1.2
- **Purpose**: M5 ATR14 velocity loss — current ATR < prior-8-bars ATR * 0.78. Detects weakening impulse/expansion momentum. Contributes to `ceis_source_score` only — does not fire independent tactical gates.
- **Field**: `ceis_momentum_fade_m5`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.3 — CEIS Composite Score

- **Node ID**: ARCH-2.1.3
- **Name**: CEIS Composite Score
- **Type**: WEIGHTED COMPOSITE OUTPUT
- **Parent**: ARCH-2.1
- **Purpose**: `ceis_source_score` (0..1): weighted sum of all 7 sub-signals, clamped. `ceis_signal_count`: count of active sub-signals (0..7). These continuous values replace the old binary `exhaustion_hint` for graded CEIS consumption (e.g. failure detector exhaustion risk now uses `ceis_source_score * 0.20` instead of binary).
- **Fields**: `ceis_source_score`, `ceis_signal_count`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.4 — CEIS Consumption Points

- **Node ID**: ARCH-2.1.4
- **Name**: CEIS Consumption Points
- **Type**: CROSS-STACK INTERFACE MAP
- **Parent**: ARCH-2.1
- **Purpose**: Documents where CEIS signals are consumed across the pipeline.
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.1.4.1 through ARCH-2.1.4.4

---

#### ARCH-2.1.4.1 — Aggregator Exhaustion Warning Composition

- **Node ID**: ARCH-2.1.4.1
- **Name**: Aggregator Exhaustion Warning Composition
- **Type**: CONSUMPTION POINT
- **Parent**: ARCH-2.1.4
- **Purpose**: `council_aggregator.mqh` composes `outReport.exhaustion_warning` from 7 sources: strategy-vote paths (EXHAUSTION_JUDGE ACTIVE/REDUCED + zone_align), EXHAUSTION_JUDGE OBSERVE_ONLY in TREND_CONTINUATION (signal routing only), `env.exhaustion_hint`, `env.ceis_overextension_m5`, M5+M15 MFI confluence, `env.ceis_mfi_exhaustion_h1`. This composite bool flows into pre-AI filter and council quality penalty.
- **Main files**: `council_aggregator.mqh` lines 364-368
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.4.2 — Pre-AI Filter Exhaustion Tightening Gate

- **Node ID**: ARCH-2.1.4.2
- **Name**: Pre-AI Filter Exhaustion Tightening Gate
- **Type**: CONSUMPTION POINT
- **Parent**: ARCH-2.1.4
- **Purpose**: In `council_pre_ai_filter.mqh`: if exhaustion_warning active in TREND_CONTINUATION or BREAKOUT_EXPANSION zone, raise min_required_council_quality by +0.04 and lower max_allowed_conflict by -0.10. Tightens the pre-AI gate under exhaustion conditions.
- **Main files**: `council_pre_ai_filter.mqh` lines 111-126
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.4.3 — Failure Detector Exhaustion Risk Scoring

- **Node ID**: ARCH-2.1.4.3
- **Name**: Failure Detector Exhaustion Risk Scoring
- **Type**: CONSUMPTION POINT
- **Parent**: ARCH-2.1.4
- **Purpose**: `council_failure_detector.mqh` uses `ceis_source_score * 0.20` (continuous graded signal, replaces old binary 0.20) + `agg.exhaustion_warning * 0.15` for exhaustion_ignore_risk_score computation. CEIS evolution replaced binary exhaustion_hint with graded ceis_source_score here.
- **Main files**: `council_failure_detector.mqh` lines 225-232
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.1.4.4 — Council Quality CEIS Penalty

- **Node ID**: ARCH-2.1.4.4
- **Name**: Council Quality CEIS Penalty
- **Type**: CONSUMPTION POINT
- **Parent**: ARCH-2.1.4
- **Purpose**: `council_aggregator.mqh` applies stacked CEIS penalties to `council_quality` in TREND_CONTINUATION zone: base -0.08 (exhaustion_warning), +(-0.04) for ceis_overextension_m5, +(-0.03) for ceis_mfi_exhaustion_h1. In REVERSAL_EXHAUSTION zone: +0.04 bonus. Maximum stacked penalty: -0.15.
- **Main files**: `council_aggregator.mqh` lines 410-429
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2 — SVS — Structural Visibility Stack

- **Node ID**: ARCH-2.2
- **Name**: SVS — Structural Visibility Stack
- **Type**: INTELLIGENCE STACK
- **Parent**: ARCH-2
- **Purpose**: Detects, maintains, and exposes structural price-level obstacles (support/resistance zones) for brake enforcement. Formal identity: COHERENT_STACK with 6 ordered layers. Functional mission: detect structural price-level obstacles and enforce hard-brake rejection before order submission. Does not generate trade direction.
- **Authority relation**: INTELLIGENCE_SUPPORT (layers 1-5) + VETO_AUTHORITY via brake (layer 6)
- **Class contract**: ENRICHMENT_WITH_LEGACY_CLASS_CONTRACT. Hard-brake gate = `opposeClass >= ZONE_STRONG` (≥50.0 strength score). Thresholds: WEAK<28, MEDIUM≥28, STRONG≥50, MAJOR≥75. Preserved through Slice 1+2.
- **Main files**: `structural_sr_engine.mqh` (layers 1-6 engine), `level_awareness_brake.mqh` (layer 6 consumption)
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.2.1 through ARCH-2.2.7

---

#### ARCH-2.2.1 — SVS Layer 1 — Raw Candidate Acquisition

- **Node ID**: ARCH-2.2.1
- **Name**: SVS Layer 1 — Raw Candidate Acquisition
- **Type**: DATA ACQUISITION LAYER
- **Parent**: ARCH-2.2
- **Purpose**: `SRE_ScanTF()` scans a single timeframe for N=3 confirmed swing pivots (local high/low with N bars on each side confirming). For each pivot, initializes a `StructuralZone` with geometric bounds (ATR-width), touch count=1, rejection/moveaway scores, and all 7 Slice 1 enrichment fields (freshness, persistence, credibility, openness, crowding_penalty, zone_tested, source_tf_rank). Also runs a 20-bar credibility scan per pivot to detect approach evidence.
- **Authority relation**: DATA only — no brake authority
- **Quota enforcement**: `maxContribution` parameter caps how many raw candidates this TF adds to the shared pool
- **Main files**: `structural_sr_engine.mqh` — `SRE_ScanTF()` function
- **Main outputs**: raw resistance/support zone arrays (pre-cluster)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.2 — SVS Layer 2 — Candidate Pool Management

- **Node ID**: ARCH-2.2.2
- **Name**: SVS Layer 2 — Candidate Pool Management
- **Type**: POOL MANAGEMENT LAYER
- **Parent**: ARCH-2.2
- **Purpose**: `SRE_UpdateZones()` manages the raw candidate pool. Scan order H4→H1→M15→M5 guarantees higher-TF zones enter pool first. Pool size: SRE_MAX_ZONES * 6 = 48 slots. Per-TF quotas: H4=8, H1=12, M15=16, M5=12. Also calls clustering, confluence, post-promotion, and diagnostic builder in sequence.
- **Authority relation**: DATA only
- **Key fix (Slice 1)**: Prior state was H1→M15→M5 with shared 32-slot pool and no per-TF quota — H4 absent, H1 zones frequently starved. Fixed by scan-order resequence + quota allocation.
- **Main files**: `structural_sr_engine.mqh` — `SRE_UpdateZones()`
- **Main outputs**: populated raw pool arrays → feeds Layer 3
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.3 — SVS Layer 3 — Clustering and Promotion

- **Node ID**: ARCH-2.2.3
- **Name**: SVS Layer 3 — Clustering and Promotion
- **Type**: ZONE PROMOTION LAYER
- **Parent**: ARCH-2.2
- **Purpose**: `SRE_ClusterAndPromote()` merges raw pivots within ATR*0.40 cluster threshold. Requires `touch_count >= 2` for promotion (quality gate). Averages rejection, moveaway, freshness, persistence, credibility scores. Takes max source_tf_rank across merged cluster. Caps output at SRE_MAX_ZONES=8 per side, sorted by `total_strength` descending.
- **Strength formula (Slice 1, 9 components)**: tc*0.22 + rejection*0.18 + moveaway*0.12 + TFWeight*0.15 + recency*0.08 + confluence*0.05 + freshness*0.08 + persistence*0.05 + credibility*0.07 = 1.00. Scale *100.
- **Class thresholds**: WEAK<28, MEDIUM≥28, STRONG≥50, MAJOR≥75 — UNCHANGED through Slice 1.
- **Main files**: `structural_sr_engine.mqh` — `SRE_ClusterAndPromote()`, `SRE_ComputeStrength()`, `SRE_AssignClass()`
- **Main outputs**: promoted zone arrays (max 8 per side) with class assignments
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.4 — SVS Layer 4 — Multi-TF Confluence Marking

- **Node ID**: ARCH-2.2.4
- **Name**: SVS Layer 4 — Multi-TF Confluence Marking
- **Type**: CONFLUENCE DETECTION LAYER
- **Parent**: ARCH-2.2
- **Purpose**: `SRE_MarkConfluence()` checks promoted zones against each other within cluster threshold. If resistance zones from different timeframes align within ATR*0.40, both are marked `multi_tf_confluent=true`, `confluence_score=1.0`, and strength/class recomputed. Strengthens zones that are confirmed across TF boundaries.
- **Authority relation**: DATA — enriches zone quality, no brake authority
- **Main files**: `structural_sr_engine.mqh` — `SRE_MarkConfluence()`
- **Main outputs**: confluence flags and updated strength/class on promoted zones
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.5 — SVS Layer 5 — Post-Promotion Semantics

- **Node ID**: ARCH-2.2.5
- **Name**: SVS Layer 5 — Post-Promotion Semantics
- **Type**: SEMANTIC ENRICHMENT LAYER (Slice 1 addition)
- **Parent**: ARCH-2.2
- **Purpose**: `SRE_ComputePostPromotionSemantics()` runs after clustering and confluence to compute two semantic fields that require the full promoted zone set to be available.
- **Authority relation**: DATA — enriches zone semantics, no brake authority
- **Main files**: `structural_sr_engine.mqh` — `SRE_ComputePostPromotionSemantics()`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.2.5.1, ARCH-2.2.5.2

---

#### ARCH-2.2.5.1 — Crowding Penalty Computation

- **Node ID**: ARCH-2.2.5.1
- **Name**: Crowding Penalty Computation
- **Type**: SEMANTIC FIELD
- **Parent**: ARCH-2.2.5
- **Purpose**: For each promoted zone, counts peer zones within 3*ATR on the same side. `crowding_penalty = min(1.0, n/3.0)`. Identifies structurally dense areas where multiple zones compete — zones in dense clusters have reduced individual reliability.
- **Field**: `crowding_penalty` (0..1)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.5.2 — Openness Score Computation

- **Node ID**: ARCH-2.2.5.2
- **Name**: Openness Score Computation
- **Type**: SEMANTIC FIELD
- **Parent**: ARCH-2.2.5
- **Purpose**: For each resistance zone, measures gap to nearest support zone below it, normalized by 5*ATR. `openness_score = min(1.0, gap/(ATR*5.0))`. High openness = clear space on far side = trade has more room if this zone breaks. No opposing zone below = fully open (1.0). Symmetric for support zones (gap to nearest resistance above).
- **Field**: `openness_score` (0..1)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.6 — SVS Layer 6 — Structural Query Interface

- **Node ID**: ARCH-2.2.6
- **Name**: SVS Layer 6 — Structural Query Interface
- **Type**: QUERY API LAYER
- **Parent**: ARCH-2.2
- **Purpose**: Read-only access functions over the promoted zone arrays. The clean boundary between the SRE engine and all consumers (brake, diagnostics). Consumers must use query functions — never access zone arrays directly.
- **Authority relation**: DATA — query-only, no mutation
- **Main files**: `structural_sr_engine.mqh` — query functions
- **Global diagnostic**: `gSRELastUpdateSummary` (pool counts + class distribution, updated per bar)
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.2.6.1 through ARCH-2.2.6.4

---

#### ARCH-2.2.6.1 — Class Query Functions

- **Node ID**: ARCH-2.2.6.1
- **Name**: Class Query Functions
- **Type**: QUERY FUNCTIONS
- **Parent**: ARCH-2.2.6
- **Purpose**: Return the `StructuralZoneClass` of the nearest zone above/below price. Used by brake to determine `opposeIsStructural` (gate = `>= ZONE_STRONG`). Also used for backing zone class in Slice 2.
- **Functions**: `SRE_NearestResistanceClass(price)`, `SRE_NearestSupportClass(price)`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.6.2 — Distance Query Functions

- **Node ID**: ARCH-2.2.6.2
- **Name**: Distance Query Functions
- **Type**: QUERY FUNCTIONS
- **Parent**: ARCH-2.2.6
- **Purpose**: Return the price level (zone_low or zone_high) of the nearest non-broken/non-stale zone of ANY class. Used for distance/room computations in brake. Excludes BROKEN and STALE status zones.
- **Functions**: `SRE_NearestResistanceAny(price)`, `SRE_NearestSupportAny(price)`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.6.3 — Hard Brake Query Functions

- **Node ID**: ARCH-2.2.6.3
- **Name**: Hard Brake Query Functions
- **Type**: QUERY FUNCTIONS
- **Parent**: ARCH-2.2.6
- **Purpose**: Return price level of nearest STRONG or MAJOR zone only (hardOnly=true path). Used for original hard-brake level identification in legacy brake logic.
- **Functions**: `SRE_NearestStructuralResistance(price, hardOnly)`, `SRE_NearestStructuralSupport(price, hardOnly)`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.6.4 — Slice 1 Enrichment Query Functions

- **Node ID**: ARCH-2.2.6.4
- **Name**: Slice 1 Enrichment Query Functions
- **Type**: QUERY FUNCTIONS (Slice 1 addition)
- **Parent**: ARCH-2.2.6
- **Purpose**: Return Slice 1 enrichment field values (freshness, credibility, openness) for the nearest opposing zone. Direction-aware: `direction > 0` → resistance above (opposing for BUY), `direction < 0` → support below (opposing for SELL). Calling with opposite direction sign yields backing zone values.
- **Functions**: `SRE_NearestOpposingFreshness(price, direction)`, `SRE_NearestOpposingCredibility(price, direction)`, `SRE_NearestOpposingOpenness(price, direction)`
- **First consumed by**: ARCH-2.2.7 (Level Awareness Brake, Slice 2)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.7 — SVS Layer 6 — Brake Consumption

- **Node ID**: ARCH-2.2.7
- **Name**: SVS Layer 6 — Brake Consumption
- **Type**: HARD-REJECT ENFORCEMENT LAYER
- **Parent**: ARCH-2.2
- **Purpose**: `BuildLevelAwarenessBrakeReport()` in `level_awareness_brake.mqh` consumes SVS query outputs and applies 6 structural brake rules. Only STRONG or MAJOR opposing zones can trigger structural hard brakes (Rules A, B, F). Slice 2 added structural permission vs obstruction model, enriched diagnostics, and fixed Rule F false positives.
- **Authority relation**: VETO_AUTHORITY — sole structural hard-reject authority
- **Behavioral rules**: A (continuation into obstacle), B (reclaim into rejection), C (exhausted breakout — CEIS touchpoint), D (strategy/location misfit), E (reversal trap), F (SRE room gate — STRONG/MAJOR only after Slice 2 fix)
- **Main files**: `level_awareness_brake.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Cross-ref**: ARCH-1.3.2
- **Children**: ARCH-2.2.7.1 through ARCH-2.2.7.6

---

#### ARCH-2.2.7.1 — Rule A: Continuation Into Obstacle

- **Node ID**: ARCH-2.2.7.1
- **Name**: Rule A — Continuation Into Obstacle
- **Type**: BRAKE RULE
- **Parent**: ARCH-2.2.7
- **Purpose**: Hard brake for CONTINUATION families when `opposeIsStructural && opposePts < ATR*0.35 && breakout_room_score < 0.35`. Prevents trend continuation entry directly into a near STRONG/MAJOR opposing level.
- **Gate**: `opposeClass >= ZONE_STRONG` (LEGACY CLASS CONTRACT)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.7.2 — Rule B: Reclaim Into Rejection

- **Node ID**: ARCH-2.2.7.2
- **Name**: Rule B — Reclaim Into Rejection
- **Type**: BRAKE RULE
- **Parent**: ARCH-2.2.7
- **Purpose**: Hard brake for MEAN_RECLAIM family when `opposeIsStructural && rejection_risk_score > 0.80 && breakout_room_score < 0.40`. Prevents mean-reclaim entry into a STRONG/MAJOR rejection zone.
- **Gate**: `opposeClass >= ZONE_STRONG` (LEGACY CLASS CONTRACT)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.7.3 — Rule C: Exhausted Breakout (CEIS Touchpoint)

- **Node ID**: ARCH-2.2.7.3
- **Name**: Rule C — Exhausted Breakout
- **Type**: BRAKE RULE + CEIS TOUCHPOINT
- **Parent**: ARCH-2.2.7
- **Purpose**: Hard brake for BREAKOUT families when `breakout_room_score < 0.25 || exhausted`. The `exhausted` bool is the sole CEIS/SVS cross-stack touchpoint: `exhausted = (rt.aggregate.exhaustion_warning || rt.env.exhaustion_hint)`. CEIS owns exhaustion signal — brake consumes it read-only here only.
- **CEIS boundary**: READ-ONLY from `rt.aggregate.exhaustion_warning` only. No CEIS logic in brake.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.7.4 — Rule D: Strategy/Location Misfit

- **Node ID**: ARCH-2.2.7.4
- **Name**: Rule D — Strategy/Location Misfit
- **Type**: BRAKE RULE
- **Parent**: ARCH-2.2.7
- **Purpose**: Hard brake for semantic zone/strategy family mismatches. NO_TRADE zone → always reject. Trend family in range zone → reject. Reclaim family in trend zone → reject. Reclaim family in compression zone → reject. Not structural — semantic positioning gate.
- **Gate**: zone_semantic string matching, no structural class check
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.7.5 — Rule E: Reversal Trap

- **Node ID**: ARCH-2.2.7.5
- **Name**: Rule E — Reversal Trap
- **Type**: BRAKE RULE
- **Parent**: ARCH-2.2.7
- **Purpose**: Hard brake for LIQUIDITY_REVERSAL/MOMENTUM_REVERSAL_ASSIST families when `reversal_trap_risk > 0.75`. Fires when a reversal family entry is materially distant from the expected structural edge (support for BUY reversal, resistance for SELL reversal). Distance-based, not class-based.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.2.7.6 — Rule F: SRE Room Gate (Fixed Slice 2)

- **Node ID**: ARCH-2.2.7.6
- **Name**: Rule F — Continuation Obstacle SRE Room Gate
- **Type**: BRAKE RULE
- **Parent**: ARCH-2.2.7
- **Purpose**: Hard brake for CONTINUATION families when `sreRoomScore < 0.25 && opposeIsStructural`. Uses SRE-only distance (excludes session extremes). Fires when continuation entry has insufficient runway to nearest structural zone. Slice 2 added `&& opposeIsStructural` fix: previously fired on ANY SRE zone (including WEAK/MEDIUM) — false positives eliminated. Now correctly requires STRONG/MAJOR zone to trigger.
- **Gate**: `opposeClass >= ZONE_STRONG` (LEGACY CLASS CONTRACT — narrowing fix, not widening)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3 — Council Decision Architecture

- **Node ID**: ARCH-2.3
- **Name**: Council Decision Architecture
- **Type**: INTELLIGENCE STACK
- **Parent**: ARCH-2
- **Purpose**: The full pipeline for producing a directional trade decision through multi-strategy deliberation, weighted aggregation, environment scoring, quality gating, failure pressure awareness, and attribution. COUNCIL mode is the primary active decision engine.
- **Authority relation**: INTELLIGENCE_SUPPORT — produces decision recommendation, OnTick has final execution authority
- **Decision modes**: GATE / SCORE / HYBRID / COUNCIL (COUNCIL = active)
- **Max strategies**: COUNCIL_MAX_STRATEGIES = 17
- **Main files**: council_* file family + decision_mode_router.mqh
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.3.1 through ARCH-2.3.11

---

#### ARCH-2.3.1 — Environment Layer

- **Node ID**: ARCH-2.3.1
- **Name**: Council Environment Layer
- **Type**: ENVIRONMENT ASSESSMENT
- **Parent**: ARCH-2.3
- **Purpose**: `BuildCouncilEnvironmentReport()` assembles the `CouncilEnvironmentReport`. Computes 7 sub-scores (liquidity, spread, momentum, volatility, structure, sweep_context, session), total_score, zone classification (ZoneType + confidence), preferred/blocked style, CEIS sub-signals (ARCH-2.1.1), ATAS shadow overlay, and regime summary. Primary world-state input for all downstream council stages.
- **Authority relation**: INTELLIGENCE_SUPPORT — input to all council stages
- **Dependencies**: `market_regime.mqh`, `core_market_data.mqh`, `atas_intake_layer.mqh` (ATAS shadow), CEIS sub-signal computation (embedded)
- **Main files**: `council_environment.mqh`
- **Main outputs**: `CouncilEnvironmentReport` (rich world-state struct consumed by strategies, aggregator, pre-AI filter, failure detector, brake)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.2 — Strategy Layer

- **Node ID**: ARCH-2.3.2
- **Name**: Council Strategy Layer
- **Type**: MULTI-STRATEGY EVALUATION
- **Parent**: ARCH-2.3
- **Purpose**: Evaluates up to 17 active strategies. Each strategy produces a `CouncilStrategyReport` with BUY/SELL/WAIT/REJECT decision, score (0..1), vote_weight, role, and eligibility state. Strategies are organized into families (TREND_CONTINUATION, MEAN_RECLAIM, LIQUIDITY_REVERSAL, COMPRESSION_BREAKOUT, etc.).
- **Main files**: `council_strategies.mqh` (strategy logic), `strategy_runtime.mqh` (live utility functions: trend signals, market indicators)
- **Main outputs**: Array of `CouncilStrategyReport` (max 17)
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.3.2.1, ARCH-2.3.2.2

---

#### ARCH-2.3.2.1 — Strategy Role System

- **Node ID**: ARCH-2.3.2.1
- **Name**: Strategy Role System
- **Type**: ROLE ARCHITECTURE
- **Parent**: ARCH-2.3.2
- **Purpose**: Each strategy has a `CouncilStrategyRole`: SCOUT (baseline explorer), CONFIRM (confirmation signal, 1.10x multiplier), TREND_JUDGE (trend direction judge, 1.12x multiplier), EXHAUSTION_JUDGE (exhaustion/reversal detector, 1.05x multiplier), GUARD (conservative filter, 0.80x multiplier). Roles affect weight multipliers in aggregation. EXHAUSTION_JUDGE in OBSERVE_ONLY state can still propagate exhaustion_warning in TREND_CONTINUATION zone (signal routing, vote_weight = 0).
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.2.2 — Eligibility State System

- **Node ID**: ARCH-2.3.2.2
- **Name**: Eligibility State System
- **Type**: ELIGIBILITY ARCHITECTURE
- **Parent**: ARCH-2.3.2
- **Purpose**: Each strategy has a `CouncilEligibilityState`: ACTIVE (full weight), REDUCED (0.75x), OBSERVE_ONLY (0.15x — signals observed but not voted), BLOCKED (weight=0 — no influence). Eligibility is assigned per zone type. Controls how much each strategy influences the aggregate under current zone conditions.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.3 — Aggregation Layer

- **Node ID**: ARCH-2.3.3
- **Name**: Council Aggregation Layer
- **Type**: VOTE AGGREGATION
- **Parent**: ARCH-2.3
- **Purpose**: `BuildCouncilAggregateReport()` weighs all strategy votes accounting for role multipliers, eligibility adjustments, and adaptive weight multipliers. Produces consensus_strength, conflict_score, family_diversity_score, zone_alignment_score, council_quality, exhaustion_warning composition, and consensus classification (NONE/NARROW/DIVERSE/HIGH_CONVICTION).
- **Main files**: `council_aggregator.mqh`, `council_adaptive_weights.mqh`
- **Main outputs**: `CouncilAggregateReport`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.3.3.1 through ARCH-2.3.3.5

---

#### ARCH-2.3.3.1 — Vote Weight Computation

- **Node ID**: ARCH-2.3.3.1
- **Name**: Vote Weight Computation
- **Type**: WEIGHTING LOGIC
- **Parent**: ARCH-2.3.3
- **Purpose**: Per-strategy weight = `vote_weight * roleMultiplier * eligibilityFactor * v1Mul` (Package 1: `score_final` and `awMul` removed from live weight formula; `council_aggregator.mqh:205`). Eligibility factors: BLOCKED→0.0, OBSERVE_ONLY→0.15x, REDUCED→0.75x, ACTIVE→1.0x. v1Mul: categorical policy constant [0.85, 1.05] by strategy family. Sum of BUY weights vs SELL weights determines dominant side. `score_final` retained in struct as diagnostic/local-ranking only. `awMul` quarantined unconditionally at formula level (diagnostic note emitted if adaptive weights ever re-enabled via plan flag). `best_strategy_id` selected by highest no-score post-eligibility live contribution (not by score_final). `bestScore` (tracks max score_final) retained for council_quality diagnostic formula only.
- **Truth**: CONFIRMED_SOURCE_TRUTH (updated Package 1)

---

#### ARCH-2.3.3.2 — Consensus and Conflict Scoring

- **Node ID**: ARCH-2.3.3.2
- **Name**: Consensus and Conflict Scoring
- **Type**: QUALITY METRIC
- **Parent**: ARCH-2.3.3
- **Purpose**: `consensus_strength = dominant_weight / total_directional_weight` (voter-fidelity adjusted). `conflict_score = smaller_weight / larger_weight`. Both 0..1. These are primary quality signals for pre-AI filter admission.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.3.3 — Family Diversity Scoring

- **Node ID**: ARCH-2.3.3.3
- **Name**: Family Diversity Scoring
- **Type**: DIVERSITY METRIC
- **Parent**: ARCH-2.3.3
- **Purpose**: Log-based continuous diversity index: `log(1 + familyCount) / log(6)`. Normalised to 5 families = 1.0. Gradients: 1→0.39, 2→0.61, 3→0.77, 4→0.90, 5+→1.0. Replaced prior near-binary {0.35, 0.70, 1.0} step function for finer discrimination around 0.45/0.60 consensus thresholds.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.3.4 — Council Quality Score

- **Node ID**: ARCH-2.3.3.4
- **Name**: Council Quality Score
- **Type**: COMPOSITE QUALITY METRIC
- **Parent**: ARCH-2.3.3
- **Purpose**: `council_quality` = weighted composite of adjusted_consensus*0.32 + environment*0.18 + best_score*0.15 + diversity*0.15 + zone_alignment*0.10 + confirm_role*0.06 + trend_judge*0.04 + HIGH_CONVICTION bonus+0.05 / NARROW penalty-0.05 + CEIS penalties (up to -0.15). Gated by `min_required_council_quality` in pre-AI filter.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.3.5 — Adaptive Weights Hook

- **Node ID**: ARCH-2.3.3.5
- **Name**: Adaptive Weights Hook
- **Type**: OPTIONAL WEIGHT MODIFIER
- **Parent**: ARCH-2.3.3
- **Purpose**: `CouncilAdaptiveWeights` applies per-strategy multipliers (range 0.75..1.25, conservative) when enabled via `plan.council_adaptive_weights_enabled`. Default OFF. Adjusts vote weights based on historical strategy performance, regime alignment, and zone fit. If disabled, all `awMul = 1.0`.
- **Main files**: `council_adaptive_weights.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.4 — Pre-AI Filter

- **Node ID**: ARCH-2.3.4
- **Name**: Council Pre-AI Filter
- **Type**: QUALITY GATE
- **Parent**: ARCH-2.3
- **Purpose**: See ARCH-1.3.3. Cross-referenced here as internal council pipeline node. Applies adaptive quality thresholds. Can produce REJECT. Is NOT the legacy governor — is the live council enforcement owner.
- **Main files**: `council_pre_ai_filter.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Cross-ref**: ARCH-1.3.3

---

#### ARCH-2.3.5 — Failure Pattern Detector

- **Node ID**: ARCH-2.3.5
- **Name**: Council Failure Pattern Detector
- **Type**: FAILURE AWARENESS LAYER
- **Parent**: ARCH-2.3
- **Purpose**: `BuildCouncilFailurePatternReport()` analyses historical trade failure patterns from memory to compute risk scores across failure modes (late continuation, weak reversal, zone mismatch, high conflict, low quality, no confirm, exhaustion ignored). Produces `pressure_level` and `recommended_state` (NORMAL/DEFENSIVE/EXHAUSTION_SENSITIVE). Informs governor operating state adjustments.
- **Main files**: `council_failure_detector.mqh`
- **Main outputs**: `CouncilFailurePatternReport`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-2.3.5.1, ARCH-2.3.5.2, ARCH-2.3.5.3

---

#### ARCH-2.3.5.1 — Memory Input Layer

- **Node ID**: ARCH-2.3.5.1
- **Name**: Failure Detector Memory Input
- **Type**: DATA INPUT
- **Parent**: ARCH-2.3.5
- **Purpose**: Reads `CouncilMemorySummary` from `council_memory.mqh` which in turn reads the performance journal via `journal_analytics.mqh`. Provides: total/executed records, wins/losses, failure-type counts (late_continuation_failures, weak_reversal_failures, zone_mismatch_failures, high_conflict_failures, low_quality_failures, no_confirm_role_failures, exhaustion_ignored_failures).
- **Main files**: `council_memory.mqh`, `journal_analytics.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.5.2 — Risk Score Computation

- **Node ID**: ARCH-2.3.5.2
- **Name**: Failure Risk Score Computation
- **Type**: RISK SCORING
- **Parent**: ARCH-2.3.5
- **Purpose**: Per-failure-type risk scores: continuation_risk, reversal_risk, mean_reclaim_risk, breakout_risk, confirm_gap_risk, exhaustion_ignore_risk, conflict_risk, zone_mismatch_risk, low_quality_risk. Each combines historical failure rate + environment penalty + context flags. Exhaustion_ignore_risk uses graded `ceis_source_score * 0.20` (Slice 1 CEIS evolution).
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.5.3 — Pressure Level Classification

- **Node ID**: ARCH-2.3.5.3
- **Name**: Pressure Level Classification
- **Type**: PRESSURE CLASSIFICATION
- **Parent**: ARCH-2.3.5
- **Purpose**: `recent_failure_pressure` composite (0..1) → `pressure_level` enum (NONE/LOW/MEDIUM/HIGH/CRITICAL). CRITICAL pressure → recommended_state=DEFENSIVE. Zone mismatch / low quality cluster / confirmation gap → DEFENSIVE. Exhaustion risk → EXHAUSTION_SENSITIVE.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.6 — AI Governor

- **Node ID**: ARCH-2.3.6
- **Name**: Council AI Governor
- **Type**: ADAPTIVE GOVERNANCE
- **Parent**: ARCH-2.3
- **Purpose**: `council_ai_governor.mqh` computes governor operating state (NORMAL/DEFENSIVE/AGGRESSIVE/EXHAUSTION_SENSITIVE/CRITICAL_DEFENSIVE) from failure detector output and environmental context. Produces `CouncilPolicyAdjustment outAction` with threshold adjustment vector (new_min_consensus, new_max_conflict, new_min_environment_score, new_min_council_quality). Now called at pipeline step 3E — BEFORE `RunCouncilPreAIFilter()` runs. Enforcement owner remains `RunCouncilPreAIFilter()`; governor is threshold-input supplier only.
- **ENFORCEMENT GAP — CLOSED (PLAN-4 Stage 1, 2026-04-18)**: Prior gap (governor advisory-only, thresholds discarded) is resolved. Governor output is now passed as `CouncilPolicyAdjustment &gov` to `RunCouncilPreAIFilter()`. Filter applies floor enforcement (`MathMax`/`MathMin`) after zone-adaptive adjustments. Three structural gates (NO_TRADE, diversity, confirm-role) remain governor-independent by architectural invariant.
- **Stage 1 implementation**: G1 (enforcement reach closure) + G3 (CEIS high-confidence rider `ceis_source_score >= 0.70 → max_conflict -0.05`) — source-complete, compile-verified 0 errors 2026-04-18 19:19. Observation window open.
- **Main files**: `council_ai_governor.mqh`, `council_pre_ai_filter.mqh`, `council_mode_runtime.mqh`, `council_mode_types.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH + CONFIRMED_ARCHITECTURAL_DECISION (PLAN-4 Stage 1 complete)

---

#### ARCH-2.3.7 — Legacy Governor (Preserved, Not Active Enforcement)

- **Node ID**: ARCH-2.3.7
- **Name**: Legacy Governor (Policy Reference)
- **Type**: PRESERVED PATH — NOT ACTIVE ENFORCEMENT
- **Parent**: ARCH-2.3
- **Purpose**: `council_governor.mqh` contains legacy governor threshold helpers and `RunCouncilGovernorDecision()`. Explicit source comment: "This legacy governor threshold module is descriptive/policy reference only in current active runtime flow. It is not the live council pre-filter enforcement owner." Pre-AI filter (`council_pre_ai_filter.mqh`) is the live enforcement owner.
- **Authority relation**: HISTORICAL_CONTEXT — policy reference, not active enforcement
- **Main files**: `council_governor.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH + CONFIRMED_ARCHITECTURAL_DECISION

---

#### ARCH-2.3.8 — Attribution Intelligence

- **Node ID**: ARCH-2.3.8
- **Name**: Council Attribution Intelligence
- **Type**: INTERPRETABILITY SURFACE
- **Parent**: ARCH-2.3
- **Purpose**: `council_attribution_intelligence.mqh` produces `CouncilDecisionAttribution` (dominant strategy, aligned/opposing/neutral strategy counts, compact encoding) and `ZoneCoverageReport` (zone coverage quality, diversity, conflict detection). Provides human-readable and log-parseable attribution for each council decision. Non-authoritative — interpretability only.
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY
- **Main files**: `council_attribution_intelligence.mqh`
- **Main outputs**: `CouncilDecisionAttribution`, `ZoneCoverageReport` (inside `CouncilRuntimeResult`)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.9 — Zone Coverage Reporter

- **Node ID**: ARCH-2.3.9
- **Name**: Zone Coverage Reporter
- **Type**: INTERPRETABILITY SURFACE (currently) — PLAN-4 Stage 2 candidate for bounded threshold input
- **Parent**: ARCH-2.3
- **Purpose**: Computes `ZoneCoverageReport` from `reports[]` and `env` — describes strategic deployment quality for the current zone. Labels: NO_COVERAGE / WEAK / OVERCROWDED / CONFLICTED / STRONG_DIVERSE / BALANCED. Classification logic: OVERCROWDED fires at `active_strategies >= 5` (with 17 council strategies, this fires on most high-consensus bars). CONFLICTED fires when any opposing directional vote is present regardless of weight. STRONG_DIVERSE fires when `diversity_score > 0.6` (unique families / active strategies). Coverage is diagnostic only until Stage 2 promotes it.
- **Source location**: `council_strategies.mqh` (function `BuildZoneCoverageReport()`) — NOT in `council_attribution_intelligence.mqh` despite the prior PIML note.
- **Pipeline position**: Step 3B — computed before filter; result stored in `runtime.zone_coverage`. Available for filter consumption in Stage 2 with no pipeline reordering.
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY (current) — Stage 2 would change to THRESHOLD_INPUT (bounded, filter-local only)
- **Stage 2 design findings**: CONFLICTED tightening is the primary value case (captures low-weight opposing votes missed by governor Case 2). NO_COVERAGE tightening is near-theatrical (already rejected by consensus gate). OVERCROWDED handling is unresolved (most common label on active bars). STRONG_DIVERSE relaxation is the best positive-signal case (currently not in Stage 2 sketch). Stage 2 description requires refinement before execution opens.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.10 — Council Mode Runtime Orchestrator

- **Node ID**: ARCH-2.3.10
- **Name**: Council Mode Runtime Orchestrator
- **Type**: PIPELINE ORCHESTRATOR
- **Parent**: ARCH-2.3
- **Purpose**: `council_mode_runtime.mqh` orchestrates the full council pipeline per tick: environment build → strategy evaluation → aggregation (with adaptive weights) → pre-AI filter → failure detector → governor → continuation reinforcement (opt-in) → attribution → feedback write → result assembly. Produces `CouncilRuntimeResult` (complete council execution output).
- **Authority relation**: PIPELINE ORCHESTRATOR — no independent authority, assembles all council stages
- **Main files**: `council_mode_runtime.mqh`
- **Main outputs**: `CouncilRuntimeResult` (env, aggregate, pre_ai_gate, failure_detector, attribution, zone_coverage, final_decision)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-2.3.11 — Decision Mode Router

- **Node ID**: ARCH-2.3.11
- **Name**: Decision Mode Router
- **Type**: MODE DISPATCH LAYER
- **Parent**: ARCH-2.3
- **Purpose**: See ARCH-1.2.2. Cross-referenced here as the council pipeline exit gate. Routes COUNCIL mode to `council_mode_runtime.mqh`. Converts `CouncilDecision` → `RuntimeDecision` for OnTick consumption. Produces `RoutedRuntimeEvaluation`.
- **Main files**: `decision_mode_router.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Cross-ref**: ARCH-1.2.2

---

#### ARCH-3 — Data / Memory / Feedback / Diagnostics Surfaces

- **Node ID**: ARCH-3
- **Name**: Data / Memory / Feedback / Diagnostics Surfaces
- **Type**: ROOT DOMAIN
- **Parent**: none (sibling of ARCH-1, ARCH-2)
- **Purpose**: All surfaces responsible for capturing, storing, reading, and surfacing runtime truth, trade outcomes, performance intelligence, and operational diagnostics. None of these surfaces hold execution authority. They feed intelligence stacks and visibility layers.
- **Authority relation**: JOURNAL_OR_SUPPORT_ARTIFACT + DERIVED_OR_VISIBILITY_ONLY
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-3.1 through ARCH-3.10

---

#### ARCH-3.1 — Performance Journal

- **Node ID**: ARCH-3.1
- **Name**: Performance Journal
- **Type**: LIVE-LOCKED APPEND-ONLY JOURNAL
- **Parent**: ARCH-3
- **Purpose**: Primary trade outcome storage. MT5 writes trade outcomes as JSONL records to `ai_performance_journal.jsonl`. Live-locked during operation — must not be read, copied, zipped, or modified while MT5 is running (AGENTS.md Rule 2). Read by `journal_analytics.mqh` for analysis.
- **Authority relation**: JOURNAL_OR_SUPPORT_ARTIFACT — source of truth for historical outcomes
- **Main files**: `performance_journal.mqh` (writer), `ai_performance_journal.jsonl` (artifact)
- **Truth**: CONFIRMED_RUNTIME_TRUTH

---

#### ARCH-3.2 — Journal Analytics

- **Node ID**: ARCH-3.2
- **Name**: Journal Analytics
- **Type**: JOURNAL READER/ANALYSER
- **Parent**: ARCH-3
- **Purpose**: `journal_analytics.mqh` reads and parses `ai_performance_journal.jsonl`. Aggregates outcome records by strategy, zone, failure type. Feeds `council_memory.mqh` and `risk_state_policy_engine.mqh` with summary statistics.
- **Main files**: `journal_analytics.mqh`
- **Main outputs**: aggregated statistics consumed by council memory and risk policy
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.3 — Council Memory Layer

- **Node ID**: ARCH-3.3
- **Name**: Council Memory Layer
- **Type**: INTELLIGENCE MEMORY
- **Parent**: ARCH-3
- **Purpose**: `council_memory.mqh` wraps journal analytics output into `CouncilMemorySummary` (failure counts, win/loss rates, quality bands, top failure tag, top setup type). Primary memory input for failure detector (ARCH-2.3.5).
- **Main files**: `council_memory.mqh`
- **Main outputs**: `CouncilMemorySummary`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.4 — Council Feedback Writer

- **Node ID**: ARCH-3.4
- **Name**: Council Feedback Writer
- **Type**: FEEDBACK CAPTURE
- **Parent**: ARCH-3
- **Purpose**: `council_feedback.mqh` writes `CouncilFeedbackRecord` entries to the performance journal after each council evaluation. Records decision context, zone, strategy attribution, council quality, exhaustion state. `council_feedback_memory.mqh` manages feedback state between writes.
- **Main files**: `council_feedback.mqh`, `council_feedback_memory.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.5 — Trade Feedback

- **Node ID**: ARCH-3.5
- **Name**: Trade Feedback
- **Type**: TRADE OUTCOME CAPTURE
- **Parent**: ARCH-3
- **Purpose**: `trade_feedback.mqh` captures trade close outcomes (P&L, outcome type) and appends to performance journal. Raw trade result source — separate from council feedback records.
- **Main files**: `trade_feedback.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.6 — Performance Memory

- **Node ID**: ARCH-3.6
- **Name**: Performance Memory
- **Type**: PERFORMANCE STATE CACHE
- **Parent**: ARCH-3
- **Purpose**: `performance_memory.mqh` maintains in-memory performance state (recent P&L streak, drawdown state, win rate windows). Feeds `risk_state_policy_engine.mqh` for risk policy state computation.
- **Main files**: `performance_memory.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.7 — Dashboard System

- **Node ID**: ARCH-3.7
- **Name**: Dashboard System
- **Type**: OPERATIONAL VISIBILITY SURFACE
- **Parent**: ARCH-3
- **Purpose**: Multi-file dashboard rendering system. Read-only operational visibility — not a control layer. Displays runtime state, council outputs, zone context, ATAS status, performance indicators. Cannot mutate runtime state.
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY — strict read-only, no execution authority
- **Main files**: `dashboard_contract.mqh`, `dashboard_source_registry.mqh`, `dashboard_state_collector.mqh`, `dashboard_state_classifier.mqh`, `dashboard_view_model.mqh`, `dashboard_guardrails.mqh`, `dashboard_snapshot_exporter.mqh`, `dashboard_navigation_controller.mqh`, `dashboard_renderer.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-3.7.1 through ARCH-3.7.6

---

#### ARCH-3.7.1 — Dashboard Contract and Registry

- **Node ID**: ARCH-3.7.1
- **Name**: Dashboard Contract and Registry
- **Type**: DASHBOARD FOUNDATION
- **Parent**: ARCH-3.7
- **Purpose**: `dashboard_contract.mqh` defines dashboard data contracts (structs, display modes). `dashboard_source_registry.mqh` manages which runtime sources feed which dashboard panels. Foundation layer — consumed by all other dashboard files.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.7.2 — Dashboard State Collection and Classification

- **Node ID**: ARCH-3.7.2
- **Name**: Dashboard State Collection and Classification
- **Type**: STATE AGGREGATION
- **Parent**: ARCH-3.7
- **Purpose**: `dashboard_state_collector.mqh` gathers current runtime state from all sources. `dashboard_state_classifier.mqh` applies semantic classification to raw state (risk level, council quality band, zone type label). Produces structured state for the view model.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.7.3 — Dashboard View Model and Renderer

- **Node ID**: ARCH-3.7.3
- **Name**: Dashboard View Model and Renderer
- **Type**: DISPLAY LAYER
- **Parent**: ARCH-3.7
- **Purpose**: `dashboard_view_model.mqh` translates classified state into display-ready data. `dashboard_renderer.mqh` renders MT5 chart objects (labels, panels). The final visible output of the dashboard pipeline.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.7.4 — Dashboard Snapshot Exporter

- **Node ID**: ARCH-3.7.4
- **Name**: Dashboard Snapshot Exporter
- **Type**: EXPORT SURFACE
- **Parent**: ARCH-3.7
- **Purpose**: `dashboard_snapshot_exporter.mqh` writes dashboard state snapshots to `MQL5/Files/AI/` JSON files for external consumption (review, aggregation, Python analysis layer).
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.7.5 — Dashboard Navigation and Guardrails

- **Node ID**: ARCH-3.7.5
- **Name**: Dashboard Navigation and Guardrails
- **Type**: UI CONTROL + SAFETY
- **Parent**: ARCH-3.7
- **Purpose**: `dashboard_navigation_controller.mqh` manages panel switching/navigation state. `dashboard_guardrails.mqh` enforces dashboard read-only discipline — prevents any dashboard component from writing to execution surfaces.
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.8 — Runtime Honesty Surfaces

- **Node ID**: ARCH-3.8
- **Name**: Runtime Honesty Surfaces
- **Type**: OPERATIONAL TRANSPARENCY LAYER
- **Parent**: ARCH-3
- **Purpose**: `runtime_honesty_surfaces.mqh` writes operational truth artifacts: `runtime_honesty_truth.json`, `operator_input_truth_map.json`, `threshold_ownership_registry.json`, `operator_effective_configuration_surface.json`. These surfaces expose the actual runtime configuration, threshold owners, and effective settings for human/AI review. Visibility only — not authoritative.
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY
- **Main files**: `runtime_honesty_surfaces.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.9 — Council Text Reporter

- **Node ID**: ARCH-3.9
- **Name**: Council Text Reporter
- **Type**: DIAGNOSTIC TEXT SURFACE
- **Parent**: ARCH-3
- **Purpose**: `council_txt_reporter.mqh` builds human-readable structured text summaries of council evaluation results for journal/log output. Not a storage surface — formats existing data into readable strings. Diagnostic/visibility only.
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY
- **Main files**: `council_txt_reporter.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-3.10 — SRE Diagnostic Surface

- **Node ID**: ARCH-3.10
- **Name**: SRE Diagnostic Surface
- **Type**: ENGINE DIAGNOSTIC
- **Parent**: ARCH-3
- **Purpose**: `gSRELastUpdateSummary` global string updated per bar by `SRE_BuildDiagnosticSummary()`. Contains pool raw counts and promoted zone class distribution (Maj/Str/Med/Wk per side). Consumed by Slice 2 `structural_profile` field in brake report for forensic log analysis.
- **Authority relation**: DERIVED_OR_VISIBILITY_ONLY
- **Main files**: `structural_sr_engine.mqh` (`gSRELastUpdateSummary` global + `SRE_BuildDiagnosticSummary()`)
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4 — External / Shadow / Preserved Paths

- **Node ID**: ARCH-4
- **Name**: External / Shadow / Preserved Paths
- **Type**: ROOT DOMAIN
- **Parent**: none (sibling of ARCH-1, ARCH-2, ARCH-3)
- **Purpose**: All paths that exist in the system but are either external to the MT5 runtime authority, operating in shadow/advisory mode only, preserved but not primary active, or dormant. None of these paths hold execution authority or can override MT5 decisions.
- **Authority relation**: EXTERNAL, SHADOW, or PRESERVED — zero execution authority
- **Truth**: CONFIRMED_SOURCE_TRUTH
- **Children**: ARCH-4.1 through ARCH-4.8

---

#### ARCH-4.1 — ATAS External Shadow Path

- **Node ID**: ARCH-4.1
- **Name**: ATAS External Shadow Path
- **Type**: EXTERNAL SHADOW INTELLIGENCE
- **Parent**: ARCH-4
- **Purpose**: ATAS (order flow / microstructure platform) contributes bounded advisory context via file-based shadow channel. MT5 reads `atas_microstructure_context.json` (primary, Direct Write, LIVE) per heartbeat. Produces advisory overlay embedded in `CouncilEnvironmentReport` — non-authoritative, non-consumed for trade generation. ATAS advisory role permanently capped at BOUNDED_CONTEXT or SHADOW_ONLY.
- **Authority relation**: ZERO EXECUTION AUTHORITY — advisory and shadow only, cannot override MT5 decisions
- **Truth**: CONFIRMED_RUNTIME_TRUTH + CONFIRMED_ARCHITECTURAL_DECISION
- **Children**: ARCH-4.1.1 through ARCH-4.1.7

---

#### ARCH-4.1.1 — ATAS Intake Layer

- **Node ID**: ARCH-4.1.1
- **Name**: ATAS Intake Layer
- **Type**: FILE READER
- **Parent**: ARCH-4.1
- **Purpose**: `atas_intake_layer.mqh` reads and parses `atas_microstructure_context.json` (primary Direct Write target, 15-second max age). Writes `atas_microstructure_status.json` per heartbeat (MT5-side evaluation status). Defines freshness validation, schema parsing, and acceptance/rejection logic.
- **Main files**: `atas_intake_layer.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.1.2 — ATAS Runtime Contract

- **Node ID**: ARCH-4.1.2
- **Name**: ATAS Runtime Contract
- **Type**: DATA CONTRACT
- **Parent**: ARCH-4.1
- **Purpose**: `atas_runtime_contract.mqh` defines structs: `AtasMicrostructureOverlay` (order flow signals), `AtasLevelEvidenceBundle` (S/R level evidence), `TwinInfluenceTrace` (dual-side influence tracing). The schema contract between ATAS indicator output and MT5 consumption.
- **Main files**: `atas_runtime_contract.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.1.3 — Governed Advisory Layer (Layer 3)

- **Node ID**: ARCH-4.1.3
- **Name**: ATAS Governed Advisory Layer
- **Type**: ADVISORY PROCESSING
- **Parent**: ARCH-4.1
- **Purpose**: `atas_governed_advisory_layer.mqh` implements the Layer 3 governed advisory processing. Evaluates ATAS microstructure signals against eligibility criteria, produces advisory relevance scores and hold-bias assessments. Output embedded in `CouncilEnvironmentReport.atas_advisory_*` fields. Advisory only — does not generate or block trades.
- **Main files**: `atas_governed_advisory_layer.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.1.4 — Governed Advisory Contract and Artifacts

- **Node ID**: ARCH-4.1.4
- **Name**: ATAS Governed Advisory Contract and Artifacts
- **Type**: DATA CONTRACT + ARTIFACT MANAGEMENT
- **Parent**: ARCH-4.1
- **Purpose**: `atas_governed_advisory_contract.mqh` defines the advisory-layer data contracts (eligibility states, outcome labels, consumption mode enums). `atas_governed_advisory_artifacts.mqh` manages advisory artifact lifecycle (creation, age checking, output writing).
- **Main files**: `atas_governed_advisory_contract.mqh`, `atas_governed_advisory_artifacts.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.1.5 — Legacy ATAS Files (Historical)

- **Node ID**: ARCH-4.1.5
- **Name**: Legacy ATAS Files
- **Type**: HISTORICAL_CONTEXT
- **Parent**: ARCH-4.1
- **Purpose**: `atas_runtime_context.json` (last written 2026-04-10, legacy flat schema) and `atas_runtime_context_status.json` (stale since 2026-04-10). MT5 intake no longer reads these — primary Direct Write path is live. These are historical lineage artifacts, not current execution surfaces.
- **Authority relation**: HISTORICAL_CONTEXT — do not retire until primary path is confirmed stable
- **Truth**: CONFIRMED_RUNTIME_TRUTH + HISTORICAL_CONTEXT

---

#### ARCH-4.2 — Strategy Runtime (Mixed-Role Preserved)

- **Node ID**: ARCH-4.2
- **Name**: Strategy Runtime (Mixed-Role)
- **Type**: MIXED — ACTIVE UTILITY + PRESERVED DEAD PATHS
- **Parent**: ARCH-4
- **Purpose**: `strategy_runtime.mqh` has a mixed role. Contains live utility functions (RT_M1TrendBull, RT_M5TrendBull, RT_M5TrendBear, RT_M1TrendBear etc.) that are actively called from `council_strategies.mqh`. Also contains legacy GATE/SCORE/HYBRID mode strategy execution paths that are preserved but not the primary active flow when COUNCIL mode is active. Must NOT be uniformly treated as dead — live utility functions are required.
- **Authority relation**: ACTIVE (utility functions) + PRESERVED (legacy mode paths)
- **Classification**: MIXED — not uniformly dead, not uniformly active
- **Main files**: `strategy_runtime.mqh`
- **Truth**: CONFIRMED_ARCHITECTURAL_DECISION (Phase 4 containment decision)
- **Children**: ARCH-4.2.1, ARCH-4.2.2

---

#### ARCH-4.2.1 — Live Utility Functions

- **Node ID**: ARCH-4.2.1
- **Name**: Strategy Runtime Live Utility Functions
- **Type**: ACTIVE UTILITY
- **Parent**: ARCH-4.2
- **Purpose**: Functions like `RT_M1TrendBull()`, `RT_M5TrendBull()`, `RT_M1TrendBear()`, `RT_M5TrendBear()` and similar market condition helpers. Called directly from `council_strategies.mqh` strategy evaluation logic. These are ACTIVE and must not be removed.
- **Authority relation**: ACTIVE UTILITY — required by council strategies
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.2.2 — Legacy Strategy Mode Paths (Preserved)

- **Node ID**: ARCH-4.2.2
- **Name**: Legacy Strategy Mode Paths (Preserved)
- **Type**: PRESERVED PATH — INACTIVE WHEN COUNCIL IS ACTIVE
- **Parent**: ARCH-4.2
- **Purpose**: GATE/SCORE/HYBRID mode execution logic in `strategy_runtime.mqh`. Not the primary active path when COUNCIL mode is configured. Preserved for backward compatibility — plan may switch modes. Contains `RuntimeEvaluation` struct and legacy decision logic.
- **Authority relation**: PRESERVED — may become active if decision_engine_mode switches from COUNCIL
- **Truth**: CONFIRMED_SOURCE_TRUTH + CONFIRMED_ARCHITECTURAL_DECISION

---

#### ARCH-4.3 — Rollback Engine (Dormant)

- **Node ID**: ARCH-4.3
- **Name**: Rollback Engine
- **Type**: DORMANT SAFETY MECHANISM
- **Parent**: ARCH-4
- **Purpose**: `rollback_engine.mqh` + `rollback_signal_engine.mqh` implement an AI parameter rollback safety system. Armed via `ai_rollback_state.json`. Currently dormant — `ai_rollback_state.json` is empty, rollback is never armed. Safety mechanism exists but is not active.
- **Authority relation**: DORMANT — would hold risk-override authority if armed
- **Main files**: `rollback_engine.mqh`, `rollback_signal_engine.mqh`
- **Runtime artifact**: `ai_rollback_state.json` (empty — CONFIRMED_RUNTIME_TRUTH)
- **Truth**: CONFIRMED_SOURCE_TRUTH (code exists) + CONFIRMED_RUNTIME_TRUTH (dormant, not armed)

---

#### ARCH-4.4 — AI Bridge and Evolution Engine (Deferred)

- **Node ID**: ARCH-4.4
- **Name**: AI Bridge and Evolution Engine
- **Type**: DEFERRED PATH
- **Parent**: ARCH-4
- **Purpose**: `ai_bridge.mqh` and `ai_evolution_engine.mqh` implement AI advisory/execution intelligence hooks — external AI interpretation layer connection points. Present in include chain but their advisory surfaces are not currently generating execution-level decisions. Deferred capability for future AI authority escalation (requires explicit governance unlock).
- **Authority relation**: DEFERRED — zero current execution authority, no auto-apply capability
- **Main files**: `ai_bridge.mqh`, `ai_evolution_engine.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH + DEFERRED_PATH

---

#### ARCH-4.5 — Shadow and Replay Paths

- **Node ID**: ARCH-4.5
- **Name**: Shadow and Replay Paths
- **Type**: SHADOW COMPUTATION
- **Parent**: ARCH-4
- **Purpose**: `shadow_replay_engine.mqh` implements a replay/shadow evaluation path that runs council evaluation in shadow mode (no trade execution). `shadow_policy_mirroring.mqh` mirrors policy decisions into shadow surfaces for comparison. Used for analysis and validation without affecting live execution.
- **Authority relation**: SHADOW — zero execution authority, read-only shadow computation
- **Main files**: `shadow_replay_engine.mqh`, `shadow_policy_mirroring.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.6 — Legacy GATE/SCORE/HYBRID Mode Execution Path

- **Node ID**: ARCH-4.6
- **Name**: Legacy GATE/SCORE/HYBRID Mode Execution Path
- **Type**: PRESERVED PARALLEL PATH
- **Parent**: ARCH-4
- **Purpose**: The non-COUNCIL decision modes (GATE, SCORE, HYBRID) route through `strategy_runtime.mqh` legacy evaluation logic via `decision_mode_router.mqh`. These paths are architecturally preserved but not the primary active path when `decision_engine_mode = COUNCIL`. Plan configuration determines which path is active.
- **Authority relation**: PRESERVED — ACTIVE only if plan switches away from COUNCIL mode
- **Main files**: `decision_mode_router.mqh`, `strategy_runtime.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.7 — Correlation Engine

- **Node ID**: ARCH-4.7
- **Name**: Correlation Engine
- **Type**: ANALYTICAL SURFACE
- **Parent**: ARCH-4
- **Purpose**: `correlation_engine.mqh` tracks correlations between strategies and trade outcomes — cross-strategy correlation analysis. Used for attribution and performance analysis. Non-authoritative.
- **Authority relation**: ANALYTICAL — no execution authority
- **Main files**: `correlation_engine.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-4.8 — Plan Auto-Apply and Validator

- **Node ID**: ARCH-4.8
- **Name**: Plan Auto-Apply and Validator
- **Type**: PLAN GOVERNANCE UTILITY
- **Parent**: ARCH-4
- **Purpose**: `plan_auto_apply.mqh` applies plan parameter changes at runtime. `plan_validator.mqh` validates plan integrity before application. Governance utilities for plan lifecycle management.
- **Main files**: `plan_auto_apply.mqh`, `plan_validator.mqh`
- **Truth**: CONFIRMED_SOURCE_TRUTH

---

#### ARCH-5 — Future Device Candidates (Deferred)

- **Node ID**: ARCH-5
- **Name**: Future Device Candidates
- **Type**: ROOT DOMAIN — DEFERRED
- **Parent**: none (sibling domain)
- **Purpose**: Architectural positions reserved for future intelligence devices that are not yet implemented as governed production-ready paths. Explicitly deferred — not blocked, not rejected, but outside current program scope.
- **Authority relation**: DEFERRED_PATH — none currently
- **Truth**: CONFIRMED_ARCHITECTURAL_DECISION (deferred, not rejected)
- **Children**: ARCH-5.1, ARCH-5.2, ARCH-5.3

---

#### ARCH-5.1 — Liquidity Structural Stack (Deferred)

- **Node ID**: ARCH-5.1
- **Name**: Liquidity Structural Stack
- **Type**: DEFERRED FUTURE DEVICE
- **Parent**: ARCH-5
- **Purpose**: Long-term structural intelligence combining ATAS order flow, dxFeed liquidity signals, and structural price levels into a unified liquidity-aware zone intelligence layer. Explicitly excluded from current SVS and CEIS evolution scope. Requires dxFeed integration and ATAS long-term device work — not in current program.
- **Authority relation**: DEFERRED_PATH
- **Truth**: CONFIRMED_ARCHITECTURAL_DECISION

---

#### ARCH-5.2 — Structural Fusion Layer (Deferred)

- **Node ID**: ARCH-5.2
- **Name**: Structural Fusion Layer
- **Type**: DEFERRED FUTURE DEVICE
- **Parent**: ARCH-5
- **Purpose**: Fusion of SVS structural zones with ATAS level evidence and liquidity markers to produce a higher-confidence structural map. Would consume SVS zone enrichment (Slice 1 fields) + ATAS level evidence bundle. Not in current program scope.
- **Authority relation**: DEFERRED_PATH
- **Truth**: CONFIRMED_ARCHITECTURAL_DECISION

---

#### ARCH-5.3 — AI Interpretation Layer (Deferred)

- **Node ID**: ARCH-5.3
- **Name**: AI Interpretation Layer
- **Type**: DEFERRED FUTURE DEVICE
- **Parent**: ARCH-5
- **Purpose**: External AI interpretation and advisory authority — requires explicit governance unlock via plan changes. ai_bridge.mqh and ai_evolution_engine.mqh provide structural connection points but the layer has zero current execution authority. Full AI advisory escalation is deferred.
- **Authority relation**: DEFERRED_PATH — requires governed plan unlock
- **Truth**: CONFIRMED_ARCHITECTURAL_DECISION

---

## 3. FUNCTIONAL TREE

> This is not the same as architecture. Architecture = what exists structurally. Functional tree = what each part actually does.

### 3.1 Functional Tree Rules

Every functional node must include:

- functional ID
- function name
- owning architecture node(s)
- operational purpose
- trigger condition
- inputs
- outputs
- consumers
- decision effect
- failure mode if absent

### 3.2 Root Functional Tree

**FUNC-1 Execution Control Functions**

- Children:

**FUNC-2 Intelligence Functions**

- Children:
  - FUNC-2.1 Exhaustion intelligence
  - FUNC-2.2 Structural visibility
  - FUNC-2.3 Decision filtering
  - FUNC-2.4 Brake enforcement

**FUNC-2.1 Exhaustion Intelligence**

- Owning nodes:
- Children:

**FUNC-2.2 Structural Visibility**

- Owning nodes:
- Children:

**FUNC-2.3 Decision Filtering**

- Owning nodes:
- Children:

**FUNC-2.4 Brake Enforcement**

- Owning nodes:
- Children:

**FUNC-3 Feedback / Memory / Learning Functions**

- Children:

**FUNC-4 Diagnostics / Interpretability Functions**

- Children:

---

## 4. DEPENDENCY MAP

> This section captures what each important unit depends on and what depends on it.

### 4.1 Dependency Record Template

- Dependency ID:
- Node / function:
- Depends on:
- Dependency type:
  - structural
  - logical
  - runtime
  - semantic
  - data
- Failure impact if broken:
- Consumer impact:
- Notes:

### 4.2 Dependency Registry

**DEP-1**

- Node / function:
- Depends on:
- Type:
- Impact:

**DEP-2**

- Node / function:
- Depends on:
- Type:
- Impact:

---

## 5. EDGE / QUALITY / FAILURE DEFINITIONS

> This section stores high-value edge definitions and quality interpretations.

### 5.1 Edge Definition Template

- Edge ID:
- Name:
- Owning system part:
- Operational meaning:
- Why it matters:
- When present:
- When absent:
- Related functions:
- Risks of false detection:
- Risks of missed detection:

### 5.2 Edge Registry

- EDGE-1 CEIS Edge Definitions
- EDGE-2 SVS Edge Definitions
- EDGE-3 Council / Admission Edge Definitions
- EDGE-4 Brake Edge Definitions
- EDGE-5 Failure Pattern Definitions

---

## 6. INPUT / OUTPUT / CONSUMER MATRIX

> This section is a storage matrix for every major functional block.

### 6.1 I/O Record Template

- IO ID:
- Block / function:
- Inputs:
- Input owners:
- Output(s):
- Output consumer(s):
- Output authority status:
- Downstream effect:

### 6.2 Matrix Records

**IO-1**

- Block:
- Inputs:
- Outputs:
- Consumers:

**IO-2**

- Block:
- Inputs:
- Outputs:
- Consumers:

---

## 7. EXECUTION PROGRAM REGISTRY

> This section is the authoritative working-memory location for execution programs (implementation plans).
> It holds full working state for open plans, and concise archival summaries for closed plans.

### 7.0 Execution-Plan Memory Model

The execution-plan section operates on a **two-tier memory model**:

**Tier 1 — Working State (this file, Section 7.2)**

Plans in any open state are held in full working form here. Open states:

`DRAFTED` · `UNDER_PREPARATION` · `APPROVED` · `ACTIVE` · `PARTIALLY_EXECUTED` · `MODIFIED` · `IMPROVED` · `SPLIT` · `MERGED_INTO` · `PARTIALLY_CANCELLED` · `DEFERRED`

A plan remains in Tier 1 for as long as it carries operationally relevant open state — including plans that are split, merged with another open plan, or temporarily deferred but expected to re-open. Multiple open plans may coexist in Tier 1 when overlap is genuine (split, merge-in-progress, partial cancellation).

**Tier 2 — Archive (linked .txt file, Section 7.3 summary)**

Once a plan reaches state `CLOSED` or `ARCHIVED`, its full execution history moves to a linked archive file:

`plans/archive/<PLAN-ID>_<short-name>.txt`

After archival, this file retains only the concise archival summary (see template 7.1.2). Closed plans do not remain fully expanded in the main `.md`. The main file stays useful and light to read repeatedly.

---

### 7.1 Program Templates

**7.1.1 Working-State Template**
*Use when plan state is any open state (DRAFTED through DEFERRED).*

- Program ID:
- Name:
- Scope:
- State:               [DRAFTED | UNDER_PREPARATION | APPROVED | ACTIVE | PARTIALLY_EXECUTED | MODIFIED | IMPROVED | SPLIT | MERGED_INTO | PARTIALLY_CANCELLED | DEFERRED]
- Owner:
- Why it exists:
- Architecture nodes affected:
- Functional nodes affected:
- Current stage:
- Completed stages:
- Next stage:
- Main blockers:
- Main risks:
- Files affected:
- Related plans:       [other plan IDs — if split from, merged with, or depends on]
- Notes:

---

**7.1.2 Archival Summary Template**
*Use when plan state is CLOSED or ARCHIVED. Full execution detail moves to linked .txt.*

- Program ID:
- Name:
- State:               CLOSED | ARCHIVED
- Closed on:           [date or "unknown"]
- Closed reason:       [COMPLETED | SUPERSEDED | CANCELLED | MERGED | SPLIT_AND_CLOSED]
- What was done:       [1–3 sentence summary of what actually changed in the system]
- Outcome:             [SUCCESSFUL | PARTIAL | REVERTED | INCONCLUSIVE]
- Superseded by:       [plan ID, or "n/a"]
- Merged into:         [plan ID, or "n/a"]
- Archive file:        [plans/archive/<ID>_<short-name>.txt — or "not yet archived"]

---

### 7.2 Working-State Programs

> Plans listed here are in an open state. Full working detail is preserved.
> When a plan closes, move its entry to Section 7.3 using the Archival Summary Template (7.1.2).

**PLAN-1 CEIS Evolution Program**

- Program ID: PLAN-1
- Name: CEIS Evolution Program
- Scope: Council Environment Intelligence System — multi-horizon exhaustion source layer within `council_environment.mqh` and `council_mode_types.mqh`; consumed by aggregator, pre-AI filter, and brake
- State: ACTIVE
- Owner: execution layer
- Why it exists: The original single `exhaustion_hint` (M1 wick-dominant spike) fired on ~44% of range cycles as false positives. CEIS replaces it with a 7-signal multi-horizon exhaustion intelligence layer that provides genuine composite context for zone typing, council aggregation, pre-AI filtering, and brake Rule C.
- Architecture nodes affected: ARCH-2.1 (CEIS — primary), ARCH-2.3.2 (aggregator exhaustion_warning path), ARCH-1.1 (environment builder), ARCH-2.2.7.3 (brake Rule C consumer)
- Functional nodes affected: `EvaluateCEISSourceSignals()`, `BuildCouncilEnvironmentReport()`, `BuildCouncilAggregateReport()` 7-path exhaustion_warning, pre-AI filter TREND_CONTINUATION + BREAKOUT_EXPANSION gates, brake Rule C
- Current stage: Observation window — live validation of multi-signal confluence patterns vs prior single-hint behaviour; monitoring `ceis_source_score` and `ceis_signal_count` in journal
- Completed stages:
  - Stage 1 (baseline): Single `exhaustion_hint` — M1 wick-dominant + highVol + highMomentum. Operational pre-CEIS; preserved as `ceis_spike_reversal_m1`.
  - Stage 2 (source layer): 7 sub-signals in `EvaluateCEISSourceSignals()` — M1 spike, M5 EMA overextension (primary LATE_CONTINUATION_FAILURE detector), M5/M15 MFI extremes, H1 MFI structural extreme (strict 65/35), H4 MFI macro context (68/32, score-only), M5 ATR momentum fade (score-only)
  - Stage 3 (composite scoring): `ceis_source_score` 0..1 (7 weighted sub-signals: overext=0.30, mfi_m5=0.20, mfi_m15=0.18, mfi_h1=0.15, fade=0.15, spike=0.12, h4=0.10) + `ceis_signal_count` 0..7 in `CouncilEnvironmentReport`
  - Stage 4 (aggregator): 7-path `exhaustion_warning` combination — strategy EXHAUSTION_JUDGE votes, `env.exhaustion_hint`, `ceis_overextension_m5`, M5+M15 MFI confluence, `ceis_mfi_exhaustion_h1` independently
  - Stage 5 (pre-AI filter): TREND_CONTINUATION and BREAKOUT_EXPANSION exhaustion gates consuming `agg.exhaustion_warning`; stacked quality/conflict adjustments
  - Stage 6 (brake): Rule C reads `rt.aggregate.exhaustion_warning` — CEIS boundary read-only; no structural authority over brake verdict logic
- Next stage: Live observation — validate `ceis_overextension_m5` primary fire rate, confirm H1 MFI fires only at structural extremes, verify no regressions from prior `exhaustion_hint` behaviour
- Main blockers: Runtime freeze operational (no trade execution) — does not block CEIS observation of signal patterns
- Main risks: H4 MFI context and M5 momentum fade are score-contributors only (no independent exhaustion_warning authority); if combined ceis_source_score generates elevated false-positive rates in live ranging conditions, sub-signal weighting may need tuning
- Files affected: `council_mode_types.mqh`, `council_environment.mqh`, `council_aggregator.mqh`, `council_pre_ai_filter.mqh`, `level_awareness_brake.mqh`
- Related plans: PLAN-2 (SVS) — `agg.exhaustion_warning` (CEIS-sourced) consumed by brake Rule C alongside SVS structural context; CEIS boundary to SVS is read-only
- Notes: ceis_mfi_context_h4 and ceis_momentum_fade_m5 intentionally excluded from independent exhaustion_warning authority — macro-context false-positive prevention. H1 structural MFI exhaustion fires independently because multi-hour overbought/oversold is architecturally meaningful regardless of M5 state.

---

**PLAN-2 SVS Evolution Program**

- Program ID: PLAN-2
- Name: SVS Evolution Program (Structural Visibility Stack)
- Scope: Full structural S/R engine maturation across two slices. Slice 1 = internal SRE enrichment (`structural_sr_engine.mqh`). Slice 2 = brake-side consumption maturation (`level_awareness_brake.mqh`). Pre-Slice Layer 1 = raw S/R replacement.
- State: RUNTIME_GATE_CLOSED (2026-04-23 03:35)
- Owner: execution layer
- Why it exists: The original brake used a naive single-point fractal scan with no zone strength model and no structural class filter. SVS was built to provide proper zone objects (N=3 confirmed swings, ATR-width zones, multi-TF confluence, WEAK/MEDIUM/STRONG/MAJOR classification). Slice 1 enriched the internal zone model with 7 new fields and a diagnostic surface. Slice 2 corrected Rule F false positives and built a structural permission/obstruction model in the brake, consuming Slice 1's new query functions.
- Architecture nodes affected: ARCH-2.2 (SVS, all 6 layers), ARCH-2.2.5 (post-promotion semantics, new), ARCH-2.2.6 (query interface, 3 new functions), ARCH-2.2.7.6 (Rule F — narrowed)
- Functional nodes affected: `SRE_UpdateZones()`, `SRE_ClusterAndPromote()`, `SRE_ComputePostPromotionSemantics()`, `SRE_BuildDiagnosticSummary()`, `SRE_NearestOpposing{Credibility,Freshness,Openness}()`, `BuildLevelAwarenessBrakeReport()`, `LAB_ObstructionLabel()`, `LAB_NormBackingClass()`
- Current stage: RUNTIME_GATE_CLOSED — Slice 1 + Slice 2 source-complete, compile-verified (03:10 binary, 0 errors), runtime-verified (03:35:00 brake event in MQL5/Logs/20260423.log). LAB intercepted council-passed SELL, SRE 8+8 zones live, SRVIZ_STATUS FINAL_RUNTIME_RELIED_ON on every bar. structural_sr_engine.mqh + level_awareness_brake.mqh unfrozen. Deferred (non-blocking): Rule A WEAK/MEDIUM non-trigger observation; H4 source_tf_rank=3 direct confirmation.
- Completed stages:
  - Layer 1 (pre-Slice): Raw S/R replacement — naive fractal scan replaced with proper zone model: N=3 confirmed swings, ATR-width zones, 2-touch promotion, WEAK/MEDIUM/STRONG/MAJOR classification; brake hard-gate `opposeClass >= ZONE_STRONG` established
  - Slice 1 (internal SRE maturation): 7 new zone struct fields (freshness, persistence, credibility, openness, crowding_penalty, zone_tested, source_tf_rank); SRE_ComputeStrength enriched to 9 components (weights sum 1.00); per-TF quota pool (H4=8, H1=12, M15=16, M5=12); H4 integration (TFWeight=1.3, TFRank=3, 40-bar lookback, scanned first); post-promotion semantics (crowding + openness); credibility scan (20-bar approach evidence per pivot); 3 new query functions (SRE_NearestOpposingCredibility/Freshness/Openness); diagnostic surface (gSRELastUpdateSummary + SRE_BuildDiagnosticSummary). CLASS_CONTRACT_MODE: ENRICHMENT_WITH_LEGACY_CLASS_CONTRACT — thresholds WEAK<28/MEDIUM≥28/STRONG≥50/MAJOR≥75 preserved.
  - Slice 2 (brake-side maturation): Rule F false-positive fix (`&& opposeIsStructural` guard — WEAK/MEDIUM zones no longer hard-brake Rule F); new brake struct fields (opposing_freshness, opposing_credibility, opposing_openness, backing_class_score, obstruction_label, structural_profile); LAB_ObstructionLabel (WEAK/MODERATE/HARD/SEVERE_OBSTACLE — diagnostic only); LAB_NormBackingClass; Slice 1 query functions consumed; enriched location_context_summary (key rename opposeZone→oppClass, 4 new fields); structural_profile SVS_PROFILE diagnostic including gSRELastUpdateSummary. CLASS_CONTRACT_CONSUMPTION_MODE: LEGACY_CLASS_CONTRACT_CONSUMED — hard-brake gate preserved exactly.
- Next stage: GATE_CLOSED — no further required observation. Deferred optional follow-up: Rule A WEAK/MEDIUM non-trigger direct observation; H4 source_tf_rank=3 explicit confirmation. SVS Slice 3+ remains deferred per original design.
- Main blockers: NONE — gate closed
- Main risks:
  - SRE_ComputePostPromotionSemantics openness calculation: nearest-opposing loop must correctly exclude same-side zones; to be confirmed in first live observation bars
  - H4 lookback (40 bars): if XAUUSD H4 pivot density is low, H4 quota of 8 slots may fill sparsely — acceptable, not a blocker
  - Rule F narrowing: entries near WEAK/MEDIUM zones now pass Rule F; other rules (A–E) semantics unchanged; any unexpected Rule F bypass should be audited against zone class
- Files affected: `structural_sr_engine.mqh`, `level_awareness_brake.mqh`
- Related plans: PLAN-1 (CEIS) — brake Rule C reads CEIS `exhaustion_warning`; SVS Slice 2 does not touch this boundary. SVS and CEIS are co-resident in the brake but authority-isolated.
- Notes: SVS Slice 3 or further maturation deferred until observation window confirms Slice 1+2 jointly operational. No widening of hard-brake authority across any slice — LEGACY_CLASS_CONTRACT_CONSUMED is a hard governance invariant.

---

**PLAN-4 Council Evolution Program**

- Program ID: PLAN-4
- Name: Council Evolution Program
- Scope: Council adaptive enforcement upgrade — wire governor enforcement path, promote continuous CEIS signal to filter precision, zone coverage soft gate promotion (staged). Single-file targets per stage: `council_mode_runtime.mqh` + `council_pre_ai_filter.mqh` (Stage 1), `council_pre_ai_filter.mqh` only (Stage 2).
- State: STAGE_1_COMPLETE — Stage 2: EXECUTION_PAUSED (executive decision 2026-04-20, pending PLAN-5)
- Owner: execution layer
- Why it exists: The AI governor (ARCH-2.3.6) computes correct threshold adjustments per bar but they are discarded — enforcement gap confirmed (2026-04-18). Pre-AI filter runs at static thresholds regardless of failure pressure, CEIS state, or zone regime. The upgrade wires the existing intelligence to the existing enforcement boundary without adding new authority layers.
- Re-entry condition: PLAN-2 SVS compile + observation window complete. PLAN-4 opens only after SVS gate closes. Council source files (`council_pre_ai_filter.mqh`, `council_mode_runtime.mqh`) remain frozen until then.
- Stage 1 (G1 + G3, single compile cycle):
  - G1: Move `EvaluateCouncilAIGovernor()` + `BuildCouncilFailurePatternReport()` to before `RunCouncilPreAIFilter()` in pipeline. Add `const CouncilPolicyAdjustment &gov` to filter signature. Apply `gov.new_*` thresholds when `gov.threshold_override_enabled == true`. Structural gates (family diversity, confirm role, env score) remain governor-independent.
  - G3: Inside filter, add CEIS high-confidence tightening rider — `if(env.ceis_source_score >= threshold)` → conflict ceiling -0.05. Threshold calibrated from PLAN-1 CEIS score distribution before Stage 1 opens.
  - Observation gate for Stage 2: governor fires non-NORMAL on ≥15% of evaluated bars in a varied session; at least one entry rejected by governor-tightened thresholds that would have passed at base.
- Stage 2 (G2, post-observation): Zone coverage soft gate — implementation-ready in design, requires Stage 1 observation gate to close + coverage label distribution data.
  - Files: `council_pre_ai_filter.mqh` (signature + G2 block) + `council_mode_runtime.mqh` (filter call update). Zero other files.
  - Signature: add `ZoneCoverageReport &zc` as 4th parameter to `RunCouncilPreAIFilter()` (before `result`). Call site: pass `runtime.zone_coverage` (populated at step 3B, available at step 4 — no pipeline reordering needed). No new includes needed: `ZoneCoverageReport` already in scope via existing `council_mode_types.mqh` include.
  - Critical ordering: G2 block must go BEFORE G1 governor floor, not after G3. Reason: governor floor uses MathMax/MathMin — placing G2 before G1 means governor floor correctly overrides STRONG_DIVERSE relaxation under pressure; placing G2 after G1 would let relaxation silently undercut governor security minimum.
  - Filter block order after Stage 2: base → zone-adaptive → relative adjustments → [G2 zone coverage] → [G1 governor floor] → [G3 CEIS rider] → clamps → gates.
  - G2 block: CONFLICTED → min_required_consensus += 0.05 (unconditional; catches low-weight opposing votes that governor Case 2 misses when conflict_score < 0.50). STRONG_DIVERSE → min_required_consensus -= 0.02 (zone guard: not in REVERSAL_EXHAUSTION; governor floor overrides this if under pressure — no explicit state check needed). OVERCROWDED → deferred (fires at active_strategies>=5; with 17 strategies likely most common label on strong-consensus bars; needs live distribution before deciding). WEAK → deferred (single-strategy case is less theatrical than assumed — one voting strategy can produce consensus_strength=1.0; needs observation). NO_COVERAGE → omit (theatrical: zero active strategies already rejected by consensus gate).
  - Also add `" | coverage=" + zc.coverage_label` to filter PASS summary and `fb.` feedback record for Stage 2 observability.
  - Behavioral delta: CONFLICTED rejects bars that Stage 1 passes when governor is NORMAL and CEIS is low (adds genuine gap coverage). STRONG_DIVERSE admits bars that Stage 1 rejects when council deployment quality is verified strong (bounded relaxation under non-defensive posture). OVERCROWDED and WEAK: no change until observation data exists.
- Stage 3 (deferred, separate governance): Adaptive weights shadow activation (see PLAN-3 dormant registry).
- Architecture nodes affected: ARCH-2.3.6 (governor — enforcement gap closed), ARCH-1.3.3/ARCH-2.3.5 (pre-AI filter — signature + threshold block), ARCH-2.3.10 (orchestrator — call order), ARCH-2.3.9 (zone coverage — Stage 2 promotion)
- Authority boundary: `RunCouncilPreAIFilter()` remains sole enforcement owner. Governor becomes threshold-input supplier. MT5 authority unchanged. AI advisory → threshold-modulation intelligence only.
- Design invariant: At least 3 checks in `RunCouncilPreAIFilter()` must remain governor-independent at all times (family diversity hard reject, confirmation role hard reject, env score gate). These are the filter's permanent identity.

---

**PLAN-5 Continuation Maturity + SR-Anchor + Aggressive Governor Investigation**

- Program ID: PLAN-5
- Name: Continuation Maturity + Unified Bounded Implementation
- Scope: Causal investigation → design gate → unified implementation branch (C1/C2/C3 + PLAN-4 Stage 2A/2B in one compile cycle). Files: `council_ai_governor.mqh`, `council_pre_ai_filter.mqh`, `council_mode_runtime.mqh`.
- State: IMPLEMENTATION_SOURCE_COMPLETE — pending MetaEditor compile + observation window (2026-04-20)
- Authority: Executive Decision Memo 2026-04-20 — formal approval to open as highest-priority next branch ahead of Stage 2 execution.
- Why it exists: Live-session causal investigation (2026-04-20) confirmed VOLATILITY_SPIKE_FAILURE is a symptom label masking two distinct root causes: (1) LATE_CONTINUATION_FAILURE — council achieves maximum conviction (env=0.96–0.98, consensus=1.00, TrendJudge=TRUE) at trend maturity peaks; AGGRESSIVE governor case fires at same peak (env-triggered), reducing admission barriers at the wrong moment; (2) SR-unanchored stop failure — the sole winning trade had CANONICAL_RESISTANCE_NEAR and level_context_supported=True; 3 losing trades had LEVEL_CONTEXT_DEGRADED (87% loss rate when SR degraded in matched historical pairs). Stop geometry is not the primary discriminator: WIN avg stop=3.09pt vs LOSS avg stop=2.96pt across 85 matched pairs. Stage 2 (zone coverage soft gate) would have made zero difference to all 4 trades (consensus=1.00, conflict=0.00 in all cases). A different problem layer requires investigation before Stage 2 execution.
- Approved investigation focus (4 areas):
  - A) Late continuation vulnerability — does council reach max confidence too late in trend leg life? Does TREND_CONTINUATION zone admission lack any concept of maturity / age / leg exhaustion? What proxies exist in current source (trend_judge field, SELLw/BUYw magnitude, bar counts, vol regime duration)?
  - B) SR-anchor-dependent stop adequacy — quantify: do losses correlate with LEVEL_CONTEXT_DEGRADED (not stop size)? Is `level_context_supported` enforced or merely recorded? Does continuation_obstacle field currently influence admission in any code path?
  - C) AGGRESSIVE governor alignment — read `council_ai_governor.mqh` AGGRESSIVE case logic. Does it fire purely on high env? Does high env in TREND_CONTINUATION zone correctly trigger AGGRESSIVE, or should it trigger EXHAUSTION_SENSITIVE instead? Is this a genuine design flaw or a benign edge?
  - D) Supporting quantification — journal: TREND_CONTINUATION zone NARROW vs HIGH_CONVICTION win-rate differential; TREND_UP regime entry win rate (historical: 14L/3W = 82% loss rate warrants investigation); ExhaustionWarn directional edge confirmation (population: ~55% loss rate regardless of direction alignment — signal real, directional interpretation unreliable)
- Forbidden scope expansion: broad Council redesign, Stage 2 replacement, exit-system redesign, generic stop optimization, new AI branch, adaptive-weights activation, disguised implementation.
- Expected output: (1) clean causal diagnosis with confidence labels; (2) ranked structural weaknesses; (3) clear separation: symptom / root cause / amplifier / secondary contributor; (4) decision on whether new bounded intervention branch is justified; (5) if justified, likely shape of that future branch.
- Re-entry condition for Stage 2: PLAN-5 closes and either (a) continuation-maturity problem is minor → Stage 2 recovers immediate priority; or (b) a more urgent intervention is justified → Stage 2 sequenced after.
- Files to read (investigation scope): `council_ai_governor.mqh` (AGGRESSIVE case), `council_strategies.mqh` (trend_momentum, momentum_breakout_cont_v1, sweep_reversal logic), `council_environment.mqh` (trend maturity signals available), `council_pre_ai_filter.mqh` (continuation_obstacle usage, level_context_supported usage), journal (TREND_CONTINUATION quantification). No writes to any of these files.
- Architecture nodes relevant: ARCH-2.3.6 (governor — AGGRESSIVE case), ARCH-1.3.3/ARCH-2.3.5 (pre-AI filter — SR context, continuation_obstacle), ARCH-2.3.10 (orchestrator)
- Authority boundary: READ-ONLY for all source. No execution authority transfer. No governor authority change. MT5 sole execution authority unchanged.
- Forensic re-evaluation update (2026-04-23): VERIFIED_FROM_SOURCE + VERIFIED_FROM_RUNTIME. The old C1/C2/C3 observation blocker is not stable as written. Post-unified compile XAUUSD runtime produced 31 `TREND_CONTINUATION` decision snapshots, all `NARROW`, 0 `HIGH_CONVICTION`, and 0 `NOISY`. C1 distinct footprint is structurally shadowed by current source order: `env.ceis_overextension_m5` always propagates to `agg.exhaustion_warning`, and governor selects `EXHAUSTION_SENSITIVE` before the AGGRESSIVE branch, so a separate live C1 exclusion footprint cannot emerge as currently framed. C2 source scope is broader than the remembered acceptance rule: filter adds `+0.08` consensus whenever `env.ceis_overextension_m5` is true, regardless of zone/consensus label, but exact overextension is not durably persisted in current runtime evidence surfaces, so historical C2 activation cannot be directly proven. C3 rebind remains valid and historically reachable (27 archived XAUUSD `TREND_CONTINUATION+NOISY` events) but has not appeared in the post-rebind window: 0 `TC+NOISY` in 132 post-rebind decision snapshots; recent `NOISY` conditions were routed to `RANGE_MEAN_RECLAIM` / `NO_TRADE` / `UNDEFINED`. Sequencing implication: acceptance criteria must be rewritten before PLAN-5/P2.B blocker logic can remain binding.

---

- State update (2026-04-23 06:40:20): `IMPLEMENTATION_SURFACES_REPAIRED + COMPILE_VERIFIED + OBSERVATION_OPEN`.
- Truthful obstacle-repair implementation update (2026-04-23): BEHAVIOR_PRESERVING_SOURCE_REPAIR + COMPILE_VERIFIED. Governed backup: `D:\MT5_Project_Backups\pre_change_20260423_061358_c123_obstacle_repair.zip` (2938 selected files / 2938 archive entries / 18,230,809 bytes). Bounded evidence contract added across `council_mode_types.mqh`, `council_ai_governor.mqh`, `council_pre_ai_filter.mqh`, `council_mode_runtime.mqh`, `council_feedback.mqh`, `council_memory.mqh`, `performance_journal.mqh`, and `main_ea.mq5`. C1 is NOT behaviorally resolved; it is now durably exposed as atomic pre-governor ingredients (`c1_tc_active`, `c1_high_conviction_active`, `c1_overextension_active`), a pre-governor candidate flag, and an explicit shadowing outcome/reason when exhaustion precedence selects `EXHAUSTION_SENSITIVE`. C2 is now durably observable and locally traceable via overextension-active, tightening-applied, delta, pre/post consensus requirement, local effect flag, and gate outcome. C3 is now durably checkable via low-structure-TC-active, structure score, logic-applied, local effect flag, and gate outcome. Writers updated only for durable `council_feedback.json`, durable DECISION records in `ai_performance_journal.jsonl`, and latest-cycle `diagnostic_runtime_summary.json`; TRADE / OPEN / CLOSE journal surfaces were intentionally not widened.
- Verification note (2026-04-23): Compile log `compile_c123_obstacle_repair_20260423_064120.log` reports 0 errors and 2 unchanged warnings (`main_ea.mq5` intâ†’string warnings at lines 13840 and 14333). Observation remains OPEN because `terminal64` was not running after compile; current runtime artifacts strict-parse successfully but predate the rebuilt 06:40 binary and therefore do not yet prove live emission of the new fields.
- Stage 2 identity resolved (2026-04-26): C1/C2/C3 Shadow Validation Design = **PLAN-5 Stage 2 — Acceptance Criteria Rewrite + Shadow Validation Design**. This is NOT a new plan. Stage 1 forensic re-evaluation (2026-04-23) IS the gate that opens Stage 2 — original observation criteria are invalid (C1 structurally shadowed by governor ordering, C2 activation not durable in current surfaces, C3 absent in 132 post-rebind snapshots). Stage 2 deliverables (design-only; no source edits without authorization): (1) rewrite C1/C2/C3 behavioral correction acceptance criteria; (2) design shadow-mode implementation for each correction (files: `council_ai_governor.mqh`, `council_pre_ai_filter.mqh`); (3) define shadow observation gate. Entry condition: Stage 1 forensic findings accepted (MET). Authorization required before Stage 2 design session opens. State: DESIGN_IDENTIFIED.

---

**PLAN-6 Council Signal Supply Recovery + NO_TRADE Truth Repair**

- Program ID: PLAN-6
- Name: Council Signal Supply Recovery + NO_TRADE Truth Repair
- Scope: Bounded operational truth-recovery and signal-supply restoration program for the Council. Targets: NO_TRADE over-blocking, strategy participation collapse, unreachable compression/expansion zone paths, structural mono-family concentration in TREND_CONTINUATION, RANGE_MEAN_RECLAIM productivity truth, best_strategy dominance visibility. Does NOT include: stop/exit redesign, adaptive weights activation, AI/ATAS authority expansion, dormant-branch activation beyond explicit stage scope, broad Council redesign.
- State: APPROVED (executive execution memo adopted 2026-04-20)
- Owner: execution layer
- Why it exists: Investigation (2026-04-20) confirmed that the live Council operates as a 3–4 strategy system despite nominal 17-strategy architecture. Three compounding causes: (1) 8 strategies are hard-locked to COMPRESSION/EXPANSION zones that are never classified live — zero activation path in current runtime; (2) RANGE_MEAN_RECLAIM classified 40% of cycles but 87.1% produce zero directional votes — range strategies only fire at specific price locations; (3) NO_TRADE fires 41% of cycles at avg env_score 0.764 — the primary driver is per-bar momentum_ok (body/range < 0.35) failure, a candle-quality check that produces false market-untradability classification. Additionally, TREND_CONTINUATION is structurally mono-family (all 6 zone-specific strategies share TREND_CONTINUATION family; family_diversity_score = 0.39 with one family; HIGH_CONVICTION requires 0.60 cross-family diversity).
- Architecture nodes affected: ARCH-1.1 (environment builder — tradable gate, zone classifier), ARCH-1.3 (strategy layer — activation path), ARCH-2.3.5 (zone classification routing), ARCH-2.3.9 (zone coverage)
- Functional nodes affected: `BuildCouncilEnvironmentReport()`, `ClassifyCouncilZone()`, `RunCouncilStrategySet()` and individual strategy builders, `CouncilZoneAlignmentScore()`, `CouncilAssignStrategyMeta()`
- Current stage: Stage 2 — INVESTIGATION_COMPLETE + PATH_B_DECOMPOSITION_LOCKED | Stage 3 — IMPLEMENTED + COMPILE_VERIFIED + OBSERVATION_OPEN (2026-04-21: COMPRESSION branch in ClassifyCouncilZone() + COMPRESSION threshold block in filter; COMPRESSION appeared live per operator report)
- Completed stages: Stage 0 — COMPLETE (2026-04-20) | Stage 1 — CLOSED (2026-04-21) | Stage 2 — INVESTIGATION_COMPLETE (activation class map locked 2026-04-20)
- Stage 0 — Baseline Lock — COMPLETE (2026-04-20)
  - Baseline measurements locked: NO_TRADE rate=41.0% (872/2126 XAUUSD records), avg env_score at NO_TRADE=0.764, RANGE zero-vote rate=87.1%, effective live participation=3–4/17 strategies, sweep_reversal dominance=81.5%, TREND_CONT rejection=52.1% (184/353). Source artifact: `PLAN6_STAGE0_BASELINE.md` (DEPRECATED 2026-04-20 — content migrated here; file marked non-authoritative).
  - Exit condition: MET.
- Stage 1 — NO_TRADE Truth Repair — CLOSED (2026-04-21)
  - Implemented (council_environment.mqh): (1) `momentum_ok` removed from hard tradability gate in `BuildCouncilEnvironmentReport()` — soft path via 15% total_score weight preserved; hard gate now: `liquidity_ok && spread_ok && volatility_ok` only. (2) Tradable-but-unclassified fallback changed from `COUNCIL_ZONE_NO_TRADE` (confidence 0.45) to `COUNCIL_ZONE_RANGE_MEAN_RECLAIM` (confidence 0.38) in `ClassifyCouncilZone()`. EA reloaded 23:22 on 2026-04-20.
  - Observation evidence (2026-04-21, 47 post-Stage1 DECISION_SNAPSHOTs, 6+ hours): NO_TRADE rate 56.2%→8.5%. 4 remaining NO_TRADE: env_score 0.40–0.56, council_quality 0.08–0.11, consensus=NONE, governor=DEFENSIVE — genuinely bad conditions, not single-bar artefacts. 15 records with zone_confidence=0.38 (new fallback path exercised). Execution rate 14.9% (7/47). Reject rate in tradable zones: 70%. Reclassification audit: PASSED.
  - `council_environment.mqh`: UNFROZEN — available for Stage 3+.
  - Exit condition: MET.
- Stage 2 — Strategy Activation Path Repair — INVESTIGATION_COMPLETE + PATH_B_DECOMPOSITION_LOCKED (2026-04-20)
  - Root cause confirmed (CONFIRMED_SOURCE_TRUTH): 5 strategies (`range_compression_breakout`, `volatility_squeeze_release`, `volatility_breakout`, `expansion_continuation`, `micro_range_expansion`) are permanently gated via `CouncilIsCompressionOrExpansionAllowedZone()`. This function requires COMPRESSION or EXPANSION context. Neither is ever produced: `ClassifyCouncilZone()` never emits `COUNCIL_ZONE_COMPRESSION` (6) or `COUNCIL_ZONE_EXPANSION_CONTINUATION` (7); `market_regime.mqh` summary format (RANGE|TREND_BULL|TREND_BEAR|HIGH_VOL|TIGHT_SPREAD|CLEAN|NOISY) never contains "COMPRESSION" or "EXPANSION" text tokens. All text-fallback paths in `CouncilIsCompressionContext()` and `CouncilIsExpansionContext()` are architecturally dead. Baseline said 8 zone-dormant — reconciliation needed: 5 confirmed via COMPRESSION/EXPANSION gate; 3 remaining zero-vote strategies may be DORMANT_BY_TRIGGER_RARITY rather than DORMANT_BY_CLASSIFIER (verify in Stage 3 investigation).
  - Sub-slice map:
    - SAFE_TO_IMPLEMENT_NOW (council_strategies.mqh): NONE that activate dormant strategies. Activation class metadata is safe but non-behavioral.
    - BLOCKED_BY_FROZEN_FILE: Core repair — add COMPRESSION zone detection to `ClassifyCouncilZone()` in `council_environment.mqh`. Blocked until Stage 1 observation window closes.
    - BLOCKED_BY_ARCHITECTURE: Text-token repair in `market_regime.mqh` — not recommended (brittle pattern match, classifier path is correct repair).
    - REQUIRES_STAGE3: All compression/expansion strategy activation. Stage 3 is the governed slot.
  - Strategy activation class map (CONFIRMED_SOURCE_TRUTH 2026-04-20, 2126 XAUUSD records):
    - sweep_reversal: ACTIVE (81.5% vote share — partly a list-position artifact; true signal dominance unverified until Stage 6)
    - range_reversal: WEAKLY_ACTIVE (trigger: specific liquidity-grab locations; selectivity is design intent)
    - trend_momentum: WEAKLY_ACTIVE (TREND_CONT zone; 52% filter rejection rate)
    - momentum_breakout_cont_v1: WEAKLY_ACTIVE (TREND_CONT/BREAKOUT zone; frequency limited by zone reach)
    - breakout_momentum_v2: WEAKLY_ACTIVE (BREAKOUT zone dependency; zone fires rarely in observed data)
    - mean_reversion_range: WEAKLY_ACTIVE (RANGE zone; trigger location-selective)
    - fake_break_reversal: WEAKLY_ACTIVE (SR-proximity; fires across multiple zones)
    - continuation_pullback_v1: WEAKLY_ACTIVE (TREND_CONT; structurally similar to trend_momentum)
    - macd_reversal: WEAKLY_ACTIVE (RANGE/REVERSAL zones; trigger signal dependent)
    - confluence_reversal: WEAKLY_ACTIVE (multi-zone; trigger demanding)
    - sr_bounce_reversal: WEAKLY_ACTIVE (SR proximity dependent)
    - range_compression_breakout: DORMANT_BY_CLASSIFIER (COMPRESSION zone never produced)
    - volatility_squeeze_release: DORMANT_BY_CLASSIFIER (COMPRESSION zone never produced)
    - volatility_breakout: DORMANT_BY_CLASSIFIER (EXPANSION context never produced)
    - expansion_continuation: DORMANT_BY_CLASSIFIER (EXPANSION zones never produced)
    - micro_range_expansion: DORMANT_BY_CLASSIFIER (COMPRESSION/EXPANSION context never produced)
    - [6th zero-vote strategy from baseline]: DORMANT_BY_TRIGGER_RARITY or DORMANT_BY_CLASSIFIER — requires Stage 3 verification
  - Path determination: PATH_B (IMPLEMENTATION_READY_DECOMPOSITION_ONLY). No safe non-overlapping slice exists in council_strategies.mqh alone that activates dormant strategies. Formal Stage 3 kickoff authorized after Stage 1 observation closes.
  - Exit condition: MET at investigation/mapping level (activation class map complete). Behavioral correction deferred to Stage 3.
- Stage 3 — Compression/Expansion Reachability Repair
  - Six strategies (range_compression_breakout, volatility_squeeze_release, volatility_breakout, expansion_continuation, micro_range_expansion, fake_break_reversal) have zero lifetime XAUUSD participation. Five of these require COMPRESSION or EXPANSION zones that ClassifyCouncilZone never produces in live operation. Determine: should these zones be reachable live? If yes, restore bounded classifier path. If no, formally reclassify linked strategies as NON_LIVE/DEFERRED/RESERVED. Reachability truth, not activation mandate.
  - Exit condition: Compression/expansion strategy families no longer exist in silent contradiction between architecture and runtime.
- Stage 4 — TREND_CONT Participation and Diversity Repair
  - All 6 TREND_CONTINUATION zone-specific strategies share the TREND_CONTINUATION family → diversity_score=0.39 with any combination → HIGH_CONVICTION structurally unreachable without reduced-eligibility cross-zone co-fire. Review family mapping, cross-family participation paths, and whether diversity thresholds are calibrated to the actual strategy architecture. Must not become broad consensus redesign.
  - Exit condition: TREND_CONTINUATION no longer relies on effectively mono-family structure for most live cycles.
- Stage 5 — RANGE Productivity Truth Repair
  - Distinguish correct-low-productivity-by-design from excessive starvation. Review whether range trigger conditions (edge touch, mid-reclaim, bounce patterns) are correctly restrictive or artificially suppressive. No mandate to loosen logic — truth-and-productivity review only.
  - Exit condition: Clear judgment exists on whether low range productivity is healthy design or boundedly correctable.
- Stage 6 — Best-Strategy Dominance Truth Review
  - sweep_reversal appears as best_strategy_id in 81.5% of XAUUSD events primarily due to position #1 in RunCouncilStrategySet ordering (any non-zero score_final wins when all others return 0). This distorts visibility surfaces. Review score vs weight vs ordering effect. Distinguish true signal dominance from visibility artifact.
  - Exit condition: best_strategy visibility becomes trustworthy for runtime interpretation.
- Stage 7 — Full Post-Fix Suppression Re-Measurement
  - Re-measure live system against Stage 0 baseline. Required report: PLAN-6 Post-Fix Trade Flow Suppression Map — updated NO_TRADE rate, updated strategy participation breadth, updated zone productivity, updated suppression ranking, updated TREND_CONT rejection structure. Must answer: did live operation move meaningfully closer to architectural truth?
  - Exit condition: New suppression map exists and is trustworthy enough to set next program priority.
- Next stage: Stage 3 — Compression/Expansion Reachability Repair (AUTHORIZED 2026-04-21 — Stage 1 closed, council_environment.mqh unfrozen; entry condition met; sequenced after Stage 2B defect fix in council_pre_ai_filter.mqh)
- Main blockers: Stage 3 opening sequenced after Stage 2B placement fix (not a hard dependency, but avoids opening council_environment.mqh while council_pre_ai_filter.mqh has a pending bounded defect fix).
- Main risks:
  - Stage 1 (NO_TRADE repair): `momentum_ok` fix could over-open trade flow if not properly bounded — reclassification audit is mandatory gate (OBSERVATION_OPEN)
  - Stage 3 (compression/expansion reachability): adding new zone types to ClassifyCouncilZone could produce unexpected zone routing in edge cases — requires conservative scope and review
  - Stage 4 (diversity repair): family remapping could affect consensus classification in ways that interact with PLAN-5 changes — careful sequencing with post-PLAN-5 observation required
- Files affected: `council_environment.mqh` (Stage 1 — MODIFIED + FROZEN), `council_strategies.mqh` (Stage 2/3/4 — unmodified, Stage 2 investigation complete), `council_mode_types.mqh` (Stage 3 if new zone types added).
- Related plans: PLAN-5 (unified branch must be compile-verified before PLAN-6 Stage 1 opens) | PLAN-2 (SVS compile gate should close before Stage 1) | PLAN-1 CEIS (observation window ongoing — no interaction with PLAN-6 stages)
- Notes: The decisive sentence from the memo governs execution: "PLAN-6 is not intended to make the system trade more by force. It is intended to make the Council more operationally honest, less artificially starved, and more aligned with its own architectural promise before any later performance or expansion decisions are made." Governing principle: Truth first → activation second → diversity third → productivity fourth → re-measure last.

---

**PLAN-RC Regime Provenance + Serialization Contradiction Repair**

- Program ID: PLAN-RC
- Name: Regime Provenance + Serialization Contradiction Repair
- Scope: Bounded surgical repair for regime provenance ambiguity across decision-time vs close-time serialization surfaces. Explicit source/time-basis tagging for `regime_label` and `regime_summary` without changing decision policy, thresholds, governor behavior, execution routing, or authority boundaries.
- State: IMPLEMENTED + COMPILE_VERIFIED + OBSERVATION_OPEN (2026-04-21)
- Owner: execution layer
- Why it exists: Runtime artifacts reused the same field name (`regime_label`) across multiple semantic/time contexts (decision-time RC label vs close-time RC label) without explicit provenance metadata, allowing replay/diagnostic consumers to treat unlike semantics as if they were identical.
- Architecture nodes affected: ARCH-1.1 (runtime journaling/diagnostic emission), ARCH-2.3 (Council decision artifact path), replay diagnostic summary surfaces
- Functional nodes affected: `PJ_BuildDecisionJson*()`, `PJ_BuildCouncilAttributionJson()`, `PJ_BuildCouncilOutcomeAttributionJson()`, `PJ_BuildTradeJson()`, `TradeFeedbackRecordToJson()`, `ReplayBuildCandidateFromLatest*()`, `BuildReplayValidationSummary*()`
- Current stage: Stage 3 — IMPLEMENTED + COMPILE_VERIFIED | Stage 4 — OBSERVATION_OPEN
- Completed stages:
  - Stage 0 (cold backup gate): COMPLETE. Full-system backup created and verified before edits: `backup_archives/pre_change_20260421_224731_regime_contradiction_full_system.zip` (2931 entries, 18,636,232 bytes, governed root coverage confirmed for `MQL5/Experts/AI` + `MQL5/Files/AI` including docs and external_adapter path).
  - Stage 1 (forensic mapping): COMPLETE. Root cause ranked as serialization/provenance contradiction + naming ambiguity, not safe broad ownership unification.
  - Stage 2 (surgical patch): COMPLETE. Added explicit provenance fields:
    - `regime_label_source`, `regime_label_semantics`, `regime_label_time_basis`
    - `regime_summary_source`, `regime_summary_semantics`, `regime_summary_time_basis`
    - Added `regime_summary` to TRADE journal serialization and replay provenance carry-through/fallback.
  - Stage 3 (compile verification): COMPLETE. `main_ea.mq5` compiled via MetaEditor log `compile_regime_contradiction_repair_20260421_232450.log` with 0 errors, 2 pre-existing warnings.
- Next stage: Stage 4 — observation closure gate (confirm fresh runtime records include provenance fields across DECISION/TRADE/replay surfaces and that consumer coherence remains intact).
- Main blockers: No post-compile decision/trade cycle observed yet in current window; runtime evidence is pending.
- Main risks:
  - Downstream external readers that assume fixed schemas may ignore new optional fields (low risk; additive contract only).
  - Provenance defaults in replay path are deterministic but still inferred when reading older records that lack new fields.
- Files affected: `performance_journal.mqh`, `trade_feedback.mqh`, `main_ea.mq5`
- Related plans: PLAN-6 (operational-truth program alignment), PLAN-5 (no behavioral overlap; authority-preserving isolation maintained)
- Notes: No changes to governor thresholds, pre-AI admission gates, risk policy state transitions, execution authority, AI authority, or trade routing behavior.

---

**PLAN-ARCH-DR Dual-Regime Architecture Declaration and Resolution**

- Program ID: PLAN-ARCH-DR
- Name: Dual-Regime Architecture Declaration and Resolution
- Scope: Governance declaration, surface ownership assignment, and staged surgical resolution of the dual-regime architecture gap. Two independently-computing regime systems (gRegime / REGIME_CLASSIFICATION_V1 and MarketRegimeSnapshot → council zone) operate with partial vocabulary overlap, five confirmed surface violations, and no prior explicit authority contract. This program declares the canonical roles (ERA/ExRA), assigns surface ownership, and stages the surgical repair path (P1–P4). Stage P1 = documentation only. No code changes in any stage until explicitly authorized.
- State: STAGE_P3_3_IMPLEMENTED_COMPILE_VERIFIED + P2A_FULLY_CLOSED + THREE_CHAIN_DOCTRINE_DECLARED + SIXTH_VIOLATION_REGISTERED (2026-04-22) | P2.B NEXT GATE (blocked by PLAN-2+Stage3+C1/C2/C3)
- Deep architecture truth addendum (2026-04-22): VERIFIED_FROM_SOURCE + VERIFIED_FROM_RUNTIME. The program remains valid at the high level (ERA=gRegime, ExRA=council zone), but the topic is now confirmed to involve three primary chains plus a wider derivative network. Primary chains: `MarketRegimeSnapshot`, `RegimeClassificationV1`/`gRegime`, and council environment -> zone/zone_semantic. Derivative/consumer network explicitly confirmed: legacy strategy runtime, zone coverage, dirty-environment gate, strategy intelligence, institutional learning, strategy confidence memory, journal analytics / AI operational review, replay arbitration, dashboard aggregation, AI advisory identity, and a dormant reinforcement path. Prior summaries that treated the topic as only a dual-surface issue are therefore incomplete. Adopted doctrine (Mission 8, 2026-04-22): stronger separation but not full severance — shared indicator foundations (EMA20/50, ATR14 M1/M5 used by both gRegime and MarketRegimeSnapshot) are deliberate design, not contamination; bridge is measurement-only (P2.B adds gRegime to DECISION record; P3.1B adds zone_bucket to learning motif); bridge must never be used for governance, control, threshold modification, or veto logic. P2.A precision correction (Mission 9, 2026-04-22): behavior is bounded (no execution logic changed, causality=C, zero non-P2.A drift) BUT NOT contract-closed — TRADE records in ai_performance_journal.jsonl contain malformed JSON (double commas before provenance block, e.g., field value followed by ",,") causing strict json.loads() parse failures; substring/regex workarounds confirm field presence but JSON contract integrity is broken; replay blank provenance for empty regime_label bars is correct-by-design but constitutes an observability gap. Sixth violation confirmed (Mission 8 source investigation): LEARNING_CONTAMINATION — `ILV1_BuildMotifKey()` at `institutional_learning_layer_v1.mqh:338` keys all council-mode advisory learning motifs solely by gRegime `regime_bucket` (populated via `ILV1_BuildDecisionContext()` at line 1311 from `reg.regime_label`) with NO council zone component; `ILV1_DecisionContext` struct has no `zone_bucket` field; two distinct routing situations (REVERSAL_EXHAUSTION and RANGE_MEAN_RECLAIM) under the same gRegime accumulate outcomes into the same motif bucket — learning contamination across distinct routing situations; advisory evidence is misassigned; repair stage P3.1B. P3.1 restructured as one AI deconfliction bundle (Mission 9): P3.1A = AI scope/signature rebind (`main_ea.mq5:7568`); P3.1B = institutional learning motif-key extension (add `zone_bucket` field to `ILV1_DecisionContext` + extend `ILV1_BuildMotifKey()` with `|zone=<zone_bucket>` component); P3.1A without P3.1B is insufficient — advisory records would be looked up by council zone key but the motif database was built from gRegime-keyed experiences, producing an incompatible hybrid.
- Owner: execution layer / architecture governance
- Why it exists: Forensic investigation (2026-04-21) confirmed the dual-regime structure is Model C — a valid design that drifted into ambiguity. The two systems serve genuinely different layers (admission vs routing) but five surfaces cross-read without reconciliation contracts, producing silent behavioral asymmetries. The dead fallback in `council_strategies.mqh` (`CouncilIsCompressionContext` line 737–739: string search for "COMPRESSION" in `env.regime_summary` which is a MarketRegimeSnapshot pipe string and never contains "COMPRESSION") is the strongest drift evidence. The architecture gap was acknowledged in PLAN-RC as deferred to Stage 4+ — this program is the formal entry for that deferred gap.
- Architecture nodes affected: ARCH-1.1 (`main_ea.mq5` — CouncilDirtyEnvironmentGate, AI scope key), ARCH-2.3.5 (strategy intelligence layer, journal analytics), ARCH-1.3 (`council_strategies.mqh` dead fallback), ARCH-2.3.10 (orchestrator regime sequence)
- Canonical authority declarations (CONFIRMED_ARCHITECTURAL_DECISION, 2026-04-22):
  - **ERA = gRegime (REGIME_CLASSIFICATION_V1)** — External Regime Authority. Governs: trade admission gates (`main_ea.mq5:10541`), CouncilDirtyEnvironmentGate (`main_ea.mq5:9633`), AI scope key (`main_ea.mq5:7568`), failure classification (`failure_taxonomy.mqh`), journal analytics stratification (`journal_analytics.mqh`). Source: `BuildRegimeClassificationV1()` in `regime_classification_layer_v1.mqh`. 8-label output. Confidence 0.55–0.85.
  - **ExRA = council zone (ClassifyCouncilZone)** — Execution Routing Authority. Governs: strategy eligibility (`council_strategies.mqh` `CouncilAssignStrategyMeta`), zone alignment scoring (`council_strategies.mqh:435`), filter thresholds (`council_pre_ai_filter.mqh` zone-adaptive blocks), preferred/blocked style. Source: `ClassifyCouncilZone()` in `council_environment.mqh`. 7-label output including `COUNCIL_ZONE_COMPRESSION=6` (post PLAN-6 Stage 3).
- Surface ownership map (CONFIRMED_SOURCE_TRUTH 2026-04-22):

  | Surface | Authority Layer | Owner | Status |
  |---------|----------------|-------|--------|
  | Trade admission gate (`main_ea.mq5:10541`) | ERA | gRegime | CORRECT |
  | CouncilDirtyEnvironmentGate (`main_ea.mq5:9633`) | ERA | gRegime | HARMFUL — post-routing ERA veto of ExRA decision |
  | AI scope key (`main_ea.mq5:7568`) | ERA (BOUNDARY_VIOLATION) | gRegime (current) | BOUNDARY_VIOLATION |
  | Failure classification (`failure_taxonomy.mqh`) | ERA | gRegime | CORRECT |
  | Journal analytics stratification (`journal_analytics.mqh`) | ERA (ANALYTICS_MISMATCH) | gRegime (current) | ANALYTICS_MISMATCH |
  | Strategy eligibility routing (`council_strategies.mqh`) | ExRA | council zone | CORRECT |
  | Zone_alignment_score (`council_strategies.mqh:435`) | ExRA | council zone | CORRECT |
  | Filter thresholds (`council_pre_ai_filter.mqh`) | ExRA | council zone | CORRECT |
  | Strategy intelligence trendish/rangish (`strategy_intelligence_layer_v1.mqh:337`) | ExRA (BOUNDARY_VIOLATION) | gRegime (current — wrong) | BOUNDARY_VIOLATION |
  | Dead fallback `CouncilIsCompressionContext` (`council_strategies.mqh:737`) | DEAD | N/A | DEAD |
  | Institutional learning motif key (`institutional_learning_layer_v1.mqh:338`) | ExRA (BOUNDARY_VIOLATION) | gRegime (current — wrong) | LEARNING_CONTAMINATION |

- Six confirmed surface violations:
  1. **CouncilDirtyEnvironmentGate asymmetry** (HARMFUL): `main_ea.mq5:9633–9652` — gRegime="COMPRESSION" blocks execution AFTER council has already routed to a zone (may be TREND_CONTINUATION). ERA post-routing veto of ExRA decision with no reconciliation clause. Repair stage: P4 (data-dependent — needs frequency/impact measurement).
  2. **AI scope key mismatch** (BOUNDARY_VIOLATION): `main_ea.mq5:7568` — AI advisory memory indexed by `gRegime.regime_label`. AI advisory is a council-mode execution tool; its scope key should be ExRA-indexed. Repair stage: P3.1.
  3. **Strategy intelligence mismatch** (BOUNDARY_VIOLATION): `strategy_intelligence_layer_v1.mqh:337–338` — COMPRESSION classified as "rangish" using gRegime. When gRegime=COMPRESSION AND council_zone=TREND_CONTINUATION, strategy intelligence cross-reads wrong authority. Repair stage: P3.2.
  4. **Journal analytics mismatch** (ANALYTICS_MISMATCH): `journal_analytics.mqh` reads `regime_label` (gRegime) only at lines 494, 765, 900, 2030. All council-mode performance analytics stratified by admission authority, not routing authority. Repair stage: downstream of P2.B — bridge field in DECISION record is prerequisite infrastructure; analytics consumer update is a separate downstream stage.
  5. **Dead fallback cleanup** (DEAD): `council_strategies.mqh:737–739` `CouncilIsCompressionContext()` string search for "COMPRESSION" in `env.regime_summary` (MarketRegimeSnapshot pipe string `RANGE|TREND_BULL|TIGHT_SPREAD|CLEAN` etc.) is permanently dead. Comment "Zone COMPRESSION may not exist in baseline" is pre-Stage-3 era relic. Repair stage: P3.3.
  6. **Institutional learning motif key contamination** (LEARNING_CONTAMINATION): `institutional_learning_layer_v1.mqh:338` `ILV1_BuildMotifKey()` — all council-mode advisory learning motifs keyed by gRegime `regime_bucket` (set via `ILV1_BuildDecisionContext()` line 1311: `ctx.regime_bucket = reg.regime_label`) with NO council zone component. `ILV1_DecisionContext` struct (lines 35–64) has no `zone_bucket` field. Two distinct routing situations (REVERSAL_EXHAUSTION and RANGE_MEAN_RECLAIM) under the same gRegime accumulate outcomes into the same motif bucket — learning contamination across distinct routing situations. Advisory evidence from qualitatively different execution contexts is misassigned to a single motif. Repair stage: P3.1B (part of P3.1A+P3.1B AI deconfliction bundle — must implement together).
- Staged repair path:
  - **Stage P1 — Governance Declaration** (COMPLETE 2026-04-22): PIML PLAN-ARCH-DR entry + ERA/ExRA declarations. AGENTS.md Regime Authority Discipline section. OPERATION_GUARDRAILS.md active risk entries. No code changes.
  - **Stage P2.A — Provenance Re-Application + JSON Contract Closure** (FULLY_CLOSED 2026-04-22): VERIFY_PASSED_FROM_EQUIVALENCE_AUDIT + OBSERVATION_CONFIRMED (behavioral provenance) + RUNTIME_CONTRACT_CONFIRMED (JSON fix). Three provenance helper functions in performance_journal.mqh corrected (double-comma separator defect). Runtime evidence: 8 post-fix DECISION + 1 post-fix TRADE — all json.loads() PASS, all provenance fields intact, no separator defects. P2.A FULLY CLOSED.
  - **Stage P2.B — gRegime Bridge Fields** (FULLY_CLOSED — RUNTIME_CONFIRMED 2026-04-25 14:58:40): DECISION BTCUSD-1777129120-100035-12 strict-parsed — 5 ExRA fields confirmed (zone_name=RANGE_MEAN_RECLAIM, zone_type=4=COUNCIL_ZONE_RANGE_MEAN_RECLAIM, zone_confidence=0.5200, preferred_style=MEAN_RECLAIM, blocked_style=BREAKOUT); ERA intact (regime_label=RANGE_BALANCED, regime_tradability=0.6354, provenance 3-field block intact); 0 double-commas; C1/C2/C3 C123_OBSERVABILITY_V1 intact; diagnostic cross-ref consistent; authority boundary confirmed (measurement-only: final_decision=REJECT by council_pre_ai_rejection, bridge fields not on decision path). STAGE CLOSED.
  - **Stage P3.1A — AI Scope Key Fix** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED 2026-04-25 16:51:37): `CouncilAIAdvisoryBuildCandidateScope()` + `CouncilAIAdvisoryBuildCandidateSignature()` in main_ea.mq5 now use V2 ExRA-primary identity. Scope format: `COUNCIL|V2|<direction>|<zone_text>|<best_strategy_id>`. Signature format: `V2|<direction>|<zone_text>|<strategy_family>|<best_strategy_id>`. Valid council context uses `CouncilZoneTypeToText(routed.council.env.zone_type)`; defensive non-council fallback remains `gRegime.regime_label`. `zone_semantic` removed from advisory identity key material. No migration, no dual-read, no authority change.
  - **Stage P3.1B — Institutional Learning Motif-Key Extension** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_CONFIRMED 2026-04-25 16:51:37): `ILV1_DecisionContext` now carries `zone_bucket` after `regime_bucket`; `ILV1_InitDecisionContext()` initializes it to empty; `ILV1_BuildContextFromRouted()` populates it from `CouncilZoneTypeToText(routed.council.env.zone_type)` only in valid council context; `ILV1_ContextToJson()` and `ILV1_ParseContextLine()` persist/reconstruct it for outcome correlation while old records parse safely with default empty zone. `ILV1_BuildMotifKey()` now emits `keyver=2|strategy=...|direction=...|regime=...|zone=...|vol=...|struct=...|setup=...|sr=...|contradiction=...`. `ILV1_MotifStat` unchanged. Clean V2 silent orphaning active: no migration, no backfill, no dual-read, no v1 compatibility bridge.
  - **Stage P3.2 — Strategy Intelligence Fix** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_SIGNAL_PENDING 2026-04-25 17:55:36): `ComputeEntryQualityV1()` in `strategy_intelligence_layer_v1.mqh` now accepts `CouncilZoneType council_zone_type` as 5th parameter; when `activeMode == "COUNCIL"` and zone_type is not UNDEFINED, trendish/rangish classification uses ExRA council zone (trendish: TREND_CONTINUATION, BREAKOUT_EXPANSION, EXPANSION_CONTINUATION; rangish: RANGE_MEAN_RECLAIM, RANGE_BALANCED, RANGE_DIRTY, COMPRESSION); non-council and UNDEFINED-zone paths fall through to ERA `reg.regime_label` unchanged (zero behavioral delta for GATE/SCORE/HYBRID). `#include "council_mode_types.mqh"` added to `strategy_intelligence_layer_v1.mqh` (no circular dependency: council_mode_types includes only config_loader + atas_runtime_contract). Call site updated at `main_ea.mq5:12246` and shadow call site at `shadow_replay_engine.mqh:379` — both now pass `routed.council.env.zone_type` / `shadowRouted.council.env.zone_type`. `ComputeStrategyRegimeFitV1()` unchanged (uses ERA style-tag path, separate from P3.2 scope). Compile: 0 errors, 2 pre-existing warnings (int→string at main_ea.mq5 lines 13848/14342 — shifted from prior 13705/14197 by earlier insertions, unchanged warnings). Backup: `pre_change_20260425_174738_p3_2_strategy_intelligence_authority_fix.zip` (25,872,631 bytes). Log: `compile_p3_2_strategy_intelligence_authority_fix_20260425_175536.log`. **Post-reload runtime verification (2026-04-25 22:27:36):** EA confirmed running with binary 19:58:40; one post-binary trade opened and closed (BTCUSD-1777153870-100135-31, 21:52:33). P3.2 path NOT exercised: `strategy_intelligence_enabled = false` in active plan `plan_v076` (default from `config_loader.mqh:802` — not overridden in `ai_current_plan.json`). `gHasStrategyIntel = false` for all current decisions; `ComputeEntryQualityV1()` never called. DECISION record confirms: `decision_quality_version: ""`, all strategy intelligence scores 0, all labels empty. P3.2 RUNTIME_PENDING — **plan-configuration-gated, not market-condition-gated.** Runtime confirmation requires `strategy_intelligence_enabled: true` and `entry_quality_scoring_enabled: true` in active plan.
  - **Stage P3.2-S — expected_rr_estimate Observability Repair** (IMPLEMENTED + COMPILE_VERIFIED + FIX1_RUNTIME_CONFIRMED 2026-04-25 19:58:40): Root cause: two-site defect — (1) `InitUnifiedDecisionConfidence()` in `unified_confidence.mqh` omitted all 8 "Execution Estimation (v3)" fields (lines 38-46 of struct: `expected_stop_distance`, `expected_target_distance`, `expected_rr_estimate`, `adverse_excursion_risk_score`, `favorable_excursion_potential_score`, `execution_geometry_score`, `execution_geometry_label`, `execution_geometry_reason`); (2) `main_ea.mq5` computed correct clamped value into `gExecEstimation.expected_rr_estimate` (via `ComputeExecutionEstimationV1`, clamped [0.10, 5.0]) but never copied it to `out.expected_rr_estimate` (`UnifiedDecisionConfidence`) — ILV1 reads from `UnifiedDecisionConfidence`, not `gExecEstimation`. Impact: OBSERVABILITY ONLY — execution authority, risk, governor, routing, motif keys, and DECISION journal records all unaffected. Affected surfaces: ILV1 decision context JSONL `expected_rr_estimate` field (garbage ~9.78e+184); `trade_feedback.mqh` `out_vs_expected_rr` always = HIGH_QUALITY_WIN/LOSS (garbage > 0.0 guard, always ≥ 1.6). Fix 1: Added 8 field initializations to `InitUnifiedDecisionConfidence()` after `c.follow_through_reason = ""` line (safe defaults: 0.0 for doubles, "" for strings). Fix 2: Added 8-line copy block from `gExecEstimation` to `out` inside `if(gHasExecEstimation)` block in `main_ea.mq5` after `out.decision_quality_version = "DQ_V3"`. Compile: 0 errors, 2 pre-existing warnings (int→string at main_ea.mq5 lines 13856/14350 — shifted by 8 from prior 13848/14342 confirming only the 8 copy lines were added). Binary: main_ea.ex5 2026-04-25 19:58:40. Backup: `pre_change_20260425_194931_p3_2_rr_estimate_repair.zip` (25,238,522 bytes). Log: `compile_p3_2_rr_estimate_repair_20260425_195431.log`. **Post-reload runtime verification (2026-04-25):** Fix 1 (init) RUNTIME_CONFIRMED — pre-repair: `expected_rr_estimate ≈ 9.78e+184` (ILV1 context record 87, captured 16:51:37); post-repair: `expected_rr_estimate = 0.000` (ILV1 context record 88, captured 21:52:33) and TRADE close record (ts 21:54:36, `expected_rr_estimate: 0.0`). Feedback corruption eliminated: 0.0 correctly fails `> 0.0` guard in `trade_feedback.mqh` — `out_vs_expected_rr` corruption path blocked. Fix 2 (copy block) plan-gated: `execution_estimation_enabled` not enabled in `plan_v076`; both `gHasStrategyIntel` and `gHasExecEstimation` remain false under current plan. FIX1_RUNTIME_CONFIRMED / FIX2_COMPILE_VERIFIED_PLAN_GATED.
  - **Stage P3.3 — Dead Fallback Cleanup** (IMPLEMENTED + COMPILE_VERIFIED 2026-04-22): Removed permanently dead string-search fallback clauses from both `CouncilIsCompressionContext()` and `CouncilIsExpansionContext()` in `council_strategies.mqh`. Each function now contains only the active `env.zone_type` enum condition. Both regime_summary and zone_name string-search branches confirmed dead from source: `env.regime_summary` is a MarketRegimeSnapshot pipe string whose complete token vocabulary (TREND_BULL/TREND_BEAR/RANGE, HIGH_VOL/LOW_VOL/NORMAL_VOL, TIGHT_SPREAD/WIDE_SPREAD/NORMAL_SPREAD, CLEAN/NOISY) never contains "COMPRESSION" or "EXPANSION"; `env.zone_name` = "UNDEFINED" for COMPRESSION zone (CouncilZoneTypeToText has no case for COUNCIL_ZONE_COMPRESSION=6). Expansion zone_name clause redundant/dead (BREAKOUT_EXPANSION caught by clause 1 first; EXPANSION_CONTINUATION maps to "UNDEFINED"). Compile: 0 errors, 2 pre-existing warnings (lines 13705/14197 int→string, unchanged). main_ea.ex5 updated Apr 22 21:57. Behavioral impact: NONE — dead fallbacks never fired; all callers (CouncilIsCompressionOrExpansionAllowedZone, 5 strategy admission gates) unaffected. Backup: `pre_change_20260422_215019_p3_3_dead_fallback_cleanup.zip` (2,936 files, 18,826,803 bytes). No prerequisite gate — executed independently as per doctrine sequencing.
  - **Stage P4 Option 1 — Dirty Environment Observability Annotation** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-26 02:07:26): DECISION-only `p4_dirty_env_*` fields record counterfactual legacy dirty-gate would-block assessment, raw ERA/ExRA measurements, threshold evidence, and divergence state. The measurement intentionally ignores `EnableCouncilDirtyEnvironmentTightening` for counterfactual assessment while recording the flag as `p4_dirty_env_legacy_gate_enabled`. Action is always `OBSERVED_ONLY`. Legacy dirty blocking branches remain dormant/unchanged; no blocking behavior enabled, no authority transfer, no final decision impact, no lifecycle invalidation, no risk/governor/routing/pre-AI change. Options 2/3/4 remain unimplemented and require evidence sample plus explicit user approval.
  - **V1-B0+B — COUNCIL-only Shadow State + Policy Annotation** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-26 15:39:38): Bounded Version 1 shadow package added without live authority transfer. V1-B0: `SI_InferStyleTag()` / `ComputeStrategyRegimeFitV1()` gained additive zone-aware overloads; live COUNCIL strategy-regime-fit call now passes `routed.council.env.zone_type`, while existing callers retain old ERA fallback behavior. V1-B: new `council_v1_state_composer.mqh` builds pure shadow state/policy annotations; `performance_journal.mqh` emits DECISION-only `v1_shadow_*` fields; `main_ea.mq5` sets the V1 snapshot before all 6 active DECISION appends. Non-COUNCIL/invalid council emits `V1_NOT_APPLICABLE_NON_COUNCIL`; no ExRA is inferred outside valid COUNCIL. No policy matrix authority, no Version 1 live authority, no specialist suppression, no DQ/P4 activation, no score/coherence fields, no final decision/permission/risk/governor/routing/pre-AI/plan/config change.
  - **V1 Complete Shadow Observability Package — V1-C/D/E/F** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-26 21:34:20): Extends V1-B DECISION annotation with explicit `V1_POLICY_SPECIALIST_MAP_V1` role-map fields, live-family role/alignment, counterfactual recommendation, promotion readiness, and `V1_SCORING_QUARANTINE_V1` diagnostics. Existing V1-B fields remain backward-compatible. Package is shadow observability only: no live V1 authority, no specialist influence/suppression, no policy matrix authority, no DQ/P4 activation, no final decision/permission/risk/governor/routing/pre-AI/execution/plan/config change. Runtime field observation pending because `terminal64` is not running and latest runtime artifacts predate `main_ea.ex5` timestamp 2026-04-26 21:34:20.
  - **V1-FSW Phase 1 — Family Soft-Weight Live Influence Spine** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-27 04:25:27): Adds bounded COUNCIL-only specialist/family weight influence inside `BuildCouncilAggregateReport()`. `EnableV1LiveInfluencePhase1` is an EA input default false. Disabled path emits `v1_fsw_enabled=false`, `DISABLED_NO_ADJUSTMENT`, 1.00 multipliers, zero deltas, and no live influence. Enabled path may indirectly affect `final_decision` through bounded aggregation weights only; no direct `final_decision` / `final_permission` override, no hard veto, no zero multiplier, and no risk/governor/pre-AI/P4/DQ/AI/ATAS/plan authority activation. Adds early V1 context helpers, exact delimiter-safe CSV family matching, FSW aggregate fields, DECISION-only `v1_fsw_*` serialization, and advances `v1_shadow_scoring_quarantine_version` to `V1_SCORING_QUARANTINE_V2_FSW`. Compile log: `compile_v1_fsw_phase1_20260427_041701.log`, 0 errors / 2 unchanged warnings. Runtime pending because `terminal64` was not running after compile.
- **V1-FSW Phase 1 — Family Soft-Weight Live Influence Spine** (RUNTIME_CONFIRMED_ACTIVE_EFFECTIVE 2026-04-27): Runtime closure supersedes the pending entry above. Strict parse of `ai_performance_journal.jsonl` found 45 V1-FSW DECISION records, 0 parse errors, and 14 records with nonzero `v1_fsw_total_weight_delta`. Evidence record `XAUUSD-1777287329-100509-60` confirms `sweep_reversal|LIQUIDITY_REVERSAL|CONDITIONAL|0.90|0.4264|0.3838|-0.0426`, with `v1_fsw_enabled=true`, `SPECIALIST_WEIGHT_ADJUSTED`, and bounded aggregation-weight influence only. No direct final decision/permission override and no P4/DQ/AI/ATAS/risk/governor/pre-AI/plan activation.
- **V1 Phase 2+3 — Policy-Guided Participation Expansion + Scoring Quarantine Enforcement** (ARCHITECTURE_PREPARED_CODEX_READY 2026-04-27): Current accepted mission and source preflight define the next bounded COUNCIL-only extension over V1-FSW: Phase 2 state-specific multiplier expansion behind `EnableV1LiveInfluencePhase1 && EnableV1PolicyGuidedParticipation`, vocabulary fixes for `REVERSAL_ERA_RANGE_EXRA` and `ANY_ERA_NO_TRADE_ZONE`, mapped-vs-nonzero impact observability correction, unknown-family diagnostics, and Phase 3 exact `v1_score_quarantine_*` DECISION fields. No direct final decision/permission override, no hard veto, no zero multiplier, no DQ/P4/Dirty Gate/AI/ATAS/risk/governor/pre-AI activation, no plan JSON edit, no production-ready claim.
- **V1 Phase 2+3 — Policy-Guided Participation Expansion + Scoring Quarantine Enforcement** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-27 14:42:54): Adds `EnableV1PolicyGuidedParticipation=false` and `EnableV1ScoreQuarantineDiagnostics=true` EA inputs; Phase 2 effect requires both Phase 1 and Phase 2 flags. Adds `REVERSAL_ERA_RANGE_EXRA` and `ANY_ERA_NO_TRADE_ZONE`; Phase 2 multipliers remain categorical-only and clamped [0.85, 1.05]. Adds mapped/nonzero count split while preserving `v1_fsw_influenced_strategy_count` as mapped alias, role-specific nonzero counts, unknown-family warning, corrected action semantics, and exact `v1_score_quarantine_*` DECISION fields. `v1_shadow_scoring_quarantine_version` advanced to `V1_SCORING_QUARANTINE_V3_ENFORCEMENT`. Compile log `compile_v1_phase2_phase3_20260427_143427.log`: 0 errors / 2 unchanged warnings. Runtime pending because `terminal64` was not running after compile.
- **V1 Phase 2.5 Unknown Family Mapping** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-28 03:06:59): One-file additive role-map append only in `council_v1_state_composer.mqh::CouncilV1_ApplySpecialistRoleMapForState()`. Mapped the five previously unknown V1-FSW families (`MOMENTUM_REVERSAL_ASSIST`, `TREND_PULLBACK_CONTINUATION`, `VOL_BREAKOUT`, `EXPANSION_CONTINUATION`, `MICRO_RANGE_BREAK`) into existing role CSVs without adding states/functions/structs or changing confirmed tokens. Clamp remains [0.85, 1.05]. No direct final decision/permission effect; no governor/pre-AI/risk/DQ/P4/AI/ATAS/execution/plan change. `v1_fsw_unknown_family_warning` expected to clear on fresh non-bypass COUNCIL records; runtime pending because no post-binary DECISION was emitted after compile. Compile log `compile_v1_phase25_unknown_family_mapping_20260428_030232.log`: 0 errors / 2 unchanged warnings. Backup: `D:\MT5_Project_Backups\pre_change_20260428_025805_v1_phase25_unknown_family_mapping.zip`.
- **Authority Stack Pilot** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-29 01:34:56): Added bounded live authority-stack pilot in `authority_stack_pilot.mqh`, `main_ea.mq5`, and `performance_journal.mqh`. Stack runs after routed evaluation and before branch handling, order P4 -> DQ proxy -> V1, and may convert only baseline BUY/SELL decisions to `RUNTIME_REJECT`. P4 is Rule-7 compliant and blocks only `ERA_EXRA_AGREE_DEGRADED`; old `EnableCouncilDirtyEnvironmentTightening` remains false. DQ is proxy-active only using current-tick `council_quality`, `consensus_strength`, and `zone_confidence` with threshold 0.34. V1 final authority is conservative block-only for OBSERVE_ONLY/WAIT/UNDEFINED posture or `UNDEFINED_STATE`; FULL/STAGED/REDUCED/RESTRICTED pass. DECISION journal now emits `authority_stack_*`, `authority_p4_*`, `authority_dq_*`, and `authority_v1_*` fields; authority-blocked records use `AUTHORITY_STACK_<P4|DQ|V1>` reason and `authority_stack_pilot` blocking layer. Compile log `compile_authority_stack_pilot_20260429_012844.log`: 0 errors / 2 unchanged warnings; `main_ea.ex5` timestamp 2026-04-29 01:34:56. Runtime pending because `terminal64` was not running and latest journal write predates the rebuilt binary.
- **A3-Revised DQ Proxy Quarantine** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-29 20:05:03): Supersedes old DQ threshold-recalibration direction under the No Score in Decision Layers directive. `authority_stack_pilot.mqh` keeps DQ proxy computation and existing `authority_dq_*` journal fields for compatibility, but DQ is now diagnostic-only and cannot block, allow, reject, or change live authority status. `AuthorityStack_EnableDQ` is retained as a diagnostic compatibility flag; no live `BLOCKED_DQ` branch remains. P4 and V1 remain live categorical authority layers. Compile log `compile_a3_revised_dq_proxy_quarantine_20260429_200024.log`: 0 errors / 2 unchanged warnings. Runtime pending because the journal last write predates the rebuilt binary.
- **V1 Constructive Eligibility Layer A1** (IMPLEMENTED + COMPILE_VERIFIED + RUNTIME_PENDING 2026-04-29 12:56:02): Stage A1 only. Added `EnableV1ConstructivePolicyEligibility=false` and a V1 policy eligibility override that runs after strategy detection and before aggregation. The override downgrades `CouncilStrategyReport.eligibility_state` from V1 state/posture/family role using exact CSV matching, never upgrades existing zone eligibility, and preserves strategy scores, vote weights, triggers, direction, families, and V1-FSW multipliers. Additive `v1_policy_*` DECISION fields expose active state, role map, eligibility counts, score-sovereignty evidence, and per-strategy attribution. Pre-AI score-threshold gates were not changed; Stage A2 remains required to complete score-sovereignty demotion. Compile log `compile_v1_constructive_eligibility_a1_20260429_125131.log`: 0 errors / 2 unchanged warnings. Runtime pending because MT5 was not running after compile and latest journal write predates the binary.
- Implementation baseline: `pre_change_20260421_224731_regime_contradiction_full_system.zip` (pre-Codex baseline — contains PLAN-6 Stage 3 + C3 rebind; does NOT contain Plan-RC provenance fields which will be re-applied in Stage P2.A). This is the approved surgical baseline for all Stage P2+ implementations.
- Post-Codex branch (current working tree): Evidence and reference only. Plan-RC provenance additions exist in current branch. Will be re-applied to pre-Codex baseline in Stage P2.A.
- Completed stages:
  - Stage P1 (COMPLETE 2026-04-22): Files changed: `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` (this entry + anchor update), `AGENTS.md` (Regime Authority Discipline section added), `OPERATION_GUARDRAILS.md` (5 new active risk entries). No source files changed.
  - Stage P2.A (VERIFY_PASSED_FROM_EQUIVALENCE_AUDIT 2026-04-22): No source edits performed. Equivalence audit executed against pre-Codex baseline zip (`pre_change_20260421_224731_regime_contradiction_full_system.zip`). Diff results: `performance_journal.mqh` — 7 hunks (3 provenance helper functions + 7 emission-point call sites, all P2.A-scoped); `trade_feedback.mqh` — 1 hunk (6 inline provenance fields, P2.A-scoped); `main_ea.mq5` — 8 hunks (ReplayValidationSummary 3-field struct addition, 3-field initialization, `ReplayApplyRegimeLabelProvenanceFallback()` function, 3× extraction+fallback-call blocks from latestLine/matchedDecision/latestClose, text output block, JSON output block — all P2.A-scoped). Zero non-P2.A hunks in any file. Path 1 accepted as `VERIFY_PASSED_FROM_EQUIVALENCE_AUDIT`. Fresh re-application from extracted pre-Codex source was NOT performed; equivalence to approved P2.A target state WAS verified by direct diff. Pre-stage backup: `pre_change_20260422_021550_plan_arch_dr_p2a_baseline_state.zip` (2933 files, 63,052,725 bytes). Compile: VERIFIED (0 errors, 2 pre-existing warnings — unchanged). Runtime: OBSERVATION_CONFIRMED (2026-04-22 Mission-6 audit): DECISION records confirmed — last 5 DECISION records (ts range 11:31–12:16 UTC+3, post-compile) all carry regime_label_source="REGIME_CLASSIFICATION_V1_DECISION_TIME", regime_label_semantics="REGIME_CLASSIFICATION_LABEL", regime_label_time_basis="DECISION_TIME_M1_M5_SNAPSHOT". TRADE records confirmed — last 5 TRADE (close) records all carry regime_label_source="REGIME_CLASSIFICATION_V1_CLOSE_TIME", regime_summary_source="MARKET_REGIME_SNAPSHOT_CLOSE_TIME" with correct semantics/time_basis variants. Replay fallback: correct (ReplayApplyRegimeLabelProvenanceFallback() returns early when regime_label="", producing empty provenance fields in replay_validation_summary — expected by design). P2.A BEHAVIOR_BOUNDED_NOT_CONTRACT_CLOSED (precision correction 2026-04-22 Mission 9): behavioral confirmation stands (no execution logic changed, zero non-P2.A drift, causality=C market conditions); NOT contract-closed because TRADE records in ai_performance_journal.jsonl contain malformed JSON — double commas before provenance block (e.g., field value followed by ",,") — causing strict json.loads() parse failures with JSONDecodeError; substring/regex workarounds confirm field presence but JSON contract integrity is broken; replay blank provenance for empty regime_label bars is correct-by-design but constitutes an observability gap when regime_label was empty at close time.
  - Stage P2.A JSON contract-closure fix (FULLY_CLOSED 2026-04-22 — RUNTIME_CONFIRMED): Three provenance helper functions in `performance_journal.mqh` (lines 160–185) corrected — leading comma removed from first field of each helper, trailing comma added to last field of each helper. Affected helpers: `PJ_RegimeLabelProvenanceDecisionJsonFields`, `PJ_RegimeLabelProvenanceTradeCloseJsonFields`, `PJ_RegimeSummaryProvenanceTradeCloseJsonFields`. All three active record types now assemble valid JSON: DECISION (via `PJ_BuildDecisionJsonV3`, line 986), COUNCIL_OUTCOME_ATTRIBUTION (via `PJ_BuildCouncilOutcomeAttributionJson`, line 1353), TRADE (via `PJ_BuildTradeJson`, lines 1467+1469). Active call chains confirmed from `main_ea.mq5`: `JournalAppendDecisionV3` (6 call sites), `JournalAppendCouncilOutcomeAttribution` (line 12606), `JournalAppendTrade` (line 13185). Legacy builders (`PJ_BuildDecisionJson`, `PJ_BuildDecisionJsonV2`, `PJ_BuildCouncilAttributionJson`) also corrected as side effect — not called from `main_ea.mq5`. Synthetic parse verification: PASSED for all 3 record types. Compile: 0 errors, 2 pre-existing warnings (int→string at `main_ea.mq5` lines 13705/14197 — unchanged). `main_ea.ex5` updated Apr 22 19:55. Runtime verification CONFIRMED (2026-04-22): 8 post-fix DECISION records (ts range 20:28–21:26, all json.loads() PASS, all 3 provenance fields intact, no double-comma, clean SNAPSHOT→direction transition); 1 post-fix TRADE record (ts 20:53:15, json.loads() PASS, all 6 provenance fields intact — regime_label=COMPRESSION + regime_summary=RANGE|NORMAL_VOL|TIGHT_SPREAD|CLEAN); COUNCIL_OUTCOME_ATTRIBUTION — 0 post-fix records observed (does not block closure per mission rule; remains unconfirmed but non-blocking). Backup: `pre_change_20260422_194514_p2a_contract_fix.zip` (4,447 files, 26,264,670 bytes — full system, compliant). Wrapper map comment at performance_journal.mqh line 33 confirmed OUTDATED (says `PJ_BuildDecisionJson` is active; actual active path is `PJ_BuildDecisionJsonV3`) — comment not corrected (out of scope for minimum-change rule; note logged here). P3.3 (dead fallback cleanup in council_strategies.mqh:737–739) is now the next independent ready stage.
  - Stage P3.3 (IMPLEMENTED + COMPILE_VERIFIED 2026-04-22): Dead string-search fallback clauses removed from `CouncilIsCompressionContext()` and `CouncilIsExpansionContext()` in `council_strategies.mqh`. Both functions simplified to single active zone_type enum condition. Confirmed dead from source: MarketRegimeSnapshot token vocabulary exhaustively verified — no "COMPRESSION" or "EXPANSION" token emitted in any path; zone_name="UNDEFINED" for COMPRESSION (CouncilZoneTypeToText gap). Compile: 0 errors, 2 pre-existing warnings (unchanged). main_ea.ex5 Apr 22 21:57. Behavioral impact: NONE. Backup: `pre_change_20260422_215019_p3_3_dead_fallback_cleanup.zip`.
  - Stage doctrine correction (COMPLETE 2026-04-22, Mission 9): Three-primary-chain doctrine declared: (1) MarketRegimeSnapshot (market_regime.mqh) — 4-axis intermediate, upstream input to ClassifyCouncilZone, never emits "COMPRESSION" in summary string; (2) gRegime/RegimeClassificationV1 (regime_classification_layer_v1.mqh) — 8-label ATR-ratio-based, Admission Authority; (3) council zone (council_environment.mqh ClassifyCouncilZone) — 7-label routing authority. Adopted doctrine: stronger separation not full severance; shared indicator foundations are deliberate design; bridge is measurement-only (P2.B + P3.1B); never bridge for governance/control/veto. P2.A reclassified from "CLOSED" to "BEHAVIOR_BOUNDED_NOT_CONTRACT_CLOSED." Sixth violation registered: LEARNING_CONTAMINATION (institutional_learning_layer_v1.mqh:338). P3.1 restructured as P3.1A+P3.1B AI deconfliction bundle. Files updated: PROJECT_INTELLIGENCE_MEMORY_LAYER.md (this entry), AGENTS.md, OPERATION_GUARDRAILS.md.
- Next stage: Reload/start EA and capture a fresh post-21:34:20 DECISION record with `v1_shadow_policy_specialist_version="V1_POLICY_SPECIALIST_MAP_V1"`, role-map fields, live-family alignment, counterfactual fields, `v1_shadow_scoring_quarantine_version="V1_SCORING_QUARANTINE_V1"`, and `v1_shadow_score_authority_warning` to runtime-confirm V1-C/D/E/F wiring. Version 1 remains shadow/observability-only; policy matrix authority and specialist suppression remain not live.
- Main blockers: V1 complete shadow observability runtime field observation pending because `terminal64` is not running and runtime artifacts predate the rebuilt binary. V1-B0 divergence-specific runtime signal remains pending. P4 remains data-collection only; Options 2/3/4 remain paused pending evidence and user approval. Remaining PLAN-4/PLAN-5 C1/C2/C3 observation events remain market-dependent and separate from V1.
- Main risks:
  - Stage P4 Option 1 (observability annotation): runtime field observation is pending because `terminal64` was not running after compile; behavioral P4 blocking remains unauthorized until evidence samples exist and the user explicitly approves a later option.
  - V1 complete shadow observability package: runtime field observation is pending. Risk is limited to DECISION JSON annotation, live-family classification, counterfactual labels, and scoring-quarantine diagnostics because no V1 field is consumed by execution/risk/governor/routing/pre-AI and no policy authority was activated.
  - Stage P3.1A+P3.1B (AI deconfliction bundle): Rebinding scope key shifts AI memory lookup patterns; behavioral effect is low but must be verified against advisory coherence surfaces. P3.1B motif-key extension changes the motif namespace — existing motif history is keyed by gRegime only; post-P3.1B new entries will include zone component; hybrid observation period required.
  - Stage P3.2 (strategy intelligence): Rebinding to council zone changes trendish/rangish classification for COMPRESSION bars from gRegime to ExRA source — must verify council zone COMPRESSION fires with sufficient frequency before rebind is meaningful.
- Files affected in Stage P1: `PROJECT_INTELLIGENCE_MEMORY_LAYER.md`, `AGENTS.md`, `OPERATION_GUARDRAILS.md` only. No source files changed.
- Related plans: PLAN-RC (provenance repair — residual dual-regime gap acknowledged in PLAN-RC PIML entry; this program is the formal entry for that deferred gap) | PLAN-6 Stage 3 (COMPRESSION zone detection makes ExRA now capable of producing `COUNCIL_ZONE_COMPRESSION` — this program governs how that interacts with ERA for all six violation surfaces)
- Notes: The governing principle for all stages: ERA and ExRA are not in conflict — they operate at different decision layers and both are architecturally correct. The violations are not architecture errors; they are drift points where code written before the ERA/ExRA declaration was formalized accidentally cross-read the wrong authority. Staged repair corrects each drift point without consolidating the two systems (which remain architecturally valid as separate layers).

---

- 2026-04-23 blocker-doctrine implementation update: The old gate `PLAN-2 + PLAN-6 Stage 3 + C1/C2/C3 observation stable` is now partially repaired at the implementation-surface layer. C1 shadowed-candidate, C2 overextension-tightening, and C3 low-structure-TC evidence are wired into `council_feedback.json`, `diagnostic_runtime_summary.json`, and DECISION journal records. Final blocker-doctrine restatement remains pending the first post-compile runtime emission that proves these fields are live and parse-safe in durable artifacts.
- 2026-04-23 next-stage clarification: Stage P2.B remains not yet open. The remaining blocker is no longer a documentation-only rewrite; it is live post-compile confirmation of the repaired C1/C2/C3 evidence contract. All gated stages (P3.1A, P3.1B, P3.2, P4) remain paused on P2.B until that observation gate closes.
- 2026-04-23 C1/C2/C3 EVIDENCE CONTRACT RUNTIME_CONFIRMED: Post-compile runtime verification complete. All three artifact surfaces confirmed with new fields. (1) `diagnostic_runtime_summary.json` (evaluated_at=07:01:54): all 18 C1/C2/C3 fields present, semantics_version="C123_OBSERVABILITY_V1", parse clean, values internally coherent (c1_tc_active=true/zone=TC, c1_high_conviction_active=false/NARROW consensus, c3_structure_score=1.00/CLEAN — all consistent). (2) `ai_performance_journal.jsonl` DECISION (ts=07:03:01, decision_id XAUUSD-1776927781-100128-3): all 18 fields present, semantics_version confirmed, parse clean, same coherent values. (3) `council_feedback.json` (line 776, close_time=1776927530, session ~07:05): record_semantics_version="S4_FEEDBACK_V2" — hard schema-version marker (prior 5 records all "S4_FEEDBACK_V1" with no C1/C2/C3 fields); all 18 fields present, parse clean, coherent. The S4_FEEDBACK_V1→V2 boundary is the cleanest pre/post-compile delimiter observed. P2.B gate OPENS — the evidence contract blocker (lines 2089-2090) is now resolved. Note: actual C1/C2/C3 trigger events (c1_pre_governor_candidate=true, c2_consensus_tightening_applied=true, c3_low_structure_tc_active=true) are still market-dependent and required for PLAN-4/PLAN-5 observation window closure — these are SEPARATE from the P2.B contract gate.

---

**PLAN-3 Deferred Branch Registry**

- Program ID: PLAN-3
- Name: Deferred Branch Registry
- State: DEFERRED
- Deferred reason: Formally identified dormant branches that require explicit governed plan entry before any activation. Not defects — deliberate architecture decisions frozen pending correct activation conditions.
- Re-entry rule: Activation of any dormant branch requires its own governed plan entry (minimum: scope, observation gate, authority boundary confirmation). No flag flip without plan.
- Dormant branches registered:
  - **TREND_CONTINUATION_REINFORCEMENT** — `EnableCouncilTrendContinuationConfirmationReinforcement = false`. Entire evaluator returns false unconditionally. Pipeline step 6 produces nothing. Status: DORMANT_GOVERNED. Re-entry condition: explicit PLAN entry with behavioral scope and observation gate.
  - **Council Adaptive Weights** — `gCouncilAW.enabled = false` (initialized in `council_adaptive_weights.mqh`). All 17 strategy vote weights are static (awMul = 1.0 always). Attribution hints accumulate in `gCawHints[]` but no learning feedback path active. Status: DORMANT_GOVERNED. Re-entry condition: PLAN-4 Stage 3 (shadow activation first, live activation only after multi-cycle observation). Requires separate governance decision.

---

### 7.3 Archived Programs

> Plans listed here are CLOSED or ARCHIVED. Only concise archival summaries are stored here.
> Full execution history is in the linked archive file referenced in each entry.

*(No archived programs yet.)*

---

## 8. RISK REGISTRY

### 8.1 Risk Template

- Risk ID:
- Name:
- Layer / node:
- Trigger:
- Impact:
- Detection path:
- Mitigation:
- Current status:

### 8.2 Risk Records

- RISK-1 Semantic Drift Risk
- RISK-2 Hidden Authority Shift Risk
- RISK-3 Structural Blindness Risk
- RISK-4 Exhaustion False-Silence Risk
- RISK-5 Diagnostics Misinterpretation Risk

---

## 9. FILE / FUNCTION INDEX

> This section links architecture + function + files.

### 9.1 File Record Template

- File:
- Main role:
- Architecture node references:
- Functional references:
- Main functions:
- Notes:

### 9.2 File Index

**FILE-1 structural_sr_engine.mqh**

- Main role:
- Architecture refs:
- Functional refs:
- Main functions:

**FILE-2 level_awareness_brake.mqh**

- Main role:
- Architecture refs:
- Functional refs:
- Main functions:

**FILE-3 council_environment.mqh**

- Main role:
- Architecture refs:
- Functional refs:
- Main functions:

**FILE-4 council_aggregator.mqh**

- Main role:
- Architecture refs:
- Functional refs:
- Main functions:

**FILE-5 council_pre_ai_filter.mqh**

- Main role:
- Architecture refs:
- Functional refs:
- Main functions:

**FILE-6 council_v1_state_composer.mqh**

- Main role: Pure COUNCIL-only Version 1 shadow state, specialist-role, counterfactual, promotion-readiness, and scoring-quarantine annotation composer.
- Architecture refs: V1-B shadow observability; PLAN-ARCH-DR ERA/ExRA measurement-only bridge doctrine.
- Functional refs: DECISION journal V1 shadow fields; no execution/risk/governor/pre-AI authority.
- Main functions: `CouncilV1_BuildShadowStatePolicyAnnotation()`, `CouncilV1_EnrichShadowStatePolicyAnnotation()`, `CouncilV1_ApplySpecialistRoleMapForState()`, `CouncilV1_ApplyScoringQuarantine()`.

---

## 10. DECISION LOG

### 10.1 Decision Template

- Decision ID:
- Decision:
- Date / phase:
- Why taken:
- Alternatives rejected:
- Affected nodes:
- Expected impact:
- Reversal condition:

### 10.2 Decision Records

**DEC-1**

- Decision:

**DEC-2**

- Decision:

---

## 11. OPEN QUESTIONS / UNRESOLVED AREAS

### 11.1 Open Question Template

- Question ID:
- Question:
- Why unresolved:
- What would resolve it:
- Owner:
- Related nodes:

### 11.2 Open Questions

**OQ-1**

- Question:

**OQ-2**

- Question:

---

## 12. HISTORICAL / REJECTED / DEFERRED PATHS

> This section records architectural **design paths** — approaches, ideas, and alternative implementations that were considered at design time and rejected, deferred indefinitely, or historically superseded at the architectural level.

> **Boundary with Section 7**: Section 12 stores design-path decisions (e.g. "approach X was considered for CEIS but rejected in favour of approach Y"). Closed *execution plans* that were actually executed and completed are archived in **Section 7.3**, not here.

### 12.1 Rejected Path Template

- Path ID:
- Name:
- Why considered:
- Why rejected:
- Can it return later:
- Related systems:

### 12.2 Historical Paths

**HIST-1**

- Name:

**REJ-1**

- Name:

**DEF-1**

- Name:

---

## 13. SECTION FILL STATUS

> This section tracks what has been populated and what is still empty.

Fill status codes: `NOT_FILLED` = empty skeleton only · `STRUCTURE_REFINED` = storage model defined, no real data entries yet · `PARTIAL` = some real data entries present · `FILLED` = substantially complete

### 13.1 Fill Status Table

| Section | Status |
|---------|--------|
| Section 1 Master Project Identity | NOT_FILLED |
| Section 2 Master Architecture Tree | PARTIAL |
| Section 3 Functional Tree | NOT_FILLED |
| Section 4 Dependency Map | NOT_FILLED |
| Section 5 Edge Registry | NOT_FILLED |
| Section 6 I/O Consumer Matrix | NOT_FILLED |
| Section 7 Execution Program Registry | PARTIAL |
| Section 8 Risk Registry | NOT_FILLED |
| Section 9 File / Function Index | PARTIAL |
| Section 10 Decision Log | NOT_FILLED |
| Section 11 Open Questions | NOT_FILLED |
| Section 12 Historical / Rejected / Deferred Paths | NOT_FILLED |

---

## 14. POPULATION PROTOCOL

> This file is meant to be populated by targeted execution missions.

Examples:

- fill the full architecture tree only
- fill CEIS functional tree only
- fill SVS dependency map only
- fill active program registry only
- fill edge definitions for one stack only

### 14.1 Phase Structure

- Phase 1: build the storage architecture of the file itself
- Phase 2: populate sections through focused missions

### 14.2 Population Rule

Never try to fill the whole file at once. Each mission should target one bounded section or one bounded subtree.

### 14.3 Consumer Rule

This file is primarily for:

- Claude
- Codex as execution-memory and project-understanding infrastructure.

### 14.4 Execution-Plan Population Rule

When inserting a real execution plan entry (e.g. CEIS, SVS, or any future subsystem plan):

- If the plan is **open / active**: use the Working-State Template (7.1.1) and place the entry under **Section 7.2**
- If the plan is **newly closed**: convert its 7.2 entry to the Archival Summary Template (7.1.2), create the linked `.txt` archive file at `plans/archive/<ID>_<short-name>.txt`, and move the summary to **Section 7.3**
- Do not insert plans directly into Section 7.3 unless they arrive already closed
- Each plan population mission should target one plan's real entry — do not populate multiple plans in one mission unless they are jointly closing

---

## 15. IMMEDIATE NEXT POPULATION CANDIDATES

1. Full detailed master architecture tree
2. Full CEIS architecture + functional subtree
3. Full SVS architecture + functional subtree
4. Active execution program registry
5. File/function cross-index
6. Edge registry for CEIS and SVS

---

## 16. IRREW_IMPLEMENTATION_BASELINE_V1 — Approved Strategy Architecture Direction

> **Authority:** This section is CONFIRMED_ARCHITECTURAL_DECISION. It records the formal operator approval of IRREW as the target implementation architecture for the MT5 council strategy layer. It does not authorize any specific source change. All changes to .mq5/.mqh files must be routed as bounded, operator-authorized Codex tasks that align with this baseline.

**Date adopted:** 2026-05-06
**Adopted from:** STRATEGY_ARCHITECTURE_AND_EDGE_CERTIFICATION_AUDIT — XAUUSD MT5 Council System DESIGN_V1 + AMENDMENTS_V1 Final Report (2026-05-06)
**Truth marker:** CONFIRMED_ARCHITECTURAL_DECISION

---

### 16.1 Adoption Status

IRREW — INSTITUTIONAL_ROLE_RIGHTS_WITH_EDGE_CALIBRATED_WEIGHTING — is formally approved as the target implementation architecture for the MT5 council strategy layer.

- **IRREW supersedes** simple static voting as the target coordination model for the strategy/council layer.
- **MT5 runtime authority is fully preserved.** MT5 remains the sole execution authority. No approval in this section transfers authority away from MT5 or toward any external system.
- **NautilusTrader is evidence lab only.** Nautilus is the research, replay, and edge-certification lab. Nautilus must not send orders, modify MT5, or become execution authority. Nautilus findings are evidence — not commands, not approvals.
- **Future council/strategy patches must align with IRREW.** No council or strategy source change should be routed as a bounded task unless it is directionally consistent with the IRREW model documented here.
- **IRREW approval does not authorize broad rewrite.** Implementation must proceed phase by phase, one bounded task at a time, with compile verification and runtime validation between tasks.
- **IRREW approval does not constitute production readiness.** System status remains DEVELOPING.

---

### 16.2 Strategic Reason for IRREW

The MT5 council system is architecturally sound but operationally weak. The following deficiencies were verified from source and runtime before IRREW was adopted:

| Weakness | Source Verification | Impact |
|---|---|---|
| Score gates are dormant | `council_pre_ai_filter.mqh` L125–163: council_quality/consensus/conflict captured as diagnostics only — no gate rejection produced | Low-quality NARROW-consensus trades execute without resistance |
| CRR allows same-family pseudo-confirmation | `council_pre_ai_filter.mqh` L230–253: only checks CONFIRM role votes dominant side; does not check whether confirm family differs from executor family | 5 of 6 TC CONFIRM strategies are TREND_CONTINUATION family (same as TREND_JUDGE); CRR gate satisfied by same-family "confirmation" |
| Static weights do not reflect evidence | Hard-coded in `council_strategies.mqh`; no update mechanism | bollinger_reclaim holds weight=1.00 despite being the weakest confirmed strategy by live WR |
| No veto mechanism | `council_mode_types.mqh`: no VETO role; EXHAUSTION_JUDGE reduces council_quality only via exhaustion_warning penalty | EXHAUSTION_JUDGE cannot block a TC/BREAKOUT trade even when CEIS exhaustion score is extreme |
| No opportunity tracking | No opportunity ledger file exists | System cannot distinguish between "no trigger" and "trigger suppressed correctly" — suppression quality is unauditable |
| Regime eligibility is zone-type only | Zone-type routing only; no regime_label×strategy matrix | bollinger_reclaim fires in RANGE_MEAN_RECLAIM zone despite Nautilus showing RANGE WR=12.5% (vs EXPANSION WR=50%) |
| Strategy edge is uneven and mostly unconfirmed | 10 of 17 strategies have 0 closed live outcomes; 2 of 3 strategies with >15 outcomes are NOT_CONFIRMED or below EDGE_SUPPORTED | Strategies with no proven edge hold full vote weight and can lead decisions |

These weaknesses are not caused by bad strategy concepts — they are structural deficiencies in how the decision layer consumes strategy outputs.

---

### 16.3 Approved IRREW Target Model

IRREW = INSTITUTIONAL_ROLE_RIGHTS_WITH_EDGE_CALIBRATED_WEIGHTING

The model combines seven mechanisms into a unified coordination framework:

**1. Role Rights** — Each strategy role has explicitly defined capabilities in the pipeline (lead / confirm / veto / observe). A role is not just a weight multiplier; it is an authority contract.

**2. Primary Executor Designation** — Before aggregation, the decision layer identifies which strategy holds lead authority for the current bar (DesignatePrimaryExecutor stage). This allows cross-family confirmation enforcement.

**3. Cross-Family Confirmation (Upgraded CRR)** — True CRR satisfaction requires the CONFIRM strategy to come from a different family than the primary executor. Same-family confirm contributes to council_quality but does NOT satisfy the CRR gate. This closes the TC pseudo-confirmation gap.

**4. Veto Authority** — EXHAUSTION_JUDGE strategies can veto TC/BREAKOUT decisions when exhaustion evidence is calibrated from real entries. GUARD strategies can veto NO_TRADE conditions. Veto is a hard block, not a quality reduction.

**5. Regime-Conditioned Eligibility Matrix (RCEM)** — Each strategy has a certified eligibility per regime_label (ACTIVE / REDUCED / OBSERVE_ONLY / BLOCKED), superseding zone-type-only routing. RCEM is built from live evidence and Nautilus certification — not from design intuition.

**6. Nautilus Certification Workflow** — NautilusTrader runs 5-variant replay certification per strategy family. Certification evidence informs RCEM entries and weight progression recommendations. Nautilus provides evidence; operator authorization approves all MT5 changes.

**7. Evidence-Earned Weight Progression (EEWP)** — Weights are calibrated by evidence (Nautilus certification multiplier × live performance multiplier) and updated via operator-authorized bounded tasks. No automatic or dynamic weight changes. Weight floor: 0.40. Weight ceiling: 1.40.

**8. Opportunity Ledger** — Every bar where a strategy trigger fires writes a record to `ai_opportunity_ledger.jsonl`. Every session writes per-strategy evaluation counters to `ai_opportunity_summary.json`. This enables forward auditing of suppression quality.

**9. MT5 Runtime Validation** — Every IRREW change requires a runtime validation window (30–50 decisions) before the next change is authorized.

**10. Operator-Authorized Governance** — Weight changes, RCEM promotions, and gate activations require explicit operator sign-off. No automatic promotion, demotion, or weight adjustment is authorized.

---

### 16.4 Role-Rights Model

#### SCOUT

- Can lead decisions in REVERSAL_EXHAUSTION and RANGE_MEAN_RECLAIM zones, or when HIGH_CONVICTION consensus is present.
- Can confirm decisions from other families.
- Cannot veto.
- Vote influence: ×1.00.
- OBSERVE_ONLY reduction: ×0.15 (audit required before changing to ×0.00 — see Amendment A9).

#### CONFIRM

- Cannot lead decisions.
- Can confirm decisions. Under IRREW, true CRR confirmation requires cross-family support (confirm_family ≠ primary_executor_family). Same-family confirm contributes to council_quality only.
- Cannot veto.
- Vote influence: ×1.10.

#### TREND_JUDGE

- Can lead trend-continuation and breakout-style decisions when regime eligibility permits.
- Does not satisfy the CONFIRM role by itself. A TREND_JUDGE vote for the dominant side does not count as a CRR-satisfying confirmation.
- Cannot veto.
- Vote influence: ×1.12.

#### EXHAUSTION_JUDGE

- Cannot lead decisions.
- Can confirm reversal decisions (cross-family).
- Can veto TC/BREAKOUT decisions — but only after exhaustion thresholds are calibrated from live mfi_reversal_assist entries. **Veto is BLOCKED until mfi_reversal_assist produces ≥5 real live signal-strength readings.**
- Vote influence: ×1.05.
- Current state: 0 live entries; veto design is deferred pending calibration data.

#### GUARD

- Cannot lead decisions.
- Cannot confirm decisions.
- Can veto NO_TRADE safety conditions only.
- Vote influence: ×0.80.

#### FROZEN

- No lead, no confirm, no veto, no vote contribution.
- Vote weight: ×0.00.
- Example: momentum_breakout_cont_v1 — FROZEN by Package 1 (BOLLINGER_RECLAIM_SELL_TREND_UP_GATE is a separate restriction; FROZEN is a separate state).

---

### 16.5 Strategy Classification Baseline

This is the evidence-grounded strategy baseline at the time of IRREW adoption (2026-05-06). **All WR figures use wins/(wins+losses). Source: ai_strategy_memory.json 2026-05-06.**

#### sweep_reversal
- Edge Status: WEAK_BUT_RECOVERABLE
- Live WR: 42.9% (15W/20L = 15/35 closed outcomes)
- degradation_hint: YES
- Action: Keep active at weight=0.60. Observe 30 more closed outcomes before any change.
- Do not promote. Do not increase weight. Degradation_hint requires monitoring.
- Nautilus certification: Priority 2 (after bollinger_reclaim full replay).

#### bollinger_reclaim
- Edge Status: NOT_CONFIRMED (borderline WEAK_BUT_RECOVERABLE)
- Live WR: 38.5% (10W/16L = 10/26 closed outcomes)
- Note: WR=32.3% figure (wins/total_entries = 10/31) is RETIRED. Use wins/(wins+losses) = 38.5% as the authoritative live metric.
- RANGE regime hostile: Nautilus Variant A RANGE WR=12.5%; live evidence consistent.
- Phase 5A gate APPLIED: BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A_PATCH_APPLIED — source-applied 2026-05-06, compile-verified (0 errors/0 warnings), binary timestamp 17:11:10. Runtime validation PENDING (requires EA reload).
- Action: Monitor RANGE performance for 40+ closed outcomes. Do not designate as trusted leader. Requires continued validation.
- Nautilus certification: Priority 1 (full replay upgrade beyond GC=F proxy).

#### trend_momentum
- Edge Status: NOT_CONFIRMED
- Live WR: 30.0% (6W/14L = 6/20 closed outcomes)
- Note: Prior plan sections cited WR=42.9% for trend_momentum — this was an error (42.9% belonged to sweep_reversal). Corrected live WR is 30.0%.
- degradation_hint: YES
- Entry Timing Guard V1 live (not_late guard, EMA distance ≤ ATR×1.20).
- Action: Maintain not_late guard. Watch 30+ post-guard closed outcomes. Do NOT promote. Do NOT increase weight.
- Nautilus certification: Priority 3.

#### momentum_breakout_cont_v1
- Edge Status: REJECTED
- Live WR: 9.1% (1W/10L = 1/11 closed outcomes)
- State: FROZEN — Package 1 applied (vote_weight=0.00, decision=WAIT hard-coded).
- Action: Keep FROZEN. No redesign without a separate, dedicated plan. Do not route any future task that restores this strategy without a full standalone design.

#### mfi_reversal_assist
- Edge Status: DATA_INSUFFICIENT
- Live entries: 0 closed outcomes.
- MFI threshold widened (Package 3: <55/>45 from <45/>55).
- Veto design: BLOCKED pending real entries. Do not design or implement veto thresholds until ≥5 live signal-strength readings exist.
- Action: Monitor for first entries post-reload. No authority changes.

#### trend_pullback_cont_v1 (TPC)
- Edge Status: DATA_INSUFFICIENT
- Live entries: 0 closed outcomes.
- ATR pullback gate widened to 0.70 (Package 2 — was 0.25).
- Critically important: TPC is the ONLY cross-family CONFIRM candidate in TREND_CONTINUATION zone. All other TC CONFIRM strategies are TREND_CONTINUATION family (same as TREND_JUDGE). Cross-family CRR (Phase 4A) CANNOT be enabled until TPC demonstrates sustained trigger frequency.
- Required before Phase 4A: ≥5 distinct TPC triggers observed in live runtime + ≥20% eligible-bar fire rate in TC zone.
- Action: Monitor fire rate post-reload. No authority changes.

#### breakdown_momentum_v1
- Edge Status: NOT_CONFIRMED
- Live WR: 30.0% (3W/7L = 3/10 closed outcomes)
- Possible future restriction: regime_label=TREND_DOWN only (if Nautilus Phase 3 certification supports).
- Action: Keep active. Regime restriction requires Phase 3 Nautilus certification first — no restriction without evidence.

#### lower_high_rejection_v1
- Edge Status: DATA_INSUFFICIENT
- Live entries: 0 closed outcomes.
- Action: Keep active (SELL_ONLY in TC zone). Monitor.

#### mean_reversion_bounce
- Edge Status: DATA_INSUFFICIENT
- Live entries: 1 entry, 0 closed W/L outcomes.
- Buffer widened to 0.30 ATR (Package 3).
- Action: Keep active. Monitor.

#### range_edge_fade
- Edge Status: DATA_INSUFFICIENT (2 entries, both L — N<15 threshold)
- Action: Keep active (RMR CONFIRM). Monitor.

#### fake_break_reversal, range_compression_breakout, volatility_squeeze_release, volatility_breakout, expansion_continuation, micro_range_expansion
- Edge Status: DATA_INSUFFICIENT (0 entries each)
- Action: Keep active in designated zones. No promotion, no weight increase, no new authority of any kind until Nautilus + runtime evidence exists.
- Baseline weights in Genome Matrix are design-intent targets only — not current authorized changes.

#### sweep_detector
- Evidence status: ORPHANED_LEGACY_DATA
- ai_strategy_memory.json shows wins=26, losses=22, but total_entries=0, total_observations=0.
- These win/loss counts are legacy data from when sweep_detector was the compiled-plan main trigger (plan_v076), not a council strategy. They are NOT council evidence and must not be used for edge decisions, weight assignments, or RCEM entries.
- Action: Do not use sweep_detector legacy W/L data for any decision. Reconcile data source before any use.

**DATA_INSUFFICIENT hard rule:** No strategy in DATA_INSUFFICIENT status may be promoted, given weight increases, assigned new authority (veto/lead), or have its RCEM eligibility expanded until both Nautilus certification and live runtime evidence (minimum N=15 closed W/L outcomes) exist.

---

### 16.6 Approved Implementation Direction

IRREW implementation should progress through the following capabilities in approximate priority order. Each capability requires a bounded, operator-authorized implementation task — none are authorized by this section alone.

**Authorized to build toward:**
- Opportunity Ledger (`ai_opportunity_ledger.jsonl` records + `ai_opportunity_summary.json` counters)
- Strategy Genome Matrix (RCEM v1) in PIML (Phase 1 — documentation only)
- RCEM / Regime-Conditioned Eligibility Matrix (populated from Nautilus + live evidence)
- Role-rights enforcement (primary executor designation, cross-family CRR, veto path)
- Cross-family CRR gate upgrade (after TPC fire rate verified)
- Exhaustion veto path (after mfi_reversal_assist entries calibrate threshold)
- Council quality soft gate re-activation (after Opportunity Ledger is live with ≥200 records)
- Evidence-earned weight governance (after Phase 3 substantially complete)
- Strategy restriction patches (from Nautilus certification evidence, one gate per bounded task)

**Hard constraints that must not be violated:**
- No broad rewrite of council or strategy architecture.
- No automatic or dynamic weight changes. Every weight adjustment requires operator authorization + bounded Codex task.
- No Nautilus execution authority. Nautilus is evidence lab only.
- No production-readiness claim from this approval or any single phase completion.
- No cross-family CRR before TPC fire rate is verified.
- No exhaustion veto before MFI calibration data exists.
- No quality soft gate before Opportunity Ledger is live.
- No OBSERVE_ONLY multiplier change before Opportunity Ledger audit completes.
- No DATA_INSUFFICIENT strategy authority changes without evidence.

---

### 16.7 Practical Priority Order

The following phase sequence governs IRREW implementation. Phases are approximate — exact timing depends on evidence accumulation.

**Phase 0 — Evidence Inventory and Runtime Reload Baseline**
- EA reload → Phase 5A runtime validation begins
- TPC fire rate measurement (48h window post-reload)
- mfi_reversal_assist first entry observation (post-reload)
- bollinger_reclaim WR denominator formally reconciled: use wins/(wins+losses); 32.3% figure retired
- MAE/MFE per strategy from ai_performance_journal.jsonl
- Strategy-level regime breakdown from journal (7,403 records)
- Scope: read-only. No source changes.

**Phase 1 — Strategy Genome Matrix and RCEM v1 in PIML**
- Define authoritative RCEM for all 17 strategies from Phase 0 evidence
- Encode RCEM v1 in PIML Section 16 or a new PIML subsection
- Operator approves RCEM v1 before any Phase 2+ implementation
- Scope: PIML documentation only. No source changes.

**Phase 2 — Opportunity Ledger Design and Implementation**
- Add OpportunityRecord struct to `council_mode_types.mqh`
- Add WriteOpportunityRecord() to `council_mode_runtime.mqh` (trigger_present=true records only)
- Add per-session EvaluationCounterRecord write to `ai_opportunity_summary.json`
- Scope: `council_mode_types.mqh` + `council_mode_runtime.mqh` only. One bounded Codex task.
- Requires: design approval before Codex task opens.
- Phase 2 is prerequisite for Phase 4C (quality soft gate).

**Phase 3 — Nautilus Replay Certification (runs in parallel)**
- Certify all 17 strategies using NautilusTrader lab
- Priority: bollinger_reclaim full replay → sweep_reversal → trend_momentum → breakdown_momentum_v1 → DATA_INSUFFICIENT strategies
- Output per strategy: certification label + evidence classification + RCEM update recommendation
- Scope: nautilus_lab/ directory only. No MT5 source changes.
- Nautilus evidence is input to operator decisions — not automatic permission for changes.

**Phase 4 — Role-Rights Architecture Implementation**
- Phase 4A: Cross-family CRR upgrade — BLOCKED until TPC fire rate verified (≥5 triggers, ≥20% TC eligible-bar rate)
- Phase 4B: Exhaustion veto path — BLOCKED until mfi_reversal_assist ≥5 entries and threshold calibrated
- Phase 4C: Council quality soft gate re-activation — BLOCKED until Phase 2 Opportunity Ledger live with ≥200 records
- Each sub-task is one bounded Codex task with mandatory compile verification + 30-decision runtime window before next sub-task.
- Scope per sub-task: one file only (4A: `council_pre_ai_filter.mqh`; 4B: `council_mode_types.mqh` + `council_mode_runtime.mqh`; 4C: `council_pre_ai_filter.mqh`).

**Phase 5 — Strategy Restriction Patches from Evidence**
- Phase 5A: APPLIED — BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A_PATCH_APPLIED (2026-05-06 17:11:10, 0 errors/0 warnings). Runtime validation PENDING (requires EA reload).
- Phase 5B: breakdown_momentum_v1 → TREND_DOWN gate — requires Phase 3 Nautilus certification first.
- Phase 5C+: additional gates from Phase 3 certifications.
- One gate per bounded Codex task. One file (`council_strategies.mqh`) per task. 24h runtime validation between tasks.

**Phase 6 — Evidence-Earned Weight Progression (EEWP)**
- Design-only until Phase 2 live + Phase 3 ≥8 strategies certified + Phase 4 runtime sample ≥50 decisions.
- No implementation until all blockers cleared.
- Every weight change requires explicit operator authorization + bounded Codex task.
- One strategy weight adjustment per task.

**Phase 7 — Runtime Validation (Ongoing from Phase 4)**
- 30–50 decision validation window after every Phase 4/5/6 change.
- Compare opportunity ledger before/after each change.
- Read-only. No source changes.

**Phase 8 — Promotion/Demotion Governance**
- Promotion: Nautilus EDGE_SUPPORTED + live WR ≥43% for 50+ closed outcomes → eligible for weight increase (operator authorizes).
- Demotion: live WR < 35% for 30+ closed outcomes OR degradation_hint for 20+ consecutive → mandatory review.
- Freeze: live WR < 25% for 20+ closed outcomes → FROZEN (momentum_breakout_cont_v1 pattern).
- All governance actions require operator authorization.

---

### 16.8 Evidence Discipline

Four categories of evidence are recognized in IRREW. These categories must not be mixed or promoted between tiers without explicit justification.

**Runtime Authority Truth**
- Source: live MT5 execution, live trade outcomes, live ai_strategy_memory.json, live ai_performance_journal.jsonl, live council_report.txt, live runtime_governance_status.json
- Authority level: HIGHEST — this is the ground truth for system behavior
- Rule: MT5 runtime evidence is the authoritative record. Nautilus replay must not override or supersede MT5 runtime evidence.

**Nautilus Research Evidence**
- Source: NautilusTrader replay results (br_backtest_results.json), certification labels, variant analysis, regime breakdowns
- Authority level: RESEARCH — informs design decisions and RCEM recommendations; requires operator review before acting
- Rule: Nautilus Research Evidence must NOT be treated as Runtime Authority Truth. A strategy showing 50% WR in Nautilus does not mean it achieves 50% WR in MT5 live. Backtest/replay success must not be treated as production readiness.
- Critical: Nautilus results using GC=F proxy (PARTIAL_REPLICATION) have additional proxy distance from MT5 live behavior.

**Status Truth**
- Source: PIML (this file), MEMORY.md, Claude memory files, compile logs
- Authority level: GOVERNANCE — records decisions, approvals, and execution state
- Rule: PIML is the governed project memory. Claude memory files may not maintain independent status claims contradicting PIML.

**Evidence Truth**
- Source: Nautilus certification labels, live WR tables, RCEM entries, strategy baseline
- Authority level: DESIGN — informs architecture decisions but requires operator validation before implementation
- Rule: Evidence Truth must be dated and sourced. Evidence tables without explicit snapshot dates and denominator definitions must not be used for implementation decisions.

---

### 16.9 Production Readiness Status

**System status: DEVELOPING**

IRREW approval improves strategic direction. It does not improve production readiness by itself.

Production readiness requires all of the following — none of which are currently met:
- All 17 strategies certified under Phase 3 Nautilus (not yet started for most)
- IRREW Phase 4 live and runtime-validated (200+ decisions under IRREW architecture)
- Opportunity Ledger live and confirming suppression quality (Phase 2 not yet implemented)
- WR ≥ 42% stable for 60 consecutive days under IRREW architecture (current: 39.9% under pre-IRREW)
- Evidence-earned weights calibrated and validated (Phase 6 not yet designed)
- Promotion/Demotion governance enforced (Phase 8 not yet designed)

Do not interpret any phase completion as production readiness. Do not interpret IRREW approval as production readiness. System status will be upgraded only when all criteria above are met and operator explicitly authorizes the status change.

---

### 16.10 IRREW Adoption Record

```
ADOPTION_ID:                     IRREW_IMPLEMENTATION_BASELINE_V1
ADOPTED_DATE:                    2026-05-06
ADOPTED_FROM:                    STRATEGY_ARCHITECTURE_AND_EDGE_CERTIFICATION_AUDIT DESIGN_V1 + AMENDMENTS_V1
ARCHITECTURE_NAME:               INSTITUTIONAL_ROLE_RIGHTS_WITH_EDGE_CALIBRATED_WEIGHTING
ARCHITECTURE_ABBREV:             IRREW
ARCHITECTURE_APPROVED_BY:        Operator (2026-05-06)
SUPERSEDES:                      Static voting model as target coordination architecture
MT5_AUTHORITY:                   PRESERVED — MT5 is sole runtime authority
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY — no execution authority, no approval authority
PRODUCTION_READY_CLAIMED:        NO
SYSTEM_STATUS:                   DEVELOPING
PHASE_5A_STATUS:                 APPLIED (BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A, compile-verified, runtime pending reload)
PHASE_4A_STATUS:                 BLOCKED — TPC fire rate unverified
PHASE_4B_STATUS:                 BLOCKED — mfi_reversal_assist 0 entries
PHASE_4C_STATUS:                 BLOCKED — Opportunity Ledger not live
EEWP_STATUS:                     DESIGN_ONLY — no implementation path active
NEXT_IMMEDIATE_ACTION:           EA reload → Phase 5A runtime observation → Phase 0 evidence inventory
CODEX_AUTHORIZED_NOW:            None — this section is documentation only; future Codex tasks require per-task operator authorization
```

---

## 17. PARALLEL_ADVANCE_MODE_V1 — Operator-Approved IRREW Parallel Work Policy

> **Authority:** This section is CONFIRMED_ARCHITECTURAL_DECISION. It records the formal operator approval of PARALLEL_ADVANCE_MODE as the execution posture for IRREW work while Phase 0 runtime evidence accumulates. It does not authorize any source change, weight adjustment, gate enforcement, or execution behavior modification.

**Date adopted:** 2026-05-06
**Adopted by:** Operator (2026-05-06)
**Truth marker:** CONFIRMED_ARCHITECTURAL_DECISION

---

### 17.1 Adoption Status

PARALLEL_ADVANCE_MODE is operator-approved as the active execution posture for IRREW implementation work.

- **Phase 0 runtime evidence accumulation remains active and open.** This mode does not close Phase 0, supersede it, or reduce its evidence requirements.
- **The gate verdict WAIT_FOR_RUNTIME_EVIDENCE remains valid.** PARALLEL_ADVANCE_MODE does not contradict this verdict. It permits safe parallel work while runtime evidence accumulates — it does not convert the system from a waiting state to a proceed state.
- **Parallel work is bounded.** It is allowed only where it does not change runtime authority, execution behavior, strategy weights, gate thresholds, or live trading decisions.
- **All evidence blockers listed in Sections 16.6 and 16.7 remain in force.** Phase 4A, 4B, and 4C remain blocked. EEWP remains design-only.

---

### 17.2 Strategic Purpose

The governed system must make productive use of the time during which Phase 0 runtime evidence accumulates, without prematurely enforcing architectural changes that depend on that evidence.

- The goal is to avoid idle time while TPC fire rate, MFI first entries, and Phase 5A gate observations accumulate over hours and days of live runtime.
- The project may continue moving toward IRREW through design, documentation, measurement specification, and task preparation — none of which alter live behavior.
- Parallel work must remain bounded, reversible, and evidence-aware. If evidence arrives that changes a design assumption, parallel work products must be revisable without disruption to live operation.
- The goal under this mode is **preparation, documentation, and measurement design** — not premature gate enforcement, not weight changes, not architectural changes to the running council.
- Any deliverable produced under PARALLEL_ADVANCE_MODE is a design artifact, not an execution artifact, until a separate bounded Codex task is operator-authorized.

---

### 17.3 Allowed Parallel Work

The following categories of work are explicitly permitted under PARALLEL_ADVANCE_MODE. All are design/documentation activities that do not touch live trading logic.

| Category | Description |
|---|---|
| RCEM_V1_PROVISIONAL design | Draft the Regime-Conditioned Eligibility Matrix for all 17 strategies based on current evidence. Mark as PROVISIONAL until Phase 0 and Phase 3 evidence is complete. |
| Strategy Genome Matrix refinement | Refine the per-strategy classification table in PIML with current evidence labels, corrected WR figures, and edge status updates. |
| Opportunity Ledger design | Design the full struct definition, write conditions, record schema, and evaluation counter schema for the Opportunity Ledger. Produce a Codex task specification. Do not implement. |
| Opportunity Ledger Codex task specification | Write a bounded Codex task spec covering: struct in `council_mode_types.mqh`, write function in `council_mode_runtime.mqh`, session counter write logic. Operator must separately authorize before Codex executes. |
| Nautilus certification preparation | Prepare per-strategy certification plan: required data, trigger replication requirements, variant analysis spec, proxy documentation, cost model, regime segmentation plan. |
| Strategy-by-strategy certification plan | Document the exact Nautilus certification sequence and what evidence each strategy needs before proceeding to Phase 5 restriction or Phase 6 weight changes. |
| Evidence extraction plans | Design how MAE/MFE, regime breakdown, and per-strategy performance will be extracted from `ai_performance_journal.jsonl` for Phase 0 evidence inventory completion. |
| Bounded future Codex task drafts | Draft task specifications for future Phase 2, 5B, and 5C+ tasks. Drafts are design artifacts — not authorized for execution until operator sign-off. |
| PIML documentation updates | Add, refine, or correct sections in `PROJECT_INTELLIGENCE_MEMORY_LAYER.md`. |
| Read-only evidence analysis | Analyze existing `ai_strategy_memory.json`, `ai_performance_journal.jsonl`, `factory_operational_evidence_status.json`, `council_report.txt`, and Nautilus artifacts for patterns, gaps, and design inputs. |
| Non-runtime design artifacts | Any document, schema, plan, or specification that does not alter `.mq5`, `.mqh`, `.ex5`, `.json`, `.jsonl`, `.set`, or runtime/config files. |

---

### 17.4 Forbidden Until Evidence Blockers Clear

The following are explicitly forbidden under PARALLEL_ADVANCE_MODE and remain forbidden until the specific evidence blocker for each is cleared by Phase 0 evidence accumulation and operator sign-off.

| Forbidden Action | Blocker |
|---|---|
| Cross-family CRR enforcement (Phase 4A) | TPC fire rate unverified — minimum 5 distinct TC zone triggers required |
| Exhaustion veto implementation (Phase 4B) | mfi_reversal_assist has 0 entries — minimum 5 signal-strength readings required |
| Quality soft gate enforcement (Phase 4C) | Opportunity Ledger not live — minimum 200 records required before gate activation |
| EEWP / evidence-earned weight changes (Phase 6) | Phase 2 not live, Phase 3 incomplete, Phase 4 runtime sample absent |
| Any strategy weight changes | No weight change authorized without Phase 3 certification + Phase 6 design + operator authorization |
| Promotion or demotion decisions | No authority changes for any strategy without Nautilus + runtime evidence |
| New strategy activation | Factory admission locked; no new strategy without proven role gap |
| Broad rewrite of council or strategy layer | Not authorized under any mode |
| Source-level trading logic changes | All `.mq5` and `.mqh` files frozen for trading-logic changes until a separate bounded Codex task is authorized |
| Stop geometry changes | Requires separate multi-file design and authorization |
| Execution authority changes | MT5 authority is permanently preserved; no transfer to any other system |
| Nautilus live execution | Nautilus is evidence lab only; no orders, no MT5 control, no runtime influence |
| Any change that alters live trade permission | Live decision authority belongs to MT5 runtime only; no design artifact from this mode may alter it |

---

### 17.5 Evidence Blockers Still Active

The following evidence blockers were confirmed in the most recent gate check (2026-05-06, `WAIT_FOR_RUNTIME_EVIDENCE`) and remain active:

| Blocker | Status | Evidence |
|---|---|---|
| Phase 5A gate events | ZERO — gate loaded but no TREND_UP + bollinger_reclaim SELL context observed post-launch | `council_report.txt` zone=RANGE_MEAN_RECLAIM; no post-launch council report yet |
| TPC fire rate | UNVERIFIED — 0 TC zone triggers observed; monitoring window open | `ai_strategy_memory.json`: trend_pullback_cont_v1 entries=0 |
| MFI first entry | UNAVAILABLE — mfi_reversal_assist has 0 closed entries; P3 threshold widening applied but not yet tested | `ai_strategy_memory.json`: mfi_reversal_assist entries=0 |
| council_report.txt freshness | STALE — last report timestamp was `2026.05.06 16:36:13`, pre-launch | No post-launch council report written to disk at time of gate check |
| Phase 0 monitoring window | OPEN — 48h minimum window for TPC/MFI observation running from 2026-05-06 ~18:45 launch | EA confirmed running at `evaluated_at: 2026.05.06 19:04:14` |
| RCEM hard implementation | NOT AUTHORIZED — RCEM_V1_PROVISIONAL is a documentation artifact only; enforcement requires Phase 1 operator approval + Phase 3 certification | By design |
| Phase 4A (cross-family CRR) | BLOCKED | TPC fire rate blocker |
| Phase 4B (exhaustion veto) | BLOCKED | MFI entries blocker |
| Phase 4C (quality soft gate) | BLOCKED | Opportunity Ledger not live |

---

### 17.6 Practical Priority Under Parallel Advance Mode

Work items are sequenced by safety and dependency. All items in this priority list are design/documentation activities only.

**First priority — Immediate safe work:**
1. RCEM_V1_PROVISIONAL documentation — draft Regime-Conditioned Eligibility Matrix for all 17 strategies in PIML, clearly marked PROVISIONAL pending Phase 0 and Phase 3 evidence. No source changes.
2. Opportunity Ledger design — complete struct definition, write conditions, evaluation counter schema, and per-session summary schema. Produce a self-contained Codex task specification.

**Second priority — Parallel preparation:**
3. Nautilus certification preparation — strategy-by-strategy certification plan: data requirements, trigger replication spec, variant analysis design, proxy gap documentation, cost model.
4. Strategy Genome Matrix refinement — update PIML with corrected WR figures, current edge status labels, and RCEM provisional entries.

**Third priority — Task specification drafting:**
5. Prepare bounded Codex task specification for Opportunity Ledger implementation only (Phase 2). Do not execute. Operator must separately authorize before Codex runs this task.
6. Draft Phase 5B and 5C+ task specifications for breakdown_momentum_v1 regime restriction and any additional gates identified in Phase 3 certification.

**Fourth priority — Continuous background monitoring:**
7. Continue Phase 0 runtime evidence monitoring — read-only checks of `runtime_governance_status.json`, `council_report.txt`, `ai_strategy_memory.json`, `factory_operational_evidence_status.json` to detect: first TPC trigger, first MFI entry, first Phase 5A gate event.

---

### 17.7 Authority Rules

These rules govern all actors operating under PARALLEL_ADVANCE_MODE.

**MT5:** Sole runtime execution authority. All trading decisions, position management, stop/target geometry, and entry/exit behavior are MT5's exclusive domain. No design artifact, PIML entry, Nautilus result, or Claude recommendation may alter MT5 runtime behavior without a separate operator-authorized bounded Codex task.

**NautilusTrader:** Evidence lab only. Provides replay evidence, certification labels, regime analysis, and variant comparisons. Does not send orders. Does not modify MT5. Does not become runtime authority. Nautilus findings require operator review before they produce any MT5 source change.

**PIML (this file):** Memory and governance documentation layer. Records decisions, approvals, design artifacts, and project state. PIML is not runtime authority. Writing to PIML does not authorize any source change. PIML changes require only operator approval; source changes require separate bounded Codex tasks with compile verification and runtime validation.

**Claude:** May design, review, analyze, document, and produce design artifacts. May read all evidence surfaces. May produce Codex task specifications. May not execute Codex tasks. May not alter `.mq5`, `.mqh`, or live configuration files. May not infer permission to alter runtime behavior from PARALLEL_ADVANCE_MODE alone.

**Codex:** May implement only bounded, operator-authorized tasks. Codex operates on task specifications approved in advance. PARALLEL_ADVANCE_MODE does not authorize any Codex task — each task requires separate per-task operator sign-off.

**No AI layer may infer permission to alter runtime behavior from PARALLEL_ADVANCE_MODE alone.** This mode is explicitly a design/documentation posture. It creates no execution authority.

---

### 17.8 Production Readiness Status

**System status: DEVELOPING** (unchanged).

PARALLEL_ADVANCE_MODE improves project throughput — not production readiness. It allows productive preparation work while evidence accumulates, but it does not:
- Reduce the evidence requirements for Phase 4 or Phase 6
- Convert Nautilus replay results into MT5 runtime truth
- Authorize weight changes or gate enforcement
- Shorten the Phase 0 monitoring window
- Change the system status from DEVELOPING to any higher state

Production readiness criteria are unchanged from Section 16.9. This mode produces no progress toward those criteria by itself — only live runtime evidence accumulation, Nautilus certification completion, and IRREW phase implementation do.

---

### 17.9 Parallel Advance Mode Adoption Record

```
ADOPTION_ID:                     PARALLEL_ADVANCE_MODE_V1
ADOPTED_DATE:                    2026-05-06
APPROVED_BY:                     Operator (2026-05-06)
GATE_VERDICT_AT_ADOPTION:        WAIT_FOR_RUNTIME_EVIDENCE (unchanged — not superseded)
PHASE_0_STATUS:                  OPEN — monitoring window running from ~2026-05-06 18:45 launch
PHASE_5A_GATE_EVENTS:            ZERO — TREND_UP context not yet observed post-launch
TPC_FIRE_RATE:                   UNVERIFIED
MFI_ENTRIES:                     ZERO
PHASE_4A_STATUS:                 BLOCKED
PHASE_4B_STATUS:                 BLOCKED
PHASE_4C_STATUS:                 BLOCKED
EEWP_STATUS:                     DESIGN_ONLY
SYSTEM_STATUS:                   DEVELOPING
PRODUCTION_READY_CLAIMED:        NO
CODEX_AUTHORIZED_NOW:            None — all Codex tasks require separate per-task operator authorization
FIRST_SAFE_WORK:                 Opportunity Ledger design + RCEM_V1_PROVISIONAL documentation
MT5_AUTHORITY:                   PRESERVED
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY
```

---

## 18. RCEM_V1_PROVISIONAL — Regime-Conditioned Eligibility Matrix and Strategy Genome Baseline

**Section ID:** RCEM_V1_PROVISIONAL
**Date:** 2026-05-07
**Authority:** DOCUMENTATION_ONLY — not runtime-enforced; MT5 runtime eligibility remains governed by current source
**Source:** STRATEGY_ARCHITECTURE_AND_EDGE_CERTIFICATION_DESIGN_V1 + DESIGN_V1_REVIEW_AMENDMENTS_V1 + Phase 2 Opportunity Ledger first observations
**Operator authorization:** This section documents intended target state and evidence baseline. No source changes are authorized by this section.

---

### 18.1 Adoption Status

**Status:** DOCUMENTATION_ONLY — provisional design intent; no runtime enforcement

The RCEM is the target regime-conditioned routing matrix defined in IRREW Phase 1. It specifies, per strategy and per regime/zone combination, whether a strategy should be ACTIVE, REDUCED, OBSERVE_ONLY, BLOCKED, or FROZEN.

**Current runtime state:** Zone eligibility is determined by `zone_type` in `council_strategies.mqh` using per-strategy `allowed_zones` arrays. Regime-conditional routing (e.g., blocking a SELL-only strategy in TREND_UP) is implemented only where source patches have been applied (bollinger_reclaim SELL-in-TREND_UP gate, Phase 5A). All other regime conditioning is documentation-intent only until Phase 4/5 source patches are authorized.

**What this section is:**
- A baseline record of intended eligibility per strategy × regime/zone
- An evidence summary for each strategy (live WR, Nautilus status, edge classification)
- A foundation for Phase 1 RCEM v1 encoding in PIML and for Phase 3 Nautilus certification

**What this section is not:**
- A runtime configuration
- An authorization to implement regime routing in source
- An authorization to change weights, roles, or eligibility states
- Evidence that IRREW is active — it is not

---

### 18.2 Evidence Inputs and Truth Classifications

| Evidence Claim | Source | Classification |
|---|---|---|
| 17 active strategies in council | council_strategies.mqh (source-verified) | VERIFIED |
| Strategy families, roles, weights | council_strategies.mqh (source-verified) | VERIFIED |
| momentum_breakout_cont_v1 FROZEN (weight=0.00) | council_strategies.mqh (source-verified) | VERIFIED |
| sweep_reversal live WR=42.9% (N=35) | ai_strategy_memory.json | RUNTIME_OBSERVED |
| bollinger_reclaim live WR denominator unresolved | ai_strategy_memory.json (W=10, L=16, total_entries=31) | DENOMINATOR_UNRESOLVED |
| trend_momentum live WR=42.9% (N=28) | ai_strategy_memory.json | RUNTIME_OBSERVED |
| breakdown_momentum_v1 live WR=30.0% (N=10) | ai_strategy_memory.json | RUNTIME_OBSERVED |
| momentum_breakout_cont_v1 live WR=9.1% (N=11) | ai_strategy_memory.json | RUNTIME_OBSERVED |
| All other strategies: DATA_INSUFFICIENT (N<15 or N=0) | ai_strategy_memory.json | RUNTIME_OBSERVED |
| bollinger_reclaim Nautilus: PARTIAL_REPLICATION, GC=F proxy, 28,677 bars, Variant A WR=42.9% | Nautilus lab | EVIDENCE_LAB_ONLY |
| All other strategies: not Nautilus-certified | Nautilus lab (not run) | DATA_INSUFFICIENT |
| trend_momentum: sole trigger in TC/TREND_UP (2 ledger records) | ai_opportunity_ledger.jsonl | RUNTIME_OBSERVED |
| trend_momentum triggers blocked 100% by CRR (confirm_role_absent) | ai_opportunity_ledger.jsonl + ai_opportunity_summary.json | RUNTIME_OBSERVED |
| trend_pullback_cont_v1: 0 triggers (both sessions) | ai_opportunity_summary.json | RUNTIME_OBSERVED |
| mfi_reversal_assist: 0 triggers (both sessions) | ai_opportunity_summary.json | RUNTIME_OBSERVED |
| bollinger_reclaim SELL-in-TREND_UP gate (Phase 5A): source applied, runtime validation pending | council_strategies.mqh | SOURCE_APPLIED_PENDING_RUNTIME_VALIDATION |
| Cross-family CRR upgrade (Phase 4A): design-intent only | STRATEGY_ARCHITECTURE_AND_EDGE_CERTIFICATION_DESIGN_V1 | DESIGN_INTENT_UNIMPLEMENTED |
| Exhaustion veto (Phase 4B): design-intent only | STRATEGY_ARCHITECTURE_AND_EDGE_CERTIFICATION_DESIGN_V1 | DESIGN_INTENT_UNIMPLEMENTED |
| Quality soft gate reactivation (Phase 4C): design-intent only | STRATEGY_ARCHITECTURE_AND_EDGE_CERTIFICATION_DESIGN_V1 | DESIGN_INTENT_UNIMPLEMENTED |

**bollinger_reclaim WR denominator note (from DESIGN_V1_REVIEW_AMENDMENTS_V1, Amendment A4):**
Three figures have been cited: 32.3% (wins/total_entries = 10/31), 38.5% (wins/(W+L) = 10/26), 36.0% (9/25 prior snapshot), 37.5% (9/24 prior snapshot). Primary WR metric going forward: wins/(wins+losses). Current snapshot: W=10, L=16, WR=38.5%. Classification: EDGE_NOT_CONFIRMED (35–38% range using wins/(W+L)). Do not use 32.3% for edge decisions.

---

### 18.3 RCEM State Definitions

| State | Runtime Behavior | Weight Applied | Can Lead? | Satisfies CRR? | Authority |
|---|---|---|---|---|---|
| ACTIVE | Fully eligible; evaluates and votes | Full (role multiplier applies) | YES (if TREND_JUDGE/SCOUT) | YES (if CONFIRM, cross-family pending Phase 4A) | Full |
| REDUCED | Fires with reduced influence | ×0.75 of base | NO | NO | Diminished |
| OBSERVE_ONLY | Fires but minimal influence | ×0.15 of base | NO | NO | Minimal |
| BLOCKED | Does not evaluate in this zone/regime | 0 | NO | NO | None |
| FROZEN | Permanently excluded pending redesign | 0.00 (hardcoded) | NO | NO | None |
| DATA_INSUFFICIENT_HOLD | Provisional ACTIVE — treated as ACTIVE in current runtime; marked for restriction pending evidence | Full (current runtime) | As role allows (current runtime) | As role allows (current runtime) | Current: Full; Target: Restricted until N≥15 + Nautilus run |

**Note:** REDUCED and OBSERVE_ONLY are runtime-enforced via eligibility_state in the aggregator weight multiplier. BLOCKED and FROZEN are enforced in council_strategies.mqh per strategy. DATA_INSUFFICIENT_HOLD is a RCEM documentation designation only — current runtime does not enforce it. No source change is authorized based on this designation.

---

### 18.4 Strategy Genome Matrix

All 17 active strategies plus one legacy orphan. Source of truth for roles, families, weights, and evidence state.

| # | strategy_id | Role | Family | Baseline Weight | Zone ACTIVE | Direction | Live WR | Live N | Edge Status | Nautilus Status |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | sweep_reversal | SCOUT | LIQUIDITY_REVERSAL | 0.60 | REV | BOTH | 42.9% | 35 | WEAK_BUT_RECOVERABLE | NOT_RUN |
| 2 | bollinger_reclaim | CONFIRM | MEAN_RECLAIM | 1.00 | RMR, REV | BOTH | 38.5%* | 26 (W+L) | NOT_CONFIRMED | PARTIAL_REPLICATION (GC=F proxy) |
| 3 | trend_momentum | TREND_JUDGE | TREND_CONTINUATION | 0.95 | TC, BREAKOUT | BOTH | 42.9% | 28 | WEAK_BUT_RECOVERABLE | NOT_RUN |
| 4 | mfi_reversal_assist | EXHAUSTION_JUDGE | MOM_REVERSAL_ASSIST | 0.90 | REV | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 5 | trend_pullback_cont_v1 | CONFIRM | TREND_PULLBACK_CONT | 0.80 | TC, RMR (era-gated) | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 6 | momentum_breakout_cont_v1 | FROZEN | TREND_CONTINUATION | 0.00 | — | — | 9.1% | 11 | REJECTED | NOT_RUN |
| 7 | micro_structure_reentry_v1 | CONFIRM | TREND_CONTINUATION | 0.70 | TC | BOTH | 0% | 1 | DATA_INSUFFICIENT | NOT_RUN |
| 8 | breakdown_momentum_v1 | CONFIRM | TREND_CONTINUATION | 0.68 | TC | SELL | 30.0% | 10 | NOT_CONFIRMED | NOT_RUN |
| 9 | lower_high_rejection_v1 | CONFIRM | TREND_CONTINUATION | 0.66 | TC | SELL | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 10 | mean_reversion_bounce | CONFIRM | MEAN_RECLAIM | 0.92 | RMR | BOTH | 0% | 1 | DATA_INSUFFICIENT | NOT_RUN |
| 11 | range_edge_fade | CONFIRM | MEAN_RECLAIM | 0.88 | RMR | BOTH | 0% | 2 | DATA_INSUFFICIENT | NOT_RUN |
| 12 | fake_break_reversal | SCOUT | LIQUIDITY_REVERSAL | 0.94 | RMR | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 13 | range_compression_breakout | SCOUT | COMPRESSION_BREAKOUT | 0.95 | COMPRESSION, EXP | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 14 | volatility_squeeze_release | CONFIRM | COMPRESSION_BREAKOUT | 0.92 | COMPRESSION, EXP | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 15 | volatility_breakout | TREND_JUDGE | VOL_BREAKOUT | 0.92 | EXP | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 16 | expansion_continuation | TREND_JUDGE | EXP_CONTINUATION | 0.90 | EXP | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| 17 | micro_range_expansion | SCOUT | MICRO_RANGE_BREAK | 0.88 | EXP | BOTH | 0% | 0 | DATA_INSUFFICIENT | NOT_RUN |
| — | sweep_detector | ORPHANED_LEGACY_DATA | — | — | — | — | — | — | NOT_ACTIVE | — |

*bollinger_reclaim WR=38.5% uses wins/(wins+losses) denominator (W=10, L=16). See Amendment A4 (DESIGN_V1_REVIEW_AMENDMENTS_V1). Do not use WR=32.3% for edge decisions.

**ORPHANED_LEGACY_DATA — sweep_detector:** An identifier appearing in legacy performance data without a corresponding active strategy in the current council. Not a distinct strategy; presumed a prior name for sweep_reversal or an earlier prototype. No source entry in council_strategies.mqh. Not included in RCEM. No action required unless legacy data requires reconciliation.

**FROZEN — momentum_breakout_cont_v1:** WR=9.1% (1W/10L). FROZEN with weight=0.00. Redesign as pilot-only non-executor signal is a future option; no redesign plan authorized. Remains frozen until separate operator-authorized Codex task.

---

### 18.5 Provisional RCEM Table by Regime / Zone Bucket

This table expresses IRREW-intended eligibility per strategy × zone bucket. It is documentation-intent only. Current runtime uses zone_type routing in council_strategies.mqh, not this matrix.

**Zone bucket key:** TC = TREND_CONTINUATION | RMR = RANGE_MEAN_REVERSION | REV = REVERSAL | EXP = EXPANSION | COMP = COMPRESSION | N/A = no design eligibility

**State key:** ACTIVE = full eligibility | OBS = OBSERVE_ONLY (×0.15) | BLOCKED = no evaluation | FROZEN = excluded

| strategy_id | TC / T_UP | TC / T_DN | RMR / RNG | REV / VOL | EXP / VOL | COMP / any |
|---|---|---|---|---|---|---|
| sweep_reversal | OBS | OBS | OBS | ACTIVE | OBS | OBS |
| bollinger_reclaim | OBS† | OBS | ACTIVE | ACTIVE | OBS | OBS |
| trend_momentum | ACTIVE | ACTIVE | BLOCKED | BLOCKED | OBS | BLOCKED |
| mfi_reversal_assist | ACTIVE‡ | ACTIVE‡ | OBS | ACTIVE | OBS | OBS |
| trend_pullback_cont_v1 | ACTIVE | ACTIVE | OBS | BLOCKED | BLOCKED | BLOCKED |
| momentum_breakout_cont_v1 | FROZEN | FROZEN | FROZEN | FROZEN | FROZEN | FROZEN |
| micro_structure_reentry_v1 | ACTIVE | ACTIVE | BLOCKED | BLOCKED | BLOCKED | BLOCKED |
| breakdown_momentum_v1 | OBS | ACTIVE | BLOCKED | BLOCKED | BLOCKED | BLOCKED |
| lower_high_rejection_v1 | OBS | ACTIVE | BLOCKED | BLOCKED | BLOCKED | BLOCKED |
| mean_reversion_bounce | BLOCKED | BLOCKED | ACTIVE | OBS | BLOCKED | BLOCKED |
| range_edge_fade | BLOCKED | BLOCKED | ACTIVE | OBS | BLOCKED | BLOCKED |
| fake_break_reversal | BLOCKED | BLOCKED | ACTIVE | OBS | BLOCKED | BLOCKED |
| range_compression_breakout | BLOCKED | BLOCKED | BLOCKED | BLOCKED | ACTIVE | ACTIVE |
| volatility_squeeze_release | BLOCKED | BLOCKED | BLOCKED | BLOCKED | ACTIVE | ACTIVE |
| volatility_breakout | BLOCKED | BLOCKED | BLOCKED | BLOCKED | ACTIVE | BLOCKED |
| expansion_continuation | BLOCKED | BLOCKED | BLOCKED | BLOCKED | ACTIVE | BLOCKED |
| micro_range_expansion | BLOCKED | BLOCKED | BLOCKED | BLOCKED | ACTIVE | BLOCKED |

†bollinger_reclaim TC designation: OBSERVE_ONLY for any direction. Phase 5A gate additionally blocks SELL direction in TREND_UP (source-applied, runtime validation pending).

‡mfi_reversal_assist TC designation: ACTIVE as EXHAUSTION_JUDGE (advisory only until Phase 4B). No veto path until Phase 4B enabled. Current runtime: participates in council_quality calculation only.

**CRR coverage analysis for TC zone — critical structural gap:**
In TC zone, trend_momentum (TREND_JUDGE, TREND_CONTINUATION family) is the primary executor. Under IRREW cross-family CRR (Phase 4A, not yet implemented):
- trend_pullback_cont_v1 (TREND_PULLBACK_CONT family) — the ONLY cross-family CONFIRM available for TC
- micro_structure_reentry_v1 (TREND_CONTINUATION family) — same-family; does NOT satisfy cross-family CRR
- breakdown_momentum_v1 (TREND_CONTINUATION family) — same-family; does NOT satisfy cross-family CRR
- lower_high_rejection_v1 (TREND_CONTINUATION family) — same-family; does NOT satisfy cross-family CRR

**TC zone conclusion:** TPC is the sole CRR-satisfying CONFIRM for TC zone executions under IRREW. If TPC is not firing, cross-family CRR upgrade collapses TC executions to zero. This is the binding Phase 4A dependency.

---

### 18.6 Opportunity Ledger Findings — Phase 2 First Observations

**Source:** ai_opportunity_ledger.jsonl (2 records as of 2026-05-07 05:04) + ai_opportunity_summary.json
**Observation window:** 2026-05-06 23:13 through 2026-05-07 05:04 (two EA sessions)

| Finding | Detail | Classification |
|---|---|---|
| trend_momentum sole triggering strategy | 2 trigger records; all other 16 strategies: 0 triggers in TREND_UP/TC environment | RUNTIME_OBSERVED |
| trend_momentum 100% CRR-blocked | suppression_reason=CONFIRM_ROLE_REQUIRED; structural_gate_detail=confirm_role_absent | RUNTIME_OBSERVED |
| trend_pullback_cont_v1: 0 triggers | TPC has not fired in any session since P2 deployment | RUNTIME_OBSERVED |
| No CRR-satisfying confirm available | Confirms Phase 4A structural gap: TPC is required; TPC is not firing | RUNTIME_INFERRED |
| council_quality improving: 0.4887 → 0.5174 | council_quality crossed the 0.50 soft-gate floor between sessions | RUNTIME_OBSERVED |
| environment_score improving: 0.7500 → 0.8824 | ceis_signal_count: 0 → 1; trending market strengthening | RUNTIME_OBSERVED |
| zone_confidence stable: 0.9267 → 0.9243 | TC/TREND_UP zone assignment consistent across sessions | RUNTIME_OBSERVED |
| pre_ai_would_have_gated_quality: true (both records) | Without current structural suppression, quality gate would also have blocked | RUNTIME_OBSERVED |
| bollinger_reclaim: 0 triggers | Phase 5A gate not yet observable — no SELL trigger attempted in TREND_UP | RUNTIME_OBSERVED |
| mfi_reversal_assist: 0 triggers | Phase 4B veto remains blocked (0 MFI entries) | RUNTIME_OBSERVED |

**Interpretation:** The council is operating correctly. The CRR block on trend_momentum is the intended structural gate. TPC not firing is an expected state given its ATR-gated entry condition (0.70 ATR gap requirement, Package 2). This is not a system malfunction. Continued accumulation required before Phase 4A dependency evaluation.

---

### 18.7 Phase-Linked Decisions

| Decision | Phase | Linked Dependency | Current State |
|---|---|---|---|
| Cross-family CRR upgrade | Phase 4A | TPC must fire ≥5 distinct times with ≥20% eligible-bar rate | BLOCKED — TPC 0 triggers |
| Exhaustion veto implementation | Phase 4B | MFI must produce ≥5 signal-strength readings | BLOCKED — MFI 0 triggers |
| Quality soft gate reactivation | Phase 4C | Opportunity Ledger must have ≥200 records | BLOCKED — 2 records |
| bollinger_reclaim SELL-in-TREND_UP gate | Phase 5A | Source applied; runtime validation pending SELL trigger in TREND_UP context | SOURCE_APPLIED — AWAITING_RUNTIME_VALIDATION |
| breakdown_momentum_v1 TREND_DOWN gate | Phase 5B | Requires Nautilus Phase 3 certification | BLOCKED — not yet certified |
| DATA_INSUFFICIENT strategies — authority expansion | Phase 4+5 | Requires Nautilus certification + N≥15 live entries | BLOCKED — all DATA_INSUFFICIENT |
| EEWP weight adjustment (any strategy) | Phase 6 | Phase 2 live + Phase 3 ≥8 certified + Phase 4 50+ decisions | DESIGN_ONLY — blocked |
| Promotion/demotion governance | Phase 8 | Requires Phase 6 foundation | DESIGN_ONLY |
| trend_pullback_cont_v1 authority confirmation | Phase 4A prerequisite | TPC must demonstrate sustained fire rate | MONITORING |
| mfi_reversal_assist veto threshold design | Phase 4B prerequisite | First MFI signal strength readings observed | BLOCKED — no data |

---

### 18.8 What Must Not Be Implemented Yet

The following must not be implemented in MT5 source code until the stated blocking conditions are cleared. This list is authoritative for Phase 4 and beyond.

| Item | Reason | Blocking Condition |
|---|---|---|
| Cross-family CRR check in council_pre_ai_filter.mqh | TC execution collapse risk if TPC not firing | TPC: ≥5 distinct live firings, ≥20% eligible-bar rate, operator authorization |
| Exhaustion veto path in council_mode_runtime.mqh | Veto threshold has no calibration basis (0 MFI entries) | MFI: ≥5 signal-strength readings observed in live runtime |
| Quality soft gate enforcement in council_pre_ai_filter.mqh | Cannot audit suppression quality without ledger evidence | Opportunity Ledger: ≥200 records accumulated |
| OBSERVE_ONLY multiplier change (×0.15 → ×0.00) | May remove legitimate weak-signal diversity; requires ledger audit | Opportunity Ledger: ≥200 records; audit of OBSERVE_ONLY vote contribution to consensus_type |
| Weight changes for any strategy | EEWP is design-only; all weights static until Phase 6 | Phase 2 live + Phase 3 ≥8 certified + Phase 4 runtime sample ≥50 decisions |
| DATA_INSUFFICIENT strategy authority expansion | No evidence basis for new authority | N≥15 live entries AND Nautilus certification run complete |
| New strategies in council | Factory admission locked | Separate operator-authorized design + evidence plan required |
| Stop geometry changes (core_trade_engine.mqh) | Multi-file architectural risk | Separate design plan required |
| momentum_breakout_cont_v1 redesign as pilot signal | No redesign plan exists | Separate operator-authorized Codex task |
| Nautilus as runtime data source | MT5 is sole runtime authority | Never — permanent constraint |

---

### 18.9 Open Evidence Questions

| Question | Method | Status | Urgency |
|---|---|---|---|
| Why is trend_pullback_cont_v1 not triggering? Is the 0.70 ATR gate too restrictive? | Monitor Opportunity Ledger: track setup_conditions_seen vs trigger_seen for TPC over 50+ bars | 0 data points | HIGH — Phase 4A dependency |
| What is mfi_reversal_assist's signal strength distribution in live XAUUSD? | Monitor Opportunity Ledger: first MFI trigger entries with confidence_score readings | 0 data points | HIGH — Phase 4B dependency |
| Is bollinger_reclaim SELL direction being suppressed by Phase 5A gate in TREND_UP? | Monitor Opportunity Ledger: bollinger_reclaim trigger_blocked_by_direction count in TREND_UP sessions | 0 qualifying events observed | MEDIUM — Phase 5A validation |
| Does ledger confirm trend_momentum regime breakdown (BUY vs SELL, TC vs other zones)? | Accumulate 30+ ledger records for trend_momentum | 2 records — insufficient | MEDIUM — edge characterization |
| What is bollinger_reclaim's true edge in RANGE/RMR regime specifically? | Nautilus Phase 3: regime-stratified replay (XAUUSD M1, not GC=F proxy) | Not yet run | MEDIUM — Phase 5 guidance |
| Does sweep_reversal show degradation trend? (degradation_hint in Genome Matrix at N=35) | Monitor ai_strategy_memory.json WR over next 30+ trades | Currently 42.9% at N=35 | LOW — near breakeven, monitor |
| Is OBSERVE_ONLY ×0.15 multiplier contributing to harmful consensus distortion? | Opportunity Ledger audit: OBSERVE_ONLY vote influence on consensus_type outcomes | Blocked — requires ≥200 records | LOW — Phase 4 dependency |

---

### 18.10 Next Safe Work Package

**Authorized immediately (no source changes required):**

1. **Phase 0 monitoring continuation** — observe Opportunity Ledger accumulation; specifically track trend_pullback_cont_v1 setup_conditions_seen and mfi_reversal_assist trigger_seen. Both counters at 0.

2. **Nautilus Phase 3 pipeline preparation** — export XAUUSD M1/M5 OHLCV from MetaEditor. Begin source-faithful trigger replication for trend_momentum (sole TC executor in current ledger; 2 trigger records confirm expected behavior). Apply 5-variant analysis per DESIGN_V1 workflow.

3. **Nautilus bollinger_reclaim upgrade** — extend PARTIAL_REPLICATION (GC=F proxy, 28,677 bars) to full XAUUSD M1 replay. Resolve WR denominator (W=10/L=16 vs total_entries=31) against exact source snapshot. Target: regime-stratified edge classification (TREND_UP vs RMR/RANGE vs TREND_DOWN).

4. **Phase 5A runtime validation (monitoring)** — declare Phase 5A RUNTIME_VALIDATED when ≥3 bollinger_reclaim SELL triggers in TREND_UP context are confirmed suppressed. Currently 0 qualifying events. No source action required — monitoring only.

**Blocked — do not begin:**

5. Phase 4A cross-family CRR (blocked: TPC fire rate unverified)
6. Phase 4B exhaustion veto design (blocked: MFI 0 entries)
7. Phase 4C quality gate reactivation (blocked: ledger < 200 records)
8. Phase 5B breakdown_momentum restriction (blocked: Nautilus certification not run)
9. Phase 6 EEWP (blocked: all prerequisites unmet)
10. Any weight or authority change for any strategy

---

```
SECTION_ID:                      RCEM_V1_PROVISIONAL
SECTION_TYPE:                    DOCUMENTATION_ONLY
ADOPTED_DATE:                    2026-05-07
APPROVED_BY:                     Operator (Phase 1 documentation task authorization)
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
RUNTIME_ENFORCEMENT:             NO — all eligibility states are documentation-intent only except where source patches already applied (Phase 5A bollinger_reclaim gate)
RCEM_ENFORCED_IN_SOURCE:         NO — current runtime uses zone_type routing in council_strategies.mqh
PHASE_4A_STATUS:                 BLOCKED — TPC 0 triggers
PHASE_4B_STATUS:                 BLOCKED — MFI 0 triggers
PHASE_4C_STATUS:                 BLOCKED — Ledger < 200 records
PHASE_5A_STATUS:                 SOURCE_APPLIED — AWAITING_RUNTIME_VALIDATION
SYSTEM_STATUS:                   DEVELOPING
MT5_AUTHORITY:                   PRESERVED
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY
NEXT_AUTHORIZED_ACTION:          Phase 0 monitoring continuation + Nautilus Phase 3 pipeline preparation
```

---

## 19. TREND_MOMENTUM_NAUTILUS_CERTIFICATION_A_B_C_V1 — Edge Profile and External Benchmark Context

### 19.0 Adoption / Status

**Certification date:** 2026-05-07
**Evidence type:** Nautilus replay lab — EVIDENCE_ONLY
**Data:** Clean XAUUSD M1/M5 MT5 API export (not GCF proxy)
  - M1: 100,466 bars, 2026-01-23 to 2026-05-07 (104 days, broker-limited)
  - M5: 34,652 bars, 2025-11-07 to 2026-05-07 (181 days, complete)

**What this section authorizes:**
- Strategy evidence classification update only
- Documentation of edge profile and external benchmark comparison

**What this section does NOT authorize:**
- MT5 source changes of any kind
- Phase 4A, 4B, or 4C enablement
- Weight changes for trend_momentum
- CRR, RCEM, or gate implementation
- Any change to trend_momentum's role, zone eligibility, or authority
- Change to production readiness status (remains DEVELOPING)

---

### 19.1 Variant A — Unrestricted Baseline

**Classification:** CONFIRMED_RUNTIME_TRUTH (Nautilus replay, clean data)

| Metric | Value |
|---|---|
| N closed | 8,445 |
| WR | 39.11% |
| Expectancy | -0.022R |
| Profit factor | 0.9635 |
| Max consec losses | 18 |
| Breakeven WR | 40.00% |
| Practical WR | 42.40% |
| **Label** | **EDGE_WEAK_BUT_RECOVERABLE** |

**Key finding:** Raw unrestricted edge is below breakeven. The strategy fires ~81 triggers/day at M1 frequency. M5_CONFLICT subgroup (WR=19.88%, N=649) is the dominant drag — 7.7% of entries, catastrophically below breakeven.

**M5_CONFLICT is toxic.** WR=19.88% — roughly 2x worse than a coin flip adjusted for RR costs. These are entries where M1 EMA signals BUY/SELL but the M5 trend directly opposes the direction. This subgroup is the single most important finding from Variant A.

---

### 19.2 Variant B — M5_CONFLICT Excluded

**Classification:** CONFIRMED_RUNTIME_TRUTH (Nautilus replay)

| Metric | Variant A | Variant B | Delta |
|---|---|---|---|
| N closed | 8,445 | 7,940 | -505 (-6.0%) |
| WR | 39.11% | **41.17%** | +2.06pp |
| Expectancy | -0.022R | **+0.029R** | +0.051R |
| Profit factor | 0.9635 | **1.0498** | +0.086 |
| Max consec losses | 18 | **14** | -4 |
| Months below breakeven | 2/6 | **0/6** | all above |
| **Label** | WEAK_BUT_RECOVERABLE | **WEAK_BUT_RECOVERABLE** | ↑ (margin improved) |

**Recovery path confirmed.** Excluding M5_CONFLICT:
- Flips expectancy from negative to positive
- Eliminates below-breakeven months from the sample
- Reduces max drawdown streak by 4
- Costs only 6% of trade count

**BUY/SELL split (Variant B):**
- BUY: WR=39.82%, N=4,001 — marginally below breakeven
- SELL: WR=42.55%, N=3,939 — above practical threshold

SELL direction is the primary edge carrier.

---

### 19.3 Variant C — Regime × Direction Stratification

**Classification:** CONFIRMED_RUNTIME_TRUTH (Nautilus replay, post-hoc stratification of Variant B)

**Regime proxy:** M5 EMA20/EMA50 state at time of M1 entry
- TREND_UP: M5 EMA20 > EMA50 AND close >= EMA20 (was BULL in Variant B m5_trend_raw)
- TREND_DOWN: M5 EMA20 < EMA50 AND close <= EMA20 (was BEAR)
- RANGE_NEUTRAL: neither condition (was NEUTRAL)

**Structural consequence of Variant B filter:** TREND_DOWN+BUY = 0; TREND_UP+SELL = 0 — M5_CONFLICT exclusion collapses these two buckets to empty. Only 4 of 6 theoretical buckets are active.

**Bucket results:**

| Bucket | N | WR | E[R] | PF | MaxCL | Label |
|---|---|---|---|---|---|---|
| TREND_UP + BUY | 2,659 | 39.34% | -0.017R | 0.9727 | 13 | EDGE_NOT_CONFIRMED |
| TREND_DOWN + SELL | 2,537 | 41.55% | +0.039R | 1.0661 | 13 | EDGE_WEAK_BUT_RECOVERABLE |
| RANGE_NEUTRAL + BUY | 1,342 | 40.76% | +0.019R | 1.0321 | 15 | EDGE_WEAK_BUT_RECOVERABLE |
| **RANGE_NEUTRAL + SELL** | **1,402** | **44.37%** | **+0.109R** | **1.1962** | **8** | **EDGE_SUPPORTED** |
| TREND_UP + SELL | 0 | — | — | — | — | EMPTY |
| TREND_DOWN + BUY | 0 | — | — | — | — | EMPTY |

**RANGE_NEUTRAL + SELL is the strongest single certified bucket — EDGE_SUPPORTED.**
WR=44.37% exceeds the 43% EDGE_SUPPORTED threshold. Profit factor 1.1962. Max consecutive losses only 8. Monthly WR consistently above 42% across Jan–May 2026.

**TREND_UP + BUY is structurally weak — EDGE_NOT_CONFIRMED.**
WR=39.34%, negative expectancy (-0.017R), profit factor below 1. This is paradoxically the "most aligned" direction (M5 bullish + BUY entry in established uptrend) yet performs worst. The most likely explanation is overextension: trend_momentum M1 entries during strong TREND_UP regimes arrive after the move is mature, increasing mean-reversion risk. The not_late guard (ATR×1.20 max distance) mitigates but does not eliminate this.

**SELL asymmetric advantage:** SELL outperforms BUY in every regime context:
- TREND_DOWN+SELL > TREND_DOWN+BUY (N/A, empty)
- RANGE_NEUTRAL+SELL > RANGE_NEUTRAL+BUY (+3.61pp WR, +0.090R expectancy)
- SELL overall: WR=42.55% vs BUY: WR=39.82%

**Hypothesis (OPEN_QUESTION):** trend_momentum may be catching bearish transitions more reliably than bullish continuations. XAUUSD gold may exhibit asymmetric downside momentum at M1/M5 intraday frequency — bearish moves are sharper and more persistent, while bullish continuation spreads over longer, more volatile M1 windows.

---

### 19.4 IRREW Interpretation

| Interpretation | Evidence | Classification |
|---|---|---|
| trend_momentum overall label: EDGE_WEAK_BUT_RECOVERABLE | Variants A/B/C | CONFIRMED |
| M5_CONFLICT exclusion is a valid recovery path | Variant B | CONFIRMED |
| RANGE_NEUTRAL+SELL is the single EDGE_SUPPORTED bucket | Variant C | CONFIRMED |
| SELL direction carries stronger edge than BUY | Variants B/C | CONFIRMED |
| TREND_UP+BUY is structurally weak (below breakeven, negative E[R]) | Variant C | CONFIRMED |
| trend_momentum should not be treated as strong unrestricted executor | Variants A/C | CONFIRMED |
| Overextension causes TREND_UP+BUY weakness | — | OPEN_QUESTION |
| M5 alignment direction filter is superior to EMA alignment alone | See §19.5 TSMOM proxy | PLAUSIBLE_BUT_CONTESTED |
| Direction asymmetry justifies BUY suppression in MT5 now | — | NOT_AUTHORIZED |
| Phase 4A is now unlocked | — | NO — TPC still 0 triggers |

**Architecture implications (Nautilus-informed, not implementation-authorized):**

The M5_CONFLICT exclusion evidence supports the IRREW cross-family CRR gate concept: trades that lack multi-timeframe alignment are demonstrably inferior. However, **the M5 filter is not implementable as a hard gate now** — Phase 4A requires TPC live fire rate first.

The TREND_UP+BUY weakness combined with RANGE_NEUTRAL+SELL strength suggests that trend_momentum's edge may be structurally asymmetric. In IRREW architecture, this would eventually be expressible as a direction-conditioned eligibility in the RCEM matrix — but this cannot be implemented until Phase 4 is complete.

---

### 19.5 Restrictions — What Must Not Happen Based on This Certification

The following are explicitly forbidden despite the Nautilus evidence above:

| Item | Reason |
|---|---|
| Add hard M5 alignment gate to MT5 (council_strategies.mqh or pre_ai_filter) | Phase 4A blocked; TPC fire rate unverified; TC collapse risk |
| Disable BUY direction for trend_momentum in MT5 | Not authorized; asymmetry is statistical evidence, not a confirmed structural defect; Variant D not run |
| Change trend_momentum vote_weight | EEWP is design-only; Phase 6 blocked until Phase 2+3+4 prerequisites met |
| Promote trend_momentum to unconditional ACTIVE in TREND_UP | Variant C evidence contradicts this |
| Demote trend_momentum to OBSERVE_ONLY | No single Nautilus result authorizes RCEM enforcement changes |
| Loosen CRR gate based on high suppression rate | CRR suppression is intended behavior; the 2 ledger records confirm correct structural filtering |
| Treat RANGE_NEUTRAL+SELL EDGE_SUPPORTED as production approval | Label applies to that bucket only; overall strategy is WEAK_BUT_RECOVERABLE |
| Use Nautilus evidence as MT5 runtime data source | Nautilus = evidence/research only; MT5 is sole runtime authority |
| Claim production readiness improvement from this certification | System status remains DEVELOPING |

---

### 19.6 Next Evidence Questions

| Question | Priority | Method | Status |
|---|---|---|---|
| Is TREND_UP+BUY weakness due to overextension (entry distance from EMA)? | HIGH | Variant D: analyze (entry - EMA20) / ATR for TREND_UP+BUY subset | NOT_RUN |
| Is TREND_UP+BUY weakness session-dependent (Asian vs London vs NY)? | HIGH | Variant D: UTC session split on TREND_UP+BUY trades | NOT_RUN |
| Does live MT5 ledger confirm M5_CONFLICT toxicity? | MEDIUM | Accumulate 30+ trend_momentum ledger records with M5 alignment field | 2 records — insufficient |
| Does TPC ever provide cross-family CRR confirmation for trend_momentum? | HIGH | Monitor Opportunity Ledger: TPC trigger_seen in TC zone | 0 entries |
| Would M5 alignment filter reduce live MT5 trade count materially? | MEDIUM | Depends on M5 state distribution at runtime; ledger will show | 2 records — insufficient |
| Does SELL asymmetry persist past 2026 data? | MEDIUM | Future Nautilus certification when more M1 data available (broker export extends) | DEFERRED |
| Is the 1h return-lookback proxy (TSMOM LB12) superior to EMA alignment? | MEDIUM | Variant D or dedicated follow-up; proxy results are promising | See §19.9 |

---

### 19.7 Time-Series Momentum Literature Summary

**Primary source:**
Moskowitz, T.J., Ooi, Y.H., Pedersen, L.H. (2012). "Time Series Momentum." *Journal of Financial Economics*, Vol. 104(2), pp. 228–250.
Source: https://papers.ssrn.com/sol3/papers.cfm?abstract_id=2089463 | AQR: https://www.aqr.com/Insights/Research/Journal-Article/Time-Series-Momentum

**Core finding:**
An asset's own 12-month past excess return positively predicts its future 1-month return. The effect is:
- Positive for 58 diverse futures/forwards (equity indices, fixed income, commodities, currencies)
- Consistent: positive for every single asset in the universe over the 25-year study period
- Profitable across asset classes, not confined to equities
- Partially reverses at horizons beyond 12 months (consistent with initial under-reaction, delayed over-reaction)
- Performs best during extreme trending markets (crash protection / crisis alpha)

**Gold/commodity relevance:**
Commodity futures, including precious metals, are explicitly in the TSMOM universe. The finding holds for gold futures (GC=F equivalent) at the monthly rebalancing frequency. This is STRONGLY_SUPPORTED evidence for a TSMOM edge on gold at daily/monthly horizon.

**Secondary source:**
"A Century of Evidence on Trend-Following Investing." AQR. 2017.
Source: https://www.aqr.com/Insights/Research/Journal-Article/A-Century-of-Evidence-on-Trend-Following-Investing
Extends the TSMOM finding back to 1880 across 67 markets. Trend-following has been consistently profitable for 135+ years. Confirms commodity futures inclusion.

**Supporting source:**
Baltas, N., Kosowski, R. "Momentum Strategies in Futures Markets and Trend-following Funds." SSRN.
Source: https://papers.ssrn.com/sol3/Delivery.cfm/SSRN_ID2196898_code896686.pdf?abstractid=1968996
Documents the connection between time-series momentum strategies and CTA/managed futures returns. CTA performance is substantially explained by TSMOM factor exposure.

**Key institutional context:**
- Managed futures / CTA industry is the largest practitioner of TSMOM
- Typical CTA uses: multi-asset diversification, volatility scaling, long-term trend models (months not minutes)
- Gold at CTA frequency: typical lookback 50–250 days, position sized by trailing vol
- TSMOM Sharpe ratios documented: 0.60–1.40 depending on universe and period (before costs at daily/monthly frequency)

**Evidence classification for all TSMOM literature claims:**
- TSMOM edge on commodity futures at monthly/daily horizon: **STRONGLY_SUPPORTED** (JFE 2012, 25+ years, 58 assets)
- TSMOM edge persistent over century: **STRONGLY_SUPPORTED** (AQR Century paper)
- TSMOM edge at intraday M1/M5 frequency on XAUUSD: **PLAUSIBLE_BUT_UNVERIFIED** (not documented in literature; our proxy tests this)
- Direct transfer of literature edge to live MT5 intraday trading: **PLAUSIBLE_BUT_UNVERIFIED**

---

### 19.8 Current trend_momentum vs Classical TSMOM: Conceptual Comparison

| Dimension | trend_momentum (current) | Classical TSMOM |
|---|---|---|
| Signal type | EMA20/50 alignment + close>=EMA20 + not_late guard | Sign of past N-month return |
| Horizon | M1 intraday (5–6 bars avg hold) | Monthly rebalancing (~20 day hold) |
| Lookback | Inherent in EMA state (~20–50 bars) | 12 months (252 trading days) |
| Instrument | XAUUSD single | 58+ diversified futures |
| Volatility scaling | Fixed ATR×1.20 stop | Dynamic — position scaled by trailing vol |
| Regime sensitivity | High — TREND_UP+BUY weak | Low — benefits from any strong trend |
| Cost sensitivity | Very high — $0.12 per trade, 81/day | Low — rebalances monthly |
| Confirmation requirement | Cross-family CRR (IRREW target) | None — pure momentum signal |
| Direction asymmetry | SELL > BUY | Not documented in original paper |
| Overextension risk | HIGH — not_late guard partially mitigates | LOW — monthly entry less timing-sensitive |
| Literature support | Not tested at this frequency | JFE 2012, strong |
| IRREW role | TREND_JUDGE (primary executor, TC/BREAKOUT) | Not applicable as-is |
| Intraday execution | YES | NO — wrong frequency |
| XAUUSD applicability | YES (designed for it) | YES (commodity futures documented) |

**Key conceptual gap:** Current trend_momentum uses EMA state as a momentum proxy. Classical TSMOM uses raw return sign. These are related but not identical. EMA alignment is a smoothed, lagged momentum indicator that may introduce more signal persistence but also more lag than raw return sign.

**Is trend_momentum a "true trend-following" strategy?**
Partially. It uses EMA alignment (a trend indicator) with M5 confirmation (multi-timeframe trend agreement). However:
- M5_CONFLICT toxicity **supports** multi-timeframe trend agreement — consistent with TSMOM logic
- SELL-side strength **supports** asymmetric momentum (gold bearish moves may be sharper/faster)
- TREND_UP+BUY weakness **challenges** simple trend continuation interpretation: the most "aligned" bucket underperforms, suggesting entry timing matters more than directional trend agreement alone
- RANGE_NEUTRAL+SELL being strongest **challenges** pure trend-following: the strategy performs best when SELLING into neutral-to-bearish M5 conditions, not in confirmed strong downtrends

**Interpretation (PLAUSIBLE_BUT_UNVERIFIED):** trend_momentum may be catching bearish breakdowns from neutral M5 states rather than pure trend continuation. This is closer to a momentum transition signal than a trend-following signal.

---

### 19.9 Short-Horizon TSMOM Proxy Benchmark Results

**Benchmark ID:** TSMOM_PROXY_BENCHMARK_V1
**Type:** SHORT_HORIZON_TSMOM_PROXY — NOT institutional TSMOM
**Artifacts:**
- Script: `nautilus_lab/scripts/cert_tsmom_proxy_benchmark_v1.py`
- Trades: `nautilus_lab/outputs/tsmom_proxy_benchmark_v1_trades.csv` (43,108 rows across 3 lookbacks)
- Metrics: `nautilus_lab/outputs/tsmom_proxy_benchmark_v1_metrics.json`
- Certification: `nautilus_lab/certifications/certification_tsmom_proxy_benchmark_v1.md`

**Signal logic:**
- M5 signal = sign(M5_close[t] - M5_close[t-N]) for N in {12, 24, 48} M5 bars
- BULL → BUY at M1 entry; BEAR → SELL at M1 entry
- Identical cost model, ATR stop, RR=1.5, sequential simulation as Variant B
- No EMA alignment condition, no not_late guard, no M5_CONFLICT filter (signal IS the direction)

**Results:**

| Strategy | N | WR | E[R] | PF | MaxCL | Label |
|---|---|---|---|---|---|---|
| trend_momentum Variant B (baseline) | 7,940 | 41.17% | +0.029R | 1.0498 | 14 | EDGE_WEAK_BUT_RECOVERABLE |
| TSMOM proxy LB12 (60min) | 14,301 | **42.63%** | **+0.066R** | **1.1144** | — | EDGE_WEAK_BUT_RECOVERABLE |
| TSMOM proxy LB24 (120min) | 14,352 | 41.11% | +0.028R | 1.0471 | — | EDGE_WEAK_BUT_RECOVERABLE |
| TSMOM proxy LB48 (240min) | 14,452 | 40.72% | +0.018R | 1.0304 | — | EDGE_WEAK_BUT_RECOVERABLE |

**Direction breakdown:**

| Strategy | BUY WR | BUY N | SELL WR | SELL N |
|---|---|---|---|---|
| Variant B | 39.82% | 4,001 | 42.55% | 3,939 |
| TSMOM LB12 | 41.81% | 7,146 | **43.44%** | 7,155 |
| TSMOM LB24 | 40.35% | 7,259 | 41.89% | 7,093 |
| TSMOM LB48 | 39.89% | 7,307 | 41.57% | 7,145 |

**Key findings from proxy:**

1. **LB12 (1h) outperforms Variant B on WR and expectancy.** WR=42.63% vs 41.17%. E[R]=+0.066R vs +0.029R. This is the most important result — a simpler raw-momentum signal on 1h M5 lookback beats the EMA-alignment approach by 2.3× on expectancy.

2. **Trade count ~1.8× higher for proxy.** LB12: 14,301 trades vs Variant B: 7,940. The proxy enters more frequently because it lacks EMA alignment and not_late guards. Higher N provides more statistical confidence but also means the proxy captures more "ordinary" momentum entries including potentially lower-quality ones.

3. **SELL asymmetry persists in proxy.** SELL WR consistently exceeds BUY WR across all three lookbacks (by +1.5 to +2.6pp). This confirms that the SELL advantage is not specific to EMA alignment logic — it is a property of the XAUUSD M1 market structure or data period.

4. **Lookback decay.** Performance decreases monotonically as lookback increases (LB12 > LB24 > LB48). Shorter recent momentum is more predictive at intraday M1 frequency on this data. This is consistent with intraday momentum being a short-memory phenomenon.

5. **No lookback reaches EDGE_SUPPORTED.** All three proxy lookbacks are EDGE_WEAK_BUT_RECOVERABLE — same label as Variant B. The edge at intraday M1 frequency is inherently bounded.

**Evidence classification for proxy findings:**

| Claim | Classification |
|---|---|
| LB12 proxy WR=42.63% on this 104-day window | VERIFIED (run result) |
| LB12 proxy would outperform Variant B in a different data window | PLAUSIBLE_BUT_UNVERIFIED |
| EMA alignment adds no value over raw return sign | SUSPICIOUS — needs Variant D + more data |
| Short-horizon TSMOM is equivalent to institutional TSMOM | CONTRADICTED |
| Proxy trade count difference invalidates comparison | PARTIALLY — more trades means different risk profile |
| SELL XAUUSD M1 has structural intraday momentum | PLAUSIBLE — consistent across strategies and lookbacks |

**Interpretation caution:**
The LB12 proxy's apparent outperformance vs Variant B should not be over-interpreted. The proxy:
- Has 1.8× more entries, meaning it captures more market exposure per unit time
- Has no not_late guard (may enter overextended positions that trend_momentum rejects)
- Has no IRREW role or council confirmation requirement
- Operates as an unrestricted standalone signal, not inside a council architecture

The correct interpretation is: **raw 1h momentum signal contains at least as much directional information as the EMA alignment approach at this frequency on this data**. Whether this implies the EMA filter should be replaced is an OPEN_QUESTION requiring Variant D and more data.

---

### 19.10 Comparison Table: trend_momentum vs TSMOM Suitability for IRREW

| Dimension | trend_momentum (current) | Classical TSMOM | Short-horizon proxy |
|---|---|---|---|
| Evidence strength | Certif. A/B/C (104d M1) | JFE 2012 (25y, 58 assets) | Proxy only, 104d M1 |
| Horizon fit for M1 exec | NATIVE | POOR (too slow) | MEDIUM (same data) |
| XAUUSD fit | YES (designed for it) | YES (commodity documented) | YES (same instrument) |
| M1/M5 fit | YES | NO | YES |
| Regime fit | PARTIAL (TC/BREAKOUT, EDGE_NOT_CONFIRMED in TU+BUY) | Not regime-conditioned | Not tested by regime |
| IRREW role candidate | TREND_JUDGE (current) | Context/filter layer (H1+) | Potential signal feature |
| Implementation difficulty | LOW (in source) | HIGH (new file, new data req.) | MEDIUM |
| Risk of overfitting | LOW (simple EMA rule) | LOW (classical, well-documented) | MEDIUM (single window) |
| H1/H4/D1 data needed | NO | YES | NO |
| Testable in Nautilus now | YES | PARTIAL (D1 export needed) | YES (done) |
| Expected IRREW role | Primary TREND_JUDGE (TC zone) | H1/D1 trend filter or context layer | Signal feature or filter |
| Missing evidence | Variant D; more M1 data | D1 export; long-horizon replay | More data, different periods |

**TSMOM as IRREW candidate — classification: SYSTEM_FIT_MEDIUM**

- **For daily/H4 trend direction layer:** SYSTEM_FIT_HIGH — TSMOM on H1/D1 XAUUSD would provide a high-quality trend context that could inform RCEM regime labeling. Well-documented, robust, low overfitting risk.
- **As M1/M5 primary executor replacement:** SYSTEM_FIT_LOW — wrong frequency, cost regime unfavorable, literature does not support.
- **As short-horizon return-lookback feature (proxy form):** SYSTEM_FIT_MEDIUM — proxy LB12 is competitive with current EMA approach; could inform a future signal redesign. Requires Variant D.

---

### 19.11 Final Recommendation

**Status of the three choices as of 2026-05-07:**

| Option | Decision | Reason |
|---|---|---|
| Run Variant D (BUY overextension/session analysis) | **RECOMMENDED NEXT** | Directly answers the TREND_UP+BUY root cause question; uses existing trade set; no new simulation; <2h work |
| Run H1/D1 TSMOM benchmark | **ADD TO QUEUE** | Requires D1 export from MetaEditor; data not currently available; worth doing as trend direction context layer research |
| Add short-horizon TSMOM proxy to External Candidate Queue | **DONE** — proxy run | Results documented; LB12 is competitive; not implementation-authorized |
| Stop TSMOM research | **NO** | Classical TSMOM has too strong a literature basis for XAUUSD futures to dismiss |
| Implement any change to MT5 from Section 19 | **FORBIDDEN** | No source change is authorized from Nautilus evidence alone |

**External Candidate Queue — additions from this section:**

1. **SHORT_HORIZON_TSMOM_PROXY (LB12)** — RESEARCH_CANDIDATE
   - Evidence: proxy WR=42.63%, E[R]=+0.066R on 104d M1
   - Gap: single data window; lacks not_late guard; not regime-stratified; Variant D should run first
   - Possible future role: M5 return-lookback as additional feature in trend_momentum signal redesign

2. **CLASSICAL_TSMOM_H1_D1_LAYER** — EXTERNAL_CANDIDATE_QUEUE
   - Evidence: JFE 2012, commodity futures, gold included, strong
   - Gap: D1/H1 XAUUSD export needed; daily horizon incompatible with M1 executor
   - Possible future role: RCEM regime labeling (trend_up/trend_down from D1 TSMOM signal)
   - Required: MetaEditor D1 XAUUSD export (weeks of data minimum, years preferred)

---

### 19.12 Footer

```
SECTION_ID:                      TREND_MOMENTUM_NAUTILUS_CERTIFICATION_A_B_C_V1
SECTION_TYPE:                    CERTIFICATION_DOCUMENTATION_AND_BENCHMARK_COMPARISON
ADDED_DATE:                      2026-05-07
PIML_BACKUP:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_075310
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
MT5_AUTHORITY:                   PRESERVED
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY
SYSTEM_STATUS:                   DEVELOPING (unchanged)
TREND_MOMENTUM_LABEL:            EDGE_WEAK_BUT_RECOVERABLE (overall, post M5_CONFLICT exclusion)
STRONGEST_BUCKET:                RANGE_NEUTRAL_SELL — EDGE_SUPPORTED (WR=44.37%, N=1,402)
WEAKEST_BUCKET:                  TREND_UP_BUY — EDGE_NOT_CONFIRMED (WR=39.34%, N=2,659)
M5_CONFLICT_VERDICT:             TOXIC — WR=19.88%; exclusion confirms recovery path
TSMOM_LITERATURE:                STRONGLY_SUPPORTED at daily/monthly horizon (JFE 2012)
TSMOM_PROXY_RESULT:              LB12 WR=42.63% E[R]=+0.066R — EDGE_WEAK_BUT_RECOVERABLE (proxy only)
PHASE_4A_STATUS:                 BLOCKED (unchanged — TPC 0 triggers)
PHASE_4B_STATUS:                 BLOCKED (unchanged — MFI 0 triggers)
PHASE_4C_STATUS:                 BLOCKED (unchanged — Ledger < 200 records)
NEXT_AUTHORIZED_ACTION:          Variant D (BUY overextension analysis) + D1 data export planning
EXTERNAL_CANDIDATE_QUEUE:        SHORT_HORIZON_TSMOM_PROXY (LB12), CLASSICAL_TSMOM_H1_D1_LAYER
```

---

## 20. INSTITUTIONAL_SEPARATION_DOCTRINE_V1 — Alpha/Thesis, Risk, Allocation, Execution, Attribution

### 20.0 Management Decision Record

**Decision date:** 2026-05-07
**Decision type:** Strategic architecture doctrine — documentation only
**Authority:** Management (operator)
**Supersedes:** No prior section — first formal doctrine definition
**Effect date:** Immediate (as architecture review lens)
**Implementation date:** Deferred — see §20.9

This doctrine is adopted after deeper architectural review. It formalizes the separation that already implicitly exists across the current system into five named, non-overlapping institutional layers. It is the governing principle for all future IRREW evolution, design review, prompt interpretation, and Codex task scoping.

---

### 20.1 Adoption Status

The institutional separation doctrine is **management-approved** as of 2026-05-07.

What this adoption means:
- The five-layer model is the canonical lens for interpreting all future architecture discussions, design tasks, and Codex scoping.
- Every future change to the system should be classified by layer before implementation begins.
- Every Nautilus result, PIML update, or prompt must be interpretable in these terms.

What this adoption does **not** mean:
- No MT5 source files are modified by this decision.
- No runtime behavior changes.
- No strategy logic, gates, weights, RCEM enforcement, or execution geometry changes.
- No council, aggregator, filter, governor, or trade engine changes.
- No change to Phase 4A/4B/4C blocking conditions.
- No change to production readiness. System status remains **DEVELOPING**.
- Nautilus remains evidence/replay/certification lab only.
- MT5 remains the sole runtime authority.

Truth marker: **CONFIRMED_ARCHITECTURAL_DECISION**

---

### 20.2 Doctrine Definition — The Five Layers

#### Layer 1 — Alpha / Thesis

**What it is:**
The layer that produces market hypotheses, directional signals, and thesis candidates. A thesis is a structured claim: "In this regime, at this moment, for this direction, the evidence supports a trade." Alpha is not a fact — it is a conditional, falsifiable claim that must be tested.

**What belongs here:**
- All 17 council strategies (each originates or supports a directional thesis)
- Nautilus replay candidates, external strategy playbooks
- TSMOM proxy research, EMA alignment studies, trendline playbooks
- Signal primitives in `strategy_runtime.mqh`
- Historical replay evidence from Nautilus lab
- M5 alignment studies, regime-stratified edge profiles
- External academic findings (Moskowitz/Ooi/Pedersen, etc.)

**What it must not do:**
- Alpha never directly executes a trade.
- Alpha does not determine risk tolerance, position size, or veto conditions.
- Alpha does not control stop geometry.
- Alpha generating a signal is the beginning of the decision chain, not the end.

**Current system anchor:** `council_strategies.mqh`, `strategy_runtime.mqh` trigger primitives, Nautilus lab, Nautilus certification outputs.

---

#### Layer 2 — Risk

**What it is:**
The layer that judges whether a thesis is safe to act upon. Risk assesses whether the environment invalidates the thesis, whether the trade setup is exhausted, hostile, or flagged, and whether structural conditions (regime gates, veto triggers, quality floors) permit proceeding.

**What belongs here:**
- Structural gates: DSN (diversity), CRR (confirmation role), DOMINANT_SIDE, council_quality floor
- Regime-hostile zone eligibility (RCEM enforcement when activated)
- Exhaustion veto concept (Phase 4B, not yet implemented)
- Dirty-market / hostile-environment detection
- `council_pre_ai_filter.mqh` — the primary Risk gate
- `risk_state_policy_engine.mqh` — risk state authority
- `runtime_governance_status.json` — runtime risk truth
- `council_ai_governor.mqh` — advisory threshold adjustments (currently advisory; eventual risk layer component)
- Future: M5_CONFLICT hard gate (if and when authorized)
- Future: cross-family CRR enforcement (Phase 4A)

**What Risk must not do:**
- Risk must not invent alpha. A gate that blocks a thesis is not an alternative thesis.
- Risk must not combine alpha signal generation with suppression logic in the same function without clear layer separation.
- Risk findings do not replace alpha evidence — they constrain it.
- Risk thresholds must be evidence-calibrated (requires Opportunity Ledger audit before tightening).

**Current system anchor:** `council_pre_ai_filter.mqh`, `risk_state_policy_engine.mqh`, `runtime_governance_status.json`, `council_ai_governor.mqh` (advisory).

---

#### Layer 3 — Portfolio / Allocation

**What it is:**
The layer that decides whether a thesis, once passed by Risk, deserves capital commitment — and at what size, frequency, and priority. Allocation is evidence-earned, not signal-driven. A strategy earning a higher vote weight is making an allocation claim, not an alpha claim.

**What belongs here:**
- Vote weights (`vote_weight` fields in `council_strategies.mqh`) — current form is static allocation
- Future EEWP (Evidence-Earned Weight Progression, Phase 6) — dynamic allocation based on certified edge
- Strategy-level and family-level budget caps (future)
- Frequency throttling or cooldown logic (future)
- Diversification requirements at the thesis level (future)
- Certification multipliers from Nautilus lab (future input to allocation, not runtime data source)
- Operator-authorized weight change process

**What Allocation must not do:**
- Allocation does not produce alpha. A high vote_weight does not mean a thesis is right.
- Allocation must not size before Risk has cleared the thesis.
- Dynamic weight changes (EEWP) require: Phase 2 live + Phase 3 ≥8 certified + Phase 4 runtime sample ≥50 decisions + operator authorization. No automatic adjustments.
- Allocation changes are always bounded, one strategy at a time, with 24h runtime validation between changes.

**Current system anchor:** `vote_weight` values in `council_strategies.mqh` (static). EEWP: design-only (Phase 6). No runtime allocation layer exists yet.

---

#### Layer 4 — Execution

**What it is:**
The layer that handles actual order permission, entry routing, stop and target geometry, trade engine behavior, and MT5 broker-side execution. Execution is the terminal output of the decision chain. It does not originate, risk-assess, or size — it executes what the upstream chain has authorized.

**What belongs here:**
- `core_trade_engine.mqh` — stop geometry, entry/exit mechanics, trade state management
- `council_mode_runtime.mqh` — final decision routing (accept → execute, reject → log, wait → hold)
- MT5 broker connection, order submission, fill handling
- Entry price adjustment for spread/slippage (currently embedded in Nautilus cost model and trade engine)
- Future: execution quality tracking (fill slippage vs modeled cost)

**What Execution must not do:**
- Execution must not modify alpha. If the entry condition is not met, execution stops — it does not substitute a different signal.
- Execution must not override Risk gates. A REJECT from the pre-AI filter is final for that bar.
- Execution authority belongs exclusively to MT5. Nautilus must never become an execution authority under any circumstances, including emergency conditions.
- Stop geometry changes require a separate bounded design plan (currently deferred — see §18.8).

**MT5 authority is permanent and non-negotiable.** Nautilus cannot be granted execution authority. This is a hard constraint with no exception path.

**Current system anchor:** `core_trade_engine.mqh`, `council_mode_runtime.mqh` (final routing), MT5 broker connection.

---

#### Layer 5 — Attribution

**What it is:**
The layer that measures what actually happened after decisions were made, and why. Attribution closes the loop between thesis and outcome. It does not execute, authorize, or veto — it observes, records, and provides the evidence base for future offline review.

**What belongs here:**
- `ai_opportunity_ledger.jsonl` — per-trigger decision record including suppression reasons (Phase 2, active)
- `ai_opportunity_summary.json` — per-session aggregate counters
- `ai_strategy_memory.json` — per-strategy win/loss/confidence history
- `ai_performance_journal.jsonl` — closed trade attribution with MAE/MFE
- Nautilus replay outputs — external attribution comparison (not runtime authority)
- `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` — architecture memory and evidence registry (this file)
- Future: Thesis Ledger (evolved form of Opportunity Ledger; see §20.10)
- Future: post-trade attribution tags linking closed trades to originating thesis

**What Attribution must not do:**
- Attribution findings do not self-authorize changes. Evidence → offline review → operator authorization → bounded Codex task → source change.
- Attribution must not influence runtime decisions directly. A strategy's historical WR does not adjust its behavior within the same session without an operator-authorized source update.
- Attribution is not a feedback loop without the operator. The system does not self-modify.

**Current system anchor:** Opportunity Ledger (`ai_opportunity_ledger.jsonl`), strategy memory (`ai_strategy_memory.json`), performance journal (`ai_performance_journal.jsonl`), Nautilus certification artifacts, PIML.

---

### 20.3 Mapping of Current System Components to Doctrine Layers

| Component | Primary Layer | Secondary Layer | Notes |
|---|---|---|---|
| `council_strategies.mqh` | Alpha / Thesis | — | Vote weight fields are Allocation artifacts embedded here; eventual separation warranted |
| `strategy_runtime.mqh` | Alpha / Thesis | — | Trigger primitives; produces thesis signals only |
| `council_environment.mqh` | Alpha context | Risk context | Zone, CEIS, structure — provides environment to both Alpha and Risk consumers |
| `council_aggregator.mqh` | — | Pre-Allocation decision support | Aggregates thesis votes into consensus; serves as input to Allocation and Risk judgement |
| `council_pre_ai_filter.mqh` | Risk | — | Primary gate layer: DSN, CRR, DOMINANT_SIDE; quality floor when activated |
| `council_ai_governor.mqh` | Risk (advisory) | — | Adjusts thresholds based on environment; advisory only; not hard-blocking currently |
| `council_mode_runtime.mqh` | Orchestration | — | Crosses all layers; not a single-layer component — this is the integration surface |
| `council_memory.mqh` | Attribution | — | Historical pattern summaries feeding council context |
| `council_failure_detector.mqh` | Risk | Attribution | Failure pattern detection; Risk-relevant context |
| `council_feedback.mqh` | Attribution | Risk | Feedback signals; post-bar retrospective |
| `core_trade_engine.mqh` | Execution | — | Stop geometry, order mechanics; must not be modified without separate design plan |
| `risk_state_policy_engine.mqh` | Risk | — | Runtime risk authority |
| `runtime_governance_status.json` | Risk | — | Runtime risk/authority truth file |
| `ai_opportunity_ledger.jsonl` | Attribution | — | Phase 2 active; per-trigger decision record |
| `ai_opportunity_summary.json` | Attribution | — | Per-session aggregate counters |
| `ai_strategy_memory.json` | Attribution | — | Per-strategy W/L/confidence history |
| `ai_performance_journal.jsonl` | Attribution | — | Closed trade MAE/MFE attribution |
| Nautilus lab (all scripts/outputs) | Alpha / Thesis (research) | Attribution (comparison) | Evidence/replay only; never runtime authority |
| `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | Architecture memory | Governance documentation | This file |

**Components that span multiple layers (deliberate design):**

`council_environment.mqh` feeds both Alpha (regime context for strategy signals) and Risk (zone gating). This boundary is intentional and acceptable — environment is not a layer itself, it is shared infrastructure.

`council_mode_runtime.mqh` is the orchestration surface. It invokes Alpha (strategy set), feeds Risk (filter), routes to Execution (final decision), and writes Attribution (ledger). It is not a monolithic layer — it is the integration pipeline. Future IRREW evolution should preserve this separation within the orchestration surface rather than collapsing layers.

`council_aggregator.mqh` sits at the boundary of Alpha aggregation and pre-Allocation decision support. The consensus score and diversity metrics it produces are inputs to both the Risk gate (quality floor, diversity gate) and the Allocation layer (weight-aggregated vote). This dual role is currently managed by a single pass and is architecturally sound given the system's size.

---

### 20.4 IRREW Reinterpretation Under Institutional Separation

IRREW (Institutional Role Rights with Evidence-Calibrated Weighting) remains valid. The institutional separation doctrine does not replace IRREW — it provides the interpretive framework that IRREW must be consistent with as it is implemented.

**Language correction — terminology alignment:**

| IRREW term (current) | Doctrine-preferred term | Reason |
|---|---|---|
| Primary Executor | Trade Thesis Source / Primary Thesis Originator | A strategy does not execute — it originates a thesis |
| CONFIRM role strategy | Thesis Support / Confirmation Evidence Provider | Confirmation is evidence diversity, not obedience to a leader |
| EXHAUSTION_JUDGE veto | Risk Invalidation Signal / Thesis Exhaustion Flag | Veto is a Risk determination, not a strategy vote against another |
| vote_weight | Allocation Weight / Evidence-Calibrated Allocation | Weight is an allocation decision, not a measure of alpha authority |
| OBSERVE_ONLY | Risk-Attenuated Thesis Contribution | Strategy contributes at reduced weight due to regime unsuitability (risk context) |
| BLOCKED / [FROZEN] | Allocation-Suspended / Risk-Suspended | Depending on reason: FROZEN is allocation suspension; hostile-regime block is risk suspension |

These terminology corrections are recommendations for future documentation. They do not change any current code, constant, enum value, or source identifier. Existing code identifiers (`CONFIRM`, `TREND_JUDGE`, `vote_weight`, etc.) are unchanged.

**IRREW principle restatements under doctrine:**

*Original IRREW:* "A strategy leads the trade."
*Doctrine-consistent restatement:* "A strategy originates the highest-confidence thesis for this bar. The Central Decision Layer determines whether that thesis clears Risk, deserves Allocation, and is eligible for Execution."

*Original IRREW:* "A CONFIRM strategy confirms the leader."
*Doctrine-consistent restatement:* "A strategy in the CONFIRM role provides independent family evidence that supports the thesis. This evidence increases thesis confidence (diversity). It does not confirm a leader — it reduces the probability that the thesis is a single-family artifact."

*Original IRREW:* "An EXHAUSTION_JUDGE vetoes a trade."
*Doctrine-consistent restatement:* "An EXHAUSTION_JUDGE produces a Risk Invalidation Signal. If signal strength is sufficient and conditions are met (Phase 4B, not yet implemented), the Risk layer rejects the thesis on exhaustion grounds — not because of a competing vote, but because the thesis context is invalidated."

*Original IRREW:* "Weights reflect strategy quality."
*Doctrine-consistent restatement:* "Weights reflect current Allocation belief — how much capital contribution is warranted given current evidence. Weights are not proof of alpha. Evidence-Earned Weight Progression (Phase 6) is the mechanism for updating Allocation belief from Attribution evidence."

**CRR restatement:**
The Confirmation Role Requirement gate is a Risk rule: before a thesis proceeds to Execution, it must have independently-derived supporting evidence from a different strategy family. This prevents execution on single-family thesis artifacts (where one strategy's signal is the only support). Under the doctrine, CRR is a Risk gate, not an Alpha requirement.

**Consensus score restatement:**
Consensus (from `council_aggregator.mqh`) is pre-Allocation signal strength aggregation. A HIGH_CONVICTION consensus is strong input to Allocation and Risk — it does not force Execution. Consensus informs the decision chain; it does not conclude it.

---

### 20.5 Implications for Current trend_momentum Findings

Under institutional separation, the Nautilus A/B/C certification results update **Alpha / Thesis evidence only**.

| Finding | Layer Updated | Action Authorized |
|---|---|---|
| trend_momentum overall: EDGE_WEAK_BUT_RECOVERABLE | Alpha / Thesis | None beyond documentation |
| M5_CONFLICT WR=19.88% — TOXIC | Alpha / Thesis | Evidence only; future Risk gate design (not implemented) |
| M5_CONFLICT exclusion recovery path confirmed | Alpha / Thesis | Evidence only; not a current Risk gate |
| RANGE_NEUTRAL+SELL: EDGE_SUPPORTED (WR=44.37%) | Alpha / Thesis | Evidence only; not Allocation or Execution change |
| TREND_UP+BUY: EDGE_NOT_CONFIRMED (WR=39.34%) | Alpha / Thesis | Evidence only; not a BUY disable; Variant D required first |
| SELL asymmetry consistent across all variants | Alpha / Thesis | Evidence only; direction asymmetry does not authorize direction gate yet |
| TSMOM LB12 proxy competitive with Variant B | Alpha / Thesis (external) | Research candidate only; not an implementation signal |

trend_momentum is an **Alpha / Thesis source** operating in the TREND_JUDGE role in TC and BREAKOUT zones. It originates trend-continuation theses. It does not control Risk gates, Allocation weights, or Execution routing. Changes to any of those layers require separate, bounded, operator-authorized tasks regardless of Alpha evidence.

---

### 20.6 External Candidate Entry Protocol Under Doctrine

All external candidates — regardless of how well-documented the underlying academic edge — must enter through the **Alpha / Thesis research queue** only. They must not bypass any layer review before reaching Architecture consideration.

**Current external candidate queue:**
1. SHORT_HORIZON_TSMOM_PROXY_LB12 (SSRN, AQR — see §19.7)
2. CLASSICAL_TSMOM_H1_D1_LAYER (Moskowitz/Ooi/Pedersen 2012, JFE)
3. Trendline Playbook H4 candidate — not yet researched
4. Opening Range Breakout candidate — not yet researched
5. Session momentum/reversal candidates — not yet researched

**Required entry stages before Architecture consideration (all stages mandatory, in order):**

| Stage | Gate | Who owns it |
|---|---|---|
| 1. Codability check | Can the signal be faithfully represented in MQL5 within the IRREW role framework? | Architecture review |
| 2. System-fit review | Does it fit an existing or needed role? (Alpha/Thesis layer only) | Architecture review |
| 3. Nautilus certification | Source-faithful replay on XAUUSD M1/M5 (or appropriate timeframe); min N=20; all required variants | Nautilus Phase 3 pipeline |
| 4. Opportunity Ledger comparison | How does it compare to current council decisions? Does it add independent evidence or duplicate? | Post-Phase 2 audit |
| 5. RCEM / role interpretation | Which zone? Which role? Which family? Does it satisfy or create CRR coverage? | Architecture review |
| 6. Risk review | Does enabling it create regime hostility, TC execution collapse, or veto miscalibration? | Architecture review |
| 7. Operator authorization | Written authorization for bounded Codex implementation task | Operator |

No candidate may skip stages. Strong academic evidence (stage 1 cleared) does not imply system fit (stage 2), reliable replication (stage 3), or absence of runtime risk (stage 6).

---

### 20.7 Provisional Thesis-Centric Evidence Model

The following fields represent the future state of a thesis-centric evidence record. They are **design concepts only** — not current runtime fields, not current Opportunity Ledger fields, not implemented anywhere.

These are provisional because the system is not yet ready for thesis-centric execution (see §20.9). They are documented now so future architecture work has a coherent target.

```
Future thesis evidence record fields (DESIGN_CONCEPT_ONLY):

thesis_id              — unique ID per evaluated thesis (bar + primary source + direction)
thesis_type            — TREND_CONTINUATION | REVERSAL | RANGE_FADE | BREAKOUT | etc.
thesis_direction       — BUY | SELL | NONE
source_strategy_ids    — list of strategies contributing to this thesis
supporting_families    — families providing evidence FOR the thesis
opposing_families      — families providing evidence AGAINST (not just absent)
regime_label           — TREND_UP | TREND_DOWN | RANGE_NEUTRAL | etc.
zone_type              — TC | RMR | REV | BREAKOUT | etc.
evidence_for           — aggregated evidence score supporting the thesis
evidence_against       — aggregated evidence score opposing the thesis
risk_flags             — list of active risk flags at thesis time
veto_flags             — list of active veto signals (Risk layer invalidations)
allocation_candidate   — boolean: passed Risk, eligible for Allocation decision
execution_permission   — boolean: Allocation approved, cleared for Execution
final_decision         — EXECUTE | REJECT | WAIT | VETO_BLOCKED | QUALITY_GATED
attribution_result     — WIN | LOSS | OPEN | SUPPRESSED_CORRECTLY | etc.
```

Relationship to current Opportunity Ledger:
The current Opportunity Ledger (§18 / Phase 2) is a **per-strategy per-trigger** record. The thesis-centric model would be a **per-bar per-thesis** record that aggregates multiple strategy inputs into a single thesis conclusion. Evolution from strategy-ledger to thesis-ledger is a future Phase design question, not a current task.

---

### 20.8 Hard Governance Rules Under Doctrine

These rules are binding under the institutional separation doctrine. They apply to all future design, review, implementation, and Codex tasks regardless of context.

| Rule | Statement |
|---|---|
| G-1 | Alpha / Thesis layer never directly executes. Signal generation and execution authorization are separate acts separated by Risk and Allocation layers. |
| G-2 | Risk may block but must not invent alpha. A suppressed thesis requires a new Alpha input on the next bar — Risk does not substitute a different signal. |
| G-3 | Allocation may size or prioritize only after evidence. No weight increase without operator-authorized Nautilus certification + live sample. |
| G-4 | Execution may only execute after MT5 authority permits. Nautilus never becomes execution authority. This constraint has no exception path. |
| G-5 | Attribution informs future decisions only through: (1) offline review, (2) operator analysis, (3) explicit operator authorization, (4) bounded Codex task. No self-modification. |
| G-6 | Runtime Truth (`runtime_governance_status.json`) is the sole operational authority for current system state. It cannot be overwritten by Nautilus outputs or external research conclusions. |
| G-7 | External Research Evidence (Nautilus outputs, academic literature) informs Alpha / Thesis layer only. It does not directly update Risk gates, Allocation weights, or Execution behavior. |
| G-8 | Status Truth (system status, phase states, production readiness) is set by operator authorization only. It cannot be claimed by performance metrics alone. |
| G-9 | Evidence Truth (WR, expectancy, MAE/MFE) must be time-bounded and source-bounded. No metric is context-free. Every claim must state its denominator, date range, and data source. |
| G-10 | Layer leakage — where one layer begins performing another layer's function — must be flagged in architecture review. Examples: a strategy that controls its own stop geometry (Alpha invading Execution), a gate that varies by strategy performance (Risk incorporating Allocation logic), a weight change triggered automatically by runtime WR (Attribution directly driving Allocation). |

---

### 20.9 What This Decision Does Not Authorize

The following are explicitly forbidden as a direct consequence of this doctrine adoption:

| Item | Status |
|---|---|
| MT5 source patch of any kind | FORBIDDEN |
| Thesis engine implementation in MT5 | FORBIDDEN — design-only concept |
| M5 hard alignment gate in MT5 | FORBIDDEN — requires Phase 4A prerequisites |
| BUY direction disable for trend_momentum | FORBIDDEN — Variant D not yet run; asymmetry not structural-confirmed |
| Any strategy replacement or substitution | FORBIDDEN — factory admission locked |
| Vote weight change for any strategy | FORBIDDEN — Phase 6 prerequisites unmet |
| RCEM enforcement activation in source | FORBIDDEN — Phase 4 prerequisites unmet |
| Phase 4A cross-family CRR implementation | FORBIDDEN — TPC 0 live triggers |
| Phase 4B exhaustion veto implementation | FORBIDDEN — MFI 0 live entries |
| Phase 4C quality soft gate reactivation | FORBIDDEN — Ledger < 200 records |
| Nautilus as MT5 runtime data source | FORBIDDEN — permanent constraint |
| Automatic weight adjustment by runtime WR | FORBIDDEN — Attribution-to-Allocation feedback requires operator gate |
| Production readiness claim | FORBIDDEN — system status is DEVELOPING |
| Automatic promotion or demotion of any strategy | FORBIDDEN — operator authorization required |

---

### 20.10 Open Architecture Questions

These questions are raised by the doctrine adoption. They are not answered here — they are documented for future architecture sessions.

| Question | Layer(s) Involved | Priority |
|---|---|---|
| Should future IRREW evolve to be fully thesis-centric (one thesis record per bar) rather than one strategy record per strategy? | Alpha, Attribution | MEDIUM |
| Should the Opportunity Ledger evolve into a Thesis Ledger — recording the collective thesis evidence rather than individual strategy triggers? | Attribution | MEDIUM |
| How should `evidence_for` and `evidence_against` be scored — by family diversity, confidence sum, or something else? | Alpha → Attribution | OPEN |
| How should Risk veto differ structurally from Alpha disagreement? Current system has no veto path (Phase 4B blocked). When Phase 4B is enabled, how does an EXHAUSTION_JUDGE risk invalidation get recorded separately from a conflicting strategy vote? | Risk, Attribution | HIGH (Phase 4B prerequisite) |
| How should Portfolio / Allocation weights be earned — what is the minimum evidence standard before an EEWP adjustment is authorized? Current design requires Phase 2+3+4 completion but the formula is not finalized. | Allocation | MEDIUM |
| How should external candidates enter the system without causing feature sprawl — is there a council size limit, a family diversity limit, or a minimum certified-WR admission bar? | Alpha, Architecture governance | LOW |
| How should the system detect and prevent layer leakage — where a function in one layer begins performing another layer's role? Should PIML track known leakage points explicitly? | Architecture governance | LOW |
| Should `council_mode_runtime.mqh` be refactored to explicitly label each stage by doctrine layer? | Orchestration | DEFERRED |

---

### 20.11 Recommended Next Action

**This doctrine is now the architecture review lens. It is not the next implementation target.**

The recommended sequencing from this doctrine adoption is unchanged from what was already planned. The doctrine does not introduce new urgency or new work items — it provides the interpretive framework for work already in progress.

| Priority | Action | Doctrine Layer | Blocking Condition |
|---|---|---|---|
| 1 | Run trend_momentum Variant D (BUY overextension / session analysis) | Alpha / Thesis | None — existing trade set in Nautilus lab |
| 2 | Continue Opportunity Ledger accumulation | Attribution | Ongoing — monitoring only |
| 3 | Continue Phase 3 Nautilus certification pipeline (sweep_reversal next) | Alpha / Thesis | None — data available |
| 4 | Export XAUUSD D1 from MetaEditor for future TSMOM H1/D1 candidate | Alpha / Thesis (external) | Operator action |
| 5 | Monitor TPC live fire rate (Phase 4A prerequisite) | Risk (future) | TPC must reach ≥5 distinct triggers before Phase 4A design |
| 6 | Monitor MFI first signal strength readings (Phase 4B prerequisite) | Risk (future) | MFI must reach ≥5 readings before Phase 4B design |
| DEFERRED | Phase 4A/4B/4C implementation | Risk | All three BLOCKED — conditions unchanged |
| DEFERRED | EEWP / Phase 6 Allocation design | Allocation | Phase 2+3+4 prerequisites unmet |
| DEFERRED | Thesis Ledger evolution | Attribution | Requires Phase 2 maturity + operator design session |
| DEFERRED | IRREW terminology refresh in source code | Architecture | Deferred until Phase 4 implementation — no current source change |

**Do not implement the institutional separation doctrine as software.** The value of the doctrine today is as a review lens: use it to classify proposed changes before authorizing them, to detect layer leakage in design proposals, and to frame attribution evidence correctly before drawing implementation conclusions.

---

### 20.12 Footer

```
SECTION_ID:                      INSTITUTIONAL_SEPARATION_DOCTRINE_V1
SECTION_TYPE:                    ARCHITECTURE_DOCTRINE — DOCUMENTATION_ONLY
DECISION_DATE:                   2026-05-07
DECISION_AUTHORITY:              Management (operator)
PIML_BACKUP:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_131037
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
MT5_AUTHORITY:                   PRESERVED — sole runtime authority, permanent constraint
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY — permanent constraint
SYSTEM_STATUS:                   DEVELOPING — unchanged
DOCTRINE_STATUS:                 ADOPTED — review lens only, not implementation target
IMPLEMENTATION_STATUS:           DEFERRED — no phase or timeline assigned
LAYERS_DEFINED:                  Alpha/Thesis | Risk | Allocation | Execution | Attribution
COMPONENTS_MAPPED:               YES — see §20.3
IRREW_REINTERPRETED:             YES — see §20.4 (IRREW remains valid under doctrine)
PHASE_4A_STATUS:                 BLOCKED (unchanged — TPC 0 triggers)
PHASE_4B_STATUS:                 BLOCKED (unchanged — MFI 0 triggers)
PHASE_4C_STATUS:                 BLOCKED (unchanged — Ledger < 200 records)
NEXT_AUTHORIZED_ACTION:          Variant D + Phase 3 continuation + Ledger accumulation
```

---

## 21. VARIANT_D_AND_LAYER_COHERENCE_V1 — trend_momentum Overextension, Regime-Function, and Layer Leakage Review

---

### 21.1 Adoption Status

This section is evidence and documentation only. It does not authorize any MT5 source change, gate implementation, RCEM enforcement, weight adjustment, execution change, strategy replacement, or claim of production readiness. It does not authorize any change to Nautilus lab artifacts, scripts, or configuration files.

System status remains: **DEVELOPING**

MT5 remains sole runtime authority. Nautilus remains evidence/replay/certification lab only. All phase gates and blockers from Sections 16–20 remain in force unchanged.

---

### 21.2 Variant D Executive Verdict

**Analysis target:** TREND_UP+BUY bucket from the trend_momentum Variant C trade set.

**Source data:** Variant C closed trades, bucket = TREND_UP_BUY, N = 2,659. No MT5 source modification. No new Nautilus replay. Post-hoc analysis of existing certified trade set.

**Baseline:**

| Metric | Value |
|---|---|
| N | 2,659 |
| WR | 39.34% |
| E[R] | -0.017R |
| Profit factor | 0.9727 |
| Breakeven threshold (RR=1.50) | 40.00% |
| Practical threshold | 42.40% |
| Certification label | EDGE_WEAK_BUT_RECOVERABLE |

**Root cause verdict: `PARTIAL_RECOVERY_INSUFFICIENT_FOR_GATE_DECISION`**

Neither overextension ratio nor session timing explains the underperformance with sufficient consistency to form an operationally viable gate. Partial pockets of edge exist in the cross-cell (OXT × session) matrix, but they are heterogeneous and do not dominate the distribution. TREND_UP+BUY remains EDGE_WEAK_BUT_RECOVERABLE — it is not EDGE_REJECTED. The not_late guard (ATR×1.20 cap) is functioning correctly. No source change is warranted by this analysis.

---

### 21.3 Overextension Findings

**Overextension definition:** `overextension_ratio = (raw_entry - EMA20_M1_at_trigger) / ATR14_M1_at_trigger`

This captures how far the M1 entry price is above the M1 EMA20 anchor at trigger time, normalized by M1 ATR14. The not_late guard limits entries to approximately [0.00, 1.20]; the empirical distribution shows median = 0.626, p75 = 0.931 — confirming the guard is active on the bulk of the distribution.

**Overextension bucket analysis:**

| Bucket | N | WR | E[R] | PF | Clears BE | Clears PRC | Label |
|---|---|---|---|---|---|---|---|
| 0.00–0.25 | 590 | 42.03% | +0.051R | 1.088 | YES | NO | EDGE_WEAK_BUT_RECOVERABLE |
| 0.25–0.50 | 495 | 37.17% | -0.071R | 0.888 | NO | NO | EDGE_NOT_CONFIRMED |
| 0.50–0.75 | 475 | 37.68% | -0.058R | 0.907 | NO | NO | EDGE_NOT_CONFIRMED |
| 0.75–1.00 | 594 | 39.90% | -0.003R | 0.996 | NO | NO | EDGE_WEAK_BUT_RECOVERABLE |
| 1.00–1.20 | 500 | 39.20% | -0.020R | 0.967 | NO | NO | EDGE_WEAK_BUT_RECOVERABLE |
| >1.20 | 4 | 25.00% | -0.375R | 0.500 | NO | NO | DATA_INSUFFICIENT |

**Key observations:**

- The OXT–WR relationship is **non-monotonic**: the 0.00–0.25 bucket is the strongest, but the 0.75–1.00 range recovers relative to the 0.25–0.75 trough. No clean directional rule applies.
- The 0.50–0.75 bucket shows max_consec_losses = 18 and avg_mae_r = 1.051 — the only bucket where average adverse excursion exceeds 1R. Trades entering mid-range face disproportionate adverse pressure.
- Low-OXT aggregate filter (< 0.50 ATR, N = 1,086): WR = 39.87%, E[R] = -0.003R — marginally better than baseline but does not clear the 40% breakeven.
- The best overextension bucket (0.00–0.25) clears 40% breakeven but does not clear the 42.4% practical threshold.
- **The not_late guard should not be changed from this evidence.** The guard is correctly bounding the OXT distribution and is not the source of TREND_UP+BUY underperformance.

---

### 21.4 Session Findings

Session split defined for this analysis as 8-hour UTC blocks: Asia (00–08), London (08–16), NewYork (16–00).

| Session | N | WR | E[R] | Avg OXT | Label |
|---|---|---|---|---|---|
| Asia (00–08) | 939 | 38.98% | -0.026R | 0.625 | EDGE_WEAK_BUT_RECOVERABLE |
| London (08–16) | 879 | 39.02% | -0.025R | 0.607 | EDGE_WEAK_BUT_RECOVERABLE |
| NewYork (16–00) | 841 | 40.07% | +0.002R | 0.622 | EDGE_WEAK_BUT_RECOVERABLE |

Session spread: 1.09pp (NY vs Asia). The verdict logic threshold for session-driven classification was not met (spread < 2pp). Session timing does not explain the TREND_UP+BUY weakness.

**MT5 EA actual session subset** (using council_environment.mqh hours: London 09–13 UTC, NY 15–18 UTC):

| MT5 Session | N | WR | E[R] | Label |
|---|---|---|---|---|
| London_Core (09–12 UTC) | 445 | 38.88% | -0.028R | EDGE_WEAK_BUT_RECOVERABLE |
| NY_Core (15–17 UTC) | 387 | 37.98% | -0.050R | EDGE_NOT_CONFIRMED |
| Off_Session | 1,827 | 39.74% | -0.007R | EDGE_WEAK_BUT_RECOVERABLE |

The MT5 EA's designated core trading hours (London_Core and NY_Core) are not superior for TREND_UP+BUY. NY_Core is the weakest MT5 subset (EDGE_NOT_CONFIRMED). Do not infer from this single strategy-specific finding that session scoring in council_environment.mqh should be altered. Session scoring serves environmental context for all 17 strategies and is not calibrated to trend_momentum direction × regime performance specifically.

---

### 21.5 Cross-Cell Findings

Overextension × session cross-matrix (15 primary cells, 3 sessions × 5 OXT buckets):

| Session | OXT Bucket | N | WR | E[R] | Label |
|---|---|---|---|---|---|
| Asia | 0.00–0.25 | 210 | 39.05% | -0.024R | EDGE_WEAK_BUT_RECOVERABLE |
| Asia | 0.25–0.50 | 177 | 38.42% | -0.040R | EDGE_WEAK_BUT_RECOVERABLE |
| Asia | 0.50–0.75 | 152 | **28.29%** | **-0.293R** | **EDGE_REJECTED** |
| Asia | 0.75–1.00 | 230 | **43.48%** | **+0.087R** | **EDGE_SUPPORTED** |
| Asia | 1.00–1.20 | 167 | **43.11%** | **+0.078R** | **EDGE_SUPPORTED** |
| London | 0.00–0.25 | 198 | **43.94%** | **+0.099R** | **EDGE_SUPPORTED** |
| London | 0.25–0.50 | 170 | 35.88% | -0.103R | EDGE_NOT_CONFIRMED |
| London | 0.50–0.75 | 166 | 39.76% | -0.006R | EDGE_WEAK_BUT_RECOVERABLE |
| London | 0.75–1.00 | 178 | 38.20% | -0.045R | EDGE_WEAK_BUT_RECOVERABLE |
| London | 1.00–1.20 | 167 | 36.53% | -0.087R | EDGE_NOT_CONFIRMED |
| NewYork | 0.00–0.25 | 182 | **43.41%** | **+0.085R** | **EDGE_SUPPORTED** |
| NewYork | 0.25–0.50 | 148 | 37.16% | -0.071R | EDGE_NOT_CONFIRMED |
| NewYork | 0.50–0.75 | 157 | **44.59%** | **+0.115R** | **EDGE_SUPPORTED** |
| NewYork | 0.75–1.00 | 186 | 37.10% | -0.073R | EDGE_NOT_CONFIRMED |
| NewYork | 1.00–1.20 | 166 | 37.95% | -0.051R | EDGE_NOT_CONFIRMED |

**5 of 15 cells are EDGE_SUPPORTED.** 1 cell is EDGE_REJECTED (Asia × 0.50–0.75, WR = 28.29%, N = 152).

**Critical observation:** The EDGE_SUPPORTED cells are not clustered around a single session or a single OXT range. London succeeds at low OXT; Asia succeeds at high OXT; NewYork succeeds at two non-adjacent OXT buckets. No operationally viable combined gate exists. Any combination filter would select small N with no cross-session or cross-OXT stability guarantee.

**Asia × 0.50–0.75 (EDGE_REJECTED):** This cell has WR = 28.29%, max_consec_losses = 17, avg_mae_r = 1.12. It is the most harmful sub-condition in the TREND_UP+BUY dataset. However, with N = 152, this finding requires fresh-data replication on a new dataset before any gate inference is drawn. Do not act on this cell in isolation.

---

### 21.6 RCEM Design Intent Update

This subsection records the design-intent regime-conditioned eligibility classification for trend_momentum based on the full A–D certification evidence base. This is documentation only. It is not runtime enforcement. It does not modify council_strategies.mqh, council_mode_runtime.mqh, or any other source file.

**Certification evidence base:** Variant A (unrestricted), Variant B (M5 hostile-regime excluded), Variant C (direction × regime buckets), Variant D (OXT × session sub-analysis of TREND_UP+BUY).

**Proposed RCEM design intent — trend_momentum:**

| Regime × Direction | Variant C Label | Variant D Insight | RCEM Design Intent |
|---|---|---|---|
| TREND_DOWN + SELL | EDGE_SUPPORTED (WR=41.55%, E[R]=+0.039R) | — | ACTIVE (positive expectancy, regime-aligned) |
| RANGE_NEUTRAL + SELL | **EDGE_SUPPORTED** (WR=44.37%, E[R]=+0.109R) | — | ACTIVE (strongest bucket, highest priority) |
| RANGE_NEUTRAL + BUY | EDGE_WEAK_BUT_RECOVERABLE (WR=40.76%, E[R]=+0.019R) | — | ACTIVE_REDUCED (positive expectancy; not EDGE_SUPPORTED yet) |
| TREND_UP + BUY | EDGE_WEAK_BUT_RECOVERABLE (WR=39.34%, E[R]=-0.017R) | PARTIAL_RECOVERY verdict; 5 EDGE_SUPPORTED cross-cells | **REDUCED** (not BLOCKED; partial edge confirmed) |

**RCEM intent: TREND_UP+BUY → REDUCED, not BLOCKED.**

The presence of five EDGE_SUPPORTED cross-cells within TREND_UP+BUY confirms the regime is not uniformly toxic. A BLOCKED classification would be unwarranted. REDUCED is the appropriate design intent: acknowledge the negative aggregate expectancy while preserving access to the sub-conditions where edge exists.

This design intent will be encoded in PIML Phase 1 RCEM notation when authorized. No source enforcement today.

---

### 21.7 Layer-Coherence Executive Verdict

The Institutional Separation Doctrine (Section 20) has been applied as a review lens to the current MT5 system. The verdict:

**The current system is functionally coherent enough to continue development under DEVELOPING status.** The council pipeline correctly routes market signals through Alpha → aggregation → Risk gates → execution, and has done so for 152+ live executions. The five-layer doctrine is not broken — it is incompletely implemented.

Seven layer-leakage or design-debt risks are identified and documented below. None of these is an operational failure. None justifies an immediate source patch. They are architectural debts to be addressed in order as the phase roadmap progresses.

**Layer 5 Attribution status:** The Opportunity Ledger (Phase 2) is **active**. `ai_opportunity_ledger.jsonl` and `ai_opportunity_summary.json` exist and are receiving records. Stage 18.5 is confirmed live. However, the ledger record count is currently low and evidence volume is **immature** — insufficient to support Phase 4C (quality soft gate), FSW audit, or EEWP weight decisions. The Attribution layer is active but its evidence base has not yet reached the threshold required for downstream decisions. This is a data-maturity gap, not an architectural absence.

---

### 21.8 Layer Leakage Risks

Seven leakage mechanisms identified from source-verified inspection of council_aggregator.mqh, council_pre_ai_filter.mqh, council_environment.mqh, council_mode_types.mqh, and council_strategies.mqh.

---

**Risk 1 — V1 FSW Alpha→Allocation Circularity**

| Field | Detail |
|---|---|
| Layer issue | The V1 Family Soft Weight (FSW) system in council_aggregator.mqh adjusts effective strategy weights based on the current bar's Alpha signal family composition. The Allocation weight (Layer 3) is therefore partly determined by the real-time Alpha vote mix (Layer 1), creating a circular dependency within a single aggregation pass. |
| Trading risk | A family that dominates the current council bar receives FSW amplification — the stronger the Alpha signal, the larger its Allocation weight. This may overweight momentum-dominant signals in TC zone precisely when caution is warranted. |
| Current status | Active in aggregator. Not causing verified harm but not evidence-calibrated. |
| Mitigation timing | Phase 2 maturity + Phase 6 (EEWP) design. Requires Opportunity Ledger evidence to audit FSW contribution empirically. No change until audit complete. |

---

**Risk 2 — HIGH_CONVICTION Exemption Bypasses Risk Layer**

| Field | Detail |
|---|---|
| Layer issue | When council_aggregator computes consensus_type = HIGH_CONVICTION, council_pre_ai_filter exempts both the DSN gate (family diversity <0.30) and the CRR gate (confirm role absent). The Layer 3 Allocation output (consensus_type) is silencing Layer 2 Risk gates. Risk should be able to evaluate any trade regardless of consensus strength. |
| Trading risk | A strongly coordinated but regime-hostile signal can bypass structural diversity and confirmation checks, executing a trade the Risk layer would otherwise reject. |
| Current status | Active in pre_ai_filter (source-verified). HIGH_CONVICTION threshold is high (≥0.75 consensus, familyCount≥2, etc.) so this fires rarely in practice. |
| Mitigation timing | Phase 4 design review. Not changed now. Do not remove or alter the exemption until Phase 4 design is complete and Phase 2 evidence is available to characterize how often HIGH_CONVICTION trades would have failed DSN/CRR checks. |

---

**Risk 3 — Zone Triple-Duty Across Three Layers**

| Field | Detail |
|---|---|
| Layer issue | Zone type (from council_environment.mqh) currently serves three distinct architectural roles: (1) Layer 1 Alpha context — determines strategy ACTIVE/OBSERVE_ONLY/BLOCKED eligibility; (2) Layer 2 Risk filter — BREAKOUT_EXPANSION zone exempts CRR gate; (3) Layer 3 Allocation quality — zone_alignment contributes 10% to council_quality formula. A single variable performing three layer roles without explicit handoffs creates opacity in diagnosis. |
| Trading risk | If zone classification is wrong (e.g., misclassifies a RANGE bar as BREAKOUT), the error simultaneously misconfigures Alpha eligibility, removes a Risk gate, and inflates quality. The error propagates across all three layers in one classification decision. |
| Current status | Active architecture — not a new risk but not yet explicitly managed as doctrine. |
| Mitigation timing | Document as known layering debt. Refactor toward explicit handoffs during Phase 4 design. No runtime change. |

---

**Risk 4 — council_quality Is a Cross-Layer Composite**

| Field | Detail |
|---|---|
| Layer issue | The council_quality formula blends signals from Layer 1 (bestScore, adjustedConsensus), Layer 2 (exhaustion_warning penalty, confirm_role bonus), and Layer 3 (family_diversity, zone_alignment) into a single score. This composite then influences the HIGH_CONVICTION consensus threshold, the (demoted) score gates, and op-level narrative. |
| Trading risk | When council_quality is low, the reason is opaque: it may reflect Alpha signal weakness, Risk warning, or Allocation diversification failure. Cross-layer composites make root-cause diagnosis ambiguous and make it impossible to re-activate individual components (e.g., quality gate for Phase 4C) without affecting unintended layers. |
| Current status | Score gates currently demoted (pre_ai_score_gates_demoted = true). composite quality is diagnostic only. Leakage risk is latent until score gates are re-activated. |
| Mitigation timing | Phase 4C (quality soft gate reactivation) must be designed with awareness of this composite structure. The gate should specify which component(s) it is testing, not a raw quality threshold. Requires Phase 2 ledger evidence first. |

---

**Risk 5 — OBSERVE_ONLY Strategies Influence Allocation at ×0.15**

| Field | Detail |
|---|---|
| Layer issue | Strategies designated OBSERVE_ONLY (wrong zone) apply weight × 0.15 reduction, not × 0.00. They still contribute to consensus score, family_diversity, and council_quality at reduced influence. The Layer 1 eligibility decision (strategy is wrong zone → OBSERVE_ONLY) is not fully enforced at the Layer 3 Allocation step. |
| Trading risk | A GUARD strategy in the wrong zone that votes NO_TRADE still suppresses consensus at 15% weight. A wrong-zone CONFIRM still contributes to family_diversity — potentially satisfying the DSN gate by diversity it should not contribute. |
| Current status | Active in aggregator (source-verified lines 207–212). |
| Mitigation timing | Requires Opportunity Ledger audit. The ×0.15 multiplier was a deliberate design choice (preserve weak-signal diversity while reducing influence). Before any change, verify whether OBSERVE_ONLY votes are causing demonstrable harm or providing useful dampening. No change until ≥200 ledger records analyzed. |

---

**Risk 6 — Exhaustion Signal in Allocation Layer Instead of Risk Layer**

| Field | Detail |
|---|---|
| Layer issue | mfi_reversal_assist and CEIS exhaustion sub-scores produce exhaustion signals that currently enter as exhaustion_warning penalties in council_quality (Layer 3 Allocation). A signal strong enough to indicate the trade should be blocked is converted into a quality reduction — making the council less confident, not stopped. The doctrine-correct path is exhaustion → Layer 2 Risk veto. |
| Trading risk | An exhaustion signal at 0.60–0.69 strength reduces quality and may shift consensus from HIGH_CONVICTION to NARROW, but does not block execution. A true veto (Layer 2) would block regardless of consensus type. |
| Current status | mfi_reversal_assist has produced 0 live entries to date. Exhaustion signals exist via CEIS but the EXHAUSTION_JUDGE strategy (mfi_reversal_assist) is not yet producing real signal-strength readings. Phase 4B remains BLOCKED. |
| Mitigation timing | Phase 4B design (blocked on MFI ≥5 signal readings). When Phase 4B is eventually designed, the veto path should be a clean Layer 2 block — not a quality penalty modifier. This framing must be established at design time, not implementation time. |

---

**Risk 7 — Regime Not First-Class in Live MT5 Layers**

| Field | Detail |
|---|---|
| Layer issue | Regime (TREND_UP/TREND_DOWN/RANGE_NEUTRAL) is the most operationally significant conditioning variable identified across Variants B, C, and D. However, regime has no discrete first-class representation in any live MT5 layer. Zone is the primary market-structure field; regime is an approximation derived from zone and CEIS signals. Regime-based edge differences (TREND_DOWN_SELL EDGE_SUPPORTED vs TREND_UP_BUY below breakeven) are invisible to Layer 2 Risk gates, Layer 3 Allocation weights, and Layer 4 Execution. |
| Trading risk | The system allocates identical Layer 3 weight and applies identical Layer 2 gates to RANGE_NEUTRAL_SELL (EDGE_SUPPORTED) and TREND_UP_BUY (below breakeven) for the same strategy. This means the system executes trades with meaningfully different expectancy at identical decision weight. |
| Current status | Not a new gap — RCEM design (Phase 1) is the intended resolution. RCEM was deferred because evidence collection (Phase 3) is not yet substantially complete. |
| Mitigation timing | Phase 1 RCEM design-intent documentation (PIML update, documentation only). Phase 6 EEWP for evidence-based weight conditioning. Neither is an immediate source change. |

---

### 21.9 Regime / Zone Role Clarification

The following doctrine clarification applies within the Institutional Separation Doctrine (Section 20):

**Zone → Layer 1 (Alpha/Thesis) with documented handoffs to Layer 2**

Zone describes market structure: which strategies are contextually appropriate for the current environment. Zone eligibility is the primary Layer 1 activation mechanism. Zone-based Layer 2 exemptions (e.g., BREAKOUT_EXPANSION exempt from CRR) are legitimate but must be treated as explicit policy decisions with documented rationale, not implicit byproducts of zone classification. Zone is appropriately read at Layer 1. Its downstream influence on Layer 2 and Layer 3 must be named and intentional.

**Regime → Layer 3 (Allocation) primarily, with optional Layer 2 participation in extreme cases**

Regime describes directional momentum state: which direction has positive expectancy in the current market. Regime is primarily an Allocation-layer signal — it should condition the effective weight assigned to directional votes. It is not a structural Risk signal (Layer 2) except in extreme cases where a regime is verifiably toxic for a specific strategy × direction combination and evidence crosses EDGE_REJECTED threshold (< 35% WR at N ≥ 20). TREND_UP+BUY (WR = 39.34%) does not currently meet the EDGE_REJECTED threshold. It is a REDUCED target, not a blocked target.

**Regime labels are not edge proof by themselves.** A regime label (TREND_UP, TREND_DOWN, RANGE_NEUTRAL) becomes actionable for Allocation or Risk decisions only after strategy-specific evidence confirms the regime's edge relationship for that strategy × direction combination. Nautilus Variants B–D provide this evidence for trend_momentum. The same evidence collection requirement applies to every other strategy before regime conditioning is authorized.

**Zone should not silently serve three layers.** The triple-duty usage of zone (Risk 3 above) is a known debt. Future architecture reviews should aim to make zone's role at each layer explicit rather than emergent.

**No live MT5 runtime change is authorized to implement this clarification.** This is doctrine-level documentation only.

---

### 21.10 Functional Edge Picture

The trend_momentum evidence base (Variants A–D) provides the most complete functional edge picture of any strategy in the council to date.

**What the evidence shows:**

The strategy has real edge in specific regime × direction sub-conditions (RANGE_NEUTRAL_SELL, TREND_DOWN_SELL) and weak-but-not-rejected edge in others (TREND_UP_BUY, RANGE_NEUTRAL_BUY). The edge is not strategy-global — it is bucket-specific. The overall Variant B WR of 41.17% masks a distribution from EDGE_SUPPORTED (44.37% in RANGE_NEUTRAL_SELL) to below-breakeven (39.34% in TREND_UP_BUY).

**What the live system cannot currently distinguish:**

The live MT5 decision layer (Layers 2 and 3) cannot distinguish between a RANGE_NEUTRAL_SELL trade and a TREND_UP_BUY trade from the same strategy. Both receive identical Layer 3 vote_weight (0.95, TREND_JUDGE role), identical Layer 2 gate treatment (no regime-directional block), and identical Layer 4 execution geometry. The 5pp expectancy difference between these buckets is invisible to the live system.

**Where the gap lives:** This is an Allocation (Layer 3) and evidence-feedback (Layer 5 → Layer 3) failure, not an execution-engine failure. The MT5 execution layer (Layer 4: core_trade_engine.mqh, stop geometry, order management) is clean and correctly preserves its sole-authority role. The gap is that the system has no mechanism to assign different effective weights to the same strategy in different regime × direction contexts.

**System trajectory:** The system is progressing from weak-signal collection (early live accumulation) toward evidence-based architecture (RCEM + EEWP design pending Phase 2 maturity and Phase 3 completion). Section 21 marks the point where the evidence base for trend_momentum is substantially complete at the regime × direction level. The remaining work is translating that evidence into Phase 1 RCEM documentation and eventually Phase 6 weight calibration — both requiring further phase prerequisites.

---

### 21.11 council_aggregator.mqh Review Flag

The following review flag is raised for Phase 6 (EEWP) design attention. It does not require immediate action.

**Current architecture:** council_aggregator.mqh sits between the raw strategy reports (Layer 1 Alpha signals) and the pre-AI filter (Layer 2 Risk gates). It performs three functions: (1) weight application and consensus computation (Layer 3 Allocation); (2) family diversity and zone alignment scoring (Layer 3 quality); (3) exhaustion penalty integration (partial Layer 2 Risk leakage via Risk 6 above).

**V1 FSW review requirement:** The V1 Family Soft Weight system must be audited with Opportunity Ledger evidence before EEWP is designed. Specifically: how often does FSW amplify the effective weight of a family that is already dominant in the bar's Alpha signal? Does that amplification correlate with better or worse decision outcomes? This audit requires ≥200 ledger records with per-strategy effective_weight fields captured. The audit cannot be performed until ledger record volume is sufficient.

**vote_weight interpretation:** `vote_weight` in council_strategies.mqh must be treated as an **Allocation belief** — how much capital influence this strategy's signal should have relative to others. It is not an Alpha truth claim — it does not indicate whether the strategy's signal is correct. Treating vote_weight as signal strength (which is the implicit risk in the current static-weight setup) creates false equivalence between high-confidence signals in certified regimes and weak signals in uncertified regimes.

**HIGH_CONVICTION exemption — Phase 4 design review item:** The Layer 3 output (consensus_type = HIGH_CONVICTION) exempting Layer 2 gates is an architectural inversion. During Phase 4 design, the exemption should be reviewed with the following question: should HIGH_CONVICTION relax thresholds within Layer 2 (e.g., CRR requires cross-family confirm in HIGH_CONVICTION context), or eliminate Layer 2 checks entirely? The current behavior is the latter. The correct behavior under doctrine is the former. No change is authorized now.

---

### 21.12 What Must Not Be Implemented

The following changes are **explicitly forbidden** until separately authorized through the phase gate and Codex task process:

| Forbidden action | Reason |
|---|---|
| Overextension gate on TREND_UP+BUY | Root cause verdict: PARTIAL_RECOVERY_INSUFFICIENT — no operationally viable gate exists |
| Session gate on TREND_UP+BUY | Session spread 1.09pp — below actionable threshold |
| M5 hard regime gate for trend_momentum | No RCEM enforcement authorized; Phase 1 design only |
| BUY direction disable in TREND_UP regime | No EDGE_REJECTED verdict; WR 39.34% above EDGE_REJECTED (<35%) threshold |
| RCEM runtime enforcement | Phase 1 is documentation-only; no source encoding authorized |
| FSW modification or removal | Requires Opportunity Ledger audit first; ledger immature |
| OBSERVE_ONLY multiplier change from ×0.15 to ×0.00 | Requires ledger audit; change may harm signal diversity |
| HIGH_CONVICTION exemption modification | Phase 4 design review item; not authorized now |
| Exhaustion veto implementation | Phase 4B BLOCKED — MFI 0 live entries; no threshold calibration basis |
| EEWP weight adjustments | Phase 6 blocked on Phase 2+3+4 completion |
| Strategy replacement of trend_momentum | No evidence supports replacement; EDGE_WEAK_BUT_RECOVERABLE overall |
| Production readiness claim | System status DEVELOPING; criteria not met |
| Any .mq5/.mqh/.ex5/.set source modification | Not authorized by this section |
| Nautilus lab artifact modification | Nautilus is evidence lab only; not runtime authority |

---

### 21.13 Recommended Next Actions

| Priority | Action | Layer | Blocking Condition |
|---|---|---|---|
| 1 | Continue Opportunity Ledger accumulation — ledger is active but evidence volume immature | Attribution (Layer 5) | Ongoing — monitoring only |
| 2 | Use Section 21 as review lens for Phase 4 and Phase 6 design proposals — specifically for layer-leakage risks 1–7 | Architecture governance | None — documentation already complete |
| 3 | Continue Nautilus Phase 3 certification pipeline | Alpha / Thesis | None — data available for next candidates |
| 4 | **Next Nautilus certification target — choose based on strategic priority:** | | |
| 4a | `trend_pullback_cont_v1` — if priority is Phase 4A (cross-family CRR) unblock. TPC is the only cross-family TC confirmer; its certification is prerequisite to Phase 4A design | Alpha / Risk | None — M1/M5 data available |
| 4b | `sweep_reversal` — if priority is REV/RMR evidence base. WEAK_BUT_RECOVERABLE with 35 live executions; additional Nautilus evidence needed | Alpha | None — M1/M5 data available |
| 4c | `bollinger_reclaim` — if priority is resolving Phase 5A/RMR evidence and WR denominator ambiguity. Partial replication exists; needs WR reconciliation and full-data upgrade | Alpha | None — M1/M5 data available |
| 5 | When ledger reaches ≥200 records: initiate FSW audit and Phase 4C (quality soft gate) design review | Allocation / Risk | Phase 2 ledger maturity |
| 6 | Monitor TPC live fire rate for Phase 4A prerequisite (≥5 distinct firings, ≥20% eligible-bar rate) | Risk (future) | TPC must reach threshold before Phase 4A design |
| 7 | Monitor MFI signal strength readings for Phase 4B prerequisite (≥5 readings) | Risk (future) | MFI must reach threshold before Phase 4B design |

**No source patch is authorized from any action in this list.**

---

### 21.14 Evidence Classification Summary

| Claim | Classification |
|---|---|
| Variant D metrics (N=2,659, WR=39.34%, root cause verdict) | **Verified** — computed from closed Variant C trade set, Nautilus lab |
| OXT–WR relationship is non-monotonic in TREND_UP+BUY | **Verified** — 6-bucket analysis; no directional pattern |
| Session timing does not explain TREND_UP+BUY weakness | **Verified / Strongly supported** — 1.09pp spread; session_driven=False by verdict logic |
| Asia × 0.50–0.75 EDGE_REJECTED (WR=28.29%, N=152) | **Verified in sample** — requires fresh-data replication before inference; do not act |
| TREND_UP+BUY RCEM design intent → REDUCED | **Supported, documentation-only** — not runtime enforcement |
| V1 FSW Alpha→Allocation circular dependency | **Verified from source** — council_aggregator.mqh |
| HIGH_CONVICTION exemption bypasses DSN + CRR gates | **Verified from source** — council_pre_ai_filter.mqh |
| Zone serves triple-duty across Alpha, Risk, Allocation | **Verified from source** — three confirmed usage sites |
| council_quality is a cross-layer composite | **Verified from source** — aggregator formula confirmed |
| OBSERVE_ONLY ×0.15 influences Allocation | **Verified from source** — aggregator lines 207–212 |
| Exhaustion signal feeds Allocation (quality) not Risk (veto) | **Verified from source** — exhaustion_warning is quality penalty, not blocking condition |
| Regime absent from live MT5 layers | **Corrected to:** Regime is not first-class in live MT5 layers — zone approximates it but regime has no discrete field representation |
| Opportunity Ledger absent or not implemented | **Contradicted and corrected** — Opportunity Ledger (Phase 2, Stage 18.5) is ACTIVE; ai_opportunity_ledger.jsonl and ai_opportunity_summary.json confirmed live |
| Layer 5 Attribution absent | **Contradicted and corrected** — Attribution layer is ACTIVE but immature; ledger record volume insufficient for Phase 4C, FSW audit, or EEWP decisions |
| Any MT5 source patch authorized by Section 21 | **Contradicted** — Section 21 is documentation only; no source change authorized |
| System production-ready | **Contradicted** — DEVELOPING status unchanged |

---

### 21.15 Footer

```
SECTION_ID:                      VARIANT_D_AND_LAYER_COHERENCE_V1
SECTION_TYPE:                    EVIDENCE_DOCUMENTATION — DOCUMENTATION_ONLY
DECISION_DATE:                   2026-05-07
PIML_BACKUP:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_134812
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
MT5_AUTHORITY:                   PRESERVED — sole runtime authority, permanent constraint
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY — permanent constraint
SYSTEM_STATUS:                   DEVELOPING — unchanged
VARIANT_D_VERDICT:               PARTIAL_RECOVERY_INSUFFICIENT_FOR_GATE_DECISION
TREND_UP_BUY_LABEL:              EDGE_WEAK_BUT_RECOVERABLE (not EDGE_REJECTED)
TREND_UP_BUY_RCEM_INTENT:        REDUCED (design-only; no enforcement)
RANGE_NEUTRAL_SELL_LABEL:        EDGE_SUPPORTED (strongest bucket)
LAYER_LEAKAGE_COUNT:             7 identified (see §21.8)
OPPORTUNITY_LEDGER_STATUS:       ACTIVE — Stage 18.5 live; evidence immature (low record count)
LAYER_5_ATTRIBUTION_STATUS:      ACTIVE BUT IMMATURE — insufficient volume for Phase 4C/FSW/EEWP
PHASE_4A_STATUS:                 BLOCKED (unchanged — TPC ≥5 triggers required)
PHASE_4B_STATUS:                 BLOCKED (unchanged — MFI ≥5 signal readings required)
PHASE_4C_STATUS:                 BLOCKED (unchanged — Ledger < 200 records)
EEWP_STATUS:                     DESIGN_ONLY — blocked on Phase 2+3+4 completion
NEXT_AUTHORIZED_ACTION:          Ledger accumulation + Nautilus Phase 3 continuation (no source patch)
```

---

## Section 22 — TPC Certification, Packet Semantics, Phase 4A Reclassification, and Development Completion Discipline

### 22.1 Adoption Status

| Item | Status |
|---|---|
| TPC Nautilus Phase 3 certification | COMPLETE — 2026-05-07 |
| Packet semantics management adoption | ADOPTED — operative effective this session |
| Phase 4A blocker reclassification | ADOPTED — old interpretation retired |
| Development completion discipline | MANAGEMENT DIRECTIVE — operative effective this section |
| PIML Section 22 documentation | THIS SECTION |

All four items in this section are documentation of adopted decisions and completed evidence work. No MT5 source changes. No gate implementations. No weight changes.

---

### 22.2 TPC Nautilus Phase 3 Certification Summary

**Strategy:** `trend_pullback_cont_v1`
**Certification script:** `C:\Users\INFINTY GROUP\Documents\nautilus_lab\scripts\cert_trend_pullback_cont_v1.py`
**Metrics output:** `C:\Users\INFINTY GROUP\Documents\nautilus_lab\outputs\trend_pullback_cont_v1_metrics.json`
**Certification report:** `C:\Users\INFINTY GROUP\Documents\nautilus_lab\certifications\certification_trend_pullback_cont_v1.md`
**Classification:** SOURCE_FAITHFUL_APPROXIMATION (BullishRejection proxy — simplified `lower_wick > upper_wick` vs MT5 internal `RT_BullishRejection`)
**Data:** XAUUSD M1 (100,466 bars, 2026-01-23 → 2026-05-07) + M5 (34,652 bars, 2025-11-07 → 2026-05-07)
**Cost model:** Spread 10pt + slippage 2pt = 12pt = 0.12 price. SL = ATR14_M1 × 1.20, TP = SL × 1.50, RR = 1.50
**Breakeven WR:** 40.0% theoretical; ~42.4% practical (after spread/slippage cost)

#### Variant A — Source-Faithful Baseline

| Metric | Value |
|---|---|
| Raw triggers | 581 |
| Closed trades | 409 |
| WR | 44.99% |
| E[R] | +0.125R |
| Profit factor | 1.2267 |
| Max consecutive losses | 9 |
| Avg MAE | 0.95R |
| Avg MFE | 1.10R |
| Avg bars held | 6.2 |
| Certification label | **EDGE_SUPPORTED** |

#### Variant A — Direction Split

| Direction | N | WR | E[R] | PF | Label |
|---|---|---|---|---|---|
| BUY | 202 | 42.08% | +0.052R | 1.0897 | EDGE_WEAK_BUT_RECOVERABLE |
| SELL | 207 | 47.83% | +0.196R | 1.3750 | EDGE_SUPPORTED |

SELL side is notably stronger. BUY side is above breakeven but weak. Overall composite is EDGE_SUPPORTED.

#### Variant A — Monthly Breakdown

| Month | N | WR | E[R] | Label |
|---|---|---|---|---|
| 2026-01 | 31 | 51.61% | +0.290R | EDGE_SUPPORTED |
| 2026-02 | 124 | 41.13% | +0.028R | EDGE_WEAK_BUT_RECOVERABLE |
| 2026-03 | 120 | 46.67% | +0.167R | EDGE_SUPPORTED |
| 2026-04 | 121 | 42.15% | +0.054R | EDGE_WEAK_BUT_RECOVERABLE |
| 2026-05 | 13 | 76.92% | +0.923R | DATA_INSUFFICIENT (N<15) |

All four complete months show positive E[R]. No month is below breakeven. This is a consistency indicator, not a guarantee.

#### Variant B — TC Regime Proxy

TPC trigger already enforces M1+M5 dual alignment. Variant B imposes no additional filter. Result identical to Variant A (581 triggers, 409 closed, WR=44.99%).

#### Variant C — Depth Gate Sensitivity

| Upper ATR Gate | Triggers | Closed | WR | E[R] | Label |
|---|---|---|---|---|---|
| 0.50 | 485 | 348 | 43.39% | +0.085R | EDGE_SUPPORTED |
| **0.70 (current)** | **581** | **409** | **44.99%** | **+0.125R** | **EDGE_SUPPORTED** |
| 0.90 | 639 | 443 | 45.15% | +0.129R | EDGE_SUPPORTED |
| 1.10 | 658 | 455 | 44.62% | +0.115R | EDGE_SUPPORTED |

All four gates are EDGE_SUPPORTED. The 0.70 gate is the current source-faithful value and is not the weakest or strongest — it sits near the optimum. The edge is structurally robust to reasonable gate variation. No gate change is authorized or warranted.

#### Variant D/E — Co-Presence with trend_momentum

| Metric | Value |
|---|---|
| TM closed trades (Variant B) | 7,940 |
| TM trades with TPC co-present (±5 min) | 114 |
| Co-presence rate | 1.4% |
| TM + TPC (with confirmer): WR | 45.61%, E[R]=+0.140R |
| TM without TPC (no confirmer): WR | 41.11%, E[R]=+0.028R |
| WR lift with TPC present | +4.50pp |
| E[R] lift with TPC present | +0.112R |

TPC co-presence is associated with meaningfully better TM outcomes. This is directionally positive for the quality-enhancement interpretation of TPC. However, 1.4% co-presence means TPC is structurally too sparse to function as a mandatory CRR gate for TM without causing near-total execution collapse.

---

### 22.3 TPC Functional Role Interpretation

**TPC has a real, certified edge as a standalone strategy and as a quality signal — but is not viable as a mandatory CRR gate for trend_momentum.**

#### Dual Verdict

| Role | Verdict | Basis |
|---|---|---|
| Standalone CONFIRM in TC zone | **EDGE_SUPPORTED** | WR=44.99%, E[R]=+0.125R, N=409, all months positive |
| Mandatory CRR gate for trend_momentum | **TOO_SPARSE_FOR_PHASE_4A** | 1.4% co-presence → 92–98% TM starvation |

#### Why TPC Cannot Be the Mandatory CRR Gate

Under IRREW Phase 4A, the upgraded CRR gate requires a cross-family CONFIRM for every TC zone trade. TPC is the only TREND_PULLBACK_CONTINUATION family confirmer in the system. At 1.4% co-presence:

- 92% to 98% of TM trades would be blocked (CRR fails, no cross-family confirm present)
- This is structural starvation, not quality filtering
- The resulting system would not have fewer, better-selected trades — it would have near-zero TC zone activity
- Starvation collapses execution regardless of whether the blocked trades were good or bad

The maximum theoretical overlap (if TPC fired on every eligible bar) would be approximately 7.3% based on TPC's trigger rate of 5.59/day vs TM's execution frequency. Even at maximum theoretical overlap, ~92% of TM trades would still lack a co-present TPC confirm.

#### What TPC Can Do

- Serve as an independent CONFIRM vote in council deliberation — this is its current design role
- Contribute quality uplift when co-present (confirmed: +4.50pp WR, +0.112R E[R])
- Serve as a non-blocking quality signal within council aggregation scoring
- These roles are all compatible with its current implementation without any source change

---

### 22.4 Phase 4A Blocker Reclassification

**Previous blocker framing (Section 17 / DESIGN_V1):**
> Phase 4A (cross-family CRR upgrade) is BLOCKED because TPC has not yet fired in live runtime. Unblock condition: TPC fires ≥5 distinct times in live EA session.

**Reclassified blocker framing (adopted 2026-05-07):**

The "TPC fires first" condition was necessary but not sufficient. The Nautilus certification has revealed a structural architectural constraint that supersedes the firing-count blocker:

> Phase 4A (cross-family CRR upgrade as originally designed — TPC as mandatory CRR confirmer) is BLOCKED because TPC is structurally too sparse to serve as a mandatory CRR gate. The 1.4% co-presence rate means mandatory enforcement would collapse TC zone execution by 92–98%. This is a **structural architectural finding**, not a calibration problem.

| Aspect | Old Framing | New Framing |
|---|---|---|
| Blocker type | Runtime evidence gap (TPC hasn't fired) | Architectural structural constraint (TPC too sparse as mandatory gate) |
| Unblock condition | TPC fires ≥5 times live | Architectural redesign or Phase 4A scope change |
| Phase 4A status | BLOCKED pending runtime evidence | BLOCKED pending architectural decision |
| What changes when TPC fires | Blocker would have cleared (old) | Blocker does NOT clear — structural sparsity persists regardless of how many times TPC fires (new) |
| Evidence basis | None (hypothetical) | Nautilus: 581 triggers, 409 trades, 1.4% co-presence with TM across 7,940 TM trades |

**Phase 4A design direction — two candidate paths (operator decision required):**

| Path | Description | Tradeoff |
|---|---|---|
| A — Redesign gate with different scope | Keep mandatory cross-family CRR but allow any TREND_PULLBACK_CONT OR qualifying non-TC-family confirmer, not TPC-only | Requires identifying/certifying additional confirmer families; wider design scope |
| B — Quality-enhancement non-blocking design | TPC presence upgrades council_quality score; does not block TM execution; preserves execution volume while capturing quality signal | Less architecturally pure; loses hard enforcement; compatible with current sparsity |

Neither path is authorized. This is a design decision requiring operator authorization before any implementation work begins. No MT5 source changes are permitted until the design direction is chosen and a bounded Codex task is authorized.

**Updated Phase 4A status:**

```
PHASE_4A_STATUS:    BLOCKED — architectural redesign required (structural sparsity constraint)
PHASE_4A_EVIDENCE:  TPC co-presence 1.4% (114/7,940 TM trades); theoretical max ~7.3%
PHASE_4A_NEXT:      Operator decision on path A vs B before any design work
PHASE_4A_NOTE:      TPC firing live does NOT unblock Phase 4A; structural constraint persists
```

---

### 22.5 Packet Semantics Clarification (Management Adopted)

**Adopted definition (operative):**

> **Packet quality = the quality of evidence available at the moment of pre-consumption evaluation.**

A "high-quality packet" means the incoming signal has strong supporting evidence: aligned regime, directional agreement, deep pullback within depth gate, confirmed by bullish rejection, low overextension, appropriate session.

**What packet quality is NOT:**

| Misuse | Correct framing |
|---|---|
| "High quality packet → approved to execute" | Execution permission comes from council aggregation + filter gates, not from packet quality alone |
| "High quality packet → will win" | Outcome is probabilistic and belongs to Attribution/Ledger/Nautilus post-trade analysis |
| "Low quality packet → should be rejected" | Low quality reduces council_quality score and reduces consensus strength, but does not independently block execution |
| "Packet quality = certainty" | Packet quality = pre-consumption evidence quality at decision time, not outcome prediction |

**Why this matters architecturally:**
The IRREW system uses packet quality as one input into council aggregation scoring. Misreading quality as execution permission creates false enforcement logic — the quality signal is advisory for council scoring, not a binary gate. Misreading quality as outcome prediction confuses the Alpha/Thesis layer with the Attribution layer, creating a layer-leakage risk.

**Packet flow under IRREW doctrine (for reference):**

```
Regime Assessment (Environment)
  → Alpha/Thesis Layer (TPC evidence: pullback depth, confirm quality, EMA alignment)
    → Packet quality score (input to council_quality, not execution gate)
      → Risk Layer (stop geometry, ATR-based SL/TP)
        → Allocation Layer (council aggregation: roles, weights, consensus type)
          → Execution Layer (pre_ai_filter gates: DSN/CRR/DOMINANT_SIDE)
            → Attribution Layer (Ledger, Nautilus replay, outcome capture)
```

Packet quality lives in the Alpha/Thesis layer. It is upstream of execution. It informs but does not determine execution.

---

### 22.6 Inter-Layer Communication Interpretation

Each layer communicates its output as a structured packet to the next layer downstream. No layer should reach backward into a prior layer or bypass the intermediate layers.

| From Layer | To Layer | Packet Content |
|---|---|---|
| Regime (Environment) | Alpha/Thesis | zone_type, regime_label, era_v1, CEIS score, session |
| Alpha/Thesis (Strategies) | Risk | trigger_present, direction, confidence_score, quality_score (per strategy) |
| Risk (Governor/Stop) | Allocation | adjusted thresholds, ATR-based SL/TP, risk-scaled vote weights |
| Allocation (Aggregator) | Execution | consensus_type, council_quality, family_diversity, dominant_side, conflict_score |
| Execution (Filter) | Attribution | final_decision, filter_reason, gate_results (DSN/CRR/DOMINANT_SIDE) |
| Attribution (Ledger) | (Feedback loop to Regime/Alpha) | performance records, regime accuracy, strategy accuracy, anomaly flags |

**Current deviations from clean layer separation (documented in §21.8):**
Seven layer-leakage risks exist in the current implementation. They are documented, not yet remediated. Remediation requires Phase 4+ architectural work under operator authorization.

---

### 22.7 Development Completion Discipline (Management Directive)

**Directive adopted 2026-05-07. Operative immediately.**

The system is running. Strategies are firing. The council architecture is live. Evidence is accumulating. The foundational infrastructure exists and is functional.

**The primary obligation at this stage is completing the development program — not expanding it.**

#### What "completion" means

Completion means reaching the state where the system has:
1. All 17 strategies Nautilus-certified (Phase 3 complete for all 17)
2. IRREW Phase 4 architectural changes implemented and runtime-validated
3. Phase 5 restriction patches applied for all strategies with hostile-regime Nautilus findings
4. Opportunity Ledger (Phase 2) accumulating structured records enabling Attribution analysis
5. 200+ trades under the full IRREW architecture post-Phase-4
6. Stable WR ≥ 42% sustained over 60 trading days under IRREW architecture

#### What the completion discipline forbids

| Prohibited behavior | Reason |
|---|---|
| Adding new strategies to the council without evidence | Factory admission is frozen; new strategies require separate design plan and operator authorization |
| Expanding scope of an existing certification mid-analysis | Complete the current certification; add scope as a separate, bounded task |
| Implementing architectural changes before their prerequisites are met | Phase gates exist for evidence integrity; bypassing them destroys the audit trail |
| Treating "one more variant" as free exploration | Every additional variant is a time and context cost; require a specific question before adding variants |
| Designing features not currently blocked by evidence gaps | Design only what is immediately needed for the next unblocked phase step |
| Rerunning certifications without a documented reason | The current certification stands until there is a specific reason to rerun (new data, bug found, parameter change) |
| Drifting into open-ended research when a concrete next step exists | The ordered action list (§22.8) exists for a reason — work it in order |

#### What the completion discipline requires

| Required behavior | Reason |
|---|---|
| Work through the Nautilus Phase 3 certification backlog systematically | 15 of 17 strategies uncertified; this is the single largest blocking dependency |
| Resolve each blocker in the order it appears in the phase dependency chain | Out-of-order work creates dead ends when prerequisites aren't met |
| After each completed certification, immediately update PIML and the Strategy Genome Matrix | Evidence that isn't recorded is evidence that can't be acted on |
| After each MT5 source change, complete the full runtime validation window before the next change | Each change must stand alone in evidence before the next is layered on |
| When a design question arises that isn't immediately actionable, record it in PIML and continue | Do not let design exploration consume implementation bandwidth |
| Treat the Phase gate structure as a checklist, not an obstacle | Gates exist to prevent premature implementation; working through them in order is the fastest path to completion |

---

### 22.8 Current Main Objective Priority

The following is the ordered priority list as of 2026-05-07. Items must be completed in order where dependencies exist. Parallel progress is allowed only where dependencies are independent.

| Priority | Objective | Status | Dependency |
|---|---|---|---|
| 1 | EA reload and Phase 5A runtime validation (bollinger_reclaim SELL-in-TREND_UP gate observation) | PENDING RELOAD | None — immediate action |
| 2 | Opportunity Ledger (Phase 2) structured record accumulation | IN PROGRESS — records accumulating | Requires EA reload |
| 3 | Nautilus Phase 3 certification backlog — systematic completion for all 17 strategies | IN PROGRESS — 2/17 complete (bollinger_reclaim, TPC) | Independent of MT5 source changes |
| 4 | Phase 4A architectural decision (Path A vs B) | BLOCKED — awaiting operator decision | Requires completion of TPC certification (done); operator choice |
| 5 | Phase 4B (Exhaustion veto): mfi_reversal_assist first entries + signal strength readings | BLOCKED — 0 MFI entries | Live runtime |
| 6 | Phase 4C (Quality soft gate): Opportunity Ledger ≥ 200 records | BLOCKED — record count insufficient | Phase 2 accumulation |
| 7 | Phase 5 restriction patches (bollinger_reclaim RMR evidence; breakdown_momentum Nautilus cert) | PARTIALLY APPLIED — 5A done; 5B+ pending Phase 3 certs | Nautilus Phase 3 per strategy |

---

### 22.9 What Must Not Be Implemented Yet

The following are explicitly forbidden from implementation until prerequisites are documented as met:

| Item | Why Forbidden |
|---|---|
| Cross-family CRR upgrade (Phase 4A) | Architectural redesign required; path not chosen; structural sparsity constraint |
| Exhaustion veto (Phase 4B) | MFI 0 entries; no threshold calibration basis |
| Quality soft gate reactivation (Phase 4C) | Opportunity Ledger < 200 records; cannot audit suppression quality |
| Evidence-Earned Weight Progression (EEWP) | Phase 2 + Phase 3 (8 strats min) + Phase 4 runtime sample required |
| OBSERVE_ONLY multiplier change (×0.15 → ×0.00) | Requires Opportunity Ledger audit before any change authorized |
| New strategy factory admission | Locked; no new strategies without separate design plan and operator authorization |
| TPC depth gate change (from 0.70) | Nautilus confirms 0.70 is optimal; no change warranted |
| Stop geometry change | Deferred pending multi-file architectural design; not in scope |
| Nautilus as runtime authority | Permanent constraint; never |
| Automatic weight changes | All weight changes require operator sign-off on bounded Codex task |
| Phase 4A bypassing TPC sparsity constraint | Even if TPC begins firing frequently, the 1.4% co-presence rate at scale makes mandatory gate unviable without redesign |
| Claiming production readiness | Status: DEVELOPING; not claimable at any intermediate phase |

---

### 22.10 Recommended Next Actions

| # | Action | Type | Authorized Now |
|---|---|---|---|
| 1 | EA reload — activate Phase 5A runtime observation window | Operations | YES |
| 2 | Monitor bollinger_reclaim behavior in TREND_UP regime for first 48h post-reload | Observation | YES |
| 3 | Continue Nautilus Phase 3 certification backlog — next target: `sweep_reversal` or `bollinger_reclaim` full replay (operator choice) | Research/Lab | YES |
| 4 | Monitor live TPC trigger rate post-reload — expected ~5.6/day; investigate if 0 triggers after 5 trading days | Observation | YES |
| 5 | Choose Phase 4A design path (A: redesigned gate, B: quality-enhancement non-blocking) | Design decision | Operator authorization required |
| 6 | Accumulate Opportunity Ledger records toward 200-record threshold for Phase 4C | Ongoing | Automatic via EA |

---

### 22.11 Evidence Classification

| Claim | Classification |
|---|---|
| TPC Variant A WR=44.99%, E[R]=+0.125R, N=409 | **Verified** — Nautilus SOURCE_FAITHFUL_APPROXIMATION, 104-day XAUUSD data |
| All 4 complete months positive E[R] | **Verified** — Nautilus monthly breakdown |
| SELL side (WR=47.83%) stronger than BUY (WR=42.08%) | **Verified** — Nautilus direction split |
| All 4 depth gates (0.50–1.10) EDGE_SUPPORTED | **Verified** — Nautilus Variant C |
| TPC co-presence with TM = 1.4% (114/7,940) | **Verified** — Nautilus vectorized merge_asof overlap, confirmed both directions |
| TM + TPC WR = 45.61% vs TM alone = 41.11% | **Verified** — Nautilus Variant E |
| Phase 4A mandatory gate would starve TC execution 92–98% | **Derived — strongly supported** (1.4% co-presence × 7,940 TM trades; arithmetic) |
| Path B (quality-enhancement) preserves execution volume | **Plausible but unverified** — requires design; no implementation exists |
| Packet quality = pre-consumption evidence quality | **Management adopted** — definitional; operative |
| Phase 4A structural sparsity persists regardless of TPC live fire count | **Verified** — Nautilus 104-day sample; structural rate, not a sample artifact |
| Development completion discipline improves system outcomes | **Plausible** — management judgment; not quantitatively testable |
| System status: DEVELOPING | **Verified** — unchanged; no IRREW phase complete |

---

### 22.12 Footer

```
SECTION_ID:                      TPC_CERT_PACKET_SEMANTICS_PHASE4A_DISCIPLINE_V1
SECTION_TYPE:                    EVIDENCE_DOCUMENTATION_AND_MANAGEMENT_DIRECTIVE
DECISION_DATE:                   2026-05-07
PIML_BACKUP:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_175916
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
MT5_AUTHORITY:                   PRESERVED — sole runtime authority, permanent constraint
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY — permanent constraint
SYSTEM_STATUS:                   DEVELOPING — unchanged
TPC_CERTIFICATION_LABEL:         EDGE_SUPPORTED (standalone); TOO_SPARSE_FOR_PHASE_4A (as mandatory CRR gate)
TPC_VARIANT_A_WR:                44.99% (N=409)
TPC_COPRESENCE_WITH_TM:          1.4% (114/7,940)
PHASE_4A_STATUS:                 BLOCKED — structural architectural constraint (redesign required)
PHASE_4A_OLD_BLOCKER:            TPC ≥5 live fires (RETIRED — insufficient; structural constraint supersedes)
PHASE_4A_NEW_BLOCKER:            Architectural decision required: mandatory gate redesign OR quality-enhancement path
PHASE_4B_STATUS:                 BLOCKED — MFI 0 entries
PHASE_4C_STATUS:                 BLOCKED — Opportunity Ledger < 200 records
PACKET_SEMANTICS_STATUS:         ADOPTED — quality = pre-consumption evidence quality; not execution permission; not outcome
DEVELOPMENT_DISCIPLINE:          OPERATIVE — completion over expansion; work backlog in order
NAUTILUS_PHASE3_PROGRESS:        2/17 strategies certified (bollinger_reclaim, trend_pullback_cont_v1)
NEXT_AUTHORIZED_ACTION:          EA reload → Phase 5A validation → Nautilus Phase 3 next target
```

---

## Section 23 — Phase 4A Redesign: Cross-Family Evidence Handling Under IRREW

### 23.1 Adoption Status

| Item | Status |
|---|---|
| Phase 4A redesign report | COMPLETE — 2026-05-07 |
| Report type | DESIGN_ONLY — no MT5 source changes, no implementation |
| Operator decision on recommended path | PENDING — awaiting authorization |
| PIML Section 23 documentation | THIS SECTION |

**Full report:** `PHASE_4A_REDESIGN_V1` — produced and confirmed 2026-05-07. This section records the binding decisions and findings; the full report text is the authoritative reference for option analysis and rationale.

---

### 23.A — Advisory Correction Adopted (2026-05-07)

**Status: BINDING — supersedes any conflicting statements in §23.5, §23.6, §23.8, §23.9, §23.11, §23.12, §23.13**

The diagnosis in `PHASE_4A_REDESIGN_V1` is accepted: Option F (Thesis Evidence Bundle with Explicit Cross-Family Quality Tracking) is the correct architectural direction. The scoring implementation paths proposed in the original report are **rejected and deprecated**.

#### What is accepted

| Item | Status |
|---|---|
| Phase 4A problem diagnosis (Option A architecturally broken, starvation confirmed) | **ACCEPTED** |
| Phase 4A purpose reframing (evidence diversity → Allocation, not Execution) | **ACCEPTED** |
| Option F as the correct architectural frame | **ACCEPTED diagnostically** |
| Phase 4A-i as Evidence / Attribution ledger extension | **ELIGIBLE pending operator authorization** |
| Cross-family confirmation tracked as categorical evidence fields | **ACCEPTED** |

#### What is rejected / deprecated

| Item | Status |
|---|---|
| `+0.04` council_quality bonus for `cross_family_confirm_present` | **REJECTED** — no score authority in decision layers |
| HIGH_CONVICTION semantic change (requiring `cross_family_confirm_present`) | **REJECTED** — not authorized |
| Phase 4A-ii as "Quality Formula Enhancement" | **DEPRECATED** — rewritten as "Cross-Family Evidence Classification Review" |
| Any council_quality formula change | **NOT AUTHORIZED** — requires separate evidence baseline and operator authorization |
| Any CRR / DSN / gate / weight / posture / execution change | **NOT AUTHORIZED** |

#### Corrected scope of Phase 4A

Phase 4A is approved **only** as an Evidence / Attribution extension:
- Categorical tracking of cross-family confirmation structure in the Opportunity Ledger
- No numeric bonuses
- No consensus classification changes
- No score authority of any kind in decision layers
- No change to any gate, weight, role multiplier, or execution path

**Phase 4A-ii purpose is redefined:** After sufficient cross-family event accumulation, Phase 4A-ii is a classification review to determine whether cross-family evidence patterns are stable and interpretable — not a quality formula change.

---

### 23.2 Phase 4A Purpose (Reframed)

The original Phase 4A framing ("prevent same-family pseudo-confirmation from satisfying the CRR gate") was correct in intent but incomplete. The reframed single-sentence purpose:

> Phase 4A should ensure that cross-family evidence presence meaningfully influences the quality and confidence of an allocation decision, without reducing to a binary execution gate that starvation risk makes unenforceable.

**Full statement of Phase 4A purposes (all verified):**
- Ensure evidence diversity: core intent — single-family consensus cannot distinguish strong signal from strategy cluster agreement
- Reduce same-family pseudo-confirmation: micro_structure_reentry_v1 (TREND_CONTINUATION) confirming trend_momentum (TREND_CONTINUATION) satisfies the current role-only CRR gate without adding independent evidence
- Improve thesis quality: cross-family confirmation = two independent detection mechanisms agreeing
- Prevent bad trades: partially — absence of cross-family confirm does not reliably predict a bad trade
- Increase institutional coherence: evidence diversity belongs in the Portfolio/Allocation layer, not the Execution layer

---

### 23.3 Why Strict TPC-Gated CRR Fails (Summary)

The original IRREW Phase 4A design required TPC as a mandatory CRR confirmer for all TC zone executions. Four reasons this is architecturally broken:

**1. Starvation arithmetic:**
- TPC co-presence with TM: 1.4% (114/7,940 Variant B trades)
- Mandatory TPC gate → 98.6% TC execution collapse → ~1.1 trades/day from ~76 trades/day
- This is structural starvation, not quality selection

**2. Structural rate persists regardless of TPC live firing count:**
- TPC fires ~5.6/day; TM fires ~76/day; the overlap is architectural (different trigger signatures)
- Clearing "TPC must fire first" does NOT unblock Phase 4A as originally designed
- The old blocker was necessary but not sufficient

**3. Same-family pseudo-confirmation is the real defect — not a TPC absence defect:**
- TPC absence does not predict TM outcome; only TPC presence improves outcomes (+4.50pp WR)
- Treating absence as evidence of a bad trade is the architectural overcorrection

**4. No alternative mandatory confirmer exists:**
- All TC-zone CONFIRM strategies except TPC are TREND_CONTINUATION family (same as TM)
- No cross-family strategy fires at the ≥20% co-presence rate required for a viable mandatory gate
- Adding a new confirmer requires factory admission (locked) + Nautilus certification

---

### 23.4 Option Verdicts

| Option | Description | Verdict |
|---|---|---|
| A — Strict Cross-Family CRR Gate | Mandatory TPC gate; execution blocked absent TPC | **REJECTED** — structural starvation; viable only with a new cross-family confirmer |
| B — TPC Quality Enhancement | TPC present → quality boost; absent → no block | **PARTIAL** — correct direction; doesn't address same-family defect directly; component of Option F |
| C — Thesis Evidence Bundle | Confirmers as evidence contributors, not required gates | **CORRECT FRAME** — operationally implemented via Option F |
| D — Regime-Conditioned Confirmation | Different requirements per regime/bucket | **DEFERRED** — no calibrated threshold for TREND_UP+BUY gate; correct as Allocation modifier (RCEM REDUCED intent), not as Execution gate |
| E — Alternative Confirmer Search | Find higher-frequency cross-family confirmer | **NOT ACTIONABLE** — no viable candidate in current strategy set; deferred as long-term research |
| **F — Hybrid Risk/Allocation** | Risk: structural gates only; Allocation: cross-family quality delta | **RECOMMENDED** — full doctrine compliance; preserves execution volume; auditable via Ledger |

---

### 23.5 Recommended Phase 4A Design (Option F)

**Model: Thesis Evidence Bundle with Explicit Cross-Family Quality Tracking**

#### Core design change

Introduce one new field alongside the existing `confirm_role_present`:

| Field | Current | Redesigned |
|---|---|---|
| `confirm_role_present` | Any CONFIRM-role strategy voting in dominant direction | **Unchanged** — role-only; same-family CONFIRM still satisfies CRR gate |
| `cross_family_confirm_present` (NEW) | Does not exist | True only when CONFIRM role is present AND confirm_family ≠ primary_executor_family |

#### ~~council_quality formula change~~ — DEPRECATED by Advisory Correction §23.A

The original report proposed a `+0.04` council_quality bonus for `cross_family_confirm_present`. **This is rejected.** No numeric bonus, no score authority in any decision layer. The council_quality formula is unchanged.

#### ~~HIGH_CONVICTION consensus change~~ — DEPRECATED by Advisory Correction §23.A

The original report proposed tightening HIGH_CONVICTION to require `cross_family_confirm_present`. **This is rejected.** No HIGH_CONVICTION semantic change is authorized.

#### Adopted: Categorical Evidence Tracking (Evidence / Attribution only)

Cross-family confirmation is tracked as categorical fields in the Opportunity Ledger. No decision layer consumes these fields.

**Fields to be added to Opportunity Ledger (Phase 4A-i scope):**

| Field | Type | Description |
|---|---|---|
| `cross_family_confirm_present` | bool | CONFIRM role present AND confirm_family ≠ primary_executor_family |
| `same_family_confirm_present` | bool | CONFIRM role present AND confirm_family == primary_executor_family |
| `primary_executor_family` | string | Family of the strategy with highest weighted contribution |
| `cross_family_confirm_family` | string | Family of cross-family CONFIRM, if present |
| `cross_family_confirm_strategy_id` | string | Strategy ID of cross-family CONFIRM, if present |
| `confirm_structure_type` | string | CROSS_FAMILY / SAME_FAMILY / NO_CONFIRM / MIXED |
| `confirm_family_count` | int | Count of distinct confirmer families in dominant direction |
| `confirm_strategy_count` | int | Count of CONFIRM-role strategies voting in dominant direction |

**These fields are Attribution evidence only.** They are written to the Opportunity Ledger. They are not consumed by council_quality, consensus classification, any gate, or any execution path. No score authority is granted.

#### What does NOT change

- CRR gate logic in `council_pre_ai_filter.mqh`: **unchanged** — role-only `confirm_role_present` check; same-family CONFIRM still satisfies CRR; no new blocking gate
- Execution decision thresholds: **unchanged**
- TPC vote_weight (0.80): **unchanged**
- TM vote_weight: **unchanged**
- Any strategy trigger logic: **unchanged**
- Stop geometry: **unchanged**
- Any RCEM enforcement: **not implemented**

#### Why this is the correct layer placement

| What | Layer | Status |
|---|---|---|
| Cross-family evidence fields tracked | Attribution (Opportunity Ledger) | ✓ Adopted |
| ~~Cross-family quality bonus (+0.04)~~ | ~~Portfolio/Allocation~~ | **DEPRECATED** — §23.A |
| ~~HIGH_CONVICTION tightened~~ | ~~Portfolio/Allocation~~ | **DEPRECATED** — §23.A |
| CRR gate logic | Execution (pre_ai_filter) — **unchanged** | ✓ Unchanged |
| council_quality formula | Portfolio/Allocation — **unchanged** | ✓ Unchanged |
| `cross_family_confirm_present` et al. recorded | Attribution (Opportunity Ledger) | ✓ Phase 4A-i scope |

Cross-family evidence is collected as Attribution evidence only. No decision layer consumes it. The Allocation and Execution layers are unchanged by Phase 4A.

---

### 23.6 Two-Phase Implementation Approach (Conceptual — Not Authorized)

**Phase 4A-i — Ledger Extension (prerequisite, bounded)**

Authorize a single bounded Codex task to extend the Opportunity Ledger write to include the categorical evidence fields defined in §23.5:
- `cross_family_confirm_present`, `same_family_confirm_present`, `primary_executor_family`, `cross_family_confirm_family`, `cross_family_confirm_strategy_id`, `confirm_structure_type`, `confirm_family_count`, `confirm_strategy_count`

Conceptual files affected: `council_mode_types.mqh` (struct field additions) + `council_mode_runtime.mqh` (ledger write call). **No quality formula changes. No gate changes. No consensus classification changes. Data collection only.**

Accumulation windows after Phase 4A-i (evidence milestones — not authorization triggers):

| Milestone | Records / Events | Meaning |
|---|---|---|
| Field stability check | ≥500 total ledger records | Confirms fields are populating correctly; schema is stable. **Does NOT authorize any formula change.** |
| Diagnostic | ≥10 cross-family events (`cross_family_confirm_present = true`) | Sufficient for initial field validation and sanity check only |
| Preliminary design review eligible | ≥30 cross-family events | Sufficient to examine whether cross-family events cluster in any regime, session, or quality band. Review only — no implementation. |
| Candidate policy review eligible | ≥50 cross-family events | Sufficient to ask: does cross-family presence correlate with better outcomes in the ledger? Still does not authorize formula, gate, or weight change. |

**No milestone authorizes:** any formula change, any score bonus, any HIGH_CONVICTION change, any gate change, any allocation change, any weight change. Milestones gate evidence review only.

**Phase 4A-ii — ~~Quality Formula Enhancement~~ → Cross-Family Evidence Classification Review (subsequent)**

After ≥50 cross-family events are accumulated and reviewed, Phase 4A-ii is a classification review:
- Examine whether `confirm_structure_type` distributions (CROSS_FAMILY / SAME_FAMILY / NO_CONFIRM / MIXED) show stable, interpretable patterns
- Examine whether cross-family presence correlates with council_quality levels or consensus type in the ledger record (observational only — not causal attribution)
- Produce a classification report for operator review

**Phase 4A-ii does not produce a quality formula change, a bonus, a HIGH_CONVICTION change, or any implementation.** If the classification review warrants a policy change, that requires a separate, fresh design proposal with full operator authorization and a new bounded Codex task scope at that time.

**Sequencing:**
Phase 4A-i (ledger extension, bounded Codex task) → accumulation → milestone reviews → Phase 4A-ii (classification review, report-only) → [separate future design proposal if warranted, operator authorization required]

---

### 23.7 Layer Ownership Reference

| Concept | Layer |
|---|---|
| TM fires with directional thesis | Alpha/Thesis |
| TPC fires with supporting pullback evidence | Alpha/Thesis |
| TPC packet quality score | Alpha/Thesis → Allocation |
| Stop geometry (SL/TP) | Risk |
| Council aggregation (weights, roles, quality) | Portfolio/Allocation |
| `confirm_role_present` (+0.06) | Portfolio/Allocation — **unchanged** |
| `cross_family_confirm_present` (categorical, no score) | Attribution (Opportunity Ledger) — **not Allocation** |
| `family_diversity_score` | Portfolio/Allocation — **unchanged** |
| HIGH_CONVICTION consensus classification | Portfolio/Allocation — **unchanged** |
| CRR binary gate (structural coherence only) | Execution |
| DSN gate | Execution |
| DOMINANT_SIDE gate | Execution |
| `cross_family_confirm_present` recorded | Attribution (Opportunity Ledger) |
| Post-trade cross-family accuracy analysis | Attribution |

**Layer leakage identified (not yet remediated):** `confirm_role_present` in the CRR gate (Execution) treats same-family and cross-family CONFIRMs identically. Quality differentiation belongs in Allocation. The redesign resolves this by keeping CRR role-only and adding explicit cross-family tracking at the Allocation layer — without touching the Execution gate.

---

### 23.8 Required Evidence Before Any Implementation

| Evidence Type | Minimum Required | Unlocks | Current Status |
|---|---|---|---|
| Operator authorization for Phase 4A-i | Explicit, bounded Codex task | Phase 4A-i ledger extension only | NOT ISSUED |
| EA reload (Phase 5A) | Complete | Ledger begins accumulating | PENDING |
| Total Opportunity Ledger records with cross-family fields | ≥500 | Field stability confirmation only — does NOT unlock formula change | PENDING — field not yet in ledger |
| Cross-family events (`cross_family_confirm_present = true`) | ≥10 | Diagnostic / sanity check only | PENDING |
| Cross-family events | ≥30 | Preliminary design review eligible (report only) | PENDING |
| Cross-family events | ≥50 | Candidate policy review eligible (Phase 4A-ii classification review) | PENDING |
| Live TPC council observations | ≥15 instances | Confirms TPC council participation rate | PENDING — 0 live entries |
| Live TM executions post-reload | ≥100 | Live baseline for comparison | PENDING |

**Hard constraints (Advisory Correction §23.A applies):**
- 500 total ledger records = field stability only. **Not** authorization for formula change, bonus, or HIGH_CONVICTION change.
- 50 cross-family events = classification review eligible. **Not** authorization for any council layer change.
- No formula, score, bonus, consensus, gate, or execution change is authorized by any evidence threshold alone.
- Every implementation step requires explicit operator authorization as a separate bounded Codex task.
- Phase 4A-ii is a classification review report, not an implementation task.

---

### 23.9 What Must Not Be Implemented

| Item | Reason |
|---|---|
| Mandatory TPC gate (any form) | Structural starvation — architecturally rejected permanently |
| Cross-family CRR gate (blocking) | Evidence diversity belongs in Attribution/Ledger, not Execution |
| `council_quality` bonus of any value for cross-family presence | Advisory Correction §23.A — no score authority in decision layers |
| HIGH_CONVICTION semantic change (requiring cross-family confirm) | Advisory Correction §23.A — not authorized |
| Any score authority in decision layers from cross-family evidence | Advisory Correction §23.A — categorical evidence only; no scoring |
| Quality formula change of any kind | Not authorized — requires separate evidence baseline and operator authorization beyond Phase 4A-i |
| RCEM enforcement | Phase 3 certifications incomplete; operator authorization not issued |
| TPC or TM vote_weight changes | No basis; certifications do not support change |
| M5 hard gate for TM | Variant D found no actionable gate |
| BUY direction disable | EDGE_NOT_CONFIRMED ≠ EDGE_REJECTED |
| EEWP | Phase 2+3+4 prerequisites not met |
| New strategy factory admission | Locked |
| Alternative confirmer design | Deferred; not actionable |

---

### 23.10 TPC Functional Role Under Redesign

| Role | Status |
|---|---|
| Standalone CONFIRM in TC zone | Active, unchanged — EDGE_SUPPORTED, WR=44.99% |
| Cross-family evidence contributor for TM | Active, explicitly recognized — +4.50pp WR lift when co-present (Nautilus Variant E) |
| Categorical evidence signal in Attribution | Active under Phase 4A-i — `cross_family_confirm_present` recorded in Opportunity Ledger; no score authority |
| ~~Quality enhancement signal in Allocation (+0.04)~~ | **DEPRECATED §23.A** — no quality bonus authorized |
| ~~HIGH_CONVICTION exclusive enabler in TC zone~~ | **DEPRECATED §23.A** — no HIGH_CONVICTION change authorized |
| Mandatory CRR execution gate | **Permanently rejected** — structural starvation |
| Execution authority | **Never** — MT5 only |

---

### 23.11 Current Phase 4A Status (Updated)

```
PHASE_4A_STATUS:             BLOCKED — pending operator decision (Option F accepted diagnostically; scoring paths deprecated)
PHASE_4A_ADVISORY_CORRECTION:ADOPTED 2026-05-07 — §23.A; scoring implementation paths rejected
PHASE_4A_RECOMMENDED_PATH:   Option F — Evidence / Attribution extension ONLY
PHASE_4A_OPTION_F_SCOPE:     Categorical cross-family evidence tracking in Opportunity Ledger; no scoring
PHASE_4A_CONFIDENCE:         75% — design direction accepted; scoring scope deprecated
PHASE_4A_BLOCKED_OPTION:     Option A (strict gate) — permanently rejected
PHASE_4A_DEFERRED_OPTIONS:   D (regime-conditioned), E (alternative confirmer)
PHASE_4A_I_STATUS:           ELIGIBLE as bounded Codex task — Evidence / Attribution ledger extension only
                              Pending operator authorization
                              Scope: struct fields + ledger write only; no council layer changes
PHASE_4A_II_STATUS:          DEFERRED — rewritten as Cross-Family Evidence Classification Review (report only)
                              Not a quality formula task; not a gate task; not an allocation task
PHASE_4A_I_SCOPE:            council_mode_types.mqh (struct fields) + council_mode_runtime.mqh (ledger write)
                              Fields: cross_family_confirm_present, same_family_confirm_present,
                                      primary_executor_family, cross_family_confirm_family,
                                      cross_family_confirm_strategy_id, confirm_structure_type,
                                      confirm_family_count, confirm_strategy_count
PHASE_4A_II_SCOPE:           Classification review report — requires ≥50 cross-family events
                              No files affected; report-only output
PHASE_4A_SEQUENCE_NOTE:      Phase 4A-i does not wait on Nautilus Phase 3 backlog
                              Phase 4A-i is independent; authorization is operator's choice
SCORING_STATUS:              REJECTED — no council_quality bonus, no HIGH_CONVICTION change, no score authority
```

---

### 23.12 Evidence Classification

| Claim | Classification |
|---|---|
| TPC co-presence with TM = 1.4% (114/7,940) | **Verified** — Nautilus, 104-day data |
| Mandatory TPC gate → 92–98% TC execution collapse | **Verified** — deterministic arithmetic from 1.4% rate |
| Structural co-presence rate persists regardless of live fire count | **Verified** — trigger signature mismatch; structural not statistical |
| TM with TPC WR=45.61% vs without 41.11% | **Verified** — Nautilus Variant E |
| Same-family CONFIRM passes CRR gate identically to cross-family CONFIRM | **Verified** — source pre_ai_filter.mqh L230–253, aggregator.mqh L307–310 |
| No viable alternative cross-family TC confirmer in current strategy set | **Verified** — all TC-zone CONFIRMs except TPC are TREND_CONTINUATION family |
| Cross-family quality bonus (+0.04) is correctly calibrated | **Plausible but unverified** — design-intent estimate; requires ledger data |
| Cross-family quality bonus (+0.04) is authorized | **Contradicted** — Advisory Correction §23.A: no score authority in decision layers |
| HIGH_CONVICTION tightening to require cross-family confirm is correct architecturally | **Strongly supported** — closes DSN exemption path; doctrine-compliant |
| HIGH_CONVICTION tightening is authorized | **Contradicted** — Advisory Correction §23.A: not authorized |
| Option F (as Evidence/Attribution extension) preserves execution volume | **Verified by design** — no new blocking gate |
| Option F scoring implementation achieves evidence diversity intent | **Plausible but unverified AND DEFERRED** — scoring scope deprecated; classification review deferred |
| council_quality has four existing TPC co-presence hooks | **Verified** — source aggregator.mqh L528–535 |
| Phase 4A original design architecturally broken | **Verified** — starvation arithmetic is deterministic |
| Phase 4A-i evidence ledger extension path is authorized | **Supported — pending operator Codex task authorization** |
| Score authority in decision layers from cross-family fields | **Rejected by Advisory Correction §23.A** |
| 500 ledger records are sufficient to authorize formula change | **Contradicted** — §23.A: 500 records = field stability only; no formula change |

---

### 23.13 Footer

```
SECTION_ID:                      PHASE_4A_REDESIGN_V1
SECTION_TYPE:                    DESIGN_DOCUMENTATION — design-only; no implementation
DECISION_DATE:                   2026-05-07
AMENDMENT_DATE:                  2026-05-07
AMENDMENT_ID:                    PHASE_4A_ADVISORY_CORRECTION_V1
PIML_BACKUP_ORIGINAL:            PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_185309
PIML_BACKUP_AMENDED:             PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_185840
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
MT5_AUTHORITY:                   PRESERVED — sole runtime authority
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY
SYSTEM_STATUS:                   DEVELOPING — unchanged
PHASE_4A_STATUS:                 BLOCKED — pending operator decision; scoring paths deprecated; evidence extension eligible
PHASE_4A_OPTION_A:               REJECTED — structural starvation; permanently archived
PHASE_4A_OPTION_D:               DEFERRED — correct as RCEM REDUCED (design-only); no Execution gate
PHASE_4A_OPTION_E:               DEFERRED — no viable candidate in current strategy set
PHASE_4A_RECOMMENDED:            OPTION_F — Evidence / Attribution extension ONLY; no scoring
PHASE_4A_CONFIDENCE:             75%
PHASE_4A_NEXT_STEP:              Operator authorization → Phase 4A-i ledger extension (bounded Codex task)
PHASE_4A_I_SCOPE:                council_mode_types.mqh + council_mode_runtime.mqh — struct fields + ledger write only
                                 No council_quality, no gate, no consensus classification changes
PHASE_4A_II_SCOPE:               Classification review report only (≥50 cross-family events required)
                                 No files affected; not a quality formula task
COUNCIL_QUALITY_BONUS:           REJECTED — §23.A Advisory Correction; not authorized
HIGH_CONVICTION_CHANGE:          REJECTED — §23.A Advisory Correction; not authorized
SCORE_AUTHORITY_IN_DECISION_LAYERS: REJECTED — cross-family evidence is Attribution/ledger only
IMPLEMENTATION_FORBIDDEN:        All items listed in §23.9 including score bonuses and HIGH_CONVICTION change
OPPORTUNITY_LEDGER_EXTENSION:    Phase 4A-i scope: 8 categorical fields (see §23.5)
NAUTILUS_PHASE3_PROGRESS:        2/17 strategies certified; Phase 4A-i does not block Phase 3 continuation
```

---

## 24. MEAN_RECLAIM_AND_REVERSAL_CERTIFICATION_UPDATE_V1 — Bollinger, VWAP Candidate, and Sweep Reversal

**Section type:** EVIDENCE_DOCUMENTATION — Nautilus Phase 3 results only. No MT5 source change. No implementation authorization.
**Date:** 2026-05-07
**Authority:** Evidence only. MT5 remains sole runtime authority. Nautilus is research/evidence lab only.

---

### 24.1 Adoption and Authority Status

- All results in this section are Nautilus replay evidence only.
- MT5 remains the sole runtime authority for all trading decisions.
- No source changes are authorized from this section.
- No gate, weight, role, posture, RCEM, CRR, DSN, HIGH_CONVICTION, council_quality, or execution change is authorized.
- System status: **DEVELOPING** — unchanged.
- Nautilus evidence informs future operator decisions; it does not authorize them.

---

### 24.2 bollinger_reclaim — Clean XAUUSD Certification

**Certification ID:** `certification_bollinger_reclaim_xauusd_v1.md`
**Data:** XAUUSD_M1_20251107_20260507.csv — 100,466 rows, 104 days
**GCF=F proxy:** NOT USED — all prior GCF=F evidence is superseded and invalidated as an evidence source.
**Classification:** SOURCE_FAITHFUL (BB reclaim is exact source trigger; era proxy is EMA-based approximation)

#### 24.2.1 Variant A — Unrestricted Baseline

| Metric | Value |
|---|---|
| Triggers | 12,304 |
| Closed trades | 8,350 |
| WR | 39.27% |
| E[R] | -0.018R |
| Profit factor | 0.97 |
| Max consec losses | 19 |
| Cert label | `EDGE_WEAK_BUT_RECOVERABLE` |

Label is technically EDGE_WEAK_BUT_RECOVERABLE, but expectancy is negative and the strategy provides no positive expected value in the unrestricted case.

#### 24.2.2 Variant B — RANGE/RMR Era Proxy

| Metric | Value |
|---|---|
| Closed trades | 3,017 |
| WR | 37.92% |
| E[R] | -0.052R |
| Cert label | `EDGE_NOT_CONFIRMED` |

RANGE — the strategy's assigned zone — is EDGE_NOT_CONFIRMED when isolated. This is the most directly relevant context for bollinger_reclaim's live role.

#### 24.2.3 Era Breakdown (Variant A)

| Era | N | WR | E[R] | Label |
|---|---|---|---|---|
| TREND_UP | 2,754 | 40.01% | +0.0004R | EDGE_WEAK_BUT_RECOVERABLE |
| TREND_DOWN | 2,734 | 39.54% | -0.012R | EDGE_WEAK_BUT_RECOVERABLE |
| RANGE | 2,862 | 38.29% | -0.043R | EDGE_WEAK_BUT_RECOVERABLE |

**Finding:** RANGE is the weakest era for bollinger_reclaim. TREND_UP is the least negative / best context. This challenges the prior assumption that bollinger_reclaim belongs in a mean-reversion (RMR/RANGE) role. The strategy does not exhibit a RANGE advantage.

#### 24.2.4 Phase 5A Gate — Nautilus Finding

Phase 5A (BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A) was source-applied 2026-05-06. Nautilus evidence now provides the first SOURCE_FAITHFUL assessment of the targeted hypothesis.

| Subset | N | WR | E[R] |
|---|---|---|---|
| SELL / TREND_UP (gated) | 2,064 | 39.49% | -0.013R |
| SELL / non-TREND_UP (allowed) | 1,907 | 39.17% | -0.021R |

**Finding:** The Phase 5A targeted hypothesis is **NOT CONFIRMED by Nautilus**. SELL/TREND_UP (the gated subset) has marginally *better* WR and E[R] than SELL/non-TREND_UP. The gate removes a marginally better-performing subset.

**Phase 5A status:** SOURCE_APPLIED, RUNTIME_VALIDATION_PENDING, **NAUTILUS_CHALLENGED**.
No automatic revert is authorized. Revert requires separate operator decision and bounded Codex task if warranted.

---

### 24.3 VWAP_REGIME_RECLAIM_XAUUSD_V1 — Candidate Rejection

**Certification ID:** `certification_vwap_regime_reclaim_xauusd_v1.md`
**Purpose:** External functional replacement candidate for bollinger_reclaim
**Data:** XAUUSD M1/M5 clean; GCF=F not used
**Verdict: REJECTED — EDGE_NOT_CONFIRMED. Candidate failed all four qualification criteria.**

#### 24.3.1 Variant A — Unrestricted (band=0, VWAP line reclaim)

| Metric | Value |
|---|---|
| Triggers | 4,715 |
| Closed trades | 1,850 |
| WR | 37.78% |
| E[R] | -0.055R |
| Profit factor | 0.91 |

Underperforms bollinger_reclaim on all primary metrics.

#### 24.3.2 RANGE_NEUTRAL Subset

| Metric | Value |
|---|---|
| WR | 38.52% |
| E[R] | -0.037R |

Only +0.6pp WR improvement vs bollinger_reclaim RANGE (38.29%). Criterion required +2pp. Insufficient.

#### 24.3.3 Slippage Stress (+10pt)

WR: 37.16% — EDGE_NOT_CONFIRMED. Strategy does not survive realistic friction increase.

#### 24.3.4 Qualification Criteria Result

| Criterion | Threshold | Result |
|---|---|---|
| WR vs bollinger_reclaim | +2pp | FAILED (-1.49pp) |
| E[R] positive unrestricted | > 0 | FAILED (-0.055R) |
| RANGE advantage clear | +2pp WR | FAILED (+0.6pp) |
| Monthly robustness | ≥3/5 months | FAILED |

**Candidate not integrated into MT5. No implementation path open.**

#### 24.3.5 Notable Anomaly (non-actionable)

BUY_TREND_DOWN subset: WR=42.3%, E[R]=+0.057R, N=253. This segment shows positive expectancy in a counter-trend context. Classified **PLAUSIBLE_BUT_UNVERIFIED** — sample is small and the pattern is not systematically tested. Possible future research path: `VWAP_BOLLINGER_HYBRID_RECLAIM_RESEARCH_CANDIDATE`. No PIML promotion queue or implementation queue unless explicitly authorized by a separate operator decision.

---

### 24.4 sweep_reversal — Clean XAUUSD Certification

**Certification ID:** `certification_sweep_reversal_xauusd_v1.md`
**Data:** XAUUSD M1/M5 clean, same dataset as bollinger_reclaim
**Classification:** SOURCE_FAITHFUL
**Verdict: EDGE_WEAK_BUT_RECOVERABLE**

#### 24.4.1 Variant A — Unrestricted Baseline

| Metric | Value |
|---|---|
| Triggers | 8,990 |
| Closed trades | 6,589 |
| WR | 39.58% |
| E[R] | -0.0105R |
| Profit factor | 0.9827 |
| Max consec losses | 15 |
| Avg MAE_R | 1.049 |
| Avg MFE_R | 1.056 |
| Cert label | `EDGE_WEAK_BUT_RECOVERABLE` |

Direction: BUY WR=39.07%, SELL WR=40.18% — SELL marginally stronger.

M5 regime breakdown (Variant A):

| Regime | N | WR | E[R] | Label |
|---|---|---|---|---|
| TREND_DOWN | 1,939 | 40.69% | +0.0173R | EDGE_WEAK_BUT_RECOVERABLE |
| TREND_UP | 2,331 | 39.77% | -0.0058R | EDGE_WEAK_BUT_RECOVERABLE |
| RANGE_NEUTRAL | 2,319 | 38.46% | -0.0384R | EDGE_WEAK_BUT_RECOVERABLE |

#### 24.4.2 Variant B — Counter-trend Exclusion

| Metric | With-trend only | Unrestricted |
|---|---|---|
| Closed | 4,450 | 6,589 |
| WR | 39.01% | 39.58% |
| E[R] | -0.0247R | -0.0105R |

**Finding: Counter-trend exclusion worsens results.** Removing BUY_TREND_DOWN and SELL_TREND_UP degrades both WR and E[R]. A gate against these subsets would actively harm the strategy.

#### 24.4.3 Variant C — Direction × M5 Regime

| Subset | N | WR | E[R] | Label |
|---|---|---|---|---|
| BUY_TREND_UP | 1,253 | 39.03% | -0.0243R | WEAK |
| BUY_TREND_DOWN (counter-trend) | 1,131 | 40.50% | +0.0124R | WEAK, positive E[R] |
| **BUY_RANGE_NEUTRAL** | **1,339** | **37.57%** | **-0.0609R** | **EDGE_NOT_CONFIRMED** |
| SELL_TREND_UP (counter-trend) | 1,188 | 40.49% | +0.0122R | WEAK, positive E[R] |
| SELL_TREND_DOWN | 886 | 40.41% | +0.0102R | WEAK, positive E[R] |
| SELL_RANGE_NEUTRAL | 1,082 | 39.93% | -0.0018R | WEAK |

BUY_RANGE_NEUTRAL is the single weakest segment — EDGE_NOT_CONFIRMED. Watchlist only; no gate authorized.

#### 24.4.4 Variant D — Hostile Counter-trend Isolated

| Metric | Value |
|---|---|
| Counter-trend triggers | 3,037 |
| Closed | 2,319 |
| WR | 40.49% |
| E[R] | +0.0123R |
| Label | EDGE_WEAK_BUT_RECOVERABLE |

**Critical finding: Counter-trend sweeps (BUY_TREND_DOWN + SELL_TREND_UP) are the single best-performing subset of sweep_reversal, with positive E[R].** The sweep condition (new low/high beyond prior bar + BB reclaim) captures genuine overextension and rejection regardless of underlying trend direction. These sweeps must not be gated without contradicting evidence from a larger or more recent sample.

#### 24.4.5 Variant E — RANGE_NEUTRAL Only

WR=38.40%, E[R]=-0.0400R — weakest regime, consistent with bollinger_reclaim RANGE finding.

#### 24.4.6 Variant F — Slippage Stress (+10pt)

WR=38.37%, E[R]=-0.0408R — delta -0.0121pp. Tolerable; label unchanged.

#### 24.4.7 Variant G — Degradation Split (60/40 at 2026-03-26)

| Period | N | WR | E[R] | Label |
|---|---|---|---|---|
| EARLY (< 2026-03-26) | 3,965 | 39.45% | -0.0139R | EDGE_WEAK_BUT_RECOVERABLE |
| LATE (>= 2026-03-26) | 2,624 | 39.79% | -0.0053R | EDGE_WEAK_BUT_RECOVERABLE |

**Finding: LATE period is marginally better than EARLY.** Nautilus does not support the current degradation_hint=TRUE classification. However, degradation_hint is a live runtime flag; it cannot be cleared by Nautilus evidence alone. Clearing degradation_hint requires live runtime evidence of sustained improvement.

#### 24.4.8 Monthly Robustness

| Month | N | WR | E[R] | Label |
|---|---|---|---|---|
| 2026-01 | 510 | 38.63% | -0.0343R | WEAK |
| 2026-02 | 1,853 | 41.12% | +0.0281R | WEAK |
| 2026-03 | 1,953 | 37.74% | -0.0566R | NOT_CONFIRMED |
| 2026-04 | 1,876 | 40.62% | +0.0155R | WEAK |
| 2026-05 | 397 | 37.78% | -0.0554R | NOT_CONFIRMED |

3/5 months at EDGE_WEAK_BUT_RECOVERABLE or above. 2/5 months (March, partial May) at EDGE_NOT_CONFIRMED.

#### 24.4.9 Live Memory Comparison

| Metric | Live Memory (resolved-only) | Nautilus Full Sample |
|---|---|---|
| Wins | 15 | 2,608 |
| Losses | 20 | 3,981 |
| WR | 42.9% | 39.58% |
| Total entries | 68 | 6,590 |
| Unresolved | 33 | 1 |
| Unresolved rate | 48.5% | ~0% |

**Live WR=42.9% is SUSPICIOUS.** With 33 of 68 entries unresolved at measurement time, the resolved-only figure is an unreliable estimator. Nautilus WR=39.58% on 6,589 closed trades is the authoritative figure. The live resolved WR should not be used for edge decisions or weight justifications.

---

### 24.5 Updated Functional Interpretation

- **bollinger_reclaim** remains live but weak and Nautilus-challenged. The clean XAUUSD data does not support a RANGE advantage. Phase 5A gate targeted hypothesis is not confirmed by Nautilus. Strategy continues under RUNTIME_VALIDATION_PENDING and NAUTILUS_CHALLENGED status.

- **VWAP replacement candidate** is rejected. No alternative replacement research is open unless explicitly authorized.

- **sweep_reversal** remains viable as SCOUT / reversal-overextension scout with EDGE_WEAK_BUT_RECOVERABLE label. Not strong enough for promotion. Functional coherence is higher than bollinger_reclaim — the sweep condition provides better structural selectivity. However, current weight (0.60) and SCOUT role remain appropriate given evidence level.

- **Mean-reclaim and reversal family** does not currently provide strong production-grade edge. Both bollinger_reclaim and sweep_reversal show negative unrestricted expectancy. The family contributes to council diversity but is not currently a reliable lead executor.

- **Counter-trend reversal evidence:** Should not be automatically treated as hostile for sweep_reversal. Nautilus evidence shows counter-trend sweeps have positive E[R]. The hostile-regime framing does not apply to the sweep+reclaim trigger class in the same way it applies to trend-continuation strategies.

- **RANGE_NEUTRAL regime:** Unexpectedly weak for both bollinger_reclaim (WR=38.29%) and sweep_reversal (WR=38.46% aggregate, BUY_RANGE_NEUTRAL WR=37.57%). This is a regime/zone interpretation concern for future RCEM review. The current assignment of bollinger_reclaim and sweep_reversal as REV/RMR-zone strategies may not reflect their actual performance terrain.

---

### 24.6 Phase Implications

| Phase | Status | Notes |
|---|---|---|
| Phase 3 Nautilus certification | IN_PROGRESS | 3/17 strategies certified (bollinger_reclaim, VWAP candidate rejected, sweep_reversal). 14 remaining. |
| Phase 5A | SOURCE_APPLIED / RUNTIME_VALIDATION_PENDING / NAUTILUS_CHALLENGED | Gate targeted hypothesis not confirmed by Nautilus. No revert authorized. Runtime observation continues. |
| Phase 4A-i | SOURCE_APPLIED / RUNTIME_VALIDATED (summary) | JSONL V1B trigger-record validation still pending first trigger_present=true record. Not blocking Phase 3 continuation. |
| Phase 4A-ii | BLOCKED | Evidence classification review requires ≥50 cross-family ledger events. Not yet accumulated. |
| Phase 4B (exhaustion veto) | BLOCKED | mfi_reversal_assist has 0 live entries. No signal strength distribution to calibrate threshold. |
| Phase 4C (quality soft gate) | BLOCKED | Opportunity Ledger accumulation insufficient (<200 records with trigger_present=true). |
| Phase 6 (EEWP) | BLOCKED | Requires Phase 2 live, Phase 3 substantially complete, Phase 4 runtime sample. None of these exist yet. |
| System status | DEVELOPING | Unchanged. No phase completion changes this status. |

---

### 24.7 Prohibited Conclusions and Forbidden Actions

The following actions are explicitly prohibited by this section. None of these are authorized now or as a consequence of the evidence documented here:

- Delete or deactivate bollinger_reclaim
- Replace bollinger_reclaim with VWAP or any other candidate
- Automatically revert Phase 5A (BOLLINGER_RECLAIM_SELL_TREND_UP_GATE_V1A)
- Add any new strategy to the MT5 factory
- Change sweep_reversal weight from 0.60
- Clear degradation_hint from Nautilus evidence alone
- Promote sweep_reversal to higher weight or CONFIRM role
- Freeze sweep_reversal
- Add a counter-trend gate for sweep_reversal (BUY_TREND_DOWN or SELL_TREND_UP blocking)
- Implement RCEM enforcement changes
- Change council_quality threshold or formula
- Change HIGH_CONVICTION consensus criteria
- Change CRR, DSN, or any pre_ai_filter gate
- Change stop geometry, RR, or execution parameters
- Claim production readiness improvement at any level
- Treat Nautilus evidence as MT5 authorization

---

### 24.8 Recommended Next Actions

1. **Continue Phase 3 certification backlog.** Priority candidates:
   - `trend_momentum` — SCOUT/TREND_JUDGE, degradation_hint, live WR ~42.9%, N=28 at last check; source trigger uses ATR and EMA slope
   - `breakdown_momentum_v1` — live WR=30.0%, EDGE_NOT_CONFIRMED; Nautilus could confirm TREND_DOWN restriction hypothesis
   - `mfi_reversal_assist` — 0 live entries; Nautilus replay would establish baseline exhaustion signal behavior even without live calibration data
   - Short PIML certification matrix update after next 2–3 certifications complete

2. **Continue live Opportunity Ledger accumulation.** Monitor for JSONL V1B trigger records (trigger_present=true). Confirm ledger fields match V1B schema once first record appears.

3. **Monitor Phase 5A runtime.** Observe whether bollinger_reclaim SELL signals are being suppressed in TREND_UP regime after EA reload. The Nautilus-challenged status does not change current runtime behavior — it informs a future operator review.

4. **Separate investigation remains recommended** for the abnormal termination severity=2 pattern (3 crashes observed: pre- and post-patch). Not related to Nautilus findings. Investigate independently.

5. **Do not open new replacement candidate research** for bollinger_reclaim unless explicitly authorized by a separate operator decision. The VWAP candidate is the closed investigation.

---

### 24.9 Evidence Classification

| Claim | Classification |
|---|---|
| bollinger_reclaim clean WR=39.27% (XAUUSD M1, 104 days) | **Verified** — SOURCE_FAITHFUL, N=8,350 |
| Old GCF=F proxy evidence superseded | **Verified** — contradicted as an evidence source; not applicable to XAUUSD certification |
| bollinger_reclaim RANGE era is weakest context | **Verified** — WR=38.29% < TREND_UP 40.01% |
| Phase 5A targeted hypothesis not confirmed | **Verified from Nautilus** — SELL/TREND_UP WR=39.49% > SELL/non-TREND_UP 39.17%; runtime validation still pending |
| Phase 5A source-applied | **Verified** — council_strategies.mqh, compile 0 errors/warnings, binary 2026-05-06 17:11 |
| VWAP candidate rejected | **Verified** — failed all 4 qualification criteria; N=1,850 |
| VWAP BUY_TREND_DOWN anomaly (WR=42.3%, N=253) | **Plausible but unverified** — small N; not replicated in second sample |
| sweep_reversal WR=39.58% (XAUUSD M1/M5, 104 days) | **Verified** — SOURCE_FAITHFUL, N=6,589 |
| Counter-trend sweeps not toxic | **Verified / Strongly supported** — Variant D WR=40.49%, E[R]=+0.0123, N=2,319 |
| Counter-trend exclusion worsens sweep_reversal | **Verified** — Variant B WR=39.01% < Variant A 39.58% |
| BUY_RANGE_NEUTRAL is weakest sweep_reversal segment | **Verified** — WR=37.57%, E[R]=-0.0609, EDGE_NOT_CONFIRMED |
| Live sweep WR=42.9% reflects true edge | **Suspicious** — resolved-only artifact; 33/68 unresolved (48.5%); Nautilus 39.58% is stronger evidence |
| degradation_hint=TRUE unsupported by Nautilus | **Verified as Nautilus-challenged** — LATE WR=39.79% > EARLY 39.45%; not runtime-cleared |
| RANGE_NEUTRAL weak for both BR and SR | **Verified** — BR RANGE WR=38.29%, SR RANGE_NEUTRAL WR=38.46%; consistent cross-strategy finding |
| Any MT5 source change authorized from this section | **Contradicted** — documentation only; no source change authorized |
| Counter-trend gate for sweep_reversal authorized | **Contradicted** — would remove strongest segment; not authorized |

---

### 24.10 Footer

```
SECTION_ID:                      MEAN_RECLAIM_AND_REVERSAL_CERTIFICATION_UPDATE_V1
SECTION_TYPE:                    EVIDENCE_DOCUMENTATION — Nautilus Phase 3 findings only
DECISION_DATE:                   2026-05-07
PIML_BACKUP:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260507_224816
SOURCE_CHANGED:                  NO
COMPILE_RUN:                     NO
LIVE_TRADING:                    NO
MT5_AUTHORITY:                   PRESERVED — sole runtime authority
NAUTILUS_ROLE:                   EVIDENCE_LAB_ONLY
SYSTEM_STATUS:                   DEVELOPING — unchanged
BOLLINGER_RECLAIM_LABEL:         EDGE_WEAK_BUT_RECOVERABLE (negative E[R]; RANGE=EDGE_NOT_CONFIRMED)
BOLLINGER_RECLAIM_GCF_PROXY:     SUPERSEDED — invalidated as evidence source
PHASE_5A_STATUS:                 SOURCE_APPLIED / RUNTIME_VALIDATION_PENDING / NAUTILUS_CHALLENGED
VWAP_CANDIDATE_STATUS:           REJECTED — EDGE_NOT_CONFIRMED; failed all 4 criteria; not in MT5 queue
SWEEP_REVERSAL_LABEL:            EDGE_WEAK_BUT_RECOVERABLE (counter-trend subset positive E[R])
SWEEP_REVERSAL_LIVE_WR:          SUSPICIOUS — resolved-only artifact; Nautilus 39.58% is authoritative
DEGRADATION_HINT_STATUS:         NAUTILUS_CHALLENGED — not runtime-cleared; live runtime must clear
COUNTER_TREND_GATE_AUTHORIZED:   NO — Contradicted by Nautilus evidence
PHASE_3_PROGRESS:                3/17 certified (bollinger_reclaim: WEAK; VWAP: REJECTED; sweep_reversal: WEAK)
PHASE_4A_I_STATUS:               SOURCE_APPLIED — JSONL V1B trigger records pending
PHASE_4A_II_STATUS:              BLOCKED — insufficient cross-family ledger events
PHASE_4B_STATUS:                 BLOCKED — MFI 0 live entries
PHASE_4C_STATUS:                 BLOCKED — Opportunity Ledger insufficient
PHASE_6_STATUS:                  BLOCKED — prerequisites not met
IMPLEMENTATION_FORBIDDEN:        All items listed in §24.7
```

---

# §25 — PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1

**Date:** 2026-05-08  
**Authority:** DOCUMENTATION_ONLY — No MT5 modification. No runtime change. No implementation authorization.  
**Status:** REFERENCE_ARCHITECTURE_ADOPTED — Management formal decision documented.

---

## §25.1 — Management Decision Record

**Formal adoption date:** 2026-05-08

**Decision:**  
PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE (PCEA) is formally adopted as the reference methodology and architecture for organizing strategies and extracting edge inside the MT5/IRREW project.

**Reference statement (verbatim):**

> Family organizes the domain.  
> Playbook owns the executable edge thesis.  
> Causal Chain proves whether the edge is complete.  
> Strategy provides evidence packets.  
> V1 owns permission.  
> Execution Geometry owns survivability.  
> Attribution owns learning.

**Scope:** This is a reference architecture and research/design methodology only.  
It authorizes no runtime change. It authorizes no MT5 source modification. It does not alter any gate, weight, role, posture, or execution behavior. V1 remains permission authority. MT5 remains runtime and execution authority.

---

## §25.2 — Core Architecture Hierarchy

```
Family
  ↓
Playbook
  ↓
Causal Chain
  ↓
Evidence Packets
  ↓
Playbook State
  ↓
V1 / MT5 Consumption (future interface only)
```

---

## §25.3 — Layer Definitions

### Layer 1 — Family

Organizes the trading domain. Does not decide entry. Does not provide edge. Does not own packet logic.

A Family groups Playbooks that share a common market-structure premise.

**Current families (reference):**

| Family ID | Domain Premise |
|---|---|
| TREND_CONTINUATION | Price continues in established directional momentum |
| RANGE_SWEEP_RECLAIM | Price sweeps a boundary, overextends, and reclaims — reversal evidence |
| VOLATILITY_EXPANSION | Price breaks out of compression and expands — continuation evidence |
| EXHAUSTION_FAILURE_MODE | Price shows depletion signals; provides failure-mode context for other families |

Families do not fire triggers. Families do not produce votes. Families are classification containers only.

---

### Layer 2 — Playbook

**The Playbook, not an isolated strategy, is the unit of tradable edge testing.**

A Playbook owns:
- A single executable edge thesis (one causal claim)
- The complete Causal Chain that must be satisfied for that thesis to hold
- The Evidence Packet map (which detectors contribute to which link)
- A defined Playbook State (current evidence completeness status)
- A record of what is accepted, rejected, missing, and contradicted

A Playbook does not own:
- Entry permission (V1 owns permission)
- Execution authority (MT5 owns execution)
- Gate thresholds (council architecture owns gates)
- Weight values (EEWP owns weights, operator authorizes)

**Why Playbook, not Strategy:**  
A strategy tested in isolation measures only whether that single detector is profitable at breakeven across all contexts — an excessively narrow question. The Playbook frames the complete evidence sequence. A strategy that does not individually beat breakeven may still:
- Narrow the entry set to a higher-quality subset
- Eliminate a known failure mode
- Confirm regime appropriateness
- Identify room/geometry quality

These contributions are measurable but require playbook-level comparison, not standalone WR alone.

---

### Layer 3 — Causal Chain

Defines the internal evidence sequence of the Playbook. The Causal Chain is the ordered list of logical conditions that, together, produce the edge thesis.

**Each link has exactly one of four categorical states:**

| Link State | Meaning |
|---|---|
| PRESENT | Evidence for this link exists in current bar context |
| MISSING | No evidence available; link is absent |
| CONTRADICTED | Active counter-evidence exists for this link |
| NOT_APPLICABLE | Link does not apply in current context (e.g., regime gate does not apply to this family) |

**Critical constraint:** The Causal Chain produces only categorical link states. It has no score authority. It does not produce a numeric confidence or probability. A chain with 7/9 links PRESENT does not score higher than 6/9 — both are incomplete chains, and completeness thresholds are defined per-Playbook by a separate, authorized design step.

No Causal Chain computation currently affects any MT5 decision. Causal Chain evaluation is research and attribution only.

---

### Layer 4 — Evidence Packets

Strategies and detectors are classified by their functional contribution to the Playbook's Causal Chain, not by standalone profitability alone.

**Accepted Packet Classes:**

| Class | Function | What it must prove |
|---|---|---|
| ALPHA_TRIGGER_PACKET | Fires the primary trade signal | Standalone EDGE_WEAK_BUT_RECOVERABLE or better; primary entry condition |
| CONFIRMATION_PACKET | Validates the trade direction independently | WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs baseline; N ≥ 50; cross-family required for CRR use |
| FAILURE_MODE_PACKET | Identifies when the playbook premise has already failed | Counter-condition WR ≤ baseline - 2pp; degradation is measurable; N ≥ 15 |
| LOCATION_PACKET | Defines where in the price structure the setup is valid | WR split ≥ +3pp between favorable and unfavorable location bins; N ≥ 20 per bin |
| TIMING_PACKET | Identifies the optimal temporal window within the setup | WR split ≥ +3pp between early and late timing bins |
| ROOM_PACKET | Measures available reward-to-risk space before obstruction | WR or E[R] lift ≥ +3pp or +0.03R for high-room vs low-room subsets |
| STOP_GEOMETRY_PACKET | Validates ATR-based stop placement quality | Valid vs invalid geometry WR split ≥ +3pp; N ≥ 20 per bin (N ≥ 5 invalid required) |
| ATTRIBUTION_PACKET | Records post-trade evidence for learning; no entry contribution | No WR threshold; contributes to opportunity ledger analysis only |
| REJECTED_PACKET | Failed all applicable contribution tests | Documents what was tested, why it failed; retained for audit trail |

**Every packet must have all five fields documented:**

1. **purpose** — what contribution to the causal chain is being tested
2. **measurable contribution rule** — exact numeric threshold for acceptance
3. **rejection rule** — exact condition that produces REJECTED_PACKET classification
4. **layer ownership** — which Causal Chain link this packet serves
5. **no-runtime-authority statement** — explicit: this packet does not authorize MT5 behavior

**Governing rule — usefulness test:**

A strategy/detector is useful to a Playbook only if it proves one or more measurable contributions:

- improves WR (threshold: ≥ +2pp above baseline for CONFIRMATION class)
- improves E[R] (threshold: ≥ +0.04R for CONFIRMATION class; ≥ +0.03R for supporting classes)
- reduces false positives (measurable: subset exclusion reduces loss rate by ≥ 5pp)
- reduces failure modes (measurable: counter-condition WR degradation ≥ 2pp below baseline)
- improves regime separation (measurable: subset WR ≥ +3pp vs rest-of-population)
- improves playbook completion (completes a MISSING link with categorical evidence)
- improves timing quality (WR split ≥ +3pp between timing subsets)
- improves location quality (WR split ≥ +3pp between location subsets)
- improves stop survivability (measurable geometry quality split ≥ +3pp)
- improves attribution clarity (post-trade learning; no entry threshold required)

**If a detector proves none of the above: REJECTED_PACKET. Theoretical usefulness without measurable marginal value is not accepted.**

---

### Layer 5 — Playbook State

The Playbook State describes the current evidence completeness of a Playbook in a given context. These are categorical research/interface design states only.

**Proposed categorical states (design only — not runtime authority):**

| State | Meaning |
|---|---|
| PLAYBOOK_NOT_PRESENT | No required causal links are present in current context |
| PLAYBOOK_FORMING | At least one required link PRESENT; chain not yet complete |
| PLAYBOOK_VALID | All required links PRESENT; no invalidating links CONTRADICTED |
| PLAYBOOK_CONTRADICTED | One or more invalidating links are CONTRADICTED; thesis negated |
| PLAYBOOK_LATE | Required links present but timing indicators show entry window has passed |
| PLAYBOOK_INVALID | Required structural preconditions absent (e.g., wrong zone, wrong regime class) |

**Critical constraints on Playbook State:**

- Playbook States are categorical and research/interface design only.
- They are not scores. They have no numeric encoding.
- They do not authorize entry.
- They do not override V1.
- They do not alter council_quality, HIGH_CONVICTION, CRR, DSN, gates, weights, or posture.
- PLAYBOOK_VALID ≠ trade authorization. A valid playbook may exist without V1 approval.
- A Playbook State may become a structured input to V1 only after a separate design step, explicit operator authorization, bounded source implementation, compile verification, and runtime validation. That design step does not exist yet.

---

### Layer 6 — V1 / MT5 Consumption (future interface only)

V1 is the permission authority. MT5 is the runtime and execution authority.

A future interface design may allow Playbook State to become a structured binary input to V1 (e.g., `playbook_present = true/false` as a prerequisite check). This interface does not currently exist. No design for it has been authorized. It is mentioned here only to clarify the intended future boundary between research and execution layers.

**Current state:** Playbook State has no path into V1, MT5, council_mode_runtime.mqh, council_pre_ai_filter.mqh, or any runtime component. The architecture described in this section is documentation-only with no implementation timeline.

---

## §25.4 — IRREW Firewall Statement

The following is the explicit firewall between Playbook-Centric Architecture and the live MT5/IRREW runtime.

**No Playbook State currently affects:**
- council_quality computation
- HIGH_CONVICTION threshold or evaluation
- CRR (Confirm Role Required) gate logic
- DSN (Diversity Score Normalization) gate logic
- Any other structural gate in council_pre_ai_filter.mqh
- Vote weights in council_strategies.mqh
- Strategy roles or eligibility states
- RCEM regime routing
- Order permission or execution triggers
- AI governor threshold adjustments

**No packet label is runtime authority.**

A Playbook may be:
- valid as research
- valid as attribution evidence
- valid as a design candidate for future bounded implementation

and still not authorized for any MT5 behavior change.

**The separation is absolute and non-negotiable until explicitly broken by an authorized, operator-approved, bounded Codex task with compile verification and runtime validation.**

---

## §25.5 — First Official Playbook Registry Entry

**Registry entry — RANGE_BOUNDARY_SWEEP_RECLAIM**

```
PLAYBOOK_ID:            RANGE_BOUNDARY_SWEEP_RECLAIM
FAMILY:                 RANGE_SWEEP_RECLAIM
PLAYBOOK_NAME:          Range Boundary Sweep and Reclaim
VERSION:                V1 (design / evidence phase)
REGISTRY_DATE:          2026-05-08
```

**Thesis statement:**  
When price is at or near a range/reversal boundary (as defined by Bollinger Band envelope), sweeps liquidity beyond that boundary, and reclaims back inside the band, a mean-reversion trade is available. The thesis is strongest when MFI confirms the same direction and no failure-mode contradiction is present.

**Causal Chain (ordered):**

| Link # | Link Name | Description | Required? |
|---|---|---|---|
| 1 | Regime / Zone Context | M5 regime allows reversal/range mean-reversion trade (not TC/BREAKOUT hostile) | REQUIRED |
| 2 | Boundary Location | Price is at or beyond the Bollinger Band boundary (bb_lower or bb_upper touched) | REQUIRED |
| 3 | Liquidity Sweep | Price extends beyond prior bar's extreme (new low below prior low for BUY; new high above prior high for SELL) | OPTIONAL (strengthens thesis) |
| 4 | Reclaim | Trigger candle closes back inside the band (close > bb_lower for BUY; close < bb_upper for SELL) | REQUIRED |
| 5 | MFI Confirmation | MFI moving in same direction and within mid-range (not overbought/oversold) on trigger candle | OPTIONAL (confirmation) |
| 6 | No Failure-Mode Contradiction | MFI not moving in opposite direction | INVALIDATING (if CONTRADICTED → PLAYBOOK_CONTRADICTED) |
| 7 | Room to Target / Mean | BB midline is at least 1R beyond entry (room_to_mean_r ≥ 1.0) | OPTIONAL (quality filter) |
| 8 | Stop Geometry Valid | ATR-based stop distance < 80% of current band width | REQUIRED |
| 9 | Outcome Attribution | Post-trade: was the playbook premise validated by price behavior? | ATTRIBUTION (no entry role) |

**Required links:** 1, 2, 4, 8  
**Optional links:** 3, 5, 7  
**Invalidating links:** 6  
**Attribution links:** 9

**Evidence Packet Map:**

| Detector / Field | Packet Role | Packet Status | Acceptance Rule | Rejection Rule |
|---|---|---|---|---|
| sweep_reversal | ALPHA_TRIGGER_PACKET (Links 2, 3, 4) | CANDIDATE — evidence-grade | Standalone EDGE_WEAK_BUT_RECOVERABLE; triggers Links 2+3+4 simultaneously | If standalone WR < 35% for N ≥ 30: REJECTED_PACKET |
| mfi_reversal_assist (same dir) | CONFIRMATION_PACKET candidate (Link 5) | PROMISING — below threshold | WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs SR baseline; N ≥ 50 | V1 result: WR_lift=+1.25pp, E[R]_lift=+0.031R — BELOW THRESHOLD; currently REJECTED_PACKET |
| mfi_reversal_assist (counter dir) | FAILURE_MODE_PACKET candidate (Link 6) | ACCEPTED_CANDIDATE — meaningful signal | Counter-condition WR ≤ baseline - 2pp | V1 result: WR=34.59% vs baseline 39.58% (degradation 4.99pp) — threshold cleared; future bounded pilot required before formal acceptance |
| bollinger_reclaim | CONFIRMATION_PACKET / RECLAIM_PACKET candidate (Link 4) | WEAK — rejected in current pilot | Sweep premium ≥ +2pp WR vs BR-without-sweep | V1 result: lift=+1.39pp — BELOW THRESHOLD; currently REJECTED_PACKET within this playbook |
| bb_pct | LOCATION_PACKET candidate (Link 2 quality) | REJECTED — hypothesis inverted | Low bb_pct (shallow reclaim) WR - high bb_pct (deep reclaim) WR ≥ +3pp | V1 result: shallow WR=39.1% vs deep WR=40.6% — inverted; REJECTED_PACKET as originally hypothesized |
| bb_pct (inverted) | Future LOCATION_PACKET hypothesis | NOT_TESTED — future candidate only | Deep reclaim (bb_pct > 0.30) WR - shallow reclaim (bb_pct < 0.15) WR ≥ +3pp | Must be pre-defined in a new pilot before testing |
| room_to_mean_r | ROOM_PACKET candidate (Link 7) | REJECTED — no signal | room_to_mean_r > 1.5 vs ≤ 1.5 WR diff ≥ +3pp | V1 result: diff = -0.0008 — no signal; REJECTED_PACKET |
| stop_geometry_valid | STOP_GEOMETRY_PACKET / ATTRIBUTION_PACKET (Link 8) | TRIVIAL — not decision-useful | Valid vs invalid WR split ≥ +3pp with N ≥ 5 invalid | V1 result: N_invalid=7 (99.9% valid); statistically trivial; ATTRIBUTION_PACKET only |

**Current Playbook State (evidence phase):**

```
PLAYBOOK_STATE:              PLAYBOOK_FORMING
LINKS_PRESENT:               1 (regime proxy), 2 (BB boundary), 3 (sweep), 4 (reclaim), 8 (geometry mostly valid)
LINKS_MISSING:               5 (MFI confirm below threshold), 7 (room packet no signal)
LINKS_CONTRADICTED:          None currently
INVALIDATING_LINKS_ACTIVE:   6 — failure mode signal identified but not yet formally implemented
EVIDENCE_QUALITY:            Directionally promising; composite V1 E[R] flips positive; below formal packet acceptance
RESEARCH_STATUS:             ACTIVE — Phase 3 pilot complete; replication or threshold adjustment needed
IMPLEMENTATION_STATUS:       NOT_AUTHORIZED
RUNTIME_AUTHORITY_STATUS:    NONE — no MT5 behavior change authorized
```

**Missing links (what this playbook needs before PLAYBOOK_VALID):**

1. CONFIRMATION_PACKET (Link 5): MFI same-dir confirm needs to clear +2pp WR / +0.04R thresholds in a new pre-defined pilot. Current evidence is below threshold (1.25pp / 0.031R). Potential paths: tighter MFI threshold (e.g., 60/40), regime-conditional MFI confirm, or extended sample.
2. ROOM_PACKET (Link 7): Current room_to_mean_r shows no signal. Alternative room measure (e.g., distance from entry to recent swing high/low rather than BB midline) may be more discriminating.

**Next allowed action:** Define a new pre-defined pilot targeting the CONFIRMATION_PACKET gap (MFI confirm threshold tightening or alternative confirm detector). Requires operator authorization and explicit pre-definition of causal claim before testing.

**Forbidden actions:**

- Do not require MFI as a runtime entry condition for sweep_reversal
- Do not gate sweep_reversal on MFI at MT5 source level
- Do not promote MFI to runtime veto based on current evidence
- Do not delete bollinger_reclaim from the MT5 council
- Do not revert Phase 5A automatically
- Do not implement any Playbook State computation in MT5 source
- Do not score-encode any Causal Chain link

---

## §25.6 — Playbook Registry Design Schema

This schema defines the documentation structure for all future Playbook registry entries in PIML. No JSON file is created. No source registry is implemented. This is documentation-design only.

**Required fields for each PIML playbook entry:**

```
PLAYBOOK_ID:                Unique identifier (SCREAMING_SNAKE_CASE)
FAMILY:                     Parent family name
PLAYBOOK_NAME:              Human-readable name
VERSION:                    Version label (V1, V2, etc.)
REGISTRY_DATE:              Date first registered in PIML (YYYY-MM-DD)
THESIS_STATEMENT:           One paragraph. The complete edge claim in plain language.

CAUSAL_CHAIN_LINKS:
  - link_number:            Ordered integer
    link_name:              Short label
    description:            What market condition this link represents
    link_type:              REQUIRED / OPTIONAL / INVALIDATING / ATTRIBUTION

REQUIRED_LINKS:             List of link numbers that must be PRESENT for PLAYBOOK_VALID
OPTIONAL_LINKS:             List of link numbers that improve but do not gate the playbook
INVALIDATING_LINKS:         List of link numbers that, if CONTRADICTED, force PLAYBOOK_CONTRADICTED

EVIDENCE_PACKETS:
  - packet_id:              Unique identifier within this playbook
    detector:               Strategy ID or computed field name
    packet_role:            One of the 9 accepted packet classes
    packet_status:          CANDIDATE / ACCEPTED / REJECTED_PACKET / TRIVIAL / NOT_TESTED
    causal_chain_link:      Link number(s) this packet serves
    purpose:                What contribution is being tested
    acceptance_rule:        Exact numeric threshold for acceptance
    rejection_rule:         Exact condition for REJECTED_PACKET
    current_evidence:       Summary of latest Nautilus result (N, WR, lift, label)
    runtime_authority:      Always: "NONE — does not authorize MT5 behavior"

PLAYBOOK_STATE:             One of: PLAYBOOK_NOT_PRESENT / PLAYBOOK_FORMING / PLAYBOOK_VALID /
                            PLAYBOOK_CONTRADICTED / PLAYBOOK_LATE / PLAYBOOK_INVALID
LINKS_PRESENT:              List of link numbers currently PRESENT
LINKS_MISSING:              List of link numbers currently MISSING
LINKS_CONTRADICTED:         List of link numbers currently CONTRADICTED

CURRENT_EVIDENCE_SUMMARY:   Paragraph summarizing latest pilot results
MISSING_LINKS:              What evidence is needed to advance state
CONTRADICTED_LINKS:         Active contradictions and their source

RESEARCH_STATUS:            INACTIVE / ACTIVE / PENDING_PILOT / PILOT_COMPLETE / UNDER_REVIEW
IMPLEMENTATION_STATUS:      NOT_AUTHORIZED / DESIGN_ONLY / PENDING_OPERATOR / AUTHORIZED / APPLIED
RUNTIME_AUTHORITY_STATUS:   NONE (until explicitly changed by authorized Codex task with operator sign-off)

NEXT_ALLOWED_ACTION:        Specific, bounded next research or design step
FORBIDDEN_ACTIONS:          Explicit list of what must not be done based on current evidence

LAST_UPDATED:               Date of most recent PIML update
SUPERSEDES:                 Prior registry entry this replaces (if any)
```

**Playbook State transition rules (documentation only):**

```
PLAYBOOK_NOT_PRESENT → PLAYBOOK_FORMING:    At least one REQUIRED link becomes PRESENT
PLAYBOOK_FORMING → PLAYBOOK_VALID:          All REQUIRED links PRESENT; no INVALIDATING links CONTRADICTED
PLAYBOOK_VALID → PLAYBOOK_CONTRADICTED:     Any INVALIDATING link transitions to CONTRADICTED
PLAYBOOK_VALID → PLAYBOOK_LATE:             TIMING_PACKET evidence indicates window has passed
PLAYBOOK_CONTRADICTED → PLAYBOOK_FORMING:   Contradiction resolves; INVALIDATING link no longer CONTRADICTED
Any state → PLAYBOOK_INVALID:               Structural preconditions absent (wrong zone/regime class)
```

State transitions are research classifications only. No transition triggers any runtime behavior.

---

## §25.7 — COMPOSITE_REVERSAL_RECLAIM_PLAYBOOK_ANALYSIS_V1 Summary

**Source:** Nautilus Phase 3 composite pilot, run 2026-05-08  
**Script:** composite_reversal_reclaim_playbook_v1.py  
**Data:** XAUUSD M1 100,466 bars (2026-01-23 → 2026-05-07); M5 34,652 bars; GCF proxy NOT USED  
**Authority:** EVIDENCE_ONLY — no MT5 modification; lab only

### Standalone Baselines

| Strategy | N | WR | E[R] | Label |
|---|---|---|---|---|
| sweep_reversal (SR) | 6,589 | 0.3958 | -0.0105R | EDGE_WEAK_BUT_RECOVERABLE |
| bollinger_reclaim (BR) | 8,350 | 0.3927 | -0.0183R | EDGE_WEAK_BUT_RECOVERABLE |
| mfi_reversal_assist (MFI) | 6,191 | 0.3957 | -0.0107R | EDGE_WEAK_BUT_RECOVERABLE |

All three baselines consistent with prior individual certifications. ✓

### Composite Variants

| Variant | N | WR | E[R] | Label |
|---|---|---|---|---|
| V1: SR + MFI same direction | 676 | 0.4083 | +0.0207R | EDGE_WEAK_BUT_RECOVERABLE |
| V2: BR + MFI same direction | 1,023 | 0.4057 | +0.0142R | EDGE_WEAK_BUT_RECOVERABLE |
| V3: SR only (sweep premium ref) | 6,589 | 0.3958 | -0.0105R | EDGE_WEAK_BUT_RECOVERABLE |
| V3: BR without sweep (no SR) | 3,027 | 0.3819 | -0.0453R | EDGE_WEAK_BUT_RECOVERABLE |
| V5: SR + MFI counter-direction | 159 | 0.3459 | -0.1352R | EDGE_NOT_CONFIRMED |

### V7 Regime Splits — V1 (SR+MFI same direction)

| Regime | N | WR | E[R] |
|---|---|---|---|
| TREND_UP | 237 | 0.4262 | +0.0654R |
| TREND_DOWN | 194 | 0.3918 | -0.0206R |
| RANGE_NEUTRAL | 245 | 0.4041 | +0.0102R |

### V9 RANGE_NEUTRAL Isolation

| Variant | N | WR | E[R] |
|---|---|---|---|
| SR alone (RANGE_NEUTRAL) | 2,319 | 0.3846 | -0.0384R |
| V1 SR+MFI (RANGE_NEUTRAL) | 245 | 0.4041 | +0.0102R |
| V2 BR+MFI (RANGE_NEUTRAL) | 353 | 0.4164 | +0.0411R |

MFI filter materially improves RANGE_NEUTRAL E[R] (SR_RANGE: -0.038R → V1_RANGE: +0.010R → V2_RANGE: +0.041R). This addresses the cross-strategy RANGE_NEUTRAL weakness identified in all three individual certifications.

### Packet Classification Results

| Packet | Type | Verdict | Key Evidence |
|---|---|---|---|
| P1: SR as ALPHA | ALPHA_TRIGGER | **ACCEPTED** | WR=39.58%, E[R]=-0.0105R, N=6589 |
| P2: BR confirm for SR (sweep premium) | CONFIRMATION | **REJECTED** | lift=+1.39pp (threshold 2pp) |
| P3: MFI same-dir confirm for SR | CONFIRMATION | **REJECTED** | WR_lift=+1.25pp, E[R]_lift=+0.031R (thresholds: 2pp / 0.04R) — both below threshold |
| P4: MFI counter-dir failure mode | FAILURE_MODE | **ACCEPTED** | degradation=4.99pp (V5 WR 34.59% vs baseline 39.58%); N=159 |
| P5: bb_pct location | LOCATION | **REJECTED** | Hypothesis inverted: deep reclaims (bb_pct>0.30) WR=40.6% > shallow WR=39.1%; original hypothesis wrong direction |
| P6: room_to_mean location | ROOM | **REJECTED** | diff=-0.0008; no signal |
| P7: stop_geometry valid | ATTRIBUTION | **ACCEPTED (trivial)** | N_invalid=7 (99.9% valid); result is noise, not decision-useful |

### Key Findings

1. **Composite directionally positive but below formal threshold:** V1 (SR+MFI) flips E[R] from -0.011R to +0.021R. Both the WR lift (+1.25pp) and E[R] lift (+0.031R) are below the pre-defined CONFIRMATION_PACKET acceptance thresholds (+2pp / +0.04R). The hypothesis remains POST_HOC_DISCOVERY_PENDING_REPLICATION, not CONFIRMED_PACKET_CANDIDATE.

2. **Failure mode signal is real:** Counter-direction MFI degrades SR WR by 4.99pp (V5 WR=34.59%). This is the strongest and most actionable finding. P4 is accepted as a candidate. A new pre-defined pilot at tighter MFI thresholds is the logical next step.

3. **Sweep premium is real but sub-threshold:** SR (sweep) outperforms BR-only (no sweep) by +1.39pp WR. Below the +2pp formal threshold. Directionally confirmed, formally not yet graduated.

4. **bb_pct hypothesis inverted:** The original hypothesis (shallow reclaims = better quality) was wrong. Deeper reclaims (price closes more firmly back inside the band) perform better. This inverted finding is a new hypothesis for a future pre-defined pilot only — it must not be tested retroactively.

5. **RANGE_NEUTRAL cross-strategy weakness addressed by composite:** SR, BR, and MFI individually all show RANGE_NEUTRAL as weakest regime. The composite filter (SR+MFI or BR+MFI) largely eliminates this weakness. V2_RANGE E[R]=+0.041R vs standalone E[R]≈-0.038R. The improvement is material but does not authorize any implementation.

6. **TREND_UP is strongest composite subset:** V1_TREND_UP WR=42.6%, E[R]=+0.065R (N=237). This is the highest composite performance observed in any regime split. Not authorization for TREND_UP filtering.

### POST_HOC_DISCOVERY Status

The SR+MFI co-presence observation was first identified in prior Nautilus certification Variants E/F and labelled POST_HOC_DISCOVERY. This pilot was the first pre-defined test of that hypothesis. V1 result: directionally supported, formally below threshold.

**New status:** `POST_HOC_DISCOVERY_PARTIALLY_VALIDATED` — composite improves E[R] but misses acceptance thresholds; not graduated to CONFIRMED_PACKET_CANDIDATE; requires new pre-defined pilot with tighter parameters or larger sample.

### What the Composite Pilot Result Does NOT Authorize

- sweep_reversal must not be modified to require MFI
- mfi_reversal_assist must not become a runtime gate or veto for sweep_reversal
- bollinger_reclaim must not be deleted from the council
- No weight changes for any of the three strategies
- No role changes for any of the three strategies
- Phase 5A must not be reverted based on composite results
- No new gates, scores, or council_quality changes
- No RCEM changes

---

## §25.8 — Phase and Roadmap Implications

**Architecture status:**  
PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE is now the reference model. PIML will track Playbooks and Packets as research/design classifications going forward. All future Nautilus certification work should be framed within a pre-defined Playbook with a stated causal claim and packet hypotheses before testing.

**Composite methodology:**  
Composite methodology (COMPOSITE_EDGE_METHODOLOGY_V1) remains research-only. The RBSR pilot is the first completed composite analysis. No runtime implementation is justified from current results.

**IRREW roadmap phase statuses (unchanged):**

| Phase | Status | Reason |
|---|---|---|
| Phase 3 (Nautilus certification backlog) | ACTIVE — 3/17 complete | Continue: trend_momentum, breakdown_momentum_v1 are priority |
| Phase 4A-i (JSONL V1B trigger records) | APPLIED — validation pending | Monitor for first trigger_present records |
| Phase 4A-ii (cross-family CRR upgrade) | BLOCKED | Insufficient cross-family ledger events |
| Phase 4B (exhaustion veto) | BLOCKED | MFI 0 live entries; veto threshold uncalibrated |
| Phase 4C (quality soft gate) | BLOCKED | Opportunity Ledger insufficient |
| Phase 5A (bollinger_reclaim SELL/TREND_UP gate) | APPLIED — NAUTILUS_CHALLENGED | Runtime validation pending; do not revert automatically |
| Phase 6 (EEWP weight progression) | BLOCKED | All prerequisites unmet |
| Phase 7 (runtime validation ongoing) | ACTIVE | 30-50 decision window per change |
| Phase 8 (promotion/demotion governance) | BLOCKED | Phase 4 incomplete |

**System status:** DEVELOPING — unchanged. No phase completion or playbook pilot changes this status.

**Production readiness:** Unchanged. IRREW is a 8–12 week roadmap. Completing the composite pilot does not advance production readiness. Status remains DEVELOPING until all Phase 3 certifications complete, Phase 4 live, and 200+ trades accumulated under IRREW architecture.

---

## §25.9 — Forbidden Conclusions (Explicit)

The following conclusions must not be drawn from any evidence documented in this section or the composite pilot:

| Claim | Status |
|---|---|
| Any MT5 source change is authorized from composite pilot results | **FORBIDDEN** |
| Any playbook state should be consumed by MT5 now | **FORBIDDEN** |
| Any packet should become a gate in council_pre_ai_filter.mqh | **FORBIDDEN** |
| Any packet should become a score input to council_quality | **FORBIDDEN** |
| HIGH_CONVICTION threshold should change | **FORBIDDEN** |
| CRR gate logic should change based on composite pilot | **FORBIDDEN** |
| DSN gate logic should change | **FORBIDDEN** |
| sweep_reversal vote_weight should change | **FORBIDDEN** |
| mfi_reversal_assist vote_weight should change | **FORBIDDEN** |
| bollinger_reclaim vote_weight should change | **FORBIDDEN** |
| Strategy roles (SCOUT/CONFIRM/EXHAUSTION_JUDGE) should change | **FORBIDDEN** |
| sweep_reversal should require MFI as entry condition | **FORBIDDEN** |
| mfi_reversal_assist should become runtime veto for sweep_reversal | **FORBIDDEN** |
| bollinger_reclaim should be deleted from the council | **FORBIDDEN** |
| Phase 5A should be automatically reverted due to composite results | **FORBIDDEN** |
| RCEM should be enforced based on composite pilot | **FORBIDDEN** |
| Production readiness improves based on composite pilot | **FORBIDDEN** |
| POST_HOC_DISCOVERY finding graduates to CONFIRMED_PACKET without new pre-defined pilot | **FORBIDDEN** |
| Inverted bb_pct finding should be tested retroactively on same data | **FORBIDDEN** |

---

## §25.10 — Footer

```
SECTION:                         25
SECTION_ID:                      PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1
SECTION_DATE:                    2026-05-08
ARCHITECTURE_ADOPTED:            YES — management formal decision
ARCHITECTURE_STATUS:             REFERENCE_ARCHITECTURE — documentation only; no runtime authority
COMPOSITE_PILOT_RESULT:          PARTIALLY_VALIDATED — below formal thresholds; not graduated
PLAYBOOK_REGISTRY_STATUS:        FIRST_ENTRY_DEFINED — RANGE_BOUNDARY_SWEEP_RECLAIM (FORMING)
PLAYBOOK_STATE:                  PLAYBOOK_FORMING — required links present; confirmation packet missing
PACKET_ACCEPTED:                 P1_SR_ALPHA, P4_MFI_FAILURE_MODE (candidate), P7_trivial
PACKET_REJECTED:                 P2_BR_CONFIRM, P3_MFI_CONFIRM, P5_BBPCT, P6_ROOM_TO_MEAN
MT5_MODIFIED:                    NO
SOURCE_CHANGED:                  NO
RUNTIME_CHANGED:                 NO
NAUTILUS_ARTIFACTS_CHANGED:      NO
SYSTEM_STATUS:                   DEVELOPING — unchanged
PHASE_3_PROGRESS:                3/17 certified (bollinger_reclaim, VWAP, sweep_reversal)
PHASE_4A_II_STATUS:              BLOCKED
PHASE_4B_STATUS:                 BLOCKED
PHASE_4C_STATUS:                 BLOCKED
PHASE_6_STATUS:                  BLOCKED
NEXT_ALLOWED_ACTION:             Phase 3 continuation (trend_momentum, breakdown_momentum_v1); new pre-defined MFI pilot design
IMPLEMENTATION_FORBIDDEN:        All items listed in §25.9
```

---

# §26 — BREAKDOWN_MOMENTUM_PHASE3_CERTIFICATION_V1

**Date:** 2026-05-08  
**Authority:** EVIDENCE_ONLY — No MT5 modification. No runtime change. No implementation authorization.  
**Status:** CERTIFICATION_COMPLETE — REJECTED_PACKET in intended role; no active playbook assignment.

---

## §26.1 — Certification Summary

**Strategy:** `breakdown_momentum_v1`  
**Cert date:** 2026-05-08  
**Overall label:** `EDGE_WEAK_BUT_RECOVERABLE` in aggregate; `EDGE_NOT_CONFIRMED` in intended TC/TREND_DOWN context  
**Replication class:** PARTIAL_REPLICATION (trigger and dual-bear gate SOURCE_FAITHFUL; TC zone gate PROXY)  
**Data:** Clean XAUUSD M1/M5 only. M1 rows: 100,466 (2026-01-23 → 2026-05-07). M5 rows: 34,652 (2025-11-07 → 2026-05-07). GCF proxy NOT USED.  
**Phase 3 count after this cert:** 4/17

---

## §26.2 — Source Identity

| Field | Value |
|---|---|
| strategy_id | breakdown_momentum_v1 |
| family | TREND_CONTINUATION |
| role | COUNCIL_ROLE_CONFIRM |
| vote_weight | 0.68 |
| direction_bias | SELL_ONLY — hardcoded; no BUY signals |
| active zone | COUNCIL_ZONE_TREND_CONTINUATION only (hardcoded hard gate) |
| TC eligibility | REDUCED (×0.75 — CONFIRM role in TC zone) |
| M1 prerequisite | RT_M1TrendBear: M1 EMA20 < EMA50 AND M1_close[1] ≤ M1_EMA20[1] |
| M5 prerequisite | RT_M5TrendBear: M5 EMA20 < EMA50 AND M5_close[1] ≤ M5_EMA20[1] |
| Dual-TF gate | BOTH M1Bear AND M5Bear required (L1843, council_strategies.mqh) |
| Candle condition | Bearish (close < open) |
| Body threshold | body / ATR14(M1, shift=1) ≥ 0.60 |
| Breakdown condition | close[1] < min(low[2], low[3], low[4]) |
| Quality formula | Clamp01(0.62 + min(0.28, bodyRatio − 0.60)) → range [0.62, 0.90] |
| Score formula | Clamp01(0.58 × quality + 0.28 × zone_align + 0.14 × env_fit) |
| Degradation hint | NONE found in source |
| Freeze note | NONE — do not confuse with momentum_breakout_cont_v1, which is a separate frozen strategy |

**Proxy gap:** The TC zone hard gate (`env.zone_type != COUNCIL_ZONE_TREND_CONTINUATION`) cannot be reproduced from OHLCV alone. Variant C uses M5 TREND_DOWN (EMA-spread proxy) as the closest available approximation.

---

## §26.3 — Certification Results

### Variant A — Source-Faithful Baseline

Includes: trigger detection + M1TrendBear + M5TrendBear dual gate.  
Excludes: TC zone hard gate (proxy gap).

| Metric | Value |
|---|---|
| Total triggers (dual-bear gate) | 3,230 |
| Closed trades | 2,340 |
| Open trades | 0 |
| WR | 38.08% |
| E[R] | -0.048R |
| Profit factor | 0.9224 |
| Max consec losses | 15 |
| Avg MAE_R | 0.9961 |
| Avg MFE_R | 1.1145 |
| Avg bars held | 4.6 |
| Label | EDGE_WEAK_BUT_RECOVERABLE |
| Confidence | SUFFICIENT |
| Fire rate | 3,230 triggers / 74 trading days ≈ **43.6 triggers/day** — extremely high |

### Variant B — M5 Regime Split (Variant A population)

| Regime | N | WR | E[R] | Label | Confidence |
|---|---|---|---|---|---|
| TREND_DOWN | 1,558 | 37.36% | -0.0661R | **EDGE_NOT_CONFIRMED** | SUFFICIENT |
| RANGE_NEUTRAL | 782 | 39.51% | -0.0121R | EDGE_WEAK_BUT_RECOVERABLE | SUFFICIENT |
| TREND_UP | 0 | — | — | DATA_INSUFFICIENT | INSUFFICIENT |

**TREND_UP has zero trades by construction.** The dual-bear gate (M1Bear AND M5Bear) structurally excludes all bars where M5 EMA20 > EMA50, which is the defining condition of M5 TREND_UP. This is architecturally correct per source.

**Critical regime inversion:** TREND_DOWN is the weakest subset, not the strongest. RANGE_NEUTRAL outperforms TREND_DOWN by +2.15pp WR and +0.054R E[R]. The strategy performs *worse* in its intended bearish continuation context than in ranging conditions.

### Variant C — Intended TC Zone Proxy (M5 TREND_DOWN)

Restricts Variant A to M5 TREND_DOWN bars as proxy for COUNCIL_ZONE_TREND_CONTINUATION.

| Metric | Value |
|---|---|
| N | 1,578 |
| WR | 37.52% |
| E[R] | -0.062R |
| Label | **EDGE_NOT_CONFIRMED** |
| Confidence | SUFFICIENT |

breakdown_momentum_v1 **fails in its own intended operating context.** The TC zone proxy result is worse than the unrestricted baseline.

### Variant D — Trigger-Only Baseline (No Dual-Bear Gate)

Tests gate contribution by removing M1+M5 bear alignment requirement.

| | Variant A (with gate) | Variant D (no gate) |
|---|---|---|
| N | 2,340 | 7,191 |
| WR | 38.08% | 38.56% |
| E[R] | -0.0481R | -0.0359R |
| Label | EDGE_WEAK_BUT_RECOVERABLE | EDGE_WEAK_BUT_RECOVERABLE |
| Gate WR premium | **-0.48pp** (gate hurts) | — |

The dual-bear alignment gate delivers **negative marginal value** in Nautilus evidence: removing it improves WR by +0.48pp and E[R] by +0.012R. This is Nautilus evidence only — it does not authorize removing the gate from MT5 source.

### Variant E / F — Overlay / Co-presence (Trend Momentum and Sweep Reversal)

**Both overlay variants are uninformative due to absence of a control group.**

breakdown_momentum_v1 fired on **74 out of 74 trading days** in the dataset. Every TM trade and every SR BUY trade occurred on a day when BDM also fired. The "without BDM" control group has N=0. WR delta is undefined and cannot be computed.

This high fire rate is itself a material architectural finding: a CONFIRM-role strategy that fires 43.6 times per day on every trading day cannot be selective. It cannot provide meaningful directional discrimination or serve as a discriminating CONFIRMATION_PACKET or FAILURE_MODE_PACKET.

### Variant G — Cost / Slippage Stress

| | Base (12pt) | Stress (22pt) | Delta |
|---|---|---|---|
| WR | 38.08% | 36.57% | -1.51pp |
| E[R] | -0.0481R | -0.0858R | — |
| Label | EDGE_WEAK_BUT_RECOVERABLE | **EDGE_NOT_CONFIRMED** | — |

Moderate cost sensitivity. Stress degrades label to EDGE_NOT_CONFIRMED. No robustness advantage over baseline.

### Variant H — Recency / Degradation Split

**Degradation split (60/40 at 2026-03-26):**

| Period | N | WR | E[R] | Label |
|---|---|---|---|---|
| EARLY (< 2026-03-26) | 1,416 | 40.18% | +0.0046R | EDGE_WEAK_BUT_RECOVERABLE |
| LATE (≥ 2026-03-26) | 924 | **34.85%** | **-0.1288R** | **EDGE_REJECTED** |

**Monthly breakdown:**

| Month | N | WR | E[R] | Label |
|---|---|---|---|---|
| 2026-01 | 158 | 48.10% | +0.2025R | EDGE_SUPPORTED |
| 2026-02 | 548 | 35.04% | -0.1241R | EDGE_NOT_CONFIRMED |
| 2026-03 | 812 | 41.63% | +0.0406R | EDGE_WEAK_BUT_RECOVERABLE |
| 2026-04 | 684 | 34.80% | -0.1301R | **EDGE_REJECTED** |
| 2026-05 | 138 | 34.06% | -0.1486R | **EDGE_REJECTED** |

**Severe temporal instability.** The monthly pattern alternates between reasonable and poor performance with no stable underlying trend. January 2026 showed exceptional results (N=158 only, likely noise-influenced). The last two full months (April, May 2026) are both EDGE_REJECTED. The LATE period is EDGE_REJECTED. Any future assumption of continued edge must be supported by fresh evidence, not extrapolation from earlier months.

**Body quality split:**  
High quality candles (bodyRatio ≥ 0.80): WR=37.91%, E[R]=-0.052R (N=1,857)  
Low quality candles (bodyRatio < 0.80): WR=38.72%, E[R]=-0.032R (N=483)  
The quality metric does not predict better outcomes. Higher body ratio does not produce better trades.

---

## §26.4 — Playbook-Centric Packet Classification

Classified under PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1 (§25).

### P1 — ALPHA_TRIGGER_PACKET (Intended TC/TREND_DOWN Context)

**Verdict: REJECTED**

| Field | Value |
|---|---|
| Rule | Intended context WR ≥ 38% AND E[R] ≥ -0.02R AND N ≥ 15 |
| Intended context WR | 37.52% |
| Intended context E[R] | -0.062R |
| N | 1,578 (SUFFICIENT) |
| Rejection reason | E[R] = -0.062R is well below the -0.02R floor; WR below 38%; no positive standalone condition confirmed |
| Runtime authority | NONE |

### P2 — ALPHA_TRIGGER_PACKET (Unrestricted Variant A)

**Verdict: REJECTED**

| Field | Value |
|---|---|
| Rule | Unrestricted WR ≥ 38% AND E[R] ≥ -0.02R AND N ≥ 15 |
| WR | 38.08% |
| E[R] | -0.048R |
| N | 2,340 (SUFFICIENT) |
| Rejection reason | E[R] = -0.048R below -0.02R threshold; recent deterioration to EDGE_REJECTED; no stable edge |
| Runtime authority | NONE |

### P3 — CONFIRMATION_PACKET

**Verdict: REJECTED**

| Field | Value |
|---|---|
| Rule | WR lift ≥ +2pp AND E[R] lift ≥ +0.04R vs baseline; N ≥ 50 |
| Rejection reason | Fire rate of 43.6 triggers/day produces no control group; co-presence uninformative; marginal contribution unmeasurable; signal is too ubiquitous to confirm anything |
| Runtime authority | NONE |

### P4 — FAILURE_MODE_PACKET

**Verdict: DATA_INSUFFICIENT / UNINFORMATIVE**

| Field | Value |
|---|---|
| Rule | Warning-present WR ≤ baseline - 3pp; N ≥ 15 in both groups |
| Reason | Fires on 74/74 trading days; control group (no-BDM days) N=0; cannot isolate failure-mode-present vs failure-mode-absent conditions |
| Note | This is not DATA_INSUFFICIENT due to low N — it is structurally uninformative due to near-total market coverage |
| Runtime authority | NONE |

### P5 — RESEARCH_ONLY_PACKET (RANGE_NEUTRAL Hypothesis)

**Verdict: CONDITIONAL — not authorized for testing without new operator-approved bounded pilot**

| Field | Value |
|---|---|
| Hypothesis | Bearish breakdown candle (body ≥ 0.60 ATR, close below 3-bar low) in ranging M5 context may belong to a different playbook — not trend continuation, possibly range mean-reversion sell |
| Current evidence | RANGE_NEUTRAL WR=39.51%, E[R]=-0.012R — better than TREND_DOWN but still sub-breakeven E[R] |
| Status | Unexpected finding from pre-defined regime split; not retroactively cherry-picked |
| Requirement before testing | Operator must explicitly open a bounded pilot with a pre-defined causal claim; not authorized to test retroactively on existing data |
| Playbook assignment | NONE — do not assign to RANGE_BOUNDARY_SWEEP_RECLAIM or any existing playbook |
| Runtime authority | NONE |

### Current Playbook Assignment

**NONE.**  
breakdown_momentum_v1 is not assigned to any active playbook as an accepted packet under current evidence.  
Do not assign it to RANGE_BOUNDARY_SWEEP_RECLAIM (wrong direction — SELL_ONLY cannot serve a reversal/reclaim BUY thesis).  
Do not assign it as an accepted Trend Continuation packet (REJECTED per P1/P2).

---

## §26.5 — Architectural Interpretation

1. **TC confirm role failure:** breakdown_momentum_v1 was designed as a CONFIRM-role strategy to validate bearish momentum continuation in TC zone. It fails this role: its intended TREND_DOWN context is its weakest subset (WR=37.52%, E[R]=-0.062R, EDGE_NOT_CONFIRMED).

2. **Regime inversion:** The strategy performs measurably better in RANGE_NEUTRAL conditions than in TREND_DOWN conditions. This is counter to its design intent and indicates the trigger logic may be detecting something other than pure bearish continuation momentum.

3. **Gate counterproductivity:** The dual M1+M5 bearish alignment gate, which was designed to ensure the trigger fires only in fully bearish aligned conditions, actually degrades performance when applied (-0.48pp WR vs ungated). The gate restricts to a context that performs worse than the general case. This is Nautilus evidence only; the gate must not be removed from MT5 without a separate authorized design decision.

4. **Quality metric not predictive:** The body-ratio quality formula (higher body ratio = higher quality score) does not translate to better trade outcomes. Low-quality triggers (bodyRatio 0.60–0.79) slightly outperform high-quality triggers (≥0.80). The score formula may not be discriminating.

5. **Fire rate disqualifies confirm role:** 43.6 triggers per day means the strategy fires on virtually every breakout candle in bearish conditions. This ubiquity is incompatible with the CONFIRM role, which requires selective evidence that a specific setup is present. A confirm strategy that fires on all bars confirms nothing.

6. **Recent deterioration is severe:** April and May 2026 are both EDGE_REJECTED. The LATE period (last 40% of data) is EDGE_REJECTED with E[R]=-0.129R. Any future trading assumption must be treated as having no current edge support until fresh evidence emerges.

7. **TC family weakness signal:** This finding adds to the evidence that TC-family CONFIRM strategies have structural difficulty providing cross-family confirmation. breakdown_momentum_v1 joins momentum_breakout_cont_v1 (FROZEN, 9.1% WR) as a failed TC confirm. This motivates continued certification of remaining TC confirms — particularly `lower_high_rejection_v1` — to determine whether the weakness is strategy-specific or family-wide.

8. **SELL_ONLY architecture:** By construction, breakdown_momentum_v1 can never support BUY-side contexts. It cannot contribute to any reversal or mean-reclaim playbook and cannot serve as a failure-mode detector for BUY trades in any operational sense given the fire rate.

---

## §26.6 — Phase Implications

| Phase | Status | Reason |
|---|---|---|
| Phase 3 (certification backlog) | ACTIVE — 4/17 certified | breakdown_momentum_v1 complete; lower_high_rejection_v1 recommended next |
| Phase 4A-i (JSONL V1B trigger records) | APPLIED — validation pending | Monitor for first trigger_present records in live trading |
| Phase 4A-ii (cross-family CRR upgrade) | BLOCKED | breakdown_momentum_v1 failure does not help; TPC (EDGE_SUPPORTED, certified separately) is the dependency but is too sparse as mandatory gate; insufficient cross-family ledger events |
| Phase 4B (exhaustion veto) | BLOCKED | MFI 0 live entries; veto threshold uncalibrated |
| Phase 4C (quality soft gate) | BLOCKED | Opportunity Ledger insufficient |
| Phase 5A (bollinger_reclaim SELL/TREND_UP gate) | APPLIED — NAUTILUS_CHALLENGED / RUNTIME_VALIDATION_PENDING | Unchanged |
| Phase 6 (EEWP weight progression) | BLOCKED | All prerequisites unmet |
| System status | DEVELOPING | Unchanged; no phase completion changes this |
| Production readiness | UNCHANGED | No improvement from this certification |

**Note on Phase 4A-ii:** breakdown_momentum_v1 is a TREND_CONTINUATION CONFIRM — the same family as the TREND_JUDGE it would confirm (trend_momentum). This is exactly the same-family confirm problem that Phase 4A-ii (cross-family CRR upgrade) is designed to fix. A same-family confirm cannot satisfy the cross-family CRR requirement. Even if breakdown_momentum_v1 had strong edge, it would not advance Phase 4A-ii because cross-family CRR requires a CONFIRM from a *different* family.

---

## §26.7 — Evidence Classification

| Claim | Classification |
|---|---|
| Trigger replication (body ≥ 0.60 ATR + close < 3-bar prior low) — source-faithful | **Verified** |
| Dual-bear gate replication (M1TrendBear AND M5TrendBear, EMA20/50) | **Verified** |
| TC zone proxy gap (M5 TREND_DOWN used as proxy) | **Plausible proxy — stated limitation** |
| Variant A WR=38.08%, E[R]=-0.048R (N=2,340) | **Verified** |
| Intended TREND_DOWN context WR=37.52%, E[R]=-0.062R (N=1,578) | **Verified** |
| RANGE_NEUTRAL (WR=39.51%) outperforms TREND_DOWN (WR=37.36%) | **Verified** |
| Dual-bear gate is counterproductive in Nautilus (-0.48pp WR vs ungated) | **Strongly supported** |
| Body-quality metric (bodyRatio) does not predict better outcomes | **Strongly supported** |
| LATE period (≥ 2026-03-26) is EDGE_REJECTED (WR=34.85%, N=924) | **Verified** |
| April 2026 EDGE_REJECTED (WR=34.80%, N=684) | **Verified** |
| May 2026 EDGE_REJECTED (WR=34.06%, N=138) | **Verified** |
| Overlay analysis uninformative — BDM fires 74/74 days, no control group | **Verified** |
| breakdown_momentum_v1 accepted as TC CONFIRM packet | **Contradicted** |
| breakdown_momentum_v1 accepted as FAILURE_MODE_PACKET | **Contradicted / uninformative** |
| Any MT5 source change authorized by this certification | **Contradicted** |
| Dual-bear gate should be removed from MT5 | **Contradicted — evidence only, no implementation authority** |

---

## §26.8 — Forbidden Conclusions

The following conclusions must not be drawn from this certification:

| Claim | Status |
|---|---|
| breakdown_momentum_v1 should be deleted | **FORBIDDEN** |
| breakdown_momentum_v1 should be frozen | **FORBIDDEN** |
| breakdown_momentum_v1 source logic should be changed | **FORBIDDEN** |
| Dual-bear gate should be removed from MT5 based on this cert | **FORBIDDEN** |
| vote_weight 0.68 should change | **FORBIDDEN** |
| TC zone gates should change | **FORBIDDEN** |
| Any MT5 source change is authorized | **FORBIDDEN** |
| Any runtime behavior should change | **FORBIDDEN** |
| council_quality / HIGH_CONVICTION / CRR / DSN change is authorized | **FORBIDDEN** |
| RCEM enforcement is authorized | **FORBIDDEN** |
| RANGE_NEUTRAL hypothesis is authorized for implementation | **FORBIDDEN** |
| RANGE_NEUTRAL hypothesis may be retroactively tested on existing cert data | **FORBIDDEN** |
| production readiness improves | **FORBIDDEN** |

---

## §26.9 — Recommended Next Actions

1. **Continue Phase 3 certification backlog.** breakdown_momentum_v1 is complete (cert #4 of 17).

2. **Next recommended Phase 3 target: `lower_high_rejection_v1`.** Rationale: it is a TC-family SELL_ONLY CONFIRM strategy (family=TREND_CONTINUATION, role=CONFIRM, direction_bias=SELL_ONLY per source L1894–1901). Certifying it will determine whether the TC confirm family weakness is specific to breakdown_momentum_v1 or a broader family pattern. It also shares structural characteristics (SELL_ONLY, TC zone, CONFIRM role) that make comparison diagnostically useful.

3. **Do not re-certify TPC (trend_pullback_cont_v1).** TPC is already certified: EDGE_SUPPORTED standalone but TOO_SPARSE_FOR_PHASE_4A as a mandatory gate. TPC certification is complete.

4. **Continue Opportunity Ledger accumulation.** Monitor JSONL V1B trigger-present records from live trading. This remains the prerequisite for Phase 4C and Phase 4A-ii audit evidence.

5. **Abnormal termination investigation (severity=2) remains a separate operational concern.** Do not conflate with certification work.

---

## §26.10 — Footer

```
SECTION:                         26
SECTION_ID:                      BREAKDOWN_MOMENTUM_PHASE3_CERTIFICATION_V1
SECTION_DATE:                    2026-05-08
STRATEGY:                        breakdown_momentum_v1
CERT_LABEL:                      EDGE_WEAK_BUT_RECOVERABLE (aggregate) / EDGE_NOT_CONFIRMED (intended TC/TREND_DOWN context)
REPLICATION_CLASS:               PARTIAL_REPLICATION
TC_ZONE_PROXY:                   M5 TREND_DOWN (EMA-spread, consistent with prior certs)
GCF_PROXY:                       NOT_USED
PHASE_3_PROGRESS:                4/17 certified (bollinger_reclaim, VWAP, sweep_reversal, breakdown_momentum_v1)
ALPHA_TC_PROXY:                  REJECTED
ALPHA_UNRESTRICTED:              REJECTED
CONFIRMATION_PACKET:             REJECTED (ubiquitous fire rate)
FAILURE_MODE_PACKET:             UNINFORMATIVE (no control group)
RESEARCH_ONLY_RANGE_NEUTRAL:     CONDITIONAL — requires new operator-authorized pilot
PLAYBOOK_ASSIGNMENT:             NONE
REGIME_INVERSION:                CONFIRMED — TREND_DOWN weakest subset; RANGE_NEUTRAL best
GATE_PREMIUM:                    NEGATIVE (-0.48pp WR vs ungated) — Nautilus evidence only; gate not removed
TEMPORAL_INSTABILITY:            SEVERE — April/May 2026 EDGE_REJECTED; LATE period EDGE_REJECTED
MT5_MODIFIED:                    NO
SOURCE_CHANGED:                  NO
RUNTIME_CHANGED:                 NO
NAUTILUS_ARTIFACTS_CHANGED:      NO
SYSTEM_STATUS:                   DEVELOPING — unchanged
PHASE_4A_II_STATUS:              BLOCKED (same-family confirm; does not advance cross-family CRR)
PHASE_4B_STATUS:                 BLOCKED
PHASE_4C_STATUS:                 BLOCKED
PHASE_6_STATUS:                  BLOCKED
NEXT_PHASE3_TARGET:              lower_high_rejection_v1
IMPLEMENTATION_FORBIDDEN:        All items listed in §26.8

---

# §27 — lower_high_rejection_v1 Nautilus Phase 3 Certification

**Date:** 2026-05-08  
**Type:** Nautilus Phase 3 Certification  
**Authority:** EVIDENCE_ONLY — No MT5 modification, no runtime change  
**Phase 3 progress:** 5/17  
**Artifacts:** cert_lower_high_rejection_v1_xauusd_v1.py · cert_lhr_v1_metrics.json · certification_lower_high_rejection_v1_xauusd_v1.md

---

## §27.1 Source Identity

| Field | Value |
|---|---|
| strategy_id | lower_high_rejection_v1 |
| family | TREND_CONTINUATION |
| role | COUNCIL_ROLE_CONFIRM |
| vote_weight | 0.66 |
| direction_bias | SELL_ONLY |
| zone | TREND_CONTINUATION only |
| quality | 0.72 (fixed) |
| Trigger file | council_strategies.mqh L1638–1669 |
| Strategy builder | council_strategies.mqh L1887–1955 |
| Replication class | PARTIAL_REPLICATION (trigger + gate SOURCE_FAITHFUL; TC zone = M5 TREND_DOWN proxy) |

**Trigger logic (verbatim from source):**
- h2 = high[2]; h3 = high[3]; h4 = high[4]
- prior_high = max(h3, h4)
- lower_high gate: h2 < prior_high - 0.15 × ATR14(shift=1)
- Bearish rejection at shift=1: close < open AND upper_wick >= body × 0.8
- Dual-bear gate: M1EMA20 < M1EMA50 AND close[1] <= M1EMA20; M5EMA20 < M5EMA50 AND M5close <= M5EMA20

---

## §27.2 Certification Verdict

**Overall: `EDGE_WEAK_BUT_RECOVERABLE`**

| Variant | Triggers | Simulated | WR | E[R] | Label |
|---|---|---|---|---|---|
| A — Unrestricted | 8,440 | 5,597 | 0.3900 | -0.0249R | EDGE_WEAK_BUT_RECOVERABLE |
| B — Dual-bear gate | 2,246 | 1,578 | 0.3986 | -0.0035R | EDGE_WEAK_BUT_RECOVERABLE |
| C — TC proxy (M5 TREND_DOWN) | 2,601 | 1,751 | 0.4015 | **+0.0037R** | EDGE_WEAK_BUT_RECOVERABLE |

**Gate impact (B vs A):** +0.0086pp WR, +0.021R E[R] — gate HELPS (unlike BDM where gate was counterproductive).  
**TC proxy:** Only variant with positive E[R]. WR=40.15% is at breakeven; E[R] marginally positive.  
**Fire rate:** A=113.6/day; B=30.2/day (~74.3 trading days).  
**Breakeven WR:** 40.0%.

---

## §27.3 Regime Split (Variant A)

| Regime | N | WR | E[R] | Label |
|---|---|---|---|---|
| TREND_DOWN | 1,730 | 0.4012 | +0.0029R | EDGE_WEAK_BUT_RECOVERABLE |
| RANGE_NEUTRAL | 1,902 | 0.3906 | -0.0234R | EDGE_WEAK_BUT_RECOVERABLE |
| TREND_UP | 1,965 | 0.3796 | -0.0509R | EDGE_NOT_CONFIRMED |

**Critical finding — regime alignment is CORRECT.** TREND_DOWN is the best regime, TREND_UP is the worst. This is the expected directional pattern for a SELL_ONLY strategy. This distinguishes LHR from breakdown_momentum_v1 which showed complete regime inversion (TREND_DOWN was BDM's worst context).

---

## §27.4 Monthly Breakdown and Degradation (Variant A)

| Month | N | WR | E[R] | Label |
|---|---|---|---|---|
| 2026-01 | 430 | 0.3953 | -0.0116R | EDGE_WEAK_BUT_RECOVERABLE |
| 2026-02 | 1,525 | 0.3948 | -0.0131R | EDGE_WEAK_BUT_RECOVERABLE |
| 2026-03 | 1,711 | 0.3992 | -0.0020R | EDGE_WEAK_BUT_RECOVERABLE |
| 2026-04 | 1,610 | 0.3702 | -0.0745R | EDGE_NOT_CONFIRMED |
| 2026-05 | 321 | 0.4112 | +0.0280R | EDGE_WEAK_BUT_RECOVERABLE |

**Walk-forward split at 2026-03-26 (60/40):**

| Period | N | WR | E[R] | Label |
|---|---|---|---|---|
| EARLY (< 2026-03-26) | 3,358 | 0.3970 | -0.0076R | EDGE_WEAK_BUT_RECOVERABLE |
| LATE (>= 2026-03-26) | 2,239 | 0.3796 | -0.0509R | EDGE_NOT_CONFIRMED |

**Degradation hint: TRUE.** LATE period drops to NOT_CONFIRMED. Same 2026-03-26 split produces degradation across sweep_reversal, BDM, and now LHR — pattern consistent with a shared market regime shift.

---

## §27.5 LH Gap Quality and Stress Tests

**LH Gap quality (median=186pt):**

| Quality | N | WR | E[R] |
|---|---|---|---|
| STRONG (gap >= 186pt) | 2,801 | 0.3974 | -0.0066R |
| WEAK (gap < 186pt) | 2,796 | 0.3827 | -0.0433R |

Gap discriminates: +1.47pp WR, +0.037R E[R] for stronger lower-high structures. Below formal +2pp threshold but directionally valid. Future research: test stricter gap threshold (e.g., 0.20×ATR).

**Slippage stress (Variant B + 10pt extra):**

| Metric | Base | Stress | Delta |
|---|---|---|---|
| WR | 0.3986 | 0.3949 | -0.0037 |
| E[R] | -0.0035R | -0.0438R | -0.040R |

E[R] is sensitive to cost: thin edge near breakeven under base cost becomes materially negative under stress.

---

## §27.6 Packet Classification (PLAYBOOK_CENTRIC_EVIDENCE_ARCHITECTURE_V1)

LHR is a TC-family SELL_ONLY CONFIRM strategy. It does not belong to the RANGE_BOUNDARY_SWEEP_RECLAIM playbook. These packets belong to a future TC_TREND_SELL_CONTINUATION playbook (not yet defined in the registry).

| Packet | Type | Evidence | Verdict |
|---|---|---|---|
| P1 — LHR trigger in TC regime | ALPHA_TRIGGER | Variant C: WR=40.15%, E[R]=+0.0037R | EDGE_WEAK_BUT_RECOVERABLE — near breakeven, positive E[R] |
| P2 — LHR trigger unrestricted | ALPHA_TRIGGER | Variant A: WR=39.0%, E[R]=-0.025R | EDGE_WEAK_BUT_RECOVERABLE |
| P3 — TREND_UP hostile | FAILURE_MODE | F TREND_UP: WR=37.96%, E[R]=-0.051R | ACCEPTED — NOT_CONFIRMED; correct directional failure mode |
| P4 — LH gap quality | QUALITY_DISCRIMINANT | STRONG WR=39.74% vs WEAK WR=38.27%; delta=+1.47pp | RESEARCH_ONLY — below formal confirmation threshold |
| P5 — LATE degradation | FAILURE_MODE | H_LATE: WR=37.96%, E[R]=-0.051R | ACCEPTED — sustained degradation from 2026-03-26 |

---

## §27.7 Architectural Interpretation

1. **LHR is strictly better than BDM on TC-SELL dimension.** Higher WR (39.0% vs 38.08%), better E[R] (-0.025R vs -0.048R), gate helps (vs gate counterproductive), correct regime alignment (vs BDM regime inversion), lower fire rate (30.2 vs 43.6/day gated).

2. **TC proxy achieves near-breakeven.** WR=40.15%, E[R]=+0.0037R is the first TC-family SELL_ONLY variant to produce positive E[R] in this certification series. The TC regime context is genuinely improving LHR's edge.

3. **Regime alignment is correct, not inverted.** TREND_DOWN best, TREND_UP worst. This confirms the lower-high rejection structure is a meaningful TC signal — it correctly identifies exhaustion of counter-moves within trends.

4. **Gate does genuine filtering work for LHR.** The +0.021R E[R] improvement from the dual-bear gate confirms that bearish EMA alignment adds information for LHR. This differentiates LHR from BDM where the gate was counterproductive.

5. **Fire rate is a CONFIRM selectivity concern but not disqualifying.** At 30.2/day gated, LHR fires frequently. This is a lower rate than BDM (43.6/day) but still structurally limits diagnostic co-presence analysis. Evidence only — not a reason to freeze or alter the strategy.

6. **LH gap quality offers future improvement path.** The 0.15×ATR minimum in source is conservative. A tighter filter could improve selectivity. This is a future Nautilus research task — not a source change recommendation.

7. **April 2026 co-occurrence with BDM.** Both TC-family strategies have their worst month in April 2026. This temporal pattern across the family suggests market regime exposure rather than individual strategy failure.

8. **Degradation hint authorized.** The LATE period crosses into NOT_CONFIRMED. The same 2026-03-26 boundary triggers degradation in sweep_reversal, BDM, and LHR — likely a shared XAUUSD structure shift.

---

## §27.8 Phase Implications

| Phase | State | Notes |
|---|---|---|
| Phase 3 — LHR | COMPLETE | 5/17; EDGE_WEAK_BUT_RECOVERABLE |
| Phase 3 — next | READY | micro_structure_reentry_v1 (last TC-CONFIRM uncertified) |
| Phase 4A (cross-family CRR) | BLOCKED | TPC fire rate unverified |
| Phase 4B (exhaustion veto) | BLOCKED | MFI 0 entries |
| Phase 4C (quality soft gate) | BLOCKED | Phase 2 (Opportunity Ledger) not live |
| Phase 5C+ (LHR regime gate) | NOT_AUTHORIZED | Evidence only; no source change authorized |
| Phase 6 (EEWP) | DESIGN_ONLY | Weight 0.66 unchanged |

---

## §27.9 Evidence Classification

| Claim | Classification |
|---|---|
| Trigger replication (lower-high + bearish rejection exact) | Verified |
| Dual-bear gate replication | Verified |
| TC zone proxy (M5 TREND_DOWN) | Plausible — EMA proxy |
| Gate helps LHR | Verified — +0.86pp WR, +0.021R E[R] |
| TC proxy near-breakeven | Verified — WR=40.15%, E[R]=+0.0037R (N=1,751) |
| TREND_UP hostile | Verified — WR=37.96%, E[R]=-0.051R |
| LHR > BDM on TC-SELL | Verified — all metrics superior |
| LH gap quality discriminates | Plausible — below formal threshold |
| Degradation hint | Verified — LATE NOT_CONFIRMED; consistent across TC family |

---

## §27.10 Forbidden Conclusions

- lower_high_rejection_v1 should be promoted to new zones → NO
- vote_weight should increase from 0.66 → NO
- degradation_hint should be cleared or suppressed → NO
- LHR's gate should be modified in MT5 source → NO
- LHR TREND_UP gate authorized (Phase 5C) → NO — evidence only; requires separate operator authorization
- LHR replaces or demotes BDM → NO — evidence only; BDM remains in its current role
- CONFIRM role disqualified for LHR → NO — fire rate concern; not a disqualification
- TC proxy positive E[R] means edge confirmed → NO — EDGE_WEAK_BUT_RECOVERABLE, not EDGE_SUPPORTED
- micro_structure_reentry_v1 cert can be deferred → NO — TC-CONFIRM family coverage requires it as next Phase 3 target
- Any gate, posture, RCEM, weight, or role change → NO
- MT5 source should change → NO
- Production readiness improves → NO

---

## §27.11 Footer

```
SECTION:                         §27
STRATEGY:                        lower_high_rejection_v1
CERT_DATE:                       2026-05-08
LABEL:                           EDGE_WEAK_BUT_RECOVERABLE
REPLICATION_CLASS:               PARTIAL_REPLICATION
SOURCE_CHANGED:                  NO
RUNTIME_CHANGED:                 NO
NAUTILUS_ARTIFACTS_CHANGED:      NO
SYSTEM_STATUS:                   DEVELOPING — unchanged
PHASE_3_PROGRESS:                5/17
NEXT_PHASE3_TARGET:              micro_structure_reentry_v1
DEGRADATION_HINT:                TRUE (LATE NOT_CONFIRMED; 2026-03-26 split)
GATE_HELPFUL:                    YES (unlike BDM where gate was counterproductive)
REGIME_ALIGNMENT:                CORRECT (TREND_DOWN best; TREND_UP worst — SELL_ONLY aligned)
BDM_COMPARISON:                  LHR strictly superior on all TC-SELL metrics
TC_PROXY_E_R:                    +0.0037R (near breakeven; only positive-E[R] TC-SELL variant in Phase 3)
PHASE_4_ALL:                     BLOCKED — no dependency on LHR cert
IMPLEMENTATION_FORBIDDEN:        All items listed in §27.10
```

---

# §28 — micro_structure_reentry_v1 Nautilus Phase 3 Certification

**Date:** 2026-05-08  
**Type:** Nautilus Phase 3 Certification  
**Authority:** EVIDENCE_ONLY — No MT5 modification, no runtime change  
**Phase 3 progress:** 6/17 — TC-CONFIRM family coverage complete  
**Artifacts:** cert_micro_structure_reentry_v1_xauusd_v1.py · micro_structure_reentry_v1_xauusd_v1_trades.csv · micro_structure_reentry_v1_xauusd_v1_metrics.json · micro_structure_reentry_v1_packet_classification_v1.json · micro_structure_reentry_v1_overlay_v1.json · certification_micro_structure_reentry_v1_xauusd_v1.md

---

## §28.1 Source Identity

| Field | Value |
|---|---|
| strategy_id | micro_structure_reentry_v1 |
| family | TREND_CONTINUATION |
| role | COUNCIL_ROLE_CONFIRM |
| vote_weight | 0.70 |
| direction_bias | BOTH |
| zone | TREND_CONTINUATION only |
| quality range | 0.60–0.78 (computed per bar) |
| Trigger file | council_strategies.mqh L1529–1598 |
| Strategy builder | council_strategies.mqh L1743–1815 |
| Replication class | PARTIAL_REPLICATION (trigger + gates SOURCE_FAITHFUL; TC zone = M5 proxy) |

**Trigger: 2-bar pullback-and-reclaim micro structure pattern.**
- BUY: bar[2] bearish (pullback), bar[1] bullish closing above bar[2] high, not-late gate (c1 - EMA20 <= ATR × 1.20)
- SELL: bar[2] bullish (pullback), bar[1] bearish closing below bar[2] low, not-late gate (EMA20 - c1 <= ATR × 1.20)
- Direction determined by: M1TrendBull+M5TrendBull → BUY; M1TrendBear+M5TrendBear → SELL; neither → WAIT
- Key difference from BDM/LHR: BOTH directions; EMA20 proximity (not-late) gate; no body/ATR ratio requirement

---

## §28.2 Certification Verdict

**Overall: `EDGE_WEAK_BUT_RECOVERABLE`**

| Variant | Triggers | Simulated | WR | E[R] | Label |
|---|---|---|---|---|---|
| A — Unrestricted | 11,706 | 6,756 | 0.3850 | -0.0375R | EDGE_WEAK_BUT_RECOVERABLE |
| B — Alignment gated | 2,185 | 1,735 | 0.3948 | -0.0130R | EDGE_WEAK_BUT_RECOVERABLE |
| C — TC proxy (M5 regime) | 3,636 | 2,703 | 0.3814 | -0.0464R | EDGE_WEAK_BUT_RECOVERABLE |

**Gate helps:** +0.98pp WR, +0.025R E[R] (B vs A).  
**TC proxy hurts:** C worse than A — opposite of LHR behaviour. MSR pattern fires equally across regime contexts.  
**Fire rate:** A=157.6/day (highest TC-CONFIRM); B=29.4/day.  
**Breakeven WR:** 40.0%.

---

## §28.3 Direction and Regime Findings

**Direction split (Variant A):**

| Direction | N | WR | E[R] | Label |
|---|---|---|---|---|
| SELL | 3,344 | 0.3932 | -0.0169R | EDGE_WEAK_BUT_RECOVERABLE |
| BUY | 3,412 | 0.3769 | -0.0577R | EDGE_NOT_CONFIRMED |

**Direction × Regime highlights:**

| Subset | N | WR | E[R] | Label |
|---|---|---|---|---|
| SELL × TREND_UP | 1,266 | **0.4013** | **+0.0032R** | EDGE_WEAK_BUT_RECOVERABLE (best) |
| BUY × TREND_UP | 1,100 | 0.3964 | -0.0091R | EDGE_WEAK_BUT_RECOVERABLE |
| BUY × RANGE_NEUTRAL | 1,219 | 0.3634 | -0.0915R | EDGE_NOT_CONFIRMED (worst) |

**Regime inversion:** TREND_UP best overall (like BDM inversion pattern, not like LHR's correct alignment). SELL direction in M5-bullish environment produces the only positive E[R] cell — counter-trend sells within uptrend may be the actual mechanism.

**Gated regime (Variant B):** TREND_DOWN achieves WR=40.42%, E[R]=+0.010R with alignment gate active. The alignment gate + TREND_DOWN context is the cleanest combination.

---

## §28.4 Co-presence Failure Mode Finding (Critical)

| Population | N (LHR triggers) | Simulated Trades | WR | E[R] | Label |
|---|---|---|---|---|---|
| LHR with MSR co-present (±5 bars) | 6,153 (72.9%) | 4,268 | 0.3629 | -0.0927R | EDGE_NOT_CONFIRMED |
| LHR without MSR nearby | 2,287 (27.1%) | 1,697 | 0.4832 | +0.208R | EDGE_SUPPORTED |
| LHR standalone baseline | — | 5,597 | 0.3900 | -0.0249R | — |

**E[R] degradation (with vs baseline):** -0.068R — exceeds -0.06R failure-mode threshold.  
**WR degradation:** -2.71pp — below -3.0pp threshold.  
**FAILURE_MODE_PACKET: ACCEPTED on E[R] criterion** (N=4,268, SUFFICIENT).

Interpretation: MSR fires on 72.9% of LHR trigger bars, making it near-ubiquitous. When MSR's 2-bar pullback-reclaim pattern is active near LHR, LHR's rejection signal quality degrades. The "without-MSR" WR=48.32% is likely inflated by selection bias (unusual market states where MSR doesn't fire) rather than a reliable filter mechanism.

**No runtime authority:** This finding does not authorize any MSR-based gate on LHR in MT5.

---

## §28.5 Degradation and Monthly Breakdown

**Walk-forward split (60/40 at 2026-03-26):**

| Period | N | WR | E[R] | Label |
|---|---|---|---|---|
| EARLY | 4,053 | 0.3906 | -0.0236R | EDGE_WEAK_BUT_RECOVERABLE |
| LATE | 2,703 | 0.3766 | -0.0585R | EDGE_NOT_CONFIRMED |

**Monthly:** April worst (WR=37.39%, NOT_CONFIRMED). May partial recovery (WR=41.67%, positive E[R], N=396).  
**Degradation hint: TRUE.** Third consecutive TC-CONFIRM strategy degrading at 2026-03-26 split — shared market structure change, not individual strategy failure.

---

## §28.6 Packet Classification Summary

| Packet | Type | Verdict |
|---|---|---|
| P1 — SELL alpha (TC) | ALPHA_TRIGGER | RESEARCH_ONLY_PACKET — positive E[R] in SELL×TREND_UP but below formal threshold |
| P2 — BUY alpha | ALPHA_TRIGGER | REJECTED_PACKET — NOT_CONFIRMED in all BUY conditions |
| P3 — Confirmation | CONFIRMATION | REJECTED_PACKET — ubiquitous; co-presence degrades LHR outcomes |
| P4 — LHR failure mode | FAILURE_MODE | ACCEPTED — E[R] degradation -0.068R exceeds -0.06R threshold; N=4,268 |
| P5 — Timing | TIMING | DATA_INSUFFICIENT — no comparable baseline available |
| P6 — Quality discriminant | QUALITY | REJECTED_PACKET — source quality inverted (4th consecutive TC-CONFIRM) |

---

## §28.7 TC-CONFIRM Family Coverage (Complete)

| Strategy | Cert label | Gate | Best regime | Direction | Primary packet role |
|---|---|---|---|---|---|
| BDM | NOT_CONFIRMED (TC proxy) | Hurts | RANGE_NEUTRAL (inverted) | SELL_ONLY | REJECTED |
| LHR | RECOVERABLE | Helps | TREND_DOWN (correct) | SELL_ONLY | RESEARCH_ONLY (SELL) |
| MSR | RECOVERABLE; BUY REJECTED | Helps | SELL×TREND_UP | BOTH (BUY weak) | FAILURE_MODE_PACKET (LHR) |
| TPC | SUPPORTED | N/A (sparse) | TC | BOTH | CONFIRM_PACKET_SPARSE |

TC-CONFIRM coverage complete. Summary: TPC is the only certified CONFIRM (sparse). BDM rejected. LHR is a research-direction SELL candidate. MSR provides failure-mode evidence for LHR. No TC strategy meets CONFIRMATION_PACKET threshold for cross-family CRR enforcement under IRREW Phase 4A.

---

## §28.8 Phase Implications

| Phase | State | Notes |
|---|---|---|
| Phase 3 — MSR | COMPLETE | 6/17 |
| Phase 3 — next | READY | range_edge_fade (RMR CONFIRM; RBSR playbook relevance) |
| Phase 4A (cross-family CRR) | BLOCKED | TPC fire rate unverified; TC-CONFIRM completion does not clear Phase 4A |
| Phase 4B (exhaustion veto) | BLOCKED | MFI 0 entries |
| Phase 4C (quality soft gate) | BLOCKED | Phase 2 Opportunity Ledger not live |
| Phase 5 (MSR gate) | NOT_AUTHORIZED | Evidence only |
| Phase 6 (EEWP) | DESIGN_ONLY | Weight 0.70 unchanged |

---

## §28.9 Evidence Classification

| Claim | Classification |
|---|---|
| 2-bar pullback-reclaim trigger | Verified |
| Not-late EMA20 gate | Verified |
| Dual-EMA alignment gate | Verified |
| TC zone proxy (M5 regime) | Plausible |
| BUY direction NOT_CONFIRMED | Verified — all BUY subsets below breakeven |
| SELL × TREND_UP positive E[R] | Verified — N=1,266 |
| MSR co-presence predicts worse LHR | Verified — E[R] threshold exceeded |
| LHR-without-MSR WR=48.3% reliable | Suspicious — likely selection bias |
| Quality score inverted | Contradicted — inverted 4th consecutive cert |
| Degradation (2026-03-26 split) | Verified — consistent across TC family |

---

## §28.10 Forbidden Conclusions

- vote_weight 0.70 should change → NO
- BUY direction should be disabled in MT5 → NO
- MSR should gate LHR in MT5 → NO
- LHR-without-MSR is a viable trading filter → NO
- SELL × TREND_UP authorizes regime-restricted source change → NO
- TC-CONFIRM completion justifies Phase 4A clearance → NO
- Any gate, posture, RCEM, weight, role, or score change → NO
- Production readiness improves → NO

---

## §28.11 Footer

```
SECTION:                         §28
STRATEGY:                        micro_structure_reentry_v1
CERT_DATE:                       2026-05-08
LABEL:                           EDGE_WEAK_BUT_RECOVERABLE (overall); BUY EDGE_NOT_CONFIRMED
REPLICATION_CLASS:               PARTIAL_REPLICATION
SOURCE_CHANGED:                  NO
RUNTIME_CHANGED:                 NO
PHASE_3_PROGRESS:                6/17
TC_CONFIRM_COVERAGE:             COMPLETE (BDM/LHR/MSR/TPC all certified)
NEXT_PHASE3_TARGET:              range_edge_fade
DEGRADATION_HINT:                TRUE (LATE NOT_CONFIRMED; 2026-03-26 split)
DIRECTION_ASYMMETRY:             SELL RECOVERABLE; BUY REJECTED
BEST_SUBSET:                     SELL x TREND_UP WR=40.13%, E[R]=+0.003R
FAILURE_MODE_CONFIRMED:          MSR co-presence predicts LHR E[R] degradation -0.068R (threshold -0.06R)
QUALITY_SCORE_INVERTED:          TRUE (4th consecutive TC-CONFIRM cert)
PHASE_4A_STATUS:                 BLOCKED — TC-CONFIRM completion alone does not clear Phase 4A
IMPLEMENTATION_FORBIDDEN:        All items listed in §28.10
```

---

# §29 — range_edge_fade Phase 3 Certification

## §29.1 Strategy Identity

| Field | Value |
|---|---|
| strategy_id | range_edge_fade |
| family | MEAN_RECLAIM |
| role | CONFIRM |
| weight | 0.88 |
| direction | BOTH |
| intended zone | RMR (RANGE_MEAN_RECLAIM) |
| MT5 source | council_strategies.mqh L2104–2219 |
| cert_date | 2026-05-08 |
| cert_id | CERT_RANGE_EDGE_FADE_XAUUSD_V1 |
| replication_class | PARTIAL_REPLICATION |
| overall_cert_label | EDGE_WEAK_BUT_RECOVERABLE |

---

## §29.2 Source Identity (Verified)

Trigger: range_edge_fade fires a BUY or SELL when:
- Zone gate: CouncilIsRangeContext(env) AND NOT TC AND NOT BREAKOUT
- BUY: bullish rejection M1 bar[1] + low touched range_low zone (≤ lo−edgeBuf×0.15 OR ≤ lo+edgeBuf×0.10) + close recovered above lo+edgeBuf×0.20
- SELL: bearish rejection M1 bar[1] + high touched range_high zone (≥ hi+edgeBuf×0.15 OR ≥ hi−edgeBuf×0.10) + close recovered below hi−edgeBuf×0.20
- edgeBuf = max(0.05, M5_ATR14_price × 0.20) [for XAUUSD]
- Range bounds: 42-bar M5 rolling max(high)/min(low) from shift=1
- trendConflict (quality modifier, NOT a hard gate): BUY+M5TrendBear OR SELL+M5TrendBull → conflict_score=0.17

Python proxies: zone gate = M5 RANGE_NEUTRAL proxy; all other logic SOURCE_FAITHFUL.

---

## §29.3 Certification Verdict

**Overall: EDGE_WEAK_BUT_RECOVERABLE**

| Variant | N | WR | E[R] | Cert Label |
|---|---|---|---|---|
| A Unrestricted | 639 | 0.3850 | −0.0376R | RECOVERABLE |
| B Zone proxy (RANGE_NEUTRAL) | 167 | 0.3713 | −0.0719R | NOT_CONFIRMED |
| C BUY only | 287 | 0.3798 | −0.0505R | NOT_CONFIRMED |
| C SELL only | 352 | 0.3892 | −0.0270R | RECOVERABLE |
| D No conflict | 59 | 0.3729 | −0.0678R | NOT_CONFIRMED |
| D With conflict | 580 | 0.3862 | −0.0345R | RECOVERABLE |
| E RANGE_NEUTRAL | 167 | 0.3713 | −0.0719R | NOT_CONFIRMED |
| E TREND_UP | 280 | 0.3750 | −0.0625R | NOT_CONFIRMED |
| E TREND_DOWN | 193 | 0.4093 | +0.0233R | RECOVERABLE |
| F With SR | 572 | 0.3846 | −0.0385R | RECOVERABLE |
| F Without SR | 75 | 0.4000 | 0.0000R | RECOVERABLE |
| G With BR | 608 | 0.3816 | −0.0461R | RECOVERABLE |
| G Without BR | 34 | 0.4412 | +0.1029R | (N insufficient) |
| H Stress +10pt | 635 | 0.3906 | −0.0557R | RECOVERABLE |
| I Early 60% | 383 | 0.3577 | −0.1057R | NOT_CONFIRMED |
| I Late 40% | 256 | 0.4258 | +0.0645R | RECOVERABLE |

---

## §29.4 Monthly and Degradation Analysis

| Month | N | WR | E[R] |
|---|---|---|---|
| 2026-01 | 48 | 0.3750 | −0.0625R |
| 2026-02 | 170 | 0.3824 | −0.0441R |
| 2026-03 | 173 | 0.3526 | −0.1185R |
| 2026-04 | 196 | 0.4031 | +0.0077R |
| 2026-05 | 52 | 0.4423 | +0.1058R (partial) |

Split date: 2026-03-31. LATE period (April–May) is markedly better than EARLY (Jan–Mar).

**TEMPORAL INVERSION vs TC-CONFIRM pattern:** All TC-CONFIRM certifications (BDM, LHR, MSR) showed EARLY better than LATE, degrading in the March–April 2026 trending/volatile period. range_edge_fade shows the reverse: EARLY is NOT_CONFIRMED, LATE is RECOVERABLE with positive E[R]. Plausible mechanism: March 2026 trending conditions destroyed range structure (hurting REF) but then market reverted to ranging in April–May 2026, benefiting REF while TC strategies lagged.

**No shared 2026-03-26 degradation split.** The TC-CONFIRM strategies all degraded at ~2026-03-26. range_edge_fade was worst in March but then improved. The degradation does not carry over to MEAN_RECLAIM family.

---

## §29.5 Key Structural Findings

**Finding 1 — Zone proxy degrades outcomes:**
RANGE_NEUTRAL gate reduces WR by −1.4pp and E[R] by −0.034R vs unrestricted. Best regime is TREND_DOWN (WR=40.9%, E[R]=+0.023R), which is excluded by the RANGE_NEUTRAL zone proxy. Design intent (fire in ranging conditions) conflicts with empirical behavior (fires best in trending).

**Finding 2 — trendConflict flag inverted and structurally dominant:**
90.5% of all REF triggers are flagged as counter-trend (trendConflict = True). Trades with conflict outperform those without (WR +1.3pp, E[R] +0.033R). The trendConflict quality penalty does not predict worse outcomes for this strategy type, because counter-trend firing IS the intended operation of a range-fade strategy.

**Finding 3 — SR/BR co-presence too ubiquitous to discriminate:**
SR fires within 10 bars of 88.0% of REF triggers. BR fires within 10 bars of 94.2% of REF triggers. Neither can serve as a discriminating RBSR chain filter. Co-presence of SR/BR with REF does not lift REF outcomes — in both cases, with-SR/BR outcomes are slightly worse than without. Same structural pattern as MSR co-presence with LHR in TC-CONFIRM certifications.

**Finding 4 — TREND_DOWN positive E[R] is BUY-driven (H1 SELL × TREND_DOWN FALSIFIED — 2026-05-08):**
The only positive E[R] regime is TREND_DOWN (E[R]=+0.023R, N=193). SELL direction is better than BUY aggregate (E[R]=-0.027R vs -0.051R). **Amendment REF_SELL_TREND_DOWN_ISOLATION_V1 (2026-05-08):** H1 hypothesis (SELL × TREND_DOWN = the positive signal) is FALSIFIED. TREND_DOWN regime is 191 BUY / 2 SELL (99.1% BUY). The TREND_DOWN positive E[R] is driven entirely by BUY × TREND_DOWN (N=191, WR=40.31%, E[R]=+0.008R). SELL × TREND_DOWN has N=2 — structurally absent. The range-fade geometry explains this structurally: in a bearish trending environment, price gravitates to the lower range boundary, producing BUY fades; SELL upper-boundary fades are mechanically rare. BUY × TREND_DOWN is registered as a secondary RESEARCH_ONLY finding (E[R]=+0.008R — too thin to accept as a packet). No packet accepted from this test. No further REF micro-tests authorized.

**Finding 5 — Quality score inversion series:**
Fifth consecutive certification (sweep_reversal, BDM, LHR, MSR, range_edge_fade) where quality-related score flags are inverted or non-discriminating. The pattern now spans two families (TREND_CONTINUATION and MEAN_RECLAIM). Source quality score mechanisms do not predict actual trade quality.

---

## §29.6 Packet Classification

| Packet | Type | Status |
|---|---|---|
| P1 | ALPHA_TRIGGER | RESEARCH_ONLY — TREND_DOWN E[R]=+0.023R |
| P2 | LOCATION | REJECTED — zone proxy degrades outcomes |
| P3 | CONFIRMATION (RBSR chain) | REJECTED — SR/BR ubiquitous, no lift |
| P4 | FAILURE_MODE | BELOW_THRESHOLD (not formally accepted) |
| P5 | QUALITY_DISCRIMINANT | REJECTED — trendConflict inverted |
| P6 | TEMPORAL | RESEARCH_ONLY — LATE improvement |

**No packets formally accepted.** Family assignment: RESEARCH_ONLY (not a confirmed RBSR chain packet).

---

## §29.7 RBSR Family Comparison

| Strategy | Cert Label | Role in RBSR | Family Assignment |
|---|---|---|---|
| sweep_reversal | RECOVERABLE | ALPHA (reversal at extreme) | ALPHA_PACKET — RBSR anchor |
| bollinger_reclaim | NOT_CONFIRMED standalone | CONFIRM (mean reclaim) | CONFIRM_PACKET (weak) — secondary |
| mfi_reversal_assist | NOT_CONFIRMED | FAILURE_MODE vs SR counter | FAILURE_MODE_PACKET |
| range_edge_fade | RECOVERABLE (overall) | CONFIRM (RMR edge rejection) | RESEARCH_ONLY — BUY×TREND_DOWN secondary (H1 SELL×TD FALSIFIED 2026-05-08) |

---

## §29.8 Architectural Interpretation

1. Zone proxy mismatch: RANGE_NEUTRAL gate excludes best regime (TREND_DOWN). Gate applies wrong zone filter empirically.
2. 90.5% counter-trend trigger rate confirms REF is inherently a counter-trend fade strategy.
3. SR/BR co-presence ubiquity (88-94%) means RBSR chain does not selectively gate REF.
4. **Amendment 2026-05-08 (REF_SELL_TREND_DOWN_ISOLATION_V1):** H1 SELL × TREND_DOWN FALSIFIED — N=2 across 74 trading days (structural absence). TREND_DOWN positive E[R] is entirely BUY × TREND_DOWN (N=191, E[R]=+0.008R). BUY × TREND_DOWN is a secondary RESEARCH_ONLY finding; no packet accepted; no further REF micro-tests authorized.
5. Temporal INVERSION (LATE > EARLY) is the inverse of TC-CONFIRM degradation pattern. These two families respond to opposite market regimes.
6. Quality score inversion: fifth consecutive cert with inverted quality-flag prediction.

---

## §29.9 Phase Implications

| Phase | Implication | Status |
|---|---|---|
| Phase 3 progress | 7/17 strategies certified | UPDATED |
| Phase 5 restriction gate | Not warranted — no regime gate improves outcomes | NONE |
| Phase 4A (cross-family CRR) | Not affected by this cert | UNCHANGED/BLOCKED |
| RBSR composite | REF NOT confirmed as RBSR chain packet | RESEARCH_ONLY |
| SELL×TREND_DOWN isolation | COMPLETE — H1 FALSIFIED (N=2, structural absence) | DONE 2026-05-08 |
| BUY×TREND_DOWN H2 secondary | RESEARCH_ONLY secondary; E[R]=+0.008R (too thin) | OPTIONAL — LOW_PRIORITY only |
| Next Phase 3 target | fake_break_reversal or mean_reversion_bounce | PENDING |

---

## §29.10 Evidence Classification

| Claim | Classification |
|---|---|
| WR=38.5%, E[R]=-0.038R baseline | VERIFIED |
| Zone proxy degrades | STRONGLY_SUPPORTED |
| trendConflict inverted, 90.5% conflict rate | VERIFIED |
| TREND_DOWN best regime WR=40.9%, E[R]=+0.023R | SUPPORTED (N=193) |
| SELL > BUY | SUPPORTED (N=352 vs 287) |
| LATE > EARLY temporal inversion | SUPPORTED (N=256/383) |
| SR/BR co-presence 88-94% ubiquitous | VERIFIED |
| without-BR WR=44.1% reliable | SAMPLE_INSUFFICIENT (N=34) |
| SELL×TREND_DOWN positive E[R] | CONTRADICTED — REF_SELL_TREND_DOWN_ISOLATION_V1 (2026-05-08) falsified; N=2 structural absence |
| BUY×TREND_DOWN N=191, WR=40.31%, E[R]=+0.008R | VERIFIED — secondary finding; E[R] lift +0.046R vs baseline; too thin to accept as packet |

---

## §29.11 Forbidden Conclusions

- Zone gate should be removed from MT5 source → NO
- trendConflict penalty should be modified → NO
- REF role or weight should change → NO
- REF is confirmed as RBSR CONFIRM packet → NO (REJECTED)
- LATE improvement confirms edge recovery → NO (insufficient data; 2 months only)
- without-BR WR=44.1% authorizes a BR co-presence filter → NO (N=34)
- Production readiness improves → NO

---

## §29.12 Footer

```
SECTION:                         §29
STRATEGY:                        range_edge_fade
CERT_DATE:                       2026-05-08
LABEL:                           EDGE_WEAK_BUT_RECOVERABLE
REPLICATION_CLASS:               PARTIAL_REPLICATION
SOURCE_CHANGED:                  NO
RUNTIME_CHANGED:                 NO
PHASE_3_PROGRESS:                7/17
RBSR_FAMILY_STATUS:              RESEARCH_ONLY (not a confirmed RBSR chain packet)
ZONE_PROXY_FINDING:              DEGRADES — RANGE_NEUTRAL gate excludes best regime (TREND_DOWN)
TREND_CONFLICT_FINDING:          INVERTED — 90.5% counter-trend, with-conflict trades outperform
COPRESENCE_FINDING:              SR=88% / BR=94% ubiquitous — cannot discriminate
TEMPORAL_FINDING:                LATE > EARLY (inverse of TC-CONFIRM; LATE WR=42.6%, E[R]=+0.065R)
BEST_REGIME:                     TREND_DOWN (WR=40.93%, E[R]=+0.023R, N=193)
RESEARCH_DIRECTION:              H1 SELL×TD FALSIFIED (2026-05-08) — BUY×TD secondary RESEARCH_ONLY (E[R]=+0.008R)
QUALITY_INVERSION:               TRUE (5th consecutive cert)
PACKETS_ACCEPTED:                NONE
IMPLEMENTATION_FORBIDDEN:        All items listed in §29.11
NEXT_PHASE3_TARGET:              fake_break_reversal OR mean_reversion_bounce
```

---

# PLAYBOOK_GOVERNANCE_AND_REGISTRY_RULES_V1 — Governing Principles for Playbook-Centric Evidence Architecture

**Date:** 2026-05-08  
**Authority:** Advisory Layer memo — documentation only  
**Status:** DESIGN_REFERENCE — no runtime authority  
**Scope:** Governs all future Playbook, Packet, Nautilus, Registry, and MT5-interface design work

---

## PG.1 Core Decision

The Advisory Layer has approved the following governing interpretation of the Playbook-Centric Evidence Architecture:

| Term | Role |
|---|---|
| **Playbook** | Thesis-completion layer — not a permission layer |
| **Strategy** | Evidence packet — not a trading system |
| **Packet** | Measurable contribution unit — not a narrative justification |
| **V1** | Permission authority |
| **Execution Geometry** | Survivability authority |
| **Risk** | Invalidation / constraint authority |
| **Attribution** | Learning and evidence authority |

**Reference statement (canonical):**

> The Playbook qualifies the thesis. It does not authorize execution.

---

## PG.2 Governing Principles (20)

### PG.2.1 — Playbook Must Not Become a Mega-Strategy

Playbook is not a super-signal. Playbook is not a hidden gate. Playbook is not a replacement for V1. Playbook does not execute.

Playbook describes whether the trading thesis is complete.

**Correct layer separation:**

| Layer | Question |
|---|---|
| Playbook | Is the thesis complete? |
| V1 | Is participation allowed? |
| Execution Geometry | Can the entry survive? |
| Risk | Is there a reason to block, reduce, or invalidate? |
| Attribution | What happened and why? |

### PG.2.2 — Playbook is the Unit of Edge, Not the Standalone Strategy

Strategy standalone WR/PF/E[R] remains useful but insufficient. A strategy may be weak standalone but useful as: confirm, failure-mode detector, location detector, timing detector, stop-survivability diagnostic, or attribution signal.

**Hard rule:** Narrative is not evidence. Marginal contribution is evidence.

No weak strategy may survive by narrative alone. If a strategy does not demonstrate measurable contribution in at least one packet role, it is REJECTED.

### PG.2.3 — No Packet Without Layer Ownership

Every Evidence Packet must have clear layer ownership.

| Packet Type | Layer Ownership |
|---|---|
| Alpha trigger | Alpha / Thesis |
| Confirmation | Alpha / Thesis or Allocation interpretation |
| Failure-mode detector | Risk |
| Location packet | Alpha context or Attribution |
| Room-to-target | Execution / Risk |
| Stop-anchor validation | Execution |
| Regime / context packet | Environment / Attribution |
| Outcome explanation | Attribution |

**Governing rule:** No layer ownership = no packet admission.

### PG.2.4 — Do Not Waste Effort on Strategy Micro-Details at the Expense of the Architecture

The main priority is building a robust Playbook-Centric Evidence Architecture, not endlessly refining isolated strategy mechanics. Strategy details matter only insofar as they define measurable packet contribution inside a Playbook.

### PG.2.5 — Playbook State Must Be Categorical Only

**Allowed Playbook State values:**
- `PLAYBOOK_NOT_PRESENT`
- `PLAYBOOK_FORMING`
- `PLAYBOOK_VALID`
- `PLAYBOOK_CONTRADICTED`
- `PLAYBOOK_LATE`
- `PLAYBOOK_INVALID`

**Forbidden numeric constructs:**
- playbook_score
- playbook_quality_bonus
- playbook_confidence_multiplier
- playbook_weight
- playbook_completion_percent
- any numeric completion score

**Reason:** Numeric Playbook scoring would reintroduce score authority through the back door. Playbook state is categorical only. If it is not a state transition, it is not a Playbook output.

### PG.2.6 — PLAYBOOK_VALID Does Not Mean Trade

`PLAYBOOK_VALID` = thesis complete. It does not mean open trade.

Even if Playbook is valid, the decision must still pass all of:
- V1 permission check
- Risk constraints
- Execution geometry
- Level / room validation
- Runtime safety
- MT5 execution authority

**This principle must be documented explicitly in every Playbook registry entry.**

### PG.2.7 — Failure-Mode Packets Must Not Become Immediate Gates

Required maturity path before a failure-mode packet can influence runtime:

```
Attribution-only
  → Shadow failure-mode flag
    → Risk-layer candidate (separate design review)
      → only then, after explicit separate authorization, possible runtime consideration
```

**Forbidden shortcut:** `failure_mode_detected → block trade`

**Reason:** Premature gates can kill useful edge, create execution starvation, or introduce hidden risk logic that bypasses V1 authority.

### PG.2.8 — Start With a Small Number of Playbooks

Only the following initial Playbooks are approved for reference/research work:

1. **Range Boundary Sweep-Reclaim** (RBSR)
2. **Trend Pullback Continuation** (TPC)
3. **Volatility Compression Release** (VCR)

Do not define 10+ playbooks simultaneously. Do not broaden playbook inventory without management approval. Depth over breadth.

### PG.2.9 — Causal Chains Must Remain Short

**Recommended:** 5–7 causal links per Playbook.

**Example canonical chain:**
```
Context → Location → Trigger → Reclaim/Continuation → Confirm/Contradiction → Room → Stop Geometry
```

**Warning:** If a Playbook requires 12+ conditions to complete, it is likely overfit, too complex, or latency-sensitive for M1/M5 execution. Prune before implementing.

### PG.2.10 — Packet Acceptance Requires Measurable Contribution

A packet is useful only if it demonstrates at least one of:

| Measurable Contribution | Category |
|---|---|
| Improves WR | Alpha quality |
| Improves E[R] | Alpha quality |
| Reduces false positives | Filter quality |
| Reduces MAE | Execution quality |
| Reduces stop-outs inside noise | Stop survivability |
| Improves regime separation | Context quality |
| Detects failure mode | Risk / negative signal |
| Improves entry timing | Timing quality |
| Improves room / target quality | Execution quality |
| Improves stop survivability | Execution quality |
| Improves attribution clarity | Attribution quality |

If none of the above: **REJECTED_PACKET**. No exceptions.

### PG.2.11 — Nautilus Success Must Align With MT5 Context

Nautilus may use proxies for regime, zone, timing, boundary, spread/session, and execution assumptions. A successful Playbook replay in Nautilus must later demonstrate:

**MT5 Opportunity Ledger Alignment** — the critical question:

> Can the same causal-chain conditions be observed inside MT5 before the decision, at the correct time, with the same interpretation, without look-ahead?

Nautilus replay success is necessary but not sufficient. Ledger alignment verification is required before any Playbook transitions from RESEARCH to RUNTIME_CANDIDATE.

### PG.2.12 — Event Ordering Is Mandatory

**Governing rule:** Late evidence cannot validate an earlier trade.

Each Playbook must define an Event Order Contract (see PG.5). Confirmations and failure-mode detectors must be logically available before V1 consumes the Playbook state. No post-hoc completion is allowed.

### PG.2.13 — Strategy Rescue Bias Must Be Actively Blocked

**Hard rule:** Do not keep weak strategies alive by relabeling them as "maybe it is a packet."

A strategy is not rescued by finding a packet role. If a strategy does not:
- improve a Playbook's predictive quality,
- detect a failure mode reliably, or
- explain outcomes with measurable evidence,

then it is rejected. The Playbook architecture must not become a recycling mechanism for underperforming strategies.

### PG.2.14 — Separate Packet Registry from Playbook Registry

Two distinct registries must be maintained:

**Packet Registry:** Tracks each strategy/detector as a packet candidate (see PG.4).

**Playbook Registry:** Tracks each Playbook's causal chain, state definitions, and evidence requirements (see PG.5).

These are separate documents with separate governance. Do not merge them.

### PG.2.15 — Not Every Packet Is Required

Playbook evidence categories must be explicitly separated:

| Category | Definition |
|---|---|
| Required evidence | Playbook is INVALID without it |
| Supporting evidence | Strengthens classification but not mandatory |
| Failure evidence | Presence may shift state to CONTRADICTED |
| Optional evidence | May improve attribution quality if present |

**Example — RBSR Playbook:**
- Required: boundary, sweep, reclaim, room
- Supporting: MFI same-direction, structure_score alignment
- Failure: MFI counter-direction (failure-mode)
- Optional: bollinger_reclaim as secondary confirm

Optional and supporting packets are not gates. Absence does not reject a trade. This separation avoids execution starvation from over-specified requirements.

### PG.2.16 — Cross-Family Evidence Must Not Become Mandatory by Default

Cross-family evidence can strengthen thesis classification but absence of cross-family evidence must not automatically reject a trade unless frequency and causal value are separately proven.

**Correct framing:** cross-family evidence = stronger thesis classification  
**Incorrect framing:** no cross-family evidence = automatic reject

This is distinct from the Phase 4A cross-family CRR gate in the V1 architecture, which has its own governing rules. Playbook evidence classification and V1 gate rules are separate systems.

### PG.2.17 — Attribution Must Be Built Into Playbooks From the Start

Each Playbook record must eventually answer:

- Which packets were present?
- Which causal links were completed?
- Which links were missing?
- Which links were contradicted?
- Was failure-mode present?
- Was room sufficient?
- Was stop anchored?
- What was the outcome?

**Without attribution, Playbook architecture becomes another black box.** Attribution is not optional — it is the feedback loop that allows Playbook definitions to be calibrated over time.

### PG.2.18 — Do Not Rebuild Score as "Completion"

**Forbidden:**
```
playbook_completion = 80%
```

**Required (categorical only):**
```
completed_links: [context, trigger, reclaim]
missing_links:   [room]
contradicted_links: [MFI_counter_direction]
state: PLAYBOOK_CONTRADICTED
```

Categorical explanations of which links are complete/missing/contradicted — never a numeric completion score.

### PG.2.19 — Future V1 Should Consume Playbook State, Not Raw Strategy Clutter

If, later and separately authorized, Playbook architecture enters MT5/V1 interface, V1 should receive clean fields such as:

```json
{
  "playbook_id":             "range_boundary_sweep_reclaim",
  "playbook_state":          "PLAYBOOK_VALID",
  "failure_mode_present":    false,
  "missing_link":            "",
  "execution_geometry_state": "GEOMETRY_VALID"
}
```

V1 must not receive raw internal strategy details, individual packet votes, or intermediate causal-chain states. Clean interface only.

**This is future interface design only. No runtime consumption is authorized now.**

### PG.2.20 — Unify Language Before Implementation

Before any source change, the following vocabulary must be defined and stable:

| Term | Requires Definition |
|---|---|
| Packet | Yes |
| Causal Link | Yes |
| Playbook | Yes |
| Playbook State | Yes |
| Failure Mode | Yes |
| Required Evidence | Yes |
| Supporting Evidence | Yes |
| Contradiction | Yes |
| Runtime Candidate | Yes |
| Shadow Flag | Yes |
| Attribution-only | Yes |

**If language is not unified, implementation will create architecture drift.** Document vocabulary before writing any code.

---

## PG.3 Registry Design Requirement

The strongest next non-runtime architecture work (in priority order):

1. **Packet Registry** — document each strategy's packet candidacy, evidence status, and rejection/acceptance rules
2. **Playbook Registry** — document each Playbook's causal chain, required packets, state definitions
3. **Causal Chain definitions** — define each link in each Playbook's evidence chain with measurability criteria
4. **Playbook State definitions** — define transition conditions for each state category
5. **Nautilus → MT5 Opportunity Ledger Alignment Plan** — define how Nautilus certifications translate to MT5-observable conditions

All five are documentation/design/attribution planning tasks. None are runtime implementation tasks.

---

## PG.4 Packet Registry — Proposed Schema

Each strategy/detector tracked as a packet candidate. Schema per entry:

| Field | Description |
|---|---|
| strategy_id | MT5 strategy identifier |
| current_family | e.g. MEAN_RECLAIM, TREND_CONTINUATION |
| current_role | Current MT5 role (SCOUT/CONFIRM/TREND_JUDGE/etc.) |
| allowed_packet_roles | Which packet types this strategy may serve |
| rejected_packet_roles | Which packet types have been empirically rejected |
| layer_ownership | Which architecture layer owns this packet (Alpha/Risk/Attribution/etc.) |
| valid_contexts | Regime/zone/direction conditions where evidence holds |
| invalid_contexts | Conditions where evidence is negative |
| playbook_candidates | Which Playbooks this strategy may contribute to |
| current_evidence_status | EDGE_SUPPORTED / RECOVERABLE / NOT_CONFIRMED / REJECTED / DATA_INSUFFICIENT |
| standalone_cert_status | Nautilus cert label for standalone behavior |
| composite_cert_status | Cert label within a Playbook context (if run) |
| replication_status | SOURCE_FAITHFUL / PARTIAL_REPLICATION / PROXY_ONLY / BLOCKED |
| acceptance_rule | Formal measurable threshold for packet acceptance |
| rejection_rule | Formal measurable threshold for packet rejection |
| current_packet_status | ACCEPTED / RESEARCH_ONLY / REJECTED / DATA_INSUFFICIENT |
| missing_evidence | What additional evidence would change classification |
| next_allowed_action | Next research step (no MT5 action without separate authorization) |
| runtime_authority_status | NONE (until separately authorized) |

---

## PG.5 Playbook Registry — Proposed Schema

Each Playbook tracked with full causal chain and evidence state. Schema per entry:

| Field | Description |
|---|---|
| playbook_id | e.g. range_boundary_sweep_reclaim |
| family | e.g. MEAN_RECLAIM / LIQUIDITY_REVERSAL |
| thesis_statement | One-sentence thesis this Playbook tests |
| causal_chain_links | Ordered list: [context, location, trigger, reclaim, confirm, room, stop_geometry] |
| required_links | Links without which Playbook is INVALID |
| supporting_links | Links that strengthen classification but are not required |
| failure_links | Links whose presence shifts state to CONTRADICTED |
| optional_links | Links that improve attribution if present |
| required_packets | strategy_ids that must provide required_link evidence |
| supporting_packets | strategy_ids providing supporting evidence |
| failure_packets | strategy_ids detecting failure conditions |
| optional_packets | strategy_ids providing optional evidence |
| playbook_state_definitions | State transition rules (see PG.6) |
| event_order_contract | Ordered timing requirements (see PG.7) |
| attribution_requirements | What must be recorded post-trade |
| current_evidence_summary | Per-link evidence status from Nautilus certifications |
| missing_links | Links not yet evidenced |
| contradicted_links | Links with negative empirical evidence |
| research_status | NOT_STARTED / IN_PROGRESS / COMPLETE / BLOCKED |
| implementation_status | DESIGN_ONLY (until separately authorized) |
| runtime_authority_status | NONE (until separately authorized) |
| forbidden_actions | Specific MT5 changes blocked until explicit authorization |
| next_allowed_action | Next research action |

---

## PG.6 Playbook State Definitions

| State | Meaning | Does It Authorize Trade? |
|---|---|---|
| PLAYBOOK_NOT_PRESENT | No meaningful causal-chain activity. Required links absent. | NO |
| PLAYBOOK_FORMING | Some required links present, but thesis incomplete. | NO |
| PLAYBOOK_VALID | Required causal links present; no invalidating contradiction present. | NO — must still pass V1, Risk, Execution |
| PLAYBOOK_CONTRADICTED | A failure-mode or contradiction packet invalidates the thesis structure. | NO |
| PLAYBOOK_LATE | Evidence arrived after valid decision window or trigger timing no longer actionable. | NO |
| PLAYBOOK_INVALID | Required structure failed or became impossible in current context. | NO |

**None of these states authorize execution.** State emission is a thesis-qualification step only. V1 remains the permission authority.

---

## PG.7 Event Order Contract — Base Template

The following ordering is mandatory for all Playbooks. Late evidence cannot validate earlier decisions.

| Step | Event | Requirement |
|---|---|---|
| 1 | Regime / context known | Must precede trigger |
| 2 | Location known | Must be known before or at trigger |
| 3 | Trigger fires | The signal event |
| 4 | Confirmation / contradiction evaluated | Must be available before V1 consumption |
| 5 | Room and stop geometry known | Must be known before execution decision |
| 6 | Playbook State emitted | Must be emitted before V1 consumes it |
| 7 | V1 permission check | Separate system; consumes Playbook State as context |
| 8 | Attribution records final state | Records all packet/link states and outcome |

**Rule:** No confirmation, failure-mode, or room signal that arrives after step 3 may be counted as pre-trade evidence for that trigger. Attribution may use it for learning; execution may not.

---

## PG.8 Initial Playbook Evidence Summary (Current State)

Based on Phase 3 certification results to date (7/17 strategies certified):

### RBSR — Range Boundary Sweep-Reclaim

| Causal Link | Packet | Evidence Status |
|---|---|---|
| Context (RMR zone) | Environment | PROXY (zone_type not Nautilus-replicable) |
| Location (range boundary) | range_edge_fade | PARTIAL — fires at boundaries; zone proxy degrades |
| Trigger (sweep/rejection) | sweep_reversal | EDGE_WEAK_BUT_RECOVERABLE — boundary sweep detected |
| Reclaim (mean return) | bollinger_reclaim | EDGE_NOT_CONFIRMED standalone |
| Confirmation | range_edge_fade | REJECTED_PACKET (co-presence ubiquitous) |
| Failure mode | mfi_reversal_assist | FAILURE_MODE_PACKET (counter-direction) |
| Room | N/A | NOT_YET_TESTED |
| Stop geometry | N/A | NOT_YET_TESTED |

**RBSR Playbook research status:** IN_PROGRESS — alpha and failure-mode packets available; reclaim confirmation weak; room/stop not tested.

### TPC — Trend Pullback Continuation

| Causal Link | Packet | Evidence Status |
|---|---|---|
| Context (TC zone) | Environment | PROXY |
| Location | lower_high_rejection_v1 | RESEARCH_ONLY (SELL) |
| Trigger | trend_momentum | EDGE_WEAK_BUT_RECOVERABLE |
| Continuation | trend_pullback_cont_v1 | CONFIRM_SPARSE (certified but sparse) |
| Failure mode | micro_structure_reentry_v1 | FAILURE_MODE for LHR |
| Room | N/A | NOT_YET_TESTED |
| Stop geometry | N/A | NOT_YET_TESTED |

**TPC Playbook research status:** IN_PROGRESS — core alpha and confirmation sparse; failure-mode identified.

### VCR — Volatility Compression Release

| Causal Link | Packet | Evidence Status |
|---|---|---|
| Context (COMPRESSION zone) | Environment | NOT_YET_CERTIFIED |
| All links | range_compression_breakout, volatility_squeeze_release | DATA_INSUFFICIENT |

**VCR Playbook research status:** NOT_STARTED — no certified packets.

---

## PG.9 Forbidden Conclusions

This section does **NOT** authorize any of the following:

- MT5 source changes of any kind
- Runtime Playbook state consumption in V1 or any EA component
- Playbook gates (blocking or permitting trades based on Playbook state)
- Packet gates (blocking or permitting trades based on packet presence)
- Score creation or modification (playbook_score, completion %, quality bonus)
- council_quality threshold changes
- HIGH_CONVICTION condition changes
- CRR / DSN gate changes
- Strategy weight changes
- Strategy role changes
- RCEM enforcement changes
- Execution geometry changes
- Strategy injection (new strategies added)
- Strategy deletion or FROZEN status changes
- Production readiness improvement claim
- Advisory Layer authority transfer to Nautilus

**Nautilus remains EVIDENCE_ONLY. V1 remains runtime authority. Advisory Layer governs design and documentation only.**

---

## PG.10 Phase Implications

| Phase | Status |
|---|---|
| Playbook architecture | DESIGN_REFERENCE only — no runtime authority |
| Phase 3 certification | CONTINUING (7/17) — results feed Packet Registry |
| Registry design work | NEXT_NON_RUNTIME_PRIORITY |
| Ledger alignment planning | NEXT_NON_RUNTIME_PRIORITY after registry |
| Phase 4A (cross-family CRR) | BLOCKED — TPC fire rate unverified |
| Phase 4B (exhaustion veto) | BLOCKED — MFI 0 entries |
| Phase 4C (quality soft gate) | BLOCKED — Opportunity Ledger not live |
| Phase 5A (bollinger_reclaim SELL gate) | APPLIED; runtime validation pending reload |
| Phase 6 (EEWP) | DESIGN_ONLY — no implementation path active |
| System status | DEVELOPING |

---

## PG.11 Footer

```
SECTION:                  PLAYBOOK_GOVERNANCE_AND_REGISTRY_RULES_V1
DATE:                     2026-05-08
AUTHORITY:                Advisory Layer memo — documentation only
STATUS:                   DESIGN_REFERENCE
SOURCE_CHANGED:           NO
RUNTIME_CHANGED:          NO
MT5_AUTHORITY:            NONE
NAUTILUS_AUTHORITY:       NONE
PLAYBOOK_ROLE:            thesis-completion layer only
V1_ROLE:                  permission authority (unchanged)
EXECUTION_AUTHORITY:      unchanged — V1 + Execution Geometry + Risk
REGISTRY_DESIGN:          APPROVED for documentation — not yet implemented
RUNTIME_CONSUMPTION:      NOT_AUTHORIZED
PLAYBOOK_STATE:           categorical only — no numeric score
FAILURE_MODE_GATE:        NOT_AUTHORIZED — must follow maturity path
INITIAL_PLAYBOOKS:        RBSR, TPC, VCR (3 only; no expansion without approval)
PHASE_3_STATUS:           7/17 certified; feeds Packet Registry
FORBIDDEN:                All items listed in PG.9
NEXT_DESIGN_WORK:         Packet Registry → Playbook Registry → Causal Chains → Ledger Alignment Plan
SYSTEM_STATUS:            DEVELOPING
```

---

# FULL_STRATEGY_PACKET_AND_PLAYBOOK_REGISTRY_V1 — Comprehensive Evidence Packet Registry and Initial Playbook Registry

**Date:** 2026-05-08  
**Authority:** Advisory Layer — documentation only  
**Status:** DESIGN_REFERENCE — no runtime authority  
**Scope:** All 17 active strategies; 3 approved Playbooks (RBSR, TPC, VCR)

---

## REG.0 Registry Adoption Statement

This registry transitions Phase 3 from "run full certification for every strategy" to "classify every strategy into Packet and Playbook Registries, then run only targeted Nautilus tests where evidence gaps require it."

**Governing principle:** Strategy details matter only insofar as they define measurable packet contribution inside a Playbook.

All entries below are DESIGN_REFERENCE only. No entry authorizes an MT5 source change, runtime gate, weight change, role change, or score modification.

---

## REG.1 Registry Classification Rules

| Status | Meaning |
|---|---|
| ACCEPTED_PACKET | Measured contribution confirmed; rejection rule not triggered |
| REJECTED_PACKET | Failed intended role; no bounded unresolved hypothesis |
| RESEARCH_ONLY_PACKET | Specific bounded hypothesis with defined next test |
| DATA_INSUFFICIENT | Sample or source replication insufficient |
| PENDING_CERTIFICATION | Not yet tested; belongs to approved playbook — awaiting targeted Nautilus test |
| PARKED | No current playbook assignment; no immediate evidence need |
| FROZEN_OR_LEGACY | Strategy frozen or legacy in V1 source |

---

## REG.2 Packet Registry — All 17 Strategies

---

### REG.2.1 sweep_reversal

```
strategy_id:           sweep_reversal
current_family:        LIQUIDITY_REVERSAL
current_role:          SCOUT
current_vote_weight:   0.60
direction_bias:        BOTH
zone:                  REV (LIQUIDITY_REVERSAL)

proposed_packet_roles:
  - ALPHA_TRIGGER_PACKET: liquidity sweep / boundary violation detector in RBSR

rejected_packet_roles:
  - None yet confirmed as rejected

layer_ownership:
  - Alpha / Thesis (sweep event = thesis initiator in RBSR)

valid_contexts:
  - REV zone, counter-trend sweeps strongest
  - SELL direction in trend context

invalid_contexts:
  - BUY in RANGE_NEUTRAL (weakest subset in cert)
  - TREND_DOWN BUY combination

playbook_candidates:
  - RANGE_BOUNDARY_SWEEP_RECLAIM (primary alpha event)

current_evidence_status:   EDGE_WEAK_BUT_RECOVERABLE
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE (WR=42.9%, E[R] approx 0)
composite_cert_status:     NOT_YET_RUN (composite RBSR pilot inconclusive)
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    RESEARCH_ONLY_PACKET
rejection_rule:            Reject ALPHA role if sweep detection does not precede RBSR
                           composite improvement by >= +2pp WR or +0.04R E[R]

missing_evidence:          Composite RBSR playbook replay isolating sweep → reclaim chain
next_allowed_action:       Design bounded composite RBSR Nautilus test;
                           no MT5 change authorized
runtime_authority_status:  NONE
```

---

### REG.2.2 bollinger_reclaim

```
strategy_id:           bollinger_reclaim
current_family:        MEAN_RECLAIM
current_role:          CONFIRM
current_vote_weight:   1.00
direction_bias:        BOTH
zone:                  RMR, REV

proposed_packet_roles:
  - RECLAIM_PACKET candidate: mean-reclaim confirmation leg in RBSR

rejected_packet_roles:
  - STANDALONE_ALPHA: weak/negative standalone expectancy
  - VWAP_REPLACEMENT: VWAP candidate rejected in direct comparison

layer_ownership:
  - Alpha / Thesis (reclaim leg: measures return to mean)

valid_contexts:
  - RMR zone; RMR SELL direction marginally better

invalid_contexts:
  - RANGE_NEUTRAL (weakest regime in cert)
  - TREND_DOWN BUY

playbook_candidates:
  - RANGE_BOUNDARY_SWEEP_RECLAIM (reclaim leg)

current_evidence_status:   EDGE_NOT_CONFIRMED (standalone weak; composite inconclusive)
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE technically; negative expectancy runs
composite_cert_status:     NOT_CONFIRMED in composite RBSR pilot (Phase 5A challenged)
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    RESEARCH_ONLY_PACKET
rejection_rule:            Reject RECLAIM role if composite RBSR replay shows
                           bollinger_reclaim co-presence does not improve chain E[R]
                           by >= +0.04R vs without

missing_evidence:          Source-faithful composite RBSR chain replay measuring
                           bollinger_reclaim as RECLAIM vs NO_RECLAIM subgroup
next_allowed_action:       Composite RBSR Nautilus test (targeted);
                           Phase 5A SELL-gate runtime validation still pending reload
runtime_authority_status:  NONE
```

---

### REG.2.3 trend_momentum

```
strategy_id:           trend_momentum
current_family:        TREND_CONTINUATION
current_role:          TREND_JUDGE
current_vote_weight:   0.95
direction_bias:        BOTH
zone:                  TC, BREAKOUT_EXPANSION

proposed_packet_roles:
  - ALPHA_TRIGGER_PACKET (regime-qualified): primary trend continuation signal in TPC

rejected_packet_roles:
  - STANDALONE_PRODUCTION_ALPHA: insufficient edge without regime conditioning

layer_ownership:
  - Alpha / Thesis (trend continuation signal)

valid_contexts:
  - SELL direction; RANGE_NEUTRAL × SELL strongest subset
  - Gated variant (M5_CONFLICT excluded) improves edge
  - Not-late guard active in V1 (Phase 1/2 packages applied)

invalid_contexts:
  - TREND_UP × BUY (weakest subset; harmful)
  - M5_CONFLICT condition (EMA20 < EMA50 and price below EMA20 in M5)
  - Over-extended entry (late-entry gate addresses this)

playbook_candidates:
  - TREND_PULLBACK_CONTINUATION (primary alpha)

current_evidence_status:   EDGE_WEAK_BUT_RECOVERABLE
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE (Variant A WR ~40.7%, cert-year data)
composite_cert_status:     Partial — TPC co-presence analysis run; improves with TPC present
replication_status:        PARTIAL_REPLICATION (entry timing proxy; zone proxy)

accepted_packet_status:    RESEARCH_ONLY_PACKET (regime-qualified)
rejection_rule:            Reject ALPHA role if regime-gated E[R] remains negative
                           after M5_CONFLICT exclusion at N >= 50 in targeted regime

missing_evidence:          Regime-gated isolation E[R] confirmed positive at N >= 100;
                           30+ post-guard live trades for runtime validation
next_allowed_action:       Monitor live performance post entry-timing guard;
                           no further Nautilus test required immediately
runtime_authority_status:  NONE (guard applied; no further weight/role change authorized)
```

---

### REG.2.4 mfi_reversal_assist

```
strategy_id:           mfi_reversal_assist
current_family:        MOM_REVERSAL_ASSIST
current_role:          EXHAUSTION_JUDGE
current_vote_weight:   0.90
direction_bias:        BOTH
zone:                  REV

proposed_packet_roles:
  - CONFIRMATION_PACKET candidate (same-direction): reinforces RBSR sweep direction
  - FAILURE_MODE_PACKET candidate (counter-direction): opposes RBSR sweep direction

rejected_packet_roles:
  - VETO_PACKET against trend_momentum: 45/55 threshold veto NOT_CONFIRMED
    (Phase 4B threshold not calibrated from live data; 0 entries to date)

layer_ownership:
  - Risk / Attribution (failure-mode candidate — counter-direction)
  - Alpha support (same-direction candidate — reinforcing)

valid_contexts:
  - Same-direction as sweep_reversal (RBSR same-dir): improving E[R] observed
  - Counter-direction as failure-mode signal: degradation observed

invalid_contexts:
  - As exhaustion veto against TC/BREAKOUT (Phase 4B BLOCKED — threshold hypothetical)

playbook_candidates:
  - RANGE_BOUNDARY_SWEEP_RECLAIM (both roles)

current_evidence_status:   EDGE_WEAK_BUT_RECOVERABLE standalone
                           same-dir promising; counter-dir failure-mode supported
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE
composite_cert_status:     SR+MFI same-dir improves E[R] but misses +2pp/+0.04R
                           SR+MFI counter-dir failure-mode: degradation confirmed
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    RESEARCH_ONLY_PACKET (both roles)
rejection_rule (confirm):  Reject if MFI same-direction co-presence does not produce
                           WR lift >= +2pp AND E[R] lift >= +0.04R vs without-MFI
rejection_rule (fail-mode): Reject if MFI counter-direction shows no consistent E[R]
                            degradation vs absence at N >= 100

missing_evidence:          Formal composite RBSR test isolating same-dir and counter-dir
                           MFI with N >= 100 per group; live signal readings (0 entries)
next_allowed_action:       Monitor Phase 4B preconditions (first live MFI entries);
                           composite RBSR Nautilus test;
                           veto threshold design BLOCKED until live readings available
runtime_authority_status:  NONE
```

---

### REG.2.5 trend_pullback_cont_v1

```
strategy_id:           trend_pullback_cont_v1
current_family:        TREND_PULLBACK_CONT
current_role:          CONFIRM
current_vote_weight:   0.80
direction_bias:        BOTH
zone:                  TC, RMR (era-conditioned)

proposed_packet_roles:
  - CONFIRM_PACKET_SPARSE: cross-family TC confirmation in TPC playbook

rejected_packet_roles:
  - MANDATORY_GATE: too sparse as forced Phase 4A CRR gate (TOO_SPARSE_FOR_PHASE_4A)

layer_ownership:
  - Alpha / Thesis (pullback continuation confirmation — cross-family from TC)

valid_contexts:
  - TC zone; pullback depth 0.5–1.5 ATR; co-present with trend_momentum
  - Only cross-family TC confirmer available (TREND_PULLBACK_CONT family vs TREND_CONTINUATION)

invalid_contexts:
  - Forced mandatory gate (starvation risk in TC zone)
  - Era-conditioned RMR firing (insufficient runtime data)

playbook_candidates:
  - TREND_PULLBACK_CONTINUATION (confirmation leg)

current_evidence_status:   EDGE_SUPPORTED standalone; co-presence improves TM outcomes
standalone_cert_status:    EDGE_SUPPORTED (WR > 45% standalone; depth-sensitive)
composite_cert_status:     Co-presence with trend_momentum shows WR/E[R] improvement
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    CONFIRM_PACKET_SPARSE (research designation — not a gate)
rejection_rule:            Reject CONFIRM role if co-presence rate with trend_momentum
                           falls below 15% of eligible TC bars (starvation risk)

missing_evidence:          Live runtime fire rate in TC zone (0 entries still as of §28);
                           5+ distinct live firings required before Phase 4A CRR design
next_allowed_action:       Monitor live runtime fire rate; no Phase 4A gate change yet
runtime_authority_status:  NONE (0.70 ATR gate applied; no CRR gate change authorized)
```

---

### REG.2.6 micro_structure_reentry_v1

```
strategy_id:           micro_structure_reentry_v1
current_family:        TREND_CONTINUATION
current_role:          CONFIRM
current_vote_weight:   0.70
direction_bias:        BOTH (SELL direction only reliable)
zone:                  TC

proposed_packet_roles:
  - FAILURE_MODE_PACKET candidate: MSR co-presence predicts worse LHR outcomes

rejected_packet_roles:
  - CONFIRMATION_PACKET: ubiquitous co-presence (72.9% with LHR); negative lift
  - BUY_ALPHA: BUY direction EDGE_NOT_CONFIRMED

layer_ownership:
  - Risk / Attribution (failure-mode for LHR — when MSR fires near LHR, LHR degrades)

valid_contexts:
  - SELL direction in TC zone (WR=39.3%, E[R] marginally recoverable)
  - SELL × TREND_UP marginally positive E[R]=+0.003R

invalid_contexts:
  - BUY direction (EDGE_NOT_CONFIRMED across all regime conditions)
  - BUY × RANGE_NEUTRAL (worst subset: WR=36.3%, E[R]=-0.092R)

playbook_candidates:
  - TREND_PULLBACK_CONTINUATION (FAILURE_MODE for LHR leg — caution: selection bias)

current_evidence_status:   EDGE_WEAK_BUT_RECOVERABLE overall; BUY REJECTED
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE (SELL); EDGE_NOT_CONFIRMED (BUY)
composite_cert_status:     FAILURE_MODE accepted: E[R] degradation -0.068R (threshold -0.06R)
                           Selection bias caveat: without-MSR WR=48.3% implausibly high
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    RESEARCH_ONLY_PACKET (failure-mode for LHR with caution)
rejection_rule:            Reject failure-mode role if market-state-controlled test
                           shows degradation disappears (selection bias explanation confirmed)

missing_evidence:          Market-state-controlled test to distinguish failure-mode
                           from selection-bias in without-MSR subgroup
next_allowed_action:       Design bounded market-state-controlled overlay test (Nautilus)
                           before treating as confirmed failure-mode gate
runtime_authority_status:  NONE
```

---

### REG.2.7 breakdown_momentum_v1

```
strategy_id:           breakdown_momentum_v1
current_family:        TREND_CONTINUATION
current_role:          CONFIRM
current_vote_weight:   0.68
direction_bias:        SELL
zone:                  TC

proposed_packet_roles:
  - RESEARCH_ONLY_UNCLASSIFIED: RANGE_NEUTRAL regime hypothesis only

rejected_packet_roles:
  - TC_CONFIRM_PACKET: REJECTED — TREND_DOWN worst; dual-bear gate counterproductive
  - RANGE_NEUTRAL_CONFIRMED: not yet formally tested; conditional research only

layer_ownership:
  - None confirmed (intended Alpha support; empirically rejected in TC context)

valid_contexts:
  - RANGE_NEUTRAL regime (unexpectedly better in cert; not yet isolated)

invalid_contexts:
  - TC zone TREND_DOWN: worst regime (opposite of design intent)
  - dual-bear gate active: degrades outcomes
  - Recency: severe deterioration in late data

playbook_candidates:
  - None confirmed; RANGE_NEUTRAL isolation is a bounded hypothesis

current_evidence_status:   EDGE_REJECTED for intended role; RANGE_NEUTRAL unverified
standalone_cert_status:    EDGE_NOT_CONFIRMED (overall); EDGE_REJECTED in TREND_DOWN
composite_cert_status:     Not run in composite context
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    REJECTED_PACKET (TC confirm role); RESEARCH_ONLY conditional
rejection_rule:            Reject all roles if RANGE_NEUTRAL isolation at N >= 50
                           does not show E[R] >= 0

missing_evidence:          RANGE_NEUTRAL isolation test (bounded Nautilus test)
next_allowed_action:       PARKED pending RANGE_NEUTRAL isolation decision;
                           no TC role change authorized
runtime_authority_status:  NONE
```

---

### REG.2.8 lower_high_rejection_v1

```
strategy_id:           lower_high_rejection_v1
current_family:        TREND_CONTINUATION
current_role:          CONFIRM
current_vote_weight:   0.66
direction_bias:        SELL
zone:                  TC

proposed_packet_roles:
  - LOCATION_PACKET: lower-high structure identifies SELL location within TC zone
  - CONFIRM_PACKET (SELL): sequential lower-high structure confirms TC SELL direction

rejected_packet_roles:
  - BUY: SELL_ONLY strategy by design; no BUY evidence tested

layer_ownership:
  - Alpha / Thesis (location of lower-high structure = pullback termination signal)

valid_contexts:
  - TC zone SELL direction; TC proxy near breakeven (WR=40.15%, E[R]=+0.004R)
  - TREND_DOWN best regime (WR=40.12%, E[R]=+0.003R)
  - Gate (dual-bear gate) helps: +0.86pp WR, +0.021R E[R]

invalid_contexts:
  - TREND_UP (WR=37.96%, E[R]=-0.051R; NOT_CONFIRMED)
  - LH gap weak subset (WR=38.27%)
  - LATE period (degradation hint: WR=37.96%, NOT_CONFIRMED post-split)

playbook_candidates:
  - TREND_PULLBACK_CONTINUATION (SELL location / confirm candidate)

current_evidence_status:   EDGE_WEAK_BUT_RECOVERABLE
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE (WR=39.0%, E[R]=-0.025R)
composite_cert_status:     MSR failure-mode overlay run: MSR co-presence predicts LHR
                           degradation (accepted failure-mode packet)
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    RESEARCH_ONLY_PACKET (SELL TC confirm/location)
rejection_rule:            Reject CONFIRM role if TREND_DOWN × SELL isolation
                           at N >= 100 shows E[R] < 0 after dual-bear gate applied

missing_evidence:          SELL × TREND_DOWN isolated cell with N >= 100 (currently
                           estimated ~300-400 SELL triggers but cell not formally run);
                           MSR failure-mode market-state control
next_allowed_action:       SELL × TREND_DOWN isolation test (bounded; same Nautilus pass)
runtime_authority_status:  NONE
```

---

### REG.2.9 range_edge_fade

```
strategy_id:           range_edge_fade
current_family:        MEAN_RECLAIM
current_role:          CONFIRM
current_vote_weight:   0.88
direction_bias:        BOTH (SELL better)
zone:                  RMR

proposed_packet_roles:
  - NONE — H1 SELL × TREND_DOWN FALSIFIED (REF_SELL_TREND_DOWN_ISOLATION_V1, 2026-05-08)
  - BUY × TREND_DOWN secondary RESEARCH_ONLY finding (N=191, E[R]=+0.008R — too thin; not a candidate)

rejected_packet_roles:
  - ALPHA_TRIGGER_PACKET via SELL×TREND_DOWN: FALSIFIED — N=2 structural absence
  - LOCATION_PACKET: zone proxy (RANGE_NEUTRAL gate) degrades outcomes
  - CONFIRMATION_PACKET (RBSR chain): SR/BR co-presence ubiquitous (88-94%); no lift

layer_ownership:
  - NONE currently — no accepted packet role

valid_contexts:
  - TREND_DOWN regime: WR=40.93%, E[R]=+0.023R (driven by BUY×TD, not SELL×TD)
  - BUY × TREND_DOWN: WR=40.31%, E[R]=+0.008R (secondary; too thin)
  - SELL direction aggregate: WR=38.92%, E[R]=-0.027R (better than BUY but still negative)
  - LATE period: WR=42.58%, E[R]=+0.065R (April–May 2026)

invalid_contexts:
  - SELL × TREND_DOWN: N=2, structurally absent — not a valid operating context
  - RANGE_NEUTRAL (worst regime: WR=37.13%, E[R]=-0.072R — zone proxy degrades)
  - BUY direction aggregate: WR=37.98%, E[R]=-0.051R (NOT_CONFIRMED)
  - EARLY period (Jan–Mar 2026): WR=35.77%, E[R]=-0.106R

playbook_candidates:
  - RANGE_BOUNDARY_SWEEP_RECLAIM (BUY×TD secondary finding only; no confirmed link)

current_evidence_status:   EDGE_WEAK_BUT_RECOVERABLE; no packets formally accepted
standalone_cert_status:    EDGE_WEAK_BUT_RECOVERABLE (A: WR=38.5%, E[R]=-0.038R)
composite_cert_status:     No composite run yet
replication_status:        PARTIAL_REPLICATION

accepted_packet_status:    NO_PACKET_ACCEPTED — H1 FALSIFIED; BUY×TD secondary RESEARCH_ONLY only
rejection_rule:            SELL×TREND_DOWN rejected on structural absence (N=2);
                           BUY×TREND_DOWN not accepted (E[R]=+0.008R too thin; mixed threshold test)

missing_evidence:          No immediate missing evidence — H1 test complete;
                           BUY×TREND_DOWN H2 optional only (LOW_PRIORITY)
next_allowed_action:       NO further REF micro-tests authorized — proceed to architecture
                           build-out phase; H2 (BUY×TD) may be queued optionally only if
                           RBSR architecture later explicitly requires it
runtime_authority_status:  NONE
```

---

### REG.2.10 momentum_breakout_cont_v1

```
strategy_id:           momentum_breakout_cont_v1
current_family:        TREND_CONTINUATION
current_role:          [FROZEN]
current_vote_weight:   0.00
direction_bias:        —
zone:                  — (FROZEN)

proposed_packet_roles:  None while FROZEN

rejected_packet_roles:
  - TC_CONFIRM: WR=9.1% (1W/10L) — EDGE_REJECTED with N >= 10

layer_ownership:        None (FROZEN)

valid_contexts:         None confirmed
invalid_contexts:       All contexts (EDGE_REJECTED)

playbook_candidates:    None

current_evidence_status:   EDGE_REJECTED
standalone_cert_status:    EDGE_REJECTED (1W/10L = 9.1%)
replication_status:        LIVE_ONLY (no full Nautilus cert; WR from runtime)

accepted_packet_status:    FROZEN_OR_LEGACY
rejection_rule:            No packet admission while FROZEN;
                           redesign requires separate authorization and separate plan

missing_evidence:          N/A (FROZEN; no testing authorized)
next_allowed_action:       No action; keep FROZEN; no redesign without separate plan
runtime_authority_status:  NONE (weight=0.00; no execution)
```

---

### REG.2.11 mean_reversion_bounce

```
strategy_id:           mean_reversion_bounce
current_family:        MEAN_RECLAIM
current_role:          CONFIRM
current_vote_weight:   0.92
direction_bias:        BOTH
zone:                  RMR

proposed_packet_roles:
  - RECLAIM_PACKET candidate in RBSR (mean bounce at RMR zone)

rejected_packet_roles:  None yet (no cert run)

layer_ownership:        Alpha / Thesis (reclaim leg) — pending evidence

valid_contexts:         Unknown — SOURCE_READ_REQUIRED for exact trigger
invalid_contexts:       Unknown

playbook_candidates:
  - RANGE_BOUNDARY_SWEEP_RECLAIM (potential reclaim leg alongside bollinger_reclaim)

current_evidence_status:   DATA_INSUFFICIENT (0W/0L/1 entry from live runtime)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject RECLAIM role if composite RBSR replay shows
                           no E[R] improvement with mean_reversion_bounce present

missing_evidence:          Source read of trigger logic; targeted RBSR composite test
next_allowed_action:       Source read first; then assess if composite RBSR test warranted
runtime_authority_status:  NONE
```

---

### REG.2.12 fake_break_reversal

```
strategy_id:           fake_break_reversal
current_family:        LIQUIDITY_REVERSAL
current_role:          SCOUT
current_vote_weight:   0.94
direction_bias:        BOTH
zone:                  RMR

proposed_packet_roles:
  - ALPHA_TRIGGER_PACKET candidate in RBSR (false breakout / fake break detector)
  - Complements sweep_reversal as alternative boundary violation signal

rejected_packet_roles:  None yet (no cert run)

layer_ownership:        Alpha / Thesis (boundary violation detection)

valid_contexts:         Unknown — SOURCE_READ_REQUIRED
invalid_contexts:       Unknown

playbook_candidates:
  - RANGE_BOUNDARY_SWEEP_RECLAIM (alternative alpha alongside sweep_reversal)

current_evidence_status:   DATA_INSUFFICIENT (0 live entries)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject ALPHA role if fake_break_reversal standalone replay
                           shows WR < 38% and E[R] < 0 at N >= 100

missing_evidence:          Source read; standalone Nautilus cert (RBSR context priority)
next_allowed_action:       Source read → standalone cert (targeted RBSR Nautilus test)
runtime_authority_status:  NONE
```

---

### REG.2.13 range_compression_breakout

```
strategy_id:           range_compression_breakout
current_family:        COMPRESSION_BREAKOUT
current_role:          SCOUT
current_vote_weight:   0.95
direction_bias:        BOTH
zone:                  COMPRESSION, BREAKOUT_EXPANSION

proposed_packet_roles:
  - ALPHA_TRIGGER_PACKET candidate in VCR (compression detection + breakout signal)

rejected_packet_roles:  None yet (no cert)

layer_ownership:        Alpha / Thesis (breakout initiation in VCR)

valid_contexts:         Unknown — SOURCE_READ_REQUIRED
invalid_contexts:       Unknown

playbook_candidates:
  - VOLATILITY_COMPRESSION_RELEASE (primary alpha candidate)

current_evidence_status:   DATA_INSUFFICIENT (0 live entries)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject ALPHA role if VCR composite replay shows
                           no WR/E[R] improvement with range_compression_breakout present

missing_evidence:          Source read; VCR playbook causal chain definition first
next_allowed_action:       Source read → VCR causal chain design → targeted Nautilus
runtime_authority_status:  NONE
```

---

### REG.2.14 volatility_squeeze_release

```
strategy_id:           volatility_squeeze_release
current_family:        COMPRESSION_BREAKOUT
current_role:          CONFIRM
current_vote_weight:   0.92
direction_bias:        BOTH
zone:                  COMPRESSION, BREAKOUT_EXPANSION

proposed_packet_roles:
  - CONFIRM_PACKET candidate in VCR (post-compression expansion confirmation)

rejected_packet_roles:  None yet (no cert)

layer_ownership:        Alpha / Thesis (expansion confirmation in VCR)

valid_contexts:         Unknown — SOURCE_READ_REQUIRED
invalid_contexts:       Unknown

playbook_candidates:
  - VOLATILITY_COMPRESSION_RELEASE

current_evidence_status:   DATA_INSUFFICIENT (0 live entries)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject CONFIRM role if co-presence with range_compression_breakout
                           shows no measurable lift in VCR composite test

missing_evidence:          Source read; VCR composite test
next_allowed_action:       Source read → VCR causal chain design first
runtime_authority_status:  NONE
```

---

### REG.2.15 volatility_breakout

```
strategy_id:           volatility_breakout
current_family:        VOL_BREAKOUT
current_role:          TREND_JUDGE
current_vote_weight:   0.92
direction_bias:        BOTH
zone:                  BREAKOUT_EXPANSION

proposed_packet_roles:
  - ALPHA_TRIGGER_PACKET candidate in VCR (volatility-driven breakout)

rejected_packet_roles:  None yet (no cert)

layer_ownership:        Alpha / Thesis (breakout alpha in VCR or standalone EXP)

valid_contexts:         Unknown — SOURCE_READ_REQUIRED
invalid_contexts:       Unknown

playbook_candidates:
  - VOLATILITY_COMPRESSION_RELEASE (breakout leg)

current_evidence_status:   DATA_INSUFFICIENT (0 live entries)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject if standalone WR < 38% at N >= 100

missing_evidence:          Source read; standalone Nautilus cert
next_allowed_action:       Source read → targeted standalone cert (VCR context)
runtime_authority_status:  NONE
```

---

### REG.2.16 expansion_continuation

```
strategy_id:           expansion_continuation
current_family:        EXP_CONTINUATION
current_role:          TREND_JUDGE
current_vote_weight:   0.90
direction_bias:        BOTH
zone:                  BREAKOUT_EXPANSION

proposed_packet_roles:
  - CONFIRM_PACKET candidate in VCR (expansion continuation after breakout)

rejected_packet_roles:  None yet (no cert)

layer_ownership:        Alpha / Thesis (continuation leg in VCR)

valid_contexts:         Unknown — SOURCE_READ_REQUIRED
invalid_contexts:       Unknown

playbook_candidates:
  - VOLATILITY_COMPRESSION_RELEASE

current_evidence_status:   DATA_INSUFFICIENT (0 live entries)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject if standalone E[R] < 0 at N >= 100 in EXP zone

missing_evidence:          Source read; standalone Nautilus cert
next_allowed_action:       Source read → targeted standalone cert
runtime_authority_status:  NONE
```

---

### REG.2.17 micro_range_expansion

```
strategy_id:           micro_range_expansion
current_family:        MICRO_RANGE_BREAK
current_role:          SCOUT
current_vote_weight:   0.88
direction_bias:        BOTH
zone:                  BREAKOUT_EXPANSION

proposed_packet_roles:
  - ALPHA_TRIGGER_PACKET candidate in VCR (micro-range break as early expansion signal)

rejected_packet_roles:  None yet (no cert)

layer_ownership:        Alpha / Thesis (early expansion alpha in VCR)

valid_contexts:         Unknown — SOURCE_READ_REQUIRED
invalid_contexts:       Unknown

playbook_candidates:
  - VOLATILITY_COMPRESSION_RELEASE

current_evidence_status:   DATA_INSUFFICIENT (0 live entries)
standalone_cert_status:    DATA_INSUFFICIENT
replication_status:        SOURCE_READ_REQUIRED

accepted_packet_status:    PENDING_CERTIFICATION
rejection_rule:            Reject if standalone WR < 38% at N >= 100

missing_evidence:          Source read; standalone Nautilus cert
next_allowed_action:       Source read → targeted standalone cert
runtime_authority_status:  NONE
```

---

## REG.3 Strategy-to-Playbook Mapping

| strategy_id | RBSR | TPC | VCR | Other | Packet Status |
|---|---|---|---|---|---|
| sweep_reversal | ALPHA candidate | — | — | — | RESEARCH_ONLY |
| bollinger_reclaim | RECLAIM candidate | — | — | — | RESEARCH_ONLY |
| trend_momentum | — | ALPHA candidate | — | — | RESEARCH_ONLY |
| mfi_reversal_assist | CONFIRM+FAIL_MODE | FAIL_MODE candidate | — | — | RESEARCH_ONLY |
| trend_pullback_cont_v1 | — | CONFIRM_SPARSE | — | — | CONFIRM_SPARSE |
| momentum_breakout_cont_v1 | — | — | — | — | FROZEN |
| micro_structure_reentry_v1 | — | FAIL_MODE (LHR) | — | — | RESEARCH_ONLY |
| breakdown_momentum_v1 | — | REJECTED | — | — | REJECTED (TC) |
| lower_high_rejection_v1 | — | LOCATION/CONFIRM | — | — | RESEARCH_ONLY |
| mean_reversion_bounce | RECLAIM candidate | — | — | — | PENDING |
| range_edge_fade | ALPHA candidate | — | — | — | RESEARCH_ONLY |
| fake_break_reversal | ALPHA candidate | — | — | — | PENDING |
| range_compression_breakout | — | — | ALPHA candidate | — | PENDING |
| volatility_squeeze_release | — | — | CONFIRM candidate | — | PENDING |
| volatility_breakout | — | — | ALPHA/CONFIRM | — | PENDING |
| expansion_continuation | — | — | CONFIRM candidate | — | PENDING |
| micro_range_expansion | — | — | ALPHA candidate | — | PENDING |

---

## REG.4 Playbook Registry

---

### REG.4.1 RANGE_BOUNDARY_SWEEP_RECLAIM (RBSR)

```
playbook_id:         RANGE_BOUNDARY_SWEEP_RECLAIM
family:              LIQUIDITY_REVERSAL + MEAN_RECLAIM
thesis_statement:    Price sweeps beyond a range boundary (liquidity grab), then
                     reclaims back into the range with a mean-return move; this
                     sweep-and-reclaim pattern carries a directional edge when
                     confirmed by reclaim structure.

causal_chain_links:
  1. Zone / regime context     (RMR zone; ranging conditions)
  2. Range boundary location   (range high or low identified)
  3. Liquidity sweep event     (price violates boundary; rejection candle)
  4. Reclaim / mean return     (price returns to range interior / mean)
  5. Confirmation signal       (secondary confirm or no failure-mode)
  6. No failure-mode           (counter-direction momentum absent)
  7. Room to target            (distance from entry to mean or opposite boundary)
  8. Stop geometry             (stop beyond sweep extreme)
  9. Outcome attribution

required_links:      [3. sweep, 4. reclaim, 7. room]
supporting_links:    [1. zone context, 5. confirmation, 8. stop geometry]
failure_links:       [6. counter-direction momentum (MFI counter)]
optional_links:      [2. formal boundary identification, 9. attribution fields]

required_packets:
  - sweep_reversal (link 3: sweep event)
  - [reclaim packet TBD: bollinger_reclaim or mean_reversion_bounce] (link 4)

supporting_packets:
  - mfi_reversal_assist same-direction (link 5: confirmation)
  - range_edge_fade BUY×TREND_DOWN secondary (link 2/3: H1 SELL×TD FALSIFIED 2026-05-08; BUY×TD secondary RESEARCH_ONLY — E[R]=+0.008R, not accepted)

failure_packets:
  - mfi_reversal_assist counter-direction (link 6: failure-mode signal)

optional_packets:
  - fake_break_reversal (alternative boundary violation detector)
  - bollinger_reclaim (reclaim confirmation; current status: weak)

current_accepted_packets:   NONE formally accepted
rejected_packets:
  - bollinger_reclaim standalone: weak/negative standalone expectancy
  - range_edge_fade as CONFIRM: co-presence ubiquitous; no lift

missing_links:
  - Link 4 (reclaim): no confirmed reclaim packet; bollinger_reclaim weak
  - Link 7 (room): not yet tested
  - Link 8 (stop geometry): not yet tested

contradicted_links:
  - Link 4 (bollinger_reclaim as reclaim confirm): composite pilot inconclusive
  - Link 6 (mfi counter-direction): degradation observed — supports failure-mode

event_order_contract:
  1. RMR zone context must precede trigger
  2. Range boundary must be identifiable before or at sweep candle
  3. Sweep_reversal trigger (link 3) fires on rejection candle
  4. MFI direction (link 5/6) must be observable BEFORE V1 consumption
  5. Reclaim signal (link 4) should be observable within defined bar window
  6. Room measurement (link 7) at time of entry decision
  7. Playbook State emitted after all available links evaluated
  8. Attribution records all link states and outcome

attribution_requirements:
  - sweep_present: true/false
  - reclaim_present: true/false
  - mfi_direction: same/counter/absent
  - room_to_mean: estimated_R
  - stop_below_sweep: true/false
  - outcome: WIN/LOSS/OPEN
  - failed_link: which link broke the chain (if any)

current_evidence_summary:
  - Link 3 (sweep): sweep_reversal RESEARCH_ONLY; WR=42.9% standalone
  - Link 4 (reclaim): bollinger_reclaim weak; mean_reversion_bounce uncertified
  - Link 5 (confirm): mfi_reversal_assist same-dir promising; not threshold-confirmed
  - Link 6 (fail-mode): mfi_reversal_assist counter-dir degradation observed
  - Links 1,2,7,8: not formally tested

research_status:          IN_PROGRESS (links 3,6 partially evidenced; chain incomplete)
implementation_status:    DESIGN_ONLY
runtime_authority_status: NONE
playbook_state:           PLAYBOOK_FORMING

forbidden_actions:
  - Emit PLAYBOOK_VALID until ALL required links evidenced at N >= 50 per link
  - Create gate: "if RBSR valid → execute" — NOT_AUTHORIZED
  - Use bollinger_reclaim co-presence as CONFIRM gate — rejected
  - Use SR fire rate to gate other strategies
  - Any MT5 source change based on RBSR state

next_allowed_action:
  - Composite RBSR Nautilus replay (sweep → reclaim → MFI chain)
  - mean_reversion_bounce source read
  - fake_break_reversal source read + standalone cert
```

---

### REG.4.2 TREND_PULLBACK_CONTINUATION (TPC)

```
playbook_id:         TREND_PULLBACK_CONTINUATION
family:              TREND_CONTINUATION + TREND_PULLBACK_CONT
thesis_statement:    In an established trend, price pulls back to a structural
                     level (lower high in SELL, higher low in BUY), then
                     resumes the trend; this continuation pattern carries
                     directional edge when confirmed by pullback structure
                     and cross-family confirmation.

causal_chain_links:
  1. TC zone / trend context   (trend regime established)
  2. Trend direction           (SELL dominant or BUY dominant)
  3. Pullback to key level     (retest of structure; lower high for SELL)
  4. Location gate             (lower_high_rejection_v1: SELL structural location)
  5. Continuation trigger      (trend_momentum fires in trend direction)
  6. Cross-family confirmation (trend_pullback_cont_v1: TREND_PULLBACK_CONT family)
  7. No exhaustion / failure-mode (mfi veto absent; MSR not co-present near LHR)
  8. Room to next level        (distance to next structural target)
  9. Stop geometry             (stop above lower high for SELL)
  10. Outcome attribution

required_links:      [1. TC context, 5. continuation trigger, 6. cross-family confirm]
supporting_links:    [3. pullback, 4. location gate, 8. room]
failure_links:       [7. failure-mode: MSR near LHR degrades; mfi counter]
optional_links:      [2. direction confirmation, 9. stop geometry, 10. attribution]

required_packets:
  - trend_momentum (link 5: continuation alpha)
  - trend_pullback_cont_v1 (link 6: cross-family confirm)

supporting_packets:
  - lower_high_rejection_v1 (link 4: SELL location gate — research-only)

failure_packets:
  - micro_structure_reentry_v1 (link 7: failure-mode when near LHR)
  - mfi_reversal_assist counter-direction (link 7: exhaustion signal)

current_accepted_packets:   NONE formally accepted
  - trend_pullback_cont_v1: CONFIRM_PACKET_SPARSE designation
  - trend_momentum: RESEARCH_ONLY alpha
  - lower_high_rejection_v1: RESEARCH_ONLY location/confirm
rejected_packets:
  - breakdown_momentum_v1: REJECTED for TC confirm role
  - micro_structure_reentry_v1 as CONFIRM: ubiquitous; no lift
  - mfi veto under current 45/55 thresholds: NOT_CONFIRMED

missing_links:
  - Link 3 (pullback quality): no formal pullback depth gating tested in composite
  - Link 8 (room): not tested
  - Link 9 (stop geometry): not tested
  - Direction-conditioned composite: TM+TPC+LHR chain not run together

contradicted_links:
  - Link 6 via BDM: BDM rejected as TC confirm; gate-based cross-family fail
  - Link 7 via MSR: MSR co-presence degrades LHR (failure-mode accepted)

event_order_contract:
  1. TC zone / trend regime confirmed before trigger
  2. Pullback structure observable before trigger
  3. LHR fires (lower-high structure confirmed) — link 4
  4. trend_momentum trigger fires — link 5
  5. TPC confirm signal observable (within defined bar window) — link 6
  6. MSR / MFI failure-mode status observable BEFORE V1 consumption — link 7
  7. Room and stop geometry known before execution decision
  8. Playbook State emitted
  9. Attribution records all link states and outcome

attribution_requirements:
  - tc_context: true/false
  - lower_high_present: true/false
  - trend_momentum_fired: true/false
  - tpc_confirmed: true/false
  - msr_nearby: true/false (failure-mode flag)
  - mfi_direction: same/counter/absent
  - room_to_target: estimated_R
  - outcome: WIN/LOSS/OPEN
  - failed_link: which link broke (if any)

current_evidence_summary:
  - Link 5 (TM alpha): RESEARCH_ONLY; WR ~40.7%
  - Link 6 (TPC confirm): CONFIRM_SPARSE; EDGE_SUPPORTED standalone; sparse co-presence
  - Link 4 (LHR location): RESEARCH_ONLY; WR=39.0%
  - Link 7 (MSR fail-mode): RESEARCH_ONLY; E[R] degradation -0.068R accepted
  - Link 7 (MFI veto): REJECTED under current thresholds
  - Links 3,8,9: not tested in composite

research_status:          IN_PROGRESS (individual packets evidenced; chain not composite-run)
implementation_status:    DESIGN_ONLY
runtime_authority_status: NONE
playbook_state:           PLAYBOOK_FORMING

forbidden_actions:
  - Enable Phase 4A cross-family CRR until TPC fire rate confirmed sustained
  - Use LHR as mandatory gate without isolation test
  - Use MSR near-LHR as hard block — not authorized as gate
  - Emit PLAYBOOK_VALID until TM+TPC composite chain run at N >= 50
  - Any weight, role, or gate change based on TPC state

next_allowed_action:
  - TM+TPC composite Nautilus chain run (targeted)
  - LHR SELL×TREND_DOWN isolation (bounded)
  - MSR market-state-controlled overlay test
  - Monitor TPC live fire rate (5+ firings required before Phase 4A design)
```

---

### REG.4.3 VOLATILITY_COMPRESSION_RELEASE (VCR)

```
playbook_id:         VOLATILITY_COMPRESSION_RELEASE
family:              COMPRESSION_BREAKOUT + VOL_BREAKOUT + EXP_CONTINUATION
thesis_statement:    After a sustained period of price compression (narrow range,
                     contracting volatility), energy release produces a directional
                     breakout; this compression-release pattern carries edge when
                     the breakout direction aligns with context and is confirmed
                     by expansion continuation signals.

causal_chain_links:
  1. Compression context       (COMPRESSION zone; narrow ATR; squeeze detected)
  2. Squeeze depth             (range compression duration and depth)
  3. Direction determination   (breakout direction bias from context)
  4. Breakout trigger          (price exits compression range)
  5. Expansion confirmation    (velocity/volume expansion post-break)
  6. No reversal failure-mode  (no immediate snap-back pattern)
  7. Room to target            (expansion target based on compression width)
  8. Stop geometry             (stop inside or at compression boundary)
  9. Outcome attribution

required_links:      [1. compression context, 4. breakout trigger, 7. room]
supporting_links:    [2. squeeze depth, 5. expansion confirm, 8. stop geometry]
failure_links:       [6. snap-back / reversal]
optional_links:      [3. direction bias, 9. attribution]

required_packets:    [ALL PENDING_CERTIFICATION — no packets evidenced]
supporting_packets:  [ALL PENDING_CERTIFICATION]
failure_packets:     [ALL PENDING_CERTIFICATION]

current_accepted_packets:   NONE
current_evidence_summary:
  - range_compression_breakout: DATA_INSUFFICIENT (0 entries); SOURCE_READ_REQUIRED
  - volatility_squeeze_release: DATA_INSUFFICIENT (0 entries); SOURCE_READ_REQUIRED
  - volatility_breakout:        DATA_INSUFFICIENT (0 entries); SOURCE_READ_REQUIRED
  - expansion_continuation:     DATA_INSUFFICIENT (0 entries); SOURCE_READ_REQUIRED
  - micro_range_expansion:      DATA_INSUFFICIENT (0 entries); SOURCE_READ_REQUIRED
  - momentum_breakout_cont_v1:  FROZEN; not available for VCR

missing_links:       All links — no packets evidenced
contradicted_links:  None tested

event_order_contract:
  [NOT_YET_DEFINED — requires source reads and causal chain design first]
  Template stub:
  1. Compression zone detected before trigger
  2. Squeeze depth observable before trigger
  3. Breakout trigger fires (link 4)
  4. Expansion confirm within defined bar window (link 5)
  5. Failure-mode check observable before V1 consumption
  6. Room and stop known before execution
  7. Playbook State emitted
  8. Attribution records all states and outcome

attribution_requirements:
  [NOT_YET_DEFINED — requires packet definitions first]

research_status:          NOT_STARTED (source reads required for all packets)
implementation_status:    DESIGN_ONLY
runtime_authority_status: NONE
playbook_state:           PLAYBOOK_NOT_PRESENT

forbidden_actions:
  - Assign any strategy to VCR roles without source read and standalone cert
  - Emit any Playbook State beyond PLAYBOOK_NOT_PRESENT until minimum 2 links evidenced
  - Any MT5 change based on VCR state

next_allowed_action:
  - Source reads for all 5 VCR candidate strategies
  - Standalone Nautilus certs for range_compression_breakout and volatility_breakout
    (highest-priority: SCOUT and TREND_JUDGE roles for link 1 and link 4)
  - VCR causal chain formalization after first source reads
```

---

## REG.5 Nautilus → MT5 Opportunity Ledger Alignment Plan V1

**Purpose:** Before any Playbook transitions from RESEARCH to RUNTIME_CANDIDATE, Nautilus certifications must demonstrate MT5 observability — the same causal-chain conditions must be capturable inside MT5 before the trade decision, without look-ahead.

**Future ledger record fields required per trigger event:**

```
playbook_id:                which playbook this trigger belongs to
proposed_playbook_state:    state that would be emitted given available packets
completed_links:            [ordered list of links confirmed present]
missing_links:              [ordered list of links not yet confirmed]
contradicted_links:         [links actively contradicted by failure packets]
packet_presence:            {strategy_id: true/false} for each chain packet
packet_direction:           {strategy_id: BUY/SELL/ABSENT}
trigger_timestamp:          ISO8601 — when primary alpha trigger fired
confirm_timestamp:          ISO8601 — when confirmation packet fired (or null)
failure_mode_timestamp:     ISO8601 — when failure-mode packet fired (or null)
room_state:                 ROOM_SUFFICIENT / ROOM_MARGINAL / ROOM_ABSENT
stop_geometry_state:        GEOMETRY_VALID / GEOMETRY_MARGINAL / GEOMETRY_INVALID
pre_decision_available:     bool — were all required links available before V1 decision?
late_evidence:              bool — did any link arrive after trigger_timestamp?
final_decision:             BUY / SELL / WAIT / REJECT (from V1)
outcome:                    WIN / LOSS / OPEN
outcome_r:                  float (R-multiple)
```

**Key alignment question per link:**

| Link | MT5 Observability | Proxy Gap |
|---|---|---|
| Zone / regime context | zone_type from council_environment | Proxy gap: regime_label vs exact zone |
| Range boundary | CouncilGetRecentRangeBounds (M5, 42, 1) | None — SOURCE_FAITHFUL |
| Sweep event | sweep_reversal trigger_present flag | Proxy gap: REV zone gate not ledger-captured |
| Reclaim | bollinger_reclaim / mean_reversion_bounce trigger | Both weak; reclaim timing uncertain |
| MFI direction | mfi_reversal_assist trigger direction | Timing: fires before or after sweep? |
| Room to target | Not yet in opportunity ledger schema | Gap: no room field in current ledger design |
| Stop geometry | core_trade_engine ATR-based SL | SOURCE_FAITHFUL |

**This plan is documentation only. No ledger code change authorized.**

---

## REG.6 Next Test Selection Rules

Phase 3 changes from "full certification of every strategy" to "targeted tests driven by registry gaps." Future Nautilus tests are selected only if:

| Rule | Description |
|---|---|
| R1 — Missing playbook link | Strategy fills a required or supporting link with no current evidence |
| R2 — Bounded hypothesis | A specific testable hypothesis is documented in the Packet Registry |
| R3 — Active contradiction | Test would resolve a contradiction between two evidence sources |
| R4 — Phase readiness | Test affects Phase 4A/4B/4C/5A/6 readiness (e.g., TPC fire rate) |
| R5 — Source fidelity | Strategy has SOURCE_FAITHFUL or PARTIAL_REPLICATION status; sample potential >= 50 trades |

If none of R1–R5 apply: **do not run full certification now.**

**Targeted test status (updated 2026-05-08):**

| Test | Strategy | Rule | Playbook | Status |
|---|---|---|---|---|
| 1. SELL × TREND_DOWN isolation | range_edge_fade | R2 | RBSR | **COMPLETE — FALSIFIED** (N=2 structural absence; BUY×TD secondary RESEARCH_ONLY) |
| 2. LHR SELL × TREND_DOWN isolation | lower_high_rejection_v1 | R2 | TPC | PENDING |
| 3. BDM RANGE_NEUTRAL isolation | breakdown_momentum_v1 | R2 | (conditional) | PENDING |
| 4. Source read | fake_break_reversal | R1 | RBSR | PENDING |
| 5. Source read | mean_reversion_bounce | R1 | RBSR | PENDING |
| 6. Source reads | range_compression_breakout, volatility_squeeze_release, volatility_breakout | R1 | VCR | PENDING |
| 7. MSR market-state-controlled overlay | micro_structure_reentry_v1 | R3 | TPC | PENDING |
| 8. Composite RBSR chain | sweep_reversal + BR + MFI | R1+R3 | RBSR | PENDING |

Tests 2–3 are bounded variants inside existing cert scripts (no new full cert required).  
Tests 4–6 are source reads only (no Nautilus run yet).  
Tests 7–8 require design before execution.

**BUY × TREND_DOWN H2 (range_edge_fade):** Optional, LOW_PRIORITY — do not run unless RBSR architecture explicitly requires it. E[R]=+0.008R is too thin to justify prioritization.

---

### REG.6.1 Governance Correction — Research Discipline Note (2026-05-08)

The REF_SELL_TREND_DOWN_ISOLATION_V1 test was valuable: it falsified a specific inference from Phase 3 and corrected the registry. However, the completed test illustrates a risk in registry-driven research: chaining micro-isolation tests one after another creates an evidence-collection loop without producing architecture progress.

**The next priority is not another micro-test.** The registry now contains 7 certified strategies, 0 accepted packets, and two PLAYBOOK_FORMING playbooks. The correct next step is to consolidate this evidence into an actionable architecture definition — not to continue drilling into isolated subsets.

**Architecture build-out preconditions (what must be defined before "build"):**

1. What does a minimum viable RBSR execution look like in MT5? What packets are actually required vs desired?
2. Can RBSR fire at all with current accepted-packet inventory (0)? Or does it require at least one formally accepted packet before any chain logic can be written?
3. What is the minimum MT5 change required to implement Phase 2 (Opportunity Ledger), and is that the right first implementation step?
4. What does the bounded Opportunity Ledger Codex task look like? Is it ready to draft?

**Authorized next actions from registry evidence (not micro-tests):**
- Consolidate current packet/playbook registry into a Phase 2 implementation brief (Opportunity Ledger design)
- Define the IRREW Phase 4 pre-conditions explicitly: which blockers have cleared, which remain
- Produce a bounded architecture package (not research; not MT5 source change; design documentation only)

**Do not run further micro-isolation tests without explicit operator authorization identifying which R1–R5 rule applies and why it is higher priority than architecture definition.**

---

## REG.7 Phase Implications

| Phase | Status |
|---|---|
| Phase 3 reframed | 17 strategy classifications into Packet Registry; targeted tests only where rules R1–R5 apply |
| Existing 7/17 evidence | Absorbed into registry above |
| Remaining 10 strategies | Source-read + registry-classify first; deep Nautilus only if R1–R5 triggered |
| Phase 4A (cross-family CRR) | BLOCKED — TPC live fire rate unverified |
| Phase 4B (exhaustion veto) | BLOCKED — MFI 0 live entries |
| Phase 4C (quality soft gate) | BLOCKED — Opportunity Ledger not live |
| Phase 5A (bollinger_reclaim SELL gate) | APPLIED; runtime validation pending EA reload |
| Phase 6 (EEWP) | DESIGN_ONLY |
| System status | DEVELOPING |

---

## REG.8 Forbidden Conclusions

This registry does **NOT** authorize:

- MT5 source changes of any kind
- Runtime registry consumption (no EA reads this registry)
- Packet gates (blocking or permitting trades based on packet status)
- Playbook gates (blocking or permitting trades based on playbook state)
- Score creation (playbook_score, completion %, quality_bonus, any numeric)
- council_quality threshold changes
- HIGH_CONVICTION changes
- CRR / DSN gate changes
- Strategy weight changes
- Strategy role changes
- RCEM enforcement changes
- Execution geometry changes
- Strategy injection (adding new strategies to council)
- Strategy deletion or FROZEN status changes (beyond momentum_breakout_cont_v1 already FROZEN)
- Production readiness improvement claim
- Treating RESEARCH_ONLY as ACCEPTED

**No packet is accepted until its acceptance rule is formally met with measured evidence at stated N threshold.**

---

## REG.9 Footer

```
SECTION:                  FULL_STRATEGY_PACKET_AND_PLAYBOOK_REGISTRY_V1
DATE:                     2026-05-08
AUTHORITY:                Advisory Layer — documentation only
STATUS:                   DESIGN_REFERENCE
SOURCE_CHANGED:           NO
RUNTIME_CHANGED:          NO
MT5_AUTHORITY:            NONE
NAUTILUS_AUTHORITY:       NONE

STRATEGIES_REGISTERED:    17 (all active council strategies)
PLAYBOOKS_REGISTERED:     3 (RBSR, TPC, VCR)

PACKET_COUNTS:
  ACCEPTED_PACKETS:       0
  CONFIRM_SPARSE:         1 (trend_pullback_cont_v1)
  RESEARCH_ONLY:          8 (sweep_reversal, bollinger_reclaim, trend_momentum,
                             mfi_reversal_assist, micro_structure_reentry_v1,
                             lower_high_rejection_v1, range_edge_fade,
                             breakdown_momentum_v1 conditional)
  REJECTED_PACKETS:       2 (momentum_breakout_cont_v1 FROZEN; breakdown_momentum_v1 TC)
  PENDING_CERTIFICATION:  6 (mean_reversion_bounce, fake_break_reversal,
                             range_compression_breakout, volatility_squeeze_release,
                             volatility_breakout, expansion_continuation)
  SOURCE_READ_REQUIRED:   7 (same 6 pending + micro_range_expansion)
  DATA_INSUFFICIENT:      7 (same 7 pending/source-read strategies)

PLAYBOOK_STATES:
  RBSR:                   PLAYBOOK_FORMING
  TPC:                    PLAYBOOK_FORMING
  VCR:                    PLAYBOOK_NOT_PRESENT

PHASE_3_REFRAMED:         7/17 certified; remaining 10 = source-read + targeted tests only
NEXT_TARGETED_TESTS:      7 active (test #1 COMPLETE/FALSIFIED 2026-05-08; see REG.6)
REG6_TEST1_STATUS:        COMPLETE — REF SELL×TD FALSIFIED; BUY×TD secondary RESEARCH_ONLY
NEXT_ARCHITECTURE_STEP:   Phase 2 Opportunity Ledger design brief (not more micro-tests)
FORBIDDEN:                All items listed in REG.8
SYSTEM_STATUS:            DEVELOPING
```

---

## BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1

**Section type:** GOVERNANCE RECORD  
**Date:** 2026-05-09  
**Based on:** BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1 (PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP)  
**Authority:** DOCUMENTATION ONLY — No source change. No runtime change. No compile. No reload.  
**See also:** BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1.md (standalone document)

### SGU.1 Audit Verdict Accepted

BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1 returned **PASS_WITH_CAVEATS_NEEDS_SEMANTIC_CLEANUP**. The post-IRREW/PCEA/IFR/FVG_TPB functional audit of `best_strategy_id` confirmed that the core doctrine is substantially upheld. The audit is accepted without modification.

### SGU.2 Accepted Doctrine

```
best_strategy_id   = thesis / attribution identity
V1                 = permission authority
Risk               = protection authority
Execution          = survivability authority
Attribution        = learning authority
```

`best_strategy_id` is selected by highest post-V1 adjusted weight (not `score_final`) during `BuildCouncilAggregateReport`. It is fixed per bar before the permission layer runs. It names the leading alpha signal for attribution, diagnostics, and ledger. It does NOT name the permitted strategy, the executed strategy, or the gate-output strategy. Score fields (`score_final`, `council_quality`, `confidence`) are diagnostic-only post-A2.

### SGU.3 Current Caveat: Cohort Admission Authority Leakage

`RuntimeOperatingCohortAdmissionAllowsExecution` (main_ea.mq5:3018–3047) derives `candidateFamily = LAB_InferFamilyFromStrategyId(best_strategy_id)` and checks it against the operating cohort. This makes `best_strategy_id` **indirectly execution-blocking** when its inferred family is outside `{LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT}`.

**Safety:** SAFE under current conditions — correct behavioral outcome (blocks IFR-led trades since IFR is not in cohort), but through a semantically impure mechanism. FVG_TPB exposed this because IMBALANCE_FILL_REVERSAL is the first admitted strategy whose family is not in cohort.

**Doctrine violation:** `best_strategy_id` should describe thesis identity only. It should not be the source from which execution-admission family is derived.

**Resolution:** Deferred — see SGU.6.

### SGU.4 Immediate Cleanup: LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1 — COMPLETE

| Field | Value |
|---|---|
| Status | COMPLETE — COMPILE_VERIFIED |
| File modified | `level_awareness_brake.mqh` |
| Line added | `if(strategy_id == "fvg_tpb") return "IMBALANCE_FILL_REVERSAL";` |
| Compile | 0 errors, 0 warnings |
| Binary timestamp | 2026-05-09 12:50:10 |
| Functional effect | Diagnostic family trace now correct; cohort/permission/weight unchanged |
| Cohort change | NO — IMBALANCE_FILL_REVERSAL still outside cohort |
| Runtime permission change | NO |

Before this fix: `LAB_InferFamilyFromStrategyId("fvg_tpb")` → `"UNKNOWN"` (registry gap from FVG_TPB implementation package). After: → `"IMBALANCE_FILL_REVERSAL"`. Cohort admission diagnostic now correctly states `"IMBALANCE_FILL_REVERSAL not in cohort"` instead of `"UNKNOWN family not in cohort"`.

### SGU.5 Playbook Runtime Authority Firewall

All playbook shadow fields (`playbook_id`, `playbook_state`, `primary_packet_id`) and all `fvg_/ifr_` attribution fields are **shadow/ledger/attribution only**. They must never feed: gates, cohort admission, weights, `council_quality`, HIGH_CONVICTION, CRR, DSN, risk, execution, stop/target geometry, or order permission.

**Canonical rule:** Playbook State may describe thesis completeness. It must not authorize execution.

`runtime_authority_status = "NONE"` is the universal runtime confirmation that no playbook field drives any decision. Static validation confirmed: zero `fvg_/ifr_` references in `council_aggregator.mqh`, `council_pre_ai_filter.mqh`, `council_ai_governor.mqh`, `core_trade_engine.mqh`, or the BUY/SELL execution path. Firewall intact as of 2026-05-09.

### SGU.6 Deferred Semantic Cleanup Roadmap

| ID | Name | Status |
|---|---|---|
| A | EXECUTION_ADMISSION_IDENTITY_DECOUPLING_V1 | DEFERRED — decouple cohort admission from `best_strategy_id`; introduce `execution_admission_family` from aggregate direction |
| B | PRIMARY_THESIS_STRATEGY_ID_RENAME_DESIGN_V1 | DEFERRED — rename to `primary_thesis_strategy_id`; 23+ consumer occurrences; coordinated multi-file task at Phase 6 milestone |
| C | PRIMARY_THESIS_SELECTION_CONTRACT_V1 | DEFERRED — filter thesis selection to `trigger_present=true`, `decision∈{BUY,SELL}`, `eligibility≠BLOCKED/OBSERVE_ONLY`, `postV1Weight>0` |

None of A/B/C are authorized for implementation. Each requires separate operator authorization and a bounded design + Codex task.

### SGU.7 New Strategy Identity Registry Rule

No new strategy is structurally integrated unless: (1) strategy_id registered, (2) strategy_family registered, (3) `LAB_InferFamilyFromStrategyId` entry added at implementation time, (4) packet role documented, (5) playbook relationship documented or marked NONE, (6) `runtime_authority_status = NONE` unless separately authorized, (7) V1C/ledger attribution fields classified, (8) cohort status explicit (ADMITTED/NOT_ADMITTED/CONDITIONAL/FORBIDDEN), (9) rollback behavior documented.

Purpose: Prevent future `fvg_tpb`-style family opacity in family inference layer.

### SGU.8 Explicit Non-Authorizations

This governance update does NOT authorize: runtime playbook authority, cohort promotion, IMBALANCE_FILL_REVERSAL admission, score authority, gate change (CRR/DSN/HIGH_CONVICTION/DOMINANT_SIDE), weight change, council_quality change, V1 posture change, P4 change (4A/4B/4C), Level Brake change, risk change, execution geometry change, strategy injection, or production readiness claim.

### SGU.9 Phase and Production Impact

- Reload: ALLOWED WITH CAVEATS — unchanged from audit verdict. No blocker found.
- System status: DEVELOPING — unchanged.
- Production readiness: unchanged — IRREW Phase 3 certifications not complete; Phase 4 not live.
- FVG_TPB runtime validation: PENDING EA reload (operator action required).

### SGU.10 Footer

```
SECTION_ID:               BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1
DATE:                     2026-05-09
STANDALONE_DOCUMENT:      BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1.md
PIML_BACKUP:              PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_20260509_131007
SOURCE_CHANGED:           NO
RUNTIME_JSON_CHANGED:     NO
COMPILE_RUN:              NO
MT5_RELOAD:               NO
LAB_FIX_STATUS:           COMPLETE (LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1)
SYSTEM_STATUS:            DEVELOPING
PRODUCTION_READY:         NOT CLAIMED
```
```

---

## §29. DEVELOPMENT_COMPLETE_DECLARATION_V1 (2026-05-09)

- **DEVELOPMENT_COMPLETE_BUILD_DELIVERED (2026-05-09):** All 12 DEV-C criteria confirmed met. Final governed archive created. Development complete phase formally closed.
- **Binary:** `main_ea.ex5` timestamp 2026-05-09 12:50:10; 0 errors / 0 warnings (compile_lab_infer_family_registry_fvg_tpb_fix_v1_20260509_124554.log)
- **Archive:** `D:\MT5_Project_Backups\FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_20260509_215951.zip` (9.87 MB, 1,134 entries — 462 Experts/AI + 672 Files/AI)
- **Handover:** `DEVELOPMENT_COMPLETE_HANDOVER_PACKAGE_V1.md`
- **Declaration:** `DEVELOPMENT_COMPLETE_DECLARATION_V1.md`
- **System status after declaration:** DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
- **Production ready:** FALSE — 57-item PAC required; 13 runtime debts open
- **V1 Constructive Eligibility A1:** CONFIRMED ACTIVE — `EnableV1ConstructivePolicyEligibility=true` in current source (correction to prior RUNTIME_PENDING note at §27 line 237)
- **No-Score A2:** CONFIRMED — `pre_ai_score_gates_demoted=true` in council_pre_ai_filter.mqh L157
- **No-Score Hard-Lock:** CONFIRMED — `return false` at council_mode_runtime.mqh L195–199
- **Stage D Governor:** CONFIRMED — categorical observer only; advisory flags; no pass/fail authority
- **Authority Stack:** CONFIRMED — P4+V1 live; DQ force-diagnostic (authority_stack_pilot.mqh L273)
- **EQ-DIAG fields:** sl_vs_m5_atr_ratio + level_context_at_entry present in performance_journal.mqh TRADE records; stop_anchor_state never implemented (removed from criteria)
- **breakdown_momentum_v1 Nautilus:** NOT CERTIFIED — Phase 3 pending; reclassified from SOURCE_READ_REQUIRED to PENDING_LAB_WORK
- **Compile warning status:** 0 warnings in latest binary (int-to-string warnings resolved by compile_warning94_cleanup_20260503_010513.log)
- **Runtime debt ledger:** 13 items open (see DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1.md §8)
- **Critical next action:** XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1

```
SECTION_ID:               DEVELOPMENT_COMPLETE_DECLARATION_V1
DATE:                     2026-05-09
BINARY_TIMESTAMP:         2026-05-09 12:50:10
ARCHIVE_PATH:             D:\MT5_Project_Backups\FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_20260509_215951.zip
ARCHIVE_SIZE:             9.87 MB (10,352,799 bytes)
ARCHIVE_ENTRIES:          1,134 (462 Experts/AI + 672 Files/AI)
COMPILE_STATUS:           0 errors / 0 warnings
WARNING_WAIVER:           NOT REQUIRED
DEV_C_CRITERIA_MET:       12/12
SYSTEM_STATUS:            DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
PRODUCTION_READY:         FALSE
RUNTIME_DEBTS:            13 OPEN
PAC_STATUS:               NOT_STARTED (57 items)
SOURCE_CHANGED:           NO
COMPILE_RUN:              NO
MT5_RELOAD:               NO
```

---

## §30. ENGINEERING_ACTIVATION_REVIEW_FOR_V1_IRREW_PCEA_V1 (2026-05-09)

- **Review type:** Architecture-to-implementation activation review under Engineering Completion Mode
- **Management directive:** Controlled Activation accepted; Controlled Inaction not accepted
- **Full report:** `ENGINEERING_ACTIVATION_REVIEW_FOR_V1_IRREW_PCEA_V1.md`

**New finding — Risk State Policy Engine enforcement confirmed:**
Previously listed as "consumption in live path unclear." Source read at `main_ea.mq5:L2720-2727` confirmed: `gRiskPolicy.block_new_trades → ev.risk_policy_guard_active → OperatingEnvelopeSetBlock → return`. Risk State Policy Engine is LIVE and ENFORCING in the live trade decision path. This strengthens the dev-complete assessment.

**Component activation summary:**
- ALREADY_ACTIVE (10): V1 Auth Stack (P4+V1), A1 flag=true, A2 score gate demotion, No-Score Hard-Lock (6 surfaces), Risk State Policy Engine enforcement, Failure Detector (advisory via governor), PCEA OL_V1C_PLAYBOOK_SHADOW, FVG_TPB source (compile-clean), IFR exclusion + LAB_InferFamily fix, EQ-DIAG TRADE fields
- RUNTIME_DEBT (4): Phase 4A (TPC 0 triggers), Phase 4B (MFI 2 entries), Phase 4C (38 OL records), FVG_TPB first XAUUSD trigger / mae-mfe real values
- PERMANENTLY_EXCLUDED/DEACTIVATED (3): DQ (A3-Revised), IFR operating cohort, stop_anchor_state (never implemented — removed from criteria)
- REJECTED_UNTIL_EVIDENCE: EEWP (design-only), SPC-001 to SPC-010 (all BLOCKED/EARLY_RESEARCH)
- DEVELOPMENT_FLAGGED: RCEM (zone_type routing only in source — no regime_label matrix; documentation reconciliation needed in PIML/PAC)

**Phase 4A/4B/4C engineering assessment (confirmed not over-deferral):**
- Phase 4A (cross-family CRR): TC execution collapse risk is genuine if TPC fire rate is low. Unblock: TPC ≥5 triggers + ≥20% eligible-bar rate confirmed.
- Phase 4B (exhaustion veto): Threshold calibration requires observed mfi_reversal_assist signal distribution. Unblock: ≥5 MFI signal readings in OL.
- Phase 4C (quality soft gate): Re-activating before OL has 200+ records creates unauditable suppression. Sequencing: Phase 2 (OL live — DONE) → 200+ records → Phase 4C.

**RCEM clarification:** "RCEM V1" in prior PIML entries = zone_type routing in `council_strategies.mqh`. No regime_label matrix exists in source. The per-strategy gate pattern (Phase 5A bollinger_reclaim, future Phase 5B breakdown_momentum_v1) IS the correct incremental RCEM implementation — one gate per strategy per Nautilus evidence.

**Playbook consumption:** Firewall confirmed. Playbook shadow is attribution-only. Promotion to categorical V1 input requires: 200+ OL records with playbook context → correlation analysis → operator authorization.

**Failure Detector mode:** Advisory-only via governor is correct. Promotion to direct enforcement requires: 200+ OL records showing pressure_level=HIGH/CRITICAL sessions correlate with losing runs not caught by risk state engine → operator authorization → bounded Codex task.

**Next Codex priorities (ordered):**
1. Phase 4C (quality soft gate) — blocked: OL ≥200 records
2. Phase 4A (cross-family CRR) — blocked: TPC ≥5 triggers + ≥20% rate
3. Phase 4B (exhaustion veto) — blocked: MFI ≥5 OL entries
4. Phase 5B (breakdown_momentum_v1 TREND_DOWN gate) — blocked: Nautilus cert
5. RCEM PIML documentation reconciliation — no source change; operator action

**Immediate operator action:** Attach EA to XAUUSD chart → XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1 → resolves RDL-001 through RDL-013.

```
SECTION_ID:               ENGINEERING_ACTIVATION_REVIEW_V1_IRREW_PCEA_V1
DATE:                     2026-05-09
REVIEW_TYPE:              Architecture-to-implementation activation review
SYSTEM_STATUS:            DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
SOURCE_CHANGED:           NO
COMPILE_RUN:              NO
MT5_RELOAD:               NO
PRODUCTION_READY:         FALSE
DEV_COMPLETE_VALIDATED:   YES — all 12 DEV-C criteria confirmed
NEW_FINDING:              Risk State Policy Engine LIVE enforcement confirmed (main_ea.mq5:L2720-2727)
NEXT_CODEX_TASK:          Phase 4C quality soft gate (blocked: OL ≥200 records)
NEXT_OPERATOR_ACTION:     Attach EA to XAUUSD chart
```

---

## §31. FORCED_ENGINEERING_ACTIVATION_FULL_FORENSIC_ADVERSARIAL_REVIEW_V1 (2026-05-10)

- **Review type:** Maximum-depth adversarial forensic review — post-Codex Packages A through D
- **Verdict:** **PASS_RELOAD_ALLOWED_WITH_CAVEATS**
- **Full report:** `FORCED_ENGINEERING_ACTIVATION_FULL_FORENSIC_ADVERSARIAL_REVIEW_V1.md`

**Build changes (Codex Packages A–D):**
- 5 files modified: council_mode_types.mqh, council_aggregator.mqh, council_mode_runtime.mqh, main_ea.mq5, PROJECT_INTELLIGENCE_MEMORY_LAYER.md
- 5 backups created (all .bak_20260510_*)
- Binary timestamp: 2026-05-10 00:39:43
- Compile: 0 errors / 0 warnings (all 4 packages, staged)
- 8 files correctly NOT touched (council_pre_ai_filter, authority_stack_pilot, core_trade_engine, council_strategies, level_awareness_brake, council_ai_governor, council_environment, council_failure_detector)

**What was implemented (all default-off):**
- 7 IRREW development input flags (all default=false): EnableIRREWDevelopmentConsumption (master), Phase4ADev, Phase4BDev, Phase4CDev, RCEMDev, ExecutionGeometryDev, PlaybookAdvisoryDev
- 6 new enums in council_mode_types.mqh: CouncilThesisQualityState, CouncilPacketClass, CouncilPacketStatus, CouncilPlaybookState, CouncilIRREWDevAction, CouncilRCEMEligibility
- 4 new structs in council_mode_types.mqh: CouncilExecutionAdmissionIdentity, CouncilPacketRegistryConsumptionReport, CouncilPlaybookConsumptionReport, CouncilIRREWDevelopmentActionReport
- IRREW_ResolveAdmissionIdentity() in council_aggregator.mqh (two-tier: eligible contributor → fallback LAB_Infer)
- Phase 4A/4B/4C/RCEM evaluators in council_mode_runtime.mqh (all role-based; all gated by IRREW_SubFlagActive)
- Execution geometry WAIT gate in main_ea.mq5 (L3047-3111; separate from DQ hard-lock path)
- 34 new IRREW fields in OL write section (L1742-1775); OL schema → OL_V1C_IRREW_DEV_V1
- execution_admission_family field consumed by cohort admission (RuntimeInferDecisionCandidateFromRouted L3016)

**Authority leakage: NONE FOUND.** No IRREW path can promote REJECT→BUY/SELL. No score authority restored. No playbook runtime authority added. IFR exclusion preserved.

**No-score hard-lock: FULLY PRESERVED.** All 9 DQ score gates confirmed commented at main_ea.mq5:L10903-10976. DQ execution geometry path is hard-locked separately from the new IRREW geometry path.

**Structural deviations from spec (none reload-blocking):**
1. No unified ApplyIRREWDevelopmentActions wrapper function (inline sequence at L2217-2229 instead)
2. Phase 4C CONTRADICTED condition uses exhaustion_warning instead of playbook_state/failDet pressure — **must correct before Phase 4C enabled**
3. Double resolution of admission identity (aggregator + pipeline — redundant, not breaking)
4. gIRREWDevReport / gAdmissionIdentity globals deferred (not in main_ea.mq5)
5. Process gate bypass (Codex ran A–D continuously; this forensic review serves as post-hoc gate)

**OL schema migration:** All new OL records post-reload use OL_V1C_IRREW_DEV_V1 schema with 34 new IRREW fields. Pre-reload records retain OL_V1C_PLAYBOOK_SHADOW. Mixed-schema JSONL is expected (append-only design).

**Behavioral delta on reload:** ZERO for trade execution — all IRREW paths gated by flags=false. Only observable change: richer OL record schema.

**Mandatory correction before Phase 4C enable:**
Phase 4C CONTRADICTED derivation must be corrected: `exhaustion_warning || exhaustion_risk_detected` → `playbookReport.playbook_state == PLAYBOOK_STATE_CONTRADICTED || (failDet.valid && failDet.exhaustion_risk_detected && high_pressure_condition)`.

**Reload authorization:** YES. Reload may proceed. Attach EA to BTCUSD and XAUUSD charts.

```
SECTION_ID:               FORENSIC_REVIEW_V1_IRREW_PCEA_PACKAGES_A_D
DATE:                     2026-05-10
REVIEW_VERDICT:           PASS_RELOAD_ALLOWED_WITH_CAVEATS
BINARY_TIMESTAMP:         2026-05-10 00:39:43
COMPILE_STATUS:           0 errors / 0 warnings (all 4 packages)
AUTHORITY_LEAKAGE:        NONE
NO_SCORE_HARD_LOCK:       PRESERVED
V1_PERMISSION_AUTHORITY:  PRESERVED
ALL_IRREW_FLAGS:          DEFAULT=FALSE (no live IRREW behavior on reload)
BEHAVIORAL_DELTA:         ZERO (flags disabled; only OL schema enrichment)
ROLLBACK_REQUIRED:        NO
RELOAD_AUTHORIZED:        YES
STRUCTURAL_DEVIATIONS:    5 (none reload-blocking)
PRE_PHASE4C_CORRECTION:   REQUIRED (CONTRADICTED condition fix)
PROCESS_VIOLATION:        Codex bypassed B→C and C→D adversarial gates — forensic review substitutes
SYSTEM_STATUS:            DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
SOURCE_CHANGED:           NO (forensic review only)
COMPILE_RUN:              NO
MT5_RELOAD:               AUTHORIZED (pending operator action)
PRODUCTION_READY:         FALSE
NEXT_OPERATOR_ACTION:     Reload EA → attach to XAUUSD chart → XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1
```

---

## §32. POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1 (2026-05-10)

- **Mission type:** Bounded correction + schema reconciliation + documentation network consolidation + XAUUSD validation preparation
- **Context:** Post-BTCUSD-session corrections following Packages A–D reload (§31) and BTCUSD sanity review
- **Full report:** `DOCS_SYSTEM/02_IMPLEMENTATION_REPORTS/POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1_REPORT.md`
- **Compile:** 0 errors / 0 warnings — `compile_correction_20260510_052916.log`

### BTCUSD Sanity Review (pre-correction finding)

- **Review:** BTCUSD_POST_RELOAD_FORCED_ACTIVATION_RUNTIME_SANITY_REVIEW_V1
- **Verdict:** PASS_BTCUSD_POST_RELOAD_SANITY_WITH_CAVEATS
- **Session:** 2026-05-10 03:02–04:40 (EA removed, not crashed — REASON_REMOVE)
- **Trades:** 2 (1 SELL → SL hit loss; 1 BUY → SL hit loss)
- **OL records:** 45 total (40 pre-reload XAUUSD + 5 BTCUSD post-reload)
- **Routing:** All 6 decisions Mode=COUNCIL — zero legacy path activity
- **IRREW flags:** All 7 confirmed false in OL records; zero behavioral delta
- **OL schema observation:** `record_version="OL_V1C_PLAYBOOK_SHADOW"` in BTCUSD records while `irrew_schema_version="OL_V1C_IRREW_DEV_V1"` — dual-field ambiguity → corrected in Phase 1
- **U-02 (pre-known):** CONTRADICTED condition used exhaustion signals — non-blocking, corrected in Phase 2
- **Caveat-I (U-02):** Resolved by this package

### Phase 1 — OL Schema Contract Reconciliation

**File:** `council_mode_runtime.mqh`
**Changes (3 string literals):**

| Location | Old Value | New Value |
|---|---|---|
| L1655 — `record_version` | `"OL_V1C_PLAYBOOK_SHADOW"` | `"OL_V1C_IRREW_DEV_V1"` |
| L1853 — summary `schema_version` | `"OL_SUMMARY_V1C_PLAYBOOK_SHADOW"` | `"OL_SUMMARY_V1C_IRREW_DEV_V1"` |
| L1858 — summary `playbook_architecture_schema` | `"OL_V1C_PLAYBOOK_SHADOW"` | `"OL_V1C_IRREW_DEV_V1"` |

Note: `irrew_schema_version` in struct init (`council_mode_types.mqh`) was already `"OL_V1C_IRREW_DEV_V1"` — no change needed. Historical BTCUSD records (5 lines, `record_version="OL_V1C_PLAYBOOK_SHADOW"`) are preserved as-is (no modification to runtime JSON).

### Phase 2 — PHASE4C_THESIS_QUALITY_CONTRADICTION_FIX_V1 (U-02)

**File:** `council_mode_runtime.mqh:L1169–1170`
**Function:** `IRREW_DeriveThesisQualityState()`

```mql5
// Before (wrong — used exhaustion signals):
if(agg.exhaustion_warning || (failDet.valid && failDet.exhaustion_risk_detected))
   return "THESIS_QUALITY_CONTRADICTED";

// After (correct — uses categorical failure pressure level):
if(failDet.valid && (failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_HIGH ||
                     failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_CRITICAL))
   return "THESIS_QUALITY_CONTRADICTED";
```

Rationale: Exhaustion signals are analog/continuous signals already used downstream. `pressure_level` (CouncilFailurePressureLevel enum: NONE/LOW/MEDIUM/HIGH/CRITICAL) is categorical, orthogonal to exhaustion, and is the correct proxy for thesis contradiction pressure. This fix is gated by `EnableIRREWPhase4CDev=false` — behavioral impact only when Phase 4C is explicitly enabled.

### Phase 3 — Compile Verification

- **Compile log:** `compile_correction_20260510_052916.log`
- **Result:** 0 errors, 0 warnings, 312580 ms elapsed, cpu='X64 Regular'
- **Static safety checklist (12 items):** All PASS
  - IRREW flags all false (main_ea.mq5:L107–113) ✓
  - No playbook_score added ✓
  - No council_quality bonus from Phase4C ✓
  - U-02 CONTRADICTED uses pressure_level (not exhaustion) ✓
  - OL schema ambiguity resolved (3 strings) ✓
  - DQ No-Score Hard-Lock intact (9+ gates confirmed) ✓
  - IMBALANCE_FILL_REVERSAL outside operating cohort ✓
  - PLAYBOOK_VALID not used as trade permission gate ✓
  - No EEWP or automatic weight changes ✓
  - Runtime JSON not modified ✓
  - Stop/target/lot geometry untouched ✓
  - Compile clean ✓

### Phase 4 — XAUUSD Attach Instructions

- **Status:** XAUUSD_ATTACH_REQUIRED_AFTER_OPERATOR_RELOAD
- **Document:** `DOCS_SYSTEM/03_RUNTIME_VALIDATION/XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1.md`
- **Key checks:** 10 startup markers (D-1 to D-10), fvg_tpb evaluation checks (E-1 to E-6), OL schema checks (F-1 to F-10), summary checks (G-1 to G-5), boundary checks (H-1 to H-7)
- **Expected result:** XAUUSD_VALIDATION_PASS after 20+ bars

### Phase 5 — DOCS_SYSTEM Documentation Network

- **Root:** `MQL5/Experts/AI/DOCS_SYSTEM/`
- **Subfolders (8):** 00_INDEX_AND_GOVERNANCE, 01_ARCHITECTURE, 02_IMPLEMENTATION_REPORTS, 03_RUNTIME_VALIDATION, 04_NAUTILUS_INEC, 05_HANDOVER_AND_ACCEPTANCE, 06_AUDITS_AND_REVIEWS (reserved), 99_LEGACY_OR_SUPERSEDED (reserved)
- **Files moved:** 31 cumulative root .md files → DOCS_SYSTEM subfolders (30 during POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1; 1 relocation during DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1)
- **Root exceptions kept:** AGENTS.md, OPERATION_GUARDRAILS.md, PROJECT_INTELLIGENCE_MEMORY_LAYER.md
- **Index:** `DOCS_SYSTEM/DOCS_SYSTEM_INDEX.md`
- **Manifest:** `DOCS_SYSTEM/DOCS_MOVE_MANIFEST_V1.md` (full old→new path table)

### Open Items After This Package

| Item | Status | Next Action |
|---|---|---|
| XAUUSD attachment | REQUIRED | Operator: attach EA to XAUUSD M5 chart, run validation checklist |
| Phase 4C enable | BLOCKED | Requires OL ≥ 200 records (Phase 4C) after reload |
| Phase 4A enable | BLOCKED | Requires TPC min 5 distinct live firings |
| Phase 4B enable | BLOCKED | Requires MFI ≥ 5 signal entries |
| Opportunity Ledger Phase 2 | NOT_STARTED | Design OpportunityRecord struct |
| Nautilus Phase 3 certifications | NOT_STARTED | Export XAUUSD M1/M5 OHLCV |

```
SECTION_ID:                   POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1
DATE:                         2026-05-10
MISSION_TYPE:                 Bounded correction + schema reconciliation + doc network + XAUUSD prep
FILES_CHANGED:                council_mode_runtime.mqh (4 edits: Phase 1 ×3, Phase 2 ×1)
FILES_CREATED:                XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1.md, DOCS_SYSTEM/ (32 files)
COMPILE_LOG:                  compile_correction_20260510_052916.log
COMPILE_RESULT:               0 errors / 0 warnings
STATIC_SAFETY_CHECKLIST:      12/12 PASS
IRREW_FLAGS:                  ALL FALSE — not changed
BEHAVIORAL_DELTA:             ZERO (flags off; schema labels corrected for future records only)
HISTORICAL_RECORDS_MODIFIED:  NO
STOP_GEOMETRY_CHANGED:        NO
PRODUCTION_READY_CLAIMED:     NO
SYSTEM_STATUS:                DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
NEXT_OPERATOR_ACTION:         Attach EA to XAUUSD chart → run XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1
U02_STATUS:                   RESOLVED (CONTRADICTED condition uses pressure_level HIGH/CRITICAL)
OL_SCHEMA_STATUS:             RECONCILED (record_version and summary schemas unified to OL_V1C_IRREW_DEV_V1)
DOCS_SYSTEM_STATUS:           CREATED (31 files organized, 3 root exceptions preserved)
```

## §33. DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1 (2026-05-10)

- **Mission type:** Forensic dataflow audit + bounded log correction + documentation relocation + strategy gap research
- **Full report:** `DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1_REPORT.md`
- **Governed backup:** `D:\MT5_Project_Backups\system_backup_DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1_PREPATCH_20260510_061316.zip`
- **Compile:** 0 errors / 0 warnings — `compile_dataflow_experts_docs_strategy_gap_v1_20260510_061821.log`

### Findings

- **Dataflow:** No verified producer-consumer defect requiring a decision-path source fix. IRREW master/sub-flag gating remains source-backed, `execution_admission_family` remains authority-facing cohort identity, `runtime_authority_status` remains `NONE`, and `IMBALANCE_FILL_REVERSAL` remains outside the active operating cohort.
- **Experts logs:** Verified misleading startup labels corrected in `main_ea.mq5` only. Legacy compiled-plan library counts, main trigger, and score thresholds now identify themselves as diagnostics under COUNCIL routing.
- **Docs network:** Root `.md` inventory restored to the three exceptions only: `AGENTS.md`, `OPERATION_GUARDRAILS.md`, `PROJECT_INTELLIGENCE_MEMORY_LAYER.md`. `POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1_REPORT.md` moved into `DOCS_SYSTEM/02_IMPLEMENTATION_REPORTS/`.
- **Strategy gap:** Largest gap is VCR / volatility-compression-release and breakout/expansion coverage. Candidate INEC certification priorities: session opening-range/range-release breakout, NR4/NR7 or ATR compression-release, and Donchian/ATR channel breakout with retest/failed-breakout diagnostics.

```
SECTION_ID:                   DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1
DATE:                         2026-05-10
MISSION_TYPE:                 Forensic dataflow + Experts logs + docs network + strategy gap audit
FILES_CHANGED:                main_ea.mq5, DOCS_SYSTEM/DOCS_SYSTEM_INDEX.md, DOCS_SYSTEM/DOCS_MOVE_MANIFEST_V1.md, PROJECT_INTELLIGENCE_MEMORY_LAYER.md
FILES_MOVED:                  POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1_REPORT.md -> DOCS_SYSTEM/02_IMPLEMENTATION_REPORTS/
FILES_CREATED:                DOCS_SYSTEM/06_AUDITS_AND_REVIEWS/DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1_REPORT.md
COMPILE_LOG:                  compile_dataflow_experts_docs_strategy_gap_v1_20260510_061821.log
COMPILE_RESULT:               0 errors / 0 warnings
IRREW_FLAGS:                  ALL FALSE — not changed
SOURCE_FIX_SCOPE:             Experts startup log label clarification only
RUNTIME_JSON_MODIFIED:        NO
PRODUCTION_READY_CLAIMED:     NO
SYSTEM_STATUS:                DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
NEXT_OPERATOR_ACTION:         Attach EA to XAUUSD M5 chart and run DOCS_SYSTEM/03_RUNTIME_VALIDATION/XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1.md
```

## §34. MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1 (2026-05-10)

- **Mission type:** Read-only MT5 Strategy Tester validation + static IRREW architecture analysis
- **Full report:** `DOCS_SYSTEM/03_RUNTIME_VALIDATION/MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1.md`
- **Final verdict:** `TESTER_PARTIAL_EVIDENCE_REQUIRES_LIVE_XAUUSD`

### Findings

- **Tester environment:** `TESTER_ENV_READY_WITH_CAVEATS` — terminal running at PID 7112 during open market hours; second-instance launch on same profile directory blocked (lock conflict risk). Tester must be UI-initiated by operator (View → Strategy Tester).
- **Binary:** `main_ea.ex5` 2026-05-10 06:22:51 confirmed present; no compile required; no mismatch.
- **File isolation:** Confirmed — EA uses no `FILE_COMMON` flag in any `FileOpen()` call. Tester writes to agent-isolated directory only; live `MQL5/Files/AI/` runtime files are safe during tester runs.
- **Static validation:** 16 of 17 validation targets confirmed via source-verified IRREW architecture analysis combined with prior live session evidence.
- **IRREW master/sub-flag contract:** `IRREW_SubFlagActive(master, sub)` = pure AND gate (`council_mode_runtime.mqh:L839–841`). All 6 dev evaluators early-return when sub-flag is false. Behavioral delta = zero in default build (all flags false, L107–113 `main_ea.mq5`).
- **IRREW_ApplyDevelopmentWaitProtocol authority boundary:** Converts directional (BUY/SELL) → WAIT only when `development_wait_requested=true` (L1280). Cannot promote REJECT → execution. Preserves `baseline_decision_before_irrew_dev` and `final_decision_after_irrew_dev`.
- **Phase4C detail:** THIN and UNCERTAIN states → `advisory_wait=true` + `v1_caution` only; `development_wait_requested` NOT set. CONTRADICTED and INCOMPLETE → WAIT via `IRREW_AddDevelopmentWaitReason` (L1186–1220).
- **RCEM REDUCED detail:** Advisory only — no WAIT. OBSERVE_ONLY/BLOCKED → WAIT `IRREW_RCEM_DEV_WAIT_CATEGORICAL_ELIGIBILITY`. Default state = `ALLOWED_BY_NO_CERTIFIED_RESTRICTION` for unknown families (L1240).
- **Playbook Advisory dev:** No `IRREW_EvaluatePlaybookAdvisoryDev()` function in current source. `EnableIRREWPlaybookAdvisoryDev` used only at `council_mode_runtime.mqh:L1767` (OL serialization). No WAIT path. Advisory/OL-only in this build.
- **fvg_tpb RCEM:** Always `OBSERVE_ONLY` for `IMBALANCE_FILL_REVERSAL` family (source L1225–1227). Cannot serve as cross-family confirmer (OBSERVE_ONLY skip in `IRREW_HasCrossFamilyRoleConfirmation`).
- **DQ no-score hard-lock:** 9+ commented `// return false; // [NO-SCORE HARD-LOCKED]` gates at `main_ea.mq5:L10903–10976` — untouched and separate from the Execution Geometry pre-order WAIT path at L3047–3111.
- **TESTER_REQUIRED item:** XAUUSD M5 OL records with `fvg_tpb` `evaluations_seen > 0`. Requires operator-initiated tester run on XAUUSD M5. XAUUSD M5 tester cache confirmed available: `main_ea.XAUUSD.M5.20040611.20260423.41.*`.

### Artifacts Created

- 9 `.set` files in `MQL5/Profiles/Tester/`: `phase0_baseline`, `phase2_master_true`, `phase3a` through `phase3f`, `phase4_combined`
- 9 INI configs in `MQL5/Experts/AI/TESTER_CONFIGS/`: matching profile for each `.set` file
- Report: `DOCS_SYSTEM/03_RUNTIME_VALIDATION/MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1.md`

```
SECTION_ID:                   MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1
DATE:                         2026-05-10
MISSION_TYPE:                 MT5 Strategy Tester validation + static IRREW architecture analysis
FINAL_VERDICT:                TESTER_PARTIAL_EVIDENCE_REQUIRES_LIVE_XAUUSD
TESTER_ENV:                   TESTER_ENV_READY_WITH_CAVEATS
BINARY_CONFIRMED:             main_ea.ex5 2026-05-10 06:22:51
FILE_ISOLATION:               CONFIRMED — no FILE_COMMON; tester writes to agent-isolated directory
TARGETS_CONFIRMED_STATIC:     16 of 17
TESTER_REQUIRED:              1 (fvg_tpb evaluations_seen > 0 in XAUUSD M5 tester run)
FILES_CREATED:                DOCS_SYSTEM/03_RUNTIME_VALIDATION/MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1.md, 9 .set files (MQL5/Profiles/Tester/), 9 INI configs (MQL5/Experts/AI/TESTER_CONFIGS/)
SOURCE_CHANGED:               NO
COMPILE_RUN:                  NO
IRREW_FLAGS_STATUS:           ALL DEFAULT FALSE — unchanged
RUNTIME_JSON_MODIFIED:        NO
PRODUCTION_READY_CLAIMED:     NO
SYSTEM_STATUS:                DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
NEXT_OPERATOR_ACTION:         Run tester from terminal UI using .set files in MQL5/Profiles/Tester/; then attach EA to XAUUSD M5 per XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1.md
```
