#ifndef __DASHBOARD_STATE_CLASSIFIER_MQH__
#define __DASHBOARD_STATE_CLASSIFIER_MQH__

#include "dashboard_state_collector.mqh"

int DashboardSeverityRank(DashboardSeverityClass severity)
{
   return (int)severity;
}

DashboardSeverityClass DashboardMaxSeverity(DashboardSeverityClass a, DashboardSeverityClass b)
{
   return (DashboardSeverityRank(a) >= DashboardSeverityRank(b) ? a : b);
}

string DashboardSeverityText(DashboardSeverityClass severity)
{
   switch(severity)
   {
      case DASHBOARD_SEVERITY_INFO:     return "INFO";
      case DASHBOARD_SEVERITY_NOTICE:   return "NOTICE";
      case DASHBOARD_SEVERITY_CAUTION:  return "CAUTION";
      case DASHBOARD_SEVERITY_WARNING:  return "WARNING";
      case DASHBOARD_SEVERITY_CRITICAL: return "CRITICAL";
   }

   return "NOTICE";
}

string DashboardStateClassText(DashboardStateClass state_class)
{
   switch(state_class)
   {
      case DASHBOARD_STATE_CLASS_AUTHORITATIVE:               return "AUTHORITATIVE";
      case DASHBOARD_STATE_CLASS_DERIVED:                     return "DERIVED";
      case DASHBOARD_STATE_CLASS_PLACEHOLDER_OR_TRANSITIONAL: return "TRANSITIONAL";
   }

   return "DERIVED";
}

int DashboardPrecedenceWeight(const string state_id)
{
   if(state_id == "FROZEN" || state_id == "TRADING_BLOCKED" || state_id == "STARTUP_BLOCKED" || state_id == "EXPORT_BLOCKED")
      return 500;
   if(state_id == "GOVERNANCE_HELD" || state_id == "PILOT_DEFINED_NOT_LIVE")
      return 400;
   if(state_id == "NOT_READY" || state_id == "READINESS_PARTIAL" || state_id == "STARTUP_PARTIAL" || state_id == "SOURCE_PARTIAL" || state_id == "STALE_STATE")
      return 300;
   if(state_id == "MIXED_PLANE_SUMMARY_ONLY" || state_id == "PLACEHOLDER_STATE" || state_id == "PENDING_RUNTIME_INIT" || state_id == "SUMMARY_ONLY_NOT_PRIMARY_TRUTH" || state_id == "TRANSITIONAL_ARTIFACT" || state_id == "ZERO_RECORD_STATE" || state_id == "STATUS_EMITTED_NOT_RUNTIME_CONFIRMED")
      return 200;
   return 100;
}

DashboardStateClass DashboardStateClassForId(const string state_id)
{
   if(state_id == "FROZEN" || state_id == "TRADING_BLOCKED" || state_id == "GOVERNANCE_HELD" || state_id == "PILOT_DEFINED_NOT_LIVE" ||
      state_id == "EXPORT_BLOCKED" || state_id == "STARTUP_OK" || state_id == "STARTUP_BLOCKED" || state_id == "FACTORY_READY" ||
      state_id == "FACTORY_PARTIAL" || state_id == "AI_OFF" || state_id == "AI_SHADOW_ONLY" || state_id == "AI_ADVISORY_ONLY")
      return DASHBOARD_STATE_CLASS_AUTHORITATIVE;

   if(state_id == "NOT_READY" || state_id == "STARTUP_PARTIAL" || state_id == "READINESS_PARTIAL" || state_id == "SOURCE_PARTIAL" ||
      state_id == "REVIEW_PENDING" || state_id == "EVIDENCE_ONLY" || state_id == "STALE_STATE" ||
      state_id == "MIXED_PLANE_SUMMARY_ONLY" || state_id == "ARCHITECTURE_DEFINED_NOT_OPERATIONALLY_ACTIVE")
      return DASHBOARD_STATE_CLASS_DERIVED;

   return DASHBOARD_STATE_CLASS_PLACEHOLDER_OR_TRANSITIONAL;
}

