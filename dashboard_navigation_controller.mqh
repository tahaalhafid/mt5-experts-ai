#ifndef __DASHBOARD_NAVIGATION_CONTROLLER_MQH__
#define __DASHBOARD_NAVIGATION_CONTROLLER_MQH__

#include "dashboard_snapshot_exporter.mqh"

DashboardLocalUIState g_dashboard_ui;
bool g_dashboard_ui_initialized = false;
bool g_dashboard_render_requested = false;
bool g_dashboard_force_reload_requested = false;
bool g_dashboard_page_entry_requested = false;
string g_dashboard_last_snapshot_status = "";

string DashboardSeverityFilterLabel()
{
   if(g_dashboard_ui.severity_filter == "CAUTION_PLUS")
      return "Severity: Caution+";
   if(g_dashboard_ui.severity_filter == "WARNING_PLUS")
      return "Severity: Warning+";
   if(g_dashboard_ui.severity_filter == "CRITICAL_ONLY")
      return "Severity: Critical only";
   return "Severity: All";
}

string DashboardPanelFilterLabel()
{
   if(g_dashboard_ui.panel_filter == "PRIMARY_ONLY")
      return "Panels: Primary only";
   if(g_dashboard_ui.panel_filter == "PRIMARY_SECONDARY")
      return "Panels: Primary + Secondary";
   return "Panels: All";
}

string DashboardStateClassFilterLabel()
{
   if(g_dashboard_ui.state_class_filter == "AUTHORITATIVE_ONLY")
      return "State class: Authoritative";
   if(g_dashboard_ui.state_class_filter == "DERIVED_ONLY")
      return "State class: Derived";
   if(g_dashboard_ui.state_class_filter == "TRANSITIONAL_ONLY")
      return "State class: Transitional";
   return "State class: All";
}

bool DashboardAnyLocalFilterActive()
{
   return (g_dashboard_ui.severity_filter != "ALL" ||
           g_dashboard_ui.panel_filter != "ALL" ||
           g_dashboard_ui.state_class_filter != "ALL" ||
           !g_dashboard_ui.show_transitional_warnings);
}

string DashboardFilterToolbarSeverityText()
{
   if(g_dashboard_ui.severity_filter == "CAUTION_PLUS")
      return "Severity:Caution+";
   if(g_dashboard_ui.severity_filter == "WARNING_PLUS")
      return "Severity:Warning+";
   if(g_dashboard_ui.severity_filter == "CRITICAL_ONLY")
      return "Severity:Critical";
   return "Severity:All";
}

string DashboardFilterToolbarPanelText()
{
   if(g_dashboard_ui.panel_filter == "PRIMARY_ONLY")
      return "Panel:Primary";
   if(g_dashboard_ui.panel_filter == "PRIMARY_SECONDARY")
      return "Panel:Pri+Sec";
   return "Panel:All";
}

string DashboardFilterToolbarClassText()
{
   if(g_dashboard_ui.state_class_filter == "AUTHORITATIVE_ONLY")
      return "Class:Authoritative";
   if(g_dashboard_ui.state_class_filter == "DERIVED_ONLY")
      return "Class:Derived";
   if(g_dashboard_ui.state_class_filter == "TRANSITIONAL_ONLY")
      return "Class:Transitional";
   return "Class:All";
}

string DashboardActiveFilterSummary()
{
   string summary = DashboardSeverityFilterLabel() + " | " + DashboardPanelFilterLabel() + " | " + DashboardStateClassFilterLabel();
   if(!g_dashboard_ui.show_transitional_warnings)
      summary += " | Transitional warnings hidden";
   return summary;
}

string DashboardAutoRefreshStatusLabel()
{
   return (g_dashboard_ui.auto_refresh_enabled ? "Auto refresh: On (" + IntegerToString(g_dashboard_ui.auto_refresh_interval_seconds) + "s)" :
                                                 "Auto refresh: Off");
}

string DashboardAutoRefreshButtonText()
{
   return (g_dashboard_ui.auto_refresh_enabled ? "Auto:On" : "Auto:Off");
}

string DashboardViewOptionsButtonText()
{
   return (g_dashboard_ui.view_options_expanded ? "View Options:Hide" : "View Options");
}

