#ifndef __COUNCIL_AI_GOVERNOR_MQH__
#define __COUNCIL_AI_GOVERNOR_MQH__

#include "council_mode_types.mqh"

// Structural ownership note:
// This governor is a categorical context observer. Live council pass/fail
// enforcement remains owned by RunCouncilPreAIFilter(...) plus final
// env.tradable/pre.passed branching.

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
// Internal context helpers
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

bool CouncilAIGovC1PreGovernorCandidate(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg
)
{
   return (env.tradable &&
           env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION &&
           agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION &&
           agg.two_or_more_dominant_families);
}

bool CouncilAIGovExhaustionPrecedenceActive(
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg
)
{
   return (env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION ||
           agg.exhaustion_warning);
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
      agg.two_or_more_dominant_families &&
      gate.passed &&
      !env.ceis_overextension_m5)
   {
      return COUNCIL_GOV_STATE_AGGRESSIVE;
   }

   if(agg.consensus_type == COUNCIL_CONSENSUS_NARROW ||
      env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM ||
      env.zone_type == COUNCIL_ZONE_COMPRESSION)
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
      " | consensus=" + agg.consensus_label +
      " | two_families=" + string(agg.two_or_more_dominant_families ? "true" : "false") +
      " | tradable=" + string(env.tradable ? "true" : "false") +
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

   outAction.c1_tc_active              = (env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION);
   outAction.c1_high_conviction_active = (agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION);
   outAction.c1_overextension_active   = env.ceis_overextension_m5;
   outAction.c1_pre_governor_candidate = CouncilAIGovC1PreGovernorCandidate(env, agg);

   CouncilGovernorStateReport state;
   BuildCouncilGovernorStateReport(env, agg, gate, state);

   outAction.change_operating_state      = true;
   outAction.target_operating_state      = state.operating_state;
   outAction.target_operating_state_text = state.operating_state_text;
   outAction.c1_shadowed_by_exhaustion   =
      (outAction.c1_pre_governor_candidate &&
       outAction.c1_overextension_active &&
       CouncilAIGovExhaustionPrecedenceActive(env, agg) &&
       state.operating_state == COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE);
   outAction.c1_shadow_reason =
      (outAction.c1_shadowed_by_exhaustion ? "OVEREXTENSION_EXHAUSTION_PRECEDENCE" : "");

   //------------------------------------------------------
   // Case 0: failure detector pressure context
   //------------------------------------------------------
   if(failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_CRITICAL ||
      failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_HIGH)
   {
      outAction.target_strategy_id = bestStrategyId;
      outAction.reason_code        = "CRIT_PRESSURE";
      outAction.source_flags       = "FAILDET";

      if(failDet.pressure_level == COUNCIL_FAILURE_PRESSURE_CRITICAL)
      {
         outAction.target_operating_state      = COUNCIL_GOV_STATE_CRITICAL_DEFENSIVE;
         outAction.target_operating_state_text = CouncilGovernorOperatingStateToText(COUNCIL_GOV_STATE_CRITICAL_DEFENSIVE);
      }
      else
      {
         outAction.target_operating_state      = COUNCIL_GOV_STATE_DEFENSIVE;
         outAction.target_operating_state_text = CouncilGovernorOperatingStateToText(COUNCIL_GOV_STATE_DEFENSIVE);
      }

      outAction.adjustment_reason =
         "Failure detector pressure elevated"
         " | pressure=" + failDet.pressure_label +
         " | state=" + outAction.target_operating_state_text +
         " | dominant_failure=" + failDet.dominant_failure_tag;

      outAction.summary =
         "AI Governor: failure detector " + outAction.target_operating_state_text + " context"
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
      outAction.target_strategy_id = bestStrategyId;
      outAction.reason_code        = "GATE_FAIL";
      outAction.source_flags       = "GATE";

      outAction.adjustment_reason =
         "Pre-AI gate failed"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: pre-AI gate context"
         " | state=" + state.operating_state_text +
         " | filtered_decision=" + CouncilAIGovDecisionText(gate.filtered_decision) +
         " | best_strategy=" + bestStrategyId +
         " | support=" + secondaryHint;

      return true;
   }

   //------------------------------------------------------
   // Case 2: narrow consensus context
   //------------------------------------------------------
   if(agg.consensus_type == COUNCIL_CONSENSUS_NARROW)
   {
      outAction.target_strategy_id = bestStrategyId;
      outAction.reason_code        = "NARROW_CONTEXT";
      outAction.source_flags       = "AGG";

      outAction.adjustment_reason =
         "Narrow council consensus"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: narrow consensus context"
         " | state=" + state.operating_state_text +
         " | best_strategy=" + bestStrategyId +
         " | consensus=" + agg.consensus_label +
         " | two_families=" + string(agg.two_or_more_dominant_families ? "true" : "false");

      return true;
   }

   //------------------------------------------------------
   // Case 3: confirmation gap detected
   //------------------------------------------------------
   if(failDet.confirmation_gap_detected)
   {
      outAction.target_strategy_id = bestStrategyId;
      outAction.target_operating_state = COUNCIL_GOV_STATE_DEFENSIVE;
      outAction.target_operating_state_text = CouncilGovernorOperatingStateToText(COUNCIL_GOV_STATE_DEFENSIVE);
      outAction.reason_code        = "CONFIRM_GAP";
      outAction.source_flags       = "FAILDET";

      outAction.adjustment_reason =
         "Confirmation gap detected by failure detector";

      outAction.summary =
         "AI Governor: confirmation gap context"
         " | dominant_failure=" + failDet.dominant_failure_tag;

      return true;
   }

   //------------------------------------------------------
   // Case 4: exhaustion-sensitive mode
   //------------------------------------------------------
   if(state.operating_state == COUNCIL_GOV_STATE_EXHAUSTION_SENSITIVE)
   {
      outAction.target_strategy_id = bestStrategyId;
      outAction.reason_code        = "EXHAUST_SENSITIVE";
      outAction.source_flags       = "FAILDET|ENV";

      outAction.adjustment_reason =
         "Exhaustion-sensitive operating state active";

      outAction.summary =
         "AI Governor: exhaustion-sensitive mode"
         " | zone=" + env.zone_name +
         " | best_strategy=" + bestStrategyId +
         " | exhaustion=" + string(agg.exhaustion_warning ? "true" : "false");

      return true;
   }

   //------------------------------------------------------
   // Case 5: aggressive continuation state
   //------------------------------------------------------
   if(state.operating_state == COUNCIL_GOV_STATE_AGGRESSIVE)
   {
      outAction.target_strategy_id = bestStrategyId;

      outAction.adjustment_reason =
         "Aggressive continuation state active";

      outAction.summary =
         "AI Governor: aggressive continuation mode"
         " | zone=" + env.zone_name +
         " | best_strategy=" + bestStrategyId +
         " | two_families=" + string(agg.two_or_more_dominant_families ? "true" : "false");

      return true;
   }

   //------------------------------------------------------
   // Case 6: defensive state
   //------------------------------------------------------
   if(state.operating_state == COUNCIL_GOV_STATE_DEFENSIVE)
   {
      outAction.reason_code  = "DEFENSIVE";
      outAction.source_flags = "FAILDET";

      outAction.adjustment_reason =
         "Defensive operating state active";

      outAction.summary =
         "AI Governor: defensive mode"
         " | zone=" + env.zone_name +
         " | consensus=" + agg.consensus_label +
         " | tradable=" + string(env.tradable ? "true" : "false");

      return true;
   }

   //------------------------------------------------------
   // Case 7: directionless or empty council context
   //------------------------------------------------------
   if(agg.dominant_side == "NONE" || agg.active_strategies <= 0)
   {
      outAction.suggest_mode_exit = true;
      outAction.reason_code       = "NO_DIRECTIONAL_CONTEXT";
      outAction.source_flags      = "AGG";

      outAction.adjustment_reason =
         "Council lacks directional context"
         " | state=" + state.operating_state_text;

      outAction.summary =
         "AI Governor: council mode may be unsuitable right now"
         " | state=" + state.operating_state_text +
         " | dominant=" + agg.dominant_side +
         " | active_strategies=" + IntegerToString(agg.active_strategies);

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
      " | consensus=" + agg.consensus_label +
      " | two_families=" + string(agg.two_or_more_dominant_families ? "true" : "false") +
      " | fail_pressure=" + failDet.pressure_label;

   return true;
}

#endif
