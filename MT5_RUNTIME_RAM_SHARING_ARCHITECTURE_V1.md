# MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1

**Document ID:** MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1
**Date:** 2026-05-10
**Package:** Package 1 (Claude architecture/planning output)
**Status:** PACKAGE1_COMPLETE — RAM_SHARING_PACKAGE2_READY

---

## A. Executive Verdict

**`RAM_SHARING_PACKAGE2_READY`**

Source-level IO reduction is achievable, safe, rollback-able, and fully specifiable for a single Codex implementation package. The primary bottleneck is **MT5's own file IO write pattern**, not external tool read patterns. The recommended Package 2 architecture is:

**In-EA telemetry buffering + frequency-gated status writes + dirty-flag governance writes**

This architecture:
- Reduces MT5 FileOpen/Close cycles on the 34MB performance journal by ~5×
- Reduces honesty surface write frequency by ~10× (7 files × 10× = ~70 unnecessary writes eliminated per 10-bar window)
- Reduces governance status writes by ~80%+ (dirty-flag: only write when state changes)
- Requires NO external process, NO DLL, NO named pipe, NO RAM disk
- Is fully rollback-able via a single feature flag per component
- Does NOT touch trading logic, V1 gates, risk, execution, stop geometry, or strategy conditions
- Compatible with MT5 Strategy Tester (buffer flushed on OnDeinit which Tester calls on completion)

Expected aggregate reduction: **5–10× fewer FileOpen/Close cycles per M1 bar**, **50–70% lower total daily IO call count**.

---

## B. Correction of Prior Sidecar Drift

### The problem with the earlier sidecar plan

The Package 1 spec produced as `MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1.md` designed a read-only Python sidecar that caches MT5 outputs in RAM for dashboard consumption.

**That is an external observability acceleration tool, not MT5 runtime IO reduction.**

The sidecar:
- Does NOT reduce how many times MT5 calls `FileOpen()`
- Does NOT reduce how many times MT5 calls `FileSeek()` on the 34MB journal
- Does NOT reduce how many status files MT5 rewrites per bar
- Reduces only the latency at which an external dashboard RE-READS already-written files

The core MT5 IO problem is entirely on the MT5 write side. External tools are consumers of that IO, not the cause.

### Reclassification of the sidecar

The earlier sidecar spec is:
- **Reclassified as SECONDARY** — remains valid as a future optional consumer of reduced/snapshotted output
- **Not the main solution** — does not address the primary IO pressure
- **Can be implemented later** after MT5 IO reduction is live — it would then read less-frequently-written, compactly-snapshotted outputs

The earlier `MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1.md` remains as a valid future secondary package but must not be treated as resolving the primary problem.

---

## C. Current MT5 File IO Producer Inventory

Source scan confirmed **160 FileOpen/FileWrite/FileClose calls across 23 .mqh files + 19 in main_ea.mq5 = 179 total**.

### Top-level write function taxonomy

| Function | Module | Signature pattern | Files written |
|---|---|---|---|
| `PJ_AppendJsonLine()` | performance_journal.mqh | `FileOpen → FileSeek(SEEK_END) → FileWriteString → FileClose` | ai_performance_journal.jsonl, ai_decision_envelope_trace.jsonl |
| `PJ_AppendLine()` | performance_journal.mqh | Same pattern + JSON validation | ai_performance_journal.jsonl |
| `PJ_WriteJsonTextFile()` | performance_journal.mqh | `FileOpen(WRITE) → FileWriteString → FileClose` | ai_decision_envelope_observability_status.json, ai_trade_evidence_completeness_status.json |
| `RuntimeHonestyWriteTextFileAll()` | runtime_honesty_surfaces.mqh | `FileOpen(WRITE) → FileWriteString → FileClose` | 7 honesty/config surfaces |
| `RuntimeHonestyEmitSurfacesBestEffort()` | runtime_honesty_surfaces.mqh | Calls 5 sub-writers | runtime_honesty_truth.json, operator_input_truth_map.json, threshold_ownership_registry.json, operator_effective_configuration_surface.json, runtime_honesty_note.txt, operator_effective_configuration_note.txt, operator_runtime_truth_note.txt |
| `WriteTextFileAll()` | main_ea.mq5 | `FileOpen(WRITE) → FileWriteString → FileClose` | All status/governance surfaces |
| `SaveRuntimeGovernanceStatusBestEffort()` | main_ea.mq5 | Calls `WriteTextFileAll` × 2 | runtime_governance_status.json, runtime_governance_status.txt |
| `BuildTrendContinuationStatusReport()` | council_mode_runtime.mqh | `FileOpen × 2 → Write × 2 → Close × 2` | council_trend_cont_confirmation_status.json/txt |
| `OL_WriteRecord()` | council_mode_runtime.mqh | `FileOpen(READ\|WRITE) → FileSeek(SEEK_END) → FileWriteString → FileFlush → FileClose` | ai_opportunity_ledger.jsonl |
| `OL_SaveSummary()` | council_mode_runtime.mqh | `FileOpen(WRITE) → FileWriteString → FileFlush → FileClose` | ai_opportunity_summary.json |
| `AppendCouncilFeedbackJsonObject()` | council_feedback.mqh | Binary-mode `FileOpen → FileSeek → Write → Close` | council_feedback.json |
| `ILV1_AppendLine()` / `ILV1_WriteText()` | institutional_learning_layer_v1.mqh | Append + overwrite patterns | ai_institutional_learning_*.jsonl/json |

### Write trigger taxonomy

| Trigger | Frequency | Files affected | Approx FileOpen calls/day |
|---|---|---|---|
| Every M1 bar (is_new_m1_bar) | 1440/day | perf_journal (2-3 calls), honesty (7 calls), governance (2 calls), trendcont (2 calls) | **~20,000** |
| Every decision cycle (M1 bar-gated council evaluation) | ~800-1440/day | perf_journal (council_attribution), OL_WriteRecord | **~2,000** |
| Trade open | ~1-10/day | perf_journal (trade_open record), OL_WriteRecord | ~10-20 |
| Trade close | ~1-10/day | perf_journal (trade close, attribution), council_feedback, trade_feedback, learning_events, learning_memory | ~10-30 |
| OL periodic flush | Per trigger (~1-20/day) | ai_opportunity_summary.json | ~5-20 |
| Startup / OnInit | 1/session | Honesty surfaces (initial emit), governance initial write | ~15 |
| OnDeinit | 1/session | All flush paths | ~30 |
| Timer (OnTimer, dashboard refresh) | Every 10-30s | ATAS status files only | ~300/day |

**Total estimated FileOpen/Close cycles per trading day: ~22,000–25,000**

### The single largest IO burden

`ai_performance_journal.jsonl` currently at **34MB** and growing. Every M1 bar triggers **2-3 `FileOpen → FileSeek(0, SEEK_END) → FileWriteString → FileClose`** cycles on this file. FileSeek to end of a 34MB file on every write is significant IO overhead even on SSD. In one trading day: ~3,000-4,000 seek-to-end operations on a growing 34MB file.

---

## D. Runtime File Categories

### Classification

