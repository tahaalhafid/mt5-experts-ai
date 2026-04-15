from __future__ import annotations

import json
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


def utc_now() -> datetime:
    return datetime.now(UTC)


def utc_now_iso() -> str:
    return utc_now().isoformat().replace("+00:00", "Z")


def parse_ts(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    if " " in text and "T" not in text:
        text = text.replace(" ", "T", 1)
    try:
        dt = datetime.fromisoformat(text)
    except ValueError:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=UTC)
    return dt.astimezone(UTC)


def file_meta(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {
            "path": str(path),
            "exists": False,
            "mtime_utc": None,
            "age_seconds": None,
            "size_bytes": 0,
        }
    stat = path.stat()
    mtime = datetime.fromtimestamp(stat.st_mtime, tz=UTC)
    age = int((utc_now() - mtime).total_seconds())
    return {
        "path": str(path),
        "exists": True,
        "mtime_utc": mtime.isoformat().replace("+00:00", "Z"),
        "age_seconds": max(age, 0),
        "size_bytes": int(stat.st_size),
    }


def read_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    try:
        parsed = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return {}
    return parsed if isinstance(parsed, dict) else {}


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def write_json(path: Path, payload: dict[str, Any]) -> None:
    ensure_parent(path)
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def append_jsonl(path: Path, payload: dict[str, Any]) -> None:
    ensure_parent(path)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(payload, separators=(",", ":")) + "\n")


def g(data: dict[str, Any], *keys: str) -> Any:
    cur: Any = data
    for key in keys:
        if not isinstance(cur, dict) or key not in cur:
            return None
        cur = cur[key]
    return cur


def choose_value(candidates: list[tuple[str, Any]]) -> tuple[Any, str]:
    for source, value in candidates:
        if value is None:
            continue
        if isinstance(value, str) and not value.strip():
            continue
        return value, source
    return None, "UNAVAILABLE"


def freshness_from_times(event_time: Any, fresh_until: Any, fallback_age: Any = None) -> dict[str, Any]:
    now = utc_now()
    event_dt = parse_ts(event_time)
    fresh_dt = parse_ts(fresh_until)

    state = "UNKNOWN"
    reason = "FRESHNESS_UNKNOWN"
    age_seconds = None
    margin_seconds = None

    if event_dt is not None:
        age_seconds = int((now - event_dt).total_seconds())
    if fresh_dt is not None:
        margin_seconds = int((fresh_dt - now).total_seconds())
        if margin_seconds >= 0:
            state = "FRESH"
            reason = "FRESHNESS_FRESH"
        else:
            state = "EXPIRED"
            reason = "FRESHNESS_EXPIRED"
    elif isinstance(age_seconds, int):
        if age_seconds <= 60:
            state = "FRESH"
            reason = "FRESHNESS_FRESH_EVENT_AGE"
        elif age_seconds <= 300:
            state = "STALE"
            reason = "FRESHNESS_STALE_EVENT_AGE"
        else:
            state = "EXPIRED"
            reason = "FRESHNESS_EXPIRED_EVENT_AGE"
    elif isinstance(fallback_age, int):
        if fallback_age <= 60:
            state = "FRESH"
            reason = "FRESHNESS_FRESH_FILE_AGE"
        elif fallback_age <= 300:
            state = "STALE"
            reason = "FRESHNESS_STALE_FILE_AGE"
        else:
            state = "EXPIRED"
            reason = "FRESHNESS_EXPIRED_FILE_AGE"

    return {
        "freshness_state": state,
        "freshness_reason": reason,
        "event_time_utc": event_dt.isoformat().replace("+00:00", "Z") if event_dt else None,
        "fresh_until_utc": fresh_dt.isoformat().replace("+00:00", "Z") if fresh_dt else None,
        "event_age_seconds": age_seconds,
        "fresh_margin_seconds": margin_seconds,
    }


def first_present(payload: dict[str, Any], keys: list[str]) -> Any:
    for key in keys:
        parts = key.split(".")
        value = g(payload, *parts)
        if value is None:
            continue
        if isinstance(value, str) and not value.strip():
            continue
        return value
    return None


def classify_source_state(
    source_name: str,
    payload: dict[str, Any],
    meta: dict[str, Any],
    required_fields: list[str],
    event_candidates: list[str],
    fresh_candidates: list[str],
) -> dict[str, Any]:
    if not bool(meta.get("exists")):
        return {
            "source_name": source_name,
            "state": "MISSING",
            "reason": "SOURCE_FILE_MISSING",
            "coverage_ratio": 0.0,
            "required_missing": required_fields,
            "freshness": freshness_from_times(None, None, None),
            "usability_state": "UNUSABLE",
        }

    event_time = first_present(payload, event_candidates)
    fresh_until = first_present(payload, fresh_candidates)
    freshness = freshness_from_times(event_time, fresh_until, meta.get("age_seconds"))

    if not payload:
        return {
            "source_name": source_name,
            "state": "PARTIAL_BUT_DEGRADED",
            "reason": "SOURCE_PRESENT_BUT_EMPTY_OR_UNPARSABLE",
            "coverage_ratio": 0.0,
            "required_missing": required_fields,
            "freshness": freshness,
            "usability_state": "DEGRADED",
        }

    missing = []
    present = 0
    for field in required_fields:
        value = g(payload, *field.split("."))
        if value is None or (isinstance(value, str) and not value.strip()):
            missing.append(field)
        else:
            present += 1
    coverage = present / max(len(required_fields), 1)

    state = "PARTIAL_BUT_DEGRADED"
    reason = "SOURCE_PARTIAL"
    usability = "DEGRADED"
    fs = freshness["freshness_state"]
    if fs == "FRESH" and coverage >= 0.8:
        state = "FRESH"
        reason = "SOURCE_FRESH_AND_COMPLETE"
        usability = "USABLE"
    elif fs == "FRESH" and coverage >= 0.4:
        state = "PARTIAL_BUT_USABLE"
        reason = "SOURCE_FRESH_BUT_PARTIAL"
        usability = "USABLE_WITH_GAPS"
    elif fs == "STALE" and coverage >= 0.6:
        state = "STALE"
        reason = "SOURCE_STALE_BUT_MOSTLY_COMPLETE"
        usability = "DEGRADED"
    elif fs == "EXPIRED":
        state = "EXPIRED"
        reason = "SOURCE_EXPIRED"
        usability = "DEGRADED"
    elif coverage <= 0.0:
        state = "MISSING"
        reason = "SOURCE_REQUIRED_FIELDS_MISSING"
        usability = "UNUSABLE"

    return {
        "source_name": source_name,
        "state": state,
        "reason": reason,
        "coverage_ratio": round(coverage, 4),
        "required_missing": missing,
        "freshness": freshness,
        "usability_state": usability,
        "packet_id": (
            g(payload, "packet_id")
            or g(payload, "acquisition_event_id")
            or g(payload, "last_packet_id")
        ),
        "source_packet_id": g(payload, "source_packet_id"),
        "trace_id": g(payload, "trace_id") or g(payload, "source_trace_id"),
    }


def source_state_reason_code(source_name: str, source_state: str) -> str:
    normalized_name = source_name.upper().replace(" ", "_")
    normalized_state = source_state.upper().replace("-", "_")
    return f"SOURCE_{normalized_name}_{normalized_state}"


def family_usability_state(
    freshness_state: str,
    completeness_ratio: float,
    source_state_values: list[str],
) -> str:
    missing_any = any(s == "MISSING" for s in source_state_values)
    expired_any = any(s == "EXPIRED" for s in source_state_values)
    partial_any = any(s in {"PARTIAL_BUT_USABLE", "PARTIAL_BUT_DEGRADED"} for s in source_state_values)

    if missing_any and completeness_ratio < 0.4:
        return "MISSING"
    if freshness_state == "FRESH" and completeness_ratio >= 0.85 and not partial_any:
        return "FRESH"
    if freshness_state == "FRESH" and completeness_ratio >= 0.6:
        return "PARTIAL_BUT_USABLE"
    if freshness_state == "STALE":
        return "STALE" if completeness_ratio >= 0.6 else "PARTIAL_BUT_DEGRADED"
    if freshness_state == "EXPIRED" or expired_any:
        return "EXPIRED" if completeness_ratio >= 0.6 else "PARTIAL_BUT_DEGRADED"
    return "PARTIAL_BUT_DEGRADED"


def extract_lineage_ids(payload: dict[str, Any], paths: list[str]) -> list[str]:
    values: list[str] = []
    for path in paths:
        value = first_present(payload, [path])
        if value is None:
            continue
        normalized = str(value).strip()
        if not normalized:
            continue
        if normalized not in values:
            values.append(normalized)
    return values


def parse_stage_event_dt(payload: dict[str, Any]) -> datetime | None:
    return parse_ts(
        first_present(
            payload,
            [
                "event_time",
                "created_time",
                "last_run_timestamp",
                "evaluated_at",
                "status_timestamp_utc",
                "status_timestamp",
            ],
        )
    )


def parse_stage_fresh_dt(payload: dict[str, Any]) -> datetime | None:
    return parse_ts(first_present(payload, ["fresh_until"]))


def lineage_transition_detail(
    upstream_ids: list[str],
    downstream_ids: list[str],
    downstream_source_ids: list[str],
) -> dict[str, Any]:
    left = set(upstream_ids)
    right = set(downstream_ids)
    right_src = set(downstream_source_ids)
    if not left:
        return {
            "state": "MISSING",
            "reason": "UPSTREAM_PACKET_ID_MISSING",
        }
    if not right and not right_src:
        return {
            "state": "MISSING",
            "reason": "DOWNSTREAM_PACKET_ID_MISSING",
        }
    if left.intersection(right):
        return {
            "state": "MATCH_DIRECT",
            "reason": "PACKET_ID_MATCH_DIRECT",
        }
    if left.intersection(right_src):
        return {
            "state": "MATCH_VIA_LINEAGE",
            "reason": "PACKET_ID_MATCH_VIA_SOURCE_LINKAGE",
        }
    if right and right_src:
        return {
            "state": "DIVERGED",
            "reason": "DOWNSTREAM_PACKET_AND_SOURCE_PACKET_BOTH_MISMATCH",
        }
    if right:
        return {
            "state": "DIVERGED",
            "reason": "DOWNSTREAM_PACKET_ID_MISMATCH",
        }
    return {
        "state": "PARTIAL_INCOMPLETE",
        "reason": "ONLY_SOURCE_LINKAGE_PRESENT",
    }


