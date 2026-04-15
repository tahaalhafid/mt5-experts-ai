#ifndef __JOURNAL_ANALYTICS_MQH__
#define __JOURNAL_ANALYTICS_MQH__

#include "core_logger.mqh"

//---------------------------------------------------------
// Wrapper usage map (Phase 9B)
// Active: AnalyzeCouncilAttributionAnalyticsV2() (V1 delegates to V2).
// Loader: PJ_LoadCouncilAttributionMetaByPositionId() consumes TRADE_OPEN metadata.
//---------------------------------------------------------

//---------------------------------------------------------
// Journal Analytics v1
// - Reads ai_performance_journal.jsonl
// - Provides: failure clustering, regime-aware performance, correlation lookup
//---------------------------------------------------------
#define JA_MAX_LINE 2048

double JA_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}
double JA_Clamp01(double v) { return JA_Clamp(v, 0.0, 1.0); }

int JA_ClampInt(int v, int lo, int hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}


string JA_Trim(string s)
{
   StringTrimLeft(s);
   StringTrimRight(s);
   return s;
}

bool JA_ReadAllLines(string relativePath, string &lines[])
{
   ArrayResize(lines, 0);

   int h = FileOpen(relativePath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   string buf = "";
   while(!FileIsEnding(h))
   {
      string part = FileReadString(h);
      if(StringLen(part) > 0)
         buf += part;
   }
   FileClose(h);

   int n = StringSplit(buf, '\n', lines);
   if(n <= 0)
   {
      ArrayResize(lines, 0);
      return true;
   }

   // drop empty tail
   while(ArraySize(lines) > 0 && StringLen(JA_Trim(lines[ArraySize(lines) - 1])) <= 0)
      ArrayResize(lines, ArraySize(lines) - 1);

   return true;
}

bool JA_ReadLastNLines(string relativePath, int maxLines, string &out[])
{
   string lines[];
   if(!JA_ReadAllLines(relativePath, lines))
      return false;

   int total = ArraySize(lines);
   if(total <= 0)
   {
      ArrayResize(out, 0);
      return true;
   }

   int start = MathMax(0, total - maxLines);
   int n = total - start;
   ArrayResize(out, n);

   for(int i = 0; i < n; i++)
      out[i] = lines[start + i];

   return true;
}

// naive JSON string extractor: "key":"value"
bool JA_ExtractJsonString(string json, string key, string &value)
{
   value = "";
   string needle = "\"" + key + "\":\"";
   int p = StringFind(json, needle);
   if(p < 0) return false;

   int s = p + StringLen(needle);
   int e = StringFind(json, "\"", s);
   if(e < 0) return false;

   value = StringSubstr(json, s, e - s);
   return true;
}


// Convenience overloads used by legacy call sites
string JA_ExtractJsonString(string json, string key)
{
   string v = "";
   JA_ExtractJsonString(json, key, v);
   return v;
}



int JA_ExtractJsonInt(string json, string key)
{
   int v = 0;
   JA_ExtractJsonInt(json, key, v);
   return v;
}

ulong JA_ExtractJsonULong(string json, string key)
{
   ulong v = 0;
   JA_ExtractJsonULong(json, key, v);
   return v;
}

// Legacy spelling used by some call sites
ulong JA_ExtractJsonUlong(string json, string key)
{
   return JA_ExtractJsonULong(json, key);
}

double JA_ExtractJsonDouble(string json, string key)
{
   double v = 0.0;
   JA_ExtractJsonDouble(json, key, v);
   return v;
}
bool JA_ExtractJsonInt(string json, string key, int &value)
{
   value = 0;
   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0) return false;
   p = StringFind(json, ":", p);
   if(p < 0) return false;

   int s = p + 1;
   while(s < StringLen(json))
   {
      ushort c = StringGetCharacter(json, s);
      if(c!=' ' && c!='\t' && c!='\r' && c!='\n') break;
      s++;
   }

   int e = s;
   while(e < StringLen(json))
   {
      ushort c = StringGetCharacter(json, e);
      if((c>='0' && c<='9') || c=='-' ) { e++; continue; }
      break;
   }
   if(e <= s) return false;

   value = (int)StringToInteger(StringSubstr(json, s, e - s));
   return true;
}

bool JA_ExtractJsonULong(string json, string key, ulong &value)
{
   value = 0;
   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0) return false;
   p = StringFind(json, ":", p);
   if(p < 0) return false;

   int s = p + 1;
   while(s < StringLen(json))
   {
      ushort c = StringGetCharacter(json, s);
      if(c!=' ' && c!='\t' && c!='\r' && c!='\n') break;
      s++;
   }

   int e = s;
   while(e < StringLen(json))
   {
      ushort c = StringGetCharacter(json, e);
      if(c>='0' && c<='9') { e++; continue; }
      break;
   }
   if(e <= s) return false;

   value = (ulong)StringToInteger(StringSubstr(json, s, e - s));
   return true;
}


// naive JSON bool extractor: "key":true/false
bool JA_ExtractJsonBool(string json, string key, bool &value)
{
   value = false;
   string needle = "\"" + key + "\":";
   int p = StringFind(json, needle);
   if(p < 0) return false;

   int s = p + StringLen(needle);
   while(s < StringLen(json) && StringGetCharacter(json, s) == ' ') s++;

   if(StringFind(json, "true", s) == s)
   {
      value = true;
      return true;
   }

   if(StringFind(json, "false", s) == s)
   {
      value = false;
      return true;
   }

   return false;
}

// naive JSON double extractor: "key":1.23
bool JA_ExtractJsonDouble(string json, string key, double &value)
{
   value = 0.0;
   string needle = "\"" + key + "\":";
   int p = StringFind(json, needle);
   if(p < 0) return false;

   int s = p + StringLen(needle);
   int e = s;

   while(e < StringLen(json))
   {
      ushort ch = StringGetCharacter(json, e);
      if((ch >= '0' && ch <= '9') || ch == '.' || ch == '-')
      {
         e++;
         continue;
      }
      break;
   }

   if(e <= s) return false;
   value = StringToDouble(StringSubstr(json, s, e - s));
   return true;
}
// naive JSON ulong extractor: "key":123
bool JA_ExtractJsonUlong(string json, string key, ulong &value)
{
   value = 0;
   string needle = "\"" + key + "\":";
   int p = StringFind(json, needle);
   if(p < 0) return false;

   int s = p + StringLen(needle);
   int e = s;

   while(e < StringLen(json))
   {
      ushort ch = StringGetCharacter(json, e);
      if((ch >= '0' && ch <= '9'))
      {
         e++;
         continue;
      }
      break;
   }

   if(e <= s) return false;

   string num = StringSubstr(json, s, e - s);
   value = (ulong)StringToInteger(num);
   return true;
}

string JA_NormalizeDirectionText(string s)
{
   s = JA_Trim(s);
   StringToUpper(s);

   if(s == "LONG")
      s = "BUY";
   else if(s == "SHORT")
      s = "SELL";
   else if(s == "UNKNOWN" || s == "NONE" || s == "NULL" || s == "N/A")
      s = "";

   if(s == "BUY" || s == "SELL")
      return s;

   return "";
}

string JA_NormalizeTradeResultText(string s)
{
   s = JA_Trim(s);
   StringToUpper(s);

   if(s == "PROFIT")
      s = "WIN";
   else if(s == "LOSE")
      s = "LOSS";
   else if(s == "BREAKEVEN" || s == "BREAK_EVEN" || s == "BE")
      s = "FLAT";

   if(s == "WIN" || s == "LOSS" || s == "FLAT" || s == "PENDING" || s == "NOT_EXECUTED")
      return s;

   return "";
}

string JA_GetNormalizedRecordType(string line)
{
   string t = "";
   if(!JA_ExtractJsonString(line, "record_type", t))
      return "";

   t = JA_Trim(t);

   if(t == "TRADE_CLOSE")
      return "TRADE";

   return t;
}

bool JA_IsTradeOpenLikeRecord(string line)
{
   string rt = JA_GetNormalizedRecordType(line);
   if(rt == "TRADE_OPEN")
      return true;

   string stage = "";
   if(JA_ExtractJsonString(line, "trade_event_type", stage))
      return (JA_Trim(stage) == "TRADE_OPEN");

   return false;
}

bool JA_IsTradeCloseLikeRecord(string line)
{
   string rt = JA_GetNormalizedRecordType(line);
   if(rt == "TRADE")
      return true;

   string stage = "";
   if(JA_ExtractJsonString(line, "trade_event_type", stage))
      return (JA_Trim(stage) == "TRADE_CLOSE");

   return false;
}

bool JA_ExtractTradeResultNormalized(string line, string &result)
{
   result = "";

   if(JA_ExtractJsonString(line, "trade_result", result))
   {
      result = JA_NormalizeTradeResultText(result);
      if(StringLen(result) > 0)
         return true;
   }

   if(JA_ExtractJsonString(line, "exit_class", result))
   {
      result = JA_NormalizeTradeResultText(result);
      if(StringLen(result) > 0)
         return true;
   }

   if(JA_ExtractJsonString(line, "result", result))
   {
      result = JA_NormalizeTradeResultText(result);
      if(StringLen(result) > 0)
         return true;
   }

   result = "";
   return false;
}

bool JA_ExtractDirectionNormalized(string line, string key, string &direction)
{
   direction = "";
   if(!JA_ExtractJsonString(line, key, direction))
      return false;

   direction = JA_NormalizeDirectionText(direction);
   return (StringLen(direction) > 0);
}

bool JA_IsRecordType(string line, string recordType)
{
   string rt = JA_GetNormalizedRecordType(line);
   if(rt == recordType)
      return true;

   if(recordType == "TRADE_OPEN")
      return JA_IsTradeOpenLikeRecord(line);

   if(recordType == "TRADE")
      return JA_IsTradeCloseLikeRecord(line);

   return false;
}

//---------------------------------------------------------
// Failure clustering v1 (conservative windowed)
//---------------------------------------------------------
struct FailureClusterResult
{
   bool   clustered_failure_detected;

   string dominant_failure_class;
   int    dominant_failure_count;
   double failure_cluster_score;

   string dominant_regime_if_any;
   int    cluster_window_size;
   string cluster_reason_summary;
};

void InitFailureClusterResult(FailureClusterResult &r)
{
   r.clustered_failure_detected = false;
   r.dominant_failure_class = "UNKNOWN_FAILURE";
   r.dominant_failure_count = 0;
   r.failure_cluster_score = 0.0;
   r.dominant_regime_if_any = "";
   r.cluster_window_size = 0;
   r.cluster_reason_summary = "";
}

