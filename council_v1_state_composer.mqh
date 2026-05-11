#ifndef __COUNCIL_V1_STATE_COMPOSER_MQH__
#define __COUNCIL_V1_STATE_COMPOSER_MQH__

#include "council_mode_types.mqh"

struct CouncilV1ShadowStatePolicyAnnotation
{
   string semantics_version;
   string state_label;
   string era_posture;
   string exra_posture;
   string divergence_class;
   string policy_posture;
   string policy_allowed_families;
   string policy_deprioritized_families;
   string policy_conditional_families;
   string policy_reason_code;
   string authority_class;
   string action_taken;
   bool   policy_is_shadow;
   string policy_specialist_version;
   string role_native_families;
   string role_conditional_families;
   string role_deprioritized_families;
   string role_informational_families;
   string live_family;
   string live_family_role;
   string policy_live_alignment;
   string counterfactual_action;
   string counterfactual_reason_code;
   string promotion_readiness;
   string scoring_quarantine_version;
   bool   dq_policy_enabled;
   string dq_score_role;
   string entry_quality_role;
   string execution_geometry_role;
   string learning_role;
   string advisory_role;
   string score_authority_warning;
};

struct CouncilV1EarlyInfluenceContext
{
   bool   valid;
   string state_label;
   string era_posture;
   string exra_posture;
   string policy_posture;
   string native_families;
   string conditional_families;
   string deprioritized_families;
   string informational_families;
   string bypass_reason;
};

void CouncilV1_InitShadowAnnotation(CouncilV1ShadowStatePolicyAnnotation &out)
{
   out.semantics_version = "V1_SHADOW_STATE_POLICY_V1";
   out.state_label = "V1_NOT_EVALUATED";
   out.era_posture = "UNKNOWN";
   out.exra_posture = "UNKNOWN";
   out.divergence_class = "UNKNOWN";
   out.policy_posture = "OBSERVE_ONLY";
   out.policy_allowed_families = "";
   out.policy_deprioritized_families = "";
   out.policy_conditional_families = "";
   out.policy_reason_code = "NOT_EVALUATED";
   out.authority_class = "DERIVED_VISIBILITY_ONLY";
   out.action_taken = "OBSERVED_ONLY";
   out.policy_is_shadow = true;
   out.policy_specialist_version = "V1_POLICY_SPECIALIST_MAP_V1";
   out.role_native_families = "";
   out.role_conditional_families = "";
   out.role_deprioritized_families = "";
   out.role_informational_families = "";
   out.live_family = "NOT_AVAILABLE";
   out.live_family_role = "NOT_AVAILABLE";
   out.policy_live_alignment = "LIVE_FAMILY_NOT_AVAILABLE";
   out.counterfactual_action = "UNKNOWN";
   out.counterfactual_reason_code = "NOT_EVALUATED";
   out.promotion_readiness = "NOT_READY";
   out.scoring_quarantine_version = "V1_SCORING_QUARANTINE_V3_ENFORCEMENT";
   out.dq_policy_enabled = false;
   out.dq_score_role = "UNKNOWN";
   out.entry_quality_role = "UNKNOWN";
   out.execution_geometry_role = "UNKNOWN";
   out.learning_role = "UNKNOWN";
   out.advisory_role = "UNKNOWN";
   out.score_authority_warning = "UNKNOWN_AUTHORITY_PATH";
}

void CouncilV1_InitEarlyInfluenceContext(CouncilV1EarlyInfluenceContext &out)
{
   out.valid = false;
   out.state_label = "V1_EARLY_NOT_EVALUATED";
   out.era_posture = "UNKNOWN";
   out.exra_posture = "UNKNOWN";
   out.policy_posture = "OBSERVE_ONLY";
   out.native_families = "";
   out.conditional_families = "";
   out.deprioritized_families = "";
   out.informational_families = "";
   out.bypass_reason = "NOT_EVALUATED";
}

string CouncilV1_EraPostureFromRegimeLabel(const string regime_label)
{
   if(regime_label == "TREND_UP" ||
      regime_label == "TREND_DOWN" ||
      regime_label == "TRENDING_UP" ||
      regime_label == "TRENDING_DOWN" ||
      regime_label == "EXPANSION")
      return "TREND";

   if(regime_label == "RANGE_BALANCED")
      return "RANGE";

   if(regime_label == "RANGE_DIRTY")
      return "DIRTY";

   if(regime_label == "COMPRESSION")
      return "COMPRESSION";

   if(regime_label == "REVERSAL_RISK")
      return "REVERSAL";

   if(regime_label == "TRANSITION")
      return "TRANSITION";

   return "ERA_UNDEFINED";
}

