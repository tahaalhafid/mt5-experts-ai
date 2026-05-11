# FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_REPORT

**Status:** IMPLEMENTATION_COMPLETE — COMPILE_VERIFIED — RUNTIME_VALIDATION_PENDING
**Date:** 2026-05-09
**Binary timestamp:** 2026-05-09 05:29:15 local
**Compile result:** 0 errors, 0 warnings

---

## A. Authorization Trail

| Field | Value |
|---|---|
| Package ID | FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1 |
| Operator authorization | EXPLICIT — issued in session 2026-05-09 |
| factory_admission_lock | LIFTED FOR FVG_TPB ONLY — no general factory admission |
| Design lane | IMBALANCE_FILL_REVERSAL (IFR) — adopted explicitly |
| INEC certification basis | INEC_LAB_V1 run_20260509_fvg_tpb_xauusd_v1 |
| INEC verdict | ALPHA_TRIGGER_PACKET FORMALLY_ACCEPTABLE |
| Scope | FVG_TPB admission only — no other external strategies admitted |
| Factory admission lock status after | REMAINS ACTIVE for all strategies except fvg_tpb |
| NO_CODE_FACTORY_LOCK_FOUND | No explicit code variable for factory_admission_lock found in source. Governance condition is operator authorization only. |

---

## B. Package Summary

This package implements `fvg_tpb` (Fair Value Gap — Trend Pullback) as the 18th council strategy and sole anchor of the IMBALANCE_FILL_REVERSAL (IFR) playbook lane. The implementation is write-only instrumentation except for the strategy vote contribution: `fvg_tpb` participates in council aggregation as a SCOUT-role strategy with vote_weight=0.65. All V1C attribution fields (fvg_/ifr_) are written to the opportunity ledger only — they have zero decision authority over any gate, threshold, or filter.

**INEC certification metrics (basis for admission):**
- N = 2,442 triggers (Variant A, all M1 bars, 100,466 bar sample)
- WR = 43.41%, E[R] = +0.0852R (RR=1.50, ATR14(M1)×1.20 stop)
- Best subsets: BUY_TREND_DOWN WR=47.76%; SELL_RANGE_NEUTRAL WR=47.06%
- Hostile subset suppressed: SELL_TREND_DOWN WR=38.37%, E[R]=−0.041R
- Trigger density: 2.43% of M1 bars — ADEQUATE_DENSITY (no starvation risk)
- EOC classification: COMPLIANT (stages 1–7, hypothetical basis confirmed)

---

## C. Files Modified

| File | Change type | Change summary |
|---|---|---|
| council_mode_types.mqh | MODIFIED | COUNCIL_MAX_STRATEGIES 17→18; SFVGZone struct; SFVGTriggerAttribution struct |
| council_strategies.mqh | MODIFIED | FVG_MAX_ACTIVE_ZONES, FVG_EXPIRY_MINS, FVG_ATR_THRESH, FVG_VOTE_WEIGHT constants; g_fvg_attribution global; FVG_ResetAttribution(); FVG_SubsetClassification(); BuildCouncilStrategy_FVG_TPB(); RunCouncilStrategySet s18 parameter + call |
| council_mode_runtime.mqh | MODIFIED | s18 declaration + reports[17] assignment; OL_PacketRegistryStatusForStrategy fvg_tpb branch; OL_PrimaryPlaybookForStrategy fvg_tpb branch; g_ol_ifr_state_seen_count global; OL_ResetPlaybookSummaryCounters ifr reset; OL_UpdatePlaybookSummaryCounters ifr branch; OL_ComputePlaybookShadowStates ifr parameter + IFR shadow logic; OL_SelectPlaybookStateForStrategy ifr parameter + branch; Stage 18.5 ol_ifr declaration + call updates; WriteOpportunityLedgerRecord fvg_ conditional fields; SaveOpportunitySummary ifr_state_seen_count field |

**Files NOT modified (forbidden or unchanged):**
- main_ea.mq5 — NOT modified
- council_aggregator.mqh — NOT modified
- council_pre_ai_filter.mqh — NOT modified
- council_ai_governor.mqh — NOT modified
- core_trade_engine.mqh — NOT modified
- strategy_runtime.mqh — NOT modified
- All runtime JSON/JSONL files — NOT modified
- All existing design/spec/registry Markdown files — NOT modified

