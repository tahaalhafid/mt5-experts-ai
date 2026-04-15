#ifndef __CONFIG_LOADER_MQH__
#define __CONFIG_LOADER_MQH__

//---------------------------------------------------------
// Personality
//---------------------------------------------------------
struct PersonalityProfile
{
   string profile_name;
   string raw_json;
};

bool LoadDefaultPersonality(PersonalityProfile &p)
{
   p.profile_name = "Aggressive Bollinger Scalper Architect";
   p.raw_json =
      "{"
      "\"profile_name\":\"Aggressive Bollinger Scalper Architect\","
      "\"behavior\":\"adaptive\","
      "\"style\":\"scalping\","
      "\"risk_bias\":\"moderate_aggressive\","
      "\"red_lines\":[\"avoid_random_entries\",\"respect_spread\",\"prefer_confirmed_setups\"]"
      "}";

   return true;
}

//---------------------------------------------------------
// AI Secrets
//---------------------------------------------------------
struct AISecrets
{
   bool   ai_enabled;
   string api_key;
   string model;
   string base_url;
   int    timeout_seconds;
};

bool LoadDefaultAISecrets(AISecrets &cfg)
{
   cfg.ai_enabled      = false;
   cfg.api_key         = "";
   cfg.model           = "gpt-4o-2024-08-06";
   cfg.base_url        = "https://api.openai.com/v1/chat/completions";
   cfg.timeout_seconds = 25;
   return true;
}

//---------------------------------------------------------
// AI Evolution State
//---------------------------------------------------------
struct AIEvolutionState
{
   string version;
   bool   evolution_enabled;

   int    current_generation;
   string current_plan_id;

   string last_evolution_time;
   string last_evolution_reason;
   string last_evolution_scope;
   string last_diagnosis;

   int    min_trades_before_evolution;

   int    small_evolution_min_trades;
   int    medium_evolution_min_trades;
   int    major_evolution_min_trades;
   int    strong_major_evolution_min_trades;

   bool   allow_minor_evolution_anytime;
   bool   allow_small_evolution;
   bool   allow_medium_evolution;
   bool   allow_major_evolution;

   bool   major_evolution_drawdown_trigger;
   bool   major_evolution_underperformance_trigger;

   bool   require_diagnosis_before_evolution;
   bool   diagnostic_first_mode;
   bool   prefer_smallest_effective_change;
   bool   forbid_random_trigger_rotation;
   bool   prefer_regime_adaptation_before_trigger_change;
   bool   require_structural_reason_for_trigger_change;

   int    last_observed_trade_count;
   bool   last_underperformance_flag;
   int    consecutive_underperformance_cycles;

   int    last_trigger_change_generation;
   string last_trigger_change_reason;
   int    trigger_change_cooldown_cycles;

   bool   last_change_improved_performance;
   int    failed_major_change_cycles;

   string notes;
};

bool LoadDefaultEvolutionState(AIEvolutionState &st)
{
   st.version                                  = "2.0";
   st.evolution_enabled                        = true;

   st.current_generation                       = 1;
   st.current_plan_id                          = "plan_v001";

   st.last_evolution_time                      = "";
   st.last_evolution_reason                    = "initial_state";
   st.last_evolution_scope                     = "NONE";
   st.last_diagnosis                           = "INITIAL_STATE";

   st.min_trades_before_evolution              = 8;

   st.small_evolution_min_trades               = 8;
   st.medium_evolution_min_trades              = 15;
   st.major_evolution_min_trades               = 20;
   st.strong_major_evolution_min_trades        = 30;

   st.allow_minor_evolution_anytime            = false;
   st.allow_small_evolution                    = true;
   st.allow_medium_evolution                   = true;
   st.allow_major_evolution                    = true;

   st.major_evolution_drawdown_trigger         = true;
   st.major_evolution_underperformance_trigger = true;

   st.require_diagnosis_before_evolution             = true;
   st.diagnostic_first_mode                          = true;
   st.prefer_smallest_effective_change               = true;
   st.forbid_random_trigger_rotation                 = true;
   st.prefer_regime_adaptation_before_trigger_change = true;
   st.require_structural_reason_for_trigger_change   = true;

   st.last_observed_trade_count                = 0;
   st.last_underperformance_flag               = false;
   st.consecutive_underperformance_cycles      = 0;

   st.last_trigger_change_generation           = 0;
   st.last_trigger_change_reason               = "";
   st.trigger_change_cooldown_cycles           = 2;

   st.last_change_improved_performance         = false;
   st.failed_major_change_cycles               = 0;

   st.notes =
      "Evolution must diagnose root cause first, then apply the smallest "
      "effective improvement. Small changes start at 8 trades, medium at 15, "
      "major trigger-level redesign at 20 to 30 trades only when diagnosis clearly supports it.";

   return true;
}

//---------------------------------------------------------
// Runtime plan
//---------------------------------------------------------
struct RuntimePlan
{
   bool   enabled;

   string plan_id;
   string main_timeframe;
   string confirmation_timeframe;

   string main_trigger_name;
   bool   factory_first_admission_policy_locked;
   bool   strategy_transfer_runtime_freeze_active;
   bool   future_factory_admission_required_for_execution;
   string strategy_transfer_runtime_freeze_reason_code;
   string strategy_transfer_runtime_freeze_scope;


   string strong_confirmations[10];
   int    strong_confirmations_count;

   string medium_confirmations[10];
   int    medium_confirmations_count;

   string required_filters[10];
   int    required_filters_count;

   string entry_patterns[10];
   int    entry_patterns_count;

   double pullback_ratio;
   double breakout_buffer_points;
   int    signal_expiry_bars;

   double atr_multiplier;
   double risk_reward;
   int    time_exit_minutes;
   bool   move_sl_20_to_10;

   int    max_open_positions;
   bool   one_direction_only;
   int    cooldown_bars;
   bool   use_spread_filter;
   double max_spread_points;

   //------------------------------------------------------
   // Phase 5 additions
   //------------------------------------------------------
   double signal_quality_threshold;
   double minimum_confirmation_score;
   string aggression_level;
   string execution_mode;
   bool   allow_counter_trend;
   int    max_trades_per_session;

