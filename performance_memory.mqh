#ifndef __PERFORMANCE_MEMORY_MQH__
#define __PERFORMANCE_MEMORY_MQH__

#include "config_loader.mqh"

struct PerformanceSnapshot
{
   int    closed_trades;
   int    wins;
   int    losses;

   int    consecutive_losses;       // current/latest consecutive losses
   int    max_consecutive_losses;   // maximum historical losing streak
   int    consecutive_wins;         // current/latest consecutive wins

   int    recent_closed_trades;     // last recent window
   int    recent_wins;
   int    recent_losses;

   double total_profit;
   double avg_profit_per_trade;
   double win_rate;

   double recent_total_profit;
   double recent_avg_profit;
   double recent_win_rate;

   bool   underperformance;
   string reason;
};

//---------------------------------------------------------
// Internal helper
//---------------------------------------------------------
bool IsMatchingClosedDeal(ulong dealTicket, ulong magic, double &profitOut)
{
   profitOut = 0.0;

   if(dealTicket == 0)
      return false;

   string sym = HistoryDealGetString(dealTicket, DEAL_SYMBOL);
   long   mg  = HistoryDealGetInteger(dealTicket, DEAL_MAGIC);
   long   ent = HistoryDealGetInteger(dealTicket, DEAL_ENTRY);

   if(sym != _Symbol || (ulong)mg != magic)
      return false;

   if(ent != DEAL_ENTRY_OUT)
      return false;

   profitOut = HistoryDealGetDouble(dealTicket, DEAL_PROFIT);
   return true;
}

//---------------------------------------------------------
// Build snapshot
//---------------------------------------------------------
bool BuildPerformanceSnapshot(ulong magic, PerformanceSnapshot &snap)
{
   snap.closed_trades         = 0;
   snap.wins                  = 0;
   snap.losses                = 0;

   snap.consecutive_losses    = 0;
   snap.max_consecutive_losses = 0;
   snap.consecutive_wins      = 0;

   snap.recent_closed_trades  = 0;
   snap.recent_wins           = 0;
   snap.recent_losses         = 0;

   snap.total_profit          = 0.0;
   snap.avg_profit_per_trade  = 0.0;
   snap.win_rate              = 0.0;

   snap.recent_total_profit   = 0.0;
   snap.recent_avg_profit     = 0.0;
   snap.recent_win_rate       = 0.0;

   snap.underperformance      = false;
   snap.reason                = "";

   if(!HistorySelect(0, TimeCurrent()))
   {
      snap.reason = "HistorySelect failed";
      return false;
   }

   int totalDeals = HistoryDealsTotal();
   if(totalDeals <= 0)
   {
      snap.reason = "No history deals";
      return true;
   }

   //------------------------------------------------------
   // First pass: full history metrics
   //------------------------------------------------------
   int runningLossStreak = 0;

   for(int i = totalDeals - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      double profit = 0.0;

      if(!IsMatchingClosedDeal(dealTicket, magic, profit))
         continue;

      snap.closed_trades++;
      snap.total_profit += profit;

      if(profit > 0.0)
      {
         snap.wins++;
         runningLossStreak = 0;
      }
      else if(profit < 0.0)
      {
         snap.losses++;
         runningLossStreak++;

         if(runningLossStreak > snap.max_consecutive_losses)
            snap.max_consecutive_losses = runningLossStreak;
      }
      else
      {
         // flat trade does not count as win/loss streak continuation
         runningLossStreak = 0;
      }
   }

   if(snap.closed_trades > 0)
   {
      snap.avg_profit_per_trade = snap.total_profit / snap.closed_trades;
      snap.win_rate = (100.0 * snap.wins) / snap.closed_trades;
   }

   //------------------------------------------------------
   // Second pass: latest consecutive streaks from most recent deal backward
   //------------------------------------------------------
   bool streakLocked = false;
   int currentLosses = 0;
   int currentWins   = 0;

   for(int i = totalDeals - 1; i >= 0; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      double profit = 0.0;

      if(!IsMatchingClosedDeal(dealTicket, magic, profit))
         continue;

      if(!streakLocked)
      {
         if(profit < 0.0)
         {
            currentLosses++;
         }
         else if(profit > 0.0)
         {
            currentWins++;
         }
         else
         {
            streakLocked = true;
         }

         if(currentLosses > 0 && profit > 0.0)
            streakLocked = true;

         if(currentWins > 0 && profit < 0.0)
            streakLocked = true;
      }
   }

   // Correct overshoot caused by the last breaking trade
   if(currentLosses > 0 && currentWins > 0)
   {
      currentLosses = 0;
      currentWins   = 0;
   }

   snap.consecutive_losses = currentLosses;
   snap.consecutive_wins   = currentWins;

   //------------------------------------------------------
   // Third pass: recent window metrics (last N closed trades)
   //------------------------------------------------------
   const int recentWindow = 12;
   int taken = 0;

   for(int i = totalDeals - 1; i >= 0 && taken < recentWindow; i--)
   {
      ulong dealTicket = HistoryDealGetTicket(i);
      double profit = 0.0;

      if(!IsMatchingClosedDeal(dealTicket, magic, profit))
         continue;

      snap.recent_closed_trades++;
      snap.recent_total_profit += profit;

      if(profit > 0.0)
         snap.recent_wins++;
      else if(profit < 0.0)
         snap.recent_losses++;

      taken++;
   }

   if(snap.recent_closed_trades > 0)
   {
      snap.recent_avg_profit = snap.recent_total_profit / snap.recent_closed_trades;
      snap.recent_win_rate   = (100.0 * snap.recent_wins) / snap.recent_closed_trades;
   }

   //------------------------------------------------------
   // Smarter underperformance logic
   //------------------------------------------------------
   bool recentLossStreak   = (snap.consecutive_losses >= 3);
   bool recentLowWinRate   = (snap.recent_closed_trades >= 6 && snap.recent_win_rate < 40.0);
   bool recentNegativeAvg  = (snap.recent_closed_trades >= 6 && snap.recent_avg_profit < 0.0);
   bool recentNegativePnL  = (snap.recent_closed_trades >= 8 && snap.recent_total_profit < 0.0);

   bool globalLowWinRate   = (snap.closed_trades >= 12 && snap.win_rate < 40.0);
   bool globalNegativeAvg  = (snap.closed_trades >= 10 && snap.avg_profit_per_trade < 0.0);
   bool globalNegativePnL  = (snap.closed_trades >= 15 && snap.total_profit < 0.0);

   snap.underperformance =
      recentLossStreak ||
      recentLowWinRate ||
      recentNegativeAvg ||
      recentNegativePnL ||
      globalLowWinRate ||
      globalNegativeAvg ||
      globalNegativePnL;

   if(recentLossStreak)
      snap.reason = "Recent consecutive losses trigger";
   else if(recentLowWinRate)
      snap.reason = "Recent low win rate trigger";
   else if(recentNegativeAvg)
      snap.reason = "Recent negative average trade trigger";
   else if(recentNegativePnL)
      snap.reason = "Recent negative total profit trigger";
   else if(globalLowWinRate)
      snap.reason = "Global low win rate trigger";
   else if(globalNegativeAvg)
      snap.reason = "Global negative average trade trigger";
   else if(globalNegativePnL)
      snap.reason = "Global negative total profit trigger";
   else
      snap.reason = "Performance normal";

   return true;
}