---

## D. council_mode_types.mqh Changes

### D1. COUNCIL_MAX_STRATEGIES

```mql5
// Before:
#define COUNCIL_MAX_STRATEGIES 17
// After:
#define COUNCIL_MAX_STRATEGIES 18
```

### D2. SFVGZone Struct

New struct for tracking active FVG zone state across M1 bars (static arrays inside BuildCouncilStrategy_FVG_TPB):

```mql5
struct SFVGZone
{
   datetime  activation_time;   // iTime(M5,1) + 5*60 (after bar[j] close)
   datetime  expiry_time;       // activation_time + FVG_EXPIRY_MINS*60
   double    fvg_lo;            // lower bound of gap
   double    fvg_hi;            // upper bound of gap
   double    gap_size_pts;      // fvg_hi - fvg_lo in points (raw)
   double    atr_m5;            // ATR14(M5) at detection time
   int       direction;         // 1=BUY, -1=SELL
   string    regime_context;    // era_label_v1 at detection time
   bool      is_active;         // true after activation_time
   bool      is_expired;        // true after expiry_time
   bool      is_invalidated;    // true on M1 close through far side
   bool      has_triggered;     // true once M1 fill entry fired from this zone
   int       age_bars;          // M1 bars elapsed since activation
};
```

### D3. SFVGTriggerAttribution Struct

New struct for V1C ledger attribution (global g_fvg_attribution; write-only from BuildCouncilStrategy_FVG_TPB; read-only in WriteOpportunityLedgerRecord):

```mql5
struct SFVGTriggerAttribution
{
   bool   has_data;
   string fvg_direction;
   double fvg_gap_low;
   double fvg_gap_high;
   string fvg_regime_context;
   string fvg_subset_classification;
   bool   fvg_hostile_gate_fired;
   double fvg_size_atr;
   int    fvg_age_bars;
   int    fvg_active_zone_count;
   double fvg_mitigation_pct;
};
```

---

## E. council_strategies.mqh Changes

### E1. Constants

```mql5
#define FVG_MAX_ACTIVE_ZONES  20    // max simultaneous tracked FVG zones
#define FVG_EXPIRY_MINS       240   // certified 4-hour expiry window
#define FVG_ATR_THRESH        0.05  // gap >= ATR14(M5)*0.05 size filter
#define FVG_VOTE_WEIGHT       0.65  // initial conservative SCOUT weight
```

### E2. Global Attribution

```mql5
SFVGTriggerAttribution g_fvg_attribution;
// Populated by BuildCouncilStrategy_FVG_TPB each bar when trigger fires.
// Read by WriteOpportunityLedgerRecord for fvg_tpb records only.
// Zero decision authority.
```

### E3. FVG_ResetAttribution

Resets g_fvg_attribution to empty state at start of each BuildCouncilStrategy_FVG_TPB call.

### E4. FVG_SubsetClassification

Returns canonical subset label from (direction, era_label_v1):
- BUY + TREND_DOWN → "BUY_TREND_DOWN" (EDGE_SUPPORTED, WR=47.76%)
- SELL + RANGE_NEUTRAL → "SELL_RANGE_NEUTRAL" (EDGE_SUPPORTED, WR=47.06%)
- SELL + TREND_DOWN → "SELL_TREND_DOWN" (hostile gate — never reaches this; suppressed before)
- All others → "BASELINE"

### E5. BuildCouncilStrategy_FVG_TPB — Algorithm

**Static state (session-persistent across M1 bar calls):**
```mql5
static SFVGZone sZones[FVG_MAX_ACTIVE_ZONES];
static int      sZoneCount;
static datetime sLastM5Bar;
```

**Step 1 — Identity and eligibility:**
- strategy_id = "fvg_tpb", strategy_family = "IMBALANCE_FILL_REVERSAL"
- role = COUNCIL_ROLE_SCOUT, vote_weight = FVG_VOTE_WEIGHT (0.65)
- direction_bias = "BOTH"
- Zone override: OBSERVE_ONLY in COUNCIL_ZONE_TREND_CONTINUATION (TC hostility gate at zone level)
- Standard SCOUT eligibility applied via CouncilApplyStrategyEligibility

