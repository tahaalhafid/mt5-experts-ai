#ifndef __COUNCIL_ENVIRONMENT_MQH__
#define __COUNCIL_ENVIRONMENT_MQH__

#include "council_mode_types.mqh"
#include "atas_intake_layer.mqh"
#include "market_regime.mqh"
#include "core_market_data.mqh"

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
double CouncilClamp01(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

double CouncilNormalizeScore(double value, double minValue, double maxValue)
{
   if(maxValue <= minValue)
      return 0.0;

   return CouncilClamp01((value - minValue) / (maxValue - minValue));
}

double CouncilGetATR(ENUM_TIMEFRAMES tf, int period, int shift)
{
   int handle = iATR(_Symbol, tf, period);
   if(handle == INVALID_HANDLE)
      return 0.0;

   double buffer[];
   ArraySetAsSeries(buffer, true);

   double result = 0.0;
   if(CopyBuffer(handle, 0, shift, 1, buffer) == 1)
      result = buffer[0];

   IndicatorRelease(handle);
   return result;
}

bool CouncilStringContains(string s, string token)
{
   return (StringFind(s, token) >= 0);
}

//---------------------------------------------------------
// Candle helpers from snapshot
//---------------------------------------------------------
double CouncilGetBodySize(TimeframeSnapshot &m1)
{
   return MathAbs(m1.bar1.close - m1.bar1.open);
}

double CouncilGetRangeSize(TimeframeSnapshot &m1)
{
   return MathAbs(m1.bar1.high - m1.bar1.low);
}

double CouncilGetUpperWickSize(TimeframeSnapshot &m1)
{
   double top = MathMax(m1.bar1.open, m1.bar1.close);
   return MathMax(0.0, m1.bar1.high - top);
}

double CouncilGetLowerWickSize(TimeframeSnapshot &m1)
{
   double bottom = MathMin(m1.bar1.open, m1.bar1.close);
   return MathMax(0.0, bottom - m1.bar1.low);
}

//---------------------------------------------------------
// Liquidity evaluation
//---------------------------------------------------------
void EvaluateCouncilLiquidity(
   TimeframeSnapshot &m1,
   CouncilEnvironmentReport &r
)
{
   double atr = CouncilGetATR(m1.tf, 14, 1);
   double score = CouncilNormalizeScore(atr / _Point, 20.0, 250.0);

   r.liquidity_score = score;
   r.liquidity_ok    = (score >= 0.35);
}

//---------------------------------------------------------
// Spread evaluation
//---------------------------------------------------------
void EvaluateCouncilSpread(
   TimeframeSnapshot &m1,
   CouncilEnvironmentReport &r
)
{
   double spread = m1.spread_points;
   // Spread is evaluated in live symbol points ((ask-bid)/_Point), so keep
   // council normalization on the same point scale as runtime spread handling.
   double score  = 1.0 - CouncilNormalizeScore(spread, 200.0, 2000.0);

   r.spread_score = CouncilClamp01(score);
   r.spread_ok    = (r.spread_score >= 0.40);
}

//---------------------------------------------------------
// Volatility evaluation
//---------------------------------------------------------
void EvaluateCouncilVolatility(
   TimeframeSnapshot &m1,
   CouncilEnvironmentReport &r
)
{
   double atr = CouncilGetATR(m1.tf, 14, 1);
   double score = CouncilNormalizeScore(atr / _Point, 20.0, 200.0);

   r.volatility_score = score;
   r.volatility_ok    = (score >= 0.35);
}

//---------------------------------------------------------
// Momentum evaluation
//---------------------------------------------------------
void EvaluateCouncilMomentum(
   TimeframeSnapshot &m1,
   CouncilEnvironmentReport &r
)
{
   double body  = CouncilGetBodySize(m1);
   double range = CouncilGetRangeSize(m1);

   double ratio = 0.0;
   if(range > 0.0)
      ratio = body / range;

   r.momentum_score = CouncilClamp01(ratio);
   r.momentum_ok    = (r.momentum_score >= 0.35);
}

//---------------------------------------------------------
// Structure evaluation
//---------------------------------------------------------
void EvaluateCouncilStructure(
   MarketRegimeSnapshot &reg,
   CouncilEnvironmentReport &r
)
{
   double score = 0.0;

   if(reg.structure_state == "CLEAN")
      score += 0.60;
   else if(reg.structure_state == "NOISY")
      score += 0.25;

   if(reg.trend_state == "TREND_BULL" || reg.trend_state == "TREND_BEAR")
      score += 0.40;

   r.structure_score = CouncilClamp01(score);
   r.structure_ok    = (r.structure_score >= 0.35);
}

//---------------------------------------------------------
// Sweep context evaluation
//---------------------------------------------------------
void EvaluateCouncilSweepContext(
   MarketRegimeSnapshot &reg,
   CouncilEnvironmentReport &r
)
{
   bool cleanOrTrend =
      (reg.structure_state == "CLEAN") ||
      (reg.trend_state == "TREND_BULL") ||
      (reg.trend_state == "TREND_BEAR");

   r.sweep_context_score = cleanOrTrend ? 0.80 : 0.40;
   r.sweep_context_ok    = true;
}

//---------------------------------------------------------
// Session evaluation
//---------------------------------------------------------
void EvaluateCouncilSession(CouncilEnvironmentReport &r)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);

   int hour = dt.hour;

   bool london = (hour >= 9  && hour <= 13);
   bool ny     = (hour >= 15 && hour <= 18);

   bool goodSession = (london || ny);

   r.session_ok    = goodSession;
   r.session_score = goodSession ? 1.0 : 0.4;
}

