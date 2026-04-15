# External Dashboard Architecture v1

## Purpose

Provide a local, read-only, non-authoritative observability unit for the governed MT5 runtime without introducing execution, risk, or governance control paths.

## Runtime posture

- MT5 remains sole runtime authority (decision/execution/risk/governance).
- External dashboard is display/analysis only.
- No write-back to MT5 runtime control surfaces.
- No trade/risk/governor actions exposed.

## Implementation stack

- Backend: Python + FastAPI
- Templates: Jinja2
- Frontend: lightweight static CSS/JS with bounded polling
- Data access: file-based JSON/JSONL readers with mtime cache and missing-file tolerance

## Unit layout

- `external_dashboard/app/main.py`: app bootstrap, HTML and JSON routes, health endpoint
- `external_dashboard/app/sources.py`: bounded artifact readers and UNAVAILABLE markers
- `external_dashboard/app/aggregator.py`: view-model assembly and source precedence logic
- `external_dashboard/templates/*.html`: page templates
- `external_dashboard/static/style.css`: dark-friendly compact UI
- `external_dashboard/static/app.js`: refresh/auto-refresh behavior

## Route set

- HTML: `/`, `/context`, `/trades`, `/rejections`, `/forensics`, `/levels`, `/inspect`
- JSON: `/api/overview`, `/api/context`, `/api/trades`, `/api/rejections`, `/api/forensics`, `/api/levels`, `/api/inspect`
- Health: `/health`

## Data roots

Resolved from unit location:

- `MQL5/Files/AI`
- `MQL5/Files/AI/external_adapter/atas_semantic_adapter`

## Source precedence highlights

### System posture

- `runtime_governance_status.json`
- `execution_authority_status.json`
- `operational_integrity_status.json`
- `ai_activation_readiness_status.json`

### Context/advisory

- `atas_runtime_context_status.json`
- `atas_runtime_context.json`
- `atas_governed_advisory_status.json`
- `diagnostic_runtime_summary.json`
- `ai_decision_envelope_trace.jsonl` (latest)

### Trades

1. `ai_institutional_learning_trade_lineage.jsonl` (primary row identity)
2. `ai_institutional_learning_events.jsonl` (outcome/profit enrichment)
3. `ai_decision_envelope_trace.jsonl` (confidence/policy/learning envelope enrichment)
4. `ai_trade_feedback.json` (fallback)

### Levels comparative

FINAL_RUNTIME_RELIED_ON (green):
1. latest non-zero nearest levels from `ai_decision_envelope_trace.jsonl`
2. linked nearest levels from `ai_trade_feedback.json`

ATAS_REFERENCE (red):
1. `atas_runtime_context.json` `level_candidates`
2. nearest levels from `atas_governed_advisory_status.json`

Confluence marker is set when FINAL/ATAS levels are within a bounded inferred tolerance.

## Safety boundaries

- Missing or optional files are surfaced as explicit `UNAVAILABLE`.
- Locked live journal `ai_performance_journal.jsonl` is intentionally not required.
- Dashboard never mutates runtime authority surfaces.