string CouncilV1_ExraPostureFromZone(const CouncilZoneType zone_type)
{
   if(zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
      zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION ||
      zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION)
      return "EXRA_TREND_OR_EXPANSION";

   if(zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM ||
      zone_type == COUNCIL_ZONE_RANGE_BALANCED ||
      zone_type == COUNCIL_ZONE_RANGE_DIRTY ||
      zone_type == COUNCIL_ZONE_COMPRESSION)
      return "EXRA_RANGE_OR_COMPRESSION";

   if(zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
      return "EXRA_REVERSAL_EXHAUSTION";

   if(zone_type == COUNCIL_ZONE_NO_TRADE)
      return "EXRA_NO_TRADE";

   return "EXRA_UNDEFINED";
}

string CouncilV1_ComposeStateLabel(const string era_posture,
                                   const string exra_posture,
                                   const CouncilZoneType zone_type)
{
   if(exra_posture == "EXRA_NO_TRADE")
      return "ANY_ERA_NO_TRADE_ZONE";

   if(era_posture == "TRANSITION")
      return "TRANSITION_ERA_ANY_EXRA";

   if(exra_posture == "EXRA_REVERSAL_EXHAUSTION")
      return "EXRA_REVERSAL_EXHAUSTION";

   if(era_posture == "TREND" && exra_posture == "EXRA_TREND_OR_EXPANSION")
      return "TREND_ERA_TREND_EXRA";

   if(era_posture == "TREND" && exra_posture == "EXRA_RANGE_OR_COMPRESSION")
      return "TREND_ERA_RANGE_EXRA";

   if(era_posture == "RANGE" && exra_posture == "EXRA_RANGE_OR_COMPRESSION")
      return "RANGE_ERA_RANGE_EXRA";

   if(era_posture == "RANGE" && exra_posture == "EXRA_TREND_OR_EXPANSION")
      return "RANGE_ERA_TREND_EXRA";

   if(era_posture == "COMPRESSION" &&
      (zone_type == COUNCIL_ZONE_COMPRESSION ||
       zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION ||
       zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION))
      return "COMPRESSION_ERA_BREAKOUT_OR_COMPRESSION_EXRA";

   if(era_posture == "COMPRESSION" && exra_posture == "EXRA_RANGE_OR_COMPRESSION")
      return "COMPRESSION_ERA_RANGE_EXRA";

   if(era_posture == "REVERSAL" && exra_posture == "EXRA_TREND_OR_EXPANSION")
      return "REVERSAL_ERA_ROUTE_NATIVE_EXRA";

   if(era_posture == "REVERSAL" && exra_posture == "EXRA_RANGE_OR_COMPRESSION")
      return "REVERSAL_ERA_RANGE_EXRA";

   if(era_posture == "DIRTY" && exra_posture == "EXRA_RANGE_OR_COMPRESSION")
      return "DIRTY_ERA_DEGRADED_EXRA";

   return "UNDEFINED_STATE";
}

string CouncilV1_DivergenceClass(const string era_posture,
                                 const string exra_posture,
                                 const string state_label)
{
   if(state_label == "V1_NOT_APPLICABLE_NON_COUNCIL")
      return "NON_COUNCIL_MODE";

   if(state_label == "TRANSITION_ERA_ANY_EXRA")
      return "TRANSITIONAL";

   if(state_label == "EXRA_REVERSAL_EXHAUSTION")
      return "EXRA_REVERSAL_EXHAUSTION";

   if(era_posture == "ERA_UNDEFINED" ||
      exra_posture == "EXRA_UNDEFINED" ||
      exra_posture == "EXRA_NO_TRADE")
      return "UNKNOWN";

   bool eraDegraded = (era_posture == "DIRTY" ||
                       era_posture == "COMPRESSION" ||
                       era_posture == "REVERSAL");
   bool eraClean = (era_posture == "TREND" || era_posture == "RANGE");
   bool exraRouteNative = (exra_posture == "EXRA_TREND_OR_EXPANSION");
   bool exraDegraded = (exra_posture == "EXRA_RANGE_OR_COMPRESSION");

   if((state_label == "TREND_ERA_TREND_EXRA") ||
      (state_label == "RANGE_ERA_RANGE_EXRA"))
      return "ALIGNED";

   if(eraDegraded && exraRouteNative)
      return "ERA_DEGRADED_EXRA_ROUTE_NATIVE";

   if(eraDegraded && exraDegraded)
      return "ERA_EXRA_BOTH_DEGRADED";

   if(eraClean && exraDegraded && era_posture != "RANGE")
      return "ERA_CLEAN_EXRA_DEGRADED";

   return "UNKNOWN";
}

void CouncilV1_ApplyPolicyForState(CouncilV1ShadowStatePolicyAnnotation &out)
{
   out.policy_posture = "OBSERVE_ONLY";
   out.policy_allowed_families = "";
   out.policy_deprioritized_families = "";
   out.policy_conditional_families = "";
   out.policy_reason_code = "V1_UNCLASSIFIED";

   if(out.state_label == "TREND_ERA_TREND_EXRA")
   {
      out.policy_posture = "FULL";
      out.policy_allowed_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,LIQUIDITY_REVERSAL";
      out.policy_conditional_families = "MEAN_RECLAIM";
      out.policy_reason_code = "ALIGNED_TREND";
   }
   else if(out.state_label == "TREND_ERA_RANGE_EXRA")
   {
      out.policy_posture = "REDUCED";
      out.policy_allowed_families = "MEAN_RECLAIM,LIQUIDITY_REVERSAL";
      out.policy_conditional_families = "TREND_CONTINUATION";
      out.policy_reason_code = "ERA_TREND_EXRA_RANGE";
   }
   else if(out.state_label == "RANGE_ERA_RANGE_EXRA")
   {
      out.policy_posture = "STAGED";
      out.policy_allowed_families = "MEAN_RECLAIM";
      out.policy_conditional_families = "LIQUIDITY_REVERSAL";
      out.policy_deprioritized_families = "TREND_CONTINUATION";
      out.policy_reason_code = "RANGE_ALIGNED";
   }
   else if(out.state_label == "RANGE_ERA_TREND_EXRA")
   {
      out.policy_posture = "STAGED";
      out.policy_allowed_families = "MEAN_RECLAIM";
      out.policy_conditional_families = "TREND_CONTINUATION,LIQUIDITY_REVERSAL";
      out.policy_deprioritized_families = "COMPRESSION_BREAKOUT";
      out.policy_reason_code = "RANGE_ERA_TREND_EXRA_MISMATCH";
   }
   else if(out.state_label == "COMPRESSION_ERA_BREAKOUT_OR_COMPRESSION_EXRA")
   {
      out.policy_posture = "STAGED";
      out.policy_allowed_families = "COMPRESSION_BREAKOUT,MEAN_RECLAIM";
      out.policy_conditional_families = "LIQUIDITY_REVERSAL";
      out.policy_deprioritized_families = "TREND_CONTINUATION";
      out.policy_reason_code = "COMPRESSION_COILING";
   }
   else if(out.state_label == "COMPRESSION_ERA_RANGE_EXRA")
   {
      out.policy_posture = "STAGED";
      out.policy_allowed_families = "MEAN_RECLAIM";
      out.policy_conditional_families = "COMPRESSION_BREAKOUT,LIQUIDITY_REVERSAL";
      out.policy_deprioritized_families = "TREND_CONTINUATION";
      out.policy_reason_code = "COMPRESSION_ERA_RANGE_EXRA";
   }
   else if(out.state_label == "REVERSAL_ERA_ROUTE_NATIVE_EXRA")
   {
      out.policy_posture = "OBSERVE_ONLY";
      out.policy_conditional_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,LIQUIDITY_REVERSAL,MEAN_RECLAIM";
      out.policy_reason_code = "ERA_REVERSAL_EXRA_ROUTE_NATIVE";
   }
   else if(out.state_label == "REVERSAL_ERA_RANGE_EXRA")
   {
      out.policy_posture = "STAGED";
      out.policy_allowed_families = "MEAN_RECLAIM";
      out.policy_conditional_families = "LIQUIDITY_REVERSAL";
      out.policy_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT";
      out.policy_reason_code = "REVERSAL_ERA_RANGE_EXRA";
   }
   else if(out.state_label == "DIRTY_ERA_DEGRADED_EXRA")
   {
      out.policy_posture = "REDUCED";
      out.policy_allowed_families = "MEAN_RECLAIM";
      out.policy_conditional_families = "LIQUIDITY_REVERSAL";
      out.policy_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT";
      out.policy_reason_code = "DIRTY_DEGRADED";
   }
   else if(out.state_label == "EXRA_REVERSAL_EXHAUSTION")
   {
      out.policy_posture = "WAIT";
      out.policy_allowed_families = "LIQUIDITY_REVERSAL";
      out.policy_conditional_families = "MEAN_RECLAIM";
      out.policy_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT";
      out.policy_reason_code = "EXRA_REVERSAL_EXHAUSTION";
   }
   else if(out.state_label == "TRANSITION_ERA_ANY_EXRA")
   {
      out.policy_posture = "OBSERVE_ONLY";
      out.policy_conditional_families = "LIQUIDITY_REVERSAL,MEAN_RECLAIM,TREND_CONTINUATION,COMPRESSION_BREAKOUT";
      out.policy_reason_code = "TRANSITIONAL_ERA";
   }
   else if(out.state_label == "ANY_ERA_NO_TRADE_ZONE")
   {
      out.policy_posture = "OBSERVE_ONLY";
      out.policy_reason_code = "EXRA_NO_TRADE_ZONE";
   }
   else if(out.state_label == "V1_NOT_APPLICABLE_NON_COUNCIL")
   {
      out.policy_posture = "OBSERVE_ONLY";
      out.policy_reason_code = "NON_COUNCIL_MODE";
   }
   else
   {
      out.policy_posture = "OBSERVE_ONLY";
      out.policy_reason_code = "V1_UNCLASSIFIED";
   }

   out.authority_class = "DERIVED_VISIBILITY_ONLY";
   out.action_taken = "OBSERVED_ONLY";
   out.policy_is_shadow = true;
}

bool CouncilV1_CsvHasFamily(const string csv, const string family)
{
   string fam = family;
   StringTrimLeft(fam);
   StringTrimRight(fam);
   if(StringLen(fam) <= 0)
      return false;

   string parts[];
   int n = StringSplit(csv, ',', parts);
   for(int i = 0; i < n; i++)
   {
      string token = parts[i];
      StringTrimLeft(token);
      StringTrimRight(token);
      if(token == fam)
         return true;
   }

   return false;
}

int CouncilV1_EligibilityRestrictionRank(const CouncilEligibilityState s)
{
   if(s == COUNCIL_ELIGIBILITY_BLOCKED)
      return 4;
   if(s == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      return 3;
   if(s == COUNCIL_ELIGIBILITY_REDUCED)
      return 2;
   if(s == COUNCIL_ELIGIBILITY_ACTIVE)
      return 1;

   // UNSET currently behaves as unrestricted in aggregation, so a policy cap may safely downgrade it.
   return 1;
}

CouncilEligibilityState CouncilV1_ApplyEligibilityCap(const CouncilEligibilityState currentState,
                                                      const CouncilEligibilityState capState)
{
   if(CouncilV1_EligibilityRestrictionRank(currentState) >= CouncilV1_EligibilityRestrictionRank(capState))
      return currentState;

   return capState;
}

string CouncilV1_ConstructiveFamilyRole(const string family,
                                        const CouncilV1EarlyInfluenceContext &ctx)
{
   string fam = family;
   StringTrimLeft(fam);
   StringTrimRight(fam);
   if(StringLen(fam) <= 0)
      return "UNKNOWN";

   if(fam == "IMBALANCE_FILL_REVERSAL")
      return "CONDITIONAL";

   if(CouncilV1_CsvHasFamily(ctx.native_families, fam))
      return "NATIVE";
   if(CouncilV1_CsvHasFamily(ctx.conditional_families, fam))
      return "CONDITIONAL";
   if(CouncilV1_CsvHasFamily(ctx.deprioritized_families, fam))
      return "DEPRIORITIZED";
   if(ctx.informational_families == "ALL" ||
      CouncilV1_CsvHasFamily(ctx.informational_families, fam))
      return "INFORMATIONAL";

   return "UNKNOWN";
}

bool CouncilV1_StrategyHasScorePotential(const CouncilStrategyReport &r)
{
   return (r.score_final > 0.00005 ||
           r.vote_weight > 0.00005 ||
           r.trigger_present ||
           r.decision == COUNCIL_DECISION_BUY ||
           r.decision == COUNCIL_DECISION_SELL);
}

void CouncilV1_ApplyPolicyEligibilityOverride(CouncilStrategyReport &reports[],
                                              const int count,
                                              const CouncilV1EarlyInfluenceContext &ctx,
                                              const bool enabled,
                                              CouncilV1ConstructiveEligibilitySummary &summary)
{
   InitCouncilV1ConstructiveEligibilitySummary(summary);

   if(!enabled || !ctx.valid)
      return;

   summary.version = "V1_CONSTRUCTIVE_ELIGIBILITY_V1";
   summary.active = true;
   summary.state_label = ctx.state_label;
   summary.policy_posture = ctx.policy_posture;
   summary.native_families = ctx.native_families;
   summary.conditional_families = ctx.conditional_families;
   summary.deprioritized_families = ctx.deprioritized_families;
   summary.informational_families = ctx.informational_families;
   summary.score_role = "LOCAL_RANKING_WITHIN_POLICY_ELIGIBLE_SUBSET";
   summary.score_could_not_admit_suppressed = true;
   summary.score_could_not_override_state =
      (ctx.state_label == "UNDEFINED_STATE" ||
       ctx.policy_posture == "OBSERVE_ONLY" ||
       ctx.policy_posture == "WAIT");
   summary.authority_class = "V1_CONSTRUCTIVE_ELIGIBILITY_ACTIVE";

   int limit = count;
   if(limit > ArraySize(reports))
      limit = ArraySize(reports);
   for(int i = 0; i < limit; i++)
   {
      if(!reports[i].valid || !reports[i].enabled)
         continue;

      string role = CouncilV1_ConstructiveFamilyRole(reports[i].strategy_family, ctx);
      CouncilEligibilityState preState = reports[i].eligibility_state;
      CouncilEligibilityState postState = preState;
      string overrideSource = "ZONE_ROLE_PRESERVED";

      if(ctx.state_label == "UNDEFINED_STATE")
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_OBSERVE_ONLY);
         overrideSource = "V1_POLICY_UNDEFINED_CAP";
      }
      else if(ctx.policy_posture == "WAIT")
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_BLOCKED);
         overrideSource = "V1_POLICY_WAIT_BLOCK";
      }
      else if(ctx.policy_posture == "OBSERVE_ONLY")
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_OBSERVE_ONLY);
         overrideSource = "V1_POLICY_OBSERVE_ONLY_CAP";
      }
      else if(role == "NATIVE")
      {
         overrideSource = "V1_POLICY_PRESERVE_NATIVE";
      }
      else if(role == "CONDITIONAL")
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_REDUCED);
         overrideSource = "V1_POLICY_DOWNGRADE_CONDITIONAL";
      }
      else if(role == "DEPRIORITIZED")
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_REDUCED);
         overrideSource = "V1_POLICY_DOWNGRADE_DEPRIORITIZED";
      }
      else if(role == "INFORMATIONAL")
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_OBSERVE_ONLY);
         overrideSource = "V1_POLICY_INFORMATIONAL_ONLY";
      }
      else
      {
         postState = CouncilV1_ApplyEligibilityCap(preState, COUNCIL_ELIGIBILITY_OBSERVE_ONLY);
         overrideSource = "V1_POLICY_UNKNOWN_SUPPRESSED";
      }

      if(role == "INFORMATIONAL")
         summary.informational_strategy_count++;
      else if(role == "UNKNOWN")
         summary.unknown_strategy_count++;

      bool downgraded = (CouncilV1_EligibilityRestrictionRank(postState) >
                         CouncilV1_EligibilityRestrictionRank(preState));
      if(downgraded)
      {
         reports[i].eligibility_state = postState;
         reports[i].eligibility_text = CouncilEligibilityStateToText(postState);

         if(postState == COUNCIL_ELIGIBILITY_OBSERVE_ONLY ||
            postState == COUNCIL_ELIGIBILITY_BLOCKED)
            summary.suppressed_strategy_count++;

         if(CouncilV1_StrategyHasScorePotential(reports[i]))
            summary.score_sovereignty_blocked = true;
      }

      if(postState == COUNCIL_ELIGIBILITY_ACTIVE ||
         postState == COUNCIL_ELIGIBILITY_REDUCED)
         summary.eligible_strategy_count++;

      if(StringLen(summary.strategy_attributions) > 0)
         summary.strategy_attributions += ";";

      summary.strategy_attributions +=
         reports[i].strategy_id + "|" +
         reports[i].strategy_family + "|" +
         role + "|" +
         CouncilEligibilityStateToText(preState) + "|" +
         CouncilEligibilityStateToText(postState) + "|" +
         overrideSource;
   }
}

