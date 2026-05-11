# MT5_IO_REDUCTION_V1_PACKAGE3_FORENSIC_REVIEW

**Date:** 2026-05-10
**Reviewer:** Claude (Package 3 forensic review — read-only, no source changes)
**Subject:** Post-implementation forensic audit of MT5_IO_REDUCTION_V1 Package 2
**Codex implementation report:** `DOCS_SYSTEM/02_IMPLEMENTATION_REPORTS/MT5_IO_REDUCTION_V1_PACKAGE2_IMPLEMENTATION_REPORT.md`
**Compile log:** `compile_mt5_io_reduction_v1_package2_20260510_211952.log`

---

## A. Executive Verdict

**`PASS_RELOAD_ALLOWED_WITH_CAVEATS`**

The MT5_IO_REDUCTION_V1 implementation is forensically sound for reload. All ten primary checks pass at the source level:

1. Trading behavior is unchanged — verified at source.
2. Critical evidence remains immediate — verified at source.
3. Non-critical buffering is bounded and safe — verified at source.
4. Event ordering is preserved — critical preflush confirmed.
5. OnDeinit flush exists and is correctly wired — confirmed at line 13655 of main_ea.mq5.
6. `EnableMT5IOReductionV1=false` restores direct-write behavior — verified at source.
7. IO counters are diagnostic-only — verified; not read by any trading logic.
8. Runtime JSON/JSONL history was not modified — backup timestamp scan confirms.
9. No authority path was changed — static search and scope scan confirm.
10. Reload can proceed with caveats — see Section N.

No blocking findings were identified. The seven non-blocking caveats in Section N are observational; none represent safety or correctness defects.

---

## B. Scope / Diff Audit

### Files Approved for Modification

| File | Role | Modified After Backup? |
|---|---|---|
| `main_ea.mq5` | EA main (IO gates, OnDeinit, governance, status) | YES (21:19:40) — expected |
| `performance_journal.mqh` | PJ buffer, flush, critical classifier | YES (21:08:11) — expected |
| `council_mode_runtime.mqh` | Trend-cont gate, OL summary rate limit | YES (21:08:33) — expected |
| `mt5_io_reduction_v1.mqh` | New file: inputs, counters, accessors | YES (21:03:23) — expected |
| `main_ea.ex5` | Compiled binary | YES (21:24:19) — expected |

Backup timestamp: `2026-05-10 20:58:29`

### Unapproved Files — Modification Scan

All critical unapproved files verified unmodified after backup timestamp:

| File | Last Modified | Status |
|---|---|---|
| `council_strategies.mqh` | 2026-05-09 06:56:42 | OK — predates backup |
| `council_aggregator.mqh` | 2026-05-10 00:18:40 | OK — predates backup |
| `council_pre_ai_filter.mqh` | 2026-04-30 14:58:15 | OK — predates backup |
| `council_ai_governor.mqh` | 2026-04-30 03:16:23 | OK — predates backup |
| `core_trade_engine.mqh` | 2026-05-02 23:49:11 | OK — predates backup |
| `decision_mode_router.mqh` | 2026-04-16 20:53:41 | OK — predates backup |
| `council_mode_types.mqh` | 2026-05-10 00:10:48 | OK — predates backup |
| `council_environment.mqh` | 2026-04-29 22:09:40 | OK — predates backup |
| `council_memory.mqh` | 2026-04-23 06:24:55 | OK — predates backup |
| `council_failure_detector.mqh` | 2026-04-17 21:33:07 | OK — predates backup |
| `council_feedback.mqh` | 2026-04-23 06:24:36 | OK — predates backup |

PowerShell scan of all `.mq5`/`.mqh` files modified after backup and not in the approved list: **0 files found. SCOPE_CLEAN.**

No `.set` files were modified. No `MQL5/Files/AI/` runtime JSON/JSONL history was modified.

---

## C. Trading Authority Safety

**PASS — VERIFIED AT SOURCE.**

Static search results:

| Search Target | council_strategies.mqh | council_aggregator.mqh | core_trade_engine.mqh |
|---|---|---|---|
| `g_mt5io_*` variables | 0 matches | 0 matches | 0 matches |
| `EnableMT5IOReductionV1` | 0 matches | 0 matches | 0 matches |
| `EnablePJBuffer` | 0 matches | 0 matches | 0 matches |
| `EnableGovernanceDirtyFlag` | 0 matches | 0 matches | 0 matches |
| `EnableTrendContGate` | 0 matches | 0 matches | 0 matches |
| `EnableOLSummaryRateLimit` | 0 matches | 0 matches | 0 matches |

