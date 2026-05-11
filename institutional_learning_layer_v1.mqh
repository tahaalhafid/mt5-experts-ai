#ifndef __INSTITUTIONAL_LEARNING_LAYER_V1_MQH__
#define __INSTITUTIONAL_LEARNING_LAYER_V1_MQH__

#include "config_loader.mqh"
#include "decision_mode_router.mqh"
#include "trade_feedback.mqh"
#include "unified_confidence.mqh"

//------------------------------------------------------------------------------
// L3 Institutional Self-Learning Layer v1
// - Bounded, deterministic, non-authoritative learning support
// - Evidence-driven memory + capped confidence/caution/context-fit shaping
// - No direct execution/risk/governor authority
//------------------------------------------------------------------------------

#define ILV1_MEMORY_PATH         "AI\\ai_institutional_learning_memory.json"
#define ILV1_STATUS_PATH         "AI\\ai_institutional_learning_status.json"
#define ILV1_STATUS_TXT_PATH     "AI\\ai_institutional_learning_status.txt"
#define ILV1_EVENTS_PATH         "AI\\ai_institutional_learning_events.jsonl"
#define ILV1_CONTEXT_PATH        "AI\\ai_institutional_learning_decision_context.jsonl"
#define ILV1_LINEAGE_PATH        "AI\\ai_institutional_learning_trade_lineage.jsonl"
#define ILV1_LINEAGE_STATUS_PATH "AI\\ai_institutional_learning_lineage_status.json"
#define ILV1_STRATEGY_EVENTS_PATH "AI\\ai_strategy_memory_events.jsonl"

#define ILV1_MIN_EVIDENCE_ANY        8
#define ILV1_MIN_EVIDENCE_STRENGTHEN 14
#define ILV1_MIN_EVIDENCE_PENALIZE   10
#define ILV1_CONFIDENCE_DELTA_CAP    0.08
#define ILV1_CAUTION_CAP             0.10
#define ILV1_EWMA_ALPHA              0.15

struct ILV1_DecisionContext
{
   bool     valid;
   datetime captured_at;
   string   decision_id;
   string   symbol;
   string   strategy_id;
   string   strategy_family;
   string   direction;
   string   regime_bucket;   // ERA / gRegime admission context
   string   zone_bucket;     // ExRA / council zone routing context
   string   volatility_bucket;
   string   structure_bucket;
   string   setup_quality_bucket;
   string   sr_interaction_bucket;
   string   support_resistance_confluence_state;
   string   canonical_level_state;
   bool     sr_confluence_flag;
   bool     sr_rejection_risk_flag;
   bool     sr_continuation_obstructed_flag;
   bool     sr_canonical_near_flag;
   bool     sr_conflicted_flag;
   bool     advisory_contradiction_flag;
   bool     advisory_hold_bias_active;
   double   advisory_relevance_score;
   string   advisory_reason_summary;
   string   decision_quality_label;
   string   entry_quality_label;
   string   entry_edge_label;
   string   follow_through_label;
   string   execution_geometry_label;
   double   expected_rr_estimate;
   string   motif_key;
};

struct ILV1_MotifStat
{
   bool     valid;
   string   motif_key;
   string   strategy_id;
   string   strategy_family;
   string   direction;
   string   regime_bucket;
   string   volatility_bucket;
   string   structure_bucket;
   string   setup_quality_bucket;
   string   sr_interaction_bucket;
   bool     advisory_contradiction_flag;
   int      evidence_count;
   int      win_count;
   int      loss_count;
   int      flat_count;
   double   net_edge_ewma;
   double   caution_ewma;
   double   context_fit_ewma;
   string   recent_outcomes;
   string   last_primary_attribution;
   string   last_secondary_attribution;
   string   last_reason_codes_csv;
   datetime last_updated;
};

struct ILV1_Adjustment
{
   bool     applied;
   string   state_code;
   string   reason_codes_csv;
   string   motif_key;
   int      evidence_count;
   double   confidence_delta;
   double   caution_score;
   double   context_fit_score;
   bool     contradiction_signal;
   bool     hold_bias;
   bool     reevaluation_bias;
   string   strength_band;
};

struct ILV1_RuntimeStatus
{
   string   artifact_role;
   string   artifact_authority_class;
   string   summary_version;
   string   trust_rule;
   string   update_source;
   bool     learning_enabled;
   bool     initialized;
   int      motif_count;
   int      total_events;
   string   state_code;
   string   reason_codes_csv;
   string   last_motif_key;
   int      last_evidence_count;
   double   last_confidence_delta;
   double   last_caution_score;
   double   last_context_fit_score;
   bool     last_contradiction_signal;
   bool     last_hold_bias;
   bool     last_reevaluation_bias;
   string   last_strength_band;
   string   non_authoritative_notice;
   datetime evaluated_at;
};

static ILV1_MotifStat gILV1Motifs[];
static bool           gILV1Initialized = false;
static int            gILV1TotalEvents = 0;
static int            gILV1LineageRecords = 0;
static int            gILV1LineageDegradedRecords = 0;
static ILV1_RuntimeStatus gILV1Status;

double ILV1_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}

double ILV1_Clamp01(double v) { return ILV1_Clamp(v, 0.0, 1.0); }

string ILV1_BoolText(bool v)
{
   return (v ? "true" : "false");
}

string ILV1_TimeText(datetime t)
{
   if(t <= 0) return "";
   return TimeToString(t, TIME_DATE | TIME_SECONDS);
}

string ILV1_EscapeJson(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", " ");
   StringReplace(s, "\n", " ");
   return s;
}

string ILV1_U64Text(ulong v)
{
   return (string)v;
}

bool ILV1_WriteText(string relPath, string txt)
{
   int h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileWriteString(h, txt);
   FileClose(h);
   return true;
}

bool ILV1_AppendLine(string relPath, string line)
{
   int h = FileOpen(relPath, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, line + "\n");
   FileClose(h);
   return true;
}

