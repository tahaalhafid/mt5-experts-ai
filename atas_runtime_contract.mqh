#ifndef __ATAS_RUNTIME_CONTRACT_MQH__
#define __ATAS_RUNTIME_CONTRACT_MQH__

#include "config_loader.mqh"

#define ATAS_RUNTIME_CONTEXT_SCHEMA_VERSION "ATAS_DIRECT_WRITE_CORE_V1"
#define ATAS_RUNTIME_CONTEXT_LEGACY_SCHEMA_VERSION "ATAS_RUNTIME_CONTEXT_V1"
#define ATAS_RUNTIME_STATUS_SCHEMA_VERSION  "ATAS_MICROSTRUCTURE_STATUS_V1"
#define ATAS_MAX_LEVEL_CANDIDATES 3
#define ATAS_MAX_OVERLAY_WEIGHT 0.25
#define ATAS_MAX_CONTEXT_AGE_SECONDS 180

enum AtasSourceMode
{
   ATAS_SOURCE_MODE_UNKNOWN   = 0,
   ATAS_SOURCE_MODE_LIVE      = 1,
   ATAS_SOURCE_MODE_REPLAY    = 2,
   ATAS_SOURCE_MODE_SYNTHETIC = 3
};

enum AtasQualityState
{
   ATAS_QUALITY_UNKNOWN = 0,
   ATAS_QUALITY_HIGH    = 1,
   ATAS_QUALITY_MEDIUM  = 2,
   ATAS_QUALITY_LOW     = 3
};

enum AtasFreshnessState
{
   ATAS_FRESHNESS_UNKNOWN = 0,
   ATAS_FRESHNESS_FRESH   = 1,
   ATAS_FRESHNESS_STALE   = 2,
   ATAS_FRESHNESS_EXPIRED = 3
};

enum AtasRejectionReason
{
   ATAS_REJECT_NONE                           = 0,
   ATAS_REJECT_SCHEMA_INVALID                 = 1,
   ATAS_REJECT_PACKET_STALE                   = 2,
   ATAS_REJECT_SYMBOL_MISMATCH                = 3,
   ATAS_REJECT_SOURCE_MODE_FORBIDDEN          = 4,
   ATAS_REJECT_QUALITY_TOO_LOW                = 5,
   ATAS_REJECT_FRESHNESS_WINDOW_EXPIRED       = 6,
   ATAS_REJECT_OVERLAY_DISABLED               = 7,
   ATAS_REJECT_BASE_ENVIRONMENT_UNAVAILABLE   = 8,
   ATAS_REJECT_MALFORMED_PAYLOAD              = 9,
   ATAS_REJECT_PACKET_INVALID                 = 10
};

enum AtasConsumptionMode
{
   ATAS_CONSUMPTION_NONE            = 0,
   ATAS_CONSUMPTION_SHADOW_ONLY     = 1,
   ATAS_CONSUMPTION_BOUNDED_CONTEXT = 2
};

struct AtasLevelEvidenceRecord
{
   bool   valid;
   double level_price;
   string level_side_candidate;
   string level_class;
   string level_origin;
   string session_context;
   double absorption_strength;
   bool   sweep_detected;
   bool   reclaim_confirmed;
   double imbalance_ratio;
   string delta_divergence_state;
   string exhaustion_hint;
   int    touch_count_local;
   double reaction_strength;
   double stability_score;
   string fresh_until;
   double invalidation_distance_ticks;
   string candidate_role;
   string market_behavior_tag;
};

struct AtasLevelEvidenceBundle
{
   bool                    valid;
   int                     candidate_count;
   AtasLevelEvidenceRecord candidates[ATAS_MAX_LEVEL_CANDIDATES];
   string                  authority_note;
   string                  summary;
};

struct AtasRuntimePacket
{
   bool               valid;
   string             packet_id;
   string             schema_version;
   string             source_platform;
   AtasSourceMode     source_mode;
   string             source_symbol;
   string             source_symbol_original;
   string             execution_symbol;
   double             source_reference_price;
   double             execution_reference_price;
   bool               cross_instrument_translation_applied;
   double             cross_instrument_basis_value;
   bool               price_anchor_fields_suppressed;
   string             price_space_relation;
   string             event_time;
   string             created_time;
   string             fresh_until;
   string             session_context;
   AtasQualityState   data_quality_state;
   double             packet_confidence;
   int                signal_stability_window_sec;
   bool               replay_flag;
   string             market_state_class;
   string             ingestion_status;
   bool               overlay_enabled;
   AtasConsumptionMode consumption_mode;

