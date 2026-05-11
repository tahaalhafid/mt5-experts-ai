# DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1

**Verdict:** `PACKAGE_B_READY_BUT_STUB_REQUIRED`
**Date:** 2026-05-11
**Scope:** Deep spider-web / matrix-style dependency investigation — READ-ONLY; no source changes, no compile, no runtime modification
**Authority:** MT5 remains runtime authority; this is a design review document only

---

## A. Executive Summary

This review was commissioned to determine the precise dependency web surrounding `EvaluateCompiledPlan()`, Zone 2 in `strategy_runtime.mqh`, and the legacy GATE/SCORE/HYBRID router branches. The root question: can Zone 2 be safely isolated via the existing `STRATEGY_RUNTIME_DISABLE_ZONE2` compile guard?

**Core finding:** Activating `STRATEGY_RUNTIME_DISABLE_ZONE2` alone causes a compile error because `decision_mode_router.mqh` calls `EvaluateCompiledPlan()` at lines 120 and 177 with no guard. The function definition lives inside Zone 2-B (line 1595, inside `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2`). Activating the guard removes the definition but not the call sites — compile fails.

**Solution path:** The safest fix is a minimal stub — add `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2` immediately after line 1627 in `strategy_runtime.mqh`, providing a stub `EvaluateCompiledPlan()` body that sets `eval.decision = RUNTIME_REJECT` and a reason string. This touches only **one file**, preserves all COUNCIL runtime behavior unchanged, and makes the compile guard complete and safe.

**Recommended Package B design:** `PACKAGE_B_STUB_EVALUATECOMPILEDPLAN` — define at `strategy_runtime.mqh:3`, stub at `strategy_runtime.mqh:1628–1637` (immediately after Zone 2-B `#endif`). Compile verification is mandatory before any reload.

---

## B. Scope and Methodology

**Files examined (source-read):**
- `decision_mode_router.mqh` (200 lines — full read)
- `strategy_runtime.mqh` (1628 lines — targeted zone reads: L1–10, L270–290, L560–730, L1590–1628)
- `main_ea.mq5` (key sections: L9330–9355, L3340–3360, L14365–14380)
- `council_pre_ai_gate.mqh` (283 lines — full read)
- `council_governor.mqh` (145 lines — full read)
- `authority_stack_pilot.mqh` (323 lines — full read)
- `LEGACY_CLEANUP_AUDIT_CODEX_CONFIRMATION_ONLY_V1.md` (full read — Codex confirmation of prior audit)
- `LEGACY_SURFACE_DEAD_CODE_AND_OBSOLETE_FIELD_CLEANUP_AUDIT_V1.md` (reference)

**Search methodology:**
- `rg EvaluateCompiledPlan` across all `.mq5`/`.mqh` to confirm exhaustive call site inventory
- `rg EvaluateDecisionModeRouted` across all `.mq5`/`.mqh` to confirm router entry point
- `rg "#include.*council_pre_ai_gate"` to confirm include topology
- `rg "#include.*council_governor"` to confirm include topology
- Zone boundary line confirmation via targeted reads

**Constraints:** No source changes. No compile run. No runtime file modification. Read-only research only.

---

## C. 20 Architecture Questions — Answered

**Q1. What is the exact call graph for EvaluateCompiledPlan()?**

```
EvaluateCompiledPlan() defined at strategy_runtime.mqh:1595
  ← called by decision_mode_router.mqh:120 (GATE/SCORE/HYBRID branch, unconditional)
  ← called by decision_mode_router.mqh:177 (fallback branch, unconditional)
  No other callers confirmed by exhaustive rg search across all .mq5/.mqh
```

**Q2. Is EvaluateCompiledPlan() called from anywhere other than decision_mode_router.mqh?**

No. `rg` search confirmed only two call sites, both in `decision_mode_router.mqh`. No call site exists in `council_mode_runtime.mqh`, `council_strategies.mqh`, `council_aggregator.mqh`, `council_pre_ai_filter.mqh`, `council_ai_governor.mqh`, `core_trade_engine.mqh`, `main_ea.mq5`, or any other file.

**Q3. What guard (if any) wraps the EvaluateCompiledPlan() calls in decision_mode_router.mqh?**

None. Both call sites are unconditionally compiled:
- Line 120: inside `if(mode == "GATE" || mode == "SCORE" || mode == "HYBRID")` — a runtime branch condition, not a compile guard
- Line 177: inside the else-fallback block — also a runtime branch condition, not a compile guard

Neither call site has any `#ifndef`, `#ifdef`, or `#if defined()` compile directive wrapping it.

**Q4. What is the exact Zone 2-A and Zone 2-B line range in strategy_runtime.mqh?**

