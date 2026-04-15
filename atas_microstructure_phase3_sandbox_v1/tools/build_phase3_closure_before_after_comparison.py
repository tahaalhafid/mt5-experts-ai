from __future__ import annotations

import argparse
import json
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


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


def find_latest_baseline_index(output_dir: Path) -> Path | None:
    files = sorted(
        output_dir.glob("phase3_closure_before_baseline_index_*.json"),
        key=lambda p: p.stat().st_mtime,
        reverse=True,
    )
    return files[0] if files else None


def to_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def score_set(candidate: dict[str, Any], validation: dict[str, Any]) -> dict[str, float]:
    csum = candidate.get("candidate_quality_summary", {})
    closure = csum.get("closure_readiness_scores", {}) if isinstance(csum, dict) else {}
    vrep = validation.get("phase31_quality_report", {}) if isinstance(validation, dict) else {}
    return {
        "continuity_score": to_float(closure.get("continuity_score"), to_float(vrep.get("continuity_score"), 0.0)),
        "freshness_score": to_float(closure.get("freshness_score"), to_float(vrep.get("freshness_score"), 0.0)),
        "completeness_score": to_float(closure.get("completeness_score"), to_float(vrep.get("completeness_score"), 0.0)),
        "lineage_continuity_score": to_float(
            closure.get("lineage_continuity_score"),
            to_float(vrep.get("lineage_continuity_score"), 0.0),
        ),
        "source_coverage_score": to_float(
            closure.get("source_coverage_score"),
            to_float(vrep.get("source_coverage_score"), 0.0),
        ),
        "explainability_score": to_float(
            closure.get("explainability_score"),
            to_float(vrep.get("explainability_score"), 0.0),
        ),
    }


def main() -> int:
    parser = argparse.ArgumentParser(description="Build Phase 3 closure before/after comparison artifacts.")
    parser.add_argument("--output-dir", required=True, help="Path to MQL5/Files/AI/atas_micro_phase3_candidate")
    parser.add_argument("--baseline-index", help="Optional explicit baseline index path")
    args = parser.parse_args()

    output_dir = Path(args.output_dir).resolve()
    baseline_index_path = Path(args.baseline_index).resolve() if args.baseline_index else find_latest_baseline_index(output_dir)
    if baseline_index_path is None or not baseline_index_path.exists():
        raise SystemExit("Baseline index not found. Provide --baseline-index.")

    baseline_index = read_json(baseline_index_path)
    baseline_files = baseline_index.get("files", [])
    baseline_candidate = {}
    baseline_validation = {}
    for name in baseline_files:
        if "candidate_bundle" in name:
            baseline_candidate = read_json(output_dir / name)
        elif "validation" in name:
            baseline_validation = read_json(output_dir / name)

    current_candidate = read_json(output_dir / "phase3_candidate_state_bundle_latest.json")
    current_validation = read_json(output_dir / "phase3_validation_latest.json")
    current_blockers = read_json(output_dir / "phase3_closure_blocker_consolidation_latest.json")

    before_scores = score_set(baseline_candidate, baseline_validation)
    after_scores = score_set(current_candidate, current_validation)
    score_deltas = {
        key: round(after_scores.get(key, 0.0) - before_scores.get(key, 0.0), 4)
        for key in after_scores.keys()
    }

    before_lineage = (
        baseline_candidate.get("candidate_quality_summary", {}).get("lineage_continuity_summary", {})
        if isinstance(baseline_candidate, dict)
        else {}
    )
    after_lineage = (
        current_candidate.get("candidate_quality_summary", {}).get("lineage_continuity_summary", {})
        if isinstance(current_candidate, dict)
        else {}
    )

    blocker_summary = current_blockers.get("blocker_consolidation_summary", {}) if isinstance(current_blockers, dict) else {}
    open_blockers = [
        b for b in blocker_summary.get("blockers", [])
        if isinstance(b, dict) and str(b.get("status", "")).upper() == "OPEN"
    ]
    validator_result = str(current_validation.get("result", "UNKNOWN")).upper()
    closure_assessment = "STILL_OPEN"
    if validator_result == "PASS" and not open_blockers:
        closure_assessment = "CLOSED"
    elif validator_result in {"PASS", "PARTIAL_PASS"}:
        closure_assessment = "PARTIALLY_CLOSED"

    payload = {
        "schema_version": "ATAS_PHASE3_CLOSURE_BEFORE_AFTER_COMPARISON_V1",
        "generated_at_utc": utc_now_iso(),
        "baseline_index_path": str(baseline_index_path),
        "before_scores": before_scores,
        "after_scores": after_scores,
        "score_deltas": score_deltas,
        "before_lineage": {
            "lineage_state": before_lineage.get("lineage_state"),
            "first_break_stage": before_lineage.get("first_break_stage"),
            "lineage_reason": before_lineage.get("lineage_reason"),
        },
        "after_lineage": {
            "lineage_state": after_lineage.get("lineage_state"),
            "first_break_stage": after_lineage.get("first_break_stage"),
            "lineage_reason": after_lineage.get("lineage_reason"),
        },
        "current_validator_result": validator_result,
        "current_open_blocker_count": len(open_blockers),
        "current_open_blocker_ids": [str(b.get("blocker_id", "")) for b in open_blockers],
        "closure_gate_assessment": closure_assessment,
    }

    json_out = output_dir / "phase3_closure_before_after_comparison_latest.json"
    md_out = output_dir / "phase3_closure_before_after_comparison_latest.md"
    write_json(json_out, payload)
    write_md(
        md_out,
        "\n".join(
            [
                "# Phase 3 Closure Before/After Comparison",
                "",
                f"- Generated At (UTC): {payload['generated_at_utc']}",
                f"- Validator Result (Current): {validator_result}",
                f"- Closure Gate Assessment: {closure_assessment}",
                "",
                "## Score Deltas",
                *(f"- {k}: {v:+.4f}" for k, v in score_deltas.items()),
                "",
                "## Lineage",
                f"- Before: {json.dumps(payload['before_lineage'])}",
                f"- After: {json.dumps(payload['after_lineage'])}",
                "",
                "## Current Open Blockers",
                f"- Count: {len(open_blockers)}",
                f"- IDs: {', '.join(payload['current_open_blocker_ids']) if payload['current_open_blocker_ids'] else 'NONE'}",
            ]
        ) + "\n",
    )

    print(
        json.dumps(
            {
                "result": "PASS",
                "comparison_json": str(json_out),
                "comparison_md": str(md_out),
                "closure_gate_assessment": closure_assessment,
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
