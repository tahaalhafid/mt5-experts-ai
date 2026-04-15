#ifndef __LIBRARY_STRATEGIES_MQH__
#define __LIBRARY_STRATEGIES_MQH__

struct StrategyDefinition
{
   string id;
   string display_name;
   string description;
   string market_type;
   string preferred_main_trigger;
   string required_indicator_ids[8];
   int    required_indicator_count;
   string preferred_entry_patterns[6];
   int    preferred_entry_patterns_count;
   string preferred_risk_models[6];
   int    preferred_risk_models_count;
};

#define MAX_STRATEGIES 32

StrategyDefinition gStrategyLibrary[MAX_STRATEGIES];
int gStrategyCount = 0;

void AddStrategyDefinition(
   string id,
   string display_name,
   string description,
   string market_type,
   string preferred_main_trigger
)
{
   if(gStrategyCount >= MAX_STRATEGIES)
      return;

   gStrategyLibrary[gStrategyCount].id                     = id;
   gStrategyLibrary[gStrategyCount].display_name           = display_name;
   gStrategyLibrary[gStrategyCount].description            = description;
   gStrategyLibrary[gStrategyCount].market_type            = market_type;
   gStrategyLibrary[gStrategyCount].preferred_main_trigger = preferred_main_trigger;
   gStrategyLibrary[gStrategyCount].required_indicator_count = 0;
   gStrategyLibrary[gStrategyCount].preferred_entry_patterns_count = 0;
   gStrategyLibrary[gStrategyCount].preferred_risk_models_count = 0;

   gStrategyCount++;
}

void AddStrategyIndicator(string strategy_id, string indicator_id)
{
   for(int i = 0; i < gStrategyCount; i++)
   {
      if(gStrategyLibrary[i].id == strategy_id)
      {
         int idx = gStrategyLibrary[i].required_indicator_count;
         if(idx < 8)
         {
            gStrategyLibrary[i].required_indicator_ids[idx] = indicator_id;
            gStrategyLibrary[i].required_indicator_count++;
         }
         return;
      }
   }
}

void AddStrategyEntryPattern(string strategy_id, string pattern_id)
{
   for(int i = 0; i < gStrategyCount; i++)
   {
      if(gStrategyLibrary[i].id == strategy_id)
      {
         int idx = gStrategyLibrary[i].preferred_entry_patterns_count;
         if(idx < 6)
         {
            gStrategyLibrary[i].preferred_entry_patterns[idx] = pattern_id;
            gStrategyLibrary[i].preferred_entry_patterns_count++;
         }
         return;
      }
   }
}

void AddStrategyRiskModel(string strategy_id, string model_id)
{
   for(int i = 0; i < gStrategyCount; i++)
   {
      if(gStrategyLibrary[i].id == strategy_id)
      {
         int idx = gStrategyLibrary[i].preferred_risk_models_count;
         if(idx < 6)
         {
            gStrategyLibrary[i].preferred_risk_models[idx] = model_id;
            gStrategyLibrary[i].preferred_risk_models_count++;
         }
         return;
      }
   }
}