void CouncilV1_ApplySpecialistRoleMapForState(CouncilV1ShadowStatePolicyAnnotation &out)
{
   out.policy_specialist_version = "V1_POLICY_SPECIALIST_MAP_V1";
   out.role_native_families = "";
   out.role_conditional_families = "";
   out.role_deprioritized_families = "";
   out.role_informational_families = "";

   if(out.state_label == "TREND_ERA_TREND_EXRA")
   {
      out.role_native_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,TREND_PULLBACK_CONTINUATION,VOL_BREAKOUT,EXPANSION_CONTINUATION";
      out.role_conditional_families = "LIQUIDITY_REVERSAL,MOMENTUM_REVERSAL_ASSIST";
      out.role_deprioritized_families = "MEAN_RECLAIM,MICRO_RANGE_BREAK";
   }
   else if(out.state_label == "TREND_ERA_RANGE_EXRA")
   {
      out.role_native_families = "MEAN_RECLAIM,LIQUIDITY_REVERSAL,TREND_PULLBACK_CONTINUATION";
      out.role_conditional_families = "TREND_CONTINUATION,MOMENTUM_REVERSAL_ASSIST,VOL_BREAKOUT,EXPANSION_CONTINUATION,MICRO_RANGE_BREAK";
      out.role_deprioritized_families = "COMPRESSION_BREAKOUT";
   }
   else if(out.state_label == "RANGE_ERA_RANGE_EXRA")
   {
      out.role_native_families = "MEAN_RECLAIM,MICRO_RANGE_BREAK";
      out.role_conditional_families = "LIQUIDITY_REVERSAL,MOMENTUM_REVERSAL_ASSIST";
      out.role_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,TREND_PULLBACK_CONTINUATION,VOL_BREAKOUT,EXPANSION_CONTINUATION";
   }
   else if(out.state_label == "RANGE_ERA_TREND_EXRA")
   {
      out.role_native_families = "MEAN_RECLAIM,TREND_PULLBACK_CONTINUATION";
      out.role_conditional_families = "TREND_CONTINUATION,LIQUIDITY_REVERSAL,MOMENTUM_REVERSAL_ASSIST,MICRO_RANGE_BREAK";
      out.role_deprioritized_families = "COMPRESSION_BREAKOUT,VOL_BREAKOUT,EXPANSION_CONTINUATION";
   }
   else if(out.state_label == "COMPRESSION_ERA_BREAKOUT_OR_COMPRESSION_EXRA")
   {
      out.role_native_families = "COMPRESSION_BREAKOUT,VOL_BREAKOUT,MICRO_RANGE_BREAK";
      out.role_conditional_families = "MEAN_RECLAIM,LIQUIDITY_REVERSAL,EXPANSION_CONTINUATION";
      out.role_deprioritized_families = "TREND_CONTINUATION,TREND_PULLBACK_CONTINUATION";
      out.role_informational_families = "MOMENTUM_REVERSAL_ASSIST";
   }
   else if(out.state_label == "COMPRESSION_ERA_RANGE_EXRA")
   {
      out.role_native_families = "MEAN_RECLAIM,MICRO_RANGE_BREAK";
      out.role_conditional_families = "COMPRESSION_BREAKOUT,LIQUIDITY_REVERSAL,VOL_BREAKOUT";
      out.role_deprioritized_families = "TREND_CONTINUATION,TREND_PULLBACK_CONTINUATION,EXPANSION_CONTINUATION";
      out.role_informational_families = "MOMENTUM_REVERSAL_ASSIST";
   }
   else if(out.state_label == "REVERSAL_ERA_ROUTE_NATIVE_EXRA")
   {
      out.role_native_families = "MOMENTUM_REVERSAL_ASSIST";
      out.role_conditional_families = "LIQUIDITY_REVERSAL,TREND_CONTINUATION,MICRO_RANGE_BREAK";
      out.role_deprioritized_families = "COMPRESSION_BREAKOUT,MEAN_RECLAIM,TREND_PULLBACK_CONTINUATION,VOL_BREAKOUT,EXPANSION_CONTINUATION";
   }
   else if(out.state_label == "REVERSAL_ERA_RANGE_EXRA")
   {
      out.role_native_families = "MEAN_RECLAIM,MOMENTUM_REVERSAL_ASSIST";
      out.role_conditional_families = "LIQUIDITY_REVERSAL,MICRO_RANGE_BREAK";
      out.role_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,TREND_PULLBACK_CONTINUATION,VOL_BREAKOUT,EXPANSION_CONTINUATION";
   }
   else if(out.state_label == "DIRTY_ERA_DEGRADED_EXRA")
   {
      out.role_native_families = "MEAN_RECLAIM";
      out.role_conditional_families = "LIQUIDITY_REVERSAL";
      out.role_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,MOMENTUM_REVERSAL_ASSIST,TREND_PULLBACK_CONTINUATION,VOL_BREAKOUT,EXPANSION_CONTINUATION,MICRO_RANGE_BREAK";
   }
   else if(out.state_label == "EXRA_REVERSAL_EXHAUSTION")
   {
      out.role_native_families = "LIQUIDITY_REVERSAL,MOMENTUM_REVERSAL_ASSIST";
      out.role_conditional_families = "MEAN_RECLAIM,VOL_BREAKOUT,MICRO_RANGE_BREAK";
      out.role_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT,TREND_PULLBACK_CONTINUATION,EXPANSION_CONTINUATION";
   }
   else if(out.state_label == "TRANSITION_ERA_ANY_EXRA")
   {
      out.role_conditional_families = "LIQUIDITY_REVERSAL,MEAN_RECLAIM,MOMENTUM_REVERSAL_ASSIST,TREND_PULLBACK_CONTINUATION,VOL_BREAKOUT,EXPANSION_CONTINUATION,MICRO_RANGE_BREAK";
      out.role_deprioritized_families = "TREND_CONTINUATION,COMPRESSION_BREAKOUT";
   }
   else if(out.state_label == "ANY_ERA_NO_TRADE_ZONE")
   {
      out.role_informational_families = "ALL";
   }
   else if(out.state_label == "UNDEFINED_STATE")
   {
      out.role_informational_families = "ALL";
   }
}