bool ILV1_ReadAllLines(string relPath, string &outLines[])
{
   ArrayResize(outLines, 0);
   int h = FileOpen(relPath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
   {
      string ln = TrimString(FileReadString(h));
      if(StringLen(ln) <= 0)
         continue;
      int n = ArraySize(outLines);
      ArrayResize(outLines, n + 1);
      outLines[n] = ln;
   }

   FileClose(h);
   return true;
}

void ILV1_TrimRecentOutcomes(string &s)
{
   const int maxLen = 40;
   int len = StringLen(s);
   if(len > maxLen)
      s = StringSubstr(s, len - maxLen, maxLen);
}

string ILV1_InferStrategyFamily(string strategy_id)
{
   if(strategy_id == "bollinger_reclaim") return "MEAN_RECLAIM";
   string s = TrimString(strategy_id);
   StringToLower(s);
   if(StringLen(s) <= 0) return "UNKNOWN";
   if(StringFind(s, "trend") >= 0 || StringFind(s, "momentum") >= 0) return "TREND_CONTINUATION";
   if(StringFind(s, "reversal") >= 0 || StringFind(s, "mean") >= 0) return "MEAN_RECLAIM";
   if(StringFind(s, "breakout") >= 0) return "BREAKOUT_CONTINUATION";
   if(StringFind(s, "sweep") >= 0 || StringFind(s, "liquidity") >= 0) return "LIQUIDITY_REVERSAL";
   return "UNKNOWN";
}

string ILV1_BucketSetupQuality(string decision_quality_label, string entry_edge_label, string follow_through_label)
{
   bool highDQ = (decision_quality_label == "HIGH_QUALITY_DECISION" || decision_quality_label == "GOOD_DECISION");
   bool lowDQ  = (decision_quality_label == "LOW_QUALITY_DECISION" || decision_quality_label == "BLOCK_WORTHY_DECISION");
   bool strongEdge = (entry_edge_label == "STRONG_ENTRY_EDGE" || entry_edge_label == "ADEQUATE_ENTRY_EDGE");
   bool weakEdge   = (entry_edge_label == "POOR_ENTRY_EDGE" || entry_edge_label == "NEGATIVE_ENTRY_EDGE");
   bool weakFT = (follow_through_label == "WEAK_FOLLOW_THROUGH" || follow_through_label == "COLLAPSING_FOLLOW_THROUGH");

   if(highDQ && strongEdge && !weakFT) return "SETUP_STRONG";
   if(lowDQ || weakEdge) return "SETUP_WEAK";
   if(weakFT) return "SETUP_FRAGILE";
   return "SETUP_NEUTRAL";
}

string ILV1_BucketSrInteraction(string sr_state)
{
   sr_state = TrimString(sr_state);
   if(StringLen(sr_state) <= 0) return "SR_UNKNOWN";
   if(StringFind(sr_state, "EXTERNAL_LEVEL_CONFLUENT") >= 0) return "SR_CONFLUENT";
   if(StringFind(sr_state, "EXTERNAL_LEVEL_CONFLICTED") >= 0) return "SR_CONFLICTED";
   if(StringFind(sr_state, "REJECTION_RISK_ELEVATED") >= 0) return "SR_REJECTION_RISK";
   if(StringFind(sr_state, "CONTINUATION_PATH_OBSTRUCTED") >= 0) return "SR_CONTINUATION_OBSTRUCTED";
   if(StringFind(sr_state, "REVERSAL_TRAP_RISK_ELEVATED") >= 0) return "SR_REVERSAL_TRAP";
   if(StringFind(sr_state, "CANONICAL_SUPPORT_NEAR") >= 0 || StringFind(sr_state, "CANONICAL_RESISTANCE_NEAR") >= 0) return "SR_CANONICAL_NEAR";
   return "SR_SEMANTIC";
}

bool ILV1_StateHasToken(string state, string token)
{
   return (StringFind(state, token) >= 0);
}

void ILV1_ApplySrFlags(ILV1_DecisionContext &ctx)
{
   string s = TrimString(ctx.support_resistance_confluence_state);
   ctx.sr_confluence_flag = ILV1_StateHasToken(s, "EXTERNAL_LEVEL_CONFLUENT");
   ctx.sr_rejection_risk_flag = ILV1_StateHasToken(s, "REJECTION_RISK_ELEVATED");
   ctx.sr_continuation_obstructed_flag = ILV1_StateHasToken(s, "CONTINUATION_PATH_OBSTRUCTED");
   ctx.sr_canonical_near_flag =
      ILV1_StateHasToken(s, "CANONICAL_SUPPORT_NEAR") ||
      ILV1_StateHasToken(s, "CANONICAL_RESISTANCE_NEAR");
   ctx.sr_conflicted_flag =
      ILV1_StateHasToken(s, "EXTERNAL_LEVEL_CONFLICTED") ||
      ILV1_StateHasToken(s, "REVERSAL_TRAP_RISK_ELEVATED");
}

string ILV1_BuildTradeLineageKey(const string decision_id, const ulong position_id, const ulong close_deal_id)
{
   string did = TrimString(decision_id);
   if(StringLen(did) <= 0)
      did = "NO_DECISION_ID";
   return
      "decision=" + did +
      "|position=" + ILV1_U64Text(position_id) +
      "|close_deal=" + ILV1_U64Text(close_deal_id);
}

string ILV1_BuildDecisionLinkKey(const string decision_id)
{
   string did = TrimString(decision_id);
   if(StringLen(did) <= 0)
      return "";

   string parts[];
   int n = StringSplit(did, '-', parts);
   if(n >= 2)
      return TrimString(parts[0]) + "-" + TrimString(parts[1]);
   return did;
}

int ILV1_DecisionIdMatchScore(const string left_id, const string right_id)
{
   string a = TrimString(left_id);
   string b = TrimString(right_id);
   if(StringLen(a) <= 0 || StringLen(b) <= 0)
      return 0;
   if(a == b)
      return 100;

   if(StringFind(a, b + "-") == 0 || StringFind(b, a + "-") == 0)
      return 90;

   if(StringFind(a, b) == 0 || StringFind(b, a) == 0)
      return 70;

   string ka = ILV1_BuildDecisionLinkKey(a);
   string kb = ILV1_BuildDecisionLinkKey(b);
   if(StringLen(ka) > 0 && ka == kb)
      return 50;

   return 0;
}

string ILV1_BuildMotifKey(const ILV1_DecisionContext &ctx)
{
   return
      "keyver=2" +
      "|strategy=" + ctx.strategy_id +
      "|direction=" + ctx.direction +
      "|regime=" + ctx.regime_bucket +
      "|zone=" + ctx.zone_bucket +
      "|vol=" + ctx.volatility_bucket +
      "|struct=" + ctx.structure_bucket +
      "|setup=" + ctx.setup_quality_bucket +
      "|sr=" + ctx.sr_interaction_bucket +
      "|contradiction=" + (ctx.advisory_contradiction_flag ? "1" : "0");
}

void ILV1_InitDecisionContext(ILV1_DecisionContext &ctx)
{
   ctx.valid = false;
   ctx.captured_at = 0;
   ctx.decision_id = "";
   ctx.symbol = "";
   ctx.strategy_id = "";
   ctx.strategy_family = "";
   ctx.direction = "";
   ctx.regime_bucket = "UNKNOWN_REGIME";
   ctx.zone_bucket = "";
   ctx.volatility_bucket = "UNKNOWN_VOL";
   ctx.structure_bucket = "UNKNOWN_STRUCTURE";
   ctx.setup_quality_bucket = "SETUP_NEUTRAL";
   ctx.sr_interaction_bucket = "SR_UNKNOWN";
   ctx.support_resistance_confluence_state = "";
   ctx.canonical_level_state = "";
   ctx.sr_confluence_flag = false;
   ctx.sr_rejection_risk_flag = false;
   ctx.sr_continuation_obstructed_flag = false;
   ctx.sr_canonical_near_flag = false;
   ctx.sr_conflicted_flag = false;
   ctx.advisory_contradiction_flag = false;
   ctx.advisory_hold_bias_active = false;
   ctx.advisory_relevance_score = 0.0;
   ctx.advisory_reason_summary = "";
   ctx.decision_quality_label = "";
   ctx.entry_quality_label = "";
   ctx.entry_edge_label = "";
   ctx.follow_through_label = "";
   ctx.execution_geometry_label = "";
   ctx.expected_rr_estimate = 0.0;
   ctx.motif_key = "";
}

void ILV1_InitMotif(ILV1_MotifStat &m)
{
   m.valid = false;
   m.motif_key = "";
   m.strategy_id = "";
   m.strategy_family = "";
   m.direction = "";
   m.regime_bucket = "UNKNOWN_REGIME";
   m.volatility_bucket = "UNKNOWN_VOL";
   m.structure_bucket = "UNKNOWN_STRUCTURE";
   m.setup_quality_bucket = "SETUP_NEUTRAL";
   m.sr_interaction_bucket = "SR_UNKNOWN";
   m.advisory_contradiction_flag = false;
   m.evidence_count = 0;
   m.win_count = 0;
   m.loss_count = 0;
   m.flat_count = 0;
   m.net_edge_ewma = 0.0;
   m.caution_ewma = 0.0;
   m.context_fit_ewma = 0.5;
   m.recent_outcomes = "";
   m.last_primary_attribution = "";
   m.last_secondary_attribution = "";
   m.last_reason_codes_csv = "";
   m.last_updated = 0;
}

void ILV1_InitAdjustment(ILV1_Adjustment &a)
{
   a.applied = false;
   a.state_code = "LEARNING_IDLE";
   a.reason_codes_csv = "";
   a.motif_key = "";
   a.evidence_count = 0;
   a.confidence_delta = 0.0;
   a.caution_score = 0.0;
   a.context_fit_score = 0.5;
   a.contradiction_signal = false;
   a.hold_bias = false;
   a.reevaluation_bias = false;
   a.strength_band = "NONE";
}

void ILV1_InitStatus(ILV1_RuntimeStatus &s)
{
   s.artifact_role = "AI_INSTITUTIONAL_LEARNING_STATUS";
   s.artifact_authority_class = "NON_AUTHORITATIVE_DERIVED_LEARNING_STATUS";
   s.summary_version = "L3_INSTITUTIONAL_LEARNING_V1";
   s.trust_rule = "bounded_learning_shapes_confidence_only_never_execution_authority";
   s.update_source = "institutional_learning_layer_v1";
   s.learning_enabled = false;
   s.initialized = false;
   s.motif_count = 0;
   s.total_events = 0;
   s.state_code = "NOT_INITIALIZED";
   s.reason_codes_csv = "INIT_PENDING";
   s.last_motif_key = "";
   s.last_evidence_count = 0;
   s.last_confidence_delta = 0.0;
   s.last_caution_score = 0.0;
   s.last_context_fit_score = 0.5;
   s.last_contradiction_signal = false;
   s.last_hold_bias = false;
   s.last_reevaluation_bias = false;
   s.last_strength_band = "NONE";
   s.non_authoritative_notice = "Learning output may shape confidence/caution/context-fit only. No execution/risk/governor authority transfer.";
   s.evaluated_at = TimeCurrent();
}

int ILV1_FindMotifIndex(string motif_key)
{
   for(int i = 0; i < ArraySize(gILV1Motifs); i++)
   {
      if(gILV1Motifs[i].valid && gILV1Motifs[i].motif_key == motif_key)
         return i;
   }
   return -1;
}

double ILV1_RecentInstabilityScore(string recent_outcomes)
{
   int len = StringLen(recent_outcomes);
   if(len <= 1)
      return 0.0;

   int flips = 0;
   for(int i = 1; i < len; i++)
   {
      string a = StringSubstr(recent_outcomes, i - 1, 1);
      string b = StringSubstr(recent_outcomes, i, 1);
      if((a == "W" || a == "L") && (b == "W" || b == "L") && a != b)
         flips++;
   }

   return ILV1_Clamp01((double)flips / (double)MathMax(1, len - 1));
}

string ILV1_AdjustmentBand(double absDelta, double caution)
{
   double score = absDelta + caution;
   if(score >= 0.11) return "STRONG";
   if(score >= 0.06) return "MODERATE";
   if(score > 0.0)   return "WEAK";
   return "NONE";
}

int ILV1_EnsureMotif(const ILV1_DecisionContext &ctx)
{
   int idx = ILV1_FindMotifIndex(ctx.motif_key);
   if(idx >= 0)
      return idx;

   ILV1_MotifStat m;
   ILV1_InitMotif(m);
   m.valid = true;
   m.motif_key = ctx.motif_key;
   m.strategy_id = ctx.strategy_id;
   m.strategy_family = ctx.strategy_family;
   m.direction = ctx.direction;
   m.regime_bucket = ctx.regime_bucket;
   m.volatility_bucket = ctx.volatility_bucket;
   m.structure_bucket = ctx.structure_bucket;
   m.setup_quality_bucket = ctx.setup_quality_bucket;
   m.sr_interaction_bucket = ctx.sr_interaction_bucket;
   m.advisory_contradiction_flag = ctx.advisory_contradiction_flag;

   int n = ArraySize(gILV1Motifs);
   ArrayResize(gILV1Motifs, n + 1);
   gILV1Motifs[n] = m;
   return n;
}

string ILV1_ContextToJson(const ILV1_DecisionContext &ctx)
{
   string decision_link_key = ILV1_BuildDecisionLinkKey(ctx.decision_id);
   string j = "{";
   j += "\"record_type\":\"DECISION_CONTEXT\"";
   j += ",\"captured_at\":\"" + ILV1_EscapeJson(ILV1_TimeText(ctx.captured_at)) + "\"";
   j += ",\"decision_id\":\"" + ILV1_EscapeJson(ctx.decision_id) + "\"";
   j += ",\"decision_link_key\":\"" + ILV1_EscapeJson(decision_link_key) + "\"";
   j += ",\"symbol\":\"" + ILV1_EscapeJson(ctx.symbol) + "\"";
   j += ",\"strategy_id\":\"" + ILV1_EscapeJson(ctx.strategy_id) + "\"";
   j += ",\"strategy_family\":\"" + ILV1_EscapeJson(ctx.strategy_family) + "\"";
   j += ",\"direction\":\"" + ILV1_EscapeJson(ctx.direction) + "\"";
   j += ",\"regime_bucket\":\"" + ILV1_EscapeJson(ctx.regime_bucket) + "\"";
   j += ",\"zone_bucket\":\"" + ILV1_EscapeJson(ctx.zone_bucket) + "\"";
   j += ",\"volatility_bucket\":\"" + ILV1_EscapeJson(ctx.volatility_bucket) + "\"";
   j += ",\"structure_bucket\":\"" + ILV1_EscapeJson(ctx.structure_bucket) + "\"";
   j += ",\"setup_quality_bucket\":\"" + ILV1_EscapeJson(ctx.setup_quality_bucket) + "\"";
   j += ",\"sr_interaction_bucket\":\"" + ILV1_EscapeJson(ctx.sr_interaction_bucket) + "\"";
   j += ",\"support_resistance_confluence_state\":\"" + ILV1_EscapeJson(ctx.support_resistance_confluence_state) + "\"";
   j += ",\"canonical_level_state\":\"" + ILV1_EscapeJson(ctx.canonical_level_state) + "\"";
   j += ",\"sr_confluence_flag\":" + ILV1_BoolText(ctx.sr_confluence_flag);
   j += ",\"sr_rejection_risk_flag\":" + ILV1_BoolText(ctx.sr_rejection_risk_flag);
   j += ",\"sr_continuation_obstructed_flag\":" + ILV1_BoolText(ctx.sr_continuation_obstructed_flag);
   j += ",\"sr_canonical_near_flag\":" + ILV1_BoolText(ctx.sr_canonical_near_flag);
   j += ",\"sr_conflicted_flag\":" + ILV1_BoolText(ctx.sr_conflicted_flag);
   j += ",\"advisory_contradiction_flag\":" + ILV1_BoolText(ctx.advisory_contradiction_flag);
   j += ",\"advisory_hold_bias_active\":" + ILV1_BoolText(ctx.advisory_hold_bias_active);
   j += ",\"advisory_relevance_score\":" + DoubleToString(ILV1_Clamp01(ctx.advisory_relevance_score), 3);
   j += ",\"advisory_reason_summary\":\"" + ILV1_EscapeJson(ctx.advisory_reason_summary) + "\"";
   j += ",\"decision_quality_label\":\"" + ILV1_EscapeJson(ctx.decision_quality_label) + "\"";
   j += ",\"entry_quality_label\":\"" + ILV1_EscapeJson(ctx.entry_quality_label) + "\"";
   j += ",\"entry_edge_label\":\"" + ILV1_EscapeJson(ctx.entry_edge_label) + "\"";
   j += ",\"follow_through_label\":\"" + ILV1_EscapeJson(ctx.follow_through_label) + "\"";
   j += ",\"execution_geometry_label\":\"" + ILV1_EscapeJson(ctx.execution_geometry_label) + "\"";
   j += ",\"expected_rr_estimate\":" + DoubleToString(ctx.expected_rr_estimate, 3);
   j += ",\"motif_key\":\"" + ILV1_EscapeJson(ctx.motif_key) + "\"";
   j += "}";
   return j;
}

bool ILV1_ParseContextLine(string ln, ILV1_DecisionContext &ctx)
{
   ILV1_InitDecisionContext(ctx);

   string s = "";
   bool b = false;
   double d = 0.0;

   if(!ExtractJsonStringField(ln, "decision_id", s) || StringLen(TrimString(s)) <= 0)
      return false;
   ctx.decision_id = s;

   ExtractJsonStringField(ln, "symbol", ctx.symbol);
   ExtractJsonStringField(ln, "strategy_id", ctx.strategy_id);
   ExtractJsonStringField(ln, "strategy_family", ctx.strategy_family);
   ExtractJsonStringField(ln, "direction", ctx.direction);
   ExtractJsonStringField(ln, "regime_bucket", ctx.regime_bucket);
   ExtractJsonStringField(ln, "zone_bucket", ctx.zone_bucket);
   ExtractJsonStringField(ln, "volatility_bucket", ctx.volatility_bucket);
   ExtractJsonStringField(ln, "structure_bucket", ctx.structure_bucket);
   ExtractJsonStringField(ln, "setup_quality_bucket", ctx.setup_quality_bucket);
   ExtractJsonStringField(ln, "sr_interaction_bucket", ctx.sr_interaction_bucket);
    ExtractJsonStringField(ln, "support_resistance_confluence_state", ctx.support_resistance_confluence_state);
    ExtractJsonStringField(ln, "canonical_level_state", ctx.canonical_level_state);

   if(ExtractJsonBoolField(ln, "advisory_contradiction_flag", b))
      ctx.advisory_contradiction_flag = b;
   if(ExtractJsonBoolField(ln, "advisory_hold_bias_active", b))
      ctx.advisory_hold_bias_active = b;
   if(ExtractJsonBoolField(ln, "sr_confluence_flag", b))
      ctx.sr_confluence_flag = b;
   if(ExtractJsonBoolField(ln, "sr_rejection_risk_flag", b))
      ctx.sr_rejection_risk_flag = b;
   if(ExtractJsonBoolField(ln, "sr_continuation_obstructed_flag", b))
      ctx.sr_continuation_obstructed_flag = b;
   if(ExtractJsonBoolField(ln, "sr_canonical_near_flag", b))
      ctx.sr_canonical_near_flag = b;
   if(ExtractJsonBoolField(ln, "sr_conflicted_flag", b))
      ctx.sr_conflicted_flag = b;
   if(ExtractJsonDoubleField(ln, "advisory_relevance_score", d))
      ctx.advisory_relevance_score = d;

   ExtractJsonStringField(ln, "advisory_reason_summary", ctx.advisory_reason_summary);
   ExtractJsonStringField(ln, "decision_quality_label", ctx.decision_quality_label);
   ExtractJsonStringField(ln, "entry_quality_label", ctx.entry_quality_label);
   ExtractJsonStringField(ln, "entry_edge_label", ctx.entry_edge_label);
   ExtractJsonStringField(ln, "follow_through_label", ctx.follow_through_label);
   ExtractJsonStringField(ln, "execution_geometry_label", ctx.execution_geometry_label);
   if(ExtractJsonDoubleField(ln, "expected_rr_estimate", d))
      ctx.expected_rr_estimate = d;
   ExtractJsonStringField(ln, "motif_key", ctx.motif_key);

   if(StringLen(ctx.strategy_family) <= 0)
      ctx.strategy_family = ILV1_InferStrategyFamily(ctx.strategy_id);
   if(StringLen(ctx.support_resistance_confluence_state) <= 0)
      ctx.support_resistance_confluence_state = ctx.sr_interaction_bucket;
   if(StringLen(ctx.canonical_level_state) <= 0)
      ctx.canonical_level_state = ctx.support_resistance_confluence_state;
   ILV1_ApplySrFlags(ctx);

   ctx.valid = true;
   return true;
}

bool ILV1_FindContextByDecisionId(string decision_id, ILV1_DecisionContext &ctx)
{
   ILV1_InitDecisionContext(ctx);
   decision_id = TrimString(decision_id);
   if(StringLen(decision_id) <= 0)
      return false;

   string lines[];
   if(!ILV1_ReadAllLines(ILV1_CONTEXT_PATH, lines))
      return false;

   ILV1_DecisionContext best;
   ILV1_InitDecisionContext(best);
   int best_score = 0;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      ILV1_DecisionContext one;
      if(!ILV1_ParseContextLine(lines[i], one))
         continue;
      int score = ILV1_DecisionIdMatchScore(one.decision_id, decision_id);
      if(score <= 0)
         continue;
      if(score > best_score)
      {
         best = one;
         best_score = score;
         if(score >= 100)
            break;
      }
   }

   if(best_score > 0)
   {
      ctx = best;
      return true;
   }

   return false;
}

