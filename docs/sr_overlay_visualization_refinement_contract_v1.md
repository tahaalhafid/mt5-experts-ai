# SR Overlay Visualization Refinement Contract v1

## Scope Class
- `DERIVED_OR_VISIBILITY_ONLY`
- Display-only chart overlay and dashboard usability surfaces
- No execution/risk/governor/authority semantics

## Layer Semantics
- `GREEN` family (`FINAL_*` labels): MT5 final runtime contextual/evaluated support/resistance
- `RED` family (`ATAS_*` labels): ATAS comparison/reference support/resistance
- ATAS layer remains non-authoritative and comparison-only

## Final (Green) Data Precedence
1. Decision-envelope contextual levels from `UnifiedDecisionConfidence`:
   - `nearest_support_price`
   - `nearest_resistance_price`
2. Council/environment level-brake contextual levels:
   - `BuildLevelAwarenessBrakeReport(...)` output
3. MT5 canonical auxiliary contextual levels (structure view only):
   - session high/low
   - previous day high/low
   - bounded M15 swing high/low
4. If none available, layer is unavailable with explicit reason code

## ATAS (Red) Data Precedence
1. Governed advisory status contextual levels:
   - `gAtasGovernedAdvisoryStatus.nearest_support_price`
   - `gAtasGovernedAdvisoryStatus.nearest_resistance_price`
2. Runtime context packet fallback:
   - `AI\\atas_runtime_context.json` -> `level_candidates[]`
3. If none available, layer is unavailable with explicit reason code

## Ranked Bounded Display
- Up to `2` supports and `2` resistances per layer (bounded)
- Ranking score combines:
  - source-tier precedence
  - proximity to current mid-price
- Duplicate/near-duplicate levels are deduplicated

## Overlap/Confluence Handling
- Near-overlap detection uses configurable threshold points
- When overlap is detected:
  - ATAS line is shifted by a small visual-only offset
  - confluence label is shown (`FINAL~ATAS_*`)
- Logical level meaning remains unchanged (offset is visual-only)

## Display Modes
- `DECISION_VIEW`: closest/most relevant bounded subset (1 per side)
- `STRUCTURE_VIEW`: multi-level bounded structure view
- `CLEAN_VIEW`: minimal final layer emphasis, ATAS layer hidden

## Dashboard Usability Contract
- Default posture: left-edge compact sidebar
- Sidebar-only state when minimized footprint is active
- Page button opens one adjacent panel (single rendered panel model)
- Close panel returns to sidebar-only view