DashboardSeverityClass DashboardStateSeverityForId(const string state_id)
{
   if(state_id == "FROZEN" || state_id == "TRADING_BLOCKED" || state_id == "STARTUP_BLOCKED" || state_id == "EXPORT_BLOCKED")
      return DASHBOARD_SEVERITY_CRITICAL;
   if(state_id == "GOVERNANCE_HELD" || state_id == "NOT_READY" || state_id == "AI_OFF" || state_id == "STALE_STATE")
      return DASHBOARD_SEVERITY_WARNING;
   if(state_id == "STARTUP_PARTIAL" || state_id == "READINESS_PARTIAL" || state_id == "SOURCE_PARTIAL" || state_id == "ZERO_RECORD_STATE")
      return DASHBOARD_SEVERITY_CAUTION;
   if(state_id == "PILOT_DEFINED_NOT_LIVE" || state_id == "AI_SHADOW_ONLY" || state_id == "AI_ADVISORY_ONLY" ||
      state_id == "FACTORY_READY" || state_id == "FACTORY_PARTIAL" || state_id == "EVIDENCE_ONLY" || state_id == "MIXED_PLANE_SUMMARY_ONLY")
      return DASHBOARD_SEVERITY_NOTICE;
   return DASHBOARD_SEVERITY_INFO;
}

string DashboardDominantState(const string current_state, const string candidate_state)
{
   if(StringLen(current_state) == 0)
      return candidate_state;

   int current_weight = DashboardPrecedenceWeight(current_state);
   int candidate_weight = DashboardPrecedenceWeight(candidate_state);

   if(candidate_weight > current_weight)
      return candidate_state;

   if(candidate_weight == current_weight &&
      DashboardSeverityRank(DashboardStateSeverityForId(candidate_state)) > DashboardSeverityRank(DashboardStateSeverityForId(current_state)))
      return candidate_state;

   return current_state;
}

string DashboardSourceBadgeFromIds(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   bool any_missing = false;
   bool any_partial = false;

   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(!DashboardGetSourceState(ids[i], state) || !state.source_present)
         any_missing = true;
      else if(!state.parse_ok || state.partial || state.placeholder_only)
         any_partial = true;
   }

   if(any_missing)
      return "Source: Missing";
   if(any_partial)
      return "Source: Partial";
   return "Source: Curated";
}

string DashboardFreshnessBadgeFromIds(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   bool any_unknown = false;
   bool any_stale = false;

   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(!DashboardGetSourceState(ids[i], state) || !state.source_present || !state.parse_ok)
      {
         any_unknown = true;
         continue;
      }

      if(state.stale)
         any_stale = true;
   }

   if(any_stale)
      return "Freshness: Stale";
   if(any_unknown)
      return "Freshness: Unconfirmed";
   return "Freshness: Current";
}

string DashboardAuthorityBadgeFromIds(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);

   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(DashboardGetSourceState(ids[i], state))
      {
         if(state.tier == DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY)
            return "Authority: Primary";
         if(state.tier == DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS)
            return "Authority: Structural";
      }
   }

   return "Authority: Context";
}

string DashboardPlaceholderBadgeFromIds(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   bool zero_record = false;
   bool summary_only = false;

   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(!DashboardGetSourceState(ids[i], state))
         continue;

      if(state.zero_record)
         zero_record = true;
      if(state.placeholder_only || state.mixed_plane)
         summary_only = true;
   }

   if(zero_record)
      return "Placeholder: Zero Record";
   if(summary_only)
      return "Placeholder: Summary Only";
   return "";
}

bool DashboardAnySourceStale(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(DashboardGetSourceState(ids[i], state) && state.stale)
         return true;
   }
   return false;
}

bool DashboardAnySourcePartial(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   bool any_visible = false;

   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(!DashboardGetSourceState(ids[i], state))
         return true;

      if(state.source_present)
         any_visible = true;

      if(!state.source_present || !state.parse_ok || state.partial || state.placeholder_only)
         return true;
   }

   return !any_visible;
}

bool DashboardAnySourceMixedPlane(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(DashboardGetSourceState(ids[i], state) && (state.mixed_plane || state.placeholder_only))
         return true;
   }
   return false;
}

