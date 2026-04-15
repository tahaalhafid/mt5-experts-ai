# SR Overlay Capture Broadening Report v1

## Scope
- Bounded display-only SR overlay source broadening.
- No trading/execution/risk/governor/authority logic changes.

## Root Cause
- Overlay selection depended on `UnifiedDecisionConfidence` SR fields and current governed advisory status snapshot.
- During REJECT/NON_ENTRY cycles, BUY/SELL advisory integration path is often not invoked, so SR fields remain defaulted (`UNAVAILABLE_NOT_CAPTURED`) even when runtime contextual SR can still be computed.

## Final (Green) Source Precedence
1. Decision-envelope contextual SR (`UnifiedDecisionConfidence.nearest_*`) when present.
2. Council/environment runtime contextual fallback via `BuildLevelAwarenessBrakeReport(...)` during the current cycle, including REJECT/NON_ENTRY.
3. If neither provides usable numeric levels, mark unavailable with precise reason.

## ATAS (Red) Source Precedence
1. Governed advisory status SR levels (`gAtasGovernedAdvisoryStatus.nearest_*`) when present.
2. Runtime context packet fallback (`AI\\atas_runtime_context.json` level candidates), display-only.
3. If neither provides usable numeric levels, mark unavailable with precise reason.

## Unavailable/Blocked Reason Improvements
- Distinct reason families now emitted and shown:
  - `*_NO_CONTEXTUAL_SOURCE_AVAILABLE:*`
  - `*_SOURCE_AVAILABLE_BLOCKED_OR_INELIGIBLE:*`
  - `*_SOURCE_PRESENT_MISSING_NUMERIC_LEVEL_VALUES:*`
  - `*_SOURCE_PRESENT_DELIBERATELY_SUPPRESSED:*`
  - `*_SOURCE_ABSENT_ENTIRELY:*`

## REJECT/NON_ENTRY Behavior
- Overlay can now still render contextual levels in REJECT/NON_ENTRY cycles when contextual runtime sources are available.
- This is display-only and does not alter decision or execution paths.

## Compile Verification
- Built `main_ea.mq5` after patch with compile log:
  - `MQL5/Experts/AI/compile_logs/compile_sr_overlay_broadening_20260409_074941.log`
  - Result: `0 errors, 2 warnings`
