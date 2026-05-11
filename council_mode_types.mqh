#ifndef __COUNCIL_MODE_TYPES_MQH__
#define __COUNCIL_MODE_TYPES_MQH__

#include "config_loader.mqh"
#include "atas_runtime_contract.mqh"

//---------------------------------------------------------
// Council constants
//---------------------------------------------------------
#define COUNCIL_MAX_STRATEGIES  18
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

   // COMPRESSION (6) is actively emitted since PLAN-6 Stage 3.
   // Remaining sub-zones (7-9) are defined but not yet emitted by ClassifyCouncilZone().
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
   COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE,
   COUNCIL_GOV_STATE_CRITICAL_DEFENSIVE    // PLAN-4 Stage 1: highest pressure defensive state
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

   // CEIS Source Signal Layer — multi-horizon sub-signals (evolved from single exhaustion_hint)
   bool   ceis_spike_reversal_m1;   // Preserved: M1 wick-dominant + highVol + highMomentum (= exhaustion_hint)
   bool   ceis_overextension_m5;    // New: M5 EMA20 price distance >= 2.0 * ATR14_M5
   bool   ceis_mfi_exhaustion_m5;   // New: M5 MFI turning from extreme (declining from >55 or rising from <45)
   bool   ceis_mfi_exhaustion_m15;  // New: M15 MFI turning from extreme (same logic, higher stability)
   bool   ceis_mfi_exhaustion_h1;   // New: H1 MFI turning from extreme (>65 or <35, strict — structural context)
   bool   ceis_mfi_context_h4;      // New: H4 MFI at extreme turning (>68 or <32 — macro structural context only)
   bool   ceis_momentum_fade_m5;    // New: M5 ATR14 velocity loss (current < prior-8-bars * 0.78)
   double ceis_source_score;        // Composite 0..1: 7 weighted sub-signals, clamped
   int    ceis_signal_count;        // Count of active sub-signals (0..7)

   string zone_name;
   string preferred_style_text;
   string blocked_style_text;

   string regime_summary;
   string summary;
   string reject_reason;
   string era_label_v1;     // V1 ERA posture from gRegime.regime_label (per-decision, not cached)

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
// V1 constructive eligibility summary (Stage A1)
//---------------------------------------------------------
struct CouncilV1ConstructiveEligibilitySummary
{
   string version;
   bool   active;

   string state_label;
   string policy_posture;
   string native_families;
   string conditional_families;
   string deprioritized_families;
   string informational_families;

   int    eligible_strategy_count;
   int    suppressed_strategy_count;
   int    informational_strategy_count;
   int    unknown_strategy_count;

   bool   score_sovereignty_blocked;
   string score_role;
   bool   score_could_not_admit_suppressed;
   bool   score_could_not_override_state;
   string authority_class;
   string strategy_attributions;
};

//---------------------------------------------------------
// IRREW development consumption identity and audit reports
//---------------------------------------------------------
struct CouncilExecutionAdmissionIdentity
{
   string primary_thesis_strategy_id;
   string execution_admission_family;
   string execution_admission_source;
   string execution_admission_reason;
};

struct CouncilPacketRegistryConsumptionReport
{
   string packet_class;
   string packet_registry_status;
   string packet_identity_state;
};

struct CouncilPlaybookConsumptionReport
{
   string playbook_id;
   string playbook_state;
   bool   playbook_thesis_complete;
};

struct CouncilIRREWDevelopmentActionReport
{
   string thesis_quality_state;

   bool   failure_mode_present;
   string failure_mode_type;
   string failure_packet_id;
   string failure_mode_direction;
   bool   pre_decision_available;
   string failure_mode_action_candidate;

   bool   v1_caution_present;
   bool   risk_warning_present;
   bool   advisory_wait_preference;
   bool   development_wait_requested;

