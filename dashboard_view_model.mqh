#ifndef __DASHBOARD_VIEW_MODEL_MQH__
#define __DASHBOARD_VIEW_MODEL_MQH__

#include "dashboard_state_classifier.mqh"

DashboardPageDefinition g_dashboard_page_defs[];
DashboardPageModel g_dashboard_pages[];

string DashboardYesNo(const bool value)
{
   return (value ? "true" : "false");
}

string DashboardValueOr(const string value, const string fallback)
{
   return (StringLen(TrimString(value)) > 0 ? value : fallback);
}

string DashboardPercentText(const double value)
{
   return DoubleToString(value * 100.0, 1) + "%";
}

string DashboardPLText(const double value)
{
   return DoubleToString(value, 2);
}


int DashboardCountOccurrences(const string text, const string token)
{
   if(StringLen(token) == 0)
      return 0;

   int count = 0;
   int pos = 0;

   while(true)
   {
      pos = StringFind(text, token, pos);
      if(pos < 0)
         break;

      count++;
      pos += StringLen(token);
   }

   return count;
}

void DashboardClearCard(DashboardCardModel &card)
{
   card.widget_id = "";
   card.title = "";
   card.dominant_state_id = "";
   card.state_class = DASHBOARD_STATE_CLASS_DERIVED;
   card.severity_class = DASHBOARD_SEVERITY_NOTICE;
   card.authority_badge = "";
   card.source_badge = "";
   card.freshness_badge = "";
   card.state_badge = "";
   card.placeholder_badge = "";
   card.mixed_plane_warning_required = false;
   card.rendering_priority = 1;
   card.visible = true;
   card.line1 = "";
   card.line2 = "";
   card.line3 = "";
   card.line4 = "";
   card.line5 = "";
   card.line6 = "";
   card.note = "";
}

void DashboardClearPage(DashboardPageModel &page)
{
   page.page_id = "";
   page.title = "";
   page.subtitle = "";
   page.non_goal = "";
   page.posture_banner_text = "";
   page.posture_severity = DASHBOARD_SEVERITY_NOTICE;
   page.mixed_plane_warning_required = false;
   page.card_count = 0;
   for(int i = 0; i < DASHBOARD_MAX_CARDS_PER_PAGE; i++)
      DashboardClearCard(page.cards[i]);
}

void DashboardEnsurePageDefinitions()
{
   if(ArraySize(g_dashboard_page_defs) == DASHBOARD_MAX_PAGES)
      return;

   ArrayResize(g_dashboard_page_defs, DASHBOARD_MAX_PAGES);

   g_dashboard_page_defs[0].id = "system_posture_overview";
   g_dashboard_page_defs[0].title = "System Posture Overview";
   g_dashboard_page_defs[0].purpose = "Bounded summary of dominant governed truth layers.";
   g_dashboard_page_defs[0].non_goal = "This page does not become the primary truth source.";

   g_dashboard_page_defs[1].id = "runtime_governance";
   g_dashboard_page_defs[1].title = "Runtime / Governance";
   g_dashboard_page_defs[1].purpose = "Freeze, trading-block, startup, and governance posture.";
   g_dashboard_page_defs[1].non_goal = "This page does not grant runtime authority, unfreeze privilege, or trade permission.";

   g_dashboard_page_defs[2].id = "ai_authority_readiness";
   g_dashboard_page_defs[2].title = "AI Authority & Readiness";
   g_dashboard_page_defs[2].purpose = "Bounded AI authority and readiness visibility only.";
   g_dashboard_page_defs[2].non_goal = "This page does not imply AI execution authority, AI enablement, or mutation rights.";

   g_dashboard_page_defs[3].id = "ai_advisory_review_governance";
   g_dashboard_page_defs[3].title = "AI Advisory / Review / Governance";
   g_dashboard_page_defs[3].purpose = "Advisory-only boundary and review governance.";
   g_dashboard_page_defs[3].non_goal = "This page does not imply AI may control direction, veto runtime, or write to governed truth surfaces.";

   g_dashboard_page_defs[4].id = "factory_state";
   g_dashboard_page_defs[4].title = "Factory State";
   g_dashboard_page_defs[4].purpose = "Structural factory visibility with bounded mixed-plane handling.";
   g_dashboard_page_defs[4].non_goal = "Factory State does not imply runtime authority, canon promotion, experiment approval, or trading permission.";

   g_dashboard_page_defs[5].id = "transfer_pilot_cohort";
   g_dashboard_page_defs[5].title = "Transfer / Pilot / Cohort";
   g_dashboard_page_defs[5].purpose = "Transfer status, pilot structure, and evidence-only posture.";
   g_dashboard_page_defs[5].non_goal = "Pilot page does not imply live pilot, execution privilege, or runtime reactivation.";

   g_dashboard_page_defs[6].id = "export_release_gate";
   g_dashboard_page_defs[6].title = "Export / Release Gate";
   g_dashboard_page_defs[6].purpose = "Export blocked posture and blocker categories.";
   g_dashboard_page_defs[6].non_goal = "Export page does not imply export approval, release clearance, or external delivery authorization.";

   g_dashboard_page_defs[7].id = "startup_diagnostics";
   g_dashboard_page_defs[7].title = "Startup / Diagnostics";
   g_dashboard_page_defs[7].purpose = "Startup summary and bounded diagnostic context.";
   g_dashboard_page_defs[7].non_goal = "Startup/Diagnostics does not imply readiness, health, or permission beyond the visible bounded source truth.";

   g_dashboard_page_defs[8].id = "alerts_reasons_holds";
   g_dashboard_page_defs[8].title = "Alerts / Reasons / Holds";
   g_dashboard_page_defs[8].purpose = "Short blocking reasons by source ownership.";
   g_dashboard_page_defs[8].non_goal = "Alerts/Reasons/Holds does not become a governance action console or approval surface.";

   g_dashboard_page_defs[9].id = "market_operational_context";
   g_dashboard_page_defs[9].title = "Market Operational Context";
   g_dashboard_page_defs[9].purpose = "Context-only summary under blocking truth.";
   g_dashboard_page_defs[9].non_goal = "Market Operational Context does not imply live trading authority, execution intent, or strategy selection control.";
}

void DashboardInitPage(DashboardPageModel &page, const int index)
{
   DashboardClearPage(page);
   page.page_id = g_dashboard_page_defs[index].id;
   page.title = g_dashboard_page_defs[index].title;
   page.subtitle = g_dashboard_page_defs[index].purpose;
   page.non_goal = g_dashboard_page_defs[index].non_goal;
   page.posture_banner_text = DashboardTopPostureState();
   page.posture_severity = DashboardStateSeverityForId(page.posture_banner_text);
}

void DashboardFinalizeCard(DashboardCardModel &card, const string source_ids_csv)
{
   if(StringLen(card.dominant_state_id) == 0)
      card.dominant_state_id = "SOURCE_PARTIAL";

   card.state_class = DashboardStateClassForId(card.dominant_state_id);
   card.severity_class = DashboardStateSeverityForId(card.dominant_state_id);
   DashboardApplyDerivedSafetyState(card, source_ids_csv);
   DashboardApplyCommonBadges(card, source_ids_csv);
}

