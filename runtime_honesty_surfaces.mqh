#ifndef __RUNTIME_HONESTY_SURFACES_MQH__
#define __RUNTIME_HONESTY_SURFACES_MQH__

string RuntimeHonestyTruthArtifactPath() { return "AI\\runtime_honesty_truth.json"; }
string RuntimeHonestyOperatorInputTruthMapPath() { return "AI\\operator_input_truth_map.json"; }
string RuntimeHonestyThresholdOwnershipRegistryPath() { return "AI\\threshold_ownership_registry.json"; }
string RuntimeHonestyNotePath() { return "AI\\runtime_honesty_note.txt"; }
string RuntimeHonestyOperatorEffectiveConfigurationSurfacePath() { return "AI\\operator_effective_configuration_surface.json"; }
string RuntimeHonestyOperatorEffectiveConfigurationNotePath() { return "AI\\operator_effective_configuration_note.txt"; }
string RuntimeHonestyOperatorRuntimeTruthNotePath() { return "AI\\operator_runtime_truth_note.txt"; }

string RuntimeHonestyJsonBool(const bool value)
{
   return (value ? "true" : "false");
}

string RuntimeHonestyEscapeJson(const string value)
{
   string out = value;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\r", " ");
   StringReplace(out, "\n", " ");
   return out;
}

