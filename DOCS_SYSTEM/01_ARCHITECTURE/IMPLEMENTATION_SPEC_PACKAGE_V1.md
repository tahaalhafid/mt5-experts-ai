# IMPLEMENTATION_SPEC_PACKAGE_V1

**Package type:** SPECIFICATION — Non-executed implementation design  
**Date:** 2026-05-08  
**Authority:** EVIDENCE_ONLY — No MT5 source change. No runtime change. No Nautilus change.  
**Follows:** ARCHITECTURE_BUILD_PACKAGE_V1.md → Candidates 1–5  
**System status:** DEVELOPING — unchanged  
**Runtime authority:** V1 (MT5 EA) — permanent; not transferred to any document or layer  

---

## 1. Executive Summary

This package is specification-only. It prepares five future Codex task candidates as bounded, Codex-ready implementation specifications.

It does not implement any code. It does not authorize runtime behavior. Every candidate in this document is marked NOT_AUTHORIZED_HERE and requires a separate operator authorization before execution.

The five candidates are:
1. OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 — new ledger fields for playbook/packet observation
2. PLAYBOOK_STATE_SHADOW_EMITTER_V1 — categorical playbook state assembly and write (observation only)
3. EVENT_ORDER_TRACE_FIELDS_V1 — event timestamp recording for EOC compliance
4. PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1 — diagnostic comparison of registry vs live behavior
5. RCEM_V1_DOCUMENTATION_UPDATE — PIML documentation of regime-conditioned design intent

This package follows:
- PIML governance rules (§16, §25, REG.1–REG.9)
- PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md (17 strategies, 3 playbooks, packet inventory)
- ARCHITECTURE_BUILD_PACKAGE_V1.md (Packages A–E, Event Order Contract, ledger alignment spec)

---

## 2. Source-of-Truth References Reviewed

| Reference | Purpose | Review Status |
|---|---|---|
| PROJECT_INTELLIGENCE_MEMORY_LAYER.md | Governance truth — phase status, architecture decisions, constraints | REVIEWED — §16, §22–29, REG.1–REG.9 |
| PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md | Packet and playbook working reference — 17 strategies, 3 playbooks | REVIEWED — all sections |
| ARCHITECTURE_BUILD_PACKAGE_V1.md | Design bridge — Packages A–E, Event Order Contract, ledger spec (§5) | REVIEWED — all sections |
| council_mode_types.mqh | Struct layout, existing types, insertion points | REVIEWED — tail section, struct list, OL_CrossFamilyEvidence definition |
| council_mode_runtime.mqh | WriteOpportunityLedgerRecord function (L562–693), call site (L1197–1222), RunCouncilModePipeline (L774), schema version (L587, L704) | REVIEWED — key sections |

**Source-of-truth hierarchy:**
- PIML is the governance truth source — any conflict between this spec and PIML, PIML governs
- Registry MD is the packet/playbook working reference — packet statuses here must not contradict registry
- Architecture Build Package is the design bridge — event order contract and ledger field specs from §5–6 of that document are incorporated here by reference
- This Implementation Spec Package is non-executed specification only

**Source files read for insertion-point accuracy (read-only; not modified):**
- `council_mode_types.mqh` — struct layout confirmed; `OL_CrossFamilyEvidence` is the last struct before `#endif`
- `council_mode_runtime.mqh` — `WriteOpportunityLedgerRecord` at L562; call site at L1213; current schema `"OL_V1B_CROSS_FAMILY"` at L587; summary schema `"OL_SUMMARY_V1B_CROSS_FAMILY"` at L704; `OL_ComputeCrossFamilyEvidence` at L1198; reporting loop L1200–1223

---

## 3. Governance Firewall

The following constraints are absolute for every candidate in this package. Any implementation derived from this spec that violates any item below must be halted and reviewed before continuing.

| Rule | Constraint |
|---|---|
| GFW-1 | No MT5 behavior change. All new code is instrumentation-only — write to ledger, never read by decision pipeline. |
| GFW-2 | No council_quality change. No new fields fed into the council_quality computation. |
| GFW-3 | No HIGH_CONVICTION change. Playbook state must never qualify or disqualify HIGH_CONVICTION consensus. |
| GFW-4 | No CRR / DSN gate change. No new gate conditions. No modification to existing gate logic. |
| GFW-5 | No new execution gate. No packet or playbook state may block or permit a trade. |
| GFW-6 | No vote_weight change. No field added here modifies any strategy's effective vote weight. |
| GFW-7 | No role change. No strategy's role_name, eligibility_state, or direction_bias is altered. |
| GFW-8 | No execution engine change. core_trade_engine.mqh is forbidden across all candidates. |
| GFW-9 | No playbook runtime permission. A PLAYBOOK_VALID state does not permit execution. PLAYBOOK_CONTRADICTED does not block execution. Playbook state is observation-only. |
| GFW-10 | No playbook score or completion percentage. States are categorical strings only: NOT_PRESENT / FORMING / VALID / CONTRADICTED / LATE / INVALID. |
| GFW-11 | No production readiness claim. System status remains DEVELOPING through all five candidates. |
| GFW-12 | No Nautilus change. nautilus_lab/ directory and all Nautilus scripts/certifications are untouched. |
| GFW-13 | Decision-path isolation. Zero read dependency from any V1 decision layer to any shadow field added by these candidates. Verified by code inspection before deployment. |
| GFW-14 | Accepted packet status = research/registry classification only. MSR FAILURE_MODE_PACKET and TPC CONFIRM_PACKET_SPARSE authorize nothing in runtime. |

---

## 4. Specification Package Overview

| # | Candidate ID | Purpose | Layer | Runtime Effect | Status | Dependency | Risk Level | Execution Readiness |
|---|---|---|---|---|---|---|---|---|
| 1 | OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 | Add playbook/packet shadow fields to ledger schema | Attribution (Layer 5) | NONE | NOT_AUTHORIZED_HERE | Opportunity Ledger live (met) | LOW-MEDIUM | READY when authorized |
| 2 | PLAYBOOK_STATE_SHADOW_EMITTER_V1 | Emit categorical playbook state to ledger (observe only) | Attribution (Layer 5) | NONE | NOT_AUTHORIZED_HERE | Candidate 1 must be live first | MEDIUM | BLOCKED on Candidate 1 |
| 3 | EVENT_ORDER_TRACE_FIELDS_V1 | Record event ordering timestamps for EOC compliance | Attribution (Layer 5) | NONE | NOT_AUTHORIZED_HERE | Candidate 1 must be live first | LOW-MEDIUM | BLOCKED on Candidate 1 |
| 4 | PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1 | Diagnostic: compare registry expectations to observed runtime behavior | Reporting / External | NONE | NOT_AUTHORIZED_HERE | Candidates 1+2 live with ≥200 records | LOW | BLOCKED on Candidates 1+2 |
| 5 | RCEM_V1_DOCUMENTATION_UPDATE | PIML documentation of regime-conditioned design intent (no source change) | Documentation | NONE | NOT_AUTHORIZED_HERE | Phase 3 ≥8 certs (currently 7/17) | NEGLIGIBLE | NEAR_READY — 1 more cert away from threshold |

---

## 5. Candidate 1 — OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1

**Status: NOT_AUTHORIZED_HERE**  
**Type:** Instrumentation-only / Attribution-layer schema extension  
**Layer:** Layer 5 — Attribution  
**Runtime effect:** NONE

### 5.1 Objective

Extend the Opportunity Ledger (`ai_opportunity_ledger.jsonl`) schema from `OL_V1B_CROSS_FAMILY` to `OL_V1C_PLAYBOOK_SHADOW` by adding playbook and packet observation fields to each trigger-present record. These fields enable future shadow playbook state analysis (Candidate 2) and event order validation (Candidate 3).

### 5.2 Rationale

The current V1B schema captures cross-family confirmation evidence per strategy trigger. It does not capture:
- Which playbook was active when the trigger fired
- Whether the playbook chain had completed or missing links
- Whether failure-mode evidence was present
- Whether evidence was available before or after the decision

Adding these fields as write-only shadow data (never read by decision logic) enables the Attribution layer to observe playbook coherence over time without touching any decision path.

### 5.3 Allowed Files (if later executed)

| File | Change Type | Scope |
|---|---|---|
| `council_mode_types.mqh` | Add structs only | Two new structs after `OL_CrossFamilyEvidence`, before `#endif` |
| `council_mode_runtime.mqh` | Extend function signature + add field serializations | `WriteOpportunityLedgerRecord` only; schema version string only; call site addition only |

### 5.4 Forbidden Files (absolute)

`council_aggregator.mqh` · `council_pre_ai_filter.mqh` · `core_trade_engine.mqh` · `council_strategies.mqh` · `council_ai_governor.mqh` · `council_environment.mqh` · `council_failure_detector.mqh` · `council_feedback.mqh` · `council_memory.mqh` · `decision_mode_router.mqh` · `main_ea.mq5` · any `.set` file · any `.json` runtime file · any `.jsonl` runtime file (existing records; new writes are allowed by schema extension)

### 5.5 New Structs — council_mode_types.mqh

**Insertion point:** After `OL_CrossFamilyEvidence` closing `};` (current last struct before `#endif`), before `#endif`.

#### Struct 1: OL_PlaybookShadowState