void DashboardBuildSystemOverviewPage(DashboardPageModel &page)
{
   DashboardCardModel card;

   DashboardClearCard(card);
   card.widget_id = "WGT_CURRENT_OPERATING_PICTURE";
   card.title = "Current Operating Picture";
   card.dominant_state_id = DashboardTopPostureState();
   card.rendering_priority = 1;

   string runtime_label = DashboardRuntimeOperationalLabel();
   string authority_source = "";
   string cohort_id = "";
   int cohort_count = 0;
   string risk_envelope_state = "";
   string guard_reason = "";
   string guard_name = "";
   string overall_state = "";
   string freshness_gate_state = "";
   int stale_critical_surface_count = 0;
   string dominant_stale_surface = "";
   string dominant_stale_reason = "";
   string last_event_type = "";
   string last_event_time = "";
   string last_event_note = "";
   string last_event_reason = "";

   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_source", authority_source);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "active_operating_cohort_id", cohort_id);
   DashboardGetInt("SRC_ACTIVE_OPERATING_COHORT", "candidate_count", cohort_count);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "operating_risk_envelope_state", risk_envelope_state);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", guard_reason);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_blocking_guard", guard_name);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "overall_state", overall_state);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "freshness_gate_state", freshness_gate_state);
   DashboardGetInt("SRC_OPERATIONAL_INTEGRITY_STATUS", "stale_critical_surface_count", stale_critical_surface_count);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "dominant_stale_surface", dominant_stale_surface);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "dominant_stale_reason", dominant_stale_reason);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "event_type", last_event_type);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "event_time", last_event_time);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "short_note", last_event_note);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "reason_code", last_event_reason);

   bool export_delivery_allowed = false;
   string export_gate_result = "";
   DashboardGetBool("SRC_EXPORT_RELEASE_GATE_STATUS", "external_delivery_allowed", export_delivery_allowed);
   DashboardGetString("SRC_EXPORT_RELEASE_GATE_STATUS", "overall_gate_result", export_gate_result);

   card.line1 = "Runtime posture: " + DashboardValueOr(runtime_label, "unavailable") + " | Integrity: " + DashboardValueOr(overall_state, "unknown");
   card.line2 = "Runtime authority source: " + DashboardValueOr(authority_source, "unavailable");
   card.line3 = "Active cohort: " + DashboardValueOr(cohort_id, "unavailable") + " (" + IntegerToString(cohort_count) + ")";
   card.line4 = "Risk envelope: " + DashboardValueOr(risk_envelope_state, "PENDING_RUNTIME_INIT") + " | Guard: " + DashboardValueOr(guard_name, "none");
   card.line5 = "Runtime blocker / reason: " + DashboardValueOr(guard_reason, "none");
   card.line6 = "Export posture: " + DashboardValueOr(export_gate_result, "unavailable") + " | External delivery allowed: " + DashboardYesNo(export_delivery_allowed);
   card.note = DashboardShortText("Last live event: " + DashboardValueOr(last_event_type, "unavailable") + " @ " + DashboardValueOr(last_event_time, "timestamp unavailable") + " | " + DashboardValueOr(last_event_note, last_event_reason), 108);
   if(freshness_gate_state != "FRESH")
      card.note = DashboardShortText("Freshness: " + DashboardValueOr(freshness_gate_state, "unknown") +
                                     " | Stale surfaces: " + IntegerToString(stale_critical_surface_count) +
                                     " | Dominant: " + DashboardValueOr(dominant_stale_surface, "unknown") +
                                     " | Reason: " + DashboardValueOr(dominant_stale_reason, "unknown"), 96);
   DashboardFinalizeCard(card, "SRC_RUNTIME_GOVERNANCE_STATUS|SRC_EXECUTION_AUTHORITY_STATUS|SRC_ACTIVE_OPERATING_COHORT|SRC_OPERATING_RISK_ENVELOPE_STATUS|SRC_OPERATIONAL_INTEGRITY_STATUS|SRC_LAST_MEANINGFUL_RUNTIME_EVENT|SRC_EXPORT_RELEASE_GATE_STATUS");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_WHY_BLOCKED_NOW";
   card.title = "Why Blocked Now?";
   card.dominant_state_id = DashboardTopPostureState();
   card.rendering_priority = 1;

   bool authority_blocked = false;
   string authority_reason = "";
   string authority_source_label = "";
   string authority_updated = "";
   bool guardrail_clear = true;
   bool guardrail_blocked = false;
   string guardrail_reason = "";
   string guardrail_name = "";
   DashboardGetBool("SRC_EXECUTION_AUTHORITY_STATUS", "execution_globally_blocked", authority_blocked);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_block_reason_code", authority_reason);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_source", authority_source_label);
   authority_updated = DashboardSourceUpdatedAtOrUnknown("SRC_EXECUTION_AUTHORITY_STATUS");
   bool guardrail_clear_present = DashboardGetBool("SRC_OPERATING_RISK_ENVELOPE_STATUS", "envelope_clear_for_new_entries", guardrail_clear);
   guardrail_blocked = (DashboardGuardrailBlockActive() && ((guardrail_clear_present && !guardrail_clear) || DashboardOperatingRiskEnvelopeState() == "ENVELOPE_BLOCKED" || DashboardOperatingRiskEnvelopeState() == "EMERGENCY_STOP_ACTIVE"));
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", guardrail_reason);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_blocking_guard", guardrail_name);

   card.line1 = "Current dominant block: " + ((guardrail_blocked && StringLen(guardrail_reason) > 0) ? "TRADING_BLOCKED" : (authority_blocked ? "TRADING_BLOCKED" : DashboardTopPostureState()));
   card.line2 = "Owning source: " + ((guardrail_blocked && StringLen(guardrail_reason) > 0) ? "Operating Risk Envelope Status" : (authority_blocked ? DashboardValueOr(authority_source_label, "SRC_EXECUTION_AUTHORITY_STATUS") : DashboardDominantBlockSourceLabel()));
   card.line3 = "Reason code: " + ((guardrail_blocked && StringLen(guardrail_reason) > 0) ? DashboardValueOr(guardrail_reason, "unavailable") : (authority_blocked ? DashboardValueOr(authority_reason, "unavailable") : DashboardValueOr(DashboardDominantBlockReasonCode(), "unavailable")));
   card.line4 = "Affected domain: " + ((guardrail_blocked && StringLen(guardrail_reason) > 0) ? "risk / safety" : (authority_blocked ? "runtime / execution authority" : DashboardDominantBlockAffectedDomain()));
   card.line5 = "Affected scope: " + ((guardrail_blocked && StringLen(guardrail_reason) > 0) ? DashboardValueOr(guardrail_name, "runtime entry envelope") : (authority_blocked ? "active operating cohort admission" : DashboardDominantBlockScope()));
   card.line6 = "Last updated: " + ((guardrail_blocked && StringLen(guardrail_reason) > 0) ? DashboardSourceUpdatedAtOrUnknown("SRC_OPERATING_RISK_ENVELOPE_STATUS") : (authority_blocked ? authority_updated : DashboardSourceUpdatedAtOrUnknown(DashboardDominantBlockSourceId())));
   card.note = "Concise operational summary only. Use source and freshness badges before inferring authority.";
   DashboardFinalizeCard(card, "SRC_RUNTIME_GOVERNANCE_STATUS|SRC_OPERATING_RISK_ENVELOPE_STATUS|SRC_DIAGNOSTIC_RUNTIME_SUMMARY|SRC_EXPORT_RELEASE_GATE_STATUS|SRC_TRANSFER_PACKAGE5_PILOT_CYCLE|SRC_AI_ACTIVATION_READINESS");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_TRADE_STATISTICS_OVERVIEW";
   card.title = "Trade Statistics Summary";
   card.dominant_state_id = "EVIDENCE_ONLY";
   card.rendering_priority = 2;

   int decisions_total = 0;
   int rejected_total = 0;
   int waits_total = 0;
   int execution_total = 0;
   int closed_outcomes_total = 0;
   int wins = 0;
   int losses = 0;
   double win_rate = 0.0;
   double net_realized_pl = 0.0;
   string last_trade_result = "";
   string last_trade_time = "";
   string last_exec_name = "";
   string last_exec_family = "";
   string evidence_state = "";
   string evidence_note = "";
   string evidence_scope = "";
   string evidence_scope_note = "";

   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "decisions_total", decisions_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "rejected_total", rejected_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "waits_total", waits_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "execution_total", execution_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "closed_outcomes_total", closed_outcomes_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "wins", wins);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "losses", losses);
   DashboardGetDouble("SRC_FACTORY_OPERATIONAL_EVIDENCE", "win_rate", win_rate);
   DashboardGetDouble("SRC_FACTORY_OPERATIONAL_EVIDENCE", "net_realized_pl", net_realized_pl);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "last_trade_result", last_trade_result);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "last_trade_time", last_trade_time);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "last_executed_candidate_name", last_exec_name);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "last_executed_candidate_family", last_exec_family);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_completeness_state", evidence_state);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_completeness_note", evidence_note);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_scope", evidence_scope);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_scope_note", evidence_scope_note);

   card.line1 = "Decisions / Reject / Wait: " + IntegerToString(decisions_total) + " / " + IntegerToString(rejected_total) + " / " + IntegerToString(waits_total);
   card.line2 = "Executions / Closed outcomes: " + IntegerToString(execution_total) + " / " + IntegerToString(closed_outcomes_total);
   card.line3 = "Wins / Losses: " + IntegerToString(wins) + " / " + IntegerToString(losses) + " | Win rate: " + DashboardPercentText(win_rate);
   card.line4 = "Net realized result: " + DashboardPLText(net_realized_pl);
   card.line5 = "Last trade: " + DashboardValueOr(last_trade_result, "unavailable") + " @ " + DashboardValueOr(last_trade_time, "unavailable");
   card.line6 = "Last executed candidate/family: " + DashboardValueOr(last_exec_name, "unavailable") + " / " + DashboardValueOr(last_exec_family, "unavailable");
   card.note = "Coverage: " + DashboardValueOr(evidence_state, "PARTIAL") + " | Scope: " + DashboardValueOr(evidence_scope, "HISTORICAL_PLUS_CURRENT_RUNTIME_SUMMARY") + " | " + DashboardShortText(DashboardValueOr(evidence_scope_note, evidence_note), 72);
   DashboardFinalizeCard(card, "SRC_FACTORY_OPERATIONAL_EVIDENCE|SRC_TRADE_JOURNAL_SUMMARY|SRC_EXECUTION_QUALITY_VALIDATION");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_OPERATIONAL_INTEGRITY_SUMMARY";
   card.title = "Operational Integrity Summary";
   card.dominant_state_id = DashboardOperationalIntegrityDominantState();
   card.rendering_priority = 2;

   string overall_reason = "";
   string runtime_integrity = "";
   string execution_authority_integrity = "";
   string dashboard_integrity = "";
   string factory_integrity = "";
   string ai_integrity = "";
   string journaling_integrity = "";
   string risk_integrity = "";
   string last_checked = "";

   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "overall_state", overall_state);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "overall_reason", overall_reason);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "runtime_integrity_state", runtime_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "execution_authority_integrity_state", execution_authority_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "dashboard_integrity_state", dashboard_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "factory_integrity_state", factory_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "ai_oversight_integrity_state", ai_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "journaling_integrity_state", journaling_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "risk_safety_integrity_state", risk_integrity);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "last_checked", last_checked);

   card.line1 = "Overall coherence: " + DashboardValueOr(overall_state, "PARTIAL");
   card.line2 = "Runtime / Authority: " + DashboardValueOr(runtime_integrity, "unknown") + " / " + DashboardValueOr(execution_authority_integrity, "unknown");
   card.line3 = "Dashboard / Factory: " + DashboardValueOr(dashboard_integrity, "unknown") + " / " + DashboardValueOr(factory_integrity, "unknown");
   card.line4 = "AI / Journaling: " + DashboardValueOr(ai_integrity, "unknown") + " / " + DashboardValueOr(journaling_integrity, "unknown");
   card.line5 = "Risk / Safety: " + DashboardValueOr(risk_integrity, "unknown");
   card.line6 = "Last checked: " + DashboardValueOr(last_checked, "timestamp unavailable");
   card.note = "Reason: " + DashboardShortText(DashboardValueOr(overall_reason, "runtime coherence summary unavailable"), 96);
   DashboardFinalizeCard(card, "SRC_OPERATIONAL_INTEGRITY_STATUS");
   page.cards[page.card_count++] = card;
}

