# NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_SPEC_V1

**Date:** 2026-05-11
**Author:** Claude (read-only design; no source changes in this document)
**Mission:** Codex-ready specification for NR7 as a unified shadow packet in the MT5 council system
**Scope:** Specification and package design only — no source changes, no compile, no MT5 reload

---

## A. Executive Summary

```
VERDICT: NR7_SHADOW_RUNTIME_SPEC_READY_FOR_CODEX
```

NR7 (Narrow Range 7) passed INEC certification with strong ALPHA_TRIGGER, LOCATION, and STOP_GEOMETRY evidence. This spec defines the minimum-footprint shadow integration: one `string` field in `CouncilEnvironmentReport`, computed inside `BuildCouncilEnvironmentReport()`, written to the OL JSONL as a new field, and blocked from influencing any trading logic.

**Management decision (simplified development rule):**

```
Research → INEC → Shadow Integration → Runtime Evidence → Live Influence Later
```

NR7 INEC is complete. Shadow integration is the authorized next step. Live influence is NOT authorized.

**Boundaries for this spec:**
- No BUY/SELL/WAIT change, no stop/TP/lot change
- No pending orders, no OCO
- No BuildTradeLevels override
- No strategy slot, no COUNCIL_MAX_STRATEGIES change
- No vote weight change
- No V1/risk/execution/cohort change
- No IRREW flag activation
- No production-ready claim

---

## B. Authority Constraints

| Constraint | Rule |
|---|---|
| MT5 authority | Canonical. Shadow state is observability-only. |
| Nautilus | Research/certification lab only. No runtime decisions. |
| NR7 runtime influence | `runtime_authority_status: "NONE"` — no read-back into any trading logic. |
| Council decision path | `nr7_shadow_state` must NOT be read by council_aggregator, council_pre_ai_filter, council_ai_governor, council_strategies, or core_trade_engine. |
| IRREW flags | All remain FALSE. This spec does not touch IRREW. |
| Production ready | Remains FALSE. |

---

## C. Source Review Summary

Sources read for this spec:

| File | Finding |
|---|---|
| `council_mode_types.mqh:122–204` | `CouncilEnvironmentReport` struct. ATAS shadow precedent at lines 163–203. New field appended after line 203. |
| `council_mode_types.mqh:755–834` | `InitCouncilEnvironmentReport()`. New init line appended before closing `}` at line 834. |
| `council_mode_types.mqh:478–495` | `CouncilRuntimeResult` has `CouncilEnvironmentReport env` at line 484. OL writer accesses `runtime.env.nr7_shadow_state`. |
| `council_environment.mqh:328–476` | `BuildCouncilEnvironmentReport()`. ATAS shadow attached at lines 389–473. NR7 shadow block inserted after `ClassifyCouncilZone` (line 368) and before ATAS block (line 389). |
| `council_mode_runtime.mqh:252–587` | `RunCouncilModePipeline()`. Event order: snapshots → `BuildCouncilEnvironmentReport` (step 2) → `RunCouncilStrategySet` (step 3) → ... Decision at step 8. NR7 computed at step 2, BEFORE strategies, pre-AI filter, and governor. |
| `core_market_data.mqh:12–21` | `TimeframeSnapshot` has only 3 bars (bar1/bar2/bar3). NR7 requires 7-bar lookback — must use direct `iHigh`/`iLow` API calls (shift 1–7). |
| `council_mode_runtime.mqh.bak_20260510_205829:1620` | `WriteOpportunityLedgerRecord()` — canonical OL JSON builder. Last known location of OL writer. See Section H (OL Writer Dependency). |

**OL writer source-binary divergence (critical finding):** `WriteOpportunityLedgerRecord` is present in the pre-Package-2 backup but is NOT in any current `.mq5` or `.mqh` source file. The running binary has the OL writer compiled in from an older version. Codex MUST resolve this dependency before adding the `nr7_shadow_state` OL field. See Section H.

---

## D. Design Questions (Q1–Q10)

### Q1: Does NR7 shadow state belong in CouncilEnvironmentReport or a separate struct?

**Decision: CouncilEnvironmentReport — same pattern as ATAS Phase 0 shadow.**

