# SR Overlay Visualization Refinement Report v1

## Executive summary
Implemented a bounded display-only refinement package for support/resistance visualization:
- multi-level ranked final vs ATAS comparative overlay
- overlap/confluence readability handling
- bounded display modes
- compact left-edge sidebar default dashboard behavior

No trading, execution, risk, governor, authority, AI posture, Databento/Fusion, semantic-adapter, or advisory authority behavior was modified.

## Backup evidence
- Pre-change backup:
  - `backup_archives/pre_change_20260409_090337_sr_overlay_visual_refinement.zip`
  - Included governed roots: `MQL5/Experts/AI`, `MQL5/Files/AI`
  - Excluded locked file: `MQL5/Files/AI/ai_performance_journal.jsonl`
- Post-change backup:
  - `backup_archives/post_change_20260409_092948_sr_overlay_visual_refinement_scope.zip`
  - Included governed roots: `MQL5/Experts/AI`, `MQL5/Files/AI`
  - Excluded locked file: `MQL5/Files/AI/ai_performance_journal.jsonl`

## Files reviewed
- `main_ea.mq5`
- `dashboard_navigation_controller.mqh`
- `dashboard_renderer.mqh`

## Files modified
- `main_ea.mq5`
  - Added bounded multi-level SR overlay selection/ranking/overlap visualization behavior.
  - Added display-mode and bounded-level controls.
  - Added explicit status/reason/source/count diagnostics for FINAL and ATAS layers.
- `dashboard_navigation_controller.mqh`
  - Kept/used compact collapsed default posture and close-panel behavior.
  - Ensured page-button behavior expands to one open panel from minimized sidebar mode.
- `dashboard_renderer.mqh`
  - Refined minimized rendering to left-edge compact sidebar behavior.
  - Reduced navigation width and panel footprint for less chart obstruction.
  - Kept single current-page panel rendering model.

## Files created
- `docs/sr_overlay_visualization_refinement_contract_v1.md`
- `docs/sr_overlay_visualization_refinement_report_v1.md`

## Files intentionally not modified
- Execution/trade/risk/governor/authority modules (intentionally unchanged).
- ATAS semantic adapter and external authority-chain modules (intentionally unchanged).
- AI authority/readiness gates (intentionally unchanged).

## Multi-level ranked overlay implementation
- Final (green) and ATAS (red) layers now each support bounded ranked multi-level rendering.
- Bounded target: up to 2 supports + 2 resistances per layer.
- When fewer levels exist from bounded sources, overlay displays best available subset and emits explicit unavailable reasons.

## Ranking/selection logic
- Score = source-tier precedence penalty + distance in points from current mid-price.
- Final source-tier preference:
  1. decision-envelope context
  2. council/environment level-brake context
  3. MT5 canonical auxiliary context (structure mode)
- ATAS source-tier preference:
  1. governed advisory status context
  2. runtime context packet `level_candidates`

## Overlap/confluence handling
- Added near-overlap detection via configurable threshold points.
- ATAS line gets a small visual-only offset on overlap.
- Confluence labels are added (`FINAL~ATAS_*`) so overlapping levels remain readable.
- No logical price reinterpretation is performed; offsets are display-only.

## Display modes
- `DECISION_VIEW`: nearest/most relevant, minimal set.
- `STRUCTURE_VIEW`: bounded multi-level structural view.
- `CLEAN_VIEW`: minimal final-only emphasis (ATAS hidden).

## Vertical left-edge sidebar implementation
- Minimized footprint now renders as compact far-left sidebar navigation.
- Startup posture remains compact/collapsed (sidebar visible, no large panel open).
- Opening a page from sidebar expands to adjacent panel view.

## One-panel-only behavior
- Renderer still draws one active page panel only (single current page model).
- `AIDASH_BTN_CLOSE_PANEL` returns to sidebar-only minimized posture.
- Opening a new page replaces the current page content; no multi-panel accumulation.

## Dashboard obstruction reduction
- Minimized state switched from wide floating block to slim left-edge sidebar.
- Expanded panel footprint and nav width reduced to lower chart obstruction.

## Labeling improvements
- Concise level labels retained:
  - `FINAL_S*`, `FINAL_R*`
  - `ATAS_S*`, `ATAS_R*`
- Interaction hint retained on final labels.
- Confluence markers explicitly shown on overlap.
- Full reason/source diagnostics preserved in status label and Experts log status line.

## Professional palette and line styles
- Final runtime layer (green family):
  - primary `C'46,150,92'`, secondary `C'78,178,120'`
  - solid, thicker lines
- ATAS comparison layer (red family):
  - primary `C'188,88,88'`, secondary `C'214,132,132'`
  - dotted, lighter-weight lines
- Confluence hint:
  - neutral accent `C'196,196,196'`

## Surface ownership (final vs ATAS)
- FINAL runtime lines are driven by MT5-internal contextual/evaluated surfaces in `main_ea.mq5` selection path.
- ATAS reference lines are driven by governed advisory status and bounded runtime context packet fallback.
- Raw ATAS levels are never labeled as final runtime authority.

## Compile results
- MetaEditor path:
  - `C:\Program Files\MetaTrader 5\metaeditor64.exe`
- Compile invocation used:
  - `/s /compile:"...\\MQL5\\Experts\\AI\\main_ea.mq5" /log:"...\\MQL5\\Experts\\AI\\compile_logs\\compile_sr_overlay_refinement_20260409_093100.log"`
- Compiler log result:
  - `result 0 errors, 2 warnings`
- Artifact observation:
  - Existing `main_ea.ex5` timestamp/size in this workspace did not change during this CLI run; compile success evidence is taken from compiler log output.
- Warning lines:
  - `main_ea.mq5(13332,50): warning 94 implicit conversion from 'int' to 'string'`
  - `main_ea.mq5(13821,59): warning 94 implicit conversion from 'int' to 'string'`

## Residual risks
- Runtime availability of multi-level fields varies by bounded source freshness/availability.
- Auxiliary canonical levels are bounded heuristics; they support structure visualization but do not imply execution authority.
- MetaEditor process exit code may be environment-specific; compiler log is used as primary proof.

## Recommended quick runtime validation steps
1. In chart, set `SupportResistanceOverlayDisplayMode=1` (STRUCTURE_VIEW), verify up to 2 levels per side and clear green/red separation.
2. Verify overlap case shows confluence marker and red visual offset, not hidden lines.
3. Toggle to `DECISION_VIEW` and `CLEAN_VIEW` to confirm bounded mode behavior.
4. Confirm minimized dashboard starts as slim left-edge sidebar and page-click opens a single adjacent panel.
