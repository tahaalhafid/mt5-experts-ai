#ifndef __AI_EVOLUTION_ENGINE_MQH__
#define __AI_EVOLUTION_ENGINE_MQH__

#include "config_loader.mqh"
#include "ai_bridge.mqh"
#include "evolution_governor.mqh"
#include "journal_analytics.mqh"
#include "performance_journal.mqh"

struct AIEvolutionResult
{
   bool   valid;
   bool   changed_plan;
   string new_plan_json;
   string evolution_reason;
   string raw_response;
};


struct EvolutionProposalMeta
{
   string proposal_reason;
   string proposal_scope;
   string proposal_target_regime;
   string proposal_target_failure_class;
   double proposal_confidence;
   string proposal_risk_class;
   string evidence_summary;
   int    sample_size_used;
   string proposal_action; // NO_ACTION / PROPOSE
};

void InitEvolutionProposalMeta(EvolutionProposalMeta &m)
{
   m.proposal_reason = "";
   m.proposal_scope = "";
   m.proposal_target_regime = "";
   m.proposal_target_failure_class = "";
   m.proposal_confidence = 0.0;
   m.proposal_risk_class = "LOW_RISK_TIGHTENING";
   m.evidence_summary = "";
   m.sample_size_used = 0;
   m.proposal_action = "NO_ACTION";
}