void BuildStrategyLibrary()
{
   gStrategyCount = 0;

   AddStrategyDefinition(
      "bollinger_mean_reversion",
      "Bollinger Mean Reversion",
      "Uses Bollinger band extremes as locations for reversion toward equilibrium, especially after exhaustion.",
      "ranging_or_overextended",
      "bollinger_reclaim_trigger"
   );
   AddStrategyIndicator("bollinger_mean_reversion", "bollinger_reclaim_trigger");
   AddStrategyIndicator("bollinger_mean_reversion", "mfi_momentum");
   AddStrategyIndicator("bollinger_mean_reversion", "atr_volatility_filter");
   AddStrategyEntryPattern("bollinger_mean_reversion", "pullback_entry");
   AddStrategyEntryPattern("bollinger_mean_reversion", "reclaim_entry");
   AddStrategyRiskModel("bollinger_mean_reversion", "middle_band_reversion_exit");
   AddStrategyRiskModel("bollinger_mean_reversion", "atr_stop_rr_exit");

   AddStrategyDefinition(
      "bollinger_reclaim_reversal",
      "Bollinger Reclaim Reversal",
      "Waits for price excursion beyond a Bollinger edge and then reclaim inside the band with directional confirmation.",
      "volatile_reversal",
      "bollinger_reclaim_trigger"
   );
   AddStrategyIndicator("bollinger_reclaim_reversal", "bollinger_reclaim_trigger");
   AddStrategyIndicator("bollinger_reclaim_reversal", "sweep_detector");
   AddStrategyIndicator("bollinger_reclaim_reversal", "candle_rejection_validation");
   AddStrategyIndicator("bollinger_reclaim_reversal", "mfi_momentum");
   AddStrategyEntryPattern("bollinger_reclaim_reversal", "reclaim_entry");
   AddStrategyEntryPattern("bollinger_reclaim_reversal", "breakout_entry");
   AddStrategyRiskModel("bollinger_reclaim_reversal", "atr_stop_rr_exit");
   AddStrategyRiskModel("bollinger_reclaim_reversal", "time_exit_with_move_sl");

   AddStrategyDefinition(
      "sweep_reversal",
      "Sweep Reversal",
      "Seeks reversal after price runs liquidity above or below a recent swing and fails to continue.",
      "liquidity_reversal",
      "sweep_detector"
   );
   AddStrategyIndicator("sweep_reversal", "sweep_detector");
   AddStrategyIndicator("sweep_reversal", "reclaim_detector");
   AddStrategyIndicator("sweep_reversal", "candle_rejection_validation");
   AddStrategyIndicator("sweep_reversal", "mfi_momentum");
   AddStrategyEntryPattern("sweep_reversal", "reclaim_entry");
   AddStrategyEntryPattern("sweep_reversal", "pullback_entry");
   AddStrategyRiskModel("sweep_reversal", "atr_stop_rr_exit");
   AddStrategyRiskModel("sweep_reversal", "time_exit_with_move_sl");

   AddStrategyDefinition(
      "trend_pullback",
      "Trend Pullback",
      "Trades short retracements in the direction of prevailing trend when momentum resumes.",
      "trending",
      "ema_trend_alignment"
   );
   AddStrategyIndicator("trend_pullback", "ema_trend_alignment");
   AddStrategyIndicator("trend_pullback", "atr_volatility_filter");
   AddStrategyIndicator("trend_pullback", "mfi_momentum");
   AddStrategyEntryPattern("trend_pullback", "pullback_entry");
   AddStrategyEntryPattern("trend_pullback", "breakout_entry");
   AddStrategyRiskModel("trend_pullback", "atr_stop_rr_exit");
   AddStrategyRiskModel("trend_pullback", "time_exit_with_move_sl");

   AddStrategyDefinition(
      "breakout_continuation",
      "Breakout Continuation",
      "Seeks continuation after compression or structural release when price breaks and holds direction.",
      "expansion",
      "range_compression_state"
   );
   AddStrategyIndicator("breakout_continuation", "range_compression_state");
   AddStrategyIndicator("breakout_continuation", "volume_spike_context");
   AddStrategyIndicator("breakout_continuation", "atr_volatility_filter");
   AddStrategyEntryPattern("breakout_continuation", "breakout_entry");
   AddStrategyEntryPattern("breakout_continuation", "staged_entry");
   AddStrategyRiskModel("breakout_continuation", "atr_stop_rr_exit");
   AddStrategyRiskModel("breakout_continuation", "trailing_progressive_exit");

   AddStrategyDefinition(
      "dual_timeframe_reclaim",
      "Dual Timeframe Reclaim",
      "Uses fast timeframe trigger with higher timeframe structural alignment and reclaim behavior.",
      "hybrid",
      "bollinger_reclaim_trigger"
   );
   AddStrategyIndicator("dual_timeframe_reclaim", "bollinger_reclaim_trigger");
   AddStrategyIndicator("dual_timeframe_reclaim", "ema_trend_alignment");
   AddStrategyIndicator("dual_timeframe_reclaim", "sweep_detector");
   AddStrategyIndicator("dual_timeframe_reclaim", "mfi_momentum");
   AddStrategyEntryPattern("dual_timeframe_reclaim", "reclaim_entry");
   AddStrategyEntryPattern("dual_timeframe_reclaim", "pullback_entry");
   AddStrategyRiskModel("dual_timeframe_reclaim", "atr_stop_rr_exit");
   AddStrategyRiskModel("dual_timeframe_reclaim", "time_exit_with_move_sl");
}

bool GetStrategyDefinitionById(string id, StrategyDefinition &outDef)
{
   for(int i = 0; i < gStrategyCount; i++)
   {
      if(gStrategyLibrary[i].id == id)
      {
         outDef = gStrategyLibrary[i];
         return true;
      }
   }
   return false;
}

#endif




