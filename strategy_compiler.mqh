#ifndef __STRATEGY_COMPILER_MQH__
#define __STRATEGY_COMPILER_MQH__

#include "LIBRARIES/library_indicators.mqh"
#include "LIBRARIES/library_strategies.mqh"
#include "LIBRARIES/library_entry_patterns.mqh"
#include "LIBRARIES/library_risk_models.mqh"
#include "LIBRARIES/library_filters.mqh"
#include "config_loader.mqh"

struct CompiledPlan
{
   bool enabled;

   string plan_id;
   string main_timeframe;
   string confirmation_timeframe;

   //------------------------------------------------------
   // Legacy / compatibility ids
   //------------------------------------------------------
   string main_trigger_id;

   string strong_confirmation_ids[10];
   int    strong_confirmations_count;

   string medium_confirmation_ids[10];
   int    medium_confirmations_count;

   string required_filter_ids[10];
   int    required_filters_count;

   string entry_pattern_ids[10];
   int    entry_patterns_count;

   //------------------------------------------------------
   // Full definitions
   //------------------------------------------------------
   IndicatorDefinition main_trigger;

   IndicatorDefinition strong_confirmations[10];
   IndicatorDefinition medium_confirmations[10];

   FilterDefinition required_filters[10];
   EntryPatternDefinition entry_patterns[10];

   //------------------------------------------------------
   // Basic execution fields
   //------------------------------------------------------
   double pullback_ratio;
   double breakout_buffer_points;
   int    signal_expiry_bars;

   RiskModelDefinition primary_risk_model;
   bool has_primary_risk_model;

   RiskModelDefinition secondary_risk_model;
   bool has_secondary_risk_model;

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
   // Phase 5 runtime policy fields
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

   // Regime Classification Layer v1 (optional)
   bool   enable_regime_filter;
   string allowed_regimes;
   double regime_confidence_min;
   double regime_tradability_min;
   bool   regime_policy_enabled;



   // Risk State Policy Engine (optional)
   bool   risk_state_policy_enabled;
   string risk_state_thresholds;
   string lockdown_rules;
   string recovery_rules;
   string failure_cluster_rules;

   bool   failure_clustering_enabled;
   int    failure_cluster_window;
   bool   exit_intelligence_enabled;
   string rollback_signal_rules;
   bool   evolution_regime_awareness_enabled;
   bool   shadow_evaluation_enabled;
   string proposal_evidence_thresholds;
   int    proposal_min_sample_by_regime;
   bool   council_adaptive_weights_enabled;
   bool   policy_block_clustering_enabled;

   bool   shadow_replay_enabled;
   string shadow_replay_mode;
   bool   shadow_comparison_logging_enabled;
   bool   shadow_policy_mirroring_enabled;
   bool   governance_review_enabled;
   int    governance_review_window;
   string governance_overfilter_thresholds;
   string governance_evidence_rules;

   // Strategy Intelligence Layer v1 (optional)
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

   // v7A
   bool   execution_estimation_enabled;
   double minimum_execution_geometry_score;
   double minimum_expected_rr_estimate;
   bool   block_adverse_execution_geometry;
   bool   multidimensional_edge_analytics_enabled;
   bool   edge_stability_analytics_enabled;
   int    edge_stability_short_window;
   int    edge_stability_medium_window;
   bool   trade_outcome_linkage_enabled;
   string spread_policy_mode;

   //------------------------------------------------------
   // AI Experiment Designer fields
   //------------------------------------------------------
   string plan_mode;
   string execution_archetype;
   string decision_engine_mode;
   string bias_direction;
   bool   use_soft_filters;
   bool   use_hard_blocks;
   bool   require_main_trigger;
   bool   allow_triggerless_entry;
   double score_entry_threshold;
   double score_reject_threshold;
   double hard_block_penalty;
   double soft_filter_penalty;
   double counter_trend_penalty;
   double spread_penalty_multiplier;
   double regime_alignment_bonus;
   double regime_misalignment_penalty;
   double trigger_missing_penalty;
   double confirmation_bonus_multiplier;
   double trigger_bonus_multiplier;
   double filter_penalty_multiplier;
   double environment_bonus_multiplier;

   //------------------------------------------------------
   // Weighted triggers
   //------------------------------------------------------
   string trigger_weight_ids[10];
   double trigger_weights[10];
   int    trigger_weights_count;

   IndicatorDefinition trigger_weight_defs[10];
   bool   trigger_weight_valid[10];

   //------------------------------------------------------
   // Weighted confirmations
   //------------------------------------------------------
   string confirmation_weight_ids[20];
   double confirmation_weights[20];
   int    confirmation_weights_count;

   IndicatorDefinition confirmation_weight_defs[20];
   bool   confirmation_weight_valid[20];

