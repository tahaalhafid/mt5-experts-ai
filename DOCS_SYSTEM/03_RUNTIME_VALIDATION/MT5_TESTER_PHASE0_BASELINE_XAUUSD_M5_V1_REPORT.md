# MT5_TESTER_PHASE0_BASELINE_XAUUSD_M5_V1_REPORT

**Date:** 2026-05-10
**Verdict:** `BLOCKED_TESTER_ENVIRONMENT — TESTER_RUN_REQUIRED_BY_OPERATOR`

---

## A. Executive Verdict

**Final verdict:** `BLOCKED_TESTER_ENVIRONMENT`

Phase 0 baseline tester run has not been executed. No fresh tester artifacts for `main_ea` on XAUUSD M5 with the current binary (2026-05-10 06:22:51) exist in the tester output directories. The MT5 terminal is not currently running. The Phase 0 result cannot be determined without an actual tester run.

All pre-run checks were completed and passed. The system is ready. The operator must initiate the tester run from the MT5 terminal UI.

**Scope filter applied:** Only artifacts satisfying ALL of the following were considered:
- Project path: `...\D0E8209F77C8CF37AD8BF550E51FF075\MQL5\Experts\AI`
- EA: `main_ea`, binary timestamp ≥ 2026-05-10 06:22:51
- Tester config: `phase0_baseline.set`, XAUUSD M5, 2026.04.14–2026.05.02, all IRREW flags false

---

## B. Tester Environment

| Check | Result |
|---|---|
| MT5 terminal running | NO — no `terminal64.exe` process found at scan time |
| Terminal executable present | YES — `C:\Program Files\MetaTrader 5\terminal64.exe` (Build 5836, 2026-04-29) |
| Data directory present | YES — `D0E8209F77C8CF37AD8BF550E51FF075` confirmed |
| XAUUSD history present | YES — `bases/Tickmill-Demo/history/XAUUSD/` has `.hcc` files through 2026 |
| Phase 0 .set file present | YES — `MQL5/Profiles/Tester/main_ea_phase0_baseline_TESTER_ONLY_NOT_LIVE.set` |
| Tester INI config present | YES — `MQL5/Experts/AI/TESTER_CONFIGS/tester_phase1_baseline.ini` |
| Today's tester log (20260510.log) | NOT FOUND — tester has not run today |
| Agent directories in Tester/ | NOT FOUND — only `cache/` and `logs/` subdirectories exist |
| Fresh main_ea XAUUSD M5 tester output | NOT FOUND |

**Tester environment verdict: READY but RUN NOT EXECUTED**

---

## C. Binary / Build Confirmation

| Item | Value |
|---|---|
| Binary file | `MQL5/Experts/AI/main_ea.ex5` |
| Binary timestamp | 2026-05-10 06:22:51 (confirmed present on disk) |
| Source | DATAFLOW_EXPERTS_LOG_DOCS_AND_STRATEGY_GAP_AUDIT_PACKAGE_V1 compile |
| Compile result | 0 errors / 0 warnings (log: `compile_dataflow_experts_docs_strategy_gap_v1_20260510_061821.log`) |
| Compile duration | 265981 ms |
| Build | 5836 |
| Binary mismatch | NONE FOUND — binary matches expected build |

---

## D. Phase 0 Settings Used

**Set file:** `main_ea_phase0_baseline_TESTER_ONLY_NOT_LIVE.set`

Verified content from file read (UTF-16 encoded, content confirmed):

```
EnableIRREWDevelopmentConsumption=false
EnableIRREWPhase4ADev=false
EnableIRREWPhase4BDev=false
EnableIRREWPhase4CDev=false
EnableIRREWRCEMDev=false
EnableIRREWExecutionGeometryDev=false
EnableIRREWPlaybookAdvisoryDev=false
```

All 7 IRREW development flags: **CONFIRMED FALSE** — safe to proceed. `IRREW_FLAG_STATE_UNSAFE_FOR_PHASE0` does NOT apply.

Additional confirmed settings:
- `FixedLot=0.1`
- `Magic=26059999`
- `EnableRuntimeExecution=true`
- `TradeRR=1.5`
- `TradeATRMultiplier=1.2`
- `LogRuntimeDecision=true`
- `EnableTradeFeedbackLogging=true`

**INI config:** `tester_phase1_baseline.ini`
```
Expert=AI\main_ea
Symbol=XAUUSD
Period=M5
Model=4 (Every tick)
FromDate=2026.04.14
ToDate=2026.05.02
Optimization=0
Visual=0
ShutdownTerminal=0
```

---

## E. Tester Execution Result

**Status: NOT EXECUTED**

The Phase 0 tester run has not been performed. This is not a failure of the EA, configuration, or environment — it is a pending operator action. The run must be initiated from within the MT5 terminal.

---

## F. Logs / Runtime Errors

**No Phase 0 logs exist.** The following files were found in `Tester/logs/` and were scoped OUT:

| File | Reason Excluded |
|---|---|
| `20260505.log` | Wrong EA — `DynamicTemporalRailLadder_EA`; wrong project; predates current binary |
| `20260506.log` | Contains only "Cloud servers switched off" — no main_ea run; wrong date |

No `20260510.log` file exists. The Phase 0 run has not generated any log output.

---

## G. IRREW Flags State

**From set file — all confirmed false:**

| Flag | Value in Set File | Safe for Phase 0 |
|---|---|---|
| `EnableIRREWDevelopmentConsumption` | `false` | YES |
| `EnableIRREWPhase4ADev` | `false` | YES |
| `EnableIRREWPhase4BDev` | `false` | YES |
| `EnableIRREWPhase4CDev` | `false` | YES |
| `EnableIRREWRCEMDev` | `false` | YES |
| `EnableIRREWExecutionGeometryDev` | `false` | YES |
| `EnableIRREWPlaybookAdvisoryDev` | `false` | YES |

`IRREW_FLAG_STATE_UNSAFE_FOR_PHASE0`: **NOT TRIGGERED** — all flags false. Safe to run.

---

## H. Routing / Legacy Surface Confirmation

Cannot confirm from tester output — run has not occurred.

From source analysis (PIML §34, static verification):
- `decision_engine_mode=COUNCIL` is the active routing mode
- Compiled-plan path startup labels are now clearly marked as diagnostics (DATAFLOW audit fix)
- No EvaluateCompiledPlan authority path is used under COUNCIL routing

These will require tester output to runtime-confirm.

---

## I. Strategy Universe Confirmation

Cannot confirm count from tester output — run has not occurred.

From source analysis: 18 strategies in council universe (17 cohort + 1 playbook observer `fvg_tpb`).

---

## J. fvg_tpb Evaluation Result

**CANNOT CHECK — Phase 0 run has not executed.**

The primary validation target (`fvg_tpb evaluations_seen > 0`) requires:
1. Tester to run on XAUUSD M5 with the current binary
2. EA to write `ai_opportunity_summary.json` or equivalent output to the tester agent directory
3. That output to be read from `Tester/Agent-*/MQL5/Files/AI/`

Status: `PENDING_TESTER_RUN`

---

## K. OL / JSON / Schema Result

**CANNOT CHECK — No tester output produced.**

Schema fields to verify after run:
- `record_version = "OL_V1C_IRREW_DEV_V1"`
- `irrew_schema_version = "OL_V1C_IRREW_DEV_V1"`
- `runtime_authority_status = "NONE"`
- All 7 IRREW dev flags false in OL records

---

## L. Authority Boundary Confirmation

Cannot confirm from tester output — run has not occurred.

Static source verification (PIML §34) confirms:
- DQ no-score hard-lock: 9+ commented gates at `main_ea.mq5:L10903–10976` — untouched
- `IMBALANCE_FILL_REVERSAL` remains outside operating cohort
- `PLAYBOOK_VALID` is not permission
- `IRREW_ApplyDevelopmentWaitProtocol` cannot promote REJECT → execution

---

## M. Runtime Files Modified by Tester

**None — tester has not run.**

File isolation pre-check confirmed:
- EA uses no `FILE_COMMON` flag
- Tester writes to `Tester/Agent-*/MQL5/Files/` (agent-isolated), not live `MQL5/Files/AI/`
- Live runtime files (`ai_performance_journal.jsonl`, `ai_opportunity_summary.json`, etc.) are SAFE from tester contamination

---

## N. Issues / Caveats

1. **Phase 0 has not run.** Operator action required to initiate from MT5 terminal UI.
2. **Terminal was not running at pre-check time.** Terminal must be started by operator and tester initiated via View → Strategy Tester.
3. **Old DTRL tester logs exist** in `Tester/logs/` from May 5-6. These belong to an unrelated EA (`DynamicTemporalRailLadder_EA`) and must not be used as Phase 0 evidence. They have been explicitly excluded.
4. **XAUUSD M5 tester cache** (`main_ea.XAUUSD.M5.20040611.20260423.41.*.opt`) is an old optimization result cache predating the current binary. Not Phase 0 output. Excluded.
5. **`ShutdownTerminal=0`** in the INI config — the terminal will remain open after the tester completes. This is correct for operator-assisted runs (allows result inspection in GUI). Do not change this for the Phase 0 run.

---

## O. Whether Phase 2 Master_True Can Proceed

**NO — Phase 0 has not completed.** Phase 2 requires Phase 0 to complete with verdict `PASS_PHASE0_BASELINE` or `PASS_PHASE0_BASELINE_WITH_CAVEATS`. Phase 0 is currently `BLOCKED_TESTER_ENVIRONMENT`. Phase 2 is blocked.

---

## P. What Must Not Be Concluded

- Do not conclude Phase 0 passed from static source analysis alone.
- Do not infer `fvg_tpb evaluations_seen > 0` from prior live session evidence.
- Do not use DTRL tester logs or old optimization caches as Phase 0 evidence.
- Do not conclude Phase 0 failed — it has simply not run yet.
- Do not enable IRREW development flags before Phase 0 completes.

---

## Q. Final Decision