   string liquidity_sweep_state;
   string absorption_state;
   string delta_bias_state;
   string imbalance_state;
   string liquidity_stability_state;
   string continuation_exhaustion_hint;

   AtasLevelEvidenceBundle level_evidence;
};

struct AtasMicrostructureOverlay
{
   bool   valid;
   bool   non_authoritative;
   double overlay_weight;
   double overlay_weight_cap;
   string liquidity_sweep_state;
   string absorption_state;
   string delta_bias_state;
   string imbalance_state;
   string liquidity_stability_state;
   string continuation_exhaustion_hint;
   string summary;
};

struct TwinInfluenceTrace
{
   bool   valid;
   string base_environment_source;
   bool   base_environment_valid;
   string atas_consumption_mode;
   double atas_overlay_weight_cap;
   double atas_overlay_weight_applied;
   bool   live_influence_applied;
   bool   live_influence_blocked;
   string rejection_reason;
   string trace_note;
};

string AtasSourceModeToText(AtasSourceMode mode)
{
   if(mode == ATAS_SOURCE_MODE_LIVE) return "LIVE";
   if(mode == ATAS_SOURCE_MODE_REPLAY) return "REPLAY";
   if(mode == ATAS_SOURCE_MODE_SYNTHETIC) return "SYNTHETIC";
   return "UNKNOWN";
}

AtasSourceMode AtasSourceModeFromText(string value)
{
   value = TrimString(value);
   StringToUpper(value);
   if(value == "LIVE") return ATAS_SOURCE_MODE_LIVE;
   if(value == "REPLAY") return ATAS_SOURCE_MODE_REPLAY;
   if(value == "SYNTHETIC") return ATAS_SOURCE_MODE_SYNTHETIC;
   return ATAS_SOURCE_MODE_UNKNOWN;
}

string AtasQualityStateToText(AtasQualityState state)
{
   if(state == ATAS_QUALITY_HIGH) return "HIGH";
   if(state == ATAS_QUALITY_MEDIUM) return "MEDIUM";
   if(state == ATAS_QUALITY_LOW) return "LOW";
   return "UNKNOWN";
}

AtasQualityState AtasQualityStateFromText(string value)
{
   value = TrimString(value);
   StringToUpper(value);
   if(value == "HIGH" || value == "OK") return ATAS_QUALITY_HIGH;
   if(value == "MEDIUM") return ATAS_QUALITY_MEDIUM;
   if(value == "LOW") return ATAS_QUALITY_LOW;
   return ATAS_QUALITY_UNKNOWN;
}

string AtasFreshnessStateToText(AtasFreshnessState state)
{
   if(state == ATAS_FRESHNESS_FRESH) return "FRESH";
   if(state == ATAS_FRESHNESS_STALE) return "STALE";
   if(state == ATAS_FRESHNESS_EXPIRED) return "EXPIRED";
   return "UNKNOWN";
}

string AtasRejectionReasonToText(AtasRejectionReason reason)
{
   if(reason == ATAS_REJECT_SCHEMA_INVALID) return "SCHEMA_INVALID";
   if(reason == ATAS_REJECT_PACKET_STALE) return "PACKET_STALE";
   if(reason == ATAS_REJECT_SYMBOL_MISMATCH) return "SYMBOL_MISMATCH";
   if(reason == ATAS_REJECT_SOURCE_MODE_FORBIDDEN) return "SOURCE_MODE_FORBIDDEN";
   if(reason == ATAS_REJECT_QUALITY_TOO_LOW) return "QUALITY_TOO_LOW";
   if(reason == ATAS_REJECT_FRESHNESS_WINDOW_EXPIRED) return "FRESHNESS_WINDOW_EXPIRED";
   if(reason == ATAS_REJECT_OVERLAY_DISABLED) return "OVERLAY_DISABLED";
   if(reason == ATAS_REJECT_BASE_ENVIRONMENT_UNAVAILABLE) return "BASE_ENVIRONMENT_UNAVAILABLE";
   if(reason == ATAS_REJECT_MALFORMED_PAYLOAD) return "MALFORMED_PAYLOAD";
   if(reason == ATAS_REJECT_PACKET_INVALID) return "PACKET_INVALID";
   return "NONE";
}

string AtasConsumptionModeToText(AtasConsumptionMode mode)
{
   if(mode == ATAS_CONSUMPTION_SHADOW_ONLY) return "SHADOW_ONLY";
   if(mode == ATAS_CONSUMPTION_BOUNDED_CONTEXT) return "BOUNDED_CONTEXT";
   return "NONE";
}