def stage_timing_detail(
    upstream_payload: dict[str, Any],
    downstream_payload: dict[str, Any],
) -> dict[str, Any]:
    up_event = parse_stage_event_dt(upstream_payload)
    down_event = parse_stage_event_dt(downstream_payload)
    up_fresh = parse_stage_fresh_dt(upstream_payload)
    down_fresh = parse_stage_fresh_dt(downstream_payload)
    if up_event is None or down_event is None:
        return {
            "alignment_state": "UNKNOWN",
            "reason": "EVENT_TIME_MISSING",
            "event_lag_seconds": None,
            "fresh_margin_delta_seconds": None,
        }
    event_lag = int((down_event - up_event).total_seconds())
    fresh_delta = None
    if up_fresh is not None and down_fresh is not None:
        fresh_delta = int((down_fresh - up_fresh).total_seconds())

    if event_lag < 0:
        state = "REORDERED_OR_CLOCK_SKEW"
        reason = "DOWNSTREAM_EVENT_TIME_BEFORE_UPSTREAM"
    elif event_lag <= 60:
        state = "ALIGNED"
        reason = "EVENT_TIME_LAG_WITHIN_60S"
    elif event_lag <= 180:
        state = "DELAYED_BUT_USABLE"
        reason = "EVENT_TIME_LAG_WITHIN_180S"
    else:
        state = "DELAYED_EXCESSIVE"
        reason = "EVENT_TIME_LAG_GT_180S"
    return {
        "alignment_state": state,
        "reason": reason,
        "event_lag_seconds": event_lag,
        "fresh_margin_delta_seconds": fresh_delta,
    }


def build_lineage_continuity_summary(
    source_data: dict[str, dict[str, Any]],
    source_assessments: dict[str, dict[str, Any]],
) -> dict[str, Any]:
    observation_payload = source_data.get("observation", {})
    acquisition_payload = source_data.get("acquisition_input", {})
    producer_payload = source_data.get("producer_input", {})
    runtime_payload = source_data.get("runtime_context", {})
    status_payload = source_data.get("runtime_context_status", {})

    observation_ids = extract_lineage_ids(
        observation_payload,
        ["packet_id", "acquisition_event_id"],
    )
    acquisition_ids = extract_lineage_ids(
        acquisition_payload,
        ["packet_id", "acquisition_event_id"],
    )
    acquisition_source_ids = extract_lineage_ids(
        acquisition_payload,
        ["source_packet_id"],
    )
    producer_ids = extract_lineage_ids(
        producer_payload,
        ["packet_id"],
    )
    producer_source_ids = extract_lineage_ids(
        producer_payload,
        ["source_packet_id", "acquisition_event_id"],
    )
    runtime_ids = extract_lineage_ids(
        runtime_payload,
        ["packet_id"],
    )
    status_ids = extract_lineage_ids(
        status_payload,
        ["packet_id", "last_packet_id"],
    )

    transitions = {
        "observation_to_acquisition": lineage_transition_detail(
            observation_ids,
            acquisition_ids,
            acquisition_source_ids,
        ),
        "acquisition_to_producer": lineage_transition_detail(
            acquisition_ids if acquisition_ids else acquisition_source_ids,
            producer_ids,
            producer_source_ids,
        ),
        "producer_to_runtime": lineage_transition_detail(
            producer_ids,
            runtime_ids,
            [],
        ),
        "runtime_to_status": lineage_transition_detail(
            runtime_ids,
            status_ids,
            [],
        ),
    }
    timing = {
        "observation_to_acquisition": stage_timing_detail(observation_payload, acquisition_payload),
        "acquisition_to_producer": stage_timing_detail(acquisition_payload, producer_payload),
        "producer_to_runtime": stage_timing_detail(producer_payload, runtime_payload),
        "runtime_to_status": stage_timing_detail(runtime_payload, status_payload),
    }

    first_break = "NONE"
    for stage, detail in transitions.items():
        if detail.get("state") not in {"MATCH_DIRECT", "MATCH_VIA_LINEAGE"}:
            first_break = stage
            break

    runtime_state = source_assessments.get("runtime_context", {}).get("state", "MISSING")
    status_state = source_assessments.get("runtime_context_status", {}).get("state", "MISSING")
    source_states = [x.get("state", "MISSING") for x in source_assessments.values()]

    transition_states = [str(v.get("state", "UNKNOWN")) for v in transitions.values()]
    all_matched = all(s in {"MATCH_DIRECT", "MATCH_VIA_LINEAGE"} for s in transition_states)
    any_missing = any(s == "MISSING" for s in transition_states)
    any_diverged = any(s == "DIVERGED" for s in transition_states)
    any_timing_excessive = any(
        str(v.get("alignment_state", "UNKNOWN")) in {"DELAYED_EXCESSIVE", "REORDERED_OR_CLOCK_SKEW"}
        for v in timing.values()
    )

    if all_matched and runtime_state == "FRESH" and status_state in {"FRESH", "PARTIAL_BUT_USABLE"} and not any_timing_excessive:
        lineage_state = "COHERENT_FRESH"
        reason = "LINEAGE_ALIGNED_AND_FRESH"
    elif all_matched and (runtime_state in {"STALE", "EXPIRED"} or status_state in {"STALE", "EXPIRED"}):
        lineage_state = "COHERENT_BUT_LOW_FRESHNESS"
        reason = "LINEAGE_ALIGNED_BUT_STALE_OR_EXPIRED"
    elif any_missing or any(s == "MISSING" for s in source_states):
        lineage_state = "PARTIAL_INCOMPLETE"
        reason = "LINEAGE_MISSING_STAGE_DATA"
    elif any_diverged:
        lineage_state = "DIVERGED"
        reason = "LINEAGE_PACKET_ID_MISMATCH"
    elif any_timing_excessive:
        lineage_state = "PARTIAL_INCOMPLETE"
        reason = "LINEAGE_TIMING_ALIGNMENT_DEGRADED"
    else:
        lineage_state = "DIVERGED"
        reason = "LINEAGE_PACKET_ID_MISMATCH"

    return {
        "lineage_state": lineage_state,
        "lineage_reason": reason,
        "first_break_stage": first_break,
        "packet_chain": {
            "observation_packet_ids": observation_ids,
            "acquisition_packet_ids": acquisition_ids,
            "acquisition_source_packet_ids": acquisition_source_ids,
            "producer_packet_ids": producer_ids,
            "producer_source_packet_ids": producer_source_ids,
            "runtime_packet_ids": runtime_ids,
            "status_packet_ids": status_ids,
        },
        "transitions": transitions,
        "timing_alignment": timing,
    }


def build_source_completeness_summary(source_assessments: dict[str, dict[str, Any]]) -> dict[str, Any]:
    ratios = [float(v.get("coverage_ratio", 0.0)) for v in source_assessments.values()]
    avg = sum(ratios) / max(len(ratios), 1)
    state_counts: dict[str, int] = {}
    for v in source_assessments.values():
        state = str(v.get("state", "UNKNOWN"))
        state_counts[state] = state_counts.get(state, 0) + 1
    return {
        "average_source_coverage_ratio": round(avg, 4),
        "source_state_counts": state_counts,
        "sources": source_assessments,
    }


def build_freshness_summary(
    source_assessments: dict[str, dict[str, Any]],
    families: dict[str, "FamilyResult"],
) -> dict[str, Any]:
    source_freshness = {
        name: s.get("freshness", {}).get("freshness_state", "UNKNOWN")
        for name, s in source_assessments.items()
    }
    family_freshness = {
        name: f.metadata.get("freshness", {}).get("freshness_state", "UNKNOWN")
        for name, f in families.items()
    }
    counts: dict[str, int] = {}
    for state in list(source_freshness.values()) + list(family_freshness.values()):
        counts[state] = counts.get(state, 0) + 1
    return {
        "source_freshness_states": source_freshness,
        "family_freshness_states": family_freshness,
        "freshness_state_counts": counts,
        "early_stage_alignment": {
            "observation": source_freshness.get("observation", "UNKNOWN"),
            "acquisition_input": source_freshness.get("acquisition_input", "UNKNOWN"),
            "producer_input": source_freshness.get("producer_input", "UNKNOWN"),
            "alignment_state": (
                "SOURCE_FRESH_DOWNSTREAM_DELAYED"
                if source_freshness.get("observation") == "FRESH"
                and source_freshness.get("acquisition_input") in {"STALE", "EXPIRED"}
                else "SOURCE_STALE_AT_ORIGIN"
                if source_freshness.get("observation") in {"STALE", "EXPIRED"}
                else "ALIGNED"
                if source_freshness.get("observation") == source_freshness.get("acquisition_input")
                else "PARTIAL_OR_MIXED"
            ),
        },
    }


def build_blocker_consolidation_summary(
    source_assessments: dict[str, dict[str, Any]],
    lineage_summary: dict[str, Any],
    freshness_summary: dict[str, Any],
) -> dict[str, Any]:
    blockers: list[dict[str, Any]] = []
    transitions = lineage_summary.get("transitions", {})
    timing = lineage_summary.get("timing_alignment", {})
    source_states = {k: str(v.get("state", "UNKNOWN")) for k, v in source_assessments.items()}

    obs_to_acq = transitions.get("observation_to_acquisition", {})
    obs_to_acq_state = str(obs_to_acq.get("state", "UNKNOWN"))
    if obs_to_acq_state not in {"MATCH_DIRECT", "MATCH_VIA_LINEAGE"}:
        blockers.append(
            {
                "blocker_id": "B001_OBSERVATION_TO_ACQUISITION_CONTINUITY",
                "severity": "HIGH",
                "status": "OPEN",
                "fixability": "FIXABLE_NOW",
                "evidence": {
                    "transition_state": obs_to_acq_state,
                    "transition_reason": obs_to_acq.get("reason"),
                },
            }
        )

    obs_to_acq_timing = timing.get("observation_to_acquisition", {})
    obs_to_acq_timing_state = str(obs_to_acq_timing.get("alignment_state", "UNKNOWN"))
    if obs_to_acq_timing_state in {"DELAYED_EXCESSIVE", "REORDERED_OR_CLOCK_SKEW"}:
        blockers.append(
            {
                "blocker_id": "B002_EARLY_STAGE_TIMING_ALIGNMENT",
                "severity": "HIGH",
                "status": "OPEN",
                "fixability": "PARTIALLY_FIXABLE_NOW",
                "evidence": {
                    "timing_state": obs_to_acq_timing_state,
                    "timing_reason": obs_to_acq_timing.get("reason"),
                    "event_lag_seconds": obs_to_acq_timing.get("event_lag_seconds"),
                },
            }
        )

    early_alignment = freshness_summary.get("early_stage_alignment", {})
    if early_alignment.get("alignment_state") in {"SOURCE_FRESH_DOWNSTREAM_DELAYED", "PARTIAL_OR_MIXED"}:
        blockers.append(
            {
                "blocker_id": "B003_EARLY_STAGE_FRESHNESS_MISALIGNMENT",
                "severity": "HIGH",
                "status": "OPEN",
                "fixability": "PARTIALLY_FIXABLE_NOW",
                "evidence": early_alignment,
            }
        )

    for source_name in ("observation", "acquisition_input", "producer_input"):
        source_state = source_states.get(source_name, "UNKNOWN")
        if source_state in {"MISSING", "PARTIAL_BUT_DEGRADED"}:
            blockers.append(
                {
                    "blocker_id": f"B004_SOURCE_COMPLETENESS_{source_name.upper()}",
                    "severity": "MEDIUM",
                    "status": "OPEN",
                    "fixability": "SOURCE_LIMITED_OR_FIXABLE_NOW",
                    "evidence": source_assessments.get(source_name, {}),
                }
            )

    lineage_state = str(lineage_summary.get("lineage_state", "UNKNOWN"))
    if lineage_state in {"PARTIAL_INCOMPLETE", "DIVERGED"}:
        blockers.append(
            {
                "blocker_id": "B005_LINEAGE_CONTINUITY_NOT_STABLE",
                "severity": "HIGH",
                "status": "OPEN",
                "fixability": "PARTIALLY_FIXABLE_NOW",
                "evidence": {
                    "lineage_state": lineage_state,
                    "lineage_reason": lineage_summary.get("lineage_reason"),
                    "first_break_stage": lineage_summary.get("first_break_stage"),
                },
            }
        )

    if not blockers:
        blockers.append(
            {
                "blocker_id": "B000_NO_BLOCKER",
                "severity": "LOW",
                "status": "CLOSED",
                "fixability": "N/A",
                "evidence": {
                    "note": "No open continuity/freshness/lineage blockers detected in current snapshot.",
                },
            }
        )

    return {
        "summary_version": "ATAS_PHASE3_CLOSURE_BLOCKER_CONSOLIDATION_V1",
        "generated_at_utc": utc_now_iso(),
        "blocker_count": len([b for b in blockers if b.get("status") == "OPEN"]),
        "blockers": blockers,
    }


