#ifndef __COUNCIL_AI_GOVERNOR_MQH__
#define __COUNCIL_AI_GOVERNOR_MQH__

#include "council_mode_types.mqh"

// Structural ownership note:
// AI governor thresholds in this module are post-filter policy-producing/advisory in current runtime order.
// Live council pass/fail enforcement owner remains RunCouncilPreAIFilter(...) plus final env.tradable/pre.passed branching.

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
double CouncilAIGovClamp(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string CouncilAIGovDecisionText(CouncilDecision d)
{
   return CouncilDecisionToText(d);
}

void CouncilAIGovReset(CouncilPolicyAdjustment &a)
{
   InitCouncilPolicyAdjustment(a);
   a.valid = true;
}

//---------------------------------------------------------
// Internal ranking helper
//---------------------------------------------------------
void CouncilAIGovPickBestStrategy(
   CouncilAggregateReport &agg,
   string &bestStrategyId,
   string &secondaryHint
)
{
   bestStrategyId = TrimString(agg.best_strategy_id);
   secondaryHint  = TrimString(agg.support_strategy_ids);

   if(StringLen(bestStrategyId) <= 0)
      bestStrategyId = "";

   if(StringLen(secondaryHint) <= 0)
      secondaryHint = "";
}

//---------------------------------------------------------
// Governor state selection
//---------------------------------------------------------
CouncilGovernorOperatingState CouncilAIGovSelectOperatingState(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &gate
)
{
   if(!env.tradable)
      return COUNCIL_GOV_STATE_DEFENSIVE;

   if(env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION ||
      agg.exhaustion_warning)
   {
      return COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE;
   }

   if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION &&
      agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION &&
      agg.family_diversity_score >= 0.60 &&
      agg.conflict_score <= 0.20 &&
      gate.passed)
   {
      return COUNCIL_GOV_STATE_AGGRESSIVE;
   }

   if(agg.conflict_score >= 0.40 ||
      agg.consensus_type == COUNCIL_CONSENSUS_NARROW ||
      env.zone_confidence < 0.50)
   {
      return COUNCIL_GOV_STATE_DEFENSIVE;
   }

   return COUNCIL_GOV_STATE_NORMAL;
}

//---------------------------------------------------------
// Governor state report builder
//---------------------------------------------------------
void BuildCouncilGovernorStateReport(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &gate,
   CouncilGovernorStateReport &st
)
{
   InitCouncilGovernorStateReport(st);

   st.valid = true;
   st.operating_state = CouncilAIGovSelectOperatingState(env, agg, gate);
   st.operating_state_text = CouncilGovernorOperatingStateToText(st.operating_state);

   st.tighten_entry       = false;
   st.prefer_reversal     = false;
   st.prefer_continuation = false;
   st.defensive_bias      = false;

   if(st.operating_state == COUNCIL_GOV_STATE_DEFENSIVE)
   {
      st.tighten_entry  = true;
      st.defensive_bias = true;
   }
   else if(st.operating_state == COUNCIL_GOV_STATE_AGGRESSIVE)
   {
      st.prefer_continuation = true;
   }
   else if(st.operating_state == COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE)
   {
      st.tighten_entry   = true;
      st.prefer_reversal = true;
      st.defensive_bias  = true;
   }
   else
   {
      if(env.preferred_style == COUNCIL_STYLE_REVERSAL ||
         env.preferred_style == COUNCIL_STYLE_MEAN_RECLAIM)
         st.prefer_reversal = true;

      if(env.preferred_style == COUNCIL_STYLE_CONTINUATION ||
         env.preferred_style == COUNCIL_STYLE_BREAKOUT)
         st.prefer_continuation = true;
   }

   st.reason =
      "Governor state selected"
      " | state=" + st.operating_state_text +
      " | zone=" + env.zone_name +
      " | zone_conf=" + DoubleToString(env.zone_confidence, 2) +
      " | consensus=" + agg.consensus_label +
      " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
      " | conflict=" + DoubleToString(agg.conflict_score, 2) +
      " | exhaustion=" + string(agg.exhaustion_warning ? "true" : "false");

   st.summary =
      "GovState"
      " | state=" + st.operating_state_text +
      " | tighten=" + string(st.tighten_entry ? "true" : "false") +
      " | pref_rev=" + string(st.prefer_reversal ? "true" : "false") +
      " | pref_cont=" + string(st.prefer_continuation ? "true" : "false") +
      " | defensive=" + string(st.defensive_bias ? "true" : "false");
}

