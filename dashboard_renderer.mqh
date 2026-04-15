#ifndef __DASHBOARD_RENDERER_MQH__
#define __DASHBOARD_RENDERER_MQH__

#include "dashboard_navigation_controller.mqh"

enum DashboardRenderPhase
{
   DASHBOARD_RENDER_PHASE0_NO_RENDERING = 0,
   DASHBOARD_RENDER_PHASE1_READ_ONLY_ACTIVE
};

struct DashboardRendererContract
{
   DashboardRenderPhase render_phase;
   bool chart_objects_allowed;
   bool control_actions_allowed;
   string non_goal_note;
};

bool g_dashboard_phase1_active = false;
datetime g_dashboard_last_render_cycle = 0;

DashboardRendererContract DashboardGetRendererContract()
{
   DashboardRendererContract contract;
   contract.render_phase = DASHBOARD_RENDER_PHASE1_READ_ONLY_ACTIVE;
   contract.chart_objects_allowed = true;
   contract.control_actions_allowed = false;
   contract.non_goal_note = "Phase 1 renders read-only visibility only and does not mutate runtime behavior.";
   return contract;
}

color DashboardColorForSeverity(DashboardSeverityClass severity)
{
   switch(severity)
   {
      case DASHBOARD_SEVERITY_INFO:     return clrAliceBlue;
      case DASHBOARD_SEVERITY_NOTICE:   return clrSilver;
      case DASHBOARD_SEVERITY_CAUTION:  return clrKhaki;
      case DASHBOARD_SEVERITY_WARNING:  return clrOrange;
      case DASHBOARD_SEVERITY_CRITICAL: return clrTomato;
   }
   return clrSilver;
}

color DashboardTextColorForSeverity(DashboardSeverityClass severity)
{
   switch(severity)
   {
      case DASHBOARD_SEVERITY_CRITICAL: return clrMaroon;
      case DASHBOARD_SEVERITY_WARNING:  return clrDarkOrange;
      default:                          return clrBlack;
   }
}

void DashboardDeleteObjects()
{
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string object_name = ObjectName(0, i);
      if(StringFind(object_name, DASHBOARD_OBJECT_PREFIX) == 0)
         ObjectDelete(0, object_name);
   }
}

void DashboardApplyCommonObjectStyle(const string name)
{
   ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, 0);
}

void DashboardDrawRectangle(const string name, int x, int y, int w, int h, color bg, color border)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
   DashboardApplyCommonObjectStyle(name);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, border);
}

void DashboardDrawLabel(const string name, int x, int y, const string text, int font_size, color text_color, const string font_name = "Arial")
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
   DashboardApplyCommonObjectStyle(name);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, font_size);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetString(0, name, OBJPROP_FONT, font_name);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

void DashboardDrawButton(const string name, int x, int y, int w, int h, const string text, color bg, color text_color)
{
   if(ObjectFind(0, name) >= 0)
      ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
   DashboardApplyCommonObjectStyle(name);
   ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
   ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   ObjectSetInteger(0, name, OBJPROP_COLOR, text_color);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 8);
   ObjectSetString(0, name, OBJPROP_TEXT, text);
}

bool DashboardCardVisibleByFilters(const DashboardCardModel &card)
{
   if(!DashboardPassesSeverityFilter(card, g_dashboard_ui.severity_filter))
      return false;
   if(!DashboardPassesPanelFilter(card, g_dashboard_ui.panel_filter))
      return false;
   if(!DashboardPassesStateClassFilter(card, g_dashboard_ui.state_class_filter))
      return false;
   if(!g_dashboard_ui.show_transitional_warnings && card.state_class == DASHBOARD_STATE_CLASS_PLACEHOLDER_OR_TRANSITIONAL)
      return false;
   return true;
}

int DashboardClamp(const int value, const int min_value, const int max_value)
{
   if(value < min_value)
      return min_value;
   if(value > max_value)
      return max_value;
   return value;
}

