#ifndef __SHADOW_REPLAY_ENGINE_MQH__
#define __SHADOW_REPLAY_ENGINE_MQH__

#include "config_loader.mqh"
#include "strategy_compiler.mqh"
#include "decision_mode_router.mqh"
#include "regime_classification_layer_v1.mqh"
#include "unified_confidence.mqh"
#include "strategy_intelligence_layer_v1.mqh"
#include "execution_estimator_v1.mqh"
#include "performance_journal.mqh"
#include "shadow_policy_mirroring.mqh"

//---------------------------------------------------------
// Shadow replay outputs (no execution, no side effects)
//---------------------------------------------------------
struct ShadowReplayResult
{
   bool   valid;

   string shadow_decision_id;
   string shadow_mode;
   string shadow_plan_fingerprint;

   RuntimeDecision shadow_decision;
   string shadow_direction;

   double shadow_raw_signal_score;
   double shadow_confidence_score;
   double shadow_regime_fit_score;
   double shadow_execution_quality_score;
   double shadow_policy_risk_score;

   // Strategy Intelligence (shadow)
   double shadow_entry_quality_score;
   double shadow_entry_edge_score;
   double shadow_follow_through_quality_score;
   double shadow_strategy_regime_fit_score;
   double shadow_decision_quality_score;

   double shadow_expected_rr_estimate;
   double shadow_execution_geometry_score;
   string shadow_execution_geometry_label;
   string shadow_entry_quality_label;
   string shadow_entry_edge_label;
   string shadow_follow_through_quality_label;
   string shadow_strategy_regime_fit_label;
   string shadow_decision_quality_label;

   bool   shadow_final_permission;
   bool   shadow_policy_permission;
   string shadow_policy_reason;
   string shadow_policy_state;
   string shadow_reason_summary;
};

struct ShadowComparisonResult
{
   string production_decision;
   string shadow_decision;

   string production_direction;
   string shadow_direction;

   bool   decision_agreement;
   string relation_class;

   double confidence_delta;
   int    permission_delta;
   int    shadow_permission_delta_vs_production;

   double entry_quality_delta;
   double entry_edge_delta;
   double follow_through_quality_delta;
   double regime_fit_delta;
   double decision_quality_delta;

   double expected_rr_delta;
   double execution_geometry_delta;

   string comparison_summary;
   string comparison_basis;
};

void InitShadowReplayResult(ShadowReplayResult &r)
{
   r.valid = false;
   r.shadow_decision_id = "";
   r.shadow_mode = "";
   r.shadow_plan_fingerprint = "";
   r.shadow_decision = RUNTIME_WAIT;
   r.shadow_direction = "NONE";
   r.shadow_raw_signal_score = 0.0;
   r.shadow_confidence_score = 0.0;
   r.shadow_regime_fit_score = 0.0;
   r.shadow_execution_quality_score = 0.0;
   r.shadow_policy_risk_score = 0.0;

   r.shadow_entry_quality_score = 0.0;
   r.shadow_strategy_regime_fit_score = 0.0;
   r.shadow_decision_quality_score = 0.0;
   r.shadow_expected_rr_estimate = 0.0;
   r.shadow_execution_geometry_score = 0.0;
   r.shadow_execution_geometry_label = "";
   r.shadow_entry_quality_label = "";
   r.shadow_strategy_regime_fit_label = "";
   r.shadow_decision_quality_label = "";

   r.shadow_final_permission = false;
   r.shadow_policy_permission = false;
   r.shadow_policy_reason = "";
   r.shadow_policy_state = "";
   r.shadow_reason_summary = "";
}

void InitShadowComparisonResult(ShadowComparisonResult &c)
{
   c.production_decision = "";
   c.shadow_decision = "";
   c.production_direction = "";
   c.shadow_direction = "";
   c.decision_agreement = false;
   c.relation_class = "UNKNOWN_RELATION";
   c.confidence_delta = 0.0;
   c.permission_delta = 0;
   c.shadow_permission_delta_vs_production = 0;
   c.entry_quality_delta = 0.0;
   c.entry_edge_delta = 0.0;
   c.follow_through_quality_delta = 0.0;
   c.regime_fit_delta = 0.0;
   c.decision_quality_delta = 0.0;
   c.comparison_summary = "";
   c.comparison_basis = "SAFE_REPLAY_V1";
}

