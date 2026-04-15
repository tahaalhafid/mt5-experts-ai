#ifndef __DASHBOARD_CONTRACT_MQH__
#define __DASHBOARD_CONTRACT_MQH__

#define DASHBOARD_PHASE0_CONTRACT_VERSION "MT5_DASHBOARD_PHASE0_CONTRACT_V1"
#define DASHBOARD_INTERNAL_WATERMARK "INTERNAL OPERATIONAL VIEW — NON-EXPORT SAFE"
#define DASHBOARD_OBJECT_PREFIX "AIDASH_"
#define DASHBOARD_TIMER_SECONDS 1
#define DASHBOARD_MAX_PAGES 10
#define DASHBOARD_MAX_SOURCES 30
#define DASHBOARD_MAX_CARDS_PER_PAGE 4
#define DASHBOARD_MAX_DETAIL_LINES 6
#define DASHBOARD_NORMAL_POLL_SECONDS 5
#define DASHBOARD_SLOW_POLL_SECONDS 20
#define DASHBOARD_PAGE_ENTRY_SECONDS 60
#define DASHBOARD_STALE_BOOT_ONLY_SECONDS 86400
#define DASHBOARD_STALE_SLOW_POLL_SECONDS 1800
#define DASHBOARD_STALE_NORMAL_POLL_SECONDS 600
#define DASHBOARD_STALE_PAGE_ENTRY_SECONDS 3600
#define DASHBOARD_STALE_ON_DEMAND_SECONDS 3600
#define DASHBOARD_AUTO_REFRESH_DEFAULT_SECONDS 6

enum DashboardPageId
{
   DASHBOARD_PAGE_SYSTEM_POSTURE_OVERVIEW = 0,
   DASHBOARD_PAGE_RUNTIME_GOVERNANCE,
   DASHBOARD_PAGE_AI_AUTHORITY_READINESS,
   DASHBOARD_PAGE_AI_ADVISORY_REVIEW_GOVERNANCE,
   DASHBOARD_PAGE_FACTORY_STATE,
   DASHBOARD_PAGE_TRANSFER_PILOT_COHORT,
   DASHBOARD_PAGE_EXPORT_RELEASE_GATE,
   DASHBOARD_PAGE_STARTUP_DIAGNOSTICS,
   DASHBOARD_PAGE_ALERTS_REASONS_HOLDS,
   DASHBOARD_PAGE_MARKET_OPERATIONAL_CONTEXT
};

enum DashboardStateClass
{
   DASHBOARD_STATE_CLASS_AUTHORITATIVE = 0,
   DASHBOARD_STATE_CLASS_DERIVED,
   DASHBOARD_STATE_CLASS_PLACEHOLDER_OR_TRANSITIONAL
};

enum DashboardSeverityClass
{
   DASHBOARD_SEVERITY_INFO = 0,
   DASHBOARD_SEVERITY_NOTICE,
   DASHBOARD_SEVERITY_CAUTION,
   DASHBOARD_SEVERITY_WARNING,
   DASHBOARD_SEVERITY_CRITICAL
};

enum DashboardRefreshClass
{
   DASHBOARD_REFRESH_BOOT_ONLY = 0,
   DASHBOARD_REFRESH_SLOW_POLL,
   DASHBOARD_REFRESH_NORMAL_POLL,
   DASHBOARD_REFRESH_ON_DEMAND,
   DASHBOARD_REFRESH_PAGE_ENTRY_ONLY
};

enum DashboardButtonState
{
   DASHBOARD_BUTTON_ENABLED = 0,
   DASHBOARD_BUTTON_DISABLED,
   DASHBOARD_BUTTON_VIEW_ONLY,
   DASHBOARD_BUTTON_LOCKED_WITH_REASON,
   DASHBOARD_BUTTON_HIDDEN,
   DASHBOARD_BUTTON_REQUEST_AVAILABLE,
   DASHBOARD_BUTTON_REQUEST_PENDING,
   DASHBOARD_BUTTON_REQUEST_REJECTED,
   DASHBOARD_BUTTON_REQUEST_ACCEPTED_NOT_APPLIED,
   DASHBOARD_BUTTON_NOT_IMPLEMENTED_RESERVED
};

enum DashboardSourceTier
{
   DASHBOARD_SOURCE_TIER_A_PRIMARY_VISIBILITY = 0,
   DASHBOARD_SOURCE_TIER_B_STRUCTURAL_STATUS,
   DASHBOARD_SOURCE_TIER_C_CONTEXTUAL_OPTIONAL,
   DASHBOARD_SOURCE_TIER_D_NEVER_RENDER_DIRECTLY
};

struct DashboardPageDefinition
{
   string id;
   string title;
   string purpose;
   string non_goal;
};

struct DashboardWidgetContract
{
   string widget_id;
   string page_id;
   string source_ids_csv;
   string field_list_csv;
   string required_badges_csv;
   DashboardRefreshClass refresh_class;
   int rendering_priority;
};

struct DashboardSourceDefinition
{
   string source_id;
   string display_path;
   string runtime_path;
   DashboardSourceTier tier;
   string authority_type;
   bool direct_render_allowed;
   DashboardRefreshClass refresh_class;
   string bounded_usage_note;
};

struct DashboardCollectedSourceState
{
   string source_id;
   string display_path;
   string runtime_path;
   DashboardSourceTier tier;
   DashboardRefreshClass refresh_class;
   string authority_type;
   bool direct_render_allowed;

   bool source_present;
   bool parse_ok;
   bool partial;
   bool placeholder_only;
   bool zero_record;
   bool mixed_plane;
   bool stale;
   bool runtime_file_allowed;

   string timestamp_value;
   datetime timestamp_epoch;
   datetime last_poll_time;

   string raw_text;
   string fallback_text;
   string summary_text;
   string reason_text;
};

struct DashboardCardModel
{
   string widget_id;
   string title;
   string dominant_state_id;
   DashboardStateClass state_class;
   DashboardSeverityClass severity_class;
   string authority_badge;
   string source_badge;
   string freshness_badge;
   string state_badge;
   string placeholder_badge;
   bool mixed_plane_warning_required;
   int rendering_priority;
   bool visible;

   string line1;
   string line2;
   string line3;
   string line4;
   string line5;
   string line6;
   string note;
};

struct DashboardPageModel
{
   string page_id;
   string title;
   string subtitle;
   string non_goal;
   string posture_banner_text;
   DashboardSeverityClass posture_severity;
   bool mixed_plane_warning_required;
   DashboardCardModel cards[DASHBOARD_MAX_CARDS_PER_PAGE];
   int card_count;
};

struct DashboardLocalUIState
{
   bool dashboard_visible;
   int current_page_index;
   string current_page_id;
   bool compact_view_enabled;
   bool collapsed_panels;
   bool show_transitional_warnings;
   bool show_advanced_details;
   bool auto_refresh_enabled;
   int auto_refresh_interval_seconds;
   bool view_options_expanded;
   string severity_filter;
   string panel_filter;
   string state_class_filter;
   bool alert_dismissed;
   string last_resync_request_time;
   string last_snapshot_export_time;
   string local_alert_text;
};

struct DashboardButtonModel
{
   string button_id;
   string label;
   DashboardButtonState state;
   string tooltip;
};

#endif
