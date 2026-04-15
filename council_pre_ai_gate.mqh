



#ifndef __COUNCIL_PRE_AI_GATE_MQH__
#define __COUNCIL_PRE_AI_GATE_MQH__

#include "council_mode_types.mqh"

// Structural ownership note:
// This module is legacy-preserved/descriptive in the current active runtime path.
// Live council pass/fail enforcement owner is RunCouncilPreAIFilter(...) plus final env.tradable/pre.passed branching.

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
double CouncilGateClamp(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string CouncilGateDecisionText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)    return "BUY";
   if(d == COUNCIL_DECISION_SELL)   return "SELL";
   if(d == COUNCIL_DECISION_REJECT) return "REJECT";
   return "WAIT";
}

//---------------------------------------------------------
// Defaults
//---------------------------------------------------------
void InitCouncilPreAIGateConfig(CouncilPreAIGateConfig &cfg)
{
   cfg.enabled                    = true;
   cfg.min_environment_score      = 0.55;
   cfg.min_council_quality        = 0.60;
   cfg.min_consensus_strength     = 0.58;
   cfg.max_conflict_score         = 0.42;
   cfg.min_best_strategy_score    = 0.60;
   cfg.min_directional_weight     = 0.90;
   cfg.min_active_strategies      = 2;
   cfg.allow_single_strong_vote   = false;
   cfg.single_vote_score_override = 0.92;
   cfg.reject_on_environment_block = true;
   cfg.reject_on_heavy_conflict    = true;
}

//---------------------------------------------------------
// Internal checks
//---------------------------------------------------------
bool CouncilGateHasDirectionalBias(CouncilAggregateReport &agg)
{
   return (agg.total_buy_weight > 0.0 || agg.total_sell_weight > 0.0);
}

double CouncilGateDominantWeight(CouncilAggregateReport &agg)
{
   return MathMax(agg.total_buy_weight, agg.total_sell_weight);
}

CouncilDecision CouncilGateResolveDirection(CouncilAggregateReport &agg)
{
   if(agg.total_buy_weight > agg.total_sell_weight)
      return COUNCIL_DECISION_BUY;

   if(agg.total_sell_weight > agg.total_buy_weight)
      return COUNCIL_DECISION_SELL;

   return COUNCIL_DECISION_WAIT;
}

