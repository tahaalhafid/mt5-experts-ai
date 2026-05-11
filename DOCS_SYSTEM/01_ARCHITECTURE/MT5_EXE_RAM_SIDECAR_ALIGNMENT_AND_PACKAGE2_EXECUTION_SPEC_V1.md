# MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1

**Document ID:** MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1
**Date:** 2026-05-10
**Package:** Package 1 (Claude planning/spec output)
**Status:** SPEC_COMPLETE — READY_FOR_CODEX_PACKAGE2

---

## A. Authority Statement

This spec does NOT change any authority boundary. MT5 remains the sole runtime, decision, risk, governor, and execution authority. The sidecar is an optional, disposable, read-only observer process. No trade execution, plan mutation, config write, or status file write is approved at any point in this package.

The sidecar is entirely separate from the IRREW development phases and does not affect the Phase 0/1/2/3/4 roadmap.

---

## B. Package Model

```
Package 1 (Claude — this document):
  - Read current workspace state
  - Reconcile with MT5_EXE_MIGRATION_PLAN.md Stages 0–2R.1
  - Answer 15 alignment questions
  - Produce Codex implementation spec (Package 2 brief)
  - Define Package 3 review criteria

Package 2 (Codex — implementation):
  - Implement sidecar per spec below
  - No approval gates mid-task
  - All decisions pre-made in this document
  - Zero trading logic touched
  - Compile/test with existing Python venv

Package 3 (Claude — forensic review):
  - Verify implementation against spec
  - Verify no Files/AI writes occurred
  - Verify authority boundary preserved
  - Certify or flag regressions
```

---

## C. Current System Alignment — 15 Questions Answered

### Q1. What language/runtime for the sidecar?

**Answer: Python 3.x using the existing external_dashboard venv.**

