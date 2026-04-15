from __future__ import annotations

import argparse
import json
import time
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


LIVE_VALID = "LIVE_VALID"
STALE = "STALE"
EXPIRED = "EXPIRED"
HISTORICAL_ONLY = "HISTORICAL_ONLY"
ABSENT = "ABSENT"
NOT_ATTACHED = "NOT_ATTACHED"
BLOCKED = "BLOCKED"
INELIGIBLE = "INELIGIBLE"
DEFAULTED_OR_INVALID = "DEFAULTED_OR_INVALID"
SUPPRESSED = "SUPPRESSED"
UNKNOWN = "UNKNOWN"

STATUS_VALUES = {
    LIVE_VALID,
    STALE,
    EXPIRED,
    HISTORICAL_ONLY,
    ABSENT,
    NOT_ATTACHED,
    BLOCKED,
    INELIGIBLE,
    DEFAULTED_OR_INVALID,
    SUPPRESSED,
    UNKNOWN,
}


@dataclass
class StageAssessment:
    stage: str
    state: str
    reason_code: str
    details: dict[str, Any]

    def as_dict(self) -> dict[str, Any]:
        return {
            "stage": self.stage,
            "state": self.state,
            "reason_code": self.reason_code,
            "details": self.details,
        }


def utc_now_iso() -> str:
    return datetime.now(UTC).isoformat().replace("+00:00", "Z")


def parse_timestamp(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    raw = value.strip()
    if not raw:
        return None
    if raw.endswith("Z"):
        raw = raw[:-1] + "+00:00"
    if " " in raw and "T" not in raw and "." in raw:
        raw = raw.replace(" ", "T", 1)
    try:
        dt = datetime.fromisoformat(raw)
    except ValueError:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=UTC)
    return dt.astimezone(UTC)


def age_seconds(value: Any) -> int | None:
    dt = parse_timestamp(value)
    if dt is None:
        return None
    delta = datetime.now(UTC) - dt
    sec = int(delta.total_seconds())
    return sec if sec >= 0 else 0


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
    age = int((datetime.now(UTC) - mtime).total_seconds())
    return {
        "path": str(path),
        "exists": True,
        "mtime_utc": mtime.isoformat().replace("+00:00", "Z"),
        "age_seconds": age if age >= 0 else 0,
        "size_bytes": int(stat.st_size),
    }


def read_json(path: Path) -> tuple[dict[str, Any], str]:
    if not path.exists():
        return {}, ABSENT
    try:
        data = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except Exception:
        return {}, DEFAULTED_OR_INVALID
    if isinstance(data, dict):
        return data, LIVE_VALID
    return {}, DEFAULTED_OR_INVALID


def read_json_with_fallback(primary: Path, legacy_fallback: Path) -> tuple[dict[str, Any], str, str]:
    primary_payload, primary_state = read_json(primary)
    if primary_state == LIVE_VALID:
        return primary_payload, primary_state, str(primary)

    fallback_payload, fallback_state = read_json(legacy_fallback)
    if fallback_state == LIVE_VALID:
        return fallback_payload, fallback_state, str(legacy_fallback)

    return primary_payload, primary_state, str(primary)


def upper_text(value: Any) -> str:
    if not isinstance(value, str):
        return ""
    return value.strip().upper()