   string allowed_regime_trend;
   string allowed_regime_volatility;
   string allowed_regime_structure;

   //------------------------------------------------------
   // Regime Classification Layer v1 (optional, backward-safe)
   //------------------------------------------------------
   bool   enable_regime_filter;        // decision-level prefilter
   string allowed_regimes;             // CSV labels: TREND_UP,RANGE_BALANCED,...
   double regime_confidence_min;       // 0..1
   double regime_tradability_min;      // 0..1
   bool   regime_policy_enabled;       // policy-level guard


   //------------------------------------------------------
   // Risk State Policy Engine (optional, backward-safe)
   //------------------------------------------------------
   bool   risk_state_policy_enabled;
   string risk_state_thresholds;   // JSON object as string (optional)
   string lockdown_rules;          // JSON object as string (optional)
   string recovery_rules;          // JSON object as string (optional)
   string failure_cluster_rules;   // JSON object as string (optional)

   bool   failure_clustering_enabled;
   int    failure_cluster_window;
   bool   exit_intelligence_enabled;
   string rollback_signal_rules;            // JSON object as string (optional)
   bool   evolution_regime_awareness_enabled;

   // 4B: Evolution Intelligence Upgrade
   bool   shadow_evaluation_enabled;
   string proposal_evidence_thresholds;    // JSON object as string (optional)
   int    proposal_min_sample_by_regime;
   bool   council_adaptive_weights_enabled;
   bool   policy_block_clustering_enabled;

   // 5A: Shadow Replay v1 + Proposal vs Production Comparison
   bool   shadow_replay_enabled;
   string shadow_replay_mode;
   bool   shadow_comparison_logging_enabled;
   bool   shadow_policy_mirroring_enabled;
   bool   governance_review_enabled;
   int    governance_review_window;
   string governance_overfilter_thresholds;
   string governance_evidence_rules;

   //------------------------------------------------------
   // Strategy Intelligence Layer v1 (optional)
   //------------------------------------------------------
   bool   strategy_intelligence_enabled;
   bool   entry_quality_scoring_enabled;
   double minimum_entry_quality_score;
   double minimum_strategy_regime_fit_score;
   double minimum_entry_edge_score;
   double minimum_follow_through_quality_score;
   bool   block_poor_entries;
   bool   block_negative_entry_edge;
   bool   decision_quality_policy_enabled;
   bool   decision_quality_analytics_enabled;

   // Execution Estimation + Multi-Dimensional Edge Analytics (v7A)
   bool   execution_estimation_enabled;
   double minimum_execution_geometry_score;
   double minimum_expected_rr_estimate;
   bool   block_adverse_execution_geometry;
   bool   multidimensional_edge_analytics_enabled;

   // Edge Stability + Outcome Linkage (v7B)
   bool   edge_stability_analytics_enabled;
   int    edge_stability_short_window;
   int    edge_stability_medium_window;
   bool   trade_outcome_linkage_enabled;


   // Phase 8A: Council Attribution + Strategy Responsibility (optional)
   bool   council_attribution_enabled;
   bool   council_outcome_attribution_enabled;
   bool   strategy_responsibility_analytics_enabled;

   // Phase 8B: Dissent/Correctness Intelligence (optional)
   bool   council_dissent_intelligence_enabled;
   bool   attribution_correctness_analytics_enabled;
   int    attribution_min_dissent_samples;

   int    attribution_min_strategy_appearances;
   int    attribution_min_linked_outcomes;
   int    attribution_regime_min_sample;


   string spread_policy_mode;

   //------------------------------------------------------
   // AI Experiment Designer fields
   //------------------------------------------------------
   string plan_mode;                     // LEGACY / WEIGHTED / LAB / HYBRID
   string execution_archetype;           // SCALP / INTRADAY / HYBRID / EXPERIMENTAL
   string decision_engine_mode;          // GATE / SCORE / HYBRID
   string bias_direction;                // BOTH / BUY_ONLY / SELL_ONLY / AUTO
   bool   use_soft_filters;              // true => penalties, false => hard reject
   bool   use_hard_blocks;               // true => hard reject on severe cases
   bool   require_main_trigger;          // old behavior if true
   bool   allow_triggerless_entry;       // allow score-only entry
   double score_entry_threshold;         // final score to enter
   double score_reject_threshold;        // below this => reject / hard wait
   double hard_block_penalty;            // severe negative penalty
   double soft_filter_penalty;           // default filter penalty
   double counter_trend_penalty;         // score penalty for counter-trend
   double spread_penalty_multiplier;     // spread cost multiplier
   double regime_alignment_bonus;        // if regime matches
   double regime_misalignment_penalty;   // if regime mismatches
   double trigger_missing_penalty;       // if trigger absent but entry still allowed
   double confirmation_bonus_multiplier;
   double trigger_bonus_multiplier;
   double filter_penalty_multiplier;
   double environment_bonus_multiplier;

   //------------------------------------------------------
   // Weighted trigger map
   //------------------------------------------------------
   string trigger_weight_ids[10];
   double trigger_weights[10];
   int    trigger_weights_count;

   //------------------------------------------------------
   // Weighted confirmations map
   //------------------------------------------------------
   string confirmation_weight_ids[20];
   double confirmation_weights[20];
   int    confirmation_weights_count;

   //------------------------------------------------------
   // Weighted filters / penalties
   //------------------------------------------------------
   string filter_penalty_ids[20];
   double filter_penalties[20];
   int    filter_penalties_count;

   //------------------------------------------------------
   // Environment policy blocks
   //------------------------------------------------------
   string regime_bonus_trend;
   string regime_bonus_volatility;
   string regime_bonus_structure;

   string regime_penalty_trend;
   string regime_penalty_volatility;
   string regime_penalty_structure;

   //------------------------------------------------------
   // Sandbox experiment metadata
   //------------------------------------------------------
   string experiment_family;
   string experiment_note;
};

//---------------------------------------------------------
// Basic text/json helpers
//---------------------------------------------------------
string TrimString(string s)
{
   StringTrimLeft(s);
   StringTrimRight(s);
   return s;
}