int DashboardWrapTextLines(const string raw_text, const int max_chars_per_line, const int max_lines, string &out_lines[])
{
   ArrayResize(out_lines, 0);
   string remaining = TrimString(raw_text);
   if(StringLen(remaining) == 0 || max_chars_per_line <= 0 || max_lines <= 0)
      return 0;

   int count = 0;
   while(StringLen(remaining) > 0 && count < max_lines)
   {
      string piece = remaining;
      if(StringLen(piece) > max_chars_per_line)
      {
         int split_at = max_chars_per_line;
         while(split_at > 12)
         {
            if(StringGetCharacter(piece, split_at - 1) == 32)
               break;
            split_at--;
         }
         if(split_at <= 12)
            split_at = max_chars_per_line;

         piece = TrimString(StringSubstr(remaining, 0, split_at));
         remaining = TrimString(StringSubstr(remaining, split_at));
      }
      else
      {
         remaining = "";
      }

      if(count == max_lines - 1 && StringLen(remaining) > 0)
      {
         if(StringLen(piece) > max_chars_per_line - 3)
            piece = TrimString(StringSubstr(piece, 0, max_chars_per_line - 3));
         piece += "...";
         remaining = "";
      }

      int new_size = count + 1;
      ArrayResize(out_lines, new_size);
      out_lines[count] = piece;
      count++;
   }

   return count;
}

int DashboardDrawWrappedLabel(const string prefix, int x, int y, const string text, const int max_chars_per_line, const int max_lines, const int font_size, color text_color)
{
   string lines[];
   int count = DashboardWrapTextLines(text, max_chars_per_line, max_lines, lines);
   int step = font_size + 5;
   for(int i = 0; i < count; i++)
      DashboardDrawLabel(prefix + "_" + IntegerToString(i), x, y + (i * step), lines[i], font_size, text_color);
   return count * step;
}

string DashboardLastRefreshLabel()
{
   if(g_dashboard_last_render_cycle > 0)
      return TimeToString(g_dashboard_last_render_cycle, TIME_DATE | TIME_SECONDS);
   return "unavailable";
}

int DashboardVisibleCardCount(const DashboardPageModel &page)
{
   int count = 0;
   for(int i = 0; i < page.card_count; i++)
   {
      if(DashboardCardVisibleByFilters(page.cards[i]))
         count++;
   }
   return count;
}

void DashboardDrawBadgeRow(const string prefix, int x, int y, const DashboardCardModel &card, const bool compact_mode)
{
   string badge_text = card.authority_badge + " | " + card.source_badge + " | " + card.freshness_badge;
   if(StringLen(card.state_badge) > 0)
      badge_text += " | " + card.state_badge;
   if(StringLen(card.placeholder_badge) > 0)
      badge_text += " | " + card.placeholder_badge;

   DashboardDrawWrappedLabel(prefix + "_badges", x, y, badge_text, (compact_mode ? 86 : 78), (compact_mode ? 1 : 2), 8, clrDimGray);
}