bool DashboardAnyZeroRecord(const string source_ids_csv)
{
   string ids[];
   int n = StringSplit(source_ids_csv, '|', ids);
   for(int i = 0; i < n; i++)
   {
      DashboardCollectedSourceState state;
      if(DashboardGetSourceState(ids[i], state) && state.zero_record)
         return true;
   }
   return false;
}

bool DashboardGetBoolEither(const string primary_source_id,
                            const string primary_key,
                            const string secondary_source_id,
                            const string secondary_key,
                            bool &out_value)
{
   bool value_primary = false;
   bool value_secondary = false;
   bool has_primary = DashboardGetBool(primary_source_id, primary_key, value_primary);
   bool has_secondary = DashboardGetBool(secondary_source_id, secondary_key, value_secondary);

   out_value = (value_primary || value_secondary);
   return (has_primary || has_secondary);
}

bool DashboardGetStringEither(const string primary_source_id,
                              const string primary_key,
                              const string secondary_source_id,
                              const string secondary_key,
                              string &out_value)
{
   out_value = "";

   string value = "";
   if(DashboardGetString(primary_source_id, primary_key, value) && StringLen(value) > 0)
   {
      out_value = value;
      return true;
   }

   if(DashboardGetString(secondary_source_id, secondary_key, value) && StringLen(value) > 0)
   {
      out_value = value;
      return true;
   }

   return false;
}


bool DashboardExecutionAuthorityCutoverActive()
{
   string cutover_state = "";
   bool factory_governed = false;
   bool cohort_defined = false;

   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_cutover_state", cutover_state);
   DashboardGetBool("SRC_EXECUTION_AUTHORITY_STATUS", "factory_governed_execution_authority_active", factory_governed);
   DashboardGetBool("SRC_EXECUTION_AUTHORITY_STATUS", "active_operating_cohort_defined", cohort_defined);

   return (cutover_state == "CUTOVER_ACTIVE" && factory_governed && cohort_defined);
}

bool DashboardActiveOperatingCohortDefinedSemantically()
{
   bool cohort_defined = false;
   int candidate_count = 0;
   string cohort_state = "";

   DashboardGetBool("SRC_EXECUTION_AUTHORITY_STATUS", "active_operating_cohort_defined", cohort_defined);
   DashboardGetInt("SRC_ACTIVE_OPERATING_COHORT", "candidate_count", candidate_count);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "active_operating_cohort_state", cohort_state);

   return (cohort_defined && candidate_count > 0 && cohort_state == "COHORT_ACTIVE");
}

string DashboardExecutionAuthoritySourceText()
{
   string src = "";
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_source", src);
   return DashboardValueOr(src, "unavailable");
}

string DashboardOperatingRiskEnvelopeState()
{
   string value = "";
   if(DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "operating_risk_envelope_state", value) && StringLen(value) > 0)
      return value;
   return "PENDING_RUNTIME_INIT";
}

bool DashboardGuardrailBlockActive()
{
   bool clear_for_new_entries = true;
   string state = DashboardOperatingRiskEnvelopeState();
   if(DashboardGetBool("SRC_OPERATING_RISK_ENVELOPE_STATUS", "envelope_clear_for_new_entries", clear_for_new_entries))
      return (!clear_for_new_entries || state == "ENVELOPE_BLOCKED" || state == "EMERGENCY_STOP_ACTIVE");

   return (state == "ENVELOPE_BLOCKED" || state == "EMERGENCY_STOP_ACTIVE");
}