| File / Pattern | Category | Authority | Crash-loss acceptable? | Max staleness OK? |
|---|---|---|---|---|
| `ai_performance_journal.jsonl` | AUDIT_CRITICAL + OBSERVABILITY_HEAVY | MT5-owned | 1 record OK; never entire session | 0s for trade events; 5 bars for decisions |
| `ai_opportunity_ledger.jsonl` | AUDIT_CRITICAL | MT5-owned | Never | 0s for trigger events |
| `ai_opportunity_summary.json` | OBSERVABILITY_HEAVY | MT5-owned | Yes (can regenerate) | 5 bars |
| `ai_decision_envelope_trace.jsonl` | OBSERVABILITY_HEAVY | MT5-owned | Yes | 5 bars |
| `ai_decision_envelope_observability_status.json` | DASHBOARD_ONLY | MT5-generated | Yes | 10 bars |
| `ai_trade_evidence_completeness_status.json` | DASHBOARD_ONLY | MT5-generated | Yes | 1 trade cycle |
| `runtime_governance_status.json/.txt` | AUTHORITY_CRITICAL | MT5-owned | No | 0s (must write on state change) |
| `execution_authority_status.json/.txt` | AUTHORITY_CRITICAL | MT5-owned | No | 0s |
| `active_operating_cohort.json/.txt` | AUTHORITY_CRITICAL | MT5-owned | No | 0s |
| `operating_risk_envelope_status.json/.txt` | RECOVERY_CRITICAL | MT5-owned | No | 0s |
| `risk_safety_status.json/.txt` | RECOVERY_CRITICAL | MT5-owned | No | 0s |
| `runtime_honesty_truth.json` | OBSERVABILITY_HEAVY | MT5-generated (config snapshot) | Yes | 10 bars (static config rarely changes) |
| `operator_input_truth_map.json` | OBSERVABILITY_HEAVY | MT5-generated (config snapshot) | Yes | 10 bars |
| `threshold_ownership_registry.json` | OBSERVABILITY_HEAVY | MT5-generated (config snapshot) | Yes | 10 bars |
| `operator_effective_configuration_surface.json` | OBSERVABILITY_HEAVY | MT5-generated (config snapshot) | Yes | 10 bars |
| `operator_effective_configuration_note.txt` | DASHBOARD_ONLY | MT5-generated | Yes | 10 bars |
| `operator_runtime_truth_note.txt` | DASHBOARD_ONLY | MT5-generated | Yes | 10 bars |
| `runtime_honesty_note.txt` | DASHBOARD_ONLY | MT5-generated | Yes | 10 bars |
| `council_trend_cont_confirmation_status.json/.txt` | OBSERVABILITY_HEAVY | MT5-generated | Yes | 5 bars |
| `council_audit_summary.json/.txt` | DERIVED_REPORT | MT5-generated | Yes | Per-session |
| `council_report.txt` | DERIVED_REPORT | MT5-generated | Yes | Per-session |
| `council_feedback.json` | AUDIT_CRITICAL | MT5-owned | 1 record OK | 0s for record appends |
| `ai_trade_feedback.json` | AUDIT_CRITICAL | MT5-owned | Never | 0s |
| `ai_strategy_memory_events.jsonl` | AUDIT_CRITICAL | MT5-owned | 1 record OK | 0s |
| `ai_institutional_learning_memory.json` | RECOVERY_CRITICAL | MT5-owned | Yes (rebuilt from events) | Per-session |
| `ai_institutional_learning_*.jsonl` | AUDIT_CRITICAL | MT5-owned | 1 record OK | 0s |
| `ai_institutional_learning_status.json/.txt` | OBSERVABILITY_HEAVY | MT5-generated | Yes | 5 bars |
| `ai_institutional_learning_lineage_status.json` | OBSERVABILITY_HEAVY | MT5-generated | Yes | 5 bars |
| `last_meaningful_runtime_event.json/.txt` | OBSERVABILITY_HEAVY | MT5-generated | Yes | 5 bars |
| `diagnostic_runtime_summary.json/.txt` | DERIVED_REPORT | MT5-generated | Yes | Per-session |
| `execution_quality_validation.json/.txt` | DERIVED_REPORT | MT5-generated | Yes | Per-session |
| `replay_validation_summary.json/.txt` | DERIVED_REPORT | MT5-generated | Yes | Per-session |
| `factory_operational_evidence_status.json/.txt` | DERIVED_REPORT | MT5-generated | Yes | Per-session |
| `ai_performance_journal.jsonl` (shadow/comparison records) | OBSERVABILITY_HEAVY | MT5-generated | Yes | 5 bars |
| `ai_governor_state.json` | AUTHORITY_CRITICAL (minimal content) | MT5-owned | No | 0s |
| `ai_rollback_state.json` | RECOVERY_CRITICAL | MT5-owned | No | 0s |

---

## E. File IO Pressure Sources (Ranked)

### Tier 1 — Critical, Must Fix

**E1. Performance Journal Open/Close per append (performance_journal.mqh)**

Every call to `PJ_AppendLine()` or `PJ_AppendJsonLine()` performs:
```
FileOpen(FILE_WRITE|FILE_READ|FILE_TXT|FILE_ANSI)
FileSeek(handle, 0, SEEK_END)   ← seeks to EOF of 34MB file
FileWriteString(handle, json)
FileClose(handle)
```

Triggered per M1 bar: 2-3 times (decision + council_attribution + possibly shadow).
Daily cost: ~3,000-4,000 FileOpen+Seek(EOF on 34MB) cycles.
**Fix: RAM buffer with periodic flush → reduces to 1 open/close per 5 bars.**

**E2. Runtime Honesty Surfaces rewrite per M1 bar (runtime_honesty_surfaces.mqh)**

`RuntimeHonestyEmitSurfacesBestEffort()` called in `OnTick` on every new M1 bar (line 13671 of main_ea.mq5). Writes 7 files per call — all static configuration snapshots that almost never change:
- runtime_honesty_truth.json
- operator_input_truth_map.json
- threshold_ownership_registry.json
- operator_effective_configuration_surface.json
- operator_effective_configuration_note.txt
- operator_runtime_truth_note.txt
- runtime_honesty_note.txt

Daily cost: 7 files × 1440 bars = **10,080 unnecessary file overwrites** (content identical on most bars).
**Fix: Interval gate (every 10 bars) + content hash check → ~1,000 writes/day maximum.**

### Tier 2 — High Impact, Safe to Fix

**E3. Governance status rewrite per governance check (main_ea.mq5)**

`SaveRuntimeGovernanceStatusBestEffort()` called in `IsRuntimeGovernanceAllowed()` — which is called as part of every decision cycle. Also called in `RefreshRuntimeGovernanceAndSafetyStatusBestEffort()` on every M1 bar. Writes runtime_governance_status.json + .txt = 2 files per call.
Daily cost: ~2,880-4,320 writes (per M1 bar + some per-tick calls).
Governance state changes are infrequent. Writing on every check is pure waste when state hasn't changed.
**Fix: Dirty-flag; only write when governance state changes → ~10-20 writes/day on typical session.**

**E4. Council Trend Continuation Status per M1 bar (council_mode_runtime.mqh)**

`BuildTrendContinuationStatusReport()` writes 2 files (json + txt) per M1 bar.
Daily cost: 2,880 writes.
Content likely changes every bar (reflects current trend assessment) — dirty-flag less effective here.
**Fix: Interval gate (every 3-5 bars) → reduces to 576-960 writes/day.**

