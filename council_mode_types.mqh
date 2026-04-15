#ifndef __COUNCIL_MODE_TYPES_MQH__
#define __COUNCIL_MODE_TYPES_MQH__

#include "config_loader.mqh"
#include "atas_runtime_contract.mqh"

//---------------------------------------------------------
// Council constants
//---------------------------------------------------------
#define COUNCIL_MAX_STRATEGIES  17
#define COUNCIL_TEXT_SMALL      64
#define COUNCIL_TEXT_MEDIUM     128
#define COUNCIL_TEXT_LARGE      256
#define COUNCIL_TEXT_XL         512

//---------------------------------------------------------
// Council decisions
//---------------------------------------------------------
enum CouncilDecision
{
   COUNCIL_DECISION_WAIT   = 0,
   COUNCIL_DECISION_BUY    = 1,
   COUNCIL_DECISION_SELL   = -1,
   COUNCIL_DECISION_REJECT = 2
};

//---------------------------------------------------------
// Council zone classification
//---------------------------------------------------------
enum CouncilZoneType
{
   COUNCIL_ZONE_UNDEFINED             = 0,
   COUNCIL_ZONE_NO_TRADE              = 1,
   COUNCIL_ZONE_TREND_CONTINUATION    = 2,
   COUNCIL_ZONE_REVERSAL_EXHAUSTION   = 3,
   COUNCIL_ZONE_RANGE_MEAN_RECLAIM    = 4,
   COUNCIL_ZONE_BREAKOUT_EXPANSION    = 5,

   // Architectural sub-zones (not required to be emitted by env builder yet)
   COUNCIL_ZONE_COMPRESSION           = 6,
   COUNCIL_ZONE_EXPANSION_CONTINUATION= 7,
   COUNCIL_ZONE_RANGE_BALANCED        = 8,
   COUNCIL_ZONE_RANGE_DIRTY           = 9
};

//---------------------------------------------------------
// Council style preference
//---------------------------------------------------------
enum CouncilStyleType
{
   COUNCIL_STYLE_UNSPECIFIED = 0,
   COUNCIL_STYLE_CONTINUATION,
   COUNCIL_STYLE_REVERSAL,
   COUNCIL_STYLE_MEAN_RECLAIM,
   COUNCIL_STYLE_BREAKOUT,
   COUNCIL_STYLE_DEFENSIVE
};

//---------------------------------------------------------
// Strategy role inside council
//---------------------------------------------------------
enum CouncilStrategyRole
{
   COUNCIL_ROLE_UNASSIGNED = 0,
   COUNCIL_ROLE_SCOUT,
   COUNCIL_ROLE_CONFIRM,
   COUNCIL_ROLE_TREND_JUDGE,
   COUNCIL_ROLE_EXHAUSTION_JUDGE,
   COUNCIL_ROLE_GUARD
};

//---------------------------------------------------------
// Strategy routing / eligibility state
//---------------------------------------------------------
enum CouncilEligibilityState
{
   COUNCIL_ELIGIBILITY_UNSET = 0,
   COUNCIL_ELIGIBILITY_ACTIVE,
   COUNCIL_ELIGIBILITY_REDUCED,
   COUNCIL_ELIGIBILITY_OBSERVE_ONLY,
   COUNCIL_ELIGIBILITY_BLOCKED
};

//---------------------------------------------------------
// Aggregate consensus classification
//---------------------------------------------------------
enum CouncilConsensusType
{
   COUNCIL_CONSENSUS_NONE = 0,
   COUNCIL_CONSENSUS_NARROW,
   COUNCIL_CONSENSUS_DIVERSE,
   COUNCIL_CONSENSUS_HIGH_CONVICTION
};

//---------------------------------------------------------
// Governor operating state
//---------------------------------------------------------
enum CouncilGovernorOperatingState
{
   COUNCIL_GOV_STATE_UNSET = 0,
   COUNCIL_GOV_STATE_NORMAL,
   COUNCIL_GOV_STATE_DEFENSIVE,
   COUNCIL_GOV_STATE_AGGRESSIVE,
   COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE
};

//---------------------------------------------------------
// Failure detector pressure classification
//---------------------------------------------------------
enum CouncilFailurePressureLevel
{
   COUNCIL_FAILURE_PRESSURE_NONE = 0,
   COUNCIL_FAILURE_PRESSURE_LOW,
   COUNCIL_FAILURE_PRESSURE_MEDIUM,
   COUNCIL_FAILURE_PRESSURE_HIGH,
   COUNCIL_FAILURE_PRESSURE_CRITICAL
};

