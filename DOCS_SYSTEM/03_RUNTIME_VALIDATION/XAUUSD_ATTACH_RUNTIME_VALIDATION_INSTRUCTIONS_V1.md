# XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1

**Status:** XAUUSD_ATTACH_REQUIRED_AFTER_OPERATOR_RELOAD
**Date:** 2026-05-10
**Context:** POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1
**Issued by:** Claude — documentation artifact, operator-review required before action

---

## A. Why This File Exists

After the 2026-05-10 EA reload (Package D binary), the terminal was operating on BTCUSD (M5). XAUUSD was not attached. Strategy `fvg_tpb` (family: IMBALANCE_FILL_REVERSAL) requires a XAUUSD chart attachment to evaluate. Without it, `fvg_tpb` records `evaluations_seen > 0` but `trigger_seen = 0` permanently — a silent non-fire, not a filter.

This file defines the exact validation checklist the operator must run after attaching the EA to a XAUUSD chart and reloading.

---

## B. Pre-Attachment Requirements

Before attaching the EA to XAUUSD, confirm ALL of the following:

| # | Requirement | Check |
|---|---|---|
| B-1 | Binary: `main_ea.ex5` LastWriteTime = 2026-05-10 00:39:43 (Package D) | Confirm in terminal Experts tab |
| B-2 | All 7 IRREW dev flags = false (default off) | Confirm in EA inputs before attach |
| B-3 | Chart: XAUUSD, M5 or M1 (same TF as BTCUSD session) | Confirm chart symbol |
| B-4 | EA inputs match the authorized input set (no score gates re-enabled, no geometry changes) | Verify against last authorized input snapshot |
| B-5 | Decision engine mode = COUNCIL (not LEGACY or HYBRID) | Will be confirmed in startup log |
| B-6 | No open positions on XAUUSD before attach (clean state preferred for first session) | Check terminal Positions tab |

---

## C. IRREW Dev Flags — Must Remain False

These 7 flags must remain `false` in the EA inputs at attachment. Do not enable any of them.

```
EnableIRREWDevelopmentConsumption   = false   // MANDATORY
EnableIRREWPhase4ADev               = false   // MANDATORY
EnableIRREWPhase4BDev               = false   // MANDATORY
EnableIRREWPhase4CDev               = false   // MANDATORY
EnableIRREWRCEMDev                  = false   // MANDATORY
EnableIRREWExecutionGeometryDev     = false   // MANDATORY
EnableIRREWPlaybookAdvisoryDev      = false   // MANDATORY
```

Enabling any of these flags is an unauthorized architectural change. All flags default to false and require a separate operator-authorized bounded change task before activation.

---

## D. Post-Attach Startup Validation Checklist

After attaching and reloading, check the Experts log (MQL5/Logs/YYYYMMDD.log) for the following startup markers:

| # | Expected Log Marker | Pass Condition |
|---|---|---|
| D-1 | `authoritative_mode=COUNCIL` | Exactly "COUNCIL" — not LEGACY, not HYBRID |
| D-2 | `decision_engine_mode=COUNCIL` | Confirms COUNCIL pipeline active |
| D-3 | `COHORT_GOVERNED_ACTIVE` | Operating cohort governance active |
| D-4 | `AI_OFF` | AI authority boundary confirmed off |
| D-5 | `SAFE_ACTIVE` | Risk/safety layer active |
| D-6 | `active_strategies_count=18` | All 18 strategies loaded (17 cohort + fvg_tpb playbook observer) |
| D-7 | `symbol=XAUUSD` | Correct chart symbol |
| D-8 | No `ERROR` or `INIT_FAILED` lines | Clean initialization |
| D-9 | `irrew_phase4c_enabled=false` (in IRREW audit block) | Phase4C dev path inactive |
| D-10 | `thesis_quality_state` field present in OL records | U-02 fix confirmed serializing |

---

## E. fvg_tpb Validation Checklist

`fvg_tpb` (IMBALANCE_FILL_REVERSAL family, SCOUT role) is a playbook-lane observer. It is **not in the operating cohort** and does not vote in council decisions. It observes and serializes fvg/ifr context fields to the OL record.

After 20+ bars on XAUUSD, check `ai_opportunity_summary.json` for the following:

| # | Field | Expected Value |
|---|---|---|
| E-1 | `fvg_tpb.evaluations_seen` | > 0 (increasing each bar) |
| E-2 | `fvg_tpb.trigger_seen` | 0–N (may be 0 if no valid FVG detected yet — this is OK) |
| E-3 | `fvg_tpb` appears exactly once | No duplicate entries |
| E-4 | `fvg_tpb.family` | `"IMBALANCE_FILL_REVERSAL"` |
| E-5 | `fvg_tpb.role` | `"SCOUT"` |
| E-6 | `fvg_tpb` NOT listed in any council vote aggregation | Playbook observer only — must not influence consensus |

---

## F. OL Schema Validation

After the first OL record is written on XAUUSD, open `ai_opportunity_ledger.jsonl` and verify the **most recent record** contains:

| # | Field | Expected Value |
|---|---|---|
| F-1 | `record_version` | `"OL_V1C_IRREW_DEV_V1"` (not "OL_V1C_PLAYBOOK_SHADOW") |
| F-2 | `irrew_schema_version` | `"OL_V1C_IRREW_DEV_V1"` |
| F-3 | `irrew_phase4a_active` | `false` |
| F-4 | `irrew_phase4b_active` | `false` |
| F-5 | `irrew_phase4c_active` | `false` |
| F-6 | `irrew_rcem_active` | `false` |
| F-7 | `irrew_execution_geometry_active` | `false` |
| F-8 | `irrew_playbook_advisory_active` | `false` |
| F-9 | `baseline_decision_before_irrew_dev` == `final_decision_after_irrew_dev` | Zero IRREW behavioral delta |
| F-10 | `thesis_quality_state` present | One of: THESIS_QUALITY_SOLID / THIN / INCOMPLETE / CONTRADICTED / UNCERTAIN |

---

## G. OL Summary Schema Validation

After the first summary flush, open `ai_opportunity_summary.json` and verify:

| # | Field | Expected Value |
|---|---|---|
| G-1 | `schema_version` | `"OL_SUMMARY_V1C_IRREW_DEV_V1"` (not "OL_SUMMARY_V1C_PLAYBOOK_SHADOW") |
| G-2 | `playbook_architecture_schema` | `"OL_V1C_IRREW_DEV_V1"` |
| G-3 | `symbol` | `"XAUUSD"` |
| G-4 | `runtime_authority_status` | `"NONE"` |
| G-5 | Total strategy entries | 18 (including fvg_tpb) |

---

## H. Boundary Checks — Must NOT Appear

Verify these conditions do NOT appear in logs or OL records after first XAUUSD session:

| # | Forbidden Condition | Why |
|---|---|---|
| H-1 | `PLAYBOOK_VALID` used as trade permission gate | Not authorized — playbook is advisory context only |
| H-2 | `playbook_score` in any council vote or OL field influencing central_decision | Score authority not granted to playbook layer |
| H-3 | Any IRREW flag = true in OL records | All 7 flags must remain false |
| H-4 | `fvg_tpb` appearing in council vote aggregation | It is a playbook observer, not a cohort voter |
| H-5 | `IMBALANCE_FILL_REVERSAL` strategy receiving a lot/entry assignment | Outside operating cohort — no execution authority |
| H-6 | `council_quality` bonus applied from Phase4C logic | Phase4C not active (flag false) |
| H-7 | Any weight changes applied automatically | EEWP not authorized; all weights static |

---

## I. Validation Result States

After completing the above checklist, assign one of the following states:

| State | Meaning |
|---|---|
| `XAUUSD_VALIDATION_PASS` | All D/E/F/G/H checks pass; fvg_tpb evaluating and serializing correctly |
| `XAUUSD_VALIDATION_PASS_WITH_CAVEATS` | All structural checks pass; one or more minor observations noted (not blocking) |
| `XAUUSD_VALIDATION_FAIL_SCHEMA` | F or G checks fail — OL schema not updated, resync required |
| `XAUUSD_VALIDATION_FAIL_IRREW_FLAG` | Any IRREW flag = true detected — stop trading, investigate |
| `XAUUSD_VALIDATION_FAIL_BOUNDARY` | Any H-series condition detected — stop trading, escalate to operator |
| `XAUUSD_VALIDATION_INCONCLUSIVE` | Fewer than 5 OL records written; check again after 30+ bars |

---

## J. Relation to BTCUSD Session

The BTCUSD session (2026-05-10 03:02–04:40) produced 5 OL records (lines 40–44 of `ai_opportunity_ledger.jsonl`). These records used `record_version="OL_V1C_PLAYBOOK_SHADOW"` — the pre-correction schema label. They are **historical records and must not be modified**. XAUUSD records written after this correction will use `record_version="OL_V1C_IRREW_DEV_V1"` — the reconciled label.

Both values identify the same OL V1C architecture. The schema correction is a label reconciliation only; no field structure, no decision logic, and no serialization paths were changed.

---

## K. PIML Reference

Phase progress and validation outcomes should be recorded in `PROJECT_INTELLIGENCE_MEMORY_LAYER.md`, Section §32 (POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1) under the XAUUSD validation sub-section.

---

```
DOC_ID:                     XAUUSD_ATTACH_RUNTIME_VALIDATION_INSTRUCTIONS_V1
ISSUED_AT:                  2026-05-10
CONTEXT:                    POST_FORCED_ACTIVATION_CORRECTION_AND_DOC_NETWORK_V1
ATTACHMENT_STATUS:          XAUUSD_ATTACH_REQUIRED_AFTER_OPERATOR_RELOAD
IRREW_FLAGS_STATE:          ALL_FALSE — do not change
OPERATOR_ACTION_REQUIRED:   YES — attach EA to XAUUSD chart, complete checklist, record result
SOURCE_CHANGED:             NO
COMPILE_RUN:                NO
PRODUCTION_READY_CLAIMED:   NO
```