| Zone | Start | End | Guard |
|---|---|---|---|
| Zone 2-A | L279 (`#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2`) | L564 (`#endif`) | `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` |
| Zone 1 Trigger Island | L567 | L713 | NONE — unconditionally compiled |
| Zone 2-B | L722 (`#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2`) | L1627 (`#endif`) | `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` |

Note: Zone 1 Trigger Island (L567–713) sits between Zone 2-A and Zone 2-B end marks. It is NOT inside either guard.

**Q5. What Zone 1 functions are outside the DISABLE_ZONE2 guard?**

| Function | Line | Guard | Called From |
|---|---|---|---|
| `DetectBollingerReclaimTrigger()` | L572 | NONE | `council_strategies.mqh:915` |
| `DetectSweepDetectorTrigger()` | L616 | NONE | `council_strategies.mqh:810` |
| `DetectEMATrendAlignmentTrigger()` | ~L650+ | NONE | `council_strategies.mqh` (confirmed live caller) |

These are live COUNCIL pipeline functions. They must remain unconditionally compiled.

**Q6. Are Zone 1 Trigger Island functions called by any COUNCIL pipeline component?**

Yes. `DetectBollingerReclaimTrigger()` is called at `council_strategies.mqh:915` and `DetectSweepDetectorTrigger()` at `council_strategies.mqh:810`. These are active COUNCIL execution paths. Any define that accidentally guards these functions would break the COUNCIL pipeline.

Confirmed: The Zone 1 Trigger Island (L567–713) is correctly placed OUTSIDE both Zone 2 guards and must remain so.

**Q7. What does EvaluateDecisionModeRoutedEx() do when mode=COUNCIL?**

At `decision_mode_router.mqh:133–172`, the COUNCIL branch:
1. Calls `RunCouncilModePipeline(plan, m1, m5, routed.council)` — the full council evaluation
2. Derives `routed.base_eval.decision` from `routed.council.filtered_decision`
3. Derives `routed.base_eval.reason` from council result
4. Sets `routed.active_mode = "COUNCIL"`
5. Sets `routed.valid = true`

The COUNCIL branch does NOT call `EvaluateCompiledPlan()` at any point.

**Q8. What does EvaluateDecisionModeRoutedEx() do when mode=GATE/SCORE/HYBRID?**

At `decision_mode_router.mqh:118–128`:
```mql5
if(mode == "GATE" || mode == "SCORE" || mode == "HYBRID")
{
   EvaluateCompiledPlan(plan, m1, m5, routed.base_eval);   // line 120 — UNGUARDED
   routed.active_mode = mode;
   routed.valid = true;
   ...
}
```
This branch is runtime-dead in COUNCIL-only production configuration. It is compile-linked, not compile-guarded.

**Q9. Is the router fallback branch (L174) ever reached in COUNCIL-only config?**

No. The fallback at L174–183 is reached only when mode does not match GATE, SCORE, HYBRID, or COUNCIL. The normalizer `NormalizeDecisionEngineModeEx()` at L37–54 converts any unknown mode string to "HYBRID" before `EvaluateDecisionModeRoutedEx()` is called. In production, `ai_current_plan.json` sets `decision_engine_mode = "COUNCIL"`. The fallback is a defensive artifact that cannot be reached under current configuration. It is nevertheless compile-linked and contains an unguarded `EvaluateCompiledPlan()` call at L177.

**Q10. Where is decision_engine_mode set, and what value does it hold in production?**

- Source: `ai_current_plan.json` field `"decision_engine_mode"`
- Loaded at `main_ea.mq5:9341` via `ExtractJsonStringField(planJson, "decision_engine_mode", decisionMode)`
- Stored in `gPlan.decision_engine_mode`
- Normalized at `main_ea.mq5:3346` via `NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode)`
- Production value: `"COUNCIL"` — confirmed by PIML and all prior audits
- Consequence: only the COUNCIL branch in `EvaluateDecisionModeRoutedEx()` executes at runtime

**Q11. Where should STRATEGY_RUNTIME_DISABLE_ZONE2 be defined if authorized?**

`strategy_runtime.mqh:3`, immediately after the include guard define:
```mql5
// Line 1: #ifndef __STRATEGY_RUNTIME_MQH__
// Line 2: #define __STRATEGY_RUNTIME_MQH__
// Line 3: #define STRATEGY_RUNTIME_DISABLE_ZONE2   ← recommended placement
```
This ensures the define is active for the entire file before any Zone 2-A or Zone 2-B guard is evaluated. Placing it here rather than in `main_ea.mq5` scopes the define to `strategy_runtime.mqh` specifically.

**Q12. Does activating STRATEGY_RUNTIME_DISABLE_ZONE2 alone compile cleanly?**

No. Adding only the `#define` at L3 would:
1. Exclude Zone 2-A (L279–564) — safe, no live callers
2. Exclude Zone 2-B (L722–1627) including `EvaluateCompiledPlan()` definition
3. Leave `decision_mode_router.mqh:120` and `decision_mode_router.mqh:177` with unresolved function references
4. Result: compile error — undefined function `EvaluateCompiledPlan`

