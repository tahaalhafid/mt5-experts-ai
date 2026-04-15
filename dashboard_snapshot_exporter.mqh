#ifndef __DASHBOARD_SNAPSHOT_EXPORTER_MQH__
#define __DASHBOARD_SNAPSHOT_EXPORTER_MQH__

#include "dashboard_guardrails.mqh"

string DashboardSnapshotTimestampToken()
{
   string token = TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
   StringReplace(token, ".", "");
   StringReplace(token, ":", "");
   StringReplace(token, " ", "_");
   return token;
}

bool DashboardWriteTextFile(const string runtime_path, const string text)
{
   int handle = FileOpen(runtime_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(handle == INVALID_HANDLE)
      return false;

   FileWriteString(handle, text);
   FileClose(handle);
   return true;
}

string DashboardBuildVisibleSummary(const DashboardPageModel &page)
{
   string text = "";
   text += DashboardGuardrailInternalOnlyNote() + "\r\n";
   text += "snapshot_role=INTERNAL_ONLY_SANITIZED_VISIBLE_SUMMARY\r\n";
   text += "snapshot_authority=DERIVED_NON_AUTHORITATIVE\r\n";
   text += "snapshot_generated_at=" + DashboardNowString() + "\r\n";
   text += "page_id=" + page.page_id + "\r\n";
   text += "page_title=" + page.title + "\r\n";
   text += "posture_banner=" + DashboardSanitizeSnapshotLine(page.posture_banner_text) + "\r\n";
   text += "page_non_goal=" + DashboardSanitizeSnapshotLine(page.non_goal) + "\r\n";

   for(int i = 0; i < page.card_count; i++)
   {
      DashboardCardModel card = page.cards[i];
      if(!card.visible)
         continue;

      text += "\r\n";
      text += "widget_id=" + card.widget_id + "\r\n";
      text += "title=" + DashboardSanitizeSnapshotLine(card.title) + "\r\n";
      text += "dominant_state=" + DashboardSanitizeSnapshotLine(card.dominant_state_id) + "\r\n";
      text += "severity=" + DashboardSeverityText(card.severity_class) + "\r\n";
      text += "authority_badge=" + DashboardSanitizeSnapshotLine(card.authority_badge) + "\r\n";
      text += "source_badge=" + DashboardSanitizeSnapshotLine(card.source_badge) + "\r\n";
      text += "freshness_badge=" + DashboardSanitizeSnapshotLine(card.freshness_badge) + "\r\n";

      if(StringLen(card.state_badge) > 0)
         text += "state_badge=" + DashboardSanitizeSnapshotLine(card.state_badge) + "\r\n";
      if(StringLen(card.placeholder_badge) > 0)
         text += "placeholder_badge=" + DashboardSanitizeSnapshotLine(card.placeholder_badge) + "\r\n";

      if(StringLen(card.line1) > 0) text += "line1=" + DashboardSanitizeSnapshotLine(card.line1) + "\r\n";
      if(StringLen(card.line2) > 0) text += "line2=" + DashboardSanitizeSnapshotLine(card.line2) + "\r\n";
      if(StringLen(card.line3) > 0) text += "line3=" + DashboardSanitizeSnapshotLine(card.line3) + "\r\n";
      if(StringLen(card.line4) > 0) text += "line4=" + DashboardSanitizeSnapshotLine(card.line4) + "\r\n";
      if(StringLen(card.line5) > 0) text += "line5=" + DashboardSanitizeSnapshotLine(card.line5) + "\r\n";
      if(StringLen(card.line6) > 0) text += "line6=" + DashboardSanitizeSnapshotLine(card.line6) + "\r\n";
      if(StringLen(card.note) > 0)  text += "note=" + DashboardSanitizeSnapshotLine(card.note) + "\r\n";
   }

   text += "\r\nsnapshot_limitations=internal-only|sanitized|non-authoritative|derived|visibility-only\r\n";
   text += "snapshot_forbidden_content=secrets|credentials|raw_internal_memory_refs|sensitive_raw_paths|investor_framing|authority_inflating_claims\r\n";
   return text;
}

bool DashboardExportVisibleSnapshot(const DashboardPageModel &page, string &out_runtime_path, string &out_status)
{
   string token = DashboardSnapshotTimestampToken();
   string runtime_path = "AI\\dashboard_visible_snapshot_" + token + ".txt";
   string latest_path = "AI\\dashboard_visible_snapshot_latest.txt";
   string content = DashboardBuildVisibleSummary(page);

   if(!DashboardWriteTextFile(runtime_path, content))
   {
      out_runtime_path = "";
      out_status = "Snapshot export failed.";
      return false;
   }

   DashboardWriteTextFile(latest_path, content);
   out_runtime_path = runtime_path;
   out_status = "Snapshot exported: " + runtime_path;
   return true;
}

#endif
