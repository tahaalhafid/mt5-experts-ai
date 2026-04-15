from __future__ import annotations

import argparse
import json
import os
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


def parse_iso(value: Any) -> datetime | None:
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


def parse_mt5_local(value: Any) -> datetime | None:
    if not isinstance(value, str):
        return None
    raw = value.strip()
    if not raw:
        return None
    for fmt in ("%Y.%m.%d %H:%M:%S", "%Y-%m-%d %H:%M:%S"):
        try:
            naive = datetime.strptime(raw, fmt)
            local_tz = datetime.now().astimezone().tzinfo
            if local_tz is None:
                local_tz = UTC
            return naive.replace(tzinfo=local_tz).astimezone(UTC)
        except ValueError:
            continue
    return None


def parse_any_timestamp(value: Any) -> datetime | None:
    return parse_iso(value) or parse_mt5_local(value)


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


def age_seconds(value: Any) -> int | None:
    dt = parse_any_timestamp(value)
    if dt is None:
        return None
    age = int((utc_now() - dt).total_seconds())
    return max(age, 0)


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
            "timed_out": False,
            "stdout_tail": (proc.stdout or "")[-2500:],
            "stderr_tail": (proc.stderr or "")[-2500:],
        }
    except subprocess.TimeoutExpired as ex:
        return {
            "started_at_utc": started,
            "finished_at_utc": utc_now_iso(),
            "cwd": str(cwd),
            "command": cmd,
            "exit_code": None,
            "timed_out": True,
            "stdout_tail": ((ex.stdout or "")[-2500:] if isinstance(ex.stdout, str) else ""),
            "stderr_tail": ((ex.stderr or "")[-2500:] if isinstance(ex.stderr, str) else ""),
        }


