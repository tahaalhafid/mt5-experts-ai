from __future__ import annotations

import argparse
import json
import subprocess
import time
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path
from typing import Any


def utc_now() -> datetime:
    return datetime.now(UTC)


def utc_now_iso() -> str:
    return utc_now().isoformat().replace("+00:00", "Z")


def local_tzinfo():
    return datetime.now().astimezone().tzinfo


def parse_iso(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    if text.endswith("Z"):
        text = text[:-1] + "+00:00"
    if " " in text and "T" not in text and "." in text:
        text = text.replace(" ", "T", 1)
    try:
        dt = datetime.fromisoformat(text)
    except ValueError:
        return None
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=UTC)
    return dt.astimezone(UTC)


def parse_mt5_local(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    for fmt in ("%Y.%m.%d %H:%M:%S", "%Y-%m-%d %H:%M:%S"):
        try:
            naive = datetime.strptime(text, fmt)
            return naive.replace(tzinfo=local_tzinfo()).astimezone(UTC)
        except ValueError:
            continue
    return None


def parse_any_timestamp(value: Any) -> datetime | None:
    return parse_iso(value) or parse_mt5_local(value)


def parse_iso_as_local_ignore_tz(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    text = value.strip()
    if not text:
        return None
    z_pos = text.find("Z")
    if z_pos > 0:
        text = text[:z_pos]
    plus = text.find("+", 10)
    minus = text.find("-", 10)
    cut = -1
    if plus > 0:
        cut = plus
    if minus > 0 and (cut < 0 or minus < cut):
        cut = minus
    if cut > 0:
        text = text[:cut]
    text = text.replace("T", " ").replace("-", ".")
    if len(text) >= 19:
        text = text[:19]
    try:
        naive = datetime.strptime(text, "%Y.%m.%d %H:%M:%S")
    except ValueError:
        return None
    return naive.replace(tzinfo=local_tzinfo()).astimezone(UTC)


def safe_int(value: Any) -> int | None:
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float):
        return int(value)
    if isinstance(value, str):
        try:
            return int(float(value.strip()))
        except ValueError:
            return None
    return None


def read_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    try:
        raw = path.read_text(encoding="utf-8", errors="replace")
        data = json.loads(raw)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


def read_json_with_fallback(primary: Path, legacy_fallback: Path) -> tuple[dict[str, Any], Path]:
    primary_payload = read_json(primary)
    if primary_payload:
        return primary_payload, primary

    fallback_payload = read_json(legacy_fallback)
    if fallback_payload:
        return fallback_payload, legacy_fallback

    return primary_payload, primary


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


def run_command(cmd: list[str], cwd: Path, timeout_sec: int) -> dict[str, Any]:
    started = utc_now_iso()
    try:
        proc = subprocess.run(
            cmd,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            timeout=timeout_sec,
            check=False,
        )
        return {
            "started_at_utc": started,
            "finished_at_utc": utc_now_iso(),
            "cwd": str(cwd),
            "command": cmd,
            "exit_code": int(proc.returncode),
            "stdout_tail": (proc.stdout or "")[-2500:],
            "stderr_tail": (proc.stderr or "")[-2500:],
            "timed_out": False,
        }
    except subprocess.TimeoutExpired as ex:
        return {
            "started_at_utc": started,
            "finished_at_utc": utc_now_iso(),
            "cwd": str(cwd),
            "command": cmd,
            "exit_code": None,
            "stdout_tail": ((ex.stdout or "")[-2500:] if isinstance(ex.stdout, str) else ""),
            "stderr_tail": ((ex.stderr or "")[-2500:] if isinstance(ex.stderr, str) else ""),
            "timed_out": True,
        }


@dataclass
class Paths:
    terminal_root: Path
    observation: Path
    exporter_status: Path
    acquisition_input: Path
    producer_input: Path
    adapter_status: Path
    context: Path
    context_status: Path
    context_fallback: Path
    context_status_fallback: Path
    advisory_status: Path
    capture_dir: Path
    exporter_src_dir: Path
    adapter_src_dir: Path


def build_paths() -> Paths:
    terminal_root = Path(__file__).resolve().parents[5]
    files_ai = terminal_root / "MQL5" / "Files" / "AI"
    adapter_root = files_ai / "external_adapter" / "atas_semantic_adapter"
    capture_dir = files_ai / "atas_live_capture"
    capture_dir.mkdir(parents=True, exist_ok=True)
    return Paths(
        terminal_root=terminal_root,
        observation=adapter_root
        / "future_exporter"
        / "runtime"
        / "acquisition_source"
        / "atas_observation_export.json",
        exporter_status=adapter_root / "future_exporter" / "runtime" / "exporter_status.json",
        acquisition_input=adapter_root
        / "future_exporter"
        / "runtime"
        / "acquisition_input"
        / "acquisition_input_payload.json",
        producer_input=adapter_root / "runtime" / "producer_input" / "atas_export_payload.json",
        adapter_status=adapter_root / "runtime" / "adapter_status.json",
        context=files_ai / "atas_microstructure_context.json",
        context_status=files_ai / "atas_microstructure_status.json",
        context_fallback=files_ai / "atas_runtime_context.json",
        context_status_fallback=files_ai / "atas_runtime_context_status.json",
        advisory_status=files_ai / "atas_governed_advisory_status.json",
        capture_dir=capture_dir,
        exporter_src_dir=adapter_root / "future_exporter" / "src",
        adapter_src_dir=adapter_root / "src",
    )


def state_or_default(text: Any, default: str) -> str:
    if isinstance(text, str) and text.strip():
        return text.strip()
    return default


def analyze_cycle(cycle_index: int, prev: dict[str, Any], p: Paths) -> dict[str, Any]:
    obs_before = read_json(p.observation)
    obs_before_meta = file_meta(p.observation)

    exporter_cmd = [
        "dotnet",
        "run",
        "--project",
        "AtasRealExporter.csproj",
        "--",
        "--input-mode",
        "ACQUISITION_SOURCE_FILE",
        "--acquisition-source-type",
        "ATAS_EXPORT_FILE_DROP",
        "--acquisition-source-input",
        "..\\runtime\\acquisition_source\\atas_observation_export.json",
        "--acquisition-input",
        "..\\runtime\\acquisition_input\\acquisition_input_payload.json",
        "--config",
        "..\\config\\atas_exporter_runtime_config.example.json",
    ]
    exporter_exec = run_command(exporter_cmd, p.exporter_src_dir, timeout_sec=90)

    time.sleep(1.0)
    exporter_status = read_json(p.exporter_status)
    exporter_meta = file_meta(p.exporter_status)
    acq_meta = file_meta(p.acquisition_input)
    producer_meta = file_meta(p.producer_input)
    obs_after_exporter = read_json(p.observation)

    adapter_cmd = [
        "dotnet",
        "run",
        "--project",
        "AtasSemanticAdapter.csproj",
        "--",
        "--input-mode",
        "PRODUCER_INPUT_FILE",
        "--producer-file",
        "atas_export_payload.json",
        "--config",
        "..\\config\\adapter_config.example.json",
        "--symbol-map",
        "..\\config\\symbol_map.example.json",
    ]
    adapter_exec = run_command(adapter_cmd, p.adapter_src_dir, timeout_sec=90)

    time.sleep(3.0)
    adapter_status = read_json(p.adapter_status)
    adapter_meta = file_meta(p.adapter_status)
    context, context_surface = read_json_with_fallback(p.context, p.context_fallback)
    context_meta = file_meta(context_surface)
    context_status, context_status_surface = read_json_with_fallback(
        p.context_status, p.context_status_fallback
    )
    context_status_meta = file_meta(context_status_surface)
    advisory = read_json(p.advisory_status)
    advisory_meta = file_meta(p.advisory_status)
    obs_after_cycle = read_json(p.observation)

    observation_packet_before = state_or_default(obs_before.get("packet_id"), "MISSING")
    observation_packet_after_exporter = state_or_default(
        obs_after_exporter.get("packet_id"), "MISSING"
    )
    observation_packet_after_cycle = state_or_default(obs_after_cycle.get("packet_id"), "MISSING")
    exporter_packet = state_or_default(exporter_status.get("packet_id"), "MISSING")
    adapter_packet = state_or_default(adapter_status.get("last_packet_id"), "MISSING")
    context_packet = state_or_default(context.get("packet_id"), "MISSING")
    status_packet = state_or_default(context_status.get("packet_id"), "MISSING")

    exporter_consumed_newest_observation = exporter_packet in {
        observation_packet_before,
        observation_packet_after_exporter,
    }
    adapter_consumed_newest_exporter = adapter_packet == exporter_packet
    intake_saw_newest_adapter_output = status_packet == adapter_packet and context_packet == adapter_packet

    freshness_state = state_or_default(context_status.get("freshness_state"), "UNKNOWN")
    acceptance_state = state_or_default(context_status.get("acceptance_state"), "UNKNOWN")
    rejection_reason = state_or_default(context_status.get("rejection_reason"), "UNKNOWN")
    adapter_acceptance_state = state_or_default(adapter_status.get("last_acceptance_state"), "UNKNOWN")
    adapter_rejection_reason = state_or_default(adapter_status.get("last_rejection_reason"), "UNKNOWN")
    advisory_eligible = advisory.get("advisory_eligible")
    advisory_state = state_or_default(advisory.get("advisory_state"), "UNKNOWN")
    advisory_gate_reason = state_or_default(advisory.get("gate_reason_code"), "UNKNOWN")

    event_time_text = context.get("event_time") or context_status.get("event_time")
    fresh_until_text = context.get("fresh_until")
    status_eval_text = context_status.get("evaluated_at") or context_status.get("status_timestamp")

    event_utc = parse_any_timestamp(event_time_text)
    fresh_until_utc = parse_any_timestamp(fresh_until_text)
    status_eval_utc = parse_any_timestamp(status_eval_text)
    status_file_mtime_utc = parse_iso(context_status_meta.get("mtime_utc"))
    eval_anchor = status_eval_utc or status_file_mtime_utc

    freshness_breakdown: dict[str, Any] = {
        "event_time": event_time_text,
        "fresh_until": fresh_until_text,
        "status_evaluated_at": status_eval_text,
        "event_time_utc": event_utc.isoformat().replace("+00:00", "Z") if event_utc else None,
        "fresh_until_utc": fresh_until_utc.isoformat().replace("+00:00", "Z") if fresh_until_utc else None,
        "status_eval_utc": eval_anchor.isoformat().replace("+00:00", "Z") if eval_anchor else None,
    }

    if event_utc and eval_anchor:
        freshness_breakdown["age_seconds_at_eval_utc"] = int((eval_anchor - event_utc).total_seconds())
    if fresh_until_utc and eval_anchor:
        freshness_breakdown["fresh_margin_seconds_at_eval_utc"] = int(
            (fresh_until_utc - eval_anchor).total_seconds()
        )
        freshness_breakdown["expired_by_seconds_at_eval_utc"] = max(
            0, int((eval_anchor - fresh_until_utc).total_seconds())
        )

    packet_age_ms_emitted = safe_int(context_status.get("packet_age_ms"))
    event_local_ignoring_tz = parse_iso_as_local_ignore_tz(event_time_text)
    age_ms_utc = None
    age_ms_local_ignore_tz = None
    if event_utc and eval_anchor:
        age_ms_utc = int((eval_anchor - event_utc).total_seconds() * 1000)
    if event_local_ignoring_tz and eval_anchor:
        age_ms_local_ignore_tz = int((eval_anchor - event_local_ignoring_tz).total_seconds() * 1000)

    packet_age_alignment = "UNVERIFIABLE"
    if packet_age_ms_emitted is not None and age_ms_utc is not None and age_ms_local_ignore_tz is not None:
        delta_utc = abs(packet_age_ms_emitted - age_ms_utc)
        delta_local = abs(packet_age_ms_emitted - age_ms_local_ignore_tz)
        if delta_utc < delta_local:
            packet_age_alignment = "ALIGNED_WITH_UTC_EVENT_TIME"
        elif delta_local < delta_utc:
            packet_age_alignment = "ALIGNED_WITH_LOCALIZED_EVENT_TIME_IGNORING_TZ"
        else:
            packet_age_alignment = "AMBIGUOUS_ALIGNMENT"
        freshness_breakdown["packet_age_alignment_deltas"] = {
            "emitted_packet_age_ms": packet_age_ms_emitted,
            "expected_age_ms_utc": age_ms_utc,
            "expected_age_ms_local_ignore_tz": age_ms_local_ignore_tz,
            "delta_to_utc_ms": delta_utc,
            "delta_to_local_ignore_tz_ms": delta_local,
            "alignment": packet_age_alignment,
        }

    stage_outcome = {
        "exporter_consumed_newest_observation": exporter_consumed_newest_observation,
        "adapter_consumed_newest_exporter": adapter_consumed_newest_exporter,
        "adapter_acceptance_state": adapter_acceptance_state,
        "adapter_rejection_reason": adapter_rejection_reason,
        "adapter_run_exit_code": adapter_exec.get("exit_code"),
        "adapter_context_written": context_packet == adapter_packet and context_packet != "MISSING",
        "intake_saw_newest_adapter_output": intake_saw_newest_adapter_output,
        "mt5_freshness_state": freshness_state,
        "mt5_acceptance_state": acceptance_state,
        "mt5_rejection_reason": rejection_reason,
        "mt5_expired": freshness_state.upper() == "EXPIRED",
        "advisory_eligible": advisory_eligible,
        "advisory_state": advisory_state,
        "advisory_gate_reason_code": advisory_gate_reason,
    }

    packet_progression = {
        "observation_packet_before": observation_packet_before,
        "observation_packet_after_exporter": observation_packet_after_exporter,
        "observation_packet_after_cycle": observation_packet_after_cycle,
        "exporter_packet_id": exporter_packet,
        "adapter_packet_id": adapter_packet,
        "context_packet_id": context_packet,
        "context_status_packet_id": status_packet,
        "changed_since_prev": {
            "observation": observation_packet_after_cycle
            != state_or_default(prev.get("observation_packet_after_cycle"), "MISSING"),
            "exporter": exporter_packet
            != state_or_default(prev.get("exporter_packet_id"), "MISSING"),
            "adapter": adapter_packet
            != state_or_default(prev.get("adapter_packet_id"), "MISSING"),
            "context": context_packet
            != state_or_default(prev.get("context_packet_id"), "MISSING"),
            "status": status_packet != state_or_default(prev.get("context_status_packet_id"), "MISSING"),
        },
    }

    timestamp_progression = {
        "observation_mtime_utc": obs_before_meta.get("mtime_utc"),
        "exporter_status_mtime_utc": exporter_meta.get("mtime_utc"),
        "adapter_status_mtime_utc": adapter_meta.get("mtime_utc"),
        "context_mtime_utc": context_meta.get("mtime_utc"),
        "context_status_mtime_utc": context_status_meta.get("mtime_utc"),
        "advisory_status_mtime_utc": advisory_meta.get("mtime_utc"),
    }

    first_failing_gate = None
    if not exporter_consumed_newest_observation:
        first_failing_gate = {
            "stage": "exporter",
            "reason_code": "EXPORTER_DID_NOT_CONSUME_NEWEST_OBSERVATION",
        }
    elif not adapter_consumed_newest_exporter:
        first_failing_gate = {
            "stage": "adapter",
            "reason_code": "ADAPTER_DID_NOT_CONSUME_NEWEST_EXPORTER_PAYLOAD",
        }
    elif adapter_exec.get("exit_code") not in (0, None):
        first_failing_gate = {
            "stage": "adapter",
            "reason_code": f"ADAPTER_RUN_EXIT_{adapter_exec.get('exit_code')}",
        }
    elif adapter_acceptance_state != "ACCEPTED_SHADOW_ONLY":
        first_failing_gate = {
            "stage": "adapter",
            "reason_code": f"ADAPTER_{adapter_rejection_reason}",
        }
    elif not intake_saw_newest_adapter_output:
        first_failing_gate = {
            "stage": "intake",
            "reason_code": "INTAKE_DID_NOT_REFLECT_NEWEST_ADAPTER_PACKET",
        }
    elif freshness_state.upper() == "EXPIRED":
        first_failing_gate = {"stage": "intake", "reason_code": rejection_reason}
    elif advisory_eligible is False:
        first_failing_gate = {"stage": "advisory", "reason_code": advisory_gate_reason}

    cycle = {
        "cycle_index": cycle_index,
        "captured_at_utc": utc_now_iso(),
        "exporter_run": exporter_exec,
        "adapter_run": adapter_exec,
        "packet_progression": packet_progression,
        "timestamp_progression": timestamp_progression,
        "stage_outcome": stage_outcome,
        "freshness_breakdown": freshness_breakdown,
        "first_failing_gate": first_failing_gate,
        "files": {
            "observation": file_meta(p.observation),
            "exporter_status": exporter_meta,
            "acquisition_input": acq_meta,
            "producer_input": producer_meta,
            "adapter_status": adapter_meta,
            "context": context_meta,
            "context_status": context_status_meta,
            "advisory_status": advisory_meta,
            "context_source_surface": str(context_surface),
            "context_status_source_surface": str(context_status_surface),
        },
    }
    return cycle


def classify_root_cause(cycles: list[dict[str, Any]]) -> dict[str, Any]:
    if not cycles:
        return {"classification": "OTHER", "reason": "NO_CYCLES_CAPTURED"}

    exporter_lag_cycles = 0
    adapter_lag_cycles = 0
    adapter_rejected_cycles = 0
    intake_packet_lag_cycles = 0
    intake_expired_cycles = 0
    tz_alignment_local_like = 0
    tz_alignment_utc_like = 0
    freshness_margin_positive_while_expired = 0

    for c in cycles:
        stage = c.get("stage_outcome", {})
        if not stage.get("exporter_consumed_newest_observation", False):
            exporter_lag_cycles += 1
        if not stage.get("adapter_consumed_newest_exporter", False):
            adapter_lag_cycles += 1
        if str(stage.get("adapter_acceptance_state", "")).upper() != "ACCEPTED_SHADOW_ONLY":
            adapter_rejected_cycles += 1
        if not stage.get("intake_saw_newest_adapter_output", False):
            intake_packet_lag_cycles += 1
        if str(stage.get("mt5_freshness_state", "")).upper() == "EXPIRED":
            intake_expired_cycles += 1
            margin = c.get("freshness_breakdown", {}).get("fresh_margin_seconds_at_eval_utc")
            if isinstance(margin, int) and margin > 0:
                freshness_margin_positive_while_expired += 1
        align = (
            c.get("freshness_breakdown", {})
            .get("packet_age_alignment_deltas", {})
            .get("alignment", "")
        )
        if align == "ALIGNED_WITH_LOCALIZED_EVENT_TIME_IGNORING_TZ":
            tz_alignment_local_like += 1
        elif align == "ALIGNED_WITH_UTC_EVENT_TIME":
            tz_alignment_utc_like += 1

    flags = []
    if exporter_lag_cycles > 0:
        flags.append("EXPORTER_CADENCE_OR_ORCHESTRATION_GAP")
    if adapter_lag_cycles > 0:
        flags.append("ADAPTER_CADENCE_OR_CONSUMPTION_GAP")
    if adapter_rejected_cycles > 0:
        flags.append("ATTACHMENT_REQUIRES_ANOTHER_GATE_BEYOND_FRESHNESS")
    if intake_packet_lag_cycles > 0:
        flags.append("INTAKE_READING_OLD_CONTEXT")
    if intake_expired_cycles > 0:
        flags.append("INTAKE_FRESHNESS_REJECTION_ACTIVE")
    if freshness_margin_positive_while_expired > 0:
        flags.append("TIMESTAMP_FIELD_MISMATCH")
    if tz_alignment_local_like > tz_alignment_utc_like:
        flags.append("TIMEZONE_OR_CLOCK_SKEW")

    if not flags:
        classification = "OTHER"
    elif len(flags) == 1:
        classification = flags[0]
    else:
        classification = "MIXED_FAILURE"

    return {
        "classification": classification,
        "flags": flags,
        "counts": {
            "total_cycles": len(cycles),
            "exporter_lag_cycles": exporter_lag_cycles,
            "adapter_lag_cycles": adapter_lag_cycles,
            "adapter_rejected_cycles": adapter_rejected_cycles,
            "intake_packet_lag_cycles": intake_packet_lag_cycles,
            "intake_expired_cycles": intake_expired_cycles,
            "tz_alignment_local_like": tz_alignment_local_like,
            "tz_alignment_utc_like": tz_alignment_utc_like,
            "freshness_margin_positive_while_expired": freshness_margin_positive_while_expired,
        },
    }


def write_json(path: Path, payload: dict[str, Any]) -> None:
    path.write_text(json.dumps(payload, indent=2), encoding="utf-8")


def write_jsonl(path: Path, rows: list[dict[str, Any]]) -> None:
    with path.open("w", encoding="utf-8") as f:
        for row in rows:
            f.write(json.dumps(row, ensure_ascii=False) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Bounded periodic ATAS exporter/adapter propagation validation + freshness isolation."
    )
    parser.add_argument("--cycles", type=int, default=6, help="Number of cycles to run.")
    parser.add_argument(
        "--cycle-interval-sec",
        type=float,
        default=8.0,
        help="Sleep between cycles after each capture.",
    )
    parser.add_argument(
        "--refresh-monitor-once",
        action="store_true",
        help="Run single-shot monitor refresh after cycle run.",
    )
    args = parser.parse_args()

    cycles = max(1, min(args.cycles, 20))
    interval_sec = max(1.0, min(args.cycle_interval_sec, 120.0))
    paths = build_paths()
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")

    all_rows: list[dict[str, Any]] = []
    prev_packets: dict[str, Any] = {}
    for i in range(1, cycles + 1):
        row = analyze_cycle(i, prev_packets, paths)
        all_rows.append(row)
        prev_packets = row.get("packet_progression", {})
        print(
            f"[cycle {i}] exporter={row['packet_progression']['exporter_packet_id']} "
            f"adapter={row['packet_progression']['adapter_packet_id']} "
            f"status={row['packet_progression']['context_status_packet_id']} "
            f"freshness={row['stage_outcome']['mt5_freshness_state']} "
            f"acceptance={row['stage_outcome']['mt5_acceptance_state']}"
        )
        if i < cycles:
            time.sleep(interval_sec)

    root = classify_root_cause(all_rows)
    first_fail = None
    for row in all_rows:
        ff = row.get("first_failing_gate")
        if ff:
            first_fail = ff
            break

    summary = {
        "captured_at_utc": utc_now_iso(),
        "diagnostic_role": "ATAS_PERIODIC_PROPAGATION_VALIDATION_NON_AUTHORITATIVE",
        "total_cycles": cycles,
        "first_failing_gate_observed": first_fail,
        "root_cause_isolation": root,
        "latest_cycle": all_rows[-1] if all_rows else {},
    }

    freshness_isolation = {
        "captured_at_utc": utc_now_iso(),
        "diagnostic_role": "ATAS_FRESHNESS_ISOLATION_NON_AUTHORITATIVE",
        "root_cause_isolation": root,
        "cycle_freshness_breakdown": [
            {
                "cycle_index": row.get("cycle_index"),
                "packet_ids": row.get("packet_progression"),
                "stage_outcome": row.get("stage_outcome"),
                "freshness_breakdown": row.get("freshness_breakdown"),
            }
            for row in all_rows
        ],
    }

    cycles_path = paths.capture_dir / f"periodic_validation_cycles_{ts}.jsonl"
    cycles_latest = paths.capture_dir / "periodic_validation_cycles_latest.jsonl"
    summary_path = paths.capture_dir / f"periodic_validation_summary_{ts}.json"
    summary_latest = paths.capture_dir / "periodic_validation_summary_latest.json"
    fresh_path = paths.capture_dir / f"freshness_isolation_report_{ts}.json"
    fresh_latest = paths.capture_dir / "freshness_isolation_report_latest.json"

    write_jsonl(cycles_path, all_rows)
    write_jsonl(cycles_latest, all_rows)
    write_json(summary_path, summary)
    write_json(summary_latest, summary)
    write_json(fresh_path, freshness_isolation)
    write_json(fresh_latest, freshness_isolation)

    if args.refresh_monitor_once:
        monitor = Path(__file__).resolve().parent / "atas_live_capture_monitor.py"
        subprocess.run(
            [
                "python",
                str(monitor),
                "--iterations",
                "1",
                "--interval-sec",
                "1",
                "--max-events",
                "2000",
            ],
            check=False,
        )

    print(f"cycles_jsonl={cycles_path}")
    print(f"summary_json={summary_path}")
    print(f"freshness_json={fresh_path}")
    print(f"classification={root.get('classification')}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