IO flags and counters are completely absent from all trading authority files. IO reduction inputs cannot influence BUY/SELL/WAIT decisions, risk policy, stop geometry, lot sizing, cohort admission, or any IRREW/PCEA/V1 path.

The `score_authority_warning` reference found at main_ea.mq5:10336 is a pre-existing annotation diagnostic field — not a new addition and not a regression.

---

## D. Feature Flag Safety

**PASS — VERIFIED AT SOURCE.**

### Master Flag

`EnableMT5IOReductionV1` (mt5_io_reduction_v1.mqh:14) is the master gate. All five component flags are ANDed with it:

| Component | Guard Expression | Source Location |
|---|---|---|
| PJ buffer | `EnableMT5IOReductionV1 && EnablePJBuffer` | performance_journal.mqh:1847 |
| Governance dirty flag | `EnableMT5IOReductionV1 && EnableGovernanceDirtyFlag` | main_ea.mq5:5999 |
| Trend-cont gate | `EnableMT5IOReductionV1 && EnableTrendContGate` | council_mode_runtime.mqh:163 |
| OL summary rate limit | `EnableMT5IOReductionV1 && EnableOLSummaryRateLimit` | council_mode_runtime.mqh:2445 |
| IO status write | `MT5IO_MasterEnabled()` (returns `EnableMT5IOReductionV1`) | main_ea.mq5:2000–2007 |

### Fallback Behavior When `EnableMT5IOReductionV1=false`

- `MT5IO_PJBufferActive()` returns `false` → `PJ_AppendLine` always calls `PJ_WriteLineDirect` → direct FileOpen/SeekEnd/Write/Close per record (legacy behavior)
- Governance dirty flag: condition at line 5999 fails → write proceeds every call (legacy behavior)
- Trend-cont gate: condition at line 163 `gateActive && last_bar >= 0` is false when `gateActive=false` → write every call (legacy behavior)
- OL summary: `ol_rate_enabled = false` → summary written on every qualifying count (legacy behavior)

**Confirmed: `EnableMT5IOReductionV1=false` restores direct-write behavior as closely as possible without recompile.**

### Defaults Verified

Defaults confirmed at source (mt5_io_reduction_v1.mqh:14–24):

| Input | Default |
|---|---|
| `EnableMT5IOReductionV1` | `true` |
| `EnablePJBuffer` | `true` |
| `PJFlushIntervalBars` | `5` |
| `PJBufferMaxRecords` | `20` |
| `EnableGovernanceDirtyFlag` | `true` |
| `RuntimeGovernanceHeartbeatSeconds` | `300` |
| `EnableTrendContGate` | `true` |
| `TrendContStatusIntervalBars` | `5` |
| `EnableOLSummaryRateLimit` | `true` |
| `OLSummaryWriteEveryNRecords` | `5` |
| `OLSummaryIntervalBars` | `10` |

Match report: **YES.**

---

## E. Performance Journal Buffer Review

**PASS WITH NON-BLOCKING OBSERVATION.**

### PJ_AppendLine Flow (performance_journal.mqh:1821–1860)

```
PJ_AppendLine(path, line, immediate=false)
  ├─ PJ_NormalizeJsonLine() → validate + enforce JSONL invariant
  │    FAIL → drop line to ai_journal_rejects.txt, return false (safe)
  ├─ PJ_LineRequiresImmediateFlush(line) → classify critical
  ├─ canBuffer = MT5IO_PJBufferActive() && bufferablePath && !forceImmediate
  ├─ if !canBuffer (critical or IO reduction disabled):
  │    if buffer has pending records: PJ_FlushAllBuffers("critical_preflush")
  │    PJ_WriteLineDirect(path, line) → direct FileOpen/SeekEnd/Write/Close
  └─ if canBuffer:
       PJ_BufferLine(path, line) → enqueue in performance/envelope buffer
```

### Critical-Event Classifier (performance_journal.mqh:1644–1665)

Verified keywords (case-insensitive substring match):

