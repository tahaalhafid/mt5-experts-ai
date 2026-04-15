#ifndef __EVOLUTION_GOVERNOR_MQH__
#define __EVOLUTION_GOVERNOR_MQH__

#include "config_loader.mqh"

//---------------------------------------------------------
// Governor state
//---------------------------------------------------------
struct EvolutionGovernorState
{
   string last_main_trigger_name;
   int    same_trigger_generations;

   bool   force_diversification;
   string banned_trigger_name;

   int    last_observed_trade_count;
   int    consecutive_underperformance_cycles;

   string last_change_scope;   // NONE / SMALL / MEDIUM / MAJOR_TRIGGER
   string last_diagnosis;      // ROOT CAUSE summary
};

//---------------------------------------------------------
// Internal helpers
//---------------------------------------------------------
string Gov_NormalizeScope(string scope)
{
   scope = TrimString(scope);

   if(scope == "SMALL")
      return "SMALL";

   if(scope == "MEDIUM")
      return "MEDIUM";

   if(scope == "MAJOR_TRIGGER")
      return "MAJOR_TRIGGER";

   return "NONE";
}

bool Gov_LoadEvolutionStateSafe(string evolutionStatePath, AIEvolutionState &st)
{
   if(LoadAIEvolutionStateFromJson(evolutionStatePath, st))
      return true;

   LoadDefaultEvolutionState(st);
   return false;
}

bool Gov_IsUnderperformanceSerious(bool underperformance, int observedTradeCount, AIEvolutionState &evState)
{
   if(!underperformance)
      return false;

   return (observedTradeCount >= evState.major_evolution_min_trades);
}

bool Gov_IsMajorScope(string scope)
{
   return (Gov_NormalizeScope(scope) == "MAJOR_TRIGGER");
}

bool Gov_IsMediumScope(string scope)
{
   return (Gov_NormalizeScope(scope) == "MEDIUM");
}

bool Gov_IsSmallScope(string scope)
{
   return (Gov_NormalizeScope(scope) == "SMALL");
}

bool Gov_IsTriggerDiagnosis(string diagnosis)
{
   diagnosis = TrimString(diagnosis);
   return (diagnosis == "TRIGGER_PROBLEM");
}

bool Gov_IsTriggerOrRegimeDiagnosis(string diagnosis)
{
   diagnosis = TrimString(diagnosis);

   if(diagnosis == "TRIGGER_PROBLEM")
      return true;

   if(diagnosis == "REGIME_POLICY_PROBLEM")
      return true;

   return false;
}

string Gov_ScopePermissionText(int observedTradeCount, AIEvolutionState &evState)
{
   if(observedTradeCount < evState.small_evolution_min_trades)
   {
      return
         "NO_CHANGE_WINDOW active. Observed trades are below the small evolution threshold. "
         "Do NOT redesign the plan. Keep the current plan unchanged.";
   }

   if(observedTradeCount < evState.medium_evolution_min_trades)
   {
      return
         "SMALL_CHANGE_ONLY window active. "
         "Allowed changes: thresholds, penalties, bonuses, minor score tuning, confirmation weight tuning. "
         "Do NOT change main_trigger_name. "
         "Do NOT change decision_engine_mode. "
         "Do NOT perform architecture redesign.";
   }

   if(observedTradeCount < evState.major_evolution_min_trades)
   {
      return
         "MEDIUM_CHANGE_WINDOW active. "
         "Allowed changes: SMALL changes plus confirmation structure tuning, filter tuning, regime policy tuning, "
         "moderate score logic tuning. "
         "Do NOT change main_trigger_name unless there is extremely strong explicit diagnosis, "
         "and prefer not to change it in this window.";
   }

   if(observedTradeCount < evState.strong_major_evolution_min_trades)
   {
      return
         "MAJOR_CHANGE_WINDOW active. "
         "Main trigger change is allowed ONLY if diagnosis explicitly concludes that the trigger family itself is weak "
         "or mismatched to the current market environment. "
         "Prefer regime adaptation and confirmation redesign before trigger replacement.";
   }

   return
      "FULL_CHANGE_WINDOW active. "
      "Small, medium, and major changes are allowed, but only when diagnosis clearly supports them. "
      "Do not change the main trigger casually.";
}

