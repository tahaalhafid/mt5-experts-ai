# FORCED_ENGINEERING_ACTIVATION_ARCHITECTURAL_EXECUTION_SPEC_REVIEW_V1

**Review Type:** Deep architectural / functional / trading-system implementation-quality review
**Subject:** FORCED_ENGINEERING_ACTIVATION_V1_IRREW_PCEA_IMPLEMENTATION_PLAN
**Authority:** Engineering Completion Mode (approved) — full modification authority
**Date:** 2026-05-09
**Source Inspection:** council_mode_types.mqh, council_mode_runtime.mqh, execution_estimator_v1.mqh, council_v1_state_composer.mqh, council_pre_ai_filter.mqh, main_ea.mq5

---

## A. Executive Verdict

**PLAN_APPROVED_FOR_CODEX_AFTER_REVISIONS**

The plan is architecturally sound and correctly aimed at converting shadow/ledger architecture into development-active trading architecture. It does not reduce to production-ready claims and correctly preserves all authority boundaries. However, **four mandatory revisions** must be applied before Codex executes:

1. **Sequencing error:** `execution_admission_family` is proposed for Package D but is required by Package C (Phase 4A needs primary executor family for cross-family scoping). Move types to Package A; compute identity in Package B.
2. **Phase 4A scope definition is under-specified:** "scoped context requires cross-family confirmation" needs a precise categorical source — not hardcoded zone_type assumptions. Define via consensus context, not zone string comparison.
3. **Execution Geometry Package D is partially already implemented** at diagnostic level (L10840-L10858 in DQ path, hardcoded-blocked). The new flag must add a SEPARATE enforcement path in the pre-order gate, distinct from the DQ/score path, to avoid re-entangling with score authority.
4. **Development WAIT collision protocol is missing:** When Phase 4A + Phase 4B + Phase 4C all request WAIT simultaneously, reason precedence must be defined explicitly in the spec.

No reduction in implementation depth is recommended. All 16 component targets are architecturally implementable as specified.

---

## B. High-Level Interpretation

The plan successfully moves from shadow/ledger architecture to development-active trading architecture. Specifically:

**Before this plan:** V1, IRREW, PCEA exist as design documents, OL attribution fields, PIML entries, and a governance firewall. They observe decisions; they produce no categorical development inputs.

**After this plan (all flags false):** Same decision behavior; new audit fields in ledger; no new decision effects. Development flags off = backward-compatible.

**After this plan (flags enabled):** Seven defined development paths can convert BUY/SELL to WAIT based on categorical state — each behind its own flag, each with a defined reason string, each auditable in the OL record. `execution_admission_family` is explicit and decoupled from `best_strategy_id`. `primary_thesis_strategy_id` is a semantic alias, not a new authority.

**What this is NOT:**
- Not production-ready activation (production acceptance checklist still required)
- Not score/weight reintroduction (categorical states only; no numeric thresholds in new paths)
- Not EEWP (no weight changes)
- Not IFR cohort admission (IFR excluded from `OperatingCohortFamilyAllowed()`)

The interpretation of the prior Development Complete declaration: it was valid under the shadow/firewall doctrine (all designed components were implemented at observability level). Under the forced-activation definition, several components (RCEM, playbook consumption, packet registry, failure detector mode, Phase 4A/4B/4C, execution geometry, execution admission identity) were documentation-only or ledger-only. This plan closes that gap.

---

## C. Required Revisions Before Codex

### C-REV-01: execution_admission_family must enter Package A (types) and Package B (compute)

**Problem:** Phase 4A (Package C) needs to determine whether the dominant-side primary executor has the same family as the confirming vote. This requires `execution_admission_family` to be known before Phase 4A fires. Package D (the proposed home for admission identity) runs after Phase 4A has already executed in Package C.

**Fix:** 
- Package A: Add `CouncilExecutionAdmissionIdentity` struct and `primary_thesis_strategy_id` + `execution_admission_family` fields
- Package B: Add `IRREW_ResolveAdmissionIdentity()` computation after strategy set evaluation, store in the new report
- Package C: Phase 4A reads `execution_admission_family` from the already-computed report (not from Package D)
- Package D: Focuses on order-gate integration (pre-submission cohort check and execution geometry) only

### C-REV-02: Phase 4A scope detection must be categorical, not zone_type string

**Problem:** The plan says "trend-continuation or breakout contexts only" — but detecting this via zone_type string comparisons (`zone_type == "TREND_CONTINUATION"`) creates a brittle hardcoded dependency on env string values. Zone strings can evolve; hardcoded comparisons are compile-invisible bugs.

**Fix:** Define Phase 4A scope via the aggregator's `consensus_type` and `trend_judge_supportive` field, not zone_type string:
- Phase 4A fires when: `agg.trend_judge_supportive == true` OR `agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION AND agg.dominant_side != "NONE"`
- This captures TC/breakout contexts without hardcoding zone strings
- Phase 4A does NOT fire in range/reversal contexts because trend_judge_supportive will be false

### C-REV-03: Execution Geometry gate must be a new enforcement path, not a re-enable of DQ gate

**Problem:** The execution geometry advisory already exists in the NO-SCORE HARD-LOCKED DQ path (main_ea.mq5:L10840-L10858). It checks ADVERSE/POOR geometry but has `// return false; // [NO-SCORE HARD-LOCKED]` — diagnostic only. The plan's Package D cannot re-enable that path because doing so would re-entangle with DQ/score authority.

**Fix:** Package D adds a NEW separate check in the pre-order submission gate (after `OperatingEnvelopeEvaluate()` passes, before `AttemptTradeEntry()`), guarded by `EnableIRREWExecutionGeometryDev`. This is distinct from the DQ path and does not touch the DQ/score block. The geometry fields used (labels only, not `execution_geometry_score` numeric) come from `gExecEstimation` which is already computed as a global (L12714) and is safe to read.

### C-REV-04: Define development WAIT collision protocol

**Problem:** When Phase 4A + 4B + 4C all request WAIT, the spec is silent on reason precedence, multiple-reason collection, and ledger representation.

**Fix:** Define a single collector pattern:
- `irrew_development_wait_requested` = true if ANY dev path fires
- `irrew_development_wait_reason` = first-firing reason (highest priority: 4B > 4A > 4C > RCEM > Geometry)
- `irrew_development_wait_reasons_all` = pipe-separated list of all firing reasons (for ledger audit)
- Final action: BUY/SELL → WAIT (regardless of how many paths fired)
- Priority order: Phase 4B (exhaustion/failure, immediate risk) > Phase 4A (structural confirmation gap) > Phase 4C (thesis quality) > RCEM (regime restriction) > Geometry (pre-order)

### C-REV-06 (Critical): Phase 4A must use ROLE-BASED cross-family check, not packet-based

**Problem:** The spec's Phase 4A contract checks for "an accepted CONFIRMATION_PACKET from a cross-family strategy." The PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1 confirms that only 1 formal packet is accepted system-wide: MSR's FAILURE_MODE_PACKET (not a CONFIRMATION_PACKET). Zero CONFIRMATION_PACKET entries are formally accepted in TC zone. Using a packet-based check would produce near-100% WAIT starvation in TC zone regardless of TPC fire rate — the opposite of targeted cross-family confirmation enforcement.

**Fix:** Phase 4A uses ROLE-BASED cross-family detection, not packet-based:
```
IRREW_HasCrossFamilyRoleConfirmation(reports, dominant_side, execution_admission_family)
  → returns true if any strategy:
    (a) votes on dominant_side (BUY/SELL matching dominant)
    (b) has role == CONFIRM or TREND_JUDGE
    (c) has family != execution_admission_family
    (d) is not BLOCKED (eligibility != COUNCIL_ELIGIBILITY_BLOCKED)
    (e) vote_weight > 0.0
```

This is the correct development-phase implementation: checks structural role-based cross-family coverage, not formal packet acceptance (which requires runtime evidence accumulation — unavailable at dev-activate time).

The packet registry confirmation requirement (formally accepted CONFIRMATION_PACKET) is the PRODUCTION ACCEPTANCE standard, not the development-flag activation standard.

**Downstream fix:** Remove `packetReport` from `IRREW_HasCrossFamilyRoleConfirmation()` signature. Phase 4A does not consume packet registry for its WAIT decision; packet registry feeds OL audit fields only.

### C-REV-05 (Advisory): JSON schema versioning for IRREW-dev era records

Add `irrew_schema_version: "OL_V1C_IRREW_DEV_V1"` to OL records when `EnableIRREWDevelopmentConsumption=true`. When flag is false, schema version remains unchanged. This allows downstream parsers to identify IRREW-dev era records without reading individual field presence.

---

## D. Package-by-Package Review

### Package A — Identity, Registry, and Audit Types

**Purpose:** Establish all new types, enums, structs, and input flags before any runtime logic touches them. Zero runtime behavior change.

**Files touched:**
- `council_mode_types.mqh` — new structs and enums
- `main_ea.mq5` — new input flags

**Source insertion points:**
- `council_mode_types.mqh`: Insert new structs after `CouncilRuntimeResult` (line ~596). Insert new enums before the struct definitions (after existing enums at L19-122).
- `main_ea.mq5`: Insert new `input bool` flags after existing authority stack inputs (~L94 block), in a dedicated `// IRREW Development Activation` group.