def build_observation_stage(
    obs: dict[str, Any],
    obs_meta: dict[str, Any],
    ind_status: dict[str, Any],
    observation_stale_sec: int,
    observation_expired_sec: int,
) -> StageAssessment:
    if not obs_meta.get("exists", False):
        return StageAssessment("observation", ABSENT, "OBSERVATION_FILE_MISSING", {"meta": obs_meta})

    packet_id = obs.get("packet_id")
    event_time = obs.get("event_time")
    source_symbol = obs.get("source_symbol")
    execution_symbol = obs.get("execution_symbol")
    write_status = upper_text(ind_status.get("write_status"))
    event_age = age_seconds(event_time)
    mtime_age = obs_meta.get("age_seconds")

    if not isinstance(packet_id, str) or not packet_id.strip():
        return StageAssessment(
            "observation",
            DEFAULTED_OR_INVALID,
            "OBSERVATION_PACKET_ID_MISSING",
            {"meta": obs_meta, "packet_id": packet_id},
        )

    if not isinstance(event_time, str) or not event_time.strip():
        return StageAssessment(
            "observation",
            DEFAULTED_OR_INVALID,
            "OBSERVATION_EVENT_TIME_MISSING",
            {"meta": obs_meta, "packet_id": packet_id},
        )

    if write_status and write_status != "WRITTEN":
        return StageAssessment(
            "observation",
            BLOCKED,
            "INDICATOR_WRITE_NOT_WRITTEN",
            {
                "meta": obs_meta,
                "packet_id": packet_id,
                "event_time": event_time,
                "indicator_write_status": write_status,
            },
        )

    state = LIVE_VALID
    reason = "OBSERVATION_FRESH"
    if isinstance(mtime_age, int) and mtime_age > observation_expired_sec:
        state = EXPIRED
        reason = "OBSERVATION_FILE_MTIME_EXPIRED"
    elif isinstance(mtime_age, int) and mtime_age > observation_stale_sec:
        state = STALE
        reason = "OBSERVATION_FILE_MTIME_STALE"
    elif isinstance(event_age, int) and event_age > observation_expired_sec * 2:
        state = HISTORICAL_ONLY
        reason = "OBSERVATION_EVENT_TIME_HISTORICAL"

    details = {
        "meta": obs_meta,
        "packet_id": packet_id,
        "event_time": event_time,
        "event_age_seconds": event_age,
        "source_symbol": source_symbol,
        "execution_symbol": execution_symbol,
        "indicator_write_status": write_status or UNKNOWN,
        "cross_instrument_translation_applied": obs.get("cross_instrument_translation_applied"),
        "price_anchor_fields_suppressed": obs.get("price_anchor_fields_suppressed"),
        "basis_capture_state": obs.get("basis_capture_state"),
    }
    return StageAssessment("observation", state, reason, details)


def build_exporter_stage(
    exporter_status: dict[str, Any],
    exporter_meta: dict[str, Any],
    acq_input_meta: dict[str, Any],
    producer_meta: dict[str, Any],
    observation: StageAssessment,
    exporter_stale_sec: int,
    exporter_expired_sec: int,
) -> StageAssessment:
    if not exporter_meta.get("exists", False):
        return StageAssessment("exporter", ABSENT, "EXPORTER_STATUS_MISSING", {"meta": exporter_meta})

    write_status = upper_text(exporter_status.get("write_status"))
    packet_id = exporter_status.get("packet_id")
    obs_packet = observation.details.get("packet_id")
    mtime_age = exporter_meta.get("age_seconds")
    source_age = acq_input_meta.get("age_seconds")
    producer_age = producer_meta.get("age_seconds")

    if write_status and write_status != "WRITTEN":
        return StageAssessment(
            "exporter",
            BLOCKED,
            "EXPORTER_WRITE_REJECTED",
            {
                "meta": exporter_meta,
                "write_status": write_status,
                "rejection_reason": exporter_status.get("rejection_reason"),
                "packet_id": packet_id,
            },
        )

    if not isinstance(packet_id, str) or not packet_id.strip():
        return StageAssessment(
            "exporter",
            DEFAULTED_OR_INVALID,
            "EXPORTER_PACKET_ID_MISSING",
            {"meta": exporter_meta, "packet_id": packet_id, "write_status": write_status},
        )

    if isinstance(mtime_age, int) and mtime_age > exporter_expired_sec:
        state = EXPIRED
        reason = "EXPORTER_STATUS_EXPIRED"
    elif isinstance(mtime_age, int) and mtime_age > exporter_stale_sec:
        state = STALE
        reason = "EXPORTER_STATUS_STALE"
    else:
        state = LIVE_VALID
        reason = "EXPORTER_FRESH"

    if isinstance(obs_packet, str) and obs_packet and obs_packet != packet_id:
        if observation.state == LIVE_VALID:
            state = HISTORICAL_ONLY
            reason = "EXPORTER_PACKET_ID_LAGS_OBSERVATION"
        else:
            state = STALE
            reason = "EXPORTER_PACKET_ID_MISMATCH"

    details = {
        "meta": exporter_meta,
        "packet_id": packet_id,
        "write_status": write_status or UNKNOWN,
        "rejection_reason": exporter_status.get("rejection_reason"),
        "last_run_timestamp": exporter_status.get("last_run_timestamp"),
        "last_run_age_seconds": age_seconds(exporter_status.get("last_run_timestamp")),
        "observation_packet_id": obs_packet,
        "acquisition_input_meta": acq_input_meta,
        "producer_input_meta": producer_meta,
        "acquisition_input_age_seconds": source_age,
        "producer_input_age_seconds": producer_age,
    }
    return StageAssessment("exporter", state, reason, details)