void DashboardBuildRuntimeGovernancePage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_RUNTIME_POSTURE_CARD";
   card.title = "Runtime Posture";
   card.dominant_state_id = DashboardRuntimePostureState();
   card.rendering_priority = 1;

   bool freeze_active = DashboardRuntimeFreezeSemanticallyActive();
   bool trading_blocked = DashboardTradingBlockedSemantically();
   bool policy_locked = DashboardPolicyLockedSemantically();
   bool execution_privilege_frozen = DashboardExecutionPrivilegeFrozenSemantically();
   bool factory_admission_required = false;
   bool legacy_authority_active = false;
   bool factory_governed_authority = false;
   bool cohort_defined = false;
   int cohort_count = 0;
   string governance_state = "";
   string reason_code = "";
   string freeze_scope = "";
   string status_origin = "";
   string cutover_state = "";
   string authority_source = "";
   string cohort_id = "";

   DashboardGetBoolEither("SRC_RUNTIME_GOVERNANCE_STATUS", "future_factory_admission_required_for_execution",
                          "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "future_factory_admission_required_for_execution",
                          factory_admission_required);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "governance_state", governance_state);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "reason_code", reason_code);
   DashboardGetStringEither("SRC_RUNTIME_GOVERNANCE_STATUS", "strategy_transfer_runtime_freeze_scope",
                            "SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS", "strategy_transfer_runtime_freeze_scope",
                            freeze_scope);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "status_origin", status_origin);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "execution_authority_cutover_state", cutover_state);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "execution_authority_source", authority_source);
   DashboardGetBool("SRC_RUNTIME_GOVERNANCE_STATUS", "legacy_identity_execution_authority_active", legacy_authority_active);
   DashboardGetBool("SRC_RUNTIME_GOVERNANCE_STATUS", "factory_governed_execution_authority_active", factory_governed_authority);
   DashboardGetBool("SRC_RUNTIME_GOVERNANCE_STATUS", "active_operating_cohort_defined", cohort_defined);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "active_operating_cohort_id", cohort_id);
   DashboardGetInt("SRC_RUNTIME_GOVERNANCE_STATUS", "active_operating_candidate_count", cohort_count);

   string envelope_state_runtime = "";
   string guard_reason_runtime = "";
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "operating_risk_envelope_state", envelope_state_runtime);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", guard_reason_runtime);

   card.line1 = "Runtime posture: " + DashboardRuntimeOperationalLabel();
   card.line2 = "Execution authority source: " + DashboardValueOr(authority_source, "unavailable");
   card.line3 = "Cutover state: " + DashboardValueOr(cutover_state, "unavailable");
   card.line4 = "Legacy identity authority retired: " + DashboardYesNo(!legacy_authority_active);
   card.line5 = "Active cohort families: " + DashboardValueOr(cohort_id, "unavailable") + " (" + IntegerToString(cohort_count) + ")";
   card.line6 = "Guard posture: " + DashboardValueOr(envelope_state_runtime, "PENDING_RUNTIME_INIT");
   card.note = "Trading blocked=" + DashboardYesNo(trading_blocked) +
               " | Factory-governed authority=" + DashboardYesNo(factory_governed_authority) +
               " | Cohort defined=" + DashboardYesNo(cohort_defined) +
               " | Guard reason=" + DashboardValueOr(guard_reason_runtime, "none") +
               " | Freeze lineage scope=" + DashboardValueOr(freeze_scope, "unavailable") +
               " | Status origin=" + DashboardValueOr(status_origin, "unavailable") +
               " | Policy locked=" + DashboardYesNo(policy_locked) +
               " | Execution privilege frozen=" + DashboardYesNo(execution_privilege_frozen) +
               " | Factory admission required=" + DashboardYesNo(factory_admission_required) +
               " | Freeze active=" + DashboardYesNo(freeze_active);
   DashboardFinalizeCard(card, "SRC_RUNTIME_GOVERNANCE_STATUS|SRC_STRATEGY_TRANSFER_RUNTIME_FREEZE_STATUS|SRC_EXECUTION_AUTHORITY_STATUS|SRC_ACTIVE_OPERATING_COHORT");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_OPERATING_GUARDRAILS_SUMMARY";
   card.title = "Operating Guardrails Summary";
   card.dominant_state_id = (DashboardGuardrailBlockActive() ? "TRADING_BLOCKED" : "STARTUP_OK");
   card.rendering_priority = 2;

   string guard_state = "";
   string guard_name = "";
   string guard_reason = "";
   string guard_owner = "";
   int max_open_positions_guard = 0;
   int current_open_positions_guard = 0;
   int max_trades_guard = 0;
   int session_cap_guard = 0;
   int current_session_guard = 0;
   int cooldown_guard = 0;
   int bars_since_guard = 0;
   bool spread_guard_active_runtime = false;
   double spread_guard_threshold = 0.0;
   double current_spread_guard = 0.0;

   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "operating_risk_envelope_state", guard_state);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_blocking_guard", guard_name);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", guard_reason);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_owner", guard_owner);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "max_open_positions", max_open_positions_guard);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_open_positions", current_open_positions_guard);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "max_new_trades_per_session", max_trades_guard);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "effective_session_trade_cap", session_cap_guard);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_session_new_entries", current_session_guard);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "cooldown_bars", cooldown_guard);
   DashboardGetInt("SRC_OPERATING_RISK_ENVELOPE_STATUS", "bars_since_last_entry", bars_since_guard);
   DashboardGetBool("SRC_OPERATING_RISK_ENVELOPE_STATUS", "spread_guard_active", spread_guard_active_runtime);
   DashboardGetDouble("SRC_OPERATING_RISK_ENVELOPE_STATUS", "spread_guard_threshold_points", spread_guard_threshold);
   DashboardGetDouble("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_spread_points", current_spread_guard);

   card.line1 = "Envelope state: " + DashboardValueOr(guard_state, "PENDING_RUNTIME_INIT");
   card.line2 = "Dominant guard / reason: " + DashboardValueOr(guard_name, "none") + " / " + DashboardValueOr(guard_reason, "none");
   card.line3 = "Open positions: " + IntegerToString(current_open_positions_guard) + " / " + IntegerToString(max_open_positions_guard);
   card.line4 = "Session entries: " + IntegerToString(current_session_guard) + " / " + IntegerToString(session_cap_guard > 0 ? session_cap_guard : max_trades_guard);
   card.line5 = "Cooldown bars: " + IntegerToString(bars_since_guard) + " since last entry | min " + IntegerToString(cooldown_guard);
   card.line6 = "Spread guard: " + DashboardYesNo(spread_guard_active_runtime) + " | current/limit " + DoubleToString(current_spread_guard, 1) + " / " + DoubleToString(spread_guard_threshold, 1);
   card.note = "Owner: " + DashboardValueOr(guard_owner, "operating_risk_envelope") + ". Authority alone does not imply immediate execution when a guardrail is active.";
   DashboardFinalizeCard(card, "SRC_OPERATING_RISK_ENVELOPE_STATUS|SRC_RUNTIME_GOVERNANCE_STATUS|SRC_EXECUTION_AUTHORITY_STATUS");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_LAST_MEANINGFUL_EVENT";
   card.title = "Last Meaningful Event";
   card.dominant_state_id = DashboardTopPostureState();
   card.rendering_priority = 2;

   string event_type = "";
   string event_time = "";
   string event_candidate = "";
   string event_family = "";
   string event_reason = "";
   string event_direction = "";
   string event_note = "";
   string event_owner = "";

   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "event_type", event_type);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "event_time", event_time);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "candidate_name", event_candidate);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "candidate_family", event_family);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "reason_code", event_reason);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "direction", event_direction);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "short_note", event_note);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "source_owner", event_owner);

   card.line1 = "Event type: " + DashboardValueOr(event_type, "unavailable");
   card.line2 = "Event time: " + DashboardValueOr(event_time, "timestamp unavailable");
   card.line3 = "Candidate / family: " + DashboardValueOr(event_candidate, "n/a") + " / " + DashboardValueOr(event_family, "n/a");
   card.line4 = "Direction / owner: " + DashboardValueOr(event_direction, "n/a") + " / " + DashboardValueOr(event_owner, "unavailable");
   card.line5 = "Reason code: " + DashboardValueOr(event_reason, "none");
   card.line6 = "Note: " + DashboardShortText(DashboardValueOr(event_note, "none"), 86);
   card.note = "Bounded runtime event surface only; useful for reviewability, not control.";
   DashboardFinalizeCard(card, "SRC_LAST_MEANINGFUL_RUNTIME_EVENT");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_EXECUTION_AUTHORITY_CARD";
   card.title = "Execution Authority";
   card.dominant_state_id = DashboardRuntimePostureState();
   card.rendering_priority = 2;

   string authority_source2 = "";
   string cutover_state2 = "";
   string admission_semantics2 = "";
   string decision_candidate_name2 = "";
   string decision_candidate_family2 = "";
   string last_reject_candidate_name2 = "";
   string last_reject_reason_code2 = "";
   string last_executed_candidate_name2 = "";
   string last_executed_candidate_family2 = "";
   string last_executed_candidate_time2 = "";

   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_source", authority_source2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_cutover_state", cutover_state2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "operating_cohort_admission_semantics", admission_semantics2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "decision_candidate_name", decision_candidate_name2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "decision_candidate_family", decision_candidate_family2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "last_reject_candidate_name", last_reject_candidate_name2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "last_reject_reason_code", last_reject_reason_code2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "last_executed_candidate_name", last_executed_candidate_name2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "last_executed_candidate_family", last_executed_candidate_family2);
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "last_executed_candidate_time", last_executed_candidate_time2);

   string guard_state2 = "";
   string guard_reason2 = "";
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "operating_risk_envelope_state", guard_state2);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", guard_reason2);

   card.line1 = "Authority source: " + DashboardValueOr(authority_source2, "unavailable");
   card.line2 = "Cutover state / semantics: " + DashboardValueOr(cutover_state2, "unavailable") + " / " + DashboardValueOr(admission_semantics2, "FAMILY_LEVEL");
   card.line3 = "Current guard posture: " + DashboardValueOr(guard_state2, "PENDING_RUNTIME_INIT") + " | " + DashboardValueOr(guard_reason2, "none");
   card.line4 = "Decision attribution: " + DashboardValueOr(decision_candidate_name2, "unavailable") + " / " + DashboardValueOr(decision_candidate_family2, "unavailable");
   card.line5 = "Last reject: " + DashboardValueOr(last_reject_candidate_name2, "none") + " | " + DashboardValueOr(last_reject_reason_code2, "none");
   card.line6 = "Last execution: " + DashboardValueOr(last_executed_candidate_name2, "none") + " / " + DashboardValueOr(last_executed_candidate_family2, "none") + " @ " + DashboardValueOr(last_executed_candidate_time2, "unavailable");
   card.note = "Execution authority remains cohort-governed and family-level; guardrails may still block entries when authority exists.";
   DashboardFinalizeCard(card, "SRC_EXECUTION_AUTHORITY_STATUS|SRC_ACTIVE_OPERATING_COHORT|SRC_OPERATING_RISK_ENVELOPE_STATUS");
   page.cards[page.card_count++] = card;
}

