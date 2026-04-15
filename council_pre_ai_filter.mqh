#ifndef __COUNCIL_PRE_AI_FILTER_MQH__
#define __COUNCIL_PRE_AI_FILTER_MQH__

#include "council_mode_types.mqh"

//---------------------------------------------------------
// Helper
//---------------------------------------------------------
string CouncilPreAIDecisionText(CouncilDecision d)
{
   return CouncilDecisionToText(d);
}

//---------------------------------------------------------
// Init
//---------------------------------------------------------
void InitCouncilPreAIGateReportEx(CouncilPreAIGateReport &r)
{
   InitCouncilPreAIGateReport(r);
}

//---------------------------------------------------------
// Core Filter Logic
//---------------------------------------------------------
bool RunCouncilPreAIFilter(
   CouncilAggregateReport &agg,
   CouncilEnvironmentReport &env,
   CouncilPreAIGateReport &result
)
{
   InitCouncilPreAIGateReportEx(result);

   if(!agg.valid)
   {
      result.reason = "Aggregate report invalid";
      result.summary = result.reason;
      return false;
   }

   if(!env.valid)
   {
      result.reason = "Environment report invalid";
      result.summary = result.reason;
      return false;
   }

   result.valid = true;

   //-----------------------------------------------------
   // Base thresholds
   //-----------------------------------------------------
   result.min_required_council_quality   = 0.55;
   result.max_allowed_conflict           = 0.55;
   result.min_required_environment_score = 0.40;
   result.min_required_consensus         = 0.45;

   //-----------------------------------------------------
   // Adaptive thresholds by zone / consensus context
   //-----------------------------------------------------
   if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
      env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
   {
      result.min_required_consensus       = 0.55;
      result.max_allowed_conflict         = 0.40;
      result.min_required_council_quality = 0.58;
   }

   if(env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
   {
      result.min_required_consensus       = 0.50;
      result.max_allowed_conflict         = 0.30;
      result.min_required_council_quality = 0.58;
   }

   if(env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)
   {
      result.min_required_consensus       = 0.45;
      result.max_allowed_conflict         = 0.45;
      result.min_required_council_quality = 0.55;
   }

   if(env.zone_confidence < 0.50)
   {
      result.min_required_consensus       += 0.05;
      result.min_required_council_quality += 0.03;
   }

   if(agg.consensus_type == COUNCIL_CONSENSUS_NARROW)
   {
      result.min_required_consensus       += 0.05;
      result.min_required_council_quality += 0.03;
      result.max_allowed_conflict         -= 0.10;
   }

   if(agg.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION)
   {
      result.min_required_consensus       -= 0.03;
      result.max_allowed_conflict         += 0.05;
   }

   if(agg.family_diversity_score < 0.45)
   {
      result.min_required_council_quality += 0.03;
   }

   if(!agg.confirm_role_present)
   {
      result.min_required_council_quality += 0.02;
   }

   if(env.exhaustion_hint && agg.exhaustion_warning &&
      (env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
       env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION))
   {
      result.max_allowed_conflict         -= 0.10;
      result.min_required_council_quality += 0.04;
   }

   //-----------------------------------------------------
   // Clamp adaptive thresholds
   //-----------------------------------------------------
   if(result.min_required_consensus < 0.35)
      result.min_required_consensus = 0.35;
   if(result.min_required_consensus > 0.80)
      result.min_required_consensus = 0.80;

   if(result.max_allowed_conflict < 0.15)
      result.max_allowed_conflict = 0.15;
   if(result.max_allowed_conflict > 0.80)
      result.max_allowed_conflict = 0.80;

   if(result.min_required_environment_score < 0.30)
      result.min_required_environment_score = 0.30;
   if(result.min_required_environment_score > 0.80)
      result.min_required_environment_score = 0.80;

   if(result.min_required_council_quality < 0.40)
      result.min_required_council_quality = 0.40;
   if(result.min_required_council_quality > 0.85)
      result.min_required_council_quality = 0.85;

   //-----------------------------------------------------
   // Hard no-trade zone
   //-----------------------------------------------------
   if(env.zone_type == COUNCIL_ZONE_NO_TRADE)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Environment zone is NO_TRADE";
      result.summary =
         "Pre-AI rejected"
         " | zone=" + env.zone_name +
         " | reason=NO_TRADE";
      return true;
   }

   //-----------------------------------------------------
   // Environment quality
   //-----------------------------------------------------
   if(env.total_score < result.min_required_environment_score)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Environment score too weak";
      result.summary =
         "Pre-AI rejected"
         " | zone=" + env.zone_name +
         " | env_score=" + DoubleToString(env.total_score, 2) +
         " | required=" + DoubleToString(result.min_required_environment_score, 2);
      return true;
   }

   //-----------------------------------------------------
   // Council quality
   //-----------------------------------------------------
   if(agg.council_quality < result.min_required_council_quality)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Council quality below threshold";
      result.summary =
         "Pre-AI rejected"
         " | zone=" + env.zone_name +
         " | consensus_label=" + agg.consensus_label +
         " | council_quality=" + DoubleToString(agg.council_quality, 2) +
         " | required=" + DoubleToString(result.min_required_council_quality, 2);
      return true;
   }

   //-----------------------------------------------------
   // Consensus check
   //-----------------------------------------------------
   if(agg.consensus_strength < result.min_required_consensus)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Consensus too weak";
      result.summary =
         "Pre-AI rejected"
         " | consensus_label=" + agg.consensus_label +
         " | consensus=" + DoubleToString(agg.consensus_strength, 2) +
         " | required=" + DoubleToString(result.min_required_consensus, 2);
      return true;
   }

   //-----------------------------------------------------
   // Conflict check
   //-----------------------------------------------------
   if(agg.conflict_score > result.max_allowed_conflict)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Council conflict too high";
      result.summary =
         "Pre-AI rejected"
         " | consensus_label=" + agg.consensus_label +
         " | conflict=" + DoubleToString(agg.conflict_score, 2) +
         " | max=" + DoubleToString(result.max_allowed_conflict, 2);
      return true;
   }

   //-----------------------------------------------------
   // Diversity / confirmation quality checks
   //-----------------------------------------------------
   if(agg.family_diversity_score < 0.30 && agg.consensus_type != COUNCIL_CONSENSUS_HIGH_CONVICTION)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Directional agreement too narrow";
      result.summary =
         "Pre-AI rejected"
         " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
         " | consensus_label=" + agg.consensus_label;
      return true;
   }

   if(!agg.confirm_role_present &&
      env.zone_type != COUNCIL_ZONE_BREAKOUT_EXPANSION &&
      agg.consensus_type != COUNCIL_CONSENSUS_HIGH_CONVICTION)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.reason = "Confirmation role missing";
      result.summary =
         "Pre-AI rejected"
         " | confirm_role_present=false"
         " | zone=" + env.zone_name;
      return true;
   }

   //-----------------------------------------------------
   // Tradable decision check
   //-----------------------------------------------------
   if(agg.dominant_side != "BUY" && agg.dominant_side != "SELL")
   {
      result.filtered_decision = COUNCIL_DECISION_WAIT;
      result.passed = false;
      result.reason = "Council decision not tradable";
      result.summary = "Pre-AI rejected | dominant side is NONE";
      return true;
   }

   //-----------------------------------------------------
   // Passed
   //-----------------------------------------------------
   result.passed = true;
   result.filtered_decision =
      (agg.dominant_side == "BUY") ? COUNCIL_DECISION_BUY : COUNCIL_DECISION_SELL;

   result.reason = "Council case accepted";

   result.summary =
      "Pre-AI passed"
      " | decision=" + CouncilPreAIDecisionText(result.filtered_decision) +
      " | zone=" + env.zone_name +
      " | zone_conf=" + DoubleToString(env.zone_confidence, 2) +
      " | env=" + DoubleToString(env.total_score, 2) +
      " | quality=" + DoubleToString(agg.council_quality, 2) +
      " | consensus=" + DoubleToString(agg.consensus_strength, 2) +
      " | conflict=" + DoubleToString(agg.conflict_score, 2) +
      " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
      " | type=" + agg.consensus_label;

   return true;
}