The define alone is NOT compile-safe without a stub or router guard.

**Q13. What are the two compile-safe options for Package B?**

Option 1 — **Stub approach** (recommended):
Add `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2` stub after Zone 2-B `#endif` at strategy_runtime.mqh:1627. Stub provides a minimal `EvaluateCompiledPlan()` body returning RUNTIME_REJECT. One file modified: `strategy_runtime.mqh` only.

Option 2 — **Router guard approach**:
Wrap `decision_mode_router.mqh:118–128` and `decision_mode_router.mqh:174–183` in `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2`, with deterministic return values when guarded. Two files modified: `strategy_runtime.mqh` (define) + `decision_mode_router.mqh` (guards).

**Q14. Which files would the stub approach modify?**

One file only: `strategy_runtime.mqh` — adding the `#define` at L3 and the stub block after L1627.

The router (`decision_mode_router.mqh`) remains completely unchanged. The stub satisfies the linker reference without altering any routing logic.

**Q15. Which files would the router-guard approach modify?**

Two files: `strategy_runtime.mqh` (define at L3) + `decision_mode_router.mqh` (guard wrapping L118–128 and L174–183). The router guard approach requires deciding what value the guarded branches return — this alters non-COUNCIL compatibility semantics, requiring operator authorization for fallback behavior.

**Q16. What is the stub's required signature for EvaluateCompiledPlan()?**

Must exactly match the existing call sites' argument types:
```mql5
#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2
void EvaluateCompiledPlan(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   eval.decision = RUNTIME_REJECT;
   eval.reason = "Zone2 disabled — COUNCIL-only build";
}
#endif
```
The types `CompiledPlan`, `TimeframeSnapshot`, and `RuntimeEvaluation` are defined in Zone 1 base (L1–269) and remain unconditionally compiled. The enum value `RUNTIME_REJECT` is also in Zone 1 base. No missing types.

**Q17. Are council_pre_ai_gate.mqh and council_governor.mqh in the compile unit?**

No. Exhaustive `rg` search found no `#include "council_pre_ai_gate.mqh"` or `#include "council_governor.mqh"` in any `.mq5` or `.mqh` file. Neither file appeared in the latest compile log. These files exist as source documents but are not part of the compilation unit. Prior audit claim ("compiled into binary") was CONTRADICTED by Codex confirmation.

Impact for Package B: These files are irrelevant to the Zone 2 isolation problem. They do not call `EvaluateCompiledPlan()` and are not part of the dependency chain.

**Q18. Does Zone 2 contain any types or structs used by Zone 1 or COUNCIL pipeline?**

No. Type and struct definitions are in Zone 1 base (L1–269), unconditionally compiled:
- `RuntimeDecision` enum (L1 base)
- `RuntimeEvaluation` struct (L1 base)
- `TriggerResult` struct (L1 base)
- `CompiledPlan` defined elsewhere (included before strategy_runtime.mqh)
- `TimeframeSnapshot` defined elsewhere

Zone 2-A and Zone 2-B contain only functions (plan adjusters, score discipline, evaluation engine). Excluding them does not remove any type that Zone 1 or COUNCIL pipeline needs.

**Q19. Is the HYBRID fallback behavior in the router safety-critical for non-COUNCIL configs?**

Yes — for non-COUNCIL deployments. The normalizer converts unknown modes to "HYBRID" (a documented defensive behavior at `decision_mode_router.mqh:37–53`). The fallback at L174–183 handles any further unexpected mode. In COUNCIL-only production, neither matters at runtime. However, removing or guarding the fallback changes non-COUNCIL defensive semantics and must not be done casually. The stub approach avoids touching the router entirely, preserving full non-COUNCIL compatibility.

**Q20. What is the definitive recommended Package B implementation path?**

`PACKAGE_B_STUB_EVALUATECOMPILEDPLAN` — single-file change to `strategy_runtime.mqh`:
1. Add `#define STRATEGY_RUNTIME_DISABLE_ZONE2` at L3
2. Add stub `EvaluateCompiledPlan()` under `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2` after L1627
3. Verify compile: 0 errors, 0 warnings
4. Runtime: COUNCIL path unchanged; stub is compile-linked but never executed at runtime
5. Do not modify `decision_mode_router.mqh`

---

## D. Matrix A — EvaluateCompiledPlan() Call Site Inventory

| # | File | Line | Context | Compile Guard | Runtime Reached (COUNCIL)? | Compile Linked? |
|---|---|---|---|---|---|---|
| 1 | `strategy_runtime.mqh` | 1595 | Function **definition** | `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` (Zone 2-B) | N/A | YES (currently) |
| 2 | `decision_mode_router.mqh` | 120 | GATE/SCORE/HYBRID branch | NONE | NO | YES |
| 3 | `decision_mode_router.mqh` | 177 | Fallback/unknown-mode branch | NONE | NO | YES |