void DashboardBuildAIAuthorityReadinessPage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_AI_AUTHORITY_CARD";
   card.title = "AI Authority";
   card.dominant_state_id = DashboardAIAuthorityState();
   card.rendering_priority = 1;

   string authority_state = "";
   bool runtime_governance_allows_ai = false;
   bool direct_control_allowed = false;
   bool auto_apply_allowed = false;
   bool directional_trade_generation_allowed = false;
   string review_surface_state = "";
   bool review_surface_present = false;
   bool review_surface_independent = false;
   bool review_surface_implies_ready = false;

   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "authority_state", authority_state);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "runtime_governance_allows_ai", runtime_governance_allows_ai);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "direct_control_allowed", direct_control_allowed);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "auto_apply_allowed", auto_apply_allowed);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "directional_trade_generation_allowed", directional_trade_generation_allowed);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "review_surface_state", review_surface_state);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "review_surface_present", review_surface_present);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "review_surface_independent_of_authority", review_surface_independent);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "review_surface_implies_authority_ready", review_surface_implies_ready);

   card.line1 = "Authority posture: " + DashboardValueOr(authority_state, "AI_OFF");
   card.line2 = "Runtime governance allows AI: " + DashboardYesNo(runtime_governance_allows_ai);
   card.line3 = "Direct control allowed: " + DashboardYesNo(direct_control_allowed);
   card.line4 = "Auto apply allowed: " + DashboardYesNo(auto_apply_allowed);
   card.line5 = "Directional trade generation allowed: " + DashboardYesNo(directional_trade_generation_allowed);
   card.line6 = "Review surface: " + DashboardValueOr(review_surface_state, "unavailable") + " | present=" + DashboardYesNo(review_surface_present);
   card.note = "Review independent of authority=" + DashboardYesNo(review_surface_independent) +
               " | Review implies authority ready=" + DashboardYesNo(review_surface_implies_ready);
   DashboardFinalizeCard(card, "SRC_AI_ACTIVATION_READINESS|SRC_AI_OPERATIONAL_REVIEW");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_AI_READINESS_CARD";
   card.title = "AI Readiness";
   card.dominant_state_id = "NOT_READY";
   card.rendering_priority = 2;

   string readiness_state = "";
   string readiness_reason_code = "";
   string next_upgrade_blocker = "";
   bool ai_bridge_ready = false;
   bool truth_ready = false;
   bool diagnostics_ready = false;
   bool replay_ready = false;
   bool validation_ready = false;
   string consistency_state = "";
   string consistency_note = "";

   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "readiness_state", readiness_state);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "readiness_reason_code", readiness_reason_code);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "next_upgrade_blocker", next_upgrade_blocker);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "ai_bridge_ready", ai_bridge_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "truth_ready", truth_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "diagnostics_ready", diagnostics_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "replay_ready", replay_ready);
   DashboardGetBool("SRC_AI_ACTIVATION_READINESS", "validation_ready", validation_ready);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "readiness_review_consistency_state", consistency_state);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "readiness_review_note", consistency_note);

   card.line1 = "Readiness state: " + DashboardValueOr(readiness_state, "NOT_READY");
   card.line2 = "Reason / blocker: " + DashboardValueOr(readiness_reason_code, "unavailable") + " / " + DashboardValueOr(next_upgrade_blocker, "unavailable");
   card.line3 = "Bridge / truth / diagnostics: " + DashboardYesNo(ai_bridge_ready) + " / " + DashboardYesNo(truth_ready) + " / " + DashboardYesNo(diagnostics_ready);
   card.line4 = "Replay / validation: " + DashboardYesNo(replay_ready) + " / " + DashboardYesNo(validation_ready);
   card.line5 = "Consistency state: " + DashboardValueOr(consistency_state, "PENDING");
   card.line6 = "Last updated: " + DashboardSourceUpdatedAtOrUnknown("SRC_AI_ACTIVATION_READINESS");
   card.note = DashboardShortText(DashboardValueOr(consistency_note, "AI review visibility does not imply runtime AI authority readiness."), 96);
   DashboardFinalizeCard(card, "SRC_AI_ACTIVATION_READINESS|SRC_AI_OPERATIONAL_REVIEW|SRC_OPERATIONAL_INTEGRITY_STATUS");
   page.cards[page.card_count++] = card;
}

