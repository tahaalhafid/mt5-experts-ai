#ifndef __COUNCIL_MEMORY_MQH__
#define __COUNCIL_MEMORY_MQH__

#include "council_mode_types.mqh"
#include "config_loader.mqh"
#include "journal_analytics.mqh"

//---------------------------------------------------------
// Memory summary structs
//---------------------------------------------------------
struct CouncilStrategyMemoryStats
{
   string strategy_name;

   int total_signals;
   int executed_trades;

   int wins;
   int losses;
   int flats;

   int buy_signals;
   int sell_signals;

   int buy_wins;
   int buy_losses;
   int sell_wins;
   int sell_losses;

   double total_profit;
   double avg_profit;
   double win_rate;
};

struct CouncilMemorySummary
{
   int total_records;
   int executed_records;


   int decision_snapshot_records;
   int trade_close_outcome_records;
   int correlated_close_outcome_records;
   int attributed_executed_records;
   int unattributed_executed_records;

   int wins;
   int losses;
   int flats;

   double total_profit;
   double avg_profit;
   double overall_win_rate;

   // New memory intelligence aggregates
   int high_quality_records;
   int medium_quality_records;
   int low_quality_records;

   int confirm_supported_records;
   int trend_judge_supported_records;
   int exhaustion_warning_records;

   int continuation_setups;
   int reversal_setups;
   int mean_reclaim_setups;
   int breakout_setups;
   int defensive_setups;
   int unspecified_setups;

   int late_continuation_failures;
   int weak_reversal_failures;
   int zone_mismatch_failures;
   int high_conflict_failures;
   int low_quality_failures;
   int no_confirm_role_failures;
   int exhaustion_ignored_failures;
   int unclassified_failures;

   CouncilStrategyMemoryStats strategy_1;
   CouncilStrategyMemoryStats strategy_2;
   CouncilStrategyMemoryStats strategy_3;
   CouncilStrategyMemoryStats strategy_4;

   string best_overall_strategy;
   string best_buy_strategy;
   string best_sell_strategy;

   string best_strategy_id;
   string support_strategy_ids;

   string top_failure_tag;
   string top_setup_type;

   string summary_text;
   string summary_json;
};


//---------------------------------------------------------
// Council audit summary (Phase 5)
//---------------------------------------------------------
struct CouncilAuditSummary
{
   // Raw record counters (feedback)
   int feedback_total_records;
   int feedback_decision_snapshot_records;
   int feedback_trade_close_outcome_records;

   // Close linkage quality (feedback)
   int close_with_decision_id;
   int close_with_correlated_decision_id;
   int close_with_position_id;
   int close_with_resolved_direction;
   int close_with_strategy_attribution;

   // Performance journal population
   int journal_decision_records;
   int journal_trade_open_records;
   int journal_trade_open_with_decision_id;
   int journal_trade_open_with_position_id;
   int journal_trade_open_with_dominant_strategy_id;
   int journal_trade_records;
   int journal_trade_records_with_decision_id;
   int journal_trade_records_with_position_id;

   // Derived rates
   double close_decision_link_rate;
   double close_position_link_rate;
   double close_direction_resolution_rate;
   double close_strategy_attribution_rate;
   double trade_open_decision_link_rate;
   double trade_open_position_link_rate;
   double trade_open_strategy_attribution_rate;
   double trade_close_decision_link_rate;
   double trade_close_position_link_rate;

   // Readiness / status
   string audit_status;
   string weakest_link;
   string summary_text;
   string summary_json;
};

//---------------------------------------------------------
// Low-level helpers
//---------------------------------------------------------
string CouncilMemoryEscape(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", "");
   StringReplace(s, "\n", " ");
   StringReplace(s, "\t", " ");
   return s;
}

double CouncilMemorySafeDivide(double a, double b)
{
   if(b == 0.0)
      return 0.0;
   return (a / b);
}

