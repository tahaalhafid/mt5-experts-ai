from __future__ import annotations

import argparse
import json
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

try:
    import jsonschema  # type: ignore
except ImportError:  # pragma: no cover
    jsonschema = None


def utc_now_iso() -> str:
    return datetime.now(UTC).isoformat().replace("+00:00", "Z")


def read_json(path: Path) -> dict[str, Any]:
    parsed = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    if not isinstance(parsed, dict):
        raise ValueError(f"Expected JSON object in {path}")
    return parsed


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def append_jsonl(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(payload, separators=(",", ":")) + "\n")


def validate_schema(payload: dict[str, Any], schema: dict[str, Any]) -> list[str]:
    if jsonschema is None:
        return []
    validator = jsonschema.Draft202012Validator(schema)
    errors: list[str] = []
    for err in sorted(validator.iter_errors(payload), key=lambda e: e.path):
        p = ".".join(str(x) for x in err.path) or "$"
        errors.append(f"{p}: {err.message}")
    return errors


def walk_forbidden(obj: Any, forbidden: set[str], prefix: str = "") -> list[str]:
    hits: list[str] = []
    if isinstance(obj, dict):
        for k, v in obj.items():
            p = f"{prefix}.{k}" if prefix else k
            if k in forbidden:
                hits.append(p)
            hits.extend(walk_forbidden(v, forbidden, p))
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            hits.extend(walk_forbidden(item, forbidden, f"{prefix}[{i}]"))
    return hits


def check_family_contract(bundle: dict[str, Any], contract: dict[str, Any]) -> tuple[list[str], list[str], dict[str, Any]]:
    errors: list[str] = []
    warnings: list[str] = []
    report: dict[str, Any] = {}

    families_cfg = contract.get("families", {})
    families_payload = bundle.get("families", {})
    if not isinstance(families_payload, dict):
        return ["bundle.families missing"], warnings, report

    for family_name, cfg in families_cfg.items():
        if family_name not in families_payload:
            errors.append(f"families.{family_name}: missing")
            continue
        fam = families_payload[family_name]
        if not isinstance(fam, dict):
            errors.append(f"families.{family_name}: invalid family object")
            continue
        fields = fam.get("candidate_fields")
        meta = fam.get("metadata")
        reasons = fam.get("reason_codes")
        trace = fam.get("trace_summary")
        if not isinstance(fields, dict):
            errors.append(f"families.{family_name}.candidate_fields: missing/invalid")
            continue
        if not isinstance(meta, dict):
            errors.append(f"families.{family_name}.metadata: missing/invalid")
        if not isinstance(reasons, list) or not reasons:
            errors.append(f"families.{family_name}.reason_codes: missing/empty")
        if not isinstance(trace, dict):
            errors.append(f"families.{family_name}.trace_summary: missing/invalid")

        mandatory = cfg.get("mandatory_fields", [])
        optional = cfg.get("optional_fields", [])
        provisional = cfg.get("provisional_fields", [])
        derived_later = cfg.get("derived_later_fields", [])
        missing = [f for f in mandatory if f not in fields]
        if missing:
            errors.append(f"families.{family_name}: missing mandatory -> {', '.join(missing)}")

        present = set(fields.keys())
        unknown = sorted(present - set(mandatory) - set(optional) - set(provisional) - set(derived_later) - {"field_group_quality"})
        if unknown:
            warnings.append(f"families.{family_name}: unknown candidate fields -> {', '.join(unknown)}")

        for key in ("freshness", "completeness_ratio", "provenance_by_field", "field_status"):
            if not isinstance(meta, dict) or key not in meta:
                warnings.append(f"families.{family_name}.metadata.{key}: missing")

        report[family_name] = {
            "mandatory_count": len(mandatory),
            "mandatory_missing_count": len(missing),
            "mandatory_missing_fields": missing,
            "present_field_count": len(fields),
            "has_reason_codes": isinstance(reasons, list) and len(reasons) > 0,
            "has_trace_summary": isinstance(trace, dict),
        }

    return errors, warnings, report