bool RuntimeHonestyWriteTextFileAll(const string relPath, const string text)
{
   int h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

bool RuntimeHonestyReadTextFileAll(const string relPath, string &text)
{
   text = "";
   int h = FileOpen(relPath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
      text += FileReadString(h);

   FileClose(h);
   return true;
}

string RuntimeHonestyRollbackStatePath();
string RuntimeHonestyRollbackThresholdOwnerWhenArmed();
string RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv();
string RuntimeHonestyRollbackArmingContractState();
string RuntimeHonestyRollbackLiveArmingEntrypointFunction();
string RuntimeHonestyRollbackLiveArmingEntrypointFile();
bool   RuntimeHonestyRollbackLiveArmingCallsitePresent();
bool   RuntimeHonestyRollbackAutoArmingPresent();
bool   RuntimeHonestyRollbackArmingBridgeImplemented();
string RuntimeHonestyRollbackArmingBridgeLocation();
bool   RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow();
string RuntimeHonestyRollbackCurrentRuntimeArmingPathState();
string RuntimeHonestyRollbackOperatorInputCurrentRole();

bool RuntimeHonestyRollbackMonitoringStateActive()
{
   string json = "";
   if(!RuntimeHonestyReadTextFileAll(RuntimeHonestyRollbackStatePath(), json))
      return false;

   string compact = json;
   StringReplace(compact, " ", "");
   StringReplace(compact, "\r", "");
   StringReplace(compact, "\n", "");
   StringReplace(compact, "\t", "");

   return (StringFind(compact, "\"monitoring_active\":true") >= 0);
}

string RuntimeHonestyRollbackStatePath() { return RollbackStatePath(); }
string RuntimeHonestyRollbackThresholdOwnerWhenArmed() { return RollbackThresholdOwnerWhenArmedPath(); }
string RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv() { return RollbackThresholdOwnerWhenArmedFieldsCsv(); }
string RuntimeHonestyRollbackArmingContractState() { return RollbackArmingContractState(); }
string RuntimeHonestyRollbackLiveArmingEntrypointFunction() { return "StartRollbackMonitoring"; }
string RuntimeHonestyRollbackLiveArmingEntrypointFile() { return "MQL5/Experts/AI/rollback_engine.mqh"; }
bool   RuntimeHonestyRollbackLiveArmingCallsitePresent() { return RollbackLiveArmingCallerPresent(); }
bool   RuntimeHonestyRollbackAutoArmingPresent() { return RollbackAutoArmingPresent(); }
bool   RuntimeHonestyRollbackArmingBridgeImplemented() { return RollbackArmingBridgeImplemented(); }
string RuntimeHonestyRollbackArmingBridgeLocation() { return RollbackArmingBridgeLocation(); }
bool   RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow() { return RollbackArmingBridgeReachableInCurrentRuntimeFlow(); }
string RuntimeHonestyRollbackCurrentRuntimeArmingPathState() { return RollbackCurrentRuntimeArmingPathState(); }
string RuntimeHonestyRollbackOperatorInputCurrentRole() { return "VISIBLE_NON_AUTHORITATIVE_NOT_ARMING_CURRENTLY"; }

string RuntimeHonestyCurrentAtasRolloutEffect(const bool atasEnabled, const int rolloutMode)
{
   if(!atasEnabled)
      return "DORMANT_FEATURE_BRANCH";

   if(rolloutMode <= 0)
      return "OBSERVATION_ONLY_DISPLAY";

   if(rolloutMode == 1)
      return "SOFT_INFLUENCE_NON_BLOCKING";

   return "HOLD_REEVALUATE_MAY_BLOCK_PROGRESS";
}

string RuntimeHonestyAtasRolloutClassification(const bool atasEnabled, const int rolloutMode)
{
   if(!atasEnabled)
      return "DORMANT_FEATURE_BRANCH";

   if(rolloutMode <= 0)
      return "OBSERVATION_ONLY_IN_CURRENT_CONFIGURATION";

   if(rolloutMode == 1)
      return "PARTIALLY_WIRED";

   return "WIRED_FOR_HOLD_ONLY";
}

string RuntimeHonestyPresentationTierVocabularyJson()
{
   return "[\"PRIMARY_EFFECTIVE\",\"SECONDARY_TRUTH\",\"TRANSITIONAL_LEGACY_PRESENT\",\"VISIBLE_NON_EFFECTIVE\",\"DORMANT_RUNTIME_BRANCH\",\"DISCONNECTED_SURFACE\"]";
}

string RuntimeHonestyCouncilThresholdOwnershipVocabularyJson()
{
   return "[\"ENFORCING\",\"POLICY_PRODUCING\",\"DESCRIPTIVE_OR_LEGACY_PRESERVED\",\"DORMANT_OPERATOR_SURFACE\"]";
}

string RuntimeHonestyCouncilThresholdOwnershipModelJson()
{
   return "{"
      "\"enforcing_owner\":\"RunCouncilPreAIFilter + final env.tradable/pre.passed branch\","
      "\"enforcing_runtime_files\":\"MQL5/Experts/AI/council_pre_ai_filter.mqh + MQL5/Experts/AI/council_mode_runtime.mqh\","
      "\"policy_producing_surfaces\":[\"council_ai_governor.mqh\"],"
      "\"descriptive_or_legacy_preserved_surfaces\":[\"council_pre_ai_gate.mqh\",\"council_governor.mqh\"],"
      "\"dormant_operator_threshold_groups\":[\"ACTIVATION_PRESSURE_GATE\",\"DIRTY_ENVIRONMENT_TIGHTENING\",\"EXECUTION_QUALITY_GATE\"]"
      "}";
}

string RuntimeHonestyLegacyTransitionalSurfacesJson()
{
   return "[{\"surface\":\"atas_runtime_context.json\",\"state\":\"TRANSITIONAL_LEGACY_PRESENT\",\"notice\":\"dashboard secondary fallback only when primary context absent; MT5 intake reads atas_microstructure_context.json exclusively; not yet retired\"},{\"surface\":\"atas_runtime_context_status.json\",\"state\":\"TRANSITIONAL_LEGACY_PRESENT\",\"notice\":\"advisory layer fallback when primary status absent; MT5 primary reads atas_microstructure_status.json; not yet retired\"}]";
}

string RuntimeHonestyPresentationTierFromClassification(const string classification,
                                                        const bool runtimeEffective)
{
   if(classification == "ACTIVE_ENFORCING" || classification == "ACTIVE_ADVISORY")
      return "PRIMARY_EFFECTIVE";

   if(classification == "PARTIALLY_WIRED" || classification == "WIRED_FOR_HOLD_ONLY" || classification == "OBSERVATION_ONLY_IN_CURRENT_CONFIGURATION")
      return (runtimeEffective ? "PRIMARY_EFFECTIVE" : "SECONDARY_TRUTH");

   if(classification == "LEGACY_PRESERVED")
      return "TRANSITIONAL_LEGACY_PRESENT";

   if(classification == "DORMANT_FEATURE_BRANCH")
      return "DORMANT_RUNTIME_BRANCH";

   if(classification == "DISCONNECTED_OPERATOR_SURFACE")
      return "DISCONNECTED_SURFACE";

   if(classification == "DOCUMENTATION_ONLY")
      return "VISIBLE_NON_EFFECTIVE";

   return (runtimeEffective ? "SECONDARY_TRUTH" : "VISIBLE_NON_EFFECTIVE");
}

string RuntimeHonestyThresholdPresentationTier(const string runtimeClass,
                                               const bool operatorSurfaceEffective)
{
   if(runtimeClass == "ENFORCING" && operatorSurfaceEffective)
      return "PRIMARY_EFFECTIVE";

   if(runtimeClass == "ADVISORY" || runtimeClass == "POLICY_PRODUCING")
      return "SECONDARY_TRUTH";

   if(runtimeClass == "ENFORCING" && !operatorSurfaceEffective)
      return "VISIBLE_NON_EFFECTIVE";

   if(runtimeClass == "DESCRIPTIVE_ONLY")
      return "VISIBLE_NON_EFFECTIVE";

   return (operatorSurfaceEffective ? "SECONDARY_TRUTH" : "VISIBLE_NON_EFFECTIVE");
}

void RuntimeHonestyLogWriteFailureOnce(const string relPath)
{
   static string logged = "|";
   string token = "|" + relPath + "|";
   if(StringFind(logged, token) >= 0)
      return;

   logged += relPath + "|";
   LogWarn("Runtime honesty: artifact write failed | path=" + relPath);
}

string RuntimeHonestyBuildInputGroupJson(const string groupId,
                                         const string classification,
                                         const string controllingFeatureFlag,
                                         const string defaultValue,
                                         const bool currentConfigActive,
                                         const bool runtimePathExists,
                                         const bool operatorSurfaceEffective,
                                         const string runtimeBehaviorNote,
                                         const string falseBeliefRisk)
{
   string json = "{";
   json += "\"group_id\":\"" + RuntimeHonestyEscapeJson(groupId) + "\"";
   json += ",\"classification\":\"" + RuntimeHonestyEscapeJson(classification) + "\"";
   json += ",\"controlling_feature_flag\":\"" + RuntimeHonestyEscapeJson(controllingFeatureFlag) + "\"";
   json += ",\"default_value\":\"" + RuntimeHonestyEscapeJson(defaultValue) + "\"";
   json += ",\"current_config_active\":" + RuntimeHonestyJsonBool(currentConfigActive);
   json += ",\"runtime_path_exists\":" + RuntimeHonestyJsonBool(runtimePathExists);
   json += ",\"operator_surface_effective\":" + RuntimeHonestyJsonBool(operatorSurfaceEffective);
   json += ",\"presentation_tier\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyPresentationTierFromClassification(classification, operatorSurfaceEffective)) + "\"";
   json += ",\"presentation_partition\":\"" + (operatorSurfaceEffective ? "effective_now" : "not_effective_now") + "\"";
   json += ",\"runtime_behavior_note\":\"" + RuntimeHonestyEscapeJson(runtimeBehaviorNote) + "\"";
   json += ",\"false_belief_risk\":\"" + RuntimeHonestyEscapeJson(falseBeliefRisk) + "\"";
   json += "}";
   return json;
}

string RuntimeHonestyBuildThresholdFamilyJson(const string familyName,
                                              const string governingPurpose,
                                              const string currentWinner,
                                              const string runtimeClass,
                                              const bool operatorSurfaceEffective,
                                              const string misunderstandingSeverity)
{
   string json = "{";
   json += "\"threshold_family\":\"" + RuntimeHonestyEscapeJson(familyName) + "\"";
   json += ",\"governing_purpose\":\"" + RuntimeHonestyEscapeJson(governingPurpose) + "\"";
   json += ",\"actual_current_winner\":\"" + RuntimeHonestyEscapeJson(currentWinner) + "\"";
   json += ",\"runtime_class\":\"" + RuntimeHonestyEscapeJson(runtimeClass) + "\"";
   json += ",\"operator_surface_effective\":" + RuntimeHonestyJsonBool(operatorSurfaceEffective);
   json += ",\"presentation_tier\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyThresholdPresentationTier(runtimeClass, operatorSurfaceEffective)) + "\"";
   json += ",\"misunderstanding_severity\":\"" + RuntimeHonestyEscapeJson(misunderstandingSeverity) + "\"";
   json += "}";
   return json;
}

void RuntimeHonestyAppendArrayItem(string &arr, bool &first, const string item)
{
   if(!first)
      arr += ",";
   arr += item;
   first = false;
}

string RuntimeHonestyBuildEffectiveControlJson(const string controlName,
                                               const string currentRole,
                                               const bool runtimeEffective,
                                               const string governingScope,
                                               const string classification,
                                               const string currentValue,
                                               const string notes)
{
   string json = "{";
   json += "\"control_name\":\"" + RuntimeHonestyEscapeJson(controlName) + "\"";
   json += ",\"current_role\":\"" + RuntimeHonestyEscapeJson(currentRole) + "\"";
   json += ",\"runtime_effective\":" + RuntimeHonestyJsonBool(runtimeEffective);
   json += ",\"governing_scope\":\"" + RuntimeHonestyEscapeJson(governingScope) + "\"";
   json += ",\"classification\":\"" + RuntimeHonestyEscapeJson(classification) + "\"";
   json += ",\"presentation_tier\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyPresentationTierFromClassification(classification, runtimeEffective)) + "\"";
   json += ",\"presentation_partition\":\"" + (runtimeEffective ? "effective_now" : "not_effective_now") + "\"";
   json += ",\"current_default_or_current_value\":\"" + RuntimeHonestyEscapeJson(currentValue) + "\"";
   json += ",\"notes\":\"" + RuntimeHonestyEscapeJson(notes) + "\"";
   json += "}";
   return json;
}

void RuntimeHonestyWriteTruthArtifactBestEffort(const string activePlanId,
                                                const string activeMode,
                                                const bool atasEnabled,
                                                const int atasRolloutMode)
{
   const bool rollbackArmingPathPresent = false; // Phase 1 proven current-source truth.
   const bool rollbackMonitoringStateActive = RuntimeHonestyRollbackMonitoringStateActive();
   string rollbackProtectionState = "DECLARED_BUT_INACTIVE";
   if(rollbackMonitoringStateActive)
      rollbackProtectionState = "POTENTIAL_PROTECTION";

   string json = "{";
   json += "\"schema_version\":\"RUNTIME_HONESTY_TRUTH_V1\"";
   json += ",\"artifact_role\":\"RUNTIME_TRUTH_ESTABLISHMENT\"";
   json += ",\"operator_surface_truth_version\":\"PHASE2_RUNTIME_HONESTY_V1\"";
   json += ",\"presentation_isolation_version\":\"PHASE4A_PRESENTATION_ISOLATION_V1\"";
   json += ",\"presentation_tier\":\"SECONDARY_TRUTH\"";
   json += ",\"presentation_tier_vocabulary\":" + RuntimeHonestyPresentationTierVocabularyJson();
   json += ",\"primary_effective_surface\":\"operator_effective_configuration_surface.json\"";
   json += ",\"secondary_truth_surfaces\":[\"runtime_honesty_truth.json\",\"operator_input_truth_map.json\",\"threshold_ownership_registry.json\",\"runtime_honesty_note.txt\"]";
   json += ",\"transitional_legacy_present_surfaces\":" + RuntimeHonestyLegacyTransitionalSurfacesJson();
   json += ",\"transitional_notice\":\"legacy ATAS context/status surfaces remain consumed for compatibility and are not safe to retire in this phase\"";
   json += ",\"proven_disconnected_modules\":[{\"module\":\"council_pre_ai_gate.mqh\",\"classification\":\"LEGACY_PRESERVED\",\"runtime_effective\":false,\"isolation_state\":\"DISCONNECTED_FROM_LIVE_ENFORCEMENT\"},{\"module\":\"council_governor.mqh\",\"classification\":\"LEGACY_PRESERVED\",\"runtime_effective\":false,\"isolation_state\":\"DISCONNECTED_FROM_LIVE_ENFORCEMENT\"}]";
   json += ",\"dormant_branch_containment_surface\":\"operator_input_truth_map.json\"";
   json += ",\"dormant_branch_groups_tracked\":[\"ACTIVATION_PRESSURE_GATE\",\"DIRTY_ENVIRONMENT_TIGHTENING\",\"EXECUTION_QUALITY_GATE\",\"LIVE_EXIT_ARCHITECTURE\",\"AI_CANDIDATE_BLOCK\",\"AI_ADVISORY_SECURITY_CLEARANCE\",\"COUNCIL_SETUP_LIFECYCLE\",\"TREND_CONTINUATION_REINFORCEMENT\",\"EMERGENCY_FLAT_CRITICAL_SAFETY\",\"INTERNAL_DASHBOARD_CHART_UI\",\"ROLLBACK_ENABLE_SWITCH\",\"ROLLBACK_THRESHOLD_INPUTS\"]";
   json += ",\"active_plan_id\":\"" + RuntimeHonestyEscapeJson(activePlanId) + "\"";
   json += ",\"active_mode\":\"" + RuntimeHonestyEscapeJson(activeMode) + "\"";
   json += ",\"live_council_enforcement_owner\":\"RunCouncilPreAIFilter + final env.tradable/pre.passed branch\"";
   json += ",\"live_council_enforcement_file\":\"MQL5/Experts/AI/council_pre_ai_filter.mqh + MQL5/Experts/AI/council_mode_runtime.mqh\"";
   json += ",\"council_threshold_ownership_vocabulary\":" + RuntimeHonestyCouncilThresholdOwnershipVocabularyJson();
   json += ",\"council_threshold_ownership_model\":" + RuntimeHonestyCouncilThresholdOwnershipModelJson();
   json += ",\"council_threshold_policy_producing_role\":\"council_ai_governor thresholds are post-filter policy-producing and not live pre-filter enforcement owners\"";
   json += ",\"council_threshold_legacy_surface_role\":\"council_pre_ai_gate.mqh and council_governor.mqh threshold surfaces are descriptive/legacy-preserved and not live enforcement owners\"";
   json += ",\"council_threshold_dormant_operator_surface_role\":\"activation/dirty/execution council threshold inputs are non-live when their feature switches are disabled\"";
   json += ",\"governor_runtime_role\":\"POST_FILTER_POLICY_AND_REPORTING\"";
   json += ",\"governor_enforcement_scope\":\"NOT_PRE_FILTER_ENFORCER_IN_ACTIVE_PATH\"";
   json += ",\"rollback_protection_state\":\"" + RuntimeHonestyEscapeJson(rollbackProtectionState) + "\"";
   json += ",\"rollback_arming_path_present\":" + RuntimeHonestyJsonBool(rollbackArmingPathPresent);
   json += ",\"rollback_state_file_monitoring_active\":" + RuntimeHonestyJsonBool(rollbackMonitoringStateActive);
   json += ",\"rollback_inputs_operator_surface_effective\":false";
   json += ",\"rollback_arming_contract_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingContractState()) + "\"";
   json += ",\"rollback_arming_bridge_implemented\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented());
   json += ",\"rollback_arming_bridge_location\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingBridgeLocation()) + "\"";
   json += ",\"rollback_arming_bridge_reachable_in_current_runtime_flow\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow());
   json += ",\"rollback_current_runtime_arming_path_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackCurrentRuntimeArmingPathState()) + "\"";
   json += ",\"rollback_state_file_path\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackStatePath()) + "\"";
   json += ",\"rollback_threshold_owner_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdOwnerWhenArmed()) + "\"";
   json += ",\"rollback_threshold_fields_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv()) + "\"";
   json += ",\"rollback_operator_input_current_role\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackOperatorInputCurrentRole()) + "\"";
   json += ",\"rollback_live_arming_entrypoint_function\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackLiveArmingEntrypointFunction()) + "\"";
   json += ",\"rollback_live_arming_entrypoint_file\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackLiveArmingEntrypointFile()) + "\"";
   json += ",\"rollback_live_arming_callsite_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent());
   json += ",\"rollback_auto_arming_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent());
   json += ",\"rollback_non_activation_guarantee\":true";
   json += ",\"rollback_activation_wave_state\":\"WAVE3_STRUCTURAL_READINESS_BRIDGE_ONLY\"";
   json += ",\"atas_rollout_mode_0_effect\":\"DISPLAY_ONLY_OBSERVATION\"";
   json += ",\"atas_rollout_mode_1_effect\":\"SOFT_INFLUENCE_NON_BLOCKING_FLAG\"";
   json += ",\"atas_rollout_mode_2_effect\":\"HOLD_REEVALUATE_MAY_STOP_CANDIDATE_PROGRESSION\"";
   json += ",\"atas_current_rollout_mode_input\":" + IntegerToString(atasRolloutMode);
   json += ",\"atas_current_rollout_effect\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyCurrentAtasRolloutEffect(atasEnabled, atasRolloutMode)) + "\"";
   json += ",\"evaluated_at\":\"" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\"";
   json += "}";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyTruthArtifactPath(), json))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyTruthArtifactPath());
}