int JA_FindOrAppendKey(string &keys[], int &counts[], string key)
{
   int n = ArraySize(keys);
   for(int i = 0; i < n; i++)
   {
      if(keys[i] == key) return i;
   }

   ArrayResize(keys, n + 1);
   ArrayResize(counts, n + 1);
   keys[n] = key;
   counts[n] = 0;
   return n;
}

bool AnalyzeFailureClusteringV1(string relativePath, int windowTrades, FailureClusterResult &out)
{
   InitFailureClusterResult(out);

   if(windowTrades <= 0) windowTrades = 12;

   string lines[];
   if(!JA_ReadLastNLines(relativePath, MathMax(200, windowTrades * 10), lines))
      return false;

   string failureKeys[];
   int failureCounts[];

   string regimeKeys[];
   int regimeCounts[];

   int seenTrades = 0;
   int total = ArraySize(lines);

   for(int i = total - 1; i >= 0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;

      if(!JA_IsRecordType(line, "TRADE"))
         continue;

      string fc = "";
      string reg = "";

      JA_ExtractJsonString(line, "failure_class", fc);
      JA_ExtractJsonString(line, "regime_label", reg);

      if(StringLen(fc) <= 0) fc = "UNKNOWN_FAILURE";

      int fi = JA_FindOrAppendKey(failureKeys, failureCounts, fc);
      failureCounts[fi]++;

      if(StringLen(reg) > 0)
      {
         int ri = JA_FindOrAppendKey(regimeKeys, regimeCounts, reg);
         regimeCounts[ri]++;
      }

      seenTrades++;
      if(seenTrades >= windowTrades)
         break;
   }

   out.cluster_window_size = seenTrades;

   if(seenTrades < MathMax(4, windowTrades / 3))
   {
      out.cluster_reason_summary = "insufficient_trade_window";
      return true;
   }

   // dominant failure
   int bestIdx = -1;
   int bestCount = 0;
   for(int i = 0; i < ArraySize(failureKeys); i++)
   {
      if(failureCounts[i] > bestCount)
      {
         bestCount = failureCounts[i];
         bestIdx = i;
      }
   }

   if(bestIdx >= 0)
   {
      out.dominant_failure_class = failureKeys[bestIdx];
      out.dominant_failure_count = bestCount;
   }

   // dominant regime
   int rBestIdx = -1;
   int rBestCount = 0;
   for(int i = 0; i < ArraySize(regimeKeys); i++)
   {
      if(regimeCounts[i] > rBestCount)
      {
         rBestCount = regimeCounts[i];
         rBestIdx = i;
      }
   }
   if(rBestIdx >= 0)
      out.dominant_regime_if_any = regimeKeys[rBestIdx];

   double concentration = (double)bestCount / (double)MathMax(1, seenTrades);
   out.failure_cluster_score = JA_Clamp01((concentration - 0.35) / 0.55);

   out.clustered_failure_detected = (bestCount >= 3 && concentration >= 0.50);

   out.cluster_reason_summary =
      "window=" + (string)seenTrades +
      "|dom=" + out.dominant_failure_class +
      "|count=" + (string)bestCount +
      "|conc=" + DoubleToString(concentration, 2) +
      "|reg=" + out.dominant_regime_if_any;

   return true;
}

//---------------------------------------------------------
// Correlation lookup: find decision_id by position_id using TRADE_OPEN records
//---------------------------------------------------------
bool PJ_FindDecisionIdByPositionId(
   string relativePath,
   ulong positionId,
   int maxLines,
   string &decisionId,
   string &method,
   double &quality
)
{
   decisionId = "";
   method = "NONE";
   quality = 0.0;

   if(positionId == 0) return false;

   string lines[];
   if(!JA_ReadLastNLines(relativePath, MathMax(50, maxLines), lines))
      return false;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;

      if(!JA_IsRecordType(line, "TRADE_OPEN"))
         continue;

      ulong pid = 0;
      if(!JA_ExtractJsonUlong(line, "position_id", pid))
         continue;

      if(pid != positionId)
         continue;

      string did = "";
      if(JA_ExtractJsonString(line, "decision_id", did) && StringLen(did) > 0)
      {
         decisionId = did;
         method = "POSITION_ID";
         quality = 0.95;
         return true;
      }
   }

   
    return false;
}

//---------------------------------------------------------
// Phase 8A: Load council attribution meta from TRADE_OPEN by position_id
//---------------------------------------------------------
bool PJ_LoadCouncilAttributionMetaByPositionId(
   string relativePath,
   ulong positionId,
   int maxLines,
   string &dominant_strategy_id,
   int &aligned_count,
   int &opposing_count,
   int &neutral_count,
   double &attribution_confidence,
   string &aligned_strategy_ids,
   string &opposing_strategy_ids,
   string &neutral_strategy_ids,
   string &strategies_compact
)
{
   dominant_strategy_id = "";
   aligned_count = 0;
   opposing_count = 0;
   neutral_count = 0;
   attribution_confidence = 0.0;
   aligned_strategy_ids = "";
   opposing_strategy_ids = "";
   neutral_strategy_ids = "";
   strategies_compact = "";

   if(positionId == 0) return false;

   string lines[];
   if(!JA_ReadLastNLines(relativePath, MathMax(50, maxLines), lines))
      return false;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;

      if(!JA_IsRecordType(line, "TRADE_OPEN"))
         continue;

      ulong pid = 0;
      if(!JA_ExtractJsonUlong(line, "position_id", pid))
         continue;

      if(pid != positionId)
         continue;

      JA_ExtractJsonString(line, "dominant_strategy_id", dominant_strategy_id);
      JA_ExtractJsonInt(line, "aligned_strategy_count", aligned_count);
      JA_ExtractJsonInt(line, "opposing_strategy_count", opposing_count);
      JA_ExtractJsonInt(line, "neutral_strategy_count", neutral_count);
      JA_ExtractJsonDouble(line, "attribution_confidence", attribution_confidence);

      JA_ExtractJsonString(line, "aligned_strategy_ids", aligned_strategy_ids);
      JA_ExtractJsonString(line, "opposing_strategy_ids", opposing_strategy_ids);
      JA_ExtractJsonString(line, "neutral_strategy_ids", neutral_strategy_ids);
      JA_ExtractJsonString(line, "strategies_compact", strategies_compact);

      // Return true only if we found something meaningful
      if(StringLen(dominant_strategy_id) > 0 || StringLen(strategies_compact) > 0 || StringLen(aligned_strategy_ids) > 0)
         return true;

      return false;
   }

   return false;
}

//---------------------------------------------------------
// Regime-aware performance foundation (windowed, conservative)
//---------------------------------------------------------
struct RegimePerfRow
{
   string regime_label;
   int    trades;
   int    wins;
   double net_profit;
};

struct RegimePerformanceSummary
{
   int total_trades;
   double overall_winrate;
   double overall_net_profit;

   RegimePerfRow rows[12];
   int rows_count;

   string summary_reason;
};

void InitRegimePerformanceSummary(RegimePerformanceSummary &s)
{
   s.total_trades = 0;
   s.overall_winrate = 0.0;
   s.overall_net_profit = 0.0;
   s.rows_count = 0;
   s.summary_reason = "";
}

int JA_FindRegimeRow(RegimePerformanceSummary &s, string label)
{
   for(int i = 0; i < s.rows_count; i++)
   {
      if(s.rows[i].regime_label == label)
         return i;
   }

   if(s.rows_count >= 12)
      return -1;

   int idx = s.rows_count;
   s.rows[idx].regime_label = label;
   s.rows[idx].trades = 0;
   s.rows[idx].wins = 0;
   s.rows[idx].net_profit = 0.0;
   s.rows_count++;
   return idx;
}

bool AnalyzeRegimePerformanceV1(string relativePath, int windowTrades, RegimePerformanceSummary &out)
{
   InitRegimePerformanceSummary(out);

   if(windowTrades <= 0) windowTrades = 20;

   string lines[];
   if(!JA_ReadLastNLines(relativePath, MathMax(250, windowTrades * 10), lines))
      return false;

   int seenTrades = 0;
   int wins = 0;
   double net = 0.0;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;

      if(!JA_IsRecordType(line, "TRADE"))
         continue;

      string reg = "";
      string res = "";

      JA_ExtractJsonString(line, "regime_label", reg);
      JA_ExtractTradeResultNormalized(line, res);

      // profit is numeric; extract as string by searching key then reading digits including - and .
      double profit = 0.0;
      string needle = "\"profit\":";
      int p = StringFind(line, needle);
      if(p >= 0)
      {
         int s = p + StringLen(needle);
         int e = s;
         while(e < StringLen(line))
         {
            ushort ch = StringGetCharacter(line, e);
            if((ch >= '0' && ch <= '9') || ch=='-' || ch=='.')
            {
               e++;
               continue;
            }
            break;
         }
         if(e > s)
            profit = StringToDouble(StringSubstr(line, s, e - s));
      }

      if(StringLen(reg) <= 0) reg = "UNKNOWN";

      int idx = JA_FindRegimeRow(out, reg);
      if(idx >= 0)
      {
         out.rows[idx].trades++;
         out.rows[idx].net_profit += profit;
         if(res == "WIN") out.rows[idx].wins++;
      }

      net += profit;
      if(res == "WIN") wins++;

      seenTrades++;
      if(seenTrades >= windowTrades)
         break;
   }

   out.total_trades = seenTrades;
   out.overall_net_profit = net;
   out.overall_winrate = (seenTrades > 0 ? (double)wins * 100.0 / (double)seenTrades : 0.0);
   out.summary_reason = "window=" + (string)seenTrades + "|wr=" + DoubleToString(out.overall_winrate, 1) + "|net=" + DoubleToString(net, 2);
   return true;
}


//---------------------------------------------------------
// Policy-block clustering (decision-level) v1
//---------------------------------------------------------
struct PolicyBlockClusterResult
{
   bool   policy_block_cluster_detected;
   string dominant_block_reason;
   double block_cluster_score;   // 0..1
   double block_rate;            // 0..1
   string block_dominant_regime;
   bool   overfiltering_suspected;
   int    window_size;
   string block_cluster_summary;
};

void InitPolicyBlockClusterResult(PolicyBlockClusterResult &r)
{
   r.policy_block_cluster_detected = false;
   r.dominant_block_reason = "";
   r.block_cluster_score = 0.0;
   r.block_rate = 0.0;
   r.block_dominant_regime = "";
   r.overfiltering_suspected = false;
   r.window_size = 0;
   r.block_cluster_summary = "";
}