`CouncilEnvironmentReport` is the environment context that flows through the full pipeline and is embedded in `CouncilRuntimeResult.env`. It is the correct struct for context-enrichment fields that are computed pre-decision and carried through the OL record. No separate struct is needed for Phase 0 shadow-only state.

### Q2: Should NR7 state include box bounds (high/low/range) or just the state string?

**Decision: State string only. No box bounds in runtime struct.**

Box bounds are derivable offline from OHLCV at any time. Including them in the runtime struct would add 3 double fields with no observability benefit that cannot be obtained by the offline attribution pipeline. The INEC certification proved box bounds can be computed accurately from OHLCV alone. Box bounds remain in the offline Python (already in `nr7_attribution_offline.py`).

### Q3: Where in BuildCouncilEnvironmentReport should NR7 be computed?

**Decision: After `ClassifyCouncilZone()` (line 368), before the ATAS shadow block (line 389).**

NR7 needs to be computed AFTER all base environment assessments are complete (so `r.valid` is set) and BEFORE ATAS shadow attachment. This ensures the NR7 state reflects the fully-resolved environment context at the decision point. The insertion point is line 369–388 (the gap between `ClassifyCouncilZone` and the ATAS comment).

### Q4: Does NR7 computation need the cached TimeframeSnapshot or direct API calls?

**Decision: Direct API calls (`iHigh`, `iLow` on PERIOD_M5, shifts 1–7).**

`TimeframeSnapshot` only holds 3 bars (bar1/bar2/bar3). NR7 requires 7 completed bars (shifts 1–7 on M5). The computation must use `iHigh(_Symbol, PERIOD_M5, k)` and `iLow(_Symbol, PERIOD_M5, k)` for k=1..7 directly. For series detection (SERIES/FILTERED_SERIES), shifts 2–8 are needed for bar2's NR7 check.

### Q5: Which ATR source for the ATR filter?

**Decision: `CouncilGetATR(PERIOD_M1, 14, 1)` — already exists in `council_environment.mqh`.**

This function is already used in `EvaluateCouncilLiquidity()` and is the canonical ATR access pattern in this file. The INEC used M1 ATR(14) for the 40% box filter. No new indicator setup required.

### Q6: Should `nr7_shadow_state` appear in the env report summary string?

**Decision: YES — append `| nr7=<state>` to `r.summary`.**

The ATAS shadow state is not appended to `r.summary` in the base summary builder (it gets its own `atas_summary` field). For NR7, because it is a single compact string with no standalone summary field, appending it to `r.summary` is the minimal visibility mechanism. This does not affect trading logic (summary is observability-only).

### Q7: How is `nr7_shadow_state` serialized in the OL JSONL?

**Decision: One new JSON field `"nr7_shadow_state":"<value>"` in `WriteOpportunityLedgerRecord`.**

The OL JSON builder uses string concatenation. The new field is appended near the end of the existing V1C JSON string, just before the final `}`. The value is `runtime.env.nr7_shadow_state` (a plain ASCII string — no escape needed for enum-style values, but `OpportunityJsonEscape` wrapper is used for safety). No schema version bump is needed unless the project governance requires it.

### Q8: Should `nr7_shadow_state` appear in any text report or log?

**Decision: Optional low-priority addition to council_txt_reporter.mqh / cycle log text.**

Not required for Phase 0 shadow. The priority field is the OL JSONL record. If desired, a single line can be added to `BuildCouncilCycleLogText` in `council_mode_logger.mqh` via `CouncilLogLine("nr7_shadow_state", env.nr7_shadow_state)`. This is marked OPTIONAL in the Codex package.

### Q9: Does NR7 state need init/reset in CouncilEnvironmentReport init?

**Decision: YES — `r.nr7_shadow_state = "NONE";` in `InitCouncilEnvironmentReport()`.**

All fields in `CouncilEnvironmentReport` are explicitly initialized in `InitCouncilEnvironmentReport()`. The new field must be initialized to `"NONE"` (the no-NR7 state). Appended after line 833, before closing `}`.

### Q10: What defines "Gate 3A1 ready" (live attribution from runtime records)?