```mql5
//---------------------------------------------------------
// Playbook shadow state — PLAYBOOK_CENTRIC_EVIDENCE_ARCH V1
// OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1
// Write-only to JSONL. Never read by decision pipeline.
// No score. No gate. No weight. No execution permission.
//---------------------------------------------------------
struct OL_PlaybookShadowState
{
   string playbook_id;                  // "RANGE_BOUNDARY_SWEEP_RECLAIM" |
                                        // "TREND_PULLBACK_CONTINUATION"  |
                                        // "VOLATILITY_COMPRESSION_RELEASE" | ""
   string playbook_state;               // "PLAYBOOK_NOT_PRESENT" |
                                        // "PLAYBOOK_FORMING" |
                                        // "PLAYBOOK_VALID" |
                                        // "PLAYBOOK_CONTRADICTED" |
                                        // "PLAYBOOK_LATE" |
                                        // "PLAYBOOK_INVALID"
   string primary_packet_id;            // strategy_id of anchor trigger ("" if not present)
   string completed_links_json;         // JSON array: "[\"ALPHA\",\"LOCATION\"]"
   string missing_links_json;           // JSON array: "[\"CONFIRMATION\"]"
   string contradicted_links_json;      // JSON array: "[]"
   bool   failure_mode_present;         // True if accepted FAILURE_MODE_PACKET is active
   string failure_mode_type;            // e.g. "MSR_LHR_COPRESENCE" | ""
   bool   required_evidence_present;    // True if all required chain links satisfied
   bool   supporting_evidence_present;  // True if supporting evidence present
   bool   optional_evidence_present;    // True if optional evidence present
   string room_state;                   // "FAVORABLE" | "MARGINAL" | "UNFAVORABLE" | "NOT_EVALUATED"
   string stop_geometry_state;          // "CALCULABLE" | "NOT_CALCULABLE" | "NOT_EVALUATED"
   bool   pre_decision_available;       // True if state assembled before V1 final_decision
   bool   late_evidence;                // True if any packet evidence post-dates decision
   string attribution_note;             // Free-text note for human review
   string state_reason;                 // Why this state was assigned
};
```

#### Struct 2: OL_EventOrderTrace (also added in this candidate)

```mql5
//---------------------------------------------------------
// Event order trace — EVENT_ORDER_TRACE_FIELDS_V1 spec
// OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1
// Timestamps proving evidence causal ordering per EOC §6
// Write-only. Never read by decision pipeline.
//---------------------------------------------------------
struct OL_EventOrderTrace
{
   string context_timestamp;             // TimeCurrent() when env report complete
   string location_timestamp;            // TimeCurrent() when location gate evaluated
   string trigger_timestamp;             // TimeCurrent() at strategy trigger evaluation
   string confirm_timestamp;             // TimeCurrent() when confirm packet evaluated ("" if absent)
   string failure_mode_timestamp;        // TimeCurrent() when failure mode evaluated ("" if absent)
   string room_timestamp;                // TimeCurrent() when room-to-target calculated
   string stop_geometry_timestamp;       // TimeCurrent() when SL level confirmed
   string playbook_state_timestamp;      // TimeCurrent() after OL_ComputePlaybookShadowState()
   string decision_timestamp;            // TimeCurrent() after runtime.final_decision set
   bool   pre_decision_available;        // playbook_state_timestamp set before decision_timestamp
   bool   late_evidence;                 // Any evidence captured after decision_timestamp
   bool   event_order_valid;             // All timestamps satisfy EOC monotonic ordering
   string event_order_violation_reason;  // "" | description if event_order_valid = false
};
```

**Note on MQL5 timestamps:** `TimeCurrent()` returns `datetime` (seconds resolution). In single-threaded MQL5 `OnTick()`, context through decision happens within the same second on most bars. Use `GetMicrosecondCount()` for sub-second differentiation. The spec uses string representation (`TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS)`) to match existing ledger timestamp conventions. If sub-second granularity is needed, a separate `GetMicrosecondCount()` field may be added as `_us` suffix fields (design review item — not blocking).

#### Initializer functions

```mql5
void OL_InitPlaybookShadowState(OL_PlaybookShadowState &s)
{
   s.playbook_id                 = "";
   s.playbook_state              = "PLAYBOOK_NOT_PRESENT";
   s.primary_packet_id           = "";
   s.completed_links_json        = "[]";
   s.missing_links_json          = "[]";
   s.contradicted_links_json     = "[]";
   s.failure_mode_present        = false;
   s.failure_mode_type           = "";
   s.required_evidence_present   = false;
   s.supporting_evidence_present = false;
   s.optional_evidence_present   = false;
   s.room_state                  = "NOT_EVALUATED";
   s.stop_geometry_state         = "NOT_EVALUATED";
   s.pre_decision_available      = false;
   s.late_evidence               = false;
   s.attribution_note            = "";
   s.state_reason                = "";
}

void OL_InitEventOrderTrace(OL_EventOrderTrace &t)
{
   t.context_timestamp            = "";
   t.location_timestamp           = "";
   t.trigger_timestamp            = "";
   t.confirm_timestamp            = "";
   t.failure_mode_timestamp       = "";
   t.room_timestamp               = "";
   t.stop_geometry_timestamp      = "";
   t.playbook_state_timestamp     = "";
   t.decision_timestamp           = "";
   t.pre_decision_available       = false;
   t.late_evidence                = false;
   t.event_order_valid            = false;
   t.event_order_violation_reason = "NOT_EVALUATED";
}
```

### 5.6 Schema Version Change — council_mode_runtime.mqh

**Two locations to update if implemented:**

| Location | Current value | New value |
|---|---|---|
| L587: record_version | `"OL_V1B_CROSS_FAMILY"` | `"OL_V1C_PLAYBOOK_SHADOW"` |
| L704: schema_version (summary) | `"OL_SUMMARY_V1B_CROSS_FAMILY"` | `"OL_SUMMARY_V1C_PLAYBOOK_SHADOW"` |

**Backward compatibility:** Old V1B records remain valid JSONL. Consumers must handle missing fields gracefully (null-safe parsing). New V1C records carry all V1B fields plus new shadow fields.

### 5.7 WriteOpportunityLedgerRecord — Extended Signature

**Current signature (L562–568):**
```mql5
bool WriteOpportunityLedgerRecord(
   string                         filePath,
   const CouncilStrategyReport   &report,
   const CouncilRuntimeResult    &runtime,
   StrategyOpportunityCounter    &counter,
   const OL_CrossFamilyEvidence  &cfe
)
```

**Proposed extended signature:**
```mql5
bool WriteOpportunityLedgerRecord(
   string                            filePath,
   const CouncilStrategyReport      &report,
   const CouncilRuntimeResult       &runtime,
   StrategyOpportunityCounter       &counter,
   const OL_CrossFamilyEvidence     &cfe,
   const OL_PlaybookShadowState     &pss,    // NEW — shadow; not read by decision
   const OL_EventOrderTrace         &eot     // NEW — trace; not read by decision
)
```

### 5.8 JSON Field Additions — WriteOpportunityLedgerRecord Body

**Current last field (L667):**
```mql5
j += "\"confirm_strategy_count\":" + IntegerToString(cfe.confirm_strategy_count);
j += "}";   // L668 — closing brace
```

**Proposed replacement (add comma after last existing field, append new block before closing brace):**
```mql5
j += "\"confirm_strategy_count\":" + IntegerToString(cfe.confirm_strategy_count) + ",";
// --- PLAYBOOK SHADOW FIELDS (OL_V1C_PLAYBOOK_SHADOW) ---
// Write-only. Never read by council decision pipeline.
j += "\"playbook_id\":\"" + OpportunityJsonEscape(pss.playbook_id) + "\",";
j += "\"playbook_state\":\"" + OpportunityJsonEscape(pss.playbook_state) + "\",";
j += "\"primary_packet_id\":\"" + OpportunityJsonEscape(pss.primary_packet_id) + "\",";
j += "\"completed_links\":" + pss.completed_links_json + ",";
j += "\"missing_links\":" + pss.missing_links_json + ",";
j += "\"contradicted_links\":" + pss.contradicted_links_json + ",";
j += "\"failure_mode_present\":" + (pss.failure_mode_present ? "true" : "false") + ",";
j += "\"failure_mode_type\":\"" + OpportunityJsonEscape(pss.failure_mode_type) + "\",";
j += "\"required_evidence_present\":" + (pss.required_evidence_present ? "true" : "false") + ",";
j += "\"supporting_evidence_present\":" + (pss.supporting_evidence_present ? "true" : "false") + ",";
j += "\"optional_evidence_present\":" + (pss.optional_evidence_present ? "true" : "false") + ",";
j += "\"room_state\":\"" + OpportunityJsonEscape(pss.room_state) + "\",";
j += "\"stop_geometry_state\":\"" + OpportunityJsonEscape(pss.stop_geometry_state) + "\",";
j += "\"pss_pre_decision_available\":" + (pss.pre_decision_available ? "true" : "false") + ",";
j += "\"pss_late_evidence\":" + (pss.late_evidence ? "true" : "false") + ",";
j += "\"attribution_note\":\"" + OpportunityJsonEscape(pss.attribution_note) + "\",";
j += "\"state_reason\":\"" + OpportunityJsonEscape(pss.state_reason) + "\",";
// --- EVENT ORDER TRACE FIELDS ---
j += "\"context_timestamp\":\"" + OpportunityJsonEscape(eot.context_timestamp) + "\",";
j += "\"location_timestamp\":\"" + OpportunityJsonEscape(eot.location_timestamp) + "\",";
j += "\"trigger_timestamp\":\"" + OpportunityJsonEscape(eot.trigger_timestamp) + "\",";
j += "\"confirm_timestamp\":\"" + OpportunityJsonEscape(eot.confirm_timestamp) + "\",";
j += "\"failure_mode_timestamp\":\"" + OpportunityJsonEscape(eot.failure_mode_timestamp) + "\",";
j += "\"room_timestamp\":\"" + OpportunityJsonEscape(eot.room_timestamp) + "\",";
j += "\"stop_geometry_timestamp\":\"" + OpportunityJsonEscape(eot.stop_geometry_timestamp) + "\",";
j += "\"playbook_state_timestamp\":\"" + OpportunityJsonEscape(eot.playbook_state_timestamp) + "\",";
j += "\"decision_timestamp\":\"" + OpportunityJsonEscape(eot.decision_timestamp) + "\",";
j += "\"eot_pre_decision_available\":" + (eot.pre_decision_available ? "true" : "false") + ",";
j += "\"eot_late_evidence\":" + (eot.late_evidence ? "true" : "false") + ",";
j += "\"event_order_valid\":" + (eot.event_order_valid ? "true" : "false") + ",";
j += "\"event_order_violation_reason\":\"" +
     OpportunityJsonEscape(eot.event_order_violation_reason) + "\"";
j += "}";
```

**Note:** `pss.completed_links_json`, `pss.missing_links_json`, `pss.contradicted_links_json` are pre-formed JSON array strings (`"[]"` or `"[\"ALPHA\",\"LOCATION\"]"`). They are inserted raw (no extra quoting) since they are already valid JSON.

