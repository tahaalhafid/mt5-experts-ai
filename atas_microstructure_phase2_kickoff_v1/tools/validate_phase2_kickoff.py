from __future__ import annotations

import argparse
import json
import sys
from datetime import UTC, datetime
from pathlib import Path
from typing import Any

try:
    import jsonschema  # type: ignore
except ImportError:  # pragma: no cover - optional dependency
    jsonschema = None


TYPE_MAP = {
    "string": str,
    "integer": int,
    "number": (int, float),
    "boolean": bool,
    "array": list,
    "object": dict,
}


def utc_now() -> datetime:
    return datetime.now(UTC)


def utc_now_iso() -> str:
    return utc_now().isoformat().replace("+00:00", "Z")


def parse_iso(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    try:
        dt = datetime.fromisoformat(text)
    except ValueError:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=UTC)
    return dt.astimezone(UTC)


def read_json(path: Path) -> dict[str, Any]:
    raw = path.read_text(encoding="utf-8", errors="replace")
    parsed = json.loads(raw)
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


def is_type_match(value: Any, expected_type: str) -> bool:
    if expected_type == "number":
        return isinstance(value, (int, float)) and not isinstance(value, bool)
    if expected_type == "integer":
        return isinstance(value, int) and not isinstance(value, bool)
    py_type = TYPE_MAP.get(expected_type)
    if py_type is None:
        return False
    return isinstance(value, py_type)


def validate_with_jsonschema(data: dict[str, Any], schema: dict[str, Any]) -> list[str]:
    if jsonschema is None:
        return []
    validator = jsonschema.Draft202012Validator(schema)
    errors = []
    for err in sorted(validator.iter_errors(data), key=lambda e: e.path):
        path = ".".join(str(p) for p in err.path) or "$"
        errors.append(f"{path}: {err.message}")
    return errors


def manual_required_checks(data: dict[str, Any], schema: dict[str, Any], path: str = "$") -> list[str]:
    errors: list[str] = []
    required = schema.get("required", [])
    if isinstance(required, list):
        for name in required:
            if isinstance(name, str) and name not in data:
                errors.append(f"{path}.{name}: missing required field")
    props = schema.get("properties", {})
    if not isinstance(props, dict):
        return errors
    for name, prop in props.items():
        if not isinstance(name, str) or not isinstance(prop, dict):
            continue
        if name not in data:
            continue
        value = data[name]
        if "const" in prop and value != prop["const"]:
            errors.append(f"{path}.{name}: expected const value {prop['const']!r}")
        if prop.get("type") == "object" and isinstance(value, dict):
            errors.extend(manual_required_checks(value, prop, f"{path}.{name}"))
    return errors


def validate_phase1_packet(
    packet_path: Path | None, schema_path: Path, label: str
) -> tuple[str, list[str]]:
    if packet_path is None:
        return "SKIPPED", []
    if not packet_path.exists():
        return "MISSING_INPUT", [f"{label}: file not found -> {packet_path}"]
    packet = read_json(packet_path)
    schema = read_json(schema_path)
    schema_errors = validate_with_jsonschema(packet, schema)
    if jsonschema is None:
        schema_errors = manual_required_checks(packet, schema)
    status = "PASS" if not schema_errors else "FAIL"
    return status, schema_errors