**`BLOCKED_TESTER_ENVIRONMENT`**

Phase 0 cannot be completed until the operator runs the tester manually from the MT5 terminal. All pre-checks passed. The set file is correct, the binary is current, the XAUUSD history exists, and all IRREW flags are confirmed false. The only missing element is the operator-initiated tester run.

---

## OPERATOR RUN INSTRUCTIONS — Phase 0 Baseline

Follow these exact steps to execute Phase 0:

### Step 1: Start MT5 Terminal

Open MT5 terminal:
```
C:\Program Files\MetaTrader 5\terminal64.exe
```
Wait for it to connect to Tickmill-Demo and fully load.

### Step 2: Open Strategy Tester

In the terminal menu: **View → Strategy Tester**

Or press **Ctrl+R**.

### Step 3: Configure Tester

In the Strategy Tester panel:

| Field | Value |
|---|---|
| Expert Advisor | `AI\main_ea` |
| Symbol | `XAUUSD` |
| Timeframe | `M5` |
| Model | `Every tick based on real ticks` (or `Every tick` if unavailable) |
| Date From | `2026.04.14` |
| Date To | `2026.05.02` |
| Optimization | `Disabled` |
| Visual mode | `OFF` |

### Step 4: Load the Phase 0 Set File

In the Inputs tab: click **Load** → navigate to:
```
MQL5\Profiles\Tester\main_ea_phase0_baseline_TESTER_ONLY_NOT_LIVE.set
```

**Verify before running:** All 7 IRREW flags must show `false`:
- `EnableIRREWDevelopmentConsumption` = false
- `EnableIRREWPhase4ADev` = false
- `EnableIRREWPhase4BDev` = false
- `EnableIRREWPhase4CDev` = false
- `EnableIRREWRCEMDev` = false
- `EnableIRREWExecutionGeometryDev` = false
- `EnableIRREWPlaybookAdvisoryDev` = false

If any flag shows `true`: STOP — do not run. Report `IRREW_FLAG_STATE_UNSAFE_FOR_PHASE0`.

### Step 5: Run the Test

Click **Start**.

Wait for the run to complete. Expected runtime: 5–30 minutes for XAUUSD M5, 2026.04.14–2026.05.02 date range.

### Step 6: Collect Artifacts After Run

After the run completes:

1. **Tester Journal tab** — screenshot or copy all log lines from the Journal tab (inside Strategy Tester panel)
2. **Experts log** — in the main terminal: View → Terminal → Experts tab — copy any lines from the tester run
3. **Tester agent files** — check:
   ```
   Tester\Agent-127.0.0.1-3000\MQL5\Files\AI\ai_opportunity_summary.json
   Tester\Agent-127.0.0.1-3000\MQL5\Files\AI\ai_opportunity_ledger.jsonl (if exists)
   Tester\Agent-127.0.0.1-3000\MQL5\Files\AI\runtime_governance_status.json (if exists)
   ```
   (Agent port number may vary — check `Tester\` directory for `Agent-*` folders after run completes)
4. **Tester log** — `Tester\logs\20260510.log` (today's date)

### Step 7: Confirm fvg_tpb

In `ai_opportunity_summary.json`, look for a record with `strategy_id = "fvg_tpb"`.

Check: `evaluations_seen > 0`

Report the exact value. This is the primary Phase 0 validation target.

### Step 8: Report Back

Provide the following to Claude:
- Contents of `Tester\logs\20260510.log`
- Contents of `Tester\Agent-*/MQL5\Files\AI\ai_opportunity_summary.json`
- Any errors from Journal/Experts log
- Whether the EA initialized and ran without crash

---

```
REPORT_ID:                    MT5_TESTER_PHASE0_BASELINE_XAUUSD_M5_V1_REPORT
DATE:                         2026-05-10
FINAL_VERDICT:                BLOCKED_TESTER_ENVIRONMENT
SCOPE_FILTER_VERDICT:         BLOCKED_PHASE0_TESTER_OUTPUT_NOT_FOUND
BINARY_CONFIRMED:             main_ea.ex5 2026-05-10 06:22:51 (present on disk)
IRREW_FLAGS_IN_SET:           ALL FALSE — SAFE_FOR_PHASE0
TESTER_RUN_STATUS:            NOT_EXECUTED
FVG_TPB_CHECK:                PENDING_TESTER_RUN
CONTAMINATION_RISK:           ZERO — old DTRL logs excluded by scope filter
PHASE2_CAN_PROCEED:           NO — Phase 0 must complete first
SOURCE_CHANGED:               NO
COMPILE_RUN:                  NO
LIVE_TRADING:                 NO
PRODUCTION_READY_CLAIMED:     NO
OPERATOR_ACTION:              RUN_STRATEGY_TESTER_PHASE0_BASELINE_XAUUSD_M5
SET_FILE:                     MQL5/Profiles/Tester/main_ea_phase0_baseline_TESTER_ONLY_NOT_LIVE.set
INI_CONFIG:                   MQL5/Experts/AI/TESTER_CONFIGS/tester_phase1_baseline.ini
```
