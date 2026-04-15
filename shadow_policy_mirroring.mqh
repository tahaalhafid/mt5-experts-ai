#ifndef __SHADOW_POLICY_MIRRORING_MQH__
#define __SHADOW_POLICY_MIRRORING_MQH__

#include "config_loader.mqh"

#include "regime_classification_layer_v1.mqh"
#include "risk_state_policy_engine.mqh"
#include "core_trade_engine.mqh"

//---------------------------------------------------------
// Shadow Policy Mirroring v1
// - Runs a conservative policy permission check using plan + current platform state
// - No side effects: reads only (history/positions/time), does not write counters/logs
//---------------------------------------------------------

struct ShadowPolicyResult
{
   bool   policy_permission;
   bool   final_permission;
   string policy_reason;
   string policy_state_text;
};

void InitShadowPolicyResult(ShadowPolicyResult &r)
{
   r.policy_permission = true;
   r.final_permission  = true;
   r.policy_reason     = "";
   r.policy_state_text = "UNKNOWN";
}

datetime SPM_GetSessionStartTime()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   dt.hour = 0;
   dt.min  = 0;
   dt.sec  = 0;
   return StructToTime(dt);
}

int SPM_CountMyOpenPositions(string symbol, ulong magic)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      if(PositionGetString(POSITION_SYMBOL) == symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC) == magic)
      {
         count++;
      }
   }

   return count;
}

int SPM_CountMyDirectionPositions(string symbol, ulong magic, long positionType)
{
   int count = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      if(PositionGetString(POSITION_SYMBOL) == symbol &&
         (ulong)PositionGetInteger(POSITION_MAGIC) == magic &&
         (long)PositionGetInteger(POSITION_TYPE) == positionType)
      {
         count++;
      }
   }

   return count;
}

void SPM_BuildSessionWinLossStats(string symbol, ulong magic, int &wins, int &losses, int &closedTrades)
{
   wins = 0;
   losses = 0;
   closedTrades = 0;

   datetime fromTime = SPM_GetSessionStartTime();
   datetime toTime   = TimeCurrent();

   if(!HistorySelect(fromTime, toTime))
      return;

   int total = HistoryDealsTotal();

   for(int i = total - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0) continue;

      string dsymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      long   dmagic  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      long   entry   = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

      if(dsymbol != symbol || (ulong)dmagic != magic || entry != DEAL_ENTRY_OUT)
         continue;

      double profit = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);

      if(profit > 0.0) wins++;
      else if(profit < 0.0) losses++;

      closedTrades++;
   }
}

double SPM_ComputeSessionWinRate(string symbol, ulong magic)
{
   int wins=0, losses=0, closedTrades=0;
   SPM_BuildSessionWinLossStats(symbol, magic, wins, losses, closedTrades);

   if(closedTrades <= 0)
      return 0.0;

   return (double)wins / (double)closedTrades * 100.0;
}

int SPM_ComputeSmartSessionCap(RuntimePlan &plan, string symbol, ulong magic)
{
   int baseCap = plan.max_trades_per_session;

   if(baseCap <= 0)
      return 0;

   int wins=0, losses=0, closedTrades=0;
   SPM_BuildSessionWinLossStats(symbol, magic, wins, losses, closedTrades);

   if(closedTrades < 5)
      return baseCap;

   double winRate = SPM_ComputeSessionWinRate(symbol, magic);
   int smartCap = baseCap;

   if(winRate >= 65.0) smartCap = baseCap + 10;
   else if(winRate >= 55.0) smartCap = baseCap + 5;
   else if(winRate <= 30.0) smartCap = 5;
   else if(winRate <= 40.0) smartCap = baseCap - 5;

   if(smartCap < 5) smartCap = 5;

   return smartCap;
}

int SPM_CountSessionClosedTrades(string symbol, ulong magic)
{
   datetime fromTime = SPM_GetSessionStartTime();
   datetime toTime   = TimeCurrent();

   if(!HistorySelect(fromTime, toTime))
      return 0;

   int count = 0;
   int total = HistoryDealsTotal();

   for(int i = total - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      if(dealTicket == 0) continue;

      string dsymbol = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
      long   dmagic  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
      long   entry   = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

      if(dsymbol == symbol &&
         (ulong)dmagic == magic &&
         entry == DEAL_ENTRY_OUT)
      {
         count++;
      }
   }

   return count;
}