bool LoadTextFile(string relativePath, string &outText)
{
   outText = "";

   int h = FileOpen(relativePath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
      outText += FileReadString(h);

   FileClose(h);
   return true;
}

bool ExtractJsonStringField(string json, string key, string &outVal)
{
   outVal = "";

   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, ":", p);
   if(p < 0)
      return false;

   int q1 = StringFind(json, "\"", p + 1);
   if(q1 < 0)
      return false;

   int q2 = q1 + 1;
   while(true)
   {
      q2 = StringFind(json, "\"", q2);
      if(q2 < 0)
         return false;

      if(StringGetCharacter(json, q2 - 1) != '\\')
         break;

      q2++;
   }

   outVal = StringSubstr(json, q1 + 1, q2 - q1 - 1);
   return true;
}

bool ExtractJsonBoolField(string json, string key, bool &outVal)
{
   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, ":", p);
   if(p < 0)
      return false;

   string tail = TrimString(StringSubstr(json, p + 1));

   if(StringFind(tail, "true") == 0)
   {
      outVal = true;
      return true;
   }

   if(StringFind(tail, "false") == 0)
   {
      outVal = false;
      return true;
   }

   return false;
}


//---------------------------------------------------------
// Extract object field as raw JSON (balanced braces). Safe + minimal.
// Supports: "field": { ... }
//---------------------------------------------------------
bool ExtractJsonObjectField(string json, string fieldName, string &outObject)
{
   outObject = "";

   string key = """ + fieldName + """;
   int p = StringFind(json, key);
   if(p < 0) return false;

   int colon = StringFind(json, ":", p + StringLen(key));
   if(colon < 0) return false;

   int start = StringFind(json, "{", colon);
   if(start < 0) return false;

   int depth = 0;
   int n = StringLen(json);

   for(int i = start; i < n; i++)
   {
      ushort ch = StringGetCharacter(json, i);

      if(ch == '{') depth++;
      else if(ch == '}')
      {
         depth--;
         if(depth == 0)
         {
            outObject = StringSubstr(json, start, (i - start) + 1);
            outObject = TrimString(outObject);
            return (StringLen(outObject) > 0);
         }
      }
   }

   return false;
}

bool ExtractJsonIntField(string json, string key, int &outVal)
{
   outVal = 0;

   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, ":", p);
   if(p < 0)
      return false;

   int s = p + 1;
   while(s < StringLen(json))
   {
      ushort c = StringGetCharacter(json, s);
      if((c >= '0' && c <= '9') || c == '-')
         break;
      s++;
   }

   int e = s;
   while(e < StringLen(json))
   {
      ushort c = StringGetCharacter(json, e);
      if(!((c >= '0' && c <= '9') || c == '-'))
         break;
      e++;
   }

   if(e <= s)
      return false;

   outVal = (int)StringToInteger(StringSubstr(json, s, e - s));
   return true;
}

bool ExtractJsonDoubleField(string json, string key, double &outVal)
{
   outVal = 0.0;

   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, ":", p);
   if(p < 0)
      return false;

   int s = p + 1;
   while(s < StringLen(json))
   {
      ushort c = StringGetCharacter(json, s);
      if((c >= '0' && c <= '9') || c == '-' || c == '.')
         break;
      s++;
   }

   int e = s;
   while(e < StringLen(json))
   {
      ushort c = StringGetCharacter(json, e);
      if(!((c >= '0' && c <= '9') || c == '-' || c == '.'))
         break;
      e++;
   }

   if(e <= s)
      return false;

   outVal = StringToDouble(StringSubstr(json, s, e - s));
   return true;
}

bool ExtractJsonArrayStrings(string json, string key, string &outArr[], int &outCount, int maxCount = 10)
{
   outCount = 0;

   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, "[", p);
   if(p < 0)
      return false;

   int e = StringFind(json, "]", p);
   if(e < 0)
      return false;

   string block = StringSubstr(json, p + 1, e - p - 1);

   int pos = 0;
   while(outCount < maxCount)
   {
      int q1 = StringFind(block, "\"", pos);
      if(q1 < 0)
         break;

      int q2 = q1 + 1;
      while(true)
      {
         q2 = StringFind(block, "\"", q2);
         if(q2 < 0)
            break;

         if(StringGetCharacter(block, q2 - 1) != '\\')
            break;

         q2++;
      }

      if(q2 < 0)
         break;

      outArr[outCount] = StringSubstr(block, q1 + 1, q2 - q1 - 1);
      outCount++;

      pos = q2 + 1;
   }

   return true;
}

//---------------------------------------------------------
// Extract weighted pairs from object block
//---------------------------------------------------------
bool ExtractJsonObjectStringDoublePairs(
   string json,
   string key,
   string &outKeys[],
   double &outVals[],
   int &outCount,
   int maxCount = 20
)
{
   outCount = 0;

   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, "{", p);
   if(p < 0)
      return false;

   int e = StringFind(json, "}", p);
   if(e < 0)
      return false;

   string block = StringSubstr(json, p + 1, e - p - 1);
   int pos = 0;

   while(outCount < maxCount)
   {
      int q1 = StringFind(block, "\"", pos);
      if(q1 < 0)
         break;

      int q2 = StringFind(block, "\"", q1 + 1);
      if(q2 < 0)
         break;

      string objKey = StringSubstr(block, q1 + 1, q2 - q1 - 1);

      int colon = StringFind(block, ":", q2);
      if(colon < 0)
         break;

      int s = colon + 1;
      while(s < StringLen(block))
      {
         ushort c = StringGetCharacter(block, s);
         if((c >= '0' && c <= '9') || c == '-' || c == '.')
            break;
         s++;
      }

      int n = s;
      while(n < StringLen(block))
      {
         ushort c = StringGetCharacter(block, n);
         if(!((c >= '0' && c <= '9') || c == '-' || c == '.'))
            break;
         n++;
      }

      if(n <= s)
         break;

      outKeys[outCount] = objKey;
      outVals[outCount] = StringToDouble(StringSubstr(block, s, n - s));
      outCount++;

      pos = n + 1;
   }

   return true;
}