//---------------------------------------------------------
// Exhaustion / bias hints
//---------------------------------------------------------
void EvaluateCouncilExhaustionHint(
   TimeframeSnapshot &m1,
   MarketRegimeSnapshot &reg,
   CouncilEnvironmentReport &r
)
{
   double range = CouncilGetRangeSize(m1);
   double body  = CouncilGetBodySize(m1);
   double upper = CouncilGetUpperWickSize(m1);
   double lower = CouncilGetLowerWickSize(m1);

   bool wickDominant = false;
   if(body > 0.0)
      wickDominant = (upper >= body * 1.8 || lower >= body * 1.8);
   else
      wickDominant = (upper > 0.0 || lower > 0.0);

   bool highMomentum = (r.momentum_score >= 0.70);
   bool highVol      = (r.volatility_score >= 0.70);
   bool rangeRegime  = CouncilStringContains(reg.summary, "RANGE");

   // Exhaustion hint:
   // strong move, large wick rejection, high vol, especially inside range-like context
   r.exhaustion_hint = (wickDominant && highVol && (highMomentum || rangeRegime));

   r.continuation_bias = false;
   r.reversal_bias     = false;

   if((reg.trend_state == "TREND_BULL" || reg.trend_state == "TREND_BEAR") &&
      r.structure_score >= 0.60 &&
      r.momentum_score >= 0.55 &&
      !r.exhaustion_hint)
   {
      r.continuation_bias = true;
   }

   if(r.exhaustion_hint || rangeRegime)
   {
      r.reversal_bias = true;
   }
}