def build_adapter_stage(
    adapter_status: dict[str, Any],
    adapter_meta: dict[str, Any],
    context_meta: dict[str, Any],
    exporter_stage: StageAssessment,
    adapter_stale_sec: int,
    adapter_expired_sec: int,
) -> StageAssessment:
    if not adapter_meta.get("exists", False):
        return StageAssessment("adapter", ABSENT, "ADAPTER_STATUS_MISSING", {"meta": adapter_meta})

    acceptance = upper_text(adapter_status.get("last_acceptance_state"))
    packet_id = adapter_status.get("last_packet_id")
    exporter_packet = exporter_stage.details.get("packet_id")
    mtime_age = adapter_meta.get("age_seconds")

    if acceptance and acceptance != "ACCEPTED_SHADOW_ONLY":
        return StageAssessment(
            "adapter",
            BLOCKED,
            "ADAPTER_LAST_ACCEPTANCE_NOT_ACCEPTED_SHADOW_ONLY",
            {
                "meta": adapter_meta,
                "last_acceptance_state": acceptance,
                "last_rejection_reason": adapter_status.get("last_rejection_reason"),
                "packet_id": packet_id,
            },
        )

    if not isinstance(packet_id, str) or not packet_id.strip():
        return StageAssessment(
            "adapter",
            DEFAULTED_OR_INVALID,
            "ADAPTER_PACKET_ID_MISSING",
            {"meta": adapter_meta, "packet_id": packet_id},
        )

    if isinstance(mtime_age, int) and mtime_age > adapter_expired_sec:
        state = EXPIRED
        reason = "ADAPTER_STATUS_EXPIRED"
    elif isinstance(mtime_age, int) and mtime_age > adapter_stale_sec:
        state = STALE
        reason = "ADAPTER_STATUS_STALE"
    else:
        state = LIVE_VALID
        reason = "ADAPTER_FRESH"

    if isinstance(exporter_packet, str) and exporter_packet and exporter_packet != packet_id:
        state = HISTORICAL_ONLY
        reason = "ADAPTER_PACKET_ID_LAGS_EXPORTER"

    details = {
        "meta": adapter_meta,
        "packet_id": packet_id,
        "last_acceptance_state": acceptance or UNKNOWN,
        "last_rejection_reason": adapter_status.get("last_rejection_reason"),
        "last_run_timestamp": adapter_status.get("last_run_timestamp"),
        "last_run_age_seconds": age_seconds(adapter_status.get("last_run_timestamp")),
        "freshness_state": adapter_status.get("freshness_state"),
        "quality_state": adapter_status.get("quality_state"),
        "context_meta": context_meta,
    }
    return StageAssessment("adapter", state, reason, details)