void CouncilV1_ApplyLiveFamilyRelation(CouncilV1ShadowStatePolicyAnnotation &out,
                                       const string activeMode,
                                       const bool councilValid,
                                       const string liveFamily)
{
   if(activeMode != "COUNCIL" || !councilValid)
   {
      out.live_family = "NON_COUNCIL_MODE";
      out.live_family_role = "NON_COUNCIL_MODE";
      out.policy_live_alignment = "NON_COUNCIL_MODE";
      return;
   }

   string fam = liveFamily;
   StringTrimLeft(fam);
   StringTrimRight(fam);
   if(StringLen(fam) <= 0 || fam == "NOT_AVAILABLE")
   {
      out.live_family = "NOT_AVAILABLE";
      out.live_family_role = "NOT_AVAILABLE";
      out.policy_live_alignment = "LIVE_FAMILY_NOT_AVAILABLE";
      return;
   }

   out.live_family = fam;
   out.live_family_role = "UNKNOWN";
   out.policy_live_alignment = "UNKNOWN";

   if(CouncilV1_CsvHasFamily(out.role_native_families, fam))
   {
      out.live_family_role = "NATIVE";
      out.policy_live_alignment = "LIVE_ALIGNED_WITH_V1";
   }
   else if(CouncilV1_CsvHasFamily(out.role_conditional_families, fam))
   {
      out.live_family_role = "CONDITIONAL";
      out.policy_live_alignment = "LIVE_CONDITIONAL_UNDER_V1";
   }
   else if(CouncilV1_CsvHasFamily(out.role_deprioritized_families, fam))
   {
      out.live_family_role = "DEPRIORITIZED";
      out.policy_live_alignment = "LIVE_DEPRIORITIZED_BY_V1";
   }
   else if(out.role_informational_families == "ALL" ||
           CouncilV1_CsvHasFamily(out.role_informational_families, fam))
   {
      out.live_family_role = "INFORMATIONAL";
      out.policy_live_alignment = "LIVE_INFORMATIONAL_ONLY_UNDER_V1";
   }
}