void DashboardBuildAIAdvisoryGovernancePage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_AI_GOVERNANCE_BOUNDARY";
   card.title = "AI Governance Boundary";
   card.dominant_state_id = "AI_ADVISORY_ONLY";
   card.rendering_priority = 1;

   string learning_role = "";
   string council_role = "";
   string allowed_outputs = "";
   string forbidden_outputs = "";
   string proposal_authority = "";

   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "learning_governance_role", learning_role);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "council_advisory_role", council_role);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "council_advisory_allowed_outputs", allowed_outputs);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "council_advisory_forbidden_outputs", forbidden_outputs);
   DashboardGetString("SRC_AI_ACTIVATION_READINESS", "proposal_generation_authority", proposal_authority);

   card.line1 = "Learning governance role: " + DashboardValueOr(learning_role, "unavailable");
   card.line2 = "Council advisory role: " + DashboardValueOr(council_role, "unavailable");
   card.line3 = "Allowed outputs: " + DashboardShortText(DashboardValueOr(allowed_outputs, "unavailable"), 94);
   card.line4 = "Forbidden outputs: " + DashboardShortText(DashboardValueOr(forbidden_outputs, "unavailable"), 94);
   card.note = "Proposal authority: " + DashboardValueOr(proposal_authority, "ADVISORY_ONLY");
   DashboardFinalizeCard(card, "SRC_AI_ACTIVATION_READINESS|SRC_DOC_FACTORY_TRUTH_VOCABULARY_CONTRACT");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_PAGE_MIXED_PLANE_WARNING";
   card.title = "Review Governance";
   card.dominant_state_id = "EVIDENCE_ONLY";
   card.rendering_priority = 2;
   card.line1 = "AI visibility remains review-governed and evidence-bounded.";
   card.line2 = "No runtime mutation, veto, or direct execution path exists here.";
   card.line3 = "No hidden authority is rendered or implied.";
   card.note = "This page clarifies governance boundaries only.";
   DashboardFinalizeCard(card, "SRC_AI_ACTIVATION_READINESS");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_AI_OPERATIONAL_REVIEW";
   card.title = "AI Operational Review";
   card.dominant_state_id = "EVIDENCE_ONLY";
   card.rendering_priority = 2;

   string authority_state = "";
   bool repeated_cluster = false;
   string repeated_family = "";
   int repeated_count = 0;
   string no_trade_pattern = "";
   string drift_state = "";
   string evidence_gap = "";
   string advisory_sufficiency = "";
   string interpretability = "";
   string dominant_block_layer = "";
   string dominant_reason = "";
   string dominant_regime = "";
   string context_note = "";

   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "authority_state", authority_state);
   DashboardGetBool("SRC_AI_OPERATIONAL_REVIEW", "repeated_reject_cluster_present", repeated_cluster);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "repeated_reject_cluster_family", repeated_family);
   DashboardGetInt("SRC_AI_OPERATIONAL_REVIEW", "repeated_reject_cluster_count", repeated_count);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "no_trade_pattern_state", no_trade_pattern);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "drift_observation_state", drift_state);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "evidence_gap_state", evidence_gap);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "advisory_sufficiency_state", advisory_sufficiency);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "interpretability_state", interpretability);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "dominant_block_layer", dominant_block_layer);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "dominant_reason_code", dominant_reason);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "dominant_regime_label", dominant_regime);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "post_execution_context_note", context_note);

   card.line1 = "Authority state: " + DashboardValueOr(authority_state, "unavailable") + " | Advisory sufficiency: " + DashboardValueOr(advisory_sufficiency, "unknown");
   card.line2 = "Repeated reject cluster: " + DashboardYesNo(repeated_cluster) + " | " + DashboardValueOr(repeated_family, "none") + " (" + IntegerToString(repeated_count) + ")";
   card.line3 = "No-trade / drift: " + DashboardValueOr(no_trade_pattern, "unknown") + " / " + DashboardValueOr(drift_state, "unknown");
   card.line4 = "Evidence gap / interpretability: " + DashboardValueOr(evidence_gap, "unknown") + " / " + DashboardValueOr(interpretability, "unknown");
   card.line5 = "Dominant block / regime: " + DashboardValueOr(dominant_block_layer, "unknown") + " / " + DashboardValueOr(dominant_regime, "unknown");
   card.line6 = "Dominant reason: " + DashboardValueOr(dominant_reason, "none");
   card.note = DashboardShortText(DashboardValueOr(context_note, "AI remains explanatory only."), 96);
   DashboardFinalizeCard(card, "SRC_AI_OPERATIONAL_REVIEW|SRC_AI_ACTIVATION_READINESS|SRC_LAST_MEANINGFUL_RUNTIME_EVENT|SRC_FACTORY_OPERATIONAL_EVIDENCE");
   page.cards[page.card_count++] = card;
}