def build_intake_stage(
    context: dict[str, Any],
    context_meta: dict[str, Any],
    context_status: dict[str, Any],
    context_status_meta: dict[str, Any],
    adapter_stage: StageAssessment,
    intake_stale_sec: int,
    intake_expired_sec: int,
) -> StageAssessment:
    if not context_meta.get("exists", False):
        return StageAssessment("intake", ABSENT, "MT5_CONTEXT_FILE_MISSING", {"context_meta": context_meta})
    if not context_status_meta.get("exists", False):
        return StageAssessment(
            "intake",
            ABSENT,
            "MT5_CONTEXT_STATUS_FILE_MISSING",
            {"context_status_meta": context_status_meta},
        )

    ctx_packet = context.get("packet_id")
    status_packet = context_status.get("packet_id")
    acceptance = upper_text(context_status.get("acceptance_state"))
    freshness = upper_text(context_status.get("freshness_state"))
    rejection = upper_text(context_status.get("rejection_reason"))
    status_age = context_status_meta.get("age_seconds")
    context_age = context_meta.get("age_seconds")

    if isinstance(ctx_packet, str) and isinstance(status_packet, str) and ctx_packet and status_packet and ctx_packet != status_packet:
        state = HISTORICAL_ONLY
        reason = "MT5_STATUS_PACKET_DIFFERS_FROM_CONTEXT_PACKET"
    elif freshness == "EXPIRED":
        state = EXPIRED
        reason = "MT5_STATUS_FRESHNESS_EXPIRED"
    elif "NOT_ATTACHED" in acceptance:
        state = NOT_ATTACHED
        reason = "MT5_STATUS_NOT_ATTACHED"
    elif rejection and rejection not in {"NONE", UNKNOWN}:
        state = BLOCKED
        reason = f"MT5_REJECTION_{rejection}"
    elif freshness == "FRESH" and "ATTACHED" in acceptance:
        state = LIVE_VALID
        reason = "MT5_SHADOW_ATTACHED_FRESH"
    elif isinstance(status_age, int) and status_age > intake_expired_sec:
        state = EXPIRED
        reason = "MT5_STATUS_FILE_EXPIRED"
    elif isinstance(status_age, int) and status_age > intake_stale_sec:
        state = STALE
        reason = "MT5_STATUS_FILE_STALE"
    else:
        state = UNKNOWN
        reason = "MT5_STATUS_STATE_UNRESOLVED"

    diagnostics: list[str] = []
    if state == EXPIRED and isinstance(context_age, int) and context_age < 120:
        diagnostics.append("status_expired_while_context_recent_possible_timekeeping_or_timestamp_normalization_mismatch")
    if adapter_stage.state == LIVE_VALID and state in {EXPIRED, NOT_ATTACHED, BLOCKED}:
        diagnostics.append("adapter_fresh_but_mt5_intake_not_live")

    details = {
        "context_meta": context_meta,
        "context_status_meta": context_status_meta,
        "context_packet_id": ctx_packet,
        "status_packet_id": status_packet,
        "acceptance_state": acceptance or UNKNOWN,
        "freshness_state": freshness or UNKNOWN,
        "rejection_reason": rejection or UNKNOWN,
        "status_timestamp": context_status.get("status_timestamp"),
        "event_time": context.get("event_time"),
        "fresh_until": context.get("fresh_until"),
        "event_age_seconds": age_seconds(context.get("event_time")),
        "fresh_until_age_seconds": age_seconds(context.get("fresh_until")),
        "diagnostic_flags": diagnostics,
    }
    return StageAssessment("intake", state, reason, details)


def build_advisory_stage(
    advisory: dict[str, Any],
    advisory_meta: dict[str, Any],
    intake_stage: StageAssessment,
    advisory_stale_sec: int,
    advisory_expired_sec: int,
) -> StageAssessment:
    if not advisory_meta.get("exists", False):
        return StageAssessment("advisory", ABSENT, "ADVISORY_STATUS_MISSING", {"meta": advisory_meta})

    freshness = upper_text(advisory.get("freshness_state"))
    eligible = advisory.get("advisory_eligible")
    state_txt = upper_text(advisory.get("advisory_state"))
    attach = upper_text(advisory.get("advisory_attachment_state"))
    gate = upper_text(advisory.get("gate_reason_code"))
    age = advisory_meta.get("age_seconds")

    if isinstance(age, int) and age > advisory_expired_sec:
        state = EXPIRED
        reason = "ADVISORY_STATUS_FILE_EXPIRED"
    elif isinstance(age, int) and age > advisory_stale_sec:
        state = STALE
        reason = "ADVISORY_STATUS_FILE_STALE"
    elif freshness == "EXPIRED":
        state = EXPIRED
        reason = "ADVISORY_FRESHNESS_EXPIRED"
    elif eligible is True and "ATTACHED" in attach and "INELIGIBLE" not in state_txt:
        state = LIVE_VALID
        reason = "ADVISORY_ELIGIBLE_AND_ATTACHED"
    elif "NOT_ATTACHED" in attach or "NOT_ATTACHED" in gate:
        state = NOT_ATTACHED
        reason = "ADVISORY_NOT_ATTACHED"
    elif eligible is False:
        state = INELIGIBLE
        reason = f"ADVISORY_INELIGIBLE_{gate or state_txt or 'UNKNOWN'}"
    else:
        state = BLOCKED
        reason = f"ADVISORY_BLOCKED_{gate or state_txt or 'UNKNOWN'}"

    if intake_stage.state != LIVE_VALID and state == LIVE_VALID:
        state = BLOCKED
        reason = "ADVISORY_REPORTED_LIVE_BUT_INTAKE_NOT_LIVE"

    details = {
        "meta": advisory_meta,
        "freshness_state": freshness or UNKNOWN,
        "advisory_eligible": eligible,
        "advisory_state": state_txt or UNKNOWN,
        "advisory_attachment_state": attach or UNKNOWN,
        "gate_reason_code": gate or UNKNOWN,
        "advisory_usage_state": advisory.get("advisory_usage_state"),
        "advisory_zero_effect_reason": advisory.get("advisory_zero_effect_reason"),
    }
    return StageAssessment("advisory", state, reason, details)