bool CouncilMemorySaveTextFile(string relativePath, string text)
{
   if(StringLen(relativePath) <= 0)
      return true;

   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

//---------------------------------------------------------
// Small counters helpers
//---------------------------------------------------------
void CouncilMemoryCountQualityBand(CouncilMemorySummary &m, string band)
{
   band = TrimString(band);

   if(StringLen(band) <= 0)
      return;

   if(band == "HIGH")
   {
      m.high_quality_records++;
      return;
   }

   if(band == "MEDIUM")
   {
      m.medium_quality_records++;
      return;
   }

   if(band == "LOW")
   {
      m.low_quality_records++;
      return;
   }
}

void CouncilMemoryCountSetupType(CouncilMemorySummary &m, string setupType)
{
   setupType = TrimString(setupType);

   if(StringLen(setupType) <= 0)
      return;

   if(setupType == "CONTINUATION")
   {
      m.continuation_setups++;
      return;
   }

   if(setupType == "REVERSAL")
   {
      m.reversal_setups++;
      return;
   }

   if(setupType == "MEAN_RECLAIM")
   {
      m.mean_reclaim_setups++;
      return;
   }

   if(setupType == "BREAKOUT")
   {
      m.breakout_setups++;
      return;
   }

   if(setupType == "DEFENSIVE")
   {
      m.defensive_setups++;
      return;
   }

   if(setupType == "UNSPECIFIED")
   {
      m.unspecified_setups++;
      return;
   }
}

void CouncilMemoryCountFailureTag(CouncilMemorySummary &m, string failureTag)
{
   failureTag = TrimString(failureTag);

   if(StringLen(failureTag) <= 0)
      return;

   if(failureTag == "LATE_CONTINUATION_FAILURE")
   {
      m.late_continuation_failures++;
      return;
   }

   if(failureTag == "WEAK_REVERSAL_FAILURE")
   {
      m.weak_reversal_failures++;
      return;
   }

   if(failureTag == "ZONE_MISMATCH_FAILURE")
   {
      m.zone_mismatch_failures++;
      return;
   }

   if(failureTag == "HIGH_CONFLICT_FAILURE")
   {
      m.high_conflict_failures++;
      return;
   }

   if(failureTag == "LOW_QUALITY_ENTRY")
   {
      m.low_quality_failures++;
      return;
   }

   if(failureTag == "NO_CONFIRM_ROLE_FAILURE")
   {
      m.no_confirm_role_failures++;
      return;
   }

   if(failureTag == "EXHAUSTION_IGNORED_FAILURE")
   {
      m.exhaustion_ignored_failures++;
      return;
   }

   if(failureTag == "UNCLASSIFIED_FAILURE")
   {
      m.unclassified_failures++;
      return;
   }
}

string CouncilMemoryResolveTopFailureTag(CouncilMemorySummary &m)
{
   int best = -1;
   string tag = "";

   if(m.late_continuation_failures > best)
   {
      best = m.late_continuation_failures;
      tag = "LATE_CONTINUATION_FAILURE";
   }

   if(m.weak_reversal_failures > best)
   {
      best = m.weak_reversal_failures;
      tag = "WEAK_REVERSAL_FAILURE";
   }

   if(m.zone_mismatch_failures > best)
   {
      best = m.zone_mismatch_failures;
      tag = "ZONE_MISMATCH_FAILURE";
   }

   if(m.high_conflict_failures > best)
   {
      best = m.high_conflict_failures;
      tag = "HIGH_CONFLICT_FAILURE";
   }

   if(m.low_quality_failures > best)
   {
      best = m.low_quality_failures;
      tag = "LOW_QUALITY_ENTRY";
   }

   if(m.no_confirm_role_failures > best)
   {
      best = m.no_confirm_role_failures;
      tag = "NO_CONFIRM_ROLE_FAILURE";
   }

   if(m.exhaustion_ignored_failures > best)
   {
      best = m.exhaustion_ignored_failures;
      tag = "EXHAUSTION_IGNORED_FAILURE";
   }

   if(m.unclassified_failures > best)
   {
      best = m.unclassified_failures;
      tag = "UNCLASSIFIED_FAILURE";
   }

   if(best <= 0)
      return "";

   return tag;
}

string CouncilMemoryResolveTopSetupType(CouncilMemorySummary &m)
{
   int best = -1;
   string tag = "";

   if(m.continuation_setups > best)
   {
      best = m.continuation_setups;
      tag = "CONTINUATION";
   }

   if(m.reversal_setups > best)
   {
      best = m.reversal_setups;
      tag = "REVERSAL";
   }

   if(m.mean_reclaim_setups > best)
   {
      best = m.mean_reclaim_setups;
      tag = "MEAN_RECLAIM";
   }

   if(m.breakout_setups > best)
   {
      best = m.breakout_setups;
      tag = "BREAKOUT";
   }

   if(m.defensive_setups > best)
   {
      best = m.defensive_setups;
      tag = "DEFENSIVE";
   }

   if(m.unspecified_setups > best)
   {
      best = m.unspecified_setups;
      tag = "UNSPECIFIED";
   }

   if(best <= 0)
      return "";

   return tag;
}

//---------------------------------------------------------
// Record parsing
//---------------------------------------------------------
bool ParseCouncilFeedbackRecordFromJson(string json, CouncilFeedbackRecord &r)
{
   InitCouncilFeedbackRecord(r);

   string s = "";
   double d = 0.0;
   int i = 0;
   bool b = false;

   if(ExtractJsonStringField(json, "symbol", s))
      r.symbol = s;

   if(ExtractJsonStringField(json, "plan_id", s))
      r.plan_id = s;

   if(ExtractJsonStringField(json, "mode_name", s))
      r.mode_name = s;

   if(ExtractJsonStringField(json, "record_type", s))
      r.record_type = s;

   if(ExtractJsonStringField(json, "decision_id", s))
      r.decision_id = s;

   if(ExtractJsonStringField(json, "correlated_decision_id", s))
      r.correlated_decision_id = s;

   ulong u = 0;
   if(JA_ExtractJsonUlong(json, "position_id", u))
      r.position_id = u;

   if(JA_ExtractJsonUlong(json, "close_deal_id", u))
      r.close_deal_id = u;

   if(ExtractJsonStringField(json, "correlation_method", s))
      r.correlation_method = s;

   if(ExtractJsonDoubleField(json, "correlation_quality", d))
      r.correlation_quality = d;

   if(ExtractJsonStringField(json, "final_decision", s))
      r.final_decision = s;

   if(ExtractJsonStringField(json, "executed_direction", s))
      r.executed_direction = s;

   if(ExtractJsonStringField(json, "trade_result", s))
      r.trade_result = s;

   if(ExtractJsonDoubleField(json, "profit", d))
      r.profit = d;

   if(ExtractJsonDoubleField(json, "environment_score", d))
      r.environment_score = d;

   if(ExtractJsonDoubleField(json, "council_quality", d))
      r.council_quality = d;

   if(ExtractJsonDoubleField(json, "consensus_strength", d))
      r.consensus_strength = d;

   if(ExtractJsonDoubleField(json, "conflict_score", d))
      r.conflict_score = d;

   if(ExtractJsonStringField(json, "zone_name", s))
      r.zone_name = s;

   if(ExtractJsonDoubleField(json, "zone_confidence", d))
      r.zone_confidence = d;

   if(ExtractJsonStringField(json, "preferred_style", s))
      r.preferred_style = s;

   if(ExtractJsonStringField(json, "governor_state", s))
      r.governor_state = s;

   if(ExtractJsonStringField(json, "consensus_label", s))
      r.consensus_label = s;

   if(ExtractJsonStringField(json, "best_strategy_id", s))
      r.best_strategy_id = s;

   if(ExtractJsonStringField(json, "support_strategy_ids", s))
      r.support_strategy_ids = s;

   if(ExtractJsonStringField(json, "regime_summary", s))
      r.regime_summary = s;

   if(ExtractJsonStringField(json, "explanation", s))
      r.explanation = s;

   if(ExtractJsonStringField(json, "failure_tag", s))
      r.failure_tag = s;

   if(ExtractJsonStringField(json, "quality_band", s))
      r.quality_band = s;

   if(ExtractJsonStringField(json, "setup_type", s))
      r.setup_type = s;

   if(ExtractJsonBoolField(json, "confirm_role_present", b))
      r.confirm_role_present = b;

   if(ExtractJsonBoolField(json, "trend_judge_supportive", b))
      r.trend_judge_supportive = b;

   if(ExtractJsonBoolField(json, "exhaustion_warning", b))
      r.exhaustion_warning = b;

   if(ExtractJsonBoolField(json, "c1_tc_active", b))
      r.c1_tc_active = b;

   if(ExtractJsonBoolField(json, "c1_high_conviction_active", b))
      r.c1_high_conviction_active = b;

   if(ExtractJsonBoolField(json, "c1_overextension_active", b))
      r.c1_overextension_active = b;

   if(ExtractJsonBoolField(json, "c1_pre_governor_candidate", b))
      r.c1_pre_governor_candidate = b;

   if(ExtractJsonBoolField(json, "c1_shadowed_by_exhaustion", b))
      r.c1_shadowed_by_exhaustion = b;

   if(ExtractJsonStringField(json, "c1_shadow_reason", s))
      r.c1_shadow_reason = s;

   if(ExtractJsonBoolField(json, "c2_overextension_m5_active", b))
      r.c2_overextension_m5_active = b;

   if(ExtractJsonBoolField(json, "c2_consensus_tightening_applied", b))
      r.c2_consensus_tightening_applied = b;

   if(ExtractJsonDoubleField(json, "c2_consensus_tightening_delta", d))
      r.c2_consensus_tightening_delta = d;

   if(ExtractJsonDoubleField(json, "c2_pre_consensus_requirement", d))
      r.c2_pre_consensus_requirement = d;

   if(ExtractJsonDoubleField(json, "c2_post_consensus_requirement", d))
      r.c2_post_consensus_requirement = d;

   if(ExtractJsonBoolField(json, "c2_effective_on_outcome", b))
      r.c2_effective_on_outcome = b;

   if(ExtractJsonStringField(json, "c2_gate_outcome", s))
      r.c2_gate_outcome = s;

   if(ExtractJsonBoolField(json, "c3_low_structure_tc_active", b))
      r.c3_low_structure_tc_active = b;

   if(ExtractJsonDoubleField(json, "c3_structure_score", d))
      r.c3_structure_score = d;

   if(ExtractJsonBoolField(json, "c3_logic_applied", b))
      r.c3_logic_applied = b;

   if(ExtractJsonBoolField(json, "c3_effective_on_outcome", b))
      r.c3_effective_on_outcome = b;

   if(ExtractJsonStringField(json, "c3_gate_outcome", s))
      r.c3_gate_outcome = s;

   if(ExtractJsonStringField(json, "c123_obstacle_summary", s))
      r.c123_obstacle_summary = s;

   if(ExtractJsonStringField(json, "c123_obstacle_semantics_version", s))
      r.c123_obstacle_semantics_version = s;

   if(ExtractJsonIntField(json, "close_time", i))
      r.close_time = (datetime)i;

   NormalizeCouncilFeedbackRecordSemantics(r);
   return true;
}

//---------------------------------------------------------
// Array/object extraction from feedback log
//---------------------------------------------------------
int ExtractCouncilFeedbackObjects(string jsonArrayText, string &outObjects[], int maxCount = 500)
{
   ArrayResize(outObjects, 0);

   int count = 0;
   string s = TrimString(jsonArrayText);

   if(StringLen(s) <= 0)
      return 0;

   bool inString = false;
   bool escaped = false;
   int depth = 0;
   int start = -1;

   for(int i = 0; i < StringLen(s); i++)
   {
      ushort c = StringGetCharacter(s, i);

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
            if(depth == 0)
               start = i;

            depth++;
         }
         else if(c == '}')
         {
            depth--;
            if(depth == 0 && start >= 0)
            {
               if(count < maxCount)
               {
                  outObjects[count] = StringSubstr(s, start, i - start + 1);
                  count++;
               }
               start = -1;
            }
         }
      }
   }

   return count;
}

//---------------------------------------------------------
// Stats helpers
//---------------------------------------------------------
void InitCouncilStrategyMemoryStats(CouncilStrategyMemoryStats &st, string name)
{
   st.strategy_name   = name;

   st.total_signals   = 0;
   st.executed_trades = 0;

   st.wins            = 0;
   st.losses          = 0;
   st.flats           = 0;

   st.buy_signals     = 0;
   st.sell_signals    = 0;

   st.buy_wins        = 0;
   st.buy_losses      = 0;
   st.sell_wins       = 0;
   st.sell_losses     = 0;

   st.total_profit    = 0.0;
   st.avg_profit      = 0.0;
   st.win_rate        = 0.0;
}

