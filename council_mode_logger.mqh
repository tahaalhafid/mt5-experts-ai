


#ifndef __COUNCIL_MODE_LOGGER_MQH__
#define __COUNCIL_MODE_LOGGER_MQH__

#include "council_mode_types.mqh"
#include "config_loader.mqh"

//---------------------------------------------------------
// Small helpers
//---------------------------------------------------------
string CouncilLogDecisionText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)    return "BUY";
   if(d == COUNCIL_DECISION_SELL)   return "SELL";
   if(d == COUNCIL_DECISION_REJECT) return "REJECT";
   return "WAIT";
}

string CouncilLogBoolText(bool v)
{
   return (v ? "true" : "false");
}

string CouncilLogNowText()
{
   return TimeToString(TimeCurrent(), TIME_DATE | TIME_SECONDS);
}

bool CouncilLogSaveText(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

bool CouncilLogAppendText(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI);

   if(h == INVALID_HANDLE)
   {
      h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
      if(h == INVALID_HANDLE)
         return false;

      FileWriteString(h, text);
      FileClose(h);
      return true;
   }

   FileSeek(h, 0, SEEK_END);
   FileWriteString(h, text);
   FileClose(h);
   return true;
}

string CouncilLogLine(string title, string value)
{
   return title + ": " + value + "\n";
}

string CouncilLogDouble(string title, double v, int digits = 4)
{
   return title + ": " + DoubleToString(v, digits) + "\n";
}

string CouncilLogInt(string title, int v)
{
   return title + ": " + IntegerToString(v) + "\n";
}

//---------------------------------------------------------
// Strategy report block
//---------------------------------------------------------
string CouncilBuildSingleStrategyLogBlock(
   int index,
   string name,
   CouncilDecision direction,
   double score,
   double confidence,
   bool passedEnvironment,
   bool active,
   string reason
)
{
   string s = "";
   s += "----------------------------------------\n";
   s += "STRATEGY #" + IntegerToString(index) + "\n";
   s += CouncilLogLine("name", name);
   s += CouncilLogLine("direction", CouncilLogDecisionText(direction));
   s += CouncilLogDouble("score", score, 4);
   s += CouncilLogDouble("confidence", confidence, 4);
   s += CouncilLogLine("passed_environment", CouncilLogBoolText(passedEnvironment));
   s += CouncilLogLine("active", CouncilLogBoolText(active));
   s += CouncilLogLine("reason", reason);
   return s;
}

//---------------------------------------------------------
// Environment block
//---------------------------------------------------------
string CouncilBuildEnvironmentLogBlock(CouncilEnvironmentReport &env)
{
   string s = "";
   s += "========================================\n";
   s += "COUNCIL MODE | ENVIRONMENT REPORT\n";
   s += "========================================\n";
   s += CouncilLogLine("valid", CouncilLogBoolText(env.valid));
   s += CouncilLogLine("summary", env.summary);

   s += CouncilLogLine("liquidity_state", env.liquidity_state);
   s += CouncilLogLine("spread_state", env.spread_state);
   s += CouncilLogLine("volatility_state", env.volatility_state);
   s += CouncilLogLine("structure_state", env.structure_state);
   s += CouncilLogLine("session_state", env.session_state);

   s += CouncilLogDouble("liquidity_score", env.liquidity_score, 4);
   s += CouncilLogDouble("spread_score", env.spread_score, 4);
   s += CouncilLogDouble("volatility_score", env.volatility_score, 4);
   s += CouncilLogDouble("structure_score", env.structure_score, 4);
   s += CouncilLogDouble("session_score", env.session_score, 4);

   s += CouncilLogLine("scalp_friendly", CouncilLogBoolText(env.scalp_friendly));
   s += CouncilLogDouble("environment_score", env.environment_score, 4);

   return s;
}

//---------------------------------------------------------
// Aggregate block
//---------------------------------------------------------
string CouncilBuildAggregateLogBlock(CouncilAggregateReport &agg)
{
   string s = "";
   s += "========================================\n";
   s += "COUNCIL MODE | AGGREGATE REPORT\n";
   s += "========================================\n";
   s += CouncilLogLine("valid", CouncilLogBoolText(agg.valid));
   s += CouncilLogInt("strategy_count", agg.strategy_count);
   s += CouncilLogLine("final_decision", CouncilLogDecisionText(agg.final_decision));
   s += CouncilLogDouble("buy_score", agg.buy_score, 4);
   s += CouncilLogDouble("sell_score", agg.sell_score, 4);
   s += CouncilLogDouble("council_quality", agg.council_quality, 4);
   s += CouncilLogDouble("conflict_score", agg.conflict_score, 4);
   s += CouncilLogLine("summary", agg.summary);
   s += "\n";

   for(int i = 0; i < agg.strategy_count && i < 4; i++)
   {
      s += CouncilBuildSingleStrategyLogBlock(
         i + 1,
         agg.strategy_names[i],
         agg.strategy_directions[i],
         agg.strategy_scores[i],
         agg.strategy_confidences[i],
         agg.strategy_passed_environment[i],
         agg.strategy_active_flags[i],
         agg.strategy_reasons[i]
      );
   }

   return s;
}