//---------------------------------------------------------
// Council environment layer report
//---------------------------------------------------------
struct CouncilEnvironmentReport
{
   bool   valid;
   bool   tradable;

   bool   liquidity_ok;
   bool   spread_ok;
   bool   momentum_ok;
   bool   volatility_ok;
   bool   structure_ok;
   bool   sweep_context_ok;
   bool   session_ok;

   double liquidity_score;     // 0..1
   double spread_score;        // 0..1
   double momentum_score;      // 0..1
   double volatility_score;    // 0..1
   double structure_score;     // 0..1
   double sweep_context_score; // 0..1
   double session_score;       // 0..1

   double total_score;         // 0..1

   // Phase 1 additions
   CouncilZoneType  zone_type;
   double           zone_confidence;      // 0..1
   CouncilStyleType preferred_style;
   CouncilStyleType blocked_style;

   bool   exhaustion_hint;
   bool   continuation_bias;
   bool   reversal_bias;

   string zone_name;
   string preferred_style_text;
   string blocked_style_text;

   string regime_summary;
   string summary;
   string reject_reason;

   // Phase 0: ATAS external shadow attachment (non-authoritative, non-consumed)
   bool   atas_available;
   bool   atas_shadow_attached;
   bool   atas_quality_ok;
   bool   atas_fresh;
   string atas_acceptance_state;
   string atas_rejection_reason;
   string atas_consumption_mode;
   string atas_summary;

   AtasMicrostructureOverlay atas_shadow_overlay;
   AtasLevelEvidenceBundle   atas_level_evidence_shadow;
   TwinInfluenceTrace        atas_trace;

   // Level 3: governed ATAS advisory (descriptive only; non-authoritative)
   bool   atas_advisory_available;
   bool   atas_advisory_eligible;
   string atas_advisory_state;
   string atas_advisory_outcome;
   double atas_advisory_relevance_score;
   bool   atas_advisory_contradiction;
   bool   atas_advisory_hold_bias_active;
   string atas_advisory_level_confluence_state;
   string atas_advisory_summary;
   string atas_canonical_level_context_summary;
   string atas_advisory_attachment_state;
   string atas_advisory_ineligibility_reason_code;
   string atas_advisory_gate_reason_code;
   string atas_advisory_block_class;
   string atas_advisory_usage_state;
   string atas_advisory_zero_effect_reason;

   double atas_nearest_support_price;
   double atas_nearest_resistance_price;
   int    atas_nearest_support_distance_points;
   int    atas_nearest_resistance_distance_points;
   string atas_level_interaction_type;
   bool   atas_level_context_supported;
   bool   atas_level_context_obstructed;
   bool   atas_level_context_degraded;
   string atas_sr_observation_source;
};

//---------------------------------------------------------
// Per-strategy report inside council
//---------------------------------------------------------
struct CouncilStrategyReport
{
   bool   enabled;
   bool   valid;

   string strategy_id;
   string strategy_name;
   string strategy_family;
   string direction_bias;

   CouncilDecision decision;

   double confidence;           // 0..1
   double trigger_quality;      // 0..1
   double confirmation_quality; // 0..1
   double environment_fit;      // 0..1
   double conflict_score;       // 0..1
   double score_final;          // 0..1
   double vote_weight;          // >= 0

   bool   trigger_present;
   bool   blocked_by_filter;
   bool   counter_trend;

   // Phase 1 additions
   CouncilStrategyRole     role;
   CouncilEligibilityState eligibility_state;

   double zone_alignment_score; // 0..1
   double priority_score;       // 0..1

   bool   eligible_for_zone;
   bool   observe_only;
   bool   blocked_by_zone;

   string role_name;
   string eligibility_text;
   string zone_name;
   string zone_block_reason;

   string explanation;
   string short_reason;
};

//---------------------------------------------------------
// Aggregated council result before pre-AI gate
//---------------------------------------------------------
struct CouncilAggregateReport
{
   bool   valid;

   int    active_strategies;
   int    buy_votes;
   int    sell_votes;
   int    neutral_votes;

   double total_buy_weight;
   double total_sell_weight;
   double total_neutral_weight;

   double consensus_strength;   // 0..1
   double conflict_score;       // 0..1
   double environment_score;    // 0..1
   double council_quality;      // 0..1

   // Phase 1 additions
   CouncilConsensusType consensus_type;
   double family_diversity_score; // 0..1
   double zone_alignment_score;   // 0..1

   bool   confirm_role_present;
   bool   trend_judge_supportive;
   bool   exhaustion_warning;

   string consensus_label;

