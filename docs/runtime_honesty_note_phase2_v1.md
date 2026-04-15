# Runtime Honesty Note (Phase 2)

## Scope
Phase 2 is a runtime honesty repair pass only. No authority, operating model, or core decision-order changes were introduced.

## Live Ownership Truth
- Live council enforcement owner: `RunCouncilPreAIFilter(...)` plus final `env.tradable / pre.passed` branch.
- Governor role in current active path: post-filter policy/reporting context, not live pre-filter enforcement.
- Rollback posture: declared but inactive unless rollback monitoring is separately armed.
- ATAS rollout semantics:
  - mode 0: display/observation only
  - mode 1: soft influence flagging, non-blocking
  - mode 2: hold/reevaluate path can stop candidate progression when hold is applied

## Operator Surface Truth
- Dormant and disconnected operator-facing surfaces exist and are now explicitly classified in machine-readable artifacts.
- Rollback threshold inputs are visible but not consumed by the current live arming path.

## Artifacts Added
- `MQL5/Files/AI/runtime_honesty_truth.json`
- `MQL5/Files/AI/operator_input_truth_map.json`
- `MQL5/Files/AI/threshold_ownership_registry.json`
- `MQL5/Files/AI/runtime_honesty_note.txt`
