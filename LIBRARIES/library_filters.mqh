#ifndef __LIBRARY_FILTERS_MQH__
#define __LIBRARY_FILTERS_MQH__

struct FilterDefinition
{
   string id;
   string display_name;
   string description;
   bool   is_hard_filter;
};

#define MAX_FILTERS 24

FilterDefinition gFilterLibrary[MAX_FILTERS];
int gFilterCount = 0;

void AddFilterDefinition(
   string id,
   string display_name,
   string description,
   bool is_hard_filter
)
{
   if(gFilterCount >= MAX_FILTERS)
      return;

   gFilterLibrary[gFilterCount].id           = id;
   gFilterLibrary[gFilterCount].display_name = display_name;
   gFilterLibrary[gFilterCount].description  = description;
   gFilterLibrary[gFilterCount].is_hard_filter = is_hard_filter;
   gFilterCount++;
}

void BuildFilterLibrary()
{
   gFilterCount = 0;

   AddFilterDefinition(
      "spread_filter",
      "Spread Filter",
      "Rejects execution when current spread exceeds allowed threshold.",
      true
   );

   AddFilterDefinition(
      "atr_volatility_filter",
      "ATR Volatility Filter",
      "Rejects setups when volatility is too low for the intended style.",
      true
   );

   AddFilterDefinition(
      "trend_alignment_filter",
      "Trend Alignment Filter",
      "Requires directional consistency with prevailing trend.",
      false
   );

   AddFilterDefinition(
      "higher_timeframe_agreement_filter",
      "Higher Timeframe Agreement Filter",
      "Requires structural support or lack of major conflict from higher timeframe.",
      false
   );

   AddFilterDefinition(
      "flat_market_filter",
      "Flat Market Filter",
      "Avoids entries in narrow, indecisive, or structurally low-energy conditions.",
      true
   );

   AddFilterDefinition(
      "breakout_risk_filter",
      "Breakout Risk Filter",
      "Rejects mean-reversion setups that look more like genuine continuation breakouts.",
      false
   );

   AddFilterDefinition(
      "session_activity_filter",
      "Session Activity Filter",
      "Avoids dead session periods or periods with poor participation.",
      false
   );

   AddFilterDefinition(
      "position_limit_filter",
      "Position Limit Filter",
      "Stops new entries when max position logic is reached.",
      true
   );

   AddFilterDefinition(
      "cooldown_filter",
      "Cooldown Filter",
      "Blocks immediate re-entry for a defined number of bars after execution.",
      true
   );
}

bool GetFilterDefinitionById(string id, FilterDefinition &outDef)
{
   for(int i = 0; i < gFilterCount; i++)
   {
      if(gFilterLibrary[i].id == id)
      {
         outDef = gFilterLibrary[i];
         return true;
      }
   }
   return false;
}

#endif