int DashboardDrawCard(const string prefix, int x, int y, int w, const DashboardCardModel &card)
{
   if(!DashboardCardVisibleByFilters(card))
      return 0;

   bool compact_mode = (g_dashboard_ui.compact_view_enabled && !g_dashboard_ui.show_advanced_details);
   int inner_x = x + 10;
   int detail_limit = (compact_mode ? 2 : 6);
   if(g_dashboard_ui.collapsed_panels)
      detail_limit = 0;

   string detail_lines[6];
   detail_lines[0] = card.line1;
   detail_lines[1] = card.line2;
   detail_lines[2] = card.line3;
   detail_lines[3] = card.line4;
   detail_lines[4] = card.line5;
   detail_lines[5] = card.line6;

   int h = 20;
   string tmp_lines[];

   int title_count = DashboardWrapTextLines(card.title, (compact_mode ? 52 : 42), 2, tmp_lines);
   if(title_count <= 0) title_count = 1;
   int state_count = DashboardWrapTextLines(card.dominant_state_id + " - " + DashboardSeverityText(card.severity_class), (compact_mode ? 58 : 48), 2, tmp_lines);
   if(state_count <= 0) state_count = 1;

   string badge_text = card.authority_badge + " | " + card.source_badge + " | " + card.freshness_badge;
   if(StringLen(card.state_badge) > 0)
      badge_text += " | " + card.state_badge;
   if(StringLen(card.placeholder_badge) > 0)
      badge_text += " | " + card.placeholder_badge;
   int badge_count = DashboardWrapTextLines(badge_text, (compact_mode ? 86 : 78), (compact_mode ? 1 : 2), tmp_lines);
   if(badge_count <= 0) badge_count = 1;

   h += title_count * 14;
   h += state_count * 13;
   h += badge_count * 13;

   int drawn_details = 0;
   for(int i = 0; i < 6; i++)
   {
      if(StringLen(detail_lines[i]) == 0)
         continue;
      if(drawn_details >= detail_limit)
         break;

      int line_count = DashboardWrapTextLines(detail_lines[i], (compact_mode ? 88 : 84), (compact_mode ? 1 : 2), tmp_lines);
      if(line_count <= 0)
         line_count = 1;
      h += line_count * 12;
      drawn_details++;
   }

   bool show_note = (!g_dashboard_ui.collapsed_panels && (!compact_mode || g_dashboard_ui.show_advanced_details));
   if(show_note && StringLen(card.note) > 0)
   {
      int note_count = DashboardWrapTextLines(card.note, 84, 2, tmp_lines);
      if(note_count <= 0) note_count = 1;
      h += note_count * 12;
      h += 4;
   }

   if(card.mixed_plane_warning_required && g_dashboard_ui.show_transitional_warnings && !g_dashboard_ui.collapsed_panels)
      h += (compact_mode ? 14 : 18);

   h = DashboardClamp(h, (g_dashboard_ui.collapsed_panels ? 76 : (compact_mode ? 108 : 138)), (compact_mode ? 180 : 236));

   DashboardDrawRectangle(prefix + "_bg", x, y, w, h, clrWhiteSmoke, DashboardColorForSeverity(card.severity_class));

   int cursor_y = y + 10;
   cursor_y += DashboardDrawWrappedLabel(prefix + "_title", inner_x, cursor_y, card.title, (compact_mode ? 52 : 42), 2, 10, clrBlack);
   cursor_y += 1;
   cursor_y += DashboardDrawWrappedLabel(prefix + "_state", inner_x, cursor_y, card.dominant_state_id + " - " + DashboardSeverityText(card.severity_class), (compact_mode ? 58 : 48), 2, 9, DashboardTextColorForSeverity(card.severity_class));
   cursor_y += 2;
   DashboardDrawBadgeRow(prefix, inner_x, cursor_y, card, compact_mode);
   cursor_y += (compact_mode ? 14 : 24);

   if(!g_dashboard_ui.collapsed_panels)
   {
      drawn_details = 0;
      for(int i = 0; i < 6; i++)
      {
         if(StringLen(detail_lines[i]) == 0)
            continue;
         if(drawn_details >= detail_limit)
            break;
         int used = DashboardDrawWrappedLabel(prefix + "_l" + IntegerToString(i + 1), inner_x, cursor_y, detail_lines[i], (compact_mode ? 88 : 84), (compact_mode ? 1 : 2), 8, clrBlack);
         cursor_y += (used > 0 ? used : 12);
         drawn_details++;
      }

      if(card.mixed_plane_warning_required && g_dashboard_ui.show_transitional_warnings)
      {
         DashboardDrawWrappedLabel(prefix + "_mix", inner_x, cursor_y, (compact_mode ?
            "Mixed-plane summary only. Check badges." :
            "Mixed-plane summary only. Check authority, source, freshness, and placeholder badges."),
            (compact_mode ? 88 : 82), (compact_mode ? 1 : 2), 8, clrDarkGoldenrod);
         cursor_y += (compact_mode ? 14 : 18);
      }

      if(show_note && StringLen(card.note) > 0)
         DashboardDrawWrappedLabel(prefix + "_note", inner_x, y + h - 26, card.note, 84, 2, 8, clrDimGray);
   }

   return h + 10;
}

