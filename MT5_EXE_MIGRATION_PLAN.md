# MT5 to EXE Migration Plan

## Stage 0 discovery notice

This document was created during Stage 0 discovery only. It inventories and classifies the existing file-based MT5 system. It does not implement an EXE, does not change trading logic, does not change config formats, does not modify runtime/state/log files, and does not move or rename files.

Generated from uploaded archive: `pre_change_20260420_160325_plan5_stage1_unified.zip`  
Workspace root observed inside archive: `AI\`  
Discovery date: 2026-04-25  
Existing `MT5_EXE_MIGRATION_PLAN.md`: not found in archive, so no timestamped plan backup was created.  
Read `AGENTS.md`: yes.  
Read `OPERATION_GUARDRAILS.md`: yes.

---

## Project objective

Perform a governed migration discovery for a possible MT5-to-EXE architecture while preserving existing runtime meaning and authority boundaries.

Stage 0 objective:

- Inventory the current file-based MT5 system.
- Classify source, config, state/status, report/memory, dashboard, external adapter, developer tooling, archives, and generated artifacts.
- Define only a proposed EXE boundary and cache/RAM strategy at discovery level.
- Mark uncertain authority, ownership, freshness, and write behavior as `Unknown / needs confirmation`.
- Avoid all implementation changes.

Non-goals for Stage 0:

- No EXE implementation.
- No RAM loader implementation.
- No dashboard implementation.
- No developer tool implementation.
- No trading-logic change.
- No `.mq5` or `.mqh` modification.
- No config/state/status/log/report modification other than this plan file.

---

## Current architecture summary

Evidence from workspace docs and source scan indicates this is a governed MT5 trading system rather than a simple EA.

Observed layers:

1. **MT5 runtime layer**
   - Primary active source entrypoint appears to be `AI\main_ea.mq5`.
   - Active compiled artifact present: `AI\main_ea.ex5`.
   - Runtime source modules are primarily root-level `.mqh` files and `AI\LIBRARIES\*.mqh`.
   - `main_ea.mq5` has `OnInit`, `OnTick`, `OnTimer`, `OnDeinit`, timer setup/kill usage, and 49 include directives.
   - Runtime/trade concepts were observed in `main_ea.mq5`, `core_trade_engine.mqh`, and `AI\LIBRARIES\library_filters.mqh`.
   - `config_loader.mqh` and many modules use file-based runtime/config/status surfaces.

2. **Configuration layer**
   - Plan/config surfaces include `ai_current_plan.json`, `ai_personality_profile.json`, `ai_runtime_secrets.json`, `ai_capabilities.json`, `ai_constraints.json`, `operator_*`, and threshold/ownership files.
   - Strict JSON parsing flagged `AI\ai_current_plan.json`, `AI\ai_previous_plan_backup.json`, and `AI\ai_evolution_state.json` as invalid due to escape handling. This must be confirmed before any EXE parser assumes standard JSON compatibility.
   - `ai_runtime_secrets.json` exists and must remain secret-sensitive even if it currently indicates placeholder status.

3. **State/status layer**
   - Runtime status surfaces include `runtime_governance_status.*`, `execution_authority_status.*`, `active_operating_cohort.*`, `operating_risk_envelope_status.*`, `risk_safety_status.*`, `operational_integrity_status.*`, and multiple dashboard/AI/ATAS status files.
   - `current_truth_authority_map.txt` states that runtime-emitted status surfaces describe active internal execution posture while code remains the final execution mechanism.
   - These files are write-sensitive/volatile and must not be rewritten or reformatted by EXE migration work.

4. **Report/memory layer**
   - Large journals and memory artifacts include `ai_performance_journal.jsonl`, `council_feedback.json`, institutional learning `.jsonl` files, strategy memory files, and forensic exports.
   - `AGENTS.md` marks `MQL5/Files/AI/ai_performance_journal.jsonl` as live-locked during live operation and says it should not be repeatedly read/copied/zipped while MT5 is running.

5. **Dashboard layer**
   - Internal MQL dashboard modules exist: `dashboard_*.mqh`.
   - External FastAPI dashboard exists under `AI\external_dashboard`.
   - `external_dashboard\app\sources.py` uses mtime-based JSON/JSONL caching and returns unavailable markers for missing or parse-failed files.
   - Dashboard governance docs explicitly say dashboard posture is display/analysis only and must not become runtime authority.

6. **External adapter / ATAS layer**
   - `AI\external_adapter\atas_semantic_adapter` contains .NET/C# adapter/exporter/prototype code, configs, docs, bin/obj outputs, and runtime/example files.
   - `AI\external_dashboard\tools\atas_live_capture_monitor.py` and `atas_live_propagation_runner.py` write or orchestrate ATAS live-chain capture/runner outputs.
   - OPERATION guardrails state ATAS is bounded external intelligence only and carries zero runtime authority.

7. **Codex/developer tooling layer**
   - `.claude`, `.continue`, `.vscode`, PowerShell scripts, Python tools, C# project files, and build outputs are present.
   - Several tools can write generated outputs and must not be run during discovery.

Primary authority boundary observed from governance docs:

- MT5 remains sole runtime, decision, risk, governor, and execution authority unless a future governed task explicitly changes that.
- Dashboard data is not runtime truth.
- ATAS/AI surfaces are advisory/visibility unless explicitly proven otherwise by runtime code and approved governance.

---

## File inventory/classification

### Inventory counts

Total files inspected by archive metadata and targeted content/path scans: **2931**  
Total uncompressed bytes inspected by metadata: **82402860**

| Extension | Count |
|---|---:|
| `.py` | 825 |
| `.pyc` | 820 |
| `.json` | 363 |
| `.txt` | 249 |
| `.md` | 171 |
| `[no extension]` | 133 |
| `.cs` | 78 |
| `.mqh` | 76 |
| `.typed` | 32 |
| `.jsonl` | 25 |
| `.cache` | 24 |
| `.log` | 23 |
| `.exe` | 20 |
| `.dll` | 16 |
| `.ps1` | 10 |
| `.html` | 9 |
| `.pdb` | 8 |
| `.editorconfig` | 5 |
| `.csproj` | 4 |
| `.props` | 4 |
| `.targets` | 4 |
| `.pyi` | 3 |
| `.csv` | 3 |
| `.mq5` | 2 |
| `.yaml` | 2 |
| `.pem` | 2 |
| `.pyd` | 2 |
| `.apache` | 2 |
| `.bsd` | 2 |
| `.bat` | 2 |
| `.xml` | 2 |
| `.bak_3d2` | 1 |
| `.ex5` | 1 |
| `.cfg` | 1 |
| `.c` | 1 |
| `.rst` | 1 |
| `.fish` | 1 |
| `.js` | 1 |
| `.css` | 1 |
| `.flag` | 1 |
| `.stop` | 1 |


### Top-level folder inventory

| Folder | Files | Size bytes | Major extensions |
|---|---:|---:|---|
| AI\.claude | 1 | 24848 | `.json`:1 |
| AI\.continue | 2 | 636 | `.yaml`:2 |
| AI\.vscode | 2 | 144 | `.json`:2 |
| AI\LIBRARIES | 5 | 22743 | `.mqh`:5 |
| AI\archive_pre_strategy_memory_v1 | 12 | 8879063 | `.json`:6, `.txt`:4, `.jsonl`:1, `.flag`:1 |
| AI\atas_live_capture | 41 | 682665 | `.json`:29, `.jsonl`:11, `.stop`:1 |
| AI\atas_micro_baseline | 25 | 823004 | `.json`:19, `.mqh`:5, `.mq5`:1 |
| AI\atas_micro_phase2_validation | 2 | 10382 | `.json`:1, `.jsonl`:1 |
| AI\atas_micro_phase3_candidate | 36 | 878875 | `.json`:24, `.jsonl`:6, `.md`:3, `.log`:3 |
| AI\atas_microstructure_phase2_kickoff_v1 | 20 | 68221 | `.json`:12, `.md`:5, `.cs`:1, `.ps1`:1, `.py`:1 |
| AI\atas_microstructure_phase3_sandbox_v1 | 23 | 185301 | `.md`:12, `.json`:4, `.py`:4, `.ps1`:3 |
| AI\backup | 1 | 134 | `.txt`:1 |
| AI\compile_logs | 7 | 306102 | `.log`:7 |
| AI\docs | 211 | 817658 | `.txt`:155, `.md`:43, `.json`:13 |
| AI\edge_factory | 43 | 6712858 | `.json`:41, `.txt`:2 |
| AI\external_adapter | 386 | 2840613 | `.json`:133, `.md`:84, `.cs`:77, `.cache`:24, `.dll`:16, `.txt`:10, `[no extension]`:9, `.pdb`:8 |
| AI\external_dashboard | 1891 | 32331560 | `.py`:820, `.pyc`:820, `[no extension]`:124, `.typed`:32, `.txt`:28, `.md`:19, `.exe`:14, `.html`:9 |
| AI\forensic_exports | 14 | 522567 | `.json`:8, `.csv`:3, `.md`:2, `.txt`:1 |


### Folder classification

| Path / pattern | Evidence / role | Classification | Risk | Authority source | Safe-to-cache | Write sensitivity | Refresh condition | Invalidation condition | Failure behavior recommendation | Stale dangerous? |
|---|---|---|---|---|---|---|---|---|---|---|
| AI | Workspace root with runtime source, status/config files, reports, docs, tools, compiled artifacts | MT5 Runtime Layer; Configuration Layer; State/Status Layer; Report/Memory Layer; EXE Application Layer; Codex Execution Layer; Archive/Documentation; Generated/Volatile | execution-critical; config-critical; state-critical; visibility-only; report-only; generated/volatile | Mixed: MT5-owned, human-owned, generated, external/tool-owned, unknown | conditional | write-sensitive | Refresh by per-file mtime/hash; do not bulk-cache as truth | Invalidate on any file mtime/hash change, MT5 restart, EXE restart, failed parse, unknown authority | Fail closed for runtime authority/config; fail unavailable for dashboard/report-only | Yes for runtime/config/status; no/conditional for docs |
| AI\LIBRARIES | MQL include libraries used by `main_ea.mq5` strategy compiler/runtime | MT5 Runtime Layer | execution-critical | MT5-owned / source-controlled | conditional | read-only | Refresh on source hash/mtime change | Any include edit or compile artifact mismatch | Block migration/build assumptions; do not execute stale compiled logic | Yes |
| AI\.claude; AI\.continue; AI\.vscode | Developer/IDE/Codex configuration | Codex Execution Layer; Configuration Layer | config-critical; visibility-only; unknown | human-owned / tool-owned | conditional | write-sensitive | Refresh on developer-tool startup or config mtime/hash change | Config edit, plugin/tool version change | Do not use as trading truth; fail by disabling developer automation only | Usually no; unknown for automation |
| AI\docs | Architecture, authority, dashboard, migration, policy, contract docs | Archive/Documentation; Report/Memory Layer | report-only; visibility-only | human-owned / generated; evidence varies by document | conditional | read-only | Refresh on document hash/mtime change | Document edit or newer authoritative doc appears | Do not use docs over runtime code/status; flag conflict | Could be dangerous if used as authority without code/status evidence |
| AI\archive_pre_strategy_memory_v1 | Archived/pre-strategy memory and historical transfer artifacts | Archive/Documentation; Report/Memory Layer | archive-only; report-only | generated / human-owned unknown | conditional | write-sensitive | Refresh only for evidence review | Archive manifest/hash mismatch or newer archive supersedes it | Keep read-only; do not use as current runtime truth | Yes if treated as current truth |
| AI\backup | Backup marker/status artifact | Archive/Documentation | archive-only | human-owned/generated unknown | conditional | read-only | Refresh on backup audit | Backup file change | Report unavailable; do not restore blindly | No for runtime; yes for rollback audit |
| AI\compile_logs | Generated compile logs | Generated/Volatile; Report/Memory Layer | generated/volatile; report-only | generated | unsafe | volatile | Refresh after compile attempt | New compile log or source hash change | Use only as diagnostic evidence; never runtime truth | No for trading; yes for diagnosis if stale |
| AI\edge_factory | Factory/edge registry, canon, decomposition, governance, risk, timing, scorecard artifacts | Report/Memory Layer; State/Status Layer; Configuration Layer; Archive/Documentation | visibility-only; state-critical; report-only; unknown | generated / human-owned unknown | conditional | write-sensitive | Refresh on mtime/hash and factory process completion | Any factory artifact update; schema mismatch; missing status | Do not promote to runtime authority; surface unavailable/stale | Yes if used to grant runtime permission |
| AI\atas_live_capture | ATAS live-chain snapshots, event streams, lock/stop/status outputs | Generated/Volatile; State/Status Layer; Report/Memory Layer | generated/volatile; state-critical; visibility-only | generated by dashboard/ATAS tools | unsafe/conditional | volatile | Refresh by mtime, event cursor, runner status, explicit stop/lock file state | New event, lock/stop change, stale age threshold, parse failure | Do not block MT5 trading solely from dashboard capture; mark chain unavailable/stale | Yes if treated as runtime truth |
| AI\atas_micro_baseline | Archived ATAS micro baseline package including payload MQL source copy | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | generated/human-owned unknown | conditional | read-only | Refresh only for baseline comparison | Baseline superseded or hash mismatch | Do not use archived source as active runtime source without explicit promotion | Yes if confused with live source |
| AI\atas_micro_phase2_validation; AI\atas_micro_phase3_candidate; AI\atas_microstructure_phase2_kickoff_v1; AI\atas_microstructure_phase3_sandbox_v1 | Validation/sandbox/candidate packages and tools | Archive/Documentation; Codex Execution Layer; Report/Memory Layer | archive-only; report-only; unknown; generated/volatile | human-owned/generated/tool-owned unknown | conditional | write-sensitive | Refresh on package/tool run completion | Tool output changed, package superseded, schema mismatch | Do not apply candidate output to runtime without governed task | Yes if promoted silently |
| AI\external_adapter | ATAS semantic adapter C#/.NET source, configs, runtime examples, bin/obj outputs | EXE Application Layer; Configuration Layer; State/Status Layer; Generated/Volatile; Archive/Documentation | config-critical; state-critical; generated/volatile; visibility-only | external/tool-owned; generated; human-owned config examples | conditional | write-sensitive | Refresh on adapter run/build output mtime/hash | Config change, binary/source mismatch, runtime output update | Treat as bounded external advisory producer; no MT5 authority | Yes if adapter output is treated as execution authority |
| AI\external_dashboard | FastAPI read-only dashboard, templates/static files, scripts/tools, `.venv` | EXE Application Layer; Dashboard/visibility; Codex Execution Layer; Generated/Volatile | visibility-only; generated/volatile; state-critical for local tool outputs | human-owned/source; generated dependencies; tool-generated outputs | conditional | write-sensitive for tools; read-only for app display path | Refresh app source on hash/mtime; refresh dashboard data by source mtime cache | Source/data mtime change, missing file, stale age threshold, app restart | Return UNAVAILABLE/stale badges; never write back to runtime from dashboard | Yes if dashboard cache is used as runtime truth |
| AI\forensic_exports | Forensic exports, CSV/JSON/report snapshots | Report/Memory Layer; Archive/Documentation | report-only; archive-only | generated | conditional | read-only | Refresh only when reviewing forensic evidence | New forensic export supersedes old snapshot | Do not use as current trading state | Yes if treated as live status |


### File type classification

| File type / group | Evidence | Classification | Risk | Authority source | Safe-to-cache | Write sensitivity | Refresh condition | Invalidation condition | Failure behavior recommendation | Stale dangerous? |
|---|---|---|---|---|---|---|---|---|---|---|
| .mq5 | 2 files: active `AI\main_ea.mq5` plus archived baseline payload | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change; compile change | Any source/include change; active-vs-archive ambiguity | Block EXE migration assumptions; require compile/source review | Yes |
| .mqh | 76 files including runtime modules, libraries, dashboard modules, archived payload modules | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Any include edit; dependency graph change | Do not alter; classify before migration | Yes |
| .ex5 | `AI\main_ea.ex5` compiled runtime artifact | MT5 Runtime Layer; Generated/Volatile | execution-critical; generated/volatile | generated by MT5 compile | unsafe | write-sensitive | Refresh after compile only | Source hash mismatch; compile timestamp/version change | Do not treat source and binary as interchangeable; fail closed | Yes |
| .json | 363 files: config, status, memory, dashboard, adapter, factory artifacts | Configuration Layer; State/Status Layer; Report/Memory Layer; Generated/Volatile | config-critical; state-critical; visibility-only; report-only; unknown | mixed: MT5-owned/generated/human-owned/external/unknown | conditional/unsafe | write-sensitive or volatile | Per-file mtime/hash and role-specific TTL | MT5 write, external tool write, parse/schema failure, role uncertainty | Fail closed for runtime/config; UNAVAILABLE for dashboard/report | Yes for config/status |
| .jsonl | 25 files: journals, event streams, lineage | State/Status Layer; Report/Memory Layer; Generated/Volatile | state-critical; generated/volatile; report-only | generated | unsafe/conditional | volatile | Append cursor/mtime; avoid rereading huge live journal | New append, truncation, rotation, parse errors | Tail only when needed; never block live system on locked journal | Yes if used for current execution truth |
| .txt | 249 files: status mirrors, reports, docs, snapshots | State/Status Layer; Report/Memory Layer; Archive/Documentation | visibility-only; report-only; state-critical where status mirror | mixed | conditional | write-sensitive/volatile depending on file | mtime/hash | New status/report; mismatch with paired JSON | Prefer authoritative JSON/code when conflict exists | Conditional |
| .md | 171 files: governance, architecture, review docs | Archive/Documentation; Report/Memory Layer | report-only; archive-only | human-owned/generated | conditional | read-only | mtime/hash | Newer contract/doc supersedes | Use as evidence, not runtime truth | Yes if misused as authority |
| .log | 23 files | Generated/Volatile; Report/Memory Layer | generated/volatile; report-only | generated | unsafe | volatile | After tool/compile run | New run; truncation; source changed | Diagnostic only | No for runtime; conditional for diagnosis |
| .csv | 3 files | Report/Memory Layer; Archive/Documentation | report-only | generated | conditional | read-only | When reviewing export snapshot | New export supersedes | Do not use as current truth | Conditional |
| .py/.ps1/.bat/.cs/.csproj | 825 Python incl. venv, 10 PowerShell, 2 bat, 78 C# source, 4 projects | EXE Application Layer; Codex Execution Layer | config-critical; state-critical where tools write outputs; unknown | human/tool-owned | conditional | write-sensitive | Source hash/mtime; tool version change | Script/source change; output path change | Do not run during discovery; review write paths before future task | Yes if tool writes runtime surfaces unexpectedly |
| .exe/.dll/.pdb/.pyc/.cache/.venv | 20 exe, 16 dll, 820 pyc, 24 cache; mostly dashboard venv and .NET bin/obj | Generated/Volatile; EXE Application Layer | generated/volatile; unknown; execution-critical if invoked | generated/tool-owned | unsafe | write-sensitive/volatile | Rebuild/reinstall only | Source/build dependency mismatch; dependency update | Do not migrate from binary artifacts alone; prefer source + manifest | Yes |
| [no extension]/unknown | 133 no-extension entries | Unknown; Generated/Volatile | unknown | unknown | unknown | unknown | Manual review | Any content/mtime change | Quarantine from runtime assumptions | Unknown |


### Important file and pattern classification

| File / pattern | Evidence / role | Classification | Risk | Authority source | Safe-to-cache | Write sensitivity | Refresh condition | Invalidation condition | Failure behavior recommendation | Stale dangerous? |
|---|---|---|---|---|---|---|---|---|---|---|
| AI\main_ea.mq5 | Primary MT5 EA entrypoint; has OnInit/OnTick/OnTimer and 49 include directives | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | source hash/mtime | any source/include or compiled binary mismatch | Do not modify; block implementation until boundary confirmed | Yes |
| AI\main_ea.ex5 | Compiled EA artifact | MT5 Runtime Layer; Generated/Volatile | execution-critical; generated/volatile | generated by MT5 compiler | unsafe | write-sensitive | compile output refresh | source/binary mismatch | Do not decompile or treat as plan authority | Yes |
| AI\config_loader.mqh | Runtime config loader; uses FileOpen | MT5 Runtime Layer; Configuration Layer | execution-critical; config-critical | MT5-owned/source-controlled | conditional | read-only | source hash/mtime | config path/schema changes | Fail closed on config ambiguity | Yes |
| AI\core_trade_engine.mqh | Trade engine module; includes Trade/Trade.mqh and uses CTrade/Position concepts | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | source hash/mtime | trade engine source/include change | Do not alter; runtime owner remains MT5 | Yes |
| AI\storage_reset_pre_strategy_memory_v1.mqh | Contains FileDelete/FileOpen functions for memory reset paths | MT5 Runtime Layer; State/Status Layer | execution-critical; state-critical | MT5-owned/source-controlled | unsafe/conditional | read-only | source hash/mtime | any reset path change | Do not run or modify in discovery | Yes |
| AI\ai_bridge.mqh | AI bridge module; contains WebRequest usage | MT5 Runtime Layer; EXE Application Layer boundary candidate | execution-critical; config-critical | MT5-owned/source-controlled | conditional | read-only | source hash/mtime | bridge endpoint/config change | Treat as advisory bridge only until authority confirmed | Yes |
| AI\runtime_governance_status.json/.txt | Runtime governance status surface | State/Status Layer | state-critical | MT5-owned/generated | conditional | volatile | MT5 write mtime/hash | stale age, parse mismatch, MT5 restart | Fail closed for execution decision consumers; dashboard stale badge | Yes |
| AI\execution_authority_status.json/.txt | Execution authority status surface | State/Status Layer | state-critical; execution-critical reporting | MT5-owned/generated | conditional | volatile | MT5 write mtime/hash | stale age, parse mismatch | Fail closed for any authority consumer | Yes |
| AI\active_operating_cohort.json/.txt | Operating cohort status | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | MT5 write mtime/hash | stale/missing/cohort mismatch | Fail closed for authority assumptions | Yes |
| AI\ai_current_plan.json | Runtime plan/config surface; strict JSON parser flagged invalid escaping in archive | Configuration Layer | config-critical | human-owned/generated unknown | unsafe/conditional | write-sensitive | mtime/hash plus parser/schema validation | parse failure, plan version change, MT5 reload | Do not silently default; needs human confirmation | Yes |
| AI\ai_runtime_secrets.json | Runtime secret/config placeholder surface | Configuration Layer | config-critical | human-owned | unsafe | write-sensitive | explicit operator rotation/reload only | any write or secret-status change | Never cache secrets longer than process need; redact in reports | Yes |
| AI\ai_performance_journal.jsonl | Large append-only runtime journal; AGENTS marks live-locked during live operation | State/Status Layer; Report/Memory Layer; Generated/Volatile | state-critical; generated/volatile | MT5-owned/generated | unsafe | volatile | append cursor/tail only; cold snapshot preferred | append/truncation/rotation/lock | Do not repeatedly read/copy/zip live; tolerate unavailable | Yes |
| AI\council_feedback.json | Large feedback/memory artifact consumed/referenced by runtime modules | Report/Memory Layer; State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | write-sensitive/volatile | mtime/hash, schema validation | feedback append/write, parse mismatch | Treat as evidence/state; do not rewrite | Yes |
| AI\dashboard_* files and dashboard_*.mqh | Internal dashboard sources/status/UI state/snapshots | EXE Application Layer; State/Status Layer; MT5 Runtime Layer | visibility-only; execution-critical if MQL included | MT5-owned/generated/human-owned | conditional | write-sensitive/volatile | dashboard refresh/mtime | source/status mismatch, stale dashboard source | Dashboard unavailable; never runtime truth | Yes if misused |
| AI\external_dashboard\app\sources.py | FastAPI artifact store with mtime-based JSON/JSONL cache and missing-file tolerance | EXE Application Layer; Dashboard strategy | visibility-only | human-owned source | conditional | read-only for display app | source hash/mtime and app restart | source edit, cache key mtime mismatch | Return UNAVAILABLE; no write-back | Yes if used by runtime |
| AI\external_dashboard\tools\atas_live_capture_monitor.py | Tool writes ATAS live capture snapshots/event stream under Files/AI | EXE Application Layer; Generated/Volatile; State/Status Layer | state-critical; generated/volatile | tool-generated | unsafe/conditional | volatile | tool cycle/update mtime | new snapshot/event/stop/lock | Do not run in discovery; mark outputs volatile | Yes if treated as authority |
| AI\external_dashboard\tools\atas_live_propagation_runner.py | Tool can run external exporter/adapter commands and write runner status/events/stop/lock | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; config-critical; generated/volatile | tool-generated | unsafe/conditional | volatile | runner cycle, command completion | lock/stop/status changes; command failures | Do not run in discovery; require isolated future task | Yes |
| AI\external_adapter\atas_semantic_adapter | C# adapter source/bin/obj/runtime examples for ATAS producer/exporter/adapter | EXE Application Layer; Configuration Layer; State/Status Layer | config-critical; state-critical; generated/volatile | external/tool-owned; generated; human-owned config examples | conditional | write-sensitive | build/run output mtime/hash | config/source/binary mismatch or new runtime output | Bounded external advisory only; never execution authority | Yes if promoted to authority |
| AI\edge_factory\** | Factory registries/maps/status artifacts referenced by source registry/runtime dashboards | Report/Memory Layer; State/Status Layer; Configuration Layer | visibility-only; state-critical/unknown | generated/unknown | conditional | write-sensitive | factory process output mtime/hash | schema mismatch; status change; missing status | Visible only unless code proves runtime authority | Yes |
| AI\PROJECT_INTELLIGENCE_MEMORY_LAYER.md | Long-term project memory | Report/Memory Layer; Archive/Documentation | report-only | human/generated | conditional | read-only | document update | new memory update | Use as memory context, not runtime truth | Conditional |
| AI\OPERATION_GUARDRAILS.md; AI\AGENTS.md | Workspace governance/operating rules; read during discovery | Archive/Documentation; Codex Execution Layer | config-critical for Codex behavior; report-only for runtime | human-owned | conditional | read-only | document hash/mtime | governance doc change | Honor for future Codex tasks; do not override runtime status | Yes for operator process |


### MT5 source inventory

All `.mq5` and `.mqh` entries in the archive are listed below. No source file was modified.

| File | Size bytes | Classification | Risk | Authority source | Safe-to-cache | Write sensitivity | Refresh condition | Invalidation condition | Failure behavior recommendation | Stale dangerous? |
|---|---:|---|---|---|---|---|---|---|---|---|
| AI\ai_bridge.mqh | 8450 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\ai_evolution_engine.mqh | 57906 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_governed_advisory_artifacts.mqh | 27612 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_governed_advisory_contract.mqh | 18883 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_governed_advisory_layer.mqh | 50600 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_intake_layer.mqh | 30001 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_governed_advisory_artifacts.mqh | 27612 | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | unknown/generated archive of MT5 source | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_governed_advisory_contract.mqh | 18883 | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | unknown/generated archive of MT5 source | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_governed_advisory_layer.mqh | 50402 | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | unknown/generated archive of MT5 source | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_intake_layer.mqh | 31961 | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | unknown/generated archive of MT5 source | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_runtime_contract.mqh | 10079 | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | unknown/generated archive of MT5 source | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\main_ea.mq5 | 620534 | Archive/Documentation; MT5 Runtime Layer | archive-only; execution-critical if reactivated | unknown/generated archive of MT5 source | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\atas_runtime_contract.mqh | 10278 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\config_loader.mqh | 47753 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\core_logger.mqh | 827 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\core_market_data.mqh | 1183 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\core_trade_engine.mqh | 29932 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\correlation_engine.mqh | 13926 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_adaptive_weights.mqh | 4799 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_aggregator.mqh | 15483 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_ai_governor.mqh | 17817 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_attribution_intelligence.mqh | 7736 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_environment.mqh | 23311 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_failure_detector.mqh | 9892 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_feedback.mqh | 16994 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_feedback_memory.mqh | 17651 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_governor.mqh | 5731 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_memory.mqh | 59347 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_mode_logger.mqh | 11085 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_mode_runtime.mqh | 22774 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_mode_types.mqh | 34884 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_pre_ai_filter.mqh | 14278 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_pre_ai_gate.mqh | 8924 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_strategies.mqh | 91824 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\council_txt_reporter.mqh | 28012 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_contract.mqh | 5147 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_guardrails.mqh | 1213 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_navigation_controller.mqh | 18228 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_renderer.mqh | 24662 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_snapshot_exporter.mqh | 4052 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_source_registry.mqh | 16459 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_state_classifier.mqh | 33352 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_state_collector.mqh | 29203 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\dashboard_view_model.mqh | 67138 | MT5 Runtime Layer; Dashboard/visibility | visibility-only plus execution-critical if included in EA | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\decision_mode_router.mqh | 5867 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\evolution_governor.mqh | 14037 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\execution_estimator_v1.mqh | 6966 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\exit_intelligence.mqh | 3397 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\failure_taxonomy.mqh | 6067 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\institutional_learning_layer_v1.mqh | 77045 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\journal_analytics.mqh | 78726 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\level_awareness_brake.mqh | 20535 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\LIBRARIES\library_entry_patterns.mqh | 4133 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\LIBRARIES\library_filters.mqh | 2753 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\LIBRARIES\library_indicators.mqh | 5046 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\LIBRARIES\library_risk_models.mqh | 2797 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\LIBRARIES\library_strategies.mqh | 8014 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\main_ea.mq5 | 631146 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\market_regime.mqh | 5247 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\performance_journal.mqh | 130633 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\performance_memory.mqh | 9176 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\plan_auto_apply.mqh | 7524 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\plan_validator.mqh | 21194 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\regime_classification_layer_v1.mqh | 8581 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\risk_state_policy_engine.mqh | 9613 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\rollback_engine.mqh | 6611 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\rollback_signal_engine.mqh | 2351 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\runtime_honesty_surfaces.mqh | 72485 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\shadow_policy_mirroring.mqh | 10779 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\shadow_replay_engine.mqh | 19671 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\storage_reset_pre_strategy_memory_v1.mqh | 4101 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\strategy_compiler.mqh | 20696 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\strategy_confidence_memory_v1.mqh | 14554 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\strategy_intelligence_layer_v1.mqh | 26928 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\strategy_runtime.mqh | 44618 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\structural_sr_engine.mqh | 33820 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\trade_feedback.mqh | 52076 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |
| AI\unified_confidence.mqh | 7929 | MT5 Runtime Layer | execution-critical | MT5-owned/source-controlled | conditional | read-only | Source hash/mtime change | Include graph or source edit | Do not modify in Stage 0 | Yes |


### Include graph summary

| Source file | Include count | First includes observed |
|---|---:|---|
| AI\main_ea.mq5 | 49 | `Trade/Trade.mqh, trade_feedback.mqh, market_regime.mqh, regime_classification_layer_v1.mqh, strategy_intelligence_layer_v1.mqh, execution_estimator_v1.mqh, unified_confidence.mqh, institutional_learning_layer_v1.mqh, performance_journal.mqh, level_awareness_brake.mqh, storage_reset_pre_strategy_memory_v1.mqh, strategy_confidence_memory_v1.mqh ...` |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\main_ea.mq5 | 48 | `Trade/Trade.mqh, trade_feedback.mqh, market_regime.mqh, regime_classification_layer_v1.mqh, strategy_intelligence_layer_v1.mqh, execution_estimator_v1.mqh, unified_confidence.mqh, institutional_learning_layer_v1.mqh, performance_journal.mqh, level_awareness_brake.mqh, storage_reset_pre_strategy_memory_v1.mqh, strategy_confidence_memory_v1.mqh ...` |
| AI\council_mode_runtime.mqh | 12 | `council_mode_types.mqh, core_market_data.mqh, council_environment.mqh, council_strategies.mqh, council_aggregator.mqh, council_pre_ai_filter.mqh, council_memory.mqh, council_failure_detector.mqh, council_ai_governor.mqh, council_feedback.mqh, council_txt_reporter.mqh, council_attribution_intelligence.mqh` |
| AI\shadow_replay_engine.mqh | 9 | `config_loader.mqh, strategy_compiler.mqh, decision_mode_router.mqh, regime_classification_layer_v1.mqh, unified_confidence.mqh, strategy_intelligence_layer_v1.mqh, execution_estimator_v1.mqh, performance_journal.mqh, shadow_policy_mirroring.mqh` |
| AI\performance_journal.mqh | 6 | `core_logger.mqh, config_loader.mqh, decision_mode_router.mqh, regime_classification_layer_v1.mqh, unified_confidence.mqh, trade_feedback.mqh` |
| AI\strategy_compiler.mqh | 6 | `LIBRARIES/library_indicators.mqh, LIBRARIES/library_strategies.mqh, LIBRARIES/library_entry_patterns.mqh, LIBRARIES/library_risk_models.mqh, LIBRARIES/library_filters.mqh, config_loader.mqh` |
| AI\ai_evolution_engine.mqh | 5 | `config_loader.mqh, ai_bridge.mqh, evolution_governor.mqh, journal_analytics.mqh, performance_journal.mqh` |
| AI\risk_state_policy_engine.mqh | 5 | `config_loader.mqh, performance_memory.mqh, regime_classification_layer_v1.mqh, unified_confidence.mqh, journal_analytics.mqh` |
| AI\strategy_intelligence_layer_v1.mqh | 5 | `core_market_data.mqh, regime_classification_layer_v1.mqh, market_regime.mqh, strategy_runtime.mqh, execution_estimator_v1.mqh` |
| AI\trade_feedback.mqh | 5 | `config_loader.mqh, market_regime.mqh, regime_classification_layer_v1.mqh, exit_intelligence.mqh, journal_analytics.mqh` |
| AI\atas_governed_advisory_layer.mqh | 4 | `decision_mode_router.mqh, level_awareness_brake.mqh, atas_governed_advisory_contract.mqh, atas_governed_advisory_artifacts.mqh` |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_governed_advisory_layer.mqh | 4 | `decision_mode_router.mqh, level_awareness_brake.mqh, atas_governed_advisory_contract.mqh, atas_governed_advisory_artifacts.mqh` |
| AI\correlation_engine.mqh | 4 | `core_logger.mqh, performance_journal.mqh, trade_feedback.mqh, journal_analytics.mqh` |
| AI\council_environment.mqh | 4 | `council_mode_types.mqh, atas_intake_layer.mqh, market_regime.mqh, core_market_data.mqh` |
| AI\council_txt_reporter.mqh | 4 | `config_loader.mqh, council_mode_types.mqh, council_feedback.mqh, council_memory.mqh` |
| AI\decision_mode_router.mqh | 4 | `strategy_runtime.mqh, council_mode_types.mqh, council_mode_runtime.mqh, council_adaptive_weights.mqh` |
| AI\execution_estimator_v1.mqh | 4 | `core_market_data.mqh, market_regime.mqh, regime_classification_layer_v1.mqh, strategy_runtime.mqh` |
| AI\institutional_learning_layer_v1.mqh | 4 | `config_loader.mqh, decision_mode_router.mqh, trade_feedback.mqh, unified_confidence.mqh` |
| AI\shadow_policy_mirroring.mqh | 4 | `config_loader.mqh, regime_classification_layer_v1.mqh, risk_state_policy_engine.mqh, core_trade_engine.mqh` |
| AI\council_memory.mqh | 3 | `council_mode_types.mqh, config_loader.mqh, journal_analytics.mqh` |
| AI\council_strategies.mqh | 3 | `council_mode_types.mqh, council_environment.mqh, strategy_runtime.mqh` |
| AI\exit_intelligence.mqh | 3 | `core_logger.mqh, trade_feedback.mqh, regime_classification_layer_v1.mqh` |
| AI\failure_taxonomy.mqh | 3 | `trade_feedback.mqh, unified_confidence.mqh, regime_classification_layer_v1.mqh` |
| AI\plan_auto_apply.mqh | 3 | `plan_validator.mqh, config_loader.mqh, performance_memory.mqh` |
| AI\rollback_engine.mqh | 3 | `config_loader.mqh, performance_memory.mqh, plan_auto_apply.mqh` |
| AI\strategy_runtime.mqh | 3 | `strategy_compiler.mqh, core_market_data.mqh, market_regime.mqh` |
| AI\ai_bridge.mqh | 2 | `config_loader.mqh, core_market_data.mqh` |
| AI\core_trade_engine.mqh | 2 | `Trade/Trade.mqh, journal_analytics.mqh` |
| AI\council_adaptive_weights.mqh | 2 | `core_logger.mqh, council_mode_types.mqh` |
| AI\council_aggregator.mqh | 2 | `council_mode_types.mqh, council_adaptive_weights.mqh` |
| AI\council_failure_detector.mqh | 2 | `council_mode_types.mqh, council_memory.mqh` |
| AI\council_feedback.mqh | 2 | `config_loader.mqh, council_mode_types.mqh` |
| AI\council_feedback_memory.mqh | 2 | `council_mode_types.mqh, config_loader.mqh` |
| AI\council_mode_logger.mqh | 2 | `council_mode_types.mqh, config_loader.mqh` |
| AI\council_mode_types.mqh | 2 | `config_loader.mqh, atas_runtime_contract.mqh` |
| AI\dashboard_state_collector.mqh | 2 | `config_loader.mqh, dashboard_source_registry.mqh` |
| AI\level_awareness_brake.mqh | 2 | `council_mode_types.mqh, structural_sr_engine.mqh` |
| AI\regime_classification_layer_v1.mqh | 2 | `core_market_data.mqh, market_regime.mqh` |
| AI\rollback_signal_engine.mqh | 2 | `core_logger.mqh, journal_analytics.mqh` |
| AI\strategy_confidence_memory_v1.mqh | 2 | `core_logger.mqh, council_mode_types.mqh` |
| AI\atas_governed_advisory_artifacts.mqh | 1 | `atas_governed_advisory_contract.mqh` |
| AI\atas_intake_layer.mqh | 1 | `atas_runtime_contract.mqh` |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_governed_advisory_artifacts.mqh | 1 | `atas_governed_advisory_contract.mqh` |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_intake_layer.mqh | 1 | `atas_runtime_contract.mqh` |
| AI\atas_micro_baseline\p0p1_20260410_171057\payload\src\atas_runtime_contract.mqh | 1 | `config_loader.mqh` |
| AI\atas_runtime_contract.mqh | 1 | `config_loader.mqh` |
| AI\council_ai_governor.mqh | 1 | `council_mode_types.mqh` |
| AI\council_attribution_intelligence.mqh | 1 | `council_mode_types.mqh` |
| AI\council_governor.mqh | 1 | `council_mode_types.mqh` |
| AI\council_pre_ai_filter.mqh | 1 | `council_mode_types.mqh` |
| AI\council_pre_ai_gate.mqh | 1 | `council_mode_types.mqh` |
| AI\dashboard_guardrails.mqh | 1 | `dashboard_view_model.mqh` |
| AI\dashboard_navigation_controller.mqh | 1 | `dashboard_snapshot_exporter.mqh` |
| AI\dashboard_renderer.mqh | 1 | `dashboard_navigation_controller.mqh` |
| AI\dashboard_snapshot_exporter.mqh | 1 | `dashboard_guardrails.mqh` |
| AI\dashboard_source_registry.mqh | 1 | `dashboard_contract.mqh` |
| AI\dashboard_state_classifier.mqh | 1 | `dashboard_state_collector.mqh` |
| AI\dashboard_view_model.mqh | 1 | `dashboard_state_classifier.mqh` |
| AI\evolution_governor.mqh | 1 | `config_loader.mqh` |
| AI\journal_analytics.mqh | 1 | `core_logger.mqh` |
| AI\market_regime.mqh | 1 | `core_market_data.mqh` |
| AI\performance_memory.mqh | 1 | `config_loader.mqh` |
| AI\plan_validator.mqh | 1 | `config_loader.mqh` |
| AI\storage_reset_pre_strategy_memory_v1.mqh | 1 | `core_logger.mqh` |
| AI\unified_confidence.mqh | 1 | `strategy_runtime.mqh` |


### MQL file I/O and external-hook findings

- `.mq5/.mqh` source files scanned: 78.
- Source files with `FileOpen`/file API usage: 28.
- Source files with `WebRequest`: 1; observed in `AI\ai_bridge.mqh`.
- `main_ea.mq5` contains lifecycle/timer handlers and is the primary source boundary for runtime event flow.
- No `ShellExecute`, `CreateProcess`, or obvious WinAPI process-launch hook was detected in MQL source by Stage 0 text scan.
- No MQL `GlobalVariable*` usage was detected by Stage 0 text scan.
- External process/tool hooks do exist outside MQL in PowerShell/Python/.NET tooling.

### Runtime/file surfaces referenced by MQL source

Unique `AI\...` data/status/config/report paths referenced by MQL scan: **117**.  
Present in archive: **100**.  
Referenced but missing from archive: **17**.

| Referenced path | Archive status | Classification | Risk | Authority source | Safe-to-cache | Write sensitivity | Refresh condition | Invalidation condition | Failure behavior recommendation | Stale dangerous? |
|---|---|---|---|---|---|---|---|---|---|---|
| AI\active_operating_cohort.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\active_operating_cohort.txt | present | State/Status Layer; Archive/Documentation | state-critical; report-only | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_activation_readiness_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_activation_readiness_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_current_plan.json | present | Configuration Layer | config-critical | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\ai_decision_envelope_observability_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_decision_envelope_trace.jsonl | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | unsafe | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_evolution_state.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_governor_state.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_institutional_learning_decision_context.jsonl | present | Unknown | unknown | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\ai_institutional_learning_events.jsonl | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_institutional_learning_lineage_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_institutional_learning_memory.json | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_institutional_learning_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_institutional_learning_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_institutional_learning_trade_lineage.jsonl | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | unsafe | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_journal_rejects.txt | MISSING in archive; referenced by MQL | Report/Memory Layer; Archive/Documentation | state-critical; report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\ai_last_evolution_raw.txt | MISSING in archive; referenced by MQL | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\ai_last_recorded_council_close_deal.txt | present | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\ai_last_recorded_feedback_deal.txt | present | Report/Memory Layer; Archive/Documentation | state-critical; report-only | generated/MT5-owned/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\ai_last_recorded_feedback_order.txt | MISSING in archive; referenced by MQL | Report/Memory Layer; Archive/Documentation | state-critical; report-only | generated/MT5-owned/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\ai_last_recorded_feedback_position.txt | MISSING in archive; referenced by MQL | Report/Memory Layer; Archive/Documentation | state-critical; report-only | generated/MT5-owned/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\ai_next_plan_proposal.json | present | Unknown | unknown | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\ai_operational_review_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_operational_review_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_performance_journal.jsonl | present | Report/Memory Layer | state-critical | generated/MT5-owned/unknown | unsafe | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\ai_personality_profile.json | present | Configuration Layer | config-critical | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\ai_previous_plan_backup.json | present | Unknown | unknown | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\ai_rollback_state.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\ai_runtime_secrets.json | present | Configuration Layer | config-critical | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\ai_strategy_memory.json | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_strategy_memory_events.jsonl | present | State/Status Layer; Report/Memory Layer | state-critical; report-only | generated/MT5-owned/unknown | unsafe | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_trade_evidence_completeness_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\ai_trade_feedback.json | present | Report/Memory Layer | state-critical | generated/MT5-owned/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\atas_governed_advisory_effectiveness.json | present | State/Status Layer; EXE Application Layer | visibility-only; state-critical | external/generated/MT5-consumed unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_governed_advisory_effectiveness.txt | present | State/Status Layer; EXE Application Layer; Archive/Documentation | visibility-only; state-critical; report-only | external/generated/MT5-consumed unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_governed_advisory_last_packet.json | present | State/Status Layer; EXE Application Layer | visibility-only; state-critical | external/generated/MT5-consumed unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_governed_advisory_status.json | present | State/Status Layer; EXE Application Layer | state-critical; visibility-only | external/generated/MT5-consumed unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_governed_advisory_status.txt | present | State/Status Layer; EXE Application Layer | state-critical; visibility-only | external/generated/MT5-consumed unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_microstructure_context.json | present | State/Status Layer; EXE Application Layer | visibility-only; state-critical | external/generated/MT5-consumed unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_microstructure_status.json | present | State/Status Layer; EXE Application Layer | state-critical; visibility-only | external/generated/MT5-consumed unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_runtime_context.json | present | State/Status Layer; EXE Application Layer | visibility-only; state-critical | external/generated/MT5-consumed unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\atas_runtime_context_status.json | present | State/Status Layer; EXE Application Layer | state-critical; visibility-only | external/generated/MT5-consumed unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as bounded context; MT5 continues independently | Yes if advisory treated as authority |
| AI\council_activation_pressure_status.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_activation_pressure_status.txt | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_ai_advisory_effectiveness.json | present | Unknown | unknown | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\council_ai_advisory_effectiveness.txt | present | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\council_ai_advisory_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_ai_advisory_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_audit_summary.json | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\council_audit_summary.txt | present | Report/Memory Layer; Archive/Documentation | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\council_dirty_environment_status.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_dirty_environment_status.txt | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_execution_quality_status.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_execution_quality_status.txt | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_feedback.json | present | Report/Memory Layer | state-critical | generated/MT5-owned/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Yes |
| AI\council_live_exit_state.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_live_exit_status.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_live_exit_status.txt | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_memory.txt | present | Report/Memory Layer; Archive/Documentation | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\council_report.txt | present | Report/Memory Layer; Archive/Documentation | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\council_setup_lifecycle_state.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_setup_lifecycle_status.txt | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_trend_cont_confirmation_status.json | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\council_trend_cont_confirmation_status.txt | MISSING in archive; referenced by MQL | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\dashboard_local_ui_state.json | present | State/Status Layer; EXE Application Layer | state-critical; visibility-only | generated/human-owned | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Dashboard unavailable/stale; never runtime authority | Yes if treated as runtime truth |
| AI\dashboard_phase0_status.json | present | State/Status Layer; EXE Application Layer | state-critical; visibility-only | generated/human-owned | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Dashboard unavailable/stale; never runtime authority | Yes if treated as runtime truth |
| AI\dashboard_visible_snapshot_latest.txt | present | EXE Application Layer; State/Status Layer; Archive/Documentation | visibility-only; report-only | generated/human-owned | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Dashboard unavailable/stale; never runtime authority | Yes if treated as runtime truth |
| AI\diagnostic_runtime_summary.json | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\diagnostic_runtime_summary.txt | present | Report/Memory Layer; Archive/Documentation | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\docs\export_release_gate_contract.txt | present | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\docs\factory_truth_vocabulary_contract.txt | present | Report/Memory Layer; State/Status Layer; Archive/Documentation | visibility-only; unknown; report-only | generated/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\docs\security_containment_secret_hygiene_remediation.txt | present | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\docs\strategy_transfer_pilot_evidence_design_contract.txt | present | Report/Memory Layer; Archive/Documentation | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\edge_factory\decomposition\decomposition_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; visibility-only; unknown | generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\edge_factory_manifest.json | present | Report/Memory Layer; State/Status Layer | visibility-only; unknown | generated/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\internal_intelligence\internal_factory_intelligence_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; visibility-only; unknown | generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\registry\factory_intake_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; visibility-only; unknown | generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\registry\material_registry.json | present | Report/Memory Layer; State/Status Layer | visibility-only; unknown | generated/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\registry\source_intake_gateway.json | present | Report/Memory Layer; State/Status Layer | visibility-only; unknown | generated/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\registry\source_intake_gateway_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; visibility-only; unknown | generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\edge_factory\registry\source_intake_gateway_status.txt | present | State/Status Layer; Report/Memory Layer | state-critical; visibility-only; unknown | generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\execution_authority_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\execution_authority_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\execution_quality_validation.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\execution_quality_validation.txt | present | State/Status Layer; Archive/Documentation | state-critical; report-only | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\export_release_gate_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\export_release_gate_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\factory_operational_evidence_status.json | present | State/Status Layer; Report/Memory Layer | state-critical; report-only; visibility-only; unknown | generated/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\factory_operational_evidence_status.txt | present | State/Status Layer; Report/Memory Layer | state-critical; report-only; visibility-only; unknown | generated/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Do not promote factory visibility to authority | Yes if used for runtime permission |
| AI\last_meaningful_runtime_event.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\last_meaningful_runtime_event.txt | present | State/Status Layer; Archive/Documentation | state-critical; report-only | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\operating_risk_envelope_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\operating_risk_envelope_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\operational_integrity_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\operational_integrity_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\operator_effective_configuration_note.txt | present | Configuration Layer; Archive/Documentation | config-critical; report-only | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\operator_effective_configuration_surface.json | present | Configuration Layer | config-critical | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\operator_input_truth_map.json | present | Configuration Layer | config-critical | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\operator_runtime_truth_note.txt | present | Configuration Layer; Archive/Documentation | config-critical; report-only | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |
| AI\replay_validation_summary.json | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\replay_validation_summary.txt | present | Report/Memory Layer; Archive/Documentation | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\risk_safety_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\risk_safety_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\runtime_governance_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\runtime_governance_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\runtime_honesty_note.txt | present | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\runtime_honesty_truth.json | present | Unknown | unknown | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\strategy_transfer_package5_pilot_cycle.json | present | Unknown | unknown | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\strategy_transfer_package5_pilot_cycle.txt | present | Archive/Documentation | report-only | unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | UNAVAILABLE/stale; do not infer | Conditional |
| AI\strategy_transfer_package5_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\strategy_transfer_package5_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\strategy_transfer_packageC_pilot_evidence_design.json | present | Report/Memory Layer | report-only | generated/MT5-owned/unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Treat as evidence only unless code proves runtime consumption | Conditional |
| AI\strategy_transfer_packageC_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\strategy_transfer_packageC_status.txt | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\strategy_transfer_runtime_freeze_status.json | present | State/Status Layer | state-critical | MT5-owned/generated/unknown | conditional | volatile | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for execution authority/status; show stale for dashboard | Yes |
| AI\threshold_ownership_registry.json | present | Configuration Layer | config-critical | human-owned / unknown | conditional | write-sensitive | mtime/hash; role-specific TTL; append cursor for jsonl | file write/append, parse error, schema mismatch, missing file, source-role uncertainty | Fail closed for runtime config consumption; do not silently default | Yes |


Referenced-but-missing runtime surfaces requiring human review:

- `AI\ai_journal_rejects.txt`
- `AI\ai_last_evolution_raw.txt`
- `AI\ai_last_recorded_feedback_order.txt`
- `AI\ai_last_recorded_feedback_position.txt`
- `AI\council_activation_pressure_status.json`
- `AI\council_activation_pressure_status.txt`
- `AI\council_dirty_environment_status.json`
- `AI\council_dirty_environment_status.txt`
- `AI\council_execution_quality_status.json`
- `AI\council_execution_quality_status.txt`
- `AI\council_live_exit_state.json`
- `AI\council_live_exit_status.json`
- `AI\council_live_exit_status.txt`
- `AI\council_setup_lifecycle_state.json`
- `AI\council_setup_lifecycle_status.txt`
- `AI\council_trend_cont_confirmation_status.json`
- `AI\council_trend_cont_confirmation_status.txt`

### Developer/build/operational tool inventory

| Tool / script | Role observed | Classification | Risk | Authority source | Cache/write notes |
|---|---|---|---|---|---|
| AI\atas_microstructure_phase2_kickoff_v1\tools\run_phase2_validation.ps1 | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase2_kickoff_v1\tools\validate_phase2_kickoff.py | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\build_phase3_closure_before_after_comparison.py | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\build_phase3_weekend_safe_prelive_pack.py | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\generate_phase3_candidate_bundle.py | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_1_refinement_cycles.ps1 | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_candidate_pipeline.ps1 | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\run_phase3_weekend_safe_prelive_pass.ps1 | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\atas_microstructure_phase3_sandbox_v1\tools\validate_phase3_candidate_bundle.py | phase validation/candidate package tool | Codex Execution Layer; Archive/Documentation | archive-only; unknown | human/tool-owned | Candidate/sandbox only unless explicitly promoted |
| AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\src\AtasObservationExporter.csproj | .NET adapter/exporter project | EXE Application Layer; Configuration Layer | config-critical; generated/volatile | human/tool-owned | Build/run outputs not runtime authority |
| AI\external_adapter\atas_semantic_adapter\future_exporter\src\AtasRealExporter.csproj | .NET adapter/exporter project | EXE Application Layer; Configuration Layer | config-critical; generated/volatile | human/tool-owned | Build/run outputs not runtime authority |
| AI\external_adapter\atas_semantic_adapter\producer_prototype\src\AtasProducerPrototype.csproj | .NET adapter/exporter project | EXE Application Layer; Configuration Layer | config-critical; generated/volatile | human/tool-owned | Build/run outputs not runtime authority |
| AI\external_adapter\atas_semantic_adapter\src\AtasSemanticAdapter.csproj | .NET adapter/exporter project | EXE Application Layer; Configuration Layer | config-critical; generated/volatile | human/tool-owned | Build/run outputs not runtime authority |
| AI\external_dashboard\app\__init__.py | read-only dashboard app source | EXE Application Layer; Dashboard/visibility | visibility-only | human/tool-owned | App display path should remain read-only |
| AI\external_dashboard\app\aggregator.py | read-only dashboard app source | EXE Application Layer; Dashboard/visibility | visibility-only | human/tool-owned | App display path should remain read-only |
| AI\external_dashboard\app\main.py | read-only dashboard app source | EXE Application Layer; Dashboard/visibility | visibility-only | human/tool-owned | App display path should remain read-only |
| AI\external_dashboard\app\sources.py | read-only dashboard app source | EXE Application Layer; Dashboard/visibility | visibility-only | human/tool-owned | App display path should remain read-only |
| AI\external_dashboard\run_atas_live_capture.ps1 | dashboard/ATAS operational tool | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; generated/volatile | human/tool-owned | Writes/controls capture or propagation outputs; future task needs explicit permission |
| AI\external_dashboard\run_atas_live_propagation.ps1 | dashboard/ATAS operational tool | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; generated/volatile | human/tool-owned | Writes/controls capture or propagation outputs; future task needs explicit permission |
| AI\external_dashboard\run_atas_periodic_validation.ps1 | dashboard/ATAS operational tool | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; generated/volatile | human/tool-owned | Writes/controls capture or propagation outputs; future task needs explicit permission |
| AI\external_dashboard\run_external_dashboard.ps1 | developer/build/validation tool | Codex Execution Layer | unknown | human/tool-owned | Do not run during Stage 0; inspect before future execution |
| AI\external_dashboard\stop_atas_live_propagation.ps1 | developer/build/validation tool | Codex Execution Layer | unknown | human/tool-owned | Do not run during Stage 0; inspect before future execution |
| AI\external_dashboard\tools\atas_live_capture_monitor.py | dashboard/ATAS operational tool | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; generated/volatile | human/tool-owned | Writes/controls capture or propagation outputs; future task needs explicit permission |
| AI\external_dashboard\tools\atas_live_propagation_runner.py | dashboard/ATAS operational tool | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; generated/volatile | human/tool-owned | Writes/controls capture or propagation outputs; future task needs explicit permission |
| AI\external_dashboard\tools\atas_periodic_propagation_validation.py | dashboard/ATAS operational tool | EXE Application Layer; Codex Execution Layer; Generated/Volatile | state-critical; generated/volatile | human/tool-owned | Writes/controls capture or propagation outputs; future task needs explicit permission |


### Executable/binary inventory

- MT5 compiled artifact:
  - `AI\main_ea.ex5` (3154604 bytes)
- Python virtual environment executables under `AI\external_dashboard\.venv\Scripts` and pip vendored launcher EXEs: 14 files.
- .NET adapter/exporter apphost/output EXEs under `AI\external_adapter\atas_semantic_adapter\**\bin` / `obj`: 6 files.
- .NET adapter/exporter DLLs under `AI\external_adapter\atas_semantic_adapter`: 16 files.

Binary/build outputs are generated/volatile and should not be used as canonical migration truth without source/build-manifest validation.

---

## EXE boundary definition

Stage 0 boundary definition only; no implementation exists in this change.

Proposed boundary discipline:

1. **MT5-owned / must remain in MT5 until explicitly governed otherwise**
   - Trade execution.
   - Runtime decision routing.
   - Risk envelope enforcement.
   - Governor authority.
   - Runtime status emission.
   - MQL config consumption semantics.
   - Active event loop and timer behavior.

2. **EXE-owned candidate responsibilities, discovery-only**
   - Read-only inventory, validation, and observability.
   - Optional future read-only RAM cache of selected config/status/report artifacts with strict invalidation.
   - Optional future developer tooling for schema validation and diff reporting.
   - Optional future dashboard serving, if kept display-only.

3. **Shared-boundary / needs explicit contract before any implementation**
   - Plan/config loading from `ai_current_plan.json` and related surfaces.
   - Runtime status mirroring.
   - AI/ATAS advisory packet consumption.
   - External adapter handoff files.
   - Any file currently written by MT5 or external tools.

4. **Forbidden at current stage**
   - EXE must not place trades.
   - EXE must not mutate runtime plan/config/state/status files.
   - EXE must not become source of execution authority.
   - EXE must not treat dashboard summaries as truth.
   - EXE must not write back to MT5 without a future explicit governed task.

Unknown / needs confirmation:

- Whether the future EXE is meant to replace only file I/O/cache behavior, only dashboard tooling, only developer validation tools, or a broader runtime-adjacent application.
- Whether the future EXE will be separate from existing `external_dashboard` and `external_adapter` code or evolve from them.
- Exact terminal runtime root and live MT5 state at migration time.

---

## RAM loading strategy

Discovery-only strategy; no loader was implemented.

Recommended cache posture by layer:

| Data class | RAM cache posture | Refresh condition | Invalidation condition | Failure behavior | Stale dangerous? |
|---|---|---|---|---|---|
| `.mq5/.mqh` source | Conditional for analysis/build planning only | Source mtime/hash | Any source/include change or active/archive ambiguity | Stop migration/build assumptions | Yes |
| `.ex5` compiled artifact | Unsafe as source of truth | Compile event only | Source/binary mismatch | Require compile provenance | Yes |
| Runtime authority/status JSON/TXT | Conditional, short-lived, mtime/hash/TTL-bound | MT5 write mtime/hash | Stale age, parse failure, schema mismatch, MT5 restart | Fail closed for authority; dashboard stale/unavailable | Yes |
| Plan/config/secrets | Unsafe or strict conditional | Explicit operator reload or mtime/hash | Any write, parse/schema failure, config role uncertainty | Fail closed; do not silently default | Yes |
| Journals/JSONL | Unsafe for full-cache; tail/cursor only | Append cursor/mtime | Append/truncate/rotate/lock | Tolerate unavailable; avoid retry loops on live lock | Yes |
| Dashboard-only local UI state | Conditional for UI only | UI file mtime | UI state file change | Reset UI view to default; no runtime effect | No unless misused |
| External adapter outputs | Conditional with strict role labels | Adapter output mtime/hash | Runner/tool write, stale age, source mismatch | Treat as bounded context unavailable | Yes if treated as authority |
| Docs/reports/forensics | Conditional for review only | Document/export mtime/hash | Superseding doc/export | Do not use as live truth | Conditional |
| Generated `.venv`, `.pyc`, bin/obj, logs | Unsafe as authority | Rebuild/reinstall/run | New build/run output | Ignore for runtime truth; rebuild from source if needed | Conditional |

Minimum future RAM-cache rules:

- Every cached item must carry path, size, mtime_ns, optional hash, parse/schema status, owner classification, and source layer.
- Any unknown authority source must remain `Unknown / needs confirmation`; do not promote by inference.
- Runtime authority/config/status cache must be fail-closed or unavailable, not default-positive.
- Dashboard cache must not feed runtime execution decisions.
- Generated/volatile files must never be cached as durable truth without explicit evidence.
- JSONL should be cursor/tail-based, not fully loaded by default.
- Live-locked journal handling must follow `AGENTS.md`.

---

## Dashboard strategy

Discovery-only strategy; no dashboard was implemented.

Observed dashboard assets:

- MQL dashboard modules: `dashboard_contract.mqh`, `dashboard_guardrails.mqh`, `dashboard_navigation_controller.mqh`, `dashboard_renderer.mqh`, `dashboard_snapshot_exporter.mqh`, `dashboard_source_registry.mqh`, `dashboard_state_classifier.mqh`, `dashboard_state_collector.mqh`, `dashboard_view_model.mqh`.
- Dashboard status/snapshot/local files: `dashboard_phase0_status.*`, `dashboard_phase1_status.*`, `dashboard_local_ui_state.json`, `dashboard_visible_snapshot_*`.
- External dashboard app: `AI\external_dashboard\app\main.py`, `sources.py`, `aggregator.py`, templates, static assets, scripts.
- External dashboard docs state it is local, read-only, non-authoritative observability.

Recommended dashboard posture:

- Preserve dashboard as read-only visibility.
- Treat dashboard outputs as derived, never runtime truth.
- Preserve missing-file and stale-file display behavior.
- Do not expose trade/risk/governor/config mutation controls.
- Do not write to MT5 runtime control surfaces.
- Separate dashboard cache from any future EXE runtime/config cache.
- Keep local UI state isolated from MT5 runtime authority.

Unknown / needs confirmation:

- Whether internal MQL dashboard rendering remains soft-disabled in current runtime; docs report that it was soft-disabled previously, but Stage 0 did not execute MT5.
- Whether external dashboard is actively used in production.
- Whether future EXE should absorb the external dashboard or remain separate.

---

## Developer tool strategy

Discovery-only strategy; no tool was executed.

Observed developer/operational tools:

- Python validation/candidate package tools under ATAS phase folders.
- PowerShell run/stop scripts for dashboard and ATAS live propagation/capture.
- FastAPI external dashboard source.
- .NET/C# ATAS adapter/exporter projects and generated bin/obj artifacts.
- `.claude`, `.continue`, `.vscode` developer configuration.
- Existing compile logs and build outputs.

Recommended tool posture:

- Future Codex tasks must read `AGENTS.md` and `OPERATION_GUARDRAILS.md` before edits.
- Future edits should use a governed backup strategy that does not modify runtime files and respects live-locked journal constraints.
- Do not run scripts that can write `AI\atas_live_capture`, adapter runtime outputs, status files, stop/lock files, or configs during discovery.
- Treat `.venv`, `.pyc`, bin/obj, `.exe`, `.dll`, `.pdb`, and cache files as generated/volatile.
- Prefer source files, docs, manifests, and explicit status contracts over binaries/build artifacts.
- Any future validation tool should be read-only by default and produce output outside runtime scope unless explicitly approved.

Unknown / needs confirmation:

- Which developer toolchain versions are authoritative for future EXE migration.
- Whether the existing FastAPI dashboard venv should be regenerated, ignored, or vendored.
- Whether .NET `net8.0`/`net10.0` artifacts are intentional production artifacts or build leftovers.

---

## Risks and mitigations

| Risk | Evidence | Mitigation |
|---|---|---|
| Accidentally changing trading logic | Active source contains 2 `.mq5`, 76 `.mqh`, primary `main_ea.mq5`, compiled `main_ea.ex5` | Stage 0 modifies only this plan; future tasks require source-hash validation and no MQL edits unless explicitly requested |
| EXE usurps MT5 authority | Guardrails state MT5 is sole runtime/decision/risk/governor/execution authority | EXE boundary must be read-only or explicitly governed; fail closed for authority ambiguity |
| Dashboard treated as truth | Dashboard docs say dashboard may describe posture but not change posture | Keep dashboard cache isolated and label as visibility-only |
| Generated files cached as durable truth | `.venv`, `.pyc`, bin/obj, logs, jsonl, ATAS capture files present | Classify generated/volatile as unsafe/conditional; invalidate on mtime/hash/append/tool run |
| Runtime status stale or missing | Many status surfaces are generated and volatile | Use mtime/hash/TTL, schema validation, fail closed for runtime status/config |
| Plan/config parser mismatch | Strict JSON parse failed for `ai_current_plan.json`, `ai_previous_plan_backup.json`, `ai_evolution_state.json` | Human review before EXE parser implementation; do not silently repair or rewrite |
| Secrets mishandled | `ai_runtime_secrets.json` exists | Redact; avoid durable RAM cache; never report secret values |
| Live journal lock/retry loops | `AGENTS.md` marks `ai_performance_journal.jsonl` as live-locked during live operation | Tail/cold snapshot only; no repeated retries; tolerate unavailable |
| External adapter outputs treated as execution authority | ATAS adapter/exporter and propagation tools write advisory/context artifacts | Keep ATAS bounded-context/shadow-only unless future governed change proves otherwise |
| Missing referenced files misunderstood | 17 referenced `AI\...` surfaces missing from archive | Treat as generated-on-demand or absent unknown; human review required |
| Archive/baseline source confused with active source | `atas_micro_baseline` contains archived MQL payload | Only `AI\main_ea.mq5` and active root modules are active unless human confirms otherwise |
| Tool scripts modify runtime outputs | Dashboard/ATAS tools contain write paths and process invocations | Do not run during discovery; require future explicit execution scope |

---

## Codex execution tasks

### Stage 0 completed in this update

- Read workspace governance docs available in the archive.
- Inspected archive tree metadata.
- Scanned `.mq5`/`.mqh` source for includes, file I/O APIs, lifecycle handlers, trade concepts, WebRequest, GlobalVariables, and process-launch hooks.
- Inventoried config/status/report/docs/logs/tool/build/generated artifacts.
- Classified relevant files/folders and important file types by layer, risk, authority, cache safety, write sensitivity, refresh/invalidation, failure behavior, and stale-data danger.
- Created `AI\MT5_EXE_MIGRATION_PLAN.md`.
- Did not modify `.mq5`, `.mqh`, configs, states, statuses, logs, reports, binaries, build files, or runtime files.

### Recommended next Codex task

Stage 1 should be a **read-only data-contract and authority map extraction** task:

- Do not implement EXE.
- Do not modify runtime/config/state files.
- Produce a separate contract map of every runtime-consumed file path, paired writer/reader, schema keys, authority class, stale threshold, parse behavior, and fail-closed rule.
- Confirm strict JSON validity and MQL parser expectations for `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json`.
- Confirm whether missing referenced surfaces are generated-on-demand, obsolete, or operationally missing.
- Confirm active terminal paths for `MQL5\Experts\AI` versus `MQL5\Files\AI`.

---

## Validation checklist

Stage 0 validation target:

- [x] `MT5_EXE_MIGRATION_PLAN.md` created because it did not exist.
- [x] No timestamped plan backup created because no existing plan file was found.
- [x] No `.mq5` file modified.
- [x] No `.mqh` file modified.
- [x] No trading logic modified.
- [x] No config/state/status/log/report/runtime file modified.
- [x] No executable/build/generated file modified.
- [x] No file moved or renamed.
- [x] No dashboard/RAM loader/developer tool implementation added.
- [x] All mandatory plan sections present.
- [x] Stage 0 content is discovery-only.
- [x] Unknown authority/freshness/cache cases marked as unknown or conditional rather than inferred as safe.

Hash validation recommendation for future local run:

1. Capture SHA-256 for all files before edit.
2. Edit only `MT5_EXE_MIGRATION_PLAN.md`.
3. Recompute SHA-256.
4. Confirm every original file hash is unchanged.
5. Confirm the only added/changed file is the plan and, if applicable, its timestamped backup.

---

## Rollback plan

Because no prior `MT5_EXE_MIGRATION_PLAN.md` existed in the archive, rollback for this Stage 0 update is:

1. Remove `AI\MT5_EXE_MIGRATION_PLAN.md` from the updated package if the discovery plan is rejected.
2. Keep the original uploaded archive as the source-of-truth rollback artifact.
3. If a future existing plan is updated, create `MT5_EXE_MIGRATION_PLAN.md.bak_YYYYMMDD_HHMMSS` before editing and restore from that backup if the update is wrong.
4. If any unexpected file is modified in a future task, revert all unexpected files immediately and report exact paths and hashes.

No runtime rollback is required for this Stage 0 archive update because no runtime/config/source/state/log files were modified.

---

## Open questions

- Unknown / needs confirmation: exact live MT5 terminal root and whether the uploaded archive corresponds to `MQL5\Experts\AI`, `MQL5\Files\AI`, or a merged project snapshot.
- Unknown / needs confirmation: whether MT5 is currently running and whether `ai_performance_journal.jsonl` is live-locked.
- Unknown / needs confirmation: intended scope of the future EXE: dashboard, RAM cache, developer validator, adapter supervisor, or runtime-adjacent service.
- Unknown / needs confirmation: whether future EXE should coexist with or replace `AI\external_dashboard`.
- Unknown / needs confirmation: whether future EXE should coexist with or replace any `.NET` adapter/exporter binaries.
- Unknown / needs confirmation: source-of-truth writer for each generated status surface.
- Unknown / needs confirmation: strict JSON validity expectations for `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json`.
- Unknown / needs confirmation: whether referenced-but-missing surfaces are expected generated-on-demand files, obsolete surfaces, or missing operational files.
- Unknown / needs confirmation: production status of `.venv`, `.exe`, `.dll`, `.pdb`, `.pyc`, `bin`, `obj`, and cache artifacts.
- Unknown / needs confirmation: authoritative stale thresholds for each runtime surface beyond those implied by dashboard code/docs.
- Unknown / needs confirmation: current internal dashboard rendering posture in live MT5.
- Unknown / needs confirmation: whether archived baseline MQL payloads should be excluded from future active-source migration scans.

---

## Progress log

| Date | Stage | Action | Files modified | Notes |
|---|---|---|---|---|
| 2026-04-25 | 0 | Created Stage 0 discovery plan from archive inspection | `AI\MT5_EXE_MIGRATION_PLAN.md` | Discovery-only. No trading/config/runtime/status/log/source modifications. |

PIML_READ: NO  
PIML_UPDATE: NO  
PIML_SECTIONS: N/A

---

## Completion criteria

Stage 0 is complete when:

- `MT5_EXE_MIGRATION_PLAN.md` exists.
- The plan includes all mandatory sections.
- The plan records the current architecture and file classifications based only on inspection.
- Uncertain ownership, authority, cache safety, freshness, invalidation, and write sensitivity are marked unknown or conditional.
- No `.mq5`, `.mqh`, trading logic, config, state/status, log, report, executable/build, or runtime files are modified.
- Validation confirms that the only added/modified project file is `AI\MT5_EXE_MIGRATION_PLAN.md` plus a timestamped plan backup only if a prior plan existed.
- The next task is clearly limited to read-only contract extraction unless the human explicitly authorizes implementation work.

---

## Stage 1 — Data Contract and Authority Map

Stage 1 discovery timestamp: `20260425_030157` Europe/Istanbul.


Scope: read-only static analysis and strict JSON compatibility audit. No EXE, RAM loader, dashboard implementation, adapter supervisor, developer tooling, trading logic, config, state, status, log, or JSON file was modified. Secret values were not written to this plan.


### Stage 1 inspection scope

- Source archive inspected: `pre_change_20260420_160325_plan5_stage1_unified_stage0_discovery.zip`.

- Files in archive: `2955` files plus directory entries.

- Root active MQL inspected: `67` root `.mq5/.mqh` files.

- Total source/static-analysis files inspected: `166` code files excluding `.venv`, `bin`, `obj`, and `__pycache__` generated files.

- Runtime/data path candidates mapped: `148`.

- Existing mapped paths: `128`. Missing mapped paths: `20`.

- MQL file I/O tokens found in root/source scan: `285` total occurrences including archive baseline duplicates; root MQL was used for the active map.


### 1. Runtime-consumed file path map

| referenced path as written | normalized project-relative path | exists | referenced by file/function | operation | expected format | MT5 direct dependency | EXE future access mode | criticality |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AI\active_operating_cohort.json | AI\active_operating_cohort.json | yes | AI\main_ea.mq5:2218 ActiveOperatingCohortStatusJsonPath()<br>AI\main_ea.mq5:2360 via ActiveOperatingCohortStatusJsonPath()<br>AI\main_ea.mq5:7169 via ActiveOperatingCohortStatusJsonPath()<br>…(+3) | path-def+write+read+existence+literal-ref | JSON object/array | yes | observe-only | execution-critical |
| AI\active_operating_cohort.txt | AI\active_operating_cohort.txt | yes | AI\main_ea.mq5:2217 ActiveOperatingCohortStatusTxtPath()<br>AI\main_ea.mq5:2359 via ActiveOperatingCohortStatusTxtPath()<br>AI\dashboard_state_collector.mqh:146<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | execution-critical |
| AI\ai_activation_readiness_status.json | AI\ai_activation_readiness_status.json | yes | AI\main_ea.mq5:2213 AIActivationReadinessStatusJsonPath()<br>AI\main_ea.mq5:6689 via AIActivationReadinessStatusJsonPath()<br>AI\main_ea.mq5:7011 via AIActivationReadinessStatusJsonPath()<br>…(+5) | path-def+write+read+existence+read+… | JSON object/array | yes | unknown | state-critical |
| AI\ai_activation_readiness_status.txt | AI\ai_activation_readiness_status.txt | yes | AI\main_ea.mq5:2212 AIActivationReadinessStatusTxtPath()<br>AI\main_ea.mq5:6688 via AIActivationReadinessStatusTxtPath()<br>AI\dashboard_state_collector.mqh:132<br>…(+1) | path-def+write+read | TXT key/value or report | yes | unknown | state-critical |
| AI\ai_current_plan.json | AI\ai_current_plan.json | yes | AI\main_ea.mq5:2202 TruthCurrentPlanPath()<br>AI\main_ea.mq5:5145 via TruthCurrentPlanPath()<br>AI\main_ea.mq5:8952 via TruthCurrentPlanPath()<br>…(+9) | path-def+read+existence+read+unknown+… | JSON object/array | yes | cache-read | execution-critical |
| AI\ai_decision_envelope_observability_status.json | AI\ai_decision_envelope_observability_status.json | yes | AI\performance_journal.mqh:47<br>AI\external_dashboard\app\aggregator.py:745 | literal-ref+dashboard-surface | JSON object/array | yes | unknown | state-critical |
| AI\ai_decision_envelope_trace.jsonl | AI\ai_decision_envelope_trace.jsonl | yes | AI\performance_journal.mqh:46<br>AI\external_dashboard\app\aggregator.py:136<br>AI\external_dashboard\app\aggregator.py:237<br>…(+4) | literal-ref+read+dashboard-surface | JSONL events | yes | unknown | unknown |
| AI\ai_evolution_state.json | AI\ai_evolution_state.json | yes | AI\main_ea.mq5:2203 TruthEvolutionStatePath()<br>AI\main_ea.mq5:5114 via TruthEvolutionStatePath()<br>AI\main_ea.mq5:5118 via TruthEvolutionStatePath()<br>…(+11) | path-def+existence-check+read+write+… | JSON object/array | yes | cache-read | state-critical |
| AI\ai_governor_state.json | AI\ai_governor_state.json | yes | AI\main_ea.mq5:12973<br>AI\storage_reset_pre_strategy_memory_v1.mqh:107 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\ai_institutional_learning_decision_context.jsonl | AI\ai_institutional_learning_decision_context.jsonl | yes | AI\institutional_learning_layer_v1.mqh:20<br>AI\external_dashboard\app\aggregator.py:241<br>AI\external_dashboard\app\aggregator.py:644<br>…(+2) | literal-ref+read+dashboard-surface | JSONL events | yes | unknown | unknown |
| AI\ai_institutional_learning_events.jsonl | AI\ai_institutional_learning_events.jsonl | yes | AI\institutional_learning_layer_v1.mqh:19<br>AI\external_dashboard\app\aggregator.py:233<br>AI\external_dashboard\app\aggregator.py:754<br>…(+1) | literal-ref+read+dashboard-surface | JSONL events | yes | unknown | unknown |
| AI\ai_institutional_learning_lineage_status.json | AI\ai_institutional_learning_lineage_status.json | yes | AI\institutional_learning_layer_v1.mqh:22<br>AI\external_dashboard\app\aggregator.py:740 | literal-ref+dashboard-surface | JSON object/array | yes | unknown | state-critical |
| AI\ai_institutional_learning_memory.json | AI\ai_institutional_learning_memory.json | yes | AI\institutional_learning_layer_v1.mqh:16<br>AI\external_dashboard\app\aggregator.py:753 | literal-ref+dashboard-surface | JSON object/array | yes | observe-only | state-critical |
| AI\ai_institutional_learning_status.json | AI\ai_institutional_learning_status.json | yes | AI\institutional_learning_layer_v1.mqh:17<br>AI\external_dashboard\app\aggregator.py:752 | literal-ref+dashboard-surface | JSON object/array | yes | unknown | state-critical |
| AI\ai_institutional_learning_status.txt | AI\ai_institutional_learning_status.txt | yes | AI\institutional_learning_layer_v1.mqh:18 | literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\ai_institutional_learning_trade_lineage.jsonl | AI\ai_institutional_learning_trade_lineage.jsonl | yes | AI\institutional_learning_layer_v1.mqh:21<br>AI\external_dashboard\app\aggregator.py:229<br>AI\external_dashboard\app\aggregator.py:739<br>…(+1) | literal-ref+read+dashboard-surface | JSONL events | yes | unknown | unknown |
| AI\ai_last_evolution_raw.txt | AI\ai_last_evolution_raw.txt | no | AI\main_ea.mq5:12977<br>AI\main_ea.mq5:12988<br>AI\storage_reset_pre_strategy_memory_v1.mqh:99 | literal-ref+read | TXT key/value or report | yes | unknown | unknown |
| AI\ai_last_recorded_council_close_deal.txt | AI\ai_last_recorded_council_close_deal.txt | yes | AI\main_ea.mq5:14703 | literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\ai_last_recorded_feedback_deal.txt | AI\ai_last_recorded_feedback_deal.txt | yes | AI\storage_reset_pre_strategy_memory_v1.mqh:100<br>AI\storage_reset_pre_strategy_memory_v1.mqh:111<br>AI\trade_feedback.mqh:10 | literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\ai_last_recorded_feedback_order.txt | AI\ai_last_recorded_feedback_order.txt | no | AI\storage_reset_pre_strategy_memory_v1.mqh:112 | literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\ai_last_recorded_feedback_position.txt | AI\ai_last_recorded_feedback_position.txt | no | AI\storage_reset_pre_strategy_memory_v1.mqh:113 | literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\ai_next_plan_proposal.json | AI\ai_next_plan_proposal.json | yes | AI\main_ea.mq5:12976<br>AI\main_ea.mq5:14972 | literal-ref | JSON object/array | yes | unknown | unknown |
| AI\ai_operational_review_status.json | AI\ai_operational_review_status.json | yes | AI\main_ea.mq5:2245 AIOperationalReviewJsonPath()<br>AI\main_ea.mq5:1290 via AIOperationalReviewJsonPath()<br>AI\main_ea.mq5:6219 via AIOperationalReviewJsonPath()<br>…(+5) | path-def+write+read+existence+existence-check+… | JSON object/array | yes | unknown | state-critical |
| AI\ai_operational_review_status.txt | AI\ai_operational_review_status.txt | yes | AI\main_ea.mq5:2244 AIOperationalReviewTxtPath()<br>AI\main_ea.mq5:1289 via AIOperationalReviewTxtPath()<br>AI\dashboard_state_collector.mqh:154<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\ai_performance_journal.jsonl | AI\ai_performance_journal.jsonl | yes | AI\council_memory.mqh:1095<br>AI\council_mode_runtime.mqh:558<br>AI\dashboard_source_registry.mqh:223<br>…(+21) | literal-ref+read | JSONL events | yes | observe-only | state-critical |
| AI\ai_personality_profile.json | AI\ai_personality_profile.json | yes | AI\main_ea.mq5:12605 | read | JSON object/array | yes | unknown | config-critical |
| AI\ai_previous_plan_backup.json | AI\ai_previous_plan_backup.json | yes | AI\main_ea.mq5:2204 TruthPreviousPlanBackupPath()<br>AI\main_ea.mq5:8981 via TruthPreviousPlanBackupPath()<br>AI\main_ea.mq5:2204<br>…(+1) | path-def+unknown+literal-ref | JSON object/array | yes | cache-read | unknown |
| AI\ai_rollback_state.json | AI\ai_rollback_state.json | yes | AI\rollback_engine.mqh:23 RollbackStatePath()<br>AI\main_ea.mq5:13017 via RollbackStatePath()<br>AI\main_ea.mq5:13054 via RollbackStatePath()<br>…(+18) | path-def+read+unknown+literal-ref | JSON object/array | yes | cache-read | execution-critical |
| AI\ai_runtime_secrets.json | AI\ai_runtime_secrets.json | yes | AI\main_ea.mq5:12606 | read | JSON object/array | yes | forbidden | config-critical |
| AI\ai_strategy_memory.json | AI\ai_strategy_memory.json | yes | AI\main_ea.mq5:12971<br>AI\storage_reset_pre_strategy_memory_v1.mqh:105<br>AI\strategy_confidence_memory_v1.mqh:8 | literal-ref | JSON object/array | yes | observe-only | state-critical |
| AI\ai_strategy_memory_events.jsonl | AI\ai_strategy_memory_events.jsonl | yes | AI\institutional_learning_layer_v1.mqh:23<br>AI\strategy_confidence_memory_v1.mqh:7<br>AI\external_dashboard\app\aggregator.py:245<br>…(+3) | literal-ref+read+dashboard-surface | JSONL events | yes | observe-only | state-critical |
| AI\ai_trade_evidence_completeness_status.json | AI\ai_trade_evidence_completeness_status.json | yes | AI\performance_journal.mqh:48<br>AI\external_dashboard\app\aggregator.py:743 | literal-ref+dashboard-surface | JSON object/array | yes | unknown | state-critical |
| AI\ai_trade_feedback.json | AI\ai_trade_feedback.json | yes | AI\dashboard_source_registry.mqh:213<br>AI\dashboard_source_registry.mqh:214<br>AI\main_ea.mq5:12974<br>…(+6) | literal-ref+read+dashboard-surface | JSON object/array | yes | observe-only | state-critical |
| AI\atas_governed_advisory_effectiveness.json | AI\atas_governed_advisory_effectiveness.json | yes | AI\atas_governed_advisory_artifacts.mqh:9 AtasGovernedAdvisoryEffectivenessJsonPath()<br>AI\atas_governed_advisory_artifacts.mqh:343 via AtasGovernedAdvisoryEffectivenessJsonPath()<br>AI\atas_governed_advisory_artifacts.mqh:9<br>…(+1) | path-def+write+literal-ref+dashboard-surface | JSON object/array | yes | observe-only | unknown |
| AI\atas_governed_advisory_effectiveness.txt | AI\atas_governed_advisory_effectiveness.txt | yes | AI\atas_governed_advisory_artifacts.mqh:8 AtasGovernedAdvisoryEffectivenessTxtPath()<br>AI\atas_governed_advisory_artifacts.mqh:342 via AtasGovernedAdvisoryEffectivenessTxtPath()<br>AI\atas_governed_advisory_artifacts.mqh:8 | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | unknown |
| AI\atas_governed_advisory_last_packet.json | AI\atas_governed_advisory_last_packet.json | yes | AI\atas_governed_advisory_artifacts.mqh:10 AtasGovernedAdvisoryLastPacketJsonPath()<br>AI\atas_governed_advisory_artifacts.mqh:344 via AtasGovernedAdvisoryLastPacketJsonPath()<br>AI\atas_governed_advisory_artifacts.mqh:10 | path-def+write+literal-ref | JSON object/array | yes | observe-only | unknown |
| AI\atas_governed_advisory_status.json | AI\atas_governed_advisory_status.json | yes | AI\atas_governed_advisory_artifacts.mqh:7 AtasGovernedAdvisoryStatusJsonPath()<br>AI\atas_governed_advisory_artifacts.mqh:341 via AtasGovernedAdvisoryStatusJsonPath()<br>AI\atas_governed_advisory_artifacts.mqh:7<br>…(+4) | path-def+write+literal-ref+read+… | JSON object/array | yes | observe-only | state-critical |
| AI\atas_governed_advisory_status.txt | AI\atas_governed_advisory_status.txt | yes | AI\atas_governed_advisory_artifacts.mqh:6 AtasGovernedAdvisoryStatusTxtPath()<br>AI\atas_governed_advisory_artifacts.mqh:340 via AtasGovernedAdvisoryStatusTxtPath()<br>AI\atas_governed_advisory_artifacts.mqh:6 | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\atas_live_capture\atas_live_chain_status.json | AI\atas_live_capture\atas_live_chain_status.json | yes | AI\external_dashboard\app\aggregator.py:1059<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:666 | read+write | JSON object/array | no | observe-only | state-critical |
| AI\atas_live_capture\atas_live_event_stream.jsonl | AI\atas_live_capture\atas_live_event_stream.jsonl | yes | AI\external_dashboard\app\aggregator.py:1062<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:689 | read+append | JSONL events | no | observe-only | visibility-only |
| AI\atas_live_capture\atas_live_field_inventory.json | AI\atas_live_capture\atas_live_field_inventory.json | yes | AI\external_dashboard\app\aggregator.py:1060<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:669 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\atas_propagation_runner.lock | AI\atas_live_capture\atas_propagation_runner.lock | no | AI\external_dashboard\tools\atas_live_propagation_runner.py:233/378 | write | sentinel/lock | no | forbidden | visibility-only |
| AI\atas_live_capture\atas_propagation_runner.stop | AI\atas_live_capture\atas_propagation_runner.stop | yes | AI\external_dashboard\tools\atas_live_propagation_runner.py:234 | read | sentinel/lock | no | forbidden | visibility-only |
| AI\atas_live_capture\atas_propagation_runner_events.jsonl | AI\atas_live_capture\atas_propagation_runner_events.jsonl | yes | AI\external_dashboard\tools\atas_live_propagation_runner.py:232 | append | JSONL events | no | observe-only | visibility-only |
| AI\atas_live_capture\atas_propagation_runner_status.json | AI\atas_live_capture\atas_propagation_runner_status.json | yes | AI\external_dashboard\tools\atas_live_propagation_runner.py:231 | write | JSON object/array | no | observe-only | state-critical |
| AI\atas_live_capture\freshness_isolation_report_latest.json | AI\atas_live_capture\freshness_isolation_report_latest.json | yes | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:651 | write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\freshness_isolation_report_{timestamp}.json | AI\atas_live_capture\freshness_isolation_report_{timestamp}.json | no | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:650 | write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_acquisition_input_snapshot.json | AI\atas_live_capture\latest_acquisition_input_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1068<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:635 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_adapter_snapshot.json | AI\atas_live_capture\latest_adapter_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1070<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:637 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_advisory_snapshot.json | AI\atas_live_capture\latest_advisory_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1073<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:650 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_context_snapshot.json | AI\atas_live_capture\latest_context_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1072<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:645 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_exporter_snapshot.json | AI\atas_live_capture\latest_exporter_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1067<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:634 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_mt5_intake_snapshot.json | AI\atas_live_capture\latest_mt5_intake_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1071<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:639 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_observation_snapshot.json | AI\atas_live_capture\latest_observation_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1066<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:633 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\latest_producer_input_snapshot.json | AI\atas_live_capture\latest_producer_input_snapshot.json | yes | AI\external_dashboard\app\aggregator.py:1069<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:636 | read+write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\periodic_validation_cycles_latest.jsonl | AI\atas_live_capture\periodic_validation_cycles_latest.jsonl | yes | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:647 | write | JSONL events | no | observe-only | visibility-only |
| AI\atas_live_capture\periodic_validation_cycles_{timestamp}.jsonl | AI\atas_live_capture\periodic_validation_cycles_{timestamp}.jsonl | no | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:646 | write | JSONL events | no | observe-only | visibility-only |
| AI\atas_live_capture\periodic_validation_summary_latest.json | AI\atas_live_capture\periodic_validation_summary_latest.json | yes | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:649 | write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_live_capture\periodic_validation_summary_{timestamp}.json | AI\atas_live_capture\periodic_validation_summary_{timestamp}.json | no | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:648 | write | JSON object/array | no | observe-only | visibility-only |
| AI\atas_microstructure_context.json | AI\atas_microstructure_context.json | yes | AI\atas_intake_layer.mqh:8 AtasRuntimeContextPath()<br>AI\atas_intake_layer.mqh:535 via AtasRuntimeContextPath()<br>AI\atas_intake_layer.mqh:8<br>…(+5) | path-def+read+literal-ref+dashboard-surface+… | JSON object/array | yes | observe-only | unknown |
| AI\atas_microstructure_status.json | AI\atas_microstructure_status.json | yes | AI\atas_intake_layer.mqh:9 AtasRuntimeContextStatusPath()<br>AI\atas_intake_layer.mqh:501 via AtasRuntimeContextStatusPath()<br>AI\atas_intake_layer.mqh:503 via AtasRuntimeContextStatusPath()<br>…(+7) | path-def+write+unknown+read+… | JSON object/array | yes | observe-only | state-critical |
| AI\atas_microstructure_writer_status.json | AI\atas_microstructure_writer_status.json | yes | AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\src\Config\AtasIndicatorExporterConfigLoader.cs:74 + Runtime.cs:139 | write | JSON object/array | no | observe-only | state-critical |
| AI\atas_runtime_context.json | AI\atas_runtime_context.json | yes | AI\atas_intake_layer.mqh:10 AtasRuntimeContextLegacyMirrorPath()<br>AI\atas_intake_layer.mqh:10<br>AI\main_ea.mq5:11314<br>…(+3) | path-def+literal-ref+dashboard-surface+write | JSON object/array | yes | observe-only | unknown |
| AI\atas_runtime_context_status.json | AI\atas_runtime_context_status.json | yes | AI\atas_intake_layer.mqh:11 AtasRuntimeContextStatusLegacyMirrorPath()<br>AI\atas_intake_layer.mqh:502 via AtasRuntimeContextStatusLegacyMirrorPath()<br>AI\atas_governed_advisory_layer.mqh:370<br>…(+4) | path-def+unknown+read+literal-ref+… | JSON object/array | yes | observe-only | state-critical |
| AI\council_activation_pressure_status.json | AI\council_activation_pressure_status.json | no | AI\main_ea.mq5:9361 CouncilActivationPressureStatusJsonPath()<br>AI\main_ea.mq5:9434 via CouncilActivationPressureStatusJsonPath()<br>AI\main_ea.mq5:9361 | path-def+write+literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\council_activation_pressure_status.txt | AI\council_activation_pressure_status.txt | no | AI\main_ea.mq5:9360 CouncilActivationPressureStatusTxtPath()<br>AI\main_ea.mq5:9433 via CouncilActivationPressureStatusTxtPath()<br>AI\main_ea.mq5:9360 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\council_ai_advisory_effectiveness.json | AI\council_ai_advisory_effectiveness.json | yes | AI\main_ea.mq5:2232 CouncilAIAdvisoryEffectivenessJsonPath()<br>AI\main_ea.mq5:7862 via CouncilAIAdvisoryEffectivenessJsonPath()<br>AI\main_ea.mq5:7934 via CouncilAIAdvisoryEffectivenessJsonPath()<br>…(+1) | path-def+write+read+existence+literal-ref | JSON object/array | yes | unknown | unknown |
| AI\council_ai_advisory_effectiveness.txt | AI\council_ai_advisory_effectiveness.txt | yes | AI\main_ea.mq5:2231 CouncilAIAdvisoryEffectivenessTxtPath()<br>AI\main_ea.mq5:7861 via CouncilAIAdvisoryEffectivenessTxtPath()<br>AI\main_ea.mq5:2231 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\council_ai_advisory_status.json | AI\council_ai_advisory_status.json | yes | AI\main_ea.mq5:2230 CouncilAIAdvisoryStatusJsonPath()<br>AI\main_ea.mq5:7856 via CouncilAIAdvisoryStatusJsonPath()<br>AI\main_ea.mq5:2230 | path-def+write+literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\council_ai_advisory_status.txt | AI\council_ai_advisory_status.txt | yes | AI\main_ea.mq5:2229 CouncilAIAdvisoryStatusTxtPath()<br>AI\main_ea.mq5:7855 via CouncilAIAdvisoryStatusTxtPath()<br>AI\main_ea.mq5:2229 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\council_audit_summary.json | AI\council_audit_summary.json | yes | AI\council_mode_runtime.mqh:566 | write | JSON object/array | yes | unknown | unknown |
| AI\council_audit_summary.txt | AI\council_audit_summary.txt | yes | AI\council_mode_runtime.mqh:565 | write | TXT key/value or report | yes | unknown | unknown |
| AI\council_dirty_environment_status.json | AI\council_dirty_environment_status.json | no | AI\main_ea.mq5:9461 CouncilDirtyEnvironmentStatusJsonPath()<br>AI\main_ea.mq5:9514 via CouncilDirtyEnvironmentStatusJsonPath()<br>AI\main_ea.mq5:9461 | path-def+write+literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\council_dirty_environment_status.txt | AI\council_dirty_environment_status.txt | no | AI\main_ea.mq5:9460 CouncilDirtyEnvironmentStatusTxtPath()<br>AI\main_ea.mq5:9513 via CouncilDirtyEnvironmentStatusTxtPath()<br>AI\main_ea.mq5:9460 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\council_execution_quality_status.json | AI\council_execution_quality_status.json | no | AI\main_ea.mq5:9271 CouncilExecutionQualityStatusJsonPath()<br>AI\main_ea.mq5:9329 via CouncilExecutionQualityStatusJsonPath()<br>AI\main_ea.mq5:9271 | path-def+write+literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\council_execution_quality_status.txt | AI\council_execution_quality_status.txt | no | AI\main_ea.mq5:9270 CouncilExecutionQualityStatusTxtPath()<br>AI\main_ea.mq5:9328 via CouncilExecutionQualityStatusTxtPath()<br>AI\main_ea.mq5:9270 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\council_feedback.json | AI\council_feedback.json | yes | AI\decision_mode_router.mqh:148<br>AI\main_ea.mq5:3606<br>AI\main_ea.mq5:5214<br>…(+3) | literal-ref+read | JSON object/array | yes | observe-only | state-critical |
| AI\council_live_exit_state.json | AI\council_live_exit_state.json | no | AI\core_trade_engine.mqh:762<br>AI\core_trade_engine.mqh:815 | read+write | JSON object/array | yes | unknown | state-critical |
| AI\council_live_exit_status.json | AI\council_live_exit_status.json | no | AI\core_trade_engine.mqh:876 | write | JSON object/array | yes | unknown | state-critical |
| AI\council_live_exit_status.txt | AI\council_live_exit_status.txt | no | AI\core_trade_engine.mqh:873 | write | TXT key/value or report | yes | unknown | state-critical |
| AI\council_memory.txt | AI\council_memory.txt | yes | AI\decision_mode_router.mqh:150<br>AI\storage_reset_pre_strategy_memory_v1.mqh:103 | literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\council_report.txt | AI\council_report.txt | yes | AI\decision_mode_router.mqh:149<br>AI\storage_reset_pre_strategy_memory_v1.mqh:104 | literal-ref | TXT key/value or report | yes | unknown | report-only |
| AI\council_setup_lifecycle_state.json | AI\council_setup_lifecycle_state.json | no | AI\main_ea.mq5:1826 CouncilSetupLifecycleStatePath()<br>AI\main_ea.mq5:8997 via CouncilSetupLifecycleStatePath()<br>AI\main_ea.mq5:9051 via CouncilSetupLifecycleStatePath()<br>…(+1) | path-def+read+write+literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\council_setup_lifecycle_status.txt | AI\council_setup_lifecycle_status.txt | no | AI\main_ea.mq5:1827 CouncilSetupLifecycleStatusPath()<br>AI\main_ea.mq5:9079 via CouncilSetupLifecycleStatusPath()<br>AI\main_ea.mq5:1827 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\council_trend_cont_confirmation_status.json | AI\council_trend_cont_confirmation_status.json | no | AI\council_mode_runtime.mqh:160 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\council_trend_cont_confirmation_status.txt | AI\council_trend_cont_confirmation_status.txt | no | AI\council_mode_runtime.mqh:159 | literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\dashboard_local_ui_state.json | AI\dashboard_local_ui_state.json | yes | AI\dashboard_navigation_controller.mqh:164<br>AI\dashboard_navigation_controller.mqh:264<br>AI\main_ea.mq5:6986 | read+write+existence-check | JSON object/array | yes | observe-only | state-critical |
| AI\dashboard_phase0_status.json | AI\dashboard_phase0_status.json | yes | AI\dashboard_source_registry.mqh:142<br>AI\dashboard_source_registry.mqh:143<br>AI\main_ea.mq5:6985 | literal-ref+existence-check | JSON object/array | yes | observe-only | state-critical |
| AI\dashboard_visible_snapshot_latest.txt | AI\dashboard_visible_snapshot_latest.txt | yes | AI\dashboard_snapshot_exporter.mqh:76 | literal-ref | TXT key/value or report | yes | observe-only | visibility-only |
| AI\diagnostic_runtime_summary.json | AI\diagnostic_runtime_summary.json | yes | AI\main_ea.mq5:2235 DiagnosticRuntimeSummaryJsonPath()<br>AI\main_ea.mq5:1345 via DiagnosticRuntimeSummaryJsonPath()<br>AI\main_ea.mq5:3530 via DiagnosticRuntimeSummaryJsonPath()<br>…(+8) | path-def+read+write+unknown+… | JSON object/array | yes | unknown | unknown |
| AI\diagnostic_runtime_summary.txt | AI\diagnostic_runtime_summary.txt | yes | AI\main_ea.mq5:2234 DiagnosticRuntimeSummaryTxtPath()<br>AI\main_ea.mq5:3529 via DiagnosticRuntimeSummaryTxtPath()<br>AI\dashboard_state_collector.mqh:142<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\docs\export_release_gate_contract.txt | AI\docs\export_release_gate_contract.txt | yes | AI\dashboard_source_registry.mqh:162 | literal-ref | TXT key/value or report | yes | unknown | report-only |
| AI\docs\factory_truth_vocabulary_contract.txt | AI\docs\factory_truth_vocabulary_contract.txt | yes | AI\dashboard_source_registry.mqh:192 | literal-ref | TXT key/value or report | yes | unknown | report-only |
| AI\docs\security_containment_secret_hygiene_remediation.txt | AI\docs\security_containment_secret_hygiene_remediation.txt | yes | AI\dashboard_source_registry.mqh:182 | literal-ref | TXT key/value or report | yes | unknown | report-only |
| AI\docs\strategy_transfer_pilot_evidence_design_contract.txt | AI\docs\strategy_transfer_pilot_evidence_design_contract.txt | yes | AI\dashboard_source_registry.mqh:172 | literal-ref | TXT key/value or report | yes | unknown | report-only |
| AI\edge_factory\decomposition\decomposition_status.json | AI\edge_factory\decomposition\decomposition_status.json | yes | AI\dashboard_source_registry.mqh:112<br>AI\dashboard_source_registry.mqh:113 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\edge_factory\edge_factory_manifest.json | AI\edge_factory\edge_factory_manifest.json | yes | AI\dashboard_source_registry.mqh:122<br>AI\dashboard_source_registry.mqh:123<br>AI\main_ea.mq5:6997 | literal-ref+existence-check | JSON object/array | yes | unknown | unknown |
| AI\edge_factory\internal_intelligence\internal_factory_intelligence_status.json | AI\edge_factory\internal_intelligence\internal_factory_intelligence_status.json | yes | AI\dashboard_source_registry.mqh:132<br>AI\dashboard_source_registry.mqh:133 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\edge_factory\registry\factory_intake_status.json | AI\edge_factory\registry\factory_intake_status.json | yes | AI\dashboard_source_registry.mqh:92<br>AI\dashboard_source_registry.mqh:93 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\edge_factory\registry\material_registry.json | AI\edge_factory\registry\material_registry.json | yes | AI\dashboard_source_registry.mqh:304<br>AI\dashboard_source_registry.mqh:305<br>AI\main_ea.mq5:6998 | literal-ref+existence-check | JSON object/array | yes | unknown | unknown |
| AI\edge_factory\registry\source_intake_gateway.json | AI\edge_factory\registry\source_intake_gateway.json | yes | AI\main_ea.mq5:2224 SourceIntakeGatewayPath()<br>AI\main_ea.mq5:2113 via SourceIntakeGatewayPath()<br>AI\main_ea.mq5:2128 via SourceIntakeGatewayPath()<br>…(+1) | path-def+existence-check+read+literal-ref | JSON object/array | yes | unknown | unknown |
| AI\edge_factory\registry\source_intake_gateway_status.json | AI\edge_factory\registry\source_intake_gateway_status.json | yes | AI\main_ea.mq5:2226 SourceIntakeGatewayStatusJsonPath()<br>AI\main_ea.mq5:2052 via SourceIntakeGatewayStatusJsonPath()<br>AI\main_ea.mq5:2060 via SourceIntakeGatewayStatusJsonPath()<br>…(+4) | path-def+write+read+literal-ref+… | JSON object/array | yes | unknown | state-critical |
| AI\edge_factory\registry\source_intake_gateway_status.txt | AI\edge_factory\registry\source_intake_gateway_status.txt | yes | AI\main_ea.mq5:2225 SourceIntakeGatewayStatusTxtPath()<br>AI\main_ea.mq5:2051 via SourceIntakeGatewayStatusTxtPath()<br>AI\main_ea.mq5:2225 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\execution_authority_status.json | AI\execution_authority_status.json | yes | AI\main_ea.mq5:2220 ExecutionAuthorityStatusJsonPath()<br>AI\main_ea.mq5:2543 via ExecutionAuthorityStatusJsonPath()<br>AI\main_ea.mq5:6958 via ExecutionAuthorityStatusJsonPath()<br>…(+5) | path-def+write+read+existence+literal-ref+… | JSON object/array | yes | observe-only | execution-critical |
| AI\execution_authority_status.txt | AI\execution_authority_status.txt | yes | AI\main_ea.mq5:2219 ExecutionAuthorityStatusTxtPath()<br>AI\main_ea.mq5:2542 via ExecutionAuthorityStatusTxtPath()<br>AI\dashboard_state_collector.mqh:144<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | execution-critical |
| AI\execution_quality_validation.json | AI\execution_quality_validation.json | yes | AI\main_ea.mq5:4318 ExecutionQualityValidationJsonPath()<br>AI\main_ea.mq5:1096 via ExecutionQualityValidationJsonPath()<br>AI\main_ea.mq5:1324 via ExecutionQualityValidationJsonPath()<br>…(+8) | path-def+read+write+unknown+… | JSON object/array | yes | unknown | unknown |
| AI\execution_quality_validation.txt | AI\execution_quality_validation.txt | yes | AI\main_ea.mq5:4317 ExecutionQualityValidationTxtPath()<br>AI\main_ea.mq5:4884 via ExecutionQualityValidationTxtPath()<br>AI\main_ea.mq5:4317 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\export_release_gate_status.json | AI\export_release_gate_status.json | yes | AI\dashboard_source_registry.mqh:32<br>AI\dashboard_source_registry.mqh:33 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\export_release_gate_status.txt | AI\export_release_gate_status.txt | yes | AI\dashboard_state_collector.mqh:134 | literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\config\atas_indicator_exporter.example.json | AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\config\atas_indicator_exporter.example.json | yes | AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\src\Config\AtasIndicatorExporterConfigLoader.cs:82 | read | JSON object/array | no | observe-only | config-critical |
| AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\runtime\atas_indicator_exporter_status.json | AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\runtime\atas_indicator_exporter_status.json | yes | AI\external_dashboard\tools\atas_live_capture_monitor.py:702 | read | JSON object/array | no | observe-only | state-critical |
| AI\external_adapter\atas_semantic_adapter\config\adapter_config.example.json | AI\external_adapter\atas_semantic_adapter\config\adapter_config.example.json | yes | AI\external_adapter\atas_semantic_adapter\src\Program.cs config input / docs | read | JSON object/array | no | observe-only | config-critical |
| AI\external_adapter\atas_semantic_adapter\config\symbol_map.example.json | AI\external_adapter\atas_semantic_adapter\config\symbol_map.example.json | yes | AI\external_adapter\atas_semantic_adapter\src config/docs | read | JSON object/array | no | observe-only | config-critical |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\acquisition_input\acquisition_input_payload.json | AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\acquisition_input\acquisition_input_payload.json | yes | AI\external_dashboard\tools\atas_live_capture_monitor.py:703 / propagation_runner.py:217<br>AI\external_adapter\atas_semantic_adapter\future_exporter\src\Models\FusionRuntimeConfig.cs:47 + FusionRuntimeWriter.cs<br>AI\external_dashboard\app\aggregator.py:763 | read+write+dashboard-surface | JSON object/array | no | observe-only | unknown |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\acquisition_source\atas_observation_export.json | AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\acquisition_source\atas_observation_export.json | yes | AI\external_dashboard\tools\atas_live_capture_monitor.py:701 / propagation_runner.py:211 | read | JSON object/array | no | observe-only | unknown |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\exporter_status.json | AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\exporter_status.json | yes | AI\external_dashboard\tools\atas_live_capture_monitor.py:705 / propagation_runner.py:216<br>AI\external_adapter\atas_semantic_adapter\future_exporter\src\Models\ExporterConfig.cs:20 + Program.cs<br>AI\external_dashboard\app\aggregator.py:762 | read+write+dashboard-surface | JSON object/array | no | observe-only | state-critical |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\fusion\fusion_status.json | AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\fusion\fusion_status.json | yes | AI\external_adapter\atas_semantic_adapter\future_exporter\src\Models\FusionRuntimeConfig.cs:50 + FusionRuntimeWriter.cs | write | JSON object/array | no | observe-only | state-critical |
| AI\external_adapter\atas_semantic_adapter\runtime\adapter_status.json | AI\external_adapter\atas_semantic_adapter\runtime\adapter_status.json | yes | AI\external_dashboard\tools\atas_live_capture_monitor.py:706 / propagation_runner.py:223<br>AI\external_adapter\atas_semantic_adapter\src\Models\AdapterConfig.cs:26 + Program.cs/AtomicJsonWriter<br>AI\external_dashboard\app\aggregator.py:760 | read+write+dashboard-surface | JSON object/array | no | observe-only | state-critical |
| AI\external_adapter\atas_semantic_adapter\runtime\producer_input\atas_export_payload.json | AI\external_adapter\atas_semantic_adapter\runtime\producer_input\atas_export_payload.json | yes | AI\external_dashboard\tools\atas_live_capture_monitor.py:704 / propagation_runner.py:222<br>AI\external_dashboard\app\aggregator.py:761 | read+dashboard-surface | JSON object/array | no | observe-only | unknown |
| AI\factory_operational_evidence_status.json | AI\factory_operational_evidence_status.json | yes | AI\main_ea.mq5:2243 FactoryOperationalEvidenceJsonPath()<br>AI\main_ea.mq5:1077 via FactoryOperationalEvidenceJsonPath()<br>AI\main_ea.mq5:6988 via FactoryOperationalEvidenceJsonPath()<br>…(+5) | path-def+write+existence-check+read+existence+… | JSON object/array | yes | unknown | state-critical |
| AI\factory_operational_evidence_status.txt | AI\factory_operational_evidence_status.txt | yes | AI\main_ea.mq5:2242 FactoryOperationalEvidenceTxtPath()<br>AI\main_ea.mq5:1076 via FactoryOperationalEvidenceTxtPath()<br>AI\dashboard_state_collector.mqh:152<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\last_meaningful_runtime_event.json | AI\last_meaningful_runtime_event.json | yes | AI\main_ea.mq5:2241 LastMeaningfulRuntimeEventJsonPath()<br>AI\main_ea.mq5:714 via LastMeaningfulRuntimeEventJsonPath()<br>AI\main_ea.mq5:762 via LastMeaningfulRuntimeEventJsonPath()<br>…(+7) | path-def+write+read+existence-check+… | JSON object/array | yes | unknown | unknown |
| AI\last_meaningful_runtime_event.txt | AI\last_meaningful_runtime_event.txt | yes | AI\main_ea.mq5:2240 LastMeaningfulRuntimeEventTxtPath()<br>AI\main_ea.mq5:697 via LastMeaningfulRuntimeEventTxtPath()<br>AI\dashboard_state_collector.mqh:150<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\operating_risk_envelope_status.json | AI\operating_risk_envelope_status.json | yes | AI\main_ea.mq5:2222 OperatingRiskEnvelopeStatusJsonPath()<br>AI\main_ea.mq5:778 via OperatingRiskEnvelopeStatusJsonPath()<br>AI\main_ea.mq5:2859 via OperatingRiskEnvelopeStatusJsonPath()<br>…(+5) | path-def+read+write+read+existence+… | JSON object/array | yes | observe-only | execution-critical |
| AI\operating_risk_envelope_status.txt | AI\operating_risk_envelope_status.txt | yes | AI\main_ea.mq5:2221 OperatingRiskEnvelopeStatusTxtPath()<br>AI\main_ea.mq5:2834 via OperatingRiskEnvelopeStatusTxtPath()<br>AI\main_ea.mq5:2911 via OperatingRiskEnvelopeStatusTxtPath()<br>…(+2) | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | execution-critical |
| AI\operational_integrity_status.json | AI\operational_integrity_status.json | yes | AI\main_ea.mq5:2216 OperationalIntegrityStatusJsonPath()<br>AI\main_ea.mq5:7335 via OperationalIntegrityStatusJsonPath()<br>AI\dashboard_source_registry.mqh:233<br>…(+4) | path-def+write+literal-ref+read+… | JSON object/array | yes | observe-only | state-critical |
| AI\operational_integrity_status.txt | AI\operational_integrity_status.txt | yes | AI\main_ea.mq5:2215 OperationalIntegrityStatusTxtPath()<br>AI\main_ea.mq5:7334 via OperationalIntegrityStatusTxtPath()<br>AI\main_ea.mq5:2215 | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\operator_effective_configuration_note.txt | AI\operator_effective_configuration_note.txt | yes | AI\runtime_honesty_surfaces.mqh:9 RuntimeHonestyOperatorEffectiveConfigurationNotePath()<br>AI\runtime_honesty_surfaces.mqh:1240 via RuntimeHonestyOperatorEffectiveConfigurationNotePath()<br>AI\runtime_honesty_surfaces.mqh:1241 via RuntimeHonestyOperatorEffectiveConfigurationNotePath()<br>…(+1) | path-def+write+unknown+literal-ref | TXT key/value or report | yes | unknown | config-critical |
| AI\operator_effective_configuration_surface.json | AI\operator_effective_configuration_surface.json | yes | AI\runtime_honesty_surfaces.mqh:8 RuntimeHonestyOperatorEffectiveConfigurationSurfacePath()<br>AI\runtime_honesty_surfaces.mqh:1200 via RuntimeHonestyOperatorEffectiveConfigurationSurfacePath()<br>AI\runtime_honesty_surfaces.mqh:1201 via RuntimeHonestyOperatorEffectiveConfigurationSurfacePath()<br>…(+1) | path-def+write+unknown+literal-ref | JSON object/array | yes | unknown | config-critical |
| AI\operator_input_truth_map.json | AI\operator_input_truth_map.json | yes | AI\runtime_honesty_surfaces.mqh:5 RuntimeHonestyOperatorInputTruthMapPath()<br>AI\runtime_honesty_surfaces.mqh:559 via RuntimeHonestyOperatorInputTruthMapPath()<br>AI\runtime_honesty_surfaces.mqh:560 via RuntimeHonestyOperatorInputTruthMapPath()<br>…(+1) | path-def+write+unknown+literal-ref | JSON object/array | yes | unknown | unknown |
| AI\operator_runtime_truth_note.txt | AI\operator_runtime_truth_note.txt | yes | AI\runtime_honesty_surfaces.mqh:10 RuntimeHonestyOperatorRuntimeTruthNotePath()<br>AI\runtime_honesty_surfaces.mqh:1281 via RuntimeHonestyOperatorRuntimeTruthNotePath()<br>AI\runtime_honesty_surfaces.mqh:1282 via RuntimeHonestyOperatorRuntimeTruthNotePath()<br>…(+1) | path-def+write+unknown+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\replay_validation_summary.json | AI\replay_validation_summary.json | yes | AI\main_ea.mq5:2238 ReplayValidationSummaryJsonPath()<br>AI\main_ea.mq5:4261 via ReplayValidationSummaryJsonPath()<br>AI\main_ea.mq5:6369 via ReplayValidationSummaryJsonPath()<br>…(+1) | path-def+write+unknown+literal-ref | JSON object/array | yes | unknown | unknown |
| AI\replay_validation_summary.txt | AI\replay_validation_summary.txt | yes | AI\main_ea.mq5:2237 ReplayValidationSummaryTxtPath()<br>AI\main_ea.mq5:4260 via ReplayValidationSummaryTxtPath()<br>AI\main_ea.mq5:2237 | path-def+write+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\risk_safety_status.json | AI\risk_safety_status.json | yes | AI\main_ea.mq5:2210 RiskSafetyStatusJsonPath()<br>AI\main_ea.mq5:5954 via RiskSafetyStatusJsonPath()<br>AI\main_ea.mq5:7133 via RiskSafetyStatusJsonPath()<br>…(+1) | path-def+write+read+existence+literal-ref | JSON object/array | yes | observe-only | state-critical |
| AI\risk_safety_status.txt | AI\risk_safety_status.txt | yes | AI\main_ea.mq5:2209 RiskSafetyStatusTxtPath()<br>AI\main_ea.mq5:5953 via RiskSafetyStatusTxtPath()<br>AI\main_ea.mq5:2209 | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | state-critical |
| AI\runtime_governance_status.json | AI\runtime_governance_status.json | yes | AI\main_ea.mq5:2207 RuntimeGovernanceStatusJsonPath()<br>AI\main_ea.mq5:773 via RuntimeGovernanceStatusJsonPath()<br>AI\main_ea.mq5:5501 via RuntimeGovernanceStatusJsonPath()<br>…(+6) | path-def+read+write+read+existence+… | JSON object/array | yes | observe-only | execution-critical |
| AI\runtime_governance_status.txt | AI\runtime_governance_status.txt | yes | AI\main_ea.mq5:2206 RuntimeGovernanceStatusTxtPath()<br>AI\main_ea.mq5:5500 via RuntimeGovernanceStatusTxtPath()<br>AI\dashboard_state_collector.mqh:130<br>…(+1) | path-def+write+literal-ref | TXT key/value or report | yes | observe-only | execution-critical |
| AI\runtime_honesty_note.txt | AI\runtime_honesty_note.txt | yes | AI\runtime_honesty_surfaces.mqh:7 RuntimeHonestyNotePath()<br>AI\runtime_honesty_surfaces.mqh:742 via RuntimeHonestyNotePath()<br>AI\runtime_honesty_surfaces.mqh:743 via RuntimeHonestyNotePath()<br>…(+1) | path-def+write+unknown+literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\runtime_honesty_truth.json | AI\runtime_honesty_truth.json | yes | AI\runtime_honesty_surfaces.mqh:4 RuntimeHonestyTruthArtifactPath()<br>AI\runtime_honesty_surfaces.mqh:340 via RuntimeHonestyTruthArtifactPath()<br>AI\runtime_honesty_surfaces.mqh:341 via RuntimeHonestyTruthArtifactPath()<br>…(+1) | path-def+write+unknown+literal-ref | JSON object/array | yes | unknown | unknown |
| AI\strategy_transfer_package5_pilot_cycle.json | AI\strategy_transfer_package5_pilot_cycle.json | yes | AI\dashboard_source_registry.mqh:52<br>AI\dashboard_source_registry.mqh:53 | literal-ref | JSON object/array | yes | unknown | unknown |
| AI\strategy_transfer_package5_pilot_cycle.txt | AI\strategy_transfer_package5_pilot_cycle.txt | yes | AI\dashboard_state_collector.mqh:138 | literal-ref | TXT key/value or report | yes | unknown | unknown |
| AI\strategy_transfer_package5_status.json | AI\strategy_transfer_package5_status.json | yes | AI\dashboard_source_registry.mqh:42<br>AI\dashboard_source_registry.mqh:43 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\strategy_transfer_package5_status.txt | AI\strategy_transfer_package5_status.txt | yes | AI\dashboard_state_collector.mqh:136 | literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\strategy_transfer_packageC_pilot_evidence_design.json | AI\strategy_transfer_packageC_pilot_evidence_design.json | yes | AI\dashboard_source_registry.mqh:72<br>AI\dashboard_source_registry.mqh:73 | literal-ref | JSON object/array | yes | unknown | unknown |
| AI\strategy_transfer_packageC_status.json | AI\strategy_transfer_packageC_status.json | yes | AI\dashboard_source_registry.mqh:62<br>AI\dashboard_source_registry.mqh:63 | literal-ref | JSON object/array | yes | unknown | state-critical |
| AI\strategy_transfer_packageC_status.txt | AI\strategy_transfer_packageC_status.txt | yes | AI\dashboard_state_collector.mqh:140 | literal-ref | TXT key/value or report | yes | unknown | state-critical |
| AI\strategy_transfer_runtime_freeze_status.json | AI\strategy_transfer_runtime_freeze_status.json | yes | AI\dashboard_source_registry.mqh:152<br>AI\dashboard_source_registry.mqh:153<br>AI\main_ea.mq5:5064 | literal-ref+read | JSON object/array | yes | unknown | state-critical |
| AI\threshold_ownership_registry.json | AI\threshold_ownership_registry.json | yes | AI\runtime_honesty_surfaces.mqh:6 RuntimeHonestyThresholdOwnershipRegistryPath()<br>AI\runtime_honesty_surfaces.mqh:693 via RuntimeHonestyThresholdOwnershipRegistryPath()<br>AI\runtime_honesty_surfaces.mqh:694 via RuntimeHonestyThresholdOwnershipRegistryPath()<br>…(+1) | path-def+write+unknown+literal-ref | JSON object/array | yes | unknown | unknown |

### 2. Reader/writer authority map

| file | readers | writers | likely authority owner | multiple writers exist | conflict/desync risk | locking or sequencing notes |
| --- | --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | AI\main_ea.mq5:12429<br>AI\main_ea.mq5:12609<br>AI\main_ea.mq5:5145 via TruthCurrentPlanPath()<br>AI\main_ea.mq5:8952 via TruthCurrentPlanPath() | Unknown / needs confirmation | MT5-owned active truth; original author Unknown | unknown | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_previous_plan_backup.json | Unknown / needs confirmation | Unknown / needs confirmation | MT5-owned rollback backup; original author Unknown | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_evolution_state.json | AI\main_ea.mq5:5114 via TruthEvolutionStatePath()<br>AI\main_ea.mq5:5118 via TruthEvolutionStatePath()<br>AI\main_ea.mq5:8901 via TruthEvolutionStatePath()<br>AI\main_ea.mq5:8913 via TruthEvolutionStatePath()<br>…(+1) | AI\main_ea.mq5:8906 via TruthEvolutionStatePath()<br>AI\main_ea.mq5:8908 via TruthEvolutionStatePath()<br>AI\main_ea.mq5:8937 via TruthEvolutionStatePath() | MT5-owned/generated derived state | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_runtime_secrets.json | AI\main_ea.mq5:12606 | Unknown / needs confirmation | human-owned | unknown | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\runtime_governance_status.json | AI\external_dashboard\app\aggregator.py:62<br>AI\external_dashboard\app\aggregator.py:756<br>AI\main_ea.mq5:6931 via RuntimeGovernanceStatusJsonPath()<br>AI\main_ea.mq5:773 via RuntimeGovernanceStatusJsonPath() | AI\main_ea.mq5:5501 via RuntimeGovernanceStatusJsonPath() | MT5-owned/generated | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\execution_authority_status.json | AI\external_dashboard\app\aggregator.py:63<br>AI\external_dashboard\app\aggregator.py:757<br>AI\main_ea.mq5:6958 via ExecutionAuthorityStatusJsonPath() | AI\main_ea.mq5:2543 via ExecutionAuthorityStatusJsonPath() | MT5-owned/generated | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\active_operating_cohort.json | AI\main_ea.mq5:7169 via ActiveOperatingCohortStatusJsonPath() | AI\main_ea.mq5:2360 via ActiveOperatingCohortStatusJsonPath() | MT5-owned/generated | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\operating_risk_envelope_status.json | AI\main_ea.mq5:7135 via OperatingRiskEnvelopeStatusJsonPath()<br>AI\main_ea.mq5:778 via OperatingRiskEnvelopeStatusJsonPath() | AI\main_ea.mq5:2859 via OperatingRiskEnvelopeStatusJsonPath()<br>AI\main_ea.mq5:2936 via OperatingRiskEnvelopeStatusJsonPath() | MT5-owned/generated | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_performance_journal.jsonl | AI\journal_analytics.mqh:1331<br>AI\journal_analytics.mqh:2008<br>AI\journal_analytics.mqh:2356<br>AI\journal_analytics.mqh:2399<br>…(+6) | Unknown / needs confirmation | MT5-owned/generated | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\council_feedback.json | AI\main_ea.mq5:3606<br>AI\main_ea.mq5:5214<br>AI\main_ea.mq5:6101 | Unknown / needs confirmation | MT5-owned/generated | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_trade_feedback.json | AI\external_dashboard\app\aggregator.py:139<br>AI\external_dashboard\app\aggregator.py:248<br>AI\external_dashboard\app\aggregator.py:742<br>AI\external_dashboard\app\aggregator.py:816 | Unknown / needs confirmation | MT5-owned/generated | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_strategy_memory.json | Unknown / needs confirmation | Unknown / needs confirmation | MT5-owned/generated | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_governor_state.json | Unknown / needs confirmation | Unknown / needs confirmation | MT5-owned/generated | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_next_plan_proposal.json | Unknown / needs confirmation | Unknown / needs confirmation | Unknown | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\ai_rollback_state.json | AI\main_ea.mq5:13017 via RollbackStatePath()<br>AI\runtime_honesty_surfaces.mqh:69 via RollbackStatePath() | Unknown / needs confirmation | Unknown | unknown | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\edge_factory\registry\source_intake_gateway.json | AI\main_ea.mq5:2113 via SourceIntakeGatewayPath()<br>AI\main_ea.mq5:2128 via SourceIntakeGatewayPath() | Unknown / needs confirmation | Unknown | unknown | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\edge_factory\registry\source_intake_gateway_status.json | AI\main_ea.mq5:2060 via SourceIntakeGatewayStatusJsonPath()<br>AI\main_ea.mq5:6999 | AI\main_ea.mq5:2052 via SourceIntakeGatewayStatusJsonPath() | MT5-owned/generated | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\atas_microstructure_context.json | AI\atas_intake_layer.mqh:535 via AtasRuntimeContextPath()<br>AI\external_dashboard\app\aggregator.py:749 | AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\src\Config\AtasIndicatorExporterConfigLoader.cs:73 + Runtime.cs:32 | adapter-owned/generated | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\atas_microstructure_status.json | AI\atas_governed_advisory_layer.mqh:367<br>AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\src\Config\AtasIndicatorExporterConfigLoader.cs:75 + Mt5ExecutionReferenceReader.cs:37<br>AI\external_dashboard\app\aggregator.py:748 | AI\atas_intake_layer.mqh:501 via AtasRuntimeContextStatusPath() | Unknown | yes | high | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\atas_runtime_context.json | AI\external_dashboard\app\aggregator.py:751 | AI\external_adapter\atas_semantic_adapter\atas_indicator_exporter\src\AtasObservationExporterRuntime.cs:144-150<br>AI\external_adapter\atas_semantic_adapter\src\Models\AdapterConfig.cs:23 + Program.cs/AtomicJsonWriter | Unknown | yes | medium | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\atas_runtime_context_status.json | AI\atas_governed_advisory_layer.mqh:370<br>AI\external_adapter\atas_semantic_adapter\future_exporter\src\Models\ExporterConfig.cs:62 + CrossInstrumentBasisCapture.cs:145<br>AI\external_dashboard\app\aggregator.py:750 | Unknown / needs confirmation | Unknown | unknown | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\external_adapter\atas_semantic_adapter\runtime\adapter_status.json | AI\external_dashboard\app\aggregator.py:760<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:706 / propagation_runner.py:223 | AI\external_adapter\atas_semantic_adapter\src\Models\AdapterConfig.cs:26 + Program.cs/AtomicJsonWriter | adapter-owned/generated | yes | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\exporter_status.json | AI\external_dashboard\app\aggregator.py:762<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:705 / propagation_runner.py:216 | AI\external_adapter\atas_semantic_adapter\future_exporter\src\Models\ExporterConfig.cs:20 + Program.cs | adapter-owned/generated | yes | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\acquisition_input\acquisition_input_payload.json | AI\external_dashboard\app\aggregator.py:763<br>AI\external_dashboard\tools\atas_live_capture_monitor.py:703 / propagation_runner.py:217 | AI\external_adapter\atas_semantic_adapter\future_exporter\src\Models\FusionRuntimeConfig.cs:47 + FusionRuntimeWriter.cs | adapter-owned/generated | yes | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\atas_live_capture\atas_live_chain_status.json | AI\external_dashboard\app\aggregator.py:1059 | AI\external_dashboard\tools\atas_live_capture_monitor.py:666 | script-owned/generated | yes | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\atas_live_capture\atas_live_event_stream.jsonl | AI\external_dashboard\app\aggregator.py:1062 | AI\external_dashboard\tools\atas_live_capture_monitor.py:689 | script-owned/generated | yes | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |
| AI\dashboard_local_ui_state.json | AI\dashboard_navigation_controller.mqh:164<br>AI\main_ea.mq5:6986 | AI\dashboard_navigation_controller.mqh:264 | script-owned/generated | yes | Unknown / needs confirmation | mtime/hash sequencing; single writer per surface required; Unknown / needs confirmation for live locking |

### 3. Schema/key expectations

MQL JSON parsing is mostly string-search based through `ExtractJson*Field` helpers in `config_loader.mqh`; strict JSON object validation is not consistently enforced by MT5-side loaders. Required fields below are inferred only where code explicitly depends on them.

| file | format | observed keys / structure | required keys inferred from code | optional/default behavior inferred from code | unknown required fields |
| --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | JSON object/array | non-strict-key-extraction-only; object keys(82): plan_id, enabled, main_timeframe, confirmation_timeframe, main_trigger_name, strong_confirmations, medium_confirmations, required_filters, entry_patterns, pullback_ratio, breakout_buffer_points, signal_expiry_bars, atr_multiplier, risk_reward, time_exit_minutes, move_sl_20_to_10, max_open_positions, one_direction_only, cooldown_bars, use_spread_filter… | `plan_id`, `decision_engine_mode` for truth sync; load requires file readable | Most `RuntimePlan` fields default in `LoadDefaultPlan` if missing | Unknown / needs confirmation |
| AI\ai_previous_plan_backup.json | JSON object/array | non-strict-key-extraction-only; object keys(76): plan_id, enabled, main_timeframe, confirmation_timeframe, main_trigger_name, strong_confirmations, medium_confirmations, required_filters, entry_patterns, pullback_ratio, breakout_buffer_points, signal_expiry_bars, atr_multiplier, risk_reward, time_exit_minutes, move_sl_20_to_10, max_open_positions, one_direction_only, cooldown_bars, use_spread_filter… | rollback source must be readable when rollback applies; plan fields expected but exact required set Unknown | annotated as non-authoritative backup when present | Unknown / needs confirmation |
| AI\ai_evolution_state.json | JSON object/array | non-strict-key-extraction-only; object keys(39): active_decision_engine_mode, active_plan_id, authoritative_plan_file, truth_authority_policy, truth_role, version, evolution_enabled, current_generation, current_plan_id, last_evolution_time, last_evolution_reason, last_evolution_scope, last_diagnosis, min_trades_before_evolution, small_evolution_min_trades, medium_evolution_min_trades, major_evolution_min_trades, strong_major_evolution_min_trades, allow_minor_evolution_anytime, allow_small_evolution… | file optional; defaults created if load fails; `current_plan_id` must mirror active plan after truth sync | Most fields default in `LoadDefaultEvolutionState` | Unknown / needs confirmation |
| AI\ai_runtime_secrets.json | JSON object/array | strict; object keys(10): ai_enabled, provider, api_key, api_key_status, api_key_placeholder_only, project_package_contains_no_live_secret, model, base_url, timeout_seconds, security_boundary_note | file must be readable for live AI enablement; `api_key` required only if AI enabled | defaults exist: ai disabled, model/base_url/timeout | Unknown / needs confirmation |
| AI\council_feedback.json | JSON object/array | strict; array length 2939; first object keys: symbol, plan_id, record_type, record_semantics_version, mode_name, decision_id, correlated_decision_id, position_id, close_deal_id, correlation_method, correlation_quality, final_decision, executed_direction, trade_result, profit, environment_score, council_quality, consensus_strength, conflict_score, zone_name… | array tail must remain valid enough for append helper; analytics infer `WIN`/`LOSS`, `deal`, `trigger` tokens | many record fields are analytics-only | Unknown / needs confirmation |
| AI\ai_performance_journal.jsonl | JSONL events | JSONL lines=5614; first 50 valid=50; first keys: record_type, record_semantics_version, event_family, decision_event_type, decision_id, plan_fingerprint, plan_id, active_mode, ts, symbol, tf, regime_label, regime_confidence, direction, raw_signal_score, confidence_score, regime_fit_score, execution_quality_score, policy_risk_score, entry_quality_score… | one JSON object per line for Python/dashboard strict JSONL; MQL may scan text | event-specific keys vary | Unknown / needs confirmation |
| AI\runtime_governance_status.json | JSON object/array | strict; object keys(35): governance_state, trading_allowed, degraded_mode, truth_ready, diagnostics_ready, rollback_recently_applied, reason_code, active_plan_id, active_mode, status_origin, factory_first_admission_policy_locked, strategy_transfer_runtime_freeze_active, strategy_transfer_runtime_freeze_scope, strategy_transfer_runtime_freeze_reason_code, strategy_execution_identity_authority_frozen, compiled_plan_runtime_privilege_frozen, council_runtime_execution_privilege_frozen, future_factory_admission_required_for_execution, lineage_preservation_mode, package1_policy_lock_state… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\execution_authority_status.json | JSON object/array | strict; object keys(23): execution_authority_source, execution_authority_cutover_state, legacy_identity_execution_authority_active, factory_governed_execution_authority_active, active_operating_cohort_defined, active_operating_cohort_id, active_operating_candidate_count, execution_allowed_only_through_active_operating_cohort, operating_cohort_admission_semantics, operating_risk_envelope_state, current_guardrail_block_reason_code, current_guardrail_owner, execution_globally_blocked, execution_block_reason_code, decision_candidate_name, decision_candidate_family, last_reject_candidate_name, last_reject_candidate_family, last_reject_reason_code, last_executed_candidate_name… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\active_operating_cohort.json | JSON object/array | strict; object keys(9): active_operating_cohort_id, active_operating_cohort_state, active_operating_candidates, candidate_count, operating_cohort_admission_semantics, candidate_sources, cohort_activation_reason, cohort_scope_note, last_updated | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\operating_risk_envelope_status.json | JSON object/array | strict; object keys(21): operating_risk_envelope_state, envelope_clear_for_new_entries, max_open_positions, current_open_positions, max_new_trades_per_session, current_session_new_entries, effective_session_trade_cap, cooldown_bars, bars_since_last_entry, spread_guard_active, spread_guard_threshold_points, current_spread_points, risk_policy_guard_active, execution_quality_guard_active, emergency_stop_active, current_blocking_guard, current_block_reason_code, current_block_reason_text, current_block_owner, last_direction_under_review… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\risk_safety_status.json | JSON object/array | strict; object keys(38): artifact_role, artifact_authority_class, trust_rule, status_origin, safety_state, trading_allowed, emergency_flat_required, safe_block_mode, degraded_protection_mode, open_position_management_only, safety_reason_code, consecutive_open_failures, rollback_recovery_pending, governance_degraded, governance_state, governance_reason_code, active_plan_id, active_mode, operating_risk_envelope_state, envelope_clear_for_new_entries… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\operational_integrity_status.json | JSON object/array | strict; object keys(50): artifact_role, artifact_authority_class, summary_version, status_origin, overall_state, overall_reason, ai_readiness_review_consistency_state, ai_readiness_review_consistency_reason, freshness_gate_state, stale_critical_surface_count, stale_critical_surfaces, dominant_stale_surface, dominant_stale_reason, last_freshness_check_time, last_checked, runtime_integrity_state, runtime_integrity_issue_class, runtime_integrity_owner, runtime_integrity_reason, runtime_integrity_last_checked… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\ai_trade_feedback.json | JSON object/array | strict; object keys(124): symbol, plan_id, main_trigger_name, plan_mode, decision_engine_mode, execution_archetype, experiment_family, experiment_note, bias_direction, allow_triggerless_entry, use_soft_filters, use_hard_blocks, direction, result, profit, spread_points, requested_entry_price, actual_entry_fill_price, exit_fill_price, initial_stop_loss… | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\ai_strategy_memory.json | JSON object/array | strict; object keys(4): version, generated_at, strategy_count, strategies | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\ai_governor_state.json | JSON object/array | strict; object keys(0):  | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\ai_next_plan_proposal.json | JSON object/array | strict; object keys(63): plan_id, enabled, main_timeframe, confirmation_timeframe, main_trigger_name, strong_confirmations, medium_confirmations, required_filters, entry_patterns, pullback_ratio, breakout_buffer_points, signal_expiry_bars, atr_multiplier, risk_reward, time_exit_minutes, move_sl_20_to_10, max_open_positions, one_direction_only, cooldown_bars, use_spread_filter… | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\atas_microstructure_context.json | JSON object/array | strict; object keys(7): artifact_role, artifact_authority_class, schema_version, envelope, quality, signal_payload, non_authoritative_note | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\atas_microstructure_status.json | JSON object/array | strict; object keys(35): artifact_role, artifact_authority_class, schema_version, source_platform, last_packet_id, packet_id, last_acceptance_state, last_rejection_reason, packet_age_ms, source_symbol, source_symbol_original, execution_symbol, source_reference_price, execution_reference_price, cross_instrument_translation_applied, cross_instrument_basis_value, price_anchor_fields_suppressed, price_space_relation, source_mode, quality_state… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\atas_runtime_context.json | JSON object/array | strict; object keys(7): artifact_role, artifact_authority_class, schema_version, envelope, quality, signal_payload, non_authoritative_note | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\atas_runtime_context_status.json | JSON object/array | strict; object keys(35): artifact_role, artifact_authority_class, schema_version, source_platform, last_packet_id, packet_id, last_acceptance_state, last_rejection_reason, packet_age_ms, source_symbol, source_symbol_original, execution_symbol, source_reference_price, execution_reference_price, cross_instrument_translation_applied, cross_instrument_basis_value, price_anchor_fields_suppressed, price_space_relation, source_mode, quality_state… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\edge_factory\registry\source_intake_gateway.json | JSON object/array | strict; object keys(73): artifact_role, artifact_authority_class, gateway_contract_version, source_intake_gateway_rich_hybrid_schema_version, gateway_mode, gateway_processing_mode, direct_factory_commit_allowed, auto_import_allowed, runtime_trading_impact, analytical_writer_scope_note, semantic_layer_authority_note, codification_layer_authority_note, update_id, snapshot_time, gateway_record_count, gateway_material_total, lossless_intake_preservation_mode, source_level_schema_fields_supported, material_level_schema_fields_supported, codification_layer_schema_fields_supported… | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\edge_factory\registry\source_intake_gateway_status.json | JSON object/array | strict; object keys(22): artifact_role, artifact_authority_class, gateway_file_present, gateway_parse_ok, gateway_update_detected, gateway_last_seen_update_id, gateway_last_seen_modified_time, gateway_last_seen_hash, gateway_record_count, gateway_processing_mode, gateway_contract_version, gateway_schema_version, gateway_version, gateway_snapshot_identity, gateway_producer_role, gateway_snapshot_updated_at, gateway_pending_review, direct_factory_commit_allowed, auto_import_allowed, runtime_trading_impact… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\external_adapter\atas_semantic_adapter\runtime\adapter_status.json | JSON object/array | strict; object keys(20): schema_version, last_run_timestamp, last_input_path, last_output_path, last_packet_id, last_acceptance_state, last_rejection_reason, source_symbol, execution_symbol, source_symbol_original, cross_instrument_translation_applied, price_anchor_fields_suppressed, cross_instrument_basis_value, quality_state, freshness_state, level_candidate_count, packet_age_ms, shadow_packet_written, adapter_mode, trace_id | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\exporter_status.json | JSON object/array | strict; object keys(22): last_run_timestamp, exporter_mode, input_mode, source_input_path, source_type, acquisition_handoff_path, profile_used, packet_id, source_symbol, execution_symbol, freshness_seconds, level_candidate_count, source_reference_price, execution_reference_price, cross_instrument_basis_value, cross_instrument_translation_applied, price_anchor_fields_suppressed, basis_capture_state, producer_output_path, write_status… | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\external_adapter\atas_semantic_adapter\future_exporter\runtime\acquisition_input\acquisition_input_payload.json | JSON object/array | strict; object keys(25): acquisition_schema_version, acquisition_event_id, source_platform, source_mode, source_symbol, execution_symbol, source_symbol_original, event_time, created_time, fresh_until, session_context, quality_state, observation_confidence, signal_stability_window_sec, market_state_class, overlay_weight_hint, source_reference_price, execution_reference_price, cross_instrument_basis_value, price_space_relation… | Unknown / needs confirmation | Unknown / needs confirmation | Unknown / needs confirmation |
| AI\atas_live_capture\atas_live_chain_status.json | JSON object/array | strict; object keys(10): captured_at_utc, diagnostic_role, chain_live_valid, first_failing_gate, stages, observation_packet_id, exporter_packet_id, adapter_packet_id, context_packet_id, context_status_packet_id | status-specific keys used by dashboard and integrity checks; exact hard-fail set Unknown | display/diagnostic fields default unavailable in dashboard | Unknown / needs confirmation |
| AI\atas_live_capture\atas_live_event_stream.jsonl | JSONL events | JSONL lines=17; first 50 valid=17; first keys: captured_at_utc, first_failing_gate, observation_state, exporter_state, adapter_state, intake_state, advisory_state, observation_packet_id, exporter_packet_id, adapter_packet_id, context_packet_id, context_status_packet_id, summary… | one JSON object per line for Python/dashboard strict JSONL; MQL may scan text | event-specific keys vary | Unknown / needs confirmation |

### 4. Strict JSON compatibility audit

| file | valid strict JSON | encoding/BOM | non-standard/parse issue | duplicate key concern | parser expectations inferred from MQL/config loader | Python/json tooling | MT5 parser likely accepts/rejects |
| --- | --- | --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | no | utf-8-sig / none | JSONDecodeError: Invalid \escape: line 1 column 2277 (char 2276) | none detected | likely accepts field extraction if quoted keys remain present; strict JSON not required by current MQL helpers | rejects | likely accepts |
| AI\ai_previous_plan_backup.json | no | utf-8-sig / none | JSONDecodeError: Invalid \escape: line 1 column 2276 (char 2275) | none detected | likely accepts field extraction if quoted keys remain present; strict JSON not required by current MQL helpers | rejects | likely accepts |
| AI\ai_evolution_state.json | no | utf-8-sig / none | JSONDecodeError: Invalid \escape: line 1 column 100 (char 99) | none detected | likely accepts field extraction if quoted keys remain present; strict JSON not required by current MQL helpers | rejects | likely accepts |
| AI\ai_runtime_secrets.json | yes | utf-8-sig / none | none detected | none detected | likely accepts via LoadAISecretsFromJson string/bool/int extractors | accepts | likely accepts |
| AI\council_feedback.json | yes | utf-8-sig / none | none detected | none detected | likely accepts as raw text / append-array pattern; strict schema not enforced | accepts | likely accepts |

Strict audit notes:

- `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json` are rejected by strict Python `json.loads` because of invalid backslash escapes. They were not modified.

- The current MQL loaders are permissive string extractors, so strict JSON rejection does not automatically mean MT5 rejection. This is a migration risk because an EXE written with strict JSON parsing would reject these files unless compatibility policy is resolved.

- No comments, trailing commas, single-quoted JSON, UTF BOM, or duplicate keys were detected in the audited valid JSON files. Duplicate-key checks for invalid strict JSON are conditional because strict parse aborts.

- `ai_runtime_secrets.json` was inspected for structure only; secret values were not written into this report.


### 5. Missing runtime surfaces

| referenced path | referenced by | expected format | likely purpose | missing appears | recommended human decision |
| --- | --- | --- | --- | --- | --- |
| AI\ai_last_evolution_raw.txt | AI\main_ea.mq5:12977<br>AI\main_ea.mq5:12988<br>…(+1) | TXT key/value or report | MT5 feedback/evolution checkpoint | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\ai_last_recorded_feedback_order.txt | AI\storage_reset_pre_strategy_memory_v1.mqh:112 | TXT key/value or report | MT5 feedback/evolution checkpoint | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\ai_last_recorded_feedback_position.txt | AI\storage_reset_pre_strategy_memory_v1.mqh:113 | TXT key/value or report | MT5 feedback/evolution checkpoint | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\atas_live_capture\atas_propagation_runner.lock | AI\external_dashboard\tools\atas_live_propagation_runner.py:233/378 | sentinel/lock | dashboard runner lock sentinel | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\atas_live_capture\freshness_isolation_report_{timestamp}.json | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:650 | JSON object/array | generated timestamp output | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\atas_live_capture\periodic_validation_cycles_{timestamp}.jsonl | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:646 | JSONL events | generated timestamp output | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\atas_live_capture\periodic_validation_summary_{timestamp}.json | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:648 | JSON object/array | generated timestamp output | optional/generated | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_activation_pressure_status.json | AI\main_ea.mq5:9361 CouncilActivationPressureStatusJsonPath()<br>AI\main_ea.mq5:9434 via CouncilActivationPressureStatusJsonPath()<br>…(+1) | JSON object/array | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_activation_pressure_status.txt | AI\main_ea.mq5:9360 CouncilActivationPressureStatusTxtPath()<br>AI\main_ea.mq5:9433 via CouncilActivationPressureStatusTxtPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_dirty_environment_status.json | AI\main_ea.mq5:9461 CouncilDirtyEnvironmentStatusJsonPath()<br>AI\main_ea.mq5:9514 via CouncilDirtyEnvironmentStatusJsonPath()<br>…(+1) | JSON object/array | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_dirty_environment_status.txt | AI\main_ea.mq5:9460 CouncilDirtyEnvironmentStatusTxtPath()<br>AI\main_ea.mq5:9513 via CouncilDirtyEnvironmentStatusTxtPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_execution_quality_status.json | AI\main_ea.mq5:9271 CouncilExecutionQualityStatusJsonPath()<br>AI\main_ea.mq5:9329 via CouncilExecutionQualityStatusJsonPath()<br>…(+1) | JSON object/array | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_execution_quality_status.txt | AI\main_ea.mq5:9270 CouncilExecutionQualityStatusTxtPath()<br>AI\main_ea.mq5:9328 via CouncilExecutionQualityStatusTxtPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_live_exit_state.json | AI\core_trade_engine.mqh:762<br>AI\core_trade_engine.mqh:815 | JSON object/array | MT5 council status/state surface | optional if no live exit state yet; could affect live-exit continuity if expected at runtime | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_live_exit_status.json | AI\core_trade_engine.mqh:876 | JSON object/array | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_live_exit_status.txt | AI\core_trade_engine.mqh:873 | TXT key/value or report | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_setup_lifecycle_state.json | AI\main_ea.mq5:1826 CouncilSetupLifecycleStatePath()<br>AI\main_ea.mq5:8997 via CouncilSetupLifecycleStatePath()<br>…(+2) | JSON object/array | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_setup_lifecycle_status.txt | AI\main_ea.mq5:1827 CouncilSetupLifecycleStatusPath()<br>AI\main_ea.mq5:9079 via CouncilSetupLifecycleStatusPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_trend_cont_confirmation_status.json | AI\council_mode_runtime.mqh:160 | JSON object/array | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |
| AI\council_trend_cont_confirmation_status.txt | AI\council_mode_runtime.mqh:159 | TXT key/value or report | MT5 council status/state surface | Unknown / needs confirmation | Human must confirm whether absence is expected in current runtime snapshot |

### 6. RAM cache eligibility draft

| file/class | example files | safe-to-cache status | authority source | load timing recommendation | refresh condition | invalidation condition | stale threshold recommendation | failure behavior | stale-data danger | write sensitivity |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Active plan and rollback backup | AI\ai_current_plan.json; AI\ai_previous_plan_backup.json | conditional | MT5-owned active truth / backup; original author Unknown | OnInit + explicit reload only | mtime/hash change; plan_id/mode change | rollback/apply event, validation failure | no arbitrary TTL; event/mtime driven | fail closed / keep last known only if MT5 current behavior permits | critical | write-sensitive |
| Evolution/governor/rollback state | AI\ai_evolution_state.json; AI\ai_governor_state.json; AI\ai_rollback_state.json | conditional | MT5-owned/generated or Unknown | OnInit/timer | mtime/hash; active_plan_id mismatch | rollback armed/disarmed, evolution update | per timer or event-driven | fail closed for rollback/governance; annotate Unknown | critical | write-sensitive |
| Governance/authority/cohort status | runtime_governance_status.*, execution_authority_status.*, active_operating_cohort.*, operating_risk_envelope_status.* | conditional | MT5-owned/generated | timer/tick observer cache only | mtime/hash; status last_updated | any stale age beyond current timer cadence | per tick/timer | treat unavailable/stale as blocked/unknown, not allowed | critical | volatile |
| Secrets | AI\ai_runtime_secrets.json | unsafe | human-owned | explicit manual load only | never dashboard-cache; process memory only | any file change or credential rotation | no TTL cache | fail disabled; never expose values | critical | write-sensitive |
| Journals and feedback | ai_performance_journal.jsonl; council_feedback.json; ai_trade_feedback.json; memory json/jsonl | conditional | MT5-owned/generated | read-only analytical snapshots | mtime/tail offset | append/rewrite detected; malformed tail | tail-driven; no execution truth | fail as analytics unavailable | medium | volatile |
| ATAS adapter surfaces | atas_microstructure_context/status; atas_runtime_context/status; external_adapter runtime files | conditional | adapter-owned/generated or MT5-owned status mirror | read-only observation | packet id, timestamp, freshness fields, mtime | stale packet/freshness state, writer status reject | seconds-level, use existing stale fields | degrade advisory only; never execution authority | high | volatile |
| Dashboard/capture outputs | AI\atas_live_capture\*; dashboard_local_ui_state.json | conditional | script-owned/generated | dashboard request only | mtime | dashboard stale/absent | dashboard UI threshold only | label stale/unavailable; never runtime truth | low/medium | volatile |
| Documentation/reports | docs, md, reports, archive outputs | safe for display only | human-owned/generated | on demand | mtime | file replaced | none for runtime | show unavailable | low | read-only |

### 7. Dashboard truth labeling draft

| dashboard-visible candidate | truth label | source file | refresh expectation | display warning if stale/unavailable | must never become dashboard authority |
| --- | --- | --- | --- | --- | --- |
| Runtime Governance card | cached view | AI\runtime_governance_status.json | <=4h in dashboard SurfaceTarget; runtime should be much fresher | show stale/unavailable; never allow trading from dashboard | yes |
| Execution Authority card | cached view | AI\execution_authority_status.json | <=4h in dashboard SurfaceTarget | show blocked/unknown if missing/stale | yes |
| Active cohort / risk envelope | cached view | AI\active_operating_cohort.json; AI\operating_risk_envelope_status.json | <=4h in dashboard SurfaceTarget | show stale/unavailable | yes |
| ATAS context/status | derived/cached view | AI\atas_microstructure_context.json/status with legacy fallback | 4-12h dashboard thresholds; adapter has stricter freshness fields | show primary vs legacy fallback and stale state | yes |
| Journals/trades/rejections | derived view | AI\ai_performance_journal.jsonl; AI\ai_trade_feedback.json; AI\council_feedback.json | mtime/tail read | show stale analytics only | yes |
| ATAS live capture monitor | derived view | AI\atas_live_capture\* | tool writes snapshots/events | show diagnostic-only label | yes |
| Dashboard UI local state | cached view | AI\dashboard_local_ui_state.json | on UI write/read | must not be interpreted as runtime command | yes |

### 8. Developer tool boundary draft

| possible tool action discovered | boundary classification | logging requirement | backup requirement | safety note |
| --- | --- | --- | --- | --- |
| external_dashboard/app FastAPI | observe-only | log HTTP/service health; no runtime writes | backup not applicable | Read-only dashboard notice observed in main.py. |
| external_dashboard/tools/atas_live_capture_monitor.py | confirm-before-write for its own diagnostic output; forbidden to write MT5 runtime truth | log generated snapshots/events | backup not required for generated dashboard output; do not overwrite runtime truth | Writes only capture/status files by design; still not an authority source. |
| external_dashboard/tools/atas_live_propagation_runner.py | confirm-before-write for runner status/events/lock/stop; forbidden to alter trading files | log runner events/status | backup not required for generated runner output | May launch dotnet subprocesses; V1 must not mutate MT5 configs/state. |
| external_dashboard/tools/atas_periodic_propagation_validation.py | confirm-before-write for validation reports; forbidden for runtime truth | log validation cycles | backup not required for generated validation outputs | Diagnostic-only. |
| external_adapter/atas_semantic_adapter C# apps | defer to V2 / observe-only for EXE migration until ownership confirmed | structured status required | atomic writer already observed; production backup policy Unknown | Adapter can write ATAS context/status; not dashboard or EXE authority. |
| plan/config editors | forbidden in V1 except explicit human-approved managed-write task | full audit log required | timestamped backup required | Current plan edits are trading-affecting. |
| secrets tooling | forbidden in V1 | redacted audit only | backup policy must avoid secret leakage | Never print or copy secret values into reports. |

### 9. Risks and mitigations update

- **stale governance/authority state:** Critical: stale `runtime_governance_status.*`, `execution_authority_status.*`, `active_operating_cohort.*`, or risk envelope can mislabel whether trading is allowed. Mitigation: EXE must treat stale/unavailable authority as blocked/unknown until MT5 confirms.
- **current plan cache desync:** Critical: `ai_current_plan.json` is active truth; `ai_evolution_state.json` mirrors it. Mitigation: Cache must invalidate by mtime/hash and verify `plan_id` / `active_plan_id` consistency.
- **secrets exposure:** Critical: `ai_runtime_secrets.json` contains secret-shaped fields. Mitigation: Never include values in logs, dashboard, backups, or plan reports.
- **multiple writers:** High: MT5, adapter tools, and human/Codex tasks can all target adjacent files. Mitigation: Stage 2 must define single-writer ownership and sequencing before any managed write.
- **missing runtime files:** High/unknown: some council/live-exit/status surfaces are referenced but absent in archive. Mitigation: Human must confirm optional/generated vs deployment gap.
- **strict JSON incompatibility:** High: Python/C# strict parsers reject several runtime-critical JSON files. Mitigation: Stage 2 prerequisite: compatibility policy before EXE parser design.
- **dashboard false authority:** High: dashboard reads many truth-like files. Mitigation: Dashboard labels must always be cached/derived view, never command authority.
- **adapter/tooling accidental writes:** High: Python tools and C# adapters write status/context/capture artifacts. Mitigation: Constrain V1 tooling to observe-only or diagnostic output; backups/audit for any future write.

### 10. Open questions update

- What is the exact live MT5 terminal root and is the archive path layout identical to production? **Unknown / needs confirmation.**
- Who is the human/system authority allowed to edit `AI\ai_current_plan.json` outside MT5? **Unknown / needs confirmation.**
- Are `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json` intentionally non-strict JSON-compatible, or is this a known defect? **Unknown / needs confirmation.**
- Should a future EXE preserve MQL permissive string extraction semantics or require strict JSON after human-approved migration? **Unknown / needs confirmation.**
- Are missing council/live-exit status files optional first-run generated outputs or expected production files? **Unknown / needs confirmation.**
- Which process is the single writer for `atas_microstructure_context.json`, `atas_runtime_context.json`, and related status files in live operation? **Unknown / needs confirmation.**
- Are `AI\external_adapter\atas_semantic_adapter\runtime\*` files production runtime truth, diagnostic adapter output, or generated leftovers? **Unknown / needs confirmation.**
- What freshness thresholds are considered safe for governance/authority/cohort status at runtime? **Unknown / needs confirmation.**
- Can `dashboard_local_ui_state.json` ever influence runtime behavior, or is it strictly UI-local? **Unknown / needs confirmation.**
- What locking/atomic-write mechanism is required between MT5, adapter writers, and future EXE readers? **Unknown / needs confirmation.**
- Should EXE V1 be entirely observe/cache-only, or are any managed writes explicitly in scope after Stage 2? **Unknown / needs confirmation.**
- How should secrets be deployed so backups and diagnostic reports never copy live credentials? **Unknown / needs confirmation.**

### 11. Recommended Stage 2 prerequisites

- Human confirmation of live terminal root, live process state, and production-vs-archive file expectations.
- Decision on strict JSON compatibility policy for runtime-critical JSON files before any EXE parser is designed.
- Single-writer authority matrix for active plan, backup plan, evolution state, rollback state, governance, authority, cohort, ATAS context/status, and dashboard local state.
- Freshness/staleness thresholds for execution-critical status files, including fail-closed behavior.
- Secret-handling policy for `ai_runtime_secrets.json`, including redacted logging and backup exclusions.
- List of missing runtime surfaces marked optional/generated/fatal by human owner.
- Atomic read/write/lock policy between MT5, Python dashboard tools, and C# adapter writers.
- Dashboard labeling policy: authoritative runtime truth vs cached/derived/stale/unavailable view.
- Rollback procedure for plan cache desync and bad Stage 2 artifacts.

### Stage 1 validation checklist

- [x] Only `AI\MT5_EXE_MIGRATION_PLAN.md` and timestamped backup are changed in the output archive.
- [x] All `.mq5`, `.mqh`, and `.ex5` files remain byte-identical to input archive.
- [x] All `.json`, `.jsonl`, `.txt`, `.csv`, `.ini`, and `.log` runtime/config/state/log files remain byte-identical.
- [x] No dashboard, adapter, build, binary, venv, cache, obj, bin, dll, exe, pdb, pyc, or script file was modified.
- [x] Stage 1 contains no implementation code.
- [x] Strict JSON audit did not modify JSON files.
- [x] Missing runtime surfaces are listed.
- [x] Unknown ownership/path/parser/writer questions are explicitly marked `Unknown / needs confirmation`.

### Stage 1 completion criteria

- [x] Runtime-consumed path map drafted from MQL, dashboard, external tool, and adapter static analysis.

- [x] Reader/writer authority map drafted for important files.

- [x] Schema/key expectations captured without exposing secrets.

- [x] Strict JSON audit completed without modification.

- [x] RAM-cache eligibility, dashboard truth labels, and developer tool boundaries drafted at discovery level only.

---

## Stage 1.5 — Migration Gate Resolution

Stage 1.5 discovery timestamp: `20260425_032217` Europe/Istanbul.

Scope: migration-gate decisions only. This section converts Stage 1 read-only findings into explicit Stage 2 blockers, allowed design scope, and human-review decisions. No EXE, RAM loader, dashboard implementation, adapter supervisor, developer tool, trading logic, JSON normalization, runtime state edit, log edit, or config-format change was performed. Secret values were not written to this plan.

Inspection basis:

- `AI\MT5_EXE_MIGRATION_PLAN.md`
- `AI\main_ea.mq5`
- `AI\config_loader.mqh`
- `AI\core_trade_engine.mqh`
- `AI\storage_reset_pre_strategy_memory_v1.mqh`
- all active root `.mqh` files with runtime/config/state references
- runtime/config/status files named in the Stage 1 contract
- `AI\external_dashboard\tools\*`
- `AI\external_adapter\atas_semantic_adapter\*`
- Stage 1 runtime path map: `148` file/data references, `113` reader/writer relationship entries, and `20` missing referenced surfaces

### 1. JSON Compatibility Policy

Gate decision: **Stage 2 implementation/prototype is blocked for strict JSON parsing of runtime-critical files until humans approve a JSON compatibility policy. Stage 2 design-only work may document parser modes and cache metadata without modifying or normalizing JSON files.**

| file | current strict JSON validity | current MT5/MQL tolerance behavior if inferable | risk if parsed by strict EXE parser | recommended policy | modification required before Stage 2 | Stage 2 RAM loader may read | Stage 2 may cache | dashboard may display | redaction requirements |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | No; invalid backslash escape detected by strict parser | Current MQL loaders use permissive string-field extraction and do not validate whole-file JSON; `plan_id` is required for truth extraction and `decision_engine_mode` is used when present. | Critical: strict EXE parser rejects active plan, causing cache/load failure or desync if not handled. | Unknown / needs human decision between compatibility parser vs later strict normalization; preferred Stage 1.5 gate decision is: do not normalize now and block strict-parser RAM loader. | Yes for Stage 2 implementation/prototype; no file modification in this task. | Design-only raw-text inspection may read; Stage 2 RAM loader implementation may not consume as strict JSON until policy approved. | No runtime-truth cache; conditional metadata/hash cache only after policy approval. | No direct display; dashboard may show redacted metadata/status only with control-surface warning. | Redact plan body in broad dashboard/export contexts; expose only plan_id/hash/mtime when approved. |
| AI\ai_previous_plan_backup.json | No; invalid backslash escape detected by strict parser | MQL treats it as rollback-only backup and can annotate/read through permissive text helpers. | High: strict EXE parser could reject rollback backup and incorrectly report missing rollback safety. | Unknown / needs human decision; do not normalize now. Treat as rollback backup, never authority. | Yes for any prototype that parses it; not required for design-only registry. | Design-only raw-text metadata read allowed; strict parse blocked. | No cache as truth; conditional backup metadata/hash only. | No direct display; metadata only as non-authoritative backup. | No secret-specific redaction known; avoid rendering full control surface. |
| AI\ai_evolution_state.json | No; invalid backslash escape detected by strict parser | MQL loads fields permissively after default initialization and truth-sync rewrites/annotates derived mirror fields. | High: strict EXE parser could reject derived state and break active-plan coherence checks. | Unknown / needs human decision; treat as MT5-owned derived state and block strict-parser RAM cache. | Yes for prototype implementation; no for design-only. | Design-only raw-text metadata read allowed; implementation blocked until parser policy. | Conditional only after active_plan/current_plan coherence policy and parser policy are approved. | Metadata only; stale/derived label required. | No secret-specific redaction known; do not render entire state as runtime authority. |
| AI\ai_runtime_secrets.json | Yes | MQL loads `ai_enabled`, `api_key`, `model`, `base_url`, and `timeout_seconds` through permissive field extraction. | Critical confidentiality risk, not parser risk. | Reject unsafe broad access. EXE V1 must not read values unless a separate secret-handling task explicitly approves read-on-demand/startup-validation behavior. | Yes if Stage 2 requires secrets; no if Stage 2 excludes secrets completely. | No by default. Unknown / needs human decision for startup validation only. | No cache. Secret values must never be cached. | No value display. Redacted metadata only if explicitly approved. | Never print or log values; redact all secret-bearing fields as `<REDACTED>` and prefer key-presence booleans only. |
| AI\council_feedback.json | Yes; JSON array | MQL appends objects to an array and reads latest/summary data with permissive object/key extraction. | Medium: strict parser accepts current file, but append corruption or partial writes could break full-array parse. | Stage 2 may use tolerant streaming/line-safe or bounded array reader for derived summaries only; never runtime truth. | No for design-only; prototype allowed only for read-only derived summaries if strict parse remains valid. | Yes for read-only analytics/metadata after mtime/hash tracking. | Conditional derived-summary cache only; invalidate on mtime/size/hash change or parse error. | Yes as derived/stale-labeled view, not authority. | No known secrets; still avoid dumping full multi-MB report into dashboard. |

Notes:

- `AI\ai_current_plan.json`, `AI\ai_previous_plan_backup.json`, and `AI\ai_evolution_state.json` fail strict Python JSON parsing due to invalid backslash escape sequences. They were not modified.
- MQL parsing is field-oriented and permissive. `ExtractJsonStringField`, `ExtractJsonBoolField`, `ExtractJsonIntField`, `ExtractJsonDoubleField`, and array/object helpers scan text for fields rather than validating the full JSON document.
- Duplicate-key certainty remains **Unknown** for invalid strict JSON files because strict parsing aborts before a full object can be constructed.
- `AI\ai_runtime_secrets.json` was inspected only for parser status and key names. Secret values were not written here.

### 2. Authority Ownership Decisions

Gate decision: **EXE V1, dashboard V1, and developer tools V1 must not write runtime/config/status/state files. Runtime authority remains MT5-owned or existing-tool-owned as listed. Unknown ownership requires human confirmation before any Stage 2 prototype.**

| file/class | current known readers | current known writers | proposed single authority owner | multiple writers detected | EXE V1 may write | dashboard V1 may write | developer tool V1 may write | confirmation/logging/backup notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| ai_current_plan.json | main_ea.mq5, config_loader.mqh, docs/dashboard registries | MT5 truth annotation; rollback_engine via CopyFileText; plan_auto_apply code path exists; human/manual writer Unknown | MT5-owned for runtime truth; human-owned semantic edits require confirmation | Yes: MT5 modules plus possible human/manual | No | No | No in V1 | Future writes require explicit human confirmation, backup, diff, audit log, and post-write MT5 reload/validation. |
| ai_previous_plan_backup.json | rollback_engine/main_ea, docs/dashboard metadata | plan_auto_apply backup path; MT5 truth annotation; human/manual Unknown | MT5-owned rollback backup | Yes/Unknown | No | No | No in V1 | Future writes require backup-chain proof and rollback rehearsal approval. |
| ai_evolution_state.json | main_ea.mq5, config_loader.mqh, evolution engine, docs | SaveAIEvolutionStateToJson; truth-sync annotations; storage reset | MT5-owned generated/derived | Yes within MT5 runtime modules | No | No | No in V1 | Future writes require runtime stop/lock policy and current-plan coherence check. |
| ai_runtime_secrets.json | main_ea.mq5/config_loader.mqh; docs mention only | Human-owned or deployment-owned; actual writer Unknown | human-owned | Unknown | No | No | No in V1 | Future edits require secret-manager process, value redaction, and never a broad migration tool. |
| runtime_governance_status.* | main_ea operational integrity; dashboard collectors/registries; docs | main_ea SaveRuntimeGovernanceStatusBestEffort | MT5-owned/generated | No independent writer detected | No | No | No in V1 | Observe only; conflict if any non-MT5 writer appears. |
| execution_authority_status.* | main_ea operational integrity; dashboard collectors/registries; docs | main_ea SaveExecutionAuthorityStatusBestEffort | MT5-owned/generated | No independent writer detected | No | No | No in V1 | Observe only; never override authority from EXE/dashboard. |
| active_operating_cohort.* | main_ea operational integrity; dashboard collectors/registries/classifiers; docs | main_ea SaveActiveOperatingCohortStatusBestEffort | MT5-owned/generated | No independent writer detected | No | No | No in V1 | Observe only; stale cohort must block trading-adjacent EXE actions. |
| ai_performance_journal.jsonl | journal_analytics, council memory, trade feedback, dashboard summaries | performance_journal append helpers; storage reset archives/resets | MT5-owned append-only generated | Multiple append wrapper call sites, same helper family | No | No | No in V1 | Treat as volatile append-only; cache tail only with mtime/size/hash and partial-line handling. |
| council_feedback.json | main_ea, council memory/reporting, decision router, dashboard/report docs | SaveCouncilFeedbackRecord; AppendCouncilFeedbackJsonObject; storage reset | MT5-owned generated/report-memory | Multiple MT5 call sites, same append helper family | No | No | No in V1 | Read-only derived view; no EXE/dashboard repair or compaction. |
| adapter outputs | MT5 ATAS intake/advisory layers, dashboard monitor/validation tools | C# adapter/exporter AtomicJsonWriter/AtomicJsonFileWriter; Python runner writes capture/runner status | adapter-owned for adapter runtime outputs; MT5-owned for MT5-emitted ATAS status | Yes across adapter/exporter/runner/status writers | No | No | No in V1 | Separate ownership per file; do not let EXE supervise/write until adapter authority contract approved. |
| dashboard outputs | dashboard view/state tools and docs | dashboard collectors/tools may write capture snapshots/status files | generated | Yes | No | No authority writes; visibility-only generated output allowed only by existing tools | No in V1 | Dashboard must label source truth and never become runtime authority. |
| lock/stop sentinel files | external_dashboard ATAS propagation runner | runner creates/removes lock and stop files | generated | Potentially yes if operator/tooling interacts | No | No | Forbidden in V1 | Never cache as truth; manage only with explicit operator-controlled runner task. |

### 3. Freshness and Stale-Data Thresholds

Gate decision: **stale cache must never be treated as runtime truth. Trading-adjacent EXE behavior must fail closed when governance, authority, cohort, or active-plan freshness is missing, stale, invalid, or Unknown.**

| file/file class | stale danger | proposed freshness threshold | refresh trigger | invalidation trigger | failure behavior | stale data may be displayed | stale data may be runtime truth |
| --- | --- | --- | --- | --- | --- | --- | --- |
| ai_current_plan.json | critical | No stale runtime-truth use. Draft: invalidate immediately on mtime/hash change during read, parser failure, empty `plan_id`, or plan_id/mode mismatch. | Startup/load, explicit recompile, mtime/hash change | strict parse failure under EXE policy, permissive extraction failure, missing plan_id, active-mode mismatch, concurrent write | fail closed; block trading-adjacent EXE action; mark unavailable | Only stale-labeled metadata may be displayed | No |
| runtime_governance_status.* | critical | 600 seconds stale warning/partial; 1800 seconds expired/unavailable, matching source freshness calls | mtime change, evaluated_at/last_updated change, MT5 status refresh | missing file, placeholder, parse failure, age > 600/1800, startup state | fail closed for EXE actions; dashboard stale/unavailable label | Yes, stale-labeled only | No |
| execution_authority_status.* | critical | 600 seconds stale warning/partial; 1800 seconds expired/unavailable | mtime change, last_updated change, MT5 authority refresh | missing file, cutover not active, legacy authority active, age > 600/1800, parse failure | fail closed; block trading-adjacent EXE action | Yes, stale-labeled only | No |
| active_operating_cohort.* | high/critical | 600 seconds stale warning/partial; 1800 seconds expired/unavailable | mtime change, last_updated change, cohort refresh | missing file, no active cohort when required, age > 600/1800, parse failure | fail closed for cohort-dependent EXE actions; dashboard stale label | Yes, stale-labeled only | No |
| ai_evolution_state.json | high | Immediate invalid if active/current plan mirror does not match current plan. Draft age threshold Unknown / needs human confirmation; do not use seconds-only freshness as truth. | truth sync, mtime/hash change, current plan change | strict parse failure under EXE policy, mirror mismatch, empty derived state | keep last known only as stale-labeled derived view; block trading-adjacent EXE use | Yes, derived/stale-labeled only | No |
| ai_performance_journal.jsonl | medium | Informational only. Draft: tail cache invalidates on mtime/size/hash change; no strict age threshold without human policy. Current audit found 1 invalid JSONL line among 5614. | append/mtime/size change | partial line, invalid line, file shrink/reset, storage reset | warn only for visibility; skip bad line; never drive runtime truth | Yes as derived analytics with parse-warning label | No |
| adapter context/status outputs | high | Use existing dashboard monitor defaults as draft: exporter/adapter stale 30s expired 120s; MT5 intake/advisory stale 45s expired 180s. | packet_id, mtime, status_timestamp, freshness_state, adapter runner cycle | packet mismatch, expired status, rejected/blocked state, missing output, lock/runner failure | mark unavailable/stale; block trading-adjacent EXE action; dashboard warning | Yes, stale/unavailable labeling required | No |

### 4. Secret-Handling Policy

Gate decision: **Stage 2 is blocked for any secret-reading implementation. Stage 2 design may exclude secrets entirely.**

For `AI\ai_runtime_secrets.json` and any future secret-bearing file:

- EXE may read: **No by default / Unknown pending explicit human approval**.
- EXE may cache: **No**.
- Dashboard may display: **No values ever**. Redacted metadata only if approved.
- Logs may include values: **No**.
- Redaction rule: any value for keys such as `api_key`, token, password, credential, secret, endpoint with sensitive identity, or equivalent must be rendered as `<REDACTED>` or omitted. Key names and boolean presence may be reported only if approved.
- Access timing: **never** by default. `startup validation only` or `read-on-demand` requires separate approved secret-policy task.
- Failure behavior: if secret access is required but policy is missing, mark unavailable and block the secret-dependent EXE path.
- Audit/logging behavior: log only file presence, mtime/hash if allowed, key-presence booleans if approved, and redaction status; never log values.
- Stage 2 blocked by missing secret policy: **Yes for any implementation that reads or validates secrets; No for design-only work that excludes secrets.**

### 5. Missing Runtime Surface Classification

Gate decision: **Stage 2 design may list missing surfaces, but any cache/prototype/dashboard truth that depends on an Unknown or feature-gated missing surface is blocked until human classification confirms generated/optional/required/legacy status.**

| referenced path | referenced by | expected format | likely purpose | Stage 1.5 classification | Stage 2 blocked | recommended next action |
| --- | --- | --- | --- | --- | --- | --- |
| AI\ai_last_evolution_raw.txt | AI\main_ea.mq5:12977<br>AI\main_ea.mq5:12988<br>…(+1) | TXT key/value or report | MT5 feedback/evolution checkpoint | generated-at-runtime | No for design-only; no cache/write in Stage 2 | Confirm whether evolution proposal logging is expected in this runtime. |
| AI\ai_last_recorded_feedback_order.txt | AI\storage_reset_pre_strategy_memory_v1.mqh:112 | TXT key/value or report | MT5 feedback/evolution checkpoint | generated-at-runtime | No for design-only; cache/write behavior blocked until MT5 dedupe semantics confirmed | Confirm whether absence means reset baseline or feature unused. |
| AI\ai_last_recorded_feedback_position.txt | AI\storage_reset_pre_strategy_memory_v1.mqh:113 | TXT key/value or report | MT5 feedback/evolution checkpoint | generated-at-runtime | No for design-only; cache/write behavior blocked until MT5 dedupe semantics confirmed | Confirm whether absence means reset baseline or feature unused. |
| AI\atas_live_capture\atas_propagation_runner.lock | AI\external_dashboard\tools\atas_live_propagation_runner.py:233/378 | sentinel/lock | dashboard runner lock sentinel | generated-at-runtime | No for design-only; blocked for runner/runtime-control implementation until lifecycle policy approved | Confirm runner output directory and volatile retention; do not cache lock/status as truth. |
| AI\atas_live_capture\freshness_isolation_report_{timestamp}.json | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:650 | JSON object/array | generated timestamp output | generated-at-runtime | No for design-only; blocked for runner/runtime-control implementation until lifecycle policy approved | Confirm runner output directory and volatile retention; do not cache lock/status as truth. |
| AI\atas_live_capture\periodic_validation_cycles_{timestamp}.jsonl | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:646 | JSONL events | generated timestamp output | generated-at-runtime | No for design-only; blocked for runner/runtime-control implementation until lifecycle policy approved | Confirm runner output directory and volatile retention; do not cache lock/status as truth. |
| AI\atas_live_capture\periodic_validation_summary_{timestamp}.json | AI\external_dashboard\tools\atas_periodic_propagation_validation.py:648 | JSON object/array | generated timestamp output | generated-at-runtime | No for design-only; blocked for runner/runtime-control implementation until lifecycle policy approved | Confirm runner output directory and volatile retention; do not cache lock/status as truth. |
| AI\council_activation_pressure_status.json | AI\main_ea.mq5:9361 CouncilActivationPressureStatusJsonPath()<br>AI\main_ea.mq5:9434 via CouncilActivationPressureStatusJsonPath()<br>…(+1) | JSON object/array | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_activation_pressure_status.txt | AI\main_ea.mq5:9360 CouncilActivationPressureStatusTxtPath()<br>AI\main_ea.mq5:9433 via CouncilActivationPressureStatusTxtPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_dirty_environment_status.json | AI\main_ea.mq5:9461 CouncilDirtyEnvironmentStatusJsonPath()<br>AI\main_ea.mq5:9514 via CouncilDirtyEnvironmentStatusJsonPath()<br>…(+1) | JSON object/array | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_dirty_environment_status.txt | AI\main_ea.mq5:9460 CouncilDirtyEnvironmentStatusTxtPath()<br>AI\main_ea.mq5:9513 via CouncilDirtyEnvironmentStatusTxtPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_execution_quality_status.json | AI\main_ea.mq5:9271 CouncilExecutionQualityStatusJsonPath()<br>AI\main_ea.mq5:9329 via CouncilExecutionQualityStatusJsonPath()<br>…(+1) | JSON object/array | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_execution_quality_status.txt | AI\main_ea.mq5:9270 CouncilExecutionQualityStatusTxtPath()<br>AI\main_ea.mq5:9328 via CouncilExecutionQualityStatusTxtPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_live_exit_state.json | AI\core_trade_engine.mqh:762<br>AI\core_trade_engine.mqh:815 | JSON object/array | MT5 council status/state surface | unknown | Yes for live-exit cache/prototype; design-only may list it | Human must decide whether absence is normal when no live council exits are active. |
| AI\council_live_exit_status.json | AI\core_trade_engine.mqh:876 | JSON object/array | MT5 council status/state surface | generated-at-runtime | No for design-only; block dashboard truth until feature enablement confirmed | Confirm live-exit feature enablement and expected writer cadence. |
| AI\council_live_exit_status.txt | AI\core_trade_engine.mqh:873 | TXT key/value or report | MT5 council status/state surface | generated-at-runtime | No for design-only; block dashboard truth until feature enablement confirmed | Confirm live-exit feature enablement and expected writer cadence. |
| AI\council_setup_lifecycle_state.json | AI\main_ea.mq5:1826 CouncilSetupLifecycleStatePath()<br>AI\main_ea.mq5:8997 via CouncilSetupLifecycleStatePath()<br>…(+2) | JSON object/array | MT5 council status/state surface | unknown | Yes for lifecycle cache/prototype; design-only may list it | Confirm whether lifecycle gate is enabled and whether missing state should initialize defaults. |
| AI\council_setup_lifecycle_status.txt | AI\main_ea.mq5:1827 CouncilSetupLifecycleStatusPath()<br>AI\main_ea.mq5:9079 via CouncilSetupLifecycleStatusPath()<br>…(+1) | TXT key/value or report | MT5 council status/state surface | generated-at-runtime | No for design-only; block dashboard truth until enablement confirmed | Confirm lifecycle gate enablement and writer cadence. |
| AI\council_trend_cont_confirmation_status.json | AI\council_mode_runtime.mqh:160 | JSON object/array | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |
| AI\council_trend_cont_confirmation_status.txt | AI\council_mode_runtime.mqh:159 | TXT key/value or report | MT5 council status/state surface | generated-at-runtime | No for design-only; block caching as runtime truth until opt-in gate enablement confirmed | Confirm if corresponding opt-in council gate is enabled; otherwise treat as optional/generated. |

Summary:

- Missing surfaces classified as generated-at-runtime or optional/generated do not block Stage 2 design-only work.
- Missing surfaces classified as `unknown` block any implementation/prototype that depends on them.
- Council opt-in gate statuses appear generated by dormant/feature-gated code paths when enabled; human confirmation is still required before treating absence as safe.

### 6. Stage 2 Readiness Gate

Decision:

- **APPROVED for Stage 2 design only.**
- **BLOCKED pending JSON policy** for any strict-parser RAM loader or runtime-critical JSON cache.
- **BLOCKED pending authority policy** for any writer, repair, normalization, dashboard-authority, adapter-supervisor, or developer-tool write path.
- **BLOCKED pending missing files** for any cache/prototype that depends on the 20 missing surfaces.
- **BLOCKED pending secrets policy** for any EXE read/cache/display/log behavior involving secret-bearing files.
- **BLOCKED pending human review** before Stage 2 limited prototype or implementation.

Rationale:

- Critical JSON parser mismatch remains unresolved.
- Active plan, governance, authority, cohort, and secrets surfaces are too sensitive for implementation without explicit policy approval.
- Missing runtime surfaces include feature-gated council/live-exit/lifecycle files whose absence may be normal, fatal, or stale depending on live runtime configuration.
- Dashboard and adapter outputs remain visibility/derived surfaces, not runtime authority.

### 7. Stage 2 Allowed Scope Draft

Allowed scope for Stage 2 **design-only**:

- Read-only cache registry specification only.
- No writes.
- No secret value reads.
- No secret cache.
- No dashboard authority.
- Checksum/mtime/size tracking design only.
- Parser-mode design only: permissive compatibility parser vs strict normalization vs strict shadow copy.
- Stale labeling design only.
- No trading decisions.
- No MT5 file modifications.
- No JSON/config normalization.
- No placeholder generation for missing files.
- No adapter runner supervision.
- No lock/stop sentinel manipulation.
- No developer repair tooling.

Not approved:

- Stage 2 limited prototype.
- Stage 2 runtime cache implementation.
- RAM loader implementation.
- Dashboard implementation.
- EXE implementation.
- Adapter supervisor implementation.
- Developer tool implementation.
- Any runtime/config/status/log/state write.

### 8. Developer Tool Boundary Draft

| possible tool action | boundary decision | logging/backup requirement | safety note |
| --- | --- | --- | --- |
| JSON compatibility audit/normalization proposal | observe-only now; future confirm-before-write | Audit log required; future normalization requires timestamped backup and diff | Forbidden to auto-fix in Stage 1.5/Stage 2 design. |
| Missing runtime surface checker | observe-only | Log missing/present decisions only | Must not create placeholder files. |
| Cache registry design/spec | observe-only | Log source path, mtime, size, hash, parser mode | No runtime writes; no secret cache. |
| Dashboard truth-labeling spec | observe-only | Log source authority and stale label mapping | Dashboard remains visibility-only. |
| Secret redaction policy task | observe-only | Log key names and redaction decisions only | Never log secret values. |
| Adapter/runner supervisor action | forbidden in V1 | No start/stop/kill/lock manipulation | Defer to V2 after ownership and lock lifecycle approval. |
| Developer repair/normalization tools | confirm-before-write only after separate approval | Mandatory backup, dry-run diff, rollback path | Forbidden for trading/config/state in current gate. |

### 9. Risks and Mitigations Update

| risk | Stage 1.5 finding | mitigation / gate |
| --- | --- | --- |
| strict JSON mismatch | Active plan, backup, and evolution state reject under strict parsers. | Block strict-parser RAM loader; require human JSON policy decision. |
| plan cache desync | A cached active plan could diverge from MT5 truth or rollback writes. | No runtime-truth cache until mtime/hash/coherence contract approved. |
| stale authority status | Governance/authority/cohort stale data could mislead EXE or dashboard. | Use 600/1800 source thresholds; fail closed for EXE actions. |
| secret exposure | Secret-bearing config exists and includes sensitive-key fields. | No cache, no logs, no dashboard values; separate secret policy task. |
| multiple writers | MT5 modules, adapter writers, runner tools, and possible human edits can conflict. | Single-owner map; EXE/dashboard V1 write forbidden. |
| missing runtime files | 20 referenced surfaces are absent in archive. | Classify generated/optional/unknown; block implementation using unknown surfaces. |
| false dashboard authority | Dashboard/capture outputs could be mistaken for runtime truth. | Truth labels and must-never-be-authority rules. |
| accidental adapter/tool writes | Python/C# tools contain atomic writes, locks, and status outputs. | Stage 2 design observe-only; adapter supervisor deferred. |
| JSONL partial/corrupt line | ai_performance_journal.jsonl has one strict JSONL line failure in audit. | Derived analytics must skip/warn and never drive runtime truth. |

### 10. Open Questions Update

- Human decision required: compatibility parser vs strict normalization vs strict shadow copy for `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json`.
- Human decision required: exact single owner for semantic edits to `ai_current_plan.json` outside MT5 truth annotation.
- Unknown: whether human/operator manual edits are expected for plan, backup, evolution, and secrets files.
- Unknown: whether Stage 2 may perform any read of `ai_runtime_secrets.json`; current decision forbids secret value reads unless separately approved.
- Unknown: whether missing council/live-exit/lifecycle status files are expected absent because gates are disabled, generated only in live runtime, or stale references.
- Unknown: live MT5 terminal root/path contract and whether archive paths mirror active production paths.
- Unknown: concurrency/locking mechanism for MT5 writes vs external EXE reads.
- Unknown: acceptable stale thresholds for plan/evolution/journal beyond source-observed governance/authority/cohort and dashboard ATAS defaults.
- Unknown: whether dashboard output retention and volatile capture files are production obligations or generated diagnostics.

### 11. Recommended Stage 2 Prerequisites

- Approve JSON compatibility policy before any strict JSON RAM loader or cache registry implementation.
- Approve authority ownership map and confirm EXE/dashboard/developer-tool V1 write prohibition.
- Confirm missing runtime surfaces as generated-at-runtime, optional, required/fatal, or legacy.
- Approve secret-handling policy, especially whether EXE may ever read secret-bearing config.
- Approve freshness/stale thresholds for plan/evolution/journal and concurrency invalidation rules.
- Confirm live MT5 terminal root and file path resolution behavior.

### 12. Codex Task Backlog Update

| future task | bounded scope |
| --- | --- |
| JSON normalization proposal task | Produce dry-run diff proposal only; no JSON modification without approval. |
| Missing runtime surface confirmation task | Human classify each of the 20 missing surfaces as generated/optional/required/legacy. |
| RAM loader design spec task | Design only: parser modes, hash/mtime tracking, invalidation, stale labels; no code. |
| Cache registry skeleton task | Only after gate approval; read-only metadata registry; no secrets, no writes. |
| Dashboard truth-labeling spec task | Map each displayed field to authoritative/cached/derived/stale/unavailable. |
| Secret redaction policy task | Define allowed metadata and redaction patterns; no values. |

### 13. Stage 1.5 Completion Criteria

- JSON policy documented with explicit blockers: **complete**.
- Authority ownership decisions documented with EXE/dashboard/developer-tool write prohibition: **complete**.
- Freshness/stale threshold draft documented: **complete**.
- Secret-handling policy documented without values: **complete**.
- Missing runtime surfaces classified with blockers/actions: **complete**.
- Stage 2 readiness decision clearly stated: **complete**.
- Implementation work avoided: **complete**.

## Stage 1.6 — Human Decision Worksheet and Gate Checklist

### 1. Executive Gate Status

| Gate | Status | Notes |
|---|---:|---|
| Stage 0 Discovery | Complete | Inventory and classification completed. |
| Stage 1 Data Contract | Complete | Runtime file references, authority map, schema expectations, JSON audit, and cache-eligibility draft completed. |
| Stage 1.5 Gate Resolution | Complete | Blockers and safe defaults documented. |
| Stage 2 Design | Approved | Design/specification work only. No executable implementation. |
| Stage 2 Prototype/Implementation | Blocked | Blocked by JSON policy, authority policy, missing runtime surface classification, secrets policy, and pending human review. |
| Reason for block | Active | JSON parser/normalization decision, writer ownership, missing surfaces, secret access, path contract, and read-concurrency policy remain undecided. |

### 2. Human Approval Matrix

All undecided items below are intentionally marked **Pending Human Decision**. Recommended safe defaults are conservative and do not imply approval to implement.

| Decision ID | Area | Decision required | Recommended safe default | Options | Risk if undecided | Blocks Stage 2 implementation | Human decision | Decision date | Notes |
|---|---|---|---|---|---|---:|---|---|---|
| DEC-JSON-001 | JSON compatibility | Choose parser policy for invalid strict JSON runtime files. | Design compatibility parser first; do not change runtime JSON. | compatibility parser / normalize later / strict shadow copy / reject unsafe file / unknown | EXE strict parser may reject runtime files that MT5 currently tolerates. | yes | Pending Human Decision | Pending | Applies to `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json`. |
| DEC-JSON-002 | JSON compatibility | Decide whether runtime-critical JSON files may be normalized in a later approved task. | Do not normalize during Stage 2 design. | no normalization / later approved normalization / unknown | Config-format drift could change MT5 behavior. | yes | Pending Human Decision | Pending | Any normalization requires separate backup, validation, and rollback task. |
| DEC-JSON-003 | JSON compatibility | Decide whether strict shadow copies may be created later. | Consider design only; create no files now. | no shadow copy / strict shadow copies / unknown | Shadow copies can desync from runtime truth. | yes | Pending Human Decision | Pending | Shadow copies must never become runtime authority unless separately approved. |
| DEC-AUTH-001 | Authority | Confirm single authority for `ai_current_plan.json` runtime truth. | MT5 runtime-authoritative; EXE observe-only. | MT5-owned / human-owned semantic input / EXE-owned / unknown | Multiple runtime authorities can cause plan cache desync. | yes | Pending Human Decision | Pending | EXE V1 must not become authority. |
| DEC-AUTH-002 | Authority | Define human semantic-edit process for `ai_current_plan.json`. | Approved manual process only; no EXE V1 writes. | manual edit with backup / dedicated editor later / forbidden / unknown | Silent edits can bypass validation and create runtime ambiguity. | yes | Pending Human Decision | Pending | Requires backup/logging if future writes are allowed. |
| DEC-AUTH-003 | Authority | Confirm single authority for governance/status/cohort outputs. | Treat as MT5-owned/generated; EXE observe-only. | MT5-owned / generated / script-owned / EXE-owned / unknown | Stale or conflicting status can falsely authorize runtime-adjacent actions. | yes | Pending Human Decision | Pending | Includes `runtime_governance_status.*`, `execution_authority_status.*`, and `active_operating_cohort.*`. |
| DEC-WRITE-001 | Write boundary | Decide whether EXE V1 may write runtime/config/state files. | No writes. | no writes / managed writes later / unknown | EXE could corrupt runtime state or become unintended authority. | yes | Pending Human Decision | Pending | Future writes require explicit file allowlist, backup, locking, and audit logs. |
| DEC-WRITE-002 | Write boundary | Decide whether dashboard V1 may write runtime/config/state files. | No writes; visibility-only. | visibility-only / confirm-before-write later / unknown | Dashboard may become false runtime authority. | yes | Pending Human Decision | Pending | Dashboard data must remain cached/derived/unavailable labeled. |
| DEC-WRITE-003 | Write boundary | Decide whether developer tool V1 may write runtime/config/state files. | No runtime/config/state writes. | observe-only / confirm-before-write later / forbidden / unknown | Tooling could accidentally rewrite production runtime files. | yes | Pending Human Decision | Pending | Any future write needs backup, dry-run, confirmation, and audit trail. |
| DEC-SECRET-001 | Secret handling | Decide whether EXE may read `ai_runtime_secrets.json`. | No secret reads by default. | never / startup validation only / read-on-demand / unknown | Secret exposure or logging risk. | yes | Pending Human Decision | Pending | Values must never be written to the plan, dashboard, or logs. |
| DEC-SECRET-002 | Secret handling | Decide whether EXE may cache secrets. | No cache. | no cache / encrypted memory only later / unknown | Cached secrets can leak through memory, logs, dumps, or UI. | yes | Pending Human Decision | Pending | Any exception requires explicit justification and redaction policy. |
| DEC-SECRET-003 | Secret handling | Decide whether dashboard may display secret metadata. | No display except possibly redacted metadata after approval. | none / redacted metadata / unknown | Dashboard can expose sensitive identifiers. | yes | Pending Human Decision | Pending | No secret values; metadata-only display requires approval. |
| DEC-MISS-001 | Missing surfaces | Classify missing council surfaces. | Treat unresolved surfaces as blockers for dependent Stage 2 work. | required/fatal / optional / generated-at-runtime / legacy / unknown | Stage 2 may depend on files not present or not produced. | yes | Pending Human Decision | Pending | Use Stage 1 missing-runtime-surface list as source of review. |
| DEC-MISS-002 | Missing surfaces | Classify missing live-exit/lifecycle surfaces. | Treat as Unknown until live runtime behavior is confirmed. | required/fatal / optional / generated-at-runtime / legacy / unknown | Lifecycle actions could be misread or ignored. | yes | Pending Human Decision | Pending | Do not design cache dependency until confirmed. |
| DEC-MISS-003 | Missing surfaces | Classify generated ATAS/status surfaces. | Treat as generated/optional unless explicitly required. | required/fatal / optional / generated-at-runtime / legacy / unknown | Adapter/dashboard readiness may be overstated. | yes | Pending Human Decision | Pending | Missing generated outputs must be unavailable-labeled. |
| DEC-FRESH-001 | Freshness | Approve freshness threshold for governance/authority/cohort files. | 600s stale, 1800s expired/unavailable. | accept draft / tighten / loosen / unknown | Stale authority state may appear valid. | yes | Pending Human Decision | Pending | Draft mirrors discovered runtime checks; still requires approval. |
| DEC-FRESH-002 | Freshness | Approve freshness threshold for ATAS exporter/adapter outputs. | 30s stale and 120s expired for exporter; 45s stale and 180s expired for advisory/intake. | accept draft / tighten / loosen / unknown | Stale market/context data can mislead visibility layers. | yes | Pending Human Decision | Pending | Dashboard may display stale data only with explicit warning. |
| DEC-FRESH-003 | Freshness | Approve freshness policy for `ai_current_plan.json`. | Do not use stale plan as runtime truth; cache only with hash/mtime validation and stale labels. | no cache / conditional cache / unknown | Current-plan cache desync can misrepresent active strategy. | yes | Pending Human Decision | Pending | Any parse/coherence/hash mismatch invalidates cache. |
| DEC-CONC-001 | Concurrency | Define EXE read policy while MT5 may write files. | Read-only with checksum/mtime recheck; no writes or locks that can block MT5. | snapshot-read / retry-on-change / lock protocol later / unknown | Partial reads or race conditions can corrupt EXE interpretation. | yes | Pending Human Decision | Pending | Stage 2 design may specify strategies only. |
| DEC-PATH-001 | Path contract | Confirm live MT5 terminal root and project-relative path mapping. | Do not assume; require explicit terminal root/path contract. | archive-root / terminal-data-path / FILE_COMMON / custom root / unknown | EXE may read stale archive files instead of live runtime files. | yes | Pending Human Decision | Pending | Must resolve before any prototype. |
| DEC-STAGE2-001 | Stage 2 scope | Approve Stage 2 design-only work. | Approve design/specification only. | approve design / block all / unknown | Lack of approval stalls safe design work. | no | Pending Human Decision | Pending | No implementation, no file writes outside migration plan. |
| DEC-STAGE2-002 | Stage 2 scope | Define approval criteria for any future Stage 2 prototype. | Prototype remains blocked until all critical gates are approved. | blocked / limited prototype later / unknown | Prototype may begin before safety boundaries exist. | yes | Pending Human Decision | Pending | Prototype must require explicit human sign-off. |

### 3. Recommended Safe Defaults

Unless a human decision explicitly overrides them:

- Use compatibility parser design first; do not normalize runtime JSON yet.
- Treat `ai_current_plan.json` as MT5 runtime-authoritative.
- Allow human semantic edits only through an approved process, not EXE V1.
- EXE V1 remains observe/read-only only.
- Dashboard V1 remains visibility-only only.
- Developer Tool V1 performs no runtime/config/state writes.
- `ai_runtime_secrets.json`: no read, no cache, no display, no logged values by default.
- Missing runtime surfaces must not be dependencies for Stage 2 work until classified.
- Stale data may be displayed only with explicit stale labels.
- Stale data must never become runtime truth.
- Stage 2 allowed work is design/specification only.

### 4. Stage 2 Design-Only Scope

Allowed Stage 2 design-only work:

- RAM cache registry specification.
- File classification table refinement.
- Parser-mode design.
- Checksum/mtime/size tracking design.
- Stale-state labeling model.
- Failure behavior matrix.
- Dashboard truth-labeling specification.

Explicitly out of scope:

- No executable implementation.
- No RAM loader implementation.
- No dashboard implementation.
- No adapter supervisor implementation.
- No developer-tool implementation.
- No file writes outside `MT5_EXE_MIGRATION_PLAN.md`.
- No secrets-handling implementation.
- No MT5/config/state/log modification.
- No runtime JSON normalization.
- No trading-logic change.

### 5. Stage 2 Prototype Entry Criteria

Before any prototype, all criteria below require human approval:

- Human-approved JSON compatibility policy.
- Human-approved authority ownership matrix.
- Human-approved secret-handling policy.
- Human-approved missing surface classification.
- Human-approved live MT5 terminal root/path contract.
- Human-approved concurrency/locking/read policy.
- Explicit list of files allowed for read-only cache.
- Explicit list of files forbidden from cache.
- Explicit rollback strategy.
- Validation approach for parser compatibility.
- Confirmation that MT5 behavior remains unchanged.

### 6. Implementation Blockers

Current blockers:

- Invalid strict JSON in `ai_current_plan.json`, `ai_previous_plan_backup.json`, and `ai_evolution_state.json`.
- Unresolved compatibility parser vs normalization vs shadow-copy decision.
- Unresolved single writer/semantic owner for `ai_current_plan.json`.
- Unresolved classification of some missing runtime surfaces.
- Unresolved secret read/access policy.
- Unresolved live MT5 terminal root/path contract.
- Unresolved read-concurrency policy while MT5 writes files.
- JSON file-count discrepancy between Stage 1 and Stage 1.5 reports: current archive inspection shows 363 `.json` files. No JSON file changed in Stage 1.6. Treat prior `362` vs `363` as a counting-method/reporting discrepancy unless a later file-by-file audit proves otherwise.
- No approval exists for Stage 2 prototype or implementation.

### 7. Required Human Sign-Off Template

```text
Approved by:
Date:
Approved decisions:
Deferred decisions:
Stage 2 design-only approved: yes/no
Stage 2 prototype approved: no by default
Notes:
```

### 8. Codex Task Backlog Update

Bounded future tasks only:

| Task | Boundary |
|---|---|
| Stage 2A RAM cache registry design spec | Specification only; no implementation, no runtime reads, no writes. |
| JSON compatibility parser design spec | Define parser modes, validation cases, and failure behavior; do not normalize files. |
| Missing runtime surfaces confirmation worksheet | Classify each missing surface as required/fatal, optional, generated-at-runtime, legacy/stale, or Unknown. |
| Dashboard truth-labeling design spec | Define authoritative/cached/derived/stale/unavailable labels; dashboard remains visibility-only. |
| Secret redaction/access policy spec | Define redaction and access rules; no secret values printed or cached. |
| Read-concurrency and file-locking design spec | Define snapshot/retry/hash/mtime strategy; do not block MT5 writes. |

### 9. Stage 1.6 Completion Criteria

- Executive gate status recorded: **complete**.
- Human approval matrix recorded with all unresolved decisions marked **Pending Human Decision**: **complete**.
- Recommended safe defaults recorded: **complete**.
- Stage 2 design-only scope recorded: **complete**.
- Stage 2 prototype entry criteria recorded: **complete**.
- Implementation blockers recorded: **complete**.
- Required human sign-off template recorded: **complete**.
- Future Codex task backlog updated without implementation: **complete**.
## Stage 2A — RAM Cache Registry Design Spec

Generated: 2026-04-25  
Scope: design-only cache registry specification based on Stage 0, Stage 1, Stage 1.5, and Stage 1.6 findings.  
Gate state inherited from Stage 1.6: Stage 2 design-only is approved; Stage 2 prototype/implementation remains blocked.

### 1. Design Scope and Non-Goals

This section is design-only.

Non-goals and hard boundaries:

- No RAM loader implementation.
- No EXE implementation.
- No dashboard implementation.
- No file watcher implementation.
- No parser implementation.
- No JSON normalization.
- No runtime/config/status/log writes.
- No secret reads or caching.
- No trading decision authority.
- No stale cache may be treated as runtime truth.
- No human approval is inferred; unresolved decisions remain **Pending Human Decision**.
- Dashboard V1 remains visibility-only.
- EXE remains non-authoritative.

### 2. Cache Registry Principles

The cache registry is a proposed read-view design, not an implementation.

Principles:

- Source files remain authoritative according to their current owner unless a later human-approved decision changes ownership.
- RAM cache is a performance/read-view layer only.
- Cache reads must never change MT5 behavior.
- Cache entries must never write back to runtime/config/status/log/state files in Stage 2A or any blocked prototype state.
- Any parse failure, stale condition, missing file, or authority uncertainty must be visible.
- Dashboard surfaces must display truth labels and must never become runtime authority.
- Secret-bearing files are denylisted by default.
- Generated or volatile files are not safe to cache unless freshness, invalidation, and authority rules are explicit.
- Stale data may be displayed only with explicit stale labels and must never become runtime truth.
- Partial writes must not be parsed as truth.

Required metadata for every future cache entry:

| Metadata field | Required meaning |
| --- | --- |
| source_path | Original source path or file class. |
| authority_owner | MT5-owned, human-owned, adapter-owned, dashboard-owned, generated, script-owned, EXE-owned, or Unknown. |
| parser_mode | Parser/read mode selected from the Stage 2A parser mode matrix. |
| mtime | Source file modification timestamp captured during stable read. |
| size | Source file byte size captured during stable read. |
| checksum/hash | Checksum after stable read. |
| loaded_at | Time cache entry was first loaded in process. |
| refreshed_at | Time cache entry was last refreshed. |
| freshness_state | fresh, stale, expired, unavailable, forbidden, or Unknown. |
| stale_after_seconds | Draft stale threshold or `not applicable`. |
| expired_after_seconds | Draft expiry threshold or `not applicable`. |
| parse_status | valid, invalid, partial, skipped, forbidden, or Unknown. |
| last_error | Last read/parse/validation error, without secret values. |
| truth_label | Dashboard-safe label: authoritative file truth, cached view, derived view, stale cached view, expired/unavailable, forbidden/secret, or unknown/unclassified. |
| access_mode | observe-only, cache-read, existence-live-check, forbidden, or Unknown. |
| secret_classification | none, secret-bearing, possible-secret, redacted-metadata-only, or Unknown. |

### 3. RAM Cache Registry Table

| Registry ID | File or file class | Layer | Authority owner | Exists in archive | Runtime criticality | Access mode | Cache eligibility | Parser mode | Freshness threshold | Expiry threshold | Refresh trigger | Invalidation trigger | Failure behavior | Dashboard truth label | Secret exposure risk | Stage 2B allowed? | Human decision dependency | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| CACHE-CFG-001 | AI\ai_current_plan.json | Configuration Layer / MT5 Runtime Layer | MT5-owned runtime truth; human semantic owner Pending Human Decision | Yes | execution-critical / config-critical | cache-read design only | conditional | compatibility-json required; strict-json not sufficient now | event/hash/mtime/coherence driven; no stale runtime-truth use | not approved for runtime truth from RAM | mtime/hash/plan identifier/coherence change | parse failure, coherence failure, hash/mtime instability, human-applied plan update | fail closed for trading-adjacent EXE action; mark unavailable or stale-labeled display only | authoritative file truth when read live; cached view or stale cached view when cached | possible sensitive strategy/config data | Design-only yes; prototype no until gates approved | DEC-JSON-001; DEC-AUTH-001; DEC-CONC-001; DEC-PATH-001 | Invalid strict JSON in current archive; compatibility policy must be approved before parser/prototype. |
| CACHE-CFG-002 | AI\ai_previous_plan_backup.json | Configuration / rollback reference | MT5-owned/generated backup; semantic owner Unknown | Yes | config-critical / report-only backup | cache-read design only | conditional | compatibility-json required; strict-json not sufficient now | event/hash/mtime driven | not approved as runtime truth | mtime/hash change or rollback event | parse failure, unstable read, backup-current mismatch | mark unavailable; never promote to current runtime truth | cached view / derived rollback reference | possible sensitive strategy/config data | Design-only yes; prototype no until gates approved | DEC-JSON-001; DEC-AUTH-001; DEC-CONC-001 | Invalid strict JSON in current archive; not runtime truth. |
| CACHE-CFG-003 | AI\ai_evolution_state.json | State/Status Layer | MT5-owned/generated or Unknown | Yes | state-critical | cache-read design only | conditional | compatibility-json required; strict-json not sufficient now | event/hash/mtime driven | not approved for stale runtime use | mtime/hash/evolution state change | parse failure, rollback mismatch, unstable read | mark unavailable; block trading-adjacent EXE action if depended on | cached view / derived view | possible strategy metadata | Design-only yes; prototype no until gates approved | DEC-JSON-001; DEC-AUTH-003; DEC-CONC-001 | Invalid strict JSON in current archive. |
| CACHE-SEC-001 | AI\ai_runtime_secrets.json | Configuration Layer / Secret-bearing | human-owned / secret-bearing | Yes | config-critical / security-critical | forbidden by default | unsafe / denylisted | forbidden; no value parser by default | no cache | no cache | none | any attempted secret read/cache/display/log | block access; human review required; log only redacted metadata if later approved | forbidden/secret | critical | No | DEC-SECRET-001; DEC-SECRET-002; DEC-SECRET-003 | Valid strict JSON but forbidden to cache/read/display by default. |
| CACHE-STATE-001 | AI\runtime_governance_status.* | State/Status Layer | MT5-owned/generated | Yes | execution-critical / state-critical | cache-read design only | conditional | strict-json for .json if valid; text-status for .txt | 600 | 1800 | mtime/hash/timer/tick/status timestamp change | stale/expired, parse failure, missing pair, mtime regression | stale = stale-labeled and block trading-adjacent EXE action; expired = unavailable/fail closed | authoritative file truth when live; cached view/stale cached view | low/medium | Design-only yes; prototype no until gates approved | DEC-AUTH-003; DEC-FRESH-001; DEC-CONC-001 | Threshold mirrors Stage 1.5 draft from MQL freshness checks. |
| CACHE-STATE-002 | AI\execution_authority_status.* | State/Status Layer | MT5-owned/generated | Yes | execution-critical / state-critical | cache-read design only | conditional | strict-json for .json if valid; text-status for .txt | 600 | 1800 | mtime/hash/timer/tick/status timestamp change | stale/expired, authority contradiction, parse failure, mtime regression | stale = stale-labeled and block trading-adjacent EXE action; expired = unavailable/fail closed | authoritative file truth when live; cached view/stale cached view | low/medium | Design-only yes; prototype no until gates approved | DEC-AUTH-003; DEC-FRESH-001; DEC-CONC-001 | Must never allow stale authority state to drive EXE action. |
| CACHE-STATE-003 | AI\active_operating_cohort.* | State/Status Layer | MT5-owned/generated | Yes | execution-critical / state-critical | cache-read design only | conditional | strict-json for .json if valid; text-status for .txt | 600 | 1800 | mtime/hash/timer/tick/status timestamp change | stale/expired, cohort missing/contradiction, parse failure | stale = stale-labeled and block trading-adjacent EXE action; expired = unavailable/fail closed | authoritative file truth when live; cached view/stale cached view | low/medium | Design-only yes; prototype no until gates approved | DEC-AUTH-003; DEC-FRESH-001; DEC-CONC-001 | Cohort cache must not override live MT5 cohort admission. |
| CACHE-JOURNAL-001 | AI\ai_performance_journal.jsonl | Report/Memory Layer / State append log | MT5-owned/generated | Yes | report-only / analytics | cache-read design only | conditional | jsonl-warn-skip | derived analytics; no runtime truth threshold | not runtime truth | append offset, mtime/size growth | invalid line, truncation, mtime regression | warn/skip invalid lines; analytics unavailable on failure | derived view | low/medium | Design-only yes; prototype no until gates approved | DEC-CONC-001; cache allowlist approval | Stage 1 found at least one invalid JSONL line; never runtime truth. |
| CACHE-FEEDBACK-001 | AI\council_feedback.json | Report/Memory Layer | MT5-owned/generated or human-reviewed feedback; exact semantic owner Unknown | Yes | report-only / advisory memory | cache-read design only | conditional | strict-json if valid | mtime/hash driven | not runtime truth | mtime/hash change | parse failure, unstable read, schema mismatch | mark unavailable for analytics; no trading-adjacent action | derived view / cached view | possible strategy comments | Design-only yes; prototype no until gates approved | DEC-AUTH-003; DEC-CONC-001 | Valid strict JSON in Stage 1 audit. |
| CACHE-ADAPTER-001 | ATAS exporter outputs | EXE/Adapter Layer / Generated/Volatile | adapter-owned/generated | Mixed / generated | visibility/advisory; possible high stale risk | cache-read design only | conditional | strict-json, jsonl-warn-skip, or text-status depending surface | 30 | 120 | packet timestamp, mtime/hash, exporter cycle | stale packet, missing exporter heartbeat, parse failure, mtime regression | stale-labeled display; block trading-adjacent EXE action | adapter-owned cached view / stale cached view | low/medium | Design-only yes; prototype no until gates approved | DEC-FRESH-002; DEC-AUTH-003; DEC-CONC-001 | Adapter data cannot become execution authority. |
| CACHE-ADAPTER-002 | ATAS intake/advisory/status outputs | EXE/Adapter Layer / Generated/Volatile | adapter-owned or MT5-owned mirror; exact per-file authority Pending Human Decision | Mixed / generated | advisory/visibility; high stale risk | cache-read design only | conditional | strict-json, jsonl-warn-skip, or text-status depending surface | 45 | 180 | advisory packet/timestamp/mtime/hash | stale advisory, mismatch with MT5 governance, parse failure | stale-labeled display; block trading-adjacent EXE action | adapter-owned cached view / stale cached view | low/medium | Design-only yes; prototype no until gates approved | DEC-FRESH-002; DEC-AUTH-003; DEC-CONC-001 | Advisory status must remain non-authoritative. |
| CACHE-DASH-001 | dashboard-generated visibility outputs | Dashboard Layer / Generated/Volatile | dashboard-owned/generated | Yes for dashboard tools; outputs mixed | visibility-only | observe-only / cache-read for UI design only | conditional for display; forbidden as runtime truth | strict-json, text-status, log-tail-derived, or unknown-forbidden per file | UI-specific; Pending Human Decision | UI-specific; Pending Human Decision | UI refresh/mtime | source stale/unavailable, dashboard output newer than source but source stale | display stale/unavailable warning; never drive runtime | derived view / stale cached view | possible metadata exposure | Design-only yes; prototype no until dashboard truth spec approved | DEC-WRITE-002; dashboard truth-labeling approval | Dashboard must never become authority. |
| CACHE-LOCK-001 | lock/stop sentinel files | State/Status Layer / Volatile Control | MT5/script/dashboard-owned depending file; Unknown per sentinel | Some missing/generated | execution-control / lifecycle-sensitive | existence-live-check only | unsafe as cached truth | existence-live-check | immediate / live only | immediate / live only | each action boundary; filesystem event if later approved | existence change, missing lock, stale lock, mtime change | read live; stale cache forbidden; human review for ambiguous lifecycle | unavailable or unknown/unclassified; never cached view as truth | low/medium | No cached prototype; design-only existence strategy allowed | DEC-CONC-001; missing surface classifications | Do not cache sentinel truth; at most design live existence check. |
| CACHE-MISS-001 | missing council surfaces | State/Status Layer | MT5-owned/generated or Unknown | No for listed missing surfaces | state-critical if feature enabled | forbidden until classified | unsafe / unknown | unknown-forbidden | unavailable | unavailable | human classification only | file appears/disappears; feature gate confirmation | unavailable; block dependent prototype | unknown/unclassified | low/medium | No until classified | DEC-MISS-001 | Includes missing council status/state surfaces from Stage 1/1.5. |
| CACHE-MISS-002 | missing live-exit/lifecycle surfaces | State/Status Layer | MT5-owned/generated or Unknown | No for listed missing surfaces | potentially execution-critical if feature enabled | forbidden until classified | unsafe / unknown | unknown-forbidden | unavailable | unavailable | human classification only | file appears/disappears; feature gate confirmation | unavailable; block dependent prototype | unknown/unclassified | low/medium | No until classified | DEC-MISS-002 | Live-exit/lifecycle missing surfaces block any dependent prototype. |
| CACHE-MISS-003 | generated missing runtime surfaces | Generated/Volatile | generated/script-owned/MT5-owned depending file | No for timestamped/volatile outputs | visibility-only or report-only unless proven otherwise | observe-only after classification | conditional after classification | strict-json/jsonl-warn-skip/text-status by surface | per-surface Pending Human Decision | per-surface Pending Human Decision | generated file creation/mtime | missing expected run output, stale timestamp, parse failure | mark unavailable; do not infer failure without runtime context | unavailable / derived view | low/medium | Design-only yes; prototype no until classified | DEC-MISS-003 | Generated absence may be normal; do not treat as fatal without human decision. |
| CACHE-DOC-001 | reports/docs/memory files | Archive/Documentation / Report/Memory | human-owned/generated/mixed | Yes | report-only / archive-only | cache-read design only | conditional | text-status, strict-json, csv-readonly, or log-tail-derived by file | manual or mtime-driven | not runtime truth | mtime/hash change | parse failure, size instability, unknown provenance | warn only; mark derived/unavailable | derived view / cached view | possible sensitive notes | Design-only yes; prototype no until allowlist approved | cache allowlist approval; secret scan policy | Useful for report search only; never runtime truth. |
| CACHE-LOG-001 | logs | Generated/Volatile / Report/Memory | generated by MT5/scripts/tools | Yes | visibility/report-only unless specific log is operational | observe-only / tail-derived design only | conditional for display only | log-tail-derived | UI/report-specific; Pending Human Decision | UI/report-specific; Pending Human Decision | append offset/mtime/size | truncation, rotation, partial write, encoding error | warn/skip/mark unavailable; never runtime truth | derived view / stale cached view | possible secret leakage | Design-only yes; prototype no until redaction policy approved | DEC-SECRET-003; cache allowlist approval | Logs may contain sensitive values; require redaction policy before display. |
| CACHE-UNKNOWN-001 | unknown referenced surfaces | Unknown | Unknown | Mixed | unknown | forbidden | unsafe / unknown | unknown-forbidden | unavailable | unavailable | human classification only | any discovered reference without owner/schema/freshness | block dependent prototype; human review required | unknown/unclassified | unknown | No | Pending Human Decision | Unknown remains forbidden until classified. |

### 4. Cache Denylist

| File/class | Reason | Risk | Allowed future access only if | Notes |
| --- | --- | --- | --- | --- |
| AI\ai_runtime_secrets.json | Secret-bearing file. | critical secret exposure | DEC-SECRET-001/002/003 explicitly approve limited redacted behavior. | No value reads, cache, display, or logging by default. |
| Any secret-bearing file | Secrets may appear outside the known secrets file. | critical secret exposure | Human-approved secret inventory and redaction policy exists. | Treat possible secrets as denylisted until classified. |
| Lock/stop sentinel files as cached truth | Sentinel existence is lifecycle-sensitive and can change immediately. | critical stale-control risk | Future design uses live existence checks or approved watcher semantics, not stale cache. | CACHE-LOCK-001 may only design existence-live-check behavior. |
| Unresolved missing runtime surfaces | No file exists to inspect and no approved lifecycle classification. | high/critical dependency ambiguity | DEC-MISS decisions classify each as optional/generated/required/legacy. | Do not synthesize or assume contents. |
| Unknown authority files | Writer/owner is not known. | high desync/multiple-writer risk | Authority owner and writer rules are approved. | Unknown remains forbidden. |
| Volatile generated files without freshness rules | Generated outputs can be stale, partial, or absent normally. | high stale/false-truth risk | Freshness, expiry, invalidation, and failure rules are approved. | Especially dashboard/adapter timestamped outputs. |
| Files with multiple writers and no authority decision | Multiple writers can cause race/desync. | critical runtime conflict risk | Single authority, locking, backup, and logging policy are approved. | EXE/dashboard/developer tool V1 writes remain forbidden. |
| Dashboard-only outputs as runtime truth | Dashboard is visibility-only. | critical false-authority risk | Not applicable for runtime truth in V1. | Dashboard must label source and freshness. |
| Binary artifacts, .ex5, .dll, .exe, .pdb, .pyc, bin/obj/cache/venv contents | Not runtime data contracts for RAM cache. | high corruption/security ambiguity | Separate binary provenance task approves read-only metadata inspection. | No binary parsing in Stage 2A. |

### 5. Conditional Cache Allowlist

| File/class | Conditions required before cache | Parser requirement | Freshness requirement | Authority requirement | Failure behavior | Human decision dependency |
| --- | --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | DEC-JSON-001 and DEC-AUTH-001 approved; stable-read design approved; no runtime-truth use from RAM. | compatibility-json or approved strict shadow policy; strict-json alone not allowed now. | mtime/hash/coherence driven; no stale runtime-truth use. | MT5 runtime authority confirmed; semantic edit owner confirmed. | fail closed for trading-adjacent EXE action; stale-labeled display only. | DEC-JSON-001; DEC-AUTH-001; DEC-CONC-001; DEC-PATH-001 |
| AI\ai_previous_plan_backup.json | JSON policy approved; backup semantics confirmed. | compatibility-json required now. | mtime/hash/rollback event driven. | MT5/generated backup ownership confirmed. | mark unavailable; never promote to current truth. | DEC-JSON-001; DEC-AUTH-001; DEC-CONC-001 |
| AI\ai_evolution_state.json | JSON policy and evolution-state authority approved. | compatibility-json required now. | mtime/hash/evolution event driven. | MT5/generated or explicit owner approved. | mark unavailable; block dependent EXE action. | DEC-JSON-001; DEC-AUTH-003; DEC-CONC-001 |
| runtime_governance_status.* | Authority/freshness/concurrency approved. | strict-json if valid for .json; text-status for .txt. | 600s stale / 1800s expired unless changed by human decision. | MT5-owned/generated confirmed. | stale/expired blocks trading-adjacent EXE action. | DEC-AUTH-003; DEC-FRESH-001; DEC-CONC-001 |
| execution_authority_status.* | Authority/freshness/concurrency approved. | strict-json if valid for .json; text-status for .txt. | 600s stale / 1800s expired unless changed by human decision. | MT5-owned/generated confirmed. | stale/expired blocks trading-adjacent EXE action. | DEC-AUTH-003; DEC-FRESH-001; DEC-CONC-001 |
| active_operating_cohort.* | Authority/freshness/concurrency approved. | strict-json if valid for .json; text-status for .txt. | 600s stale / 1800s expired unless changed by human decision. | MT5-owned/generated confirmed. | stale/expired blocks trading-adjacent EXE action. | DEC-AUTH-003; DEC-FRESH-001; DEC-CONC-001 |
| AI\ai_performance_journal.jsonl | Analytics-only scope approved; invalid-line handling approved. | jsonl-warn-skip. | append/mtime/size driven; no runtime truth. | MT5/generated append source confirmed. | warn/skip invalid lines; analytics unavailable on failure. | DEC-CONC-001; cache allowlist approval |
| AI\council_feedback.json | Feedback/report-only scope approved. | strict-json if valid. | mtime/hash driven. | owner/writer confirmed or marked generated. | mark analytics unavailable on parse failure. | DEC-AUTH-003; DEC-CONC-001 |
| Adapter context/status outputs | Adapter ownership, freshness, and non-authority rules approved. | strict-json/jsonl-warn-skip/text-status per surface. | exporter 30/120; intake/advisory 45/180 unless changed. | adapter-owned/generated or MT5 mirror owner confirmed. | stale-labeled display; block trading-adjacent EXE action. | DEC-FRESH-002; DEC-AUTH-003; DEC-CONC-001 |
| Selected docs/reports as read-only memory/report cache | Human-approved allowlist and redaction policy. | text-status/strict-json/csv-readonly/log-tail-derived by file. | mtime/hash driven; no runtime truth. | human-owned/generated classification approved. | warn only; mark derived/unavailable. | cache allowlist approval; DEC-SECRET-003 |

### 6. Parser Mode Matrix

| Parser mode | Meaning | Allowed now in Stage 2A | Invalid parse behavior |
| --- | --- | --- | --- |
| strict-json | Standard JSON parser with no comments/trailing commas/invalid escapes. | Design-only for files already valid strict JSON or future strict shadow copies. | mark unavailable; do not auto-fix; do not fall back silently. |
| compatibility-json | Parser design compatible with current permissive MQL string-field extraction and invalid strict JSON surfaces. | Design-only; implementation blocked by DEC-JSON-001. | mark unavailable or compatibility-failed; never normalize in-place. |
| jsonl-warn-skip | Line-oriented JSONL reader that warns/skips invalid lines. | Design-only for analytics/report surfaces. | warn/skip invalid line; analytics partial; never runtime truth. |
| text-status | Key/value or status text reader. | Design-only for `.txt` status surfaces. | mark unavailable or partial; never infer missing fields silently. |
| csv-readonly | Read-only CSV parser for reports/data. | Design-only for report-only surfaces. | warn/mark unavailable; no runtime truth. |
| log-tail-derived | Tail/offset reader for logs. | Design-only for visibility/reporting. | warn/skip partial lines; no runtime truth. |
| existence-live-check | Live filesystem existence check, not a persisted cache. | Design-only for sentinel/lock/stop surfaces. | ambiguous state blocks dependent action; no cached truth. |
| binary-forbidden | Binary artifacts not parsed by cache registry. | Yes as denylist mode only. | block; human review required. |
| unknown-forbidden | Unknown/unclassified format is not cache eligible. | Yes as default deny mode. | block; human review required. |

| File/class | Assigned parser mode | Strict parser allowed now | Compatibility required | Implementation blocked by human decision | Behavior on invalid parse |
| --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | compatibility-json | No, not as only parser | Yes | DEC-JSON-001 | mark unavailable/fail closed for trading-adjacent EXE action; no auto-fix. |
| AI\ai_previous_plan_backup.json | compatibility-json | No, not as only parser | Yes | DEC-JSON-001 | mark unavailable; never promote backup to truth. |
| AI\ai_evolution_state.json | compatibility-json | No, not as only parser | Yes | DEC-JSON-001 | mark unavailable; block dependent EXE action. |
| AI\ai_runtime_secrets.json | binary-forbidden/forbidden secret access | No parser by default despite strict validity | No value parser approved | DEC-SECRET-001/002/003 | block access; no values logged. |
| AI\council_feedback.json | strict-json | Yes, design-only | No | cache allowlist approval | mark unavailable for analytics. |
| runtime_governance_status.json | strict-json if valid | Yes, design-only | No unless file proves non-standard | DEC-AUTH-003; DEC-CONC-001 | unavailable/fail closed for trading-adjacent EXE action. |
| runtime_governance_status.txt | text-status | Not applicable | No | DEC-AUTH-003; DEC-CONC-001 | partial/unavailable; fail closed for dependent action. |
| execution_authority_status.json | strict-json if valid | Yes, design-only | No unless file proves non-standard | DEC-AUTH-003; DEC-CONC-001 | unavailable/fail closed for trading-adjacent EXE action. |
| execution_authority_status.txt | text-status | Not applicable | No | DEC-AUTH-003; DEC-CONC-001 | partial/unavailable; fail closed for dependent action. |
| active_operating_cohort.json | strict-json if valid | Yes, design-only | No unless file proves non-standard | DEC-AUTH-003; DEC-CONC-001 | unavailable/fail closed for trading-adjacent EXE action. |
| active_operating_cohort.txt | text-status | Not applicable | No | DEC-AUTH-003; DEC-CONC-001 | partial/unavailable; fail closed for dependent action. |
| AI\ai_performance_journal.jsonl | jsonl-warn-skip | Per-line only | No | cache allowlist approval | warn/skip invalid lines; analytics partial only. |
| Adapter outputs | strict-json / jsonl-warn-skip / text-status per file | Only for known-valid strict JSON surfaces | Possibly per surface | DEC-FRESH-002; DEC-AUTH-003 | stale/unavailable; no runtime truth. |
| Dashboard outputs | strict-json / text-status / log-tail-derived / unknown-forbidden per file | Only for known-valid strict JSON surfaces | Possibly per surface | dashboard truth-label spec approval | display unavailable/stale; no authority. |
| Lock/stop sentinel files | existence-live-check | Not applicable | No | DEC-CONC-001 | live check ambiguous -> block dependent action. |
| Missing/unknown surfaces | unknown-forbidden | No | Unknown | DEC-MISS-* | unavailable; human review. |

### 7. Freshness, Expiry, and Invalidation Matrix

| File/class | stale_after_seconds | expired_after_seconds | refresh trigger | invalidation trigger | stale display allowed | stale runtime use allowed | expired behavior | notes |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| AI\ai_current_plan.json | no generic TTL; event/hash/mtime/coherence driven | not approved for runtime truth from RAM | mtime/hash/plan id/coherence change | parse failure, coherence failure, unstable read, human plan update | Yes, only as stale-labeled cached view | No | mark unavailable; block trading-adjacent EXE action | Stale RAM copy must never become plan truth. |
| AI\ai_previous_plan_backup.json | event/hash/mtime driven | not runtime truth | mtime/hash/rollback event | parse failure, unstable read, current/backup mismatch | Yes, stale-labeled rollback reference | No | mark unavailable | Backup is not active truth. |
| AI\ai_evolution_state.json | event/hash/mtime driven | not runtime truth | mtime/hash/evolution event | parse failure, rollback/evolution mismatch | Yes, stale-labeled derived state | No | mark unavailable; block dependent action | Depends on JSON policy. |
| runtime_governance_status.* | 600 | 1800 | mtime/hash/timer/tick/status timestamp | stale/expired, parse failure, contradiction, mtime regression | Yes, with warning | No | unavailable/fail closed for trading-adjacent EXE action | Stage 1.5 default from MQL freshness checks. |
| execution_authority_status.* | 600 | 1800 | mtime/hash/timer/tick/status timestamp | stale/expired, authority contradiction, parse failure, mtime regression | Yes, with warning | No | unavailable/fail closed for trading-adjacent EXE action | Stale authority is critical. |
| active_operating_cohort.* | 600 | 1800 | mtime/hash/timer/tick/status timestamp | stale/expired, cohort contradiction, parse failure, mtime regression | Yes, with warning | No | unavailable/fail closed for trading-adjacent EXE action | Stale cohort cannot be used for admission. |
| AI\ai_performance_journal.jsonl | append/mtime/size driven; no runtime TTL | not runtime truth | append offset, mtime, size | invalid line, truncation, rotation, mtime regression | Yes, derived partial display | No | analytics unavailable | Warn/skip invalid JSONL lines. |
| AI\council_feedback.json | mtime/hash driven | not runtime truth | mtime/hash change | parse failure, unstable read | Yes, derived display | No | analytics unavailable | Report/memory only. |
| ATAS exporter outputs | 30 | 120 | packet timestamp, exporter cycle, mtime/hash | stale packet, exporter heartbeat missing, parse failure | Yes, stale-labeled | No | unavailable; block trading-adjacent EXE action | Adapter cannot be execution authority. |
| ATAS intake/advisory/status outputs | 45 | 180 | advisory packet/timestamp, mtime/hash | stale advisory, mismatch with governance, parse failure | Yes, stale-labeled | No | unavailable; block trading-adjacent EXE action | Advisory remains non-authoritative. |
| Dashboard outputs | Pending Human Decision | Pending Human Decision | UI refresh, source mtime/hash | source stale/unavailable, dashboard-source mismatch | Yes, with truth labels | No | unavailable | Visibility-only. |
| Lock/stop sentinel files | immediate/live only | immediate/live only | action boundary live check | existence change, stale lock, ambiguous state | Only as current live observation | No cached use | block dependent action | Do not cache sentinel truth. |
| Secrets | no cache | no cache | none | any read/cache/display attempt | No | No | forbidden/secret | Secret file denylisted. |
| Missing/unknown surfaces | unavailable | unavailable | human classification | unresolved owner/schema/lifecycle | No, except unavailable label | No | unavailable/blocked | Not eligible until classified. |

### 8. Failure Behavior Matrix

| Failure case | Required behavior |
| --- | --- |
| File missing | If optional/generated: mark unavailable; if execution/config/state-critical or Unknown: fail closed for trading-adjacent EXE action and require human review. |
| File unreadable | Mark unavailable; record redacted error; do not retry indefinitely; no trading-adjacent EXE action from cached data. |
| Parse failure | Mark parse_status invalid; do not auto-fix; do not silently fall back to older truth; block dependent trading-adjacent EXE action. |
| Checksum mismatch | Treat as unstable or changed source; retry only under approved future strategy; do not parse as truth. |
| mtime regression | Mark suspicious/unavailable; require human review or explicit rollback context. |
| Partial write detected | Reject read; retry only if future concurrency policy allows; never parse partial writes as truth. |
| Stale | Display only with stale label; block trading-adjacent EXE action for governance/authority/plan/cohort/adapter classes. |
| Expired | Mark unavailable/fail closed; no cached runtime use. |
| Permission error | Mark unavailable; redact path-sensitive details if needed; human review required. |
| Secret access attempted | Block; do not log values; record redacted policy violation only if approved. |
| Multiple writer conflict | Mark conflict; block managed-write/prototype; require authority decision. |
| Dashboard-only data presented as truth | Treat as policy violation; relabel as derived/stale/unavailable and require review. |
| Unknown authority/schema | Use unknown-forbidden mode; no cache/prototype dependency. |
| Encoding/BOM issue | Mark parse/read warning; do not normalize in-place; require parser policy decision. |
| Runtime path mismatch | Mark unavailable; require DEC-PATH-001 resolution. |

### 9. Dashboard Truth-Labeling Model

Allowed dashboard truth labels:

| Label | Meaning |
| --- | --- |
| authoritative file truth | Live source file is displayed as the current file-owned truth, not dashboard-owned truth. |
| cached view | RAM-cached copy of a source file that is fresh by approved rules. |
| derived view | Computed/report-only view from logs, journals, docs, or adapter output. |
| stale cached view | Cached copy is older than stale threshold or failed freshness check but may be displayed with warning. |
| expired/unavailable | Source/cache is expired, missing, unreadable, or invalid. |
| forbidden/secret | Source is secret-bearing or access/display is forbidden. |
| unknown/unclassified | Source owner/schema/freshness is unresolved. |

Dashboard labeling by registry class:

| Registry class | Allowed dashboard label | Requirements |
| --- | --- | --- |
| CACHE-CFG-001 ai_current_plan.json | authoritative file truth only if live-read; cached view/stale cached view if cached | Must show source path, mtime/hash/freshness; stale warning required. |
| CACHE-CFG-002 previous plan backup | cached view / derived view | Must not appear as active plan truth. |
| CACHE-CFG-003 evolution state | cached view / derived view / stale cached view | Must not drive runtime decisions. |
| CACHE-SEC-001 secrets | forbidden/secret | No values; redacted metadata only if later human-approved. |
| CACHE-STATE-001/002/003 governance/authority/cohort | authoritative file truth if live-read; cached view/stale cached view/expired unavailable | Must show MT5-owned/generated source and stale/expired warnings. |
| CACHE-JOURNAL-001 journal | derived view | Invalid lines must be labeled skipped/partial. |
| CACHE-FEEDBACK-001 feedback | derived view / cached view | Report-only. |
| CACHE-ADAPTER-001/002 adapter outputs | adapter-owned cached view / stale cached view / expired unavailable | Must identify adapter-owned/generated source and non-authority status. |
| CACHE-DASH-001 dashboard outputs | derived view / stale cached view | Must identify dashboard-generated view, never truth. |
| CACHE-LOCK-001 sentinels | unknown/unclassified or live observation only | Cached sentinel truth is forbidden. |
| CACHE-MISS/UNKNOWN | expired/unavailable / unknown/unclassified | Must show unresolved classification. |
| CACHE-DOC/LOG | derived view / cached view / stale cached view | Must show report-only and possible redaction status. |

Dashboard V1 requirements:

- Dashboard V1 is visibility-only.
- Dashboard V1 must not become source of truth.
- Dashboard must not display secret values.
- Dashboard must warn when stale, expired, unavailable, partial, or unknown.
- Dashboard must identify MT5-owned vs adapter-owned vs generated vs human-owned data where known.
- Dashboard must not convert derived or stale data into authority.

### 10. Security and Secret Handling

Security policy for Stage 2A:

- `AI\ai_runtime_secrets.json` is denylisted.
- No secret value reads by default.
- No secret cache.
- No secret dashboard display.
- No secret logs.
- No secret values in migration documentation or reports.
- Redacted metadata only if human-approved later.
- Secret-bearing files outside `AI\ai_runtime_secrets.json` remain possible and must be classified before display/cache.
- Stage 2B must not implement secret handling unless DEC-SECRET-001, DEC-SECRET-002, and DEC-SECRET-003 are approved.
- Logs and reports require a redaction policy before dashboard display or cache indexing.

### 11. Read Concurrency and Atomicity Design Notes

Design notes only; no locking or read implementation is approved.

Known concern:

- EXE reads may race with MT5/script/adapter writes.
- Future implementation must not parse partial writes or overwrite MT5-owned state.
- `DEC-CONC-001` remains **Pending Human Decision**.

Future safe-read strategy requirements:

- Capture mtime and size before read.
- Read file content.
- Capture mtime and size after read.
- Reject or retry if mtime or size changes during read.
- Compute checksum only after a stable read.
- Do not parse partial writes as truth.
- Treat mtime regression as suspicious unless rollback context is approved.
- Optional file locking may be designed only if confirmed compatible with MT5 file access.
- No lock file creation is approved in Stage 2A.
- Future retry limits, backoff, and failure surfacing require human approval.

### 12. Stage 2B Entry Criteria

Before any Stage 2B skeleton/prototype or cache implementation:

| Gate | Required approval |
| --- | --- |
| DEC-JSON-001 | Approved JSON parser policy. |
| DEC-AUTH-001 | Approved single authority for `AI\ai_current_plan.json` runtime truth. |
| DEC-WRITE-001 | Approved as no writes or explicit bounded exceptions; safe default remains no writes. |
| DEC-SECRET-001 | Approved whether EXE may read secrets; safe default remains no. |
| DEC-SECRET-002 | Approved whether EXE may cache secrets; safe default remains no. |
| DEC-SECRET-003 | Approved dashboard secret metadata policy; safe default remains no display. |
| DEC-MISS-* | Approved classifications for all Stage 2 dependencies. |
| DEC-CONC-001 | Approved read concurrency/atomicity policy. |
| DEC-PATH-001 | Approved live MT5 terminal root/path contract. |
| Cache allowlist/denylist | Human-approved file classes and per-file exceptions. |
| Parser-mode matrix | Human-approved parser assignment and invalid-parse behavior. |
| Failure behavior matrix | Human-approved fail-closed/warn/unavailable actions. |
| Rollback/validation plan | Approved before any skeleton/prototype. |
| MT5 behavior confirmation | Explicit confirmation that MT5 behavior remains unchanged. |

Stage 2B remains blocked for implementation until all required gates for its intended scope are approved.

### 13. Codex Task Backlog Update

Future bounded tasks only; none are implemented here.

| Future task | Boundary |
| --- | --- |
| Stage 2B compatibility parser design spec | Design parser behavior/options only; no parser code. |
| Stage 2C file-stability/read-concurrency design spec | Design stable-read, checksum, retry, and atomicity rules only. |
| Stage 2D dashboard truth-labeling wireframe/spec | Design labels and UI warnings only; no dashboard implementation. |
| Stage 2E cache registry skeleton proposal | Only if human gates are approved; proposal before implementation. |
| JSON normalization proposal task | Separate future proposal; not approved and not performed here. |
| Missing runtime surface confirmation task | Human worksheet to classify unresolved/missing surfaces. |
| Secret redaction/access policy spec | Define redaction/access rules; no secret reads. |
| Cache allowlist/denylist approval worksheet | Human approval matrix for each cache candidate. |

### 14. Stage 2A Completion Criteria

- Design scope and non-goals recorded: **complete**.
- Cache registry principles recorded: **complete**.
- RAM cache registry table recorded with conditional/deny decisions: **complete**.
- Cache denylist includes secrets and unresolved/unknown surfaces: **complete**.
- Conditional cache allowlist recorded: **complete**.
- Parser mode matrix recorded; invalid strict JSON files require compatibility-json or pending DEC-JSON-001: **complete**.
- Freshness/expiry/invalidation matrix recorded: **complete**.
- Failure behavior matrix recorded: **complete**.
- Dashboard truth-labeling model recorded: **complete**.
- Security/secret-handling policy recorded without secret values: **complete**.
- Read concurrency/atomicity design notes recorded: **complete**.
- Stage 2B entry criteria recorded: **complete**.
- Stage 2 prototype/implementation remains blocked: **complete**.


## Stage 2B — Compatibility Parser Design Spec

### 1. Design Scope and Non-Goals

This Stage 2B section is **design/specification only**.

Non-goals and hard boundaries:

- No parser implementation.
- No JSON normalization.
- No JSON auto-fix.
- No RAM loader implementation.
- No EXE implementation.
- No dashboard implementation.
- No adapter supervisor implementation.
- No developer-tool implementation.
- No validator, file watcher, or prototype implementation.
- No runtime/config/status/log/state writes.
- No `.mq5`, `.mqh`, `.ex5`, `.json`, `.jsonl`, `.txt`, `.csv`, `.ini`, `.log`, dashboard, adapter, script, build, binary, cache, or venv changes.
- No secret reads, no secret caching, no secret display, and no secret logging.
- No trading decision authority.
- No stale or compatibility-parsed data may become runtime truth without explicit human approval.

Stage 2 prototype/implementation remains **blocked**. All unresolved decisions remain **Pending Human Decision**.

### 2. Problem Statement

Stage 1 and Stage 1.5 found that the following runtime-critical JSON files are not valid strict JSON:

- `AI\ai_current_plan.json`
- `AI\ai_previous_plan_backup.json`
- `AI\ai_evolution_state.json`

The main known strict JSON issue is invalid backslash escape usage. Current MT5/MQL behavior appears permissive or extraction-based: MQL helpers load file text and extract key values using string search and loose field extraction instead of a full strict JSON parse. That behavior may tolerate JSON files that strict EXE-side parsers reject.

Compatibility parsing must preserve the MT5-intended meaning. It must not silently rewrite, normalize, reinterpret, or elevate data authority. A future compatibility parser must report diagnostics and must never make RAM cache stronger than the source file.

`DEC-JSON-001` remains **Pending Human Decision**. Therefore, parser implementation and any Stage 2 prototype remain blocked.

### 3. Parser Mode Definitions

| Parser mode | Accepted input class | Allowed output use | Cache eligibility | Dashboard display eligibility | Failure behavior | Requires human approval |
|---|---|---|---|---|---|---|
| `strict-json` | RFC-compatible JSON accepted by standard strict parsers | Read-only config/status/report view where strict validity is confirmed | Conditional, if Stage 2A registry permits | Yes, as cached or derived view with source label | Mark unavailable on parse failure; do not repair | Yes for runtime-critical files |
| `compatibility-json` | Non-strict JSON requiring compatibility interpretation, including invalid escape diagnostics | Diagnostics and limited read-view only unless approved | Conditional and blocked until `DEC-JSON-001` | Yes only with compatibility warning and non-authority label | Fail closed on low confidence, mismatch, or required-key uncertainty | Yes |
| `compatibility-json-readonly` | Same as `compatibility-json`, with explicit no-write/no-normalize boundary | Read-only diagnostics, cache-design candidate, dashboard view candidate | Conditional design only; no implementation approval | Yes only as cached/derived/stale-labeled view | Mark unavailable or human review required on uncertainty | Yes |
| `jsonl-warn-skip` | JSON Lines/event log where individual lines may be invalid | Derived analytics only; invalid lines warn/skip | Conditional for analytics/report cache only | Yes as derived view with invalid-line warning | Skip invalid line, warn, never truth | Yes for runtime-adjacent use |
| `text-status` | Text status or sentinel-style values | Visibility/status view only | Conditional if freshness rules exist | Yes with source/freshness label | Mark unavailable if unreadable or malformed | Yes for runtime-adjacent use |
| `log-tail-derived` | Log files and append-only operational text | Derived diagnostics only | Conditional; never authority | Yes as derived/log view | Warn only unless used for a blocked gate | No for report-only design; yes for runtime-adjacent use |
| `existence-live-check` | Sentinel or lock/stop files where existence matters | Live existence status only | Not cacheable as truth | Yes as live/critical status only | Read live or mark unavailable; stale cache forbidden | Yes |
| `forbidden-secret` | Secret-bearing files or values | No value output | Not eligible | No value display; redacted metadata only if later approved | Block access attempt and require audit note | Yes; current default is no-read/no-cache |
| `forbidden-unknown` | Unknown authority, unknown format, or unresolved missing surface | None | Not eligible | Unknown/unavailable only | Block and require human classification | Human classification required |
| `binary-forbidden` | `.ex5`, `.exe`, `.dll`, `.pdb`, compiled/cache/binary artifacts | Presence/reference metadata only if needed | Not eligible | Inventory metadata only | Do not parse as runtime data | Yes for any future binary inspection |

### 4. Runtime-Critical JSON Parser Assignment

| File | Strict JSON validity | Current proposed parser mode | Runtime authority | Cache eligibility | Dashboard display eligibility | Allowed use | Forbidden use | Failure behavior | Human decision dependency | Notes |
|---|---|---|---|---|---|---|---|---|---|---|
| `AI\ai_current_plan.json` | No | `compatibility-json-readonly` pending approval | MT5/source-file truth; RAM is not truth | Conditional design only | Cached/derived/stale-labeled view only | Read-only diagnostics, parser-status view, cache-candidate design | Stale runtime truth, auto-normalization, silent fallback, EXE writes | Fail closed / mark unavailable / human review if strict and compatibility interpretations differ or required fields are uncertain | `DEC-JSON-001`, `DEC-AUTH-001`, `DEC-CONC-001`, `DEC-PATH-001` | Most critical compatibility target. Must preserve MT5 meaning. |
| `AI\ai_previous_plan_backup.json` | No | `compatibility-json-readonly` pending approval | Backup/rollback source file; not active runtime truth | Conditional design only | Cached/derived view with compatibility warning | Read-only rollback context and diagnostics | Treating backup as active truth, auto-fix, EXE writes | Mark unavailable on parse ambiguity; human review for mismatch | `DEC-JSON-001`, `DEC-JSON-002`, `DEC-JSON-003` | Not runtime truth. |
| `AI\ai_evolution_state.json` | No | `compatibility-json-readonly` pending approval | Derived/evolution state; authority remains source/runtime generator | Conditional design only | Cached/derived/stale-labeled view | Read-only diagnostics and derived-state display | Runtime truth elevation, auto-normalization, silent fallback | Mark unavailable on invalid/mismatch; stale derived display only if labeled | `DEC-JSON-001`, `DEC-AUTH-003`, `DEC-CONC-001` | Derived state must not override current plan authority. |
| `AI\council_feedback.json` | Yes | `strict-json` | Source/report feedback file; likely generated/runtime-adjacent | Conditional read-only/report cache | Derived/report view allowed | Strict read-only parse for report/feedback display | Dashboard/runtime authority, writes without approval | Mark unavailable on parse failure; do not repair | Authority confirmation remains Pending Human Decision | Large valid JSON file; still non-authoritative for trading decisions. |
| `AI\ai_runtime_secrets.json` | Yes | `forbidden-secret` | Human-owned / secret-bearing | Forbidden | No values; redacted metadata only if later approved | No value access by default | Secret reads, cache, display, log, parser diagnostics containing values | Block access; record redacted access-denied state only | `DEC-SECRET-001`, `DEC-SECRET-002`, `DEC-SECRET-003` | Do not print or store secret values. |
| `AI\ai_performance_journal.jsonl` | JSONL with one known invalid line | `jsonl-warn-skip` | Generated journal/report source | Conditional analytics/report cache only | Derived analytics view with invalid-line warning | Warn/skip invalid event lines for analytics | Runtime truth, silent skip without warning, writes | Warn and skip invalid lines; fail closed if required for runtime-adjacent action | Authority/write policy Pending Human Decision | Existing invalid JSONL line makes strict whole-file parsing unsuitable. |

### 5. Compatibility JSON Behavior Contract

A future compatibility parser, if approved, must follow this contract:

- Read raw bytes/text without modifying the source file.
- Detect encoding and BOM concerns.
- Detect strict JSON validity before compatibility interpretation.
- Detect invalid escape sequences and report counts/locations where feasible.
- Produce parse diagnostics for every attempt.
- Never auto-write normalized JSON.
- Never silently repair source files.
- Never rewrite slashes or escapes in the source file.
- Never treat compatibility parse output as stronger authority than MT5/source-file truth.
- Preserve the original raw file hash.
- Store raw checksum, parser-mode checksum if applicable, source size, source mtime, and diagnostics.
- Mark every compatibility-parsed output explicitly as `compatibility-parsed`.
- Fail closed and require human review if strict and compatibility interpretations differ.
- Mark unavailable if parse confidence is low.
- Reject or retry if a partial write is suspected, subject to future concurrency policy.
- Redact or suppress secret-bearing data before any dashboard/report/log surface.
- Keep all parser implementation work blocked until approved by `DEC-JSON-001`.

### 6. Parse Result State Model

| Result state | Cache allowed | Dashboard display allowed | Trading-adjacent EXE action allowed | Required warning | Failure behavior |
|---|---|---|---|---|---|
| `VALID_STRICT` | Conditional if registry and authority policy allow | Yes, labeled strict-valid cached/derived view | No by default; only if later explicitly approved | Source/freshness label | Use as read-view only; invalidate on source change |
| `VALID_COMPATIBILITY` | Conditional and blocked until `DEC-JSON-001` | Yes with compatibility-parsed label | No by default | Compatibility warning and source checksum | Read-view only; no authority elevation |
| `INVALID_RECOVERABLE_FOR_DISPLAY` | No for runtime/config truth; conditional for diagnostic snapshot only | Yes only as warning/diagnostic view | No | Invalid but recoverable for display only | Mark degraded; require human review for runtime-adjacent use |
| `INVALID_UNRECOVERABLE` | No | Unavailable/error only | No | Parse failed | Mark unavailable; fail closed |
| `PARTIAL_WRITE_SUSPECTED` | No | Unavailable or retry-pending only | No | Source changed during read | Reject/retry under future concurrency policy; never parse as truth |
| `STALE` | Conditional display cache only | Yes with stale label | No | Stale threshold exceeded | Keep last known only as stale-labeled view; block trading-adjacent action |
| `EXPIRED` | No, except retained diagnostics | Expired/unavailable only | No | Expired threshold exceeded | Mark unavailable; fail closed for runtime-adjacent action |
| `FORBIDDEN_SECRET` | No | No values; redacted access-denied metadata only if approved | No | Secret access denied | Block access; no value logging |
| `UNKNOWN_UNCLASSIFIED` | No | Unknown/unclassified only | No | Human classification required | Block use until classified |
| `HUMAN_REVIEW_REQUIRED` | No new cache promotion | Review-required label only | No | Human decision required | Fail closed until decision is recorded |

### 7. Invalid Escape Handling Policy

- Invalid backslash escapes must be detected and reported.
- Source files must not be modified.
- No automatic slash rewriting is approved.
- No silent conversion is approved.
- Compatibility interpretation, if approved later, must be labeled.
- Future implementation must include tests proving compatibility output does not alter MT5-intended semantic values.
- If invalid escapes occur in keys or values required for trading behavior, the parser must fail closed pending human review.
- If invalid escapes occur only in display/report strings, display may be allowed with a warning, pending `DEC-JSON-001`.
- Compatibility output must never become runtime truth by default.
- Any ambiguity between strict interpretation, compatibility interpretation, and observed MT5 extraction behavior requires `HUMAN_REVIEW_REQUIRED`.

### 8. Shadow Copy / Normalization Policy Options

| Option | Description | Pros | Risks | Impact on MT5 continuity | Rollback requirement | Required human decision | Stage 2 prototype may proceed? |
|---|---|---|---|---|---|---|---|
| A | Compatibility parser only | Preserves existing files; avoids runtime writes | Parser complexity; mismatch risk | Lowest direct MT5 disruption | Disable parser/cache and fall back to file-only view | `DEC-JSON-001` | Only after approval |
| B | Human-approved strict normalization of source runtime files | Standard parser compatibility | Changes source config/state format; potential MT5 behavior drift | High risk unless MT5 behavior validated | Timestamped backups and restore plan for every changed file | `DEC-JSON-002` plus runtime approval | Not approved now |
| C | Strict shadow-copy generation for EXE consumption | EXE can use strict parser without touching source | Shadow copy can desync; extra authority confusion | Medium risk if labels/ownership unclear | Delete/ignore shadow copies; source remains authority | `DEC-JSON-003` plus authority policy | Not approved now |
| D | Dual parser comparison with fail-closed mismatch | Strong diagnostics and safer migration | More complex; false positives possible | Low source-file risk | Disable compatibility path; report diagnostics only | `DEC-JSON-001` | Only after approval |
| E | Reject invalid JSON until manually corrected | Simple, strict, safer parser behavior | Blocks EXE design/prototype for invalid current files | No direct MT5 change, but migration blocked | No parser rollback needed | Human decision to accept block or fix separately | No until files/policy resolved |

Recommended safe default: design for compatibility parser plus strict diagnostics first; do not normalize source runtime JSON; do not generate strict shadow copies; keep `DEC-JSON-001`, `DEC-JSON-002`, and `DEC-JSON-003` as **Pending Human Decision** unless explicitly approved later.

### 9. Parser Diagnostics Model

Future parser diagnostics should include these fields as metadata only; this is not an implementation schema approval.

| Diagnostic field | Purpose | Sensitivity notes |
|---|---|---|
| `source_path` | Identifies source file | Path only; no secret values |
| `parser_mode` | Records parser selected | Must match registry |
| `strict_valid` | Strict JSON pass/fail | Safe |
| `compatibility_valid` | Compatibility parse pass/fail | Safe if no values exposed |
| `encoding` | Encoding detected | Safe |
| `bom_detected` | BOM presence | Safe |
| `invalid_escape_count` | Invalid escape diagnostics | Safe if positions only; do not print secret content |
| `duplicate_key_warning` | Duplicate-key concern | Safe if key names are non-secret; redact if secret file |
| `required_key_missing` | Required-key diagnostics | Redact for secret-bearing files |
| `optional_key_missing` | Optional-key diagnostics | Redact for secret-bearing files |
| `parse_started_at` | Timing metadata | Safe |
| `parse_completed_at` | Timing metadata | Safe |
| `source_mtime` | Source freshness metadata | Safe |
| `source_size` | Source size metadata | Safe |
| `source_checksum` | Raw source checksum | Safe but can reveal file-change fingerprint; acceptable for internal diagnostics |
| `parse_status` | Parse result state | Safe |
| `confidence` | Parser confidence category | Safe |
| `warnings` | Warnings list | Must not include secret values |
| `errors` | Error list | Must not include secret values |
| `redaction_applied` | Whether output was redacted | Required for secret-adjacent diagnostics |
| `human_review_required` | Gate flag | Safe |

Diagnostics for `AI\ai_runtime_secrets.json` must not include raw values, parsed values, endpoint values, token values, or credential-like substrings.

### 10. Cache Interaction Rules

- Compatibility-parsed config may enter RAM cache only if permitted by the Stage 2A registry and approved human decisions.
- Cache entries must include parser diagnostics.
- Cache entries must include raw source checksum, source size, and source mtime.
- Cache entries must include a truth label.
- Cache entries must not override file authority.
- Cache entries must invalidate on source mtime, size, or checksum change.
- Cache entries must invalidate on parser-mode mismatch.
- Cache entries must invalidate on parse failure.
- Cache entries must invalidate or downgrade on partial-write suspicion.
- Stale compatibility-parsed config must not be runtime truth.
- Expired compatibility-parsed config must be unavailable for trading-adjacent EXE action.
- Secrets must not enter cache.
- Dashboard-only data must not enter cache as runtime truth.
- All cache behavior remains design-only until Stage 2B and later gates are approved.

### 11. Dashboard Interaction Rules

- Dashboard may show parser status, warnings, stale state, and redacted metadata.
- Dashboard must not show secret values.
- Dashboard must distinguish:
  - strict-valid
  - compatibility-parsed
  - invalid/recoverable
  - invalid/unrecoverable
  - stale
  - expired/unavailable
  - forbidden/secret
  - unknown/unclassified
- Dashboard must label compatibility-parsed plan data as cached or derived view, not authority.
- Dashboard must mark missing, invalid, expired, or unclassified data clearly.
- Dashboard must identify source ownership where known: MT5-owned, adapter-owned, generated, human-owned, or Unknown.
- Dashboard must never become writer or source of truth.
- Dashboard V1 remains visibility-only.

### 12. Validation Test Strategy for Future Implementation

Future implementation, if approved, must include tests for:

| Test area | Purpose | Expected design outcome |
|---|---|---|
| Strict valid JSON | Confirm valid strict files parse under `strict-json` | `VALID_STRICT` with diagnostics |
| Invalid backslash escape | Confirm detection and compatibility diagnostics | `VALID_COMPATIBILITY` or `INVALID_RECOVERABLE_FOR_DISPLAY`, never silent repair |
| Duplicate key detection | Confirm duplicate-key warning behavior | Warning and human-review flag if authority-impacting |
| Required key missing | Confirm required-key failure handling | Mark unavailable or human review required |
| Partial write simulation | Confirm unstable source is rejected/retried | `PARTIAL_WRITE_SUSPECTED`, no cache promotion |
| Mtime/size changed during read | Confirm stable-read guard behavior | Reject/retry; no partial truth |
| Strict vs compatibility mismatch | Confirm fail-closed mismatch handling | `HUMAN_REVIEW_REQUIRED` |
| Secret file redaction | Confirm no values are exposed | `FORBIDDEN_SECRET` or redacted metadata only |
| JSONL invalid line warn/skip | Confirm analytics-only behavior | Invalid line skipped with warning |
| Dashboard label mapping | Confirm status labels are clear | No dashboard authority |
| Cache invalidation on checksum change | Confirm source-change invalidation | Cache invalidated or downgraded |

No test files or test code are created by this Stage 2B task.

### 13. Stage 2C Entry Criteria

Before Stage 2C read concurrency/file-stability design or any later parser prototype:

- `DEC-JSON-001` must be approved, or Stage 2C must explicitly remain design-only.
- Parser mode matrix must be reviewed.
- Compatibility behavior contract must be reviewed.
- Invalid escape policy must be reviewed.
- Secret policy remains no-read/no-cache unless `DEC-SECRET-*` decisions approve otherwise.
- Cache interaction rules must be reviewed.
- Dashboard interaction rules must be reviewed.
- No source JSON normalization may occur unless separately approved.
- No strict shadow-copy generation may occur unless separately approved.
- No prototype may begin until Stage 2B design is accepted and Stage 1.6 gates are updated.
- MT5 runtime behavior must remain unchanged.

### 14. Codex Task Backlog Update

Future bounded tasks only:

| Task | Scope | Implementation allowed? |
|---|---|---|
| Stage 2C read concurrency and file stability design spec | Stable-read, partial-write, retry/reject, checksum/mtime/size design | No |
| Stage 2D dashboard truth-labeling wireframe/spec | Display labels for strict/compatibility/stale/expired/secret/unknown states | No |
| Stage 2E cache registry skeleton proposal | Only after human gates; proposal only unless approved | Not currently |
| Compatibility parser prototype task | Only after `DEC-JSON-001` approval | Not currently |
| JSON normalization proposal task | Separate proposal; source-file changes not approved | No |
| Strict shadow-copy proposal task | Separate proposal; shadow generation not approved | No |
| Missing runtime surface confirmation task | Human worksheet for missing/unknown surfaces | No runtime changes |

### 15. Stage 2B Completion Criteria

- Design scope and non-goals recorded: **complete**.
- Problem statement recorded for invalid strict JSON and permissive MT5/MQL behavior: **complete**.
- Parser modes defined: **complete**.
- Runtime-critical JSON parser assignment recorded: **complete**.
- Compatibility JSON behavior contract recorded: **complete**.
- Parse result state model recorded: **complete**.
- Invalid escape handling policy recorded: **complete**.
- Shadow copy / normalization options recorded without approval: **complete**.
- Parser diagnostics model recorded without secret values: **complete**.
- Cache interaction rules recorded: **complete**.
- Dashboard interaction rules recorded: **complete**.
- Future validation test strategy recorded without creating tests/code: **complete**.
- Stage 2C entry criteria recorded: **complete**.
- Stage 2 prototype/implementation remains blocked: **complete**.
- `AI\ai_current_plan.json` is not approved as stale runtime truth from RAM: **complete**.

## Stage 2C — Read Concurrency and File Stability Design Spec

### 1. Design Scope and Non-Goals

This stage is **design/specification only**. It records a future-safe contract for reading files that may be written by MT5, adapters, scripts, or dashboard tooling during runtime.

Non-goals and forbidden work for this stage:

- No file watcher implementation.
- No RAM loader implementation.
- No parser implementation.
- No EXE implementation.
- No dashboard implementation.
- No locking implementation.
- No runtime/config/status/log writes.
- No JSON normalization.
- No secret reads or caching.
- No trading decision authority.
- No stale, partial, unstable, or expired read may become runtime truth.
- No changes to MT5 trading logic, MQL files, runtime configuration, state files, reports, logs, adapter files, dashboard files, scripts, binaries, or generated runtime artifacts.

Stage 2 prototype/implementation remains **blocked**. All unresolved decisions remain **Pending Human Decision** unless explicitly approved later.

### 2. Problem Statement

A future EXE or RAM-cache layer may need to read file-based runtime surfaces while MT5, adapter processes, scripts, or dashboard tools are writing those same surfaces. This creates concurrency and stability risks:

- Reads can race with active writes and produce partial snapshots.
- File watcher events can arrive before a writer has finished flushing content.
- `mtime` and `size` alone are not authoritative enough to prove semantic validity.
- A checksum calculated from partial data only proves the partial data was read consistently.
- Parser success does not prove the file was complete if the write protocol is unknown.
- Last-known-good cache fallback can hide stale or partial data if not clearly labeled.
- MT5-owned files must remain source authority unless a future human decision explicitly changes authority.
- Stage 2 implementation remains blocked until at minimum `DEC-CONC-001` and `DEC-PATH-001` are approved or explicitly scoped as design-only constraints.

Safe future behavior must verify read stability before parser use, cache update, dashboard display, or any trading-adjacent EXE action. Dashboard-visible state must distinguish stable, stale, expired, partial-write suspected, unavailable, forbidden, and unknown data.

### 3. Stable Read Strategy

Future implementation, if separately approved, should use a non-invasive stable-read strategy. This is a design contract only, not executable logic.

Required future stable-read sequence:

1. Resolve source path using the human-approved live MT5 terminal root/path contract.
2. Capture pre-read metadata:
   - file exists / missing state
   - `mtime`
   - size
   - permissions or access status if available
   - source path identity
3. Read raw bytes or raw text without modifying the source file.
4. Capture post-read metadata:
   - file exists / missing state
   - `mtime`
   - size
   - permissions or access status if available
5. Reject or retry if `mtime` or size changed during read.
6. For volatile files, optionally require a short stability window after a successful read.
7. Compute checksum only after metadata is stable.
8. Attach read diagnostics to the future cache entry or dashboard status.
9. Pass raw content to the Stage 2B parser mode only after read stability is confirmed.
10. Never parse a partial write as runtime truth.
11. Never silently fall back to last-known-good data without a stale or expired label.
12. Never elevate RAM cache above source-file authority.
13. Never read, cache, display, or log secret values unless later explicitly approved by human decision.

Stable-read success means only that a consistent raw snapshot was obtained. It does **not** mean the snapshot is semantically valid, fresh, authoritative, or safe for trading-adjacent use.

### 4. Partial Write Detection Model

| Detection signal | Severity | Retry allowed | Cache allowed | Dashboard display | Trading-adjacent EXE action |
|---|---:|---|---|---|---|
| `mtime` changed during read | high | yes, bounded | no for this attempt | stale/unavailable warning | blocked |
| size changed during read | high | yes, bounded | no for this attempt | stale/unavailable warning | blocked |
| unexpected zero-byte file | high to critical | yes for volatile/generated files; no if repeated | no | unavailable with warning | blocked |
| truncated JSON or text | high | yes if recent write suspected | no | unavailable or stale last-known-good | blocked |
| parse failure after recent `mtime` | high | yes, bounded | no | partial-write suspected or invalid | blocked |
| checksum changes between stable attempts | high | yes, bounded | no until stable | unstable warning | blocked |
| file disappears during read | high | yes for generated/optional; no for required after retries | no | unavailable | blocked |
| permission or writer-lock error | high | yes if transient; otherwise no | no | unavailable/permission warning | blocked |
| incomplete JSONL final line | medium | optional for analytics; not required for truth | conditional for derived analytics only | warn/skip invalid final line | blocked for truth use |
| adapter output updates too frequently to stabilize | medium to high | yes, bounded with coalescing | no until stable | stale/unavailable adapter status | blocked for trading-adjacent use |
| watcher event without stable read | medium | delayed stable-read attempt | no | pending refresh / not refreshed | blocked |
| unknown temporary-file pattern | unknown | human review | no | unknown/unclassified | blocked |

Partial-write suspicion must be visible in diagnostics and dashboard labels. A suspected partial read must not update an authoritative cache state.

### 5. Retry and Backoff Design

Future retry behavior must be bounded and non-invasive. No retry logic is implemented in this stage.

Recommended design defaults:

| File/class | Retry policy | Backoff profile | Failure outcome |
|---|---|---|---|
| execution-critical/config-critical files | small bounded retry count | short backoff with stability re-check | fail closed / mark unavailable |
| governance/authority/cohort status | small bounded retry count | short backoff due to runtime volatility | stale/expired blocks trading-adjacent EXE action |
| adapter exporter/intake/status outputs | bounded retry with event coalescing | short backoff; tolerate frequent refresh | mark stale/unavailable if unstable |
| journals/logs/report-derived analytics | bounded retry or single-pass read | longer backoff for large files | warn-only / derived display only |
| missing/unknown surfaces | no repeated active probing unless approved | none or manual review | unavailable / forbidden |
| secrets | no read by default | none | forbidden-secret |
| lock/stop sentinels | live existence re-check only | immediate re-check if needed | do not cache as truth |

General retry constraints:

- No infinite retry loops.
- No hidden retry that blocks MT5 runtime.
- No write, repair, normalization, or lock attempt.
- Last-known-good may be displayed only with stale/expired labeling and never as runtime truth.
- If retries do not produce a stable read, critical files fail closed and visibility-only files mark unavailable or stale.
- Retry counts and timings require future human approval before implementation.

### 6. File Locking and Atomicity Policy

| Topic | Design decision |
|---|---|
| EXE file locks | Do not assume the EXE can lock files used by MT5. |
| Risk of locking | Locking can break MT5 write/read behavior or introduce runtime delays. |
| Current stage | No locking implementation and no locking requirement. |
| Preferred V1 approach | Non-invasive stable-read detection using pre/post metadata and checksum. |
| Atomic writer pattern | A future writer pattern may use write-temp + flush + rename only if compatible with MT5 and approved separately. |
| MT5 writer changes | Not approved in this stage. Any MT5 write-behavior change requires explicit separate approval and regression testing. |
| Existing file formats | Must not be changed by this design. |
| Human dependency | `DEC-CONC-001` remains **Pending Human Decision**. |

Future implementation must not require existing MT5 writers to change unless a separate approved task authorizes MQL/runtime changes.

### 7. File Watcher Event Policy

File watcher behavior is design-only and not approved for implementation.

Future watcher principles:

- File watcher events are hints, not truth.
- A watcher event must trigger a delayed stable-read attempt.
- Multiple rapid events should be coalesced before attempting refresh.
- Watcher logic must not write, repair, normalize, delete, rename, or move files.
- Watcher logic must not treat an event itself as a successful refresh.
- Cache/dashboard state may update only after stable read plus parser diagnostics.
- Missing, unavailable, stale, expired, partial-write suspected, forbidden, and unknown states must be visible.
- Watchers must not read or cache secret values unless secret policy is later approved.
- Watchers must not convert dashboard/generated output into runtime authority.
- Watcher design depends on `DEC-CONC-001` and `DEC-PATH-001`.

### 8. Per-File Concurrency Classification

| File/class | Likely writer | Read volatility | Criticality | Stable-read required | Watcher suitable | Polling suitable | Locking allowed | Retry policy | Partial-write behavior | Cache behavior | Dashboard behavior | Human decision dependency | Notes |
|---|---|---:|---|---|---|---|---|---|---|---|---|---|---|
| `AI\ai_current_plan.json` | MT5/source file; human semantic edits unknown | medium | config-critical / execution-adjacent | yes | conditional, design-only | conditional | no by default | bounded retry then fail closed | reject; no stale runtime truth | conditional design only; compatibility parser dependency | cached/derived/stale labels only | `DEC-JSON-001`, `DEC-AUTH-001`, `DEC-CONC-001`, `DEC-PATH-001` | invalid strict JSON; must not become RAM truth |
| `AI\ai_previous_plan_backup.json` | MT5/script/human unknown | low to medium | config-critical backup / report-adjacent | yes | conditional, design-only | conditional | no by default | bounded retry; mark unavailable if unstable | reject unstable snapshot | conditional design only | cached/derived view | `DEC-JSON-001`, `DEC-CONC-001` | invalid strict JSON; not runtime truth |
| `AI\ai_evolution_state.json` | MT5/evolution layer unknown | medium | state-critical / strategy-memory-adjacent | yes | conditional, design-only | conditional | no by default | bounded retry; fail closed for trading-adjacent use | reject unstable snapshot | conditional design only | cached/derived/stale labels | `DEC-JSON-001`, `DEC-CONC-001` | invalid strict JSON |
| `AI\ai_runtime_secrets.json` | human-owned / secret-bearing | low | secret-critical | not applicable by default | no | no | no | no read | forbidden | forbidden to cache | forbidden/secret; no values | `DEC-SECRET-001/002/003` | no secret reads/cache/display by default |
| `AI\runtime_governance_status.*` | MT5/generated | medium to high | state-critical | yes | conditional, design-only | conditional | no by default | bounded short retry | reject unstable; stale/expired visible | conditional; 600s stale / 1800s expired default | authoritative file truth only if stable; otherwise stale/unavailable | `DEC-CONC-001`, `DEC-PATH-001`, `DEC-FRESH-001` | stale/expired blocks trading-adjacent EXE action |
| `AI\execution_authority_status.*` | MT5/generated | medium to high | state-critical / authority-critical | yes | conditional, design-only | conditional | no by default | bounded short retry | reject unstable; stale/expired visible | conditional; 600s stale / 1800s expired default | authoritative file truth only if stable; otherwise stale/unavailable | `DEC-CONC-001`, `DEC-PATH-001`, `DEC-FRESH-001` | stale/expired blocks trading-adjacent EXE action |
| `AI\active_operating_cohort.*` | MT5/generated | medium to high | state-critical | yes | conditional, design-only | conditional | no by default | bounded short retry | reject unstable; stale/expired visible | conditional; 600s stale / 1800s expired default | authoritative file truth only if stable; otherwise stale/unavailable | `DEC-CONC-001`, `DEC-PATH-001`, `DEC-FRESH-001` | stale/expired blocks trading-adjacent EXE action |
| `AI\ai_performance_journal.jsonl` | MT5/journal writers | high / append-like | report-memory / derived analytics | yes | conditional for tail status | conditional | no by default | bounded or snapshot read | incomplete final line may warn/skip for analytics only | conditional derived cache only | derived view; warn/skip invalid lines | `DEC-CONC-001` | never runtime truth |
| `AI\council_feedback.json` | MT5/council tooling unknown | medium | report/memory / advisory | yes | conditional, design-only | conditional | no by default | bounded retry | reject unstable snapshot | conditional read-only/derived | derived/cached view | `DEC-CONC-001`, authority confirmation | valid strict JSON observed in Stage 2B |
| ATAS exporter outputs | adapter/exporter | high | adapter context / visibility-to-advisory | yes | conditional, design-only | conditional | no by default | bounded short retry/coalesce | reject until stable | conditional; 30s stale / 120s expired default | adapter-owned cached/derived view | `DEC-CONC-001`, `DEC-FRESH-002` | must not be runtime truth |
| ATAS intake/advisory/status outputs | adapter/intake tooling | high | adapter advisory/status | yes | conditional, design-only | conditional | no by default | bounded short retry/coalesce | reject until stable | conditional; 45s stale / 180s expired default | adapter-owned cached/derived view | `DEC-CONC-001`, `DEC-FRESH-002` | advisory only unless authority approved later |
| dashboard-generated outputs | dashboard/MT5 exporter/tools | medium | visibility-only | yes for display accuracy | conditional, design-only | conditional | no | bounded or mark stale | do not use unstable output | derived/display cache only | visibility-only; never authority | `DEC-WRITE-002`, `DEC-CONC-001` | dashboard must not write runtime truth |
| lock/stop sentinel files | MT5/human/tool unknown | high semantic sensitivity | execution-critical sentinel | live check required | no cached watcher truth | live polling/existence check only | no | immediate live re-check only | no cache from unstable state | do not cache as truth | live state / unavailable | `DEC-CONC-001`, authority confirmation | existence must be current |
| logs | MT5/scripts/adapters | high append-like | report-only / diagnostics | snapshot/tail stability required | conditional for tail hints | conditional | no | warn-only | tolerate tail instability for derived display | derived cache only | log-tail-derived / stale label | `DEC-CONC-001` | never runtime truth |
| reports/docs/memory files | MT5/scripts/human/generated | low to medium | report/memory | yes for cache | optional | conditional | no | bounded or mark stale | reject unstable snapshot | safe only if read-only/report cache | derived/read-only memory view | authority confirmation if used | not trading truth |
| missing/unknown surfaces | unknown | unknown | unknown | no approved read target | no | no | no | none until classified | unavailable | forbidden until classified | unknown/unclassified | `DEC-MISS-*`, `DEC-PATH-001` | not eligible until classified |

### 9. Metadata and Diagnostics Model

Future stable-read diagnostics should include these fields. This is a data contract only, not an implementation schema:

| Field | Purpose |
|---|---|
| `source_path` | Original source path resolved from approved path contract. |
| `exists` | Whether file existed at read attempt. |
| `access_mode` | Intended access mode such as observe-only, cache-read, forbidden-secret, or unknown-forbidden. |
| `read_started_at` | Timestamp for read start. |
| `read_completed_at` | Timestamp for read completion. |
| `pre_mtime` | Metadata timestamp before read. |
| `post_mtime` | Metadata timestamp after read. |
| `pre_size` | Size before read. |
| `post_size` | Size after read. |
| `stable_metadata` | Whether pre/post metadata was stable. |
| `stability_window_ms` | Optional stability window used for volatile files. |
| `retry_count` | Number of read retries attempted. |
| `checksum` | Checksum of stable raw content only. |
| `partial_write_suspected` | Flag for instability or truncation suspicion. |
| `permission_error` | Permission/access error flag. |
| `file_disappeared` | File disappeared during read attempt. |
| `read_status` | Stable, unstable, missing, unavailable, forbidden, or unknown. |
| `freshness_state` | Fresh, stale, expired, unavailable, forbidden, or unknown. |
| `parser_mode` | Stage 2B parser mode assigned to this file/class. |
| `parser_status` | Parser result state, if parsing is allowed. |
| `cache_allowed` | Whether this read result may update cache under Stage 2A/2B rules. |
| `dashboard_label` | Dashboard truth/staleness label. |
| `human_review_required` | Whether unresolved ambiguity requires review. |
| `warnings` | Non-secret warning list. |
| `errors` | Non-secret error list. |

Diagnostics must not include secret values, raw sensitive content, or unredacted credentials.

### 10. Cache Interaction Rules

Cache behavior must obey Stage 2A and Stage 2B constraints plus the stable-read contract:

- Cache update requires a stable read.
- Cache update requires parser result compatible with the assigned Stage 2B parser mode.
- Cache entry must include read diagnostics.
- Cache entry must include parser diagnostics where parsing is allowed.
- Cache entry must include raw source checksum from stable content.
- Cache must invalidate on `mtime`, size, or checksum change.
- Cache must invalidate on parser-mode mismatch.
- Cache must invalidate on parse failure for config-critical/state-critical files.
- Cache must invalidate on partial-write suspicion.
- Cache must not update from unstable reads.
- Last-known-good may remain only as stale/expired display state.
- Execution-critical/config-critical stale data must block trading-adjacent EXE actions.
- Secrets must not enter cache.
- Missing/unknown surfaces must not enter cache.
- Dashboard-generated outputs must not enter cache as runtime truth.
- `AI\ai_current_plan.json` must not be approved as stale runtime truth from RAM.

### 11. Dashboard Interaction Rules

Dashboard behavior must remain visibility-only:

- Dashboard may show read status, freshness, diagnostics, and warnings.
- Dashboard must distinguish:
  - stable
  - stale
  - expired
  - partial-write suspected
  - unavailable
  - forbidden-secret
  - unknown/unclassified
- Dashboard must not present last-known-good as current truth.
- Dashboard must not present cached data as source authority.
- Dashboard must not display secret values.
- Dashboard must not become a writer or source of truth.
- Dashboard must identify MT5-owned, adapter-owned, generated, human-owned, and unknown data where known.
- Dashboard must clearly mark unstable or partial reads as unavailable or stale, not fresh.
- Dashboard-only data must never be used to drive runtime/trading decisions.

### 12. Failure Behavior Matrix

| Failure condition | Severity | Retry policy | Cache behavior | Dashboard behavior | Trading-adjacent EXE behavior | Human review required |
|---|---:|---|---|---|---|---|
| file missing | medium to critical | optional if generated; otherwise none after bounded retries | no update | unavailable or missing | blocked if critical | yes if required/unknown |
| file disappears during read | high | bounded retry | no update | unavailable / partial-read warning | blocked | yes if repeated |
| permission denied | high | bounded retry only if transient | no update | unavailable / permission warning | blocked | yes |
| `mtime` changed during read | high | bounded retry | no update | partial-write suspected | blocked | no unless repeated |
| size changed during read | high | bounded retry | no update | partial-write suspected | blocked | no unless repeated |
| checksum changed between stable attempts | high | bounded retry | invalidate/hold stale-labeled last-known-good | unstable warning | blocked | yes if persistent |
| unexpected zero-byte file | high to critical | bounded retry for generated files | no update | unavailable / zero-byte warning | blocked | yes |
| parse failure after stable read | high for config/state; medium for report | no retry unless file changed again | invalidate or keep stale-labeled old view | invalid/unavailable | blocked if critical | yes for config/state |
| parse failure after unstable read | high | bounded stable-read retry | no update | partial-write suspected | blocked | no unless persistent |
| incomplete JSONL last line | medium | optional re-read; warn/skip for analytics | derived cache may skip invalid tail only | warning / derived view | blocked for truth use | no unless widespread |
| stale | medium to high | refresh attempt allowed | stale-labeled only | stale cached view | blocked for critical/authority status | no unless thresholds disputed |
| expired | high | refresh attempt allowed | expired/unavailable | expired/unavailable | blocked | yes if persistent |
| watcher event without stable read | medium | delayed stable-read attempt | no update | refresh pending / not refreshed | blocked | no |
| secret access attempted | critical | none | forbidden | forbidden-secret | blocked | yes |
| unknown file authority | high | none until classified | no update | unknown/unclassified | blocked | yes |
| multiple writer conflict | high to critical | stop cache update until resolved | invalidate/hold stale-labeled old view | conflict warning | blocked | yes |

### 13. Future Validation Test Strategy

Future tests are design-only and must not be created in this stage. A later approved task should test at minimum:

- stable read success for a static file.
- `mtime` changes during read.
- size changes during read.
- file disappears during read.
- zero-byte transient file.
- partial JSON write.
- incomplete JSONL final line.
- rapid watcher events coalesced before read.
- checksum invalidation after source update.
- permission denied.
- last-known-good stale labeling.
- secret access blocked.
- dashboard label mapping for stable/stale/expired/partial/unavailable/forbidden/unknown.
- no cache update from unstable read.
- parser interaction after stable read.
- cache invalidation on parser failure.
- no runtime/config/status/log/source file modification during tests unless a disposable fixture is explicitly approved.

No parser, watcher, validator, file-locking, RAM loader, dashboard, EXE, or test files are created by this stage.

### 14. Stage 2D Entry Criteria

Before Stage 2D dashboard truth-labeling wireframe/spec:

- Stage 2C design reviewed.
- `DEC-CONC-001` remains explicitly design-only or is approved by a human.
- `DEC-PATH-001` remains explicitly design-only or is approved by a human.
- Stable-read diagnostics model reviewed.
- Failure behavior matrix reviewed.
- Cache interaction rules reviewed.
- Dashboard interaction rules reviewed.
- Secret no-read/no-cache/no-display default remains in force unless human-approved otherwise.
- No source JSON normalization is approved by this section.
- No file watcher, parser, cache, EXE, dashboard, locking, validator, or test implementation is approved by this section.
- Stage 2 prototype/implementation remains blocked unless all human gates are explicitly cleared.

### 15. Codex Task Backlog Update

Future bounded tasks only:

| Task ID | Task | Scope boundary |
|---|---|---|
| `STAGE-2D-DASHBOARD-TRUTH-SPEC` | Dashboard truth-labeling wireframe/spec | Design-only; no dashboard implementation. |
| `STAGE-2E-CACHE-SKELETON-PROPOSAL` | Read-only cache registry skeleton proposal | Only after human gates; proposal first, no implementation unless separately approved. |
| `STAGE-2C-FILE-WATCHER-DESIGN-REFINE` | File watcher design refinement | Design-only; events remain hints, not truth. |
| `STAGE-2C-CONCURRENCY-TEST-PLAN` | Read-concurrency validation test plan | Test plan only; no test files/code in migration workspace. |
| `STAGE-MT5-WRITER-ATOMICITY-ASSESS` | MT5 writer atomicity assessment | Separate assessment; no MQL/code changes approved. |
| `STAGE-2B-COMPAT-PARSER-PROTOTYPE` | Compatibility parser prototype | Only after `DEC-JSON-001` approval and fixture-only test scope. |
| `STAGE-RAM-LOADER-PROTOTYPE` | RAM loader prototype | Only after Stage 2A/2B/2C gates and human approvals are complete. |

### 16. Stage 2C Completion Criteria

- Design scope and non-goals recorded: **complete**.
- Problem statement recorded for concurrent file reads: **complete**.
- Stable-read strategy recorded without implementation code: **complete**.
- Partial-write detection model recorded: **complete**.
- Retry/backoff design recorded without implementation: **complete**.
- Locking/atomicity policy recorded without locking implementation: **complete**.
- File watcher event policy recorded without watcher implementation: **complete**.
- Per-file concurrency classification recorded: **complete**.
- Read metadata/diagnostics model recorded without secret values: **complete**.
- Cache interaction rules recorded: **complete**.
- Dashboard interaction rules recorded: **complete**.
- Failure behavior matrix recorded: **complete**.
- Future validation test strategy recorded without creating tests/code: **complete**.
- Stage 2D entry criteria recorded: **complete**.
- Stage 2 prototype/implementation remains blocked: **complete**.
- `AI\ai_current_plan.json` is not approved as stale runtime truth from RAM: **complete**.
- Secrets remain forbidden from read/cache/display by default: **complete**.

## Stage 2D — Dashboard Truth-Labeling Wireframe and Spec

### 1. Design Scope and Non-Goals

This section is a **design-only** dashboard truth-labeling specification for the MT5-to-EXE migration.

Non-goals and forbidden actions for this stage:

- No dashboard implementation.
- No UI code.
- No EXE implementation.
- No RAM loader implementation.
- No parser implementation.
- No watcher implementation.
- No runtime/config/status/log writes.
- No JSON normalization.
- No secret reads, secret caching, or secret display.
- No trading decision authority.
- Dashboard V1 is visibility-only.
- Dashboard V1 must never become the source of truth.
- Dashboard V1 must never hide stale, expired, unavailable, partial-read, parser-warning, compatibility-parsed, forbidden-secret, unknown, or human-review-required states.
- Dashboard-displayed values must never silently become runtime truth.
- Stage 2 prototype/implementation remains **blocked**.

### 2. Dashboard V1 Doctrine

Dashboard V1 exists to observe, explain, and label system state. It does not decide trading behavior and does not replace MT5/file authority.

Doctrine:

- Dashboard observes and explains system state.
- Dashboard does not decide trading behavior.
- Dashboard does not write runtime/config/state/status/log files.
- Dashboard does not replace MT5 truth.
- Dashboard does not normalize, repair, delete, rename, move, or regenerate runtime files.
- Dashboard values must carry source path/class, owner, read status, parser status, freshness status, and truth label where available.
- Dashboard must expose uncertainty instead of hiding it.
- Dashboard must distinguish MT5-owned, adapter-owned, generated, cached, derived, human-owned, script-owned, dashboard-generated, and unknown data.
- Dashboard must show warnings for stale, expired, parser-warning, compatibility-parsed, partial-write suspected, missing, unknown, multiple-writer, blocked, or forbidden-secret states.
- Dashboard V1 actions are limited to visibility and diagnostics unless a later human-approved implementation stage explicitly changes this boundary.
- Unresolved decisions remain **Pending Human Decision**.

### 3. Truth Label Taxonomy

| Truth label | Meaning | Allowed dashboard display | Allowed user interpretation | Forbidden interpretation | Trading-adjacent EXE action allowed | Required warning/badge text |
|---|---|---|---|---|---|---|
| `AUTHORITATIVE_FILE_TRUTH` | Source file is the identified current authority for the displayed value and the read is stable/fresh. | Yes, with source owner/path and freshness. | "This is the latest stable view of the authoritative file." | "Dashboard is the authority" or "RAM cache can override the file." | No by default; implementation not approved. | `AUTHORITATIVE FILE — VIEW ONLY` |
| `CACHED_VIEW` | Value is from future cache design and reflects a prior stable read. | Yes, with cache time, source hash, and freshness. | "This is a cached view of a source." | "This is guaranteed current truth." | No. | `CACHED VIEW — VERIFY FRESHNESS` |
| `DERIVED_VIEW` | Value is computed/summarized from one or more sources. | Yes, with derivation source list. | "This is an informational summary." | "Derived value replaces source authority." | No. | `DERIVED VIEW — NOT AUTHORITY` |
| `STALE_CACHED_VIEW` | Cached/source view exceeded stale threshold but is not necessarily expired. | Yes, with stale age and threshold. | "This may be useful for visibility only." | "Safe to use as current runtime truth." | No. | `STALE — DO NOT TREAT AS TRUTH` |
| `EXPIRED_UNAVAILABLE` | Data exceeded expiry threshold, could not be read, or is not reliable enough to display as current. | Yes, status only; value hidden or last-known clearly expired. | "Current value is unavailable." | "Last-known value is current." | No. | `EXPIRED / UNAVAILABLE` |
| `PARTIAL_WRITE_SUSPECTED` | Stable-read checks indicate the source may have been read during a writer update. | Status only or stale last-known with warning. | "Source is changing or unstable." | "Partial content is valid current truth." | No. | `PARTIAL WRITE SUSPECTED — REFRESH REQUIRED` |
| `PARSER_WARNING` | Parser diagnostics found non-fatal issues or compatibility concerns. | Yes, with warnings and no hidden errors. | "Displayed content has parser caveats." | "Parser warnings are harmless by default." | No. | `PARSER WARNING` |
| `COMPATIBILITY_PARSED` | Data required compatibility parser behavior, not strict JSON. | Yes, only if allowed by parser/read/security rules and labeled. | "Parsed using compatibility semantics for visibility." | "Equivalent to strict JSON authority" or "safe to normalize." | No. | `COMPATIBILITY PARSED — VIEW ONLY` |
| `FORBIDDEN_SECRET` | Source is secret-bearing or access is forbidden by policy. | Status/redacted metadata only if approved; no values. | "Secret content is intentionally hidden." | "Dashboard can inspect or validate secret values." | No. | `SECRET FORBIDDEN — VALUES HIDDEN` |
| `UNKNOWN_UNCLASSIFIED` | Source ownership, format, freshness, or authority is unresolved. | Status only. | "Human review is required." | "Safe to cache or display as truth." | No. | `UNKNOWN — HUMAN REVIEW REQUIRED` |
| `HUMAN_REVIEW_REQUIRED` | State cannot be safely interpreted without an explicit human decision. | Yes, as blocker/decision row. | "Migration gate remains blocked." | "Proceed by assumption." | No. | `PENDING HUMAN DECISION` |
| `NOT_APPLICABLE` | Label does not apply to this panel/source. | Yes, for empty or design-only areas. | "No runtime value exists here." | "Missing data is safe by default." | No. | `N/A — DESIGN ONLY` |

### 4. Dashboard Panel Map

| Panel ID | Panel name | Purpose | Primary source files/classes | Data ownership | Truth labels allowed | Refresh expectation | Stale/expired behavior | Secret exposure risk | User action allowed | Forbidden action | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|
| `DASH-001` | System Overview / Readiness | Summarize observation readiness and blockers. | Aggregated diagnostics from registry, parser, read-stability, decision worksheet. | Derived/generated view. | `DERIVED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `HUMAN_REVIEW_REQUIRED`, `NOT_APPLICABLE` | Future refresh after stable reads only. | Stale/expired critical dependencies degrade or block readiness. | Low if secrets remain redacted. | View readiness and blockers. | Use readiness to control MT5 trading. | Readiness is display-only unless separately approved. |
| `DASH-002` | Active Plan View | Display active plan structure/status when allowed. | `AI\ai_current_plan.json` | MT5/file truth pending decisions. | `CACHED_VIEW`, `DERIVED_VIEW`, `COMPATIBILITY_PARSED`, `PARSER_WARNING`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `HUMAN_REVIEW_REQUIRED` | Stable read + approved parser policy required. | Stale/expired plan cannot be runtime truth. | Medium; plan may contain sensitive operational context. | View source path, parser state, warnings. | Edit/save/normalize active plan. | Depends on `DEC-JSON-001` and `DEC-AUTH-001`. |
| `DASH-003` | Governance and Execution Authority | Show governance and execution status. | `AI\runtime_governance_status.*`, `AI\execution_authority_status.*` | MT5-owned/generated. | `AUTHORITATIVE_FILE_TRUTH`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED`, `UNKNOWN_UNCLASSIFIED` | Stale after 600s, expired after 1800s unless changed by human decision. | Expired/invalid marks readiness not-ready/degraded. | Low to medium. | View freshness and source. | Override authority or generate replacement values. | Dashboard never overrides authority state. |
| `DASH-004` | Active Operating Cohort | Display cohort/source selection state. | `AI\active_operating_cohort.*` | MT5-owned/generated. | `AUTHORITATIVE_FILE_TRUTH`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED` | Stale after 600s, expired after 1800s unless changed. | Expired/invalid marks not-ready/degraded. | Low to medium. | View status and age. | Select/change cohort. | Cohort writes are forbidden in V1. |
| `DASH-005` | RAM Cache / File Sync Status | Show future cache registry status and file sync diagnostics. | Stage 2A registry classes and Stage 2C diagnostics. | Derived/generated view. | `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED`, `UNKNOWN_UNCLASSIFIED`, `FORBIDDEN_SECRET` | Future registry refresh only after stable reads. | Show invalidation/stale reason. | Medium if metadata includes paths. | View diagnostics. | Force cache refresh by writing files. | Design-only until implementation gates clear. |
| `DASH-006` | Parser and Compatibility Warnings | Show strict/compat parser status and warnings. | Stage 2B diagnostics; runtime JSON/JSONL classes. | Derived/generated view. | `PARSER_WARNING`, `COMPATIBILITY_PARSED`, `EXPIRED_UNAVAILABLE`, `HUMAN_REVIEW_REQUIRED`, `FORBIDDEN_SECRET` | After stable read and parser diagnostics. | Parser failures block display as truth. | Medium. | View warnings. | Auto-fix/normalize JSON. | No parser implementation approved. |
| `DASH-007` | Read Stability / Partial Write Diagnostics | Show file stability diagnostics. | Stage 2C read diagnostics across source classes. | Derived/generated view. | `PARTIAL_WRITE_SUSPECTED`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `UNKNOWN_UNCLASSIFIED` | After stable-read checks. | Partial-write suspicion blocks current display. | Low to medium. | View diagnostics and warnings. | Lock files or retry forever. | No watcher/locking implementation approved. |
| `DASH-008` | ATAS Adapter Status | Show ATAS exporter/intake/advisory state. | ATAS exporter outputs; ATAS intake/advisory/status outputs. | Adapter-owned/generated. | `CACHED_VIEW`, `DERIVED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED`, `UNKNOWN_UNCLASSIFIED` | Exporter stale 30s/expired 120s; intake stale 45s/expired 180s. | Stale/expired blocks trading-adjacent EXE use. | Medium depending payload. | View status and age. | Modify adapter outputs. | Adapter data is not MT5 runtime truth. |
| `DASH-009` | Recent Logs / Journal Summary | Summarize logs and JSONL journal. | `AI\ai_performance_journal.jsonl`, logs. | Generated/report layer. | `DERIVED_VIEW`, `PARSER_WARNING`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE` | Tail/read-derived only after stable read; invalid JSONL lines warn/skip. | Stale logs remain report-only. | Medium; logs may contain sensitive operational details. | View summaries. | Treat journal/logs as runtime authority. | Invalid JSONL final/lines must not become truth. |
| `DASH-010` | AI Control / Capability Status | Show whether future control functions are allowed/blocked. | Decision worksheet, authority/write-boundary decisions, governance states. | Derived from plan/gates. | `DERIVED_VIEW`, `HUMAN_REVIEW_REQUIRED`, `NOT_APPLICABLE` | Manual/plan-driven until implementation approved. | Pending decisions remain blockers. | Low. | View capability status. | Start/stop/control trading. | Control functions are not approved. |
| `DASH-011` | Risks and Open Human Decisions | Show unresolved gates and risks. | Stage 1.6 decision matrix and later stage blockers. | Human-owned planning layer. | `HUMAN_REVIEW_REQUIRED`, `DERIVED_VIEW`, `NOT_APPLICABLE` | Refresh from plan content. | Pending decisions block implementation. | Low. | View decisions. | Infer approval silently. | All unresolved items remain Pending Human Decision. |
| `DASH-012` | Developer Diagnostics View | Display technical diagnostics for future developers. | Parser/read/cache diagnostics, source maps, failure matrix. | Derived/generated view. | `DERIVED_VIEW`, `PARSER_WARNING`, `PARTIAL_WRITE_SUSPECTED`, `UNKNOWN_UNCLASSIFIED`, `FORBIDDEN_SECRET` | Diagnostic-only. | Show warning or unavailable states. | Medium; must redact secrets. | View diagnostics. | Write runtime/config/state files. | Developer tool V1 writes remain forbidden. |
| `DASH-013` | Secret / Security Status | Show secret-policy status without values. | `AI\ai_runtime_secrets.json`, secret-bearing classes. | Human-owned/secret-bearing. | `FORBIDDEN_SECRET`, `HUMAN_REVIEW_REQUIRED`, `NOT_APPLICABLE` | No read by default; status from policy only unless approved. | Secret access attempted is blocked/critical. | Critical. | View policy status only. | Read/cache/display/log secret values. | No secret values may appear. |
| `DASH-014` | Missing Runtime Surfaces | Show missing/unclassified runtime surfaces. | Missing council/live-exit/lifecycle/generated/unknown surfaces. | Unknown/generated/needs decision. | `UNKNOWN_UNCLASSIFIED`, `EXPIRED_UNAVAILABLE`, `HUMAN_REVIEW_REQUIRED` | Manual/scan-derived in future design. | Missing critical dependency blocks readiness. | Unknown. | View missing list. | Create or infer missing files. | Missing classification remains a gate. |
| `DASH-015` | Migration Progress | Show migration stage completion and blocked implementation status. | `AI\MT5_EXE_MIGRATION_PLAN.md` | Human-owned documentation. | `DERIVED_VIEW`, `HUMAN_REVIEW_REQUIRED`, `NOT_APPLICABLE` | Refresh from plan. | Implementation remains blocked until gates clear. | Low. | View progress. | Approve implementation implicitly. | Stage 2 design-only is approved; prototype blocked. |

### 5. Source-to-Panel Mapping

| Source file/class | Owning layer | Dashboard panel(s) | Display type | Truth label | Refresh/stale rule | Parser/read dependency | Display allowed | Notes |
|---|---|---|---|---|---|---|---|---|
| `AI\ai_current_plan.json` | MT5 Runtime Layer / Configuration Layer | `DASH-002`, `DASH-006`, `DASH-005`, `DASH-001` | Cached/derived/compatibility-parsed plan view. | `COMPATIBILITY_PARSED`, `PARSER_WARNING`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `HUMAN_REVIEW_REQUIRED` | No stale runtime-truth use; invalidate on parse/coherence/hash/mtime issues. | Stable-read required; compatibility parser policy pending `DEC-JSON-001`; authority pending `DEC-AUTH-001`. | Yes, only if parser/read/security rules allow; never as stale runtime truth. | No editing, save, normalization, or silent fallback. |
| `AI\ai_previous_plan_backup.json` | Report/Memory / Configuration backup | `DASH-002`, `DASH-006`, `DASH-009` | Historical/reference view. | `COMPATIBILITY_PARSED`, `PARSER_WARNING`, `DERIVED_VIEW`, `STALE_CACHED_VIEW` | Not runtime truth; freshness informational. | Stable-read + compatibility parser dependency. | Yes, with warning. | Historical only. |
| `AI\ai_evolution_state.json` | State/Status / Report/Memory | `DASH-010`, `DASH-006`, `DASH-009` | Evolution-state summary. | `COMPATIBILITY_PARSED`, `PARSER_WARNING`, `DERIVED_VIEW`, `STALE_CACHED_VIEW` | Conditional only; no runtime authority. | Stable-read + compatibility parser dependency. | Yes, with warnings. | Invalid strict JSON currently blocks strict-only parser assumptions. |
| `AI\ai_runtime_secrets.json` | Configuration / Secret-bearing | `DASH-013`, `DASH-005` | Policy/denylist status only. | `FORBIDDEN_SECRET`, `HUMAN_REVIEW_REQUIRED` | No cache; no read by default. | No value read; no parser requirement unless human-approved later. | Redacted/policy status only; no values. | Secret values forbidden from plan/report/dashboard. |
| `AI\runtime_governance_status.*` | MT5 Runtime / State/Status | `DASH-003`, `DASH-001`, `DASH-005` | Status/freshness view. | `AUTHORITATIVE_FILE_TRUTH`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED` | Stale 600s; expired 1800s unless human changes. | Stable-read required; parser mode per file format. | Yes. | Expired/invalid blocks readiness display. |
| `AI\execution_authority_status.*` | MT5 Runtime / State/Status | `DASH-003`, `DASH-001`, `DASH-005` | Authority/freshness view. | `AUTHORITATIVE_FILE_TRUTH`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED` | Stale 600s; expired 1800s unless human changes. | Stable-read required. | Yes. | Dashboard cannot override. |
| `AI\active_operating_cohort.*` | MT5 Runtime / State/Status | `DASH-004`, `DASH-001`, `DASH-005` | Cohort/freshness view. | `AUTHORITATIVE_FILE_TRUTH`, `CACHED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED` | Stale 600s; expired 1800s unless human changes. | Stable-read required. | Yes. | Dashboard cannot select cohort. |
| `AI\ai_performance_journal.jsonl` | Report/Memory / Generated | `DASH-009`, `DASH-006` | Derived analytics/journal summary. | `DERIVED_VIEW`, `PARSER_WARNING`, `STALE_CACHED_VIEW` | Derived only; invalid lines warn/skip. | `jsonl-warn-skip`; stable-read recommended. | Yes, derived only. | Never runtime truth. |
| `AI\council_feedback.json` | Report/Memory / Feedback | `DASH-009`, `DASH-006` | Feedback summary. | `DERIVED_VIEW`, `CACHED_VIEW`, `PARSER_WARNING` | Read-only; freshness informational unless later classified. | Strict JSON allowed if valid; stable-read recommended. | Yes. | Not runtime authority. |
| ATAS exporter outputs | Adapter Layer / Generated | `DASH-008`, `DASH-001`, `DASH-005`, `DASH-007` | Adapter output status/context. | `CACHED_VIEW`, `DERIVED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED` | Stale 30s; expired 120s. | Stable-read required; watcher/polling only as hints. | Yes, if stable; label stale/expired. | Adapter output is not MT5 truth. |
| ATAS intake/advisory/status outputs | Adapter Layer / Generated | `DASH-008`, `DASH-001`, `DASH-005`, `DASH-007` | Advisory/status view. | `CACHED_VIEW`, `DERIVED_VIEW`, `STALE_CACHED_VIEW`, `EXPIRED_UNAVAILABLE`, `PARTIAL_WRITE_SUSPECTED` | Stale 45s; expired 180s. | Stable-read required. | Yes, if stable; label stale/expired. | Trading-adjacent use blocked if stale/expired. |
| dashboard-generated outputs | Dashboard/Generated | `DASH-005`, `DASH-012`, `DASH-015` | Generated visibility data. | `DERIVED_VIEW`, `CACHED_VIEW`, `UNKNOWN_UNCLASSIFIED` | Visibility only. | Must not become source. | Yes, as generated. | Never runtime truth. |
| lock/stop sentinel files | MT5 Runtime / State/Status | `DASH-001`, `DASH-005`, `DASH-007` | Live existence state only. | `AUTHORITATIVE_FILE_TRUTH`, `PARTIAL_WRITE_SUSPECTED`, `EXPIRED_UNAVAILABLE` | Live existence check; do not cache as truth. | Existence-live-check; stable enough for existence semantics only. | Yes, as live/existence state. | No stale cached truth. |
| logs | Generated/Volatile / Report | `DASH-009`, `DASH-012` | Tail/summary. | `DERIVED_VIEW`, `STALE_CACHED_VIEW`, `PARSER_WARNING` | Report-only; freshness informational. | Stable-read/log-tail-derived. | Yes, derived only. | May contain sensitive context; no secrets. |
| reports/docs/memory files | Archive/Documentation / Report/Memory | `DASH-009`, `DASH-011`, `DASH-015` | Reference/progress summaries. | `DERIVED_VIEW`, `CACHED_VIEW`, `NOT_APPLICABLE` | Read-only memory/report cache if approved. | Markdown/text read-only. | Yes. | Not runtime truth. |
| missing/unknown surfaces | Unknown / Generated / Needs decision | `DASH-014`, `DASH-001`, `DASH-011` | Missing/unclassified status. | `UNKNOWN_UNCLASSIFIED`, `HUMAN_REVIEW_REQUIRED`, `EXPIRED_UNAVAILABLE` | Unavailable until classified. | No parser/cache until classified. | Status only. | Blocks implementation if dependency critical. |

### 6. Readiness Signal Model

Readiness is a future display model only. Dashboard readiness must not control MT5 trading unless a later explicit approval changes that boundary.

| Readiness state | Triggering conditions | Dashboard display | Operator meaning | Required warning | Trading-adjacent EXE action allowed | Recovery requirement |
|---|---|---|---|---|---|---|
| `READY_TO_OBSERVE` | Critical display sources are stable, fresh, non-secret, and parser/read diagnostics are acceptable for visibility. | Green/OK observation state. | Observation view appears healthy. | `OBSERVATION READY — NOT TRADING AUTHORITY` | No by default; implementation not approved. | Continue monitoring; no writes. |
| `DEGRADED_OBSERVATION` | Non-critical stale/missing/parser-warning sources; critical runtime source still visible/fresh enough for display. | Warning/degraded. | Dashboard can still provide partial visibility. | `DEGRADED — CHECK WARNINGS` | No. | Resolve stale/missing/warning sources. |
| `NOT_READY_STALE_CRITICAL` | Governance/authority/cohort or active plan display dependency is stale past critical threshold. | Critical/not-ready. | Critical observation is stale. | `CRITICAL STALE DATA — NOT CURRENT TRUTH` | No. | Refresh from stable source; verify freshness. |
| `NOT_READY_PARSE_FAILURE` | Required display source cannot be parsed or strict/compat interpretation conflicts. | Critical/not-ready. | Parser cannot safely interpret source. | `PARSE FAILURE — HUMAN REVIEW REQUIRED` | No. | Human review and parser policy decision. |
| `NOT_READY_PARTIAL_WRITE` | Stable-read checks suspect partial write for critical source. | Critical/not-ready. | Source was likely read during write. | `PARTIAL WRITE SUSPECTED` | No. | Retry stable read after writer settles. |
| `NOT_READY_SECRET_FORBIDDEN` | Secret source access attempted or secret data requested for display/cache. | Blocked/secret. | Access is forbidden by policy. | `SECRET FORBIDDEN — VALUES HIDDEN` | No. | Stop secret access; review policy. |
| `NOT_READY_UNKNOWN_AUTHORITY` | Source authority, ownership, or writer relationship is unresolved for a critical path. | Unknown/blocked. | Dashboard cannot safely label source. | `UNKNOWN AUTHORITY — HUMAN REVIEW REQUIRED` | No. | Resolve authority decision. |
| `BLOCKED_PENDING_HUMAN_DECISION` | Required `DEC-*` decision remains pending for prototype/implementation. | Blocked. | Implementation gate is not cleared. | `PENDING HUMAN DECISION` | No. | Human sign-off. |
| `NOT_APPLICABLE_DESIGN_ONLY` | Design stage only; no runtime dashboard exists. | Design-only badge. | This is a specification, not a running dashboard. | `DESIGN ONLY — NO IMPLEMENTATION` | No. | Explicit future approval required. |

### 7. Warning and Badge Rules

| Condition | Badge level | Required behavior |
|---|---|---|
| Source fresh/stable and display-approved | `OK` | Show label, source, owner, and freshness. |
| Informational/derived source | `INFO` | Show derivation and non-authority notice. |
| Stale data | `WARNING` | Show age, stale threshold, and "not current truth." |
| Expired data | `CRITICAL` | Hide or clearly mark value unavailable/expired; block readiness. |
| Parser warning | `WARNING` | Show parser diagnostics; do not hide warning. |
| Parser failure | `CRITICAL` | Do not display parsed value as truth. |
| Compatibility parsed data | `WARNING` | Label as compatibility parsed and view-only. |
| Partial write suspected | `CRITICAL` | Mark unavailable or stale; do not update current view from unstable read. |
| Missing file | `WARNING` or `CRITICAL` | Severity depends on criticality; show missing source path/class. |
| Unknown authority | `UNKNOWN` | Mark human review required. |
| Multiple writers | `WARNING` or `CRITICAL` | Show conflict/desync risk and required authority decision. |
| Secret file present | `SECRET_FORBIDDEN` | Display policy/denylist status only; no values. |
| Secret access attempted | `BLOCKED` / `SECRET_FORBIDDEN` | Show critical policy violation; no values. |
| Dashboard-only data used as truth | `BLOCKED` | Flag forbidden interpretation. |
| Unresolved human decision | `BLOCKED` | Link/list decision ID; do not infer approval. |
| Stage 2 implementation blocked | `DESIGN_ONLY` / `BLOCKED` | Show implementation is not approved. |

### 8. Active Plan Display Contract

For `AI\ai_current_plan.json`, Dashboard V1 must:

- Show source path: `AI\ai_current_plan.json`.
- Show source owner as MT5/file truth pending human decisions.
- Show unresolved dependency on `DEC-JSON-001` and `DEC-AUTH-001` while pending.
- Show parser mode and parser status.
- Show strict JSON validity and compatibility parser status when available.
- Show source `mtime`, size, checksum/hash, and stable-read status when available.
- Show freshness state and invalidation reason when available.
- Show truth label for every displayed value.
- Display plan content only if parser/read/security rules allow it.
- Label compatibility-parsed content as `COMPATIBILITY_PARSED` and view-only.
- Label stale cached content as `STALE_CACHED_VIEW` and not runtime truth.
- Never present compatibility-parsed or stale plan data as current runtime truth.
- Never silently fall back to last-known-good.
- Never auto-normalize, rewrite, save, or repair the plan.
- Provide no editing in Dashboard V1.
- Provide no "approve plan" or "activate plan" action in Dashboard V1.
- Provide no EXE-side write path for the active plan in V1.

### 9. Governance / Authority Display Contract

For `AI\runtime_governance_status.*`, `AI\execution_authority_status.*`, and `AI\active_operating_cohort.*`, Dashboard V1 must:

- Show owner/source class as MT5-owned/generated unless later human decision changes that classification.
- Show source path/class and file format where known.
- Show last stable read time if available.
- Show freshness age.
- Show warning if stale age exceeds `600s`, unless human-approved threshold changes.
- Show expired/unavailable if age exceeds `1800s`, unless human-approved threshold changes.
- Show parser/read warnings, partial-write suspicion, and missing/unavailable state.
- Mark readiness degraded/not-ready when expired, invalid, or partial-write suspected.
- Never override governance/authority/cohort.
- Never generate replacement authority values.
- Never write status files.
- Never treat dashboard-generated values as governance/authority truth.

### 10. Cache / Sync Diagnostics Display Contract

For future cache entries, Dashboard V1 should display only diagnostic metadata and labels:

- Source path/class.
- Cache eligibility.
- Access mode.
- Authority owner.
- Last loaded time.
- Last refreshed time.
- Source `mtime`, size, and checksum/hash.
- Stable-read result.
- Parser mode and parser result.
- Freshness state.
- Stale/expired thresholds.
- Invalidation reason.
- Last error/warning.
- Truth label.
- Secret classification.
- Human decision dependencies.
- Whether data is MT5-owned, adapter-owned, generated, dashboard-generated, cached, derived, or unknown.

Cache/sync display must not imply that the cache can override source files.

### 11. Security / Secret Display Contract

For `AI\ai_runtime_secrets.json` and any secret-bearing files:

- Do not display secret values.
- Do not log secret values.
- Do not cache secret values.
- Do not read secret values by default.
- Dashboard may display only:
  - secret file/class is denylisted;
  - secret access is forbidden;
  - policy status;
  - redacted metadata only if later approved.
- Any attempted secret access must display `CRITICAL` / `BLOCKED` / `SECRET_FORBIDDEN`.
- Secret display remains blocked unless `DEC-SECRET-001`, `DEC-SECRET-002`, and `DEC-SECRET-003` are explicitly resolved.
- No secret values may be written into the migration plan, reports, logs, dashboard, or diagnostics.

### 12. Operator / Developer Actions Boundary

Allowed V1 actions, subject to later implementation approval:

- Request refresh of the view; design-only/spec at this stage.
- Open/view migration plan reference.
- View diagnostics.
- View warnings and blockers.
- View redacted status/policy metadata.
- Export redacted diagnostic summary only if later approved.

Forbidden V1 actions:

- Edit active plan.
- Write JSON/state/status/log files.
- Normalize JSON.
- Auto-fix parser warnings.
- Clear warnings by writing files.
- Override governance, execution authority, or active cohort.
- Edit secrets.
- Read/cache/display secret values.
- Start/stop trading.
- Trigger MT5 actions.
- Modify adapter outputs.
- Modify dashboard output files as runtime truth.
- Delete, rename, move, or regenerate runtime files.
- Treat stale/expired/partial/unknown/cache data as current truth.

All future write-capable actions require separate approval, confirmation prompts, audit logging, backups, rollback instructions, and validation.

### 13. Dashboard Failure Behavior Matrix

| Failure/condition | Label | Badge level | Panel behavior | Operator message | Forbidden interpretation | Required follow-up |
|---|---|---|---|---|---|---|
| Source missing | `EXPIRED_UNAVAILABLE` or `UNKNOWN_UNCLASSIFIED` | `WARNING` / `CRITICAL` | Show missing status; hide current value if critical. | Source unavailable. | Missing means safe/default. | Classify source and restore/confirm if required. |
| Source stale | `STALE_CACHED_VIEW` | `WARNING` | Show stale age and threshold. | Value may be outdated. | Stale value is current truth. | Refresh from stable source. |
| Source expired | `EXPIRED_UNAVAILABLE` | `CRITICAL` | Mark panel unavailable/not-ready. | Current value unavailable. | Last-known value is current. | Restore fresh stable source. |
| Parser warning | `PARSER_WARNING` | `WARNING` | Show value only with parser warning if safe. | Parser found compatibility/non-fatal issue. | Warning can be ignored. | Review diagnostics and parser policy. |
| Parser failure | `EXPIRED_UNAVAILABLE` / `HUMAN_REVIEW_REQUIRED` | `CRITICAL` | Do not display parsed value as truth. | Parser cannot safely interpret source. | Raw content is trusted. | Human review; fix policy/source in separate task. |
| Compatibility parse only | `COMPATIBILITY_PARSED` | `WARNING` | Display view-only if allowed. | Parsed with compatibility behavior. | Equivalent to strict authority. | Resolve `DEC-JSON-001` if needed. |
| Partial write suspected | `PARTIAL_WRITE_SUSPECTED` | `CRITICAL` | Do not update current value; show stale/unavailable. | File may be mid-write. | Partial read is valid. | Retry stable read after writer settles. |
| Checksum changed | `CACHED_VIEW` / `STALE_CACHED_VIEW` | `INFO` / `WARNING` | Invalidate previous cache and require stable re-read. | Source changed. | Previous cache remains current. | Stable read and parse diagnostics. |
| Unknown authority | `UNKNOWN_UNCLASSIFIED` | `UNKNOWN` | Show blocker. | Authority unknown. | Safe to assume MT5/EXE owner. | Human authority decision. |
| Multiple writers | `HUMAN_REVIEW_REQUIRED` | `WARNING` / `CRITICAL` | Show desync risk. | Multiple writers may conflict. | Last writer wins safely. | Resolve ownership/locking policy. |
| Secret source | `FORBIDDEN_SECRET` | `SECRET_FORBIDDEN` | Display policy status only. | Secret values hidden. | Dashboard can inspect values. | Resolve secret policy if needed. |
| Dashboard-generated value | `DERIVED_VIEW` | `INFO` | Mark generated/visibility-only. | Informational only. | Runtime truth. | Keep non-authoritative. |
| Cache unavailable | `EXPIRED_UNAVAILABLE` | `WARNING` / `CRITICAL` | Show unavailable/stale state. | Cache is not current. | Source is also unavailable by implication. | Attempt stable source read in future implementation. |
| Stage 2 implementation blocked | `HUMAN_REVIEW_REQUIRED` / `NOT_APPLICABLE` | `BLOCKED` / `DESIGN_ONLY` | Show gate status. | Implementation not approved. | Prototype is approved. | Resolve human gates. |
| Pending human decision | `HUMAN_REVIEW_REQUIRED` | `BLOCKED` | Show decision ID and area. | Human sign-off required. | Approval can be inferred. | Complete sign-off template. |

### 14. Wireframe Text Layout

Text-only wireframe; no UI code or implementation.

```text
[System Overview / Readiness]
- Readiness:
- Dashboard mode: visibility-only / design-only
- Critical blockers:
- Pending human decisions:
- Latest stable read:
- Highest severity badge:
- Trading authority: none

[Active Plan]
- Source: AI\ai_current_plan.json
- Owner: MT5/file truth pending DEC-AUTH-001
- Parser: compatibility-json-readonly pending DEC-JSON-001
- Truth label:
- Freshness:
- mtime / size / checksum:
- Warnings:
- Editable: no
- Runtime truth from dashboard/RAM: no

[Governance and Execution Authority]
- Sources: runtime_governance_status.*, execution_authority_status.*
- Owner:
- Last stable read:
- Stale threshold: 600s
- Expiry threshold: 1800s
- Truth labels:
- Warnings:
- Override allowed: no

[Active Operating Cohort]
- Source: active_operating_cohort.*
- Owner:
- Last stable read:
- Freshness:
- Truth label:
- Cohort edit allowed: no

[RAM Cache / File Sync Status]
- Cache mode: design-only
- Entries observed:
- Entries stale:
- Entries expired:
- Entries forbidden:
- Last invalidation reason:
- Cache authority: none

[Parser and Compatibility Warnings]
- Strict-valid sources:
- Compatibility-parsed sources:
- Parser warnings:
- Parser failures:
- Human review required:
- JSON normalization allowed: no

[Read Stability / Partial Write Diagnostics]
- Partial-write suspected:
- Metadata stable:
- Retry count:
- Last stable read:
- Last failure:
- Watcher mode: not implemented

[ATAS Adapter Status]
- Exporter source/status:
- Intake/advisory source/status:
- Stale/expired state:
- Truth label:
- Adapter write allowed: no

[Recent Logs / Journal Summary]
- Journal source:
- Invalid JSONL lines:
- Derived summary:
- Last read:
- Truth label:
- Runtime authority: no

[AI Control / Capability Status]
- EXE writes allowed: no
- Dashboard writes allowed: no
- Developer tool writes allowed: no
- Trading actions allowed: no
- Blockers:

[Risks and Open Human Decisions]
- DEC-JSON-*:
- DEC-AUTH-*:
- DEC-WRITE-*:
- DEC-SECRET-*:
- DEC-MISS-*:
- DEC-CONC-001:
- DEC-PATH-001:

[Developer Diagnostics View]
- Source map:
- Parser diagnostics:
- Read diagnostics:
- Cache diagnostics:
- Redaction applied:
- Export allowed: redacted only if approved

[Secret / Security Status]
- Secret file/class: AI\ai_runtime_secrets.json
- Policy: forbidden-secret
- Values displayed: no
- Values cached: no
- Values logged: no
- Attempted access:
- Required decision: DEC-SECRET-001/002/003

[Missing Runtime Surfaces]
- Missing council surfaces:
- Missing live-exit/lifecycle surfaces:
- Generated missing surfaces:
- Unknown surfaces:
- Human review required:

[Migration Progress]
- Stage 0: Complete
- Stage 1: Complete
- Stage 1.5: Complete
- Stage 1.6: Complete
- Stage 2A: Complete
- Stage 2B: Complete
- Stage 2C: Complete
- Stage 2D: Complete after this section
- Stage 2 prototype/implementation: Blocked
```

### 15. Future Validation Test Strategy

Design tests only; do not create test files or code in this stage.

Future validation cases:

- Stale status renders warning and does not appear as current truth.
- Expired status renders blocked/not-ready.
- Compatibility-parsed active plan displays a warning/badge.
- Parser failure does not display active plan as truth.
- Partial-write suspected shows unavailable/stale and does not update current value.
- Secret file status does not display secret values.
- Dashboard-generated output never appears as authority.
- Missing runtime surface shows `HUMAN_REVIEW_REQUIRED`.
- Unresolved human decision appears as blocker.
- Last-known-good appears stale/expired, not current.
- Cache diagnostics match Stage 2A rules.
- Parser labels match Stage 2B rules.
- Read stability labels match Stage 2C rules.
- Governance/authority/cohort expired state blocks readiness display.
- Active plan view shows `DEC-JSON-001` and `DEC-AUTH-001` while unresolved.
- Secret access attempt maps to `SECRET_FORBIDDEN` / `BLOCKED`.
- Dashboard never offers edit/save/normalize/write controls in V1.

### 16. Stage 2E Entry Criteria

Before any cache registry skeleton proposal, UI prototype, or implementation:

- Stage 2D dashboard spec reviewed.
- Truth label taxonomy approved.
- Dashboard panel map approved.
- Source-to-panel mapping approved.
- Operator/developer action boundary approved.
- Secret display contract approved.
- Readiness model approved.
- Dashboard failure behavior matrix approved.
- `DEC-JSON-001` remains pending for design-only or is explicitly approved.
- `DEC-AUTH-001` remains pending for design-only or is explicitly approved.
- `DEC-SECRET-001`, `DEC-SECRET-002`, and `DEC-SECRET-003` remain no-read/no-cache/no-display unless explicitly approved.
- `DEC-CONC-001` and `DEC-PATH-001` reviewed for dashboard design implications.
- Cache allowlist/denylist remains consistent with Stage 2A.
- Parser behavior remains consistent with Stage 2B.
- Stable-read behavior remains consistent with Stage 2C.
- No implementation is approved unless all human gates are explicitly cleared.
- Stage 2 prototype/implementation remains **blocked** until explicit human approval.

### 17. Codex Task Backlog Update

| Task ID | Task | Boundary |
|---|---|---|
| `STAGE-2E-CACHE-REGISTRY-SKELETON-PROPOSAL` | Cache registry skeleton proposal | Proposal only after human gates; no implementation unless separately approved. |
| `DASHBOARD-UI-PROTOTYPE` | Dashboard UI prototype | Not approved; requires explicit human approval and truth-label spec acceptance. |
| `DASHBOARD-TRUTH-LABEL-VALIDATION-PLAN` | Dashboard truth-label validation test plan | Test plan only; no tests/code/files created in migration workspace. |
| `DEVELOPER-TOOL-BOUNDARY-SPEC` | Developer tool action boundary spec | Design-only; no runtime/config/state writes. |
| `SECRET-REDACTION-ACCESS-POLICY-SPEC` | Secret redaction/access policy spec | Policy-only; no secret reads or values. |
| `HUMAN-DECISION-RESOLUTION` | Resolve pending `DEC-*` items | Human sign-off task; no inferred approval. |
| `INTEGRATION-HANDOFF-PACKAGE` | Package approved design decisions for later implementation | Documentation-only unless implementation gates clear. |

### 18. Stage 2D Completion Criteria

- Design scope and non-goals recorded: **complete**.
- Dashboard V1 doctrine recorded: **complete**.
- Truth label taxonomy recorded: **complete**.
- Dashboard panel map recorded: **complete**.
- Source-to-panel mapping recorded: **complete**.
- Readiness signal model recorded: **complete**.
- Warning and badge rules recorded: **complete**.
- Active plan display contract recorded: **complete**.
- Governance/authority display contract recorded: **complete**.
- Cache/sync diagnostics display contract recorded: **complete**.
- Security/secret display contract recorded without secret values: **complete**.
- Operator/developer action boundary recorded: **complete**.
- Dashboard failure behavior matrix recorded: **complete**.
- Text-only wireframe recorded without UI code: **complete**.
- Future validation test strategy recorded without creating tests/code: **complete**.
- Stage 2E entry criteria recorded: **complete**.
- Stage 2 prototype/implementation remains blocked: **complete**.
- `AI\ai_current_plan.json` is not approved as stale runtime truth from dashboard/RAM: **complete**.
- Secrets remain forbidden from read/cache/display by default: **complete**.

## Stage 2R — Review, Human Gate Decisions, and Claude Integration Handoff

### 1. Completed Stage Summary

| Stage | Status | Output produced | Implementation created | Runtime files modified | Remaining blockers |
|---|---:|---|---:|---:|---|
| Stage 0 Discovery | Complete | Project inventory, architecture summary, layer classification, initial risks, missing/unknowns. | No | No | Human confirmation of live runtime environment remained open. |
| Stage 1 Data Contract | Complete | Runtime file path map, reader/writer authority map, schema/key expectations, strict JSON compatibility audit, missing runtime surfaces. | No | No | Strict JSON mismatch, writer ownership, missing surfaces, stale-data policy. |
| Stage 1.5 Migration Gates | Complete | JSON policy blockers, authority ownership decisions, freshness thresholds, secret-handling blockers, missing surface classification, Stage 2 readiness decision. | No | No | Prototype/implementation blocked pending human decisions. |
| Stage 1.6 Human Decision Worksheet | Complete | Human approval matrix and gate checklist with decision IDs and recommended safe defaults. | No | No | All unresolved decision rows remain Pending Human Decision unless explicitly resolved later. |
| Stage 2A RAM Cache Registry Design | Complete | Design-only cache registry, denylist, conditional allowlist, parser modes, freshness/invalidation/failure/dashboard/security rules. | No | No | Cache implementation blocked; allowlist/denylist requires human approval. |
| Stage 2B Compatibility Parser Design | Complete | Design-only compatibility parser contract, parser states, invalid escape policy, diagnostics, cache/dashboard interaction rules. | No | No | Parser implementation blocked pending DEC-JSON-001 and related approvals. |
| Stage 2C Read Concurrency Design | Complete | Design-only stable-read, partial-write, retry/backoff, watcher-event, diagnostics, failure behavior, cache/dashboard interaction rules. | No | No | Read implementation blocked pending DEC-CONC-001 and DEC-PATH-001. |
| Stage 2D Dashboard Truth-Labeling Design | Complete | Design-only dashboard doctrine, truth taxonomy, panel map, source mapping, readiness model, badge rules, display contracts, wireframe. | No | No | Dashboard implementation blocked; action boundary and truth-label model require human approval. |

### 2. Current Authority Statement

- MT5 remains the runtime execution authority.
- Existing source/runtime files remain file truth unless a later explicitly approved task changes authority.
- `AI\MT5_EXE_MIGRATION_PLAN.md` is migration control documentation only.
- EXE is not implemented.
- RAM cache is not implemented.
- Dashboard is not implemented.
- Developer tool is not implemented.
- No trading authority has moved from MT5.
- No runtime/config/state writes are approved.
- No JSON normalization is approved.
- No parser, watcher, cache, dashboard, EXE, adapter-supervisor, developer-tool, validator, test, or file-locking implementation is approved by this stage.
- Claude/VS Code repository is the source-of-truth development repo.
- Codex archive is a patch/design source only.

### 3. Pending Human Decisions Register

| Decision ID | Area | Recommended safe default | Current status | Blocks implementation | Blocks design-only work | Required human answer | Notes |
|---|---|---|---|---:|---:|---|---|
| DEC-JSON-001 | JSON parser policy | Design compatibility parser first; no source normalization. | Pending Human Decision | Yes | No | Choose compatibility parser, normalization, shadow copy, dual parser, or reject-invalid policy. | Required before parser/RAM prototype. |
| DEC-JSON-002 | Runtime JSON normalization | Do not normalize runtime-critical JSON yet. | Pending Human Decision | Yes | No | Approve or reject any future source JSON normalization task. | Any normalization must be separate, backed up, tested, and reversible. |
| DEC-JSON-003 | Strict shadow copies | Do not generate strict shadow copies yet. | Pending Human Decision | Yes | No | Decide whether EXE may consume generated strict shadow copies. | Shadow copies could desync from source truth if unmanaged. |
| DEC-AUTH-001 | `ai_current_plan.json` runtime truth | Treat `ai_current_plan.json` as MT5/file runtime truth. | Pending Human Decision | Yes | No | Confirm the single runtime authority owner. | RAM/dashboard must not become authority. |
| DEC-AUTH-002 | Human semantic-edit process | Human semantic edits require approved manual process. | Pending Human Decision | Yes | No | Define who may edit the active plan and by what process. | Prevents hidden multiple-writer conflicts. |
| DEC-AUTH-003 | Governance/status/cohort authority | Treat governance/status/cohort as MT5-owned/generated unless proven otherwise. | Pending Human Decision | Yes | No | Confirm owning writer(s) and authority source. | Stale/expired state must not be hidden. |
| DEC-WRITE-001 | EXE V1 writes | EXE V1 performs no runtime/config/state writes. | Pending Human Decision | Yes | No | Approve no-write V1 or define specific exceptions. | Recommended default is no writes. |
| DEC-WRITE-002 | Dashboard V1 writes | Dashboard V1 performs no runtime/config/state writes. | Pending Human Decision | Yes | No | Approve visibility-only dashboard or define specific exceptions. | Recommended default is visibility-only. |
| DEC-WRITE-003 | Developer Tool V1 writes | Developer Tool V1 performs no runtime/config/state writes. | Pending Human Decision | Yes | No | Approve no-write developer tool or define guarded exceptions. | Future writes require confirmation, backup, logging, and rollback. |
| DEC-SECRET-001 | EXE secret reads | No EXE read of `ai_runtime_secrets.json` values by default. | Pending Human Decision | Yes | No | Decide whether EXE may ever read secrets and under what boundary. | Secret values must not be copied into reports/logs. |
| DEC-SECRET-002 | Secret caching | No secret cache. | Pending Human Decision | Yes | No | Decide whether any secret metadata/value cache is allowed. | Recommended default remains no cache. |
| DEC-SECRET-003 | Dashboard secret metadata | No secret display except denylist/policy status by default. | Pending Human Decision | Yes | No | Decide whether redacted metadata display is allowed. | Secret values remain forbidden. |
| DEC-MISS-001 | Missing council surfaces | Stage 2 must not depend on unresolved missing council surfaces. | Pending Human Decision | Yes | No | Classify as required/fatal, optional, generated, legacy, or unknown. | Required for implementation dependencies. |
| DEC-MISS-002 | Missing live-exit/lifecycle surfaces | Stage 2 must not depend on unresolved lifecycle surfaces. | Pending Human Decision | Yes | No | Classify missing lifecycle/live-exit references. | Prevents false readiness. |
| DEC-MISS-003 | Generated ATAS/status surfaces | Treat generated/missing ATAS/status outputs as unavailable until observed/classified. | Pending Human Decision | Yes | No | Confirm which generated surfaces are expected at runtime. | Freshness rules required before cache use. |
| DEC-FRESH-001 | Governance/authority/cohort freshness | Use 600s stale and 1800s expired unless humans override. | Pending Human Decision | Yes | No | Approve or adjust thresholds. | Expired critical status blocks trading-adjacent EXE action. |
| DEC-FRESH-002 | ATAS freshness | Use 30s stale/120s expired for exporter; 45s stale/180s expired for intake/advisory. | Pending Human Decision | Yes | No | Approve or adjust adapter thresholds. | Applies to future display/cache only. |
| DEC-FRESH-003 | Active plan freshness | No stale `ai_current_plan.json` runtime truth from RAM/dashboard. | Pending Human Decision | Yes | No | Define plan freshness/coherence requirements. | Parser/read stability remains required. |
| DEC-CONC-001 | Read concurrency | Non-invasive stable-read strategy; no locking by default. | Pending Human Decision | Yes | No | Approve stable-read/read-retry policy and locking boundary. | File locking may break MT5 and is not approved. |
| DEC-PATH-001 | Live MT5 path contract | Confirm from live MT5 environment before implementation. | Pending Human Decision | Yes | No | Provide live terminal root, common-data paths, and deployment path contract. | Required before any file reader. |
| DEC-STAGE2-001 | Stage 2 design-only | Stage 2 design-only is approved. | Resolved: Approved for design-only | No | No | No further answer required unless scope changes. | Does not approve prototypes or implementation. |
| DEC-STAGE2-002 | Stage 2 prototype entry | Prototype remains blocked. | Pending Human Decision | Yes | No | Define exact approval criteria for future prototype. | No skeleton/code until gates clear. |

### 4. Stage 2E Decision

- Stage 2E implementation is not approved.
- Stage 2E cache registry skeleton proposal may proceed only as design/proposal if humans explicitly accept continuing design-only work.
- No code skeleton should be generated until human gates are cleared.
- No runtime file reader, parser, watcher, dashboard, EXE, validator, test, locking, or RAM cache code is approved.

Recommended path:

1. Pause design expansion after Stage 2R.
2. Integrate `AI\MT5_EXE_MIGRATION_PLAN.md` into the Claude/VS Code source-of-truth repo first.
3. Resolve human decisions in the Claude/VS Code repo.
4. Create a fresh ZIP from the Claude/VS Code repo before any future Codex implementation task.
5. Proceed only with either another explicitly bounded design-only task or a prototype task after all required human gates are approved.

### 5. Claude/VS Code Integration Handoff

| File/path | Action | Merge into Claude repo | Reason | Notes |
|---|---|---:|---|---|
| `AI\MT5_EXE_MIGRATION_PLAN.md` | Copy from Codex archive into Claude/VS Code repo. | Yes | This is the consolidated migration control document through Stage 2D plus Stage 2R handoff. | Default and only recommended merge candidate. |
| `AI\MT5_EXE_MIGRATION_PLAN.md.bak_*` | Do not copy into production path by default. | No | Backups are Codex-stage recovery artifacts, not source/runtime files. | Archive externally or under a deliberate `migration_backups` location only if desired. |
| `AI\*.mq5` | Do not merge from Codex archive. | No | No approved trading/source changes were made. | Claude repo remains source truth. |
| `AI\*.mqh` | Do not merge from Codex archive. | No | No approved include/trading/helper changes were made. | Avoid overwriting source truth. |
| `AI\*.ex5` | Do not merge from Codex archive. | No | Binary/runtime artifact not modified or approved for merge. | Rebuild only through approved build process. |
| `AI\*.json`, `AI\*.jsonl`, `AI\*.txt`, `AI\*.csv`, `AI\*.ini`, `AI\*.log` runtime/config/state files | Do not merge from Codex archive. | No | No runtime/config/state/log changes are approved. | Prevent accidental runtime state rollback or desync. |
| `AI\external_dashboard\tools\*` | Do not merge from Codex archive. | No | Dashboard implementation is not approved. | Existing Claude repo files remain authoritative. |
| `AI\external_adapter\atas_semantic_adapter\*` | Do not merge from Codex archive. | No | Adapter changes are not approved. | Adapter outputs/config remain external/source-controlled separately. |
| scripts/build files | Do not merge from Codex archive. | No | No scripts/build changes are approved. | Avoid accidental toolchain changes. |
| binaries, venv, cache, obj, bin, dll, exe, pdb, pyc | Do not merge from Codex archive. | No | Generated/runtime/binary artifacts are not approved merge content. | Keep out of source-truth merge by default. |

### 6. Safe Merge Procedure for Claude Repo

1. In the Claude/VS Code repository, commit or back up the current state before merging.
2. Extract the Codex archive to a temporary location outside the production/runtime tree.
3. Copy only `AI\MT5_EXE_MIGRATION_PLAN.md` from the Codex archive into the Claude/VS Code repo.
4. Do not copy the full `AI` folder.
5. Do not overwrite `.mq5`, `.mqh`, `.ex5`, JSON, JSONL, TXT, CSV, INI, LOG, dashboard, adapter, script, build, binary, venv, cache, obj, bin, dll, exe, pdb, or pyc files.
6. Do not copy backup files unless intentionally archived outside the production path.
7. Review `git diff`.
8. Confirm only `AI\MT5_EXE_MIGRATION_PLAN.md` changed.
9. Commit with a message such as: `Add MT5 EXE migration plan through Stage 2D design`.
10. After merge, Claude continues from the Claude/VS Code source-of-truth repo, not from the Codex archive.

### 7. Post-Merge Claude Instructions

```text
Treat AI\MT5_EXE_MIGRATION_PLAN.md as the MT5-to-EXE migration control document.

Do not implement Stage 2 prototype work until human gates are resolved.
Preserve MT5 behavior.
Do not modify .mq5/.mqh trading logic without explicit task approval.
Do not normalize runtime JSON.
Do not write runtime/config/state/status/log files.
Do not read, cache, display, or log secret values.
Dashboard V1 must remain visibility-only.
EXE/RAM cache must remain non-authoritative.
Stale, expired, partial-read, compatibility-parsed, or dashboard-generated data must never silently become runtime truth.
Any implementation must be performed as bounded tasks with validation, backup, and rollback.
```

### 8. Implementation Blockers

- Runtime-critical JSON is invalid under strict parsers for known files from Stage 1/2B.
- DEC-JSON policy is unresolved.
- `ai_current_plan.json` semantic authority and edit ownership are unresolved.
- EXE/dashboard/developer-tool write boundaries remain unresolved.
- Secret read/cache/display policy remains unresolved.
- Missing runtime surfaces remain unresolved.
- Read concurrency/live path contract remains unresolved.
- No Stage 2 prototype approval exists.
- No live MT5 terminal path contract is confirmed.
- No approved cache allowlist for implementation exists.
- No approved parser implementation exists.
- No approved watcher/file-locking implementation exists.
- No approved dashboard implementation exists.
- No approved rollback/validation plan for code changes exists.

### 9. Next Recommended Actions

1. Merge only `AI\MT5_EXE_MIGRATION_PLAN.md` into the Claude/VS Code source-of-truth repo.
2. Human reviewers complete the pending decision register.
3. Resolve at minimum `DEC-JSON-001`, `DEC-AUTH-001`, `DEC-WRITE-001`, `DEC-SECRET-001`, `DEC-SECRET-002`, `DEC-SECRET-003`, `DEC-CONC-001`, and `DEC-PATH-001`.
4. Classify missing runtime surfaces under `DEC-MISS-001`, `DEC-MISS-002`, and `DEC-MISS-003`.
5. Approve or reject Stage 2E as proposal-only.
6. Create a fresh ZIP from the Claude/VS Code source-of-truth repo.
7. Only then prepare the next Codex task:
   - Stage 2E proposal-only, or
   - Stage 2 gate resolution, or
   - a bounded prototype task only if all gates are approved.

### 10. Validation and Rollback Notes

- This stage is review/handoff only.
- No production runtime files should change.
- Rollback for this Codex archive is restoring `AI\MT5_EXE_MIGRATION_PLAN.md` from `AI\MT5_EXE_MIGRATION_PLAN.md.bak_20260425_153247`.
- Integration rollback in Claude/VS Code repo is reverting the merge commit that introduced the updated migration plan.
- If any file other than `AI\MT5_EXE_MIGRATION_PLAN.md` and its timestamped backup changes in this archive, treat it as unexpected and revert before handoff.

### Stage 2R Completion Checklist

- Completed stage summary recorded: **complete**.
- Current authority statement recorded: **complete**.
- Pending human decisions register recorded: **complete**.
- Recommended safe defaults recorded: **complete**.
- Stage 2E decision recorded as no implementation approval: **complete**.
- Claude/VS Code integration handoff recorded: **complete**.
- Safe merge procedure recorded: **complete**.
- Post-merge Claude instructions recorded: **complete**.
- Implementation blockers recorded: **complete**.
- Next recommended actions recorded: **complete**.
- No implementation code/test/UI/parser/watcher/cache files created: **complete**.
- Stage 2 prototype/implementation remains blocked: **complete**.


## Stage 2R.1 — EXE Role, MT5 Runtime Load Reduction, and Legacy Dashboard Migration Clarifications

### Status

This section is a documentation-only architectural clarification addendum. It does not approve implementation. It does not implement an EXE, RAM loader, dashboard, parser, watcher, bridge, snapshot mechanism, developer tool, or legacy dashboard migration. Stage 2 prototype/implementation remains blocked until the relevant human decisions are resolved and explicitly approved.

### Merge Safety Clarification

Integrating `AI\MT5_EXE_MIGRATION_PLAN.md` only into the Claude/VS Code source-of-truth repository is low risk because this file is documentation and migration-control planning only.

Safe merge rules:

- Copy only `AI\MT5_EXE_MIGRATION_PLAN.md`.
- Do not copy the full Codex archive.
- Do not overwrite the full `AI\` folder.
- Do not merge runtime/config/state/trading files from the Codex archive.
- Do not merge `.mq5`, `.mqh`, `.ex5`, `.json`, `.jsonl`, `.txt`, `.csv`, `.ini`, `.log`, dashboard, adapter, script, build, binary, venv, cache, obj, bin, dll, exe, pdb, or pyc files from the Codex archive by default.
- A backup or git commit before merge is mandatory.
- A git diff after merge must confirm that only the migration plan changed, unless a later explicitly approved task says otherwise.

### Claude Continuation Clarification

The Claude/VS Code project remains the source-of-truth development repository. The Codex archive is a temporary design/patch source only.

After merging this migration plan into the VS Code project, Claude can continue development normally from the source-of-truth repository. Claude must treat `AI\MT5_EXE_MIGRATION_PLAN.md` as the governing migration-control document and must not implement EXE/RAM/dashboard/prototype work until the relevant pending human decisions are resolved.

Claude must continue to preserve MT5 behavior, avoid unapproved `.mq5`/`.mqh` trading-logic changes, avoid JSON normalization, avoid runtime/config/state/status/log writes, avoid secret read/cache/display/logging, keep the dashboard visibility-only, and keep EXE/RAM cache non-authoritative unless a later stage explicitly approves a different boundary.

### EXE Role Clarification

The EXE is not intended to be only a dashboard. The EXE has three intended roles:

1. RAM runtime support / loader.
2. Dashboard / visibility layer.
3. Developer diagnostics and extension foundation.

The dashboard is a consumer of the EXE/RAM layer, not the main purpose by itself.

MT5 remains the trading execution authority. The EXE must not become trading authority without explicit future approval. EXE/RAM cache must not silently replace source-file authority. Loading a file into EXE/RAM does not automatically make the EXE or RAM cache the source of truth.

### Primary EXE Goal: MT5 Runtime Load Reduction

The primary goal of the EXE is not merely to provide a dashboard. The primary goal is to reduce MT5 runtime load wherever safely possible.

The EXE should progressively move repeated reading, parsing, validation, aggregation, diagnostics, dashboard preparation, and non-authoritative analysis into EXE/RAM. Any file that can safely reduce MT5 load should be evaluated for EXE/RAM handling.

RAM handling must follow the cache registry, parser policy, stable-read policy, freshness rules, and authority rules already defined in the migration plan. Source-file/MT5 authority remains unless an explicit future authority transfer is approved.

The EXE must never hide stale data, parse failures, partial writes, authority uncertainty, missing files, unknown ownership, or secret-forbidden states. The EXE must never trade or alter MT5 behavior unless explicitly approved in a future stage.

Performance intention:

- Repeated file access should be reduced.
- Repeated parsing should be reduced.
- Repeated dashboard polling should be removed from production flow.
- Heavy local WebView polling should be migrated to EXE RAM/view-model.
- Derived summaries should be calculated in the EXE where safe.
- Runtime-heavy report/log/status aggregation should be moved to the EXE where safe.
- Frequently used non-secret operational artifacts should be candidates for RAM handling if they pass safety classification.

Important limitation:

A read-only EXE cache helps EXE/dashboard performance immediately, but it reduces MT5 runtime load only when MT5 no longer performs the same repeated heavy reads itself, or when MT5 is later connected to a safe bridge/snapshot/view-file strategy.

Therefore, true MT5 runtime load reduction may require later approved design work such as:

- compact state snapshot,
- EXE-managed read-optimized view files,
- MT5-to-EXE bridge,
- IPC/local service,
- shared memory,
- DLL only if explicitly approved and tested.

These future mechanisms are not approved for implementation yet.

### Legacy Local WebView Dashboard Clarification

The existing local WebView dashboard must not remain as an uncontrolled production polling load after the EXE dashboard becomes active.

The legacy dashboard must not be deleted immediately. First, it must be audited to determine:

- what files it reads,
- what files it writes, if any,
- how often it polls,
- what panels and values it displays,
- what runtime/config/state/log files it touches,
- what operational value should be migrated into the EXE dashboard,
- what load it adds to MT5/runtime files.

Useful legacy dashboard panels should be migrated into an EXE dashboard backed by EXE RAM/cache/view-model. The EXE dashboard should read from the EXE RAM/cache/view-model rather than performing heavy direct polling against runtime files.

The legacy dashboard should be disabled, archived, or retired only after comparison and verification. Legacy dashboard retirement is intended to reduce runtime/dashboard polling load, not merely change UI appearance.

### Developer Window Clarification

No EXE developer window exists yet.

The V1 developer tool should be diagnostics-first. It may show:

- cache registry status,
- parser warnings,
- stale files,
- read stability diagnostics,
- missing surfaces,
- migration decisions,
- redacted diagnostics,
- dashboard truth-label states,
- file classification and safe/unsafe cache status.

V1 must not:

- edit the active plan,
- normalize JSON,
- write runtime/config/state files,
- read/cache/display secrets,
- override governance/authority/cohort,
- trigger MT5 trading actions,
- delete/rename/move production files,
- modify adapter outputs.

Any future write action requires explicit approval, confirmation, logging, backup, validation, and rollback.

### Updated Backlog

The following future tasks are added as pending/design-only backlog items. They are not approved for implementation:

- Stage 2D.5 — Legacy Local WebView Dashboard Migration Assessment.
- Stage 3X — MT5 Runtime Load Reduction Bridge / Snapshot Design.
- Stage 3Y — EXE Developer Diagnostics Window Design.
- Stage 3Z — Production Cutover and Legacy Dashboard Retirement Plan.

### Current Status After Clarification

These clarifications do not approve implementation.

Current blocked items remain:

- Stage 2 prototype/implementation remains blocked.
- Dashboard implementation remains blocked.
- RAM loader implementation remains blocked.
- Parser implementation remains blocked.
- Watcher implementation remains blocked.
- Bridge/snapshot implementation remains blocked.
- Legacy dashboard deletion/removal remains blocked until audited and approved.
- Secret reads/cache/display remain blocked.
- Runtime/config/state/status/log writes remain blocked.
- JSON normalization remains blocked.

The only default merge candidate remains `AI\MT5_EXE_MIGRATION_PLAN.md`.

---

## Stage 2S — EXE/RAM Sidecar V1 (First Prototype)

### Status

**2026-05-10** — Package 1 (Claude planning/spec) complete. Package 2 (Codex implementation) authorized.

This stage implements the first concrete prototype milestone: a bounded, optional, read-only Python sidecar process that caches `MQL5/Files/AI/` outputs in RAM and serves them via a local HTTP API (localhost:17001). It resolves a subset of the pending human decision register without requiring all blockers to clear.

### Scope

See: `DOCS_SYSTEM/01_ARCHITECTURE/MT5_EXE_RAM_SIDECAR_ALIGNMENT_AND_PACKAGE2_EXECUTION_SPEC_V1.md`

That document is the Package 2 Codex execution brief and contains the complete specification including:
- 15 alignment questions answered
- File classification manifest (Category A/B/C/D)
- HTTP API contract
- Task-by-task Codex implementation spec
- Package 3 forensic review checklist

### Pending Decisions Resolved by Stage 2S

| Decision ID | Resolution |
|---|---|
| DEC-WRITE-001 | Sidecar writes only to `EXE_RUNTIME_CACHE/` — never to Files/AI |
| DEC-WRITE-002 | Dashboard remains visibility-only |
| DEC-CONC-001 | Polling + mtime check; no file locking |
| DEC-PATH-001 | Live path confirmed: `...D0E8209F77C8CF37AD8BF550E51FF075/MQL5/Files/AI/` |
| DEC-SECRET-001/002/003 | `ai_runtime_secrets.json` excluded in manifest; never cached or displayed |

### Remaining Blockers (still unresolved, out of scope for Stage 2S)

All DEC-JSON-*, DEC-AUTH-*, DEC-MISS-*, DEC-FRESH-* decisions remain pending. Stage 2S does not require their resolution because the sidecar is read-only, excludes config/plan/secret surfaces, and tolerates missing files gracefully.

### Authority Statement

MT5 remains sole runtime authority. The sidecar is invisible to MT5. MT5's behavior is identical whether the sidecar is running or not. The sidecar has no trading, config, plan, or governance authority.

### Stage 2S Completion Criteria

Package 3 (Claude forensic review) must certify `SIDECAR_V1_CERTIFIED` per the Package 3 checklist in the spec document.


---

## Stage 3 — Primary Objective Correction: MT5 Runtime IO Reduction

**Date:** 2026-05-10
**Status:** PACKAGE1_SPEC_COMPLETE — AWAITING_PACKAGE2_AUTHORIZATION

### Objective Correction

The EXE/RAM Sidecar direction documented in Stage 2S targets read-only observability acceleration for the external dashboard. That work is valid and its Package 2 brief is authorized. However, it does not materially reduce MT5's own runtime file IO burden.

The **primary MT5 load-reduction objective** is now formally:

> **MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1 — MT5-side file IO reduction through RAM-resident state, write buffering, interval gating, and dirty-flag suppression.**

### Corrected Priority Hierarchy

| Tier | Package | Objective | MT5 IO Reduction? |
|---|---|---|---|
| PRIMARY | MT5_IO_REDUCTION_V1 | Reduce FileOpen/Close cycles inside MT5 EA | YES — 60-73% fewer cycles |
| SECONDARY | EXE/RAM Sidecar V1 | Cache Files/AI outputs in RAM for dashboard | NO — dashboard-side only |

### Architecture Document

See: `MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1.md` (at MQL5/Experts/AI/ root)

That document is the Package 2 Codex execution brief for MT5_IO_REDUCTION_V1 and contains:
- Complete source IO inventory (179 FileOpen/Close/Write calls across 23 .mqh files + main_ea.mq5)
- File category classification for all 30+ runtime output files
- Tier 1–4 IO pressure source ranking with quantified daily cost
- 10 architecture options with SAFE_FOR_PACKAGE2 / REJECTED / DEFERRED classifications
- 13-question source-of-truth policy (flush immediacy, crash-loss, recovery-critical vs bufferable)
- MT5_IO_REDUCTION_V1 recommended architecture (5 components, 11 input flags)
- Complete Package 2 Codex execution brief (Steps K1–K11)
- Expected reduction: 60–73% fewer FileOpen/Close cycles per M1 bar; 90% reduction in honesty surface writes; 99% reduction in governance status writes on stable state

### Files to Modify (Package 2 — MT5_IO_REDUCTION_V1)

| File | Change |
|---|---|
| `performance_journal.mqh` | PJ_BUFFER — RAM buffer for DECISION/ATTRIBUTION/SHADOW records; flush on TRADE_OPEN/CLOSE/RISK_BLOCK/TRUTH_NOT_READY |
| `main_ea.mq5` | HONESTY_GATE — interval gate every N bars for 7 static honesty surfaces; GOV_DIRTY — dirty-flag for governance status; TRENDCONT_GATE — interval gate |
| `council_mode_runtime.mqh` | OL_RATE — opportunity ledger summary rate limiter |

All other files: unchanged.

### Feature Flag Safety

All 5 IO-reduction components are independently controlled by EA input flags. Setting all flags to off values (EnablePJBuffer=false, EnableHonestyIntervalGate=false, EnableGovernanceDirtyFlag=false, EnableTrendContGate=false, EnableOLSummaryRateLimit=false) restores exact legacy behavior without recompile.

### Authority Statement

MT5 remains sole runtime authority. The IO reduction architecture does not change trading logic, stop geometry, council pipeline, governance policy, or any runtime authority structure. It only changes when and how often file writes are executed.

### Stage 3 Completion Criteria

Package 3 (Claude forensic review) must certify `MT5_IO_REDUCTION_V1_CERTIFIED` per the Package 3 checklist in `MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1.md`.

```
STAGE_3_ID:               MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_PACKAGE_1_V1
SOURCE_DOCUMENT:          MT5_RUNTIME_RAM_SHARING_ARCHITECTURE_V1.md
PRIMARY_VERDICT:          RAM_SHARING_PACKAGE2_READY
DATE:                     2026-05-10
SIDECAR_STATUS:           SECONDARY — Stage 2S Package 2 authorized; does not reduce MT5 IO
PACKAGE2_STATUS:          AWAITING_OPERATOR_AUTHORIZATION
SOURCE_CHANGED:           NO
COMPILE_RUN:              NO
LIVE_TRADING:             NO
```
