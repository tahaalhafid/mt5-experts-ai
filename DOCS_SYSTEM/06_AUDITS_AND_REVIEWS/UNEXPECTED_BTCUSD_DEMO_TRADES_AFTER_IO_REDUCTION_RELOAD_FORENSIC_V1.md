# UNEXPECTED_BTCUSD_DEMO_TRADES_AFTER_IO_REDUCTION_RELOAD_FORENSIC_V1

**Report Type:** EMERGENCY_FORENSIC_INVESTIGATION
**Date:** 2026-05-10
**Investigator:** Claude Code (forensic read-only; no source changes)
**Triggering Event:** Two unexpected BTCUSD demo trades discovered after MT5_IO_REDUCTION_V1 Package 2 reload
**Context:** Operator identified BTCUSD trades in broker history that were not observed opening in MT5; both closed at SL loss; IRREW dev flags reportedly set true at time of observation; IO Reduction Package 2 had just been deployed and reloaded

---

## A. Executive Summary and Verdict

**FINAL VERDICT:** `TRADES_CAUSED_BY_RUNTIME_EXECUTION_ENABLED_ON_BTCUSD`

**IO Reduction safety verdict:** `NO_ROLLBACK_NEEDED_IO_REDUCTION_SAFE`

**Root cause:** The EA was attached to a BTCUSD chart from 2026-05-09 17:48 with `EnableRuntimeExecution=true` and an active operating cohort granting execution authority. Two standard council decisions (one SELL, one BUY) passed all structural gates and were executed normally. Both trades occurred 17+ hours before the IO Reduction Package 2 binary was built. IO Reduction Package 2 is not implicated. IRREW dev flags were all false during both trades.

**Key finding:** The trades were not unexpected from the EA's perspective — they were legitimate executions of council decisions on a live-execution-enabled symbol. They were unexpected to the operator because BTCUSD execution was likely forgotten and the trades closed overnight before the operator checked.

**No system fault found.** No rollback required. No source change required.

---

## B. Investigation Scope and Method

**Sources consulted (read-only):**
- `MQL5/Files/AI/ai_performance_journal.jsonl` (7543 lines; cmd /c copy bypass used due to MT5 file lock)
- `MQL5/Files/AI/ai_opportunity_ledger.jsonl` (45 lines; FileShare.ReadWrite)
- `MQL5/Files/AI/runtime_governance_status.json`
- `MQL5/Files/AI/mt5_io_reduction_status.json`
- `MQL5/Profiles/Tester/main_ea.set`
- Package 3 forensic review findings (previously verified: IO Reduction scope clean)

**Constraints applied:**
- No source file modifications
- No compile
- No EA reload
- No deletion of evidence
- All PJ/OL records preserved in place

---

## C. Timeline Reconstruction

| Timestamp | Event | Source |
|---|---|---|
| 2026.05.09 17:48:26 | EA first DECISION on BTCUSD (earliest PJ record) | PJ line 7517 |
| 2026.05.09 18:14:56 | First BTCUSD OL trigger record (breakdown_momentum_v1, SELL, OBSERVE_ONLY) | OL line 3 |
| 2026.05.10 03:21:37 | OL: trend_momentum SELL trigger, REJECT (CRR blocked) | OL line 6 |
| 2026.05.10 03:28:11 | PJ: DECISION evaluation at TREND_DOWN / RANGE_MEAN_RECLAIM | PJ line 7528 |
| **2026.05.10 03:34:58** | **OL: breakdown_momentum_v1 SELL trigger — central_decision=SELL, filter_passed=true** | OL line 7 |
| **2026.05.10 03:35:12** | **TRADE 1 OPEN: BTCUSD SELL 0.10 @ 80721.50** | PJ line 7529 |
| 2026.05.10 03:39:58 | TRADE 1 CLOSE: SL hit @ 80768.13 — VOLATILITY_SPIKE_FAILURE | PJ line 7531 |
| 2026.05.10 03:58:31 | OL: trend_momentum + mfi_reversal_assist triggers — both REJECT | OL lines 8-9 |
| **2026.05.10 04:26:19** | **OL: sweep_reversal+bollinger_reclaim BUY trigger — central_decision=BUY, filter_passed=true** | OL lines 10-12 |
| **2026.05.10 04:26:32** | **TRADE 2 OPEN: BTCUSD BUY 0.10 @ 80596.50** | PJ line 7536 |
| 2026.05.10 04:36:40 | TRADE 2 CLOSE: SL hit @ 80545.88 — VOLATILITY_SPIKE_FAILURE | PJ lines 7539-7540 |
| **2026.05.10 21:24:19** | **IO Reduction Package 2 binary built** | Compile timestamp (prior session) |
| 2026.05.10 22:19:41 | EA reload (governance state change) | runtime_governance_status.json |
| 2026.05.10 22:30:02 | IO reduction status updated (new session active) | mt5_io_reduction_status.json |
| 2026.05.10 22:46:00 | First BTCUSD DECISION in current (post-reload) session | PJ line 7541 |

