#ifndef __LIBRARY_ENTRY_PATTERNS_MQH__
#define __LIBRARY_ENTRY_PATTERNS_MQH__

struct EntryPatternDefinition
{
   string id;
   string display_name;
   string description;
   string use_case;
   string pros;
   string cons;
};

#define MAX_ENTRY_PATTERNS 24

EntryPatternDefinition gEntryPatternLibrary[MAX_ENTRY_PATTERNS];
int gEntryPatternCount = 0;

void AddEntryPatternDefinition(
   string id,
   string display_name,
   string description,
   string use_case,
   string pros,
   string cons
)
{
   if(gEntryPatternCount >= MAX_ENTRY_PATTERNS)
      return;

   gEntryPatternLibrary[gEntryPatternCount].id          = id;
   gEntryPatternLibrary[gEntryPatternCount].display_name= display_name;
   gEntryPatternLibrary[gEntryPatternCount].description = description;
   gEntryPatternLibrary[gEntryPatternCount].use_case    = use_case;
   gEntryPatternLibrary[gEntryPatternCount].pros        = pros;
   gEntryPatternLibrary[gEntryPatternCount].cons        = cons;
   gEntryPatternCount++;
}

void BuildEntryPatternLibrary()
{
   gEntryPatternCount = 0;

   AddEntryPatternDefinition(
      "close_bar_entry",
      "Close Bar Entry",
      "Executes after a setup candle has fully closed and validated the trigger.",
      "Stable confirmation environments",
      "More stable and explainable",
      "Can miss better intra-bar prices"
   );

   AddEntryPatternDefinition(
      "pullback_entry",
      "Pullback Entry",
      "Arms a setup after confirmation, then enters on a partial retrace for improved price.",
      "Mean reversion and reclaim models",
      "Better entry price and smaller risk",
      "May miss runaway moves"
   );

   AddEntryPatternDefinition(
      "breakout_entry",
      "Breakout Entry",
      "Arms a setup and enters when price breaks beyond a signal candle threshold.",
      "Momentum continuation and reclaim extension",
      "Captures strong continuation moves",
      "Higher risk of false breaks"
   );

   AddEntryPatternDefinition(
      "reclaim_entry",
      "Reclaim Entry",
      "Enters when price first returns back into a zone after being temporarily outside it.",
      "Sweep and reclaim strategies",
      "Excellent for structural reversals",
      "Needs precise zone logic"
   );

   AddEntryPatternDefinition(
      "retest_entry",
      "Retest Entry",
      "Waits for price to break a level and then retest it before entry.",
      "Breakout and continuation setups",
      "Reduces fake breakout risk",
      "May be late"
   );

   AddEntryPatternDefinition(
      "staged_entry",
      "Staged Entry",
      "Splits entry across multiple levels or multiple phases of confirmation.",
      "High volatility conditions",
      "Flexible and adaptive",
      "More complex execution"
   );

   AddEntryPatternDefinition(
      "stacked_entry",
      "Stacked Entry",
      "Allows multiple small entries to build a position if structure remains valid.",
      "Aggressive scalping or scaling models",
      "Improves flexibility",
      "Can overexpose if not controlled"
   );

   AddEntryPatternDefinition(
      "intra_candle_trigger_entry",
      "Intra Candle Trigger Entry",
      "Analyzes setup on candle close, then executes live within the next candle as conditions appear.",
      "Fast scalping and hybrid entry models",
      "Best balance between stability and speed",
      "Requires more runtime logic"
   );

   AddEntryPatternDefinition(
      "candle_rejection_validation",
      "Candle Rejection Validation",
      "Not a direct entry mode but a validation layer that requires rejection behavior before allowing entry.",
      "Reversal systems",
      "Improves quality",
      "May reduce trade frequency"
   );
}

bool GetEntryPatternDefinitionById(string id, EntryPatternDefinition &outDef)
{
   for(int i = 0; i < gEntryPatternCount; i++)
   {
      if(gEntryPatternLibrary[i].id == id)
      {
         outDef = gEntryPatternLibrary[i];
         return true;
      }
   }
   return false;
}

#endif