**Required new enums in council_mode_types.mqh:**
```mql5
enum CouncilThesisQualityState
{
   THESIS_QUALITY_UNKNOWN = 0,
   THESIS_QUALITY_CLEAR,
   THESIS_QUALITY_THIN,
   THESIS_QUALITY_INCOMPLETE,
   THESIS_QUALITY_CONTRADICTED,
   THESIS_QUALITY_UNCERTAIN
};

enum CouncilPacketClass
{
   PACKET_CLASS_UNKNOWN = 0,
   PACKET_CLASS_ALPHA_TRIGGER,
   PACKET_CLASS_CONFIRMATION,
   PACKET_CLASS_FAILURE_MODE,
   PACKET_CLASS_REJECTED,
   PACKET_CLASS_RESEARCH_ONLY
};

enum CouncilPacketStatus
{
   PACKET_STATUS_UNKNOWN = 0,
   PACKET_STATUS_ACCEPTED,
   PACKET_STATUS_CONTEXT_VALID,
   PACKET_STATUS_CONTEXT_INVALID,
   PACKET_STATUS_REJECTED,
   PACKET_STATUS_RESEARCH_ONLY
};

enum CouncilPlaybookState
{
   PLAYBOOK_STATE_UNKNOWN = 0,
   PLAYBOOK_STATE_FORMING,
   PLAYBOOK_STATE_VALID,
   PLAYBOOK_STATE_LATE,
   PLAYBOOK_STATE_CONTRADICTED,
   PLAYBOOK_STATE_INVALID,
   PLAYBOOK_STATE_NOT_APPLICABLE
};

enum CouncilIRREWDevAction
{
   IRREW_DEV_ACTION_NONE = 0,
   IRREW_DEV_ACTION_WAIT_PHASE4A,
   IRREW_DEV_ACTION_WAIT_PHASE4B,
   IRREW_DEV_ACTION_WAIT_PHASE4C,
   IRREW_DEV_ACTION_WAIT_RCEM,
   IRREW_DEV_ACTION_WAIT_GEOMETRY,
   IRREW_DEV_ACTION_AUDIT_ONLY
};

enum CouncilRCEMEligibility
{
   RCEM_ELIGIBILITY_ALLOWED = 0,
   RCEM_ELIGIBILITY_ALLOWED_BY_NO_CERTIFIED_RESTRICTION,
   RCEM_ELIGIBILITY_REDUCED,
   RCEM_ELIGIBILITY_OBSERVE_ONLY,
   RCEM_ELIGIBILITY_BLOCKED
};
```

**Required new structs in council_mode_types.mqh:**
```mql5
struct CouncilExecutionAdmissionIdentity
{
   bool   valid;
   string primary_thesis_strategy_id;
   string primary_thesis_family;
   string execution_admission_family;
   string execution_admission_source;   // DIRECT / FALLBACK_BEST_STRATEGY / NOT_RESOLVED
   string execution_admission_reason;
   bool   admission_family_is_ifr;
   bool   admission_blocked_by_cohort;
};

struct CouncilPacketRegistryConsumptionReport
{
   bool   valid;
   string strategy_id;
   CouncilPacketClass  packet_class;
   CouncilPacketStatus packet_status;
   string packet_class_text;
   string packet_status_text;
   bool   satisfies_thesis_anchor;
   bool   satisfies_confirmation;
   bool   is_failure_mode_packet;
   bool   is_rejected_or_research_only;
   string packet_registry_note;
};

struct CouncilPlaybookConsumptionReport
{
   bool   valid;
   string playbook_id;
   CouncilPlaybookState playbook_state;
   string playbook_state_text;
   bool   advisory_wait_preference;
   bool   eligible_thesis_marker;
   CouncilThesisQualityState thesis_quality_state;
   string thesis_quality_state_text;
   bool   risk_warning_present;
   bool   v1_caution_present;
   string runtime_authority_status;    // always "NONE"
};

struct CouncilIRREWDevelopmentActionReport
{
   bool   valid;
   bool   enabled;
   bool   development_wait_requested;
   string development_wait_reason;       // primary reason
   string development_wait_reasons_all;  // pipe-separated all reasons
   CouncilIRREWDevAction primary_action;

   // Phase 4A
   bool   phase4a_enabled;
   bool   phase4a_fired;
   bool   phase4a_cross_family_confirm_missing;
   string phase4a_expected_confirm_family;
   string phase4a_found_confirm_family;

   // Phase 4B
   bool   phase4b_enabled;
   bool   phase4b_fired;
   bool   phase4b_exhaustion_detected;
   bool   phase4b_failure_aligned_against_direction;
   string phase4b_reason;

   // Phase 4C
   bool   phase4c_enabled;
   bool   phase4c_fired;
   CouncilThesisQualityState phase4c_thesis_quality;
   string phase4c_thesis_quality_text;

   // RCEM
   bool   rcem_enabled;
   bool   rcem_fired;
   CouncilRCEMEligibility rcem_eligibility;
   string rcem_eligibility_text;
   string rcem_rule_applied;

   // Playbook advisory
   bool   playbook_advisory_enabled;
   bool   playbook_valid_emitted;
   CouncilPlaybookState playbook_consumed_state;

   // Geometry (applied pre-order, not pre-council)
   bool   geometry_enabled;
   bool   geometry_fired;
   string geometry_label_at_fire;
};
```

**Required new input flags in main_ea.mq5:**
```mql5
input bool   EnableIRREWDevelopmentConsumption   = false;
input bool   EnableIRREWPhase4ADev               = false;
input bool   EnableIRREWPhase4BDev               = false;
input bool   EnableIRREWPhase4CDev               = false;
input bool   EnableIRREWRCEMDev                  = false;
input bool   EnableIRREWExecutionGeometryDev      = false;
input bool   EnableIRREWPlaybookAdvisoryDev       = false;
```

**Required new global in main_ea.mq5:**
```mql5
CouncilIRREWDevelopmentActionReport gIRREWDevReport;
CouncilExecutionAdmissionIdentity   gAdmissionIdentity;
```

**Producer-consumer contracts:** Package A produces no runtime logic — types and flags only. All consumers depend on Package A being compiled first.

**Risks:**
- MQL5 enum vs int initialization: ensure all new enums have explicit zero value as default
- Struct Init functions required for each new struct before first use

**Required Init functions:**
```mql5
void InitCouncilExecutionAdmissionIdentity(CouncilExecutionAdmissionIdentity &r)
void InitCouncilPacketRegistryConsumptionReport(CouncilPacketRegistryConsumptionReport &r)
void InitCouncilPlaybookConsumptionReport(CouncilPlaybookConsumptionReport &r)
void InitCouncilIRREWDevelopmentActionReport(CouncilIRREWDevelopmentActionReport &r)
```

**Compile/test:** 0 errors / 0 warnings. No runtime change. Log: `compile_forced_engineering_activation_pkg_a_<timestamp>.log`.

**Rollback:** Revert council_mode_types.mqh and main_ea.mq5 inputs to pre-change state using `.bak_<timestamp>`. No state in other files.

---

### Package B — Playbook, Packet, Failure, and Admission Identity Compute

**Purpose:** Wire registry resolvers and compute all new reports into the pipeline. Add admission identity compute. Add OL audit fields. No final-decision behavior change yet (all new reports are advisory/audit only).

**Files touched:**
- `council_mode_runtime.mqh` — registry resolvers, report population, OL audit fields
- `council_aggregator.mqh` — add admission identity compute after best_strategy_id resolution (if best_strategy_id is set here)

**Source insertion points (council_mode_runtime.mqh):**

1. **Registry resolvers** — add as standalone functions near the top of the runtime file (after includes):
   - `IRREW_PacketClassForStrategy(strategy_id)` — returns `CouncilPacketClass`
   - `IRREW_PacketStatusForStrategy(strategy_id)` — returns `CouncilPacketStatus`
   - `IRREW_PlaybookForStrategy(strategy_id)` — returns playbook_id string
   - `IRREW_PlaybookStateFromShadow(playbook_id, shadow_state_string)` — returns `CouncilPlaybookState`
   - `IRREW_IsRejectedOrUnknownPacket(CouncilPacketStatus status)` — returns bool
   - `IRREW_PacketSatisfiesThesis(CouncilPacketClass cls, CouncilPacketStatus status)` — returns bool
   - `IRREW_PacketSatisfiesConfirmation(CouncilPacketClass cls, CouncilPacketStatus status, string confirm_family, string primary_family)` — returns bool

2. **Admission identity compute** — add after `RunCouncilStrategySet()` return, before `BuildCouncilAggregateReport()`:
   ```
   IRREW_ResolveAdmissionIdentity(reports, agg.dominant_side, gAdmissionIdentity)
   ```
   This function:
   - Iterates over reports[18] looking for dominant-side eligible strategies not in IFR family
   - Picks highest-weight non-IFR strategy on dominant side as execution_admission_family source
   - Falls back to LAB_InferFamilyFromStrategyId(agg.best_strategy_id) if no direct match
   - Sets `execution_admission_family`, `execution_admission_source`, `primary_thesis_strategy_id`

3. **Playbook/packet report population** — add after admission identity, still pre-filter:
   - Build `CouncilPacketRegistryConsumptionReport` for the primary thesis strategy
   - Build `CouncilPlaybookConsumptionReport` using OL playbook shadow state + PLAYBOOK_VALID emission logic
   - Both are advisory/audit only at this stage — no decision effect in Package B

4. **PLAYBOOK_VALID emission check** — separate function:
   ```
   IRREW_EvaluatePlaybookValid(admission, reports, agg, playbook_report)
   ```
   Emits PLAYBOOK_VALID only when ALL are true:
   - `admission.execution_admission_family != "IMBALANCE_FILL_REVERSAL"`
   - Packet for primary strategy is ALPHA_TRIGGER_PACKET status ACCEPTED or CONTEXT_VALID
   - At least one CONFIRMATION_PACKET from a DIFFERENT family is present, ACCEPTED or CONTEXT_VALID
   - No FAILURE_MODE_PACKET is active on same side
   - Pre-decision timing is valid (called before final decision)
   - IFR/fvg_tpb: PLAYBOOK_VALID requires IFR CONFIRMATION_PACKET → absent in current strategy set → emits PLAYBOOK_FORMING by default

5. **OL audit field additions** — add to the JSONL write block:
   New fields added only when `EnableIRREWDevelopmentConsumption=true` check:
   ```
   irrew_schema_version, irrew_development_consumption_enabled,
   irrew_packet_class, irrew_packet_status, irrew_playbook_consumed,
   irrew_playbook_action_candidate, irrew_thesis_quality_state,
   irrew_failure_packet_id, irrew_failure_mode_direction,
   irrew_failure_mode_action_candidate, irrew_v1_caution_present,
   irrew_risk_warning_present, irrew_development_wait_requested,
   irrew_development_wait_reason, primary_thesis_strategy_id,
   execution_admission_family, execution_admission_source,
   execution_admission_reason
   ```
   These fields are written as part of the existing JSONL structure with no line breaks.