string DashboardGuardrailReasonCode()
{
   string value = "";
   if(DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", value) && StringLen(value) > 0)
      return value;
   return "operating_risk_envelope_blocked";
}

string DashboardGuardrailOwner()
{
   string value = "";
   if(DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_owner", value) && StringLen(value) > 0)
      return value;
   return "operating_risk_envelope";
}

string DashboardRuntimeOperationalLabel()
{
   if(DashboardExecutionAuthorityCutoverActive() && DashboardActiveOperatingCohortDefinedSemantically())
   {
      if(DashboardGuardrailBlockActive())
         return "Cohort-governed guardrail blocked";
      return "Cohort-governed active";
   }
   if(DashboardRuntimeFreezeSemanticallyActive())
      return "Runtime Frozen";
   if(DashboardTradingBlockedSemantically())
      return "Trading Blocked";
   return "Runtime Active";
}


bool DashboardRuntimeFreezeSemanticallyActive()
{
   if(DashboardExecutionAuthorityCutoverActive() && DashboardActiveOperatingCohortDefinedSemantically())
      return false;

   bool freeze_active = false;
   bool execution_identity_frozen = false;
   bool compiled_privilege_frozen = false;
   bool council_privilege_frozen = false;
   string package_freeze_state = "";

   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "strategy_transfer_runtime_freeze_active",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "strategy_transfer_runtime_freeze_active",
                          freeze_active);
   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "strategy_execution_identity_authority_frozen",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "strategy_execution_identity_authority_frozen",
                          execution_identity_frozen);
   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "compiled_plan_runtime_privilege_frozen",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "compiled_plan_runtime_privilege_frozen",
                          compiled_privilege_frozen);
   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "council_runtime_execution_privilege_frozen",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "council_runtime_execution_privilege_frozen",
                          council_privilege_frozen);
   DashboardGetStringEither("SRC_RUNTIME_GOVERNANCE_STATUS", "package1_runtime_freeze_state",
                            "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "strategy_transfer_runtime_freeze_mode",
                            package_freeze_state);

   return (freeze_active || execution_identity_frozen || compiled_privilege_frozen || council_privilege_frozen || package_freeze_state == "ACTIVE" || package_freeze_state == "CENTRAL_RUNTIME_POLICY_GATE");
}

bool DashboardPolicyLockedSemantically()
{
   if(DashboardExecutionAuthorityCutoverActive() && DashboardActiveOperatingCohortDefinedSemantically())
      return false;

   bool policy_locked = false;
   bool factory_admission_required = false;
   string package_policy_lock_state = "";

   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "factory_first_admission_policy_locked",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "factory_first_admission_policy_locked",
                          policy_locked);
   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "future_factory_admission_required_for_execution",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "future_factory_admission_required_for_execution",
                          factory_admission_required);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "package1_policy_lock_state", package_policy_lock_state);

   return (policy_locked || factory_admission_required || package_policy_lock_state == "ACTIVE");
}

bool DashboardExecutionPrivilegeFrozenSemantically()
{
   if(DashboardExecutionAuthorityCutoverActive() && DashboardActiveOperatingCohortDefinedSemantically())
      return false;

   bool execution_identity_frozen = false;
   bool compiled_privilege_frozen = false;
   bool council_privilege_frozen = false;

   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "strategy_execution_identity_authority_frozen",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "strategy_execution_identity_authority_frozen",
                          execution_identity_frozen);
   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "compiled_plan_runtime_privilege_frozen",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "compiled_plan_runtime_privilege_frozen",
                          compiled_privilege_frozen);
   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "council_runtime_execution_privilege_frozen",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "council_runtime_execution_privilege_frozen",
                          council_privilege_frozen);

   return (execution_identity_frozen || compiled_privilege_frozen || council_privilege_frozen);
}

bool DashboardTradingBlockedSemantically()
{
   bool trading_allowed = true;
   bool final_blocked = false;
   bool execution_globally_blocked = false;
   string governance_state = "";
   string final_decision = "";

   DashboardGetBool("SRC_RUNTIME_GOVERNANCE_STATUS", "trading_allowed", trading_allowed);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "governance_state", governance_state);
   DashboardGetBool("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_blocked", final_blocked);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_decision", final_decision);
   DashboardGetBool("SRC_EXECUTION_AUTHORITY_STATUS", "execution_globally_blocked", execution_globally_blocked);

   if(DashboardExecutionAuthorityCutoverActive() && DashboardActiveOperatingCohortDefinedSemantically())
   {
      if(execution_globally_blocked)
         return true;
      if(!trading_allowed)
         return true;
      if(governance_state == "STARTUP_INIT" || governance_state == "HOLD" || governance_state == "GOVERNANCE_HELD" || governance_state == "TRUTH_NOT_READY" || governance_state == "DIAGNOSTICS_NOT_READY")
         return true;
      return false;
   }

   if(DashboardRuntimeFreezeSemanticallyActive())
      return true;
   if(DashboardPolicyLockedSemantically())
      return true;
   if(DashboardExecutionPrivilegeFrozenSemantically())
      return true;
   if(!trading_allowed)
      return true;
   if(final_blocked || final_decision == "INIT_PENDING")
      return true;
   if(governance_state == "STARTUP_INIT" || governance_state == "HOLD" || governance_state == "GOVERNANCE_HELD")
      return true;

   return false;
}