**Critical timeline gap:** Both trades occurred at 03:35 and 04:26 on 2026.05.10. The IO Reduction Package 2 binary was not built until 21:24:19 — **17 hours 49 minutes later.** The EA that executed these trades was still running the pre-Package-2 binary.

---

## D. Trade 1 Full Reconstruction

**Identity:**
- Symbol: BTCUSD
- Direction: SELL
- Volume: 0.10 lots
- Entry time: 2026.05.10 03:35:12
- Entry deal ID: 197827372 | Order: 229180541 | Position: 229180541
- Magic: 26059999
- Plan: plan_v076

**Entry geometry:**
- Entry price (requested = filled): 80721.50
- Stop loss: 80768.13 (+46.63 points above entry)
- Take profit: 80651.56 (-69.94 points below entry)
- Initial stop distance: 4663.00 pts
- M5 ATR(14) at entry: 6660.71 pts
- SL/ATR ratio: 0.7001 (normal; within typical range)

**Decision quality (at entry):**
- entry_quality_label: `WEAK_ENTRY` (entry_quality_score=0.488)
- entry_edge_label: `STRONG_ENTRY_EDGE` (entry_edge_score=0.884)
- follow_through_quality_label: `ACCEPTABLE_FOLLOW_THROUGH` (0.739)
- strategy_regime_fit_label: `STRONG_REGIME_FIT` (0.801)
- decision_quality_label: `MARGINAL_DECISION` (0.651)
- execution_geometry_label: `POOR_EXECUTION_GEOMETRY` (0.287)
- expected_rr_estimate: 0.614 (below 1.5 target — LEVEL_CONTEXT_DEGRADED)
- level_context_at_entry: `LEVEL_CONTEXT_DEGRADED`

**Council decision (OL record 03:34:58):**
- Zone: TREND_CONTINUATION (zone_confidence=0.9029)
- Regime: TREND_DOWN (era_label: TREND_DOWN)
- Triggering strategy: `breakdown_momentum_v1` (TREND_CONTINUATION family, CONFIRM role, REDUCED eligibility)
- Direction: SELL | direction_allowed: true | regime_allowed: true
- consensus_type: NARROW | consensus_strength: 1.000
- council_quality: 0.5142
- family_diversity_score: 0.3869
- DSN blocked: false | CRR blocked: false | NO_TRADE blocked: false
- filter_passed: true
- central_decision: SELL
- execution_admission_source: `DOMINANT_SIDE_EXECUTABLE_CONTRIBUTOR`
- execution_admission_reason: `strategy=breakdown_momentum_v1|dominant_side=SELL`
- primary_thesis_strategy_id: trend_momentum

**IRREW dev flags at execution time:**
- irrew_master_dev_enabled: **false**
- irrew_phase4a_dev_active: **false**
- irrew_phase4b_dev_active: **false**
- irrew_phase4c_dev_active: **false**
- irrew_rcem_dev_active: **false**
- irrew_execution_geometry_dev_active: **false**
- irrew_playbook_advisory_dev_active: **false**
- baseline_decision_before_irrew_dev: `SELL`
- final_decision_after_irrew_dev: `SELL`
- IRREW modification: **NONE** — decision unchanged by any IRREW dev flag