def determine_first_failing_gate(stages: list[StageAssessment]) -> dict[str, Any]:
    required_live_order = ["observation", "exporter", "adapter", "intake", "advisory"]
    by_name = {s.stage: s for s in stages}
    for name in required_live_order:
        stage = by_name.get(name)
        if stage is None:
            return {"stage": name, "state": ABSENT, "reason_code": "STAGE_NOT_PRODUCED"}
        if stage.state != LIVE_VALID:
            return {"stage": name, "state": stage.state, "reason_code": stage.reason_code}
    return {"stage": "NONE", "state": LIVE_VALID, "reason_code": "ALL_STAGES_LIVE_VALID"}


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")


def write_snapshot(path: Path, stage: StageAssessment, payload: dict[str, Any], meta: dict[str, Any]) -> None:
    write_json(
        path,
        {
            "captured_at_utc": utc_now_iso(),
            "stage": stage.as_dict(),
            "file_meta": meta,
            "payload": payload,
            "diagnostic_role": "ATAS_LIVE_CAPTURE_STAGE_SNAPSHOT_NON_AUTHORITATIVE",
        },
    )


def append_event(path: Path, event: dict[str, Any], max_events: int) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(event, ensure_ascii=False) + "\n")

    if max_events <= 0:
        return
    lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    if len(lines) <= max_events:
        return
    trimmed = lines[-max_events:]
    path.write_text("\n".join(trimmed) + "\n", encoding="utf-8")


def build_field_inventory(stage_payloads: dict[str, dict[str, Any]]) -> dict[str, Any]:
    required = {
        "observation": ["packet_id", "event_time", "source_symbol", "execution_symbol"],
        "exporter_status": ["last_run_timestamp", "packet_id", "write_status", "rejection_reason"],
        "acquisition_input": ["event_time", "source_symbol", "execution_symbol"],
        "producer_input": ["packet_id", "event_time", "source_symbol", "execution_symbol"],
        "adapter_status": ["last_run_timestamp", "last_packet_id", "last_acceptance_state", "freshness_state"],
        "context": ["packet_id", "event_time", "fresh_until", "source_symbol", "execution_symbol"],
        "context_status": ["status_timestamp", "packet_id", "acceptance_state", "freshness_state", "rejection_reason"],
        "advisory_status": ["evaluated_at", "advisory_state", "advisory_attachment_state", "advisory_eligible"],
    }
    stages: dict[str, Any] = {}
    for name, payload in stage_payloads.items():
        present = sorted(payload.keys()) if isinstance(payload, dict) else []
        req = required.get(name, [])
        missing = [k for k in req if k not in present]
        stages[name] = {
            "present_key_count": len(present),
            "required_key_count": len(req),
            "required_keys_missing": missing,
            "required_keys_present": [k for k in req if k in present],
            "sample_keys": present[:80],
        }
    return {
        "captured_at_utc": utc_now_iso(),
        "diagnostic_role": "ATAS_LIVE_CAPTURE_FIELD_INVENTORY_NON_AUTHORITATIVE",
        "stages": stages,
    }