string DashboardRuntimePostureState()
{
   string governance_state = "";
   string final_decision = "";
   bool final_blocked = false;
   bool execution_globally_blocked = false;

   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "governance_state", governance_state);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_decision", final_decision);
   DashboardGetBool("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_blocked", final_blocked);
   DashboardGetBool("SRC_EXECUTION_AUTHORITY_STATUS", "execution_globally_blocked", execution_globally_blocked);

   if(DashboardExecutionAuthorityCutoverActive() && DashboardActiveOperatingCohortDefinedSemantically())
   {
      if(DashboardGuardrailBlockActive())
         return "TRADING_BLOCKED";
      if(execution_globally_blocked)
         return "TRADING_BLOCKED";
      if(governance_state == "STARTUP_INIT" || governance_state == "TRUTH_NOT_READY" || governance_state == "DIAGNOSTICS_NOT_READY")
         return "STARTUP_BLOCKED";
      if(governance_state == "HOLD" || governance_state == "GOVERNANCE_HELD")
         return "GOVERNANCE_HELD";
      return "STARTUP_OK";
   }

   if(DashboardRuntimeFreezeSemanticallyActive())
      return "FROZEN";
   if(DashboardTradingBlockedSemantically())
      return "TRADING_BLOCKED";
   if(final_blocked || governance_state == "STARTUP_INIT" || final_decision == "INIT_PENDING")
      return "STARTUP_BLOCKED";
   if(governance_state == "HOLD" || governance_state == "GOVERNANCE_HELD")
      return "GOVERNANCE_HELD";
   return "STARTUP_OK";
}

string DashboardExportPostureState()
{
   string gate_result = "";
   bool external_delivery_allowed = false;

   DashboardGetString("SRC_EXPORT_RELEASE_GATE_STATUS", "overall_gate_result", gate_result);
   DashboardGetBool("SRC_EXPORT_RELEASE_GATE_STATUS", "external_delivery_allowed", external_delivery_allowed);

   if(gate_result == "BLOCKED" || !external_delivery_allowed)
      return "EXPORT_BLOCKED";

   return "ARCHITECTURE_DEFINED_NOT_OPERATIONALLY_ACTIVE";
}

string DashboardPilotPostureState()
{
   bool pilot_cycle_defined = false;
   bool live_pilot_execution_started = false;
   bool runtime_reactivation_performed = false;

   DashboardGetBool("SRC_TRANSFER_PACKAGE5_PILOT_CYCLE", "pilot_cycle_defined", pilot_cycle_defined);
   DashboardGetBool("SRC_TRANSFER_PACKAGE5_PILOT_CYCLE", "live_pilot_execution_started", live_pilot_execution_started);
   DashboardGetBool("SRC_TRANSFER_PACKAGE5_PILOT_CYCLE", "runtime_reactivation_performed", runtime_reactivation_performed);

   if(pilot_cycle_defined && !live_pilot_execution_started && !runtime_reactivation_performed)
      return "PILOT_DEFINED_NOT_LIVE";

   return "ARCHITECTURE_DEFINED_NOT_OPERATIONALLY_ACTIVE";
}

string DashboardAIAuthorityState()
{
   string authority_state = "";
   if(DashboardGetString("SRC_AI_ACTIVATION_READINESS", "authority_state", authority_state))
      return authority_state;

   return "AI_OFF";
}

string DashboardFactoryPostureState()
{
   bool intake_ready = false;
   bool decomp_ready = false;

   DashboardGetBool("SRC_FACTORY_INTAKE_STATUS", "edge_factory_intake_ready", intake_ready);
   DashboardGetBool("SRC_EDGE_FACTORY_DECOMPOSITION_STATUS", "edge_factory_decomposition_ready", decomp_ready);

   if(intake_ready && decomp_ready)
      return "FACTORY_READY";
   if(intake_ready || decomp_ready)
      return "FACTORY_PARTIAL";

   return "FACTORY_PARTIAL";
}