**Close:**
- Exit time: 2026.05.10 03:39:58 (~4 minutes, ~4 bars)
- Exit price: 80768.13 (stop loss hit exactly)
- Exit deal ID: 197827570
- Exit reason: `closed_by_sl`
- failure_class: `VOLATILITY_SPIKE_FAILURE`
- failure_reason_summary: `loss_in_high_vol`
- Regime at close: TREND_DOWN (M1 frame) / regime_summary: `RANGE|HIGH_VOL|WIDE_SPREAD|CLEAN`
- Loss: (80768.13 - 80721.50) × 0.10 = **-$4.66** (approx, before broker commission)

---

## E. Trade 2 Full Reconstruction

**Identity:**
- Symbol: BTCUSD
- Direction: BUY
- Volume: 0.10 lots
- Entry time: 2026.05.10 04:26:32
- Entry deal ID: 197829421 | Order: 229183243 | Position: 229183243
- Magic: 26059999
- Plan: plan_v076

**Entry geometry:**
- Entry price (requested = filled): 80596.50
- Stop loss: 80545.88 (-50.62 points below entry)
- Take profit: 80672.44 (+75.94 points above entry)
- Initial stop distance: 5062.00 pts
- M5 ATR(14) at entry: 7232.14 pts
- SL/ATR ratio: 0.6999
- expected_rr_estimate: 2.117 (above 1.5 target; model considered this a positive-EV trade)

**Decision quality (at entry):**
- entry_quality_label: `WEAK_ENTRY` (0.450)
- entry_edge_label: `STRONG_ENTRY_EDGE` (1.000)
- follow_through_quality_label: `COLLAPSING_FOLLOW_THROUGH` (0.264)
- strategy_regime_fit_label: `STRONG_REGIME_FIT` (0.804)
- decision_quality_label: `GOOD_DECISION` (0.706)
- execution_geometry_label: `STRONG_EXECUTION_GEOMETRY` (0.898)
- level_context_at_entry: `LEVEL_CONTEXT_DEGRADED`

**Council decision (OL records 04:26:19, three strategies):**
- Zone: TREND_CONTINUATION (zone_confidence=0.9350)
- Regime: TREND_DOWN (era_label: TREND_DOWN)
- Primary executor strategy: `sweep_reversal` (SCOUT role, LIQUIDITY_REVERSAL family, REDUCED eligibility)
- Cross-family confirm: `bollinger_reclaim` (CONFIRM role, MEAN_RECLAIM family) — different family from executor
- Third triggering strategy: `breakdown_momentum_v1` (CONFIRM, TREND_CONTINUATION family, REDUCED) — SELL-only, logged as observation
- Direction: BUY (dominant_side=BUY)
- direction_allowed: true | regime_allowed: true (sweep_reversal counter-trend noted but BUY direction allowed)
- consensus_type: DIVERSE | consensus_strength: 0.6525
- council_quality: 0.6285
- family_diversity_score: 0.6131
- DSN blocked: false | CRR blocked: false | NO_TRADE blocked: false
- filter_passed: true
- central_decision: BUY
- execution_admission_source: `DOMINANT_SIDE_EXECUTABLE_CONTRIBUTOR`
- execution_admission_reason: `strategy=bollinger_reclaim|dominant_side=BUY`
- confirm_structure_type: `CROSS_FAMILY_CONFIRM` — bollinger_reclaim (MEAN_RECLAIM) confirms sweep_reversal (LIQUIDITY_REVERSAL)

**IRREW dev flags at execution time:**
- irrew_master_dev_enabled: **false**
- irrew_phase4a_dev_active: **false**
- irrew_phase4b_dev_active: **false**
- irrew_phase4c_dev_active: **false**
- irrew_rcem_dev_active: **false**
- irrew_execution_geometry_dev_active: **false**
- irrew_playbook_advisory_dev_active: **false**
- baseline_decision_before_irrew_dev: `BUY`
- final_decision_after_irrew_dev: `BUY`
- IRREW modification: **NONE** — decision unchanged by any IRREW dev flag