**Step 2 — New M5 bar FVG detection (runs once per new M5 bar):**
- Detects when iTime(M5, 1) != sLastM5Bar (new closed M5 bar)
- Reads M5 OHLCV from shifts 1, 2, 3 (all confirmed closed bars — no bar[0] lookahead)
- Bullish FVG: iLow(M5,1) > iHigh(M5,3) → fvg_lo=iHigh(M5,3), fvg_hi=iLow(M5,1), dir=1
- Bearish FVG: iHigh(M5,1) < iLow(M5,3) → fvg_lo=iHigh(M5,1), fvg_hi=iLow(M5,3), dir=-1
- Size filter: (fvg_hi - fvg_lo) / _Point >= atrM5Pts * FVG_ATR_THRESH
- If passes: adds zone to sZones[] array (FIFO eviction when array full)
- activation_time = iTime(M5,1) + 5*60 (deterministic: after M5 bar[j] closes)
- expiry_time = activation_time + FVG_EXPIRY_MINS * 60

**Step 3 — Zone state update (every M1 bar):**
For each zone in sZones[]:
- Activate: is_active = (TimeCurrent() >= activation_time)
- Expire: is_expired = (TimeCurrent() > expiry_time) if already active
- Invalidate: BUY zone if m1Close1 < fvg_lo; SELL zone if m1Close1 > fvg_hi
- Increment age_bars for active, non-expired, non-invalidated zones
- Compact: removes expired/invalidated zones from active array

**Step 4 — FIFO M1 entry trigger check:**
- Iterates active, non-expired, non-invalidated, non-triggered zones
- Entry condition: m1Close1 (shift=1, completed M1 bar) within [fvg_lo, fvg_hi]
- FIFO: first matching zone wins (oldest active zone by activation_time)
- m1Close1 is `iClose(_Symbol, PERIOD_M1, 1)` — completed bar only

**Step 5 — Hostile gate (SELL + TREND_DOWN):**
- If triggered zone direction == -1 AND era_label_v1 contains "TREND_DOWN":
  - Sets g_fvg_attribution.fvg_hostile_gate_fired = true
  - Sets trigger_present=true (trigger WAS present)
  - Sets decision=WAIT, vote_weight=0.0
  - Returns without contributing to council consensus (hostile suppression)

**Step 6 — Valid trigger — report construction:**
- Sets trigger_present=true, decision=BUY|SELL
- Marks sZones[triggeredIdx].has_triggered = true (written back to array)
- trigger_quality = CouncilClamp01(0.60 + min(atrRatio * 0.10, 0.25))
- confirmation_quality = 0.55 (FVG fill is self-confirming)
- environment_fit = CouncilEnvironmentFitBuy|Sell(env)
- score_final via CouncilApplyZoneAdjustedScore
- Populates g_fvg_attribution for V1C ledger

### E6. RunCouncilStrategySet — s18 Addition

Added `CouncilStrategyReport &s18` as 19th parameter.
Added `BuildCouncilStrategy_FVG_TPB(env, s18);` as 18th strategy call.

---

## F. council_mode_runtime.mqh Changes

### F1. s18 Declaration + Array Assignment

```mql5
CouncilStrategyReport s18;
// ...
RunCouncilStrategySet(env, s1, s2, ..., s17, s18);
// ...
reports[17] = s18;
```

### F2. OL_PacketRegistryStatusForStrategy

Added branch:
```mql5
if(sid == "fvg_tpb") return "ALPHA_TRIGGER_ADMITTED_IFR";
```

### F3. OL_PrimaryPlaybookForStrategy

Added branch:
```mql5
if(sid == "fvg_tpb") return "IMBALANCE_FILL_REVERSAL";
```

### F4. IFR Summary Counter

Added global:
```mql5
int g_ol_ifr_state_seen_count = 0;
```
Wired into OL_ResetPlaybookSummaryCounters and OL_UpdatePlaybookSummaryCounters.

### F5. OL_ComputePlaybookShadowStates — IFR Parameter + Logic

New parameter: `OL_PlaybookShadowState &ifr`