### Tier 3 — Moderate Impact

**E5. OL_SaveSummary rewrites (council_mode_runtime.mqh)**

`ai_opportunity_summary.json` overwritten on every OL record write or periodic flush. File is 15KB. Each overwrite = FileOpen/FileWriteString/FileClose on a 15KB file.
Daily cost: ~50-200 writes (depends on trigger frequency).
**Fix: Rate-limit to every 5 OL records or every 10 bars minimum.**

**E6. Execution quality / factory status / other derived report rewrites**

Multiple derived report files written periodically. Low frequency relative to Tier 1-2 but aggregate overhead exists.
**Fix: Rate-limit to every 15-30 bars; accept staleness.**

### Tier 4 — Low Impact (per-trade, infrequent)

- Trade feedback / council feedback / learning events: 1-10 times/day — acceptable as-is.
- Learning memory rebuild: once per session — acceptable.
- Audit summary / council report: once per session — acceptable.

---

## F. Architecture Options Analysis

### F1. In-EA RAM Buffering with Periodic Flush — RECOMMENDED

**Description:** Add a global string array buffer for telemetry records. `PJ_AppendLine()` writes to RAM buffer instead of disk. A flush function writes all buffered records to file in one FileOpen/FileClose cycle.

**Flush triggers (immediate, cannot be deferred):**
- TRADE_OPEN event
- TRADE_CLOSE event
- RISK_BLOCK / GUARDRAIL_BLOCK event
- Abnormal state (TRUTH_NOT_READY, governance failure)
- Buffer full (max 20 records)
- OnDeinit

**Flush triggers (periodic):**
- Every 5 M1 bars (configurable via `PJFlushIntervalBars` input, default 5)

**Classification:** SAFE_FOR_PACKAGE2
**Risk:** LOW
**IO Reduction:** 5× fewer FileOpen/Close on performance_journal.jsonl for decision records
**Trading behavior change:** NONE — records are identical, only timing of disk write changes
**Crash loss:** Maximum 5-bar window of telemetry records on hard crash (not trade events — those flush immediately)
**MT5 Tester compatibility:** YES — OnDeinit flushes all pending records at tester end

### F2. Frequency-Gated Honesty Surface Writes — RECOMMENDED

**Description:** Add `g_HonestyBarCount` counter. `RuntimeHonestyEmitSurfacesBestEffort()` checks `(gM1BarCounter % HonestyEmitIntervalBars == 0)` before writing. Write always on startup and OnDeinit.

**Parameters:**
- `HonestyEmitIntervalBars` (input, default 10): write honesty surfaces every N M1 bars
- Force-write on startup: YES
- Force-write on OnDeinit: YES

**Classification:** SAFE_FOR_PACKAGE2
**Risk:** LOW
**IO Reduction:** 10× reduction in honesty surface writes (7 files × 10× = 70× total FileOpen ops)
**Authority impact:** NONE — honesty surfaces are static config snapshots; 10-minute staleness is acceptable
**Dashboard impact:** Honesty surfaces may be up to 10 bars (10 minutes) stale — acceptable for observability-only files

### F3. Governance Status Dirty-Flag Write — RECOMMENDED

**Description:** Add `gLastSavedGovernanceStateKey` string global. In `SaveRuntimeGovernanceStatusBestEffort()`, compute a key from `{state, reason_code, trading_allowed}`. Write only if key != `gLastSavedGovernanceStateKey`.

**Force-write on startup:** YES
**Force-write on state change:** YES (this is the whole point)
**Force-write on OnDeinit:** YES

**Classification:** SAFE_FOR_PACKAGE2
**Risk:** LOW
**IO Reduction:** ~85-95% reduction in governance status writes
**Authority impact:** NONE — governance state is still evaluated every check; only the file write is gated
**Recovery impact:** NONE — on restart, MT5 re-evaluates governance from live state anyway

### F4. Council Status Write Interval Gate — RECOMMENDED (minor)

**Description:** Add `g_TrendContStatusLastWriteBar` integer. `BuildTrendContinuationStatusReport()` only writes if `(gM1BarCounter - g_TrendContStatusLastWriteBar) >= TrendContStatusIntervalBars` (default 5).

**Classification:** SAFE_FOR_PACKAGE2
**Risk:** LOW
**IO Reduction:** 5× reduction in trend_cont_confirmation_status writes (2,880 → ~576 writes/day)

### F5. OL Summary Write Rate Limiting — RECOMMENDED (minor)

**Description:** Track `g_OL_LastSummaryWriteBar`. `OL_SaveSummary()` only writes if enough bars have passed since last write OR on trade events.

**Classification:** SAFE_FOR_PACKAGE2
**Risk:** LOW
**IO Reduction:** Moderate; OL summary writes reduced to ~30-50/day

### F6. Persistent File Handle Cache — DEFERRED

**Description:** Keep the performance journal file handle open as a global. Each `PJ_AppendLine()` just does `FileSeek(SEEK_END) + FileWrite` with no FileOpen/Close overhead.

**Classification:** REQUIRES_RUNTIME_DEBT_LEDGER
**Risk:** MEDIUM
**IO Reduction:** Highest possible for the journal — eliminates FileOpen/Close overhead entirely
**Reason for deferral:** Handle management adds complexity (crash cleanup, tester compatibility, handle limit risks). Implement after F1-F5 are proven safe. F1 already captures most benefit through batching.

### F7. RAM Disk — DEFERRED

**Description:** Install a RAM disk (e.g., ImDisk) and configure MT5 to write to it. All existing code unchanged.

**Classification:** REQUIRES_OPERATOR_DECISION
**Risk:** MEDIUM (power loss = data loss; needs persistence mirror to real disk)
**IO Reduction:** All disk IO becomes RAM writes — eliminates disk latency entirely
**Reason for deferral:** External tool dependency; operator setup required; persistence risk. Evaluate after source-level reduction is baseline-measured.

### F8. Named Pipe / Local Socket Bridge — REJECTED

**Description:** MT5 sends telemetry to external process via pipe; EXE writes files.

**Classification:** REJECTED
**Risk:** HIGH
**Reason:** MQL5 has no native pipe/socket API. Would require a DLL. Bridge failure = event loss. Event ordering across pipe = complex. Not practical without DLL approval and extensive testing.

### F9. Memory-Mapped File / DLL Shared Memory — REJECTED

**Description:** MT5 writes to shared memory via a DLL; EXE reads from shared memory.

**Classification:** REQUIRES_DLL_OR_TERMINAL_PERMISSION
**Risk:** CRITICAL
**Reason:** Requires DLL permission in terminal settings; DLL approval process; DLL crash = MT5 crash risk. Not appropriate at current architecture stage.

### F10. Status/Report File Reduction — RECOMMENDED (minimal)

**Description:** Identify status files written per-bar but rarely consumed. Gate writes to every N bars or on demand only.

**Classification:** SAFE_FOR_PACKAGE2
**Risk:** LOW
**Examples:** diagnostic_runtime_summary (write once per session or every 30 min), execution_quality_validation (per trade, not per bar), factory_operational_evidence (per factory run, not per bar)

---

## G. Source-of-Truth and Recovery Policy

### G1. What data must remain immediately written by MT5?