   string baseline_decision_before_irrew_dev;
   string final_decision_after_irrew_dev;
   string irrew_development_wait_reasons_all;
   string primary_development_wait_reason;
   string irrew_dev_flag_that_fired;
   string irrew_schema_version;
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
   bool   two_or_more_dominant_families;
   string best_strategy_id;
   string primary_thesis_strategy_id;
   string execution_admission_family;
   string execution_admission_source;
   string execution_admission_reason;
   string support_strategy_ids;

   bool   v1_fsw_enabled;
   bool   v1_fsw_applied;
   bool   v1_fsw_phase2_active;
   string v1_fsw_version;
   string v1_fsw_authority_class;
   string v1_fsw_action_taken;
   string v1_fsw_state_label;
   string v1_fsw_policy_posture;
   string v1_fsw_native_families;
   string v1_fsw_conditional_families;
   string v1_fsw_deprioritized_families;
   string v1_fsw_bypass_reason;
   int    v1_fsw_influenced_strategy_count;
   int    v1_fsw_mapped_strategy_count;
   int    v1_fsw_nonzero_impact_count;
   int    v1_fsw_native_nonzero_count;
   int    v1_fsw_conditional_nonzero_count;
   int    v1_fsw_deprioritized_nonzero_count;
   double v1_fsw_native_weight_delta;
   double v1_fsw_conditional_weight_delta;
   double v1_fsw_deprioritized_weight_delta;
   double v1_fsw_total_weight_delta;
   string v1_fsw_strategy_attributions;
   string v1_fsw_unknown_family_warning;
   bool   v1_fsw_no_veto;
   bool   v1_fsw_no_final_permission_effect;
   bool   v1_fsw_was_active_at_decision;

   string v1_constructive_policy_version;
   bool   v1_policy_constructive_active;
   string v1_policy_state_label;
   string v1_policy_posture;
   string v1_policy_native_families;
   string v1_policy_conditional_families;
   string v1_policy_deprioritized_families;
   string v1_policy_informational_families;
   int    v1_policy_eligible_strategy_count;
   int    v1_policy_suppressed_strategy_count;
   int    v1_policy_informational_strategy_count;
   int    v1_policy_unknown_strategy_count;
   bool   v1_policy_score_sovereignty_blocked;
   string v1_policy_score_role;
   bool   v1_policy_score_could_not_admit_suppressed;
   bool   v1_policy_score_could_not_override_state;
   string v1_policy_authority_class;
   string v1_policy_strategy_attributions;

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

   bool   c2_overextension_m5_active;
   bool   c2_consensus_tightening_applied;
   double c2_consensus_tightening_delta;
   double c2_pre_consensus_requirement;
   double c2_post_consensus_requirement;
   bool   c2_effective_on_outcome;
   string c2_gate_outcome;

   bool   c3_low_structure_tc_active;
   double c3_structure_score;
   bool   c3_logic_applied;
   bool   c3_effective_on_outcome;
   string c3_gate_outcome;

   // A2 -- score gate demotion observability (SCORE_SOVEREIGNTY_REMOVAL_A2)
   bool   pre_ai_score_gates_demoted;
   double pre_ai_obs_council_quality;
   double pre_ai_obs_consensus_strength;
   double pre_ai_obs_conflict_score;
   bool   pre_ai_would_have_gated_quality;
   bool   pre_ai_would_have_gated_consensus;
   bool   pre_ai_would_have_gated_conflict;

   string structural_reject_gate;
   string structural_reject_gate_detail;
   bool   pre_ai_structural_passed;

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
   bool                        c1_tc_active;
   bool                        c1_high_conviction_active;
   bool                        c1_overextension_active;
   bool                        c1_pre_governor_candidate;
   bool                        c1_shadowed_by_exhaustion;
   string                      c1_shadow_reason;
   CouncilFailurePatternReport failure_detector;
   string                      governor_state;
   string                      governor_state_source;
   bool                        governor_categorical_state_active;
   CouncilExecutionAdmissionIdentity       execution_admission;
   CouncilPacketRegistryConsumptionReport  packet_registry;
   CouncilPlaybookConsumptionReport        playbook_consumption;
   CouncilIRREWDevelopmentActionReport     irrew_development;

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