| Keyword | Covers |
|---|---|
| `"RECORD_TYPE":"TRADE` | Trade open, trade close, all TRADE_* record types |
| `"EVENT_FAMILY":"TRADE_LIFECYCLE"` | Trade lifecycle events |
| `RISK_BLOCK` | Risk block events |
| `RUNTIME_RISK` | Runtime risk state |
| `EXECUTION_BLOCK` | Execution block events |
| `EXECUTION_OPEN_FAILED` | Execution failure markers |
| `GUARDRAIL` | All guardrail events |
| `TRUTH_NOT_READY` | Truth-not-ready state |
| `ACTIVE_PLAN_MISSING` | Active plan missing |
| `ABNORMAL` | Abnormal state |
| `ROLLBACK` | Rollback/recovery events |
| `AUTHORITY_TRANSITION` | Authority transition |
| `COHORT_TRANSITION` | Cohort transition |
| `RISK_ENVELOPE_TRANSITION` | Risk envelope transition |
| `FILEOPEN_FAILURE` | FileOpen failure markers |
| `FILEWRITE_FAILURE` | FileWrite failure markers |

All required critical event types are covered. Classifier matches on the full JSON line (case-insensitive) after normalization. See non-blocking observation in Section N.C1.

### Bufferable Paths

`PJ_IsIOReductionBufferablePath` (line 1632–1637) permits buffering only for:
- `AI\ai_performance_journal.jsonl`
- `AI\ai_decision_envelope_trace.jsonl`

All other PJ paths bypass buffering and use direct write. Correct and minimal.

### Buffer Capacity

- `g_PJ_PerformanceBuffer[MT5_IO_PJ_BUFFER_CAPACITY]` — static array, size `200` (hard cap in mt5_io_reduction_v1.mqh:12)
- Effective capacity = `PJBufferMaxRecords` clamped to `[1, 200]`; default 20
- Two independent buffers: performance journal and envelope trace
- On buffer full: flush then retry buffer; if flush fails: direct write (safe fallback at lines 1797–1798, 1807–1808)

### Batch Flush

`PJ_WriteBatchDirect` (line 1706–1748) opens file **once**, writes all buffered records in insertion order, calls `FileFlush`, closes. This is the core IO reduction mechanism. Correct and safe.

### Flush Events

| Trigger | Location | Verified |
|---|---|---|
| Buffer full | performance_journal.mqh:1795–1798 | ✓ |
| Periodic M1 bar interval | main_ea.mq5:13808 → `PJ_FlushOnM1Bar` | ✓ |
| Critical record arrives | performance_journal.mqh:1853–1854 | ✓ |
| OnDeinit | main_ea.mq5:13655 | ✓ |

Order confirmed: OnDeinit calls `PJ_FlushAllBuffers("on_deinit")` **before** `SaveRuntimeGovernanceStatusBestEffort` and `SaveMT5IOReductionStatusBestEffort` — correct.

---

## F. Runtime Governance Dirty-Flag Review

**PASS — VERIFIED AT SOURCE.**

### Dirty Key Construction (main_ea.mq5:5946–5974)

Source comment at line 5948–5950 explicitly states: *"Deliberately excludes evaluated_at/current timestamp so stable state can be heartbeat-refreshed without defeating dirty-flag suppression."*

Dirty key fields confirmed (line 5951–5973):

| Field | Included in Key |
|---|---|
| `governance_state` | ✓ |
| `trading_allowed` | ✓ |
| `degraded_mode` | ✓ |
| `truth_ready` | ✓ |
| `diagnostics_ready` | ✓ |
| `rollback_recently_applied` | ✓ |
| `reason_code` | ✓ |
| `active_plan_id` | ✓ |
| `active_mode` | ✓ |
| `operating_risk_envelope_state` | ✓ |
| `current_guardrail_block_reason_code` | ✓ |
| `current_guardrail_owner` | ✓ |
| `execution_authority_source` | ✓ |
| `execution_authority_cutover_state` | ✓ |
| `active_operating_cohort_id` | ✓ |
| `active_operating_candidate_count` | ✓ |
| `execution_allowed_only_through_active_operating_cohort` | ✓ |
| `evaluated_at` | **EXCLUDED** (correct) |
| current timestamp | **EXCLUDED** (correct) |

### Startup Write

`gLastSavedGovernanceStateKey = ""` (line 316) — first call computes key ≠ "" → dirty=true → write always happens on EA init regardless of IO reduction flags. Correct.

### Heartbeat