   string dominant_side;        // BUY / SELL / NONE
   string best_strategy_id;
   string support_strategy_ids;
   string summary;
};

//---------------------------------------------------------
// Pre-AI filter result
//---------------------------------------------------------
struct CouncilPreAIGateReport
{
   bool   valid;
   bool   passed;

   CouncilDecision filtered_decision;

   double min_required_consensus;
   double max_allowed_conflict;
   double min_required_environment_score;
   double min_required_council_quality;

   string reason;
   string summary;
};

//---------------------------------------------------------
// Failure pattern detector report
//---------------------------------------------------------
struct CouncilFailurePatternReport
{
   bool   valid;

   CouncilFailurePressureLevel pressure_level;
   string pressure_label;

   string dominant_failure_tag;
   string dominant_setup_type;

   double recent_failure_pressure;     // 0..1
   double continuation_risk_score;     // 0..1
   double reversal_risk_score;         // 0..1
   double mean_reclaim_risk_score;     // 0..1
   double breakout_risk_score;         // 0..1
   double confirm_gap_risk_score;      // 0..1
   double exhaustion_ignore_risk_score;// 0..1
   double conflict_risk_score;         // 0..1
   double zone_mismatch_risk_score;    // 0..1
   double low_quality_risk_score;      // 0..1

   bool   continuation_fragile;
   bool   reversal_fragile;
   bool   confirmation_gap_detected;
   bool   exhaustion_risk_detected;
   bool   zone_mismatch_detected;
   bool   low_quality_cluster_detected;

   string recommended_state;
   string recommendation_summary;
   string summary;
};

//---------------------------------------------------------
// Final council runtime result
//---------------------------------------------------------

//---------------------------------------------------------
// Phase 8A: Council Attribution + Strategy Responsibility
//---------------------------------------------------------
enum CouncilStrategyAlignment
{
   COUNCIL_ALIGN_UNKNOWN = 0,
   COUNCIL_ALIGN_ALIGNED,
   COUNCIL_ALIGN_OPPOSING,
   COUNCIL_ALIGN_NEUTRAL
};

struct CouncilStrategyAttribution
{
   bool   valid;

   string strategy_id;
   string strategy_family;

   string strategy_role;          // PRIMARY / SECONDARY / ADVISORY / UNKNOWN
   string strategy_eligibility_state; // ELIGIBLE / SUPPRESSED / OBSERVE_ONLY / UNKNOWN

   string strategy_direction;     // BUY / SELL / WAIT / REJECT
   string alignment;              // ALIGNED / OPPOSING / NEUTRAL / UNKNOWN

   double vote_strength;          // best-effort (0..1 scaled)
   double confidence;             // 0..1 if available

   string short_reason;           // short summary
   string regime_context;         // optional
};

struct CouncilDecisionAttribution
{
   bool   available;

   string dominant_strategy_id;
   string dominant_strategy_role;
   string dominant_strategy_eligibility_state;

   int    aligned_count;
   int    opposing_count;
   int    neutral_count;

   double consensus_strength;     // 0..1
   double conflict_score;         // 0..1
   double attribution_confidence; // 0..1

   string aligned_strategy_ids;   // CSV
   string opposing_strategy_ids;  // CSV
   string neutral_strategy_ids;   // CSV

   // Compact encoding v2 (8B): "id|dir|align|role|elig|w|c|r;..."
   // Backward compatible: parsers should tolerate missing role/elig.
   string strategies_compact;

   string attribution_summary;
};


//---------------------------------------------------------
// Zone coverage awareness (passive intelligence layer)
//---------------------------------------------------------
struct ZoneCoverageReport
{
   string zone_semantic;

   int    total_strategies;
   int    active_strategies;

   int    aligned_count;
   int    opposing_count;
   int    neutral_count;

   double diversity_score;
   double concentration_score;

   string dominant_family;
   string dominant_strategy;

   bool   has_conflict;
   bool   weak_coverage;
   bool   over_crowded;

   string coverage_label;   // NO_COVERAGE / WEAK / OVERCROWDED / CONFLICTED / STRONG_DIVERSE / BALANCED
   string coverage_reason;
};


void InitCouncilStrategyAttribution(CouncilStrategyAttribution &a)
{
   a.valid = false;
   a.strategy_id = "";
   a.strategy_family = "";
   a.strategy_role = "UNKNOWN_ROLE";
   a.strategy_eligibility_state = "ELIGIBLE_UNKNOWN";
   a.strategy_direction = "WAIT";
   a.alignment = "UNKNOWN";
   a.vote_strength = 0.0;
   a.confidence = 0.0;
   a.short_reason = "";
   a.regime_context = "";
}

