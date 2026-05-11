# LEGACY_SCORE_HYBRID_RUNTIME_SURFACE_AUDIT_V1

**Document type:** Runtime-surface contradiction audit
**Date:** 2026-05-10
**Mission:** Determine whether legacy-looking runtime log surfaces are harmless diagnostics or active authority-bearing paths
**Scope:** Read-only — no source changes, no compile, no reload, no runtime JSON modification, no PIML update

**Sources investigated:**
- ai_current_plan.json (authoritative active plan) — DIRECTLY READ ✓
- decision_mode_router.mqh — DIRECTLY READ (full 200 lines) ✓
- main_ea.mq5 — DIRECTLY GREPPED (decision_engine_mode, IsCouncilModeEnabled, LogPlanArchitectureSummary, LogCompiledArchitectureSummary) ✓
- strategy_runtime.mqh — AGENT READ ✓
- shadow_replay_engine.mqh — AGENT READ ✓
- config_loader.mqh, plan_validator.mqh, strategy_compiler.mqh — AGENT GREPPED ✓
- library_strategies.mqh, library_indicators.mqh — AGENT GREPPED ✓
- ai_evolution_engine.mqh, ai_bridge.mqh — AGENT GREPPED ✓

---

## A. Executive Verdict

| Field | Value |
|---|---|
| **Final Verdict** | **LEGACY_SURFACE_ACTIVE_BUT_GOVERNED** |
| Council pipeline active? | **YES — CONFIRMED** (`decision_engine_mode=COUNCIL` in ai_current_plan.json) |
| Legacy score thresholds enforced? | **NO** — log-only; only enforced in HYBRID/GATE/SCORE mode, which is NOT active |
| sweep_detector executing as trigger? | **NO** — only called from EvaluateCompiledPlan(), which does not run in COUNCIL mode |
| plan_mode=HYBRID routing decisions? | **NO** — plan_mode and decision_engine_mode are different fields; routing is by decision_engine_mode=COUNCIL |
| Strategies loaded: 6 vs council 18? | **NOT A CONFLICT** — two separate systems; "6" = legacy library count; "18" = council universe (source-verified) |
| No-Score hard-lock bypassed? | **NO** — DQ hard-lock at L10903-10976 intact; legacy score gates never run in COUNCIL mode |
| BTCUSD reload sanity valid? | **YES** |
| Codex fix required? | **NO** (governing; no safety blocker) — optional plan JSON cleanup as governance recommendation |

**Root cause of all visible legacy surfaces:** The log surfaces originate from two pure-diagnostic log functions (`LogPlanArchitectureSummary()` at main_ea.mq5:L10676-10695 and `LogCompiledArchitectureSummary()` at L10697-10702). These functions print plan JSON metadata fields to the terminal at startup. They are NOT decision gates. The confusion arises because `plan_mode` and `decision_engine_mode` are different fields — the log shows `plan_mode=HYBRID` (a legacy classification) while `decision_engine_mode=COUNCIL` (the actual routing field) is printed in the same log line but may have been truncated in the report.

---

## B. Visible Contradiction Summary