//---------------------------------------------------------
// To JSON
//---------------------------------------------------------
string PerformanceSnapshotToJson(PerformanceSnapshot &snap)
{
   string json = "{";
   json += "\"closed_trades\":" + IntegerToString(snap.closed_trades) + ",";
   json += "\"wins\":" + IntegerToString(snap.wins) + ",";
   json += "\"losses\":" + IntegerToString(snap.losses) + ",";

   json += "\"consecutive_losses\":" + IntegerToString(snap.consecutive_losses) + ",";
   json += "\"max_consecutive_losses\":" + IntegerToString(snap.max_consecutive_losses) + ",";
   json += "\"consecutive_wins\":" + IntegerToString(snap.consecutive_wins) + ",";

   json += "\"recent_closed_trades\":" + IntegerToString(snap.recent_closed_trades) + ",";
   json += "\"recent_wins\":" + IntegerToString(snap.recent_wins) + ",";
   json += "\"recent_losses\":" + IntegerToString(snap.recent_losses) + ",";

   json += "\"total_profit\":" + DoubleToString(snap.total_profit, 2) + ",";
   json += "\"avg_profit_per_trade\":" + DoubleToString(snap.avg_profit_per_trade, 2) + ",";
   json += "\"win_rate\":" + DoubleToString(snap.win_rate, 2) + ",";

   json += "\"recent_total_profit\":" + DoubleToString(snap.recent_total_profit, 2) + ",";
   json += "\"recent_avg_profit\":" + DoubleToString(snap.recent_avg_profit, 2) + ",";
   json += "\"recent_win_rate\":" + DoubleToString(snap.recent_win_rate, 2) + ",";

   json += "\"underperformance\":" + string(snap.underperformance ? "true" : "false") + ",";
   json += "\"reason\":\"" + snap.reason + "\"";
   json += "}";

   return json;
}

#endif