bool ILV1_ResolveDecisionIdFromFeedbackDeals(const TradeFeedbackRecord &fb, string &outDecisionId)
{
   outDecisionId = "";
   string comment = "";
   string did = "";

   if(fb.close_deal_id > 0)
   {
      comment = HistoryDealGetString(fb.close_deal_id, DEAL_COMMENT);
      if(ExtractDecisionIdFromComment(comment, did) && StringLen(TrimString(did)) > 0)
      {
         outDecisionId = TrimString(did);
         return true;
      }
   }

   if(fb.entry_deal_id > 0)
   {
      comment = HistoryDealGetString(fb.entry_deal_id, DEAL_COMMENT);
      if(ExtractDecisionIdFromComment(comment, did) && StringLen(TrimString(did)) > 0)
      {
         outDecisionId = TrimString(did);
         return true;
      }
   }

   if(fb.position_id > 0)
   {
      int total = HistoryDealsTotal();
      for(int i = total - 1; i >= 0; i--)
      {
         ulong tk = HistoryDealGetTicket(i);
         if(tk == 0)
            continue;

         ulong pid = (ulong)HistoryDealGetInteger(tk, DEAL_POSITION_ID);
         if(pid != fb.position_id)
            continue;

         comment = HistoryDealGetString(tk, DEAL_COMMENT);
         if(ExtractDecisionIdFromComment(comment, did) && StringLen(TrimString(did)) > 0)
         {
            outDecisionId = TrimString(did);
            return true;
         }
      }
   }

   return false;
}

bool ILV1_FindStrategyOpenByDecisionId(const string decision_id,
                                       string &strategy_id,
                                       string &strategy_family,
                                       string &regime_label,
                                       string &direction)
{
   strategy_id = "";
   strategy_family = "";
   regime_label = "";
   direction = "";

   string did = TrimString(decision_id);
   if(StringLen(did) <= 0)
      return false;

   string lines[];
   if(!ILV1_ReadAllLines(ILV1_STRATEGY_EVENTS_PATH, lines))
      return false;

   string best_strategy_id = "";
   string best_strategy_family = "";
   string best_regime_label = "";
   string best_direction = "";
   int best_score = 0;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string ln = lines[i];
      string eventName = "";
      string oneDid = "";
      if(!ExtractJsonStringField(ln, "event", eventName) || eventName != "TRADE_OPEN")
         continue;
      if(!ExtractJsonStringField(ln, "decision_id", oneDid))
         continue;
      int score = ILV1_DecisionIdMatchScore(oneDid, did);
      if(score <= 0)
         continue;

      string one_strategy_id = "";
      string one_strategy_family = "";
      string one_regime_label = "";
      string one_direction = "";
      ExtractJsonStringField(ln, "strategy_id", one_strategy_id);
      ExtractJsonStringField(ln, "strategy_family", one_strategy_family);
      ExtractJsonStringField(ln, "regime_label", one_regime_label);
      ExtractJsonStringField(ln, "direction", one_direction);

      one_strategy_id = TrimString(one_strategy_id);
      one_strategy_family = TrimString(one_strategy_family);
      one_regime_label = TrimString(one_regime_label);
      one_direction = TrimString(one_direction);
      if(StringLen(one_strategy_id) <= 0)
         continue;

      if(StringLen(one_strategy_family) <= 0)
         one_strategy_family = ILV1_InferStrategyFamily(one_strategy_id);

      if(score > best_score)
      {
         best_strategy_id = one_strategy_id;
         best_strategy_family = one_strategy_family;
         best_regime_label = one_regime_label;
         best_direction = one_direction;
         best_score = score;
         if(score >= 100)
            break;
      }
   }

   if(best_score > 0)
   {
      strategy_id = best_strategy_id;
      strategy_family = best_strategy_family;
      regime_label = best_regime_label;
      direction = best_direction;
      return true;
   }

   return false;
}

datetime ILV1_ResolveEntryTime(const TradeFeedbackRecord &fb)
{
   if(fb.entry_deal_id > 0)
      return (datetime)HistoryDealGetInteger(fb.entry_deal_id, DEAL_TIME);
   return 0;
}

datetime ILV1_ResolveExitTime(const TradeFeedbackRecord &fb)
{
   if(fb.close_time > 0)
      return fb.close_time;
   if(fb.close_deal_id > 0)
      return (datetime)HistoryDealGetInteger(fb.close_deal_id, DEAL_TIME);
   return 0;
}

string ILV1_ClassifyIdentityLineage(const string decision_id, const ulong position_id, const ulong close_deal_id)
{
   bool hasDecision = (StringLen(TrimString(decision_id)) > 0);
   bool hasPosition = (position_id > 0);
   bool hasCloseDeal = (close_deal_id > 0);
   if(hasDecision && hasPosition && hasCloseDeal) return "PRESERVED";
   if(hasDecision || hasPosition || hasCloseDeal) return "PARTIALLY_PRESERVED";
   return "MISSING";
}

string ILV1_ClassifyStrategyLineage(const TradeFeedbackRecord &fb, const ILV1_DecisionContext &ctx)
{
   string runtimeSid = TrimString(ctx.strategy_id);
   string feedbackSid = TrimString(fb.main_trigger_name);
   if(StringLen(runtimeSid) <= 0 || runtimeSid == "UNKNOWN_STRATEGY")
      return "MISSING";
   if(StringLen(feedbackSid) > 0 && feedbackSid != runtimeSid)
      return "PARTIALLY_PRESERVED";
   return "PRESERVED";
}

string ILV1_ClassifySrLineage(const ILV1_DecisionContext &ctx)
{
   bool hasRaw = (StringLen(TrimString(ctx.support_resistance_confluence_state)) > 0 &&
                  ctx.support_resistance_confluence_state != "UNSET");
   bool hasBucket = (StringLen(TrimString(ctx.sr_interaction_bucket)) > 0 &&
                     ctx.sr_interaction_bucket != "SR_UNKNOWN");
   if(hasRaw && hasBucket) return "PRESERVED";
   if(hasBucket) return "PARTIALLY_PRESERVED";
   return "FLATTENED";
}

string ILV1_ClassifyAttributionLineage(const string primary_attr, const string secondary_attr)
{
   if(StringLen(TrimString(primary_attr)) <= 0)
      return "MISSING";
   if(StringLen(TrimString(secondary_attr)) <= 0)
      return "PARTIALLY_PRESERVED";
   return "PRESERVED";
}

string ILV1_ClassifyAdvisoryLineage(const ILV1_DecisionContext &ctx)
{
   bool hasAdvisory = (ctx.advisory_relevance_score > 0.0 || StringLen(TrimString(ctx.advisory_reason_summary)) > 0);
   return (hasAdvisory ? "PRESERVED" : "PARTIALLY_PRESERVED");
}