void RuntimeHonestyWriteOperatorInputMapBestEffort(const bool enableCouncilActivationPressureGate,
                                                   const bool enableCouncilDirtyEnvironmentTightening,
                                                   const bool enableCouncilExecutionQualityGate,
                                                   const bool enableCouncilLiveExitArchitecture,
                                                   const bool enableAICandidateBlock,
                                                   const bool enableCouncilSetupLifecycle,
                                                   const bool enableCouncilTrendReinforcement,
                                                   const bool enableEmergencyFlatOnCriticalSafetyState,
                                                   const bool enableInternalDashboardChartUI,
                                                   const bool enableAutoRollback,
                                                   const bool enableATASGovernedAdvisory,
                                                   const int atasRolloutMode)
{
   string groups = "[";

   groups += RuntimeHonestyBuildInputGroupJson(
      "ACTIVATION_PRESSURE_GATE",
      (enableCouncilActivationPressureGate ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableCouncilActivationPressureGate",
      "false",
      enableCouncilActivationPressureGate,
      true,
      enableCouncilActivationPressureGate,
      "Post-router structural coverage filter for COUNCIL path; not the primary live pre-filter owner.",
      "Operator may assume these thresholds govern current live pass/fail while disabled; they do not unless this branch is enabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "DIRTY_ENVIRONMENT_TIGHTENING",
      (enableCouncilDirtyEnvironmentTightening ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableCouncilDirtyEnvironmentTightening",
      "false",
      enableCouncilDirtyEnvironmentTightening,
      true,
      enableCouncilDirtyEnvironmentTightening,
      "Post-router dirty/transitional discipline filter for COUNCIL path; not the primary live pre-filter owner.",
      "Operator may assume transitional threshold tightening governs live pass/fail while disabled; it does not unless enabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "EXECUTION_QUALITY_GATE",
      (enableCouncilExecutionQualityGate ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableCouncilExecutionQualityGate",
      "false",
      enableCouncilExecutionQualityGate,
      true,
      enableCouncilExecutionQualityGate,
      "Post-router timing/fill-quality guard before execution; not the primary live pre-filter owner.",
      "Operator may assume execution-quality thresholds govern current live council pass/fail while disabled; they do not unless enabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "LIVE_EXIT_ARCHITECTURE",
      (enableCouncilLiveExitArchitecture ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableCouncilLiveExitArchitecture",
      "false",
      enableCouncilLiveExitArchitecture,
      true,
      enableCouncilLiveExitArchitecture,
      "Open-position management architecture switch.",
      "Operator may assume advanced live exits are active while disabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "AI_CANDIDATE_BLOCK",
      (enableAICandidateBlock ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableAICandidateBlock",
      "false",
      enableAICandidateBlock,
      true,
      enableAICandidateBlock,
      "Council AI advisory strict block branch (not ATAS).",
      "Operator may assume AI strict blocking is active while disabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "AI_ADVISORY_SECURITY_CLEARANCE",
      (AIGateSecurityClearanceForAdvisory ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "AIGateSecurityClearanceForAdvisory",
      "false",
      AIGateSecurityClearanceForAdvisory,
      true,
      AIGateSecurityClearanceForAdvisory,
      "Final security gate in AI authority ladder: enables AI_ADVISORY_ONLY mode from AI_SHADOW_ONLY. Phase 6 reserved for activation.",
      "Operator may assume advisory mode is active while this clearance is false; advisory mode requires this gate plus all prior readiness conditions."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "ROLLBACK_ENABLE_SWITCH",
      (enableAutoRollback ? "DORMANT_FEATURE_BRANCH" : "DORMANT_FEATURE_BRANCH"),
      "EnableAutoRollback",
      "true",
      enableAutoRollback,
      true,
      false,
      "Rollback evaluation loop exists, but this switch does not arm monitoring and does not make thresholds authoritative by itself.",
      "Operator may assume rollback protection is armed by enable switch alone; actual arming still requires explicit StartRollbackMonitoring call path."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "ROLLBACK_THRESHOLD_INPUTS",
      "DISCONNECTED_OPERATOR_SURFACE",
      "RollbackMinTradesAfterApply/RollbackMinWinRate/RollbackMaxConsecutiveLosses/RollbackMinAvgProfitPerTrade",
      "6/35.0/3/-1.0",
      false,
      false,
      false,
      "Visible rollback threshold inputs are currently not consumed by active protection in this unarmed snapshot.",
      "Operator may tune these inputs expecting live rollback behavior changes; when armed, threshold authority is ai_rollback_state.json fields."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "ATAS_ROLLOUT_MODES",
      RuntimeHonestyAtasRolloutClassification(enableATASGovernedAdvisory, atasRolloutMode),
      "EnableATASGovernedAdvisory + ATASAdvisoryRolloutMode",
      "enabled=true, mode=0",
      enableATASGovernedAdvisory,
      true,
      enableATASGovernedAdvisory,
      "Mode0 display-only, mode1 soft/non-blocking, mode2 hold/reevaluate may stop progression.",
      "Operator may incorrectly treat mode1 as hard block or mode0 as unwired."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "COUNCIL_SETUP_LIFECYCLE",
      (enableCouncilSetupLifecycle ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableCouncilSetupLifecycle",
      "false",
      enableCouncilSetupLifecycle,
      true,
      enableCouncilSetupLifecycle,
      "Lifecycle arm/confirm gate in post-router COUNCIL execution path.",
      "Operator may assume setup lifecycle gating is active while disabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "TREND_CONTINUATION_REINFORCEMENT",
      (enableCouncilTrendReinforcement ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableCouncilTrendContinuationConfirmationReinforcement",
      "false",
      enableCouncilTrendReinforcement,
      true,
      enableCouncilTrendReinforcement,
      "Narrow pre-filter rescue branch for missing confirmation role.",
      "Operator may assume reinforcement can rescue entries while disabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "EMERGENCY_FLAT_CRITICAL_SAFETY",
      (enableEmergencyFlatOnCriticalSafetyState ? "ACTIVE_ENFORCING" : "DORMANT_FEATURE_BRANCH"),
      "EnableEmergencyFlatOnCriticalSafetyState",
      "false",
      enableEmergencyFlatOnCriticalSafetyState,
      true,
      enableEmergencyFlatOnCriticalSafetyState,
      "Emergency-flat protection branch in runtime risk/safety envelope.",
      "Operator may assume emergency flat protection is active while the branch is disabled."
   );
   groups += ",";

   groups += RuntimeHonestyBuildInputGroupJson(
      "INTERNAL_DASHBOARD_CHART_UI",
      "DISCONNECTED_OPERATOR_SURFACE",
      "EnableInternalDashboardChartUI",
      "false",
      enableInternalDashboardChartUI,
      true,
      false,
      "Chart UI rendering toggle only; does not change runtime decision authority or trade gating.",
      "Operator may assume chart-UI visibility toggles affect runtime decision behavior."
   );

   groups += "]";

   string json = "{";
   json += "\"schema_version\":\"OPERATOR_INPUT_TRUTH_MAP_V1\"";
   json += ",\"operator_surface_truth_version\":\"PHASE2_RUNTIME_HONESTY_V1\"";
   json += ",\"presentation_isolation_version\":\"PHASE4A_PRESENTATION_ISOLATION_V1\"";
   json += ",\"surface_visibility_role\":\"SECONDARY_TRUTH\"";
   json += ",\"primary_effective_surface\":\"operator_effective_configuration_surface.json\"";
   json += ",\"presentation_tier_vocabulary\":" + RuntimeHonestyPresentationTierVocabularyJson();
   json += ",\"transitional_legacy_present_surfaces\":" + RuntimeHonestyLegacyTransitionalSurfacesJson();
   json += ",\"council_threshold_ownership_vocabulary\":" + RuntimeHonestyCouncilThresholdOwnershipVocabularyJson();
   json += ",\"council_threshold_ownership_model\":" + RuntimeHonestyCouncilThresholdOwnershipModelJson();
   json += ",\"atas_current_rollout_mode_input\":" + IntegerToString(atasRolloutMode);
   json += ",\"atas_current_rollout_effect\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyCurrentAtasRolloutEffect(enableATASGovernedAdvisory, atasRolloutMode)) + "\"";
   json += ",\"rollback_contract\":{\"arming_contract_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingContractState()) + "\"";
   json += ",\"arming_bridge_implemented\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented());
   json += ",\"arming_bridge_location\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingBridgeLocation()) + "\"";
   json += ",\"arming_bridge_reachable_in_current_runtime_flow\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow());
   json += ",\"current_runtime_arming_path_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackCurrentRuntimeArmingPathState()) + "\"";
   json += ",\"state_file_path\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackStatePath()) + "\"";
   json += ",\"threshold_owner_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdOwnerWhenArmed()) + "\"";
   json += ",\"threshold_fields_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv()) + "\"";
   json += ",\"live_arming_entrypoint_function\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackLiveArmingEntrypointFunction()) + "\"";
   json += ",\"live_arming_entrypoint_file\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackLiveArmingEntrypointFile()) + "\"";
   json += ",\"live_arming_callsite_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent());
   json += ",\"auto_arming_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent());
   json += ",\"operator_input_current_role\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackOperatorInputCurrentRole()) + "\"";
   json += ",\"activation_in_this_wave\":false}";
   json += ",\"groups\":" + groups;
   json += ",\"evaluated_at\":\"" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\"";
   json += "}";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyOperatorInputTruthMapPath(), json))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyOperatorInputTruthMapPath());
}

void RuntimeHonestyWriteThresholdOwnershipRegistryBestEffort()
{
   string families = "[";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_PASS_FAIL",
      "Final council pass/fail prior to execution branch conversion.",
      "RunCouncilPreAIFilter + final env.tradable/pre.passed branch",
      "ENFORCING",
      true,
      "CRITICAL"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_CONSENSUS_CONFLICT",
      "Adaptive consensus/conflict quality gating for council candidacy.",
      "council_pre_ai_filter adaptive thresholds",
      "ENFORCING",
      true,
      "HIGH"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_ENVIRONMENT_QUALITY",
      "Environment tradability and environment score bounded eligibility.",
      "council_environment + council_pre_ai_filter",
      "ENFORCING",
      true,
      "HIGH"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_AI_GOVERNOR_POLICY_THRESHOLDS",
      "Post-filter council policy adaptation thresholds used for policy/reporting outputs.",
      "council_ai_governor threshold policies (post-filter, non-owning for live pass/fail)",
      "POLICY_PRODUCING",
      false,
      "HIGH"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_LEGACY_PRE_AI_GATE_THRESHOLD_SURFACE",
      "Legacy pre-AI gate threshold surface retained for lineage/reference.",
      "council_pre_ai_gate thresholds are descriptive/legacy-preserved in current active runtime path",
      "DESCRIPTIVE_ONLY",
      false,
      "CRITICAL"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_LEGACY_GOVERNOR_THRESHOLD_SURFACE",
      "Legacy council governor threshold surface retained for lineage/reference.",
      "council_governor thresholds are descriptive/legacy-preserved in current active runtime path",
      "DESCRIPTIVE_ONLY",
      false,
      "CRITICAL"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "COUNCIL_DORMANT_OPERATOR_THRESHOLD_INPUTS",
      "Visible council threshold input groups that are dormant when their feature branches are disabled.",
      "ActivationPressure/DirtyEnvironment/ExecutionQuality thresholds do not govern live pass/fail unless branch enabled",
      "DESCRIPTIVE_ONLY",
      false,
      "HIGH"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "RISK_STATE_LOCKDOWN",
      "Risk-state policy lockdown/tightening thresholds.",
      "risk_state_policy_engine thresholds (only when enabled)",
      "POLICY_PRODUCING",
      false,
      "MEDIUM"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "ROLLBACK_THRESHOLDS",
      "Rollback trigger thresholds are enforcing only when rollback monitoring is armed.",
      "Conditional winner: ai_rollback_state.json rollback thresholds when monitoring_active=true; current runtime snapshot is unarmed/inactive.",
      "ENFORCING",
      false,
      "CRITICAL"
   );
   families += ",";

   families += RuntimeHonestyBuildThresholdFamilyJson(
      "ATAS_FRESHNESS_RELEVANCE_CONFLUENCE",
      "ATAS shadow freshness and advisory evidence eligibility.",
      "ATAS_MAX_CONTEXT_AGE_SECONDS + ATASAdvisoryMinRelevanceScore + ATASAdvisoryMinConfluenceScore",
      "ADVISORY",
      true,
      "HIGH"
   );

   families += "]";

   string json = "{";
   json += "\"schema_version\":\"THRESHOLD_OWNERSHIP_REGISTRY_V1\"";
   json += ",\"operator_surface_truth_version\":\"PHASE2_RUNTIME_HONESTY_V1\"";
   json += ",\"presentation_isolation_version\":\"PHASE4A_PRESENTATION_ISOLATION_V1\"";
   json += ",\"surface_visibility_role\":\"SECONDARY_TRUTH\"";
   json += ",\"presentation_tier_vocabulary\":" + RuntimeHonestyPresentationTierVocabularyJson();
   json += ",\"primary_effective_surface\":\"operator_effective_configuration_surface.json\"";
   json += ",\"transitional_legacy_present_surfaces\":" + RuntimeHonestyLegacyTransitionalSurfacesJson();
   json += ",\"council_threshold_ownership_vocabulary\":" + RuntimeHonestyCouncilThresholdOwnershipVocabularyJson();
   json += ",\"council_threshold_ownership_model\":" + RuntimeHonestyCouncilThresholdOwnershipModelJson();
   json += ",\"rollback_family_contract\":{\"arming_contract_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingContractState()) + "\"";
   json += ",\"arming_bridge_implemented\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented());
   json += ",\"arming_bridge_location\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingBridgeLocation()) + "\"";
   json += ",\"arming_bridge_reachable_in_current_runtime_flow\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow());
   json += ",\"current_runtime_arming_path_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackCurrentRuntimeArmingPathState()) + "\"";
   json += ",\"state_file_path\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackStatePath()) + "\"";
   json += ",\"threshold_owner_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdOwnerWhenArmed()) + "\"";
   json += ",\"threshold_fields_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv()) + "\"";
   json += ",\"live_arming_callsite_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent());
   json += ",\"auto_arming_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent());
   json += ",\"active_now\":false}";
   json += ",\"families\":" + families;
   json += ",\"evaluated_at\":\"" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\"";
   json += "}";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyThresholdOwnershipRegistryPath(), json))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyThresholdOwnershipRegistryPath());
}

void RuntimeHonestyWriteNoteBestEffort(const bool enableATASGovernedAdvisory, const int atasRolloutMode)
{
   const bool rollbackMonitoringStateActive = RuntimeHonestyRollbackMonitoringStateActive();
   string rollbackState = (rollbackMonitoringStateActive ? "POTENTIAL_PROTECTION (externally armed state only)" : "DECLARED_BUT_INACTIVE");

   string text = "";
   text += "RUNTIME HONESTY NOTE (PHASE2_RUNTIME_HONESTY_V1)\n";
   text += "presentation_isolation_version=PHASE4A_PRESENTATION_ISOLATION_V1\n";
   text += "primary_effective_surface=operator_effective_configuration_surface.json\n";
   text += "secondary_truth_surfaces=runtime_honesty_truth.json,operator_input_truth_map.json,threshold_ownership_registry.json,runtime_honesty_note.txt\n";
   text += "transitional_legacy_present_surfaces=atas_runtime_context.json,atas_runtime_context_status.json\n";
   text += "transitional_notice=atas_runtime_context_status.json: advisory-layer fallback when primary status absent; atas_runtime_context.json: dashboard fallback when primary context absent; MT5 intake reads primary files exclusively; not yet retired\n";
   text += "visibility_tiers=PRIMARY_EFFECTIVE|SECONDARY_TRUTH|TRANSITIONAL_LEGACY_PRESENT|VISIBLE_NON_EFFECTIVE|DORMANT_RUNTIME_BRANCH|DISCONNECTED_SURFACE\n";
   text += "proven_disconnected_modules=council_pre_ai_gate.mqh,council_governor.mqh\n";
   text += "dormant_branch_containment_surface=operator_input_truth_map.json\n";
   text += "live_council_enforcement_owner=RunCouncilPreAIFilter + final env.tradable/pre.passed branch\n";
   text += "council_threshold_ownership_vocabulary=ENFORCING|POLICY_PRODUCING|DESCRIPTIVE_OR_LEGACY_PRESERVED|DORMANT_OPERATOR_SURFACE\n";
   text += "council_threshold_policy_producing_surface=council_ai_governor.mqh\n";
   text += "council_threshold_descriptive_legacy_surfaces=council_pre_ai_gate.mqh,council_governor.mqh\n";
   text += "council_threshold_dormant_operator_groups=ACTIVATION_PRESSURE_GATE,DIRTY_ENVIRONMENT_TIGHTENING,EXECUTION_QUALITY_GATE\n";
   text += "governor_runtime_role=POST_FILTER_POLICY_AND_REPORTING_ONLY\n";
   text += "rollback_protection_state=" + rollbackState + "\n";
   text += "rollback_arming_path_present_in_live_runtime=false\n";
   text += "rollback_arming_contract_state=" + RuntimeHonestyRollbackArmingContractState() + "\n";
   text += "rollback_arming_bridge_implemented=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented()) + "\n";
   text += "rollback_arming_bridge_location=" + RuntimeHonestyRollbackArmingBridgeLocation() + "\n";
   text += "rollback_arming_bridge_reachable_in_current_runtime_flow=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow()) + "\n";
   text += "rollback_current_runtime_arming_path_state=" + RuntimeHonestyRollbackCurrentRuntimeArmingPathState() + "\n";
   text += "rollback_state_file_path=" + RuntimeHonestyRollbackStatePath() + "\n";
   text += "rollback_threshold_owner_when_armed=" + RuntimeHonestyRollbackThresholdOwnerWhenArmed() + "\n";
   text += "rollback_threshold_fields_when_armed=" + RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv() + "\n";
   text += "rollback_live_arming_entrypoint_function=" + RuntimeHonestyRollbackLiveArmingEntrypointFunction() + "\n";
   text += "rollback_live_arming_entrypoint_file=" + RuntimeHonestyRollbackLiveArmingEntrypointFile() + "\n";
   text += "rollback_live_arming_callsite_present=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent()) + "\n";
   text += "rollback_auto_arming_present=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent()) + "\n";
   text += "rollback_operator_input_current_role=" + RuntimeHonestyRollbackOperatorInputCurrentRole() + "\n";
   text += "rollback_activation_in_this_wave=false\n";
   text += "rollback_wave3_structural_readiness=true\n";
   text += "atas_mode_0_effect=DISPLAY_ONLY_OBSERVATION\n";
   text += "atas_mode_1_effect=SOFT_INFLUENCE_NON_BLOCKING\n";
   text += "atas_mode_2_effect=HOLD_REEVALUATE_MAY_STOP_PROGRESSION\n";
   text += "atas_current_rollout_effect=" + RuntimeHonestyCurrentAtasRolloutEffect(enableATASGovernedAdvisory, atasRolloutMode) + "\n";
   text += "operator_note=dormant_or_disconnected_input_groups_exist; consult operator_input_truth_map.json\n";
   text += "evaluated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\n";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyNotePath(), text))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyNotePath());
}