//---------------------------------------------------------
// File save helper
//---------------------------------------------------------
bool SaveTextFileEx(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

//---------------------------------------------------------
// Safe JSON helpers
//---------------------------------------------------------
string AE_JsonEscape(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", "\\r");
   StringReplace(s, "\n", "\\n");
   StringReplace(s, "\t", "\\t");
   return s;
}


string AE_BuildProposalMetaJson(EvolutionProposalMeta &m)
{
   string json = "{";
   json += "\"proposal_action\":\"" + AE_JsonEscape(m.proposal_action) + "\",";
   json += "\"proposal_reason\":\"" + AE_JsonEscape(m.proposal_reason) + "\",";
   json += "\"proposal_scope\":\"" + AE_JsonEscape(m.proposal_scope) + "\",";
   json += "\"proposal_target_regime\":\"" + AE_JsonEscape(m.proposal_target_regime) + "\",";
   json += "\"proposal_target_failure_class\":\"" + AE_JsonEscape(m.proposal_target_failure_class) + "\",";
   json += "\"proposal_confidence\":" + DoubleToString(PJ_Clamp01(m.proposal_confidence), 3) + ",";
   json += "\"proposal_risk_class\":\"" + AE_JsonEscape(m.proposal_risk_class) + "\",";
   json += "\"evidence_summary\":\"" + AE_JsonEscape(m.evidence_summary) + "\",";
   json += "\"sample_size_used\":" + IntegerToString(m.sample_size_used);
   json += "}";
   return json;
}

string AE_NowAsText()
{
   return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

//---------------------------------------------------------
// AI evolution state save helper
//---------------------------------------------------------
bool SaveAIEvolutionStateToJson(string relativePath, AIEvolutionState &st)
{
   string json = "{";
   json += "\"version\":\"" + AE_JsonEscape(st.version) + "\",";
   json += "\"evolution_enabled\":" + string(st.evolution_enabled ? "true" : "false") + ",";
   json += "\"current_generation\":" + IntegerToString(st.current_generation) + ",";
   json += "\"current_plan_id\":\"" + AE_JsonEscape(st.current_plan_id) + "\",";
   json += "\"last_evolution_time\":\"" + AE_JsonEscape(st.last_evolution_time) + "\",";
   json += "\"last_evolution_reason\":\"" + AE_JsonEscape(st.last_evolution_reason) + "\",";
   json += "\"last_evolution_scope\":\"" + AE_JsonEscape(st.last_evolution_scope) + "\",";
   json += "\"last_diagnosis\":\"" + AE_JsonEscape(st.last_diagnosis) + "\",";
   json += "\"min_trades_before_evolution\":" + IntegerToString(st.min_trades_before_evolution) + ",";
   json += "\"small_evolution_min_trades\":" + IntegerToString(st.small_evolution_min_trades) + ",";
   json += "\"medium_evolution_min_trades\":" + IntegerToString(st.medium_evolution_min_trades) + ",";
   json += "\"major_evolution_min_trades\":" + IntegerToString(st.major_evolution_min_trades) + ",";
   json += "\"strong_major_evolution_min_trades\":" + IntegerToString(st.strong_major_evolution_min_trades) + ",";
   json += "\"allow_minor_evolution_anytime\":" + string(st.allow_minor_evolution_anytime ? "true" : "false") + ",";
   json += "\"allow_small_evolution\":" + string(st.allow_small_evolution ? "true" : "false") + ",";
   json += "\"allow_medium_evolution\":" + string(st.allow_medium_evolution ? "true" : "false") + ",";
   json += "\"allow_major_evolution\":" + string(st.allow_major_evolution ? "true" : "false") + ",";
   json += "\"major_evolution_drawdown_trigger\":" + string(st.major_evolution_drawdown_trigger ? "true" : "false") + ",";
   json += "\"major_evolution_underperformance_trigger\":" + string(st.major_evolution_underperformance_trigger ? "true" : "false") + ",";
   json += "\"require_diagnosis_before_evolution\":" + string(st.require_diagnosis_before_evolution ? "true" : "false") + ",";
   json += "\"diagnostic_first_mode\":" + string(st.diagnostic_first_mode ? "true" : "false") + ",";
   json += "\"prefer_smallest_effective_change\":" + string(st.prefer_smallest_effective_change ? "true" : "false") + ",";
   json += "\"forbid_random_trigger_rotation\":" + string(st.forbid_random_trigger_rotation ? "true" : "false") + ",";
   json += "\"prefer_regime_adaptation_before_trigger_change\":" + string(st.prefer_regime_adaptation_before_trigger_change ? "true" : "false") + ",";
   json += "\"require_structural_reason_for_trigger_change\":" + string(st.require_structural_reason_for_trigger_change ? "true" : "false") + ",";
   json += "\"last_observed_trade_count\":" + IntegerToString(st.last_observed_trade_count) + ",";
   json += "\"last_underperformance_flag\":" + string(st.last_underperformance_flag ? "true" : "false") + ",";
   json += "\"consecutive_underperformance_cycles\":" + IntegerToString(st.consecutive_underperformance_cycles) + ",";
   json += "\"last_trigger_change_generation\":" + IntegerToString(st.last_trigger_change_generation) + ",";
   json += "\"last_trigger_change_reason\":\"" + AE_JsonEscape(st.last_trigger_change_reason) + "\",";
   json += "\"trigger_change_cooldown_cycles\":" + IntegerToString(st.trigger_change_cooldown_cycles) + ",";
   json += "\"last_change_improved_performance\":" + string(st.last_change_improved_performance ? "true" : "false") + ",";
   json += "\"failed_major_change_cycles\":" + IntegerToString(st.failed_major_change_cycles) + ",";
   json += "\"notes\":\"" + AE_JsonEscape(st.notes) + "\"";
   json += "}";

   return SaveTextFileEx(relativePath, json);
}

//---------------------------------------------------------
// Read and compress recent trade feedback
//---------------------------------------------------------
string ExtractRecentTradeFeedbackWindow(string feedbackJson, int maxChars)
{
   if(StringLen(feedbackJson) <= maxChars)
      return feedbackJson;

   int start = StringLen(feedbackJson) - maxChars;
   if(start < 0)
      start = 0;

   string tail = StringSubstr(feedbackJson, start);

   int p = StringFind(tail, "{");
   if(p > 0)
      tail = StringSubstr(tail, p);

   return tail;
}

bool LoadRecentTradeFeedbackSnippet(string relativePath, string &outSnippet, int maxChars = 5000)
{
   outSnippet = "";

   string raw = "";
   if(!LoadTextFile(relativePath, raw))
      return false;

   raw = TrimString(raw);
   if(StringLen(raw) == 0)
      return false;

   outSnippet = ExtractRecentTradeFeedbackWindow(raw, maxChars);
   return true;
}

//---------------------------------------------------------
// Feedback diagnostics helpers
//---------------------------------------------------------
int AE_CountOccurrences(string text, string token)
{
   int count = 0;
   int pos   = 0;

   while(true)
   {
      int p = StringFind(text, token, pos);
      if(p < 0)
         break;

      count++;
      pos = p + StringLen(token);
   }

   return count;
}

int AE_CountApproxTradeRecords(string feedbackJson)
{
   string s = TrimString(feedbackJson);
   if(StringLen(s) <= 0)
      return 0;

   int wins   = AE_CountOccurrences(s, "\"WIN\"");
   int losses = AE_CountOccurrences(s, "\"LOSS\"");

   if((wins + losses) > 0)
      return (wins + losses);

   int deals = AE_CountOccurrences(s, "\"deal");
   if(deals > 0)
      return deals;

   int triggers = AE_CountOccurrences(s, "\"trigger\"");
   if(triggers > 0)
      return triggers;

   return 0;
}

double AE_SafeDivide(double a, double b)
{
   if(b == 0.0)
      return 0.0;

   return (a / b);
}

bool AE_ExtractFirstDouble(string json, string key, double &outVal)
{
   return ExtractJsonDoubleField(json, key, outVal);
}

bool AE_ExtractFirstInt(string json, string key, int &outVal)
{
   return ExtractJsonIntField(json, key, outVal);
}

double AE_DetectApproxWinRate(string feedbackJson)
{
   int wins   = AE_CountOccurrences(feedbackJson, "\"WIN\"");
   int losses = AE_CountOccurrences(feedbackJson, "\"LOSS\"");
   int total  = wins + losses;

   if(total > 0)
      return AE_SafeDivide((double)wins, (double)total);

   double wr = 0.0;
   if(AE_ExtractFirstDouble(feedbackJson, "win_rate", wr))
      return wr;

   return -1.0;
}

double AE_DetectApproxAvgTrade(string performanceJsonEnhanced, string feedbackJson)
{
   double v = 0.0;

   if(AE_ExtractFirstDouble(performanceJsonEnhanced, "avg_trade", v))
      return v;

   if(AE_ExtractFirstDouble(performanceJsonEnhanced, "average_trade", v))
      return v;

   if(AE_ExtractFirstDouble(performanceJsonEnhanced, "avg_profit_per_trade", v))
      return v;

   if(AE_ExtractFirstDouble(feedbackJson, "avg_trade", v))
      return v;

   if(AE_ExtractFirstDouble(feedbackJson, "average_trade", v))
      return v;

   return 0.0;
}

bool AE_IsUnderperformanceLikely(
   string performanceJsonEnhanced,
   string feedbackJson,
   int observedTradeCount,
   AIEvolutionState &evState
)
{
   if(observedTradeCount < evState.small_evolution_min_trades)
      return false;

   double wr       = AE_DetectApproxWinRate(feedbackJson);
   double avgTrade = AE_DetectApproxAvgTrade(performanceJsonEnhanced, feedbackJson);

   if(wr >= 0.0 && wr < 0.45)
      return true;

   if(avgTrade < 0.0)
      return true;

   if(observedTradeCount >= evState.major_evolution_min_trades && wr >= 0.0 && wr < 0.50)
      return true;

   return false;
}

string AE_DetectSuggestedChangeScope(
   int observedTradeCount,
   bool underperformance,
   AIEvolutionState &evState
)
{
   if(observedTradeCount < evState.small_evolution_min_trades)
      return "NONE";

   if(observedTradeCount < evState.medium_evolution_min_trades)
      return "SMALL";

   if(observedTradeCount < evState.major_evolution_min_trades)
      return "MEDIUM";

   if(underperformance)
      return "MAJOR_TRIGGER";

   return "MEDIUM";
}

string AE_BuildSampleWindowNote(int observedTradeCount, string allowedScope)
{
   allowedScope = Gov_NormalizeScope(allowedScope);

   string note =
      "observed_trades=" + IntegerToString(observedTradeCount) +
      " | allowed_scope=" + allowedScope;

   if(allowedScope == "NONE")
      note += " | insufficient sample for evolution";

   return note;
}

//---------------------------------------------------------
// plan_id helpers
//---------------------------------------------------------
bool ExtractCurrentPlanId(string currentPlanJson, string &planId)
{
   planId = "";
   return ExtractJsonStringField(currentPlanJson, "plan_id", planId);
}

int ExtractTrailingDigitsAsInt(string s)
{
   string digits = "";

   for(int i = 0; i < StringLen(s); i++)
   {
      ushort c = StringGetCharacter(s, i);
      if(c >= '0' && c <= '9')
         digits += StringSubstr(s, i, 1);
   }

   if(StringLen(digits) <= 0)
      return 0;

   return (int)StringToInteger(digits);
}

string BuildNextPlanIdFromCurrent(string currentPlanId)
{
   int n = ExtractTrailingDigitsAsInt(currentPlanId);
   if(n <= 0)
      n = 1;
   else
      n++;

   string nextNum = IntegerToString(n);

   while(StringLen(nextNum) < 3)
      nextNum = "0" + nextNum;

   return "plan_v" + nextNum;
}

//---------------------------------------------------------
// JSON normalization helpers
//---------------------------------------------------------
string ExtractBalancedJsonObject(string text)
{
   text = TrimString(text);

   int start = StringFind(text, "{");
   if(start < 0)
      return text;

   int  depth    = 0;
   bool inString = false;
   bool escaped  = false;

   for(int i = start; i < StringLen(text); i++)
   {
      ushort c = StringGetCharacter(text, i);

      if(inString)
      {
         if(escaped)
         {
            escaped = false;
         }
         else if(c == '\\')
         {
            escaped = true;
         }
         else if(c == '"')
         {
            inString = false;
         }
      }
      else
      {
         if(c == '"')
         {
            inString = true;
         }
         else if(c == '{')
         {
            depth++;
         }
         else if(c == '}')
         {
            depth--;
            if(depth == 0)
               return StringSubstr(text, start, i - start + 1);
         }
      }
   }

   return StringSubstr(text, start);
}

string NormalizePlanJsonString(string rawPlanJson)
{
   string s = TrimString(rawPlanJson);
   if(StringLen(s) <= 0)
      return s;

   for(int pass = 0; pass < 3; pass++)
   {
      string prev = s;

      s = TrimString(s);

      if(StringLen(s) >= 2)
      {
         ushort first = StringGetCharacter(s, 0);
         ushort last  = StringGetCharacter(s, StringLen(s) - 1);

         if(first == '"' && last == '"')
            s = StringSubstr(s, 1, StringLen(s) - 2);
      }

      s = JsonUnescape(s);
      s = TrimString(s);
      s = ExtractBalancedJsonObject(s);
      s = TrimString(s);

      if(s == prev)
         break;
   }

   return TrimString(s);
}

bool HasNonEmptyPlanId(string planJson, string &planId)
{
   planId = "";

   if(!ExtractJsonStringField(planJson, "plan_id", planId))
      return false;

   planId = TrimString(planId);
   return (StringLen(planId) > 0);
}

bool InjectPlanIdAtObjectStart(string planJson, string desiredPlanId, string &outJson)
{
   outJson = "";

   if(StringLen(TrimString(planJson)) <= 0 || StringLen(TrimString(desiredPlanId)) <= 0)
      return false;

   int p = StringFind(planJson, "{");
   if(p < 0)
      return false;

   string head = StringSubstr(planJson, 0, p + 1);
   string tail = StringSubstr(planJson, p + 1);

   outJson = head + "\"plan_id\":\"" + desiredPlanId + "\"," + tail;
   return true;
}

bool ReplaceExistingPlanId(string planJson, string desiredPlanId, string existingPlanId, string &outJson)
{
   outJson = planJson;

   if(StringLen(TrimString(existingPlanId)) <= 0 || StringLen(TrimString(desiredPlanId)) <= 0)
      return false;

   string oldPattern = "\"plan_id\":\"" + existingPlanId + "\"";
   string newPattern = "\"plan_id\":\"" + desiredPlanId + "\"";

   StringReplace(outJson, oldPattern, newPattern);
   return true;
}

bool EnsurePlanIdExists(
   string currentPlanJson,
   string inputPlanJson,
   string &outputPlanJson,
   string &ensuredPlanId
)
{
   outputPlanJson = NormalizePlanJsonString(inputPlanJson);
   ensuredPlanId  = "";

   string existingPlanId = "";
   if(HasNonEmptyPlanId(outputPlanJson, existingPlanId))
   {
      ensuredPlanId = existingPlanId;
      return true;
   }

   string currentPlanId = "";
   if(!ExtractCurrentPlanId(currentPlanJson, currentPlanId))
      currentPlanId = "plan_v001";

   string nextPlanId = BuildNextPlanIdFromCurrent(currentPlanId);

   string patched = "";
   if(!InjectPlanIdAtObjectStart(outputPlanJson, nextPlanId, patched))
      return false;

   outputPlanJson = patched;
   ensuredPlanId  = nextPlanId;
   return true;
}

//---------------------------------------------------------
// Runtime-safe evolution normalization helpers
//---------------------------------------------------------
bool AE_IsOneOf(string value, string allowedCsv)
{
   value = TrimString(value);
   string work = allowedCsv;

   int start = 0;
   while(start < StringLen(work))
   {
      int sep = StringFind(work, "|", start);
      if(sep < 0)
         sep = StringLen(work);

      string token = StringSubstr(work, start, sep - start);
      token = TrimString(token);

      if(value == token)
         return true;

      start = sep + 1;
   }

   return false;
}

int AE_FindValueEnd(string json, int valueStart)
{
   bool inString = false;
   bool escaped  = false;

   for(int i = valueStart; i < StringLen(json); i++)
   {
      ushort c = StringGetCharacter(json, i);

      if(inString)
      {
         if(escaped)
         {
            escaped = false;
         }
         else if(c == '\\')
         {
            escaped = true;
         }
         else if(c == '"')
         {
            inString = false;
         }
      }
      else
      {
         if(c == '"')
         {
            inString = true;
         }
         else if(c == ',' || c == '}')
         {
            return i;
         }
      }
   }

   return StringLen(json);
}

bool AE_SetJsonRawField(string json, string key, string rawValue, string &outJson)
{
   outJson = json;

   string pattern = "\"" + key + "\"";
   int p = StringFind(outJson, pattern);

   if(p >= 0)
   {
      int colon = StringFind(outJson, ":", p);
      if(colon < 0)
         return false;

      int valueStart = colon + 1;
      while(valueStart < StringLen(outJson))
      {
         ushort c = StringGetCharacter(outJson, valueStart);
         if(c != ' ' && c != '\r' && c != '\n' && c != '\t')
            break;
         valueStart++;
      }

      int valueEnd = AE_FindValueEnd(outJson, valueStart);
      if(valueEnd < valueStart)
         return false;

      outJson =
         StringSubstr(outJson, 0, valueStart) +
         rawValue +
         StringSubstr(outJson, valueEnd);

      return true;
   }

   int brace = StringFind(outJson, "{");
   if(brace < 0)
      return false;

   string insert = "\"" + key + "\":" + rawValue + ",";
   outJson =
      StringSubstr(outJson, 0, brace + 1) +
      insert +
      StringSubstr(outJson, brace + 1);

   return true;
}

bool AE_SetJsonStringField(string json, string key, string value, string &outJson)
{
   return AE_SetJsonRawField(json, key, "\"" + value + "\"", outJson);
}

bool AE_SetJsonBoolField(string json, string key, bool value, string &outJson)
{
   return AE_SetJsonRawField(json, key, value ? "true" : "false", outJson);
}

bool AE_ExtractCurrentMainTrigger(string currentPlanJson, string &triggerName)
{
   triggerName = "";

   if(ExtractJsonStringField(currentPlanJson, "main_trigger_name", triggerName))
   {
      triggerName = TrimString(triggerName);
      if(StringLen(triggerName) > 0)
         return true;
   }

   triggerName = "sweep_detector";
   return true;
}

string AE_SelectSafeMainTrigger(string currentPlanJson, string proposedMainTrigger, string executionArchetype)
{
   proposedMainTrigger = TrimString(proposedMainTrigger);
   executionArchetype  = TrimString(executionArchetype);

   if(proposedMainTrigger == "sweep_detector" || proposedMainTrigger == "bollinger_reclaim_trigger")
      return proposedMainTrigger;

   if(proposedMainTrigger == "ema_trend_alignment")
   {
      if(executionArchetype == "SCALP" || executionArchetype == "HYBRID" || executionArchetype == "EXPERIMENTAL")
      {
         string currentMain = "";
         AE_ExtractCurrentMainTrigger(currentPlanJson, currentMain);

         if(currentMain == "sweep_detector" || currentMain == "bollinger_reclaim_trigger")
            return currentMain;

         return "sweep_detector";
      }

      return proposedMainTrigger;
   }

   string fallback = "";
   AE_ExtractCurrentMainTrigger(currentPlanJson, fallback);
   return fallback;
}

bool NormalizeEvolvedPlanForRuntime(
   string currentPlanJson,
   string inputPlanJson,
   string &outputPlanJson,
   string &normalizationNote
)
{
   outputPlanJson    = NormalizePlanJsonString(inputPlanJson);
   normalizationNote = "";

   if(StringLen(outputPlanJson) <= 0)
      return false;

   string s   = outputPlanJson;
   string tmp = "";

   AE_SetJsonBoolField(s, "require_main_trigger", true, tmp); s = tmp;
   AE_SetJsonBoolField(s, "allow_triggerless_entry", false, tmp); s = tmp;

   string decisionMode = "";
   if(!ExtractJsonStringField(s, "decision_engine_mode", decisionMode) ||
      !AE_IsOneOf(decisionMode, "GATE|SCORE|HYBRID"))
   {
      AE_SetJsonStringField(s, "decision_engine_mode", "HYBRID", tmp); s = tmp;
      normalizationNote += " normalized decision_engine_mode;";
   }

   string execArchetype = "";
   if(!ExtractJsonStringField(s, "execution_archetype", execArchetype) ||
      !AE_IsOneOf(execArchetype, "SCALP|INTRADAY|HYBRID|EXPERIMENTAL"))
   {
      execArchetype = "EXPERIMENTAL";
      AE_SetJsonStringField(s, "execution_archetype", execArchetype, tmp); s = tmp;
      normalizationNote += " normalized execution_archetype;";
   }

   string proposedMainTrigger = "";
   if(!ExtractJsonStringField(s, "main_trigger_name", proposedMainTrigger))
      proposedMainTrigger = "";

   string safeMainTrigger = AE_SelectSafeMainTrigger(currentPlanJson, proposedMainTrigger, execArchetype);
   if(StringLen(safeMainTrigger) > 0)
   {
      AE_SetJsonStringField(s, "main_trigger_name", safeMainTrigger, tmp); s = tmp;
      if(safeMainTrigger != proposedMainTrigger)
         normalizationNote += " normalized main_trigger_name;";
   }

   string v = "";

   if(!ExtractJsonStringField(s, "regime_bonus_trend", v) ||
      !AE_IsOneOf(v, "ANY|RANGE|TREND_BULL|TREND_BEAR"))
   {
      AE_SetJsonStringField(s, "regime_bonus_trend", "ANY", tmp); s = tmp;
      normalizationNote += " normalized regime_bonus_trend;";
   }

   if(!ExtractJsonStringField(s, "regime_bonus_volatility", v) ||
      !AE_IsOneOf(v, "ANY|HIGH_VOL|NORMAL_VOL|LOW_VOL"))
   {
      AE_SetJsonStringField(s, "regime_bonus_volatility", "ANY", tmp); s = tmp;
      normalizationNote += " normalized regime_bonus_volatility;";
   }

   if(!ExtractJsonStringField(s, "regime_bonus_structure", v) ||
      !AE_IsOneOf(v, "ANY|CLEAN|NOISY"))
   {
      AE_SetJsonStringField(s, "regime_bonus_structure", "ANY", tmp); s = tmp;
      normalizationNote += " normalized regime_bonus_structure;";
   }

   if(!ExtractJsonStringField(s, "regime_penalty_trend", v) ||
      !AE_IsOneOf(v, "|RANGE|TREND_BULL|TREND_BEAR"))
   {
      AE_SetJsonStringField(s, "regime_penalty_trend", "", tmp); s = tmp;
      normalizationNote += " normalized regime_penalty_trend;";
   }

   if(!ExtractJsonStringField(s, "regime_penalty_volatility", v) ||
      !AE_IsOneOf(v, "|HIGH_VOL|NORMAL_VOL|LOW_VOL"))
   {
      AE_SetJsonStringField(s, "regime_penalty_volatility", "", tmp); s = tmp;
      normalizationNote += " normalized regime_penalty_volatility;";
   }

   if(!ExtractJsonStringField(s, "regime_penalty_structure", v) ||
      !AE_IsOneOf(v, "|CLEAN|NOISY"))
   {
      AE_SetJsonStringField(s, "regime_penalty_structure", "", tmp); s = tmp;
      normalizationNote += " normalized regime_penalty_structure;";
   }

   outputPlanJson    = NormalizePlanJsonString(s);
   normalizationNote = TrimString(normalizationNote);

   return true;
}

//---------------------------------------------------------
// Scope / diagnosis helpers
//---------------------------------------------------------
string AE_BuildEvolutionScopeInstruction(
   int observedTradeCount,
   bool underperformance,
   AIEvolutionState &evState
)
{
   string scope = AE_DetectSuggestedChangeScope(observedTradeCount, underperformance, evState);

   if(scope == "NONE")
   {
      return
         "INSUFFICIENT_SAMPLE. Observed trades are below the minimum window for evolution. " +
         "Do not change the plan. Return changed_plan=false unless there is a severe runtime safety issue.";
   }

   if(scope == "SMALL")
   {
      return
         "ALLOWED_CHANGE_SCOPE=SMALL. " +
         "You may adjust only thresholds, penalties, bonuses, minor confirmation weights, and minor filter tuning. " +
         "Do NOT change main_trigger_name. " +
         "Do NOT change decision_engine_mode. " +
         "Do NOT redesign architecture.";
   }

   if(scope == "MEDIUM")
   {
      return
         "ALLOWED_CHANGE_SCOPE=MEDIUM. " +
         "You may do SMALL changes plus moderate confirmation restructuring, regime policy refinement, " +
         "filter tuning, and moderate scoring logic tuning. " +
         "Avoid changing main_trigger_name unless diagnosis strongly requires it.";
   }

   return
      "ALLOWED_CHANGE_SCOPE=MAJOR_TRIGGER. " +
      "You may redesign more deeply, including main_trigger_name, only if diagnosis explicitly identifies " +
      "trigger family mismatch or trigger failure. " +
      "Prefer adaptation before replacement.";
}

string AE_BuildDiagnosticDirective()
{
   return
      "DIAGNOSTIC PROCESS REQUIREMENT: " +
      "First determine the dominant root cause from this set: " +
      "TRIGGER_PROBLEM, CONFIRMATION_PROBLEM, THRESHOLD_PROBLEM, FILTER_PROBLEM, " +
      "REGIME_POLICY_PROBLEM, EXIT_PROBLEM, OVERTRADING_PROBLEM, INSUFFICIENT_SAMPLE. " +
      "Then apply the smallest sufficient change. " +
      "Do not rotate triggers for variety. " +
      "Do not treat diversification as a primary goal. " +
      "The primary goal is measurable strategy improvement and better adaptation to market environment.";
}

string AE_BuildChangePolicyDirective()
{
   return
      "CHANGE POLICY: " +
      "1) Keep the current main trigger when the issue can be solved by thresholds, confirmations, filters, or regime policy. " +
      "2) Change main_trigger_name only after diagnosis indicates the trigger family itself is weak or mismatched. " +
      "3) Prefer tuning confirmation structure and regime alignment before trigger replacement. " +
      "4) For high-volatility scalping, market adaptation matters more than random structural change.";
}

string AE_ExtractCurrentMainTriggerFallback(string currentPlanJson)
{
   string triggerName = "";
   if(!AE_ExtractCurrentMainTrigger(currentPlanJson, triggerName))
      return "sweep_detector";

   return triggerName;
}

string AE_DetectAppliedChangeScope(string currentPlanJson, string newPlanJson)
{
   string oldTrigger = AE_ExtractCurrentMainTriggerFallback(currentPlanJson);
   string newTrigger = AE_ExtractCurrentMainTriggerFallback(newPlanJson);

   string oldDecision = "";
   string newDecision = "";

   ExtractJsonStringField(currentPlanJson, "decision_engine_mode", oldDecision);
   ExtractJsonStringField(newPlanJson, "decision_engine_mode", newDecision);

   if(oldTrigger != newTrigger)
      return "MAJOR_TRIGGER";

   if(TrimString(oldDecision) != TrimString(newDecision))
      return "MEDIUM";

   return "SMALL";
}

string AE_DetectDiagnosisLabel(
   string evolutionReason,
   string tradeFeedbackJson,
   string performanceJsonEnhanced,
   int observedTradeCount,
   AIEvolutionState &evState
)
{
   string r = evolutionReason;
   string p = performanceJsonEnhanced;
   string f = tradeFeedbackJson;

   if(observedTradeCount < evState.small_evolution_min_trades)
      return "INSUFFICIENT_SAMPLE";

   if(StringFind(r, "trigger") >= 0 || StringFind(r, "Trigger") >= 0)
      return "TRIGGER_PROBLEM";

   if(StringFind(r, "confirmation") >= 0 || StringFind(r, "Confirm") >= 0)
      return "CONFIRMATION_PROBLEM";

   if(StringFind(r, "threshold") >= 0)
      return "THRESHOLD_PROBLEM";

   if(StringFind(r, "filter") >= 0)
      return "FILTER_PROBLEM";

   if(StringFind(r, "regime") >= 0 || StringFind(r, "market environment") >= 0 || StringFind(r, "environment") >= 0)
      return "REGIME_POLICY_PROBLEM";

   if(StringFind(r, "overtrading") >= 0)
      return "OVERTRADING_PROBLEM";

   if(StringFind(r, "exit") >= 0 || StringFind(r, "trailing") >= 0 || StringFind(r, "risk_reward") >= 0)
      return "EXIT_PROBLEM";

   double wr       = AE_DetectApproxWinRate(f);
   double avgTrade = AE_DetectApproxAvgTrade(p, f);

   if((wr >= 0.0 && wr < 0.50) || avgTrade < 0.0)
      return "REGIME_POLICY_PROBLEM";

   return "THRESHOLD_PROBLEM";
}

//---------------------------------------------------------
// Prompt builders
//---------------------------------------------------------
string BuildEvolutionSystemPrompt(PersonalityProfile &personality)
{
   string prompt =
      "You are an AI Meta-Governor, Experiment Designer, and Strategy Evolution Engine for an MT5 trading system. " +
      "Your job is NOT to decide each trade directly. " +
      "Your job is to redesign the Runtime Core experiment plan using only components from immutable internal libraries. " +
      "You are allowed to create experimental plans that define not only indicator selection, but also weighting logic, trigger logic, confirmation weighting, soft filter penalties, hard blocks, environment bonuses/penalties, and score-based decision policies. " +
      "Treat the EA as an execution sandbox and the plan as an experiment specification. " +
      "You may modify the plan, reorder components, switch trigger family, switch entry patterns, adjust risk parameters, change filters, adjust environment policies, change direction bias, use weighted rules, and redesign the decision engine mode. " +
      "You must learn from overall performance, recent performance, individual trade outcomes, and market regime feedback. " +
      "You must behave as a DIAGNOSTIC optimizer, not a random switcher. " +
      "Your priority is improvement through correct diagnosis and smallest necessary intervention. " +
      "If underperformance persists, changing only parameters may be insufficient; however trigger replacement is still a last-resort structural action. " +
      "You must respect the personality profile and red-line rules. " +
      "You must return STRICT JSON ONLY with exactly these top-level fields: changed_plan, evolution_reason, plan_json. " +
      "The field plan_json must itself be a JSON STRING containing a full plan object. " +
      "The plan_json object MUST include the legacy fields and the experimental design fields. " +
      "The plan_json object MUST ALWAYS contain a non-empty plan_id field. " +
      "If you redesign the plan, generate a valid non-empty plan_id such as plan_v020 or plan_v021. " +
      "Required legacy/core fields include: " +
      "plan_id, enabled, main_timeframe, confirmation_timeframe, main_trigger_name, " +
      "strong_confirmations, medium_confirmations, required_filters, entry_patterns, " +
      "pullback_ratio, breakout_buffer_points, signal_expiry_bars, " +
      "atr_multiplier, risk_reward, time_exit_minutes, move_sl_20_to_10, " +
      "max_open_positions, one_direction_only, cooldown_bars, use_spread_filter, max_spread_points, " +
      "signal_quality_threshold, minimum_confirmation_score, aggression_level, execution_mode, allow_counter_trend, max_trades_per_session, " +
      "allowed_regime_trend, allowed_regime_volatility, allowed_regime_structure, spread_policy_mode. " +
      "Required experimental design fields include: " +
      "plan_mode, execution_archetype, decision_engine_mode, bias_direction, " +
      "use_soft_filters, use_hard_blocks, require_main_trigger, allow_triggerless_entry, " +
      "score_entry_threshold, score_reject_threshold, hard_block_penalty, soft_filter_penalty, counter_trend_penalty, " +
      "spread_penalty_multiplier, regime_alignment_bonus, regime_misalignment_penalty, trigger_missing_penalty, " +
      "confirmation_bonus_multiplier, trigger_bonus_multiplier, filter_penalty_multiplier, environment_bonus_multiplier, " +
      "regime_bonus_trend, regime_bonus_volatility, regime_bonus_structure, " +
      "regime_penalty_trend, regime_penalty_volatility, regime_penalty_structure, " +
      "experiment_family, experiment_note. " +
      "Optional weighted objects are allowed: trigger_weights, confirmation_weights, filter_penalties. " +
      "Allowed main_trigger_name values: bollinger_reclaim_trigger, sweep_detector, ema_trend_alignment. " +
      "Allowed aggression_level values: LOW, NORMAL, HIGH. " +
      "Allowed execution_mode values: NORMAL, CONSERVATIVE, AGGRESSIVE. " +
      "Allowed allowed_regime_trend values: ANY, TREND_ONLY, RANGE_ONLY, TREND_BULL, TREND_BEAR. " +
      "Allowed allowed_regime_volatility values: ANY, HIGH_VOL, NORMAL_VOL, LOW_VOL. " +
      "Allowed allowed_regime_structure values: ANY, CLEAN, NOISY. " +
      "Allowed spread_policy_mode values: FLEXIBLE, NORMAL, STRICT. " +
      "Allowed plan_mode values: LEGACY, WEIGHTED, LAB, HYBRID. " +
      "Allowed execution_archetype values: SCALP, INTRADAY, HYBRID, EXPERIMENTAL. " +
      "Allowed decision_engine_mode values: GATE, SCORE, HYBRID. " +
      "Allowed bias_direction values: BOTH, BUY_ONLY, SELL_ONLY, AUTO. " +
      "IMPORTANT SAFETY RULES: " +
      "For scalping, HYBRID, or EXPERIMENTAL execution archetypes, strongly prefer sweep_detector or bollinger_reclaim_trigger as the main trigger. " +
      "Do not promote ema_trend_alignment to main_trigger_name unless recent evidence clearly shows superior trend-following performance and stable market structure. " +
      "require_main_trigger should remain true unless there is very strong evidence to relax it. " +
      "allow_triggerless_entry should remain false. " +
      "The fields regime_bonus_trend, regime_bonus_volatility, regime_bonus_structure, regime_penalty_trend, regime_penalty_volatility, regime_penalty_structure MUST be STRING ENUMS, not numbers. " +
      "Use only these values for regime_bonus_trend: ANY, RANGE, TREND_BULL, TREND_BEAR. " +
      "Use only these values for regime_bonus_volatility: ANY, HIGH_VOL, NORMAL_VOL, LOW_VOL. " +
      "Use only these values for regime_bonus_structure: ANY, CLEAN, NOISY. " +
      "Use only these values for regime_penalty_trend: empty string, RANGE, TREND_BULL, TREND_BEAR. " +
      "Use only these values for regime_penalty_volatility: empty string, HIGH_VOL, NORMAL_VOL, LOW_VOL. " +
      "Use only these values for regime_penalty_structure: empty string, CLEAN, NOISY. " +
      "Do not invent non-library indicators or strategies. " +
      "Do not omit required fields. " +
      "Do not wrap your answer in markdown. " +
      "When performance is normal, keep the current plan unchanged or perform only minor optimization. " +
      "When performance is poor, redesign only according to diagnosis and allowed scope. " +
      "Personality profile: " + personality.raw_json;

   return prompt;
}

string BuildEvolutionUserPrompt(
   string currentPlanJson,
   string strategyMemoryJson,
   string evolutionStateJson,
   string performanceJsonEnhanced,
   string tradeFeedbackJson,
   string governorInstruction,
   int observedTradeCount,
   string allowedScope,
   AIEvolutionState &evState
)
{
   string currentPlanId = "";
   if(!ExtractCurrentPlanId(currentPlanJson, currentPlanId))
      currentPlanId = "plan_v001";

   string suggestedNextPlanId = BuildNextPlanIdFromCurrent(currentPlanId);

   string text = "";

   text += "Current active plan JSON:\n" + currentPlanJson + "\n\n";
   text += "Strategy memory JSON:\n" + strategyMemoryJson + "\n\n";
   text += "Evolution state JSON:\n" + evolutionStateJson + "\n\n";
   text += "Performance JSON:\n" + performanceJsonEnhanced + "\n\n";
   text += "Recent trade feedback JSON:\n" + tradeFeedbackJson + "\n\n";
   text += "Governor instruction:\n" + governorInstruction + "\n\n";

   text += "Observed trade sample count: " + IntegerToString(observedTradeCount) + "\n";
   text += "Allowed change scope: " + allowedScope + "\n";
   text += "Configured windows: " +
           "small=" + IntegerToString(evState.small_evolution_min_trades) +
           ", medium=" + IntegerToString(evState.medium_evolution_min_trades) +
           ", major=" + IntegerToString(evState.major_evolution_min_trades) +
           ", strong_major=" + IntegerToString(evState.strong_major_evolution_min_trades) + "\n";
   text += "Current plan_id is: " + currentPlanId + "\n";
   text += "If you change the plan, use a non-empty plan_id. Suggested next plan_id: " + suggestedNextPlanId + "\n\n";

   text += AE_BuildDiagnosticDirective() + "\n\n";
   text += AE_BuildChangePolicyDirective() + "\n\n";
   text += AE_BuildEvolutionScopeInstruction(
      observedTradeCount,
      AE_IsUnderperformanceLikely(performanceJsonEnhanced, tradeFeedbackJson, observedTradeCount, evState),
      evState
   ) + "\n\n";

   text +=
      "Your task: redesign the Runtime Core experiment plan using performance, trade outcomes, and market regime context. " +
      "Think like an experiment designer, not a simple parameter tuner. " +
      "You may decide whether the plan should remain GATE-based, become SCORE-based, or become HYBRID. " +
      "You may define trigger_weights, confirmation_weights, and filter_penalties when useful. " +
      "You may soften filters into penalties, add environment alignment bonuses, and penalize weak contexts. " +
      "For scalping, HYBRID, and EXPERIMENTAL plans, prefer sweep_detector or bollinger_reclaim_trigger as main_trigger_name unless there is strong evidence they are the root problem. " +
      "Keep require_main_trigger=true unless there is very strong evidence to relax it. " +
      "Keep allow_triggerless_entry=false. " +
      "IMPORTANT: regime_bonus_* and regime_penalty_* fields are STRING ENUM fields, not numeric bonus values. " +
      "IMPORTANT: plan_json MUST contain a non-empty plan_id. " +
      "IMPORTANT: your evolution_reason must explain the diagnosis, not just the change. " +
      "Return strict JSON only in this exact outer format: " +
      "{\"changed_plan\":true,\"evolution_reason\":\"...\",\"plan_json\":\"{...}\"}";

   return text;
}

//---------------------------------------------------------
// JSON helpers
//---------------------------------------------------------
bool ExtractJsonBoolLooseEx(string json, string key, bool &outVal)
{
   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, ":", p);
   if(p < 0)
      return false;

   string tail = TrimString(StringSubstr(json, p + 1));

   if(StringFind(tail, "true") == 0)
   {
      outVal = true;
      return true;
   }

   if(StringFind(tail, "false") == 0)
   {
      outVal = false;
      return true;
   }

   return false;
}

//---------------------------------------------------------
// Request evolution from AI
//---------------------------------------------------------
bool RequestAIEvolution(
   AISecrets &cfg,
   PersonalityProfile &personality,
   string currentPlanJson,
   string strategyMemoryJson,
   string evolutionStateJson,
   string performanceJsonEnhanced,
   string tradeFeedbackJson,
   string governorInstruction,
   int observedTradeCount,
   string allowedScope,
   AIEvolutionState &evState,
   AIEvolutionResult &result
)
{
   result.valid            = false;
   result.changed_plan     = false;
   result.new_plan_json    = "";
   result.evolution_reason = "";
   result.raw_response     = "";

   if(!AIIsReady(cfg))
   {
      result.evolution_reason = "AI not ready";
      return false;
   }

   string systemPrompt = BuildEvolutionSystemPrompt(personality);
   string userPrompt   = BuildEvolutionUserPrompt(
      currentPlanJson,
      strategyMemoryJson,
      evolutionStateJson,
      performanceJsonEnhanced,
      tradeFeedbackJson,
      governorInstruction,
      observedTradeCount,
      allowedScope,
      evState
   );

   string rawApiResponse = "";
   string err            = "";

   if(!CallOpenAIChat(cfg, systemPrompt, userPrompt, rawApiResponse, err))
   {
      result.raw_response     = rawApiResponse;
      result.evolution_reason = err;
      return false;
   }

   result.raw_response = rawApiResponse;

   string assistantJson = "";
   if(!ExtractAssistantContentFromChatResponse(rawApiResponse, assistantJson))
   {
      result.evolution_reason = "Failed to extract evolution assistant content";
      return false;
   }

   assistantJson = StripMarkdownJsonFence(assistantJson);

   bool   changed  = false;
   string reason   = "";
   string planJson = "";

   ExtractJsonBoolLooseEx(assistantJson, "changed_plan", changed);
   ExtractJsonStringField(assistantJson, "evolution_reason", reason);
   ExtractJsonStringField(assistantJson, "plan_json", planJson);

   planJson = NormalizePlanJsonString(planJson);

   if(changed)
   {
      string ensuredPlanId   = "";
      string patchedPlanJson = "";

      if(EnsurePlanIdExists(currentPlanJson, planJson, patchedPlanJson, ensuredPlanId))
      {
         planJson = NormalizePlanJsonString(patchedPlanJson);

         if(StringLen(reason) > 0)
            reason += " | ensured plan_id=" + ensuredPlanId;
         else
            reason = "ensured plan_id=" + ensuredPlanId;
      }
      else
      {
         if(StringLen(reason) > 0)
            reason += " | failed to ensure plan_id";
         else
            reason = "failed to ensure plan_id";
      }

      string normalizationNote = "";
      string safePlanJson      = "";

      if(NormalizeEvolvedPlanForRuntime(currentPlanJson, planJson, safePlanJson, normalizationNote))
      {
         planJson = NormalizePlanJsonString(safePlanJson);

         if(StringLen(normalizationNote) > 0)
         {
            if(StringLen(reason) > 0)
               reason += " |" + normalizationNote;
            else
               reason = normalizationNote;
         }
      }
      else
      {
         if(StringLen(reason) > 0)
            reason += " | failed runtime normalization";
         else
            reason = "failed runtime normalization";
      }
   }

   result.valid            = true;
   result.changed_plan     = changed;
   result.evolution_reason = reason;
   result.new_plan_json    = planJson;
   result.raw_response     = assistantJson;

   return true;
}

//---------------------------------------------------------
// Main proposal runner
//---------------------------------------------------------
bool RunEvolutionProposal(
   AISecrets &cfg,
   PersonalityProfile &personality,
   string currentPlanPath,
   string strategyMemoryPath,
   string evolutionStatePath,
   string governorStatePath,
   string tradeFeedbackPath,
   string performanceJsonEnhanced,
   string proposalOutputPath,
   string rawOutputPath,
   string &logMessage
)
{
   logMessage = "";

   string currentPlanJson    = "";
   string strategyMemoryJson = "";
   string evolutionStateJson = "";
   string tradeFeedbackJson  = "[]";

   if(!LoadTextFile(currentPlanPath, currentPlanJson))
   {
      logMessage = "Evolution skipped: failed to load current plan file";
      return false;
   }

   if(!LoadTextFile(strategyMemoryPath, strategyMemoryJson))
   {
      logMessage = "Evolution skipped: failed to load strategy memory file";
      return false;
   }

   AIEvolutionState evState;
   if(!LoadAIEvolutionStateFromJson(evolutionStatePath, evState))
   {
      LoadDefaultEvolutionState(evState);
      SaveAIEvolutionStateToJson(evolutionStatePath, evState);
      evolutionStateJson = "";
   }
   else
   {
      LoadTextFile(evolutionStatePath, evolutionStateJson);
   }

   if(!evState.evolution_enabled)
   {
      logMessage = "Evolution skipped: evolution disabled in state file";
      return true;
   }

   string feedbackSnippet = "";
   if(LoadRecentTradeFeedbackSnippet(tradeFeedbackPath, feedbackSnippet, 5000))
      tradeFeedbackJson = feedbackSnippet;

   int    observedTradeCount = AE_CountApproxTradeRecords(tradeFeedbackJson);
   bool   underperformance   = AE_IsUnderperformanceLikely(performanceJsonEnhanced, tradeFeedbackJson, observedTradeCount, evState);
   string allowedScope       = AE_DetectSuggestedChangeScope(observedTradeCount, underperformance, evState);

   // 4B: Regime-aware evolution intelligence (evidence-based, conservative)
   bool evoRegimeAware = false;
   bool failureClusteringEnabled = false;
   bool policyBlockClusteringEnabled = false;
   bool shadowEnabled = false;
   int  minSampleByRegime = 8;
   int  clusterWindow = 12;

   bool b = false;
   int  iv = 0;

   if(ExtractJsonBoolField(currentPlanJson, "evolution_regime_awareness_enabled", b))
      evoRegimeAware = b;

   if(ExtractJsonBoolField(currentPlanJson, "failure_clustering_enabled", b))
      failureClusteringEnabled = b;

   if(ExtractJsonBoolField(currentPlanJson, "policy_block_clustering_enabled", b))
      policyBlockClusteringEnabled = b;

   if(ExtractJsonBoolField(currentPlanJson, "shadow_evaluation_enabled", b))
      shadowEnabled = b;

   if(ExtractJsonIntField(currentPlanJson, "proposal_min_sample_by_regime", iv))
      minSampleByRegime = MathMax(4, iv);

   if(ExtractJsonIntField(currentPlanJson, "failure_cluster_window", iv))
      clusterWindow = MathMax(6, iv);

   FailureClusterResult fcr;
   InitFailureClusterResult(fcr);
   if(failureClusteringEnabled)
      AnalyzeFailureClusteringV1(PERF_JOURNAL_PATH, clusterWindow, fcr);

   PolicyBlockClusterResult pbcr;
   InitPolicyBlockClusterResult(pbcr);
   if(policyBlockClusteringEnabled)
      AnalyzePolicyBlockClusteringV1(PERF_JOURNAL_PATH, clusterWindow, pbcr);

   RegimePerformanceSummary rps;
   InitRegimePerformanceSummary(rps);
   if(evoRegimeAware)
      AnalyzeRegimePerformanceV1(PERF_JOURNAL_PATH, MathMax(clusterWindow, 20), rps);

   // Governance Review (anti-over-governance) - metadata only
   bool governanceEnabled = false;
   int govWindow = 20;

   bool govB=false;
   int govI=0;
   if(ExtractJsonBoolField(currentPlanJson, "governance_review_enabled", govB))
      governanceEnabled = govB;

   if(ExtractJsonIntField(currentPlanJson, "governance_review_window", govI))
      govWindow = MathMax(10, govI);

   GovernanceReviewResult gov;
   InitGovernanceReviewResult(gov);
   if(governanceEnabled)
   {
      AnalyzeGovernanceReviewV1(PERF_JOURNAL_PATH, govWindow, gov);

      string gLog = "";
      JournalAppendGovernanceReview(
         gov.dominant_governance_issue,
         gov.overgovernance_detected,
         gov.overgovernance_score,
         gov.governance_evidence_strength,
         gov.insufficient_governance_evidence,
         gov.recommended_action_class,
         gov.governance_summary_reason,
         gLog
      );
   }

   EvolutionProposalMeta meta;
   InitEvolutionProposalMeta(meta);
   meta.sample_size_used = observedTradeCount;

   // Identify worst regime (by net profit) with enough samples
   string worstRegime = "";
   double worstProfit = 0.0;
   bool haveWorst = false;

   if(evoRegimeAware)
   {
      for(int i = 0; i < rps.rows_count; i++)
      {
         if(rps.rows[i].trades < minSampleByRegime)
            continue;

         if(!haveWorst || rps.rows[i].net_profit < worstProfit)
         {
            haveWorst = true;
            worstProfit = rps.rows[i].net_profit;
            worstRegime = rps.rows[i].regime_label;
         }
      }
   }

   // Evidence-based proposal intent
   double evidence = 0.0;
   if(fcr.clustered_failure_detected)
      evidence = MathMax(evidence, fcr.failure_cluster_score);

   if(pbcr.policy_block_cluster_detected)
      evidence = MathMax(evidence, pbcr.block_cluster_score);

   if(underperformance)
      evidence = MathMax(evidence, 0.55);

   // Decide target + risk class conservatively
   if(observedTradeCount < evState.small_evolution_min_trades)
   {
      meta.proposal_action = "NO_ACTION";
      meta.proposal_reason = "INSUFFICIENT_EVIDENCE_SAMPLE";
      meta.proposal_scope  = "NONE";
      meta.proposal_confidence = 0.0;
   }
   else if(pbcr.overfiltering_suspected && pbcr.window_size >= MathMax(8, clusterWindow/2))
   {
      meta.proposal_action = "PROPOSE";
      meta.proposal_reason = "OVER_FILTERING_POLICY_BLOCK_CLUSTER";
      meta.proposal_scope  = "SMALL";
      meta.proposal_target_regime = pbcr.block_dominant_regime;
      meta.proposal_confidence = PJ_Clamp01(0.45 + pbcr.block_cluster_score * 0.45);
      meta.proposal_risk_class = "LOW_RISK_RELAXATION";
      meta.proposal_target_failure_class = "OVER_FILTER_FAILURE";
   }
   else if(fcr.clustered_failure_detected && fcr.dominant_failure_count >= 3)
   {
      meta.proposal_action = "PROPOSE";
      meta.proposal_reason = "FAILURE_CLUSTER_DOMINANT";
      meta.proposal_scope  = allowedScope;
      meta.proposal_target_regime = fcr.dominant_regime_if_any;
      meta.proposal_target_failure_class = fcr.dominant_failure_class;
      meta.proposal_confidence = PJ_Clamp01(0.40 + fcr.failure_cluster_score * 0.50);
      meta.proposal_risk_class = (meta.proposal_scope == "MAJOR_TRIGGER" ? "MEDIUM_RISK_STRUCTURAL" : "LOW_RISK_TIGHTENING");
   }
   else if(evoRegimeAware && haveWorst && worstProfit < 0.0)
   {
      meta.proposal_action = "PROPOSE";
      meta.proposal_reason = "REGIME_SPECIFIC_DETERIORATION";
      meta.proposal_scope  = "SMALL";
      meta.proposal_target_regime = worstRegime;
      meta.proposal_confidence = PJ_Clamp01(0.35 + (MathAbs(worstProfit) > 0.0 ? 0.25 : 0.10));
      meta.proposal_risk_class = "LOW_RISK_TIGHTENING";
   }
   else
   {
      meta.proposal_action = "NO_ACTION";
      meta.proposal_reason = (underperformance ? "UNDERPERFORMANCE_MIXED_EVIDENCE" : "NO_ACTION_STABLE");
      meta.proposal_scope  = "NONE";
      meta.proposal_confidence = PJ_Clamp01(evidence * 0.35);
   }

   meta.evidence_summary =
      "underperf=" + string(underperformance ? "true" : "false") +
      " | fcl=" + fcr.cluster_reason_summary +
      " | pbl=" + pbcr.block_cluster_summary +
      " | rps=" + rps.summary_reason;


   if(governanceEnabled)
      meta.evidence_summary += " | gov=" + gov.governance_summary_reason;

   // Strategy intelligence / multidimensional analytics evidence
   // intentionally omitted here to keep RunEvolutionProposal compile-safe.
   meta.evidence_summary += " | md=unavailable";

   // Phase 8A / council attribution + edge stability analytics intentionally omitted here as well,
   // because this function does not currently have a runtime plan object.
   meta.evidence_summary += " | council_attr=unavailable";
   meta.evidence_summary += " | stability=unavailable";

if(governanceEnabled && gov.overgovernance_detected && meta.proposal_action == "PROPOSE")
   {
      // metadata-only hint: if governance is too tight, prefer low-risk relaxation
      if(meta.proposal_risk_class == "LOW_RISK_TIGHTENING")
         meta.proposal_risk_class = "LOW_RISK_RELAXATION";

      if(StringLen(meta.proposal_target_failure_class) <= 0)
         meta.proposal_target_failure_class = "OVER_FILTER_FAILURE";

      if(StringLen(meta.proposal_reason) > 0)
         meta.proposal_reason += " | GOV_OVERGOVERNANCE_SIGNAL";
      else
         meta.proposal_reason = "GOV_OVERGOVERNANCE_SIGNAL";
   }

   string performanceJsonEnhancedLocal = performanceJsonEnhanced;
   performanceJsonEnhancedLocal += "\n\n[JournalAnalytics]";
   performanceJsonEnhancedLocal += "\nFailureCluster: " + fcr.cluster_reason_summary;
   performanceJsonEnhancedLocal += "\nPolicyBlockCluster: " + pbcr.block_cluster_summary;
   performanceJsonEnhancedLocal += "\nRegimePerf: " + rps.summary_reason + "\n";

   // If NO_ACTION, skip AI call while preserving explainability
   if(meta.proposal_action == "NO_ACTION")
   {
      evState.last_observed_trade_count = observedTradeCount;
      evState.last_underperformance_flag = underperformance;
      evState.last_evolution_reason = AE_BuildProposalMetaJson(meta);
      evState.last_evolution_time = AE_NowAsText();
      SaveAIEvolutionStateToJson(evolutionStatePath, evState);

      string emLog = "";
      JournalAppendEvolutionMeta(
         "NO_ACTION",
         meta.proposal_risk_class,
         meta.proposal_confidence,
         meta.sample_size_used,
         true,
         meta.proposal_reason + " | " + meta.evidence_summary,
         emLog
      );

      logMessage = "Evolution intelligence: NO_ACTION | " + meta.proposal_reason;
      return true;
   }


   if(allowedScope == "NONE")
   {
      evState.last_observed_trade_count = observedTradeCount;
      evState.last_underperformance_flag = underperformance;
      evState.last_evolution_time = AE_NowAsText();
      SaveAIEvolutionStateToJson(evolutionStatePath, evState);

      logMessage =
         "Evolution skipped: insufficient trade sample | " +
         AE_BuildSampleWindowNote(observedTradeCount, allowedScope);
      return true;
   }

   string governorInstruction = BuildGovernorInstructionEx(
      governorStatePath,
      evolutionStatePath,
      observedTradeCount
   );

   AIEvolutionResult evo;

   string emLog2 = "";
   JournalAppendEvolutionMeta(
      "PROPOSE",
      meta.proposal_risk_class,
      meta.proposal_confidence,
      meta.sample_size_used,
      false,
      meta.proposal_reason + " | " + meta.evidence_summary,
      emLog2
   );

   bool ok = RequestAIEvolution(
      cfg,
      personality,
      currentPlanJson,
      strategyMemoryJson,
      evolutionStateJson,
      performanceJsonEnhancedLocal,
      tradeFeedbackJson,
      governorInstruction,
      observedTradeCount,
      allowedScope,
      evState,
      evo
   );

   SaveTextFileEx(rawOutputPath, evo.raw_response);

   if(!ok || !evo.valid)
   {
      logMessage = "Evolution request failed: " + evo.evolution_reason;
      return false;
   }

   // Attach evidence-based proposal metadata for governor/journal consumers
   evo.evolution_reason = AE_BuildProposalMetaJson(meta) + " | " + evo.evolution_reason;

   if(!evo.changed_plan)
   {
      evState.last_observed_trade_count = observedTradeCount;
      evState.last_underperformance_flag = underperformance;
      evState.last_evolution_reason = "no_plan_change";
      evState.last_evolution_time = AE_NowAsText();
      SaveAIEvolutionStateToJson(evolutionStatePath, evState);

      logMessage =
         "Evolution checked: no plan change" +
         " | " + AE_BuildSampleWindowNote(observedTradeCount, allowedScope);
      return true;
   }

   if(StringLen(evo.new_plan_json) < 10)
   {
      logMessage = "Evolution returned weak/empty plan";
      return false;
   }

   // Shadow evaluation foundation (records intent only, no execution)
   if(shadowEnabled)
   {
      string proposedId = "";
      if(!ExtractCurrentPlanId(evo.new_plan_json, proposedId))
         proposedId = "plan_unknown";

      string shadow_fp = StringFormat("%s|%08X", proposedId, PJ_Fnv1a32(evo.new_plan_json));
      string shadow_decision_id = "SH-" + PJ_MakeDecisionId();

      string sjLog = "";
      JournalAppendShadowDecision(
         shadow_decision_id,
         shadow_fp,
         "PENDING",
         meta.proposal_confidence,
         meta.proposal_reason,
         "UNKNOWN",
         "",
         sjLog
      );

      if(StringLen(sjLog) > 0)
         LogStateOnce(sjLog);
   }

evo.new_plan_json = NormalizePlanJsonString(evo.new_plan_json);

   string previousTriggerName = AE_ExtractCurrentMainTriggerFallback(currentPlanJson);
   string newTriggerName      = AE_ExtractCurrentMainTriggerFallback(evo.new_plan_json);
   string appliedChangeScope  = AE_DetectAppliedChangeScope(currentPlanJson, evo.new_plan_json);
   string diagnosisLabel      = AE_DetectDiagnosisLabel(
      evo.evolution_reason,
      tradeFeedbackJson,
      performanceJsonEnhanced,
      observedTradeCount,
      evState
   );

   string normalizedAllowedScope = Gov_NormalizeScope(allowedScope);
   string normalizedAppliedScope = Gov_NormalizeScope(appliedChangeScope);

   bool scopeViolation = false;

   if(normalizedAllowedScope == "SMALL" && normalizedAppliedScope != "SMALL")
      scopeViolation = true;

   if(normalizedAllowedScope == "MEDIUM" && normalizedAppliedScope == "MAJOR_TRIGGER")
      scopeViolation = true;

   if(scopeViolation)
   {
      logMessage =
         "Evolution blocked: AI proposed change scope exceeds allowed scope" +
         " | allowed=" + normalizedAllowedScope +
         " | proposed=" + normalizedAppliedScope +
         " | trades=" + IntegerToString(observedTradeCount);
      return false;
   }

   if(!SaveTextFileEx(proposalOutputPath, evo.new_plan_json))
   {
      logMessage = "Evolution generated plan but failed to save proposal";
      return false;
   }

   string govApplyLog = "";
   UpdateEvolutionGovernorAfterApplyEx(
      governorStatePath,
      evolutionStatePath,
      previousTriggerName,
      newTriggerName,
      observedTradeCount,
      normalizedAppliedScope,
      diagnosisLabel,
      underperformance,
      govApplyLog
   );

   evState.current_generation++;
   ExtractCurrentPlanId(evo.new_plan_json, evState.current_plan_id);
   evState.last_evolution_time = AE_NowAsText();
   evState.last_evolution_reason = evo.evolution_reason;
   evState.last_evolution_scope = normalizedAppliedScope;
   evState.last_diagnosis = diagnosisLabel;
   evState.last_observed_trade_count = observedTradeCount;
   evState.last_underperformance_flag = underperformance;

   if(underperformance)
      evState.consecutive_underperformance_cycles++;
   else
      evState.consecutive_underperformance_cycles = 0;

   if(previousTriggerName != newTriggerName)
   {
      evState.last_trigger_change_generation = evState.current_generation;
      evState.last_trigger_change_reason = diagnosisLabel;
   }

   SaveAIEvolutionStateToJson(evolutionStatePath, evState);

   logMessage =
      "Evolution proposal saved: " + evo.evolution_reason +
      " | trades=" + IntegerToString(observedTradeCount) +
      " | allowed_scope=" + normalizedAllowedScope +
      " | applied_scope=" + normalizedAppliedScope +
      " | diagnosis=" + diagnosisLabel +
      " | " + govApplyLog;

   return true;
}

#endif