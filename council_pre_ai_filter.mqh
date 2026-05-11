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

string CouncilPreAIA2WouldGateSummary(const CouncilPreAIGateReport &result)
{
   string s = "";

   if(result.pre_ai_would_have_gated_quality)
      s += "WOULD_HAVE_GATED_QUALITY";

   if(result.pre_ai_would_have_gated_consensus)
   {
      if(StringLen(s) > 0)
         s += ",";
      s += "WOULD_HAVE_GATED_CONSENSUS";
   }

   if(result.pre_ai_would_have_gated_conflict)
   {
      if(StringLen(s) > 0)
         s += ",";
      s += "WOULD_HAVE_GATED_CONFLICT";
   }

   if(StringLen(s) <= 0)
      s = "NONE";

   return s;
}

string CouncilPreAIA2DiagnosticSummary(const CouncilPreAIGateReport &result)
{
   return " | a2_score_gates=A2_SCORE_GATE_DEMOTED"
          " | a2_score_gate_role=SCORE_GATE_DIAGNOSTIC_ONLY"
          " | a2_obs_q=" + DoubleToString(result.pre_ai_obs_council_quality, 2) +
          " | a2_obs_c=" + DoubleToString(result.pre_ai_obs_consensus_strength, 2) +
          " | a2_obs_cf=" + DoubleToString(result.pre_ai_obs_conflict_score, 2) +
          " | a2_would_gate=" + CouncilPreAIA2WouldGateSummary(result);
}

void CouncilPreAIFinalizeObstacleEvidence(
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &result,
   double noC2MinRequiredConsensus,
   double noC3MinRequiredConsensus,
   double noC3MinRequiredCouncilQuality
)
{
   result.c2_pre_consensus_requirement =
      (result.c2_overextension_m5_active ? noC2MinRequiredConsensus : result.min_required_consensus);
   result.c2_post_consensus_requirement = result.min_required_consensus;
   result.c2_effective_on_outcome = false;

   if(!result.c2_overextension_m5_active)
      result.c2_gate_outcome = "NOT_APPLICABLE";
   else
      result.c2_gate_outcome = "A2_SCORE_GATE_DEMOTED_NO_OUTCOME_EFFECT";

   result.c3_effective_on_outcome = false;

   if(!result.c3_logic_applied)
      result.c3_gate_outcome = "NOT_APPLICABLE";
   else
      result.c3_gate_outcome = "A2_SCORE_GATE_DEMOTED_NO_OUTCOME_EFFECT";
}

