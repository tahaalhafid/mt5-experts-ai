#ifndef __PLAN_VALIDATOR_MQH__
#define __PLAN_VALIDATOR_MQH__

#include "config_loader.mqh"

struct PlanValidationResult
{
   bool   valid;
   string reason;
};

bool ContainsKey(const string json, const string key)
{
   return (StringFind(json, "\"" + key + "\"") >= 0);
}

bool IsAllowedMainTrigger(const string v)
{
   return (v == "bollinger_reclaim_trigger" ||
           v == "sweep_detector" ||
           v == "ema_trend_alignment");
}

bool IsAllowedAggressionLevel(const string v)
{
   return (v == "LOW" || v == "NORMAL" || v == "HIGH");
}

bool IsAllowedExecutionMode(const string v)
{
   return (v == "NORMAL" || v == "CONSERVATIVE" || v == "AGGRESSIVE");
}

bool IsAllowedRegimeTrend(const string v)
{
   return (v == "ANY" ||
           v == "TREND_ONLY" ||
           v == "RANGE_ONLY" ||
           v == "TREND_BULL" ||
           v == "TREND_BEAR");
}

bool IsAllowedRegimeVolatility(const string v)
{
   return (v == "ANY" ||
           v == "HIGH_VOL" ||
           v == "NORMAL_VOL" ||
           v == "LOW_VOL");
}

bool IsAllowedRegimeStructure(const string v)
{
   return (v == "ANY" ||
           v == "CLEAN" ||
           v == "NOISY");
}

bool IsAllowedSpreadPolicyMode(const string v)
{
   return (v == "FLEXIBLE" ||
           v == "NORMAL" ||
           v == "STRICT");
}

bool IsAllowedPlanMode(const string v)
{
   return (v == "LEGACY" ||
           v == "WEIGHTED" ||
           v == "LAB" ||
           v == "HYBRID");
}

bool IsAllowedExecutionArchetype(const string v)
{
   return (v == "SCALP" ||
           v == "INTRADAY" ||
           v == "HYBRID" ||
           v == "EXPERIMENTAL");
}

bool IsAllowedDecisionEngineMode(const string v)
{
   return (v == "GATE" ||
           v == "SCORE" ||
           v == "HYBRID");
}

bool IsAllowedBiasDirection(const string v)
{
   return (v == "BOTH" ||
           v == "BUY_ONLY" ||
           v == "SELL_ONLY" ||
           v == "AUTO");
}

bool ValidateRange01(const string fieldName, double value, PlanValidationResult &res)
{
   if(value < 0.0 || value > 1.0)
   {
      res.reason = fieldName + " out of range";
      return false;
   }
   return true;
}

bool ValidatePositiveRange(const string fieldName, double value, double minVal, double maxVal, PlanValidationResult &res)
{
   if(value < minVal || value > maxVal)
   {
      res.reason = fieldName + " out of range";
      return false;
   }
   return true;
}