**Total call sites: 2 (both in decision_mode_router.mqh, both unguarded)**
**Total definitions: 1 (in strategy_runtime.mqh Zone 2-B, inside DISABLE_ZONE2 guard)**

**Risk if define activated alone:** Both call sites at rows 2–3 would fail to resolve → compile error.
**Stub resolves:** Adds a guarded definition at row-equivalent position (after L1627) under `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2` — rows 2–3 resolve to stub, compile succeeds.

---

## E. Matrix B — Zone 2 Internal Function and Type Dependency

| Component | Zone | Lines | Guard | Called By (in COUNCIL pipeline)? | Safe to Exclude? |
|---|---|---|---|---|---|
| Plan adjuster helpers | 2-A | L279–564 | `#ifndef DISABLE_ZONE2` | NO | YES |
| `DetectBollingerReclaimTrigger()` | Zone 1 Trigger Island | L572 | NONE | YES — `council_strategies.mqh:915` | NO — must remain |
| `DetectSweepDetectorTrigger()` | Zone 1 Trigger Island | L616 | NONE | YES — `council_strategies.mqh:810` | NO — must remain |
| `DetectEMATrendAlignmentTrigger()` | Zone 1 Trigger Island | L650+ | NONE | YES — `council_strategies.mqh` | NO — must remain |
| Score discipline helpers | 2-B | L722–1594 | `#ifndef DISABLE_ZONE2` | NO | YES |
| `EvaluateCompiledPlan()` | 2-B | L1595–1625 | `#ifndef DISABLE_ZONE2` | NO (router only, non-COUNCIL) | YES (with stub) |
| `EvaluateByGateMode()` | 2-B | inside 2-B | `#ifndef DISABLE_ZONE2` | NO | YES |
| `EvaluateByScoreMode()` | 2-B | inside 2-B | `#ifndef DISABLE_ZONE2` | NO | YES |
| `EvaluateByHybridMode()` | 2-B | inside 2-B | `#ifndef DISABLE_ZONE2` | NO | YES |
| Zone 1 base types/structs | Zone 1 base | L1–269 | NONE | YES — used everywhere | NO — must remain |

**Key insight:** Zone 1 Trigger Island (L567–713) must remain unconditionally compiled. Zone 2-A and Zone 2-B can be excluded without breaking the COUNCIL pipeline. The only bridge dependency is the linker reference to `EvaluateCompiledPlan()` from the router — resolved by stub.

---

## F. Matrix C — Router Branch → Dependency and Runtime Status

| Branch | Condition in Code | Router Lines | Calls | Runtime Active (COUNCIL)? | Compile-Linked? | Notes |
|---|---|---|---|---|---|---|
| GATE branch | `mode == "GATE"` | 118–120 | `EvaluateCompiledPlan()` | NO | YES | Unguarded call |
| SCORE branch | `mode == "SCORE"` | 118–120 | `EvaluateCompiledPlan()` | NO | YES | Same condition block |
| HYBRID branch | `mode == "HYBRID"` | 118–120 | `EvaluateCompiledPlan()` | NO | YES | Same condition block |
| COUNCIL branch | `mode == "COUNCIL"` | 133–172 | `RunCouncilModePipeline()` | YES | YES | Only active path |
| Fallback branch | else (none matched) | 174–183 | `EvaluateCompiledPlan()` | NO | YES | Normalization prevents; unguarded |
| Mode normalization | Pre-call in main_ea | 3346 | `NormalizeDecisionEngineModeEx()` | YES | YES | Converts unknown→"HYBRID" |

**Critical observation:** The COUNCIL branch (rows 5) is the only runtime-active branch. All four other branches containing `EvaluateCompiledPlan()` calls are runtime-dead in COUNCIL-only production. Yet all four are compile-linked and unguarded.

---

## G. Matrix D — File-Level Include Topology (Relevant Subset)

| File | Includes | Included By | In Compile Unit? | Notes |
|---|---|---|---|---|
| `strategy_runtime.mqh` | `council_mode_types.mqh` (possibly others) | `decision_mode_router.mqh` | YES | Contains Zone 1, 2-A, 2-B, EvaluateCompiledPlan |
| `decision_mode_router.mqh` | `strategy_runtime.mqh`, `council_mode_types.mqh`, `council_mode_runtime.mqh`, `council_adaptive_weights.mqh` | `main_ea.mq5` (via chain) | YES | Contains unguarded call sites |
| `council_mode_runtime.mqh` | (council sub-files) | `decision_mode_router.mqh` | YES | Contains RunCouncilModePipeline — active |
| `council_strategies.mqh` | (strategy headers) | chain | YES | Calls Zone 1 Trigger Island functions |
| `council_pre_ai_gate.mqh` | (unknown) | **NOTHING** | NO | No `#include` found; not in compile log |
| `council_governor.mqh` | (unknown) | **NOTHING** | NO | No `#include` found; not in compile log |
| `main_ea.mq5` | (full chain) | — | YES (root) | Single EA entry file |

