# DOCS_SYSTEM_INDEX

**Root:** `MQL5/Experts/AI/DOCS_SYSTEM/`
**Created:** 2026-05-10
**Context:** POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1
**Total documents:** 54 (+ 2 index files in this folder)

---

## Root Exceptions (Remain at EA Root)

These 3 files stay at `MQL5/Experts/AI/` permanently — they are active governance documents requiring direct access:

| File | Purpose |
|---|---|
| `AGENTS.md` | Operator protocol, backup requirements, surgery discipline |
| `OPERATION_GUARDRAILS.md` | MT5 authority, phase ledger, production guardrails |
| `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | Sole authoritative project phase/status memory (PIML) |

---

## 00_INDEX_AND_GOVERNANCE/ — 4 files

Registry, manifest, and backlog documents governing system state.

| File | Description |
|---|---|
| `FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_MANIFEST.md` | Final archive manifest for governed system V1 |
| `PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md` | Strategy packet registry for playbook architecture |
| `MASTER_DEVELOPMENT_CLOSURE_BACKLOG_V1.md` | Development closure backlog tracker |
| `SOURCE_READ_REQUIRED_RESOLUTION_V1.md` | Source-read requirement resolution log |

---

## 01_ARCHITECTURE/ — 12 files + 1 AI-root architecture doc

Design packages, architecture specs, and implementation blueprints.

| File | Description |
|---|---|
| `ARCHITECTURE_BUILD_PACKAGE_V1.md` | Full architecture build package V1 |
| `IMPLEMENTATION_SPEC_PACKAGE_V1.md` | Implementation specification package V1 |
| `PLAN6_STAGE0_BASELINE.md` | Plan 6 Stage 0 baseline snapshot |
| `SHADOW_POLICY_CANDIDATE_DESIGN_PACKAGE_V1.md` | Shadow replay policy candidate design |
| `FVG_TPB_MT5_ADMISSION_DESIGN_PACKAGE_V1.md` | FVG-TPB MT5 admission design package |
| `IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1.md` | IFR playbook architecture design package |
| `MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1.md` | EXE/RAM sidecar Package 1 spec — 15 questions answered + Codex Package 2 brief (SECONDARY) |
| `GEMINI_DELEGATED_EXTERNAL_XAUUSD_STRATEGY_DISCOVERY_AND_INEC_PIPELINE_V1.md` | Four-gate pipeline spec for external XAUUSD strategy discovery → INEC certification; authority model, gap analysis, candidate requirements, INEC framework (Gate 0 authorized; Gate 1 pending) |
| `NR7_VCR_GATE2_DESIGN_AND_EXECUTION_FEASIBILITY_REVIEW_V1.md` | NR7 Gate 2 architecture review — Verdict: NR7_GATE2_DESIGN_READY_FOR_GATE3_PACKET_ONLY; OCO blocked (market-order-only trade engine); STOP_GEOMETRY + LOCATION packets ready; ALPHA_TRIGGER deferred; 4 required matrices |
| `NR7_SHADOW_ATTRIBUTION_AND_EDGE_QUALITY_INTEGRATION_DESIGN_V1.md` | NR7 Gate 3 shadow-attribution design — Verdict: NR7_SHADOW_ATTRIBUTION_OFFLINE_FIRST_RECOMMENDED; zero new runtime fields; Gate 3A0 + 3B (offline Python) authorized immediately; Gate 3A1/3C/3D/3E deferred; 4 required matrices |
| `NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_SPEC_V1.md` | NR7 unified shadow runtime integration spec — Verdict: NR7_SHADOW_RUNTIME_SPEC_READY_FOR_CODEX; one `nr7_shadow_state` string field in CouncilEnvironmentReport; computed in BuildCouncilEnvironmentReport; OL JSONL field; zero live influence; Codex implementation pending operator confirmation |
| `ACTIVE_OPERATIONAL_ROADMAP_V1.md` | Project task reorder and operational sequence — Verdict: ACTIVE_OPERATIONAL_ROADMAP_CREATED_PENDING_DOCS_BRANCH_COMMIT; 8 priorities P0–P8; top blocker actual_trade=0/confirm_role_absent (P2); TTM stale recommendation corrected (RESEARCH_ONLY); NR7 shadow validated small-N; SIOL design complete/impl not authorized |

**AI-root architecture document (not in DOCS_SYSTEM/ folder):**

| File | Location | Description |
|---|---|---|
| `MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1.md` | `MQL5/Experts/AI/` | PRIMARY MT5 IO reduction architecture — Package 1 spec complete; 5-component MT5_IO_REDUCTION_V1; Package 2 Codex brief |

---

## 02_IMPLEMENTATION_REPORTS/ — 9 files

Implementation execution reports and fix verification reports.

| File | Description |
|---|---|
| `FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_REPORT.md` | FVG-TPB MT5 implementation execution report |
| `FVG_TPB_RELOAD_BLOCKER_FIX_PACKAGE_V1_REPORT.md` | FVG-TPB reload blocker fix report |
| `PLAYBOOK_ARCHITECTURE_FULL_IMPLEMENTATION_PACKAGE_V1_REPORT.md` | Playbook architecture full implementation report |
| `V1C_CLEANUP_PACKAGE_V1_REPORT.md` | V1C cleanup package execution report |
| `FORCED_ENGINEERING_ACTIVATION_OF_ALL_TARGET_ARCHITECTURE_DESIGNS_V1_REPORT.md` | Forced engineering activation implementation report (Packages A–D) |
| `LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1_REPORT.md` | Lab infer_family registry FVG-TPB fix report |
| `POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1_REPORT.md` | Post-forced-activation correction and documentation network report |
| `MT5_IO_REDUCTION_V1_PACKAGE2_IMPLEMENTATION_REPORT.md` | MT5-side IO reduction Package 2 implementation report |
| `NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_PACKAGE_V1_REPORT.md` | NR7 shadow runtime integration implementation report — Verdict: NR7_SHADOW_RUNTIME_INTEGRATION_COMPLETE_COMPILE_CLEAN; 0 errors/warnings; OL writer divergence resolved (confirmed at :1638); zero trading behavior change; branch split/source-before-gemini-worker-policy |

---

## 03_RUNTIME_VALIDATION/ — 11 files

Runtime sanity reviews, post-reload validation, and operational audit docs.

| File | Description |
|---|---|
| `BTCUSD_INTERIM_POST_RELOAD_FVG_TPB_RUNTIME_SANITY_AND_FIX_REVIEW_V1_REPORT.md` | BTCUSD interim post-reload FVG-TPB sanity review |
| `BTCUSD_POST_RELOAD_FORCED_ACTIVATION_RUNTIME_SANITY_REVIEW_V1.md` | BTCUSD post-forced-activation reload sanity review (Verdict: PASS_WITH_CAVEATS) |
| `XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1.md` | XAUUSD attach checklist — operator instructions for next reload |
| `BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1.md` | best_strategy_id functional audit after IRREW refactor |
| `BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1.md` | best_strategy_id semantic governance update |
| `LEGACY_SCORE_HYBRID_RUNTIME_SURFACE_AUDIT_V1.md` | Legacy score + hybrid runtime surface audit |
| `MT5_PRE_MARKET_FULL_SYSTEM_TESTER_VALIDATION_V1.md` | MT5 Strategy Tester validation + static IRREW architecture analysis (Verdict: TESTER_PARTIAL_EVIDENCE_REQUIRES_LIVE_XAUUSD) |
| `MT5_IO_REDUCTION_RUNTIME_EVIDENCE_DOSSIER_V1.md` | IO Reduction Package 2 runtime proof dossier (Verdict: IO_REDUCTION_PROVEN_ACTIVE_1 — OL_RATE proven 83%; PJ_BUFFER zero-activity anomaly requires source investigation) |
| `RAM_IO_REDUCTION_AND_PENDING_ACTIVATION_PHASES_READINESS_REVIEW_V1.md` | Post-fix IO/RAM proof + trade-quality phase readiness (Verdict: RAM_IO_VALIDATION_PASS_PJ_BUFFER_PROVEN + TRADE_QUALITY_PHASES_NOT_READY_DO_NOT_ENABLE) |
| `POST_COMPILE_RUNTIME_FLAGS_AND_GIT_STATE_VERIFICATION_V1.md` | Compile verification (0 errors/warnings) + IRREW dev flags (all disabled confirmed) + IO reduction continuation + binary load + Git state (Verdict: VERIFIED_WITH_CAVEATS — BINARY_MTIME_DISCREPANCY_NOTED; runtime consistent with fix compile) |
| `FULL_DAY_RUNTIME_EVIDENCE_REVIEW_AND_STATE_UPDATE_V1.md` | Full-day runtime evidence review after NR7 shadow integration — Verdict: SYSTEM_ACTIVE_NO_TRADES_PARTIAL_WINDOW; NR7 shadow validated (small N, all NONE); IRREW flags clean; IO clean; actual_trade=0 persists; OL writer divergence resolved; 3 active anomalies |

---

## 04_NAUTILUS_INEC/ — 1 file

Nautilus Trader certification lab and INEC evidence framework.

| File | Description |
|---|---|
| `IRREW_NAUTILUS_EVIDENCE_CERTIFICATION_LAB_V1.md` | Nautilus evidence certification lab design (INEC V1) |

---

## 05_HANDOVER_AND_ACCEPTANCE/ — 7 files

Development completion declarations, PCEA reviews, and handover packages.

| File | Description |
|---|---|
| `DEVELOPMENT_COMPLETE_DECLARATION_V1.md` | Development completion declaration V1 |
| `DEVELOPMENT_COMPLETE_HANDOVER_PACKAGE_V1.md` | Development complete handover package |
| `DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1.md` | Dev-to-production acceptance plan |
| `ENGINEERING_ACTIVATION_REVIEW_FOR_V1_IRREW_PCEA_V1.md` | Engineering activation review for IRREW PCEA |
| `IRREW_PCEA_PENDING_WORK_STATUS_UPDATE_FAST_V1.md` | IRREW PCEA pending work status update |
| `FORCED_ENGINEERING_ACTIVATION_ARCHITECTURAL_EXECUTION_SPEC_REVIEW_V1.md` | Forced engineering activation spec review |
| `FORCED_ENGINEERING_ACTIVATION_FULL_FORENSIC_ADVERSARIAL_REVIEW_V1.md` | Full forensic adversarial review of forced activation |

---

## 06_AUDITS_AND_REVIEWS/ — 10 files

Standalone audit reports and external review documents.

| File | Description |
|---|---|
| `DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1_REPORT.md` | Dataflow, Experts log, documentation network, and strategy gap audit report |
| `MT5_IO_REDUCTION_V1_PACKAGE3_FORENSIC_REVIEW.md` | Package 3 forensic review of MT5_IO_REDUCTION_V1 Package 2 — Verdict: PASS_RELOAD_ALLOWED_WITH_CAVEATS |
| `UNEXPECTED_BTCUSD_DEMO_TRADES_AFTER_IO_REDUCTION_RELOAD_FORENSIC_V1.md` | Emergency forensic investigation of 2 unexpected BTCUSD demo trades — Verdict: TRADES_CAUSED_BY_RUNTIME_EXECUTION_ENABLED_ON_BTCUSD / NO_ROLLBACK_NEEDED_IO_REDUCTION_SAFE |
| `LEGACY_SURFACE_DEAD_CODE_AND_OBSOLETE_FIELD_CLEANUP_AUDIT_V1.md` | Legacy/dead-code/obsolete-field cleanup audit — Verdict: CLEANUP_REQUIRED_HIGH_VALUE; 25 items classified; Package A COMPLETED; Package B design complete |
| `DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1.md` | Deep dependency matrix review of EvaluateCompiledPlan/Zone 2/router — Verdict: PACKAGE_B_READY_BUT_STUB_REQUIRED; Codex package ZONE2_COMPILE_ISOLATION_V1 specified |
| `GEMINI_EXTERNAL_XAUUSD_STRATEGY_CANDIDATE_RESEARCH_V1.md` | Gemini external research dossier — 12 candidates, 4 eliminated, top 3 ranked (NR7 #1, TTM Squeeze #2, RSI Divergence+Candlestick #3 per Gemini); full source citations with quality ratings |
| `CLAUDE_EXTERNAL_STRATEGY_SELECTION_AND_INEC_PLAN_V1.md` | Claude independent evaluation + INEC plan — re-ranked TTM Squeeze to #1 (ALPHA_TRIGGER + LOCATION dual role, resolves event_order_valid=false); full INEC plan E1–E10; Gate 1 PENDING |
| `BLOCKER_CLOSURE_PACKAGE_1_GIT_HYGIENE_AND_TRADE_STARVATION_FORENSICS_V1.md` | BUILD_FREEZE forensics — Verdict: BLOCKER_CLOSURE_PACKAGE_1_FORENSICS_COMPLETE; actual_trade=0 is CORRECT_SYSTEM_BEHAVIOR (CONFIRM triggers require price at BB band or range extreme); event_order_valid=false hardcoded by design; playbook shadow naming confusion resolved; 10 blockers classified; next: GEMINI re-brief for CONFIRMATION_PACKET |
| `CONFIRMATION_PACKET_CANDIDATE_DISCOVERY_AND_INEC_SCREEN_V1.md` | Three-iteration INEC co-presence screen (V1/V2/V3, 9 candidates) — Verdict: CONFIRMATION_PACKET_GAP_REMAINS_OPEN_NEEDS_NEW_SEARCH; all candidates with large lifts disqualified (artifacts, look-ahead, trigger-quality filters); only independent signals (PTBM, PTAI) rejected weak; M5BC_CORR +3pp SR at 93% starvation — RESEARCH_ONLY; TBB reveals critical SR trigger bifurcation (57.3% vs 21.2% WR) as TRIGGER_REFINEMENT finding; next: Gemini Gate 1 |
| `GEMINI_GATE1_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1.md` | Gate 1 INEC co-presence screen (H1DA, BBMP, RMDM) with mandatory RMR interior subset filter — Verdict: CONFIRMATION_GAP_REMAINS_OPEN_AFTER_GATE1; all 3 candidates failed interior subset (H1DA harmful, RMDM starvation/flat, BBMP RESEARCH_ONLY aggregate); BBMP BUY TM interior STRONG_ACCEPT statistically but monthly inconsistent; Gemini fallback triggered; 8 candidates generated; top 3 selected (BBMP3, M5MP, M52MP) for Gate 2; next: GEMINI_GATE2_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1 |

---

## 99_LEGACY_OR_SUPERSEDED/ — 0 files (reserved)

Reserved for documents that have been superseded or deprecated but retained for reference.

---

## Notes

- The `docs/` subfolder at `MQL5/Experts/AI/docs/` predates this structure and is retained in place. Its contents are not catalogued here.
- For the complete move history (old paths → new paths), see `DOCS_MOVE_MANIFEST_V1.md` in this folder.
- PIML (`PROJECT_INTELLIGENCE_MEMORY_LAYER.md`) is the authoritative source for project phase and status — this index is a navigation aid only.

```
INDEX_ID:       DOCS_SYSTEM_INDEX_V1
CREATED:        2026-05-10
CONTEXT:        POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1
FILES_INDEXED:  55 (DOCS_SYSTEM/) + 1 AI-root architecture doc
ROOT_KEPT:      3 (AGENTS.md, OPERATION_GUARDRAILS.md, PROJECT_INTELLIGENCE_MEMORY_LAYER.md)
LAST_UPDATED:   2026-05-12 — added GEMINI_GATE1_INTERIOR_RANGE_CONFIRMATION_SEARCH_V1 to 06_AUDITS_AND_REVIEWS (now 10 files); total 54 docs; Gate 1 complete; gap remains open; BBMP BUY TM interior lead; Gemini fallback triggered; Gate 2 candidates: BBMP3, M5MP, M52MP
```
