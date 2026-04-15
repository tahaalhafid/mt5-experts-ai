# Evidence Completeness + Decision Envelope Observability Hardening (Package 3/4) - Implementation Report v1

## 1) Executive Summary
This package implements bounded forensic-observability upgrades only.
No trade-entry/exit logic, execution routing, risk formulas, governor authority, AI authority posture, Databento/Fusion activation, or semantic-adapter posture was broadened.

Implemented scope:
- Package 3: per-trade evidence completeness repair.
- Package 4: decision envelope observability hardening.

Implementation state: **Complete for bounded code instrumentation scope** with compile confirmation limited to static symbol consistency in this environment.

## 2) Backup Evidence
Pre-change backup:
- `backup_archives/pre_change_20260409_020652_evidence_observability_repair.zip`
- Included: `MQL5/Experts/AI`, `MQL5/Files/AI`
- Excluded: `MQL5/Files/AI/ai_performance_journal.jsonl` (live-locked governance rule), existing zip artifacts, nested backup artifacts.

## 3) Files Reviewed
- `AGENTS.md`
- `main_ea.mq5`
- `unified_confidence.mqh`
- `correlation_engine.mqh`
- `trade_feedback.mqh`
- `performance_journal.mqh`
- `journal_analytics.mqh`
- `council_mode_types.mqh`

## 4) Files Modified
- `unified_confidence.mqh`
- `main_ea.mq5`
- `correlation_engine.mqh`
- `trade_feedback.mqh`
- `performance_journal.mqh`

## 5) Files Created
- `docs/evidence_completeness_contract_v1.md`
- `docs/decision_envelope_observability_contract_v1.md`
- `docs/evidence_observability_repair_implementation_report_v1.md`
- `compile_evidence_observability_repair.log`

## 6) Files Intentionally Not Modified
- Trading/execution/risk/governor authority modules outside bounded observability integration points.
- External adapter/Fusion/Databento activation paths.
- Semantic adapter contract surfaces.
- AI authority/readiness gate logic.

Rationale: preserve governance and runtime authority boundaries.

## 7) Package 3 Repaired/Improved
- Added richer trade-open evidence capture (requested/fill/SL/TP/slippage).
- Added per-field provenance markers (direct/derived/unavailable).
- Added trade-close evidence carry-forward via `TradeFeedbackRecord`.
- Added bounded trade evidence completeness status surface:
  - `AI/ai_trade_evidence_completeness_status.json`
- Preserved explicit unavailable markers for not-captured/not-derivable fields.

## 8) Package 4 Repaired/Improved
- Added per-decision envelope trace surface:
  - `AI/ai_decision_envelope_trace.jsonl`
- Added compact envelope status surface:
  - `AI/ai_decision_envelope_observability_status.json`
- Added decision posture + reasoning flags (descriptive, non-authoritative).
- Added journaling of confidence shaping components:
  base/final confidence, policy risk, regime fit, learning/advisory/SR context.

## 9) New Fields Now Captured Directly
- `requested_entry_price`
- `actual_entry_fill_price` (from result/deal where available)
- `initial_stop_loss`
- `initial_take_profit`
- `exit_fill_price` (from close deal where available)
- `base_confidence_score`
- `final_confidence_score`
- `policy_risk_score`
- `regime_fit_score`
- `learning_confidence_delta`
- `learning_caution_score`
- `learning_state_code`
- `learning_evidence_count`
- `learning_evidence_threshold_met`
- `learning_zero_influence_due_to_insufficient_evidence`
- advisory contradiction/hold-bias/relevance context
- SR confluence/rejection/obstruction/canonical-near/conflicted flags and buckets
- decision acceptance posture and reasoning flags

## 10) New Fields Now Derived Deterministically
- `entry_slippage_points` from requested vs actual fill when both exist.
- `confidence_delta_from_base` from final minus base confidence.
- availability classification fields based on observed bounded context:
  advisory and support/resistance observation source markers.

## 11) Fields Still Unavailable and Why
Unavailable in current bounded runtime surfaces (explicitly marked, not fabricated):
- nearest numeric support value
- nearest numeric resistance value
- exact numeric distance-to-level values
- detailed stop/target modification timeline
- robust MFE/MAE lifecycle series

Reason: no authoritative bounded writer currently emits these as stable runtime evidence.

## 12) Decision-Envelope Observability Improvements
- Added dedicated non-authoritative trace records per decision.
- Added explicit posture classification:
  `STANDARD/CAUTIOUS/DEGRADED/EXCEPTIONAL/BLOCKED/NON_ENTRY`.
- Added reasoning tags to explain envelope shaping before execution attempt.
- Preserved separation between authority and observability surfaces.

## 13) Support/Resistance Observability Improvements
- SR context now carried in decision envelope and trade evidence surfaces:
  state, bucket, canonical state, and key flags.
- Prevented silent SR loss by explicit fields and availability markers.

## 14) Learning/Advisory Contribution Visibility Improvements
- Learning gate state/evidence threshold visibility added in both decision and trade evidence.
- Advisory contribution signals (relevance/contradiction/hold-bias) emitted as bounded context.
- No advisory/learning control escalation introduced.

## 15) Compile Results
MetaEditor process launch returned exit code `0`, but this environment did not emit/update compiler diagnostic output or ex5 timestamp.
Compile state therefore recorded as:
- `SOURCE_PATCH_APPLIED_WITH_STATIC_SYMBOL_CONSISTENCY_ONLY`

See:
- `compile_evidence_observability_repair.log`

## 16) Residual Risks
- Definitive compiler diagnostics remain unconfirmed until interactive terminal compile emits verifiable output.
- Some desired forensic numeric level-distance fields remain unavailable due missing upstream bounded writer support.
- Trade management modification history remains not captured in current bounded surfaces.

## 17) Recommended Next Bounded Validation Step
Run a controlled runtime replay/live bounded session and verify newly emitted surfaces for at least a small set of closed trades:
- `AI/ai_decision_envelope_trace.jsonl`
- `AI/ai_decision_envelope_observability_status.json`
- `AI/ai_trade_evidence_completeness_status.json`
- `AI/ai_performance_journal.jsonl` (cold read only if journal lock policy allows)

Goal: confirm field completeness/availability markers and cross-surface coherence without any authority-path changes.

