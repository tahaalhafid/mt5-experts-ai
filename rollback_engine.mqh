#ifndef __ROLLBACK_ENGINE_MQH__
#define __ROLLBACK_ENGINE_MQH__

#include "config_loader.mqh"
#include "performance_memory.mqh"
#include "plan_auto_apply.mqh"

struct RollbackState
{
   bool   monitoring_active;
   string candidate_plan_id;
   int    baseline_closed_trades;
   int    min_trades_before_judgment;
   double min_win_rate;
   int    max_consecutive_losses;
   double min_avg_profit_per_trade;
};

// Rollback ownership + arming contract:
// - Threshold authority (when armed) is ai_rollback_state.json.
// - Bridge is attached at AutoApplyPlanProposal(...) lifecycle location.
// - Current runtime flow remains intentionally unarmed until that lifecycle is reachable.
string RollbackStatePath() { return "AI\\ai_rollback_state.json"; }
string RollbackThresholdOwnerWhenArmedPath() { return "AI\\ai_rollback_state.json"; }
string RollbackThresholdOwnerWhenArmedFieldsCsv() { return "min_trades_before_judgment,min_win_rate,max_consecutive_losses,min_avg_profit_per_trade"; }
bool   RollbackLiveArmingCallerPresent() { return false; }
bool   RollbackAutoArmingPresent() { return false; }
bool   RollbackArmingBridgeImplemented() { return true; }
string RollbackArmingBridgeLocation() { return "AutoApplyPlanProposal@MQL5/Experts/AI/plan_auto_apply.mqh"; }
bool   RollbackArmingBridgeReachableInCurrentRuntimeFlow() { return false; }
string RollbackCurrentRuntimeArmingPathState() { return "NO_REACHABLE_CALLER_IN_CURRENT_MAIN_RUNTIME_FLOW_INTENTIONAL"; }
string RollbackArmingContractState() { return "BRIDGE_PRESENT_RUNTIME_UNREACHABLE_INTENTIONAL"; }

bool SaveRollbackState(string relativePath, RollbackState &st)
{
   string json = "{";
   json += "\"monitoring_active\":" + string(st.monitoring_active ? "true" : "false") + ",";
   json += "\"candidate_plan_id\":\"" + st.candidate_plan_id + "\",";
   json += "\"baseline_closed_trades\":" + IntegerToString(st.baseline_closed_trades) + ",";
   json += "\"min_trades_before_judgment\":" + IntegerToString(st.min_trades_before_judgment) + ",";
   json += "\"min_win_rate\":" + DoubleToString(st.min_win_rate, 2) + ",";
   json += "\"max_consecutive_losses\":" + IntegerToString(st.max_consecutive_losses) + ",";
   json += "\"min_avg_profit_per_trade\":" + DoubleToString(st.min_avg_profit_per_trade, 2);
   json += "}";

   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, json);
   FileClose(h);
   return true;
}

bool LoadRollbackState(string relativePath, RollbackState &st)
{
   st.monitoring_active = false;
   st.candidate_plan_id = "";
   st.baseline_closed_trades = 0;
   st.min_trades_before_judgment = 6;
   st.min_win_rate = 35.0;
   st.max_consecutive_losses = 3;
   st.min_avg_profit_per_trade = -1.0;

   string json = "";
   if(!LoadTextFile(relativePath, json))
      return false;

   string s = "";
   bool b = false;
   int i = 0;
   double d = 0.0;

   if(ExtractJsonBoolField(json, "monitoring_active", b))
      st.monitoring_active = b;

   if(ExtractJsonStringField(json, "candidate_plan_id", s))
      st.candidate_plan_id = s;

   if(ExtractJsonIntField(json, "baseline_closed_trades", i))
      st.baseline_closed_trades = i;

   if(ExtractJsonIntField(json, "min_trades_before_judgment", i))
      st.min_trades_before_judgment = i;

   if(ExtractJsonDoubleField(json, "min_win_rate", d))
      st.min_win_rate = d;

   if(ExtractJsonIntField(json, "max_consecutive_losses", i))
      st.max_consecutive_losses = i;

   if(ExtractJsonDoubleField(json, "min_avg_profit_per_trade", d))
      st.min_avg_profit_per_trade = d;

   return true;
}

bool StartRollbackMonitoring(
   string relativePath,
   string candidatePlanId,
   int baselineClosedTrades,
   int minTradesBeforeJudgment,
   double minWinRate,
   int maxConsecutiveLosses,
   double minAvgProfitPerTrade,
   string &logMessage
)
{
   RollbackState st;
   st.monitoring_active = true;
   st.candidate_plan_id = candidatePlanId;
   st.baseline_closed_trades = baselineClosedTrades;
   st.min_trades_before_judgment = minTradesBeforeJudgment;
   st.min_win_rate = minWinRate;
   st.max_consecutive_losses = maxConsecutiveLosses;
   st.min_avg_profit_per_trade = minAvgProfitPerTrade;

   if(!SaveRollbackState(relativePath, st))
   {
      logMessage = "Failed to save rollback monitoring state";
      return false;
   }

   logMessage = "Rollback monitoring started for plan: " + candidatePlanId;
   return true;
}

bool StopRollbackMonitoring(string relativePath, string &logMessage)
{
   RollbackState st;
   st.monitoring_active = false;
   st.candidate_plan_id = "";
   st.baseline_closed_trades = 0;
   st.min_trades_before_judgment = 6;
   st.min_win_rate = 35.0;
   st.max_consecutive_losses = 3;
   st.min_avg_profit_per_trade = -1.0;

   if(!SaveRollbackState(relativePath, st))
   {
      logMessage = "Failed to clear rollback monitoring state";
      return false;
   }

   logMessage = "Rollback monitoring stopped";
   return true;
}

bool ShouldRollbackNow(RollbackState &st, PerformanceSnapshot &perf, bool &decision, string &reason)
{
   decision = false;
   reason = "";

   if(!st.monitoring_active)
   {
      reason = "Rollback monitoring not active";
      return true;
   }

   int newTrades = perf.closed_trades - st.baseline_closed_trades;
   if(newTrades < st.min_trades_before_judgment)
   {
      reason = "Not enough trades yet for rollback judgment";
      return true;
   }

   bool badWinRate    = (perf.win_rate < st.min_win_rate);
   bool badLossStreak = (perf.consecutive_losses >= st.max_consecutive_losses);
   bool badAvgProfit  = (perf.avg_profit_per_trade < st.min_avg_profit_per_trade);

   if(badWinRate || badLossStreak || badAvgProfit)
   {
      decision = true;

      if(badLossStreak)
         reason = "Rollback triggered by consecutive losses";
      else if(badWinRate)
         reason = "Rollback triggered by low win rate";
      else
         reason = "Rollback triggered by poor average trade";

      return true;
   }

   reason = "Candidate plan passed rollback monitoring";
   return true;
}

bool ApplyRollbackFromBackup(
   string currentPlanPath,
   string backupPlanPath,
   string &logMessage
)
{
   if(!CopyFileText(backupPlanPath, currentPlanPath))
   {
      logMessage = "Failed to restore backup plan";
      return false;
   }

   logMessage = "Rollback applied from previous backup plan";
   return true;
}

#endif