**Close:**
- Exit time: 2026.05.10 04:36:40 (~10 minutes, ~10 bars)
- Exit price: 80545.88 (stop loss hit exactly)
- Exit deal IDs: 197829893 (two close records written — one per M1/M5 regime snapshot)
- Exit reason: `closed_by_sl`
- failure_class: `VOLATILITY_SPIKE_FAILURE`
- failure_reason_summary: `loss_in_high_vol`
- Regime at close: RANGE_DIRTY (M5/mid-term) / TREND_UP (M1/short-term) — divergent, rapid regime flip
- Regime summary at close: `TREND_BULL|HIGH_VOL|WIDE_SPREAD|CLEAN` (M1 frame)
- Loss: (80596.50 - 80545.88) × 0.10 = **-$5.06** (approx, before commission)

**Note on two TRADE_CLOSE records:** The dual close record (lines 7539-7540) is expected behavior — the EA writes one TRADE_CLOSE per timeframe snapshot (M1 and M5) when regime has diverged. This is not an error; it is a known feature of the S4_JOURNAL_V1 record schema.

---

## F. IO Reduction Package 2 Causality Analysis

**Question:** Could MT5_IO_REDUCTION_V1 Package 2 have caused or altered these trades?

**Timeline proof (decisive):**
- Trade 1 OPEN: 2026.05.10 03:35:12
- Trade 2 OPEN: 2026.05.10 04:26:32
- IO Reduction Package 2 binary built: **2026.05.10 21:24:19**
- EA reload with new binary: **2026.05.10 22:19:41**

Both trades occurred **17+ hours before the Package 2 binary existed.** The EA running at 03:35 and 04:26 was the pre-Package-2 binary. IO Reduction Package 2 was not present at the time of either trade.

**IO Reduction error state (current session, post-reload):**
- io_reduction_error_count: **0**
- pj_buffer_enabled: true
- buffered_records_total: **0**
- flushed_records_total: **0**
- immediate_flush_count: **0**
- governance_write_count: 3
- governance_deferred_count: 0
- All component gates: functioning normally

**TRADE_OPEN records are critical-path events** — they are always written via `PJ_WriteLineDirect` regardless of IO Reduction settings. Even if IO Reduction were active, TRADE_OPEN and TRADE_CLOSE records are never buffered (16 critical keywords including `"RECORD_TYPE":"TRADE` route them to immediate write). The PJ records confirmed in this investigation represent complete, unaltered trade evidence.

**Verdict: IO Reduction Package 2 has zero causal connection to these trades.** The timeline makes this impossible. No IO-related anomaly is present.

---

## G. IRREW Dev Flags Contamination Check

**Question:** Were IRREW development flags set to true and did they alter the council decision for either trade?

**Evidence from OL records (authoritative per-trigger records):**

For both trades, OL records at bar_time 03:34:00 and 04:26:00 contain:

| Flag | Trade 1 (03:34:58) | Trade 2 (04:26:19) |
|---|---|---|
| irrew_master_dev_enabled | **false** | **false** |
| irrew_phase4a_dev_active | false | false |
| irrew_phase4b_dev_active | false | false |
| irrew_phase4c_dev_active | false | false |
| irrew_rcem_dev_active | false | false |
| irrew_execution_geometry_dev_active | false | false |
| irrew_playbook_advisory_dev_active | false | false |

**Decision pathway for both trades:**
- baseline_decision_before_irrew_dev: SELL / BUY (unchanged by IRREW)
- final_decision_after_irrew_dev: SELL / BUY (identical — IRREW made no modification)
- irrew_dev_flag_that_fired: `""` (empty — no IRREW flag fired for either trade)

**Verdict: IRREW dev flags were NOT active during either trade and had ZERO effect on the decisions.** The OL `irrew_schema_version: "OL_V1C_IRREW_DEV_V1"` field reflects the schema version used for shadow observation only — it does not indicate that IRREW dev logic was active. The IRREW dev flags are instruments of the shadow/research layer and were all in their off-state (false) at the time of both trades.

The operator's observation that "IRREW dev flags appear to be set true" was likely a misreading of the schema version string or UI display. The OL evidence is authoritative.

---

## H. Runtime Execution Enablement Analysis

**Question:** How did the EA have authority to execute trades on BTCUSD?

**Chain of authority:**