`gLastRuntimeGovernanceStatusWrite = 0` (line 317) — on first call `<= 0` → heartbeat=true → write always happens. After that: write when `(now - last) >= RuntimeGovernanceHeartbeatSeconds` (default 300s). Stable state is never silent for more than 300 seconds.

### Immediate-Write Override

`RuntimeGovernanceRequiresImmediateStatusWrite` (line 5976–5987) forces write on:
- `governance_state == "TRUTH_NOT_READY"` ✓
- `governance_state == "ROLLBACK_RECOVERED"` ✓
- `reason_code` contains `ABNORMAL`, `GUARDRAIL`, `EXECUTION`, or `RISK` (case-insensitive) ✓

Note: Any state transition (dirty=true) also forces a write regardless of this function, so `RequiresImmediateStatusWrite` is an additional guard for cases where state didn't technically change but the situation still demands a write.

### OnDeinit

`SaveRuntimeGovernanceStatusBestEffort(gRuntimeGovernance, true)` at line 13656 — force=true, writes unconditionally. Confirmed.

---

## G. Opportunity Ledger Safety

**PASS — VERIFIED AT SOURCE.**

### OL_WriteRecord (council_mode_runtime.mqh:1838–1859)

Direct write path confirmed — no rate limiting applied:

```mql5
int h = FileOpen(filePath, FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI);
// ... FileSeek(SEEK_END) → FileWriteString → FileFlush → FileClose
```

`OL_WriteRecord` does not reference `EnableOLSummaryRateLimit`, `EnableMT5IOReductionV1`, or any IO reduction counter. It is unchanged from pre-Package2 behavior.

### Rate Limit Scope

Rate limiting (at council_mode_runtime.mqh:2445–2482) applies **only to `OL_SaveSummary`** (which writes `ai_opportunity_summary.json` — a derived report). The JSONL trigger/event records in `ai_opportunity_ledger.jsonl` are unaffected.

### Schema

`OL_WriteRecord` body was not modified. The schema version `OL_V1C_IRREW_DEV_V1` present in `SaveOpportunitySummary` (line 1871) is unchanged from prior implementation. No JSON parse-risk introduced.

### Deferred Counter Visibility

`g_mt5io_ol_summary_deferred_count` is written to `mt5_io_reduction_status.json` — operator can observe whether summary is being deferred and by how much.

---

## H. Trend-Continuation Status Gate Review

**PASS — VERIFIED AT SOURCE.**

### Implementation (council_mode_runtime.mqh:160–192)

```mql5
void SaveTrendContinuationReinforcementStatusBestEffort(...)
{
   int currentBar = Bars(_Symbol, PERIOD_M1);
   bool gateActive = (EnableMT5IOReductionV1 && EnableTrendContGate);
   if(gateActive && g_mt5io_trendcont_last_write_bar >= 0)
   {
      int interval = MT5IO_TrendContStatusIntervalBars();
      if((currentBar - g_mt5io_trendcont_last_write_bar) < interval)
      { g_mt5io_trendcont_deferred_count++; return; }
   }
   // ... write txt + json files ...
   g_mt5io_trendcont_last_write_bar = currentBar;
   g_mt5io_trendcont_write_count++;
}
```

### Startup Behavior

`g_mt5io_trendcont_last_write_bar = -100000` (line 28) — on first call: `-100000 >= 0` is false → gate not applied → write always happens on first call. Correct.

### Legacy Fallback

When `EnableMT5IOReductionV1=false` or `EnableTrendContGate=false`: `gateActive=false` → condition `gateActive && last_bar >= 0` fails → write every call. Legacy behavior restored. Correct.

### Strategy Logic

`SaveTrendContinuationReinforcementStatusBestEffort` only writes status files (`council_trend_cont_confirmation_status.txt/json`). No change to `EvaluateTrendContinuationConfirmationReinforcement` logic, council pipeline, or any decision path.

---

## I. mt5_io_reduction_status.json Review

**PASS — VERIFIED AT SOURCE.**

### Self-Declared Role (main_ea.mq5:1957–1959)

```
"schema_version": "MT5_IO_REDUCTION_STATUS_V1"
"artifact_role":  "OBSERVABILITY_ONLY_NON_AUTHORITATIVE"
```

### Content