void CouncilV1_ApplyCounterfactualAction(CouncilV1ShadowStatePolicyAnnotation &out)
{
   out.counterfactual_action = "UNKNOWN";
   out.counterfactual_reason_code = "COUNTERFACTUAL_UNKNOWN";

   if(out.live_family_role == "NON_COUNCIL_MODE")
   {
      out.counterfactual_action = "NOT_APPLICABLE";
      out.counterfactual_reason_code = "NON_COUNCIL_MODE";
      return;
   }

   if(out.live_family_role == "NOT_AVAILABLE" || out.live_family == "NOT_AVAILABLE")
   {
      out.counterfactual_action = "UNKNOWN";
      out.counterfactual_reason_code = "LIVE_FAMILY_NOT_AVAILABLE";
      return;
   }

   if(out.policy_posture == "WAIT")
   {
      out.counterfactual_action = "WOULD_WAIT";
      out.counterfactual_reason_code = "POLICY_WAIT";
      return;
   }

   if(out.policy_posture == "OBSERVE_ONLY")
   {
      out.counterfactual_action = "WOULD_OBSERVE_ONLY";
      out.counterfactual_reason_code = "POLICY_OBSERVE_ONLY";
      return;
   }

   if(out.live_family_role == "INFORMATIONAL")
   {
      out.counterfactual_action = "WOULD_OBSERVE_ONLY";
      out.counterfactual_reason_code = "LIVE_INFORMATIONAL_ONLY_UNDER_V1";
      return;
   }

   if(out.live_family_role == "DEPRIORITIZED")
   {
      out.counterfactual_action = "WOULD_REDUCE_CURRENT";
      out.counterfactual_reason_code = "LIVE_DEPRIORITIZED_BY_V1";
      return;
   }

   bool nativeOrConditional = (out.live_family_role == "NATIVE" ||
                               out.live_family_role == "CONDITIONAL");

   if(out.policy_posture == "FULL" && nativeOrConditional)
   {
      out.counterfactual_action = "WOULD_ALLOW_CURRENT";
      out.counterfactual_reason_code = "FULL_POLICY_NATIVE_OR_CONDITIONAL";
      return;
   }

   if(out.policy_posture == "STAGED" && nativeOrConditional)
   {
      out.counterfactual_action = "WOULD_STAGE_CURRENT";
      out.counterfactual_reason_code = "STAGED_POLICY_NATIVE_OR_CONDITIONAL";
      return;
   }

   if(out.policy_posture == "REDUCED" && nativeOrConditional)
   {
      out.counterfactual_action = "WOULD_REDUCE_CURRENT";
      out.counterfactual_reason_code = "REDUCED_POLICY_NATIVE_OR_CONDITIONAL";
      return;
   }
}