bool AnalyzePolicyBlockClusteringV1(string journalPath, int window, PolicyBlockClusterResult &out)
{
   InitPolicyBlockClusterResult(out);

   string lines[];
   if(!JA_ReadLastNLines(journalPath, MathMax(50, window * 4), lines))
      return false;

   int totalDecisions = 0;
   int blocked = 0;

   string topReason = "";
   int topReasonCount = 0;

   string topRegime = "";
   int topRegimeCount = 0;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;
      if(!JA_IsRecordType(line, "DECISION")) continue;

      totalDecisions++;

      bool finalPerm = true;
      JA_ExtractJsonBool(line, "final_permission", finalPerm);

      string policyResult = "";
      JA_ExtractJsonString(line, "policy_result", policyResult);

      bool isBlocked = (!finalPerm);
      if(!isBlocked)
      {
         // some flows keep final_permission true but policy_result indicates block
         string pr = (StringLen(policyResult) > 0 ? policyResult : "");
         StringToUpper(pr);
         if(StringFind(pr, "BLOCK") >= 0 || StringFind(pr, "DENY") >= 0)
            isBlocked = true;
      }

      if(isBlocked)
      {
         blocked++;

         string reason = (StringLen(policyResult) > 0 ? policyResult : "policy_block");
         int rc = 1;

         if(reason == topReason)
            topReasonCount++;
         else if(topReasonCount <= rc)
         {
            topReason = reason;
            topReasonCount = rc;
         }

         string regime = "";
         JA_ExtractJsonString(line, "regime_label", regime);
         if(regime == topRegime)
            topRegimeCount++;
         else if(topRegimeCount <= 1)
         {
            topRegime = regime;
            topRegimeCount = 1;
         }
      }

      if(totalDecisions >= window)
         break;
   }

   out.window_size = totalDecisions;
   if(totalDecisions <= 0)
      return true;

   out.block_rate = JA_Clamp01((double)blocked / (double)totalDecisions);

   out.dominant_block_reason = topReason;
   out.block_dominant_regime = topRegime;

   // conservative scoring
   double score = 0.0;
   if(out.block_rate >= 0.55) score += 0.55;
   if(out.block_rate >= 0.70) score += 0.25;
   if(blocked >= MathMax(4, window / 2)) score += 0.15;

   out.block_cluster_score = JA_Clamp01(score);
   out.overfiltering_suspected = (out.block_cluster_score >= 0.65);
   out.policy_block_cluster_detected = (out.block_cluster_score >= 0.55);

   out.block_cluster_summary =
      "policy_block_cluster=" + string(out.policy_block_cluster_detected ? "true" : "false") +
      " | block_rate=" + DoubleToString(out.block_rate, 2) +
      " | score=" + DoubleToString(out.block_cluster_score, 2) +
      " | dom_reason=" + out.dominant_block_reason +
      " | dom_regime=" + out.block_dominant_regime;

   return true;
}


//---------------------------------------------------------
// Anti-Over-Governance Review v1 (windowed, explainable)
//---------------------------------------------------------
struct GovernanceReviewResult
{
   bool   governance_review_available;
   bool   insufficient_governance_evidence;

   double acceptance_rate;
   double block_rate;
   double regime_block_rate;
   double policy_block_rate;

   double lockdown_frequency;
   double defensive_state_frequency;
   double recovery_duration_average;
   double recovery_reentry_delay; // placeholder

   double no_action_frequency;
   double proposal_skip_due_to_insufficient_evidence_rate;

   double shadow_disagreement_rate;
   double shadow_more_aggressive_rate;
   double shadow_more_selective_rate;

   double production_vs_shadow_permission_gap;

   bool   overfiltering_suspected_extended;
   bool   overgovernance_detected;
   double overgovernance_score;

   string dominant_governance_issue;
   double governance_evidence_strength;
   string governance_summary_reason;
   string recommended_action_class;
};

void InitGovernanceReviewResult(GovernanceReviewResult &g)
{
   g.governance_review_available = false;
   g.insufficient_governance_evidence = true;

   g.acceptance_rate = 0.0;
   g.block_rate = 0.0;
   g.regime_block_rate = 0.0;
   g.policy_block_rate = 0.0;

   g.lockdown_frequency = 0.0;
   g.defensive_state_frequency = 0.0;
   g.recovery_duration_average = 0.0;
   g.recovery_reentry_delay = 0.0;

   g.no_action_frequency = 0.0;
   g.proposal_skip_due_to_insufficient_evidence_rate = 0.0;

   g.shadow_disagreement_rate = 0.0;
   g.shadow_more_aggressive_rate = 0.0;
   g.shadow_more_selective_rate = 0.0;

   g.production_vs_shadow_permission_gap = 0.0;

   g.overfiltering_suspected_extended = false;
   g.overgovernance_detected = false;
   g.overgovernance_score = 0.0;

   g.dominant_governance_issue = "UNKNOWN";
   g.governance_evidence_strength = 0.0;
   g.governance_summary_reason = "";
   g.recommended_action_class = "NO_ACTION";
}

bool AnalyzeGovernanceReviewV1(string relativePath, int window, GovernanceReviewResult &out)
{
   InitGovernanceReviewResult(out);

   if(window <= 0) window = 20;

   int maxLines = window * 6;
   string lines[];
   if(!JA_ReadLastNLines(relativePath, maxLines, lines))
      return false;

   int totalDecisions = 0;
   int accepted = 0;
   int blocked = 0;
   int policyBlocks = 0;
   int regimeBlocks = 0;

   int lockdown = 0;
   int defensive = 0;
   int recovery = 0;

   // recovery streak tracking (approx)
   int recoveryStreak = 0;
   int recoveryStreaks = 0;
   int recoveryStreakSum = 0;

   int evoMeta = 0;
   int noAction = 0;
   int insufficient = 0;

   int comps = 0;
   int disagree = 0;
   int moreAgg = 0;
   int moreSel = 0;

   double permGapSumAbs = 0.0;
   int permGapN = 0;

   for(int i = 0; i < ArraySize(lines); i++)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;

      string recType = "";
      if(!JA_ExtractJsonString(line, "record_type", recType))
         continue;

      if(recType == "DECISION")
      {
         totalDecisions++;

         string finalPermS = "";
         bool finalPerm = false;
         if(JA_ExtractJsonBool(line, "final_permission", finalPerm))
         {
            if(finalPerm) accepted++;
            else blocked++;
         }

         string policyResult = "";
         JA_ExtractJsonString(line, "policy_result", policyResult);

         if(!finalPerm)
         {
            if(StringFind(policyResult, "regime") >= 0)
               regimeBlocks++;
            else
               policyBlocks++;
         }

         string ps = "";
         if(JA_ExtractJsonString(line, "policy_state", ps))
         {
            if(ps == "LOCKDOWN") lockdown++;
            else if(ps == "DEFENSIVE") defensive++;
            else if(ps == "RECOVERY") recovery++;
         }

         // recovery streaks
         if(ps == "RECOVERY")
         {
            recoveryStreak++;
         }
         else
         {
            if(recoveryStreak > 0)
            {
               recoveryStreaks++;
               recoveryStreakSum += recoveryStreak;
               recoveryStreak = 0;
            }
         }
      }
      else if(recType == "SHADOW_COMPARISON")
      {
         comps++;
         bool agreeB=false;
         JA_ExtractJsonBool(line, "decision_agreement", agreeB);
         if(!agreeB) disagree++;

         string rel = "";
         JA_ExtractJsonString(line, "relation_class", rel);

         if(rel == "SHADOW_MORE_AGGRESSIVE" || rel == "SHADOW_ALLOWED_REJECTED_PRODUCTION")
            moreAgg++;
         if(rel == "SHADOW_MORE_SELECTIVE" || rel == "SHADOW_BLOCKED_PRODUCTION_TRADE")
            moreSel++;

         int dperm=0;
         if(JA_ExtractJsonInt(line, "permission_delta", dperm))
         {
            permGapSumAbs += MathAbs((double)dperm);
            permGapN++;
         }
      }
      else if(recType == "EVOLUTION_META")
      {
         evoMeta++;
         string action = "";
         JA_ExtractJsonString(line, "evolution_action", action);
         bool insuff=false;
         JA_ExtractJsonBool(line, "insufficient_evidence", insuff);

         if(action == "NO_ACTION" || action == "INSUFFICIENT_EVIDENCE")
            noAction++;
         if(insuff)
            insufficient++;
      }
   }

   if(recoveryStreak > 0)
   {
      recoveryStreaks++;
      recoveryStreakSum += recoveryStreak;
   }

   out.governance_review_available = true;

   int denom = MathMax(1, totalDecisions);
   out.acceptance_rate = (double)accepted / (double)denom;
   out.block_rate = (double)blocked / (double)denom;
   out.regime_block_rate = (double)regimeBlocks / (double)denom;
   out.policy_block_rate = (double)policyBlocks / (double)denom;

   out.lockdown_frequency = (double)lockdown / (double)denom;
   out.defensive_state_frequency = (double)(defensive + lockdown) / (double)denom;

   if(recoveryStreaks > 0)
      out.recovery_duration_average = (double)recoveryStreakSum / (double)recoveryStreaks;
   else
      out.recovery_duration_average = 0.0;

   if(evoMeta > 0)
   {
      out.no_action_frequency = (double)noAction / (double)evoMeta;
      out.proposal_skip_due_to_insufficient_evidence_rate = (double)insufficient / (double)evoMeta;
   }

   if(comps > 0)
   {
      out.shadow_disagreement_rate = (double)disagree / (double)comps;
      out.shadow_more_aggressive_rate = (double)moreAgg / (double)comps;
      out.shadow_more_selective_rate = (double)moreSel / (double)comps;
   }

   if(permGapN > 0)
      out.production_vs_shadow_permission_gap = permGapSumAbs / (double)permGapN;

   // Evidence strength
   double decStrength = JA_Clamp01((double)totalDecisions / (double)window);
   double cmpStrength = JA_Clamp01((double)comps / (double)MathMax(1, window / 2));
   out.governance_evidence_strength = JA_Clamp01(decStrength * 0.65 + cmpStrength * 0.35);

   out.insufficient_governance_evidence = (totalDecisions < MathMax(8, window / 2) && comps < 3);

   // Overfiltering / overgovernance heuristics (conservative)
   out.overfiltering_suspected_extended =
      (out.block_rate >= 0.70 && out.shadow_more_aggressive_rate >= 0.25) ||
      (out.policy_block_rate >= 0.55 && out.shadow_more_aggressive_rate >= 0.20);

   double s_block = JA_Clamp01((out.block_rate - 0.50) / 0.50);
   double s_lock  = JA_Clamp01(out.lockdown_frequency / 0.25);
   double s_noact = JA_Clamp01(out.no_action_frequency / 0.50);
   double s_gap   = JA_Clamp01(out.shadow_more_aggressive_rate / 0.50);

   out.overgovernance_score = JA_Clamp01(s_block * 0.35 + s_lock * 0.25 + s_noact * 0.15 + s_gap * 0.25);

   out.overgovernance_detected =
      (!out.insufficient_governance_evidence) &&
      (out.overgovernance_score >= 0.68 || out.overfiltering_suspected_extended);

   // Dominant issue + recommendation (metadata only)
   out.dominant_governance_issue = "NONE";
   out.recommended_action_class = "NO_ACTION";

   if(out.insufficient_governance_evidence)
   {
      out.dominant_governance_issue = "INSUFFICIENT_EVIDENCE";
      out.recommended_action_class = "NO_ACTION";
   }
   else if(out.lockdown_frequency >= 0.10)
   {
      out.dominant_governance_issue = "LOCKDOWN_DRAG";
      out.recommended_action_class = "REVIEW_LOCKDOWN_RULES";
   }
   else if(out.recovery_duration_average >= 6.0)
   {
      out.dominant_governance_issue = "RECOVERY_DRAG";
      out.recommended_action_class = "REVIEW_RECOVERY_RULES";
   }
   else if(out.no_action_frequency >= 0.45 || out.proposal_skip_due_to_insufficient_evidence_rate >= 0.45)
   {
      out.dominant_governance_issue = "EVOLUTION_PASSIVITY";
      out.recommended_action_class = "REVIEW_EVOLUTION_PASSIVITY";
   }
   else if(out.overfiltering_suspected_extended)
   {
      out.dominant_governance_issue = "OVERFILTERING";
      out.recommended_action_class = "REVIEW_OVERFILTERING";
   }
   else if(out.shadow_more_aggressive_rate >= 0.25 && out.block_rate >= 0.55)
   {
      out.dominant_governance_issue = "SHADOW_PRODUCTION_GAP";
      out.recommended_action_class = "REVIEW_SHADOW_PRODUCTION_GAP";
   }
   else if(out.block_rate >= 0.60)
   {
      out.dominant_governance_issue = "POLICY_TIGHTNESS";
      out.recommended_action_class = "REVIEW_POLICY_TIGHTNESS";
   }
   else
   {
      out.dominant_governance_issue = "NO_ACTION";
      out.recommended_action_class = "NO_ACTION";
   }

   out.governance_summary_reason =
      "acc=" + DoubleToString(out.acceptance_rate, 2) +
      "|blk=" + DoubleToString(out.block_rate, 2) +
      "|pblk=" + DoubleToString(out.policy_block_rate, 2) +
      "|rblk=" + DoubleToString(out.regime_block_rate, 2) +
      "|lock=" + DoubleToString(out.lockdown_frequency, 2) +
      "|noact=" + DoubleToString(out.no_action_frequency, 2) +
      "|shAgg=" + DoubleToString(out.shadow_more_aggressive_rate, 2) +
      "|shDis=" + DoubleToString(out.shadow_disagreement_rate, 2) +
      "|score=" + DoubleToString(out.overgovernance_score, 2) +
      "|issue=" + out.dominant_governance_issue;

   return true;
}