**Producer-consumer contracts:**
| Producer | Consumer | Flag | Effect |
|---|---|---|---|
| `IRREW_ResolveAdmissionIdentity()` | Phase 4A (Pkg C), cohort check (Pkg D), OL fields | Always computed when EnableIRREWDevelopmentConsumption=true | execution_admission_family in gAdmissionIdentity |
| `IRREW_EvaluatePlaybookValid()` | OL fields, Phase 4C (thesis quality source) | EnableIRREWPlaybookAdvisoryDev | playbook_consumed_state in gPlaybookReport |
| `IRREW_BuildPacketReport()` | OL fields, Phase 4A (confirmation packet type check) | EnableIRREWDevelopmentConsumption | packet_class in gPacketReport |

**What happens if resolver returns UNKNOWN:**
- PACKET_CLASS_UNKNOWN: `satisfies_thesis_anchor=false`, `satisfies_confirmation=false`, writes audit only
- PLAYBOOK_STATE_UNKNOWN: treated as PLAYBOOK_FORMING (advisory_wait_preference=false, thesis_quality not upgraded)
- PACKET_STATUS_UNKNOWN: treated as PACKET_STATUS_REJECTED for confirmation purposes (conservative)

**What happens if packet is REJECTED or RESEARCH_ONLY:**
- Cannot satisfy thesis anchor
- Cannot satisfy confirmation
- Cannot upgrade thesis_quality_state
- May write `is_rejected_or_research_only=true` in audit fields
- Has no decision effect in Package B (all audit only)

**Risks:**
- JSON comma safety: all new OL fields must be added at the end of the existing JSON object, with consistent leading comma prefixes
- Null/default string values in MQL5: initialize all string fields to `""` not `null`
- String length of pipe-separated lists: cap at reasonable length (256 chars) to avoid log bloat

**Compile/test:** 0 errors / 0 warnings. New OL fields appear in jsonl records when consumption flag=true. When flag=false, no new fields. Log: `compile_forced_engineering_activation_pkg_b_<timestamp>.log`.

**Rollback:** Revert council_mode_runtime.mqh and council_aggregator.mqh to `.bak_<timestamp>`.

---

### Package C — V1 / Pre-AI Development Consumption

**Purpose:** Wire the development action report into the decision pipeline. When flags are enabled, Phase 4A/4B/4C and RCEM can downgrade BUY/SELL to WAIT. No REJECT. No weight changes. No authority modifications.

**Files touched:**
- `council_mode_runtime.mqh` — post-structural, pre-final-decision development action step
- `council_pre_ai_filter.mqh` — minor addition if needed for Phase 4A CRR context detection
- `council_v1_state_composer.mqh` — read-only (verify V1 state fields available)

**Architectural placement:** The development action step runs AFTER `RunCouncilPreAIFilter()` and AFTER `ApplyAuthorityStackPilot()` have determined the structural result, but BEFORE the final `RunCouncilModePipeline()` return. Specifically:

```
... [existing pipeline] ...
ApplyAuthorityStackPilot(...)        ← existing
[NEW] ApplyIRREWDevelopmentActions() ← Package C — can WAIT if enabled; cannot REJECT
[FINAL] return result                ← existing
```

This placement means:
- Authority Stack (P4+V1) has already applied — structural rejects cannot be un-rejected
- Pre-AI gates have already applied — DSN/CRR/DOMINANT_SIDE are set
- IRREW dev actions can only WAIT on surviving BUY/SELL decisions
- IRREW dev actions have full context: agg, pre, failDet, gov, admission, packet, playbook

**`ApplyIRREWDevelopmentActions()` function contract:**
```mql5
void ApplyIRREWDevelopmentActions(
   const CouncilAggregateReport &agg,
   const CouncilPreAIGateReport &pre,
   const CouncilFailurePatternReport &failDet,
   const CouncilGovernorStateReport &gov,
   const CouncilEnvironmentReport &env,
   const CouncilExecutionAdmissionIdentity &admission,
   const CouncilPlaybookConsumptionReport &playbookReport,
   const CouncilPacketRegistryConsumptionReport &packetReport,
   CouncilIRREWDevelopmentActionReport &devAction,
   CouncilDecision &decision,   // in/out — can be downgraded to WAIT
   string &reason               // in/out — updated with first-firing dev reason
)
```

**Phase 4A implementation:**
```
if(EnableIRREWPhase4ADev && EnableIRREWDevelopmentConsumption)
{
   // Scope: fires only when trend_judge_supportive=true or HIGH_CONVICTION
   bool in_tc_breakout_context = (agg.trend_judge_supportive ||
                                   agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION);
   if(in_tc_breakout_context && (decision == COUNCIL_DECISION_BUY || decision == COUNCIL_DECISION_SELL))
   {
      // Check if a cross-family confirmation packet exists and is context-valid
      // Check for cross-family ROLE-BASED confirmation (not packet-based)
      // Only 1 formal packet is accepted system-wide (MSR FAILURE_MODE); packet-based check
      // would produce near-100% WAIT starvation. Use role-based vote check instead.
      bool has_cross_family_confirm = IRREW_HasCrossFamilyRoleConfirmation(
         reports, agg.dominant_side, admission.execution_admission_family);
      if(!has_cross_family_confirm)
      {
         devAction.phase4a_fired = true;
         devAction.phase4a_cross_family_confirm_missing = true;
         devAction.development_wait_requested = true;
         // Append reason — priority below Phase 4B
         if(!devAction.phase4b_fired)  // 4B has higher priority
         {
            reason = "IRREW_PHASE4A_DEV_WAIT_MISSING_CROSS_FAMILY_CONFIRM";
         }
         AppendWaitReason(devAction, "IRREW_PHASE4A_DEV_WAIT_MISSING_CROSS_FAMILY_CONFIRM");
      }
   }
}
```

**Phase 4B implementation:**
```
if(EnableIRREWPhase4BDev && EnableIRREWDevelopmentConsumption)
{
   // Scope: TC/breakout context; exhaustion aligned against trade direction
   bool in_tc_breakout_context = (agg.trend_judge_supportive ||
                                   agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION);
   bool exhaustion_against_direction = (failDet.exhaustion_risk_detected &&
                                         failDet.continuation_fragile);
   if(in_tc_breakout_context && exhaustion_against_direction &&
      (decision == COUNCIL_DECISION_BUY || decision == COUNCIL_DECISION_SELL))
   {
      devAction.phase4b_fired = true;
      devAction.phase4b_exhaustion_detected = true;
      devAction.development_wait_requested = true;
      reason = "IRREW_PHASE4B_DEV_WAIT_FAILURE_EXHAUSTION";  // highest priority
      AppendWaitReason(devAction, "IRREW_PHASE4B_DEV_WAIT_FAILURE_EXHAUSTION");
   }
   else if(failDet.exhaustion_risk_detected)
   {
      // Write risk_warning_present without waiting — Phase 4B writes risk signal even when flag=false
      playbookReport.risk_warning_present = true;  // audit only
   }
}
```

**Phase 4C implementation (Thesis Quality State — NO council_quality):**
Thesis Quality State is derived ENTIRELY from categorical boolean and enum fields:
```
Inputs (all categorical, no numeric thresholds):
- agg.consensus_type           → NONE/NARROW/DIVERSE/HIGH_CONVICTION
- agg.confirm_role_present     → bool
- agg.exhaustion_warning       → bool
- failDet.continuation_fragile → bool
- failDet.pressure_level       → NONE/LOW/MEDIUM/HIGH/CRITICAL
- playbookReport.playbook_consumed_state → enum
- admission.packet_class for primary thesis → enum

Derivation rules (evaluated in order, first match wins):
THESIS_QUALITY_CONTRADICTED:
  playbookReport.playbook_consumed_state == PLAYBOOK_CONTRADICTED
  OR failDet.pressure_level == HIGH or CRITICAL
  (triggers WAIT when Phase4C enabled)

THESIS_QUALITY_INCOMPLETE:
  !agg.confirm_role_present
  OR agg.consensus_type == NONE
  (triggers WAIT when Phase4C enabled)

THESIS_QUALITY_UNCERTAIN:
  agg.exhaustion_warning AND agg.trend_judge_supportive
  (triggers WAIT when Phase4C enabled)

THESIS_QUALITY_THIN:
  agg.consensus_type == NARROW AND agg.confirm_role_present
  (audit only — no WAIT; too common to gate)

THESIS_QUALITY_CLEAR:
  agg.consensus_type == DIVERSE or HIGH_CONVICTION
  AND agg.confirm_role_present
  AND NOT CONTRADICTED/INCOMPLETE/UNCERTAIN
  (no WAIT; eligible_thesis_marker = true)

THESIS_QUALITY_UNKNOWN:
  fallback (no conditions met)
```

**IMPORTANT:** Phase 4C WAIT triggers only on CONTRADICTED, INCOMPLETE, and UNCERTAIN — NOT on THIN. THIN is too common (NARROW consensus is a valid trade under current architecture) to gate on behind a dev flag.

**RCEM implementation:**
```
if(EnableIRREWRCEMDev && EnableIRREWDevelopmentConsumption)
{
   CouncilRCEMEligibility rcem = IRREW_GetRCEMEligibility(
      admission.execution_admission_family, env.regime_label);
   if(rcem == RCEM_ELIGIBILITY_BLOCKED)
   {
      // Sparse matrix entry: explicit BLOCKED rule → WAIT
      devAction.rcem_fired = true;
      devAction.development_wait_requested = true;
      AppendWaitReason(devAction, "IRREW_RCEM_DEV_WAIT_BLOCKED_REGIME_STRATEGY");
   }
   // ALLOWED_BY_NO_CERTIFIED_RESTRICTION = allowed (no hidden block)
}
```

**RCEM initial sparse matrix:** At launch, only bollinger_reclaim TREND_UP SELL is encoded (already implemented as source gate in Phase 5A — do NOT duplicate). The RCEM dev matrix starts nearly empty; each entry is added only when Nautilus evidence certifies a restriction.

**V1 integration:** The existing V1 Permission Authority Stack (P4+V1) already runs before this step. The IRREW dev actions do NOT modify V1 state, V1 eligibility, or authority stack behavior. The dev action step reads V1 context but does not write to it.

**Development WAIT final merge:**
```
if(devAction.development_wait_requested)
{
   if(decision == COUNCIL_DECISION_BUY || decision == COUNCIL_DECISION_SELL)
   {
      decision = COUNCIL_DECISION_WAIT;
      // reason already updated with primary reason per priority order
      devAction.primary_action = (highest priority firing IRREW_DEV_ACTION_*)
   }
}
```

