#ifndef __AUTHORITY_STACK_PILOT_MQH__
#define __AUTHORITY_STACK_PILOT_MQH__

struct AuthorityResult
{
   bool    enabled;
   bool    evaluated;
   bool    blocked;

   string  version;
   string  order;
   string  enabled_layers;

   string  baseline_decision;
   string  adjusted_decision;
   bool    changed_outcome;

   string  status;
   string  primary_layer;
   string  blocking_authority;
   string  blocking_reason;

   string  triggered_layers;
   string  reason_codes;
   string  trace;

   double  dq_proxy_score;
   double  dq_threshold;
   bool    dq_would_block;

   string  v1_posture_observed;
   string  v1_state_observed;
   bool    v1_would_block;

   string  p4_divergence_observed;
   bool    p4_would_block;
};

void InitAuthorityStackPilotResult(AuthorityResult &r)
{
   r.enabled                = false;
   r.evaluated              = false;
   r.blocked                = false;

   r.version                = "AUTHORITY_STACK_PILOT_V1";
   r.order                  = "P4,DQ,V1";
   r.enabled_layers         = "NONE";

   r.baseline_decision      = "";
   r.adjusted_decision      = "";
   r.changed_outcome        = false;

   r.status                 = "NOT_EVALUATED";
   r.primary_layer          = "NONE";
   r.blocking_authority     = "NONE";
   r.blocking_reason        = "";

   r.triggered_layers       = "NONE";
   r.reason_codes           = "";
   r.trace                  = "";

   r.dq_proxy_score         = -1.0;
   r.dq_threshold           = -1.0;
   r.dq_would_block         = false;

   r.v1_posture_observed    = "";
   r.v1_state_observed      = "";
   r.v1_would_block         = false;

   r.p4_divergence_observed = "";
   r.p4_would_block         = false;
}

AuthorityResult CreateDefaultAuthorityResult()
{
   AuthorityResult r;
   InitAuthorityStackPilotResult(r);
   return r;
}