void DashboardDrawNavigation(int panel_x, int panel_y, int nav_w, int panel_h)
{
   DashboardDrawRectangle("AIDASH_NAV_BG", panel_x, panel_y, nav_w, panel_h, C'34,38,44', C'78,86,96');
   DashboardDrawLabel("AIDASH_NAV_TITLE", panel_x + 6, panel_y + 8, (nav_w <= 80 ? "NAV" : "Pages"), 8, clrWhiteSmoke);

   int y = panel_y + 24;
   for(int i = 0; i < ArraySize(g_dashboard_page_defs); i++)
   {
      color bg = (i == g_dashboard_ui.current_page_index ? C'74,116,168' : C'58,66,76');
      string txt = g_dashboard_page_defs[i].title;
      if(nav_w <= 80)
         txt = IntegerToString(i + 1);
      DashboardDrawButton(DashboardButtonPageId(i), panel_x + 4, y, nav_w - 8, 20, txt, bg, clrWhiteSmoke);
      y += 22;
      if(y > panel_y + panel_h - 50)
         break;
   }

   DashboardDrawButton("AIDASH_BTN_REFRESH", panel_x + 4, panel_y + panel_h - 44, nav_w - 8, 18, (nav_w <= 80 ? "R" : "Refresh"), C'58,66,76', clrWhiteSmoke);
   DashboardDrawButton("AIDASH_BTN_CLOSE_PANEL", panel_x + 4, panel_y + panel_h - 22, nav_w - 8, 18, (nav_w <= 80 ? "X" : "Close"), C'58,66,76', clrWhiteSmoke);
}

int DashboardDrawActionRow(int x, int y, int content_w)
{
   int bh = 22;
   int gap = 6;
   int col = x;

   DashboardDrawButton("AIDASH_BTN_REFRESH", col, y, 84, bh, "Refresh", clrWhiteSmoke, clrBlack); col += 90;
   DashboardDrawButton("AIDASH_BTN_SNAPSHOT", col, y, 104, bh, "Export Report", clrWhiteSmoke, clrBlack); col += 110;
   DashboardDrawButton("AIDASH_BTN_MINIMIZE", col, y, 104, bh, (DashboardIsMinimizedFootprint() ? "Restore Size" : "Minimize Size"), clrWhiteSmoke, clrBlack); col += 110;
   DashboardDrawButton("AIDASH_BTN_COMPACT", col, y, 96, bh, (g_dashboard_ui.compact_view_enabled ? "Full View" : "Compact View"), clrWhiteSmoke, clrBlack); col += 102;
   DashboardDrawButton("AIDASH_BTN_AUTO", col, y, 82, bh, DashboardAutoRefreshButtonText(), clrWhiteSmoke, clrBlack); col += 88;
   DashboardDrawButton("AIDASH_BTN_VIEW_OPTIONS", col, y, 112, bh, DashboardViewOptionsButtonText(), clrWhiteSmoke, clrBlack); col += 118;
   DashboardDrawButton("AIDASH_BTN_RESET", col, y, 86, bh, "Reset View", clrWhiteSmoke, clrBlack);

   int used_h = bh;
   if(g_dashboard_ui.view_options_expanded)
   {
      int box_y = y + bh + 8;
      int box_h = 62;
      DashboardDrawRectangle("AIDASH_VIEW_OPTIONS_BG", x, box_y, content_w, box_h, clrWhiteSmoke, clrSilver);
      DashboardDrawWrappedLabel("AIDASH_VIEW_OPTIONS_TITLE", x + 8, box_y + 6, "View Options - local only", 44, 1, 8, clrDimGray);

      int row1_y = box_y + 22;
      int row2_y = row1_y + 24;
      int c1 = x + 8;

      DashboardDrawButton("AIDASH_BTN_RELOAD", c1, row1_y, 82, bh, "Reload", clrWhiteSmoke, clrBlack); c1 += 88;
      DashboardDrawButton("AIDASH_BTN_COLLAPSE", c1, row1_y, 108, bh, (g_dashboard_ui.collapsed_panels ? "Expand Panels" : "Collapse Panels"), clrWhiteSmoke, clrBlack); c1 += 114;
      DashboardDrawButton("AIDASH_BTN_ADVANCED", c1, row1_y, 112, bh, (g_dashboard_ui.show_advanced_details ? "Details:On" : "Details:Bounded"), clrWhiteSmoke, clrBlack); c1 += 118;
      DashboardDrawButton("AIDASH_BTN_RESYNC", c1, row1_y, 92, bh, "Re-sync", clrWhiteSmoke, clrBlack);

      c1 = x + 8;
      DashboardDrawButton("AIDASH_BTN_SEVERITY", c1, row2_y, 108, bh, DashboardFilterToolbarSeverityText(), clrWhiteSmoke, clrBlack); c1 += 114;
      DashboardDrawButton("AIDASH_BTN_PANEL", c1, row2_y, 98, bh, DashboardFilterToolbarPanelText(), clrWhiteSmoke, clrBlack); c1 += 104;
      DashboardDrawButton("AIDASH_BTN_CLASS", c1, row2_y, 118, bh, DashboardFilterToolbarClassText(), clrWhiteSmoke, clrBlack); c1 += 124;
      DashboardDrawButton("AIDASH_BTN_TRANSITION", c1, row2_y, 122, bh, (g_dashboard_ui.show_transitional_warnings ? "Warnings:Shown" : "Warnings:Hidden"), clrWhiteSmoke, clrBlack); c1 += 128;
      DashboardDrawButton("AIDASH_BTN_PREV", c1, row2_y, 56, bh, "Prev", clrWhiteSmoke, clrBlack); c1 += 62;
      DashboardDrawButton("AIDASH_BTN_NEXT", c1, row2_y, 56, bh, "Next", clrWhiteSmoke, clrBlack);

      used_h += 70;
   }

   return used_h;
}