string DashboardLayoutSummary()
{
   return (g_dashboard_ui.compact_view_enabled ? "Layout: Compact" : "Layout: Full") +
          " | Panels: " + (g_dashboard_ui.collapsed_panels ? "Collapsed" : "Expanded") +
          " | Details: " + (g_dashboard_ui.show_advanced_details ? "Shown" : "Bounded") +
          " | Footprint: " + ((g_dashboard_ui.compact_view_enabled && g_dashboard_ui.collapsed_panels) ? "Minimized" : "Normal");
}

bool DashboardIsMinimizedFootprint()
{
   return (g_dashboard_ui.compact_view_enabled && g_dashboard_ui.collapsed_panels);
}

void DashboardSetMinimizedFootprint(const bool minimized)
{
   if(minimized)
   {
      g_dashboard_ui.compact_view_enabled = true;
      g_dashboard_ui.collapsed_panels = true;
      g_dashboard_ui.view_options_expanded = false;
      DashboardSetAlert("Dashboard footprint minimized (read-only view). Use Restore Size to expand.");
   }
   else
   {
      g_dashboard_ui.compact_view_enabled = false;
      g_dashboard_ui.collapsed_panels = false;
      DashboardSetAlert("Dashboard footprint restored to normal layout.");
   }

   DashboardPersistLocalUIState();
   DashboardRequestRender();
}

void DashboardSetDefaultUIState()
{
   g_dashboard_ui.dashboard_visible = true;
   g_dashboard_ui.current_page_index = 0;
   g_dashboard_ui.current_page_id = "system_posture_overview";
   g_dashboard_ui.compact_view_enabled = true;
   g_dashboard_ui.collapsed_panels = true;
   g_dashboard_ui.show_transitional_warnings = true;
   g_dashboard_ui.show_advanced_details = false;
   g_dashboard_ui.auto_refresh_enabled = true;
   g_dashboard_ui.auto_refresh_interval_seconds = DASHBOARD_AUTO_REFRESH_DEFAULT_SECONDS;
   g_dashboard_ui.view_options_expanded = false;
   g_dashboard_ui.severity_filter = "ALL";
   g_dashboard_ui.panel_filter = "ALL";
   g_dashboard_ui.state_class_filter = "ALL";
   g_dashboard_ui.alert_dismissed = false;
   g_dashboard_ui.last_resync_request_time = "";
   g_dashboard_ui.last_snapshot_export_time = "";
   g_dashboard_ui.local_alert_text = "Read-only dashboard active. Visibility does not grant authority.";
}

bool DashboardLoadLocalUIState()
{
   string text = "";
   if(!LoadTextFile("AI\\dashboard_local_ui_state.json", text))
      return false;

   string current_page_id = "";
   string layout_mode = "";
   string severity_filter = "";
   string panel_filter = "";
   string state_class_filter = "";
   bool show_transitional = true;
   bool show_advanced = false;
   bool compact_view_enabled = false;
   bool collapsed_panels = false;
   bool auto_refresh_enabled = true;
   int auto_refresh_interval_seconds = DASHBOARD_AUTO_REFRESH_DEFAULT_SECONDS;
   bool view_options_expanded = false;
   string last_resync = "";
   string last_snapshot_export_time = "";

   ExtractJsonStringField(text, "current_page_id", current_page_id);
   ExtractJsonStringField(text, "layout_mode", layout_mode);
   ExtractJsonStringField(text, "severity_filter", severity_filter);
   ExtractJsonStringField(text, "panel_filter", panel_filter);
   ExtractJsonStringField(text, "state_class_filter", state_class_filter);
   ExtractJsonBoolField(text, "show_transitional_warnings", show_transitional);
   ExtractJsonBoolField(text, "show_advanced_details", show_advanced);
   ExtractJsonBoolField(text, "compact_view_enabled", compact_view_enabled);
   ExtractJsonBoolField(text, "collapsed_panels", collapsed_panels);
   ExtractJsonBoolField(text, "auto_refresh_enabled", auto_refresh_enabled);
   ExtractJsonIntField(text, "auto_refresh_interval_seconds", auto_refresh_interval_seconds);
   ExtractJsonBoolField(text, "view_options_expanded", view_options_expanded);
   ExtractJsonStringField(text, "last_resync_request_time", last_resync);
   ExtractJsonStringField(text, "last_snapshot_export_time", last_snapshot_export_time);

   if(StringLen(current_page_id) > 0)
      g_dashboard_ui.current_page_id = current_page_id;
   if(StringLen(severity_filter) > 0)
      g_dashboard_ui.severity_filter = severity_filter;
   if(StringLen(panel_filter) > 0)
      g_dashboard_ui.panel_filter = panel_filter;
   if(StringLen(state_class_filter) > 0)
      g_dashboard_ui.state_class_filter = state_class_filter;

   g_dashboard_ui.show_transitional_warnings = show_transitional;
   g_dashboard_ui.show_advanced_details = show_advanced;
   g_dashboard_ui.compact_view_enabled = compact_view_enabled;
   g_dashboard_ui.collapsed_panels = (layout_mode == "COMPACT_COLLAPSED" || collapsed_panels);
   g_dashboard_ui.auto_refresh_enabled = auto_refresh_enabled;
   g_dashboard_ui.auto_refresh_interval_seconds = (auto_refresh_interval_seconds > 0 ? auto_refresh_interval_seconds : DASHBOARD_AUTO_REFRESH_DEFAULT_SECONDS);
   g_dashboard_ui.view_options_expanded = view_options_expanded;
   g_dashboard_ui.last_resync_request_time = last_resync;
   g_dashboard_ui.last_snapshot_export_time = last_snapshot_export_time;
   return true;
}