//---------------------------------------------------------

//---------------------------------------------------------
// Decision Quality Stats v1 (metadata foundation)
//---------------------------------------------------------
struct DecisionQualityStats
{
   bool   valid;
   int    window_size;
   int    decision_count;
   int    trade_signal_count;
   double avg_entry_quality;
   double avg_entry_edge;
   double avg_follow_through;
   double avg_regime_fit;
   double avg_decision_quality;
   double poor_entry_rate;
   double thin_entry_edge_rate;
   double weak_follow_through_rate;
   double weak_fit_rate;
   double low_quality_rate;

   bool   low_quality_decision_cluster_detected;
   string dominant_low_quality_pattern;
   double quality_cluster_score;
   bool   insufficient_quality_evidence;
   string quality_cluster_summary;

   string summary_reason;
};

void InitDecisionQualityStats(DecisionQualityStats &s)
{
   s.valid = false;
   s.window_size = 0;
   s.decision_count = 0;
   s.trade_signal_count = 0;
   s.avg_entry_quality = 0.0;
   s.avg_entry_edge = 0.0;
   s.avg_follow_through = 0.0;
   s.avg_regime_fit = 0.0;
   s.avg_decision_quality = 0.0;
   s.poor_entry_rate = 0.0;
   s.thin_entry_edge_rate = 0.0;
   s.weak_follow_through_rate = 0.0;
   s.weak_fit_rate = 0.0;
   s.low_quality_rate = 0.0;

   s.low_quality_decision_cluster_detected = false;
   s.dominant_low_quality_pattern = "";
   s.quality_cluster_score = 0.0;
   s.insufficient_quality_evidence = true;
   s.quality_cluster_summary = "";

   s.summary_reason = "";
}

bool AnalyzeDecisionQualityStatsV1(int windowDecisions, DecisionQualityStats &out)
{
   InitDecisionQualityStats(out);
   if(windowDecisions <= 0) windowDecisions = 20;

   string lines[];
   if(!JA_ReadAllLines("AI\\ai_performance_journal.jsonl", lines))
   {
      out.summary_reason = "journal_read_failed";
      return false;
   }

   int n=0, tradeN=0;
   double sumEq=0.0, sumEdge=0.0, sumFt=0.0, sumFit=0.0, sumDq=0.0;
   int poorEq=0, thinEdge=0, weakFt=0, weakFit=0, lowDq=0;
   int patPoorEntry=0, patThinEdge=0, patWeakFT=0, patWeakFit=0;

   for(int i=ArraySize(lines)-1; i>=0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;
      if(!JA_IsRecordType(line, "DECISION")) continue;

      n++;

      double eq=0.0, edge=0.0, ft=0.0, fit=0.0, dq=0.0;
      JA_ExtractJsonDouble(line, "entry_quality_score", eq);
      JA_ExtractJsonDouble(line, "entry_edge_score", edge);
      JA_ExtractJsonDouble(line, "follow_through_quality_score", ft);
      JA_ExtractJsonDouble(line, "strategy_regime_fit_score", fit);
      JA_ExtractJsonDouble(line, "decision_quality_score", dq);

      string final_decision="";
      JA_ExtractJsonString(line, "final_decision", final_decision);
      if(final_decision == "BUY" || final_decision == "SELL") tradeN++;

      sumEq += eq;
      sumEdge += edge;
      sumFt += ft;
      sumFit += fit;
      sumDq += dq;

      string eql="", eel="", ftl="", fl="", dql="";
      JA_ExtractJsonString(line, "entry_quality_label", eql);
      JA_ExtractJsonString(line, "entry_edge_label", eel);
      JA_ExtractJsonString(line, "follow_through_quality_label", ftl);
      JA_ExtractJsonString(line, "strategy_regime_fit_label", fl);
      JA_ExtractJsonString(line, "decision_quality_label", dql);

      if(eql == "POOR_ENTRY" || eql == "NO_ENTRY_EDGE") { poorEq++; patPoorEntry++; }
      if(eel == "THIN_ENTRY_EDGE" || eel == "POOR_ENTRY_EDGE" || eel == "NEGATIVE_ENTRY_EDGE") { thinEdge++; patThinEdge++; }
      if(ftl == "WEAK_FOLLOW_THROUGH" || ftl == "COLLAPSING_FOLLOW_THROUGH") { weakFt++; patWeakFT++; }
      if(fl == "WEAK_REGIME_FIT" || fl == "CONTRADICTED_BY_REGIME") { weakFit++; patWeakFit++; }
      if(dql == "LOW_QUALITY_DECISION" || dql == "BLOCK_WORTHY_DECISION") lowDq++;

      if(n >= windowDecisions) break;
   }

   out.window_size = windowDecisions;
   out.decision_count = n;
   out.trade_signal_count = tradeN;

   if(n <= 0)
   {
      out.summary_reason = "no_decisions";
      return false;
   }

   out.avg_entry_quality = sumEq / (double)n;
   out.avg_entry_edge = sumEdge / (double)n;
   out.avg_follow_through = sumFt / (double)n;
   out.avg_regime_fit = sumFit / (double)n;
   out.avg_decision_quality = sumDq / (double)n;
   out.poor_entry_rate = (double)poorEq / (double)n;
   out.thin_entry_edge_rate = (double)thinEdge / (double)n;
   out.weak_follow_through_rate = (double)weakFt / (double)n;
   out.weak_fit_rate = (double)weakFit / (double)n;
   out.low_quality_rate = (double)lowDq / (double)n;
   out.valid = true;

   // Simple clustering signal (conservative)
   out.insufficient_quality_evidence = (n < 12);
   double clusterScore = 0.0;
   if(!out.insufficient_quality_evidence)
   {
      clusterScore =
         0.30 * JA_Clamp01(out.poor_entry_rate / 0.45) +
         0.25 * JA_Clamp01(out.thin_entry_edge_rate / 0.55) +
         0.25 * JA_Clamp01(out.weak_follow_through_rate / 0.45) +
         0.20 * JA_Clamp01(out.low_quality_rate / 0.40);
      clusterScore = JA_Clamp01(clusterScore);
   }
   out.quality_cluster_score = clusterScore;
   out.low_quality_decision_cluster_detected = (!out.insufficient_quality_evidence && clusterScore >= 0.60);

   // Dominant low-quality pattern (best-effort)
   int maxPat = patPoorEntry;
   string dom = "POOR_ENTRY";
   if(patThinEdge > maxPat) { maxPat = patThinEdge; dom = "THIN_ENTRY_EDGE"; }
   if(patWeakFT > maxPat) { maxPat = patWeakFT; dom = "WEAK_FOLLOW_THROUGH"; }
   if(patWeakFit > maxPat) { maxPat = patWeakFit; dom = "WEAK_REGIME_FIT"; }
   out.dominant_low_quality_pattern = dom;

   out.quality_cluster_summary =
      "cluster=" + DoubleToString(out.quality_cluster_score, 2) +
      "|dom=" + out.dominant_low_quality_pattern +
      "|poorEq=" + DoubleToString(out.poor_entry_rate, 2) +
      "|thinEdge=" + DoubleToString(out.thin_entry_edge_rate, 2) +
      "|weakFT=" + DoubleToString(out.weak_follow_through_rate, 2) +
      "|lowDQ=" + DoubleToString(out.low_quality_rate, 2);

   out.summary_reason =
      "n=" + IntegerToString(n) +
      "|avg_eq=" + DoubleToString(out.avg_entry_quality, 2) +
      "|avg_edge=" + DoubleToString(out.avg_entry_edge, 2) +
      "|avg_ft=" + DoubleToString(out.avg_follow_through, 2) +
      "|avg_fit=" + DoubleToString(out.avg_regime_fit, 2) +
      "|avg_dq=" + DoubleToString(out.avg_decision_quality, 2) +
      "|poor_eq=" + DoubleToString(out.poor_entry_rate, 2) +
      "|thin_edge=" + DoubleToString(out.thin_entry_edge_rate, 2) +
      "|weak_ft=" + DoubleToString(out.weak_follow_through_rate, 2) +
      "|weak_fit=" + DoubleToString(out.weak_fit_rate, 2) +
      "|low_dq=" + DoubleToString(out.low_quality_rate, 2);

   return true;
}