void FinalizeCouncilStrategyMemoryStats(CouncilStrategyMemoryStats &st)
{
   int decisive = st.wins + st.losses;

   st.avg_profit = CouncilMemorySafeDivide(st.total_profit, st.executed_trades);
   st.win_rate   = 100.0 * CouncilMemorySafeDivide((double)st.wins, (double)decisive);
}

bool CouncilMemoryIsExecutableDecision(string d)
{
   d = TrimString(d);
   return (d == "BUY" || d == "SELL");
}

bool CouncilMemoryIsExecutedTradeResult(string tradeResult)
{
   tradeResult = TrimString(tradeResult);
   return (tradeResult == "WIN" || tradeResult == "LOSS" || tradeResult == "FLAT");
}

bool CouncilMemoryRepairCloseRecordLinkage(CouncilFeedbackRecord &r)
{
   NormalizeCouncilFeedbackRecordSemantics(r);

   if(r.record_type != CouncilFeedbackRecordTypeTradeCloseOutcome())
      return false;

   if(!CouncilMemoryIsExecutedTradeResult(r.trade_result))
      return false;

   if(CouncilMemoryIsExecutableDecision(r.executed_direction))
      return true;

   string resolvedDirection = "";

   if(CouncilFeedbackIsDirectionText(r.final_decision))
      resolvedDirection = r.final_decision;

   if(StringLen(resolvedDirection) <= 0 && r.position_id > 0)
      JA_FindTradeOpenDirectionByPositionId(r.position_id, resolvedDirection);

   if(StringLen(resolvedDirection) <= 0 && StringLen(r.decision_id) > 0)
   {
      ulong resolvedPositionId = 0;
      if(JA_FindTradeOpenDirectionByDecisionId(r.decision_id, resolvedDirection, resolvedPositionId))
      {
         if(r.position_id == 0 && resolvedPositionId > 0)
            r.position_id = resolvedPositionId;
      }
   }

   if(StringLen(resolvedDirection) <= 0 && StringLen(r.correlated_decision_id) > 0)
   {
      ulong resolvedPositionId = 0;
      if(JA_FindTradeOpenDirectionByDecisionId(r.correlated_decision_id, resolvedDirection, resolvedPositionId))
      {
         if(r.position_id == 0 && resolvedPositionId > 0)
            r.position_id = resolvedPositionId;
      }
   }

   if(StringLen(resolvedDirection) <= 0)
   {
      string fingerprintDecisionId = "";
      ulong fingerprintPositionId = 0;
      if(JA_FindTradeDirectionByCloseFingerprint(
            r.symbol,
            r.close_time,
            r.profit,
            r.trade_result,
            resolvedDirection,
            fingerprintDecisionId,
            fingerprintPositionId))
      {
         if(StringLen(r.decision_id) <= 0 && StringLen(fingerprintDecisionId) > 0)
            r.decision_id = fingerprintDecisionId;

         if(r.position_id == 0 && fingerprintPositionId > 0)
            r.position_id = fingerprintPositionId;
      }
   }

   if(CouncilMemoryIsExecutableDecision(resolvedDirection))
   {
      r.executed_direction = resolvedDirection;

      if(!CouncilFeedbackIsDirectionText(r.final_decision))
         r.final_decision = resolvedDirection;

      return true;
   }

   return false;
}

bool CouncilMemoryIsExecutedTradeRecord(CouncilFeedbackRecord &r)
{
   if(TrimString(r.record_type) != CouncilFeedbackRecordTypeTradeCloseOutcome())
      return false;

   if(!CouncilMemoryIsExecutedTradeResult(r.trade_result))
      return false;

   if(CouncilMemoryIsExecutableDecision(r.executed_direction))
      return true;

   return CouncilMemoryRepairCloseRecordLinkage(r);
}


void UpdateCouncilStrategyStats(
   CouncilStrategyMemoryStats &st,
   string executedDirection,
   string tradeResult,
   double realizedProfit
)
{
   executedDirection = TrimString(executedDirection);
   tradeResult       = TrimString(tradeResult);

   if(!CouncilMemoryIsExecutableDecision(executedDirection))
      return;

   if(!CouncilMemoryIsExecutedTradeResult(tradeResult))
      return;

   st.total_signals++;
   st.executed_trades++;

   if(executedDirection == "BUY")
      st.buy_signals++;
   else if(executedDirection == "SELL")
      st.sell_signals++;

   st.total_profit += realizedProfit;

   if(tradeResult == "WIN")
   {
      st.wins++;

      if(executedDirection == "BUY")
         st.buy_wins++;

      if(executedDirection == "SELL")
         st.sell_wins++;

      return;
   }

   if(tradeResult == "LOSS")
   {
      st.losses++;

      if(executedDirection == "BUY")
         st.buy_losses++;

      if(executedDirection == "SELL")
         st.sell_losses++;

      return;
   }

   st.flats++;
}