   //------------------------------------------------------
   // Weighted filter penalties
   //------------------------------------------------------
   string filter_penalty_ids[20];
   double filter_penalties[20];
   int    filter_penalties_count;

   FilterDefinition filter_penalty_defs[20];
   bool   filter_penalty_valid[20];

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

bool CompileRuntimePlan(RuntimePlan &sourcePlan, CompiledPlan &compiled)
{
   //------------------------------------------------------
   // Basic fields
   //------------------------------------------------------
   compiled.enabled                = sourcePlan.enabled;
   compiled.plan_id                = sourcePlan.plan_id;
   compiled.main_timeframe         = sourcePlan.main_timeframe;
   compiled.confirmation_timeframe = sourcePlan.confirmation_timeframe;

   compiled.main_trigger_id = sourcePlan.main_trigger_name;

   compiled.strong_confirmations_count = 0;
   compiled.medium_confirmations_count = 0;
   compiled.required_filters_count     = 0;
   compiled.entry_patterns_count       = 0;
   compiled.has_primary_risk_model     = false;
   compiled.has_secondary_risk_model   = false;

   compiled.trigger_weights_count       = 0;
   compiled.confirmation_weights_count  = 0;
   compiled.filter_penalties_count      = 0;

   //------------------------------------------------------
   // Main trigger
   //------------------------------------------------------
   if(!GetIndicatorDefinitionById(sourcePlan.main_trigger_name, compiled.main_trigger))
      return false;

   //------------------------------------------------------
   // Strong confirmations
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.strong_confirmations_count && i < 10; i++)
   {
      IndicatorDefinition def;
      if(GetIndicatorDefinitionById(sourcePlan.strong_confirmations[i], def))
      {
         compiled.strong_confirmations[compiled.strong_confirmations_count]    = def;
         compiled.strong_confirmation_ids[compiled.strong_confirmations_count] = sourcePlan.strong_confirmations[i];
         compiled.strong_confirmations_count++;
      }
   }