def run_cycle(args: argparse.Namespace, paths: dict[str, Path]) -> dict[str, Any]:
    obs_payload, _ = read_json(paths["observation"])
    ind_payload, _ = read_json(paths["indicator_status"])
    acq_payload, _ = read_json(paths["acquisition_input"])
    producer_payload, _ = read_json(paths["producer_input"])
    exporter_payload, _ = read_json(paths["exporter_status"])
    adapter_payload, _ = read_json(paths["adapter_status"])
    context_payload, _, context_surface = read_json_with_fallback(
        paths["context"], paths["context_fallback"]
    )
    context_status_payload, _, context_status_surface = read_json_with_fallback(
        paths["context_status"], paths["context_status_fallback"]
    )
    advisory_payload, _ = read_json(paths["advisory_status"])
    context_path = Path(context_surface)
    context_status_path = Path(context_status_surface)

    observation_stage = build_observation_stage(
        obs_payload,
        file_meta(paths["observation"]),
        ind_payload,
        args.observation_stale_sec,
        args.observation_expired_sec,
    )
    exporter_stage = build_exporter_stage(
        exporter_payload,
        file_meta(paths["exporter_status"]),
        file_meta(paths["acquisition_input"]),
        file_meta(paths["producer_input"]),
        observation_stage,
        args.exporter_stale_sec,
        args.exporter_expired_sec,
    )
    adapter_stage = build_adapter_stage(
        adapter_payload,
        file_meta(paths["adapter_status"]),
        file_meta(context_path),
        exporter_stage,
        args.adapter_stale_sec,
        args.adapter_expired_sec,
    )
    intake_stage = build_intake_stage(
        context_payload,
        file_meta(context_path),
        context_status_payload,
        file_meta(context_status_path),
        adapter_stage,
        args.intake_stale_sec,
        args.intake_expired_sec,
    )
    advisory_stage = build_advisory_stage(
        advisory_payload,
        file_meta(paths["advisory_status"]),
        intake_stage,
        args.advisory_stale_sec,
        args.advisory_expired_sec,
    )

    stages = [observation_stage, exporter_stage, adapter_stage, intake_stage, advisory_stage]
    first_fail = determine_first_failing_gate(stages)
    chain_live_valid = first_fail["stage"] == "NONE"

    stage_payloads = {
        "observation": obs_payload,
        "exporter_status": exporter_payload,
        "acquisition_input": acq_payload,
        "producer_input": producer_payload,
        "adapter_status": adapter_payload,
        "context": context_payload,
        "context_status": context_status_payload,
        "advisory_status": advisory_payload,
    }

    output_dir = paths["output_dir"]
    output_dir.mkdir(parents=True, exist_ok=True)

    write_snapshot(output_dir / "latest_observation_snapshot.json", observation_stage, obs_payload, file_meta(paths["observation"]))
    write_snapshot(output_dir / "latest_exporter_snapshot.json", exporter_stage, exporter_payload, file_meta(paths["exporter_status"]))
    write_snapshot(output_dir / "latest_acquisition_input_snapshot.json", exporter_stage, acq_payload, file_meta(paths["acquisition_input"]))
    write_snapshot(output_dir / "latest_producer_input_snapshot.json", exporter_stage, producer_payload, file_meta(paths["producer_input"]))
    write_snapshot(output_dir / "latest_adapter_snapshot.json", adapter_stage, adapter_payload, file_meta(paths["adapter_status"]))
    write_snapshot(
        output_dir / "latest_mt5_intake_snapshot.json",
        intake_stage,
        context_status_payload,
        file_meta(context_status_path),
    )
    write_snapshot(
        output_dir / "latest_context_snapshot.json",
        intake_stage,
        context_payload,
        file_meta(context_path),
    )
    write_snapshot(output_dir / "latest_advisory_snapshot.json", advisory_stage, advisory_payload, file_meta(paths["advisory_status"]))

    chain_status = {
        "captured_at_utc": utc_now_iso(),
        "diagnostic_role": "ATAS_LIVE_CHAIN_STATUS_NON_AUTHORITATIVE",
        "chain_live_valid": chain_live_valid,
        "first_failing_gate": first_fail,
        "stages": [s.as_dict() for s in stages],
        "observation_packet_id": observation_stage.details.get("packet_id"),
        "exporter_packet_id": exporter_stage.details.get("packet_id"),
        "adapter_packet_id": adapter_stage.details.get("packet_id"),
        "context_packet_id": intake_stage.details.get("context_packet_id"),
        "context_status_packet_id": intake_stage.details.get("status_packet_id"),
        "context_surface": context_surface,
        "context_status_surface": context_status_surface,
    }
    write_json(output_dir / "atas_live_chain_status.json", chain_status)

    field_inventory = build_field_inventory(stage_payloads)
    write_json(output_dir / "atas_live_field_inventory.json", field_inventory)

    event = {
        "captured_at_utc": chain_status["captured_at_utc"],
        "first_failing_gate": first_fail,
        "observation_state": observation_stage.state,
        "exporter_state": exporter_stage.state,
        "adapter_state": adapter_stage.state,
        "intake_state": intake_stage.state,
        "advisory_state": advisory_stage.state,
        "observation_packet_id": observation_stage.details.get("packet_id"),
        "exporter_packet_id": exporter_stage.details.get("packet_id"),
        "adapter_packet_id": adapter_stage.details.get("packet_id"),
        "context_packet_id": intake_stage.details.get("context_packet_id"),
        "context_status_packet_id": intake_stage.details.get("status_packet_id"),
        "summary": (
            f"obs={observation_stage.state}; exp={exporter_stage.state}; "
            f"adp={adapter_stage.state}; intake={intake_stage.state}; adv={advisory_stage.state}"
        ),
    }
    append_event(output_dir / "atas_live_event_stream.jsonl", event, args.max_events)

    return chain_status


