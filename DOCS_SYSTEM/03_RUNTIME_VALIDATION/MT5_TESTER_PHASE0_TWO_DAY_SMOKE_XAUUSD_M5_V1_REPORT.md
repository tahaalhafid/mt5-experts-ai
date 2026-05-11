# MT5_TESTER_PHASE0_TWO_DAY_SMOKE_XAUUSD_M5_V1_REPORT

## A. Executive Verdict

**Final verdict:** `TWO_DAY_SMOKE_COMPLETED_FVG_TPB_NOT_CONFIRMED`

The MT5 Strategy Tester was actually started from Codex using `terminal64.exe /config`. The test completed successfully at the tester level, but the EA runtime did not reach the COUNCIL / Opportunity Ledger / fvg_tpb evaluation path because the tester agent sandbox was missing `AI\ai_current_plan.json`. Runtime governance stayed `TRUTH_NOT_READY` with reason `active_plan_missing`.

No source code was modified. No compile was run. No PIML update was made. No runtime JSON/JSONL history in the terminal `MQL5/Files/AI` folder was manually modified.

## B. Tester Was Actually Started?

Yes.

- Run start: `2026-05-10 16:28:38`
- Terminal process: `C:\Program Files\MetaTrader 5\terminal64.exe`
- Start config: `MQL5/Experts/AI/tester_phase0_xauusd_m5_v1_20260510_162838.ini`
- Terminal exit code: `0`
- Tester log result: `last test passed with result "successfully finished" in 0:02:48.127`

## C. Symbol / Date / Model Used

- EA: `Experts\AI\main_ea.ex5`
- Symbol: `XAUUSD`
- Timeframe: `M5`
- Date range: `2026.05.08 00:00` to `2026.05.10 00:00`
- Model: `1 minutes OHLC ticks generating`
- Optimization: `0`
- Visual mode: `0`

Fresh tester evidence:

```text
Tester XAUUSD,M5: testing of Experts\AI\main_ea.ex5 from 2026.05.08 00:00 to 2026.05.10 00:00 started with inputs
Tester XAUUSD,M5: 5508 ticks, 276 bars generated. Test passed in 0:02:48.127
```

## D. Settings and IRREW Flag State

Binary:

- `main_ea.ex5`
- timestamp: `2026-05-10 06:22:51`
- size: `2,692,418 bytes`

Settings file:

- `MQL5/Profiles/Tester/main_ea_phase0_baseline_TESTER_ONLY_NOT_LIVE.set`
- timestamp: `2026-05-10 15:22:08`

IRREW flags in tester set file:

```text
EnableIRREWDevelopmentConsumption=false
EnableIRREWPhase4ADev=false
EnableIRREWPhase4BDev=false
EnableIRREWPhase4CDev=false
EnableIRREWRCEMDev=false
EnableIRREWExecutionGeometryDev=false
EnableIRREWPlaybookAdvisoryDev=false
```

IRREW flag state verdict: safe for smoke run.

## E. Fresh Output Files

Only files modified after run start `2026-05-10 16:28:38` were used.

| Path | Modified | Why it belongs to this run |
|---|---:|---|
| `MQL5/Experts/AI/tester_phase0_xauusd_m5_v1_20260510_162838.ini` | 2026-05-10 16:28:39 | Created as the Strategy Tester launch config for this run. |
| `Terminal\Logs\20260510.log` | 2026-05-10 16:32:03 | Contains terminal startup, auto-testing start, successful tester finish, and shutdown for this config. |
| `Terminal\Tester\logs\20260510.log` | 2026-05-10 16:32:01 | Contains tester controller output, including `last test passed`. |
| `MetaQuotes\Tester\...\Agent-127.0.0.1-3000\logs\20260510.log` | 2026-05-10 16:32:01 | Contains EA Experts output for the fresh XAUUSD M5 test. |
| `MetaQuotes\Tester\...\Agent-127.0.0.1-3000\MQL5\Files\AI\diagnostic_runtime_summary.json` | 2026-05-10 16:32:00 | Fresh tester-agent runtime diagnostic summary. |
| `MetaQuotes\Tester\...\Agent-127.0.0.1-3000\MQL5\Files\AI\runtime_governance_status.json` | 2026-05-10 16:32:00 | Fresh tester-agent governance status showing `TRUTH_NOT_READY`. |
| `MetaQuotes\Tester\...\Agent-127.0.0.1-3000\MQL5\Files\AI\risk_safety_status.json` | 2026-05-10 16:32:00 | Fresh tester-agent risk/safety status showing safe block mode. |
| `MetaQuotes\Tester\...\Agent-127.0.0.1-3000\MQL5\Files\AI\active_operating_cohort.json` | 2026-05-10 16:32:00 | Fresh tester-agent cohort surface; cohort remained defined. |