double AuthorityClamp01(double v)
{
   if(!MathIsValidNumber(v)) return 0.0;
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

bool AuthorityIsTradeDecision(const RuntimeDecision decision)
{
   return (decision == RUNTIME_ENTER_BUY || decision == RUNTIME_ENTER_SELL);
}

string AuthorityDecisionToString(const RuntimeDecision decision)
{
   if(decision == RUNTIME_ENTER_BUY)  return "BUY";
   if(decision == RUNTIME_ENTER_SELL) return "SELL";
   if(decision == RUNTIME_REJECT)     return "REJECT";
   if(decision == RUNTIME_WAIT)       return "WAIT";
   return "UNKNOWN";
}

void AuthorityAppendCsvToken(string &csv, const string token)
{
   string t = token;
   StringTrimLeft(t);
   StringTrimRight(t);
   if(StringLen(t) <= 0)
      return;

   if(StringLen(csv) > 0)
      csv += ",";
   csv += t;
}

string AuthorityEnabledLayers(const bool enableStack,
                              const bool enableP4,
                              const bool enableDQ,
                              const bool enableV1)
{
   if(!enableStack)
      return "NONE";

   string s = "";
   if(enableP4) AuthorityAppendCsvToken(s, "P4");
   if(enableDQ) AuthorityAppendCsvToken(s, "DQ");
   if(enableV1) AuthorityAppendCsvToken(s, "V1");
   if(StringLen(s) <= 0)
      s = "NONE";
   return s;
}

string AuthorityP4DivergenceStateEquivalent(const string regime,
                                            const CouncilZoneType zoneType,
                                            const bool assessmentAvailable)
{
   string state = "UNKNOWN";
   if(assessmentAvailable)
   {
      bool eraDegraded = (regime == "RANGE_DIRTY" || regime == "COMPRESSION" || regime == "REVERSAL_RISK");
      bool exraDegraded = (zoneType == COUNCIL_ZONE_NO_TRADE ||
                           zoneType == COUNCIL_ZONE_RANGE_MEAN_RECLAIM ||
                           zoneType == COUNCIL_ZONE_COMPRESSION ||
                           zoneType == COUNCIL_ZONE_RANGE_BALANCED ||
                           zoneType == COUNCIL_ZONE_RANGE_DIRTY);
      bool exraRouteNative = (zoneType == COUNCIL_ZONE_TREND_CONTINUATION ||
                              zoneType == COUNCIL_ZONE_BREAKOUT_EXPANSION ||
                              zoneType == COUNCIL_ZONE_EXPANSION_CONTINUATION ||
                              zoneType == COUNCIL_ZONE_REVERSAL_EXHAUSTION);

      if(eraDegraded && exraDegraded)
         state = "ERA_EXRA_AGREE_DEGRADED";
      else if(eraDegraded && exraRouteNative)
         state = "ERA_DIRTY_EXRA_CLEAN_OR_ROUTE_NATIVE";
      else if(!eraDegraded && exraDegraded)
         state = "ERA_CLEAN_EXRA_DEGRADED";
      else if(!eraDegraded && !exraDegraded)
         state = "NO_DIRTY_CONTEXT";
   }
   return state;
}

string AuthorityComputeP4DivergenceStateFromRouted(const RoutedRuntimeEvaluation &routed,
                                                   const string eraRegimeLabel,
                                                   const double eraTradability)
{
   bool assessmentAvailable = false;
   if(routed.active_mode == "COUNCIL" && routed.council.valid)
   {
      double environmentScore = routed.council.aggregate.environment_score;
      double councilQuality = routed.council.aggregate.council_quality;
      assessmentAvailable = (StringLen(eraRegimeLabel) > 0 &&
                             MathIsValidNumber(eraTradability) && eraTradability >= 0.0 &&
                             MathIsValidNumber(environmentScore) && environmentScore >= 0.0 &&
                             MathIsValidNumber(councilQuality) && councilQuality >= 0.0);
   }

   return AuthorityP4DivergenceStateEquivalent(eraRegimeLabel, routed.council.env.zone_type, assessmentAvailable);
}

bool AuthorityP4WouldBlock(const string p4DivergenceState)
{
   return (p4DivergenceState == "ERA_EXRA_AGREE_DEGRADED");
}

double ComputeAuthorityDQProxy(const RoutedRuntimeEvaluation &routed)
{
   double quality = routed.council.aggregate.council_quality;
   double consensus = routed.council.aggregate.consensus_strength;
   double zoneConfidence = routed.council.env.zone_confidence;

   if(!MathIsValidNumber(quality)) quality = 0.0;
   if(!MathIsValidNumber(consensus)) consensus = 0.0;
   if(!MathIsValidNumber(zoneConfidence)) zoneConfidence = 0.0;

   return AuthorityClamp01((0.50 * quality) + (0.35 * consensus) + (0.15 * zoneConfidence));
}

bool AuthorityV1CurrentTickAvailable(const RoutedRuntimeEvaluation &routed)
{
   if(routed.active_mode != "COUNCIL" || !routed.council.valid)
      return false;

   return (StringLen(TrimString(routed.council.aggregate.v1_fsw_policy_posture)) > 0 &&
           StringLen(TrimString(routed.council.aggregate.v1_fsw_state_label)) > 0);
}

bool AuthorityV1WouldBlock(const RoutedRuntimeEvaluation &routed)
{
   string posture = TrimString(routed.council.aggregate.v1_fsw_policy_posture);
   string stateLabel = TrimString(routed.council.aggregate.v1_fsw_state_label);

   return (posture == "OBSERVE_ONLY" ||
           posture == "WAIT" ||
           posture == "UNDEFINED" ||
           stateLabel == "UNDEFINED_STATE");
}

void AuthorityPopulateTriggeredLayers(AuthorityResult &result)
{
   result.triggered_layers = "";
   if(result.p4_would_block) AuthorityAppendCsvToken(result.triggered_layers, "P4");
   if(result.dq_would_block) AuthorityAppendCsvToken(result.triggered_layers, "DQ");
   if(result.v1_would_block) AuthorityAppendCsvToken(result.triggered_layers, "V1");
   if(StringLen(result.triggered_layers) <= 0)
      result.triggered_layers = "NONE";
}

AuthorityResult ApplyAuthorityStackPilot(const RoutedRuntimeEvaluation &routed,
                                         RuntimeDecision &decision,
                                         const RuntimeDecision baselineDecision,
                                         const string p4DivergenceState,
                                         const bool enableStack,
                                         const bool enableP4,
                                         const bool enableDQ,
                                         const bool enableV1,
                                         const double dqThreshold)
{
   AuthorityResult result = CreateDefaultAuthorityResult();

   result.enabled           = enableStack;
   result.enabled_layers    = AuthorityEnabledLayers(enableStack, enableP4, enableDQ, enableV1);
   result.baseline_decision = AuthorityDecisionToString(baselineDecision);
   result.adjusted_decision = AuthorityDecisionToString(decision);
   result.dq_threshold      = dqThreshold;

   if(!enableStack)
   {
      result.trace = "STACK_DISABLED";
      return result;
   }

   if(!AuthorityIsTradeDecision(baselineDecision))
   {
      result.trace = "BASELINE_NOT_BUY_OR_SELL";
      return result;
   }

   if(routed.active_mode != "COUNCIL" || !routed.council.valid)
   {
      result.trace = "NON_COUNCIL_OR_INVALID_COUNCIL";
      return result;
   }

   result.evaluated = true;

   result.p4_divergence_observed = p4DivergenceState;
   result.p4_would_block = AuthorityP4WouldBlock(p4DivergenceState);

   result.dq_proxy_score = ComputeAuthorityDQProxy(routed);
   // A3-REVISED: DQ proxy is diagnostic-only. AuthorityStack_EnableDQ
   // remains a compatibility flag for observability, not live blocking.
   result.dq_would_block = false;

   result.v1_posture_observed = TrimString(routed.council.aggregate.v1_fsw_policy_posture);
   result.v1_state_observed = TrimString(routed.council.aggregate.v1_fsw_state_label);
   result.v1_would_block = (AuthorityV1CurrentTickAvailable(routed) ? AuthorityV1WouldBlock(routed) : false);

   AuthorityPopulateTriggeredLayers(result);

   if(enableP4 && result.p4_would_block)
   {
      decision = RUNTIME_REJECT;
      result.blocked = true;
      result.status = "BLOCKED_P4";
      result.primary_layer = "P4";
      result.blocking_authority = "P4";
      result.blocking_reason = "AUTHORITY_STACK_P4";
      result.reason_codes = "P4_ERA_EXRA_AGREE_DEGRADED";
      result.adjusted_decision = AuthorityDecisionToString(decision);
      result.changed_outcome = (result.baseline_decision != result.adjusted_decision);
      result.trace = "P4_BLOCK_FIRST";
      return result;
   }

   if(enableV1 && result.v1_would_block)
   {
      decision = RUNTIME_REJECT;
      result.blocked = true;
      result.status = "BLOCKED_V1";
      result.primary_layer = "V1";
      result.blocking_authority = "V1";
      result.blocking_reason = "AUTHORITY_STACK_V1";
      result.reason_codes = StringFormat("V1_POSTURE_%s_STATE_%s", result.v1_posture_observed, result.v1_state_observed);
      result.adjusted_decision = AuthorityDecisionToString(decision);
      result.changed_outcome = (result.baseline_decision != result.adjusted_decision);
      result.trace = "V1_BLOCK_THIRD";
      return result;
   }

   result.status = "PASSED";
   result.primary_layer = "NONE";
   result.blocking_authority = "NONE";
   result.blocking_reason = "";
   result.reason_codes = "";
   result.adjusted_decision = AuthorityDecisionToString(decision);
   result.changed_outcome = false;
   result.trace = "STACK_PASSED";

   return result;
}

#endif // __AUTHORITY_STACK_PILOT_MQH__