**Decision: Gate 3A1 requires `N_nr7_context ≥ 20` OL records with `nr7_shadow_state` field populated AND `actual_trade = true`.**

Currently all 53 OL records have `actual_trade = false` (confirmed in Gate 3A0). Gate 3A1 requires actual trade outcomes matched against NR7 context state. ETA: ~90 days of live operation after this shadow implementation is compiled and the system produces trades.

Gate 3A1 ALSO requires: the OL records must be schema version `OL_V1C_IRREW_DEV_V1` or later with the `nr7_shadow_state` field present. Old records without the field are NOT countable toward the N_nr7_context threshold.

---

## E. Field Specification

### E1. New field in CouncilEnvironmentReport

```cpp
// Phase 0: NR7 shadow state (observability-only, non-authoritative, no live influence)
string nr7_shadow_state;   // NONE | RAW | ATR_FILTERED | SERIES | FILTERED_SERIES
```

**Value semantics:**

| Value | Meaning |
|---|---|
| `NONE` | Current M5 bar (shift=1) is not a Narrow Range 7 bar |
| `RAW` | NR7 present (range[1] < min(range[2..7])) but box > 40% ATR — fails ATR filter |
| `ATR_FILTERED` | NR7 present AND box ≤ 40% ATR (passes ATR filter) — production-relevant subset |
| `SERIES` | NR7 AND bar[2] is also NR7 (consecutive NR7 run) AND ATR filter fails |
| `FILTERED_SERIES` | NR7 AND bar[2] is also NR7 (consecutive run) AND ATR filter passes — tightest state |

**Values not used at runtime (deferred to OL post-processing):**
- `BREAKOUT_UP` — requires bar close (post-decision)
- `BREAKOUT_DOWN` — requires bar close (post-decision)
- `AMBIGUOUS` — requires bar close (post-decision)
- `EXPIRED` — NR7 box no longer active (deferred)

### E2. Placement in struct

After the last existing field (`atas_sr_observation_source` at line 203), before closing `};`:

```cpp
   // Phase 0: NR7 shadow state (observability-only, non-authoritative, no live influence)
   string nr7_shadow_state;
};
```

### E3. Init value

In `InitCouncilEnvironmentReport()`, after line 833 (`r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";`), before `}`:

```cpp
   r.nr7_shadow_state = "NONE";
```

---

## F. Implementation Design

### F1. council_mode_types.mqh — Struct field + init

**Change 1: Add field to CouncilEnvironmentReport struct**

Location: `council_mode_types.mqh`, after line 203 (after `string atas_sr_observation_source;`, before `};`)

```cpp
   // Phase 0: NR7 shadow state (observability-only, non-authoritative, no live influence)
   string nr7_shadow_state;
```

**Change 2: Add init to InitCouncilEnvironmentReport**

Location: `council_mode_types.mqh`, after line 833 (after `r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";`, before `}`)

```cpp
   r.nr7_shadow_state = "NONE";
```

### F2. council_environment.mqh — NR7 shadow computation block

**Change 3: Add NR7 shadow computation inside BuildCouncilEnvironmentReport**

Location: `council_environment.mqh`, between line 368 (`ClassifyCouncilZone(reg, r);`) and line 369 (blank line before line 370 `r.summary = ...`).

Wait — re-reading the actual code, `r.summary` is built at lines 370–382, and the ATAS block starts at line 389. So the NR7 block inserts between the summary builder (lines 370–382) and the ATAS block (line 389). Specifically, after line 382 and before line 384 (the tradable/reject_reason block).

Actually, the correct insertion point is: after the base environment is complete and `r.valid = true` is set (line 365), after `ClassifyCouncilZone` (line 368), after the `r.summary` builder (line 382), after `r.reject_reason` is set (line 385 or 387), and before the ATAS block (line 389). The NR7 block is independent of the summary string (though it will append to it).

The exact location is between line 387 (`r.reject_reason = "";`) and line 389 (`// Phase 0 ATAS intake...`).

Insert this block:

```cpp
   // Phase 0 NR7 shadow: observability-only, zero live influence.
   {
      string _nr7 = "NONE";
      double _r0 = iHigh(_Symbol, PERIOD_M5, 1) - iLow(_Symbol, PERIOD_M5, 1);
      if(_r0 > 0.0)
      {
         double _min_prev = _r0 * 2.0;   // safe upper bound
         bool   _ok       = true;
         for(int _k = 2; _k <= 7; _k++)
         {
            double _rk = iHigh(_Symbol, PERIOD_M5, _k) - iLow(_Symbol, PERIOD_M5, _k);
            if(_rk <= 0.0) { _ok = false; break; }
            if(_rk < _min_prev) _min_prev = _rk;
         }
         if(_ok && _r0 < _min_prev)
         {
            double _atr    = CouncilGetATR(PERIOD_M1, 14, 1);
            bool   _atr_ok = (_atr > 0.0 && _r0 <= 0.40 * _atr);
            bool   _series = false;
            double _r1     = iHigh(_Symbol, PERIOD_M5, 2) - iLow(_Symbol, PERIOD_M5, 2);
            if(_r1 > 0.0)
            {
               double _min2  = _r1 * 2.0;
               bool   _ok2   = true;
               for(int _k2 = 3; _k2 <= 8; _k2++)
               {
                  double _rk2 = iHigh(_Symbol, PERIOD_M5, _k2) - iLow(_Symbol, PERIOD_M5, _k2);
                  if(_rk2 <= 0.0) { _ok2 = false; break; }
                  if(_rk2 < _min2) _min2 = _rk2;
               }
               if(_ok2 && _r1 < _min2) _series = true;
            }
            _nr7 = _series ? (_atr_ok ? "FILTERED_SERIES" : "SERIES")
                           : (_atr_ok ? "ATR_FILTERED"    : "RAW");
         }
      }
      r.nr7_shadow_state = _nr7;
      r.summary += " | nr7=" + r.nr7_shadow_state;
   }
```

**Algorithm notes:**
- `iHigh`/`iLow` at shift=1 = most recently completed M5 bar (the one the council is evaluating)
- Shifts 2–7 = the 6 bars before it (lookback for NR7 minimum range)
- Shift=2 for series check = the bar before bar1
- Series check uses shifts 3–8 for the prior 6 bars of bar2
- `_r0 * 2.0` as initial `_min_prev` ensures correct minimum search (any real bar range < 2×bar1 range)
- `CouncilGetATR(PERIOD_M1, 14, 1)` reuses the existing function already in `council_environment.mqh`
- Zero live influence: `r.nr7_shadow_state` is NOT checked by any function called after this block (councils, aggregator, pre-AI filter, governor, trade engine)

### F3. OL JSONL field addition (DEPENDENCY-GATED)

**Change 4: Add nr7_shadow_state to WriteOpportunityLedgerRecord**

**STATUS: DEPENDENCY — See Section H before implementing this change.**

When the OL write path is confirmed/re-established in the source, add the following to the JSON string builder inside `WriteOpportunityLedgerRecord()`:

```cpp
j += ",\"nr7_shadow_state\":\"" + OpportunityJsonEscape(runtime.env.nr7_shadow_state) + "\"";
```

Access path: `runtime.env.nr7_shadow_state` where `runtime` is `CouncilRuntimeResult` (which embeds `CouncilEnvironmentReport env` at line 484 of council_mode_types.mqh).

---

## G. Forbidden Changes

The following files must NOT be modified in this implementation:

| File | Reason |
|---|---|
| `core_trade_engine.mqh` | No execution logic may change. NR7 must not affect order placement, stops, targets, or lot sizing. |
| `council_aggregator.mqh` | No aggregation or score path may read nr7_shadow_state. |
| `council_strategies.mqh` | No strategy evaluation may change. NR7 is not a council strategy. |
| `council_pre_ai_filter.mqh` | No pre-AI gate may read nr7_shadow_state. |
| `council_ai_governor.mqh` | No governor logic may read nr7_shadow_state. |
| `council_failure_detector.mqh` | No failure detector logic may change. |
| `council_memory.mqh` | No memory update path may change. |
| `council_feedback.mqh` | No feedback path may change. |
| `council_adaptive_weights.mqh` | No weight path may change. |
| `decision_mode_router.mqh` | No router logic may change. |
| `risk_state_policy_engine.mqh` | No risk policy may change. |
| `execution_estimator_v1.mqh` | No execution estimator may change. |
| `strategy_intelligence_layer_v1.mqh` | No strategy intelligence may change. |
| `institutional_learning_layer_v1.mqh` | No learning layer may change. |
| `LIBRARIES/*.mqh` | No library files may change. |
| `MQL5/Files/AI/*.jsonl` | No runtime files may be hand-edited. |