def build_source_assessments(
    source_data: dict[str, dict[str, Any]],
    source_meta: dict[str, dict[str, Any]],
) -> dict[str, dict[str, Any]]:
    specs: dict[str, dict[str, Any]] = {
        "runtime_context": {
            "required_fields": [
                "packet_id",
                "event_time",
                "fresh_until",
                "data_quality_state",
            ],
            "event_candidates": ["event_time", "created_time"],
            "fresh_candidates": ["fresh_until"],
        },
        "runtime_context_status": {
            "required_fields": [
                "packet_id",
                "freshness_state",
                "quality_state",
                "shadow_attached",
            ],
            "event_candidates": ["evaluated_at", "status_timestamp_utc", "status_timestamp"],
            "fresh_candidates": [],
        },
        "advisory_status": {
            "required_fields": [
                "advisory_packet_id",
                "freshness_state",
                "advisory_eligible",
                "gate_reason_code",
            ],
            "event_candidates": ["evaluated_at"],
            "fresh_candidates": [],
        },
        "observation": {
            "required_fields": [
                "packet_id",
                "event_time",
                "fresh_until",
                "quality_state",
                "microstructure_observation",
            ],
            "event_candidates": ["event_time", "created_time"],
            "fresh_candidates": ["fresh_until"],
        },
        "acquisition_input": {
            "required_fields": [
                "packet_id",
                "acquisition_event_id",
                "source_packet_id",
                "event_time",
                "fresh_until",
                "quality_state",
                "microstructure_observation",
            ],
            "event_candidates": ["event_time", "created_time"],
            "fresh_candidates": ["fresh_until"],
        },
        "producer_input": {
            "required_fields": [
                "packet_id",
                "source_packet_id",
                "acquisition_event_id",
                "event_time",
                "fresh_until",
                "data_quality_state",
                "microstructure",
            ],
            "event_candidates": ["event_time", "created_time"],
            "fresh_candidates": ["fresh_until"],
        },
        "exporter_status": {
            "required_fields": [
                "packet_id",
                "last_run_timestamp",
                "write_status",
            ],
            "event_candidates": ["last_run_timestamp"],
            "fresh_candidates": [],
        },
        "adapter_status": {
            "required_fields": [
                "last_packet_id",
                "last_run_timestamp",
                "freshness_state",
                "quality_state",
            ],
            "event_candidates": ["last_run_timestamp"],
            "fresh_candidates": [],
        },
    }

    assessments: dict[str, dict[str, Any]] = {}
    for source_name, payload in source_data.items():
        spec = specs.get(
            source_name,
            {
                "required_fields": [],
                "event_candidates": [],
                "fresh_candidates": [],
            },
        )
        assessments[source_name] = classify_source_state(
            source_name=source_name,
            payload=payload,
            meta=source_meta.get(source_name, {}),
            required_fields=spec.get("required_fields", []),
            event_candidates=spec.get("event_candidates", []),
            fresh_candidates=spec.get("fresh_candidates", []),
        )
    return assessments


def quality_score(label: str) -> float:
    m = {"HIGH": 1.0, "MEDIUM": 0.7, "LOW": 0.35, "UNKNOWN": 0.5}
    return m.get(label.upper(), 0.5)


def quality_band(label: str, freshness_state: str, completeness: float) -> str:
    base = quality_score(label)
    if freshness_state == "EXPIRED":
        base *= 0.45
    elif freshness_state == "STALE":
        base *= 0.7
    base *= completeness
    if base >= 0.75:
        return "GOOD"
    if base >= 0.45:
        return "MEDIUM"
    return "LOW"


def str_upper(value: Any) -> str:
    if isinstance(value, str):
        return value.strip().upper()
    return ""


def bool_value(value: Any, default: bool = False) -> bool:
    if isinstance(value, bool):
        return value
    return default


@dataclass
class FamilyResult:
    family_name: str
    candidate_fields: dict[str, Any]
    metadata: dict[str, Any]
    reason_codes: list[str]
    trace_summary: dict[str, Any]

    def as_dict(self) -> dict[str, Any]:
        return {
            "family_name": self.family_name,
            "candidate_fields": self.candidate_fields,
            "metadata": self.metadata,
            "reason_codes": self.reason_codes,
            "trace_summary": self.trace_summary,
        }


class MapperContext:
    def __init__(
        self,
        sources: dict[str, dict[str, Any]],
        source_meta: dict[str, dict[str, Any]],
        source_assessments: dict[str, dict[str, Any]],
    ) -> None:
        self.sources = sources
        self.source_meta = source_meta
        self.source_assessments = source_assessments

    def source(self, key: str) -> dict[str, Any]:
        return self.sources.get(key, {})

    def meta(self, key: str) -> dict[str, Any]:
        return self.source_meta.get(key, {})

    def source_state(self, key: str) -> dict[str, Any]:
        return self.source_assessments.get(key, {})