//---------------------------------------------------------
// Zone classification
//---------------------------------------------------------
void ClassifyCouncilZone(
   MarketRegimeSnapshot &reg,
   CouncilEnvironmentReport &r
)
{
   r.zone_type            = COUNCIL_ZONE_UNDEFINED;
   r.zone_confidence      = 0.0;
   r.preferred_style      = COUNCIL_STYLE_UNSPECIFIED;
   r.blocked_style        = COUNCIL_STYLE_UNSPECIFIED;
   r.zone_name            = "UNDEFINED";
   r.preferred_style_text = "UNSPECIFIED";
   r.blocked_style_text   = "UNSPECIFIED";

   if(!r.tradable)
   {
      r.zone_type       = COUNCIL_ZONE_NO_TRADE;
      r.zone_confidence = 0.80;
      r.preferred_style = COUNCIL_STYLE_DEFENSIVE;
      r.blocked_style   = COUNCIL_STYLE_CONTINUATION;
   }
   else if(r.exhaustion_hint && r.reversal_bias)
   {
      r.zone_type       = COUNCIL_ZONE_REVERSAL_EXHAUSTION;
      r.zone_confidence = CouncilClamp01(0.55 + (r.momentum_score * 0.20) + (r.volatility_score * 0.20));
      r.preferred_style = COUNCIL_STYLE_REVERSAL;
      r.blocked_style   = COUNCIL_STYLE_CONTINUATION;
   }
   else if(CouncilStringContains(reg.summary, "RANGE") &&
           r.structure_score >= 0.45 &&
           r.spread_score >= 0.50)
   {
      r.zone_type       = COUNCIL_ZONE_RANGE_MEAN_RECLAIM;
      r.zone_confidence = CouncilClamp01(0.50 + (r.structure_score * 0.20) + (r.spread_score * 0.20));
      r.preferred_style = COUNCIL_STYLE_MEAN_RECLAIM;
      r.blocked_style   = COUNCIL_STYLE_BREAKOUT;
   }
   else if(r.continuation_bias &&
           (reg.trend_state == "TREND_BULL" || reg.trend_state == "TREND_BEAR") &&
           r.momentum_score >= 0.55)
   {
      r.zone_type       = COUNCIL_ZONE_TREND_CONTINUATION;
      r.zone_confidence = CouncilClamp01(0.55 + (r.structure_score * 0.20) + (r.momentum_score * 0.20));
      r.preferred_style = COUNCIL_STYLE_CONTINUATION;
      r.blocked_style   = COUNCIL_STYLE_REVERSAL;
   }
   else if((reg.structure_state == "CLEAN") &&
           r.volatility_score >= 0.70 &&
           r.momentum_score >= 0.60 &&
           !CouncilStringContains(reg.summary, "RANGE"))
   {
      r.zone_type       = COUNCIL_ZONE_BREAKOUT_EXPANSION;
      r.zone_confidence = CouncilClamp01(0.55 + (r.volatility_score * 0.20) + (r.momentum_score * 0.20));
      r.preferred_style = COUNCIL_STYLE_BREAKOUT;
      r.blocked_style   = COUNCIL_STYLE_MEAN_RECLAIM;
   }
   else
   {
      // fallback safe routing
      if(CouncilStringContains(reg.summary, "RANGE"))
      {
         r.zone_type       = COUNCIL_ZONE_RANGE_MEAN_RECLAIM;
         r.zone_confidence = 0.52;
         r.preferred_style = COUNCIL_STYLE_MEAN_RECLAIM;
         r.blocked_style   = COUNCIL_STYLE_BREAKOUT;
      }
      else
      {
         r.zone_type       = COUNCIL_ZONE_NO_TRADE;
         r.zone_confidence = 0.45;
         r.preferred_style = COUNCIL_STYLE_DEFENSIVE;
         r.blocked_style   = COUNCIL_STYLE_CONTINUATION;
      }
   }

   r.zone_name            = CouncilZoneTypeToText(r.zone_type);
   r.preferred_style_text = CouncilStyleTypeToText(r.preferred_style);
   r.blocked_style_text   = CouncilStyleTypeToText(r.blocked_style);
}