void RHWriteOperatorEffectiveSurface(
   const string activeMode,
   const bool enableRuntimeExecution,
   const bool oneTradeAttemptPerBar,
   const bool enableRuntimeRiskSafetyHardening,
   const bool enableCouncilActivationPressureGate,
   const bool enableCouncilDirtyEnvironmentTightening,
   const bool enableCouncilExecutionQualityGate,
   const bool enableCouncilLiveExitArchitecture,
   const bool enableAICandidateBlock,
   const bool enableCouncilSetupLifecycle,
   const bool enableCouncilTrendReinforcement,
   const bool enableAutoRollback,
   const bool enableATASGovernedAdvisory,
   const int atasRolloutMode)
{
   string effectiveNow = "";
   bool firstEffective = true;
   string notEffectiveNow = "";
   bool firstNotEffective = true;

   RuntimeHonestyAppendArrayItem(
      effectiveNow,
      firstEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "LIVE_COUNCIL_ENFORCEMENT_PATH",
         "Primary live council pass/fail enforcement path.",
         true,
         "COUNCIL_RUNTIME_DECISION_PATH",
         "ACTIVE_ENFORCING",
         "RunCouncilPreAIFilter + final env.tradable/pre.passed",
         "Proven current runtime owner for council admission pass/fail."
      )
   );

   RuntimeHonestyAppendArrayItem(
      effectiveNow,
      firstEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "EnableRuntimeExecution",
         "Master runtime execution permission switch.",
         true,
         "RUNTIME_EXECUTION_ADMISSION",
         "ACTIVE_ENFORCING",
         (enableRuntimeExecution ? "true" : "false"),
         "Changing this control changes whether runtime can submit execution attempts."
      )
   );

   RuntimeHonestyAppendArrayItem(
      effectiveNow,
      firstEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "OneTradeAttemptPerBar",
         "Limits execution attempts per bar when runtime is execution-enabled.",
         true,
         "EXECUTION_THROTTLE_DISCIPLINE",
         "ACTIVE_ENFORCING",
         (oneTradeAttemptPerBar ? "true" : "false"),
         "This control changes attempt pacing behavior in live runtime."
      )
   );

   RuntimeHonestyAppendArrayItem(
      effectiveNow,
      firstEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "EnableRuntimeRiskSafetyHardening",
         "Activates runtime risk/safety hardening policy checks.",
         true,
         "RUNTIME_RISK_AND_SAFETY_ENVELOPE",
         "ACTIVE_ENFORCING",
         (enableRuntimeRiskSafetyHardening ? "true" : "false"),
         "This control changes protective runtime gating behavior."
      )
   );

   if(enableATASGovernedAdvisory)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableATASGovernedAdvisory",
            "Enables bounded external ATAS advisory integration.",
            true,
            "ATAS_GOVERNED_ADVISORY_LAYER",
            "ACTIVE_ADVISORY",
            "true",
            "ATAS remains non-authoritative; MT5 remains final authority owner."
         )
      );

      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "ATASAdvisoryRolloutMode",
            "Selects ATAS advisory runtime behavior profile.",
            true,
            "ATAS_GOVERNED_ADVISORY_LAYER",
            "ACTIVE_ADVISORY",
            IntegerToString(atasRolloutMode),
            "mode0=observation/display only; mode1=soft non-blocking; mode2=hold/reevaluate may stop progression."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableATASGovernedAdvisory",
            "ATAS advisory integration master switch.",
            false,
            "ATAS_GOVERNED_ADVISORY_LAYER",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "ATAS advisory path is disabled in current configuration."
         )
      );
   }

   if(enableCouncilActivationPressureGate)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilActivationPressureGate",
            "Activation pressure gate branch enable switch.",
            true,
            "COUNCIL_POST_ROUTER_GATING",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and its thresholds participate in post-router runtime gating; live pre-filter owner remains RunCouncilPreAIFilter."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilActivationPressureGate",
            "Activation pressure gate branch enable switch.",
            false,
            "COUNCIL_POST_ROUTER_GATING",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is structurally present but disabled; these thresholds are not current live council pass/fail owners."
         )
      );
   }

   if(enableCouncilDirtyEnvironmentTightening)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilDirtyEnvironmentTightening",
            "Dirty/transitional environment tightening branch switch.",
            true,
            "COUNCIL_POST_ROUTER_ENVIRONMENT_DISCIPLINE",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and currently participates in post-router gating; live pre-filter owner remains RunCouncilPreAIFilter."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilDirtyEnvironmentTightening",
            "Dirty/transitional environment tightening branch switch.",
            false,
            "COUNCIL_POST_ROUTER_ENVIRONMENT_DISCIPLINE",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is structurally present but disabled; these thresholds are not current live council pass/fail owners."
         )
      );
   }

   if(enableCouncilExecutionQualityGate)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilExecutionQualityGate",
            "Execution quality gate branch switch.",
            true,
            "COUNCIL_PRE_EXECUTION_QUALITY_GATE",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and currently affects pre-execution filtering; live pre-filter owner remains RunCouncilPreAIFilter."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilExecutionQualityGate",
            "Execution quality gate branch switch.",
            false,
            "COUNCIL_PRE_EXECUTION_QUALITY_GATE",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is present but disabled; these thresholds are not current live council pass/fail owners."
         )
      );
   }

   if(enableCouncilLiveExitArchitecture)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilLiveExitArchitecture",
            "Advanced live exit architecture branch switch.",
            true,
            "OPEN_POSITION_MANAGEMENT_POLICY",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and affects runtime exit management behavior."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilLiveExitArchitecture",
            "Advanced live exit architecture branch switch.",
            false,
            "OPEN_POSITION_MANAGEMENT_POLICY",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is present but disabled."
         )
      );
   }

   if(enableAICandidateBlock)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableAICandidateBlock",
            "Council AI candidate hard-block branch switch.",
            true,
            "COUNCIL_AI_ADVISORY_BLOCK_BRANCH",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and can hard-block candidates."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableAICandidateBlock",
            "Council AI candidate hard-block branch switch.",
            false,
            "COUNCIL_AI_ADVISORY_BLOCK_BRANCH",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is present but disabled."
         )
      );
   }

   if(enableCouncilSetupLifecycle)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilSetupLifecycle",
            "Council setup lifecycle gate branch switch.",
            true,
            "COUNCIL_SETUP_LIFECYCLE_BRANCH",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and can influence candidate progression."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilSetupLifecycle",
            "Council setup lifecycle gate branch switch.",
            false,
            "COUNCIL_SETUP_LIFECYCLE_BRANCH",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is present but disabled."
         )
      );
   }

   if(enableCouncilTrendReinforcement)
   {
      RuntimeHonestyAppendArrayItem(
         effectiveNow,
         firstEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilTrendContinuationConfirmationReinforcement",
            "Trend continuation reinforcement branch switch.",
            true,
            "COUNCIL_TREND_REINFORCEMENT_BRANCH",
            "ACTIVE_ENFORCING",
            "true",
            "Branch is enabled and can influence pre-filter rescue behavior."
         )
      );
   }
   else
   {
      RuntimeHonestyAppendArrayItem(
         notEffectiveNow,
         firstNotEffective,
         RuntimeHonestyBuildEffectiveControlJson(
            "EnableCouncilTrendContinuationConfirmationReinforcement",
            "Trend continuation reinforcement branch switch.",
            false,
            "COUNCIL_TREND_REINFORCEMENT_BRANCH",
            "DORMANT_FEATURE_BRANCH",
            "false",
            "Branch is present but disabled."
         )
      );
   }

   RuntimeHonestyAppendArrayItem(
      notEffectiveNow,
      firstNotEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "EnableAutoRollback",
         "Rollback monitoring enable switch.",
         false,
         "ROLLBACK_MONITORING_SURFACE",
         "DORMANT_FEATURE_BRANCH",
         (enableAutoRollback ? "true" : "false"),
         "Switch alone does not arm monitoring; approved arming bridge exists at plan-apply lifecycle but current runtime has no reachable caller."
      )
   );

   RuntimeHonestyAppendArrayItem(
      notEffectiveNow,
      firstNotEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "RollbackThresholdInputs",
         "Visible rollback threshold input family.",
         false,
         "ROLLBACK_THRESHOLD_SURFACE",
         "DISCONNECTED_OPERATOR_SURFACE",
         "RollbackMinTradesAfterApply/RollbackMinWinRate/RollbackMaxConsecutiveLosses/RollbackMinAvgProfitPerTrade",
         "Visible threshold inputs do not drive active protection in the current unarmed snapshot; armed threshold authority is ai_rollback_state.json."
      )
   );

   RuntimeHonestyAppendArrayItem(
      notEffectiveNow,
      firstNotEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "RollbackArmingContractBridge",
         "Explicit arming bridge requirement for rollback monitoring.",
         false,
         "ROLLBACK_ARMING_CONTRACT",
         "DISCONNECTED_OPERATOR_SURFACE",
         "entrypoint=AutoApplyPlanProposal->StartRollbackMonitoring; reachable_in_current_runtime=false",
         "Arming bridge is implemented at plan-apply lifecycle, but current runtime flow has no reachable caller; rollback remains intentionally unarmed."
      )
   );

   RuntimeHonestyAppendArrayItem(
      notEffectiveNow,
      firstNotEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "council_pre_ai_gate.mqh",
         "Legacy-preserved pre-AI threshold surface.",
         false,
         "LEGACY_REFERENCE_SURFACE",
         "LEGACY_PRESERVED",
         "present_in_source=true",
         "Descriptive/legacy-preserved threshold surface; not a live enforcement owner in the active council runtime path."
      )
   );

   RuntimeHonestyAppendArrayItem(
      notEffectiveNow,
      firstNotEffective,
      RuntimeHonestyBuildEffectiveControlJson(
         "council_governor.mqh",
         "Legacy-preserved governor threshold policy surface.",
         false,
         "LEGACY_REFERENCE_SURFACE",
         "LEGACY_PRESERVED",
         "present_in_source=true",
         "Descriptive/legacy-preserved threshold surface; not a live pre-filter enforcement owner in the active council runtime path."
      )
   );

   string json = "{";
   json += "\"schema_version\":\"OPERATOR_EFFECTIVE_CONFIGURATION_SURFACE_V1\"";
   json += ",\"artifact_role\":\"OPERATOR_EFFECTIVE_CONFIGURATION_TRUTH_SURFACE\"";
   json += ",\"operator_surface_truth_version\":\"PHASE3_OPERATOR_SURFACE_CLEANUP_V1\"";
   json += ",\"presentation_isolation_version\":\"PHASE4A_PRESENTATION_ISOLATION_V1\"";
   json += ",\"surface_visibility_role\":\"PRIMARY_EFFECTIVE\"";
   json += ",\"presentation_tier_vocabulary\":" + RuntimeHonestyPresentationTierVocabularyJson();
   json += ",\"council_threshold_ownership_vocabulary\":" + RuntimeHonestyCouncilThresholdOwnershipVocabularyJson();
   json += ",\"council_threshold_ownership_model\":" + RuntimeHonestyCouncilThresholdOwnershipModelJson();
   json += ",\"secondary_truth_surfaces\":[\"runtime_honesty_truth.json\",\"operator_input_truth_map.json\",\"threshold_ownership_registry.json\"]";
   json += ",\"transitional_legacy_present_surfaces\":" + RuntimeHonestyLegacyTransitionalSurfacesJson();
   json += ",\"rollback_contract\":{\"arming_contract_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingContractState()) + "\"";
   json += ",\"arming_bridge_implemented\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented());
   json += ",\"arming_bridge_location\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackArmingBridgeLocation()) + "\"";
   json += ",\"arming_bridge_reachable_in_current_runtime_flow\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow());
   json += ",\"current_runtime_arming_path_state\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackCurrentRuntimeArmingPathState()) + "\"";
   json += ",\"state_file_path\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackStatePath()) + "\"";
   json += ",\"threshold_owner_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdOwnerWhenArmed()) + "\"";
   json += ",\"threshold_fields_when_armed\":\"" + RuntimeHonestyEscapeJson(RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv()) + "\"";
   json += ",\"live_arming_callsite_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent());
   json += ",\"auto_arming_present\":" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent());
   json += ",\"activation_in_this_wave\":false}";
   json += ",\"active_mode\":\"" + RuntimeHonestyEscapeJson(activeMode) + "\"";
   json += ",\"classification_vocabulary\":[\"ACTIVE_ENFORCING\",\"ACTIVE_ADVISORY\",\"DORMANT_FEATURE_BRANCH\",\"DISCONNECTED_OPERATOR_SURFACE\",\"DOCUMENTATION_ONLY\",\"LEGACY_PRESERVED\"]";
   json += ",\"effective_now\":[" + effectiveNow + "]";
   json += ",\"not_effective_now\":[" + notEffectiveNow + "]";
   json += ",\"evaluated_at\":\"" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\"";
   json += "}";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyOperatorEffectiveConfigurationSurfacePath(), json))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyOperatorEffectiveConfigurationSurfacePath());
}