Contains only:
- Feature flag states (enabled/disabled booleans)
- Counter values (buffered_records_total, flushed_records_total, deferred counts)
- Configuration values (heartbeat_seconds, flush_interval_bars)
- Crash-loss policy scope declaration
- `authority_impact: "NONE"`, `trading_behavior_impact: "NONE"`, `production_ready: "false"`

Contains **no** trading decisions, strategy weights, council votes, risk policy, execution history, positions, or runtime authority values.

### Write Path

Written by `SaveMT5IOReductionStatusBestEffort` (main_ea.mq5:2000–2007) via `WriteTextFileAll` — same write utility used for other observability files. Rate-limited to 60s (except force=true on startup and deinit). Write failure is silent-best-effort (does not affect trading).

### Not Consumed by Trading Logic

Static search confirmed zero references to `MT5IOReductionStatusJsonPath()` or `MT5_IO_REDUCTION_STATUS_PATH` in any strategy, council, risk, or execution file.

---

## J. Crash-Loss / Recovery Policy

**PASS — DOCUMENTED LIMITATION ACCEPTED.**

### Crash-Loss Scope

| Category | Crash Behavior |
|---|---|
| Non-critical telemetry (DECISION, COUNCIL_ATTRIBUTION, SHADOW, envelope trace) | May lose up to `PJBufferMaxRecords` (default 20) records in hard crash |
| Critical records (TRADE_*, RISK_BLOCK, GUARDRAIL, TRUTH_NOT_READY, ROLLBACK, etc.) | **Immediate** — never only buffered |
| Governance status | **Forced write** on state change; heartbeat every 300s |
| OL trigger/event JSONL | **Immediate** — unchanged behavior |
| OL summary | Rate-limited derived report only; staleness is observable |

### Maximum Loss Window

- Records: PJBufferMaxRecords = 20 (non-critical telemetry only)
- Time: PJFlushIntervalBars × M1 interval = up to 5 minutes of non-critical telemetry

### Planned Shutdown

`OnDeinit` at line 13652–13661:
```mql5
EventKillTimer();
PJ_FlushAllBuffers("on_deinit");       // all non-critical records written
SaveRuntimeGovernanceStatusBestEffort(gRuntimeGovernance, true); // governance status
SaveMT5IOReductionStatusBestEffort("on_deinit", true);           // IO status
```
Ordered correctly. Planned shutdown (EA removal, terminal restart) flushes all buffers. ✓

### Hard Crash

If MT5 process is killed without OnDeinit: up to 20 non-critical telemetry records may be lost. This is the documented and accepted limitation of RAM buffering. No critical trading evidence is at risk.

---

## K. Compile / Binary Verification

**PASS.**

| Item | Value | Status |
|---|---|---|
| Compile log | `compile_mt5_io_reduction_v1_package2_20260510_211952.log` | Verified |
| Errors | `0 errors` | ✓ |
| Warnings | `0 warnings` | ✓ |
| MetaEditor exit code | `1` | Known MetaEditor behavior (consistent with all prior clean compilations in this codebase) |
| Binary timestamp | `2026-05-10 21:24:19` | ✓ Matches report |
| Binary size | `2,720,620` bytes | Consistent with a major EA |
| Compile log format | UTF-16LE (standard MetaEditor output) | ✓ |
| Includes verified | `mt5_io_reduction_v1.mqh` confirmed in compile log line 10 | ✓ |

Prior compile logs for this EA all have MetaEditor exit code 1. This is a known terminal behavior — the compiler log content is the authoritative indicator, not the process exit code.

---

## L. Static Regression Checks

**PASS — ZERO REGRESSIONS FOUND.**

| Regression Check | Result |
|---|---|
| Score authority regression | None — IO flags absent from council_strategies, aggregator, core_trade_engine |
| `playbook_score` new usage | None |
| `completion_percentage` new usage | None |
| `council_quality` bonus change | None |
| HIGH_CONVICTION change | None |
| CRR change | None |
| DSN change | None |
| DQ hard-lock change | None |
| IMBALANCE_FILL_REVERSAL cohort promotion | None |
| IO counters consumed by trading logic | None |
| IO flags in council_pre_ai_filter.mqh | Not checked (file predates backup; no modification) |
| `PJ_FlushAllBuffers` wired to OnDeinit | CONFIRMED at main_ea.mq5:13655 |
| `PJ_FlushOnM1Bar` wired to M1 bar handler | CONFIRMED at main_ea.mq5:13808 |
| `gLastSavedGovernanceStateKey` initialized to `""` | CONFIRMED at main_ea.mq5:316 |
| `gLastRuntimeGovernanceStatusWrite` initialized to `0` | CONFIRMED at main_ea.mq5:317 |