IFR shadow logic:
```mql5
OL_InitPlaybookShadowState(ifr, "IMBALANCE_FILL_REVERSAL");
bool ifr_anchor = OL_StrategyIdTriggeredOrVoted(reports, reportCount, "fvg_tpb");
ifr.primary_packet_id = ifr_anchor ? "fvg_tpb" : "";
if(!ifr_anchor)
{
   ifr.playbook_state = "PLAYBOOK_NOT_PRESENT";
   ifr.missing_links_json = OL_LinkJson("IFR_ALPHA_ANCHOR","IFR_FILL_CONFIRM","","","");
   ifr.state_reason = "NO_IFR_ANCHOR_EVIDENCE";
}
else
{
   ifr.playbook_state = "PLAYBOOK_FORMING";
   ifr.completed_links_json = OL_LinkJson("IFR_ALPHA_ANCHOR","","","","");
   ifr.missing_links_json = OL_LinkJson("","IFR_FILL_CONFIRM","PRE_DECISION_EVENT_ORDER",
                                          "FORMAL_CONFIRMATION_PACKET","");
   ifr.required_evidence_present = true;
   ifr.state_reason = "IFR_ALPHA_ONLY_FORMING";
}
OL_ApplyPlaybookTimingFlags(ifr, eot);
```

**IFR playbook state rationale:**
- VALID is permanently withheld: no pre-decision event-order proof exists for FVG_TPB; no CONFIRMATION_PACKET is implemented. FORMING is the maximum achievable state.
- PLAYBOOK_NOT_PRESENT when fvg_tpb did not trigger or vote on this bar.

### F6. OL_SelectPlaybookStateForStrategy — IFR Branch

Added `const OL_PlaybookShadowState &ifr` parameter and branch:
```mql5
if(mapped == ifr.playbook_id)
{
   OL_CopyPlaybookShadowState(ifr, out_state);
   return;
}
```

### F7. Stage 18.5 — ol_ifr Declaration + Call Updates

```mql5
OL_PlaybookShadowState ol_ifr;
OL_ComputePlaybookShadowStates(..., ol_ifr);
// ...
OL_SelectPlaybookStateForStrategy(..., ol_ifr, ol_pss);
```

### F8. WriteOpportunityLedgerRecord — fvg_ Attribution Fields

Conditional block written after `attribution_note`, only for fvg_tpb records with populated attribution:

```mql5
if(report.strategy_id == "fvg_tpb" && g_fvg_attribution.has_data)
{
   j += ",\"fvg_direction\":\"...\"";
   j += ",\"fvg_gap_low\":...";
   j += ",\"fvg_gap_high\":...";
   j += ",\"fvg_regime_context\":\"...\"";
   j += ",\"fvg_subset_classification\":\"...\"";
   j += ",\"fvg_hostile_gate_fired\":true|false";
   j += ",\"fvg_size_atr\":...";
   j += ",\"fvg_age_bars\":...";
   j += ",\"fvg_active_zone_count\":...";
   j += ",\"fvg_mitigation_pct\":...";
   j += ",\"ifr_playbook_state\":\"PLAYBOOK_FORMING|PLAYBOOK_NOT_PRESENT\"";
}
```

All 11 fvg_/ifr_ fields are write-only attribution. No decision path reads these fields.

### F9. SaveOpportunitySummary — ifr_state_seen_count

```mql5
j += "\"ifr_state_seen_count\":" + IntegerToString(g_ol_ifr_state_seen_count) + ",";
```

---

## G. IFR Playbook Architecture

| Field | Value |
|---|---|
| Playbook ID | IMBALANCE_FILL_REVERSAL |
| Playbook abbreviation | IFR |
| Anchor strategy | fvg_tpb (sole anchor) |
| FORMING condition | fvg_tpb triggered or voted on this bar |
| NOT_PRESENT condition | fvg_tpb did not trigger or vote |
| VALID | PERMANENTLY WITHHELD |
| VALID withheld reason | No pre-decision event-order proof; no CONFIRMATION_PACKET |
| Missing links (FORMING) | IFR_FILL_CONFIRM, PRE_DECISION_EVENT_ORDER, FORMAL_CONFIRMATION_PACKET |
| Completed links (FORMING) | IFR_ALPHA_ANCHOR |
| Attribution authority | NONE — write-only ledger instrumentation |

---

## H. Zone Routing and Eligibility