**Hard constraint on nr7_shadow_state consumption:**
The field `nr7_shadow_state` must NOT appear in any `if`, `switch`, conditional expression, or comparison in: `council_aggregator.mqh`, `council_pre_ai_filter.mqh`, `council_ai_governor.mqh`, `core_trade_engine.mqh`, `council_strategies.mqh`, `council_failure_detector.mqh`, or any file that affects `final_decision`, `filter_passed`, `executed_direction`, entry price, stop price, lot size, or position management.

---

## H. OL Writer Dependency Note

**CRITICAL FINDING — Source-binary divergence on OL write path.**

The function `WriteOpportunityLedgerRecord()` was last located at `council_mode_runtime.mqh.bak_20260510_205829:1620`. It is NOT present in any current `.mq5` or `.mqh` source file in the working directory.

The running binary (`main_ea.ex5`, mtime 2026-05-11 06:47:02) has the OL writer compiled in from a pre-Package-2 version of `council_mode_runtime.mqh`. The OL records in `ai_opportunity_ledger.jsonl` are being written by this older binary.

**Implication for Codex implementation:**

Codex MUST perform the following before implementing Change 4:

1. **Locate the OL writer in current source.** Search all `.mq5` and `.mqh` files for `WriteOpportunityLedgerRecord`. If not found, proceed to step 2.
2. **Identify the correct re-establishment path.** The canonical reference is `council_mode_runtime.mqh.bak_20260510_205829`, lines 1620–1880. The function must be restored to `council_mode_runtime.mqh` or `main_ea.mq5` before the `nr7_shadow_state` field can be added.
3. **Do NOT add a nr7_shadow_state field to a non-existing write path.** If the OL writer cannot be located, flag the gap and proceed with Changes 1–3 only. Change 4 becomes a follow-on task.

**What Codex reports back:** Codex must confirm in its implementation report whether the OL writer was found in the current source or whether the write-path re-establishment was required.

---

## I. Codex Package: NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_PACKAGE_V1

### I1. Package Identity

```
PACKAGE_ID:     NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_PACKAGE_V1
DATE:           2026-05-11
SPEC:           NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_SPEC_V1.md
SCOPE:          Shadow-only; zero live influence; observability field + OL instrumentation
SOURCE_CHANGES: council_mode_types.mqh (2 changes), council_environment.mqh (1 change), 
                council_mode_runtime.mqh or main_ea.mq5 (1 change — DEPENDENCY-GATED)
COMPILE:        Required after all changes
RELOAD:         Required after compile
AUTHORITY:      runtime_authority_status = "NONE"
PRODUCTION_READY: FALSE
```

### I2. Pre-implementation Checklist

Before making any changes:

- [ ] Read `council_mode_types.mqh` lines 122–204 (CouncilEnvironmentReport struct) — verify `atas_sr_observation_source` is last field at line 203
- [ ] Read `council_mode_types.mqh` lines 755–834 (InitCouncilEnvironmentReport) — verify `r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";` is last assignment at line 833
- [ ] Read `council_environment.mqh` lines 364–392 (BuildCouncilEnvironmentReport post-ClassifyCouncilZone block) — confirm insertion point between lines 387 and 389
- [ ] Search all `.mq5`/`.mqh` for `WriteOpportunityLedgerRecord` — document result (found/not found)
- [ ] Create governed backups: `council_mode_types.mqh.bak_YYYYMMDD_HHMMSS`, `council_environment.mqh.bak_YYYYMMDD_HHMMSS`

### I3. Changes in Order

