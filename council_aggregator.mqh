#ifndef __COUNCIL_AGGREGATOR_MQH__
#define __COUNCIL_AGGREGATOR_MQH__

#include "council_mode_types.mqh"
#include "council_v1_state_composer.mqh"
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

bool IRREW_IsAdmissionEligibleContributor(const CouncilStrategyReport &s, const string dominantSide)
{
   if(!s.valid || !s.enabled || !s.trigger_present)
      return false;

   if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED ||
      s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      return false;

   if(dominantSide == "BUY" && s.decision != COUNCIL_DECISION_BUY)
      return false;
   if(dominantSide == "SELL" && s.decision != COUNCIL_DECISION_SELL)
      return false;
   if(dominantSide != "BUY" && dominantSide != "SELL")
      return false;

   double w = s.vote_weight * CouncilRoleInfluenceMultiplier(s.role);
   if(s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
      w *= 0.75;
   w = CouncilClamp(w);

   return (w > 0.0);
}

double IRREW_AdmissionContributorWeight(const CouncilStrategyReport &s)
{
   double w = s.vote_weight * CouncilRoleInfluenceMultiplier(s.role);
   if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
      w = 0.0;
   else if(s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      w = 0.0;
   else if(s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
      w *= 0.75;
   return CouncilClamp(w);
}

void IRREW_ResolveAdmissionIdentity(
   CouncilStrategyReport &reports[],
   int reportCount,
   const CouncilAggregateReport &agg,
   CouncilExecutionAdmissionIdentity &outIdentity
)
{
   InitCouncilExecutionAdmissionIdentity(outIdentity);
   outIdentity.primary_thesis_strategy_id = agg.best_strategy_id;

   double bestWeight = -1.0;
   string bestFamily = "";
   string bestStrategy = "";

   for(int i = 0; i < reportCount; i++)
   {
      CouncilStrategyReport s = reports[i];
      if(!IRREW_IsAdmissionEligibleContributor(s, agg.dominant_side))
         continue;

      double w = IRREW_AdmissionContributorWeight(s);
      if(w > bestWeight)
      {
         bestWeight = w;
         bestFamily = s.strategy_family;
         bestStrategy = s.strategy_id;
      }
   }

   if(StringLen(TrimString(bestFamily)) > 0)
   {
      outIdentity.execution_admission_family = bestFamily;
      outIdentity.execution_admission_source = "DOMINANT_SIDE_EXECUTABLE_CONTRIBUTOR";
      outIdentity.execution_admission_reason =
         "strategy=" + bestStrategy + "|dominant_side=" + agg.dominant_side;
      return;
   }

   outIdentity.execution_admission_family = LAB_InferFamilyFromStrategyId(agg.best_strategy_id);
   outIdentity.execution_admission_source = "FALLBACK_BEST_STRATEGY";
   outIdentity.execution_admission_reason =
      "no_safe_executable_contributor|best_strategy_id=" + agg.best_strategy_id;
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
   const CouncilV1EarlyInfluenceContext &v1Early,
   const bool v1FswEnabled,
   const bool v1Phase2Enabled,
   const CouncilV1ConstructiveEligibilitySummary &v1Policy,
   CouncilAggregateReport &outReport
)
{
   InitCouncilAggregateReport(outReport);
   string aw_notes = "";
   if(CouncilAdaptiveWeights_IsEnabled())
      aw_notes = "ADAPTIVE_WEIGHTS_QUARANTINED_NO_LIVE_WEIGHT_EFFECT";

   outReport.v1_fsw_enabled = v1FswEnabled;
   outReport.v1_fsw_phase2_active = (v1FswEnabled && v1Phase2Enabled && v1Early.valid);
   outReport.v1_fsw_version = "V1_FSW_PHASE1";
   outReport.v1_fsw_authority_class = "BOUNDED_PARTICIPATION_INFLUENCE_ONLY";
   outReport.v1_fsw_action_taken = (v1FswEnabled ? "OBSERVED_NO_ADJUSTMENT" : "DISABLED_NO_ADJUSTMENT");
   outReport.v1_fsw_state_label = v1Early.state_label;
   outReport.v1_fsw_policy_posture = v1Early.policy_posture;
   outReport.v1_fsw_native_families = v1Early.native_families;
   outReport.v1_fsw_conditional_families = v1Early.conditional_families;
   outReport.v1_fsw_deprioritized_families = v1Early.deprioritized_families;
   outReport.v1_fsw_bypass_reason = (v1FswEnabled ? v1Early.bypass_reason : "FLAG_DISABLED");
   outReport.v1_fsw_no_veto = true;
   outReport.v1_fsw_no_final_permission_effect = true;

   outReport.v1_constructive_policy_version = v1Policy.version;
   outReport.v1_policy_constructive_active = v1Policy.active;
   outReport.v1_policy_state_label = v1Policy.state_label;
   outReport.v1_policy_posture = v1Policy.policy_posture;
   outReport.v1_policy_native_families = v1Policy.native_families;
   outReport.v1_policy_conditional_families = v1Policy.conditional_families;
   outReport.v1_policy_deprioritized_families = v1Policy.deprioritized_families;
   outReport.v1_policy_informational_families = v1Policy.informational_families;
   outReport.v1_policy_eligible_strategy_count = v1Policy.eligible_strategy_count;
   outReport.v1_policy_suppressed_strategy_count = v1Policy.suppressed_strategy_count;
   outReport.v1_policy_informational_strategy_count = v1Policy.informational_strategy_count;
   outReport.v1_policy_unknown_strategy_count = v1Policy.unknown_strategy_count;
   outReport.v1_policy_score_sovereignty_blocked = v1Policy.score_sovereignty_blocked;
   outReport.v1_policy_score_role = v1Policy.score_role;
   outReport.v1_policy_score_could_not_admit_suppressed = v1Policy.score_could_not_admit_suppressed;
   outReport.v1_policy_score_could_not_override_state = v1Policy.score_could_not_override_state;
   outReport.v1_policy_authority_class = v1Policy.authority_class;
   outReport.v1_policy_strategy_attributions = v1Policy.strategy_attributions;

   if(reportCount <= 0)
      return false;

   double buyWeight     = 0.0;
   double sellWeight    = 0.0;
   double neutralWeight = 0.0;

   int buyVotes     = 0;
   int sellVotes    = 0;
   int neutralVotes = 0;

   double bestScore = -1.0;
   double bestContribution = -1.0;
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

      double weight = s.vote_weight * roleMultiplier;

      if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
         weight = 0.0;
      else if(s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
         weight *= 0.15;
      else if(s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
         weight *= 0.75;

      weight = CouncilClamp(weight);

      double preV1Weight = weight;
      string v1Role = "";
      string v1Reason = "";
      double v1Mul = CouncilV1_FamilySoftWeightMultiplier(
         s.strategy_family,
         v1Early,
         v1FswEnabled,
         outReport.v1_fsw_phase2_active,
         v1Role,
         v1Reason
      );
      double postV1Weight = CouncilClamp(preV1Weight * v1Mul);
      double v1Delta = postV1Weight - preV1Weight;
      bool v1Mapped = (v1FswEnabled && MathAbs(v1Mul - 1.00) > 0.0001);
      bool v1NonzeroImpact = (v1Mapped && preV1Weight > 0.0 && MathAbs(v1Delta) > 0.00005);

      if(StringLen(outReport.v1_fsw_strategy_attributions) > 0)
         outReport.v1_fsw_strategy_attributions += ";";

      outReport.v1_fsw_strategy_attributions +=
         s.strategy_id + "|" +
         s.strategy_family + "|" +
         v1Role + "|" +
         DoubleToString(v1Mul, 2) + "|" +
         DoubleToString(preV1Weight, 4) + "|" +
         DoubleToString(postV1Weight, 4) + "|" +
         DoubleToString(v1Delta, 4);

      if(v1FswEnabled && StringLen(outReport.v1_fsw_bypass_reason) <= 0 && StringLen(v1Reason) > 0)
         outReport.v1_fsw_bypass_reason = v1Reason;

      if(v1FswEnabled && v1Role == "UNKNOWN" && StringLen(TrimString(s.strategy_family)) > 0)
         CouncilAppendCsvUnique(outReport.v1_fsw_unknown_family_warning, s.strategy_family);

      if(v1Mapped)
      {
         outReport.v1_fsw_mapped_strategy_count++;
         outReport.v1_fsw_influenced_strategy_count++;
         outReport.v1_fsw_total_weight_delta += v1Delta;

         if(v1Role == "NATIVE")
            outReport.v1_fsw_native_weight_delta += v1Delta;
         else if(v1Role == "CONDITIONAL")
            outReport.v1_fsw_conditional_weight_delta += v1Delta;
         else if(v1Role == "DEPRIORITIZED")
            outReport.v1_fsw_deprioritized_weight_delta += v1Delta;
      }

      if(v1NonzeroImpact)
      {
         outReport.v1_fsw_nonzero_impact_count++;

         if(v1Role == "NATIVE")
            outReport.v1_fsw_native_nonzero_count++;
         else if(v1Role == "CONDITIONAL")
            outReport.v1_fsw_conditional_nonzero_count++;
         else if(v1Role == "DEPRIORITIZED")
            outReport.v1_fsw_deprioritized_nonzero_count++;
      }

      weight = postV1Weight;

      //---------------------------------------------------
      // Package 1 -- authority-facing best_strategy_id is
      // selected by no-score live contribution, not score_final.
      //---------------------------------------------------
      if(weight > 0.0 && weight > bestContribution)
      {
         bestContribution = weight;
         bestStrategy = s.strategy_id;
      }

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

      // Signal-routing only: allow EXHAUSTION_JUDGE to propagate exhaustionWarning in
      // TREND_CONTINUATION when OBSERVE_ONLY, provided it has a genuine directional
      // (non-WAIT) signal. vote_weight remains 0.0 (zeroed by CouncilApplyEligibilityWeight
      // in strategy builder) — no BUY/SELL weight added, no approval path created.
      // Only activates the existing pre-AI filter exhaustion-tightening gate
      // (council_pre_ai_filter.mqh lines 111-117): quality +0.04, conflict -0.10.
      if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION &&
         s.role == COUNCIL_ROLE_EXHAUSTION_JUDGE &&
         s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY &&
         CouncilIsDirectionalDecision(s.decision))
      {
         exhaustionWarning = true;
      }

      //---------------------------------------------------
      // Track best score for diagnostic council_quality math only.
      //---------------------------------------------------
      if(s.score_final > bestScore)
         bestScore = s.score_final;
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

   if(v1FswEnabled)
   {
      if(outReport.v1_fsw_nonzero_impact_count > 0 ||
         MathAbs(outReport.v1_fsw_total_weight_delta) > 0.00005)
      {
         outReport.v1_fsw_applied = true;
         outReport.v1_fsw_was_active_at_decision = true;
         outReport.v1_fsw_action_taken = "SPECIALIST_WEIGHT_ADJUSTED";
         outReport.v1_fsw_bypass_reason = "";
      }
      else if(outReport.v1_fsw_mapped_strategy_count > 0)
      {
         outReport.v1_fsw_applied = false;
         outReport.v1_fsw_was_active_at_decision = false;
         outReport.v1_fsw_action_taken = "FAMILY_MAPPED_NO_EFFECTIVE_WEIGHT_IMPACT";
         if(StringLen(outReport.v1_fsw_bypass_reason) <= 0)
            outReport.v1_fsw_bypass_reason = "MAPPED_ZERO_EFFECTIVE_WEIGHT";
      }
      else
      {
         outReport.v1_fsw_action_taken = "OBSERVED_NO_ADJUSTMENT";
         if(StringLen(outReport.v1_fsw_bypass_reason) <= 0)
            outReport.v1_fsw_bypass_reason = "NO_MULTIPLIER_DEVIATION";
      }
   }

   //------------------------------------------------------
   // Dominant side
   //------------------------------------------------------
   if(buyWeight > sellWeight)
      outReport.dominant_side = "BUY";
   else if(sellWeight > buyWeight)
      outReport.dominant_side = "SELL";
   else
      outReport.dominant_side = "NONE";

   CouncilExecutionAdmissionIdentity admissionIdentity;
   IRREW_ResolveAdmissionIdentity(reports, reportCount, outReport, admissionIdentity);
   outReport.primary_thesis_strategy_id = admissionIdentity.primary_thesis_strategy_id;
   outReport.execution_admission_family = admissionIdentity.execution_admission_family;
   outReport.execution_admission_source = admissionIdentity.execution_admission_source;
   outReport.execution_admission_reason = admissionIdentity.execution_admission_reason;

   outReport.two_or_more_dominant_families =
      ((outReport.dominant_side == "BUY"  && buyFamilyCount  >= 2) ||
       (outReport.dominant_side == "SELL" && sellFamilyCount >= 2));

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

   // Continuous log-based diversity index (replaces near-binary {0.35, 0.70, 1.0} step function).
   // Normalised to 5 families = 1.0. Gradients: 1→0.39, 2→0.61, 3→0.77, 4→0.90, 5+→1.0.
   // Provides finer discrimination around the 0.45/0.60 consensus thresholds.
   if(dominantFamilyCount <= 0)
      outReport.family_diversity_score = 0.0;
   else
      outReport.family_diversity_score = CouncilClamp(
         MathLog(1.0 + (double)dominantFamilyCount) / MathLog(6.0));

   //------------------------------------------------------
   // Role-aware flags
   //------------------------------------------------------
   outReport.confirm_role_present   = confirmSupportsDominant;
   outReport.trend_judge_supportive = trendJudgeSupportsDominant;
   // CEIS Source Intelligence exhaustion_warning combination (7-signal evolved):
   // - Original strategy-vote paths preserved (mfi_reversal_assist ACTIVE/REDUCED + zone_align)
   // - env.exhaustion_hint preserved (M1 spike-reversal)
   // - ceis_overextension_m5 fires alone (primary LATE_CONTINUATION_FAILURE protection)
   // - M5+M15 MFI confluence fires (single M5 MFI alone does not — avoids single-horizon flicker)
   // - ceis_mfi_exhaustion_h1 fires alone: multi-hour structural overbought/oversold reversal
   //   is architecturally meaningful independent of M5 signals; H1 structural exhaustion is
   //   sufficient context to tighten enforcement regardless of tactical M5 state
   // H4 context and momentum fade contribute to ceis_source_score only — not tactical gates.
   outReport.exhaustion_warning = exhaustionWarning
                                   || env.exhaustion_hint
                                   || env.ceis_overextension_m5
                                   || (env.ceis_mfi_exhaustion_m5 && env.ceis_mfi_exhaustion_m15)
                                   || env.ceis_mfi_exhaustion_h1;

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

   // Voter-fidelity multiplier: penalises single-voice consensus (1 voter → 0.39, 2→0.61, 3→0.77).
   // Prevents a lone unopposed strategy from achieving consensus_strength=1.0 contributing full 0.32.
   int dominantVotes = (int)MathMax(outReport.buy_votes, outReport.sell_votes);
   double voterFidelity = (dominantVotes > 0)
      ? CouncilClamp(MathLog(1.0 + (double)dominantVotes) / MathLog(6.0))
      : 0.0;
   double adjustedConsensus = outReport.consensus_strength * voterFidelity;

   outReport.council_quality =
      (adjustedConsensus              * 0.32) +
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
      // CEIS stacked penalties in TREND_CONTINUATION:
      // +(-0.04) when M5 EMA overextension detected — total -0.12
      if(env.ceis_overextension_m5 && env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION)
         outReport.council_quality -= 0.04;
      // +(-0.03) when H1 structural MFI exhaustion detected — total up to -0.15
      // (only in TREND_CONTINUATION; multi-hour overbought/oversold structural context)
      if(env.ceis_mfi_exhaustion_h1 && env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION)
         outReport.council_quality -= 0.03;
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