| Zone | Eligibility | Rationale |
|---|---|---|
| COUNCIL_ZONE_REVERSAL | ACTIVE | FVG fill at price reversal zones — primary habitat |
| COUNCIL_ZONE_RANGE_MIDLINE_RECLAIM | ACTIVE | FVG fill on reclaim setups |
| COUNCIL_ZONE_TREND_CONTINUATION | OBSERVE_ONLY | Hostile zone for FVG as reversal signal; TC zone suppressed at eligibility level |
| COUNCIL_ZONE_BREAKOUT_EXPANSION | REDUCED | Standard SCOUT routing |
| Other zones | Standard SCOUT routing | Per CouncilApplyStrategyEligibility |

---

## I. Hostile Gate Design

**Gate:** SELL + TREND_DOWN
**Basis:** INEC certification — SELL_TREND_DOWN WR=38.37%, E[R]=−0.041R
**Implementation:** Inside BuildCouncilStrategy_FVG_TPB only — not in pre_ai_filter, not in aggregator
**Behavior when fired:**
- trigger_present = true (trigger WAS detected — recorded for ledger)
- decision = COUNCIL_DECISION_WAIT
- vote_weight = 0.0
- fvg_hostile_gate_fired = true in attribution
- strategy contributes zero to council consensus

**What is NOT suppressed by hostile gate:**
- BUY trades in any regime
- SELL trades in RANGE_NEUTRAL regime (WR=47.06% — EDGE_SUPPORTED)
- SELL trades in TREND_UP, BREAKOUT, or other regimes (baseline WR=43.41%)

---

## J. EOC Compliance Verification

| Stage | Assessment | Detail |
|---|---|---|
| S1: Bar timestamps | COMPLIANT | M1 timestamps used directly; M5 bars identified by timestamp comparison |
| S2: M5 regime proxy | COMPLIANT | M5 ATR14 computed from iATR(M5,14); regime from env.era_label_v1 (pre-decision) |
| S3: FVG detection | COMPLIANT | Shifts 1, 2, 3 = all confirmed closed M5 bars. bar[0] never read. |
| S4: FVG activation | COMPLIANT | activation_time = iTime(M5,1) + 5*60. Zone not active until after M5 bar[j] closes. |
| S5: M1 entry check | COMPLIANT | Entry against iClose(M1,1) = completed M1 bar. Gap boundaries fixed at activation time. |
| S6: Expiry/invalidation | COMPLIANT | Expiry time-based; invalidation on completed M1 close vs fixed boundary. |
| S7: Aggregation | COMPLIANT | Standard council aggregation path; no novel aggregation required. |
| S8: Opportunity ledger | NOT_AVAILABLE | Phase 2 pending (already partially live; fvg_tpb writes when trigger_present=true). |

**No lookahead bias possible from this implementation.** All detection uses completed bar OHLCV only.

---

## K. Cold-Start Limitation

**Classification:** KNOWN_LIMITATION — DOCUMENTED
**Description:** Static zone arrays inside BuildCouncilStrategy_FVG_TPB are session-local. On EA reload, all tracked FVG zones are lost. The strategy starts with an empty zone set and repopulates within the 4-hour expiry window as new M5 bars form.

**Why not fixed:** Hooking into OnInit() for zone replay requires modifying main_ea.mq5, which is forbidden in this package scope.

**Impact:** Approximately 0–4 hours of reduced FVG zone coverage after each EA reload. Not a runtime safety risk — simply means fewer zones tracked immediately after reload.

**Runtime authority:** No impact on existing strategies, gates, or decisions.

---

## L. Factory Admission Lock Status

**Code search result:** NO_CODE_FACTORY_LOCK_FOUND
No explicit `factory_admission_lock` variable, flag, or constant was found in any source file.
The governance condition (operator authorization) is satisfied by the explicit authorization issued for this package.
The lock remains in effect for all other external strategies by operator standing instruction — no code change required or made.

---

## M. Compile Verification

| Field | Value |
|---|---|
| Compile command | MetaEditor64.exe /compile main_ea.mq5 |
| Errors | 0 |
| Warnings | 0 |
| Binary timestamp | 2026-05-09 05:29:15 |
| Log file | compile_fvg_tpb_impl_v1.log |
| Runtime authority transferred | NO |