| Data class | Immediate write required | Reason |
|---|---|---|
| TRADE_OPEN records (performance journal) | YES | Accountability; trade correlated to decision context |
| TRADE_CLOSE records (performance journal, trade_feedback) | YES | PnL, attribution, learning |
| RISK_BLOCK / GUARDRAIL events | YES | Forensic audit trail |
| TRUTH_NOT_READY / governance failure events | YES | Recovery and diagnosis |
| ai_rollback_state.json | YES | Crash recovery |
| ai_current_plan.json (when plan changes) | YES | Plan authority surface |
| Operating cohort changes | YES | Authority boundary |
| Execution authority changes | YES | Authority boundary |
| Risk envelope changes | YES | Protection boundary |

### G2. What data can be buffered (delay up to 5 M1 bars)?

| Data class | Bufferable | Max buffer window | Flush trigger |
|---|---|---|---|
| DECISION records (no trade taken) | YES | 5 M1 bars | Trade event, risk block, OnDeinit |
| COUNCIL_ATTRIBUTION records | YES | 5 M1 bars | Trade event, OnDeinit |
| SHADOW_DECISION records | YES | 10 M1 bars | OnDeinit |
| SHADOW_COMPARISON records | YES | 10 M1 bars | OnDeinit |
| Decision envelope trace | YES | 5 M1 bars | Trade event, OnDeinit |
| OL summary snapshot | YES | 5 M1 bars | Trade event, OL full, OnDeinit |

### G3. What data can be derived later?

| Data class | Derivable | How |
|---|---|---|
| ai_opportunity_summary.json | YES | Regenerate from ai_opportunity_ledger.jsonl |
| ai_institutional_learning_memory.json | YES | Rebuild from ai_institutional_learning_events.jsonl |
| council_audit_summary | YES | Rebuild from performance_journal |
| runtime_honesty_truth.json | YES | Re-emit from live config inputs |
| operator_effective_configuration_surface.json | YES | Re-emit from live inputs |
| threshold_ownership_registry.json | YES | Re-emit from source definitions |
| diagnostic_runtime_summary | YES | Rebuild from journal |

### G4. What data can be lost on crash without trading-safety impact?

| Data class | Safe to lose on crash | Notes |
|---|---|---|
| Non-trade DECISION journal records (buffered) | YES (up to 5-bar window) | Only telemetry; trading decisions not affected |
| Council attribution records (buffered) | YES (up to 5-bar window) | Only attribution; not trading authority |
| Shadow comparison/decision records | YES | Never trading authority |
| Honesty surfaces (up to 10-bar stale) | YES | Config snapshots only |
| Governance status file (dirty-flag gated) | YES | MT5 re-evaluates live state on restart |
| Council trend continuation status | YES | Re-emitted on next bar |

### G5. Maximum crash-loss window

| Record type | Max acceptable loss | Policy |
|---|---|---|
| TRADE_OPEN / TRADE_CLOSE journal records | 0 records | Immediate flush, never buffered |
| RISK_BLOCK events | 0 records | Immediate flush, never buffered |
| DECISION records | Up to 5 M1 bars | Periodic buffer flush |
| COUNCIL_ATTRIBUTION records | Up to 5 M1 bars | Periodic buffer flush |
| Shadow records | Up to 10 M1 bars | Periodic buffer flush |
| OL trigger records | 0 records | OL writes not buffered (already has FileFlush) |

### G6–G13. Event-driven flush policy

| Event | Flush triggered? | Scope |
|---|---|---|
| G6. OnDeinit | YES | ALL buffers, ALL pending writes |
| G7. Trade open | YES | All journal buffers, OL, envelope trace |
| G8. Trade close | YES | All journal buffers, learning events, feedback |
| G9. Guardrail/risk block | YES | All journal buffers |
| G10. TRUTH_NOT_READY / abnormal state | YES | All journal buffers |
| G11. EXE/RAM bridge absent | N/A | No bridge; sidecar is optional consumer |
| G12. EXE crashes | N/A | No bridge; MT5 writes unchanged |
| G13. MT5 restart | Full re-emit of honesty/governance on next bar | Re-evaluation from live state |

---

## H. Recommended Architecture: MT5 IO Reduction V1 — In-EA Buffering + Frequency Gating

### H1. Design Name
`MT5_IO_REDUCTION_V1`

### H2. Core Components

**Component 1: Performance Journal RAM Buffer (PJ_BUFFER)**

Goal: Eliminate per-record FileOpen+Seek(EOF on 34MB)+Close overhead for non-critical telemetry.

```
New globals (performance_journal.mqh):
  string g_PJ_Buffer[20];         // ring buffer, 20 records max
  int g_PJ_BufferCount = 0;
  bool g_PJ_BufferEnabled = false; // controlled by EnablePJBuffer input

New functions:
  bool PJ_BufferLine(const string path, const string line);
  bool PJ_FlushBuffer(const string path);
  bool PJ_IsBufferFull();
  void PJ_FlushAllBuffers();        // called from OnDeinit, trade events

Modified:
  PJ_AppendLine() - when buffer enabled, routes to PJ_BufferLine
  PJ_AppendJsonLine() - same routing

Flush triggers (hard-coded, non-deferrable):
  1. g_PJ_BufferCount >= 20 (buffer full → auto flush)
  2. Trade open/close signal
  3. Risk block / guardrail signal
  4. OnDeinit
  5. Every PJFlushIntervalBars M1 bars (default 5)
```

**Component 2: Honesty Surface Interval Gate (HONESTY_GATE)**

Goal: Eliminate 10,080 identical file overwrites/day for static config surfaces.

```
New global (main_ea.mq5):
  int g_LastHonestyEmitBarCount = -1;

Modified call site (OnTick, line ~13671):
  if(is_new_m1_bar)
  {
    // BEFORE: RuntimeHonestyEmitSurfacesBestEffort(...)
    // AFTER:
    bool honesty_due = (HonestyEmitIntervalBars <= 0)
       || (g_LastHonestyEmitBarCount < 0)
       || ((gM1BarCounter - g_LastHonestyEmitBarCount) >= HonestyEmitIntervalBars);
    if(honesty_due)
    {
       RuntimeHonestyEmitSurfacesBestEffort(...);
       g_LastHonestyEmitBarCount = gM1BarCounter;
    }
  }

New input:
  input int HonestyEmitIntervalBars = 10;  // 0 = every bar (legacy behavior)

Force-emit on:
  - OnInit (g_LastHonestyEmitBarCount = -1 ensures first bar writes)
  - OnDeinit (explicit call regardless of counter)
```

**Component 3: Governance Status Dirty-Flag Gate (GOV_DIRTY)**

Goal: Eliminate per-governance-check file rewrites when state hasn't changed.

```
New globals (main_ea.mq5):
  string g_LastSavedGovernanceStateKey = "";

Modified SaveRuntimeGovernanceStatusBestEffort():
  string currentKey = gRuntimeGovernance.state + "|"
                    + gRuntimeGovernance.reason_code + "|"
                    + string(gRuntimeGovernance.trading_allowed);
  if(currentKey == g_LastSavedGovernanceStateKey && !g_ForceGovernanceWrite)
     return;  // skip: state unchanged
  WriteTextFileAll(RuntimeGovernanceStatusTxtPath(), ...);
  WriteTextFileAll(RuntimeGovernanceStatusJsonPath(), ...);
  g_LastSavedGovernanceStateKey = currentKey;
  g_ForceGovernanceWrite = false;

Force-write triggers:
  - OnInit startup
  - OnDeinit
  - Any state string changes (already handled by key comparison)
```

