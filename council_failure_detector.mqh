#ifndef __COUNCIL_FAILURE_DETECTOR_MQH__
#define __COUNCIL_FAILURE_DETECTOR_MQH__

#include "council_mode_types.mqh"
#include "council_memory.mqh"

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
double CouncilFailureClamp01(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

double CouncilFailureSafeDivide(double a, double b)
{
   if(b <= 0.0)
      return 0.0;
   return (a / b);
}

double CouncilFailureWeightedBlend(double a, double wa, double b, double wb)
{
   double wsum = wa + wb;
   if(wsum <= 0.0)
      return 0.0;

   return CouncilFailureClamp01((a * wa + b * wb) / wsum);
}

string CouncilFailureResolveRecommendedState(CouncilFailurePatternReport &r)
{
   if(r.pressure_level == COUNCIL_FAILURE_PRESSURE_CRITICAL)
      return "DEFENSIVE";

   if(r.zone_mismatch_detected || r.low_quality_cluster_detected || r.confirmation_gap_detected)
      return "DEFENSIVE";

   if(r.exhaustion_risk_detected)
      return "EXHAUSTION_SENSITIVE";

   if(r.continuation_fragile && !r.reversal_fragile)
      return "DEFENSIVE";

   if(r.reversal_fragile && !r.continuation_fragile)
      return "NORMAL";

   return "NORMAL";
}

CouncilFailurePressureLevel CouncilFailureResolvePressure(double v)
{
   if(v >= 0.85)
      return COUNCIL_FAILURE_PRESSURE_CRITICAL;

   if(v >= 0.65)
      return COUNCIL_FAILURE_PRESSURE_HIGH;

   if(v >= 0.40)
      return COUNCIL_FAILURE_PRESSURE_MEDIUM;

   if(v >= 0.20)
      return COUNCIL_FAILURE_PRESSURE_LOW;

   return COUNCIL_FAILURE_PRESSURE_NONE;
}

double CouncilFailureSetupPenaltyFromEnvironment(
   CouncilEnvironmentReport &env,
   string setupType
)
{
   setupType = TrimString(setupType);

   if(setupType == "CONTINUATION")
   {
      if(env.zone_name == "TREND_CONTINUATION")
         return 0.0;

      if(env.zone_name == "BREAKOUT_EXPANSION")
         return 0.10;

      if(env.zone_name == "NO_TRADE")
         return 0.60;

      return 0.30;
   }

   if(setupType == "REVERSAL")
   {
      if(env.zone_name == "REVERSAL_EXHAUSTION")
         return 0.0;

      if(env.zone_name == "RANGE_MEAN_RECLAIM")
         return 0.12;

      if(env.zone_name == "NO_TRADE")
         return 0.60;

      return 0.28;
   }

   if(setupType == "MEAN_RECLAIM")
   {
      if(env.zone_name == "RANGE_MEAN_RECLAIM")
         return 0.0;

      if(env.zone_name == "REVERSAL_EXHAUSTION")
         return 0.10;

      if(env.zone_name == "NO_TRADE")
         return 0.60;

      return 0.25;
   }

   if(setupType == "BREAKOUT")
   {
      if(env.zone_name == "BREAKOUT_EXPANSION")
         return 0.0;

      if(env.zone_name == "TREND_CONTINUATION")
         return 0.10;

      if(env.zone_name == "NO_TRADE")
         return 0.60;

      return 0.25;
   }

   return 0.20;
}

double CouncilFailureEnvironmentFragilityPenalty(CouncilEnvironmentReport &env)
{
   double p = 0.0;

   if(!env.tradable)
      p += 0.40;

   if(env.zone_name == "NO_TRADE")
      p += 0.30;

   if(env.exhaustion_hint)
      p += 0.15;

   if(env.zone_confidence >= 0.75 && env.blocked_style_text != "UNSPECIFIED")
      p += 0.05;

   return CouncilFailureClamp01(p);
}

//---------------------------------------------------------
// Core scoring
//---------------------------------------------------------
void BuildCouncilFailureRiskScores(
   CouncilMemorySummary &mem,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilFailurePatternReport &r
)
{
   double executed = (double)mem.executed_records;
   double total    = (double)mem.total_records;

   double lossRate = CouncilFailureSafeDivide((double)mem.losses, (double)(mem.wins + mem.losses));
   double executedParticipation = CouncilFailureSafeDivide(executed, total);

   double lateContinuationBase =
      CouncilFailureSafeDivide((double)mem.late_continuation_failures, executed);

   double weakReversalBase =
      CouncilFailureSafeDivide((double)mem.weak_reversal_failures, executed);

   double zoneMismatchBase =
      CouncilFailureSafeDivide((double)mem.zone_mismatch_failures, executed);

   double highConflictBase =
      CouncilFailureSafeDivide((double)mem.high_conflict_failures, executed);

   double lowQualityBase =
      CouncilFailureSafeDivide((double)mem.low_quality_failures, executed);

   double noConfirmBase =
      CouncilFailureSafeDivide((double)mem.no_confirm_role_failures, executed);

   double exhaustionIgnoredBase =
      CouncilFailureSafeDivide((double)mem.exhaustion_ignored_failures, executed);

   double continuationPenalty = CouncilFailureSetupPenaltyFromEnvironment(env, "CONTINUATION");
   double reversalPenalty     = CouncilFailureSetupPenaltyFromEnvironment(env, "REVERSAL");
   double meanPenalty         = CouncilFailureSetupPenaltyFromEnvironment(env, "MEAN_RECLAIM");
   double breakoutPenalty     = CouncilFailureSetupPenaltyFromEnvironment(env, "BREAKOUT");
   double envFragility        = CouncilFailureEnvironmentFragilityPenalty(env);

   r.continuation_risk_score =
      CouncilFailureClamp01(lateContinuationBase + continuationPenalty + envFragility * 0.35);

   r.reversal_risk_score =
      CouncilFailureClamp01(weakReversalBase + reversalPenalty + envFragility * 0.25);

   r.mean_reclaim_risk_score =
      CouncilFailureClamp01(
         CouncilFailureSafeDivide((double)mem.zone_mismatch_failures + (double)mem.low_quality_failures, executed) * 0.5 +
         meanPenalty +
         envFragility * 0.20
      );

   r.breakout_risk_score =
      CouncilFailureClamp01(
         CouncilFailureSafeDivide((double)mem.high_conflict_failures + (double)mem.low_quality_failures, executed) * 0.5 +
         breakoutPenalty +
         envFragility * 0.20
      );

   r.confirm_gap_risk_score =
      CouncilFailureClamp01(
         noConfirmBase +
         (agg.confirm_role_present ? 0.0 : 0.20) +
         ((agg.consensus_label == "NARROW") ? 0.10 : 0.0)
      );

   r.exhaustion_ignore_risk_score =
      CouncilFailureClamp01(
         exhaustionIgnoredBase +
         (env.exhaustion_hint ? 0.20 : 0.0) +
         (agg.exhaustion_warning ? 0.15 : 0.0)
      );

   r.conflict_risk_score =
      CouncilFailureClamp01(highConflictBase + agg.conflict_score * 0.45);

   r.zone_mismatch_risk_score =
      CouncilFailureClamp01(zoneMismatchBase + ((env.zone_name == "NO_TRADE") ? 0.30 : 0.0));

   r.low_quality_risk_score =
      CouncilFailureClamp01(
         lowQualityBase +
         CouncilFailureSafeDivide((double)mem.low_quality_records, total) * 0.30 +
         ((env.total_score < 0.55) ? 0.10 : 0.0)
      );

   double failureDensity =
      CouncilFailureClamp01(
         lateContinuationBase * 0.18 +
         weakReversalBase     * 0.12 +
         zoneMismatchBase     * 0.18 +
         highConflictBase     * 0.14 +
         lowQualityBase       * 0.16 +
         noConfirmBase        * 0.12 +
         exhaustionIgnoredBase* 0.10
      );

   r.recent_failure_pressure =
      CouncilFailureClamp01(
         failureDensity * 0.55 +
         lossRate * 0.25 +
         (1.0 - executedParticipation) * 0.05 +
         envFragility * 0.15
      );
}

//---------------------------------------------------------
// Main build
//---------------------------------------------------------
bool BuildCouncilFailurePatternReport(
   CouncilMemorySummary &mem,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &agg,
   CouncilFailurePatternReport &r
)
{
   InitCouncilFailurePatternReport(r);

   BuildCouncilFailureRiskScores(mem, env, agg, r);

   r.dominant_failure_tag = TrimString(mem.top_failure_tag);
   r.dominant_setup_type  = TrimString(mem.top_setup_type);

   r.continuation_fragile      = (r.continuation_risk_score >= 0.55);
   r.reversal_fragile          = (r.reversal_risk_score >= 0.55);
   r.confirmation_gap_detected = (r.confirm_gap_risk_score >= 0.50);
   r.exhaustion_risk_detected  = (r.exhaustion_ignore_risk_score >= 0.50);
   r.zone_mismatch_detected    = (r.zone_mismatch_risk_score >= 0.50);
   r.low_quality_cluster_detected = (r.low_quality_risk_score >= 0.50);

   r.pressure_level = CouncilFailureResolvePressure(r.recent_failure_pressure);
   r.pressure_label = CouncilFailurePressureLevelToText(r.pressure_level);

   r.recommended_state = CouncilFailureResolveRecommendedState(r);

   r.recommendation_summary =
      "FailureDetector"
      " | Pressure=" + r.pressure_label +
      " | DominantFailure=" + (StringLen(r.dominant_failure_tag) > 0 ? r.dominant_failure_tag : "-") +
      " | DominantSetup=" + (StringLen(r.dominant_setup_type) > 0 ? r.dominant_setup_type : "-") +
      " | RecommendedState=" + r.recommended_state;

   r.summary =
      "FailurePattern"
      " | Pressure=" + DoubleToString(r.recent_failure_pressure, 2) +
      " | ContRisk=" + DoubleToString(r.continuation_risk_score, 2) +
      " | RevRisk=" + DoubleToString(r.reversal_risk_score, 2) +
      " | ConfirmGap=" + DoubleToString(r.confirm_gap_risk_score, 2) +
      " | ExhaustRisk=" + DoubleToString(r.exhaustion_ignore_risk_score, 2) +
      " | ConflictRisk=" + DoubleToString(r.conflict_risk_score, 2) +
      " | ZoneMismatch=" + DoubleToString(r.zone_mismatch_risk_score, 2) +
      " | LowQuality=" + DoubleToString(r.low_quality_risk_score, 2) +
      " | State=" + r.recommended_state;

   r.valid = true;
   return true;
}

#endif