//---------------------------------------------------------
//---------------------------------------------------------
// Multi-Dimensional Edge Analytics v1 (windowed, conservative)
// Dimensions: regime + mode + failure + quality labels + execution geometry
//---------------------------------------------------------
struct MultiDimEdgeAnalyticsBucket
{
   string key;
   int    trade_count;
   int    win_count;
   double net_profit;
};

struct MultiDimEdgeAnalyticsResult
{
   bool   available;
   bool   insufficient_multidim_evidence;

   int    total_trades;
   int    window_size_used;

   string worst_dimension_bucket;
   string strongest_dimension_bucket;

   bool   edge_deterioration_detected;
   string edge_summary_reason;
};

void InitMultiDimEdgeAnalyticsResult(MultiDimEdgeAnalyticsResult &r)
{
   r.available = false;
   r.insufficient_multidim_evidence = true;
   r.total_trades = 0;
   r.window_size_used = 0;
   r.worst_dimension_bucket = "";
   r.strongest_dimension_bucket = "";
   r.edge_deterioration_detected = false;
   r.edge_summary_reason = "";
}

// Edge Stability Analytics v1 (multi-window, conservative)
//---------------------------------------------------------
struct EdgeStabilityAnalyticsResult
{
   bool   available;
   bool   insufficient_stability_evidence;

   int    short_window_size;
   int    medium_window_size;

   MultiDimEdgeAnalyticsResult short_window_summary;
   MultiDimEdgeAnalyticsResult medium_window_summary;

   double edge_stability_score; // 0..1 (higher = more stable)
   bool   recent_edge_deterioration_detected;
   bool   structural_edge_weakness_detected;

   string deterioration_summary;
   string stability_summary;
};

void InitEdgeStabilityAnalyticsResult(EdgeStabilityAnalyticsResult &r)
{
   r.available = false;
   r.insufficient_stability_evidence = true;
   r.short_window_size = 0;
   r.medium_window_size = 0;
   InitMultiDimEdgeAnalyticsResult(r.short_window_summary);
   InitMultiDimEdgeAnalyticsResult(r.medium_window_summary);
   r.edge_stability_score = 0.0;
   r.recent_edge_deterioration_detected = false;
   r.structural_edge_weakness_detected = false;
   r.deterioration_summary = "";
   r.stability_summary = "";
}

bool AnalyzeEdgeStabilityAnalyticsV1(int shortWindowTrades, int mediumWindowTrades, EdgeStabilityAnalyticsResult &out)
{
   InitEdgeStabilityAnalyticsResult(out);

   if(shortWindowTrades <= 0) shortWindowTrades = 12;
   if(mediumWindowTrades <= 0) mediumWindowTrades = 24;

   out.short_window_size = shortWindowTrades;
   out.medium_window_size = mediumWindowTrades;

   if(!AnalyzeMultiDimensionalEdgeAnalyticsV1(shortWindowTrades, out.short_window_summary))
      return false;

   if(!AnalyzeMultiDimensionalEdgeAnalyticsV1(mediumWindowTrades, out.medium_window_summary))
      return false;

   out.available = out.short_window_summary.available && out.medium_window_summary.available;

   if(!out.available)
      return true;

   if(out.short_window_summary.insufficient_multidim_evidence || out.medium_window_summary.insufficient_multidim_evidence)
   {
      out.insufficient_stability_evidence = true;
      out.edge_stability_score = 0.0;
      out.stability_summary = "insufficient_stability_evidence";
      return true;
   }

   out.insufficient_stability_evidence = false;

   string swWorst = out.short_window_summary.worst_dimension_bucket;
   string mwWorst = out.medium_window_summary.worst_dimension_bucket;

   bool swBad = out.short_window_summary.edge_deterioration_detected;
   bool mwBad = out.medium_window_summary.edge_deterioration_detected;

   // stability heuristics (conservative, explainable)
   if(!swBad && !mwBad)
   {
      out.edge_stability_score = 0.80;
      out.stability_summary = "stable: no_deterioration_short_or_medium";
   }
   else if(swBad && !mwBad)
   {
      out.edge_stability_score = 0.45;
      out.recent_edge_deterioration_detected = true;
      out.deterioration_summary = "recent_deterioration: short_window_only";
      out.stability_summary = "instability_candidate";
   }
   else if(swBad && mwBad)
   {
      out.edge_stability_score = 0.25;
      out.structural_edge_weakness_detected = true;
      out.deterioration_summary = "structural_weakness_candidate: short+medium";
      out.stability_summary = "structural_weakness_candidate";
   }
   else
   {
      // medium bad but short not bad: odd edge case; treat as uncertain
      out.edge_stability_score = 0.35;
      out.stability_summary = "uncertain: medium_bad_short_ok";
   }

   // bucket agreement adds confidence
   if(swBad && mwBad && swWorst == mwWorst && StringLen(swWorst) > 0)
   {
      out.edge_stability_score = JA_Clamp01(out.edge_stability_score - 0.05);
      out.deterioration_summary += "|same_worst_bucket";
   }

   out.stability_summary =
      out.stability_summary +
      "|swWorst=" + swWorst +
      "|mwWorst=" + mwWorst;

   return true;
}


//---------------------------------------------------------
// Phase 8A: Council Strategy Responsibility Analytics (v1)
// - Consumes COUNCIL_OUTCOME_ATTRIBUTION records
// - Conservative sample discipline
//---------------------------------------------------------
#define CA_MAX_STRATEGIES 24
#define CA_MAX_REGIMES_PER_STRAT 6

struct StrategyRegimeMiniRow
{
   string regime_label;
   int    n;
   int    wins;
   int    losses;
   double net_profit;

   // Phase 8B: correctness mini-counters
   int    aligned_wins;
   int    aligned_losses;
   int    dissent_correct;
   int    dissent_wrong;
};

struct StrategyResponsibilitySummary
{
   bool   valid;

   string strategy_id;

   int appearances;
   int aligned_with_final;
   int opposed_final;
   int neutral_or_abstain;

   int dominant_at_open;

   int wins_linked;
   int losses_linked;
   int high_quality_win;
   int low_quality_loss;
   int adverse_geometry_loss;

   // Phase 8B: aligned vs dissent correctness
   int aligned_win_credit_count;
   int aligned_loss_blame_count;
   int correct_dissent_count;
   int wrong_dissent_count;
   int high_quality_win_credit_count;
   int low_quality_loss_blame_count;
   int adverse_geometry_loss_blame_count;
   int correct_dissent_on_bad_trade_count;

   double strategy_correctness_balance; // [-1..+1] best-effort
   string strategy_trust_readiness_hint;
   string strategy_dampening_readiness_hint;

   // Failure linkage (v1)
   int chop_failure;
   int late_entry_failure;
   int weak_consensus_failure;
   int poor_entry_failure;
   int adverse_geometry_failure;

   StrategyRegimeMiniRow regimes[CA_MAX_REGIMES_PER_STRAT];
   int regimes_count;
};

struct CouncilAttributionAnalyticsResult
{
   bool   available;

   bool   insufficient_attribution_evidence;
   bool   insufficient_dissent_evidence;

   int    total_linked_outcomes;
   int    total_council_trades_seen;

   int    min_strategy_appearances;
   int    min_linked_outcomes;
   int    regime_min_sample;
   int    min_dissent_samples;

   StrategyResponsibilitySummary strategies[CA_MAX_STRATEGIES];
   int strategies_count;

   string most_reliable_strategy_candidate;
   string most_problematic_strategy_candidate;

   // Phase 8B: correctness / dissent candidates (sample disciplined)
   string most_consistently_correct_strategy_candidate;
   string most_consistently_misleading_strategy_candidate;
   string best_dissenting_strategy_candidate;
   string weakest_aligned_strategy_candidate;

   string regime_specific_best_strategy_candidate;
   string regime_specific_weak_strategy_candidate;

   // Phase 8B: regime-conditioned correctness/dissent (mini, sample disciplined)
   string regime_specific_correct_strategy_candidate;
   string regime_specific_dissent_candidate;
   string regime_specific_misleading_strategy_candidate;

   double attribution_evidence_strength;
   double attribution_correctness_evidence_strength;

   string attribution_summary;
   string attribution_correctness_summary;
};

void InitStrategyResponsibilitySummary(StrategyResponsibilitySummary &s)
{
   s.valid = false;

   s.strategy_id = "";

   s.appearances = 0;
   s.aligned_with_final = 0;
   s.opposed_final = 0;
   s.neutral_or_abstain = 0;

   s.dominant_at_open = 0;

   s.wins_linked = 0;
   s.losses_linked = 0;
   s.high_quality_win = 0;
   s.low_quality_loss = 0;
   s.adverse_geometry_loss = 0;

   s.aligned_win_credit_count = 0;
   s.aligned_loss_blame_count = 0;

   s.correct_dissent_count = 0;
   s.wrong_dissent_count = 0;

   s.high_quality_win_credit_count = 0;
   s.low_quality_loss_blame_count = 0;
   s.adverse_geometry_loss_blame_count = 0;

   s.correct_dissent_on_bad_trade_count = 0;

   s.strategy_correctness_balance = 0.0;
   s.strategy_trust_readiness_hint = "";
   s.strategy_dampening_readiness_hint = "";

   s.chop_failure = 0;
   s.late_entry_failure = 0;
   s.weak_consensus_failure = 0;
   s.poor_entry_failure = 0;
   s.adverse_geometry_failure = 0;

   s.regimes_count = 0;
   for(int i = 0; i < CA_MAX_REGIMES_PER_STRAT; i++)
   {
      s.regimes[i].regime_label = "";
      s.regimes[i].n = 0;
      s.regimes[i].wins = 0;
      s.regimes[i].losses = 0;
      s.regimes[i].net_profit = 0.0;
      s.regimes[i].aligned_wins = 0;
      s.regimes[i].aligned_losses = 0;
      s.regimes[i].dissent_correct = 0;
      s.regimes[i].dissent_wrong = 0;
   }
}