//---------------------------------------------------------
// Core Filter Logic
//---------------------------------------------------------
bool RunCouncilPreAIFilter(
   CouncilAggregateReport &agg,
   CouncilEnvironmentReport &env,
   CouncilPolicyAdjustment &gov,
   ZoneCoverageReport &coverage,
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
   result.c2_overextension_m5_active      = env.ceis_overextension_m5;
   result.c2_consensus_tightening_applied = false;
   result.c2_consensus_tightening_delta   = 0.0;
   result.c3_low_structure_tc_active      =
      (env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION &&
       env.structure_score < 0.70);
   result.c3_structure_score              = env.structure_score;
   result.c3_logic_applied                = false;

   //-----------------------------------------------------
   // Base thresholds
   //-----------------------------------------------------
   result.min_required_council_quality   = 0.55;
   result.max_allowed_conflict           = 0.55;
   result.min_required_environment_score = 0.40;
   result.min_required_consensus         = 0.45;

   double noC2MinRequiredConsensus       = result.min_required_consensus;
   double noC3MinRequiredConsensus       = result.min_required_consensus;
   double noC3MinRequiredCouncilQuality  = result.min_required_council_quality;

   //-----------------------------------------------------
   // Package 2 — Adaptive threshold machinery removed as dead code.
   // Since Stage A2, council_quality / consensus / conflict score gates are
   // diagnostics only. The old zone-adaptive, coverage, governor, CEIS,
   // C2/C3, and clamp threshold machinery was overwritten by the A2 reset
   // block and no longer feeds any live gate. Gate 2 env.total_score was
   // removed in Package 1. Structural validators below retain authority.
   //-----------------------------------------------------

   //-----------------------------------------------------
   // A2 -- score-gate demotion normalization
   // Legacy score thresholds remain diagnostics only.
   //-----------------------------------------------------
   result.min_required_council_quality   = 0.55;
   result.min_required_consensus         = 0.45;
   result.max_allowed_conflict           = 0.55;
   noC2MinRequiredConsensus              = result.min_required_consensus;
   noC3MinRequiredConsensus              = result.min_required_consensus;
   noC3MinRequiredCouncilQuality         = result.min_required_council_quality;
   result.c2_consensus_tightening_applied = false;
   result.c2_consensus_tightening_delta   = 0.0;
   result.c3_logic_applied                = result.c3_low_structure_tc_active;

   result.pre_ai_score_gates_demoted        = true;
   result.pre_ai_obs_council_quality        = agg.council_quality;
   result.pre_ai_obs_consensus_strength     = agg.consensus_strength;
   result.pre_ai_obs_conflict_score         = agg.conflict_score;
   result.pre_ai_would_have_gated_quality   = (agg.council_quality < result.min_required_council_quality);
   result.pre_ai_would_have_gated_consensus = (agg.consensus_strength < result.min_required_consensus);
   result.pre_ai_would_have_gated_conflict  = (agg.conflict_score > result.max_allowed_conflict);

   //-----------------------------------------------------
   // Hard no-trade zone
   //-----------------------------------------------------
   if(env.zone_type == COUNCIL_ZONE_NO_TRADE)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.structural_reject_gate = "NO_TRADE_ZONE";
      result.structural_reject_gate_detail = "zone=NO_TRADE";
      result.pre_ai_structural_passed = false;
      result.reason = "Environment zone is NO_TRADE";
      result.summary =
         "Pre-AI rejected"
         " | zone=" + env.zone_name +
         " | reason=NO_TRADE" +
         CouncilPreAIA2DiagnosticSummary(result);
      CouncilPreAIFinalizeObstacleEvidence(
         agg,
         result,
         noC2MinRequiredConsensus,
         noC3MinRequiredConsensus,
         noC3MinRequiredCouncilQuality
      );
      return true;
   }

   //-----------------------------------------------------
   // Package 1 -- Environment total_score is diagnostic only.
   // No live rejection is produced from env.total_score.
   // Structural validators below retain authority.
   //-----------------------------------------------------

   //-----------------------------------------------------
   // A2 -- quality / consensus / conflict are diagnostics only.
   // No REJECT is produced here; structural validators below retain authority.
   //-----------------------------------------------------

   //-----------------------------------------------------
   // Diversity / confirmation quality checks
   // STRUCTURAL GATE — governor-independent by design (PLAN-4 invariant)
   //-----------------------------------------------------
   if(agg.family_diversity_score < 0.30 && agg.consensus_type != COUNCIL_CONSENSUS_HIGH_CONVICTION)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.structural_reject_gate = "DIVERSITY_SAFETY_NET";
      result.structural_reject_gate_detail = "family_diversity_below_structural_floor";
      result.pre_ai_structural_passed = false;
      result.reason = "Directional agreement too narrow";
      result.summary =
         "Pre-AI rejected"
         " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
         " | consensus_label=" + agg.consensus_label +
         CouncilPreAIA2DiagnosticSummary(result);
      CouncilPreAIFinalizeObstacleEvidence(
         agg,
         result,
         noC2MinRequiredConsensus,
         noC3MinRequiredConsensus,
         noC3MinRequiredCouncilQuality
      );
      return true;
   }

   // STRUCTURAL GATE — governor-independent by design (PLAN-4 invariant)
   if(!agg.confirm_role_present &&
      env.zone_type != COUNCIL_ZONE_BREAKOUT_EXPANSION &&
      agg.consensus_type != COUNCIL_CONSENSUS_HIGH_CONVICTION)
   {
      result.filtered_decision = COUNCIL_DECISION_REJECT;
      result.passed = false;
      result.structural_reject_gate = "CONFIRM_ROLE_REQUIRED";
      result.structural_reject_gate_detail = "confirm_role_absent";
      result.pre_ai_structural_passed = false;
      result.reason = "Confirmation role missing";
      result.summary =
         "Pre-AI rejected"
         " | confirm_role_present=false"
         " | zone=" + env.zone_name +
         CouncilPreAIA2DiagnosticSummary(result);
      CouncilPreAIFinalizeObstacleEvidence(
         agg,
         result,
         noC2MinRequiredConsensus,
         noC3MinRequiredConsensus,
         noC3MinRequiredCouncilQuality
      );
      return true;
   }

   //-----------------------------------------------------
   // Tradable decision check
   //-----------------------------------------------------
   if(agg.dominant_side != "BUY" && agg.dominant_side != "SELL")
   {
      result.filtered_decision = COUNCIL_DECISION_WAIT;
      result.passed = false;
      result.structural_reject_gate = "DOMINANT_SIDE_REQUIRED";
      result.structural_reject_gate_detail = "dominant_side_none";
      result.pre_ai_structural_passed = false;
      result.reason = "Council decision not tradable";
      result.summary = "Pre-AI rejected | dominant side is NONE" +
                       CouncilPreAIA2DiagnosticSummary(result);
      CouncilPreAIFinalizeObstacleEvidence(
         agg,
         result,
         noC2MinRequiredConsensus,
         noC3MinRequiredConsensus,
         noC3MinRequiredCouncilQuality
      );
      return true;
   }

   //-----------------------------------------------------
   // Passed
   //-----------------------------------------------------
   result.passed = true;
   result.filtered_decision =
      (agg.dominant_side == "BUY") ? COUNCIL_DECISION_BUY : COUNCIL_DECISION_SELL;
   result.structural_reject_gate = "PASSED_STRUCTURAL";
   result.structural_reject_gate_detail = "direction=" + agg.dominant_side;
   result.pre_ai_structural_passed = true;

   result.reason = "Council case accepted";

   result.summary =
      "Pre-AI passed"
      " | decision=" + CouncilPreAIDecisionText(result.filtered_decision) +
      " | zone=" + env.zone_name +
      " | zone_conf=" + DoubleToString(env.zone_confidence, 2) +
      " | struct=" + DoubleToString(env.structure_score, 2) +
      " | env=" + DoubleToString(env.total_score, 2) +
      " | quality=" + DoubleToString(agg.council_quality, 2) +
      " | consensus=" + DoubleToString(agg.consensus_strength, 2) +
      " | conflict=" + DoubleToString(agg.conflict_score, 2) +
      " | diversity=" + DoubleToString(agg.family_diversity_score, 2) +
      " | type=" + agg.consensus_label +
      CouncilPreAIA2DiagnosticSummary(result);

   CouncilPreAIFinalizeObstacleEvidence(
      agg,
      result,
      noC2MinRequiredConsensus,
      noC3MinRequiredConsensus,
      noC3MinRequiredCouncilQuality
   );

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