### 5.9 Call Site Update — council_mode_runtime.mqh (L1197–1222)

**Current code (L1197–1222):**
```mql5
OL_CrossFamilyEvidence ol_cfe = OL_ComputeCrossFamilyEvidence(reports, reportCount, runtime);
for(int ol_i = 0; ol_i < reportCount && ol_i < COUNCIL_MAX_STRATEGIES; ol_i++)
{
   IncrementEvaluationCounter(...);
   if(reports[ol_i].trigger_present)
   {
      bool ol_wrote = WriteOpportunityLedgerRecord(
         "AI\\ai_opportunity_ledger.jsonl",
         reports[ol_i], runtime, g_opportunity_counters[ol_i], ol_cfe
      );
      if(ol_wrote) g_total_trigger_writes++;
   }
}
```

**Proposed replacement:**
```mql5
OL_CrossFamilyEvidence ol_cfe = OL_ComputeCrossFamilyEvidence(reports, reportCount, runtime);
// NEW: Compute playbook shadow state once per bar (not per strategy)
OL_PlaybookShadowState ol_pss;
OL_InitPlaybookShadowState(ol_pss);
// ol_pss populated by Candidate 2 function (OL_ComputePlaybookShadowState)
// Until Candidate 2 is authorized, ol_pss fields remain at init defaults (PLAYBOOK_NOT_PRESENT)

// NEW: Compute event order trace once per bar
OL_EventOrderTrace ol_eot;
OL_InitEventOrderTrace(ol_eot);
// ol_eot populated by Candidate 3 function (OL_ComputeEventOrderTrace)
// Until Candidate 3 is authorized, ol_eot fields remain at init defaults

for(int ol_i = 0; ol_i < reportCount && ol_i < COUNCIL_MAX_STRATEGIES; ol_i++)
{
   IncrementEvaluationCounter(...);
   if(reports[ol_i].trigger_present)
   {
      bool ol_wrote = WriteOpportunityLedgerRecord(
         "AI\\ai_opportunity_ledger.jsonl",
         reports[ol_i], runtime, g_opportunity_counters[ol_i], ol_cfe,
         ol_pss, ol_eot   // NEW parameters
      );
      if(ol_wrote) g_total_trigger_writes++;
   }
}
```

**Key design choice:** `ol_pss` and `ol_eot` are computed once per bar and shared across all strategy records in the loop. This mirrors the `ol_cfe` pattern. When Candidates 2 and 3 are not yet authorized, both structs hold their zero-initialized (safe default) values — all shadow fields write `"PLAYBOOK_NOT_PRESENT"` and empty timestamps, which is correct and honest.

### 5.10 Validation Steps

| Level | Check | Pass Criteria |
|---|---|---|
| L1 — Compile | Build with MetaEditor | 0 errors, 0 warnings |
| L2a — File write | EA reload, generate 5 trigger records | `record_version` field = `"OL_V1C_PLAYBOOK_SHADOW"` in all new records |
| L2b — New fields | Inspect JSONL records | All 27 new fields present; no parse errors; array fields valid JSON |
| L2c — Old fields | Inspect JSONL records | All 32 existing V1B fields still present; values unchanged |
| L2d — Summary schema | Inspect ai_opportunity_summary.json | `schema_version` = `"OL_SUMMARY_V1C_PLAYBOOK_SHADOW"` |
| L3a — Decision rate | Compare 30-bar window before/after | Trade execution rate unchanged (±0 trades) |
| L3b — Gate results | Compare 30-bar window | DSN, CRR, NO_TRADE block rates unchanged |
| L3c — council_quality | Compare 30-bar window | council_quality distribution unchanged |
| L3d — No PSS read dependency | Code inspection | Zero references to `ol_pss` fields in aggregator, filter, governor, strategy, execution code |
| L4 — Default states | Inspect records with Candidates 2+3 not yet active | `playbook_state` = `"PLAYBOOK_NOT_PRESENT"`; `event_order_valid` = `false`; `event_order_violation_reason` = `"NOT_EVALUATED"` — all correct defaults |

### 5.11 Rollback Plan

1. Restore `council_mode_types.mqh` from backup (remove `OL_PlaybookShadowState` and `OL_EventOrderTrace` struct definitions and their initializers)
2. Restore `council_mode_runtime.mqh` from backup (revert `WriteOpportunityLedgerRecord` signature; revert schema version strings; revert call site to 5-parameter form)
3. Compile and verify 0 errors
4. Verify ledger writes revert to V1B schema (`record_version` = `"OL_V1B_CROSS_FAMILY"`)
5. Existing V1B and V1C records coexist in JSONL without issue (JSONL is append-only; old records are unaffected)

### 5.12 Decision-Path Isolation Proof

- `ol_pss` and `ol_eot` are declared after `runtime.final_decision` is set (line 1197 in the current code is after all decision logic concludes in RunCouncilModePipeline)
- Neither struct is declared in, nor passed to: `RunCouncilStrategySet`, `BuildCouncilAggregateReport`, `EvaluateCouncilAIGovernor`, `RunCouncilPreAIFilter`, or any execution path
- The only function receiving `ol_pss` and `ol_eot` is `WriteOpportunityLedgerRecord`, which has no return value influence on decisions (it returns `bool` write-success only; this return value controls `g_total_trigger_writes` counter, which is a telemetry counter only, not a decision input)
- Inspection rule: after implementation, `grep -n "playbook_state\|ol_pss\|ol_eot"` in all `.mqh` files must return no matches in `council_aggregator.mqh`, `council_pre_ai_filter.mqh`, `council_ai_governor.mqh`, `council_strategies.mqh`, or `core_trade_engine.mqh`

---

## 6. Candidate 2 — PLAYBOOK_STATE_SHADOW_EMITTER_V1

**Status: NOT_AUTHORIZED_HERE**  
**Type:** Shadow state assembly — observation only  
**Layer:** Layer 5 — Attribution  
**Runtime effect:** NONE  
**Prerequisite:** Candidate 1 must be implemented and live

### 6.1 Objective

Implement the `OL_ComputePlaybookShadowState()` function that populates the `OL_PlaybookShadowState` struct per bar. Until Candidate 1 is live and Candidate 2 is separately authorized, `ol_pss` holds default values (PLAYBOOK_NOT_PRESENT) as specified in §5.9.

### 6.2 Allowed States

```
PLAYBOOK_NOT_PRESENT   — anchor strategy not firing on this bar
PLAYBOOK_FORMING       — anchor present; confirmation absent or insufficient
PLAYBOOK_VALID         — anchor + confirmation; no active failure mode
PLAYBOOK_CONTRADICTED  — failure mode overrides confirmation
PLAYBOOK_LATE          — temporal improvement flag active; edge concentrated in late period only
PLAYBOOK_INVALID       — causal chain structurally impossible in current zone/regime context
```

**Critical governance rules for state assignment:**
- No numeric score. No completion percentage. No confidence multiplier.
- State assignment must be purely from categorical rules applied to existing `reports[]` and `runtime` fields — no new signal evaluations.
- State is per-bar, not per-strategy.

### 6.3 Proposed Function Signature

```mql5
OL_PlaybookShadowState OL_ComputePlaybookShadowState(
   const CouncilStrategyReport  &reports[],
   int                           reportCount,
   const CouncilRuntimeResult   &runtime,
   const OL_CrossFamilyEvidence &cfe
);
```

This function reads from `reports[]`, `runtime.env`, and `cfe` only — all of which are already computed before the call. It does NOT call any strategy evaluation functions, does NOT read price data, and does NOT modify any `runtime` fields.

### 6.4 Playbook Assignment — Strategy Lookup

Each playbook has a defined anchor strategy and confirmation strategies. The emitter identifies these by `strategy_id` string match in `reports[]`.

| Playbook ID | Anchor (ALPHA) | Confirm | Failure Mode Signal | Chain Required |
|---|---|---|---|---|
| RANGE_BOUNDARY_SWEEP_RECLAIM (RBSR) | `sweep_reversal` | `bollinger_reclaim`, `range_edge_fade` | `mfi_reversal_assist` | anchor + at least 1 confirm |
| TREND_PULLBACK_CONTINUATION (TPC) | `trend_momentum` | `trend_pullback_cont_v1` | exhaustion_warning (runtime.aggregate) | anchor + TPC confirm |
| VOLATILITY_COMPRESSION_RELEASE (VCR) | `range_compression_breakout` | `volatility_squeeze_release` | none defined | anchor + compress confirm |

### 6.5 State Assignment Logic (per playbook)

**For each playbook, evaluate in order:**

```
Step 1: Find anchor strategy report (by strategy_id match in reports[])
   If anchor.trigger_present == false → PLAYBOOK_NOT_PRESENT; stop.

Step 2: Determine direction from anchor.decision
   If direction == NONE → PLAYBOOK_NOT_PRESENT (no directional signal); stop.

Step 3: Check zone/regime validity
   If zone is structurally incompatible with playbook (e.g., RBSR in TC zone) → PLAYBOOK_INVALID; stop.

Step 4: Check failure mode
   failure_mode_active = evaluate per playbook definition (see §6.6)

Step 5: Check confirmation
   confirm_present = false
   for each confirm strategy: if report.trigger_present AND direction matches anchor → confirm_present = true

Step 6: Assign state
   If failure_mode_active AND confirm_present  → PLAYBOOK_CONTRADICTED
   If failure_mode_active AND !confirm_present → PLAYBOOK_FORMING (anchor only; failure mode present)
   If confirm_present AND !failure_mode_active → PLAYBOOK_VALID
   If !confirm_present AND !failure_mode_active → PLAYBOOK_FORMING (anchor only; confirmation absent)
   Additional: if temporal late_evidence flag relevant → PLAYBOOK_LATE
               (late evidence detected from runtime degradation context — DESIGN_REVIEW_REQUIRED for exact condition)
```

### 6.6 Failure Mode Evaluation Per Playbook

| Playbook | Failure Mode Condition | Source Field |
|---|---|---|
| RBSR | `mfi_reversal_assist.trigger_present == true AND direction contradicts anchor` | reports[] for mfi_reversal_assist |
| TPC | `runtime.aggregate.exhaustion_warning == true AND zone == TREND_CONTINUATION` | runtime.aggregate.exhaustion_warning |
| VCR | No formally accepted failure mode defined (DATA_INSUFFICIENT for all VCR strategies) | N/A — failure_mode_present = false always for VCR until defined |