int DashboardDrawHeader(const DashboardPageModel &page, int x, int y, int w)
{
   DashboardDrawWrappedLabel("AIDASH_TITLE", x, y, "Expanded Read-Only Operational / Governance Dashboard", 64, 2, 12, clrBlack);
   DashboardDrawWrappedLabel("AIDASH_SUBTITLE", x, y + 22, page.title + " - " + page.subtitle, 88, (g_dashboard_ui.compact_view_enabled ? 1 : 2), 9, clrDimGray);
   DashboardDrawRectangle("AIDASH_POSTURE_BG", x, y + 44, w, 28, clrWhiteSmoke, DashboardColorForSeverity(page.posture_severity));
   DashboardDrawWrappedLabel("AIDASH_POSTURE", x + 8, y + 50, "Top posture: " + page.posture_banner_text, 90, 2, 10, DashboardTextColorForSeverity(page.posture_severity));
   DashboardDrawWrappedLabel("AIDASH_REFRESH", x + 8, y + 78, DashboardAutoRefreshStatusLabel() + " | Last refresh: " + DashboardLastRefreshLabel(), 92, 1, 8, clrDimGray);
   DashboardDrawWrappedLabel("AIDASH_FILTERS", x + 8, y + 94, "Local filters: " + DashboardActiveFilterSummary(), 92, 1, 8, clrDimGray);
   DashboardDrawWrappedLabel("AIDASH_LAYOUT", x + 8, y + 110, DashboardLayoutSummary(), 92, 1, 8, clrDimGray);
   DashboardDrawWrappedLabel("AIDASH_WATERMARK", x + 8, y + 126, DASHBOARD_INTERNAL_WATERMARK, 90, 1, 8, clrDarkSlateGray);
   return 138;
}

int DashboardDrawAlertBanner(int x, int y, int w)
{
   if(g_dashboard_ui.alert_dismissed || StringLen(g_dashboard_ui.local_alert_text) == 0)
      return 0;

   int h = (g_dashboard_ui.compact_view_enabled ? 30 : 34);
   DashboardDrawRectangle("AIDASH_ALERT_BG", x, y, w, h, clrLavenderBlush, clrOrange);
   DashboardDrawWrappedLabel("AIDASH_ALERT_TEXT", x + 8, y + 6,
                             DashboardShortText(g_dashboard_ui.local_alert_text, (g_dashboard_ui.compact_view_enabled ? 110 : 180)),
                             (g_dashboard_ui.compact_view_enabled ? 96 : 88), (g_dashboard_ui.compact_view_enabled ? 1 : 2), 8, clrBlack);
   DashboardDrawButton("AIDASH_BTN_DISMISS", x + w - 74, y + 5, 68, 20, "Dismiss", clrWhiteSmoke, clrBlack);
   return h + 6;
}