**Component 4: Council Trend Status Interval Gate (TRENDCONT_GATE)**

Goal: Reduce 2,880 writes/day to ~576 writes/day.

```
New global (council_mode_runtime.mqh):
  int g_LastTrendContStatusWriteBar = -1;

Modified BuildTrendContinuationStatusReport():
  if((gM1BarCounter - g_LastTrendContStatusWriteBar) < TrendContStatusIntervalBars)
     return;
  // ... existing write ...
  g_LastTrendContStatusWriteBar = gM1BarCounter;

New input:
  input int TrendContStatusIntervalBars = 5;  // 0 = every bar (legacy)
```

**Component 5: OL Summary Write Rate Limiter (OL_RATE)**

Goal: Reduce OL summary (ai_opportunity_summary.json) rewrites.

```
New global (council_mode_runtime.mqh):
  int g_LastOLSummaryWriteBar = -1;
  int g_OLRecordsSinceLastSummary = 0;

Modified OL_SaveSummary() call site:
  g_OLRecordsSinceLastSummary++;
  bool summary_due = (g_OLRecordsSinceLastSummary >= OLSummaryWriteEveryNRecords)
                  || ((gM1BarCounter - g_LastOLSummaryWriteBar) >= OLSummaryIntervalBars);
  if(summary_due)
  {
     OL_SaveSummary(...);
     g_LastOLSummaryWriteBar = gM1BarCounter;
     g_OLRecordsSinceLastSummary = 0;
  }

New inputs:
  input int OLSummaryWriteEveryNRecords = 5;  // 0 = on every record (legacy)
  input int OLSummaryIntervalBars = 10;       // 0 = no bar-based rate limit
```

### H3. Feature Flag Architecture

All 5 components are independently controlled by input flags:

```mql5
input bool EnablePJBuffer              = true;   // Component 1: Journal RAM buffer
input int  PJFlushIntervalBars         = 5;      // Component 1: Flush every N M1 bars
input int  PJBufferMaxRecords          = 20;     // Component 1: Max buffer before auto-flush
input bool EnableHonestyIntervalGate   = true;   // Component 2: Honesty surface gate
input int  HonestyEmitIntervalBars     = 10;     // Component 2: Write every N M1 bars
input bool EnableGovernanceDirtyFlag   = true;   // Component 3: Governance dirty-flag
input bool EnableTrendContGate         = true;   // Component 4: TrendCont status gate
input int  TrendContStatusIntervalBars = 5;      // Component 4: Write every N bars
input bool EnableOLSummaryRateLimit    = true;   // Component 5: OL summary rate limit
input int  OLSummaryWriteEveryNRecords = 5;      // Component 5: Write every N OL records
input int  OLSummaryIntervalBars       = 10;     // Component 5: Write every N bars
```

**Default behavior when all inputs are at default values:**
- Legacy behavior fully preserved
- All new flags default to `true` / non-zero = IO reduction active
- Setting `EnablePJBuffer = false` restores exact original behavior for Component 1
- Setting `HonestyEmitIntervalBars = 0` restores per-bar honesty writes
- Setting `EnableGovernanceDirtyFlag = false` restores per-check governance writes

### H4. Files to Modify

| File | Changes | Risk |
|---|---|---|
| `performance_journal.mqh` | Add PJ buffer globals, `PJ_BufferLine()`, `PJ_FlushBuffer()`, `PJ_FlushAllBuffers()`; modify `PJ_AppendLine()` routing | LOW |
| `main_ea.mq5` | Add `HonestyEmitIntervalBars` input, `g_LastHonestyEmitBarCount` global, honesty gate check in OnTick; add `EnableGovernanceDirtyFlag` input, `g_LastSavedGovernanceStateKey` global, dirty-flag check in `SaveRuntimeGovernanceStatusBestEffort()`; call `PJ_FlushAllBuffers()` in `OnDeinit` and trade event handlers; add `PJFlushIntervalBars` check in M1 bar handler | MEDIUM (main_ea.mq5 is large) |
| `council_mode_runtime.mqh` | Add `TrendContStatusIntervalBars` gate in `BuildTrendContinuationStatusReport()`; add OL summary rate limiter globals; add `TrendContStatusIntervalBars` and `OLSummaryIntervalBars` and `OLSummaryWriteEveryNRecords` inputs | LOW |

**Files NOT modified in Package 2:**
- Any other `.mqh` or `.mq5` source (including all strategy, risk, execution, council aggregation, filter, governor logic)
- All JSON/JSONL runtime files
- All governance documents

---

## I. Rejected / Deferred Options

| Option | Status | Reason |
|---|---|---|
| Persistent file handle cache (F6) | DEFERRED | Adds handle lifecycle complexity; deliver after F1-F5 proven |
| RAM disk (F7) | DEFERRED / REQUIRES_OPERATOR_DECISION | External tool; power-loss risk; evaluate after source-level baseline measured |
| Named pipe bridge (F8) | REJECTED | No native MQL5 pipe API; requires DLL |
| DLL shared memory (F9) | REJECTED | REQUIRES_DLL_OR_TERMINAL_PERMISSION; crash risk |
| Read-only external sidecar as primary solution | RECLASSIFIED_SECONDARY | Does not reduce MT5 write IO; deferred as optional consumer of reduced outputs |
| Full-session journal reconstruction | DEFERRED | No benefit while append model is working |

---

## J. Package 2 Implementation Specification

### J1. Objective

Implement MT5_IO_REDUCTION_V1: 5 source changes to `performance_journal.mqh`, `main_ea.mq5`, and `council_mode_runtime.mqh` that reduce MT5 runtime FileOpen/Close cycle count by 5–10× per M1 bar without altering trading logic.

### J2. Files Allowed to Modify

- `performance_journal.mqh`
- `main_ea.mq5`
- `council_mode_runtime.mqh`
- Compile logs (auto-generated)
- Backup files (timestamped, auto-created before each source edit)

### J3. Files Forbidden to Modify

All of the following must not be touched:
- All `.mqh` files except those in J2
- All `.json`, `.jsonl`, `.txt`, `.ini` runtime/config/status/log files
- `PROJECT_INTELLIGENCE_MEMORY_LAYER.md`
- `OPERATION_GUARDRAILS.md`
- `AGENTS.md`
- Any governance document
- `MT5_EXE_MIGRATION_PLAN.md`
- Any file in `DOCS_SYSTEM/`

### J4. Writer Categories (Package 2 scope)

| Writer category | Component | Treatment |
|---|---|---|
| Non-critical telemetry appends (DECISION, ATTRIBUTION, SHADOW) | C1 PJ_BUFFER | Buffer in RAM; flush periodically + on critical events |
| Critical event appends (TRADE_OPEN, TRADE_CLOSE, RISK_BLOCK) | C1 PJ_BUFFER | Always immediate flush; never buffered |
| Static config surface rewrites | C2 HONESTY_GATE | Interval-gated (every 10 bars); force on startup/OnDeinit |
| Governance state rewrites | C3 GOV_DIRTY | Dirty-flag; write only on state change or OnDeinit |
| Council trend status overwrites | C4 TRENDCONT_GATE | Interval-gated (every 5 bars) |
| OL summary overwrites | C5 OL_RATE | Rate-limited by record count and bar count |