//---------------------------------------------------------
// Defaults
//---------------------------------------------------------
bool LoadDefaultPlan(RuntimePlan &plan)
{
   plan.enabled                 = true;
   plan.plan_id                 = "plan_v001";
   plan.main_timeframe          = "M1";
   plan.confirmation_timeframe  = "M5";

   plan.main_trigger_name = "bollinger_reclaim_trigger";

   plan.strong_confirmations_count = 2;
   plan.strong_confirmations[0]    = "sweep_detector";
   plan.strong_confirmations[1]    = "mfi_momentum";

   plan.medium_confirmations_count = 2;
   plan.medium_confirmations[0]    = "candle_rejection_validation";
   plan.medium_confirmations[1]    = "ema_trend_alignment";

   plan.required_filters_count = 1;
   plan.required_filters[0]    = "atr_volatility_filter";

   plan.entry_patterns_count = 2;
   plan.entry_patterns[0]    = "breakout_entry";
   plan.entry_patterns[1]    = "pullback_entry";

   plan.pullback_ratio          = 0.25;
   plan.breakout_buffer_points  = 15.0;
   plan.signal_expiry_bars      = 3;

   plan.atr_multiplier          = 1.5;
   plan.risk_reward             = 2.0;
   plan.time_exit_minutes       = 20;
   plan.move_sl_20_to_10        = true;

   plan.max_open_positions      = 2;
   plan.one_direction_only      = true;
   plan.cooldown_bars           = 2;
   plan.use_spread_filter       = true;
   plan.max_spread_points       = 2500.0;

   // Strategy Transfer Package 1 defaults (non-disruptive)
   plan.factory_first_admission_policy_locked = false;
   plan.strategy_transfer_runtime_freeze_active = false;
   plan.future_factory_admission_required_for_execution = false;
   plan.strategy_transfer_runtime_freeze_reason_code = "";
   plan.strategy_transfer_runtime_freeze_scope = "NONE";

   //------------------------------------------------------
   // Phase 5 defaults
   //------------------------------------------------------
   plan.signal_quality_threshold   = 0.72;
   plan.minimum_confirmation_score = 0.45;
   plan.aggression_level           = "NORMAL";
   plan.execution_mode             = "NORMAL";
   plan.allow_counter_trend        = false;
   plan.max_trades_per_session     = 20;

   plan.allowed_regime_trend       = "ANY";
   plan.allowed_regime_volatility  = "ANY";
   plan.allowed_regime_structure   = "ANY";


   // Regime Classification Layer v1 defaults (non-disruptive)
   plan.enable_regime_filter   = false;
   plan.allowed_regimes        = "";
   plan.regime_confidence_min  = 0.0;
   plan.regime_tradability_min = 0.0;
   plan.regime_policy_enabled  = false;


   // Risk State Policy Engine defaults (non-disruptive)
   plan.risk_state_policy_enabled = false;
   plan.risk_state_thresholds     = "";
   plan.lockdown_rules            = "";
   plan.recovery_rules            = "";
   plan.failure_cluster_rules     = "";

   plan.failure_clustering_enabled = false;
   plan.failure_cluster_window = 12;
   plan.exit_intelligence_enabled = true;
   plan.rollback_signal_rules = "";
   plan.evolution_regime_awareness_enabled = false;

   plan.shadow_evaluation_enabled = false;
   plan.proposal_evidence_thresholds = "";
   plan.proposal_min_sample_by_regime = 8;
   plan.council_adaptive_weights_enabled = false;
   plan.policy_block_clustering_enabled = false;

   // 5A defaults (non-disruptive)
   plan.shadow_replay_enabled = false;
   plan.shadow_replay_mode = "SAFE_REPLAY_V1";
   plan.shadow_comparison_logging_enabled = true;
   plan.shadow_policy_mirroring_enabled = false;
   plan.governance_review_enabled = false;
   plan.governance_review_window = 20;
   plan.governance_overfilter_thresholds = "";
   plan.governance_evidence_rules = "";

   // Strategy Intelligence defaults (non-disruptive)
   plan.strategy_intelligence_enabled      = false;
   plan.entry_quality_scoring_enabled      = false;
   plan.minimum_entry_quality_score        = 0.0;
   plan.minimum_strategy_regime_fit_score  = 0.0;
   plan.block_poor_entries                 = false;
   plan.decision_quality_policy_enabled    = false;

   plan.spread_policy_mode         = "NORMAL";

   // Execution Estimation + Multi-Dimensional Edge defaults (non-disruptive)
   plan.execution_estimation_enabled            = false;
   plan.minimum_execution_geometry_score        = 0.0;
   plan.minimum_expected_rr_estimate            = 0.0;
   plan.block_adverse_execution_geometry        = false;
   plan.multidimensional_edge_analytics_enabled = false;

   // Edge Stability + Outcome Linkage defaults (non-disruptive)
   plan.edge_stability_analytics_enabled        = false;
   plan.edge_stability_short_window             = 12;
   plan.edge_stability_medium_window            = 24;
   plan.trade_outcome_linkage_enabled           = true;


   // Phase 8A defaults (off by default, backward compatible)
   plan.council_attribution_enabled             = false;
   plan.council_outcome_attribution_enabled     = false;
   plan.strategy_responsibility_analytics_enabled = false;
   plan.council_dissent_intelligence_enabled = false;
   plan.attribution_correctness_analytics_enabled = false;
   plan.attribution_min_dissent_samples = 3;

   plan.attribution_min_strategy_appearances    = 5;
   plan.attribution_min_linked_outcomes         = 3;
   plan.attribution_regime_min_sample           = 3;


   //------------------------------------------------------
   // AI Experiment Designer defaults
   //------------------------------------------------------
   plan.plan_mode                     = "HYBRID";
   plan.execution_archetype           = "EXPERIMENTAL";
   plan.decision_engine_mode          = "HYBRID";
   plan.bias_direction                = "BOTH";
   plan.use_soft_filters              = true;
   plan.use_hard_blocks               = true;
   plan.require_main_trigger          = false;
   plan.allow_triggerless_entry       = false;
   plan.score_entry_threshold         = 0.72;
   plan.score_reject_threshold        = 0.15;
   plan.hard_block_penalty            = 1.00;
   plan.soft_filter_penalty           = 0.12;
   plan.counter_trend_penalty         = 0.10;
   plan.spread_penalty_multiplier     = 1.00;
   plan.regime_alignment_bonus        = 0.08;
   plan.regime_misalignment_penalty   = 0.10;
   plan.trigger_missing_penalty       = 0.15;
   plan.confirmation_bonus_multiplier = 1.00;
   plan.trigger_bonus_multiplier      = 1.00;
   plan.filter_penalty_multiplier     = 1.00;
   plan.environment_bonus_multiplier  = 1.00;

   plan.trigger_weights_count      = 0;
   plan.confirmation_weights_count = 0;
   plan.filter_penalties_count     = 0;

   plan.regime_bonus_trend       = "ANY";
   plan.regime_bonus_volatility  = "ANY";
   plan.regime_bonus_structure   = "ANY";

   plan.regime_penalty_trend      = "";
   plan.regime_penalty_volatility = "";
   plan.regime_penalty_structure  = "";

   plan.experiment_family = "default_lab";
   plan.experiment_note   = "AI experimental runtime plan";

   return true;
}