void DashboardBuildFactoryStatePage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_FACTORY_SUMMARY_CARD";
   card.title = "Factory Summary";
   card.dominant_state_id = DashboardFactoryPostureState();
   card.rendering_priority = 1;

   string edge_factory_state = "";
   bool intake_ready = false;
   bool decomposition_ready = false;
   int registered_material_total = 0;

   DashboardGetString("SRC_FACTORY_INTAKE_STATUS", "edge_factory_state", edge_factory_state);
   DashboardGetBool("SRC_FACTORY_INTAKE_STATUS", "edge_factory_intake_ready", intake_ready);
   DashboardGetBool("SRC_EDGE_FACTORY_DECOMPOSITION_STATUS", "edge_factory_decomposition_ready", decomposition_ready);
   DashboardGetInt("SRC_EDGE_FACTORY_MANIFEST", "registered_material_total", registered_material_total);

   card.line1 = "Factory posture: " + DashboardValueOr(edge_factory_state, "unavailable");
   card.line2 = "Factory Ready Structurally: " + DashboardYesNo(intake_ready && decomposition_ready);
   card.line3 = "Intake ready: " + DashboardYesNo(intake_ready);
   card.line4 = "Decomposition ready: " + DashboardYesNo(decomposition_ready);
   card.line5 = "Registered material total: " + IntegerToString(registered_material_total);
   card.note = "Factory visibility is structural only and not canon promotion.";
   DashboardFinalizeCard(card, "SRC_FACTORY_INTAKE_STATUS|SRC_EDGE_FACTORY_DECOMPOSITION_STATUS|SRC_EDGE_FACTORY_MANIFEST");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_FACTORY_GATEWAY_CARD";
   card.title = "Gateway / Intelligence";
   card.dominant_state_id = "FACTORY_PARTIAL";
   card.rendering_priority = 2;

   int gateway_record_count = 0;
   bool gateway_snapshot_emitted = false;
   string gateway_processing_mode = "";
   int intelligence_record_count = 0;
   bool artifact_snapshot_emitted = false;

   DashboardGetInt("SRC_SOURCE_INTAKE_GATEWAY_STATUS", "gateway_record_count", gateway_record_count);
   DashboardGetBool("SRC_SOURCE_INTAKE_GATEWAY_STATUS", "gateway_snapshot_emitted", gateway_snapshot_emitted);
   DashboardGetString("SRC_SOURCE_INTAKE_GATEWAY_STATUS", "gateway_processing_mode", gateway_processing_mode);
   DashboardGetInt("SRC_EDGE_FACTORY_INTERNAL_INTELLIGENCE_STATUS", "intelligence_record_count", intelligence_record_count);
   DashboardGetBool("SRC_EDGE_FACTORY_INTERNAL_INTELLIGENCE_STATUS", "artifact_snapshot_emitted", artifact_snapshot_emitted);

   card.line1 = "Gateway record count: " + IntegerToString(gateway_record_count);
   card.line2 = "Gateway snapshot emitted: " + DashboardYesNo(gateway_snapshot_emitted);
   card.line3 = "Gateway mode: " + DashboardValueOr(gateway_processing_mode, "unavailable");
   card.line4 = "Intelligence record count: " + IntegerToString(intelligence_record_count);
   card.line5 = "Intelligence snapshot emitted: " + DashboardYesNo(artifact_snapshot_emitted);
   card.note = "Zero record state is cautionary, not healthy.";
   DashboardFinalizeCard(card, "SRC_SOURCE_INTAKE_GATEWAY_STATUS|SRC_EDGE_FACTORY_INTERNAL_INTELLIGENCE_STATUS");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_FACTORY_OPERATIONAL_EVIDENCE";
   card.title = "Factory Operational Evidence Summary";
   card.dominant_state_id = "EVIDENCE_ONLY";
   card.rendering_priority = 2;

   string evidence_cohort = "";
   int evidence_count = 0;
   string evidence_semantics = "";
   string evidence_scope = "";
   string evidence_scope_note = "";
   int decisions_total = 0;
   int rejected_total = 0;
   int waits_total = 0;
   int execution_total = 0;
   int closed_outcomes_total = 0;
   string completeness_state = "";
   string completeness_note = "";
   string lineage_note = "";

   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "active_operating_cohort_id", evidence_cohort);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "active_operating_candidate_count", evidence_count);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "operating_cohort_admission_semantics", evidence_semantics);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_scope", evidence_scope);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_scope_note", evidence_scope_note);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "decisions_total", decisions_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "rejected_total", rejected_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "waits_total", waits_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "execution_total", execution_total);
   DashboardGetInt("SRC_FACTORY_OPERATIONAL_EVIDENCE", "closed_outcomes_total", closed_outcomes_total);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_completeness_state", completeness_state);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_completeness_note", completeness_note);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "lineage_note", lineage_note);

   card.line1 = "Active cohort context: " + DashboardValueOr(evidence_cohort, "unavailable") + " (" + IntegerToString(evidence_count) + ")";
   card.line2 = "Admission / evidence scope: " + DashboardValueOr(evidence_semantics, "FAMILY_LEVEL") + " / " + DashboardValueOr(evidence_scope, "HISTORICAL_PLUS_CURRENT_RUNTIME_SUMMARY");
   card.line3 = "Decision / Reject / Wait: " + IntegerToString(decisions_total) + " / " + IntegerToString(rejected_total) + " / " + IntegerToString(waits_total);
   card.line4 = "Execution / Closed outcomes: " + IntegerToString(execution_total) + " / " + IntegerToString(closed_outcomes_total);
   card.line5 = "Evidence completeness: " + DashboardValueOr(completeness_state, "PARTIAL");
   card.line6 = "Scope note: " + DashboardShortText(DashboardValueOr(evidence_scope_note, completeness_note), 84);
   card.note = DashboardShortText(DashboardValueOr(lineage_note, "Runtime evidence remains linked to factory lineage only."), 96);
   DashboardFinalizeCard(card, "SRC_FACTORY_OPERATIONAL_EVIDENCE|SRC_ACTIVE_OPERATING_COHORT|SRC_EXECUTION_QUALITY_VALIDATION");
   page.cards[page.card_count++] = card;
}