**Important design note (MSR / LHR interaction):** MSR's FAILURE_MODE_PACKET is accepted for LHR outcomes (MSR co-presence predicts LHR E[R] degradation). However, this failure mode applies to LHR as a CONFIRM strategy, not to the TPC playbook anchor (trend_momentum). The emitter should capture MSR presence when LHR fires, but must not mark the whole TPC playbook as CONTRADICTED based on MSR alone. The correct behavior: if LHR is the current trigger strategy and MSR co-presence is observed within ±5 bars, set `failure_mode_present = true` and `failure_mode_type = "MSR_LHR_COPRESENCE"` in that specific strategy's record. For the bar-level playbook state, this affects the TPC chain at the CONFIRM level, not at the ALPHA anchor level.

**Exact implementation of co-presence (±5 bars) check:** This requires a small lookback into the `reports[]` array from prior bars — DESIGN_REVIEW_REQUIRED. The simplest V1 approach is to flag MSR co-presence only on the same bar (0-bar window), not ±5. The ±5 window is a future refinement. Spec the current bar check for initial implementation.

### 6.7 Chain Link JSON Array Construction

```mql5
// Helper: build JSON array string from a dynamic list of link names
// Example output: "[\"ALPHA\",\"LOCATION\"]"
// For empty list: "[]"
string OL_BuildLinkJson(const string &links[], int count)
{
   if(count == 0) return "[]";
   string j = "[";
   for(int i = 0; i < count; i++)
   {
      j += "\"" + links[i] + "\"";
      if(i < count - 1) j += ",";
   }
   j += "]";
   return j;
}
```

### 6.8 Allowed Future Files

| File | Change Type |
|---|---|
| `council_mode_types.mqh` | Already handled in Candidate 1 (structs added) |
| `council_mode_runtime.mqh` | Add `OL_ComputePlaybookShadowState()` function body; populate `ol_pss` before the write loop |

### 6.9 Forbidden Files (absolute — same as Candidate 1)

All decision, gate, execution, and aggregation files. See §5.4.

### 6.10 Validation Steps

| Level | Check | Pass Criteria |
|---|---|---|
| L1 | Compile | 0 errors, 0 warnings |
| L2a | State values | All `playbook_state` values in ledger are one of the 6 valid categorical strings |
| L2b | PLAYBOOK_NOT_PRESENT default | For bars where sweep_reversal.trigger_present=false: RBSR state = PLAYBOOK_NOT_PRESENT |
| L2c | PLAYBOOK_FORMING | For bar where only anchor fires: state = PLAYBOOK_FORMING; completed_links = ["ALPHA"] |
| L2d | No playbook_score field | Grep confirms no `playbook_score` or `playbook_pct` field anywhere in JSONL |
| L3a — Decision invariance | 30-bar window | Execution rate, gate rates, council_quality all unchanged vs pre-implementation baseline |
| L3b — No state read | Code inspection | Zero references to `ol_pss.playbook_state` in any file except `WriteOpportunityLedgerRecord` |
| L4 — EOC compliance | Pre_decision_available | `pss_pre_decision_available = true` in ≥90% of records (computed after final_decision; always pre-decision if inserted after L1024 in runtime) |

### 6.11 Rollback Plan

1. Remove `OL_ComputePlaybookShadowState()` function body from `council_mode_runtime.mqh`
2. Remove `ol_pss` population call (restore to `OL_InitPlaybookShadowState(ol_pss)` default only)
3. Schema version can optionally revert to `OL_V1C_PLAYBOOK_SHADOW` (fields remain in schema but populated with defaults) — no change needed if Candidate 1 stays live
4. Compile and verify 0 errors

---

## 7. Candidate 3 — EVENT_ORDER_TRACE_FIELDS_V1

**Status: NOT_AUTHORIZED_HERE**  
**Type:** Attribution instrumentation — event ordering timestamps  
**Layer:** Layer 5 — Attribution  
**Runtime effect:** NONE  
**Prerequisite:** Candidate 1 must be implemented and live

### 7.1 Objective

Implement `OL_ComputeEventOrderTrace()` to populate the `OL_EventOrderTrace` struct per bar, recording timestamps (and ordering validation) for each stage in the Event Order Contract (§6 of ARCHITECTURE_BUILD_PACKAGE_V1.md). This enables post-hoc verification that all evidence was available before the decision — the fundamental requirement for valid attribution analysis.

### 7.2 Purpose

Without event ordering evidence, retrospective analysis cannot distinguish between:
- A confirmation that fired before the trade decision (valid evidence)
- A confirmation that fired after the bar closed but was attributed to the earlier decision (late evidence — invalid)

The `OL_EventOrderTrace` struct creates an unforgeable audit record of when each stage completed.

### 7.3 Proposed Function Signature

```mql5
OL_EventOrderTrace OL_ComputeEventOrderTrace(
   const CouncilRuntimeResult  &runtime,
   string                       context_ts,       // captured at env report completion
   string                       location_ts,      // captured at zone position evaluation
   string                       trigger_ts,       // captured at strategy trigger fire
   string                       confirm_ts,       // captured at confirm packet eval ("")
   string                       failure_mode_ts,  // captured at failure mode eval ("")
   string                       room_ts,          // captured at room-to-target calc
   string                       stop_geometry_ts, // captured at SL level confirmation
   string                       playbook_state_ts,// captured after OL_ComputePlaybookShadowState()
   string                       decision_ts       // captured after runtime.final_decision set
);
```

### 7.4 Timestamp Capture Points in RunCouncilModePipeline

Each timestamp must be captured at the specific point in `RunCouncilModePipeline()` where that stage completes. Implementation inserts timestamp captures (using `TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS)`) at the following approximate locations:

| Timestamp | Capture Point | Approximate Line (current code) |
|---|---|---|
| `context_ts` | After `BuildCouncilEnvironmentReport(env)` completes | ~L865 (after env assignment) |
| `location_ts` | After zone position / eligibility evaluation within env | Same bar as context — may be same timestamp; acceptable |
| `trigger_ts` | Captured per-strategy within the write loop (L1211) when `trigger_present=true` | L1211 |
| `confirm_ts` | After `OL_ComputeCrossFamilyEvidence()` returns (L1198) — confirms cross-family eval complete | ~L1199 |
| `failure_mode_ts` | Same as confirm_ts (cross-family evidence computation covers failure mode scan) | ~L1199 |
| `room_ts` | DESIGN_REVIEW_REQUIRED — room-to-target is computed in core_trade_engine.mqh (forbidden file); may require a proxy timestamp from the pre-AI filter completion | ~L969 (after RunCouncilPreAIFilter) |
| `stop_geometry_ts` | DESIGN_REVIEW_REQUIRED — same as room_ts (stop geometry is execution layer) | same |
| `playbook_state_ts` | After `OL_ComputePlaybookShadowState()` returns | Between L1198 and L1200 |
| `decision_ts` | After `runtime.final_decision` is set (after L1036) | ~L1037 |

**Design note for room_ts and stop_geometry_ts:** Since `core_trade_engine.mqh` is forbidden, the proxy is to use the `RunCouncilPreAIFilter` completion timestamp as the "room and stop geometry evaluated" marker, since the pre-AI filter evaluates whether the trade is structurally viable (which implicitly requires room/geometry to be assessable). This is a conservative proxy — document it as such.

### 7.5 Event Order Validation Logic

```mql5
// Within OL_ComputeEventOrderTrace() body:
bool order_valid = true;
string violation = "";

// Rule EOC-2: playbook_state must precede decision
if(StringLen(t.playbook_state_timestamp) > 0 &&
   StringLen(t.decision_timestamp) > 0 &&
   t.playbook_state_timestamp > t.decision_timestamp)
{
   order_valid = false;
   violation = "PLAYBOOK_STATE_AFTER_DECISION";
}

// Rule EOC-1: confirm must precede decision (if present)
if(StringLen(t.confirm_timestamp) > 0 &&
   StringLen(t.decision_timestamp) > 0 &&
   t.confirm_timestamp > t.decision_timestamp)
{
   order_valid = false;
   if(StringLen(violation) > 0) violation += "|";
   violation += "CONFIRM_AFTER_DECISION";
}

t.event_order_valid = order_valid;
t.event_order_violation_reason = (StringLen(violation) > 0) ? violation : "";
t.pre_decision_available = (StringLen(t.playbook_state_timestamp) > 0 &&
                             t.playbook_state_timestamp <= t.decision_timestamp);
t.late_evidence = (t.event_order_valid == false);
```

**Note:** Since MQL5 `TimeCurrent()` has one-second resolution, most comparisons will return equal timestamps (not strictly ordered). The `>=` comparisons above treat equal timestamps as non-violating. Sub-second `GetMicrosecondCount()` can be used in a future refinement for stricter ordering — mark as DESIGN_REVIEW_REQUIRED for V2.

### 7.6 Practical reality for V1

In MT5's single-threaded `OnTick()` execution, most timestamps between `context_ts` and `decision_ts` will be identical (same second). The value of recording them in V1 is:
1. Confirming that all stages complete within the same OnTick() invocation (no async gaps)
2. Establishing the structural pattern for future sub-second timestamping if needed
3. Enabling `pre_decision_available` to be computed and validated
4. Providing a format that can be upgraded to microsecond precision without schema change

### 7.7 Allowed Future Files

| File | Change Type |
|---|---|
| `council_mode_types.mqh` | Already handled in Candidate 1 |
| `council_mode_runtime.mqh` | Add `OL_ComputeEventOrderTrace()` function; add timestamp capture variables in `RunCouncilModePipeline()`; pass to `OL_ComputeEventOrderTrace()` |

### 7.8 Validation Steps

| Level | Check | Pass Criteria |
|---|---|---|
| L1 | Compile | 0 errors, 0 warnings |
| L2a | Timestamps present | All 9 timestamp fields populated (non-empty strings) in new records |
| L2b | Order validation | `event_order_valid = true` in ≥95% of records (timestamps equal or context < decision) |
| L2c | Pre-decision flag | `eot_pre_decision_available = true` in ≥90% of records (playbook_state_ts ≤ decision_ts) |
| L2d | Late evidence | `eot_late_evidence = false` in ≥95% of records (correct — all evidence in-tick) |
| L3 | Decision invariance | 30-bar window; execution rate, gate rates, WR all unchanged |