| Surface Reported | Source Location | True Role | Decision Authority? |
|---|---|---|---|
| Score entry threshold: 0.75 | main_ea.mq5:L10693 (LogPlanArchitectureSummary) | Diagnostic log of gPlan.score_entry_threshold | NO — only enforced inside EvaluateCompiledPlan() |
| Score reject threshold: 0.45 | main_ea.mq5:L10694 (LogPlanArchitectureSummary) | Diagnostic log of gPlan.score_reject_threshold | NO — only enforced inside EvaluateCompiledPlan() |
| plan_mode=HYBRID | main_ea.mq5:L10699 (LogCompiledArchitectureSummary) | Diagnostic log of gCompiledPlan.plan_mode | NO — plan_mode only adjusts score caps inside EvaluateCompiledPlan(); not the routing field |
| Loaded plan: plan_v076 | main_ea.mq5:L10678 (LogPlanArchitectureSummary) | Diagnostic log of gPlan.plan_id | NO — version label; not a source constant |
| Main trigger: sweep_detector | main_ea.mq5:L10679 (LogPlanArchitectureSummary) | Diagnostic log of gPlan.main_trigger_name | NO — sweep_detector trigger only called from EvaluateCompiledPlan() |
| Loaded personality: Aggressive Bollinger Scalper Architect | main_ea.mq5:L13384 | Diagnostic log of gPersonality.profile_name | NO (trade gates) — YES (AI prompt context; bounded by AI advisory) |
| Archetype: EXPERIMENTAL | main_ea.mq5:L10683 (LogPlanArchitectureSummary) | Diagnostic log of gPlan.execution_archetype | NO — archetype has no council routing effect |
| Indicators loaded: 13 | main_ea.mq5:L13372 | Diagnostic log of gIndicatorCount post-BuildIndicatorLibrary() | NO — legacy library count; not council indicators |
| Strategies loaded: 6 | main_ea.mq5:L13373 | Diagnostic log of gStrategyCount post-BuildStrategyLibrary() | NO — legacy library count; completely separate from council's 18 |
| Entry patterns loaded: 9 | main_ea.mq5:L13374 | Diagnostic log of gEntryPatternCount | NO — legacy library; not council |
| Risk models loaded: 7 | main_ea.mq5:L13375 | Diagnostic log of gRiskModelCount | NO — legacy library; not council |
| Filters loaded: 9 | main_ea.mq5:L13376 | Diagnostic log of gFilterCount | NO — legacy library; not council |

---

## C. Score Threshold Audit

### C1. Source of the log lines

Both "Score entry threshold: 0.75" and "Score reject threshold: 0.45" originate from a single log function:

```mql5
// main_ea.mq5:L10693-10694 — inside LogPlanArchitectureSummary()
LogInfo("Score entry threshold: " + DoubleToString(gPlan.score_entry_threshold, 2) +
        " | Score reject threshold: " + DoubleToString(gPlan.score_reject_threshold, 2));
```

This function only calls `LogInfo()`. It does not evaluate thresholds, does not branch on them, and has no decision output.

### C2. Where these thresholds ARE enforced

In `strategy_runtime.mqh`, the actual enforcement:
- `score_entry_threshold` compared at L1519: `if(sbBuy.final_score >= threshold || sbSell.final_score >= threshold)` → BUY/SELL
- `score_reject_threshold` compared at L1536-1542: if both scores at or below → RUNTIME_REJECT

These are inside `EvaluateCompiledPlan()` / `EvaluateByHybridMode()` path.

### C3. Is EvaluateCompiledPlan() called in COUNCIL mode?

**NO.**

Decision routing in `decision_mode_router.mqh:L118`:
```mql5
if(mode == "GATE" || mode == "SCORE" || mode == "HYBRID")
{
   EvaluateCompiledPlan(plan, m1, m5, routed.base_eval);
   return;  // returns here — council never runs
}

if(mode == "COUNCIL")
{
   RunCouncilModePipeline(...);  // THIS runs
}
```

`NormalizeDecisionEngineModeEx(plan.decision_engine_mode)` produces the mode value. Since `decision_engine_mode = "COUNCIL"` (confirmed in ai_current_plan.json), EvaluateCompiledPlan() is NEVER called.

### C4. Does this bypass the No-Score hard-lock?

**NO.** There are two separate score gate surfaces:
1. Legacy score gates in EvaluateCompiledPlan() → NOT reached in COUNCIL mode
2. DQ/strategy intelligence score gates in main_ea.mq5:L10903-10976 → Hard-locked (`// return false; // [NO-SCORE HARD-LOCKED]`) — separate path; independently confirmed in FORCED_ENGINEERING_ACTIVATION_FULL_FORENSIC_ADVERSARIAL_REVIEW_V1

