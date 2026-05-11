# FINAL_GOVERNED_SYSTEM_ARCHIVE_V1 — ARCHIVE MANIFEST

**Document type:** Governed archive manifest
**Date:** 2026-05-09
**Task:** FINAL_GOVERNED_SYSTEM_ARCHIVE_AND_HANDOVER_PACKAGE_V1

---

## A. Archive Identity

| Field | Value |
|---|---|
| Archive name | `FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_20260509_215951.zip` |
| Archive path | `D:\MT5_Project_Backups\FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_20260509_215951.zip` |
| Archive size | 9.87 MB (10,352,799 bytes) |
| Created at | 2026-05-09 21:59:51 |
| Archive format | ZIP (System.IO.Compression.ZipFile, .NET Framework) |
| Structure preserved | YES — folder prefixes Experts\AI\ and Files\AI\ maintained |

---

## B. Entry Count Summary

| Category | Count |
|---|---|
| Total entries | 1,134 |
| Experts\AI\ entries | 462 |
| Files\AI\ entries | 672 |
| .mqh source files | 78 |
| .mq5 source files | 2 |
| .ex5 compiled binary | 1 |
| .md governance documents | 172 |
| .log compile logs | 92 |

---

## C. Root Folders Included

| Folder | Source Path | Entries | Purpose |
|---|---|---|---|
| `Experts\AI\` | `c:\Users\INFINTY GROUP\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\AI\` | 462 | All governed source files, documentation, compile logs |
| `Files\AI\` | `c:\Users\INFINTY GROUP\AppData\Roaming\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Files\AI\` | 672 | All runtime JSON/JSONL files at archive time |

---

## D. Excluded Directories and Files

| Excluded Item | Reason |
|---|---|
| `Experts\AI\external_dashboard\` (545.9 MB, 11,631 files) | Dashboard visualization data — not governed source; not MT5 execution logic |
| `*.bak_*` PIML snapshot files | Redundant historical snapshots; current PIML.md is the authority |

---

## E. Key Files Confirmed in Archive

| File | Status | Notes |
|---|---|---|
| `Experts\AI\main_ea.ex5` | PRESENT | Binary timestamp 2026-05-09 12:50:10; 2.54 MB |
| `Experts\AI\main_ea.mq5` | PRESENT | Primary EA source file |
| `Experts\AI\council_mode_runtime.mqh` | PRESENT | V1C OL schema; playbook shadow; fvg_tpb wiring |
| `Experts\AI\council_mode_types.mqh` | PRESENT | COUNCIL_MAX_STRATEGIES=18; OL structs |
| `Experts\AI\council_strategies.mqh` | PRESENT | BuildCouncilStrategy_FVG_TPB + all 18 strategies |
| `Experts\AI\council_pre_ai_filter.mqh` | PRESENT | A2 score gate demotion; bollinger_reclaim hostile gate |
| `Experts\AI\council_ai_governor.mqh` | PRESENT | Stage D categorical observer |
| `Experts\AI\authority_stack_pilot.mqh` | PRESENT | P4+V1 live; DQ diagnostic (A3-Revised) |
| `Experts\AI\level_awareness_brake.mqh` | PRESENT | LAB_InferFamilyFromStrategyId fix; fvg_tpb → IMBALANCE_FILL_REVERSAL |
| `Experts\AI\council_v1_state_composer.mqh` | PRESENT | V1 FSW + Phase 2+3 + Phase 2.5 |
| `Experts\AI\council_aggregator.mqh` | PRESENT | No-Score Core Package 1 aggregation |
| `Experts\AI\council_environment.mqh` | PRESENT | env.total_score removed from live authority |
| `Experts\AI\performance_journal.mqh` | PRESENT | sl_vs_m5_atr_ratio; level_context_at_entry; mae_pts/mfe_pts |
| `Experts\AI\PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | PRESENT | 6,805 lines; 676.3 KB; sole authoritative phase/status memory |
| `Experts\AI\PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md` | PRESENT | 17+fvg_tpb; GF-1 through GF-12 |
| `Experts\AI\DEVELOPMENT_COMPLETION_TO_PRODUCTION_ACCEPTANCE_PLAN_V1.md` | PRESENT | 57-item PAC; 13-item RDL |
| `Experts\AI\MASTER_DEVELOPMENT_CLOSURE_BACKLOG_V1.md` | PRESENT | DEV-C gate final assessment |
| `Experts\AI\SOURCE_READ_REQUIRED_RESOLUTION_V1.md` | PRESENT | SRR resolution for 9 items |
| `Experts\AI\BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1.md` | PRESENT | IRREW doctrine; authority layer formalization |
| `Experts\AI\compile_lab_infer_family_registry_fvg_tpb_fix_v1_20260509_124554.log` | PRESENT | Latest compile log (see warning status below) |
| `Files\AI\ai_opportunity_ledger.jsonl` | PRESENT | V1C live records; 38+ BTCUSD records at archive time |
| `Files\AI\ai_performance_journal.jsonl` | PRESENT | Runtime DECISION and TRADE records |
| `Files\AI\ai_strategy_memory.json` | PRESENT | Live strategy counters (17+1 strategies) |
| `Files\AI\ai_opportunity_summary.json` | PRESENT (if exists) | Per-session evaluation summary |

---

## F. Binary Metadata

