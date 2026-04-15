from __future__ import annotations

import argparse
import json
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

SCORE_KEYS = [
    "continuity_score",
    "freshness_score",
    "completeness_score",
    "lineage_continuity_score",
    "source_coverage_score",
    "explainability_score",
]


def utc_now_iso() -> str:
    return datetime.now(UTC).isoformat().replace("+00:00", "Z")


def read_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    parsed = json.loads(path.read_text(encoding="utf-8-sig", errors="replace"))
    return parsed if isinstance(parsed, dict) else {}


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def write_md(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8")


def append_jsonl(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(payload, separators=(",", ":")) + "\n")


def to_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def pick_scores(payload: dict[str, Any], source_name: str) -> dict[str, float]:
    result: dict[str, float] = {}
    for key in SCORE_KEYS:
        result[key] = round(to_float(payload.get(key), 0.0), 4)
    result["source_name"] = source_name  # type: ignore[assignment]
    return result


def score_consistency_report(score_sources: dict[str, dict[str, float]], tolerance: float = 0.0001) -> dict[str, Any]:
    per_score: dict[str, Any] = {}
    mismatches: list[dict[str, Any]] = []
    for key in SCORE_KEYS:
        observed: dict[str, float] = {}
        for source_name, values in score_sources.items():
            if key in values:
                observed[source_name] = round(to_float(values.get(key), 0.0), 4)
        if not observed:
            per_score[key] = {"consistent": False, "reason": "NO_VALUES"}
            mismatches.append({"score": key, "reason": "NO_VALUES"})
            continue
        low = min(observed.values())
        high = max(observed.values())
        consistent = (high - low) <= tolerance
        per_score[key] = {
            "consistent": consistent,
            "low": round(low, 4),
            "high": round(high, 4),
            "spread": round(high - low, 4),
            "values": observed,
        }
        if not consistent:
            mismatches.append({"score": key, "values": observed, "spread": round(high - low, 4)})
    return {
        "consistent": len(mismatches) == 0,
        "tolerance": tolerance,
        "per_score": per_score,
        "mismatches": mismatches,
    }


def lineage_consistency_report(lineage_sources: dict[str, str]) -> dict[str, Any]:
    normalized = {k: str(v or "UNKNOWN") for k, v in lineage_sources.items()}
    unique_states = sorted(set(normalized.values()))
    return {
        "consistent": len(unique_states) == 1,
        "states": normalized,
        "unique_states": unique_states,
    }


def file_snapshot(path: Path, now_utc: datetime) -> dict[str, Any]:
    if not path.exists():
        return {"path": str(path), "exists": False}
    stat = path.stat()
    mtime_utc = datetime.fromtimestamp(stat.st_mtime, UTC)
    age_seconds = round((now_utc - mtime_utc).total_seconds(), 3)
    return {
        "path": str(path),
        "exists": True,
        "mtime_utc": mtime_utc.isoformat().replace("+00:00", "Z"),
        "age_seconds": age_seconds,
        "size_bytes": stat.st_size,
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build weekend-safe pre-live verification pack artifacts.")
    parser.add_argument("--output-dir", required=True, help="Path to MQL5/Files/AI/atas_micro_phase3_candidate")
    parser.add_argument(
        "--market-state",
        choices=["MARKET_CLOSED", "LIVE_WINDOW"],
        default="MARKET_CLOSED",
        help="Current verification window state.",
    )
    args = parser.parse_args()

    now_utc = datetime.now(UTC)
    generated_at = now_utc.isoformat().replace("+00:00", "Z")

    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    tool_dir = Path(__file__).resolve().parent
    phase3_root = tool_dir.parent
    ai_root = phase3_root.parent
    terminal_root = ai_root.parents[2]
    files_ai = terminal_root / "MQL5" / "Files" / "AI"

    validation = read_json(output_dir / "phase3_validation_latest.json")
    candidate = read_json(output_dir / "phase3_candidate_state_bundle_latest.json")
    freshness_lineage = read_json(output_dir / "phase3_freshness_lineage_summary_latest.json")
    source_completeness = read_json(output_dir / "phase3_source_completeness_summary_latest.json")
    blocker_consolidation = read_json(output_dir / "phase3_closure_blocker_consolidation_latest.json")
    closure_comparison = read_json(output_dir / "phase3_closure_before_after_comparison_latest.json")
    refinement_cycles = read_json(output_dir / "phase3_1_refinement_cycles_latest.json")

    validation_phase31 = (
        validation.get("phase31_quality_report", {})
        if isinstance(validation.get("phase31_quality_report"), dict)
        else {}
    )
    candidate_quality = (
        candidate.get("candidate_quality_summary", {})
        if isinstance(candidate.get("candidate_quality_summary"), dict)
        else {}
    )
    candidate_scores = (
        candidate_quality.get("closure_readiness_scores", {})
        if isinstance(candidate_quality.get("closure_readiness_scores"), dict)
        else {}
    )
    freshness_scores = (
        freshness_lineage.get("closure_readiness_scores", {})
        if isinstance(freshness_lineage.get("closure_readiness_scores"), dict)
        else {}
    )
    comparison_scores = (
        closure_comparison.get("after_scores", {})
        if isinstance(closure_comparison.get("after_scores"), dict)
        else {}
    )

    score_sources = {
        "validation_phase31": pick_scores(validation_phase31, "validation_phase31"),
        "candidate_closure_scores": pick_scores(candidate_scores, "candidate_closure_scores"),
        "freshness_lineage_scores": pick_scores(freshness_scores, "freshness_lineage_scores"),
        "closure_comparison_after_scores": pick_scores(comparison_scores, "closure_comparison_after_scores"),
    }
    score_consistency = score_consistency_report(score_sources)

    lineage_sources = {
        "validation_phase31": str(
            validation_phase31.get("lineage_continuity", {}).get("lineage_state", "UNKNOWN")
            if isinstance(validation_phase31.get("lineage_continuity"), dict)
            else "UNKNOWN"
        ),
        "candidate_quality": str(candidate_quality.get("lineage_continuity_summary", {}).get("lineage_state", "UNKNOWN")),
        "freshness_lineage": str(freshness_lineage.get("lineage_continuity_summary", {}).get("lineage_state", "UNKNOWN")),
        "closure_comparison_after": str(closure_comparison.get("after_lineage", {}).get("lineage_state", "UNKNOWN")),
    }
    lineage_consistency = lineage_consistency_report(lineage_sources)

    blocker_summary = (
        blocker_consolidation.get("blocker_consolidation_summary", {})
        if isinstance(blocker_consolidation.get("blocker_consolidation_summary"), dict)
        else {}
    )
    blockers = blocker_summary.get("blockers", []) if isinstance(blocker_summary.get("blockers"), list) else []
    open_blockers = [b for b in blockers if isinstance(b, dict) and str(b.get("status", "")).upper() == "OPEN"]
    open_blocker_ids = [str(b.get("blocker_id", "UNKNOWN")) for b in open_blockers]

    validation_result = str(validation.get("result", "UNKNOWN")).upper()
    closure_assessment = str(closure_comparison.get("closure_gate_assessment", "UNKNOWN")).upper()
    continuity_score = round(to_float(validation_phase31.get("continuity_score"), 0.0), 4)
    freshness_score = round(to_float(validation_phase31.get("freshness_score"), 0.0), 4)
    completeness_score = round(to_float(validation_phase31.get("completeness_score"), 0.0), 4)
    explainability_score = round(to_float(validation_phase31.get("explainability_score"), 0.0), 4)
    lineage_state = str(
        validation_phase31.get("lineage_continuity", {}).get("lineage_state", "UNKNOWN")
        if isinstance(validation_phase31.get("lineage_continuity"), dict)
        else "UNKNOWN"
    )

    source_state_counts = (
        validation_phase31.get("source_state_counts", {})
        if isinstance(validation_phase31.get("source_state_counts"), dict)
        else {}
    )
    family_freshness_counts = (
        validation_phase31.get("family_freshness_counts", {})
        if isinstance(validation_phase31.get("family_freshness_counts"), dict)
        else {}
    )
    expired_source_count = int(source_state_counts.get("EXPIRED", 0))
    expired_family_count = int(family_freshness_counts.get("EXPIRED", 0))

    monitor_surfaces = {
        "atas_observation_export.json": files_ai
        / "external_adapter"
        / "atas_semantic_adapter"
        / "future_exporter"
        / "runtime"
        / "acquisition_source"
        / "atas_observation_export.json",
        "acquisition_input_payload.json": files_ai
        / "external_adapter"
        / "atas_semantic_adapter"
        / "future_exporter"
        / "runtime"
        / "acquisition_input"
        / "acquisition_input_payload.json",
        "atas_export_payload.json": files_ai
        / "external_adapter"
        / "atas_semantic_adapter"
        / "runtime"
        / "producer_input"
        / "atas_export_payload.json",
        "exporter_status.json": files_ai
        / "external_adapter"
        / "atas_semantic_adapter"
        / "future_exporter"
        / "runtime"
        / "exporter_status.json",
        "adapter_status.json": files_ai / "external_adapter" / "atas_semantic_adapter" / "runtime" / "adapter_status.json",
        "atas_runtime_context.json": files_ai / "atas_runtime_context.json",
        "atas_runtime_context_status.json": files_ai / "atas_runtime_context_status.json",
        "phase3_candidate_state_bundle_latest.json": output_dir / "phase3_candidate_state_bundle_latest.json",
        "phase3_validation_latest.json": output_dir / "phase3_validation_latest.json",
        "phase3_freshness_lineage_summary_latest.json": output_dir / "phase3_freshness_lineage_summary_latest.json",
        "phase3_source_completeness_summary_latest.json": output_dir / "phase3_source_completeness_summary_latest.json",
        "phase3_closure_blocker_consolidation_latest.json": output_dir / "phase3_closure_blocker_consolidation_latest.json",
        "phase3_closure_before_after_comparison_latest.json": output_dir
        / "phase3_closure_before_after_comparison_latest.json",
        "phase3_closure_before_after_comparison_latest.md": output_dir / "phase3_closure_before_after_comparison_latest.md",
    }
    monitor_snapshots = {name: file_snapshot(path, now_utc) for name, path in monitor_surfaces.items()}
    missing_monitor_surfaces = [name for name, snap in monitor_snapshots.items() if not snap.get("exists")]

    live_verification_state = (
        "LIVE_VERIFICATION_DEFERRED_MARKET_CLOSED"
        if args.market_state == "MARKET_CLOSED"
        else "LIVE_VERIFICATION_PENDING_FRESH_EVIDENCE"
    )

    score_consistency_ok = bool(score_consistency.get("consistent"))
    lineage_consistency_ok = bool(lineage_consistency.get("consistent"))
    artifact_presence_ok = len(missing_monitor_surfaces) == 0
    validator_ok = validation_result in {"PASS", "PARTIAL_PASS"}

    prelive_verification_state = (
        "PRELIVE_VERIFICATION_READY"
        if artifact_presence_ok and score_consistency_ok and lineage_consistency_ok and validator_ok
        else "PRELIVE_VERIFICATION_NOT_READY"
    )

    closure_state = "CLOSURE_STILL_PARTIAL"
    if (
        args.market_state == "LIVE_WINDOW"
        and closure_assessment == "CLOSED"
        and not open_blockers
        and validation_result == "PASS"
    ):
        closure_state = "CLOSURE_GATE_CLOSED_PENDING_OPERATOR_CONFIRMATION"

    closure_gate_checks = [
        {
            "gate_id": "G1_VALIDATOR_PASS",
            "required": "phase3_validation_latest.result == PASS",
            "met_now": validation_result == "PASS",
        },
        {
            "gate_id": "G2_NO_OPEN_BLOCKERS",
            "required": "phase3_closure_blocker_consolidation_latest.blocker_count == 0",
            "met_now": len(open_blockers) == 0,
        },
        {
            "gate_id": "G3_LINEAGE_COHERENT_FRESH",
            "required": "lineage_state == COHERENT_FRESH",
            "met_now": lineage_state == "COHERENT_FRESH",
        },
        {
            "gate_id": "G4_NO_EXPIRED_STATES",
            "required": "source_state_counts.EXPIRED == 0 and family_freshness_counts.EXPIRED == 0",
            "met_now": expired_source_count == 0 and expired_family_count == 0,
        },
        {
            "gate_id": "G5_LIVE_CHAIN_PROGRESS_PROVEN",
            "required": "fresh live window confirms coherent packet progression across observation->acquisition->exporter->adapter->runtime->status",
            "met_now": False,
            "reason": "MARKET_CLOSED" if args.market_state == "MARKET_CLOSED" else "REQUIRES_REVIEW",
        },
    ]

    partial_closure_evidence_rules = [
        "any_open_blocker_present",
        "validator_result_not_PASS",
        "lineage_state_not_COHERENT_FRESH",
        "any_expired_or_stale_required_surface",
        "market_closed_without_fresh_live_propagation_window",
    ]
    current_partial_evidence: list[str] = []
    if open_blockers:
        current_partial_evidence.append(f"open_blockers:{','.join(open_blocker_ids)}")
    if validation_result != "PASS":
        current_partial_evidence.append(f"validator_result:{validation_result}")
    if lineage_state != "COHERENT_FRESH":
        current_partial_evidence.append(f"lineage_state:{lineage_state}")
    if expired_source_count > 0 or expired_family_count > 0:
        current_partial_evidence.append(
            f"expired_states:sources={expired_source_count},families={expired_family_count}"
        )
    if args.market_state == "MARKET_CLOSED":
        current_partial_evidence.append("market_closed_no_fresh_live_window")

    stale_honesty_checks = {
        "closure_not_forced_to_closed": closure_state != "CLOSURE_GATE_CLOSED_PENDING_OPERATOR_CONFIRMATION",
        "expired_states_reported": (expired_source_count + expired_family_count) > 0,
        "open_blockers_reported": len(open_blockers) > 0,
        "consistency_ambiguity_eliminated": score_consistency_ok and lineage_consistency_ok,
    }

    next_live_run_order = [
        {
            "step": 1,
            "command": "powershell -ExecutionPolicy Bypass -File .\\atas_microstructure_phase3_sandbox_v1\\tools\\run_phase3_candidate_pipeline.ps1",
            "expected_output": "phase3_candidate_state_bundle_latest.json + phase3_validation_latest.json",
        },
        {
            "step": 2,
            "command": "powershell -ExecutionPolicy Bypass -File .\\atas_microstructure_phase3_sandbox_v1\\tools\\run_phase3_1_refinement_cycles.ps1 -Cycles 5 -IntervalSeconds 1",
            "expected_output": "phase3_1_refinement_cycles_latest.json",
        },
        {
            "step": 3,
            "command": "python .\\atas_microstructure_phase3_sandbox_v1\\tools\\build_phase3_closure_before_after_comparison.py --output-dir .\\..\\..\\Files\\AI\\atas_micro_phase3_candidate",
            "expected_output": "phase3_closure_before_after_comparison_latest.json/.md",
        },
        {
            "step": 4,
            "command": "python .\\atas_microstructure_phase3_sandbox_v1\\tools\\build_phase3_weekend_safe_prelive_pack.py --output-dir .\\..\\..\\Files\\AI\\atas_micro_phase3_candidate --market-state LIVE_WINDOW",
            "expected_output": "phase3_weekend_safe_prelive_status_latest.json",
        },
    ]

    payload = {
        "schema_version": "ATAS_PHASE3_WEEKEND_SAFE_PRELIVE_STATUS_V1",
        "generated_at_utc": generated_at,
        "market_state_assumption": args.market_state,
        "machine_status": {
            "live_verification_state": live_verification_state,
            "prelive_verification_state": prelive_verification_state,
            "closure_state": closure_state,
            "closure_gate_assessment_from_comparison": closure_assessment,
            "validator_result": validation_result,
        },
        "open_blocker_count": len(open_blockers),
        "open_blocker_ids": open_blocker_ids,
        "open_blockers": open_blockers,
        "scores_snapshot": {
            "continuity_score": continuity_score,
            "freshness_score": freshness_score,
            "completeness_score": completeness_score,
            "explainability_score": explainability_score,
            "lineage_state": lineage_state,
        },
        "score_consistency": {
            "score_sources": score_sources,
            "report": score_consistency,
            "lineage_report": lineage_consistency,
        },
        "stale_state_honesty_checks": stale_honesty_checks,
        "monitor_surfaces": monitor_snapshots,
        "missing_monitor_surfaces": missing_monitor_surfaces,
        "next_live_window": {
            "run_order": next_live_run_order,
            "closure_gate_criteria_for_closed": closure_gate_checks,
            "partial_closure_evidence_rules": partial_closure_evidence_rules,
            "current_partial_closure_evidence": current_partial_evidence,
            "rollback_stop_rule": "STOP if validator_result == FAIL or continuity_score < 0.50 or blocker_count increases from baseline.",
            "evidence_collection_order": [
                "Capture monitored raw surfaces and mtimes before run.",
                "Capture phase3 candidate outputs after step 2.",
                "Capture closure comparison and weekend-safe status artifacts after step 4.",
            ],
            "post_run_evaluation_order": [
                "Review validator_result and blocker_count.",
                "Review closure gate checks G1-G5 and current partial evidence.",
                "Promote to CLOSED only if all closure gate checks are met with fresh live evidence.",
            ],
        },
        "reference_artifacts": {
            "phase3_validation_latest": str(output_dir / "phase3_validation_latest.json"),
            "phase3_freshness_lineage_summary_latest": str(output_dir / "phase3_freshness_lineage_summary_latest.json"),
            "phase3_source_completeness_summary_latest": str(output_dir / "phase3_source_completeness_summary_latest.json"),
            "phase3_closure_blocker_consolidation_latest": str(
                output_dir / "phase3_closure_blocker_consolidation_latest.json"
            ),
            "phase3_closure_before_after_comparison_latest": str(
                output_dir / "phase3_closure_before_after_comparison_latest.json"
            ),
            "phase3_1_refinement_cycles_latest": str(output_dir / "phase3_1_refinement_cycles_latest.json"),
            "refinement_generated_at_utc": refinement_cycles.get("generated_at_utc"),
        },
    }

    status_latest = output_dir / "phase3_weekend_safe_prelive_status_latest.json"
    status_stream = output_dir / "phase3_weekend_safe_prelive_status_stream.jsonl"
    pack_md = output_dir / "phase3_weekend_safe_verification_pack_latest.md"

    write_json(status_latest, payload)
    append_jsonl(status_stream, payload)

    lines = [
        "# Phase 3 Weekend-Safe Pre-Live Verification Pack",
        "",
        f"- Generated At (UTC): {generated_at}",
        f"- Live Verification State: {live_verification_state}",
        f"- Pre-Live Verification State: {prelive_verification_state}",
        f"- Closure State: {closure_state}",
        f"- Closure Gate Assessment (Current): {closure_assessment}",
        "",
        "## Open Blockers",
        f"- Count: {len(open_blockers)}",
        f"- IDs: {', '.join(open_blocker_ids) if open_blocker_ids else 'NONE'}",
        "",
        "## Score Snapshot",
        *(f"- {k}: {v}" for k, v in payload["scores_snapshot"].items()),
        "",
        "## Consistency",
        f"- Scores Consistent: {score_consistency.get('consistent')}",
        f"- Lineage Classification Consistent: {lineage_consistency.get('consistent')}",
        "",
        "## Next Live Run Order",
    ]
    for item in next_live_run_order:
        lines.append(f"- Step {item['step']}: `{item['command']}`")
    lines.extend(
        [
            "",
            "## Closure Gate Criteria",
        ]
    )
    for gate in closure_gate_checks:
        lines.append(f"- {gate['gate_id']}: {gate['required']} (met_now={gate['met_now']})")
    lines.extend(
        [
            "",
            "## Current Partial Evidence",
            *(f"- {x}" for x in current_partial_evidence),
            "",
            "## Note",
            "- This pack does not claim live continuity closure while market is closed.",
            "",
        ]
    )
    write_md(pack_md, "\n".join(lines))

    print(
        json.dumps(
            {
                "result": "PASS",
                "status_json": str(status_latest),
                "status_stream": str(status_stream),
                "pack_md": str(pack_md),
                "live_verification_state": live_verification_state,
                "prelive_verification_state": prelive_verification_state,
                "closure_state": closure_state,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