Score threshold verdict: **DIAGNOSTIC ONLY — not enforced in current COUNCIL mode runtime.**

---

## D. HYBRID / plan_v076 Audit

### D1. The decisive fact: plan_mode ≠ decision_engine_mode

These are **two different struct fields** in the `RuntimePlan` / `CompiledPlan` structs.

| Field | Value in ai_current_plan.json | Where used | Effect |
|---|---|---|---|
| `plan_mode` | `"HYBRID"` | strategy_runtime.mqh:L419,479 — score cap adjustments | Only applies inside EvaluateCompiledPlan() — never called in COUNCIL mode |
| `decision_engine_mode` | **`"COUNCIL"`** | decision_mode_router.mqh:L112 — routing | **This is the routing field. Mode=COUNCIL routes to RunCouncilModePipeline().** |

The log line at main_ea.mq5:L10699 prints BOTH fields in one string:
```
Compiled runtime ready | plan_mode=HYBRID | decision_engine_mode=COUNCIL | experiment_family=default_lab
```

If the user report only showed "plan_mode=HYBRID", the full line was truncated. The routing field `decision_engine_mode=COUNCIL` appears in the same log line immediately after.

### D2. Is plan_v076 an active runtime authority?

**As a JSON file:** YES — `ai_current_plan.json` is the authoritative plan file (truth_role="AUTHORITATIVE_ACTIVE_PLAN"). It IS the source that sets gPlan fields at startup.

**As a decision authority:** The plan JSON sets `decision_engine_mode=COUNCIL`. Therefore, the plan's own configuration declares that the COUNCIL pipeline governs decisions. The plan functions as a configuration source, not as a competing decision engine.

### D3. Does HYBRID mode route decisions through old plan logic?

**NO** — because `decision_engine_mode=COUNCIL`. The HYBRID routing branch at L118 is never taken. The council branch at L133 is taken exclusively.

**The default fallback in config_loader.mqh is HYBRID:**
```mql5
// config_loader.mqh:L843 — default only if no JSON loaded
plan.decision_engine_mode = "HYBRID";
```
This default is overridden when the JSON is successfully loaded:
```mql5
// LoadRuntimePlanFromJson extracts: decision_engine_mode="COUNCIL"
```

### D4. plan_v076 naming — source vs runtime

"plan_v076" does NOT appear in any .mqh or .mq5 source file. It exists only as a runtime data label in the JSON file. It is not a compiled constant, not a function name, not a struct type. It is version-tracking metadata.

**HYBRID / plan_v076 verdict:** GOVERNED. plan_mode=HYBRID is a legacy classification field; routing is exclusively by decision_engine_mode=COUNCIL.

---

## E. sweep_detector Audit

### E1. Why "Main trigger: sweep_detector" is logged

```mql5
// main_ea.mq5:L10679 — LogPlanArchitectureSummary() — DIAGNOSTIC ONLY
LogInfo("Main trigger: " + gPlan.main_trigger_name);
```

`gPlan.main_trigger_name = "sweep_detector"` comes from ai_current_plan.json.

### E2. Where sweep_detector is actually evaluated

`DetectSweepDetectorTrigger()` is defined in strategy_runtime.mqh:L616-647. It is called from `EvaluateIndicatorAsTrigger()` at L728:
```mql5
if(triggerId == "sweep_detector") return DetectSweepDetectorTrigger();
```

`EvaluateIndicatorAsTrigger()` is only called from within `EvaluateCompiledPlan()`, which is only called in GATE/SCORE/HYBRID mode.

### E3. Does sweep_detector execute in current COUNCIL mode?

**NO.** The call chain to sweep_detector trigger evaluation:
```
EvaluateDecisionModeRoutedEx (mode=COUNCIL)
  → if(mode=="COUNCIL") { RunCouncilModePipeline() }
  ← does NOT call EvaluateCompiledPlan()
  ← does NOT call EvaluateIndicatorAsTrigger()
  ← does NOT call DetectSweepDetectorTrigger()
```