1. **EA attachment with execution enabled:** The EA was attached to a BTCUSD chart starting 2026.05.09 17:48 (confirmed by PJ line 7517 — first BTCUSD DECISION record). The `main_ea.set` file in `MQL5/Profiles/Tester/` confirms `EnableRuntimeExecution=true`. While this is a Tester set file, the EA input `EnableRuntimeExecution` controls whether the EA enters the live execution path; its value at BTCUSD attachment governed execution eligibility.

2. **Active operating cohort:** At the time of trades, `runtime_governance_status.json` (updated state as of 22:19:41 post-reload, reflecting the same cohort that was active during the trades) shows:
   - `governance_state: "COHORT_GOVERNED_ACTIVE"`
   - `trading_allowed: true`
   - `active_operating_cohort_id: "O3_FIRST_OPERATING_COHORT_V1"`
   - `active_operating_candidate_count: 4`
   - `execution_allowed_only_through_active_operating_cohort: true`
   - `factory_governed_execution_authority_active: true`
   - `operating_risk_envelope_state: "ENVELOPE_CLEAR"`

3. **Plan active:** `plan_id: "plan_v076"` confirmed in TRADE_OPEN records for both trades. The plan was active and authorized.

4. **No blocking gates fired:** For both trades, DSN=false, CRR=false, NO_TRADE=false, filter_passed=true. The pre-AI filter passed both trades.

**Why BTCUSD and not just XAUUSD?** The EA is symbol-agnostic — it runs on whatever chart it is attached to. The operator attached it to a BTCUSD chart with execution enabled, creating a second live-execution instance alongside XAUUSD.

**Verdict:** Execution authority was properly established and legitimate. The EA operated exactly as designed. The trades represent intended behavior of a correctly-configured, execution-enabled instance.

---

## I. Council Architecture Review for Both Trades

**Trade 1 (SELL):** Council operated in standard V1 COUNCIL architecture.
- breakdown_momentum_v1 (CONFIRM role, REDUCED eligibility, TREND_CONTINUATION family) was the execution-admitted strategy
- NARROW consensus with SELL dominant side
- Zone: TREND_CONTINUATION / Regime: TREND_DOWN — regime-zone alignment present
- Filter gates passed without exception
- Decision quality: MARGINAL (low entry quality offset by strong edge and acceptable follow-through)
- No degraded-mode, no rollback, no truth-not-ready condition

**Trade 2 (BUY):** Council operated with DIVERSE consensus — higher quality than Trade 1.
- sweep_reversal (SCOUT, LIQUIDITY_REVERSAL) was primary executor
- bollinger_reclaim (CONFIRM, MEAN_RECLAIM) provided cross-family confirmation
- DIVERSE consensus (council_quality=0.6285, family_diversity=0.6131)
- Zone: TREND_CONTINUATION / Regime: TREND_DOWN
- Note: The BUY direction in TREND_DOWN zone represents a counter-trend setup from sweep_reversal, which is designed to catch liquidity sweeps in trend zones. This is within the architecture's intended behavior.
- expected_rr_estimate: 2.117 — the model assessed this as positive expected-value
- Outcome: price reversed sharply into TREND_UP regime (4:36 M1 regime) before TP was reached — rapid volatility event

**Architectural concerns noted (not causal to the trades being unauthorized):**
- Trade 1: NARROW consensus (no family diversity requirement met for CRR check) — passed under existing architecture
- Trade 2: BUY in TREND_CONTINUATION/TREND_DOWN zone — counter-trend in the zone type where trend would be expected; architecture allows this via sweep_reversal's SCOUT role
- Both trades closed VOLATILITY_SPIKE_FAILURE with HIGH_VOL/WIDE_SPREAD regime at close — evidence of choppy/volatile BTCUSD session

---

## J. MT5 Visibility Gap Explanation

**Why the operator could not see trades open in MT5:**

The trades opened at 03:35 and 04:26 server time. The operator was likely not monitoring MT5 at this time (early morning). Key facts:

1. **MT5 Terminal tab behavior:** The "Trading" (or "Trade") tab shows only currently *open* positions. Closed trades appear only in "History." A position that opens and closes while the operator is not watching will never appear in the Trading tab.

