#ifndef __COUNCIL_AGGREGATOR_MQH__
#define __COUNCIL_AGGREGATOR_MQH__

#include "council_mode_types.mqh"
#include "council_adaptive_weights.mqh"

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
double CouncilClamp(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string DirectionToText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY) return "BUY";
   if(d == COUNCIL_DECISION_SELL) return "SELL";
   if(d == COUNCIL_DECISION_REJECT) return "REJECT";
   return "WAIT";
}

bool CouncilStringInList(string csv, string token)
{
   string padded = "," + csv + ",";
   string target = "," + token + ",";
   return (StringFind(padded, target) >= 0);
}

void CouncilAppendCsvUnique(string &csv, string token)
{
   token = TrimString(token);
   if(StringLen(token) <= 0)
      return;

   if(CouncilStringInList(csv, token))
      return;

   if(StringLen(csv) > 0)
      csv += ",";

   csv += token;
}

double CouncilRoleInfluenceMultiplier(CouncilStrategyRole role)
{
   if(role == COUNCIL_ROLE_CONFIRM)
      return 1.10;

   if(role == COUNCIL_ROLE_TREND_JUDGE)
      return 1.12;

   if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
      return 1.05;

   if(role == COUNCIL_ROLE_SCOUT)
      return 1.00;

   if(role == COUNCIL_ROLE_GUARD)
      return 0.80;

   return 1.00;
}

bool CouncilIsDirectionalDecision(CouncilDecision d)
{
   return (d == COUNCIL_DECISION_BUY || d == COUNCIL_DECISION_SELL);
}

CouncilConsensusType CouncilClassifyConsensusType(
   int familyCount,
   bool confirmPresent,
   double consensusStrength,
   double conflictScore,
   double familyDiversityScore
)
{
   if(consensusStrength < 0.45)
      return COUNCIL_CONSENSUS_NONE;

   if(confirmPresent &&
      familyCount >= 2 &&
      familyDiversityScore >= 0.60 &&
      conflictScore <= 0.25 &&
      consensusStrength >= 0.75)
   {
      return COUNCIL_CONSENSUS_HIGH_CONVICTION;
   }

   if(familyCount >= 2 &&
      familyDiversityScore >= 0.45 &&
      consensusStrength >= 0.60)
   {
      return COUNCIL_CONSENSUS_DIVERSE;
   }

   if(consensusStrength >= 0.55)
      return COUNCIL_CONSENSUS_NARROW;

   return COUNCIL_CONSENSUS_NONE;
}