class OrderFlowStateMapper:
    def map(self, ctx: MapperContext) -> FamilyResult:
        runtime = ctx.source("runtime_context")
        obs = ctx.source("observation")
        acq = ctx.source("acquisition_input")
        adv = ctx.source("advisory_status")
        status = ctx.source("runtime_context_status")

        absorption, src_abs = choose_value(
            [
                ("runtime_context.absorption_state", g(runtime, "absorption_state")),
                ("observation.microstructure_observation.absorption_state", g(obs, "microstructure_observation", "absorption_state")),
                ("acquisition_input.microstructure_observation.absorption_state", g(acq, "microstructure_observation", "absorption_state")),
            ]
        )
        imbalance, src_imb = choose_value(
            [
                ("runtime_context.imbalance_state", g(runtime, "imbalance_state")),
                ("observation.microstructure_observation.imbalance_state", g(obs, "microstructure_observation", "imbalance_state")),
                ("acquisition_input.microstructure_observation.imbalance_state", g(acq, "microstructure_observation", "imbalance_state")),
            ]
        )
        delta_bias, src_delta = choose_value(
            [
                ("runtime_context.delta_bias_state", g(runtime, "delta_bias_state")),
                ("observation.microstructure_observation.delta_bias_state", g(obs, "microstructure_observation", "delta_bias_state")),
                ("acquisition_input.microstructure_observation.delta_bias_state", g(acq, "microstructure_observation", "delta_bias_state")),
            ]
        )
        sweep, src_sweep = choose_value(
            [
                ("runtime_context.liquidity_sweep_state", g(runtime, "liquidity_sweep_state")),
                ("observation.microstructure_observation.liquidity_sweep_state", g(obs, "microstructure_observation", "liquidity_sweep_state")),
                ("acquisition_input.microstructure_observation.liquidity_sweep_state", g(acq, "microstructure_observation", "liquidity_sweep_state")),
            ]
        )
        exhaustion, src_exh = choose_value(
            [
                ("runtime_context.continuation_exhaustion_hint", g(runtime, "continuation_exhaustion_hint")),
                ("observation.microstructure_observation.continuation_exhaustion_hint", g(obs, "microstructure_observation", "continuation_exhaustion_hint")),
                ("acquisition_input.microstructure_observation.continuation_exhaustion_hint", g(acq, "microstructure_observation", "continuation_exhaustion_hint")),
            ]
        )

        aggression_state = "AGGRESSION_BALANCED"
        if "POSITIVE" in str_upper(delta_bias) and "BUY" in str_upper(imbalance):
            aggression_state = "AGGRESSION_BUY_PRESSURE"
        elif "NEGATIVE" in str_upper(delta_bias) and "SELL" in str_upper(imbalance):
            aggression_state = "AGGRESSION_SELL_PRESSURE"

        passivity_state = "PASSIVITY_UNKNOWN"
        abs_u = str_upper(absorption)
        if "BID" in abs_u:
            passivity_state = "PASSIVE_BID_DEFENSE"
        elif "ASK" in abs_u:
            passivity_state = "PASSIVE_ASK_DEFENSE"

        initiative_response_state = "INITIATIVE_RESPONSE_BALANCED"
        if "SWEEP" in str_upper(sweep) and "ABSORPTION" in abs_u:
            initiative_response_state = "INITIATIVE_RESPONSE_SWEEP_ABSORPTION"
        elif "NO_SWEEP" in str_upper(sweep) and "LOW" in str_upper(exhaustion):
            initiative_response_state = "INITIATIVE_RESPONSE_CONTINUATION"
        elif "SWEEP" in str_upper(sweep):
            initiative_response_state = "INITIATIVE_RESPONSE_VOLATILE"

        candidates = g(obs, "level_behavior_candidates")
        if not isinstance(candidates, list):
            candidates = g(acq, "level_behavior_candidates")
        reaction_quality_state = "REACTION_QUALITY_NOT_DERIVABLE"
        if isinstance(candidates, list) and candidates:
            strengths = [float(x.get("reaction_strength", 0.0)) for x in candidates if isinstance(x, dict)]
            avg = sum(strengths) / len(strengths) if strengths else 0.0
            if avg >= 0.65:
                reaction_quality_state = "REACTION_QUALITY_STRONG"
            elif avg >= 0.45:
                reaction_quality_state = "REACTION_QUALITY_MODERATE"
            else:
                reaction_quality_state = "REACTION_QUALITY_WEAK"
        elif bool_value(g(adv, "level_context_supportive")) and not bool_value(g(adv, "level_context_degraded")):
            reaction_quality_state = "REACTION_QUALITY_CONTEXT_SUPPORTIVE"

        mandatory_values = {
            "aggression_state": aggression_state,
            "passivity_state": passivity_state,
            "absorption_state": absorption or "UNKNOWN",
            "exhaustion_state": exhaustion or "UNKNOWN",
            "imbalance_state": imbalance or "UNKNOWN",
            "initiative_response_state": initiative_response_state,
            "reaction_quality_state": reaction_quality_state,
        }
        field_available = {
            "aggression_state": (delta_bias is not None and imbalance is not None),
            "passivity_state": (absorption is not None),
            "absorption_state": (src_abs != "UNAVAILABLE"),
            "exhaustion_state": (src_exh != "UNAVAILABLE"),
            "imbalance_state": (src_imb != "UNAVAILABLE"),
            "initiative_response_state": (src_sweep != "UNAVAILABLE"),
            "reaction_quality_state": (reaction_quality_state != "REACTION_QUALITY_NOT_DERIVABLE"),
        }
        available_count = len([1 for _, ok in field_available.items() if ok])
        completeness = available_count / max(len(mandatory_values), 1)

        freshness = freshness_from_times(
            g(runtime, "event_time"),
            g(runtime, "fresh_until"),
            ctx.meta("runtime_context").get("age_seconds"),
        )
        qlabel = (
            str(g(status, "quality_state") or g(runtime, "data_quality_state") or g(acq, "quality_state") or "UNKNOWN")
        ).upper()
        fgq = quality_band(qlabel, freshness["freshness_state"], completeness)

        reason_codes = [
            "BOUNDARY_OK_NON_AUTHORITATIVE",
            "ORDERFLOW_MICROSTRUCTURE_SOURCE_RUNTIME_CONTEXT" if src_abs.startswith("runtime_context") else "ORDERFLOW_MICROSTRUCTURE_SOURCE_OBSERVATION",
            "ORDERFLOW_INITIATIVE_RESPONSE_INFERRED",
            "FIELD_DIRECT",
            f"FRESHNESS_{freshness['freshness_state']}",
            f"QUALITY_{fgq}",
        ]
        source_states = {
            "runtime_context": ctx.source_state("runtime_context").get("state", "MISSING"),
            "observation": ctx.source_state("observation").get("state", "MISSING"),
            "advisory_status": ctx.source_state("advisory_status").get("state", "MISSING"),
        }
        for source_name, state in source_states.items():
            reason_codes.append(source_state_reason_code(source_name, state))
        if reaction_quality_state == "REACTION_QUALITY_NOT_DERIVABLE":
            reason_codes.append("ORDERFLOW_REACTION_QUALITY_NOT_DERIVABLE")
            reason_codes.append("FIELD_NOT_SUPPORTED_BY_CURRENT_SOURCES")
        else:
            reason_codes.append("ORDERFLOW_REACTION_QUALITY_FROM_LEVEL_BEHAVIOR")
        if freshness["freshness_state"] in {"STALE", "EXPIRED"}:
            reason_codes.append("PRESENT_BUT_LOW_FRESHNESS")
        if fgq == "LOW":
            reason_codes.append("PRESENT_BUT_LOW_QUALITY")

        candidate_fields = {
            **mandatory_values,
            "field_group_quality": fgq,
            "source_lineage_packet_id": g(runtime, "packet_id") or g(obs, "packet_id"),
            "source_lineage_trace_id": g(status, "trace_id") or g(obs, "trace_id"),
        }
        family_usability = family_usability_state(
            freshness["freshness_state"],
            completeness,
            list(source_states.values()),
        )
        completeness_bucket = (
            "COMPLETE"
            if completeness >= 0.90
            else "PARTIAL_HIGH" if completeness >= 0.70 else "PARTIAL_LOW"
        )
        metadata = {
            "freshness": freshness,
            "completeness_ratio": round(completeness, 4),
            "completeness_bucket": completeness_bucket,
            "candidate_usability_state": family_usability,
            "source_state_summary": source_states,
            "provenance_by_field": {
                "absorption_state": src_abs,
                "imbalance_state": src_imb,
                "delta_bias_state": src_delta,
                "sweep_state": src_sweep,
                "exhaustion_state": src_exh,
                "reaction_quality_state": "observation.level_behavior_candidates/advisory_context",
            },
            "field_status": {
                "direct_fields": available_count,
                "provisional_fields": 0,
                "derived_later_fields": 0,
                "direct_field_names": [k for k, ok in field_available.items() if ok],
                "unsupported_field_names": [k for k, ok in field_available.items() if not ok],
            },
        }
        trace = {
            "mapper": "OrderFlowStateMapper",
            "source_families_used": ["runtime_context_snapshot", "observation_event_stream", "advisory_status_cached"],
            "source_quality_label": qlabel,
            "family_usability_state": family_usability,
            "source_states": source_states,
            "notes": [
                "candidate only; no final regime/tradability meaning emitted",
                "reaction quality inferred from level behavior candidates when present",
            ],
        }
        return FamilyResult("OrderFlowState", candidate_fields, metadata, sorted(set(reason_codes)), trace)


class LiquidityStateMapper:
    def map(self, ctx: MapperContext) -> FamilyResult:
        runtime = ctx.source("runtime_context")
        obs = ctx.source("observation")
        acq = ctx.source("acquisition_input")
        adv = ctx.source("advisory_status")
        status = ctx.source("runtime_context_status")

        imbalance, _ = choose_value(
            [
                ("runtime_context.imbalance_state", g(runtime, "imbalance_state")),
                ("observation.microstructure_observation.imbalance_state", g(obs, "microstructure_observation", "imbalance_state")),
                ("acquisition_input.microstructure_observation.imbalance_state", g(acq, "microstructure_observation", "imbalance_state")),
            ]
        )
        stability, _ = choose_value(
            [
                ("runtime_context.liquidity_stability_state", g(runtime, "liquidity_stability_state")),
                ("observation.microstructure_observation.liquidity_stability_state", g(obs, "microstructure_observation", "liquidity_stability_state")),
                ("acquisition_input.microstructure_observation.liquidity_stability_state", g(acq, "microstructure_observation", "liquidity_stability_state")),
            ]
        )
        level_candidates = g(obs, "level_behavior_candidates")
        if not isinstance(level_candidates, list):
            level_candidates = g(acq, "level_behavior_candidates")
        if not isinstance(level_candidates, list):
            level_candidates = g(runtime, "level_candidates")
        level_count = len(level_candidates) if isinstance(level_candidates, list) else int(g(status, "level_candidate_count") or 0)

        pressure = "LIQUIDITY_PRESSURE_BALANCED"
        imb_u = str_upper(imbalance)
        if "BUY" in imb_u:
            pressure = "LIQUIDITY_PRESSURE_BUY_SIDE"
        elif "SELL" in imb_u:
            pressure = "LIQUIDITY_PRESSURE_SELL_SIDE"

        density_void = "DENSITY_VOID_UNKNOWN"
        if level_count <= 0:
            density_void = "DENSITY_VOID_SPARSE"
        elif level_count <= 2:
            density_void = "DENSITY_VOID_BALANCED"
        else:
            density_void = "DENSITY_VOID_DENSE"

        pull_stack = "UNSUPPORTED_BY_CURRENT_SOURCES"
        pull_stack_supported = False
        first_candidate = level_candidates[0] if isinstance(level_candidates, list) and level_candidates and isinstance(level_candidates[0], dict) else {}
        if first_candidate:
            sweep = bool_value(first_candidate.get("sweep_detected"))
            reclaim = bool_value(first_candidate.get("reclaim_confirmed"))
            imbalance_ratio = float(first_candidate.get("imbalance_ratio", 0.0) or 0.0)
            if sweep and reclaim:
                pull_stack = "PULL_STACK_SUBSTITUTE_RECLAIM_AFTER_SWEEP"
                pull_stack_supported = True
            elif sweep and not reclaim:
                pull_stack = "PULL_STACK_SUBSTITUTE_FAILED_RECLAIM"
                pull_stack_supported = True
            elif imbalance_ratio >= 1.15:
                pull_stack = "PULL_STACK_SUBSTITUTE_BUY_PRESSURE_CLUSTER"
                pull_stack_supported = True
            elif imbalance_ratio > 0 and imbalance_ratio <= 0.90:
                pull_stack = "PULL_STACK_SUBSTITUTE_SELL_PRESSURE_CLUSTER"
                pull_stack_supported = True
        elif bool_value(g(adv, "level_context_supportive")) or bool_value(g(adv, "level_context_obstructive")):
            pull_stack = "PULL_STACK_SUBSTITUTE_CONTEXT_ONLY"
            pull_stack_supported = True
        book_asymmetry = "BOOK_ASYMMETRY_UNKNOWN"
        if "BUY" in imb_u:
            book_asymmetry = "BOOK_ASYMMETRY_BID_HEAVY"
        elif "SELL" in imb_u:
            book_asymmetry = "BOOK_ASYMMETRY_ASK_HEAVY"

        local_stability = (stability or "UNKNOWN")
        mandatory = {
            "liquidity_pressure_state": pressure,
            "pull_stack_behavior": pull_stack,
            "density_void_state": density_void,
            "book_asymmetry_state": book_asymmetry,
            "local_microstructure_stability": local_stability,
        }
        field_available = {
            "liquidity_pressure_state": imbalance is not None,
            "pull_stack_behavior": pull_stack_supported,
            "density_void_state": level_count >= 0,
            "book_asymmetry_state": imbalance is not None,
            "local_microstructure_stability": stability is not None,
        }
        available_count = len([1 for _, ok in field_available.items() if ok])
        completeness = available_count / max(len(mandatory), 1)
        freshness = freshness_from_times(g(runtime, "event_time"), g(runtime, "fresh_until"), ctx.meta("runtime_context").get("age_seconds"))
        qlabel = str(g(status, "quality_state") or g(runtime, "data_quality_state") or "UNKNOWN").upper()
        fgq = quality_band(qlabel, freshness["freshness_state"], completeness)

        reason_codes = [
            "BOUNDARY_OK_NON_AUTHORITATIVE",
            "LIQUIDITY_FROM_STABILITY_AND_IMBALANCE",
            "LIQUIDITY_DENSITY_VOID_INFERRED",
            f"FRESHNESS_{freshness['freshness_state']}",
            f"QUALITY_{fgq}",
        ]
        source_states = {
            "runtime_context": ctx.source_state("runtime_context").get("state", "MISSING"),
            "observation": ctx.source_state("observation").get("state", "MISSING"),
            "advisory_status": ctx.source_state("advisory_status").get("state", "MISSING"),
        }
        for source_name, state in source_states.items():
            reason_codes.append(source_state_reason_code(source_name, state))
        if pull_stack_supported:
            reason_codes.append("LIQUIDITY_PULL_STACK_SUBSTITUTE_APPLIED")
        else:
            reason_codes.append("LIQUIDITY_PULL_STACK_NOT_SUPPORTED")
            reason_codes.append("FIELD_NOT_SUPPORTED_BY_CURRENT_SOURCES")
        if freshness["freshness_state"] in {"STALE", "EXPIRED"}:
            reason_codes.append("PRESENT_BUT_LOW_FRESHNESS")
        if fgq == "LOW":
            reason_codes.append("PRESENT_BUT_LOW_QUALITY")
        if g(adv, "nearest_support_distance_points") is not None or g(adv, "nearest_resistance_distance_points") is not None:
            reason_codes.append("LIQUIDITY_DISTANCES_FROM_ADVISORY_CONTEXT")

        candidate_fields = {
            **mandatory,
            "field_group_quality": fgq,
        }
        family_usability = family_usability_state(
            freshness["freshness_state"],
            completeness,
            list(source_states.values()),
        )
        completeness_bucket = (
            "COMPLETE"
            if completeness >= 0.90
            else "PARTIAL_HIGH" if completeness >= 0.70 else "PARTIAL_LOW"
        )
        metadata = {
            "freshness": freshness,
            "completeness_ratio": round(completeness, 4),
            "completeness_bucket": completeness_bucket,
            "candidate_usability_state": family_usability,
            "source_state_summary": source_states,
            "provenance_by_field": {
                "liquidity_pressure_state": "runtime_context/observation/acquisition_input",
                "density_void_state": "level_behavior_candidates or level_candidate_count",
                "book_asymmetry_state": "imbalance_state",
                "local_microstructure_stability": "liquidity_stability_state",
                "pull_stack_behavior": "level_behavior_candidates or advisory context substitute",
            },
            "field_status": {
                "direct_fields": available_count,
                "provisional_fields": 0,
                "derived_later_fields": 1 if not pull_stack_supported else 0,
                "direct_field_names": [k for k, ok in field_available.items() if ok],
                "unsupported_field_names": [k for k, ok in field_available.items() if not ok],
            },
        }
        trace = {
            "mapper": "LiquidityStateMapper",
            "source_families_used": ["runtime_context_snapshot", "observation_event_stream", "advisory_status_cached"],
            "level_candidate_count_seen": level_count,
            "family_usability_state": family_usability,
            "source_states": source_states,
            "notes": [
                "pull/stack behavior uses bounded substitute logic where available",
                "candidate only; non-authoritative",
            ],
        }
        return FamilyResult("LiquidityState", candidate_fields, metadata, sorted(set(reason_codes)), trace)


