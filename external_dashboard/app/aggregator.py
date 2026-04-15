from __future__ import annotations

from dataclasses import dataclass
from typing import Any

from .sources import ArtifactStore


DIRECT = "DIRECT"
DERIVED = "DERIVED"
UNAVAILABLE = "UNAVAILABLE"
STALE = "STALE"
NOT_PRODUCED = "NOT_PRODUCED"

ATAS_CONTEXT_PRIMARY = "atas_microstructure_context.json"
ATAS_CONTEXT_LEGACY = "atas_runtime_context.json"
ATAS_STATUS_PRIMARY = "atas_microstructure_status.json"
ATAS_STATUS_LEGACY = "atas_runtime_context_status.json"


@dataclass
class SurfaceTarget:
    group: str
    name: str
    rel_path: str
    root: str = "ai"
    kind: str = "json"
    stale_after_seconds: int = 6 * 3600
    optional: bool = False


class DashboardAggregator:
    def __init__(self, store: ArtifactStore) -> None:
        self.store = store

    @staticmethod
    def _surface_available(surface: dict[str, Any]) -> bool:
        return isinstance(surface, dict) and surface.get("_status") != UNAVAILABLE

    def _load_atas_context_surface(self) -> tuple[dict[str, Any], str]:
        return self._load_atas_surface_with_fallback(ATAS_CONTEXT_PRIMARY, ATAS_CONTEXT_LEGACY)

    def _load_atas_status_surface(self) -> tuple[dict[str, Any], str]:
        return self._load_atas_surface_with_fallback(ATAS_STATUS_PRIMARY, ATAS_STATUS_LEGACY)

    def _load_atas_surface_with_fallback(
        self,
        primary_rel_path: str,
        legacy_rel_path: str,
    ) -> tuple[dict[str, Any], str]:
        primary = self.store.load_json(primary_rel_path)
        if self._surface_available(primary):
            return primary, primary_rel_path

        legacy = self.store.load_json(legacy_rel_path)
        if self._surface_available(legacy):
            return legacy, legacy_rel_path

        return primary, primary_rel_path

    def overview(self) -> dict[str, Any]:
        gov = self.store.load_json("runtime_governance_status.json")
        auth = self.store.load_json("execution_authority_status.json")
        ai = self.store.load_json("ai_activation_readiness_status.json")
        adv = self.store.load_json("atas_governed_advisory_status.json")
        integrity = self.store.load_json("operational_integrity_status.json")
        event = self.store.load_json("last_meaningful_runtime_event.json")
        ctx_status, ctx_status_surface = self._load_atas_status_surface()
        ctx, _ = self._load_atas_context_surface()
        atas_truth = self._atas_reference_truth(ctx_status, adv, ctx, ctx_status_surface)

        cards = [
            {
                "title": "Runtime Governance",
                "value": ArtifactStore.safe(gov, "governance_state"),
                "badge": "OK" if ArtifactStore.safe(gov, "trading_allowed", False) else "BLOCKED",
                "sub": ArtifactStore.safe(gov, "reason_code"),
            },
            {
                "title": "Execution Authority",
                "value": ArtifactStore.safe(auth, "execution_authority_source"),
                "badge": "COHORT"
                if ArtifactStore.safe(auth, "execution_allowed_only_through_active_operating_cohort", False)
                else "UNKNOWN",
                "sub": ArtifactStore.safe(auth, "execution_authority_cutover_state"),
            },
            {
                "title": "AI Posture",
                "value": ArtifactStore.safe(ai, "authority_state"),
                "badge": ArtifactStore.safe(ai, "readiness_state"),
                "sub": ArtifactStore.safe(ai, "readiness_reason_code"),
            },
            {
                "title": "ATAS Advisory",
                "value": ArtifactStore.safe(adv, "advisory_state"),
                "badge": ArtifactStore.safe(adv, "advisory_attachment_state"),
                "sub": ArtifactStore.safe(adv, "gate_reason_code"),
            },
            {
                "title": "ATAS Reference Truth",
                "value": atas_truth["state"],
                "badge": "LIVE_VALID" if atas_truth["live_valid"] else "NON_LIVE",
                "sub": atas_truth["reason"],
            },
            {
                "title": "Shadow Context",
                "value": ArtifactStore.safe(ctx_status, "acceptance_state"),
                "badge": ArtifactStore.safe(ctx_status, "freshness_state"),
                "sub": ArtifactStore.safe(ctx_status, "rejection_reason"),
            },
            {
                "title": "Operational Integrity",
                "value": ArtifactStore.safe(integrity, "overall_state"),
                "badge": ArtifactStore.safe(integrity, "freshness_gate_state"),
                "sub": ArtifactStore.safe(integrity, "overall_reason"),
            },
        ]

        return {
            "cards": cards,
            "event": {
                "type": ArtifactStore.safe(event, "event_type"),
                "time": ArtifactStore.safe(event, "event_time"),
                "decision_id": ArtifactStore.safe(event, "decision_id"),
                "note": ArtifactStore.safe(event, "short_note"),
                "reason": ArtifactStore.safe(event, "reason_code"),
            },
            "atas_reference_truth": atas_truth,
        }

    def context(self) -> dict[str, Any]:
        ctx, ctx_surface = self._load_atas_context_surface()
        ctx_status, ctx_status_surface = self._load_atas_status_surface()
        adv = self.store.load_json("atas_governed_advisory_status.json")
        diag = self.store.load_json("diagnostic_runtime_summary.json")
        envelope_rows = self.store.load_jsonl("ai_decision_envelope_trace.jsonl", limit=80)
        envelope_rows = self._sort_latest(envelope_rows, ["ts", "captured_at"])
        latest_env = envelope_rows[0] if envelope_rows else {}
        feedback = self.store.load_json("ai_trade_feedback.json")
        final_levels = self._collect_final_runtime_levels(envelope_rows, feedback)
        atas_truth = self._atas_reference_truth(ctx_status, adv, ctx, ctx_status_surface)

        return {
            "runtime": {
                "decision_id": ArtifactStore.safe(diag, "decision_id"),
                "final_decision": ArtifactStore.safe(diag, "final_decision"),
                "final_blocking_layer": ArtifactStore.safe(diag, "final_blocking_layer"),
                "final_block_reason_code": ArtifactStore.safe(diag, "final_block_reason_code"),
                "zone_name": ArtifactStore.safe(diag, "zone_name"),
                "regime_summary": ArtifactStore.safe(diag, "regime_summary"),
                "best_strategy_id": ArtifactStore.safe(diag, "best_strategy_id"),
                "evaluated_at": ArtifactStore.safe(diag, "evaluated_at"),
            },
            "decision_envelope": {
                "base_confidence": ArtifactStore.safe(latest_env, "base_confidence_score"),
                "final_confidence": ArtifactStore.safe(latest_env, "final_confidence_score"),
                "policy_risk": ArtifactStore.safe(latest_env, "policy_risk_score"),
                "regime_fit": ArtifactStore.safe(latest_env, "regime_fit_score"),
                "decision_acceptance_posture": ArtifactStore.safe(latest_env, "decision_acceptance_posture"),
                "advisory_state": ArtifactStore.safe(latest_env, "advisory_state"),
                "advisory_usage_state": ArtifactStore.safe(latest_env, "advisory_usage_state"),
                "sr_interaction_bucket": ArtifactStore.safe(latest_env, "sr_interaction_bucket"),
                "level_interaction_type": ArtifactStore.safe(latest_env, "level_interaction_type"),
                "support_resistance_observation_source": ArtifactStore.safe(
                    latest_env, "support_resistance_observation_source"
                ),
            },
            "shadow_context": {
                # Identity and quality fields: read from status file (flat) — status file mirrors these
                # from the primary DIRECT_WRITE_CORE_V1 schema where they are nested under envelope/quality.
                "packet_id": ArtifactStore.safe(ctx_status, "packet_id"),
                "source_symbol_original": ArtifactStore.safe(ctx_status, "source_symbol_original"),
                "execution_symbol": ArtifactStore.safe(ctx_status, "execution_symbol"),
                "source_reference_price": ArtifactStore.safe(ctx_status, "source_reference_price"),
                "execution_reference_price": ArtifactStore.safe(ctx_status, "execution_reference_price"),
                "cross_instrument_translation_applied": ArtifactStore.safe(
                    ctx_status, "cross_instrument_translation_applied"
                ),
                "cross_instrument_basis_value": ArtifactStore.safe(ctx_status, "cross_instrument_basis_value"),
                "price_anchor_fields_suppressed": ArtifactStore.safe(ctx_status, "price_anchor_fields_suppressed"),
                "quality_state": ArtifactStore.safe(ctx_status, "quality_state"),
                # Time fields: read from ctx envelope (DIRECT_WRITE_CORE_V1) with fallback to flat (legacy schema)
                "fresh_until": (
                    ArtifactStore.safe(ctx.get("envelope") or {}, "fresh_until")
                    if isinstance(ctx, dict) and isinstance(ctx.get("envelope"), dict)
                    else ArtifactStore.safe(ctx, "fresh_until")
                ),
                "event_time": (
                    ArtifactStore.safe(ctx.get("envelope") or {}, "written_at")
                    if isinstance(ctx, dict) and isinstance(ctx.get("envelope"), dict)
                    else ArtifactStore.safe(ctx, "event_time")
                ),
                "level_candidate_count": len(ctx.get("level_candidates", [])) if isinstance(ctx.get("level_candidates"), list) else 0,
                "source_surface": ctx_surface,
            },
            "shadow_status": {
                "acceptance_state": ArtifactStore.safe(ctx_status, "acceptance_state"),
                "freshness_state": ArtifactStore.safe(ctx_status, "freshness_state"),
                "rejection_reason": ArtifactStore.safe(ctx_status, "rejection_reason"),
                "consumption_mode": ArtifactStore.safe(ctx_status, "consumption_mode"),
                "status_timestamp": ArtifactStore.safe(ctx_status, "status_timestamp_utc"),
                "source_surface": ctx_status_surface,
            },
            "advisory": {
                "advisory_eligible": ArtifactStore.safe(adv, "advisory_eligible"),
                "advisory_state": ArtifactStore.safe(adv, "advisory_state"),
                "advisory_attachment_state": ArtifactStore.safe(adv, "advisory_attachment_state"),
                "gate_reason_code": ArtifactStore.safe(adv, "gate_reason_code"),
                "advisory_usage_state": ArtifactStore.safe(adv, "advisory_usage_state"),
                "advisory_zero_effect_reason": ArtifactStore.safe(adv, "advisory_zero_effect_reason"),
                "nearest_support_price": ArtifactStore.safe(adv, "nearest_support_price"),
                "nearest_resistance_price": ArtifactStore.safe(adv, "nearest_resistance_price"),
            },
            "atas_reference_truth": atas_truth,
            "final_runtime_levels": {
                "state": final_levels["state"],
                "reason": final_levels["reason"],
                "nearest_support_price": final_levels["supports"][0]["price"] if final_levels["supports"] else UNAVAILABLE,
                "nearest_resistance_price": final_levels["resistances"][0]["price"] if final_levels["resistances"] else UNAVAILABLE,
                "source_support": final_levels["supports"][0]["source"] if final_levels["supports"] else UNAVAILABLE,
                "source_resistance": final_levels["resistances"][0]["source"] if final_levels["resistances"] else UNAVAILABLE,
                "note": "Final runtime levels use decision-envelope/runtime precedence; shadow packet levels are diagnostic only when ATAS is non-live.",
            },
        }

    def trades(self, limit: int = 10) -> dict[str, Any]:
        limit = max(1, min(limit, 200))
        lineage_rows = self._sort_latest(
            self.store.load_jsonl("ai_institutional_learning_trade_lineage.jsonl", limit=4000),
            ["captured_at", "exit_time", "entry_time"],
        )
        event_rows = self._sort_latest(
            self.store.load_jsonl("ai_institutional_learning_events.jsonl", limit=8000),
            ["captured_at", "exit_time", "entry_time"],
        )
        env_rows = self._sort_latest(
            self.store.load_jsonl("ai_decision_envelope_trace.jsonl", limit=12000),
            ["ts"],
        )
        decision_context_rows = self._sort_latest(
            self.store.load_jsonl("ai_institutional_learning_decision_context.jsonl", limit=8000),
            ["captured_at"],
        )
        strategy_memory_rows = self._sort_latest(
            self.store.load_jsonl("ai_strategy_memory_events.jsonl", limit=12000),
            ["ts"],
        )
        feedback = self.store.load_json("ai_trade_feedback.json")

        env_by_decision = self._index_latest(env_rows, "decision_id", ["ts"])
        env_by_decision_base = self._index_latest_by_decision_base(env_rows, "decision_id", ["ts"])
        env_by_decision_stamp = self._index_latest_by_decision_stamp(env_rows, "decision_id", ["ts"])
        event_by_lineage = self._index_latest(event_rows, "trade_lineage_key", ["captured_at"])
        event_by_decision = self._index_latest(event_rows, "decision_id", ["captured_at"])
        event_by_decision_base = self._index_latest_by_decision_base(event_rows, "decision_id", ["captured_at"])
        event_by_decision_stamp = self._index_latest_by_decision_stamp(
            event_rows, "decision_id", ["captured_at"]
        )
        context_by_decision = self._index_latest(decision_context_rows, "decision_id", ["captured_at"])
        context_by_decision_base = self._index_latest_by_decision_base(
            decision_context_rows, "decision_id", ["captured_at"]
        )
        context_by_decision_stamp = self._index_latest_by_decision_stamp(
            decision_context_rows, "decision_id", ["captured_at"]
        )
        memory_by_decision = self._index_latest(strategy_memory_rows, "decision_id", ["ts"])
        memory_by_decision_base = self._index_latest_by_decision_base(
            strategy_memory_rows, "decision_id", ["ts"]
        )
        memory_by_decision_stamp = self._index_latest_by_decision_stamp(
            strategy_memory_rows, "decision_id", ["ts"]
        )
        trade_open_rows = [
            r for r in strategy_memory_rows if str(r.get("event", "")).upper() == "TRADE_OPEN"
        ]
        trade_open_by_decision_base = self._index_latest_by_decision_base(
            trade_open_rows, "decision_id", ["ts"]
        )
        trade_open_by_decision_stamp = self._index_latest_by_decision_stamp(
            trade_open_rows, "decision_id", ["ts"]
        )

        base_rows = lineage_rows if lineage_rows else event_rows
        rows: list[dict[str, Any]] = []
        for item in base_rows[:limit]:
            decision_id = self._value(item, "decision_id")
            lineage_key = self._value(item, "trade_lineage_key")
            env, env_link_state = self._resolve_by_decision(
                decision_id, env_by_decision, env_by_decision_base, env_by_decision_stamp
            )
            ev = event_by_lineage.get(lineage_key, {})
            if not ev:
                ev, _ = self._resolve_by_decision(
                    decision_id, event_by_decision, event_by_decision_base, event_by_decision_stamp
                )
            dctx, dctx_link_state = self._resolve_by_decision(
                decision_id, context_by_decision, context_by_decision_base, context_by_decision_stamp
            )
            mem, mem_link_state = self._resolve_by_decision(
                decision_id, memory_by_decision, memory_by_decision_base, memory_by_decision_stamp
            )
            open_ev, open_link_state = self._resolve_by_decision(
                decision_id, {}, trade_open_by_decision_base, trade_open_by_decision_stamp
            )
            fdb = self._feedback_if_matching(
                feedback, decision_id, self._value(item, "position_id"), self._value(item, "close_deal_id")
            )

            strategy_id = self._pick_value(
                [
                    (dctx.get("strategy_id"), DIRECT),
                    (open_ev.get("strategy_id"), DIRECT),
                    (open_ev.get("strategy_name"), DIRECT),
                    (mem.get("strategy_id"), DIRECT),
                    (env.get("best_strategy_id"), DIRECT),
                    (item.get("runtime_strategy_id_exact"), DIRECT),
                    (ev.get("runtime_strategy_id_exact"), DIRECT),
                    (ev.get("strategy_id"), DIRECT),
                    (fdb.get("linked_runtime_strategy_id"), DIRECT),
                    (item.get("feedback_strategy_id"), DIRECT),
                    (item.get("aggregated_strategy_bucket"), DERIVED),
                    (ev.get("aggregated_strategy_bucket"), DERIVED),
                ],
                not_produced_when=(not lineage_rows and not event_rows and not strategy_memory_rows),
            )

            strategy_family = self._pick_value(
                [
                    (dctx.get("strategy_family"), DIRECT),
                    (open_ev.get("strategy_family"), DIRECT),
                    (mem.get("strategy_family"), DIRECT),
                    (item.get("runtime_strategy_family_exact"), DIRECT),
                    (ev.get("runtime_strategy_family_exact"), DIRECT),
                    (ev.get("strategy_family"), DIRECT),
                    (fdb.get("linked_runtime_strategy_family"), DIRECT),
                    (item.get("aggregated_strategy_bucket"), DERIVED),
                    (ev.get("aggregated_strategy_bucket"), DERIVED),
                ],
                not_produced_when=(not lineage_rows and not event_rows),
            )

            sr_bucket = self._pick_value(
                [
                    (dctx.get("sr_interaction_bucket"), DIRECT),
                    (env.get("sr_interaction_bucket"), DIRECT),
                    (item.get("sr_interaction_bucket"), DIRECT),
                    (ev.get("sr_interaction_bucket"), DIRECT),
                    (fdb.get("linked_support_resistance_bucket"), DIRECT),
                ],
                not_produced_when=(not env_rows and not lineage_rows),
            )
            canonical = self._pick_value(
                [
                    (dctx.get("canonical_level_state"), DIRECT),
                    (env.get("canonical_level_state"), DIRECT),
                    (item.get("canonical_level_state"), DIRECT),
                    (ev.get("canonical_level_state"), DIRECT),
                    (fdb.get("linked_canonical_level_state"), DIRECT),
                ],
                not_produced_when=(not env_rows and not lineage_rows),
            )
            lvl_type = self._pick_value(
                [
                    (env.get("level_interaction_type"), DIRECT),
                    (dctx.get("sr_interaction_bucket"), DERIVED),
                    (fdb.get("linked_level_interaction_type"), DIRECT),
                ],
                not_produced_when=(not env_rows),
            )
            nearest_support = self._pick_value(
                [
                    (self._positive_number_or_none(env.get("nearest_support_price")), DIRECT),
                    (self._positive_number_or_none(fdb.get("linked_nearest_support_price")), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )
            nearest_resistance = self._pick_value(
                [
                    (self._positive_number_or_none(env.get("nearest_resistance_price")), DIRECT),
                    (self._positive_number_or_none(fdb.get("linked_nearest_resistance_price")), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )

            advisory_eligibility = self._pick_value(
                [
                    (env.get("advisory_eligible"), DIRECT),
                    (fdb.get("linked_advisory_eligible"), DIRECT),
                    (ev.get("advisory_eligible"), DERIVED),
                ],
                not_produced_when=(not env_rows),
            )
            advisory_usage = self._pick_value(
                [
                    (env.get("advisory_usage_state"), DIRECT),
                    (fdb.get("linked_advisory_usage_state"), DIRECT),
                    (ev.get("advisory_usage_state"), DERIVED),
                ],
                not_produced_when=(not env_rows),
            )
            posture = self._pick_value(
                [
                    (env.get("decision_acceptance_posture"), DIRECT),
                    (fdb.get("decision_acceptance_posture_at_entry"), DIRECT),
                    (ev.get("decision_acceptance_posture"), DERIVED),
                ],
                not_produced_when=(not env_rows),
            )
            base_confidence = self._pick_value(
                [
                    (env.get("base_confidence_score"), DIRECT),
                    (fdb.get("base_confidence_score_at_entry"), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )
            final_confidence = self._pick_value(
                [
                    (env.get("final_confidence_score"), DIRECT),
                    (fdb.get("final_confidence_score_at_entry"), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )
            policy_risk = self._pick_value(
                [
                    (env.get("policy_risk_score"), DIRECT),
                    (fdb.get("policy_risk_score_at_entry"), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )
            regime_fit = self._pick_value(
                [
                    (env.get("regime_fit_score"), DIRECT),
                    (fdb.get("regime_fit_score_at_entry"), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )
            learning_delta = self._pick_value(
                [
                    (env.get("learning_confidence_delta"), DIRECT),
                    (fdb.get("learning_confidence_delta_at_entry"), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )
            learning_caution = self._pick_value(
                [
                    (env.get("learning_caution_score"), DIRECT),
                    (fdb.get("learning_caution_delta_at_entry"), DIRECT),
                ],
                not_produced_when=(not env_rows and not fdb),
            )

            row_ts = self._pick_value(
                [
                    (item.get("captured_at"), DIRECT),
                    (item.get("exit_time"), DIRECT),
                    (ev.get("captured_at"), DIRECT),
                    (open_ev.get("ts"), DIRECT),
                    (dctx.get("captured_at"), DIRECT),
                    (env.get("ts"), DIRECT),
                    (mem.get("ts"), DIRECT),
                ],
                not_produced_when=False,
            )
            row_age = ArtifactStore.timestamp_age_seconds(row_ts["value"])
            freshness = STALE if isinstance(row_age, int) and row_age > 24 * 3600 else "FRESH"

            rows.append(
                {
                    "trade_lineage_key": self._value(item, "trade_lineage_key", self._value(ev, "trade_lineage_key")),
                    "decision_id": decision_id,
                    "position_id": self._pick_raw(item, ev, fdb, keys=["position_id"]) or UNAVAILABLE,
                    "close_deal_id": self._pick_raw(item, ev, fdb, keys=["close_deal_id"]) or UNAVAILABLE,
                    "entry_deal_id": self._pick_raw(item, ev, fdb, keys=["entry_deal_id"]) or UNAVAILABLE,
                    "symbol": self._pick_raw(item, ev, fdb, mem, keys=["symbol"]) or UNAVAILABLE,
                    "direction": self._pick_raw(
                        item,
                        ev,
                        open_ev,
                        dctx,
                        env,
                        fdb,
                        mem,
                        keys=["direction"],
                    )
                    or UNAVAILABLE,
                    "entry_time": self._pick_raw(item, ev, fdb, keys=["entry_time"]) or UNAVAILABLE,
                    "exit_time": self._pick_raw(item, ev, fdb, keys=["exit_time", "close_time"]) or UNAVAILABLE,
                    "strategy_id": strategy_id["value"],
                    "strategy_id_state": strategy_id["state"],
                    "strategy_family": strategy_family["value"],
                    "strategy_family_state": strategy_family["state"],
                    "regime_label": self._pick_raw(
                        item, ev, dctx, env, fdb, mem, keys=["regime_label", "regime_bucket"]
                    )
                    or UNAVAILABLE,
                    "decision_link_state": (
                        DIRECT
                        if env_link_state == DIRECT or dctx_link_state == DIRECT
                        else DERIVED
                        if env_link_state == DERIVED or dctx_link_state == DERIVED or mem_link_state == DERIVED or open_link_state == DERIVED
                        else UNAVAILABLE
                    ),
                    "volatility_regime": self._pick_raw(
                        item, ev, dctx, env, fdb, keys=["volatility_regime", "volatility_state", "volatility_bucket"]
                    )
                    or UNAVAILABLE,
                    "structure_bucket": self._pick_raw(
                        item, ev, dctx, env, fdb, keys=["structure_bucket", "structure_state"]
                    )
                    or UNAVAILABLE,
                    "sr_interaction_bucket": sr_bucket["value"],
                    "sr_interaction_bucket_state": sr_bucket["state"],
                    "canonical_level_state": canonical["value"],
                    "canonical_level_state_state": canonical["state"],
                    "level_interaction_type": lvl_type["value"],
                    "level_interaction_type_state": lvl_type["state"],
                    "nearest_support_price": nearest_support["value"],
                    "nearest_support_price_state": nearest_support["state"],
                    "nearest_resistance_price": nearest_resistance["value"],
                    "nearest_resistance_price_state": nearest_resistance["state"],
                    "runtime_primary_attribution": self._pick_raw(
                        item,
                        ev,
                        fdb,
                        keys=["runtime_primary_attribution", "primary_attribution", "learning_primary_attribution"],
                    )
                    or UNAVAILABLE,
                    "runtime_secondary_attribution": self._pick_raw(
                        item,
                        ev,
                        fdb,
                        keys=["runtime_secondary_attribution", "secondary_attribution", "learning_secondary_attribution"],
                    )
                    or UNAVAILABLE,
                    "trade_result": self._pick_raw(ev, item, fdb, keys=["trade_result", "result"]) or UNAVAILABLE,
                    "profit": self._pick_raw(ev, fdb, keys=["profit"]) or UNAVAILABLE,
                    "base_confidence": base_confidence["value"],
                    "base_confidence_state": base_confidence["state"],
                    "final_confidence": final_confidence["value"],
                    "final_confidence_state": final_confidence["state"],
                    "policy_risk_score": policy_risk["value"],
                    "policy_risk_score_state": policy_risk["state"],
                    "regime_fit_score": regime_fit["value"],
                    "regime_fit_score_state": regime_fit["state"],
                    "learning_confidence_delta": learning_delta["value"],
                    "learning_confidence_delta_state": learning_delta["state"],
                    "learning_caution_score": learning_caution["value"],
                    "learning_caution_score_state": learning_caution["state"],
                    "advisory_eligible": advisory_eligibility["value"],
                    "advisory_eligible_state": advisory_eligibility["state"],
                    "advisory_usage_state": advisory_usage["value"],
                    "advisory_usage_state_data_state": advisory_usage["state"],
                    "advisory_zero_effect_reason": self._pick_raw(
                        env, fdb, ev, keys=["advisory_zero_effect_reason", "linked_advisory_zero_effect_reason"]
                    )
                    or UNAVAILABLE,
                    "decision_acceptance_posture": posture["value"],
                    "decision_acceptance_posture_state": posture["state"],
                    "decision_reasoning_flags": self._pick_raw(
                        env, fdb, keys=["decision_reasoning_flags_csv", "decision_reasoning_flags_at_entry"]
                    )
                    or UNAVAILABLE,
                    "source_timestamp": row_ts["value"],
                    "source_timestamp_state": row_ts["state"],
                    "freshness_state": freshness,
                    "support_resistance_observation_source": self._pick_raw(
                        env, fdb, item, keys=["support_resistance_observation_source", "linked_support_resistance_observation_source"]
                    )
                    or UNAVAILABLE,
                }
            )

        if not rows:
            rows.append(
                {
                    "trade_lineage_key": NOT_PRODUCED,
                    "decision_id": NOT_PRODUCED,
                    "position_id": NOT_PRODUCED,
                    "close_deal_id": NOT_PRODUCED,
                    "entry_deal_id": NOT_PRODUCED,
                    "symbol": NOT_PRODUCED,
                    "direction": NOT_PRODUCED,
                    "entry_time": NOT_PRODUCED,
                    "exit_time": NOT_PRODUCED,
                    "strategy_id": NOT_PRODUCED,
                    "strategy_id_state": NOT_PRODUCED,
                    "strategy_family": NOT_PRODUCED,
                    "strategy_family_state": NOT_PRODUCED,
                    "regime_label": NOT_PRODUCED,
                    "decision_link_state": NOT_PRODUCED,
                    "volatility_regime": NOT_PRODUCED,
                    "structure_bucket": NOT_PRODUCED,
                    "sr_interaction_bucket": NOT_PRODUCED,
                    "sr_interaction_bucket_state": NOT_PRODUCED,
                    "canonical_level_state": NOT_PRODUCED,
                    "canonical_level_state_state": NOT_PRODUCED,
                    "level_interaction_type": NOT_PRODUCED,
                    "level_interaction_type_state": NOT_PRODUCED,
                    "nearest_support_price": NOT_PRODUCED,
                    "nearest_support_price_state": NOT_PRODUCED,
                    "nearest_resistance_price": NOT_PRODUCED,
                    "nearest_resistance_price_state": NOT_PRODUCED,
                    "runtime_primary_attribution": NOT_PRODUCED,
                    "runtime_secondary_attribution": NOT_PRODUCED,
                    "trade_result": NOT_PRODUCED,
                    "profit": NOT_PRODUCED,
                    "base_confidence": NOT_PRODUCED,
                    "base_confidence_state": NOT_PRODUCED,
                    "final_confidence": NOT_PRODUCED,
                    "final_confidence_state": NOT_PRODUCED,
                    "policy_risk_score": NOT_PRODUCED,
                    "policy_risk_score_state": NOT_PRODUCED,
                    "regime_fit_score": NOT_PRODUCED,
                    "regime_fit_score_state": NOT_PRODUCED,
                    "learning_confidence_delta": NOT_PRODUCED,
                    "learning_confidence_delta_state": NOT_PRODUCED,
                    "learning_caution_score": NOT_PRODUCED,
                    "learning_caution_score_state": NOT_PRODUCED,
                    "advisory_eligible": NOT_PRODUCED,
                    "advisory_eligible_state": NOT_PRODUCED,
                    "advisory_usage_state": NOT_PRODUCED,
                    "advisory_usage_state_data_state": NOT_PRODUCED,
                    "advisory_zero_effect_reason": NOT_PRODUCED,
                    "decision_acceptance_posture": NOT_PRODUCED,
                    "decision_acceptance_posture_state": NOT_PRODUCED,
                    "decision_reasoning_flags": NOT_PRODUCED,
                    "source_timestamp": NOT_PRODUCED,
                    "source_timestamp_state": NOT_PRODUCED,
                    "freshness_state": NOT_PRODUCED,
                    "support_resistance_observation_source": NOT_PRODUCED,
                }
            )

        return {
            "rows": rows,
            "limit": limit,
            "state_legend": [DIRECT, DERIVED, UNAVAILABLE, STALE, NOT_PRODUCED],
        }

    def rejections(self, limit: int = 20) -> dict[str, Any]:
        limit = max(1, min(limit, 300))
        memory_events = self.store.load_jsonl("ai_strategy_memory_events.jsonl", limit=5000)
        env_rows = self.store.load_jsonl("ai_decision_envelope_trace.jsonl", limit=3000)
        dctx_rows = self.store.load_jsonl("ai_institutional_learning_decision_context.jsonl", limit=3000)
        env_by_decision = self._index_latest(env_rows, "decision_id", ["ts"])
        env_by_decision_base = self._index_latest_by_decision_base(env_rows, "decision_id", ["ts"])
        env_by_decision_stamp = self._index_latest_by_decision_stamp(env_rows, "decision_id", ["ts"])
        dctx_by_decision = self._index_latest(dctx_rows, "decision_id", ["captured_at"])
        dctx_by_decision_base = self._index_latest_by_decision_base(dctx_rows, "decision_id", ["captured_at"])
        dctx_by_decision_stamp = self._index_latest_by_decision_stamp(
            dctx_rows, "decision_id", ["captured_at"]
        )
        out: list[dict[str, Any]] = []

        for row in reversed(memory_events):
            outcome = str(row.get("decision_outcome", "")).upper()
            if outcome not in {"REJECT", "WAIT", "NON_ENTRY", "BLOCKED"}:
                continue
            decision_id = str(row.get("decision_id", ""))
            env, env_link_state = self._resolve_by_decision(
                decision_id, env_by_decision, env_by_decision_base, env_by_decision_stamp
            )
            dctx, dctx_link_state = self._resolve_by_decision(
                decision_id, dctx_by_decision, dctx_by_decision_base, dctx_by_decision_stamp
            )
            direction_raw = str(row.get("direction", "")).upper()
            direction_state = DIRECT
            if direction_raw in {"", "UNKNOWN"}:
                derived_dir = self._pick_raw(env, dctx, keys=["direction"])
                direction_raw = str(derived_dir) if self._is_present(derived_dir) else "UNKNOWN"
                direction_state = DERIVED if direction_raw != "UNKNOWN" else UNAVAILABLE
            link_state = (
                DIRECT
                if env_link_state == DIRECT or dctx_link_state == DIRECT
                else DERIVED
                if env_link_state == DERIVED or dctx_link_state == DERIVED
                else UNAVAILABLE
            )
            out.append(
                {
                    "ts": row.get("ts", UNAVAILABLE),
                    "decision_id": decision_id or UNAVAILABLE,
                    "symbol": row.get("symbol", UNAVAILABLE),
                    "strategy_id": self._pick_raw(row, dctx, env, keys=["strategy_id", "strategy_name", "best_strategy_id"]) or UNAVAILABLE,
                    "direction": direction_raw,
                    "direction_state": direction_state,
                    "outcome": outcome,
                    "regime_label": self._pick_raw(row, dctx, env, keys=["regime_label"]) or UNAVAILABLE,
                    "zone_semantic": row.get("zone_semantic", UNAVAILABLE),
                    "reason": row.get("level_brake_reason", UNAVAILABLE),
                    "decision_acceptance_posture": self._pick_raw(env, keys=["decision_acceptance_posture"]) or UNAVAILABLE,
                    "advisory_usage_state": self._pick_raw(env, keys=["advisory_usage_state"]) or UNAVAILABLE,
                    "sr_interaction_bucket": self._pick_raw(env, dctx, keys=["sr_interaction_bucket"]) or UNAVAILABLE,
                    "context_link_state": link_state,
                }
            )

        for row in reversed(env_rows):
            final_decision = str(row.get("final_decision", "")).upper()
            policy_result = str(row.get("policy_result", "")).upper()
            posture = str(row.get("decision_acceptance_posture", "")).upper()
            if final_decision != "REJECT" and "BLOCKED" not in policy_result and posture not in {"BLOCKED", "NON_ENTRY"}:
                continue
            out.append(
                {
                    "ts": row.get("ts", UNAVAILABLE),
                    "decision_id": row.get("decision_id", UNAVAILABLE),
                    "symbol": row.get("symbol", UNAVAILABLE),
                    "strategy_id": row.get("best_strategy_id", UNAVAILABLE),
                    "direction": row.get("direction", UNAVAILABLE),
                    "direction_state": DIRECT if self._is_present(row.get("direction")) else UNAVAILABLE,
                    "outcome": final_decision if final_decision else posture,
                    "regime_label": row.get("regime_label", UNAVAILABLE),
                    "zone_semantic": row.get("final_blocking_layer", UNAVAILABLE),
                    "reason": row.get("final_block_reason_code", row.get("policy_result", UNAVAILABLE)),
                    "decision_acceptance_posture": row.get("decision_acceptance_posture", UNAVAILABLE),
                    "advisory_usage_state": row.get("advisory_usage_state", UNAVAILABLE),
                    "sr_interaction_bucket": row.get("sr_interaction_bucket", UNAVAILABLE),
                    "context_link_state": DIRECT if self._is_present(row.get("decision_id")) else UNAVAILABLE,
                }
            )

        out = sorted(out, key=lambda x: str(x.get("ts", "")), reverse=True)
        deduped: list[dict[str, Any]] = []
        seen: set[str] = set()
        for row in out:
            key = f"{row.get('decision_id')}|{row.get('ts')}|{row.get('outcome')}"
            if key in seen:
                continue
            seen.add(key)
            deduped.append(row)
            if len(deduped) >= limit:
                break

        return {"rows": deduped, "limit": limit}

    def forensics(self) -> dict[str, Any]:
        targets = [
            SurfaceTarget("Lineage", "Trade Lineage Stream", "ai_institutional_learning_trade_lineage.jsonl", kind="jsonl", stale_after_seconds=8 * 3600),
            SurfaceTarget("Lineage", "Lineage Status", "ai_institutional_learning_lineage_status.json", stale_after_seconds=8 * 3600),
            SurfaceTarget("Lineage", "Decision Context Stream", "ai_institutional_learning_decision_context.jsonl", kind="jsonl", stale_after_seconds=8 * 3600),
            SurfaceTarget("Evidence Completeness", "Trade Feedback", "ai_trade_feedback.json", stale_after_seconds=24 * 3600),
            SurfaceTarget("Evidence Completeness", "Evidence Completeness Status", "ai_trade_evidence_completeness_status.json", stale_after_seconds=8 * 3600),
            SurfaceTarget("Decision Envelope Observability", "Decision Envelope Trace", "ai_decision_envelope_trace.jsonl", kind="jsonl", stale_after_seconds=8 * 3600),
            SurfaceTarget("Decision Envelope Observability", "Envelope Observability Status", "ai_decision_envelope_observability_status.json", stale_after_seconds=8 * 3600),
            SurfaceTarget("Advisory Diagnostics", "ATAS Advisory Status", "atas_governed_advisory_status.json", stale_after_seconds=4 * 3600),
            SurfaceTarget("Advisory Diagnostics", "ATAS Advisory Effectiveness", "atas_governed_advisory_effectiveness.json", stale_after_seconds=12 * 3600),
            SurfaceTarget("Advisory Diagnostics", "ATAS Microstructure Status (Primary)", "atas_microstructure_status.json", stale_after_seconds=4 * 3600),
            SurfaceTarget("Advisory Diagnostics", "ATAS Microstructure Context (Primary)", "atas_microstructure_context.json", stale_after_seconds=12 * 3600),
            SurfaceTarget("Advisory Diagnostics", "ATAS Runtime Context Status (Legacy Transitional)", "atas_runtime_context_status.json", stale_after_seconds=4 * 3600, optional=True),
            SurfaceTarget("Advisory Diagnostics", "ATAS Runtime Context (Legacy Transitional)", "atas_runtime_context.json", stale_after_seconds=12 * 3600, optional=True),
            SurfaceTarget("Learning Status", "Institutional Learning Status", "ai_institutional_learning_status.json", stale_after_seconds=12 * 3600),
            SurfaceTarget("Learning Status", "Institutional Learning Memory", "ai_institutional_learning_memory.json", stale_after_seconds=12 * 3600),
            SurfaceTarget("Learning Status", "Institutional Learning Events", "ai_institutional_learning_events.jsonl", kind="jsonl", stale_after_seconds=12 * 3600),
            SurfaceTarget("Learning Status", "Strategy Memory Events", "ai_strategy_memory_events.jsonl", kind="jsonl", stale_after_seconds=8 * 3600),
            SurfaceTarget("Runtime Authority / Readiness", "Runtime Governance Status", "runtime_governance_status.json", stale_after_seconds=4 * 3600),
            SurfaceTarget("Runtime Authority / Readiness", "Execution Authority Status", "execution_authority_status.json", stale_after_seconds=4 * 3600),
            SurfaceTarget("Runtime Authority / Readiness", "Operational Integrity Status", "operational_integrity_status.json", stale_after_seconds=4 * 3600),
            SurfaceTarget("Runtime Authority / Readiness", "AI Readiness Status", "ai_activation_readiness_status.json", stale_after_seconds=4 * 3600),
            SurfaceTarget("Adapter Runtime", "Adapter Status", "runtime/adapter_status.json", root="adapter", stale_after_seconds=6 * 3600, optional=True),
            SurfaceTarget("Adapter Runtime", "Producer Input", "runtime/producer_input/atas_export_payload.json", root="adapter", stale_after_seconds=6 * 3600, optional=True),
            SurfaceTarget("Adapter Runtime", "Exporter Status", "future_exporter/runtime/exporter_status.json", root="adapter", stale_after_seconds=6 * 3600, optional=True),
            SurfaceTarget("Adapter Runtime", "Acquisition Input", "future_exporter/runtime/acquisition_input/acquisition_input_payload.json", root="adapter", stale_after_seconds=6 * 3600, optional=True),
        ]

        sections: dict[str, list[dict[str, Any]]] = {}
        counts = {
            "AVAILABLE": 0,
            "STALE": 0,
            "MISSING": 0,
            "NOT_YET_PRODUCED": 0,
            "BLOCKED": 0,
            "INELIGIBLE": 0,
            "EMPTY_BUT_VALID": 0,
        }
        health_counts = {
            "HEALTHY": 0,
            "DEGRADED": 0,
            "AGGREGATION_ONLY": 0,
            "RISK": 0,
        }

        for target in targets:
            surface = self._classify_surface(target)
            sections.setdefault(target.group, []).append(surface)
            counts[surface["classification"]] = counts.get(surface["classification"], 0) + 1
            health_counts[surface["health_state"]] = health_counts.get(surface["health_state"], 0) + 1

        ordered_sections = [
            {"name": name, "surfaces": surfaces}
            for name, surfaces in sections.items()
        ]
        return {
            "sections": ordered_sections,
            "counts": counts,
            "health_counts": health_counts,
            "classification_legend": [
                "AVAILABLE",
                "STALE",
                "MISSING",
                "NOT_YET_PRODUCED",
                "BLOCKED",
                "INELIGIBLE",
                "EMPTY_BUT_VALID",
            ],
            "health_legend": [
                "HEALTHY",
                "DEGRADED",
                "AGGREGATION_ONLY",
                "RISK",
            ],
        }

    def levels(self) -> dict[str, Any]:
        env_rows = self._sort_latest(self.store.load_jsonl("ai_decision_envelope_trace.jsonl", limit=1200), ["ts"])
        feedback = self.store.load_json("ai_trade_feedback.json")
        atas_ctx, _ = self._load_atas_context_surface()
        ctx_status, ctx_status_surface = self._load_atas_status_surface()
        adv = self.store.load_json("atas_governed_advisory_status.json")

        final_layer = self._collect_final_runtime_levels(env_rows, feedback)
        atas_truth = self._atas_reference_truth(ctx_status, adv, atas_ctx, ctx_status_surface)

        atas_supports: list[dict[str, Any]] = []
        atas_resistances: list[dict[str, Any]] = []
        historical_supports: list[dict[str, Any]] = []
        historical_resistances: list[dict[str, Any]] = []

        if atas_truth["live_valid"]:
            adv_s = self._positive_number_or_none(adv.get("nearest_support_price"))
            adv_r = self._positive_number_or_none(adv.get("nearest_resistance_price"))
            if adv_s is not None:
                self._add_unique_price(
                    atas_supports,
                    float(adv_s),
                    "atas_governed_advisory_status",
                    adv.get("gate_reason_code", UNAVAILABLE),
                )
            if adv_r is not None:
                self._add_unique_price(
                    atas_resistances,
                    float(adv_r),
                    "atas_governed_advisory_status",
                    adv.get("gate_reason_code", UNAVAILABLE),
                )

            levels = atas_ctx.get("level_candidates", [])
            if isinstance(levels, list):
                for lvl in levels:
                    if not isinstance(lvl, dict):
                        continue
                    p = self._positive_number_or_none(lvl.get("level_price"))
                    side = str(lvl.get("level_side_candidate", "")).upper()
                    if p is None:
                        continue
                    if "SUPPORT" in side:
                        self._add_unique_price(
                            atas_supports,
                            float(p),
                            "atas_packet_live",
                            lvl.get("market_behavior_tag", UNAVAILABLE),
                        )
                    elif "RESISTANCE" in side:
                        self._add_unique_price(
                            atas_resistances,
                            float(p),
                            "atas_packet_live",
                            lvl.get("market_behavior_tag", UNAVAILABLE),
                        )
                    if len(atas_supports) >= 2 and len(atas_resistances) >= 2:
                        break
        else:
            levels = atas_ctx.get("level_candidates", [])
            if isinstance(levels, list):
                for lvl in levels:
                    if not isinstance(lvl, dict):
                        continue
                    p = self._positive_number_or_none(lvl.get("level_price"))
                    side = str(lvl.get("level_side_candidate", "")).upper()
                    if p is None:
                        continue
                    if "SUPPORT" in side:
                        self._add_unique_price(
                            historical_supports,
                            float(p),
                            "atas_packet_historical_only",
                            lvl.get("fresh_until", UNAVAILABLE),
                        )
                    elif "RESISTANCE" in side:
                        self._add_unique_price(
                            historical_resistances,
                            float(p),
                            "atas_packet_historical_only",
                            lvl.get("fresh_until", UNAVAILABLE),
                        )
                    if len(historical_supports) >= 2 and len(historical_resistances) >= 2:
                        break

        final_supports = final_layer["supports"][:2]
        final_resistances = final_layer["resistances"][:2]
        atas_supports = atas_supports[:2]
        atas_resistances = atas_resistances[:2]
        historical_supports = historical_supports[:2]
        historical_resistances = historical_resistances[:2]

        tolerance = self._inferred_tolerance(final_supports + final_resistances + atas_supports + atas_resistances)
        point_value = tolerance / 10.0 if tolerance > 0 else 0.1
        self._mark_confluence(final_supports, atas_supports, tolerance)
        self._mark_confluence(final_resistances, atas_resistances, tolerance)

        support_comparisons = self._build_side_comparisons(
            "SUPPORT", final_supports, atas_supports, tolerance, point_value
        )
        resistance_comparisons = self._build_side_comparisons(
            "RESISTANCE", final_resistances, atas_resistances, tolerance, point_value
        )

        return {
            "final_layer": {
                "supports": final_supports,
                "resistances": final_resistances,
                "state": final_layer["state"],
                "reason": final_layer["reason"],
            },
            "atas_layer": {
                "supports": atas_supports,
                "resistances": atas_resistances,
                "state": atas_truth["state"],
                "reason": atas_truth["reason"],
                "live_valid": atas_truth["live_valid"],
                "source_surface": atas_truth["source_surface"],
            },
            "atas_diagnostic_historical": {
                "supports": historical_supports,
                "resistances": historical_resistances,
                "present": bool(historical_supports or historical_resistances),
                "note": "Historical ATAS packet levels shown as diagnostic-only because live-valid ATAS reference is not available.",
            },
            "comparison": {
                "point_value": point_value,
                "confluence_tolerance": tolerance,
                "supports": support_comparisons,
                "resistances": resistance_comparisons,
            },
            "atas_reference_truth": atas_truth,
        }

    def inspect(self, query: str) -> dict[str, Any]:
        token = query.strip()
        if not token:
            return {
                "query": token,
                "matches": [],
                "decision_records": [],
                "match_count": 0,
                "supported_identifiers": ["decision_id", "position_id", "ticket", "deal_id", "entry_deal_id", "close_deal_id"],
                "state_legend": [DIRECT, DERIVED, UNAVAILABLE, STALE, NOT_PRODUCED],
            }

        trades_payload = self.trades(limit=400)
        rows = trades_payload["rows"]
        needle = token.lower()

        matched_rows: list[dict[str, Any]] = []
        for row in rows:
            key_fields = [
                str(row.get("decision_id", "")),
                str(row.get("position_id", "")),
                str(row.get("close_deal_id", "")),
                str(row.get("entry_deal_id", "")),
                str(row.get("trade_lineage_key", "")),
                str(row.get("symbol", "")),
            ]
            if any(needle == k.lower() for k in key_fields if k):
                matched_rows.append(row)
                continue
            if any(needle in k.lower() for k in key_fields if k):
                matched_rows.append(row)

        detailed: list[dict[str, Any]] = []
        for row in matched_rows[:60]:
            detailed.append(
                {
                    "identity": {
                        "decision_id": row.get("decision_id", UNAVAILABLE),
                        "position_id": row.get("position_id", UNAVAILABLE),
                        "close_deal_id": row.get("close_deal_id", UNAVAILABLE),
                        "entry_deal_id": row.get("entry_deal_id", UNAVAILABLE),
                        "trade_lineage_key": row.get("trade_lineage_key", UNAVAILABLE),
                        "symbol": row.get("symbol", UNAVAILABLE),
                        "direction": row.get("direction", UNAVAILABLE),
                    },
                    "strategy": {
                        "strategy_id": row.get("strategy_id", UNAVAILABLE),
                        "strategy_id_state": row.get("strategy_id_state", UNAVAILABLE),
                        "strategy_family": row.get("strategy_family", UNAVAILABLE),
                        "strategy_family_state": row.get("strategy_family_state", UNAVAILABLE),
                    },
                    "regime": {
                        "regime_label": row.get("regime_label", UNAVAILABLE),
                        "volatility_regime": row.get("volatility_regime", UNAVAILABLE),
                        "structure_bucket": row.get("structure_bucket", UNAVAILABLE),
                    },
                    "support_resistance": {
                        "sr_interaction_bucket": row.get("sr_interaction_bucket", UNAVAILABLE),
                        "sr_interaction_bucket_state": row.get("sr_interaction_bucket_state", UNAVAILABLE),
                        "canonical_level_state": row.get("canonical_level_state", UNAVAILABLE),
                        "level_interaction_type": row.get("level_interaction_type", UNAVAILABLE),
                        "nearest_support_price": row.get("nearest_support_price", UNAVAILABLE),
                        "nearest_resistance_price": row.get("nearest_resistance_price", UNAVAILABLE),
                    },
                    "advisory": {
                        "advisory_eligible": row.get("advisory_eligible", UNAVAILABLE),
                        "advisory_eligible_state": row.get("advisory_eligible_state", UNAVAILABLE),
                        "advisory_usage_state": row.get("advisory_usage_state", UNAVAILABLE),
                        "advisory_usage_state_data_state": row.get("advisory_usage_state_data_state", UNAVAILABLE),
                        "advisory_zero_effect_reason": row.get("advisory_zero_effect_reason", UNAVAILABLE),
                    },
                    "attribution": {
                        "runtime_primary_attribution": row.get("runtime_primary_attribution", UNAVAILABLE),
                        "runtime_secondary_attribution": row.get("runtime_secondary_attribution", UNAVAILABLE),
                        "trade_result": row.get("trade_result", UNAVAILABLE),
                        "profit": row.get("profit", UNAVAILABLE),
                    },
                    "learning": {
                        "learning_confidence_delta": row.get("learning_confidence_delta", UNAVAILABLE),
                        "learning_caution_score": row.get("learning_caution_score", UNAVAILABLE),
                    },
                    "decision_posture": {
                        "decision_acceptance_posture": row.get("decision_acceptance_posture", UNAVAILABLE),
                        "decision_acceptance_posture_state": row.get("decision_acceptance_posture_state", UNAVAILABLE),
                        "decision_reasoning_flags": row.get("decision_reasoning_flags", UNAVAILABLE),
                    },
                    "timing": {
                        "entry_time": row.get("entry_time", UNAVAILABLE),
                        "exit_time": row.get("exit_time", UNAVAILABLE),
                        "source_timestamp": row.get("source_timestamp", UNAVAILABLE),
                        "freshness_state": row.get("freshness_state", UNAVAILABLE),
                    },
                }
            )

        decision_records: list[dict[str, Any]] = []
        if not detailed:
            decision_records = self._inspect_decision_records(token)

        return {
            "query": token,
            "matches": detailed,
            "decision_records": decision_records,
            "match_count": len(detailed) + len(decision_records),
            "supported_identifiers": ["decision_id", "position_id", "ticket", "deal_id", "entry_deal_id", "close_deal_id"],
            "state_legend": [DIRECT, DERIVED, UNAVAILABLE, STALE, NOT_PRODUCED],
        }

    def atas_live_chain(self, event_limit: int = 120) -> dict[str, Any]:
        event_limit = max(10, min(event_limit, 500))

        chain = self.store.load_json("atas_live_capture/atas_live_chain_status.json")
        inventory = self.store.load_json("atas_live_capture/atas_live_field_inventory.json")
        events = self._sort_latest(
            self.store.load_jsonl("atas_live_capture/atas_live_event_stream.jsonl", limit=5000),
            ["captured_at_utc", "event_time", "ts"],
        )[:event_limit]

        observation = self.store.load_json("atas_live_capture/latest_observation_snapshot.json")
        exporter = self.store.load_json("atas_live_capture/latest_exporter_snapshot.json")
        acquisition_input = self.store.load_json("atas_live_capture/latest_acquisition_input_snapshot.json")
        producer = self.store.load_json("atas_live_capture/latest_producer_input_snapshot.json")
        adapter = self.store.load_json("atas_live_capture/latest_adapter_snapshot.json")
        intake = self.store.load_json("atas_live_capture/latest_mt5_intake_snapshot.json")
        context = self.store.load_json("atas_live_capture/latest_context_snapshot.json")
        advisory = self.store.load_json("atas_live_capture/latest_advisory_snapshot.json")

        if chain.get("_status") == UNAVAILABLE:
            return {
                "state": "NOT_PRODUCED",
                "reason": "ATAS_LIVE_CAPTURE_NOT_RUNNING_OR_NOT_YET_STARTED",
                "chain": {},
                "events": [],
                "inventory": {},
                "snapshots": {},
                "event_limit": event_limit,
            }

        return {
            "state": "AVAILABLE",
            "reason": "ATAS_LIVE_CAPTURE_RUNNING_OR_LAST_RUN_PRESENT",
            "chain": chain,
            "inventory": inventory if inventory.get("_status") != UNAVAILABLE else {},
            "events": events,
            "event_limit": event_limit,
            "snapshots": {
                "observation": observation if observation.get("_status") != UNAVAILABLE else {},
                "exporter": exporter if exporter.get("_status") != UNAVAILABLE else {},
                "acquisition_input": acquisition_input if acquisition_input.get("_status") != UNAVAILABLE else {},
                "producer_input": producer if producer.get("_status") != UNAVAILABLE else {},
                "adapter": adapter if adapter.get("_status") != UNAVAILABLE else {},
                "intake": intake if intake.get("_status") != UNAVAILABLE else {},
                "context": context if context.get("_status") != UNAVAILABLE else {},
                "advisory": advisory if advisory.get("_status") != UNAVAILABLE else {},
            },
        }

    def _classify_surface(self, target: SurfaceTarget) -> dict[str, Any]:
        meta = self.store.get_file_meta(target.rel_path, root=target.root)
        if not meta["exists"]:
            return {
                "name": target.name,
                "classification": "NOT_YET_PRODUCED" if target.optional else "MISSING",
                "reason": "FILE_MISSING",
                "path": meta["path"],
                "updated_at": "UNAVAILABLE",
                "age_seconds": None,
                "health_state": "RISK",
            }

        if target.kind == "jsonl":
            rows = self.store.load_jsonl(target.rel_path, root=target.root, limit=1200)
            if meta["size"] == 0 or not rows:
                return {
                    "name": target.name,
                    "classification": "EMPTY_BUT_VALID",
                    "reason": "NO_ROWS_OR_EMPTY_FILE",
                    "path": meta["path"],
                    "updated_at": meta["updated_at"],
                    "age_seconds": meta["age_seconds"],
                    "health_state": "DEGRADED",
                }
            latest = self._sort_latest(rows, ["ts", "captured_at", "evaluated_at", "updated_at"])[0]
            updated = self._pick_raw(latest, keys=["ts", "captured_at", "evaluated_at", "updated_at"])
            age = ArtifactStore.timestamp_age_seconds(updated)
            classification = "AVAILABLE"
            reason = "LATEST_ROW_PRESENT"
            if isinstance(age, int) and age > target.stale_after_seconds:
                classification = "STALE"
                reason = f"STALE_BY_AGE>{target.stale_after_seconds}s"
            return {
                "name": target.name,
                "classification": classification,
                "reason": reason,
                "path": meta["path"],
                "updated_at": updated if self._is_present(updated) else meta["updated_at"],
                "age_seconds": age if isinstance(age, int) else meta["age_seconds"],
                "health_state": "HEALTHY" if classification == "AVAILABLE" else "RISK",
            }

        obj = self.store.load_json(target.rel_path, root=target.root)
        if obj.get("_status") == UNAVAILABLE:
            return {
                "name": target.name,
                "classification": "MISSING",
                "reason": obj.get("_reason", "JSON_READ_ERROR"),
                "path": meta["path"],
                "updated_at": meta["updated_at"],
                "age_seconds": meta["age_seconds"],
                "health_state": "RISK",
            }
        if meta["size"] == 0 or (isinstance(obj, dict) and len(obj) == 0):
            return {
                "name": target.name,
                "classification": "EMPTY_BUT_VALID",
                "reason": "EMPTY_JSON_OBJECT_OR_FILE",
                "path": meta["path"],
                "updated_at": meta["updated_at"],
                "age_seconds": meta["age_seconds"],
                "health_state": "DEGRADED",
            }

        updated = self._pick_raw(obj, keys=["evaluated_at", "updated_at", "status_timestamp", "rebuilt_at", "last_updated"])
        age = ArtifactStore.timestamp_age_seconds(updated)
        reason = self._pick_raw(
            obj,
            keys=[
                "reason_code",
                "gate_reason_code",
                "ineligibility_reason_code",
                "advisory_ineligibility_reason_code",
                "rejection_reason",
                "overall_reason",
                "state_code",
                "_reason",
            ],
        )
        classification = "AVAILABLE"
        reason_text = str(reason if self._is_present(reason) else "OK")
        reason_upper = reason_text.upper()
        advisory_surface = (
            target.group == "Advisory Diagnostics"
            or "ADVISORY" in target.name.upper()
            or "ATAS RUNTIME CONTEXT STATUS" in target.name.upper()
        )

        if advisory_surface and (
            "INELIGIBLE" in reason_upper or str(obj.get("advisory_eligible", "")).lower() == "false"
        ):
            classification = "INELIGIBLE"
            if reason_text == "OK":
                reason_text = "ADVISORY_ELIGIBILITY_FALSE"
        elif advisory_surface and "BLOCK" in reason_upper:
            classification = "BLOCKED"
        else:
            freshness = str(obj.get("freshness_state", "")).upper()
            if freshness in {"STALE", "EXPIRED"}:
                classification = "STALE"
            elif isinstance(age, int) and age > target.stale_after_seconds:
                classification = "STALE"

        health_state = "HEALTHY"
        state_code = str(obj.get("state_code", "")).upper()
        lineage_state = str(obj.get("last_sr_status", "")).upper()
        if classification in {"STALE", "MISSING", "BLOCKED", "INELIGIBLE"}:
            health_state = "RISK"
        elif "DEGRADED" in state_code or "FLATTENED" in lineage_state:
            health_state = "DEGRADED"
        elif target.group == "Learning Status" and "MEMORY" in target.name.upper():
            health_state = "AGGREGATION_ONLY"

        return {
            "name": target.name,
            "classification": classification,
            "reason": reason_text,
            "path": meta["path"],
            "updated_at": updated if self._is_present(updated) else meta["updated_at"],
            "age_seconds": age if isinstance(age, int) else meta["age_seconds"],
            "health_state": health_state,
        }

    def _collect_final_runtime_levels(self, env_rows: list[dict[str, Any]], feedback: dict[str, Any]) -> dict[str, Any]:
        final_supports: list[dict[str, Any]] = []
        final_resistances: list[dict[str, Any]] = []
        found_from_env = False

        for row in env_rows:
            s = self._positive_number_or_none(row.get("nearest_support_price"))
            r = self._positive_number_or_none(row.get("nearest_resistance_price"))
            if s is not None:
                self._add_unique_price(final_supports, float(s), "decision_envelope", row.get("decision_id", UNAVAILABLE))
                found_from_env = True
            if r is not None:
                self._add_unique_price(final_resistances, float(r), "decision_envelope", row.get("decision_id", UNAVAILABLE))
                found_from_env = True
            if len(final_supports) >= 2 and len(final_resistances) >= 2:
                break

        fbs = self._positive_number_or_none(feedback.get("linked_nearest_support_price"))
        fbr = self._positive_number_or_none(feedback.get("linked_nearest_resistance_price"))
        if fbs is not None:
            self._add_unique_price(
                final_supports,
                float(fbs),
                "trade_feedback_linked",
                feedback.get("decision_id", UNAVAILABLE),
            )
        if fbr is not None:
            self._add_unique_price(
                final_resistances,
                float(fbr),
                "trade_feedback_linked",
                feedback.get("decision_id", UNAVAILABLE),
            )

        final_supports = final_supports[:2]
        final_resistances = final_resistances[:2]
        if final_supports or final_resistances:
            if found_from_env:
                reason = "FINAL_RUNTIME_RELIED_ON:DECISION_ENVELOPE_CONTEXT"
            else:
                reason = "FINAL_RUNTIME_RELIED_ON:TRADE_FEEDBACK_LINKED_FALLBACK"
            return {
                "supports": final_supports,
                "resistances": final_resistances,
                "state": "AVAILABLE",
                "reason": reason,
            }
        return {
            "supports": [],
            "resistances": [],
            "state": "UNAVAILABLE",
            "reason": "FINAL_RUNTIME_SR_UNAVAILABLE",
        }

    def _atas_reference_truth(
        self,
        ctx_status: dict[str, Any],
        advisory: dict[str, Any],
        ctx: dict[str, Any],
        status_surface: str = ATAS_STATUS_PRIMARY,
    ) -> dict[str, Any]:
        if not isinstance(status_surface, str) or not status_surface:
            status_surface = ATAS_STATUS_PRIMARY
        if not isinstance(ctx_status, dict) or ctx_status.get("_status") == UNAVAILABLE:
            return {
                "state": "ATAS_REFERENCE_ABSENT",
                "reason": "STATUS_SURFACE_MISSING_OR_UNREADABLE",
                "live_valid": False,
                "source_surface": status_surface,
            }

        packet_levels = ctx.get("level_candidates", []) if isinstance(ctx, dict) else []
        has_packet_levels = any(
            isinstance(x, dict) and self._positive_number_or_none(x.get("level_price")) is not None
            for x in packet_levels
        )
        # has_packet_identity: check status file (flat, always present when evaluated) and legacy flat ctx
        has_packet_identity = (
            (self._is_present(ctx_status.get("packet_id")) if isinstance(ctx_status, dict) else False)
            or (self._is_present(ctx.get("packet_id")) if isinstance(ctx, dict) else False)
        )
        # has_signal_payload: microstructure signals present (DIRECT_WRITE_CORE_V1 schema)
        has_signal_payload = (
            isinstance(ctx, dict)
            and isinstance(ctx.get("signal_payload"), dict)
            and bool(ctx.get("signal_payload"))
        )

        atas_available = self._to_bool(ctx_status.get("atas_available"))
        atas_attached = self._to_bool(ctx_status.get("atas_shadow_attached"))
        atas_fresh = self._to_bool(ctx_status.get("atas_fresh"))
        freshness_state = str(ctx_status.get("freshness_state", "")).upper()
        acceptance_state = str(ctx_status.get("acceptance_state", "")).upper()
        rejection_reason = str(ctx_status.get("rejection_reason", "UNAVAILABLE"))

        advisory_eligible = self._to_bool(advisory.get("advisory_eligible"))
        gate_reason = str(advisory.get("gate_reason_code", "UNAVAILABLE"))
        # advisory_not_evaluated: advisory idle — no active trade candidate, not a failure state
        advisory_not_evaluated = (
            str(advisory.get("advisory_attachment_state", "")).upper() == "ADVISORY_NOT_EVALUATED"
            and str(advisory.get("gate_reason_code", "")).lower() == "not_evaluated"
        )
        gate_blocked = (
            not self._to_bool(advisory.get("gate_shadow_attached"))
            or not self._to_bool(advisory.get("gate_freshness_valid"))
            or not self._to_bool(advisory.get("gate_source_valid"))
            or not self._to_bool(advisory.get("gate_symbol_mapping_valid"))
            or not self._to_bool(advisory.get("gate_session_valid"))
            or not self._to_bool(advisory.get("gate_translation_valid"))
        )
        price_anchor_suppressed = self._to_bool(ctx_status.get("price_anchor_fields_suppressed"))
        packet_age = int(ctx_status.get("packet_age_ms", -1)) if str(ctx_status.get("packet_age_ms", "")).isdigit() else -1
        historical_age_ms = 60 * 60 * 1000

        if not atas_available:
            state = "ATAS_REFERENCE_ABSENT"
            reason = f"atas_available_false:{rejection_reason}"
        elif (not atas_attached) or ("NOT_ATTACHED" in acceptance_state):
            state = "ATAS_REFERENCE_NOT_ATTACHED"
            reason = rejection_reason
        elif "EXPIRED" in freshness_state:
            if has_packet_levels or has_packet_identity or packet_age >= historical_age_ms:
                state = "ATAS_REFERENCE_HISTORICAL_ONLY"
                reason = f"expired_with_historical_packet:{rejection_reason}"
            else:
                state = "ATAS_REFERENCE_EXPIRED"
                reason = rejection_reason
        elif (not atas_fresh) or ("STALE" in freshness_state):
            state = "ATAS_REFERENCE_STALE"
            reason = rejection_reason
        elif price_anchor_suppressed:
            # Cross-instrument mapping (e.g. GC->XAUUSD): price anchors suppressed by design.
            # Microstructure signals remain valid. This is expected behaviour, not a blockage.
            if has_signal_payload or has_packet_identity:
                state = "ATAS_REFERENCE_LIVE_SIGNALS_ONLY"
                reason = "cross_instrument_attached_signals_only_price_anchors_suppressed_by_design"
            else:
                state = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE"
                reason = "price_anchor_fields_suppressed_no_signals"
        elif advisory_not_evaluated:
            # Advisory idle: no active trade candidate currently being evaluated.
            # Shadow is attached and fresh — this is a normal between-decision state, not a failure.
            state = "ATAS_REFERENCE_ATTACHED_ADVISORY_PENDING"
            reason = "advisory_idle_no_active_trade_candidate"
        elif (not advisory_eligible) or gate_blocked:
            state = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE"
            reason = f"advisory_gate:{gate_reason}"
        elif has_packet_levels:
            state = "ATAS_LIVE_REFERENCE_AVAILABLE"
            reason = "live_valid_attached_fresh_eligible"
        else:
            state = "ATAS_REFERENCE_DEFAULTED_OR_INVALID"
            reason = "no_live_numeric_levels"

        return {
            "state": state,
            "reason": reason,
            "live_valid": state in (
                "ATAS_LIVE_REFERENCE_AVAILABLE",
                "ATAS_REFERENCE_LIVE_SIGNALS_ONLY",
                "ATAS_REFERENCE_ATTACHED_ADVISORY_PENDING",
            ),
            "source_surface": status_surface,
            "status_timestamp": ctx_status.get("status_timestamp_utc", UNAVAILABLE),
            "packet_id": ctx_status.get("packet_id", UNAVAILABLE),
            "freshness_state": ctx_status.get("freshness_state", UNAVAILABLE),
            "acceptance_state": ctx_status.get("acceptance_state", UNAVAILABLE),
            "advisory_eligible": advisory.get("advisory_eligible", UNAVAILABLE),
        }

    def _decision_id_base(self, decision_id: str) -> str:
        if not isinstance(decision_id, str) or not decision_id:
            return ""
        parts = decision_id.split("-")
        while len(parts) >= 4 and parts[-1].isdigit():
            parts = parts[:-1]
        return "-".join(parts)

    def _decision_stamp_key(self, decision_id: str) -> str:
        if not isinstance(decision_id, str) or not decision_id:
            return ""
        parts = decision_id.split("-")
        if len(parts) >= 2 and parts[0] and parts[1]:
            return f"{parts[0]}-{parts[1]}"
        return decision_id

    def _index_latest_by_decision_base(
        self,
        rows: list[dict[str, Any]],
        key: str,
        ts_keys: list[str],
    ) -> dict[str, dict[str, Any]]:
        out: dict[str, dict[str, Any]] = {}
        for row in self._sort_latest(rows, ts_keys):
            value = row.get(key)
            if not isinstance(value, str) or not value:
                continue
            base = self._decision_id_base(value)
            if base and base not in out:
                out[base] = row
        return out

    def _index_latest_by_decision_stamp(
        self,
        rows: list[dict[str, Any]],
        key: str,
        ts_keys: list[str],
    ) -> dict[str, dict[str, Any]]:
        out: dict[str, dict[str, Any]] = {}
        first_id: dict[str, str] = {}
        ambiguous: set[str] = set()
        for row in self._sort_latest(rows, ts_keys):
            value = row.get(key)
            if not isinstance(value, str) or not value:
                continue
            stamp = self._decision_stamp_key(value)
            if not stamp or stamp in ambiguous:
                continue
            prior_id = first_id.get(stamp, "")
            if not prior_id:
                first_id[stamp] = value
                out[stamp] = row
                continue
            if prior_id != value:
                ambiguous.add(stamp)
                out.pop(stamp, None)
        return out

    def _resolve_by_decision(
        self,
        decision_id: str,
        by_decision: dict[str, dict[str, Any]],
        by_base: dict[str, dict[str, Any]],
        by_stamp: dict[str, dict[str, Any]],
    ) -> tuple[dict[str, Any], str]:
        did = decision_id if isinstance(decision_id, str) else ""
        if did and did in by_decision:
            return by_decision[did], DIRECT
        base = self._decision_id_base(did)
        if base and base in by_base:
            return by_base[base], DERIVED
        stamp = self._decision_stamp_key(did)
        if stamp and stamp in by_stamp:
            return by_stamp[stamp], DERIVED
        return {}, UNAVAILABLE

    def _positive_number_or_none(self, value: Any) -> float | None:
        if isinstance(value, (int, float)) and float(value) > 0:
            return float(value)
        return None

    def _to_bool(self, value: Any) -> bool:
        if isinstance(value, bool):
            return value
        if isinstance(value, (int, float)):
            return value != 0
        if isinstance(value, str):
            v = value.strip().lower()
            if v in {"true", "1", "yes", "y"}:
                return True
            if v in {"false", "0", "no", "n"}:
                return False
        return False

    def _inspect_decision_records(self, token: str) -> list[dict[str, Any]]:
        needle = token.lower()
        env_rows = self._sort_latest(self.store.load_jsonl("ai_decision_envelope_trace.jsonl", limit=8000), ["ts"])
        memory_rows = self._sort_latest(self.store.load_jsonl("ai_strategy_memory_events.jsonl", limit=12000), ["ts"])
        dctx_rows = self._sort_latest(
            self.store.load_jsonl("ai_institutional_learning_decision_context.jsonl", limit=8000),
            ["captured_at"],
        )
        lineages = self._sort_latest(
            self.store.load_jsonl("ai_institutional_learning_trade_lineage.jsonl", limit=4000),
            ["captured_at"],
        )
        events = self._sort_latest(
            self.store.load_jsonl("ai_institutional_learning_events.jsonl", limit=8000),
            ["captured_at"],
        )

        env_by_decision = self._index_latest(env_rows, "decision_id", ["ts"])
        env_by_decision_base = self._index_latest_by_decision_base(env_rows, "decision_id", ["ts"])
        env_by_decision_stamp = self._index_latest_by_decision_stamp(env_rows, "decision_id", ["ts"])
        dctx_by_decision = self._index_latest(dctx_rows, "decision_id", ["captured_at"])
        dctx_by_decision_base = self._index_latest_by_decision_base(dctx_rows, "decision_id", ["captured_at"])
        dctx_by_decision_stamp = self._index_latest_by_decision_stamp(
            dctx_rows, "decision_id", ["captured_at"]
        )
        mem_by_decision = self._index_latest(memory_rows, "decision_id", ["ts"])
        mem_by_decision_base = self._index_latest_by_decision_base(memory_rows, "decision_id", ["ts"])
        mem_by_decision_stamp = self._index_latest_by_decision_stamp(
            memory_rows, "decision_id", ["ts"]
        )
        lin_by_decision = self._index_latest(lineages, "decision_id", ["captured_at"])
        lin_by_decision_base = self._index_latest_by_decision_base(lineages, "decision_id", ["captured_at"])
        lin_by_decision_stamp = self._index_latest_by_decision_stamp(
            lineages, "decision_id", ["captured_at"]
        )
        ev_by_decision = self._index_latest(events, "decision_id", ["captured_at"])
        ev_by_decision_base = self._index_latest_by_decision_base(events, "decision_id", ["captured_at"])
        ev_by_decision_stamp = self._index_latest_by_decision_stamp(events, "decision_id", ["captured_at"])

        candidate_ids: list[str] = []
        for src in (env_rows, memory_rows, dctx_rows, lineages, events):
            for row in src:
                did = str(row.get("decision_id", ""))
                if not did:
                    continue
                if needle == did.lower() or needle in did.lower():
                    candidate_ids.append(did)
                    if len(candidate_ids) >= 40:
                        break
            if len(candidate_ids) >= 40:
                break

        if token.isdigit():
            for src in (lineages, events):
                for row in src:
                    for key in ("position_id", "close_deal_id", "entry_deal_id"):
                        value = row.get(key)
                        if value is None:
                            continue
                        if str(value) == token:
                            did = str(row.get("decision_id", ""))
                            if did:
                                candidate_ids.append(did)
                            break
                    tlk = str(row.get("trade_lineage_key", ""))
                    if tlk and token in tlk:
                        did = str(row.get("decision_id", ""))
                        if did:
                            candidate_ids.append(did)
                    if len(candidate_ids) >= 80:
                        break
                if len(candidate_ids) >= 80:
                    break

        dedup: list[str] = []
        seen: set[str] = set()
        for did in candidate_ids:
            base = self._decision_id_base(did)
            stamp = self._decision_stamp_key(did)
            key = stamp or base or did
            if key in seen:
                continue
            seen.add(key)
            dedup.append(did)

        records: list[dict[str, Any]] = []
        for did in dedup[:20]:
            base = self._decision_id_base(did)
            stamp = self._decision_stamp_key(did)
            env = (
                env_by_decision.get(did, {})
                or env_by_decision_base.get(base, {})
                or env_by_decision_stamp.get(stamp, {})
            )
            dctx = (
                dctx_by_decision.get(did, {})
                or dctx_by_decision_base.get(base, {})
                or dctx_by_decision_stamp.get(stamp, {})
            )
            mem = (
                mem_by_decision.get(did, {})
                or mem_by_decision_base.get(base, {})
                or mem_by_decision_stamp.get(stamp, {})
            )
            lin = (
                lin_by_decision.get(did, {})
                or lin_by_decision_base.get(base, {})
                or lin_by_decision_stamp.get(stamp, {})
            )
            ev = (
                ev_by_decision.get(did, {})
                or ev_by_decision_base.get(base, {})
                or ev_by_decision_stamp.get(stamp, {})
            )
            records.append(
                {
                    "identity": {
                        "decision_id": did,
                        "decision_base": base or UNAVAILABLE,
                        "decision_stamp_key": stamp or UNAVAILABLE,
                        "symbol": self._pick_raw(env, dctx, mem, lin, keys=["symbol"]) or UNAVAILABLE,
                        "direction": self._pick_raw(env, dctx, mem, lin, keys=["direction"]) or UNAVAILABLE,
                    },
                    "strategy": {
                        "strategy_id": self._pick_raw(dctx, mem, env, lin, ev, keys=["strategy_id", "best_strategy_id", "runtime_strategy_id_exact"]) or UNAVAILABLE,
                        "strategy_family": self._pick_raw(dctx, mem, lin, ev, keys=["strategy_family", "runtime_strategy_family_exact"]) or UNAVAILABLE,
                    },
                    "regime": {
                        "regime_label": self._pick_raw(env, mem, lin, ev, dctx, keys=["regime_label", "regime_bucket"]) or UNAVAILABLE,
                        "volatility_regime": self._pick_raw(env, mem, lin, dctx, keys=["volatility_regime", "volatility_state", "volatility_bucket"]) or UNAVAILABLE,
                        "structure_bucket": self._pick_raw(env, mem, lin, dctx, keys=["structure_bucket", "structure_state"]) or UNAVAILABLE,
                    },
                    "support_resistance": {
                        "sr_interaction_bucket": self._pick_raw(env, dctx, lin, keys=["sr_interaction_bucket"]) or UNAVAILABLE,
                        "canonical_level_state": self._pick_raw(env, dctx, lin, keys=["canonical_level_state"]) or UNAVAILABLE,
                        "level_interaction_type": self._pick_raw(env, keys=["level_interaction_type"]) or UNAVAILABLE,
                        "nearest_support_price": self._pick_raw(env, keys=["nearest_support_price"]) or UNAVAILABLE,
                        "nearest_resistance_price": self._pick_raw(env, keys=["nearest_resistance_price"]) or UNAVAILABLE,
                    },
                    "advisory": {
                        "advisory_eligible": self._pick_raw(env, keys=["advisory_eligible"]) or UNAVAILABLE,
                        "advisory_usage_state": self._pick_raw(env, keys=["advisory_usage_state"]) or UNAVAILABLE,
                        "advisory_zero_effect_reason": self._pick_raw(env, keys=["advisory_zero_effect_reason"]) or UNAVAILABLE,
                    },
                    "attribution": {
                        "runtime_primary_attribution": self._pick_raw(lin, ev, keys=["runtime_primary_attribution", "primary_attribution"]) or UNAVAILABLE,
                        "runtime_secondary_attribution": self._pick_raw(lin, ev, keys=["runtime_secondary_attribution", "secondary_attribution"]) or UNAVAILABLE,
                    },
                    "learning": {
                        "learning_confidence_delta": self._pick_raw(env, keys=["learning_confidence_delta"]) or UNAVAILABLE,
                        "learning_caution_score": self._pick_raw(env, keys=["learning_caution_score"]) or UNAVAILABLE,
                    },
                    "decision_posture": {
                        "decision_acceptance_posture": self._pick_raw(env, keys=["decision_acceptance_posture"]) or UNAVAILABLE,
                        "decision_reasoning_flags": self._pick_raw(env, keys=["decision_reasoning_flags_csv"]) or UNAVAILABLE,
                    },
                    "timing": {
                        "source_timestamp": self._pick_raw(env, dctx, mem, lin, keys=["ts", "captured_at"]) or UNAVAILABLE,
                        "freshness_state": STALE
                        if isinstance(ArtifactStore.timestamp_age_seconds(self._pick_raw(env, dctx, mem, lin, keys=["ts", "captured_at"])), int)
                        and ArtifactStore.timestamp_age_seconds(self._pick_raw(env, dctx, mem, lin, keys=["ts", "captured_at"])) > 24 * 3600
                        else "FRESH",
                    },
                }
            )
        return records

    def _pick_value(self, candidates: list[tuple[Any, str]], not_produced_when: bool) -> dict[str, str]:
        for value, state in candidates:
            if self._is_present(value):
                return {"value": str(value), "state": state}
        if not_produced_when:
            return {"value": NOT_PRODUCED, "state": NOT_PRODUCED}
        return {"value": UNAVAILABLE, "state": UNAVAILABLE}

    def _pick_raw(self, *objs: dict[str, Any], keys: list[str]) -> Any:
        for obj in objs:
            if not isinstance(obj, dict):
                continue
            for key in keys:
                if key in obj and self._is_present(obj.get(key)):
                    return obj.get(key)
        return None

    def _feedback_if_matching(
        self, feedback: dict[str, Any], decision_id: str, position_id: str, close_deal_id: str
    ) -> dict[str, Any]:
        if not isinstance(feedback, dict) or feedback.get("_status") == UNAVAILABLE:
            return {}
        if decision_id and str(feedback.get("decision_id")) == decision_id:
            return feedback
        if decision_id and str(feedback.get("correlated_decision_id")) == decision_id:
            return feedback
        if position_id and str(feedback.get("position_id")) == position_id:
            return feedback
        if close_deal_id and str(feedback.get("close_deal_id")) == close_deal_id:
            return feedback
        return {}

    def _build_side_comparisons(
        self,
        side: str,
        final_rows: list[dict[str, Any]],
        atas_rows: list[dict[str, Any]],
        tolerance: float,
        point_value: float,
    ) -> list[dict[str, Any]]:
        results: list[dict[str, Any]] = []
        used_atas: set[int] = set()

        for f in final_rows:
            fprice = float(f["price"])
            best_idx = -1
            best_diff = 10**18
            for idx, a in enumerate(atas_rows):
                aprice = float(a["price"])
                diff = abs(fprice - aprice)
                if diff < best_diff:
                    best_diff = diff
                    best_idx = idx
            if best_idx >= 0:
                used_atas.add(best_idx)
                arow = atas_rows[best_idx]
                diff_points = (best_diff / point_value) if point_value > 0 else 0.0
                relation = "CONFLUENCE_NEAR" if best_diff <= tolerance else "DIVERGED"
                results.append(
                    {
                        "side": side,
                        "final_price": fprice,
                        "atas_price": float(arow["price"]),
                        "abs_diff": round(best_diff, 8),
                        "diff_points": round(diff_points, 3),
                        "relation": relation,
                    }
                )
            else:
                results.append(
                    {
                        "side": side,
                        "final_price": fprice,
                        "atas_price": None,
                        "abs_diff": None,
                        "diff_points": None,
                        "relation": "FINAL_ONLY",
                    }
                )

        for idx, a in enumerate(atas_rows):
            if idx in used_atas:
                continue
            results.append(
                {
                    "side": side,
                    "final_price": None,
                    "atas_price": float(a["price"]),
                    "abs_diff": None,
                    "diff_points": None,
                    "relation": "ATAS_ONLY",
                }
            )
        return results

    def _index_latest(self, rows: list[dict[str, Any]], key: str, ts_keys: list[str]) -> dict[str, dict[str, Any]]:
        out: dict[str, dict[str, Any]] = {}
        for row in self._sort_latest(rows, ts_keys):
            value = row.get(key)
            if isinstance(value, str) and value and value not in out:
                out[value] = row
        return out

    def _sort_latest(self, rows: list[dict[str, Any]], ts_keys: list[str]) -> list[dict[str, Any]]:
        def row_key(item: dict[str, Any]) -> str:
            for name in ts_keys:
                value = item.get(name)
                if isinstance(value, str) and value:
                    return value
            return ""

        return sorted(rows, key=row_key, reverse=True)

    def _value(self, obj: dict[str, Any], key: str, default: str = UNAVAILABLE) -> str:
        if not isinstance(obj, dict):
            return default
        value = obj.get(key)
        if not self._is_present(value):
            return default
        return str(value)

    def _is_present(self, value: Any) -> bool:
        if value is None:
            return False
        if isinstance(value, str) and not value.strip():
            return False
        if isinstance(value, str) and value.strip().upper() in {UNAVAILABLE, NOT_PRODUCED}:
            return False
        return True

    def _add_unique_price(self, target: list[dict[str, Any]], price: float, source: str, note: Any) -> None:
        for item in target:
            if abs(item["price"] - price) <= 0.00001:
                return
        target.append({"price": price, "source": source, "note": str(note), "confluence": False})
        target.sort(key=lambda x: x["price"])

    def _inferred_tolerance(self, rows: list[dict[str, Any]]) -> float:
        prices = [float(r["price"]) for r in rows if isinstance(r.get("price"), (int, float))]
        if not prices:
            return 0.1
        max_decimals = 2
        for p in prices:
            txt = f"{p:.8f}".rstrip("0").rstrip(".")
            if "." in txt:
                max_decimals = max(max_decimals, len(txt.split(".")[1]))
        point = 10 ** (-max_decimals)
        return point * 10

    def _mark_confluence(self, final_rows: list[dict[str, Any]], atas_rows: list[dict[str, Any]], tol: float) -> None:
        for f in final_rows:
            for a in atas_rows:
                if abs(float(f["price"]) - float(a["price"])) <= tol:
                    f["confluence"] = True
                    a["confluence"] = True