void InitCouncilAttributionAnalyticsResult(CouncilAttributionAnalyticsResult &r)
{
   r.available = false;

   r.insufficient_attribution_evidence = true;
   r.insufficient_dissent_evidence = true;

   r.total_linked_outcomes = 0;
   r.total_council_trades_seen = 0;

   r.min_strategy_appearances = 5;
   r.min_linked_outcomes = 3;
   r.regime_min_sample = 3;
   r.min_dissent_samples = 3;

   r.strategies_count = 0;

   r.most_reliable_strategy_candidate = "";
   r.most_problematic_strategy_candidate = "";
   r.most_consistently_correct_strategy_candidate = "";
   r.most_consistently_misleading_strategy_candidate = "";
   r.best_dissenting_strategy_candidate = "";
   r.weakest_aligned_strategy_candidate = "";

   r.regime_specific_best_strategy_candidate = "";
   r.regime_specific_weak_strategy_candidate = "";
   r.regime_specific_correct_strategy_candidate = "";
   r.regime_specific_dissent_candidate = "";
   r.regime_specific_misleading_strategy_candidate = "";

   r.attribution_evidence_strength = 0.0;
   r.attribution_correctness_evidence_strength = 0.0;

   r.attribution_summary = "";
   r.attribution_correctness_summary = "";

   for(int i = 0; i < CA_MAX_STRATEGIES; i++)
      InitStrategyResponsibilitySummary(r.strategies[i]);
}


int CA_FindOrAddStrategy(CouncilAttributionAnalyticsResult &r, string strategyId)
{
   strategyId = JA_Trim(strategyId);
   if(StringLen(strategyId) <= 0) return -1;

   for(int i = 0; i < r.strategies_count; i++)
   {
      if(r.strategies[i].valid && r.strategies[i].strategy_id == strategyId)
         return i;
   }

   if(r.strategies_count >= CA_MAX_STRATEGIES)
      return -1;

   int idx = r.strategies_count;
   r.strategies_count++;

   InitStrategyResponsibilitySummary(r.strategies[idx]);
   r.strategies[idx].valid = true;
   r.strategies[idx].strategy_id = strategyId;
   return idx;
}

void CA_UpdateRegimeRow(StrategyResponsibilitySummary &s, string regime, bool aligned, bool opposed, bool isWin, double profit)
{
   regime = JA_Trim(regime);
   if(StringLen(regime) <= 0) regime = "UNKNOWN";

   int idx = -1;
   for(int i = 0; i < s.regimes_count; i++)
   {
      if(s.regimes[i].regime_label == regime)
      {
         idx = i;
         break;
      }
   }

   if(idx < 0)
   {
      if(s.regimes_count >= CA_MAX_REGIMES_PER_STRAT)
         return;

      idx = s.regimes_count;
      s.regimes_count++;
      s.regimes[idx].regime_label = regime;
      s.regimes[idx].n = 0;
      s.regimes[idx].wins = 0;
      s.regimes[idx].losses = 0;
      s.regimes[idx].net_profit = 0.0;
      s.regimes[idx].aligned_wins = 0;
      s.regimes[idx].aligned_losses = 0;
      s.regimes[idx].dissent_correct = 0;
      s.regimes[idx].dissent_wrong = 0;
   }

   s.regimes[idx].n++;
   if(isWin) s.regimes[idx].wins++;
   else s.regimes[idx].losses++;
   s.regimes[idx].net_profit += profit;

   if(aligned)
   {
      if(isWin) s.regimes[idx].aligned_wins++;
      else s.regimes[idx].aligned_losses++;
   }
   else if(opposed)
   {
      if(!isWin) s.regimes[idx].dissent_correct++;
      else s.regimes[idx].dissent_wrong++;
   }
}

void CA_ApplyFailureLinkage(StrategyResponsibilitySummary &s, string failureClass, string outcomeQuality)
{
   failureClass = JA_Trim(failureClass);
   outcomeQuality = JA_Trim(outcomeQuality);

   if(failureClass == "CHOP_FAILURE") s.chop_failure++;
   if(failureClass == "LATE_ENTRY_FAILURE") s.late_entry_failure++;
   if(failureClass == "WEAK_CONSENSUS_FAILURE") s.weak_consensus_failure++;

   // Some deployments use these naming conventions
   if(StringFind(failureClass, "POOR_ENTRY") >= 0) s.poor_entry_failure++;
   if(StringFind(failureClass, "ADVERSE_EXECUTION_GEOMETRY") >= 0) s.adverse_geometry_failure++;

   if(StringFind(outcomeQuality, "ADVERSE_GEOMETRY_LOSS") >= 0) s.adverse_geometry_loss++;
}

bool CA_CsvContains(string csv, string token)
{
   string padded = "," + csv + ",";
   string target = "," + token + ",";
   return (StringFind(padded, target) >= 0);
}

void CA_UpdateStrategyFromOutcome(
   CouncilAttributionAnalyticsResult &r,
   string strategyId,
   bool aligned,
   bool opposed,
   bool neutral,
   bool isDominant,
   bool isWin,
   string regimeLabel,
   double profit,
   string failureClass,
   string outcomeQuality
)
{
   int idx = CA_FindOrAddStrategy(r, strategyId);
   if(idx < 0) return;

   StrategyResponsibilitySummary s = r.strategies[idx];

   s.appearances++;
   if(aligned) s.aligned_with_final++;
   else if(opposed) s.opposed_final++;
   else s.neutral_or_abstain++;

   if(isDominant) s.dominant_at_open++;

   if(isWin)
   {
      s.wins_linked++;
      if(StringFind(outcomeQuality, "HIGH_QUALITY_WIN") >= 0)
         s.high_quality_win++;
   }
   else
   {
      s.losses_linked++;
      if(StringFind(outcomeQuality, "LOW_QUALITY_LOSS") >= 0)
         s.low_quality_loss++;
   }


   bool isHQWin  = (StringFind(outcomeQuality, "HIGH_QUALITY_WIN") >= 0);
   bool isLQLoss = (StringFind(outcomeQuality, "LOW_QUALITY_LOSS") >= 0);
   bool isAGLoss = (StringFind(outcomeQuality, "ADVERSE_GEOMETRY_LOSS") >= 0);
   bool badLoss = (!isWin && (isLQLoss || isAGLoss));

   if(aligned)
   {
      if(isWin)
      {
         s.aligned_win_credit_count++;
         if(isHQWin) s.high_quality_win_credit_count++;
      }
      else
      {
         s.aligned_loss_blame_count++;
         if(isLQLoss) s.low_quality_loss_blame_count++;
         if(isAGLoss) s.adverse_geometry_loss_blame_count++;
      }
   }
   else if(opposed)
   {
      if(!isWin)
      {
         s.correct_dissent_count++;
         if(badLoss) s.correct_dissent_on_bad_trade_count++;
      }
      else
      {
         s.wrong_dissent_count++;
      }
   }

   CA_ApplyFailureLinkage(s, failureClass, outcomeQuality);
   CA_UpdateRegimeRow(s, regimeLabel, aligned, opposed, isWin, profit);
   r.strategies[idx] = s;
}

