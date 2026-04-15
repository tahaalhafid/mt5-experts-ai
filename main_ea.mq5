#property strict

#include <Trade/Trade.mqh>

#include "trade_feedback.mqh"
#include "market_regime.mqh"
#include "regime_classification_layer_v1.mqh"
#include "strategy_intelligence_layer_v1.mqh"
#include "execution_estimator_v1.mqh"
#include "unified_confidence.mqh"
#include "institutional_learning_layer_v1.mqh"
#include "performance_journal.mqh"
#include "level_awareness_brake.mqh"
#include "storage_reset_pre_strategy_memory_v1.mqh"
#include "strategy_confidence_memory_v1.mqh"
#include "risk_state_policy_engine.mqh"
#include "failure_taxonomy.mqh"
#include "journal_analytics.mqh"
#include "rollback_signal_engine.mqh"
#include "correlation_engine.mqh"
#include "shadow_replay_engine.mqh"
#include "core_logger.mqh"
#include "config_loader.mqh"
#include "dashboard_contract.mqh"
#include "dashboard_source_registry.mqh"
#include "dashboard_state_collector.mqh"
#include "dashboard_state_classifier.mqh"
#include "dashboard_view_model.mqh"
#include "dashboard_guardrails.mqh"
#include "dashboard_snapshot_exporter.mqh"
#include "dashboard_navigation_controller.mqh"
#include "dashboard_renderer.mqh"
#include "core_market_data.mqh"
#include "core_trade_engine.mqh"
#include "strategy_compiler.mqh"
#include "strategy_runtime.mqh"
#include "decision_mode_router.mqh"
#include "atas_governed_advisory_contract.mqh"
#include "atas_governed_advisory_artifacts.mqh"
#include "atas_governed_advisory_layer.mqh"
#include "ai_bridge.mqh"
#include "ai_evolution_engine.mqh"
#include "performance_memory.mqh"
#include "plan_auto_apply.mqh"
#include "rollback_engine.mqh"
#include "runtime_honesty_surfaces.mqh"
#include "evolution_governor.mqh"

#include "LIBRARIES/library_indicators.mqh"
#include "LIBRARIES/library_strategies.mqh"
#include "LIBRARIES/library_entry_patterns.mqh"
#include "LIBRARIES/library_risk_models.mqh"
#include "LIBRARIES/library_filters.mqh"

CTrade trade;

SCM_StrategyStats gSCMCache[];


//---------------------------------------------------------
// Inputs
//---------------------------------------------------------
input double FixedLot = 0.10;
input ulong  Magic    = 26059999;

// Council setup lifecycle (opt-in, COUNCIL only)
input bool EnableCouncilSetupLifecycle = false;
input int  CouncilSetupConfirmBars    = 1;


// Council execution quality gate (opt-in, COUNCIL only)
input bool   EnableCouncilExecutionQualityGate = false;
input double CouncilExecutionQualityMinScore   = 0.55;
input double CouncilMaxSpreadAtrFraction       = 0.12;
input double CouncilMaxChaseAtrFraction        = 0.30;


// Council activation pressure gate (opt-in, COUNCIL only)
input bool   EnableCouncilActivationPressureGate             = false;
input double CouncilMinConsensusForWeakCoverage             = 0.62;
input double CouncilMinConsensusForConflictedCoverage       = 0.72;
input double CouncilMinConsensusToAllowCrowdedActivation    = 0.76;
input double CouncilMaxCrowdingConcentration                = 0.82;

// Council dirty / transitional environment tightening (opt-in, COUNCIL only)
input bool   EnableCouncilDirtyEnvironmentTightening      = false;
input double CouncilDirtyTradabilityFloor                = 0.55;
input double CouncilCompressionTradabilityFloor          = 0.58;
input double CouncilReversalRiskTradabilityFloor         = 0.52;
input double CouncilDirtyMinEnvironmentScore             = 0.74;
input double CouncilTransitionalMinCouncilQuality        = 0.72;



// Council live exit architecture (opt-in; default OFF)
input bool   EnableCouncilLiveExitArchitecture      = false;
input int    CouncilExitPremiseDeathM5Bars          = 6;
input double CouncilExitMinProgressToKeep           = 0.18;
input double CouncilExitGivebackTriggerProgress     = 0.55;
input double CouncilExitGivebackRetainedFloor       = 0.20;

// AI intelligence & oversight layer (H6 authority-gated; never direct trading control)
input bool   EnableAIEvolution       = true;
input int    EvolutionEveryNBars     = 30;
input bool   EnableAutoApplyPlan     = true;
input int    EvolutionCooldownBars   = 10;
input bool   LogEvolutionRawResponse = true;

input bool   EnableAutoRollback           = true;
input int    RollbackMinTradesAfterApply  = 6;
input double RollbackMinWinRate           = 35.0;
input int    RollbackMaxConsecutiveLosses = 3;
input double RollbackMinAvgProfitPerTrade = -1.0;

// Runtime execution controls
input bool   EnableRuntimeExecution = true;
input bool   OneTradeAttemptPerBar  = true;

// Runtime risk & safety hardening (H5)
input bool   EnableRuntimeRiskSafetyHardening          = true;
input int    RuntimeExecutionFailureLockoutCount       = 3;
input bool   EnableEmergencyFlatOnCriticalSafetyState  = false;
input bool   EnableOpenPositionManagementInBlockedSafeMode = true;

// AI activation readiness gate (H6)
input int    AIGateMinDecisions                    = 300;
input int    AIGateMinTradeOpens                   = 30;
input int    AIGateMinClosedOutcomes               = 20;
input bool   AIGateSecurityClearanceForShadow      = true;
input bool   AIGateSecurityClearanceForAdvisory    = false;
input int    AIHourlyRunCap                        = 6;
input int    AIDeepInvestigationDailyCap           = 4;
input int    AITriggerCooldownMinutes              = 30;

// AI council contextual advisory integration (A6)
input bool   EnableAICouncilContextualAdvisory       = true;
input int    AICouncilHoldBars                       = 1;
input int    AICouncilMaxHoldsPerSignature           = 1;
input bool   EnableAICandidateBlock                  = false;
input double AICandidateBlockMinConfidence           = 0.90;
input double AICandidateBlockMinEvidenceStrength     = 0.85;
input int    AICandidateBlockMinCorroborationCount   = 3;

// ATAS governed advisory integration (Level 3; bounded and non-authoritative)
input bool   EnableATASGovernedAdvisory              = true;
input int    ATASAdvisoryRolloutMode                 = 0;     // 0=OBSERVE_ONLY, 1=SOFT_INFLUENCE, 2=HOLD_REEVALUATE
input int    ATASAdvisoryHoldBars                    = 1;
input int    ATASAdvisoryMaxHoldsPerSignature        = 1;
input double ATASAdvisoryMinRelevanceScore           = 0.55;
input double ATASAdvisoryMinConfluenceScore          = 0.45;
input bool   ATASAdvisoryRequireFreshShadow          = true;
input bool   ATASAdvisoryAllowSemanticOnly           = true;
input int    ATASAdvisoryLevelNearThresholdPoints    = 180;
input double ATASAdvisoryRejectionRiskThreshold      = 0.65;
input double ATASAdvisoryBreakoutRoomTightThreshold  = 0.35;
input int    AtasStatusHeartbeatIntervalSec          = 5; // status-only heartbeat sync throttle (seconds)

// Institutional self-learning overlay (L3 bounded, non-authoritative)
input bool   EnableInstitutionalSelfLearning         = true;

// Support/Resistance chart overlay (bounded visualization only)
input bool   EnableSupportResistanceChartVisualization = true;
input int    SupportResistanceOverlayDisplayMode = 1; // 0=DECISION_VIEW, 1=STRUCTURE_VIEW, 2=CLEAN_VIEW
input int    SupportResistanceOverlayMaxLevelsPerSide = 2; // bounded to [1..2]
input int    SupportResistanceOverlayConfluenceThresholdPoints = 10;
input int    SupportResistanceOverlayVisualOffsetPoints = 2;

// Internal MT5 dashboard chart UI (visual path only; collectors remain active)
input bool   EnableInternalDashboardChartUI = false;

// Trade engine risk settings
input double TradeRR               = 1.50;
input double TradeATRMultiplier    = 1.20;
input int    TradeATRPeriod        = 14;
input double ExtraStopBufferPoints = 50.0;

// Runtime logging
input bool   LogRuntimeDecision         = true;
input bool   EnableTradeFeedbackLogging = true;

//---------------------------------------------------------
// Globals
//---------------------------------------------------------
PersonalityProfile gPersonality;
RuntimePlan        gPlan;
CompiledPlan       gCompiledPlan;
AISecrets          gAISecrets;

RegimeClassification gRegime;
bool               gHasRegime = false;

EntryQualityResult      gEntryQuality;
StrategyRegimeFitResult gStrategyFit;
DecisionQualityResult   gDecisionQuality;
bool                   gHasStrategyIntel = false;
RuntimeDecision         gLastDecisionEval = RUNTIME_WAIT;


TimeframeSnapshot    gLastM1Snapshot;
TimeframeSnapshot    gLastM5Snapshot;
bool                gHasLastSnapshots = false;

EntryEdgeResult            gEntryEdge;
FollowThroughQualityResult gFollowThrough;
ExecutionEstimationResult  gExecEstimation;
bool                       gHasExecEstimation = false;


RiskPolicySnapshot  gRiskPolicy;
bool                gHasRiskPolicy = false;

string              gCurrentDecisionId = "";
string              gLastEntryDecisionId = "";

FailureClassification gDecisionFailure;
FailureClusterResult gFailureCluster;
bool                gHasFailureCluster = false;
TradeCorrelation    gLastOpenCorrelation;

//---------------------------------------------------------
// SR chart visualization (bounded, non-authoritative)
//---------------------------------------------------------
#define SRVIZ_MAX_LEVELS_PER_SIDE 2
#define SRVIZ_MODE_DECISION_VIEW 0
#define SRVIZ_MODE_STRUCTURE_VIEW 1
#define SRVIZ_MODE_CLEAN_VIEW 2

color SRVIZ_COLOR_FINAL_PRIMARY   = C'46,150,92';
color SRVIZ_COLOR_FINAL_SECONDARY = C'78,178,120';
color SRVIZ_COLOR_ATAS_PRIMARY    = C'188,88,88';
color SRVIZ_COLOR_ATAS_SECONDARY  = C'214,132,132';
color SRVIZ_COLOR_CONFLUENCE_HINT = C'196,196,196';

string SRVIZ_FINAL_SUPPORT_LINE   = "SRVIZ_FINAL_SUPPORT_LINE";
string SRVIZ_FINAL_RES_LINE       = "SRVIZ_FINAL_RESISTANCE_LINE";
string SRVIZ_ATAS_SUPPORT_LINE    = "SRVIZ_ATAS_SUPPORT_LINE";
string SRVIZ_ATAS_RES_LINE        = "SRVIZ_ATAS_RESISTANCE_LINE";
string SRVIZ_FINAL_SUPPORT_LABEL  = "SRVIZ_FINAL_SUPPORT_LABEL";
string SRVIZ_FINAL_RES_LABEL      = "SRVIZ_FINAL_RESISTANCE_LABEL";
string SRVIZ_ATAS_SUPPORT_LABEL   = "SRVIZ_ATAS_SUPPORT_LABEL";
string SRVIZ_ATAS_RES_LABEL       = "SRVIZ_ATAS_RESISTANCE_LABEL";
string SRVIZ_STATUS_LABEL         = "SRVIZ_STATUS_LABEL";
string gSRVizLastStatusLogKey     = "";
datetime gAtasStatusHeartbeatLastRefresh = 0;
//---------------------------------------------------------
// Runtime governance hardening (H1)
//---------------------------------------------------------
struct RuntimeGovernanceState
{
   string   governance_state;
   bool     trading_allowed;
   bool     degraded_mode;
   bool     truth_ready;
   bool     diagnostics_ready;
   bool     rollback_recently_applied;
   string   reason_code;
   string   active_plan_id;
   string   active_mode;
   string   status_origin;
   bool     factory_first_admission_policy_locked;
   bool     strategy_transfer_runtime_freeze_active;
   string   strategy_transfer_runtime_freeze_scope;
   string   strategy_transfer_runtime_freeze_reason_code;
   bool     strategy_execution_identity_authority_frozen;
   bool     compiled_plan_runtime_privilege_frozen;
   bool     council_runtime_execution_privilege_frozen;
   bool     future_factory_admission_required_for_execution;
   string   lineage_preservation_mode;
   string   package1_policy_lock_state;
   string   package1_runtime_freeze_state;
   string   execution_authority_source;
   string   execution_authority_cutover_state;
   bool     legacy_identity_execution_authority_active;
   bool     factory_governed_execution_authority_active;
   bool     active_operating_cohort_defined;
   string   active_operating_cohort_id;
   int      active_operating_candidate_count;
   bool     execution_allowed_only_through_active_operating_cohort;
   string   operating_cohort_admission_semantics;
   string   operating_risk_envelope_state;
   string   current_guardrail_block_reason_code;
   string   current_guardrail_owner;
   datetime last_state_change;
   datetime evaluated_at;
};

static RuntimeGovernanceState gRuntimeGovernance;
static bool gRuntimeGovernanceInitialized = false;
static bool gRuntimeGovernanceStartupComplete = false;
static bool gRuntimeGovernanceRollbackRecoveryPending = false;

//---------------------------------------------------------
// Runtime risk & safety hardening (H5)
//---------------------------------------------------------
struct RuntimeRiskSafetyState
{
   string   safety_state;
   bool     trading_allowed;
   bool     emergency_flat_required;
   bool     safe_block_mode;
   bool     degraded_protection_mode;
   bool     open_position_management_only;
   string   safety_reason_code;
   int      consecutive_open_failures;
   bool     rollback_recovery_pending;
   bool     governance_degraded;
   string   governance_state;
   string   governance_reason_code;
   string   active_plan_id;
   string   active_mode;
   string   operating_risk_envelope_state;
   bool     envelope_clear_for_new_entries;
   string   current_blocking_guard;
   string   current_block_reason_code;
   string   current_block_owner;
   int      max_open_positions;
   int      current_open_positions;
   int      max_new_trades_per_session;
   int      current_session_new_entries;
   int      effective_session_trade_cap;
   int      cooldown_bars;
   int      bars_since_last_entry;
   bool     spread_guard_active;
   double   spread_guard_threshold_points;
   double   current_spread_points;
   bool     risk_policy_guard_active;
   bool     execution_quality_guard_active;
   bool     emergency_stop_active;
   string   status_origin;
   datetime evaluated_at;
   datetime last_state_change;
};

static RuntimeRiskSafetyState gRuntimeRiskSafety;
static bool gRuntimeRiskSafetyInitialized = false;
static int  gRuntimeConsecutiveOpenFailures = 0;

//---------------------------------------------------------
// AI activation readiness gate (H6)
//---------------------------------------------------------
struct AIAuthorityReadinessState
{

   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   trust_rule;
   string   status_origin;

   string   authority_state;      // AI_OFF / AI_SHADOW_ONLY / AI_ADVISORY_ONLY
   string   readiness_state;      // NOT_READY / SHADOW_READY / ADVISORY_READY

   bool     ai_enabled;
   bool     ai_bridge_ready;
   bool     truth_ready;
   bool     diagnostics_ready;
   bool     replay_ready;
   bool     validation_ready;
   bool     safety_ready;
   bool     sample_ready;
   bool     security_clearance_for_shadow;
   bool     security_clearance_for_advisory;
   bool     runtime_governance_allows_ai;

   string   readiness_reason_code;
   string   next_upgrade_blocker;

   string   active_plan_id;
   string   active_mode;

   string   allowed_task_families;
   string   allowed_input_classes;
   string   allowed_output_classes;
   string   forbidden_surface_classes;

   string   learning_governance_role;
   string   council_advisory_role;
   string   council_advisory_reserved_future_state;
   string   council_advisory_allowed_outputs;
   string   council_advisory_forbidden_outputs;

   string   trigger_mode;
   string   cost_control_mode;
   string   dedupe_mode;
   string   deep_investigation_mode;

   int      effective_min_decisions;
   int      effective_min_trade_opens;
   int      effective_min_closed_outcomes;
   int      sample_decisions;
   int      sample_trade_opens;
   int      sample_closed_outcomes;

   int      effective_hourly_run_cap;
   int      effective_deep_investigation_daily_cap;
   int      effective_trigger_cooldown_minutes;

   bool     direct_control_allowed;
   bool     auto_apply_allowed;
   bool     directional_trade_generation_allowed;
   bool     direct_candidate_veto_active;

   string   review_surface_state;
   bool     review_surface_present;
   bool     review_surface_independent_of_authority;
   bool     review_surface_implies_authority_ready;
   string   readiness_review_consistency_state;
   string   readiness_review_note;

   datetime evaluated_at;
   datetime last_state_change;
};


static AIAuthorityReadinessState gAIAuthorityReadiness;
static bool gAIAuthorityReadinessInitialized = false;

//---------------------------------------------------------
// Operational integrity / coherence cutover (O1)
//---------------------------------------------------------
struct OperationalIntegrityDomainState
{
   string   domain_id;
   string   state;
   string   issue_class;
   string   owner;
   string   reason;
   datetime last_checked;
};

struct OperationalIntegrityStatus
{

   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   status_origin;
   string   overall_state;
   string   overall_reason;
   string   ai_readiness_review_consistency_state;
   string   ai_readiness_review_consistency_reason;
   string   freshness_gate_state;
   int      stale_critical_surface_count;
   string   stale_critical_surfaces;
   string   dominant_stale_surface;
   string   dominant_stale_reason;
   datetime last_freshness_check_time;
   datetime last_checked;

   OperationalIntegrityDomainState runtime_integrity;
   OperationalIntegrityDomainState execution_authority_integrity;
   OperationalIntegrityDomainState dashboard_integrity;
   OperationalIntegrityDomainState factory_integrity;
   OperationalIntegrityDomainState ai_oversight_integrity;
   OperationalIntegrityDomainState journaling_integrity;
   OperationalIntegrityDomainState risk_safety_integrity;
};

static OperationalIntegrityStatus gOperationalIntegrity;
static bool gOperationalIntegrityInitialized = false;

struct ActiveOperatingCohortStatus
{
   string   active_operating_cohort_id;
   string   active_operating_cohort_state;
   string   active_operating_candidates_csv;
   int      candidate_count;
   string   operating_cohort_admission_semantics;
   string   candidate_sources;
   string   cohort_activation_reason;
   string   cohort_scope_note;
   datetime last_updated;
};

struct ExecutionAuthorityStatus
{
   string   execution_authority_source;
   string   execution_authority_cutover_state;
   bool     legacy_identity_execution_authority_active;
   bool     factory_governed_execution_authority_active;
   bool     active_operating_cohort_defined;
   string   active_operating_cohort_id;
   int      active_operating_candidate_count;
   bool     execution_allowed_only_through_active_operating_cohort;
   string   operating_cohort_admission_semantics;
   string   operating_risk_envelope_state;
   string   current_guardrail_block_reason_code;
   string   current_guardrail_owner;
   bool     execution_globally_blocked;
   string   execution_block_reason_code;
   string   decision_candidate_name;
   string   decision_candidate_family;
   string   last_reject_candidate_name;
   string   last_reject_candidate_family;
   string   last_reject_reason_code;
   string   last_executed_candidate_name;
   string   last_executed_candidate_family;
   datetime last_executed_candidate_time;
   datetime last_updated;
};

static ActiveOperatingCohortStatus gActiveOperatingCohort;
static bool gActiveOperatingCohortInitialized = false;
static ExecutionAuthorityStatus gExecutionAuthorityStatus;
static bool gExecutionAuthorityInitialized = false;

struct OperatingRiskEnvelopeStatus
{
   string   operating_risk_envelope_state;
   bool     envelope_clear_for_new_entries;
   int      max_open_positions;
   int      current_open_positions;
   int      max_new_trades_per_session;
   int      current_session_new_entries;
   int      effective_session_trade_cap;
   int      cooldown_bars;
   int      bars_since_last_entry;
   bool     spread_guard_active;
   double   spread_guard_threshold_points;
   double   current_spread_points;
   bool     risk_policy_guard_active;
   bool     execution_quality_guard_active;
   bool     emergency_stop_active;
   string   current_blocking_guard;
   string   current_block_reason_code;
   string   current_block_reason_text;
   string   current_block_owner;
   string   last_direction_under_review;
   datetime last_updated;
};

static OperatingRiskEnvelopeStatus gOperatingRiskEnvelope;
static bool gOperatingRiskEnvelopeInitialized = false;

static string gCurrentDecisionCandidateName = "";
static string gCurrentDecisionCandidateFamily = "";
static string gLastRejectedCandidateName = "";
static string gLastRejectedCandidateFamily = "";
static string gLastRejectedReasonCode = "";
static string gLastExecutedCandidateName = "";
static string gLastExecutedCandidateFamily = "";
static datetime gLastExecutedCandidateTime = 0;


struct LastMeaningfulRuntimeEventStatus
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   event_type;
   datetime event_time;
   string   candidate_name;
   string   candidate_family;
   string   reason_code;
   string   direction;
   string   short_note;
   string   source_owner;
   string   decision_id;
   datetime updated_at;
};

static LastMeaningfulRuntimeEventStatus gLastMeaningfulRuntimeEvent;
static bool gLastMeaningfulRuntimeEventInitialized = false;

struct FactoryOperationalEvidenceStatus
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   active_operating_cohort_id;
   int      active_operating_candidate_count;
   string   operating_cohort_admission_semantics;
   string   evidence_scope;
   string   evidence_scope_note;
   int      decisions_total;
   int      rejected_total;
   int      waits_total;
   int      execution_total;
   int      closed_outcomes_total;
   int      wins;
   int      losses;
   int      flat;
   double   win_rate;
   double   net_realized_pl;
   string   last_trade_result;
   string   last_trade_time;
   string   last_executed_candidate_name;
   string   last_executed_candidate_family;
   string   evidence_completeness_state;
   string   evidence_completeness_note;
   string   lineage_note;
   bool     candidate_auto_promotion_allowed;
   bool     candidate_auto_suppression_allowed;
   bool     factory_classification_mutation_allowed;
   datetime last_refresh_time;
};

static FactoryOperationalEvidenceStatus gFactoryOperationalEvidence;
static bool gFactoryOperationalEvidenceInitialized = false;

struct AIOperationalReviewStatus
{

   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   authority_state;
   string   ai_operational_role;
   string   advisory_scope_note;
   bool     repeated_reject_cluster_present;
   string   repeated_reject_cluster_family;
   int      repeated_reject_cluster_count;
   string   no_trade_pattern_state;
   string   drift_observation_state;
   string   evidence_gap_state;
   string   advisory_sufficiency_state;
   string   interpretability_state;
   string   dominant_block_layer;
   string   dominant_reason_code;
   int      recent_window_decisions;
   int      recent_window_rejects;
   int      recent_window_waits;
   string   dominant_regime_label;
   string   post_execution_context_note;
   string   last_meaningful_event_type;
   string   last_meaningful_event_time;
   bool     execution_authority_granted;
   bool     trade_generation_authority;
   bool     auto_apply_allowed;
   bool     runtime_mutation_allowed;
   string   readiness_reference_state;
   string   readiness_alignment_state;
   bool     review_independent_of_authority_readiness;
   bool     review_implies_authority_ready;
   string   non_authoritative_notice;
   datetime last_review_time;
};

static AIOperationalReviewStatus gAIOperationalReview;
static bool gAIOperationalReviewInitialized = false;

struct RecentDecisionWindowSummary
{
   int      sampled_decisions;
   int      reject_count;
   int      wait_count;
   int      approved_or_executed_count;
   int      blocked_count;
   string   dominant_rejection_family;
   int      dominant_rejection_family_count;
   string   dominant_reason_code;
   int      dominant_reason_code_count;
   string   dominant_block_layer;
   int      dominant_block_layer_count;
   string   dominant_regime_label;
   int      dominant_regime_count;
   int      distinct_regime_count;
   string   latest_decision_time;
   string   latest_decision_reason;
};



void InitLastMeaningfulRuntimeEventStatus(LastMeaningfulRuntimeEventStatus &st)
{
   st.artifact_role = "LAST_MEANINGFUL_RUNTIME_EVENT";
   st.artifact_authority_class = "NON_AUTHORITATIVE_RUNTIME_EVENT_SUMMARY";
   st.summary_version = "O5_LAST_MEANINGFUL_EVENT_V1";
   st.event_type = "RUNTIME_INIT";
   st.event_time = TimeCurrent();
   st.candidate_name = "";
   st.candidate_family = "";
   st.reason_code = "runtime_init_status";
   st.direction = "";
   st.short_note = "Latest meaningful runtime event has not yet been established.";
   st.source_owner = "runtime_initialization";
   st.decision_id = "";
   st.updated_at = TimeCurrent();
}

void SaveLastMeaningfulRuntimeEventBestEffort(const LastMeaningfulRuntimeEventStatus &st)
{
   string txt = "";
   txt += "artifact_role=" + st.artifact_role + "\n";
   txt += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   txt += "summary_version=" + st.summary_version + "\n";
   txt += "event_type=" + st.event_type + "\n";
   txt += "event_time=" + DiagnosticTimeText(st.event_time) + "\n";
   txt += "candidate_name=" + st.candidate_name + "\n";
   txt += "candidate_family=" + st.candidate_family + "\n";
   txt += "reason_code=" + st.reason_code + "\n";
   txt += "direction=" + st.direction + "\n";
   txt += "short_note=" + st.short_note + "\n";
   txt += "source_owner=" + st.source_owner + "\n";
   txt += "decision_id=" + st.decision_id + "\n";
   txt += "updated_at=" + DiagnosticTimeText(st.updated_at) + "\n";
   WriteTextFileAll(LastMeaningfulRuntimeEventTxtPath(), txt);

   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"event_type\":\"" + JsonEscapeString(st.event_type) + "\"";
   j += ",\"event_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.event_time)) + "\"";
   j += ",\"candidate_name\":\"" + JsonEscapeString(st.candidate_name) + "\"";
   j += ",\"candidate_family\":\"" + JsonEscapeString(st.candidate_family) + "\"";
   j += ",\"reason_code\":\"" + JsonEscapeString(st.reason_code) + "\"";
   j += ",\"direction\":\"" + JsonEscapeString(st.direction) + "\"";
   j += ",\"short_note\":\"" + JsonEscapeString(st.short_note) + "\"";
   j += ",\"source_owner\":\"" + JsonEscapeString(st.source_owner) + "\"";
   j += ",\"decision_id\":\"" + JsonEscapeString(st.decision_id) + "\"";
   j += ",\"updated_at\":\"" + JsonEscapeString(DiagnosticTimeText(st.updated_at)) + "\"";
   j += "}";
   WriteTextFileAll(LastMeaningfulRuntimeEventJsonPath(), j);
}

void UpdateLastMeaningfulRuntimeEventBestEffort(const string eventType,
                                                const string candidateName,
                                                const string candidateFamily,
                                                const string reasonCode,
                                                const string direction,
                                                const string shortNote,
                                                const string sourceOwner,
                                                const string decisionId = "",
                                                const datetime eventTime = 0)
{
   if(!gLastMeaningfulRuntimeEventInitialized)
      InitLastMeaningfulRuntimeEventStatus(gLastMeaningfulRuntimeEvent);

   gLastMeaningfulRuntimeEvent.artifact_role = "LAST_MEANINGFUL_RUNTIME_EVENT";
   gLastMeaningfulRuntimeEvent.artifact_authority_class = "NON_AUTHORITATIVE_RUNTIME_EVENT_SUMMARY";
   gLastMeaningfulRuntimeEvent.summary_version = "O5_LAST_MEANINGFUL_EVENT_V1";
   gLastMeaningfulRuntimeEvent.event_type = eventType;
   gLastMeaningfulRuntimeEvent.event_time = (eventTime > 0 ? eventTime : TimeCurrent());
   gLastMeaningfulRuntimeEvent.candidate_name = TrimString(candidateName);
   gLastMeaningfulRuntimeEvent.candidate_family = OperatingCohortNormalizeFamily(candidateFamily);
   gLastMeaningfulRuntimeEvent.reason_code = TrimString(reasonCode);
   gLastMeaningfulRuntimeEvent.direction = TrimString(direction);
   gLastMeaningfulRuntimeEvent.short_note = DashboardShortText(TrimString(shortNote), 144);
   gLastMeaningfulRuntimeEvent.source_owner = TrimString(sourceOwner);
   gLastMeaningfulRuntimeEvent.decision_id = TrimString(decisionId);
   gLastMeaningfulRuntimeEvent.updated_at = TimeCurrent();

   if(StringLen(gLastMeaningfulRuntimeEvent.candidate_name) == 0 && StringLen(gCurrentDecisionCandidateName) > 0)
      gLastMeaningfulRuntimeEvent.candidate_name = gCurrentDecisionCandidateName;
   if(StringLen(gLastMeaningfulRuntimeEvent.candidate_family) == 0 && StringLen(gCurrentDecisionCandidateFamily) > 0)
      gLastMeaningfulRuntimeEvent.candidate_family = gCurrentDecisionCandidateFamily;
   if(StringLen(gLastMeaningfulRuntimeEvent.candidate_name) == 0 && StringLen(gLastExecutedCandidateName) > 0 &&
      (eventType == "EXECUTION_OPENED" || eventType == "TRADE_CLOSED"))
      gLastMeaningfulRuntimeEvent.candidate_name = gLastExecutedCandidateName;
   if(StringLen(gLastMeaningfulRuntimeEvent.candidate_family) == 0 && StringLen(gLastExecutedCandidateFamily) > 0 &&
      (eventType == "EXECUTION_OPENED" || eventType == "TRADE_CLOSED"))
      gLastMeaningfulRuntimeEvent.candidate_family = gLastExecutedCandidateFamily;

   SaveLastMeaningfulRuntimeEventBestEffort(gLastMeaningfulRuntimeEvent);
   gLastMeaningfulRuntimeEventInitialized = true;
}

void RefreshLastMeaningfulRuntimeEventFromCurrentPostureBestEffort()
{
   string json = "";
   if(ReadTextFileAll(LastMeaningfulRuntimeEventJsonPath(), json) && StringLen(TrimString(json)) > 0)
   {
      gLastMeaningfulRuntimeEventInitialized = true;
      return;
   }

   string runtimeReason = "";
   string runtimeState = "";
   string guardReason = "";
   string guardState = "";

   ReadTextFileAll(RuntimeGovernanceStatusJsonPath(), json);
   ExtractJsonStringField(json, "reason_code", runtimeReason);
   ExtractJsonStringField(json, "governance_state", runtimeState);

   json = "";
   ReadTextFileAll(OperatingRiskEnvelopeStatusJsonPath(), json);
   ExtractJsonStringField(json, "current_block_reason_code", guardReason);
   ExtractJsonStringField(json, "operating_risk_envelope_state", guardState);

   if(StringLen(guardReason) > 0)
   {
      UpdateLastMeaningfulRuntimeEventBestEffort("GUARDRAIL_BLOCK",
                                                 gCurrentDecisionCandidateName,
                                                 gCurrentDecisionCandidateFamily,
                                                 guardReason,
                                                 "",
                                                 "Operating envelope currently reports an active dominant guardrail block.",
                                                 "operating_risk_envelope");
      return;
   }

   UpdateLastMeaningfulRuntimeEventBestEffort("POSTURE_STATUS",
                                              gCurrentDecisionCandidateName,
                                              gCurrentDecisionCandidateFamily,
                                              runtimeReason,
                                              "",
                                              "Runtime posture is " + DashboardValueOr(runtimeState, "unknown") + " with envelope " + DashboardValueOr(guardState, "unknown") + ".",
                                              "runtime_governance_status");
}

void InitRecentDecisionWindowSummary(RecentDecisionWindowSummary &st)
{
   st.sampled_decisions = 0;
   st.reject_count = 0;
   st.wait_count = 0;
   st.approved_or_executed_count = 0;
   st.blocked_count = 0;
   st.dominant_rejection_family = "";
   st.dominant_rejection_family_count = 0;
   st.dominant_reason_code = "";
   st.dominant_reason_code_count = 0;
   st.dominant_block_layer = "";
   st.dominant_block_layer_count = 0;
   st.dominant_regime_label = "";
   st.dominant_regime_count = 0;
   st.distinct_regime_count = 0;
   st.latest_decision_time = "";
   st.latest_decision_reason = "";
}

void OperationalLoopCountValue(string &keys[], int &counts[], int &used, const string rawValue)
{
   string key = TrimString(rawValue);
   if(StringLen(key) == 0)
      key = "UNSPECIFIED";

   for(int i = 0; i < used; i++)
   {
      if(keys[i] == key)
      {
         counts[i]++;
         return;
      }
   }

   ArrayResize(keys, used + 1);
   ArrayResize(counts, used + 1);
   keys[used] = key;
   counts[used] = 1;
   used++;
}

void BuildRecentDecisionWindowSummary(const string journalText, RecentDecisionWindowSummary &st, const int maxDecisions = 80)
{
   InitRecentDecisionWindowSummary(st);

   string trimmed = TrimString(journalText);
   if(StringLen(trimmed) == 0)
      return;

   string lines[];
   int totalLines = StringSplit(journalText, '\n', lines);
   if(totalLines <= 0)
      return;

   string familyKeys[];
   int familyCounts[];
   int familyUsed = 0;

   string layerKeys[];
   int layerCounts[];
   int layerUsed = 0;

   string reasonKeys[];
   int reasonCounts[];
   int reasonUsed = 0;

   string regimeKeys[];
   int regimeCounts[];
   int regimeUsed = 0;

   for(int i = totalLines - 1; i >= 0; i--)
   {
      string line = TrimString(lines[i]);
      if(StringLen(line) == 0)
         continue;

      string recordType = "";
      if(!ExtractJsonStringField(line, "record_type", recordType))
         continue;
      if(recordType != "DECISION")
         continue;

      st.sampled_decisions++;
      if(StringLen(st.latest_decision_time) == 0)
      {
         ExtractJsonStringField(line, "ts", st.latest_decision_time);
         ExtractJsonStringField(line, "final_block_reason_code", st.latest_decision_reason);
      }

      string finalDecision = "";
      ExtractJsonStringField(line, "final_decision", finalDecision);
      StringToUpper(finalDecision);
      if(finalDecision == "REJECT")
         st.reject_count++;
      else if(finalDecision == "WAIT")
         st.wait_count++;
      else if(finalDecision == "BUY" || finalDecision == "SELL")
         st.approved_or_executed_count++;

      string blockLayer = "";
      ExtractJsonStringField(line, "final_blocking_layer", blockLayer);
      if(StringLen(TrimString(blockLayer)) > 0 && blockLayer != "none")
      {
         st.blocked_count++;
         OperationalLoopCountValue(layerKeys, layerCounts, layerUsed, blockLayer);
      }

      string reasonCode = "";
      ExtractJsonStringField(line, "final_block_reason_code", reasonCode);
      reasonCode = TrimString(reasonCode);
      if(StringLen(reasonCode) > 0)
         OperationalLoopCountValue(reasonKeys, reasonCounts, reasonUsed, reasonCode);

      string rejectionFamily = "";
      ExtractJsonStringField(line, "validation_rejection_family", rejectionFamily);
      if(finalDecision == "REJECT" || finalDecision == "WAIT" || StringLen(TrimString(rejectionFamily)) > 0)
         OperationalLoopCountValue(familyKeys, familyCounts, familyUsed, rejectionFamily);

      string regimeLabel = "";
      ExtractJsonStringField(line, "regime_label", regimeLabel);
      if(StringLen(TrimString(regimeLabel)) > 0)
         OperationalLoopCountValue(regimeKeys, regimeCounts, regimeUsed, regimeLabel);

      if(st.sampled_decisions >= maxDecisions)
         break;
   }

   st.distinct_regime_count = regimeUsed;

   for(int i = 0; i < familyUsed; i++)
   {
      if(familyCounts[i] > st.dominant_rejection_family_count)
      {
         st.dominant_rejection_family_count = familyCounts[i];
         st.dominant_rejection_family = familyKeys[i];
      }
   }

   for(int i = 0; i < reasonUsed; i++)
   {
      if(reasonCounts[i] > st.dominant_reason_code_count)
      {
         st.dominant_reason_code_count = reasonCounts[i];
         st.dominant_reason_code = reasonKeys[i];
      }
   }

   for(int i = 0; i < layerUsed; i++)
   {
      if(layerCounts[i] > st.dominant_block_layer_count)
      {
         st.dominant_block_layer_count = layerCounts[i];
         st.dominant_block_layer = layerKeys[i];
      }
   }

   for(int i = 0; i < regimeUsed; i++)
   {
      if(regimeCounts[i] > st.dominant_regime_count)
      {
         st.dominant_regime_count = regimeCounts[i];
         st.dominant_regime_label = regimeKeys[i];
      }
   }
}

void InitFactoryOperationalEvidenceStatus(FactoryOperationalEvidenceStatus &st)
{
   st.artifact_role = "FACTORY_OPERATIONAL_EVIDENCE_STATUS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_FACTORY_EVIDENCE_SUMMARY";
   st.summary_version = "O6_FACTORY_OPERATIONAL_EVIDENCE_V1";
   st.active_operating_cohort_id = "";
   st.active_operating_candidate_count = 0;
   st.operating_cohort_admission_semantics = "FAMILY_LEVEL";
   st.evidence_scope = "HISTORICAL_PLUS_CURRENT_RUNTIME_SUMMARY";
   st.evidence_scope_note = "Active cohort context is current, but displayed counts are derived from broader bounded runtime and journal surfaces rather than strict active-cohort-only evidence.";
   st.decisions_total = 0;
   st.rejected_total = 0;
   st.waits_total = 0;
   st.execution_total = 0;
   st.closed_outcomes_total = 0;
   st.wins = 0;
   st.losses = 0;
   st.flat = 0;
   st.win_rate = 0.0;
   st.net_realized_pl = 0.0;
   st.last_trade_result = "";
   st.last_trade_time = "";
   st.last_executed_candidate_name = "";
   st.last_executed_candidate_family = "";
   st.evidence_completeness_state = "PARTIAL";
   st.evidence_completeness_note = "Factory operational evidence has not yet been refreshed from runtime surfaces.";
   st.lineage_note = "Live operation remains linked to current cohort/pilot lineage; no auto-promotion or classification mutation is permitted.";
   st.candidate_auto_promotion_allowed = false;
   st.candidate_auto_suppression_allowed = false;
   st.factory_classification_mutation_allowed = false;
   st.last_refresh_time = TimeCurrent();
}

string BuildFactoryOperationalEvidenceText(const FactoryOperationalEvidenceStatus &st)
{
   string out = "";
   out += "artifact_role=" + st.artifact_role + "\n";
   out += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   out += "summary_version=" + st.summary_version + "\n";
   out += "active_operating_cohort_id=" + st.active_operating_cohort_id + "\n";
   out += "active_operating_candidate_count=" + IntegerToString(st.active_operating_candidate_count) + "\n";
   out += "operating_cohort_admission_semantics=" + st.operating_cohort_admission_semantics + "\n";
   out += "evidence_scope=" + st.evidence_scope + "\n";
   out += "evidence_scope_note=" + st.evidence_scope_note + "\n";
   out += "decisions_total=" + IntegerToString(st.decisions_total) + "\n";
   out += "rejected_total=" + IntegerToString(st.rejected_total) + "\n";
   out += "waits_total=" + IntegerToString(st.waits_total) + "\n";
   out += "execution_total=" + IntegerToString(st.execution_total) + "\n";
   out += "closed_outcomes_total=" + IntegerToString(st.closed_outcomes_total) + "\n";
   out += "wins=" + IntegerToString(st.wins) + "\n";
   out += "losses=" + IntegerToString(st.losses) + "\n";
   out += "flat=" + IntegerToString(st.flat) + "\n";
   out += "win_rate=" + DoubleToString(st.win_rate, 3) + "\n";
   out += "net_realized_pl=" + DoubleToString(st.net_realized_pl, 2) + "\n";
   out += "last_trade_result=" + st.last_trade_result + "\n";
   out += "last_trade_time=" + st.last_trade_time + "\n";
   out += "last_executed_candidate_name=" + st.last_executed_candidate_name + "\n";
   out += "last_executed_candidate_family=" + st.last_executed_candidate_family + "\n";
   out += "evidence_completeness_state=" + st.evidence_completeness_state + "\n";
   out += "evidence_completeness_note=" + st.evidence_completeness_note + "\n";
   out += "lineage_note=" + st.lineage_note + "\n";
   out += "candidate_auto_promotion_allowed=" + DiagnosticBoolText(st.candidate_auto_promotion_allowed) + "\n";
   out += "candidate_auto_suppression_allowed=" + DiagnosticBoolText(st.candidate_auto_suppression_allowed) + "\n";
   out += "factory_classification_mutation_allowed=" + DiagnosticBoolText(st.factory_classification_mutation_allowed) + "\n";
   out += "last_refresh_time=" + DiagnosticTimeText(st.last_refresh_time) + "\n";
   return out;
}

string BuildFactoryOperationalEvidenceJson(const FactoryOperationalEvidenceStatus &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"active_operating_cohort_id\":\"" + JsonEscapeString(st.active_operating_cohort_id) + "\"";
   j += ",\"active_operating_candidate_count\":" + IntegerToString(st.active_operating_candidate_count);
   j += ",\"operating_cohort_admission_semantics\":\"" + JsonEscapeString(st.operating_cohort_admission_semantics) + "\"";
   j += ",\"evidence_scope\":\"" + JsonEscapeString(st.evidence_scope) + "\"";
   j += ",\"evidence_scope_note\":\"" + JsonEscapeString(st.evidence_scope_note) + "\"";
   j += ",\"decisions_total\":" + IntegerToString(st.decisions_total);
   j += ",\"rejected_total\":" + IntegerToString(st.rejected_total);
   j += ",\"waits_total\":" + IntegerToString(st.waits_total);
   j += ",\"execution_total\":" + IntegerToString(st.execution_total);
   j += ",\"closed_outcomes_total\":" + IntegerToString(st.closed_outcomes_total);
   j += ",\"wins\":" + IntegerToString(st.wins);
   j += ",\"losses\":" + IntegerToString(st.losses);
   j += ",\"flat\":" + IntegerToString(st.flat);
   j += ",\"win_rate\":" + DoubleToString(st.win_rate, 3);
   j += ",\"net_realized_pl\":" + DoubleToString(st.net_realized_pl, 2);
   j += ",\"last_trade_result\":\"" + JsonEscapeString(st.last_trade_result) + "\"";
   j += ",\"last_trade_time\":\"" + JsonEscapeString(st.last_trade_time) + "\"";
   j += ",\"last_executed_candidate_name\":\"" + JsonEscapeString(st.last_executed_candidate_name) + "\"";
   j += ",\"last_executed_candidate_family\":\"" + JsonEscapeString(st.last_executed_candidate_family) + "\"";
   j += ",\"evidence_completeness_state\":\"" + JsonEscapeString(st.evidence_completeness_state) + "\"";
   j += ",\"evidence_completeness_note\":\"" + JsonEscapeString(st.evidence_completeness_note) + "\"";
   j += ",\"lineage_note\":\"" + JsonEscapeString(st.lineage_note) + "\"";
   j += ",\"candidate_auto_promotion_allowed\":" + DiagnosticBoolText(st.candidate_auto_promotion_allowed);
   j += ",\"candidate_auto_suppression_allowed\":" + DiagnosticBoolText(st.candidate_auto_suppression_allowed);
   j += ",\"factory_classification_mutation_allowed\":" + DiagnosticBoolText(st.factory_classification_mutation_allowed);
   j += ",\"last_refresh_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.last_refresh_time)) + "\"";
   j += "}";
   return j;
}

void SaveFactoryOperationalEvidenceBestEffort(const FactoryOperationalEvidenceStatus &st)
{
   WriteTextFileAll(FactoryOperationalEvidenceTxtPath(), BuildFactoryOperationalEvidenceText(st));
   WriteTextFileAll(FactoryOperationalEvidenceJsonPath(), BuildFactoryOperationalEvidenceJson(st));
}

void EvaluateFactoryOperationalEvidenceStatus(FactoryOperationalEvidenceStatus &st)
{
   if(!gFactoryOperationalEvidenceInitialized)
      InitFactoryOperationalEvidenceStatus(st);

   InitFactoryOperationalEvidenceStatus(st);
   EvaluateActiveOperatingCohortStatus(gActiveOperatingCohort);
   EvaluateExecutionAuthorityStatus(gExecutionAuthorityStatus);

   st.active_operating_cohort_id = gActiveOperatingCohort.active_operating_cohort_id;
   st.active_operating_candidate_count = gActiveOperatingCohort.candidate_count;
   st.operating_cohort_admission_semantics = gActiveOperatingCohort.operating_cohort_admission_semantics;
   st.evidence_scope = "HISTORICAL_PLUS_CURRENT_RUNTIME_SUMMARY";
   st.evidence_scope_note = "Active cohort context is current, but displayed counts are derived from broader bounded runtime and journal surfaces rather than strict active-cohort-only evidence.";

   string validationJson = "";
   if(ReadTextFileAll(ExecutionQualityValidationJsonPath(), validationJson))
   {
      ExtractJsonIntField(validationJson, "decisions_total", st.decisions_total);
      ExtractJsonIntField(validationJson, "rejected_total", st.rejected_total);
      ExtractJsonIntField(validationJson, "waits_total", st.waits_total);
      ExtractJsonIntField(validationJson, "executed_trades_total", st.execution_total);
   }

   string journalText = "";
   bool journalPresent = ReadTextFileAll(PERF_JOURNAL_PATH, journalText);
   string tradeSummaryJson = "";
   if(journalPresent && DashboardBuildTradeJournalSummaryJson(journalText, tradeSummaryJson))
   {
      ExtractJsonIntField(tradeSummaryJson, "closed_trade_records", st.closed_outcomes_total);
      ExtractJsonIntField(tradeSummaryJson, "wins", st.wins);
      ExtractJsonIntField(tradeSummaryJson, "losses", st.losses);
      ExtractJsonIntField(tradeSummaryJson, "flat", st.flat);
      ExtractJsonDoubleField(tradeSummaryJson, "win_rate", st.win_rate);
      ExtractJsonDoubleField(tradeSummaryJson, "net_realized_pl", st.net_realized_pl);
      ExtractJsonStringField(tradeSummaryJson, "last_trade_result", st.last_trade_result);
      ExtractJsonStringField(tradeSummaryJson, "last_trade_time", st.last_trade_time);

      bool coveragePartial = true;
      ExtractJsonBoolField(tradeSummaryJson, "coverage_partial", coveragePartial);
      if(!journalPresent)
      {
         st.evidence_completeness_state = "MISSING";
         st.evidence_completeness_note = "Performance journal is missing; factory evidence loop cannot reconcile runtime activity.";
      }
      else if(coveragePartial || st.decisions_total <= 0)
      {
         st.evidence_completeness_state = "PARTIAL";
         st.evidence_completeness_note = "Runtime evidence is connected but remains partial; trade outcomes are journal-derived and decision attribution may be incomplete.";
      }
      else
      {
         st.evidence_completeness_state = "COHERENT";
         st.evidence_completeness_note = "Runtime decisions, executions, and closed outcomes are linked into a bounded factory-facing evidence summary.";
      }
   }
   else if(!journalPresent)
   {
      st.evidence_completeness_state = "MISSING";
      st.evidence_completeness_note = "Performance journal is missing; no runtime evidence could be derived for the factory loop.";
   }
   else
   {
      st.evidence_completeness_state = "PARTIAL";
      st.evidence_completeness_note = "Journal is present but the bounded trade summary could not be derived cleanly.";
   }

   st.last_executed_candidate_name = gExecutionAuthorityStatus.last_executed_candidate_name;
   st.last_executed_candidate_family = gExecutionAuthorityStatus.last_executed_candidate_family;
   if(StringLen(st.last_executed_candidate_name) == 0)
      st.last_executed_candidate_name = gLastExecutedCandidateName;
   if(StringLen(st.last_executed_candidate_family) == 0)
      st.last_executed_candidate_family = gLastExecutedCandidateFamily;

   st.lineage_note = "Live operation remains tied to active operating cohort " +
                     DashboardValueOr(st.active_operating_cohort_id, "UNDEFINED") +
                     " under " + DashboardValueOr(st.operating_cohort_admission_semantics, "FAMILY_LEVEL") +
                     " admission semantics; displayed evidence counts are broader bounded runtime summaries and remain evidence-only and non-mutative.";
   st.candidate_auto_promotion_allowed = false;
   st.candidate_auto_suppression_allowed = false;
   st.factory_classification_mutation_allowed = false;
   st.last_refresh_time = TimeCurrent();
}

void RefreshFactoryOperationalEvidenceBestEffort()
{
   EvaluateFactoryOperationalEvidenceStatus(gFactoryOperationalEvidence);
   SaveFactoryOperationalEvidenceBestEffort(gFactoryOperationalEvidence);
   gFactoryOperationalEvidenceInitialized = true;
}

void InitAIOperationalReviewStatus(AIOperationalReviewStatus &st)
{
   st.artifact_role = "AI_OPERATIONAL_REVIEW_STATUS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_AI_OPERATIONAL_REVIEW";
   st.summary_version = "O6_AI_OPERATIONAL_REVIEW_V2";
   st.authority_state = "AI_OFF";
   st.ai_operational_role = "SHADOW_ADVISORY_ONLY";
   st.advisory_scope_note = "AI remains shadow/advisory only and may not execute, veto, mutate runtime, or auto-apply learning.";
   st.repeated_reject_cluster_present = false;
   st.repeated_reject_cluster_family = "";
   st.repeated_reject_cluster_count = 0;
   st.no_trade_pattern_state = "SPARSE_ACTIVITY";
   st.drift_observation_state = "NO_CLEAR_DRIFT_SIGNAL";
   st.evidence_gap_state = "EVIDENCE_PARTIAL";
   st.advisory_sufficiency_state = "INSUFFICIENT";
   st.interpretability_state = "TOO_SPARSE";
   st.dominant_block_layer = "";
   st.dominant_reason_code = "";
   st.recent_window_decisions = 0;
   st.recent_window_rejects = 0;
   st.recent_window_waits = 0;
   st.dominant_regime_label = "";
   st.post_execution_context_note = "Recent runtime activity has not yet produced enough bounded evidence for a stronger AI operational review.";
   st.last_meaningful_event_type = "";
   st.last_meaningful_event_time = "";
   st.execution_authority_granted = false;
   st.trade_generation_authority = false;
   st.auto_apply_allowed = false;
   st.runtime_mutation_allowed = false;
   st.readiness_reference_state = "NOT_READY";
   st.readiness_alignment_state = "PENDING";
   st.review_independent_of_authority_readiness = true;
   st.review_implies_authority_ready = false;
   st.non_authoritative_notice = "AI output is bounded interpretation only; no execution authority, no trade generation authority, and no runtime mutation are allowed.";
   st.last_review_time = TimeCurrent();
}

string BuildAIOperationalReviewText(const AIOperationalReviewStatus &st)
{
   string out = "";
   out += "artifact_role=" + st.artifact_role + "\n";
   out += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   out += "summary_version=" + st.summary_version + "\n";
   out += "authority_state=" + st.authority_state + "\n";
   out += "ai_operational_role=" + st.ai_operational_role + "\n";
   out += "advisory_scope_note=" + st.advisory_scope_note + "\n";
   out += "repeated_reject_cluster_present=" + DiagnosticBoolText(st.repeated_reject_cluster_present) + "\n";
   out += "repeated_reject_cluster_family=" + st.repeated_reject_cluster_family + "\n";
   out += "repeated_reject_cluster_count=" + IntegerToString(st.repeated_reject_cluster_count) + "\n";
   out += "no_trade_pattern_state=" + st.no_trade_pattern_state + "\n";
   out += "drift_observation_state=" + st.drift_observation_state + "\n";
   out += "evidence_gap_state=" + st.evidence_gap_state + "\n";
   out += "advisory_sufficiency_state=" + st.advisory_sufficiency_state + "\n";
   out += "interpretability_state=" + st.interpretability_state + "\n";
   out += "dominant_block_layer=" + st.dominant_block_layer + "\n";
   out += "dominant_reason_code=" + st.dominant_reason_code + "\n";
   out += "recent_window_decisions=" + IntegerToString(st.recent_window_decisions) + "\n";
   out += "recent_window_rejects=" + IntegerToString(st.recent_window_rejects) + "\n";
   out += "recent_window_waits=" + IntegerToString(st.recent_window_waits) + "\n";
   out += "dominant_regime_label=" + st.dominant_regime_label + "\n";
   out += "post_execution_context_note=" + st.post_execution_context_note + "\n";
   out += "last_meaningful_event_type=" + st.last_meaningful_event_type + "\n";
   out += "last_meaningful_event_time=" + st.last_meaningful_event_time + "\n";
   out += "execution_authority_granted=" + DiagnosticBoolText(st.execution_authority_granted) + "\n";
   out += "trade_generation_authority=" + DiagnosticBoolText(st.trade_generation_authority) + "\n";
   out += "auto_apply_allowed=" + DiagnosticBoolText(st.auto_apply_allowed) + "\n";
   out += "runtime_mutation_allowed=" + DiagnosticBoolText(st.runtime_mutation_allowed) + "\n";
   out += "readiness_reference_state=" + st.readiness_reference_state + "\n";
   out += "readiness_alignment_state=" + st.readiness_alignment_state + "\n";
   out += "review_independent_of_authority_readiness=" + DiagnosticBoolText(st.review_independent_of_authority_readiness) + "\n";
   out += "review_implies_authority_ready=" + DiagnosticBoolText(st.review_implies_authority_ready) + "\n";
   out += "non_authoritative_notice=" + st.non_authoritative_notice + "\n";
   out += "last_review_time=" + DiagnosticTimeText(st.last_review_time) + "\n";
   return out;
}

string BuildAIOperationalReviewJson(const AIOperationalReviewStatus &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"authority_state\":\"" + JsonEscapeString(st.authority_state) + "\"";
   j += ",\"ai_operational_role\":\"" + JsonEscapeString(st.ai_operational_role) + "\"";
   j += ",\"advisory_scope_note\":\"" + JsonEscapeString(st.advisory_scope_note) + "\"";
   j += ",\"repeated_reject_cluster_present\":" + DiagnosticBoolText(st.repeated_reject_cluster_present);
   j += ",\"repeated_reject_cluster_family\":\"" + JsonEscapeString(st.repeated_reject_cluster_family) + "\"";
   j += ",\"repeated_reject_cluster_count\":" + IntegerToString(st.repeated_reject_cluster_count);
   j += ",\"no_trade_pattern_state\":\"" + JsonEscapeString(st.no_trade_pattern_state) + "\"";
   j += ",\"drift_observation_state\":\"" + JsonEscapeString(st.drift_observation_state) + "\"";
   j += ",\"evidence_gap_state\":\"" + JsonEscapeString(st.evidence_gap_state) + "\"";
   j += ",\"advisory_sufficiency_state\":\"" + JsonEscapeString(st.advisory_sufficiency_state) + "\"";
   j += ",\"interpretability_state\":\"" + JsonEscapeString(st.interpretability_state) + "\"";
   j += ",\"dominant_block_layer\":\"" + JsonEscapeString(st.dominant_block_layer) + "\"";
   j += ",\"dominant_reason_code\":\"" + JsonEscapeString(st.dominant_reason_code) + "\"";
   j += ",\"recent_window_decisions\":" + IntegerToString(st.recent_window_decisions);
   j += ",\"recent_window_rejects\":" + IntegerToString(st.recent_window_rejects);
   j += ",\"recent_window_waits\":" + IntegerToString(st.recent_window_waits);
   j += ",\"dominant_regime_label\":\"" + JsonEscapeString(st.dominant_regime_label) + "\"";
   j += ",\"post_execution_context_note\":\"" + JsonEscapeString(st.post_execution_context_note) + "\"";
   j += ",\"last_meaningful_event_type\":\"" + JsonEscapeString(st.last_meaningful_event_type) + "\"";
   j += ",\"last_meaningful_event_time\":\"" + JsonEscapeString(st.last_meaningful_event_time) + "\"";
   j += ",\"execution_authority_granted\":" + DiagnosticBoolText(st.execution_authority_granted);
   j += ",\"trade_generation_authority\":" + DiagnosticBoolText(st.trade_generation_authority);
   j += ",\"auto_apply_allowed\":" + DiagnosticBoolText(st.auto_apply_allowed);
   j += ",\"runtime_mutation_allowed\":" + DiagnosticBoolText(st.runtime_mutation_allowed);
   j += ",\"readiness_reference_state\":\"" + JsonEscapeString(st.readiness_reference_state) + "\"";
   j += ",\"readiness_alignment_state\":\"" + JsonEscapeString(st.readiness_alignment_state) + "\"";
   j += ",\"review_independent_of_authority_readiness\":" + DiagnosticBoolText(st.review_independent_of_authority_readiness);
   j += ",\"review_implies_authority_ready\":" + DiagnosticBoolText(st.review_implies_authority_ready);
   j += ",\"non_authoritative_notice\":\"" + JsonEscapeString(st.non_authoritative_notice) + "\"";
   j += ",\"last_review_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.last_review_time)) + "\"";
   j += "}";
   return j;
}

void SaveAIOperationalReviewBestEffort(const AIOperationalReviewStatus &st)
{
   WriteTextFileAll(AIOperationalReviewTxtPath(), BuildAIOperationalReviewText(st));
   WriteTextFileAll(AIOperationalReviewJsonPath(), BuildAIOperationalReviewJson(st));
}

void EvaluateAIOperationalReviewStatus(AIOperationalReviewStatus &st)
{
   if(!gAIOperationalReviewInitialized)
      InitAIOperationalReviewStatus(st);

   InitAIOperationalReviewStatus(st);
   EvaluateAIAuthorityReadinessState(gAIAuthorityReadiness);
   st.authority_state = gAIAuthorityReadiness.authority_state;
   st.readiness_reference_state = gAIAuthorityReadiness.readiness_state;
   st.readiness_alignment_state = gAIAuthorityReadiness.readiness_review_consistency_state;
   st.review_independent_of_authority_readiness = gAIAuthorityReadiness.review_surface_independent_of_authority;
   st.review_implies_authority_ready = gAIAuthorityReadiness.review_surface_implies_authority_ready;

   string journalText = "";
   RecentDecisionWindowSummary recent;
   if(ReadTextFileAll(PERF_JOURNAL_PATH, journalText))
      BuildRecentDecisionWindowSummary(journalText, recent, 80);
   else
      InitRecentDecisionWindowSummary(recent);

   st.recent_window_decisions = recent.sampled_decisions;
   st.recent_window_rejects = recent.reject_count;
   st.recent_window_waits = recent.wait_count;
   st.dominant_block_layer = recent.dominant_block_layer;
   st.dominant_reason_code = recent.dominant_reason_code;
   st.dominant_regime_label = recent.dominant_regime_label;
   st.repeated_reject_cluster_family = recent.dominant_rejection_family;
   st.repeated_reject_cluster_count = recent.dominant_rejection_family_count;
   st.repeated_reject_cluster_present = (recent.reject_count >= 3 && recent.dominant_rejection_family_count >= 3);

   string validationJson = "";
   if(ReadTextFileAll(ExecutionQualityValidationJsonPath(), validationJson))
   {
      ExtractJsonStringField(validationJson, "dominant_rejection_family", st.repeated_reject_cluster_family);
      ExtractJsonStringField(validationJson, "dominant_block_layer", st.dominant_block_layer);
   }

   string lastEventJson = "";
   if(ReadTextFileAll(LastMeaningfulRuntimeEventJsonPath(), lastEventJson))
   {
      ExtractJsonStringField(lastEventJson, "event_type", st.last_meaningful_event_type);
      ExtractJsonStringField(lastEventJson, "event_time", st.last_meaningful_event_time);
      string lastEventReason = "";
      if(ExtractJsonStringField(lastEventJson, "reason_code", lastEventReason) &&
         StringLen(TrimString(lastEventReason)) > 0 &&
         StringLen(TrimString(st.dominant_reason_code)) == 0)
      {
         st.dominant_reason_code = lastEventReason;
      }
   }

   string diagnosticJson = "";
   if(ReadTextFileAll(DiagnosticRuntimeSummaryJsonPath(), diagnosticJson))
   {
      string diagnosticDecision = "";
      ExtractJsonStringField(diagnosticJson, "final_decision", diagnosticDecision);
      StringToUpper(diagnosticDecision);

      if(diagnosticDecision == "REJECT" ||
         diagnosticDecision == "WAIT" ||
         diagnosticDecision == "GUARDRAIL_BLOCK" ||
         diagnosticDecision == "BUY" ||
         diagnosticDecision == "SELL")
      {
         string diagnosticLayer = "";
         string diagnosticReason = "";
         string diagnosticTime = "";

         ExtractJsonStringField(diagnosticJson, "final_blocking_layer", diagnosticLayer);
         ExtractJsonStringField(diagnosticJson, "final_block_reason_code", diagnosticReason);
         ExtractJsonStringField(diagnosticJson, "evaluated_at", diagnosticTime);

         if(StringLen(TrimString(diagnosticLayer)) > 0)
            st.dominant_block_layer = diagnosticLayer;
         if(StringLen(TrimString(diagnosticReason)) > 0)
            st.dominant_reason_code = diagnosticReason;
         if(StringLen(TrimString(st.last_meaningful_event_type)) == 0)
            st.last_meaningful_event_type = (diagnosticDecision == "BUY" || diagnosticDecision == "SELL" ? "EXECUTION" : diagnosticDecision);
         if(StringLen(TrimString(st.last_meaningful_event_time)) == 0)
            st.last_meaningful_event_time = diagnosticTime;
      }
   }

   if(gFactoryOperationalEvidenceInitialized == false)
      RefreshFactoryOperationalEvidenceBestEffort();

   if(gFactoryOperationalEvidence.evidence_completeness_state == "COHERENT")
      st.evidence_gap_state = "NO_MATERIAL_EVIDENCE_GAP";
   else if(gFactoryOperationalEvidence.evidence_completeness_state == "MISSING")
      st.evidence_gap_state = "MISSING_RUNTIME_EVIDENCE";
   else
      st.evidence_gap_state = "EVIDENCE_PARTIAL";

   if(recent.wait_count >= 5 && recent.wait_count >= recent.reject_count)
      st.no_trade_pattern_state = "PERSISTENT_WAIT_CLUSTER";
   else if(recent.sampled_decisions <= 0)
      st.no_trade_pattern_state = "NO_RECENT_DECISION_WINDOW";
   else if(recent.wait_count > 0)
      st.no_trade_pattern_state = "INTERMITTENT_NO_TRADE";
   else
      st.no_trade_pattern_state = "NO_MATERIAL_WAIT_PATTERN";

   if(st.repeated_reject_cluster_present && recent.dominant_regime_count >= 3)
      st.drift_observation_state = "POSSIBLE_REGIME_MISMATCH_OBSERVED";
   else if(recent.distinct_regime_count >= 4 && recent.reject_count > recent.approved_or_executed_count)
      st.drift_observation_state = "REGIME_TRANSITION_NOISE_OBSERVED";
   else
      st.drift_observation_state = "NO_CLEAR_DRIFT_SIGNAL";

   if(recent.sampled_decisions >= 12)
   {
      st.advisory_sufficiency_state = "SUFFICIENT_FOR_BOUNDED_REVIEW";
      st.interpretability_state = (recent.distinct_regime_count >= 4 ? "NOISY_BUT_INTERPRETABLE" : "INTERPRETABLE");
   }
   else if(recent.sampled_decisions >= 4)
   {
      st.advisory_sufficiency_state = "LIMITED";
      st.interpretability_state = "SPARSE";
   }
   else
   {
      st.advisory_sufficiency_state = "INSUFFICIENT";
      st.interpretability_state = "TOO_SPARSE";
   }

   if(StringLen(TrimString(gFactoryOperationalEvidence.last_trade_result)) > 0)
      st.post_execution_context_note = "Latest closed-trade outcome is " + gFactoryOperationalEvidence.last_trade_result +
                                       " at " + DashboardValueOr(gFactoryOperationalEvidence.last_trade_time, "unknown time") +
                                       "; interpretation remains bounded and non-authoritative.";
   else if(StringLen(TrimString(st.last_meaningful_event_type)) > 0)
      st.post_execution_context_note = "Latest meaningful event is " + st.last_meaningful_event_type +
                                       " at " + DashboardValueOr(st.last_meaningful_event_time, "unknown time") +
                                       "; current AI role is explanatory only and does not alter authority.";
   else
      st.post_execution_context_note = "Recent activity is too sparse for a stronger AI contextual note.";

   st.execution_authority_granted = false;
   st.trade_generation_authority = false;
   st.auto_apply_allowed = false;
   st.runtime_mutation_allowed = false;
   st.last_review_time = TimeCurrent();
}

void RefreshAIOperationalReviewBestEffort()
{
   RefreshLastMeaningfulRuntimeEventFromCurrentPostureBestEffort();
   EvaluateAIOperationalReviewStatus(gAIOperationalReview);
   SaveAIOperationalReviewBestEffort(gAIOperationalReview);
   gAIOperationalReviewInitialized = true;
}

void RefreshOperationalizationLoopArtifactsBestEffort()
{
   RefreshLastMeaningfulRuntimeEventFromCurrentPostureBestEffort();
   RefreshFactoryOperationalEvidenceBestEffort();
   RefreshAIOperationalReviewBestEffort();
   RefreshOperationalIntegrityStatusBestEffort();
}

struct SourceIntakeGatewayStatusState
{
   bool     gateway_file_present;
   bool     gateway_parse_ok;
   bool     gateway_update_detected;
   string   gateway_last_seen_update_id;
   string   gateway_last_seen_modified_time;
   string   gateway_last_seen_hash;
   int      gateway_record_count;
   string   gateway_processing_mode;
   string   gateway_contract_version;
   string   gateway_schema_version;
   string   gateway_version;
   string   gateway_snapshot_identity;
   string   gateway_producer_role;
   string   gateway_snapshot_updated_at;
   bool     gateway_pending_review;
   bool     direct_factory_commit_allowed;
   bool     auto_import_allowed;
   bool     runtime_trading_impact;
   datetime last_detection_time;
   string   last_error_code_or_note;
};

static SourceIntakeGatewayStatusState gSourceIntakeGatewayStatus;
static bool gSourceIntakeGatewayStatusLoaded = false;
static datetime gSourceIntakeGatewayLastPollTime = 0;

//---------------------------------------------------------
// AI council advisory integration (A6)
//---------------------------------------------------------
struct CouncilAIAdvisoryPacket
{
   bool     valid;
   string   invocation_state;
   string   invocation_reason_code;
   string   advisory_packet_id;
   string   advisory_state;
   double   advisory_confidence;
   double   evidence_strength;
   int      corroboration_count;
   string   advisory_reason_codes_csv;
   string   rationale_short;
   string   candidate_scope;
   string   candidate_decision_id;
   string   candidate_direction;
   string   relevant_zone;
   string   relevant_strategy_family;
   bool     execution_instability_flag;
   bool     strategy_family_weakening_flag;
   bool     severe_recent_pattern_deterioration_flag;
   bool     anomaly_cluster_high_severity_flag;
   bool     recent_similar_case_failure_bias_flag;
   string   advisory_freshness;
   string   evidence_limitations;
   string   recommended_action_class;
   bool     direct_control_allowed;
   bool     directional_generation_allowed;
   bool     reserved_future_state_only;
   string   raw_response;
   datetime evaluated_at;
};

struct CouncilAIAdvisoryRelevanceGateResult
{
   string   gate_outcome; // IGNORE_ADVISORY / DISPLAY_ONLY / FLAG_FOR_OPERATOR / HOLD_FOR_REEVALUATION / BLOCK_CANDIDATE
   string   gate_reason_code;
   string   strict_reason_families_csv;
   bool     advisory_considered;
   bool     operational_influence_allowed;
   bool     hold_applied;
   bool     block_applied;
   bool     block_mode_enabled;
   bool     strict_conditions_satisfied;
   int      effective_hold_bars;
   int      effective_corroboration_count;
   double   hold_confidence_threshold;
   double   hold_evidence_threshold;
   int      hold_corroboration_threshold;
   double   block_confidence_threshold;
   double   block_evidence_threshold;
   int      block_corroboration_threshold;
   string   note;
   datetime evaluated_at;
};

struct CouncilAIAdvisoryHoldState
{
   bool     active;
   string   candidate_signature;
   string   decision_id;
   string   direction;
   string   advisory_packet_id;
   string   hold_reason_code;
   datetime held_at;
   int      release_bar_index;
   int      holds_used_for_signature;
   int      signature_anchor_bar_index;
};

struct CouncilAIAdvisoryStatus
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   trust_rule;
   string   update_source;

   string   authority_state;
   string   readiness_state;
   bool     advisory_integration_enabled;
   bool     advisory_invocation_allowed;
   bool     operational_influence_allowed;

   string   advisory_packet_schema_state;
   string   advisory_packet_id;
   string   advisory_state;
   double   advisory_confidence;
   double   evidence_strength;
   int      corroboration_count;
   string   advisory_reason_codes_csv;
   string   rationale_short;
   string   candidate_scope;
   string   candidate_decision_id;
   string   candidate_direction;
   string   relevant_zone;
   string   relevant_strategy_family;
   string   advisory_freshness;
   string   evidence_limitations;
   string   recommended_action_class;

   bool     execution_instability_flag;
   bool     strategy_family_weakening_flag;
   bool     severe_recent_pattern_deterioration_flag;
   bool     anomaly_cluster_high_severity_flag;
   bool     recent_similar_case_failure_bias_flag;

   string   relevance_gate_outcome;
   string   relevance_gate_reason_code;
   string   strict_reason_families_csv;
   bool     hold_applied;
   bool     block_applied;
   bool     block_mode_enabled;

   int      effective_hold_bars;
   int      effective_hold_limit_per_signature;
   double   effective_hold_confidence_threshold;
   double   effective_hold_evidence_threshold;
   int      effective_hold_corroboration_threshold;
   double   effective_block_confidence_threshold;
   double   effective_block_evidence_threshold;
   int      effective_block_corroboration_threshold;

   bool     current_hold_active;
   string   current_hold_signature;
   int      current_hold_release_bar_index;
   int      current_hold_count_for_signature;

   string   non_authoritative_notice;
   datetime evaluated_at;
};

struct CouncilAIAdvisoryEffectivenessSummary
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   review_window_note;
   string   note;

   int      advisory_total;
   int      advisory_ok_total;
   int      advisory_caution_total;
   int      advisory_strong_caution_total;
   int      advisory_insufficient_evidence_total;
   int      advisory_hold_total;
   int      advisory_block_eligible_total;
   int      advisory_block_applied_total;

   bool     advisory_block_enabled;

   int      hold_then_trade_total;
   int      hold_then_drop_total;
   int      blocked_loss_prevention_count;
   int      blocked_win_penalty_count;
   bool     false_block_risk_unknown;
   string   advisory_effectiveness_confidence;
   datetime rebuilt_at;
};

static CouncilAIAdvisoryStatus gCouncilAIAdvisoryStatus;
static bool gCouncilAIAdvisoryStatusInitialized = false;

static CouncilAIAdvisoryEffectivenessSummary gCouncilAIAdvisoryEffectiveness;
static bool gCouncilAIAdvisoryEffectivenessInitialized = false;

static CouncilAIAdvisoryHoldState gCouncilAIAdvisoryHold;
static bool gCouncilAIAdvisoryHoldInitialized = false;

//---------------------------------------------------------
// ATAS governed advisory integration (Level 3)
//---------------------------------------------------------
static AtasGovernedAdvisoryStatus gAtasGovernedAdvisoryStatus;
static bool gAtasGovernedAdvisoryStatusInitialized = false;

static AtasGovernedAdvisoryEffectiveness gAtasGovernedAdvisoryEffectiveness;
static bool gAtasGovernedAdvisoryEffectivenessInitialized = false;

static AtasGovernedAdvisoryHoldState gAtasGovernedAdvisoryHold;
static bool gAtasGovernedAdvisoryHoldInitialized = false;

//---------------------------------------------------------
// Observability & diagnostic reliability hardening (H2)
//---------------------------------------------------------
struct DiagnosticRuntimeSummary
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   update_source;

   string   governance_state;
   bool     trading_allowed;
   bool     degraded_mode;
   bool     truth_ready;
   bool     diagnostics_ready;
   bool     rollback_recently_applied;
   string   governance_reason_code;

   string   active_plan_id;
   string   active_mode;

   string   final_decision;
   bool     final_blocked;
   string   final_blocking_layer;
   string   final_block_reason_code;

   string   dominant_failure;
   string   dominant_failure_source;
   string   dominant_failure_pressure;

   string   zone_name;
   string   best_strategy_id;
   string   consensus_label;
   string   governor_state;
   string   zone_coverage_label;
   string   lifecycle_state;

   double   consensus_strength;
   double   conflict_score;
   double   council_quality;
   double   environment_score;

   string   decision_id;
   string   execution_path;

   string   last_open_decision_id;
   ulong    last_open_position_id;
   ulong    last_open_entry_deal_id;

   string   last_close_decision_id;
   ulong    last_close_position_id;
   ulong    last_close_deal_id;
   string   last_close_trade_result;
   double   last_close_profit;
   datetime last_close_time;

   string   note;
   datetime evaluated_at;
};

static DiagnosticRuntimeSummary gDiagnosticRuntimeSummary;
static bool gDiagnosticRuntimeSummaryInitialized = false;

struct ReplayValidationSummary
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   trust_rule;
   string   update_source;

   string   replay_case_type;
   string   replay_case_scope;

   string   governance_state;
   bool     trading_allowed;

   string   active_plan_id;
   string   active_mode;

   string   regime_label;
   double   regime_confidence;

   string   zone_name;
   string   best_strategy_id;
   string   consensus_label;
   double   consensus_strength;
   double   conflict_score;
   double   council_quality;
   double   environment_score;

   string   dominant_failure;
   string   dominant_failure_source;
   string   dominant_failure_pressure;

   string   final_decision;
   string   final_blocking_layer;
   string   final_block_reason_code;
   string   execution_path;

   string   decision_id;
   string   correlated_decision_id;
   ulong    position_id;
   ulong    entry_deal_id;
   ulong    close_deal_id;
   string   trade_result;
   double   close_profit;

   datetime decision_time;
   datetime open_time;
   datetime close_time;
   datetime evaluated_at;

   string   replay_confidence;
   string   replay_data_limitations;
};

static ReplayValidationSummary gReplayValidationSummary;
static bool gReplayValidationSummaryInitialized = false;

void RefreshReplayValidationArtifactsBestEffort();
void RefreshAIActivationReadinessStatusBestEffort();
void RefreshAIOperationalReviewBestEffort();
void RefreshOperationalIntegrityStatusBestEffort();


//---------------------------------------------------------
// Decision identity linkage (Phase 1 ? Truth Linkage Repair Pack)
//---------------------------------------------------------
//---------------------------------------------------------
void EnsureCurrentDecisionId()
{
   if(StringLen(gCurrentDecisionId) <= 0)
      gCurrentDecisionId = PJ_MakeDecisionId();
}

//---------------------------------------------------------
// Council setup lifecycle (opt-in; COUNCIL only; behavior-preserving when disabled)
//---------------------------------------------------------
struct CouncilSetupLifecycleState
{
   bool     active;
   string   state_name; // ARMED / TRIGGER_READY / EXECUTED / INVALIDATED / EXPIRED
   string   direction;  // BUY / SELL
   string   decision_id;
   string   strategy_id;
   string   strategy_family;
   string   zone_name;
   datetime created_bar_time;
   datetime last_seen_bar_time;
   int      created_bar_index;
   int      last_seen_bar_index;
   int      confirmation_bars_seen;
   int      expiry_bar_index;
   double   council_quality;
   double   consensus_strength;
   double   environment_score;
   string   invalidation_reason;
};

static CouncilSetupLifecycleState gCouncilSetupLifecycle;
static bool gCouncilSetupLifecycleLoaded = false;

string CouncilSetupLifecycleStatePath()  { return "AI\\council_setup_lifecycle_state.json"; }
string CouncilSetupLifecycleStatusPath() { return "AI\\council_setup_lifecycle_status.txt"; }

int CouncilM1BarIndex(const datetime bar_time)
{
   return (int)(bar_time / 60);
}

string JsonEscapeString(const string s)
{
   string out = s;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\r", "\\r");
   StringReplace(out, "\n", "\\n");
   return out;
}

void InitCouncilSetupLifecycleState(CouncilSetupLifecycleState &st)
{
   st.active = false;
   st.state_name = "";
   st.direction = "";
   st.decision_id = "";
   st.strategy_id = "";
   st.strategy_family = "";
   st.zone_name = "";
   st.created_bar_time = (datetime)0;
   st.last_seen_bar_time = (datetime)0;
   st.created_bar_index = 0;
   st.last_seen_bar_index = 0;
   st.confirmation_bars_seen = 0;
   st.expiry_bar_index = 0;
   st.council_quality = 0.0;
   st.consensus_strength = 0.0;
   st.environment_score = 0.0;
   st.invalidation_reason = "";
}

bool ReadTextFileAll(const string rel_path, string &outText)
{
   outText = "";
   int h = FileOpen(rel_path, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   outText = FileReadString(h);
   while(!FileIsEnding(h))
      outText += FileReadString(h);
   FileClose(h);
   return true;
}

bool WriteTextFileAll(const string rel_path, const string text)
{
   int h = FileOpen(rel_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileWriteString(h, text);
   FileClose(h);
   return true;
}


void InitSourceIntakeGatewayStatusState(SourceIntakeGatewayStatusState &st)
{
   st.gateway_file_present = false;
   st.gateway_parse_ok = false;
   st.gateway_update_detected = false;
   st.gateway_last_seen_update_id = "";
   st.gateway_last_seen_modified_time = "0";
   st.gateway_last_seen_hash = "";
   st.gateway_record_count = 0;
   st.gateway_processing_mode = "DETECTION_ONLY";
   st.gateway_contract_version = "";
   st.gateway_schema_version = "";
   st.gateway_version = "";
   st.gateway_snapshot_identity = "";
   st.gateway_producer_role = "";
   st.gateway_snapshot_updated_at = "";
   st.gateway_pending_review = false;
   st.direct_factory_commit_allowed = false;
   st.auto_import_allowed = false;
   st.runtime_trading_impact = false;
   st.last_detection_time = 0;
   st.last_error_code_or_note = "";
}

int CountStringOccurrences(const string haystack, const string needle)
{
   if(StringLen(needle) <= 0)
      return 0;

   int count = 0;
   int pos = 0;
   while(true)
   {
      pos = StringFind(haystack, needle, pos);
      if(pos < 0)
         break;
      count++;
      pos += StringLen(needle);
   }
   return count;
}

string SourceIntakeGatewayHash64(const string text)
{
   ulong hash = 1469598103934665603;
   for(int i = 0; i < StringLen(text); i++)
   {
      hash ^= (ulong)StringGetCharacter(text, i);
      hash *= 1099511628211;
   }
   return DiagnosticU64(hash);
}

bool SourceIntakeGatewayExtractUpdateId(const string json, string &updateId)
{
   updateId = "";
   if(ExtractJsonStringField(json, "update_id", updateId))
      return true;
   if(ExtractJsonStringField(json, "gateway_update_id", updateId))
      return true;
   if(ExtractJsonStringField(json, "snapshot_update_id", updateId))
      return true;
   updateId = "";
   return false;
}

bool SourceIntakeGatewayExtractRecordCount(const string json, int &recordCount)
{
   recordCount = 0;
   if(ExtractJsonIntField(json, "gateway_record_count", recordCount))
      return true;
   if(ExtractJsonIntField(json, "record_count", recordCount))
      return true;

   recordCount = CountStringOccurrences(json, "\"intake_record_id\"");
   return true;
}

void SourceIntakeGatewayExtractOperationalMetadata(const string json,
                                                  string &gatewayContractVersion,
                                                  string &gatewaySchemaVersion,
                                                  string &gatewayVersion,
                                                  string &snapshotIdentity,
                                                  string &producerRole,
                                                  string &snapshotUpdatedAt)
{
   gatewayContractVersion = "";
   gatewaySchemaVersion = "";
   gatewayVersion = "";
   snapshotIdentity = "";
   producerRole = "";
   snapshotUpdatedAt = "";

   ExtractJsonStringField(json, "gateway_contract_version", gatewayContractVersion);
   ExtractJsonStringField(json, "source_intake_gateway_rich_hybrid_schema_version", gatewaySchemaVersion);
   ExtractJsonStringField(json, "gateway_version", gatewayVersion);
   if(!ExtractJsonStringField(json, "snapshot_identity", snapshotIdentity))
      ExtractJsonStringField(json, "update_id", snapshotIdentity);
   ExtractJsonStringField(json, "producer_role", producerRole);
   if(!ExtractJsonStringField(json, "updated_at", snapshotUpdatedAt))
      ExtractJsonStringField(json, "snapshot_time", snapshotUpdatedAt);
}

string BuildSourceIntakeGatewayStatusText(const SourceIntakeGatewayStatusState &st)
{
   string out = "";
   out += "artifact_role=SOURCE_INTAKE_GATEWAY_STATUS\n";
   out += "artifact_authority_class=NON_AUTHORITATIVE_GATEWAY_DETECTION_STATUS\n";
   out += "gateway_file_present=" + DiagnosticBoolText(st.gateway_file_present) + "\n";
   out += "gateway_parse_ok=" + DiagnosticBoolText(st.gateway_parse_ok) + "\n";
   out += "gateway_update_detected=" + DiagnosticBoolText(st.gateway_update_detected) + "\n";
   out += "gateway_last_seen_update_id=" + st.gateway_last_seen_update_id + "\n";
   out += "gateway_last_seen_modified_time=" + st.gateway_last_seen_modified_time + "\n";
   out += "gateway_last_seen_hash=" + st.gateway_last_seen_hash + "\n";
   out += "gateway_record_count=" + IntegerToString(st.gateway_record_count) + "\n";
   out += "gateway_processing_mode=" + st.gateway_processing_mode + "\n";
   out += "gateway_contract_version=" + st.gateway_contract_version + "\n";
   out += "gateway_schema_version=" + st.gateway_schema_version + "\n";
   out += "gateway_version=" + st.gateway_version + "\n";
   out += "gateway_snapshot_identity=" + st.gateway_snapshot_identity + "\n";
   out += "gateway_producer_role=" + st.gateway_producer_role + "\n";
   out += "gateway_snapshot_updated_at=" + st.gateway_snapshot_updated_at + "\n";
   out += "gateway_pending_review=" + DiagnosticBoolText(st.gateway_pending_review) + "\n";
   out += "direct_factory_commit_allowed=" + DiagnosticBoolText(st.direct_factory_commit_allowed) + "\n";
   out += "auto_import_allowed=" + DiagnosticBoolText(st.auto_import_allowed) + "\n";
   out += "runtime_trading_impact=" + DiagnosticBoolText(st.runtime_trading_impact) + "\n";
   out += "last_detection_time=" + DiagnosticTimeText(st.last_detection_time) + "\n";
   out += "last_error_code_or_note=" + st.last_error_code_or_note + "\n";
   return out;
}

string BuildSourceIntakeGatewayStatusJson(const SourceIntakeGatewayStatusState &st)
{
   string j = "{";
   j += "\"artifact_role\":\"SOURCE_INTAKE_GATEWAY_STATUS\"";
   j += ",\"artifact_authority_class\":\"NON_AUTHORITATIVE_GATEWAY_DETECTION_STATUS\"";
   j += ",\"gateway_file_present\":" + (st.gateway_file_present ? "true" : "false");
   j += ",\"gateway_parse_ok\":" + (st.gateway_parse_ok ? "true" : "false");
   j += ",\"gateway_update_detected\":" + (st.gateway_update_detected ? "true" : "false");
   j += ",\"gateway_last_seen_update_id\":\"" + JsonEscapeString(st.gateway_last_seen_update_id) + "\"";
   j += ",\"gateway_last_seen_modified_time\":\"" + JsonEscapeString(st.gateway_last_seen_modified_time) + "\"";
   j += ",\"gateway_last_seen_hash\":\"" + JsonEscapeString(st.gateway_last_seen_hash) + "\"";
   j += ",\"gateway_record_count\":" + IntegerToString(st.gateway_record_count);
   j += ",\"gateway_processing_mode\":\"" + JsonEscapeString(st.gateway_processing_mode) + "\"";
   j += ",\"gateway_contract_version\":\"" + JsonEscapeString(st.gateway_contract_version) + "\"";
   j += ",\"gateway_schema_version\":\"" + JsonEscapeString(st.gateway_schema_version) + "\"";
   j += ",\"gateway_version\":\"" + JsonEscapeString(st.gateway_version) + "\"";
   j += ",\"gateway_snapshot_identity\":\"" + JsonEscapeString(st.gateway_snapshot_identity) + "\"";
   j += ",\"gateway_producer_role\":\"" + JsonEscapeString(st.gateway_producer_role) + "\"";
   j += ",\"gateway_snapshot_updated_at\":\"" + JsonEscapeString(st.gateway_snapshot_updated_at) + "\"";
   j += ",\"gateway_pending_review\":" + (st.gateway_pending_review ? "true" : "false");
   j += ",\"direct_factory_commit_allowed\":" + (st.direct_factory_commit_allowed ? "true" : "false");
   j += ",\"auto_import_allowed\":" + (st.auto_import_allowed ? "true" : "false");
   j += ",\"runtime_trading_impact\":" + (st.runtime_trading_impact ? "true" : "false");
   j += ",\"last_detection_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.last_detection_time)) + "\"";
   j += ",\"last_error_code_or_note\":\"" + JsonEscapeString(st.last_error_code_or_note) + "\"";
   j += "}";
   return j;
}

void SaveSourceIntakeGatewayStatusBestEffort(const SourceIntakeGatewayStatusState &st)
{
   WriteTextFileAll(SourceIntakeGatewayStatusTxtPath(), BuildSourceIntakeGatewayStatusText(st));
   WriteTextFileAll(SourceIntakeGatewayStatusJsonPath(), BuildSourceIntakeGatewayStatusJson(st));
}

bool LoadSourceIntakeGatewayStatusBestEffort(SourceIntakeGatewayStatusState &st)
{
   InitSourceIntakeGatewayStatusState(st);

   string raw = "";
   if(!ReadTextFileAll(SourceIntakeGatewayStatusJsonPath(), raw))
      return false;

   ExtractJsonBoolField(raw, "gateway_file_present", st.gateway_file_present);
   ExtractJsonBoolField(raw, "gateway_parse_ok", st.gateway_parse_ok);
   ExtractJsonBoolField(raw, "gateway_update_detected", st.gateway_update_detected);
   ExtractJsonStringField(raw, "gateway_last_seen_update_id", st.gateway_last_seen_update_id);
   ExtractJsonStringField(raw, "gateway_last_seen_modified_time", st.gateway_last_seen_modified_time);
   ExtractJsonStringField(raw, "gateway_last_seen_hash", st.gateway_last_seen_hash);
   ExtractJsonIntField(raw, "gateway_record_count", st.gateway_record_count);
   ExtractJsonStringField(raw, "gateway_processing_mode", st.gateway_processing_mode);
   ExtractJsonStringField(raw, "gateway_contract_version", st.gateway_contract_version);
   ExtractJsonStringField(raw, "gateway_schema_version", st.gateway_schema_version);
   ExtractJsonStringField(raw, "gateway_version", st.gateway_version);
   ExtractJsonStringField(raw, "gateway_snapshot_identity", st.gateway_snapshot_identity);
   ExtractJsonStringField(raw, "gateway_producer_role", st.gateway_producer_role);
   ExtractJsonStringField(raw, "gateway_snapshot_updated_at", st.gateway_snapshot_updated_at);
   ExtractJsonBoolField(raw, "gateway_pending_review", st.gateway_pending_review);
   ExtractJsonBoolField(raw, "direct_factory_commit_allowed", st.direct_factory_commit_allowed);
   ExtractJsonBoolField(raw, "auto_import_allowed", st.auto_import_allowed);
   ExtractJsonBoolField(raw, "runtime_trading_impact", st.runtime_trading_impact);

   string t = "";
   if(ExtractJsonStringField(raw, "last_detection_time", t))
      st.last_detection_time = DiagnosticParseTimeText(t);

   ExtractJsonStringField(raw, "last_error_code_or_note", st.last_error_code_or_note);
   return true;
}

void PollSourceIntakeGatewayBestEffort(const bool force=false)
{
   if(!gSourceIntakeGatewayStatusLoaded)
   {
      InitSourceIntakeGatewayStatusState(gSourceIntakeGatewayStatus);
      LoadSourceIntakeGatewayStatusBestEffort(gSourceIntakeGatewayStatus);
      gSourceIntakeGatewayStatusLoaded = true;
   }

   datetime now = TimeCurrent();
   if(!force && gSourceIntakeGatewayLastPollTime > 0 && (now - gSourceIntakeGatewayLastPollTime) < 15)
      return;

   gSourceIntakeGatewayLastPollTime = now;

   SourceIntakeGatewayStatusState next = gSourceIntakeGatewayStatus;
   next.gateway_update_detected = false;
   next.gateway_processing_mode = "DETECTION_ONLY";
   next.direct_factory_commit_allowed = false;
   next.auto_import_allowed = false;
   next.runtime_trading_impact = false;
   next.last_detection_time = now;

   if(!FileIsExist(SourceIntakeGatewayPath()))
   {
      next.gateway_file_present = false;
      next.gateway_parse_ok = false;
      next.gateway_record_count = 0;
      next.gateway_pending_review = false;
      next.last_error_code_or_note = "gateway_file_missing";
      SaveSourceIntakeGatewayStatusBestEffort(next);
      gSourceIntakeGatewayStatus = next;
      return;
   }

   next.gateway_file_present = true;

   string raw = "";
   if(!ReadTextFileAll(SourceIntakeGatewayPath(), raw) || StringLen(TrimString(raw)) <= 2)
   {
      next.gateway_parse_ok = false;
      next.gateway_pending_review = false;
      next.last_error_code_or_note = "gateway_read_failed_or_empty";
      SaveSourceIntakeGatewayStatusBestEffort(next);
      gSourceIntakeGatewayStatus = next;
      return;
   }

   string artifactRole = "";
   if(!ExtractJsonStringField(raw, "artifact_role", artifactRole) || TrimString(artifactRole) != "SOURCE_INTAKE_GATEWAY")
   {
      next.gateway_parse_ok = false;
      next.gateway_pending_review = false;
      next.last_error_code_or_note = "gateway_json_malformed_or_role_missing";
      SaveSourceIntakeGatewayStatusBestEffort(next);
      gSourceIntakeGatewayStatus = next;
      return;
   }

   next.gateway_parse_ok = true;

   string updateId = "";
   SourceIntakeGatewayExtractUpdateId(raw, updateId);

   int recordCount = 0;
   SourceIntakeGatewayExtractRecordCount(raw, recordCount);
   next.gateway_record_count = recordCount;

   SourceIntakeGatewayExtractOperationalMetadata(raw,
                                                 next.gateway_contract_version,
                                                 next.gateway_schema_version,
                                                 next.gateway_version,
                                                 next.gateway_snapshot_identity,
                                                 next.gateway_producer_role,
                                                 next.gateway_snapshot_updated_at);

   string hash = SourceIntakeGatewayHash64(raw);

   bool isNewUpdate = false;
   if(StringLen(updateId) > 0 && updateId != gSourceIntakeGatewayStatus.gateway_last_seen_update_id)
      isNewUpdate = true;
   else if(hash != gSourceIntakeGatewayStatus.gateway_last_seen_hash)
      isNewUpdate = true;

   if(StringLen(updateId) > 0)
      next.gateway_last_seen_update_id = updateId;
   next.gateway_last_seen_hash = hash;
   next.gateway_last_seen_modified_time = "UNAVAILABLE_NOT_CAPTURED";
   next.gateway_pending_review = (recordCount > 0);

   if(isNewUpdate)
   {
      next.gateway_update_detected = true;
      next.last_error_code_or_note = "ok_new_update_detected";
      LogInfo("Source intake gateway update detected | update_id=" +
              (StringLen(updateId) > 0 ? updateId : "HASH_ONLY") +
              " | records=" + IntegerToString(recordCount) +
              " | mode=DETECTION_ONLY");
   }
   else
   {
      next.last_error_code_or_note = "ok_no_new_update";
   }

   SaveSourceIntakeGatewayStatusBestEffort(next);
   gSourceIntakeGatewayStatus = next;
}

// Truth integrity policy (S1):
// - AI\ai_current_plan.json is the only authoritative source of active plan truth.
// - AI\ai_evolution_state.json is derived state and must mirror the authoritative active plan id.
// - AI\ai_previous_plan_backup.json is rollback-only backup state and is never authoritative.
string TruthCurrentPlanPath()         { return "AI\\ai_current_plan.json"; }
string TruthEvolutionStatePath()      { return "AI\\ai_evolution_state.json"; }
string TruthPreviousPlanBackupPath()  { return "AI\\ai_previous_plan_backup.json"; }

string RuntimeGovernanceStatusTxtPath()   { return "AI\\runtime_governance_status.txt"; }
string RuntimeGovernanceStatusJsonPath()  { return "AI\\runtime_governance_status.json"; }

string RiskSafetyStatusTxtPath()          { return "AI\\risk_safety_status.txt"; }
string RiskSafetyStatusJsonPath()         { return "AI\\risk_safety_status.json"; }

string AIActivationReadinessStatusTxtPath()  { return "AI\\ai_activation_readiness_status.txt"; }
string AIActivationReadinessStatusJsonPath() { return "AI\\ai_activation_readiness_status.json"; }

string OperationalIntegrityStatusTxtPath()   { return "AI\\operational_integrity_status.txt"; }
string OperationalIntegrityStatusJsonPath()  { return "AI\\operational_integrity_status.json"; }
string ActiveOperatingCohortStatusTxtPath()  { return "AI\\active_operating_cohort.txt"; }
string ActiveOperatingCohortStatusJsonPath() { return "AI\\active_operating_cohort.json"; }
string ExecutionAuthorityStatusTxtPath()     { return "AI\\execution_authority_status.txt"; }
string ExecutionAuthorityStatusJsonPath()    { return "AI\\execution_authority_status.json"; }
string OperatingRiskEnvelopeStatusTxtPath()  { return "AI\\operating_risk_envelope_status.txt"; }
string OperatingRiskEnvelopeStatusJsonPath() { return "AI\\operating_risk_envelope_status.json"; }

string SourceIntakeGatewayPath()           { return "AI\\edge_factory\\registry\\source_intake_gateway.json"; }
string SourceIntakeGatewayStatusTxtPath()  { return "AI\\edge_factory\\registry\\source_intake_gateway_status.txt"; }
string SourceIntakeGatewayStatusJsonPath() { return "AI\\edge_factory\\registry\\source_intake_gateway_status.json"; }


string CouncilAIAdvisoryStatusTxtPath()      { return "AI\\council_ai_advisory_status.txt"; }
string CouncilAIAdvisoryStatusJsonPath()     { return "AI\\council_ai_advisory_status.json"; }
string CouncilAIAdvisoryEffectivenessTxtPath()  { return "AI\\council_ai_advisory_effectiveness.txt"; }
string CouncilAIAdvisoryEffectivenessJsonPath() { return "AI\\council_ai_advisory_effectiveness.json"; }

string DiagnosticRuntimeSummaryTxtPath()  { return "AI\\diagnostic_runtime_summary.txt"; }
string DiagnosticRuntimeSummaryJsonPath() { return "AI\\diagnostic_runtime_summary.json"; }

string ReplayValidationSummaryTxtPath()    { return "AI\\replay_validation_summary.txt"; }
string ReplayValidationSummaryJsonPath()   { return "AI\\replay_validation_summary.json"; }

string LastMeaningfulRuntimeEventTxtPath()      { return "AI\\last_meaningful_runtime_event.txt"; }
string LastMeaningfulRuntimeEventJsonPath()     { return "AI\\last_meaningful_runtime_event.json"; }
string FactoryOperationalEvidenceTxtPath()      { return "AI\\factory_operational_evidence_status.txt"; }
string FactoryOperationalEvidenceJsonPath()     { return "AI\\factory_operational_evidence_status.json"; }
string AIOperationalReviewTxtPath()             { return "AI\\ai_operational_review_status.txt"; }
string AIOperationalReviewJsonPath()            { return "AI\\ai_operational_review_status.json"; }


string DiagnosticBoolText(bool v)
{
   return (v ? "true" : "false");
}

string DiagnosticU64(ulong v)
{
   return StringFormat("%I64u", v);
}

string DiagnosticTimeText(datetime t)
{
   if(t <= 0)
      return "0";
   return TimeToString(t, TIME_DATE | TIME_MINUTES | TIME_SECONDS);
}

string OperatingCohortNormalizeFamily(const string src)
{
   string v = TrimString(src);
   StringToUpper(v);
   return v;
}

bool OperatingCohortFamilyAllowed(const string family)
{
   string v = OperatingCohortNormalizeFamily(family);
   return (v == "LIQUIDITY_REVERSAL" ||
           v == "MEAN_RECLAIM" ||
           v == "TREND_CONTINUATION" ||
           v == "COMPRESSION_BREAKOUT");
}

string ActiveOperatingCohortCandidatesCsv()
{
   return "LIQUIDITY_REVERSAL,MEAN_RECLAIM,TREND_CONTINUATION,COMPRESSION_BREAKOUT";
}

void InitActiveOperatingCohortStatus(ActiveOperatingCohortStatus &st)
{
   st.active_operating_cohort_id = "O3_FIRST_OPERATING_COHORT_V1";
   st.active_operating_cohort_state = "COHORT_ACTIVE";
   st.active_operating_candidates_csv = ActiveOperatingCohortCandidatesCsv();
   st.candidate_count = 4;
   st.operating_cohort_admission_semantics = "FAMILY_LEVEL";
   st.candidate_sources = "package5_pilot_cycle|packageC_pilot_evidence_design|factory_material_registry";
   st.cohort_activation_reason = "first_governance_valid_operating_cohort_cutover";
   st.cohort_scope_note = "Execution admitted only for LIQUIDITY_REVERSAL, MEAN_RECLAIM, TREND_CONTINUATION, COMPRESSION_BREAKOUT families. Family-level admission; not exact candidate identity-level admission.";
   st.last_updated = TimeCurrent();
   gActiveOperatingCohortInitialized = true;
}

void EvaluateActiveOperatingCohortStatus(ActiveOperatingCohortStatus &st)
{
   if(!gActiveOperatingCohortInitialized)
      InitActiveOperatingCohortStatus(st);

   st.active_operating_cohort_id = "O3_FIRST_OPERATING_COHORT_V1";
   st.active_operating_cohort_state = "COHORT_ACTIVE";
   st.active_operating_candidates_csv = ActiveOperatingCohortCandidatesCsv();
   st.candidate_count = 4;
   st.operating_cohort_admission_semantics = "FAMILY_LEVEL";
   st.candidate_sources = "package5_pilot_cycle|packageC_pilot_evidence_design|factory_material_registry";
   st.cohort_activation_reason = "first_governance_valid_operating_cohort_cutover";
   st.cohort_scope_note = "Execution admitted only for current governance-valid operating cohort families. Family-level admission; not exact candidate identity-level admission.";
   st.last_updated = TimeCurrent();
   gActiveOperatingCohortInitialized = true;
}

bool ActiveOperatingCohortDefined()
{
   EvaluateActiveOperatingCohortStatus(gActiveOperatingCohort);
   return (StringLen(gActiveOperatingCohort.active_operating_cohort_id) > 0 &&
           gActiveOperatingCohort.candidate_count > 0 &&
           gActiveOperatingCohort.active_operating_cohort_state == "COHORT_ACTIVE");
}

string BuildActiveOperatingCohortStatusText(const ActiveOperatingCohortStatus &st)
{
   string s = "";
   s += "active_operating_cohort_status\n";
   s += "active_operating_cohort_id=" + st.active_operating_cohort_id + "\n";
   s += "active_operating_cohort_state=" + st.active_operating_cohort_state + "\n";
   s += "active_operating_candidates=" + st.active_operating_candidates_csv + "\n";
   s += "candidate_count=" + IntegerToString(st.candidate_count) + "\n";
   s += "operating_cohort_admission_semantics=" + st.operating_cohort_admission_semantics + "\n";
   s += "candidate_sources=" + st.candidate_sources + "\n";
   s += "cohort_activation_reason=" + st.cohort_activation_reason + "\n";
   s += "cohort_scope_note=" + st.cohort_scope_note + "\n";
   s += "last_updated=" + DiagnosticTimeText(st.last_updated) + "\n";
   return s;
}

string BuildActiveOperatingCohortStatusJson(const ActiveOperatingCohortStatus &st)
{
   string j = "{";
   j += "\"active_operating_cohort_id\":\"" + JsonEscape(st.active_operating_cohort_id) + "\"";
   j += ",\"active_operating_cohort_state\":\"" + JsonEscape(st.active_operating_cohort_state) + "\"";
   j += ",\"active_operating_candidates\":\"" + JsonEscape(st.active_operating_candidates_csv) + "\"";
   j += ",\"candidate_count\":" + IntegerToString(st.candidate_count);
   j += ",\"operating_cohort_admission_semantics\":\"" + JsonEscape(st.operating_cohort_admission_semantics) + "\"";
   j += ",\"candidate_sources\":\"" + JsonEscape(st.candidate_sources) + "\"";
   j += ",\"cohort_activation_reason\":\"" + JsonEscape(st.cohort_activation_reason) + "\"";
   j += ",\"cohort_scope_note\":\"" + JsonEscape(st.cohort_scope_note) + "\"";
   j += ",\"last_updated\":\"" + JsonEscape(DiagnosticTimeText(st.last_updated)) + "\"";
   j += "}";
   return j;
}

void SaveActiveOperatingCohortStatusBestEffort(const ActiveOperatingCohortStatus &st)
{
   WriteTextFileAll(ActiveOperatingCohortStatusTxtPath(), BuildActiveOperatingCohortStatusText(st));
   WriteTextFileAll(ActiveOperatingCohortStatusJsonPath(), BuildActiveOperatingCohortStatusJson(st));
}

void RefreshActiveOperatingCohortStatusBestEffort()
{
   EvaluateActiveOperatingCohortStatus(gActiveOperatingCohort);
   SaveActiveOperatingCohortStatusBestEffort(gActiveOperatingCohort);
}

void RuntimeGovernanceApplyExecutionAuthorityCutoverTruth(RuntimeGovernanceState &st)
{
   EvaluateActiveOperatingCohortStatus(gActiveOperatingCohort);

   st.execution_authority_source = "ACTIVE_OPERATING_COHORT_FACTORY_GOVERNED_ADMISSION";
   st.execution_authority_cutover_state = "CUTOVER_ACTIVE";
   st.legacy_identity_execution_authority_active = false;
   st.factory_governed_execution_authority_active = true;
   st.active_operating_cohort_defined = ActiveOperatingCohortDefined();
   st.active_operating_cohort_id = gActiveOperatingCohort.active_operating_cohort_id;
   st.active_operating_candidate_count = gActiveOperatingCohort.candidate_count;
   st.execution_allowed_only_through_active_operating_cohort = true;
   st.operating_cohort_admission_semantics = gActiveOperatingCohort.operating_cohort_admission_semantics;
}

void ExecutionAuthorityInitStatus(ExecutionAuthorityStatus &st)
{
   EvaluateActiveOperatingCohortStatus(gActiveOperatingCohort);
   st.execution_authority_source = "ACTIVE_OPERATING_COHORT_FACTORY_GOVERNED_ADMISSION";
   st.execution_authority_cutover_state = "CUTOVER_ACTIVE";
   st.legacy_identity_execution_authority_active = false;
   st.factory_governed_execution_authority_active = true;
   st.active_operating_cohort_defined = ActiveOperatingCohortDefined();
   st.active_operating_cohort_id = gActiveOperatingCohort.active_operating_cohort_id;
   st.active_operating_candidate_count = gActiveOperatingCohort.candidate_count;
   st.execution_allowed_only_through_active_operating_cohort = true;
   st.operating_cohort_admission_semantics = gActiveOperatingCohort.operating_cohort_admission_semantics;
   st.execution_globally_blocked = false;
   st.execution_block_reason_code = "";
   st.decision_candidate_name = gCurrentDecisionCandidateName;
   st.decision_candidate_family = gCurrentDecisionCandidateFamily;
   st.last_reject_candidate_name = gLastRejectedCandidateName;
   st.last_reject_candidate_family = gLastRejectedCandidateFamily;
   st.last_reject_reason_code = gLastRejectedReasonCode;
   st.last_executed_candidate_name = gLastExecutedCandidateName;
   st.last_executed_candidate_family = gLastExecutedCandidateFamily;
   st.last_executed_candidate_time = gLastExecutedCandidateTime;
   st.last_updated = TimeCurrent();
   gExecutionAuthorityInitialized = true;
}

void ExecutionAuthoritySetDecisionCandidate(const string candidateName, const string candidateFamily)
{
   gCurrentDecisionCandidateName = TrimString(candidateName);
   gCurrentDecisionCandidateFamily = OperatingCohortNormalizeFamily(candidateFamily);

   if(StringLen(gCurrentDecisionCandidateName) == 0 && StringLen(gCurrentDecisionCandidateFamily) > 0)
      gCurrentDecisionCandidateName = gCurrentDecisionCandidateFamily;
}

void ExecutionAuthorityRememberReject(const string reasonCode)
{
   gLastRejectedCandidateName = gCurrentDecisionCandidateName;
   gLastRejectedCandidateFamily = gCurrentDecisionCandidateFamily;
   gLastRejectedReasonCode = reasonCode;
   UpdateLastMeaningfulRuntimeEventBestEffort("DECISION_REJECTED",
                                              gLastRejectedCandidateName,
                                              gLastRejectedCandidateFamily,
                                              reasonCode,
                                              "",
                                              "Execution authority recorded the latest rejected candidate.",
                                              "execution_authority");
}

void ExecutionAuthorityRememberExecution()
{
   gLastExecutedCandidateName = gCurrentDecisionCandidateName;
   gLastExecutedCandidateFamily = gCurrentDecisionCandidateFamily;
   gLastExecutedCandidateTime = TimeCurrent();
   UpdateLastMeaningfulRuntimeEventBestEffort("EXECUTION_OPENED",
                                              gLastExecutedCandidateName,
                                              gLastExecutedCandidateFamily,
                                              "",
                                              "",
                                              "Execution authority recorded the latest executed candidate.",
                                              "execution_authority");
}

void EvaluateExecutionAuthorityStatus(ExecutionAuthorityStatus &st)
{
   if(!gExecutionAuthorityInitialized)
      ExecutionAuthorityInitStatus(st);

   EvaluateActiveOperatingCohortStatus(gActiveOperatingCohort);

   st.execution_authority_source = "ACTIVE_OPERATING_COHORT_FACTORY_GOVERNED_ADMISSION";
   st.execution_authority_cutover_state = "CUTOVER_ACTIVE";
   st.legacy_identity_execution_authority_active = false;
   st.factory_governed_execution_authority_active = true;
   st.active_operating_cohort_defined = ActiveOperatingCohortDefined();
   st.active_operating_cohort_id = gActiveOperatingCohort.active_operating_cohort_id;
   st.active_operating_candidate_count = gActiveOperatingCohort.candidate_count;
   st.execution_allowed_only_through_active_operating_cohort = true;
   st.operating_cohort_admission_semantics = gActiveOperatingCohort.operating_cohort_admission_semantics;
   st.operating_risk_envelope_state = (gOperatingRiskEnvelopeInitialized ? gOperatingRiskEnvelope.operating_risk_envelope_state : "PENDING_RUNTIME_INIT");
   st.current_guardrail_block_reason_code = (gOperatingRiskEnvelopeInitialized ? gOperatingRiskEnvelope.current_block_reason_code : "");
   st.current_guardrail_owner = (gOperatingRiskEnvelopeInitialized ? gOperatingRiskEnvelope.current_block_owner : "");
   st.execution_globally_blocked = (!st.active_operating_cohort_defined || !st.factory_governed_execution_authority_active);
   st.execution_block_reason_code = (st.execution_globally_blocked ? "active_operating_cohort_not_defined" : "");
   st.decision_candidate_name = gCurrentDecisionCandidateName;
   st.decision_candidate_family = gCurrentDecisionCandidateFamily;
   st.last_reject_candidate_name = gLastRejectedCandidateName;
   st.last_reject_candidate_family = gLastRejectedCandidateFamily;
   st.last_reject_reason_code = gLastRejectedReasonCode;
   st.last_executed_candidate_name = gLastExecutedCandidateName;
   st.last_executed_candidate_family = gLastExecutedCandidateFamily;
   st.last_executed_candidate_time = gLastExecutedCandidateTime;
   st.last_updated = TimeCurrent();
   gExecutionAuthorityInitialized = true;
}

string BuildExecutionAuthorityStatusText(const ExecutionAuthorityStatus &st)
{
   string s = "";
   s += "execution_authority_status\n";
   s += "execution_authority_source=" + st.execution_authority_source + "\n";
   s += "execution_authority_cutover_state=" + st.execution_authority_cutover_state + "\n";
   s += "legacy_identity_execution_authority_active=" + DiagnosticBoolText(st.legacy_identity_execution_authority_active) + "\n";
   s += "factory_governed_execution_authority_active=" + DiagnosticBoolText(st.factory_governed_execution_authority_active) + "\n";
   s += "active_operating_cohort_defined=" + DiagnosticBoolText(st.active_operating_cohort_defined) + "\n";
   s += "active_operating_cohort_id=" + st.active_operating_cohort_id + "\n";
   s += "active_operating_candidate_count=" + IntegerToString(st.active_operating_candidate_count) + "\n";
   s += "execution_allowed_only_through_active_operating_cohort=" + DiagnosticBoolText(st.execution_allowed_only_through_active_operating_cohort) + "\n";
   s += "operating_cohort_admission_semantics=" + st.operating_cohort_admission_semantics + "\n";
   s += "operating_risk_envelope_state=" + st.operating_risk_envelope_state + "\n";
   s += "current_guardrail_block_reason_code=" + st.current_guardrail_block_reason_code + "\n";
   s += "current_guardrail_owner=" + st.current_guardrail_owner + "\n";
   s += "execution_globally_blocked=" + DiagnosticBoolText(st.execution_globally_blocked) + "\n";
   s += "execution_block_reason_code=" + st.execution_block_reason_code + "\n";
   s += "decision_candidate_name=" + st.decision_candidate_name + "\n";
   s += "decision_candidate_family=" + st.decision_candidate_family + "\n";
   s += "last_reject_candidate_name=" + st.last_reject_candidate_name + "\n";
   s += "last_reject_candidate_family=" + st.last_reject_candidate_family + "\n";
   s += "last_reject_reason_code=" + st.last_reject_reason_code + "\n";
   s += "last_executed_candidate_name=" + st.last_executed_candidate_name + "\n";
   s += "last_executed_candidate_family=" + st.last_executed_candidate_family + "\n";
   s += "last_executed_candidate_time=" + DiagnosticTimeText(st.last_executed_candidate_time) + "\n";
   s += "last_updated=" + DiagnosticTimeText(st.last_updated) + "\n";
   return s;
}

string BuildExecutionAuthorityStatusJson(const ExecutionAuthorityStatus &st)
{
   string j = "{";
   j += "\"execution_authority_source\":\"" + JsonEscape(st.execution_authority_source) + "\"";
   j += ",\"execution_authority_cutover_state\":\"" + JsonEscape(st.execution_authority_cutover_state) + "\"";
   j += ",\"legacy_identity_execution_authority_active\":" + string(st.legacy_identity_execution_authority_active ? "true" : "false");
   j += ",\"factory_governed_execution_authority_active\":" + string(st.factory_governed_execution_authority_active ? "true" : "false");
   j += ",\"active_operating_cohort_defined\":" + string(st.active_operating_cohort_defined ? "true" : "false");
   j += ",\"active_operating_cohort_id\":\"" + JsonEscape(st.active_operating_cohort_id) + "\"";
   j += ",\"active_operating_candidate_count\":" + IntegerToString(st.active_operating_candidate_count);
   j += ",\"execution_allowed_only_through_active_operating_cohort\":" + string(st.execution_allowed_only_through_active_operating_cohort ? "true" : "false");
   j += ",\"operating_cohort_admission_semantics\":\"" + JsonEscape(st.operating_cohort_admission_semantics) + "\"";
   j += ",\"operating_risk_envelope_state\":\"" + JsonEscape(st.operating_risk_envelope_state) + "\"";
   j += ",\"current_guardrail_block_reason_code\":\"" + JsonEscape(st.current_guardrail_block_reason_code) + "\"";
   j += ",\"current_guardrail_owner\":\"" + JsonEscape(st.current_guardrail_owner) + "\"";
   j += ",\"execution_globally_blocked\":" + string(st.execution_globally_blocked ? "true" : "false");
   j += ",\"execution_block_reason_code\":\"" + JsonEscape(st.execution_block_reason_code) + "\"";
   j += ",\"decision_candidate_name\":\"" + JsonEscape(st.decision_candidate_name) + "\"";
   j += ",\"decision_candidate_family\":\"" + JsonEscape(st.decision_candidate_family) + "\"";
   j += ",\"last_reject_candidate_name\":\"" + JsonEscape(st.last_reject_candidate_name) + "\"";
   j += ",\"last_reject_candidate_family\":\"" + JsonEscape(st.last_reject_candidate_family) + "\"";
   j += ",\"last_reject_reason_code\":\"" + JsonEscape(st.last_reject_reason_code) + "\"";
   j += ",\"last_executed_candidate_name\":\"" + JsonEscape(st.last_executed_candidate_name) + "\"";
   j += ",\"last_executed_candidate_family\":\"" + JsonEscape(st.last_executed_candidate_family) + "\"";
   j += ",\"last_executed_candidate_time\":\"" + JsonEscape(DiagnosticTimeText(st.last_executed_candidate_time)) + "\"";
   j += ",\"last_updated\":\"" + JsonEscape(DiagnosticTimeText(st.last_updated)) + "\"";
   j += "}";
   return j;
}

void SaveExecutionAuthorityStatusBestEffort(const ExecutionAuthorityStatus &st)
{
   WriteTextFileAll(ExecutionAuthorityStatusTxtPath(), BuildExecutionAuthorityStatusText(st));
   WriteTextFileAll(ExecutionAuthorityStatusJsonPath(), BuildExecutionAuthorityStatusJson(st));
}

void RefreshExecutionAuthorityStatusBestEffort()
{
   EvaluateExecutionAuthorityStatus(gExecutionAuthorityStatus);
   SaveExecutionAuthorityStatusBestEffort(gExecutionAuthorityStatus);
}

string OperatingEnvelopeDirectionText(const CoreDirection dir)
{
   if(dir == CORE_BUY)
      return "BUY";
   if(dir == CORE_SELL)
      return "SELL";
   return "NONE";
}

double RuntimeCurrentSpreadPoints()
{
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0)
      point = Point();

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if(point > 0.0 && ask > 0.0 && bid > 0.0 && ask >= bid)
      return ((ask - bid) / point);

   long spreadPoints = 0;
   if(SymbolInfoInteger(_Symbol, SYMBOL_SPREAD, spreadPoints))
      return (double)spreadPoints;

   return 0.0;
}

struct OperatingEnvelopeEvaluation
{
   string   operating_risk_envelope_state;
   bool     envelope_clear_for_new_entries;
   int      max_open_positions;
   int      current_open_positions;
   int      max_new_trades_per_session;
   int      current_session_new_entries;
   int      effective_session_trade_cap;
   int      cooldown_bars;
   int      bars_since_last_entry;
   bool     spread_guard_active;
   double   spread_guard_threshold_points;
   double   current_spread_points;
   bool     risk_policy_guard_active;
   bool     execution_quality_guard_active;
   bool     emergency_stop_active;
   string   current_blocking_guard;
   string   current_block_reason_code;
   string   current_block_reason_text;
   string   current_block_owner;
   string   direction_under_review;
};

void InitOperatingEnvelopeEvaluation(OperatingEnvelopeEvaluation &ev)
{
   ev.operating_risk_envelope_state = "PENDING_RUNTIME_INIT";
   ev.envelope_clear_for_new_entries = false;
   ev.max_open_positions = 0;
   ev.current_open_positions = 0;
   ev.max_new_trades_per_session = 0;
   ev.current_session_new_entries = 0;
   ev.effective_session_trade_cap = 0;
   ev.cooldown_bars = 0;
   ev.bars_since_last_entry = 0;
   ev.spread_guard_active = false;
   ev.spread_guard_threshold_points = 0.0;
   ev.current_spread_points = 0.0;
   ev.risk_policy_guard_active = false;
   ev.execution_quality_guard_active = EnableCouncilExecutionQualityGate;
   ev.emergency_stop_active = false;
   ev.current_blocking_guard = "";
   ev.current_block_reason_code = "";
   ev.current_block_reason_text = "";
   ev.current_block_owner = "";
   ev.direction_under_review = "NONE";
}

void OperatingEnvelopeSetBlock(OperatingEnvelopeEvaluation &ev,
                               const string guardName,
                               const string reasonCode,
                               const string reasonText,
                               const string owner)
{
   ev.envelope_clear_for_new_entries = false;
   ev.operating_risk_envelope_state = (reasonCode == "emergency_stop_active" ? "EMERGENCY_STOP_ACTIVE" : "ENVELOPE_BLOCKED");
   ev.current_blocking_guard = guardName;
   ev.current_block_reason_code = reasonCode;
   ev.current_block_reason_text = reasonText;
   ev.current_block_owner = owner;
}

void EvaluateOperatingEnvelope(const CoreDirection dir, OperatingEnvelopeEvaluation &ev)
{
   InitOperatingEnvelopeEvaluation(ev);
   ev.direction_under_review = OperatingEnvelopeDirectionText(dir);
   ev.max_open_positions = MathMax(0, gPlan.max_open_positions);
   ev.current_open_positions = CountMyOpenPositions();
   ev.max_new_trades_per_session = MathMax(0, gPlan.max_trades_per_session);
   ev.current_session_new_entries = CountSessionNewEntries();
   ev.effective_session_trade_cap = (ev.max_new_trades_per_session > 0 ? ComputeSmartSessionCap() : 0);
   ev.cooldown_bars = MathMax(0, gPlan.cooldown_bars);
   ev.spread_guard_active = (gPlan.use_spread_filter && gPlan.max_spread_points > 0.0);
   ev.spread_guard_threshold_points = (ev.spread_guard_active ? gPlan.max_spread_points : 0.0);
   ev.current_spread_points = RuntimeCurrentSpreadPoints();
   ev.risk_policy_guard_active = (gHasRiskPolicy && gRiskPolicy.block_new_trades);
   ev.execution_quality_guard_active = EnableCouncilExecutionQualityGate;
   ev.emergency_stop_active = (gRuntimeRiskSafetyInitialized && gRuntimeRiskSafety.emergency_flat_required);

   int currentBars = Bars(_Symbol, PERIOD_M1);
   if(ev.cooldown_bars > 0 && gLastRuntimeEntryBars > 0 && currentBars > 0)
      ev.bars_since_last_entry = (currentBars - gLastRuntimeEntryBars);
   else
      ev.bars_since_last_entry = ev.cooldown_bars + 1;

   ev.envelope_clear_for_new_entries = true;
   ev.operating_risk_envelope_state = "ENVELOPE_CLEAR";

   if(ev.emergency_stop_active)
   {
      OperatingEnvelopeSetBlock(ev,
                                "EMERGENCY_STOP",
                                "emergency_stop_active",
                                "Emergency stop posture is active; new entries are withheld.",
                                "risk_safety_guard");
      return;
   }

   if(ev.risk_policy_guard_active)
   {
      OperatingEnvelopeSetBlock(ev,
                                "RISK_POLICY",
                                "risk_safety_block_active",
                                "Risk-state policy currently blocks new trades.",
                                "risk_state_policy_engine");
      return;
   }

   if(ev.spread_guard_active && ev.current_spread_points > ev.spread_guard_threshold_points)
   {
      OperatingEnvelopeSetBlock(ev,
                                "SPREAD_GUARD",
                                "spread_too_wide",
                                "Spread is above the bounded operating threshold.",
                                "market_spread_guard");
      return;
   }

   if(ev.cooldown_bars > 0 && ev.bars_since_last_entry <= ev.cooldown_bars)
   {
      OperatingEnvelopeSetBlock(ev,
                                "COOLDOWN_GUARD",
                                "cooldown_active",
                                "Minimum spacing between entries is still active.",
                                "entry_cooldown_guard");
      return;
   }

   if(ev.max_new_trades_per_session > 0 && ev.effective_session_trade_cap > 0 && ev.current_session_new_entries >= ev.effective_session_trade_cap)
   {
      OperatingEnvelopeSetBlock(ev,
                                "SESSION_GUARD",
                                "max_trades_window_reached",
                                "The bounded session trade-opening cap has been reached.",
                                "session_trade_guard");
      return;
   }

   if(ev.max_open_positions > 0 && ev.current_open_positions >= ev.max_open_positions)
   {
      OperatingEnvelopeSetBlock(ev,
                                "CAPACITY_GUARD",
                                "max_open_positions_reached",
                                "Maximum open-position capacity has been reached.",
                                "position_capacity_guard");
      return;
   }

   if(dir != CORE_NONE && gPlan.one_direction_only)
   {
      if(dir == CORE_BUY && CountMyDirectionPositions(POSITION_TYPE_BUY) > 0)
      {
         OperatingEnvelopeSetBlock(ev,
                                   "DIRECTION_GUARD",
                                   "one_direction_only_blocked",
                                   "One-direction-only posture blocks an additional BUY entry.",
                                   "direction_capacity_guard");
         return;
      }

      if(dir == CORE_SELL && CountMyDirectionPositions(POSITION_TYPE_SELL) > 0)
      {
         OperatingEnvelopeSetBlock(ev,
                                   "DIRECTION_GUARD",
                                   "one_direction_only_blocked",
                                   "One-direction-only posture blocks an additional SELL entry.",
                                   "direction_capacity_guard");
         return;
      }
   }
}

void InitOperatingRiskEnvelopeStatus(OperatingRiskEnvelopeStatus &st)
{
   st.operating_risk_envelope_state = "PENDING_RUNTIME_INIT";
   st.envelope_clear_for_new_entries = false;
   st.max_open_positions = 0;
   st.current_open_positions = 0;
   st.max_new_trades_per_session = 0;
   st.current_session_new_entries = 0;
   st.effective_session_trade_cap = 0;
   st.cooldown_bars = 0;
   st.bars_since_last_entry = 0;
   st.spread_guard_active = false;
   st.spread_guard_threshold_points = 0.0;
   st.current_spread_points = 0.0;
   st.risk_policy_guard_active = false;
   st.execution_quality_guard_active = false;
   st.emergency_stop_active = false;
   st.current_blocking_guard = "";
   st.current_block_reason_code = "";
   st.current_block_reason_text = "";
   st.current_block_owner = "";
   st.last_direction_under_review = "NONE";
   st.last_updated = TimeCurrent();
}

void ApplyOperatingRiskEnvelopeStatusFromEvaluation(OperatingRiskEnvelopeStatus &st, const OperatingEnvelopeEvaluation &ev)
{
   st.operating_risk_envelope_state = ev.operating_risk_envelope_state;
   st.envelope_clear_for_new_entries = ev.envelope_clear_for_new_entries;
   st.max_open_positions = ev.max_open_positions;
   st.current_open_positions = ev.current_open_positions;
   st.max_new_trades_per_session = ev.max_new_trades_per_session;
   st.current_session_new_entries = ev.current_session_new_entries;
   st.effective_session_trade_cap = ev.effective_session_trade_cap;
   st.cooldown_bars = ev.cooldown_bars;
   st.bars_since_last_entry = ev.bars_since_last_entry;
   st.spread_guard_active = ev.spread_guard_active;
   st.spread_guard_threshold_points = ev.spread_guard_threshold_points;
   st.current_spread_points = ev.current_spread_points;
   st.risk_policy_guard_active = ev.risk_policy_guard_active;
   st.execution_quality_guard_active = ev.execution_quality_guard_active;
   st.emergency_stop_active = ev.emergency_stop_active;
   st.current_blocking_guard = ev.current_blocking_guard;
   st.current_block_reason_code = ev.current_block_reason_code;
   st.current_block_reason_text = ev.current_block_reason_text;
   st.current_block_owner = ev.current_block_owner;
   st.last_direction_under_review = ev.direction_under_review;
   st.last_updated = TimeCurrent();
   gOperatingRiskEnvelopeInitialized = true;
}

void RefreshOperatingRiskEnvelopeStatusBestEffort(const CoreDirection dir = CORE_NONE)
{
   if(!gOperatingRiskEnvelopeInitialized)
      InitOperatingRiskEnvelopeStatus(gOperatingRiskEnvelope);

   OperatingEnvelopeEvaluation ev;
   EvaluateOperatingEnvelope(dir, ev);
   ApplyOperatingRiskEnvelopeStatusFromEvaluation(gOperatingRiskEnvelope, ev);

   string s = "";
   s += "operating_risk_envelope_status\n";
   s += "operating_risk_envelope_state=" + gOperatingRiskEnvelope.operating_risk_envelope_state + "\n";
   s += "envelope_clear_for_new_entries=" + DiagnosticBoolText(gOperatingRiskEnvelope.envelope_clear_for_new_entries) + "\n";
   s += "max_open_positions=" + IntegerToString(gOperatingRiskEnvelope.max_open_positions) + "\n";
   s += "current_open_positions=" + IntegerToString(gOperatingRiskEnvelope.current_open_positions) + "\n";
   s += "max_new_trades_per_session=" + IntegerToString(gOperatingRiskEnvelope.max_new_trades_per_session) + "\n";
   s += "current_session_new_entries=" + IntegerToString(gOperatingRiskEnvelope.current_session_new_entries) + "\n";
   s += "effective_session_trade_cap=" + IntegerToString(gOperatingRiskEnvelope.effective_session_trade_cap) + "\n";
   s += "cooldown_bars=" + IntegerToString(gOperatingRiskEnvelope.cooldown_bars) + "\n";
   s += "bars_since_last_entry=" + IntegerToString(gOperatingRiskEnvelope.bars_since_last_entry) + "\n";
   s += "spread_guard_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.spread_guard_active) + "\n";
   s += "spread_guard_threshold_points=" + DoubleToString(gOperatingRiskEnvelope.spread_guard_threshold_points, 1) + "\n";
   s += "current_spread_points=" + DoubleToString(gOperatingRiskEnvelope.current_spread_points, 1) + "\n";
   s += "risk_policy_guard_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.risk_policy_guard_active) + "\n";
   s += "execution_quality_guard_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.execution_quality_guard_active) + "\n";
   s += "emergency_stop_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.emergency_stop_active) + "\n";
   s += "current_blocking_guard=" + gOperatingRiskEnvelope.current_blocking_guard + "\n";
   s += "current_block_reason_code=" + gOperatingRiskEnvelope.current_block_reason_code + "\n";
   s += "current_block_reason_text=" + gOperatingRiskEnvelope.current_block_reason_text + "\n";
   s += "current_block_owner=" + gOperatingRiskEnvelope.current_block_owner + "\n";
   s += "last_direction_under_review=" + gOperatingRiskEnvelope.last_direction_under_review + "\n";
   s += "last_updated=" + DiagnosticTimeText(gOperatingRiskEnvelope.last_updated) + "\n";
   WriteTextFileAll(OperatingRiskEnvelopeStatusTxtPath(), s);

   string j = "{";
   j += "\"operating_risk_envelope_state\":\"" + JsonEscape(gOperatingRiskEnvelope.operating_risk_envelope_state) + "\"";
   j += ",\"envelope_clear_for_new_entries\":" + string(gOperatingRiskEnvelope.envelope_clear_for_new_entries ? "true" : "false");
   j += ",\"max_open_positions\":" + IntegerToString(gOperatingRiskEnvelope.max_open_positions);
   j += ",\"current_open_positions\":" + IntegerToString(gOperatingRiskEnvelope.current_open_positions);
   j += ",\"max_new_trades_per_session\":" + IntegerToString(gOperatingRiskEnvelope.max_new_trades_per_session);
   j += ",\"current_session_new_entries\":" + IntegerToString(gOperatingRiskEnvelope.current_session_new_entries);
   j += ",\"effective_session_trade_cap\":" + IntegerToString(gOperatingRiskEnvelope.effective_session_trade_cap);
   j += ",\"cooldown_bars\":" + IntegerToString(gOperatingRiskEnvelope.cooldown_bars);
   j += ",\"bars_since_last_entry\":" + IntegerToString(gOperatingRiskEnvelope.bars_since_last_entry);
   j += ",\"spread_guard_active\":" + string(gOperatingRiskEnvelope.spread_guard_active ? "true" : "false");
   j += ",\"spread_guard_threshold_points\":" + DoubleToString(gOperatingRiskEnvelope.spread_guard_threshold_points, 1);
   j += ",\"current_spread_points\":" + DoubleToString(gOperatingRiskEnvelope.current_spread_points, 1);
   j += ",\"risk_policy_guard_active\":" + string(gOperatingRiskEnvelope.risk_policy_guard_active ? "true" : "false");
   j += ",\"execution_quality_guard_active\":" + string(gOperatingRiskEnvelope.execution_quality_guard_active ? "true" : "false");
   j += ",\"emergency_stop_active\":" + string(gOperatingRiskEnvelope.emergency_stop_active ? "true" : "false");
   j += ",\"current_blocking_guard\":\"" + JsonEscape(gOperatingRiskEnvelope.current_blocking_guard) + "\"";
   j += ",\"current_block_reason_code\":\"" + JsonEscape(gOperatingRiskEnvelope.current_block_reason_code) + "\"";
   j += ",\"current_block_reason_text\":\"" + JsonEscape(gOperatingRiskEnvelope.current_block_reason_text) + "\"";
   j += ",\"current_block_owner\":\"" + JsonEscape(gOperatingRiskEnvelope.current_block_owner) + "\"";
   j += ",\"last_direction_under_review\":\"" + JsonEscape(gOperatingRiskEnvelope.last_direction_under_review) + "\"";
   j += ",\"last_updated\":\"" + JsonEscape(DiagnosticTimeText(gOperatingRiskEnvelope.last_updated)) + "\"";
   j += "}";
   WriteTextFileAll(OperatingRiskEnvelopeStatusJsonPath(), j);
}

void OperatingRiskEnvelopeRecordCurrentBlock(const string guardName,
                                            const string reasonCode,
                                            const string reasonText,
                                            const string owner,
                                            const CoreDirection dir = CORE_NONE)
{
   if(!gOperatingRiskEnvelopeInitialized)
      InitOperatingRiskEnvelopeStatus(gOperatingRiskEnvelope);

   RefreshOperatingRiskEnvelopeStatusBestEffort(dir);
   gOperatingRiskEnvelope.operating_risk_envelope_state = (reasonCode == "emergency_stop_active" ? "EMERGENCY_STOP_ACTIVE" : "ENVELOPE_BLOCKED");
   gOperatingRiskEnvelope.envelope_clear_for_new_entries = false;
   gOperatingRiskEnvelope.current_blocking_guard = guardName;
   gOperatingRiskEnvelope.current_block_reason_code = reasonCode;
   gOperatingRiskEnvelope.current_block_reason_text = reasonText;
   gOperatingRiskEnvelope.current_block_owner = owner;
   gOperatingRiskEnvelope.last_direction_under_review = OperatingEnvelopeDirectionText(dir);
   gOperatingRiskEnvelope.last_updated = TimeCurrent();

   UpdateLastMeaningfulRuntimeEventBestEffort("GUARDRAIL_BLOCK",
                                              gCurrentDecisionCandidateName,
                                              gCurrentDecisionCandidateFamily,
                                              reasonCode,
                                              OperatingEnvelopeDirectionText(dir),
                                              reasonText,
                                              owner);

   string txtStatus = "operating_risk_envelope_status\n";
   txtStatus += "operating_risk_envelope_state=" + gOperatingRiskEnvelope.operating_risk_envelope_state + "\n";
   txtStatus += "envelope_clear_for_new_entries=" + DiagnosticBoolText(gOperatingRiskEnvelope.envelope_clear_for_new_entries) + "\n";
   txtStatus += "max_open_positions=" + IntegerToString(gOperatingRiskEnvelope.max_open_positions) + "\n";
   txtStatus += "current_open_positions=" + IntegerToString(gOperatingRiskEnvelope.current_open_positions) + "\n";
   txtStatus += "max_new_trades_per_session=" + IntegerToString(gOperatingRiskEnvelope.max_new_trades_per_session) + "\n";
   txtStatus += "current_session_new_entries=" + IntegerToString(gOperatingRiskEnvelope.current_session_new_entries) + "\n";
   txtStatus += "effective_session_trade_cap=" + IntegerToString(gOperatingRiskEnvelope.effective_session_trade_cap) + "\n";
   txtStatus += "cooldown_bars=" + IntegerToString(gOperatingRiskEnvelope.cooldown_bars) + "\n";
   txtStatus += "bars_since_last_entry=" + IntegerToString(gOperatingRiskEnvelope.bars_since_last_entry) + "\n";
   txtStatus += "spread_guard_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.spread_guard_active) + "\n";
   txtStatus += "spread_guard_threshold_points=" + DoubleToString(gOperatingRiskEnvelope.spread_guard_threshold_points, 1) + "\n";
   txtStatus += "current_spread_points=" + DoubleToString(gOperatingRiskEnvelope.current_spread_points, 1) + "\n";
   txtStatus += "risk_policy_guard_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.risk_policy_guard_active) + "\n";
   txtStatus += "execution_quality_guard_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.execution_quality_guard_active) + "\n";
   txtStatus += "emergency_stop_active=" + DiagnosticBoolText(gOperatingRiskEnvelope.emergency_stop_active) + "\n";
   txtStatus += "current_blocking_guard=" + gOperatingRiskEnvelope.current_blocking_guard + "\n";
   txtStatus += "current_block_reason_code=" + gOperatingRiskEnvelope.current_block_reason_code + "\n";
   txtStatus += "current_block_reason_text=" + gOperatingRiskEnvelope.current_block_reason_text + "\n";
   txtStatus += "current_block_owner=" + gOperatingRiskEnvelope.current_block_owner + "\n";
   txtStatus += "last_direction_under_review=" + gOperatingRiskEnvelope.last_direction_under_review + "\n";
   txtStatus += "last_updated=" + DiagnosticTimeText(gOperatingRiskEnvelope.last_updated) + "\n";
   WriteTextFileAll(OperatingRiskEnvelopeStatusTxtPath(), txtStatus);

   string jsonStatus = "{";
   jsonStatus += "\"operating_risk_envelope_state\":\"" + JsonEscape(gOperatingRiskEnvelope.operating_risk_envelope_state) + "\"";
   jsonStatus += ",\"envelope_clear_for_new_entries\":" + string(gOperatingRiskEnvelope.envelope_clear_for_new_entries ? "true" : "false");
   jsonStatus += ",\"max_open_positions\":" + IntegerToString(gOperatingRiskEnvelope.max_open_positions);
   jsonStatus += ",\"current_open_positions\":" + IntegerToString(gOperatingRiskEnvelope.current_open_positions);
   jsonStatus += ",\"max_new_trades_per_session\":" + IntegerToString(gOperatingRiskEnvelope.max_new_trades_per_session);
   jsonStatus += ",\"current_session_new_entries\":" + IntegerToString(gOperatingRiskEnvelope.current_session_new_entries);
   jsonStatus += ",\"effective_session_trade_cap\":" + IntegerToString(gOperatingRiskEnvelope.effective_session_trade_cap);
   jsonStatus += ",\"cooldown_bars\":" + IntegerToString(gOperatingRiskEnvelope.cooldown_bars);
   jsonStatus += ",\"bars_since_last_entry\":" + IntegerToString(gOperatingRiskEnvelope.bars_since_last_entry);
   jsonStatus += ",\"spread_guard_active\":" + string(gOperatingRiskEnvelope.spread_guard_active ? "true" : "false");
   jsonStatus += ",\"spread_guard_threshold_points\":" + DoubleToString(gOperatingRiskEnvelope.spread_guard_threshold_points, 1);
   jsonStatus += ",\"current_spread_points\":" + DoubleToString(gOperatingRiskEnvelope.current_spread_points, 1);
   jsonStatus += ",\"risk_policy_guard_active\":" + string(gOperatingRiskEnvelope.risk_policy_guard_active ? "true" : "false");
   jsonStatus += ",\"execution_quality_guard_active\":" + string(gOperatingRiskEnvelope.execution_quality_guard_active ? "true" : "false");
   jsonStatus += ",\"emergency_stop_active\":" + string(gOperatingRiskEnvelope.emergency_stop_active ? "true" : "false");
   jsonStatus += ",\"current_blocking_guard\":\"" + JsonEscape(gOperatingRiskEnvelope.current_blocking_guard) + "\"";
   jsonStatus += ",\"current_block_reason_code\":\"" + JsonEscape(gOperatingRiskEnvelope.current_block_reason_code) + "\"";
   jsonStatus += ",\"current_block_reason_text\":\"" + JsonEscape(gOperatingRiskEnvelope.current_block_reason_text) + "\"";
   jsonStatus += ",\"current_block_owner\":\"" + JsonEscape(gOperatingRiskEnvelope.current_block_owner) + "\"";
   jsonStatus += ",\"last_direction_under_review\":\"" + JsonEscape(gOperatingRiskEnvelope.last_direction_under_review) + "\"";
   jsonStatus += ",\"last_updated\":\"" + JsonEscape(DiagnosticTimeText(gOperatingRiskEnvelope.last_updated)) + "\"";
   jsonStatus += "}";
   WriteTextFileAll(OperatingRiskEnvelopeStatusJsonPath(), jsonStatus);
}

bool RuntimeOperatingEnvelopeAllowsTrade(const CoreDirection dir, string &reasonCode)
{
   reasonCode = "";
   RefreshOperatingRiskEnvelopeStatusBestEffort(dir);
   if(gOperatingRiskEnvelope.envelope_clear_for_new_entries)
      return true;

   reasonCode = (StringLen(TrimString(gOperatingRiskEnvelope.current_block_reason_code)) > 0
                 ? gOperatingRiskEnvelope.current_block_reason_code
                 : "operating_risk_envelope_blocked");
   return false;
}

void RuntimeInferDecisionCandidateFromRouted(const RoutedRuntimeEvaluation &routed,
                                             string &candidateName,
                                             string &candidateFamily)
{
   candidateName = "";
   candidateFamily = "";

   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      candidateName = TrimString(routed.council.aggregate.best_strategy_id);
      candidateFamily = LAB_InferFamilyFromStrategyId(candidateName);
   }
   else
   {
      candidateName = TrimString(routed.active_mode);
      candidateFamily = TrimString(routed.active_mode);
   }

   candidateFamily = OperatingCohortNormalizeFamily(candidateFamily);
   if(StringLen(candidateName) == 0 && StringLen(candidateFamily) > 0)
      candidateName = candidateFamily;
}

bool RuntimeOperatingCohortAdmissionAllowsExecution(const string candidateName,
                                                    const string candidateFamily,
                                                    string &reasonCode)
{
   reasonCode = "";

   RefreshActiveOperatingCohortStatusBestEffort();
   RefreshExecutionAuthorityStatusBestEffort();

   if(!gExecutionAuthorityStatus.factory_governed_execution_authority_active)
   {
      reasonCode = "execution_authority_cutover_not_active";
      return false;
   }

   if(!gExecutionAuthorityStatus.active_operating_cohort_defined)
   {
      reasonCode = "active_operating_cohort_not_defined";
      return false;
   }

   string normalizedFamily = OperatingCohortNormalizeFamily(candidateFamily);
   if(!OperatingCohortFamilyAllowed(normalizedFamily))
   {
      reasonCode = "candidate_not_in_active_operating_cohort";
      return false;
   }

   return true;
}


datetime DiagnosticParseTimeText(const string textValue)
{
   string v = TrimString(textValue);
   if(StringLen(v) <= 0 || v == "0")
      return 0;
   return StringToTime(v);
}

string DiagnosticRuntimeDecisionText(const RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY)
      return "BUY";
   if(d == RUNTIME_ENTER_SELL)
      return "SELL";
   if(d == RUNTIME_REJECT)
      return "REJECT";
   if(d == RUNTIME_WAIT)
      return "WAIT";
   return "UNKNOWN";
}

void InitDiagnosticRuntimeSummary(DiagnosticRuntimeSummary &st)
{
   st.artifact_role = "RUNTIME_DIAGNOSTIC_SUMMARY";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_DIAGNOSTIC";
   st.summary_version = "H2_RUNTIME_DIAGNOSTIC_V1";
   st.update_source = "UNINITIALIZED";

   st.governance_state = "STARTUP_INIT";
   st.trading_allowed = false;
   st.degraded_mode = false;
   st.truth_ready = false;
   st.diagnostics_ready = false;
   st.rollback_recently_applied = false;
   st.governance_reason_code = "startup_state_incomplete";

   st.active_plan_id = "";
   st.active_mode = "";

   st.final_decision = "UNKNOWN";
   st.final_blocked = false;
   st.final_blocking_layer = "";
   st.final_block_reason_code = "";

   st.dominant_failure = "";
   st.dominant_failure_source = "";
   st.dominant_failure_pressure = "";

   st.zone_name = "";
   st.best_strategy_id = "";
   st.consensus_label = "";
   st.governor_state = "NORMAL";
   st.zone_coverage_label = "";
   st.lifecycle_state = "";

   st.consensus_strength = 0.0;
   st.conflict_score = 0.0;
   st.council_quality = 0.0;
   st.environment_score = 0.0;

   st.decision_id = "";
   st.execution_path = "";

   st.last_open_decision_id = "";
   st.last_open_position_id = 0;
   st.last_open_entry_deal_id = 0;

   st.last_close_decision_id = "";
   st.last_close_position_id = 0;
   st.last_close_deal_id = 0;
   st.last_close_trade_result = "";
   st.last_close_profit = 0.0;
   st.last_close_time = 0;

   st.note = "";
   st.evaluated_at = TimeCurrent();
}

void EnsureDiagnosticRuntimeSummaryInitialized()
{
   if(gDiagnosticRuntimeSummaryInitialized)
      return;

   InitDiagnosticRuntimeSummary(gDiagnosticRuntimeSummary);
   gDiagnosticRuntimeSummaryInitialized = true;
}

void DiagnosticRuntimeSeedCycleBase(const string updateSource)
{
   EnsureDiagnosticRuntimeSummaryInitialized();

   gDiagnosticRuntimeSummary.artifact_role = "RUNTIME_DIAGNOSTIC_SUMMARY";
   gDiagnosticRuntimeSummary.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_DIAGNOSTIC";
   gDiagnosticRuntimeSummary.summary_version = "H2_RUNTIME_DIAGNOSTIC_V1";
   gDiagnosticRuntimeSummary.update_source = updateSource;

   gDiagnosticRuntimeSummary.governance_state = gRuntimeGovernance.governance_state;
   gDiagnosticRuntimeSummary.trading_allowed = gRuntimeGovernance.trading_allowed;
   gDiagnosticRuntimeSummary.degraded_mode = gRuntimeGovernance.degraded_mode;
   gDiagnosticRuntimeSummary.truth_ready = gRuntimeGovernance.truth_ready;
   gDiagnosticRuntimeSummary.diagnostics_ready = gRuntimeGovernance.diagnostics_ready;
   gDiagnosticRuntimeSummary.rollback_recently_applied = gRuntimeGovernance.rollback_recently_applied;
   gDiagnosticRuntimeSummary.governance_reason_code = gRuntimeGovernance.reason_code;

   gDiagnosticRuntimeSummary.active_plan_id = (StringLen(TrimString(gRuntimeGovernance.active_plan_id)) > 0 ? gRuntimeGovernance.active_plan_id : gPlan.plan_id);
   gDiagnosticRuntimeSummary.active_mode = (StringLen(TrimString(gRuntimeGovernance.active_mode)) > 0 ? gRuntimeGovernance.active_mode : NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode));

   gDiagnosticRuntimeSummary.final_decision = "UNKNOWN";
   gDiagnosticRuntimeSummary.final_blocked = false;
   gDiagnosticRuntimeSummary.final_blocking_layer = "";
   gDiagnosticRuntimeSummary.final_block_reason_code = "";

   gDiagnosticRuntimeSummary.dominant_failure = "";
   gDiagnosticRuntimeSummary.dominant_failure_source = "";
   gDiagnosticRuntimeSummary.dominant_failure_pressure = "";

   gDiagnosticRuntimeSummary.zone_name = "";
   gDiagnosticRuntimeSummary.best_strategy_id = "";
   gDiagnosticRuntimeSummary.consensus_label = "";
   gDiagnosticRuntimeSummary.governor_state = (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL");
   gDiagnosticRuntimeSummary.zone_coverage_label = "";
   gDiagnosticRuntimeSummary.lifecycle_state = "";

   gDiagnosticRuntimeSummary.consensus_strength = 0.0;
   gDiagnosticRuntimeSummary.conflict_score = 0.0;
   gDiagnosticRuntimeSummary.council_quality = 0.0;
   gDiagnosticRuntimeSummary.environment_score = 0.0;

   gDiagnosticRuntimeSummary.decision_id = "";
   gDiagnosticRuntimeSummary.execution_path = "";
   gDiagnosticRuntimeSummary.note = "";
   gDiagnosticRuntimeSummary.evaluated_at = TimeCurrent();
}

void DiagnosticRuntimeApplyFailureFallbacks()
{
   if(StringLen(TrimString(gDiagnosticRuntimeSummary.dominant_failure)) > 0)
      return;

   if(gHasFailureCluster && StringLen(TrimString(gFailureCluster.dominant_failure_class)) > 0 && gFailureCluster.dominant_failure_class != "UNKNOWN_FAILURE")
   {
      gDiagnosticRuntimeSummary.dominant_failure = gFailureCluster.dominant_failure_class;
      gDiagnosticRuntimeSummary.dominant_failure_source = "FAILURE_CLUSTER";
      gDiagnosticRuntimeSummary.dominant_failure_pressure = DoubleToString(gFailureCluster.failure_cluster_score, 2);
      return;
   }

   if(StringLen(TrimString(gDecisionFailure.failure_class)) > 0 && gDecisionFailure.failure_class != "UNKNOWN_FAILURE")
   {
      gDiagnosticRuntimeSummary.dominant_failure = gDecisionFailure.failure_class;
      gDiagnosticRuntimeSummary.dominant_failure_source = "DECISION_FAILURE_CLASSIFIER";
      gDiagnosticRuntimeSummary.dominant_failure_pressure = DoubleToString(gDecisionFailure.failure_severity, 2);
   }
}

void DiagnosticRuntimeApplyRoutedContext(const RoutedRuntimeEvaluation &routed)
{
   EnsureDiagnosticRuntimeSummaryInitialized();

   if(StringLen(TrimString(routed.active_mode)) > 0)
      gDiagnosticRuntimeSummary.active_mode = routed.active_mode;

   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      gDiagnosticRuntimeSummary.zone_name = routed.council.env.zone_name;
      gDiagnosticRuntimeSummary.best_strategy_id = routed.council.aggregate.best_strategy_id;
      gDiagnosticRuntimeSummary.consensus_label = routed.council.aggregate.consensus_label;
      gDiagnosticRuntimeSummary.zone_coverage_label = routed.council.zone_coverage.coverage_label;
      gDiagnosticRuntimeSummary.consensus_strength = routed.council.aggregate.consensus_strength;
      gDiagnosticRuntimeSummary.conflict_score = routed.council.aggregate.conflict_score;
      gDiagnosticRuntimeSummary.council_quality = routed.council.aggregate.council_quality;
      gDiagnosticRuntimeSummary.environment_score = routed.council.aggregate.environment_score;

      if(gDiagnosticRuntimeSummary.environment_score <= 0.0)
         gDiagnosticRuntimeSummary.environment_score = routed.council.env.total_score;

      if(routed.council.failure_detector.valid && StringLen(TrimString(routed.council.failure_detector.dominant_failure_tag)) > 0)
      {
         gDiagnosticRuntimeSummary.dominant_failure = routed.council.failure_detector.dominant_failure_tag;
         gDiagnosticRuntimeSummary.dominant_failure_source = "COUNCIL_FAILURE_DETECTOR";
         gDiagnosticRuntimeSummary.dominant_failure_pressure = routed.council.failure_detector.pressure_label;
      }
   }

   DiagnosticRuntimeApplyFailureFallbacks();
}

bool DiagnosticBlockingLayerIsBlocking(const string blockingLayer)
{
   string layer = TrimString(blockingLayer);

   if(StringLen(layer) <= 0)
      return false;

   if(layer == "wait_no_entry")
      return false;

   return true;
}

string DiagnosticInferRejectBlockingLayer(const RoutedRuntimeEvaluation &routed)
{
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      if(routed.council.pre_ai_gate.valid && !routed.council.pre_ai_gate.passed)
         return "council_pre_ai_rejection";

      if(routed.council.env.valid && !routed.council.env.tradable)
         return "explicit_no_trade_environment_rejection";

      if(routed.council.aggregate.conflict_score >= 0.40)
         return "council_conflict_rejection";

      if(!routed.council.aggregate.confirm_role_present)
         return "council_confirmation_rejection";

      if(routed.council.aggregate.council_quality < 0.55)
         return "council_quality_rejection";
   }

   return "decision_reject";
}

string DiagnosticInferRejectReasonCode(const RoutedRuntimeEvaluation &routed)
{
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      if(routed.council.pre_ai_gate.valid && !routed.council.pre_ai_gate.passed && StringLen(TrimString(routed.council.pre_ai_gate.reason)) > 0)
         return routed.council.pre_ai_gate.reason;

      if(routed.council.env.valid && !routed.council.env.tradable && StringLen(TrimString(routed.council.env.reject_reason)) > 0)
         return routed.council.env.reject_reason;

      if(routed.council.failure_detector.valid && StringLen(TrimString(routed.council.failure_detector.dominant_failure_tag)) > 0)
         return routed.council.failure_detector.dominant_failure_tag;
   }

   if(StringLen(TrimString(gDecisionFailure.failure_class)) > 0)
      return gDecisionFailure.failure_class;

   return routed.base_eval.reason;
}

string DiagnosticInferWaitBlockingLayer(const RoutedRuntimeEvaluation &routed)
{
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      if(routed.council.env.valid && !routed.council.env.tradable)
         return "explicit_no_trade_environment_rejection";

      if(routed.council.pre_ai_gate.valid && !routed.council.pre_ai_gate.passed)
         return "council_pre_ai_rejection";

      if(routed.council.aggregate.conflict_score >= 0.40)
         return "council_conflict_rejection";
   }

   return "wait_no_entry";
}

string DiagnosticInferWaitReasonCode(const RoutedRuntimeEvaluation &routed)
{
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      if(routed.council.env.valid && !routed.council.env.tradable && StringLen(TrimString(routed.council.env.reject_reason)) > 0)
         return routed.council.env.reject_reason;

      if(routed.council.pre_ai_gate.valid && !routed.council.pre_ai_gate.passed && StringLen(TrimString(routed.council.pre_ai_gate.reason)) > 0)
         return routed.council.pre_ai_gate.reason;
   }

   if(StringLen(TrimString(routed.base_eval.reason)) > 0)
      return routed.base_eval.reason;

   return "wait_for_better_setup";
}

void DiagnosticRuntimeSetOutcome(const string finalDecision,
                                 const bool finalBlocked,
                                 const string finalBlockingLayer,
                                 const string reasonCode,
                                 const string executionPath,
                                 const string note)
{
   EnsureDiagnosticRuntimeSummaryInitialized();

   gDiagnosticRuntimeSummary.final_decision = finalDecision;
   gDiagnosticRuntimeSummary.final_blocked = finalBlocked;
   gDiagnosticRuntimeSummary.final_blocking_layer = finalBlockingLayer;
   gDiagnosticRuntimeSummary.final_block_reason_code = reasonCode;
   gDiagnosticRuntimeSummary.execution_path = executionPath;
   gDiagnosticRuntimeSummary.note = note;
   gDiagnosticRuntimeSummary.evaluated_at = TimeCurrent();
}

void DiagnosticRuntimeSetDecisionId(const string decisionId)
{
   EnsureDiagnosticRuntimeSummaryInitialized();
   gDiagnosticRuntimeSummary.decision_id = decisionId;
}

void DiagnosticRuntimeSetLifecycleState(const string lifecycleState)
{
   EnsureDiagnosticRuntimeSummaryInitialized();
   gDiagnosticRuntimeSummary.lifecycle_state = lifecycleState;
}

void DiagnosticRuntimeRecordTradeOpen(const string decisionId, const string finalDecision, const bool opened)
{
   EnsureDiagnosticRuntimeSummaryInitialized();

   gDiagnosticRuntimeSummary.decision_id = decisionId;
   gDiagnosticRuntimeSummary.final_decision = finalDecision;
   gDiagnosticRuntimeSummary.final_blocked = (!opened);
   gDiagnosticRuntimeSummary.final_blocking_layer = (opened ? "" : "execution_open_failed");
   gDiagnosticRuntimeSummary.final_block_reason_code = (opened ? "" : "execution_open_failed");
   gDiagnosticRuntimeSummary.execution_path = (opened ? "TRADE_OPEN_EXECUTED" : "TRADE_OPEN_FAILED");
   gDiagnosticRuntimeSummary.last_open_decision_id = decisionId;
   gDiagnosticRuntimeSummary.last_open_position_id = gLastOpenCorrelation.position_id;
   gDiagnosticRuntimeSummary.last_open_entry_deal_id = gLastOpenCorrelation.entry_deal_id;
   gDiagnosticRuntimeSummary.note = (opened ? "trade_open_link_visible" : "trade_open_failed_after_permission");
   gDiagnosticRuntimeSummary.evaluated_at = TimeCurrent();
}

void DiagnosticRuntimeRecordTradeClose(const TradeFeedbackRecord &fb)
{
   EnsureDiagnosticRuntimeSummaryInitialized();

   string linkedDecisionId = (StringLen(TrimString(fb.decision_id)) > 0 ? fb.decision_id : fb.correlated_decision_id);

   gDiagnosticRuntimeSummary.last_close_decision_id = linkedDecisionId;
   gDiagnosticRuntimeSummary.last_close_position_id = fb.position_id;
   gDiagnosticRuntimeSummary.last_close_deal_id = fb.close_deal_id;
   gDiagnosticRuntimeSummary.last_close_trade_result = fb.result;
   gDiagnosticRuntimeSummary.last_close_profit = fb.profit;
   gDiagnosticRuntimeSummary.last_close_time = fb.close_time;
   gDiagnosticRuntimeSummary.note = "latest_trade_close_outcome_visible";
   gDiagnosticRuntimeSummary.evaluated_at = TimeCurrent();
}

string BuildDiagnosticRuntimeSummaryText(const DiagnosticRuntimeSummary &st)
{
   string s = "";
   s += "diagnostic_runtime_summary\n";
   s += "artifact_role=" + st.artifact_role + "\n";
   s += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   s += "summary_version=" + st.summary_version + "\n";
   s += "trust_rule=diagnostic_only_non_authoritative_best_effort\n";
   s += "update_source=" + st.update_source + "\n";
   s += "governance_state=" + st.governance_state + "\n";
   s += "trading_allowed=" + DiagnosticBoolText(st.trading_allowed) + "\n";
   s += "degraded_mode=" + DiagnosticBoolText(st.degraded_mode) + "\n";
   s += "truth_ready=" + DiagnosticBoolText(st.truth_ready) + "\n";
   s += "diagnostics_ready=" + DiagnosticBoolText(st.diagnostics_ready) + "\n";
   s += "rollback_recently_applied=" + DiagnosticBoolText(st.rollback_recently_applied) + "\n";
   s += "governance_reason_code=" + st.governance_reason_code + "\n";
   s += "active_plan_id=" + st.active_plan_id + "\n";
   s += "active_mode=" + st.active_mode + "\n";
   s += "final_decision=" + st.final_decision + "\n";
   s += "final_blocked=" + DiagnosticBoolText(st.final_blocked) + "\n";
   s += "final_blocking_layer=" + st.final_blocking_layer + "\n";
   s += "final_block_reason_code=" + st.final_block_reason_code + "\n";
   s += "dominant_failure=" + st.dominant_failure + "\n";
   s += "dominant_failure_source=" + st.dominant_failure_source + "\n";
   s += "dominant_failure_pressure=" + st.dominant_failure_pressure + "\n";
   s += "zone_name=" + st.zone_name + "\n";
   s += "best_strategy_id=" + st.best_strategy_id + "\n";
   s += "consensus_label=" + st.consensus_label + "\n";
   s += "governor_state=" + st.governor_state + "\n";
   s += "zone_coverage_label=" + st.zone_coverage_label + "\n";
   s += "lifecycle_state=" + st.lifecycle_state + "\n";
   s += "consensus_strength=" + DoubleToString(st.consensus_strength, 3) + "\n";
   s += "conflict_score=" + DoubleToString(st.conflict_score, 3) + "\n";
   s += "council_quality=" + DoubleToString(st.council_quality, 3) + "\n";
   s += "environment_score=" + DoubleToString(st.environment_score, 3) + "\n";
   s += "decision_id=" + st.decision_id + "\n";
   s += "execution_path=" + st.execution_path + "\n";
   s += "last_open_decision_id=" + st.last_open_decision_id + "\n";
   s += "last_open_position_id=" + DiagnosticU64(st.last_open_position_id) + "\n";
   s += "last_open_entry_deal_id=" + DiagnosticU64(st.last_open_entry_deal_id) + "\n";
   s += "last_close_decision_id=" + st.last_close_decision_id + "\n";
   s += "last_close_position_id=" + DiagnosticU64(st.last_close_position_id) + "\n";
   s += "last_close_deal_id=" + DiagnosticU64(st.last_close_deal_id) + "\n";
   s += "last_close_trade_result=" + st.last_close_trade_result + "\n";
   s += "last_close_profit=" + DoubleToString(st.last_close_profit, 2) + "\n";
   s += "last_close_time=" + DiagnosticTimeText(st.last_close_time) + "\n";
   s += "note=" + st.note + "\n";
   s += "evaluated_at=" + DiagnosticTimeText(st.evaluated_at) + "\n";
   return s;
}

string BuildDiagnosticRuntimeSummaryJson(const DiagnosticRuntimeSummary &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"trust_rule\":\"diagnostic_only_non_authoritative_best_effort\"";
   j += ",\"update_source\":\"" + JsonEscapeString(st.update_source) + "\"";
   j += ",\"governance_state\":\"" + JsonEscapeString(st.governance_state) + "\"";
   j += ",\"trading_allowed\":" + string(st.trading_allowed ? "true" : "false");
   j += ",\"degraded_mode\":" + string(st.degraded_mode ? "true" : "false");
   j += ",\"truth_ready\":" + string(st.truth_ready ? "true" : "false");
   j += ",\"diagnostics_ready\":" + string(st.diagnostics_ready ? "true" : "false");
   j += ",\"rollback_recently_applied\":" + string(st.rollback_recently_applied ? "true" : "false");
   j += ",\"governance_reason_code\":\"" + JsonEscapeString(st.governance_reason_code) + "\"";
   j += ",\"active_plan_id\":\"" + JsonEscapeString(st.active_plan_id) + "\"";
   j += ",\"active_mode\":\"" + JsonEscapeString(st.active_mode) + "\"";
   j += ",\"final_decision\":\"" + JsonEscapeString(st.final_decision) + "\"";
   j += ",\"final_blocked\":" + string(st.final_blocked ? "true" : "false");
   j += ",\"final_blocking_layer\":\"" + JsonEscapeString(st.final_blocking_layer) + "\"";
   j += ",\"final_block_reason_code\":\"" + JsonEscapeString(st.final_block_reason_code) + "\"";
   j += ",\"dominant_failure\":\"" + JsonEscapeString(st.dominant_failure) + "\"";
   j += ",\"dominant_failure_source\":\"" + JsonEscapeString(st.dominant_failure_source) + "\"";
   j += ",\"dominant_failure_pressure\":\"" + JsonEscapeString(st.dominant_failure_pressure) + "\"";
   j += ",\"zone_name\":\"" + JsonEscapeString(st.zone_name) + "\"";
   j += ",\"best_strategy_id\":\"" + JsonEscapeString(st.best_strategy_id) + "\"";
   j += ",\"consensus_label\":\"" + JsonEscapeString(st.consensus_label) + "\"";
   j += ",\"governor_state\":\"" + JsonEscapeString(st.governor_state) + "\"";
   j += ",\"zone_coverage_label\":\"" + JsonEscapeString(st.zone_coverage_label) + "\"";
   j += ",\"lifecycle_state\":\"" + JsonEscapeString(st.lifecycle_state) + "\"";
   j += ",\"consensus_strength\":" + DoubleToString(st.consensus_strength, 3);
   j += ",\"conflict_score\":" + DoubleToString(st.conflict_score, 3);
   j += ",\"council_quality\":" + DoubleToString(st.council_quality, 3);
   j += ",\"environment_score\":" + DoubleToString(st.environment_score, 3);
   j += ",\"decision_id\":\"" + JsonEscapeString(st.decision_id) + "\"";
   j += ",\"execution_path\":\"" + JsonEscapeString(st.execution_path) + "\"";
   j += ",\"last_open_decision_id\":\"" + JsonEscapeString(st.last_open_decision_id) + "\"";
   j += ",\"last_open_position_id\":\"" + DiagnosticU64(st.last_open_position_id) + "\"";
   j += ",\"last_open_entry_deal_id\":\"" + DiagnosticU64(st.last_open_entry_deal_id) + "\"";
   j += ",\"last_close_decision_id\":\"" + JsonEscapeString(st.last_close_decision_id) + "\"";
   j += ",\"last_close_position_id\":\"" + DiagnosticU64(st.last_close_position_id) + "\"";
   j += ",\"last_close_deal_id\":\"" + DiagnosticU64(st.last_close_deal_id) + "\"";
   j += ",\"last_close_trade_result\":\"" + JsonEscapeString(st.last_close_trade_result) + "\"";
   j += ",\"last_close_profit\":" + DoubleToString(st.last_close_profit, 2);
   j += ",\"last_close_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.last_close_time)) + "\"";
   j += ",\"note\":\"" + JsonEscapeString(st.note) + "\"";
   j += ",\"evaluated_at\":\"" + JsonEscapeString(DiagnosticTimeText(st.evaluated_at)) + "\"";
   j += "}";
   return j;
}

bool DiagnosticRuntimeDecisionPromotableToMeaningfulEvent(const string finalDecision)
{
   string decision = TrimString(finalDecision);
   StringToUpper(decision);
   return (decision == "REJECT" ||
           decision == "WAIT" ||
           decision == "GUARDRAIL_BLOCK" ||
           decision == "EXECUTION" ||
           decision == "BUY" ||
           decision == "SELL");
}

string DiagnosticRuntimeMeaningfulEventType(const DiagnosticRuntimeSummary &st)
{
   string decision = TrimString(st.final_decision);
   StringToUpper(decision);

   if(decision == "BUY" || decision == "SELL" || st.execution_path == "TRADE_OPEN_EXECUTED")
      return "EXECUTION";
   if(decision == "REJECT")
      return "REJECT";
   if(decision == "WAIT")
      return "WAIT";
   if(decision == "GUARDRAIL_BLOCK")
      return "GUARDRAIL_BLOCK";

   return "";
}

string DiagnosticRuntimeMeaningfulEventShortNote(const DiagnosticRuntimeSummary &st, const string eventType)
{
   string layer = DashboardValueOr(st.final_blocking_layer, "unknown layer");
   string reason = DashboardValueOr(st.final_block_reason_code, "no explicit reason");
   string strategy = DashboardValueOr(st.best_strategy_id, "unavailable");

   if(eventType == "REJECT")
      return "Live runtime decision rejected at " + layer + " with reason " + reason + ".";
   if(eventType == "WAIT")
      return "Live runtime decision is waiting at " + layer + " with reason " + reason + ".";
   if(eventType == "GUARDRAIL_BLOCK")
      return "Live runtime guardrail block is active at " + layer + " with reason " + reason + ".";
   if(eventType == "EXECUTION")
      return "Live runtime execution authorized for " + strategy + " via " + DashboardValueOr(st.execution_path, "execution path unavailable") + ".";
   return "";
}

void PromoteDiagnosticRuntimeSummaryToMeaningfulEventBestEffort()
{
   EnsureDiagnosticRuntimeSummaryInitialized();

   string eventType = DiagnosticRuntimeMeaningfulEventType(gDiagnosticRuntimeSummary);
   if(!DiagnosticRuntimeDecisionPromotableToMeaningfulEvent(eventType))
      return;

   string candidateFamily = gCurrentDecisionCandidateFamily;
   if(StringLen(TrimString(candidateFamily)) == 0 && StringLen(TrimString(gLastExecutedCandidateFamily)) > 0)
      candidateFamily = gLastExecutedCandidateFamily;

   string candidateName = gCurrentDecisionCandidateName;
   if(StringLen(TrimString(candidateName)) == 0 && StringLen(TrimString(gDiagnosticRuntimeSummary.best_strategy_id)) > 0)
      candidateName = gDiagnosticRuntimeSummary.best_strategy_id;
   if(StringLen(TrimString(candidateName)) == 0 && StringLen(TrimString(gLastExecutedCandidateName)) > 0)
      candidateName = gLastExecutedCandidateName;

   UpdateLastMeaningfulRuntimeEventBestEffort(
      eventType,
      candidateName,
      candidateFamily,
      DashboardValueOr(gDiagnosticRuntimeSummary.final_block_reason_code, gDiagnosticRuntimeSummary.governance_reason_code),
      "",
      DiagnosticRuntimeMeaningfulEventShortNote(gDiagnosticRuntimeSummary, eventType),
      DashboardValueOr(gDiagnosticRuntimeSummary.final_blocking_layer, gDiagnosticRuntimeSummary.update_source),
      gDiagnosticRuntimeSummary.decision_id,
      gDiagnosticRuntimeSummary.evaluated_at
   );
}

void SaveDiagnosticRuntimeSummaryBestEffort()
{
   EnsureDiagnosticRuntimeSummaryInitialized();
   WriteTextFileAll(DiagnosticRuntimeSummaryTxtPath(), BuildDiagnosticRuntimeSummaryText(gDiagnosticRuntimeSummary));
   WriteTextFileAll(DiagnosticRuntimeSummaryJsonPath(), BuildDiagnosticRuntimeSummaryJson(gDiagnosticRuntimeSummary));
   PromoteDiagnosticRuntimeSummaryToMeaningfulEventBestEffort();
   RefreshAIOperationalReviewBestEffort();
   RefreshOperationalIntegrityStatusBestEffort();
   RefreshReplayValidationArtifactsBestEffort();
}


void InitReplayValidationSummary(ReplayValidationSummary &st)
{
   st.artifact_role = "REPLAY_VALIDATION_SUMMARY";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_REPLAY";
   st.summary_version = "H4_REPLAY_VALIDATION_V1";
   st.trust_rule = "best_effort_forensic_review_only";
   st.update_source = "UNINITIALIZED";

   st.replay_case_type = "NO_CASE";
   st.replay_case_scope = "none";

   st.governance_state = "UNKNOWN";
   st.trading_allowed = false;

   st.active_plan_id = "";
   st.active_mode = "";

   st.regime_label = "";
   st.regime_confidence = 0.0;

   st.zone_name = "";
   st.best_strategy_id = "";
   st.consensus_label = "";
   st.consensus_strength = 0.0;
   st.conflict_score = 0.0;
   st.council_quality = 0.0;
   st.environment_score = 0.0;

   st.dominant_failure = "";
   st.dominant_failure_source = "";
   st.dominant_failure_pressure = "";

   st.final_decision = "";
   st.final_blocking_layer = "";
   st.final_block_reason_code = "";
   st.execution_path = "";

   st.decision_id = "";
   st.correlated_decision_id = "";
   st.position_id = 0;
   st.entry_deal_id = 0;
   st.close_deal_id = 0;
   st.trade_result = "";
   st.close_profit = 0.0;

   st.decision_time = 0;
   st.open_time = 0;
   st.close_time = 0;
   st.evaluated_at = TimeCurrent();

   st.replay_confidence = "LOW";
   st.replay_data_limitations = "insufficient_structured_data";
}

void EnsureReplayValidationSummaryInitialized()
{
   if(gReplayValidationSummaryInitialized)
      return;

   InitReplayValidationSummary(gReplayValidationSummary);
   gReplayValidationSummaryInitialized = true;
}

bool ReplayExtractLatestFeedbackObject(const string recordType, string &objectJson)
{
   objectJson = "";

   string raw = "";
   if(!ReadTextFileAll("AI\\council_feedback.json", raw))
      return false;

   string needle = "\"record_type\":\"" + recordType + "\"";
   int pos = StringFind(raw, needle);
   if(pos < 0)
      return false;

   int lastPos = pos;
   while(true)
   {
      int nextPos = StringFind(raw, needle, lastPos + 1);
      if(nextPos < 0)
         break;
      lastPos = nextPos;
   }

   int start = lastPos;
   while(start >= 0 && StringGetCharacter(raw, start) != '{')
      start--;
   if(start < 0)
      return false;

   int len = StringLen(raw);
   int end = lastPos;
   while(end < len && StringGetCharacter(raw, end) != '}')
      end++;
   if(end >= len)
      return false;

   objectJson = StringSubstr(raw, start, end - start + 1);
   return true;
}

ulong ReplayExtractJsonULongFlexible(const string json, const string key)
{
   ulong value = JA_ExtractJsonULong(json, key);
   if(value > 0)
      return value;

   string raw = JA_ExtractJsonString(json, key);
   raw = TrimString(raw);
   if(StringLen(raw) <= 0)
      return 0;

   return (ulong)StringToInteger(raw);
}

int ReplayConfidenceScore(const string confidence)
{
   string v = TrimString(confidence);
   StringToUpper(v);
   if(v == "HIGH")
      return 300;
   if(v == "MEDIUM")
      return 200;
   return 100;
}

int ReplayCaseTypeScore(const string caseType)
{
   string v = TrimString(caseType);
   StringToUpper(v);
   if(v == "CLOSED_TRADE")
      return 40;
   if(v == "EXECUTED_TRADE")
      return 30;
   if(v == "BLOCKED_DECISION")
      return 20;
   if(v == "DECISION_ONLY")
      return 10;
   return 0;
}

int ReplayCandidateScore(const ReplayValidationSummary &st)
{
   return ReplayConfidenceScore(st.replay_confidence) + ReplayCaseTypeScore(st.replay_case_type);
}

void ReplaySelectBetterCandidate(const ReplayValidationSummary &candidate, bool &hasBest, ReplayValidationSummary &best)
{
   if(!hasBest)
   {
      best = candidate;
      hasBest = true;
      return;
   }

   int candidateScore = ReplayCandidateScore(candidate);
   int bestScore = ReplayCandidateScore(best);
   if(candidateScore > bestScore)
   {
      best = candidate;
      return;
   }

   if(candidateScore == bestScore && candidate.evaluated_at > best.evaluated_at)
      best = candidate;
}

bool ReplayBuildCandidateFromDiagnostic(ReplayValidationSummary &st)
{
   InitReplayValidationSummary(st);

   string raw = "";
   if(!ReadTextFileAll(DiagnosticRuntimeSummaryJsonPath(), raw))
      return false;

   string updateSource = JA_ExtractJsonString(raw, "update_source");
   if(StringFind(updateSource, "PACKAGE_PLACEHOLDER") >= 0)
      return false;

   st.update_source = "diagnostic_runtime_summary.json";
   st.governance_state = JA_ExtractJsonString(raw, "governance_state");
   JA_ExtractJsonBool(raw, "trading_allowed", st.trading_allowed);
   st.active_plan_id = JA_ExtractJsonString(raw, "active_plan_id");
   st.active_mode = JA_ExtractJsonString(raw, "active_mode");

   st.zone_name = JA_ExtractJsonString(raw, "zone_name");
   st.best_strategy_id = JA_ExtractJsonString(raw, "best_strategy_id");
   st.consensus_label = JA_ExtractJsonString(raw, "consensus_label");
   st.consensus_strength = JA_ExtractJsonDouble(raw, "consensus_strength");
   st.conflict_score = JA_ExtractJsonDouble(raw, "conflict_score");
   st.council_quality = JA_ExtractJsonDouble(raw, "council_quality");
   st.environment_score = JA_ExtractJsonDouble(raw, "environment_score");

   st.dominant_failure = JA_ExtractJsonString(raw, "dominant_failure");
   st.dominant_failure_source = JA_ExtractJsonString(raw, "dominant_failure_source");
   st.dominant_failure_pressure = JA_ExtractJsonString(raw, "dominant_failure_pressure");

   st.final_decision = JA_ExtractJsonString(raw, "final_decision");
   st.final_blocking_layer = JA_ExtractJsonString(raw, "final_blocking_layer");
   st.final_block_reason_code = JA_ExtractJsonString(raw, "final_block_reason_code");
   st.execution_path = JA_ExtractJsonString(raw, "execution_path");

   st.decision_id = JA_ExtractJsonString(raw, "decision_id");
   st.correlated_decision_id = JA_ExtractJsonString(raw, "last_open_decision_id");

   ulong openPositionId = ReplayExtractJsonULongFlexible(raw, "last_open_position_id");
   ulong openEntryDealId = ReplayExtractJsonULongFlexible(raw, "last_open_entry_deal_id");
   ulong closePositionId = ReplayExtractJsonULongFlexible(raw, "last_close_position_id");
   ulong closeDealId = ReplayExtractJsonULongFlexible(raw, "last_close_deal_id");

   st.position_id = openPositionId;
   st.entry_deal_id = openEntryDealId;
   st.close_deal_id = closeDealId;
   st.trade_result = JA_ExtractJsonString(raw, "last_close_trade_result");
   st.close_profit = JA_ExtractJsonDouble(raw, "last_close_profit");

   st.close_time = DiagnosticParseTimeText(JA_ExtractJsonString(raw, "last_close_time"));
   st.evaluated_at = DiagnosticParseTimeText(JA_ExtractJsonString(raw, "evaluated_at"));

   if(st.close_time > 0 || st.close_deal_id > 0 || StringLen(TrimString(st.trade_result)) > 0)
   {
      if(closePositionId > 0)
         st.position_id = closePositionId;

      if(st.position_id > 0 && openPositionId > 0 && st.position_id == openPositionId)
         st.entry_deal_id = openEntryDealId;
      else
         st.entry_deal_id = 0;

      string feedbackObj = "";
      if(ReplayExtractLatestFeedbackObject("TRADE_CLOSE_OUTCOME", feedbackObj) && StringLen(TrimString(feedbackObj)) > 0)
      {
         ulong feedbackCloseDealId = ReplayExtractJsonULongFlexible(feedbackObj, "close_deal_id");
         datetime feedbackCloseTime = (datetime)JA_ExtractJsonInt(feedbackObj, "close_time");

         bool sameClose = false;
         if(st.close_deal_id > 0 && feedbackCloseDealId > 0 && st.close_deal_id == feedbackCloseDealId)
            sameClose = true;
         else if(st.close_time > 0 && feedbackCloseTime > 0 && MathAbs((int)st.close_time - (int)feedbackCloseTime) <= 2)
            sameClose = true;

         if(sameClose)
         {
            if(st.position_id == 0)
               st.position_id = ReplayExtractJsonULongFlexible(feedbackObj, "position_id");
            if(st.entry_deal_id == 0)
               st.entry_deal_id = ReplayExtractJsonULongFlexible(feedbackObj, "entry_deal_id");
            if(st.close_deal_id == 0)
               st.close_deal_id = feedbackCloseDealId;
         }
      }

      st.replay_case_type = "CLOSED_TRADE";
      st.replay_case_scope = "latest_close";
      st.replay_confidence = ((StringLen(TrimString(st.decision_id)) > 0 || StringLen(TrimString(st.correlated_decision_id)) > 0 || st.position_id > 0 || st.close_deal_id > 0) ? "HIGH" : "MEDIUM");
      st.replay_data_limitations = (st.replay_confidence == "HIGH" ? "built_from_runtime_diagnostic_with_close_linkage" : "close_visible_but_linkage_is_partial");
      return true;
   }

   if(st.position_id > 0 || st.entry_deal_id > 0 || StringLen(TrimString(st.correlated_decision_id)) > 0)
   {
      st.replay_case_type = "EXECUTED_TRADE";
      st.replay_case_scope = "latest_open";
      st.replay_confidence = ((st.position_id > 0 && StringLen(TrimString(st.correlated_decision_id)) > 0) ? "HIGH" : "MEDIUM");
      st.replay_data_limitations = (st.replay_confidence == "HIGH" ? "built_from_runtime_diagnostic_with_open_linkage" : "open_visible_but_decision_context_is_partial");
      return true;
   }

   bool finalBlocked = false;
   JA_ExtractJsonBool(raw, "final_blocked", finalBlocked);
   if(finalBlocked)
   {
      st.replay_case_type = "BLOCKED_DECISION";
      st.replay_case_scope = "latest_block";
      st.replay_confidence = (StringLen(TrimString(st.final_blocking_layer)) > 0 ? "HIGH" : "MEDIUM");
      st.replay_data_limitations = (st.replay_confidence == "HIGH" ? "built_from_runtime_diagnostic_with_explicit_blocking_layer" : "blocked_decision_visible_but_blocking_layer_is_partial");
      return true;
   }

   if(StringLen(TrimString(st.final_decision)) > 0)
   {
      st.replay_case_type = "DECISION_ONLY";
      st.replay_case_scope = "latest_decision";
      st.replay_confidence = "MEDIUM";
      st.replay_data_limitations = "built_from_runtime_diagnostic_without_open_or_close_linkage";
      return true;
   }

   return false;
}

bool ReplayBuildCandidateFromLatestBlockedDecision(ReplayValidationSummary &st)
{
   InitReplayValidationSummary(st);

   int h = FileOpen(PERF_JOURNAL_PATH, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   string latestLine = "";
   string latestTs = "";

   while(!FileIsEnding(h))
   {
      string line = TrimString(FileReadString(h));
      if(StringLen(line) <= 0)
         continue;

      string recordType = JA_ExtractJsonString(line, "record_type");
      if(recordType != "DECISION")
         continue;

      string blockingLayer = JA_ExtractJsonString(line, "final_blocking_layer");
      string finalDecision = JA_ExtractJsonString(line, "final_decision");
      if(StringLen(TrimString(blockingLayer)) <= 0 && finalDecision != "REJECT" && finalDecision != "WAIT")
         continue;

      string ts = JA_ExtractJsonString(line, "ts");
      if(StringLen(TrimString(ts)) <= 0)
         continue;

      if(StringLen(latestTs) <= 0 || StringCompare(ts, latestTs) > 0)
      {
         latestTs = ts;
         latestLine = line;
      }
   }

   FileClose(h);
   if(StringLen(latestLine) <= 0)
      return false;

   st.update_source = "ai_performance_journal.jsonl";
   st.replay_case_type = "BLOCKED_DECISION";
   st.replay_case_scope = "latest_block";
   st.governance_state = "UNKNOWN_FROM_JOURNAL";
   st.trading_allowed = false;
   st.active_plan_id = JA_ExtractJsonString(latestLine, "plan_id");
   st.active_mode = JA_ExtractJsonString(latestLine, "active_mode");
   st.regime_label = JA_ExtractJsonString(latestLine, "regime_label");
   st.regime_confidence = JA_ExtractJsonDouble(latestLine, "regime_confidence");
   st.dominant_failure = JA_ExtractJsonString(latestLine, "dominant_failure_class");
   if(StringLen(TrimString(st.dominant_failure)) <= 0)
      st.dominant_failure = JA_ExtractJsonString(latestLine, "failure_class");
   st.dominant_failure_source = JA_ExtractJsonString(latestLine, "failure_basis");
   st.dominant_failure_pressure = DoubleToString(JA_ExtractJsonDouble(latestLine, "failure_cluster_score"), 3);
   st.final_decision = JA_ExtractJsonString(latestLine, "final_decision");
   st.final_blocking_layer = JA_ExtractJsonString(latestLine, "final_blocking_layer");
   st.final_block_reason_code = JA_ExtractJsonString(latestLine, "final_block_reason_code");
   st.execution_path = JA_ExtractJsonString(latestLine, "execution_path");
   st.decision_id = JA_ExtractJsonString(latestLine, "decision_id");
   st.decision_time = DiagnosticParseTimeText(latestTs);
   st.evaluated_at = st.decision_time;

   st.replay_confidence = (StringLen(TrimString(st.final_blocking_layer)) > 0 && StringLen(TrimString(st.decision_id)) > 0 ? "HIGH" : "MEDIUM");
   st.replay_data_limitations = "journal_block_replay_without_runtime_governance_or_trade_linkage";
   return true;
}

bool ReplayBuildCandidateFromLatestTradeOpen(ReplayValidationSummary &st)
{
   InitReplayValidationSummary(st);

   int h = FileOpen(PERF_JOURNAL_PATH, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   string latestOpen = "";
   string latestOpenTs = "";
   string matchedDecision = "";

   while(!FileIsEnding(h))
   {
      string line = TrimString(FileReadString(h));
      if(StringLen(line) <= 0)
         continue;

      string recordType = JA_ExtractJsonString(line, "record_type");
      if(recordType == "TRADE_OPEN")
      {
         string ts = JA_ExtractJsonString(line, "ts");
         if(StringLen(TrimString(ts)) > 0 && (StringLen(latestOpenTs) <= 0 || StringCompare(ts, latestOpenTs) > 0))
         {
            latestOpenTs = ts;
            latestOpen = line;
         }
      }
   }

   FileClose(h);
   if(StringLen(latestOpen) <= 0)
      return false;

   string decisionId = JA_ExtractJsonString(latestOpen, "decision_id");
   if(StringLen(TrimString(decisionId)) > 0)
   {
      h = FileOpen(PERF_JOURNAL_PATH, FILE_READ | FILE_TXT | FILE_ANSI);
      if(h != INVALID_HANDLE)
      {
         while(!FileIsEnding(h))
         {
            string line = TrimString(FileReadString(h));
            if(StringLen(line) <= 0)
               continue;
            if(JA_ExtractJsonString(line, "record_type") != "DECISION")
               continue;
            if(JA_ExtractJsonString(line, "decision_id") == decisionId)
               matchedDecision = line;
         }
         FileClose(h);
      }
   }

   st.update_source = "ai_performance_journal.jsonl";
   st.replay_case_type = "EXECUTED_TRADE";
   st.replay_case_scope = "latest_open";
   st.governance_state = "UNKNOWN_FROM_JOURNAL";
   st.trading_allowed = true;
   st.active_plan_id = JA_ExtractJsonString(matchedDecision, "plan_id");
   st.active_mode = JA_ExtractJsonString(matchedDecision, "active_mode");
   st.regime_label = JA_ExtractJsonString(matchedDecision, "regime_label");
   st.regime_confidence = JA_ExtractJsonDouble(matchedDecision, "regime_confidence");
   st.final_decision = JA_ExtractJsonString(matchedDecision, "final_decision");
   if(StringLen(TrimString(st.final_decision)) <= 0)
      st.final_decision = JA_ExtractJsonString(latestOpen, "executed_direction");
   st.execution_path = JA_ExtractJsonString(latestOpen, "execution_path");
   st.decision_id = decisionId;
   st.position_id = ReplayExtractJsonULongFlexible(latestOpen, "position_id");
   st.entry_deal_id = ReplayExtractJsonULongFlexible(latestOpen, "entry_deal_id");
   st.open_time = DiagnosticParseTimeText(JA_ExtractJsonString(latestOpen, "entry_time"));
   if(st.open_time <= 0)
      st.open_time = DiagnosticParseTimeText(latestOpenTs);
   st.evaluated_at = st.open_time;

   bool matched = (StringLen(TrimString(matchedDecision)) > 0);
   st.replay_confidence = (matched ? "MEDIUM" : "LOW");
   st.replay_data_limitations = (matched ? "open_linkage_present_but_close_outcome_missing" : "trade_open_visible_but_decision_context_missing");
   return true;
}

bool ReplayBuildCandidateFromLatestClosedTrade(ReplayValidationSummary &st)
{
   InitReplayValidationSummary(st);

   int h = FileOpen(PERF_JOURNAL_PATH, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   string latestClose = "";
   string latestCloseTs = "";

   while(!FileIsEnding(h))
   {
      string line = TrimString(FileReadString(h));
      if(StringLen(line) <= 0)
         continue;

      string recordType = JA_ExtractJsonString(line, "record_type");
      if(recordType != "TRADE")
         continue;

      string tradeEventType = JA_ExtractJsonString(line, "trade_event_type");
      if(StringLen(TrimString(tradeEventType)) > 0 && tradeEventType != "TRADE_CLOSE")
         continue;

      string ts = JA_ExtractJsonString(line, "ts");
      if(StringLen(TrimString(ts)) <= 0)
         continue;

      if(StringLen(latestCloseTs) <= 0 || StringCompare(ts, latestCloseTs) > 0)
      {
         latestCloseTs = ts;
         latestClose = line;
      }
   }

   FileClose(h);
   if(StringLen(latestClose) <= 0)
      return false;

   string feedbackObj = "";
   ReplayExtractLatestFeedbackObject("TRADE_CLOSE_OUTCOME", feedbackObj);

   st.update_source = "ai_performance_journal.jsonl";
   st.replay_case_type = "CLOSED_TRADE";
   st.replay_case_scope = "latest_close";
   st.governance_state = "UNKNOWN_FROM_JOURNAL";
   st.trading_allowed = true;
   st.active_plan_id = JA_ExtractJsonString(latestClose, "plan_id");
   st.active_mode = JA_ExtractJsonString(latestClose, "active_mode");
   st.regime_label = JA_ExtractJsonString(latestClose, "regime_label");
   st.regime_confidence = JA_ExtractJsonDouble(latestClose, "regime_confidence");
   st.dominant_failure = JA_ExtractJsonString(latestClose, "failure_class");
   st.dominant_failure_source = JA_ExtractJsonString(latestClose, "failure_basis");
   st.dominant_failure_pressure = DoubleToString(JA_ExtractJsonDouble(latestClose, "failure_severity"), 3);
   st.final_decision = JA_ExtractJsonString(latestClose, "final_decision");
   st.execution_path = "TRADE_CLOSE_OBSERVED";
   st.decision_id = JA_ExtractJsonString(latestClose, "decision_id");
   st.correlated_decision_id = JA_ExtractJsonString(latestClose, "correlated_decision_id");
   st.position_id = ReplayExtractJsonULongFlexible(latestClose, "position_id");
   st.entry_deal_id = ReplayExtractJsonULongFlexible(latestClose, "entry_deal_id");
   st.close_deal_id = ReplayExtractJsonULongFlexible(latestClose, "close_deal_id");
   st.trade_result = JA_ExtractJsonString(latestClose, "trade_result");
   if(StringLen(TrimString(st.trade_result)) <= 0)
      st.trade_result = JA_ExtractJsonString(latestClose, "result");
   st.close_profit = JA_ExtractJsonDouble(latestClose, "profit");
   st.close_time = DiagnosticParseTimeText(latestCloseTs);
   st.evaluated_at = st.close_time;

   if(StringLen(TrimString(feedbackObj)) > 0)
   {
      datetime feedbackCloseTime = (datetime)JA_ExtractJsonInt(feedbackObj, "close_time");
      if((int)feedbackCloseTime > 0)
      {
         datetime closeTs = DiagnosticParseTimeText(latestCloseTs);
         if(MathAbs((int)closeTs - (int)feedbackCloseTime) <= 2)
         {
            if(st.close_deal_id == 0)
               st.close_deal_id = ReplayExtractJsonULongFlexible(feedbackObj, "close_deal_id");
            if(st.position_id == 0)
               st.position_id = ReplayExtractJsonULongFlexible(feedbackObj, "position_id");
            if(st.entry_deal_id == 0)
               st.entry_deal_id = ReplayExtractJsonULongFlexible(feedbackObj, "entry_deal_id");
            if(StringLen(TrimString(st.decision_id)) <= 0)
               st.decision_id = JA_ExtractJsonString(feedbackObj, "decision_id");
            if(StringLen(TrimString(st.correlated_decision_id)) <= 0)
               st.correlated_decision_id = JA_ExtractJsonString(feedbackObj, "correlated_decision_id");
            if(StringLen(TrimString(st.zone_name)) <= 0)
               st.zone_name = JA_ExtractJsonString(feedbackObj, "zone_name");
            if(StringLen(TrimString(st.best_strategy_id)) <= 0)
               st.best_strategy_id = JA_ExtractJsonString(feedbackObj, "best_strategy_id");
            st.consensus_strength = JA_ExtractJsonDouble(feedbackObj, "consensus_strength");
            st.conflict_score = JA_ExtractJsonDouble(feedbackObj, "conflict_score");
            st.council_quality = JA_ExtractJsonDouble(feedbackObj, "council_quality");
            st.environment_score = JA_ExtractJsonDouble(feedbackObj, "environment_score");
         }
      }
   }

   bool strongLink = (StringLen(TrimString(st.decision_id)) > 0 || StringLen(TrimString(st.correlated_decision_id)) > 0 || st.position_id > 0 || st.close_deal_id > 0);
   st.replay_confidence = (strongLink ? "MEDIUM" : "LOW");
   st.replay_data_limitations = (strongLink ? "close_outcome_visible_but_decision_chain_is_partial" : "close_outcome_visible_without_reliable_open_or_decision_linkage");
   return true;
}

bool ReplayBuildCandidateFromLatestDecisionSnapshot(ReplayValidationSummary &st)
{
   InitReplayValidationSummary(st);

   string obj = "";
   if(!ReplayExtractLatestFeedbackObject("DECISION_SNAPSHOT", obj))
      return false;

   st.update_source = "council_feedback.json";
   st.replay_case_type = "DECISION_ONLY";
   st.replay_case_scope = "latest_decision_snapshot";
   st.governance_state = "UNKNOWN_FROM_FEEDBACK";
   st.trading_allowed = false;
   st.active_plan_id = JA_ExtractJsonString(obj, "plan_id");
   st.active_mode = JA_ExtractJsonString(obj, "mode_name");
   st.zone_name = JA_ExtractJsonString(obj, "zone_name");
   st.best_strategy_id = JA_ExtractJsonString(obj, "best_strategy_id");
   st.consensus_label = JA_ExtractJsonString(obj, "consensus_label");
   st.consensus_strength = JA_ExtractJsonDouble(obj, "consensus_strength");
   st.conflict_score = JA_ExtractJsonDouble(obj, "conflict_score");
   st.council_quality = JA_ExtractJsonDouble(obj, "council_quality");
   st.environment_score = JA_ExtractJsonDouble(obj, "environment_score");
   st.dominant_failure = JA_ExtractJsonString(obj, "failure_tag");
   st.dominant_failure_source = "COUNCIL_FEEDBACK";
   st.dominant_failure_pressure = JA_ExtractJsonString(obj, "quality_band");
   st.final_decision = JA_ExtractJsonString(obj, "final_decision");
   st.trade_result = JA_ExtractJsonString(obj, "trade_result");
   st.close_profit = JA_ExtractJsonDouble(obj, "profit");
   st.decision_id = JA_ExtractJsonString(obj, "decision_id");
   st.correlated_decision_id = JA_ExtractJsonString(obj, "correlated_decision_id");
   st.position_id = JA_ExtractJsonULong(obj, "position_id");
   st.close_deal_id = JA_ExtractJsonULong(obj, "close_deal_id");
   st.decision_time = (datetime)JA_ExtractJsonInt(obj, "close_time");
   st.evaluated_at = st.decision_time;
   st.final_block_reason_code = JA_ExtractJsonString(obj, "failure_tag");
   st.final_blocking_layer = (st.final_decision == "REJECT" ? "feedback_snapshot_rejection" : "");
   st.execution_path = (st.final_decision == "REJECT" ? "DECISION_REJECTED" : "DECISION_ONLY_VISIBLE");
   st.replay_confidence = "MEDIUM";
   st.replay_data_limitations = "feedback_snapshot_has_context_but_may_lack_explicit_decision_or_trade_linkage";
   return true;
}

string BuildReplayValidationSummaryText(const ReplayValidationSummary &st)
{
   string s = "";
   s += "replay_validation_summary\n";
   s += "artifact_role=" + st.artifact_role + "\n";
   s += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   s += "summary_version=" + st.summary_version + "\n";
   s += "trust_rule=" + st.trust_rule + "\n";
   s += "update_source=" + st.update_source + "\n";
   s += "replay_case_type=" + st.replay_case_type + "\n";
   s += "replay_case_scope=" + st.replay_case_scope + "\n";
   s += "governance_state=" + st.governance_state + "\n";
   s += "trading_allowed=" + DiagnosticBoolText(st.trading_allowed) + "\n";
   s += "active_plan_id=" + st.active_plan_id + "\n";
   s += "active_mode=" + st.active_mode + "\n";
   s += "regime_label=" + st.regime_label + "\n";
   s += "regime_confidence=" + DoubleToString(st.regime_confidence, 3) + "\n";
   s += "zone_name=" + st.zone_name + "\n";
   s += "best_strategy_id=" + st.best_strategy_id + "\n";
   s += "consensus_label=" + st.consensus_label + "\n";
   s += "consensus_strength=" + DoubleToString(st.consensus_strength, 3) + "\n";
   s += "conflict_score=" + DoubleToString(st.conflict_score, 3) + "\n";
   s += "council_quality=" + DoubleToString(st.council_quality, 3) + "\n";
   s += "environment_score=" + DoubleToString(st.environment_score, 3) + "\n";
   s += "dominant_failure=" + st.dominant_failure + "\n";
   s += "dominant_failure_source=" + st.dominant_failure_source + "\n";
   s += "dominant_failure_pressure=" + st.dominant_failure_pressure + "\n";
   s += "final_decision=" + st.final_decision + "\n";
   s += "final_blocking_layer=" + st.final_blocking_layer + "\n";
   s += "final_block_reason_code=" + st.final_block_reason_code + "\n";
   s += "execution_path=" + st.execution_path + "\n";
   s += "decision_id=" + st.decision_id + "\n";
   s += "correlated_decision_id=" + st.correlated_decision_id + "\n";
   s += "position_id=" + DiagnosticU64(st.position_id) + "\n";
   s += "entry_deal_id=" + DiagnosticU64(st.entry_deal_id) + "\n";
   s += "close_deal_id=" + DiagnosticU64(st.close_deal_id) + "\n";
   s += "trade_result=" + st.trade_result + "\n";
   s += "close_profit=" + DoubleToString(st.close_profit, 2) + "\n";
   s += "decision_time=" + DiagnosticTimeText(st.decision_time) + "\n";
   s += "open_time=" + DiagnosticTimeText(st.open_time) + "\n";
   s += "close_time=" + DiagnosticTimeText(st.close_time) + "\n";
   s += "replay_confidence=" + st.replay_confidence + "\n";
   s += "replay_data_limitations=" + st.replay_data_limitations + "\n";
   s += "evaluated_at=" + DiagnosticTimeText(st.evaluated_at) + "\n";
   return s;
}

string BuildReplayValidationSummaryJson(const ReplayValidationSummary &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"trust_rule\":\"" + JsonEscapeString(st.trust_rule) + "\"";
   j += ",\"update_source\":\"" + JsonEscapeString(st.update_source) + "\"";
   j += ",\"replay_case_type\":\"" + JsonEscapeString(st.replay_case_type) + "\"";
   j += ",\"replay_case_scope\":\"" + JsonEscapeString(st.replay_case_scope) + "\"";
   j += ",\"governance_state\":\"" + JsonEscapeString(st.governance_state) + "\"";
   j += ",\"trading_allowed\":" + string(st.trading_allowed ? "true" : "false");
   j += ",\"active_plan_id\":\"" + JsonEscapeString(st.active_plan_id) + "\"";
   j += ",\"active_mode\":\"" + JsonEscapeString(st.active_mode) + "\"";
   j += ",\"regime_label\":\"" + JsonEscapeString(st.regime_label) + "\"";
   j += ",\"regime_confidence\":" + DoubleToString(st.regime_confidence, 3);
   j += ",\"zone_name\":\"" + JsonEscapeString(st.zone_name) + "\"";
   j += ",\"best_strategy_id\":\"" + JsonEscapeString(st.best_strategy_id) + "\"";
   j += ",\"consensus_label\":\"" + JsonEscapeString(st.consensus_label) + "\"";
   j += ",\"consensus_strength\":" + DoubleToString(st.consensus_strength, 3);
   j += ",\"conflict_score\":" + DoubleToString(st.conflict_score, 3);
   j += ",\"council_quality\":" + DoubleToString(st.council_quality, 3);
   j += ",\"environment_score\":" + DoubleToString(st.environment_score, 3);
   j += ",\"dominant_failure\":\"" + JsonEscapeString(st.dominant_failure) + "\"";
   j += ",\"dominant_failure_source\":\"" + JsonEscapeString(st.dominant_failure_source) + "\"";
   j += ",\"dominant_failure_pressure\":\"" + JsonEscapeString(st.dominant_failure_pressure) + "\"";
   j += ",\"final_decision\":\"" + JsonEscapeString(st.final_decision) + "\"";
   j += ",\"final_blocking_layer\":\"" + JsonEscapeString(st.final_blocking_layer) + "\"";
   j += ",\"final_block_reason_code\":\"" + JsonEscapeString(st.final_block_reason_code) + "\"";
   j += ",\"execution_path\":\"" + JsonEscapeString(st.execution_path) + "\"";
   j += ",\"decision_id\":\"" + JsonEscapeString(st.decision_id) + "\"";
   j += ",\"correlated_decision_id\":\"" + JsonEscapeString(st.correlated_decision_id) + "\"";
   j += ",\"position_id\":\"" + DiagnosticU64(st.position_id) + "\"";
   j += ",\"entry_deal_id\":\"" + DiagnosticU64(st.entry_deal_id) + "\"";
   j += ",\"close_deal_id\":\"" + DiagnosticU64(st.close_deal_id) + "\"";
   j += ",\"trade_result\":\"" + JsonEscapeString(st.trade_result) + "\"";
   j += ",\"close_profit\":" + DoubleToString(st.close_profit, 2);
   j += ",\"decision_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.decision_time)) + "\"";
   j += ",\"open_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.open_time)) + "\"";
   j += ",\"close_time\":\"" + JsonEscapeString(DiagnosticTimeText(st.close_time)) + "\"";
   j += ",\"replay_confidence\":\"" + JsonEscapeString(st.replay_confidence) + "\"";
   j += ",\"replay_data_limitations\":\"" + JsonEscapeString(st.replay_data_limitations) + "\"";
   j += ",\"evaluated_at\":\"" + JsonEscapeString(DiagnosticTimeText(st.evaluated_at)) + "\"";
   j += "}";
   return j;
}

void RefreshReplayValidationArtifactsBestEffort()
{
   ReplayValidationSummary best;
   InitReplayValidationSummary(best);
   best.update_source = "PACKAGE_PLACEHOLDER_PENDING_RUNTIME_REPLAY";
   best.replay_data_limitations = "PACKAGE_PLACEHOLDER_PENDING_RUNTIME_REPLAY";
   best.evaluated_at = TimeCurrent();

   bool hasBest = false;

   ReplayValidationSummary candidate;
   if(ReplayBuildCandidateFromDiagnostic(candidate))
      ReplaySelectBetterCandidate(candidate, hasBest, best);

   if(ReplayBuildCandidateFromLatestClosedTrade(candidate))
      ReplaySelectBetterCandidate(candidate, hasBest, best);

   if(ReplayBuildCandidateFromLatestTradeOpen(candidate))
      ReplaySelectBetterCandidate(candidate, hasBest, best);

   if(ReplayBuildCandidateFromLatestBlockedDecision(candidate))
      ReplaySelectBetterCandidate(candidate, hasBest, best);

   if(ReplayBuildCandidateFromLatestDecisionSnapshot(candidate))
      ReplaySelectBetterCandidate(candidate, hasBest, best);

   if(!hasBest)
   {
      InitReplayValidationSummary(best);
      best.update_source = "PACKAGE_PLACEHOLDER_PENDING_RUNTIME_REPLAY";
      best.replay_case_type = "NO_CASE";
      best.replay_case_scope = "none";
      best.replay_confidence = "LOW";
      best.replay_data_limitations = "PACKAGE_PLACEHOLDER_PENDING_RUNTIME_REPLAY";
      best.evaluated_at = TimeCurrent();
   }

   gReplayValidationSummary = best;
   gReplayValidationSummaryInitialized = true;

   WriteTextFileAll(ReplayValidationSummaryTxtPath(), BuildReplayValidationSummaryText(best));
   WriteTextFileAll(ReplayValidationSummaryJsonPath(), BuildReplayValidationSummaryJson(best));
}



struct ExecutionQualityValidationSummary
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   source_scope;
   string   note;

   int      decisions_total;
   int      executed_trades_total;
   int      approved_entry_intents_total;
   int      rejected_total;
   int      waits_total;
   int      blocked_total;
   int      unclassified_total;

   int      execution_open_failures;
   int      runtime_governance_blocks;
   int      policy_blocks;
   int      level_brake_blocks;
   int      activation_pressure_blocks;
   int      dirty_environment_blocks;
   int      lifecycle_not_ready_blocks;
   int      execution_quality_blocks;
   int      council_pre_ai_rejections;
   int      council_confirmation_rejections;
   int      council_conflict_rejections;
   int      council_quality_rejections;
   int      no_trade_environment_rejections;
   int      other_blocked_total;

   int      source_decision_records;
   int      source_trade_open_records;
   int      source_trade_close_records;

   string   dominant_block_layer;
   string   dominant_rejection_family;
   string   latest_record_ts;
   datetime rebuilt_at;

   double   decision_to_trade_conversion_rate;
   double   approval_intent_rate;
   double   rejection_rate;
   double   wait_rate;
   double   block_rate;
   double   execution_open_failure_rate;
};

static ExecutionQualityValidationSummary gExecutionQualityValidationSummary;
static bool gExecutionQualityValidationInitialized = false;

string ExecutionQualityValidationTxtPath()  { return "AI\\execution_quality_validation.txt"; }
string ExecutionQualityValidationJsonPath() { return "AI\\execution_quality_validation.json"; }

void InitExecutionQualityValidationSummary(ExecutionQualityValidationSummary &st)
{
   st.artifact_role = "EXECUTION_QUALITY_VALIDATION";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_VALIDATION";
   st.summary_version = "H3_EXECUTION_QUALITY_VALIDATION_V1";
   st.source_scope = "AI\\ai_performance_journal.jsonl";
   st.note = "best_effort_validation_summary";

   st.decisions_total = 0;
   st.executed_trades_total = 0;
   st.approved_entry_intents_total = 0;
   st.rejected_total = 0;
   st.waits_total = 0;
   st.blocked_total = 0;
   st.unclassified_total = 0;

   st.execution_open_failures = 0;
   st.runtime_governance_blocks = 0;
   st.policy_blocks = 0;
   st.level_brake_blocks = 0;
   st.activation_pressure_blocks = 0;
   st.dirty_environment_blocks = 0;
   st.lifecycle_not_ready_blocks = 0;
   st.execution_quality_blocks = 0;
   st.council_pre_ai_rejections = 0;
   st.council_confirmation_rejections = 0;
   st.council_conflict_rejections = 0;
   st.council_quality_rejections = 0;
   st.no_trade_environment_rejections = 0;
   st.other_blocked_total = 0;

   st.source_decision_records = 0;
   st.source_trade_open_records = 0;
   st.source_trade_close_records = 0;

   st.dominant_block_layer = "";
   st.dominant_rejection_family = "";
   st.latest_record_ts = "";
   st.rebuilt_at = TimeCurrent();

   st.decision_to_trade_conversion_rate = 0.0;
   st.approval_intent_rate = 0.0;
   st.rejection_rate = 0.0;
   st.wait_rate = 0.0;
   st.block_rate = 0.0;
   st.execution_open_failure_rate = 0.0;
}

string ValidationNormalizeBlockingLayer(string layer)
{
   layer = TrimString(layer);
   StringToLower(layer);

   if(layer == "runtime_governance_block" ||
      layer == "policy_block" ||
      layer == "level_brake_block" ||
      layer == "activation_pressure_block" ||
      layer == "dirty_environment_block" ||
      layer == "lifecycle_gate_not_ready" ||
      layer == "execution_quality_block" ||
      layer == "council_pre_ai_rejection" ||
      layer == "council_confirmation_rejection" ||
      layer == "council_conflict_rejection" ||
      layer == "council_quality_rejection" ||
      layer == "explicit_no_trade_environment_rejection" ||
      layer == "regime_filter_block" ||
      layer == "decision_reject" ||
      layer == "wait_no_entry" ||
      layer == "per_bar_attempt_limit" ||
      layer == "execution_open_failed")
      return layer;

   return layer;
}

string ValidationNormalizeOutcomeClass(string value)
{
   value = TrimString(value);
   StringToUpper(value);

   if(value == "BLOCKED" || value == "REJECT" || value == "WAIT" || value == "EXECUTED" || value == "OPEN_FAILURE" || value == "APPROVED_ENTRY_INTENT" || value == "EXECUTED_TRADE_OPEN" || value == "UNCLASSIFIED")
      return value;

   return "UNCLASSIFIED";
}

string ValidationNormalizeRejectionFamily(string value)
{
   value = TrimString(value);
   StringToUpper(value);

   if(value == "PRE_AI" || value == "CONFIRMATION" || value == "CONFLICT" || value == "QUALITY" || value == "NO_TRADE_ENVIRONMENT")
      return value;

   return "";
}

bool ValidationIsBlockingLayer(const string layer)
{
   string v = ValidationNormalizeBlockingLayer(layer);

   return (v == "runtime_governance_block" ||
           v == "policy_block" ||
           v == "level_brake_block" ||
           v == "activation_pressure_block" ||
           v == "dirty_environment_block" ||
           v == "lifecycle_gate_not_ready" ||
           v == "execution_quality_block" ||
           v == "council_pre_ai_rejection" ||
           v == "council_confirmation_rejection" ||
           v == "council_conflict_rejection" ||
           v == "council_quality_rejection" ||
           v == "explicit_no_trade_environment_rejection" ||
           v == "regime_filter_block" ||
           v == "per_bar_attempt_limit");
}

string ValidationInferRejectionFamilyFromBlockingLayer(const string blockingLayer)
{
   string layer = ValidationNormalizeBlockingLayer(blockingLayer);

   if(layer == "council_pre_ai_rejection")
      return "PRE_AI";
   if(layer == "council_confirmation_rejection")
      return "CONFIRMATION";
   if(layer == "council_conflict_rejection")
      return "CONFLICT";
   if(layer == "council_quality_rejection")
      return "QUALITY";
   if(layer == "explicit_no_trade_environment_rejection")
      return "NO_TRADE_ENVIRONMENT";

   return "";
}

string ValidationInferOutcomeClass(const string finalDecision, const string blockingLayer, const string executionPath)
{
   string decision = TrimString(finalDecision);
   StringToUpper(decision);

   string layer = ValidationNormalizeBlockingLayer(blockingLayer);
   string path = TrimString(executionPath);
   StringToUpper(path);

   if(layer == "execution_open_failed" || path == "TRADE_OPEN_FAILED")
      return "OPEN_FAILURE";

   if(path == "TRADE_OPEN_EXECUTED")
      return "EXECUTED";

   if(decision == "REJECT")
      return "REJECT";
   if(decision == "WAIT")
      return "WAIT";
   if(ValidationIsBlockingLayer(layer))
      return "BLOCKED";
   if(decision == "BUY" || decision == "SELL")
      return "APPROVED_ENTRY_INTENT";

   return "UNCLASSIFIED";
}

void ValidationCountBlockingLayer(ExecutionQualityValidationSummary &st, const string blockingLayer)
{
   string layer = ValidationNormalizeBlockingLayer(blockingLayer);
   if(!ValidationIsBlockingLayer(layer))
      return;

   st.blocked_total++;

   if(layer == "runtime_governance_block")
      st.runtime_governance_blocks++;
   else if(layer == "policy_block")
      st.policy_blocks++;
   else if(layer == "level_brake_block")
      st.level_brake_blocks++;
   else if(layer == "activation_pressure_block")
      st.activation_pressure_blocks++;
   else if(layer == "dirty_environment_block")
      st.dirty_environment_blocks++;
   else if(layer == "lifecycle_gate_not_ready")
      st.lifecycle_not_ready_blocks++;
   else if(layer == "execution_quality_block")
      st.execution_quality_blocks++;
   else if(layer == "council_pre_ai_rejection")
      st.council_pre_ai_rejections++;
   else if(layer == "council_confirmation_rejection")
      st.council_confirmation_rejections++;
   else if(layer == "council_conflict_rejection")
      st.council_conflict_rejections++;
   else if(layer == "council_quality_rejection")
      st.council_quality_rejections++;
   else if(layer == "explicit_no_trade_environment_rejection")
      st.no_trade_environment_rejections++;
   else
      st.other_blocked_total++;
}

void ValidationCountRejectionFamily(ExecutionQualityValidationSummary &st, const string rejectionFamily)
{
   string family = ValidationNormalizeRejectionFamily(rejectionFamily);

   if(family == "PRE_AI")
      st.council_pre_ai_rejections++;
   else if(family == "CONFIRMATION")
      st.council_confirmation_rejections++;
   else if(family == "CONFLICT")
      st.council_conflict_rejections++;
   else if(family == "QUALITY")
      st.council_quality_rejections++;
   else if(family == "NO_TRADE_ENVIRONMENT")
      st.no_trade_environment_rejections++;
}

double ValidationRatioCount(const int part, const int whole)
{
   if(whole <= 0)
      return 0.0;
   return (double)part / (double)whole;
}

string ValidationInferLegacyBlockingLayer(const string jsonLine, const string finalDecision)
{
   string layer = JA_ExtractJsonString(jsonLine, "final_blocking_layer");
   if(StringLen(TrimString(layer)) > 0)
      return ValidationNormalizeBlockingLayer(layer);

   string policyResult = JA_ExtractJsonString(jsonLine, "policy_result");
   string policyUpper = policyResult;
   StringToUpper(policyUpper);
   if(StringFind(policyUpper, "BLOCKED:LEVEL_BRAKE") == 0)
      return "level_brake_block";
   if(StringFind(policyUpper, "BLOCKED:") == 0)
      return "regime_filter_block";

   string councilSummary = JA_ExtractJsonString(jsonLine, "council_summary");
   string councilLower = councilSummary;
   StringToLower(councilLower);
   if(StringFind(councilLower, "pre-ai") >= 0)
      return "council_pre_ai_rejection";
   if(StringFind(councilLower, "environment") >= 0)
      return "explicit_no_trade_environment_rejection";

   string decision = TrimString(finalDecision);
   StringToUpper(decision);
   if(decision == "REJECT")
      return "decision_reject";
   if(decision == "WAIT")
      return "wait_no_entry";

   return "";
}

string ValidationInferLegacyReasonCode(const string jsonLine, const string blockingLayer)
{
   string reason = JA_ExtractJsonString(jsonLine, "final_block_reason_code");
   if(StringLen(TrimString(reason)) > 0)
      return reason;

   if(blockingLayer == "level_brake_block")
      return "level_brake_block";

   if(blockingLayer == "council_pre_ai_rejection")
      return "council_pre_ai_rejection";
   if(blockingLayer == "explicit_no_trade_environment_rejection")
      return "explicit_no_trade_environment_rejection";

   reason = JA_ExtractJsonString(jsonLine, "final_decision_reason");
   if(StringLen(TrimString(reason)) > 0 && reason != "REJECT" && reason != "WAIT")
      return reason;

   reason = JA_ExtractJsonString(jsonLine, "failure_class");
   if(StringLen(TrimString(reason)) > 0 && reason != "UNKNOWN_FAILURE")
      return reason;

   return "";
}

string ValidationInferLegacyExecutionPath(const string jsonLine, const string finalDecision, const string blockingLayer)
{
   string path = JA_ExtractJsonString(jsonLine, "execution_path");
   if(StringLen(TrimString(path)) > 0)
      return path;

   string decision = TrimString(finalDecision);
   StringToUpper(decision);

   if(blockingLayer == "execution_open_failed")
      return "TRADE_OPEN_FAILED";
   if(decision == "REJECT")
      return "DECISION_REJECTED";
   if(decision == "WAIT")
      return "NO_TRADE_WAIT";
   if(decision == "BUY" || decision == "SELL")
      return "APPROVED_ENTRY_INTENT";

   return "";
}

string ValidationInferLegacyRejectionFamily(const string jsonLine, const string blockingLayer)
{
   string family = JA_ExtractJsonString(jsonLine, "validation_rejection_family");
   if(StringLen(TrimString(family)) > 0)
      return ValidationNormalizeRejectionFamily(family);

   family = ValidationInferRejectionFamilyFromBlockingLayer(blockingLayer);
   if(StringLen(family) > 0)
      return family;

   string councilSummary = JA_ExtractJsonString(jsonLine, "council_summary");
   string councilLower = councilSummary;
   StringToLower(councilLower);
   if(StringFind(councilLower, "pre-ai") >= 0)
      return "PRE_AI";
   if(StringFind(councilLower, "environment") >= 0)
      return "NO_TRADE_ENVIRONMENT";

   return "";
}

void FinalizeExecutionQualityValidationSummary(ExecutionQualityValidationSummary &st)
{
   if(st.decisions_total > 0)
   {
      st.decision_to_trade_conversion_rate = (double)st.executed_trades_total / (double)st.decisions_total;
      st.approval_intent_rate = (double)st.approved_entry_intents_total / (double)st.decisions_total;
      st.rejection_rate = (double)st.rejected_total / (double)st.decisions_total;
      st.wait_rate = (double)st.waits_total / (double)st.decisions_total;
      st.block_rate = (double)st.blocked_total / (double)st.decisions_total;
   }

   int openIntentDen = st.approved_entry_intents_total;
   if(openIntentDen <= 0)
      openIntentDen = (st.executed_trades_total + st.execution_open_failures);
   if(openIntentDen > 0)
      st.execution_open_failure_rate = (double)st.execution_open_failures / (double)openIntentDen;

   int dominantBlockCount = 0;
   st.dominant_block_layer = "";
   if(st.runtime_governance_blocks > dominantBlockCount) { dominantBlockCount = st.runtime_governance_blocks; st.dominant_block_layer = "runtime_governance_block"; }
   if(st.policy_blocks > dominantBlockCount) { dominantBlockCount = st.policy_blocks; st.dominant_block_layer = "policy_block"; }
   if(st.level_brake_blocks > dominantBlockCount) { dominantBlockCount = st.level_brake_blocks; st.dominant_block_layer = "level_brake_block"; }
   if(st.activation_pressure_blocks > dominantBlockCount) { dominantBlockCount = st.activation_pressure_blocks; st.dominant_block_layer = "activation_pressure_block"; }
   if(st.dirty_environment_blocks > dominantBlockCount) { dominantBlockCount = st.dirty_environment_blocks; st.dominant_block_layer = "dirty_environment_block"; }
   if(st.lifecycle_not_ready_blocks > dominantBlockCount) { dominantBlockCount = st.lifecycle_not_ready_blocks; st.dominant_block_layer = "lifecycle_gate_not_ready"; }
   if(st.execution_quality_blocks > dominantBlockCount) { dominantBlockCount = st.execution_quality_blocks; st.dominant_block_layer = "execution_quality_block"; }
   if(st.council_pre_ai_rejections > dominantBlockCount) { dominantBlockCount = st.council_pre_ai_rejections; st.dominant_block_layer = "council_pre_ai_rejection"; }
   if(st.council_confirmation_rejections > dominantBlockCount) { dominantBlockCount = st.council_confirmation_rejections; st.dominant_block_layer = "council_confirmation_rejection"; }
   if(st.council_conflict_rejections > dominantBlockCount) { dominantBlockCount = st.council_conflict_rejections; st.dominant_block_layer = "council_conflict_rejection"; }
   if(st.council_quality_rejections > dominantBlockCount) { dominantBlockCount = st.council_quality_rejections; st.dominant_block_layer = "council_quality_rejection"; }
   if(st.no_trade_environment_rejections > dominantBlockCount) { dominantBlockCount = st.no_trade_environment_rejections; st.dominant_block_layer = "explicit_no_trade_environment_rejection"; }
   if(st.other_blocked_total > dominantBlockCount) { dominantBlockCount = st.other_blocked_total; st.dominant_block_layer = "other_blocked"; }

   int dominantRejectCount = 0;
   st.dominant_rejection_family = "";
   if(st.council_pre_ai_rejections > dominantRejectCount) { dominantRejectCount = st.council_pre_ai_rejections; st.dominant_rejection_family = "PRE_AI"; }
   if(st.council_confirmation_rejections > dominantRejectCount) { dominantRejectCount = st.council_confirmation_rejections; st.dominant_rejection_family = "CONFIRMATION"; }
   if(st.council_conflict_rejections > dominantRejectCount) { dominantRejectCount = st.council_conflict_rejections; st.dominant_rejection_family = "CONFLICT"; }
   if(st.council_quality_rejections > dominantRejectCount) { dominantRejectCount = st.council_quality_rejections; st.dominant_rejection_family = "QUALITY"; }
   if(st.no_trade_environment_rejections > dominantRejectCount) { dominantRejectCount = st.no_trade_environment_rejections; st.dominant_rejection_family = "NO_TRADE_ENVIRONMENT"; }

   if(StringLen(TrimString(st.latest_record_ts)) <= 0)
      st.latest_record_ts = DiagnosticTimeText(TimeCurrent());

   st.rebuilt_at = TimeCurrent();
}

bool RebuildExecutionQualityValidationSummaryFromJournal(ExecutionQualityValidationSummary &st)
{
   InitExecutionQualityValidationSummary(st);

   int h = FileOpen(PERF_JOURNAL_PATH, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
   {
      st.note = "journal_not_readable";
      st.rebuilt_at = TimeCurrent();
      return false;
   }

   while(!FileIsEnding(h))
   {
      string line = FileReadString(h);
      line = TrimString(line);
      if(StringLen(line) <= 0)
         continue;

      string recordType = JA_ExtractJsonString(line, "record_type");
      if(StringLen(TrimString(recordType)) <= 0)
         continue;

      string ts = JA_ExtractJsonString(line, "ts");
      if(StringLen(TrimString(ts)) <= 0)
         ts = JA_ExtractJsonString(line, "timestamp");
      if(StringLen(TrimString(ts)) > 0)
         st.latest_record_ts = ts;

      if(recordType == "DECISION")
      {
         st.source_decision_records++;
         st.decisions_total++;

         string finalDecision = JA_ExtractJsonString(line, "final_decision");
         string blockingLayer = ValidationInferLegacyBlockingLayer(line, finalDecision);
         string executionPath = ValidationInferLegacyExecutionPath(line, finalDecision, blockingLayer);
         string outcomeClass = JA_ExtractJsonString(line, "validation_outcome_class");
         if(StringLen(TrimString(outcomeClass)) <= 0)
            outcomeClass = ValidationInferOutcomeClass(finalDecision, blockingLayer, executionPath);
         outcomeClass = ValidationNormalizeOutcomeClass(outcomeClass);

         string rejectionFamily = ValidationInferLegacyRejectionFamily(line, blockingLayer);

         if(outcomeClass == "REJECT")
            st.rejected_total++;
         else if(outcomeClass == "WAIT")
            st.waits_total++;
         else if(outcomeClass == "OPEN_FAILURE")
         {
            st.approved_entry_intents_total++;
            st.execution_open_failures++;
         }
         else if(outcomeClass == "EXECUTED")
            st.approved_entry_intents_total++;
         else if(outcomeClass == "APPROVED_ENTRY_INTENT")
            st.approved_entry_intents_total++;
         else if(outcomeClass == "BLOCKED")
            st.unclassified_total++;
         else if(outcomeClass == "UNCLASSIFIED")
            st.unclassified_total++;

         if(ValidationIsBlockingLayer(blockingLayer))
            ValidationCountBlockingLayer(st, blockingLayer);

      }
      else if(recordType == "TRADE_OPEN")
      {
         st.source_trade_open_records++;
         st.executed_trades_total++;
      }
      else if(recordType == "TRADE")
      {
         string tradeEventType = JA_ExtractJsonString(line, "trade_event_type");
         if(tradeEventType == "TRADE_CLOSE" || StringLen(TrimString(tradeEventType)) <= 0)
            st.source_trade_close_records++;
      }
   }

   FileClose(h);

   string diagnosticJson = "";
   if(ReadTextFileAll(DiagnosticRuntimeSummaryJsonPath(), diagnosticJson))
   {
      string latestBlockingLayer = ValidationNormalizeBlockingLayer(JA_ExtractJsonString(diagnosticJson, "final_blocking_layer"));
      if(latestBlockingLayer == "runtime_governance_block")
         st.runtime_governance_blocks++;

      string latestExecutionPath = JA_ExtractJsonString(diagnosticJson, "execution_path");
      if(StringLen(TrimString(latestExecutionPath)) > 0)
         st.note = "journal_plus_latest_runtime_diagnostic_best_effort";
   }

   FinalizeExecutionQualityValidationSummary(st);
   return true;
}

string BuildExecutionQualityValidationText(const ExecutionQualityValidationSummary &st)
{
   string s = "";
   s += "execution_quality_validation\n";
   s += "artifact_role=" + st.artifact_role + "\n";
   s += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   s += "summary_version=" + st.summary_version + "\n";
   s += "trust_rule=derived_non_authoritative_best_effort_validation_only\n";
   s += "source_scope=" + st.source_scope + "\n";
   s += "decisions_total=" + IntegerToString(st.decisions_total) + "\n";
   s += "executed_trades_total=" + IntegerToString(st.executed_trades_total) + "\n";
   s += "approved_entry_intents_total=" + IntegerToString(st.approved_entry_intents_total) + "\n";
   s += "rejected_total=" + IntegerToString(st.rejected_total) + "\n";
   s += "waits_total=" + IntegerToString(st.waits_total) + "\n";
   s += "blocked_total=" + IntegerToString(st.blocked_total) + "\n";
   s += "execution_open_failures=" + IntegerToString(st.execution_open_failures) + "\n";
   s += "runtime_governance_blocks=" + IntegerToString(st.runtime_governance_blocks) + "\n";
   s += "policy_blocks=" + IntegerToString(st.policy_blocks) + "\n";
   s += "level_brake_blocks=" + IntegerToString(st.level_brake_blocks) + "\n";
   s += "activation_pressure_blocks=" + IntegerToString(st.activation_pressure_blocks) + "\n";
   s += "dirty_environment_blocks=" + IntegerToString(st.dirty_environment_blocks) + "\n";
   s += "lifecycle_not_ready_blocks=" + IntegerToString(st.lifecycle_not_ready_blocks) + "\n";
   s += "execution_quality_blocks=" + IntegerToString(st.execution_quality_blocks) + "\n";
   s += "council_pre_ai_rejections=" + IntegerToString(st.council_pre_ai_rejections) + "\n";
   s += "council_confirmation_rejections=" + IntegerToString(st.council_confirmation_rejections) + "\n";
   s += "council_conflict_rejections=" + IntegerToString(st.council_conflict_rejections) + "\n";
   s += "council_quality_rejections=" + IntegerToString(st.council_quality_rejections) + "\n";
   s += "no_trade_environment_rejections=" + IntegerToString(st.no_trade_environment_rejections) + "\n";
   s += "other_blocked_total=" + IntegerToString(st.other_blocked_total) + "\n";
   s += "unclassified_total=" + IntegerToString(st.unclassified_total) + "\n";
   s += "decision_to_trade_conversion_rate=" + DoubleToString(st.decision_to_trade_conversion_rate, 3) + "\n";
   s += "approval_intent_rate=" + DoubleToString(st.approval_intent_rate, 3) + "\n";
   s += "rejection_rate=" + DoubleToString(st.rejection_rate, 3) + "\n";
   s += "wait_rate=" + DoubleToString(st.wait_rate, 3) + "\n";
   s += "block_rate=" + DoubleToString(st.block_rate, 3) + "\n";
   s += "execution_open_failure_rate=" + DoubleToString(st.execution_open_failure_rate, 3) + "\n";
   s += "dominant_block_layer=" + st.dominant_block_layer + "\n";
   s += "dominant_rejection_family=" + st.dominant_rejection_family + "\n";
   s += "source_decision_records=" + IntegerToString(st.source_decision_records) + "\n";
   s += "source_trade_open_records=" + IntegerToString(st.source_trade_open_records) + "\n";
   s += "source_trade_close_records=" + IntegerToString(st.source_trade_close_records) + "\n";
   s += "latest_record_ts=" + st.latest_record_ts + "\n";
   s += "note=" + st.note + "\n";
   s += "rebuilt_at=" + DiagnosticTimeText(st.rebuilt_at) + "\n";
   return s;
}

string BuildExecutionQualityValidationJson(const ExecutionQualityValidationSummary &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"trust_rule\":\"derived_non_authoritative_best_effort_validation_only\"";
   j += ",\"source_scope\":\"" + JsonEscapeString(st.source_scope) + "\"";
   j += ",\"decisions_total\":" + IntegerToString(st.decisions_total);
   j += ",\"executed_trades_total\":" + IntegerToString(st.executed_trades_total);
   j += ",\"approved_entry_intents_total\":" + IntegerToString(st.approved_entry_intents_total);
   j += ",\"rejected_total\":" + IntegerToString(st.rejected_total);
   j += ",\"waits_total\":" + IntegerToString(st.waits_total);
   j += ",\"blocked_total\":" + IntegerToString(st.blocked_total);
   j += ",\"execution_open_failures\":" + IntegerToString(st.execution_open_failures);
   j += ",\"runtime_governance_blocks\":" + IntegerToString(st.runtime_governance_blocks);
   j += ",\"policy_blocks\":" + IntegerToString(st.policy_blocks);
   j += ",\"level_brake_blocks\":" + IntegerToString(st.level_brake_blocks);
   j += ",\"activation_pressure_blocks\":" + IntegerToString(st.activation_pressure_blocks);
   j += ",\"dirty_environment_blocks\":" + IntegerToString(st.dirty_environment_blocks);
   j += ",\"lifecycle_not_ready_blocks\":" + IntegerToString(st.lifecycle_not_ready_blocks);
   j += ",\"execution_quality_blocks\":" + IntegerToString(st.execution_quality_blocks);
   j += ",\"council_pre_ai_rejections\":" + IntegerToString(st.council_pre_ai_rejections);
   j += ",\"council_confirmation_rejections\":" + IntegerToString(st.council_confirmation_rejections);
   j += ",\"council_conflict_rejections\":" + IntegerToString(st.council_conflict_rejections);
   j += ",\"council_quality_rejections\":" + IntegerToString(st.council_quality_rejections);
   j += ",\"no_trade_environment_rejections\":" + IntegerToString(st.no_trade_environment_rejections);
   j += ",\"other_blocked_total\":" + IntegerToString(st.other_blocked_total);
   j += ",\"unclassified_total\":" + IntegerToString(st.unclassified_total);
   j += ",\"decision_to_trade_conversion_rate\":" + DoubleToString(st.decision_to_trade_conversion_rate, 3);
   j += ",\"approval_intent_rate\":" + DoubleToString(st.approval_intent_rate, 3);
   j += ",\"rejection_rate\":" + DoubleToString(st.rejection_rate, 3);
   j += ",\"wait_rate\":" + DoubleToString(st.wait_rate, 3);
   j += ",\"block_rate\":" + DoubleToString(st.block_rate, 3);
   j += ",\"execution_open_failure_rate\":" + DoubleToString(st.execution_open_failure_rate, 3);
   j += ",\"dominant_block_layer\":\"" + JsonEscapeString(st.dominant_block_layer) + "\"";
   j += ",\"dominant_rejection_family\":\"" + JsonEscapeString(st.dominant_rejection_family) + "\"";
   j += ",\"source_decision_records\":" + IntegerToString(st.source_decision_records);
   j += ",\"source_trade_open_records\":" + IntegerToString(st.source_trade_open_records);
   j += ",\"source_trade_close_records\":" + IntegerToString(st.source_trade_close_records);
   j += ",\"latest_record_ts\":\"" + JsonEscapeString(st.latest_record_ts) + "\"";
   j += ",\"note\":\"" + JsonEscapeString(st.note) + "\"";
   j += ",\"rebuilt_at\":\"" + JsonEscapeString(DiagnosticTimeText(st.rebuilt_at)) + "\"";
   j += "}";
   return j;
}

void RefreshExecutionQualityValidationArtifactsBestEffort()
{
   ExecutionQualityValidationSummary st;
   RebuildExecutionQualityValidationSummaryFromJournal(st);
   gExecutionQualityValidationSummary = st;
   gExecutionQualityValidationInitialized = true;
   WriteTextFileAll(ExecutionQualityValidationTxtPath(), BuildExecutionQualityValidationText(st));
   WriteTextFileAll(ExecutionQualityValidationJsonPath(), BuildExecutionQualityValidationJson(st));
   RefreshReplayValidationArtifactsBestEffort();
   RefreshOperationalizationLoopArtifactsBestEffort();
}

string ValidationOutcomeClassForJournal(const string finalDecision, const string finalBlockingLayer, const string executionPath)
{
   return ValidationInferOutcomeClass(finalDecision, finalBlockingLayer, executionPath);
}

string ValidationRejectionFamilyForJournal(const string finalBlockingLayer)
{
   return ValidationInferRejectionFamilyFromBlockingLayer(finalBlockingLayer);
}

void AppendValidationDecisionJournal(
   RoutedRuntimeEvaluation &routed,
   TimeframeSnapshot &m1,
   RuntimeEvaluation &eval,
   bool policyAllowed,
   string policyResult,
   string failureBasis,
   string finalDecision,
   string finalBlockingLayer,
   string finalBlockReasonCode,
   string executionPath
)
{
   EnsureCurrentDecisionId();

   UnifiedDecisionConfidence conf;
   BuildUnifiedDecisionConfidence(routed, gRegime, eval, policyAllowed, policyResult, conf);

   InitFailureClassification(gDecisionFailure);
   ClassifyDecisionFailureV1(conf, gRegime, policyResult, failureBasis, gDecisionFailure);

   string councilSummary = (routed.active_mode == "COUNCIL" ? routed.council.summary : "");
   if(routed.active_mode == "COUNCIL")
      PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
   else
      PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);

   PJ_SetDecisionValidationContext(
      finalBlockingLayer,
      finalBlockReasonCode,
      executionPath,
      ValidationOutcomeClassForJournal(finalDecision, finalBlockingLayer, executionPath),
      ValidationRejectionFamilyForJournal(finalBlockingLayer)
   );

   string pjLog = "";
   JournalAppendDecisionV3(
      gCurrentDecisionId,
      gPlan,
      routed.active_mode,
      m1,
      gRegime,
      conf,
      eval,
      policyResult,
      (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL"),
      (gHasRiskPolicy ? gRiskPolicy.reason : ""),
      gDecisionFailure.failure_class,
      gDecisionFailure.failure_reason_summary,
      gDecisionFailure.failure_severity,
      failureBasis,
      councilSummary,
      "",
      "",
      (gHasRollbackSignal ? gRollbackSignal.state_text : "NONE"),
      (gHasRollbackSignal ? gRollbackSignal.rollback_signal_score : 0.0),
      (gHasRollbackSignal ? gRollbackSignal.rollback_signal_reason : ""),
      (gHasFailureCluster ? gFailureCluster.clustered_failure_detected : false),
      (gHasFailureCluster ? gFailureCluster.dominant_failure_class : "UNKNOWN_FAILURE"),
      (gHasFailureCluster ? gFailureCluster.dominant_failure_count : 0),
      (gHasFailureCluster ? gFailureCluster.failure_cluster_score : 0.0),
      (gHasFailureCluster ? gFailureCluster.dominant_regime_if_any : ""),
      (gHasRegimePerf ? gRegimePerf.summary_reason : ""),
      pjLog
   );
   LogStateOnce(pjLog);

   string envTraceLog = "";
   JournalAppendDecisionEnvelopeTrace(
      gCurrentDecisionId,
      routed,
      conf,
      eval,
      policyResult,
      finalDecision,
      finalBlockingLayer,
      finalBlockReasonCode,
      executionPath,
      envTraceLog
   );
   if(StringLen(envTraceLog) > 0)
      LogStateOnce(envTraceLog);
}

void InitRuntimeGovernanceState(RuntimeGovernanceState &st)
{
   datetime now = TimeCurrent();
   st.governance_state = "STARTUP_INIT";
   st.trading_allowed = false;
   st.degraded_mode = false;
   st.truth_ready = false;
   st.diagnostics_ready = false;
   st.rollback_recently_applied = false;
   st.reason_code = "startup_state_incomplete";
   st.active_plan_id = "";
   st.active_mode = "";
   st.status_origin = "RUNTIME_EMITTED_GOVERNANCE_INIT";
   st.factory_first_admission_policy_locked = true;
   st.strategy_transfer_runtime_freeze_active = true;
   st.strategy_transfer_runtime_freeze_scope = "CENTRAL_RUNTIME_POLICY_GATE";
   st.strategy_transfer_runtime_freeze_reason_code = "factory_first_admission_policy_lock_runtime_freeze";
   st.strategy_execution_identity_authority_frozen = true;
   st.compiled_plan_runtime_privilege_frozen = true;
   st.council_runtime_execution_privilege_frozen = true;
   st.future_factory_admission_required_for_execution = true;
   st.lineage_preservation_mode = "NON_DESTRUCTIVE_PRESERVE_FOR_LATER_TRANSFER";
   st.package1_policy_lock_state = "ACTIVE";
   st.package1_runtime_freeze_state = "ACTIVE";
   RuntimeGovernanceApplyExecutionAuthorityCutoverTruth(st);
   st.operating_risk_envelope_state = "PENDING_RUNTIME_INIT";
   st.current_guardrail_block_reason_code = "";
   st.current_guardrail_owner = "";
   st.last_state_change = now;
   st.evaluated_at = now;
}

bool RuntimeGovernanceCanOpenReadOnly(const string rel_path)
{
   int h = FileOpen(rel_path, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileClose(h);
   return true;
}


bool RuntimeGovernanceArtifactLooksRuntimeReady(const string rel_path)
{
   if(!FileIsExist(rel_path))
      return false;

   string text_value = "";
   if(!ReadTextFileAll(rel_path, text_value))
      return false;

   if(StringLen(TrimString(text_value)) <= 0)
      return false;

   if(StringFind(text_value, "PACKAGE_PLACEHOLDER_PENDING_") >= 0)
      return false;
   if(StringFind(text_value, "STARTUP_INIT") >= 0 && StringFind(text_value, "RUNTIME_EMITTED") < 0)
      return false;
   if(StringFind(text_value, "startup_state_incomplete") >= 0 && StringFind(text_value, "RUNTIME_EMITTED") < 0)
      return false;

   return true;
}

void RuntimeGovernanceLoadTransferPolicyTruth(RuntimeGovernanceState &st)
{
   st.factory_first_admission_policy_locked = true;
   st.strategy_transfer_runtime_freeze_active = true;
   st.strategy_transfer_runtime_freeze_scope = "CENTRAL_RUNTIME_POLICY_GATE";
   st.strategy_transfer_runtime_freeze_reason_code = "factory_first_admission_policy_lock_runtime_freeze";
   st.strategy_execution_identity_authority_frozen = true;
   st.compiled_plan_runtime_privilege_frozen = true;
   st.council_runtime_execution_privilege_frozen = true;
   st.future_factory_admission_required_for_execution = true;
   st.lineage_preservation_mode = "NON_DESTRUCTIVE_PRESERVE_FOR_LATER_TRANSFER";
   st.package1_policy_lock_state = "ACTIVE";
   st.package1_runtime_freeze_state = "ACTIVE";

   string freeze_json = "";
   if(!ReadTextFileAll("AI\\strategy_transfer_runtime_freeze_status.json", freeze_json))
      return;

   ExtractJsonBoolField(freeze_json, "factory_first_admission_policy_locked", st.factory_first_admission_policy_locked);
   ExtractJsonBoolField(freeze_json, "strategy_transfer_runtime_freeze_active", st.strategy_transfer_runtime_freeze_active);
   ExtractJsonStringField(freeze_json, "strategy_transfer_runtime_freeze_scope", st.strategy_transfer_runtime_freeze_scope);
   ExtractJsonStringField(freeze_json, "strategy_transfer_runtime_freeze_reason_code", st.strategy_transfer_runtime_freeze_reason_code);
   ExtractJsonBoolField(freeze_json, "strategy_execution_identity_authority_frozen", st.strategy_execution_identity_authority_frozen);
   ExtractJsonBoolField(freeze_json, "compiled_plan_runtime_privilege_frozen", st.compiled_plan_runtime_privilege_frozen);
   ExtractJsonBoolField(freeze_json, "council_runtime_execution_privilege_frozen", st.council_runtime_execution_privilege_frozen);
   ExtractJsonBoolField(freeze_json, "future_factory_admission_required_for_execution", st.future_factory_admission_required_for_execution);
   ExtractJsonStringField(freeze_json, "lineage_preservation_mode", st.lineage_preservation_mode);

   if(st.factory_first_admission_policy_locked)
      st.package1_policy_lock_state = "ACTIVE";
   else
      st.package1_policy_lock_state = "INACTIVE";

   if(st.strategy_transfer_runtime_freeze_active)
      st.package1_runtime_freeze_state = "ACTIVE";
   else
      st.package1_runtime_freeze_state = "INACTIVE";

   RuntimeGovernanceApplyExecutionAuthorityCutoverTruth(st);
}

bool RuntimeGovernancePolicyLockOrFreezeActive(const RuntimeGovernanceState &st)
{
   if(st.factory_governed_execution_authority_active &&
      st.active_operating_cohort_defined &&
      st.execution_allowed_only_through_active_operating_cohort)
      return false;

   return (st.factory_first_admission_policy_locked ||
           st.strategy_transfer_runtime_freeze_active ||
           st.strategy_execution_identity_authority_frozen ||
           st.compiled_plan_runtime_privilege_frozen ||
           st.council_runtime_execution_privilege_frozen ||
           st.future_factory_admission_required_for_execution ||
           st.package1_policy_lock_state == "ACTIVE" ||
           st.package1_runtime_freeze_state == "ACTIVE");
}


bool RuntimeGovernanceExtractEvolutionMirror(string &planId, string &decisionMode, bool &hasMirror)
{
   planId = "";
   decisionMode = "";
   hasMirror = false;

   if(!FileIsExist(TruthEvolutionStatePath()))
      return true;

   string evolutionJson = "";
   if(!ReadTextFileAll(TruthEvolutionStatePath(), evolutionJson))
      return false;

   string tmp = "";
   if(ExtractJsonStringField(evolutionJson, "active_plan_id", tmp) || ExtractJsonStringField(evolutionJson, "current_plan_id", tmp))
   {
      planId = TrimString(tmp);
      hasMirror = true;
   }

   tmp = "";
   if(ExtractJsonStringField(evolutionJson, "active_decision_engine_mode", tmp) || ExtractJsonStringField(evolutionJson, "current_active_decision_engine_mode", tmp) || ExtractJsonStringField(evolutionJson, "current_decision_engine_mode", tmp))
   {
      decisionMode = TrimString(tmp);
      hasMirror = true;
   }

   return true;
}

bool RuntimeGovernanceEvaluateTruthReadiness(string &planId, string &decisionMode, string &reasonCode)
{
   planId = "";
   decisionMode = "";
   reasonCode = "truth_not_ready";

   string planJson = "";
   if(!FileIsExist(TruthCurrentPlanPath()) || !ReadTextFileAll(TruthCurrentPlanPath(), planJson))
   {
      reasonCode = "active_plan_missing";
      return false;
   }

   if(!TruthExtractAuthoritativePlanState(planJson, planId, decisionMode))
   {
      reasonCode = "active_plan_missing";
      return false;
   }

   if(StringLen(planId) <= 0)
   {
      reasonCode = "active_plan_missing";
      return false;
   }

   if(StringLen(decisionMode) <= 0)
   {
      reasonCode = "active_mode_missing";
      return false;
   }

   if(StringLen(gPlan.plan_id) > 0 && gPlan.plan_id != planId)
   {
      reasonCode = "truth_not_ready";
      return false;
   }

   if(StringLen(gPlan.decision_engine_mode) > 0 && gPlan.decision_engine_mode != decisionMode)
   {
      reasonCode = "truth_not_ready";
      return false;
   }

   string mirrorPlanId = "";
   string mirrorMode = "";
   bool hasMirror = false;
   if(!RuntimeGovernanceExtractEvolutionMirror(mirrorPlanId, mirrorMode, hasMirror))
   {
      reasonCode = "truth_not_ready";
      return false;
   }

   if(hasMirror)
   {
      if(StringLen(mirrorPlanId) > 0 && mirrorPlanId != planId)
      {
         reasonCode = "truth_not_ready";
         return false;
      }

      if(StringLen(mirrorMode) > 0 && mirrorMode != decisionMode)
      {
         reasonCode = "truth_not_ready";
         return false;
      }
   }

   reasonCode = "runtime_ready";
   return true;
}

bool RuntimeGovernanceEvaluateDiagnosticsReadiness(string &reasonCode)
{
   reasonCode = "runtime_ready";

   bool performanceJournalReady = RuntimeGovernanceCanOpenReadOnly(PERF_JOURNAL_PATH);
   bool councilFeedbackReady = RuntimeGovernanceCanOpenReadOnly("AI\\council_feedback.json");
   bool diagnosticSummaryReady = RuntimeGovernanceArtifactLooksRuntimeReady(DiagnosticRuntimeSummaryJsonPath());
   bool validationReady = RuntimeGovernanceArtifactLooksRuntimeReady(ExecutionQualityValidationJsonPath());

   if(performanceJournalReady || councilFeedbackReady || diagnosticSummaryReady || validationReady)
      return true;

   if(!FileIsExist(PERF_JOURNAL_PATH))
      reasonCode = "performance_journal_missing";
   else
      reasonCode = "diagnostics_surface_not_ready";
   return false;
}

void RuntimeGovernanceApplyState(RuntimeGovernanceState &st,
                                 const string governanceState,
                                 const bool tradingAllowed,
                                 const bool degradedMode,
                                 const bool truthReady,
                                 const bool diagnosticsReady,
                                 const bool rollbackRecentlyApplied,
                                 const string reasonCode,
                                 const string activePlanId,
                                 const string activeMode)
{
   if(!gRuntimeGovernanceInitialized)
      InitRuntimeGovernanceState(st);

   RuntimeGovernanceLoadTransferPolicyTruth(st);

   datetime now = TimeCurrent();
   string statusOrigin = "RUNTIME_EMITTED_GOVERNANCE_STATUS";
   bool changed = (!gRuntimeGovernanceInitialized ||
                   st.governance_state != governanceState ||
                   st.trading_allowed != tradingAllowed ||
                   st.degraded_mode != degradedMode ||
                   st.truth_ready != truthReady ||
                   st.diagnostics_ready != diagnosticsReady ||
                   st.rollback_recently_applied != rollbackRecentlyApplied ||
                   st.reason_code != reasonCode ||
                   st.active_plan_id != activePlanId ||
                   st.active_mode != activeMode ||
                   st.status_origin != statusOrigin);

   st.governance_state = governanceState;
   st.trading_allowed = tradingAllowed;
   st.degraded_mode = degradedMode;
   st.truth_ready = truthReady;
   st.diagnostics_ready = diagnosticsReady;
   st.rollback_recently_applied = rollbackRecentlyApplied;
   st.reason_code = reasonCode;
   st.active_plan_id = activePlanId;
   st.active_mode = activeMode;
   st.status_origin = statusOrigin;
   st.operating_risk_envelope_state = (gOperatingRiskEnvelopeInitialized ? gOperatingRiskEnvelope.operating_risk_envelope_state : "PENDING_RUNTIME_INIT");
   st.current_guardrail_block_reason_code = (gOperatingRiskEnvelopeInitialized ? gOperatingRiskEnvelope.current_block_reason_code : "");
   st.current_guardrail_owner = (gOperatingRiskEnvelopeInitialized ? gOperatingRiskEnvelope.current_block_owner : "");
   st.evaluated_at = now;

   if(changed || st.last_state_change <= 0)
      st.last_state_change = now;

   gRuntimeGovernanceInitialized = true;
}

void EvaluateRuntimeGovernanceState(RuntimeGovernanceState &st)
{
   if(!gRuntimeGovernanceInitialized)
      InitRuntimeGovernanceState(st);

   RuntimeGovernanceLoadTransferPolicyTruth(st);

   string activePlanId = "";
   string activeMode = "";
   string truthReason = "";
   bool truthReady = RuntimeGovernanceEvaluateTruthReadiness(activePlanId, activeMode, truthReason);

   string diagnosticsReason = "";
   bool diagnosticsReady = RuntimeGovernanceEvaluateDiagnosticsReadiness(diagnosticsReason);

   if(!gRuntimeGovernanceStartupComplete)
   {
      RuntimeGovernanceApplyState(
         st,
         "STARTUP_INIT",
         false,
         false,
         truthReady,
         diagnosticsReady,
         gRuntimeGovernanceRollbackRecoveryPending,
         "startup_state_incomplete",
         activePlanId,
         activeMode
      );
      return;
   }

   if(!truthReady)
   {
      RuntimeGovernanceApplyState(
         st,
         "TRUTH_NOT_READY",
         false,
         false,
         false,
         diagnosticsReady,
         gRuntimeGovernanceRollbackRecoveryPending,
         truthReason,
         activePlanId,
         activeMode
      );
      return;
   }

   if(gRuntimeGovernanceRollbackRecoveryPending)
   {
      RuntimeGovernanceApplyState(
         st,
         "ROLLBACK_RECOVERED",
         false,
         false,
         true,
         diagnosticsReady,
         true,
         "rollback_recovery_pending",
         activePlanId,
         activeMode
      );
      return;
   }

   if(RuntimeGovernancePolicyLockOrFreezeActive(st))
   {
      string freezeReason = (StringLen(TrimString(st.strategy_transfer_runtime_freeze_reason_code)) > 0
                             ? st.strategy_transfer_runtime_freeze_reason_code
                             : "factory_first_admission_policy_lock_runtime_freeze");

      RuntimeGovernanceApplyState(
         st,
         "RUNTIME_FROZEN",
         false,
         false,
         true,
         diagnosticsReady,
         false,
         freezeReason,
         activePlanId,
         activeMode
      );
      return;
   }

   if(!EnableRuntimeExecution)
   {
      RuntimeGovernanceApplyState(
         st,
         "BLOCKED_NO_TRADE",
         false,
         false,
         true,
         diagnosticsReady,
         false,
         "runtime_execution_disabled",
         activePlanId,
         activeMode
      );
      return;
   }

   if(!diagnosticsReady)
   {
      RuntimeGovernanceApplyState(
         st,
         "DIAGNOSTICS_NOT_READY",
         false,
         true,
         true,
         false,
         false,
         diagnosticsReason,
         activePlanId,
         activeMode
      );
      return;
   }

   RuntimeGovernanceApplyState(
      st,
      "COHORT_GOVERNED_ACTIVE",
      true,
      false,
      true,
      true,
      false,
      "cohort_governed_execution_authority_active",
      activePlanId,
      activeMode
   );
}

string BuildRuntimeGovernanceStatusText(const RuntimeGovernanceState &st)
{
   string s = "";
   s += "runtime_governance_status\n";
   s += "governance_state=" + st.governance_state + "\n";
   s += "trading_allowed=" + (st.trading_allowed ? "true" : "false") + "\n";
   s += "degraded_mode=" + (st.degraded_mode ? "true" : "false") + "\n";
   s += "truth_ready=" + (st.truth_ready ? "true" : "false") + "\n";
   s += "diagnostics_ready=" + (st.diagnostics_ready ? "true" : "false") + "\n";
   s += "rollback_recently_applied=" + (st.rollback_recently_applied ? "true" : "false") + "\n";
   s += "reason_code=" + st.reason_code + "\n";
   s += "active_plan_id=" + st.active_plan_id + "\n";
   s += "active_mode=" + st.active_mode + "\n";
   s += "status_origin=" + st.status_origin + "\n";
   s += "factory_first_admission_policy_locked=" + DiagnosticBoolText(st.factory_first_admission_policy_locked) + "\n";
   s += "strategy_transfer_runtime_freeze_active=" + DiagnosticBoolText(st.strategy_transfer_runtime_freeze_active) + "\n";
   s += "strategy_transfer_runtime_freeze_scope=" + st.strategy_transfer_runtime_freeze_scope + "\n";
   s += "strategy_transfer_runtime_freeze_reason_code=" + st.strategy_transfer_runtime_freeze_reason_code + "\n";
   s += "strategy_execution_identity_authority_frozen=" + DiagnosticBoolText(st.strategy_execution_identity_authority_frozen) + "\n";
   s += "compiled_plan_runtime_privilege_frozen=" + DiagnosticBoolText(st.compiled_plan_runtime_privilege_frozen) + "\n";
   s += "council_runtime_execution_privilege_frozen=" + DiagnosticBoolText(st.council_runtime_execution_privilege_frozen) + "\n";
   s += "future_factory_admission_required_for_execution=" + DiagnosticBoolText(st.future_factory_admission_required_for_execution) + "\n";
   s += "lineage_preservation_mode=" + st.lineage_preservation_mode + "\n";
   s += "package1_policy_lock_state=" + st.package1_policy_lock_state + "\n";
   s += "package1_runtime_freeze_state=" + st.package1_runtime_freeze_state + "\n";
   s += "execution_authority_source=" + st.execution_authority_source + "\n";
   s += "execution_authority_cutover_state=" + st.execution_authority_cutover_state + "\n";
   s += "legacy_identity_execution_authority_active=" + DiagnosticBoolText(st.legacy_identity_execution_authority_active) + "\n";
   s += "factory_governed_execution_authority_active=" + DiagnosticBoolText(st.factory_governed_execution_authority_active) + "\n";
   s += "active_operating_cohort_defined=" + DiagnosticBoolText(st.active_operating_cohort_defined) + "\n";
   s += "active_operating_cohort_id=" + st.active_operating_cohort_id + "\n";
   s += "active_operating_candidate_count=" + IntegerToString(st.active_operating_candidate_count) + "\n";
   s += "execution_allowed_only_through_active_operating_cohort=" + DiagnosticBoolText(st.execution_allowed_only_through_active_operating_cohort) + "\n";
   s += "operating_cohort_admission_semantics=" + st.operating_cohort_admission_semantics + "\n";
   s += "operating_risk_envelope_state=" + st.operating_risk_envelope_state + "\n";
   s += "current_guardrail_block_reason_code=" + st.current_guardrail_block_reason_code + "\n";
   s += "current_guardrail_owner=" + st.current_guardrail_owner + "\n";
   s += "last_state_change=" + TimeToString(st.last_state_change, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\n";
   s += "evaluated_at=" + TimeToString(st.evaluated_at, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\n";
   return s;
}

string BuildRuntimeGovernanceStatusJson(const RuntimeGovernanceState &st)
{
   string j = "{";
   j += "\"governance_state\":\"" + JsonEscape(st.governance_state) + "\"";
   j += ",\"trading_allowed\":" + string(st.trading_allowed ? "true" : "false");
   j += ",\"degraded_mode\":" + string(st.degraded_mode ? "true" : "false");
   j += ",\"truth_ready\":" + string(st.truth_ready ? "true" : "false");
   j += ",\"diagnostics_ready\":" + string(st.diagnostics_ready ? "true" : "false");
   j += ",\"rollback_recently_applied\":" + string(st.rollback_recently_applied ? "true" : "false");
   j += ",\"reason_code\":\"" + JsonEscape(st.reason_code) + "\"";
   j += ",\"active_plan_id\":\"" + JsonEscape(st.active_plan_id) + "\"";
   j += ",\"active_mode\":\"" + JsonEscape(st.active_mode) + "\"";
   j += ",\"status_origin\":\"" + JsonEscape(st.status_origin) + "\"";
   j += ",\"factory_first_admission_policy_locked\":" + string(st.factory_first_admission_policy_locked ? "true" : "false");
   j += ",\"strategy_transfer_runtime_freeze_active\":" + string(st.strategy_transfer_runtime_freeze_active ? "true" : "false");
   j += ",\"strategy_transfer_runtime_freeze_scope\":\"" + JsonEscape(st.strategy_transfer_runtime_freeze_scope) + "\"";
   j += ",\"strategy_transfer_runtime_freeze_reason_code\":\"" + JsonEscape(st.strategy_transfer_runtime_freeze_reason_code) + "\"";
   j += ",\"strategy_execution_identity_authority_frozen\":" + string(st.strategy_execution_identity_authority_frozen ? "true" : "false");
   j += ",\"compiled_plan_runtime_privilege_frozen\":" + string(st.compiled_plan_runtime_privilege_frozen ? "true" : "false");
   j += ",\"council_runtime_execution_privilege_frozen\":" + string(st.council_runtime_execution_privilege_frozen ? "true" : "false");
   j += ",\"future_factory_admission_required_for_execution\":" + string(st.future_factory_admission_required_for_execution ? "true" : "false");
   j += ",\"lineage_preservation_mode\":\"" + JsonEscape(st.lineage_preservation_mode) + "\"";
   j += ",\"package1_policy_lock_state\":\"" + JsonEscape(st.package1_policy_lock_state) + "\"";
   j += ",\"package1_runtime_freeze_state\":\"" + JsonEscape(st.package1_runtime_freeze_state) + "\"";
   j += ",\"execution_authority_source\":\"" + JsonEscape(st.execution_authority_source) + "\"";
   j += ",\"execution_authority_cutover_state\":\"" + JsonEscape(st.execution_authority_cutover_state) + "\"";
   j += ",\"legacy_identity_execution_authority_active\":" + string(st.legacy_identity_execution_authority_active ? "true" : "false");
   j += ",\"factory_governed_execution_authority_active\":" + string(st.factory_governed_execution_authority_active ? "true" : "false");
   j += ",\"active_operating_cohort_defined\":" + string(st.active_operating_cohort_defined ? "true" : "false");
   j += ",\"active_operating_cohort_id\":\"" + JsonEscape(st.active_operating_cohort_id) + "\"";
   j += ",\"active_operating_candidate_count\":" + IntegerToString(st.active_operating_candidate_count);
   j += ",\"execution_allowed_only_through_active_operating_cohort\":" + string(st.execution_allowed_only_through_active_operating_cohort ? "true" : "false");
   j += ",\"operating_cohort_admission_semantics\":\"" + JsonEscape(st.operating_cohort_admission_semantics) + "\"";
   j += ",\"operating_risk_envelope_state\":\"" + JsonEscape(st.operating_risk_envelope_state) + "\"";
   j += ",\"current_guardrail_block_reason_code\":\"" + JsonEscape(st.current_guardrail_block_reason_code) + "\"";
   j += ",\"current_guardrail_owner\":\"" + JsonEscape(st.current_guardrail_owner) + "\"";
   j += ",\"last_state_change\":\"" + TimeToString(st.last_state_change, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\"";
   j += ",\"evaluated_at\":\"" + TimeToString(st.evaluated_at, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\"";
   j += "}";
   return j;
}

void SaveRuntimeGovernanceStatusBestEffort(const RuntimeGovernanceState &st)
{
   WriteTextFileAll(RuntimeGovernanceStatusTxtPath(), BuildRuntimeGovernanceStatusText(st));
   WriteTextFileAll(RuntimeGovernanceStatusJsonPath(), BuildRuntimeGovernanceStatusJson(st));
}

bool RuntimeGovernanceAllowsTrading(string &reasonCode)
{
   EvaluateRuntimeGovernanceState(gRuntimeGovernance);
   SaveRuntimeGovernanceStatusBestEffort(gRuntimeGovernance);
   reasonCode = gRuntimeGovernance.reason_code;
   return gRuntimeGovernance.trading_allowed;
}

void RuntimeGovernanceAcknowledgeRecoveryCycle()
{
   if(gRuntimeGovernance.governance_state == "ROLLBACK_RECOVERED" && gRuntimeGovernance.truth_ready)
      gRuntimeGovernanceRollbackRecoveryPending = false;
}

//---------------------------------------------------------
// Runtime risk & safety hardening (H5)
//---------------------------------------------------------
int RuntimeRiskSafetyEffectiveLockoutCount()
{
   int n = RuntimeExecutionFailureLockoutCount;
   if(n < 1)  n = 1;
   if(n > 20) n = 20;
   return n;
}

void InitRuntimeRiskSafetyState(RuntimeRiskSafetyState &st)
{
   datetime now = TimeCurrent();
   st.safety_state = "SAFE_BLOCK_ONLY";
   st.trading_allowed = false;
   st.emergency_flat_required = false;
   st.safe_block_mode = true;
   st.degraded_protection_mode = false;
   st.open_position_management_only = EnableOpenPositionManagementInBlockedSafeMode;
   st.safety_reason_code = "startup_state_incomplete";
   st.consecutive_open_failures = 0;
   st.rollback_recovery_pending = false;
   st.governance_degraded = false;
   st.governance_state = "";
   st.governance_reason_code = "";
   st.active_plan_id = "";
   st.active_mode = "";
   st.operating_risk_envelope_state = "PENDING_RUNTIME_INIT";
   st.envelope_clear_for_new_entries = false;
   st.current_blocking_guard = "";
   st.current_block_reason_code = "";
   st.current_block_owner = "";
   st.max_open_positions = 0;
   st.current_open_positions = 0;
   st.max_new_trades_per_session = 0;
   st.current_session_new_entries = 0;
   st.effective_session_trade_cap = 0;
   st.cooldown_bars = 0;
   st.bars_since_last_entry = 0;
   st.spread_guard_active = false;
   st.spread_guard_threshold_points = 0.0;
   st.current_spread_points = 0.0;
   st.risk_policy_guard_active = false;
   st.execution_quality_guard_active = false;
   st.emergency_stop_active = false;
   st.status_origin = "RUNTIME_EMITTED_RISK_SAFETY_STATUS";
   st.evaluated_at = now;
   st.last_state_change = now;
}

void RuntimeRiskSafetyApplyState(RuntimeRiskSafetyState &st,
                                 const string safetyState,
                                 const bool tradingAllowed,
                                 const bool emergencyFlatRequired,
                                 const bool safeBlockMode,
                                 const bool degradedProtectionMode,
                                 const bool openPositionManagementOnly,
                                 const string reasonCode,
                                 const int consecutiveOpenFailures,
                                 const bool rollbackRecoveryPending,
                                 const bool governanceDegraded,
                                 const string governanceState,
                                 const string governanceReasonCode,
                                 const string activePlanId,
                                 const string activeMode)
{
   datetime now = TimeCurrent();
   string statusOrigin = "RUNTIME_EMITTED_RISK_SAFETY_STATUS";
   bool changed = (!gRuntimeRiskSafetyInitialized ||
                   st.safety_state != safetyState ||
                   st.trading_allowed != tradingAllowed ||
                   st.emergency_flat_required != emergencyFlatRequired ||
                   st.safe_block_mode != safeBlockMode ||
                   st.degraded_protection_mode != degradedProtectionMode ||
                   st.open_position_management_only != openPositionManagementOnly ||
                   st.safety_reason_code != reasonCode ||
                   st.consecutive_open_failures != consecutiveOpenFailures ||
                   st.rollback_recovery_pending != rollbackRecoveryPending ||
                   st.governance_degraded != governanceDegraded ||
                   st.governance_state != governanceState ||
                   st.governance_reason_code != governanceReasonCode ||
                   st.active_plan_id != activePlanId ||
                   st.active_mode != activeMode ||
                   st.status_origin != statusOrigin);

   st.safety_state = safetyState;
   st.trading_allowed = tradingAllowed;
   st.emergency_flat_required = emergencyFlatRequired;
   st.safe_block_mode = safeBlockMode;
   st.degraded_protection_mode = degradedProtectionMode;
   st.open_position_management_only = openPositionManagementOnly;
   st.safety_reason_code = reasonCode;
   st.consecutive_open_failures = consecutiveOpenFailures;
   st.rollback_recovery_pending = rollbackRecoveryPending;
   st.governance_degraded = governanceDegraded;
   st.governance_state = governanceState;
   st.governance_reason_code = governanceReasonCode;
   st.active_plan_id = activePlanId;
   st.active_mode = activeMode;
   st.status_origin = statusOrigin;
   st.evaluated_at = now;

   if(changed || st.last_state_change <= 0)
      st.last_state_change = now;

   gRuntimeRiskSafetyInitialized = true;
}

void RuntimeRiskSafetyApplyEnvelopeMetadata(RuntimeRiskSafetyState &st, const OperatingEnvelopeEvaluation &ev)
{
   st.operating_risk_envelope_state = ev.operating_risk_envelope_state;
   st.envelope_clear_for_new_entries = ev.envelope_clear_for_new_entries;
   st.current_blocking_guard = ev.current_blocking_guard;
   st.current_block_reason_code = ev.current_block_reason_code;
   st.current_block_owner = ev.current_block_owner;
   st.max_open_positions = ev.max_open_positions;
   st.current_open_positions = ev.current_open_positions;
   st.max_new_trades_per_session = ev.max_new_trades_per_session;
   st.current_session_new_entries = ev.current_session_new_entries;
   st.effective_session_trade_cap = ev.effective_session_trade_cap;
   st.cooldown_bars = ev.cooldown_bars;
   st.bars_since_last_entry = ev.bars_since_last_entry;
   st.spread_guard_active = ev.spread_guard_active;
   st.spread_guard_threshold_points = ev.spread_guard_threshold_points;
   st.current_spread_points = ev.current_spread_points;
   st.risk_policy_guard_active = ev.risk_policy_guard_active;
   st.execution_quality_guard_active = ev.execution_quality_guard_active;
   st.emergency_stop_active = ev.emergency_stop_active || st.emergency_flat_required;
}

void EvaluateRuntimeRiskSafetyState(RuntimeRiskSafetyState &st)
{
   if(!gRuntimeRiskSafetyInitialized)
      InitRuntimeRiskSafetyState(st);

   string governanceState = gRuntimeGovernance.governance_state;
   string governanceReason = gRuntimeGovernance.reason_code;
   string activePlanId = gRuntimeGovernance.active_plan_id;
   string activeMode = gRuntimeGovernance.active_mode;

   bool rollbackPending = (gRuntimeGovernanceRollbackRecoveryPending || gRuntimeGovernance.rollback_recently_applied);
   bool governanceDegraded = (gRuntimeGovernance.degraded_mode ||
                              governanceState == "DIAGNOSTICS_NOT_READY" ||
                              governanceState == "TRUTH_NOT_READY" ||
                              governanceState == "STARTUP_INIT" ||
                              governanceState == "ROLLBACK_RECOVERED");

   bool allowMgmtOnly = EnableOpenPositionManagementInBlockedSafeMode;
   int  failureCount = gRuntimeConsecutiveOpenFailures;
   int  failureLockoutCount = RuntimeRiskSafetyEffectiveLockoutCount();

   OperatingEnvelopeEvaluation envelope;
   EvaluateOperatingEnvelope(CORE_NONE, envelope);

   if(!EnableRuntimeRiskSafetyHardening)
   {
      RuntimeRiskSafetyApplyState(
         st,
         (gRuntimeGovernance.trading_allowed ? "SAFE_ACTIVE" : "SAFE_BLOCK_ONLY"),
         gRuntimeGovernance.trading_allowed,
         false,
         (!gRuntimeGovernance.trading_allowed),
         false,
         ((!gRuntimeGovernance.trading_allowed) && allowMgmtOnly),
         gRuntimeGovernance.reason_code,
         failureCount,
         rollbackPending,
         governanceDegraded,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      return;
   }

   if(rollbackPending)
   {
      RuntimeRiskSafetyApplyState(
         st,
         "ROLLBACK_SAFE_HOLD",
         false,
         false,
         true,
         false,
         allowMgmtOnly,
         "rollback_recovery_pending",
         failureCount,
         true,
         governanceDegraded,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      return;
   }

   if(failureCount >= failureLockoutCount)
   {
      RuntimeRiskSafetyApplyState(
         st,
         "EXECUTION_FAILURE_LOCKOUT",
         false,
         false,
         true,
         true,
         allowMgmtOnly,
         "execution_failure_lockout",
         failureCount,
         false,
         governanceDegraded,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      st.emergency_stop_active = st.emergency_flat_required;
      return;
   }

   bool truthBroken = (!gRuntimeGovernance.truth_ready || governanceState == "TRUTH_NOT_READY" || governanceState == "STARTUP_INIT");
   bool diagnosticsBroken = (!gRuntimeGovernance.diagnostics_ready || governanceState == "DIAGNOSTICS_NOT_READY");
   bool governanceBlocked = (!gRuntimeGovernance.trading_allowed);

   if(truthBroken)
   {
      bool emergencyFlat = EnableEmergencyFlatOnCriticalSafetyState;
      RuntimeRiskSafetyApplyState(
         st,
         (emergencyFlat ? "EMERGENCY_FLAT_PENDING" : "SAFE_BLOCK_ONLY"),
         false,
         emergencyFlat,
         true,
         false,
         (emergencyFlat ? false : allowMgmtOnly),
         (StringLen(TrimString(governanceReason)) > 0 ? governanceReason : "truth_not_ready"),
         failureCount,
         false,
         true,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      st.emergency_stop_active = emergencyFlat;
      return;
   }

   if(diagnosticsBroken)
   {
      RuntimeRiskSafetyApplyState(
         st,
         "DEGRADED_PROTECTION",
         false,
         false,
         true,
         true,
         allowMgmtOnly,
         (StringLen(TrimString(governanceReason)) > 0 ? governanceReason : "diagnostics_surface_not_ready"),
         failureCount,
         false,
         true,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      return;
   }

   if(governanceBlocked)
   {
      RuntimeRiskSafetyApplyState(
         st,
         "SAFE_BLOCK_ONLY",
         false,
         false,
         true,
         false,
         allowMgmtOnly,
         (StringLen(TrimString(governanceReason)) > 0 ? governanceReason : "runtime_blocked"),
         failureCount,
         false,
         governanceDegraded,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      return;
   }

   if(!envelope.envelope_clear_for_new_entries)
   {
      RuntimeRiskSafetyApplyState(
         st,
         "OPERATING_GUARD_BLOCK",
         false,
         false,
         true,
         false,
         allowMgmtOnly,
         (StringLen(TrimString(envelope.current_block_reason_code)) > 0 ? envelope.current_block_reason_code : "operating_risk_envelope_blocked"),
         failureCount,
         false,
         governanceDegraded,
         governanceState,
         governanceReason,
         activePlanId,
         activeMode
      );
      RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
      return;
   }

   RuntimeRiskSafetyApplyState(
      st,
      "SAFE_ACTIVE",
      true,
      false,
      false,
      false,
      false,
      "runtime_safe",
      failureCount,
      false,
      governanceDegraded,
      governanceState,
      governanceReason,
      activePlanId,
      activeMode
   );
   RuntimeRiskSafetyApplyEnvelopeMetadata(st, envelope);
}

string BuildRuntimeRiskSafetyStatusText(const RuntimeRiskSafetyState &st)
{
   string s = "";
   s += "risk_safety_status\n";
   s += "artifact_role=RUNTIME_RISK_SAFETY_STATUS\n";
   s += "artifact_authority_class=NON_AUTHORITATIVE_DERIVED_RUNTIME_SAFETY\n";
   s += "trust_rule=runtime_safety_visibility_only_non_authoritative\n";
   s += "status_origin=" + st.status_origin + "\n";
   s += "safety_state=" + st.safety_state + "\n";
   s += "trading_allowed=" + DiagnosticBoolText(st.trading_allowed) + "\n";
   s += "emergency_flat_required=" + DiagnosticBoolText(st.emergency_flat_required) + "\n";
   s += "safe_block_mode=" + DiagnosticBoolText(st.safe_block_mode) + "\n";
   s += "degraded_protection_mode=" + DiagnosticBoolText(st.degraded_protection_mode) + "\n";
   s += "open_position_management_only=" + DiagnosticBoolText(st.open_position_management_only) + "\n";
   s += "safety_reason_code=" + st.safety_reason_code + "\n";
   s += "consecutive_open_failures=" + IntegerToString(st.consecutive_open_failures) + "\n";
   s += "rollback_recovery_pending=" + DiagnosticBoolText(st.rollback_recovery_pending) + "\n";
   s += "governance_degraded=" + DiagnosticBoolText(st.governance_degraded) + "\n";
   s += "governance_state=" + st.governance_state + "\n";
   s += "governance_reason_code=" + st.governance_reason_code + "\n";
   s += "active_plan_id=" + st.active_plan_id + "\n";
   s += "active_mode=" + st.active_mode + "\n";
   s += "operating_risk_envelope_state=" + st.operating_risk_envelope_state + "\n";
   s += "envelope_clear_for_new_entries=" + DiagnosticBoolText(st.envelope_clear_for_new_entries) + "\n";
   s += "current_blocking_guard=" + st.current_blocking_guard + "\n";
   s += "current_block_reason_code=" + st.current_block_reason_code + "\n";
   s += "current_block_owner=" + st.current_block_owner + "\n";
   s += "max_open_positions=" + IntegerToString(st.max_open_positions) + "\n";
   s += "current_open_positions=" + IntegerToString(st.current_open_positions) + "\n";
   s += "max_new_trades_per_session=" + IntegerToString(st.max_new_trades_per_session) + "\n";
   s += "current_session_new_entries=" + IntegerToString(st.current_session_new_entries) + "\n";
   s += "effective_session_trade_cap=" + IntegerToString(st.effective_session_trade_cap) + "\n";
   s += "cooldown_bars=" + IntegerToString(st.cooldown_bars) + "\n";
   s += "bars_since_last_entry=" + IntegerToString(st.bars_since_last_entry) + "\n";
   s += "spread_guard_active=" + DiagnosticBoolText(st.spread_guard_active) + "\n";
   s += "spread_guard_threshold_points=" + DoubleToString(st.spread_guard_threshold_points, 1) + "\n";
   s += "current_spread_points=" + DoubleToString(st.current_spread_points, 1) + "\n";
   s += "risk_policy_guard_active=" + DiagnosticBoolText(st.risk_policy_guard_active) + "\n";
   s += "execution_quality_guard_active=" + DiagnosticBoolText(st.execution_quality_guard_active) + "\n";
   s += "emergency_stop_active=" + DiagnosticBoolText(st.emergency_stop_active) + "\n";
   s += "last_state_change=" + DiagnosticTimeText(st.last_state_change) + "\n";
   s += "evaluated_at=" + DiagnosticTimeText(st.evaluated_at) + "\n";
   return s;
}

string BuildRuntimeRiskSafetyStatusJson(const RuntimeRiskSafetyState &st)
{
   string j = "{";
   j += "\"artifact_role\":\"RUNTIME_RISK_SAFETY_STATUS\"";
   j += ",\"artifact_authority_class\":\"NON_AUTHORITATIVE_DERIVED_RUNTIME_SAFETY\"";
   j += ",\"trust_rule\":\"runtime_safety_visibility_only_non_authoritative\"";
   j += ",\"status_origin\":\"" + JsonEscape(st.status_origin) + "\"";
   j += ",\"safety_state\":\"" + JsonEscape(st.safety_state) + "\"";
   j += ",\"trading_allowed\":" + string(st.trading_allowed ? "true" : "false");
   j += ",\"emergency_flat_required\":" + string(st.emergency_flat_required ? "true" : "false");
   j += ",\"safe_block_mode\":" + string(st.safe_block_mode ? "true" : "false");
   j += ",\"degraded_protection_mode\":" + string(st.degraded_protection_mode ? "true" : "false");
   j += ",\"open_position_management_only\":" + string(st.open_position_management_only ? "true" : "false");
   j += ",\"safety_reason_code\":\"" + JsonEscape(st.safety_reason_code) + "\"";
   j += ",\"consecutive_open_failures\":" + IntegerToString(st.consecutive_open_failures);
   j += ",\"rollback_recovery_pending\":" + string(st.rollback_recovery_pending ? "true" : "false");
   j += ",\"governance_degraded\":" + string(st.governance_degraded ? "true" : "false");
   j += ",\"governance_state\":\"" + JsonEscape(st.governance_state) + "\"";
   j += ",\"governance_reason_code\":\"" + JsonEscape(st.governance_reason_code) + "\"";
   j += ",\"active_plan_id\":\"" + JsonEscape(st.active_plan_id) + "\"";
   j += ",\"active_mode\":\"" + JsonEscape(st.active_mode) + "\"";
   j += ",\"operating_risk_envelope_state\":\"" + JsonEscape(st.operating_risk_envelope_state) + "\"";
   j += ",\"envelope_clear_for_new_entries\":" + string(st.envelope_clear_for_new_entries ? "true" : "false");
   j += ",\"current_blocking_guard\":\"" + JsonEscape(st.current_blocking_guard) + "\"";
   j += ",\"current_block_reason_code\":\"" + JsonEscape(st.current_block_reason_code) + "\"";
   j += ",\"current_block_owner\":\"" + JsonEscape(st.current_block_owner) + "\"";
   j += ",\"max_open_positions\":" + IntegerToString(st.max_open_positions);
   j += ",\"current_open_positions\":" + IntegerToString(st.current_open_positions);
   j += ",\"max_new_trades_per_session\":" + IntegerToString(st.max_new_trades_per_session);
   j += ",\"current_session_new_entries\":" + IntegerToString(st.current_session_new_entries);
   j += ",\"effective_session_trade_cap\":" + IntegerToString(st.effective_session_trade_cap);
   j += ",\"cooldown_bars\":" + IntegerToString(st.cooldown_bars);
   j += ",\"bars_since_last_entry\":" + IntegerToString(st.bars_since_last_entry);
   j += ",\"spread_guard_active\":" + string(st.spread_guard_active ? "true" : "false");
   j += ",\"spread_guard_threshold_points\":" + DoubleToString(st.spread_guard_threshold_points, 1);
   j += ",\"current_spread_points\":" + DoubleToString(st.current_spread_points, 1);
   j += ",\"risk_policy_guard_active\":" + string(st.risk_policy_guard_active ? "true" : "false");
   j += ",\"execution_quality_guard_active\":" + string(st.execution_quality_guard_active ? "true" : "false");
   j += ",\"emergency_stop_active\":" + string(st.emergency_stop_active ? "true" : "false");
   j += ",\"last_state_change\":\"" + JsonEscape(DiagnosticTimeText(st.last_state_change)) + "\"";
   j += ",\"evaluated_at\":\"" + JsonEscape(DiagnosticTimeText(st.evaluated_at)) + "\"";
   j += "}";
   return j;
}

void SaveRuntimeRiskSafetyStatusBestEffort(const RuntimeRiskSafetyState &st)
{
   WriteTextFileAll(RiskSafetyStatusTxtPath(), BuildRuntimeRiskSafetyStatusText(st));
   WriteTextFileAll(RiskSafetyStatusJsonPath(), BuildRuntimeRiskSafetyStatusJson(st));
}

void RefreshRuntimeGovernanceAndSafetyStatusBestEffort()
{
   EvaluateRuntimeGovernanceState(gRuntimeGovernance);
   EvaluateRuntimeRiskSafetyState(gRuntimeRiskSafety);
   SaveRuntimeRiskSafetyStatusBestEffort(gRuntimeRiskSafety);
   RefreshOperatingRiskEnvelopeStatusBestEffort();
   EvaluateRuntimeGovernanceState(gRuntimeGovernance);
   SaveRuntimeGovernanceStatusBestEffort(gRuntimeGovernance);
   RefreshExecutionAuthorityStatusBestEffort();
}

bool RuntimeRiskSafetyAllowsNewEntries(string &reasonCode)
{
   EvaluateRuntimeRiskSafetyState(gRuntimeRiskSafety);
   SaveRuntimeRiskSafetyStatusBestEffort(gRuntimeRiskSafety);
   reasonCode = gRuntimeRiskSafety.safety_reason_code;
   return gRuntimeRiskSafety.trading_allowed;
}

bool RuntimeRiskSafetyAllowsOpenPositionManagement()
{
   EvaluateRuntimeRiskSafetyState(gRuntimeRiskSafety);
   SaveRuntimeRiskSafetyStatusBestEffort(gRuntimeRiskSafety);

   if(gRuntimeRiskSafety.emergency_flat_required)
      return false;

   if(gRuntimeRiskSafety.trading_allowed)
      return true;

   return gRuntimeRiskSafety.open_position_management_only;
}

void RuntimeRiskSafetyRecordExecutionOpenResult(const bool opened)
{
   if(opened)
      gRuntimeConsecutiveOpenFailures = 0;
   else
      gRuntimeConsecutiveOpenFailures++;

   EvaluateRuntimeRiskSafetyState(gRuntimeRiskSafety);
   SaveRuntimeRiskSafetyStatusBestEffort(gRuntimeRiskSafety);
}

bool RuntimeRiskSafetyEmergencyFlatActive()
{
   EvaluateRuntimeRiskSafetyState(gRuntimeRiskSafety);
   SaveRuntimeRiskSafetyStatusBestEffort(gRuntimeRiskSafety);

   return (EnableRuntimeRiskSafetyHardening &&
           EnableEmergencyFlatOnCriticalSafetyState &&
           gRuntimeRiskSafety.emergency_flat_required);
}


int AIGateClampInt(const int value, const int minValue, const int maxValue)
{
   int v = value;
   if(v < minValue)
      v = minValue;
   if(v > maxValue)
      v = maxValue;
   return v;
}

int AIGateEffectiveMinDecisions()          { return AIGateClampInt(AIGateMinDecisions, 0, 100000); }
int AIGateEffectiveMinTradeOpens()         { return AIGateClampInt(AIGateMinTradeOpens, 0, 100000); }
int AIGateEffectiveMinClosedOutcomes()     { return AIGateClampInt(AIGateMinClosedOutcomes, 0, 100000); }
int AIGateEffectiveHourlyRunCap()          { return AIGateClampInt(AIHourlyRunCap, 0, 100); }
int AIGateEffectiveDeepInvestigationCap()  { return AIGateClampInt(AIDeepInvestigationDailyCap, 0, 100); }
int AIGateEffectiveTriggerCooldownMinutes(){ return AIGateClampInt(AITriggerCooldownMinutes, 0, 1440); }

int AIGateCountOccurrences(const string textValue, const string needle)
{
   if(StringLen(textValue) <= 0 || StringLen(needle) <= 0)
      return 0;

   int count = 0;
   int pos = 0;
   int step = StringLen(needle);

   while(true)
   {
      int found = StringFind(textValue, needle, pos);
      if(found < 0)
         break;

      count++;
      pos = found + step;
   }

   return count;
}

bool AIGateArtifactLooksReady(const string relPath)
{
   if(!FileIsExist(relPath))
      return false;

   string textValue = "";
   if(!ReadTextFileAll(relPath, textValue))
      return false;

   if(StringFind(textValue, "PACKAGE_PLACEHOLDER_PENDING_") >= 0)
      return false;

   if(StringFind(textValue, "\"status_origin\":\"PACKAGE_PLACEHOLDER_") >= 0)
      return false;

   if(StringFind(textValue, "status_origin=PACKAGE_PLACEHOLDER_") >= 0)
      return false;

   return (StringLen(TrimString(textValue)) > 0);
}

bool AIGateLoadValidationCounts(int &decisionsTotal, int &tradeOpensTotal)
{
   decisionsTotal = 0;
   tradeOpensTotal = 0;

   string validationJson = "";
   if(ReadTextFileAll(ExecutionQualityValidationJsonPath(), validationJson))
   {
      ExtractJsonIntField(validationJson, "decisions_total", decisionsTotal);
      ExtractJsonIntField(validationJson, "executed_trades_total", tradeOpensTotal);
   }

   if(decisionsTotal > 0 || tradeOpensTotal > 0)
      return true;

   string journalText = "";
   if(!ReadTextFileAll(PERF_JOURNAL_PATH, journalText))
      return false;

   decisionsTotal = AIGateCountOccurrences(journalText, "\"record_type\":\"DECISION\"");
   tradeOpensTotal = AIGateCountOccurrences(journalText, "\"record_type\":\"TRADE_OPEN\"");
   return (decisionsTotal > 0 || tradeOpensTotal > 0);
}

bool AIGateLoadClosedOutcomeCount(int &closedOutcomesTotal)
{
   closedOutcomesTotal = 0;

   string feedbackJson = "";
   if(!ReadTextFileAll("AI\\council_feedback.json", feedbackJson))
      return false;

   closedOutcomesTotal = AIGateCountOccurrences(feedbackJson, "\"record_type\":\"TRADE_CLOSE_OUTCOME\"");
   return (closedOutcomesTotal > 0);
}

string AIGateAllowedInputClassesForState(const string authorityState)
{
   if(authorityState == "AI_OFF")
      return "NONE";
   return "ALWAYS_VISIBLE_SUMMARIES,ON_DEMAND_RETRIEVAL,SNAPSHOT_ONLY";
}

string AIGateAllowedOutputClassesForState(const string authorityState)
{
   if(authorityState == "AI_OFF")
      return "NONE";

   if(authorityState == "AI_SHADOW_ONLY")
      return "DIAGNOSTIC_FINDINGS,STRUCTURED_ANOMALIES,HYPOTHESES,PERIODIC_REPORTS,OPERATOR_ANSWERS,LEARNING_GOVERNANCE_EVIDENCE,COUNCIL_CONTEXTUAL_ADVISORY";

   return "DIAGNOSTIC_FINDINGS,STRUCTURED_ANOMALIES,HYPOTHESES,RECOMMENDATIONS,REVIEWABLE_PROPOSALS,PERIODIC_REPORTS,OPERATOR_ANSWERS,LEARNING_GOVERNANCE_EVIDENCE,COUNCIL_CONTEXTUAL_ADVISORY";
}

string AIGateAllowedTaskFamiliesForState(const string authorityState)
{
   if(authorityState == "AI_OFF")
      return "NONE";

   if(authorityState == "AI_SHADOW_ONLY")
      return "FORENSIC_ANALYSIS,DRIFT_ANALYSIS,ROOT_CAUSE_INVESTIGATION,COVERAGE_GAP_ANALYSIS,GOVERNANCE_AUDIT,OPERATOR_COPILOT,LEARNING_GOVERNANCE_SUPPORT,COUNCIL_CONTEXTUAL_ADVISORY";

   return "FORENSIC_ANALYSIS,DRIFT_ANALYSIS,ROOT_CAUSE_INVESTIGATION,BOUNDED_PROPOSAL_GENERATION,COVERAGE_GAP_ANALYSIS,GOVERNANCE_AUDIT,OPERATOR_COPILOT,LEARNING_GOVERNANCE_SUPPORT,COUNCIL_CONTEXTUAL_ADVISORY";
}

string AIGateForbiddenSurfaceClasses()
{
   return "SECRETS,CREDENTIALS,MUTABLE_CONTROL_SURFACES,DIRECT_EXECUTION_PERMISSIONS,WRITE_CAPABLE_TRUTH_SOURCES,DIRECT_RUNTIME_MUTATION";
}

void InitAIAuthorityReadinessState(AIAuthorityReadinessState &st)
{
   datetime now = TimeCurrent();

   st.artifact_role = "AI_ACTIVATION_READINESS_STATUS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_AI_GOVERNANCE";
   st.summary_version = "H6_AI_ACTIVATION_READINESS_V2";
   st.trust_rule = "authority_gate_visibility_only_not_runtime_truth";
   st.status_origin = "RUNTIME_EVALUATED_AI_GOVERNANCE";

   st.authority_state = "AI_OFF";
   st.readiness_state = "NOT_READY";

   st.ai_enabled = EnableAIEvolution;
   st.ai_bridge_ready = false;
   st.truth_ready = false;
   st.diagnostics_ready = false;
   st.replay_ready = false;
   st.validation_ready = false;
   st.safety_ready = false;
   st.sample_ready = false;
   st.security_clearance_for_shadow = AIGateSecurityClearanceForShadow;
   st.security_clearance_for_advisory = AIGateSecurityClearanceForAdvisory;
   st.runtime_governance_allows_ai = false;

   st.readiness_reason_code = "not_ready";
   st.next_upgrade_blocker = "startup_state_incomplete";

   st.active_plan_id = "";
   st.active_mode = "";

   st.allowed_task_families = "NONE";
   st.allowed_input_classes = "NONE";
   st.allowed_output_classes = "NONE";
   st.forbidden_surface_classes = AIGateForbiddenSurfaceClasses();

   st.learning_governance_role = "EVIDENCE_INPUT_ONLY|REVIEWABLE_PROPOSAL_ONLY";
   st.council_advisory_role = "POST_CANDIDATE_CONTEXTUAL_ADVISORY_ONLY";
   st.council_advisory_reserved_future_state = "BLOCK_CANDIDATE_ELIGIBLE";
   st.council_advisory_allowed_outputs = "NO_ADVISORY,ADVISORY_OK,ADVISORY_CAUTION,ADVISORY_STRONG_CAUTION,ADVISORY_INSUFFICIENT_EVIDENCE,BLOCK_CANDIDATE_ELIGIBLE";
   st.council_advisory_forbidden_outputs = "DIRECT_BUY_SELL_GENERATION,DIRECTION_REPLACEMENT,DIRECT_BLOCK_ALLOW_CONTROL,PARAMETER_MUTATION";

   st.trigger_mode = "EVENT_DRIVEN_CADENCE_CONTROLLED";
   st.cost_control_mode = "SUMMARY_FIRST_SELECTIVE_RETRIEVAL";
   st.dedupe_mode = "ENABLED";
   st.deep_investigation_mode = "ON_TRIGGER_ONLY";

   st.effective_min_decisions = AIGateEffectiveMinDecisions();
   st.effective_min_trade_opens = AIGateEffectiveMinTradeOpens();
   st.effective_min_closed_outcomes = AIGateEffectiveMinClosedOutcomes();
   st.sample_decisions = 0;
   st.sample_trade_opens = 0;
   st.sample_closed_outcomes = 0;

   st.effective_hourly_run_cap = AIGateEffectiveHourlyRunCap();
   st.effective_deep_investigation_daily_cap = AIGateEffectiveDeepInvestigationCap();
   st.effective_trigger_cooldown_minutes = AIGateEffectiveTriggerCooldownMinutes();

   st.direct_control_allowed = false;
   st.auto_apply_allowed = false;
   st.directional_trade_generation_allowed = false;
   st.direct_candidate_veto_active = false;

   st.review_surface_state = "NOT_PRESENT";
   st.review_surface_present = false;
   st.review_surface_independent_of_authority = true;
   st.review_surface_implies_authority_ready = false;
   st.readiness_review_consistency_state = "PENDING_REVIEW_SURFACE_CHECK";
   st.readiness_review_note = "AI readiness evaluation pending review-surface consistency check.";

   st.evaluated_at = now;
   st.last_state_change = now;
}

void FinalizeAIReadinessReviewConsistency(AIAuthorityReadinessState &st)
{
   string aiOperationalReviewJson = "";
   st.review_surface_present = ReadTextFileAll(AIOperationalReviewJsonPath(), aiOperationalReviewJson);
   st.review_surface_state = (st.review_surface_present ? "OPERATIONAL_PRESENT" : "NOT_PRESENT");
   st.review_surface_independent_of_authority = true;
   st.review_surface_implies_authority_ready = false;

   if(st.review_surface_present)
   {
      st.readiness_review_consistency_state = "CONSISTENT_SHADOW_REVIEW_ONLY";
      st.readiness_review_note = "AI operational review is present as bounded shadow interpretation only; it remains independent of execution authority readiness.";
      if(st.authority_state == "AI_OFF" && st.readiness_state == "NOT_READY")
      {
         st.readiness_reason_code = "authority_off_review_present_bounded";
         if(StringLen(TrimString(st.next_upgrade_blocker)) == 0)
            st.next_upgrade_blocker = "bounded_review_does_not_imply_authority_ready";
      }
   }
   else
   {
      st.readiness_review_consistency_state = "CONSISTENT_NO_REVIEW_SURFACE";
      st.readiness_review_note = "AI readiness is evaluated without an active bounded review surface.";
   }
}

void ApplyAIAuthorityReadinessState(AIAuthorityReadinessState &st,
                                    const string authorityState,
                                    const string readinessState,
                                    const bool aiEnabled,
                                    const bool aiBridgeReady,
                                    const bool truthReady,
                                    const bool diagnosticsReady,
                                    const bool replayReady,
                                    const bool validationReady,
                                    const bool safetyReady,
                                    const bool sampleReady,
                                    const bool securityShadow,
                                    const bool securityAdvisory,
                                    const bool governanceAllowsAI,
                                    const string readinessReasonCode,
                                    const string nextUpgradeBlocker,
                                    const string activePlanId,
                                    const string activeMode,
                                    const int sampleDecisions,
                                    const int sampleTradeOpens,
                                    const int sampleClosedOutcomes)
{
   if(!gAIAuthorityReadinessInitialized)
      InitAIAuthorityReadinessState(st);

   datetime now = TimeCurrent();
   string statusOrigin = "RUNTIME_EVALUATED_AI_GOVERNANCE";
   bool changed = (!gAIAuthorityReadinessInitialized ||
                   st.authority_state != authorityState ||
                   st.readiness_state != readinessState ||
                   st.ai_enabled != aiEnabled ||
                   st.ai_bridge_ready != aiBridgeReady ||
                   st.truth_ready != truthReady ||
                   st.diagnostics_ready != diagnosticsReady ||
                   st.replay_ready != replayReady ||
                   st.validation_ready != validationReady ||
                   st.safety_ready != safetyReady ||
                   st.sample_ready != sampleReady ||
                   st.security_clearance_for_shadow != securityShadow ||
                   st.security_clearance_for_advisory != securityAdvisory ||
                   st.runtime_governance_allows_ai != governanceAllowsAI ||
                   st.readiness_reason_code != readinessReasonCode ||
                   st.next_upgrade_blocker != nextUpgradeBlocker ||
                   st.active_plan_id != activePlanId ||
                   st.active_mode != activeMode ||
                   st.sample_decisions != sampleDecisions ||
                   st.sample_trade_opens != sampleTradeOpens ||
                   st.sample_closed_outcomes != sampleClosedOutcomes ||
                   st.status_origin != statusOrigin);

   st.artifact_role = "AI_ACTIVATION_READINESS_STATUS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_AI_GOVERNANCE";
   st.summary_version = "H6_AI_ACTIVATION_READINESS_V2";
   st.trust_rule = "authority_gate_visibility_only_not_runtime_truth";
   st.status_origin = statusOrigin;

   st.authority_state = authorityState;
   st.readiness_state = readinessState;

   st.ai_enabled = aiEnabled;
   st.ai_bridge_ready = aiBridgeReady;
   st.truth_ready = truthReady;
   st.diagnostics_ready = diagnosticsReady;
   st.replay_ready = replayReady;
   st.validation_ready = validationReady;
   st.safety_ready = safetyReady;
   st.sample_ready = sampleReady;
   st.security_clearance_for_shadow = securityShadow;
   st.security_clearance_for_advisory = securityAdvisory;
   st.runtime_governance_allows_ai = governanceAllowsAI;

   st.readiness_reason_code = readinessReasonCode;
   st.next_upgrade_blocker = nextUpgradeBlocker;

   st.active_plan_id = activePlanId;
   st.active_mode = activeMode;

   st.allowed_task_families = AIGateAllowedTaskFamiliesForState(authorityState);
   st.allowed_input_classes = AIGateAllowedInputClassesForState(authorityState);
   st.allowed_output_classes = AIGateAllowedOutputClassesForState(authorityState);
   st.forbidden_surface_classes = AIGateForbiddenSurfaceClasses();

   st.learning_governance_role = "EVIDENCE_INPUT_ONLY|REVIEWABLE_PROPOSAL_ONLY";
   st.council_advisory_role = "POST_CANDIDATE_CONTEXTUAL_ADVISORY_ONLY";
   st.council_advisory_reserved_future_state = "BLOCK_CANDIDATE_ELIGIBLE";
   st.council_advisory_allowed_outputs = "NO_ADVISORY,ADVISORY_OK,ADVISORY_CAUTION,ADVISORY_STRONG_CAUTION,ADVISORY_INSUFFICIENT_EVIDENCE,BLOCK_CANDIDATE_ELIGIBLE";
   st.council_advisory_forbidden_outputs = "DIRECT_BUY_SELL_GENERATION,DIRECTION_REPLACEMENT,DIRECT_BLOCK_ALLOW_CONTROL,PARAMETER_MUTATION";

   st.trigger_mode = "EVENT_DRIVEN_CADENCE_CONTROLLED";
   st.cost_control_mode = "SUMMARY_FIRST_SELECTIVE_RETRIEVAL";
   st.dedupe_mode = "ENABLED";
   st.deep_investigation_mode = "ON_TRIGGER_ONLY";

   st.effective_min_decisions = AIGateEffectiveMinDecisions();
   st.effective_min_trade_opens = AIGateEffectiveMinTradeOpens();
   st.effective_min_closed_outcomes = AIGateEffectiveMinClosedOutcomes();
   st.sample_decisions = sampleDecisions;
   st.sample_trade_opens = sampleTradeOpens;
   st.sample_closed_outcomes = sampleClosedOutcomes;

   st.effective_hourly_run_cap = AIGateEffectiveHourlyRunCap();
   st.effective_deep_investigation_daily_cap = AIGateEffectiveDeepInvestigationCap();
   st.effective_trigger_cooldown_minutes = AIGateEffectiveTriggerCooldownMinutes();

   st.direct_control_allowed = false;
   st.auto_apply_allowed = false;
   st.directional_trade_generation_allowed = false;
   st.direct_candidate_veto_active = false;

   FinalizeAIReadinessReviewConsistency(st);

   st.evaluated_at = now;
   if(changed || st.last_state_change <= 0)
      st.last_state_change = now;

   gAIAuthorityReadinessInitialized = true;
}

void EvaluateAIAuthorityReadinessState(AIAuthorityReadinessState &st)
{
   if(!gAIAuthorityReadinessInitialized)
      InitAIAuthorityReadinessState(st);

   bool aiEnabled = EnableAIEvolution;
   bool aiBridgeReady = AIIsReady(gAISecrets);
   bool truthReady = gRuntimeGovernance.truth_ready;
   bool diagnosticsReady = AIGateArtifactLooksReady(DiagnosticRuntimeSummaryJsonPath());
   bool replayReady = AIGateArtifactLooksReady(ReplayValidationSummaryJsonPath());
   bool validationReady = AIGateArtifactLooksReady(ExecutionQualityValidationJsonPath());

   bool rollbackPending = (gRuntimeGovernanceRollbackRecoveryPending ||
                           gRuntimeGovernance.rollback_recently_applied ||
                           gRuntimeRiskSafety.rollback_recovery_pending);

   bool safetyCritical = (gRuntimeRiskSafety.safety_state == "EXECUTION_FAILURE_LOCKOUT" ||
                          gRuntimeRiskSafety.safety_state == "EMERGENCY_FLAT_PENDING" ||
                          gRuntimeRiskSafety.safety_state == "ROLLBACK_SAFE_HOLD");

   bool safetyReady = (!rollbackPending &&
                       !safetyCritical &&
                       !gRuntimeRiskSafety.emergency_flat_required &&
                       !gRuntimeRiskSafety.safe_block_mode &&
                       gRuntimeRiskSafety.safety_state == "SAFE_ACTIVE");

   bool governanceAllowsAI = (gRuntimeGovernanceStartupComplete &&
                              gRuntimeGovernance.governance_state == "READY_ACTIVE" &&
                              gRuntimeGovernance.trading_allowed &&
                              truthReady &&
                              safetyReady);

   int sampleDecisions = 0;
   int sampleTradeOpens = 0;
   int sampleClosedOutcomes = 0;

   AIGateLoadValidationCounts(sampleDecisions, sampleTradeOpens);
   AIGateLoadClosedOutcomeCount(sampleClosedOutcomes);

   bool sampleReady = (sampleDecisions >= AIGateEffectiveMinDecisions() &&
                       sampleTradeOpens >= AIGateEffectiveMinTradeOpens() &&
                       sampleClosedOutcomes >= AIGateEffectiveMinClosedOutcomes());

   bool securityShadow = AIGateSecurityClearanceForShadow;
   bool securityAdvisory = AIGateSecurityClearanceForAdvisory;

   string authorityState = "AI_OFF";
   string readinessState = "NOT_READY";
   string reasonCode = "ai_gate_not_ready";
   string nextBlocker = "truth_not_ready";

   string activePlanId = gRuntimeGovernance.active_plan_id;
   string activeMode = gRuntimeGovernance.active_mode;
   if(StringLen(activePlanId) <= 0)
      activePlanId = gPlan.plan_id;
   if(StringLen(activeMode) <= 0)
      activeMode = NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode);

   if(!aiEnabled)
   {
      reasonCode = "ai_disabled";
      nextBlocker = "enable_ai_runtime_input";
   }
   else if(!aiBridgeReady)
   {
      reasonCode = "ai_bridge_not_ready";
      nextBlocker = "configure_ai_bridge_transport";
   }
   else if(!truthReady)
   {
      reasonCode = (StringLen(gRuntimeGovernance.reason_code) > 0 ? gRuntimeGovernance.reason_code : "truth_not_ready");
      nextBlocker = "truth_not_ready";
   }
   else if(!safetyReady)
   {
      if(rollbackPending)
      {
         reasonCode = "rollback_recovery_pending";
         nextBlocker = "rollback_recovery_pending";
      }
      else if(gRuntimeRiskSafety.safety_state == "EXECUTION_FAILURE_LOCKOUT")
      {
         reasonCode = "execution_failure_lockout";
         nextBlocker = "execution_failure_lockout";
      }
      else if(gRuntimeRiskSafety.safety_state == "EMERGENCY_FLAT_PENDING")
      {
         reasonCode = "emergency_flat_pending";
         nextBlocker = "emergency_flat_pending";
      }
      else if(gRuntimeRiskSafety.safety_state == "SAFE_BLOCK_ONLY" || gRuntimeRiskSafety.safety_state == "DEGRADED_PROTECTION")
      {
         reasonCode = (StringLen(gRuntimeRiskSafety.safety_reason_code) > 0 ? gRuntimeRiskSafety.safety_reason_code : "runtime_safety_not_ready");
         nextBlocker = "runtime_safety_not_ready";
      }
      else
      {
         reasonCode = "runtime_safety_not_ready";
         nextBlocker = "runtime_safety_not_ready";
      }
   }
   else if(!diagnosticsReady)
   {
      reasonCode = "diagnostic_summary_not_ready";
      nextBlocker = "diagnostic_runtime_summary_not_ready";
   }
   else if(!validationReady)
   {
      reasonCode = "validation_summary_not_ready";
      nextBlocker = "execution_quality_validation_not_ready";
   }
   else if(!replayReady)
   {
      reasonCode = "replay_summary_not_ready";
      nextBlocker = "replay_validation_summary_not_ready";
   }
   else if(!sampleReady)
   {
      reasonCode = "sample_readiness_not_met";
      nextBlocker = "minimum_sample_not_met";
   }
   else if(!securityShadow)
   {
      reasonCode = "shadow_security_clearance_not_enabled";
      nextBlocker = "shadow_security_clearance_not_enabled";
   }
   else if(!governanceAllowsAI)
   {
      reasonCode = "runtime_governance_disallows_ai";
      nextBlocker = "runtime_governance_not_ready";
   }
   // [DORMANT_GATE: AI_ADVISORY_SECURITY_CLEARANCE] flag=false; Phase 6 reserved for activation; enables AI_ADVISORY_ONLY mode from AI_SHADOW_ONLY; registered in runtime_honesty_surfaces.mqh as of Phase 4-A
   else if(!securityAdvisory)
   {
      authorityState = "AI_SHADOW_ONLY";
      readinessState = "SHADOW_READY";
      reasonCode = "shadow_ready_advisory_security_clearance_not_enabled";
      nextBlocker = "advisory_security_clearance_not_enabled";
   }
   else
   {
      authorityState = "AI_ADVISORY_ONLY";
      readinessState = "ADVISORY_READY";
      reasonCode = "advisory_ready";
      nextBlocker = "none";
   }

   if(authorityState == "AI_OFF")
   {
      ApplyAIAuthorityReadinessState(
         st,
         "AI_OFF",
         "NOT_READY",
         aiEnabled,
         aiBridgeReady,
         truthReady,
         diagnosticsReady,
         replayReady,
         validationReady,
         safetyReady,
         sampleReady,
         securityShadow,
         securityAdvisory,
         governanceAllowsAI,
         reasonCode,
         nextBlocker,
         activePlanId,
         activeMode,
         sampleDecisions,
         sampleTradeOpens,
         sampleClosedOutcomes
      );
      return;
   }

   ApplyAIAuthorityReadinessState(
      st,
      authorityState,
      readinessState,
      aiEnabled,
      aiBridgeReady,
      truthReady,
      diagnosticsReady,
      replayReady,
      validationReady,
      safetyReady,
      sampleReady,
      securityShadow,
      securityAdvisory,
      governanceAllowsAI,
      reasonCode,
      nextBlocker,
      activePlanId,
      activeMode,
      sampleDecisions,
      sampleTradeOpens,
      sampleClosedOutcomes
   );
}

string BuildAIActivationReadinessStatusText(const AIAuthorityReadinessState &st)
{
   string s = "";
   s += "ai_activation_readiness_status\n";
   s += "artifact_role=" + st.artifact_role + "\n";
   s += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   s += "summary_version=" + st.summary_version + "\n";
   s += "trust_rule=" + st.trust_rule + "\n";
   s += "status_origin=" + st.status_origin + "\n";
   s += "authority_state=" + st.authority_state + "\n";
   s += "readiness_state=" + st.readiness_state + "\n";
   s += "ai_enabled=" + DiagnosticBoolText(st.ai_enabled) + "\n";
   s += "ai_bridge_ready=" + DiagnosticBoolText(st.ai_bridge_ready) + "\n";
   s += "truth_ready=" + DiagnosticBoolText(st.truth_ready) + "\n";
   s += "diagnostics_ready=" + DiagnosticBoolText(st.diagnostics_ready) + "\n";
   s += "replay_ready=" + DiagnosticBoolText(st.replay_ready) + "\n";
   s += "validation_ready=" + DiagnosticBoolText(st.validation_ready) + "\n";
   s += "safety_ready=" + DiagnosticBoolText(st.safety_ready) + "\n";
   s += "sample_ready=" + DiagnosticBoolText(st.sample_ready) + "\n";
   s += "security_clearance_for_shadow=" + DiagnosticBoolText(st.security_clearance_for_shadow) + "\n";
   s += "security_clearance_for_advisory=" + DiagnosticBoolText(st.security_clearance_for_advisory) + "\n";
   s += "runtime_governance_allows_ai=" + DiagnosticBoolText(st.runtime_governance_allows_ai) + "\n";
   s += "readiness_reason_code=" + st.readiness_reason_code + "\n";
   s += "next_upgrade_blocker=" + st.next_upgrade_blocker + "\n";
   s += "allowed_task_families=" + st.allowed_task_families + "\n";
   s += "allowed_input_classes=" + st.allowed_input_classes + "\n";
   s += "allowed_output_classes=" + st.allowed_output_classes + "\n";
   s += "forbidden_surface_classes=" + st.forbidden_surface_classes + "\n";
   s += "learning_governance_role=" + st.learning_governance_role + "\n";
   s += "council_advisory_role=" + st.council_advisory_role + "\n";
   s += "council_advisory_reserved_future_state=" + st.council_advisory_reserved_future_state + "\n";
   s += "council_advisory_allowed_outputs=" + st.council_advisory_allowed_outputs + "\n";
   s += "council_advisory_forbidden_outputs=" + st.council_advisory_forbidden_outputs + "\n";
   s += "trigger_mode=" + st.trigger_mode + "\n";
   s += "cost_control_mode=" + st.cost_control_mode + "\n";
   s += "dedupe_mode=" + st.dedupe_mode + "\n";
   s += "deep_investigation_mode=" + st.deep_investigation_mode + "\n";
   s += "AIHourlyRunCap=" + IntegerToString(st.effective_hourly_run_cap) + "\n";
   s += "AIDeepInvestigationDailyCap=" + IntegerToString(st.effective_deep_investigation_daily_cap) + "\n";
   s += "AITriggerCooldownMinutes=" + IntegerToString(st.effective_trigger_cooldown_minutes) + "\n";
   s += "effective_min_decisions=" + IntegerToString(st.effective_min_decisions) + "\n";
   s += "effective_min_trade_opens=" + IntegerToString(st.effective_min_trade_opens) + "\n";
   s += "effective_min_closed_outcomes=" + IntegerToString(st.effective_min_closed_outcomes) + "\n";
   s += "sample_decisions=" + IntegerToString(st.sample_decisions) + "\n";
   s += "sample_trade_opens=" + IntegerToString(st.sample_trade_opens) + "\n";
   s += "sample_closed_outcomes=" + IntegerToString(st.sample_closed_outcomes) + "\n";
   s += "direct_control_allowed=" + DiagnosticBoolText(st.direct_control_allowed) + "\n";
   s += "auto_apply_allowed=" + DiagnosticBoolText(st.auto_apply_allowed) + "\n";
   s += "directional_trade_generation_allowed=" + DiagnosticBoolText(st.directional_trade_generation_allowed) + "\n";
   s += "direct_candidate_veto_active=" + DiagnosticBoolText(st.direct_candidate_veto_active) + "\n";
   s += "review_surface_state=" + st.review_surface_state + "\n";
   s += "review_surface_present=" + DiagnosticBoolText(st.review_surface_present) + "\n";
   s += "review_surface_independent_of_authority=" + DiagnosticBoolText(st.review_surface_independent_of_authority) + "\n";
   s += "review_surface_implies_authority_ready=" + DiagnosticBoolText(st.review_surface_implies_authority_ready) + "\n";
   s += "readiness_review_consistency_state=" + st.readiness_review_consistency_state + "\n";
   s += "readiness_review_note=" + st.readiness_review_note + "\n";
   s += "active_plan_id=" + st.active_plan_id + "\n";
   s += "active_mode=" + st.active_mode + "\n";
   s += "last_state_change=" + DiagnosticTimeText(st.last_state_change) + "\n";
   s += "evaluated_at=" + DiagnosticTimeText(st.evaluated_at) + "\n";
   return s;
}

string BuildAIActivationReadinessStatusJson(const AIAuthorityReadinessState &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscape(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscape(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscape(st.summary_version) + "\"";
   j += ",\"trust_rule\":\"" + JsonEscape(st.trust_rule) + "\"";
   j += ",\"status_origin\":\"" + JsonEscape(st.status_origin) + "\"";
   j += ",\"authority_state\":\"" + JsonEscape(st.authority_state) + "\"";
   j += ",\"readiness_state\":\"" + JsonEscape(st.readiness_state) + "\"";
   j += ",\"ai_enabled\":" + string(st.ai_enabled ? "true" : "false");
   j += ",\"ai_bridge_ready\":" + string(st.ai_bridge_ready ? "true" : "false");
   j += ",\"truth_ready\":" + string(st.truth_ready ? "true" : "false");
   j += ",\"diagnostics_ready\":" + string(st.diagnostics_ready ? "true" : "false");
   j += ",\"replay_ready\":" + string(st.replay_ready ? "true" : "false");
   j += ",\"validation_ready\":" + string(st.validation_ready ? "true" : "false");
   j += ",\"safety_ready\":" + string(st.safety_ready ? "true" : "false");
   j += ",\"sample_ready\":" + string(st.sample_ready ? "true" : "false");
   j += ",\"security_clearance_for_shadow\":" + string(st.security_clearance_for_shadow ? "true" : "false");
   j += ",\"security_clearance_for_advisory\":" + string(st.security_clearance_for_advisory ? "true" : "false");
   j += ",\"runtime_governance_allows_ai\":" + string(st.runtime_governance_allows_ai ? "true" : "false");
   j += ",\"readiness_reason_code\":\"" + JsonEscape(st.readiness_reason_code) + "\"";
   j += ",\"next_upgrade_blocker\":\"" + JsonEscape(st.next_upgrade_blocker) + "\"";
   j += ",\"allowed_task_families\":\"" + JsonEscape(st.allowed_task_families) + "\"";
   j += ",\"allowed_input_classes\":\"" + JsonEscape(st.allowed_input_classes) + "\"";
   j += ",\"allowed_output_classes\":\"" + JsonEscape(st.allowed_output_classes) + "\"";
   j += ",\"forbidden_surface_classes\":\"" + JsonEscape(st.forbidden_surface_classes) + "\"";
   j += ",\"learning_governance_role\":\"" + JsonEscape(st.learning_governance_role) + "\"";
   j += ",\"council_advisory_role\":\"" + JsonEscape(st.council_advisory_role) + "\"";
   j += ",\"council_advisory_reserved_future_state\":\"" + JsonEscape(st.council_advisory_reserved_future_state) + "\"";
   j += ",\"council_advisory_allowed_outputs\":\"" + JsonEscape(st.council_advisory_allowed_outputs) + "\"";
   j += ",\"council_advisory_forbidden_outputs\":\"" + JsonEscape(st.council_advisory_forbidden_outputs) + "\"";
   j += ",\"trigger_mode\":\"" + JsonEscape(st.trigger_mode) + "\"";
   j += ",\"cost_control_mode\":\"" + JsonEscape(st.cost_control_mode) + "\"";
   j += ",\"dedupe_mode\":\"" + JsonEscape(st.dedupe_mode) + "\"";
   j += ",\"deep_investigation_mode\":\"" + JsonEscape(st.deep_investigation_mode) + "\"";
   j += ",\"AIHourlyRunCap\":" + IntegerToString(st.effective_hourly_run_cap);
   j += ",\"AIDeepInvestigationDailyCap\":" + IntegerToString(st.effective_deep_investigation_daily_cap);
   j += ",\"AITriggerCooldownMinutes\":" + IntegerToString(st.effective_trigger_cooldown_minutes);
   j += ",\"effective_min_decisions\":" + IntegerToString(st.effective_min_decisions);
   j += ",\"effective_min_trade_opens\":" + IntegerToString(st.effective_min_trade_opens);
   j += ",\"effective_min_closed_outcomes\":" + IntegerToString(st.effective_min_closed_outcomes);
   j += ",\"sample_decisions\":" + IntegerToString(st.sample_decisions);
   j += ",\"sample_trade_opens\":" + IntegerToString(st.sample_trade_opens);
   j += ",\"sample_closed_outcomes\":" + IntegerToString(st.sample_closed_outcomes);
   j += ",\"direct_control_allowed\":" + string(st.direct_control_allowed ? "true" : "false");
   j += ",\"auto_apply_allowed\":" + string(st.auto_apply_allowed ? "true" : "false");
   j += ",\"directional_trade_generation_allowed\":" + string(st.directional_trade_generation_allowed ? "true" : "false");
   j += ",\"direct_candidate_veto_active\":" + string(st.direct_candidate_veto_active ? "true" : "false");
   j += ",\"review_surface_state\":\"" + JsonEscape(st.review_surface_state) + "\"";
   j += ",\"review_surface_present\":" + string(st.review_surface_present ? "true" : "false");
   j += ",\"review_surface_independent_of_authority\":" + string(st.review_surface_independent_of_authority ? "true" : "false");
   j += ",\"review_surface_implies_authority_ready\":" + string(st.review_surface_implies_authority_ready ? "true" : "false");
   j += ",\"readiness_review_consistency_state\":\"" + JsonEscape(st.readiness_review_consistency_state) + "\"";
   j += ",\"readiness_review_note\":\"" + JsonEscape(st.readiness_review_note) + "\"";
   j += ",\"active_plan_id\":\"" + JsonEscape(st.active_plan_id) + "\"";
   j += ",\"active_mode\":\"" + JsonEscape(st.active_mode) + "\"";
   j += ",\"last_state_change\":\"" + JsonEscape(DiagnosticTimeText(st.last_state_change)) + "\"";
   j += ",\"evaluated_at\":\"" + JsonEscape(DiagnosticTimeText(st.evaluated_at)) + "\"";
   j += "}";
   return j;
}

void SaveAIActivationReadinessStatusBestEffort(const AIAuthorityReadinessState &st)
{
   WriteTextFileAll(AIActivationReadinessStatusTxtPath(), BuildAIActivationReadinessStatusText(st));
   WriteTextFileAll(AIActivationReadinessStatusJsonPath(), BuildAIActivationReadinessStatusJson(st));
}

void RefreshAIActivationReadinessStatusBestEffort()
{
   EvaluateAIAuthorityReadinessState(gAIAuthorityReadiness);
   SaveAIActivationReadinessStatusBestEffort(gAIAuthorityReadiness);
}

void OperationalIntegrityInitDomain(OperationalIntegrityDomainState &domain, const string domainId, const string owner)
{
   domain.domain_id = domainId;
   domain.state = "PARTIAL";
   domain.issue_class = "placeholder-related";
   domain.owner = owner;
   domain.reason = "runtime_evaluation_pending";
   domain.last_checked = TimeCurrent();
}

void OperationalIntegritySetDomain(OperationalIntegrityDomainState &domain,
                                   const string stateValue,
                                   const string issueClass,
                                   const string reasonValue)
{
   domain.state = stateValue;
   domain.issue_class = issueClass;
   domain.reason = reasonValue;
   domain.last_checked = TimeCurrent();
}

datetime OperationalIntegrityExtractTimestamp(const string jsonText)
{
   string rawValue = "";
   string keys[8] =
   {
      "evaluated_at",
      "rebuilt_at",
      "last_state_change",
      "last_updated",
      "last_refresh_time",
      "last_review_time",
      "event_time",
      "last_checked"
   };

   for(int i = 0; i < 8; i++)
   {
      if(!ExtractJsonStringField(jsonText, keys[i], rawValue))
         continue;

      string normalized = rawValue;
      StringReplace(normalized, "T", " ");
      StringReplace(normalized, "Z", "");
      StringReplace(normalized, "-", ".");
      if(StringLen(normalized) >= 19)
         normalized = StringSubstr(normalized, 0, 19);
      return StringToTime(normalized);
   }

   return 0;
}

struct OperationalFreshnessSurfaceState
{
   string   surface_name;
   string   state;
   string   reason;
   datetime observed_time;
};

string OperationalIntegrityNormalizeFreshnessState(const string state)
{
   if(state == "MISSING")
      return "CRITICAL_STALE";
   return state;
}

int OperationalIntegrityFreshnessRank(const string state)
{
   string normalized = OperationalIntegrityNormalizeFreshnessState(state);
   if(normalized == "FRESH")
      return 0;
   if(normalized == "PARTIAL_STALE")
      return 1;
   return 2;
}

void OperationalIntegrityEvaluateFreshnessSurface(OperationalFreshnessSurfaceState &out_state,
                                                  const string surface_name,
                                                  const bool surface_present,
                                                  const string jsonText,
                                                  const int partial_age_seconds,
                                                  const int critical_age_seconds)
{
   out_state.surface_name = surface_name;
   out_state.observed_time = OperationalIntegrityExtractTimestamp(jsonText);

   if(!surface_present)
   {
      out_state.state = "MISSING";
      out_state.reason = surface_name + "_missing";
      return;
   }

   if(StringFind(jsonText, "PACKAGE_PLACEHOLDER_PENDING_") >= 0)
   {
      out_state.state = "CRITICAL_STALE";
      out_state.reason = surface_name + "_placeholder_persisted";
      return;
   }

   if(out_state.observed_time <= 0)
   {
      out_state.state = "PARTIAL_STALE";
      out_state.reason = surface_name + "_timestamp_unavailable";
      return;
   }

   int age_seconds = (int)(TimeCurrent() - out_state.observed_time);
   if(age_seconds > critical_age_seconds)
   {
      out_state.state = "CRITICAL_STALE";
      out_state.reason = surface_name + "_critical_stale";
   }
   else if(age_seconds > partial_age_seconds)
   {
      out_state.state = "PARTIAL_STALE";
      out_state.reason = surface_name + "_partial_stale";
   }
   else
   {
      out_state.state = "FRESH";
      out_state.reason = surface_name + "_fresh";
   }
}

void OperationalIntegrityAppendFreshnessDescriptor(string &csv,
                                                   const string surface_name,
                                                   const string surface_state)
{
   if(StringLen(csv) > 0)
      csv += ",";
   csv += surface_name + ":" + OperationalIntegrityNormalizeFreshnessState(surface_state);
}

bool OperationalIntegritySurfaceIsStale(const string jsonText, const int maxAgeSeconds)
{
   datetime ts = OperationalIntegrityExtractTimestamp(jsonText);
   if(ts <= 0)
      return false;

   return ((TimeCurrent() - ts) > maxAgeSeconds);
}

long OperationalIntegrityFileByteSize(const string rel_path)
{
   int h = FileOpen(rel_path, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return -1;

   long size = (long)FileSize(h);
   FileClose(h);
   return size;
}

string OperationalIntegrityWorstState(const string a, const string b)
{
   int ra = 0;
   int rb = 0;

   if(a == "COHERENT") ra = 0;
   else if(a == "PARTIAL") ra = 1;
   else if(a == "DEGRADED") ra = 2;
   else if(a == "BROKEN") ra = 3;

   if(b == "COHERENT") rb = 0;
   else if(b == "PARTIAL") rb = 1;
   else if(b == "DEGRADED") rb = 2;
   else if(b == "BROKEN") rb = 3;

   return (rb > ra ? b : a);
}

string OperationalIntegrityReasonForWorstDomain(const OperationalIntegrityStatus &st)
{
   string overall = st.overall_state;

   OperationalIntegrityDomainState domains[7];
   domains[0] = st.runtime_integrity;
   domains[1] = st.execution_authority_integrity;
   domains[2] = st.dashboard_integrity;
   domains[3] = st.factory_integrity;
   domains[4] = st.ai_oversight_integrity;
   domains[5] = st.journaling_integrity;
   domains[6] = st.risk_safety_integrity;

   for(int i = 0; i < 7; i++)
   {
      if(domains[i].state == overall)
         return domains[i].domain_id + ":" + domains[i].reason;
   }

   return "operational_integrity_runtime_checked";
}

void InitOperationalIntegrityStatus(OperationalIntegrityStatus &st)
{
   st.artifact_role = "OPERATIONAL_INTEGRITY_STATUS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_RUNTIME_COHERENCE_STATUS";
   st.summary_version = "O5O6_OPERATIONAL_INTEGRITY_V2";
   st.status_origin = "RUNTIME_EMITTED_OPERATIONAL_INTEGRITY";
   st.overall_state = "PARTIAL";
   st.overall_reason = "runtime_evaluation_pending";
   st.ai_readiness_review_consistency_state = "PENDING";
   st.ai_readiness_review_consistency_reason = "runtime_evaluation_pending";
   st.freshness_gate_state = "FRESH";
   st.stale_critical_surface_count = 0;
   st.stale_critical_surfaces = "";
   st.dominant_stale_surface = "";
   st.dominant_stale_reason = "";
   st.last_freshness_check_time = TimeCurrent();
   st.last_checked = TimeCurrent();

   OperationalIntegrityInitDomain(st.runtime_integrity, "Runtime Integrity", "runtime_governance_status");
   OperationalIntegrityInitDomain(st.execution_authority_integrity, "Execution Authority Integrity", "runtime_governance_status");
   OperationalIntegrityInitDomain(st.dashboard_integrity, "Dashboard Integrity", "dashboard_phase1_runtime");
   OperationalIntegrityInitDomain(st.factory_integrity, "Factory Integrity", "edge_factory_manifest");
   OperationalIntegrityInitDomain(st.ai_oversight_integrity, "AI Oversight Integrity", "ai_activation_readiness_status");
   OperationalIntegrityInitDomain(st.journaling_integrity, "Journaling Integrity", "ai_performance_journal.jsonl");
   OperationalIntegrityInitDomain(st.risk_safety_integrity, "Risk / Safety Integrity", "risk_safety_status");
}

void EvaluateOperationalIntegrityStatus(OperationalIntegrityStatus &st)
{
   if(!gOperationalIntegrityInitialized)
      InitOperationalIntegrityStatus(st);

   InitOperationalIntegrityStatus(st);
   st.last_checked = TimeCurrent();
   st.last_freshness_check_time = st.last_checked;

   string runtimeJson = "";
   bool runtimePresent = ReadTextFileAll(RuntimeGovernanceStatusJsonPath(), runtimeJson);
   if(!runtimePresent)
   {
      OperationalIntegritySetDomain(st.runtime_integrity, "BROKEN", "missing-surface-related", "runtime_governance_status_missing");
   }
   else if(StringFind(runtimeJson, "PACKAGE_PLACEHOLDER_PENDING_") >= 0)
   {
      OperationalIntegritySetDomain(st.runtime_integrity, "DEGRADED", "placeholder-related", "runtime_governance_placeholder_persisted");
   }
   else if(OperationalIntegritySurfaceIsStale(runtimeJson, 600))
   {
      OperationalIntegritySetDomain(st.runtime_integrity, "PARTIAL", "stale-related", "runtime_governance_status_stale");
   }
   else if(gRuntimeGovernance.governance_state == "STARTUP_INIT")
   {
      OperationalIntegritySetDomain(st.runtime_integrity, "PARTIAL", "placeholder-related", "startup_state_incomplete");
   }
   else if(!gRuntimeGovernance.truth_ready)
   {
      OperationalIntegritySetDomain(st.runtime_integrity, "PARTIAL", "true-runtime-failure", gRuntimeGovernance.reason_code);
   }
   else
   {
      OperationalIntegritySetDomain(st.runtime_integrity, "COHERENT", "none", "runtime_governance_runtime_emitted");
   }

   string authorityJson = "";
   bool authorityPresent = ReadTextFileAll(ExecutionAuthorityStatusJsonPath(), authorityJson);
   if(!authorityPresent)
   {
      OperationalIntegritySetDomain(st.execution_authority_integrity, "BROKEN", "missing-surface-related", "execution_authority_status_missing");
   }
   else if(StringFind(authorityJson, "\"execution_authority_cutover_state\":\"CUTOVER_ACTIVE\"") < 0)
   {
      OperationalIntegritySetDomain(st.execution_authority_integrity, "DEGRADED", "placeholder-related", "execution_authority_cutover_not_active");
   }
   else if(StringFind(authorityJson, "\"legacy_identity_execution_authority_active\":true") >= 0)
   {
      OperationalIntegritySetDomain(st.execution_authority_integrity, "BROKEN", "true-runtime-failure", "legacy_identity_execution_authority_not_retired");
   }
   else if(StringFind(authorityJson, "\"factory_governed_execution_authority_active\":true") >= 0 &&
           StringFind(authorityJson, "\"active_operating_cohort_defined\":true") < 0)
   {
      OperationalIntegritySetDomain(st.execution_authority_integrity, "PARTIAL", "missing-surface-related", "active_operating_cohort_not_defined");
   }
   else if(OperationalIntegritySurfaceIsStale(authorityJson, 600))
   {
      OperationalIntegritySetDomain(st.execution_authority_integrity, "PARTIAL", "stale-related", "execution_authority_status_stale");
   }
   else
   {
      OperationalIntegritySetDomain(st.execution_authority_integrity, "COHERENT", "none", "cohort_governed_execution_authority_connected");
   }

   bool dashboardStatePresent = FileIsExist("AI\\dashboard_phase0_status.json");
   bool dashboardUiPresent = FileIsExist("AI\\dashboard_local_ui_state.json");
   bool eventSurfacePresent = FileIsExist(LastMeaningfulRuntimeEventJsonPath());
   bool factoryLoopPresent = FileIsExist(FactoryOperationalEvidenceJsonPath());
   bool aiLoopPresent = FileIsExist(AIOperationalReviewJsonPath());
   if(g_dashboard_phase1_active && dashboardStatePresent && eventSurfacePresent && factoryLoopPresent && aiLoopPresent)
      OperationalIntegritySetDomain(st.dashboard_integrity, "COHERENT", "none", "dashboard_phase1_operating_picture_connected");
   else if(dashboardStatePresent || dashboardUiPresent || eventSurfacePresent || factoryLoopPresent || aiLoopPresent)
      OperationalIntegritySetDomain(st.dashboard_integrity, "PARTIAL", "missing-surface-related", "dashboard_operating_picture_partial");
   else
      OperationalIntegritySetDomain(st.dashboard_integrity, "BROKEN", "missing-surface-related", "dashboard_surfaces_missing");

   bool factoryManifestPresent = FileIsExist("AI\\edge_factory\\edge_factory_manifest.json");
   bool materialRegistryPresent = FileIsExist("AI\\edge_factory\\registry\\material_registry.json");
   bool gatewayStatusPresent = FileIsExist("AI\\edge_factory\\registry\\source_intake_gateway_status.json");
   string factoryOperationalEvidenceJson = "";
   bool factoryOperationalEvidencePresent = ReadTextFileAll(FactoryOperationalEvidenceJsonPath(), factoryOperationalEvidenceJson);
   if(factoryManifestPresent && materialRegistryPresent && gatewayStatusPresent && factoryOperationalEvidencePresent &&
      StringFind(factoryOperationalEvidenceJson, "\"factory_classification_mutation_allowed\":true") < 0)
      OperationalIntegritySetDomain(st.factory_integrity, "COHERENT", "none", "factory_operational_evidence_connected");
   else if(factoryManifestPresent || materialRegistryPresent || factoryOperationalEvidencePresent)
      OperationalIntegritySetDomain(st.factory_integrity, "PARTIAL", "missing-surface-related", "factory_operational_evidence_partial");
   else
      OperationalIntegritySetDomain(st.factory_integrity, "BROKEN", "missing-surface-related", "factory_structural_surfaces_missing");

   string aiJson = "";
   bool aiPresent = ReadTextFileAll(AIActivationReadinessStatusJsonPath(), aiJson);
   string aiOperationalReviewJson = "";
   bool aiOperationalReviewPresent = ReadTextFileAll(AIOperationalReviewJsonPath(), aiOperationalReviewJson);

   string readinessConsistencyState = "";
   string readinessConsistencyNote = "";
   string readinessReviewState = "";
   bool readinessReviewIndependent = false;
   bool readinessReviewImpliesAuthority = false;
   ExtractJsonStringField(aiJson, "readiness_review_consistency_state", readinessConsistencyState);
   ExtractJsonStringField(aiJson, "readiness_review_note", readinessConsistencyNote);
   ExtractJsonStringField(aiJson, "review_surface_state", readinessReviewState);
   ExtractJsonBoolField(aiJson, "review_surface_independent_of_authority", readinessReviewIndependent);
   ExtractJsonBoolField(aiJson, "review_surface_implies_authority_ready", readinessReviewImpliesAuthority);

   if(!aiPresent)
   {
      st.ai_readiness_review_consistency_state = "BROKEN";
      st.ai_readiness_review_consistency_reason = "ai_activation_readiness_status_missing";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "BROKEN", "missing-surface-related", "ai_activation_readiness_status_missing");
   }
   else if(StringFind(aiJson, "PACKAGE_PLACEHOLDER_PENDING_") >= 0)
   {
      st.ai_readiness_review_consistency_state = "DEGRADED";
      st.ai_readiness_review_consistency_reason = "ai_activation_placeholder_persisted";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "DEGRADED", "placeholder-related", "ai_activation_placeholder_persisted");
   }
   else if(OperationalIntegritySurfaceIsStale(aiJson, 600))
   {
      st.ai_readiness_review_consistency_state = "PARTIAL";
      st.ai_readiness_review_consistency_reason = "ai_activation_readiness_status_stale";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "PARTIAL", "stale-related", "ai_activation_readiness_status_stale");
   }
   else if(gAIAuthorityReadiness.direct_control_allowed || gAIAuthorityReadiness.auto_apply_allowed || gAIAuthorityReadiness.directional_trade_generation_allowed)
   {
      st.ai_readiness_review_consistency_state = "BROKEN";
      st.ai_readiness_review_consistency_reason = "ai_authority_boundary_broken";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "BROKEN", "true-runtime-failure", "ai_authority_boundary_broken");
   }
   else if(!aiOperationalReviewPresent)
   {
      if(gAIAuthorityReadiness.readiness_review_consistency_state == "CONSISTENT_NO_REVIEW_SURFACE" ||
         readinessConsistencyState == "CONSISTENT_NO_REVIEW_SURFACE")
      {
         st.ai_readiness_review_consistency_state = "CONSISTENT";
         st.ai_readiness_review_consistency_reason = "readiness_without_review_surface_is_explicit";
         OperationalIntegritySetDomain(st.ai_oversight_integrity, "PARTIAL", "missing-surface-related", "ai_operational_review_status_missing");
      }
      else
      {
         st.ai_readiness_review_consistency_state = "PARTIAL";
         st.ai_readiness_review_consistency_reason = "ai_operational_review_status_missing";
         OperationalIntegritySetDomain(st.ai_oversight_integrity, "PARTIAL", "missing-surface-related", "ai_operational_review_status_missing");
      }
   }
   else if(StringFind(aiOperationalReviewJson, "\"execution_authority_granted\":true") >= 0 ||
           StringFind(aiOperationalReviewJson, "\"trade_generation_authority\":true") >= 0 ||
           StringFind(aiOperationalReviewJson, "\"runtime_mutation_allowed\":true") >= 0 ||
           StringFind(aiOperationalReviewJson, "\"review_implies_authority_ready\":true") >= 0)
   {
      st.ai_readiness_review_consistency_state = "BROKEN";
      st.ai_readiness_review_consistency_reason = "ai_operational_review_authority_boundary_broken";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "BROKEN", "true-runtime-failure", "ai_operational_review_authority_boundary_broken");
   }
   else if((gAIAuthorityReadiness.readiness_review_consistency_state == "CONSISTENT_SHADOW_REVIEW_ONLY" ||
            readinessConsistencyState == "CONSISTENT_SHADOW_REVIEW_ONLY") &&
           (gAIAuthorityReadiness.authority_state == "AI_OFF" || StringFind(aiJson, "\"authority_state\":\"AI_OFF\"") >= 0) &&
           (gAIAuthorityReadiness.readiness_state == "NOT_READY" || StringFind(aiJson, "\"readiness_state\":\"NOT_READY\"") >= 0) &&
           (gAIAuthorityReadiness.review_surface_independent_of_authority || readinessReviewIndependent) &&
           !(gAIAuthorityReadiness.review_surface_implies_authority_ready || readinessReviewImpliesAuthority))
   {
      st.ai_readiness_review_consistency_state = "CONSISTENT";
      st.ai_readiness_review_consistency_reason = "ai_review_present_authority_off_consistent";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "COHERENT", "none", "ai_review_present_authority_off_consistent");
   }
   else
   {
      st.ai_readiness_review_consistency_state = "PARTIAL";
      if(StringLen(TrimString(readinessConsistencyNote)) > 0)
         st.ai_readiness_review_consistency_reason = readinessConsistencyNote;
      else
         st.ai_readiness_review_consistency_reason = "ai_readiness_review_alignment_unclear";
      OperationalIntegritySetDomain(st.ai_oversight_integrity, "PARTIAL", "consistency-related", "ai_readiness_review_alignment_unclear");
   }

   bool journalPresent = FileIsExist(PERF_JOURNAL_PATH);
   string validationJson = "";
   bool validationPresent = ReadTextFileAll(ExecutionQualityValidationJsonPath(), validationJson);
   string eventJson = "";
   bool eventPresentForJournal = ReadTextFileAll(LastMeaningfulRuntimeEventJsonPath(), eventJson);
   string factoryOperationalEvidenceJson2 = "";
   bool factoryEvidencePresentForJournal = ReadTextFileAll(FactoryOperationalEvidenceJsonPath(), factoryOperationalEvidenceJson2);
   if(!journalPresent)
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "BROKEN", "missing-surface-related", "performance_journal_missing");
   }
   else if(!validationPresent)
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "PARTIAL", "missing-surface-related", "execution_quality_validation_missing");
   }
   else if(!eventPresentForJournal)
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "PARTIAL", "missing-surface-related", "last_meaningful_runtime_event_missing");
   }
   else if(!factoryEvidencePresentForJournal)
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "PARTIAL", "missing-surface-related", "factory_operational_evidence_missing");
   }
   else if(OperationalIntegritySurfaceIsStale(validationJson, 1800))
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "PARTIAL", "stale-related", "execution_quality_validation_stale");
   }
   else if(OperationalIntegrityFileByteSize(PERF_JOURNAL_PATH) <= 0)
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "PARTIAL", "missing-surface-related", "performance_journal_present_but_empty");
   }
   else
   {
      OperationalIntegritySetDomain(st.journaling_integrity, "COHERENT", "none", "journaling_trade_stats_and_event_surfaces_present");
   }

   string riskJson = "";
   bool riskPresent = ReadTextFileAll(RiskSafetyStatusJsonPath(), riskJson);
   string envelopeJson = "";
   bool envelopePresent = ReadTextFileAll(OperatingRiskEnvelopeStatusJsonPath(), envelopeJson);
   if(!riskPresent)
   {
      OperationalIntegritySetDomain(st.risk_safety_integrity, "BROKEN", "missing-surface-related", "risk_safety_status_missing");
   }
   else if(!envelopePresent)
   {
      OperationalIntegritySetDomain(st.risk_safety_integrity, "PARTIAL", "missing-surface-related", "operating_risk_envelope_status_missing");
   }
   else if(StringFind(riskJson, "PACKAGE_PLACEHOLDER_PENDING_") >= 0)
   {
      OperationalIntegritySetDomain(st.risk_safety_integrity, "DEGRADED", "placeholder-related", "risk_safety_placeholder_persisted");
   }
   else if(OperationalIntegritySurfaceIsStale(riskJson, 600) || OperationalIntegritySurfaceIsStale(envelopeJson, 600))
   {
      OperationalIntegritySetDomain(st.risk_safety_integrity, "PARTIAL", "stale-related", "risk_safety_or_envelope_status_stale");
   }
   else if(StringFind(envelopeJson, "\"operating_risk_envelope_state\":\"PENDING_RUNTIME_INIT\"") >= 0)
   {
      OperationalIntegritySetDomain(st.risk_safety_integrity, "DEGRADED", "placeholder-related", "operating_risk_envelope_not_runtime_evaluated");
   }
   else
   {
      string riskReason = gRuntimeRiskSafety.safety_reason_code;
      if(StringLen(TrimString(gOperatingRiskEnvelope.current_block_reason_code)) > 0)
         riskReason = gOperatingRiskEnvelope.current_block_reason_code;
      OperationalIntegritySetDomain(st.risk_safety_integrity, "COHERENT", "none", riskReason);
   }

   OperationalFreshnessSurfaceState freshness[9];
   OperationalIntegrityEvaluateFreshnessSurface(freshness[0], "runtime_governance_status", runtimePresent, runtimeJson, 600, 1800);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[1], "execution_authority_status", authorityPresent, authorityJson, 600, 1800);

   string cohortJson = "";
   bool cohortPresent = ReadTextFileAll(ActiveOperatingCohortStatusJsonPath(), cohortJson);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[2], "active_operating_cohort", cohortPresent, cohortJson, 600, 1800);

   OperationalIntegrityEvaluateFreshnessSurface(freshness[3], "operating_risk_envelope_status", envelopePresent, envelopeJson, 600, 1800);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[4], "risk_safety_status", riskPresent, riskJson, 600, 1800);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[5], "last_meaningful_runtime_event", eventPresentForJournal, eventJson, 600, 1800);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[6], "execution_quality_validation", validationPresent, validationJson, 1800, 7200);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[7], "factory_operational_evidence_status", factoryOperationalEvidencePresent, factoryOperationalEvidenceJson, 1800, 7200);
   OperationalIntegrityEvaluateFreshnessSurface(freshness[8], "ai_operational_review_status", aiOperationalReviewPresent, aiOperationalReviewJson, 1800, 7200);

   st.freshness_gate_state = "FRESH";
   st.stale_critical_surface_count = 0;
   st.stale_critical_surfaces = "";
   st.dominant_stale_surface = "";
   st.dominant_stale_reason = "";

   for(int i = 0; i < 9; i++)
   {
      string normalized_state = OperationalIntegrityNormalizeFreshnessState(freshness[i].state);
      if(normalized_state != "FRESH")
      {
         st.stale_critical_surface_count++;
         OperationalIntegrityAppendFreshnessDescriptor(st.stale_critical_surfaces, freshness[i].surface_name, freshness[i].state);
      }

      if(OperationalIntegrityFreshnessRank(normalized_state) > OperationalIntegrityFreshnessRank(st.freshness_gate_state))
      {
         st.freshness_gate_state = normalized_state;
         st.dominant_stale_surface = freshness[i].surface_name;
         st.dominant_stale_reason = freshness[i].reason;
      }
   }

   st.overall_state = "COHERENT";
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.runtime_integrity.state);
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.execution_authority_integrity.state);
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.dashboard_integrity.state);
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.factory_integrity.state);
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.ai_oversight_integrity.state);
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.journaling_integrity.state);
   st.overall_state = OperationalIntegrityWorstState(st.overall_state, st.risk_safety_integrity.state);

   st.overall_reason = OperationalIntegrityReasonForWorstDomain(st);

   if(st.freshness_gate_state == "PARTIAL_STALE" && st.overall_state == "COHERENT")
   {
      st.overall_state = "PARTIAL";
      st.overall_reason = "freshness_gate:" + st.dominant_stale_surface + ":" + st.dominant_stale_reason;
   }
   else if(st.freshness_gate_state == "CRITICAL_STALE" &&
           (st.overall_state == "COHERENT" || st.overall_state == "PARTIAL"))
   {
      st.overall_state = "DEGRADED";
      st.overall_reason = "freshness_gate:" + st.dominant_stale_surface + ":" + st.dominant_stale_reason;
   }

   gOperationalIntegrityInitialized = true;
}

string BuildOperationalIntegrityStatusText(const OperationalIntegrityStatus &st)
{
   string s = "";
   s += "operational_integrity_status\n";
   s += "artifact_role=" + st.artifact_role + "\n";
   s += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   s += "summary_version=" + st.summary_version + "\n";
   s += "status_origin=" + st.status_origin + "\n";
   s += "overall_state=" + st.overall_state + "\n";
   s += "overall_reason=" + st.overall_reason + "\n";
   s += "ai_readiness_review_consistency_state=" + st.ai_readiness_review_consistency_state + "\n";
   s += "ai_readiness_review_consistency_reason=" + st.ai_readiness_review_consistency_reason + "\n";
   s += "freshness_gate_state=" + st.freshness_gate_state + "\n";
   s += "stale_critical_surface_count=" + IntegerToString(st.stale_critical_surface_count) + "\n";
   s += "stale_critical_surfaces=" + st.stale_critical_surfaces + "\n";
   s += "dominant_stale_surface=" + st.dominant_stale_surface + "\n";
   s += "dominant_stale_reason=" + st.dominant_stale_reason + "\n";
   s += "last_freshness_check_time=" + DiagnosticTimeText(st.last_freshness_check_time) + "\n";
   s += "last_checked=" + DiagnosticTimeText(st.last_checked) + "\n";

   OperationalIntegrityDomainState domains[7];
   domains[0] = st.runtime_integrity;
   domains[1] = st.execution_authority_integrity;
   domains[2] = st.dashboard_integrity;
   domains[3] = st.factory_integrity;
   domains[4] = st.ai_oversight_integrity;
   domains[5] = st.journaling_integrity;
   domains[6] = st.risk_safety_integrity;

   string keys[7] =
   {
      "runtime_integrity",
      "execution_authority_integrity",
      "dashboard_integrity",
      "factory_integrity",
      "ai_oversight_integrity",
      "journaling_integrity",
      "risk_safety_integrity"
   };

   for(int i = 0; i < 7; i++)
   {
      s += keys[i] + "_state=" + domains[i].state + "\n";
      s += keys[i] + "_issue_class=" + domains[i].issue_class + "\n";
      s += keys[i] + "_owner=" + domains[i].owner + "\n";
      s += keys[i] + "_reason=" + domains[i].reason + "\n";
      s += keys[i] + "_last_checked=" + DiagnosticTimeText(domains[i].last_checked) + "\n";
   }

   return s;
}

string BuildOperationalIntegrityStatusJson(const OperationalIntegrityStatus &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscape(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscape(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscape(st.summary_version) + "\"";
   j += ",\"status_origin\":\"" + JsonEscape(st.status_origin) + "\"";
   j += ",\"overall_state\":\"" + JsonEscape(st.overall_state) + "\"";
   j += ",\"overall_reason\":\"" + JsonEscape(st.overall_reason) + "\"";
   j += ",\"ai_readiness_review_consistency_state\":\"" + JsonEscape(st.ai_readiness_review_consistency_state) + "\"";
   j += ",\"ai_readiness_review_consistency_reason\":\"" + JsonEscape(st.ai_readiness_review_consistency_reason) + "\"";
   j += ",\"freshness_gate_state\":\"" + JsonEscape(st.freshness_gate_state) + "\"";
   j += ",\"stale_critical_surface_count\":" + IntegerToString(st.stale_critical_surface_count);
   j += ",\"stale_critical_surfaces\":\"" + JsonEscape(st.stale_critical_surfaces) + "\"";
   j += ",\"dominant_stale_surface\":\"" + JsonEscape(st.dominant_stale_surface) + "\"";
   j += ",\"dominant_stale_reason\":\"" + JsonEscape(st.dominant_stale_reason) + "\"";
   j += ",\"last_freshness_check_time\":\"" + JsonEscape(DiagnosticTimeText(st.last_freshness_check_time)) + "\"";
   j += ",\"last_checked\":\"" + JsonEscape(DiagnosticTimeText(st.last_checked)) + "\"";

   OperationalIntegrityDomainState domains[7];
   domains[0] = st.runtime_integrity;
   domains[1] = st.execution_authority_integrity;
   domains[2] = st.dashboard_integrity;
   domains[3] = st.factory_integrity;
   domains[4] = st.ai_oversight_integrity;
   domains[5] = st.journaling_integrity;
   domains[6] = st.risk_safety_integrity;

   string keys[7] =
   {
      "runtime_integrity",
      "execution_authority_integrity",
      "dashboard_integrity",
      "factory_integrity",
      "ai_oversight_integrity",
      "journaling_integrity",
      "risk_safety_integrity"
   };

   for(int i = 0; i < 7; i++)
   {
      j += ",\"" + keys[i] + "_state\":\"" + JsonEscape(domains[i].state) + "\"";
      j += ",\"" + keys[i] + "_issue_class\":\"" + JsonEscape(domains[i].issue_class) + "\"";
      j += ",\"" + keys[i] + "_owner\":\"" + JsonEscape(domains[i].owner) + "\"";
      j += ",\"" + keys[i] + "_reason\":\"" + JsonEscape(domains[i].reason) + "\"";
      j += ",\"" + keys[i] + "_last_checked\":\"" + JsonEscape(DiagnosticTimeText(domains[i].last_checked)) + "\"";
   }

   j += "}";
   return j;
}

void SaveOperationalIntegrityStatusBestEffort(const OperationalIntegrityStatus &st)
{
   WriteTextFileAll(OperationalIntegrityStatusTxtPath(), BuildOperationalIntegrityStatusText(st));
   WriteTextFileAll(OperationalIntegrityStatusJsonPath(), BuildOperationalIntegrityStatusJson(st));
}

void RefreshOperationalIntegrityStatusBestEffort()
{
   EvaluateOperationalIntegrityStatus(gOperationalIntegrity);
   SaveOperationalIntegrityStatusBestEffort(gOperationalIntegrity);
}


bool AIAuthorityAllowsShadow(string &reasonCode)
{
   EvaluateAIAuthorityReadinessState(gAIAuthorityReadiness);
   SaveAIActivationReadinessStatusBestEffort(gAIAuthorityReadiness);
   reasonCode = gAIAuthorityReadiness.readiness_reason_code;
   return (gAIAuthorityReadiness.authority_state == "AI_SHADOW_ONLY" ||
           gAIAuthorityReadiness.authority_state == "AI_ADVISORY_ONLY");
}

bool AIAuthorityAllowsBoundedProposalGeneration(string &reasonCode)
{
   EvaluateAIAuthorityReadinessState(gAIAuthorityReadiness);
   SaveAIActivationReadinessStatusBestEffort(gAIAuthorityReadiness);
   reasonCode = gAIAuthorityReadiness.readiness_reason_code;
   return (gAIAuthorityReadiness.authority_state == "AI_ADVISORY_ONLY");
}


//---------------------------------------------------------
// AI council contextual advisory integration (A6)
//---------------------------------------------------------
string CouncilAIAdvisoryUpper(const string src)
{
   string out = TrimString(src);
   StringToUpper(out);
   return out;
}

string CouncilAIAdvisoryBoolText(bool v)
{
   return (v ? "true" : "false");
}

int AICouncilEffectiveHoldBars()
{
   return (int)MathMax(1, MathMin(3, AICouncilHoldBars));
}

int AICouncilEffectiveHoldLimitPerSignature()
{
   return (int)MathMax(1, MathMin(3, AICouncilMaxHoldsPerSignature));
}

double AICouncilHoldMinConfidenceThreshold()
{
   return 0.75;
}

double AICouncilHoldMinEvidenceStrengthThreshold()
{
   return 0.70;
}

int AICouncilHoldMinCorroborationThreshold()
{
   return 2;
}

double AICandidateEffectiveBlockMinConfidence()
{
   return MathMax(0.0, MathMin(1.0, AICandidateBlockMinConfidence));
}

double AICandidateEffectiveBlockMinEvidenceStrength()
{
   return MathMax(0.0, MathMin(1.0, AICandidateBlockMinEvidenceStrength));
}

int AICandidateEffectiveBlockMinCorroborationCount()
{
   return (int)MathMax(1, MathMin(10, AICandidateBlockMinCorroborationCount));
}

int CouncilAIAdvisorySignatureResetBars()
{
   return (int)MathMax(4, AICouncilEffectiveHoldBars() * 6);
}

string CouncilAIAdvisoryNormalizeState(const string src)
{
   string v = CouncilAIAdvisoryUpper(src);
   if(v == "NO_ADVISORY" ||
      v == "ADVISORY_OK" ||
      v == "ADVISORY_CAUTION" ||
      v == "ADVISORY_STRONG_CAUTION" ||
      v == "ADVISORY_INSUFFICIENT_EVIDENCE" ||
      v == "BLOCK_CANDIDATE_ELIGIBLE")
      return v;
   return "ADVISORY_INSUFFICIENT_EVIDENCE";
}

string CouncilAIAdvisoryNormalizeFreshness(const string src)
{
   string v = CouncilAIAdvisoryUpper(src);
   if(v == "FRESH" || v == "RECENT" || v == "STALE" || v == "UNKNOWN")
      return v;
   return "UNKNOWN";
}

bool CouncilAIAdvisoryFreshEnough(const string freshness)
{
   string v = CouncilAIAdvisoryNormalizeFreshness(freshness);
   return (v == "FRESH" || v == "RECENT");
}

string CouncilAIAdvisoryNormalizeActionClass(const string src)
{
   string v = CouncilAIAdvisoryUpper(src);
   if(v == "NO_ACTION" ||
      v == "DISPLAY_ONLY" ||
      v == "FLAG_FOR_OPERATOR" ||
      v == "HOLD_FOR_REEVALUATION" ||
      v == "BLOCK_CANDIDATE_ELIGIBLE")
      return v;
   return "NO_ACTION";
}

string CouncilAIAdvisoryNormalizeReasonFamily(const string src)
{
   string v = CouncilAIAdvisoryUpper(src);
   if(v == "SEVERE_RECENT_PATTERN_DETERIORATION")
      return v;
   if(v == "HIGH_SIMILAR_CASE_FAILURE_BIAS")
      return v;
   if(v == "EXECUTION_INSTABILITY_CLUSTER")
      return v;
   if(v == "STRATEGY_FAMILY_WEAKENING")
      return v;
   if(v == "ANOMALY_CLUSTER_HIGH_SEVERITY")
      return v;
   return "";
}

bool CouncilAIAdvisoryCsvContains(const string csv, const string token)
{
   string normalizedCsv = "," + CouncilAIAdvisoryUpper(csv) + ",";
   string normalizedToken = "," + CouncilAIAdvisoryUpper(token) + ",";
   return (StringFind(normalizedCsv, normalizedToken) >= 0);
}

void CouncilAIAdvisoryAppendReasonCsv(string &csv, const string reasonFamily)
{
   string normalized = CouncilAIAdvisoryNormalizeReasonFamily(reasonFamily);
   if(StringLen(normalized) <= 0)
      return;
   if(CouncilAIAdvisoryCsvContains(csv, normalized))
      return;
   if(StringLen(TrimString(csv)) > 0)
      csv += ",";
   csv += normalized;
}

string CouncilAIAdvisoryNormalizeReasonFamiliesCsv(const string src)
{
   string out = "";
   string tmp = src;
   string parts[];
   int count = StringSplit(tmp, ',', parts);
   if(count <= 0)
   {
      CouncilAIAdvisoryAppendReasonCsv(out, src);
      return out;
   }

   for(int i = 0; i < count; i++)
      CouncilAIAdvisoryAppendReasonCsv(out, parts[i]);

   return out;
}

string CouncilAIAdvisoryBuildCandidateScope(const RoutedRuntimeEvaluation &routed, const string direction)
{
   string scope = "COUNCIL|" + direction + "|" + gRegime.regime_label;
   if(StringLen(TrimString(routed.council.zone_coverage.zone_semantic)) > 0)
      scope += "|" + routed.council.zone_coverage.zone_semantic;
   if(StringLen(TrimString(routed.council.aggregate.best_strategy_id)) > 0)
      scope += "|" + routed.council.aggregate.best_strategy_id;
   return scope;
}

string CouncilAIAdvisoryBuildCandidateSignature(const RoutedRuntimeEvaluation &routed, const string direction)
{
   string signature = direction + "|" + gRegime.regime_label;
   signature += "|" + routed.council.zone_coverage.zone_semantic;
   signature += "|" + LAB_InferFamilyFromStrategyId(routed.council.aggregate.best_strategy_id);
   signature += "|" + routed.council.aggregate.best_strategy_id;
   return signature;
}

void InitCouncilAIAdvisoryPacket(CouncilAIAdvisoryPacket &p)
{
   p.valid = false;
   p.invocation_state = "NOT_EVALUATED";
   p.invocation_reason_code = "not_evaluated";
   p.advisory_packet_id = "";
   p.advisory_state = "NO_ADVISORY";
   p.advisory_confidence = 0.0;
   p.evidence_strength = 0.0;
   p.corroboration_count = 0;
   p.advisory_reason_codes_csv = "";
   p.rationale_short = "";
   p.candidate_scope = "";
   p.candidate_decision_id = "";
   p.candidate_direction = "";
   p.relevant_zone = "";
   p.relevant_strategy_family = "";
   p.execution_instability_flag = false;
   p.strategy_family_weakening_flag = false;
   p.severe_recent_pattern_deterioration_flag = false;
   p.anomaly_cluster_high_severity_flag = false;
   p.recent_similar_case_failure_bias_flag = false;
   p.advisory_freshness = "UNKNOWN";
   p.evidence_limitations = "";
   p.recommended_action_class = "NO_ACTION";
   p.direct_control_allowed = false;
   p.directional_generation_allowed = false;
   p.reserved_future_state_only = false;
   p.raw_response = "";
   p.evaluated_at = TimeCurrent();
}

void InitCouncilAIAdvisoryRelevanceGateResult(CouncilAIAdvisoryRelevanceGateResult &g)
{
   g.gate_outcome = "IGNORE_ADVISORY";
   g.gate_reason_code = "no_advisory";
   g.strict_reason_families_csv = "";
   g.advisory_considered = false;
   g.operational_influence_allowed = false;
   g.hold_applied = false;
   g.block_applied = false;
   g.block_mode_enabled = false;
   g.strict_conditions_satisfied = false;
   g.effective_hold_bars = AICouncilEffectiveHoldBars();
   g.effective_corroboration_count = 0;
   g.hold_confidence_threshold = AICouncilHoldMinConfidenceThreshold();
   g.hold_evidence_threshold = AICouncilHoldMinEvidenceStrengthThreshold();
   g.hold_corroboration_threshold = AICouncilHoldMinCorroborationThreshold();
   g.block_confidence_threshold = AICandidateEffectiveBlockMinConfidence();
   g.block_evidence_threshold = AICandidateEffectiveBlockMinEvidenceStrength();
   g.block_corroboration_threshold = AICandidateEffectiveBlockMinCorroborationCount();
   g.note = "";
   g.evaluated_at = TimeCurrent();
}

void InitCouncilAIAdvisoryHoldState(CouncilAIAdvisoryHoldState &st)
{
   st.active = false;
   st.candidate_signature = "";
   st.decision_id = "";
   st.direction = "";
   st.advisory_packet_id = "";
   st.hold_reason_code = "";
   st.held_at = 0;
   st.release_bar_index = -100000;
   st.holds_used_for_signature = 0;
   st.signature_anchor_bar_index = -100000;
}

void InitCouncilAIAdvisoryStatus(CouncilAIAdvisoryStatus &st)
{
   st.artifact_role = "COUNCIL_AI_ADVISORY_STATUS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_COUNCIL_AI_ADVISORY";
   st.summary_version = "A6_COUNCIL_AI_ADVISORY_STATUS_V1";
   st.trust_rule = "advisory_integration_only_non_authoritative";
   st.update_source = "PACKAGE_PLACEHOLDER_PENDING_RUNTIME_ADVISORY_INIT";
   st.authority_state = "AI_OFF";
   st.readiness_state = "NOT_READY";
   st.advisory_integration_enabled = EnableAICouncilContextualAdvisory;
   st.advisory_invocation_allowed = false;
   st.operational_influence_allowed = false;
   st.advisory_packet_schema_state = "PACKAGE_PLACEHOLDER_PENDING_RUNTIME_EVALUATION";
   st.advisory_packet_id = "";
   st.advisory_state = "NO_ADVISORY";
   st.advisory_confidence = 0.0;
   st.evidence_strength = 0.0;
   st.corroboration_count = 0;
   st.advisory_reason_codes_csv = "";
   st.rationale_short = "";
   st.candidate_scope = "";
   st.candidate_decision_id = "";
   st.candidate_direction = "";
   st.relevant_zone = "";
   st.relevant_strategy_family = "";
   st.advisory_freshness = "UNKNOWN";
   st.evidence_limitations = "";
   st.recommended_action_class = "NO_ACTION";
   st.execution_instability_flag = false;
   st.strategy_family_weakening_flag = false;
   st.severe_recent_pattern_deterioration_flag = false;
   st.anomaly_cluster_high_severity_flag = false;
   st.recent_similar_case_failure_bias_flag = false;
   st.relevance_gate_outcome = "IGNORE_ADVISORY";
   st.relevance_gate_reason_code = "not_evaluated";
   st.strict_reason_families_csv = "";
   st.hold_applied = false;
   st.block_applied = false;
   st.block_mode_enabled = EnableAICandidateBlock;
   st.effective_hold_bars = AICouncilEffectiveHoldBars();
   st.effective_hold_limit_per_signature = AICouncilEffectiveHoldLimitPerSignature();
   st.effective_hold_confidence_threshold = AICouncilHoldMinConfidenceThreshold();
   st.effective_hold_evidence_threshold = AICouncilHoldMinEvidenceStrengthThreshold();
   st.effective_hold_corroboration_threshold = AICouncilHoldMinCorroborationThreshold();
   st.effective_block_confidence_threshold = AICandidateEffectiveBlockMinConfidence();
   st.effective_block_evidence_threshold = AICandidateEffectiveBlockMinEvidenceStrength();
   st.effective_block_corroboration_threshold = AICandidateEffectiveBlockMinCorroborationCount();
   st.current_hold_active = false;
   st.current_hold_signature = "";
   st.current_hold_release_bar_index = -100000;
   st.current_hold_count_for_signature = 0;
   st.non_authoritative_notice = "derived_non_authoritative_advisory_integration_only";
   st.evaluated_at = TimeCurrent();
}

void InitCouncilAIAdvisoryEffectivenessSummary(CouncilAIAdvisoryEffectivenessSummary &st)
{
   st.artifact_role = "COUNCIL_AI_ADVISORY_EFFECTIVENESS";
   st.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_COUNCIL_AI_ADVISORY_EFFECTIVENESS";
   st.summary_version = "A6_COUNCIL_AI_ADVISORY_EFFECTIVENESS_V1";
   st.review_window_note = "current_runtime_session_best_effort";
   st.note = "best_effort_counters_non_authoritative";
   st.advisory_total = 0;
   st.advisory_ok_total = 0;
   st.advisory_caution_total = 0;
   st.advisory_strong_caution_total = 0;
   st.advisory_insufficient_evidence_total = 0;
   st.advisory_hold_total = 0;
   st.advisory_block_eligible_total = 0;
   st.advisory_block_applied_total = 0;
   st.advisory_block_enabled = EnableAICandidateBlock;
   st.hold_then_trade_total = 0;
   st.hold_then_drop_total = 0;
   st.blocked_loss_prevention_count = 0;
   st.blocked_win_penalty_count = 0;
   st.false_block_risk_unknown = true;
   st.advisory_effectiveness_confidence = "LOW";
   st.rebuilt_at = TimeCurrent();
}

string BuildCouncilAIAdvisoryStatusText(const CouncilAIAdvisoryStatus &st)
{
   string t = "";
   t += "artifact_role=" + st.artifact_role + "\n";
   t += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   t += "summary_version=" + st.summary_version + "\n";
   t += "trust_rule=" + st.trust_rule + "\n";
   t += "update_source=" + st.update_source + "\n";
   t += "authority_state=" + st.authority_state + "\n";
   t += "readiness_state=" + st.readiness_state + "\n";
   t += "advisory_integration_enabled=" + CouncilAIAdvisoryBoolText(st.advisory_integration_enabled) + "\n";
   t += "advisory_invocation_allowed=" + CouncilAIAdvisoryBoolText(st.advisory_invocation_allowed) + "\n";
   t += "operational_influence_allowed=" + CouncilAIAdvisoryBoolText(st.operational_influence_allowed) + "\n";
   t += "advisory_packet_schema_state=" + st.advisory_packet_schema_state + "\n";
   t += "advisory_packet_id=" + st.advisory_packet_id + "\n";
   t += "advisory_state=" + st.advisory_state + "\n";
   t += "advisory_confidence=" + DoubleToString(st.advisory_confidence, 3) + "\n";
   t += "evidence_strength=" + DoubleToString(st.evidence_strength, 3) + "\n";
   t += "corroboration_count=" + IntegerToString(st.corroboration_count) + "\n";
   t += "advisory_reason_codes_csv=" + st.advisory_reason_codes_csv + "\n";
   t += "rationale_short=" + st.rationale_short + "\n";
   t += "candidate_scope=" + st.candidate_scope + "\n";
   t += "candidate_decision_id=" + st.candidate_decision_id + "\n";
   t += "candidate_direction=" + st.candidate_direction + "\n";
   t += "relevant_zone=" + st.relevant_zone + "\n";
   t += "relevant_strategy_family=" + st.relevant_strategy_family + "\n";
   t += "advisory_freshness=" + st.advisory_freshness + "\n";
   t += "evidence_limitations=" + st.evidence_limitations + "\n";
   t += "recommended_action_class=" + st.recommended_action_class + "\n";
   t += "execution_instability_flag=" + CouncilAIAdvisoryBoolText(st.execution_instability_flag) + "\n";
   t += "strategy_family_weakening_flag=" + CouncilAIAdvisoryBoolText(st.strategy_family_weakening_flag) + "\n";
   t += "severe_recent_pattern_deterioration_flag=" + CouncilAIAdvisoryBoolText(st.severe_recent_pattern_deterioration_flag) + "\n";
   t += "anomaly_cluster_high_severity_flag=" + CouncilAIAdvisoryBoolText(st.anomaly_cluster_high_severity_flag) + "\n";
   t += "recent_similar_case_failure_bias_flag=" + CouncilAIAdvisoryBoolText(st.recent_similar_case_failure_bias_flag) + "\n";
   t += "relevance_gate_outcome=" + st.relevance_gate_outcome + "\n";
   t += "relevance_gate_reason_code=" + st.relevance_gate_reason_code + "\n";
   t += "strict_reason_families_csv=" + st.strict_reason_families_csv + "\n";
   t += "hold_applied=" + CouncilAIAdvisoryBoolText(st.hold_applied) + "\n";
   t += "block_applied=" + CouncilAIAdvisoryBoolText(st.block_applied) + "\n";
   t += "block_mode_enabled=" + CouncilAIAdvisoryBoolText(st.block_mode_enabled) + "\n";
   t += "effective_hold_bars=" + IntegerToString(st.effective_hold_bars) + "\n";
   t += "effective_hold_limit_per_signature=" + IntegerToString(st.effective_hold_limit_per_signature) + "\n";
   t += "effective_hold_confidence_threshold=" + DoubleToString(st.effective_hold_confidence_threshold, 3) + "\n";
   t += "effective_hold_evidence_threshold=" + DoubleToString(st.effective_hold_evidence_threshold, 3) + "\n";
   t += "effective_hold_corroboration_threshold=" + IntegerToString(st.effective_hold_corroboration_threshold) + "\n";
   t += "effective_block_confidence_threshold=" + DoubleToString(st.effective_block_confidence_threshold, 3) + "\n";
   t += "effective_block_evidence_threshold=" + DoubleToString(st.effective_block_evidence_threshold, 3) + "\n";
   t += "effective_block_corroboration_threshold=" + IntegerToString(st.effective_block_corroboration_threshold) + "\n";
   t += "current_hold_active=" + CouncilAIAdvisoryBoolText(st.current_hold_active) + "\n";
   t += "current_hold_signature=" + st.current_hold_signature + "\n";
   t += "current_hold_release_bar_index=" + IntegerToString(st.current_hold_release_bar_index) + "\n";
   t += "current_hold_count_for_signature=" + IntegerToString(st.current_hold_count_for_signature) + "\n";
   t += "non_authoritative_notice=" + st.non_authoritative_notice + "\n";
   t += "evaluated_at=" + DiagnosticTimeText(st.evaluated_at) + "\n";
   return t;
}

string BuildCouncilAIAdvisoryStatusJson(const CouncilAIAdvisoryStatus &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"trust_rule\":\"" + JsonEscapeString(st.trust_rule) + "\"";
   j += ",\"update_source\":\"" + JsonEscapeString(st.update_source) + "\"";
   j += ",\"authority_state\":\"" + JsonEscapeString(st.authority_state) + "\"";
   j += ",\"readiness_state\":\"" + JsonEscapeString(st.readiness_state) + "\"";
   j += ",\"advisory_integration_enabled\":" + string(st.advisory_integration_enabled ? "true" : "false");
   j += ",\"advisory_invocation_allowed\":" + string(st.advisory_invocation_allowed ? "true" : "false");
   j += ",\"operational_influence_allowed\":" + string(st.operational_influence_allowed ? "true" : "false");
   j += ",\"advisory_packet_schema_state\":\"" + JsonEscapeString(st.advisory_packet_schema_state) + "\"";
   j += ",\"advisory_packet_id\":\"" + JsonEscapeString(st.advisory_packet_id) + "\"";
   j += ",\"advisory_state\":\"" + JsonEscapeString(st.advisory_state) + "\"";
   j += ",\"advisory_confidence\":" + DoubleToString(st.advisory_confidence, 3);
   j += ",\"evidence_strength\":" + DoubleToString(st.evidence_strength, 3);
   j += ",\"corroboration_count\":" + IntegerToString(st.corroboration_count);
   j += ",\"advisory_reason_codes_csv\":\"" + JsonEscapeString(st.advisory_reason_codes_csv) + "\"";
   j += ",\"rationale_short\":\"" + JsonEscapeString(st.rationale_short) + "\"";
   j += ",\"candidate_scope\":\"" + JsonEscapeString(st.candidate_scope) + "\"";
   j += ",\"candidate_decision_id\":\"" + JsonEscapeString(st.candidate_decision_id) + "\"";
   j += ",\"candidate_direction\":\"" + JsonEscapeString(st.candidate_direction) + "\"";
   j += ",\"relevant_zone\":\"" + JsonEscapeString(st.relevant_zone) + "\"";
   j += ",\"relevant_strategy_family\":\"" + JsonEscapeString(st.relevant_strategy_family) + "\"";
   j += ",\"advisory_freshness\":\"" + JsonEscapeString(st.advisory_freshness) + "\"";
   j += ",\"evidence_limitations\":\"" + JsonEscapeString(st.evidence_limitations) + "\"";
   j += ",\"recommended_action_class\":\"" + JsonEscapeString(st.recommended_action_class) + "\"";
   j += ",\"execution_instability_flag\":" + string(st.execution_instability_flag ? "true" : "false");
   j += ",\"strategy_family_weakening_flag\":" + string(st.strategy_family_weakening_flag ? "true" : "false");
   j += ",\"severe_recent_pattern_deterioration_flag\":" + string(st.severe_recent_pattern_deterioration_flag ? "true" : "false");
   j += ",\"anomaly_cluster_high_severity_flag\":" + string(st.anomaly_cluster_high_severity_flag ? "true" : "false");
   j += ",\"recent_similar_case_failure_bias_flag\":" + string(st.recent_similar_case_failure_bias_flag ? "true" : "false");
   j += ",\"relevance_gate_outcome\":\"" + JsonEscapeString(st.relevance_gate_outcome) + "\"";
   j += ",\"relevance_gate_reason_code\":\"" + JsonEscapeString(st.relevance_gate_reason_code) + "\"";
   j += ",\"strict_reason_families_csv\":\"" + JsonEscapeString(st.strict_reason_families_csv) + "\"";
   j += ",\"hold_applied\":" + string(st.hold_applied ? "true" : "false");
   j += ",\"block_applied\":" + string(st.block_applied ? "true" : "false");
   j += ",\"block_mode_enabled\":" + string(st.block_mode_enabled ? "true" : "false");
   j += ",\"effective_hold_bars\":" + IntegerToString(st.effective_hold_bars);
   j += ",\"effective_hold_limit_per_signature\":" + IntegerToString(st.effective_hold_limit_per_signature);
   j += ",\"effective_hold_confidence_threshold\":" + DoubleToString(st.effective_hold_confidence_threshold, 3);
   j += ",\"effective_hold_evidence_threshold\":" + DoubleToString(st.effective_hold_evidence_threshold, 3);
   j += ",\"effective_hold_corroboration_threshold\":" + IntegerToString(st.effective_hold_corroboration_threshold);
   j += ",\"effective_block_confidence_threshold\":" + DoubleToString(st.effective_block_confidence_threshold, 3);
   j += ",\"effective_block_evidence_threshold\":" + DoubleToString(st.effective_block_evidence_threshold, 3);
   j += ",\"effective_block_corroboration_threshold\":" + IntegerToString(st.effective_block_corroboration_threshold);
   j += ",\"current_hold_active\":" + string(st.current_hold_active ? "true" : "false");
   j += ",\"current_hold_signature\":\"" + JsonEscapeString(st.current_hold_signature) + "\"";
   j += ",\"current_hold_release_bar_index\":" + IntegerToString(st.current_hold_release_bar_index);
   j += ",\"current_hold_count_for_signature\":" + IntegerToString(st.current_hold_count_for_signature);
   j += ",\"non_authoritative_notice\":\"" + JsonEscapeString(st.non_authoritative_notice) + "\"";
   j += ",\"evaluated_at\":\"" + JsonEscapeString(DiagnosticTimeText(st.evaluated_at)) + "\"";
   j += "}";
   return j;
}

string BuildCouncilAIAdvisoryEffectivenessText(const CouncilAIAdvisoryEffectivenessSummary &st)
{
   string t = "";
   t += "artifact_role=" + st.artifact_role + "\n";
   t += "artifact_authority_class=" + st.artifact_authority_class + "\n";
   t += "summary_version=" + st.summary_version + "\n";
   t += "review_window_note=" + st.review_window_note + "\n";
   t += "note=" + st.note + "\n";
   t += "advisory_total=" + IntegerToString(st.advisory_total) + "\n";
   t += "advisory_ok_total=" + IntegerToString(st.advisory_ok_total) + "\n";
   t += "advisory_caution_total=" + IntegerToString(st.advisory_caution_total) + "\n";
   t += "advisory_strong_caution_total=" + IntegerToString(st.advisory_strong_caution_total) + "\n";
   t += "advisory_insufficient_evidence_total=" + IntegerToString(st.advisory_insufficient_evidence_total) + "\n";
   t += "advisory_hold_total=" + IntegerToString(st.advisory_hold_total) + "\n";
   t += "advisory_block_eligible_total=" + IntegerToString(st.advisory_block_eligible_total) + "\n";
   t += "advisory_block_applied_total=" + IntegerToString(st.advisory_block_applied_total) + "\n";
   t += "advisory_block_enabled=" + CouncilAIAdvisoryBoolText(st.advisory_block_enabled) + "\n";
   t += "hold_then_trade_total=" + IntegerToString(st.hold_then_trade_total) + "\n";
   t += "hold_then_drop_total=" + IntegerToString(st.hold_then_drop_total) + "\n";
   t += "blocked_loss_prevention_count=" + IntegerToString(st.blocked_loss_prevention_count) + "\n";
   t += "blocked_win_penalty_count=" + IntegerToString(st.blocked_win_penalty_count) + "\n";
   t += "false_block_risk_unknown=" + CouncilAIAdvisoryBoolText(st.false_block_risk_unknown) + "\n";
   t += "advisory_effectiveness_confidence=" + st.advisory_effectiveness_confidence + "\n";
   t += "rebuilt_at=" + DiagnosticTimeText(st.rebuilt_at) + "\n";
   return t;
}

string BuildCouncilAIAdvisoryEffectivenessJson(const CouncilAIAdvisoryEffectivenessSummary &st)
{
   string j = "{";
   j += "\"artifact_role\":\"" + JsonEscapeString(st.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + JsonEscapeString(st.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + JsonEscapeString(st.summary_version) + "\"";
   j += ",\"review_window_note\":\"" + JsonEscapeString(st.review_window_note) + "\"";
   j += ",\"note\":\"" + JsonEscapeString(st.note) + "\"";
   j += ",\"advisory_total\":" + IntegerToString(st.advisory_total);
   j += ",\"advisory_ok_total\":" + IntegerToString(st.advisory_ok_total);
   j += ",\"advisory_caution_total\":" + IntegerToString(st.advisory_caution_total);
   j += ",\"advisory_strong_caution_total\":" + IntegerToString(st.advisory_strong_caution_total);
   j += ",\"advisory_insufficient_evidence_total\":" + IntegerToString(st.advisory_insufficient_evidence_total);
   j += ",\"advisory_hold_total\":" + IntegerToString(st.advisory_hold_total);
   j += ",\"advisory_block_eligible_total\":" + IntegerToString(st.advisory_block_eligible_total);
   j += ",\"advisory_block_applied_total\":" + IntegerToString(st.advisory_block_applied_total);
   j += ",\"advisory_block_enabled\":" + string(st.advisory_block_enabled ? "true" : "false");
   j += ",\"hold_then_trade_total\":" + IntegerToString(st.hold_then_trade_total);
   j += ",\"hold_then_drop_total\":" + IntegerToString(st.hold_then_drop_total);
   j += ",\"blocked_loss_prevention_count\":" + IntegerToString(st.blocked_loss_prevention_count);
   j += ",\"blocked_win_penalty_count\":" + IntegerToString(st.blocked_win_penalty_count);
   j += ",\"false_block_risk_unknown\":" + string(st.false_block_risk_unknown ? "true" : "false");
   j += ",\"advisory_effectiveness_confidence\":\"" + JsonEscapeString(st.advisory_effectiveness_confidence) + "\"";
   j += ",\"rebuilt_at\":\"" + JsonEscapeString(DiagnosticTimeText(st.rebuilt_at)) + "\"";
   j += "}";
   return j;
}

void SaveCouncilAIAdvisoryStatusBestEffort(const CouncilAIAdvisoryStatus &st)
{
   WriteTextFileAll(CouncilAIAdvisoryStatusTxtPath(), BuildCouncilAIAdvisoryStatusText(st));
   WriteTextFileAll(CouncilAIAdvisoryStatusJsonPath(), BuildCouncilAIAdvisoryStatusJson(st));
}

void SaveCouncilAIAdvisoryEffectivenessBestEffort(const CouncilAIAdvisoryEffectivenessSummary &st)
{
   WriteTextFileAll(CouncilAIAdvisoryEffectivenessTxtPath(), BuildCouncilAIAdvisoryEffectivenessText(st));
   WriteTextFileAll(CouncilAIAdvisoryEffectivenessJsonPath(), BuildCouncilAIAdvisoryEffectivenessJson(st));
}

void CouncilAIAdvisorySyncHoldState()
{
   if(!gCouncilAIAdvisoryHoldInitialized)
   {
      InitCouncilAIAdvisoryHoldState(gCouncilAIAdvisoryHold);
      gCouncilAIAdvisoryHoldInitialized = true;
   }

   int currentBarIndex = Bars(_Symbol, PERIOD_M1);
   if(gCouncilAIAdvisoryHold.active && currentBarIndex > gCouncilAIAdvisoryHold.release_bar_index)
   {
      if(gCouncilAIAdvisoryEffectivenessInitialized)
      {
         gCouncilAIAdvisoryEffectiveness.hold_then_drop_total++;
         gCouncilAIAdvisoryEffectiveness.rebuilt_at = TimeCurrent();
         SaveCouncilAIAdvisoryEffectivenessBestEffort(gCouncilAIAdvisoryEffectiveness);
      }
      gCouncilAIAdvisoryHold.active = false;
   }

   if(StringLen(gCouncilAIAdvisoryHold.candidate_signature) > 0 &&
      gCouncilAIAdvisoryHold.signature_anchor_bar_index > 0 &&
      currentBarIndex - gCouncilAIAdvisoryHold.signature_anchor_bar_index > CouncilAIAdvisorySignatureResetBars())
   {
      string preservedSignature = gCouncilAIAdvisoryHold.candidate_signature;
      InitCouncilAIAdvisoryHoldState(gCouncilAIAdvisoryHold);
      gCouncilAIAdvisoryHold.candidate_signature = preservedSignature;
   }
}

void RefreshCouncilAIAdvisoryArtifactsBestEffort()
{
   if(!gCouncilAIAdvisoryStatusInitialized)
   {
      InitCouncilAIAdvisoryStatus(gCouncilAIAdvisoryStatus);
      gCouncilAIAdvisoryStatusInitialized = true;
   }

   if(!gCouncilAIAdvisoryEffectivenessInitialized)
   {
      InitCouncilAIAdvisoryEffectivenessSummary(gCouncilAIAdvisoryEffectiveness);
      gCouncilAIAdvisoryEffectivenessInitialized = true;
   }

   CouncilAIAdvisorySyncHoldState();

   gCouncilAIAdvisoryStatus.authority_state = gAIAuthorityReadiness.authority_state;
   gCouncilAIAdvisoryStatus.readiness_state = gAIAuthorityReadiness.readiness_state;
   gCouncilAIAdvisoryStatus.block_mode_enabled = EnableAICandidateBlock;
   gCouncilAIAdvisoryStatus.advisory_integration_enabled = EnableAICouncilContextualAdvisory;
   gCouncilAIAdvisoryStatus.current_hold_active = gCouncilAIAdvisoryHold.active;
   gCouncilAIAdvisoryStatus.current_hold_signature = gCouncilAIAdvisoryHold.candidate_signature;
   gCouncilAIAdvisoryStatus.current_hold_release_bar_index = gCouncilAIAdvisoryHold.release_bar_index;
   gCouncilAIAdvisoryStatus.current_hold_count_for_signature = gCouncilAIAdvisoryHold.holds_used_for_signature;
   gCouncilAIAdvisoryStatus.evaluated_at = TimeCurrent();

   gCouncilAIAdvisoryEffectiveness.advisory_block_enabled = EnableAICandidateBlock;
   gCouncilAIAdvisoryEffectiveness.rebuilt_at = TimeCurrent();

   SaveCouncilAIAdvisoryStatusBestEffort(gCouncilAIAdvisoryStatus);
   SaveCouncilAIAdvisoryEffectivenessBestEffort(gCouncilAIAdvisoryEffectiveness);
}

void CouncilAIAdvisoryLoadEffectivenessFromDiskBestEffort()
{
   InitCouncilAIAdvisoryEffectivenessSummary(gCouncilAIAdvisoryEffectiveness);
   gCouncilAIAdvisoryEffectivenessInitialized = true;

   string json = "";
   if(!FileIsExist(CouncilAIAdvisoryEffectivenessJsonPath()) || !ReadTextFileAll(CouncilAIAdvisoryEffectivenessJsonPath(), json))
      return;

   ExtractJsonIntField(json, "advisory_total", gCouncilAIAdvisoryEffectiveness.advisory_total);
   ExtractJsonIntField(json, "advisory_ok_total", gCouncilAIAdvisoryEffectiveness.advisory_ok_total);
   ExtractJsonIntField(json, "advisory_caution_total", gCouncilAIAdvisoryEffectiveness.advisory_caution_total);
   ExtractJsonIntField(json, "advisory_strong_caution_total", gCouncilAIAdvisoryEffectiveness.advisory_strong_caution_total);
   ExtractJsonIntField(json, "advisory_insufficient_evidence_total", gCouncilAIAdvisoryEffectiveness.advisory_insufficient_evidence_total);
   ExtractJsonIntField(json, "advisory_hold_total", gCouncilAIAdvisoryEffectiveness.advisory_hold_total);
   ExtractJsonIntField(json, "advisory_block_eligible_total", gCouncilAIAdvisoryEffectiveness.advisory_block_eligible_total);
   ExtractJsonIntField(json, "advisory_block_applied_total", gCouncilAIAdvisoryEffectiveness.advisory_block_applied_total);
   ExtractJsonBoolField(json, "advisory_block_enabled", gCouncilAIAdvisoryEffectiveness.advisory_block_enabled);
   ExtractJsonIntField(json, "hold_then_trade_total", gCouncilAIAdvisoryEffectiveness.hold_then_trade_total);
   ExtractJsonIntField(json, "hold_then_drop_total", gCouncilAIAdvisoryEffectiveness.hold_then_drop_total);
   ExtractJsonIntField(json, "blocked_loss_prevention_count", gCouncilAIAdvisoryEffectiveness.blocked_loss_prevention_count);
   ExtractJsonIntField(json, "blocked_win_penalty_count", gCouncilAIAdvisoryEffectiveness.blocked_win_penalty_count);
   ExtractJsonBoolField(json, "false_block_risk_unknown", gCouncilAIAdvisoryEffectiveness.false_block_risk_unknown);
   ExtractJsonStringField(json, "advisory_effectiveness_confidence", gCouncilAIAdvisoryEffectiveness.advisory_effectiveness_confidence);
   string rebuiltAt = "";
   if(ExtractJsonStringField(json, "rebuilt_at", rebuiltAt))
      gCouncilAIAdvisoryEffectiveness.rebuilt_at = DiagnosticParseTimeText(rebuiltAt);
}

bool CouncilAIAdvisoryHasInvalidatingLimitations(const CouncilAIAdvisoryPacket &packet)
{
   string upper = CouncilAIAdvisoryUpper(packet.evidence_limitations);
   if(packet.advisory_state == "ADVISORY_INSUFFICIENT_EVIDENCE")
      return true;
   if(CouncilAIAdvisoryNormalizeFreshness(packet.advisory_freshness) == "STALE")
      return true;
   if(StringFind(upper, "INSUFFICIENT") >= 0)
      return true;
   if(StringFind(upper, "INVALIDATES") >= 0)
      return true;
   if(StringFind(upper, "CONTRADICT") >= 0)
      return true;
   return false;
}

int CouncilAIAdvisoryDeriveCorroborationCount(CouncilAIAdvisoryPacket &packet)
{
   int derived = 0;
   if(packet.execution_instability_flag)
      derived++;
   if(packet.strategy_family_weakening_flag)
      derived++;
   if(packet.severe_recent_pattern_deterioration_flag)
      derived++;
   if(packet.anomaly_cluster_high_severity_flag)
      derived++;
   if(packet.recent_similar_case_failure_bias_flag)
      derived++;

   if(derived <= 0 && StringLen(packet.advisory_reason_codes_csv) > 0)
   {
      string parts[];
      int count = StringSplit(packet.advisory_reason_codes_csv, ',', parts);
      for(int i = 0; i < count; i++)
      {
         if(StringLen(CouncilAIAdvisoryNormalizeReasonFamily(parts[i])) > 0)
            derived++;
      }
   }

   if(derived < 0)
      derived = 0;

   int supplied = packet.corroboration_count;
   if(supplied <= 0)
      return derived;

   if(derived <= 0)
      return MathMin(10, supplied);

   return MathMin(MathMin(10, supplied), derived);
}

void CouncilAIAdvisorySanitizePacket(CouncilAIAdvisoryPacket &packet)
{
   packet.advisory_state = CouncilAIAdvisoryNormalizeState(packet.advisory_state);
   packet.advisory_confidence = MathMax(0.0, MathMin(1.0, packet.advisory_confidence));
   packet.evidence_strength = MathMax(0.0, MathMin(1.0, packet.evidence_strength));
   packet.advisory_freshness = CouncilAIAdvisoryNormalizeFreshness(packet.advisory_freshness);
   packet.recommended_action_class = CouncilAIAdvisoryNormalizeActionClass(packet.recommended_action_class);
   packet.advisory_reason_codes_csv = CouncilAIAdvisoryNormalizeReasonFamiliesCsv(packet.advisory_reason_codes_csv);

   if(CouncilAIAdvisoryCsvContains(packet.advisory_reason_codes_csv, "EXECUTION_INSTABILITY_CLUSTER"))
      packet.execution_instability_flag = true;
   if(CouncilAIAdvisoryCsvContains(packet.advisory_reason_codes_csv, "STRATEGY_FAMILY_WEAKENING"))
      packet.strategy_family_weakening_flag = true;
   if(CouncilAIAdvisoryCsvContains(packet.advisory_reason_codes_csv, "SEVERE_RECENT_PATTERN_DETERIORATION"))
      packet.severe_recent_pattern_deterioration_flag = true;
   if(CouncilAIAdvisoryCsvContains(packet.advisory_reason_codes_csv, "ANOMALY_CLUSTER_HIGH_SEVERITY"))
      packet.anomaly_cluster_high_severity_flag = true;
   if(CouncilAIAdvisoryCsvContains(packet.advisory_reason_codes_csv, "HIGH_SIMILAR_CASE_FAILURE_BIAS"))
      packet.recent_similar_case_failure_bias_flag = true;

   packet.corroboration_count = CouncilAIAdvisoryDeriveCorroborationCount(packet);
   packet.direct_control_allowed = false;
   packet.directional_generation_allowed = false;
   packet.reserved_future_state_only = (packet.advisory_state == "BLOCK_CANDIDATE_ELIGIBLE");
   packet.valid = (StringLen(packet.candidate_decision_id) > 0);
}

void CouncilAIAdvisoryUpdateStatusFromPacketAndGate(const CouncilAIAdvisoryPacket &packet,
                                                    const CouncilAIAdvisoryRelevanceGateResult &gate,
                                                    const string updateSource)
{
   if(!gCouncilAIAdvisoryStatusInitialized)
   {
      InitCouncilAIAdvisoryStatus(gCouncilAIAdvisoryStatus);
      gCouncilAIAdvisoryStatusInitialized = true;
   }

   CouncilAIAdvisorySyncHoldState();

   gCouncilAIAdvisoryStatus.update_source = updateSource;
   gCouncilAIAdvisoryStatus.authority_state = gAIAuthorityReadiness.authority_state;
   gCouncilAIAdvisoryStatus.readiness_state = gAIAuthorityReadiness.readiness_state;
   gCouncilAIAdvisoryStatus.advisory_integration_enabled = EnableAICouncilContextualAdvisory;
   gCouncilAIAdvisoryStatus.advisory_invocation_allowed = gate.advisory_considered;
   gCouncilAIAdvisoryStatus.operational_influence_allowed = gate.operational_influence_allowed;
   gCouncilAIAdvisoryStatus.advisory_packet_schema_state = (packet.valid ? "STRUCTURED_PACKET_VALID" : packet.invocation_state);
   gCouncilAIAdvisoryStatus.advisory_packet_id = packet.advisory_packet_id;
   gCouncilAIAdvisoryStatus.advisory_state = packet.advisory_state;
   gCouncilAIAdvisoryStatus.advisory_confidence = packet.advisory_confidence;
   gCouncilAIAdvisoryStatus.evidence_strength = packet.evidence_strength;
   gCouncilAIAdvisoryStatus.corroboration_count = packet.corroboration_count;
   gCouncilAIAdvisoryStatus.advisory_reason_codes_csv = packet.advisory_reason_codes_csv;
   gCouncilAIAdvisoryStatus.rationale_short = packet.rationale_short;
   gCouncilAIAdvisoryStatus.candidate_scope = packet.candidate_scope;
   gCouncilAIAdvisoryStatus.candidate_decision_id = packet.candidate_decision_id;
   gCouncilAIAdvisoryStatus.candidate_direction = packet.candidate_direction;
   gCouncilAIAdvisoryStatus.relevant_zone = packet.relevant_zone;
   gCouncilAIAdvisoryStatus.relevant_strategy_family = packet.relevant_strategy_family;
   gCouncilAIAdvisoryStatus.advisory_freshness = packet.advisory_freshness;
   gCouncilAIAdvisoryStatus.evidence_limitations = packet.evidence_limitations;
   gCouncilAIAdvisoryStatus.recommended_action_class = packet.recommended_action_class;
   gCouncilAIAdvisoryStatus.execution_instability_flag = packet.execution_instability_flag;
   gCouncilAIAdvisoryStatus.strategy_family_weakening_flag = packet.strategy_family_weakening_flag;
   gCouncilAIAdvisoryStatus.severe_recent_pattern_deterioration_flag = packet.severe_recent_pattern_deterioration_flag;
   gCouncilAIAdvisoryStatus.anomaly_cluster_high_severity_flag = packet.anomaly_cluster_high_severity_flag;
   gCouncilAIAdvisoryStatus.recent_similar_case_failure_bias_flag = packet.recent_similar_case_failure_bias_flag;
   gCouncilAIAdvisoryStatus.relevance_gate_outcome = gate.gate_outcome;
   gCouncilAIAdvisoryStatus.relevance_gate_reason_code = gate.gate_reason_code;
   gCouncilAIAdvisoryStatus.strict_reason_families_csv = gate.strict_reason_families_csv;
   gCouncilAIAdvisoryStatus.hold_applied = gate.hold_applied;
   gCouncilAIAdvisoryStatus.block_applied = gate.block_applied;
   gCouncilAIAdvisoryStatus.block_mode_enabled = EnableAICandidateBlock;
   gCouncilAIAdvisoryStatus.current_hold_active = gCouncilAIAdvisoryHold.active;
   gCouncilAIAdvisoryStatus.current_hold_signature = gCouncilAIAdvisoryHold.candidate_signature;
   gCouncilAIAdvisoryStatus.current_hold_release_bar_index = gCouncilAIAdvisoryHold.release_bar_index;
   gCouncilAIAdvisoryStatus.current_hold_count_for_signature = gCouncilAIAdvisoryHold.holds_used_for_signature;
   gCouncilAIAdvisoryStatus.evaluated_at = TimeCurrent();

   SaveCouncilAIAdvisoryStatusBestEffort(gCouncilAIAdvisoryStatus);
}

void CouncilAIAdvisoryTrackPacket(const CouncilAIAdvisoryPacket &packet, const CouncilAIAdvisoryRelevanceGateResult &gate)
{
   if(!gCouncilAIAdvisoryEffectivenessInitialized)
   {
      InitCouncilAIAdvisoryEffectivenessSummary(gCouncilAIAdvisoryEffectiveness);
      gCouncilAIAdvisoryEffectivenessInitialized = true;
   }

   if(!packet.valid)
      return;

   gCouncilAIAdvisoryEffectiveness.advisory_total++;
   if(packet.advisory_state == "ADVISORY_OK")
      gCouncilAIAdvisoryEffectiveness.advisory_ok_total++;
   else if(packet.advisory_state == "ADVISORY_CAUTION")
      gCouncilAIAdvisoryEffectiveness.advisory_caution_total++;
   else if(packet.advisory_state == "ADVISORY_STRONG_CAUTION")
      gCouncilAIAdvisoryEffectiveness.advisory_strong_caution_total++;
   else if(packet.advisory_state == "ADVISORY_INSUFFICIENT_EVIDENCE")
      gCouncilAIAdvisoryEffectiveness.advisory_insufficient_evidence_total++;

   if(packet.advisory_state == "BLOCK_CANDIDATE_ELIGIBLE")
      gCouncilAIAdvisoryEffectiveness.advisory_block_eligible_total++;

   if(gate.hold_applied)
      gCouncilAIAdvisoryEffectiveness.advisory_hold_total++;

   if(gate.block_applied)
      gCouncilAIAdvisoryEffectiveness.advisory_block_applied_total++;

   gCouncilAIAdvisoryEffectiveness.rebuilt_at = TimeCurrent();
   SaveCouncilAIAdvisoryEffectivenessBestEffort(gCouncilAIAdvisoryEffectiveness);
}

void CouncilAIAdvisoryAcknowledgeTradeOpenFromHeldCandidate(const string decisionId)
{
   if(!gCouncilAIAdvisoryEffectivenessInitialized)
      return;

   if(StringLen(TrimString(decisionId)) <= 0)
      return;

   if(StringLen(TrimString(gCouncilAIAdvisoryHold.decision_id)) > 0 &&
      gCouncilAIAdvisoryHold.decision_id == decisionId)
   {
      gCouncilAIAdvisoryEffectiveness.hold_then_trade_total++;
      gCouncilAIAdvisoryEffectiveness.rebuilt_at = TimeCurrent();
      gCouncilAIAdvisoryHold.active = false;
      SaveCouncilAIAdvisoryEffectivenessBestEffort(gCouncilAIAdvisoryEffectiveness);
   }
}

void CouncilAIAdvisoryAcknowledgeHoldExpiredNoTrade()
{
   if(!gCouncilAIAdvisoryEffectivenessInitialized)
      return;

   if(!gCouncilAIAdvisoryHold.active)
      return;
}

bool CouncilAIAdvisoryInvocationAllowed(string &authorityState, string &reasonCode, bool &operationalInfluenceAllowed)
{
   RefreshAIActivationReadinessStatusBestEffort();

   authorityState = gAIAuthorityReadiness.authority_state;
   reasonCode = gAIAuthorityReadiness.readiness_reason_code;
   operationalInfluenceAllowed = (authorityState == "AI_ADVISORY_ONLY");

   if(!EnableAICouncilContextualAdvisory)
   {
      reasonCode = "ai_council_advisory_disabled";
      return false;
   }

   if(authorityState == "AI_SHADOW_ONLY" || authorityState == "AI_ADVISORY_ONLY")
      return true;

   return false;
}

string BuildCouncilAIAdvisorySystemPrompt()
{
   string s = "";
   s += "You are the bounded council contextual advisory layer. ";
   s += "You review an already-existing council candidate only. ";
   s += "Never generate BUY or SELL. Never reverse direction. Never issue execution or veto commands. ";
   s += "Return JSON only with fields: ";
   s += "{\"advisory_state\":\"NO_ADVISORY|ADVISORY_OK|ADVISORY_CAUTION|ADVISORY_STRONG_CAUTION|ADVISORY_INSUFFICIENT_EVIDENCE|BLOCK_CANDIDATE_ELIGIBLE\",";
   s += "\"advisory_confidence\":0.0,\"evidence_strength\":0.0,\"corroboration_count\":0,";
   s += "\"advisory_reason_codes_csv\":\"SEVERE_RECENT_PATTERN_DETERIORATION,HIGH_SIMILAR_CASE_FAILURE_BIAS,EXECUTION_INSTABILITY_CLUSTER,STRATEGY_FAMILY_WEAKENING,ANOMALY_CLUSTER_HIGH_SEVERITY\",";
   s += "\"rationale_short\":\"...\",\"execution_instability_flag\":false,\"strategy_family_weakening_flag\":false,";
   s += "\"severe_recent_pattern_deterioration_flag\":false,\"anomaly_cluster_high_severity_flag\":false,";
   s += "\"recent_similar_case_failure_bias_flag\":false,\"advisory_freshness\":\"FRESH|RECENT|STALE|UNKNOWN\",";
   s += "\"evidence_limitations\":\"...\",\"recommended_action_class\":\"NO_ACTION|DISPLAY_ONLY|FLAG_FOR_OPERATOR|HOLD_FOR_REEVALUATION|BLOCK_CANDIDATE_ELIGIBLE\"}";
   return s;
}

string BuildCouncilAIAdvisoryUserPrompt(const RoutedRuntimeEvaluation &routed,
                                        const TimeframeSnapshot &m1,
                                        const RuntimeEvaluation &eval,
                                        const string direction)
{
   string candidateScope = CouncilAIAdvisoryBuildCandidateScope(routed, direction);
   string strategyFamily = LAB_InferFamilyFromStrategyId(routed.council.aggregate.best_strategy_id);

   string prompt = "";
   prompt += "authority_state=" + gAIAuthorityReadiness.authority_state + "\n";
   prompt += "candidate_scope=" + candidateScope + "\n";
   prompt += "candidate_decision_id=" + gCurrentDecisionId + "\n";
   prompt += "candidate_direction=" + direction + "\n";
   prompt += "active_plan_id=" + gPlan.plan_id + "\n";
   prompt += "active_mode=" + NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode) + "\n";
   prompt += "regime_label=" + gRegime.regime_label + "\n";
   prompt += "regime_confidence=" + DoubleToString(gRegime.regime_confidence, 3) + "\n";
   prompt += "zone_name=" + routed.council.env.zone_name + "\n";
   prompt += "zone_semantic=" + routed.council.zone_coverage.zone_semantic + "\n";
   prompt += "best_strategy_id=" + routed.council.aggregate.best_strategy_id + "\n";
   prompt += "strategy_family=" + strategyFamily + "\n";
   prompt += "consensus_strength=" + DoubleToString(routed.council.aggregate.consensus_strength, 3) + "\n";
   prompt += "conflict_score=" + DoubleToString(routed.council.aggregate.conflict_score, 3) + "\n";
   prompt += "council_quality=" + DoubleToString(routed.council.aggregate.council_quality, 3) + "\n";
   prompt += "environment_score=" + DoubleToString(routed.council.env.total_score, 3) + "\n";
   prompt += "dominant_failure=" + gDiagnosticRuntimeSummary.dominant_failure + "\n";
   prompt += "dominant_failure_source=" + gDiagnosticRuntimeSummary.dominant_failure_source + "\n";
   prompt += "dominant_failure_pressure=" + gDiagnosticRuntimeSummary.dominant_failure_pressure + "\n";
   prompt += "execution_failure_rate=" + DoubleToString(gExecutionQualityValidationSummary.execution_open_failure_rate, 3) + "\n";
   prompt += "dominant_block_layer=" + gExecutionQualityValidationSummary.dominant_block_layer + "\n";
   prompt += "dominant_rejection_family=" + gExecutionQualityValidationSummary.dominant_rejection_family + "\n";
   prompt += "replay_case_type=" + gReplayValidationSummary.replay_case_type + "\n";
   prompt += "replay_confidence=" + gReplayValidationSummary.replay_confidence + "\n";
   prompt += "spread_points=" + DoubleToString(m1.spread_points, 2) + "\n";
   prompt += "base_eval_reason=" + eval.reason + "\n";
   prompt += "Only return structured contextual advisory. Do not generate direction.";
   return prompt;
}

bool RequestCouncilAIAdvisoryPacket(const RoutedRuntimeEvaluation &routed,
                                    const TimeframeSnapshot &m1,
                                    const RuntimeEvaluation &eval,
                                    const string direction,
                                    CouncilAIAdvisoryPacket &packet)
{
   InitCouncilAIAdvisoryPacket(packet);

   string authorityState = "";
   string reasonCode = "";
   bool operationalInfluenceAllowed = false;
   if(!CouncilAIAdvisoryInvocationAllowed(authorityState, reasonCode, operationalInfluenceAllowed))
   {
      packet.invocation_state = "NOT_ALLOWED";
      packet.invocation_reason_code = reasonCode;
      packet.candidate_decision_id = gCurrentDecisionId;
      packet.candidate_direction = direction;
      packet.candidate_scope = CouncilAIAdvisoryBuildCandidateScope(routed, direction);
      packet.relevant_zone = routed.council.env.zone_name;
      packet.relevant_strategy_family = LAB_InferFamilyFromStrategyId(routed.council.aggregate.best_strategy_id);
      return false;
   }

   packet.invocation_state = "INVOCATION_ATTEMPTED";
   packet.invocation_reason_code = "advisory_requested";
   packet.candidate_decision_id = gCurrentDecisionId;
   packet.candidate_direction = direction;
   packet.candidate_scope = CouncilAIAdvisoryBuildCandidateScope(routed, direction);
   packet.relevant_zone = routed.council.env.zone_name;
   packet.relevant_strategy_family = LAB_InferFamilyFromStrategyId(routed.council.aggregate.best_strategy_id);
   packet.advisory_packet_id = "AICADV_" + IntegerToString((int)TimeCurrent()) + "_" + gCurrentDecisionId;
   packet.evaluated_at = TimeCurrent();

   if(!AIIsReady(gAISecrets))
   {
      packet.invocation_state = "BRIDGE_NOT_READY";
      packet.invocation_reason_code = "ai_bridge_not_ready";
      return false;
   }

   string rawApiResponse = "";
   string err = "";
   if(!CallOpenAIChat(gAISecrets,
                      BuildCouncilAIAdvisorySystemPrompt(),
                      BuildCouncilAIAdvisoryUserPrompt(routed, m1, eval, direction),
                      rawApiResponse,
                      err))
   {
      packet.invocation_state = "CALL_FAILED";
      packet.invocation_reason_code = err;
      packet.raw_response = rawApiResponse;
      return false;
   }

   string assistantJson = "";
   if(!ExtractAssistantContentFromChatResponse(rawApiResponse, assistantJson))
   {
      packet.invocation_state = "INVALID_RESPONSE";
      packet.invocation_reason_code = "failed_to_extract_assistant_content";
      packet.raw_response = rawApiResponse;
      packet.advisory_state = "ADVISORY_INSUFFICIENT_EVIDENCE";
      packet.evidence_limitations = "assistant_content_extraction_failed";
      return false;
   }

   packet.raw_response = assistantJson;
   ExtractJsonStringField(assistantJson, "advisory_state", packet.advisory_state);
   ExtractJsonDoubleField(assistantJson, "advisory_confidence", packet.advisory_confidence);
   ExtractJsonDoubleField(assistantJson, "evidence_strength", packet.evidence_strength);
   ExtractJsonIntField(assistantJson, "corroboration_count", packet.corroboration_count);
   ExtractJsonStringField(assistantJson, "advisory_reason_codes_csv", packet.advisory_reason_codes_csv);
   ExtractJsonStringField(assistantJson, "rationale_short", packet.rationale_short);
   ExtractJsonBoolField(assistantJson, "execution_instability_flag", packet.execution_instability_flag);
   ExtractJsonBoolField(assistantJson, "strategy_family_weakening_flag", packet.strategy_family_weakening_flag);
   ExtractJsonBoolField(assistantJson, "severe_recent_pattern_deterioration_flag", packet.severe_recent_pattern_deterioration_flag);
   ExtractJsonBoolField(assistantJson, "anomaly_cluster_high_severity_flag", packet.anomaly_cluster_high_severity_flag);
   ExtractJsonBoolField(assistantJson, "recent_similar_case_failure_bias_flag", packet.recent_similar_case_failure_bias_flag);
   ExtractJsonStringField(assistantJson, "advisory_freshness", packet.advisory_freshness);
   ExtractJsonStringField(assistantJson, "evidence_limitations", packet.evidence_limitations);
   ExtractJsonStringField(assistantJson, "recommended_action_class", packet.recommended_action_class);

   CouncilAIAdvisorySanitizePacket(packet);
   packet.invocation_state = "STRUCTURED_PACKET_VALID";
   packet.invocation_reason_code = "structured_advisory_ready";
   packet.valid = true;

   return true;
}

bool CouncilAIAdvisoryStrictReasonsPresent(const CouncilAIAdvisoryPacket &packet)
{
   return (StringLen(TrimString(packet.advisory_reason_codes_csv)) > 0);
}

bool CouncilAIAdvisoryBlockConditionsSatisfied(const CouncilAIAdvisoryPacket &packet)
{
   // [DORMANT_BRANCH: AI_CANDIDATE_BLOCK] flag=false; double-dormant: AIGateSecurityClearanceForAdvisory must be true first (AI_ADVISORY_ONLY state required); Phase 6 reserved for activation
   if(!EnableAICandidateBlock)
      return false;

   if(gAIAuthorityReadiness.authority_state != "AI_ADVISORY_ONLY")
      return false;

   bool strictBlockEligibleState =
      (packet.advisory_state == "BLOCK_CANDIDATE_ELIGIBLE" ||
       (packet.advisory_state == "ADVISORY_STRONG_CAUTION" &&
        packet.recommended_action_class == "BLOCK_CANDIDATE_ELIGIBLE"));

   if(!strictBlockEligibleState)
      return false;

   if(packet.advisory_confidence < AICandidateEffectiveBlockMinConfidence())
      return false;

   if(packet.evidence_strength < AICandidateEffectiveBlockMinEvidenceStrength())
      return false;

   if(packet.corroboration_count < AICandidateEffectiveBlockMinCorroborationCount())
      return false;

   if(!CouncilAIAdvisoryStrictReasonsPresent(packet))
      return false;

   if(!CouncilAIAdvisoryFreshEnough(packet.advisory_freshness))
      return false;

   if(CouncilAIAdvisoryHasInvalidatingLimitations(packet))
      return false;

   if(gRuntimeGovernance.governance_state != "READY_ACTIVE" || !gRuntimeGovernance.trading_allowed)
      return false;

   if(gRuntimeRiskSafety.safety_state != "SAFE_ACTIVE" || !gRuntimeRiskSafety.trading_allowed)
      return false;

   return true;
}

void EvaluateCouncilAIAdvisoryRelevanceGate(const CouncilAIAdvisoryPacket &packet,
                                            CouncilAIAdvisoryRelevanceGateResult &gate)
{
   InitCouncilAIAdvisoryRelevanceGateResult(gate);

   gate.operational_influence_allowed = (gAIAuthorityReadiness.authority_state == "AI_ADVISORY_ONLY");
   gate.block_mode_enabled = EnableAICandidateBlock;
   gate.evaluated_at = TimeCurrent();

   if(!packet.valid)
   {
      gate.gate_outcome = "IGNORE_ADVISORY";
      gate.gate_reason_code = packet.invocation_reason_code;
      gate.note = "no_structured_packet";
      return;
   }

   gate.advisory_considered = true;
   gate.strict_reason_families_csv = packet.advisory_reason_codes_csv;
   gate.effective_corroboration_count = packet.corroboration_count;

   if(gAIAuthorityReadiness.authority_state == "AI_SHADOW_ONLY")
   {
      gate.gate_outcome = "DISPLAY_ONLY";
      gate.gate_reason_code = "shadow_only_display";
      gate.note = "shadow_only_no_operational_influence";
      return;
   }

   if(packet.advisory_state == "NO_ADVISORY" || packet.advisory_state == "ADVISORY_OK")
   {
      gate.gate_outcome = "DISPLAY_ONLY";
      gate.gate_reason_code = "advisory_ok_display_only";
      return;
   }

   if(packet.advisory_state == "ADVISORY_INSUFFICIENT_EVIDENCE" || CouncilAIAdvisoryHasInvalidatingLimitations(packet))
   {
      gate.gate_outcome = "DISPLAY_ONLY";
      gate.gate_reason_code = "insufficient_evidence_display_only";
      gate.note = "insufficient_or_invalidating_limitations";
      return;
   }

   if(packet.advisory_state == "ADVISORY_CAUTION")
   {
      if(packet.corroboration_count >= 2 &&
         packet.advisory_confidence >= 0.65 &&
         packet.evidence_strength >= 0.60 &&
         CouncilAIAdvisoryStrictReasonsPresent(packet))
      {
         gate.gate_outcome = "FLAG_FOR_OPERATOR";
         gate.gate_reason_code = "caution_meaningful_corroboration";
         return;
      }

      gate.gate_outcome = "DISPLAY_ONLY";
      gate.gate_reason_code = "caution_weak_or_partial";
      return;
   }

   if(packet.advisory_state == "ADVISORY_STRONG_CAUTION" || packet.advisory_state == "BLOCK_CANDIDATE_ELIGIBLE")
   {
      bool holdEligible =
         CouncilAIAdvisoryFreshEnough(packet.advisory_freshness) &&
         !CouncilAIAdvisoryHasInvalidatingLimitations(packet) &&
         packet.advisory_confidence >= gate.hold_confidence_threshold &&
         packet.evidence_strength >= gate.hold_evidence_threshold &&
         packet.corroboration_count >= gate.hold_corroboration_threshold &&
         CouncilAIAdvisoryStrictReasonsPresent(packet);

      bool blockEligible = CouncilAIAdvisoryBlockConditionsSatisfied(packet);

      gate.strict_conditions_satisfied = blockEligible;

      if(blockEligible)
      {
         gate.gate_outcome = "BLOCK_CANDIDATE";
         gate.gate_reason_code = "strict_block_conditions_satisfied";
         gate.note = "future_block_mode_manually_enabled";
         return;
      }

      if(holdEligible)
      {
         gate.gate_outcome = "HOLD_FOR_REEVALUATION";
         gate.gate_reason_code = (packet.advisory_state == "BLOCK_CANDIDATE_ELIGIBLE"
                                  ? "block_mode_disabled_hold_only"
                                  : "strong_caution_hold");
         gate.note = "bounded_hold_for_reevaluation";
         return;
      }

      gate.gate_outcome = "FLAG_FOR_OPERATOR";
      gate.gate_reason_code = "strong_caution_below_hold_thresholds";
      return;
   }

   gate.gate_outcome = "DISPLAY_ONLY";
   gate.gate_reason_code = "fallback_display_only";
}

bool CouncilAIAdvisoryCanApplyHold(const string candidateSignature)
{
   CouncilAIAdvisorySyncHoldState();

   int currentBarIndex = Bars(_Symbol, PERIOD_M1);
   if(StringLen(gCouncilAIAdvisoryHold.candidate_signature) <= 0 ||
      gCouncilAIAdvisoryHold.candidate_signature != candidateSignature)
   {
      InitCouncilAIAdvisoryHoldState(gCouncilAIAdvisoryHold);
      gCouncilAIAdvisoryHoldInitialized = true;
      gCouncilAIAdvisoryHold.candidate_signature = candidateSignature;
      gCouncilAIAdvisoryHold.signature_anchor_bar_index = currentBarIndex;
      gCouncilAIAdvisoryHold.holds_used_for_signature = 0;
   }

   if(currentBarIndex - gCouncilAIAdvisoryHold.signature_anchor_bar_index > CouncilAIAdvisorySignatureResetBars())
   {
      InitCouncilAIAdvisoryHoldState(gCouncilAIAdvisoryHold);
      gCouncilAIAdvisoryHoldInitialized = true;
      gCouncilAIAdvisoryHold.candidate_signature = candidateSignature;
      gCouncilAIAdvisoryHold.signature_anchor_bar_index = currentBarIndex;
      gCouncilAIAdvisoryHold.holds_used_for_signature = 0;
   }

   return (gCouncilAIAdvisoryHold.holds_used_for_signature < AICouncilEffectiveHoldLimitPerSignature());
}

void CouncilAIAdvisoryApplyHold(const CouncilAIAdvisoryPacket &packet,
                                const CouncilAIAdvisoryRelevanceGateResult &gate,
                                const string candidateSignature)
{
   CouncilAIAdvisorySyncHoldState();

   int currentBarIndex = Bars(_Symbol, PERIOD_M1);

   if(StringLen(gCouncilAIAdvisoryHold.candidate_signature) <= 0 ||
      gCouncilAIAdvisoryHold.candidate_signature != candidateSignature)
   {
      InitCouncilAIAdvisoryHoldState(gCouncilAIAdvisoryHold);
      gCouncilAIAdvisoryHold.candidate_signature = candidateSignature;
      gCouncilAIAdvisoryHold.signature_anchor_bar_index = currentBarIndex;
   }

   gCouncilAIAdvisoryHold.active = true;
   gCouncilAIAdvisoryHold.decision_id = packet.candidate_decision_id;
   gCouncilAIAdvisoryHold.direction = packet.candidate_direction;
   gCouncilAIAdvisoryHold.advisory_packet_id = packet.advisory_packet_id;
   gCouncilAIAdvisoryHold.hold_reason_code = gate.gate_reason_code;
   gCouncilAIAdvisoryHold.held_at = TimeCurrent();
   gCouncilAIAdvisoryHold.release_bar_index = currentBarIndex + gate.effective_hold_bars;
   gCouncilAIAdvisoryHold.holds_used_for_signature++;
   gCouncilAIAdvisoryHoldInitialized = true;
}

bool EvaluateCouncilAIAdvisoryForCandidate(RoutedRuntimeEvaluation &routed,
                                           TimeframeSnapshot &m1,
                                           RuntimeEvaluation &eval,
                                           const string direction,
                                           CouncilAIAdvisoryPacket &packet,
                                           CouncilAIAdvisoryRelevanceGateResult &gate)
{
   InitCouncilAIAdvisoryPacket(packet);
   InitCouncilAIAdvisoryRelevanceGateResult(gate);

   RequestCouncilAIAdvisoryPacket(routed, m1, eval, direction, packet);
   EvaluateCouncilAIAdvisoryRelevanceGate(packet, gate);

   if(gate.gate_outcome == "HOLD_FOR_REEVALUATION")
   {
      string candidateSignature = CouncilAIAdvisoryBuildCandidateSignature(routed, direction);
      if(CouncilAIAdvisoryCanApplyHold(candidateSignature))
      {
         CouncilAIAdvisoryApplyHold(packet, gate, candidateSignature);
         gate.hold_applied = true;
      }
      else
      {
         gate.gate_outcome = "FLAG_FOR_OPERATOR";
         gate.gate_reason_code = "hold_budget_exhausted_display_only";
         gate.note = "hold_per_signature_limit_reached";
      }
   }

   if(gate.gate_outcome == "BLOCK_CANDIDATE")
      gate.block_applied = true;

   CouncilAIAdvisoryTrackPacket(packet, gate);
   CouncilAIAdvisoryUpdateStatusFromPacketAndGate(packet, gate, "runtime_candidate_evaluation");
   return packet.valid;
}

bool HandleAtasGovernedAdvisoryIntegration(RoutedRuntimeEvaluation &routed,
                                           TimeframeSnapshot &m1,
                                           RuntimeEvaluation &eval,
                                           const string direction)
{
   AtasGovernedAdvisoryPacket packet;
   AtasGovernedAdvisoryGateResult gate;

   EvaluateAtasGovernedAdvisoryForCandidate(
      routed,
      gCurrentDecisionId,
      direction,
      EnableATASGovernedAdvisory,
      AtasGovernedAdvisoryRolloutModeFromInput(ATASAdvisoryRolloutMode),
      ATASAdvisoryHoldBars,
      ATASAdvisoryMaxHoldsPerSignature,
      ATASAdvisoryMinRelevanceScore,
      ATASAdvisoryMinConfluenceScore,
      ATASAdvisoryRequireFreshShadow,
      ATASAdvisoryAllowSemanticOnly,
      ATASAdvisoryLevelNearThresholdPoints,
      ATASAdvisoryRejectionRiskThreshold,
      ATASAdvisoryBreakoutRoomTightThreshold,
      packet,
      gate,
      gAtasGovernedAdvisoryStatus,
      gAtasGovernedAdvisoryEffectiveness,
      gAtasGovernedAdvisoryHold
   );

   gAtasGovernedAdvisoryStatusInitialized = true;
   gAtasGovernedAdvisoryEffectivenessInitialized = true;
   gAtasGovernedAdvisoryHoldInitialized = true;

   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION && gate.hold_applied)
   {
      LogStateOnce("ATAS governed advisory HOLD | decision=" + packet.candidate_decision_id +
                   " | dir=" + direction +
                   " | state=" + AtasGovernedAdvisoryStateToText(packet.advisory_state) +
                   " | reasons=" + packet.advisory_reason_codes_csv +
                   " | relevance=" + DoubleToString(packet.advisory_relevance_score, 2) +
                   " | confluence=" + DoubleToString(packet.advisory_confluence_score, 2));

      DiagnosticRuntimeSeedCycleBase("atas_governed_advisory_hold");
      DiagnosticRuntimeApplyRoutedContext(routed);
      DiagnosticRuntimeSetDecisionId(packet.candidate_decision_id);
      DiagnosticRuntimeSetOutcome(
         direction,
         true,
         "atas_governed_advisory_hold",
         gate.gate_reason_code,
         "HOLD_FOR_REEVALUATION",
         "bounded_atas_governed_advisory_hold"
      );
      SaveDiagnosticRuntimeSummaryBestEffort();

      AppendValidationDecisionJournal(
         routed,
         m1,
         eval,
         true,
         "BLOCKED:ATAS_GOVERNED_ADVISORY_HOLD",
         gate.gate_reason_code,
         direction,
         "atas_governed_advisory_hold",
         gate.gate_reason_code,
         "HOLD_FOR_REEVALUATION"
      );
      RefreshExecutionQualityValidationArtifactsBestEffort();
      return true;
   }

   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR)
   {
      LogStateOnce("ATAS governed advisory FLAG | decision=" + packet.candidate_decision_id +
                   " | dir=" + direction +
                   " | state=" + AtasGovernedAdvisoryStateToText(packet.advisory_state) +
                   " | reasons=" + packet.advisory_reason_codes_csv);
   }
   else if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY)
   {
      LogStateOnce("ATAS governed advisory DISPLAY | decision=" + packet.candidate_decision_id +
                   " | dir=" + direction +
                   " | state=" + AtasGovernedAdvisoryStateToText(packet.advisory_state) +
                   " | reasons=" + packet.advisory_reason_codes_csv);
   }

   return false;
}

bool HandleCouncilAIAdvisoryIntegration(RoutedRuntimeEvaluation &routed,
                                        TimeframeSnapshot &m1,
                                        RuntimeEvaluation &eval,
                                        const string direction)
{
   CouncilAIAdvisoryPacket packet;
   CouncilAIAdvisoryRelevanceGateResult gate;
   EvaluateCouncilAIAdvisoryForCandidate(routed, m1, eval, direction, packet, gate);

   if(gate.gate_outcome == "HOLD_FOR_REEVALUATION" && gate.hold_applied)
   {
      LogStateOnce("Council AI advisory HOLD | decision=" + packet.candidate_decision_id +
                   " | dir=" + direction +
                   " | state=" + packet.advisory_state +
                   " | reasons=" + packet.advisory_reason_codes_csv +
                   " | conf=" + DoubleToString(packet.advisory_confidence, 2) +
                   " | evid=" + DoubleToString(packet.evidence_strength, 2) +
                   " | corr=" + IntegerToString(packet.corroboration_count));

      DiagnosticRuntimeSeedCycleBase("ai_council_advisory_hold");
      DiagnosticRuntimeApplyRoutedContext(routed);
      DiagnosticRuntimeSetDecisionId(packet.candidate_decision_id);
      DiagnosticRuntimeSetOutcome(
         direction,
         true,
         "ai_council_advisory_hold",
         gate.gate_reason_code,
         "HOLD_FOR_REEVALUATION",
         "bounded_ai_council_advisory_hold"
      );
      SaveDiagnosticRuntimeSummaryBestEffort();

      AppendValidationDecisionJournal(
         routed,
         m1,
         eval,
         true,
         "BLOCKED:AI_COUNCIL_ADVISORY_HOLD",
         gate.gate_reason_code,
         direction,
         "ai_council_advisory_hold",
         gate.gate_reason_code,
         "HOLD_FOR_REEVALUATION"
      );
      RefreshExecutionQualityValidationArtifactsBestEffort();
      return true;
   }

   if(gate.gate_outcome == "BLOCK_CANDIDATE" && gate.block_applied)
   {
      LogWarn("Council AI advisory BLOCK | decision=" + packet.candidate_decision_id +
              " | dir=" + direction +
              " | reasons=" + packet.advisory_reason_codes_csv +
              " | conf=" + DoubleToString(packet.advisory_confidence, 2) +
              " | evid=" + DoubleToString(packet.evidence_strength, 2) +
              " | corr=" + IntegerToString(packet.corroboration_count));

      DiagnosticRuntimeSeedCycleBase("ai_council_advisory_block");
      DiagnosticRuntimeApplyRoutedContext(routed);
      DiagnosticRuntimeSetDecisionId(packet.candidate_decision_id);
      DiagnosticRuntimeSetOutcome(
         direction,
         true,
         "ai_council_advisory_block",
         gate.gate_reason_code,
         "BLOCKED_BY_AI_COUNCIL_ADVISORY",
         "bounded_ai_council_advisory_block"
      );
      SaveDiagnosticRuntimeSummaryBestEffort();

      AppendValidationDecisionJournal(
         routed,
         m1,
         eval,
         true,
         "BLOCKED:AI_COUNCIL_ADVISORY_BLOCK",
         gate.gate_reason_code,
         direction,
         "ai_council_advisory_block",
         gate.gate_reason_code,
         "BLOCKED_BY_AI_COUNCIL_ADVISORY"
      );
      RefreshExecutionQualityValidationArtifactsBestEffort();
      return true;
   }

   if(gate.gate_outcome == "FLAG_FOR_OPERATOR")
   {
      LogStateOnce("Council AI advisory FLAG | decision=" + packet.candidate_decision_id +
                   " | dir=" + direction +
                   " | state=" + packet.advisory_state +
                   " | reasons=" + packet.advisory_reason_codes_csv);
   }
   else if(gate.gate_outcome == "DISPLAY_ONLY")
   {
      LogStateOnce("Council AI advisory DISPLAY | decision=" + packet.candidate_decision_id +
                   " | dir=" + direction +
                   " | state=" + packet.advisory_state +
                   " | reasons=" + packet.advisory_reason_codes_csv);
   }

   return false;
}

bool ApplyEmergencyFlatBestEffort(string &logMessage)
{
   logMessage = "";

   if(!RuntimeRiskSafetyEmergencyFlatActive())
   {
      logMessage = "Emergency flat skipped: not active";
      return false;
   }

   trade.SetExpertMagicNumber(Magic);
   trade.SetDeviationInPoints(50);

   int attempted = 0;
   int closed = 0;
   int failed = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      long posMagic = PositionGetInteger(POSITION_MAGIC);
      if(symbol != _Symbol || (ulong)posMagic != Magic)
         continue;

      attempted++;
      if(trade.PositionClose(ticket))
         closed++;
      else
         failed++;
   }

   logMessage = "Emergency flat executed best-effort | state=" + gRuntimeRiskSafety.safety_state +
                " | reason=" + gRuntimeRiskSafety.safety_reason_code +
                " | attempted=" + IntegerToString(attempted) +
                " | closed=" + IntegerToString(closed) +
                " | failed=" + IntegerToString(failed);

   return (attempted > 0);
}

bool RuntimeRiskSafetyLockoutTriggered()
{
   EvaluateRuntimeRiskSafetyState(gRuntimeRiskSafety);
   SaveRuntimeRiskSafetyStatusBestEffort(gRuntimeRiskSafety);
   return (gRuntimeRiskSafety.safety_state == "EXECUTION_FAILURE_LOCKOUT");
}


bool TruthSetJsonStringField(string &json, const string key, const string value)
{
   string tmp = json;
   if(!AE_SetJsonStringField(tmp, key, value, tmp))
      return false;
   json = tmp;
   return true;
}

bool TruthExtractAuthoritativePlanState(const string planJson, string &planId, string &decisionMode)
{
   planId = "";
   decisionMode = "";

   if(!ExtractJsonStringField(planJson, "plan_id", planId))
      return false;

   ExtractJsonStringField(planJson, "decision_engine_mode", decisionMode);

   planId = TrimString(planId);
   decisionMode = TrimString(decisionMode);

   return (StringLen(planId) > 0);
}

bool TruthAnnotatePlanJson(string json, const bool authoritative, const string activePlanId, const string activeDecisionMode, string &outJson)
{
   outJson = NormalizePlanJsonString(json);
   if(StringLen(outJson) <= 0)
      return false;

   string role = (authoritative ? "AUTHORITATIVE_ACTIVE_PLAN" : "NON_AUTHORITATIVE_BACKUP");

   if(!TruthSetJsonStringField(outJson, "truth_role", role))
      return false;
   if(!TruthSetJsonStringField(outJson, "truth_authority_policy", "AI\\ai_current_plan.json_only"))
      return false;
   if(!TruthSetJsonStringField(outJson, "authoritative_plan_file", "AI\\ai_current_plan.json"))
      return false;
   if(!TruthSetJsonStringField(outJson, "active_plan_id", activePlanId))
      return false;
   if(!TruthSetJsonStringField(outJson, "active_decision_engine_mode", activeDecisionMode))
      return false;

   if(!authoritative)
   {
      string snapshotPlanId = "";
      string snapshotDecisionMode = "";
      ExtractJsonStringField(outJson, "plan_id", snapshotPlanId);
      ExtractJsonStringField(outJson, "decision_engine_mode", snapshotDecisionMode);

      TruthSetJsonStringField(outJson, "backup_snapshot_plan_id", TrimString(snapshotPlanId));
      TruthSetJsonStringField(outJson, "backup_snapshot_decision_engine_mode", TrimString(snapshotDecisionMode));
      TruthSetJsonStringField(outJson, "backup_snapshot_note", "rollback_snapshot_only");
   }

   return true;
}

bool TruthAnnotatePlanFile(const string relPath, const bool authoritative, const string activePlanId, const string activeDecisionMode, string &note)
{
   note = "";

   string raw = "";
   if(!ReadTextFileAll(relPath, raw))
   {
      note = "missing " + relPath;
      return (!authoritative);
   }

   string patched = "";
   if(!TruthAnnotatePlanJson(raw, authoritative, activePlanId, activeDecisionMode, patched))
   {
      note = "truth annotate failed for " + relPath;
      return false;
   }

   if(!WriteTextFileAll(relPath, patched))
   {
      note = "truth save failed for " + relPath;
      return false;
   }

   note = (authoritative ? "authoritative " : "backup_non_authoritative ") + relPath;
   return true;
}

bool TruthSyncEvolutionState(const string activePlanId, const string activeDecisionMode, string &note)
{
   note = "";

   AIEvolutionState st;
   if(!LoadAIEvolutionStateFromJson(TruthEvolutionStatePath(), st))
      LoadDefaultEvolutionState(st);

   st.current_plan_id = activePlanId;

   if(!SaveAIEvolutionStateToJson(TruthEvolutionStatePath(), st))
   {
      note = "failed to save " + TruthEvolutionStatePath();
      return false;
   }

   string raw = "";
   if(!ReadTextFileAll(TruthEvolutionStatePath(), raw))
   {
      note = "failed to reload " + TruthEvolutionStatePath();
      return false;
   }

   string patched = TrimString(raw);
   if(StringLen(patched) <= 0)
   {
      note = "empty " + TruthEvolutionStatePath();
      return false;
   }

   if(!TruthSetJsonStringField(patched, "truth_role", "DERIVED_NON_AUTHORITATIVE_STATE"))
      return false;
   if(!TruthSetJsonStringField(patched, "truth_authority_policy", "AI\\ai_current_plan.json_only"))
      return false;
   if(!TruthSetJsonStringField(patched, "authoritative_plan_file", "AI\\ai_current_plan.json"))
      return false;
   if(!TruthSetJsonStringField(patched, "active_plan_id", activePlanId))
      return false;
   if(!TruthSetJsonStringField(patched, "active_decision_engine_mode", activeDecisionMode))
      return false;

   if(!WriteTextFileAll(TruthEvolutionStatePath(), patched))
   {
      note = "failed to annotate " + TruthEvolutionStatePath();
      return false;
   }

   note = "evolution_mirrors plan_id=" + activePlanId + " mode=" + activeDecisionMode;
   return true;
}

bool EnforceAuthoritativePlanTruth(string &logMessage)
{
   logMessage = "";

   string currentPlanJson = "";
   if(!ReadTextFileAll(TruthCurrentPlanPath(), currentPlanJson))
   {
      logMessage = "truth sync failed: missing " + TruthCurrentPlanPath();
      return false;
   }

   string activePlanId = "";
   string activeDecisionMode = "";
   if(!TruthExtractAuthoritativePlanState(currentPlanJson, activePlanId, activeDecisionMode))
   {
      logMessage = "truth sync failed: invalid authoritative plan state";
      return false;
   }

   string noteCurrent = "";
   if(!TruthAnnotatePlanFile(TruthCurrentPlanPath(), true, activePlanId, activeDecisionMode, noteCurrent))
   {
      logMessage = "truth sync failed: " + noteCurrent;
      return false;
   }

   string noteEvolution = "";
   if(!TruthSyncEvolutionState(activePlanId, activeDecisionMode, noteEvolution))
   {
      logMessage = "truth sync failed: " + noteEvolution;
      return false;
   }

   string noteBackup = "";
   TruthAnnotatePlanFile(TruthPreviousPlanBackupPath(), false, activePlanId, activeDecisionMode, noteBackup);

   logMessage =
      "Truth sync complete | authoritative_plan_id=" + activePlanId +
      " | authoritative_mode=" + activeDecisionMode +
      " | " + noteEvolution +
      " | " + noteBackup;

   return true;
}

bool LoadCouncilSetupLifecycleState(CouncilSetupLifecycleState &st)
{
   InitCouncilSetupLifecycleState(st);

   string txt = "";
   if(!ReadTextFileAll(CouncilSetupLifecycleStatePath(), txt))
      return false;

   // Minimal JSON field extraction (best-effort; keeps runtime passive)
   st.active = (StringFind(txt, "\"active\":true") >= 0);

   string v = "";
   if(JA_ExtractJsonString(txt, "state_name", v)) st.state_name = v;
   if(JA_ExtractJsonString(txt, "direction", v))  st.direction  = v;
   if(JA_ExtractJsonString(txt, "decision_id", v)) st.decision_id = v;
   if(JA_ExtractJsonString(txt, "strategy_id", v)) st.strategy_id = v;
   if(JA_ExtractJsonString(txt, "strategy_family", v)) st.strategy_family = v;
   if(JA_ExtractJsonString(txt, "zone_name", v)) st.zone_name = v;
   if(JA_ExtractJsonString(txt, "invalidation_reason", v)) st.invalidation_reason = v;

   ulong u = 0;
   if(JA_ExtractJsonUlong(txt, "created_bar_time", u)) st.created_bar_time = (datetime)u;
   if(JA_ExtractJsonUlong(txt, "last_seen_bar_time", u)) st.last_seen_bar_time = (datetime)u;

   int li = 0;
   if(JA_ExtractJsonInt(txt, "created_bar_index", li)) st.created_bar_index = (int)li;
   if(JA_ExtractJsonInt(txt, "last_seen_bar_index", li)) st.last_seen_bar_index = (int)li;
   if(JA_ExtractJsonInt(txt, "confirmation_bars_seen", li)) st.confirmation_bars_seen = (int)li;
   if(JA_ExtractJsonInt(txt, "expiry_bar_index", li)) st.expiry_bar_index = (int)li;

   double d = 0.0;
   if(JA_ExtractJsonDouble(txt, "council_quality", d)) st.council_quality = d;
   if(JA_ExtractJsonDouble(txt, "consensus_strength", d)) st.consensus_strength = d;
   if(JA_ExtractJsonDouble(txt, "environment_score", d)) st.environment_score = d;

   return true;
}

bool SaveCouncilSetupLifecycleState(const CouncilSetupLifecycleState &st)
{
   string j = "{";
   j += "\"active\":" + (st.active ? "true" : "false");
   j += ",\"state_name\":\"" + JsonEscapeString(st.state_name) + "\"";
   j += ",\"direction\":\"" + JsonEscapeString(st.direction) + "\"";
   j += ",\"decision_id\":\"" + JsonEscapeString(st.decision_id) + "\"";
   j += ",\"strategy_id\":\"" + JsonEscapeString(st.strategy_id) + "\"";
   j += ",\"strategy_family\":\"" + JsonEscapeString(st.strategy_family) + "\"";
   j += ",\"zone_name\":\"" + JsonEscapeString(st.zone_name) + "\"";
   j += ",\"created_bar_time\":" + (string)(ulong)st.created_bar_time;
   j += ",\"last_seen_bar_time\":" + (string)(ulong)st.last_seen_bar_time;
   j += ",\"created_bar_index\":" + (string)st.created_bar_index;
   j += ",\"last_seen_bar_index\":" + (string)st.last_seen_bar_index;
   j += ",\"confirmation_bars_seen\":" + (string)st.confirmation_bars_seen;
   j += ",\"expiry_bar_index\":" + (string)st.expiry_bar_index;
   j += ",\"council_quality\":" + DoubleToString(st.council_quality, 6);
   j += ",\"consensus_strength\":" + DoubleToString(st.consensus_strength, 6);
   j += ",\"environment_score\":" + DoubleToString(st.environment_score, 6);
   j += ",\"invalidation_reason\":\"" + JsonEscapeString(st.invalidation_reason) + "\"";
   j += "}";
   return WriteTextFileAll(CouncilSetupLifecycleStatePath(), j);
}

string BuildCouncilSetupLifecycleStatusText(const CouncilSetupLifecycleState &st)
{
   string t = "";
   t += "active=" + (st.active ? "true" : "false") + "\n";
   t += "state_name=" + st.state_name + "\n";
   t += "direction=" + st.direction + "\n";
   t += "decision_id=" + st.decision_id + "\n";
   t += "strategy_id=" + st.strategy_id + "\n";
   t += "strategy_family=" + st.strategy_family + "\n";
   t += "zone_name=" + st.zone_name + "\n";
   t += "created_bar_time=" + TimeToString(st.created_bar_time, TIME_DATE|TIME_MINUTES) + " (" + (string)st.created_bar_index + ")\n";
   t += "last_seen_bar_time=" + TimeToString(st.last_seen_bar_time, TIME_DATE|TIME_MINUTES) + " (" + (string)st.last_seen_bar_index + ")\n";
   t += "confirmation_bars_seen=" + (string)st.confirmation_bars_seen + "\n";
   t += "expiry_bar_index=" + (string)st.expiry_bar_index + "\n";
   t += "council_quality=" + DoubleToString(st.council_quality, 3) + "\n";
   t += "consensus_strength=" + DoubleToString(st.consensus_strength, 3) + "\n";
   t += "environment_score=" + DoubleToString(st.environment_score, 3) + "\n";
   if(StringLen(st.invalidation_reason) > 0)
      t += "invalidation_reason=" + st.invalidation_reason + "\n";
   return t;
}

void SaveCouncilSetupLifecycleStatusBestEffort()
{
   string txt = BuildCouncilSetupLifecycleStatusText(gCouncilSetupLifecycle);
   WriteTextFileAll(CouncilSetupLifecycleStatusPath(), txt);
}

void LoadCouncilSetupLifecycleStateOnce()
{
   if(gCouncilSetupLifecycleLoaded)
      return;

   InitCouncilSetupLifecycleState(gCouncilSetupLifecycle);
   LoadCouncilSetupLifecycleState(gCouncilSetupLifecycle);
   gCouncilSetupLifecycleLoaded = true;
}

void CouncilLifecycleClearWithFinal(const string final_state, const string reason)
{
   gCouncilSetupLifecycle.active = false;
   gCouncilSetupLifecycle.state_name = final_state;
   gCouncilSetupLifecycle.invalidation_reason = reason;
   SaveCouncilSetupLifecycleState(gCouncilSetupLifecycle);
   SaveCouncilSetupLifecycleStatusBestEffort();
   InitCouncilSetupLifecycleState(gCouncilSetupLifecycle);
}

bool CouncilLifecycleIsDirection(const string dir)
{
   return (dir == "BUY" || dir == "SELL");
}

bool CouncilLifecycleIsCompatibleCandidate(const string dir, const string strategy_id)
{
   if(!CouncilLifecycleIsDirection(dir))
      return false;

   if(gCouncilSetupLifecycle.direction != dir)
      return false;

   if(StringLen(gCouncilSetupLifecycle.strategy_id) <= 0 || StringLen(strategy_id) <= 0)
      return false; // conservative: no loose matching when strategy_id is missing

   return (gCouncilSetupLifecycle.strategy_id == strategy_id);
}

// Returns true if execution should be intercepted (stop here). Returns false to proceed into existing execution path.
bool CouncilLifecycleGateCandidate(
   const string dir,
   const string decision_id,
   const string strategy_id,
   const string zone_name,
   const double council_quality,
   const double consensus_strength,
   const double environment_score,
   const datetime bar_time,
   const int confirm_bars,
   const int expiry_bars)
{
   LoadCouncilSetupLifecycleStateOnce();

   int cb = (confirm_bars < 1 ? 1 : confirm_bars);
   int eb = (expiry_bars < 1 ? 1 : expiry_bars);

   int bar_index = CouncilM1BarIndex(bar_time);

   // Expiry check on active state
   if(gCouncilSetupLifecycle.active && gCouncilSetupLifecycle.expiry_bar_index > 0 && bar_index > gCouncilSetupLifecycle.expiry_bar_index)
   {
      LogStateOnce("Council setup expired before execution");
      CouncilLifecycleClearWithFinal("EXPIRED", "expiry");
      return true;
   }

   // If active but current candidate is incompatible, invalidate.
   if(gCouncilSetupLifecycle.active && !CouncilLifecycleIsCompatibleCandidate(dir, strategy_id))
   {
      LogStateOnce("Council setup invalidated (incompatible candidate)");
      CouncilLifecycleClearWithFinal("INVALIDATED", "incompatible_candidate");
      return true;
   }

   // No active setup -> arm (do not execute on first qualifying cycle)
   if(!gCouncilSetupLifecycle.active)
   {
      InitCouncilSetupLifecycleState(gCouncilSetupLifecycle);
      gCouncilSetupLifecycle.active = true;
      gCouncilSetupLifecycle.state_name = "ARMED";
      gCouncilSetupLifecycle.direction = dir;
      gCouncilSetupLifecycle.decision_id = decision_id;
      gCouncilSetupLifecycle.strategy_id = strategy_id;
      gCouncilSetupLifecycle.strategy_family = LAB_InferFamilyFromStrategyId(strategy_id);
      gCouncilSetupLifecycle.zone_name = zone_name;
      gCouncilSetupLifecycle.created_bar_time = bar_time;
      gCouncilSetupLifecycle.last_seen_bar_time = bar_time;
      gCouncilSetupLifecycle.created_bar_index = bar_index;
      gCouncilSetupLifecycle.last_seen_bar_index = bar_index;
      gCouncilSetupLifecycle.confirmation_bars_seen = 0;
      gCouncilSetupLifecycle.expiry_bar_index = bar_index + eb;
      gCouncilSetupLifecycle.council_quality = council_quality;
      gCouncilSetupLifecycle.consensus_strength = consensus_strength;
      gCouncilSetupLifecycle.environment_score = environment_score;
      gCouncilSetupLifecycle.invalidation_reason = "";

      SaveCouncilSetupLifecycleState(gCouncilSetupLifecycle);
      SaveCouncilSetupLifecycleStatusBestEffort();
      LogStateOnce("Council setup armed: " + dir + " | strategy=" + strategy_id);
      return true; // intercept: do not execute on first qualifying
   }

   // Active ARMED -> confirm only on later bar
   if(gCouncilSetupLifecycle.state_name == "ARMED")
   {
      if(bar_index > gCouncilSetupLifecycle.last_seen_bar_index)
      {
         gCouncilSetupLifecycle.confirmation_bars_seen++;
         gCouncilSetupLifecycle.last_seen_bar_index = bar_index;
         gCouncilSetupLifecycle.last_seen_bar_time = bar_time;

         LogStateOnce("Council setup confirmed: " + (string)gCouncilSetupLifecycle.confirmation_bars_seen + "/" + (string)cb);

         if(gCouncilSetupLifecycle.confirmation_bars_seen >= cb)
         {
            gCouncilSetupLifecycle.state_name = "TRIGGER_READY";
            SaveCouncilSetupLifecycleState(gCouncilSetupLifecycle);
            SaveCouncilSetupLifecycleStatusBestEffort();
            LogStateOnce("Council setup trigger ready: " + dir + " | strategy=" + strategy_id);
            return false; // allow execution now
         }

         SaveCouncilSetupLifecycleState(gCouncilSetupLifecycle);
         SaveCouncilSetupLifecycleStatusBestEffort();
      }

      return true; // still not ready -> intercept
   }

   // TRIGGER_READY -> allow execution
   if(gCouncilSetupLifecycle.state_name == "TRIGGER_READY")
      return false;

   return true;
}

void CouncilLifecycleOnExecutionResult(const bool opened)
{
   // [DORMANT_BRANCH: COUNCIL_SETUP_LIFECYCLE] flag=false; entire execution-result lifecycle handler dormant; coordinate with CouncilLifecycleUpdateOnNonEntryDecision when enabling
   if(!EnableCouncilSetupLifecycle)
      return;

   if(!gCouncilSetupLifecycleLoaded)
      return;

   if(!gCouncilSetupLifecycle.active)
      return;

   if(gCouncilSetupLifecycle.state_name != "TRIGGER_READY")
      return;

   if(opened)
   {
      gCouncilSetupLifecycle.state_name = "EXECUTED";
      SaveCouncilSetupLifecycleStatusBestEffort();
      LogStateOnce("Council setup executed");

      // Persist a cleared inactive state so no stale EXECUTED setup survives reload/restart.
      InitCouncilSetupLifecycleState(gCouncilSetupLifecycle);
      SaveCouncilSetupLifecycleState(gCouncilSetupLifecycle);
   }
}


//---------------------------------------------------------
// Council execution quality gate (opt-in, COUNCIL only)
//---------------------------------------------------------
struct CouncilExecutionQualityAssessment
{
   bool     valid;
   bool     gate_applied;
   bool     pass;
   string   direction;               // BUY / SELL
   string   verdict;                 // PASS / BLOCK / BYPASS
   string   reason_code;             // spread_too_wide / chase_too_extended / quality_score_too_low / atr_unavailable_bypass
   double   quality_score;           // 0..1
   double   entry_quality_score;     // 0..1
   double   execution_geometry_score;// 0..1
   double   spread_points;
   double   atr_points;
   double   spread_atr_fraction;
   double   chase_points;
   double   chase_atr_fraction;
   double   current_bar_extension_points;
   datetime evaluated_bar_time;
};

string CouncilExecutionQualityStatusTxtPath() { return "AI\\council_execution_quality_status.txt"; }
string CouncilExecutionQualityStatusJsonPath(){ return "AI\\council_execution_quality_status.json"; }

double Clamp01(const double x) { return (x < 0.0 ? 0.0 : (x > 1.0 ? 1.0 : x)); }

void InitCouncilExecutionQualityAssessment(CouncilExecutionQualityAssessment &a)
{
   a.valid=false; a.gate_applied=false; a.pass=true;
   a.direction=""; a.verdict="BYPASS"; a.reason_code="";
   a.quality_score=0.50; a.entry_quality_score=0.50; a.execution_geometry_score=0.50;
   a.spread_points=0.0; a.atr_points=0.0; a.spread_atr_fraction=0.0;
   a.chase_points=0.0; a.chase_atr_fraction=0.0; a.current_bar_extension_points=0.0;
   a.evaluated_bar_time=0;
}

string BuildCouncilExecutionQualityStatusText(const CouncilExecutionQualityAssessment &a)
{
   string t="";
   t += "gate_applied=" + (a.gate_applied ? "true" : "false") + "\\n";
   t += "direction=" + a.direction + "\\n";
   t += "verdict=" + a.verdict + "\\n";
   if(StringLen(a.reason_code)>0) t += "reason_code=" + a.reason_code + "\\n";
   t += "quality_score=" + DoubleToString(a.quality_score, 3) + "\\n";
   t += "entry_quality_score=" + DoubleToString(a.entry_quality_score, 3) + "\\n";
   t += "execution_geometry_score=" + DoubleToString(a.execution_geometry_score, 3) + "\\n";
   t += "spread_points=" + DoubleToString(a.spread_points, 1) + "\\n";
   t += "atr_points=" + DoubleToString(a.atr_points, 1) + "\\n";
   t += "spread_atr_fraction=" + DoubleToString(a.spread_atr_fraction, 4) + "\\n";
   t += "chase_points=" + DoubleToString(a.chase_points, 1) + "\\n";
   t += "chase_atr_fraction=" + DoubleToString(a.chase_atr_fraction, 4) + "\\n";
   t += "bar_extension_points=" + DoubleToString(a.current_bar_extension_points, 1) + "\\n";
   t += "evaluated_bar_time=" + TimeToString(a.evaluated_bar_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\\n";
   return t;
}

string BuildCouncilExecutionQualityStatusJson(const CouncilExecutionQualityAssessment &a)
{
   string j="{";
   j += "\"gate_applied\":" + (a.gate_applied ? "true" : "false") + ",";
   j += "\"direction\":\"" + a.direction + "\",";
   j += "\"verdict\":\"" + a.verdict + "\",";
   j += "\"reason_code\":\"" + a.reason_code + "\",";
   j += "\"quality_score\":" + DoubleToString(a.quality_score, 6) + ",";
   j += "\"entry_quality_score\":" + DoubleToString(a.entry_quality_score, 6) + ",";
   j += "\"execution_geometry_score\":" + DoubleToString(a.execution_geometry_score, 6) + ",";
   j += "\"spread_points\":" + DoubleToString(a.spread_points, 2) + ",";
   j += "\"atr_points\":" + DoubleToString(a.atr_points, 2) + ",";
   j += "\"spread_atr_fraction\":" + DoubleToString(a.spread_atr_fraction, 6) + ",";
   j += "\"chase_points\":" + DoubleToString(a.chase_points, 2) + ",";
   j += "\"chase_atr_fraction\":" + DoubleToString(a.chase_atr_fraction, 6) + ",";
   j += "\"bar_extension_points\":" + DoubleToString(a.current_bar_extension_points, 2) + ",";
   j += "\"evaluated_bar_time\":\"" + TimeToString(a.evaluated_bar_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\"";
   j += "}";
   return j;
}

void SaveCouncilExecutionQualityStatusBestEffort(const CouncilExecutionQualityAssessment &a)
{
   WriteTextFileAll(CouncilExecutionQualityStatusTxtPath(),  BuildCouncilExecutionQualityStatusText(a));
   WriteTextFileAll(CouncilExecutionQualityStatusJsonPath(), BuildCouncilExecutionQualityStatusJson(a));
}


//---------------------------------------------------------
// Council activation pressure gate (opt-in, COUNCIL only)
//---------------------------------------------------------
struct CouncilActivationPressureAssessment
{
   bool     valid;
   bool     gate_applied;
   bool     pass;
   string   direction;               // BUY / SELL
   string   verdict;                 // PASS / BLOCK / BYPASS
   string   reason_code;             // no_coverage / weak_coverage_low_consensus / conflicted_coverage_low_consensus / overcrowded_concentration_pressure / data_unavailable_bypass
   string   coverage_label;
   string   coverage_reason;
   string   zone_semantic;
   string   best_strategy_id;
   string   dominant_family;
   int      active_strategies;
   int      aligned_count;
   int      opposing_count;
   double   diversity_score;
   double   concentration_score;
   double   consensus_strength;
   double   environment_score;
   double   activation_pressure_score;   // 0..1 diagnostic only
   datetime evaluated_bar_time;
};

string CouncilActivationPressureStatusTxtPath() { return "AI\\council_activation_pressure_status.txt"; }
string CouncilActivationPressureStatusJsonPath(){ return "AI\\council_activation_pressure_status.json"; }

double ClampRange(const double x, const double lo, const double hi)
{
   if(x < lo) return lo;
   if(x > hi) return hi;
   return x;
}

void InitCouncilActivationPressureAssessment(CouncilActivationPressureAssessment &a)
{
   a.valid=false; a.gate_applied=false; a.pass=true;
   a.direction=""; a.verdict="BYPASS"; a.reason_code="";
   a.coverage_label=""; a.coverage_reason=""; a.zone_semantic="";
   a.best_strategy_id=""; a.dominant_family="";
   a.active_strategies=0; a.aligned_count=0; a.opposing_count=0;
   a.diversity_score=0.0; a.concentration_score=0.0;
   a.consensus_strength=0.0; a.environment_score=0.0;
   a.activation_pressure_score=0.0;
   a.evaluated_bar_time=0;
}

string BuildCouncilActivationPressureStatusText(const CouncilActivationPressureAssessment &a)
{
   string s="";
   s += "council_activation_pressure\n";
   s += "direction=" + a.direction + "\n";
   s += "verdict=" + a.verdict + "\n";
   s += "reason_code=" + a.reason_code + "\n";
   s += "coverage_label=" + a.coverage_label + "\n";
   s += "coverage_reason=" + a.coverage_reason + "\n";
   s += "zone_semantic=" + a.zone_semantic + "\n";
   s += "best_strategy_id=" + a.best_strategy_id + "\n";
   s += "dominant_family=" + a.dominant_family + "\n";
   s += StringFormat("active_strategies=%d\n", a.active_strategies);
   s += StringFormat("aligned_count=%d\n", a.aligned_count);
   s += StringFormat("opposing_count=%d\n", a.opposing_count);
   s += StringFormat("diversity_score=%.3f\n", a.diversity_score);
   s += StringFormat("concentration_score=%.3f\n", a.concentration_score);
   s += StringFormat("consensus_strength=%.3f\n", a.consensus_strength);
   s += StringFormat("environment_score=%.3f\n", a.environment_score);
   s += StringFormat("activation_pressure_score=%.3f\n", a.activation_pressure_score);
   s += "evaluated_bar_time=" + TimeToString(a.evaluated_bar_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\n";
   return s;
}

string BuildCouncilActivationPressureStatusJson(const CouncilActivationPressureAssessment &a)
{
   string j="{";
   j += "\"direction\":\"" + a.direction + "\"";
   j += ",\"verdict\":\"" + a.verdict + "\"";
   j += ",\"reason_code\":\"" + a.reason_code + "\"";
   j += ",\"coverage_label\":\"" + a.coverage_label + "\"";
   j += ",\"coverage_reason\":\"" + a.coverage_reason + "\"";
   j += ",\"zone_semantic\":\"" + a.zone_semantic + "\"";
   j += ",\"best_strategy_id\":\"" + a.best_strategy_id + "\"";
   j += ",\"dominant_family\":\"" + a.dominant_family + "\"";
   j += ",\"active_strategies\":" + IntegerToString(a.active_strategies);
   j += ",\"aligned_count\":" + IntegerToString(a.aligned_count);
   j += ",\"opposing_count\":" + IntegerToString(a.opposing_count);
   j += ",\"diversity_score\":" + DoubleToString(a.diversity_score, 6);
   j += ",\"concentration_score\":" + DoubleToString(a.concentration_score, 6);
   j += ",\"consensus_strength\":" + DoubleToString(a.consensus_strength, 6);
   j += ",\"environment_score\":" + DoubleToString(a.environment_score, 6);
   j += ",\"activation_pressure_score\":" + DoubleToString(a.activation_pressure_score, 6);
   j += ",\"evaluated_bar_time\":\"" + TimeToString(a.evaluated_bar_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\"";
   j += "}";
   return j;
}

void SaveCouncilActivationPressureStatusBestEffort(const CouncilActivationPressureAssessment &a)
{
   WriteTextFileAll(CouncilActivationPressureStatusTxtPath(),  BuildCouncilActivationPressureStatusText(a));
   WriteTextFileAll(CouncilActivationPressureStatusJsonPath(), BuildCouncilActivationPressureStatusJson(a));
}


//---------------------------------------------------------
// Council dirty / transitional environment tightening (opt-in, COUNCIL only)
//---------------------------------------------------------
struct CouncilDirtyEnvironmentAssessment
{
   bool     valid;
   bool     gate_applied;
   bool     pass;
   string   verdict;                    // PASS / BLOCK / BYPASS
   string   reason_code;                // dirty_low_tradability / compression_low_tradability / reversal_risk_low_tradability / dirty_low_environment_score / transitional_low_council_quality / data_unavailable_bypass
   string   regime_label;
   double   regime_confidence;
   double   tradability;
   double   environment_score;
   double   council_quality;
   string   active_mode;
   string   decision_direction;         // BUY / SELL
   string   zone_name;
   string   best_strategy_id;
   datetime evaluated_bar_time;
};

string CouncilDirtyEnvironmentStatusTxtPath() { return "AI\\council_dirty_environment_status.txt"; }
string CouncilDirtyEnvironmentStatusJsonPath(){ return "AI\\council_dirty_environment_status.json"; }

void InitCouncilDirtyEnvironmentAssessment(CouncilDirtyEnvironmentAssessment &a)
{
   a.valid=false; a.gate_applied=false; a.pass=true;
   a.verdict="BYPASS"; a.reason_code="";
   a.regime_label=""; a.regime_confidence=0.0; a.tradability=0.0;
   a.environment_score=0.0; a.council_quality=0.0;
   a.active_mode=""; a.decision_direction=""; a.zone_name=""; a.best_strategy_id="";
   a.evaluated_bar_time=0;
}

string BuildCouncilDirtyEnvironmentStatusText(const CouncilDirtyEnvironmentAssessment &a)
{
   string s="";
   s += "council_dirty_environment\n";
   s += "verdict=" + a.verdict + "\n";
   s += "reason_code=" + a.reason_code + "\n";
   s += "regime_label=" + a.regime_label + "\n";
   s += StringFormat("regime_confidence=%.3f\n", a.regime_confidence);
   s += StringFormat("tradability=%.3f\n", a.tradability);
   s += StringFormat("environment_score=%.3f\n", a.environment_score);
   s += StringFormat("council_quality=%.3f\n", a.council_quality);
   s += "active_mode=" + a.active_mode + "\n";
   s += "direction=" + a.decision_direction + "\n";
   s += "zone_name=" + a.zone_name + "\n";
   s += "best_strategy_id=" + a.best_strategy_id + "\n";
   s += "evaluated_bar_time=" + TimeToString(a.evaluated_bar_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\n";
   return s;
}

string BuildCouncilDirtyEnvironmentStatusJson(const CouncilDirtyEnvironmentAssessment &a)
{
   string j="{";
   j += "\"verdict\":\"" + a.verdict + "\"";
   j += ",\"reason_code\":\"" + a.reason_code + "\"";
   j += ",\"regime_label\":\"" + a.regime_label + "\"";
   j += ",\"regime_confidence\":" + DoubleToString(a.regime_confidence, 6);
   j += ",\"tradability\":" + DoubleToString(a.tradability, 6);
   j += ",\"environment_score\":" + DoubleToString(a.environment_score, 6);
   j += ",\"council_quality\":" + DoubleToString(a.council_quality, 6);
   j += ",\"active_mode\":\"" + a.active_mode + "\"";
   j += ",\"direction\":\"" + a.decision_direction + "\"";
   j += ",\"zone_name\":\"" + JsonEscapeString(a.zone_name) + "\"";
   j += ",\"best_strategy_id\":\"" + a.best_strategy_id + "\"";
   j += ",\"evaluated_bar_time\":\"" + TimeToString(a.evaluated_bar_time, TIME_DATE|TIME_MINUTES|TIME_SECONDS) + "\"";
   j += "}";
   return j;
}

void SaveCouncilDirtyEnvironmentStatusBestEffort(const CouncilDirtyEnvironmentAssessment &a)
{
   WriteTextFileAll(CouncilDirtyEnvironmentStatusTxtPath(),  BuildCouncilDirtyEnvironmentStatusText(a));
   WriteTextFileAll(CouncilDirtyEnvironmentStatusJsonPath(), BuildCouncilDirtyEnvironmentStatusJson(a));
}

void EvaluateCouncilDirtyEnvironmentTightening(const RoutedRuntimeEvaluation &routed,
                                              const string direction,
                                              CouncilDirtyEnvironmentAssessment &out)
{
   InitCouncilDirtyEnvironmentAssessment(out);
   out.active_mode = routed.active_mode;
   out.decision_direction = direction;
   out.evaluated_bar_time = iTime(_Symbol, PERIOD_M1, 0);

   // Clamp thresholds safely
   const double dirtyTradFloor   = ClampRange(CouncilDirtyTradabilityFloor,           0.0, 1.0);
   const double compTradFloor    = ClampRange(CouncilCompressionTradabilityFloor,     0.0, 1.0);
   const double revTradFloor     = ClampRange(CouncilReversalRiskTradabilityFloor,    0.0, 1.0);
   const double dirtyEnvMin      = ClampRange(CouncilDirtyMinEnvironmentScore,        0.0, 1.0);
   const double transCouncilQMin = ClampRange(CouncilTransitionalMinCouncilQuality,   0.0, 1.0);

   // Fail-open if essential data is unavailable
   const string regime = gRegime.regime_label;
   const double conf   = gRegime.regime_confidence;
   const double trad   = gRegime.tradability_score;

   if(StringLen(regime) < 1 || !MathIsValidNumber(trad) || trad < 0.0)
   {
      out.valid=false;
      out.gate_applied=false;
      out.pass=true;
      out.verdict="BYPASS";
      out.reason_code="data_unavailable_bypass";
      return;
   }

   if(routed.active_mode != "COUNCIL" || !routed.council.valid)
   {
      out.valid=false;
      out.gate_applied=false;
      out.pass=true;
      out.verdict="BYPASS";
      out.reason_code="data_unavailable_bypass";
      return;
   }

   const double envScore = routed.council.aggregate.environment_score;
   const double councilQ = routed.council.aggregate.council_quality;

   if(!MathIsValidNumber(envScore) || envScore < 0.0 || !MathIsValidNumber(councilQ) || councilQ < 0.0)
   {
      out.valid=false;
      out.gate_applied=false;
      out.pass=true;
      out.verdict="BYPASS";
      out.reason_code="data_unavailable_bypass";
      return;
   }

   out.valid=true;
   out.gate_applied=true;
   out.regime_label=regime;
   out.regime_confidence=conf;
   out.tradability=trad;
   out.environment_score=envScore;
   out.council_quality=councilQ;
   out.best_strategy_id = routed.council.aggregate.best_strategy_id;
   out.zone_name = routed.council.zone_coverage.zone_semantic;

   // Apply conservative block rules only for clearly dirty / transitional states
   if(regime == "RANGE_DIRTY" && trad < dirtyTradFloor)
   {
      out.pass=false; out.verdict="BLOCK"; out.reason_code="dirty_low_tradability"; return;
   }
   if(regime == "COMPRESSION" && trad < compTradFloor)
   {
      out.pass=false; out.verdict="BLOCK"; out.reason_code="compression_low_tradability"; return;
   }
   if(regime == "REVERSAL_RISK" && trad < revTradFloor)
   {
      out.pass=false; out.verdict="BLOCK"; out.reason_code="reversal_risk_low_tradability"; return;
   }
   if(regime == "RANGE_DIRTY" && envScore < dirtyEnvMin)
   {
      out.pass=false; out.verdict="BLOCK"; out.reason_code="dirty_low_environment_score"; return;
   }
   if((regime == "RANGE_DIRTY" || regime == "COMPRESSION" || regime == "REVERSAL_RISK") && councilQ < transCouncilQMin)
   {
      out.pass=false; out.verdict="BLOCK"; out.reason_code="transitional_low_council_quality"; return;
   }

   out.pass=true;
   out.verdict="PASS";
   out.reason_code="";
}

string InferDominantFamilyFromStrategyId(const string sid)
{
   if(StringLen(sid) < 1) return "";
   int p = StringFind(sid, ":");
   if(p > 0) return StringSubstr(sid, 0, p);
   p = StringFind(sid, "_");
   if(p > 0) return StringSubstr(sid, 0, p);
   return "";
}

void EvaluateCouncilActivationPressure(const RoutedRuntimeEvaluation &routed, const string direction, CouncilActivationPressureAssessment &out)
{
   InitCouncilActivationPressureAssessment(out);
   out.direction = direction;
   out.evaluated_bar_time = iTime(_Symbol, PERIOD_M1, 0);

   // Clamp thresholds safely
   double minWeak   = ClampRange(CouncilMinConsensusForWeakCoverage,          0.30, 1.00);
   double minConf   = ClampRange(CouncilMinConsensusForConflictedCoverage,    0.30, 1.00);
   double minCrowd  = ClampRange(CouncilMinConsensusToAllowCrowdedActivation, 0.30, 1.00);
   double maxConc   = ClampRange(CouncilMaxCrowdingConcentration,             0.50, 1.00);

   string label = routed.council.zone_coverage.coverage_label;
   if(StringLen(label) < 1)
   {
      out.valid = false;
      out.gate_applied = false;
      out.pass = true;
      out.verdict = "BYPASS";
      out.reason_code = "data_unavailable_bypass";
      return;
   }

   out.valid = true;
   out.gate_applied = true;

   out.coverage_label = label;
   out.coverage_reason = routed.council.zone_coverage.coverage_reason;
   out.zone_semantic = routed.council.zone_coverage.zone_semantic;

   out.best_strategy_id = routed.council.aggregate.best_strategy_id;
   out.dominant_family  = (StringLen(routed.council.zone_coverage.dominant_family) > 0
                           ? routed.council.zone_coverage.dominant_family
                           : InferDominantFamilyFromStrategyId(out.best_strategy_id));

   out.active_strategies    = routed.council.zone_coverage.active_strategies;
   out.aligned_count        = routed.council.zone_coverage.aligned_count;
   out.opposing_count       = routed.council.zone_coverage.opposing_count;
   out.diversity_score      = Clamp01(routed.council.zone_coverage.diversity_score);
   out.concentration_score  = Clamp01(routed.council.zone_coverage.concentration_score);

   out.consensus_strength   = Clamp01(routed.council.aggregate.consensus_strength);
   out.environment_score    = Clamp01(routed.council.aggregate.environment_score);

   double conflict_pressure = ((out.opposing_count > 0 && out.aligned_count > 0) ? 1.0 : 0.0);
   double inverse_diversity = 1.0 - out.diversity_score;

   out.activation_pressure_score = Clamp01(0.45*out.concentration_score + 0.35*inverse_diversity + 0.20*conflict_pressure);

   string ulabel = label;
   StringToUpper(ulabel);

   // Apply conservative rules with first-fail reasoning
   out.pass = true;
   out.verdict = "PASS";
   out.reason_code = "";

   if(ulabel == "NO_COVERAGE")
   {
      out.pass = false; out.verdict="BLOCK"; out.reason_code="no_coverage"; return;
   }

   if(ulabel == "WEAK" && out.consensus_strength < minWeak)
   {
      out.pass = false; out.verdict="BLOCK"; out.reason_code="weak_coverage_low_consensus"; return;
   }

   if(ulabel == "CONFLICTED" && out.consensus_strength < minConf)
   {
      out.pass = false; out.verdict="BLOCK"; out.reason_code="conflicted_coverage_low_consensus"; return;
   }

   if(ulabel == "OVERCROWDED" && out.concentration_score > maxConc && out.consensus_strength < minCrowd)
   {
      out.pass = false; out.verdict="BLOCK"; out.reason_code="overcrowded_concentration_pressure"; return;
   }
}
void EvaluateCouncilExecutionQuality(const TimeframeSnapshot &m1, const string direction, CouncilExecutionQualityAssessment &out)
{
   InitCouncilExecutionQualityAssessment(out);
   out.direction = direction;
   out.evaluated_bar_time = iTime(_Symbol, PERIOD_M1, 0);

   // Clamp thresholds safely (runtime clamp; keeps inputs passive)
   double minScore = CouncilExecutionQualityMinScore;
   if(minScore < 0.0) minScore = 0.0;
   if(minScore > 1.0) minScore = 1.0;

   double maxSpreadFrac = CouncilMaxSpreadAtrFraction;
   if(maxSpreadFrac < 0.01) maxSpreadFrac = 0.01;
   if(maxSpreadFrac > 1.0)  maxSpreadFrac = 1.0;

   double maxChaseFrac = CouncilMaxChaseAtrFraction;
   if(maxChaseFrac < 0.01) maxChaseFrac = 0.01;
   if(maxChaseFrac > 2.0)  maxChaseFrac = 2.0;

   out.spread_points = m1.spread_points;

   double atr=0.0;
   if(!MR_GetATR(PERIOD_M5, 14, 1, atr) || atr <= 0.0)
   {
      out.valid=false;
      out.gate_applied=false;
      out.pass=true;
      out.verdict="BYPASS";
      out.reason_code="atr_unavailable_bypass";
      out.quality_score=0.50;
      return;
   }

   out.atr_points = atr / _Point;
   if(out.atr_points <= 0.0)
   {
      out.valid=false;
      out.gate_applied=false;
      out.pass=true;
      out.verdict="BYPASS";
      out.reason_code="atr_unavailable_bypass";
      out.quality_score=0.50;
      return;
   }

   out.gate_applied=true;
   out.valid=true;

   out.spread_atr_fraction = out.spread_points / out.atr_points;

   double m1Open = iOpen(_Symbol, PERIOD_M1, 0);
   if(direction == "BUY")
   {
      double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
      out.current_bar_extension_points = MathMax((ask - m1Open) / _Point, 0.0);
   }
   else
   {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      out.current_bar_extension_points = MathMax((m1Open - bid) / _Point, 0.0);
   }
   out.chase_points = out.current_bar_extension_points;
   out.chase_atr_fraction = out.chase_points / out.atr_points;

   // Existing quality inputs (best-effort)
   out.entry_quality_score = 0.50;
   if(gHasStrategyIntel)
      out.entry_quality_score = Clamp01(gEntryQuality.entry_quality_score);

   out.execution_geometry_score = 0.50;
   if(gHasExecEstimation)
      out.execution_geometry_score = Clamp01(gExecEstimation.execution_geometry_score);

   // Simple bounded inverse-pressure transforms
   double spreadScore = 1.0 - Clamp01(out.spread_atr_fraction / maxSpreadFrac);
   double chaseScore  = 1.0 - Clamp01(out.chase_atr_fraction  / maxChaseFrac);

   // Conservative composite quality score
   out.quality_score = Clamp01(
      0.35 * out.execution_geometry_score +
      0.30 * out.entry_quality_score +
      0.20 * spreadScore +
      0.15 * chaseScore
   );

   // First-fail conservative blocking logic
   if(out.spread_atr_fraction > maxSpreadFrac)
   {
      out.pass=false;
      out.verdict="BLOCK";
      out.reason_code="spread_too_wide";
      return;
   }
   if(out.chase_atr_fraction > maxChaseFrac)
   {
      out.pass=false;
      out.verdict="BLOCK";
      out.reason_code="chase_too_extended";
      return;
   }
   if(out.quality_score < minScore)
   {
      out.pass=false;
      out.verdict="BLOCK";
      out.reason_code="quality_score_too_low";
      return;
   }

   out.pass=true;
   out.verdict="PASS";
   out.reason_code="";
}


void CouncilLifecycleUpdateOnNonEntryDecision(const string active_mode, const int eval_decision, const string current_strategy_id, const datetime bar_time)
{
   // [DORMANT_BRANCH: COUNCIL_SETUP_LIFECYCLE] flag=false; entire non-entry lifecycle update handler dormant; coordinate with CouncilLifecycleOnExecutionResult when enabling
   if(!EnableCouncilSetupLifecycle)
      return;

   if(active_mode != "COUNCIL")
      return;

   LoadCouncilSetupLifecycleStateOnce();

   if(!gCouncilSetupLifecycle.active)
      return;

   int bar_index = CouncilM1BarIndex(bar_time);

   if(gCouncilSetupLifecycle.expiry_bar_index > 0 && bar_index > gCouncilSetupLifecycle.expiry_bar_index)
   {
      LogStateOnce("Council setup expired (non-entry cycle)");
      CouncilLifecycleClearWithFinal("EXPIRED", "expiry");
      return;
   }

   // Any non-entry decision invalidates, as required (WAIT/REJECT/non-entry)
   if(eval_decision != RUNTIME_ENTER_BUY && eval_decision != RUNTIME_ENTER_SELL)
   {
      LogStateOnce("Council setup invalidated (non-entry decision)");
      CouncilLifecycleClearWithFinal("INVALIDATED", "non_entry_decision");
      return;
   }

   // Flip invalidation (if this function is called defensively elsewhere)
   string dir = (eval_decision == RUNTIME_ENTER_BUY ? "BUY" : "SELL");
   if(gCouncilSetupLifecycle.direction != dir)
   {
      LogStateOnce("Council setup invalidated (direction flip)");
      CouncilLifecycleClearWithFinal("INVALIDATED", "direction_flip");
      return;
   }

   // Strategy incompatibility invalidation
   if(StringLen(gCouncilSetupLifecycle.strategy_id) > 0 && StringLen(current_strategy_id) > 0 && gCouncilSetupLifecycle.strategy_id != current_strategy_id)
   {
      LogStateOnce("Council setup invalidated (strategy changed)");
      CouncilLifecycleClearWithFinal("INVALIDATED", "strategy_changed");
      return;
   }
}



RegimePerformanceSummary gRegimePerf;
bool                    gHasRegimePerf = false;

RollbackSignal      gRollbackSignal;
bool                gHasRollbackSignal = false;

datetime gLastM1BarTime           = 0;
int      gM1BarCounter            = 0;
int      gLastEvolutionBar        = -100000;
datetime gLastRuntimeTradeBarTime = 0;
int      gLastRuntimeEntryBars    = -100000;

//---------------------------------------------------------
// Forward declarations
//---------------------------------------------------------
bool FinalizeCouncilClosedTrade(
   ulong magic,
   string symbol,
   string feedbackPath,
   string &logMessage
);

//---------------------------------------------------------
// Bar helpers
//---------------------------------------------------------
bool IsNewM1Bar()
{
   datetime t = iTime(_Symbol, PERIOD_M1, 0);
   if(t != gLastM1BarTime)
   {
      gLastM1BarTime = t;
      return true;
   }
   return false;
}

bool CanAttemptRuntimeTradeThisBar()
{
   datetime barTime = iTime(_Symbol, PERIOD_M1, 0);
   return (barTime != gLastRuntimeTradeBarTime);
}

void MarkRuntimeTradeAttemptedThisBar()
{
   gLastRuntimeTradeBarTime = iTime(_Symbol, PERIOD_M1, 0);
}

void MarkRuntimeTradeExecutedNow()
{
   gLastRuntimeTradeBarTime = iTime(_Symbol, PERIOD_M1, 0);
   gLastRuntimeEntryBars    = Bars(_Symbol, PERIOD_M1);
}

//---------------------------------------------------------
// Fresh proposal guards
//---------------------------------------------------------
bool CurrentProposalLooksNew(string currentPlanPath, string proposalPath)
{
   string currentJson  = "";
   string proposalJson = "";
   if(!LoadTextFile(currentPlanPath, currentJson))
      return false;
   if(!LoadTextFile(proposalPath, proposalJson))
      return false;

   currentJson  = TrimString(currentJson);
   proposalJson = TrimString(proposalJson);

   if(StringLen(proposalJson) < 50)
      return false;

   if(currentJson == proposalJson)
      return false;

   string currentPlanId  = "";
   string proposalPlanId = "";

   ExtractJsonStringField(currentJson, "plan_id", currentPlanId);
   ExtractJsonStringField(proposalJson, "plan_id", proposalPlanId);

   currentPlanId  = TrimString(currentPlanId);
   proposalPlanId = TrimString(proposalPlanId);

   if(StringLen(proposalPlanId) <= 0)
      return false;

   if(currentPlanId == proposalPlanId)
      return false;

   return true;
}

bool EvolutionProducedFreshProposal(string evoLog)
{
   return (StringFind(evoLog, "Evolution proposal saved:") >= 0);
}

//---------------------------------------------------------
// Logging helpers for experimental architecture
//---------------------------------------------------------
void LogPlanArchitectureSummary()
{
   LogInfo("Loaded plan: " + gPlan.plan_id);
   LogInfo("Main trigger: " + gPlan.main_trigger_name);

   LogInfo("Plan mode: " + gPlan.plan_mode +
           " | Decision engine: " + gPlan.decision_engine_mode +
           " | Archetype: " + gPlan.execution_archetype);

   LogInfo("Experiment family: " + gPlan.experiment_family);
   LogInfo("Bias direction: " + gPlan.bias_direction +
" | Soft filters: " + (gPlan.use_soft_filters ? "true" : "false") +
" | Hard blocks: " + (gPlan.use_hard_blocks ? "true" : "false"));

LogInfo("Triggerless entry: " + (gPlan.allow_triggerless_entry ? "true" : "false") +
" | Require main trigger: " + (gPlan.require_main_trigger ? "true" : "false"));

   LogInfo("Score entry threshold: " + DoubleToString(gPlan.score_entry_threshold, 2) +
           " | Score reject threshold: " + DoubleToString(gPlan.score_reject_threshold, 2));
}

void LogCompiledArchitectureSummary()
{
   LogInfo("Compiled runtime ready | plan_mode=" + gCompiledPlan.plan_mode +
           " | decision_engine_mode=" + gCompiledPlan.decision_engine_mode +
           " | experiment_family=" + gCompiledPlan.experiment_family);
}

//---------------------------------------------------------
// Position/session hardening helpers
//---------------------------------------------------------
int CountMyOpenPositions()
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC) == Magic)
      {
         count++;
      }
   }

   return count;
}

int CountMyDirectionPositions(long posType)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC) == Magic &&
         PositionGetInteger(POSITION_TYPE) == posType)
      {
         count++;
      }
   }

   return count;
}

datetime GetSessionStartTime()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;

   return StructToTime(dt);
}

int CountSessionNewEntries()
{
   datetime fromTime = GetSessionStartTime();
   datetime toTime   = TimeCurrent();

   if(!HistorySelect(fromTime, toTime))
      return 0;

   int count = 0;
   int total = HistoryDealsTotal();

   for(int i = total - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;

      string symbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      long   magic  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      long   entry  = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

      bool isSessionEntry = (entry == DEAL_ENTRY_IN || entry == DEAL_ENTRY_INOUT);

      if(symbol == _Symbol &&
         (ulong)magic == Magic &&
         isSessionEntry)
      {
         count++;
      }
   }

   return count;
}

//---------------------------------------------------------
// Smart session helpers
//---------------------------------------------------------
void BuildSessionWinLossStats(int &wins, int &losses, int &closedTrades)
{
   wins = 0;
   losses = 0;
   closedTrades = 0;

   datetime fromTime = GetSessionStartTime();
   datetime toTime   = TimeCurrent();

   if(!HistorySelect(fromTime, toTime))
      return;

   int total = HistoryDealsTotal();

   for(int i = total - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;

      string symbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      long   magic  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      long   entry  = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

      if(symbol != _Symbol || (ulong)magic != Magic || entry != DEAL_ENTRY_OUT)
         continue;

      double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);

      if(profit > 0.0)
         wins++;
      else if(profit < 0.0)
         losses++;

      closedTrades++;
   }
}

double ComputeSessionWinRate()
{
   int wins = 0;
   int losses = 0;
   int closedTrades = 0;

   BuildSessionWinLossStats(wins, losses, closedTrades);

   int decisiveTrades = wins + losses;
   if(decisiveTrades <= 0)
      return 0.0;

   return (100.0 * wins) / decisiveTrades;
}

int ComputeSmartSessionCap()
{
   int baseCap = gPlan.max_trades_per_session;

   if(baseCap <= 0)
      return 0;

   int wins = 0;
   int losses = 0;
   int closedTrades = 0;

   BuildSessionWinLossStats(wins, losses, closedTrades);

   if(closedTrades < 5)
      return baseCap;

   double winRate = ComputeSessionWinRate();
   int smartCap = baseCap;

   if(winRate >= 65.0)
      smartCap = baseCap + 10;
   else if(winRate >= 55.0)
      smartCap = baseCap + 5;
   else if(winRate <= 30.0)
      smartCap = 5;
   else if(winRate <= 40.0)
      smartCap = baseCap - 5;

   if(smartCap < 5)
      smartCap = 5;

   return smartCap;
}

bool CooldownAllowsNewTrade(string &reason)
{
   reason = "";

   if(gPlan.cooldown_bars <= 0)
      return true;

   int currentBars = Bars(_Symbol, PERIOD_M1);
   int barsSinceLastEntry = currentBars - gLastRuntimeEntryBars;

   if(barsSinceLastEntry <= gPlan.cooldown_bars)
   {
      reason = "Cooldown active: barsSinceLastEntry=" +
               IntegerToString(barsSinceLastEntry) +
               " <= cooldown_bars=" +
               IntegerToString(gPlan.cooldown_bars);
      return false;
   }

   // Strategy Intelligence / Decision Quality policy hooks (optional, conservative)
   if(gPlan.decision_quality_policy_enabled && gPlan.strategy_intelligence_enabled && gHasStrategyIntel)
   {
      if(gPlan.minimum_entry_quality_score > 0.0 && gEntryQuality.entry_quality_score < gPlan.minimum_entry_quality_score)
      {
         reason = "dq_policy_entry_quality_below_min";
         return false;
      }

      if(gPlan.minimum_strategy_regime_fit_score > 0.0 && gStrategyFit.strategy_regime_fit_score < gPlan.minimum_strategy_regime_fit_score)
      {
         reason = "dq_policy_regime_fit_below_min";
         return false;
      }

      if(gPlan.minimum_entry_edge_score > 0.0 && gEntryEdge.entry_edge_score < gPlan.minimum_entry_edge_score)
      {
         reason = "dq_policy_entry_edge_below_min";
         return false;
      }

      if(gPlan.minimum_follow_through_quality_score > 0.0 && gFollowThrough.follow_through_quality_score < gPlan.minimum_follow_through_quality_score)
      {
         reason = "dq_policy_follow_through_below_min";
         return false;
      }

      if(gHasExecEstimation)
      {
         if(gPlan.minimum_execution_geometry_score > 0.0 && gExecEstimation.execution_geometry_score < gPlan.minimum_execution_geometry_score)
         {
            reason = "dq_policy_execution_geometry_below_min";
            return false;
         }

         if(gPlan.minimum_expected_rr_estimate > 0.0 && gExecEstimation.expected_rr_estimate < gPlan.minimum_expected_rr_estimate)
         {
            reason = "dq_policy_expected_rr_below_min";
            return false;
         }

         if(gPlan.block_adverse_execution_geometry)
         {
            if(gExecEstimation.execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY" || gExecEstimation.execution_geometry_label == "POOR_EXECUTION_GEOMETRY")
            {
               reason = "dq_policy_adverse_execution_geometry";
               return false;
            }
         }
      }

      if(gPlan.block_poor_entries)
      {
         if(gEntryQuality.entry_quality_label == "POOR_ENTRY" || gEntryQuality.entry_quality_label == "NO_ENTRY_EDGE")
         {
            reason = "dq_policy_block_poor_entry_label";
            return false;
         }
      }

      if(gPlan.block_negative_entry_edge)
      {
         if(gEntryEdge.entry_edge_label == "NEGATIVE_ENTRY_EDGE")
         {
            reason = "dq_policy_block_negative_entry_edge";
            return false;
         }
      }
   }

   return true;
}

bool SessionAllowsNewTrade(string &reason)
{
   reason = "";

   if(gPlan.max_trades_per_session <= 0)
      return true;

   int sessionClosed = CountSessionNewEntries();
   int smartCap      = ComputeSmartSessionCap();

   if(sessionClosed >= smartCap)
   {
      double winRate = ComputeSessionWinRate();

      reason = "Session cap reached (smart): " +
               IntegerToString(sessionClosed) +
               "/" +
               IntegerToString(smartCap) +
               " | baseCap=" +
               IntegerToString(gPlan.max_trades_per_session) +
               " | winRate=" +
               DoubleToString(winRate, 1) + "%";

      return false;
   }

   // Strategy Intelligence / Decision Quality policy hooks (optional, conservative)
   if(gPlan.decision_quality_policy_enabled && gPlan.strategy_intelligence_enabled && gHasStrategyIntel)
   {
      if(gPlan.minimum_entry_quality_score > 0.0 && gEntryQuality.entry_quality_score < gPlan.minimum_entry_quality_score)
      {
         reason = "dq_policy_entry_quality_below_min";
         return false;
      }

      if(gPlan.minimum_strategy_regime_fit_score > 0.0 && gStrategyFit.strategy_regime_fit_score < gPlan.minimum_strategy_regime_fit_score)
      {
         reason = "dq_policy_regime_fit_below_min";
         return false;
      }

      if(gPlan.minimum_entry_edge_score > 0.0 && gEntryEdge.entry_edge_score < gPlan.minimum_entry_edge_score)
      {
         reason = "dq_policy_entry_edge_below_min";
         return false;
      }

      if(gPlan.minimum_follow_through_quality_score > 0.0 && gFollowThrough.follow_through_quality_score < gPlan.minimum_follow_through_quality_score)
      {
         reason = "dq_policy_follow_through_below_min";
         return false;
      }

      if(gHasExecEstimation)
      {
         if(gPlan.minimum_execution_geometry_score > 0.0 && gExecEstimation.execution_geometry_score < gPlan.minimum_execution_geometry_score)
         {
            reason = "dq_policy_execution_geometry_below_min";
            return false;
         }

         if(gPlan.minimum_expected_rr_estimate > 0.0 && gExecEstimation.expected_rr_estimate < gPlan.minimum_expected_rr_estimate)
         {
            reason = "dq_policy_expected_rr_below_min";
            return false;
         }

         if(gPlan.block_adverse_execution_geometry)
         {
            if(gExecEstimation.execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY" || gExecEstimation.execution_geometry_label == "POOR_EXECUTION_GEOMETRY")
            {
               reason = "dq_policy_adverse_execution_geometry";
               return false;
            }
         }
      }

      if(gPlan.block_poor_entries)
      {
         if(gEntryQuality.entry_quality_label == "POOR_ENTRY" || gEntryQuality.entry_quality_label == "NO_ENTRY_EDGE")
         {
            reason = "dq_policy_block_poor_entry_label";
            return false;
         }
      }

      if(gPlan.block_negative_entry_edge)
      {
         if(gEntryEdge.entry_edge_label == "NEGATIVE_ENTRY_EDGE")
         {
            reason = "dq_policy_block_negative_entry_edge";
            return false;
         }
      }
   }

   return true;
}

bool CapacityAllowsNewTrade(CoreDirection dir, string &reason)
{
   reason = "";

   int openCount = CountMyOpenPositions();
   if(openCount >= gPlan.max_open_positions)
   {
      reason = "Max open positions reached: " +
               IntegerToString(openCount) +
               "/" +
               IntegerToString(gPlan.max_open_positions);
      return false;
   }

   if(gPlan.one_direction_only)
   {
      if(dir == CORE_BUY && CountMyDirectionPositions(POSITION_TYPE_BUY) > 0)
      {
         reason = "OneDirectionOnly blocks additional BUY";
         return false;
      }

      if(dir == CORE_SELL && CountMyDirectionPositions(POSITION_TYPE_SELL) > 0)
      {
         reason = "OneDirectionOnly blocks additional SELL";
         return false;
      }
   }

   // Strategy Intelligence / Decision Quality policy hooks (optional, conservative)
   if(gPlan.decision_quality_policy_enabled && gPlan.strategy_intelligence_enabled && gHasStrategyIntel)
   {
      if(gPlan.minimum_entry_quality_score > 0.0 && gEntryQuality.entry_quality_score < gPlan.minimum_entry_quality_score)
      {
         reason = "dq_policy_entry_quality_below_min";
         return false;
      }

      if(gPlan.minimum_strategy_regime_fit_score > 0.0 && gStrategyFit.strategy_regime_fit_score < gPlan.minimum_strategy_regime_fit_score)
      {
         reason = "dq_policy_regime_fit_below_min";
         return false;
      }

      if(gPlan.minimum_entry_edge_score > 0.0 && gEntryEdge.entry_edge_score < gPlan.minimum_entry_edge_score)
      {
         reason = "dq_policy_entry_edge_below_min";
         return false;
      }

      if(gPlan.minimum_follow_through_quality_score > 0.0 && gFollowThrough.follow_through_quality_score < gPlan.minimum_follow_through_quality_score)
      {
         reason = "dq_policy_follow_through_below_min";
         return false;
      }

      if(gHasExecEstimation)
      {
         if(gPlan.minimum_execution_geometry_score > 0.0 && gExecEstimation.execution_geometry_score < gPlan.minimum_execution_geometry_score)
         {
            reason = "dq_policy_execution_geometry_below_min";
            return false;
         }

         if(gPlan.minimum_expected_rr_estimate > 0.0 && gExecEstimation.expected_rr_estimate < gPlan.minimum_expected_rr_estimate)
         {
            reason = "dq_policy_expected_rr_below_min";
            return false;
         }

         if(gPlan.block_adverse_execution_geometry)
         {
            if(gExecEstimation.execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY" || gExecEstimation.execution_geometry_label == "POOR_EXECUTION_GEOMETRY")
            {
               reason = "dq_policy_adverse_execution_geometry";
               return false;
            }
         }
      }

      if(gPlan.block_poor_entries)
      {
         if(gEntryQuality.entry_quality_label == "POOR_ENTRY" || gEntryQuality.entry_quality_label == "NO_ENTRY_EDGE")
         {
            reason = "dq_policy_block_poor_entry_label";
            return false;
         }
      }

      if(gPlan.block_negative_entry_edge)
      {
         if(gEntryEdge.entry_edge_label == "NEGATIVE_ENTRY_EDGE")
         {
            reason = "dq_policy_block_negative_entry_edge";
            return false;
         }
      }
   }

   return true;
}

bool RuntimePolicyAllowsTrade(CoreDirection dir, string &reason)
{
   reason = "";

   bool cohortGovernedAuthorityActive =
      (gExecutionAuthorityStatus.factory_governed_execution_authority_active &&
       gExecutionAuthorityStatus.active_operating_cohort_defined &&
       gExecutionAuthorityStatus.execution_allowed_only_through_active_operating_cohort);

   if(!cohortGovernedAuthorityActive &&
      gPlan.factory_first_admission_policy_locked &&
      gPlan.strategy_transfer_runtime_freeze_active &&
      gPlan.future_factory_admission_required_for_execution)
   {
      reason = (StringLen(gPlan.strategy_transfer_runtime_freeze_reason_code) > 0
                ? gPlan.strategy_transfer_runtime_freeze_reason_code
                : "strategy_transfer_runtime_freeze_active");
      return false;
   }

   string envelopeReason = "";
   if(!RuntimeOperatingEnvelopeAllowsTrade(dir, envelopeReason))
   {
      reason = envelopeReason;
      return false;
   }

   string r = "";

   if(gPlan.regime_policy_enabled && gHasRegime)
   {
      if(gPlan.regime_confidence_min > 0.0 && gRegime.regime_confidence < gPlan.regime_confidence_min)
      {
         reason = "regime_policy_confidence_below_min";
         return false;
      }

      if(gPlan.regime_tradability_min > 0.0 && gRegime.tradability_score < gPlan.regime_tradability_min)
      {
         reason = "regime_policy_tradability_below_min";
         return false;
      }

      if(!RegimeCsvAllows(gPlan.allowed_regimes, gRegime.regime_label))
      {
         reason = "regime_policy_not_allowed";
         return false;
      }
   }

   // Strategy Intelligence / Decision Quality policy hooks (optional, conservative)
   if(gPlan.decision_quality_policy_enabled && gPlan.strategy_intelligence_enabled && gHasStrategyIntel)
   {
      if(gPlan.minimum_entry_quality_score > 0.0 && gEntryQuality.entry_quality_score < gPlan.minimum_entry_quality_score)
      {
         reason = "dq_policy_entry_quality_below_min";
         return false;
      }

      if(gPlan.minimum_strategy_regime_fit_score > 0.0 && gStrategyFit.strategy_regime_fit_score < gPlan.minimum_strategy_regime_fit_score)
      {
         reason = "dq_policy_regime_fit_below_min";
         return false;
      }

      if(gPlan.minimum_entry_edge_score > 0.0 && gEntryEdge.entry_edge_score < gPlan.minimum_entry_edge_score)
      {
         reason = "dq_policy_entry_edge_below_min";
         return false;
      }

      if(gPlan.minimum_follow_through_quality_score > 0.0 && gFollowThrough.follow_through_quality_score < gPlan.minimum_follow_through_quality_score)
      {
         reason = "dq_policy_follow_through_below_min";
         return false;
      }

      if(gHasExecEstimation)
      {
         if(gPlan.minimum_execution_geometry_score > 0.0 && gExecEstimation.execution_geometry_score < gPlan.minimum_execution_geometry_score)
         {
            reason = "dq_policy_execution_geometry_below_min";
            return false;
         }

         if(gPlan.minimum_expected_rr_estimate > 0.0 && gExecEstimation.expected_rr_estimate < gPlan.minimum_expected_rr_estimate)
         {
            reason = "dq_policy_expected_rr_below_min";
            return false;
         }

         if(gPlan.block_adverse_execution_geometry)
         {
            if(gExecEstimation.execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY" || gExecEstimation.execution_geometry_label == "POOR_EXECUTION_GEOMETRY")
            {
               reason = "dq_policy_adverse_execution_geometry";
               return false;
            }
         }
      }

      if(gPlan.block_poor_entries)
      {
         if(gEntryQuality.entry_quality_label == "POOR_ENTRY" || gEntryQuality.entry_quality_label == "NO_ENTRY_EDGE")
         {
            reason = "dq_policy_block_poor_entry_label";
            return false;
         }
      }

      if(gPlan.block_negative_entry_edge)
      {
         if(gEntryEdge.entry_edge_label == "NEGATIVE_ENTRY_EDGE")
         {
            reason = "dq_policy_block_negative_entry_edge";
            return false;
         }
      }
   }

   return true;
}

//---------------------------------------------------------
// Regime filter (decision-level) - optional, backward-safe
//---------------------------------------------------------
bool RegimeFilterAllows(RuntimePlan &plan, RegimeClassification &reg, string &reason)
{
   reason = "";

   if(!plan.enable_regime_filter)
      return true;

   if(plan.regime_confidence_min > 0.0 && reg.regime_confidence < plan.regime_confidence_min)
   {
      reason = "regime_confidence_below_min";
      return false;
   }

   if(plan.regime_tradability_min > 0.0 && reg.tradability_score < plan.regime_tradability_min)
   {
      reason = "regime_tradability_below_min";
      return false;
   }

   if(!RegimeCsvAllows(plan.allowed_regimes, reg.regime_label))
   {
      reason = "regime_not_allowed";
      return false;
   }

   // Strategy Intelligence / Decision Quality policy hooks (optional, conservative)
   if(gPlan.decision_quality_policy_enabled && gPlan.strategy_intelligence_enabled && gHasStrategyIntel)
   {
      if(gPlan.minimum_entry_quality_score > 0.0 && gEntryQuality.entry_quality_score < gPlan.minimum_entry_quality_score)
      {
         reason = "dq_policy_entry_quality_below_min";
         return false;
      }

      if(gPlan.minimum_strategy_regime_fit_score > 0.0 && gStrategyFit.strategy_regime_fit_score < gPlan.minimum_strategy_regime_fit_score)
      {
         reason = "dq_policy_regime_fit_below_min";
         return false;
      }

      if(gPlan.minimum_entry_edge_score > 0.0 && gEntryEdge.entry_edge_score < gPlan.minimum_entry_edge_score)
      {
         reason = "dq_policy_entry_edge_below_min";
         return false;
      }

      if(gPlan.minimum_follow_through_quality_score > 0.0 && gFollowThrough.follow_through_quality_score < gPlan.minimum_follow_through_quality_score)
      {
         reason = "dq_policy_follow_through_below_min";
         return false;
      }

      if(gHasExecEstimation)
      {
         if(gPlan.minimum_execution_geometry_score > 0.0 && gExecEstimation.execution_geometry_score < gPlan.minimum_execution_geometry_score)
         {
            reason = "dq_policy_execution_geometry_below_min";
            return false;
         }

         if(gPlan.minimum_expected_rr_estimate > 0.0 && gExecEstimation.expected_rr_estimate < gPlan.minimum_expected_rr_estimate)
         {
            reason = "dq_policy_expected_rr_below_min";
            return false;
         }

         if(gPlan.block_adverse_execution_geometry)
         {
            if(gExecEstimation.execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY" || gExecEstimation.execution_geometry_label == "POOR_EXECUTION_GEOMETRY")
            {
               reason = "dq_policy_adverse_execution_geometry";
               return false;
            }
         }
      }

      if(gPlan.block_poor_entries)
      {
         if(gEntryQuality.entry_quality_label == "POOR_ENTRY" || gEntryQuality.entry_quality_label == "NO_ENTRY_EDGE")
         {
            reason = "dq_policy_block_poor_entry_label";
            return false;
         }
      }

      if(gPlan.block_negative_entry_edge)
      {
         if(gEntryEdge.entry_edge_label == "NEGATIVE_ENTRY_EDGE")
         {
            reason = "dq_policy_block_negative_entry_edge";
            return false;
         }
      }
   }

   return true;
}

//---------------------------------------------------------
// Unified confidence builder (fallback-friendly)
//---------------------------------------------------------
void AppendDecisionReasoningFlag(string flag, string &csv)
{
   flag = TrimString(flag);
   if(StringLen(flag) <= 0)
      return;

   if(StringLen(csv) <= 0)
      csv = flag;
   else
      csv += "," + flag;
}

string ComputeDecisionAcceptancePostureForObservability(const UnifiedDecisionConfidence &c, const bool policyAllowed)
{
   if(c.direction != "BUY" && c.direction != "SELL")
      return "NON_ENTRY";

   if(!policyAllowed)
      return "BLOCKED";

   if(c.learning_caution_score >= 0.07 || c.learning_hold_bias || c.advisory_hold_bias_active)
      return "CAUTIOUS";

   if(c.learning_confidence_delta <= -0.03 || c.policy_risk_score >= 0.70 || c.regime_fit_score < 0.45)
      return "DEGRADED";

   if(c.learning_confidence_delta >= 0.03 && c.regime_fit_score >= 0.70 && c.policy_risk_score <= 0.45)
      return "EXCEPTIONAL";

   return "STANDARD";
}

string SRVIZ_Upper(string s)
{
   s = TrimString(s);
   StringToUpper(s);
   return s;
}

bool SRVIZ_Contains(const string src, const string token)
{
   string a = SRVIZ_Upper(src);
   string b = SRVIZ_Upper(token);
   return (StringFind(a, b) >= 0);
}

bool SRVIZ_HasUsableLevel(const double price)
{
   return (price > 0.0 && price < DBL_MAX);
}

void SRVIZ_DeleteObject(const string name)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);
}

int SRVIZ_DisplayMode()
{
   int mode = SupportResistanceOverlayDisplayMode;
   if(mode < SRVIZ_MODE_DECISION_VIEW || mode > SRVIZ_MODE_CLEAN_VIEW)
      mode = SRVIZ_MODE_STRUCTURE_VIEW;
   return mode;
}

string SRVIZ_DisplayModeText(const int mode)
{
   if(mode == SRVIZ_MODE_DECISION_VIEW) return "DECISION_VIEW";
   if(mode == SRVIZ_MODE_CLEAN_VIEW) return "CLEAN_VIEW";
   return "STRUCTURE_VIEW";
}

int SRVIZ_MaxLevelsPerSideForMode(const int mode)
{
   int maxLevels = SupportResistanceOverlayMaxLevelsPerSide;
   if(maxLevels < 1) maxLevels = 1;
   if(maxLevels > SRVIZ_MAX_LEVELS_PER_SIDE) maxLevels = SRVIZ_MAX_LEVELS_PER_SIDE;

   if(mode == SRVIZ_MODE_DECISION_VIEW || mode == SRVIZ_MODE_CLEAN_VIEW)
      return 1;
   return maxLevels;
}

int SRVIZ_ConfluenceThresholdPoints()
{
   int p = SupportResistanceOverlayConfluenceThresholdPoints;
   if(p < 1) p = 1;
   if(p > 200) p = 200;
   return p;
}

int SRVIZ_VisualOffsetPoints()
{
   int p = SupportResistanceOverlayVisualOffsetPoints;
   if(p < 1) p = 1;
   if(p > 50) p = 50;
   return p;
}

string SRVIZ_FinalLineName(const bool support, const int rank)
{
   return "SRVIZ_FINAL_" + string(support ? "SUPPORT" : "RESISTANCE") + "_LINE_" + IntegerToString(rank + 1);
}

string SRVIZ_FinalLabelName(const bool support, const int rank)
{
   return "SRVIZ_FINAL_" + string(support ? "SUPPORT" : "RESISTANCE") + "_LABEL_" + IntegerToString(rank + 1);
}

string SRVIZ_AtasLineName(const bool support, const int rank)
{
   return "SRVIZ_ATAS_" + string(support ? "SUPPORT" : "RESISTANCE") + "_LINE_" + IntegerToString(rank + 1);
}

string SRVIZ_AtasLabelName(const bool support, const int rank)
{
   return "SRVIZ_ATAS_" + string(support ? "SUPPORT" : "RESISTANCE") + "_LABEL_" + IntegerToString(rank + 1);
}

string SRVIZ_ConfluenceLabelName(const bool support, const int rank)
{
   return "SRVIZ_CONFLUENCE_" + string(support ? "SUPPORT" : "RESISTANCE") + "_LABEL_" + IntegerToString(rank + 1);
}

void SRVIZ_ClearAll()
{
   for(int i = 0; i < SRVIZ_MAX_LEVELS_PER_SIDE; i++)
   {
      SRVIZ_DeleteObject(SRVIZ_FinalLineName(true, i));
      SRVIZ_DeleteObject(SRVIZ_FinalLineName(false, i));
      SRVIZ_DeleteObject(SRVIZ_AtasLineName(true, i));
      SRVIZ_DeleteObject(SRVIZ_AtasLineName(false, i));

      SRVIZ_DeleteObject(SRVIZ_FinalLabelName(true, i));
      SRVIZ_DeleteObject(SRVIZ_FinalLabelName(false, i));
      SRVIZ_DeleteObject(SRVIZ_AtasLabelName(true, i));
      SRVIZ_DeleteObject(SRVIZ_AtasLabelName(false, i));
      SRVIZ_DeleteObject(SRVIZ_ConfluenceLabelName(true, i));
      SRVIZ_DeleteObject(SRVIZ_ConfluenceLabelName(false, i));
   }

   // Legacy names kept for cleanup compatibility.
   SRVIZ_DeleteObject(SRVIZ_FINAL_SUPPORT_LINE);
   SRVIZ_DeleteObject(SRVIZ_FINAL_RES_LINE);
   SRVIZ_DeleteObject(SRVIZ_ATAS_SUPPORT_LINE);
   SRVIZ_DeleteObject(SRVIZ_ATAS_RES_LINE);
   SRVIZ_DeleteObject(SRVIZ_FINAL_SUPPORT_LABEL);
   SRVIZ_DeleteObject(SRVIZ_FINAL_RES_LABEL);
   SRVIZ_DeleteObject(SRVIZ_ATAS_SUPPORT_LABEL);
   SRVIZ_DeleteObject(SRVIZ_ATAS_RES_LABEL);
   SRVIZ_DeleteObject(SRVIZ_STATUS_LABEL);
}

datetime SRVIZ_LabelTime()
{
   datetime t = iTime(_Symbol, PERIOD_CURRENT, 0);
   if(t <= 0)
      t = TimeCurrent();
   int tfSec = PeriodSeconds(PERIOD_CURRENT);
   if(tfSec <= 0)
      tfSec = 60;
   return (t + (datetime)(tfSec * 2));
}

void SRVIZ_UpsertHLine(const string name,
                       const double price,
                       const color lineColor,
                       const int lineWidth,
                       const ENUM_LINE_STYLE lineStyle)
{
   if(!SRVIZ_HasUsableLevel(price))
   {
      SRVIZ_DeleteObject(name);
      return;
   }

   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_HLINE, 0, 0, price);

   ObjectSetDouble(0, name, OBJPROP_PRICE, price);
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, lineWidth);
   ObjectSetInteger(0, name, OBJPROP_STYLE, lineStyle);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
}

void SRVIZ_UpsertLevelLabel(const string name,
                            const double price,
                            const string text,
                            const color textColor)
{
   if(!SRVIZ_HasUsableLevel(price))
   {
      SRVIZ_DeleteObject(name);
      return;
   }

   datetime labelTime = SRVIZ_LabelTime();
   if(ObjectFind(0, name) < 0)
      ObjectCreate(0, name, OBJ_TEXT, 0, labelTime, price);
   else
      ObjectMove(0, name, 0, labelTime, price);

   ObjectSetString(0, name, OBJPROP_TEXT, text);
   ObjectSetInteger(0, name, OBJPROP_COLOR, textColor);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LEFT);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);
}

void SRVIZ_UpsertStatusLabel(const string text)
{
   if(ObjectFind(0, SRVIZ_STATUS_LABEL) < 0)
      ObjectCreate(0, SRVIZ_STATUS_LABEL, OBJ_LABEL, 0, 0, 0);

   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_XDISTANCE, 12);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_YDISTANCE, 58);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_COLOR, clrWhite);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, SRVIZ_STATUS_LABEL, OBJPROP_FONT, "Arial");
   ObjectSetString(0, SRVIZ_STATUS_LABEL, OBJPROP_TEXT, text);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, SRVIZ_STATUS_LABEL, OBJPROP_HIDDEN, false);
}

string SRVIZ_WrapStatusField(const string prefix, const string value, const int maxLineLen = 120)
{
   string v = TrimString(value);
   if(StringLen(v) <= 0)
      v = "UNAVAILABLE";

   int safeMax = maxLineLen;
   if(safeMax < 32)
      safeMax = 32;

   int firstChunk = safeMax - StringLen(prefix);
   if(firstChunk < 16)
      firstChunk = 16;

   int continuationChunk = safeMax - 2;
   if(continuationChunk < 16)
      continuationChunk = 16;

   string out = prefix;
   int idx = 0;
   bool first = true;
   int total = StringLen(v);
   while(idx < total)
   {
      int take = (first ? firstChunk : continuationChunk);
      out += StringSubstr(v, idx, take);
      idx += take;
      first = false;
      if(idx < total)
         out += "\n  ";
   }
   return out;
}

struct SRVIZLayerSelection
{
   string layer_class;
   string reason_code;
   string source_surface;
   string interaction_type;
   string canonical_state;

   int support_count;
   int resistance_count;

   double support_price[SRVIZ_MAX_LEVELS_PER_SIDE];
   double support_visual_price[SRVIZ_MAX_LEVELS_PER_SIDE];
   double support_score[SRVIZ_MAX_LEVELS_PER_SIDE];
   string support_source[SRVIZ_MAX_LEVELS_PER_SIDE];
   bool support_confluence[SRVIZ_MAX_LEVELS_PER_SIDE];

   double resistance_price[SRVIZ_MAX_LEVELS_PER_SIDE];
   double resistance_visual_price[SRVIZ_MAX_LEVELS_PER_SIDE];
   double resistance_score[SRVIZ_MAX_LEVELS_PER_SIDE];
   string resistance_source[SRVIZ_MAX_LEVELS_PER_SIDE];
   bool resistance_confluence[SRVIZ_MAX_LEVELS_PER_SIDE];
};

void SRVIZ_InitLayerSelection(SRVIZLayerSelection &s)
{
   s.layer_class = "UNAVAILABLE";
   s.reason_code = "UNSET";
   s.source_surface = "UNSET";
   s.interaction_type = "LEVEL_CONTEXT_UNSET";
   s.canonical_state = "UNSET";
   s.support_count = 0;
   s.resistance_count = 0;

   for(int i = 0; i < SRVIZ_MAX_LEVELS_PER_SIDE; i++)
   {
      s.support_price[i] = 0.0;
      s.support_visual_price[i] = 0.0;
      s.support_score[i] = DBL_MAX;
      s.support_source[i] = "";
      s.support_confluence[i] = false;

      s.resistance_price[i] = 0.0;
      s.resistance_visual_price[i] = 0.0;
      s.resistance_score[i] = DBL_MAX;
      s.resistance_source[i] = "";
      s.resistance_confluence[i] = false;
   }
}

double SRVIZ_CurrentMidPrice()
{
   double bid = 0.0, ask = 0.0;
   bool hasBid = SymbolInfoDouble(_Symbol, SYMBOL_BID, bid);
   bool hasAsk = SymbolInfoDouble(_Symbol, SYMBOL_ASK, ask);
   if(hasBid && hasAsk && bid > 0.0 && ask > 0.0)
      return (bid + ask) * 0.5;
   if(hasBid && bid > 0.0)
      return bid;
   if(hasAsk && ask > 0.0)
      return ask;
   return 0.0;
}

double SRVIZ_SourceTierPenalty(const string sourceSurface, const bool finalLayer)
{
   string src = SRVIZ_Upper(sourceSurface);
   if(finalLayer)
   {
      if(SRVIZ_Contains(src, "DECISION_ENVELOPE")) return 0.0;
      if(SRVIZ_Contains(src, "COUNCIL_ENV_LEVEL_BRAKE")) return 100000.0;
      if(SRVIZ_Contains(src, "MT5_CANONICAL_AUX")) return 200000.0;
      if(SRVIZ_Contains(src, "TRADE_LINKED")) return 300000.0;
      return 400000.0;
   }

   if(SRVIZ_Contains(src, "ATAS_GOVERNED_ADVISORY_STATUS")) return 0.0;
   if(SRVIZ_Contains(src, "ATAS_RUNTIME_CONTEXT_PACKET")) return 100000.0;
   if(SRVIZ_Contains(src, "TRADE_LINKED")) return 200000.0;
   return 300000.0;
}

double SRVIZ_ComputeCandidateScore(const double levelPrice, const double refPrice, const string sourceSurface, const bool finalLayer)
{
   double point = _Point;
   if(point <= 0.0)
      point = 0.00001;

   double distPts = 999999.0;
   if(SRVIZ_HasUsableLevel(refPrice) && SRVIZ_HasUsableLevel(levelPrice))
      distPts = MathAbs(levelPrice - refPrice) / point;

   return SRVIZ_SourceTierPenalty(sourceSurface, finalLayer) + distPts;
}

bool SRVIZ_PricesNear(const double a, const double b, const int thresholdPoints)
{
   if(!SRVIZ_HasUsableLevel(a) || !SRVIZ_HasUsableLevel(b))
      return false;

   double point = _Point;
   if(point <= 0.0)
      point = 0.00001;
   return (MathAbs(a - b) <= ((double)thresholdPoints * point));
}

void SRVIZ_InsertRankedLevel(double &prices[],
                             double &scores[],
                             string &sources[],
                             int &count,
                             const int maxCount,
                             const double price,
                             const string source,
                             const double score)
{
   if(!SRVIZ_HasUsableLevel(price) || maxCount <= 0)
      return;

   for(int i = 0; i < count; i++)
   {
      if(SRVIZ_PricesNear(prices[i], price, 1))
      {
         if(score < scores[i])
         {
            prices[i] = price;
            scores[i] = score;
            sources[i] = source;
         }
         return;
      }
   }

   if(count < maxCount)
   {
      prices[count] = price;
      scores[count] = score;
      sources[count] = source;
      count++;
   }
   else
   {
      if(score >= scores[count - 1])
         return;

      prices[count - 1] = price;
      scores[count - 1] = score;
      sources[count - 1] = source;
   }

   for(int i = 1; i < count; i++)
   {
      int j = i;
      while(j > 0 && scores[j] < scores[j - 1])
      {
         double p = prices[j];
         prices[j] = prices[j - 1];
         prices[j - 1] = p;

         double s = scores[j];
         scores[j] = scores[j - 1];
         scores[j - 1] = s;

         string src = sources[j];
         sources[j] = sources[j - 1];
         sources[j - 1] = src;

         j--;
      }
   }
}

void SRVIZ_AddCandidate(SRVIZLayerSelection &layer,
                        const bool supportSide,
                        const double levelPrice,
                        const string sourceSurface,
                        const double refPrice,
                        const bool finalLayer,
                        const int maxLevelsPerSide)
{
   double score = SRVIZ_ComputeCandidateScore(levelPrice, refPrice, sourceSurface, finalLayer);
   if(supportSide)
      SRVIZ_InsertRankedLevel(layer.support_price, layer.support_score, layer.support_source, layer.support_count, maxLevelsPerSide, levelPrice, sourceSurface, score);
   else
      SRVIZ_InsertRankedLevel(layer.resistance_price, layer.resistance_score, layer.resistance_source, layer.resistance_count, maxLevelsPerSide, levelPrice, sourceSurface, score);
}

string SRVIZ_PrimarySource(const SRVIZLayerSelection &layer)
{
   bool hasSupport = (layer.support_count > 0);
   bool hasResistance = (layer.resistance_count > 0);
   if(!hasSupport && !hasResistance)
      return layer.source_surface;

   if(hasSupport && !hasResistance)
      return layer.support_source[0];
   if(!hasSupport && hasResistance)
      return layer.resistance_source[0];

   if(layer.support_score[0] <= layer.resistance_score[0])
      return layer.support_source[0];
   return layer.resistance_source[0];
}

string SRVIZ_ShortInteractionHint(const string interactionType)
{
   string v = SRVIZ_Upper(interactionType);
   if(SRVIZ_Contains(v, "SUPPORTED")) return "SUPPORTED";
   if(SRVIZ_Contains(v, "OBSTRUCTED")) return "OBSTRUCTED";
   if(SRVIZ_Contains(v, "DEGRADED")) return "DEGRADED";
   if(SRVIZ_Contains(v, "CONFLICT")) return "CONFLICTED";
   if(SRVIZ_Contains(v, "NEUTRAL")) return "NEUTRAL";
   return "CONTEXT";
}

int SRVIZ_ResolveDirectionSign(const RoutedRuntimeEvaluation &routed, const RuntimeEvaluation &eval)
{
   if(eval.decision == RUNTIME_ENTER_BUY)
      return 1;
   if(eval.decision == RUNTIME_ENTER_SELL)
      return -1;

   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      string dom = SRVIZ_Upper(routed.council.aggregate.dominant_side);
      if(dom == "BUY")
         return 1;
      if(dom == "SELL")
         return -1;
   }

   return 1;
}

string SRVIZ_DeriveInteractionFromBrake(const LevelAwarenessBrakeReport &brake)
{
   if(brake.rejection_risk_score >= 0.75 || brake.continuation_obstacle_risk >= 0.60)
      return "LEVEL_CONTEXT_OBSTRUCTED";
   if(brake.reversal_trap_risk >= 0.60)
      return "LEVEL_CONTEXT_DEGRADED";
   if(brake.breakout_room_score >= 0.55)
      return "LEVEL_CONTEXT_SUPPORTED";
   return "LEVEL_CONTEXT_NEUTRAL";
}

void SRVIZ_AddFinalAuxiliaryCandidates(const double refPrice, SRVIZLayerSelection &out, const int maxLevelsPerSide)
{
   double sessHigh = 0.0, sessLow = 0.0;
   if(LAB_GetTodaySessionLevels(_Symbol, sessHigh, sessLow))
   {
      SRVIZ_AddCandidate(out, true, sessLow, "MT5_CANONICAL_AUX:SESSION_LOW", refPrice, true, maxLevelsPerSide);
      SRVIZ_AddCandidate(out, false, sessHigh, "MT5_CANONICAL_AUX:SESSION_HIGH", refPrice, true, maxLevelsPerSide);
   }

   double prevHigh = 0.0, prevLow = 0.0;
   if(LAB_GetPrevDayLevels(_Symbol, prevHigh, prevLow))
   {
      SRVIZ_AddCandidate(out, true, prevLow, "MT5_CANONICAL_AUX:PREV_DAY_LOW", refPrice, true, maxLevelsPerSide);
      SRVIZ_AddCandidate(out, false, prevHigh, "MT5_CANONICAL_AUX:PREV_DAY_HIGH", refPrice, true, maxLevelsPerSide);
   }

   int bars = Bars(_Symbol, PERIOD_M15);
   if(bars > 30)
   {
      int hiIdx = iHighest(_Symbol, PERIOD_M15, MODE_HIGH, MathMin(160, bars - 1), 1);
      int loIdx = iLowest(_Symbol, PERIOD_M15, MODE_LOW, MathMin(160, bars - 1), 1);
      if(hiIdx >= 0)
         SRVIZ_AddCandidate(out, false, iHigh(_Symbol, PERIOD_M15, hiIdx), "MT5_CANONICAL_AUX:M15_SWING_HIGH", refPrice, true, maxLevelsPerSide);
      if(loIdx >= 0)
         SRVIZ_AddCandidate(out, true, iLow(_Symbol, PERIOD_M15, loIdx), "MT5_CANONICAL_AUX:M15_SWING_LOW", refPrice, true, maxLevelsPerSide);
   }
}

struct SRVIZAtasRuntimeContextStatusProbe
{
   bool file_present;
   bool parse_ok;
   bool atas_available;
   bool atas_shadow_attached;
   bool atas_fresh;
   bool price_anchor_fields_suppressed;
   int packet_age_ms;
   string freshness_state;
   string acceptance_state;
   string rejection_reason;
   string packet_id;
   string status_timestamp;
   string source_surface;
};

void SRVIZ_InitAtasRuntimeContextStatusProbe(SRVIZAtasRuntimeContextStatusProbe &probe)
{
   probe.file_present = false;
   probe.parse_ok = false;
   probe.atas_available = false;
   probe.atas_shadow_attached = false;
   probe.atas_fresh = false;
   probe.price_anchor_fields_suppressed = false;
   probe.packet_age_ms = -1;
   probe.freshness_state = "";
   probe.acceptance_state = "";
   probe.rejection_reason = "";
   probe.packet_id = "";
   probe.status_timestamp = "";
   probe.source_surface = "";
}

bool SRVIZ_ReadAtasStatusSurfaceWithFallback(string &json, string &sourceSurface)
{
   json = "";
   sourceSurface = "AI\\atas_microstructure_status.json";
   if(ReadTextFileAll(sourceSurface, json))
      return true;

   sourceSurface = "AI\\atas_runtime_context_status.json";
   if(ReadTextFileAll(sourceSurface, json))
      return true;

   sourceSurface = "AI\\atas_microstructure_status.json";
   return false;
}

bool SRVIZ_LoadAtasRuntimeContextStatusProbe(SRVIZAtasRuntimeContextStatusProbe &probe)
{
   SRVIZ_InitAtasRuntimeContextStatusProbe(probe);

   string json = "";
   string sourceSurface = "";
   if(!SRVIZ_ReadAtasStatusSurfaceWithFallback(json, sourceSurface))
   {
      probe.source_surface = sourceSurface;
      return false;
   }

   probe.source_surface = sourceSurface;
   probe.file_present = true;
   if(StringLen(TrimString(json)) <= 2)
      return false;

   probe.parse_ok = true;
   ExtractJsonBoolField(json, "atas_available", probe.atas_available);
   ExtractJsonBoolField(json, "atas_shadow_attached", probe.atas_shadow_attached);
   ExtractJsonBoolField(json, "atas_fresh", probe.atas_fresh);
   ExtractJsonBoolField(json, "price_anchor_fields_suppressed", probe.price_anchor_fields_suppressed);
   ExtractJsonIntField(json, "packet_age_ms", probe.packet_age_ms);
   ExtractJsonStringField(json, "freshness_state", probe.freshness_state);
   ExtractJsonStringField(json, "acceptance_state", probe.acceptance_state);
   ExtractJsonStringField(json, "rejection_reason", probe.rejection_reason);
   ExtractJsonStringField(json, "packet_id", probe.packet_id);
   ExtractJsonStringField(json, "status_timestamp", probe.status_timestamp);

   return true;
}

bool SRVIZ_ReadAtasContextSurfaceWithFallback(string &json, string &sourceSurface)
{
   json = "";
   sourceSurface = "AI\\atas_microstructure_context.json";
   if(ReadTextFileAll(sourceSurface, json))
      return true;

   sourceSurface = "AI\\atas_runtime_context.json";
   if(ReadTextFileAll(sourceSurface, json))
      return true;

   sourceSurface = "AI\\atas_microstructure_context.json";
   return false;
}

string SRVIZ_ClassifyAtasPacketReason(const string packetReason)
{
   string reasonU = SRVIZ_Upper(packetReason);
   if(StringLen(reasonU) <= 0)
      return "ATAS_REFERENCE_ABSENT";

   if(SRVIZ_Contains(reasonU, "DELIBERATELY_SUPPRESSED"))
      return "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE";
   if(SRVIZ_Contains(reasonU, "MISSING_NUMERIC_LEVEL_VALUES"))
      return "ATAS_REFERENCE_DEFAULTED_OR_INVALID";
   if(SRVIZ_Contains(reasonU, "ABSENT_ENTIRELY") || SRVIZ_Contains(reasonU, "NO_CONTEXTUAL_SOURCE_AVAILABLE"))
      return "ATAS_REFERENCE_ABSENT";

   return "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE";
}

bool SRVIZ_AddAtasPacketCandidates(SRVIZLayerSelection &out,
                                   const int maxLevelsPerSide,
                                   string &reasonCode,
                                   string &sourceSurface)
{
   reasonCode = "";
   sourceSurface = "";

   string json = "";
   if(!SRVIZ_ReadAtasContextSurfaceWithFallback(json, sourceSurface))
   {
      reasonCode = "ATAS_SOURCE_ABSENT_ENTIRELY:RUNTIME_CONTEXT_FILE_MISSING";
      return false;
   }

   if(StringLen(TrimString(json)) <= 2)
   {
      reasonCode = "ATAS_SOURCE_ABSENT_ENTIRELY:RUNTIME_CONTEXT_EMPTY";
      return false;
   }

   bool suppressed = false;
   ExtractJsonBoolField(json, "price_anchor_fields_suppressed", suppressed);
   if(suppressed)
   {
      reasonCode = "ATAS_SOURCE_PRESENT_DELIBERATELY_SUPPRESSED:PRICE_ANCHOR_FIELDS_SUPPRESSED";
      return false;
   }

   string arrayRaw = "";
   if(!AtasExtractArrayRaw(json, "level_candidates", arrayRaw))
   {
      reasonCode = "ATAS_NO_CONTEXTUAL_SOURCE_AVAILABLE:LEVEL_CANDIDATES_FIELD_ABSENT";
      return false;
   }

   string objects[];
   int objectCount = AtasExtractArrayObjects(arrayRaw, objects);
   if(objectCount <= 0)
   {
      reasonCode = "ATAS_SOURCE_PRESENT_MISSING_NUMERIC_LEVEL_VALUES:LEVEL_CANDIDATES_EMPTY";
      return false;
   }

   double refPrice = SRVIZ_CurrentMidPrice();
   int addedBefore = out.support_count + out.resistance_count;

   for(int i = 0; i < objectCount; i++)
   {
      AtasLevelEvidenceRecord rec;
      if(!AtasParseLevelEvidenceRecord(objects[i], rec))
         continue;
      if(rec.level_price <= 0.0)
         continue;

      string side = SRVIZ_Upper(rec.level_side_candidate);
      bool isSupport = SRVIZ_Contains(side, "SUPPORT");
      bool isResistance = SRVIZ_Contains(side, "RESISTANCE");

      if(!isSupport && !isResistance)
      {
         if(refPrice > 0.0 && rec.level_price <= refPrice)
            isSupport = true;
         else
            isResistance = true;
      }

      if(isSupport)
         SRVIZ_AddCandidate(out, true, rec.level_price, "ATAS_RUNTIME_CONTEXT_PACKET", refPrice, false, maxLevelsPerSide);
      if(isResistance)
         SRVIZ_AddCandidate(out, false, rec.level_price, "ATAS_RUNTIME_CONTEXT_PACKET", refPrice, false, maxLevelsPerSide);
   }

   if((out.support_count + out.resistance_count) > addedBefore)
   {
      reasonCode = "ATAS_SOURCE_AVAILABLE_RUNTIME_CONTEXT_PACKET";
      return true;
   }

   reasonCode = "ATAS_SOURCE_PRESENT_MISSING_NUMERIC_LEVEL_VALUES:LEVEL_CANDIDATES_UNUSABLE";
   return false;
}

void SRVIZ_SelectFinalRuntimeLevels(const UnifiedDecisionConfidence &conf,
                                    const RoutedRuntimeEvaluation &routed,
                                    const RuntimeEvaluation &eval,
                                    const int displayMode,
                                    SRVIZLayerSelection &out)
{
   SRVIZ_InitLayerSelection(out);

   out.interaction_type = conf.level_interaction_type;
   out.canonical_state = conf.canonical_level_state;
   out.source_surface = TrimString(conf.support_resistance_observation_source);

   int maxLevelsPerSide = SRVIZ_MaxLevelsPerSideForMode(displayMode);
   double refPrice = SRVIZ_CurrentMidPrice();
   bool hasDecisionEnvelopeSource = false;
   bool hasCouncilContextSource = false;
   bool hasAuxContextSource = false;

   if(SRVIZ_HasUsableLevel(conf.nearest_support_price))
   {
      SRVIZ_AddCandidate(out, true, conf.nearest_support_price, "DECISION_ENVELOPE_CONTEXT", refPrice, true, maxLevelsPerSide);
      hasDecisionEnvelopeSource = true;
   }
   if(SRVIZ_HasUsableLevel(conf.nearest_resistance_price))
   {
      SRVIZ_AddCandidate(out, false, conf.nearest_resistance_price, "DECISION_ENVELOPE_CONTEXT", refPrice, true, maxLevelsPerSide);
      hasDecisionEnvelopeSource = true;
   }

   if(routed.active_mode == "COUNCIL" && routed.council.valid && routed.council.env.valid)
   {
      int directionSign = SRVIZ_ResolveDirectionSign(routed, eval);
      LevelAwarenessBrakeReport brake;
      CouncilRuntimeResult councilCopy = routed.council;
      bool brakeOk = BuildLevelAwarenessBrakeReport(_Symbol, directionSign, councilCopy, brake);
      if(brakeOk)
      {
         if(SRVIZ_HasUsableLevel(brake.nearest_support_price))
         {
            SRVIZ_AddCandidate(out, true, brake.nearest_support_price, "COUNCIL_ENV_LEVEL_BRAKE_CONTEXT", refPrice, true, maxLevelsPerSide);
            hasCouncilContextSource = true;
         }
         if(SRVIZ_HasUsableLevel(brake.nearest_resistance_price))
         {
            SRVIZ_AddCandidate(out, false, brake.nearest_resistance_price, "COUNCIL_ENV_LEVEL_BRAKE_CONTEXT", refPrice, true, maxLevelsPerSide);
            hasCouncilContextSource = true;
         }
         out.interaction_type = SRVIZ_DeriveInteractionFromBrake(brake);
         out.canonical_state = brake.location_context_summary;

         if(displayMode == SRVIZ_MODE_STRUCTURE_VIEW)
         {
            int beforeAux = out.support_count + out.resistance_count;
            SRVIZ_AddFinalAuxiliaryCandidates(refPrice, out, maxLevelsPerSide);
            if((out.support_count + out.resistance_count) > beforeAux)
               hasAuxContextSource = true;
         }
      }
      else if(displayMode == SRVIZ_MODE_STRUCTURE_VIEW)
      {
         int beforeAux = out.support_count + out.resistance_count;
         SRVIZ_AddFinalAuxiliaryCandidates(refPrice, out, maxLevelsPerSide);
         if((out.support_count + out.resistance_count) > beforeAux)
            hasAuxContextSource = true;
      }
   }
   else if(displayMode == SRVIZ_MODE_STRUCTURE_VIEW)
   {
      int beforeAux = out.support_count + out.resistance_count;
      SRVIZ_AddFinalAuxiliaryCandidates(refPrice, out, maxLevelsPerSide);
      if((out.support_count + out.resistance_count) > beforeAux)
         hasAuxContextSource = true;
   }

   if(out.support_count > 0 || out.resistance_count > 0)
   {
      out.layer_class = "FINAL_RUNTIME_RELIED_ON";
      if(hasDecisionEnvelopeSource)
         out.reason_code = "FINAL_SOURCE_AVAILABLE_DECISION_ENVELOPE_CONTEXT";
      else if(hasCouncilContextSource)
         out.reason_code = "FINAL_SOURCE_AVAILABLE_COUNCIL_ENV_CONTEXTUAL";
      else if(hasAuxContextSource)
         out.reason_code = "FINAL_SOURCE_AVAILABLE_MT5_CANONICAL_AUX_CONTEXT";
      else
         out.reason_code = "FINAL_SOURCE_AVAILABLE_RUNTIME_CONTEXT";
      out.source_surface = SRVIZ_PrimarySource(out);
      return;
   }

   string src = TrimString(conf.support_resistance_observation_source);
   string srcU = SRVIZ_Upper(src);

   if(StringLen(srcU) <= 0)
   {
      out.reason_code = "FINAL_SOURCE_ABSENT_ENTIRELY:NO_SR_CONTEXT_SURFACE";
      out.source_surface = "NONE";
      return;
   }

   out.source_surface = src;

   if(SRVIZ_Contains(srcU, "SUPPRESS") || SRVIZ_Contains(srcU, "SEMANTIC_ONLY"))
   {
      out.reason_code = "FINAL_SOURCE_PRESENT_DELIBERATELY_SUPPRESSED:" + src;
      return;
   }

   if(SRVIZ_Contains(srcU, "BLOCK") || SRVIZ_Contains(srcU, "INELIGIBLE"))
   {
      out.reason_code = "FINAL_SOURCE_AVAILABLE_BLOCKED_OR_INELIGIBLE:" + src;
      return;
   }

   if(SRVIZ_Contains(srcU, "NOT_CAPTURED") || SRVIZ_Contains(srcU, "UNAVAILABLE"))
   {
      out.reason_code = "FINAL_NO_CONTEXTUAL_SOURCE_AVAILABLE:" + src;
      return;
   }

   out.reason_code = "FINAL_SOURCE_PRESENT_MISSING_NUMERIC_LEVEL_VALUES:" + src;
}

void SRVIZ_SelectAtasReferenceLevels(const int displayMode, SRVIZLayerSelection &out)
{
   SRVIZ_InitLayerSelection(out);
   out.source_surface = "ATAS_GOVERNED_ADVISORY_STATUS";
   out.interaction_type = "LEVEL_CONTEXT_UNSET";
   out.canonical_state = "UNSET";

   if(displayMode == SRVIZ_MODE_CLEAN_VIEW)
   {
      out.layer_class = "HIDDEN_BY_MODE";
      out.reason_code = "ATAS_LAYER_DISABLED_BY_CLEAN_VIEW";
      return;
   }

   if(!EnableATASGovernedAdvisory)
   {
      out.layer_class = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE";
      out.reason_code = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE:ADVISORY_DISABLED";
      return;
   }

   SRVIZAtasRuntimeContextStatusProbe probe;
   bool probeLoaded = SRVIZ_LoadAtasRuntimeContextStatusProbe(probe);
   string statusSurface = TrimString(probe.source_surface);
   if(StringLen(statusSurface) <= 0)
      statusSurface = "AI\\atas_microstructure_status.json";
   if(!probeLoaded || !probe.file_present)
   {
      out.layer_class = "ATAS_REFERENCE_ABSENT";
      out.reason_code = "ATAS_REFERENCE_ABSENT:RUNTIME_CONTEXT_STATUS_FILE_MISSING";
      out.source_surface = statusSurface;
      return;
   }
   if(!probe.parse_ok)
   {
      out.layer_class = "ATAS_REFERENCE_ABSENT";
      out.reason_code = "ATAS_REFERENCE_ABSENT:RUNTIME_CONTEXT_STATUS_EMPTY_OR_INVALID";
      out.source_surface = statusSurface;
      return;
   }

   out.source_surface = statusSurface;
   string freshnessU = SRVIZ_Upper(probe.freshness_state);
   string acceptanceU = SRVIZ_Upper(probe.acceptance_state);
   string rejection = TrimString(probe.rejection_reason);
   if(StringLen(rejection) <= 0)
      rejection = "reason_unset";

   if(!probe.atas_available)
   {
      out.layer_class = "ATAS_REFERENCE_ABSENT";
      out.reason_code = "ATAS_REFERENCE_ABSENT:atas_available_false:" + rejection;
      return;
   }

   if(!probe.atas_shadow_attached || SRVIZ_Contains(acceptanceU, "NOT_ATTACHED"))
   {
      out.layer_class = "ATAS_REFERENCE_NOT_ATTACHED";
      out.reason_code = "ATAS_REFERENCE_NOT_ATTACHED:" + rejection;
      return;
   }

   const int historicalAgeMs = 3600000;
   if(SRVIZ_Contains(freshnessU, "EXPIRED"))
   {
      if(probe.packet_age_ms >= historicalAgeMs)
      {
         out.layer_class = "ATAS_REFERENCE_HISTORICAL_ONLY";
         out.reason_code = "ATAS_REFERENCE_HISTORICAL_ONLY:packet_age_ms=" + IntegerToString(probe.packet_age_ms) + ":" + rejection;
      }
      else
      {
         out.layer_class = "ATAS_REFERENCE_EXPIRED";
         out.reason_code = "ATAS_REFERENCE_EXPIRED:" + rejection;
      }
      return;
   }

   if(!probe.atas_fresh || SRVIZ_Contains(freshnessU, "STALE"))
   {
      out.layer_class = "ATAS_REFERENCE_STALE";
      out.reason_code = "ATAS_REFERENCE_STALE:" + rejection;
      return;
   }

   if(probe.price_anchor_fields_suppressed)
   {
      out.layer_class = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE";
      out.reason_code = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE:PRICE_ANCHOR_FIELDS_SUPPRESSED";
      return;
   }

   int maxLevelsPerSide = SRVIZ_MaxLevelsPerSideForMode(displayMode);
   double refPrice = SRVIZ_CurrentMidPrice();
   bool statusInitialized = gAtasGovernedAdvisoryStatusInitialized;
   if(!statusInitialized)
   {
      out.layer_class = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE";
      out.reason_code = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE:GOVERNED_STATUS_UNINITIALIZED";
      out.source_surface = "ATAS_GOVERNED_ADVISORY_STATUS";
      return;
   }

   bool statusHasLevels = false;

   bool gateBlocked = false;
   bool payloadPresent = false;
   string gateReason = "";
   payloadPresent = gAtasGovernedAdvisoryStatus.gate_payload_present;
   gateBlocked =
      (!gAtasGovernedAdvisoryStatus.gate_shadow_attached ||
       !gAtasGovernedAdvisoryStatus.advisory_eligible ||
       !gAtasGovernedAdvisoryStatus.gate_freshness_valid ||
       !gAtasGovernedAdvisoryStatus.gate_source_valid ||
       !gAtasGovernedAdvisoryStatus.gate_symbol_mapping_valid ||
       !gAtasGovernedAdvisoryStatus.gate_session_valid ||
       !gAtasGovernedAdvisoryStatus.gate_translation_valid);
   gateReason = TrimString(gAtasGovernedAdvisoryStatus.gate_reason_code);
   if(StringLen(gateReason) <= 0)
      gateReason = "atas_gate_reason_unset";

   out.interaction_type = gAtasGovernedAdvisoryStatus.level_interaction_type;
   out.canonical_state = gAtasGovernedAdvisoryStatus.support_resistance_confluence_state;

   if(gateBlocked)
   {
      out.layer_class = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE";
      out.reason_code = "ATAS_REFERENCE_BLOCKED_OR_INELIGIBLE:" + gateReason;
      out.source_surface = "ATAS_GOVERNED_ADVISORY_STATUS";
      return;
   }
   if(!payloadPresent)
   {
      out.layer_class = "ATAS_REFERENCE_ABSENT";
      out.reason_code = "ATAS_REFERENCE_ABSENT:PAYLOAD_ABSENT";
      out.source_surface = "ATAS_GOVERNED_ADVISORY_STATUS";
      return;
   }

   if(SRVIZ_HasUsableLevel(gAtasGovernedAdvisoryStatus.nearest_support_price))
   {
      SRVIZ_AddCandidate(out, true, gAtasGovernedAdvisoryStatus.nearest_support_price, "ATAS_GOVERNED_ADVISORY_STATUS", refPrice, false, maxLevelsPerSide);
      statusHasLevels = true;
   }
   if(SRVIZ_HasUsableLevel(gAtasGovernedAdvisoryStatus.nearest_resistance_price))
   {
      SRVIZ_AddCandidate(out, false, gAtasGovernedAdvisoryStatus.nearest_resistance_price, "ATAS_GOVERNED_ADVISORY_STATUS", refPrice, false, maxLevelsPerSide);
      statusHasLevels = true;
   }

   string packetReason = "";
   string packetSurface = "";
   bool packetHasLevels = false;
   if(!statusHasLevels)
      packetHasLevels = SRVIZ_AddAtasPacketCandidates(out, maxLevelsPerSide, packetReason, packetSurface);

   bool anyLevels = (out.support_count > 0 || out.resistance_count > 0);
   if(anyLevels)
   {
      out.layer_class = "ATAS_LIVE_REFERENCE_AVAILABLE";
      out.source_surface = SRVIZ_PrimarySource(out);
      if(statusHasLevels && packetHasLevels)
         out.reason_code = "ATAS_LIVE_REFERENCE_AVAILABLE:GOVERNED_STATUS_CONTEXT_PLUS_PACKET_FALLBACK";
      else if(statusHasLevels)
         out.reason_code = "ATAS_LIVE_REFERENCE_AVAILABLE:GOVERNED_STATUS_CONTEXT";
      else
         out.reason_code = "ATAS_LIVE_REFERENCE_AVAILABLE:RUNTIME_CONTEXT_PACKET_FALLBACK";
      return;
   }

   string classified = SRVIZ_ClassifyAtasPacketReason(packetReason);
   out.layer_class = classified;
   if(StringLen(TrimString(packetReason)) > 0)
      out.reason_code = classified + ":" + packetReason;
   else
      out.reason_code = classified + ":ATAS_NO_CONTEXTUAL_SOURCE_AVAILABLE";
   if(StringLen(TrimString(packetSurface)) > 0)
      out.source_surface = packetSurface;
   else
      out.source_surface = "AI\\atas_microstructure_context.json";
}

void SRVIZ_ApplyConfluenceVisualAdjustment(const SRVIZLayerSelection &finalLayer, SRVIZLayerSelection &atasLayer)
{
   int thresholdPts = SRVIZ_ConfluenceThresholdPoints();
   int offsetPts = SRVIZ_VisualOffsetPoints();
   double point = _Point;
   if(point <= 0.0)
      point = 0.00001;

   for(int i = 0; i < atasLayer.support_count; i++)
   {
      double raw = atasLayer.support_price[i];
      bool overlap = false;
      for(int j = 0; j < finalLayer.support_count; j++)
      {
         if(SRVIZ_PricesNear(raw, finalLayer.support_price[j], thresholdPts))
         {
            overlap = true;
            break;
         }
      }
      atasLayer.support_confluence[i] = overlap;
      atasLayer.support_visual_price[i] = (overlap ? raw - ((double)(offsetPts + i) * point) : raw);
   }

   for(int i = 0; i < atasLayer.resistance_count; i++)
   {
      double raw = atasLayer.resistance_price[i];
      bool overlap = false;
      for(int j = 0; j < finalLayer.resistance_count; j++)
      {
         if(SRVIZ_PricesNear(raw, finalLayer.resistance_price[j], thresholdPts))
         {
            overlap = true;
            break;
         }
      }
      atasLayer.resistance_confluence[i] = overlap;
      atasLayer.resistance_visual_price[i] = (overlap ? raw + ((double)(offsetPts + i) * point) : raw);
   }
}

void UpdateSupportResistanceChartOverlay(const UnifiedDecisionConfidence &finalConf,
                                         const RoutedRuntimeEvaluation &routed,
                                         const RuntimeEvaluation &eval)
{
   if(!EnableSupportResistanceChartVisualization)
   {
      SRVIZ_ClearAll();
      return;
   }

   int displayMode = SRVIZ_DisplayMode();
   SRVIZLayerSelection finalLayer;
   SRVIZLayerSelection atasLayer;
   SRVIZ_SelectFinalRuntimeLevels(finalConf, routed, eval, displayMode, finalLayer);
   SRVIZ_SelectAtasReferenceLevels(displayMode, atasLayer);
   SRVIZ_ApplyConfluenceVisualAdjustment(finalLayer, atasLayer);
   bool atasDrawable = (atasLayer.layer_class == "ATAS_LIVE_REFERENCE_AVAILABLE");

   for(int i = 0; i < SRVIZ_MAX_LEVELS_PER_SIDE; i++)
   {
      bool drawFinalSupport = (i < finalLayer.support_count && SRVIZ_HasUsableLevel(finalLayer.support_price[i]));
      bool drawFinalResistance = (i < finalLayer.resistance_count && SRVIZ_HasUsableLevel(finalLayer.resistance_price[i]));
      bool drawAtasSupport = (displayMode != SRVIZ_MODE_CLEAN_VIEW && atasDrawable && i < atasLayer.support_count && SRVIZ_HasUsableLevel(atasLayer.support_visual_price[i]));
      bool drawAtasResistance = (displayMode != SRVIZ_MODE_CLEAN_VIEW && atasDrawable && i < atasLayer.resistance_count && SRVIZ_HasUsableLevel(atasLayer.resistance_visual_price[i]));

      if(drawFinalSupport)
      {
         color c = (i == 0 ? SRVIZ_COLOR_FINAL_PRIMARY : SRVIZ_COLOR_FINAL_SECONDARY);
         int w = (i == 0 ? 3 : 2);
         SRVIZ_UpsertHLine(SRVIZ_FinalLineName(true, i), finalLayer.support_price[i], c, w, STYLE_SOLID);
         string lbl = "FINAL_S" + IntegerToString(i + 1) + " | " + SRVIZ_ShortInteractionHint(finalLayer.interaction_type);
         SRVIZ_UpsertLevelLabel(SRVIZ_FinalLabelName(true, i), finalLayer.support_price[i], lbl, c);
      }
      else
      {
         SRVIZ_DeleteObject(SRVIZ_FinalLineName(true, i));
         SRVIZ_DeleteObject(SRVIZ_FinalLabelName(true, i));
      }

      if(drawFinalResistance)
      {
         color c = (i == 0 ? SRVIZ_COLOR_FINAL_PRIMARY : SRVIZ_COLOR_FINAL_SECONDARY);
         int w = (i == 0 ? 3 : 2);
         SRVIZ_UpsertHLine(SRVIZ_FinalLineName(false, i), finalLayer.resistance_price[i], c, w, STYLE_SOLID);
         string lbl = "FINAL_R" + IntegerToString(i + 1) + " | " + SRVIZ_ShortInteractionHint(finalLayer.interaction_type);
         SRVIZ_UpsertLevelLabel(SRVIZ_FinalLabelName(false, i), finalLayer.resistance_price[i], lbl, c);
      }
      else
      {
         SRVIZ_DeleteObject(SRVIZ_FinalLineName(false, i));
         SRVIZ_DeleteObject(SRVIZ_FinalLabelName(false, i));
      }

      if(drawAtasSupport)
      {
         color c = (i == 0 ? SRVIZ_COLOR_ATAS_PRIMARY : SRVIZ_COLOR_ATAS_SECONDARY);
         int w = (i == 0 ? 2 : 1);
         SRVIZ_UpsertHLine(SRVIZ_AtasLineName(true, i), atasLayer.support_visual_price[i], c, w, STYLE_DOT);
         string lbl = "ATAS_S" + IntegerToString(i + 1);
         if(atasLayer.support_confluence[i])
            lbl += " | ~FINAL";
         SRVIZ_UpsertLevelLabel(SRVIZ_AtasLabelName(true, i), atasLayer.support_visual_price[i], lbl, c);

         if(atasLayer.support_confluence[i])
         {
            string confluence = "FINAL~ATAS_S" + IntegerToString(i + 1);
            SRVIZ_UpsertLevelLabel(SRVIZ_ConfluenceLabelName(true, i), atasLayer.support_price[i], confluence, SRVIZ_COLOR_CONFLUENCE_HINT);
         }
         else
         {
            SRVIZ_DeleteObject(SRVIZ_ConfluenceLabelName(true, i));
         }
      }
      else
      {
         SRVIZ_DeleteObject(SRVIZ_AtasLineName(true, i));
         SRVIZ_DeleteObject(SRVIZ_AtasLabelName(true, i));
         SRVIZ_DeleteObject(SRVIZ_ConfluenceLabelName(true, i));
      }

      if(drawAtasResistance)
      {
         color c = (i == 0 ? SRVIZ_COLOR_ATAS_PRIMARY : SRVIZ_COLOR_ATAS_SECONDARY);
         int w = (i == 0 ? 2 : 1);
         SRVIZ_UpsertHLine(SRVIZ_AtasLineName(false, i), atasLayer.resistance_visual_price[i], c, w, STYLE_DOT);
         string lbl = "ATAS_R" + IntegerToString(i + 1);
         if(atasLayer.resistance_confluence[i])
            lbl += " | ~FINAL";
         SRVIZ_UpsertLevelLabel(SRVIZ_AtasLabelName(false, i), atasLayer.resistance_visual_price[i], lbl, c);

         if(atasLayer.resistance_confluence[i])
         {
            string confluence = "FINAL~ATAS_R" + IntegerToString(i + 1);
            SRVIZ_UpsertLevelLabel(SRVIZ_ConfluenceLabelName(false, i), atasLayer.resistance_price[i], confluence, SRVIZ_COLOR_CONFLUENCE_HINT);
         }
         else
         {
            SRVIZ_DeleteObject(SRVIZ_ConfluenceLabelName(false, i));
         }
      }
      else
      {
         SRVIZ_DeleteObject(SRVIZ_AtasLineName(false, i));
         SRVIZ_DeleteObject(SRVIZ_AtasLabelName(false, i));
         SRVIZ_DeleteObject(SRVIZ_ConfluenceLabelName(false, i));
      }
   }

   string statusText = "SR Overlay (bounded, non-authoritative)\n";
   statusText += "MODE=" + SRVIZ_DisplayModeText(displayMode) + "\n";
   statusText += "FINAL=" + finalLayer.layer_class + "\n";
   statusText += SRVIZ_WrapStatusField("FINAL_REASON=", finalLayer.reason_code) + "\n";
   statusText += SRVIZ_WrapStatusField("FINAL_SOURCE=", finalLayer.source_surface) + "\n";
   statusText += "FINAL_LEVELS=S" + IntegerToString(finalLayer.support_count) + "/R" + IntegerToString(finalLayer.resistance_count) + "\n";
   statusText += "ATAS=" + atasLayer.layer_class + "\n";
   statusText += SRVIZ_WrapStatusField("ATAS_REASON=", atasLayer.reason_code) + "\n";
   statusText += SRVIZ_WrapStatusField("ATAS_SOURCE=", atasLayer.source_surface) + "\n";
   statusText += "ATAS_LEVELS=S" + IntegerToString(atasLayer.support_count) + "/R" + IntegerToString(atasLayer.resistance_count) + "\n";
   statusText += "interaction=" + finalLayer.interaction_type + " | canonical=" + finalLayer.canonical_state;
   SRVIZ_UpsertStatusLabel(statusText);

   string statusLogKey =
      SRVIZ_DisplayModeText(displayMode) + "|" +
      finalLayer.layer_class + "|" + finalLayer.reason_code + "|" + finalLayer.source_surface + "|" +
      IntegerToString(finalLayer.support_count) + "|" + IntegerToString(finalLayer.resistance_count) + "|" +
      atasLayer.layer_class + "|" + atasLayer.reason_code + "|" + atasLayer.source_surface + "|" +
      IntegerToString(atasLayer.support_count) + "|" + IntegerToString(atasLayer.resistance_count) + "|" +
      finalLayer.interaction_type + "|" + finalLayer.canonical_state;
   if(statusLogKey != gSRVizLastStatusLogKey)
   {
      PrintFormat("SRVIZ_STATUS MODE=%s FINAL_STATE=%s FINAL_REASON=%s FINAL_SOURCE=%s FINAL_COUNTS=S%d/R%d ATAS_STATE=%s ATAS_REASON=%s ATAS_SOURCE=%s ATAS_COUNTS=S%d/R%d interaction=%s canonical=%s",
                  SRVIZ_DisplayModeText(displayMode),
                  finalLayer.layer_class,
                  finalLayer.reason_code,
                  finalLayer.source_surface,
                  finalLayer.support_count,
                  finalLayer.resistance_count,
                  atasLayer.layer_class,
                  atasLayer.reason_code,
                  atasLayer.source_surface,
                  atasLayer.support_count,
                  atasLayer.resistance_count,
                  finalLayer.interaction_type,
                  finalLayer.canonical_state);
      gSRVizLastStatusLogKey = statusLogKey;
   }

   ChartRedraw();
}

void BuildUnifiedDecisionConfidence(
   RoutedRuntimeEvaluation &routed,
   RegimeClassification &reg,
   RuntimeEvaluation &eval,
   bool policyAllowed,
   string policyReason,
   UnifiedDecisionConfidence &out
)
{
   InitUnifiedDecisionConfidence(out);

   out.direction        = UnifiedDirectionText(eval.decision);
   out.raw_signal_score = UnifiedRawSignalScore(eval.decision);

   double baseConf = 0.50;

   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      double q  = routed.council.aggregate.council_quality;
      double cs = routed.council.aggregate.consensus_strength;
      baseConf = 0.50 * q + 0.50 * cs;
   }
   else
   {
      if(eval.decision == RUNTIME_ENTER_BUY || eval.decision == RUNTIME_ENTER_SELL)
         baseConf = 0.55;
      else if(eval.decision == RUNTIME_REJECT)
         baseConf = 0.52;
   }

   out.base_confidence_score = PJ_Clamp01(baseConf);
   out.confidence_score = out.base_confidence_score;

   double fit = (reg.tradability_score * 0.60) + (reg.regime_confidence * 0.40);
   out.regime_fit_score = PJ_Clamp01(fit);

   out.execution_quality_score = 0.50; // placeholder v1
   out.policy_risk_score       = 0.50; // placeholder v1

   // Advisory/SR observability context (non-authoritative carry-forward)
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      out.advisory_available = routed.council.env.atas_advisory_available;
      out.advisory_eligible = routed.council.env.atas_advisory_eligible;
      out.advisory_shadow_attached = routed.council.env.atas_shadow_attached;
      out.advisory_state = routed.council.env.atas_advisory_state;
      out.advisory_outcome = routed.council.env.atas_advisory_outcome;
      out.advisory_attachment_state = routed.council.env.atas_advisory_attachment_state;
      out.advisory_gate_reason_code = routed.council.env.atas_advisory_gate_reason_code;
      out.advisory_ineligibility_reason_code = routed.council.env.atas_advisory_ineligibility_reason_code;
      out.advisory_block_class = routed.council.env.atas_advisory_block_class;
      out.advisory_usage_state = routed.council.env.atas_advisory_usage_state;
      out.advisory_zero_effect_reason = routed.council.env.atas_advisory_zero_effect_reason;
      out.advisory_relevance_score = PJ_Clamp01(routed.council.env.atas_advisory_relevance_score);
      out.advisory_contradiction_flag = routed.council.env.atas_advisory_contradiction;
      out.advisory_hold_bias_active = routed.council.env.atas_advisory_hold_bias_active;
      out.nearest_support_price = routed.council.env.atas_nearest_support_price;
      out.nearest_resistance_price = routed.council.env.atas_nearest_resistance_price;
      out.nearest_support_distance_points = routed.council.env.atas_nearest_support_distance_points;
      out.nearest_resistance_distance_points = routed.council.env.atas_nearest_resistance_distance_points;
      out.level_interaction_type = routed.council.env.atas_level_interaction_type;
      out.level_context_supported = routed.council.env.atas_level_context_supported;
      out.level_context_obstructed = routed.council.env.atas_level_context_obstructed;
      out.level_context_degraded = routed.council.env.atas_level_context_degraded;
      out.support_resistance_observation_source = routed.council.env.atas_sr_observation_source;

      string srState = TrimString(routed.council.env.atas_advisory_level_confluence_state);
      if(StringLen(srState) <= 0)
         srState = "UNSET";
      out.support_resistance_confluence_state = srState;
      string canonicalState = TrimString(routed.council.env.atas_canonical_level_context_summary);
      if(StringLen(canonicalState) <= 0)
         canonicalState = srState;
      out.canonical_level_state = canonicalState;
      out.sr_interaction_bucket = ILV1_BucketSrInteraction(srState);
      out.sr_confluence_flag = ILV1_StateHasToken(srState, "EXTERNAL_LEVEL_CONFLUENT");
      out.sr_rejection_risk_flag =
         (ILV1_StateHasToken(srState, "REJECTION_RISK_HIGH") ||
          ILV1_StateHasToken(srState, "EXTERNAL_REJECTION_RISK_HIGH"));
      out.sr_continuation_obstructed_flag =
         (ILV1_StateHasToken(srState, "BREAKOUT_ROOM_TIGHT") ||
          ILV1_StateHasToken(srState, "CONTINUATION_OBSTRUCTED"));
      out.sr_canonical_near_flag =
         (ILV1_StateHasToken(srState, "EXTERNAL_LEVEL_NEAR") ||
          ILV1_StateHasToken(srState, "CANONICAL_NEAR"));
      out.sr_conflicted_flag = ILV1_StateHasToken(srState, "SIGNAL_CONFLICTED");

      if(StringLen(TrimString(out.level_interaction_type)) <= 0 || out.level_interaction_type == "LEVEL_CONTEXT_UNSET")
      {
         if(out.level_context_supported && !out.level_context_obstructed)
            out.level_interaction_type = "LEVEL_CONTEXT_SUPPORTED";
         else if(out.level_context_obstructed && !out.level_context_supported)
            out.level_interaction_type = "LEVEL_CONTEXT_OBSTRUCTED";
         else if(out.level_context_supported && out.level_context_obstructed)
            out.level_interaction_type = "LEVEL_CONTEXT_MIXED_CONFLICTED";
         else if(out.level_context_degraded)
            out.level_interaction_type = "LEVEL_CONTEXT_DEGRADED";
         else if(srState != "UNSET")
            out.level_interaction_type = "LEVEL_CONTEXT_NEUTRAL";
         else
            out.level_interaction_type = "LEVEL_CONTEXT_UNAVAILABLE";
      }

      if(StringLen(TrimString(out.advisory_usage_state)) <= 0 || out.advisory_usage_state == "ADVISORY_NOT_EVALUATED")
      {
         if(!out.advisory_available)
            out.advisory_usage_state = "ADVISORY_ABSENT";
         else if(!out.advisory_eligible)
            out.advisory_usage_state = "ADVISORY_BLOCKED";
         else if(out.advisory_outcome == "FLAG_FOR_OPERATOR")
            out.advisory_usage_state = "ADVISORY_USED_SOFT_SIGNAL";
         else if(out.advisory_outcome == "HOLD_FOR_REEVALUATION")
            out.advisory_usage_state = "ADVISORY_USED_HOLD_SIGNAL";
         else if(out.advisory_outcome == "DISPLAY_ONLY")
            out.advisory_usage_state = "ADVISORY_DISPLAY_ONLY";
         else
            out.advisory_usage_state = "ADVISORY_ELIGIBLE_NO_ACTION";
      }
      if(StringLen(TrimString(out.advisory_zero_effect_reason)) <= 0 || out.advisory_zero_effect_reason == "NOT_EVALUATED")
      {
         if(!out.advisory_available)
            out.advisory_zero_effect_reason = "ADVISORY_ABSENT";
         else if(!out.advisory_shadow_attached)
            out.advisory_zero_effect_reason = "SHADOW_NOT_ATTACHED";
         else if(!out.advisory_eligible)
            out.advisory_zero_effect_reason = "INELIGIBLE:" + out.advisory_ineligibility_reason_code;
         else if(out.advisory_usage_state == "ADVISORY_DISPLAY_ONLY")
            out.advisory_zero_effect_reason = "DISPLAY_ONLY_OUTCOME";
         else
            out.advisory_zero_effect_reason = "NO_ZERO_EFFECT";
      }
   }

   
   // Strategy Intelligence computation (v7A): in-place, snapshot-driven, side-effect minimal.
   gHasStrategyIntel = false;
   gHasExecEstimation = false;

   if(gPlan.strategy_intelligence_enabled && gPlan.entry_quality_scoring_enabled && gHasLastSnapshots)
   {
      ComputeEntryQualityV1(gLastM1Snapshot, reg, routed.active_mode, eval.decision, gEntryQuality);
      ComputeStrategyRegimeFitV1(reg, routed.active_mode, eval.decision, gStrategyFit);
      ComputeEntryEdgeV1(gLastM1Snapshot, reg, eval.decision, gEntryEdge);
      ComputeFollowThroughQualityV1(gLastM1Snapshot, reg, eval.decision, gFollowThrough);

      gHasStrategyIntel = true;
   }

   if(gPlan.execution_estimation_enabled && gHasLastSnapshots)
   {
      CoreDirection cd = CORE_NONE;
      if(eval.decision == RUNTIME_ENTER_BUY) cd = CORE_BUY;
      else if(eval.decision == RUNTIME_ENTER_SELL) cd = CORE_SELL;

      if(cd != CORE_NONE)
      {
         ComputeExecutionEstimationV1(gLastM1Snapshot, gLastM5Snapshot, reg, cd, gExecEstimation);
         gHasExecEstimation = gExecEstimation.valid;
      }
   }
// Strategy Intelligence Layer v1 fields (best-effort, fallback-safe)
   if(gHasStrategyIntel)
   {
      out.entry_quality_score    = gEntryQuality.entry_quality_score;
      out.timing_quality_score   = gEntryQuality.timing_quality_score;
      out.location_quality_score = gEntryQuality.location_quality_score;
      out.volatility_fit_score   = gEntryQuality.volatility_fit_score;
      out.entry_quality_label    = gEntryQuality.entry_quality_label;
      out.entry_quality_reason   = gEntryQuality.entry_quality_reason;
      out.entry_quality_flags    = gEntryQuality.entry_quality_flags;

      out.strategy_regime_fit_score = gStrategyFit.strategy_regime_fit_score;
      out.strategy_regime_fit_label = gStrategyFit.strategy_regime_fit_label;
      out.strategy_regime_reason    = gStrategyFit.strategy_regime_reason;

      if(gHasExecEstimation)
      {
         ComputeDecisionQualityV3(
            out.confidence_score,
            out.regime_fit_score,
            gEntryQuality,
            gStrategyFit,
            gEntryEdge,
            gFollowThrough,
            gExecEstimation,
            out.policy_risk_score,
            gDecisionQuality);
         out.decision_quality_version = "DQ_V3";
      }
      else
      {
         ComputeDecisionQualityV2(
            out.confidence_score,
            out.regime_fit_score,
            gEntryQuality,
            gStrategyFit,
            gEntryEdge,
            gFollowThrough,
            out.policy_risk_score,
            gDecisionQuality);
         out.decision_quality_version = "DQ_V2";
      }

      out.decision_quality_score  = gDecisionQuality.decision_quality_score;
      out.decision_quality_label  = gDecisionQuality.decision_quality_label;
      out.decision_quality_reason = gDecisionQuality.decision_quality_reason;
   }

   // L3 institutional self-learning overlay (bounded, capped, non-authoritative)
   ILV1_Adjustment ilAdj;
   ILV1_ComputeAdjustment(EnableInstitutionalSelfLearning, routed, reg, out, ilAdj);

   out.learning_confidence_delta    = ilAdj.confidence_delta;
   out.learning_caution_score       = ilAdj.caution_score;
   out.learning_context_fit_score   = ilAdj.context_fit_score;
   out.learning_evidence_count      = ilAdj.evidence_count;
   out.learning_motif_key           = ilAdj.motif_key;
   out.learning_reason_codes_csv    = ilAdj.reason_codes_csv;
   out.learning_contradiction_signal = ilAdj.contradiction_signal;
   out.learning_hold_bias           = ilAdj.hold_bias;
   out.learning_reevaluation_bias   = ilAdj.reevaluation_bias;
   out.learning_strength_band       = ilAdj.strength_band;
   out.learning_state_code          = ilAdj.state_code;
   out.learning_evidence_threshold_met = (ilAdj.applied || ilAdj.state_code == "APPLIED");
   out.learning_zero_influence_due_to_insufficient_evidence = (ilAdj.state_code == "INSUFFICIENT_EVIDENCE");

   if(ilAdj.applied)
   {
      out.confidence_score = PJ_Clamp01(out.confidence_score + ilAdj.confidence_delta);
      out.regime_fit_score = PJ_Clamp01(0.80 * out.regime_fit_score + 0.20 * ilAdj.context_fit_score);
      out.policy_risk_score = PJ_Clamp01(out.policy_risk_score + ilAdj.caution_score);
   }

   out.decision_acceptance_posture = ComputeDecisionAcceptancePostureForObservability(out, policyAllowed);
   out.decision_reasoning_flags_csv = "";
   if(out.learning_contradiction_signal || out.advisory_contradiction_flag)
      AppendDecisionReasoningFlag("CONTRADICTION_SIGNAL", out.decision_reasoning_flags_csv);
   if(out.sr_confluence_flag || out.sr_rejection_risk_flag || out.sr_continuation_obstructed_flag || out.sr_canonical_near_flag || out.sr_conflicted_flag)
      AppendDecisionReasoningFlag("LEVEL_SENSITIVE_ACCEPTANCE", out.decision_reasoning_flags_csv);
   if(out.confidence_score + 1e-8 < out.base_confidence_score)
      AppendDecisionReasoningFlag("CONFIDENCE_REDUCED_ACCEPTANCE", out.decision_reasoning_flags_csv);
   if(out.regime_fit_score < 0.45)
      AppendDecisionReasoningFlag("REGIME_FIT_IMPAIRED_ACCEPTANCE", out.decision_reasoning_flags_csv);
   if(out.learning_caution_score > 0.0 || out.advisory_hold_bias_active)
      AppendDecisionReasoningFlag("CAUTION_SHAPING_ACTIVE", out.decision_reasoning_flags_csv);
   if(out.decision_acceptance_posture == "EXCEPTIONAL")
      AppendDecisionReasoningFlag("EXCEPTIONAL_CONTEXT_ALIGNMENT", out.decision_reasoning_flags_csv);
   if(out.advisory_available && !out.advisory_eligible)
      AppendDecisionReasoningFlag("ADVISORY_INELIGIBLE_CONTEXT", out.decision_reasoning_flags_csv);
   if(out.advisory_available && out.advisory_usage_state == "ADVISORY_DISPLAY_ONLY")
      AppendDecisionReasoningFlag("ADVISORY_DISPLAY_ONLY_CONTEXT", out.decision_reasoning_flags_csv);
   if(out.level_context_obstructed)
      AppendDecisionReasoningFlag("LEVEL_CONTEXT_OBSTRUCTED", out.decision_reasoning_flags_csv);
   if(out.level_context_degraded)
      AppendDecisionReasoningFlag("LEVEL_CONTEXT_DEGRADED", out.decision_reasoning_flags_csv);

   out.final_permission = policyAllowed;

   if(!policyAllowed && StringLen(policyReason) > 0)
      out.final_decision_reason = policyReason;
   else
      out.final_decision_reason = eval.reason;

   // Bounded chart-only observability layer: final MT5 decision-ready S/R vs ATAS reference S/R.
   UpdateSupportResistanceChartOverlay(out, routed, eval);
}

//---------------------------------------------------------
// Execution helpers
//---------------------------------------------------------
bool ExecuteRuntimeBuy(const UnifiedDecisionConfidence &entryConf)
{
   TradeLevels levels;
   if(!BuildBuyTradeLevels(
         TradeRR,
         TradeATRMultiplier,
         TradeATRPeriod,
         ExtraStopBufferPoints,
         levels))
   {
      LogWarn("Runtime BUY levels failed: " + levels.reason);
      return false;
   }

   string cmt = "RBUY";
   if(StringLen(gLastEntryDecisionId) > 0)
      cmt += " D:" + gLastEntryDecisionId;

   bool ok = OpenBuyTrade(trade, Magic, FixedLot, levels.sl, levels.tp, cmt);
   if(!ok)
      return false;

   ulong entryDeal = trade.ResultDeal();
   ulong entryOrder = trade.ResultOrder();
   double actualFillPrice = trade.ResultPrice();
   if(actualFillPrice <= 0.0 && entryDeal > 0)
      actualFillPrice = HistoryDealGetDouble(entryDeal, DEAL_PRICE);

   double slippagePoints = 0.0;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point > 0.0 && levels.entry > 0.0 && actualFillPrice > 0.0)
      slippagePoints = MathAbs(actualFillPrice - levels.entry) / point;

   AdvisoryEnvelopeFields advisory;
   advisory.advisory_state = entryConf.advisory_state;
   advisory.advisory_outcome = entryConf.advisory_outcome;
   advisory.advisory_attachment_state = entryConf.advisory_attachment_state;
   advisory.advisory_gate_reason_code = entryConf.advisory_gate_reason_code;
   advisory.advisory_ineligibility_reason_code = entryConf.advisory_ineligibility_reason_code;
   advisory.advisory_block_class = entryConf.advisory_block_class;
   advisory.advisory_usage_state = entryConf.advisory_usage_state;
   advisory.advisory_zero_effect_reason = entryConf.advisory_zero_effect_reason;

   DecisionReasoningFields decision_reasoning;
   decision_reasoning.decision_acceptance_posture = entryConf.decision_acceptance_posture;
   decision_reasoning.decision_reasoning_flags_csv = entryConf.decision_reasoning_flags_csv;

   TradeCorrelation corr;
   Correlation_RegisterTradeOpenV5(
      gLastEntryDecisionId,
      entryDeal,
      entryOrder,
      (long)Magic,
      "BUY",
      "M1",
      TimeCurrent(),
      FixedLot,
      gEntryQuality.entry_quality_score,
      gEntryEdge.entry_edge_score,
      gFollowThrough.follow_through_quality_score,
      gStrategyFit.strategy_regime_fit_score,
      gDecisionQuality.decision_quality_score,
      gExecEstimation.expected_rr_estimate,
      gExecEstimation.execution_geometry_score,
      gExecEstimation.execution_geometry_label,
      gEntryQuality.entry_quality_label,
      gEntryEdge.entry_edge_label,
      gFollowThrough.follow_through_quality_label,
      gStrategyFit.strategy_regime_fit_label,
      gDecisionQuality.decision_quality_label,
      levels.entry,
      levels.sl,
      levels.tp,
      actualFillPrice,
      slippagePoints,
      entryConf.base_confidence_score,
      entryConf.confidence_score,
      entryConf.policy_risk_score,
      entryConf.regime_fit_score,
      entryConf.learning_confidence_delta,
      entryConf.learning_caution_score,
      entryConf.learning_state_code,
      entryConf.learning_evidence_count,
      entryConf.learning_evidence_threshold_met,
      entryConf.learning_zero_influence_due_to_insufficient_evidence,
      entryConf.advisory_relevance_score,
      entryConf.advisory_contradiction_flag,
      entryConf.advisory_hold_bias_active,
      entryConf.support_resistance_confluence_state,
      entryConf.canonical_level_state,
      entryConf.sr_interaction_bucket,
      entryConf.sr_confluence_flag,
      entryConf.sr_rejection_risk_flag,
      entryConf.sr_continuation_obstructed_flag,
      entryConf.sr_canonical_near_flag,
      entryConf.sr_conflicted_flag,
      entryConf.nearest_support_price,
      entryConf.nearest_resistance_price,
      entryConf.nearest_support_distance_points,
      entryConf.nearest_resistance_distance_points,
      entryConf.level_interaction_type,
      entryConf.level_context_supported,
      entryConf.level_context_obstructed,
      entryConf.level_context_degraded,
      entryConf.support_resistance_observation_source,
      entryConf.advisory_available,
      entryConf.advisory_eligible,
      entryConf.advisory_shadow_attached,
      advisory,
      decision_reasoning,
      corr
   );
   gLastOpenCorrelation = corr;

   return true;
}

bool ExecuteRuntimeSell(const UnifiedDecisionConfidence &entryConf)
{
   TradeLevels levels;
   if(!BuildSellTradeLevels(
         TradeRR,
         TradeATRMultiplier,
         TradeATRPeriod,
         ExtraStopBufferPoints,
         levels))
   {
      LogWarn("Runtime SELL levels failed: " + levels.reason);
      return false;
   }

   string cmt = "RSELL";
   if(StringLen(gLastEntryDecisionId) > 0)
      cmt += " D:" + gLastEntryDecisionId;

   bool ok = OpenSellTrade(trade, Magic, FixedLot, levels.sl, levels.tp, cmt);
   if(!ok)
      return false;

   ulong entryDeal = trade.ResultDeal();
   ulong entryOrder = trade.ResultOrder();
   double actualFillPrice = trade.ResultPrice();
   if(actualFillPrice <= 0.0 && entryDeal > 0)
      actualFillPrice = HistoryDealGetDouble(entryDeal, DEAL_PRICE);

   double slippagePoints = 0.0;
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point > 0.0 && levels.entry > 0.0 && actualFillPrice > 0.0)
      slippagePoints = MathAbs(actualFillPrice - levels.entry) / point;

   AdvisoryEnvelopeFields advisory;
   advisory.advisory_state = entryConf.advisory_state;
   advisory.advisory_outcome = entryConf.advisory_outcome;
   advisory.advisory_attachment_state = entryConf.advisory_attachment_state;
   advisory.advisory_gate_reason_code = entryConf.advisory_gate_reason_code;
   advisory.advisory_ineligibility_reason_code = entryConf.advisory_ineligibility_reason_code;
   advisory.advisory_block_class = entryConf.advisory_block_class;
   advisory.advisory_usage_state = entryConf.advisory_usage_state;
   advisory.advisory_zero_effect_reason = entryConf.advisory_zero_effect_reason;

   DecisionReasoningFields decision_reasoning;
   decision_reasoning.decision_acceptance_posture = entryConf.decision_acceptance_posture;
   decision_reasoning.decision_reasoning_flags_csv = entryConf.decision_reasoning_flags_csv;

   TradeCorrelation corr;
   Correlation_RegisterTradeOpenV5(
      gLastEntryDecisionId,
      entryDeal,
      entryOrder,
      (long)Magic,
      "SELL",
      "M1",
      TimeCurrent(),
      FixedLot,
      gEntryQuality.entry_quality_score,
      gEntryEdge.entry_edge_score,
      gFollowThrough.follow_through_quality_score,
      gStrategyFit.strategy_regime_fit_score,
      gDecisionQuality.decision_quality_score,
      gExecEstimation.expected_rr_estimate,
      gExecEstimation.execution_geometry_score,
      gExecEstimation.execution_geometry_label,
      gEntryQuality.entry_quality_label,
      gEntryEdge.entry_edge_label,
      gFollowThrough.follow_through_quality_label,
      gStrategyFit.strategy_regime_fit_label,
      gDecisionQuality.decision_quality_label,
      levels.entry,
      levels.sl,
      levels.tp,
      actualFillPrice,
      slippagePoints,
      entryConf.base_confidence_score,
      entryConf.confidence_score,
      entryConf.policy_risk_score,
      entryConf.regime_fit_score,
      entryConf.learning_confidence_delta,
      entryConf.learning_caution_score,
      entryConf.learning_state_code,
      entryConf.learning_evidence_count,
      entryConf.learning_evidence_threshold_met,
      entryConf.learning_zero_influence_due_to_insufficient_evidence,
      entryConf.advisory_relevance_score,
      entryConf.advisory_contradiction_flag,
      entryConf.advisory_hold_bias_active,
      entryConf.support_resistance_confluence_state,
      entryConf.canonical_level_state,
      entryConf.sr_interaction_bucket,
      entryConf.sr_confluence_flag,
      entryConf.sr_rejection_risk_flag,
      entryConf.sr_continuation_obstructed_flag,
      entryConf.sr_canonical_near_flag,
      entryConf.sr_conflicted_flag,
      entryConf.nearest_support_price,
      entryConf.nearest_resistance_price,
      entryConf.nearest_support_distance_points,
      entryConf.nearest_resistance_distance_points,
      entryConf.level_interaction_type,
      entryConf.level_context_supported,
      entryConf.level_context_obstructed,
      entryConf.level_context_degraded,
      entryConf.support_resistance_observation_source,
      entryConf.advisory_available,
      entryConf.advisory_eligible,
      entryConf.advisory_shadow_attached,
      advisory,
      decision_reasoning,
      corr
   );
   gLastOpenCorrelation = corr;

   return true;
}

// (removed duplicate ExecuteRuntimeSell definition in compile-fix pack)

//---------------------------------------------------------
// Plan reload from ai_current_plan.json
//---------------------------------------------------------
bool RecompileCurrentPlan()

{
   RuntimePlan reloadedPlan;
   if(!LoadRuntimePlanFromJson("AI\\ai_current_plan.json", reloadedPlan))
   {
      LogError("Failed to load ai_current_plan.json into memory");
      return false;
   }

   gPlan = reloadedPlan;

   if(!CompileRuntimePlan(gPlan, gCompiledPlan))
   {
      LogError("Failed to compile reloaded runtime plan");
      return false;
   }

   LogInfo("Active AI plan reloaded successfully from ai_current_plan.json");
   LogPlanArchitectureSummary();
   LogCompiledArchitectureSummary();

   return true;
}

//---------------------------------------------------------
// Runtime decision logging
//---------------------------------------------------------
void LogRuntimeEvaluation(RuntimeEvaluation &eval)
{
   if(!LogRuntimeDecision)
      return;

   string d = "UNKNOWN";
   switch(eval.decision)
   {
      case RUNTIME_ENTER_BUY:  d = "BUY";  break;
      case RUNTIME_ENTER_SELL: d = "SELL"; break;
      case RUNTIME_WAIT:       d = "WAIT"; break;
      case RUNTIME_REJECT:     d = "REJECT"; break;
      default:                 d = "UNKNOWN"; break;
   }

   LogStateOnce("Runtime decision=" + d + " | reason=" + eval.reason);
}

void LogRoutedRuntimeEvaluation(RoutedRuntimeEvaluation &routed)
{
   if(!LogRuntimeDecision)
      return;

   if(routed.active_mode == "COUNCIL")
   {
      string prefix = "Runtime decision (" + routed.active_mode + "): ";
      if(gHasRegime)
         prefix += "[Regime=" + gRegime.regime_label + " conf=" + DoubleToString(gRegime.regime_confidence, 2) + " trad=" + DoubleToString(gRegime.tradability_score, 2) + "] ";

      if(routed.base_eval.decision == RUNTIME_ENTER_BUY)
      {
         LogInfo(prefix + "BUY | " + routed.base_eval.reason);
         return;
      }

      if(routed.base_eval.decision == RUNTIME_ENTER_SELL)
      {
         LogInfo(prefix + "SELL | " + routed.base_eval.reason);
         return;
      }

      if(routed.base_eval.decision == RUNTIME_REJECT)
      {
         LogStateOnce(prefix + "REJECT | " + routed.base_eval.reason);
         return;
      }

      LogStateOnce(prefix + "WAIT | " + routed.base_eval.reason);
      return;
   }

   LogRuntimeEvaluation(routed.base_eval);
}

//---------------------------------------------------------
// Init / Deinit
//---------------------------------------------------------

//---------------------------------------------------------
// Phase 9B: minimal orchestration helpers (behavior-preserving)
//---------------------------------------------------------
void CacheLastSnapshots(const TimeframeSnapshot &m1, const TimeframeSnapshot &m5)
{
   gLastM1Snapshot = m1;
   gLastM5Snapshot = m5;
}
void FinalizeCouncilClosedTradeIfEnabled()
{
   string councilCloseLog = "";
   FinalizeCouncilClosedTrade(
      Magic,
      _Symbol,
      "AI\\council_feedback.json",
      councilCloseLog
   );
   LogStateOnce(councilCloseLog);
}

void TryAppendCouncilOutcomeAttribution(const TradeFeedbackRecord &fb)
{
   if(!gPlan.council_outcome_attribution_enabled) return;

   string dom = "";
   int ac = 0, oc = 0, nc = 0;
   double acon = 0.0;
   string aIds = "", oIds = "", nIds = "", comp = "";

   if(PJ_LoadCouncilAttributionMetaByPositionId(
         PERF_JOURNAL_PATH,
         fb.position_id,
         300,
         dom,
         ac,
         oc,
         nc,
         acon,
         aIds,
         oIds,
         nIds,
         comp))
   {
      string caOutLog = "";
      JournalAppendCouncilOutcomeAttribution(
         fb,
         dom,
         ac,
         oc,
         nc,
         acon,
         aIds,
         oIds,
         nIds,
         comp,
         caOutLog
      );
      LogStateOnce(caOutLog);
   }
}

int OnInit()
{
   LogSeparator();
   LogInfo("Initializing main EA...");
   // Controlled storage reset (pre Strategy Confidence Memory v1) - one-time, best-effort.
   string storageResetLog = "";
   if(StorageReset_PreStrategyMemoryV1_RunOnce(storageResetLog))
      LogInfo(storageResetLog);

   // Strategy Confidence Memory v1 (observer-only)
   string scmLog = "";
   SCM_Init(gSCMCache, scmLog);
   LogInfo(scmLog);

   string ilInitLog = "";
   ILV1_Initialize(EnableInstitutionalSelfLearning, ilInitLog);
   LogInfo(ilInitLog);


   if(!LoadDefaultPersonality(gPersonality))
   {
      LogError("Failed to load personality");
      return INIT_FAILED;
   }

   if(!LoadDefaultPlan(gPlan))
   {
      LogError("Failed to load default runtime plan");
      return INIT_FAILED;
   }

   LoadDefaultAISecrets(gAISecrets);

   LoadPersonalityFromJson("AI\\ai_personality_profile.json", gPersonality);
   LoadAISecretsFromJson("AI\\ai_runtime_secrets.json", gAISecrets);

   RuntimePlan livePlan;
   if(LoadRuntimePlanFromJson("AI\\ai_current_plan.json", livePlan))
      gPlan = livePlan;

   string truthInitLog = "";
   if(EnforceAuthoritativePlanTruth(truthInitLog))
      LogInfo(truthInitLog);
   else
      LogWarn(truthInitLog);

   BuildIndicatorLibrary();
   BuildStrategyLibrary();
   BuildEntryPatternLibrary();
   BuildRiskModelLibrary();
   BuildFilterLibrary();

   LogInfo("Libraries initialized successfully");
   LogInfo("Indicators loaded: " + IntegerToString(gIndicatorCount));
   LogInfo("Strategies loaded: " + IntegerToString(gStrategyCount));
   LogInfo("Entry patterns loaded: " + IntegerToString(gEntryPatternCount));
   LogInfo("Risk models loaded: " + IntegerToString(gRiskModelCount));
   LogInfo("Filters loaded: " + IntegerToString(gFilterCount));

   if(!CompileRuntimePlan(gPlan, gCompiledPlan))
   {
      LogError("Failed to compile runtime plan");
      return INIT_FAILED;
   }

   LogInfo("Loaded personality: " + gPersonality.profile_name);
   LogPlanArchitectureSummary();
   LogCompiledArchitectureSummary();

   bool aiBridgeReady = AIIsReady(gAISecrets);
   if(aiBridgeReady)
      LogInfo("AI bridge transport is configured");
   else
      LogWarn("AI bridge transport is not ready yet");

   LogInfo("Architecture mode: EXECUTION SANDBOX + ROUTED RUNTIME + AI INTELLIGENCE & OVERSIGHT GATE");

   string performanceJournalBootstrapLog = "";
   if(PJ_EnsureJournalBootstrap(performanceJournalBootstrapLog))
   {
      if(performanceJournalBootstrapLog == "performance_journal_bootstrapped_empty")
         LogInfo("Performance journal bootstrap completed | state=empty_valid_surface_created");
   }
   else if(StringLen(performanceJournalBootstrapLog) > 0)
   {
      LogWarn("Performance journal bootstrap degraded | reason=" + performanceJournalBootstrapLog);
   }

   gRuntimeGovernanceStartupComplete = true;
   RefreshRuntimeGovernanceAndSafetyStatusBestEffort();

   RuntimeHonestyLogStartupWarningsOnce(
      EnableCouncilActivationPressureGate,
      EnableCouncilDirtyEnvironmentTightening,
      EnableCouncilExecutionQualityGate,
      EnableCouncilLiveExitArchitecture,
      EnableAICandidateBlock,
      EnableEmergencyFlatOnCriticalSafetyState,
      EnableInternalDashboardChartUI,
      EnableAutoRollback,
      EnableATASGovernedAdvisory,
      ATASAdvisoryRolloutMode
   );

   RuntimeHonestyEmitSurfacesBestEffort(
      gPlan.plan_id,
      (StringLen(TrimString(gRuntimeGovernance.active_mode)) > 0
         ? gRuntimeGovernance.active_mode
         : NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode)),
      EnableRuntimeExecution,
      OneTradeAttemptPerBar,
      EnableRuntimeRiskSafetyHardening,
      EnableCouncilActivationPressureGate,
      EnableCouncilDirtyEnvironmentTightening,
      EnableCouncilExecutionQualityGate,
      EnableCouncilLiveExitArchitecture,
      EnableAICandidateBlock,
      EnableCouncilSetupLifecycle,
      EnableCouncilTrendContinuationConfirmationReinforcement,
      EnableEmergencyFlatOnCriticalSafetyState,
      EnableInternalDashboardChartUI,
      EnableAutoRollback,
      EnableATASGovernedAdvisory,
      ATASAdvisoryRolloutMode
   );

   DiagnosticRuntimeSeedCycleBase("runtime_init");
   DiagnosticRuntimeSetOutcome(
      "INIT_PENDING",
      (!gRuntimeGovernance.trading_allowed),
      (gRuntimeGovernance.trading_allowed ? "" : "runtime_governance_block"),
      gRuntimeGovernance.reason_code,
      "INIT_STATUS_ONLY",
      "runtime_init_status"
   );
   SaveDiagnosticRuntimeSummaryBestEffort();
   UpdateLastMeaningfulRuntimeEventBestEffort("POSTURE_STATUS",
                                              "",
                                              "",
                                              gRuntimeGovernance.reason_code,
                                              "",
                                              "Runtime initialization established the current governed posture.",
                                              "runtime_initialization");
   RefreshExecutionQualityValidationArtifactsBestEffort();

   RefreshRuntimeGovernanceAndSafetyStatusBestEffort();
   RefreshAIActivationReadinessStatusBestEffort();
   RefreshAtasGovernedAdvisoryArtifactsBestEffort(
      EnableATASGovernedAdvisory,
      ATASAdvisoryRolloutMode,
      gAtasGovernedAdvisoryStatus,
      gAtasGovernedAdvisoryStatusInitialized,
      gAtasGovernedAdvisoryEffectiveness,
      gAtasGovernedAdvisoryEffectivenessInitialized,
      gAtasGovernedAdvisoryHold,
      gAtasGovernedAdvisoryHoldInitialized
   );
   CouncilAIAdvisoryLoadEffectivenessFromDiskBestEffort();
   RefreshCouncilAIAdvisoryArtifactsBestEffort();
   PollSourceIntakeGatewayBestEffort(true);
   RefreshActiveOperatingCohortStatusBestEffort();
   RefreshExecutionAuthorityStatusBestEffort();
   RefreshOperationalIntegrityStatusBestEffort();

   if(gRuntimeGovernance.trading_allowed)
      LogInfo("Runtime governance ready | state=" + gRuntimeGovernance.governance_state + " | reason=" + gRuntimeGovernance.reason_code);
   else
      LogWarn("Runtime governance not ready for trading | state=" + gRuntimeGovernance.governance_state + " | reason=" + gRuntimeGovernance.reason_code);

   if(gRuntimeRiskSafety.trading_allowed)
      LogInfo("Runtime risk/safety ready | state=" + gRuntimeRiskSafety.safety_state + " | reason=" + gRuntimeRiskSafety.safety_reason_code);
   else
      LogWarn("Runtime risk/safety protective mode | state=" + gRuntimeRiskSafety.safety_state + " | reason=" + gRuntimeRiskSafety.safety_reason_code);

   LogInfo("AI authority gate | authority=" + gAIAuthorityReadiness.authority_state +
           " | readiness=" + gAIAuthorityReadiness.readiness_state +
           " | reason=" + gAIAuthorityReadiness.readiness_reason_code +
           " | next_blocker=" + gAIAuthorityReadiness.next_upgrade_blocker);

   DashboardPhase1Initialize();
   EventSetTimer(DASHBOARD_TIMER_SECONDS);
   // [DISCONNECTED_OPERATOR_SURFACE: INTERNAL_DASHBOARD_CHART_UI] flag=false; DashboardPhase1Initialize and EventSetTimer execute regardless; this flag gates rendering output only
   if(EnableInternalDashboardChartUI)
   {
      LogInfo("Dashboard Phase 1 read-only rendering initialized (chart UI enabled)");
   }
   else
   {
      DashboardRemoveAllRendering();
      LogInfo("Dashboard Phase 1 collector/status path initialized with chart UI soft-disabled");
   }

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
   EventKillTimer();
   SRVIZ_ClearAll();
   DashboardPhase1Shutdown();
   LogInfo("EA deinitialized");
}

void RefreshAtasRuntimeStatusHeartbeatBestEffort()
{
   int interval_sec = AtasStatusHeartbeatIntervalSec;
   if(interval_sec < 1)
      interval_sec = 1;

   datetime now_ts = TimeCurrent();
   if(gAtasStatusHeartbeatLastRefresh > 0 &&
      (now_ts - gAtasStatusHeartbeatLastRefresh) < interval_sec)
      return;

   bool base_environment_valid = (TerminalInfoInteger(TERMINAL_CONNECTED) != 0);
   string acceptance_state = "";
   string rejection_reason = "";
   AtasRefreshRuntimeContextStatusHeartbeat(
      _Symbol,
      base_environment_valid,
      acceptance_state,
      rejection_reason
   );
   gAtasStatusHeartbeatLastRefresh = now_ts;
}

void OnTimer()
{
   RefreshAtasRuntimeStatusHeartbeatBestEffort();

   if(EnableInternalDashboardChartUI)
   {
      DashboardPhase1OnTimer();
      return;
   }

   DashboardProcessPendingActions();
   DashboardRemoveAllRendering();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(!EnableInternalDashboardChartUI)
      return;

   DashboardPhase1OnChartEvent(id, lparam, dparam, sparam);
}

//---------------------------------------------------------
// Main
//---------------------------------------------------------
void OnTick()
{
   TimeframeSnapshot m1;
   TimeframeSnapshot m5;

   if(!BuildTimeframeSnapshot(PERIOD_M1, m1))
   {
      LogWarn("Failed to build M1 snapshot");
      return;
   }

   if(!BuildTimeframeSnapshot(PERIOD_M5, m5))
   {
      LogWarn("Failed to build M5 snapshot");

      gLastM1Snapshot = m1;
      gLastM5Snapshot = m5;
      gHasLastSnapshots = true;

      return;
   }

   RefreshRuntimeGovernanceAndSafetyStatusBestEffort();
   RefreshAIActivationReadinessStatusBestEffort();
   RefreshAtasGovernedAdvisoryArtifactsBestEffort(
      EnableATASGovernedAdvisory,
      ATASAdvisoryRolloutMode,
      gAtasGovernedAdvisoryStatus,
      gAtasGovernedAdvisoryStatusInitialized,
      gAtasGovernedAdvisoryEffectiveness,
      gAtasGovernedAdvisoryEffectivenessInitialized,
      gAtasGovernedAdvisoryHold,
      gAtasGovernedAdvisoryHoldInitialized
   );
   RefreshAtasRuntimeStatusHeartbeatBestEffort();
   RefreshCouncilAIAdvisoryArtifactsBestEffort();
   PollSourceIntakeGatewayBestEffort(false);
   RefreshActiveOperatingCohortStatusBestEffort();
   RefreshExecutionAuthorityStatusBestEffort();
   RefreshOperationalIntegrityStatusBestEffort();

   if(RuntimeRiskSafetyEmergencyFlatActive())
   {
      string emergencyFlatLog = "";
      ApplyEmergencyFlatBestEffort(emergencyFlatLog);
      if(StringLen(emergencyFlatLog) > 0)
         LogStateOnce(emergencyFlatLog);
   }

   if(RuntimeRiskSafetyAllowsOpenPositionManagement())
   {
      // [ARCHITECTURE_SWITCH: LIVE_EXIT_ARCHITECTURE] flag=false; selects ManageOpenPositionsAdvanced (true-path) vs base ManageOpenPositions (false-path); both paths are live; advanced path dormant-by-config
      if(EnableCouncilLiveExitArchitecture)
      {
         CouncilLiveExitConfig _cfg; InitCouncilLiveExitConfig(_cfg);
         _cfg.enabled = true;
         _cfg.premise_death_m5_bars      = CouncilExitPremiseDeathM5Bars;
         _cfg.min_progress_to_keep       = CouncilExitMinProgressToKeep;
         _cfg.giveback_trigger_progress  = CouncilExitGivebackTriggerProgress;
         _cfg.giveback_retained_floor    = CouncilExitGivebackRetainedFloor;
         ManageOpenPositionsAdvanced(trade, Magic, _cfg);
      }
      else
      {
         ManageOpenPositions(trade, Magic);
      }
   }
   else
   {
      LogStateOnce("Open position management withheld by risk/safety | state=" + gRuntimeRiskSafety.safety_state + " | reason=" + gRuntimeRiskSafety.safety_reason_code);
   }

bool newBar = IsNewM1Bar();

   //------------------------------------------------------
   // Meta-Governor cycle + runtime execution
   //------------------------------------------------------
   if(newBar)
   {
      gM1BarCounter++;

      RuntimeHonestyEmitSurfacesBestEffort(
         gPlan.plan_id,
         (StringLen(TrimString(gRuntimeGovernance.active_mode)) > 0
            ? gRuntimeGovernance.active_mode
            : NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode)),
         EnableRuntimeExecution,
         OneTradeAttemptPerBar,
         EnableRuntimeRiskSafetyHardening,
         EnableCouncilActivationPressureGate,
         EnableCouncilDirtyEnvironmentTightening,
         EnableCouncilExecutionQualityGate,
         EnableCouncilLiveExitArchitecture,
         EnableAICandidateBlock,
         EnableCouncilSetupLifecycle,
         EnableCouncilTrendContinuationConfirmationReinforcement,
         EnableEmergencyFlatOnCriticalSafetyState,
         EnableInternalDashboardChartUI,
         EnableAutoRollback,
         EnableATASGovernedAdvisory,
         ATASAdvisoryRolloutMode
      );

      //---------------------------------------------------
      // Performance snapshot
      //---------------------------------------------------
      PerformanceSnapshot perf;
      bool perfOk = BuildPerformanceSnapshot(Magic, perf);

      bool timeTrigger = (EvolutionEveryNBars > 0 && (gM1BarCounter % EvolutionEveryNBars == 0));
      bool perfTrigger = (perfOk && perf.underperformance);
      bool cooldownOk  = ((gM1BarCounter - gLastEvolutionBar) >= EvolutionCooldownBars);

      //---------------------------------------------------
      // AI Intelligence & Oversight gate (H6)
      //---------------------------------------------------
      if(EnableAIEvolution && cooldownOk && (timeTrigger || perfTrigger))
      {
         RefreshAIActivationReadinessStatusBestEffort();

         string aiGateReason = "";
         bool aiShadowAllowed = AIAuthorityAllowsShadow(aiGateReason);
         bool aiProposalAllowed = AIAuthorityAllowsBoundedProposalGeneration(aiGateReason);

         if(!aiShadowAllowed)
         {
            LogStateOnce("AI authority gate blocked AI activity | authority=" + gAIAuthorityReadiness.authority_state +
                         " | readiness=" + gAIAuthorityReadiness.readiness_state +
                         " | reason=" + aiGateReason);
         }
         else if(!aiProposalAllowed)
         {
            LogStateOnce("AI bounded proposal generation withheld by H6 | authority=" + gAIAuthorityReadiness.authority_state +
                         " | reason=" + aiGateReason +
                         " | proposals_remain_review_governed_only");
         }
         else
         {
            string performanceJson = perfOk
               ? PerformanceSnapshotToJson(perf)
               : "{\"underperformance\":false,\"reason\":\"performance unavailable\"}";

            string evoLog = "";

            bool evoOk = RunEvolutionProposal(
               gAISecrets,
               gPersonality,
               "AI\\ai_current_plan.json",
               "AI\\ai_strategy_memory.json",
               "AI\\ai_evolution_state.json",
               "AI\\ai_governor_state.json",
               "AI\\ai_trade_feedback.json",
               performanceJson,
               "AI\\ai_next_plan_proposal.json",
               "AI\\ai_last_evolution_raw.txt",
               evoLog
            );

            gLastEvolutionBar = gM1BarCounter;

            LogInfo(evoLog);

            if(LogEvolutionRawResponse)
            {
               string rawTxt = "";
               if(LoadTextFile("AI\\ai_last_evolution_raw.txt", rawTxt))
                  LogInfo("Last evolution raw response saved to AI\\ai_last_evolution_raw.txt");
            }

            string truthPostEvolutionLog = "";
            if(EnforceAuthoritativePlanTruth(truthPostEvolutionLog))
               LogStateOnce(truthPostEvolutionLog);
            else
               LogWarn(truthPostEvolutionLog);

            RefreshAIActivationReadinessStatusBestEffort();

            if(evoOk && EnableAutoApplyPlan)
            {
               LogWarn("H6 auto-apply blocked: proposal retained for review only | authority=" +
                       gAIAuthorityReadiness.authority_state +
                       " | direct_control_allowed=false | auto_apply_allowed=false");
            }
         }
      }

      //---------------------------------------------------
      // Rollback monitoring
      //---------------------------------------------------
      if(EnableAutoRollback)
      {
         // Non-activation contract: this loop only evaluates externally armed rollback state.
         // It does not arm monitoring by itself.
         RollbackState rb;
         if(LoadRollbackState(RollbackStatePath(), rb))
         {
            if(rb.monitoring_active)
            {
               PerformanceSnapshot perfCheck;
               if(BuildPerformanceSnapshot(Magic, perfCheck))
               {
                  bool rollbackDecision = false;
                  string rollbackReason = "";

                  if(ShouldRollbackNow(rb, perfCheck, rollbackDecision, rollbackReason))
                  {
                     if(rollbackDecision)
                     {
                        string applyRollbackLog = "";
                        bool rollbackApplied = ApplyRollbackFromBackup(
                           "AI\\ai_current_plan.json",
                           "AI\\ai_previous_plan_backup.json",
                           applyRollbackLog
                        );

                        LogWarn(applyRollbackLog + " | reason=" + rollbackReason);

                        if(rollbackApplied)
                        {
                           string truthAfterRollbackLog = "";
                           if(EnforceAuthoritativePlanTruth(truthAfterRollbackLog))
                              LogInfo(truthAfterRollbackLog);
                           else
                              LogWarn(truthAfterRollbackLog);

                           RecompileCurrentPlan();

                           gRuntimeGovernanceRollbackRecoveryPending = true;
                           RefreshRuntimeGovernanceAndSafetyStatusBestEffort();

                           string stopRbLog = "";
                           StopRollbackMonitoring(RollbackStatePath(), stopRbLog);
                           LogInfo(stopRbLog);
                        }
                     }
                     else
                     {
                        int newTrades = perfCheck.closed_trades - rb.baseline_closed_trades;
                        if(newTrades >= rb.min_trades_before_judgment)
                        {
                           string stopRbLog = "";
                           StopRollbackMonitoring(RollbackStatePath(), stopRbLog);
                           LogInfo("Candidate plan accepted permanently | " + rollbackReason);
                           LogInfo(stopRbLog);
                        }
                     }
                  }
               }
            }
         }
      }

      //---------------------------------------------------
      // Trade feedback logging from latest closed deal
      //---------------------------------------------------
      bool processedClosedDeal = false;
      if(EnableTradeFeedbackLogging)
      {
         string feedbackLog = "";
         TradeFeedbackRecord fb;

         if(SaveLatestClosedTradeFeedbackEx(
               Magic,
               gPlan,
               m1,
               m5,
               "AI\\ai_trade_feedback.json",
               fb,
               feedbackLog))
         {
            processedClosedDeal = true;
            FailureClassification tfail;
            ClassifyTradeFailureV1(fb, tfail);

            fb.failure_class = tfail.failure_class;
            fb.failure_reason_summary = tfail.failure_reason_summary;
            fb.failure_severity = tfail.failure_severity;
            fb.failure_basis = tfail.failure_basis;

            fb.policy_state = (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL");
            fb.policy_state_reason = (gHasRiskPolicy ? gRiskPolicy.reason : "");


            // Correlation upgrade (position_id/journal) - fallback safe
            TradeCorrelation tc;
            Correlation_ResolveForClosedDeal(fb.close_deal_id, Magic, fb.decision_id, tc);
            if(StringLen(tc.decision_id) > 0)
               fb.decision_id = tc.decision_id;

            fb.correlated_decision_id = tc.correlated_decision_id;
            fb.correlation_method = tc.correlation_method;
            fb.correlation_quality = tc.correlation_quality;
            fb.position_id = tc.position_id;
            fb.entry_deal_id = tc.entry_deal_id;
            fb.entry_order_id = tc.entry_order_id;
            fb.close_deal_id = tc.close_deal_id;

            if(EnableInstitutionalSelfLearning)
            {
               string ilEnrichLog = "";
               ILV1_EnrichTradeFeedbackContext(fb, ilEnrichLog);
               if(StringLen(ilEnrichLog) > 0)
                  LogStateOnce(ilEnrichLog);

               string ilOutcomeLog = "";
               ILV1_RecordClosedTradeOutcome(fb, ilOutcomeLog);
               if(StringLen(ilOutcomeLog) > 0)
                  LogStateOnce(ilOutcomeLog);
            }

            string pjLog = "";
            JournalAppendTrade(fb, pjLog);

            // Strategy Confidence Memory v1 (observer-only): closed trade outcome linked to strategy_id
            {
               string sid = (StringLen(fb.linked_runtime_strategy_id) > 0 ? fb.linked_runtime_strategy_id : fb.main_trigger_name);
               string fam = (StringLen(fb.linked_runtime_strategy_family) > 0 ? fb.linked_runtime_strategy_family : LAB_InferFamilyFromStrategyId(sid));
               string strategyIdentitySource = (StringLen(fb.linked_runtime_strategy_id) > 0 ? "ILV1_CONTEXT_LINKED" : "TRADE_FEEDBACK_MAIN_TRIGGER");
               SCM_RecordClosedTradeOutcome(
                  gSCMCache,
                  fb.symbol,
                  fb.decision_id,
                  sid,
                  sid,
                  fam,
                  "", // zone semantic may be unavailable in feedback v1
                  fb.regime_label,
                  fb.direction,
                  fb.result,
                  fb.position_id,
                  fb.close_deal_id,
                  fb.entry_deal_id,
                  fb.close_time,
                  strategyIdentitySource
               );
            }
            LogStateOnce(pjLog);
            RefreshExecutionQualityValidationArtifactsBestEffort();

            DiagnosticRuntimeRecordTradeClose(fb);
            SaveDiagnosticRuntimeSummaryBestEffort();
            UpdateLastMeaningfulRuntimeEventBestEffort("TRADE_CLOSED",
                                                       fb.main_trigger_name,
                                                       LAB_InferFamilyFromStrategyId(fb.main_trigger_name),
                                                       fb.result,
                                                       fb.direction,
                                                       "Closed trade outcome captured for bounded operational review.",
                                                       "trade_feedback",
                                                       fb.decision_id);

            // Phase 8A/8B: Council outcome attribution record (optional, best-effort)
            TryAppendCouncilOutcomeAttribution(fb);
            // Commit dedup pointer only after full handling (journal + optional council outcome attribution)
            TradeFeedback_CommitLastRecordedDealTicket(fb.close_deal_id);

          }

          LogStateOnce(feedbackLog);
      }
      if(processedClosedDeal)
         FinalizeCouncilClosedTradeIfEnabled();
      
      
  

      //---------------------------------------------------
      // Runtime governance gate (H1)
      //---------------------------------------------------
      RefreshRuntimeGovernanceAndSafetyStatusBestEffort();

      string runtimeGovernanceReason = "";
      if(!RuntimeGovernanceAllowsTrading(runtimeGovernanceReason))
      {
         LogStateOnce("Runtime governance blocked trading | state=" + gRuntimeGovernance.governance_state + " | reason=" + runtimeGovernanceReason);

         DiagnosticRuntimeSeedCycleBase("runtime_governance_gate");
         DiagnosticRuntimeSetOutcome(
            "BLOCKED",
            true,
            "runtime_governance_block",
            runtimeGovernanceReason,
            "BLOCKED_BEFORE_DECISION",
            "runtime_governance_blocked_new_bar"
         );
         SaveDiagnosticRuntimeSummaryBestEffort();
         UpdateLastMeaningfulRuntimeEventBestEffort("POSTURE_BLOCK",
                                                    "",
                                                    "",
                                                    runtimeGovernanceReason,
                                                    "",
                                                    "Runtime governance blocked new decision flow before evaluation.",
                                                    "runtime_governance");
         RefreshReplayValidationArtifactsBestEffort();
         RefreshExecutionQualityValidationArtifactsBestEffort();

         RuntimeGovernanceAcknowledgeRecoveryCycle();
         return;
      }

      string runtimeSafetyReason = "";
      if(!RuntimeRiskSafetyAllowsNewEntries(runtimeSafetyReason))
      {
         if(RuntimeRiskSafetyEmergencyFlatActive())
         {
            string emergencyFlatLog = "";
            ApplyEmergencyFlatBestEffort(emergencyFlatLog);
            if(StringLen(emergencyFlatLog) > 0)
               LogStateOnce(emergencyFlatLog);
         }

         LogStateOnce("Runtime risk/safety blocked new entries | state=" + gRuntimeRiskSafety.safety_state + " | reason=" + runtimeSafetyReason);

         DiagnosticRuntimeSeedCycleBase("runtime_risk_safety_gate");
         DiagnosticRuntimeSetOutcome(
            "BLOCKED",
            true,
            "risk_safety_block",
            runtimeSafetyReason,
            "BLOCKED_BEFORE_DECISION",
            "runtime_risk_safety_blocked_new_bar"
         );
         SaveDiagnosticRuntimeSummaryBestEffort();
         UpdateLastMeaningfulRuntimeEventBestEffort("GUARDRAIL_BLOCK",
                                                    "",
                                                    "",
                                                    runtimeSafetyReason,
                                                    "",
                                                    "Runtime risk/safety blocked new entries before decision routing.",
                                                    "risk_safety");
         RefreshReplayValidationArtifactsBestEffort();

         RuntimeGovernanceAcknowledgeRecoveryCycle();
         return;
      }

      RuntimeGovernanceAcknowledgeRecoveryCycle();

      //---------------------------------------------------
      // Regime Classification Layer v1 (before decision router)
      //---------------------------------------------------
      BuildRegimeClassificationV1(m1, m5, gRegime);
      gHasRegime = true;

      LogStateOnce(
         "Regime | label=" + gRegime.regime_label +
         " | conf=" + DoubleToString(gRegime.regime_confidence, 2) +
         " | trad=" + DoubleToString(gRegime.tradability_score, 2) +
         " | vol=" + gRegime.volatility_state +
         " | struct=" + gRegime.structure_state +
         " | " + gRegime.summary_reason
      );

      
      //---------------------------------------------------
      // Risk State Policy Engine v1 (optional)
      //---------------------------------------------------
      gHasRiskPolicy = false;
      InitRiskPolicySnapshot(gRiskPolicy);

      if(gPlan.risk_state_policy_enabled)
      {
         PerformanceSnapshot perfNow;
         if(BuildPerformanceSnapshot(Magic, perfNow))
         {
            string riskDbg = "";
            ComputeRiskPolicyStateV1(gPlan, perfNow, gRiskPolicy, riskDbg);
            gHasRiskPolicy = true;
            LogStateOnce("RiskPolicy | " + riskDbg);
         }
         else
         {
            LogWarn("RiskPolicy snapshot failed");
         }
      }

      //---------------------------------------------------
      // Journal analytics (Failure Clustering + Regime Performance) v1
      //---------------------------------------------------
      gHasFailureCluster = false;
      InitFailureClusterResult(gFailureCluster);

      gHasRegimePerf = false;
      InitRegimePerformanceSummary(gRegimePerf);

      if(gPlan.failure_clustering_enabled)
      {
         AnalyzeFailureClusteringV1(PERF_JOURNAL_PATH, gPlan.failure_cluster_window, gFailureCluster);
         gHasFailureCluster = true;

         int perfWin = MathMax(12, gPlan.failure_cluster_window);
         AnalyzeRegimePerformanceV1(PERF_JOURNAL_PATH, MathMax(20, perfWin), gRegimePerf);
         gHasRegimePerf = true;

         LogStateOnce("FailureCluster | " + gFailureCluster.cluster_reason_summary);
         LogStateOnce("RegimePerf | " + gRegimePerf.summary_reason);

         if(gHasRiskPolicy)
            RiskPolicyApplyFailureClusterV1(gFailureCluster, gRiskPolicy);
      }

      //---------------------------------------------------
      // Rollback signal hooks v1 (no action, logging only)
      //---------------------------------------------------
      gHasRollbackSignal = false;
      InitRollbackSignal(gRollbackSignal);

      PerformanceSnapshot perfForRb;
      if(BuildPerformanceSnapshot(Magic, perfForRb))
      {
         FailureClusterResult rbCluster = gFailureCluster;
         RegimePerformanceSummary rbPerf = gRegimePerf;

         ComputeRollbackSignalV1(rbCluster, rbPerf, perfForRb.consecutive_losses, gRollbackSignal);
         gHasRollbackSignal = true;

         if(gRollbackSignal.state != RB_NONE)
            LogWarn("RollbackSignal | " + gRollbackSignal.state_text + " | " + gRollbackSignal.rollback_signal_reason);
      }


string regimeBlockReason = "";
      if(!RegimeFilterAllows(gPlan, gRegime, regimeBlockReason))
      {
         LogStateOnce("Decision blocked by regime filter | " + regimeBlockReason + " | " + gRegime.summary_reason);

         RoutedRuntimeEvaluation dummyRouted;
         InitRoutedRuntimeEvaluation(dummyRouted);
         dummyRouted.active_mode = "N/A";
         dummyRouted.valid = true;

         RuntimeEvaluation dummyEval;
         dummyEval.decision = RUNTIME_WAIT;
         dummyEval.reason   = "blocked_by_regime_filter";

         UnifiedDecisionConfidence conf;
         BuildUnifiedDecisionConfidence(dummyRouted, gRegime, dummyEval, false, regimeBlockReason, conf);

         gCurrentDecisionId = PJ_MakeDecisionId();
         InitFailureClassification(gDecisionFailure);
         ClassifyDecisionFailureV1(conf, gRegime, "BLOCKED:" + regimeBlockReason, "", gDecisionFailure);

         string pjLog = "";
         if(dummyRouted.active_mode == "COUNCIL")
            PJ_SetZoneCoverageSnapshot(dummyRouted.council.zone_coverage.coverage_label, dummyRouted.council.zone_coverage.diversity_score, dummyRouted.council.zone_coverage.concentration_score);
         else
            PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);
         PJ_SetDecisionValidationContext(
            "regime_filter_block",
            regimeBlockReason,
            "BLOCKED_BY_REGIME_FILTER",
            "BLOCKED",
            ""
         );
         JournalAppendDecisionV3(
            gCurrentDecisionId,
            gPlan,
            dummyRouted.active_mode,
            m1,
            gRegime,
            conf,
            dummyEval,
            "BLOCKED:" + regimeBlockReason,
            (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL"),
            (gHasRiskPolicy ? gRiskPolicy.reason : ""),
            gDecisionFailure.failure_class,
            gDecisionFailure.failure_reason_summary,
            gDecisionFailure.failure_severity,
            gDecisionFailure.failure_basis,
            "",
            "",
            "",
            (gHasRollbackSignal ? gRollbackSignal.state_text : "NONE"),
            (gHasRollbackSignal ? gRollbackSignal.rollback_signal_score : 0.0),
            (gHasRollbackSignal ? gRollbackSignal.rollback_signal_reason : ""),
            (gHasFailureCluster ? gFailureCluster.clustered_failure_detected : false),
            (gHasFailureCluster ? gFailureCluster.dominant_failure_class : "UNKNOWN_FAILURE"),
            (gHasFailureCluster ? gFailureCluster.dominant_failure_count : 0),
            (gHasFailureCluster ? gFailureCluster.failure_cluster_score : 0.0),
            (gHasFailureCluster ? gFailureCluster.dominant_regime_if_any : ""),
            (gHasRegimePerf ? gRegimePerf.summary_reason : ""),
            pjLog
         );
         LogStateOnce(pjLog);
         RefreshExecutionQualityValidationArtifactsBestEffort();
         MaybeRunShadowReplayAndLog(m1, m5, gRegime, dummyRouted, dummyEval, conf, gCurrentDecisionId);

         DiagnosticRuntimeSeedCycleBase("regime_filter_block");
         gDiagnosticRuntimeSummary.active_mode = NormalizeDecisionEngineModeEx(gPlan.decision_engine_mode);
         DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
         DiagnosticRuntimeSetOutcome(
            "WAIT",
            true,
            "regime_filter_block",
            regimeBlockReason,
            "BLOCKED_PRE_ROUTER",
            "regime_filter_blocked_before_routed_decision"
         );
         DiagnosticRuntimeApplyFailureFallbacks();
         SaveDiagnosticRuntimeSummaryBestEffort();
         RefreshExecutionQualityValidationArtifactsBestEffort();

         return;
      }

      //---------------------------------------------------
      // Routed runtime decision
      //---------------------------------------------------
      RoutedRuntimeEvaluation routed;
      EvaluateDecisionModeRouted(gCompiledPlan, m1, m5, routed);
      LogRoutedRuntimeEvaluation(routed);

      if(!routed.valid)
      {
         LogWarn("Routed runtime returned invalid result");

         DiagnosticRuntimeSeedCycleBase("routed_runtime_invalid");
         DiagnosticRuntimeSetOutcome(
            "BLOCKED",
            true,
            "decision_router_invalid",
            "routed_runtime_invalid",
            "NO_DECISION",
            "routed_runtime_invalid"
         );
         SaveDiagnosticRuntimeSummaryBestEffort();

         return;
      }

      RuntimeEvaluation eval;
      eval.decision = routed.base_eval.decision;
      eval.reason   = routed.base_eval.reason;

      string decisionCandidateName = "";
      string decisionCandidateFamily = "";
      RuntimeInferDecisionCandidateFromRouted(routed, decisionCandidateName, decisionCandidateFamily);
      ExecutionAuthoritySetDecisionCandidate(decisionCandidateName, decisionCandidateFamily);
      RefreshExecutionAuthorityStatusBestEffort();

      // Council setup lifecycle (opt-in) invalidation/expiry handling on non-entry cycles
      string _csl_sid = (routed.active_mode == "COUNCIL" && routed.council.valid ? routed.council.aggregate.best_strategy_id : "");
      CouncilLifecycleUpdateOnNonEntryDecision(routed.active_mode, eval.decision, _csl_sid, iTime(_Symbol, PERIOD_M1, 0));

      if(!EnableRuntimeExecution)
      {
         LogStateOnce("Runtime execution disabled");

         DiagnosticRuntimeSeedCycleBase("runtime_execution_disabled");
         DiagnosticRuntimeApplyRoutedContext(routed);
         DiagnosticRuntimeSetOutcome(
            "BLOCKED",
            true,
            "runtime_governance_block",
            "runtime_execution_disabled",
            "BLOCKED_BEFORE_ENTRY",
            "runtime_execution_disabled_after_routing"
         );
         SaveDiagnosticRuntimeSummaryBestEffort();
         RefreshExecutionQualityValidationArtifactsBestEffort();

         return;
      }

      if(OneTradeAttemptPerBar && !CanAttemptRuntimeTradeThisBar())
      {
         LogStateOnce("Runtime trade already attempted this bar");

         DiagnosticRuntimeSeedCycleBase("per_bar_attempt_limit");
         DiagnosticRuntimeApplyRoutedContext(routed);
         DiagnosticRuntimeSetOutcome(
            DiagnosticRuntimeDecisionText(eval.decision),
            true,
            "per_bar_attempt_limit",
            "one_trade_attempt_per_bar",
            "BLOCKED_BEFORE_ENTRY",
            "runtime_trade_attempt_already_used_this_bar"
         );
         SaveDiagnosticRuntimeSummaryBestEffort();
         RefreshExecutionQualityValidationArtifactsBestEffort();

         return;
      }

      //---------------------------------------------------
      // BUY execution path
      //---------------------------------------------------
      if(eval.decision == RUNTIME_ENTER_BUY)
      {
         string authorityReason = "";
         if(!RuntimeOperatingCohortAdmissionAllowsExecution(gCurrentDecisionCandidateName, gCurrentDecisionCandidateFamily, authorityReason))
         {
            LogStateOnce("Runtime BUY blocked by cohort admission | " + authorityReason);

            DiagnosticRuntimeSeedCycleBase("cohort_admission_block");
            DiagnosticRuntimeApplyRoutedContext(routed);
            DiagnosticRuntimeSetOutcome(
               "BUY",
               true,
               "execution_authority_block",
               authorityReason,
               "BLOCKED_BEFORE_ENTRY",
               "runtime_buy_blocked_by_active_operating_cohort"
            );
            SaveDiagnosticRuntimeSummaryBestEffort();
            AppendValidationDecisionJournal(
               routed,
               m1,
               eval,
               false,
               "BLOCKED:EXECUTION_AUTHORITY",
               authorityReason,
               "BUY",
               "execution_authority_block",
               authorityReason,
               "BLOCKED_BEFORE_ENTRY"
            );
            ExecutionAuthorityRememberReject(authorityReason);
            RefreshExecutionAuthorityStatusBestEffort();
            RefreshExecutionQualityValidationArtifactsBestEffort();

            return;
         }

         string policyReason = "";
         if(!RuntimePolicyAllowsTrade(CORE_BUY, policyReason))
         {
            LogStateOnce("Runtime BUY blocked by policy | " + policyReason);
            if(EnableCouncilSetupLifecycle && routed.active_mode == "COUNCIL")
            {
               LoadCouncilSetupLifecycleStateOnce();
               if(gCouncilSetupLifecycle.active && gCouncilSetupLifecycle.direction == "BUY")
                  CouncilLifecycleClearWithFinal("INVALIDATED", "policy_block");
            }

            DiagnosticRuntimeSeedCycleBase("policy_block");
            DiagnosticRuntimeApplyRoutedContext(routed);
            DiagnosticRuntimeSetOutcome(
               "BUY",
               true,
               "policy_block",
               policyReason,
               "BLOCKED_BEFORE_ENTRY",
               "runtime_buy_blocked_by_policy"
            );
            SaveDiagnosticRuntimeSummaryBestEffort();
            AppendValidationDecisionJournal(
               routed,
               m1,
               eval,
               false,
               "BLOCKED:POLICY",
               policyReason,
               "BUY",
               "policy_block",
               policyReason,
               "BLOCKED_BEFORE_ENTRY"
            );
            ExecutionAuthorityRememberReject(policyReason);
            RefreshExecutionAuthorityStatusBestEffort();
            RefreshExecutionQualityValidationArtifactsBestEffort();

            return;
         }
         EnsureCurrentDecisionId();
         // Level Awareness v2 (late-stage brake) ? passive: does not change council decision
         LevelAwarenessBrakeReport brake;
         bool hasCouncil = (routed.active_mode == "COUNCIL");
         if(hasCouncil && BuildLevelAwarenessBrakeReport(_Symbol, +1, routed.council, brake))
         {
            if(brake.brake_verdict == "HARD_REJECT")
            {
               LogStateOnce("Runtime BUY blocked by level brake | " + brake.brake_reason_code + " | " + brake.location_context_summary);
               if(EnableCouncilSetupLifecycle && routed.active_mode == "COUNCIL")
               {
                  LoadCouncilSetupLifecycleStateOnce();
                  if(gCouncilSetupLifecycle.active && gCouncilSetupLifecycle.direction == "BUY")
                     CouncilLifecycleClearWithFinal("INVALIDATED", "level_brake_hard_reject");
               }

               // Journal a blocked decision event (diagnostic only)
               UnifiedDecisionConfidence conf;
               BuildUnifiedDecisionConfidence(routed, gRegime, eval, true, "BLOCKED:LEVEL_BRAKE", conf);

               if(routed.active_mode == "COUNCIL")
                  PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
               else
                  PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);
               ClassifyDecisionFailureV1(conf, gRegime, "BLOCKED:LEVEL_BRAKE", brake.brake_reason_code, gDecisionFailure);
               string pjLog = "";
               PJ_SetDecisionValidationContext(
                  "level_brake_block",
                  brake.brake_reason_code,
                  "BLOCKED_AFTER_LEVEL_BRAKE",
                  "BLOCKED",
                  ""
               );
               JournalAppendDecisionV3(
                  gCurrentDecisionId,
                  gPlan,
                  routed.active_mode,
                  m1,
                  gRegime,
                  conf,
                  eval,
                  "BLOCKED:LEVEL_BRAKE",
                  (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL"),
                  (gHasRiskPolicy ? gRiskPolicy.reason : ""),
                  gDecisionFailure.failure_class,
                  gDecisionFailure.failure_reason_summary,
                  gDecisionFailure.failure_severity,
                  brake.brake_reason_code,
                  "",
                  "",
                  "",
                  (gHasRollbackSignal ? gRollbackSignal.state_text : "NONE"),
                  (gHasRollbackSignal ? gRollbackSignal.rollback_signal_score : 0.0),
                  (gHasRollbackSignal ? gRollbackSignal.rollback_signal_reason : ""),
                  (gHasFailureCluster ? gFailureCluster.clustered_failure_detected : false),
                  (gHasFailureCluster ? gFailureCluster.dominant_failure_class : "UNKNOWN_FAILURE"),
                  (gHasFailureCluster ? gFailureCluster.dominant_failure_count : 0),
                  (gHasFailureCluster ? gFailureCluster.failure_cluster_score : 0.0),
                  (gHasFailureCluster ? gFailureCluster.dominant_regime_if_any : ""),
                  (gHasRegimePerf ? gRegimePerf.summary_reason : ""),
                  pjLog
               );
               LogStateOnce(pjLog);
               RefreshExecutionQualityValidationArtifactsBestEffort();
               // Strategy Confidence Memory v1 (observer-only): record level-brake blocked decision
               string brakeDirLabelBuy = "SELL";
               if(brake.direction_under_review > 0)
                  brakeDirLabelBuy = "BUY";
               SCM_RecordDecisionEvent(
                  gSCMCache,
                  _Symbol,
                  gCurrentDecisionId,
                  brake.strategy_id,
                  brake.strategy_id,
                  brake.strategy_family,
                  brake.zone_semantic,
                  gRegime.regime_label,
                  brakeDirLabelBuy,
                  "BLOCKED",
                  false,
                  true,
                  brake.brake_reason_code,
                  routed.council.zone_coverage.coverage_label
               );

               DiagnosticRuntimeSeedCycleBase("level_brake_block");
               DiagnosticRuntimeApplyRoutedContext(routed);
               DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
               DiagnosticRuntimeSetOutcome(
                  "BUY",
                  true,
                  "level_brake_block",
                  brake.brake_reason_code,
                  "BLOCKED_AFTER_LEVEL_BRAKE",
                  "runtime_buy_blocked_by_level_brake"
               );
               SaveDiagnosticRuntimeSummaryBestEffort();

               return;
            }
         }

         
         
         // [DORMANT_BRANCH: ACTIVATION_PRESSURE_GATE] flag=false; lifecycle invalidation nested inside; coordinate with EnableCouncilSetupLifecycle when enabling
         // Council activation pressure gate (opt-in, COUNCIL only): structural coverage filter before lifecycle/timing gates
         if(EnableCouncilActivationPressureGate && routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            CouncilActivationPressureAssessment ap;
            EvaluateCouncilActivationPressure(routed, "BUY", ap);
            SaveCouncilActivationPressureStatusBestEffort(ap);
            if(ap.gate_applied && !ap.pass)
            {
               LogStateOnce("Council activation-pressure BLOCK " + ap.reason_code + " " + ap.coverage_label);

               // Activation-pressure block is structural: invalidate any active council lifecycle setup conservatively
               if(EnableCouncilSetupLifecycle)
               {
                  LoadCouncilSetupLifecycleStateOnce();
                  if(gCouncilSetupLifecycle.active)
                     CouncilLifecycleClearWithFinal("INVALIDATED", "activation_pressure_block");
               }

               DiagnosticRuntimeSeedCycleBase("activation_pressure_block");
               DiagnosticRuntimeApplyRoutedContext(routed);
               DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
               DiagnosticRuntimeSetOutcome(
                  "BUY",
                  true,
                  "activation_pressure_block",
                  ap.reason_code,
                  "BLOCKED_AFTER_ACTIVATION_PRESSURE",
                  "runtime_buy_blocked_by_activation_pressure"
               );
               SaveDiagnosticRuntimeSummaryBestEffort();
               AppendValidationDecisionJournal(
                  routed,
                  m1,
                  eval,
                  true,
                  "BLOCKED:ACTIVATION_PRESSURE",
                  ap.reason_code,
                  "BUY",
                  "activation_pressure_block",
                  ap.reason_code,
                  "BLOCKED_AFTER_ACTIVATION_PRESSURE"
               );
               RefreshExecutionQualityValidationArtifactsBestEffort();

               return;
            }
         }

         
         // [DORMANT_BRANCH: DIRTY_ENVIRONMENT_TIGHTENING] flag=false; lifecycle invalidation nested inside; coordinate with ACTIVATION_PRESSURE_GATE when enabling
         // Council dirty/transitional environment tightening gate (opt-in, COUNCIL only): discipline filter after activation-pressure gate
         if(EnableCouncilDirtyEnvironmentTightening && routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            CouncilDirtyEnvironmentAssessment de;
            EvaluateCouncilDirtyEnvironmentTightening(routed, "BUY", de);
            SaveCouncilDirtyEnvironmentStatusBestEffort(de);
            if(de.gate_applied && !de.pass)
            {
               LogStateOnce("Council dirty-environment BLOCK " + de.reason_code + " " + de.regime_label);

               // Dirty/transitional environment block is structural: invalidate any active council lifecycle setup conservatively
               if(EnableCouncilSetupLifecycle)
               {
                  LoadCouncilSetupLifecycleStateOnce();
                  if(gCouncilSetupLifecycle.active)
                     CouncilLifecycleClearWithFinal("INVALIDATED", "dirty_environment_block");
               }

               DiagnosticRuntimeSeedCycleBase("dirty_environment_block");
               DiagnosticRuntimeApplyRoutedContext(routed);
               DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
               DiagnosticRuntimeSetOutcome(
                  "BUY",
                  true,
                  "dirty_environment_block",
                  de.reason_code,
                  "BLOCKED_AFTER_DIRTY_ENVIRONMENT",
                  "runtime_buy_blocked_by_dirty_environment"
               );
               SaveDiagnosticRuntimeSummaryBestEffort();
               AppendValidationDecisionJournal(
                  routed,
                  m1,
                  eval,
                  true,
                  "BLOCKED:DIRTY_ENVIRONMENT",
                  de.reason_code,
                  "BUY",
                  "dirty_environment_block",
                  de.reason_code,
                  "BLOCKED_AFTER_DIRTY_ENVIRONMENT"
               );
               RefreshExecutionQualityValidationArtifactsBestEffort();

               return;
            }
         }

// Council setup lifecycle (opt-in; COUNCIL only): arm/confirm gating after policy + level brake pass
                  if(EnableCouncilSetupLifecycle && routed.active_mode == "COUNCIL" && routed.council.valid)
                  {
                     string _sid  = routed.council.aggregate.best_strategy_id;
                     string _zone = routed.council.zone_coverage.zone_semantic;
                     double _q    = routed.council.aggregate.council_quality;
                     double _cs   = routed.council.aggregate.consensus_strength;
                     double _env  = gRegime.tradability_score;
                     int _expBars = (gPlan.signal_expiry_bars < 1 ? 1 : gPlan.signal_expiry_bars);

                     if(CouncilLifecycleGateCandidate("BUY", gCurrentDecisionId, _sid, _zone, _q, _cs, _env, iTime(_Symbol, PERIOD_M1, 0), CouncilSetupConfirmBars, _expBars))
                     {
                        DiagnosticRuntimeSeedCycleBase("lifecycle_gate_pending");
                        DiagnosticRuntimeApplyRoutedContext(routed);
                        DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
                        DiagnosticRuntimeSetLifecycleState(gCouncilSetupLifecycle.state_name);
                        DiagnosticRuntimeSetOutcome(
                           "BUY",
                           true,
                           "lifecycle_gate_not_ready",
                           "council_setup_lifecycle_pending",
                           "BLOCKED_BY_LIFECYCLE_GATE",
                           "runtime_buy_waiting_for_lifecycle_confirmation"
                        );
                        SaveDiagnosticRuntimeSummaryBestEffort();
                        AppendValidationDecisionJournal(
                           routed,
                           m1,
                           eval,
                           true,
                           "BLOCKED:LIFECYCLE_GATE",
                           "council_setup_lifecycle_pending",
                           "BUY",
                           "lifecycle_gate_not_ready",
                           "council_setup_lifecycle_pending",
                           "BLOCKED_BY_LIFECYCLE_GATE"
                        );
                        RefreshExecutionQualityValidationArtifactsBestEffort();
                        return;
                     }
                  }


                  // [DORMANT_BRANCH: EXECUTION_QUALITY_GATE] flag=false; NOTE: ev.execution_quality_guard_active is set in operating envelope regardless of this flag (by design)
                  // Council execution quality gate (opt-in, COUNCIL only): timing/fill-quality pass before execution
                  if(EnableCouncilExecutionQualityGate && routed.active_mode == "COUNCIL")
                  {
                     CouncilExecutionQualityAssessment qa;
                     EvaluateCouncilExecutionQuality(m1, "BUY", qa);
                     SaveCouncilExecutionQualityStatusBestEffort(qa);
                     if(qa.gate_applied && !qa.pass)
                     {
                        LogStateOnce("Council exec-quality BLOCK " + qa.reason_code + " | q=" + DoubleToString(qa.quality_score,3) +
                                    " | spreadATR=" + DoubleToString(qa.spread_atr_fraction,3) + " | chaseATR=" + DoubleToString(qa.chase_atr_fraction,3));

                        DiagnosticRuntimeSeedCycleBase("execution_quality_block");
                        DiagnosticRuntimeApplyRoutedContext(routed);
                        DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
                        DiagnosticRuntimeSetOutcome(
                           "BUY",
                           true,
                           "execution_quality_block",
                           qa.reason_code,
                           "BLOCKED_AFTER_EXECUTION_QUALITY",
                           "runtime_buy_blocked_by_execution_quality"
                        );
                        SaveDiagnosticRuntimeSummaryBestEffort();
                        AppendValidationDecisionJournal(
                           routed,
                           m1,
                           eval,
                           true,
                           "BLOCKED:EXECUTION_QUALITY",
                           qa.reason_code,
                           "BUY",
                           "execution_quality_block",
                           qa.reason_code,
                           "BLOCKED_AFTER_EXECUTION_QUALITY"
                        );
                        OperatingRiskEnvelopeRecordCurrentBlock("EXECUTION_QUALITY_GUARD",
                                                               "execution_quality_guard_failed",
                                                               "Execution quality guard withheld the current BUY entry.",
                                                               "execution_quality_guard",
                                                               CORE_BUY);
                        ExecutionAuthorityRememberReject("execution_quality_guard_failed");
                        RefreshExecutionAuthorityStatusBestEffort();
                        RefreshExecutionQualityValidationArtifactsBestEffort();

                        return;
                     }
                  }

         if(routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            if(HandleAtasGovernedAdvisoryIntegration(routed, m1, eval, "BUY"))
               return;
            if(HandleCouncilAIAdvisoryIntegration(routed, m1, eval, "BUY"))
               return;
         }

         gLastEntryDecisionId = gCurrentDecisionId;

                  // Strategy Confidence Memory v1 (observer-only): decision context for BUY candidate
                  if(routed.active_mode == "COUNCIL")
                  {
                     string sid = routed.council.aggregate.best_strategy_id;
                     string fam = LAB_InferFamilyFromStrategyId(sid);
                     SCM_RecordDecisionEvent(
                        gSCMCache,
                        _Symbol,
                        gCurrentDecisionId,
                        sid,
                        sid,
                        fam,
                        routed.council.zone_coverage.zone_semantic,
                        gRegime.regime_label,
                        "BUY",
                        "BUY",
                        false,
                        false,
                        "",
                        routed.council.zone_coverage.coverage_label
                     );
                  }

                  UnifiedDecisionConfidence entryConfBuy;
                  BuildUnifiedDecisionConfidence(routed, gRegime, eval, true, "EXECUTION_ATTEMPT_BUY", entryConfBuy);

                  if(EnableInstitutionalSelfLearning)
                  {
                     string ilDecisionCtxLogBuy = "";
                     ILV1_RecordDecisionContext(
                        gCurrentDecisionId,
                        "BUY",
                        routed,
                        gRegime,
                        entryConfBuy,
                        ilDecisionCtxLogBuy
                     );
                     if(StringLen(ilDecisionCtxLogBuy) > 0)
                        LogStateOnce(ilDecisionCtxLogBuy);
                  }

                  bool opened = ExecuteRuntimeBuy(entryConfBuy);
                  CouncilLifecycleOnExecutionResult(opened);

                  // Strategy Confidence Memory v1 (observer-only): trade open result
                  if(routed.active_mode == "COUNCIL")
                  {
                     string sid = routed.council.aggregate.best_strategy_id;
                     string fam = LAB_InferFamilyFromStrategyId(sid);
                     SCM_RecordTradeOpenEvent(
                        gSCMCache,
                        _Symbol,
                        gCurrentDecisionId,
                        sid,
                        sid,
                        fam,
                        routed.council.zone_coverage.zone_semantic,
                        gRegime.regime_label,
                        "BUY",
                        opened
                     );
                  }
                  if(opened)
                  {
                     MarkRuntimeTradeExecutedNow();
                     CouncilAIAdvisoryAcknowledgeTradeOpenFromHeldCandidate(gCurrentDecisionId);
                     ExecutionAuthorityRememberExecution();
                     RefreshExecutionAuthorityStatusBestEffort();
                     LogInfo("Runtime BUY executed successfully");
                  }
                  else
                  {
                     MarkRuntimeTradeAttemptedThisBar();
                     ExecutionAuthorityRememberReject("execution_open_failed");
                     RefreshExecutionAuthorityStatusBestEffort();
                     LogWarn("Runtime BUY execution failed");
                  }

                  RuntimeRiskSafetyRecordExecutionOpenResult(opened);
                  if(!opened && RuntimeRiskSafetyLockoutTriggered())
                     LogWarn("Runtime risk/safety execution failure lockout engaged | failures=" + IntegerToString(gRuntimeConsecutiveOpenFailures));

                  DiagnosticRuntimeSeedCycleBase("trade_open_outcome");
                  DiagnosticRuntimeApplyRoutedContext(routed);
                  DiagnosticRuntimeRecordTradeOpen(gCurrentDecisionId, "BUY", opened);
                  SaveDiagnosticRuntimeSummaryBestEffort();
                  AppendValidationDecisionJournal(
                     routed,
                     m1,
                     eval,
                     true,
                     (opened ? "BUY" : "BUY"),
                     (opened ? "" : "execution_open_failed"),
                     "BUY",
                     (opened ? "" : "execution_open_failed"),
                     (opened ? "" : "execution_open_failed"),
                     (opened ? "TRADE_OPEN_EXECUTED" : "TRADE_OPEN_FAILED")
                  );
                  RefreshExecutionQualityValidationArtifactsBestEffort();

                  return;
               }

               //---------------------------------------------------
               // SELL execution path
               //---------------------------------------------------
               if(eval.decision == RUNTIME_ENTER_SELL)
               {
                  string authorityReason = "";
                  if(!RuntimeOperatingCohortAdmissionAllowsExecution(gCurrentDecisionCandidateName, gCurrentDecisionCandidateFamily, authorityReason))
                  {
                     LogStateOnce("Runtime SELL blocked by cohort admission | " + authorityReason);

                     DiagnosticRuntimeSeedCycleBase("cohort_admission_block");
                     DiagnosticRuntimeApplyRoutedContext(routed);
                     DiagnosticRuntimeSetOutcome(
                        "SELL",
                        true,
                        "execution_authority_block",
                        authorityReason,
                        "BLOCKED_BEFORE_ENTRY",
                        "runtime_sell_blocked_by_active_operating_cohort"
                     );
                     SaveDiagnosticRuntimeSummaryBestEffort();
                     AppendValidationDecisionJournal(
                        routed,
                        m1,
                        eval,
                        false,
                        "BLOCKED:EXECUTION_AUTHORITY",
                        authorityReason,
                        "SELL",
                        "execution_authority_block",
                        authorityReason,
                        "BLOCKED_BEFORE_ENTRY"
                     );
                     ExecutionAuthorityRememberReject(authorityReason);
                     RefreshExecutionAuthorityStatusBestEffort();
                     RefreshExecutionQualityValidationArtifactsBestEffort();

                     return;
                  }

                  string policyReason = "";
                  if(!RuntimePolicyAllowsTrade(CORE_SELL, policyReason))
                  {
                     LogStateOnce("Runtime SELL blocked by policy | " + policyReason);
                     if(EnableCouncilSetupLifecycle && routed.active_mode == "COUNCIL")
                     {
                        LoadCouncilSetupLifecycleStateOnce();
                        if(gCouncilSetupLifecycle.active && gCouncilSetupLifecycle.direction == "SELL")
                           CouncilLifecycleClearWithFinal("INVALIDATED", "policy_block");
                     }

                     DiagnosticRuntimeSeedCycleBase("policy_block");
                     DiagnosticRuntimeApplyRoutedContext(routed);
                     DiagnosticRuntimeSetOutcome(
                        "SELL",
                        true,
                        "policy_block",
                        policyReason,
                        "BLOCKED_BEFORE_ENTRY",
                        "runtime_sell_blocked_by_policy"
                     );
                     SaveDiagnosticRuntimeSummaryBestEffort();
                     AppendValidationDecisionJournal(
                        routed,
                        m1,
                        eval,
                        false,
                        "BLOCKED:POLICY",
                        policyReason,
                        "SELL",
                        "policy_block",
                        policyReason,
                        "BLOCKED_BEFORE_ENTRY"
                     );
                     ExecutionAuthorityRememberReject(policyReason);
                     RefreshExecutionAuthorityStatusBestEffort();
                     RefreshExecutionQualityValidationArtifactsBestEffort();

                     return;
                  }
                  EnsureCurrentDecisionId();
                  // Level Awareness v2 (late-stage brake) ? passive: does not change council decision
                  LevelAwarenessBrakeReport brake;
                  bool hasCouncil = (routed.active_mode == "COUNCIL");
                  if(hasCouncil && BuildLevelAwarenessBrakeReport(_Symbol, -1, routed.council, brake))
                  {
                     if(brake.brake_verdict == "HARD_REJECT")
                     {
                        LogStateOnce("Runtime SELL blocked by level brake | " + brake.brake_reason_code + " | " + brake.location_context_summary);
                        if(EnableCouncilSetupLifecycle && routed.active_mode == "COUNCIL")
                        {
                           LoadCouncilSetupLifecycleStateOnce();
                           if(gCouncilSetupLifecycle.active && gCouncilSetupLifecycle.direction == "SELL")
                              CouncilLifecycleClearWithFinal("INVALIDATED", "level_brake_hard_reject");
                        }

                        if(routed.active_mode == "COUNCIL")
                           PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
                        else
                           PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);

                        // Journal a blocked decision event (diagnostic only)
                        UnifiedDecisionConfidence conf;
                        BuildUnifiedDecisionConfidence(routed, gRegime, eval, true, "BLOCKED:LEVEL_BRAKE", conf);

                        InitFailureClassification(gDecisionFailure);
                        ClassifyDecisionFailureV1(conf, gRegime, "BLOCKED:LEVEL_BRAKE", brake.brake_reason_code, gDecisionFailure);

                        string pjLog = "";
                        PJ_SetDecisionValidationContext(
                           "level_brake_block",
                           brake.brake_reason_code,
                           "BLOCKED_AFTER_LEVEL_BRAKE",
                           "BLOCKED",
                           ""
                        );
                        JournalAppendDecisionV3(
                           gCurrentDecisionId,
                           gPlan,
                           routed.active_mode,
                           m1,
                           gRegime,
                           conf,
                           eval,
                           "BLOCKED:LEVEL_BRAKE",
                           (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL"),
                           (gHasRiskPolicy ? gRiskPolicy.reason : ""),
                           gDecisionFailure.failure_class,
                           gDecisionFailure.failure_reason_summary,
                           gDecisionFailure.failure_severity,
                           brake.brake_reason_code,
                           "",
                           "",
                           "",
                           (gHasRollbackSignal ? gRollbackSignal.state_text : "NONE"),
                           (gHasRollbackSignal ? gRollbackSignal.rollback_signal_score : 0.0),
                           (gHasRollbackSignal ? gRollbackSignal.rollback_signal_reason : ""),
                           (gHasFailureCluster ? gFailureCluster.clustered_failure_detected : false),
                           (gHasFailureCluster ? gFailureCluster.dominant_failure_class : "UNKNOWN_FAILURE"),
                           (gHasFailureCluster ? gFailureCluster.dominant_failure_count : 0),
                           (gHasFailureCluster ? gFailureCluster.failure_cluster_score : 0.0),
                           (gHasFailureCluster ? gFailureCluster.dominant_regime_if_any : ""),
                           (gHasRegimePerf ? gRegimePerf.summary_reason : ""),
                           pjLog
                        );
                        LogStateOnce(pjLog);
                        RefreshExecutionQualityValidationArtifactsBestEffort();

                        // Strategy Confidence Memory v1 (observer-only): record level-brake blocked decision
                        string brakeDirLabelSell = "SELL";
                        if(brake.direction_under_review > 0)
                           brakeDirLabelSell = "BUY";
                        SCM_RecordDecisionEvent(
                           gSCMCache,
                           _Symbol,
                           gCurrentDecisionId,
                           brake.strategy_id,
                           brake.strategy_id,
                           brake.strategy_family,
                           brake.zone_semantic,
                           gRegime.regime_label,
                           brakeDirLabelSell,
                           "BLOCKED",
                           false,
                           true,
                           brake.brake_reason_code,
                           routed.council.zone_coverage.coverage_label
                        );

                        DiagnosticRuntimeSeedCycleBase("level_brake_block");
                        DiagnosticRuntimeApplyRoutedContext(routed);
                        DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
                        DiagnosticRuntimeSetOutcome(
                           "SELL",
                           true,
                           "level_brake_block",
                           brake.brake_reason_code,
                           "BLOCKED_AFTER_LEVEL_BRAKE",
                           "runtime_sell_blocked_by_level_brake"
                        );
                        SaveDiagnosticRuntimeSummaryBestEffort();

                        return;
                     }

                  }


         // [DORMANT_BRANCH: ACTIVATION_PRESSURE_GATE] flag=false; lifecycle invalidation nested inside; coordinate with EnableCouncilSetupLifecycle when enabling
         // Council activation pressure gate (opt-in, COUNCIL only): structural coverage filter before lifecycle/timing gates
         if(EnableCouncilActivationPressureGate && routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            CouncilActivationPressureAssessment ap;
            EvaluateCouncilActivationPressure(routed, "SELL", ap);
            SaveCouncilActivationPressureStatusBestEffort(ap);
            if(ap.gate_applied && !ap.pass)
            {
               LogStateOnce("Council activation-pressure BLOCK " + ap.reason_code + " " + ap.coverage_label);

               // Activation-pressure block is structural: invalidate any active council lifecycle setup conservatively
               if(EnableCouncilSetupLifecycle)
               {
                  LoadCouncilSetupLifecycleStateOnce();
                  if(gCouncilSetupLifecycle.active)
                     CouncilLifecycleClearWithFinal("INVALIDATED", "activation_pressure_block");
               }

               DiagnosticRuntimeSeedCycleBase("activation_pressure_block");
               DiagnosticRuntimeApplyRoutedContext(routed);
               DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
               DiagnosticRuntimeSetOutcome(
                  "SELL",
                  true,
                  "activation_pressure_block",
                  ap.reason_code,
                  "BLOCKED_AFTER_ACTIVATION_PRESSURE",
                  "runtime_sell_blocked_by_activation_pressure"
               );
               SaveDiagnosticRuntimeSummaryBestEffort();

               return;
            }
         }

         
         // [DORMANT_BRANCH: DIRTY_ENVIRONMENT_TIGHTENING] flag=false; lifecycle invalidation nested inside; coordinate with ACTIVATION_PRESSURE_GATE when enabling
         // Council dirty/transitional environment tightening gate (opt-in, COUNCIL only): discipline filter after activation-pressure gate
         if(EnableCouncilDirtyEnvironmentTightening && routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            CouncilDirtyEnvironmentAssessment de;
            EvaluateCouncilDirtyEnvironmentTightening(routed, "SELL", de);
            SaveCouncilDirtyEnvironmentStatusBestEffort(de);
            if(de.gate_applied && !de.pass)
            {
               LogStateOnce("Council dirty-environment BLOCK " + de.reason_code + " " + de.regime_label);

               // Dirty/transitional environment block is structural: invalidate any active council lifecycle setup conservatively
               if(EnableCouncilSetupLifecycle)
               {
                  LoadCouncilSetupLifecycleStateOnce();
                  if(gCouncilSetupLifecycle.active)
                     CouncilLifecycleClearWithFinal("INVALIDATED", "dirty_environment_block");
               }

               DiagnosticRuntimeSeedCycleBase("dirty_environment_block");
               DiagnosticRuntimeApplyRoutedContext(routed);
               DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
               DiagnosticRuntimeSetOutcome(
                  "SELL",
                  true,
                  "dirty_environment_block",
                  de.reason_code,
                  "BLOCKED_AFTER_DIRTY_ENVIRONMENT",
                  "runtime_sell_blocked_by_dirty_environment"
               );
               SaveDiagnosticRuntimeSummaryBestEffort();
               AppendValidationDecisionJournal(
                  routed,
                  m1,
                  eval,
                  true,
                  "BLOCKED:DIRTY_ENVIRONMENT",
                  de.reason_code,
                  "SELL",
                  "dirty_environment_block",
                  de.reason_code,
                  "BLOCKED_AFTER_DIRTY_ENVIRONMENT"
               );
               RefreshExecutionQualityValidationArtifactsBestEffort();

               return;
            }
         }

// Council setup lifecycle (opt-in; COUNCIL only): arm/confirm gating after policy + level brake pass
         if(EnableCouncilSetupLifecycle && routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            string _sid  = routed.council.aggregate.best_strategy_id;
            string _zone = routed.council.zone_coverage.zone_semantic;
            double _q    = routed.council.aggregate.council_quality;
            double _cs   = routed.council.aggregate.consensus_strength;
            double _env  = gRegime.tradability_score;
            int _expBars = (gPlan.signal_expiry_bars < 1 ? 1 : gPlan.signal_expiry_bars);

            if(CouncilLifecycleGateCandidate("SELL", gCurrentDecisionId, _sid, _zone, _q, _cs, _env, iTime(_Symbol, PERIOD_M1, 0), CouncilSetupConfirmBars, _expBars))
         {
            DiagnosticRuntimeSeedCycleBase("lifecycle_gate_pending");
            DiagnosticRuntimeApplyRoutedContext(routed);
            DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
            DiagnosticRuntimeSetLifecycleState(gCouncilSetupLifecycle.state_name);
            DiagnosticRuntimeSetOutcome(
               "SELL",
               true,
               "lifecycle_gate_not_ready",
               "council_setup_lifecycle_pending",
               "BLOCKED_BY_LIFECYCLE_GATE",
               "runtime_sell_waiting_for_lifecycle_confirmation"
            );
            SaveDiagnosticRuntimeSummaryBestEffort();
            AppendValidationDecisionJournal(
               routed,
               m1,
               eval,
               true,
               "BLOCKED:LIFECYCLE_GATE",
               "council_setup_lifecycle_pending",
               "SELL",
               "lifecycle_gate_not_ready",
               "council_setup_lifecycle_pending",
               "BLOCKED_BY_LIFECYCLE_GATE"
            );
            RefreshExecutionQualityValidationArtifactsBestEffort();
            return;
         }
         }


         // [DORMANT_BRANCH: EXECUTION_QUALITY_GATE] flag=false; NOTE: ev.execution_quality_guard_active is set in operating envelope regardless of this flag (by design)
         // Council execution quality gate (opt-in, COUNCIL only): timing/fill-quality pass before execution
         if(EnableCouncilExecutionQualityGate && routed.active_mode == "COUNCIL")
         {
            CouncilExecutionQualityAssessment qa;
            EvaluateCouncilExecutionQuality(m1, "SELL", qa);
            SaveCouncilExecutionQualityStatusBestEffort(qa);
            if(qa.gate_applied && !qa.pass)
            {
               LogStateOnce("Council exec-quality BLOCK " + qa.reason_code + " | q=" + DoubleToString(qa.quality_score,3) +
                           " | spreadATR=" + DoubleToString(qa.spread_atr_fraction,3) + " | chaseATR=" + DoubleToString(qa.chase_atr_fraction,3));

               DiagnosticRuntimeSeedCycleBase("execution_quality_block");
               DiagnosticRuntimeApplyRoutedContext(routed);
               DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
               DiagnosticRuntimeSetOutcome(
                  "SELL",
                  true,
                  "execution_quality_block",
                  qa.reason_code,
                  "BLOCKED_AFTER_EXECUTION_QUALITY",
                  "runtime_sell_blocked_by_execution_quality"
               );
               SaveDiagnosticRuntimeSummaryBestEffort();
               AppendValidationDecisionJournal(
                  routed,
                  m1,
                  eval,
                  true,
                  "BLOCKED:EXECUTION_QUALITY",
                  qa.reason_code,
                  "SELL",
                  "execution_quality_block",
                  qa.reason_code,
                  "BLOCKED_AFTER_EXECUTION_QUALITY"
               );
               OperatingRiskEnvelopeRecordCurrentBlock("EXECUTION_QUALITY_GUARD",
                                                      "execution_quality_guard_failed",
                                                      "Execution quality guard withheld the current SELL entry.",
                                                      "execution_quality_guard",
                                                      CORE_SELL);
               ExecutionAuthorityRememberReject("execution_quality_guard_failed");
               RefreshExecutionAuthorityStatusBestEffort();
               RefreshExecutionQualityValidationArtifactsBestEffort();

               return;
            }
         }

         if(routed.active_mode == "COUNCIL" && routed.council.valid)
         {
            if(HandleAtasGovernedAdvisoryIntegration(routed, m1, eval, "SELL"))
               return;
            if(HandleCouncilAIAdvisoryIntegration(routed, m1, eval, "SELL"))
               return;
         }

gLastEntryDecisionId = gCurrentDecisionId;

         // Strategy Confidence Memory v1 (observer-only): decision context for SELL candidate
         if(routed.active_mode == "COUNCIL")
         {
            string sid = routed.council.aggregate.best_strategy_id;
            string fam = LAB_InferFamilyFromStrategyId(sid);
            SCM_RecordDecisionEvent(
               gSCMCache,
               _Symbol,
               gCurrentDecisionId,
               sid,
               sid,
               fam,
               routed.council.zone_coverage.zone_semantic,
               gRegime.regime_label,
               "SELL",
               "SELL",
               false,
               false,
               "",
               routed.council.zone_coverage.coverage_label
            );
         }

         UnifiedDecisionConfidence entryConfSell;
         BuildUnifiedDecisionConfidence(routed, gRegime, eval, true, "EXECUTION_ATTEMPT_SELL", entryConfSell);

         if(EnableInstitutionalSelfLearning)
         {
            string ilDecisionCtxLogSell = "";
            ILV1_RecordDecisionContext(
               gCurrentDecisionId,
               "SELL",
               routed,
               gRegime,
               entryConfSell,
               ilDecisionCtxLogSell
            );
            if(StringLen(ilDecisionCtxLogSell) > 0)
               LogStateOnce(ilDecisionCtxLogSell);
         }

         bool opened = ExecuteRuntimeSell(entryConfSell);
         CouncilLifecycleOnExecutionResult(opened);

         // Strategy Confidence Memory v1 (observer-only): trade open result
         if(routed.active_mode == "COUNCIL")
         {
            string sid = routed.council.aggregate.best_strategy_id;
            string fam = LAB_InferFamilyFromStrategyId(sid);
            SCM_RecordTradeOpenEvent(
               gSCMCache,
               _Symbol,
               gCurrentDecisionId,
               sid,
               sid,
               fam,
               routed.council.zone_coverage.zone_semantic,
               gRegime.regime_label,
               "SELL",
               opened
            );
         }
         if(opened)
         {
            MarkRuntimeTradeExecutedNow();
            CouncilAIAdvisoryAcknowledgeTradeOpenFromHeldCandidate(gCurrentDecisionId);
            ExecutionAuthorityRememberExecution();
            UpdateLastMeaningfulRuntimeEventBestEffort("EXECUTION_OPENED",
                                                       gCurrentDecisionCandidateName,
                                                       gCurrentDecisionCandidateFamily,
                                                       "",
                                                       "SELL",
                                                       "Runtime SELL entry opened under current cohort-governed authority.",
                                                       "trade_execution",
                                                       gCurrentDecisionId);
            RefreshExecutionAuthorityStatusBestEffort();
            LogInfo("Runtime SELL executed successfully");
         }
         else
         {
            MarkRuntimeTradeAttemptedThisBar();
            ExecutionAuthorityRememberReject("execution_open_failed");
            UpdateLastMeaningfulRuntimeEventBestEffort("EXECUTION_FAILED",
                                                       gCurrentDecisionCandidateName,
                                                       gCurrentDecisionCandidateFamily,
                                                       "execution_open_failed",
                                                       "SELL",
                                                       "Runtime SELL entry failed at trade open stage.",
                                                       "trade_execution",
                                                       gCurrentDecisionId);
            RefreshExecutionAuthorityStatusBestEffort();
            LogWarn("Runtime SELL execution failed");
         }

         RuntimeRiskSafetyRecordExecutionOpenResult(opened);
         if(!opened && RuntimeRiskSafetyLockoutTriggered())
            LogWarn("Runtime risk/safety execution failure lockout engaged | failures=" + IntegerToString(gRuntimeConsecutiveOpenFailures));

         DiagnosticRuntimeSeedCycleBase("trade_open_outcome");
         DiagnosticRuntimeApplyRoutedContext(routed);
         DiagnosticRuntimeRecordTradeOpen(gCurrentDecisionId, "SELL", opened);
         SaveDiagnosticRuntimeSummaryBestEffort();
         AppendValidationDecisionJournal(
            routed,
            m1,
            eval,
            true,
            (opened ? "SELL" : "SELL"),
            (opened ? "" : "execution_open_failed"),
            "SELL",
            (opened ? "" : "execution_open_failed"),
            (opened ? "" : "execution_open_failed"),
            (opened ? "TRADE_OPEN_EXECUTED" : "TRADE_OPEN_FAILED")
         );
         RefreshExecutionQualityValidationArtifactsBestEffort();

         return;
      }

      if(eval.decision == RUNTIME_REJECT)
      {
         if(routed.active_mode == "COUNCIL")
            PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
         else
            PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);
      
         UnifiedDecisionConfidence conf;
         BuildUnifiedDecisionConfidence(routed, gRegime, eval, false, "REJECT", conf);

         gCurrentDecisionId = PJ_MakeDecisionId();
         InitFailureClassification(gDecisionFailure);
         ClassifyDecisionFailureV1(conf, gRegime, "REJECT", (routed.active_mode == "COUNCIL" ? routed.council.summary : ""), gDecisionFailure);


         string pjLog = "";
         string councilSummary = (routed.active_mode == "COUNCIL" ? routed.council.summary : "");
         if(routed.active_mode == "COUNCIL")
            PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
         else
            PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);
         PJ_SetDecisionValidationContext(
            DiagnosticInferRejectBlockingLayer(routed),
            DiagnosticInferRejectReasonCode(routed),
            "DECISION_REJECTED",
            "REJECT",
            ValidationRejectionFamilyForJournal(DiagnosticInferRejectBlockingLayer(routed))
         );
         JournalAppendDecisionV3(
            gCurrentDecisionId,
            gPlan,
            routed.active_mode,
            m1,
            gRegime,
            conf,
            eval,
             "REJECT",
             (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL"),
             (gHasRiskPolicy ? gRiskPolicy.reason : ""),
             gDecisionFailure.failure_class,
             gDecisionFailure.failure_reason_summary,
             gDecisionFailure.failure_severity,
             gDecisionFailure.failure_basis,
             councilSummary,
            "",
            "",
            (gHasRollbackSignal ? gRollbackSignal.state_text : "NONE"),
            (gHasRollbackSignal ? gRollbackSignal.rollback_signal_score : 0.0),
            (gHasRollbackSignal ? gRollbackSignal.rollback_signal_reason : ""),
            (gHasFailureCluster ? gFailureCluster.clustered_failure_detected : false),
            (gHasFailureCluster ? gFailureCluster.dominant_failure_class : "UNKNOWN_FAILURE"),
            (gHasFailureCluster ? gFailureCluster.dominant_failure_count : 0),
            (gHasFailureCluster ? gFailureCluster.failure_cluster_score : 0.0),
            (gHasFailureCluster ? gFailureCluster.dominant_regime_if_any : ""),
            (gHasRegimePerf ? gRegimePerf.summary_reason : ""),
            pjLog
         );
         LogStateOnce(pjLog);
         RefreshExecutionQualityValidationArtifactsBestEffort();
         // Strategy Confidence Memory v1 (observer-only): rejected decision observation
         if(routed.active_mode == "COUNCIL")
         {
            string sid = routed.council.aggregate.best_strategy_id;
            string fam = LAB_InferFamilyFromStrategyId(sid);
            string dom = routed.council.aggregate.dominant_side;
            string dir = (dom == "BUY" ? "BUY" : (dom == "SELL" ? "SELL" : "UNKNOWN"));

            SCM_RecordDecisionEvent(
               gSCMCache,
               _Symbol,
               gCurrentDecisionId,
               sid,
               sid,
               fam,
               routed.council.zone_coverage.zone_semantic,
               gRegime.regime_label,
               dir,
               "REJECT",
               false,
               false,
               "",
               routed.council.zone_coverage.coverage_label
            );
         }

         MaybeRunShadowReplayAndLog(m1, m5, gRegime, routed, eval, conf, gCurrentDecisionId);

         LogStateOnce("Runtime rejected trade");

         DiagnosticRuntimeSeedCycleBase("decision_reject");
         DiagnosticRuntimeApplyRoutedContext(routed);
         DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
         DiagnosticRuntimeSetOutcome(
            "REJECT",
            true,
            DiagnosticInferRejectBlockingLayer(routed),
            DiagnosticInferRejectReasonCode(routed),
            "DECISION_REJECTED",
            "runtime_reject_visible"
         );
         SaveDiagnosticRuntimeSummaryBestEffort();

         if(routed.active_mode == "COUNCIL")
            PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
         else
            PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);
      }

      {
         UnifiedDecisionConfidence conf;
         BuildUnifiedDecisionConfidence(routed, gRegime, eval, false, "WAIT", conf);

         gCurrentDecisionId = PJ_MakeDecisionId();
         InitFailureClassification(gDecisionFailure);
         ClassifyDecisionFailureV1(conf, gRegime, "WAIT", (routed.active_mode == "COUNCIL" ? routed.council.summary : ""), gDecisionFailure);


         string pjLog = "";
         string councilSummary = (routed.active_mode == "COUNCIL" ? routed.council.summary : "");
         if(routed.active_mode == "COUNCIL")
            PJ_SetZoneCoverageSnapshot(routed.council.zone_coverage.coverage_label, routed.council.zone_coverage.diversity_score, routed.council.zone_coverage.concentration_score);
         else
            PJ_SetZoneCoverageSnapshot("", 0.0, 0.0);
         PJ_SetDecisionValidationContext(
            DiagnosticInferWaitBlockingLayer(routed),
            DiagnosticInferWaitReasonCode(routed),
            "NO_TRADE_WAIT",
            "WAIT",
            ValidationRejectionFamilyForJournal(DiagnosticInferWaitBlockingLayer(routed))
         );
         JournalAppendDecisionV3(
            gCurrentDecisionId,
            gPlan,
            routed.active_mode,
            m1,
            gRegime,
            conf,
            eval,
             "WAIT",
             (gHasRiskPolicy ? gRiskPolicy.state_text : "NORMAL"),
             (gHasRiskPolicy ? gRiskPolicy.reason : ""),
             gDecisionFailure.failure_class,
             gDecisionFailure.failure_reason_summary,
             gDecisionFailure.failure_severity,
             gDecisionFailure.failure_basis,
             councilSummary,
            "",
            "",
            (gHasRollbackSignal ? gRollbackSignal.state_text : "NONE"),
            (gHasRollbackSignal ? gRollbackSignal.rollback_signal_score : 0.0),
            (gHasRollbackSignal ? gRollbackSignal.rollback_signal_reason : ""),
            (gHasFailureCluster ? gFailureCluster.clustered_failure_detected : false),
            (gHasFailureCluster ? gFailureCluster.dominant_failure_class : "UNKNOWN_FAILURE"),
            (gHasFailureCluster ? gFailureCluster.dominant_failure_count : 0),
            (gHasFailureCluster ? gFailureCluster.failure_cluster_score : 0.0),
            (gHasFailureCluster ? gFailureCluster.dominant_regime_if_any : ""),
            (gHasRegimePerf ? gRegimePerf.summary_reason : ""),
            pjLog
         );
         LogStateOnce(pjLog);
         RefreshExecutionQualityValidationArtifactsBestEffort();

         if(eval.decision == RUNTIME_WAIT)
         {
            string waitBlockingLayer = DiagnosticInferWaitBlockingLayer(routed);

            DiagnosticRuntimeSeedCycleBase("decision_wait");
            DiagnosticRuntimeApplyRoutedContext(routed);
            DiagnosticRuntimeSetDecisionId(gCurrentDecisionId);
            DiagnosticRuntimeSetOutcome(
               "WAIT",
               DiagnosticBlockingLayerIsBlocking(waitBlockingLayer),
               waitBlockingLayer,
               DiagnosticInferWaitReasonCode(routed),
               "NO_TRADE_WAIT",
               "runtime_wait_visible"
            );
            SaveDiagnosticRuntimeSummaryBestEffort();
         }
      }

      LogStateOnce("Runtime waiting for better setup");
      return;
   }

   //------------------------------------------------------
   // Non-new-bar ticks: do nothing heavy
   //------------------------------------------------------
   LogStateOnce("Waiting for next M1 runtime cycle");
}

bool ResolveDirectionFromJournalTradeOpen(const ulong positionId, string &direction)
{
   direction = "";
   if(positionId == 0)
      return false;

   return JA_FindTradeOpenDirectionByPositionId(positionId, direction);
}

//---------------------------------------------------------
// Council close finalizer
//---------------------------------------------------------
bool FinalizeCouncilClosedTrade(
   ulong magic,
   string symbol,
   string feedbackPath,
   string &logMessage
)
{
   logMessage = "";

   const string kCouncilCloseDedupStatePath = "AI\\ai_last_recorded_council_close_deal.txt";

   ulong    lastDealTicket = 0;
   datetime lastCloseTime  = 0;
   bool     lastValid      = false;
   LoadLastRecordedDealState(kCouncilCloseDedupStatePath, lastDealTicket, lastCloseTime, lastValid);

   if(!HistorySelect(0, TimeCurrent()))
   {
      logMessage = "Council finalize skipped: HistorySelect failed";
      return false;
   }

   int total = HistoryDealsTotal();
   if(total <= 0)
   {
      logMessage = "Council finalize skipped: no deals";
      return false;
   }

   ulong    closeDealTicket = 0;
   datetime closeTime       = 0;
   double   profit          = 0.0;

   // Find the latest strictly-new DEAL_ENTRY_OUT for this symbol+magic.
   for(int i = total - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0)
         continue;

      string dealSymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      long   dealMagic  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      long   entryType  = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

      if(dealSymbol != symbol)
         continue;

      if((ulong)dealMagic != magic)
         continue;

      if(entryType != DEAL_ENTRY_OUT)
         continue;

      datetime dt = (datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME);

      bool isNew = true;
      if(lastValid)
      {
         if(dt < lastCloseTime)
            isNew = false;
         else if(dt == lastCloseTime && dealTicket <= lastDealTicket)
            isNew = false;
      }

      if(!isNew)
         continue;

      closeDealTicket = dealTicket;
      closeTime       = dt;
      profit          = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
      break;
   }

   if(closeDealTicket == 0)
   {
      logMessage = "Council finalize skipped: no new council close deal";
      return false;
   }

   CouncilFeedbackRecord r;
   InitCouncilFeedbackRecord(r);

   r.symbol      = symbol;
   r.plan_id     = gPlan.plan_id;
   r.mode_name   = "COUNCIL";
   r.record_type = CouncilFeedbackRecordTypeTradeCloseOutcome();

   // Preserve existing outcome behavior.
   if(profit > 0.0)
      r.trade_result = "WIN";
   else if(profit < 0.0)
      r.trade_result = "LOSS";
   else
      r.trade_result = "FLAT";

   r.profit     = profit;
   r.close_time = closeTime;

   // Resolve correlation best-effort (reuse existing infrastructure).
   TradeCorrelation corr;
   InitTradeCorrelation(corr);

   if(Correlation_ResolveForClosedDeal(closeDealTicket, magic, gLastEntryDecisionId, corr))
   {
      r.decision_id            = corr.decision_id;
      r.correlated_decision_id = corr.correlated_decision_id;
      r.position_id            = corr.position_id;
      r.close_deal_id          = corr.close_deal_id;
      r.correlation_method     = corr.correlation_method;
      r.correlation_quality    = corr.correlation_quality;
   }
   else
   {
      // Keep safe defaults but still persist deal identifiers.
      r.position_id   = (ulong)HistoryDealGetInteger(closeDealTicket, DEAL_POSITION_ID);
      r.close_deal_id = closeDealTicket;
   }

   if(r.position_id == 0)
      r.position_id = (ulong)HistoryDealGetInteger(closeDealTicket, DEAL_POSITION_ID);

   if(r.close_deal_id == 0)
      r.close_deal_id = closeDealTicket;

   string resolvedDirection = "";
   if(ResolveClosedPositionDirection(closeDealTicket, resolvedDirection))
   {
      if(resolvedDirection == "BUY" || resolvedDirection == "SELL")
         r.executed_direction = resolvedDirection;
   }

   if(!CouncilFeedbackIsDirectionText(r.executed_direction) && r.position_id > 0)
   {
      if(ResolveDirectionFromJournalTradeOpen(r.position_id, resolvedDirection))
         r.executed_direction = resolvedDirection;
   }

   if(CouncilFeedbackIsDirectionText(r.executed_direction))
      r.final_decision = r.executed_direction;

   NormalizeCouncilFeedbackRecordSemantics(r);

   string fbLog = "";
   if(SaveCouncilFeedbackRecord(feedbackPath, r, fbLog))
   {
      // Commit dedup pointer only after successful save.
      SaveLastRecordedDealState(kCouncilCloseDedupStatePath, closeDealTicket, closeTime);

      logMessage = "Council closed trade recorded | result=" + r.trade_result
                 + " | close_deal_id=" + (string)closeDealTicket;
      return true;
   }

   logMessage = "Council closed trade save failed";
   return false;
}
//---------------------------------------------------------
// Shadow replay (Phase 5A) - no side effects, journaling only
//---------------------------------------------------------
void MaybeRunShadowReplayAndLog(
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RegimeClassification &regime,
   RoutedRuntimeEvaluation &productionRouted,
   RuntimeEvaluation &productionEval,
   UnifiedDecisionConfidence &productionConf,
   string productionDecisionId
)
{
   if(!gPlan.shadow_evaluation_enabled)
      return;

   if(!gPlan.shadow_replay_enabled)
      return;

   string proposalPath = "AI\\ai_next_plan_proposal.json";

   ShadowReplayResult shadow;
   ShadowComparisonResult cmp;
   string srLog = "";

   if(!RunShadowReplayV1(
         proposalPath,
         _Symbol,
         Magic,
         gLastRuntimeEntryBars,
         gHasRiskPolicy,
         gRiskPolicy,
         m1,
         m5,
         regime,
         productionRouted,
         productionEval,
         productionConf,
         shadow,
         cmp,
         srLog))
   {
      return;
   }

   LogStateOnce(srLog);

   if(gPlan.shadow_comparison_logging_enabled)
   {
      string sdLog = "";
      JournalAppendShadowDecisionReplayV5(
         shadow.shadow_decision_id,
         productionDecisionId,
         shadow.shadow_plan_fingerprint,
         shadow.shadow_mode,
         SR_DecisionToText(shadow.shadow_decision),
         shadow.shadow_direction,
         shadow.shadow_confidence_score,
         shadow.shadow_raw_signal_score,
         shadow.shadow_regime_fit_score,
         shadow.shadow_entry_quality_score,
         shadow.shadow_entry_edge_score,
         shadow.shadow_follow_through_quality_score,
         shadow.shadow_strategy_regime_fit_score,
         shadow.shadow_decision_quality_score,
         shadow.shadow_expected_rr_estimate,
         shadow.shadow_execution_geometry_score,
         shadow.shadow_execution_geometry_label,
         shadow.shadow_entry_quality_label,
         shadow.shadow_entry_edge_label,
         shadow.shadow_follow_through_quality_label,
         shadow.shadow_strategy_regime_fit_label,
         shadow.shadow_decision_quality_label,
         shadow.shadow_final_permission,
         shadow.shadow_policy_permission,
         shadow.shadow_policy_reason,
         shadow.shadow_policy_state,
         shadow.shadow_reason_summary,
         sdLog
);
if(StringLen(sdLog) > 0) LogStateOnce(sdLog);

      string scLog = "";
      JournalAppendShadowComparisonV5(
         shadow.shadow_decision_id,
         productionDecisionId,
         cmp.relation_class,
         cmp.decision_agreement,
         cmp.production_decision,
         cmp.shadow_decision,
         cmp.production_direction,
         cmp.shadow_direction,
         cmp.confidence_delta,
         cmp.permission_delta,
         cmp.entry_quality_delta,
         cmp.regime_fit_delta,
         cmp.decision_quality_delta,
         cmp.entry_edge_delta,
         cmp.follow_through_quality_delta,
         cmp.expected_rr_delta,
         cmp.execution_geometry_delta,
         cmp.comparison_summary,
         cmp.comparison_basis,
         scLog
);
if(StringLen(scLog) > 0) LogStateOnce(scLog);
   }
}