string ILV1_BuildTradeLineageJson(const TradeFeedbackRecord &fb,
                                  const ILV1_DecisionContext &ctx,
                                  const string primary_attr,
                                  const string secondary_attr,
                                  const string reason_csv,
                                  const bool context_found)
{
   string decision_id = TrimString(fb.decision_id);
   if(StringLen(decision_id) <= 0)
      decision_id = TrimString(fb.correlated_decision_id);
   string decision_link_key = ILV1_BuildDecisionLinkKey(decision_id);
   string trade_key = ILV1_BuildTradeLineageKey(decision_id, fb.position_id, fb.close_deal_id);
   datetime entry_time = ILV1_ResolveEntryTime(fb);
   datetime exit_time = ILV1_ResolveExitTime(fb);

   string identity_status = ILV1_ClassifyIdentityLineage(decision_id, fb.position_id, fb.close_deal_id);
   string strategy_status = ILV1_ClassifyStrategyLineage(fb, ctx);
   string sr_status = ILV1_ClassifySrLineage(ctx);
   string attribution_status = ILV1_ClassifyAttributionLineage(primary_attr, secondary_attr);
   string advisory_status = ILV1_ClassifyAdvisoryLineage(ctx);

   string j = "{";
   j += "\"record_type\":\"TRADE_LINEAGE\"";
   j += ",\"captured_at\":\"" + ILV1_EscapeJson(ILV1_TimeText(TimeCurrent())) + "\"";
   j += ",\"trade_lineage_key\":\"" + ILV1_EscapeJson(trade_key) + "\"";
   j += ",\"decision_id\":\"" + ILV1_EscapeJson(decision_id) + "\"";
   j += ",\"decision_link_key\":\"" + ILV1_EscapeJson(decision_link_key) + "\"";
   j += ",\"correlated_decision_id\":\"" + ILV1_EscapeJson(fb.correlated_decision_id) + "\"";
   j += ",\"position_id\":" + ILV1_U64Text(fb.position_id);
   j += ",\"entry_deal_id\":" + ILV1_U64Text(fb.entry_deal_id);
   j += ",\"close_deal_id\":" + ILV1_U64Text(fb.close_deal_id);
   j += ",\"symbol\":\"" + ILV1_EscapeJson(fb.symbol) + "\"";
   j += ",\"direction\":\"" + ILV1_EscapeJson(ctx.direction) + "\"";
   j += ",\"entry_time\":\"" + ILV1_EscapeJson(ILV1_TimeText(entry_time)) + "\"";
   j += ",\"exit_time\":\"" + ILV1_EscapeJson(ILV1_TimeText(exit_time)) + "\"";
   j += ",\"runtime_strategy_id_exact\":\"" + ILV1_EscapeJson(ctx.strategy_id) + "\"";
   j += ",\"runtime_strategy_family_exact\":\"" + ILV1_EscapeJson(ctx.strategy_family) + "\"";
   j += ",\"feedback_strategy_id\":\"" + ILV1_EscapeJson(fb.main_trigger_name) + "\"";
   j += ",\"aggregated_strategy_bucket\":\"" + ILV1_EscapeJson(ctx.strategy_id) + "\"";
   j += ",\"regime_label\":\"" + ILV1_EscapeJson(ctx.regime_bucket) + "\"";
   j += ",\"volatility_regime\":\"" + ILV1_EscapeJson(ctx.volatility_bucket) + "\"";
   j += ",\"structure_bucket\":\"" + ILV1_EscapeJson(ctx.structure_bucket) + "\"";
   j += ",\"sr_interaction_bucket\":\"" + ILV1_EscapeJson(ctx.sr_interaction_bucket) + "\"";
   j += ",\"support_resistance_confluence_state\":\"" + ILV1_EscapeJson(ctx.support_resistance_confluence_state) + "\"";
   j += ",\"canonical_level_state\":\"" + ILV1_EscapeJson(ctx.canonical_level_state) + "\"";
   j += ",\"sr_confluence_flag\":" + ILV1_BoolText(ctx.sr_confluence_flag);
   j += ",\"sr_rejection_risk_flag\":" + ILV1_BoolText(ctx.sr_rejection_risk_flag);
   j += ",\"sr_continuation_obstructed_flag\":" + ILV1_BoolText(ctx.sr_continuation_obstructed_flag);
   j += ",\"sr_canonical_near_flag\":" + ILV1_BoolText(ctx.sr_canonical_near_flag);
   j += ",\"sr_conflicted_flag\":" + ILV1_BoolText(ctx.sr_conflicted_flag);
   j += ",\"advisory_contradiction_flag\":" + ILV1_BoolText(ctx.advisory_contradiction_flag);
   j += ",\"advisory_relevance_score\":" + DoubleToString(ILV1_Clamp01(ctx.advisory_relevance_score), 3);
   j += ",\"advisory_reason_summary\":\"" + ILV1_EscapeJson(ctx.advisory_reason_summary) + "\"";
   j += ",\"runtime_primary_attribution\":\"" + ILV1_EscapeJson(primary_attr) + "\"";
   j += ",\"runtime_secondary_attribution\":\"" + ILV1_EscapeJson(secondary_attr) + "\"";
   j += ",\"aggregated_primary_attribution\":\"" + ILV1_EscapeJson(primary_attr) + "\"";
   j += ",\"aggregated_secondary_attribution\":\"" + ILV1_EscapeJson(secondary_attr) + "\"";
   j += ",\"attribution_reason_codes_csv\":\"" + ILV1_EscapeJson(reason_csv) + "\"";
   j += ",\"context_found\":" + ILV1_BoolText(context_found);
   j += ",\"identity_linkage_status\":\"" + identity_status + "\"";
   j += ",\"strategy_lineage_status\":\"" + strategy_status + "\"";
   j += ",\"sr_lineage_status\":\"" + sr_status + "\"";
   j += ",\"advisory_lineage_status\":\"" + advisory_status + "\"";
   j += ",\"attribution_lineage_status\":\"" + attribution_status + "\"";
   j += ",\"non_authoritative_notice\":\"forensic_lineage_only_non_executive\"";
   j += "}";
   return j;
}

void ILV1_WriteLineageStatus(const string trade_lineage_key,
                             const string identity_status,
                             const string strategy_status,
                             const string sr_status,
                             const string advisory_status,
                             const string attribution_status,
                             const string reason_csv)
{
   string state_code = "LINEAGE_PRESERVED";
   string degrade = "";

   if(identity_status != "PRESERVED") degrade += (StringLen(degrade) > 0 ? "," : "") + "IDENTITY_" + identity_status;
   if(strategy_status != "PRESERVED") degrade += (StringLen(degrade) > 0 ? "," : "") + "STRATEGY_" + strategy_status;
   if(sr_status != "PRESERVED") degrade += (StringLen(degrade) > 0 ? "," : "") + "SR_" + sr_status;
   if(advisory_status != "PRESERVED") degrade += (StringLen(degrade) > 0 ? "," : "") + "ADVISORY_" + advisory_status;
   if(attribution_status != "PRESERVED") degrade += (StringLen(degrade) > 0 ? "," : "") + "ATTRIBUTION_" + attribution_status;

   if(StringLen(degrade) > 0)
   {
      state_code = "LINEAGE_DEGRADED";
      gILV1LineageDegradedRecords++;
   }

   string j = "{";
   j += "\"artifact_role\":\"AI_INSTITUTIONAL_LEARNING_LINEAGE_STATUS\"";
   j += ",\"artifact_authority_class\":\"NON_AUTHORITATIVE_DERIVED_LINEAGE_STATUS\"";
   j += ",\"summary_version\":\"L3_LINEAGE_STATUS_V1\"";
   j += ",\"trust_rule\":\"lineage_diagnostics_only_non_executive\"";
   j += ",\"state_code\":\"" + state_code + "\"";
   j += ",\"total_lineage_records\":" + IntegerToString(gILV1LineageRecords);
   j += ",\"degraded_lineage_records\":" + IntegerToString(gILV1LineageDegradedRecords);
   j += ",\"last_trade_lineage_key\":\"" + ILV1_EscapeJson(trade_lineage_key) + "\"";
   j += ",\"last_identity_status\":\"" + identity_status + "\"";
   j += ",\"last_strategy_status\":\"" + strategy_status + "\"";
   j += ",\"last_sr_status\":\"" + sr_status + "\"";
   j += ",\"last_advisory_status\":\"" + advisory_status + "\"";
   j += ",\"last_attribution_status\":\"" + attribution_status + "\"";
   j += ",\"lineage_reason_codes_csv\":\"" + ILV1_EscapeJson(
      (StringLen(degrade) > 0 ? degrade : "ALL_PRESERVED") +
      (StringLen(reason_csv) > 0 ? "," + reason_csv : "")
   ) + "\"";
   j += ",\"evaluated_at\":\"" + ILV1_EscapeJson(ILV1_TimeText(TimeCurrent())) + "\"";
   j += ",\"non_authoritative_notice\":\"lineage_status_for_forensics_only_no_execution_authority\"";
   j += "}";

   ILV1_WriteText(ILV1_LINEAGE_STATUS_PATH, j);
}

string ILV1_BuildMemoryJson()
{
   string j = "{";
   j += "\"artifact_role\":\"AI_INSTITUTIONAL_LEARNING_MEMORY\"";
   j += ",\"artifact_authority_class\":\"DERIVED_LEARNING_TRUTH_NON_EXECUTION\"";
   j += ",\"summary_version\":\"L3_INSTITUTIONAL_LEARNING_V1\"";
   j += ",\"trust_rule\":\"derived_memory_for_bounded_confidence_shaping_only\"";
   j += ",\"generated_at\":\"" + ILV1_EscapeJson(ILV1_TimeText(TimeCurrent())) + "\"";
   j += ",\"motif_count\":" + IntegerToString(ArraySize(gILV1Motifs));
   j += ",\"total_events\":" + IntegerToString(gILV1TotalEvents);
   j += ",\"motifs\":[";

   for(int i = 0; i < ArraySize(gILV1Motifs); i++)
   {
      ILV1_MotifStat m = gILV1Motifs[i];
      if(i > 0) j += ",";
      j += "{";
      j += "\"motif_key\":\"" + ILV1_EscapeJson(m.motif_key) + "\"";
      j += ",\"strategy_id\":\"" + ILV1_EscapeJson(m.strategy_id) + "\"";
      j += ",\"strategy_family\":\"" + ILV1_EscapeJson(m.strategy_family) + "\"";
      j += ",\"direction\":\"" + ILV1_EscapeJson(m.direction) + "\"";
      j += ",\"regime_bucket\":\"" + ILV1_EscapeJson(m.regime_bucket) + "\"";
      j += ",\"volatility_bucket\":\"" + ILV1_EscapeJson(m.volatility_bucket) + "\"";
      j += ",\"structure_bucket\":\"" + ILV1_EscapeJson(m.structure_bucket) + "\"";
      j += ",\"setup_quality_bucket\":\"" + ILV1_EscapeJson(m.setup_quality_bucket) + "\"";
      j += ",\"sr_interaction_bucket\":\"" + ILV1_EscapeJson(m.sr_interaction_bucket) + "\"";
      j += ",\"advisory_contradiction_flag\":" + ILV1_BoolText(m.advisory_contradiction_flag);
      j += ",\"evidence_count\":" + IntegerToString(m.evidence_count);
      j += ",\"wins\":" + IntegerToString(m.win_count);
      j += ",\"losses\":" + IntegerToString(m.loss_count);
      j += ",\"flats\":" + IntegerToString(m.flat_count);
      j += ",\"net_edge_ewma\":" + DoubleToString(ILV1_Clamp(m.net_edge_ewma, -1.0, 1.0), 4);
      j += ",\"caution_ewma\":" + DoubleToString(ILV1_Clamp01(m.caution_ewma), 4);
      j += ",\"context_fit_ewma\":" + DoubleToString(ILV1_Clamp01(m.context_fit_ewma), 4);
      j += ",\"recent_outcomes\":\"" + ILV1_EscapeJson(m.recent_outcomes) + "\"";
      j += ",\"last_primary_attribution\":\"" + ILV1_EscapeJson(m.last_primary_attribution) + "\"";
      j += ",\"last_secondary_attribution\":\"" + ILV1_EscapeJson(m.last_secondary_attribution) + "\"";
      j += ",\"last_reason_codes_csv\":\"" + ILV1_EscapeJson(m.last_reason_codes_csv) + "\"";
      j += ",\"last_updated\":\"" + ILV1_EscapeJson(ILV1_TimeText(m.last_updated)) + "\"";
      j += "}";
   }

   j += "]";
   j += "}";
   return j;
}