   bool   c1_tc_active;
   bool   c1_high_conviction_active;
   bool   c1_overextension_active;
   bool   c1_pre_governor_candidate;
   bool   c1_shadowed_by_exhaustion;
   string c1_shadow_reason;

   bool   c2_overextension_m5_active;
   bool   c2_consensus_tightening_applied;
   double c2_consensus_tightening_delta;
   double c2_pre_consensus_requirement;
   double c2_post_consensus_requirement;
   bool   c2_effective_on_outcome;
   string c2_gate_outcome;

   bool   c3_low_structure_tc_active;
   double c3_structure_score;
   bool   c3_logic_applied;
   bool   c3_effective_on_outcome;
   string c3_gate_outcome;

   string c123_obstacle_summary;
   string c123_obstacle_semantics_version;

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

   bool   c1_tc_active;
   bool   c1_high_conviction_active;
   bool   c1_overextension_active;
   bool   c1_pre_governor_candidate;
   bool   c1_shadowed_by_exhaustion;
   string c1_shadow_reason;

   // Policy Layer contract fields — PLAN-4 Stage 1 additions (audit / interpretability)
   string reason_code;               // compact machine-readable driver (e.g. "CRIT_PRESSURE", "EXHAUST_SENSITIVE")
   string source_flags;              // inputs that drove adjustment (e.g. "FAILDET|CEIS|ENV")
   double confidence_of_adjustment;  // 0..1 confidence in this adjustment
   double adjustment_intensity;      // 0..1 normalized intensity of threshold delta from base
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

   if(z == COUNCIL_ZONE_COMPRESSION)
      return "COMPRESSION";

   if(z == COUNCIL_ZONE_EXPANSION_CONTINUATION)
      return "EXPANSION_CONTINUATION";

   if(z == COUNCIL_ZONE_RANGE_BALANCED)
      return "RANGE_BALANCED";

   if(z == COUNCIL_ZONE_RANGE_DIRTY)
      return "RANGE_DIRTY";

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

   if(s == COUNCIL_GOV_STATE_CRITICAL_DEFENSIVE)
      return "CRITICAL_DEFENSIVE";

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

   r.ceis_spike_reversal_m1  = false;
   r.ceis_overextension_m5   = false;
   r.ceis_mfi_exhaustion_m5  = false;
   r.ceis_mfi_exhaustion_m15 = false;
   r.ceis_mfi_exhaustion_h1  = false;
   r.ceis_mfi_context_h4     = false;
   r.ceis_momentum_fade_m5   = false;
   r.ceis_source_score       = 0.0;
   r.ceis_signal_count       = 0;

   r.zone_name            = "UNDEFINED";
   r.preferred_style_text = "UNSPECIFIED";
   r.blocked_style_text   = "UNSPECIFIED";