### J5. Buffer / Flush Policy

```
Buffer entries: string g_PJ_Buffer[PJBufferMaxRecords]
Buffer count:  int g_PJ_BufferCount = 0

On PJ_AppendLine() call when EnablePJBuffer=true:
  1. Add line to g_PJ_Buffer[g_PJ_BufferCount++]
  2. If g_PJ_BufferCount >= PJBufferMaxRecords → PJ_FlushBuffer() immediately
  3. Return true (write deferred to flush)

On PJ_FlushBuffer():
  1. FileOpen(PERF_JOURNAL_PATH, FILE_WRITE|FILE_READ|FILE_TXT|FILE_ANSI)
  2. FileSeek(0, SEEK_END)
  3. For each line in g_PJ_Buffer[0..g_PJ_BufferCount-1]: FileWriteString(handle, line)
  4. FileClose(handle)
  5. g_PJ_BufferCount = 0
  6. Return success/failure status

Critical-path note: TRADE_OPEN, TRADE_CLOSE, RISK_BLOCK records must NEVER go through the buffer. They must call PJ_AppendLine() with the immediate path (EnablePJBuffer=false context OR via direct PJ_FlushBuffer() after buffering them).
```

Implementation option for critical-event guarantee: Add `bool immediate` parameter to `PJ_AppendLine()`:
```mql5
bool PJ_AppendLine(string path, string line, bool immediate = false)
{
   if(!EnablePJBuffer || immediate)
      return PJ_WriteDirectly(path, line);  // original behavior
   return PJ_BufferLine(path, line);
}
```

### J6. Immediate-Flush Events

The following events MUST trigger `PJ_FlushAllBuffers()` before any return path:
1. `OnDeinit(const int reason)` — all buffers
2. `JournalAppendTradeOpen()` and all `JournalAppendTrade...()` trade record functions — force `immediate=true` or explicit pre-flush
3. Any call path that leads to a RISK_BLOCK/GUARDRAIL_BLOCK journal record
4. Any call path that writes an ABNORMAL_STATE or TRUTH_NOT_READY journal record
5. M1 bar count increments by `PJFlushIntervalBars` (periodic flush in OnTick M1 bar handler)

### J7. Periodic-Flush Events (from OnTick M1 bar handler)

```mql5
if(is_new_m1_bar)
{
   gM1BarCounter++;

   // PJ flush check
   if(EnablePJBuffer && g_PJ_BufferCount > 0 &&
      (gM1BarCounter % PJFlushIntervalBars == 0))
   {
      PJ_FlushBuffer(PERF_JOURNAL_PATH);
   }

   // Honesty gate check
   bool honesty_due = !EnableHonestyIntervalGate
      || (g_LastHonestyEmitBarCount < 0)
      || ((gM1BarCounter - g_LastHonestyEmitBarCount) >= HonestyEmitIntervalBars);
   if(honesty_due)
   {
      RuntimeHonestyEmitSurfacesBestEffort(...);
      g_LastHonestyEmitBarCount = gM1BarCounter;
   }

   // TrendCont gate check
   if(!EnableTrendContGate ||
      (gM1BarCounter - g_LastTrendContStatusWriteBar) >= TrendContStatusIntervalBars)
   {
      BuildTrendContinuationStatusReport(...);
      g_LastTrendContStatusWriteBar = gM1BarCounter;
   }
}
```

### J8. OnDeinit Flush Behavior

```mql5
void OnDeinit(const int reason)
{
   EventKillTimer();

   // --- PACKAGE 2 ADDITION ---
   // Force immediate flush of all pending journal buffers
   PJ_FlushAllBuffers();
   // Force final honesty emit regardless of interval
   RuntimeHonestyEmitSurfacesBestEffort(...);
   g_LastHonestyEmitBarCount = gM1BarCounter;
   // Force final governance write
   g_ForceGovernanceWrite = true;
   SaveRuntimeGovernanceStatusBestEffort(gRuntimeGovernance);
   // --- END ADDITION ---

   // ... existing OnDeinit code ...
}
```

### J9. Crash-Loss Policy

| Scenario | Impact | Policy |
|---|---|---|
| MT5 hard crash (process kill) with 4 buffered decision records | 4 decision telemetry records lost (no trade taken on any) | ACCEPTABLE — no trade accountability impact |
| MT5 hard crash with a trade open and 2 buffered decisions | Trade-open record was immediate-flush; only 2 telemetry records lost | ACCEPTABLE |
| MT5 hard crash during PJ_FlushBuffer() (mid-write) | Partial flush; last record may be truncated | ACCEPTABLE — PJ reader already handles malformed JSON lines (PJ_IsJsonLineProbablyValid) |
| Terminal power loss | All buffered records (up to 20 × 5-bar window) | ACCEPTABLE — historical telemetry only; no live trading authority data |
| Planned MT5 restart / EA remove | OnDeinit called → all buffers flushed before exit | ZERO LOSS |

### J10. Rollback Plan

Each source file gets a timestamped backup before edit.

**To rollback any component:**
1. Individual flag rollback (fastest): Set `EnablePJBuffer=false`, `HonestyEmitIntervalBars=0`, `EnableGovernanceDirtyFlag=false`, `EnableTrendContGate=false`, `EnableOLSummaryRateLimit=false` in EA inputs — restores exact legacy IO behavior without recompile
2. Source rollback: Restore backup files from timestamped `.bak_*` copies; recompile

**Rollback verification:** After rollback, confirm `ai_performance_journal.jsonl` append size per bar returns to pre-Package-2 rate (approximately 2-3 writes per M1 bar on journal).

### J11. Feature Flags Summary

See Section H3 for complete input list. All flags default to IO-reduction-active (true/non-zero). Setting all to legacy values restores exact original behavior.

### J12. Compile Requirements

1. Create timestamped backup of each file before modification
2. Compile `main_ea.mq5` via MetaEditor (requires terminal running)
3. Verify: 0 errors, 0 warnings
4. Binary timestamp must be newer than pre-Package-2 binary
5. Old binary backed up before new binary deployed

### J13. Static Checks (Codex must verify before reporting done)

1. `grep -n "PJ_FlushAllBuffers\|PJ_FlushBuffer" OnDeinit` — must find flush call in OnDeinit
2. `grep -n "immediate.*true" trade_open` — must confirm trade-open path uses immediate=true or pre-flush
3. `grep -n "EnablePJBuffer" performance_journal.mqh` — must find routing check
4. `grep -n "HonestyEmitIntervalBars" main_ea.mq5` — must find gate check in M1 bar handler
5. `grep -n "g_LastSavedGovernanceStateKey" main_ea.mq5` — must find dirty-flag check
6. Verify no modification to: `council_strategies.mqh`, `council_pre_ai_filter.mqh`, `council_aggregator.mqh`, `council_ai_governor.mqh`, `core_trade_engine.mqh`, `decision_mode_router.mqh`

### J14. Runtime Checks