### 7.9 Rollback Plan

1. Remove timestamp capture variables from `RunCouncilModePipeline()`
2. Remove `OL_ComputeEventOrderTrace()` function call; restore `OL_InitEventOrderTrace(ol_eot)` default only
3. `OL_EventOrderTrace` struct remains in types file (Candidate 1 added it; clean removal only if Candidate 1 also rolls back)
4. Compile and verify 0 errors

---

## 8. Candidate 4 — PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1

**Status: NOT_AUTHORIZED_HERE**  
**Type:** Diagnostic and reporting only  
**Layer:** External reporting (outside MT5 decision pipeline)  
**Runtime effect:** NONE  
**Prerequisite:** Candidates 1+2 live with ≥200 trigger_present=true records in V1C_PLAYBOOK_SHADOW schema

### 8.1 Objective

Compare the packet and playbook classifications in `PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md` against observed behavior in the Opportunity Ledger. Identify where live MT5 behavior diverges from registry assumptions. Surface mismatches for operator review — without any runtime effect.

### 8.2 Rationale

The registry was built from Nautilus replay evidence. The live system may differ in trigger frequency, regime distribution, co-presence rates, and playbook state distribution. A systematic alignment check prevents the architecture from drifting between "what we think is happening" (registry) and "what is actually happening" (live). Mismatches do not automatically change registry classifications — they trigger a targeted review.

### 8.3 Diagnostic Checks

| Check | Method | Expected | Mismatch Action |
|---|---|---|---|
| Strategy fire rate vs registry expectations | Count `trigger_present=true` per strategy per regime | Roughly consistent with Nautilus fire rates (within 2×) | Flag for regime-specific investigation |
| Playbook_state distribution | Count FORMING/VALID/NOT_PRESENT per playbook over 200+ records | RBSR+TPC=FORMING, VCR=NOT_PRESENT | Alert if PLAYBOOK_VALID appears without formal packet acceptance |
| Failure mode activation rate | Count `failure_mode_present=true` vs total triggers | Consistent with co-presence rates from certs | Flag if rate > 2× cert co-presence rate |
| Cross-family confirm rate | Count `cross_family_confirm_present=true` per strategy | Consistent with Phase 4A-i evidence | Flag if rate changes materially post any source change |
| Registry coverage | Every strategy in ledger must have a registry entry | 17/17 strategies registered | Alert on any unregistered strategy_id in ledger |
| Forbidden runtime influence | Verify `playbook_state` field never appears in filter/aggregator/decision logic | Zero occurrences | IMMEDIATE HALT if found |

### 8.4 Output Format

**Two outputs (future — not created here):**

1. `packet_registry_alignment_report.json` — machine-readable; per-strategy per-playbook alignment check results
2. `packet_registry_alignment_summary.txt` — human-readable; bullet-point summary of mismatches and alerts

**Location:** `MQL5/Files/AI/` (or `nautilus_lab/outputs/` if implemented as external Python script)

### 8.5 Implementation Approach Decision

Two viable approaches — the correct choice requires a design review before implementation:

**Option A: External Python script** (preferred for isolation)
- Reads `ai_opportunity_ledger.jsonl` directly (Python script; no MT5 file modification)
- Reads `PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md` for registry expectations
- Produces alignment report without touching any MT5 file
- Location: `nautilus_lab/scripts/packet_registry_alignment_check_v1.py`
- Advantage: zero risk of MT5 decision path contamination

**Option B: MT5 instrumentation** (riskier — only if external scripting unavailable)
- Add reporting function in `council_mode_runtime.mqh` that reads ledger summary and produces alignment report
- Writes to `MQL5/Files/AI/packet_registry_alignment_report.json`
- Risk: function must be strictly write-only; no read dependency in decision logic
- This option requires additional isolation verification

**Recommendation:** Option A (Python script). The ledger is a file MT5 writes to; Python can read it at any time without disturbing the MT5 process. No MT5 source change required.

### 8.6 Important Constraints

- A registry mismatch NEVER blocks a trade. A strategy is never blocked because its playbook_state differs from registry expectations.
- A registry mismatch NEVER automatically updates the registry. Updates require operator review + PIML amendment.
- A registry mismatch NEVER changes a packet's status. Status changes require new Nautilus evidence or live evidence meeting formal thresholds.
- The alignment check is a review trigger, not an automatic correction mechanism.

### 8.7 Allowed Future Files

| Option | File |
|---|---|
| Option A (preferred) | `nautilus_lab/scripts/packet_registry_alignment_check_v1.py` (new) |
| Option B (alternative) | `council_mode_runtime.mqh` only (new reporting function, strictly write-path) |

### 8.8 Validation Steps

| Level | Check | Pass Criteria |
|---|---|---|
| L2 — Output | Run script/tool against ≥200 records | Report generated without errors; all 17 strategies covered |
| L3 — No runtime effect | Verify no MT5 decision reads report | 0 references to alignment report in any `.mqh` or `.mq5` file |
| L5 — Alignment | Check mismatch rate | If >20% of strategy records show zone mismatches, flag for operator review |

### 8.9 Rollback Plan

- Option A: Delete `packet_registry_alignment_check_v1.py` and output files; no MT5 change
- Option B: Remove reporting function from `council_mode_runtime.mqh`; compile and verify

---

## 9. Candidate 5 — RCEM_V1_DOCUMENTATION_UPDATE

**Status: NOT_AUTHORIZED_HERE**  
**Type:** Documentation-only (PIML amendment)  
**Layer:** Documentation / Governance  
**Runtime effect:** NONE  
**Prerequisite:** Phase 3 ≥8 strategies certified (currently 7/17 — one certification away)

### 9.1 Objective

Document the Regime-Conditioned Eligibility Matrix (RCEM) V1 as a new PIML section (§30 or §16.X) using certified Phase 3 evidence. This formalizes the design-intent regime conditioning that is currently informal. RCEM V1 is documentation only — no source enforcement.

### 9.2 Rationale

Phase 3 evidence has revealed that all 8 certified strategies have material regime × direction asymmetries. The system currently has no formal record of which regime × direction combinations are "ACTIVE" vs "REDUCED" vs "OBSERVE_ONLY" vs "BLOCKED" for each strategy. Without this record, future Phase 6 (EEWP weight conditioning) and future Phase 1 (RCEM enforcement) have no baseline to work from.

RCEM V1 documents the design intent derived from evidence. It does not change any runtime file. It does not add any gate. It is a PIML-only documentation task.

### 9.3 Proposed RCEM V1 Table (for PIML insertion)

States: **ACTIVE** (evidence supports; deploy normally) · **REDUCED** (evidence suggests caution; continue but track) · **OBSERVE_ONLY** (evidence suggests hostile; monitor only, no weight increase) · **BLOCKED** (evidence = EDGE_REJECTED; or structural impossibility) · **PENDING_CERT** (no certification data; default behavior until evidence)

Directions shown as BUY / SELL / BOTH_EQUAL. Where direction asymmetry exists, both cells shown.

| strategy_id | TREND_DOWN | RANGE_NEUTRAL | TREND_UP | Evidence Basis |
|---|---|---|---|---|
| sweep_reversal | BUY=ACTIVE (E[R]+0.012R); SELL=ACTIVE (E[R]+0.010R) | BUY=OBSERVE_ONLY (WR=37.57%, E[R]=−0.061R NOT_CONFIRMED); SELL=ACTIVE | BUY=ACTIVE; SELL=ACTIVE (E[R]+0.012R, counter-trend) | §24, XAUUSD cert |
| bollinger_reclaim | ACTIVE (WR=39.54%, RECOVERABLE) | OBSERVE_ONLY (WR=38.29%, E[R]=−0.043R, worst era) | ACTIVE (WR=40.01%, E[R]=+0.0004R, best era; Phase 5A NAUTILUS_CHALLENGED) | §24, XAUUSD cert |
| trend_momentum | SELL=ACTIVE (positive E[R]); BUY=ACTIVE | SELL=ACTIVE_PRIORITY (WR=44.37%, E[R]+0.109R, EDGE_SUPPORTED); BUY=ACTIVE | SELL=ACTIVE; BUY=REDUCED (WR=39.34%, E[R]=−0.017R, below breakeven) | §19–21 PIML |
| mfi_reversal_assist | PENDING_CERT | PENDING_CERT | PENDING_CERT | 0 live entries; no cert |
| trend_pullback_cont_v1 | ACTIVE (SELL=47.83%) | ACTIVE (RMR era-gated) | ACTIVE (BUY=42.08%) | §22 PIML cert |
| momentum_breakout_cont_v1 | BLOCKED | BLOCKED | BLOCKED | FROZEN; 9.1% live WR |
| micro_structure_reentry_v1 | ACTIVE (B gated: WR=40.42%, E[R]+0.010R) | BUY=OBSERVE_ONLY (WR=36.34%, E[R]=−0.092R NOT_CONFIRMED); SELL=ACTIVE | SELL=ACTIVE_PRIORITY (WR=40.13%, E[R]+0.003R, best); BUY=ACTIVE | §28 PIML cert |
| breakdown_momentum_v1 | OBSERVE_ONLY (worst regime for SELL — inverted) | ACTIVE (unexpectedly best — DESIGN_REVIEW pending) | OBSERVE_ONLY (hostile for SELL) | §26 PIML cert |
| lower_high_rejection_v1 | ACTIVE (WR=40.12%, E[R]+0.003R, correct alignment) | ACTIVE (WR=39.06%, RECOVERABLE) | OBSERVE_ONLY (WR=37.96%, E[R]=−0.051R NOT_CONFIRMED) | §27 PIML cert |
| mean_reversion_bounce | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |
| range_edge_fade | ACTIVE_PRIORITY (WR=40.93%, E[R]+0.023R, best regime) | OBSERVE_ONLY (zone proxy degrades; counter-indicated) | OBSERVE_ONLY (WR=37.50%, E[R]=−0.063R NOT_CONFIRMED) | §29 PIML cert |
| fake_break_reversal | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |
| range_compression_breakout | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |
| volatility_squeeze_release | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |
| volatility_breakout | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |
| expansion_continuation | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |
| micro_range_expansion | PENDING_CERT | PENDING_CERT | PENDING_CERT | DATA_INSUFFICIENT |