int DashboardDrawMixedPlaneWarning(int x, int y, int w)
{
   int h = (g_dashboard_ui.compact_view_enabled ? 26 : 34);
   DashboardDrawRectangle("AIDASH_MIX_BG", x, y, w, h, clrLemonChiffon, clrGoldenrod);
   DashboardDrawWrappedLabel("AIDASH_MIX_TEXT", x + 8, y + 6,
                             (g_dashboard_ui.compact_view_enabled ?
                              "Mixed-plane summary only. Check badges before inferring posture." :
                              "Mixed-plane summary only. Use authority, source, freshness, and placeholder badges before inferring runtime posture."),
                             (g_dashboard_ui.compact_view_enabled ? 94 : 84), (g_dashboard_ui.compact_view_enabled ? 1 : 2), 8, clrBlack);
   return h + 6;
}

void DashboardDrawEmptyState(const DashboardPageModel &page, int x, int y, int w)
{
   DashboardDrawRectangle("AIDASH_EMPTY_BG", x, y, w, 68, clrWhiteSmoke, clrSilver);
   string title = "No panels are currently visible on this page.";
   string body = "Local filters may be excluding every panel. Use Reset View or View Options to review the current local filters. Current filters: " + DashboardActiveFilterSummary();
   if(!DashboardAnyLocalFilterActive())
      body = "No visible panels were produced from the current bounded page model. Review source and freshness badges after reload.";

   DashboardDrawWrappedLabel("AIDASH_EMPTY_TITLE", x + 8, y + 8, title, 88, 1, 9, clrBlack);
   DashboardDrawWrappedLabel("AIDASH_EMPTY_BODY", x + 8, y + 24, body, 86, 3, 8, clrDimGray);
}

void DashboardDrawMinimizedView(const DashboardPageModel &page, int outer_x, int outer_y, int panel_w, int panel_h)
{
   DashboardDrawRectangle("AIDASH_MIN_BG", outer_x, outer_y, panel_w, panel_h, C'22,26,31', C'64,72,82');
   DashboardDrawNavigation(outer_x + 2, outer_y + 2, panel_w - 4, panel_h - 4);

   string hint = "Sidebar active (" + page.title + ")";
   DashboardDrawWrappedLabel("AIDASH_MIN_HINT", outer_x + panel_w + 8, outer_y + 8, hint, 48, 1, 8, clrDimGray);
}