### E4. Does sweep_detector appear in the council strategy universe?

In `library_strategies.mqh`, sweep_detector is registered as a confirmation indicator in `bollinger_reclaim_reversal` and the primary trigger in `sweep_reversal`. However, the COUNCIL strategy universe in `council_strategies.mqh` is a separate system — each strategy evaluates its own signals in `BuildCouncilStrategy_*()` functions, NOT via EvaluateIndicatorAsTrigger().

sweep_detector as a raw trigger evaluator is not used in the council pipeline.

**sweep_detector verdict:** DIAGNOSTIC label from plan JSON — not executed in COUNCIL mode.

---

## F. Strategies Loaded Count Audit

### F1. What "Strategies loaded: 6" means

```mql5
// main_ea.mq5:L13365-13376
BuildIndicatorLibrary();
BuildStrategyLibrary();     ← gStrategyCount = 6 after this call
BuildEntryPatternLibrary();
BuildRiskModelLibrary();
BuildFilterLibrary();

LogInfo("Strategies loaded: " + IntegerToString(gStrategyCount));  // L13373
```

`gStrategyCount = 6` = the count of strategy definitions registered in `library_strategies.mqh` (legacy plan system). These are named strategy blueprints for EvaluateCompiledPlan() — e.g., `bollinger_reclaim_reversal`, `sweep_reversal`, `dual_timeframe_reclaim`, etc.

### F2. Why this is NOT the council count

The library strategies (gStrategyCount) and the council strategies (COUNCIL_MAX_STRATEGIES) are completely separate systems:

| System | Count | Source | Used by |
|---|---|---|---|
| Library strategies | 6 (gStrategyCount) | library_strategies.mqh | EvaluateCompiledPlan() only |
| Council strategies | 18 (COUNCIL_MAX_STRATEGIES) | council_strategies.mqh | RunCouncilModePipeline() only |

The library is built at startup regardless of mode. It has no effect on council execution. In COUNCIL mode, only RunCouncilStrategySet() matters — it iterates the 18 strategies defined in council_strategies.mqh.

### F3. Can council 18-strategy count be proven from current runtime?

**From source:** COUNCIL_MAX_STRATEGIES=18 in council_mode_types.mqh — confirmed in FORCED_ENGINEERING_ACTIVATION_FULL_FORENSIC_ADVERSARIAL_REVIEW_V1 (Package A review, Section E). This is a compile-time constant; it cannot change without recompile.

**From runtime log:** The "Strategies loaded: 6" log line does NOT reflect council count. Runtime OL records with `irrew_schema_version=OL_V1C_IRREW_DEV_V1` and 18-strategy council aggregate fields are the runtime evidence. Direct log confirmation requires reading the council summary lines from the Experts log after reload.

**Verdict on council 18-count:** SOURCE_VERIFIED (from council_mode_types.mqh COUNCIL_MAX_STRATEGIES=18); RUNTIME_VALIDATION_RECOMMENDED (read OL records post-reload to confirm RunCouncilStrategySet iterates all 18).

---

## G. Old Personality / Archetype Audit

### G1. "Aggressive Bollinger Scalper Architect" source

```mql5
// config_loader.mqh:L15 — LoadDefaultPersonality()
p.profile_name = "Aggressive Bollinger Scalper Architect";
```

This is the default personality. The live personality is loaded at startup:
```mql5
// main_ea.mq5:L13352
LoadPersonalityFromJson("AI\\ai_personality_profile.json", gPersonality);
```

### G2. Does personality affect trade decisions?

**Not directly.** Personality is injected into AI system prompts via `BuildAISystemPrompt(personality)` in `ai_bridge.mqh`. The AI uses it as stylistic guidance when generating decisions or evolution proposals. The AI output can influence:
- AI advisory block (EnableAICandidateBlock) — can BLOCK a trade; cannot force entry
- Evolution proposals — may adjust plan fields in future evolution cycles