void CouncilV1_ApplyPromotionReadiness(CouncilV1ShadowStatePolicyAnnotation &out)
{
   out.promotion_readiness = "NOT_READY";

   if(out.live_family_role == "NON_COUNCIL_MODE")
   {
      out.promotion_readiness = "NON_COUNCIL_MODE";
      return;
   }

   if(out.state_label == "UNDEFINED_STATE" ||
      out.live_family_role == "UNKNOWN" ||
      out.policy_live_alignment == "UNKNOWN")
   {
      out.promotion_readiness = "BLOCKED_BY_UNCLASSIFIED_STATE";
      return;
   }

   if(out.live_family_role == "DEPRIORITIZED" ||
      out.live_family_role == "INFORMATIONAL" ||
      out.policy_posture == "WAIT" ||
      out.policy_posture == "OBSERVE_ONLY")
   {
      out.promotion_readiness = "NOT_READY";
      return;
   }

   if(out.policy_posture == "FULL" && out.live_family_role == "NATIVE")
   {
      out.promotion_readiness = "ELIGIBLE_FOR_SOFT_INFLUENCE_REVIEW";
      return;
   }

   if((out.policy_posture == "FULL" ||
       out.policy_posture == "STAGED" ||
       out.policy_posture == "REDUCED") &&
      (out.live_family_role == "NATIVE" || out.live_family_role == "CONDITIONAL"))
   {
      out.promotion_readiness = "OBSERVE_MORE";
      return;
   }
}

bool CouncilV1_RoleUnknown(const string role)
{
   return (role == "UNKNOWN");
}