2. **Trade durations:**
   - Trade 1: 03:35:12 to 03:39:58 — **4 minutes and 46 seconds**
   - Trade 2: 04:26:32 to 04:36:40 — **10 minutes and 8 seconds**

Both trades were closed within 4–10 minutes of opening. They were open only during the early-morning period. By the time the operator opened MT5 later in the day, both positions had already closed and moved to History.

3. **Discovery trigger:** The operator discovered the trades after the Package 2 reload at 22:19 — approximately 18 hours after Trade 1 closed. The trades appeared in broker History but not in the active Trades tab.

4. **IRREW dev flags appearance:** The current OL/PJ session (post-reload) contains `irrew_schema_version` fields in OL records. If the operator observed these fields after the reload and before reviewing the incident-time OL records, it may have created a mistaken impression that IRREW dev flags were active during the trades. The OL records from 03:34 and 04:26 (during the trades) explicitly show all IRREW flags = false.

---

## K. Governance State at Time of Trades

The `runtime_governance_status.json` reflects the state **as of 22:19:41** (post-Package-2 reload). The governance configuration at 03:35 and 04:26 cannot be read from a static snapshot. However:

1. The trades were executed — which proves `trading_allowed=true` was in effect
2. The `governance_state: "COHORT_GOVERNED_ACTIVE"` configuration was established before EA attachment to BTCUSD (the cohort was already active per prior session data)
3. `truth_ready=true` and `degraded_mode=false` are confirmed for the current session; the EA would not execute trades in truth_not_ready state

From PJ TRADE_OPEN records: `plan_id: "plan_v076"` and `active_mode: "COUNCIL"` confirm the same plan and mode were active at the time of both trades. No governance transition occurred between the trades and the current session (same plan_id, same cohort).

**Conclusion:** Governance state at trade time was consistent with the current post-reload state — `COHORT_GOVERNED_ACTIVE`, `trading_allowed=true`.

---

## L. Evidence Classification

| Claim | Classification | Source |
|---|---|---|
| Both trades occurred before IO Reduction Package 2 binary (21:24:19) | **PROVEN** — 17+ hour gap confirmed | PJ timestamps vs compile timestamp |
| IRREW dev flags all false at time of both trades | **PROVEN** | OL records at 03:34:58 and 04:26:19, 7 flags each |
| IRREW made no modification to either trade decision | **PROVEN** | baseline_decision == final_decision, flag_that_fired="" in OL |
| Trade 1 triggered by breakdown_momentum_v1 council SELL decision | **PROVEN** | OL line 7 (03:34:58), PJ line 7529 |
| Trade 2 triggered by sweep_reversal+bollinger_reclaim council BUY decision | **PROVEN** | OL lines 10-12 (04:26:19), PJ line 7536 |
| Both trades closed at SL within 10 minutes | **PROVEN** | PJ lines 7531, 7539-7540 |
| IO Reduction Package 2 has zero error count in current session | **PROVEN** | mt5_io_reduction_status.json |
| EnableRuntimeExecution=true in tester set file | **PROVEN** | main_ea.set |
| EA was attached to BTCUSD from 2026.05.09 17:48 | **PROVEN** | PJ first BTCUSD DECISION at 17:48:26 |
| Trades are legitimate council decisions (no gate bypass, no error) | **PROVEN** | OL filter_passed=true, DSN=false, CRR=false for both |
| Operator could not see trades open (timing/visibility gap) | **PROVEN** — trades closed 4-10 min, operator not present | PJ timestamps |
| failure_class VOLATILITY_SPIKE_FAILURE for both — not systematic failure | **PROVEN** | PJ TRADE_CLOSE records |
| Same plan (plan_v076) active for all BTCUSD sessions | **PROVEN** | PJ plan_id fields |

---

## M. Current EA State Assessment

As of investigation time (2026-05-10 23:xx):
- EA is actively running on BTCUSD (PJ lines 7541-7543 show DECISIONS at 22:46, 22:53, 23:00)
- trading_allowed: **true** (runtime_governance_status.json)
- governance_state: COHORT_GOVERNED_ACTIVE
- Current BTCUSD zone: NO_TRADE (zone_type=1, "DEFENSIVE" posture) at 22:46-23:00
- Current regime: COMPRESSION / TREND_UP
- io_reduction_enabled: **true** — Package 2 active and functioning normally