void RHWriteOperatorEffectiveNote(const bool enableATASGovernedAdvisory,
                                  const int atasRolloutMode)
{
   string text = "";
   text += "OPERATOR EFFECTIVE CONFIGURATION NOTE (PHASE3_OPERATOR_SURFACE_CLEANUP_V1)\n";
   text += "presentation_isolation_version=PHASE4A_PRESENTATION_ISOLATION_V1\n";
   text += "primary_visibility_tier=PRIMARY_EFFECTIVE\n";
   text += "secondary_visibility_tier=SECONDARY_TRUTH\n";
   text += "transitional_visibility_tier=TRANSITIONAL_LEGACY_PRESENT\n";
   text += "effective_surface_file=operator_effective_configuration_surface.json\n";
   text += "effective_now_focus=controls classified ACTIVE_ENFORCING or ACTIVE_ADVISORY\n";
   text += "not_effective_now_focus=controls classified DORMANT_FEATURE_BRANCH/DISCONNECTED_OPERATOR_SURFACE/DOCUMENTATION_ONLY/LEGACY_PRESERVED\n";
   text += "council_threshold_ownership_vocabulary=ENFORCING|POLICY_PRODUCING|DESCRIPTIVE_OR_LEGACY_PRESERVED|DORMANT_OPERATOR_SURFACE\n";
   text += "council_threshold_enforcing_owner=RunCouncilPreAIFilter + final env.tradable/pre.passed branch\n";
   text += "council_threshold_policy_producing_surface=council_ai_governor.mqh\n";
   text += "council_threshold_descriptive_legacy_surfaces=council_pre_ai_gate.mqh,council_governor.mqh\n";
   text += "council_threshold_dormant_operator_groups=ACTIVATION_PRESSURE_GATE,DIRTY_ENVIRONMENT_TIGHTENING,EXECUTION_QUALITY_GATE\n";
   text += "transitional_legacy_notice=atas_runtime_context_status.json: advisory-layer fallback when primary status absent; atas_runtime_context.json: dashboard fallback when primary context absent; not yet retired\n";
   text += "disconnected_legacy_modules=council_pre_ai_gate.mqh,council_governor.mqh retained as legacy-preserved reference surfaces\n";
   text += "rollback_truth=declared_but_inactive_unless_separately_armed\n";
   text += "rollback_arming_contract_state=" + RuntimeHonestyRollbackArmingContractState() + "\n";
   text += "rollback_arming_bridge_implemented=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented()) + "\n";
   text += "rollback_arming_bridge_location=" + RuntimeHonestyRollbackArmingBridgeLocation() + "\n";
   text += "rollback_arming_bridge_reachable_in_current_runtime_flow=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow()) + "\n";
   text += "rollback_current_runtime_arming_path_state=" + RuntimeHonestyRollbackCurrentRuntimeArmingPathState() + "\n";
   text += "rollback_state_file_path=" + RuntimeHonestyRollbackStatePath() + "\n";
   text += "rollback_threshold_owner_when_armed=" + RuntimeHonestyRollbackThresholdOwnerWhenArmed() + "\n";
   text += "rollback_threshold_fields_when_armed=" + RuntimeHonestyRollbackThresholdFieldsWhenArmedCsv() + "\n";
   text += "rollback_live_arming_callsite_present=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent()) + "\n";
   text += "rollback_auto_arming_present=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent()) + "\n";
   text += "rollback_activation_in_this_wave=false\n";
   text += "atas_rollout_mode_current=" + IntegerToString(atasRolloutMode) + "\n";
   text += "atas_rollout_enabled=" + (enableATASGovernedAdvisory ? "true" : "false") + "\n";
   text += "atas_rollout_effect=" + RuntimeHonestyCurrentAtasRolloutEffect(enableATASGovernedAdvisory, atasRolloutMode) + "\n";
   text += "evaluated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\n";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyOperatorEffectiveConfigurationNotePath(), text))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyOperatorEffectiveConfigurationNotePath());
}