**CHANGE 1 — council_mode_types.mqh: Add struct field**

File: `council_mode_types.mqh`
Location: After line 203 (`string atas_sr_observation_source;`), before `};`
Action: Insert one field

Before:
```cpp
   string atas_sr_observation_source;
};
```

After:
```cpp
   string atas_sr_observation_source;

   // Phase 0: NR7 shadow state (observability-only, non-authoritative, no live influence)
   string nr7_shadow_state;
};
```

---

**CHANGE 2 — council_mode_types.mqh: Add init**

File: `council_mode_types.mqh`
Location: After line 833 (`r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";`), before `}`
Action: Insert one init line

Before:
```cpp
   r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";
}
```

After:
```cpp
   r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";
   r.nr7_shadow_state = "NONE";
}
```

---

**CHANGE 3 — council_environment.mqh: Add NR7 shadow computation**

File: `council_environment.mqh`
Location: After line 387 (`r.reject_reason = "";`), before line 389 (`// Phase 0 ATAS intake:`)
Action: Insert NR7 shadow computation block

Before:
```cpp
   if(!r.tradable)
      r.reject_reason = "Environment unsuitable for scalping";
   else
      r.reject_reason = "";

   // Phase 0 ATAS intake: strict shadow-only attachment with zero live influence.
```

After:
```cpp
   if(!r.tradable)
      r.reject_reason = "Environment unsuitable for scalping";
   else
      r.reject_reason = "";

   // Phase 0 NR7 shadow: observability-only, zero live influence.
   {
      string _nr7 = "NONE";
      double _r0 = iHigh(_Symbol, PERIOD_M5, 1) - iLow(_Symbol, PERIOD_M5, 1);
      if(_r0 > 0.0)
      {
         double _min_prev = _r0 * 2.0;
         bool   _ok       = true;
         for(int _k = 2; _k <= 7; _k++)
         {
            double _rk = iHigh(_Symbol, PERIOD_M5, _k) - iLow(_Symbol, PERIOD_M5, _k);
            if(_rk <= 0.0) { _ok = false; break; }
            if(_rk < _min_prev) _min_prev = _rk;
         }
         if(_ok && _r0 < _min_prev)
         {
            double _atr    = CouncilGetATR(PERIOD_M1, 14, 1);
            bool   _atr_ok = (_atr > 0.0 && _r0 <= 0.40 * _atr);
            bool   _series = false;
            double _r1     = iHigh(_Symbol, PERIOD_M5, 2) - iLow(_Symbol, PERIOD_M5, 2);
            if(_r1 > 0.0)
            {
               double _min2 = _r1 * 2.0;
               bool   _ok2  = true;
               for(int _k2 = 3; _k2 <= 8; _k2++)
               {
                  double _rk2 = iHigh(_Symbol, PERIOD_M5, _k2) - iLow(_Symbol, PERIOD_M5, _k2);
                  if(_rk2 <= 0.0) { _ok2 = false; break; }
                  if(_rk2 < _min2) _min2 = _rk2;
               }
               if(_ok2 && _r1 < _min2) _series = true;
            }
            _nr7 = _series ? (_atr_ok ? "FILTERED_SERIES" : "SERIES")
                           : (_atr_ok ? "ATR_FILTERED"    : "RAW");
         }
      }
      r.nr7_shadow_state = _nr7;
      r.summary += " | nr7=" + r.nr7_shadow_state;
   }

   // Phase 0 ATAS intake: strict shadow-only attachment with zero live influence.
```

---

**CHANGE 4 — OL writer: Add nr7_shadow_state field (DEPENDENCY-GATED)**

**Prerequisite:** OL writer source location confirmed (see Section H).

File: `council_mode_runtime.mqh` (or wherever `WriteOpportunityLedgerRecord` is re-established)
Location: In the JSON string builder inside `WriteOpportunityLedgerRecord`, near the end before final `}`
Action: Append one JSON field

```cpp
j += ",\"nr7_shadow_state\":\"" + OpportunityJsonEscape(runtime.env.nr7_shadow_state) + "\"";
```

