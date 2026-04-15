#ifndef __STRATEGY_CONFIDENCE_MEMORY_V1_MQH__
#define __STRATEGY_CONFIDENCE_MEMORY_V1_MQH__

#include "core_logger.mqh"
#include "council_mode_types.mqh"

#define SCM_EVENTS_PATH  "AI\\ai_strategy_memory_events.jsonl"
#define SCM_SUMMARY_PATH "AI\\ai_strategy_memory.json"

struct SCM_StrategyStats
{
   string id;
   string name;
   string family;

   int total_observations;
   int total_entries;

   int wins;
   int losses;
   int flats;

   int blocked_count;
   int rejected_count;

   string recent_results; // e.g. "WLLFW" (max 30)
};

int SCM_FindStrategyIndex(SCM_StrategyStats &arr[], string id)
{
   for(int i=0;i<ArraySize(arr);i++)
      if(arr[i].id == id)
         return i;
   return -1;
}

string SCM_EscapeJson(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\n", "\\n");
   StringReplace(s, "\r", "");
   return s;
}

bool SCM_AppendJsonLine(string relPath, string jsonLine)
{
   FolderCreate("AI");
   int h = FileOpen(relPath, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);

   if(h == INVALID_HANDLE)
      return false;

   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, jsonLine + "\n");
   FileClose(h);
   return true;
}

bool SCM_WriteText(string relPath, string txt)
{
   FolderCreate("AI");
   int h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileWriteString(h, txt);
   FileClose(h);
   return true;
}