void RHWriteOperatorRuntimeTruthNote(const bool enableATASGovernedAdvisory,
                                     const int atasRolloutMode)
{
   string text = "";
   text += "OPERATOR RUNTIME TRUTH NOTE (PHASE3_OPERATOR_SURFACE_CLEANUP_V1)\n";
   text += "presentation_isolation_version=PHASE4A_PRESENTATION_ISOLATION_V1\n";
   text += "primary_surface=operator_effective_configuration_surface.json\n";
   text += "secondary_truth_surfaces=runtime_honesty_truth.json,operator_input_truth_map.json,threshold_ownership_registry.json\n";
   text += "council_threshold_ownership_vocabulary=ENFORCING|POLICY_PRODUCING|DESCRIPTIVE_OR_LEGACY_PRESERVED|DORMANT_OPERATOR_SURFACE\n";
   text += "council_threshold_enforcing_owner=RunCouncilPreAIFilter + final env.tradable/pre.passed branch\n";
   text += "council_threshold_policy_producing_surface=council_ai_governor.mqh\n";
   text += "council_threshold_descriptive_legacy_surfaces=council_pre_ai_gate.mqh,council_governor.mqh\n";
   text += "council_threshold_dormant_operator_groups=ACTIVATION_PRESSURE_GATE,DIRTY_ENVIRONMENT_TIGHTENING,EXECUTION_QUALITY_GATE\n";
   text += "transitional_legacy_present_surfaces=atas_runtime_context.json (dashboard fallback only),atas_runtime_context_status.json (advisory-layer fallback only); not safe to retire\n";
   text += "disconnected_legacy_modules=council_pre_ai_gate.mqh,council_governor.mqh (not live enforcement owners)\n";
   text += "rollback_arming_contract_state=" + RuntimeHonestyRollbackArmingContractState() + "\n";
   text += "rollback_arming_bridge_implemented=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeImplemented()) + "\n";
   text += "rollback_arming_bridge_location=" + RuntimeHonestyRollbackArmingBridgeLocation() + "\n";
   text += "rollback_arming_bridge_reachable_in_current_runtime_flow=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackArmingBridgeReachableInCurrentRuntimeFlow()) + "\n";
   text += "rollback_current_runtime_arming_path_state=" + RuntimeHonestyRollbackCurrentRuntimeArmingPathState() + "\n";
   text += "rollback_state_file_path=" + RuntimeHonestyRollbackStatePath() + "\n";
   text += "rollback_threshold_owner_when_armed=" + RuntimeHonestyRollbackThresholdOwnerWhenArmed() + "\n";
   text += "rollback_live_arming_entrypoint_function=" + RuntimeHonestyRollbackLiveArmingEntrypointFunction() + "\n";
   text += "rollback_live_arming_callsite_present=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackLiveArmingCallsitePresent()) + "\n";
   text += "rollback_auto_arming_present=" + RuntimeHonestyJsonBool(RuntimeHonestyRollbackAutoArmingPresent()) + "\n";
   text += "rollback_activation_in_this_wave=false\n";
   text += "1) live_runtime_governs=RunCouncilPreAIFilter + final env.tradable/pre.passed branch\n";
   text += "2) effective_controls=ACTIVE_ENFORCING and ACTIVE_ADVISORY controls in operator_effective_configuration_surface.json\n";
   text += "3) visible_non_effective_controls=DORMANT_FEATURE_BRANCH and DISCONNECTED_OPERATOR_SURFACE controls do not change current runtime behavior\n";
   text += "4) declared_inactive_safety=rollback protection is declared but inactive unless monitoring is separately armed\n";
   text += "5) atas_practical_influence=mode0 observation/display only; mode1 soft non-blocking; mode2 hold/reevaluate may stop candidate progression\n";
   text += "6) council_threshold_ownership=ENFORCING RunCouncilPreAIFilter/final branch | POLICY_PRODUCING council_ai_governor | DESCRIPTIVE_LEGACY council_pre_ai_gate/council_governor | DORMANT_OPERATOR_SURFACE activation/dirty/execution groups when disabled\n";
   text += "atas_rollout_enabled=" + (enableATASGovernedAdvisory ? "true" : "false") + "\n";
   text += "atas_rollout_mode_current=" + IntegerToString(atasRolloutMode) + "\n";
   text += "atas_rollout_effect_current=" + RuntimeHonestyCurrentAtasRolloutEffect(enableATASGovernedAdvisory, atasRolloutMode) + "\n";
   text += "evaluated_at=" + TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES | TIME_SECONDS) + "\n";

   if(!RuntimeHonestyWriteTextFileAll(RuntimeHonestyOperatorRuntimeTruthNotePath(), text))
      RuntimeHonestyLogWriteFailureOnce(RuntimeHonestyOperatorRuntimeTruthNotePath());
}