//---------------------------------------------------------
// Main gate logic
//---------------------------------------------------------
bool EvaluateCouncilPreAIGate(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateConfig &cfg,
   CouncilPreAIGateResult &outGate
)
{
   InitCouncilPreAIGateResult(outGate);

   if(!cfg.enabled)
   {
      outGate.valid           = true;
      outGate.passed          = true;
      outGate.final_decision  = CouncilGateResolveDirection(agg);
      outGate.pass_score      = 1.0;
      outGate.reason          = "Pre-AI gate disabled";
      return true;
   }

   if(!env.valid)
   {
      outGate.valid  = true;
      outGate.passed = false;
      outGate.reason = "Environment report invalid";
      return true;
   }

   if(!agg.valid)
   {
      outGate.valid  = true;
      outGate.passed = false;
      outGate.reason = "Aggregate report invalid";
      return true;
   }

   //------------------------------------------------------
   // Hard environment block
   //------------------------------------------------------
   if(cfg.reject_on_environment_block && env.hard_block)
   {
      outGate.valid  = true;
      outGate.passed = false;
      outGate.reason = "Environment hard block active";
      return true;
   }

   //------------------------------------------------------
   // Active strategy requirement
   //------------------------------------------------------
   if(agg.active_strategies < cfg.min_active_strategies)
   {
      outGate.valid  = true;
      outGate.passed = false;
      outGate.reason =
         "Not enough active strategies: " +
         IntegerToString(agg.active_strategies) +
         " < " +
         IntegerToString(cfg.min_active_strategies);
      return true;
   }

   //------------------------------------------------------
   // Must have directional weight
   //------------------------------------------------------
   if(!CouncilGateHasDirectionalBias(agg))
   {
      outGate.valid  = true;
      outGate.passed = false;
      outGate.reason = "No directional council bias";
      return true;
   }

   double dominantWeight = CouncilGateDominantWeight(agg);
   CouncilDecision finalDir = CouncilGateResolveDirection(agg);

   if(finalDir != COUNCIL_DECISION_BUY && finalDir != COUNCIL_DECISION_SELL)
   {
      outGate.valid  = true;
      outGate.passed = false;
      outGate.reason = "Council direction unresolved";
      return true;
   }

   //------------------------------------------------------
   // Single-vote override
   //------------------------------------------------------
   int directionalVotes = agg.buy_votes + agg.sell_votes;
   int dominantVotes = (finalDir == COUNCIL_DECISION_BUY ? agg.buy_votes : agg.sell_votes);

   bool singleStrongOverride = false;
   if(cfg.allow_single_strong_vote &&
      dominantVotes == 1 &&
      agg.best_strategy_score >= cfg.single_vote_score_override &&
      agg.environment_score >= cfg.min_environment_score)
   {
      singleStrongOverride = true;
   }

   //------------------------------------------------------
   // Core checks
   //------------------------------------------------------
   if(!singleStrongOverride)
   {
      if(env.total_score < cfg.min_environment_score)
      {
         outGate.valid  = true;
         outGate.passed = false;
         outGate.reason =
            "Environment score too low: " +
            DoubleToString(env.total_score, 2) +
            " < " +
            DoubleToString(cfg.min_environment_score, 2);
         return true;
      }

      if(agg.council_quality < cfg.min_council_quality)
      {
         outGate.valid  = true;
         outGate.passed = false;
         outGate.reason =
            "Council quality too low: " +
            DoubleToString(agg.council_quality, 2) +
            " < " +
            DoubleToString(cfg.min_council_quality, 2);
         return true;
      }

      if(agg.consensus_strength < cfg.min_consensus_strength)
      {
         outGate.valid  = true;
         outGate.passed = false;
         outGate.reason =
            "Consensus too weak: " +
            DoubleToString(agg.consensus_strength, 2) +
            " < " +
            DoubleToString(cfg.min_consensus_strength, 2);
         return true;
      }

      if(cfg.reject_on_heavy_conflict && agg.conflict_score > cfg.max_conflict_score)
      {
         outGate.valid  = true;
         outGate.passed = false;
         outGate.reason =
            "Conflict too high: " +
            DoubleToString(agg.conflict_score, 2) +
            " > " +
            DoubleToString(cfg.max_conflict_score, 2);
         return true;
      }

      if(agg.best_strategy_score < cfg.min_best_strategy_score)
      {
         outGate.valid  = true;
         outGate.passed = false;
         outGate.reason =
            "Best strategy score too low: " +
            DoubleToString(agg.best_strategy_score, 2) +
            " < " +
            DoubleToString(cfg.min_best_strategy_score, 2);
         return true;
      }

      if(dominantWeight < cfg.min_directional_weight)
      {
         outGate.valid  = true;
         outGate.passed = false;
         outGate.reason =
            "Directional weight too low: " +
            DoubleToString(dominantWeight, 2) +
            " < " +
            DoubleToString(cfg.min_directional_weight, 2);
         return true;
      }
   }

   //------------------------------------------------------
   // Pass score
   //------------------------------------------------------
   double passScore =
      (env.total_score * 0.25) +
      (agg.council_quality * 0.25) +
      (agg.consensus_strength * 0.20) +
      (agg.best_strategy_score * 0.20) +
      (dominantWeight * 0.10);

   passScore = CouncilGateClamp(passScore);

   outGate.valid          = true;
   outGate.passed         = true;
   outGate.final_decision = finalDir;
   outGate.pass_score     = passScore;
   outGate.reason =
      "Pre-AI gate passed"
      " | dir=" + CouncilGateDecisionText(finalDir) +
      " | pass_score=" + DoubleToString(passScore, 2) +
      " | env=" + DoubleToString(env.total_score, 2) +
      " | quality=" + DoubleToString(agg.council_quality, 2) +
      " | consensus=" + DoubleToString(agg.consensus_strength, 2) +
      " | conflict=" + DoubleToString(agg.conflict_score, 2) +
      " | dominant_weight=" + DoubleToString(dominantWeight, 2);

   return true;
}

#endif
