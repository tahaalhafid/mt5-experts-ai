#ifndef __DASHBOARD_GUARDRAILS_MQH__
#define __DASHBOARD_GUARDRAILS_MQH__

#include "dashboard_view_model.mqh"

bool DashboardGuardrailAllowSourceRender(const DashboardCollectedSourceState &source_state)
{
   if(source_state.tier == DASHBOARD_SOURCE_TIER_D_NEVER_RENDER_DIRECTLY)
      return false;

   return source_state.direct_render_allowed;
}

string DashboardSanitizeSnapshotLine(string value)
{
   string text = TrimString(value);

   if(StringLen(text) == 0)
      return text;

   StringReplace(text, "MQL5/Files/AI/", "");
   StringReplace(text, "MQL5\\Files\\AI\\", "");
   StringReplace(text, "MQL5/Experts/AI/", "");
   StringReplace(text, "MQL5\\Experts\\AI\\", "");

   StringReplace(text, "Ready", "Qualified Ready");
   StringReplace(text, "AI Enabled", "AI Advisory Only");
   StringReplace(text, "Pilot Active", "Pilot Defined, Not Live");
   StringReplace(text, "Healthy", "Structurally Present");

   return DashboardShortText(text, 180);
}

bool DashboardGuardrailAllowButton(const string button_id)
{
   if(StringFind(button_id, "AIDASH_BTN_CTL_") == 0)
      return false;
   return true;
}

string DashboardGuardrailInternalOnlyNote()
{
   return DASHBOARD_INTERNAL_WATERMARK;
}

#endif