class LevelInteractionStateMapper:
    def map(self, ctx: MapperContext) -> FamilyResult:
        runtime = ctx.source("runtime_context")
        obs = ctx.source("observation")
        acq = ctx.source("acquisition_input")
        adv = ctx.source("advisory_status")
        status = ctx.source("runtime_context_status")

        level_type = g(adv, "level_interaction_type")
        confluence = g(adv, "support_resistance_confluence_state")
        supportive = bool_value(g(adv, "level_context_supportive"))
        obstructive = bool_value(g(adv, "level_context_obstructive"))
        degraded = bool_value(g(adv, "level_context_degraded"))
        nsd = g(adv, "nearest_support_distance_points")
        nrd = g(adv, "nearest_resistance_distance_points")

        candidates = g(obs, "level_behavior_candidates")
        if not isinstance(candidates, list):
            candidates = g(acq, "level_behavior_candidates")
        if not isinstance(candidates, list):
            candidates = []

        area_state = "AREA_INTERACTION_UNKNOWN"
        if isinstance(level_type, str) and level_type:
            if "CONFLICTED" in level_type.upper():
                area_state = "AREA_INTERACTION_CONFLICTED"
            elif "SUPPORT" in level_type.upper():
                area_state = "AREA_INTERACTION_SUPPORT_SIDE"
            else:
                area_state = "AREA_INTERACTION_CONTEXTUAL"
        elif candidates:
            area_state = "AREA_INTERACTION_FROM_BEHAVIOR_CANDIDATES"

        defended_failed = "DEFENDED_FAILED_UNKNOWN"
        reject_accept = "REJECTION_ACCEPTANCE_UNKNOWN"
        if candidates:
            top = candidates[0] if isinstance(candidates[0], dict) else {}
            sweep = bool_value(top.get("sweep_detected"))
            reclaim = bool_value(top.get("reclaim_confirmed"))
            reaction = float(top.get("reaction_strength", 0.0) or 0.0)
            if sweep and reclaim:
                defended_failed = "DEFENDED_RECLAIMED_AREA"
            elif sweep and not reclaim:
                defended_failed = "FAILED_RECLAIM_AFTER_SWEEP"
            if reaction >= 0.65:
                reject_accept = "REJECTION_ACCEPTANCE_STRONG"
            elif reaction >= 0.45:
                reject_accept = "REJECTION_ACCEPTANCE_MODERATE"
            else:
                reject_accept = "REJECTION_ACCEPTANCE_WEAK"

        absorption = str_upper(g(runtime, "absorption_state") or g(obs, "microstructure_observation", "absorption_state"))
        absorption_near_area = "ABSORPTION_NEAR_AREA_UNKNOWN"
        if "BID" in absorption:
            absorption_near_area = "ABSORPTION_NEAR_SUPPORT_SIDE"
        elif "ASK" in absorption:
            absorption_near_area = "ABSORPTION_NEAR_RESISTANCE_SIDE"

        pressure = "PRESSURE_AROUND_BAND_UNKNOWN"
        if isinstance(nsd, (int, float)) and isinstance(nrd, (int, float)):
            if min(float(nsd), float(nrd)) <= 15:
                pressure = "PRESSURE_AROUND_BAND_ELEVATED_NEAR_LEVEL"
            else:
                pressure = "PRESSURE_AROUND_BAND_MODERATE"

        local_interaction = "LOCAL_INTERACTION_UNKNOWN"
        if supportive and obstructive:
            local_interaction = "LOCAL_INTERACTION_MIXED_CONFLICTED"
        elif supportive and not obstructive:
            local_interaction = "LOCAL_INTERACTION_SUPPORTIVE"
        elif obstructive:
            local_interaction = "LOCAL_INTERACTION_OBSTRUCTIVE"
        if degraded:
            local_interaction = "LOCAL_INTERACTION_DEGRADED"

        mandatory = {
            "candidate_area_interaction_state": area_state,
            "defended_failed_area_behavior": defended_failed,
            "rejection_acceptance_character": reject_accept,
            "absorption_near_area": absorption_near_area,
            "pressure_around_band": pressure,
            "local_interaction_state": local_interaction,
        }
        field_available = {
            "candidate_area_interaction_state": area_state not in {"AREA_INTERACTION_UNKNOWN"},
            "defended_failed_area_behavior": defended_failed not in {"DEFENDED_FAILED_UNKNOWN"},
            "rejection_acceptance_character": reject_accept not in {"REJECTION_ACCEPTANCE_UNKNOWN"},
            "absorption_near_area": absorption_near_area not in {"ABSORPTION_NEAR_AREA_UNKNOWN"},
            "pressure_around_band": pressure not in {"PRESSURE_AROUND_BAND_UNKNOWN"},
            "local_interaction_state": local_interaction not in {"LOCAL_INTERACTION_UNKNOWN"},
        }
        available_count = len([1 for _, ok in field_available.items() if ok])
        completeness = available_count / max(len(mandatory), 1)
        freshness = freshness_from_times(g(runtime, "event_time"), g(runtime, "fresh_until"), ctx.meta("runtime_context").get("age_seconds"))
        qlabel = str(g(status, "quality_state") or g(runtime, "data_quality_state") or "UNKNOWN").upper()
        fgq = quality_band(qlabel, freshness["freshness_state"], completeness)

        reason_codes = [
            "BOUNDARY_OK_NON_AUTHORITATIVE",
            "LEVEL_INTERACTION_FROM_ADVISORY_CONTEXT" if level_type else "LEVEL_INTERACTION_FROM_LEVEL_BEHAVIOR_CANDIDATES",
            "LEVEL_INTERACTION_CANONICAL_OWNERSHIP_EXCLUDED",
            "LEVEL_INTERACTION_FINAL_MEANING_EXCLUDED",
            f"FRESHNESS_{freshness['freshness_state']}",
            f"QUALITY_{fgq}",
        ]
        source_states = {
            "advisory_status": ctx.source_state("advisory_status").get("state", "MISSING"),
            "runtime_context": ctx.source_state("runtime_context").get("state", "MISSING"),
            "observation": ctx.source_state("observation").get("state", "MISSING"),
        }
        for source_name, state in source_states.items():
            reason_codes.append(source_state_reason_code(source_name, state))
        if freshness["freshness_state"] in {"STALE", "EXPIRED"}:
            reason_codes.append("PRESENT_BUT_LOW_FRESHNESS")
        if fgq == "LOW":
            reason_codes.append("PRESENT_BUT_LOW_QUALITY")

        candidate_fields = {
            **mandatory,
            "field_group_quality": fgq,
        }
        family_usability = family_usability_state(
            freshness["freshness_state"],
            completeness,
            list(source_states.values()),
        )
        completeness_bucket = (
            "COMPLETE"
            if completeness >= 0.90
            else "PARTIAL_HIGH" if completeness >= 0.70 else "PARTIAL_LOW"
        )
        metadata = {
            "freshness": freshness,
            "completeness_ratio": round(completeness, 4),
            "completeness_bucket": completeness_bucket,
            "candidate_usability_state": family_usability,
            "source_state_summary": source_states,
            "provenance_by_field": {
                "candidate_area_interaction_state": "advisory_status.level_interaction_type or level_behavior_candidates",
                "defended_failed_area_behavior": "level_behavior_candidates",
                "rejection_acceptance_character": "level_behavior_candidates.reaction_strength",
                "absorption_near_area": "runtime_context/observation absorption_state",
                "pressure_around_band": "advisory nearest level distances",
                "local_interaction_state": "advisory support/obstruct/degraded flags",
            },
            "field_status": {
                "direct_fields": available_count,
                "provisional_fields": 0,
                "derived_later_fields": 0,
                "direct_field_names": [k for k, ok in field_available.items() if ok],
                "unsupported_field_names": [k for k, ok in field_available.items() if not ok],
            },
        }
        trace = {
            "mapper": "LevelInteractionStateMapper",
            "source_families_used": ["advisory_status_cached", "runtime_context_snapshot", "observation_event_stream"],
            "confluence_csv": confluence,
            "family_usability_state": family_usability,
            "source_states": source_states,
            "notes": [
                "candidate state excludes canonical ownership and final continuation validity",
            ],
        }
        return FamilyResult("LevelInteractionState", candidate_fields, metadata, sorted(set(reason_codes)), trace)