**Confirmed:** `council_pre_ai_gate.mqh` and `council_governor.mqh` are NOT in the compilation unit. They have no impact on Package B and do not call `EvaluateCompiledPlan()`.

---

## H. Matrix E — Runtime vs Compile Status by Component (COUNCIL-Only Production)

| Component | Compile-Linked? | Runtime-Reached (COUNCIL)? | Removal Safe? | Notes |
|---|---|---|---|---|
| Zone 1 base (L1–269) | YES | YES | NO | Types, structs, enums — live |
| Zone 2-A plan adjusters (L279–564) | YES | NO | YES (with guard) | No COUNCIL caller |
| Zone 1 Trigger Island (L567–713) | YES | YES | NO | DetectBollingerReclaim, DetectSweepDetector, DetectEMATrend — live |
| Zone 2-B score/eval helpers (L722–1594) | YES | NO | YES (with guard) | No COUNCIL caller |
| `EvaluateCompiledPlan()` definition (L1595–1625) | YES | NO | YES (replace with stub) | Only router calls it; router branch never taken |
| Router GATE/SCORE/HYBRID branch (L118–128) | YES | NO | NO (preserve for non-COUNCIL compat) | Compile-linked; runtime-dead in COUNCIL |
| Router COUNCIL branch (L133–172) | YES | YES | NO | Active — must remain |
| Router normalization (L37–54) | YES | YES | NO | Active — converts unknown→HYBRID |
| Router fallback (L174–183) | YES | NO | NO (preserve for non-COUNCIL compat) | Dead in COUNCIL; normalization prevents reaching |
| `RunCouncilModePipeline()` | YES | YES | NO | Active council pipeline entry |
| `council_pre_ai_gate.mqh` contents | NO | NO | YES (not compiled) | Already outside compile unit |
| `council_governor.mqh` contents | NO | NO | YES (not compiled) | Already outside compile unit |
| DQ block logic (authority_stack_pilot) | YES | YES (diagnostic) | NO | Hard-forced false; V1/P4 active |

---

## I. Five Cleanup Options Evaluated

### Option 1: DEFER_PACKAGE_B_KEEP_ZONE2_COMPILED

**Description:** Do nothing. Leave Zone 2 compiled, no define, no stub, no router changes.

**Pros:**
- Zero risk — no file changes, no compile needed
- COUNCIL pipeline unaffected (already true)
- Non-COUNCIL compatibility fully preserved

**Cons:**
- Zone 2 compilation overhead retained (1627 lines compile even though runtime-dead)
- Technical debt remains documented but unresolved
- Misleading: Zone 2 is compiled but never reached — source is deceptive to future readers

**Verdict:** Safe but wasteful. Acceptable as a permanent decision only if compile time is irrelevant and clarity is not a priority. Not recommended when a clean stub path exists.

---

### Option 2: PACKAGE_B_STUB_EVALUATECOMPILEDPLAN ← RECOMMENDED

**Description:** Add `#define STRATEGY_RUNTIME_DISABLE_ZONE2` at `strategy_runtime.mqh:3`. Add stub `EvaluateCompiledPlan()` under `#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2` immediately after line 1627 (the Zone 2-B closing `#endif`).

**Stub body:**
```mql5
#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2
void EvaluateCompiledPlan(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   eval.decision = RUNTIME_REJECT;
   eval.reason = "Zone2 disabled — COUNCIL-only build";
}
#endif
```

**Pros:**
- Single file change (`strategy_runtime.mqh` only)
- Router (`decision_mode_router.mqh`) unchanged — full non-COUNCIL compatibility preserved
- COUNCIL runtime path entirely unaffected
- Stub body is deterministic and explicit — no silent failure
- Stub type requirements (`CompiledPlan`, `TimeframeSnapshot`, `RuntimeEvaluation`, `RUNTIME_REJECT`) are all in Zone 1 base — always compiled — no missing types
- Compile verification trivially validates correctness
- Zone 1 Trigger Island (L567–713) remains unconditionally compiled — no disruption to COUNCIL pipeline

**Cons:**
- Stub adds ~10 lines; Zone 2-A/2-B excluded but stub persists in compile unit (~10 lines vs ~1348 lines excluded — net benefit clear)
- Non-COUNCIL operators who somehow hit GATE/SCORE/HYBRID would now get RUNTIME_REJECT instead of full evaluation — but this is a deliberate, documented design decision