---

## M. Blocking Findings

**NONE.**

No blocking findings were identified during forensic review. The implementation is source-safe for reload.

---

## N. Non-Blocking Caveats

### C1 — Critical-Event Classifier Is Substring-Based

`PJ_LineRequiresImmediateFlush` (performance_journal.mqh:1644–1665) matches keywords as substrings across the full normalized JSON line (case-insensitive). The concern is **false negatives** (a critical event not recognized → buffered).

Analysis: All required critical event types are covered by the current keyword list. However, if a future new record type introduces a novel critical event label not in this list, it would be buffered until the next interval flush. No false negative identified in current record types.

False positives (non-critical record matching a keyword → immediate flush) are safe — they only reduce IO reduction benefit. Example: a DECISION record containing `"risk_context":"no_active_risk_block"` would match `RISK_BLOCK` and flush immediately. This is overly conservative but safe.

**Mitigation:** The keyword list is comprehensive for all known record types. Future new critical record types should be added to the classifier.

### C2 — Periodic Flush Uses Modulo on gM1BarCounter

`PJ_FlushOnM1Bar` (line 1862–1871) flushes when `(gM1BarCounter % interval) == 0`. `gM1BarCounter` starts at 0 and increments by 1 each M1 bar (main_ea.mq5:13807). Bar 0 would flush immediately. At default interval=5, flush occurs at bars 0, 5, 10, 15... Maximum non-critical buffer age: 4 M1 bars (approximately 4 minutes during market hours). Acceptable.

### C3 — PJ_FileEndsWithNewline Adds One Extra FileOpen Per Direct Write

`PJ_WriteLineDirect` and `PJ_WriteBatchDirect` both call `PJ_FileEndsWithNewline` before the actual write FileOpen. This read-only check (opens in `FILE_BIN`, reads last byte) adds 1 FileOpen per direct write operation. For critical records (direct-write), this means 2 FileOpens per record instead of 1. Critical records are rare events; this does not meaningfully affect IO pressure and is not a safety concern.

### C4 — Governance Heartbeat Default 300s

At `RuntimeGovernanceHeartbeatSeconds=300` (default), stable governance status is not re-written to disk for up to 5 minutes. If the status file is deleted or corrupted during a stable-governance window, the dashboard will show stale status for up to 5 minutes. This is a dashboard experience issue, not a safety concern — trading decisions do not read the governance status file. The 300s default can be reduced by the operator if faster refresh is needed.

### C5 — ai_decision_envelope_trace.jsonl Buffering Not Previously Audited

The decision envelope trace file is buffered alongside the performance journal. This file is OBSERVABILITY_HEAVY (trace data for forensic analysis). The buffering is correct per the file's classification. This file was not previously the subject of a standalone audit; the buffering is equivalent in safety to the performance journal buffering.

### C6 — PJ_NormalizeJsonLine Quote-Balance Heuristic

The JSON validation at line 1549–1593 checks `{...}` framing and balanced quotes (ignoring escapes). It is not a full JSON parser. A malformed record with balanced but misplaced quotes would pass validation, be buffered/written, and could cause downstream analysis tool parse errors. This is not a runtime trading risk — malformed records are written to `ai_journal_rejects.txt` if they fail. The consequence is loss of that observability record, not a trading or authority defect.

### C7 — SaveMT5IOReductionStatusBestEffort 60s Rate Limit (Non-Force Calls)

The IO status file (`mt5_io_reduction_status.json`) has a 60-second rate limit for non-forced writes. Startup (`ea_startup`, force=true) and deinit (`on_deinit`, force=true) write immediately. The per-bar heartbeat (`m1_bar_heartbeat`, force=false) is subject to the 60s limit. During the first 60 seconds, the operator observing the status file will see the ea_startup snapshot. This is correct behavior — counters naturally start low and grow. Not a safety concern.

---

## O. Reload Recommendation

**`PASS_RELOAD_ALLOWED_WITH_CAVEATS`**

The package is safe to reload with `EnableMT5IOReductionV1=true` and all component flags at defaults.