void InitCouncilDecisionAttribution(CouncilDecisionAttribution &a)
{
   a.available = false;

   a.dominant_strategy_id = "";
   a.dominant_strategy_role = "UNKNOWN_ROLE";
   a.dominant_strategy_eligibility_state = "ELIGIBLE_UNKNOWN";

   a.aligned_count = 0;
   a.opposing_count = 0;
   a.neutral_count = 0;

   a.consensus_strength = 0.0;
   a.conflict_score = 0.0;
   a.attribution_confidence = 0.0;

   a.aligned_strategy_ids = "";
   a.opposing_strategy_ids = "";
   a.neutral_strategy_ids = "";

   a.strategies_compact = "";
   a.attribution_summary = "";
}


struct CouncilRuntimeResult
{
   bool   valid;

   CouncilDecision final_decision;

   CouncilEnvironmentReport    env;
   CouncilAggregateReport      aggregate;
   CouncilPreAIGateReport      pre_ai_gate;
   CouncilFailurePatternReport failure_detector;

   CouncilDecisionAttribution attribution;

   ZoneCoverageReport zone_coverage;

   string summary;
   string detailed_reason;
};

//---------------------------------------------------------
// Feedback snapshot for council mode
//---------------------------------------------------------
struct CouncilFeedbackRecord
{
   string symbol;
   string plan_id;
   string mode_name;


   string record_type;
   string final_decision;
   string executed_direction;
   string trade_result;

   
   // Close correlation + dedup fields (Phase 3)
   string decision_id;
   string correlated_decision_id;
   ulong  position_id;
   ulong  close_deal_id;
   string correlation_method;
   double correlation_quality;

double profit;
   double environment_score;
   double council_quality;
   double consensus_strength;
   double conflict_score;

   // Phase 1 additions
   string zone_name;
   double zone_confidence;
   string preferred_style;
   string governor_state;
   string consensus_label;

   string best_strategy_id;
   string support_strategy_ids;
   string regime_summary;
   string explanation;

   // Memory intelligence additions
   string failure_tag;            // e.g. LATE_CONTINUATION_FAILURE
   string quality_band;           // HIGH / MEDIUM / LOW
   string setup_type;             // REVERSAL / CONTINUATION / MEAN_RECLAIM / BREAKOUT
   bool   confirm_role_present;
   bool   trend_judge_supportive;
   bool   exhaustion_warning;

   datetime close_time;
};

//---------------------------------------------------------
// Governor operating snapshot
//---------------------------------------------------------
struct CouncilGovernorStateReport
{
   bool valid;

   CouncilGovernorOperatingState operating_state;
   string operating_state_text;

   bool tighten_entry;
   bool prefer_reversal;
   bool prefer_continuation;
   bool defensive_bias;

   string reason;
   string summary;
};

//---------------------------------------------------------
// Memory / policy adjustment suggestions for council governor
//---------------------------------------------------------
struct CouncilPolicyAdjustment
{
   bool   valid;

   bool   change_strategy_enablement;
   bool   change_vote_weights;
   bool   change_pre_ai_thresholds;
   bool   suggest_mode_exit;

   // Phase 1 additions
   bool   change_operating_state;
   CouncilGovernorOperatingState target_operating_state;
   string target_operating_state_text;

   string target_strategy_id;
   string adjustment_reason;
   string summary;

   double new_vote_weight;
   double new_min_consensus;
   double new_max_conflict;
   double new_min_environment_score;
   double new_min_council_quality;
};

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
string CouncilDecisionToText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)
      return "BUY";

   if(d == COUNCIL_DECISION_SELL)
      return "SELL";

   if(d == COUNCIL_DECISION_REJECT)
      return "REJECT";

   return "WAIT";
}

CouncilDecision CouncilDecisionFromDirectionText(string s)
{
   s = TrimString(s);

   if(s == "BUY")
      return COUNCIL_DECISION_BUY;

   if(s == "SELL")
      return COUNCIL_DECISION_SELL;

   if(s == "REJECT")
      return COUNCIL_DECISION_REJECT;

   return COUNCIL_DECISION_WAIT;
}