void DashboardApplyPageIndexFromId()
{
   DashboardEnsurePageDefinitions();

   for(int i = 0; i < ArraySize(g_dashboard_page_defs); i++)
   {
      if(g_dashboard_page_defs[i].id == g_dashboard_ui.current_page_id)
      {
         g_dashboard_ui.current_page_index = i;
         return;
      }
   }

   g_dashboard_ui.current_page_index = 0;
   g_dashboard_ui.current_page_id = g_dashboard_page_defs[0].id;
}

bool DashboardPersistLocalUIState()
{
   string layout_mode = "FULL_VIEW";
   if(g_dashboard_ui.compact_view_enabled && g_dashboard_ui.collapsed_panels)
      layout_mode = "COMPACT_COLLAPSED";
   else if(g_dashboard_ui.compact_view_enabled)
      layout_mode = "COMPACT_VIEW";

   string json = "{\n";
   json += "  \"artifact_role\": \"DASHBOARD_LOCAL_UI_STATE\",\n";
   json += "  \"artifact_authority_class\": \"LOCAL_ONLY_NON_AUTHORITATIVE_UI_STATE\",\n";
   json += "  \"dashboard_phase\": \"PHASE1_2_READ_ONLY_REFINEMENT_ACTIVE\",\n";
   json += "  \"current_page_id\": \"" + g_dashboard_ui.current_page_id + "\",\n";
   json += "  \"layout_mode\": \"" + layout_mode + "\",\n";
   json += "  \"severity_filter\": \"" + g_dashboard_ui.severity_filter + "\",\n";
   json += "  \"panel_filter\": \"" + g_dashboard_ui.panel_filter + "\",\n";
   json += "  \"state_class_filter\": \"" + g_dashboard_ui.state_class_filter + "\",\n";
   json += "  \"show_transitional_warnings\": " + (g_dashboard_ui.show_transitional_warnings ? "true" : "false") + ",\n";
   json += "  \"show_advanced_details\": " + (g_dashboard_ui.show_advanced_details ? "true" : "false") + ",\n";
   json += "  \"compact_view_enabled\": " + (g_dashboard_ui.compact_view_enabled ? "true" : "false") + ",\n";
   json += "  \"collapsed_panels\": " + (g_dashboard_ui.collapsed_panels ? "true" : "false") + ",\n";
   json += "  \"auto_refresh_enabled\": " + (g_dashboard_ui.auto_refresh_enabled ? "true" : "false") + ",\n";
   json += "  \"auto_refresh_interval_seconds\": " + IntegerToString(g_dashboard_ui.auto_refresh_interval_seconds) + ",\n";
   json += "  \"view_options_expanded\": " + (g_dashboard_ui.view_options_expanded ? "true" : "false") + ",\n";
   json += "  \"last_resync_request_time\": \"" + g_dashboard_ui.last_resync_request_time + "\",\n";
   json += "  \"last_snapshot_export_time\": \"" + g_dashboard_ui.last_snapshot_export_time + "\",\n";
   json += "  \"non_goal_note\": \"Local UI state remains visibility-only and must not mutate runtime or governance truth.\"\n";
   json += "}\n";

   return DashboardWriteTextFile("AI\\dashboard_local_ui_state.json", json);
}