string DashboardTopPostureState()
{
   string dominant = "";
   dominant = DashboardDominantState(dominant, DashboardRuntimePostureState());
   dominant = DashboardDominantState(dominant, DashboardExportPostureState());
   dominant = DashboardDominantState(dominant, DashboardPilotPostureState());
   dominant = DashboardDominantState(dominant, DashboardAIAuthorityState());
   dominant = DashboardDominantState(dominant, DashboardFactoryPostureState());
   return dominant;
}

string DashboardSourceUpdatedAtOrUnknown(const string source_id)
{
   DashboardCollectedSourceState state;
   if(!DashboardGetSourceState(source_id, state))
      return "unavailable";

   if(StringLen(state.timestamp_value) > 0)
      return state.timestamp_value;
   if(state.last_poll_time > 0)
      return TimeToString(state.last_poll_time, TIME_DATE | TIME_SECONDS);
   return "unavailable";
}

string DashboardDominantBlockSourceId()
{
   if(DashboardGuardrailBlockActive())
      return "SRC_OPERATING_RISK_ENVELOPE_STATUS";

   string runtime_state = DashboardRuntimePostureState();
   if(runtime_state == "FROZEN" || runtime_state == "TRADING_BLOCKED" || runtime_state == "STARTUP_BLOCKED" || runtime_state == "GOVERNANCE_HELD")
   {
      if(runtime_state == "STARTUP_BLOCKED")
         return "SRC_DIAGNOSTIC_RUNTIME_SUMMARY";
      return "SRC_RUNTIME_GOVERNANCE_STATUS";
   }

   if(DashboardExportPostureState() == "EXPORT_BLOCKED")
      return "SRC_EXPORT_RELEASE_GATE_STATUS";
   if(DashboardPilotPostureState() == "PILOT_DEFINED_NOT_LIVE")
      return "SRC_TRANSFER_PACKAGE5_PILOT_CYCLE";
   if(DashboardAIAuthorityState() == "AI_OFF" || DashboardAIAuthorityState() == "NOT_READY")
      return "SRC_AI_ACTIVATION_READINESS";

   return "SRC_RUNTIME_GOVERNANCE_STATUS";
}

string DashboardDominantBlockSourceLabel()
{
   string source_id = DashboardDominantBlockSourceId();
   if(source_id == "SRC_RUNTIME_GOVERNANCE_STATUS")
      return "Runtime Governance Status";
   if(source_id == "SRC_OPERATING_RISK_ENVELOPE_STATUS")
      return "Operating Risk Envelope Status";
   if(source_id == "SRC_DIAGNOSTIC_RUNTIME_SUMMARY")
      return "Runtime Diagnostic Summary";
   if(source_id == "SRC_EXPORT_RELEASE_GATE_STATUS")
      return "Export Release Gate Status";
   if(source_id == "SRC_TRANSFER_PACKAGE5_PILOT_CYCLE")
      return "Pilot Cycle Status";
   if(source_id == "SRC_AI_ACTIVATION_READINESS")
      return "AI Activation Readiness";
   return "Curated Status Surface";
}

