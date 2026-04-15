

#ifndef __COUNCIL_FEEDBACK_MEMORY_MQH__
#define __COUNCIL_FEEDBACK_MEMORY_MQH__

#include "council_mode_types.mqh"
#include "config_loader.mqh"

//---------------------------------------------------------
// Small helpers
//---------------------------------------------------------
string CouncilMemEscapeJson(string s)
{
   string out = s;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\r", "");
   StringReplace(out, "\n", " ");
   return out;
}

string CouncilMemBoolToText(bool v)
{
   return (v ? "true" : "false");
}

string CouncilMemDecisionText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)    return "BUY";
   if(d == COUNCIL_DECISION_SELL)   return "SELL";
   if(d == COUNCIL_DECISION_REJECT) return "REJECT";
   return "WAIT";
}

bool CouncilMemSaveTextFile(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

bool CouncilMemLoadTextFile(string relativePath, string &outText)
{
   outText = "";

   int h = FileOpen(relativePath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
      outText += FileReadString(h);

   FileClose(h);
   return true;
}

string CouncilMemNowText()
{
   return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

//---------------------------------------------------------
// Init helpers
//---------------------------------------------------------
void InitCouncilFeedbackRecord(CouncilFeedbackRecord &r)
{
   r.valid                      = false;
   r.symbol                     = "";
   r.time_text                  = "";

   r.environment_summary        = "";
   r.council_decision           = COUNCIL_DECISION_WAIT;
   r.council_score              = 0.0;
   r.council_conflict_score     = 0.0;
   r.pre_ai_gate_passed         = false;
   r.pre_ai_gate_score          = 0.0;

   r.governor_intervened        = false;
   r.governor_allowed_execution = false;
   r.governor_direction         = COUNCIL_DECISION_WAIT;
   r.governor_confidence        = 0.0;
   r.governor_reason            = "";

   r.strategy_1_name            = "";
   r.strategy_1_score           = 0.0;
   r.strategy_1_direction       = COUNCIL_DECISION_WAIT;

   r.strategy_2_name            = "";
   r.strategy_2_score           = 0.0;
   r.strategy_2_direction       = COUNCIL_DECISION_WAIT;

   r.strategy_3_name            = "";
   r.strategy_3_score           = 0.0;
   r.strategy_3_direction       = COUNCIL_DECISION_WAIT;

   r.strategy_4_name            = "";
   r.strategy_4_score           = 0.0;
   r.strategy_4_direction       = COUNCIL_DECISION_WAIT;

   r.executed                   = false;
   r.executed_direction         = COUNCIL_DECISION_WAIT;
   r.execution_risk_scale       = 1.0;

   r.trade_result               = "PENDING";
   r.trade_profit               = 0.0;
   r.close_time_text            = "";
}

void InitCouncilFeedbackMemoryState(CouncilFeedbackMemoryState &st)
{
   st.last_record_id            = 0;
   st.total_records             = 0;
   st.total_executed            = 0;
   st.total_wins                = 0;
   st.total_losses              = 0;
   st.total_flats               = 0;

   st.last_result               = "NONE";
   st.last_profit               = 0.0;
   st.last_close_time_text      = "";

   st.consecutive_wins          = 0;
   st.consecutive_losses        = 0;

   st.recent_win_rate           = 0.0;
   st.recent_avg_profit         = 0.0;
}

//---------------------------------------------------------
// JSON conversion
//---------------------------------------------------------
string CouncilFeedbackRecordToJson(CouncilFeedbackRecord &r, int recordId)
{
   string json = "{";

   json += "\"record_id\":" + IntegerToString(recordId) + ",";
   json += "\"valid\":" + CouncilMemBoolToText(r.valid) + ",";
   json += "\"symbol\":\"" + CouncilMemEscapeJson(r.symbol) + "\",";
   json += "\"time_text\":\"" + CouncilMemEscapeJson(r.time_text) + "\",";

   json += "\"environment_summary\":\"" + CouncilMemEscapeJson(r.environment_summary) + "\",";
   json += "\"council_decision\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.council_decision)) + "\",";
   json += "\"council_score\":" + DoubleToString(r.council_score, 4) + ",";
   json += "\"council_conflict_score\":" + DoubleToString(r.council_conflict_score, 4) + ",";
   json += "\"pre_ai_gate_passed\":" + CouncilMemBoolToText(r.pre_ai_gate_passed) + ",";
   json += "\"pre_ai_gate_score\":" + DoubleToString(r.pre_ai_gate_score, 4) + ",";

   json += "\"governor_intervened\":" + CouncilMemBoolToText(r.governor_intervened) + ",";
   json += "\"governor_allowed_execution\":" + CouncilMemBoolToText(r.governor_allowed_execution) + ",";
   json += "\"governor_direction\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.governor_direction)) + "\",";
   json += "\"governor_confidence\":" + DoubleToString(r.governor_confidence, 4) + ",";
   json += "\"governor_reason\":\"" + CouncilMemEscapeJson(r.governor_reason) + "\",";

   json += "\"strategy_1_name\":\"" + CouncilMemEscapeJson(r.strategy_1_name) + "\",";
   json += "\"strategy_1_score\":" + DoubleToString(r.strategy_1_score, 4) + ",";
   json += "\"strategy_1_direction\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.strategy_1_direction)) + "\",";

   json += "\"strategy_2_name\":\"" + CouncilMemEscapeJson(r.strategy_2_name) + "\",";
   json += "\"strategy_2_score\":" + DoubleToString(r.strategy_2_score, 4) + ",";
   json += "\"strategy_2_direction\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.strategy_2_direction)) + "\",";

   json += "\"strategy_3_name\":\"" + CouncilMemEscapeJson(r.strategy_3_name) + "\",";
   json += "\"strategy_3_score\":" + DoubleToString(r.strategy_3_score, 4) + ",";
   json += "\"strategy_3_direction\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.strategy_3_direction)) + "\",";

   json += "\"strategy_4_name\":\"" + CouncilMemEscapeJson(r.strategy_4_name) + "\",";
   json += "\"strategy_4_score\":" + DoubleToString(r.strategy_4_score, 4) + ",";
   json += "\"strategy_4_direction\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.strategy_4_direction)) + "\",";

   json += "\"executed\":" + CouncilMemBoolToText(r.executed) + ",";
   json += "\"executed_direction\":\"" + CouncilMemEscapeJson(CouncilMemDecisionText(r.executed_direction)) + "\",";
   json += "\"execution_risk_scale\":" + DoubleToString(r.execution_risk_scale, 4) + ",";

   json += "\"trade_result\":\"" + CouncilMemEscapeJson(r.trade_result) + "\",";
   json += "\"trade_profit\":" + DoubleToString(r.trade_profit, 2) + ",";
   json += "\"close_time_text\":\"" + CouncilMemEscapeJson(r.close_time_text) + "\"";

   json += "}";
   return json;
}

//---------------------------------------------------------
// Build record from live council outputs
//---------------------------------------------------------
bool BuildCouncilFeedbackRecord(
   string symbol,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateResult &gate,
   CouncilGovernorAction &gov,
   bool executed,
   CouncilDecision executedDirection,
   double executionRiskScale,
   CouncilFeedbackRecord &outRecord
)
{
   InitCouncilFeedbackRecord(outRecord);

   if(!env.valid || !agg.valid || !gate.valid)
      return false;

   outRecord.valid                  = true;
   outRecord.symbol                 = symbol;
   outRecord.time_text              = CouncilMemNowText();

   outRecord.environment_summary    = env.summary;
   outRecord.council_decision       = agg.final_decision;
   outRecord.council_score          = agg.council_quality;
   outRecord.council_conflict_score = agg.conflict_score;
   outRecord.pre_ai_gate_passed     = gate.passed;
   outRecord.pre_ai_gate_score      = gate.pass_score;

   outRecord.governor_intervened        = gov.valid;
   outRecord.governor_allowed_execution = gov.allow_execution;
   outRecord.governor_direction         = gov.override_direction;
   outRecord.governor_confidence        = gov.direction_confidence;
   outRecord.governor_reason            = gov.reason;

   if(agg.strategy_count > 0)
   {
      outRecord.strategy_1_name      = agg.strategy_names[0];
      outRecord.strategy_1_score     = agg.strategy_scores[0];
      outRecord.strategy_1_direction = agg.strategy_directions[0];
   }

   if(agg.strategy_count > 1)
   {
      outRecord.strategy_2_name      = agg.strategy_names[1];
      outRecord.strategy_2_score     = agg.strategy_scores[1];
      outRecord.strategy_2_direction = agg.strategy_directions[1];
   }

   if(agg.strategy_count > 2)
   {
      outRecord.strategy_3_name      = agg.strategy_names[2];
      outRecord.strategy_3_score     = agg.strategy_scores[2];
      outRecord.strategy_3_direction = agg.strategy_directions[2];
   }

   if(agg.strategy_count > 3)
   {
      outRecord.strategy_4_name      = agg.strategy_names[3];
      outRecord.strategy_4_score     = agg.strategy_scores[3];
      outRecord.strategy_4_direction = agg.strategy_directions[3];
   }

   outRecord.executed            = executed;
   outRecord.executed_direction  = executedDirection;
   outRecord.execution_risk_scale = executionRiskScale;

   outRecord.trade_result        = "PENDING";
   outRecord.trade_profit        = 0.0;
   outRecord.close_time_text     = "";

   return true;
}

//---------------------------------------------------------
// Memory file append
//---------------------------------------------------------
bool AppendCouncilFeedbackRecord(string relativePath, CouncilFeedbackRecord &r, int recordId)
{
   string oldText = "";
   bool exists = CouncilMemLoadTextFile(relativePath, oldText);

   string one = CouncilFeedbackRecordToJson(r, recordId);
   string newText = "";

   if(!exists)
   {
      newText = "[\n" + one + "\n]";
      return CouncilMemSaveTextFile(relativePath, newText);
   }

   oldText = TrimString(oldText);

   if(StringLen(oldText) < 2 || oldText == "[]")
   {
      newText = "[\n" + one + "\n]";
      return CouncilMemSaveTextFile(relativePath, newText);
   }

   int endBracket = -1;
   for(int i = StringLen(oldText) - 1; i >= 0; i--)
   {
      if(StringSubstr(oldText, i, 1) == "]")
      {
         endBracket = i;
         break;
      }
   }

   if(endBracket < 0)
      newText = "[\n" + one + "\n]";
   else
   {
      string prefix = StringSubstr(oldText, 0, endBracket);
      if(StringFind(prefix, "{") >= 0)
         newText = prefix + ",\n" + one + "\n]";
      else
         newText = "[\n" + one + "\n]";
   }

   return CouncilMemSaveTextFile(relativePath, newText);
}

//---------------------------------------------------------
// State persistence
//---------------------------------------------------------
bool SaveCouncilFeedbackMemoryState(string relativePath, CouncilFeedbackMemoryState &st)
{
   string json = "{";
   json += "\"last_record_id\":" + IntegerToString(st.last_record_id) + ",";
   json += "\"total_records\":" + IntegerToString(st.total_records) + ",";
   json += "\"total_executed\":" + IntegerToString(st.total_executed) + ",";
   json += "\"total_wins\":" + IntegerToString(st.total_wins) + ",";
   json += "\"total_losses\":" + IntegerToString(st.total_losses) + ",";
   json += "\"total_flats\":" + IntegerToString(st.total_flats) + ",";
   json += "\"last_result\":\"" + CouncilMemEscapeJson(st.last_result) + "\",";
   json += "\"last_profit\":" + DoubleToString(st.last_profit, 2) + ",";
   json += "\"last_close_time_text\":\"" + CouncilMemEscapeJson(st.last_close_time_text) + "\",";
   json += "\"consecutive_wins\":" + IntegerToString(st.consecutive_wins) + ",";
   json += "\"consecutive_losses\":" + IntegerToString(st.consecutive_losses) + ",";
   json += "\"recent_win_rate\":" + DoubleToString(st.recent_win_rate, 4) + ",";
   json += "\"recent_avg_profit\":" + DoubleToString(st.recent_avg_profit, 4);
   json += "}";

   return CouncilMemSaveTextFile(relativePath, json);
}

bool LoadCouncilFeedbackMemoryState(string relativePath, CouncilFeedbackMemoryState &st)
{
   InitCouncilFeedbackMemoryState(st);

   string json = "";
   if(!CouncilMemLoadTextFile(relativePath, json))
      return false;

   string s = "";
   int i = 0;
   double d = 0.0;

   if(ExtractJsonIntField(json, "last_record_id", i))
      st.last_record_id = i;

   if(ExtractJsonIntField(json, "total_records", i))
      st.total_records = i;

   if(ExtractJsonIntField(json, "total_executed", i))
      st.total_executed = i;

   if(ExtractJsonIntField(json, "total_wins", i))
      st.total_wins = i;

   if(ExtractJsonIntField(json, "total_losses", i))
      st.total_losses = i;

   if(ExtractJsonIntField(json, "total_flats", i))
      st.total_flats = i;

   if(ExtractJsonStringField(json, "last_result", s))
      st.last_result = s;

   if(ExtractJsonDoubleField(json, "last_profit", d))
      st.last_profit = d;

   if(ExtractJsonStringField(json, "last_close_time_text", s))
      st.last_close_time_text = s;

   if(ExtractJsonIntField(json, "consecutive_wins", i))
      st.consecutive_wins = i;

   if(ExtractJsonIntField(json, "consecutive_losses", i))
      st.consecutive_losses = i;

   if(ExtractJsonDoubleField(json, "recent_win_rate", d))
      st.recent_win_rate = d;

   if(ExtractJsonDoubleField(json, "recent_avg_profit", d))
      st.recent_avg_profit = d;

   return true;
}

//---------------------------------------------------------
// Record creation entry point
//---------------------------------------------------------
bool SaveCouncilFeedbackSnapshot(
   string recordsPath,
   string statePath,
   string symbol,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateResult &gate,
   CouncilGovernorAction &gov,
   bool executed,
   CouncilDecision executedDirection,
   double executionRiskScale,
   string &logMessage
)
{
   logMessage = "";

   CouncilFeedbackMemoryState st;
   LoadCouncilFeedbackMemoryState(statePath, st);

   CouncilFeedbackRecord rec;
   if(!BuildCouncilFeedbackRecord(
         symbol,
         env,
         agg,
         gate,
         gov,
         executed,
         executedDirection,
         executionRiskScale,
         rec))
   {
      logMessage = "Council feedback snapshot skipped: invalid inputs";
      return false;
   }

   int nextId = st.last_record_id + 1;

   if(!AppendCouncilFeedbackRecord(recordsPath, rec, nextId))
   {
      logMessage = "Council feedback snapshot failed to append";
      return false;
   }

   st.last_record_id = nextId;
   st.total_records++;

   if(executed)
      st.total_executed++;

   SaveCouncilFeedbackMemoryState(statePath, st);

   logMessage =
      "Council feedback snapshot saved"
      " | id=" + IntegerToString(nextId) +
      " | decision=" + CouncilMemDecisionText(rec.council_decision) +
      " | gate=" + string(rec.pre_ai_gate_passed ? "PASS" : "BLOCK") +
      " | executed=" + string(executed ? "true" : "false");

   return true;
}

//---------------------------------------------------------
// Outcome update
//---------------------------------------------------------
string CouncilProfitToResult(double profit)
{
   if(profit > 0.0) return "WIN";
   if(profit < 0.0) return "LOSS";
   return "FLAT";
}

bool UpdateCouncilFeedbackMemoryAfterTradeResult(
   string statePath,
   double tradeProfit,
   string closeTimeText,
   string &logMessage
)
{
   logMessage = "";

   CouncilFeedbackMemoryState st;
   LoadCouncilFeedbackMemoryState(statePath, st);

   string result = CouncilProfitToResult(tradeProfit);

   st.last_result          = result;
   st.last_profit          = tradeProfit;
   st.last_close_time_text = closeTimeText;

   if(result == "WIN")
   {
      st.total_wins++;
      st.consecutive_wins++;
      st.consecutive_losses = 0;
   }
   else if(result == "LOSS")
   {
      st.total_losses++;
      st.consecutive_losses++;
      st.consecutive_wins = 0;
   }
   else
   {
      st.total_flats++;
      st.consecutive_wins = 0;
      st.consecutive_losses = 0;
   }

   int decisive = st.total_wins + st.total_losses;
   if(decisive > 0)
      st.recent_win_rate = (double)st.total_wins / (double)decisive;
   else
      st.recent_win_rate = 0.0;

   int totalClosed = st.total_wins + st.total_losses + st.total_flats;
   if(totalClosed > 0)
      st.recent_avg_profit =
         ((st.recent_avg_profit * (totalClosed - 1)) + tradeProfit) / (double)totalClosed;
   else
      st.recent_avg_profit = tradeProfit;

   if(!SaveCouncilFeedbackMemoryState(statePath, st))
   {
      logMessage = "Council feedback memory state failed to save after trade result";
      return false;
   }

   logMessage =
      "Council feedback memory updated"
      " | result=" + result +
      " | profit=" + DoubleToString(tradeProfit, 2) +
      " | win_rate=" + DoubleToString(st.recent_win_rate * 100.0, 1) + "%" +
      " | consec_wins=" + IntegerToString(st.consecutive_wins) +
      " | consec_losses=" + IntegerToString(st.consecutive_losses);

   return true;
}

#endif