//---------------------------------------------------------
// JSON loaders
//---------------------------------------------------------
bool LoadPersonalityFromJson(string relativePath, PersonalityProfile &p)
{
   string json = "";
   if(!LoadTextFile(relativePath, json))
      return false;

   string v = "";
   if(ExtractJsonStringField(json, "profile_name", v))
      p.profile_name = v;

   p.raw_json = json;
   return true;
}

bool LoadAISecretsFromJson(string relativePath, AISecrets &cfg)
{
   string json = "";
   if(!LoadTextFile(relativePath, json))
      return false;

   bool   b = false;
   int    i = 0;
   int    iv = 0;
   string s = "";

   if(ExtractJsonBoolField(json, "ai_enabled", b))
      cfg.ai_enabled = b;

   if(ExtractJsonStringField(json, "api_key", s))
      cfg.api_key = s;

   if(ExtractJsonStringField(json, "model", s))
      cfg.model = s;

   if(ExtractJsonStringField(json, "base_url", s))
      cfg.base_url = s;

   if(ExtractJsonIntField(json, "timeout_seconds", i))
      cfg.timeout_seconds = i;

   return true;
}

bool LoadAIEvolutionStateFromJson(string relativePath, AIEvolutionState &st)
{
   string json = "";
   if(!LoadTextFile(relativePath, json))
      return false;

   LoadDefaultEvolutionState(st);

   bool   b = false;
   int    i = 0;
   string s = "";

   if(ExtractJsonStringField(json, "version", s))
      st.version = s;

   if(ExtractJsonBoolField(json, "evolution_enabled", b))
      st.evolution_enabled = b;

   if(ExtractJsonIntField(json, "current_generation", i))
      st.current_generation = i;

   if(ExtractJsonStringField(json, "current_plan_id", s))
      st.current_plan_id = s;

   if(ExtractJsonStringField(json, "last_evolution_time", s))
      st.last_evolution_time = s;

   if(ExtractJsonStringField(json, "last_evolution_reason", s))
      st.last_evolution_reason = s;

   if(ExtractJsonStringField(json, "last_evolution_scope", s))
      st.last_evolution_scope = s;

   if(ExtractJsonStringField(json, "last_diagnosis", s))
      st.last_diagnosis = s;

   if(ExtractJsonIntField(json, "min_trades_before_evolution", i))
      st.min_trades_before_evolution = i;

   if(ExtractJsonIntField(json, "small_evolution_min_trades", i))
      st.small_evolution_min_trades = i;

   if(ExtractJsonIntField(json, "medium_evolution_min_trades", i))
      st.medium_evolution_min_trades = i;

   if(ExtractJsonIntField(json, "major_evolution_min_trades", i))
      st.major_evolution_min_trades = i;

   if(ExtractJsonIntField(json, "strong_major_evolution_min_trades", i))
      st.strong_major_evolution_min_trades = i;

   if(ExtractJsonBoolField(json, "allow_minor_evolution_anytime", b))
      st.allow_minor_evolution_anytime = b;

   if(ExtractJsonBoolField(json, "allow_small_evolution", b))
      st.allow_small_evolution = b;

   if(ExtractJsonBoolField(json, "allow_medium_evolution", b))
      st.allow_medium_evolution = b;

   if(ExtractJsonBoolField(json, "allow_major_evolution", b))
      st.allow_major_evolution = b;

   if(ExtractJsonBoolField(json, "major_evolution_drawdown_trigger", b))
      st.major_evolution_drawdown_trigger = b;

   if(ExtractJsonBoolField(json, "major_evolution_underperformance_trigger", b))
      st.major_evolution_underperformance_trigger = b;

   if(ExtractJsonBoolField(json, "require_diagnosis_before_evolution", b))
      st.require_diagnosis_before_evolution = b;

   if(ExtractJsonBoolField(json, "diagnostic_first_mode", b))
      st.diagnostic_first_mode = b;

   if(ExtractJsonBoolField(json, "prefer_smallest_effective_change", b))
      st.prefer_smallest_effective_change = b;

   if(ExtractJsonBoolField(json, "forbid_random_trigger_rotation", b))
      st.forbid_random_trigger_rotation = b;

   if(ExtractJsonBoolField(json, "prefer_regime_adaptation_before_trigger_change", b))
      st.prefer_regime_adaptation_before_trigger_change = b;

   if(ExtractJsonBoolField(json, "require_structural_reason_for_trigger_change", b))
      st.require_structural_reason_for_trigger_change = b;

   if(ExtractJsonIntField(json, "last_observed_trade_count", i))
      st.last_observed_trade_count = i;

   if(ExtractJsonBoolField(json, "last_underperformance_flag", b))
      st.last_underperformance_flag = b;

   if(ExtractJsonIntField(json, "consecutive_underperformance_cycles", i))
      st.consecutive_underperformance_cycles = i;

   if(ExtractJsonIntField(json, "last_trigger_change_generation", i))
      st.last_trigger_change_generation = i;

   if(ExtractJsonStringField(json, "last_trigger_change_reason", s))
      st.last_trigger_change_reason = s;

   if(ExtractJsonIntField(json, "trigger_change_cooldown_cycles", i))
      st.trigger_change_cooldown_cycles = i;

   if(ExtractJsonBoolField(json, "last_change_improved_performance", b))
      st.last_change_improved_performance = b;

   if(ExtractJsonIntField(json, "failed_major_change_cycles", i))
      st.failed_major_change_cycles = i;

   if(ExtractJsonStringField(json, "notes", s))
      st.notes = s;

   //------------------------------------------------------
   // Safety normalization after loading
   //------------------------------------------------------
   if(st.small_evolution_min_trades <= 0)
      st.small_evolution_min_trades = 8;

   if(st.medium_evolution_min_trades < st.small_evolution_min_trades)
      st.medium_evolution_min_trades = 15;

   if(st.major_evolution_min_trades < st.medium_evolution_min_trades)
      st.major_evolution_min_trades = 20;

   if(st.strong_major_evolution_min_trades < st.major_evolution_min_trades)
      st.strong_major_evolution_min_trades = 30;

   if(st.min_trades_before_evolution <= 0)
      st.min_trades_before_evolution = st.small_evolution_min_trades;

   if(st.trigger_change_cooldown_cycles < 0)
      st.trigger_change_cooldown_cycles = 0;

   return true;
}