//---------------------------------------------------------
// Pre-AI gate block
//---------------------------------------------------------
string CouncilBuildPreAIGateLogBlock(CouncilPreAIGateResult &gate)
{
   string s = "";
   s += "========================================\n";
   s += "COUNCIL MODE | PRE-AI FILTER\n";
   s += "========================================\n";
   s += CouncilLogLine("valid", CouncilLogBoolText(gate.valid));
   s += CouncilLogLine("passed", CouncilLogBoolText(gate.passed));
   s += CouncilLogLine("decision_after_filter", CouncilLogDecisionText(gate.filtered_decision));
   s += CouncilLogDouble("pass_score", gate.pass_score, 4);
   s += CouncilLogDouble("minimum_required_score", gate.minimum_required_score, 4);
   s += CouncilLogDouble("conflict_score", gate.conflict_score, 4);
   s += CouncilLogLine("reason", gate.reason);
   return s;
}

//---------------------------------------------------------
// Governor block
//---------------------------------------------------------
string CouncilBuildGovernorLogBlock(CouncilGovernorAction &gov)
{
   string s = "";
   s += "========================================\n";
   s += "COUNCIL MODE | AI GOVERNOR ACTION\n";
   s += "========================================\n";
   s += CouncilLogLine("valid", CouncilLogBoolText(gov.valid));
   s += CouncilLogLine("allow_execution", CouncilLogBoolText(gov.allow_execution));
   s += CouncilLogLine("override_direction", CouncilLogDecisionText(gov.override_direction));
   s += CouncilLogDouble("direction_confidence", gov.direction_confidence, 4);
   s += CouncilLogDouble("risk_scale", gov.risk_scale, 4);
   s += CouncilLogLine("change_scope", gov.change_scope);
   s += CouncilLogLine("reason", gov.reason);
   s += CouncilLogLine("notes", gov.notes);
   return s;
}

//---------------------------------------------------------
// Final execution block
//---------------------------------------------------------
string CouncilBuildExecutionLogBlock(
   bool executed,
   CouncilDecision executedDirection,
   double riskScale,
   string reason
)
{
   string s = "";
   s += "========================================\n";
   s += "COUNCIL MODE | FINAL EXECUTION\n";
   s += "========================================\n";
   s += CouncilLogLine("executed", CouncilLogBoolText(executed));
   s += CouncilLogLine("executed_direction", CouncilLogDecisionText(executedDirection));
   s += CouncilLogDouble("risk_scale", riskScale, 4);
   s += CouncilLogLine("reason", reason);
   return s;
}

//---------------------------------------------------------
// Full cycle report
//---------------------------------------------------------
string BuildCouncilCycleLogText(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateResult &gate,
   CouncilGovernorAction &gov,
   bool executed,
   CouncilDecision executedDirection,
   double riskScale,
   string executionReason
)
{
   string s = "";
   s += "\n";
   s += "########################################################\n";
   s += "COUNCIL MODE CYCLE REPORT\n";
   s += "time: " + CouncilLogNowText() + "\n";
   s += "symbol: " + _Symbol + "\n";
   s += "########################################################\n\n";

   s += CouncilBuildEnvironmentLogBlock(env);
   s += "\n";
   s += CouncilBuildAggregateLogBlock(agg);
   s += "\n";
   s += CouncilBuildPreAIGateLogBlock(gate);
   s += "\n";
   s += CouncilBuildGovernorLogBlock(gov);
   s += "\n";
   s += CouncilBuildExecutionLogBlock(
      executed,
      executedDirection,
      riskScale,
      executionReason
   );
   s += "\n";
   s += "END OF COUNCIL CYCLE REPORT\n";
   s += "########################################################\n";

   return s;
}

//---------------------------------------------------------
// Save single latest report
//---------------------------------------------------------
bool SaveCouncilLatestCycleLog(
   string relativePath,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateResult &gate,
   CouncilGovernorAction &gov,
   bool executed,
   CouncilDecision executedDirection,
   double riskScale,
   string executionReason,
   string &logMessage
)
{
   logMessage = "";

   string text = BuildCouncilCycleLogText(
      env,
      agg,
      gate,
      gov,
      executed,
      executedDirection,
      riskScale,
      executionReason
   );

   if(!CouncilLogSaveText(relativePath, text))
   {
      logMessage = "Council latest cycle log failed to save";
      return false;
   }

   logMessage = "Council latest cycle log saved";
   return true;
}

//---------------------------------------------------------
// Append to rolling journal
//---------------------------------------------------------
bool AppendCouncilJournalLog(
   string relativePath,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateResult &gate,
   CouncilGovernorAction &gov,
   bool executed,
   CouncilDecision executedDirection,
   double riskScale,
   string executionReason,
   string &logMessage
)
{
   logMessage = "";

   string text = BuildCouncilCycleLogText(
      env,
      agg,
      gate,
      gov,
      executed,
      executedDirection,
      riskScale,
      executionReason
   );

   text += "\n\n";

   if(!CouncilLogAppendText(relativePath, text))
   {
      logMessage = "Council journal log failed to append";
      return false;
   }

   logMessage = "Council journal log appended";
   return true;
}

#endif