def validate_state_bundle(
    candidate: dict[str, Any],
    interfaces: dict[str, Any],
) -> tuple[list[str], list[str], dict[str, Any]]:
    errors: list[str] = []
    warnings: list[str] = []
    family_reports: dict[str, Any] = {}

    states = candidate.get("states")
    if not isinstance(states, dict):
        return ["$.states: missing or invalid"], warnings, family_reports

    families = interfaces.get("families", {})
    global_forbidden = set(interfaces.get("global_forbidden_fields", []))

    for family_name, family_cfg in families.items():
        if not isinstance(family_cfg, dict):
            continue
        state = states.get(family_name)
        if not isinstance(state, dict):
            errors.append(f"states.{family_name}: missing state family object")
            continue

        field_defs = family_cfg.get("fields", [])
        forbidden = set(family_cfg.get("forbidden_fields", [])) | global_forbidden
        known_names = []
        mandatory = []
        invalid_types = []
        missing_mandatory = []
        forbidden_hits = []

        for fd in field_defs:
            if not isinstance(fd, dict):
                continue
            name = fd.get("name")
            expected = fd.get("type")
            status = fd.get("status")
            if not isinstance(name, str) or not isinstance(expected, str):
                continue
            known_names.append(name)
            if status == "mandatory":
                mandatory.append(name)
                if name not in state:
                    missing_mandatory.append(name)
            if name in state and not is_type_match(state[name], expected):
                invalid_types.append(
                    {
                        "field": name,
                        "expected": expected,
                        "actual_type": type(state[name]).__name__,
                    }
                )

        for field_name in state.keys():
            if field_name in forbidden:
                forbidden_hits.append(field_name)

        unknown_fields = sorted(set(state.keys()) - set(known_names))

        if missing_mandatory:
            errors.append(
                f"states.{family_name}: missing mandatory fields -> {', '.join(missing_mandatory)}"
            )
        if invalid_types:
            errors.append(
                f"states.{family_name}: invalid field types -> "
                + ", ".join(f"{x['field']}({x['actual_type']}!= {x['expected']})" for x in invalid_types)
            )
        if forbidden_hits:
            errors.append(
                f"states.{family_name}: forbidden fields detected -> {', '.join(sorted(forbidden_hits))}"
            )
        if unknown_fields:
            warnings.append(
                f"states.{family_name}: unknown fields present -> {', '.join(unknown_fields)}"
            )

        present_known = len([name for name in known_names if name in state])
        denominator = len(known_names) if known_names else 1
        completeness = round(present_known / denominator, 4)

        if missing_mandatory:
            classification = "MISSING"
        elif invalid_types or forbidden_hits:
            classification = "INVALID"
        elif present_known == 0:
            classification = "EMPTY_BUT_VALID"
        else:
            classification = "AVAILABLE"

        family_reports[family_name] = {
            "classification": classification,
            "completeness_ratio": completeness,
            "present_known_fields": present_known,
            "known_field_count": len(known_names),
            "missing_mandatory_fields": missing_mandatory,
            "invalid_field_types": invalid_types,
            "forbidden_field_hits": sorted(forbidden_hits),
            "unknown_fields": unknown_fields,
        }

    return errors, warnings, family_reports