string ILV1_BuildStatusJson(const ILV1_RuntimeStatus &s)
{
   string j = "{";
   j += "\"artifact_role\":\"" + ILV1_EscapeJson(s.artifact_role) + "\"";
   j += ",\"artifact_authority_class\":\"" + ILV1_EscapeJson(s.artifact_authority_class) + "\"";
   j += ",\"summary_version\":\"" + ILV1_EscapeJson(s.summary_version) + "\"";
   j += ",\"trust_rule\":\"" + ILV1_EscapeJson(s.trust_rule) + "\"";
   j += ",\"update_source\":\"" + ILV1_EscapeJson(s.update_source) + "\"";
   j += ",\"learning_enabled\":" + ILV1_BoolText(s.learning_enabled);
   j += ",\"initialized\":" + ILV1_BoolText(s.initialized);
   j += ",\"motif_count\":" + IntegerToString(s.motif_count);
   j += ",\"total_events\":" + IntegerToString(s.total_events);
   j += ",\"state_code\":\"" + ILV1_EscapeJson(s.state_code) + "\"";
   j += ",\"reason_codes_csv\":\"" + ILV1_EscapeJson(s.reason_codes_csv) + "\"";
   j += ",\"last_motif_key\":\"" + ILV1_EscapeJson(s.last_motif_key) + "\"";
   j += ",\"last_evidence_count\":" + IntegerToString(s.last_evidence_count);
   j += ",\"last_confidence_delta\":" + DoubleToString(s.last_confidence_delta, 4);
   j += ",\"last_caution_score\":" + DoubleToString(s.last_caution_score, 4);
   j += ",\"last_context_fit_score\":" + DoubleToString(s.last_context_fit_score, 4);
   j += ",\"last_contradiction_signal\":" + ILV1_BoolText(s.last_contradiction_signal);
   j += ",\"last_hold_bias\":" + ILV1_BoolText(s.last_hold_bias);
   j += ",\"last_reevaluation_bias\":" + ILV1_BoolText(s.last_reevaluation_bias);
   j += ",\"last_strength_band\":\"" + ILV1_EscapeJson(s.last_strength_band) + "\"";
   j += ",\"non_authoritative_notice\":\"" + ILV1_EscapeJson(s.non_authoritative_notice) + "\"";
   j += ",\"evaluated_at\":\"" + ILV1_EscapeJson(ILV1_TimeText(s.evaluated_at)) + "\"";
   j += "}";
   return j;
}

string ILV1_BuildStatusText(const ILV1_RuntimeStatus &s)
{
   string t = "";
   t += "artifact_role=" + s.artifact_role + "\n";
   t += "artifact_authority_class=" + s.artifact_authority_class + "\n";
   t += "summary_version=" + s.summary_version + "\n";
   t += "trust_rule=" + s.trust_rule + "\n";
   t += "learning_enabled=" + ILV1_BoolText(s.learning_enabled) + "\n";
   t += "initialized=" + ILV1_BoolText(s.initialized) + "\n";
   t += "motif_count=" + IntegerToString(s.motif_count) + "\n";
   t += "total_events=" + IntegerToString(s.total_events) + "\n";
   t += "state_code=" + s.state_code + "\n";
   t += "reason_codes_csv=" + s.reason_codes_csv + "\n";
   t += "last_motif_key=" + s.last_motif_key + "\n";
   t += "last_evidence_count=" + IntegerToString(s.last_evidence_count) + "\n";
   t += "last_confidence_delta=" + DoubleToString(s.last_confidence_delta, 4) + "\n";
   t += "last_caution_score=" + DoubleToString(s.last_caution_score, 4) + "\n";
   t += "last_context_fit_score=" + DoubleToString(s.last_context_fit_score, 4) + "\n";
   t += "last_contradiction_signal=" + ILV1_BoolText(s.last_contradiction_signal) + "\n";
   t += "last_hold_bias=" + ILV1_BoolText(s.last_hold_bias) + "\n";
   t += "last_reevaluation_bias=" + ILV1_BoolText(s.last_reevaluation_bias) + "\n";
   t += "last_strength_band=" + s.last_strength_band + "\n";
   t += "non_authoritative_notice=" + s.non_authoritative_notice + "\n";
   t += "evaluated_at=" + ILV1_TimeText(s.evaluated_at) + "\n";
   return t;
}

void ILV1_SaveDerivedArtifacts()
{
   ILV1_WriteText(ILV1_MEMORY_PATH, ILV1_BuildMemoryJson());
   ILV1_WriteText(ILV1_STATUS_PATH, ILV1_BuildStatusJson(gILV1Status));
   ILV1_WriteText(ILV1_STATUS_TXT_PATH, ILV1_BuildStatusText(gILV1Status));
}

void ILV1_ClassifyAttribution(const TradeFeedbackRecord &fb,
                              const ILV1_DecisionContext &ctx,
                              string &primary,
                              string &secondary,
                              string &reason_csv)
{
   primary = "NEUTRAL_OBSERVATION";
   secondary = "";
   reason_csv = "";

   string result = TrimString(fb.result);
   bool isWin = (result == "WIN");
   bool isLoss = (result == "LOSS");

   bool lowDQ = (fb.linked_decision_quality_label == "LOW_QUALITY_DECISION" || fb.linked_decision_quality_label == "BLOCK_WORTHY_DECISION");
   bool poorGeom = (fb.linked_execution_geometry_label == "POOR_EXECUTION_GEOMETRY" || fb.linked_execution_geometry_label == "ADVERSE_EXECUTION_GEOMETRY");
   bool weakFT = (fb.linked_follow_through_quality_label == "WEAK_FOLLOW_THROUGH" || fb.linked_follow_through_quality_label == "COLLAPSING_FOLLOW_THROUGH");
   bool dirty = (fb.regime_label == "RANGE_DIRTY" || fb.rc_structure_state == "NOISY");
   bool highVol = (fb.rc_volatility_state == "HIGH_VOL");
   bool lowVol = (fb.rc_volatility_state == "LOW_VOL" || fb.regime_label == "COMPRESSION");
   bool reversalRisk = (fb.regime_label == "REVERSAL_RISK");
   bool srConflicted = (ctx.sr_interaction_bucket == "SR_CONFLICTED" || ctx.sr_interaction_bucket == "SR_REJECTION_RISK" || ctx.sr_interaction_bucket == "SR_REVERSAL_TRAP");
   bool continuationObstructed = (ctx.sr_interaction_bucket == "SR_CONTINUATION_OBSTRUCTED");

   if(isWin)
   {
      primary = "SUCCESS_MOTIF_CONFIRMED";
      if(ctx.sr_interaction_bucket == "SR_CONFLUENT" || ctx.sr_interaction_bucket == "SR_CANONICAL_NEAR")
         secondary = "SUCCESS_WITH_LEVEL_CONFLUENCE";
      reason_csv = "WIN_EVIDENCE";
      if(StringLen(secondary) > 0)
         reason_csv += ",SR_CONFLUENCE_HELPFUL";
      return;
   }

   if(!isLoss)
   {
      primary = "NEUTRAL_OBSERVATION";
      reason_csv = "FLAT_OR_UNKNOWN_OUTCOME";
      return;
   }

   if(ctx.advisory_contradiction_flag)
   {
      primary = "CONTRADICTION_IGNORED";
      reason_csv = "ADVISORY_CONTRADICTION_PRESENT";
   }
   else if(srConflicted)
   {
      primary = "POOR_LEVEL_REACTION_QUALITY";
      reason_csv = "SR_CONFLICT_OR_REJECTION_RISK";
   }
   else if(continuationObstructed || (reversalRisk && weakFT))
   {
      primary = "FALSE_CONTINUATION";
      reason_csv = "CONTINUATION_PATH_OBSTRUCTED";
   }
   else if(highVol)
   {
      primary = "ADVERSE_VOLATILITY_REGIME";
      reason_csv = "HIGH_VOLATILITY_LOSS";
   }
   else if(lowDQ)
   {
      primary = "BAD_SETUP";
      reason_csv = "LOW_DECISION_QUALITY";
   }
   else if(poorGeom)
   {
      primary = "BAD_TIMING";
      reason_csv = "ADVERSE_EXECUTION_GEOMETRY";
   }
   else if(dirty)
   {
      primary = "BAD_ENVIRONMENT";
      reason_csv = "DIRTY_OR_NOISY_CONTEXT";
   }
   else if(lowVol)
   {
      primary = "WEAK_PARTICIPATION";
      reason_csv = "LOW_PARTICIPATION_CONTEXT";
   }
   else
   {
      primary = "INSUFFICIENT_CONFIRMATION";
      reason_csv = "NO_STRONG_FAILURE_CLASSIFIER";
   }

   if(lowDQ && primary != "BAD_SETUP")
      secondary = "BAD_SETUP";
   else if(poorGeom && primary != "BAD_TIMING")
      secondary = "BAD_TIMING";
   else if(dirty && primary != "BAD_ENVIRONMENT")
      secondary = "BAD_ENVIRONMENT";
}

void ILV1_UpdateMotifFromOutcome(ILV1_MotifStat &m,
                                 string result,
                                 string primary_attr,
                                 string secondary_attr,
                                 string reason_csv)
{
   double outcomeSignal = 0.0;
   string token = "F";

   if(result == "WIN")
   {
      m.win_count++;
      outcomeSignal = 1.0;
      token = "W";
   }
   else if(result == "LOSS")
   {
      m.loss_count++;
      outcomeSignal = -1.0;
      token = "L";
   }
   else
   {
      m.flat_count++;
      outcomeSignal = 0.0;
      token = "F";
   }

   m.evidence_count++;
   m.recent_outcomes += token;
   ILV1_TrimRecentOutcomes(m.recent_outcomes);

   double cautionObs = (result == "LOSS" ? 1.0 : (result == "WIN" ? 0.0 : 0.5));
   double contextObs = (result == "WIN" ? 0.75 : (result == "LOSS" ? 0.25 : 0.50));

   m.net_edge_ewma = ((1.0 - ILV1_EWMA_ALPHA) * m.net_edge_ewma) + (ILV1_EWMA_ALPHA * outcomeSignal);
   m.caution_ewma = ((1.0 - ILV1_EWMA_ALPHA) * m.caution_ewma) + (ILV1_EWMA_ALPHA * cautionObs);
   m.context_fit_ewma = ((1.0 - ILV1_EWMA_ALPHA) * m.context_fit_ewma) + (ILV1_EWMA_ALPHA * contextObs);

   m.net_edge_ewma = ILV1_Clamp(m.net_edge_ewma, -1.0, 1.0);
   m.caution_ewma = ILV1_Clamp01(m.caution_ewma);
   m.context_fit_ewma = ILV1_Clamp01(m.context_fit_ewma);

   m.last_primary_attribution = primary_attr;
   m.last_secondary_attribution = secondary_attr;
   m.last_reason_codes_csv = reason_csv;
   m.last_updated = TimeCurrent();
}