void RuntimeHonestyEmitSurfacesBestEffort(const string activePlanId,
                                          const string activeMode,
                                          const bool enableRuntimeExecution,
                                          const bool oneTradeAttemptPerBar,
                                          const bool enableRuntimeRiskSafetyHardening,
                                          const bool enableCouncilActivationPressureGate,
                                          const bool enableCouncilDirtyEnvironmentTightening,
                                          const bool enableCouncilExecutionQualityGate,
                                          const bool enableCouncilLiveExitArchitecture,
                                          const bool enableAICandidateBlock,
                                          const bool enableCouncilSetupLifecycle,
                                          const bool enableCouncilTrendReinforcement,
                                          const bool enableEmergencyFlatOnCriticalSafetyState,
                                          const bool enableInternalDashboardChartUI,
                                          const bool enableAutoRollback,
                                          const bool enableATASGovernedAdvisory,
                                          const int atasRolloutMode)
{
   RuntimeHonestyWriteTruthArtifactBestEffort(activePlanId, activeMode, enableATASGovernedAdvisory, atasRolloutMode);
   RuntimeHonestyWriteOperatorInputMapBestEffort(
      enableCouncilActivationPressureGate,
      enableCouncilDirtyEnvironmentTightening,
      enableCouncilExecutionQualityGate,
      enableCouncilLiveExitArchitecture,
      enableAICandidateBlock,
      enableCouncilSetupLifecycle,
      enableCouncilTrendReinforcement,
      enableEmergencyFlatOnCriticalSafetyState,
      enableInternalDashboardChartUI,
      enableAutoRollback,
      enableATASGovernedAdvisory,
      atasRolloutMode
   );
   RuntimeHonestyWriteThresholdOwnershipRegistryBestEffort();
   RuntimeHonestyWriteNoteBestEffort(enableATASGovernedAdvisory, atasRolloutMode);
   RHWriteOperatorEffectiveSurface(
      activeMode,
      enableRuntimeExecution,
      oneTradeAttemptPerBar,
      enableRuntimeRiskSafetyHardening,
      enableCouncilActivationPressureGate,
      enableCouncilDirtyEnvironmentTightening,
      enableCouncilExecutionQualityGate,
      enableCouncilLiveExitArchitecture,
      enableAICandidateBlock,
      enableCouncilSetupLifecycle,
      enableCouncilTrendReinforcement,
      enableAutoRollback,
      enableATASGovernedAdvisory,
      atasRolloutMode
   );
   RHWriteOperatorEffectiveNote(enableATASGovernedAdvisory, atasRolloutMode);
   RHWriteOperatorRuntimeTruthNote(enableATASGovernedAdvisory, atasRolloutMode);
}