def build_telemetry(candidate: dict[str, Any], family_reports: dict[str, Any]) -> dict[str, Any]:
    telemetry: dict[str, Any] = {
        "generated_at_utc": candidate.get("generated_at_utc"),
        "evaluated_at_utc": utc_now_iso(),
        "family_completeness": {},
        "missing_field_families": [],
        "invalid_field_families": [],
        "forbidden_field_families": [],
        "source_freshness": {
            "candidate_age_seconds": None,
            "quality_validity_age_seconds": None
        }
    }

    for family, report in family_reports.items():
        telemetry["family_completeness"][family] = report.get("completeness_ratio")
        if report.get("missing_mandatory_fields"):
            telemetry["missing_field_families"].append(family)
        if report.get("invalid_field_types"):
            telemetry["invalid_field_families"].append(family)
        if report.get("forbidden_field_hits"):
            telemetry["forbidden_field_families"].append(family)

    generated_dt = parse_iso(candidate.get("generated_at_utc"))
    if generated_dt is not None:
        telemetry["source_freshness"]["candidate_age_seconds"] = int(
            (utc_now() - generated_dt).total_seconds()
        )

    qv = candidate.get("states", {}).get("QualityValidityState", {})
    if isinstance(qv, dict):
        event_dt = parse_iso(qv.get("event_time_utc"))
        eval_dt = parse_iso(qv.get("evaluated_at_utc"))
        if event_dt is not None and eval_dt is not None:
            telemetry["source_freshness"]["quality_validity_age_seconds"] = int(
                (eval_dt - event_dt).total_seconds()
            )
        telemetry["freshness_state"] = qv.get("freshness_state", "UNKNOWN")
        telemetry["attachment_state"] = qv.get("attachment_state", "UNKNOWN")

    return telemetry


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Validate ATAS Phase 2 kickoff state bundle and emit diagnostics telemetry."
    )
    parser.add_argument("--candidate-bundle", required=True, help="Path to candidate state bundle JSON.")
    parser.add_argument("--output-dir", help="Optional output directory for validation artifacts.")
    parser.add_argument("--phase1-core-packet", help="Optional Phase 1 core packet JSON for compatibility check.")
    parser.add_argument(
        "--phase1-extended-packet",
        help="Optional Phase 1 extended packet JSON for compatibility check.",
    )
    args = parser.parse_args()

    tool_dir = Path(__file__).resolve().parent
    phase2_root = tool_dir.parent
    ai_root = phase2_root.parent
    terminal_root = ai_root.parents[2]
    files_ai_root = terminal_root / "MQL5" / "Files" / "AI"

    output_dir = Path(args.output_dir) if args.output_dir else files_ai_root / "atas_micro_phase2_validation"
    output_dir.mkdir(parents=True, exist_ok=True)

    candidate_path = Path(args.candidate_bundle).resolve()
    interfaces_path = phase2_root / "interfaces" / "state_interface_scaffolding_v1.json"
    schema_path = phase2_root / "schemas" / "state_bundle_phase2_kickoff_v1.schema.json"
    phase1_core_schema = (
        ai_root / "docs" / "atas_microstructure_phase0_phase1_v1" / "schemas" / "context_packet_core_v1.schema.json"
    )
    phase1_extended_schema = (
        ai_root
        / "docs"
        / "atas_microstructure_phase0_phase1_v1"
        / "schemas"
        / "context_packet_extended_v1.schema.json"
    )

    candidate = read_json(candidate_path)
    interfaces = read_json(interfaces_path)
    state_schema = read_json(schema_path)

    report: dict[str, Any] = {
        "validator_version": "ATAS_PHASE2_KICKOFF_VALIDATOR_V1",
        "evaluated_at_utc": utc_now_iso(),
        "candidate_path": str(candidate_path),
        "result": "PASS",
        "errors": [],
        "warnings": []
    }

    schema_errors = validate_with_jsonschema(candidate, state_schema)
    if jsonschema is None:
        schema_errors = manual_required_checks(candidate, state_schema)
    if schema_errors:
        report["errors"].extend([f"state_bundle_schema: {e}" for e in schema_errors])

    bundle_errors, bundle_warnings, family_reports = validate_state_bundle(candidate, interfaces)
    report["errors"].extend(bundle_errors)
    report["warnings"].extend(bundle_warnings)
    report["family_reports"] = family_reports

    core_status, core_errors = validate_phase1_packet(
        Path(args.phase1_core_packet).resolve() if args.phase1_core_packet else None,
        phase1_core_schema,
        "phase1_core_packet",
    )
    extended_status, extended_errors = validate_phase1_packet(
        Path(args.phase1_extended_packet).resolve() if args.phase1_extended_packet else None,
        phase1_extended_schema,
        "phase1_extended_packet",
    )
    report["phase1_compatibility"] = {
        "core_packet_check": {"status": core_status, "errors": core_errors},
        "extended_packet_check": {"status": extended_status, "errors": extended_errors}
    }

    report["telemetry"] = build_telemetry(candidate, family_reports)

    if report["errors"]:
        report["result"] = "FAIL"
    elif core_status == "FAIL" or extended_status == "FAIL":
        report["result"] = "FAIL"
    elif report["warnings"]:
        report["result"] = "PASS_WITH_WARNINGS"
    else:
        report["result"] = "PASS"

    latest_path = output_dir / "phase2_state_validation_latest.json"
    stream_path = output_dir / "phase2_state_validation_stream.jsonl"
    write_json(latest_path, report)
    append_jsonl(stream_path, report)

    phase1_error_count = len(core_errors) + len(extended_errors)
    print(json.dumps(
        {
            "result": report["result"],
            "latest_report": str(latest_path),
            "stream_report": str(stream_path),
            "error_count": len(report["errors"]),
            "phase1_error_count": phase1_error_count,
            "warning_count": len(report["warnings"]),
        },
        indent=2,
    ))

    return 0 if report["result"] in {"PASS", "PASS_WITH_WARNINGS"} else 2


if __name__ == "__main__":
    sys.exit(main())