string ILV1_BuildEventJson(const TradeFeedbackRecord &fb,
                           const ILV1_DecisionContext &ctx,
                           const string primary_attr,
                           const string secondary_attr,
                           const string reason_csv)
{
   string decision_id = TrimString(fb.decision_id);
   if(StringLen(decision_id) <= 0)
      decision_id = TrimString(fb.correlated_decision_id);
   string decision_link_key = ILV1_BuildDecisionLinkKey(
      (StringLen(ctx.decision_id) > 0 ? ctx.decision_id : decision_id)
   );
   string trade_lineage_key = ILV1_BuildTradeLineageKey(decision_id, fb.position_id, fb.close_deal_id);
   datetime entry_time = ILV1_ResolveEntryTime(fb);
   datetime exit_time = ILV1_ResolveExitTime(fb);

   string j = "{";
   j += "\"record_type\":\"LEARNING_EVENT\"";
   j += ",\"event_family\":\"INSTITUTIONAL_SELF_LEARNING\"";
   j += ",\"captured_at\":\"" + ILV1_EscapeJson(ILV1_TimeText(TimeCurrent())) + "\"";
   j += ",\"trade_lineage_key\":\"" + ILV1_EscapeJson(trade_lineage_key) + "\"";
   j += ",\"symbol\":\"" + ILV1_EscapeJson(fb.symbol) + "\"";
   j += ",\"decision_id\":\"" + ILV1_EscapeJson(decision_id) + "\"";
   j += ",\"decision_link_key\":\"" + ILV1_EscapeJson(decision_link_key) + "\"";
   j += ",\"correlated_decision_id\":\"" + ILV1_EscapeJson(fb.correlated_decision_id) + "\"";
   j += ",\"position_id\":" + ILV1_U64Text(fb.position_id);
   j += ",\"entry_deal_id\":" + ILV1_U64Text(fb.entry_deal_id);
   j += ",\"close_deal_id\":" + ILV1_U64Text(fb.close_deal_id);
   j += ",\"entry_time\":\"" + ILV1_EscapeJson(ILV1_TimeText(entry_time)) + "\"";
   j += ",\"exit_time\":\"" + ILV1_EscapeJson(ILV1_TimeText(exit_time)) + "\"";
   j += ",\"trade_result\":\"" + ILV1_EscapeJson(fb.result) + "\"";
   j += ",\"profit\":" + DoubleToString(fb.profit, 2);
   j += ",\"regime_label\":\"" + ILV1_EscapeJson(fb.regime_label) + "\"";
   j += ",\"volatility_state\":\"" + ILV1_EscapeJson(fb.rc_volatility_state) + "\"";
   j += ",\"structure_state\":\"" + ILV1_EscapeJson(fb.rc_structure_state) + "\"";
   j += ",\"runtime_strategy_id_exact\":\"" + ILV1_EscapeJson(ctx.strategy_id) + "\"";
   j += ",\"runtime_strategy_family_exact\":\"" + ILV1_EscapeJson(ctx.strategy_family) + "\"";
   j += ",\"feedback_strategy_id\":\"" + ILV1_EscapeJson(fb.main_trigger_name) + "\"";
   j += ",\"aggregated_strategy_bucket\":\"" + ILV1_EscapeJson(ctx.strategy_id) + "\"";
   j += ",\"strategy_id\":\"" + ILV1_EscapeJson(ctx.strategy_id) + "\"";
   j += ",\"strategy_family\":\"" + ILV1_EscapeJson(ctx.strategy_family) + "\"";
   j += ",\"direction\":\"" + ILV1_EscapeJson(ctx.direction) + "\"";
   j += ",\"motif_key\":\"" + ILV1_EscapeJson(ctx.motif_key) + "\"";
   j += ",\"setup_quality_bucket\":\"" + ILV1_EscapeJson(ctx.setup_quality_bucket) + "\"";
   j += ",\"sr_interaction_bucket\":\"" + ILV1_EscapeJson(ctx.sr_interaction_bucket) + "\"";
   j += ",\"support_resistance_confluence_state\":\"" + ILV1_EscapeJson(ctx.support_resistance_confluence_state) + "\"";
   j += ",\"canonical_level_state\":\"" + ILV1_EscapeJson(ctx.canonical_level_state) + "\"";
   j += ",\"sr_confluence_flag\":" + ILV1_BoolText(ctx.sr_confluence_flag);
   j += ",\"sr_rejection_risk_flag\":" + ILV1_BoolText(ctx.sr_rejection_risk_flag);
   j += ",\"sr_continuation_obstructed_flag\":" + ILV1_BoolText(ctx.sr_continuation_obstructed_flag);
   j += ",\"sr_canonical_near_flag\":" + ILV1_BoolText(ctx.sr_canonical_near_flag);
   j += ",\"sr_conflicted_flag\":" + ILV1_BoolText(ctx.sr_conflicted_flag);
   j += ",\"advisory_contradiction_flag\":" + ILV1_BoolText(ctx.advisory_contradiction_flag);
   j += ",\"advisory_relevance_score\":" + DoubleToString(ILV1_Clamp01(ctx.advisory_relevance_score), 3);
   j += ",\"advisory_reason_summary\":\"" + ILV1_EscapeJson(ctx.advisory_reason_summary) + "\"";
   j += ",\"runtime_primary_attribution\":\"" + ILV1_EscapeJson(primary_attr) + "\"";
   j += ",\"runtime_secondary_attribution\":\"" + ILV1_EscapeJson(secondary_attr) + "\"";
   j += ",\"aggregated_primary_attribution\":\"" + ILV1_EscapeJson(primary_attr) + "\"";
   j += ",\"aggregated_secondary_attribution\":\"" + ILV1_EscapeJson(secondary_attr) + "\"";
   j += ",\"primary_attribution\":\"" + ILV1_EscapeJson(primary_attr) + "\"";
   j += ",\"secondary_attribution\":\"" + ILV1_EscapeJson(secondary_attr) + "\"";
   j += ",\"attribution_reason_codes_csv\":\"" + ILV1_EscapeJson(reason_csv) + "\"";
   j += ",\"non_authoritative_notice\":\"learning_event_non_executive_advisory_only\"";
   j += "}";
   return j;
}

bool ILV1_BuildContextFromRouted(const string decision_id,
                                 const string direction,
                                 const RoutedRuntimeEvaluation &routed,
                                 const RegimeClassification &reg,
                                 const UnifiedDecisionConfidence &conf,
                                 ILV1_DecisionContext &ctx)
{
   ILV1_InitDecisionContext(ctx);

   if(StringLen(TrimString(decision_id)) <= 0)
      return false;

   ctx.valid = true;
   ctx.captured_at = TimeCurrent();
   ctx.decision_id = decision_id;
   ctx.symbol = _Symbol;
   ctx.direction = TrimString(direction);
   if(StringLen(ctx.direction) <= 0)
      ctx.direction = TrimString(conf.direction);
   if(StringLen(ctx.direction) <= 0)
      ctx.direction = "UNKNOWN";

   ctx.regime_bucket = (StringLen(TrimString(reg.regime_label)) > 0 ? reg.regime_label : "UNKNOWN_REGIME");
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
      ctx.zone_bucket = CouncilZoneTypeToText(routed.council.env.zone_type);
   ctx.volatility_bucket = (StringLen(TrimString(reg.volatility_state)) > 0 ? reg.volatility_state : "UNKNOWN_VOL");
   ctx.structure_bucket = (StringLen(TrimString(reg.structure_state)) > 0 ? reg.structure_state : "UNKNOWN_STRUCTURE");
   ctx.setup_quality_bucket = ILV1_BucketSetupQuality(conf.decision_quality_label, conf.entry_edge_label, conf.follow_through_quality_label);

   ctx.decision_quality_label = conf.decision_quality_label;
   ctx.entry_quality_label = conf.entry_quality_label;
   ctx.entry_edge_label = conf.entry_edge_label;
   ctx.follow_through_label = conf.follow_through_quality_label;
   ctx.execution_geometry_label = conf.execution_geometry_label;
   ctx.expected_rr_estimate = conf.expected_rr_estimate;

   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      ctx.strategy_id = routed.council.aggregate.best_strategy_id;
      ctx.strategy_family = ILV1_InferStrategyFamily(ctx.strategy_id);
      ctx.advisory_contradiction_flag = routed.council.env.atas_advisory_contradiction;
      ctx.advisory_hold_bias_active = routed.council.env.atas_advisory_hold_bias_active;
      ctx.advisory_relevance_score = routed.council.env.atas_advisory_relevance_score;
      ctx.advisory_reason_summary = routed.council.env.atas_advisory_summary;
      ctx.support_resistance_confluence_state = routed.council.env.atas_advisory_level_confluence_state;
      ctx.canonical_level_state = routed.council.env.atas_advisory_level_confluence_state;
      ctx.sr_interaction_bucket = ILV1_BucketSrInteraction(ctx.support_resistance_confluence_state);
      ILV1_ApplySrFlags(ctx);
   }
   else
   {
      ctx.strategy_id = "NON_COUNCIL_CONTEXT";
      ctx.strategy_family = "UNKNOWN";
      ctx.sr_interaction_bucket = "SR_UNKNOWN";
      ctx.support_resistance_confluence_state = "UNSET";
      ctx.canonical_level_state = "UNSET";
      ctx.advisory_contradiction_flag = false;
      ctx.advisory_hold_bias_active = false;
      ctx.advisory_relevance_score = 0.0;
      ctx.advisory_reason_summary = "advisory_unavailable";
      ILV1_ApplySrFlags(ctx);
   }

   if(StringLen(ctx.strategy_id) <= 0)
      ctx.strategy_id = "UNKNOWN_STRATEGY";
   if(StringLen(ctx.strategy_family) <= 0)
      ctx.strategy_family = ILV1_InferStrategyFamily(ctx.strategy_id);

   ctx.motif_key = ILV1_BuildMotifKey(ctx);
   return true;
}