**Error encountered and fixed during compile:**
- council_strategies.mqh line 3216: `SFVGZone &tz = sZones[triggeredIdx]` — MQL5 does not support local reference variables to array elements (error 229: `'&' - reference cannot used`)
- Fix: Changed to value copy `SFVGZone tz = sZones[triggeredIdx]`; wrote `has_triggered` flag back directly to `sZones[triggeredIdx].has_triggered = true`

---

## N. Archive Verification

| Archive | Created | Size |
|---|---|---|
| PREPATCH | system_backup_FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_PREPATCH_*.zip | ~2.7 MB |
| POSTPATCH | system_backup_FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_POSTPATCH_20260509_053130.zip | 2740.2 KB |

Both archives contain: council_mode_types.mqh, council_strategies.mqh, council_mode_runtime.mqh, main_ea.mq5, main_ea.ex5

---

## O. Static Validation

**Forbidden files — fvg_/ifr_ reference check:**

| File | fvg_ references | ifr_ references |
|---|---|---|
| main_ea.mq5 | 0 | 0 |
| council_aggregator.mqh | 0 | 0 |
| council_pre_ai_filter.mqh | 0 | 0 |
| council_ai_governor.mqh | 0 | 0 |
| core_trade_engine.mqh | 0 | 0 |

**Decision path check — fvg_/ifr_ fields have zero decision authority:**
- No fvg_ or ifr_ field is read by council_aggregator.mqh
- No fvg_ or ifr_ field is read by council_pre_ai_filter.mqh
- No fvg_ or ifr_ field alters any gate, threshold, or filter
- g_fvg_attribution is only written by BuildCouncilStrategy_FVG_TPB and read by WriteOpportunityLedgerRecord

---

## P. Runtime Authority Status

```
RUNTIME_AUTHORITY_STATUS: MT5_UNCHANGED
COUNCIL_GATES_CHANGED: NONE
AGGREGATION_CHANGED: NONE (reportCount 17→18; aggregation logic unchanged)
FILTER_CHANGED: NONE
GOVERNOR_CHANGED: NONE
STOP_GEOMETRY_CHANGED: NONE
WEIGHT_CHANGED: NONE (existing strategies unchanged; fvg_tpb new at 0.65)
NAUTILUS_AUTHORITY: NONE — evidence only
OPPORTUNITY_LEDGER_WRITES: fvg_tpb records now write when trigger_present=true
```

---

## Q. V1C Schema Extension

**New fields in ai_opportunity_ledger.jsonl (fvg_tpb records only):**

| Field | Type | Source | Purpose |
|---|---|---|---|
| fvg_direction | string | g_fvg_attribution | BUY or SELL |
| fvg_gap_low | float | g_fvg_attribution | Lower FVG boundary in price |
| fvg_gap_high | float | g_fvg_attribution | Upper FVG boundary in price |
| fvg_regime_context | string | g_fvg_attribution | era_label_v1 at trigger time |
| fvg_subset_classification | string | g_fvg_attribution | BUY_TREND_DOWN, SELL_RANGE_NEUTRAL, SELL_TREND_DOWN, BASELINE |
| fvg_hostile_gate_fired | bool | g_fvg_attribution | true if SELL_TREND_DOWN suppression fired |
| fvg_size_atr | float | g_fvg_attribution | Gap size expressed as fraction of ATR14(M5) |
| fvg_age_bars | int | g_fvg_attribution | M1 bars elapsed since zone activation |
| fvg_active_zone_count | int | g_fvg_attribution | Total active zones at trigger time |
| fvg_mitigation_pct | float | g_fvg_attribution | (m1Close - fvg_lo) / (fvg_hi - fvg_lo) at entry |
| ifr_playbook_state | string | pss.playbook_state | PLAYBOOK_FORMING or PLAYBOOK_NOT_PRESENT |

**New field in ai_opportunity_summary.json:**
- `ifr_state_seen_count`: integer — count of fvg_tpb trigger records written this session

---

## R. What Was Not Implemented (Out of Scope)