void DashboardBuildTransferPilotPage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_TRANSFER_PILOT_SUMMARY";
   card.title = "Transfer / Pilot Summary";
   card.dominant_state_id = "PILOT_DEFINED_NOT_LIVE";
   card.rendering_priority = 1;

   string package5_state = "";
   bool pilot_cycle_defined = false;
   bool runtime_reactivation_performed = false;
   bool live_pilot_execution_started = false;
   string package_c_state = "";

   DashboardGetString("SRC_TRANSFER_PACKAGE5_STATUS", "package5_state", package5_state);
   DashboardGetBool("SRC_TRANSFER_PACKAGE5_PILOT_CYCLE", "pilot_cycle_defined", pilot_cycle_defined);
   DashboardGetBool("SRC_TRANSFER_PACKAGE5_PILOT_CYCLE", "runtime_reactivation_performed", runtime_reactivation_performed);
   DashboardGetBool("SRC_TRANSFER_PACKAGE5_PILOT_CYCLE", "live_pilot_execution_started", live_pilot_execution_started);
   DashboardGetString("SRC_TRANSFER_PACKAGEC_STATUS", "package_c_state", package_c_state);

   string runtime_authority_source = "";
   string current_cohort_id = "";
   DashboardGetString("SRC_EXECUTION_AUTHORITY_STATUS", "execution_authority_source", runtime_authority_source);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "active_operating_cohort_id", current_cohort_id);

   card.line1 = "Package 5 state: " + DashboardValueOr(package5_state, "unavailable");
   card.line2 = "Pilot Defined, Not Live: " + DashboardYesNo(pilot_cycle_defined && !live_pilot_execution_started);
   card.line3 = "Historical lineage only: package5 / packageC / pilot surfaces";
   card.line4 = "Current execution truth: " + DashboardValueOr(runtime_authority_source, "unavailable");
   card.line5 = "Current active cohort: " + DashboardValueOr(current_cohort_id, "unavailable");
   card.line6 = "Live pilot execution started: " + DashboardYesNo(live_pilot_execution_started);
   card.note = "Package C state: " + DashboardValueOr(package_c_state, "unavailable") + ". Runtime reactivation performed=" + DashboardYesNo(runtime_reactivation_performed) + ". Transfer/pilot surfaces remain evidence lineage and do not define current authority.";
   DashboardFinalizeCard(card, "SRC_TRANSFER_PACKAGE5_STATUS|SRC_TRANSFER_PACKAGE5_PILOT_CYCLE|SRC_TRANSFER_PACKAGEC_STATUS|SRC_ACTIVE_OPERATING_COHORT|SRC_EXECUTION_AUTHORITY_STATUS");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_TRANSFER_PILOT_EVIDENCE";
   card.title = "Pilot Evidence";
   card.dominant_state_id = "EVIDENCE_ONLY";
   card.rendering_priority = 2;

   string pilot_evidence_mode = "";
   int covered_candidate_count = 0;
   DashboardGetString("SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE", "pilot_evidence_mode", pilot_evidence_mode);
   DashboardGetInt("SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE", "covered_candidate_count", covered_candidate_count);
   DashboardGetBool("SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE", "live_pilot_execution_started", live_pilot_execution_started);
   DashboardGetBool("SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE", "runtime_reactivation_performed", runtime_reactivation_performed);

   card.line1 = "Pilot evidence mode: " + DashboardValueOr(pilot_evidence_mode, "unavailable");
   card.line2 = "Covered candidate count: " + IntegerToString(covered_candidate_count);
   card.line3 = "Live pilot execution started: " + DashboardYesNo(live_pilot_execution_started);
   card.line4 = "Runtime reactivation performed: " + DashboardYesNo(runtime_reactivation_performed);
   card.note = "Evidence-only posture does not imply pilot readiness.";
   DashboardFinalizeCard(card, "SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE|SRC_DOC_PILOT_EVIDENCE_DESIGN_CONTRACT");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_ACTIVE_OPERATING_COHORT";
   card.title = "Active Operating Cohort Families";
   card.dominant_state_id = "STARTUP_OK";
   card.rendering_priority = 2;

   string cohort_id2 = "";
   string cohort_state2 = "";
   string cohort_candidates = "";
   int cohort_count2 = 0;
   string admission_semantics3 = "";
   string candidate_sources = "";
   string cohort_reason = "";
   string cohort_scope_note = "";

   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "active_operating_cohort_id", cohort_id2);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "active_operating_cohort_state", cohort_state2);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "active_operating_candidates", cohort_candidates);
   DashboardGetInt("SRC_ACTIVE_OPERATING_COHORT", "candidate_count", cohort_count2);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "operating_cohort_admission_semantics", admission_semantics3);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "candidate_sources", candidate_sources);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "cohort_activation_reason", cohort_reason);
   DashboardGetString("SRC_ACTIVE_OPERATING_COHORT", "cohort_scope_note", cohort_scope_note);

   card.line1 = "Cohort id: " + DashboardValueOr(cohort_id2, "unavailable");
   card.line2 = "State / family count: " + DashboardValueOr(cohort_state2, "unavailable") + " / " + IntegerToString(cohort_count2);
   card.line3 = "Admitted families: " + DashboardValueOr(cohort_candidates, "unavailable");
   card.line4 = "Admission semantics: " + DashboardValueOr(admission_semantics3, "FAMILY_LEVEL");
   card.line5 = "Candidate sources: " + DashboardValueOr(candidate_sources, "unavailable");
   card.line6 = "Activation reason: " + DashboardValueOr(cohort_reason, "unavailable");
   card.note = DashboardShortText(DashboardValueOr(cohort_scope_note, "Scope unavailable"), 110);
   DashboardFinalizeCard(card, "SRC_ACTIVE_OPERATING_COHORT|SRC_TRANSFER_PACKAGE5_STATUS|SRC_TRANSFER_PACKAGEC_PILOT_EVIDENCE");
   page.cards[page.card_count++] = card;
}

void DashboardBuildExportReleaseGatePage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_EXPORT_GATE_SUMMARY";
   card.title = "Export Gate";
   card.dominant_state_id = DashboardExportPostureState();
   card.rendering_priority = 1;

   string gate_result = "";
   bool external_delivery_allowed = false;
   bool delivery_sanitization_required = false;
   string default_gate_result_reason = "";

   DashboardGetString("SRC_EXPORT_RELEASE_GATE_STATUS", "overall_gate_result", gate_result);
   DashboardGetBool("SRC_EXPORT_RELEASE_GATE_STATUS", "external_delivery_allowed", external_delivery_allowed);
   DashboardGetBool("SRC_EXPORT_RELEASE_GATE_STATUS", "delivery_sanitization_required", delivery_sanitization_required);
   DashboardGetString("SRC_EXPORT_RELEASE_GATE_STATUS", "default_gate_result_reason", default_gate_result_reason);

   card.line1 = "Gate result: " + DashboardValueOr(gate_result, "unavailable");
   card.line2 = "Export Blocked: " + DashboardYesNo(!external_delivery_allowed || gate_result == "BLOCKED");
   card.line3 = "External delivery allowed: " + DashboardYesNo(external_delivery_allowed);
   card.line4 = "Delivery sanitization required: " + DashboardYesNo(delivery_sanitization_required);
   card.note = DashboardShortText("Export / release posture only. Runtime posture remains governed separately. " + DashboardValueOr(default_gate_result_reason, "No release-gate reason available."), 118);
   DashboardFinalizeCard(card, "SRC_EXPORT_RELEASE_GATE_STATUS|SRC_DOC_EXPORT_RELEASE_GATE_CONTRACT");
   page.cards[page.card_count++] = card;

   DashboardClearCard(card);
   card.widget_id = "WGT_EXPORT_BLOCKERS";
   card.title = "Export Blockers";
   card.dominant_state_id = "EXPORT_BLOCKED";
   card.rendering_priority = 2;
   string raw = DashboardSourceRawText("SRC_EXPORT_RELEASE_GATE_STATUS");
   int blocking_checks = DashboardCountOccurrences(raw, "\"blocking\": true");
   int all_checks = DashboardCountOccurrences(raw, "\"check_id\"");
   int blocker_conditions = DashboardCountOccurrences(raw, "ANY_");
   card.line1 = "Blocking checks: " + IntegerToString(blocking_checks) + " / " + IntegerToString(all_checks);
   card.line2 = "Blocked delivery conditions tracked: " + IntegerToString(blocker_conditions);
   card.line3 = "Raw diagnostic/control/memory surfaces remain blocking.";
   card.line4 = "Export-safe subset is not elevated over governed truth.";
   card.note = "Internal-only release gate context; no external delivery approval exists.";
   DashboardFinalizeCard(card, "SRC_EXPORT_RELEASE_GATE_STATUS|SRC_DOC_SECRET_HYGIENE_REMEDIATION");
   page.cards[page.card_count++] = card;
}