bool ShadowPolicyAllowsTradeV1(
   RuntimePlan &plan,
   string symbol,
   ulong magic,
   int lastRuntimeEntryBars,
   CoreDirection dir,
   bool hasRegime,
   RegimeClassification &regime,
   bool hasRiskPolicy,
   RiskPolicySnapshot &riskPolicy,
   ShadowPolicyResult &out
)
{
   InitShadowPolicyResult(out);
   out.policy_state_text = hasRiskPolicy ? riskPolicy.state_text : "UNKNOWN";

   if(hasRiskPolicy && riskPolicy.block_new_trades)
   {
      out.policy_permission = false;
      out.final_permission  = false;
      out.policy_reason     = "risk_state_lockdown";
      return false;
   }

   // Cooldown (read-only)
   if(plan.cooldown_bars > 0)
   {
      int currentBars = Bars(symbol, PERIOD_M1);
      int barsSinceLastEntry = currentBars - lastRuntimeEntryBars;

      if(barsSinceLastEntry <= plan.cooldown_bars)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "cooldown_active";
         return false;
      }
   }

   // Session cap (read-only history)
   if(plan.max_trades_per_session > 0)
   {
      int sessionClosed = SPM_CountSessionClosedTrades(symbol, magic);
      int smartCap      = SPM_ComputeSmartSessionCap(plan, symbol, magic);

      if(smartCap > 0 && sessionClosed >= smartCap)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "session_cap_reached";
         return false;
      }
   }

   // Capacity / One-direction checks (read-only positions)
   int openCount = SPM_CountMyOpenPositions(symbol, magic);
   if(openCount >= plan.max_open_positions)
   {
      out.policy_permission = false;
      out.final_permission  = false;
      out.policy_reason     = "max_open_positions";
      return false;
   }

   if(plan.one_direction_only)
   {
      if(dir == CORE_BUY && SPM_CountMyDirectionPositions(symbol, magic, POSITION_TYPE_BUY) > 0)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "one_direction_only_buy";
         return false;
      }

      if(dir == CORE_SELL && SPM_CountMyDirectionPositions(symbol, magic, POSITION_TYPE_SELL) > 0)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "one_direction_only_sell";
         return false;
      }
   }

   // Regime policy constraints (optional)
   if(plan.regime_policy_enabled && hasRegime)
   {
      if(plan.regime_confidence_min > 0.0 && regime.regime_confidence < plan.regime_confidence_min)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "regime_policy_confidence_below_min";
         return false;
      }

      if(plan.regime_tradability_min > 0.0 && regime.tradability_score < plan.regime_tradability_min)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "regime_policy_tradability_below_min";
         return false;
      }

      if(!RegimeCsvAllows(plan.allowed_regimes, regime.regime_label))
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "regime_policy_not_allowed";
         return false;
      }
   }

   // Risk state tightening is applied by decision-level tightening elsewhere (confidence thresholds).
   out.policy_permission = true;
   out.final_permission  = true;
   out.policy_reason     = "ok";
   return true;
}

bool ShadowPolicyAllowsTradeV2(
   RuntimePlan &plan,
   string symbol,
   ulong magic,
   int lastRuntimeEntryBars,
   CoreDirection dir,
   bool hasRegime,
   RegimeClassification &regime,
   bool hasRiskPolicy,
   RiskPolicySnapshot &riskPolicy,
   double entry_quality_score,
   double strategy_regime_fit_score,
   double entry_edge_score,
   double follow_through_quality_score,
   string entry_quality_label,
   string entry_edge_label,
   ShadowPolicyResult &out
)
{
   // Run base policy mirroring (reusing V1 implementation)
   ShadowPolicyResult base;
   ShadowPolicyAllowsTradeV1(
      plan,
      symbol,
      magic,
      lastRuntimeEntryBars,
      dir,
      hasRegime,
      regime,
      hasRiskPolicy,
      riskPolicy,
      base
   );

   out = base;

   // Strategy Intelligence hooks (optional)
   if(plan.decision_quality_policy_enabled)
   {
      if(plan.minimum_entry_quality_score > 0.0 && entry_quality_score < plan.minimum_entry_quality_score)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "Shadow policy blocks: entry_quality below min";
         return false;
      }

      if(plan.minimum_strategy_regime_fit_score > 0.0 && strategy_regime_fit_score < plan.minimum_strategy_regime_fit_score)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "Shadow policy blocks: strategy_regime_fit below min";
         return false;
      }

      if(plan.minimum_entry_edge_score > 0.0 && entry_edge_score < plan.minimum_entry_edge_score)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "Shadow policy blocks: entry_edge below min";
         return false;
      }

      if(plan.minimum_follow_through_quality_score > 0.0 && follow_through_quality_score < plan.minimum_follow_through_quality_score)
      {
         out.policy_permission = false;
         out.final_permission  = false;
         out.policy_reason     = "Shadow policy blocks: follow_through below min";
         return false;
      }

      if(plan.block_poor_entries)
      {
         if(entry_quality_label == "POOR_ENTRY" || entry_quality_label == "NO_ENTRY_EDGE")
         {
            out.policy_permission = false;
            out.final_permission  = false;
            out.policy_reason     = "Shadow policy blocks: poor entry";
            return false;
         }
      }
   }

   return out.final_permission;
}


#endif