The personality does NOT flow into: council pipeline, aggregator, pre-AI filter, authority stack, V1 permission, cohort admission.

### G3. "EXPERIMENTAL" archetype scope

`execution_archetype = "EXPERIMENTAL"` from the plan JSON. Used by:
1. `ai_evolution_engine.mqh:L692` — gates trigger selection in evolution normalization
2. `plan_validator.mqh:L77` — validates archetype is an allowed value
3. `LogPlanArchitectureSummary()` — logs the value

None of these affect the council pipeline or No-Score architecture. The archetype is a label for the plan's experimental classification.

### G4. Risk from personality/archetype to COUNCIL/IRREW architecture

The only non-trivial risk: if the AI bridge is enabled and the AI generates a governance recommendation that clashes with IRREW doctrine (e.g., recommending scoring authority be restored). This is governed by:
- The AI advisory gate is not a source-level authority
- Evolution proposals require plan JSON approval and plan recompilation
- No evolution can reactivate DQ hard-locked score gates without source code change

**Personality/archetype verdict:** ACTIVE in AI prompt context only; no trade decision authority; governance bounded by AI advisory framework.

---

## H. No-Score Regression Assessment

**Path 1 — Legacy score gates in strategy_runtime.mqh:**
- score_entry_threshold (0.75) compared at strategy_runtime.mqh:L1519
- score_reject_threshold (0.45) compared at strategy_runtime.mqh:L1536-1542
- These are inside `EvaluateCompiledPlan()` / `EvaluateByHybridMode()`
- `EvaluateCompiledPlan()` is NEVER called when decision_engine_mode=COUNCIL
- **STATUS: UNREACHABLE in current runtime**

**Path 2 — DQ/strategy intelligence score gates (No-Score hard-lock):**
- main_ea.mq5:L10903-10976: all 9 score gates commented `// return false; // [NO-SCORE HARD-LOCKED]`
- These are a completely separate surface from the plan-mode score gates
- Confirmed intact in FORCED_ENGINEERING_ACTIVATION_FULL_FORENSIC_ADVERSARIAL_REVIEW_V1 Section K
- **STATUS: HARD-LOCKED — confirmed intact**

**No-Score regression finding:** NONE. No score-based gate is active in the current COUNCIL mode runtime. The legacy score thresholds (0.75/0.45) are plan JSON metadata logged for diagnostic purposes only; they have zero enforcement in COUNCIL mode.

---

## I. Council 18-Strategy Runtime Confirmation

### I1. What can be proven from source

`COUNCIL_MAX_STRATEGIES = 18` is a compile-time constant in `council_mode_types.mqh`. This was confirmed in the Package A forensic review. All 18 strategies are registered in `council_strategies.mqh` including fvg_tpb as strategy #18.

### I2. What the runtime log shows

The Experts log after reload will contain council decision output from `BuildCouncilSummaryLine()` in decision_mode_router.mqh:L75-96:
```
Mode=COUNCIL | Final=... | Zone=... | ZoneConf=... | Best=... | Regime=...
```

If this line appears in the Experts log, the council pipeline ran. The strategy-level breakdown (18 individual strategy votes) is not typically logged in the main Experts log — it appears in `council_report.txt` (AI\council_report.txt written per cycle).

### I3. What "Strategies loaded: 6" confirms

Only that 6 legacy library strategy blueprints are registered. This is consistent with COUNCIL mode — the library is built at startup regardless. It says nothing about whether RunCouncilStrategySet evaluated 18 strategies.

**18-strategy runtime verdict:**
- Source-confirmed: COUNCIL_MAX_STRATEGIES=18 ✓
- Runtime log confirmation: Read council_report.txt or search Experts log for "Mode=COUNCIL" after reload
- Status: SOURCE_VERIFIED | RUNTIME_VALIDATION_RECOMMENDED (read OL records for 18-strategy attribution fields)