1. After reload, examine Experts log: should NOT see "PJ_AppendLine failed" or "PJ_AppendJsonLine failed"
2. After 10 M1 bars, examine `runtime_honesty_truth.json` mtime — should NOT have been overwritten 10 times
3. After 3 M1 bars, examine `runtime_governance_status.json` mtime — should only change when governance state changes
4. After 1 trade open, examine `ai_performance_journal.jsonl` — must have TRADE_OPEN record within same bar
5. After 20 M1 bars, examine `ai_performance_journal.jsonl` — should have all decision records (buffer never lost them)

### J15. File Integrity Checks

1. `ai_performance_journal.jsonl` after 30 M1 bars: line count should be 30-60 records (2-3 per bar × 30 bars), no gaps
2. All TRADE_OPEN records: must appear in journal within 0 bars of the trade
3. `runtime_governance_status.json` last_modified time: should only change when state changes (test by running 10 bars with no governance state change → file mtime must not advance)

### J16. Evidence that Trading Behavior is Unchanged

1. Compare: council decision output (BUY/SELL/WAIT/REJECT) — must be identical before and after
2. Compare: actual orders placed — must be identical (trading logic not touched)
3. Compare: IRREW flags — all remain false unless explicitly enabled
4. Source diff must show: ZERO changes to `council_strategies.mqh`, `council_pre_ai_filter.mqh`, `council_aggregator.mqh`, `council_ai_governor.mqh`, `core_trade_engine.mqh`, `decision_mode_router.mqh`, `council_mode_types.mqh`, `level_awareness_brake.mqh`

### J17. Evidence that FileOpen/FileWrite Frequency is Reduced

1. Add diagnostic counter (disabled in production mode): `int g_FileOpenCountPerBar` incremented in `PJ_AppendLine()` and `PJ_FlushBuffer()`. Log on every 100 bars: `Print("IO_REDUCTION | files_opened_last_100_bars=", g_FileOpenCountPerBar)`.
2. Expected before: ~13-15 FileOpen calls per M1 bar. Expected after: ~5-7 FileOpen calls per M1 bar (~55% reduction).
3. Add `ai_io_reduction_diagnostics.json` written every 100 bars to `Files/AI/`:
   ```json
   {
     "bars_measured": 100,
     "pj_buffer_flushes": N,
     "pj_direct_writes": N,
     "honesty_writes_deferred": N,
     "governance_writes_deferred": N,
     "trendcont_writes_deferred": N,
     "ol_summary_writes_deferred": N,
     "estimated_fileopen_calls_saved": N
   }
   ```

### J18. Report Requirements

After Package 2 implementation:
1. Package 3 (Claude) reads `ai_io_reduction_diagnostics.json` after 100+ bars to confirm savings
2. Package 3 (Claude) reads `ai_performance_journal.jsonl` to confirm record completeness
3. Package 3 (Claude) confirms all TRADE records are present
4. Package 3 (Claude) verifies no governance document modified
5. Package 3 (Claude) confirms binary timestamp is newer than pre-Package-2 binary

---

## K. Package 2 Codex Execution Brief

### Pre-conditions (Codex must verify)
1. MT5 terminal NOT running (for safe file editing)
2. All 3 target source files readable and writable
3. No open trades (for safe binary replacement)
4. MetaEditor available for compile

### Execution sequence

**STEP K1: Create backups**
- `performance_journal.mqh.bak_<timestamp>`
- `main_ea.mq5.bak_<timestamp>`
- `council_mode_runtime.mqh.bak_<timestamp>`

**STEP K2: Implement Component 1 (PJ Buffer) in performance_journal.mqh**
- Add 12 new input declarations (see Section H3)
- Add globals: `g_PJ_Buffer[20]`, `g_PJ_BufferCount`, `g_PJ_IsCriticalEventContext`
- Add function `PJ_BufferLine(path, line)`
- Add function `PJ_FlushBuffer(path)` — single FileOpen → all buffered lines → FileClose
- Add function `PJ_FlushAllBuffers()` — calls PJ_FlushBuffer for PERF_JOURNAL_PATH and DECISION_ENVELOPE_TRACE_PATH
- Modify `PJ_AppendLine(path, line)` — add routing: `if(EnablePJBuffer && !g_PJ_IsCriticalEventContext) PJ_BufferLine else PJ_WriteDirectly`
- Add `PJ_SetCriticalContext(bool critical)` — sets `g_PJ_IsCriticalEventContext`

**STEP K3: Implement Component 2 (Honesty Gate) in main_ea.mq5**
- Add inputs: `EnableHonestyIntervalGate`, `HonestyEmitIntervalBars`
- Add global: `g_LastHonestyEmitBarCount`
- Modify M1 bar handler in OnTick: wrap `RuntimeHonestyEmitSurfacesBestEffort()` with interval check
- Modify OnDeinit: force-call `RuntimeHonestyEmitSurfacesBestEffort()` before existing exit logic

**STEP K4: Implement Component 3 (Governance Dirty Flag) in main_ea.mq5**
- Add input: `EnableGovernanceDirtyFlag`
- Add globals: `g_LastSavedGovernanceStateKey`, `g_ForceGovernanceWrite`
- Modify `SaveRuntimeGovernanceStatusBestEffort()`: add key-change check
- Modify OnDeinit: set `g_ForceGovernanceWrite = true` before final governance write

**STEP K5: Implement Component 4 (TrendCont Gate) in council_mode_runtime.mqh**
- Add input: `EnableTrendContGate`, `TrendContStatusIntervalBars`
- Add global: `g_LastTrendContStatusWriteBar`
- Modify `BuildTrendContinuationStatusReport()`: add interval check

**STEP K6: Implement Component 5 (OL Summary Rate Limit) in council_mode_runtime.mqh**
- Add inputs: `EnableOLSummaryRateLimit`, `OLSummaryWriteEveryNRecords`, `OLSummaryIntervalBars`
- Add globals: `g_LastOLSummaryWriteBar`, `g_OLRecordsSinceLastSummary`
- Modify OL summary call site: add rate-limit check

**STEP K7: Wire flush calls in main_ea.mq5**
- OnDeinit: call `PJ_FlushAllBuffers()` first
- M1 bar handler: add periodic flush check
- Trade-open and trade-close call sites: call `PJ_SetCriticalContext(true)` before journal append, `PJ_SetCriticalContext(false)` after
- Risk block / guardrail block call sites: same critical context pattern

**STEP K8: Add IO diagnostic counter to main_ea.mq5**
- Add global: `g_IODiagBarCount`, `g_IODiagFileOpenCount`, `g_IODiagSavedCount`
- Every 100 M1 bars: write `ai_io_reduction_diagnostics.json` to Files/AI/
- Disabled when `EnableIODiagnostics = false` (default: true for Package 2 validation window)

**STEP K9: Compile**
- Open MetaEditor
- Open `main_ea.mq5`
- Compile (F7)
- Verify: 0 errors, 0 warnings
- Record binary timestamp

**STEP K10: Static checks**
- Run all grep checks from Section J13
- Verify no forbidden file was modified (Section J3)

**STEP K11: Record results**
- Create `MT5_IO_REDUCTION_V1_IMPLEMENTATION_REPORT.md` in compile_logs/ (or AI root)
- Include: binary timestamp, compile result, backup file names, static check results

---

## L. Package 3 Claude Forensic Review Plan