The existing `external_dashboard` already ships a `.venv` with FastAPI, uvicorn, and Jinja2 installed. No new dependencies are required. The sidecar reuses this venv. If the venv is absent, the sidecar falls back to Python stdlib `http.server` with a minimal JSON response handler (no FastAPI required for the sidecar's simple API).

Preferred: FastAPI + uvicorn (from existing venv) on localhost:17001.
Fallback: stdlib `http.server` on same port if FastAPI unavailable.

### Q2. Where in the workspace does the sidecar live?

**Answer: `AI/external_dashboard/sidecar/` (new subdirectory alongside existing `app/`).**

Full path:
```
MQL5/Experts/AI/external_dashboard/sidecar/
  __init__.py
  sidecar.py          # Main FastAPI app
  cache.py            # RAM cache + JSONL tail tracker
  manifest.py         # File classification manifest
  config.json         # Default config (port, TTLs, JSONL tail length)
```

Launch/stop scripts at `external_dashboard/` level:
```
external_dashboard/
  run_sidecar.ps1
  stop_sidecar.ps1
```

### Q3. What are the sidecar's exclusive write paths (separate from Files/AI)?

**Answer: `AI/EXE_RUNTIME_CACHE/` only.**

The sidecar writes ONLY to `EXE_RUNTIME_CACHE/` at the EA root level. This directory is OUTSIDE `MQL5/Files/AI/` — it is completely separate from MT5's write domain.

```
MQL5/Experts/AI/EXE_RUNTIME_CACHE/
  sidecar_status.json       # Health/uptime, cache registry summary
  sidecar_diagnostics.json  # Hit/miss stats, file sizes, staleness
  sidecar.pid               # PID of running sidecar process
```

The sidecar NEVER writes to `MQL5/Files/AI/` or any other MT5-owned path.

### Q4. Which specific files from Files/AI does the sidecar monitor?

**Answer: 3-category manifest. Category D (secrets/write-sensitive) is excluded.**

See Section E for the full file manifest table.

High-level:
- **Category A (cache full, mtime-invalidated):** All status JSONs/TXTs under 100KB. ~30 files.
- **Category B (cache full, mtime-invalidated):** Medium files 100KB–2MB: ai_opportunity_summary.json, ai_strategy_memory.json, ai_institutional_learning_memory.json, etc.
- **Category C (tail only, cursor-based):** Large append-only JSONL: ai_performance_journal.jsonl, council_feedback.json, ai_opportunity_ledger.jsonl, ai_strategy_memory_events.jsonl, ai_decision_envelope_trace.jsonl, ai_institutional_learning_events.jsonl, ai_institutional_learning_trade_lineage.jsonl, ai_institutional_learning_decision_context.jsonl.
- **Category D (excluded — never load):** ai_runtime_secrets.json, ai_current_plan.json (config surface — human-owned, not a status file), ai_previous_plan_backup.json, ai_evolution_state.json.

### Q5. What is the per-file cache strategy?

**Answer:**

| Category | Load strategy | Invalidation | Failure behavior |
|---|---|---|---|
| A — small status | Full load into dict | mtime change | Return `{"_status":"UNAVAILABLE","_reason":"..."}`; never block |
| B — medium | Full load into dict | mtime change | Same as A |
| C — large JSONL | Tail cursor: read new bytes only; keep last `tail_lines` records in circular deque | Always append-aware; re-read only new bytes since last cursor position | Return last known tail; mark `_cursor_stale` if file deleted/truncated |
| D — excluded | Never load | N/A | Return `{"_status":"EXCLUDED","_reason":"SECRET_OR_CONFIG_SURFACE"}` |

JSONL tail default: 500 records. Configurable in `config.json`. The sidecar maintains a byte-offset cursor for each Category C file and reads only new bytes on each poll cycle.

### Q6. What is the file invalidation strategy?

**Answer: Polling, not filesystem events. Poll interval: 2 seconds.**

No `watchdog` or `inotify` dependency. A background thread polls all monitored files every 2 seconds, comparing `st_mtime_ns`. If mtime changed: reload Category A/B; read new bytes for Category C. The poll interval is configurable in `config.json`.

Rationale: MT5 writes files on timer events (typically 1s or 5s bars). A 2s poll interval captures all updates without creating significant CPU load.

### Q7. What is the sidecar's local HTTP API contract?

**Answer:**

Port: `17001` (localhost only). Configurable in `config.json`.

| Endpoint | Method | Returns |
|---|---|---|
| `/health` | GET | `{status, uptime_s, port, cache_entries, files_ai_root, last_poll_ts}` |
| `/cache/{filename}` | GET | Cached content (dict or list); `_status` field on error |
| `/snapshot` | GET | Dict of all Category A+B cached files: `{filename: cached_content, ...}` |
| `/tail/{filename}?lines=N` | GET | Last N records from Category C JSONL (default: 100, max: 500) |
| `/diagnostics` | GET | Per-file: `{filename: {category, size_bytes, mtime_ns, age_seconds, cache_hits, cache_misses, last_load_ts}}` |
| `/manifest` | GET | Complete file manifest with category, status (loaded/excluded/missing), last_mtime |

All responses are JSON. No authentication. Localhost-only binding.

Error responses always use `{"_status": "ERROR|UNAVAILABLE|EXCLUDED", "_reason": "..."}` — never raise HTTP 5xx for file problems, only for sidecar internal failures.

### Q8. How does the existing dashboard integrate with the sidecar?

**Answer: Optional proxy with transparent fallback. Minimal change to `sources.py`.**

Add `SidecarClient` class to `sources.py`. Modify `ArtifactStore.__init__` to accept an optional `sidecar_url: str | None`. If set (via `SIDECAR_URL` env var), the `load_json` and `load_jsonl` methods try the sidecar API first (with 0.1s timeout). On any failure (ConnectionError, timeout, HTTP error): transparently fall back to direct file read.

The existing `main.py` passes `os.getenv("SIDECAR_URL")` to `ArtifactStore`. If the env var is absent, behavior is identical to current. No change to `aggregator.py` or any template.

This means:
- Sidecar running + `SIDECAR_URL=http://localhost:17001` set: dashboard reads from RAM cache
- Sidecar not running or env var absent: dashboard reads directly from disk (current behavior)
- Dashboard never crashes or stalls due to sidecar failure

### Q9. What secrets and write-sensitive files are explicitly excluded?

**Answer (hard exclusions — Codex must verify these are never loaded):**

- `ai_runtime_secrets.json` — secret placeholder; EXCLUDED always
- `ai_current_plan.json` — config surface (human-owned); EXCLUDED from sidecar
- `ai_previous_plan_backup.json` — EXCLUDED
- `ai_evolution_state.json` — contains strict-JSON-invalid content per Stage 1 audit; EXCLUDED
- Any file whose name matches `*secret*`, `*key*`, `*credential*` — excluded by name pattern
- Any file in a path NOT under `MQL5/Files/AI/` except `EXE_RUNTIME_CACHE/`

The manifest.py module must contain an explicit `EXCLUDED_FILES` set checked before any load attempt.

### Q10. What is the startup/shutdown lifecycle?

**Answer:**

**Startup (`run_sidecar.ps1`):**
1. Check if sidecar already running (read `EXE_RUNTIME_CACHE/sidecar.pid`; test process exists)
2. If already running: print status and exit without starting a new instance
3. Activate existing `.venv` at `external_dashboard/.venv`
4. Start `uvicorn external_dashboard.sidecar.sidecar:app --host 127.0.0.1 --port 17001` as background process
5. Write PID to `EXE_RUNTIME_CACHE/sidecar.pid`
6. Wait 2s, hit `/health` to confirm running; print status

**Shutdown (`stop_sidecar.ps1`):**
1. Read PID from `EXE_RUNTIME_CACHE/sidecar.pid`
2. `Stop-Process -Id <PID>` (Windows) with -ErrorAction SilentlyContinue
3. Remove `EXE_RUNTIME_CACHE/sidecar.pid`
4. Print stopped

**On sidecar crash:** `EXE_RUNTIME_CACHE/sidecar.pid` remains with a dead PID. Restart by running `run_sidecar.ps1` again (which detects dead PID and starts fresh).

### Q11. What is the failure behavior when MT5 is not running / sidecar is down?

**Answer:**

- **MT5 not running, sidecar running:** Sidecar serves last cached values. Every response includes `_age_seconds` so dashboard can show staleness. Dashboard continues to work with stale data; must display staleness badge (already implemented in aggregator).
- **Sidecar down, dashboard running:** `ArtifactStore` falls back to direct file reads — existing behavior. No impact to dashboard.
- **Both down:** Dashboard shows UNAVAILABLE for all surfaces — existing behavior.
- **Files/AI directory absent:** Sidecar starts but cache remains empty. `/health` reports `files_ai_root_exists: false`. Dashboard falls back to direct reads.

The sidecar NEVER blocks MT5, the dashboard, or any user operation.

### Q12. What is the authority boundary?

**Answer (absolute constraints for all time):**

The sidecar CANNOT and MUST NOT:
- Place, modify, or cancel trades
- Write to `MQL5/Files/AI/` or any MT5-owned path
- Modify `ai_current_plan.json`, `ai_runtime_secrets.json`, or any config surface
- Emit governance decisions, status verdicts, or execution authority signals
- Be consumed by MT5 EA source (the EA must never reference the sidecar)
- Replace MT5 as source of truth for any decision
- Cache or log secret values from `ai_runtime_secrets.json`
- Be referenced by any `#include` directive in MQL source

The sidecar is invisible to MT5. MT5's behavior is identical whether the sidecar is running or not.

### Q13. What does Package 2 NOT implement?

**Explicit scope exclusions for Package 2:**
- No dashboard UI changes (no new HTML/CSS/JS templates)
- No aggregator.py changes
- No changes to any `.mq5` or `.mqh` source file
- No IRREW flag changes
- No JSON normalization of any runtime file
- No WebSocket or push-based notification (HTTP polling only)
- No Windows service/scheduled task registration
- No changes to `EXE_RUNTIME_CACHE/` outside the three defined files (sidecar_status.json, sidecar_diagnostics.json, sidecar.pid)
- No reading of `ai_current_plan.json`, `ai_runtime_secrets.json`, or any excluded file
- No implementation of the Stage 3X bridge / Stage 3Y developer window / Stage 3Z retirement plan
- No changes to `MT5_EXE_MIGRATION_PLAN.md` (that is Package 1 output only)
- No changes to PIML or any governance document

### Q14. What is the rollback procedure?

**Answer:**

Complete removal:
1. Run `stop_sidecar.ps1` to kill the process
2. Delete `external_dashboard/sidecar/` directory entirely
3. Revert the 2-line change to `sources.py` (remove `SidecarClient` and `SIDECAR_URL` check) — or simply: unset the `SIDECAR_URL` env var, making the fallback path permanent
4. Delete `EXE_RUNTIME_CACHE/`

After rollback: system is identical to pre-Package-2 state. MT5 unaffected throughout.

### Q15. What are the success criteria for Package 3 forensic review?

**Answer:**

Package 3 (Claude forensic review) certifies Package 2 as `SIDECAR_V1_CERTIFIED` only if ALL of the following are confirmed:

1. `sidecar.py` starts without error via `run_sidecar.ps1`
2. `GET /health` returns `status: ok` and correct `files_ai_root`
3. `GET /cache/runtime_governance_status.json` returns a cached dict (not UNAVAILABLE)
4. `GET /tail/ai_performance_journal.jsonl?lines=20` returns ≤20 records without loading the full 34MB file into process memory
5. `GET /cache/ai_runtime_secrets.json` returns `{_status: EXCLUDED, _reason: SECRET_OR_CONFIG_SURFACE}`
6. `MQL5/Files/AI/` directory mtime and contents are UNCHANGED after sidecar runs for 60 seconds
7. `EXE_RUNTIME_CACHE/` contains only the 3 approved files (status, diagnostics, pid)
8. Dashboard at `http://localhost:8000` continues to function with `SIDECAR_URL` unset (direct-read fallback working)
9. Dashboard with `SIDECAR_URL=http://localhost:17001` set returns the same data as without sidecar (content equivalence)
10. `stop_sidecar.ps1` terminates the process cleanly
11. No `.mq5`, `.mqh`, `.ex5`, or governance doc was modified
12. `ai_current_plan.json` was not read or modified by sidecar

---

## D. Sidecar Architecture Diagram

```
MT5 EA (main_ea.ex5)
  │ writes every tick/timer
  ▼
MQL5/Files/AI/          (MT5 write domain — sidecar READS ONLY, never writes)
  runtime_governance_status.json  ─┐
  execution_authority_status.json  │  Category A/B: full load
  active_operating_cohort.json    ─┤  on mtime change
  ai_opportunity_summary.json     ─┘
  ai_performance_journal.jsonl    ─┐
  ai_opportunity_ledger.jsonl      │  Category C: tail cursor
  council_feedback.json           ─┘  new bytes only
  ai_runtime_secrets.json         ── Category D: NEVER LOADED

                            2s poll
                               │
                               ▼
         external_dashboard/sidecar/sidecar.py
           (FastAPI, localhost:17001)
           RAM cache: {filename → cached_value}
           JSONL tail: {filename → deque(last 500)}
                               │
                               ├── writes EXE_RUNTIME_CACHE/sidecar_status.json
                               ├── writes EXE_RUNTIME_CACHE/sidecar_diagnostics.json
                               └── writes EXE_RUNTIME_CACHE/sidecar.pid
                               │
                               │ HTTP GET (optional, with fallback)
                               ▼
         external_dashboard/app/sources.py
           ArtifactStore (existing)
           + SidecarClient (new, optional proxy)
                               │
                               ▼
         external_dashboard/app/aggregator.py  (UNCHANGED)
                               │
                               ▼
         Dashboard user (browser)
```

---

## E. File Classification Manifest

All paths are relative to `MQL5/Files/AI/`.

### Category A — Small Status (full load, mtime-invalidated)

| File | Size (approx) | Notes |
|---|---|---|
| `runtime_governance_status.json` | ~1.6KB | Core status |
| `runtime_governance_status.txt` | ~1.6KB | Mirror |
| `execution_authority_status.json` | ~1KB | Authority status |
| `execution_authority_status.txt` | ~1KB | Mirror |
| `active_operating_cohort.json` | ~700B | Cohort |
| `active_operating_cohort.txt` | ~700B | Mirror |
| `operating_risk_envelope_status.json` | ~700B | Risk envelope |
| `operating_risk_envelope_status.txt` | ~700B | Mirror |
| `risk_safety_status.json` | ~1.3KB | Risk safety |
| `risk_safety_status.txt` | ~1.3KB | Mirror |
| `operational_integrity_status.json` | ~2.6KB | Integrity |
| `operational_integrity_status.txt` | ~2.5KB | Mirror |
| `council_ai_advisory_status.json` | ~2KB | Council governor |
| `council_ai_advisory_status.txt` | ~1.9KB | Mirror |
| `council_ai_advisory_effectiveness.json` | ~800B | Council effectiveness |
| `ai_institutional_learning_status.json` | ~1.1KB | Learning status |
| `ai_institutional_learning_status.txt` | ~970B | Mirror |
| `ai_institutional_learning_lineage_status.json` | ~800B | Lineage |
| `ai_trade_evidence_completeness_status.json` | ~626B | Trade evidence |
| `last_meaningful_runtime_event.json` | ~576B | Last event |
| `last_meaningful_runtime_event.txt` | ~536B | Mirror |
| `atas_runtime_context_status.json` | ~1.5KB | ATAS status |
| `atas_microstructure_status.json` | ~1.5KB | ATAS micro |
| `atas_governed_advisory_status.json` | ~1.5KB | ATAS advisory |
| `atas_governed_advisory_status.txt` | ~1.5KB | Mirror |
| `export_release_gate_status.json` | ~1KB | Release gate |
| `ai_activation_readiness_status.json` | ~1KB | Activation |
| `ai_decision_envelope_observability_status.json` | ~727B | Envelope obs |
| `council_audit_summary.json` | ~1.1KB | Audit summary |
| `replay_validation_summary.json` | ~1.4KB | Replay |
| `execution_quality_validation.json` | ~1.4KB | Exec quality |
| `factory_operational_evidence_status.json` | ~1.5KB | Factory |

### Category B — Medium Files (full load, mtime-invalidated)

| File | Size (approx) | Notes |
|---|---|---|
| `ai_opportunity_summary.json` | ~15KB | OL summary; primary sidecar target |
| `ai_strategy_memory.json` | ~20KB (est) | Strategy memory |
| `ai_institutional_learning_memory.json` | ~74KB | Learning memory |
| `operator_effective_configuration_surface.json` | ~11KB | Effective config |
| `operator_input_truth_map.json` | ~10KB | Input truth |
| `threshold_ownership_registry.json` | ~6KB | Thresholds |
| `runtime_honesty_truth.json` | ~5KB | Honesty |
| `council_report.txt` | ~26KB | Council report |

### Category C — Large JSONL (tail cursor, last 500 records)

| File | Size (approx) | Notes |
|---|---|---|
| `ai_performance_journal.jsonl` | ~34MB | CRITICAL: tail only, never full-load |
| `council_feedback.json` | ~5MB | Note: .json but line-structured; treat as JSONL tail |
| `ai_opportunity_ledger.jsonl` | ~139KB | OL records |
| `ai_strategy_memory_events.jsonl` | ~1.6MB | Strategy events |
| `ai_decision_envelope_trace.jsonl` | ~428KB | Decision trace |
| `ai_institutional_learning_events.jsonl` | ~248KB | Learning events |
| `ai_institutional_learning_trade_lineage.jsonl` | ~213KB | Trade lineage |
| `ai_institutional_learning_decision_context.jsonl` | ~178KB | Decision context |

### Category D — Excluded (never load, return EXCLUDED status)

| File | Reason |
|---|---|
| `ai_runtime_secrets.json` | SECRET surface |
| `ai_current_plan.json` | Config/human-owned; not status |
| `ai_previous_plan_backup.json` | Config backup |
| `ai_evolution_state.json` | Strict-JSON-invalid; config surface |
| `ai_governor_state.json` | `{}` only — effectively empty; not useful |
| Any file matching `*secret*`, `*key*` | Secret exclusion pattern |

---

## F. Package 2 Codex Execution Spec

### F.1 Pre-Conditions (Codex must verify before starting)

1. Current working directory is `MQL5/Experts/AI/`
2. `external_dashboard/.venv/` exists (or Python 3.x available)
3. `external_dashboard/app/sources.py` is unchanged from its pre-Package-2 state
4. `MQL5/Files/AI/` exists and is readable
5. No existing process listening on localhost:17001

If any pre-condition fails: stop and report; do not modify any file.

### F.2 Task List (ordered, each task bounded)

---

**TASK 1: Create EXE_RUNTIME_CACHE directory**

Create directory `MQL5/Experts/AI/EXE_RUNTIME_CACHE/`.

Create placeholder `MQL5/Experts/AI/EXE_RUNTIME_CACHE/.gitkeep` (empty file).

Do not create any other files in this directory — sidecar creates them at runtime.

---

**TASK 2: Create sidecar package skeleton**

Create directory `MQL5/Experts/AI/external_dashboard/sidecar/`.

Create `MQL5/Experts/AI/external_dashboard/sidecar/__init__.py`:
```python
# EXE/RAM sidecar package — read-only observer, no trading authority
```

---

**TASK 3: Create sidecar config**

Create `MQL5/Experts/AI/external_dashboard/sidecar/config.json`:
```json
{
  "port": 17001,
  "host": "127.0.0.1",
  "poll_interval_seconds": 2,
  "jsonl_tail_lines": 500,
  "jsonl_max_tail_response": 100,
  "status_write_interval_seconds": 30,
  "_note": "Read-only sidecar config. MT5 remains sole trading authority."
}
```

---

**TASK 4: Create manifest.py**

Create `MQL5/Experts/AI/external_dashboard/sidecar/manifest.py`.

This module must define:
- `CATEGORY_A_FILES`: list of filenames (Category A, full JSON load)
- `CATEGORY_B_FILES`: list of filenames (Category B, full JSON load)
- `CATEGORY_C_FILES`: list of filenames (Category C, JSONL tail)
- `EXCLUDED_FILES`: set of exact filenames that must NEVER be loaded
- `EXCLUDED_PATTERNS`: list of glob patterns matched against filename (e.g., `*secret*`, `*key*`)
- `FileCategory` enum: `A`, `B`, `C`, `D` (excluded)
- `classify(filename: str) -> FileCategory` function: returns the category for a given filename; returns `D` for any match in `EXCLUDED_FILES` or `EXCLUDED_PATTERNS`

Use the file lists from Section E of this spec. The `classify()` function is the single source of truth — no file loading code anywhere should bypass it.

---

**TASK 5: Create cache.py**

Create `MQL5/Experts/AI/external_dashboard/sidecar/cache.py`.

This module implements `SidecarCache` class with:

```python
class SidecarCache:
    """Thread-safe in-memory cache. Read-only relative to Files/AI."""

    def __init__(self, files_ai_root: Path, config: dict) -> None:
        # fields: _files_ai_root, _config, _lock (threading.RLock),
        # _json_cache: dict[str, CacheEntry],
        # _jsonl_cursors: dict[str, JsonlCursor]

    def poll(self) -> None:
        """Poll all monitored files. Called from background thread every poll_interval_seconds."""
        # For each Category A/B file: check mtime; if changed, reload JSON
        # For each Category C file: open from cursor, read new bytes, parse new lines, append to deque
        # Never read Category D files
        # Write sidecar_status.json and sidecar_diagnostics.json to EXE_RUNTIME_CACHE/

    def get_json(self, filename: str) -> dict:
        """Return cached dict or _status error dict. Thread-safe."""

    def get_jsonl_tail(self, filename: str, lines: int = 100) -> list:
        """Return last N records from tail. Thread-safe."""

    def get_snapshot(self) -> dict:
        """Return all Category A+B cached content as {filename: content}. Thread-safe."""

    def get_diagnostics(self) -> dict:
        """Return per-file diagnostics. Thread-safe."""

    def get_manifest_status(self) -> dict:
        """Return manifest with per-file status (loaded/missing/excluded/error). Thread-safe."""
```

`CacheEntry` dataclass: `{filename, category, mtime_ns, size_bytes, last_load_ts, content: dict, cache_hits: int, cache_misses: int, load_error: str | None}`

`JsonlCursor` dataclass: `{filename, byte_offset, records: collections.deque, last_read_ts, load_error: str | None}`

**Critical implementation constraint for Category C (JSONL tail):**
- Open file, seek to `byte_offset`, read to EOF, split by `\n`, parse each line as JSON
- Update `byte_offset` to new EOF position
- If `byte_offset > current_file_size` (truncation/rotation): reset cursor to 0, reload from start
- Never load the entire file into memory in a single read — use chunked reads if file is >10MB from offset 0

---

**TASK 6: Create sidecar.py**

Create `MQL5/Experts/AI/external_dashboard/sidecar/sidecar.py`.

```python
"""
MT5 EXE/RAM Sidecar — read-only observer.
Authority: MT5 remains sole runtime and trading authority.
This process NEVER writes to MQL5/Files/AI/.
"""
from __future__ import annotations

import json
import os
import threading
import time
from pathlib import Path

# ... imports

# Path resolution — sidecar lives at external_dashboard/sidecar/sidecar.py
# Files/AI is 5 levels up from here:
# sidecar.py → sidecar/ → external_dashboard/ → AI/ → MQL5/ → terminal_root/ → Files/AI/
SIDECAR_ROOT = Path(__file__).resolve().parent
EXTERNAL_DASHBOARD_ROOT = SIDECAR_ROOT.parent
AI_ROOT = EXTERNAL_DASHBOARD_ROOT.parent
TERMINAL_ROOT = AI_ROOT.parents[1]
FILES_AI_ROOT = TERMINAL_ROOT / "MQL5" / "Files" / "AI"
EXE_CACHE_ROOT = AI_ROOT / "EXE_RUNTIME_CACHE"

CONFIG_PATH = SIDECAR_ROOT / "config.json"

# Load config
def _load_config() -> dict:
    try:
        return json.loads(CONFIG_PATH.read_text(encoding="utf-8"))
    except Exception:
        return {"port": 17001, "host": "127.0.0.1", "poll_interval_seconds": 2, "jsonl_tail_lines": 500}

CONFIG = _load_config()
_STARTUP_TS = time.time()

# Init cache
from .cache import SidecarCache
from .manifest import FileCategory

cache = SidecarCache(files_ai_root=FILES_AI_ROOT, config=CONFIG)

# Background poller
def _poll_loop():
    interval = float(CONFIG.get("poll_interval_seconds", 2))
    while True:
        try:
            cache.poll()
        except Exception:
            pass  # never crash the poller
        time.sleep(interval)

_poll_thread = threading.Thread(target=_poll_loop, daemon=True, name="sidecar-poller")
_poll_thread.start()

# FastAPI app
from fastapi import FastAPI, Query
from fastapi.responses import JSONResponse

app = FastAPI(title="MT5 EXE Sidecar", version="v1")

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "mt5_exe_sidecar",
        "mode": "READ_ONLY_NO_TRADING_AUTHORITY",
        "uptime_s": int(time.time() - _STARTUP_TS),
        "port": CONFIG.get("port", 17001),
        "files_ai_root": str(FILES_AI_ROOT),
        "files_ai_root_exists": FILES_AI_ROOT.exists(),
        "exe_cache_root": str(EXE_CACHE_ROOT),
    }

@app.get("/cache/{filename:path}")
def get_cached(filename: str):
    return JSONResponse(cache.get_json(filename))

@app.get("/snapshot")
def snapshot():
    return JSONResponse(cache.get_snapshot())

@app.get("/tail/{filename:path}")
def tail(filename: str, lines: int = Query(default=100, ge=1, le=500)):
    return JSONResponse(cache.get_jsonl_tail(filename, lines=lines))

@app.get("/diagnostics")
def diagnostics():
    return JSONResponse(cache.get_diagnostics())

@app.get("/manifest")
def manifest_status():
    return JSONResponse(cache.get_manifest_status())
```

Path resolution note: `TERMINAL_ROOT = AI_ROOT.parents[1]` because:
- `AI_ROOT` = `...Terminal/<hash>/MQL5/Experts/AI`
- `AI_ROOT.parent` = `.../MQL5/Experts`
- `AI_ROOT.parents[1]` = `.../MQL5`
- Then `/ "Files" / "AI"` gives `...MQL5/Files/AI` ✓

Actually correct resolution:
- `SIDECAR_ROOT` = `AI/external_dashboard/sidecar`
- `EXTERNAL_DASHBOARD_ROOT` = `AI/external_dashboard`
- `AI_ROOT` = `AI/`
- `MQL5_ROOT` = `AI_ROOT.parent` = `MQL5/`
- `FILES_AI_ROOT` = `MQL5_ROOT / "Files" / "AI"`

Codex must verify these paths at runtime via the `/health` endpoint.

---

**TASK 7: Create run_sidecar.ps1**

Create `MQL5/Experts/AI/external_dashboard/run_sidecar.ps1`:

```powershell
# MT5 EXE Sidecar — Launch Script
# Read-only observer. MT5 remains sole trading authority.

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AIRoot = Split-Path -Parent $ScriptDir
$CacheDir = Join-Path $AIRoot "EXE_RUNTIME_CACHE"
$PidFile = Join-Path $CacheDir "sidecar.pid"
$VenvPython = Join-Path $ScriptDir ".venv\Scripts\python.exe"

if (-not (Test-Path $CacheDir)) { New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null }

# Check if already running
if (Test-Path $PidFile) {
    $existingPid = Get-Content $PidFile -ErrorAction SilentlyContinue
    if ($existingPid -and (Get-Process -Id $existingPid -ErrorAction SilentlyContinue)) {
        Write-Host "Sidecar already running (PID $existingPid). Use stop_sidecar.ps1 to stop."
        exit 0
    }
    Remove-Item $PidFile -Force
}

if (-not (Test-Path $VenvPython)) {
    $VenvPython = "python"
    Write-Host "Warning: .venv not found, using system Python"
}

$config = Get-Content (Join-Path $ScriptDir "sidecar\config.json") | ConvertFrom-Json
$port = if ($config.port) { $config.port } else { 17001 }
$host = if ($config.host) { $config.host } else { "127.0.0.1" }

$proc = Start-Process -FilePath $VenvPython -ArgumentList @(
    "-m", "uvicorn",
    "external_dashboard.sidecar.sidecar:app",
    "--host", $host,
    "--port", "$port",
    "--log-level", "warning"
) -WorkingDirectory $AIRoot -PassThru -WindowStyle Hidden

$proc.Id | Out-File $PidFile -Encoding ASCII

Start-Sleep -Seconds 2

try {
    $health = Invoke-RestMethod -Uri "http://${host}:${port}/health" -TimeoutSec 3
    Write-Host "Sidecar started (PID $($proc.Id)) — $($health.status) on port $port"
    Write-Host "Files/AI: $($health.files_ai_root)"
} catch {
    Write-Host "Sidecar started (PID $($proc.Id)) but health check failed — check logs"
}
```

---

**TASK 8: Create stop_sidecar.ps1**

Create `MQL5/Experts/AI/external_dashboard/stop_sidecar.ps1`:

```powershell
# MT5 EXE Sidecar — Stop Script

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$AIRoot = Split-Path -Parent $ScriptDir
$PidFile = Join-Path $AIRoot "EXE_RUNTIME_CACHE\sidecar.pid"

if (-not (Test-Path $PidFile)) {
    Write-Host "Sidecar PID file not found — sidecar may not be running."
    exit 0
}

$sidePid = Get-Content $PidFile -ErrorAction SilentlyContinue
if ($sidePid) {
    Stop-Process -Id $sidePid -ErrorAction SilentlyContinue
    Write-Host "Sidecar (PID $sidePid) stopped."
} else {
    Write-Host "No PID found in pid file."
}

Remove-Item $PidFile -Force -ErrorAction SilentlyContinue
```

---

**TASK 9: Minimal modification to sources.py**

Modify `external_dashboard/app/sources.py` to add `SidecarClient` class and optional proxy.

Add at top of file (after existing imports):
```python
import os
import urllib.request
import urllib.error
```

Add `SidecarClient` class before `ArtifactStore`:
```python
class SidecarClient:
    """Optional proxy to the EXE sidecar. Falls back gracefully to direct reads."""

    def __init__(self, base_url: str | None) -> None:
        self._url = base_url.rstrip("/") if base_url else None
        self._timeout = 0.15  # 150ms max — must not block dashboard

    def available(self) -> bool:
        return self._url is not None

    def get_json(self, filename: str) -> dict | None:
        if not self._url:
            return None
        try:
            url = f"{self._url}/cache/{filename}"
            with urllib.request.urlopen(url, timeout=self._timeout) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                if isinstance(data, dict) and data.get("_status") in ("UNAVAILABLE", "ERROR", "EXCLUDED"):
                    return None  # force fallback on sidecar error states
                return data
        except Exception:
            return None

    def get_jsonl(self, filename: str, limit: int = 0) -> list | None:
        if not self._url:
            return None
        try:
            lines = max(1, min(500, limit)) if limit > 0 else 100
            url = f"{self._url}/tail/{filename}?lines={lines}"
            with urllib.request.urlopen(url, timeout=self._timeout) as resp:
                data = json.loads(resp.read().decode("utf-8"))
                if isinstance(data, list):
                    return data
                return None
        except Exception:
            return None
```

Modify `ArtifactStore.__init__` to accept `sidecar: SidecarClient | None = None`:
```python
def __init__(self, files_ai_root: Path, adapter_root: Path, sidecar: SidecarClient | None = None) -> None:
    self.files_ai_root = files_ai_root
    self.adapter_root = adapter_root
    self._sidecar = sidecar
    self._json_cache: dict[str, tuple[int, Any]] = {}
    self._jsonl_cache: dict[str, tuple[int, list[dict[str, Any]]]] = {}
```

Modify `load_json` to try sidecar first:
```python
def load_json(self, rel_path: str, root: str = "ai") -> dict[str, Any]:
    path = self._path(rel_path, root)
    # Try sidecar proxy first (only for Files/AI root)
    if root == "ai" and self._sidecar and self._sidecar.available():
        cached = self._sidecar.get_json(Path(rel_path).name)
        if cached is not None:
            return cached
    # ... existing implementation unchanged below
```

Modify `load_jsonl` similarly to try `self._sidecar.get_jsonl()` first.

Modify `main.py` to wire the sidecar client:
```python
import os
from .sources import ArtifactStore, SidecarClient

sidecar_url = os.getenv("SIDECAR_URL")
sidecar = SidecarClient(sidecar_url) if sidecar_url else None
store = ArtifactStore(FILES_AI_ROOT, ADAPTER_ROOT, sidecar=sidecar)
```

No other changes to `main.py`, `aggregator.py`, or any template.

---

**TASK 10: Verification**

After completing Tasks 1–9, Codex must verify:

1. `python -c "from external_dashboard.sidecar.sidecar import app; print('import ok')"` runs without error from `AI/` directory
2. `python -c "from external_dashboard.sidecar.manifest import classify, FileCategory; assert classify('ai_runtime_secrets.json') == FileCategory.D"` passes
3. `python -c "from external_dashboard.sidecar.manifest import classify, FileCategory; assert classify('runtime_governance_status.json') == FileCategory.A"` passes
4. Existing `sources.py` imports without error: `python -c "from external_dashboard.app.sources import ArtifactStore, SidecarClient; print('ok')"`
5. Existing `main.py` imports without error: `python -c "from external_dashboard.app.main import app; print('ok')"`

If any check fails: report the error with full traceback; do not proceed.

---

## G. Package 3 Forensic Review Checklist

After Package 2 completes, Claude (Package 3) must run the following review:

**G.1 File integrity (no unauthorized writes):**
- [ ] `MQL5/Files/AI/` mtime of all Category D files unchanged
- [ ] `ai_runtime_secrets.json` not accessed (check OS file handle log if available, or verify by testing sidecar's `/cache/ai_runtime_secrets.json` returns EXCLUDED)
- [ ] No new files in `MQL5/Files/AI/`
- [ ] `EXE_RUNTIME_CACHE/` contains only: `sidecar_status.json`, `sidecar_diagnostics.json`, `sidecar.pid`

**G.2 Source integrity (no unauthorized edits):**
- [ ] All `.mq5` and `.mqh` files unchanged (git diff confirms)
- [ ] `MT5_EXE_MIGRATION_PLAN.md` unchanged by Package 2
- [ ] `PROJECT_INTELLIGENCE_MEMORY_LAYER.md` unchanged by Package 2
- [ ] `AGENTS.md` and `OPERATION_GUARDRAILS.md` unchanged

**G.3 Functional verification:**
- [ ] `run_sidecar.ps1` starts sidecar; `/health` returns ok
- [ ] `/cache/runtime_governance_status.json` returns valid dict
- [ ] `/tail/ai_performance_journal.jsonl?lines=20` returns ≤20 records
- [ ] `/cache/ai_runtime_secrets.json` returns `{_status: EXCLUDED}`
- [ ] `stop_sidecar.ps1` terminates cleanly
- [ ] Dashboard works with `SIDECAR_URL` unset (fallback mode)
- [ ] Dashboard works with `SIDECAR_URL=http://localhost:17001` (proxy mode)

**G.4 Authority boundary:**
- [ ] No MQL source includes or references the sidecar
- [ ] Sidecar HTTP server bound to `127.0.0.1` only (not `0.0.0.0`)
- [ ] No trading actions possible via sidecar API

**Certification verdict:**
- `SIDECAR_V1_CERTIFIED` — all checks pass
- `SIDECAR_V1_CONDITIONAL` — minor issues; sidecar functional but caveats documented
- `SIDECAR_V1_REJECTED` — authority boundary violated or Files/AI written

---

## H. Migration Plan Relationship

This sidecar is **Stage 2E (Prototype)** in the migration plan's terminology, with the following gates resolved:

| Decision ID | Gate | Resolution in Sidecar V1 |
|---|---|---|
| DEC-WRITE-001 | EXE V1 writes | Resolved: sidecar writes only to `EXE_RUNTIME_CACHE/`; no Files/AI writes |
| DEC-WRITE-002 | Dashboard V1 writes | Resolved: sidecar is visibility-only; no dashboard write-back |
| DEC-CONC-001 | Read concurrency | Resolved: polling with mtime check; no file locking attempted |
| DEC-PATH-001 | Live MT5 path contract | Resolved: confirmed path `...Terminal/D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Files/AI/` |
| DEC-SECRET-001 | EXE secret reads | Resolved: `ai_runtime_secrets.json` explicitly excluded in manifest |
| DEC-SECRET-002 | Secret caching | Resolved: no cache |
| DEC-SECRET-003 | Dashboard secret display | Resolved: returns EXCLUDED status only |

Remaining unresolved (out of scope for sidecar V1, preserved as-is):
- DEC-JSON-001/002/003 (JSON normalization) — not applicable to read-only sidecar
- DEC-AUTH-001/002/003 (plan authority) — not applicable; sidecar excludes plan files
- DEC-MISS-001/002/003 (missing surfaces) — tolerated: missing files return UNAVAILABLE
- DEC-FRESH-001/002/003 (freshness thresholds) — sidecar exposes `_age_seconds` per file; dashboard can apply its own stale policy

---

## I. Footer

```
DOCUMENT_ID:                 MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1
DATE:                        2026-05-10
PACKAGE:                     Package 1 (Claude planning/spec output)
STATUS:                      SPEC_COMPLETE — READY_FOR_CODEX_PACKAGE2
SOURCE_CHANGED:              NO
COMPILE_RUN:                 NO
LIVE_TRADING:                NO
MT5_AUTHORITY_TRANSFERRED:   NO
FILES_AI_WRITES_APPROVED:    NONE
SIDECAR_WRITE_PATH:          EXE_RUNTIME_CACHE/ (outside Files/AI)
LANGUAGE:                    Python (reuse external_dashboard venv)
LOCATION:                    AI/external_dashboard/sidecar/
PORT:                        17001 (localhost only)
MIGRATION_PLAN_STAGE:        Stage 2E (first prototype — constrained sidecar only)
PACKAGE2_SCOPE:              sidecar/ package + minimal sources.py proxy + launch scripts
PACKAGE2_EXCLUSIONS:         No .mq5/.mqh changes; no aggregator.py changes; no IRREW changes
PACKAGE3_VERDICT_TARGET:     SIDECAR_V1_CERTIFIED
ROLLBACK:                    Delete sidecar/ dir + unset SIDECAR_URL env var
```
