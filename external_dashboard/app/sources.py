from __future__ import annotations

import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Any


class ArtifactStore:
    def __init__(self, files_ai_root: Path, adapter_root: Path) -> None:
        self.files_ai_root = files_ai_root
        self.adapter_root = adapter_root
        self._json_cache: dict[str, tuple[int, Any]] = {}
        self._jsonl_cache: dict[str, tuple[int, list[dict[str, Any]]]] = {}

    def _base(self, root: str) -> Path:
        return self.adapter_root if root == "adapter" else self.files_ai_root

    def _path(self, rel_path: str, root: str) -> Path:
        return self._base(root) / rel_path

    def _mtime(self, path: Path) -> int:
        try:
            return path.stat().st_mtime_ns
        except OSError:
            return -1

    def exists(self, rel_path: str, root: str = "ai") -> bool:
        return self._path(rel_path, root).exists()

    def get_file_meta(self, rel_path: str, root: str = "ai") -> dict[str, Any]:
        path = self._path(rel_path, root)
        if not path.exists():
            return {
                "path": str(path),
                "exists": False,
                "size": 0,
                "updated_at": "UNAVAILABLE",
                "age_seconds": None,
            }

        stat = path.stat()
        updated_dt = datetime.fromtimestamp(stat.st_mtime, tz=timezone.utc)
        age = (datetime.now(timezone.utc) - updated_dt).total_seconds()
        return {
            "path": str(path),
            "exists": True,
            "size": int(stat.st_size),
            "updated_at": updated_dt.isoformat(),
            "age_seconds": int(age) if age >= 0 else 0,
        }

    def load_json(self, rel_path: str, root: str = "ai") -> dict[str, Any]:
        path = self._path(rel_path, root)
        key = str(path).lower()
        if not path.exists():
            return {
                "_status": "UNAVAILABLE",
                "_reason": "FILE_MISSING",
                "_path": str(path),
            }

        mtime = self._mtime(path)
        cached = self._json_cache.get(key)
        if cached and cached[0] == mtime:
            value = cached[1]
            if isinstance(value, dict):
                return value
            return {"_status": "UNAVAILABLE", "_reason": "JSON_NOT_OBJECT", "_path": str(path)}

        try:
            text = path.read_text(encoding="utf-8", errors="replace")
            data = json.loads(text)
            self._json_cache[key] = (mtime, data)
            if isinstance(data, dict):
                return data
            return {
                "_status": "UNAVAILABLE",
                "_reason": "JSON_NOT_OBJECT",
                "_path": str(path),
            }
        except Exception as exc:  # noqa: BLE001
            return {
                "_status": "UNAVAILABLE",
                "_reason": f"JSON_READ_ERROR:{exc.__class__.__name__}",
                "_path": str(path),
            }

    def load_jsonl(self, rel_path: str, root: str = "ai", limit: int = 0) -> list[dict[str, Any]]:
        path = self._path(rel_path, root)
        key = str(path).lower()
        if not path.exists():
            return []

        mtime = self._mtime(path)
        cached = self._jsonl_cache.get(key)
        rows: list[dict[str, Any]]
        if cached and cached[0] == mtime:
            rows = cached[1]
        else:
            parsed: list[dict[str, Any]] = []
            try:
                with path.open("r", encoding="utf-8", errors="replace") as handle:
                    for line in handle:
                        raw = line.strip()
                        if not raw:
                            continue
                        try:
                            obj = json.loads(raw)
                        except Exception:  # noqa: BLE001
                            continue
                        if isinstance(obj, dict):
                            parsed.append(obj)
                rows = parsed
            except Exception:  # noqa: BLE001
                rows = []
            self._jsonl_cache[key] = (mtime, rows)

        if limit > 0 and len(rows) > limit:
            return rows[-limit:]
        return rows

    @staticmethod
    def safe(obj: dict[str, Any] | None, key: str, default: Any = "UNAVAILABLE") -> Any:
        if not isinstance(obj, dict):
            return default
        value = obj.get(key, default)
        if value is None or value == "":
            return default
        return value

    @staticmethod
    def latest(rows: list[dict[str, Any]], keys: list[str]) -> list[dict[str, Any]]:
        def row_key(item: dict[str, Any]) -> str:
            for name in keys:
                value = item.get(name)
                if isinstance(value, str) and value:
                    return value
            return ""

        return sorted(rows, key=row_key, reverse=True)

    @staticmethod
    def fmt_number(value: Any, digits: int = 5) -> str:
        if isinstance(value, bool):
            return "true" if value else "false"
        if isinstance(value, int):
            return str(value)
        if isinstance(value, float):
            return f"{value:.{digits}f}"
        if value is None:
            return "UNAVAILABLE"
        return str(value)

    @staticmethod
    def parse_timestamp(value: Any) -> datetime | None:
        if not isinstance(value, str) or not value.strip():
            return None
        raw = value.strip()
        if raw.endswith("Z"):
            raw = raw[:-1] + "+00:00"
        try:
            dt = datetime.fromisoformat(raw)
        except ValueError:
            return None
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt.astimezone(timezone.utc)

    @staticmethod
    def timestamp_age_seconds(value: Any) -> int | None:
        dt = ArtifactStore.parse_timestamp(value)
        if dt is None:
            return None
        age = (datetime.now(timezone.utc) - dt).total_seconds()
        return int(age) if age >= 0 else 0