string SR_DecisionToText(RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY)  return "BUY";
   if(d == RUNTIME_ENTER_SELL) return "SELL";
   if(d == RUNTIME_REJECT)     return "REJECT";
   return "WAIT";
}

string SR_DirectionFromDecision(RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY)  return "BUY";
   if(d == RUNTIME_ENTER_SELL) return "SELL";
   return "NONE";
}

// Minimal shadow permission evaluator (no broker checks, no side effects)

void SR_BuildUnifiedDecisionConfidenceV1(
   RoutedRuntimeEvaluation &routed,
   RegimeClassification &reg,
   RuntimeEvaluation &eval,
   bool policyAllowed,
   string policyReason,
   UnifiedDecisionConfidence &out
)
{
   InitUnifiedDecisionConfidence(out);

   out.direction        = UnifiedDirectionText(eval.decision);
   out.raw_signal_score = UnifiedRawSignalScore(eval.decision);

   double baseConf = 0.50;

   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      double q  = routed.council.aggregate.council_quality;
      double cs = routed.council.aggregate.consensus_strength;
      baseConf = 0.50 * q + 0.50 * cs;
   }
   else
   {
      if(eval.decision == RUNTIME_ENTER_BUY || eval.decision == RUNTIME_ENTER_SELL)
         baseConf = 0.55;
      else if(eval.decision == RUNTIME_REJECT)
         baseConf = 0.52;
   }

   out.confidence_score = PJ_Clamp01(baseConf);

   double fit = (reg.tradability_score * 0.60) + (reg.regime_confidence * 0.40);
   out.regime_fit_score = PJ_Clamp01(fit);

   out.execution_quality_score = 0.50;
   out.policy_risk_score       = 0.50;

   out.final_permission = policyAllowed;

   if(!policyAllowed && StringLen(policyReason) > 0)
      out.final_decision_reason = policyReason;
   else
      out.final_decision_reason = eval.reason;
}

bool SR_ShadowPermissionV1(RuntimePlan &shadowPlan, RegimeClassification &regime, RuntimeDecision d, string &reason)
{
   reason = "";

   if(d != RUNTIME_ENTER_BUY && d != RUNTIME_ENTER_SELL)
      return true;

   if(shadowPlan.enable_regime_filter)
   {
      if(shadowPlan.regime_confidence_min > 0.0 && regime.regime_confidence < shadowPlan.regime_confidence_min)
      {
         reason = "shadow_regime_confidence_below_min";
         return false;
      }

      if(shadowPlan.regime_tradability_min > 0.0 && regime.tradability_score < shadowPlan.regime_tradability_min)
      {
         reason = "shadow_regime_tradability_below_min";
         return false;
      }

      if(!RegimeCsvAllows(shadowPlan.allowed_regimes, regime.regime_label))
      {
         reason = "shadow_regime_not_allowed";
         return false;
      }
   }

   // Conservative: keep permission true unless explicit plan-level guard exists
   return true;
}

string SR_ClassifyRelation(string prodDecision, string shadowDecision, bool prodPermission, bool shadowPermission, double prodConf, double shadowConf)
{
   bool prodTrade = (prodDecision == "BUY" || prodDecision == "SELL");
   bool shTrade   = (shadowDecision == "BUY" || shadowDecision == "SELL");

   if(prodDecision == shadowDecision)
   {
      if(prodPermission != shadowPermission)
      {
         if(prodTrade && prodPermission && !shadowPermission)
            return "SHADOW_BLOCKED_PRODUCTION_TRADE";

         if(shTrade && !prodPermission && shadowPermission)
            return "SHADOW_ALLOWED_REJECTED_PRODUCTION";

         return "UNKNOWN_RELATION";
      }

      double delta = MathAbs(shadowConf - prodConf);
      if(delta >= 0.15 && prodTrade)
         return "SHADOW_SAME_DECISION_DIFFERENT_CONFIDENCE";

      return "AGREE";
   }

   if(prodTrade && !shTrade)
      return "SHADOW_MORE_SELECTIVE";

   if(!prodTrade && shTrade)
      return "SHADOW_MORE_AGGRESSIVE";

   return "DISAGREE";
}