void CouncilV1_ApplyScoringQuarantine(CouncilV1ShadowStatePolicyAnnotation &out,
                                      const bool dqPolicyEnabled,
                                      const bool strategyIntelligenceEnabled,
                                      const bool entryQualityScoringEnabled,
                                      const bool executionEstimationEnabled,
                                      const bool institutionalLearningEnabled,
                                      const bool aiCandidateBlockEnabled,
                                      const bool dirtyGateEnabled,
                                      const bool atasAdvisoryEnabled,
                                      const int atasRolloutMode)
{
   out.scoring_quarantine_version = "V1_SCORING_QUARANTINE_V3_ENFORCEMENT";
   out.dq_policy_enabled = dqPolicyEnabled;

   out.dq_score_role = (dqPolicyEnabled ? "LIVE_GATE_ENABLED" :
                        (strategyIntelligenceEnabled ? "MEASUREMENT_ONLY" : "DISABLED"));

   out.entry_quality_role = (dqPolicyEnabled ? "LIVE_GATE_ENABLED" :
                             ((strategyIntelligenceEnabled && entryQualityScoringEnabled)
                              ? "MEASUREMENT_ONLY" : "DISABLED"));

   out.execution_geometry_role = (dqPolicyEnabled ? "LIVE_GATE_ENABLED" :
                                  (executionEstimationEnabled ? "MEASUREMENT_ONLY" : "DISABLED"));

   out.learning_role = (institutionalLearningEnabled ? "FIELD_ADJUSTMENT_ONLY" : "DISABLED");

   if(aiCandidateBlockEnabled)
      out.advisory_role = "BLOCK_AUTHORITY";
   else if(!atasAdvisoryEnabled)
      out.advisory_role = "DISABLED";
   else if(atasRolloutMode == 2)
      out.advisory_role = "BLOCK_AUTHORITY";
   else if(atasRolloutMode == 1)
      out.advisory_role = "SOFT_INFLUENCE";
   else if(atasRolloutMode == 0)
      out.advisory_role = "OBSERVE_ONLY";
   else
      out.advisory_role = "UNKNOWN";

   if(dirtyGateEnabled)
      out.score_authority_warning = "DIRTY_GATE_ENABLED";
   else if(out.advisory_role == "BLOCK_AUTHORITY")
      out.score_authority_warning = "ADVISORY_BLOCK_ENABLED";
   else if(dqPolicyEnabled)
      out.score_authority_warning = "DQ_POLICY_ENABLED";
   else if(CouncilV1_RoleUnknown(out.dq_score_role) ||
           CouncilV1_RoleUnknown(out.entry_quality_role) ||
           CouncilV1_RoleUnknown(out.execution_geometry_role) ||
           CouncilV1_RoleUnknown(out.learning_role) ||
           CouncilV1_RoleUnknown(out.advisory_role))
      out.score_authority_warning = "UNKNOWN_AUTHORITY_PATH";
   else
      out.score_authority_warning = "NONE";
}

void CouncilV1_EnrichShadowStatePolicyAnnotation(CouncilV1ShadowStatePolicyAnnotation &out,
                                                 const string activeMode,
                                                 const bool councilValid,
                                                 const string liveFamily,
                                                 const bool dqPolicyEnabled,
                                                 const bool strategyIntelligenceEnabled,
                                                 const bool entryQualityScoringEnabled,
                                                 const bool executionEstimationEnabled,
                                                 const bool institutionalLearningEnabled,
                                                 const bool aiCandidateBlockEnabled,
                                                 const bool dirtyGateEnabled,
                                                 const bool atasAdvisoryEnabled,
                                                 const int atasRolloutMode)
{
   CouncilV1_ApplySpecialistRoleMapForState(out);
   CouncilV1_ApplyLiveFamilyRelation(out, activeMode, councilValid, liveFamily);
   CouncilV1_ApplyCounterfactualAction(out);
   CouncilV1_ApplyPromotionReadiness(out);
   CouncilV1_ApplyScoringQuarantine(
      out,
      dqPolicyEnabled,
      strategyIntelligenceEnabled,
      entryQualityScoringEnabled,
      executionEstimationEnabled,
      institutionalLearningEnabled,
      aiCandidateBlockEnabled,
      dirtyGateEnabled,
      atasAdvisoryEnabled,
      atasRolloutMode
   );

   out.authority_class = "DERIVED_VISIBILITY_ONLY";
   out.action_taken = "OBSERVED_ONLY";
   out.policy_is_shadow = true;
}

void CouncilV1_BuildShadowStatePolicyAnnotation(const string activeMode,
                                                const bool councilValid,
                                                const string regime_label,
                                                const CouncilZoneType zone_type,
                                                CouncilV1ShadowStatePolicyAnnotation &out)
{
   CouncilV1_InitShadowAnnotation(out);

   if(activeMode != "COUNCIL" || !councilValid)
   {
      out.state_label = "V1_NOT_APPLICABLE_NON_COUNCIL";
      out.era_posture = "NOT_APPLICABLE";
      out.exra_posture = "NOT_APPLICABLE";
      out.divergence_class = "NON_COUNCIL_MODE";
      CouncilV1_ApplyPolicyForState(out);
      return;
   }

   out.era_posture = CouncilV1_EraPostureFromRegimeLabel(regime_label);
   out.exra_posture = CouncilV1_ExraPostureFromZone(zone_type);
   out.state_label = CouncilV1_ComposeStateLabel(out.era_posture, out.exra_posture, zone_type);
   out.divergence_class = CouncilV1_DivergenceClass(out.era_posture, out.exra_posture, out.state_label);
   CouncilV1_ApplyPolicyForState(out);
}

void CouncilV1_ComposeShadowStateEarly(const string activeMode,
                                       const bool councilValid,
                                       const string regime_label,
                                       const CouncilZoneType zone_type,
                                       CouncilV1EarlyInfluenceContext &out)
{
   CouncilV1_InitEarlyInfluenceContext(out);

   if(activeMode != "COUNCIL" || !councilValid)
   {
      out.valid = false;
      out.state_label = "V1_NOT_APPLICABLE_NON_COUNCIL";
      out.era_posture = "NOT_APPLICABLE";
      out.exra_posture = "NOT_APPLICABLE";
      out.policy_posture = "OBSERVE_ONLY";
      out.bypass_reason = "NON_COUNCIL_MODE";
      return;
   }

   CouncilV1ShadowStatePolicyAnnotation annotation;
   CouncilV1_BuildShadowStatePolicyAnnotation(activeMode, councilValid, regime_label, zone_type, annotation);
   CouncilV1_ApplySpecialistRoleMapForState(annotation);

   out.valid = true;
   out.state_label = annotation.state_label;
   out.era_posture = annotation.era_posture;
   out.exra_posture = annotation.exra_posture;
   out.policy_posture = annotation.policy_posture;
   out.native_families = annotation.role_native_families;
   out.conditional_families = annotation.role_conditional_families;
   out.deprioritized_families = annotation.role_deprioritized_families;
   out.informational_families = annotation.role_informational_families;
   out.bypass_reason = "";

   if(out.state_label == "UNDEFINED_STATE")
      out.bypass_reason = "UNDEFINED_STATE";
   else if(out.policy_posture == "OBSERVE_ONLY")
      out.bypass_reason = "OBSERVE_ONLY_POSTURE";
   else if(out.policy_posture == "WAIT")
      out.bypass_reason = "WAIT_POSTURE";
}