string Gov_BuildCoreDiagnosticInstruction()
{
   return
      "PRIMARY OBJECTIVE: improve the strategy, not rotate components randomly. "
      "You must behave as a diagnostic evolution controller. "
      "Before proposing any change, identify the most likely root cause category: "
      "TRIGGER_PROBLEM, CONFIRMATION_PROBLEM, THRESHOLD_PROBLEM, FILTER_PROBLEM, REGIME_POLICY_PROBLEM, EXIT_PROBLEM, "
      "OVERTRADING_PROBLEM, or INSUFFICIENT_SAMPLE. "
      "You must prefer the SMALLEST effective change that addresses the diagnosed root cause. "
      "Do not switch main_trigger_name unless the evidence points specifically to trigger failure or trigger-regime mismatch. "
      "Prefer adapting the plan to market regime and structure before replacing the trigger family. "
      "Changing the trigger is a last-resort structural action, not a default reaction.";
}

//---------------------------------------------------------
// Save / Load
//---------------------------------------------------------
bool SaveEvolutionGovernorState(string relativePath, EvolutionGovernorState &st)
{
   string json = "{";
   json += "\"last_main_trigger_name\":\"" + st.last_main_trigger_name + "\",";
   json += "\"same_trigger_generations\":" + IntegerToString(st.same_trigger_generations) + ",";
   json += "\"force_diversification\":" + string(st.force_diversification ? "true" : "false") + ",";
   json += "\"banned_trigger_name\":\"" + st.banned_trigger_name + "\",";
   json += "\"last_observed_trade_count\":" + IntegerToString(st.last_observed_trade_count) + ",";
   json += "\"consecutive_underperformance_cycles\":" + IntegerToString(st.consecutive_underperformance_cycles) + ",";
   json += "\"last_change_scope\":\"" + st.last_change_scope + "\",";
   json += "\"last_diagnosis\":\"" + st.last_diagnosis + "\"";
   json += "}";

   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, json);
   FileClose(h);
   return true;
}

bool LoadEvolutionGovernorState(string relativePath, EvolutionGovernorState &st)
{
   st.last_main_trigger_name = "";
   st.same_trigger_generations = 0;
   st.force_diversification = false;
   st.banned_trigger_name = "";
   st.last_observed_trade_count = 0;
   st.consecutive_underperformance_cycles = 0;
   st.last_change_scope = "NONE";
   st.last_diagnosis = "";

   string json = "";
   if(!LoadTextFile(relativePath, json))
      return false;

   string s = "";
   bool b = false;
   int i = 0;

   if(ExtractJsonStringField(json, "last_main_trigger_name", s))
      st.last_main_trigger_name = s;

   if(ExtractJsonIntField(json, "same_trigger_generations", i))
      st.same_trigger_generations = i;

   if(ExtractJsonBoolField(json, "force_diversification", b))
      st.force_diversification = b;

   if(ExtractJsonStringField(json, "banned_trigger_name", s))
      st.banned_trigger_name = s;

   if(ExtractJsonIntField(json, "last_observed_trade_count", i))
      st.last_observed_trade_count = i;

   if(ExtractJsonIntField(json, "consecutive_underperformance_cycles", i))
      st.consecutive_underperformance_cycles = i;

   if(ExtractJsonStringField(json, "last_change_scope", s))
      st.last_change_scope = Gov_NormalizeScope(s);

   if(ExtractJsonStringField(json, "last_diagnosis", s))
      st.last_diagnosis = s;

   return true;
}

//---------------------------------------------------------
// Enhanced post-apply update
//---------------------------------------------------------
bool UpdateEvolutionGovernorAfterApplyEx(
   string relativePath,
   string evolutionStatePath,
   string previousTriggerName,
   string newTriggerName,
   int observedTradeCount,
   string appliedChangeScope,
   string diagnosis,
   bool underperformance,
   string &logMessage
)
{
   EvolutionGovernorState st;
   LoadEvolutionGovernorState(relativePath, st);

   AIEvolutionState evState;
   Gov_LoadEvolutionStateSafe(evolutionStatePath, evState);

   previousTriggerName = TrimString(previousTriggerName);
   newTriggerName      = TrimString(newTriggerName);
   appliedChangeScope  = Gov_NormalizeScope(appliedChangeScope);
   diagnosis           = TrimString(diagnosis);

   bool triggerChanged = (previousTriggerName != newTriggerName);

   if(triggerChanged)
      st.same_trigger_generations = 1;
   else
   {
      if(st.last_main_trigger_name == newTriggerName)
         st.same_trigger_generations++;
      else
         st.same_trigger_generations = 1;
   }

   st.last_main_trigger_name    = newTriggerName;
   st.last_observed_trade_count = observedTradeCount;
   st.last_change_scope         = appliedChangeScope;
   st.last_diagnosis            = diagnosis;

   if(underperformance)
      st.consecutive_underperformance_cycles++;
   else
      st.consecutive_underperformance_cycles = 0;

   //------------------------------------------------------
   // Diversification must be rare, diagnostic, and late
   //------------------------------------------------------
   st.force_diversification = false;
   st.banned_trigger_name   = "";

   bool seriousUnderperf = Gov_IsUnderperformanceSerious(underperformance, observedTradeCount, evState);
   bool majorChange      = Gov_IsMajorScope(appliedChangeScope);
   bool structuralDiag   = Gov_IsTriggerOrRegimeDiagnosis(diagnosis);

   if(seriousUnderperf &&
      observedTradeCount >= evState.strong_major_evolution_min_trades &&
      st.consecutive_underperformance_cycles >= 2 &&
      st.same_trigger_generations >= 3 &&
      majorChange &&
      structuralDiag)
   {
      st.force_diversification = true;
      st.banned_trigger_name   = newTriggerName;

      logMessage =
         "Governor: diversification forced after sustained underperformance, repeated trigger persistence, "
         "and structural diagnosis. banned trigger=" + newTriggerName;
   }
   else
   {
      logMessage =
         "Governor: no forced diversification"
         " | trades=" + IntegerToString(observedTradeCount) +
         " | scope=" + appliedChangeScope +
         " | diagnosis=" + diagnosis +
         " | underperf_cycles=" + IntegerToString(st.consecutive_underperformance_cycles);
   }

   return SaveEvolutionGovernorState(relativePath, st);
}