//---------------------------------------------------------
// Diagnostic helper
//---------------------------------------------------------
string BuildCouncilPreAIFilterSummary(
   CouncilAggregateReport &agg,
   CouncilEnvironmentReport &env,
   CouncilPreAIGateReport &gate
)
{
   string s = "";

   s += "PRE-AI FILTER SUMMARY\n";
   s += "decision: " + CouncilPreAIDecisionText(gate.filtered_decision) + "\n";
   s += "zone_name: " + env.zone_name + "\n";
   s += "zone_confidence: " + DoubleToString(env.zone_confidence, 4) + "\n";
   s += "environment_score: " + DoubleToString(env.total_score, 4) + "\n";
   s += "council_quality: " + DoubleToString(agg.council_quality, 4) + "\n";
   s += "consensus_strength: " + DoubleToString(agg.consensus_strength, 4) + "\n";
   s += "conflict_score: " + DoubleToString(agg.conflict_score, 4) + "\n";
   s += "family_diversity: " + DoubleToString(agg.family_diversity_score, 4) + "\n";
   s += "zone_alignment: " + DoubleToString(agg.zone_alignment_score, 4) + "\n";
   s += "consensus_label: " + agg.consensus_label + "\n";
   s += "confirm_role_present: " + string(agg.confirm_role_present ? "true" : "false") + "\n";
   s += "exhaustion_warning: " + string(agg.exhaustion_warning ? "true" : "false") + "\n";
   s += "passed: " + string(gate.passed ? "true" : "false") + "\n";
   s += "reason: " + gate.reason + "\n";

   return s;
}

#endif