| Feature | Status | Reason |
|---|---|---|
| On-init zone replay | NOT_IMPLEMENTED | Requires main_ea.mq5 modification — forbidden |
| CONFIRMATION_PACKET for IFR | NOT_IMPLEMENTED | No pre-decision event-order proof; IFR VALID state withheld |
| Cross-family CRR for fvg_tpb | NOT_IMPLEMENTED | Phase 4A not authorized; blocked on TPC fire rate |
| Exhaustion veto integration | NOT_IMPLEMENTED | Phase 4B not authorized; blocked on MFI entries |
| Weight elevation from 0.65 | NOT_AUTHORIZED | EEWP design-only; no live runtime evidence yet |
| Nautilus certification upgrade (SOURCE_FAITHFUL) | NOT_IMPLEMENTED | Current basis is ALPHA_TRIGGER_PACKET; full MT5 source replay pending |

---

## S. Known Limitations

1. **Cold-start zone loss** — Static arrays cleared on EA reload. 0–4 hour FVG zone gap after reload.
2. **Single-trigger-per-zone** — has_triggered=true after first fill; zone will not re-trigger even if price re-enters gap. By design (FIFO protocol).
3. **4-hour expiry is fixed** — Cannot be adjusted per-regime without source change.
4. **OBSERVE_ONLY in TC zone** — fvg_tpb will not vote in TREND_CONTINUATION zone. If TC becomes dominant zone, fvg_tpb contributes at 15% weight only.
5. **IFR VALID state permanently withheld** — FORMING is maximum achievable state until CONFIRMATION_PACKET is defined and pre-decision event-order proof is established.

---

## T. Next Actions (Runtime Validation)

After EA reload in terminal:

1. **Verify fvg_tpb appears in ai_opportunity_summary.json** — strategy_id "fvg_tpb" should appear with evaluations_seen incrementing
2. **Verify first trigger write** — ai_opportunity_ledger.jsonl should contain records with strategy_id="fvg_tpb" when an FVG fill occurs
3. **Verify fvg_ fields present** — fvg_direction, fvg_gap_low, fvg_gap_high should appear in fvg_tpb ledger records
4. **Verify IFR playbook state** — playbook_id="IMBALANCE_FILL_REVERSAL", playbook_state="PLAYBOOK_FORMING" in fvg_tpb records
5. **Verify hostile gate** — fvg_hostile_gate_fired=true should appear in SELL records when regime=TREND_DOWN
6. **Monitor for MQL5 runtime errors** — Print output should show no division-by-zero, array-out-of-bounds, or zone state errors
7. **Verify existing strategies unaffected** — All 17 existing strategies should continue firing with same behavior

---

## U. Footer

```
PACKAGE_ID:                      FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1
REPORT_DATE:                     2026-05-09
BINARY_TIMESTAMP:                2026-05-09 05:29:15 local
COMPILE_RESULT:                  0 errors, 0 warnings
FACTORY_ADMISSION_LOCK:          LIFTED FOR FVG_TPB ONLY
SOURCE_CHANGED:                  YES — council_mode_types.mqh, council_strategies.mqh, council_mode_runtime.mqh
MAIN_EA_CHANGED:                 NO
AGGREGATOR_CHANGED:              NO
PRE_AI_FILTER_CHANGED:           NO
GOVERNOR_CHANGED:                NO
STOP_GEOMETRY_CHANGED:           NO
RUNTIME_AUTHORITY_TRANSFERRED:   NO
NAUTILUS_EXECUTION_AUTHORITY:    NO
PRODUCTION_READY_CLAIMED:        NO
SYSTEM_STATUS:                   DEVELOPING (unchanged)
RUNTIME_VALIDATION_STATUS:       PENDING — requires EA reload
NEXT_ACTION:                     EA reload → runtime validation of fvg_tpb trigger writes
DESIGN_LANE:                     IMBALANCE_FILL_REVERSAL (IFR)
IFR_VALID_STATE:                 PERMANENTLY_WITHHELD — no CONFIRMATION_PACKET
COLD_START_LIMITATION:           DOCUMENTED — on-init replay not implemented
NO_CODE_FACTORY_LOCK_FOUND:      TRUE — governance via operator authorization only
PREPATCH_ARCHIVE:                system_backup_FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_PREPATCH_*.zip
POSTPATCH_ARCHIVE:               system_backup_FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1_POSTPATCH_20260509_053130.zip
```