//---------------------------------------------------------
// Backward-compatible old updater
//---------------------------------------------------------
bool UpdateEvolutionGovernorAfterApply(
   string relativePath,
   string newTriggerName,
   bool underperformance,
   string &logMessage
)
{
   EvolutionGovernorState st;
   LoadEvolutionGovernorState(relativePath, st);

   st.last_main_trigger_name = TrimString(newTriggerName);

   if(underperformance)
      st.consecutive_underperformance_cycles++;
   else
      st.consecutive_underperformance_cycles = 0;

   st.same_trigger_generations   = 1;
   st.force_diversification      = false;
   st.banned_trigger_name        = "";
   st.last_observed_trade_count  = 0;
   st.last_change_scope          = "NONE";
   st.last_diagnosis             = "";

   logMessage = "Governor: legacy update applied without advanced diagnostic context";
   return SaveEvolutionGovernorState(relativePath, st);
}

//---------------------------------------------------------
// Enhanced governor instruction
//---------------------------------------------------------
string BuildGovernorInstructionEx(
   string relativePath,
   string evolutionStatePath,
   int observedTradeCount
)
{
   EvolutionGovernorState st;
   LoadEvolutionGovernorState(relativePath, st);

   AIEvolutionState evState;
   Gov_LoadEvolutionStateSafe(evolutionStatePath, evState);

   string instruction = "";

   instruction += Gov_BuildCoreDiagnosticInstruction();
   instruction += " ";
   instruction += Gov_ScopePermissionText(observedTradeCount, evState);
   instruction += " ";

   if(StringLen(TrimString(st.last_diagnosis)) > 0)
   {
      instruction +=
         "Previous governor diagnosis summary: " + st.last_diagnosis + ". ";
   }

   if(st.consecutive_underperformance_cycles > 0)
   {
      instruction +=
         "Observed consecutive underperformance cycles: " +
         IntegerToString(st.consecutive_underperformance_cycles) + ". ";
   }

   if(st.force_diversification && StringLen(st.banned_trigger_name) > 0)
   {
      instruction +=
         "Forced diversification is ACTIVE. You must NOT use main_trigger_name=" +
         st.banned_trigger_name +
         ". Choose a different trigger family only if a major trigger change is already allowed by the current sample window and diagnosis supports it. ";
   }
   else
   {
      instruction +=
         "No forced diversification is active. "
         "Do not switch trigger families unless diagnosis clearly supports that action. ";
   }

   instruction +=
      "Important diagnostic rule: "
      "underperformance alone does NOT prove trigger failure. "
      "First consider thresholds, confirmations, filters, regime policy, and execution tuning before changing the trigger.";

   return instruction;
}

//---------------------------------------------------------
// Backward-compatible old instruction
//---------------------------------------------------------
string BuildGovernorInstruction(string relativePath)
{
   EvolutionGovernorState st;
   if(!LoadEvolutionGovernorState(relativePath, st))
      return "No governor restriction.";

   if(st.force_diversification && StringLen(st.banned_trigger_name) > 0)
   {
      return
         "Forced diversification is ACTIVE. "
         "You must NOT use main_trigger_name=" + st.banned_trigger_name + ".";
   }

   return
      "No forced diversification is active. "
      "Use diagnostic reasoning and avoid random trigger rotation.";
}

#endif