   //------------------------------------------------------
   // Medium confirmations
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.medium_confirmations_count && i < 10; i++)
   {
      IndicatorDefinition def;
      if(GetIndicatorDefinitionById(sourcePlan.medium_confirmations[i], def))
      {
         compiled.medium_confirmations[compiled.medium_confirmations_count]    = def;
         compiled.medium_confirmation_ids[compiled.medium_confirmations_count] = sourcePlan.medium_confirmations[i];
         compiled.medium_confirmations_count++;
      }
   }

   //------------------------------------------------------
   // Required filters
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.required_filters_count && i < 10; i++)
   {
      FilterDefinition def;
      if(GetFilterDefinitionById(sourcePlan.required_filters[i], def))
      {
         compiled.required_filters[compiled.required_filters_count]    = def;
         compiled.required_filter_ids[compiled.required_filters_count] = sourcePlan.required_filters[i];
         compiled.required_filters_count++;
      }
   }

   //------------------------------------------------------
   // Entry patterns
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.entry_patterns_count && i < 10; i++)
   {
      EntryPatternDefinition def;
      if(GetEntryPatternDefinitionById(sourcePlan.entry_patterns[i], def))
      {
         compiled.entry_patterns[compiled.entry_patterns_count]    = def;
         compiled.entry_pattern_ids[compiled.entry_patterns_count] = sourcePlan.entry_patterns[i];
         compiled.entry_patterns_count++;
      }
   }

   //------------------------------------------------------
   // Risk models
   //------------------------------------------------------
   RiskModelDefinition riskDef;

   if(GetRiskModelDefinitionById("atr_stop_rr_exit", riskDef))
   {
      compiled.primary_risk_model = riskDef;
      compiled.has_primary_risk_model = true;
   }

   if(GetRiskModelDefinitionById("time_exit_with_move_sl", riskDef))
   {
      compiled.secondary_risk_model = riskDef;
      compiled.has_secondary_risk_model = true;
   }

   //------------------------------------------------------
   // Basic execution copy
   //------------------------------------------------------
   compiled.pullback_ratio          = sourcePlan.pullback_ratio;
   compiled.breakout_buffer_points  = sourcePlan.breakout_buffer_points;
   compiled.signal_expiry_bars      = sourcePlan.signal_expiry_bars;

   compiled.atr_multiplier          = sourcePlan.atr_multiplier;
   compiled.risk_reward             = sourcePlan.risk_reward;
   compiled.time_exit_minutes       = sourcePlan.time_exit_minutes;
   compiled.move_sl_20_to_10        = sourcePlan.move_sl_20_to_10;

   compiled.max_open_positions      = sourcePlan.max_open_positions;
   compiled.one_direction_only      = sourcePlan.one_direction_only;
   compiled.cooldown_bars           = sourcePlan.cooldown_bars;
   compiled.use_spread_filter       = sourcePlan.use_spread_filter;
   compiled.max_spread_points       = sourcePlan.max_spread_points;

   //------------------------------------------------------
   // Phase 5 runtime policy copy
   //------------------------------------------------------
   compiled.signal_quality_threshold   = sourcePlan.signal_quality_threshold;
   compiled.minimum_confirmation_score = sourcePlan.minimum_confirmation_score;
   compiled.aggression_level           = sourcePlan.aggression_level;
   compiled.execution_mode             = sourcePlan.execution_mode;
   compiled.allow_counter_trend        = sourcePlan.allow_counter_trend;
   compiled.max_trades_per_session     = sourcePlan.max_trades_per_session;

   compiled.allowed_regime_trend       = sourcePlan.allowed_regime_trend;
   compiled.allowed_regime_volatility  = sourcePlan.allowed_regime_volatility;
   compiled.allowed_regime_structure   = sourcePlan.allowed_regime_structure;

   compiled.enable_regime_filter       = sourcePlan.enable_regime_filter;
   compiled.allowed_regimes            = sourcePlan.allowed_regimes;
   compiled.regime_confidence_min      = sourcePlan.regime_confidence_min;
   compiled.regime_tradability_min     = sourcePlan.regime_tradability_min;
   compiled.regime_policy_enabled      = sourcePlan.regime_policy_enabled;


   compiled.risk_state_policy_enabled = sourcePlan.risk_state_policy_enabled;
   compiled.risk_state_thresholds     = sourcePlan.risk_state_thresholds;
   compiled.lockdown_rules            = sourcePlan.lockdown_rules;
   compiled.recovery_rules            = sourcePlan.recovery_rules;
   compiled.failure_cluster_rules     = sourcePlan.failure_cluster_rules;

   compiled.failure_clustering_enabled = sourcePlan.failure_clustering_enabled;
   compiled.failure_cluster_window = sourcePlan.failure_cluster_window;
   compiled.exit_intelligence_enabled = sourcePlan.exit_intelligence_enabled;
   compiled.rollback_signal_rules = sourcePlan.rollback_signal_rules;
   compiled.evolution_regime_awareness_enabled = sourcePlan.evolution_regime_awareness_enabled;
   compiled.shadow_evaluation_enabled = sourcePlan.shadow_evaluation_enabled;
   compiled.proposal_evidence_thresholds = sourcePlan.proposal_evidence_thresholds;
   compiled.proposal_min_sample_by_regime = sourcePlan.proposal_min_sample_by_regime;
   compiled.council_adaptive_weights_enabled = sourcePlan.council_adaptive_weights_enabled;
   compiled.policy_block_clustering_enabled = sourcePlan.policy_block_clustering_enabled;

   compiled.shadow_replay_enabled = sourcePlan.shadow_replay_enabled;
   compiled.shadow_replay_mode = sourcePlan.shadow_replay_mode;
   compiled.shadow_comparison_logging_enabled = sourcePlan.shadow_comparison_logging_enabled;
   compiled.shadow_policy_mirroring_enabled = sourcePlan.shadow_policy_mirroring_enabled;
   compiled.governance_review_enabled = sourcePlan.governance_review_enabled;
   compiled.governance_review_window = sourcePlan.governance_review_window;
   compiled.governance_overfilter_thresholds = sourcePlan.governance_overfilter_thresholds;
   compiled.governance_evidence_rules = sourcePlan.governance_evidence_rules;

   compiled.strategy_intelligence_enabled      = sourcePlan.strategy_intelligence_enabled;
   compiled.entry_quality_scoring_enabled      = sourcePlan.entry_quality_scoring_enabled;
   compiled.minimum_entry_quality_score        = sourcePlan.minimum_entry_quality_score;
   compiled.minimum_strategy_regime_fit_score  = sourcePlan.minimum_strategy_regime_fit_score;
   compiled.block_poor_entries                 = sourcePlan.block_poor_entries;
   compiled.decision_quality_policy_enabled    = sourcePlan.decision_quality_policy_enabled;

   compiled.spread_policy_mode         = sourcePlan.spread_policy_mode;

   //------------------------------------------------------
   // AI Experiment Designer copy
   //------------------------------------------------------
   compiled.plan_mode                   = sourcePlan.plan_mode;
   compiled.execution_archetype         = sourcePlan.execution_archetype;
   compiled.decision_engine_mode        = sourcePlan.decision_engine_mode;
   compiled.bias_direction              = sourcePlan.bias_direction;
   compiled.use_soft_filters            = sourcePlan.use_soft_filters;
   compiled.use_hard_blocks             = sourcePlan.use_hard_blocks;
   compiled.require_main_trigger        = sourcePlan.require_main_trigger;
   compiled.allow_triggerless_entry     = sourcePlan.allow_triggerless_entry;
   compiled.score_entry_threshold       = sourcePlan.score_entry_threshold;
   compiled.score_reject_threshold      = sourcePlan.score_reject_threshold;
   compiled.hard_block_penalty          = sourcePlan.hard_block_penalty;
   compiled.soft_filter_penalty         = sourcePlan.soft_filter_penalty;
   compiled.counter_trend_penalty       = sourcePlan.counter_trend_penalty;
   compiled.spread_penalty_multiplier   = sourcePlan.spread_penalty_multiplier;
   compiled.regime_alignment_bonus      = sourcePlan.regime_alignment_bonus;
   compiled.regime_misalignment_penalty = sourcePlan.regime_misalignment_penalty;
   compiled.trigger_missing_penalty     = sourcePlan.trigger_missing_penalty;
   compiled.confirmation_bonus_multiplier = sourcePlan.confirmation_bonus_multiplier;
   compiled.trigger_bonus_multiplier      = sourcePlan.trigger_bonus_multiplier;
   compiled.filter_penalty_multiplier     = sourcePlan.filter_penalty_multiplier;
   compiled.environment_bonus_multiplier  = sourcePlan.environment_bonus_multiplier;

   //------------------------------------------------------
   // Weighted trigger map
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.trigger_weights_count && i < 10; i++)
   {
      compiled.trigger_weight_ids[compiled.trigger_weights_count] = sourcePlan.trigger_weight_ids[i];
      compiled.trigger_weights[compiled.trigger_weights_count]    = sourcePlan.trigger_weights[i];
      compiled.trigger_weight_valid[compiled.trigger_weights_count] = false;

      IndicatorDefinition def;
      if(GetIndicatorDefinitionById(sourcePlan.trigger_weight_ids[i], def))
      {
         compiled.trigger_weight_defs[compiled.trigger_weights_count] = def;
         compiled.trigger_weight_valid[compiled.trigger_weights_count] = true;
      }

      compiled.trigger_weights_count++;
   }

   //------------------------------------------------------
   // Weighted confirmation map
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.confirmation_weights_count && i < 20; i++)
   {
      compiled.confirmation_weight_ids[compiled.confirmation_weights_count] = sourcePlan.confirmation_weight_ids[i];
      compiled.confirmation_weights[compiled.confirmation_weights_count]    = sourcePlan.confirmation_weights[i];
      compiled.confirmation_weight_valid[compiled.confirmation_weights_count] = false;

      IndicatorDefinition def;
      if(GetIndicatorDefinitionById(sourcePlan.confirmation_weight_ids[i], def))
      {
         compiled.confirmation_weight_defs[compiled.confirmation_weights_count] = def;
         compiled.confirmation_weight_valid[compiled.confirmation_weights_count] = true;
      }

      compiled.confirmation_weights_count++;
   }

   //------------------------------------------------------
   // Weighted filter penalties
   //------------------------------------------------------
   for(int i = 0; i < sourcePlan.filter_penalties_count && i < 20; i++)
   {
      compiled.filter_penalty_ids[compiled.filter_penalties_count] = sourcePlan.filter_penalty_ids[i];
      compiled.filter_penalties[compiled.filter_penalties_count]   = sourcePlan.filter_penalties[i];
      compiled.filter_penalty_valid[compiled.filter_penalties_count] = false;

      FilterDefinition def;
      if(GetFilterDefinitionById(sourcePlan.filter_penalty_ids[i], def))
      {
         compiled.filter_penalty_defs[compiled.filter_penalties_count] = def;
         compiled.filter_penalty_valid[compiled.filter_penalties_count] = true;
      }

      compiled.filter_penalties_count++;
   }

   //------------------------------------------------------
   // Environment policy blocks
   //------------------------------------------------------
   compiled.regime_bonus_trend       = sourcePlan.regime_bonus_trend;
   compiled.regime_bonus_volatility  = sourcePlan.regime_bonus_volatility;
   compiled.regime_bonus_structure   = sourcePlan.regime_bonus_structure;

   compiled.regime_penalty_trend      = sourcePlan.regime_penalty_trend;
   compiled.regime_penalty_volatility = sourcePlan.regime_penalty_volatility;
   compiled.regime_penalty_structure  = sourcePlan.regime_penalty_structure;

   //------------------------------------------------------
   // Sandbox experiment metadata
   //------------------------------------------------------
   compiled.experiment_family = sourcePlan.experiment_family;
   compiled.experiment_note   = sourcePlan.experiment_note;

   return true;
}

#endif