If `OpportunityJsonEscape` is not available in the re-established file, use:
```cpp
string _nr7_esc = runtime.env.nr7_shadow_state;
StringReplace(_nr7_esc, "\"", "\\\"");
j += ",\"nr7_shadow_state\":\"" + _nr7_esc + "\"";
```

---

### I4. Compile Instructions

After all changes are applied:

1. Open MetaEditor
2. Compile `main_ea.mq5` (includes all modified files transitively)
3. Expected result: `0 errors, 0 warnings`
4. If any warning about `nr7_shadow_state` not initialized: confirm Change 2 was applied
5. Save compile log as `compile_nr7_shadow_runtime_integration_v1_<YYYYMMDD_HHMMSS>.log`

### I5. Runtime Validation Checklist

After compile and MT5 reload:

**Static checks (pre-reload, source-only):**
- [ ] `council_strategies.mqh`: Search for `nr7_shadow_state` → 0 matches (REQUIRED)
- [ ] `council_aggregator.mqh`: Search for `nr7_shadow_state` → 0 matches (REQUIRED)
- [ ] `council_pre_ai_filter.mqh`: Search for `nr7_shadow_state` → 0 matches (REQUIRED)
- [ ] `council_ai_governor.mqh`: Search for `nr7_shadow_state` → 0 matches (REQUIRED)
- [ ] `core_trade_engine.mqh`: Search for `nr7_shadow_state` → 0 matches (REQUIRED)
- [ ] `council_environment.mqh`: Search for `nr7_shadow_state` → 2 matches (REQUIRED: assignment + summary append)
- [ ] `council_mode_types.mqh`: Search for `nr7_shadow_state` → 2 matches (REQUIRED: field + init)

**Runtime checks (after reload, first 2 hours):**
- [ ] `ai_opportunity_ledger.jsonl` tail: new records have `"nr7_shadow_state":` field
- [ ] `nr7_shadow_state` values are one of: `NONE`, `RAW`, `ATR_FILTERED`, `SERIES`, `FILTERED_SERIES`
- [ ] At least one record has value other than `NONE` within 30 bars (NR7 fires ~7.5% of M5 bars on XAUUSD)
- [ ] `filter_passed` remains independent of `nr7_shadow_state` (compare filter_passed=true records vs nr7 states — no correlation pattern that suggests gate dependency)
- [ ] `final_decision` distribution is unchanged from pre-integration baseline
- [ ] No new errors or warnings in Experts log related to NR7 or shadow state
- [ ] `council_report.txt` or env summary string shows `nr7=<state>` (verifying the summary append works)

### I6. Acceptance Criteria

**Pass criteria (all required):**

| # | Criterion | Method |
|---|---|---|
| A1 | `nr7_shadow_state` field present in new OL records | Tail 10 records from ai_opportunity_ledger.jsonl after reload |
| A2 | Values are only from {NONE, RAW, ATR_FILTERED, SERIES, FILTERED_SERIES} | Python check or manual scan |
| A3 | nr7_shadow_state not referenced in any forbidden file | Static grep: 0 matches in forbidden files |
| A4 | Compile: 0 errors, 0 warnings | Compile log |
| A5 | No change to filter_passed or actual_trade rate | Compare OL statistics before/after over 50+ bars |
| A6 | ATR_FILTERED rate ≈ 1–2% of OL records (consistent with INEC finding of 1.9% on 53-bar sample) | Python count on new records |
| A7 | RAW rate ≈ 5–8% of OL records (NR7 fires ~7.5% minus ATR-filtered subset) | Python count |
| A8 | NONE rate ≈ 90%+ of OL records | Python count |

**Rejection criteria:**

| Condition | Action |
|---|---|
| `nr7_shadow_state` values in forbidden file | ROLLBACK immediately |
| Compile errors | Do not reload; fix errors; re-compile |
| New OL records missing `nr7_shadow_state` field | OL write path not updated — apply Change 4 |
| `nr7_shadow_state` all-NONE after 50 bars | NR7 computation bug — debug lookup shifts |
| ATR_FILTERED rate > 20% | ATR computation or threshold bug — check _r0 calculation |

### I7. Rollback Instructions

If any acceptance criterion fails post-reload:

1. Stop MT5 EA (remove from chart or disable auto-trading)
2. Restore from governed backups:
   - `council_mode_types.mqh.bak_YYYYMMDD_HHMMSS` → `council_mode_types.mqh`
   - `council_environment.mqh.bak_YYYYMMDD_HHMMSS` → `council_environment.mqh`
   - If Change 4 applied: restore OL writer file backup
3. Recompile main_ea.mq5 (0 errors expected from rollback)
4. Reload EA
5. Document rollback reason in PIML

---

## J. PIML Update Required

After successful implementation (or after this spec is written if spec-only), update `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` CURRENT STATE ANCHOR with:

```
NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_SPEC_V1:
  Status: SPEC_COMPLETE_AWAITING_CODEX_IMPLEMENTATION
  Verdict: NR7_SHADOW_RUNTIME_SPEC_READY_FOR_CODEX
  INEC: ACCEPTED (WR=58.3%, E[R]=+0.456R, PF=2.094, N=5498; all 3 packet roles)
  Live influence: NOT_AUTHORIZED
  Shadow integration: AUTHORIZED (observability-only, nr7_shadow_state field)
  OL write dependency: SOURCE_BINARY_DIVERGENCE_NOTED — WriteOpportunityLedgerRecord not in current source
  Gate 3A1: DEFERRED — requires N_nr7_context ≥ 20 actual trades after shadow deployment
  Gate 3B: DEFERRED — requires ai_performance_journal.jsonl with V3 schema MAE fields
  Production ready: FALSE
  Codex implementation: NOT_YET_AUTHORIZED (spec gate; operator must confirm)
```

---

## K. What Will NOT Happen in This Implementation

- No BUY/SELL/WAIT decision change
- No stop price, TP price, or lot size change
- No pending orders or OCO orders
- No BuildTradeLevels override
- No strategy slot added to council
- No COUNCIL_MAX_STRATEGIES change
- No vote weight change
- No IRREW flag activated
- No Nr7 strategy added to operating cohort
- No production-ready claim
- No Gate 3A1 activation (deferred)
- No Gate 3B execution (deferred)
- No INEC re-run
- No Nautilus certification changes

---

## L. Final Decision

```
VERDICT:                NR7_SHADOW_RUNTIME_SPEC_READY_FOR_CODEX
SPEC_STATUS:            COMPLETE
SOURCE_CHANGED:         NO (spec-only document)
COMPILE_RUN:            NO
MT5_RELOAD:             NO
LIVE_INFLUENCE:         NOT_AUTHORIZED
CODEX_AUTHORIZED:       PENDING_OPERATOR_CONFIRMATION
PRODUCTION_READY:       FALSE
RUNTIME_AUTHORITY:      NONE
SYSTEM_STATUS:          DEVELOPING
```

**To advance to Codex implementation, the operator must confirm:**

> Authorize Codex to implement NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_PACKAGE_V1 per spec at `DOCS_SYSTEM/01_ARCHITECTURE/NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_SPEC_V1.md`.

**Once authorized, Codex will:**
1. Create governed backups of `council_mode_types.mqh` and `council_environment.mqh`
2. Apply Change 1 (struct field) and Change 2 (init) to `council_mode_types.mqh`
3. Apply Change 3 (NR7 shadow computation block) to `council_environment.mqh`
4. Locate `WriteOpportunityLedgerRecord` in current source — apply Change 4 if found; flag and skip if not found
5. Compile and report result (0 errors/warnings required)
6. Return compile log path and implementation report
7. NOT reload MT5 — operator must reload after reviewing compile result

```
SPEC_ID:                NR7_UNIFIED_SHADOW_RUNTIME_INTEGRATION_SPEC_V1
DATE:                   2026-05-11
SOURCE_CHANGED:         NO
COMPILE_RUN:            NO
MT5_RELOAD:             NO
RUNTIME_FILES_MODIFIED: NO
CODEX_INVOLVED:         NO (spec only)
PRODUCTION_READY_CLAIMED: NO
VERDICT:                NR7_SHADOW_RUNTIME_SPEC_READY_FOR_CODEX
```