**Risks:**
- Phase 4A cannot fire if admission_identity was not computed (Package B dependency): guard with `devAction.enabled = admission.valid`
- Phase 4B using `failDet.continuation_fragile` captures TC/breakout fragility but may also fire in range zones if a trend stall is detected. Mitigation: also require `in_tc_breakout_context` (same scope guard as Phase 4A)
- Phase 4C CONTRADICTED sourced from `failDet.pressure_level` could fire in any zone. The WAIT is appropriate because HIGH/CRITICAL pressure means recent trades are failing — this is zone-agnostic risk
- MQL5: `CouncilDecision` enum must be passed by reference to allow in-place downgrade from BUY/SELL to WAIT

**Compile/test:** 0 errors / 0 warnings. Log: `compile_forced_engineering_activation_pkg_c_<timestamp>.log`.

**Rollback:** Revert council_mode_runtime.mqh and council_pre_ai_filter.mqh to `.bak_<timestamp>`.

---

### Package D — Execution Geometry and Cohort Admission Decoupling

**Purpose:** Wire execution geometry as pre-order categorical gate. Decouple cohort admission from best_strategy_id by consuming execution_admission_family. Preserve all existing stop/target/lot geometry untouched.

**Files touched:**
- `main_ea.mq5` — pre-order admission check + execution geometry gate
- `level_awareness_brake.mqh` — verify LAB reads admission_family correctly after decoupling
- `execution_estimator_v1.mqh` — read-only (existing enum labels used)

**Source insertion points (main_ea.mq5):**

**1. Cohort admission decoupling:**
Current code reads cohort via best_strategy_id path through RuntimeInferDecisionCandidateFromRouted → LAB_InferFamily → cohort check.

After Package D:
- Before cohort check: if `EnableIRREWDevelopmentConsumption && gAdmissionIdentity.valid`, use `gAdmissionIdentity.execution_admission_family` instead of inferring from best_strategy_id
- The inference fallback remains active when `!gAdmissionIdentity.valid` (backward-compatible)
- `primary_thesis_strategy_id` is logged wherever `best_strategy_id` was logged for thesis identity purposes

**2. Execution geometry gate (NEW — separate from DQ path):**
Insert AFTER `OperatingEnvelopeEvaluate()` block and AFTER council decision is `BUY` or `SELL`, but BEFORE `AttemptTradeEntry()`:

```mql5
if(EnableIRREWExecutionGeometryDev && EnableIRREWDevelopmentConsumption
   && gHasExecEstimation
   && (decision == ENTER_BUY || decision == ENTER_SELL))
{
   bool geometry_blocks = (gExecEstimation.execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY" ||
                           gExecEstimation.execution_geometry_label == "POOR_EXECUTION_GEOMETRY");
   if(geometry_blocks)
   {
      // Downgrade to WAIT — DO NOT modify gExecEstimation or stop/target geometry
      decision = RUNTIME_HOLD;  // or equivalent WAIT signal at order gate
      gIRREWDevReport.geometry_fired = true;
      gIRREWDevReport.geometry_label_at_fire = gExecEstimation.execution_geometry_label;
      // Log audit: IRREW_GEOMETRY_DEV_WAIT_ADVERSE_OR_POOR
   }
   // THIN: write warning audit only — no WAIT
   // UNKNOWN: write warning audit only — no WAIT
}
```

**CRITICAL DISTINCTION:** This is NOT the DQ path at L10840-L10858. Those are inside the score/quality evaluation block which is `// [NO-SCORE HARD-LOCKED]`. This new check is a categorical label check at the order gate, using only the string label, not the numeric `execution_geometry_score`. It does not touch score authority.

**EQ-DIAG fields:**
- `sl_vs_m5_atr_ratio` and `level_context_at_entry` remain unchanged in performance_journal.mqh (already live)
- `stop_anchor_state`: NOT implemented; was removed from criteria in SRR resolution; do not re-add
- `room_to_target_state` and `stop_inside_noise_flag`: Add as audit-only fields in ExecutionEstimationResult if data is available cheaply from existing geometry. If computing these requires new logic, defer to production acceptance phase — do not add complexity here.
- `mae_pts` / `mfe_pts`: remain as -1 placeholders until trades complete (existing behavior)

**FVG_TPB / IFR in Package D:**
- fvg_tpb remains ACTIVE as thesis/advisory contributor
- `execution_admission_family=IMBALANCE_FILL_REVERSAL` remains blocked — Package D does NOT add IFR to `OperatingCohortFamilyAllowed()`
- When `gAdmissionIdentity.execution_admission_family == "IMBALANCE_FILL_REVERSAL"`, set `admission_blocked_by_cohort=true` and fall back to secondary executor family. If no secondary executable family exists, decision becomes WAIT (no executable family).

**Risks:**
- The `gExecEstimation` global is computed at L12714 AFTER `eval.decision` is determined. This means it runs post-council but pre-submission — the correct timing for Package D's pre-order gate.
- `gHasExecEstimation` guards the use of `gExecEstimation` — always check this flag before reading geometry label.
- Package D execution geometry check must only apply to BUY/SELL decisions that survived the council pipeline, not to existing WAIT/REJECT decisions.

**Compile/test:** 0 errors / 0 warnings. Log: `compile_forced_engineering_activation_pkg_d_<timestamp>.log`.

**Rollback:** Revert main_ea.mq5 and level_awareness_brake.mqh to `.bak_<timestamp>`.

---

### Package E — Final Report and PIML Update

**Purpose:** Document the full implementation, update PIML with current architecture state, produce the final report, and state the updated Development Complete status.

**Files touched:**
- `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` — append §31
- Create `FORCED_ENGINEERING_ACTIVATION_OF_ALL_TARGET_ARCHITECTURE_DESIGNS_V1_REPORT.md`

**PIML §31 required content:**
- Current State Anchor (new development-active architecture)
- IRREW/PCEA active architecture section (component classification table)
- New input flags and their default states
- Rejected components (SPC-001-010, EEWP, auto weights)
- Ledger-only final components (mae/mfe placeholders, playbook attribution only)
- Updated Production Acceptance debt

**Final report required verdict (if all packages compile 0 errors / 0 warnings):**
`DEVELOPMENT_COMPLETE_TRADING_ARCHITECTURE_NOW_ACTIVE`

**Compile/test:** No new compile (Package E is documentation only). All four compile logs from A-D must be present and confirmed 0 errors / 0 warnings.

**Rollback:** Revert PIML to pre-change backup; delete final report file.

---

## E. Component Activation Matrix

| Component | Activation Class | Development Effect | Production Effect | Flag | Consumer | Authority Touched | Risk | Required Audit Field |
|---|---|---|---|---|---|---|---|---|
| playbook_state | CATEGORICAL_ADVISORY_INPUT | Thesis quality state source; CONTRADICTED → WAIT (flag on) | None (attribution layer) | EnableIRREWPlaybookAdvisoryDev | Phase 4C, OL fields | None (attribution only) | PLAYBOOK_VALID emission integrity | irrew_playbook_consumed |
| Packet Registry | CATEGORICAL_ADVISORY_INPUT | Packet class/status informs thesis completion and confirmation validity | None (documentation resolver) | EnableIRREWDevelopmentConsumption | Phase 4A (confirm check), Phase 4C, OL | None (advisory only) | REJECTED/RESEARCH_ONLY must not satisfy confirmation | irrew_packet_class, irrew_packet_status |
| Playbook Registry | CATEGORICAL_ADVISORY_INPUT | Resolver for playbook_id → state vocabulary | None | EnableIRREWPlaybookAdvisoryDev | Playbook consumption report, OL | None (advisory only) | Resolvers must return UNKNOWN safely | irrew_playbook_consumed |
| Failure Detector Mode | CATEGORICAL_RISK_INPUT | exhaustion_risk + continuation_fragile → Phase 4B WAIT | None (advisory remains) | EnableIRREWPhase4BDev | Phase 4B action, Phase 4C thesis quality source | None (no direct block without flag) | Too-broad firing in range zones (scoped to TC/breakout context guard) | irrew_failure_mode_action_candidate |
| RCEM | V1_ELIGIBILITY_INPUT (sparse) | BLOCKED regime entry → WAIT via dev report | None (documentation reconciliation) | EnableIRREWRCEMDev | RCEM eligibility check, OL | None (WAIT only; no direct eligibility flag mutation) | Empty matrix at launch must default to ALLOWED_BY_NO_CERTIFIED_RESTRICTION | irrew_development_wait_reason (RCEM) |
| Phase 4A | DEVELOPMENT_FLAGGED | Missing cross-family confirm in TC/breakout → WAIT | None | EnableIRREWPhase4ADev | Dev action report, OL | None (WAIT only; no structural gate change) | TC starvation if TPC fire rate low | irrew_development_wait_reason (4A) |
| Phase 4B | DEVELOPMENT_FLAGGED | Exhaustion/failure aligned against direction in TC/breakout → WAIT | None | EnableIRREWPhase4BDev | Dev action report, OL | None (WAIT only) | Fires from existing failDet fields (no new MFI calibration required for dev flag) | irrew_development_wait_reason (4B) |
| Phase 4C | DEVELOPMENT_FLAGGED | Thesis Quality State derived from categorical signals; CONTRADICTED/INCOMPLETE/UNCERTAIN → WAIT | None | EnableIRREWPhase4CDev | Dev action report, OL | None (categorical derivation only; no council_quality) | THIN must NOT trigger WAIT (too common) | irrew_thesis_quality_state |
| Stop Geometry / EQ-DIAG | EXECUTION_GEOMETRY_INPUT | ADVERSE/POOR label → pre-order WAIT | None | EnableIRREWExecutionGeometryDev | Pre-order gate in main_ea.mq5 | None (categorical label only; not numeric score) | Must not re-enable DQ/score path | irrew_development_wait_reason (geometry) |
| execution_admission_family | IMPLEMENT_NOW | Explicit cohort identity; decoupled from best_strategy_id | Cohort admission uses explicit family | EnableIRREWDevelopmentConsumption | Phase 4A (confirm family check), cohort gate, OL | None (replaces inference; same authority) | Fallback must be safe (LAB_InferFamily is existing function) | execution_admission_family |
| primary_thesis_strategy_id | IMPLEMENT_NOW | Semantic alias for best_strategy_id in thesis context | Thesis identity is explicit | EnableIRREWDevelopmentConsumption | OL fields, PIML attribution | None (alias, not new authority) | Must not replace best_strategy_id (backward compat) | primary_thesis_strategy_id |
| FVG_TPB / IFR | DEVELOPMENT_FLAGGED (thesis) | fvg_tpb is thesis-active; PLAYBOOK_VALID requires absent IFR confirmation packet → FORMING | No IFR cohort admission | EnableIRREWDevelopmentConsumption | Playbook report, admission identity | None (IFR excluded from cohort) | IFR must remain absent from OperatingCohortFamilyAllowed() | irrew_playbook_consumed (IFR_FORMING state) |
| V1 permission integration | ALREADY_ACTIVE (unchanged) | Dev actions run after V1; cannot un-reject V1 decisions | V1 REJECT survives dev actions | EnableAuthorityStackPilot (existing) | ApplyAuthorityStackPilot (existing) | P4+V1 unchanged | None | (existing V1 fields) |
| Risk State Policy Engine | ALREADY_ACTIVE (audit addition) | Add `irrew_risk_warning_present` field from risk state to dev report | Risk block survives dev actions | None (existing enforcement) | gRiskPolicy.block_new_trades (existing) | None (existing path unchanged) | None | irrew_risk_warning_present |
| V1C / Opportunity Ledger | IMPLEMENT_NOW (audit fields) | New IRREW audit fields added when consumption=true; schema version updated | Attribution layer expanded | EnableIRREWDevelopmentConsumption | OL write path | None (ledger only) | JSON comma safety; field count growth | irrew_schema_version = "OL_V1C_IRREW_DEV_V1" |