void RuntimeHonestyLogStartupWarningsOnce(const bool enableCouncilActivationPressureGate,
                                          const bool enableCouncilDirtyEnvironmentTightening,
                                          const bool enableCouncilExecutionQualityGate,
                                          const bool enableCouncilLiveExitArchitecture,
                                          const bool enableAICandidateBlock,
                                          const bool enableEmergencyFlatOnCriticalSafetyState,
                                          const bool enableInternalDashboardChartUI,
                                          const bool enableAutoRollback,
                                          const bool enableATASGovernedAdvisory,
                                          const int atasRolloutMode)
{
   static bool alreadyLogged = false;
   if(alreadyLogged)
      return;

   alreadyLogged = true;

   LogWarn("Runtime honesty: live council enforcement owner is RunCouncilPreAIFilter + final env.tradable/pre.passed branch; governor is post-filter policy/reporting.");
   LogWarn("Runtime honesty: council threshold ownership split -> ENFORCING=RunCouncilPreAIFilter/final branch, POLICY_PRODUCING=council_ai_governor, DESCRIPTIVE_LEGACY=council_pre_ai_gate+council_governor, DORMANT_OPERATOR_SURFACE=activation/dirty/execution thresholds when disabled.");
   LogWarn("Runtime honesty: rollback bridge is implemented at AutoApplyPlanProposal lifecycle, but current runtime has no reachable live caller; rollback remains intentionally unarmed until that approved lifecycle is reached.");
   LogWarn("Runtime honesty: ATAS rollout semantics -> mode0=display-only, mode1=soft/non-blocking, mode2=hold/reevaluate may stop progression when hold is applied.");

   int dormantGroups = 0;
   if(!enableCouncilActivationPressureGate) dormantGroups++;
   if(!enableCouncilDirtyEnvironmentTightening) dormantGroups++;
   if(!enableCouncilExecutionQualityGate) dormantGroups++;
   if(!enableCouncilLiveExitArchitecture) dormantGroups++;
   if(!enableAICandidateBlock) dormantGroups++;
   if(!enableEmergencyFlatOnCriticalSafetyState) dormantGroups++;
   if(!enableInternalDashboardChartUI) dormantGroups++;
   if(enableAutoRollback) dormantGroups++; // enabled switch but inactive until armed.

   string atasModeNow = RuntimeHonestyCurrentAtasRolloutEffect(enableATASGovernedAdvisory, atasRolloutMode);
   LogWarn("Runtime honesty: dormant/disconnected operator surfaces detected | dormant_or_disconnected_groups=" + IntegerToString(dormantGroups) + " | atas_current_effect=" + atasModeNow + ".");
}

#endif