If the operator wants to validate trading behavior before enabling IO reduction:
1. Reload with `EnableMT5IOReductionV1=false` → observe 1–2 sessions → confirm identical decisions
2. Re-enable with `EnableMT5IOReductionV1=true`

This two-step approach is available but not required — source inspection confirms no trading path was changed.

---

## P. Required Runtime Validation Checklist

After reload, validate the following in the first session:

| # | Check | Method |
|---|---|---|
| 1 | Binary timestamp is `2026-05-10 21:24:19` or later | Check `main_ea.ex5` properties in MT5 |
| 2 | EA initializes with `EnableMT5IOReductionV1=true` visible in Experts log | MT5 Experts log |
| 3 | `AI\mt5_io_reduction_status.json` is created | Check file exists in `MQL5/Files/AI/` |
| 4 | `buffered_records_total` counter increases over time | Monitor status JSON |
| 5 | `batched_flush_count` increases | Monitor status JSON |
| 6 | `flushed_records_total` approaches `buffered_records_total` | Monitor status JSON |
| 7 | Trade open/close records appear in `ai_performance_journal.jsonl` immediately at trade events | Monitor JSONL |
| 8 | `ai_opportunity_ledger.jsonl` trigger/event records appear immediately | Monitor JSONL |
| 9 | `ai_opportunity_summary.json` updates less frequently than JSONL records | Compare file mtimes |
| 10 | `runtime_governance_status.json` last_updated advances at ≤300s intervals during stable operation | Monitor file |
| 11 | No FileOpen/FileWrite error messages in MT5 Experts log | MT5 Experts log |
| 12 | No JSON/JSONL parse errors in dashboard | External dashboard |
| 13 | `EnableMT5IOReductionV1=false` removes `pj_buffer_enabled` field from status → direct writes only | Test in Strategy Tester |
| 14 | No abnormal EA termination in first session | MT5 Experts log |
| 15 | Production Ready status remains FALSE | Confirm no claim |

---

## Q. What Must Not Be Concluded

- This review does NOT confirm runtime load reduction numbers — expected 60–73% FileOpen/Close reduction requires live counters, not static review.
- This review does NOT confirm critical-event classifier completeness for future record types not yet implemented.
- **Do NOT claim Production Ready** based on this review. System status remains DEVELOPING. Runtime validation per Section P checklist is required before runtime evidence can be assessed.
- **Do NOT promote any strategy, expand RCEM, or change IRREW flags** as part of or following this reload. This package only changes IO timing — not trading architecture.
- This review does NOT replace the XAUUSD live attach validation required by prior validation documents.

---

## R. Final Decision

```
PACKAGE3_VERDICT:             PASS_RELOAD_ALLOWED_WITH_CAVEATS
BLOCKING_FINDINGS:            NONE
NON_BLOCKING_CAVEATS:         7 (C1-C7) — all observational, none safety-critical
TRADING_AUTHORITY_UNCHANGED:  CONFIRMED — source-verified
CRITICAL_EVIDENCE_IMMEDIATE:  CONFIRMED — source-verified at PJ classifier + OL_WriteRecord
SCOPE_CLEAN:                  CONFIRMED — 0 unexpected source files modified
ONDEINIT_FLUSH_WIRED:         CONFIRMED — main_ea.mq5:13655
FEATURE_FLAG_ROLLBACK:        CONFIRMED — EnableMT5IOReductionV1=false restores direct-write
IO_COUNTERS_DIAGNOSTIC_ONLY:  CONFIRMED — not read by any trading logic
RUNTIME_JSON_UNMODIFIED:      CONFIRMED — backup timestamp scan + report attestation
RUNTIME_VALIDATION_REQUIRED:  YES — per Section P checklist
PRODUCTION_READY:             FALSE — no claim
SOURCE_CHANGED_THIS_REVIEW:   NO
COMPILE_RUN:                  NO
LIVE_TRADING:                 NO

REVIEW_DATE:                  2026-05-10
REVIEWER:                     Claude (Package 3 forensic review)
REVIEWED_FILES:               main_ea.mq5, performance_journal.mqh, council_mode_runtime.mqh,
                              mt5_io_reduction_v1.mqh, compile log, implementation report,
                              PIML anchor, DOCS_SYSTEM_INDEX, unapproved file timestamp scan
```

---

*This document is read-only. No source changes, runtime modifications, or production-ready claims were made during this review.*