bool LoadRuntimePlanFromJson(string relativePath, RuntimePlan &plan)
{
   string json = "";
   if(!LoadTextFile(relativePath, json))
      return false;

   LoadDefaultPlan(plan);

   bool   b = false;
   int    i = 0;
   double d = 0.0;
   int    iv = 0;
   string s = "";

   if(ExtractJsonBoolField(json, "enabled", b))
      plan.enabled = b;

   if(ExtractJsonStringField(json, "plan_id", s))
      plan.plan_id = s;

   if(ExtractJsonStringField(json, "main_timeframe", s))
      plan.main_timeframe = s;

   if(ExtractJsonStringField(json, "confirmation_timeframe", s))
      plan.confirmation_timeframe = s;

   if(ExtractJsonStringField(json, "main_trigger_name", s))
      plan.main_trigger_name = s;

   ExtractJsonArrayStrings(json, "strong_confirmations", plan.strong_confirmations, plan.strong_confirmations_count, 10);
   ExtractJsonArrayStrings(json, "medium_confirmations", plan.medium_confirmations, plan.medium_confirmations_count, 10);
   ExtractJsonArrayStrings(json, "required_filters", plan.required_filters, plan.required_filters_count, 10);
   ExtractJsonArrayStrings(json, "entry_patterns", plan.entry_patterns, plan.entry_patterns_count, 10);

   if(ExtractJsonDoubleField(json, "pullback_ratio", d))
      plan.pullback_ratio = d;

   if(ExtractJsonDoubleField(json, "breakout_buffer_points", d))
      plan.breakout_buffer_points = d;

   if(ExtractJsonIntField(json, "signal_expiry_bars", i))
      plan.signal_expiry_bars = i;

   if(ExtractJsonDoubleField(json, "atr_multiplier", d))
      plan.atr_multiplier = d;

   if(ExtractJsonDoubleField(json, "risk_reward", d))
      plan.risk_reward = d;

   if(ExtractJsonIntField(json, "time_exit_minutes", i))
      plan.time_exit_minutes = i;

   if(ExtractJsonBoolField(json, "move_sl_20_to_10", b))
      plan.move_sl_20_to_10 = b;

   if(ExtractJsonIntField(json, "max_open_positions", i))
      plan.max_open_positions = i;

   if(ExtractJsonBoolField(json, "one_direction_only", b))
      plan.one_direction_only = b;

   if(ExtractJsonIntField(json, "cooldown_bars", i))
      plan.cooldown_bars = i;

   if(ExtractJsonBoolField(json, "use_spread_filter", b))
      plan.use_spread_filter = b;

   if(ExtractJsonDoubleField(json, "max_spread_points", d))
      plan.max_spread_points = d;

   if(ExtractJsonBoolField(json, "factory_first_admission_policy_locked", b))
      plan.factory_first_admission_policy_locked = b;

   if(ExtractJsonBoolField(json, "strategy_transfer_runtime_freeze_active", b))
      plan.strategy_transfer_runtime_freeze_active = b;

   if(ExtractJsonBoolField(json, "future_factory_admission_required_for_execution", b))
      plan.future_factory_admission_required_for_execution = b;

   if(ExtractJsonStringField(json, "strategy_transfer_runtime_freeze_reason_code", s))
      plan.strategy_transfer_runtime_freeze_reason_code = s;

   if(ExtractJsonStringField(json, "strategy_transfer_runtime_freeze_scope", s))
      plan.strategy_transfer_runtime_freeze_scope = s;

   //------------------------------------------------------
   // Phase 5 fields
   //------------------------------------------------------
   if(ExtractJsonDoubleField(json, "signal_quality_threshold", d))
      plan.signal_quality_threshold = d;

   if(ExtractJsonDoubleField(json, "minimum_confirmation_score", d))
      plan.minimum_confirmation_score = d;

   if(ExtractJsonStringField(json, "aggression_level", s))
      plan.aggression_level = s;

   if(ExtractJsonStringField(json, "execution_mode", s))
      plan.execution_mode = s;

   if(ExtractJsonBoolField(json, "allow_counter_trend", b))
      plan.allow_counter_trend = b;

   if(ExtractJsonIntField(json, "max_trades_per_session", i))
      plan.max_trades_per_session = i;

   if(ExtractJsonStringField(json, "allowed_regime_trend", s))
      plan.allowed_regime_trend = s;

   if(ExtractJsonStringField(json, "allowed_regime_volatility", s))
      plan.allowed_regime_volatility = s;

   if(ExtractJsonStringField(json, "allowed_regime_structure", s))
      plan.allowed_regime_structure = s;


   // Regime Classification Layer v1 (optional)
   if(ExtractJsonBoolField(json, "enable_regime_filter", b))
      plan.enable_regime_filter = b;

   if(ExtractJsonStringField(json, "allowed_regimes", s))
      plan.allowed_regimes = s;

   if(ExtractJsonDoubleField(json, "regime_confidence_min", d))
      plan.regime_confidence_min = d;

   if(ExtractJsonDoubleField(json, "regime_tradability_min", d))
      plan.regime_tradability_min = d;

   if(ExtractJsonBoolField(json, "regime_policy_enabled", b))
      plan.regime_policy_enabled = b;



   // Risk State Policy Engine (optional)
   if(ExtractJsonBoolField(json, "risk_state_policy_enabled", b))
      plan.risk_state_policy_enabled = b;

   if(ExtractJsonObjectField(json, "risk_state_thresholds", s))
      plan.risk_state_thresholds = s;

   if(ExtractJsonObjectField(json, "lockdown_rules", s))
      plan.lockdown_rules = s;

   if(ExtractJsonObjectField(json, "recovery_rules", s))
      plan.recovery_rules = s;

   if(ExtractJsonObjectField(json, "failure_cluster_rules", s))
      plan.failure_cluster_rules = s;


   if(ExtractJsonBoolField(json, "failure_clustering_enabled", b))
      plan.failure_clustering_enabled = b;

   if(ExtractJsonIntField(json, "failure_cluster_window", iv))
      plan.failure_cluster_window = MathMax(4, iv);

   if(ExtractJsonBoolField(json, "exit_intelligence_enabled", b))
      plan.exit_intelligence_enabled = b;

   if(ExtractJsonObjectField(json, "rollback_signal_rules", s))
      plan.rollback_signal_rules = s;

   if(ExtractJsonBoolField(json, "evolution_regime_awareness_enabled", b))
      plan.evolution_regime_awareness_enabled = b;

   if(ExtractJsonBoolField(json, "shadow_evaluation_enabled", b))
      plan.shadow_evaluation_enabled = b;

   if(ExtractJsonObjectField(json, "proposal_evidence_thresholds", s))
      plan.proposal_evidence_thresholds = s;

   if(ExtractJsonIntField(json, "proposal_min_sample_by_regime", iv))
      plan.proposal_min_sample_by_regime = MathMax(4, iv);

   if(ExtractJsonBoolField(json, "council_adaptive_weights_enabled", b))
      plan.council_adaptive_weights_enabled = b;

   if(ExtractJsonBoolField(json, "policy_block_clustering_enabled", b))
      plan.policy_block_clustering_enabled = b;

   // 5A: Shadow replay (optional)
   if(ExtractJsonBoolField(json, "shadow_replay_enabled", b))
      plan.shadow_replay_enabled = b;

   if(ExtractJsonStringField(json, "shadow_replay_mode", s))
      plan.shadow_replay_mode = s;

   if(ExtractJsonBoolField(json, "shadow_comparison_logging_enabled", b))
      plan.shadow_comparison_logging_enabled = b;

   if(ExtractJsonBoolField(json, "shadow_policy_mirroring_enabled", b))
      plan.shadow_policy_mirroring_enabled = b;

   if(ExtractJsonBoolField(json, "governance_review_enabled", b))
      plan.governance_review_enabled = b;

   if(ExtractJsonIntField(json, "governance_review_window", i))
      plan.governance_review_window = i;

   if(ExtractJsonStringField(json, "governance_overfilter_thresholds", s))
      plan.governance_overfilter_thresholds = s;

   if(ExtractJsonStringField(json, "governance_evidence_rules", s))
      plan.governance_evidence_rules = s;

   // Strategy Intelligence Layer v1 (optional)
   if(ExtractJsonBoolField(json, "strategy_intelligence_enabled", b))
      plan.strategy_intelligence_enabled = b;

   if(ExtractJsonBoolField(json, "entry_quality_scoring_enabled", b))
      plan.entry_quality_scoring_enabled = b;

   if(ExtractJsonDoubleField(json, "minimum_entry_quality_score", d))
      plan.minimum_entry_quality_score = d;

   if(ExtractJsonDoubleField(json, "minimum_strategy_regime_fit_score", d))
      plan.minimum_strategy_regime_fit_score = d;

   if(ExtractJsonDoubleField(json, "minimum_entry_edge_score", d))
      plan.minimum_entry_edge_score = d;

   if(ExtractJsonDoubleField(json, "minimum_follow_through_quality_score", d))
      plan.minimum_follow_through_quality_score = d;

   if(ExtractJsonBoolField(json, "block_poor_entries", b))
      plan.block_poor_entries = b;

   if(ExtractJsonBoolField(json, "block_negative_entry_edge", b))
      plan.block_negative_entry_edge = b;

   if(ExtractJsonBoolField(json, "decision_quality_policy_enabled", b))
      plan.decision_quality_policy_enabled = b;

   if(ExtractJsonBoolField(json, "decision_quality_analytics_enabled", b))
      plan.decision_quality_analytics_enabled = b;

   if(ExtractJsonBoolField(json, "execution_estimation_enabled", b))
      plan.execution_estimation_enabled = b;

   if(ExtractJsonDoubleField(json, "minimum_execution_geometry_score", d))
      plan.minimum_execution_geometry_score = d;

   if(ExtractJsonDoubleField(json, "minimum_expected_rr_estimate", d))
      plan.minimum_expected_rr_estimate = d;

   if(ExtractJsonBoolField(json, "block_adverse_execution_geometry", b))
      plan.block_adverse_execution_geometry = b;

   if(ExtractJsonBoolField(json, "multidimensional_edge_analytics_enabled", b))
      plan.multidimensional_edge_analytics_enabled = b;

   if(ExtractJsonBoolField(json, "edge_stability_analytics_enabled", b))
      plan.edge_stability_analytics_enabled = b;

   if(ExtractJsonIntField(json, "edge_stability_short_window", i))
      plan.edge_stability_short_window = i;

   if(ExtractJsonIntField(json, "edge_stability_medium_window", i))
      plan.edge_stability_medium_window = i;

   if(ExtractJsonBoolField(json, "trade_outcome_linkage_enabled", b))
      plan.trade_outcome_linkage_enabled = b;

   // Phase 8A: Council attribution toggles (optional)
   if(ExtractJsonBoolField(json, "council_attribution_enabled", b))
      plan.council_attribution_enabled = b;

   if(ExtractJsonBoolField(json, "council_outcome_attribution_enabled", b))
      plan.council_outcome_attribution_enabled = b;

   if(ExtractJsonBoolField(json, "strategy_responsibility_analytics_enabled", b))
      plan.strategy_responsibility_analytics_enabled = b;

   if(ExtractJsonBoolField(json, "council_dissent_intelligence_enabled", b))
      plan.council_dissent_intelligence_enabled = b;

   if(ExtractJsonBoolField(json, "attribution_correctness_analytics_enabled", b))
      plan.attribution_correctness_analytics_enabled = b;

   if(ExtractJsonIntField(json, "attribution_min_dissent_samples", i))
      plan.attribution_min_dissent_samples = i;

   if(ExtractJsonIntField(json, "attribution_min_strategy_appearances", i))
      plan.attribution_min_strategy_appearances = i;

   if(ExtractJsonIntField(json, "attribution_min_linked_outcomes", i))
      plan.attribution_min_linked_outcomes = i;

   if(ExtractJsonIntField(json, "attribution_regime_min_sample", i))
      plan.attribution_regime_min_sample = i;


      plan.shadow_comparison_logging_enabled = b;

   if(ExtractJsonStringField(json, "spread_policy_mode", s))
      plan.spread_policy_mode = s;

   //------------------------------------------------------
   // AI Experiment Designer fields
   //------------------------------------------------------
   if(ExtractJsonStringField(json, "plan_mode", s))
      plan.plan_mode = s;

   if(ExtractJsonStringField(json, "execution_archetype", s))
      plan.execution_archetype = s;

   if(ExtractJsonStringField(json, "decision_engine_mode", s))
      plan.decision_engine_mode = s;

   if(ExtractJsonStringField(json, "bias_direction", s))
      plan.bias_direction = s;

   if(ExtractJsonBoolField(json, "use_soft_filters", b))
      plan.use_soft_filters = b;

   if(ExtractJsonBoolField(json, "use_hard_blocks", b))
      plan.use_hard_blocks = b;

   if(ExtractJsonBoolField(json, "require_main_trigger", b))
      plan.require_main_trigger = b;

   if(ExtractJsonBoolField(json, "allow_triggerless_entry", b))
      plan.allow_triggerless_entry = b;

   if(ExtractJsonDoubleField(json, "score_entry_threshold", d))
      plan.score_entry_threshold = d;

   if(ExtractJsonDoubleField(json, "score_reject_threshold", d))
      plan.score_reject_threshold = d;

   if(ExtractJsonDoubleField(json, "hard_block_penalty", d))
      plan.hard_block_penalty = d;

   if(ExtractJsonDoubleField(json, "soft_filter_penalty", d))
      plan.soft_filter_penalty = d;

   if(ExtractJsonDoubleField(json, "counter_trend_penalty", d))
      plan.counter_trend_penalty = d;

   if(ExtractJsonDoubleField(json, "spread_penalty_multiplier", d))
      plan.spread_penalty_multiplier = d;

   if(ExtractJsonDoubleField(json, "regime_alignment_bonus", d))
      plan.regime_alignment_bonus = d;

   if(ExtractJsonDoubleField(json, "regime_misalignment_penalty", d))
      plan.regime_misalignment_penalty = d;

   if(ExtractJsonDoubleField(json, "trigger_missing_penalty", d))
      plan.trigger_missing_penalty = d;

   if(ExtractJsonDoubleField(json, "confirmation_bonus_multiplier", d))
      plan.confirmation_bonus_multiplier = d;

   if(ExtractJsonDoubleField(json, "trigger_bonus_multiplier", d))
      plan.trigger_bonus_multiplier = d;

   if(ExtractJsonDoubleField(json, "filter_penalty_multiplier", d))
      plan.filter_penalty_multiplier = d;

   if(ExtractJsonDoubleField(json, "environment_bonus_multiplier", d))
      plan.environment_bonus_multiplier = d;

   ExtractJsonObjectStringDoublePairs(
      json,
      "trigger_weights",
      plan.trigger_weight_ids,
      plan.trigger_weights,
      plan.trigger_weights_count,
      10
   );

   ExtractJsonObjectStringDoublePairs(
      json,
      "confirmation_weights",
      plan.confirmation_weight_ids,
      plan.confirmation_weights,
      plan.confirmation_weights_count,
      20
   );

   ExtractJsonObjectStringDoublePairs(
      json,
      "filter_penalties",
      plan.filter_penalty_ids,
      plan.filter_penalties,
      plan.filter_penalties_count,
      20
   );

   if(ExtractJsonStringField(json, "regime_bonus_trend", s))
      plan.regime_bonus_trend = s;

   if(ExtractJsonStringField(json, "regime_bonus_volatility", s))
      plan.regime_bonus_volatility = s;

   if(ExtractJsonStringField(json, "regime_bonus_structure", s))
      plan.regime_bonus_structure = s;

   if(ExtractJsonStringField(json, "regime_penalty_trend", s))
      plan.regime_penalty_trend = s;

   if(ExtractJsonStringField(json, "regime_penalty_volatility", s))
      plan.regime_penalty_volatility = s;

   if(ExtractJsonStringField(json, "regime_penalty_structure", s))
      plan.regime_penalty_structure = s;

   if(ExtractJsonStringField(json, "experiment_family", s))
      plan.experiment_family = s;

   if(ExtractJsonStringField(json, "experiment_note", s))
      plan.experiment_note = s;

   return true;
}

//---------------------------------------------------------
// Backward-compatible JSON helpers
//---------------------------------------------------------
bool JsonGetBool(const string json, const string key, bool &val)
{
   return ExtractJsonBoolField(json, key, val);
}

bool JsonGetString(const string json, const string key, string &val)
{
   return ExtractJsonStringField(json, key, val);
}

bool JsonGetInt(const string json, const string key, int &val)
{
   return ExtractJsonIntField(json, key, val);
}

bool JsonGetDouble(const string json, const string key, double &val)
{
   return ExtractJsonDoubleField(json, key, val);
}

#endif