| Field | Value |
|---|---|
| Binary file | `main_ea.ex5` |
| Binary timestamp | 2026-05-09 12:50:10 |
| Binary size | 2,660,892 bytes (2.54 MB) |
| Binary source | Compiled from `main_ea.mq5` (latest compile: LAB_INFER_FAMILY_REGISTRY_FVG_TPB_FIX_V1) |
| Compile result | **0 errors, 0 warnings** |
| Compile log | `compile_lab_infer_family_registry_fvg_tpb_fix_v1_20260509_124554.log` |
| Compile duration | 255,799 ms elapsed |
| CPU target | X64 Regular |

---

## G. Compile Warning Status

**KNOWN_COMPILE_WARNING_WAIVER: NOT REQUIRED**

The latest compile log (`compile_lab_infer_family_registry_fvg_tpb_fix_v1_20260509_124554.log`) reports:
```
Result: 0 errors, 0 warnings, 255799 ms elapsed, cpu='X64 Regular'
```

The 2 pre-existing int-to-string warnings mentioned in earlier PIML entries (V1-FSW Phase 1 through Authority Stack period) were resolved by `compile_warning94_cleanup_20260503_010513.log`. All subsequent compiles have been 0 warnings.

**Conclusion:** No compile warning waiver is required. DEV-C-01 is met with full 0 errors / 0 warnings.

---

## H. System State at Archive Time

| Field | Value |
|---|---|
| System status | DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING |
| Production ready | FALSE |
| Active EA instance | BTCUSD, M5, binary 2026-05-09 12:50:10 |
| Opportunity ledger records | 38+ (BTCUSD; XAUUSD validation pending) |
| Strategy count | 18 (17 legacy + fvg_tpb) |
| Operating cohort | LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT |
| IFR cohort status | Permanently excluded (IMBALANCE_FILL_REVERSAL) |
| V1C schema version | OL_V1C_PLAYBOOK_SHADOW |
| PIML size | 6,805 lines / 676.3 KB |
| Playbook registry | RBSR FORMING; TPC FORMING; VCR NOT_PRESENT; IFR FORMING/NO_VALID |
| Nautilus certifications | 7/17 strategies certified (1 FROZEN; 9 DATA_INSUFFICIENT) |
| Phase 4A | BLOCKED (TPC fire rate unverified) |
| Phase 4B | PARTIALLY_UNBLOCKED (2 MFI entries; needs ≥5) |
| Phase 4C | BLOCKED (38 records; needs ≥200) |
| Phase 5A | APPLIED + compile-clean; XAUUSD validation pending |
| Phase 5B+ | NOT_AUTHORIZED |
| Phase 6 EEWP | DESIGN_ONLY |

---

## I. Runtime Debt Ledger Summary (13 items — all open)

| RDL # | Item | Status |
|---|---|---|
| RDL-001 | FVG_TPB first trigger XAUUSD | PENDING (market hours) |
| RDL-002 | fvg_/ifr_ serialization in OL records | PENDING (depends on RDL-001) |
| RDL-003 | Phase 5A hostile branch validated | PENDING (XAUUSD TREND_UP required) |
| RDL-004 | IFR playbook state in XAUUSD session | PENDING (depends on RDL-001) |
| RDL-005 | OL 200-record threshold for Phase 4C | PENDING (38 records; needs 162+) |
| RDL-006 | Phase 4A TPC fire rate decision | PENDING (TPC 0 BTCUSD triggers observed) |
| RDL-007 | Phase 4B MFI signal readings ≥5 | PARTIALLY_UNBLOCKED (2 readings confirmed) |
| RDL-008 | Phase 5A bollinger_reclaim SELL gate validated | PENDING (XAUUSD TREND_UP required) |
| RDL-009 | V1C K1/K3 runtime confirmation (A1 flag=true) | ACTIVE (flag=true; K1/K2/K3 compiled; XAUUSD session needed) |
| RDL-010 | No-Score A2 field in DECISION records (XAUUSD) | SUBSTANTIALLY_DONE (source confirmed; XAUUSD reload needed) |
| RDL-011 | EQ-DIAG fields in TRADE records | PENDING (requires completed XAUUSD trade) |
| RDL-012 | V1C K1–K3 full coverage XAUUSD post-cleanup | PENDING (binary ready; XAUUSD session needed) |
| RDL-013 | PLAN-ARCH-DR P3.2 expected_rr_estimate field | PENDING (compile-verified; XAUUSD runtime unconfirmed) |

---

## J. Governance Caveats

1. This archive does NOT include `external_dashboard/` content (545.9 MB, 11,631 files — dashboard visualization layer, not governed source).
2. PIML `.bak_*` snapshot files excluded (redundant historical snapshots; current PIML.md is authority).
3. The Files\AI\ content is a snapshot as of archive creation time — runtime JSON/JSONL files will continue to evolve after dev-complete.
4. This archive represents the DEVELOPMENT_COMPLETE baseline. Any source change after archive creation restarts the baseline clock and requires a new archive.

---

## Footer

```
MANIFEST_ID:          FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_MANIFEST
DATE:                 2026-05-09
ARCHIVE_PATH:         D:\MT5_Project_Backups\FINAL_GOVERNED_SYSTEM_ARCHIVE_V1_20260509_215951.zip
ARCHIVE_SIZE:         9.87 MB (10,352,799 bytes)
TOTAL_ENTRIES:        1,134
EXPERTS_AI_ENTRIES:   462
FILES_AI_ENTRIES:     672
BINARY_TIMESTAMP:     2026-05-09 12:50:10
COMPILE_STATUS:       0 errors, 0 warnings
WARNING_WAIVER:       NOT REQUIRED
SYSTEM_STATUS:        DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
PRODUCTION_READY:     FALSE
```