**Risk:** None in COUNCIL-only deployment. If non-COUNCIL mode is ever needed, stub must be removed or guarded first — but this is documented and manageable.

**Verdict:** RECOMMENDED. Minimum change, maximum clarity, compile-safe.

---

### Option 3: PACKAGE_B_GUARD_ROUTER_LEGACY_BRANCHES

**Description:** Add `#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2` guards around `decision_mode_router.mqh:118–128` and `decision_mode_router.mqh:174–183`, with explicit fallback result values when guarded (e.g., return RUNTIME_REJECT or RUNTIME_WAIT).

**Pros:**
- Makes the router explicitly COUNCIL-aware
- Documents the GATE/SCORE/HYBRID branches as guarded legacy

**Cons:**
- Modifies TWO files (`strategy_runtime.mqh` + `decision_mode_router.mqh`)
- Requires a policy decision on what the guarded branches return — this changes non-COUNCIL compatibility behavior and needs operator authorization for the fallback semantics
- Router changes are higher-risk than stub changes (router is called from main_ea.mq5)
- More code to verify, more compile surface

**Verdict:** Technically valid but unnecessarily broad. The stub approach achieves the same compile safety with fewer files modified and no router semantics change. Only recommend if the stub approach is later found problematic.

---

### Option 4: PACKAGE_B_DISABLE_LEGACY_MODES_EXPLICITLY

**Description:** Add explicit mode pre-checks in `EvaluateDecisionModeRoutedEx()` to early-return RUNTIME_REJECT when mode == "GATE", "SCORE", or "HYBRID", preventing any path to `EvaluateCompiledPlan()`. Separate from or combined with the define.

**Pros:**
- Makes runtime rejection of legacy modes explicit in code
- Does not require the define at all

**Cons:**
- Router behavior change — non-COUNCIL modes that previously evaluated now get explicit REJECT
- Does not exclude Zone 2 from compilation (compile overhead unchanged unless define also added)
- Two concerns conflated: compile isolation (define) vs runtime behavior (explicit reject)
- More invasive change than a stub

**Verdict:** Not recommended as Package B. This conflates compile-time isolation with runtime mode enforcement. These are separate concerns. If runtime explicit rejection of legacy modes is desired, it should be a separate bounded task after Zone 2 isolation is complete.

---

### Option 5: PACKAGE_B_REMOVE_NOT_RECOMMENDED

**Description:** Delete Zone 2-A and Zone 2-B source code entirely (not just guard them).

**Pros:**
- Complete elimination of dead code from source

**Cons:**
- Destructive — cannot be undone without git revert
- Eliminates non-COUNCIL recovery path permanently
- Requires router changes too (calls to removed function)
- Not consistent with COUNCIL-first but non-COUNCIL-available design intent
- Highest risk, lowest reversibility
- Prior cleanup audit explicitly classified this as "DEFER/QUARANTINE" not "REMOVE_NOW"

**Verdict:** NOT recommended. Zone 2 is a quarantine target (compile-excluded, source-preserved), not a deletion target.

---

## J. Revised Package B Design

### Package B Identity

```
PACKAGE_ID:              ZONE2_COMPILE_ISOLATION_V1
PACKAGE_TYPE:            Compile isolation via define + stub
APPROACH:                PACKAGE_B_STUB_EVALUATECOMPILEDPLAN
FILES_MODIFIED:          strategy_runtime.mqh ONLY
COMPILE_REQUIRED:        YES — mandatory before reload
RELOAD_REQUIRED:         YES — after compile verification
```

### Exact Changes Required

**Change 1: Define placement**

File: `strategy_runtime.mqh`
Location: Line 3 (immediately after the include guard define)

Before (L1–4 as-is):
```mql5
#ifndef __STRATEGY_RUNTIME_MQH__
#define __STRATEGY_RUNTIME_MQH__
// (next content line)
```

After:
```mql5
#ifndef __STRATEGY_RUNTIME_MQH__
#define __STRATEGY_RUNTIME_MQH__
#define STRATEGY_RUNTIME_DISABLE_ZONE2
// (next content line)
```

**Change 2: Stub addition**

File: `strategy_runtime.mqh`
Location: After line 1627 (immediately after the Zone 2-B closing `#endif // STRATEGY_RUNTIME_DISABLE_ZONE2`)

Add:
```mql5
#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2
void EvaluateCompiledPlan(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   eval.decision = RUNTIME_REJECT;
   eval.reason = "Zone2 disabled — COUNCIL-only build";
}
#endif // STRATEGY_RUNTIME_DISABLE_ZONE2 (stub)
```

**File L1627 context (as-is):**
```
L1627: #endif // STRATEGY_RUNTIME_DISABLE_ZONE2
L1628: #endif // __STRATEGY_RUNTIME_MQH__
```