void DashboardBuildStartupDiagnosticsPage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_STARTUP_DIAGNOSTIC_SUMMARY";
   card.title = "Startup Diagnostic Summary";
   card.dominant_state_id = DashboardDerivedStartupState();
   card.rendering_priority = 1;

   string final_decision = "";
   bool final_blocked = false;
   string final_block_reason_code = "";
   string governance_state = "";
   string note = "";
   string evaluated_at = "";
   string freshness_gate_state = "";
   string dominant_stale_surface = "";
   string dominant_stale_reason = "";

   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_decision", final_decision);
   DashboardGetBool("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_blocked", final_blocked);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_block_reason_code", final_block_reason_code);
   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "governance_state", governance_state);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "note", note);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "evaluated_at", evaluated_at);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "freshness_gate_state", freshness_gate_state);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "dominant_stale_surface", dominant_stale_surface);
   DashboardGetString("SRC_OPERATIONAL_INTEGRITY_STATUS", "dominant_stale_reason", dominant_stale_reason);

   string runtime_label_startup = DashboardRuntimeOperationalLabel();
   bool export_delivery_allowed_startup = false;
   string export_gate_result_startup = "";
   DashboardGetBool("SRC_EXPORT_RELEASE_GATE_STATUS", "external_delivery_allowed", export_delivery_allowed_startup);
   DashboardGetString("SRC_EXPORT_RELEASE_GATE_STATUS", "overall_gate_result", export_gate_result_startup);

   card.line1 = "Final decision: " + DashboardValueOr(final_decision, "unavailable");
   card.line2 = "Final blocked: " + DashboardYesNo(final_blocked);
   card.line3 = "Runtime posture: " + DashboardValueOr(runtime_label_startup, "unavailable") + " | Governance state: " + DashboardValueOr(governance_state, "unavailable");
   card.line4 = "Export posture: " + DashboardValueOr(export_gate_result_startup, "unavailable") + " | External delivery allowed: " + DashboardYesNo(export_delivery_allowed_startup);
   card.line5 = "Evaluated at: " + DashboardValueOr(evaluated_at, "timestamp unavailable");
   card.line6 = "Reason code: " + DashboardValueOr(final_block_reason_code, "unavailable");
   card.note = "Note: " + DashboardShortText(DashboardValueOr(note, "none"), 90);
   if(freshness_gate_state != "FRESH")
      card.note = DashboardShortText("Freshness: " + DashboardValueOr(freshness_gate_state, "unknown") +
                                     " | Dominant stale surface: " + DashboardValueOr(dominant_stale_surface, "unknown") +
                                     " | Reason: " + DashboardValueOr(dominant_stale_reason, "unknown"), 96);
   DashboardFinalizeCard(card, "SRC_DIAGNOSTIC_RUNTIME_SUMMARY|SRC_RUNTIME_GOVERNANCE_STATUS|SRC_OPERATIONAL_INTEGRITY_STATUS|SRC_EXPORT_RELEASE_GATE_STATUS");
   page.cards[page.card_count++] = card;
}

void DashboardBuildAlertsReasonsPage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_ALERTS_REASONS_HOLDS";
   card.title = "Top Reasons / Holds";
   card.dominant_state_id = DashboardTopPostureState();
   card.rendering_priority = 1;

   string runtime_reason = "";
   string guard_reason = "";
   string event_type = "";
   string factory_state = "";
   string ai_state = "";
   string ai_reason = "";

   DashboardGetString("SRC_RUNTIME_GOVERNANCE_STATUS", "reason_code", runtime_reason);
   DashboardGetString("SRC_OPERATING_RISK_ENVELOPE_STATUS", "current_block_reason_code", guard_reason);
   DashboardGetString("SRC_LAST_MEANINGFUL_RUNTIME_EVENT", "event_type", event_type);
   DashboardGetString("SRC_FACTORY_OPERATIONAL_EVIDENCE", "evidence_completeness_state", factory_state);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "interpretability_state", ai_state);
   DashboardGetString("SRC_AI_OPERATIONAL_REVIEW", "dominant_reason_code", ai_reason);

   card.line1 = "Runtime: " + DashboardValueOr(runtime_reason, "unavailable");
   card.line2 = "Guardrail: " + DashboardValueOr(guard_reason, "none");
   card.line3 = "Last event: " + DashboardValueOr(event_type, "unavailable");
   card.line4 = "Factory evidence: " + DashboardValueOr(factory_state, "unavailable");
   card.line5 = "AI interpretability: " + DashboardValueOr(ai_state, "unavailable");
   card.line6 = "AI dominant reason: " + DashboardValueOr(ai_reason, "none");
   card.note = "Reasons are source-owned summaries only; no workflow console exists.";
   DashboardFinalizeCard(card, "SRC_RUNTIME_GOVERNANCE_STATUS|SRC_OPERATING_RISK_ENVELOPE_STATUS|SRC_LAST_MEANINGFUL_RUNTIME_EVENT|SRC_FACTORY_OPERATIONAL_EVIDENCE|SRC_AI_OPERATIONAL_REVIEW");
   page.cards[page.card_count++] = card;
}

void DashboardBuildMarketOperationalContextPage(DashboardPageModel &page)
{
   DashboardCardModel card;
   DashboardClearCard(card);
   card.widget_id = "WGT_MARKET_OPERATIONAL_CONTEXT";
   card.title = "Market Operational Context";
   card.dominant_state_id = "SUMMARY_ONLY_NOT_PRIMARY_TRUTH";
   card.rendering_priority = 1;

   string zone_name = "";
   string consensus_label = "";
   string governor_state = "";
   string execution_path = "";
   bool final_blocked = false;
   string note = "";

   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "zone_name", zone_name);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "consensus_label", consensus_label);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "governor_state", governor_state);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "execution_path", execution_path);
   DashboardGetBool("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "final_blocked", final_blocked);
   DashboardGetString("SRC_DIAGNOSTIC_RUNTIME_SUMMARY", "note", note);

   if(final_blocked)
      card.dominant_state_id = "PENDING_RUNTIME_INIT";

   card.line1 = "Zone name: " + DashboardValueOr(zone_name, "context unavailable");
   card.line2 = "Consensus label: " + DashboardValueOr(consensus_label, "context unavailable");
   card.line3 = "Governor state: " + DashboardValueOr(governor_state, "unavailable");
   card.line4 = "Execution path: " + DashboardValueOr(execution_path, "unavailable");
   card.line5 = "Final blocked: " + DashboardYesNo(final_blocked);
   card.note = "Context note: " + DashboardShortText(DashboardValueOr(note, "none"), 90);
   DashboardFinalizeCard(card, "SRC_DIAGNOSTIC_RUNTIME_SUMMARY");
   page.cards[page.card_count++] = card;
}

void DashboardBuildAllPages()
{
   DashboardEnsurePageDefinitions();
   ArrayResize(g_dashboard_pages, DASHBOARD_MAX_PAGES);

   for(int i = 0; i < DASHBOARD_MAX_PAGES; i++)
      DashboardInitPage(g_dashboard_pages[i], i);

   DashboardBuildSystemOverviewPage(g_dashboard_pages[0]);
   DashboardBuildRuntimeGovernancePage(g_dashboard_pages[1]);
   DashboardBuildAIAuthorityReadinessPage(g_dashboard_pages[2]);
   DashboardBuildAIAdvisoryGovernancePage(g_dashboard_pages[3]);
   DashboardBuildFactoryStatePage(g_dashboard_pages[4]);
   DashboardBuildTransferPilotPage(g_dashboard_pages[5]);
   DashboardBuildExportReleaseGatePage(g_dashboard_pages[6]);
   DashboardBuildStartupDiagnosticsPage(g_dashboard_pages[7]);
   DashboardBuildAlertsReasonsPage(g_dashboard_pages[8]);
   DashboardBuildMarketOperationalContextPage(g_dashboard_pages[9]);

   for(int i = 0; i < DASHBOARD_MAX_PAGES; i++)
   {
      bool saw_authoritative = false;
      bool saw_other = false;

      for(int c = 0; c < g_dashboard_pages[i].card_count; c++)
      {
         if(g_dashboard_pages[i].cards[c].state_class == DASHBOARD_STATE_CLASS_AUTHORITATIVE)
            saw_authoritative = true;
         else
            saw_other = true;

         if(g_dashboard_pages[i].cards[c].mixed_plane_warning_required)
            g_dashboard_pages[i].mixed_plane_warning_required = true;
      }

      if(saw_authoritative && saw_other)
         g_dashboard_pages[i].mixed_plane_warning_required = true;
   }
}

bool DashboardGetPageModel(const int index, DashboardPageModel &out_page)
{
   if(index < 0 || index >= ArraySize(g_dashboard_pages))
      return false;

   out_page = g_dashboard_pages[index];
   return true;
}

#endif