---

## F. Authority Boundary Map

```
V1 PERMISSION AUTHORITY (unchanged):
  Input:  agg.v1_policy_posture → NATIVE/CONDITIONAL/DEPRIORITIZED/INFORMATIONAL
  Gate:   ApplyAuthorityStackPilot (P4 + V1)
  Effect: → REJECT (cannot be un-rejected by dev actions)
  IRREW can influence: NOTHING in this layer
  IRREW dev actions run AFTER V1 — V1 REJECTs survive

RISK PROTECTION AUTHORITY (unchanged):
  Input:  gRiskPolicy.block_new_trades
  Gate:   OperatingEnvelopeSetBlock (L2720-2727)
  Effect: → Block before council pipeline
  IRREW can influence: NOTHING in this layer
  Risk State Engine runs BEFORE council pipeline
  Dev action report reads risk_warning_present from gRiskPolicy state (audit only)

STRUCTURAL GATE AUTHORITY (unchanged):
  Input:  DSN, CRR, DOMINANT_SIDE
  Gate:   RunCouncilPreAIFilter
  Effect: → WAIT or REJECT
  IRREW can influence: NOTHING — Phase 4A WAIT is a SEPARATE subsequent step
  Phase 4A does NOT modify CRR threshold or DSN score

IRREW DEVELOPMENT AUTHORITY (NEW — categorical advisory only):
  Input:  categorical states from council evaluation
  Gate:   ApplyIRREWDevelopmentActions (AFTER V1, AFTER pre-AI filter)
  Effect: BUY/SELL → WAIT only (never REJECT)
  Controlled by: EnableIRREWDevelopmentConsumption master flag
  Flag=false: zero decision effect

EXECUTION AUTHORITY (unchanged + pre-order categorical gate):
  Input:  council decision → order submission
  Gate:   OperatingEnvelopeEvaluate → AttemptTradeEntry
  New:    Execution geometry categorical check (Package D)
  Effect: BUY/SELL → WAIT at pre-order gate if ADVERSE/POOR geometry (flag=true)
  Does NOT modify: stop placement, lot sizing, target geometry

ATTRIBUTION / LEARNING AUTHORITY (unchanged + expanded):
  Input:  all council state
  Gate:   OL write path
  Effect: ledger records; no decision effect
  New:    IRREW audit fields in OL records when consumption=true
  PLAYBOOK_VALID: thesis completeness marker only — no permission, no cohort bypass

PRODUCTION BLOCKED:
  - EEWP (design-only; no implementation path)
  - SPC-001 through SPC-010 (all BLOCKED/EARLY_RESEARCH)
  - IFR operating cohort admission
  - Automatic weight changes
  - DQ path re-enable (score authority)

REJECTED:
  - stop_anchor_state (never implemented; removed)
  - OBSERVE_ONLY multiplier change (requires OL audit first)
  - playbook_score or any numeric playbook authority
  - council_quality bonus from playbook state
```

---

## G. No-Score Regression Check

**Explicit proof that each potential score re-entry path is blocked:**

| Risk Vector | Status | Prevention Mechanism |
|---|---|---|
| `playbook_score` as numeric field | BLOCKED | New structs contain no numeric score fields; thesis quality is enum only |
| `completion_pct` or percentage-based thesis | BLOCKED | Thesis Quality State is derived from categorical booleans only; no arithmetic involving vote counts or weighted percentages |
| `council_quality` used in Phase 4C | BLOCKED | Phase 4C derivation rules explicitly forbid `council_quality`; source: categorical booleans from agg (confirm_role_present, exhaustion_warning, consensus_type enum, failDet.pressure_level enum) |
| `confidence_score` gating | BLOCKED | No confidence_score in new struct fields; no confidence threshold in dev action logic |
| `execution_geometry_score` (numeric) gating | BLOCKED | Package D uses ONLY `execution_geometry_label` string comparison (ADVERSE/POOR); `execution_geometry_score` (0..1 double) is NOT used in the gate condition |
| `automatic weight changes` | BLOCKED | No weight field in any new struct; no multiplier applied to vote_weight anywhere in packages A-D |
| EEWP | BLOCKED | Design-only; not implemented in any package |
| PLAYBOOK_VALID as permission or bypass | BLOCKED | `runtime_authority_status = "NONE"` is mandatory in all playbook reports; PLAYBOOK_VALID sets `eligible_thesis_marker=true` only — no cohort bypass, no V1 bypass, no authority override |
| RCEM numeric gate | BLOCKED | RCEM returns categorical enum (ALLOWED/REDUCED/OBSERVE_ONLY/BLOCKED); no threshold comparison |
| Failure detector numeric score as gate | BLOCKED | Phase 4B uses `failDet.exhaustion_risk_detected` (bool) and `failDet.continuation_fragile` (bool) only; numeric scores (`continuation_risk_score`, etc.) are in the report but not used for dev action decisions |

**Static grep checks (see Section M):** After all packages compile, run:
```
rg "playbook_score|completion_pct|completion_percentage|council_quality.*WAIT|confidence.*threshold|automatic weight|EEWP|execution_geometry_score.*<"
```
Must return no new hits in modified files.

---

## H. PLAYBOOK_VALID Contract

**Definition:** `PLAYBOOK_STATE_VALID` in `CouncilPlaybookState` enum means: the current thesis has a confirmed alpha anchor, a cross-family confirmation from an accepted confirmation packet, and no active failure mode packet. It is a thesis completeness label — it certifies completeness, not quality, and grants zero permission.

**Allowed emit conditions (ALL must be true):**
1. `admission.execution_admission_family` is not IMBALANCE_FILL_REVERSAL (IFR excluded)
2. Primary strategy packet class = ALPHA_TRIGGER_PACKET with status ACCEPTED or CONTEXT_VALID
3. At least one CONFIRMATION_PACKET from a DIFFERENT family than primary is ACCEPTED or CONTEXT_VALID in the current bar's strategy evaluations
4. No FAILURE_MODE_PACKET is ACCEPTED or CONTEXT_VALID on the same direction as the dominant side
5. Called before final decision is locked (pre-decision timing)

**Allowed consumers:**
- OL ledger fields (`irrew_playbook_consumed`, `irrew_thesis_quality_state`)
- Phase 4C thesis quality derivation (PLAYBOOK_VALID → thesis_quality inputs cleared of INVALID/CONTRADICTED state)
- Development action report (`playbook_valid_emitted=true` in audit)

**Forbidden consumers:**
- V1 permission gate (PLAYBOOK_VALID cannot override V1 REJECT)
- Cohort admission (PLAYBOOK_VALID cannot add IFR to cohort)
- Council quality gate (PLAYBOOK_VALID cannot bypass Phase 4C CONTRADICTED state)
- Risk state engine (PLAYBOOK_VALID cannot bypass block_new_trades)
- Order submission (PLAYBOOK_VALID cannot bypass execution geometry gate)

**IFR/FVG_TPB handling:**
- `fvg_tpb` (IMBALANCE_FILL_REVERSAL) is an ALPHA_TRIGGER_PACKET candidate
- PLAYBOOK_VALID for IFR requires a CONFIRMATION_PACKET from a non-IFR family that is ACCEPTED
- No IFR CONFIRMATION_PACKET currently exists in the 18-strategy set
- Therefore: fvg_tpb's playbook state = PLAYBOOK_STATE_FORMING by default
- This is correct — IFR remains in development observation until a confirmation architecture is defined

**Event-order requirement:**
`IRREW_EvaluatePlaybookValid()` must be called AFTER `RunCouncilStrategySet()` (strategy reports available) and AFTER `IRREW_ResolveAdmissionIdentity()` (primary family known), but BEFORE `ApplyIRREWDevelopmentActions()` (Phase 4C reads playbook state). This places it in Package B's compute stage, which is correct per the revised sequencing.

**Ledger fields required:**
- `irrew_playbook_consumed` (string — playbook_state_text)
- `irrew_playbook_action_candidate` (string — advisory_wait_preference or eligible_thesis_marker)
- `irrew_v1_caution_present` (bool)
- `irrew_risk_warning_present` (bool)

---

## I. Phase 4A / 4B / 4C Contract

### Phase 4A — Missing Cross-Family Confirmation