class MicrostructureEnvironmentEvidenceMapper:
    def map(self, ctx: MapperContext) -> FamilyResult:
        runtime = ctx.source("runtime_context")
        status = ctx.source("runtime_context_status")
        adv = ctx.source("advisory_status")

        market_state = str(g(runtime, "market_state_class") or "UNKNOWN").upper()
        compression_expansion = "COMPRESSION_EXPANSION_UNKNOWN"
        if "EXPANSION" in market_state:
            compression_expansion = "EXPANSION_EVIDENCE_PRESENT"
        elif "BALANCED" in market_state or "COMPRESSION" in market_state:
            compression_expansion = "COMPRESSION_OR_BALANCED_EVIDENCE"

        liquidity_state = str_upper(g(runtime, "liquidity_stability_state"))
        sweep_state = str_upper(g(runtime, "liquidity_sweep_state"))
        order_disorder = "ORDER_DISORDER_UNKNOWN"
        if "STABLE" in liquidity_state and "RECENT_SWEEP" not in sweep_state:
            order_disorder = "ORDERLY_MICROSTRUCTURE_EVIDENCE"
        elif "RECENT_SWEEP" in sweep_state:
            order_disorder = "DISORDER_SWEEP_ACTIVITY_EVIDENCE"
        else:
            order_disorder = "MIXED_ORDER_DISORDER_EVIDENCE"

        contradiction_flag = bool_value(g(adv, "contradiction_flag"))
        contradiction_evidence = "CONTRADICTION_EVIDENCE_NONE"
        if contradiction_flag:
            contradiction_evidence = "CONTRADICTION_EVIDENCE_PRESENT"

        freshness = freshness_from_times(g(runtime, "event_time"), g(runtime, "fresh_until"), ctx.meta("runtime_context").get("age_seconds"))
        quality_label = str(g(status, "quality_state") or g(runtime, "data_quality_state") or "UNKNOWN").upper()
        cleanliness = "MICROSTRUCTURE_CLEANLINESS_UNKNOWN"
        if freshness["freshness_state"] == "FRESH" and quality_label in {"HIGH", "MEDIUM"} and not contradiction_flag:
            cleanliness = "MICROSTRUCTURE_CLEANLINESS_GOOD"
        elif freshness["freshness_state"] == "EXPIRED" or quality_label == "LOW":
            cleanliness = "MICROSTRUCTURE_CLEANLINESS_DEGRADED"
        else:
            cleanliness = "MICROSTRUCTURE_CLEANLINESS_MIXED"

        instability = []
        if freshness["freshness_state"] in {"STALE", "EXPIRED"}:
            instability.append("INSTABILITY_FRESHNESS_" + freshness["freshness_state"])
        if bool_value(g(status, "price_anchor_fields_suppressed")):
            instability.append("INSTABILITY_PRICE_ANCHOR_SUPPRESSED")
        if bool_value(g(status, "shadow_attached")) is False:
            instability.append("INSTABILITY_SHADOW_NOT_ATTACHED")
        if bool_value(g(adv, "gate_translation_valid")) is False:
            instability.append("INSTABILITY_TRANSLATION_GATE_FALSE")

        mandatory = {
            "compression_expansion_evidence": compression_expansion,
            "order_disorder_evidence": order_disorder,
            "contradiction_evidence": contradiction_evidence,
            "microstructure_cleanliness_evidence": cleanliness,
            "local_instability_markers": instability,
        }
        field_available = {
            "compression_expansion_evidence": compression_expansion != "COMPRESSION_EXPANSION_UNKNOWN",
            "order_disorder_evidence": order_disorder != "ORDER_DISORDER_UNKNOWN",
            "contradiction_evidence": contradiction_evidence != "CONTRADICTION_EVIDENCE_NONE" or bool_value(g(adv, "contradiction_flag")) is False,
            "microstructure_cleanliness_evidence": cleanliness != "MICROSTRUCTURE_CLEANLINESS_UNKNOWN",
            "local_instability_markers": isinstance(instability, list),
        }
        available_count = len([1 for _, ok in field_available.items() if ok])
        completeness = available_count / max(len(mandatory), 1)
        fgq = quality_band(quality_label, freshness["freshness_state"], completeness)
        reason_codes = [
            "BOUNDARY_OK_NON_AUTHORITATIVE",
            "ENV_EVIDENCE_FROM_MARKET_STATE_CLASS",
            "ENV_CONTRADICTION_FROM_ADVISORY_FLAG",
            "ENV_CLEANLINESS_FROM_QUALITY_AND_FRESHNESS",
            "ENV_FINAL_REGIME_EXCLUDED",
            f"FRESHNESS_{freshness['freshness_state']}",
            f"QUALITY_{fgq}",
        ]
        source_states = {
            "runtime_context": ctx.source_state("runtime_context").get("state", "MISSING"),
            "runtime_context_status": ctx.source_state("runtime_context_status").get("state", "MISSING"),
            "advisory_status": ctx.source_state("advisory_status").get("state", "MISSING"),
        }
        for source_name, state in source_states.items():
            reason_codes.append(source_state_reason_code(source_name, state))
        if freshness["freshness_state"] in {"STALE", "EXPIRED"}:
            reason_codes.append("PRESENT_BUT_LOW_FRESHNESS")
        if fgq == "LOW":
            reason_codes.append("PRESENT_BUT_LOW_QUALITY")

        candidate_fields = {
            **mandatory,
            "field_group_quality": fgq,
        }
        family_usability = family_usability_state(
            freshness["freshness_state"],
            completeness,
            list(source_states.values()),
        )
        completeness_bucket = (
            "COMPLETE"
            if completeness >= 0.90
            else "PARTIAL_HIGH" if completeness >= 0.70 else "PARTIAL_LOW"
        )
        metadata = {
            "freshness": freshness,
            "completeness_ratio": round(completeness, 4),
            "completeness_bucket": completeness_bucket,
            "candidate_usability_state": family_usability,
            "source_state_summary": source_states,
            "provenance_by_field": {
                "compression_expansion_evidence": "runtime_context.market_state_class",
                "order_disorder_evidence": "runtime_context.liquidity_stability_state + liquidity_sweep_state",
                "contradiction_evidence": "advisory_status.contradiction_flag",
                "microstructure_cleanliness_evidence": "runtime_context_status.freshness_state + quality_state",
                "local_instability_markers": "status/advisory gates and suppression flags",
            },
            "field_status": {
                "direct_fields": available_count,
                "provisional_fields": 0,
                "derived_later_fields": 0,
                "direct_field_names": [k for k, ok in field_available.items() if ok],
                "unsupported_field_names": [k for k, ok in field_available.items() if not ok],
            },
        }
        trace = {
            "mapper": "MicrostructureEnvironmentEvidenceMapper",
            "source_families_used": ["runtime_context_snapshot", "runtime_context_status_cached", "advisory_status_cached"],
            "family_usability_state": family_usability,
            "source_states": source_states,
            "notes": [
                "environment evidence remains non-binding and non-authoritative",
                "no final regime/tradability outputs emitted",
            ],
        }
        return FamilyResult("MicrostructureEnvironmentEvidence", candidate_fields, metadata, sorted(set(reason_codes)), trace)