bool ILV1_Initialize(const bool learning_enabled, string &logMessage)
{
   logMessage = "";
   FolderCreate("AI");

   ILV1_InitStatus(gILV1Status);
   gILV1Status.learning_enabled = learning_enabled;
   gILV1Status.initialized = true;
   gILV1Status.state_code = "INITIALIZED";
   gILV1Status.reason_codes_csv = "INIT_OK";
   gILV1Status.evaluated_at = TimeCurrent();

   if(!FileIsExist(ILV1_EVENTS_PATH))
      ILV1_WriteText(ILV1_EVENTS_PATH, "");
   if(!FileIsExist(ILV1_CONTEXT_PATH))
      ILV1_WriteText(ILV1_CONTEXT_PATH, "");
   if(!FileIsExist(ILV1_LINEAGE_PATH))
      ILV1_WriteText(ILV1_LINEAGE_PATH, "");
   if(!FileIsExist(ILV1_LINEAGE_STATUS_PATH))
      ILV1_WriteText(ILV1_LINEAGE_STATUS_PATH, "{}");

   gILV1TotalEvents = 0;
   gILV1LineageRecords = 0;
   gILV1LineageDegradedRecords = 0;
   ArrayResize(gILV1Motifs, 0);

   string lines[];
   if(ILV1_ReadAllLines(ILV1_EVENTS_PATH, lines))
   {
      for(int i = 0; i < ArraySize(lines); i++)
      {
         string ln = lines[i];
         string key = "";
         if(!ExtractJsonStringField(ln, "motif_key", key) || StringLen(TrimString(key)) <= 0)
            continue;

         ILV1_DecisionContext ctx;
         ILV1_InitDecisionContext(ctx);
         ctx.valid = true;
         ctx.motif_key = key;
         ExtractJsonStringField(ln, "strategy_id", ctx.strategy_id);
         ExtractJsonStringField(ln, "strategy_family", ctx.strategy_family);
         ExtractJsonStringField(ln, "direction", ctx.direction);
         ExtractJsonStringField(ln, "regime_label", ctx.regime_bucket);
         ExtractJsonStringField(ln, "volatility_state", ctx.volatility_bucket);
         ExtractJsonStringField(ln, "structure_state", ctx.structure_bucket);
         ExtractJsonStringField(ln, "setup_quality_bucket", ctx.setup_quality_bucket);
         ExtractJsonStringField(ln, "sr_interaction_bucket", ctx.sr_interaction_bucket);
         ExtractJsonBoolField(ln, "advisory_contradiction_flag", ctx.advisory_contradiction_flag);

         if(StringLen(ctx.strategy_id) <= 0) ctx.strategy_id = "UNKNOWN_STRATEGY";
         if(StringLen(ctx.strategy_family) <= 0) ctx.strategy_family = ILV1_InferStrategyFamily(ctx.strategy_id);
         if(StringLen(ctx.direction) <= 0) ctx.direction = "UNKNOWN";
         if(StringLen(ctx.regime_bucket) <= 0) ctx.regime_bucket = "UNKNOWN_REGIME";
         if(StringLen(ctx.volatility_bucket) <= 0) ctx.volatility_bucket = "UNKNOWN_VOL";
         if(StringLen(ctx.structure_bucket) <= 0) ctx.structure_bucket = "UNKNOWN_STRUCTURE";
         if(StringLen(ctx.setup_quality_bucket) <= 0) ctx.setup_quality_bucket = "SETUP_NEUTRAL";
         if(StringLen(ctx.sr_interaction_bucket) <= 0) ctx.sr_interaction_bucket = "SR_UNKNOWN";

         int idx = ILV1_EnsureMotif(ctx);

         string result = "";
         string primary_attr = "";
         string secondary_attr = "";
         string reason_csv = "";
         ExtractJsonStringField(ln, "trade_result", result);
         ExtractJsonStringField(ln, "primary_attribution", primary_attr);
         ExtractJsonStringField(ln, "secondary_attribution", secondary_attr);
         ExtractJsonStringField(ln, "attribution_reason_codes_csv", reason_csv);
         ILV1_UpdateMotifFromOutcome(gILV1Motifs[idx], result, primary_attr, secondary_attr, reason_csv);
         gILV1TotalEvents++;
      }
   }

   string lineageLines[];
   if(ILV1_ReadAllLines(ILV1_LINEAGE_PATH, lineageLines))
   {
      gILV1LineageRecords = ArraySize(lineageLines);
      for(int i = 0; i < ArraySize(lineageLines); i++)
      {
         string one = lineageLines[i];
         string s = "";
         if(ExtractJsonStringField(one, "identity_linkage_status", s) && s != "PRESERVED")
         {
            gILV1LineageDegradedRecords++;
            continue;
         }
         if(ExtractJsonStringField(one, "strategy_lineage_status", s) && s != "PRESERVED")
         {
            gILV1LineageDegradedRecords++;
            continue;
         }
         if(ExtractJsonStringField(one, "sr_lineage_status", s) && s != "PRESERVED")
         {
            gILV1LineageDegradedRecords++;
            continue;
         }
         if(ExtractJsonStringField(one, "attribution_lineage_status", s) && s != "PRESERVED")
            gILV1LineageDegradedRecords++;
      }
   }

   gILV1Status.motif_count = ArraySize(gILV1Motifs);
   gILV1Status.total_events = gILV1TotalEvents;
   gILV1Status.state_code = (learning_enabled ? "READY" : "DISABLED_BY_INPUT");
   gILV1Status.reason_codes_csv = (learning_enabled ? "READY_FOR_BOUNDED_SHAPING" : "LEARNING_DISABLED");
   gILV1Status.evaluated_at = TimeCurrent();
   ILV1_SaveDerivedArtifacts();

   gILV1Initialized = true;
   logMessage = "Institutional learning initialized | motifs=" + IntegerToString(gILV1Status.motif_count) +
                " | events=" + IntegerToString(gILV1Status.total_events) +
                " | lineage_records=" + IntegerToString(gILV1LineageRecords) +
                " | state=" + gILV1Status.state_code;
   return true;
}

bool ILV1_RecordDecisionContext(const string decision_id,
                                const string direction,
                                const RoutedRuntimeEvaluation &routed,
                                const RegimeClassification &reg,
                                const UnifiedDecisionConfidence &conf,
                                string &logMessage)
{
   logMessage = "";
   if(!gILV1Initialized)
      ILV1_Initialize(true, logMessage);

   ILV1_DecisionContext ctx;
   if(!ILV1_BuildContextFromRouted(decision_id, direction, routed, reg, conf, ctx))
   {
      logMessage = "ILV1 context capture skipped: missing decision_id";
      return false;
   }

   if(!ILV1_AppendLine(ILV1_CONTEXT_PATH, ILV1_ContextToJson(ctx)))
   {
      logMessage = "ILV1 context capture failed: write_error";
      return false;
   }

   logMessage = "ILV1 context captured | decision_id=" + ctx.decision_id + " | motif_key=" + ctx.motif_key;
   return true;
}

bool ILV1_EnrichTradeFeedbackContext(TradeFeedbackRecord &fb, string &logMessage)
{
   logMessage = "";
   if(!gILV1Initialized)
      ILV1_Initialize(true, logMessage);

   string did = TrimString(fb.decision_id);
   if(StringLen(did) <= 0)
      did = TrimString(fb.correlated_decision_id);
   if(StringLen(did) <= 0)
      ILV1_ResolveDecisionIdFromFeedbackDeals(fb, did);

   if(StringLen(did) <= 0)
   {
      logMessage = "ILV1 feedback enrichment skipped: no decision_id";
      return false;
   }

   ILV1_DecisionContext ctx;
   if(!ILV1_FindContextByDecisionId(did, ctx))
   {
      logMessage = "ILV1 feedback enrichment skipped: context_not_found";
      return false;
   }

   if(StringLen(TrimString(fb.decision_id)) <= 0)
      fb.decision_id = did;
   if(StringLen(TrimString(fb.correlated_decision_id)) <= 0)
      fb.correlated_decision_id = did;

   fb.linked_runtime_strategy_id = ctx.strategy_id;
   fb.linked_runtime_strategy_family = ctx.strategy_family;
   fb.linked_support_resistance_bucket = ctx.sr_interaction_bucket;
   fb.linked_support_resistance_state =
      (StringLen(TrimString(ctx.support_resistance_confluence_state)) > 0 ?
       ctx.support_resistance_confluence_state :
       ctx.sr_interaction_bucket);
   fb.linked_canonical_level_state = ctx.canonical_level_state;
   fb.linked_sr_confluence_flag = ctx.sr_confluence_flag;
   fb.linked_sr_rejection_risk_flag = ctx.sr_rejection_risk_flag;
   fb.linked_sr_continuation_obstructed_flag = ctx.sr_continuation_obstructed_flag;
   fb.linked_sr_canonical_near_flag = ctx.sr_canonical_near_flag;
   fb.linked_sr_conflicted_flag = ctx.sr_conflicted_flag;
   fb.linked_advisory_contradiction_flag = ctx.advisory_contradiction_flag;
   fb.linked_advisory_relevance_score = ctx.advisory_relevance_score;
   fb.linked_learning_motif_key = ctx.motif_key;
   fb.linked_learning_context_found = true;

   if(StringLen(fb.linked_entry_quality_label) <= 0)          fb.linked_entry_quality_label = ctx.entry_quality_label;
   if(StringLen(fb.linked_decision_quality_label) <= 0)       fb.linked_decision_quality_label = ctx.decision_quality_label;
   if(StringLen(fb.linked_entry_edge_label) <= 0)             fb.linked_entry_edge_label = ctx.entry_edge_label;
   if(StringLen(fb.linked_follow_through_quality_label) <= 0) fb.linked_follow_through_quality_label = ctx.follow_through_label;
   if(StringLen(fb.linked_execution_geometry_label) <= 0)     fb.linked_execution_geometry_label = ctx.execution_geometry_label;
   if(fb.linked_expected_rr_estimate <= 0.0)                  fb.linked_expected_rr_estimate = ctx.expected_rr_estimate;
   if(StringLen(fb.linked_strategy_regime_fit_label) <= 0)    fb.linked_strategy_regime_fit_label = "CONTEXT_LINKED";

   if(StringLen(fb.outcome_quality_summary) <= 0)
   {
      ComputeOutcomeQualitySummaryV1(
         fb.profit,
         fb.linked_decision_quality_label,
         fb.linked_entry_edge_label,
         fb.linked_execution_geometry_label,
         fb.linked_expected_rr_estimate,
         fb.outcome_vs_entry_quality,
         fb.outcome_vs_execution_geometry,
         fb.outcome_vs_expected_rr,
         fb.outcome_quality_summary
      );
   }

   logMessage = "ILV1 feedback enriched | decision_id=" + did + " | motif_key=" + ctx.motif_key;
   return true;
}