| Field | Value |
|---|---|
| Flag | EnableIRREWPhase4ADev (AND EnableIRREWDevelopmentConsumption) |
| Scope | In-scope when: `agg.trend_judge_supportive == true` OR `agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION` |
| Categorical trigger | No accepted cross-family CONFIRMATION_PACKET is present for the dominant direction |
| Cross-family definition | A strategy voting on the dominant direction, with CONFIRM or TREND_JUDGE role, whose family ≠ `admission.execution_admission_family`. **NOT** a formally accepted CONFIRMATION_PACKET — see C-REV-06. |
| Allowed action | BUY/SELL → WAIT |
| Forbidden action | REJECT; modifying CRR threshold; modifying DSN score; modifying council_quality |
| Reason string | `"IRREW_PHASE4A_DEV_WAIT_MISSING_CROSS_FAMILY_CONFIRM"` |
| Out-of-scope behavior | Range/reversal context (trend_judge_supportive=false, not HIGH_CONVICTION): no Phase 4A check; trade proceeds normally |
| Audit fields | `phase4a_fired`, `phase4a_cross_family_confirm_missing`, `phase4a_expected_confirm_family`, `phase4a_found_confirm_family` |
| Test case (flag on) | TC zone, trend_judge_supportive=true, only TREND_CONTINUATION confirms present → WAIT |
| Test case (flag off) | Same setup → BUY/SELL proceeds normally |
| Test case (cross-family present) | TC zone, TPC strategy (TREND_PULLBACK_CONT family) confirms → no WAIT |

### Phase 4B — Failure/Exhaustion WAIT

| Field | Value |
|---|---|
| Flag | EnableIRREWPhase4BDev (AND EnableIRREWDevelopmentConsumption) |
| Scope | In-scope when: `agg.trend_judge_supportive == true` OR HIGH_CONVICTION (same as Phase 4A) |
| Categorical trigger | `failDet.exhaustion_risk_detected == true AND failDet.continuation_fragile == true` |
| Allowed action | BUY/SELL → WAIT; risk_warning_present=true even when flag=false (audit only) |
| Forbidden action | REJECT; modifying failure detector scores; modifying governor advisory flags |
| Reason string | `"IRREW_PHASE4B_DEV_WAIT_FAILURE_EXHAUSTION"` |
| Priority | Highest among all dev actions (Phase 4B fires first in reason precedence) |
| Audit fields | `phase4b_fired`, `phase4b_exhaustion_detected`, `phase4b_failure_aligned_against_direction`, `phase4b_reason` |
| Test case (flag on) | TC zone, exhaustion_risk_detected=true, continuation_fragile=true → WAIT |
| Test case (flag off) | Same setup → irrew_risk_warning_present=true in OL; BUY/SELL proceeds |
| Test case (not fragile) | exhaustion_risk_detected=true but continuation_fragile=false → no WAIT |

### Phase 4C — Thesis Quality State

| Field | Value |
|---|---|
| Flag | EnableIRREWPhase4CDev (AND EnableIRREWDevelopmentConsumption) |
| Scope | All zones; zone-agnostic |
| State derivation | Categorical only; no council_quality, no numeric thresholds |
| WAIT-triggering states | THESIS_QUALITY_CONTRADICTED, THESIS_QUALITY_INCOMPLETE, THESIS_QUALITY_UNCERTAIN |
| Non-WAIT states | THESIS_QUALITY_THIN (audit only), THESIS_QUALITY_CLEAR (no action), THESIS_QUALITY_UNKNOWN (audit only) |
| Forbidden | Any use of council_quality, confidence_score, consensus_strength float for state derivation |
| CONTRADICTED source | `playbookReport.playbook_state == PLAYBOOK_CONTRADICTED` OR `failDet.pressure_level == HIGH/CRITICAL` |
| INCOMPLETE source | `!agg.confirm_role_present` OR `agg.consensus_type == COUNCIL_CONSENSUS_NONE` |
| UNCERTAIN source | `agg.exhaustion_warning == true AND agg.trend_judge_supportive == true` |
| THIN source | `agg.consensus_type == COUNCIL_CONSENSUS_NARROW AND agg.confirm_role_present` — AUDIT ONLY |
| CLEAR source | `consensus DIVERSE/HIGH_CONVICTION AND confirm_role_present AND NOT contradicted/incomplete/uncertain` |
| Reason strings | `"IRREW_PHASE4C_DEV_WAIT_THESIS_CONTRADICTED"`, `"IRREW_PHASE4C_DEV_WAIT_THESIS_INCOMPLETE"`, `"IRREW_PHASE4C_DEV_WAIT_THESIS_UNCERTAIN"` |
| Audit fields | `phase4c_fired`, `phase4c_thesis_quality`, `phase4c_thesis_quality_text` |
| Test case | confirm_role_present=false, flag on → INCOMPLETE → WAIT |
| Test case | NARROW consensus + confirm present, flag on → THIN → NO WAIT |
| Test case | failDet.pressure_level=HIGH, flag on → CONTRADICTED → WAIT |

---

## J. execution_admission_family Contract

**Producer:** `IRREW_ResolveAdmissionIdentity()` in council_mode_runtime.mqh

**Compute timing:** After `RunCouncilStrategySet()`, before `BuildCouncilAggregateReport()` — reports[18] are available; agg.dominant_side may not yet be set. Use the pre-aggregated dominant vote direction from strategy reports directly (count dominant direction votes independently).

**Algorithm:**
1. Determine dominant direction from reports[18]: count BUY vs SELL weighted votes; pick dominant
2. Iterate reports[18]; for each strategy voting on dominant direction:
   - Skip if vote_weight == 0.0 (frozen)
   - Skip if strategy_family == "IMBALANCE_FILL_REVERSAL" (IFR cohort exclusion)
   - Track highest-weight eligible strategy
3. If a dominant-side eligible strategy found: set `execution_admission_family = LAB_InferFamilyFromStrategyId(strategy_id)` and `execution_admission_source = "DIRECT"`
4. If no dominant-side eligible strategy found (e.g., only IFR voted on dominant side): fall back to `LAB_InferFamilyFromStrategyId(agg.best_strategy_id)` and `execution_admission_source = "FALLBACK_BEST_STRATEGY"`
5. Set `primary_thesis_strategy_id = agg.best_strategy_id` (alias, not replacement)

**Fallback behavior:** Always safe — LAB_InferFamilyFromStrategyId is an existing function that returns a string family or "UNKNOWN_FAMILY".

**Relation to best_strategy_id:** `best_strategy_id` remains unchanged. `primary_thesis_strategy_id = best_strategy_id`. They are the same value. `primary_thesis_strategy_id` is the semantic alias for IRREW-context thesis identity; `best_strategy_id` remains the original field for backward compatibility.

**IFR handling:** `IMBALANCE_FILL_REVERSAL` may NOT appear as `execution_admission_family`. If fvg_tpb is the only dominant-side voter, fallback is used. If fallback also resolves to IFR (e.g., best_strategy_id = "fvg_tpb"), set `execution_admission_family = "IMBALANCE_FILL_REVERSAL"` and `admission_blocked_by_cohort = true`. Decision becomes WAIT (no executable family for cohort admission).

**Cohort behavior:** When `gAdmissionIdentity.valid && EnableIRREWDevelopmentConsumption`, cohort check reads `gAdmissionIdentity.execution_admission_family` instead of inferring. This is the same value that would be inferred but now it's explicit and auditable.

**Audit fields:** `execution_admission_family`, `execution_admission_source`, `execution_admission_reason`, `admission_blocked_by_cohort`, `primary_thesis_strategy_id`.

---

## K. Execution Geometry Contract

**Source fields:** `gExecEstimation.execution_geometry_label` (string) — one of five values: `"STRONG_EXECUTION_GEOMETRY"`, `"ACCEPTABLE_EXECUTION_GEOMETRY"`, `"THIN_EXECUTION_GEOMETRY"`, `"POOR_EXECUTION_GEOMETRY"`, `"ADVERSE_EXECUTION_GEOMETRY"`.

**State categories and actions:**
| Label | Action | Notes |
|---|---|---|
| STRONG_EXECUTION_GEOMETRY | None | Proceed |
| ACCEPTABLE_EXECUTION_GEOMETRY | None | Proceed |
| THIN_EXECUTION_GEOMETRY | Audit warning only | No WAIT |
| POOR_EXECUTION_GEOMETRY | WAIT (flag on) | Pre-order gate |
| ADVERSE_EXECUTION_GEOMETRY | WAIT (flag on) | Pre-order gate |
| (empty / invalid) | Audit warning only | gHasExecEstimation guard prevents empty case |

**Flag:** `EnableIRREWExecutionGeometryDev AND EnableIRREWDevelopmentConsumption`

**Where WAIT is applied:** AFTER council pipeline completes and decision is BUY/SELL, BEFORE `AttemptTradeEntry()`. Specifically in the order gate block in main_ea.mq5 — NOT inside RunCouncilModePipeline().

**What it cannot change:** stop placement, lot size, TP target, SL distance, spread tolerance. These are governed by core_trade_engine.mqh which is not touched.

**Audit fields:** `irrew_development_wait_reason` (when geometry fires), `geometry_fired`, `geometry_label_at_fire` in gIRREWDevReport.

**Test cases:**
- gExecEstimation.execution_geometry_label = "ADVERSE_EXECUTION_GEOMETRY", flag on → WAIT + audit
- gExecEstimation.execution_geometry_label = "THIN_EXECUTION_GEOMETRY", flag on → no WAIT, audit warning only
- gHasExecEstimation = false → skip entire geometry gate (gExecEstimation is uninitialized)
- Flag off → skip geometry gate; execution geometry label appears in OL as existing field

---

## L. Ledger / JSON Schema Review

**Schema versioning:**
- When `EnableIRREWDevelopmentConsumption=true`: write `"irrew_schema_version":"OL_V1C_IRREW_DEV_V1"` as first new field
- When flag=false: no irrew_schema_version field (existing schema unchanged)

**New fields and null/default values:**
| Field | Type | Default (flag=false or not set) | Notes |
|---|---|---|---|
| irrew_schema_version | string | omitted | Only written when consumption=true |
| irrew_development_consumption_enabled | bool | false | Always written when record is created |
| irrew_packet_class | string | "UNKNOWN" | Written when consumption=true |
| irrew_packet_status | string | "UNKNOWN" | Written when consumption=true |
| irrew_playbook_consumed | string | "PLAYBOOK_STATE_UNKNOWN" | Written when playbook advisory=true |
| irrew_playbook_action_candidate | string | "" | Written when playbook advisory=true |
| irrew_thesis_quality_state | string | "THESIS_QUALITY_UNKNOWN" | Written when Phase4C=true |
| irrew_failure_packet_id | string | "" | Written when failure mode packet present |
| irrew_failure_mode_direction | string | "" | Written when failure mode packet present |
| irrew_failure_mode_action_candidate | string | "" | Written when failure mode packet present |
| irrew_v1_caution_present | bool | false | Written when consumption=true |
| irrew_risk_warning_present | bool | false | Written when consumption=true |
| irrew_development_wait_requested | bool | false | Written when consumption=true |
| irrew_development_wait_reason | string | "" | Written when wait is requested |
| primary_thesis_strategy_id | string | agg.best_strategy_id | Always when consumption=true (alias) |
| execution_admission_family | string | "" | When consumption=true and identity resolved |
| execution_admission_source | string | "NOT_RESOLVED" | When consumption=true |
| execution_admission_reason | string | "" | When consumption=true |