void DashboardRenderCurrentPage()
{
   DashboardEnsureUIInitialized();
   DashboardProcessPendingActions();

   DashboardPageModel page;
   if(!DashboardGetPageModel(g_dashboard_ui.current_page_index, page))
      return;

   DashboardDeleteObjects();

   int chart_w = (int)ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0);
   int chart_h = (int)ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0);

   int outer_x = 4;
   int outer_y = 6;
   bool minimized_view = DashboardIsMinimizedFootprint();

   int panel_w = (g_dashboard_ui.compact_view_enabled ? 900 : 980);
   if(minimized_view)
      panel_w = 76;
   if(panel_w > chart_w - 8)
      panel_w = chart_w - 8;
   if(!minimized_view && panel_w < 620)
      panel_w = chart_w - 8;
   if(minimized_view && panel_w < 60)
      panel_w = 60;

   int panel_h = chart_h - 12;
   if(minimized_view)
   {
      if(panel_h > 760)
         panel_h = 760;
      if(panel_h < 240)
         panel_h = chart_h - 12;
   }
   else
   {
      if(panel_h > 700)
         panel_h = 700;
      if(panel_h < 520)
         panel_h = chart_h - 12;
   }

   if(minimized_view)
   {
      DashboardDrawMinimizedView(page, outer_x, outer_y, panel_w, panel_h);
      ChartRedraw(0);
      g_dashboard_render_requested = false;
      g_dashboard_last_render_cycle = TimeCurrent();
      return;
   }

   int nav_w = g_dashboard_ui.compact_view_enabled ? 92 : 110;
   int content_x = outer_x + nav_w + 8;
   int content_w = panel_w - nav_w - 16;

   DashboardDrawRectangle("AIDASH_OUTER_BG", outer_x, outer_y, panel_w, panel_h, clrGhostWhite, clrSilver);
   DashboardDrawNavigation(outer_x + 4, outer_y + 4, nav_w, panel_h - 8);

   int header_h = DashboardDrawHeader(page, content_x, outer_y + 8, content_w - 8);
   int action_y = outer_y + 8 + header_h + 6;
   int action_h = DashboardDrawActionRow(content_x, action_y, content_w - 8);

   int cursor_y = action_y + action_h + 10;
   cursor_y += DashboardDrawAlertBanner(content_x, cursor_y, content_w - 8);

   if(page.mixed_plane_warning_required && g_dashboard_ui.show_transitional_warnings)
      cursor_y += DashboardDrawMixedPlaneWarning(content_x, cursor_y, content_w - 8);

   int rendered_cards = 0;
   for(int i = 0; i < page.card_count; i++)
   {
      int used_h = DashboardDrawCard("AIDASH_CARD_" + IntegerToString(i), content_x, cursor_y, content_w - 8, page.cards[i]);
      if(used_h > 0)
      {
         cursor_y += used_h;
         rendered_cards++;
      }
   }

   if(rendered_cards == 0)
      DashboardDrawEmptyState(page, content_x, cursor_y + 8, content_w - 8);

   int non_goal_h = (g_dashboard_ui.compact_view_enabled ? 30 : 40);
   DashboardDrawRectangle("AIDASH_NON_GOAL_BG", content_x, outer_y + panel_h - (non_goal_h + 12), content_w - 8, non_goal_h, clrWhiteSmoke, clrSilver);
   DashboardDrawWrappedLabel("AIDASH_NON_GOAL", content_x + 8, outer_y + panel_h - (non_goal_h + 6),
                             "What this page does not mean: " + page.non_goal,
                             (g_dashboard_ui.compact_view_enabled ? 96 : 86),
                             (g_dashboard_ui.compact_view_enabled ? 1 : 2),
                             8, clrDimGray);

   ChartRedraw(0);
   g_dashboard_render_requested = false;
   g_dashboard_last_render_cycle = TimeCurrent();
}

void DashboardRemoveAllRendering()
{
   DashboardDeleteObjects();
   ChartRedraw(0);
}

void DashboardPhase1Initialize()
{
   DashboardEnsureUIInitialized();
   DashboardCollectorPoll(true, true);
   DashboardBuildAllPages();
   g_dashboard_phase1_active = true;
   g_dashboard_render_requested = true;
   g_dashboard_page_entry_requested = false;
   DashboardPersistLocalUIState();
}

void DashboardPhase1Shutdown()
{
   g_dashboard_phase1_active = false;
   DashboardPersistLocalUIState();
   DashboardRemoveAllRendering();
}

bool DashboardAutoRefreshDue()
{
   if(!g_dashboard_ui.auto_refresh_enabled)
      return false;
   if(g_dashboard_last_render_cycle <= 0)
      return true;
   return ((TimeCurrent() - g_dashboard_last_render_cycle) >= g_dashboard_ui.auto_refresh_interval_seconds);
}

void DashboardPhase1OnTimer()
{
   if(!g_dashboard_phase1_active)
      return;

   bool due = DashboardAutoRefreshDue();
   if(g_dashboard_render_requested || g_dashboard_force_reload_requested || g_dashboard_page_entry_requested || due)
      DashboardRenderCurrentPage();
}

void DashboardPhase1OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(!g_dashboard_phase1_active)
      return;

   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      DashboardHandleChartClick(sparam);
      DashboardRenderCurrentPage();
   }
}

#endif