class QualityValidityStateMapper:
    def map(self, ctx: MapperContext, prior_family_results: dict[str, FamilyResult], boundary_checks_result: dict[str, Any]) -> FamilyResult:
        status = ctx.source("runtime_context_status")
        adv = ctx.source("advisory_status")
        runtime = ctx.source("runtime_context")

        status_freshness = str(g(status, "freshness_state") or "UNKNOWN").upper()
        quality = str(g(status, "quality_state") or g(runtime, "data_quality_state") or "UNKNOWN").upper()
        attached = bool_value(g(status, "shadow_attached"))
        rejection_reason = str(g(status, "rejection_reason") or g(status, "last_rejection_reason") or "").strip()
        gate_reason = str(g(adv, "gate_reason_code") or g(adv, "advisory_ineligibility_reason_code") or "").strip()
        freshness_meta = freshness_from_times(
            first_present(runtime, ["event_time", "created_time"]),
            first_present(runtime, ["fresh_until"]),
            ctx.meta("runtime_context").get("age_seconds"),
        )
        if (
            freshness_meta["freshness_state"] == "UNKNOWN"
            and status_freshness in {"FRESH", "STALE", "EXPIRED"}
        ):
            freshness_meta["freshness_state"] = status_freshness
            freshness_meta["freshness_reason"] = "FRESHNESS_FROM_STATUS_STATE"
        freshness = str(freshness_meta["freshness_state"]).upper()

        degradation_state = "DEGRADATION_NONE"
        if freshness in {"EXPIRED"}:
            degradation_state = "DEGRADATION_FRESHNESS_EXPIRED"
        elif freshness in {"STALE"}:
            degradation_state = "DEGRADATION_FRESHNESS_STALE"
        elif quality == "LOW":
            degradation_state = "DEGRADATION_QUALITY_LOW"
        elif not attached:
            degradation_state = "DEGRADATION_NOT_ATTACHED"

        suppression_flags = {
            "price_anchor_fields_suppressed": bool_value(g(status, "price_anchor_fields_suppressed")),
            "semantic_only_mode": bool_value(g(adv, "semantic_only_mode")),
            "attachment_blocked": not attached,
            "translation_gate_false": not bool_value(g(adv, "gate_translation_valid"), True),
        }
        source_states = {
            "runtime_context": ctx.source_state("runtime_context").get("state", "MISSING"),
            "runtime_context_status": ctx.source_state("runtime_context_status").get("state", "MISSING"),
            "advisory_status": ctx.source_state("advisory_status").get("state", "MISSING"),
        }
        suppression_flags["source_partial_or_degraded"] = any(
            state in {"MISSING", "EXPIRED", "PARTIAL_BUT_DEGRADED"}
            for state in source_states.values()
        )
        suppression_reason_codes = []
        if rejection_reason:
            suppression_reason_codes.append(rejection_reason)
        if gate_reason:
            suppression_reason_codes.append(gate_reason)
        basis_state = g(runtime, "basis_capture_state")
        if isinstance(basis_state, str) and basis_state:
            suppression_reason_codes.append(basis_state)
        suppression_reason_codes = sorted(set([x for x in suppression_reason_codes if x]))

        confidence_ceiling_candidate = 0.15
        if quality == "HIGH":
            confidence_ceiling_candidate = 0.49
        elif quality == "MEDIUM":
            confidence_ceiling_candidate = 0.35
        elif quality == "LOW":
            confidence_ceiling_candidate = 0.20

        boundary_violation = any(
            bool(boundary_checks_result.get(key, False))
            for key in (
                "final_regime_leakage",
                "canonical_level_ownership_leakage",
                "tradability_verdict_leakage",
                "decision_package_leakage",
            )
        )

        export_eligibility_candidate = (
            freshness == "FRESH"
            and quality in {"HIGH", "MEDIUM"}
            and attached
            and all(
                state not in {"MISSING", "EXPIRED", "PARTIAL_BUT_DEGRADED"}
                for state in source_states.values()
            )
        )
        if boundary_violation:
            export_eligibility_candidate = False

        invalid_or_missing = []
        for name, result in prior_family_results.items():
            comp = float(result.metadata.get("completeness_ratio", 0.0))
            if comp < 0.70:
                invalid_or_missing.append(f"{name}:COMPLETENESS_BELOW_0_70")

        field_available = {
            "degradation_state": degradation_state != "DEGRADATION_NONE" or freshness in {"FRESH", "STALE", "EXPIRED"},
            "suppression_flags": isinstance(suppression_flags, dict),
            "suppression_reason_codes": isinstance(suppression_reason_codes, list),
            "export_eligibility_candidate": isinstance(export_eligibility_candidate, bool),
            "confidence_ceiling_candidate": isinstance(confidence_ceiling_candidate, (int, float)),
            "invalid_or_missing_family_indicators": isinstance(invalid_or_missing, list),
        }
        available_count = len([1 for _, ok in field_available.items() if ok])
        field_completeness = available_count / max(len(field_available), 1)
        source_completeness = len(
            [
                1
                for state in source_states.values()
                if state in {"FRESH", "PARTIAL_BUT_USABLE", "STALE", "PARTIAL_BUT_DEGRADED"}
            ]
        ) / max(len(source_states), 1)
        completeness = (field_completeness * 0.70) + (source_completeness * 0.30)
        fgq = quality_band(quality, freshness_meta["freshness_state"], completeness)
        family_usability = family_usability_state(
            freshness_meta["freshness_state"],
            completeness,
            list(source_states.values()),
        )
        completeness_bucket = (
            "COMPLETE"
            if completeness >= 0.90
            else "PARTIAL_HIGH" if completeness >= 0.70 else "PARTIAL_LOW"
        )

        reason_codes = [
            "BOUNDARY_OK_NON_AUTHORITATIVE" if not boundary_violation else "BOUNDARY_VIOLATION_DECISION_PACKAGE",
            "QUALITY_VALIDITY_FROM_STATUS_SURFACES",
            "QUALITY_VALIDITY_SUPPRESSION_FLAGS_MERGED",
            "QUALITY_VALIDITY_EXPORT_ELIGIBILITY_CANDIDATE_ONLY",
            "QUALITY_VALIDITY_NOT_EXPORT_GOVERNANCE_ENGINE",
            f"FRESHNESS_{freshness_meta['freshness_state']}",
            f"QUALITY_{fgq}",
        ]
        for source_name, state in source_states.items():
            reason_codes.append(source_state_reason_code(source_name, state))
        if freshness in {"STALE", "EXPIRED"}:
            reason_codes.append("PRESENT_BUT_LOW_FRESHNESS")
        if fgq == "LOW":
            reason_codes.append("PRESENT_BUT_LOW_QUALITY")
        if invalid_or_missing:
            reason_codes.append("QUALITY_VALIDITY_FAMILY_INPUTS_PARTIAL")
        if not export_eligibility_candidate:
            if freshness in {"STALE", "EXPIRED"}:
                reason_codes.append("GATED_BY_FRESHNESS")
            if quality == "LOW":
                reason_codes.append("GATED_BY_QUALITY")
            if not attached:
                reason_codes.append("GATED_BY_ATTACHMENT")
            if suppression_flags.get("translation_gate_false"):
                reason_codes.append("GATED_BY_TRANSLATION_STATE")

        candidate_fields = {
            "degradation_state": degradation_state,
            "suppression_flags": suppression_flags,
            "suppression_reason_codes": suppression_reason_codes,
            "export_eligibility_candidate": export_eligibility_candidate,
            "confidence_ceiling_candidate": confidence_ceiling_candidate,
            "field_group_quality": fgq,
            "invalid_or_missing_family_indicators": invalid_or_missing,
        }
        metadata = {
            "freshness": freshness_meta,
            "completeness_ratio": round(completeness, 4),
            "completeness_bucket": completeness_bucket,
            "candidate_usability_state": family_usability,
            "source_state_summary": source_states,
            "provenance_by_field": {
                "degradation_state": "runtime_context_status + advisory_status",
                "suppression_flags": "runtime_context_status + advisory_status",
                "suppression_reason_codes": "runtime_context_status.rejection_reason + advisory gate reasons + runtime basis state",
                "export_eligibility_candidate": "freshness+quality+attachment bounded candidate logic",
                "confidence_ceiling_candidate": "quality mapped with Phase1 extended confidence ceiling compatibility",
            },
            "field_status": {
                "direct_fields": available_count,
                "provisional_fields": 1,
                "derived_later_fields": 0,
                "direct_field_names": [k for k, ok in field_available.items() if ok],
                "unsupported_field_names": [k for k, ok in field_available.items() if not ok],
                "provisional_field_names": ["export_eligibility_candidate"],
            },
        }
        trace = {
            "mapper": "QualityValidityStateMapper",
            "source_families_used": ["runtime_context_status_cached", "advisory_status_cached", "runtime_context_snapshot"],
            "family_usability_state": family_usability,
            "source_states": source_states,
            "boundary_violation": boundary_violation,
            "notes": [
                "candidate quality logic only; not final export governance engine",
                "does not change MT5 authority semantics",
            ],
        }
        return FamilyResult("QualityValidityState", candidate_fields, metadata, sorted(set(reason_codes)), trace)


def boundary_checks(bundle_families: dict[str, FamilyResult], forbidden_fields: list[str]) -> dict[str, Any]:
    forbidden_hits: list[str] = []

    def walk(obj: Any, prefix: str = "") -> None:
        if isinstance(obj, dict):
            for k, v in obj.items():
                next_prefix = f"{prefix}.{k}" if prefix else k
                if k in forbidden_fields:
                    forbidden_hits.append(next_prefix)
                walk(v, next_prefix)
        elif isinstance(obj, list):
            for i, item in enumerate(obj):
                walk(item, f"{prefix}[{i}]")

    for fam in bundle_families.values():
        walk(fam.candidate_fields, f"{fam.family_name}.candidate_fields")

    hit_joined = " ".join(forbidden_hits).lower()
    return {
        "final_regime_leakage": ("regime" in hit_joined),
        "canonical_level_ownership_leakage": ("canonical" in hit_joined and "owner" in hit_joined),
        "tradability_verdict_leakage": ("tradability" in hit_joined),
        "decision_package_leakage": ("decision_package" in hit_joined or "execution_command" in hit_joined),
        "boundary_reason_codes": ["BOUNDARY_OK_NON_AUTHORITATIVE"] if not forbidden_hits else ["BOUNDARY_VIOLATION_DETECTED"],
        "forbidden_field_hits": forbidden_hits,
    }


def build_source_paths() -> dict[str, Path]:
    tool_dir = Path(__file__).resolve().parent
    phase3_root = tool_dir.parent
    ai_root = phase3_root.parent
    terminal_root = ai_root.parents[2]
    files_ai = terminal_root / "MQL5" / "Files" / "AI"
    adapter = files_ai / "external_adapter" / "atas_semantic_adapter"
    return {
        "runtime_context": files_ai / "atas_runtime_context.json",
        "runtime_context_status": files_ai / "atas_runtime_context_status.json",
        "advisory_status": files_ai / "atas_governed_advisory_status.json",
        "observation": adapter / "future_exporter" / "runtime" / "acquisition_source" / "atas_observation_export.json",
        "acquisition_input": adapter / "future_exporter" / "runtime" / "acquisition_input" / "acquisition_input_payload.json",
        "producer_input": adapter / "runtime" / "producer_input" / "atas_export_payload.json",
        "exporter_status": adapter / "future_exporter" / "runtime" / "exporter_status.json",
        "adapter_status": adapter / "runtime" / "adapter_status.json",
        "output_dir": files_ai / "atas_micro_phase3_candidate",
        "phase3_contract": ai_root / "atas_microstructure_phase3_sandbox_v1" / "contracts" / "phase3_candidate_family_contract_v1.json",
    }