**JSON safety:**
- All new fields appended at end of existing JSON object, before closing `}`
- Each field preceded by `,` (consistent with existing pattern)
- String values escaped using existing `PJ_EscapeJsonMini()` function
- Bool values: `true` or `false` (lowercase, no quotes)
- No trailing commas

**Parser compatibility:**
- New fields are additive — existing parsers will ignore unknown fields if they use robust JSON parsing
- Old records (pre-implementation) will not have irrew_* fields — parsers should treat missing fields as default/null
- Schema version field allows explicit detection of IRREW-dev era records

**Record size growth estimate:**
Approximately 400-600 bytes per IRREW-dev record (15-18 new fields at ~30 bytes average). Within acceptable range for JSONL format.

---

## M. Static Acceptance Checklist

After all packages compile, run these checks on modified files only:

```bash
# 1. No new score authority paths
rg "playbook_score|completion_pct|completion_percentage|council_quality.*playbook|council_quality.*WAIT" council_mode_runtime.mqh council_pre_ai_filter.mqh council_mode_types.mqh main_ea.mq5

# 2. No numeric geometry score used as gate condition
rg "execution_geometry_score.*<|execution_geometry_score.*>" main_ea.mq5 council_mode_runtime.mqh

# 3. No automatic weight changes
rg "vote_weight\s*=|baseline_weight\s*=|weight_delta\s*=" council_mode_runtime.mqh council_pre_ai_filter.mqh council_strategies.mqh

# 4. PLAYBOOK_VALID not used as permission or cohort bypass
rg "PLAYBOOK_VALID.*REJECT\|PLAYBOOK_VALID.*cohort\|PLAYBOOK_VALID.*permission\|PLAYBOOK_VALID.*allow" council_mode_runtime.mqh main_ea.mq5

# 5. IFR not added to operating cohort
rg "IMBALANCE_FILL_REVERSAL.*OperatingCohort\|OperatingCohortFamilyAllowed.*IFR\|OperatingCohortFamilyAllowed.*IMBALANCE" main_ea.mq5 level_awareness_brake.mqh

# 6. primary_thesis_strategy_id present wherever best_strategy_id used for thesis identity
rg "best_strategy_id" council_mode_runtime.mqh main_ea.mq5 | wc -l
# Compare before and after — new usage sites should also have primary_thesis_strategy_id

# 7. execution_admission_family in all decision/ledger traces
rg "execution_admission_family" council_mode_runtime.mqh main_ea.mq5

# 8. All new runtime-changing behavior guarded by development flags
rg "EnableIRREWPhase4ADev\|EnableIRREWPhase4BDev\|EnableIRREWPhase4CDev\|EnableIRREWRCEMDev\|EnableIRREWExecutionGeometryDev" council_mode_runtime.mqh main_ea.mq5
# Every WAIT in new paths must be inside one of these flag guards

# 9. No REJECT in new IRREW dev paths
rg "COUNCIL_DECISION_REJECT\|RUNTIME_REJECT" council_mode_runtime.mqh | grep -v "ApplyAuthorityStackPilot\|RunCouncilPreAIFilter\|OperatingEnvelopeSetBlock"
# New IRREW dev code must not produce REJECT

# 10. No DQ path re-enable
rg "NO-SCORE HARD-LOCKED" main_ea.mq5
# Confirm all [NO-SCORE HARD-LOCKED] return false comments are still present
```

---

## N. Runtime / Tester Acceptance Checklist

### All flags false — invariance checks
- [ ] Decision outcomes match pre-implementation behavior on identical bar sequence
- [ ] Ledger records appear with new `irrew_development_consumption_enabled:false` field only
- [ ] No `irrew_schema_version` field in records when consumption flag=false
- [ ] `execution_admission_family` field may appear (computed) but has no decision effect
- [ ] `primary_thesis_strategy_id` matches `best_strategy_id` in all records

### Individual flag tests (each flag on, others off)
- [ ] Phase 4A only: TC-zone bar with only same-family confirmation → WAIT with reason PHASE4A_DEV_WAIT_*
- [ ] Phase 4A only: TC-zone bar with cross-family TPC confirmation → no WAIT
- [ ] Phase 4A only: Range-zone bar → no Phase 4A check, no WAIT from 4A
- [ ] Phase 4B only: Bar with exhaustion_risk_detected=true + continuation_fragile=true in TC context → WAIT
- [ ] Phase 4B only: Same setup but flag=false → irrew_risk_warning_present=true in OL, no WAIT
- [ ] Phase 4C only: Bar with confirm_role_present=false → THESIS_INCOMPLETE → WAIT
- [ ] Phase 4C only: Bar with NARROW consensus + confirm present → THESIS_THIN → no WAIT
- [ ] Phase 4C only: Bar with pressure_level=HIGH → THESIS_CONTRADICTED → WAIT
- [ ] RCEM only: Bollinger_reclaim SELL in TREND_UP → RCEM_BLOCKED → WAIT (if matrix entry exists)
- [ ] Geometry only: Bar with ADVERSE geometry → pre-order WAIT
- [ ] Geometry only: Bar with THIN geometry → no WAIT, audit warning
- [ ] Playbook only: fvg_tpb context → PLAYBOOK_STATE_FORMING (no IFR confirmation packet)

### Combined flag tests
- [ ] Phase 4A + 4B both fire → WAIT with primary reason = 4B (higher priority)
- [ ] Phase 4A + 4C both fire → WAIT with primary reason = 4A (higher priority than 4C)
- [ ] All dev flags on + geometry fires → single WAIT with geometry reason in audit, all reasons in reasons_all

### MT5 Strategy Tester fixed replay
- [ ] Fixed XAUUSD M5 data: run with all flags false → compare decisions to pre-implementation reference
- [ ] Fixed BTCUSD M5 data: run with all flags false → confirm 0 decision differences
- [ ] Run with Phase 4B only on: confirm WAIT appears when exhaustion conditions met; proceed otherwise

### Live/demo production acceptance dependencies (not in scope of this implementation)
- [ ] XAUUSD_FVG_TPB_POST_RELOAD_RUNTIME_VALIDATION_PACKAGE_V1 (RDL-001 through RDL-013)
- [ ] Production Acceptance Checklist (57 items, PAC-A through PAC-O) — not started; requires XAUUSD validation

---

## O. Codex Implementation Prompt Outline

**Package order:** A → B → C → D → E (strict; each depends on prior)

**Package A guardrails for Codex:**
- Add types to council_mode_types.mqh ONLY — no runtime logic
- Add input flags to main_ea.mq5 ONLY — in dedicated `// IRREW Development Activation` group
- All new enums must have explicit zero-value `_UNKNOWN = 0` default
- All new structs must have corresponding `void Init<StructName>(...)` functions
- No changes to any other file
- Compile: 0 errors / 0 warnings required before Package B

**Package B guardrails for Codex:**
- Add resolvers and compute functions to council_mode_runtime.mqh
- `IRREW_ResolveAdmissionIdentity()` must be called before `BuildCouncilAggregateReport()`
- `IRREW_EvaluatePlaybookValid()` must be called after admission identity is set
- OL field additions: append at end of existing JSON object; use leading comma pattern
- No changes to council_pre_ai_filter.mqh or authority stack in this package
- `runtime_authority_status = "NONE"` in all playbook reports — hard-coded, never conditional
- Compile: 0 errors / 0 warnings required before Package C

**Package C guardrails for Codex:**
- `ApplyIRREWDevelopmentActions()` runs AFTER `ApplyAuthorityStackPilot()` and BEFORE function return in `RunCouncilModePipeline()`
- Phase 4A NEVER fires in range/reversal context — guard with `trend_judge_supportive || HIGH_CONVICTION`
- Phase 4B MUST require BOTH `exhaustion_risk_detected AND continuation_fragile` (not just exhaustion alone)
- Phase 4C MUST NOT use `council_quality`, `confidence_score`, `consensus_strength` (float) — enum/bool sources only
- THESIS_QUALITY_THIN must NOT trigger WAIT
- All IRREW dev actions produce WAIT only — never REJECT
- Master enable check: `if(!EnableIRREWDevelopmentConsumption) return;` at top of ApplyIRREWDevelopmentActions
- Compile: 0 errors / 0 warnings required before Package D

**Package D guardrails for Codex:**
- Execution geometry gate: label comparison only — `execution_geometry_label == "ADVERSE..."` not numeric score
- Geometry gate location: AFTER OperatingEnvelopeEvaluate passes, BEFORE AttemptTradeEntry
- Cohort admission: existing `LAB_InferFamilyFromStrategyId()` is the fallback — do not replace with new inference logic
- IMBALANCE_FILL_REVERSAL must NOT be added to OperatingCohortFamilyAllowed()
- No changes to core_trade_engine.mqh, stop geometry, lot sizing, TP/SL calculation
- Compile: 0 errors / 0 warnings required before Package E

---

## P. Final Recommendation

**Can Codex execute next?** YES — after applying the four mandatory revisions in Section C.

**Revisions that must be applied before first Codex task:**
1. **C-REV-01** (critical): Move execution_admission_family types to Package A; compute in Package B; use in Package C Phase 4A. Do NOT defer to Package D.
2. **C-REV-02** (critical): Define Phase 4A scope via `trend_judge_supportive` bool and `consensus_type` enum — not zone_type string comparison.
3. **C-REV-03** (important): Execution geometry gate in Package D must be in a NEW enforcement path in the pre-order block. Do NOT re-enable the DQ path at L10840-L10858.
4. **C-REV-04** (important): Define explicit WAIT reason priority order: 4B > 4A > 4C > RCEM > Geometry. Collect all firing reasons into `irrew_development_wait_reasons_all` pipe-separated field.

**Which package goes first?** Package A (types and flags). No source can be touched until types are defined and compile-clean.