**Critical notes on the RCEM table:**
- `ACTIVE_PRIORITY` = a subset with the strongest evidence; does not create a different gate or weight from `ACTIVE`; it is a documentation annotation only
- `BLOCKED` for momentum_breakout_cont_v1 does not change the existing FROZEN status (vote_weight=0.00, decision=WAIT hard-coded by Package 1); it simply documents the evidence basis
- `OBSERVE_ONLY` in the RCEM table is a design intent for future EEWP (Phase 6 weight reduction in that regime); it does not enforce any current restriction
- `PENDING_CERT` means no evidence basis for a recommendation; current behavior (ACTIVE) continues by default
- This table does not authorize any weight change, gate, or source modification

### 9.4 Allowed Future Files

| File | Change Type |
|---|---|
| `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` | Add new §30 (RCEM_V1_DOCUMENTATION) or §16.X subsection; PIML backup first |

### 9.5 Forbidden Files (absolute)

All `.mqh`, `.mq5`, `.ex5`, `.set` files. All runtime `.json` and `.jsonl` files.

### 9.6 PIML Insertion Format

New section heading: `# §30 — RCEM_V1_DOCUMENTATION`  
Type: `EVIDENCE_DOCUMENTATION — Design-intent documentation only. No source change. No runtime enforcement.`  
Includes: RCEM table (§9.3 above), regime split summary per strategy, design notes, and explicit "RCEM_V1 is documentation only — no source enforcement" disclaimer.

### 9.7 Prerequisite

Phase 3 must be at ≥8 certifications (currently 7/17) before this section is written. One additional certification (e.g., range_compression_breakout or mean_reversion_bounce) completes the prerequisite. This is a threshold, not a calendar dependency — when the 8th cert completes, this task is immediately unblocked.

### 9.8 Validation Steps

| Level | Check | Pass Criteria |
|---|---|---|
| L2 — PIML | §30 (or §16.X) present with RCEM table | All 17 strategies have at least one regime cell entry (PENDING_CERT for uncertified) |
| L3 — No source change | Verify only PIML was modified | 0 changes to any `.mqh` / `.mq5` / `.json` file |
| L5 — Evidence alignment | RCEM cells for certified strategies match cert labels in §24–29 | ACTIVE/REDUCED/OBSERVE_ONLY/BLOCKED consistent with cited cert label and E[R] |

### 9.9 Rollback Plan

1. Restore `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` from backup (remove new §30 or §16.X section)
2. Verify PIML file size reverts to pre-amendment value
3. No source or runtime rollback needed

---

## 10. Cross-Candidate Dependency Order

The recommended execution order is based on dependencies, safety, and value-delivery. Every candidate still requires separate operator authorization.

```
Order 1 — RCEM_V1_DOCUMENTATION_UPDATE             [Candidate 5]
│  Why first: documentation-only; zero risk; clarifies regime-conditioned
│  design intent for all subsequent candidates
│  Prerequisite: Phase 3 reaches ≥8 certs (1 more cert needed)
│
▼
Order 2 — OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1   [Candidate 1]
│  Why second: ledger fields are the structural prerequisite for all
│  shadow observation candidates (2, 3) and the alignment check (4)
│  Prerequisite: none beyond current live ledger
│
▼
Order 3 — EVENT_ORDER_TRACE_FIELDS_V1              [Candidate 3]
│  Why third: can be implemented alongside Candidate 2 (shares schema
│  and call site) but event order proof is prerequisite for validating
│  Candidate 2's pre_decision_available claims
│  Prerequisite: Candidate 1 live
│  Note: may be bundled with Candidate 1 as a single Codex task since
│  both modify the same function and struct. DESIGN_REVIEW_REQUIRED
│  for whether to bundle or separate.
│
▼
Order 4 — PLAYBOOK_STATE_SHADOW_EMITTER_V1         [Candidate 2]
│  Why fourth: depends on schema (Candidate 1) and event order
│  validation (Candidate 3) being live
│  Prerequisite: Candidates 1 + 3 live; ≥50 records in V1C schema
│
▼
Order 5 — PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1  [Candidate 4]
   Why last: depends on playbook state data (Candidate 2) being
   accumulated in sufficient volume
   Prerequisite: Candidates 1+2 live; ≥200 records
```

**Bundling option for Candidates 1+3:** Since both candidates modify `council_mode_types.mqh` (new structs) and `council_mode_runtime.mqh` (schema version, function signature, JSON serialization), a single bounded Codex task could implement both. This reduces the number of compile+reload+validation cycles. Risk: larger scope per task. The operator should decide. Bundled task would be named `OPPORTUNITY_LEDGER_SCHEMA_V1C_EXTENDED` covering both candidates.

**What "separately authorized" means:** Each candidate (or bundle) requires its own operator authorization instruction issued as a distinct prompt, with a bounded scope statement. Authorization for Candidate 1 does not authorize Candidates 2–5. This document is not an authorization for any of them.

---

## 11. Decision-Path Isolation Requirements

Every future Codex task derived from this package must pass the following isolation checklist before deployment. This checklist is binding.

| # | Requirement | How to Verify |
|---|---|---|
| ISO-1 | No read dependency from council_aggregator.mqh on any shadow field | `grep -n "playbook_state\|ol_pss\|ol_eot\|OL_Playbook\|OL_EventOrder"` in council_aggregator.mqh → 0 matches |
| ISO-2 | No read dependency from council_pre_ai_filter.mqh on any shadow field | Same grep in council_pre_ai_filter.mqh → 0 matches |
| ISO-3 | No read dependency from council_ai_governor.mqh on any shadow field | Same grep in council_ai_governor.mqh → 0 matches |
| ISO-4 | No read dependency from council_strategies.mqh on any shadow field | Same grep in council_strategies.mqh → 0 matches |
| ISO-5 | No read dependency from core_trade_engine.mqh on any shadow field | Same grep in core_trade_engine.mqh → 0 matches |
| ISO-6 | No read dependency from main_ea.mq5 on any shadow field (beyond calling RunCouncilModePipeline) | Same grep in main_ea.mq5 → 0 matches beyond the pipeline call |
| ISO-7 | `WriteOpportunityLedgerRecord` return value used only for telemetry counter | Verify return value feeds only `g_total_trigger_writes++`; confirm no conditional execution path reads it |
| ISO-8 | `OL_ComputePlaybookShadowState()` reads only `reports[]`, `runtime`, `cfe` | Verify function body has no price reads, no indicator calls, no additional evaluation logic |
| ISO-9 | `playbook_state` field in JSONL is not read by any MT5 function | JSONL is append-only from MT5; MT5 does not read its own ledger file in the decision path |
| ISO-10 | council_quality value distribution is unchanged in 30-bar post-deployment window | Compare `council_quality` mean and std from 30 bars before vs 30 bars after; ∆mean < 0.005 |
| ISO-11 | Execution rate unchanged in 30-bar window | Count BUY+SELL decisions before vs after; ∆rate < 5% |
| ISO-12 | DSN/CRR block rates unchanged in 30-bar window | Count dsn_blocked and crr_blocked events before vs after; ∆rate < 5% |

---

## 12. Validation Framework

Five levels applied sequentially. A failure at any level triggers rollback before proceeding to the next.

### Level 1 — Compile Validation

| Check | Pass Criteria | Failure Action |
|---|---|---|
| MetaEditor compile | 0 errors, 0 warnings | Fix errors; do not deploy; do not reload MT5 |
| No unused variable warnings | 0 warnings | Resolve all; compiler warnings in MQL5 often indicate logic errors |
| Include file consistency | All `#include` paths valid | Fix path errors before compile |

### Level 2 — Runtime File Validation

| Check | Pass Criteria | Failure Action |
|---|---|---|
| EA reloads without error | MT5 expert properties show no load error | Check compile output; reload |
| Ledger file writes | New records appear in ai_opportunity_ledger.jsonl within first triggered strategy | Check file permissions; check FileOpen path |
| Schema version | `record_version` field matches expected version | Fix schema string |
| All new fields present | Every new field appears in first 5 trigger records | Fix JSON serialization |
| Summary file updates | ai_opportunity_summary.json reflects new schema_version | Fix SaveOpportunitySummary |
| Write failures = 0 | `write_failures` counter in summary = 0 | Investigate file I/O; check disk space |

### Level 3 — Decision Invariance Validation

**Measurement window:** 30 consecutive M1 bars with trigger_present=true in at least one strategy  
**Baseline:** Statistics from the 30 bars immediately before deployment

| Metric | Pass Criteria | Data Source |
|---|---|---|
| Trade execution rate | ∆ < 5% (e.g., if 2 trades/day before, 1.9–2.1 trades/day after) | ai_performance_journal.jsonl or MT5 terminal history |
| DSN block rate | ∆ < 5% | ai_opportunity_ledger.jsonl, `dsn_blocked` field |
| CRR block rate | ∆ < 5% | ai_opportunity_ledger.jsonl, `crr_blocked` field |
| council_quality mean | ∆mean < 0.005 | ai_opportunity_ledger.jsonl, `council_quality` field |
| consensus_strength mean | ∆mean < 0.010 | ai_opportunity_ledger.jsonl, `consensus_strength` field |

**Failure action:** If any metric exceeds threshold → immediate rollback; investigate cause; do not redeploy without root cause identified.

### Level 4 — Event Order Validation

Applies after Candidate 3 (EVENT_ORDER_TRACE_FIELDS_V1) is deployed.

| Check | Pass Criteria |
|---|---|
| `event_order_valid = true` rate | ≥ 95% of records |
| `eot_pre_decision_available = true` rate | ≥ 90% of records |
| `eot_late_evidence = false` rate | ≥ 95% of records |
| Any EOC violation detected | Alert for operator review; record `event_order_violation_reason` |

### Level 5 — Registry Alignment Validation

Applies after Candidate 4 (PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1) is deployed and ≥200 records accumulated.