string CouncilZoneTypeToText(CouncilZoneType z)
{
   if(z == COUNCIL_ZONE_NO_TRADE)
      return "NO_TRADE";

   if(z == COUNCIL_ZONE_TREND_CONTINUATION)
      return "TREND_CONTINUATION";

   if(z == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
      return "REVERSAL_EXHAUSTION";

   if(z == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)
      return "RANGE_MEAN_RECLAIM";

   if(z == COUNCIL_ZONE_BREAKOUT_EXPANSION)
      return "BREAKOUT_EXPANSION";

   return "UNDEFINED";
}

string CouncilStyleTypeToText(CouncilStyleType s)
{
   if(s == COUNCIL_STYLE_CONTINUATION)
      return "CONTINUATION";

   if(s == COUNCIL_STYLE_REVERSAL)
      return "REVERSAL";

   if(s == COUNCIL_STYLE_MEAN_RECLAIM)
      return "MEAN_RECLAIM";

   if(s == COUNCIL_STYLE_BREAKOUT)
      return "BREAKOUT";

   if(s == COUNCIL_STYLE_DEFENSIVE)
      return "DEFENSIVE";

   return "UNSPECIFIED";
}

string CouncilStrategyRoleToText(CouncilStrategyRole r)
{
   if(r == COUNCIL_ROLE_SCOUT)
      return "SCOUT";

   if(r == COUNCIL_ROLE_CONFIRM)
      return "CONFIRM";

   if(r == COUNCIL_ROLE_TREND_JUDGE)
      return "TREND_JUDGE";

   if(r == COUNCIL_ROLE_EXHAUSTION_JUDGE)
      return "EXHAUSTION_JUDGE";

   if(r == COUNCIL_ROLE_GUARD)
      return "GUARD";

   return "UNASSIGNED";
}

string CouncilEligibilityStateToText(CouncilEligibilityState s)
{
   if(s == COUNCIL_ELIGIBILITY_ACTIVE)
      return "ACTIVE";

   if(s == COUNCIL_ELIGIBILITY_REDUCED)
      return "REDUCED";

   if(s == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      return "OBSERVE_ONLY";

   if(s == COUNCIL_ELIGIBILITY_BLOCKED)
      return "BLOCKED";

   return "UNSET";
}

string CouncilConsensusTypeToText(CouncilConsensusType t)
{
   if(t == COUNCIL_CONSENSUS_NARROW)
      return "NARROW";

   if(t == COUNCIL_CONSENSUS_DIVERSE)
      return "DIVERSE";

   if(t == COUNCIL_CONSENSUS_HIGH_CONVICTION)
      return "HIGH_CONVICTION";

   return "NONE";
}

string CouncilGovernorOperatingStateToText(CouncilGovernorOperatingState s)
{
   if(s == COUNCIL_GOV_STATE_NORMAL)
      return "NORMAL";

   if(s == COUNCIL_GOV_STATE_DEFENSIVE)
      return "DEFENSIVE";

   if(s == COUNCIL_GOV_STATE_AGGRESSIVE)
      return "AGGRESSIVE";

   if(s == COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE)
      return "EXHAUSTION_SENSITIVE";

   return "UNSET";
}

string CouncilFailurePressureLevelToText(CouncilFailurePressureLevel p)
{
   if(p == COUNCIL_FAILURE_PRESSURE_LOW)
      return "LOW";

   if(p == COUNCIL_FAILURE_PRESSURE_MEDIUM)
      return "MEDIUM";

   if(p == COUNCIL_FAILURE_PRESSURE_HIGH)
      return "HIGH";

   if(p == COUNCIL_FAILURE_PRESSURE_CRITICAL)
      return "CRITICAL";

   return "NONE";
}

void InitCouncilEnvironmentReport(CouncilEnvironmentReport &r)
{
   r.valid                = false;
   r.tradable             = false;

   r.liquidity_ok         = false;
   r.spread_ok            = false;
   r.momentum_ok          = false;
   r.volatility_ok        = false;
   r.structure_ok         = false;
   r.sweep_context_ok     = false;
   r.session_ok           = false;

   r.liquidity_score      = 0.0;
   r.spread_score         = 0.0;
   r.momentum_score       = 0.0;
   r.volatility_score     = 0.0;
   r.structure_score      = 0.0;
   r.sweep_context_score  = 0.0;
   r.session_score        = 0.0;

   r.total_score          = 0.0;

   r.zone_type            = COUNCIL_ZONE_UNDEFINED;
   r.zone_confidence      = 0.0;
   r.preferred_style      = COUNCIL_STYLE_UNSPECIFIED;
   r.blocked_style        = COUNCIL_STYLE_UNSPECIFIED;

   r.exhaustion_hint      = false;
   r.continuation_bias    = false;
   r.reversal_bias        = false;

   r.zone_name            = "UNDEFINED";
   r.preferred_style_text = "UNSPECIFIED";
   r.blocked_style_text   = "UNSPECIFIED";

   r.regime_summary       = "";
   r.summary              = "";
   r.reject_reason        = "";

   r.atas_available       = false;
   r.atas_shadow_attached = false;
   r.atas_quality_ok      = false;
   r.atas_fresh           = false;
   r.atas_acceptance_state = "SHADOW_NOT_ATTACHED";
   r.atas_rejection_reason = "NONE";
   r.atas_consumption_mode = AtasConsumptionModeToText(ATAS_CONSUMPTION_SHADOW_ONLY);
   r.atas_summary          = "ATAS shadow attachment not evaluated.";

   InitAtasMicrostructureOverlay(r.atas_shadow_overlay);
   InitAtasLevelEvidenceBundle(r.atas_level_evidence_shadow);
   InitTwinInfluenceTrace(r.atas_trace);

   r.atas_advisory_available = false;
   r.atas_advisory_eligible = false;
   r.atas_advisory_state = "ATAS_ADVISORY_UNSET";
   r.atas_advisory_outcome = "IGNORE_ADVISORY";
   r.atas_advisory_relevance_score = 0.0;
   r.atas_advisory_contradiction = false;
   r.atas_advisory_hold_bias_active = false;
   r.atas_advisory_level_confluence_state = "UNSET";
   r.atas_advisory_summary = "ATAS governed advisory not evaluated.";
   r.atas_canonical_level_context_summary = "UNSET";
   r.atas_advisory_attachment_state = "ADVISORY_NOT_EVALUATED";
   r.atas_advisory_ineligibility_reason_code = "NOT_EVALUATED";
   r.atas_advisory_gate_reason_code = "not_evaluated";
   r.atas_advisory_block_class = "NOT_EVALUATED";
   r.atas_advisory_usage_state = "ADVISORY_NOT_EVALUATED";
   r.atas_advisory_zero_effect_reason = "NOT_EVALUATED";

   r.atas_nearest_support_price = 0.0;
   r.atas_nearest_resistance_price = 0.0;
   r.atas_nearest_support_distance_points = -1;
   r.atas_nearest_resistance_distance_points = -1;
   r.atas_level_interaction_type = "LEVEL_CONTEXT_UNSET";
   r.atas_level_context_supported = false;
   r.atas_level_context_obstructed = false;
   r.atas_level_context_degraded = false;
   r.atas_sr_observation_source = "UNAVAILABLE_NOT_CAPTURED";
}

void InitCouncilStrategyReport(CouncilStrategyReport &r)
{
   r.enabled              = true;
   r.valid                = false;

   r.strategy_id          = "";
   r.strategy_name        = "";
   r.strategy_family      = "";
   r.direction_bias       = "";

   r.decision             = COUNCIL_DECISION_WAIT;

   r.confidence           = 0.0;
   r.trigger_quality      = 0.0;
   r.confirmation_quality = 0.0;
   r.environment_fit      = 0.0;
   r.conflict_score       = 0.0;
   r.score_final          = 0.0;
   r.vote_weight          = 0.0;

   r.trigger_present      = false;
   r.blocked_by_filter    = false;
   r.counter_trend        = false;

   r.role                 = COUNCIL_ROLE_UNASSIGNED;
   r.eligibility_state    = COUNCIL_ELIGIBILITY_UNSET;

   r.zone_alignment_score = 0.0;
   r.priority_score       = 0.0;

   r.eligible_for_zone    = false;
   r.observe_only         = false;
   r.blocked_by_zone      = false;

   r.role_name            = "UNASSIGNED";
   r.eligibility_text     = "UNSET";
   r.zone_name            = "";
   r.zone_block_reason    = "";

   r.explanation          = "";
   r.short_reason         = "";
}

void InitCouncilAggregateReport(CouncilAggregateReport &r)
{
   r.valid                  = false;

   r.active_strategies      = 0;
   r.buy_votes              = 0;
   r.sell_votes             = 0;
   r.neutral_votes          = 0;

   r.total_buy_weight       = 0.0;
   r.total_sell_weight      = 0.0;
   r.total_neutral_weight   = 0.0;

   r.consensus_strength     = 0.0;
   r.conflict_score         = 0.0;
   r.environment_score      = 0.0;
   r.council_quality        = 0.0;

   r.consensus_type         = COUNCIL_CONSENSUS_NONE;
   r.family_diversity_score = 0.0;
   r.zone_alignment_score   = 0.0;

   r.confirm_role_present   = false;
   r.trend_judge_supportive = false;
   r.exhaustion_warning     = false;

   r.consensus_label        = "NONE";

   r.dominant_side          = "NONE";
   r.best_strategy_id       = "";
   r.support_strategy_ids   = "";
   r.summary                = "";
}

void InitCouncilPreAIGateReport(CouncilPreAIGateReport &r)
{
   r.valid                          = false;
   r.passed                         = false;

   r.filtered_decision              = COUNCIL_DECISION_WAIT;

   r.min_required_consensus         = 0.0;
   r.max_allowed_conflict           = 1.0;
   r.min_required_environment_score = 0.0;
   r.min_required_council_quality   = 0.0;

   r.reason                         = "";
   r.summary                        = "";
}

void InitCouncilFailurePatternReport(CouncilFailurePatternReport &r)
{
   r.valid                        = false;

   r.pressure_level               = COUNCIL_FAILURE_PRESSURE_NONE;
   r.pressure_label               = "NONE";

   r.dominant_failure_tag         = "";
   r.dominant_setup_type          = "";

   r.recent_failure_pressure      = 0.0;
   r.continuation_risk_score      = 0.0;
   r.reversal_risk_score          = 0.0;
   r.mean_reclaim_risk_score      = 0.0;
   r.breakout_risk_score          = 0.0;
   r.confirm_gap_risk_score       = 0.0;
   r.exhaustion_ignore_risk_score = 0.0;
   r.conflict_risk_score          = 0.0;
   r.zone_mismatch_risk_score     = 0.0;
   r.low_quality_risk_score       = 0.0;

   r.continuation_fragile         = false;
   r.reversal_fragile             = false;
   r.confirmation_gap_detected    = false;
   r.exhaustion_risk_detected     = false;
   r.zone_mismatch_detected       = false;
   r.low_quality_cluster_detected = false;

   r.recommended_state            = "NORMAL";
   r.recommendation_summary       = "";
   r.summary                      = "";
}

void InitCouncilRuntimeResult(CouncilRuntimeResult &r)
{
   r.valid            = false;
   r.final_decision   = COUNCIL_DECISION_WAIT;

   InitCouncilEnvironmentReport(r.env);
   InitCouncilAggregateReport(r.aggregate);
   InitCouncilPreAIGateReport(r.pre_ai_gate);
   InitCouncilFailurePatternReport(r.failure_detector);
   InitCouncilDecisionAttribution(r.attribution);

   r.summary          = "";
   r.detailed_reason  = "";
}

void InitCouncilFeedbackRecord(CouncilFeedbackRecord &r)
{
   r.symbol                 = "";
   r.plan_id                = "";
   r.mode_name              = "COUNCIL";


   r.record_type           = "";
   r.final_decision         = "";
   r.executed_direction     = "";
   r.trade_result           = "";

   
   r.decision_id            = "";
   r.correlated_decision_id = "";
   r.position_id            = 0;
   r.close_deal_id           = 0;
   r.correlation_method     = "";
   r.correlation_quality    = 0.0;

r.profit                 = 0.0;
   r.environment_score      = 0.0;
   r.council_quality        = 0.0;
   r.consensus_strength     = 0.0;
   r.conflict_score         = 0.0;

   r.zone_name              = "";
   r.zone_confidence        = 0.0;
   r.preferred_style        = "";
   r.governor_state         = "";
   r.consensus_label        = "";

   r.best_strategy_id       = "";
   r.support_strategy_ids   = "";
   r.regime_summary         = "";
   r.explanation            = "";

   r.failure_tag            = "";
   r.quality_band           = "";
   r.setup_type             = "";
   r.confirm_role_present   = false;
   r.trend_judge_supportive = false;
   r.exhaustion_warning     = false;

   r.close_time             = 0;
}


string CouncilFeedbackRecordTypeDecisionSnapshot()
{
   return "DECISION_SNAPSHOT";
}

string CouncilFeedbackRecordTypeTradeCloseOutcome()
{
   return "TRADE_CLOSE_OUTCOME";
}

string CouncilFeedbackRecordSemanticsVersion()
{
   return "S4_FEEDBACK_V1";
}

string CouncilFeedbackNormalizeDirectionText(string s)
{
   s = TrimString(s);
   StringToUpper(s);

   if(s == "LONG")
      s = "BUY";
   else if(s == "SHORT")
      s = "SELL";
   else if(s == "UNKNOWN" || s == "NONE" || s == "NULL" || s == "N/A")
      s = "";

   if(s == "BUY" || s == "SELL")
      return s;

   return "";
}

string CouncilFeedbackNormalizeTradeResultText(string s)
{
   s = TrimString(s);
   StringToUpper(s);

   if(s == "PROFIT")
      s = "WIN";
   else if(s == "LOSE")
      s = "LOSS";
   else if(s == "BREAKEVEN" || s == "BREAK_EVEN" || s == "BE")
      s = "FLAT";

   if(s == "WIN" || s == "LOSS" || s == "FLAT" || s == "PENDING" || s == "NOT_EXECUTED")
      return s;

   return "";
}

bool CouncilFeedbackIsDirectionText(string s)
{
   s = CouncilFeedbackNormalizeDirectionText(s);
   return (s == "BUY" || s == "SELL");
}

bool CouncilFeedbackIsTradeOutcomeText(string s)
{
   s = CouncilFeedbackNormalizeTradeResultText(s);
   return (s == "WIN" || s == "LOSS" || s == "FLAT");
}

bool CouncilFeedbackIsKnownRecordType(string s)
{
   s = TrimString(s);
   return (s == CouncilFeedbackRecordTypeDecisionSnapshot()
           || s == CouncilFeedbackRecordTypeTradeCloseOutcome());
}

bool CouncilFeedbackHasTradeCloseEvidence(CouncilFeedbackRecord &r)
{
   if(CouncilFeedbackIsTradeOutcomeText(r.trade_result))
      return true;

   if(r.close_deal_id > 0 || r.position_id > 0)
      return true;

   if(MathAbs(r.profit) > 0.0000001)
      return true;

   return false;
}

void NormalizeCouncilFeedbackRecordSemantics(CouncilFeedbackRecord &r)
{
   if(StringLen(TrimString(r.mode_name)) <= 0)
      r.mode_name = "COUNCIL";

   r.record_type        = TrimString(r.record_type);
   r.final_decision     = TrimString(r.final_decision);
   r.executed_direction = CouncilFeedbackNormalizeDirectionText(r.executed_direction);
   r.trade_result       = CouncilFeedbackNormalizeTradeResultText(r.trade_result);

   if(!CouncilFeedbackIsKnownRecordType(r.record_type))
      r.record_type = "";

   if(StringLen(r.record_type) <= 0)
   {
      if(CouncilFeedbackHasTradeCloseEvidence(r))
         r.record_type = CouncilFeedbackRecordTypeTradeCloseOutcome();
      else
         r.record_type = CouncilFeedbackRecordTypeDecisionSnapshot();
   }

   if(r.record_type == CouncilFeedbackRecordTypeDecisionSnapshot())
   {
      r.executed_direction = "";

      if(r.trade_result != "PENDING" && r.trade_result != "NOT_EXECUTED")
         r.trade_result = "PENDING";

      return;
   }

   if(r.record_type == CouncilFeedbackRecordTypeTradeCloseOutcome())
   {
      if(!CouncilFeedbackIsTradeOutcomeText(r.trade_result))
      {
         if(r.profit > 0.0)
            r.trade_result = "WIN";
         else if(r.profit < 0.0)
            r.trade_result = "LOSS";
         else
            r.trade_result = "FLAT";
      }

      if(!CouncilFeedbackIsDirectionText(r.executed_direction))
      {
         string normalizedFinal = CouncilFeedbackNormalizeDirectionText(r.final_decision);
         if(CouncilFeedbackIsDirectionText(normalizedFinal))
            r.executed_direction = normalizedFinal;
         else
            r.executed_direction = "";
      }

      if(!CouncilFeedbackIsDirectionText(r.final_decision) && CouncilFeedbackIsDirectionText(r.executed_direction))
         r.final_decision = r.executed_direction;

      return;
   }
}


void InitCouncilGovernorStateReport(CouncilGovernorStateReport &r)
{
   r.valid                = false;
   r.operating_state      = COUNCIL_GOV_STATE_UNSET;
   r.operating_state_text = "UNSET";

   r.tighten_entry        = false;
   r.prefer_reversal      = false;
   r.prefer_continuation  = false;
   r.defensive_bias       = false;

   r.reason               = "";
   r.summary              = "";
}

void InitCouncilPolicyAdjustment(CouncilPolicyAdjustment &r)
{
   r.valid                       = false;

   r.change_strategy_enablement  = false;
   r.change_vote_weights         = false;
   r.change_pre_ai_thresholds    = false;
   r.suggest_mode_exit           = false;

   r.change_operating_state      = false;
   r.target_operating_state      = COUNCIL_GOV_STATE_UNSET;
   r.target_operating_state_text = "UNSET";

   r.target_strategy_id          = "";
   r.adjustment_reason           = "";
   r.summary                     = "";

   r.new_vote_weight             = 0.0;
   r.new_min_consensus           = 0.0;
   r.new_max_conflict            = 1.0;
   r.new_min_environment_score   = 0.0;
   r.new_min_council_quality     = 0.0;
}

#endif