void DashboardEnsureUIInitialized()
{
   if(g_dashboard_ui_initialized)
      return;

   DashboardSetDefaultUIState();
   DashboardLoadLocalUIState();
   DashboardApplyPageIndexFromId();
   g_dashboard_ui_initialized = true;
}

void DashboardSetAlert(const string alert_text)
{
   g_dashboard_ui.alert_dismissed = false;
   g_dashboard_ui.local_alert_text = alert_text;
}

void DashboardRequestRender()
{
   g_dashboard_render_requested = true;
}

void DashboardOpenPage(const int index)
{
   DashboardEnsurePageDefinitions();

   int bounded_index = index;
   if(bounded_index < 0)
      bounded_index = 0;
   if(bounded_index >= ArraySize(g_dashboard_page_defs))
      bounded_index = ArraySize(g_dashboard_page_defs) - 1;

   g_dashboard_ui.current_page_index = bounded_index;
   g_dashboard_ui.current_page_id = g_dashboard_page_defs[bounded_index].id;
   g_dashboard_page_entry_requested = true;
   DashboardPersistLocalUIState();
   DashboardRequestRender();
}

void DashboardCycleSeverityFilter()
{
   if(g_dashboard_ui.severity_filter == "ALL")
      g_dashboard_ui.severity_filter = "CAUTION_PLUS";
   else if(g_dashboard_ui.severity_filter == "CAUTION_PLUS")
      g_dashboard_ui.severity_filter = "WARNING_PLUS";
   else if(g_dashboard_ui.severity_filter == "WARNING_PLUS")
      g_dashboard_ui.severity_filter = "CRITICAL_ONLY";
   else
      g_dashboard_ui.severity_filter = "ALL";

   DashboardPersistLocalUIState();
   DashboardRequestRender();
}

void DashboardCyclePanelFilter()
{
   if(g_dashboard_ui.panel_filter == "ALL")
      g_dashboard_ui.panel_filter = "PRIMARY_ONLY";
   else if(g_dashboard_ui.panel_filter == "PRIMARY_ONLY")
      g_dashboard_ui.panel_filter = "PRIMARY_SECONDARY";
   else
      g_dashboard_ui.panel_filter = "ALL";

   DashboardPersistLocalUIState();
   DashboardRequestRender();
}

void DashboardCycleStateClassFilter()
{
   if(g_dashboard_ui.state_class_filter == "ALL")
      g_dashboard_ui.state_class_filter = "AUTHORITATIVE_ONLY";
   else if(g_dashboard_ui.state_class_filter == "AUTHORITATIVE_ONLY")
      g_dashboard_ui.state_class_filter = "DERIVED_ONLY";
   else if(g_dashboard_ui.state_class_filter == "DERIVED_ONLY")
      g_dashboard_ui.state_class_filter = "TRANSITIONAL_ONLY";
   else
      g_dashboard_ui.state_class_filter = "ALL";

   DashboardPersistLocalUIState();
   DashboardRequestRender();
}

string DashboardButtonPageId(const int index)
{
   return "AIDASH_BTN_PAGE_" + IntegerToString(index);
}

