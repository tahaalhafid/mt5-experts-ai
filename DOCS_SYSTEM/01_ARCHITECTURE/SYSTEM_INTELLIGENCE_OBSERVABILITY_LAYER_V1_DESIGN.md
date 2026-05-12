# SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1_DESIGN

**Date:** 2026-05-12
**Author:** Claude (architecture/design only — no source changes, no implementation)
**Mission type:** Read-only architecture design
**Scope:** Observer/anomaly/readiness layer — NOT a trading decision engine
**Authority:** MT5 remains runtime authority. This layer is observability-only.

---

## A. Executive Verdict

```
VERDICT: SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_DESIGN_READY
```

The architecture is well-defined, implementable using existing artifacts, and imposes zero MT5 runtime burden in its recommended form. Eight modules are specified. All are implementable offline (Phase 1) without any new runtime fields or MT5 source changes. A critical system anomaly was detected during design: **57 OL records with `filter_passed=true` in 32 cases but `actual_trade=true` in zero — the system is approving trades structurally but executing none.** The observability layer must make this and similar gaps immediately visible on every run.

---

## B. Architecture Recommendation

### B1. Core Principle

This layer is NOT a trading decision engine.

It must not:
- Generate BUY/SELL/WAIT
- Change risk, execution, stops, targets, or lots
- Activate strategies or change cohort admission
- Enable IRREW/PCEA/RCEM phases
- Use PLAYBOOK_VALID as permission
- Modify runtime files
- Become MT5 runtime authority

It is: observer, anomaly detector, contradiction detector, readiness monitor, packet lifecycle tracker, shadow effect tracker, report synthesizer, system intelligence assistant.

### B2. Recommended Architecture: Offline-First External Scanner

```
┌─────────────────────────────────────────────────────────┐
│         SYSTEM INTELLIGENCE OBSERVABILITY LAYER V1       │
│                    (External / Offline)                   │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  INPUT LAYER (read-only)                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ OL JSONL     │  │ Status JSONs │  │ Experts Logs  │  │
│  │ PJ JSONL     │  │ PJ buffer    │  │ PIML + DOCS   │  │
│  │ OL Summary   │  │ IO Reduction │  │ Source grep   │  │
│  └──────────────┘  └──────────────┘  └───────────────┘  │
│                           │                              │
│  SCANNER LAYER (Python, scheduled or on-demand)          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │ 8 Observability Modules (see Section C)             │ │
│  └─────────────────────────────────────────────────────┘ │
│                           │                              │
│  OUTPUT LAYER (advisory only)                            │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────┐  │
│  │ system_intel │  │ system_intel │  │ readiness_    │  │
│  │ _snapshot.   │  │ _report.md   │  │ gate_state.   │  │
│  │ json         │  │              │  │ json          │  │
│  └──────────────┘  └──────────────┘  └───────────────┘  │
│                                                          │
│  [Optional Phase 3] Dashboard read-only visualization    │
│  [Optional Phase 5] Minimal MT5 runtime hooks if proven  │
└─────────────────────────────────────────────────────────┘
```

**Why offline-first:**

| Reason | Detail |
|---|---|
| IO reduction active | PJ buffer and governance gating already reduce file writes; new MT5 observability writes would defeat this |
| Source-binary divergence | OL writer (`WriteOpportunityLedgerRecord`) not in current source; adding more runtime calls before resolving divergence is risky |
| OnTick is wrong location | Intelligence analysis is too slow for OnTick frequency (17 strategies × N fields per tick) |
| Zero new MT5 fields needed for Phase 1 | 80%+ of questions answerable from existing OL, PJ, status, and log files |
| Python is more powerful | Analysis, statistics, contradiction detection, and report generation are faster and safer in Python than MQL5 string manipulation |
| No compile risk | Offline scanner requires no compile, no reload, no authority boundary changes |

**Location:** `nautilus_lab/system_intelligence/` — independent of MT5 runtime, alongside existing INEC scripts.

**Output cadence:** On-demand (manual run) or scheduled (e.g., every 6 hours via OS task scheduler). Not tied to MT5 OnTick.

### B3. Critical System Anomaly Detected During Design

Before architecture detail, this anomaly must be noted as the highest-priority observability target:

```
ANOMALY: actual_trade=true = 0 across all 57 OL records
         filter_passed=true = 32 records (trade approved structurally)
         DELTA: 32 structurally approved decisions with zero trades executed
```

This means one or more of the following is blocking execution:
- `EnableRuntimeExecution = false`
- `OneTradeAttemptPerBar` blocking (already attempted this bar)
- Position management blocking (open position exists)
- Governance/risk gate blocking post-filter
- EA reloaded too frequently (new session before trade window)

The observability layer must surface this anomaly on every run until it is resolved or explained.

---

## C. Observability Modules

### C1. DATAFLOW_MAP

**Purpose:** Map every field's producer and consumer. Detect orphaned fields, missing consumers, source/runtime schema mismatches, and late context assembly.

**Method:**
- Static grep of all `.mq5`/`.mqh` source files for field declarations and writes
- Compare against OL JSONL field keys (latest record)
- Compare against binary mtime vs source mtime to detect compiled-in fields absent from source
- Cross-reference PIML architecture claims with actual source state

**Specific paths to map:**
1. `BuildCouncilEnvironmentReport` → `CouncilEnvironmentReport` fields → `RunCouncilModePipeline` → `WriteOpportunityLedgerRecord`
2. `CouncilStrategyReport` fields → aggregator → OL per-strategy fields
3. `nr7_shadow_state` path: environment → OL field (verify write)
4. Playbook shadow state (rbsr_state, tpc_state, vcr_state, ifr_state): check if populated in source and if OL records contain them