bool ValidatePlanJsonBasic(string planJson, PlanValidationResult &res)
{
   res.valid  = false;
   res.reason = "";

   if(StringLen(planJson) < 50)
   {
      res.reason = "Plan JSON too short";
      return false;
   }

   //------------------------------------------------------
   // Required keys
   //------------------------------------------------------
   string requiredKeys[50];
   requiredKeys[0]  = "plan_id";
   requiredKeys[1]  = "enabled";
   requiredKeys[2]  = "main_timeframe";
   requiredKeys[3]  = "confirmation_timeframe";
   requiredKeys[4]  = "main_trigger_name";
   requiredKeys[5]  = "strong_confirmations";
   requiredKeys[6]  = "medium_confirmations";
   requiredKeys[7]  = "required_filters";
   requiredKeys[8]  = "entry_patterns";
   requiredKeys[9]  = "pullback_ratio";
   requiredKeys[10] = "breakout_buffer_points";
   requiredKeys[11] = "signal_expiry_bars";
   requiredKeys[12] = "atr_multiplier";
   requiredKeys[13] = "risk_reward";
   requiredKeys[14] = "time_exit_minutes";
   requiredKeys[15] = "move_sl_20_to_10";
   requiredKeys[16] = "max_open_positions";
   requiredKeys[17] = "one_direction_only";
   requiredKeys[18] = "cooldown_bars";
   requiredKeys[19] = "use_spread_filter";
   requiredKeys[20] = "max_spread_points";

   // Phase 5
   requiredKeys[21] = "signal_quality_threshold";
   requiredKeys[22] = "minimum_confirmation_score";
   requiredKeys[23] = "aggression_level";
   requiredKeys[24] = "execution_mode";
   requiredKeys[25] = "allow_counter_trend";
   requiredKeys[26] = "max_trades_per_session";
   requiredKeys[27] = "allowed_regime_trend";
   requiredKeys[28] = "allowed_regime_volatility";
   requiredKeys[29] = "allowed_regime_structure";
   requiredKeys[30] = "spread_policy_mode";

   // AI Experiment Designer
   requiredKeys[31] = "plan_mode";
   requiredKeys[32] = "execution_archetype";
   requiredKeys[33] = "decision_engine_mode";
   requiredKeys[34] = "bias_direction";
   requiredKeys[35] = "use_soft_filters";
   requiredKeys[36] = "use_hard_blocks";
   requiredKeys[37] = "require_main_trigger";
   requiredKeys[38] = "allow_triggerless_entry";
   requiredKeys[39] = "score_entry_threshold";
   requiredKeys[40] = "score_reject_threshold";
   requiredKeys[41] = "hard_block_penalty";
   requiredKeys[42] = "soft_filter_penalty";
   requiredKeys[43] = "counter_trend_penalty";
   requiredKeys[44] = "spread_penalty_multiplier";
   requiredKeys[45] = "regime_alignment_bonus";
   requiredKeys[46] = "regime_misalignment_penalty";
   requiredKeys[47] = "trigger_missing_penalty";
   requiredKeys[48] = "confirmation_bonus_multiplier";
   requiredKeys[49] = "trigger_bonus_multiplier";

   for(int i = 0; i < 50; i++)
   {
      if(!ContainsKey(planJson, requiredKeys[i]))
      {
         res.reason = "Missing " + requiredKeys[i];
         return false;
      }
   }

   if(!ContainsKey(planJson, "filter_penalty_multiplier"))
   {
      res.reason = "Missing filter_penalty_multiplier";
      return false;
   }

   if(!ContainsKey(planJson, "environment_bonus_multiplier"))
   {
      res.reason = "Missing environment_bonus_multiplier";
      return false;
   }

   if(!ContainsKey(planJson, "regime_bonus_trend"))
   {
      res.reason = "Missing regime_bonus_trend";
      return false;
   }

   if(!ContainsKey(planJson, "regime_bonus_volatility"))
   {
      res.reason = "Missing regime_bonus_volatility";
      return false;
   }

   if(!ContainsKey(planJson, "regime_bonus_structure"))
   {
      res.reason = "Missing regime_bonus_structure";
      return false;
   }

   if(!ContainsKey(planJson, "regime_penalty_trend"))
   {
      res.reason = "Missing regime_penalty_trend";
      return false;
   }

   if(!ContainsKey(planJson, "regime_penalty_volatility"))
   {
      res.reason = "Missing regime_penalty_volatility";
      return false;
   }

   if(!ContainsKey(planJson, "regime_penalty_structure"))
   {
      res.reason = "Missing regime_penalty_structure";
      return false;
   }

   if(!ContainsKey(planJson, "experiment_family"))
   {
      res.reason = "Missing experiment_family";
      return false;
   }

   if(!ContainsKey(planJson, "experiment_note"))
   {
      res.reason = "Missing experiment_note";
      return false;
   }

   //------------------------------------------------------
   // String enum validations
   //------------------------------------------------------
   string s = "";

   if(!ExtractJsonStringField(planJson, "main_trigger_name", s))
   {
      res.reason = "Invalid main_trigger_name";
      return false;
   }
   if(!IsAllowedMainTrigger(s))
   {
      res.reason = "Unsupported main_trigger_name: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "aggression_level", s))
   {
      res.reason = "Invalid aggression_level";
      return false;
   }
   if(!IsAllowedAggressionLevel(s))
   {
      res.reason = "Unsupported aggression_level: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "execution_mode", s))
   {
      res.reason = "Invalid execution_mode";
      return false;
   }
   if(!IsAllowedExecutionMode(s))
   {
      res.reason = "Unsupported execution_mode: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "allowed_regime_trend", s))
   {
      res.reason = "Invalid allowed_regime_trend";
      return false;
   }
   if(!IsAllowedRegimeTrend(s))
   {
      res.reason = "Unsupported allowed_regime_trend: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "allowed_regime_volatility", s))
   {
      res.reason = "Invalid allowed_regime_volatility";
      return false;
   }
   if(!IsAllowedRegimeVolatility(s))
   {
      res.reason = "Unsupported allowed_regime_volatility: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "allowed_regime_structure", s))
   {
      res.reason = "Invalid allowed_regime_structure";
      return false;
   }
   if(!IsAllowedRegimeStructure(s))
   {
      res.reason = "Unsupported allowed_regime_structure: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "spread_policy_mode", s))
   {
      res.reason = "Invalid spread_policy_mode";
      return false;
   }
   if(!IsAllowedSpreadPolicyMode(s))
   {
      res.reason = "Unsupported spread_policy_mode: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "plan_mode", s))
   {
      res.reason = "Invalid plan_mode";
      return false;
   }
   if(!IsAllowedPlanMode(s))
   {
      res.reason = "Unsupported plan_mode: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "execution_archetype", s))
   {
      res.reason = "Invalid execution_archetype";
      return false;
   }
   if(!IsAllowedExecutionArchetype(s))
   {
      res.reason = "Unsupported execution_archetype: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "decision_engine_mode", s))
   {
      res.reason = "Invalid decision_engine_mode";
      return false;
   }
   if(!IsAllowedDecisionEngineMode(s))
   {
      res.reason = "Unsupported decision_engine_mode: " + s;
      return false;
   }

   if(!ExtractJsonStringField(planJson, "bias_direction", s))
   {
      res.reason = "Invalid bias_direction";
      return false;
   }
   if(!IsAllowedBiasDirection(s))
   {
      res.reason = "Unsupported bias_direction: " + s;
      return false;
   }

   //------------------------------------------------------
   // Numeric sanity checks
   //------------------------------------------------------
   double d = 0.0;
   int    i = 0;
   bool   b = false;

   if(!ExtractJsonDoubleField(planJson, "pullback_ratio", d))
   {
      res.reason = "Invalid pullback_ratio";
      return false;
   }
   if(d < 0.0 || d > 1.0)
   {
      res.reason = "pullback_ratio out of range";
      return false;
   }

   if(!ExtractJsonDoubleField(planJson, "breakout_buffer_points", d))
   {
      res.reason = "Invalid breakout_buffer_points";
      return false;
   }
   if(d < 0.0 || d > 100000.0)
   {
      res.reason = "breakout_buffer_points out of range";
      return false;
   }

   if(!ExtractJsonIntField(planJson, "signal_expiry_bars", i))
   {
      res.reason = "Invalid signal_expiry_bars";
      return false;
   }
   if(i < 1 || i > 200)
   {
      res.reason = "signal_expiry_bars out of range";
      return false;
   }

   if(!ExtractJsonDoubleField(planJson, "atr_multiplier", d))
   {
      res.reason = "Invalid atr_multiplier";
      return false;
   }
   if(d <= 0.0 || d > 20.0)
   {
      res.reason = "atr_multiplier out of range";
      return false;
   }

   if(!ExtractJsonDoubleField(planJson, "risk_reward", d))
   {
      res.reason = "Invalid risk_reward";
      return false;
   }
   if(d <= 0.0 || d > 20.0)
   {
      res.reason = "risk_reward out of range";
      return false;
   }

   if(!ExtractJsonIntField(planJson, "time_exit_minutes", i))
   {
      res.reason = "Invalid time_exit_minutes";
      return false;
   }
   if(i < 1 || i > 1440)
   {
      res.reason = "time_exit_minutes out of range";
      return false;
   }

   if(!ExtractJsonIntField(planJson, "max_open_positions", i))
   {
      res.reason = "Invalid max_open_positions";
      return false;
   }
   if(i < 1 || i > 20)
   {
      res.reason = "max_open_positions out of range";
      return false;
   }

   if(!ExtractJsonIntField(planJson, "cooldown_bars", i))
   {
      res.reason = "Invalid cooldown_bars";
      return false;
   }
   if(i < 0 || i > 500)
   {
      res.reason = "cooldown_bars out of range";
      return false;
   }

   if(!ExtractJsonDoubleField(planJson, "max_spread_points", d))
   {
      res.reason = "Invalid max_spread_points";
      return false;
   }
   if(d < 0.0 || d > 100000.0)
   {
      res.reason = "max_spread_points out of range";
      return false;
   }

   //------------------------------------------------------
   // Phase 5 numeric sanity
   //------------------------------------------------------
   if(!ExtractJsonDoubleField(planJson, "signal_quality_threshold", d))
   {
      res.reason = "Invalid signal_quality_threshold";
      return false;
   }
   if(!ValidateRange01("signal_quality_threshold", d, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "minimum_confirmation_score", d))
   {
      res.reason = "Invalid minimum_confirmation_score";
      return false;
   }
   if(!ValidateRange01("minimum_confirmation_score", d, res))
      return false;

   if(!ExtractJsonIntField(planJson, "max_trades_per_session", i))
   {
      res.reason = "Invalid max_trades_per_session";
      return false;
   }
   if(i < 1 || i > 1000)
   {
      res.reason = "max_trades_per_session out of range";
      return false;
   }

   //------------------------------------------------------
   // AI Experiment Designer numeric sanity
   //------------------------------------------------------
   if(!ExtractJsonDoubleField(planJson, "score_entry_threshold", d))
   {
      res.reason = "Invalid score_entry_threshold";
      return false;
   }
   if(!ValidateRange01("score_entry_threshold", d, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "score_reject_threshold", d))
   {
      res.reason = "Invalid score_reject_threshold";
      return false;
   }
   if(!ValidateRange01("score_reject_threshold", d, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "hard_block_penalty", d))
   {
      res.reason = "Invalid hard_block_penalty";
      return false;
   }
   if(!ValidatePositiveRange("hard_block_penalty", d, 0.0, 5.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "soft_filter_penalty", d))
   {
      res.reason = "Invalid soft_filter_penalty";
      return false;
   }
   if(!ValidatePositiveRange("soft_filter_penalty", d, 0.0, 5.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "counter_trend_penalty", d))
   {
      res.reason = "Invalid counter_trend_penalty";
      return false;
   }
   if(!ValidatePositiveRange("counter_trend_penalty", d, 0.0, 5.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "spread_penalty_multiplier", d))
   {
      res.reason = "Invalid spread_penalty_multiplier";
      return false;
   }
   if(!ValidatePositiveRange("spread_penalty_multiplier", d, 0.0, 10.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "regime_alignment_bonus", d))
   {
      res.reason = "Invalid regime_alignment_bonus";
      return false;
   }
   if(!ValidatePositiveRange("regime_alignment_bonus", d, 0.0, 2.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "regime_misalignment_penalty", d))
   {
      res.reason = "Invalid regime_misalignment_penalty";
      return false;
   }
   if(!ValidatePositiveRange("regime_misalignment_penalty", d, 0.0, 2.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "trigger_missing_penalty", d))
   {
      res.reason = "Invalid trigger_missing_penalty";
      return false;
   }
   if(!ValidatePositiveRange("trigger_missing_penalty", d, 0.0, 2.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "confirmation_bonus_multiplier", d))
   {
      res.reason = "Invalid confirmation_bonus_multiplier";
      return false;
   }
   if(!ValidatePositiveRange("confirmation_bonus_multiplier", d, 0.0, 10.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "trigger_bonus_multiplier", d))
   {
      res.reason = "Invalid trigger_bonus_multiplier";
      return false;
   }
   if(!ValidatePositiveRange("trigger_bonus_multiplier", d, 0.0, 10.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "filter_penalty_multiplier", d))
   {
      res.reason = "Invalid filter_penalty_multiplier";
      return false;
   }
   if(!ValidatePositiveRange("filter_penalty_multiplier", d, 0.0, 10.0, res))
      return false;

   if(!ExtractJsonDoubleField(planJson, "environment_bonus_multiplier", d))
   {
      res.reason = "Invalid environment_bonus_multiplier";
      return false;
   }
   if(!ValidatePositiveRange("environment_bonus_multiplier", d, 0.0, 10.0, res))
      return false;

   //------------------------------------------------------
   // Bool sanity
   //------------------------------------------------------
   if(!ExtractJsonBoolField(planJson, "enabled", b))
   {
      res.reason = "Invalid enabled";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "move_sl_20_to_10", b))
   {
      res.reason = "Invalid move_sl_20_to_10";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "one_direction_only", b))
   {
      res.reason = "Invalid one_direction_only";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "use_spread_filter", b))
   {
      res.reason = "Invalid use_spread_filter";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "allow_counter_trend", b))
   {
      res.reason = "Invalid allow_counter_trend";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "use_soft_filters", b))
   {
      res.reason = "Invalid use_soft_filters";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "use_hard_blocks", b))
   {
      res.reason = "Invalid use_hard_blocks";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "require_main_trigger", b))
   {
      res.reason = "Invalid require_main_trigger";
      return false;
   }

   if(!ExtractJsonBoolField(planJson, "allow_triggerless_entry", b))
   {
      res.reason = "Invalid allow_triggerless_entry";
      return false;
   }

   //------------------------------------------------------
   // Cross-field logic sanity
   //------------------------------------------------------
   string decisionMode = "";
   string planMode = "";

   ExtractJsonStringField(planJson, "decision_engine_mode", decisionMode);
   ExtractJsonStringField(planJson, "plan_mode", planMode);

   double entryThreshold = 0.0;
   double rejectThreshold = 0.0;
   ExtractJsonDoubleField(planJson, "score_entry_threshold", entryThreshold);
   ExtractJsonDoubleField(planJson, "score_reject_threshold", rejectThreshold);

   if(rejectThreshold > entryThreshold)
   {
      res.reason = "score_reject_threshold cannot exceed score_entry_threshold";
      return false;
   }

   if(planMode == "LEGACY" && decisionMode == "SCORE")
   {
      res.reason = "LEGACY plan cannot use SCORE decision_engine_mode";
      return false;
   }

   bool requireMain = false;
   bool allowTriggerless = false;
   ExtractJsonBoolField(planJson, "require_main_trigger", requireMain);
   ExtractJsonBoolField(planJson, "allow_triggerless_entry", allowTriggerless);

   if(requireMain && allowTriggerless)
   {
      res.reason = "require_main_trigger conflicts with allow_triggerless_entry";
      return false;
   }

   //------------------------------------------------------
   // Weighted blocks: optional but validated if present
   //------------------------------------------------------
   // trigger_weights / confirmation_weights / filter_penalties
   // are optional for backward compatibility.
   // If present, they must at least contain braces.
   if(ContainsKey(planJson, "trigger_weights"))
   {
      if(StringFind(planJson, "\"trigger_weights\":{") < 0)
      {
         res.reason = "trigger_weights must be an object";
         return false;
      }
   }

   if(ContainsKey(planJson, "confirmation_weights"))
   {
      if(StringFind(planJson, "\"confirmation_weights\":{") < 0)
      {
         res.reason = "confirmation_weights must be an object";
         return false;
      }
   }

   if(ContainsKey(planJson, "filter_penalties"))
   {
      if(StringFind(planJson, "\"filter_penalties\":{") < 0)
      {
         res.reason = "filter_penalties must be an object";
         return false;
      }
   }

   //------------------------------------------------------
   // Final pass
   //------------------------------------------------------
   res.valid = true;
   res.reason = "Plan JSON passed validation";
   return true;
}

#endif