After Package 2 implementation and minimum 100 M1 bars runtime:

1. Read `ai_io_reduction_diagnostics.json` — confirm `estimated_fileopen_calls_saved > 0`
2. Read `ai_performance_journal.jsonl` last 200 records — confirm all record types present, no corruption
3. Verify `runtime_honesty_truth.json` file mtime — confirm NOT updating every M1 bar
4. Verify `runtime_governance_status.json` file mtime — confirm NOT updating every governance check
5. Verify `ai_opportunity_summary.json` file mtime — confirm rate-limited
6. Git diff all source files — confirm ONLY the 3 target files changed
7. Confirm compile log: 0 errors, 0 warnings
8. Confirm all `AUDIT_CRITICAL` records present in journal (TRADE_OPEN, TRADE_CLOSE, RISK_BLOCK)
9. Read PIML and confirm authority statements unchanged
10. Return verdict: `IO_REDUCTION_V1_CERTIFIED` or `IO_REDUCTION_V1_CONDITIONAL` or `IO_REDUCTION_V1_REJECTED`

---

## M. Measurement Plan

### Baseline (Package 3 reads these before confirming Package 2 is complete)

| Metric | Target value | How to measure |
|---|---|---|
| FileOpen calls per M1 bar | Target ≤7 (from ~14) | `g_IODiagFileOpenCount / g_IODiagBarCount` |
| Journal appends per M1 bar | Target ≤0.5 file ops/bar (buffered) | PJ buffer flush frequency from diagnostics |
| Honesty writes per 100 bars | Target ≤10 (from ~700) | Measure `honesty_writes_deferred` in diagnostics |
| Governance writes per 100 bars | Target ≤5 (from ~300+) | Measure `governance_writes_deferred` |
| TrendCont writes per 100 bars | Target ≤20 (from 200) | Measure `trendcont_writes_deferred` |
| OL summary writes per 100 bars | Target ≤10 (from ~200 if OL active) | Measure `ol_summary_writes_deferred` |
| Performance journal size growth rate | Target ≤40% of pre-Package rate | File size delta per 100 bars |
| Max crash-loss window (telemetry) | Target ≤5 M1 bars | `PJFlushIntervalBars` value |
| Trade event immediate flush | Must be 0 bars (instant) | Verify TRADE_OPEN record in journal same bar as trade |
| Honesty surface staleness | Target ≤10 M1 bars | File mtime minus last bar close |

---

## N. Rollback Plan

### N1. Instant rollback (no recompile needed)

Set all IO reduction inputs to off values in EA settings:
```
EnablePJBuffer              = false
HonestyEmitIntervalBars     = 0
EnableGovernanceDirtyFlag   = false
EnableTrendContGate         = false
EnableOLSummaryRateLimit    = false
```
Reload EA. All IO reduction disabled. Legacy behavior restored.

### N2. Source rollback (full revert)

1. Stop EA / remove from chart
2. Copy backup files over source files:
   - `performance_journal.mqh.bak_<timestamp>` → `performance_journal.mqh`
   - `main_ea.mq5.bak_<timestamp>` → `main_ea.mq5`
   - `council_mode_runtime.mqh.bak_<timestamp>` → `council_mode_runtime.mqh`
3. Compile
4. Verify 0 errors
5. Reload EA

### N3. What rollback does NOT affect

- All existing runtime files (performance_journal, governance status, etc.) are unchanged by rollback
- All PIML, DOCS_SYSTEM, AGENTS.md, OPERATION_GUARDRAILS.md unchanged
- Strategy behavior identical before and after in both directions

---

## O. Risks and Mitigations

| Risk | Severity | Likelihood | Mitigation |
|---|---|---|---|
| Buffer holds TRADE_OPEN record past trade bar | CRITICAL | LOW | Use `immediate=true` / critical context flag for all trade records; buffer bypass for critical events |
| PJ_FlushBuffer() fails (disk full, handle error) | HIGH | LOW | On flush failure: log error, retain buffer (retry next bar), escalate after 3 failures; never silently drop records |
| OnDeinit called before flush completes | MEDIUM | VERY LOW | MQL5 OnDeinit is synchronous; flush is synchronous; cannot be preempted |
| Honesty surface 10-bar staleness misleads operator | LOW | LOW | Add `_last_emit_bar` field to honesty surfaces; operator can see staleness |
| Governance dirty-flag misses a write (hash collision) | VERY LOW | VERY LOW | Key is `state|reason|trading_allowed` — collision probability near zero; OnDeinit always forces write |
| main_ea.mq5 compile error from changes | MEDIUM | LOW | Timestamped backup exists; static checks before compile; use existing global variable patterns from file |
| MT5 Tester: OnDeinit not called on early exit | MEDIUM | VERY LOW | MT5 Strategy Tester does call OnDeinit; confirmed in documentation; flush is correct for tester |
| IO diagnostics file writes add overhead | LOW | LOW | Only writes every 100 bars (1 write/100 bars = negligible); controlled by `EnableIODiagnostics` |

---

## P. Final Recommendation

**Verdict: `RAM_SHARING_PACKAGE2_READY`**

**Recommended package:** MT5_IO_REDUCTION_V1 — 5 components, 3 source files, fully rollback-able.

**Expected IO reduction:**
- Per M1 bar: ~14 FileOpen/Close → ~5-7 (50-65% reduction)
- Honesty surfaces: 10,080 writes/day → ~1,000 writes/day (90% reduction)
- Governance status: ~3,000 writes/day → ~30 writes/day (99% reduction on stable state)
- Total daily FileOpen/Close cycles: ~22,000 → ~6,000-9,000 (60-73% reduction)

**Primary blocker before Package 2:** None. Architecture is fully specified. All decisions pre-made.

**Secondary sidecar package:** The earlier `MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1.md` remains valid as a future optional consumer of the reduced/snapshotted outputs — implement after Package 2 is certified.

**No operator decisions required** for the recommended architecture. Feature flags provide full control.

---

## Q. Footer

```
DOCUMENT_ID:                  MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1
DATE:                         2026-05-10
PACKAGE:                      Package 1 (Claude architecture/planning output)
STATUS:                       PACKAGE1_COMPLETE
FINAL_VERDICT:                RAM_SHARING_PACKAGE2_READY
SIDECAR_RECLASSIFIED:         YES — reclassified as SECONDARY (optional future consumer)
RECOMMENDED_ARCHITECTURE:     MT5_IO_REDUCTION_V1 (in-EA buffering + frequency gating)
PACKAGE2_READINESS:           READY — no operator decisions required
OPERATOR_DECISIONS_REQUIRED:  NONE for recommended package
MAIN_RISKS:                   Buffer bypass for critical events must be correctly implemented
MT5_IO_REDUCTION_EXPECTED:    60-73% fewer FileOpen/Close cycles per M1 bar
FILES_TO_MODIFY:              performance_journal.mqh, main_ea.mq5, council_mode_runtime.mqh
TRADING_LOGIC_CHANGED:        NO — only telemetry write timing and status write frequency
SOURCE_CHANGED_IN_PACKAGE1:   NO
COMPILE_RUN_IN_PACKAGE1:      NO
LIVE_TRADING_IN_PACKAGE1:     NO
MT5_AUTHORITY:                UNCHANGED — MT5 remains sole trading authority
```