bool ILV1_RecordClosedTradeOutcome(TradeFeedbackRecord &fb, string &logMessage)
{
   logMessage = "";
   if(!gILV1Initialized)
      ILV1_Initialize(true, logMessage);

   ILV1_DecisionContext ctx;
   ILV1_InitDecisionContext(ctx);

   string did = TrimString(fb.decision_id);
   if(StringLen(did) <= 0)
      did = TrimString(fb.correlated_decision_id);
   if(StringLen(did) <= 0)
      ILV1_ResolveDecisionIdFromFeedbackDeals(fb, did);
   if(StringLen(TrimString(fb.decision_id)) <= 0 && StringLen(did) > 0)
      fb.decision_id = did;
   if(StringLen(TrimString(fb.correlated_decision_id)) <= 0 && StringLen(did) > 0)
      fb.correlated_decision_id = did;

   bool ctxFound = false;
   if(StringLen(did) > 0)
      ctxFound = ILV1_FindContextByDecisionId(did, ctx);

   if(!ctxFound)
   {
      string strategyFromOpen = "";
      string familyFromOpen = "";
      string regimeFromOpen = "";
      string directionFromOpen = "";
      bool openFound = ILV1_FindStrategyOpenByDecisionId(did, strategyFromOpen, familyFromOpen, regimeFromOpen, directionFromOpen);

      ctx.valid = true;
      ctx.captured_at = TimeCurrent();
      ctx.decision_id = did;
      ctx.symbol = fb.symbol;
      ctx.strategy_id = (StringLen(TrimString(fb.linked_runtime_strategy_id)) > 0 ? fb.linked_runtime_strategy_id :
                        (openFound && StringLen(strategyFromOpen) > 0 ? strategyFromOpen :
                        (StringLen(fb.main_trigger_name) > 0 ? fb.main_trigger_name : "UNKNOWN_STRATEGY")));
      ctx.strategy_family = ILV1_InferStrategyFamily(ctx.strategy_id);
      if(openFound && StringLen(familyFromOpen) > 0)
         ctx.strategy_family = familyFromOpen;
      ctx.direction = (StringLen(fb.direction) > 0 ? fb.direction :
                      (openFound && StringLen(directionFromOpen) > 0 ? directionFromOpen : "UNKNOWN"));
      ctx.regime_bucket = (StringLen(fb.regime_label) > 0 ? fb.regime_label :
                          (openFound && StringLen(regimeFromOpen) > 0 ? regimeFromOpen : "UNKNOWN_REGIME"));
      ctx.volatility_bucket = (StringLen(fb.rc_volatility_state) > 0 ? fb.rc_volatility_state : "UNKNOWN_VOL");
      ctx.structure_bucket = (StringLen(fb.rc_structure_state) > 0 ? fb.rc_structure_state : "UNKNOWN_STRUCTURE");
      ctx.setup_quality_bucket = ILV1_BucketSetupQuality(fb.linked_decision_quality_label, fb.linked_entry_edge_label, fb.linked_follow_through_quality_label);
      ctx.support_resistance_confluence_state = fb.linked_support_resistance_state;
      ctx.sr_interaction_bucket = (StringLen(TrimString(fb.linked_support_resistance_bucket)) > 0 ?
                                   fb.linked_support_resistance_bucket :
                                   ILV1_BucketSrInteraction(fb.linked_support_resistance_state));
      ctx.canonical_level_state = (StringLen(TrimString(fb.linked_canonical_level_state)) > 0 ?
                                   fb.linked_canonical_level_state :
                                   fb.linked_support_resistance_state);
      ctx.sr_confluence_flag = fb.linked_sr_confluence_flag;
      ctx.sr_rejection_risk_flag = fb.linked_sr_rejection_risk_flag;
      ctx.sr_continuation_obstructed_flag = fb.linked_sr_continuation_obstructed_flag;
      ctx.sr_canonical_near_flag = fb.linked_sr_canonical_near_flag;
      ctx.sr_conflicted_flag = fb.linked_sr_conflicted_flag;
      ctx.advisory_contradiction_flag = fb.linked_advisory_contradiction_flag;
      ctx.advisory_relevance_score = fb.linked_advisory_relevance_score;
      ctx.decision_quality_label = fb.linked_decision_quality_label;
      ctx.entry_quality_label = fb.linked_entry_quality_label;
      ctx.entry_edge_label = fb.linked_entry_edge_label;
      ctx.follow_through_label = fb.linked_follow_through_quality_label;
      ctx.execution_geometry_label = fb.linked_execution_geometry_label;
      ctx.expected_rr_estimate = fb.linked_expected_rr_estimate;
      if(StringLen(TrimString(ctx.support_resistance_confluence_state)) <= 0)
         ctx.support_resistance_confluence_state = ctx.sr_interaction_bucket;
      if(StringLen(TrimString(ctx.canonical_level_state)) <= 0)
         ctx.canonical_level_state = ctx.support_resistance_confluence_state;
      ILV1_ApplySrFlags(ctx);
      ctx.motif_key = ILV1_BuildMotifKey(ctx);
   }
   else
   {
      if(StringLen(TrimString(fb.linked_runtime_strategy_id)) <= 0)
         fb.linked_runtime_strategy_id = ctx.strategy_id;
      if(StringLen(TrimString(fb.linked_runtime_strategy_family)) <= 0)
         fb.linked_runtime_strategy_family = ctx.strategy_family;
      if(StringLen(TrimString(fb.linked_support_resistance_bucket)) <= 0)
         fb.linked_support_resistance_bucket = ctx.sr_interaction_bucket;
      if(StringLen(TrimString(fb.linked_support_resistance_state)) <= 0)
         fb.linked_support_resistance_state = ctx.support_resistance_confluence_state;
      if(StringLen(TrimString(fb.linked_canonical_level_state)) <= 0)
         fb.linked_canonical_level_state = ctx.canonical_level_state;
      fb.linked_sr_confluence_flag = ctx.sr_confluence_flag;
      fb.linked_sr_rejection_risk_flag = ctx.sr_rejection_risk_flag;
      fb.linked_sr_continuation_obstructed_flag = ctx.sr_continuation_obstructed_flag;
      fb.linked_sr_canonical_near_flag = ctx.sr_canonical_near_flag;
      fb.linked_sr_conflicted_flag = ctx.sr_conflicted_flag;
   }

   if(StringLen(ctx.motif_key) <= 0)
      ctx.motif_key = ILV1_BuildMotifKey(ctx);

   string primary = "";
   string secondary = "";
   string reason_csv = "";
   ILV1_ClassifyAttribution(fb, ctx, primary, secondary, reason_csv);

   fb.learning_primary_attribution = primary;
   fb.learning_secondary_attribution = secondary;
   fb.learning_attribution_reason_codes = reason_csv;
   fb.linked_learning_motif_key = ctx.motif_key;
   if(!fb.linked_learning_context_found)
      fb.linked_learning_context_found = ctxFound;

   int idx = ILV1_EnsureMotif(ctx);
   ILV1_UpdateMotifFromOutcome(gILV1Motifs[idx], fb.result, primary, secondary, reason_csv);
   gILV1TotalEvents++;

   string ev = ILV1_BuildEventJson(fb, ctx, primary, secondary, reason_csv);
   ILV1_AppendLine(ILV1_EVENTS_PATH, ev);

   string lineageEvent = ILV1_BuildTradeLineageJson(fb, ctx, primary, secondary, reason_csv, ctxFound);
   ILV1_AppendLine(ILV1_LINEAGE_PATH, lineageEvent);
   gILV1LineageRecords++;

   string tradeLineageKey = ILV1_BuildTradeLineageKey(fb.decision_id, fb.position_id, fb.close_deal_id);
   string identityStatus = ILV1_ClassifyIdentityLineage(fb.decision_id, fb.position_id, fb.close_deal_id);
   string strategyStatus = ILV1_ClassifyStrategyLineage(fb, ctx);
   string srStatus = ILV1_ClassifySrLineage(ctx);
   string advisoryStatus = ILV1_ClassifyAdvisoryLineage(ctx);
   string attributionStatus = ILV1_ClassifyAttributionLineage(primary, secondary);
   ILV1_WriteLineageStatus(
      tradeLineageKey,
      identityStatus,
      strategyStatus,
      srStatus,
      advisoryStatus,
      attributionStatus,
      reason_csv
   );

   gILV1Status.motif_count = ArraySize(gILV1Motifs);
   gILV1Status.total_events = gILV1TotalEvents;
   gILV1Status.state_code = "UPDATED_FROM_CLOSED_TRADE";
   gILV1Status.reason_codes_csv = reason_csv;
   gILV1Status.last_motif_key = ctx.motif_key;
   gILV1Status.last_evidence_count = gILV1Motifs[idx].evidence_count;
   gILV1Status.last_confidence_delta = 0.0;
   gILV1Status.last_caution_score = 0.0;
   gILV1Status.last_context_fit_score = gILV1Motifs[idx].context_fit_ewma;
   gILV1Status.last_contradiction_signal = ctx.advisory_contradiction_flag;
   gILV1Status.last_hold_bias = false;
   gILV1Status.last_reevaluation_bias = false;
   gILV1Status.last_strength_band = "POST_TRADE_UPDATE";
   gILV1Status.evaluated_at = TimeCurrent();

   ILV1_SaveDerivedArtifacts();

   logMessage = "ILV1 outcome recorded | motif=" + ctx.motif_key +
                " | evidence=" + IntegerToString(gILV1Motifs[idx].evidence_count) +
                " | attribution=" + primary;
   return true;
}

bool ILV1_ComputeAdjustment(const bool learning_enabled,
                            const RoutedRuntimeEvaluation &routed,
                            const RegimeClassification &reg,
                            const UnifiedDecisionConfidence &conf,
                            ILV1_Adjustment &outAdj)
{
   ILV1_InitAdjustment(outAdj);

   if(!gILV1Initialized)
   {
      string initLog = "";
      ILV1_Initialize(learning_enabled, initLog);
   }

   if(!learning_enabled)
   {
      outAdj.state_code = "LEARNING_DISABLED";
      outAdj.reason_codes_csv = "LEARNING_DISABLED_BY_INPUT";
      gILV1Status.learning_enabled = false;
      gILV1Status.state_code = outAdj.state_code;
      gILV1Status.reason_codes_csv = outAdj.reason_codes_csv;
      gILV1Status.evaluated_at = TimeCurrent();
      ILV1_SaveDerivedArtifacts();
      return false;
   }

   if(conf.direction != "BUY" && conf.direction != "SELL")
   {
      outAdj.state_code = "NON_TRADE_DECISION";
      outAdj.reason_codes_csv = "NO_TRADE_DIRECTION";
      gILV1Status.learning_enabled = true;
      gILV1Status.state_code = outAdj.state_code;
      gILV1Status.reason_codes_csv = outAdj.reason_codes_csv;
      gILV1Status.evaluated_at = TimeCurrent();
      ILV1_SaveDerivedArtifacts();
      return false;
   }

   ILV1_DecisionContext ctx;
   if(!ILV1_BuildContextFromRouted("LIVE_EVAL", conf.direction, routed, reg, conf, ctx))
   {
      outAdj.state_code = "CONTEXT_BUILD_FAILED";
      outAdj.reason_codes_csv = "LIVE_CONTEXT_UNAVAILABLE";
      return false;
   }

   int idx = ILV1_FindMotifIndex(ctx.motif_key);
   if(idx < 0)
   {
      outAdj.state_code = "NO_MATCHED_MOTIF";
      outAdj.reason_codes_csv = "NO_MEMORY_FOR_CONTEXT";
      outAdj.motif_key = ctx.motif_key;
      return false;
   }

   ILV1_MotifStat m = gILV1Motifs[idx];
   outAdj.motif_key = m.motif_key;
   outAdj.evidence_count = m.evidence_count;

   if(m.evidence_count < ILV1_MIN_EVIDENCE_ANY)
   {
      outAdj.state_code = "INSUFFICIENT_EVIDENCE";
      outAdj.reason_codes_csv = "INSUFFICIENT_EVIDENCE";
      return false;
   }

   double reliability = ILV1_Clamp01((double)m.evidence_count / 30.0);
   double instability = ILV1_RecentInstabilityScore(m.recent_outcomes);
   double driftScale = 1.0 - MathMin(0.65, instability * 0.65);
   double signedStrength = ILV1_Clamp(m.net_edge_ewma, -1.0, 1.0);

   if(signedStrength > 0.0 && m.evidence_count < ILV1_MIN_EVIDENCE_STRENGTHEN)
      signedStrength = 0.0;
   if(signedStrength < 0.0 && m.evidence_count < ILV1_MIN_EVIDENCE_PENALIZE)
      signedStrength = 0.0;

   double delta = signedStrength * ILV1_CONFIDENCE_DELTA_CAP * reliability * driftScale;
   double caution = 0.0;
   if(signedStrength < 0.0)
      caution = MathMin(ILV1_CAUTION_CAP, (-signedStrength) * ILV1_CAUTION_CAP * reliability * driftScale);

   double contextFit = ILV1_Clamp01(0.65 * m.context_fit_ewma + 0.35 * (0.5 + 0.5 * signedStrength));
   bool contradictionSignal = (m.advisory_contradiction_flag && m.loss_count > m.win_count);

   outAdj.applied = true;
   outAdj.state_code = "APPLIED";
   outAdj.confidence_delta = ILV1_Clamp(delta, -ILV1_CONFIDENCE_DELTA_CAP, ILV1_CONFIDENCE_DELTA_CAP);
   outAdj.caution_score = ILV1_Clamp(caution, 0.0, ILV1_CAUTION_CAP);
   outAdj.context_fit_score = contextFit;
   outAdj.contradiction_signal = contradictionSignal;
   outAdj.hold_bias = (outAdj.caution_score >= 0.07);
   outAdj.reevaluation_bias = (outAdj.caution_score >= 0.04 || contradictionSignal);
   outAdj.strength_band = ILV1_AdjustmentBand(MathAbs(outAdj.confidence_delta), outAdj.caution_score);

   string reasons = "EVIDENCE_OK";
   if(instability > 0.50) reasons += ",DRIFT_GUARD_ACTIVE";
   if(outAdj.caution_score > 0.0) reasons += ",CAUTION_SHAPING";
   if(outAdj.confidence_delta > 0.0) reasons += ",EDGE_STRENGTHENING";
   if(outAdj.confidence_delta < 0.0) reasons += ",EDGE_PENALIZING";
   if(contradictionSignal) reasons += ",CONTRADICTION_SIGNAL";
   outAdj.reason_codes_csv = reasons;

   gILV1Status.learning_enabled = true;
   gILV1Status.state_code = outAdj.state_code;
   gILV1Status.reason_codes_csv = outAdj.reason_codes_csv;
   gILV1Status.last_motif_key = outAdj.motif_key;
   gILV1Status.last_evidence_count = outAdj.evidence_count;
   gILV1Status.last_confidence_delta = outAdj.confidence_delta;
   gILV1Status.last_caution_score = outAdj.caution_score;
   gILV1Status.last_context_fit_score = outAdj.context_fit_score;
   gILV1Status.last_contradiction_signal = outAdj.contradiction_signal;
   gILV1Status.last_hold_bias = outAdj.hold_bias;
   gILV1Status.last_reevaluation_bias = outAdj.reevaluation_bias;
   gILV1Status.last_strength_band = outAdj.strength_band;
   gILV1Status.evaluated_at = TimeCurrent();
   ILV1_SaveDerivedArtifacts();

   return true;
}

#endif