Tester report HTML requested in config was not created at the requested path.

## F. Runtime / Error Review

EA loaded and initialized:

```text
[AI-EA] [INFO] Initializing main EA...
[AI-EA] [INFO] Libraries initialized successfully
```

Blocking runtime condition:

```text
[AI-EA] [WARN] truth sync failed: missing AI\ai_current_plan.json
[AI-EA] [WARN] Runtime governance not ready for trading | state=TRUTH_NOT_READY | reason=active_plan_missing
[AI-EA] [INFO] Runtime governance blocked trading | state=TRUTH_NOT_READY | reason=active_plan_missing
```

Fatal error scan:

- `FileOpen failure`: not observed as a fatal tester stop.
- `JSON error`: not observed as a fatal tester stop.
- `array out of range`: not observed.
- `invalid pointer`: not observed.
- `zero divide`: not observed.
- `abnormal termination`: not observed in this fresh tester run.
- `initialization failed`: not observed.
- `cannot load EA`: not observed.

Runtime error verdict: tester completed; EA was governance-blocked by missing active plan in tester sandbox.

## G. OL / JSON Schema Result

Fresh tester-agent files did not include:

- `ai_opportunity_summary.json`
- `ai_opportunity_ledger.jsonl`

Reason: runtime governance blocked before COUNCIL / OL pipeline because `AI\ai_current_plan.json` was missing in the tester agent sandbox.

OL schema verdict: not testable in this run.

## H. Strategy Universe Result

Strategy universe was not exposed by fresh OL or summary artifacts.

The tester did not reach the COUNCIL path; the diagnostic runtime summary shows:

```json
"active_mode":"HYBRID",
"final_decision":"BLOCKED",
"final_blocking_layer":"runtime_governance_block",
"final_block_reason_code":"active_plan_missing"
```

Strategy universe verdict: not confirmed in this run.

## I. fvg_tpb evaluations_seen Result

`fvg_tpb evaluations_seen` was not confirmed.

Classification:

1. no summary produced
2. tester output path for OL summary not found
3. fvg_tpb did not reach council evaluation because runtime governance blocked before the COUNCIL path

This is not evidence that `fvg_tpb` is absent from source registration. It is evidence that this tester run did not reach the runtime layer required to evaluate it.

## J. Whether Full Phase0 Can Be Retried

Yes, full Phase0 can be retried after the tester agent environment is provisioned with the required active plan/support files through an approved tester setup path.

Minimum condition before retry:

- `AI\ai_current_plan.json` must be available inside the Strategy Tester agent sandbox, or the tester must be configured so the EA can resolve the active plan in tester mode.

Do not manually rewrite terminal runtime JSON/JSONL history to force this.

## K. If Blocked, Exact Cause and Next Operator Step

Exact cause:

`active_plan_missing` inside the tester agent sandbox.

The test did not fail from symbol mismatch or missing XAUUSD history. XAUUSD M5 history was available enough for the tester to generate:

```text
5508 ticks, 276 bars generated
```

Next operator step:

Prepare an approved tester-only environment provisioning method for the active plan/support files, then rerun the same two-day XAUUSD M5 tester smoke. The rerun should only be accepted if `decision_engine_mode=COUNCIL`, `ai_opportunity_ledger.jsonl` or `ai_opportunity_summary.json` is freshly produced, and `active_strategies_count=18` / `fvg_tpb` evaluation can be observed.

## L. Final Decision

`TWO_DAY_SMOKE_COMPLETED_FVG_TPB_NOT_CONFIRMED`