string DashboardDominantBlockReasonCode()
{
   string value = "";
   if(DashboardGuardrailBlockActive())
      return DashboardGuardrailReasonCode();

   string runtime_state = DashboardRuntimePostureState();
   if(runtime_state == "FROZEN")
   {
      if(DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "strategy_transfer_runtime_freeze_reason_code", value) && StringLen(value) > 0)
         return value;
      if(DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "reason_code", value) && StringLen(value) > 0)
         return value;
      return "runtime_freeze_active";
   }

   if(runtime_state == "TRADING_BLOCKED" || runtime_state == "GOVERNANCE_HELD")
   {
      if(DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "reason_code", value) && StringLen(value) > 0)
         return value;
      if(DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_block_reason_code", value) && StringLen(value) > 0)
         return value;
      return "trading_block_active";
   }

   if(runtime_state == "STARTUP_BLOCKED")
   {
      if(DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_block_reason_code", value) && StringLen(value) > 0)
         return value;
      return "startup_state_incomplete";
   }

   if(DashboardExportPostureState() == "EXPORT_BLOCKED")
   {
      if(DashboardGetString("SRC_EXPORT_RELEASE_GATE_STATUS", "default_gate_result_reason", value) && StringLen(value) > 0)
         return DashboardShortText(value, 80);
      return "export_blocked";
   }

   if(DashboardPilotPostureState() == "PILOT_DEFINED_NOT_LIVE")
      return "pilot_defined_not_live";

   if(DashboardGetString("SRC_AI_ACTIVATION_READINESS", "readiness_reason_code", value) && StringLen(value) > 0)
      return value;

   return "bounded_operational_block";
}

string DashboardDominantBlockAffectedDomain()
{
   if(DashboardGuardrailBlockActive())
      return "risk/safety";

   string runtime_state = DashboardRuntimePostureState();
   if(runtime_state == "FROZEN" || runtime_state == "TRADING_BLOCKED")
      return "runtime";
   if(runtime_state == "STARTUP_BLOCKED")
      return "startup/diagnostics";
   if(runtime_state == "GOVERNANCE_HELD")
      return "runtime/governance";
   if(DashboardExportPostureState() == "EXPORT_BLOCKED")
      return "export";
   if(DashboardPilotPostureState() == "PILOT_DEFINED_NOT_LIVE")
      return "pilot";
   return "AI";
}

string DashboardDominantBlockScope()
{
   if(DashboardGuardrailBlockActive())
   {
      string guard_owner = DashboardGuardrailOwner();
      if(StringLen(guard_owner) > 0)
         return guard_owner;
      return "runtime entry envelope";
   }

   string scope = "";
   if(DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "strategy_transfer_runtime_freeze_scope", scope) && StringLen(scope) > 0)
      return scope;

   if(DashboardDominantBlockAffectedDomain() == "export")
      return "external delivery";
   if(DashboardDominantBlockAffectedDomain() == "pilot")
      return "pilot execution";
   if(DashboardDominantBlockAffectedDomain() == "AI")
      return "AI authority";
   return "runtime execution";
}

string DashboardOperationalIntegrityOverallState()
{
   string value = "";
   if(DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "overall_state", value) && StringLen(value) > 0)
      return value;
   return "PARTIAL";
}

string DashboardOperationalIntegrityDominantState()
{
   string overall = DashboardOperationalIntegrityOverallState();
   if(overall == "COHERENT")
      return "STARTUP_OK";
   if(overall == "PARTIAL")
      return "READINESS_PARTIAL";
   if(overall == "DEGRADED")
      return "SOURCE_PARTIAL";
   return "NOT_READY";
}


string DashboardDerivedReadinessState()
{
   string readiness_state = "";
   if(DashboardGetString("SRC_AI_ACTIVATION_READINESS", "readiness_state", readiness_state) && readiness_state == "NOT_READY")
      return "NOT_READY";

   bool ai_bridge_ready = false;
   bool truth_ready = false;
   bool diagnostics_ready = false;
   bool replay_ready = false;
   bool validation_ready = false;
   bool safety_ready = false;
   bool sample_ready = false;

   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "ai_bridge_ready", ai_bridge_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "truth_ready", truth_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "diagnostics_ready", diagnostics_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "replay_ready", replay_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "validation_ready", validation_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "safety_ready", safety_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "sample_ready", sample_ready);

   if(!(ai_bridge_ready && truth_ready && diagnostics_ready && replay_ready && validation_ready && safety_ready && sample_ready))
      return "READINESS_PARTIAL";

   return "";
}