void SR_BuildComparison(
   UnifiedDecisionConfidence &prodConf,
   UnifiedDecisionConfidence &shadowConf,
   bool prodPermission,
   bool shadowPermission,
   ShadowComparisonResult &out
)
{
   InitShadowComparisonResult(out);

   out.production_decision  = prodConf.direction;
   out.shadow_decision      = shadowConf.direction;

   out.production_direction = prodConf.direction;
   out.shadow_direction     = shadowConf.direction;

   out.decision_agreement = (out.production_decision == out.shadow_decision);

   out.relation_class = SR_ClassifyRelation(
      out.production_decision,
      out.shadow_decision,
      prodPermission,
      shadowPermission,
      prodConf.confidence_score,
      shadowConf.confidence_score
   );

   out.confidence_delta = shadowConf.confidence_score - prodConf.confidence_score;
   out.permission_delta = (int)(shadowPermission ? 1 : 0) - (int)(prodPermission ? 1 : 0);
   out.shadow_permission_delta_vs_production = out.permission_delta;

   out.entry_quality_delta = shadowConf.entry_quality_score - prodConf.entry_quality_score;
   out.regime_fit_delta = shadowConf.strategy_regime_fit_score - prodConf.strategy_regime_fit_score;
   out.decision_quality_delta = shadowConf.decision_quality_score - prodConf.decision_quality_score;

   out.expected_rr_delta = shadowConf.expected_rr_estimate - prodConf.expected_rr_estimate;
   out.execution_geometry_delta = shadowConf.execution_geometry_score - prodConf.execution_geometry_score;

   out.comparison_summary =
      "rel=" + out.relation_class +
      "|p=" + out.production_decision +
      "|s=" + out.shadow_decision +
      "|dConf=" + DoubleToString(out.confidence_delta, 2) +
      "|dPerm=" + IntegerToString(out.permission_delta) +
      "|dEQ=" + DoubleToString(out.entry_quality_delta, 2) +
      "|dFit=" + DoubleToString(out.regime_fit_delta, 2) +
      "|dDQ=" + DoubleToString(out.decision_quality_delta, 2);
}

