# ATAS Live-Validity Investigation + Red-Line Truth-Tightening (v1)

## Executive Summary
The unexpected red ATAS comparison line was caused by overlay fallback logic accepting `AI\\atas_runtime_context.json` `level_candidates` even when `AI\\atas_runtime_context_status.json` clearly indicated `SHADOW_NOT_ATTACHED` and `EXPIRED`.  
This was a visualization classification defect (stale/historical packet reuse as drawable current comparison).  
Patch applied: ATAS red layer is now drawable only when state class is `ATAS_LIVE_REFERENCE_AVAILABLE`; otherwise it stays diagnostics-only.

## Files Reviewed
- `MQL5/Experts/AI/main_ea.mq5`
- `MQL5/Files/AI/atas_runtime_context_status.json`
- `MQL5/Files/AI/atas_runtime_context.json`
- `MQL5/Files/AI/atas_governed_advisory_status.json`

## Files Modified
- `MQL5/Experts/AI/main_ea.mq5`
  - Added runtime-status probe for ATAS live-validity gating (`atas_runtime_context_status.json`).
  - Reworked `SRVIZ_SelectAtasReferenceLevels(...)` classification flow.
  - Tightened draw gate in `UpdateSupportResistanceChartOverlay(...)` so red layer draws only for live-valid class.

## Exact Technical Root Cause
Before patch, `SRVIZ_SelectAtasReferenceLevels(...)` always called `SRVIZ_AddAtasPacketCandidates(...)` and promoted any resulting levels to drawable `ATAS_REFERENCE`, even if advisory gates were blocked and ATAS runtime status was stale/not attached.  
As a result, historical packet `level_candidates` from `atas_runtime_context.json` could still render as red lines.

## Which Source Actually Drove Red Line Before Patch
- Primary observed driver: `AI\\atas_runtime_context.json` → `level_candidates` (via `SRVIZ_AddAtasPacketCandidates(...)`).
- This happened despite status surface indicating non-live state:
  - `acceptance_state=SHADOW_NOT_ATTACHED`
  - `freshness_state=EXPIRED`
  - `atas_shadow_attached=false`
  - `atas_fresh=false`

## Prior Behavior Classification
- `misleading visualization`
- `stale-data misuse`
- `classification defect`

## New Live-Valid Red Drawing Rule
Red ATAS lines/labels now draw only when:
- `atasLayer.layer_class == "ATAS_LIVE_REFERENCE_AVAILABLE"`

`ATAS_LIVE_REFERENCE_AVAILABLE` requires all bounded gates to pass:
- runtime context status file present/parseable
- `atas_available=true`
- `atas_shadow_attached=true`
- not `NOT_ATTACHED` acceptance
- freshness not stale/expired
- not `price_anchor_fields_suppressed`
- governed advisory status initialized
- governed gates not blocked
- payload present
- usable numeric levels present

## Suppression Conditions Now Enforced
Red drawing is suppressed (diagnostics-only) for:
- `ATAS_REFERENCE_STALE`
- `ATAS_REFERENCE_EXPIRED`
- `ATAS_REFERENCE_NOT_ATTACHED`
- `ATAS_REFERENCE_ABSENT`
- `ATAS_REFERENCE_HISTORICAL_ONLY`
- `ATAS_REFERENCE_DEFAULTED_OR_INVALID`
- `ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE`

## Diagnostics / Status Improvements
Overlay status now reports explicit state-class + reason combinations for ATAS, including source clarity:
- `ATAS_LIVE_REFERENCE_AVAILABLE`
- `ATAS_REFERENCE_STALE`
- `ATAS_REFERENCE_EXPIRED`
- `ATAS_REFERENCE_NOT_ATTACHED`
- `ATAS_REFERENCE_ABSENT`
- `ATAS_REFERENCE_HISTORICAL_ONLY`
- `ATAS_REFERENCE_DEFAULTED_OR_INVALID`
- `ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE`

Reason codes now include concrete gate/freshness/classification context instead of generic fallback-only messaging.

## Confirmation: Green FINAL Logic
No changes were made to final runtime (green) level-selection logic or authority semantics.

## Compile Results
- Compile command:
  - `\"C:\\Program Files\\MetaTrader 5\\MetaEditor64.exe\" /s /compile:\"...\\MQL5\\Experts\\AI\\main_ea.mq5\" /log:\"...\\MQL5\\Experts\\AI\\compile_logs\\compile_atas_live_validity_tightening_20260410_031713.log\"`
- Compiler log:
  - `MQL5/Experts/AI/compile_logs/compile_atas_live_validity_tightening_20260410_031713.log`
- Result from compiler log tail:
  - `0 errors, 2 warnings`

## Residual Risks
- If upstream status writers stop updating, ATAS layer will fail closed (diagnostics-only), which is intended but may hide comparison lines until status resumes.
- Historical packet files are still readable for diagnostics, but are no longer drawable unless live-valid gates pass.

## Recommended Quick Runtime Check
1. Keep ATAS stopped: confirm status shows `ATAS_REFERENCE_*` non-live class and no red lines draw.
2. Start ATAS and wait for fresh attached status: confirm `ATAS_LIVE_REFERENCE_AVAILABLE` and red lines appear.
3. Stop ATAS again and allow freshness to expire: confirm red lines are removed and diagnostics switch to stale/expired/not-attached class.