//---------------------------------------------------------
// Main builder
//---------------------------------------------------------
bool BuildCouncilEnvironmentReport(
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   CouncilEnvironmentReport &r
)
{
   InitCouncilEnvironmentReport(r);

   MarketRegimeSnapshot reg;
   BuildMarketRegimeSnapshot(m1, m5, reg);

   EvaluateCouncilLiquidity(m1, r);
   EvaluateCouncilSpread(m1, r);
   EvaluateCouncilVolatility(m1, r);
   EvaluateCouncilMomentum(m1, r);
   EvaluateCouncilStructure(reg, r);
   EvaluateCouncilSweepContext(reg, r);
   EvaluateCouncilSession(r);

   r.total_score =
      r.liquidity_score     * 0.20 +
      r.spread_score        * 0.15 +
      r.momentum_score      * 0.15 +
      r.volatility_score    * 0.15 +
      r.structure_score     * 0.15 +
      r.sweep_context_score * 0.10 +
      r.session_score       * 0.10;

   r.regime_summary = reg.summary;

   bool baseConditions =
      r.liquidity_ok &&
      r.spread_ok &&
      r.volatility_ok &&
      r.momentum_ok;

   r.tradable = (baseConditions && r.total_score >= 0.40);
   r.valid    = true;

   EvaluateCouncilExhaustionHint(m1, reg, r);
   ClassifyCouncilZone(reg, r);

   r.summary =
      "EnvScore=" + DoubleToString(r.total_score, 2) +
      " | Zone=" + r.zone_name +
      " | ZoneConf=" + DoubleToString(r.zone_confidence, 2) +
      " | Pref=" + r.preferred_style_text +
      " | Blocked=" + r.blocked_style_text +
      " | Liquidity=" + DoubleToString(r.liquidity_score, 2) +
      " | Spread=" + DoubleToString(r.spread_score, 2) +
      " | Momentum=" + DoubleToString(r.momentum_score, 2) +
      " | Volatility=" + DoubleToString(r.volatility_score, 2) +
      " | Structure=" + DoubleToString(r.structure_score, 2) +
      " | Exhaustion=" + string(r.exhaustion_hint ? "true" : "false") +
      " | Regime=" + reg.summary;

   if(!r.tradable)
      r.reject_reason = "Environment unsuitable for scalping";
   else
      r.reject_reason = "";

   // Phase 0 ATAS intake: strict shadow-only attachment with zero live influence.
   bool base_environment_valid = r.valid;
   if(base_environment_valid)
   {
      AtasAttachShadowRuntimeContext(
         _Symbol,
         base_environment_valid,
         r.atas_available,
         r.atas_shadow_attached,
         r.atas_quality_ok,
         r.atas_fresh,
         r.atas_acceptance_state,
         r.atas_rejection_reason,
         r.atas_consumption_mode,
         r.atas_summary,
         r.atas_shadow_overlay,
         r.atas_level_evidence_shadow,
         r.atas_trace
      );

      if(r.atas_shadow_attached)
      {
         r.atas_summary =
            "ATAS shadow attached to environment report (observability-only)" +
            " | acceptance=" + r.atas_acceptance_state +
            " | mode=" + r.atas_consumption_mode +
            " | quality_ok=" + string(r.atas_quality_ok ? "true" : "false") +
            " | fresh=" + string(r.atas_fresh ? "true" : "false") +
            " | overlay_weight=" + DoubleToString(r.atas_shadow_overlay.overlay_weight, 3) +
            " | overlay_cap=" + DoubleToString(ATAS_MAX_OVERLAY_WEIGHT, 3) +
            " | level_candidates=" + IntegerToString(r.atas_level_evidence_shadow.candidate_count) +
            " | authority=MT5_CANONICAL_RUNTIME_ONLY";
      }
      else
      {
         r.atas_summary =
            "ATAS shadow not attached" +
            " | acceptance=" + r.atas_acceptance_state +
            " | reason=" + r.atas_rejection_reason +
            " | mode=" + r.atas_consumption_mode +
            " | fallback=MT5_BASE_ONLY" +
            " | authority=MT5_CANONICAL_RUNTIME_ONLY";
      }

      r.atas_trace.valid = true;
      r.atas_trace.base_environment_source = "MT5_RUNTIME_ENVIRONMENT";
      r.atas_trace.base_environment_valid = true;
      r.atas_trace.atas_consumption_mode = r.atas_consumption_mode;
      r.atas_trace.live_influence_applied = false;
      r.atas_trace.live_influence_blocked = true;
      r.atas_trace.rejection_reason = r.atas_rejection_reason;
      r.atas_trace.trace_note =
         r.atas_trace.trace_note +
         " | env_report_attachment=descriptive_only" +
         " | score_impact=none" +
         " | tradability_impact=none" +
         " | zone_style_impact=none";
   }
   else
   {
      r.atas_available = false;
      r.atas_shadow_attached = false;
      r.atas_quality_ok = false;
      r.atas_fresh = false;
      r.atas_acceptance_state = "SHADOW_NOT_ATTACHED";
      r.atas_rejection_reason = AtasRejectionReasonToText(ATAS_REJECT_BASE_ENVIRONMENT_UNAVAILABLE);
      r.atas_consumption_mode = AtasConsumptionModeToText(ATAS_CONSUMPTION_SHADOW_ONLY);
      r.atas_summary = "ATAS shadow skipped because base MT5 environment is unavailable.";
      InitAtasMicrostructureOverlay(r.atas_shadow_overlay);
      InitAtasLevelEvidenceBundle(r.atas_level_evidence_shadow);
      InitTwinInfluenceTrace(r.atas_trace);
      r.atas_trace.valid = true;
      r.atas_trace.base_environment_source = "MT5_RUNTIME_ENVIRONMENT";
      r.atas_trace.base_environment_valid = false;
      r.atas_trace.atas_consumption_mode = r.atas_consumption_mode;
      r.atas_trace.live_influence_applied = false;
      r.atas_trace.live_influence_blocked = true;
      r.atas_trace.rejection_reason = r.atas_rejection_reason;
      r.atas_trace.trace_note =
         "BASE_ENVIRONMENT_UNAVAILABLE | ATAS shadow skipped" +
         " | fallback=MT5_BASE_ONLY" +
         " | score_impact=none" +
         " | tradability_impact=none" +
         " | zone_style_impact=none";
   }

   return true;
}

#endif