**File L1627 context (after change):**
```
L1627: #endif // STRATEGY_RUNTIME_DISABLE_ZONE2
[NEW]  #ifdef STRATEGY_RUNTIME_DISABLE_ZONE2
[NEW]  void EvaluateCompiledPlan(
[NEW]     CompiledPlan &plan,
[NEW]     TimeframeSnapshot &m1,
[NEW]     TimeframeSnapshot &m5,
[NEW]     RuntimeEvaluation &eval
[NEW]  )
[NEW]  {
[NEW]     eval.decision = RUNTIME_REJECT;
[NEW]     eval.reason = "Zone2 disabled — COUNCIL-only build";
[NEW]  }
[NEW]  #endif // STRATEGY_RUNTIME_DISABLE_ZONE2 (stub)
L1628: #endif // __STRATEGY_RUNTIME_MQH__
```

### Pre-Conditions for Authorization

| Pre-condition | Status |
|---|---|
| EvaluateCompiledPlan call sites confirmed (L120, L177) | CONFIRMED |
| Zone 1 Trigger Island outside Zone 2 guards confirmed | CONFIRMED |
| No other EvaluateCompiledPlan callers (exhaustive rg) | CONFIRMED |
| Stub type requirements in Zone 1 base (always compiled) | CONFIRMED |
| COUNCIL pipeline does not call EvaluateCompiledPlan | CONFIRMED |
| No defines or stubs in router required | CONFIRMED |
| Operator authorization to proceed | PENDING |
| Backup before implementation | PENDING |

### Post-Implementation Verification Protocol

1. Open MetaEditor → compile `main_ea.mq5`
2. Verify: 0 errors, 0 warnings
3. Verify binary timestamp updated
4. Reload EA in terminal
5. Confirm in Experts log: no errors on attach, no strategy failures
6. Confirm in `mt5_io_reduction_status.json`: `buffered_records_total > 0` (Package A still active)
7. Confirm in opportunity ledger (if live): records continue to produce

---

## K. Codex Package Specification

```
CODEX_PACKAGE_ID:        ZONE2_COMPILE_ISOLATION_V1
TASK_TYPE:               Source modification — compile isolation define + stub
STATUS:                  DESIGN_COMPLETE — AWAITING_OPERATOR_AUTHORIZATION
AUTHORIZED:              NO — pending operator sign-off
```

### Codex Task Brief (ready to issue when authorized)

**Objective:** Isolate Zone 2 in `strategy_runtime.mqh` from the active compile unit via the existing `STRATEGY_RUNTIME_DISABLE_ZONE2` guard mechanism. Add a minimal stub for `EvaluateCompiledPlan()` to resolve linker references in `decision_mode_router.mqh`.

**File to modify:** `strategy_runtime.mqh` only.

**Change 1:** Insert `#define STRATEGY_RUNTIME_DISABLE_ZONE2` on a new line 3, immediately after `#define __STRATEGY_RUNTIME_MQH__` (line 2). Do not alter any surrounding content.

**Change 2:** Immediately after the existing line `#endif // STRATEGY_RUNTIME_DISABLE_ZONE2` (currently the Zone 2-B closing guard, currently line 1627), insert the following block exactly:
```mql5
#ifdef STRATEGY_RUNTIME_DISABLE_ZONE2
void EvaluateCompiledPlan(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   eval.decision = RUNTIME_REJECT;
   eval.reason = "Zone2 disabled — COUNCIL-only build";
}
#endif // STRATEGY_RUNTIME_DISABLE_ZONE2 (stub)
```

**Do NOT:** modify `decision_mode_router.mqh`, `main_ea.mq5`, `council_mode_runtime.mqh`, or any other file.

**Verify:** Compile `main_ea.mq5` in MetaEditor. Accept only: 0 errors, 0 warnings. Report compile result line count.

**Forbidden:** Do not delete any Zone 2 code. Do not modify Zone 1 (L1–269). Do not modify Zone 1 Trigger Island (L567–713). Do not modify Zone 2-A guard boundaries. Do not modify Zone 2-B guard boundaries. Do not add any logic to the stub beyond what is specified above.

---

## L. Risk Assessment

| Risk | Severity | Mitigation |
|---|---|---|
| Stub signature mismatch (type mismatch) | HIGH — compile error | Types `CompiledPlan`, `TimeframeSnapshot`, `RuntimeEvaluation`, `RUNTIME_REJECT` all confirmed in Zone 1 base (L1–269); always compiled; no missing types |
| Zone 1 Trigger Island accidentally guarded | HIGH — breaks COUNCIL | Trigger Island (L567–713) is OUTSIDE Zone 2 guards; stub is added AFTER L1627 (Zone 2-B close), not inside it; no change to guard boundaries |
| Router unintentionally modified | HIGH | Approach explicitly does NOT touch decision_mode_router.mqh |
| Non-COUNCIL mode now returns REJECT instead of evaluation | MEDIUM | Deliberate; COUNCIL-only production unaffected; document in PIML as intentional |
| Backup not taken before implementation | MEDIUM | Governed backup must be created before Codex execution |
| Compile verification skipped | HIGH | Mandatory: Codex spec requires 0 errors/0 warnings verification |
| Zone 2 code accidentally deleted | HIGH — irreversible | Codex spec explicitly forbids deletion; isolation is guard-only |