   r.regime_summary       = "";
   r.summary              = "";
   r.reject_reason        = "";
   r.era_label_v1         = "";

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

void InitCouncilV1ConstructiveEligibilitySummary(CouncilV1ConstructiveEligibilitySummary &r)
{
   r.version = "DISABLED";
   r.active = false;

   r.state_label = "";
   r.policy_posture = "";
   r.native_families = "";
   r.conditional_families = "";
   r.deprioritized_families = "";
   r.informational_families = "";

   r.eligible_strategy_count = 0;
   r.suppressed_strategy_count = 0;
   r.informational_strategy_count = 0;
   r.unknown_strategy_count = 0;

   r.score_sovereignty_blocked = false;
   r.score_role = "PRE_EXISTING_SCORE_AGGREGATION";
   r.score_could_not_admit_suppressed = false;
   r.score_could_not_override_state = false;
   r.authority_class = "V1_CONSTRUCTIVE_ELIGIBILITY_DISABLED";
   r.strategy_attributions = "";
}

void InitCouncilExecutionAdmissionIdentity(CouncilExecutionAdmissionIdentity &r)
{
   r.primary_thesis_strategy_id = "";
   r.execution_admission_family = "";
   r.execution_admission_source = "";
   r.execution_admission_reason = "";
}

void InitCouncilPacketRegistryConsumptionReport(CouncilPacketRegistryConsumptionReport &r)
{
   r.packet_class = "UNKNOWN_PACKET";
   r.packet_registry_status = "UNREGISTERED";
   r.packet_identity_state = "UNKNOWN_PACKET";
}

void InitCouncilPlaybookConsumptionReport(CouncilPlaybookConsumptionReport &r)
{
   r.playbook_id = "";
   r.playbook_state = "PLAYBOOK_NOT_PRESENT";
   r.playbook_thesis_complete = false;
}

void InitCouncilIRREWDevelopmentActionReport(CouncilIRREWDevelopmentActionReport &r)
{
   r.thesis_quality_state = "THESIS_QUALITY_UNCERTAIN";

   r.failure_mode_present = false;
   r.failure_mode_type = "";
   r.failure_packet_id = "";
   r.failure_mode_direction = "";
   r.pre_decision_available = false;
   r.failure_mode_action_candidate = "";

   r.v1_caution_present = false;
   r.risk_warning_present = false;
   r.advisory_wait_preference = false;
   r.development_wait_requested = false;

   r.baseline_decision_before_irrew_dev = "";
   r.final_decision_after_irrew_dev = "";
   r.irrew_development_wait_reasons_all = "";
   r.primary_development_wait_reason = "";
   r.irrew_dev_flag_that_fired = "";
   r.irrew_schema_version = "OL_V1C_IRREW_DEV_V1";
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
   r.two_or_more_dominant_families = false;
   r.best_strategy_id       = "";
   r.primary_thesis_strategy_id = "";
   r.execution_admission_family = "";
   r.execution_admission_source = "";
   r.execution_admission_reason = "";
   r.support_strategy_ids   = "";

   r.v1_fsw_enabled                     = false;
   r.v1_fsw_applied                     = false;
   r.v1_fsw_phase2_active               = false;
   r.v1_fsw_version                     = "V1_FSW_PHASE1";
   r.v1_fsw_authority_class             = "BOUNDED_PARTICIPATION_INFLUENCE_ONLY";
   r.v1_fsw_action_taken                = "DISABLED_NO_ADJUSTMENT";
   r.v1_fsw_state_label                 = "V1_FSW_NOT_EVALUATED";
   r.v1_fsw_policy_posture              = "OBSERVE_ONLY";
   r.v1_fsw_native_families             = "";
   r.v1_fsw_conditional_families        = "";
   r.v1_fsw_deprioritized_families      = "";
   r.v1_fsw_bypass_reason               = "NOT_EVALUATED";
   r.v1_fsw_influenced_strategy_count   = 0;
   r.v1_fsw_mapped_strategy_count       = 0;
   r.v1_fsw_nonzero_impact_count        = 0;
   r.v1_fsw_native_nonzero_count        = 0;
   r.v1_fsw_conditional_nonzero_count   = 0;
   r.v1_fsw_deprioritized_nonzero_count = 0;
   r.v1_fsw_native_weight_delta         = 0.0;
   r.v1_fsw_conditional_weight_delta    = 0.0;
   r.v1_fsw_deprioritized_weight_delta  = 0.0;
   r.v1_fsw_total_weight_delta          = 0.0;
   r.v1_fsw_strategy_attributions       = "";
   r.v1_fsw_unknown_family_warning      = "";
   r.v1_fsw_no_veto                     = true;
   r.v1_fsw_no_final_permission_effect  = true;
   r.v1_fsw_was_active_at_decision      = false;

   r.v1_constructive_policy_version = "DISABLED";
   r.v1_policy_constructive_active = false;
   r.v1_policy_state_label = "";
   r.v1_policy_posture = "";
   r.v1_policy_native_families = "";
   r.v1_policy_conditional_families = "";
   r.v1_policy_deprioritized_families = "";
   r.v1_policy_informational_families = "";
   r.v1_policy_eligible_strategy_count = 0;
   r.v1_policy_suppressed_strategy_count = 0;
   r.v1_policy_informational_strategy_count = 0;
   r.v1_policy_unknown_strategy_count = 0;
   r.v1_policy_score_sovereignty_blocked = false;
   r.v1_policy_score_role = "PRE_EXISTING_SCORE_AGGREGATION";
   r.v1_policy_score_could_not_admit_suppressed = false;
   r.v1_policy_score_could_not_override_state = false;
   r.v1_policy_authority_class = "V1_CONSTRUCTIVE_ELIGIBILITY_DISABLED";
   r.v1_policy_strategy_attributions = "";

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

   r.c2_overextension_m5_active     = false;
   r.c2_consensus_tightening_applied = false;
   r.c2_consensus_tightening_delta  = 0.0;
   r.c2_pre_consensus_requirement   = 0.0;
   r.c2_post_consensus_requirement  = 0.0;
   r.c2_effective_on_outcome        = false;
   r.c2_gate_outcome                = "NOT_APPLICABLE";

   r.c3_low_structure_tc_active     = false;
   r.c3_structure_score             = 0.0;
   r.c3_logic_applied               = false;
   r.c3_effective_on_outcome        = false;
   r.c3_gate_outcome                = "NOT_APPLICABLE";

   r.pre_ai_score_gates_demoted        = false;
   r.pre_ai_obs_council_quality        = 0.0;
   r.pre_ai_obs_consensus_strength     = 0.0;
   r.pre_ai_obs_conflict_score         = 0.0;
   r.pre_ai_would_have_gated_quality   = false;
   r.pre_ai_would_have_gated_consensus = false;
   r.pre_ai_would_have_gated_conflict  = false;

   r.structural_reject_gate          = "UNKNOWN";
   r.structural_reject_gate_detail   = "";
   r.pre_ai_structural_passed        = false;

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
   r.c1_tc_active              = false;
   r.c1_high_conviction_active = false;
   r.c1_overextension_active   = false;
   r.c1_pre_governor_candidate = false;
   r.c1_shadowed_by_exhaustion = false;
   r.c1_shadow_reason          = "";
   InitCouncilFailurePatternReport(r.failure_detector);
   r.governor_state                    = "";
   r.governor_state_source             = "";
   r.governor_categorical_state_active = false;
   InitCouncilExecutionAdmissionIdentity(r.execution_admission);
   InitCouncilPacketRegistryConsumptionReport(r.packet_registry);
   InitCouncilPlaybookConsumptionReport(r.playbook_consumption);
   InitCouncilIRREWDevelopmentActionReport(r.irrew_development);
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

   r.c1_tc_active                 = false;
   r.c1_high_conviction_active    = false;
   r.c1_overextension_active      = false;
   r.c1_pre_governor_candidate    = false;
   r.c1_shadowed_by_exhaustion    = false;
   r.c1_shadow_reason             = "";

   r.c2_overextension_m5_active   = false;
   r.c2_consensus_tightening_applied = false;
   r.c2_consensus_tightening_delta   = 0.0;
   r.c2_pre_consensus_requirement    = 0.0;
   r.c2_post_consensus_requirement   = 0.0;
   r.c2_effective_on_outcome         = false;
   r.c2_gate_outcome                 = "NOT_APPLICABLE";

   r.c3_low_structure_tc_active   = false;
   r.c3_structure_score           = 0.0;
   r.c3_logic_applied             = false;
   r.c3_effective_on_outcome      = false;
   r.c3_gate_outcome              = "NOT_APPLICABLE";

   r.c123_obstacle_summary        = "";
   r.c123_obstacle_semantics_version = "C123_OBSERVABILITY_V1";

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
   return "S4_FEEDBACK_V2";
}

string CouncilC123ObstacleSemanticsVersion()
{
   return "C123_OBSERVABILITY_V1";
}

string BuildC123ObstacleSummary(const CouncilPolicyAdjustment &gov, const CouncilPreAIGateReport &gate)
{
   string c1State = "INACTIVE";
   if(gov.c1_pre_governor_candidate)
      c1State = (gov.c1_shadowed_by_exhaustion ? "SHADOWED" : "CANDIDATE");
   else if(gov.c1_tc_active || gov.c1_high_conviction_active || gov.c1_overextension_active)
      c1State = "PARTIAL";

   string c2State = TrimString(gate.c2_gate_outcome);
   if(StringLen(c2State) <= 0)
      c2State = "NOT_APPLICABLE";

   string c3State = TrimString(gate.c3_gate_outcome);
   if(StringLen(c3State) <= 0)
      c3State = "NOT_APPLICABLE";

   return "C1=" + c1State + "|C2=" + c2State + "|C3=" + c3State;
}

string BuildC123ObstacleSummaryFromRuntimeResult(const CouncilRuntimeResult &runtime)
{
   string c1State = "INACTIVE";
   if(runtime.c1_pre_governor_candidate)
      c1State = (runtime.c1_shadowed_by_exhaustion ? "SHADOWED" : "CANDIDATE");
   else if(runtime.c1_tc_active || runtime.c1_high_conviction_active || runtime.c1_overextension_active)
      c1State = "PARTIAL";

   string c2State = TrimString(runtime.pre_ai_gate.c2_gate_outcome);
   if(StringLen(c2State) <= 0)
      c2State = "NOT_APPLICABLE";

   string c3State = TrimString(runtime.pre_ai_gate.c3_gate_outcome);
   if(StringLen(c3State) <= 0)
      c3State = "NOT_APPLICABLE";

   return "C1=" + c1State + "|C2=" + c2State + "|C3=" + c3State;
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

//---------------------------------------------------------
// FVG zone state — IFR / IMBALANCE_FILL_REVERSAL lane
// FVG_TPB_MT5_IMPLEMENTATION_PACKAGE_V1
// Used by council_strategies.mqh for FVG zone tracking.
// Attribution/observation only; no decision authority.
//---------------------------------------------------------
struct SFVGZone
{
   datetime  activation_time;   // M5 bar[j] close time (bar open + 5 min)
   datetime  expiry_time;       // activation_time + 240 minutes (48 M5 bars)
   double    fvg_lo;            // lower boundary of gap zone
   double    fvg_hi;            // upper boundary of gap zone
   double    gap_size_pts;      // gap size in points (fvg_hi - fvg_lo) / _Point
   double    atr_m5;            // ATR14(M5, Wilder) at detection bar
   int       direction;         // CORE_BUY=1 or CORE_SELL=-1
   string    regime_context;    // era_label_v1 at detection time
   bool      is_active;         // time >= activation_time
   bool      is_expired;        // expiry_time passed without trigger
   bool      is_invalidated;    // price closed through far side of gap
   bool      has_triggered;     // M1 entry taken from this zone
   int       age_bars;          // M1 bars elapsed since activation
};

//---------------------------------------------------------
// FVG trigger attribution — write-only ledger fields
// Populated by BuildCouncilStrategy_FVG_TPB; consumed by
// WriteOpportunityLedgerRecord. No decision path reads this.
//---------------------------------------------------------
struct SFVGTriggerAttribution
{
   bool   has_data;
   string fvg_direction;
   double fvg_gap_low;
   double fvg_gap_high;
   string fvg_regime_context;
   string fvg_subset_classification;
   bool   fvg_hostile_gate_fired;
   double fvg_size_atr;
   int    fvg_age_bars;
   int    fvg_active_zone_count;
   double fvg_mitigation_pct;
};

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

   r.c1_tc_active                = false;
   r.c1_high_conviction_active   = false;
   r.c1_overextension_active     = false;
   r.c1_pre_governor_candidate   = false;
   r.c1_shadowed_by_exhaustion   = false;
   r.c1_shadow_reason            = "";

   // Policy Layer contract fields — PLAN-4 Stage 1 additions
   r.reason_code                 = "";
   r.source_flags                = "";
   r.confidence_of_adjustment    = 0.0;
   r.adjustment_intensity        = 0.0;
}

//---------------------------------------------------------
// Opportunity Ledger — per-strategy evaluation counter
// OPPORTUNITY_LEDGER_IMPLEMENTATION_V1A_PLUS
// Instrumentation-only; write-only; no decision influence.
//---------------------------------------------------------
struct StrategyOpportunityCounter
{
   string strategy_id;
   string strategy_family;
   string current_role;

