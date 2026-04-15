#ifndef __DASHBOARD_SOURCE_REGISTRY_MQH__
#define __DASHBOARD_SOURCE_REGISTRY_MQH__

#include "dashboard_contract.mqh"

int DashboardBuildSourceRegistry(DashboardSourceDefinition &defs[])
{
   ArrayResize(defs, 30);
   int i = 0;

   defs[i].source_id = "SRC_RUNTIME_GOVERNANCE_STATUS";
   defs[i].display_path = "MQL5/Files/AI/runtime_governance_status.json";
   defs[i].runtime_path = "AI\\runtime_governance_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "AUTHORITATIVE_RUNTIME_GOVERNANCE_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Primary runtime freeze and trading posture source.";
   i++;

   defs[i].source_id = "SRC_AI_ACTIVATION_READINESS";
   defs[i].display_path = "MQL5/Files/AI/ai_activation_readiness_status.json";
   defs[i].runtime_path = "AI\\ai_activation_readiness_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_DERIVED_AI_GOVERNANCE";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Primary AI authority and readiness posture source.";
   i++;

   defs[i].source_id = "SRC_EXPORT_RELEASE_GATE_STATUS";
   defs[i].display_path = "MQL5/Files/AI/export_release_gate_status.json";
   defs[i].runtime_path = "AI\\export_release_gate_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_RELEASE_GATE_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Primary export blocked posture source.";
   i++;

   defs[i].source_id = "SRC_TRANSFER_PACKAGE5_STATUS";
   defs[i].display_path = "MQL5/Files/AI/strategy_transfer_package5_status.json";
   defs[i].runtime_path = "AI\\strategy_transfer_package5_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "PACKAGE_LEVEL_TRANSFER_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Primary package 5 transfer posture source.";
   i++;

   defs[i].source_id = "SRC_TRANSFER_PACKAGE5_PILOT_CYCLE";
   defs[i].display_path = "MQL5/Files/AI/strategy_transfer_package5_pilot_cycle.json";
   defs[i].runtime_path = "AI\\strategy_transfer_package5_pilot_cycle.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "PACKAGE_LEVEL_TRANSFER_PILOT_CYCLE";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Primary pilot-cycle definition source.";
   i++;

   defs[i].source_id = "SRC_TRANSFER_PACKAGEC_STATUS";
   defs[i].display_path = "MQL5/Files/AI/strategy_transfer_packageC_status.json";
   defs[i].runtime_path = "AI\\strategy_transfer_packageC_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_RUNTIME_STATUS_VISIBILITY";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Primary package C truth reconciliation source.";
   i++;

   defs[i].source_id = "SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE";
   defs[i].display_path = "MQL5/Files/AI/strategy_transfer_packageC_pilot_evidence_design.json";
   defs[i].runtime_path = "AI\\strategy_transfer_packageC_pilot_evidence_design.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_RUNTIME_GOVERNANCE_DESIGN";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_PAGE_ENTRY_ONLY;
   defs[i].bounded_usage_note = "Primary pilot evidence design summary source.";
   i++;

   defs[i].source_id = "SRC_DIAGNOSTIC_RUNTIME_SUMMARY";
   defs[i].display_path = "MQL5/Files/AI/diagnostic_runtime_summary.json";
   defs[i].runtime_path = "AI\\diagnostic_runtime_summary.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_DERIVED_DIAGNOSTIC";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Primary startup and diagnostic summary source.";
   i++;

   defs[i].source_id = "SRC_FACTORY_INTAKE_STATUS";
   defs[i].display_path = "MQL5/Files/AI/edge_factory/registry/factory_intake_status.json";
   defs[i].runtime_path = "AI\\edge_factory\\registry\\factory_intake_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "AUTHORITATIVE_EDGE_FACTORY_INTAKE_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Primary factory intake posture source.";
   i++;

   defs[i].source_id = "SRC_SOURCE_INTAKE_GATEWAY_STATUS";
   defs[i].display_path = "MQL5/Files/AI/edge_factory/registry/source_intake_gateway_status.json";
   defs[i].runtime_path = "AI\\edge_factory\\registry\\source_intake_gateway_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_GATEWAY_DETECTION_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Primary zero-record gateway posture source.";
   i++;

   defs[i].source_id = "SRC_EDGE_FACTORY_DECOMPOSITION_STATUS";
   defs[i].display_path = "MQL5/Files/AI/edge_factory/decomposition/decomposition_status.json";
   defs[i].runtime_path = "AI\\edge_factory\\decomposition\\decomposition_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS;
   defs[i].authority_type = "AUTHORITATIVE_EDGE_FACTORY_DECOMPOSITION_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Structural factory decomposition detail.";
   i++;

   defs[i].source_id = "SRC_EDGE_FACTORY_MANIFEST";
   defs[i].display_path = "MQL5/Files/AI/edge_factory/edge_factory_manifest.json";
   defs[i].runtime_path = "AI\\edge_factory\\edge_factory_manifest.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS;
   defs[i].authority_type = "AUTHORITATIVE_EDGE_FACTORY_INTAKE_INDEX_WITH_MIXED_PLANE_SUMMARY_FIELDS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Summary-only mixed-plane manifest.";
   i++;

   defs[i].source_id = "SRC_EDGE_FACTORY_INTERNAL_INTELLIGENCE_STATUS";
   defs[i].display_path = "MQL5/Files/AI/edge_factory/internal_intelligence/internal_factory_intelligence_status.json";
   defs[i].runtime_path = "AI\\edge_factory\\internal_intelligence\\internal_factory_intelligence_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS;
   defs[i].authority_type = "NON_AUTHORITATIVE_INTERNAL_ANALYTICAL_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Internal intelligence structural support status.";
   i++;

   defs[i].source_id = "SRC_DASHBOARD_PHASE0_STATUS";
   defs[i].display_path = "MQL5/Files/AI/dashboard_phase0_status.json";
   defs[i].runtime_path = "AI\\dashboard_phase0_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS;
   defs[i].authority_type = "NON_RUNTIME_DASHBOARD_PHASE0_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_BOOT_ONLY;
   defs[i].bounded_usage_note = "Phase 0 design lock status surface.";
   i++;

   defs[i].source_id = "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS";
   defs[i].display_path = "MQL5/Files/AI/strategy_transfer_runtime_freeze_status.json";
   defs[i].runtime_path = "AI\\strategy_transfer_runtime_freeze_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS;
   defs[i].authority_type = "NON_AUTHORITATIVE_PACKAGE_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Historical runtime-freeze provenance.";
   i++;

   defs[i].source_id = "SRC_DOC_EXPORT_RELEASE_GATE_CONTRACT";
   defs[i].display_path = "MQL5/Experts/AI/docs/export_release_gate_contract.txt";
   defs[i].runtime_path = "";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "CONTRACT_CONTEXT";
   defs[i].direct_render_allowed = false;
   defs[i].refresh_class = DASHBOARD_REFRESH_BOOT_ONLY;
   defs[i].bounded_usage_note = "Embedded Phase 0 contract context only.";
   i++;

   defs[i].source_id = "SRC_DOC_PILOT_EVIDENCE_DESIGN_CONTRACT";
   defs[i].display_path = "MQL5/Experts/AI/docs/strategy_transfer_pilot_evidence_design_contract.txt";
   defs[i].runtime_path = "";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "CONTRACT_CONTEXT";
   defs[i].direct_render_allowed = false;
   defs[i].refresh_class = DASHBOARD_REFRESH_BOOT_ONLY;
   defs[i].bounded_usage_note = "Embedded Phase 0 contract context only.";
   i++;

   defs[i].source_id = "SRC_DOC_SECRET_HYGIENE_REMEDIATION";
   defs[i].display_path = "MQL5/Experts/AI/docs/security_containment_secret_hygiene_remediation.txt";
   defs[i].runtime_path = "";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "CONTRACT_CONTEXT";
   defs[i].direct_render_allowed = false;
   defs[i].refresh_class = DASHBOARD_REFRESH_BOOT_ONLY;
   defs[i].bounded_usage_note = "Embedded Phase 0 contract context only.";
   i++;

   defs[i].source_id = "SRC_DOC_FACTORY_TRUTH_VOCABULARY_CONTRACT";
   defs[i].display_path = "MQL5/Experts/AI/docs/factory_truth_vocabulary_contract.txt";
   defs[i].runtime_path = "";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "CONTRACT_CONTEXT";
   defs[i].direct_render_allowed = false;
   defs[i].refresh_class = DASHBOARD_REFRESH_BOOT_ONLY;
   defs[i].bounded_usage_note = "Embedded vocabulary context only.";
   i++;


   defs[i].source_id = "SRC_EXECUTION_QUALITY_VALIDATION";
   defs[i].display_path = "MQL5/Files/AI/execution_quality_validation.json";
   defs[i].runtime_path = "AI\\execution_quality_validation.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "INTERNAL_DERIVED_EXECUTION_QUALITY_VALIDATION";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Internal derived execution-quality summary for bounded operational visibility only.";
   i++;

   defs[i].source_id = "SRC_AI_TRADE_FEEDBACK";
   defs[i].display_path = "MQL5/Files/AI/ai_trade_feedback.json";
   defs[i].runtime_path = "AI\\ai_trade_feedback.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "INTERNAL_LATEST_TRADE_FEEDBACK";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Latest closed-trade feedback for internal operational visibility only.";
   i++;

   defs[i].source_id = "SRC_TRADE_JOURNAL_SUMMARY";
   defs[i].display_path = "MQL5/Files/AI/ai_performance_journal.jsonl";
   defs[i].runtime_path = "AI\\ai_performance_journal.jsonl";
   defs[i].tier = DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL;
   defs[i].authority_type = "INTERNAL_DERIVED_TRADE_JOURNAL_SUMMARY";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Bounded internal close-record summary derived from the append-only journal.";
   i++;

   defs[i].source_id = "SRC_OPERATIONAL_INTEGRITY_STATUS";
   defs[i].display_path = "MQL5/Files/AI/operational_integrity_status.json";
   defs[i].runtime_path = "AI\\operational_integrity_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS;
   defs[i].authority_type = "NON_AUTHORITATIVE_RUNTIME_COHERENCE_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Bounded operational coherence summary across critical runtime domains.";
   i++;

   defs[i].source_id = "SRC_EXECUTION_AUTHORITY_STATUS";
   defs[i].display_path = "MQL5/Files/AI/execution_authority_status.json";
   defs[i].runtime_path = "AI\\execution_authority_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "RUNTIME_EXECUTION_AUTHORITY_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Current execution authority cutover and attribution summary.";
   i++;

   defs[i].source_id = "SRC_ACTIVE_OPERATING_COHORT";
   defs[i].display_path = "MQL5/Files/AI/active_operating_cohort.json";
   defs[i].runtime_path = "AI\\active_operating_cohort.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "RUNTIME_OPERATING_COHORT_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_SLOW_POLL;
   defs[i].bounded_usage_note = "Current admitted operating cohort summary.";
   i++;

   defs[i].source_id = "SRC_OPERATING_RISK_ENVELOPE_STATUS";
   defs[i].display_path = "MQL5/Files/AI/operating_risk_envelope_status.json";
   defs[i].runtime_path = "AI\\operating_risk_envelope_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "RUNTIME_OPERATING_RISK_ENVELOPE_STATUS";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Current operating envelope limits, dominant guardrail, and bounded block reason.";
   i++;


   defs[i].source_id = "SRC_LAST_MEANINGFUL_RUNTIME_EVENT";
   defs[i].display_path = "MQL5/Files/AI/last_meaningful_runtime_event.json";
   defs[i].runtime_path = "AI\\last_meaningful_runtime_event.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_RUNTIME_EVENT_SUMMARY";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Latest materially important runtime event in bounded operational form.";
   i++;

   defs[i].source_id = "SRC_FACTORY_OPERATIONAL_EVIDENCE";
   defs[i].display_path = "MQL5/Files/AI/factory_operational_evidence_status.json";
   defs[i].runtime_path = "AI\\factory_operational_evidence_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_FACTORY_EVIDENCE_SUMMARY";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "Bounded live operational evidence summary for factory-facing review.";
   i++;

   defs[i].source_id = "SRC_AI_OPERATIONAL_REVIEW";
   defs[i].display_path = "MQL5/Files/AI/ai_operational_review_status.json";
   defs[i].runtime_path = "AI\\ai_operational_review_status.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY;
   defs[i].authority_type = "NON_AUTHORITATIVE_AI_OPERATIONAL_REVIEW";
   defs[i].direct_render_allowed = true;
   defs[i].refresh_class = DASHBOARD_REFRESH_NORMAL_POLL;
   defs[i].bounded_usage_note = "AI shadow/advisory operational interpretation surface only.";
   i++;

   defs[i].source_id = "SRC_MATERIAL_REGISTRY_RAW";
   defs[i].display_path = "MQL5/Files/AI/edge_factory/registry/material_registry.json";
   defs[i].runtime_path = "AI\\edge_factory\\registry\\material_registry.json";
   defs[i].tier = DASHBOARD_SOURCE_TIER_D_NEVER_RENDER_DIRECTLY;
   defs[i].authority_type = "RAW_FACTORY_REGISTRY";
   defs[i].direct_render_allowed = false;
   defs[i].refresh_class = DASHBOARD_REFRESH_ON_DEMAND;
   defs[i].bounded_usage_note = "Large raw registry; excluded from render path.";
   i++;

   ArrayResize(defs, i);
   return i;
}

int DashboardSourceIndexById(const DashboardSourceDefinition &defs[], const string source_id)
{
   for(int i = 0; i < ArraySize(defs); i++)
   {
      if(defs[i].source_id == source_id)
         return i;
   }

   return -1;
}

#endif