string DashboardDerivedStartupState()
{
   bool truth_ready = false;
   bool diagnostics_ready = false;
   bool final_blocked = false;
   string final_decision = "";
   string governance_state = "";

   DashboardGetBool("SRC_RUNTIME_GOVERNANCE_STATUS", "truth_ready", truth_ready);
   DashboardGetBool("SRC_RUNTIME_GOVERNANCE_STATUS", "diagnostics_ready", diagnostics_ready);
   DashboardGetBool("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_blocked", final_blocked);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_decision", final_decision);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "governance_state", governance_state);

   if(final_blocked || final_decision == "INIT_PENDING" || governance_state == "STARTUP_INIT")
      return "STARTUP_BLOCKED";
   if((truth_ready || diagnostics_ready) && !(truth_ready && diagnostics_ready))
      return "STARTUP_PARTIAL";
   if(truth_ready && diagnostics_ready)
      return "STARTUP_OK";
   return "PENDING_RUNTIME_INIT";
}

bool DashboardPassesSeverityFilter(const DashboardCardModel &card, const string filter_name)
{
   if(filter_name == "ALL")
      return true;
   if(filter_name == "CAUTION_PLUS")
      return (DashboardSeverityRank(card.severity_class) >= DashboardSeverityRank(DASHBOARD_SEVERITY_CAUTION));
   if(filter_name == "WARNING_PLUS")
      return (DashboardSeverityRank(card.severity_class) >= DashboardSeverityRank(DASHBOARD_SEVERITY_WARNING));
   if(filter_name == "CRITICAL_ONLY")
      return (DashboardSeverityRank(card.severity_class) >= DashboardSeverityRank(DASHBOARD_SEVERITY_CRITICAL));
   return true;
}

bool DashboardPassesStateClassFilter(const DashboardCardModel &card, const string filter_name)
{
   if(filter_name == "ALL")
      return true;
   if(filter_name == "AUTHORITATIVE_ONLY")
      return (card.state_class == DASHBOARD_STATE_CLASS_AUTHORITATIVE);
   if(filter_name == "DERIVED_ONLY")
      return (card.state_class == DASHBOARD_STATE_CLASS_DERIVED);
   if(filter_name == "TRANSITIONAL_ONLY")
      return (card.state_class == DASHBOARD_STATE_CLASS_PLACEHOLDER_OR_TRANSITIONAL);
   return true;
}

bool DashboardPassesPanelFilter(const DashboardCardModel &card, const string filter_name)
{
   if(filter_name == "ALL")
      return true;
   if(filter_name == "PRIMARY_ONLY")
      return (card.rendering_priority <= 1);
   if(filter_name == "PRIMARY_SECONDARY")
      return (card.rendering_priority <= 2);
   return true;
}

void DashboardApplyCommonBadges(DashboardCardModel &card, const string source_ids_csv)
{
   card.authority_badge = DashboardAuthorityBadgeFromIds(source_ids_csv);
   card.source_badge = DashboardSourceBadgeFromIds(source_ids_csv);
   card.freshness_badge = DashboardFreshnessBadgeFromIds(source_ids_csv);
   card.state_badge = "State Class: " + DashboardStateClassText(card.state_class);
   card.placeholder_badge = DashboardPlaceholderBadgeFromIds(source_ids_csv);
}

void DashboardApplyDerivedSafetyState(DashboardCardModel &card, const string source_ids_csv)
{
   if(DashboardAnySourcePartial(source_ids_csv))
   {
      card.dominant_state_id = DashboardDominantState(card.dominant_state_id, "SOURCE_PARTIAL");
      card.state_class = DashboardStateClassForId(card.dominant_state_id);
      card.severity_class = DashboardStateSeverityForId(card.dominant_state_id);
   }

   if(DashboardAnySourceStale(source_ids_csv))
   {
      card.dominant_state_id = DashboardDominantState(card.dominant_state_id, "STALE_STATE");
      card.state_class = DashboardStateClassForId(card.dominant_state_id);
      card.severity_class = DashboardStateSeverityForId(card.dominant_state_id);
   }

   if(DashboardAnyZeroRecord(source_ids_csv))
   {
      card.dominant_state_id = DashboardDominantState(card.dominant_state_id, "ZERO_RECORD_STATE");
      card.state_class = DashboardStateClassForId(card.dominant_state_id);
      card.severity_class = DashboardStateSeverityForId(card.dominant_state_id);
   }

   if(DashboardAnySourceMixedPlane(source_ids_csv))
      card.mixed_plane_warning_required = true;
}

#endif