| Check | Pass Criteria |
|---|---|
| All 17 strategies appear in ledger | 17/17 `strategy_id` values present |
| Zone mismatch rate | < 10% of records (strategy fires in wrong zone) |
| Playbook state distribution | RBSR and TPC show FORMING/NOT_PRESENT; VCR shows NOT_PRESENT (consistent with registry) |
| PLAYBOOK_VALID appearance | If PLAYBOOK_VALID appears: verify that a formal CONFIRMATION_PACKET was accepted; if not, flag as ARCHITECTURE_REVIEW_REQUIRED |
| Forbidden runtime influence | Zero references to alignment report in any decision code | IMMEDIATE HALT if found |

---

## 13. Rollback Framework

### Universal Pre-Deployment Steps (all candidates)

1. Create backup of every file to be modified:
   - `council_mode_types.mqh.bak_YYYYMMDD_HHMMSS`
   - `council_mode_runtime.mqh.bak_YYYYMMDD_HHMMSS`
   - For RCEM: `PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_YYYYMMDD_HHMMSS`
2. Record the current binary timestamp from `main_ea.ex5` before recompile
3. Record baseline metrics (30-bar window) from current ledger before any change

### Rollback Trigger Conditions

| Condition | Rollback Scope | Priority |
|---|---|---|
| Compile fails (any error or warning) | Revert changed files before reload | IMMEDIATE |
| Level 2 validation fails (write errors, missing fields) | Revert changed files; reload with restored backup | IMMEDIATE |
| Level 3 fails (decision invariance breach >5%) | Revert changed files; reload; investigate root cause | URGENT |
| Level 4 fails (event order violations >10%) | Revert Candidate 3 only; keep Candidate 1 if otherwise passing | URGENT |
| Level 5 fails (registry mismatch >20%) | Do not roll back source; flag for operator design review | REVIEW_REQUIRED |
| Any shadow field found in decision code (ISO-1 through ISO-9 fail) | IMMEDIATE halt; revert all Candidates deployed since last passing check | CRITICAL |

### Per-Candidate Rollback Steps

| Candidate | Files to Restore | Additional Steps |
|---|---|---|
| 1 (Ledger fields) | `council_mode_types.mqh` (remove 2 structs + initializers); `council_mode_runtime.mqh` (revert signature, schema versions, JSON block, call site) | Verify JSONL writes revert to V1B schema |
| 2 (Shadow emitter) | `council_mode_runtime.mqh` (remove `OL_ComputePlaybookShadowState()` call + population block) | Structs remain (Candidate 1 added them); `ol_pss` returns to defaults |
| 3 (Event trace) | `council_mode_runtime.mqh` (remove timestamp captures + `OL_ComputeEventOrderTrace()` call) | `OL_EventOrderTrace` struct remains; `ol_eot` returns to defaults |
| 4 (Alignment check) | Delete `packet_registry_alignment_check_v1.py` (Option A) or remove reporting function (Option B) | No MT5 file change needed for Option A |
| 5 (RCEM doc) | Restore `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` from backup (remove §30 or §16.X) | No source file change needed |

---

## 14. Risk Register

| # | Risk | Impact | Mitigation | Current Status |
|---|---|---|---|---|
| R-1 | Score leakage — a shadow field (playbook_state) is read by council_quality or consensus | HIGH — corrupts decision architecture; allows unvalidated playbook state to gate trades | ISO-1 through ISO-9 checklist mandatory before deployment; GFW-2 absolute | NOT_PRESENT (no shadow fields implemented yet) |
| R-2 | Gate leakage — a playbook state triggers a CRR or DSN condition | HIGH — starvation risk if PLAYBOOK_FORMING blocks trades | GFW-4; Level 3 decision invariance validation | NOT_PRESENT |
| R-3 | Playbook becomes a mega-strategy — combining multiple packet fields into a single weighted score that influences execution | HIGH — creates a hidden quality gate that cannot be audited | GFW-10 (no score/percentage); categorical states only; ISO full checklist | NOT_PRESENT |
| R-4 | V1 authority erosion — the playbook state is interpreted by operators as a permission layer | MEDIUM — leads to unauthorized source changes based on playbook_state readings | GFW-9 explicit in every candidate; this spec repeatedly states "observation only" | LOW — design discipline maintained |
| R-5 | Event ordering mismatch in MQL5 single-thread — timestamps are identical, making EOC validation trivially true | MEDIUM — event order trace provides false confidence; late evidence cannot be detected at 1-second resolution | Spec acknowledges limitation; recommend `GetMicrosecondCount()` addition as V2 refinement | KNOWN_LIMITATION — documented in §7.6 |
| R-6 | Late evidence misuse — a researcher retrospectively uses post-trade playbook_state to evaluate pre-trade decisions | MEDIUM — produces optimistic attribution; misrepresents system quality | `pre_decision_available` and `late_evidence` flags; Level 4 validation; operator training | NOT_PRESENT (fields not yet implemented) |
| R-7 | Registry mismatch ignored — alignment check produces alerts that are never acted on | MEDIUM — registry drifts from reality; future decisions made on stale assumptions | Alignment check outputs must be reviewed at defined intervals (e.g., every 200 new records); alerts must trigger PIML review task | NOT_PRESENT |
| R-8 | Over-instrumentation — too many new fields increase JSON record size and file I/O overhead | LOW-MEDIUM — potential latency in high-frequency M1 bars if write time exceeds tick interval | Level 2 write failure monitoring; spec adds ~35 new string fields; estimated +0.5KB per record; typical M1 bar is 1000ms — write should complete in < 2ms | DESIGN_REVIEW_REQUIRED — measure actual write overhead post-deployment |
| R-9 | JSON schema drift — `completed_links_json` is a raw JSON array string; if not properly formed, the JSONL record becomes invalid | MEDIUM — breaks downstream parsing | `OL_BuildLinkJson()` helper ensures valid format; validate array output in Level 2 | MITIGATED by helper function spec |
| R-10 | Operator misreading accepted research packet as runtime authority | MEDIUM — could lead to unauthorized gate implementation based on "accepted packet" status | GFW-14 explicit; every candidate restates accepted packet = research classification only | LOW — governance culture risk; addressed in documentation |
| R-11 | Strategy rescue bias — weak strategies (OBSERVE_ONLY in RCEM) receive attention to "fix" them rather than being correctly deprioritized | LOW — leads to parameter tuning and false improvement | §10 of Architecture Build Package explicitly prohibits parameter tuning; OBSERVE_ONLY is not a rescue signal | LOW — addressed in governance |
| R-12 | BDM RANGE_NEUTRAL finding misread as a valid gate — BDM fires best in RANGE_NEUTRAL (inverted result) and RCEM marks it ACTIVE there | LOW | RCEM notes explicitly state this is an unexpected result requiring DESIGN_REVIEW; no source gate authorized for RANGE_NEUTRAL improvement | MITIGATED in RCEM table note |

---

## 15. Future Codex Prompt Skeletons

These are minimum-viable skeleton prompts for future use. They are NOT final prompts and must be expanded with full context before operator issuance. Each is marked NOT_AUTHORIZED_HERE.

---

### Skeleton 1: OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1

```
[NOT_AUTHORIZED_HERE — skeleton only]

Target: OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1

Objective:
Add OL_PlaybookShadowState and OL_EventOrderTrace structs to council_mode_types.mqh,
extend WriteOpportunityLedgerRecord in council_mode_runtime.mqh to write new shadow
fields, and update schema version from OL_V1B_CROSS_FAMILY to OL_V1C_PLAYBOOK_SHADOW.

Allowed files:
- council_mode_types.mqh (new structs and initializers only)
- council_mode_runtime.mqh (extended signature, JSON fields, schema version, call site)

Forbidden files:
- All decision/gate/execution files (see IMPLEMENTATION_SPEC_PACKAGE_V1.md §5.4)

Implementation requirements:
- Add OL_PlaybookShadowState struct (fields per spec §5.5)
- Add OL_EventOrderTrace struct (fields per spec §5.5)
- Add initializer functions for both structs
- Extend WriteOpportunityLedgerRecord signature to (filePath, report, runtime, counter, cfe, pss, eot)
- Change record_version from "OL_V1B_CROSS_FAMILY" to "OL_V1C_PLAYBOOK_SHADOW" (L587)
- Change summary schema_version from "OL_SUMMARY_V1B_CROSS_FAMILY" to "OL_SUMMARY_V1C_PLAYBOOK_SHADOW" (L704)
- Add JSON field block (pss fields + eot fields) before closing "}" (after L667)
- Add ol_pss and ol_eot declaration + initialization in RunCouncilModePipeline before write loop (~L1197)
- Pass ol_pss and ol_eot to WriteOpportunityLedgerRecord call (~L1213)

Validation requirements (all must pass before reporting complete):
- L1: compile 0 errors 0 warnings
- L2: new fields appear in 5 trigger records; all 32 existing V1B fields still present
- L3: 30-bar decision invariance (execution rate ∆<5%, council_quality ∆mean<0.005)
- ISO: zero shadow field references in decision-layer files (grep verification)

Expected report:
- Confirm fields added and compiling
- Confirm schema version updated
- Confirm 5 sample records showing new fields
- Confirm ISO checklist passed
- Confirm L3 invariance window passed or in progress
```

---

### Skeleton 2: PLAYBOOK_STATE_SHADOW_EMITTER_V1

```
[NOT_AUTHORIZED_HERE — skeleton only]
[BLOCKED pending Candidate 1 live]

Target: PLAYBOOK_STATE_SHADOW_EMITTER_V1

Objective:
Implement OL_ComputePlaybookShadowState() in council_mode_runtime.mqh.
Populate ol_pss before the trigger write loop in RunCouncilModePipeline.
All states must be one of 6 valid categorical strings. No score. No gate. No weight.

Allowed files:
- council_mode_runtime.mqh only

Forbidden files:
- All decision/gate/execution/strategy files

Implementation requirements:
- Define OL_ComputePlaybookShadowState() per spec §6.3
- Evaluate all 3 playbooks per spec §6.4 and §6.5
- Determine playbook_id from which anchor strategy fires
- Build completed_links_json, missing_links_json, contradicted_links_json using OL_BuildLinkJson()
- Set failure_mode_present and failure_mode_type per spec §6.6
- Set pre_decision_available = true (function called after final_decision)
- Call site: replace OL_InitPlaybookShadowState(ol_pss) with OL_ComputePlaybookShadowState() return

Validation requirements:
- L1: compile 0 errors 0 warnings
- L2: all playbook_state values are one of 6 valid strings; no playbook_score field present
- L3: 30-bar decision invariance
- ISO: zero references to ol_pss.playbook_state in any decision file

Expected report:
- Sample records showing each playbook state category observed
- Confirm no numeric score field exists
- Confirm L3 invariance passed
```