---

## J. Authority Impact

### J1. Who controls execution decisions?

The authority chain is unchanged from the architecture confirmation:

```
EvaluateDecisionModeRoutedEx (decision_engine_mode=COUNCIL)
  → RunCouncilModePipeline()
      → V1 Permission Authority Stack (P4+V1) — LIVE
      → No-Score Hard-Lock (DQ) — LIVE
      → Risk State Policy Engine — LIVE
      → IRREW Development Actions (all flags=false) — INERT
      → Operating Cohort Admission — LIVE
```

### J2. Can any legacy surface override this?

**NO.** The only path that could activate legacy logic is `decision_engine_mode != "COUNCIL"`. Since it IS "COUNCIL", no override is possible.

### J3. Does plan_mode=HYBRID create dual authority?

**NO.** plan_mode only affects score cap calculations inside EvaluateCompiledPlan() (lines 419, 479 of strategy_runtime.mqh). Since EvaluateCompiledPlan() is never called, plan_mode=HYBRID has zero effect on any calculation.

### J4. Does sweep_detector have any residual execution path?

**NO.** sweep_detector trigger evaluation is gated behind EvaluateCompiledPlan() exclusively. The code is compiled and loaded into memory but execution cannot be reached from the COUNCIL routing branch.

---

## K. Reload Safety Reassessment

| Question | Answer |
|---|---|
| Is reload still allowed? | **YES** — the legacy surfaces are diagnostic; COUNCIL mode is confirmed active |
| Is BTCUSD sanity still valid? | **YES** — council pipeline is the active execution authority |
| Is there hidden old-path dominance? | **NO** — proven: decision_engine_mode=COUNCIL in authoritative plan JSON |
| Is a blocker present before U-02? | **NO** — no new blocker introduced by legacy surfaces |
| Is a Codex cleanup required before reload? | **NO** — no safety issue; cleanup is optional governance |

**BTCUSD reload sanity:**
The post-Codex binary (timestamp 2026-05-10 00:39:43) runs COUNCIL mode exclusively. All IRREW flags remain default=false. The legacy plan surfaces visible in the log are artifacts of startup diagnostics only. No legacy path gates any trade decision.

---

## L. Blocking Findings

**NO BLOCKING FINDINGS.**

None of the observed legacy surfaces create a blocking condition, authority leakage, or No-Score regression. The runtime is operating correctly in COUNCIL mode.

**Non-blocking observations (governance recommendations only):**
1. The plan JSON (plan_v076) retains many legacy fields (score thresholds, sweep_detector trigger, plan_mode, execution_archetype) that are dead weight in COUNCIL mode. These generate confusing log output but are inert.
2. The log line at L10699 shows BOTH plan_mode AND decision_engine_mode — if only plan_mode was captured, the report would appear to show HYBRID mode when decision_engine_mode=COUNCIL is also present.
3. "Strategies loaded: 6" will always appear alongside council execution — there is no log line saying "Council strategies: 18" in the standard Experts log.

---

## M. Required Codex Fixes

**NO CODEX FIX REQUIRED FOR SAFETY.**

**Optional governance cleanup (not safety-critical):**

| ID | Recommendation | Priority | Type |
|---|---|---|---|
| OPT-01 | Update ai_current_plan.json to remove legacy fields (score thresholds, sweep_detector, plan_mode, entry patterns, risk models list) that are inert in COUNCIL mode — reduces log confusion | LOW | JSON data edit (no source change, no compile) |
| OPT-02 | Add a log line explicitly stating "Decision routing: COUNCIL" to disambiguate from plan_mode label | LOW | Source change — defer until next Codex package |
| OPT-03 | Replace personality profile (ai_personality_profile.json) with COUNCIL/IRREW-aligned description if AI advisory is used — current profile references "Bollinger Scalper" which predates the council architecture | LOW | JSON data edit — evaluate during PAC |