AtasConsumptionMode AtasConsumptionModeFromText(string value)
{
   value = TrimString(value);
   StringToUpper(value);
   if(value == "SHADOW_ONLY") return ATAS_CONSUMPTION_SHADOW_ONLY;
   if(value == "BOUNDED_CONTEXT") return ATAS_CONSUMPTION_BOUNDED_CONTEXT;
   return ATAS_CONSUMPTION_NONE;
}

void InitAtasLevelEvidenceRecord(AtasLevelEvidenceRecord &r)
{
   r.valid = false;
   r.level_price = 0.0;
   r.level_side_candidate = "";
   r.level_class = "";
   r.level_origin = "";
   r.session_context = "";
   r.absorption_strength = 0.0;
   r.sweep_detected = false;
   r.reclaim_confirmed = false;
   r.imbalance_ratio = 0.0;
   r.delta_divergence_state = "";
   r.exhaustion_hint = "";
   r.touch_count_local = 0;
   r.reaction_strength = 0.0;
   r.stability_score = 0.0;
   r.fresh_until = "";
   r.invalidation_distance_ticks = 0.0;
   r.candidate_role = "";
   r.market_behavior_tag = "";
}

void InitAtasLevelEvidenceBundle(AtasLevelEvidenceBundle &b)
{
   b.valid = false;
   b.candidate_count = 0;
   for(int i = 0; i < ATAS_MAX_LEVEL_CANDIDATES; i++)
      InitAtasLevelEvidenceRecord(b.candidates[i]);
   b.authority_note = "ATAS level evidence is non-canonical and shadow-only in Phase 0.";
   b.summary = "NO_LEVEL_EVIDENCE";
}

void InitAtasRuntimePacket(AtasRuntimePacket &p)
{
   p.valid = false;
   p.packet_id = "";
   p.schema_version = "";
   p.source_platform = "ATAS";
   p.source_mode = ATAS_SOURCE_MODE_UNKNOWN;
   p.source_symbol = "";
   p.source_symbol_original = "";
   p.execution_symbol = "";
   p.source_reference_price = 0.0;
   p.execution_reference_price = 0.0;
   p.cross_instrument_translation_applied = false;
   p.cross_instrument_basis_value = 0.0;
   p.price_anchor_fields_suppressed = false;
   p.price_space_relation = "";
   p.event_time = "";
   p.created_time = "";
   p.fresh_until = "";
   p.session_context = "";
   p.data_quality_state = ATAS_QUALITY_UNKNOWN;
   p.packet_confidence = 0.0;
   p.signal_stability_window_sec = 0;
   p.replay_flag = false;
   p.market_state_class = "";
   p.ingestion_status = "";
   p.overlay_enabled = true;
   p.consumption_mode = ATAS_CONSUMPTION_SHADOW_ONLY;

   p.liquidity_sweep_state = "";
   p.absorption_state = "";
   p.delta_bias_state = "";
   p.imbalance_state = "";
   p.liquidity_stability_state = "";
   p.continuation_exhaustion_hint = "";

   InitAtasLevelEvidenceBundle(p.level_evidence);
}

void InitAtasMicrostructureOverlay(AtasMicrostructureOverlay &o)
{
   o.valid = false;
   o.non_authoritative = true;
   o.overlay_weight = 0.0;
   o.overlay_weight_cap = ATAS_MAX_OVERLAY_WEIGHT;
   o.liquidity_sweep_state = "";
   o.absorption_state = "";
   o.delta_bias_state = "";
   o.imbalance_state = "";
   o.liquidity_stability_state = "";
   o.continuation_exhaustion_hint = "";
   o.summary = "ATAS_SHADOW_UNAVAILABLE";
}

void InitTwinInfluenceTrace(TwinInfluenceTrace &t)
{
   t.valid = false;
   t.base_environment_source = "MT5_RUNTIME_ENVIRONMENT";
   t.base_environment_valid = false;
   t.atas_consumption_mode = AtasConsumptionModeToText(ATAS_CONSUMPTION_SHADOW_ONLY);
   t.atas_overlay_weight_cap = ATAS_MAX_OVERLAY_WEIGHT;
   t.atas_overlay_weight_applied = 0.0;
   t.live_influence_applied = false;
   t.live_influence_blocked = true;
   t.rejection_reason = "";
   t.trace_note = "Phase 0 shadow-only trace.";
}

#endif
