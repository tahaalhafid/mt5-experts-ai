#ifndef __LIBRARY_RISK_MODELS_MQH__
#define __LIBRARY_RISK_MODELS_MQH__

struct RiskModelDefinition
{
   string id;
   string display_name;
   string description;
   string suitable_for;
};

#define MAX_RISK_MODELS 24

RiskModelDefinition gRiskModelLibrary[MAX_RISK_MODELS];
int gRiskModelCount = 0;

void AddRiskModelDefinition(
   string id,
   string display_name,
   string description,
   string suitable_for
)
{
   if(gRiskModelCount >= MAX_RISK_MODELS)
      return;

   gRiskModelLibrary[gRiskModelCount].id           = id;
   gRiskModelLibrary[gRiskModelCount].display_name = display_name;
   gRiskModelLibrary[gRiskModelCount].description  = description;
   gRiskModelLibrary[gRiskModelCount].suitable_for = suitable_for;
   gRiskModelCount++;
}

void BuildRiskModelLibrary()
{
   gRiskModelCount = 0;

   AddRiskModelDefinition(
      "atr_stop_rr_exit",
      "ATR Stop + Fixed RR Exit",
      "Uses ATR-based stop placement and fixed risk-reward ratio for target calculation.",
      "General purpose scalping and structured systems"
   );

   AddRiskModelDefinition(
      "middle_band_reversion_exit",
      "Middle Band Reversion Exit",
      "Uses Bollinger middle band as a practical reversion target for mean-reversion setups.",
      "Bollinger mean reversion systems"
   );

   AddRiskModelDefinition(
      "opposite_band_exit",
      "Opposite Band Exit",
      "Targets the opposite Bollinger band when expecting full band traversal.",
      "Strong mean reversion or expansion reversal systems"
   );

   AddRiskModelDefinition(
      "time_exit_with_move_sl",
      "Time Exit + Move SL",
      "Closes stale trades after a defined time and moves SL when a portion of target is reached.",
      "Short holding scalping systems"
   );

   AddRiskModelDefinition(
      "break_even_shift",
      "Break Even Shift",
      "Moves stop loss to break-even after a defined favorable move.",
      "Momentum and breakout systems"
   );

   AddRiskModelDefinition(
      "partial_scale_out",
      "Partial Scale Out",
      "Closes part of the position at earlier target and leaves remainder for extended run.",
      "Layered exit systems"
   );

   AddRiskModelDefinition(
      "trailing_progressive_exit",
      "Trailing Progressive Exit",
      "Adjusts exit progressively as trade moves in favor, typically for continuation setups.",
      "Breakout and trend continuation systems"
   );
}

bool GetRiskModelDefinitionById(string id, RiskModelDefinition &outDef)
{
   for(int i = 0; i < gRiskModelCount; i++)
   {
      if(gRiskModelLibrary[i].id == id)
      {
         outDef = gRiskModelLibrary[i];
         return true;
      }
   }
   return false;
}

#endif