**Anomaly to detect:** OL records claim schema OL_V1C_IRREW_DEV_V1 but contain zero playbook shadow fields (rbsr_state, tpc_state, vcr_state, ifr_state). This is a schema-version/content mismatch.

**Output:** `dataflow_map.json`
```json
{
  "schema": "DATAFLOW_MAP_V1",
  "generated_at": "...",
  "fields": [
    {
      "field": "nr7_shadow_state",
      "producer": "council_environment.mqh:BuildCouncilEnvironmentReport",
      "consumer": "OL JSONL write path",
      "status": "FLOWING",
      "evidence": "4 OL records contain field",
      "anomaly": null
    },
    {
      "field": "rbsr_state",
      "producer": "unknown / OL_V1C schema claims presence",
      "consumer": "OL JSONL write path",
      "status": "SCHEMA_CLAIMED_NOT_OBSERVED",
      "evidence": "0 of 57 OL records contain field despite OL_V1C schema",
      "anomaly": "FIELD_DECLARED_IN_SCHEMA_NOT_WRITTEN"
    }
  ],
  "anomalies": [],
  "divergence_summary": {}
}
```

**Runtime burden:** ZERO — runs offline.
**Authority risk:** LOW — produces descriptions only.
**Phase:** 1.

---

### C2. PACKET_LIFECYCLE_MONITOR

**Purpose:** For each defined packet type, determine current lifecycle state from evidence.

**Packet states:**
- `ACTIVE`: packet live, producing council-admissible results
- `DORMANT`: defined but not firing (insufficient context, eligibility zero)
- `STARVED`: firing but insufficient N for certification conclusions
- `NOISY`: firing too frequently (rate > threshold), risking starvation of other strategies
- `SHADOW_ONLY`: field deployed, observational only, no live influence authorized
- `READY_FOR_ADVISORY_REVIEW`: threshold met, operator review needed before activation
- `REJECTED_OR_RESEARCH_ONLY`: INEC rejected or research classification only