// Main analytics entry point
bool AnalyzeCouncilAttributionAnalyticsV2(
   int maxLines,
   int minStrategyAppearances,
   int minLinkedOutcomes,
   int regimeMinSample,
   int minDissentSamples,
   CouncilAttributionAnalyticsResult &out
)
{
   InitCouncilAttributionAnalyticsResult(out);

   out.min_strategy_appearances = minStrategyAppearances;
   out.min_linked_outcomes = minLinkedOutcomes;
   out.regime_min_sample = regimeMinSample;
   out.min_dissent_samples = minDissentSamples;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", MathMax(80, maxLines), lines))
      return false;

   int seen = 0;
   int dissentSamples = 0;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string line = JA_Trim(lines[i]);
      if(StringLen(line) <= 0) continue;

      string recType = "";
      if(!JA_ExtractJsonString(line, "record_type", recType))
         continue;

      if(recType != "COUNCIL_OUTCOME_ATTRIBUTION")
         continue;

      out.total_council_trades_seen++;
      seen++;

      string regime = "";
      JA_ExtractJsonString(line, "regime_label", regime);

      string result = "";
      JA_ExtractJsonString(line, "result", result);
      bool isWin = (result == "WIN");

      double profit = 0.0;
      JA_ExtractJsonDouble(line, "profit", profit);

      string failureClass = "";
      JA_ExtractJsonString(line, "failure_class", failureClass);

      string oq = "";
      JA_ExtractJsonString(line, "outcome_quality_summary", oq);

      string dom = "";
      JA_ExtractJsonString(line, "dominant_strategy_id", dom);

      string alignedCsv = "", oppCsv = "", neutCsv = "";
      JA_ExtractJsonString(line, "aligned_strategy_ids", alignedCsv);
      JA_ExtractJsonString(line, "opposing_strategy_ids", oppCsv);
      JA_ExtractJsonString(line, "neutral_strategy_ids", neutCsv);

      // Update aligned strategies
      string aParts[];
      int aN = StringSplit(alignedCsv, ',', aParts);
      for(int k = 0; k < aN; k++)
      {
         string sid = JA_Trim(aParts[k]);
         if(StringLen(sid) <= 0) continue;
         bool isDominant = (sid == dom);
         CA_UpdateStrategyFromOutcome(out, sid, true, false, false, isDominant, isWin, regime, profit, failureClass, oq);
      }

      // Update opposing strategies
      string oParts[];
      int oN = StringSplit(oppCsv, ',', oParts);
      for(int k = 0; k < oN; k++)
      {
         string sid = JA_Trim(oParts[k]);
         dissentSamples++;
         if(StringLen(sid) <= 0) continue;
         bool isDominant = (sid == dom);
         CA_UpdateStrategyFromOutcome(out, sid, false, true, false, isDominant, isWin, regime, profit, failureClass, oq);
      }

      // Update neutral strategies
      string nParts[];
      int nN = StringSplit(neutCsv, ',', nParts);
      for(int k = 0; k < nN; k++)
      {
         string sid = JA_Trim(nParts[k]);
         if(StringLen(sid) <= 0) continue;
         bool isDominant = (sid == dom);
         CA_UpdateStrategyFromOutcome(out, sid, false, false, true, isDominant, isWin, regime, profit, failureClass, oq);
      }

      out.total_linked_outcomes++;

      if(seen >= maxLines)
         break;
   }

   out.available = (out.total_linked_outcomes > 0);

   // Evidence strength (conservative, saturates at 20 linked outcomes)
   out.attribution_evidence_strength = JA_Clamp01((double)out.total_linked_outcomes / 20.0);

   // Candidate selection with sample discipline
   string bestId = "";
   double bestScore = -1.0;

   string worstId = "";
   double worstScore = 999.0;

   string bestRegKey = "";
   double bestRegProfit = -1e9;

   string worstRegKey = "";
   double worstRegProfit = 1e9;

   int eligible = 0;

   for(int i = 0; i < out.strategies_count; i++)
   {
      StrategyResponsibilitySummary s = out.strategies[i];
      if(!s.valid) continue;

      int linked = s.wins_linked + s.losses_linked;
      if(s.appearances < out.min_strategy_appearances) continue;
      if(linked < out.min_linked_outcomes) continue;

      eligible++;

      double winrate = (linked > 0 ? (double)s.wins_linked / (double)linked : 0.0);

      // Reliable: prioritize winrate then HQ wins
      double reliableScore = winrate + 0.02 * (double)s.high_quality_win;

      if(reliableScore > bestScore)
      {
         bestScore = reliableScore;
         bestId = s.strategy_id;
      }

      // Problematic: prioritize low winrate, plus adverse losses / poor entry failures
      double problematicScore = (1.0 - winrate) + 0.02 * (double)s.low_quality_loss + 0.02 * (double)s.adverse_geometry_loss;
      if(problematicScore < worstScore)
      {
         worstScore = problematicScore;
         worstId = s.strategy_id;
      }

      // Regime conditioned best/worst (net_profit) with sample discipline
      for(int j = 0; j < s.regimes_count; j++)
      {
         if(s.regimes[j].n < out.regime_min_sample) continue;

         double np = s.regimes[j].net_profit;

         string key = s.strategy_id + "@" + s.regimes[j].regime_label + "|n=" + IntegerToString(s.regimes[j].n) + "|np=" + DoubleToString(np, 2);

         if(np > bestRegProfit)
         {
            bestRegProfit = np;
            bestRegKey = key;
         }
         if(np < worstRegProfit)
         {
            worstRegProfit = np;
            worstRegKey = key;
         }
      }
   }


   // Phase 8B: dissent evidence
   out.insufficient_dissent_evidence = (dissentSamples < out.min_dissent_samples);
   out.attribution_correctness_evidence_strength = JA_Clamp01((double) MathMin(dissentSamples, out.total_linked_outcomes) / 20.0);

   string correctId = "";
   double correctScore = -999.0;

   string misleadingId = "";
   double misleadingScore = -999.0;

   string bestDissentId = "";
   double bestDissentScore = -999.0;

   string weakestAlignedId = "";
   double weakestAlignedScore = -999.0;

   string regCorrectKey = "";
   double regCorrectScore = -999.0;

   string regDissentKey = "";
   double regDissentScore = -999.0;

   string regMisleadKey = "";
   double regMisleadScore = -999.0;

   for(int i = 0; i < out.strategies_count; i++)
   {
      StrategyResponsibilitySummary s = out.strategies[i];
      if(!s.valid) continue;

      int linked = s.wins_linked + s.losses_linked;
      if(s.appearances < out.min_strategy_appearances) continue;
      if(linked < out.min_linked_outcomes) continue;

      int alignedTotal = s.aligned_win_credit_count + s.aligned_loss_blame_count;
      int dissentTotal = s.correct_dissent_count + s.wrong_dissent_count;

      // Correctness balance: aligned wins credit, aligned losses blame; dissent correctness credited lightly (best-effort).
      double bal = 0.0;
      if(alignedTotal > 0)
         bal += ((double)s.aligned_win_credit_count - (double)s.aligned_loss_blame_count) / (double)alignedTotal;

      if(dissentTotal > 0)
         bal += 0.6 * ((double)s.correct_dissent_count - (double)s.wrong_dissent_count) / (double)dissentTotal;

      // normalize to [-1..+1]
      if(bal > 1.0) bal = 1.0;
      if(bal < -1.0) bal = -1.0;

      s.strategy_correctness_balance = bal;

      // Readiness hints (metadata only)
      if(bal >= 0.35) s.strategy_trust_readiness_hint = "TRUST_CANDIDATE";
      else if(bal <= -0.35) s.strategy_trust_readiness_hint = "MISLEADING_CANDIDATE";
      else s.strategy_trust_readiness_hint = "NEUTRAL";

      if(s.low_quality_loss_blame_count + s.adverse_geometry_loss_blame_count >= 2)
         s.strategy_dampening_readiness_hint = "DAMPEN_CANDIDATE";
      else
         s.strategy_dampening_readiness_hint = "";

      if(!out.insufficient_dissent_evidence && bal > correctScore)
      {
         correctScore = bal;
         correctId = s.strategy_id;
      }

      // Misleading: negative balance & enough aligned samples
      if(alignedTotal >= out.min_linked_outcomes && (-bal) > misleadingScore)
      {
         misleadingScore = (-bal);
         misleadingId = s.strategy_id;
      }

      // Best dissenting: requires dissent samples
      if(dissentTotal >= out.min_dissent_samples)
      {
         double ds = ((double)s.correct_dissent_count - (double)s.wrong_dissent_count) / (double)dissentTotal;
         if(ds > bestDissentScore)
         {
            bestDissentScore = ds;
            bestDissentId = s.strategy_id;
         }
      }

      // Weakest aligned: requires aligned samples
      if(alignedTotal >= out.min_linked_outcomes)
      {
         double as = ((double)s.aligned_win_credit_count - (double)s.aligned_loss_blame_count) / (double)alignedTotal;
         if(as < weakestAlignedScore || weakestAlignedScore == -999.0)
         {
            weakestAlignedScore = as;
            weakestAlignedId = s.strategy_id;
         }
      }

      // Regime-conditioned correctness (mini, sample-disciplined)
      for(int j = 0; j < s.regimes_count; j++)
      {
         if(s.regimes[j].n < out.regime_min_sample) continue;

         int aw = s.regimes[j].aligned_wins;
         int al = s.regimes[j].aligned_losses;
         int dc = s.regimes[j].dissent_correct;
         int dw = s.regimes[j].dissent_wrong;

         double rb = 0.0;
         int at = aw + al;
         int dt = dc + dw;

         if(at > 0) rb += ((double)aw - (double)al) / (double)at;
         if(dt > 0) rb += 0.6 * ((double)dc - (double)dw) / (double)dt;

         if(rb > 1.0) rb = 1.0;
         if(rb < -1.0) rb = -1.0;

         string rkey = s.strategy_id + "@" + s.regimes[j].regime_label + "|n=" + IntegerToString(s.regimes[j].n) + "|bal=" + DoubleToString(rb, 2);

         if(rb > regCorrectScore)
         {
            regCorrectScore = rb;
            regCorrectKey = rkey;
         }
         if(dt >= out.min_dissent_samples && ((double)dc - (double)dw) / (double)dt > regDissentScore)
         {
            regDissentScore = ((double)dc - (double)dw) / (double)dt;
            regDissentKey = rkey;
         }
         if((-rb) > regMisleadScore)
         {
            regMisleadScore = (-rb);
            regMisleadKey = rkey;
         }
      }
   }

   out.most_consistently_correct_strategy_candidate = (!out.insufficient_dissent_evidence ? correctId : "");
   out.most_consistently_misleading_strategy_candidate = (eligible > 0 ? misleadingId : "");
   out.best_dissenting_strategy_candidate = (!out.insufficient_dissent_evidence ? bestDissentId : "");
   out.weakest_aligned_strategy_candidate = (eligible > 0 ? weakestAlignedId : "");

   out.regime_specific_correct_strategy_candidate = regCorrectKey;
   out.regime_specific_dissent_candidate = regDissentKey;
   out.regime_specific_misleading_strategy_candidate = regMisleadKey;

   out.attribution_correctness_summary =
      "council_corr|dissentSamples=" + IntegerToString(dissentSamples) +
      "|min=" + IntegerToString(out.min_dissent_samples) +
      "|insuff=" + (out.insufficient_dissent_evidence ? "true" : "false") +
      "|best=" + out.most_consistently_correct_strategy_candidate +
      "|mislead=" + out.most_consistently_misleading_strategy_candidate +
      "|bestDissent=" + out.best_dissenting_strategy_candidate;

   out.insufficient_attribution_evidence = (eligible == 0);

   out.most_reliable_strategy_candidate = (eligible > 0 ? bestId : "");
   out.most_problematic_strategy_candidate = (eligible > 0 ? worstId : "");
   out.regime_specific_best_strategy_candidate = bestRegKey;
   out.regime_specific_weak_strategy_candidate = worstRegKey;

   out.attribution_summary =
      "council_attr|linked=" + IntegerToString(out.total_linked_outcomes) +
      "|eligible=" + IntegerToString(eligible) +
      "|best=" + (StringLen(bestId) > 0 ? bestId : "NONE") +
      "|worst=" + (StringLen(worstId) > 0 ? worstId : "NONE") +
      "|strength=" + DoubleToString(out.attribution_evidence_strength, 2);

   return true;
}


int JA_FindBucketIndex(string &keys[], string key)
{
   for(int i=0; i<ArraySize(keys); i++)
      if(keys[i] == key) return i;
   return -1;
}





bool JA_FindTradeOpenDirectionByPositionId(ulong position_id, string &direction, string &decision_id)
{
   direction = "";
   decision_id = "";

   if(position_id == 0) return false;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 900, lines))
      return false;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE_OPEN")) continue;

      ulong pid = 0;
      if(!JA_ExtractJsonULong(ln, "position_id", pid))
         continue;
      if(pid != position_id)
         continue;

      decision_id = JA_ExtractJsonString(ln, "decision_id");

      if(!JA_ExtractDirectionNormalized(ln, "executed_direction", direction))
         JA_ExtractDirectionNormalized(ln, "order_type", direction);

      if(direction == "BUY" || direction == "SELL")
         return true;

      direction = "";
      return false;
   }

   return false;
}

bool JA_FindTradeOpenDirectionByPositionId(ulong position_id, string &direction)
{
   string decision_id = "";
   return JA_FindTradeOpenDirectionByPositionId(position_id, direction, decision_id);
}

bool JA_FindTradeOpenDirectionByDecisionId(string decision_id, string &direction, ulong &position_id)
{
   direction = "";
   position_id = 0;
   decision_id = JA_Trim(decision_id);
   if(StringLen(decision_id) <= 0) return false;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 900, lines))
      return false;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE_OPEN")) continue;

      string did = JA_ExtractJsonString(ln, "decision_id");
      if(did != decision_id)
         continue;

      JA_ExtractJsonULong(ln, "position_id", position_id);

      if(!JA_ExtractDirectionNormalized(ln, "executed_direction", direction))
         JA_ExtractDirectionNormalized(ln, "order_type", direction);

      if(direction == "BUY" || direction == "SELL")
         return true;

      direction = "";
      return false;
   }

   return false;
}