   int evaluations_seen;
   int valid_context_seen;
   int setup_conditions_seen;
   int trigger_seen;

   int trigger_blocked_by_dsn;
   int trigger_blocked_by_crr;
   int trigger_blocked_by_no_trade;
   int trigger_blocked_by_quality_gate;
   int trigger_blocked_by_veto;
   int trigger_blocked_by_direction;
   int trigger_blocked_by_regime;
   int trigger_rejected_by_central_decision;
   int trigger_executed;

   int win_count;
   int loss_count;
   int open_count;

   double sum_mae_pts;
   double sum_mfe_pts;
   int mae_count;
   int mfe_count;

   string last_seen_timestamp;
   string last_trigger_timestamp;
   string last_written_bar_time;

   int write_failures;

   // Cross-family confirm summary counters — Phase 4A-i
   // Incremented only when this strategy's trigger_present=true.
   // Attribution evidence only; no decision-layer authority.
   int no_confirm_seen;
   int same_family_confirm_seen;
   int cross_family_confirm_seen;
   int multi_family_confirm_seen;
};

//---------------------------------------------------------
// Cross-family confirmation evidence — Phase 4A-i
// PHASE_4A_I_LEDGER_EXTENSION_V1
// Computed once per bar, written to JSONL only.
// Attribution / ledger output only.
// No decision authority. No score. No gate. No weight.
//---------------------------------------------------------
struct OL_CrossFamilyEvidence
{
   string primary_executor_id;
   string primary_executor_family;
   bool   same_family_confirm_present;
   bool   cross_family_confirm_present;
   string cross_family_confirm_strategy_id;
   string cross_family_confirm_family;
   string confirm_structure_type;        // NONE / SAME_FAMILY_CONFIRM / CROSS_FAMILY_CONFIRM / MULTI_FAMILY_CONFIRM
   int    confirm_family_count;
   int    confirm_strategy_count;
};

//---------------------------------------------------------
// Playbook shadow architecture state - V1C
// PLAYBOOK_ARCHITECTURE_FULL_IMPLEMENTATION_PACKAGE_V1
// Ledger / attribution output only.
// No decision authority. No score. No gate. No weight.
//---------------------------------------------------------
struct OL_PlaybookShadowState
{
   string playbook_id;
   string playbook_state;
   string primary_packet_id;
   string completed_links_json;
   string missing_links_json;
   string contradicted_links_json;
   bool   failure_mode_present;
   string failure_mode_type;
   bool   required_evidence_present;
   bool   supporting_evidence_present;
   bool   optional_evidence_present;
   string room_state;
   string stop_geometry_state;
   bool   pre_decision_available;
   bool   late_evidence;
   string attribution_note;
   string state_reason;
};

//---------------------------------------------------------
// Event-order trace - V1C
// Diagnostic only; records timestamp availability without
// granting runtime permission or scoring authority.
//---------------------------------------------------------
struct OL_EventOrderTrace
{
   string context_timestamp;
   string location_timestamp;
   string trigger_timestamp;
   string confirm_timestamp;
   string failure_mode_timestamp;
   string room_timestamp;
   string stop_geometry_timestamp;
   string playbook_state_timestamp;
   string decision_timestamp;
   bool   pre_decision_available;
   bool   late_evidence;
   bool   event_order_valid;
   string event_order_violation_reason;
};

#endif