void DashboardHandleActionButton(const string name)
{
   if(name == "AIDASH_BTN_REFRESH")
   {
      DashboardSetAlert("View refreshed from bounded dashboard state.");
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_RELOAD")
   {
      g_dashboard_force_reload_requested = true;
      DashboardSetAlert("Curated status surfaces reload requested.");
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_PREV")
   {
      DashboardOpenPage(g_dashboard_ui.current_page_index - 1);
   }
   else if(name == "AIDASH_BTN_NEXT")
   {
      DashboardOpenPage(g_dashboard_ui.current_page_index + 1);
   }
   else if(name == "AIDASH_BTN_MINIMIZE")
   {
      DashboardSetMinimizedFootprint(!DashboardIsMinimizedFootprint());
   }
   else if(name == "AIDASH_BTN_CLOSE_PANEL")
   {
      DashboardSetMinimizedFootprint(true);
   }
   else if(name == "AIDASH_BTN_COMPACT")
   {
      g_dashboard_ui.compact_view_enabled = !g_dashboard_ui.compact_view_enabled;
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_COLLAPSE")
   {
      g_dashboard_ui.collapsed_panels = !g_dashboard_ui.collapsed_panels;
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_SEVERITY")
   {
      DashboardCycleSeverityFilter();
   }
   else if(name == "AIDASH_BTN_PANEL")
   {
      DashboardCyclePanelFilter();
   }
   else if(name == "AIDASH_BTN_CLASS")
   {
      DashboardCycleStateClassFilter();
   }
   else if(name == "AIDASH_BTN_TRANSITION")
   {
      g_dashboard_ui.show_transitional_warnings = !g_dashboard_ui.show_transitional_warnings;
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_ADVANCED")
   {
      g_dashboard_ui.show_advanced_details = !g_dashboard_ui.show_advanced_details;
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_AUTO")
   {
      g_dashboard_ui.auto_refresh_enabled = !g_dashboard_ui.auto_refresh_enabled;
      DashboardPersistLocalUIState();
      DashboardSetAlert(g_dashboard_ui.auto_refresh_enabled ? "Auto refresh enabled for bounded view updates." : "Auto refresh paused. Manual refresh remains available.");
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_VIEW_OPTIONS")
   {
      g_dashboard_ui.view_options_expanded = !g_dashboard_ui.view_options_expanded;
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_SNAPSHOT")
   {
      DashboardPageModel page;
      if(DashboardGetPageModel(g_dashboard_ui.current_page_index, page))
      {
         string runtime_path = "";
         string status = "";
         if(DashboardExportVisibleSnapshot(page, runtime_path, status))
         {
            g_dashboard_ui.last_snapshot_export_time = DashboardNowString();
            g_dashboard_last_snapshot_status = status;
            DashboardSetAlert(status);
         }
         else
         {
            g_dashboard_last_snapshot_status = status;
            DashboardSetAlert(status);
         }
      }

      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_RESET")
   {
      DashboardSetDefaultUIState();
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_DISMISS")
   {
      g_dashboard_ui.alert_dismissed = true;
      DashboardPersistLocalUIState();
      DashboardRequestRender();
   }
   else if(name == "AIDASH_BTN_RESYNC")
   {
      g_dashboard_ui.last_resync_request_time = DashboardNowString();
      g_dashboard_force_reload_requested = true;
      DashboardPersistLocalUIState();
      DashboardSetAlert("View timestamps re-sync requested.");
      DashboardRequestRender();
   }
}

void DashboardHandleChartClick(const string name)
{
   if(!DashboardGuardrailAllowButton(name))
      return;

   if(StringFind(name, "AIDASH_BTN_PAGE_") == 0)
   {
      int index = (int)StringToInteger(StringSubstr(name, StringLen("AIDASH_BTN_PAGE_")));
      if(DashboardIsMinimizedFootprint())
      {
         g_dashboard_ui.compact_view_enabled = true;
         g_dashboard_ui.collapsed_panels = false;
      }
      DashboardOpenPage(index);
      return;
   }

   DashboardHandleActionButton(name);
}

void DashboardProcessPendingActions()
{
   DashboardEnsureUIInitialized();

   if(g_dashboard_force_reload_requested)
   {
      DashboardCollectorPoll(true, true);
      g_dashboard_force_reload_requested = false;
      g_dashboard_page_entry_requested = false;
   }
   else if(g_dashboard_page_entry_requested)
   {
      DashboardCollectorPoll(false, true);
      g_dashboard_page_entry_requested = false;
   }
   else
   {
      DashboardCollectorPoll(false, false);
   }

   DashboardBuildAllPages();
}

#endif