//---------------------------------------------------------
// Shadow replay runner (SAFE_REPLAY_V1)
// - Loads proposal plan file
// - Compiles & routes decision on same snapshot
// - No execution, no file outputs from COUNCIL (router passes empty paths)
//---------------------------------------------------------
bool RunShadowReplayV1(
   string proposalPlanPath,
   string symbol,
   ulong magic,
   int lastRuntimeEntryBars,
   bool hasRiskPolicy,
   RiskPolicySnapshot &riskPolicy,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RegimeClassification &regime,
   RoutedRuntimeEvaluation &productionRouted,
   RuntimeEvaluation &productionEval,
   UnifiedDecisionConfidence &productionConf,
   ShadowReplayResult &shadow,
   ShadowComparisonResult &cmp,
   string &logMessage
)
{
   logMessage = "";
   InitShadowReplayResult(shadow);
   InitShadowComparisonResult(cmp);

   RuntimePlan shadowPlan;
   LoadDefaultPlan(shadowPlan);

   if(!LoadRuntimePlanFromJson(proposalPlanPath, shadowPlan))
   {
      logMessage = "ShadowReplay skipped: proposal plan not available";
      return false;
   }

   CompiledPlan shadowCompiled;
   if(!CompileRuntimePlan(shadowPlan, shadowCompiled))
   {
      logMessage = "ShadowReplay skipped: failed to compile proposal plan";
      return false;
   }

   RoutedRuntimeEvaluation shadowRouted;
   InitRoutedRuntimeEvaluation(shadowRouted);

   EvaluateDecisionModeRoutedEx(shadowCompiled, m1, m5, true, shadowRouted);

   if(!shadowRouted.valid)
   {
      logMessage = "ShadowReplay failed: routed invalid";
      return false;
   }

   RuntimeEvaluation shadowEval;
   shadowEval.decision = shadowRouted.base_eval.decision;
   shadowEval.reason   = shadowRouted.base_eval.reason;


   // Strategy Intelligence (shadow) inputs for policy mirroring + comparison (no side effects)
   EntryQualityResult eq;
   StrategyRegimeFitResult fit;
   DecisionQualityResult dq;

   ComputeEntryQualityV1(m1, regime, shadowRouted.active_mode, shadowEval.decision, shadowRouted.council.env.zone_type, eq);
   ComputeStrategyRegimeFitV1(regime, shadowRouted.active_mode, shadowEval.decision, fit);

   EntryEdgeResult edge;
   FollowThroughQualityResult ft;
   ComputeEntryEdgeV1(m1, regime, shadowEval.decision, edge);
   ComputeFollowThroughQualityV1(m1, regime, shadowEval.decision, ft);

   // Pre-policy permission (conservative, includes optional regime filter thresholds)
   string prePolicyReason = "";
   bool prePolicyPerm = SR_ShadowPermissionV1(shadowPlan, regime, shadowEval.decision, prePolicyReason);

   // Policy mirroring (optional) - isolated, read-only
   ShadowPolicyResult pol;
   InitShadowPolicyResult(pol);

   
    // Execution estimation (shadow) - best-effort, used for shadow logs only
    ExecutionEstimationResult ee;
    ee.expected_stop_distance = 0.0;
    ee.expected_target_distance = 0.0;
    ee.expected_rr_estimate = 0.0;
    ee.adverse_excursion_risk_score = 0.0;
    ee.favorable_excursion_potential_score = 0.0;
    ee.execution_geometry_score = 0.0;
    ee.execution_geometry_label = "";
    ee.execution_geometry_reason = "";
    ee.valid = false;
    bool hasEe = false;
    if(shadowPlan.execution_estimation_enabled)
    {
       CoreDirection cd = CORE_NONE;
       if(shadowEval.decision == RUNTIME_ENTER_BUY) cd = CORE_BUY;
       else if(shadowEval.decision == RUNTIME_ENTER_SELL) cd = CORE_SELL;

       if(cd != CORE_NONE)
       {
          ComputeExecutionEstimationV1(m1, m5, regime, cd, ee);
          hasEe = ee.valid;
       }
    }

bool doPolicyMirror = shadowPlan.shadow_policy_mirroring_enabled;
   if(doPolicyMirror && (shadowEval.decision == RUNTIME_ENTER_BUY || shadowEval.decision == RUNTIME_ENTER_SELL))
   {
      CoreDirection dir = (shadowEval.decision == RUNTIME_ENTER_BUY ? CORE_BUY : CORE_SELL);
      ShadowPolicyAllowsTradeV2(
         shadowPlan,
         symbol,
         magic,
         lastRuntimeEntryBars,
         dir,
         true,
         regime,
         hasRiskPolicy,
         riskPolicy,
         eq.entry_quality_score,
         fit.strategy_regime_fit_score,
         edge.entry_edge_score,
         ft.follow_through_quality_score,
         eq.entry_quality_label,
         edge.entry_edge_label,
         pol
      );
   }
   else
   {
      pol.policy_permission = true;
      pol.final_permission  = true;
      pol.policy_reason     = (doPolicyMirror ? "no_trade_decision" : "policy_mirroring_disabled");
      pol.policy_state_text = hasRiskPolicy ? riskPolicy.state_text : "UNKNOWN";
   }

   bool finalPerm = prePolicyPerm && pol.policy_permission;

   UnifiedDecisionConfidence shadowConf;
   SR_BuildUnifiedDecisionConfidenceV1(
      shadowRouted,
      regime,
      shadowEval,
      finalPerm,
      (finalPerm ? "" : (StringLen(prePolicyReason) > 0 ? prePolicyReason : pol.policy_reason)),
      shadowConf
   );


// Strategy Intelligence (shadow replay) - fill unified confidence + shadow fields


ComputeDecisionQualityV2(
   shadowConf.confidence_score,
   shadowConf.regime_fit_score,
   eq,
   fit,
   edge,
   ft,
   shadowConf.policy_risk_score,
   dq
);

shadowConf.entry_quality_score    = eq.entry_quality_score;
shadowConf.timing_quality_score   = eq.timing_quality_score;
shadowConf.location_quality_score = eq.location_quality_score;
shadowConf.volatility_fit_score   = eq.volatility_fit_score;
shadowConf.entry_quality_label    = eq.entry_quality_label;
shadowConf.entry_quality_reason   = eq.entry_quality_reason;
shadowConf.entry_quality_flags    = eq.entry_quality_flags;

shadowConf.strategy_regime_fit_score = fit.strategy_regime_fit_score;
shadowConf.rr_location_score            = edge.rr_location_score;
shadowConf.entry_edge_score             = edge.entry_edge_score;
shadowConf.entry_edge_label             = edge.entry_edge_label;
shadowConf.entry_edge_reason            = edge.entry_edge_reason;
shadowConf.follow_through_quality_score = ft.follow_through_quality_score;
shadowConf.follow_through_quality_label = ft.follow_through_quality_label;
shadowConf.follow_through_reason        = ft.follow_through_reason;

shadowConf.decision_quality_version     = "DQ_V2";

shadowConf.strategy_regime_fit_label = fit.strategy_regime_fit_label;
shadowConf.strategy_regime_reason    = fit.strategy_regime_reason;

shadowConf.decision_quality_score  = dq.decision_quality_score;
shadowConf.decision_quality_label  = dq.decision_quality_label;
shadowConf.decision_quality_reason = dq.decision_quality_reason;

shadow.shadow_entry_quality_score       = eq.entry_quality_score;
shadow.shadow_strategy_regime_fit_score = fit.strategy_regime_fit_score;
shadow.shadow_decision_quality_score    = dq.decision_quality_score;

   if(hasEe)
   {
      shadow.shadow_expected_rr_estimate     = ee.expected_rr_estimate;
      shadow.shadow_execution_geometry_score = ee.execution_geometry_score;
      shadow.shadow_execution_geometry_label = ee.execution_geometry_label;
   }

   if(hasEe)
   {
      shadowConf.expected_stop_distance              = ee.expected_stop_distance;
      shadowConf.expected_target_distance            = ee.expected_target_distance;
      shadowConf.expected_rr_estimate                = ee.expected_rr_estimate;
      shadowConf.adverse_excursion_risk_score        = ee.adverse_excursion_risk_score;
      shadowConf.favorable_excursion_potential_score = ee.favorable_excursion_potential_score;
      shadowConf.execution_geometry_score            = ee.execution_geometry_score;
      shadowConf.execution_geometry_label            = ee.execution_geometry_label;
      shadowConf.execution_geometry_reason           = ee.execution_geometry_reason;
      shadowConf.decision_quality_version            = "DQ_V3";
   }
   else
   {
      shadowConf.decision_quality_version            = "DQ_V2";
   }
shadow.shadow_entry_quality_label       = eq.entry_quality_label;
shadow.shadow_strategy_regime_fit_label = fit.strategy_regime_fit_label;
shadow.shadow_decision_quality_label    = dq.decision_quality_label;

   shadow.valid = true;
   shadow.shadow_decision_id = "SHR-" + PJ_MakeDecisionId();
   shadow.shadow_mode = shadowRouted.active_mode;
   shadow.shadow_plan_fingerprint = PJ_PlanFingerprint(shadowPlan);

   shadow.shadow_decision = shadowEval.decision;
   shadow.shadow_direction = SR_DirectionFromDecision(shadowEval.decision);

   shadow.shadow_raw_signal_score = shadowConf.raw_signal_score;
   shadow.shadow_confidence_score = shadowConf.confidence_score;
   shadow.shadow_regime_fit_score = shadowConf.regime_fit_score;
   shadow.shadow_execution_quality_score = shadowConf.execution_quality_score;
   shadow.shadow_policy_risk_score = shadowConf.policy_risk_score;

   shadow.shadow_entry_quality_score = shadowConf.entry_quality_score;
   shadow.shadow_entry_edge_score = shadowConf.entry_edge_score;
   shadow.shadow_follow_through_quality_score = shadowConf.follow_through_quality_score;
   shadow.shadow_strategy_regime_fit_score = shadowConf.strategy_regime_fit_score;
   shadow.shadow_decision_quality_score = shadowConf.decision_quality_score;

   shadow.shadow_entry_quality_label = shadowConf.entry_quality_label;
   shadow.shadow_entry_edge_label = shadowConf.entry_edge_label;
   shadow.shadow_follow_through_quality_label = shadowConf.follow_through_quality_label;
   shadow.shadow_strategy_regime_fit_label = shadowConf.strategy_regime_fit_label;
   shadow.shadow_decision_quality_label = shadowConf.decision_quality_label;


   shadow.shadow_final_permission = finalPerm;

   shadow.shadow_reason_summary = shadowEval.reason;
   if(!prePolicyPerm && StringLen(prePolicyReason) > 0)
      shadow.shadow_reason_summary += " | " + prePolicyReason;
   if(prePolicyPerm && !pol.policy_permission && StringLen(pol.policy_reason) > 0)
      shadow.shadow_reason_summary += " | " + pol.policy_reason;

   SR_BuildComparison(
      productionConf,
      shadowConf,
      productionConf.final_permission,
      finalPerm,
      cmp
   );

   logMessage =
      "ShadowReplay | mode=" + shadow.shadow_mode +
      " | fp=" + shadow.shadow_plan_fingerprint +
      " | s=" + SR_DecisionToText(shadowEval.decision) +
      " | rel=" + cmp.relation_class;

   return true;
}

#endif