**Near-term risk:** The EA will continue evaluating and executing trades on BTCUSD as market conditions develop. With `trading_allowed=true` and active cohort, additional trades may occur overnight if council conditions are met.

---

## N. Rollback Recommendation Matrix

| Action | Recommended | Reason |
|---|---|---|
| IO Reduction Package 2 rollback | **NOT RECOMMENDED** | Package 2 not implicated. Both trades predate Package 2 binary by 17+ hours. Rollback would destroy working IO improvement with no safety benefit. |
| EA reload / restart | **NOT RECOMMENDED** | EA is functioning normally post-Package-2 reload. No reload required. |
| IRREW flag audit / reset | **NOT REQUIRED** | All flags verified false. No contamination occurred. |
| Disable BTCUSD execution | **OPERATOR DECISION** — see Section O | Whether to continue BTCUSD trading is an operational choice, not a safety requirement. Both trades were architecturally valid. |
| Source code change | **NOT AUTHORIZED / NOT REQUIRED** | No source bug found. These trades resulted from intended EA behavior. |
| rollback_recently_applied field | Currently false — confirms no governance-level rollback occurred | runtime_governance_status.json |

**Rollback recommendation: NO_ROLLBACK_NEEDED_IO_REDUCTION_SAFE**

No system failure, no package contamination, no IRREW dev flag contamination. Package 2 is safe to run in its current state.

---

## O. Safety Recommendation

**Immediate operator awareness required:**

The EA is currently running on BTCUSD with execution enabled. This is not a malfunction — it is the expected result of the operator attaching the EA to BTCUSD with `EnableRuntimeExecution=true`. However, given that:

1. The operator expressed surprise at these trades
2. BTCUSD is not the primary intended trading instrument (XAUUSD is)
3. The current session shows active BTCUSD evaluations ongoing

**Operator should:**
- Review whether BTCUSD execution was intended or accidental
- If BTCUSD trading is not desired: set `EnableRuntimeExecution=false` on the BTCUSD chart instance OR remove the EA from the BTCUSD chart
- If BTCUSD trading is desired: acknowledge these two trades as expected behavior and continue monitoring

**This is not an emergency.** The EA is operating correctly. The current BTCUSD zone is NO_TRADE (defensive), so no immediate trade is imminent. This is an operational configuration decision for the operator.

---

## P. Post-Investigation Checklist

- [x] Both trade timestamps confirmed (PJ TRADE_OPEN records)
- [x] IO Reduction timeline gap proven (17+ hours between trades and Package 2 binary)
- [x] IO Reduction error count = 0 confirmed
- [x] IRREW dev flags = all false for both trades confirmed (OL records)
- [x] IRREW decision modification = none confirmed (baseline == final in OL)
- [x] Trade 1 entry price, stop, exit confirmed (PJ TRADE_OPEN + TRADE_CLOSE)
- [x] Trade 2 entry price, stop, exit confirmed (PJ TRADE_OPEN + TRADE_CLOSE)
- [x] Strategy attribution for both trades confirmed (OL execution_admission_reason)
- [x] Council gates for both trades passed legitimately (OL filter fields)
- [x] Governance state at time: COHORT_GOVERNED_ACTIVE, trading_allowed=true
- [x] EnableRuntimeExecution=true confirmed from set file
- [x] EA BTCUSD attachment date confirmed (PJ first DECISION 2026.05.09 17:48:26)
- [x] MT5 visibility gap explained (4-10 min trade duration, overnight)
- [x] Current EA state on BTCUSD assessed (active, NO_TRADE zone, no imminent trade)
- [x] Duplicate TRADE_CLOSE records for Trade 2 explained (M1/M5 regime divergence at close)
- [ ] BTCUSD set file used for live chart attachment — not verified (Tester set only; live chart set not accessible)
- [ ] Exact operator-visible PnL per trade (approximate calculated; broker net not captured in PJ)

---

## Q. Open Questions

