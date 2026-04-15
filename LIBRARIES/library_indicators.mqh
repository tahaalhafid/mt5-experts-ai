#ifndef __LIBRARY_INDICATORS_MQH__
#define __LIBRARY_INDICATORS_MQH__

enum IndicatorRole
{
   IND_ROLE_MAIN_TRIGGER = 0,
   IND_ROLE_CONFIRMATION = 1,
   IND_ROLE_FILTER       = 2,
   IND_ROLE_CONTEXT      = 3
};

struct IndicatorDefinition
{
   string        id;
   string        display_name;
   string        description;
   IndicatorRole primary_role;
   bool          can_be_main_trigger;
   bool          can_be_confirmation;
   bool          can_be_filter;
};

#define MAX_INDICATORS 64

IndicatorDefinition gIndicatorLibrary[MAX_INDICATORS];
int gIndicatorCount = 0;

void AddIndicatorDefinition(
   string id,
   string display_name,
   string description,
   IndicatorRole primary_role,
   bool can_be_main_trigger,
   bool can_be_confirmation,
   bool can_be_filter
)
{
   if(gIndicatorCount >= MAX_INDICATORS)
      return;

   gIndicatorLibrary[gIndicatorCount].id                   = id;
   gIndicatorLibrary[gIndicatorCount].display_name         = display_name;
   gIndicatorLibrary[gIndicatorCount].description          = description;
   gIndicatorLibrary[gIndicatorCount].primary_role         = primary_role;
   gIndicatorLibrary[gIndicatorCount].can_be_main_trigger  = can_be_main_trigger;
   gIndicatorLibrary[gIndicatorCount].can_be_confirmation  = can_be_confirmation;
   gIndicatorLibrary[gIndicatorCount].can_be_filter        = can_be_filter;
   gIndicatorCount++;
}

void BuildIndicatorLibrary()
{
   gIndicatorCount = 0;

   AddIndicatorDefinition(
      "bollinger_reclaim_trigger",
      "Bollinger Reclaim Trigger",
      "Main structural trigger based on touching or penetrating Bollinger Bands and reclaiming back inside.",
      IND_ROLE_MAIN_TRIGGER,
      true, true, false
   );

   AddIndicatorDefinition(
      "bollinger_mean_reversion_bias",
      "Bollinger Mean Reversion Bias",
      "Detects tendency for price to revert toward Bollinger middle band after extreme deviation.",
      IND_ROLE_CONFIRMATION,
      false, true, false
   );

   AddIndicatorDefinition(
      "mfi_momentum",
      "Money Flow Index Momentum",
      "Measures momentum and pressure shifts using price and volume-like flow behavior.",
      IND_ROLE_CONFIRMATION,
      false, true, true
   );

   AddIndicatorDefinition(
      "ema_trend_alignment",
      "EMA Trend Alignment",
      "Checks directional alignment between fast EMA, slow EMA, and price structure.",
      IND_ROLE_CONFIRMATION,
      false, true, true
   );

   AddIndicatorDefinition(
      "atr_volatility_filter",
      "ATR Volatility Filter",
      "Rejects setups when market volatility is too weak or structurally unsuitable.",
      IND_ROLE_FILTER,
      false, true, true
   );

   AddIndicatorDefinition(
      "sweep_detector",
      "Liquidity Sweep Detector",
      "Detects taking of prior highs or lows followed by reclaim or directional rejection.",
      IND_ROLE_CONFIRMATION,
      true, true, false
   );

   AddIndicatorDefinition(
      "reclaim_detector",
      "Reclaim Detector",
      "Detects price returning back inside a key zone after temporary excursion beyond it.",
      IND_ROLE_CONFIRMATION,
      true, true, false
   );

   AddIndicatorDefinition(
      "candle_rejection_validation",
      "Candle Rejection Validation",
      "Validates long wick rejection or strong reversal-style candle behavior.",
      IND_ROLE_CONFIRMATION,
      false, true, false
   );

   AddIndicatorDefinition(
      "vwap_deviation_bias",
      "VWAP Deviation Bias",
      "Measures deviation from VWAP to identify overextension and mean-reversion potential.",
      IND_ROLE_CONFIRMATION,
      true, true, true
   );

   AddIndicatorDefinition(
      "rsi_pressure_shift",
      "RSI Pressure Shift",
      "Tracks internal momentum shift and overbought/oversold recovery patterns.",
      IND_ROLE_CONFIRMATION,
      false, true, true
   );

   AddIndicatorDefinition(
      "session_volatility_state",
      "Session Volatility State",
      "Classifies whether the current session environment is expansion, contraction, or flat.",
      IND_ROLE_CONTEXT,
      false, true, true
   );

   AddIndicatorDefinition(
      "volume_spike_context",
      "Volume Spike Context",
      "Flags abnormal participation bursts that may support breakout or rejection behavior.",
      IND_ROLE_CONFIRMATION,
      false, true, true
   );

   AddIndicatorDefinition(
      "range_compression_state",
      "Range Compression State",
      "Detects narrow compression states that can precede expansion or fakeouts.",
      IND_ROLE_CONTEXT,
      false, true, true
   );
}

bool GetIndicatorDefinitionById(string id, IndicatorDefinition &outDef)
{
   for(int i = 0; i < gIndicatorCount; i++)
   {
      if(gIndicatorLibrary[i].id == id)
      {
         outDef = gIndicatorLibrary[i];
         return true;
      }
   }
   return false;
}

#endif













