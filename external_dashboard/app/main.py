from __future__ import annotations

from pathlib import Path
from typing import Any

from fastapi import FastAPI, Query, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates

from .aggregator import DashboardAggregator
from .sources import ArtifactStore


APP_ROOT = Path(__file__).resolve().parent.parent
TEMPLATE_DIR = APP_ROOT / "templates"
STATIC_DIR = APP_ROOT / "static"
TERMINAL_ROOT = Path(__file__).resolve().parents[5]
FILES_AI_ROOT = TERMINAL_ROOT / "MQL5" / "Files" / "AI"
ADAPTER_ROOT = FILES_AI_ROOT / "external_adapter" / "atas_semantic_adapter"

app = FastAPI(title="MT5 External Dashboard", version="v1")
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")
templates = Jinja2Templates(directory=str(TEMPLATE_DIR))

store = ArtifactStore(FILES_AI_ROOT, ADAPTER_ROOT)
aggregator = DashboardAggregator(store)


def base_context(active_page: str) -> dict[str, Any]:
    return {
        "active_page": active_page,
        "terminal_root": str(TERMINAL_ROOT),
        "files_ai_root": str(FILES_AI_ROOT),
        "adapter_root": str(ADAPTER_ROOT),
        "read_only_notice": "Read-only dashboard. MT5 remains sole runtime authority.",
    }


@app.get("/health")
def health() -> dict[str, Any]:
    return {
        "status": "ok",
        "service": "external_dashboard",
        "mode": "READ_ONLY_NON_AUTHORITATIVE",
        "files_ai_root": str(FILES_AI_ROOT),
        "adapter_root": str(ADAPTER_ROOT),
    }


@app.get("/")
def overview_page(request: Request):
    payload = aggregator.overview()
    ctx = base_context("overview")
    ctx.update({"request": request, "payload": payload, "title": "System Overview"})
    return templates.TemplateResponse(request=request, name="overview.html", context=ctx)


@app.get("/context")
def context_page(request: Request):
    payload = aggregator.context()
    ctx = base_context("context")
    ctx.update({"request": request, "payload": payload, "title": "Current Market / Runtime Context"})
    return templates.TemplateResponse(request=request, name="context.html", context=ctx)


@app.get("/trades")
def trades_page(request: Request, limit: int = Query(default=10, ge=1, le=200)):
    payload = aggregator.trades(limit=limit)
    ctx = base_context("trades")
    ctx.update({"request": request, "payload": payload, "title": "Last Trades"})
    return templates.TemplateResponse(request=request, name="trades.html", context=ctx)


@app.get("/rejections")
def rejections_page(request: Request, limit: int = Query(default=20, ge=1, le=300)):
    payload = aggregator.rejections(limit=limit)
    ctx = base_context("rejections")
    ctx.update({"request": request, "payload": payload, "title": "Rejections / Non-Entry"})
    return templates.TemplateResponse(request=request, name="rejections.html", context=ctx)


@app.get("/forensics")
def forensics_page(request: Request):
    payload = aggregator.forensics()
    ctx = base_context("forensics")
    ctx.update({"request": request, "payload": payload, "title": "Forensics / Evidence"})
    return templates.TemplateResponse(request=request, name="forensics.html", context=ctx)


@app.get("/levels")
def levels_page(request: Request):
    payload = aggregator.levels()
    ctx = base_context("levels")
    ctx.update({"request": request, "payload": payload, "title": "Levels Comparative"})
    return templates.TemplateResponse(request=request, name="levels.html", context=ctx)


@app.get("/inspect")
def inspect_page(request: Request, q: str = Query(default="", max_length=120)):
    payload = aggregator.inspect(q)
    ctx = base_context("inspect")
    ctx.update({"request": request, "payload": payload, "title": "Search / Inspect"})
    return templates.TemplateResponse(request=request, name="inspect.html", context=ctx)


@app.get("/atas-live")
def atas_live_page(request: Request, limit: int = Query(default=120, ge=10, le=500)):
    payload = aggregator.atas_live_chain(event_limit=limit)
    ctx = base_context("atas_live")
    ctx.update({"request": request, "payload": payload, "title": "ATAS Live Chain Diagnostics"})
    return templates.TemplateResponse(request=request, name="atas_live_chain.html", context=ctx)


@app.get("/api/overview")
def overview_api():
    return JSONResponse(aggregator.overview())


@app.get("/api/context")
def context_api():
    return JSONResponse(aggregator.context())


@app.get("/api/trades")
def trades_api(limit: int = Query(default=10, ge=1, le=200)):
    return JSONResponse(aggregator.trades(limit=limit))


@app.get("/api/rejections")
def rejections_api(limit: int = Query(default=20, ge=1, le=300)):
    return JSONResponse(aggregator.rejections(limit=limit))


@app.get("/api/forensics")
def forensics_api():
    return JSONResponse(aggregator.forensics())


@app.get("/api/levels")
def levels_api():
    return JSONResponse(aggregator.levels())


@app.get("/api/inspect")
def inspect_api(q: str = Query(default="", max_length=120)):
    return JSONResponse(aggregator.inspect(q))


@app.get("/api/atas-live")
def atas_live_api(limit: int = Query(default=120, ge=10, le=500)):
    return JSONResponse(aggregator.atas_live_chain(event_limit=limit))