**No OPT item is a safety requirement before reload or XAUUSD validation.**

---

## N. Final Judgment

```
AUDIT_ID:                    LEGACY_SCORE_HYBRID_RUNTIME_SURFACE_AUDIT_V1
DATE:                        2026-05-10
FINAL_VERDICT:               LEGACY_SURFACE_ACTIVE_BUT_GOVERNED

INTERPRETATION:
  The legacy plan fields (plan_v076, plan_mode=HYBRID, score thresholds 0.75/0.45,
  sweep_detector trigger, personality, archetype, library counts) are LOADED and ACTIVE
  in the sense that:
    - The plan JSON is the authoritative configuration source
    - Library initialization runs at startup
    - Personality injects into AI prompts

  But they are GOVERNED because:
    - decision_engine_mode=COUNCIL in ai_current_plan.json directs all routing to RunCouncilModePipeline()
    - EvaluateCompiledPlan() (containing all legacy score gates and trigger evaluation) is NEVER called
    - No legacy score threshold is compared against any signal
    - sweep_detector trigger detection is NEVER invoked
    - plan_mode=HYBRID score cap adjustments NEVER execute
    - The No-Score hard-lock (L10903-10976) is a separate, independently confirmed surface

COUNCIL_MODE_CONFIRMED:      YES — decision_engine_mode=COUNCIL in ai_current_plan.json
LEGACY_SCORE_ACTIVE:         NO — unreachable in COUNCIL mode; log values are metadata only
SWEEP_DETECTOR_ACTIVE:       NO — unreachable in COUNCIL mode
PLAN_MODE_HYBRID_ROUTING:    NO — plan_mode ≠ decision_engine_mode; routing by decision_engine_mode=COUNCIL
NO_SCORE_BYPASSED:           NO — DQ hard-lock intact; legacy score path unreachable
AUTHORITY_CONFLICT:          NONE FOUND
BLOCKER_PRESENT:             NONE
RELOAD_AUTHORIZED:           YES (prior authorization from forensic review stands)
CODEX_FIX_REQUIRED:          NO (optional cleanup only)
SYSTEM_STATUS:               DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING (unchanged)
PRODUCTION_READY:            FALSE (unchanged)
SOURCE_CHANGED:              NO
COMPILE_RUN:                 NO
MT5_RELOAD:                  NO CHANGE TO PRIOR AUTHORIZATION
```

---

## Evidence Classification

| Claim | Classification |
|---|---|
| decision_engine_mode=COUNCIL in ai_current_plan.json | VERIFIED — directly read from authoritative JSON file |
| plan_mode ≠ decision_engine_mode (different fields) | VERIFIED — struct definitions confirmed in config_loader.mqh, strategy_compiler.mqh |
| EvaluateCompiledPlan() only runs for GATE/SCORE/HYBRID | VERIFIED — decision_mode_router.mqh:L118 directly read |
| LogPlanArchitectureSummary() is pure logging | VERIFIED — main_ea.mq5:L10676-10695; only LogInfo() calls |
| Score thresholds (0.75/0.45) enforced inside EvaluateCompiledPlan() only | VERIFIED — strategy_runtime.mqh:L1519,1536-1542 (agent read) |
| sweep_detector evaluation inside EvaluateCompiledPlan() only | VERIFIED — strategy_runtime.mqh:L728 (agent read) |
| "Strategies loaded: 6" = legacy library count | VERIFIED — main_ea.mq5:L13373; gStrategyCount from BuildStrategyLibrary() |
| Council 18-strategy count | SOURCE_VERIFIED — COUNCIL_MAX_STRATEGIES=18 compile-time constant |
| Personality active in AI prompts only | VERIFIED — ai_bridge.mqh BuildAISystemPrompt() injection |
| No-Score hard-lock intact | VERIFIED — confirmed in prior forensic review; not touched by this session |
```