//---------------------------------------------------------
// Main evaluation
//---------------------------------------------------------
bool EvaluateCouncilAIGovernor(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &gate,
   CouncilFailurePatternReport &failDet,
   CouncilPolicyAdjustment &outAction
)
{
   CouncilAIGovReset(outAction);

   if(!env.valid || !agg.valid || !gate.valid || !failDet.valid)
   {
      outAction.summary = "AI Governor input invalid";
      outAction.adjustment_reason = "Invalid council input";
      return false;
   }

   string bestStrategyId = "";
   string secondaryHint  = "";
   CouncilAIGovPickBestStrategy(agg, bestStrategyId, secondaryHint);

   CouncilGovernorStateReport state;
   BuildCouncilGovernorStateReport(env, agg, gate, state);

   outAction.change_operating_state      = true;
   outAction.target_operating_state      = state.operating_state;
   outAction.target_operating_state_text = state.operating_state_text;

   //------------------------------------------------------
   // Case 0: failure detector severe pressure
   //------------------------------------------------------
   if(failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_CRITICAL ||
      failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_HIGH)
   {
      outAction.change_pre_ai_thresholds = true;
      outAction.target_strategy_id       = bestStrategyId;
      outAction.target_operating_state   = COUNCIL_GOV_STATE_DEFENSIVE;
      outAction.target_operating_state_text = CouncilGovernorOperatingStateToText(COUNCIL_GOV_STATE_DEFENSIVE);

      outAction.new_min_consensus         = 0.68;
      outAction.new_max_conflict          = 0.22;
      outAction.new_min_environment_score = 0.58;
      outAction.new_min_council_quality   = 0.66;

      outAction.adjustment_reason =
         "Failure detector pressure elevated"
         " | pressure=" + failDet.pressure_label +
         " | dominant_failure=" + failDet.dominant_failure_tag;

      outAction.summary =
         "AI Governor: failure detector defensive override"
         " | pressure=" + failDet.pressure_label +
         " | dominant_failure=" + failDet.dominant_failure_tag +
         " | recommended_state=" + failDet.recommended_state +
         " | best_strategy=" + bestStrategyId;

      return true;
   }

   //------------------------------------------------------
   // Case 1: gate failed
   //------------------------------------------------------
   if(!gate.passed)
   {
      outAction.change_pre_ai_thresholds = true;
      outAction.target_strategy_id       = bestStrategyId;

      if(state.operating_state == COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE)
      {
         outAction.new_min_consensus         = 0.62;
         outAction.new_max_conflict          = 0.25;
         outAction.new_min_environment_score = 0.50;
         outAction.new_min_council_quality   = 0.60;
      }
      else
      {
         outAction.new_min_consensus         = 0.60;
         outAction.new_max_conflict          = 0.35;
         outAction.new_min_environment_score = 0.55;
         outAction.new_min_council_quality   = 0.60;
      }

      outAction.adjustment_reason =
         "Pre-AI gate failed; tighten thresholds"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: tightened council thresholds"
         " | state=" + state.operating_state_text +
         " | filtered_decision=" + CouncilAIGovDecisionText(gate.filtered_decision) +
         " | best_strategy=" + bestStrategyId +
         " | support=" + secondaryHint;

      return true;
   }

   //------------------------------------------------------
   // Case 2: narrow or conflicted consensus
   //------------------------------------------------------
   if(agg.consensus_type == COUNCIL_CONSENSUS_NARROW ||
      agg.conflict_score >= 0.50 ||
      agg.family_diversity_score < 0.45)
   {
      outAction.change_pre_ai_thresholds = true;
      outAction.change_vote_weights      = true;
      outAction.target_strategy_id       = bestStrategyId;

      outAction.new_vote_weight           = 1.08;
      outAction.new_min_consensus         = 0.64;
      outAction.new_max_conflict          = 0.28;
      outAction.new_min_environment_score = MathMax(0.50, gate.min_required_environment_score);
      outAction.new_min_council_quality   = 0.62;

      outAction.adjustment_reason =
         "Narrow/conflicted council consensus"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: narrow or conflicted consensus, tightened gate and nudged leader"
         " | state=" + state.operating_state_text +
         " | best_strategy=" + bestStrategyId +
         " | consensus=" + agg.consensus_label +
         " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
         " | conflict=" + DoubleToString(agg.conflict_score, 2);

      return true;
   }

   //------------------------------------------------------
   // Case 3: confirmation gap detected
   //------------------------------------------------------
   if(failDet.confirmation_gap_detected)
   {
      outAction.change_pre_ai_thresholds = true;
      outAction.target_strategy_id       = bestStrategyId;
      outAction.target_operating_state   = COUNCIL_GOV_STATE_DEFENSIVE;
      outAction.target_operating_state_text = CouncilGovernorOperatingStateToText(COUNCIL_GOV_STATE_DEFENSIVE);

      outAction.new_min_consensus         = 0.66;
      outAction.new_max_conflict          = 0.25;
      outAction.new_min_environment_score = 0.55;
      outAction.new_min_council_quality   = 0.64;

      outAction.adjustment_reason =
         "Confirmation gap detected by failure detector";

      outAction.summary =
         "AI Governor: confirmation gap defensive tightening"
         " | confirm_gap_risk=" + DoubleToString(failDet.confirm_gap_risk_score, 2) +
         " | dominant_failure=" + failDet.dominant_failure_tag;

      return true;
   }

   //------------------------------------------------------
   // Case 4: exhaustion-sensitive mode
   //------------------------------------------------------
   if(state.operating_state == COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE)
   {
      outAction.change_pre_ai_thresholds = true;
      outAction.change_vote_weights      = true;
      outAction.target_strategy_id       = bestStrategyId;

      outAction.new_vote_weight           = 1.10;
      outAction.new_min_consensus         = 0.58;
      outAction.new_max_conflict          = 0.25;
      outAction.new_min_environment_score = 0.45;
      outAction.new_min_council_quality   = 0.58;

      outAction.adjustment_reason =
         "Exhaustion-sensitive operating state active";

      outAction.summary =
         "AI Governor: exhaustion-sensitive mode"
         " | zone=" + env.zone_name +
         " | best_strategy=" + bestStrategyId +
         " | quality=" + DoubleToString(agg.council_quality, 2) +
         " | exhaustion=" + string(agg.exhaustion_warning ? "true" : "false");

      return true;
   }

   //------------------------------------------------------
   // Case 5: aggressive continuation state
   //------------------------------------------------------
   if(state.operating_state == COUNCIL_GOV_STATE_AGGRESSIVE)
   {
      outAction.change_vote_weights      = true;
      outAction.target_strategy_id       = bestStrategyId;
      outAction.new_vote_weight          = 1.06;

      outAction.adjustment_reason =
         "Aggressive continuation state active";

      outAction.summary =
         "AI Governor: aggressive continuation mode"
         " | zone=" + env.zone_name +
         " | best_strategy=" + bestStrategyId +
         " | quality=" + DoubleToString(agg.council_quality, 2) +
         " | consensus=" + DoubleToString(agg.consensus_strength, 2);

      return true;
   }

   //------------------------------------------------------
   // Case 6: defensive state
   //------------------------------------------------------
   if(state.operating_state == COUNCIL_GOV_STATE_DEFENSIVE)
   {
      outAction.change_pre_ai_thresholds = true;

      outAction.new_min_consensus         = 0.62;
      outAction.new_max_conflict          = 0.30;
      outAction.new_min_environment_score = 0.55;
      outAction.new_min_council_quality   = 0.60;

      outAction.adjustment_reason =
         "Defensive operating state active";

      outAction.summary =
         "AI Governor: defensive mode"
         " | zone=" + env.zone_name +
         " | consensus=" + agg.consensus_label +
         " | conflict=" + DoubleToString(agg.conflict_score, 2) +
         " | zone_conf=" + DoubleToString(env.zone_confidence, 2);

      return true;
   }

   //------------------------------------------------------
   // Case 7: high-conviction pass with clear leader
   //------------------------------------------------------
   if(gate.passed &&
      agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION &&
      agg.consensus_strength >= 0.70 &&
      agg.council_quality >= 0.65 &&
      StringLen(bestStrategyId) > 0)
   {
      outAction.change_vote_weights = true;
      outAction.target_strategy_id  = bestStrategyId;
      outAction.new_vote_weight     = 1.05;

      outAction.adjustment_reason =
         "Promote strongest aligned strategy slightly"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: slight preference to best strategy"
         " | state=" + state.operating_state_text +
         " | best_strategy=" + bestStrategyId +
         " | council_quality=" + DoubleToString(agg.council_quality, 2) +
         " | consensus=" + DoubleToString(agg.consensus_strength, 2);

      return true;
   }

   //------------------------------------------------------
   // Case 8: council too weak
   //------------------------------------------------------
   if(agg.council_quality < 0.40)
   {
      outAction.suggest_mode_exit = true;
      outAction.adjustment_reason =
         "Council quality too weak"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: council mode may be unsuitable right now"
         " | state=" + state.operating_state_text +
         " | quality=" + DoubleToString(agg.council_quality, 2) +
         " | dominant=" + agg.dominant_side;

      return true;
   }

   //------------------------------------------------------
   // Default neutral state
   //------------------------------------------------------
   outAction.adjustment_reason =
      "No AI governor adjustment needed"
      " | state=" + state.operating_state_text;

   outAction.summary =
      "AI Governor: neutral"
      " | state=" + state.operating_state_text +
      " | dominant=" + agg.dominant_side +
      " | best_strategy=" + bestStrategyId +
      " | quality=" + DoubleToString(agg.council_quality, 2) +
      " | consensus=" + DoubleToString(agg.consensus_strength, 2) +
      " | conflict=" + DoubleToString(agg.conflict_score, 2) +
      " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
      " | fail_pressure=" + failDet.pressure_label;

   return true;
}

#endif