---

### Skeleton 3: EVENT_ORDER_TRACE_FIELDS_V1

```
[NOT_AUTHORIZED_HERE — skeleton only]
[BLOCKED pending Candidate 1 live]

Target: EVENT_ORDER_TRACE_FIELDS_V1

Objective:
Implement OL_ComputeEventOrderTrace() and timestamp capture points in
RunCouncilModePipeline per spec §7.3 and §7.4.
Timestamps must be captured at the actual stage completion points.
event_order_valid = true if all timestamps satisfy monotonic EOC ordering.

Allowed files:
- council_mode_runtime.mqh only

Forbidden files:
- core_trade_engine.mqh and all decision/gate files
- Note: room_ts and stop_geometry_ts use pre-AI filter completion as proxy (documented in spec §7.4)

Validation requirements:
- L1: compile 0 errors 0 warnings
- L2: all 9 timestamp fields non-empty; context_ts ≤ decision_ts in all records
- L4: event_order_valid=true in ≥95% of records; eot_pre_decision_available=true in ≥90%
- L3: 30-bar decision invariance

Expected report:
- Sample records showing event order timestamps
- Confirm event_order_valid rates and pre_decision_available rates from first 50 records
```

---

### Skeleton 4: PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1 (Option A — Python)

```
[NOT_AUTHORIZED_HERE — skeleton only]
[BLOCKED pending Candidates 1+2 live with ≥200 records]

Target: PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1 (Python script, Option A)

Objective:
Create packet_registry_alignment_check_v1.py in nautilus_lab/scripts/.
Read ai_opportunity_ledger.jsonl and compare to PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1.md.
Produce packet_registry_alignment_report.json and alignment_summary.txt.
No MT5 files modified.

Allowed files:
- nautilus_lab/scripts/packet_registry_alignment_check_v1.py (new)
- nautilus_lab/outputs/packet_registry_alignment_report.json (new output)
- nautilus_lab/outputs/packet_registry_alignment_summary.txt (new output)

Forbidden files:
- All MT5 source files
- All runtime files

Implementation requirements:
- Load all V1C_PLAYBOOK_SHADOW records from JSONL
- For each strategy_id in records: verify existence in registry
- Compare observed playbook_state distribution to expected registry states
- Compare observed failure_mode_present rate to cert co-presence rates
- Flag any record where playbook_state=PLAYBOOK_VALID without a formally accepted CONFIRMATION_PACKET in registry
- Output formatted report with mismatch summary

Validation requirements:
- Script runs without error on ≥200 V1C records
- All 17 strategies present in report
- Mismatch alerts are human-readable and actionable

Expected report:
- Confirm script path and output files created
- Summarize top 3 mismatches (or "No significant mismatches" if clean)
- Confirm no MT5 source files modified
```

---

### Skeleton 5: RCEM_V1_DOCUMENTATION_UPDATE

```
[NOT_AUTHORIZED_HERE — skeleton only]
[NEAR_READY: blocked on Phase 3 reaching ≥8 certs; currently 7/17]

Target: RCEM_V1_DOCUMENTATION_UPDATE

Objective:
Add §30 RCEM_V1_DOCUMENTATION to PROJECT_INTELLIGENCE_MEMORY_LAYER.md.
Document regime-conditioned design intent for all 17 strategies.
Documentation only — no source change, no weight change, no RCEM runtime enforcement.

Allowed files:
- PROJECT_INTELLIGENCE_MEMORY_LAYER.md only (+ backup)

Forbidden files:
- All source files, runtime files, Nautilus files

Implementation requirements:
- Create backup: PROJECT_INTELLIGENCE_MEMORY_LAYER.md.bak_YYYYMMDD_HHMMSS
- Add new section "# §30 — RCEM_V1_DOCUMENTATION" at end of PIML
- Include RCEM table from IMPLEMENTATION_SPEC_PACKAGE_V1.md §9.3
- Include regime split summaries per certified strategy (reference cert section numbers)
- Include explicit disclaimer: "RCEM_V1 is documentation only — no source enforcement, no weight change, no gate change"

Validation requirements:
- PIML opens and reads without error
- §30 present with complete 17-strategy RCEM table
- No source file modified (verify with git diff or file timestamp check)
- RCEM state labels consistent with cited cert labels in §24–29

Expected report:
- Confirm §30 added to PIML at correct location
- Confirm backup created with correct timestamp
- Confirm 17/17 strategies have at least one RCEM cell entry
- Confirm 0 source file changes
```

---

## 16. Recommended Next Real Action

**Recommended next real action: RCEM_V1_DOCUMENTATION_UPDATE (Candidate 5)**

Reason: This is the single highest-value, lowest-risk action available. It is documentation-only, requires no source change, has negligible rollback risk, and produces the formal regime-conditioned design intent baseline that all future Phase 6 (EEWP) and Phase 1 (RCEM enforcement) work depends on.

The only prerequisite is reaching Phase 3 ≥8 certifications. Currently at 7/17. One additional Phase 3 certification — range_compression_breakout, mean_reversion_bounce, or fake_break_reversal — unblocks RCEM_V1_DOCUMENTATION_UPDATE immediately. range_compression_breakout is recommended as the 8th cert target because it:
1. Unlocks the VCR playbook evidence baseline (currently PLAYBOOK_NOT_PRESENT with zero data)
2. Is the highest-weight DATA_INSUFFICIENT strategy (vote_weight 0.95)
3. Has no prerequisite (M1/M5 data available; no live entries needed)

**Alternative if operator prefers instrumentation-first:** Proceed with Candidate 1 (OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1) immediately — no prerequisite beyond current live ledger state. This unlocks the full observation pipeline.

No micro-tests are recommended as the next action. The evidence collection phase for the established strategy families is substantially complete. Architecture build-out is the correct priority.

---

## 17. Completion Checklist

| Item | Status |
|---|---|
| PIML reviewed (§16, §22–29, REG.1–REG.9) | COMPLETE |
| Registry reviewed (all 17 strategies, 3 playbooks) | COMPLETE |
| Architecture Build Package reviewed (Packages A–E, Event Order Contract, ledger spec) | COMPLETE |
| MT5 source files read for insertion-point accuracy (council_mode_types.mqh, council_mode_runtime.mqh) | COMPLETE |
| Candidate 1: OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 specified (§5) | COMPLETE |
| Candidate 2: PLAYBOOK_STATE_SHADOW_EMITTER_V1 specified (§6) | COMPLETE |
| Candidate 3: EVENT_ORDER_TRACE_FIELDS_V1 specified (§7) | COMPLETE |
| Candidate 4: PACKET_REGISTRY_RUNTIME_ALIGNMENT_CHECK_V1 specified (§8) | COMPLETE |
| Candidate 5: RCEM_V1_DOCUMENTATION_UPDATE specified (§9) | COMPLETE |
| Cross-candidate dependency order defined (§10) | COMPLETE |
| Decision-path isolation requirements defined (§11 — ISO-1 through ISO-12) | COMPLETE |
| Validation framework defined (5 levels, §12) | COMPLETE |
| Rollback framework defined (§13) | COMPLETE |
| Risk register defined (12 risks, §14) | COMPLETE |
| Future Codex prompt skeletons defined (§15 — all 5 candidates) | COMPLETE |
| Recommended next real action stated (§16) | COMPLETE |
| No MT5 source files modified | VERIFIED |
| No runtime files modified | VERIFIED |
| No Nautilus scripts or certifications modified | VERIFIED |
| No compile executed | VERIFIED |
| No approval requested at any point | VERIFIED |
| All uncertainties labeled (DESIGN_REVIEW_REQUIRED, PENDING_CERT, UNKNOWN) | VERIFIED |
| All candidates marked NOT_AUTHORIZED_HERE | VERIFIED |
| Package complete | VERIFIED |

---

## Package Footer

```
PACKAGE_ID:                      IMPLEMENTATION_SPEC_PACKAGE_V1
PACKAGE_DATE:                    2026-05-08
PACKAGE_TYPE:                    SPECIFICATION — non-executed implementation design
FOLLOWS:                         ARCHITECTURE_BUILD_PACKAGE_V1.md
CANDIDATES_SPECIFIED:            5 (Candidates 1–5)
STRUCTS_SPECIFIED:               OL_PlaybookShadowState (17 fields) + OL_EventOrderTrace (13 fields)
INSERTION_POINTS_IDENTIFIED:     council_mode_types.mqh (before #endif); council_mode_runtime.mqh (L562, L587, L667, L704, L1197, L1213)
ISOLATION_RULES_DEFINED:         ISO-1 through ISO-12
VALIDATION_LEVELS_DEFINED:       L1–L5
ROLLBACK_TRIGGERS_DEFINED:       6 conditions per candidate
RISKS_REGISTERED:                12
RECOMMENDED_NEXT_ACTION:         RCEM_V1_DOCUMENTATION_UPDATE (Candidate 5) after 8th Phase 3 cert
ALTERNATIVE_NEXT_ACTION:         OPPORTUNITY_LEDGER_PLAYBOOK_FIELDS_SHADOW_V1 (Candidate 1) if instrumentation-first preferred
SYSTEM_STATUS:                   DEVELOPING — unchanged
MT5_SOURCE_CHANGED:              NO
RUNTIME_CHANGED:                 NO
NAUTILUS_CHANGED:                NO
COMPILE_EXECUTED:                NO
APPROVAL_REQUESTED:              NO
ALL_CANDIDATES_STATUS:           NOT_AUTHORIZED_HERE
RUNTIME_AUTHORITY:               V1 (MT5 EA) — permanent
GOVERNED_BY:                     PROJECT_INTELLIGENCE_MEMORY_LAYER.md
```