bool SCM_LoadText(string relPath, string &outTxt)
{
   outTxt = "";
   int h = FileOpen(relPath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
      outTxt += FileReadString(h) + "\n";

   FileClose(h);
   return true;
}

int SCM_JsonExtractInt(string obj, string key, int defVal)
{
   string k = "\"" + key + "\":";
   int p = StringFind(obj, k);
   if(p < 0) return defVal;
   p += StringLen(k);

   // skip spaces
   while(p < StringLen(obj) && (StringGetCharacter(obj,p) == ' ')) p++;

   string num = "";
   while(p < StringLen(obj))
   {
      ushort c = (ushort)StringGetCharacter(obj,p);
      if((c >= '0' && c <= '9') || c == '-')
         num += CharToString((uchar)c);
      else
         break;
      p++;
   }
   if(StringLen(num) == 0) return defVal;
   return (int)StringToInteger(num);
}

string SCM_JsonExtractString(string obj, string key, string defVal)
{
   string k = "\"" + key + "\":\"";
   int p = StringFind(obj, k);
   if(p < 0) return defVal;
   p += StringLen(k);

   string s = "";
   while(p < StringLen(obj))
   {
      ushort c = (ushort)StringGetCharacter(obj,p);
      if(c == '"') break;
      s += CharToString((uchar)c);
      p++;
   }
   StringReplace(s, "\\\"", "\"");
   StringReplace(s, "\\\\", "\\");
   StringReplace(s, "\\n", "\n");
   return s;
}

void SCM_TrimRecent(string &s)
{
   int maxLen = 30;
   if(StringLen(s) <= maxLen) return;
   s = StringSubstr(s, StringLen(s) - maxLen);
}

double SCM_ReliabilityScore(SCM_StrategyStats &st)
{
   int denom = st.wins + st.losses;
   if(denom <= 0) return 0.0;
   // conservative shrinkage
   return (st.wins + 1.0) / (denom + 2.0);
}

bool SCM_DegradationHint(SCM_StrategyStats &st)
{
   int n = MathMin(10, StringLen(st.recent_results));
   if(n < 6) return false;

   int losses = 0;
   for(int i=StringLen(st.recent_results)-n;i<StringLen(st.recent_results);i++)
      if(StringSubstr(st.recent_results, i, 1) == "L")
         losses++;

   return ((double)losses / (double)n) >= 0.7 && st.total_entries >= 20;
}

void SCM_BuildSummaryJson(SCM_StrategyStats &arr[], string &outJson)
{
   outJson = "{";
   outJson += "\"version\":\"strategy_confidence_memory_v1\",";
   outJson += "\"generated_at\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   outJson += "\"strategy_count\":" + IntegerToString(ArraySize(arr)) + ",";
   outJson += "\"strategies\":[";
   for(int i=0;i<ArraySize(arr);i++)
   {
      SCM_StrategyStats st = arr[i];
      double rel = SCM_ReliabilityScore(st);
      bool degr = SCM_DegradationHint(st);

      if(i > 0) outJson += ",";
      outJson += "{";
      outJson += "\"id\":\"" + SCM_EscapeJson(st.id) + "\",";
      outJson += "\"name\":\"" + SCM_EscapeJson(st.name) + "\",";
      outJson += "\"family\":\"" + SCM_EscapeJson(st.family) + "\",";
      outJson += "\"total_observations\":" + IntegerToString(st.total_observations) + ",";
      outJson += "\"total_entries\":" + IntegerToString(st.total_entries) + ",";
      outJson += "\"wins\":" + IntegerToString(st.wins) + ",";
      outJson += "\"losses\":" + IntegerToString(st.losses) + ",";
      outJson += "\"flats\":" + IntegerToString(st.flats) + ",";
      outJson += "\"blocked_count\":" + IntegerToString(st.blocked_count) + ",";
      outJson += "\"rejected_count\":" + IntegerToString(st.rejected_count) + ",";
      outJson += "\"recent_results\":\"" + SCM_EscapeJson(st.recent_results) + "\",";
      outJson += "\"reliability_score\":" + DoubleToString(rel, 4) + ",";
      outJson += "\"degradation_hint\":" + (degr ? "true" : "false");
      outJson += "}";
   }
   outJson += "]";
   outJson += "}";
}

bool SCM_LoadSummary(SCM_StrategyStats &outArr[])
{
   ArrayResize(outArr, 0);

   if(!FileIsExist(SCM_SUMMARY_PATH))
      return true;

   string txt = "";
   if(!SCM_LoadText(SCM_SUMMARY_PATH, txt))
      return true;

   // Our writer emits: {"strategies":[{...},{...}]}
   int p = StringFind(txt, "\"strategies\":[");
   if(p < 0) return true;
   p = StringFind(txt, "[", p);
   if(p < 0) return true;

   int end = StringFind(txt, "]", p);
   if(end < 0) return true;

   string body = StringSubstr(txt, p+1, end - (p+1));
   // Split by occurrences of {"id":
   string parts[];
   int cnt = StringSplit(body, '{', parts);
   for(int i=0;i<cnt;i++)
   {
      string obj = parts[i];
      if(StringFind(obj, "\"id\":\"") < 0) continue;
      obj = "{" + obj;

      SCM_StrategyStats st;
      st.id = SCM_JsonExtractString(obj, "id", "");
      if(StringLen(st.id) == 0) continue;

      st.name = SCM_JsonExtractString(obj, "name", "");
      st.family = SCM_JsonExtractString(obj, "family", "");
      st.total_observations = SCM_JsonExtractInt(obj, "total_observations", 0);
      st.total_entries = SCM_JsonExtractInt(obj, "total_entries", 0);
      st.wins = SCM_JsonExtractInt(obj, "wins", 0);
      st.losses = SCM_JsonExtractInt(obj, "losses", 0);
      st.flats = SCM_JsonExtractInt(obj, "flats", 0);
      st.blocked_count = SCM_JsonExtractInt(obj, "blocked_count", 0);
      st.rejected_count = SCM_JsonExtractInt(obj, "rejected_count", 0);
      st.recent_results = SCM_JsonExtractString(obj, "recent_results", "");

      int n = ArraySize(outArr);
      ArrayResize(outArr, n+1);
      outArr[n] = st;
   }

   return true;
}

bool SCM_SaveSummary(SCM_StrategyStats &arr[])
{
   string json = "";
   SCM_BuildSummaryJson(arr, json);
   return SCM_WriteText(SCM_SUMMARY_PATH, json);
}

bool SCM_Init(SCM_StrategyStats &cache[], string &logMessage)
{
   logMessage = "";
   FolderCreate("AI");

   // Ensure files exist.
   if(!FileIsExist(SCM_EVENTS_PATH))
      SCM_WriteText(SCM_EVENTS_PATH, "");
   if(!FileIsExist(SCM_SUMMARY_PATH))
      SCM_WriteText(SCM_SUMMARY_PATH, "{\"version\":\"strategy_confidence_memory_v1\",\"generated_at\":\"\",\"strategy_count\":0,\"strategies\":[]}");

   SCM_LoadSummary(cache);
   logMessage = "Strategy Confidence Memory v1 initialized (observer-only)";
   return true;
}

void SCM_EnsureStrategy(SCM_StrategyStats &cache[], string strategy_id, string strategy_family, string strategy_name)
{
   int idx = SCM_FindStrategyIndex(cache, strategy_id);
   if(idx >= 0)
   {
      if(StringLen(cache[idx].family) == 0 && StringLen(strategy_family) > 0)
         cache[idx].family = strategy_family;
      if(StringLen(cache[idx].name) == 0 && StringLen(strategy_name) > 0)
         cache[idx].name = strategy_name;
      return;
   }

   SCM_StrategyStats st;
   st.id = strategy_id;
   st.family = strategy_family;
   st.name = strategy_name;

   st.total_observations = 0;
   st.total_entries = 0;
   st.wins = 0;
   st.losses = 0;
   st.flats = 0;
   st.blocked_count = 0;
   st.rejected_count = 0;
   st.recent_results = "";

   int n = ArraySize(cache);
   ArrayResize(cache, n+1);
   cache[n] = st;
}

// Observer-only event: decision logged (BUY/SELL/REJECT/BLOCKED) with context.
void SCM_RecordDecisionEvent(
   SCM_StrategyStats &cache[],
   string symbol,
   string decision_id,
   string strategy_id,
   string strategy_name,
   string strategy_family,
   string zone_semantic,
   string regime_label,
   string direction,
   string decision_outcome,   // BUY / SELL / REJECT / BLOCKED
   bool trade_opened,
   bool blocked_by_level_brake,
   string level_brake_reason,
   string zone_coverage_label
)
{
   if(StringLen(strategy_id) == 0)
      return; // v1 targets strategy-specific memory

   SCM_EnsureStrategy(cache, strategy_id, strategy_family, strategy_name);

   int idx = SCM_FindStrategyIndex(cache, strategy_id);
   if(idx >= 0)
   {
      cache[idx].total_observations++;

      if(decision_outcome == "REJECT")
         cache[idx].rejected_count++;
      if(decision_outcome == "BLOCKED" || blocked_by_level_brake)
         cache[idx].blocked_count++;
      if(trade_opened)
         cache[idx].total_entries++;
   }

   string json = "{";
   json += "\"ts\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"symbol\":\"" + SCM_EscapeJson(symbol) + "\",";
   json += "\"decision_id\":\"" + SCM_EscapeJson(decision_id) + "\",";
   json += "\"strategy_id\":\"" + SCM_EscapeJson(strategy_id) + "\",";
   json += "\"strategy_name\":\"" + SCM_EscapeJson(strategy_name) + "\",";
   json += "\"strategy_family\":\"" + SCM_EscapeJson(strategy_family) + "\",";
   json += "\"zone_semantic\":\"" + SCM_EscapeJson(zone_semantic) + "\",";
   json += "\"regime_label\":\"" + SCM_EscapeJson(regime_label) + "\",";
   json += "\"direction\":\"" + SCM_EscapeJson(direction) + "\",";
   json += "\"decision_outcome\":\"" + SCM_EscapeJson(decision_outcome) + "\",";
   json += "\"trade_opened\":" + (trade_opened ? "true" : "false") + ",";
   json += "\"blocked_by_level_brake\":" + (blocked_by_level_brake ? "true" : "false") + ",";
   json += "\"level_brake_reason\":\"" + SCM_EscapeJson(level_brake_reason) + "\",";
   json += "\"zone_coverage\":\"" + SCM_EscapeJson(zone_coverage_label) + "\"";
   json += "}";

   SCM_AppendJsonLine(SCM_EVENTS_PATH, json);
   SCM_SaveSummary(cache);
}

// Observer-only event: closed trade outcome (WIN/LOSS/FLAT).
void SCM_RecordClosedTradeOutcome(
   SCM_StrategyStats &cache[],
   string symbol,
   string decision_id,
   string strategy_id,
   string strategy_name,
   string strategy_family,
   string zone_semantic,
   string regime_label,
   string direction,
   string trade_result, // WIN / LOSS / FLAT
   ulong position_id = 0,
   ulong close_deal_id = 0,
   ulong entry_deal_id = 0,
   datetime close_time = 0,
   string strategy_identity_source = ""
)
{
   if(StringLen(strategy_id) == 0)
      return;

   SCM_EnsureStrategy(cache, strategy_id, strategy_family, strategy_name);

   int idx = SCM_FindStrategyIndex(cache, strategy_id);
   if(idx >= 0)
   {
      if(trade_result == "WIN") cache[idx].wins++;
      else if(trade_result == "LOSS") cache[idx].losses++;
      else cache[idx].flats++;

      string mark = "F";
      if(trade_result == "WIN") mark = "W";
      if(trade_result == "LOSS") mark = "L";

      cache[idx].recent_results += mark;
      SCM_TrimRecent(cache[idx].recent_results);
   }

   string json = "{";
   json += "\"ts\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"event\":\"TRADE_CLOSE\",";
   json += "\"symbol\":\"" + SCM_EscapeJson(symbol) + "\",";
   json += "\"decision_id\":\"" + SCM_EscapeJson(decision_id) + "\",";
   json += "\"position_id\":" + (string)position_id + ",";
   json += "\"entry_deal_id\":" + (string)entry_deal_id + ",";
   json += "\"close_deal_id\":" + (string)close_deal_id + ",";
   json += "\"close_time\":" + IntegerToString((int)close_time) + ",";
   json += "\"trade_lineage_key\":\"" + SCM_EscapeJson(
      "decision=" + decision_id + "|position=" + (string)position_id + "|close_deal=" + (string)close_deal_id
   ) + "\",";
   json += "\"strategy_identity_source\":\"" + SCM_EscapeJson(strategy_identity_source) + "\",";
   json += "\"strategy_id\":\"" + SCM_EscapeJson(strategy_id) + "\",";
   json += "\"strategy_name\":\"" + SCM_EscapeJson(strategy_name) + "\",";
   json += "\"strategy_family\":\"" + SCM_EscapeJson(strategy_family) + "\",";
   json += "\"zone_semantic\":\"" + SCM_EscapeJson(zone_semantic) + "\",";
   json += "\"regime_label\":\"" + SCM_EscapeJson(regime_label) + "\",";
   json += "\"direction\":\"" + SCM_EscapeJson(direction) + "\",";
   json += "\"trade_result\":\"" + SCM_EscapeJson(trade_result) + "\"";
   json += "}";

   SCM_AppendJsonLine(SCM_EVENTS_PATH, json);
   SCM_SaveSummary(cache);
}

#endif
// Observer-only event: trade open attempt/result.
void SCM_RecordTradeOpenEvent(
   SCM_StrategyStats &cache[],
   string symbol,
   string decision_id,
   string strategy_id,
   string strategy_name,
   string strategy_family,
   string zone_semantic,
   string regime_label,
   string direction,
   bool opened_ok
)
{
   if(StringLen(strategy_id) == 0)
      return;

   SCM_EnsureStrategy(cache, strategy_id, strategy_family, strategy_name);

   int idx = SCM_FindStrategyIndex(cache, strategy_id);
   if(idx >= 0 && opened_ok)
      cache[idx].total_entries++;

   string json = "{";
   json += "\"ts\":\"" + TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS) + "\",";
   json += "\"event\":\"TRADE_OPEN\",";
   json += "\"symbol\":\"" + SCM_EscapeJson(symbol) + "\",";
   json += "\"decision_id\":\"" + SCM_EscapeJson(decision_id) + "\",";
   json += "\"strategy_id\":\"" + SCM_EscapeJson(strategy_id) + "\",";
   json += "\"strategy_name\":\"" + SCM_EscapeJson(strategy_name) + "\",";
   json += "\"strategy_family\":\"" + SCM_EscapeJson(strategy_family) + "\",";
   json += "\"zone_semantic\":\"" + SCM_EscapeJson(zone_semantic) + "\",";
   json += "\"regime_label\":\"" + SCM_EscapeJson(regime_label) + "\",";
   json += "\"direction\":\"" + SCM_EscapeJson(direction) + "\",";
   json += "\"opened_ok\":" + (opened_ok ? "true" : "false");
   json += "}";

   SCM_AppendJsonLine(SCM_EVENTS_PATH, json);
   SCM_SaveSummary(cache);
}