---

## M. PIML Implications

The following PIML anchor update is required after this review:

1. Add entry: `DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1 — COMPLETE — Verdict: PACKAGE_B_READY_BUT_STUB_REQUIRED — approach: stub EvaluateCompiledPlan in strategy_runtime.mqh only — router unchanged — Codex package design complete — AWAITING_OPERATOR_AUTHORIZATION`

2. Package B status update: From `PACKAGE_B_NEEDS_MORE_PROOF_AND_REVISED_SCOPE` to `PACKAGE_B_DESIGN_COMPLETE_STUB_APPROACH — AWAITING_OPERATOR_AUTHORIZATION`

3. No other PIML sections need modification from this review.

---

## N. Final Verdict

**`PACKAGE_B_READY_BUT_STUB_REQUIRED`**

Zone 2 isolation via `STRATEGY_RUNTIME_DISABLE_ZONE2` is architecturally sound but the existing define guard is incomplete without a stub. The stub approach (`PACKAGE_B_STUB_EVALUATECOMPILEDPLAN`) resolves the linker gap in a single file with zero impact to the COUNCIL runtime pipeline.

**Justification for this verdict vs alternatives:**

| Verdict Option | Selected? | Reason |
|---|---|---|
| `PACKAGE_B_REVISED_READY_FOR_CODEX` | NO | Not fully ready — operator authorization still required; backup not yet taken |
| `PACKAGE_B_DEFER_KEEP_ZONE2_COMPILED` | NO | Deferral is the safe-but-suboptimal choice; stub path is clean and low-risk |
| `PACKAGE_B_READY_BUT_STUB_REQUIRED` | **YES** | Design is complete; stub path is the required additional step; Codex spec is written; no blocking unknowns remain |
| `PACKAGE_B_READY_BUT_ROUTER_GUARD_REQUIRED` | NO | Router guard is a valid alternative but inferior (two files, semantics change) |
| `PACKAGE_B_BLOCKED_BY_COMPATIBILITY_RISK` | NO | Risk is managed by stub approach; no blocking compatibility issue remains |
| `PACKAGE_B_REVIEW_INCONCLUSIVE_NEEDS_MORE_SOURCE_READ` | NO | All required reads completed; dependency chain fully mapped |

**Immediate next step:** Operator authorization for `ZONE2_COMPILE_ISOLATION_V1` Codex task. Governed backup required immediately before Codex execution.

---

## O. Footer

```
REVIEW_ID:               DECISION_MODE_ROUTER_AND_ZONE2_DEPENDENCY_MATRIX_DEEP_REVIEW_V1
DATE:                    2026-05-11
VERDICT:                 PACKAGE_B_READY_BUT_STUB_REQUIRED
APPROACH_SELECTED:       PACKAGE_B_STUB_EVALUATECOMPILEDPLAN
FILES_TO_MODIFY:         strategy_runtime.mqh ONLY
FILES_EXAMINED:          decision_mode_router.mqh, strategy_runtime.mqh, main_ea.mq5,
                         council_pre_ai_gate.mqh, council_governor.mqh,
                         authority_stack_pilot.mqh,
                         LEGACY_CLEANUP_AUDIT_CODEX_CONFIRMATION_ONLY_V1.md
SOURCE_CHANGED:          NO
COMPILE_RUN:             NO
RUNTIME_FILES_MODIFIED:  NO
PIML_READ:               YES
PIML_UPDATE:             YES — see Section M
CODEX_PACKAGE_READY:     YES — see Section K
CODEX_AUTHORIZED:        NO — pending operator sign-off
BACKUP_REQUIRED:         YES — before Codex execution
NEXT_ACTION:             Operator authorization → governed backup → Codex ZONE2_COMPILE_ISOLATION_V1
PACKAGE_B_STATUS:        PACKAGE_B_DESIGN_COMPLETE_STUB_APPROACH — AWAITING_OPERATOR_AUTHORIZATION
PRIOR_STATUS:            PACKAGE_B_NEEDS_MORE_PROOF_AND_REVISED_SCOPE (from CODEX_CONFIRMATION_ONLY_V1)
ZONE1_TRIGGER_ISLAND:    CONFIRMED SAFE — L567-713 outside both Zone 2 guards — no change needed
ROUTER_FILES_TOUCHED:    NONE — decision_mode_router.mqh not modified by stub approach
```
