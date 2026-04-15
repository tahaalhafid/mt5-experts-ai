#ifndef __COUNCIL_GOVERNOR_MQH__
#define __COUNCIL_GOVERNOR_MQH__

#include "council_mode_types.mqh"

// Structural ownership note:
// This legacy governor threshold module is descriptive/policy reference only in current active runtime flow.
// It is not the live council pre-filter enforcement owner.

//---------------------------------------------------------
// Threshold helpers
//---------------------------------------------------------
double CouncilGov_MinConsensus()
{
   return 0.55;
}

double CouncilGov_MaxConflict()
{
   return 0.45;
}

double CouncilGov_MinEnvironmentScore()
{
   return 0.45;
}

double CouncilGov_MinCouncilQuality()
{
   return 0.55;
}

//---------------------------------------------------------
// Main governor policy builder
//---------------------------------------------------------
bool RunCouncilGovernorDecision(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &gate,
   CouncilPolicyAdjustment &outPolicy
)
{
   InitCouncilPolicyAdjustment(outPolicy);
   outPolicy.valid = true;

   //------------------------------------------------------
   // Weak environment -> tighten pre-AI thresholds
   //------------------------------------------------------
   if(env.total_score < CouncilGov_MinEnvironmentScore())
   {
      outPolicy.change_pre_ai_thresholds   = true;
      outPolicy.new_min_environment_score  = 0.55;
      outPolicy.new_min_consensus          = 0.60;
      outPolicy.new_max_conflict           = 0.35;
      outPolicy.new_min_council_quality    = 0.60;
      outPolicy.adjustment_reason          = "Weak environment score";
      outPolicy.summary                    = "Governor tightened thresholds due to weak environment";
      return true;
   }

   //------------------------------------------------------
   // High conflict -> tighten conflict allowance
   //------------------------------------------------------
   if(agg.conflict_score > CouncilGov_MaxConflict())
   {
      outPolicy.change_pre_ai_thresholds   = true;
      outPolicy.new_min_consensus          = 0.62;
      outPolicy.new_max_conflict           = 0.30;
      outPolicy.new_min_environment_score  = gate.min_required_environment_score;
      outPolicy.new_min_council_quality    = 0.60;
      outPolicy.adjustment_reason          = "High council conflict";
      outPolicy.summary                    = "Governor tightened conflict threshold";
      return true;
   }

   //------------------------------------------------------
   // Strong setup -> no change
   //------------------------------------------------------
   if(gate.passed &&
      agg.consensus_strength >= CouncilGov_MinConsensus() &&
      agg.council_quality >= CouncilGov_MinCouncilQuality())
   {
      outPolicy.adjustment_reason = "No adjustment needed";
      outPolicy.summary           = "Governor accepted current council configuration";
      return true;
   }

   //------------------------------------------------------
   // If best strategy exists but council weak -> suggest weight adjustment
   //------------------------------------------------------
   if(StringLen(TrimString(agg.best_strategy_id)) > 0 && !gate.passed)
   {
      outPolicy.change_vote_weights = true;
      outPolicy.target_strategy_id  = agg.best_strategy_id;
      outPolicy.new_vote_weight     = 1.10;
      outPolicy.adjustment_reason   = "Best strategy identified while gate failed";
      outPolicy.summary             = "Governor suggests slight vote-weight increase for best strategy";
      return true;
   }

   //------------------------------------------------------
   // Repeated weak state -> mode exit suggestion
   //------------------------------------------------------
   if(!gate.passed && agg.council_quality < 0.40)
   {
      outPolicy.suggest_mode_exit   = true;
      outPolicy.adjustment_reason   = "Council quality too weak";
      outPolicy.summary             = "Governor suggests possible exit from council mode";
      return true;
   }

   //------------------------------------------------------
   // Default
   //------------------------------------------------------
   outPolicy.adjustment_reason = "Neutral adjustment";
   outPolicy.summary           = "Governor made no structural changes";
   return true;
}

//---------------------------------------------------------
// Summary helper
//---------------------------------------------------------
string BuildCouncilGovernorSummary(CouncilPolicyAdjustment &p)
{
   string s = "";

   s += "COUNCIL GOVERNOR SUMMARY\n";
   s += "valid: " + string(p.valid ? "true" : "false") + "\n";
   s += "change_strategy_enablement: " + string(p.change_strategy_enablement ? "true" : "false") + "\n";
   s += "change_vote_weights: " + string(p.change_vote_weights ? "true" : "false") + "\n";
   s += "change_pre_ai_thresholds: " + string(p.change_pre_ai_thresholds ? "true" : "false") + "\n";
   s += "suggest_mode_exit: " + string(p.suggest_mode_exit ? "true" : "false") + "\n";
   s += "target_strategy_id: " + p.target_strategy_id + "\n";
   s += "new_vote_weight: " + DoubleToString(p.new_vote_weight, 2) + "\n";
   s += "new_min_consensus: " + DoubleToString(p.new_min_consensus, 2) + "\n";
   s += "new_max_conflict: " + DoubleToString(p.new_max_conflict, 2) + "\n";
   s += "new_min_environment_score: " + DoubleToString(p.new_min_environment_score, 2) + "\n";
   s += "new_min_council_quality: " + DoubleToString(p.new_min_council_quality, 2) + "\n";
   s += "adjustment_reason: " + p.adjustment_reason + "\n";
   s += "summary: " + p.summary + "\n";

   return s;
}

#endif