double CouncilV1_FswClampMultiplier(const double v)
{
   if(v < 0.85) return 0.85;
   if(v > 1.05) return 1.05;
   return v;
}

double CouncilV1_FamilySoftWeightMultiplier(const string strategy_family,
                                            const CouncilV1EarlyInfluenceContext &ctx,
                                            const bool enabled,
                                            const bool phase2Enabled,
                                            string &out_role,
                                            string &out_reason)
{
   out_role = "BYPASS";
   out_reason = "";

   if(!enabled)
   {
      out_reason = "FLAG_DISABLED";
      return 1.00;
   }

   if(!ctx.valid)
   {
      out_reason = (StringLen(ctx.bypass_reason) > 0 ? ctx.bypass_reason : "INVALID_CONTEXT");
      return 1.00;
   }

   if(ctx.state_label == "UNDEFINED_STATE")
   {
      out_reason = "UNDEFINED_STATE";
      return 1.00;
   }

   if(ctx.policy_posture == "OBSERVE_ONLY")
   {
      out_reason = "OBSERVE_ONLY_POSTURE";
      return 1.00;
   }

   if(ctx.policy_posture == "WAIT")
   {
      out_reason = "WAIT_POSTURE";
      return 1.00;
   }

   string fam = strategy_family;
   StringTrimLeft(fam);
   StringTrimRight(fam);
   if(StringLen(fam) <= 0)
   {
      out_reason = "EMPTY_FAMILY";
      return 1.00;
   }

   if(fam == "IMBALANCE_FILL_REVERSAL")
   {
      out_role = "CONDITIONAL";
      out_reason = "IFR_CONDITIONAL_REDUCED_NO_AUTHORITY_TRANSFER";
      return CouncilV1_FswClampMultiplier(0.90);
   }

   if(CouncilV1_CsvHasFamily(ctx.native_families, fam))
   {
      out_role = "NATIVE";
      if(phase2Enabled)
      {
         if(ctx.state_label == "COMPRESSION_ERA_RANGE_EXRA" && fam == "MEAN_RECLAIM")
         {
            out_reason = "PHASE2_COMPRESSION_RANGE_NATIVE_MEAN_RECLAIM";
            return CouncilV1_FswClampMultiplier(1.02);
         }

         if(ctx.state_label == "COMPRESSION_ERA_BREAKOUT_OR_COMPRESSION_EXRA" &&
            fam == "COMPRESSION_BREAKOUT")
         {
            out_reason = "PHASE2_COMPRESSION_BREAKOUT_NATIVE";
            return CouncilV1_FswClampMultiplier(1.03);
         }

         if(ctx.policy_posture == "FULL")
         {
            out_reason = "PHASE2_NATIVE_FULL_POSTURE";
            return CouncilV1_FswClampMultiplier(1.05);
         }

         if(ctx.policy_posture == "STAGED")
         {
            out_reason = "PHASE2_NATIVE_STAGED_POSTURE";
            return CouncilV1_FswClampMultiplier(1.03);
         }

         if(ctx.policy_posture == "REDUCED")
         {
            out_reason = "PHASE2_NATIVE_REDUCED_POSTURE";
            return 1.00;
         }
      }

      if(ctx.policy_posture == "FULL")
      {
         out_reason = "NATIVE_FULL_POSTURE";
         return CouncilV1_FswClampMultiplier(1.03);
      }

      out_reason = "NATIVE_NON_FULL_POSTURE";
      return 1.00;
   }

   if(CouncilV1_CsvHasFamily(ctx.conditional_families, fam))
   {
      out_role = "CONDITIONAL";
      if(phase2Enabled && ctx.state_label == "TREND_ERA_TREND_EXRA" && fam == "MEAN_RECLAIM")
      {
         out_reason = "PHASE2_TREND_ALIGNED_CONDITIONAL_MEAN_RECLAIM";
         return CouncilV1_FswClampMultiplier(0.85);
      }

      if(phase2Enabled && ctx.state_label == "COMPRESSION_ERA_RANGE_EXRA" &&
         fam == "COMPRESSION_BREAKOUT")
      {
         out_reason = "PHASE2_COMPRESSION_RANGE_CONDITIONAL_BREAKOUT";
         return CouncilV1_FswClampMultiplier(0.88);
      }

      out_reason = "CONDITIONAL_SOFT_REDUCTION";
      return CouncilV1_FswClampMultiplier(0.90);
   }

   if(CouncilV1_CsvHasFamily(ctx.deprioritized_families, fam))
   {
      out_role = "DEPRIORITIZED";
      out_reason = "DEPRIORITIZED_SOFT_REDUCTION";
      return CouncilV1_FswClampMultiplier(0.85);
   }

   if(ctx.informational_families == "ALL" ||
      CouncilV1_CsvHasFamily(ctx.informational_families, fam))
   {
      out_role = "INFORMATIONAL";
      out_reason = "INFORMATIONAL_PHASE1_NO_ADJUSTMENT";
      return 1.00;
   }

   out_role = "UNKNOWN";
   out_reason = "FAMILY_NOT_IN_V1_MAP";
   return 1.00;
}

#endif