**Inputs:**
- OL JSONL: trigger_present, filter_passed, confirm_structure_type, nr7_shadow_state, playbook_shadow fields, actual_trade
- OL summary: per-strategy trigger_seen, win_count, loss_count
- Certifications: nautilus_lab/certifications/*.md
- PIML: packet gate status, threshold requirements

**Output:** `packet_lifecycle.json`

**Runtime burden:** ZERO.
**Authority risk:** LOW — lifecycle labels are descriptive; no enabling logic.
**Phase:** 1.

---

### C3. RAW_DATA_HEALTH_MONITOR

**Purpose:** Monitor OHLCV/bar data continuity, spread anomalies, session gaps, symbol mismatches, ATR anomalies. Critical baseline for NR7/VCR/stop-geometry logic which depends on contiguous M5 bar data.

**Inputs:**
- OL JSONL: bar_time field (monotonicity, gap detection, symbol field)
- runtime_governance_status.json: active symbol, mode
- OHLCV exports (nautilus_lab): bar count, date range, missing-bar count
- OL JSONL: spread_atr_fraction (if present) for spread anomaly detection

**Checks:**
1. bar_time monotonicity: any OL record with bar_time < previous bar_time?
2. Session gaps: large time jumps in bar_time sequence (> 30 min outside known session gaps)?
3. Symbol mismatch: OL records with symbol ≠ expected (XAUUSD)?
4. Spread anomaly: spread_points > 200 in recent OL records?
5. OHLCV continuity: for NR7 computation, are 8 consecutive M5 bars available?

**Output:** `raw_data_health.json`
```json
{
  "schema": "RAW_DATA_HEALTH_V1",
  "generated_at": "...",
  "bar_continuity_ok": true,
  "max_gap_minutes": 12,
  "session_gaps_detected": 2,
  "symbol_mismatches": 0,
  "spread_anomaly_count": 0,
  "ohlcv_bars_available": 670,
  "ohlcv_freshness_days": 5,
  "nr7_lookback_feasible": true,
  "anomalies": []
}
```

**Runtime burden:** ZERO.
**Authority risk:** VERY LOW.
**Phase:** 1.

---

### C4. ACTIVITY_LAYER_MONITOR

**Purpose:** Track what is alive, inactive, starved, noisy, or broken per strategy/layer. Detect strategies that are evaluating but never firing, strategies firing too often, layers with zero contribution, and IO/PJ buffer health.

**Inputs:**
- OL JSONL: per-strategy trigger rates, filter_pass rates, actual_trade rates
- OL summary: evaluations_seen, trigger_seen, trigger_executed per strategy
- mt5_io_reduction_status.json: buffered_records_total, flushed_records_total, max_buffer_depth_observed, direct_write_count
- ai_performance_journal.jsonl (if accessible): PJ write count, outcome events
- Experts log (if accessible): session event frequency

**Key metrics per strategy:**

| Metric | Formula | Threshold |
|---|---|---|
| Trigger rate | trigger_seen / evaluations_seen | NOISY > 30%, STARVED < 1% |
| Filter pass rate | filter_passed / trigger_seen | LOW < 20% |
| Actual trade rate | actual_trade / filter_passed | ZERO = CRITICAL ANOMALY |
| Coverage rate | evaluations_seen / total_OL_bars | Dead if 0 |

**Layer states:**
- `IO_BUFFER_HEALTHY`: flushed_records > 0, no buffer overflow, no IO error count
- `IO_BUFFER_STALLED`: buffered_records = max_buffer_depth, flushed = 0 (data at risk)
- `PJ_LOCKED`: ai_performance_journal.jsonl not accessible (device busy)
- `OL_ACTIVE`: new records written since last check
- `OL_STALE`: no new records in > 6 hours during active session

**Current anomaly (confirmed from live data):**
```
IO_BUFFER_STALLED: pj_buffer depth=6/20, flushed_records_total=0
This means 6 PJ records are buffered and have never been flushed.
If MT5 stops without proper deinit, these 6 records are lost.
```

**Output:** `activity_layer.json`

**Runtime burden:** ZERO.
**Authority risk:** LOW.
**Phase:** 1.

---

### C5. EVENT_ORDER_MONITOR

**Purpose:** Diagnose why `event_order_valid=False` in 100% of OL records where the field is present. Track context/location/trigger/confirm assembly order. Detect post-decision shadow assembly.

**Background:** `event_order_valid=False` means the required pre-decision ordering (context → location → trigger → confirmation → stop geometry) is not being met. This is an architectural property that is known to be failing (all LOCATION, TIMING, ROOM packets are NONE or DORMANT). The EVENT_ORDER_MONITOR quantifies the gap precisely.

**Inputs:**
- OL JSONL fields: `event_order_valid`, `confirm_role_present`, `suppression_reason`, `confirm_structure_type`, `late_evidence_assembly` (if present)
- OL summary: `event_order_invalid_seen_count`
- PIML: event_order_valid=false root cause documentation

**Analysis:**
1. `event_order_invalid_seen_count` from OL summary vs total records
2. Distribution of `suppression_reason` values (what's blocking)
3. `confirm_role_present=false` rate (root cause of event_order_valid=false)
4. `confirm_structure_type=NONE` rate vs actual confirm structures
5. `late_evidence_assembly` count (if field present in any records)

**Current finding (from live data):**
- `event_order_valid`: False or absent in ALL 57 records
- `event_order_invalid_seen_count`: 1 (from OL summary — current session only)
- Root cause: No LOCATION packet deployed before decisions; no formal TIMING sequence

**Output:** `event_order_report.json`
```json
{
  "schema": "EVENT_ORDER_V1",
  "event_order_valid_rate": 0.0,
  "event_order_invalid_count": 57,
  "root_causes": {
    "confirm_role_absent": 25,
    "location_absent": 57,
    "timing_absent": 57,
    "no_actual_cause_parsed": 0
  },
  "late_assembly_count": 0,
  "recommendation": "LOCATION_PACKET_DEPLOYMENT_REQUIRED_BEFORE_EVENT_ORDER_VALID_POSSIBLE"
}
```

**Runtime burden:** ZERO.
**Authority risk:** LOW — analysis is diagnostic only; does not prescribe deployment.
**Phase:** 1.

---

### C6. CONTRADICTION_DETECTOR

**Purpose:** Find factual mismatches between PIML claims, source code state, binary timestamps, runtime logs, OL schema/field coverage, strategy registry, and documentation.

**Method:** Systematic cross-reference of known truths across sources. Each contradiction is classified by severity:
- `CRITICAL`: contradicts active architecture claim; requires immediate resolution
- `HIGH`: significant state mismatch; may cause downstream confusion
- `MEDIUM`: inconsistency between documents; historical artifact likely
- `LOW`: stale documentation; no operational impact

**Specific contradiction checks:**

| Check | Source A | Source B | Expected | Anomaly If |
|---|---|---|---|---|
| OL schema vs field presence | OL schema_version=OL_V1C_IRREW_DEV_V1 | OL records contain playbook fields | Fields present in records | 0 of 57 records have rbsr_state/tpc_state/vcr_state/ifr_state |
| OL writer in source | Static grep of all .mqh/.mq5 for WriteOpportunityLedgerRecord | OL JSONL being written with nr7_shadow_state | Source contains writer | Writer not found in current source; binary-source divergence |
| PIML NR7 shadow status | PIML says "SPEC_COMPLETE_AWAITING_CODEX" | OL has 4 records with nr7_shadow_state | Status = DEPLOYED | Status mismatch (spec said awaiting but shadow is live) |
| actual_trade=true rate | PIML says system producing trades | OL actual_trade=true count | actual_trade > 0 | Zero actual trades across 57 records |
| OL summary vs JSONL record count | OL summary total_trigger_writes=1 | OL JSONL has 57 records | Summary tracks all historical | Expected: summary is session-reset; document this as EXPECTED_VARIANCE not anomaly |
| Binary mtime vs source mtime | main_ea.ex5 mtime | council_mode_runtime.mqh mtime | Binary compiled after source | Discrepancy noted in POST_COMPILE doc — EXPECTED |
| OL write path in source | WriteOpportunityLedgerRecord absent from all current .mqh/.mq5 | OL records being written | Source has OL writer | Source-binary DIVERGENCE — HIGH |
| Strategy count | COUNCIL_MAX_STRATEGIES=17 (council_mode_types.mqh:10) | active_strategies_count in OL records | Both=17 | Check if any record shows active_strategies_count≠17 |
| filter_passed vs actual_trade | filter_passed=true in 32 records | actual_trade=true in 0 records | actual_trade ≥ 1 | 32 approved but 0 executed — CRITICAL |

**Output:** `contradiction_report.md`

```markdown
# CONTRADICTION_REPORT — SYSTEM_INTELLIGENCE_V1

Generated: <datetime>

## CRITICAL

### C1: actual_trade=true = 0 across all 57 OL records (32 filter_passed=true)
- Source A: OL JSONL records (filter_passed=true in 32 records)
- Source B: OL JSONL records (actual_trade=true in 0 records)
- Contradiction: 32 structurally approved decisions, 0 trades executed
- Likely causes: EnableRuntimeExecution, OneTradeAttemptPerBar, position management gate, governance block post-filter
- Action required: Investigate execution gate stack; resolve before any Phase 4/5 design

## HIGH

### C2: OL writer (WriteOpportunityLedgerRecord) not in current source
- Source A: OL JSONL records being written with nr7_shadow_state field
- Source B: Grep of all current .mqh/.mq5 — WriteOpportunityLedgerRecord: 0 matches
- Contradiction: Source-binary divergence; running binary has OL write capability not in source
- Action required: Re-establish OL writer in source before next compile

### C3: OL schema claims OL_V1C_IRREW_DEV_V1 but playbook shadow fields absent
- Source A: record_version=OL_V1C_IRREW_DEV_V1 in multiple records
- Source B: rbsr_state, tpc_state, vcr_state, ifr_state: 0 of 57 OL records contain these fields
- Contradiction: Schema version implies field presence; fields absent
- Action required: Verify OL_V1C schema populates playbook fields; may be compile-time vs runtime version mismatch

## EXPECTED_VARIANCE (not anomalies — documented for clarity)

### E1: OL summary total_trigger_writes ≠ OL JSONL record count
- OL summary: total_trigger_writes=1 (current session)
- OL JSONL: 57 records (historical)
- Resolution: OL summary resets each EA session. Both values are correct for their scope.

### E2: Binary mtime discrepancy
- Noted in POST_COMPILE_RUNTIME_FLAGS_AND_GIT_STATE_VERIFICATION_V1.md
- Verdict: VERIFIED_WITH_CAVEATS. Not an active anomaly.
```

**Runtime burden:** ZERO.
**Authority risk:** MEDIUM — output must be labeled ANOMALY REPORT, not VERDICT; no contradiction automatically authorizes a code change.
**Phase:** 1.

---

### C7. SHADOW_EFFECT_TRACKER

**Purpose:** For deployed shadows (currently `nr7_shadow_state`; future: FVG/TPB shadow, playbook advisory), measure outcome correlation with and without the shadow state. Helps decide when a shadow should remain offline, become advisory, or be rejected.

**Current deployed shadows:**
- `nr7_shadow_state`: Live in 4 OL records (all NONE — no NR7 bars observed yet in new session)
- FVG/TPB: advisory active (IMBALANCE_FILL_REVERSAL) — observational
- ATAS governed advisory: advisory state in OL (atas_advisory_state fields)

**Analysis plan (when sufficient N):

| Shadow | Required N for analysis | Current N | Status |
|---|---|---|---|
| nr7_shadow_state (ATR_FILTERED vs NONE) | ≥ 20 with nr7_shadow_state ≠ NONE | 0 | INSUFFICIENT |
| nr7_shadow_state (ATR_FILTERED + actual_trade) | ≥ 5 actual trades | 0 | INSUFFICIENT |
| FVG/TPB co-presence | ≥ 10 fvg_tpb trigger_present records | 2 | INSUFFICIENT |
| Playbook shadow states | ≥ 5 events per playbook state | 0 (fields absent) | BLOCKED |

**Algorithm when sufficient N:**
1. Split OL records by shadow state (e.g., nr7=ATR_FILTERED vs nr7=NONE)
2. Compare: filter_pass_rate, actual_trade_rate, result distribution
3. Compute lift: delta_filter_pass_rate, delta_WR (when actual_trade=true available)
4. Classify: OBSERVABLE_LIFT (≥ +2pp), NO_OBSERVABLE_LIFT, INSUFFICIENT_N, ADVERSE_EFFECT

**Output:** `shadow_effect_report.json`

**Runtime burden:** ZERO.
**Authority risk:** MEDIUM — output labeled OBSERVATIONAL; findings may not be used to activate shadow influence without operator gate.
**Phase:** 2 (requires nr7_shadow_state ≠ NONE in ≥ 20 records AND actual_trade=true in ≥ 5 records).

---

### C8. READINESS_GATE_MONITOR

**Purpose:** For every defined gate and N threshold in the project, track current N, required N, gap, and estimated ETA.

**Inputs:**
- OL JSONL: per-strategy and per-state N counts
- PJ JSONL: actual trade count (when accessible)
- PIML: threshold definitions, gate status
- Certifications: current certification state

**Gate monitoring approach:**
- Parse threshold requirements from PIML and certification docs
- Count current evidence from OL JSONL
- Compute gap and estimated ETA (at current trigger rate × days)

**Output:** `readiness_gate_state.json` (see Matrix 4 for full gate table)

**Current alert:** `actual_trade=true` count = 0 means all gate thresholds requiring actual trade outcomes are blocked regardless of N. This is a systemic blocker.

**Runtime burden:** ZERO.
**Authority risk:** LOW — gate status is descriptive; no gate monitor output enables any phase.
**Phase:** 1.

---

## D. Data Source Matrix

| Source | What It Provides | Read Frequency | Reliability | Risk | New Fields Needed? |
|---|---|---|---|---|---|
| `ai_opportunity_ledger.jsonl` | Per-bar per-strategy context; NR7/playbook shadow states; event order; filter/trade outcomes | Periodic (phase 1) | HIGH | MEDIUM (may grow large; device lock possible) | NO — existing fields sufficient for Phase 1 |
| `ai_opportunity_summary.json` | Current-session aggregate counters, strategy trigger/execute stats | Periodic | HIGH | LOW | NO |
| `ai_performance_journal.jsonl` | Trade outcomes, PJ record types, session events | On-demand | MEDIUM (device busy risk) | HIGH (device lock) | NO — handle IOError gracefully; use journal_copy if needed |
| `ai_trade_feedback.json` | Trade feedback, last trade result, trade count | Periodic | HIGH | LOW | NO |
| `runtime_governance_status.json` | Governance state, active plan/mode, zone, decision | Periodic | HIGH | LOW | NO |
| `execution_authority_status.json` | Execution authority, decision candidate, freeze state | Periodic | HIGH | LOW | NO |
| `mt5_io_reduction_status.json` | IO buffer depth, flush counts, buffer stall detection | Periodic | HIGH | LOW | NO |
| `council_audit_summary.json` | Audit summary from council mode (filter rates, outcome summary) | Periodic | HIGH | LOW | NO |
| `ai_strategy_memory.json` | Strategy confidence memory, version | Periodic | HIGH | LOW | NO |
| `active_operating_cohort.json` | Active cohort families, admission semantics | Occasional | HIGH | LOW | NO |
| `diagnostic_runtime_summary.json` | Latest decision context, rejection layers | Periodic | HIGH | LOW | NO |
| `last_meaningful_runtime_event.json` | Last significant event type and time | Periodic | HIGH | LOW | NO |
| `atas_governed_advisory_status.json` | ATAS advisory state, effectiveness | Periodic | HIGH | LOW | NO |
| `atas_governed_advisory_effectiveness.json` | ATAS advisory outcome tracking | Periodic | HIGH | LOW | NO |
| Experts logs (`MQL5/Logs/YYYYMMDD.log`) | Timestamped events, error messages, execution events | Periodic | HIGH | MEDIUM (large files; parse only tail) | NO |
| PIML (`PROJECT_INTELLIGENCE_MEMORY_LAYER.md`) | Project truth, gate thresholds, certification status | On-demand | HIGH | LOW | NO |
| DOCS_SYSTEM reports | Architecture context, certification verdicts, audit reports | On-demand | HIGH | LOW | NO |
| Source files (static grep) | Field declarations, function locations, include chains | On-demand | HIGH | LOW | NO |
| OHLCV exports (nautilus_lab) | M1/M5 bar data for offline reconstruction and NR7 validation | On-demand | MEDIUM (may be stale) | LOW | NO |
| `ai_decision_envelope_trace.jsonl` | Per-decision envelope trace (gate-level) | Periodic | HIGH | LOW | NO |
| `operating_risk_envelope_status.json` | Risk envelope state, risk gate status | Periodic | HIGH | LOW | NO |

**Data source minimalism principle:** All 8 observability modules can be implemented using ONLY the sources listed above. No new MT5 runtime files need to be created for Phase 1. No new fields in any existing file are required for Phase 1. Derivation takes priority over new fields.

---

## E. Packet Monitoring Matrix

| Packet | Type | Current Evidence | Missing Proof | Readiness Threshold | Current Status | Next Action |
|---|---|---|---|---|---|---|
| NR7 ALPHA_TRIGGER | VCR/BREAKOUT | INEC: WR=58.3%, E[R]=+0.456R, PF=2.094, N=5,498 | OCO infrastructure; live actual_trade outcomes | Separate OCO gate; COUNCIL_MAX_STRATEGIES increase | SHADOW_ONLY (field deployed, all NONE in 4 records — no NR7 bars yet in session) | Monitor OL daily for nr7≠NONE records |
| NR7 LOCATION | LOCATION | INEC: series +3.77pp WR lift, N=1,034 | N_nr7_context ≥ 20 actual trades | Gate 3A1: N_nr7_actual_trade ≥ 20 | SHADOW_ONLY (field live, effect unmeasurable until actual trades) | Wait; recheck when actual_trade=true ≥ 1 |
| NR7 STOP_GEOMETRY | STOP_GEOMETRY | INEC: +6.32pp WR vs ATR stop | PJ V3 schema with MAE/entry_price fields | Gate 3B: MAE data accessible | SHADOW_ONLY — Gate 3B BLOCKED | Unlock PJ V3 schema; request journal copy with entry_price |
| FVG/TPB IMBALANCE_FILL | FAILURE_MODE / CONFIRMATION | Advisory active; trigger_seen=2 | ≥ 10 actual trades with FVG context | N_fvg_actual ≥ 10 | SHADOW_ONLY (advisory role, no live influence) | Wait; 2 trigger_seen insufficient |
| MFI EXHAUSTION | FAILURE_MODE / EXHAUSTION | trigger_seen=10 in OL | ≥ 5 actual trades with MFI context | N_mfi_actual ≥ 5 | STARVED (trigger active but 0 actual trades) | Blocked by actual_trade=0 systemic issue |
| TPC CONFIRMATION | CONFIRMATION (cross-family) | ~1 co-presence event estimated in 57 records | ≥ 5 co-presence firings with actual trades | N_tpc_copresence ≥ 5 actual trades | STARVED (insufficient co-presence + 0 actual trades) | Wait; check cross_family_confirm_present=true rate in OL |
| RBSR CONFIRMATION | CONFIRMATION (cross-family) | 0 cross-family certified pairs | WR lift ≥ +2pp AND E[R] lift ≥ +0.04R | N_confirm ≥ 30 actual-trade pairs | DORMANT (cross_family_confirm_present=true rate: check OL) | Monitor confirm_structure_type=CROSS_FAMILY_CONFIRM in OL |
| VCR ALPHA_TRIGGER (general) | VCR | TTM Squeeze REJECTED (WR=36.7%, E[R]=−0.083R) | New candidate INEC accepted | INEC acceptance → OCO gate | RESEARCH_ONLY (NR7 OCO is best current VCR candidate) | Continue NR7 shadow observation; TTM Squeeze KC multiplier variation is research option |
| TIMING | TIMING | event_order_valid=False in 100% of records | Any event_order_valid=true | event_order_valid rate ≥ 50% | NOT_STARTED (no timing packet designed or deployed) | Design TIMING packet architecture (separate mission) |
| ROOM | ROOM | room_state=UNKNOWN in all records | Room packet defined, testable | N_room_valid ≥ 20 | NOT_STARTED | Defer until actual_trade=true ≥ 1 |
| STOP_GEOMETRY (general) | STOP_GEOMETRY | ATR×1.20 baseline only in core_trade_engine.mqh | Box stop MAE comparison | Gate 3B MAE data | BLOCKED (source-binary divergence on OL writer; Gate 3B blocked) | Resolve OL writer divergence; unlock PJ |
| EXECUTION_GEOMETRY | EXECUTION_GEOMETRY | IRREW dev flag: False | All Phase 4 preconditions | IRREW master_dev authorized + Phase 4C gate | BLOCKED — DO NOT ACTIVATE | Maintain IRREW flags at FALSE |
| PLAYBOOK_ADVISORY | PLAYBOOK_ADVISORY | IRREW dev flag: False | All Phase 4 preconditions + PLAYBOOK_VALID | IRREW master_dev authorized + PLAYBOOK_VALID | BLOCKED — DO NOT ACTIVATE | Maintain IRREW flags at FALSE |
| CROSS-FAMILY CONFIRMATION (any) | CONFIRMATION | 0 certified cross-family pairs in OL | ≥ 30 actual-trade pairs with cross-family co-presence | WR lift ≥ +2pp AND E[R] lift ≥ +0.04R | DORMANT | Monitor confirm_structure_type field in OL; blocked by 0 actual trades |

---

## F. Readiness Gate Matrix

| Gate / Phase | Required N | Current N | Status | Activation Risk | Recommendation |
|---|---|---|---|---|---|
| **actual_trade=true ≥ 1 (any trade)** | 1 | 0 | **CRITICAL BLOCKER** | N/A | Investigate execution gate stack immediately; all outcome-dependent gates blocked until resolved |
| NR7 Gate 3A0 (offline attribution) | N/A (Python only) | COMPLETE (run 2026-05-11) | COMPLETE | NONE | Rerun monthly as OL accumulates |
| NR7 Gate 3A1 (live OL attribution) | N_nr7_context ≥ 20 actual trades | 0 (0 actual trades; 4 records with nr7 field, all NONE) | WAITING_FOR_N | LOW | Monitor weekly; trigger rerun when N_nr7_active ≥ 5 |
| NR7 Gate 3B (stop geometry MAE) | PJ V3 schema with entry_price, sl_price, mae_pts | 0 MAE records accessible (device busy + schema gap) | BLOCKED | LOW (offline Python only) | Request journal_copy.jsonl with V3 fields; or await PJ buffer flush + copy |
| NR7 Codex implementation | Operator authorization | DEPLOYED (4 records with nr7_shadow_state) | COMPLETE | LOW | Verify nr7≠NONE appears within 50 OL bars |
| Phase 4A (TPC cross-family CRR) | TPC co-presence ≥ 5 actual trades | ~1 estimated co-presence (0 actual trades) | WAITING_FOR_N + BLOCKED by actual_trade=0 | MEDIUM | Do not enable; ETA unknown |
| Phase 4B (MFI exhaustion veto) | ≥ 5 MFI signal strength readings with actual outcomes | trigger_seen=10, actual_trade=0 | BLOCKED by actual_trade=0 | MEDIUM | Do not enable |
| RBSR PLAYBOOK_VALID | N_confirm ≥ 30 cross-family actual-trade pairs; WR lift ≥ +2pp | 0 | WAITING_FOR_N | MEDIUM | PLAYBOOK_VALID is evidence target, NOT permission gate |
| TPC PLAYBOOK_VALID | Same | 0 | WAITING_FOR_N | MEDIUM | Same — not permission gate |
| VCR PLAYBOOK_VALID | VCR ALPHA_TRIGGER INEC accepted + OCO gate | NR7 OCO blocked; TTM Squeeze rejected | BLOCKED | HIGH | Design OCO separately; do not treat as unlocked |
| OCO infrastructure | Separate design gate + operator authorization | Zero OCO infrastructure in source | NOT_AUTHORIZED | HIGH | Requires separate architecture mission |
| COUNCIL_MAX_STRATEGIES increase | Operator gate + 18th strategy design | At capacity 17/17 | NOT_AUTHORIZED | HIGH | Do not increase without explicit gate |
| Cleanup Package B | Management authorization | Deferred | NOT_AUTHORIZED | LOW | Defer; not blocking |
| IRREW Phase 4C | IRREW master dev authorized + Phase 4C gate | IRREW master_dev=false | NOT_AUTHORIZED | HIGH | Maintain at false |
| IRREW RCEM | Same | Same | NOT_AUTHORIZED | HIGH | Same |
| IRREW Execution Geometry | Same | Same | NOT_AUTHORIZED | HIGH | Same |
| IRREW Playbook Advisory | Same | Same | NOT_AUTHORIZED | HIGH | Same |
| Production Ready | Multiple conditions | FALSE | NOT_READY | N/A | Runtime validation required |

**ETA estimates** (illustrative — based on current XAUUSD M5 session activity):
- OL accumulates ~5 trigger_present records per session at current rates
- actual_trade=true blocked systemically — ETA: unknown until gate stack investigated
- nr7_shadow_state ≠ NONE: at 7.5% M5 bar rate, expect ~1 per 13 OL records → ~10 OL records per NR7-active event → Gate 3A1 ETA ~100+ OL records after actual trades begin

---

## G. AI Role and Boundaries

### G1. What AI (Claude) Does in This Layer

The observability layer may use Claude (or equivalent LLM) for:
- Interpreting contradiction reports (classifying HIGH vs MEDIUM severity)
- Drafting system_intelligence_report.md narrative sections
- Synthesizing readiness gate state into executive summary
- Identifying non-obvious patterns in OL field distributions
- Drafting PIML update recommendations after design completion

### G2. What AI Must NOT Do

| Forbidden | Why |
|---|---|
| Generate BUY/SELL signals from observability data | Violates authority boundary |
| Classify READINESS_GATE_MONITOR output as permission | Gate status is descriptive; authorization requires explicit operator action |
| Recommend source changes based on shadow effect tracker alone | Shadow effect tracker is observational; N is insufficient for implementation decisions |
| Use PLAYBOOK_VALID appearance as phase activation permission | Explicitly forbidden in governance |
| Interpret contradiction as automatic bug | Contradictions require investigation; some are expected variance |
| Claim production readiness from observability evidence | Readiness is multi-condition; no single gate closes it |

### G3. Hard Scope Boundary

All observability layer outputs must carry:
```json
{
  "artifact_role": "OBSERVABILITY_ONLY_NON_AUTHORITATIVE",
  "runtime_authority_status": "NONE",
  "production_ready": false
}
```

No output file from the observability layer may be read by any MT5 source file that affects `final_decision`, `filter_passed`, entry price, stop price, lot size, or position management.

---

## H. Runtime Burden Strategy

### H1. IO Burden Assessment

| Phase | IO Impact | Assessment |
|---|---|---|
| Phase 0–1 (offline scanner) | ZERO additional MT5 IO | SAFE — reads existing files only |
| Phase 2 (report generator) | ZERO additional MT5 IO | SAFE — writes to nautilus_lab, not MQL5/Files/AI |
| Phase 3 (dashboard integration) | ZERO additional MT5 IO | SAFE — reads dashboard outputs that already exist |
| Phase 4 (alerting) | ZERO additional MT5 IO | SAFE — alerting is external |
| Phase 5 (minimal runtime hooks) | LOW — 1-2 additional JSON writes per session | REQUIRES IO IMPACT REVIEW before implementing |

### H2. PJ Buffer Stall Detection

**Current state:** `pj_buffer_depth=6, flushed_records_total=0, max_buffer_depth_observed=6`

This is a `IO_BUFFER_STALLED` condition: the PJ buffer is at capacity (6/20 non-critical records buffered) with zero flushes in the current session. This is concerning because:
- The flush condition is: `5 bars elapsed` OR `critical event preflush` OR `deinit`
- If the session is still in early bars (unique_m1_bar_count=1), no flush has occurred yet — this may be normal
- But if bars have elapsed without flush, data could be lost at deinit

The observability layer should flag when `buffered_records_total ≥ pj_buffer_max_records - 3` with no recent flush.

### H3. What the Observability Layer Must NOT Add to MT5 Runtime

The following are explicitly out of scope for Phase 1–4:
- No new `FileOpen`/`FileWrite` calls inside `OnTick`, `OnTimer`, or `OnTradeTransaction`
- No new struct fields in `CouncilEnvironmentReport`, `CouncilStrategyReport`, or `CouncilRuntimeResult`
- No new JSONL files in `MQL5/Files/AI/` from the observability scanner
- No changes to council_mode_runtime.mqh, council_environment.mqh, or council_strategies.mqh
- No changes to any file in the MT5 source tree

---

## I. Implementation Roadmap

### Phase 0 — Architecture Documentation (THIS MISSION)
- Deliverable: `DOCS_SYSTEM/01_ARCHITECTURE/SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1_DESIGN.md`
- Status: COMPLETE after this document is written
- Cost: Zero runtime impact

### Phase 1 — Offline Scanner (Python, nautilus_lab)
- Deliverable: `nautilus_lab/system_intelligence/siol_scanner.py`
- Modules: DATAFLOW_MAP, PACKET_LIFECYCLE_MONITOR, RAW_DATA_HEALTH_MONITOR, ACTIVITY_LAYER_MONITOR, EVENT_ORDER_MONITOR, CONTRADICTION_DETECTOR, READINESS_GATE_MONITOR (7 of 8)
- Outputs: `system_intelligence_snapshot.json`, `system_intelligence_report.md`, `readiness_gate_state.json` (in `nautilus_lab/outputs/`)
- Authorization needed: Operator confirmation ("Authorize SIOL Phase 1 Python scanner implementation")
- Compile: NO | MT5 reload: NO | Source changes: NO
- Prerequisite: This design document complete + operator gate

### Phase 2 — Scheduled Report Generator + Shadow Effect Tracker
- Deliverable: `nautilus_lab/system_intelligence/siol_scheduler.py` (or OS task)
- Modules: SHADOW_EFFECT_TRACKER (module 7) added once N_nr7_active ≥ 5
- Adds: Scheduled runs every 6 hours; report delta detection
- Authorization needed: Phase 1 complete + operator confirmation
- Prerequisite: actual_trade=true ≥ 1 (otherwise Shadow Effect Tracker is trivially empty)

### Phase 3 — Dashboard Read-Only Integration (Optional)
- Deliverable: Dashboard panel reading `system_intelligence_snapshot.json`
- Method: Dashboard reads the JSON; no new writes from observability layer
- Authorization needed: Phase 2 complete + operator confirmation
- Prerequisite: Dashboard architecture supports external JSON read

### Phase 4 — Alerting (Optional)
- Deliverable: Email/notification when critical anomaly detected
- Method: External (Python→email/Slack/webhook); no MT5 involvement
- Authorization needed: Phase 3 complete + operator confirmation

### Phase 5 — Minimal Runtime Hooks (Optional, Only If Proven Necessary)
- Deliverable: Up to 2 new observability-only fields in existing OL/status files
- Method: Only if offline analysis proves certain states cannot be captured post-hoc
- Authorization needed: IO impact review + Phase 4 complete + source-binary divergence resolved + operator confirmation
- Hard constraint: No new fields may influence any council decision path

---

## J. PIML Section Proposal

The following section should be added to PIML under a new heading `## SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1`:

```markdown
## SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1

**Purpose:** Read-only observer layer for dataflow, packet lifecycle, anomaly detection, contradiction detection, readiness gate monitoring, shadow effect tracking, and system intelligence reporting. NOT a trading decision engine. MT5 remains runtime authority.

**Authority boundary:**
- All outputs: OBSERVABILITY_ONLY_NON_AUTHORITATIVE
- runtime_authority_status: NONE for all artifacts
- Production Ready: FALSE (of the layer itself)
- No output may be consumed by any MT5 decision path

**Active modules:** 8 defined; 0 implemented (Phase 0 complete only)

**Monitored files:**
- ai_opportunity_ledger.jsonl (primary)
- ai_opportunity_summary.json
- ai_performance_journal.jsonl
- mt5_io_reduction_status.json
- runtime_governance_status.json
- execution_authority_status.json
- Experts logs
- PIML, DOCS_SYSTEM, source files (static)

**Readiness thresholds tracked:**
- actual_trade=true ≥ 1 (CRITICAL BLOCKER — currently 0)
- NR7 Gate 3A1: N_nr7_actual_trade ≥ 20 (currently 0)
- NR7 Gate 3B: PJ V3 MAE schema accessible (currently BLOCKED)
- Phase 4A/4B: IRREW flags remain FALSE (NOT_AUTHORIZED)
- COUNCIL_MAX_STRATEGIES: at 17/17 capacity (NOT_AUTHORIZED to increase)

**Latest snapshot:** None (Phase 1 not yet implemented)

**Active anomalies:**
1. CRITICAL: actual_trade=true = 0 across all 57 OL records (32 filter_passed=true)
2. HIGH: WriteOpportunityLedgerRecord absent from current source (source-binary divergence)
3. HIGH: OL schema OL_V1C_IRREW_DEV_V1 claims playbook shadow fields; 0 of 57 records contain them
4. MEDIUM: PJ buffer stall — 6 records buffered, 0 flushed in current session

**Blocked phases:** IRREW (all phases), Phase 4A/4B/4C/RCEM/ExecutionGeometry/PlaybookAdvisory, OCO infrastructure, COUNCIL_MAX_STRATEGIES increase, Cleanup Package B

**Next recommended review:** After Phase 1 scanner is implemented and first run completes

**Forbidden actions:**
- Do not connect observability outputs to any MT5 decision path
- Do not use READINESS_GATE_MONITOR output as automatic activation permission
- Do not treat SHADOW_EFFECT_TRACKER lift as implementation authorization
- Do not increase IO burden without explicit Phase 5 gate authorization
- Do not use PLAYBOOK_VALID state as permission gate

**Design report:** DOCS_SYSTEM/01_ARCHITECTURE/SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1_DESIGN.md
**Phase 0 complete:** 2026-05-12
**Phase 1 authorized:** PENDING OPERATOR CONFIRMATION
```

---

## K. What Must NOT Be Implemented

The following are explicitly excluded from this design and from any downstream implementation:

| Forbidden | Reason |
|---|---|
| BUY/SELL/WAIT generation from observability data | Authority boundary violation |
| MT5 source changes in Phase 1–4 | No compile, no reload required; offline-first architecture |
| New JSONL files in MQL5/Files/AI/ from scanner | Observability outputs go to nautilus_lab/outputs, not runtime dir |
| PLAYBOOK_VALID as permission gate in any code | PLAYBOOK_VALID is certification evidence target, not operator authorization |
| IRREW dev flag activation from observability findings | IRREW phases require explicit operator gate; observability evidence alone does not authorize |
| Shadow effect tracker findings as implementation authorization | All tracker findings are observational; require separate INEC or operator gate |
| Starvation-risk-based automatic strategy disabling | All strategy admission changes require explicit cohort gate |
| Phase 5 MT5 runtime hooks without IO impact review | IO burden must be assessed and approved before any new OnTick/OnTimer writes |
| Contradiction report findings as automatic code revert triggers | Contradictions require investigation; no automatic action |
| actual_trade=0 anomaly used to justify authority changes | Investigate execution gate stack; do not bypass governance to force trades |

---

## L. Report Path

Architecture report written to:
```
DOCS_SYSTEM/01_ARCHITECTURE/SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1_DESIGN.md
```

DOCS_SYSTEM_INDEX.md: Update required (01_ARCHITECTURE now 12 files; total 37 docs).

PIML: Update required (CURRENT STATE ANCHOR: design complete, Phase 1 pending authorization).

---

## M. Final Decision

```
VERDICT:            SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_DESIGN_READY
SPEC_STATUS:        DESIGN_COMPLETE
SOURCE_CHANGED:     NO
COMPILE_RUN:        NO
MT5_RELOAD:         NO
RUNTIME_AUTH:       NONE
PRODUCTION_READY:   FALSE
CODEX_INVOLVED:     NO
IMPLEMENTATION:     PHASE_1_PENDING_OPERATOR_CONFIRMATION
ACTIVE_ANOMALIES:   4 (1 CRITICAL, 2 HIGH, 1 MEDIUM — see PIML section)
```

**To advance to Phase 1 implementation, operator must confirm:**

> Authorize SIOL Phase 1 Python scanner (`nautilus_lab/system_intelligence/siol_scanner.py`) implementation per design at `DOCS_SYSTEM/01_ARCHITECTURE/SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1_DESIGN.md`.

**Critical anomaly requiring immediate attention (independent of SIOL):**

> `actual_trade=true = 0` across all 57 OL records despite 32 `filter_passed=true` decisions. This is not a SIOL implementation issue — it requires investigation of the execution gate stack (`EnableRuntimeExecution`, `OneTradeAttemptPerBar`, position management, governance blocks) before any outcome-dependent phase can be designed.

```
DESIGN_ID:          SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_V1_DESIGN
DATE:               2026-05-12
SOURCE_CHANGED:     NO
COMPILE_RUN:        NO
MT5_RELOAD:         NO
RUNTIME_FILES_MODIFIED: NO
CODEX_INVOLVED:     NO
PRODUCTION_READY_CLAIMED: NO
VERDICT:            SYSTEM_INTELLIGENCE_OBSERVABILITY_LAYER_DESIGN_READY
```