bool JA_FindTradeDirectionByCloseFingerprint(
   string symbol,
   datetime close_time,
   double profit,
   string trade_result,
   string &direction,
   string &decision_id,
   ulong &position_id
)
{
   direction = "";
   decision_id = "";
   position_id = 0;

   if(StringLen(JA_Trim(symbol)) <= 0 || close_time <= 0)
      return false;

   string tsNeedle = TimeToString(close_time, TIME_DATE | TIME_SECONDS);
   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 1200, lines))
      return false;

   int matches = 0;
   string matchedDirection = "";
   string matchedDecisionId = "";
   ulong matchedPositionId = 0;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string ln = JA_Trim(lines[i]);
      if(StringLen(ln) <= 0) continue;
      if(!JA_IsRecordType(ln, "TRADE")) continue;

      if(JA_ExtractJsonString(ln, "symbol") != symbol)
         continue;

      if(JA_ExtractJsonString(ln, "ts") != tsNeedle)
         continue;

      string res = "";
      JA_ExtractTradeResultNormalized(ln, res);
      if(StringLen(JA_Trim(trade_result)) > 0 && res != JA_NormalizeTradeResultText(trade_result))
         continue;

      double p = 0.0;
      if(!JA_ExtractJsonDouble(ln, "profit", p))
         continue;
      if(MathAbs(p - profit) > 0.0001)
         continue;

      string dir = "";
      if(!JA_ExtractDirectionNormalized(ln, "executed_direction", dir))
         JA_ExtractDirectionNormalized(ln, "direction", dir);
      if(dir != "BUY" && dir != "SELL")
         continue;

      string did = JA_ExtractJsonString(ln, "decision_id");
      ulong pid = 0;
      JA_ExtractJsonULong(ln, "position_id", pid);

      matches++;
      matchedDirection = dir;
      matchedDecisionId = did;
      matchedPositionId = pid;

      if(matches > 1)
         break;
   }

   if(matches != 1)
      return false;

   direction = matchedDirection;
   decision_id = matchedDecisionId;
   position_id = matchedPositionId;
   return true;
}

// Resolve TRADE_OPEN active_mode by position_id (bounded recent scan)
bool JA_FindTradeOpenActiveModeByPositionId(ulong position_id, string &active_mode)
{
   active_mode = "";
   if(position_id == 0) return false;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 800, lines))
      return false;

   for(int i=ArraySize(lines)-1; i>=0; i--)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE_OPEN")) continue;

      ulong pid = (ulong)JA_ExtractJsonUlong(ln, "position_id");
      if(pid != position_id) continue;

      active_mode = JA_ExtractJsonString(ln, "active_mode");
      return (StringLen(active_mode) > 0);
   }

   return false;
}


bool JA_FindTradeOpenMetaByPositionId(ulong position_id, string &decision_quality_label, string &entry_edge_label, string &follow_through_label, string &execution_geometry_label)
{
   decision_quality_label = "";
   entry_edge_label = "";
   follow_through_label = "";
   execution_geometry_label = "";

   if(position_id == 0) return false;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 500, lines))
      return false;

   for(int i=ArraySize(lines)-1; i>=0; i--)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE_OPEN")) continue;

      ulong pid = (ulong)JA_ExtractJsonUlong(ln, "position_id");
      if(pid != position_id) continue;

      decision_quality_label = JA_ExtractJsonString(ln, "decision_quality_label");
      entry_edge_label       = JA_ExtractJsonString(ln, "entry_edge_label");
      follow_through_label   = JA_ExtractJsonString(ln, "follow_through_quality_label");
      execution_geometry_label = JA_ExtractJsonString(ln, "execution_geometry_label");
      return true;
   }

   return false;
}


// Extended TRADE_OPEN meta lookup (v7B)
bool JA_FindTradeOpenMetaByPositionIdEx(
   ulong position_id,
   string &decision_quality_label,
   string &entry_quality_label,
   string &strategy_regime_fit_label,
   string &entry_edge_label,
   string &follow_through_label,
   string &execution_geometry_label,
   double &expected_rr_estimate,
   string &decision_quality_version
)
{
   decision_quality_label = "";
   entry_quality_label = "";
   strategy_regime_fit_label = "";
   entry_edge_label = "";
   follow_through_label = "";
   execution_geometry_label = "";
   expected_rr_estimate = 0.0;
   decision_quality_version = "";

   if(position_id == 0) return false;

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", 900, lines))
      return false;

   for(int i = ArraySize(lines) - 1; i >= 0; i--)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE_OPEN")) continue;

      ulong pid = 0;
      if(!JA_ExtractJsonULong(ln, "position_id", pid))
         continue;
      if(pid != position_id)
         continue;

      decision_quality_label     = JA_ExtractJsonString(ln, "decision_quality_label");
      entry_quality_label        = JA_ExtractJsonString(ln, "entry_quality_label");
      strategy_regime_fit_label  = JA_ExtractJsonString(ln, "strategy_regime_fit_label");
      entry_edge_label           = JA_ExtractJsonString(ln, "entry_edge_label");
      follow_through_label       = JA_ExtractJsonString(ln, "follow_through_quality_label");
      execution_geometry_label   = JA_ExtractJsonString(ln, "execution_geometry_label");

      double rr = 0.0;
      if(JA_ExtractJsonDouble(ln, "expected_rr_estimate", rr))
         expected_rr_estimate = rr;

      decision_quality_version = JA_ExtractJsonString(ln, "decision_quality_version");

      return true;
   }

   return false;
}


bool AnalyzeMultiDimensionalEdgeAnalyticsV1(int windowTrades, MultiDimEdgeAnalyticsResult &out)
{
   InitMultiDimEdgeAnalyticsResult(out);

   string lines[];
   if(!JA_ReadLastNLines("AI\\ai_performance_journal.jsonl", JA_ClampInt(windowTrades * 8, 50, 800), lines))
      return false;

   string keys[];
   int counts[];
   int wins[];
   double profits[];

   int totalTrades = 0;

   for(int i=0; i<ArraySize(lines); i++)
   {
      string ln = lines[i];
      if(!JA_IsRecordType(ln, "TRADE")) continue;

      string regime = JA_ExtractJsonString(ln, "regime_label");
      string mode   = JA_ExtractJsonString(ln, "active_mode");
      string fail   = JA_ExtractJsonString(ln, "failure_class");

      string dq     = JA_ExtractJsonString(ln, "decision_quality_label");
      string edge   = JA_ExtractJsonString(ln, "entry_edge_label");
      string ft     = JA_ExtractJsonString(ln, "follow_through_quality_label");
      string geo    = JA_ExtractJsonString(ln, "execution_geometry_label");

      ulong pid = (ulong)JA_ExtractJsonUlong(ln, "position_id");
      if((StringLen(dq) <= 0 || StringLen(edge) <= 0 || StringLen(ft) <= 0 || StringLen(geo) <= 0) && pid > 0)
      {
         string dq2, edge2, ft2, geo2;
         if(JA_FindTradeOpenMetaByPositionId(pid, dq2, edge2, ft2, geo2))
         {
            if(StringLen(dq) <= 0) dq = dq2;
            if(StringLen(edge) <= 0) edge = edge2;
            if(StringLen(ft) <= 0) ft = ft2;
            if(StringLen(geo) <= 0) geo = geo2;
         }
      }

      double profit = JA_ExtractJsonDouble(ln, "profit");
      bool isWin = (profit > 0.0);

      if(StringLen(regime) <= 0) regime = "UNKNOWN_REGIME";
      if(StringLen(mode) <= 0)   mode   = "UNKNOWN_MODE";
      if(StringLen(fail) <= 0)   fail   = "UNKNOWN_FAILURE";
      if(StringLen(dq) <= 0)     dq     = "UNKNOWN_DQ";
      if(StringLen(edge) <= 0)   edge   = "UNKNOWN_EDGE";
      if(StringLen(ft) <= 0)     ft     = "UNKNOWN_FT";
      if(StringLen(geo) <= 0)    geo    = "UNKNOWN_GEOM";

      string key =
         "reg=" + regime +
         "|mode=" + mode +
         "|fail=" + fail +
         "|dq=" + dq +
         "|edge=" + edge +
         "|ft=" + ft +
         "|geo=" + geo;

      int idx = JA_FindBucketIndex(keys, key);
      if(idx < 0)
      {
         int n = ArraySize(keys);
         ArrayResize(keys, n + 1);
         ArrayResize(counts, n + 1);
         ArrayResize(wins, n + 1);
         ArrayResize(profits, n + 1);

         keys[n] = key;
         counts[n] = 0;
         wins[n] = 0;
         profits[n] = 0.0;
         idx = n;
      }

      counts[idx] += 1;
      if(isWin) wins[idx] += 1;
      profits[idx] += profit;

      totalTrades++;
      if(totalTrades >= windowTrades) break;
   }

   out.available = (totalTrades > 0);
   out.total_trades = totalTrades;
   out.window_size_used = totalTrades;

   if(totalTrades < 10)
   {
      out.insufficient_multidim_evidence = true;
      out.edge_summary_reason = "insufficient_multidim_evidence|trades=" + IntegerToString(totalTrades);
      return true;
   }

   out.insufficient_multidim_evidence = false;

   // Pick worst/strongest by avg profit with minimum support.
   double worstAvg = DBL_MAX;
   double bestAvg  = -DBL_MAX;
   string worstKey = "";
   string bestKey  = "";

   for(int j=0; j<ArraySize(keys); j++)
   {
      if(counts[j] < 3) continue;
      double avg = profits[j] / (double)counts[j];

      if(avg < worstAvg)
      {
         worstAvg = avg;
         worstKey = keys[j] + "|n=" + IntegerToString(counts[j]) + "|avg=" + DoubleToString(avg, 2);
      }
      if(avg > bestAvg)
      {
         bestAvg = avg;
         bestKey = keys[j] + "|n=" + IntegerToString(counts[j]) + "|avg=" + DoubleToString(avg, 2);
      }
   }

   out.worst_dimension_bucket = worstKey;
   out.strongest_dimension_bucket = bestKey;

   out.edge_deterioration_detected = (StringLen(worstKey) > 0 && worstAvg < 0.0);
   out.edge_summary_reason =
      "multidim|trades=" + IntegerToString(totalTrades) +
      "|worst=" + worstKey +
      "|best=" + bestKey;

   return true;
}

#endif