def resolve_paths(terminal_root: Path, output_dir: Path | None) -> dict[str, Path]:
    files_ai = terminal_root / "MQL5" / "Files" / "AI"
    adapter_root = files_ai / "external_adapter" / "atas_semantic_adapter"
    default_output = files_ai / "atas_live_capture"
    return {
        "files_ai": files_ai,
        "adapter_root": adapter_root,
        "observation": adapter_root / "future_exporter" / "runtime" / "acquisition_source" / "atas_observation_export.json",
        "indicator_status": adapter_root / "atas_indicator_exporter" / "runtime" / "atas_indicator_exporter_status.json",
        "acquisition_input": adapter_root / "future_exporter" / "runtime" / "acquisition_input" / "acquisition_input_payload.json",
        "producer_input": adapter_root / "runtime" / "producer_input" / "atas_export_payload.json",
        "exporter_status": adapter_root / "future_exporter" / "runtime" / "exporter_status.json",
        "adapter_status": adapter_root / "runtime" / "adapter_status.json",
        "context": files_ai / "atas_microstructure_context.json",
        "context_status": files_ai / "atas_microstructure_status.json",
        "context_fallback": files_ai / "atas_runtime_context.json",
        "context_status_fallback": files_ai / "atas_runtime_context_status.json",
        "advisory_status": files_ai / "atas_governed_advisory_status.json",
        "output_dir": output_dir or default_output,
    }


def parse_args() -> argparse.Namespace:
    script_terminal = Path(__file__).resolve().parents[5]
    parser = argparse.ArgumentParser(
        description="Bounded ATAS live chain diagnostic capture (read-only observer, non-authoritative)."
    )
    parser.add_argument("--terminal-root", default=str(script_terminal))
    parser.add_argument("--output-dir", default="")
    parser.add_argument("--interval-sec", type=float, default=2.0)
    parser.add_argument("--iterations", type=int, default=0, help="0 means run continuously.")
    parser.add_argument("--max-events", type=int, default=2000)
    parser.add_argument("--observation-stale-sec", type=int, default=30)
    parser.add_argument("--observation-expired-sec", type=int, default=120)
    parser.add_argument("--exporter-stale-sec", type=int, default=30)
    parser.add_argument("--exporter-expired-sec", type=int, default=120)
    parser.add_argument("--adapter-stale-sec", type=int, default=30)
    parser.add_argument("--adapter-expired-sec", type=int, default=120)
    parser.add_argument("--intake-stale-sec", type=int, default=45)
    parser.add_argument("--intake-expired-sec", type=int, default=180)
    parser.add_argument("--advisory-stale-sec", type=int, default=45)
    parser.add_argument("--advisory-expired-sec", type=int, default=180)
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    terminal_root = Path(args.terminal_root).resolve()
    output_dir = Path(args.output_dir).resolve() if args.output_dir else None
    paths = resolve_paths(terminal_root, output_dir)

    runs = 0
    while True:
        chain = run_cycle(args, paths)
        first = chain.get("first_failing_gate", {})
        print(
            f"[{chain.get('captured_at_utc')}] "
            f"chain_live_valid={chain.get('chain_live_valid')} "
            f"first_failing_gate={first.get('stage')} "
            f"state={first.get('state')} "
            f"reason={first.get('reason_code')}"
        )
        runs += 1
        if args.iterations > 0 and runs >= args.iterations:
            break
        time.sleep(max(0.2, args.interval_sec))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