void CouncilMemoryAssignOrUpdateBestStrategy(
   CouncilMemorySummary &m,
   string strategyId,
   string executedDirection,
   string tradeResult,
   double realizedProfit
)
{
   strategyId = TrimString(strategyId);

   if(StringLen(strategyId) <= 0)
      return;

   if(!CouncilMemoryIsExecutableDecision(executedDirection))
      return;

   if(!CouncilMemoryIsExecutedTradeResult(tradeResult))
      return;

   if(m.strategy_1.strategy_name == strategyId)
   {
      UpdateCouncilStrategyStats(m.strategy_1, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_2.strategy_name == strategyId)
   {
      UpdateCouncilStrategyStats(m.strategy_2, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_3.strategy_name == strategyId)
   {
      UpdateCouncilStrategyStats(m.strategy_3, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_4.strategy_name == strategyId)
   {
      UpdateCouncilStrategyStats(m.strategy_4, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_1.strategy_name == "STRATEGY_1")
   {
      m.strategy_1.strategy_name = strategyId;
      UpdateCouncilStrategyStats(m.strategy_1, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_2.strategy_name == "STRATEGY_2")
   {
      m.strategy_2.strategy_name = strategyId;
      UpdateCouncilStrategyStats(m.strategy_2, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_3.strategy_name == "STRATEGY_3")
   {
      m.strategy_3.strategy_name = strategyId;
      UpdateCouncilStrategyStats(m.strategy_3, executedDirection, tradeResult, realizedProfit);
      return;
   }

   if(m.strategy_4.strategy_name == "STRATEGY_4")
   {
      m.strategy_4.strategy_name = strategyId;
      UpdateCouncilStrategyStats(m.strategy_4, executedDirection, tradeResult, realizedProfit);
      return;
   }
}

//---------------------------------------------------------
// Strategy ranking helpers
//---------------------------------------------------------
double CouncilMemoryStrategyCompositeScore(CouncilStrategyMemoryStats &st)
{
   if(st.executed_trades <= 0)
      return -1000000.0;

   return (st.win_rate * 0.70) + (st.avg_profit * 0.30);
}

double CouncilMemoryBuyCompositeScore(CouncilStrategyMemoryStats &st)
{
   int decisive = st.buy_wins + st.buy_losses;
   if(decisive <= 0)
      return -1000000.0;

   double wr = 100.0 * CouncilMemorySafeDivide((double)st.buy_wins, (double)decisive);
   return wr;
}

double CouncilMemorySellCompositeScore(CouncilStrategyMemoryStats &st)
{
   int decisive = st.sell_wins + st.sell_losses;
   if(decisive <= 0)
      return -1000000.0;

   double wr = 100.0 * CouncilMemorySafeDivide((double)st.sell_wins, (double)decisive);
   return wr;
}

//---------------------------------------------------------
// Summary builders
//---------------------------------------------------------
string CouncilStrategyStatsToJson(CouncilStrategyMemoryStats &st)
{
   string json = "{";
   json += "\"strategy_name\":\"" + CouncilMemoryEscape(st.strategy_name) + "\",";
   json += "\"total_signals\":" + IntegerToString(st.total_signals) + ",";
   json += "\"executed_trades\":" + IntegerToString(st.executed_trades) + ",";
   json += "\"wins\":" + IntegerToString(st.wins) + ",";
   json += "\"losses\":" + IntegerToString(st.losses) + ",";
   json += "\"flats\":" + IntegerToString(st.flats) + ",";
   json += "\"buy_signals\":" + IntegerToString(st.buy_signals) + ",";
   json += "\"sell_signals\":" + IntegerToString(st.sell_signals) + ",";
   json += "\"buy_wins\":" + IntegerToString(st.buy_wins) + ",";
   json += "\"buy_losses\":" + IntegerToString(st.buy_losses) + ",";
   json += "\"sell_wins\":" + IntegerToString(st.sell_wins) + ",";
   json += "\"sell_losses\":" + IntegerToString(st.sell_losses) + ",";
   json += "\"total_profit\":" + DoubleToString(st.total_profit, 2) + ",";
   json += "\"avg_profit\":" + DoubleToString(st.avg_profit, 4) + ",";
   json += "\"win_rate\":" + DoubleToString(st.win_rate, 2);
   json += "}";
   return json;
}

string BuildCouncilMemorySummaryText(CouncilMemorySummary &m)
{
   string s = "";

   s += "COUNCIL MEMORY SUMMARY\n";
   s += "artifact_authority_class: NON_AUTHORITATIVE_REBUILDABLE_SUMMARY\n";
   s += "source_scope: FULL_FEEDBACK_FILE\n";
   s += "total_records: " + IntegerToString(m.total_records) + "\n";
   s += "executed_records: " + IntegerToString(m.executed_records) + "\n";
   s += "decision_snapshot_records: " + IntegerToString(m.decision_snapshot_records) + "\n";
   s += "trade_close_outcome_records: " + IntegerToString(m.trade_close_outcome_records) + "\n";
   s += "correlated_close_outcome_records: " + IntegerToString(m.correlated_close_outcome_records) + "\n";
   s += "attributed_executed_records: " + IntegerToString(m.attributed_executed_records) + "\n";
   s += "unattributed_executed_records: " + IntegerToString(m.unattributed_executed_records) + "\n";
   s += "wins: " + IntegerToString(m.wins) + "\n";
   s += "losses: " + IntegerToString(m.losses) + "\n";
   s += "flats: " + IntegerToString(m.flats) + "\n";
   s += "total_profit: " + DoubleToString(m.total_profit, 2) + "\n";
   s += "avg_profit: " + DoubleToString(m.avg_profit, 4) + "\n";
   s += "overall_win_rate_executed_only: " + DoubleToString(m.overall_win_rate, 2) + "\n";

   s += "high_quality_records: " + IntegerToString(m.high_quality_records) + "\n";
   s += "medium_quality_records: " + IntegerToString(m.medium_quality_records) + "\n";
   s += "low_quality_records: " + IntegerToString(m.low_quality_records) + "\n";

   s += "confirm_supported_records: " + IntegerToString(m.confirm_supported_records) + "\n";
   s += "trend_judge_supported_records: " + IntegerToString(m.trend_judge_supported_records) + "\n";
   s += "exhaustion_warning_records: " + IntegerToString(m.exhaustion_warning_records) + "\n";

   s += "continuation_setups: " + IntegerToString(m.continuation_setups) + "\n";
   s += "reversal_setups: " + IntegerToString(m.reversal_setups) + "\n";
   s += "mean_reclaim_setups: " + IntegerToString(m.mean_reclaim_setups) + "\n";
   s += "breakout_setups: " + IntegerToString(m.breakout_setups) + "\n";
   s += "defensive_setups: " + IntegerToString(m.defensive_setups) + "\n";
   s += "unspecified_setups: " + IntegerToString(m.unspecified_setups) + "\n";

   s += "late_continuation_failures: " + IntegerToString(m.late_continuation_failures) + "\n";
   s += "weak_reversal_failures: " + IntegerToString(m.weak_reversal_failures) + "\n";
   s += "zone_mismatch_failures: " + IntegerToString(m.zone_mismatch_failures) + "\n";
   s += "high_conflict_failures: " + IntegerToString(m.high_conflict_failures) + "\n";
   s += "low_quality_failures: " + IntegerToString(m.low_quality_failures) + "\n";
   s += "no_confirm_role_failures: " + IntegerToString(m.no_confirm_role_failures) + "\n";
   s += "exhaustion_ignored_failures: " + IntegerToString(m.exhaustion_ignored_failures) + "\n";
   s += "unclassified_failures: " + IntegerToString(m.unclassified_failures) + "\n";

   s += "top_failure_tag: " + m.top_failure_tag + "\n";
   s += "top_setup_type: " + m.top_setup_type + "\n";

   s += "best_overall_strategy: " + m.best_overall_strategy + "\n";
   s += "best_buy_strategy: " + m.best_buy_strategy + "\n";
   s += "best_sell_strategy: " + m.best_sell_strategy + "\n";
   s += "last_best_strategy_id: " + m.best_strategy_id + "\n";
   s += "last_support_strategy_ids: " + m.support_strategy_ids + "\n";

   s += "\nSTRATEGY 1\n";
   s += "name: " + m.strategy_1.strategy_name + "\n";
   s += "signals: " + IntegerToString(m.strategy_1.total_signals) + "\n";
   s += "executed: " + IntegerToString(m.strategy_1.executed_trades) + "\n";
   s += "wins: " + IntegerToString(m.strategy_1.wins) + "\n";
   s += "losses: " + IntegerToString(m.strategy_1.losses) + "\n";
   s += "avg_profit: " + DoubleToString(m.strategy_1.avg_profit, 4) + "\n";
   s += "win_rate: " + DoubleToString(m.strategy_1.win_rate, 2) + "\n";

   s += "\nSTRATEGY 2\n";
   s += "name: " + m.strategy_2.strategy_name + "\n";
   s += "signals: " + IntegerToString(m.strategy_2.total_signals) + "\n";
   s += "executed: " + IntegerToString(m.strategy_2.executed_trades) + "\n";
   s += "wins: " + IntegerToString(m.strategy_2.wins) + "\n";
   s += "losses: " + IntegerToString(m.strategy_2.losses) + "\n";
   s += "avg_profit: " + DoubleToString(m.strategy_2.avg_profit, 4) + "\n";
   s += "win_rate: " + DoubleToString(m.strategy_2.win_rate, 2) + "\n";

   s += "\nSTRATEGY 3\n";
   s += "name: " + m.strategy_3.strategy_name + "\n";
   s += "signals: " + IntegerToString(m.strategy_3.total_signals) + "\n";
   s += "executed: " + IntegerToString(m.strategy_3.executed_trades) + "\n";
   s += "wins: " + IntegerToString(m.strategy_3.wins) + "\n";
   s += "losses: " + IntegerToString(m.strategy_3.losses) + "\n";
   s += "avg_profit: " + DoubleToString(m.strategy_3.avg_profit, 4) + "\n";
   s += "win_rate: " + DoubleToString(m.strategy_3.win_rate, 2) + "\n";

   s += "\nSTRATEGY 4\n";
   s += "name: " + m.strategy_4.strategy_name + "\n";
   s += "signals: " + IntegerToString(m.strategy_4.total_signals) + "\n";
   s += "executed: " + IntegerToString(m.strategy_4.executed_trades) + "\n";
   s += "wins: " + IntegerToString(m.strategy_4.wins) + "\n";
   s += "losses: " + IntegerToString(m.strategy_4.losses) + "\n";
   s += "avg_profit: " + DoubleToString(m.strategy_4.avg_profit, 4) + "\n";
   s += "win_rate: " + DoubleToString(m.strategy_4.win_rate, 2) + "\n";

   return s;
}

string BuildCouncilMemorySummaryJson(CouncilMemorySummary &m)
{
   string json = "{";
   json += "\"artifact_authority_class\":\"NON_AUTHORITATIVE_REBUILDABLE_SUMMARY\",";
   json += "\"source_scope\":\"FULL_FEEDBACK_FILE\",";
   json += "\"total_records\":" + IntegerToString(m.total_records) + ",";
   json += "\"executed_records\":" + IntegerToString(m.executed_records) + ",";
   json += "\"decision_snapshot_records\":" + IntegerToString(m.decision_snapshot_records) + ",";
   json += "\"trade_close_outcome_records\":" + IntegerToString(m.trade_close_outcome_records) + ",";
   json += "\"correlated_close_outcome_records\":" + IntegerToString(m.correlated_close_outcome_records) + ",";
   json += "\"attributed_executed_records\":" + IntegerToString(m.attributed_executed_records) + ",";
   json += "\"unattributed_executed_records\":" + IntegerToString(m.unattributed_executed_records) + ",";
   json += "\"wins\":" + IntegerToString(m.wins) + ",";
   json += "\"losses\":" + IntegerToString(m.losses) + ",";
   json += "\"flats\":" + IntegerToString(m.flats) + ",";
   json += "\"total_profit\":" + DoubleToString(m.total_profit, 2) + ",";
   json += "\"avg_profit\":" + DoubleToString(m.avg_profit, 4) + ",";
   json += "\"overall_win_rate_executed_only\":" + DoubleToString(m.overall_win_rate, 2) + ",";

   json += "\"high_quality_records\":" + IntegerToString(m.high_quality_records) + ",";
   json += "\"medium_quality_records\":" + IntegerToString(m.medium_quality_records) + ",";
   json += "\"low_quality_records\":" + IntegerToString(m.low_quality_records) + ",";

   json += "\"confirm_supported_records\":" + IntegerToString(m.confirm_supported_records) + ",";
   json += "\"trend_judge_supported_records\":" + IntegerToString(m.trend_judge_supported_records) + ",";
   json += "\"exhaustion_warning_records\":" + IntegerToString(m.exhaustion_warning_records) + ",";

   json += "\"continuation_setups\":" + IntegerToString(m.continuation_setups) + ",";
   json += "\"reversal_setups\":" + IntegerToString(m.reversal_setups) + ",";
   json += "\"mean_reclaim_setups\":" + IntegerToString(m.mean_reclaim_setups) + ",";
   json += "\"breakout_setups\":" + IntegerToString(m.breakout_setups) + ",";
   json += "\"defensive_setups\":" + IntegerToString(m.defensive_setups) + ",";
   json += "\"unspecified_setups\":" + IntegerToString(m.unspecified_setups) + ",";

   json += "\"late_continuation_failures\":" + IntegerToString(m.late_continuation_failures) + ",";
   json += "\"weak_reversal_failures\":" + IntegerToString(m.weak_reversal_failures) + ",";
   json += "\"zone_mismatch_failures\":" + IntegerToString(m.zone_mismatch_failures) + ",";
   json += "\"high_conflict_failures\":" + IntegerToString(m.high_conflict_failures) + ",";
   json += "\"low_quality_failures\":" + IntegerToString(m.low_quality_failures) + ",";
   json += "\"no_confirm_role_failures\":" + IntegerToString(m.no_confirm_role_failures) + ",";
   json += "\"exhaustion_ignored_failures\":" + IntegerToString(m.exhaustion_ignored_failures) + ",";
   json += "\"unclassified_failures\":" + IntegerToString(m.unclassified_failures) + ",";

   json += "\"top_failure_tag\":\"" + CouncilMemoryEscape(m.top_failure_tag) + "\",";
   json += "\"top_setup_type\":\"" + CouncilMemoryEscape(m.top_setup_type) + "\",";

   json += "\"best_overall_strategy\":\"" + CouncilMemoryEscape(m.best_overall_strategy) + "\",";
   json += "\"best_buy_strategy\":\"" + CouncilMemoryEscape(m.best_buy_strategy) + "\",";
   json += "\"best_sell_strategy\":\"" + CouncilMemoryEscape(m.best_sell_strategy) + "\",";
   json += "\"best_strategy_id\":\"" + CouncilMemoryEscape(m.best_strategy_id) + "\",";
   json += "\"support_strategy_ids\":\"" + CouncilMemoryEscape(m.support_strategy_ids) + "\",";
   json += "\"strategy_1\":" + CouncilStrategyStatsToJson(m.strategy_1) + ",";
   json += "\"strategy_2\":" + CouncilStrategyStatsToJson(m.strategy_2) + ",";
   json += "\"strategy_3\":" + CouncilStrategyStatsToJson(m.strategy_3) + ",";
   json += "\"strategy_4\":" + CouncilStrategyStatsToJson(m.strategy_4);
   json += "}";
   return json;
}

//---------------------------------------------------------
//---------------------------------------------------------
// Read-only journal attribution enrichment
//---------------------------------------------------------
bool CouncilMemoryResolveJournalAttributionByPosition(
   ulong positionId,
   string &dominant_strategy_id,
   string &aligned_strategy_ids,
   double &attribution_confidence
)
{
   dominant_strategy_id = "";
   aligned_strategy_ids = "";
   attribution_confidence = 0.0;

   if(positionId == 0)
      return false;

   int aligned = 0, opposing = 0, neutral = 0;
   string opposing_ids = "", neutral_ids = "", compact = "";

   const string relPath = "AI\\ai_performance_journal.jsonl";
   const int maxLines = 500;

   bool ok = PJ_LoadCouncilAttributionMetaByPositionId(
      relPath,
      positionId,
      maxLines,
      dominant_strategy_id,
      aligned,
      opposing,
      neutral,
      attribution_confidence,
      aligned_strategy_ids,
      opposing_ids,
      neutral_ids,
      compact
   );

   return ok && StringLen(dominant_strategy_id) > 0;
}

// Main builder
//---------------------------------------------------------
bool BuildCouncilMemorySummaryFromFeedback(
   string feedbackPath,
   CouncilMemorySummary &m,
   string &logMessage
)
{
   logMessage = "";

   m.total_records                 = 0;
   m.executed_records              = 0;


   m.decision_snapshot_records       = 0;
   m.trade_close_outcome_records     = 0;
   m.correlated_close_outcome_records= 0;
   m.attributed_executed_records     = 0;
   m.unattributed_executed_records   = 0;

   m.wins                          = 0;
   m.losses                        = 0;
   m.flats                         = 0;

   m.total_profit                  = 0.0;
   m.avg_profit                    = 0.0;
   m.overall_win_rate              = 0.0;

   m.high_quality_records          = 0;
   m.medium_quality_records        = 0;
   m.low_quality_records           = 0;

   m.confirm_supported_records     = 0;
   m.trend_judge_supported_records = 0;
   m.exhaustion_warning_records    = 0;

   m.continuation_setups           = 0;
   m.reversal_setups               = 0;
   m.mean_reclaim_setups           = 0;
   m.breakout_setups               = 0;
   m.defensive_setups              = 0;
   m.unspecified_setups            = 0;

   m.late_continuation_failures    = 0;
   m.weak_reversal_failures        = 0;
   m.zone_mismatch_failures        = 0;
   m.high_conflict_failures        = 0;
   m.low_quality_failures          = 0;
   m.no_confirm_role_failures      = 0;
   m.exhaustion_ignored_failures   = 0;
   m.unclassified_failures         = 0;

   InitCouncilStrategyMemoryStats(m.strategy_1, "STRATEGY_1");
   InitCouncilStrategyMemoryStats(m.strategy_2, "STRATEGY_2");
   InitCouncilStrategyMemoryStats(m.strategy_3, "STRATEGY_3");
   InitCouncilStrategyMemoryStats(m.strategy_4, "STRATEGY_4");

   m.best_overall_strategy = "";
   m.best_buy_strategy     = "";
   m.best_sell_strategy    = "";
   m.best_strategy_id      = "";
   m.support_strategy_ids  = "";
   m.top_failure_tag       = "";
   m.top_setup_type        = "";
   m.summary_text          = "";
   m.summary_json          = "";

   string raw = "";
   if(!LoadTextFile(feedbackPath, raw))
   {
      logMessage = "Council memory build failed: feedback file not found";
      return false;
   }

   raw = TrimString(raw);
   if(StringLen(raw) <= 0)
   {
      logMessage = "Council memory build failed: feedback file empty";
      return false;
   }
   string objects[];
   int count = ExtractCouncilFeedbackObjects(raw, objects, 0);

   if(count <= 0)
   {
      logMessage = "Council memory build failed: no feedback objects found";
      return false;
   }

   for(int i = 0; i < count; i++)
   {
      CouncilFeedbackRecord r;
      if(!ParseCouncilFeedbackRecordFromJson(objects[i], r))
         continue;

      CouncilMemoryRepairCloseRecordLinkage(r);
      m.total_records++;

      if(r.record_type == CouncilFeedbackRecordTypeDecisionSnapshot())
   m.decision_snapshot_records++;
else if(r.record_type == CouncilFeedbackRecordTypeTradeCloseOutcome())
{
   m.trade_close_outcome_records++;

   if(StringLen(r.decision_id) > 0 || StringLen(r.correlated_decision_id) > 0 || r.position_id > 0)
      m.correlated_close_outcome_records++;
}

      if(StringLen(r.best_strategy_id) > 0)
         m.best_strategy_id = r.best_strategy_id;

      if(StringLen(r.support_strategy_ids) > 0)
         m.support_strategy_ids = r.support_strategy_ids;

      CouncilMemoryCountQualityBand(m, r.quality_band);
      CouncilMemoryCountSetupType(m, r.setup_type);
      CouncilMemoryCountFailureTag(m, r.failure_tag);

      if(r.confirm_role_present)
         m.confirm_supported_records++;

      if(r.trend_judge_supportive)
         m.trend_judge_supported_records++;

      if(r.exhaustion_warning)
         m.exhaustion_warning_records++;

      
bool executed = CouncilMemoryIsExecutedTradeRecord(r);

if(executed)
{
   string effective_best_strategy_id = r.best_strategy_id;
   string effective_support_strategy_ids = r.support_strategy_ids;

   if(StringLen(effective_best_strategy_id) == 0 && r.position_id > 0)
   {
      string dom = "", aligned_ids = "";
      double conf = 0.0;

      if(CouncilMemoryResolveJournalAttributionByPosition(r.position_id, dom, aligned_ids, conf))
      {
         effective_best_strategy_id = dom;

         if(StringLen(effective_support_strategy_ids) == 0)
            effective_support_strategy_ids = aligned_ids;
      }
   }

   if(StringLen(effective_best_strategy_id) > 0)
      m.attributed_executed_records++;
   else
      m.unattributed_executed_records++;

   CouncilMemoryAssignOrUpdateBestStrategy(
      m,
      effective_best_strategy_id,
      r.executed_direction,
      r.trade_result,
      r.profit
   );

   m.executed_records++;
   m.total_profit += r.profit;

   if(r.trade_result == "WIN")
      m.wins++;
   else if(r.trade_result == "LOSS")
      m.losses++;
   else
      m.flats++;
}
   }

   FinalizeCouncilStrategyMemoryStats(m.strategy_1);
   FinalizeCouncilStrategyMemoryStats(m.strategy_2);
   FinalizeCouncilStrategyMemoryStats(m.strategy_3);
   FinalizeCouncilStrategyMemoryStats(m.strategy_4);

   m.avg_profit = CouncilMemorySafeDivide(m.total_profit, m.executed_records);
   m.overall_win_rate = 100.0 * CouncilMemorySafeDivide((double)m.wins, (double)(m.wins + m.losses));

   double s1 = CouncilMemoryStrategyCompositeScore(m.strategy_1);
   double s2 = CouncilMemoryStrategyCompositeScore(m.strategy_2);
   double s3 = CouncilMemoryStrategyCompositeScore(m.strategy_3);
   double s4 = CouncilMemoryStrategyCompositeScore(m.strategy_4);

   double bestOverall = -1000000.0;
   m.best_overall_strategy = "";

   if(s1 > bestOverall) { bestOverall = s1; m.best_overall_strategy = m.strategy_1.strategy_name; }
   if(s2 > bestOverall) { bestOverall = s2; m.best_overall_strategy = m.strategy_2.strategy_name; }
   if(s3 > bestOverall) { bestOverall = s3; m.best_overall_strategy = m.strategy_3.strategy_name; }
   if(s4 > bestOverall) { bestOverall = s4; m.best_overall_strategy = m.strategy_4.strategy_name; }

   if(bestOverall <= -1000000.0)
      m.best_overall_strategy = "";

   double b1 = CouncilMemoryBuyCompositeScore(m.strategy_1);
   double b2 = CouncilMemoryBuyCompositeScore(m.strategy_2);
   double b3 = CouncilMemoryBuyCompositeScore(m.strategy_3);
   double b4 = CouncilMemoryBuyCompositeScore(m.strategy_4);

   double bestBuy = -1000000.0;
   m.best_buy_strategy = "";

   if(b1 > bestBuy) { bestBuy = b1; m.best_buy_strategy = m.strategy_1.strategy_name; }
   if(b2 > bestBuy) { bestBuy = b2; m.best_buy_strategy = m.strategy_2.strategy_name; }
   if(b3 > bestBuy) { bestBuy = b3; m.best_buy_strategy = m.strategy_3.strategy_name; }
   if(b4 > bestBuy) { bestBuy = b4; m.best_buy_strategy = m.strategy_4.strategy_name; }

   if(bestBuy <= -1000000.0)
      m.best_buy_strategy = "";

   double e1 = CouncilMemorySellCompositeScore(m.strategy_1);
   double e2 = CouncilMemorySellCompositeScore(m.strategy_2);
   double e3 = CouncilMemorySellCompositeScore(m.strategy_3);
   double e4 = CouncilMemorySellCompositeScore(m.strategy_4);

   double bestSell = -1000000.0;
   m.best_sell_strategy = "";

   if(e1 > bestSell) { bestSell = e1; m.best_sell_strategy = m.strategy_1.strategy_name; }
   if(e2 > bestSell) { bestSell = e2; m.best_sell_strategy = m.strategy_2.strategy_name; }
   if(e3 > bestSell) { bestSell = e3; m.best_sell_strategy = m.strategy_3.strategy_name; }
   if(e4 > bestSell) { bestSell = e4; m.best_sell_strategy = m.strategy_4.strategy_name; }

   if(bestSell <= -1000000.0)
      m.best_sell_strategy = "";

   m.top_failure_tag = CouncilMemoryResolveTopFailureTag(m);
   m.top_setup_type  = CouncilMemoryResolveTopSetupType(m);

   m.summary_text = BuildCouncilMemorySummaryText(m);
   m.summary_json = BuildCouncilMemorySummaryJson(m);

   logMessage =
      "Council memory built successfully"
      " | records=" + IntegerToString(m.total_records) +
      " | executed=" + IntegerToString(m.executed_records) +
      " | win_rate=" + DoubleToString(m.overall_win_rate, 2) +
      " | best_overall=" + m.best_overall_strategy +
      " | top_failure=" + m.top_failure_tag +
      " | top_setup=" + m.top_setup_type;

   return true;
}

//---------------------------------------------------------
// Save helpers
//---------------------------------------------------------
bool SaveCouncilMemorySummaryText(string relativePath, CouncilMemorySummary &m)
{
   return CouncilMemorySaveTextFile(relativePath, m.summary_text);
}

bool SaveCouncilMemorySummaryJson(string relativePath, CouncilMemorySummary &m)
{
   return CouncilMemorySaveTextFile(relativePath, m.summary_json);
}



//---------------------------------------------------------
// Council audit (Phase 5)
//---------------------------------------------------------
void InitCouncilAuditSummary(CouncilAuditSummary &a)
{
   a.feedback_total_records                  = 0;
   a.feedback_decision_snapshot_records      = 0;
   a.feedback_trade_close_outcome_records    = 0;

   a.close_with_decision_id                 = 0;
   a.close_with_correlated_decision_id      = 0;
   a.close_with_position_id                 = 0;
   a.close_with_resolved_direction          = 0;
   a.close_with_strategy_attribution        = 0;

   a.journal_decision_records               = 0;
   a.journal_trade_open_records             = 0;
   a.journal_trade_open_with_decision_id    = 0;
   a.journal_trade_open_with_position_id    = 0;
   a.journal_trade_open_with_dominant_strategy_id = 0;
   a.journal_trade_records                  = 0;
   a.journal_trade_records_with_decision_id = 0;
   a.journal_trade_records_with_position_id = 0;

   a.close_decision_link_rate               = 0.0;
   a.close_position_link_rate               = 0.0;
   a.close_direction_resolution_rate        = 0.0;
   a.close_strategy_attribution_rate        = 0.0;
   a.trade_open_decision_link_rate          = 0.0;
   a.trade_open_position_link_rate          = 0.0;
   a.trade_open_strategy_attribution_rate   = 0.0;
   a.trade_close_decision_link_rate         = 0.0;
   a.trade_close_position_link_rate         = 0.0;

   a.audit_status                           = "WEAK";
   a.weakest_link                           = "";
   a.summary_text                           = "";
   a.summary_json                           = "";
}

bool CouncilAuditResolveJournalAttributionByPosition(
   string journalPath,
   ulong positionId,
   int maxLines,
   string &dominant_strategy_id
)
{
   dominant_strategy_id = "";

   if(positionId == 0)
      return false;

   int aligned = 0, opposing = 0, neutral = 0;
   double conf = 0.0;
   string aligned_ids = "", opposing_ids = "", neutral_ids = "", compact = "";

   bool ok = PJ_LoadCouncilAttributionMetaByPositionId(
      journalPath,
      positionId,
      MathMax(50, maxLines),
      dominant_strategy_id,
      aligned,
      opposing,
      neutral,
      conf,
      aligned_ids,
      opposing_ids,
      neutral_ids,
      compact
   );

   return ok && StringLen(dominant_strategy_id) > 0;
}

bool CouncilAuditReadTailText(string relativePath, int maxBytes, string &outText)
{
   outText = "";

   int h = FileOpen(relativePath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   int total = (int)FileSize(h);
   int seekPos = total - maxBytes;
   if(seekPos < 0) seekPos = 0;

   FileSeek(h, seekPos, SEEK_SET);

   while(!FileIsEnding(h))
      outText += FileReadString(h);

   FileClose(h);
   return true;
}

bool CouncilAuditExtractLastJsonObjects(string text, int maxObjects, string &objects[])
{
   ArrayResize(objects, 0);

   bool inString = false;
   bool esc = false;
   int depth = 0;
   int start = -1;

   for(int i = 0; i < StringLen(text); i++)
   {
      ushort ch = StringGetCharacter(text, i);

      if(inString)
      {
         if(esc)
         {
            esc = false;
            continue;
         }
         if(ch == '\\')
         {
            esc = true;
            continue;
         }
         if(ch == '"')
         {
            inString = false;
            continue;
         }
         continue;
      }

      if(ch == '"')
      {
         inString = true;
         esc = false;
         continue;
      }

      if(ch == '{')
      {
         if(depth == 0)
            start = i;
         depth++;
         continue;
      }

      if(ch == '}')
      {
         if(depth > 0)
            depth--;

         if(depth == 0 && start >= 0)
         {
            int len = i - start + 1;
            string one = StringSubstr(text, start, len);

            int n = ArraySize(objects);
            ArrayResize(objects, n + 1);
            objects[n] = one;

            start = -1;

            if(n + 1 > maxObjects * 4)
            {
               // keep memory bounded
               int keepFrom = MathMax(0, ArraySize(objects) - (maxObjects * 2));
               int newN = ArraySize(objects) - keepFrom;
               string tmp[];
               ArrayResize(tmp, newN);
               for(int k = 0; k < newN; k++)
                  tmp[k] = objects[keepFrom + k];
               ArrayResize(objects, newN);
               for(int k = 0; k < newN; k++)
                  objects[k] = tmp[k];
            }
         }
         continue;
      }
   }

   int total = ArraySize(objects);
   if(total <= 0)
      return false;

   if(total > maxObjects)
   {
      int keepFrom = total - maxObjects;
      string tmp[];
      ArrayResize(tmp, maxObjects);
      for(int k = 0; k < maxObjects; k++)
         tmp[k] = objects[keepFrom + k];
      ArrayResize(objects, maxObjects);
      for(int k = 0; k < maxObjects; k++)
         objects[k] = tmp[k];
   }

   return true;
}

double CouncilAuditRate(int num, int den)
{
   return CouncilMemorySafeDivide((double)num, (double)den);
}

void CouncilAuditComputeStatus(CouncilAuditSummary &a)
{
   double minRate = 1e9;
   string weakest = "";

   double rates[9];
   string labels[9];

   rates[0] = a.close_decision_link_rate;              labels[0] = "close decision linkage";
   rates[1] = a.close_position_link_rate;              labels[1] = "close position linkage";
   rates[2] = a.close_direction_resolution_rate;       labels[2] = "close direction resolution";
   rates[3] = a.close_strategy_attribution_rate;       labels[3] = "close strategy attribution";
   rates[4] = a.trade_open_decision_link_rate;         labels[4] = "trade_open decision linkage";
   rates[5] = a.trade_open_position_link_rate;         labels[5] = "trade_open position linkage";
   rates[6] = a.trade_open_strategy_attribution_rate;  labels[6] = "trade_open strategy attribution";
   rates[7] = a.trade_close_decision_link_rate;        labels[7] = "trade close decision linkage";
   rates[8] = a.trade_close_position_link_rate;        labels[8] = "trade close position linkage";

   for(int i = 0; i < 9; i++)
   {
      double r = rates[i];
      if(r < minRate)
      {
         minRate = r;
         weakest = labels[i];
      }
   }

   a.weakest_link = weakest;

   if(minRate >= 0.75)
      a.audit_status = "GOOD";
   else if(minRate >= 0.40)
      a.audit_status = "PARTIAL";
   else
      a.audit_status = "WEAK";
}

string BuildCouncilAuditSummaryText(CouncilAuditSummary &a)
{
   string s = "";

   s += "Council Audit Summary\n";
   s += "artifact_authority_class: NON_AUTHORITATIVE_REBUILDABLE_RECENT_WINDOW_AUDIT\n";
   s += "scope: RECENT_WINDOW_DERIVED\n";
   s += "status: " + a.audit_status + "\n";
   s += "weakest_link: " + a.weakest_link + "\n\n";

   s += "[Feedback]\n";
   s += "total_records=" + IntegerToString(a.feedback_total_records) + "\n";
   s += "decision_snapshot_records=" + IntegerToString(a.feedback_decision_snapshot_records) + "\n";
   s += "trade_close_outcome_records=" + IntegerToString(a.feedback_trade_close_outcome_records) + "\n\n";

   s += "[Close Outcomes]\n";
   s += "close_with_decision_id=" + IntegerToString(a.close_with_decision_id) + "\n";
   s += "close_with_correlated_decision_id=" + IntegerToString(a.close_with_correlated_decision_id) + "\n";
   s += "close_with_position_id=" + IntegerToString(a.close_with_position_id) + "\n";
   s += "close_with_resolved_direction=" + IntegerToString(a.close_with_resolved_direction) + "\n";
   s += "close_with_strategy_attribution=" + IntegerToString(a.close_with_strategy_attribution) + "\n";
   s += "close_decision_link_rate=" + DoubleToString(a.close_decision_link_rate, 4) + "\n";
   s += "close_position_link_rate=" + DoubleToString(a.close_position_link_rate, 4) + "\n";
   s += "close_direction_resolution_rate=" + DoubleToString(a.close_direction_resolution_rate, 4) + "\n";
   s += "close_strategy_attribution_rate=" + DoubleToString(a.close_strategy_attribution_rate, 4) + "\n\n";

   s += "[Performance Journal]\n";
   s += "journal_decision_records=" + IntegerToString(a.journal_decision_records) + "\n";
   s += "journal_trade_open_records=" + IntegerToString(a.journal_trade_open_records) + "\n";
   s += "journal_trade_open_with_decision_id=" + IntegerToString(a.journal_trade_open_with_decision_id) + "\n";
   s += "journal_trade_open_with_position_id=" + IntegerToString(a.journal_trade_open_with_position_id) + "\n";
   s += "journal_trade_open_with_dominant_strategy_id=" + IntegerToString(a.journal_trade_open_with_dominant_strategy_id) + "\n";
   s += "journal_trade_records=" + IntegerToString(a.journal_trade_records) + "\n";
   s += "journal_trade_records_with_decision_id=" + IntegerToString(a.journal_trade_records_with_decision_id) + "\n";
   s += "journal_trade_records_with_position_id=" + IntegerToString(a.journal_trade_records_with_position_id) + "\n";
   s += "trade_open_decision_link_rate=" + DoubleToString(a.trade_open_decision_link_rate, 4) + "\n";
   s += "trade_open_position_link_rate=" + DoubleToString(a.trade_open_position_link_rate, 4) + "\n";
   s += "trade_open_strategy_attribution_rate=" + DoubleToString(a.trade_open_strategy_attribution_rate, 4) + "\n";
   s += "trade_close_decision_link_rate=" + DoubleToString(a.trade_close_decision_link_rate, 4) + "\n";
   s += "trade_close_position_link_rate=" + DoubleToString(a.trade_close_position_link_rate, 4) + "\n";

   return s;
}

string BuildCouncilAuditSummaryJson(CouncilAuditSummary &a)
{
   string j = "{";

   j += "\"artifact_authority_class\":\"NON_AUTHORITATIVE_REBUILDABLE_RECENT_WINDOW_AUDIT\",";
   j += "\"scope\":\"RECENT_WINDOW_DERIVED\",";
   j += "\"audit_status\":\"" + CouncilMemoryEscape(a.audit_status) + "\",";
   j += "\"weakest_link\":\"" + CouncilMemoryEscape(a.weakest_link) + "\",";

   j += "\"feedback_total_records\":" + IntegerToString(a.feedback_total_records) + ",";
   j += "\"feedback_decision_snapshot_records\":" + IntegerToString(a.feedback_decision_snapshot_records) + ",";
   j += "\"feedback_trade_close_outcome_records\":" + IntegerToString(a.feedback_trade_close_outcome_records) + ",";

   j += "\"close_with_decision_id\":" + IntegerToString(a.close_with_decision_id) + ",";
   j += "\"close_with_correlated_decision_id\":" + IntegerToString(a.close_with_correlated_decision_id) + ",";
   j += "\"close_with_position_id\":" + IntegerToString(a.close_with_position_id) + ",";
   j += "\"close_with_resolved_direction\":" + IntegerToString(a.close_with_resolved_direction) + ",";
   j += "\"close_with_strategy_attribution\":" + IntegerToString(a.close_with_strategy_attribution) + ",";

   j += "\"close_decision_link_rate\":" + DoubleToString(a.close_decision_link_rate, 6) + ",";
   j += "\"close_position_link_rate\":" + DoubleToString(a.close_position_link_rate, 6) + ",";
   j += "\"close_direction_resolution_rate\":" + DoubleToString(a.close_direction_resolution_rate, 6) + ",";
   j += "\"close_strategy_attribution_rate\":" + DoubleToString(a.close_strategy_attribution_rate, 6) + ",";

   j += "\"journal_decision_records\":" + IntegerToString(a.journal_decision_records) + ",";
   j += "\"journal_trade_open_records\":" + IntegerToString(a.journal_trade_open_records) + ",";
   j += "\"journal_trade_open_with_decision_id\":" + IntegerToString(a.journal_trade_open_with_decision_id) + ",";
   j += "\"journal_trade_open_with_position_id\":" + IntegerToString(a.journal_trade_open_with_position_id) + ",";
   j += "\"journal_trade_open_with_dominant_strategy_id\":" + IntegerToString(a.journal_trade_open_with_dominant_strategy_id) + ",";
   j += "\"journal_trade_records\":" + IntegerToString(a.journal_trade_records) + ",";
   j += "\"journal_trade_records_with_decision_id\":" + IntegerToString(a.journal_trade_records_with_decision_id) + ",";
   j += "\"journal_trade_records_with_position_id\":" + IntegerToString(a.journal_trade_records_with_position_id) + ",";

   j += "\"trade_open_decision_link_rate\":" + DoubleToString(a.trade_open_decision_link_rate, 6) + ",";
   j += "\"trade_open_position_link_rate\":" + DoubleToString(a.trade_open_position_link_rate, 6) + ",";
   j += "\"trade_open_strategy_attribution_rate\":" + DoubleToString(a.trade_open_strategy_attribution_rate, 6) + ",";
   j += "\"trade_close_decision_link_rate\":" + DoubleToString(a.trade_close_decision_link_rate, 6) + ",";
   j += "\"trade_close_position_link_rate\":" + DoubleToString(a.trade_close_position_link_rate, 6);

   j += "}";
   return j;
}

bool BuildCouncilAuditSummaryFromFiles(
   string feedbackPath,
   string journalPath,
   int maxFeedbackRecords,
   int maxJournalLines,
   CouncilAuditSummary &a,
   string &logMessage
)
{
   logMessage = "";
   InitCouncilAuditSummary(a);

   // -------------------
   // Feedback side
   // -------------------
   string tail = "";
   string objects[];
   bool fbOk = CouncilAuditReadTailText(feedbackPath, 220000, tail)
               && CouncilAuditExtractLastJsonObjects(tail, MathMax(10, maxFeedbackRecords), objects);

   if(fbOk)
   {
      int n = ArraySize(objects);
      a.feedback_total_records = n;

      for(int i = 0; i < n; i++)
      {
         CouncilFeedbackRecord r;
         if(!ParseCouncilFeedbackRecordFromJson(objects[i], r))
            continue;

         CouncilMemoryRepairCloseRecordLinkage(r);

         if(r.record_type == CouncilFeedbackRecordTypeDecisionSnapshot())
            a.feedback_decision_snapshot_records++;

         if(r.record_type != CouncilFeedbackRecordTypeTradeCloseOutcome())
            continue;

         a.feedback_trade_close_outcome_records++;

         if(StringLen(r.decision_id) > 0)
            a.close_with_decision_id++;

         if(StringLen(r.correlated_decision_id) > 0)
            a.close_with_correlated_decision_id++;

         if(r.position_id > 0)
            a.close_with_position_id++;

         if(r.executed_direction == "BUY" || r.executed_direction == "SELL")
            a.close_with_resolved_direction++;

         bool hasAttrib = (StringLen(r.best_strategy_id) > 0);
         if(!hasAttrib && r.position_id > 0)
         {
            string dom = "";
            if(CouncilAuditResolveJournalAttributionByPosition(journalPath, r.position_id, 500, dom))
               hasAttrib = true;
         }

         if(hasAttrib)
            a.close_with_strategy_attribution++;
      }
   }
   else
   {
      logMessage += "feedback_unavailable; ";
   }

   // -------------------
   // Journal side
   // -------------------
   string lines[];
   if(JA_ReadLastNLines(journalPath, MathMax(50, maxJournalLines), lines))
   {
      for(int i = 0; i < ArraySize(lines); i++)
      {
         string line = JA_Trim(lines[i]);
         if(StringLen(line) <= 0) continue;

         string rt = "";
         if(!JA_ExtractJsonString(line, "record_type", rt))
            continue;

         if(rt == "DECISION")
         {
            a.journal_decision_records++;
            continue;
         }

         if(rt == "TRADE_OPEN")
         {
            a.journal_trade_open_records++;

            string did = "";
            if(JA_ExtractJsonString(line, "decision_id", did) && StringLen(did) > 0)
               a.journal_trade_open_with_decision_id++;

            ulong pid = 0;
            if(JA_ExtractJsonUlong(line, "position_id", pid) && pid > 0)
               a.journal_trade_open_with_position_id++;

            string dom = "";
            if(JA_ExtractJsonString(line, "dominant_strategy_id", dom) && StringLen(dom) > 0)
               a.journal_trade_open_with_dominant_strategy_id++;

            continue;
         }

         if(rt == "TRADE")
         {
            a.journal_trade_records++;

            string did = "";
            if(JA_ExtractJsonString(line, "decision_id", did) && StringLen(did) > 0)
               a.journal_trade_records_with_decision_id++;

            ulong pid = 0;
            if(JA_ExtractJsonUlong(line, "position_id", pid) && pid > 0)
               a.journal_trade_records_with_position_id++;

            continue;
         }
      }
   }
   else
   {
      logMessage += "journal_unavailable; ";
   }

   // Derived rates
   a.close_decision_link_rate =
      CouncilAuditRate(a.close_with_decision_id, a.feedback_trade_close_outcome_records);
   a.close_position_link_rate =
      CouncilAuditRate(a.close_with_position_id, a.feedback_trade_close_outcome_records);
   a.close_direction_resolution_rate =
      CouncilAuditRate(a.close_with_resolved_direction, a.feedback_trade_close_outcome_records);
   a.close_strategy_attribution_rate =
      CouncilAuditRate(a.close_with_strategy_attribution, a.feedback_trade_close_outcome_records);

   a.trade_open_decision_link_rate =
      CouncilAuditRate(a.journal_trade_open_with_decision_id, a.journal_trade_open_records);
   a.trade_open_position_link_rate =
      CouncilAuditRate(a.journal_trade_open_with_position_id, a.journal_trade_open_records);
   a.trade_open_strategy_attribution_rate =
      CouncilAuditRate(a.journal_trade_open_with_dominant_strategy_id, a.journal_trade_open_records);

   a.trade_close_decision_link_rate =
      CouncilAuditRate(a.journal_trade_records_with_decision_id, a.journal_trade_records);
   a.trade_close_position_link_rate =
      CouncilAuditRate(a.journal_trade_records_with_position_id, a.journal_trade_records);

   CouncilAuditComputeStatus(a);

   a.summary_text = BuildCouncilAuditSummaryText(a);
   a.summary_json = BuildCouncilAuditSummaryJson(a);

   return true;
}

#endif