def main() -> int:
    paths = build_source_paths()
    output_dir = paths["output_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)

    source_data: dict[str, dict[str, Any]] = {}
    source_meta: dict[str, dict[str, Any]] = {}
    for key, path in paths.items():
        if key in {"output_dir", "phase3_contract"}:
            continue
        source_data[key] = read_json(path)
        source_meta[key] = file_meta(path)

    source_assessments = build_source_assessments(source_data, source_meta)
    ctx = MapperContext(source_data, source_meta, source_assessments)
    orderflow = OrderFlowStateMapper().map(ctx)
    liquidity = LiquidityStateMapper().map(ctx)
    level = LevelInteractionStateMapper().map(ctx)
    environment = MicrostructureEnvironmentEvidenceMapper().map(ctx)
    interim_families = {
        "OrderFlowState": orderflow,
        "LiquidityState": liquidity,
        "LevelInteractionState": level,
        "MicrostructureEnvironmentEvidence": environment,
    }

    contract = read_json(paths["phase3_contract"])
    forbidden = contract.get("forbidden_boundary_fields", [])
    interim_boundary = boundary_checks(interim_families, forbidden if isinstance(forbidden, list) else [])
    quality_validity = QualityValidityStateMapper().map(ctx, interim_families, interim_boundary)

    families = {
        "OrderFlowState": orderflow,
        "LiquidityState": liquidity,
        "LevelInteractionState": level,
        "MicrostructureEnvironmentEvidence": environment,
        "QualityValidityState": quality_validity,
    }
    boundary = boundary_checks(families, forbidden if isinstance(forbidden, list) else [])
    boundary_violation = any(
        bool(boundary.get(k, False))
        for k in (
            "final_regime_leakage",
            "canonical_level_ownership_leakage",
            "tradability_verdict_leakage",
            "decision_package_leakage",
        )
    )

    packet_id = (
        g(source_data.get("runtime_context", {}), "packet_id")
        or g(source_data.get("observation", {}), "packet_id")
        or "unknown_packet"
    )
    bundle_id = f"PHASE3_{packet_id}_{int(utc_now().timestamp())}"

    family_comp = {name: float(f.metadata.get("completeness_ratio", 0.0)) for name, f in families.items()}
    avg_comp = sum(family_comp.values()) / max(len(family_comp), 1)
    quality_counts = {"GOOD": 0, "MEDIUM": 0, "LOW": 0}
    for f in families.values():
        q = str(f.candidate_fields.get("field_group_quality", "LOW")).upper()
        if q not in quality_counts:
            q = "LOW"
        quality_counts[q] += 1

    freshness_summary = build_freshness_summary(source_assessments, families)
    source_completeness_summary = build_source_completeness_summary(source_assessments)
    lineage_continuity_summary = build_lineage_continuity_summary(source_data, source_assessments)
    blocker_consolidation_summary = build_blocker_consolidation_summary(
        source_assessments,
        lineage_continuity_summary,
        freshness_summary,
    )
    unsupported_fields_by_family = {
        name: f.metadata.get("field_status", {}).get("unsupported_field_names", [])
        for name, f in families.items()
    }
    provisional_fields_by_family = {
        name: f.metadata.get("field_status", {}).get("provisional_field_names", [])
        for name, f in families.items()
    }
    source_utilization_score = source_completeness_summary.get("average_source_coverage_ratio", 0.0)
    lineage_state = str(lineage_continuity_summary.get("lineage_state", "UNKNOWN"))
    continuity_transitions = lineage_continuity_summary.get("transitions", {})
    continuity_match_count = len(
        [
            1
            for detail in continuity_transitions.values()
            if str(detail.get("state", "UNKNOWN")) in {"MATCH_DIRECT", "MATCH_VIA_LINEAGE"}
        ]
    )
    continuity_score = continuity_match_count / max(len(continuity_transitions), 1)
    freshness_quality_score = (
        int(freshness_summary.get("freshness_state_counts", {}).get("FRESH", 0))
        + (0.5 * int(freshness_summary.get("freshness_state_counts", {}).get("STALE", 0))
        )
    ) / max(sum(int(v) for v in freshness_summary.get("freshness_state_counts", {}).values()), 1)
    completeness_score = avg_comp
    explainability_score = (
        len(
            [
                1
                for f in families.values()
                if isinstance(f.metadata.get("provenance_by_field"), dict)
                and bool(f.metadata.get("provenance_by_field"))
                and isinstance(f.metadata.get("field_status"), dict)
            ]
        )
        / max(len(families), 1)
    )
    freshness_counts = freshness_summary.get("freshness_state_counts", {})
    fresh_total = int(freshness_counts.get("FRESH", 0))
    expired_total = int(freshness_counts.get("EXPIRED", 0))
    if boundary_violation:
        overall_status = "CANDIDATE_BOUNDARY_FAIL"
    elif avg_comp >= 0.80 and source_utilization_score >= 0.70 and fresh_total >= max(expired_total, 1) and lineage_state in {
        "COHERENT_FRESH",
        "COHERENT_BUT_LOW_FRESHNESS",
    }:
        overall_status = "CANDIDATE_READY"
    else:
        overall_status = "CANDIDATE_PARTIAL"

    bundle = {
        "schema_version": "ATAS_MICROSTRUCTURE_PHASE3_CANDIDATE_BUNDLE_V1",
        "bundle_classification": "CANDIDATE_PRE_GOVERNANCE_PRE_COMPOSER_NON_AUTHORITATIVE",
        "candidate_bundle_id": bundle_id,
        "generated_at_utc": utc_now_iso(),
        "governance_flags": {
            "non_authoritative": True,
            "pre_governance": True,
            "pre_export_composer": True,
            "mt5_authority_unchanged": True,
        },
        "source_snapshot_lineage": {
            "runtime_context_packet_id": g(source_data.get("runtime_context", {}), "packet_id"),
            "runtime_status_packet_id": g(source_data.get("runtime_context_status", {}), "packet_id"),
            "observation_packet_id": g(source_data.get("observation", {}), "packet_id"),
            "acquisition_packet_id": (
                g(source_data.get("acquisition_input", {}), "packet_id")
                or g(source_data.get("acquisition_input", {}), "acquisition_event_id")
            ),
            "acquisition_source_packet_id": g(source_data.get("acquisition_input", {}), "source_packet_id"),
            "producer_packet_id": g(source_data.get("producer_input", {}), "packet_id"),
            "producer_source_packet_id": g(source_data.get("producer_input", {}), "source_packet_id"),
            "advisory_packet_id": g(source_data.get("advisory_status", {}), "advisory_packet_id"),
            "trace_id": g(source_data.get("runtime_context_status", {}), "trace_id") or g(source_data.get("observation", {}), "trace_id"),
        },
        "families": {name: family.as_dict() for name, family in families.items()},
        "candidate_quality_summary": {
            "overall_status": overall_status,
            "average_completeness_ratio": round(avg_comp, 4),
            "family_completeness": family_comp,
            "field_group_quality_counts": quality_counts,
            "suppression_markers": quality_validity.candidate_fields.get("suppression_reason_codes", []),
            "freshness_summary": freshness_summary,
            "source_completeness_summary": source_completeness_summary,
            "lineage_continuity_summary": lineage_continuity_summary,
            "unsupported_fields_by_family": unsupported_fields_by_family,
            "provisional_fields_by_family": provisional_fields_by_family,
            "blocker_consolidation_summary": blocker_consolidation_summary,
            "closure_readiness_scores": {
                "continuity_score": round(continuity_score, 4),
                "freshness_score": round(freshness_quality_score, 4),
                "completeness_score": round(completeness_score, 4),
                "lineage_continuity_score": round(continuity_score, 4),
                "source_coverage_score": round(float(source_utilization_score), 4),
                "explainability_score": round(explainability_score, 4),
            },
        },
        "boundary_checks": boundary,
    }

    mapper_trace = {
        "trace_version": "ATAS_PHASE3_MAPPER_TRACE_V1",
        "generated_at_utc": utc_now_iso(),
        "candidate_bundle_id": bundle_id,
        "family_traces": {name: f.trace_summary for name, f in families.items()},
        "family_reason_codes": {name: f.reason_codes for name, f in families.items()},
    }

    source_utilization = {
        "summary_version": "ATAS_PHASE3_SOURCE_UTILIZATION_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "source_files": source_meta,
        "source_assessments": source_assessments,
        "source_completeness_summary": source_completeness_summary,
        "families_to_sources": {
            name: f.trace_summary.get("source_families_used", []) for name, f in families.items()
        },
    }

    field_population = {
        "summary_version": "ATAS_PHASE3_FIELD_POPULATION_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "families": {
            name: {
                "candidate_field_count": len(f.candidate_fields),
                "direct_fields": f.metadata.get("field_status", {}).get("direct_fields", 0),
                "provisional_fields": f.metadata.get("field_status", {}).get("provisional_fields", 0),
                "derived_later_fields": f.metadata.get("field_status", {}).get("derived_later_fields", 0),
                "completeness_ratio": f.metadata.get("completeness_ratio", 0.0),
                "completeness_bucket": f.metadata.get("completeness_bucket"),
                "candidate_usability_state": f.metadata.get("candidate_usability_state"),
                "source_state_summary": f.metadata.get("source_state_summary", {}),
            }
            for name, f in families.items()
        },
    }

    unsupported = {
        "summary_version": "ATAS_PHASE3_UNSUPPORTED_FIELDS_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "unsupported_field_markers": unsupported_fields_by_family,
        "unsupported_reason_codes": {
            name: [code for code in f.reason_codes if "NOT_SUPPORTED" in code or "UNSUPPORTED" in code]
            for name, f in families.items()
        },
    }
    provisional = {
        "summary_version": "ATAS_PHASE3_PROVISIONAL_FIELDS_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "families": {
            name: {
                "field_status": f.metadata.get("field_status", {}),
                "reason_codes": [code for code in f.reason_codes if "PROVISIONAL" in code or "DERIVED_LATER" in code],
            }
            for name, f in families.items()
        },
    }
    coverage = {
        "summary_version": "ATAS_PHASE3_MAPPER_COVERAGE_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "family_count": len(families),
        "families": list(families.keys()),
        "completeness_ratios": family_comp,
        "family_usability_states": {
            name: f.metadata.get("candidate_usability_state", "UNKNOWN")
            for name, f in families.items()
        },
        "coverage_score": round(avg_comp, 4),
    }
    freshness_lineage = {
        "summary_version": "ATAS_PHASE3_FRESHNESS_LINEAGE_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "freshness_summary": freshness_summary,
        "lineage_continuity_summary": lineage_continuity_summary,
        "closure_readiness_scores": {
            "continuity_score": round(continuity_score, 4),
            "freshness_score": round(freshness_quality_score, 4),
            "completeness_score": round(completeness_score, 4),
            "lineage_continuity_score": round(continuity_score, 4),
            "source_coverage_score": round(float(source_utilization_score), 4),
            "explainability_score": round(explainability_score, 4),
        },
    }
    source_completeness = {
        "summary_version": "ATAS_PHASE3_SOURCE_COMPLETENESS_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "source_completeness_summary": source_completeness_summary,
        "source_assessments": source_assessments,
    }
    governance_summary = {
        "summary_version": "ATAS_PHASE3_GOVERNANCE_BOUNDARY_CHECK_SUMMARY_V1",
        "generated_at_utc": utc_now_iso(),
        "boundary_checks": boundary,
        "notes": [
            "phase3 bundle is candidate/pre-governance/pre-export-composer",
            "no final regime/canonical/tradability/decision package outputs allowed",
        ],
    }
    blocker_summary = {
        "summary_version": "ATAS_PHASE3_CLOSURE_BLOCKER_CONSOLIDATION_V1",
        "generated_at_utc": utc_now_iso(),
        "blocker_consolidation_summary": blocker_consolidation_summary,
    }

    write_json(output_dir / "phase3_candidate_state_bundle_latest.json", bundle)
    append_jsonl(output_dir / "phase3_candidate_state_bundle_stream.jsonl", bundle)
    write_json(output_dir / "phase3_mapper_trace_latest.json", mapper_trace)
    append_jsonl(output_dir / "phase3_mapper_trace_stream.jsonl", mapper_trace)

    write_json(output_dir / "phase3_mapper_coverage_summary_latest.json", coverage)
    write_json(output_dir / "phase3_field_population_summary_latest.json", field_population)
    write_json(output_dir / "phase3_source_utilization_summary_latest.json", source_utilization)
    write_json(output_dir / "phase3_unsupported_fields_summary_latest.json", unsupported)
    write_json(output_dir / "phase3_provisional_derived_summary_latest.json", provisional)
    write_json(output_dir / "phase3_source_completeness_summary_latest.json", source_completeness)
    write_json(output_dir / "phase3_freshness_lineage_summary_latest.json", freshness_lineage)
    write_json(output_dir / "phase3_closure_blocker_consolidation_latest.json", blocker_summary)
    write_json(output_dir / "phase3_governance_boundary_check_summary_latest.json", governance_summary)

    print(
        json.dumps(
            {
                "result": "PASS",
                "candidate_bundle": str(output_dir / "phase3_candidate_state_bundle_latest.json"),
                "mapper_trace": str(output_dir / "phase3_mapper_trace_latest.json"),
                "coverage_summary": str(output_dir / "phase3_mapper_coverage_summary_latest.json"),
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