**Adversarial review required:** YES — one review between Package B and Package C. Before Phase 4A/4B/4C source goes in:
- Verify that Package B OL records show correct field values in Strategy Tester replay
- Confirm `execution_admission_family` resolves correctly for known BTCUSD bar sequences
- Confirm `IRREW_EvaluatePlaybookValid()` correctly returns FORMING (not VALID) for fvg_tpb
- Confirm no unexpected IFR admission in any test bar

**Between Package C and D:** Verify with flags enabled that decision WAIT events appear in Strategy Tester output with correct reasons before adding pre-order execution gate.

**Final judgment target (if all compile successfully):**
`DEVELOPMENT_COMPLETE_TRADING_ARCHITECTURE_NOW_ACTIVE`

**System status after all packages complete:**
- All designed components have source-level categorical consumption paths
- All new behaviors are behind default-off development flags
- Production acceptance checklist remains required (57 items)
- PRODUCTION_READY = FALSE until PAC is passed

---

## Footer

```
REVIEW_ID:                FORCED_ENGINEERING_ACTIVATION_ARCHITECTURAL_EXECUTION_SPEC_REVIEW_V1
DATE:                     2026-05-09
REVIEW_TYPE:              Architecture / functional / trading-system implementation-quality review
VERDICT:                  PLAN_APPROVED_FOR_CODEX_AFTER_REVISIONS
MANDATORY_REVISIONS:      4 (C-REV-01 through C-REV-04)
ADVISORY_REVISION:        1 (C-REV-05 schema versioning)
SOURCE_CHANGED:           NO
COMPILE_RUN:              NO
RELOAD_RUN:               NO
PRODUCTION_READY_CLAIMED: NO
SYSTEM_STATUS:            DEVELOPMENT_COMPLETE / PRODUCTION_ACCEPTANCE_PENDING
IRREW_DEV_STATUS:         APPROVED_FOR_CODEX_AFTER_REVISIONS
PACKAGES:                 A (types/flags) → B (compute/ledger) → C (dev actions) → D (geometry/admission) → E (report/PIML)
ADVERSARIAL_REVIEW:       Required between Package B and C; between C and D
CRITICAL_NEW_FINDING:     execution_admission_family sequencing error in original plan (C-REV-01)
CRITICAL_NEW_FINDING_2:   Execution geometry diagnostic already exists in DQ path (hardlocked) — Package D must use SEPARATE new path (C-REV-03)
FINAL_JUDGMENT_TARGET:    DEVELOPMENT_COMPLETE_TRADING_ARCHITECTURE_NOW_ACTIVE (if all A-D compile 0 errors / 0 warnings)
```

---

## Q. Reference Document Findings Addendum

*Added post-review after reading PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1, BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1, BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1, IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1, council_v1_state_composer.mqh, execution_estimator_v1.mqh, and level_awareness_brake.mqh.*

### Q1. Packet Registry State — Critical Phase 4A Impact

**Finding:** Only 1 formal packet is accepted system-wide: MSR's FAILURE_MODE_PACKET for LHR (E[R] degradation −0.068R). Zero CONFIRMATION_PACKET entries are formally accepted anywhere. The original Phase 4A contract (Section I) referenced "accepted CONFIRMATION_PACKET" which would produce TC starvation at 100% rate because the packet registry has no such entries.

**Resolution:** C-REV-06 (added to Section C) corrects Phase 4A to use role-based cross-family detection (`IRREW_HasCrossFamilyRoleConfirmation`), not packet-based detection. Packet registry feeds audit fields only.

**Implication for Phase 4A behavior with dev flag on:** Phase 4A WAIT fires when no CONFIRM or TREND_JUDGE role strategy from a different family votes on the dominant direction. Under current TPC sparsity (1.4% co-presence with trend_momentum), this WILL produce frequent WAITs in TC zone. This is the intended development observation behavior — revealing how often cross-family confirmation is structurally absent.

### Q2. TPC Sparsity Confirmed as Structural, Not Threshold Issue

**Finding:** PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1 §9 confirms TPC (trend_pullback_cont_v1) is EDGE_SUPPORTED (WR=44.99%) but marked CONFIRM_PACKET_SPARSE (1.4% co-presence with trend_momentum) — an architectural sparsity problem, not a Nautilus certification problem. Phase 4A sparsity risk is fully confirmed.

**Implication for Codex:** Phase 4A flag should be kept false by default until operator has observed Phase 4A WAIT frequency in Strategy Tester replay with flag on. If Phase 4A fires on >80% of TC-zone bars, the scoping (trend_judge_supportive guard) may need to be narrowed further — see Section N (testing checklist).

### Q3. IFR Playbook State — Correctly Assessed as FORMING

**Finding:** IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1 confirms IFR_FORMING is correct current state: FVG_TPB is ALPHA_TRIGGER (FORMALLY_ACCEPTABLE, WR=43.41%, N=2,442), but NO CONFIRMATION_PACKET exists. mean_reversion_bounce is the strongest IFR CONFIRMATION candidate but co-presence test cannot run without live MT5 fvg_tpb entries.

**Implication:** PLAYBOOK_VALID for IFR cannot be emitted in Package B. All fvg_tpb bars will produce playbook_state=PLAYBOOK_STATE_FORMING. IRREW_EvaluatePlaybookValid() must return FORMING for IFR — this is architecturally correct per Section H.

### Q4. SELL_TREND_DOWN is FVG_TPB's Worst Edge — Confirm Hostile Gate

**Finding:** FVG_TPB SELL_TREND_DOWN: WR=38.37%, E[R]=−0.041R (FAILURE_MODE_CANDIDATE_STRONG, degradation −5.04pp). The hostile gate (blocking SELL in TREND_DOWN for fvg_tpb) should be confirmed active in source before Package A begins.

**Action:** Verify `fvg_hostile_gate_fired` field is populated correctly for SELL_TREND_DOWN in existing council_strategies.mqh BuildCouncilStrategy_FVG_TPB() function before Package A adds new types.

### Q5. V1 State Composer — RCEM Orthogonality Confirmed

**Finding:** council_v1_state_composer.mqh maps families to roles (native/conditional/deprioritized/informational) across 16 state labels. RCEM (Section I) operates at STRATEGY level (per-strategy regime_label gate) while V1 operates at FAMILY level (family role per state). These are orthogonal axes — no conflict.

**Implication:** RCEM in Package C can safely reduce eligibility for specific strategies without conflicting with V1's family role assignment. RCEM blocks at the strategy level; V1 reduces at the family level. A strategy can be V1-eligible-as-native but RCEM-blocked if a certified regime restriction exists.

### Q6. Execution Geometry Gate — Confirmed Separate from LAB Brake

**Finding:** level_awareness_brake.mqh implements a HARD_REJECT brake based on structural zone proximity (Rules A-F). This is distinct from execution_estimator_v1.mqh's geometry estimation. Both exist; both are separate. Package D's execution geometry gate (ADVERSE/POOR → WAIT) uses only execution_estimator results, not LAB brake verdicts.

**Implication:** The three geometry layers are: (1) LAB HARD_REJECT (structural zone proximity — already live), (2) DQ execution geometry block (inside NO-SCORE HARD-LOCKED path — diagnostic only), (3) Package D IRREW dev geometry gate (new categorical check — NOT re-enabling DQ). These three are independent and non-overlapping in their enforcement paths.

### Q7. EXECUTION_ADMISSION_IDENTITY_DECOUPLING was Already Planned as Deferred

**Finding:** BEST_STRATEGY_ID_SEMANTIC_GOVERNANCE_UPDATE_V1 §9A ("EXECUTION_ADMISSION_IDENTITY_DECOUPLING_V1") documents this exact decoupling as planned work with prerequisites: "Opportunity Ledger ≥200 records, Phase 4 design window, operator authorization." The forced activation plan overrides the deferral under Engineering Completion Mode.

**Implication:** C-REV-01 (move execution_admission_family to Package A/B) is architecturally correct and overrides the prior deferral decision. The forced activation authorizes proceeding now under the development flag — which satisfies the "operator authorization" prerequisite from the governance doc.

### Q8. best_strategy_id Semantic Gap — WAIT Strategies Eligible

**Finding:** BEST_STRATEGY_ID_FUNCTIONAL_AUDIT_AFTER_IRREW_V1 confirms that best_strategy_id selection does NOT filter by BUY/SELL decision — WAIT-deciding strategies can be selected as best_strategy_id. This creates a semantic gap where primary_thesis_strategy_id (= best_strategy_id) may name a strategy that voted WAIT.

**Implication for Package B:** `IRREW_ResolveAdmissionIdentity()` should NOT blindly alias `primary_thesis_strategy_id = best_strategy_id`. It should filter to strategies with BUY/SELL decision on dominant side. If best_strategy_id voted WAIT (non-triggering), admission identity falls back to the highest-weight BUY/SELL dominant-side strategy. If none found, execution_admission_family = "NOT_RESOLVED" and trade becomes WAIT.

**C-REV-06 supplement:** Add filter in `IRREW_ResolveAdmissionIdentity()`:
- Only consider strategies with `report.decision == COUNCIL_DECISION_BUY or COUNCIL_DECISION_SELL`
- Only on the dominant side
- Not BLOCKED, not frozen (vote_weight > 0.0)
- Not IMBALANCE_FILL_REVERSAL
- Highest post-V1 weight among remaining candidates

```
ADDENDUM_ID:          Q_REFERENCE_DOCUMENT_FINDINGS_ADDENDUM
DATE:                 2026-05-09
ADDED_FROM:           PLAYBOOK_STRATEGY_PACKET_REGISTRY_V1, BEST_STRATEGY_ID audit docs,
                      IMBALANCE_FILL_REVERSAL_PLAYBOOK_DESIGN_PACKAGE_V1,
                      council_v1_state_composer.mqh, execution_estimator_v1.mqh,
                      level_awareness_brake.mqh
CRITICAL_CORRECTIONS: C-REV-06 (Phase 4A role-based vs packet-based — starvation prevention)
ADDITIONAL_CORRECTIONS: Q8 (best_strategy_id WAIT filter in admission identity resolver)
NEW_REVISIONS_COUNT:  6 (C-REV-01 through C-REV-06) + Q8 supplement
VERDICT_UNCHANGED:    PLAN_APPROVED_FOR_CODEX_AFTER_REVISIONS
```
