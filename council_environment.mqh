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

double CouncilGetEMA(ENUM_TIMEFRAMES tf, int period, int shift)
{
   int handle = iMA(_Symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
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

double CouncilGetMFI(ENUM_TIMEFRAMES tf, int period, int shift)
{
   int handle = iMFI(_Symbol, tf, period, VOLUME_TICK);
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

   // Exhaustion hint: requires strong move + wick rejection + high volatility.
   // Removed rangeRegime short-circuit: routine range oscillation (wick-dominant low-body
   // candles) was firing exhaustion_hint on 43.9% of RANGE cycles as false-positive.
   // Genuine exhaustion = momentum spike followed by rejection, even in range context.
   r.exhaustion_hint = (wickDominant && highVol && highMomentum);

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
// CEIS Source Signal Layer — multi-horizon exhaustion sub-signals
//---------------------------------------------------------
void EvaluateCEISSourceSignals(
   CouncilEnvironmentReport &r
)
{
   // --------------------------------------------------------
   // Sub-signal 1: Spike-reversal M1 (preserved)
   // --------------------------------------------------------
   r.ceis_spike_reversal_m1 = r.exhaustion_hint;

   // --------------------------------------------------------
   // Sub-signal 2: M5 EMA overextension
   // Primary LATE_CONTINUATION_FAILURE detector.
   // Fires regardless of candle direction (BUY and SELL compatible).
   // --------------------------------------------------------
   r.ceis_overextension_m5 = false;
   double ema20_m5  = CouncilGetEMA(PERIOD_M5, 20, 1);
   double atr14_m5  = CouncilGetATR(PERIOD_M5, 14, 1);
   if(ema20_m5 > 0.0 && atr14_m5 > 0.0)
   {
      double close_m5_1 = iClose(_Symbol, PERIOD_M5, 1);
      r.ceis_overextension_m5 = (MathAbs(close_m5_1 - ema20_m5) / atr14_m5) >= 2.0;
   }

   // --------------------------------------------------------
   // Sub-signal 3: M5 MFI turning from extreme
   // Bear exhaustion: MFI declining while overbought (>55)
   // Bull exhaustion: MFI rising while oversold (<45)
   // Mirrors mfi_reversal_assist M1 logic, elevated to M5 horizon.
   // --------------------------------------------------------
   r.ceis_mfi_exhaustion_m5 = false;
   double mfi5_1 = CouncilGetMFI(PERIOD_M5, 14, 1);
   double mfi5_2 = CouncilGetMFI(PERIOD_M5, 14, 2);
   if(mfi5_1 > 0.0 && mfi5_2 > 0.0)
   {
      r.ceis_mfi_exhaustion_m5 = (mfi5_1 < mfi5_2 && mfi5_1 > 55.0) ||
                                  (mfi5_1 > mfi5_2 && mfi5_1 < 45.0);
   }

   // --------------------------------------------------------
   // Sub-signal 4: M15 MFI turning from extreme (higher stability)
   // Same logic as M5 — confirms M5 turning with a slower, more stable signal.
   // --------------------------------------------------------
   r.ceis_mfi_exhaustion_m15 = false;
   double mfi15_1 = CouncilGetMFI(PERIOD_M15, 14, 1);
   double mfi15_2 = CouncilGetMFI(PERIOD_M15, 14, 2);
   if(mfi15_1 > 0.0 && mfi15_2 > 0.0)
   {
      r.ceis_mfi_exhaustion_m15 = (mfi15_1 < mfi15_2 && mfi15_1 > 55.0) ||
                                   (mfi15_1 > mfi15_2 && mfi15_1 < 45.0);
   }

   // --------------------------------------------------------
   // Sub-signal 5: H1 MFI turning from extreme — structural context
   // Stricter thresholds (65/35) because H1 MFI moves slowly;
   // any turning at these levels represents multi-hour structural
   // overbought/oversold condition — architecturally meaningful for
   // TREND_CONTINUATION protection regardless of scalper origin.
   // Fires exhaustion_warning independently (see aggregator).
   // --------------------------------------------------------
   r.ceis_mfi_exhaustion_h1 = false;
   double mfi_h1_1 = CouncilGetMFI(PERIOD_H1, 14, 1);
   double mfi_h1_2 = CouncilGetMFI(PERIOD_H1, 14, 2);
   if(mfi_h1_1 > 0.0 && mfi_h1_2 > 0.0)
   {
      r.ceis_mfi_exhaustion_h1 = (mfi_h1_1 < mfi_h1_2 && mfi_h1_1 > 65.0) ||
                                  (mfi_h1_1 > mfi_h1_2 && mfi_h1_1 < 35.0);
   }

   // --------------------------------------------------------
   // Sub-signal 6: H4 MFI structural context — macro only
   // Very strict thresholds (68/32): only fires when H4 MFI is at
   // sustained extreme and beginning to reverse. Contributes to
   // ceis_source_score only — does NOT independently trigger
   // exhaustion_warning (macro context, not tactical gate).
   // --------------------------------------------------------
   r.ceis_mfi_context_h4 = false;
   double mfi_h4_1 = CouncilGetMFI(PERIOD_H4, 14, 1);
   double mfi_h4_2 = CouncilGetMFI(PERIOD_H4, 14, 2);
   if(mfi_h4_1 > 0.0 && mfi_h4_2 > 0.0)
   {
      r.ceis_mfi_context_h4 = (mfi_h4_1 < mfi_h4_2 && mfi_h4_1 > 68.0) ||
                               (mfi_h4_1 > mfi_h4_2 && mfi_h4_1 < 32.0);
   }

   // --------------------------------------------------------
   // Sub-signal 7: M5 momentum fade — ATR velocity loss
   // Trend is still in direction but the forward momentum engine
   // is losing power: ATR14_M5 now < 78% of ATR14_M5 eight bars ago.
   // Eight bars = 40 minutes on M5. Threshold 0.78 = 22% velocity loss.
   // Contributes to ceis_source_score — does NOT independently trigger
   // exhaustion_warning.
   // --------------------------------------------------------
   r.ceis_momentum_fade_m5 = false;
   if(atr14_m5 > 0.0)
   {
      double atr14_m5_prior = CouncilGetATR(PERIOD_M5, 14, 8);
      if(atr14_m5_prior > 0.0)
         r.ceis_momentum_fade_m5 = (atr14_m5 < atr14_m5_prior * 0.78);
   }

   // --------------------------------------------------------
   // Composite score — weighted by signal stability / horizon
   // Weights: overext=0.30, mfi_m5=0.20, mfi_m15=0.18,
   //          mfi_h1=0.15, fade_m5=0.15, spike_m1=0.12, mfi_h4=0.10
   // Sum can exceed 1.0 — clamped. Each weight reflects independent
   // contribution; stacking raises the score toward 1.0.
   // --------------------------------------------------------
   r.ceis_source_score =
      (r.ceis_overextension_m5   ? 0.30 : 0.0) +
      (r.ceis_mfi_exhaustion_m5  ? 0.20 : 0.0) +
      (r.ceis_mfi_exhaustion_m15 ? 0.18 : 0.0) +
      (r.ceis_mfi_exhaustion_h1  ? 0.15 : 0.0) +
      (r.ceis_momentum_fade_m5   ? 0.15 : 0.0) +
      (r.ceis_spike_reversal_m1  ? 0.12 : 0.0) +
      (r.ceis_mfi_context_h4     ? 0.10 : 0.0);
   if(r.ceis_source_score > 1.0) r.ceis_source_score = 1.0;

   r.ceis_signal_count = (r.ceis_spike_reversal_m1  ? 1 : 0) +
                         (r.ceis_overextension_m5   ? 1 : 0) +
                         (r.ceis_mfi_exhaustion_m5  ? 1 : 0) +
                         (r.ceis_mfi_exhaustion_m15 ? 1 : 0) +
                         (r.ceis_mfi_exhaustion_h1  ? 1 : 0) +
                         (r.ceis_mfi_context_h4     ? 1 : 0) +
                         (r.ceis_momentum_fade_m5   ? 1 : 0);
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
   // Stage 3 — COMPRESSION Zone Detection (PLAN-6 Stage 3)
   // Coiling market: low momentum, low volatility, no directional or reversal bias.
   // Intercepts compression regimes previously routed to RANGE_MEAN_RECLAIM fallback.
   else if(!r.continuation_bias &&
           !r.reversal_bias    &&
           r.momentum_score  < 0.45 &&
           r.volatility_score < 0.55)
   {
      r.zone_type       = COUNCIL_ZONE_COMPRESSION;
      r.zone_confidence = CouncilClamp01(0.42 + (r.structure_score * 0.15));
      r.preferred_style = COUNCIL_STYLE_BREAKOUT;
      r.blocked_style   = COUNCIL_STYLE_CONTINUATION;
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
         // PLAN-6 Stage 1 — NO_TRADE Truth Repair
         // Tradable market with no specific zone match is not equivalent to untradable.
         // Route to RANGE_MEAN_RECLAIM (most defensive tradable zone) at low confidence.
         // zone_confidence 0.38 < 0.50 triggers pre-filter tightening (+0.05 consensus, +0.03 quality).
         r.zone_type       = COUNCIL_ZONE_RANGE_MEAN_RECLAIM;
         r.zone_confidence = 0.38;
         r.preferred_style = COUNCIL_STYLE_MEAN_RECLAIM;
         r.blocked_style   = COUNCIL_STYLE_BREAKOUT;
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

   // PLAN-6 Stage 1 — NO_TRADE Truth Repair
   // momentum_ok (single M1 bar body/range >= 0.35) removed from hard tradability gate.
   // A single wick-dominated bar is not a market-wide untradability signal.
   // Momentum still suppresses total_score at 15% weight (soft path preserved).
   // Hard gate: liquidity + spread + volatility only (genuine market-level conditions).
   bool hardConditions =
      r.liquidity_ok &&
      r.spread_ok &&
      r.volatility_ok;

   r.tradable = hardConditions;
   r.valid    = true;

   EvaluateCouncilExhaustionHint(m1, reg, r);
   EvaluateCEISSourceSignals(r);
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
      " | CEIS=" + DoubleToString(r.ceis_source_score, 2) +
      " | CEISn=" + IntegerToString(r.ceis_signal_count) +
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