def check_quality_suppression(bundle: dict[str, Any]) -> tuple[list[str], list[str]]:
    errors: list[str] = []
    warnings: list[str] = []
    qv = bundle.get("families", {}).get("QualityValidityState", {})
    fields = qv.get("candidate_fields", {}) if isinstance(qv, dict) else {}
    required = [
        "degradation_state",
        "suppression_flags",
        "suppression_reason_codes",
        "export_eligibility_candidate",
        "confidence_ceiling_candidate",
    ]
    for k in required:
        if k not in fields:
            errors.append(f"QualityValidityState.candidate_fields.{k}: missing")
    if "suppression_reason_codes" in fields and not isinstance(fields.get("suppression_reason_codes"), list):
        errors.append("QualityValidityState.candidate_fields.suppression_reason_codes: must be list")
    if "export_eligibility_candidate" in fields and not isinstance(fields.get("export_eligibility_candidate"), bool):
        errors.append("QualityValidityState.candidate_fields.export_eligibility_candidate: must be boolean")
    if "confidence_ceiling_candidate" in fields:
        val = fields.get("confidence_ceiling_candidate")
        if not isinstance(val, (int, float)):
            errors.append("QualityValidityState.candidate_fields.confidence_ceiling_candidate: must be number")
        elif float(val) > 0.49:
            warnings.append("confidence_ceiling_candidate exceeds Phase1 extended confidence ceiling (0.49)")
    return errors, warnings