//---------------------------------------------------------
// Main aggregation logic
//---------------------------------------------------------
bool BuildCouncilAggregateReport(
   CouncilStrategyReport &reports[],
   int reportCount,
   CouncilEnvironmentReport &env,
   CouncilAggregateReport &outReport
)
{
   InitCouncilAggregateReport(outReport);
   string aw_notes = "";

   if(reportCount <= 0)
      return false;

   double buyWeight     = 0.0;
   double sellWeight    = 0.0;
   double neutralWeight = 0.0;

   int buyVotes     = 0;
   int sellVotes    = 0;
   int neutralVotes = 0;

   double bestScore = -1.0;
   string bestStrategy = "";

   string supportList = "";

   string buyFamilies  = "";
   string sellFamilies = "";

   int buyFamilyCount  = 0;
   int sellFamilyCount = 0;

   bool confirmSupportsDominant = false;
   bool trendJudgeSupportsDominant = false;
   bool exhaustionWarning = false;

   double sumZoneAlignment = 0.0;
   int    countedZoneAlign = 0;

   //------------------------------------------------------
   // Iterate strategies
   //------------------------------------------------------
   for(int i = 0; i < reportCount; i++)
   {
      CouncilStrategyReport s = reports[i];

      if(!s.valid)
         continue;

      if(!s.enabled)
         continue;

      outReport.active_strategies++;

      double roleMultiplier = CouncilRoleInfluenceMultiplier(s.role);

      double awMul = 1.0;
      string awSummary = "";
      if(CouncilAdaptiveWeights_IsEnabled())
         awMul = CouncilAdaptiveWeights_StrategyMultiplier(s, env, awSummary);

      double weight = s.score_final * s.vote_weight * roleMultiplier * awMul;

      if(StringLen(awSummary) > 0)
         aw_notes += (StringLen(aw_notes) > 0 ? " | " : "") + awSummary;

      if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
         weight = 0.0;
      else if(s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
         weight *= 0.15;
      else if(s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
         weight *= 0.75;

      weight = CouncilClamp(weight);

      sumZoneAlignment += s.zone_alignment_score;
      countedZoneAlign++;

      //---------------------------------------------------
      // directional accounting
      //---------------------------------------------------
      if(s.decision == COUNCIL_DECISION_BUY)
      {
         buyVotes++;
         buyWeight += weight;

         CouncilAppendCsvUnique(supportList, s.strategy_id);

         if(!CouncilStringInList(buyFamilies, s.strategy_family))
         {
            CouncilAppendCsvUnique(buyFamilies, s.strategy_family);
            buyFamilyCount++;
         }

         if(s.role == COUNCIL_ROLE_CONFIRM)
            confirmSupportsDominant = true;

         if(s.role == COUNCIL_ROLE_TREND_JUDGE)
            trendJudgeSupportsDominant = true;
      }
      else if(s.decision == COUNCIL_DECISION_SELL)
      {
         sellVotes++;
         sellWeight += weight;

         CouncilAppendCsvUnique(supportList, s.strategy_id);

         if(!CouncilStringInList(sellFamilies, s.strategy_family))
         {
            CouncilAppendCsvUnique(sellFamilies, s.strategy_family);
            sellFamilyCount++;
         }

         if(s.role == COUNCIL_ROLE_CONFIRM)
            confirmSupportsDominant = true;

         if(s.role == COUNCIL_ROLE_TREND_JUDGE)
            trendJudgeSupportsDominant = true;
      }
      else
      {
         neutralVotes++;
         neutralWeight += weight;

         if(s.role == COUNCIL_ROLE_EXHAUSTION_JUDGE &&
            (s.eligibility_state == COUNCIL_ELIGIBILITY_ACTIVE ||
             s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED) &&
            s.zone_alignment_score >= 0.70)
         {
            exhaustionWarning = true;
         }
      }

      //---------------------------------------------------
      // Track best strategy
      //---------------------------------------------------
      if(s.score_final > bestScore)
      {
         bestScore = s.score_final;
         bestStrategy = s.strategy_id;
      }
   }

   //------------------------------------------------------
   // Fill report values
   //------------------------------------------------------
   outReport.buy_votes            = buyVotes;
   outReport.sell_votes           = sellVotes;
   outReport.neutral_votes        = neutralVotes;

   outReport.total_buy_weight     = buyWeight;
   outReport.total_sell_weight    = sellWeight;
   outReport.total_neutral_weight = neutralWeight;

   outReport.best_strategy_id     = bestStrategy;
   outReport.support_strategy_ids = supportList;

   //------------------------------------------------------
   // Dominant side
   //------------------------------------------------------
   if(buyWeight > sellWeight)
      outReport.dominant_side = "BUY";
   else if(sellWeight > buyWeight)
      outReport.dominant_side = "SELL";
   else
      outReport.dominant_side = "NONE";

   //------------------------------------------------------
   // Consensus strength
   //------------------------------------------------------
   double totalDirectional = buyWeight + sellWeight;

   if(totalDirectional > 0.0)
   {
      double dominant = MathMax(buyWeight, sellWeight);
      outReport.consensus_strength = CouncilClamp(dominant / totalDirectional);
   }
   else
   {
      outReport.consensus_strength = 0.0;
   }

   //------------------------------------------------------
   // Conflict score
   //------------------------------------------------------
   if(buyWeight > 0.0 && sellWeight > 0.0)
   {
      double smaller = MathMin(buyWeight, sellWeight);
      double larger  = MathMax(buyWeight, sellWeight);

      if(larger > 0.0)
         outReport.conflict_score = CouncilClamp(smaller / larger);
      else
         outReport.conflict_score = 0.0;
   }
   else
   {
      outReport.conflict_score = 0.0;
   }

   //------------------------------------------------------
   // Environment + alignment
   //------------------------------------------------------
   outReport.environment_score = env.total_score;

   if(countedZoneAlign > 0)
      outReport.zone_alignment_score = CouncilClamp(sumZoneAlignment / countedZoneAlign);
   else
      outReport.zone_alignment_score = 0.0;

   //------------------------------------------------------
   // Family diversity
   //------------------------------------------------------
   int dominantFamilyCount = 0;
   if(outReport.dominant_side == "BUY")
      dominantFamilyCount = buyFamilyCount;
   else if(outReport.dominant_side == "SELL")
      dominantFamilyCount = sellFamilyCount;

   if(dominantFamilyCount <= 0)
      outReport.family_diversity_score = 0.0;
   else if(dominantFamilyCount == 1)
      outReport.family_diversity_score = 0.35;
   else if(dominantFamilyCount == 2)
      outReport.family_diversity_score = 0.70;
   else
      outReport.family_diversity_score = 1.0;

   //------------------------------------------------------
   // Role-aware flags
   //------------------------------------------------------
   outReport.confirm_role_present   = confirmSupportsDominant;
   outReport.trend_judge_supportive = trendJudgeSupportsDominant;
   outReport.exhaustion_warning     = exhaustionWarning || env.exhaustion_hint;

   //------------------------------------------------------
   // Consensus type
   //------------------------------------------------------
   outReport.consensus_type = CouncilClassifyConsensusType(
      dominantFamilyCount,
      outReport.confirm_role_present,
      outReport.consensus_strength,
      outReport.conflict_score,
      outReport.family_diversity_score
   );

   outReport.consensus_label = CouncilConsensusTypeToText(outReport.consensus_type);

   //------------------------------------------------------
   // Council quality
   //------------------------------------------------------
   double bestScoreSafe = (bestScore > 0.0 ? bestScore : 0.0);

   outReport.council_quality =
      (outReport.consensus_strength   * 0.32) +
      (outReport.environment_score    * 0.18) +
      (bestScoreSafe                  * 0.15) +
      (outReport.family_diversity_score * 0.15) +
      (outReport.zone_alignment_score * 0.10) +
      (outReport.confirm_role_present ? 0.06 : 0.00) +
      (outReport.trend_judge_supportive ? 0.04 : 0.00);

   if(outReport.consensus_type == COUNCIL_CONSENSUS_HIGH_CONVICTION)
      outReport.council_quality += 0.05;
   else if(outReport.consensus_type == COUNCIL_CONSENSUS_NARROW)
      outReport.council_quality -= 0.05;

   if(outReport.exhaustion_warning &&
      (env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
       env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION))
   {
      outReport.council_quality -= 0.08;
   }

   if(outReport.exhaustion_warning &&
      env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
   {
      outReport.council_quality += 0.04;
   }

   outReport.council_quality = CouncilClamp(outReport.council_quality);

   //------------------------------------------------------
   // Summary
   //------------------------------------------------------
   outReport.summary =
      "CouncilAgg"
      " | BUYw=" + DoubleToString(buyWeight, 2) +
      " | SELLw=" + DoubleToString(sellWeight, 2) +
      " | Consensus=" + DoubleToString(outReport.consensus_strength, 2) +
      " | Conflict=" + DoubleToString(outReport.conflict_score, 2) +
      " | Diversity=" + DoubleToString(outReport.family_diversity_score, 2) +
      " | ZoneAlign=" + DoubleToString(outReport.zone_alignment_score, 2) +
      " | Confirm=" + string(outReport.confirm_role_present ? "true" : "false") +
      " | TrendJudge=" + string(outReport.trend_judge_supportive ? "true" : "false") +
      " | ExhaustionWarn=" + string(outReport.exhaustion_warning ? "true" : "false") +
      " | Type=" + outReport.consensus_label +
      " | Env=" + DoubleToString(env.total_score, 2) +
      " | Quality=" + DoubleToString(outReport.council_quality, 2) +
      " | Best=" + bestStrategy;

   if(StringLen(aw_notes) > 0)
      outReport.summary += " | AW[" + aw_notes + "]";

   outReport.valid = true;

   return true;
}

#endif