def write_json_atomic(path: Path, payload: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temp_path = path.with_suffix(path.suffix + ".tmp")
    temp_path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    temp_path.replace(path)


def append_jsonl(path: Path, row: dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as fh:
        fh.write(json.dumps(row, ensure_ascii=False))
        fh.write("\n")


def trim_jsonl(path: Path, max_events: int) -> None:
    if max_events <= 0 or not path.exists():
        return
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").splitlines()
    except Exception:
        return
    if len(lines) <= max_events:
        return
    tail = lines[-max_events:]
    path.write_text("\n".join(tail) + "\n", encoding="utf-8")


@dataclass
class Paths:
    terminal_root: Path
    files_ai: Path
    capture_dir: Path
    adapter_root: Path
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
    exporter_src_dir: Path
    adapter_src_dir: Path
    runner_status_file: Path
    runner_events_file: Path
    runner_lock_file: Path
    runner_stop_file: Path


def build_paths() -> Paths:
    terminal_root = Path(__file__).resolve().parents[5]
    files_ai = terminal_root / "MQL5" / "Files" / "AI"
    capture_dir = files_ai / "atas_live_capture"
    adapter_root = files_ai / "external_adapter" / "atas_semantic_adapter"
    capture_dir.mkdir(parents=True, exist_ok=True)
    return Paths(
        terminal_root=terminal_root,
        files_ai=files_ai,
        capture_dir=capture_dir,
        adapter_root=adapter_root,
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
        exporter_src_dir=adapter_root / "future_exporter" / "src",
        adapter_src_dir=adapter_root / "src",
        runner_status_file=capture_dir / "atas_propagation_runner_status.json",
        runner_events_file=capture_dir / "atas_propagation_runner_events.jsonl",
        runner_lock_file=capture_dir / "atas_propagation_runner.lock",
        runner_stop_file=capture_dir / "atas_propagation_runner.stop",
    )


def build_exporter_command() -> list[str]:
    return [
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


def build_adapter_command() -> list[str]:
    return [
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


def snapshot(paths: Paths) -> dict[str, Any]:
    observation = read_json(paths.observation)
    exporter = read_json(paths.exporter_status)
    adapter = read_json(paths.adapter_status)
    context, context_surface = read_json_with_fallback(paths.context, paths.context_fallback)
    context_status, context_status_surface = read_json_with_fallback(
        paths.context_status, paths.context_status_fallback
    )
    advisory = read_json(paths.advisory_status)

    context_event_time = context.get("event_time")
    context_fresh_until = context.get("fresh_until")
    status_eval = context_status.get("evaluated_at") or context_status.get("status_timestamp")

    return {
        "captured_at_utc": utc_now_iso(),
        "observation": {
            "packet_id": observation.get("packet_id"),
            "event_time": observation.get("event_time"),
            "meta": file_meta(paths.observation),
        },
        "exporter": {
            "packet_id": exporter.get("packet_id"),
            "last_run_timestamp": exporter.get("last_run_timestamp"),
            "write_status": exporter.get("write_status"),
            "rejection_reason": exporter.get("rejection_reason"),
            "meta": file_meta(paths.exporter_status),
            "acquisition_input_meta": file_meta(paths.acquisition_input),
            "producer_input_meta": file_meta(paths.producer_input),
        },
        "adapter": {
            "last_packet_id": adapter.get("last_packet_id"),
            "last_acceptance_state": adapter.get("last_acceptance_state"),
            "last_rejection_reason": adapter.get("last_rejection_reason"),
            "evaluated_at": adapter.get("evaluated_at"),
            "meta": file_meta(paths.adapter_status),
        },
        "context": {
            "packet_id": context.get("packet_id"),
            "event_time": context_event_time,
            "fresh_until": context_fresh_until,
            "event_age_seconds_utc": age_seconds(context_event_time),
            "fresh_until_margin_seconds_utc": (
                None
                if parse_any_timestamp(context_fresh_until) is None
                else int((parse_any_timestamp(context_fresh_until) - utc_now()).total_seconds())
            ),
            "source_surface": str(context_surface),
            "meta": file_meta(context_surface),
        },
        "context_status": {
            "packet_id": context_status.get("packet_id") or context_status.get("last_packet_id"),
            "acceptance_state": context_status.get("acceptance_state")
            or context_status.get("last_acceptance_state"),
            "rejection_reason": context_status.get("rejection_reason")
            or context_status.get("last_rejection_reason"),
            "freshness_state": context_status.get("freshness_state"),
            "evaluated_at": status_eval,
            "evaluated_age_seconds_utc": age_seconds(status_eval),
            "packet_age_ms": context_status.get("packet_age_ms"),
            "shadow_attached": context_status.get("atas_shadow_attached")
            if "atas_shadow_attached" in context_status
            else context_status.get("shadow_attached"),
            "source_surface": str(context_status_surface),
            "meta": file_meta(context_status_surface),
        },
        "advisory": {
            "advisory_eligible": advisory.get("advisory_eligible"),
            "gate_reason_code": advisory.get("gate_reason_code"),
            "advisory_state": advisory.get("advisory_state"),
            "attachment_state": advisory.get("attachment_state"),
            "usage_state": advisory.get("usage_state"),
            "meta": file_meta(paths.advisory_status),
        },
    }


def first_failing_gate(
    exporter_exec: dict[str, Any], adapter_exec: dict[str, Any], snap_after: dict[str, Any]
) -> str:
    if exporter_exec.get("timed_out"):
        return "EXPORTER_TIMEOUT"
    if exporter_exec.get("exit_code") not in (0,):
        return "EXPORTER_EXECUTION_FAILED"
    if adapter_exec.get("timed_out"):
        return "ADAPTER_TIMEOUT"
    if adapter_exec.get("exit_code") not in (0,):
        return "ADAPTER_EXECUTION_FAILED"

    context_status = snap_after.get("context_status", {})
    acceptance = str(context_status.get("acceptance_state") or "").strip().upper()
    rejection = str(context_status.get("rejection_reason") or "").strip().upper()
    if acceptance == "SHADOW_ATTACHED":
        return "NONE"
    if rejection:
        return f"INTAKE_{rejection}"
    return "INTAKE_UNKNOWN"


def create_lock(lock_file: Path) -> None:
    payload = {"pid": os.getpid(), "started_at_utc": utc_now_iso()}
    flags = os.O_CREAT | os.O_EXCL | os.O_WRONLY
    handle = os.open(str(lock_file), flags)
    try:
        os.write(handle, json.dumps(payload, ensure_ascii=False).encode("utf-8"))
    finally:
        os.close(handle)


def remove_lock(lock_file: Path) -> None:
    if lock_file.exists():
        try:
            lock_file.unlink()
        except Exception:
            pass


def emit_status(
    paths: Paths,
    state: str,
    args: argparse.Namespace,
    cycle_count: int,
    last_event: dict[str, Any] | None,
    stop_reason: str,
) -> None:
    payload: dict[str, Any] = {
        "runner_name": "ATAS_MANAGED_PROPAGATION_RUNNER",
        "runner_mode": "MANAGED_RUNNER_MANUAL_START_STOP",
        "state": state,
        "pid": os.getpid(),
        "updated_at_utc": utc_now_iso(),
        "started_at_utc": getattr(args, "_runner_started_at_utc", utc_now_iso()),
        "stop_reason": stop_reason,
        "interval_sec": args.interval_sec,
        "max_cycles": args.max_cycles,
        "command_timeout_sec": args.command_timeout_sec,
        "max_events": args.max_events,
        "cycles_completed": cycle_count,
        "status_file": str(paths.runner_status_file),
        "events_file": str(paths.runner_events_file),
        "lock_file": str(paths.runner_lock_file),
        "stop_file": str(paths.runner_stop_file),
    }
    if last_event is not None:
        payload["last_cycle"] = last_event
        payload["last_first_failing_gate"] = last_event.get("first_failing_gate")
        payload["last_context_acceptance_state"] = (
            last_event.get("snapshot_after", {})
            .get("context_status", {})
            .get("acceptance_state")
        )
        payload["last_context_rejection_reason"] = (
            last_event.get("snapshot_after", {})
            .get("context_status", {})
            .get("rejection_reason")
        )
    write_json_atomic(paths.runner_status_file, payload)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Bounded managed runner for periodic ATAS exporter->adapter propagation."
    )
    parser.add_argument("--interval-sec", type=float, default=5.0)
    parser.add_argument("--max-cycles", type=int, default=0)
    parser.add_argument("--command-timeout-sec", type=int, default=90)
    parser.add_argument("--inter-stage-delay-sec", type=float, default=1.0)
    parser.add_argument("--post-cycle-delay-sec", type=float, default=1.5)
    parser.add_argument("--max-events", type=int, default=5000)
    parser.add_argument("--stop-only", action="store_true")
    return parser.parse_args()


def run() -> int:
    args = parse_args()
    paths = build_paths()

    if args.stop_only:
        payload = {"requested_at_utc": utc_now_iso(), "requested_by_pid": os.getpid()}
        write_json_atomic(paths.runner_stop_file, payload)
        print(f"[ATAS RUNNER] stop signal written: {paths.runner_stop_file}")
        return 0

    if paths.runner_lock_file.exists():
        print(f"[ATAS RUNNER] lock exists, another runner is active: {paths.runner_lock_file}")
        return 2

    if paths.runner_stop_file.exists():
        try:
            paths.runner_stop_file.unlink()
        except Exception:
            pass

    args._runner_started_at_utc = utc_now_iso()
    cycle_count = 0
    last_event: dict[str, Any] | None = None
    stop_reason = "RUNNING"

    try:
        create_lock(paths.runner_lock_file)
    except FileExistsError:
        print(f"[ATAS RUNNER] lock acquisition failed: {paths.runner_lock_file}")
        return 2

    try:
        emit_status(paths, "RUNNING", args, cycle_count, last_event, stop_reason)
        while True:
            if paths.runner_stop_file.exists():
                stop_reason = "STOP_SIGNAL_FILE"
                break
            if args.max_cycles > 0 and cycle_count >= args.max_cycles:
                stop_reason = "MAX_CYCLES_REACHED"
                break

            cycle_count += 1
            cycle_started = time.time()
            snapshot_before = snapshot(paths)

            exporter_exec = run_command(
                build_exporter_command(), paths.exporter_src_dir, args.command_timeout_sec
            )
            if args.inter_stage_delay_sec > 0:
                time.sleep(args.inter_stage_delay_sec)

            snapshot_mid = snapshot(paths)

            adapter_exec = run_command(
                build_adapter_command(), paths.adapter_src_dir, args.command_timeout_sec
            )
            if args.post_cycle_delay_sec > 0:
                time.sleep(args.post_cycle_delay_sec)

            snapshot_after = snapshot(paths)
            cycle_elapsed = time.time() - cycle_started

            event: dict[str, Any] = {
                "event_type": "RUNNER_CYCLE",
                "cycle_index": cycle_count,
                "captured_at_utc": utc_now_iso(),
                "interval_sec": args.interval_sec,
                "cycle_elapsed_sec": round(cycle_elapsed, 3),
                "exporter_exec": exporter_exec,
                "adapter_exec": adapter_exec,
                "first_failing_gate": first_failing_gate(exporter_exec, adapter_exec, snapshot_after),
                "packet_progression": {
                    "observation_packet_before": snapshot_before.get("observation", {}).get("packet_id"),
                    "observation_packet_after": snapshot_after.get("observation", {}).get("packet_id"),
                    "exporter_packet": snapshot_after.get("exporter", {}).get("packet_id"),
                    "adapter_packet": snapshot_after.get("adapter", {}).get("last_packet_id"),
                    "context_packet": snapshot_after.get("context", {}).get("packet_id"),
                    "context_status_packet": snapshot_after.get("context_status", {}).get("packet_id"),
                },
                "freshness": {
                    "context_event_time": snapshot_after.get("context", {}).get("event_time"),
                    "context_fresh_until": snapshot_after.get("context", {}).get("fresh_until"),
                    "context_event_age_seconds_utc": snapshot_after.get("context", {}).get(
                        "event_age_seconds_utc"
                    ),
                    "context_fresh_until_margin_seconds_utc": snapshot_after.get("context", {}).get(
                        "fresh_until_margin_seconds_utc"
                    ),
                    "status_freshness_state": snapshot_after.get("context_status", {}).get("freshness_state"),
                    "status_packet_age_ms": snapshot_after.get("context_status", {}).get("packet_age_ms"),
                    "status_acceptance_state": snapshot_after.get("context_status", {}).get("acceptance_state"),
                    "status_rejection_reason": snapshot_after.get("context_status", {}).get("rejection_reason"),
                },
                "advisory": {
                    "advisory_eligible": snapshot_after.get("advisory", {}).get("advisory_eligible"),
                    "gate_reason_code": snapshot_after.get("advisory", {}).get("gate_reason_code"),
                    "advisory_state": snapshot_after.get("advisory", {}).get("advisory_state"),
                    "attachment_state": snapshot_after.get("advisory", {}).get("attachment_state"),
                    "usage_state": snapshot_after.get("advisory", {}).get("usage_state"),
                },
                "snapshot_before": snapshot_before,
                "snapshot_mid": snapshot_mid,
                "snapshot_after": snapshot_after,
            }

            append_jsonl(paths.runner_events_file, event)
            if cycle_count % 20 == 0:
                trim_jsonl(paths.runner_events_file, args.max_events)

            last_event = event
            emit_status(paths, "RUNNING", args, cycle_count, last_event, stop_reason)

            remaining = args.interval_sec - cycle_elapsed
            if remaining > 0:
                time.sleep(remaining)

    finally:
        final_state = "STOPPED"
        if stop_reason == "RUNNING":
            stop_reason = "RUNNER_TERMINATED"
        emit_status(paths, final_state, args, cycle_count, last_event, stop_reason)
        remove_lock(paths.runner_lock_file)
        if paths.runner_stop_file.exists():
            try:
                paths.runner_stop_file.unlink()
            except Exception:
                pass

    print(f"[ATAS RUNNER] stopped | reason={stop_reason} | cycles={cycle_count}")
    return 0


if __name__ == "__main__":
    raise SystemExit(run())