def to_float(value: Any, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def evaluate_phase31_quality(bundle: dict[str, Any]) -> tuple[list[str], list[str], dict[str, Any]]:
    errors: list[str] = []
    warnings: list[str] = []
    report: dict[str, Any] = {}

    families = bundle.get("families", {})
    if not isinstance(families, dict) or not families:
        errors.append("phase31: bundle.families missing/empty")
        return errors, warnings, report

    family_completeness: dict[str, float] = {}
    family_freshness_counts: dict[str, int] = {}
    family_usability: dict[str, str] = {}
    explainable_family_count = 0

    for family_name, family_payload in families.items():
        if not isinstance(family_payload, dict):
            warnings.append(f"phase31: families.{family_name} invalid")
            continue
        metadata = family_payload.get("metadata", {})
        reasons = family_payload.get("reason_codes", [])
        if not isinstance(metadata, dict):
            warnings.append(f"phase31: families.{family_name}.metadata missing")
            continue

        completeness = to_float(metadata.get("completeness_ratio"), -1.0)
        if completeness < 0:
            warnings.append(f"phase31: families.{family_name}.metadata.completeness_ratio missing")
            completeness = 0.0
        family_completeness[family_name] = round(completeness, 4)

        freshness_state = str(metadata.get("freshness", {}).get("freshness_state", "UNKNOWN")).upper()
        family_freshness_counts[freshness_state] = family_freshness_counts.get(freshness_state, 0) + 1
        if freshness_state == "UNKNOWN":
            warnings.append(f"phase31: families.{family_name}.metadata.freshness.freshness_state unknown")

        usability_state = str(metadata.get("candidate_usability_state", "UNKNOWN"))
        family_usability[family_name] = usability_state
        if usability_state == "UNKNOWN":
            warnings.append(f"phase31: families.{family_name}.metadata.candidate_usability_state missing/unknown")

        source_state_summary = metadata.get("source_state_summary")
        if not isinstance(source_state_summary, dict) or not source_state_summary:
            warnings.append(f"phase31: families.{family_name}.metadata.source_state_summary missing")

        provenance = metadata.get("provenance_by_field")
        field_status = metadata.get("field_status")
        if isinstance(provenance, dict) and provenance and isinstance(field_status, dict):
            explainable_family_count += 1
        else:
            warnings.append(f"phase31: families.{family_name} explainability metadata weak")

        if not isinstance(reasons, list) or not reasons:
            warnings.append(f"phase31: families.{family_name}.reason_codes missing")

    avg_family_completeness = (
        sum(family_completeness.values()) / max(len(family_completeness), 1)
    )
    explainability_score = explainable_family_count / max(len(families), 1)

    quality_summary = bundle.get("candidate_quality_summary", {})
    closure_scores = (
        quality_summary.get("closure_readiness_scores", {})
        if isinstance(quality_summary, dict)
        else {}
    )
    if not isinstance(closure_scores, dict):
        closure_scores = {}
    source_summary = (
        quality_summary.get("source_completeness_summary", {})
        if isinstance(quality_summary, dict)
        else {}
    )
    source_state_counts = (
        source_summary.get("source_state_counts", {})
        if isinstance(source_summary, dict)
        else {}
    )
    if not isinstance(source_state_counts, dict):
        source_state_counts = {}
        warnings.append("phase31: candidate_quality_summary.source_completeness_summary.source_state_counts missing")
    source_coverage_score = to_float(
        source_summary.get("average_source_coverage_ratio"),
        0.0,
    ) if isinstance(source_summary, dict) else 0.0

    missing_sources = int(source_state_counts.get("MISSING", 0))
    stale_sources = int(source_state_counts.get("STALE", 0))
    expired_sources = int(source_state_counts.get("EXPIRED", 0))
    partial_sources = int(source_state_counts.get("PARTIAL_BUT_USABLE", 0)) + int(
        source_state_counts.get("PARTIAL_BUT_DEGRADED", 0)
    )

    lineage_summary = (
        quality_summary.get("lineage_continuity_summary", {})
        if isinstance(quality_summary, dict)
        else {}
    )
    if not isinstance(lineage_summary, dict):
        lineage_summary = {}
    lineage_state = str(lineage_summary.get("lineage_state", "UNKNOWN"))
    lineage_reason = str(lineage_summary.get("lineage_reason", "UNKNOWN"))
    first_break = str(lineage_summary.get("first_break_stage", "NONE"))
    if lineage_state in {"UNKNOWN", ""}:
        warnings.append("phase31: lineage continuity summary missing")

    fresh_count = int(family_freshness_counts.get("FRESH", 0))
    stale_count = int(family_freshness_counts.get("STALE", 0))
    expired_count = int(family_freshness_counts.get("EXPIRED", 0))
    family_total = max(len(families), 1)
    freshness_quality_score = ((fresh_count * 1.0) + (stale_count * 0.5) + (expired_count * 0.0)) / family_total
    completeness_score = to_float(closure_scores.get("completeness_score"), avg_family_completeness)
    continuity_score = to_float(closure_scores.get("continuity_score"), 0.0)
    lineage_continuity_score = to_float(closure_scores.get("lineage_continuity_score"), continuity_score)
    freshness_score = to_float(closure_scores.get("freshness_score"), freshness_quality_score)

    transitions = lineage_summary.get("transitions", {}) if isinstance(lineage_summary, dict) else {}
    if continuity_score <= 0.0 and isinstance(transitions, dict) and transitions:
        transition_states = [str(v.get("state", "UNKNOWN")) for v in transitions.values() if isinstance(v, dict)]
        matched = len([1 for s in transition_states if s in {"MATCH_DIRECT", "MATCH_VIA_LINEAGE"}])
        continuity_score = matched / max(len(transition_states), 1)
        lineage_continuity_score = continuity_score
    if continuity_score <= 0.0 and lineage_state in {"COHERENT_FRESH", "COHERENT_BUT_LOW_FRESHNESS"}:
        continuity_score = 1.0
        lineage_continuity_score = 1.0
    elif continuity_score <= 0.0 and lineage_state in {"PARTIAL_INCOMPLETE"}:
        continuity_score = 0.5
        lineage_continuity_score = 0.5
    elif continuity_score <= 0.0 and lineage_state in {"DIVERGED"}:
        continuity_score = 0.0
        lineage_continuity_score = 0.0

    continuity_band = (
        "STABLE"
        if continuity_score >= 0.85
        else "PARTIAL"
        if continuity_score >= 0.50
        else "UNSTABLE"
    )

    report = {
        "family_population_score": round(avg_family_completeness, 4),
        "source_coverage_score": round(source_coverage_score, 4),
        "freshness_quality_score": round(freshness_quality_score, 4),
        "freshness_score": round(freshness_score, 4),
        "completeness_score": round(completeness_score, 4),
        "continuity_score": round(continuity_score, 4),
        "lineage_continuity_score": round(lineage_continuity_score, 4),
        "explainability_score": round(explainability_score, 4),
        "continuity_band": continuity_band,
        "family_completeness": family_completeness,
        "family_freshness_counts": family_freshness_counts,
        "family_usability_states": family_usability,
        "source_state_counts": source_state_counts,
        "stale_vs_missing_breakdown": {
            "missing_sources": missing_sources,
            "stale_sources": stale_sources,
            "expired_sources": expired_sources,
            "partial_sources": partial_sources,
        },
        "lineage_continuity": {
            "lineage_state": lineage_state,
            "lineage_reason": lineage_reason,
            "first_break_stage": first_break,
        },
        "closure_readiness_scores_from_bundle": closure_scores,
    }
    return errors, warnings, report


def write_human_summary(path: Path, report: dict[str, Any]) -> None:
    lines = [
        "# Phase 3.1 Candidate Validation Summary",
        "",
        f"- Evaluated At (UTC): {report.get('evaluated_at_utc', 'UNKNOWN')}",
        f"- Result: {report.get('result', 'UNKNOWN')}",
        f"- Error Count: {len(report.get('errors', []))}",
        f"- Warning Count: {len(report.get('warnings', []))}",
        "",
        "## Quality Scores",
    ]
    phase31 = report.get("phase31_quality_report", {})
    lines.extend(
        [
            f"- Family Population Score: {phase31.get('family_population_score', 'UNKNOWN')}",
            f"- Source Coverage Score: {phase31.get('source_coverage_score', 'UNKNOWN')}",
            f"- Continuity Score: {phase31.get('continuity_score', 'UNKNOWN')}",
            f"- Lineage Continuity Score: {phase31.get('lineage_continuity_score', 'UNKNOWN')}",
            f"- Freshness Quality Score: {phase31.get('freshness_quality_score', 'UNKNOWN')}",
            f"- Freshness Score: {phase31.get('freshness_score', 'UNKNOWN')}",
            f"- Completeness Score: {phase31.get('completeness_score', 'UNKNOWN')}",
            f"- Explainability Score: {phase31.get('explainability_score', 'UNKNOWN')}",
            "",
            "## Stale vs Missing",
            f"- Breakdown: {json.dumps(phase31.get('stale_vs_missing_breakdown', {}), ensure_ascii=True)}",
            "",
            "## Lineage",
            f"- Continuity: {json.dumps(phase31.get('lineage_continuity', {}), ensure_ascii=True)}",
            "",
            "## Notes",
            "- PASS requires boundary safety plus stronger continuity/freshness/completeness/explainability.",
            "- PARTIAL_PASS indicates boundary-safe but closure stability still limited.",
            "- FAIL indicates schema/contract/boundary violations.",
        ]
    )
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate ATAS Phase3 candidate state bundle.")
    parser.add_argument("--bundle", required=True, help="Path to phase3 candidate bundle JSON.")
    parser.add_argument("--output-dir", help="Optional output directory for validation artifacts.")
    args = parser.parse_args()

    tool_dir = Path(__file__).resolve().parent
    phase3_root = tool_dir.parent
    ai_root = phase3_root.parent
    terminal_root = ai_root.parents[2]
    files_ai = terminal_root / "MQL5" / "Files" / "AI"
    default_output = files_ai / "atas_micro_phase3_candidate"
    output_dir = Path(args.output_dir) if args.output_dir else default_output
    output_dir.mkdir(parents=True, exist_ok=True)

    bundle_path = Path(args.bundle).resolve()
    bundle = read_json(bundle_path)
    schema = read_json(phase3_root / "schemas" / "phase3_candidate_state_bundle_v1.schema.json")
    contract = read_json(phase3_root / "contracts" / "phase3_candidate_family_contract_v1.json")

    errors: list[str] = []
    warnings: list[str] = []
    schema_errors = validate_schema(bundle, schema)
    errors.extend([f"schema: {e}" for e in schema_errors])

    family_errors, family_warnings, family_report = check_family_contract(bundle, contract)
    errors.extend(family_errors)
    warnings.extend(family_warnings)

    q_errors, q_warnings = check_quality_suppression(bundle)
    errors.extend(q_errors)
    warnings.extend(q_warnings)

    phase31_errors, phase31_warnings, phase31_quality_report = evaluate_phase31_quality(bundle)
    errors.extend(phase31_errors)
    warnings.extend(phase31_warnings)

    forbidden = set(contract.get("forbidden_boundary_fields", []))
    hits = walk_forbidden(bundle.get("families", {}), forbidden, "families")
    if hits:
        errors.append("forbidden boundary fields detected: " + ", ".join(hits))

    boundary = bundle.get("boundary_checks", {})
    if isinstance(boundary, dict):
        for key in (
            "final_regime_leakage",
            "canonical_level_ownership_leakage",
            "tradability_verdict_leakage",
            "decision_package_leakage",
        ):
            if boundary.get(key) is True:
                errors.append(f"boundary_checks.{key}: true")

    classification = "PASS"
    if errors:
        classification = "FAIL"
    else:
        population_score = to_float(phase31_quality_report.get("family_population_score"), 0.0)
        freshness_score = to_float(phase31_quality_report.get("freshness_score"), 0.0)
        continuity_score = to_float(phase31_quality_report.get("continuity_score"), 0.0)
        completeness_score = to_float(phase31_quality_report.get("completeness_score"), 0.0)
        lineage_continuity_score = to_float(phase31_quality_report.get("lineage_continuity_score"), 0.0)
        source_coverage_score = to_float(phase31_quality_report.get("source_coverage_score"), 0.0)
        explainability_score = to_float(phase31_quality_report.get("explainability_score"), 0.0)
        boundary_safe = not hits and not any(
            bool(boundary.get(key, False))
            for key in (
                "final_regime_leakage",
                "canonical_level_ownership_leakage",
                "tradability_verdict_leakage",
                "decision_package_leakage",
            )
        )
        if (
            boundary_safe
            and population_score >= 0.75
            and completeness_score >= 0.75
            and continuity_score >= 0.75
            and lineage_continuity_score >= 0.75
            and freshness_score >= 0.60
            and source_coverage_score >= 0.70
            and explainability_score >= 0.70
            and not warnings
        ):
            classification = "PASS"
        else:
            classification = "PARTIAL_PASS"

    report = {
        "validator_version": "ATAS_PHASE3_CANDIDATE_VALIDATOR_V1_1",
        "evaluated_at_utc": utc_now_iso(),
        "bundle_path": str(bundle_path),
        "result": classification,
        "errors": errors,
        "warnings": warnings,
        "family_contract_report": family_report,
        "forbidden_boundary_hits": hits,
        "phase31_quality_report": phase31_quality_report,
    }

    latest = output_dir / "phase3_validation_latest.json"
    stream = output_dir / "phase3_validation_stream.jsonl"
    human = output_dir / "phase3_validation_human_summary_latest.md"
    governance = output_dir / "phase3_governance_boundary_check_summary_latest.json"
    write_json(latest, report)
    append_jsonl(stream, report)
    write_human_summary(human, report)

    gov_payload = read_json(governance) if governance.exists() else {}
    gov_payload["validator_result"] = classification
    gov_payload["validator_error_count"] = len(errors)
    gov_payload["validator_warning_count"] = len(warnings)
    gov_payload["validated_at_utc"] = utc_now_iso()
    gov_payload["phase31_quality_report"] = phase31_quality_report
    write_json(governance, gov_payload)

    print(
        json.dumps(
            {
                "result": classification,
                "latest_report": str(latest),
                "stream_report": str(stream),
                "error_count": len(errors),
                "warning_count": len(warnings),
            },
            indent=2,
        )
    )
    return 0 if classification in {"PASS", "PARTIAL_PASS"} else 2


if __name__ == "__main__":
    sys.exit(main())