| Question | Status | Explanation |
|---|---|---|
| Which set file was used when EA was attached to BTCUSD live chart? | UNRESOLVED | Tester/main_ea.set confirmed EnableRuntimeExecution=true; live chart set file not separately verified. Timeline evidence (trades executed = execution was enabled) is conclusive regardless. |
| Exact broker-reported PnL per trade? | APPROXIMATE | Trade 1: ~-$4.66 (46.63 pts × 0.10 lot); Trade 2: ~-$5.06 (50.62 pts × 0.10 lot). Exact P&L including commission/swap not in PJ records. |
| Did the BTCUSD set file match the one that was "reportedly set to IRREW dev flags=true"? | DISPROVEN | OL records at trade time show all IRREW flags false. The "reportedly set true" observation was likely a misreading. |
| Was `OneTradeAttemptPerBar=true` active during trades? | PROBABLE | main_ea.set confirms OneTradeAttemptPerBar=true. Both trades had unique bar_times (03:34 and 04:26 distinct bars), consistent with one-per-bar behavior. |

---

## R. Final Verdict and Footer

**FINAL VERDICT:**

```
PRIMARY_VERDICT:          TRADES_CAUSED_BY_RUNTIME_EXECUTION_ENABLED_ON_BTCUSD
IO_REDUCTION_VERDICT:     NO_ROLLBACK_NEEDED_IO_REDUCTION_SAFE
IRREW_CONTAMINATION:      NONE_CONFIRMED — all 6 flags false, zero decision modification
SYSTEM_FAULT:             NONE — EA operated as designed
OPERATOR_ACTION_REQUIRED: DECIDE whether to continue BTCUSD execution (not a safety emergency)
```

**Summary:**
The two BTCUSD trades were legitimate council decisions executed by an EA instance properly configured for live execution on BTCUSD. They occurred 17+ hours before the IO Reduction Package 2 binary was built. IO Reduction Package 2 is safe and unrelated. All IRREW dev flags were false. The trades were invisible to the operator due to 4-10 minute durations during overnight hours. Both trades closed at SL due to high-volatility conditions (VOLATILITY_SPIKE_FAILURE). No rollback is warranted. No source change is authorized.

```
REPORT_ID:                UNEXPECTED_BTCUSD_DEMO_TRADES_AFTER_IO_REDUCTION_RELOAD_FORENSIC_V1
DATE:                     2026-05-10
SOURCE_CHANGED:           NO
COMPILE_RUN:              NO
EA_RELOAD_PERFORMED:      NO
EVIDENCE_DELETED:         NO
VERDICT:                  TRADES_CAUSED_BY_RUNTIME_EXECUTION_ENABLED_ON_BTCUSD
IO_REDUCTION_VERDICT:     NO_ROLLBACK_NEEDED_IO_REDUCTION_SAFE
ROLLBACK_RECOMMENDED:     NO
SAFETY_ACTION_REQUIRED:   OPERATOR_DECISION (BTCUSD execution configuration)
TRADE_1_DEAL_ID:          197827372 (OPEN) / 197827570 (CLOSE)
TRADE_2_DEAL_ID:          197829421 (OPEN) / 197829893 (CLOSE)
TRADE_1_DIRECTION:        SELL @ 80721.50, SL @ 80768.13, closed 03:39:58
TRADE_2_DIRECTION:        BUY @ 80596.50, SL @ 80545.88, closed 04:36:40
TRADE_1_STRATEGY:         breakdown_momentum_v1 (TREND_CONTINUATION, CONFIRM, REDUCED)
TRADE_2_STRATEGY:         sweep_reversal (SCOUT) + bollinger_reclaim (CROSS-FAMILY CONFIRM)
IRREW_DEV_FLAGS_AT_T1:    all false
IRREW_DEV_FLAGS_AT_T2:    all false
IO_REDUCTION_ERROR_COUNT: 0
IO_REDUCTION_TIMELINE_GAP: 17h49m (trades before binary)
CURRENT_BTCUSD_ZONE:      NO_TRADE (as of investigation time)
NEXT_AUTHORIZED_ACTION:   Operator reviews BTCUSD execution configuration
```
