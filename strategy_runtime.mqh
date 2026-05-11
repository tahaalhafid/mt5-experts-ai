#ifndef __STRATEGY_RUNTIME_MQH__
#define __STRATEGY_RUNTIME_MQH__

#include "strategy_compiler.mqh"
#include "core_market_data.mqh"
#include "market_regime.mqh"

//---------------------------------------------------------
// Runtime decisions
//---------------------------------------------------------
enum RuntimeDecision
{
   RUNTIME_WAIT       = 0,
   RUNTIME_ENTER_BUY  = 1,
   RUNTIME_ENTER_SELL = -1,
   RUNTIME_REJECT     = 2
};

struct RuntimeEvaluation
{
   RuntimeDecision decision;
   string reason;
};

//---------------------------------------------------------
// Internal enums
//---------------------------------------------------------
enum CoreDirection
{
   CORE_NONE = 0,
   CORE_BUY  = 1,
   CORE_SELL = -1
};

struct TriggerResult
{
   CoreDirection dir;
   double quality;   // 0..1
   string reason;
   bool valid;
};

struct ConfirmationSummary
{
   int strong_aligned;
   int medium_aligned;
   int strong_total;
   int medium_total;
   double quality;   // 0..1
   string detail;
};

struct FilterSummary
{
   bool   passed;
   bool   hard_blocked;
   double penalty;
   string reason;
};

struct ScoreBreakdown
{
   double trigger_score;
   double confirmation_score;
   double filter_penalty;
   double regime_bonus;
   double regime_penalty;
   double counter_trend_penalty;
   double trigger_missing_penalty;
   double spread_penalty;
   double final_score;
   string detail;
};

//---------------------------------------------------------
// Market helper functions
//---------------------------------------------------------
double RT_Open(ENUM_TIMEFRAMES tf, int shift)  { return iOpen(_Symbol, tf, shift);  }
double RT_Close(ENUM_TIMEFRAMES tf, int shift) { return iClose(_Symbol, tf, shift); }
double RT_High(ENUM_TIMEFRAMES tf, int shift)  { return iHigh(_Symbol, tf, shift);  }
double RT_Low(ENUM_TIMEFRAMES tf, int shift)   { return iLow(_Symbol, tf, shift);   }

bool RT_CopyOne(int handle, int bufferIndex, int shift, double &outVal)
{
   outVal = 0.0;
   if(handle == INVALID_HANDLE)
      return false;

   double buf[];
   ArraySetAsSeries(buf, true);

   if(CopyBuffer(handle, bufferIndex, shift, 1, buf) != 1)
      return false;

   outVal = buf[0];
   return true;
}

bool RT_GetBands(ENUM_TIMEFRAMES tf, int period, double deviation, int shift,
                 double &mid, double &upper, double &lower)
{
   mid = 0.0;
   upper = 0.0;
   lower = 0.0;

   int h = iBands(_Symbol, tf, period, 0, deviation, PRICE_CLOSE);
   if(h == INVALID_HANDLE)
      return false;

   bool ok0 = RT_CopyOne(h, 0, shift, mid);
   bool ok1 = RT_CopyOne(h, 1, shift, upper);
   bool ok2 = RT_CopyOne(h, 2, shift, lower);

   IndicatorRelease(h);
   return (ok0 && ok1 && ok2);
}

bool RT_GetEMA(ENUM_TIMEFRAMES tf, int period, int shift, double &ema)
{
   ema = 0.0;

   int h = iMA(_Symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
   if(h == INVALID_HANDLE)
      return false;

   bool ok = RT_CopyOne(h, 0, shift, ema);
   IndicatorRelease(h);
   return ok;
}

bool RT_GetMFI(ENUM_TIMEFRAMES tf, int period, int shift, double &mfi)
{
   mfi = 0.0;

   int h = iMFI(_Symbol, tf, period, VOLUME_TICK);
   if(h == INVALID_HANDLE)
      return false;

   bool ok = RT_CopyOne(h, 0, shift, mfi);
   IndicatorRelease(h);
   return ok;
}

bool RT_GetATR(ENUM_TIMEFRAMES tf, int period, int shift, double &atr)
{
   atr = 0.0;

   int h = iATR(_Symbol, tf, period);
   if(h == INVALID_HANDLE)
      return false;

   bool ok = RT_CopyOne(h, 0, shift, atr);
   IndicatorRelease(h);
   return ok;
}

double RT_BodySize(ENUM_TIMEFRAMES tf, int shift)
{
   return MathAbs(RT_Close(tf, shift) - RT_Open(tf, shift));
}

double RT_UpperWick(ENUM_TIMEFRAMES tf, int shift)
{
   double high  = RT_High(tf, shift);
   double open  = RT_Open(tf, shift);
   double close = RT_Close(tf, shift);
   return high - MathMax(open, close);
}

double RT_LowerWick(ENUM_TIMEFRAMES tf, int shift)
{
   double low   = RT_Low(tf, shift);
   double open  = RT_Open(tf, shift);
   double close = RT_Close(tf, shift);
   return MathMin(open, close) - low;
}

bool RT_BullishRejection(ENUM_TIMEFRAMES tf, int shift)
{
   double body = RT_BodySize(tf, shift);
   double lw   = RT_LowerWick(tf, shift);
   double c    = RT_Close(tf, shift);
   double o    = RT_Open(tf, shift);

   if(c <= o || body <= 0.0)
      return false;

   return (lw >= body * 0.8);
}

bool RT_BearishRejection(ENUM_TIMEFRAMES tf, int shift)
{
   double body = RT_BodySize(tf, shift);
   double uw   = RT_UpperWick(tf, shift);
   double c    = RT_Close(tf, shift);
   double o    = RT_Open(tf, shift);

   if(c >= o || body <= 0.0)
      return false;

   return (uw >= body * 0.8);
}

bool RT_SweepUpper(ENUM_TIMEFRAMES tf, int shift)
{
   double h1 = RT_High(tf, shift);
   double h2 = RT_High(tf, shift + 1);
   double c1 = RT_Close(tf, shift);

   double mid = 0.0, up = 0.0, lo = 0.0;
   if(!RT_GetBands(tf, 20, 2.0, shift, mid, up, lo))
      return false;

   return (h1 > h2 && h1 >= up && c1 < up);
}

bool RT_SweepLower(ENUM_TIMEFRAMES tf, int shift)
{
   double l1 = RT_Low(tf, shift);
   double l2 = RT_Low(tf, shift + 1);
   double c1 = RT_Close(tf, shift);

   double mid = 0.0, up = 0.0, lo = 0.0;
   if(!RT_GetBands(tf, 20, 2.0, shift, mid, up, lo))
      return false;

   return (l1 < l2 && l1 <= lo && c1 > lo);
}

bool RT_M1TrendBull()
{
   double emaFast = 0.0, emaSlow = 0.0;
   if(!RT_GetEMA(PERIOD_M1, 20, 1, emaFast)) return false;
   if(!RT_GetEMA(PERIOD_M1, 50, 1, emaSlow)) return false;

   double close1 = RT_Close(PERIOD_M1, 1);
   return (emaFast > emaSlow && close1 >= emaFast);
}

bool RT_M1TrendBear()
{
   double emaFast = 0.0, emaSlow = 0.0;
   if(!RT_GetEMA(PERIOD_M1, 20, 1, emaFast)) return false;
   if(!RT_GetEMA(PERIOD_M1, 50, 1, emaSlow)) return false;

   double close1 = RT_Close(PERIOD_M1, 1);
   return (emaFast < emaSlow && close1 <= emaFast);
}

bool RT_M5TrendBull()
{
   double emaFast = 0.0, emaSlow = 0.0;
   if(!RT_GetEMA(PERIOD_M5, 20, 1, emaFast)) return false;
   if(!RT_GetEMA(PERIOD_M5, 50, 1, emaSlow)) return false;

   double close1 = RT_Close(PERIOD_M5, 1);
   return (emaFast > emaSlow && close1 >= emaFast);
}

bool RT_M5TrendBear()
{
   double emaFast = 0.0, emaSlow = 0.0;
   if(!RT_GetEMA(PERIOD_M5, 20, 1, emaFast)) return false;
   if(!RT_GetEMA(PERIOD_M5, 50, 1, emaSlow)) return false;

   double close1 = RT_Close(PERIOD_M5, 1);
   return (emaFast < emaSlow && close1 <= emaFast);
}

//---------------------------------------------------------
// === ZONE 1: LIVE SHARED SUBSTRATE (above this line) ===
// All types, enums, structs, and market helpers above are unconditionally compiled.
// Actively consumed by COUNCIL execution path. Must not be placed inside any guard.
//
// === ZONE 2-A: FALLBACK COMPATIBILITY — plan-adjuster / score-discipline helpers ===
// Only called from Zone 2 evaluation engine. Zero external callers confirmed.
// Compile-excluded when STRATEGY_RUNTIME_DISABLE_ZONE2 is defined (not currently defined).
//---------------------------------------------------------
#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2
double RT_AdjustQualityThresholdByMode(CompiledPlan &plan)
{
   double threshold = plan.signal_quality_threshold;

   if(plan.execution_mode == "CONSERVATIVE")
      threshold += 0.05;
   else if(plan.execution_mode == "AGGRESSIVE")
      threshold -= 0.05;

   if(plan.aggression_level == "LOW")
      threshold += 0.03;
   else if(plan.aggression_level == "HIGH")
      threshold -= 0.03;

   if(threshold < 0.0) threshold = 0.0;
   if(threshold > 1.0) threshold = 1.0;

   return threshold;
}

double RT_AdjustConfirmationThresholdByMode(CompiledPlan &plan)
{
   double threshold = plan.minimum_confirmation_score;

   if(plan.execution_mode == "CONSERVATIVE")
      threshold += 0.05;
   else if(plan.execution_mode == "AGGRESSIVE")
      threshold -= 0.05;

   if(plan.aggression_level == "LOW")
      threshold += 0.03;
   else if(plan.aggression_level == "HIGH")
      threshold -= 0.03;

   if(threshold < 0.0) threshold = 0.0;
   if(threshold > 1.0) threshold = 1.0;

   return threshold;
}

double RT_AdjustScoreEntryThresholdByMode(CompiledPlan &plan)
{
   double threshold = plan.score_entry_threshold;

   if(plan.execution_mode == "CONSERVATIVE")
      threshold += 0.05;
   else if(plan.execution_mode == "AGGRESSIVE")
      threshold -= 0.05;

   if(plan.aggression_level == "LOW")
      threshold += 0.03;
   else if(plan.aggression_level == "HIGH")
      threshold -= 0.03;

   if(threshold < 0.0) threshold = 0.0;
   if(threshold > 1.0) threshold = 1.0;

   return threshold;
}

double RT_GetSpreadMultiplier(CompiledPlan &plan)
{
   if(plan.spread_policy_mode == "STRICT")
      return 0.75;

   if(plan.spread_policy_mode == "FLEXIBLE")
      return 1.25;

   return 1.0;
}

bool RT_IsCounterTrendTrade(CoreDirection dir)
{
   bool m5Bull = RT_M5TrendBull();
   bool m5Bear = RT_M5TrendBear();

   if(dir == CORE_BUY && m5Bear)
      return true;

   if(dir == CORE_SELL && m5Bull)
      return true;

   return false;
}

bool RT_DirectionAllowedByBias(CompiledPlan &plan, CoreDirection dir)
{
   if(plan.bias_direction == "BOTH" || plan.bias_direction == "AUTO" || plan.bias_direction == "")
      return true;

   if(plan.bias_direction == "BUY_ONLY" && dir == CORE_BUY)
      return true;

   if(plan.bias_direction == "SELL_ONLY" && dir == CORE_SELL)
      return true;

   return false;
}

double RT_GetTriggerWeight(CompiledPlan &plan, string id)
{
   for(int i = 0; i < plan.trigger_weights_count; i++)
   {
      if(plan.trigger_weight_ids[i] == id)
         return plan.trigger_weights[i];
   }

   return 0.0;
}

double RT_GetConfirmationWeight(CompiledPlan &plan, string id)
{
   for(int i = 0; i < plan.confirmation_weights_count; i++)
   {
      if(plan.confirmation_weight_ids[i] == id)
         return plan.confirmation_weights[i];
   }

   return 0.0;
}

double RT_GetFilterPenalty(CompiledPlan &plan, string id)
{
   for(int i = 0; i < plan.filter_penalties_count; i++)
   {
      if(plan.filter_penalty_ids[i] == id)
         return plan.filter_penalties[i];
   }

   return plan.soft_filter_penalty;
}

//---------------------------------------------------------
// Score discipline helpers
//---------------------------------------------------------
double RT_GetConfirmationScoreCap(CompiledPlan &plan)
{
   double cap = 0.40;

   if(plan.plan_mode == "WEIGHTED")
      cap = 0.35;

   if(plan.execution_mode == "CONSERVATIVE")
      cap -= 0.05;
   else if(plan.execution_mode == "AGGRESSIVE")
      cap += 0.05;

   if(cap < 0.20) cap = 0.20;
   if(cap > 0.55) cap = 0.55;

   return cap;
}

double RT_ApplyConfirmationCap(CompiledPlan &plan, double rawConfirmationScore)
{
   double cap = RT_GetConfirmationScoreCap(plan);

   if(rawConfirmationScore < 0.0)
      rawConfirmationScore = 0.0;

   if(rawConfirmationScore > cap)
      return cap;

   return rawConfirmationScore;
}

double RT_EnforceTriggerDominance(double triggerScore, double confirmationScore)
{
   if(triggerScore <= 0.0)
      return confirmationScore;

   double maxByTrigger = triggerScore * 1.10;

   if(maxByTrigger < 0.20)
      maxByTrigger = 0.20;

   if(maxByTrigger > 0.45)
      maxByTrigger = 0.45;

   if(confirmationScore > maxByTrigger)
      return maxByTrigger;

   return confirmationScore;
}

double RT_GetTriggerScoreCap(CompiledPlan &plan)
{
   double cap = 1.00;

   if(plan.execution_mode == "CONSERVATIVE")
      cap = 0.85;
   else if(plan.execution_mode == "AGGRESSIVE")
      cap = 1.10;

   if(plan.aggression_level == "LOW")
      cap -= 0.05;
   else if(plan.aggression_level == "HIGH")
      cap += 0.05;

   if(plan.plan_mode == "WEIGHTED")
      cap += 0.05;

   if(cap < 0.70) cap = 0.70;
   if(cap > 1.20) cap = 1.20;

   return cap;
}

double RT_ApplyTriggerCap(CompiledPlan &plan, double rawTriggerScore)
{
   if(rawTriggerScore < 0.0)
      rawTriggerScore = 0.0;

   double cap = RT_GetTriggerScoreCap(plan);
   if(rawTriggerScore > cap)
      return cap;

   return rawTriggerScore;
}

double RT_GetRegimeBonusCap(CompiledPlan &plan)
{
   double cap = 0.25;

   if(plan.execution_mode == "CONSERVATIVE")
      cap = 0.18;
   else if(plan.execution_mode == "AGGRESSIVE")
      cap = 0.30;

   if(plan.aggression_level == "LOW")
      cap -= 0.03;
   else if(plan.aggression_level == "HIGH")
      cap += 0.03;

   if(cap < 0.12) cap = 0.12;
   if(cap > 0.35) cap = 0.35;

   return cap;
}

double RT_ApplyRegimeBonusCap(CompiledPlan &plan, double rawBonus)
{
   if(rawBonus < 0.0)
      rawBonus = 0.0;

   double cap = RT_GetRegimeBonusCap(plan);
   if(rawBonus > cap)
      return cap;

   return rawBonus;
}

double RT_GetRegimePenaltyCap(CompiledPlan &plan)
{
   double cap = 0.35;

   if(plan.execution_mode == "CONSERVATIVE")
      cap = 0.40;
   else if(plan.execution_mode == "AGGRESSIVE")
      cap = 0.30;

   if(cap < 0.20) cap = 0.20;
   if(cap > 0.50) cap = 0.50;

   return cap;
}

double RT_ApplyRegimePenaltyCap(CompiledPlan &plan, double rawPenalty)
{
   if(rawPenalty < 0.0)
      rawPenalty = 0.0;

   double cap = RT_GetRegimePenaltyCap(plan);
   if(rawPenalty > cap)
      return cap;

   return rawPenalty;
}

bool RT_MainTriggerValidForDirection(TriggerResult &tr, CoreDirection dir)
{
   return (tr.valid && tr.dir == dir);
}

#endif // STRATEGY_RUNTIME_DISABLE_ZONE2

//---------------------------------------------------------
// === ZONE 1 TRIGGER ISLAND — unconditionally compiled ===
// DetectBollingerReclaimTrigger, DetectSweepDetectorTrigger, DetectEMATrendAlignmentTrigger.
// Called directly by council_strategies.mqh in live COUNCIL execution.
// Must not be placed inside any guard.
//---------------------------------------------------------
TriggerResult DetectBollingerReclaimTrigger()
{
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "No Bollinger reclaim";
   tr.valid = false;

   double mid = 0.0, up = 0.0, lo = 0.0;
   if(!RT_GetBands(PERIOD_M1, 20, 2.0, 1, mid, up, lo))
   {
      tr.reason = "Bollinger unavailable";
      return tr;
   }

   double close1 = RT_Close(PERIOD_M1, 1);
   double high1  = RT_High(PERIOD_M1, 1);
   double low1   = RT_Low(PERIOD_M1, 1);

   bool buyReclaim  = (low1 <= lo && close1 > lo);
   bool sellReclaim = (high1 >= up && close1 < up);

   if(buyReclaim && !sellReclaim)
   {
      tr.dir = CORE_BUY;
      tr.quality = RT_BullishRejection(PERIOD_M1, 1) ? 0.80 : 0.65;
      tr.reason = "Bollinger lower reclaim";
      tr.valid = true;
      return tr;
   }

   if(sellReclaim && !buyReclaim)
   {
      tr.dir = CORE_SELL;
      tr.quality = RT_BearishRejection(PERIOD_M1, 1) ? 0.80 : 0.65;
      tr.reason = "Bollinger upper reclaim";
      tr.valid = true;
      return tr;
   }

   tr.reason = "No clean Bollinger reclaim";
   return tr;
}

TriggerResult DetectSweepDetectorTrigger()
{
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "No sweep trigger";
   tr.valid = false;

   bool sweepL = RT_SweepLower(PERIOD_M1, 1);
   bool sweepU = RT_SweepUpper(PERIOD_M1, 1);

   if(sweepL && !sweepU)
   {
      tr.dir = CORE_BUY;
      tr.quality = 0.85;
      tr.reason = "Liquidity sweep lower + reclaim";
      tr.valid = true;
      return tr;
   }

   if(sweepU && !sweepL)
   {
      tr.dir = CORE_SELL;
      tr.quality = 0.85;
      tr.reason = "Liquidity sweep upper + reclaim";
      tr.valid = true;
      return tr;
   }

   tr.reason = "No valid liquidity sweep";
   return tr;
}

TriggerResult DetectEMATrendAlignmentTrigger()
{
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "No EMA trend alignment";
   tr.valid = false;

   bool bullM1 = RT_M1TrendBull();
   bool bearM1 = RT_M1TrendBear();
   bool bullM5 = RT_M5TrendBull();
   bool bearM5 = RT_M5TrendBear();

   double close1 = RT_Close(PERIOD_M1, 1);
   double ema20  = 0.0;
   RT_GetEMA(PERIOD_M1, 20, 1, ema20);

   // --- Trend-Momentum Entry-Quality Guard V1 (not_late) ---
   // Prevents late-continuation entries where close is already extended
   // beyond 1.20*ATR(M1,14) from EMA20_M1 in the trade direction.
   // Mirrors DetectTrendPullbackContinuationTrigger() not_late clause.
   // ATR fail-open: guard does not fire if ATR is unavailable.
   double atrM1Guard = 0.0;
   bool   atrOk      = RT_GetATR(PERIOD_M1, 14, 1, atrM1Guard);
   const double TM_NOT_LATE_MULT = 1.20;
   bool notLateBuy  = (!atrOk || atrM1Guard <= 0.0) ? true
                      : ((close1 - ema20) <= atrM1Guard * TM_NOT_LATE_MULT);
   bool notLateSell = (!atrOk || atrM1Guard <= 0.0) ? true
                      : ((ema20 - close1) <= atrM1Guard * TM_NOT_LATE_MULT);
   // --- END Entry-Quality Guard V1 ---

   if(bullM1 && bullM5 && close1 >= ema20 && notLateBuy)
   {
      tr.dir = CORE_BUY;
      tr.quality = 0.72;
      tr.reason = "EMA trend aligned bullish";
      tr.valid = true;
      return tr;
   }

   if(bearM1 && bearM5 && close1 <= ema20 && notLateSell)
   {
      tr.dir = CORE_SELL;
      tr.quality = 0.72;
      tr.reason = "EMA trend aligned bearish";
      tr.valid = true;
      return tr;
   }

   if(bullM1 && bullM5 && close1 >= ema20 && !notLateBuy)
   {
      double ratio = (atrM1Guard > 0.0) ? ((close1 - ema20) / atrM1Guard) : 0.0;
      tr.reason = "EMA aligned BUY but late: dist>ATR*1.20 ratio=" + DoubleToString(ratio, 2);
   }
   else if(bearM1 && bearM5 && close1 <= ema20 && !notLateSell)
   {
      double ratio = (atrM1Guard > 0.0) ? ((ema20 - close1) / atrM1Guard) : 0.0;
      tr.reason = "EMA aligned SELL but late: dist>ATR*1.20 ratio=" + DoubleToString(ratio, 2);
   }
   else
      tr.reason = "No EMA trend alignment";
   return tr;
}

// === ZONE 1 TRIGGER ISLAND END ===

//---------------------------------------------------------
// === ZONE 2-B: FALLBACK COMPATIBILITY — evaluation engine ===
// EvaluateIndicatorAsTrigger, DetectMainTrigger, confirmation/filter/regime/score/gate
// helpers, EvaluateByGateMode, EvaluateByScoreMode, EvaluateByHybridMode, EvaluateCompiledPlan.
// Only external entry point: EvaluateCompiledPlan (called from decision_mode_router.mqh).
// Compile-excluded when STRATEGY_RUNTIME_DISABLE_ZONE2 is defined (not currently defined).
//---------------------------------------------------------
#ifndef STRATEGY_RUNTIME_DISABLE_ZONE2
TriggerResult EvaluateIndicatorAsTrigger(string triggerId)
{
   if(triggerId == "bollinger_reclaim_trigger")
      return DetectBollingerReclaimTrigger();

   if(triggerId == "sweep_detector")
      return DetectSweepDetectorTrigger();

   if(triggerId == "ema_trend_alignment")
      return DetectEMATrendAlignmentTrigger();

   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "Unsupported trigger: " + triggerId;
   tr.valid = false;
   return tr;
}

TriggerResult DetectMainTrigger(CompiledPlan &plan)
{
   return EvaluateIndicatorAsTrigger(plan.main_trigger_id);
}

//---------------------------------------------------------
// Confirmation evaluation
//---------------------------------------------------------
bool IsStrongConfirmationAligned(string indicatorId, CoreDirection dir)
{
   if(indicatorId == "sweep_detector")
   {
      if(dir == CORE_BUY)  return RT_SweepLower(PERIOD_M1, 1);
      if(dir == CORE_SELL) return RT_SweepUpper(PERIOD_M1, 1);
      return false;
   }

   if(indicatorId == "candle_rejection_validation")
   {
      if(dir == CORE_BUY)  return RT_BullishRejection(PERIOD_M1, 1);
      if(dir == CORE_SELL) return RT_BearishRejection(PERIOD_M1, 1);
      return false;
   }

   if(indicatorId == "bollinger_reclaim_trigger")
   {
      TriggerResult tr = DetectBollingerReclaimTrigger();
      return (tr.valid && tr.dir == dir);
   }

   if(indicatorId == "mfi_momentum")
   {
      double mfi1 = 0.0, mfi2 = 0.0;
      if(!RT_GetMFI(PERIOD_M1, 14, 1, mfi1)) return false;
      if(!RT_GetMFI(PERIOD_M1, 14, 2, mfi2)) return false;

      if(dir == CORE_BUY)  return (mfi1 > mfi2 && mfi1 < 55.0);
      if(dir == CORE_SELL) return (mfi1 < mfi2 && mfi1 > 45.0);
      return false;
   }

   if(indicatorId == "ema_trend_alignment")
   {
      if(dir == CORE_BUY)  return (RT_M1TrendBull() && RT_M5TrendBull());
      if(dir == CORE_SELL) return (RT_M1TrendBear() && RT_M5TrendBear());
      return false;
   }

   return false;
}

bool IsMediumConfirmationAligned(string indicatorId, CoreDirection dir)
{
   if(indicatorId == "mfi_momentum")
   {
      double mfi1 = 0.0, mfi2 = 0.0;
      if(!RT_GetMFI(PERIOD_M1, 14, 1, mfi1)) return false;
      if(!RT_GetMFI(PERIOD_M1, 14, 2, mfi2)) return false;

      if(dir == CORE_BUY)  return (mfi1 > mfi2);
      if(dir == CORE_SELL) return (mfi1 < mfi2);
      return false;
   }

   if(indicatorId == "ema_trend_alignment")
   {
      if(dir == CORE_BUY)  return (RT_M1TrendBull() || RT_M5TrendBull());
      if(dir == CORE_SELL) return (RT_M1TrendBear() || RT_M5TrendBear());
      return false;
   }

   if(indicatorId == "candle_rejection_validation")
   {
      if(dir == CORE_BUY)  return RT_BullishRejection(PERIOD_M1, 1);
      if(dir == CORE_SELL) return RT_BearishRejection(PERIOD_M1, 1);
      return false;
   }

   if(indicatorId == "sweep_detector")
   {
      if(dir == CORE_BUY)  return RT_SweepLower(PERIOD_M1, 1);
      if(dir == CORE_SELL) return RT_SweepUpper(PERIOD_M1, 1);
      return false;
   }

   if(indicatorId == "bollinger_reclaim_trigger")
   {
      TriggerResult tr = DetectBollingerReclaimTrigger();
      return (tr.valid && tr.dir == dir);
   }

   return false;
}

ConfirmationSummary EvaluateConfirmations(CompiledPlan &plan, CoreDirection dir)
{
   ConfirmationSummary cs;
   cs.strong_aligned = 0;
   cs.medium_aligned = 0;
   cs.strong_total   = plan.strong_confirmations_count;
   cs.medium_total   = plan.medium_confirmations_count;
   cs.quality        = 0.0;
   cs.detail         = "";

   for(int i = 0; i < plan.strong_confirmations_count; i++)
   {
      string indicatorId = plan.strong_confirmation_ids[i];
      if(IsStrongConfirmationAligned(indicatorId, dir))
         cs.strong_aligned++;
   }

   for(int j = 0; j < plan.medium_confirmations_count; j++)
   {
      string indicatorId = plan.medium_confirmation_ids[j];
      if(IsMediumConfirmationAligned(indicatorId, dir))
         cs.medium_aligned++;
   }

   double strongRatio = 0.0;
   double mediumRatio = 0.0;

   if(cs.strong_total > 0)
      strongRatio = (double)cs.strong_aligned / (double)cs.strong_total;

   if(cs.medium_total > 0)
      mediumRatio = (double)cs.medium_aligned / (double)cs.medium_total;

   cs.quality = (strongRatio * 0.7) + (mediumRatio * 0.3);
   cs.detail =
      "Strong " + IntegerToString(cs.strong_aligned) + "/" + IntegerToString(cs.strong_total) +
      " | Medium " + IntegerToString(cs.medium_aligned) + "/" + IntegerToString(cs.medium_total);

   return cs;
}

double EvaluateWeightedConfirmations(CompiledPlan &plan, CoreDirection dir, string &detail)
{
   detail = "";
   double rawScore = 0.0;
   int matched = 0;

   for(int i = 0; i < plan.confirmation_weights_count; i++)
   {
      string id = plan.confirmation_weight_ids[i];
      double w  = plan.confirmation_weights[i];

      bool ok = IsStrongConfirmationAligned(id, dir) || IsMediumConfirmationAligned(id, dir);
      if(ok)
      {
         rawScore += (w * plan.confirmation_bonus_multiplier);
         matched++;
      }
   }

   double cappedScore = RT_ApplyConfirmationCap(plan, rawScore);

   detail =
      "WeightedConfirmationsMatched=" + IntegerToString(matched) +
      " | RawConf=" + DoubleToString(rawScore, 2) +
      " | CappedConf=" + DoubleToString(cappedScore, 2);

   return cappedScore;
}

//---------------------------------------------------------
// Filter evaluation
//---------------------------------------------------------
bool PassFilter(string filterId, CompiledPlan &plan, TimeframeSnapshot &m1, TimeframeSnapshot &m5, CoreDirection dir, string &reason)
{
   reason = "";

   if(filterId == "atr_volatility_filter")
   {
      double atr = 0.0;
      if(!RT_GetATR(PERIOD_M1, 14, 1, atr))
      {
         reason = "ATR unavailable";
         return false;
      }

      double atrPoints = atr / _Point;
      if(atrPoints < 80.0)
      {
         reason = "ATR too low";
         return false;
      }

      return true;
   }

   if(filterId == "spread_filter")
   {
      double effectiveMaxSpread = plan.max_spread_points * RT_GetSpreadMultiplier(plan);

      if(plan.use_spread_filter)
      {
         if(m1.spread_points > effectiveMaxSpread)
         {
            reason = "Spread too high";
            return false;
         }
      }
      return true;
   }

   if(filterId == "m5_direction_filter")
   {
      if(dir == CORE_BUY && !RT_M5TrendBull())
      {
         reason = "M5 bullish alignment missing";
         return false;
      }

      if(dir == CORE_SELL && !RT_M5TrendBear())
      {
         reason = "M5 bearish alignment missing";
         return false;
      }

      return true;
   }

   return true;
}

FilterSummary EvaluateFilters(CompiledPlan &plan, TimeframeSnapshot &m1, TimeframeSnapshot &m5, CoreDirection dir)
{
   FilterSummary fs;
   fs.passed = true;
   fs.hard_blocked = false;
   fs.penalty = 0.0;
   fs.reason = "All filters processed";

   double effectiveMaxSpread = plan.max_spread_points * RT_GetSpreadMultiplier(plan);

   if(plan.use_spread_filter && m1.spread_points > effectiveMaxSpread)
   {
      if(plan.use_soft_filters)
      {
         fs.penalty += (plan.soft_filter_penalty * plan.filter_penalty_multiplier);
         fs.reason = "Soft spread penalty";
      }
      else
      {
         fs.passed = false;
         fs.hard_blocked = true;
         fs.reason = "Spread above effective max spread";
         return fs;
      }
   }

   for(int i = 0; i < plan.required_filters_count; i++)
   {
      string filterId = plan.required_filter_ids[i];
      string reason = "";

      bool ok = PassFilter(filterId, plan, m1, m5, dir, reason);
      if(!ok)
      {
         if(plan.use_soft_filters)
         {
            fs.penalty += (RT_GetFilterPenalty(plan, filterId) * plan.filter_penalty_multiplier);
            fs.reason = "Soft filter penalty: " + filterId + " | " + reason;
         }
         else
         {
            fs.passed = false;
            fs.hard_blocked = true;
            fs.reason = "Filter failed: " + filterId + " | " + reason;
            return fs;
         }
      }
   }

   if(fs.penalty < 0.0)
      fs.penalty = 0.0;

   return fs;
}

//---------------------------------------------------------
// Regime interpreter
//---------------------------------------------------------
bool RT_RegimeTrendAllowed(CompiledPlan &plan, MarketRegimeSnapshot &reg, string &reason)
{
   reason = "";

   string mode = plan.allowed_regime_trend;

   if(mode == "ANY")
      return true;

   if(mode == "TREND_ONLY")
   {
      if(reg.trend_state == "TREND_BULL" || reg.trend_state == "TREND_BEAR")
         return true;

      reason = "Trend regime required";
      return false;
   }

   if(mode == "RANGE_ONLY")
   {
      if(reg.trend_state == "RANGE")
         return true;

      reason = "Range regime required";
      return false;
   }

   if(mode == "TREND_BULL")
   {
      if(reg.trend_state == "TREND_BULL")
         return true;

      reason = "TREND_BULL required";
      return false;
   }

   if(mode == "TREND_BEAR")
   {
      if(reg.trend_state == "TREND_BEAR")
         return true;

      reason = "TREND_BEAR required";
      return false;
   }

   reason = "Unknown trend regime policy";
   return false;
}

bool RT_RegimeVolatilityAllowed(CompiledPlan &plan, MarketRegimeSnapshot &reg, string &reason)
{
   reason = "";

   if(plan.allowed_regime_volatility == "ANY")
      return true;

   if(plan.allowed_regime_volatility == reg.volatility_state)
      return true;

   reason = "Volatility regime blocked";
   return false;
}

bool RT_RegimeStructureAllowed(CompiledPlan &plan, MarketRegimeSnapshot &reg, string &reason)
{
   reason = "";

   if(plan.allowed_regime_structure == "ANY")
      return true;

   if(plan.allowed_regime_structure == reg.structure_state)
      return true;

   reason = "Structure regime blocked";
   return false;
}

double RT_ComputeRegimeBonus(CompiledPlan &plan, MarketRegimeSnapshot &reg, string &detail)
{
   detail = "";
   double rawBonus = 0.0;

   if(plan.regime_bonus_trend == "ANY" || plan.regime_bonus_trend == reg.trend_state)
      rawBonus += plan.regime_alignment_bonus * plan.environment_bonus_multiplier;

   if(plan.regime_bonus_volatility == "ANY" || plan.regime_bonus_volatility == reg.volatility_state)
      rawBonus += plan.regime_alignment_bonus * plan.environment_bonus_multiplier;

   if(plan.regime_bonus_structure == "ANY" || plan.regime_bonus_structure == reg.structure_state)
      rawBonus += plan.regime_alignment_bonus * plan.environment_bonus_multiplier;

   double cappedBonus = RT_ApplyRegimeBonusCap(plan, rawBonus);

   detail =
      "RegimeBonusRaw=" + DoubleToString(rawBonus, 2) +
      " | RegimeBonusCapped=" + DoubleToString(cappedBonus, 2);

   return cappedBonus;
}

double RT_ComputeRegimePenalty(CompiledPlan &plan, MarketRegimeSnapshot &reg, string &detail)
{
   detail = "";
   double rawPenalty = 0.0;

   if(StringLen(plan.regime_penalty_trend) > 0 && plan.regime_penalty_trend == reg.trend_state)
      rawPenalty += plan.regime_misalignment_penalty * plan.environment_bonus_multiplier;

   if(StringLen(plan.regime_penalty_volatility) > 0 && plan.regime_penalty_volatility == reg.volatility_state)
      rawPenalty += plan.regime_misalignment_penalty * plan.environment_bonus_multiplier;

   if(StringLen(plan.regime_penalty_structure) > 0 && plan.regime_penalty_structure == reg.structure_state)
      rawPenalty += plan.regime_misalignment_penalty * plan.environment_bonus_multiplier;

   double cappedPenalty = RT_ApplyRegimePenaltyCap(plan, rawPenalty);

   detail =
      "RegimePenaltyRaw=" + DoubleToString(rawPenalty, 2) +
      " | RegimePenaltyCapped=" + DoubleToString(cappedPenalty, 2);

   return cappedPenalty;
}

//---------------------------------------------------------
// Score engine
//---------------------------------------------------------
ScoreBreakdown BuildScoreBreakdown(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   CoreDirection dir,
   TriggerResult &mainTrigger,
   ConfirmationSummary &legacyConf,
   FilterSummary &fs,
   MarketRegimeSnapshot &reg
)
{
   ScoreBreakdown sb;
   sb.trigger_score = 0.0;
   sb.confirmation_score = 0.0;
   sb.filter_penalty = 0.0;
   sb.regime_bonus = 0.0;
   sb.regime_penalty = 0.0;
   sb.counter_trend_penalty = 0.0;
   sb.trigger_missing_penalty = 0.0;
   sb.spread_penalty = 0.0;
   sb.final_score = 0.0;
   sb.detail = "";

   //------------------------------------------------------
   // Trigger contribution
   //------------------------------------------------------
   bool anyWeightedTriggerAligned = false;

   if(plan.trigger_weights_count > 0)
   {
      for(int i = 0; i < plan.trigger_weights_count; i++)
      {
         TriggerResult tr = EvaluateIndicatorAsTrigger(plan.trigger_weight_ids[i]);
         if(tr.valid && tr.dir == dir)
         {
            sb.trigger_score += (tr.quality * plan.trigger_weights[i] * plan.trigger_bonus_multiplier);
            anyWeightedTriggerAligned = true;
         }
      }

      if(!anyWeightedTriggerAligned && (plan.require_main_trigger || !plan.allow_triggerless_entry))
         sb.trigger_missing_penalty += plan.trigger_missing_penalty;
   }
   else
   {
      if(mainTrigger.valid && mainTrigger.dir == dir)
         sb.trigger_score += (mainTrigger.quality * plan.trigger_bonus_multiplier);
      else if(plan.require_main_trigger || !plan.allow_triggerless_entry)
         sb.trigger_missing_penalty += plan.trigger_missing_penalty;
   }

   sb.trigger_score = RT_ApplyTriggerCap(plan, sb.trigger_score);

   //------------------------------------------------------
   // Confirmation contribution
   //------------------------------------------------------
   if(plan.confirmation_weights_count > 0)
   {
      string weightedDetail = "";
      sb.confirmation_score += EvaluateWeightedConfirmations(plan, dir, weightedDetail);
   }
   else
   {
      double legacyScore = legacyConf.quality * plan.confirmation_bonus_multiplier;
      sb.confirmation_score += RT_ApplyConfirmationCap(plan, legacyScore);
   }

   sb.confirmation_score = RT_EnforceTriggerDominance(sb.trigger_score, sb.confirmation_score);

   //------------------------------------------------------
   // Filter penalty
   //------------------------------------------------------
   sb.filter_penalty += fs.penalty;

   //------------------------------------------------------
   // Counter trend penalty
   //------------------------------------------------------
   if(RT_IsCounterTrendTrade(dir))
   {
      if(!plan.allow_counter_trend)
         sb.counter_trend_penalty += plan.counter_trend_penalty;
   }

   //------------------------------------------------------
   // Spread penalty
   //------------------------------------------------------
   if(plan.use_soft_filters && plan.use_spread_filter)
   {
      double effectiveMaxSpread = plan.max_spread_points * RT_GetSpreadMultiplier(plan);
      if(effectiveMaxSpread > 0.0 && m1.spread_points > 0.0)
      {
         double spreadRatio = m1.spread_points / effectiveMaxSpread;
         if(spreadRatio > 0.50)
         {
            double extra = (spreadRatio - 0.50) * 0.10 * plan.spread_penalty_multiplier;
            if(extra > 0.0)
               sb.spread_penalty += extra;
         }
      }
   }

   //------------------------------------------------------
   // Regime adjustments
   //------------------------------------------------------
   string regimeDetailA = "";
   string regimeDetailB = "";

   sb.regime_bonus   += RT_ComputeRegimeBonus(plan, reg, regimeDetailA);
   sb.regime_penalty += RT_ComputeRegimePenalty(plan, reg, regimeDetailB);

   //------------------------------------------------------
   // Final score
   //------------------------------------------------------
   sb.final_score =
      sb.trigger_score +
      sb.confirmation_score +
      sb.regime_bonus -
      sb.filter_penalty -
      sb.regime_penalty -
      sb.counter_trend_penalty -
      sb.trigger_missing_penalty -
      sb.spread_penalty;

   if(sb.final_score < 0.0) sb.final_score = 0.0;
   if(sb.final_score > 1.0) sb.final_score = 1.0;

   sb.detail =
      "TrigS=" + DoubleToString(sb.trigger_score, 2) +
      " | ConfS=" + DoubleToString(sb.confirmation_score, 2) +
      " | FiltP=" + DoubleToString(sb.filter_penalty, 2) +
      " | RegB=" + DoubleToString(sb.regime_bonus, 2) +
      " | RegP=" + DoubleToString(sb.regime_penalty, 2) +
      " | CTP=" + DoubleToString(sb.counter_trend_penalty, 2) +
      " | TMP=" + DoubleToString(sb.trigger_missing_penalty, 2) +
      " | SprP=" + DoubleToString(sb.spread_penalty, 2) +
      " | Final=" + DoubleToString(sb.final_score, 2);

   return sb;
}

//---------------------------------------------------------
// Gate engine
//---------------------------------------------------------
bool FinalBuyPermission(CompiledPlan &plan, double quality, ConfirmationSummary &cs)
{
   double qualityThreshold      = RT_AdjustQualityThresholdByMode(plan);
   double confirmationThreshold = RT_AdjustConfirmationThresholdByMode(plan);

   if(cs.quality < confirmationThreshold)
      return false;

   if(quality >= qualityThreshold)
      return true;

   if(quality >= (qualityThreshold - 0.05) &&
      cs.strong_aligned >= 1 &&
      cs.medium_aligned >= 1)
      return true;

   return false;
}

bool FinalSellPermission(CompiledPlan &plan, double quality, ConfirmationSummary &cs)
{
   double qualityThreshold      = RT_AdjustQualityThresholdByMode(plan);
   double confirmationThreshold = RT_AdjustConfirmationThresholdByMode(plan);

   if(cs.quality < confirmationThreshold)
      return false;

   if(quality >= qualityThreshold)
      return true;

   if(quality >= (qualityThreshold - 0.05) &&
      cs.strong_aligned >= 1 &&
      cs.medium_aligned >= 1)
      return true;

   return false;
}

double ComputeLegacyFinalSignalQuality(TriggerResult &tr, ConfirmationSummary &cs, FilterSummary &fs)
{
   if(!tr.valid || fs.hard_blocked)
      return 0.0;

   double q = (tr.quality * 0.60) + (cs.quality * 0.40);

   if(tr.dir == CORE_BUY && RT_M5TrendBull())
      q += 0.05;

   if(tr.dir == CORE_SELL && RT_M5TrendBear())
      q += 0.05;

   if(q > 1.0) q = 1.0;
   if(q < 0.0) q = 0.0;

   return q;
}

//---------------------------------------------------------
// Decision helpers
//---------------------------------------------------------
void EvaluateByGateMode(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   TriggerResult tr = DetectMainTrigger(plan);
   if(!tr.valid || tr.dir == CORE_NONE)
   {
      eval.decision = RUNTIME_WAIT;
      eval.reason   = "Main trigger inactive | " + tr.reason;
      return;
   }

   if(!RT_DirectionAllowedByBias(plan, tr.dir))
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = "Direction blocked by bias policy";
      return;
   }

   MarketRegimeSnapshot reg;
   BuildMarketRegimeSnapshot(m1, m5, reg);

   string regimeReason = "";
   if(!RT_RegimeTrendAllowed(plan, reg, regimeReason) ||
      !RT_RegimeVolatilityAllowed(plan, reg, regimeReason) ||
      !RT_RegimeStructureAllowed(plan, reg, regimeReason))
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = "Regime blocked | " + regimeReason + " | " + reg.summary;
      return;
   }

   if(!plan.allow_counter_trend && RT_IsCounterTrendTrade(tr.dir))
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = "Counter-trend trades disabled";
      return;
   }

   ConfirmationSummary cs = EvaluateConfirmations(plan, tr.dir);
   FilterSummary fs       = EvaluateFilters(plan, m1, m5, tr.dir);

   if(fs.hard_blocked || !fs.passed)
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = fs.reason;
      return;
   }

   double finalQuality = ComputeLegacyFinalSignalQuality(tr, cs, fs);

   string detail =
      "Mode=GATE" +
      " | Trigger=" + tr.reason +
      " | TriggerQ=" + DoubleToString(tr.quality, 2) +
      " | ConfirmQ=" + DoubleToString(cs.quality, 2) +
      " | FinalQ=" + DoubleToString(finalQuality, 2) +
      " | Regime=" + reg.summary +
      " | " + cs.detail;

   if(tr.dir == CORE_BUY)
   {
      if(FinalBuyPermission(plan, finalQuality, cs))
      {
         eval.decision = RUNTIME_ENTER_BUY;
         eval.reason = detail;
         return;
      }

      eval.decision = RUNTIME_WAIT;
      eval.reason = "BUY gate quality insufficient | " + detail;
      return;
   }

   if(tr.dir == CORE_SELL)
   {
      if(FinalSellPermission(plan, finalQuality, cs))
      {
         eval.decision = RUNTIME_ENTER_SELL;
         eval.reason = detail;
         return;
      }

      eval.decision = RUNTIME_WAIT;
      eval.reason = "SELL gate quality insufficient | " + detail;
      return;
   }

   eval.decision = RUNTIME_WAIT;
   eval.reason = "No valid gate direction";
}

void EvaluateByScoreMode(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   MarketRegimeSnapshot reg;
   BuildMarketRegimeSnapshot(m1, m5, reg);

   string regimeReason = "";
   if(!RT_RegimeTrendAllowed(plan, reg, regimeReason) ||
      !RT_RegimeVolatilityAllowed(plan, reg, regimeReason) ||
      !RT_RegimeStructureAllowed(plan, reg, regimeReason))
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = "Regime blocked | " + regimeReason + " | " + reg.summary;
      return;
   }

   TriggerResult trBuy  = DetectMainTrigger(plan);
   TriggerResult trSell = trBuy;

   ConfirmationSummary csBuy = EvaluateConfirmations(plan, CORE_BUY);
   ConfirmationSummary csSell = EvaluateConfirmations(plan, CORE_SELL);

   FilterSummary fsBuy = EvaluateFilters(plan, m1, m5, CORE_BUY);
   FilterSummary fsSell = EvaluateFilters(plan, m1, m5, CORE_SELL);

   ScoreBreakdown sbBuy = BuildScoreBreakdown(plan, m1, m5, CORE_BUY, trBuy, csBuy, fsBuy, reg);
   ScoreBreakdown sbSell = BuildScoreBreakdown(plan, m1, m5, CORE_SELL, trSell, csSell, fsSell, reg);

   double threshold = RT_AdjustScoreEntryThresholdByMode(plan);

   bool buyAllowedBias  = RT_DirectionAllowedByBias(plan, CORE_BUY);
   bool sellAllowedBias = RT_DirectionAllowedByBias(plan, CORE_SELL);

   if(plan.require_main_trigger)
   {
      if(!RT_MainTriggerValidForDirection(trBuy, CORE_BUY))
         sbBuy.final_score = 0.0;

      if(!RT_MainTriggerValidForDirection(trSell, CORE_SELL))
         sbSell.final_score = 0.0;
   }

   if(!buyAllowedBias)
      sbBuy.final_score = 0.0;
   if(!sellAllowedBias)
      sbSell.final_score = 0.0;

   if(plan.use_hard_blocks && fsBuy.hard_blocked)
      sbBuy.final_score = 0.0;
   if(plan.use_hard_blocks && fsSell.hard_blocked)
      sbSell.final_score = 0.0;

   if(!plan.allow_counter_trend && RT_IsCounterTrendTrade(CORE_BUY))
      sbBuy.final_score -= plan.counter_trend_penalty;
   if(!plan.allow_counter_trend && RT_IsCounterTrendTrade(CORE_SELL))
      sbSell.final_score -= plan.counter_trend_penalty;

   if(sbBuy.final_score < 0.0) sbBuy.final_score = 0.0;
   if(sbSell.final_score < 0.0) sbSell.final_score = 0.0;

   string detail =
      "Mode=SCORE" +
      " | BUY[" + sbBuy.detail + "]" +
      " | SELL[" + sbSell.detail + "]" +
      " | Regime=" + reg.summary;

   if(sbBuy.final_score >= threshold || sbSell.final_score >= threshold)
   {
      if(sbBuy.final_score > sbSell.final_score)
      {
         eval.decision = RUNTIME_ENTER_BUY;
         eval.reason = detail;
         return;
      }

      if(sbSell.final_score > sbBuy.final_score)
      {
         eval.decision = RUNTIME_ENTER_SELL;
         eval.reason = detail;
         return;
      }
   }

   if(sbBuy.final_score <= plan.score_reject_threshold &&
      sbSell.final_score <= plan.score_reject_threshold)
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason = "Score reject zone | " + detail;
      return;
   }

   eval.decision = RUNTIME_WAIT;
   eval.reason = "Score below entry threshold | " + detail;
}

void EvaluateByHybridMode(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   RuntimeEvaluation gateEval;
   gateEval.decision = RUNTIME_WAIT;
   gateEval.reason = "";

   EvaluateByGateMode(plan, m1, m5, gateEval);

   if(gateEval.decision == RUNTIME_ENTER_BUY || gateEval.decision == RUNTIME_ENTER_SELL)
   {
      eval = gateEval;
      eval.reason = "HYBRID-GATE PASS | " + gateEval.reason;
      return;
   }

   RuntimeEvaluation scoreEval;
   scoreEval.decision = RUNTIME_WAIT;
   scoreEval.reason = "";

   EvaluateByScoreMode(plan, m1, m5, scoreEval);

   if(scoreEval.decision == RUNTIME_ENTER_BUY || scoreEval.decision == RUNTIME_ENTER_SELL)
   {
      eval = scoreEval;
      eval.reason = "HYBRID-SCORE PASS | " + scoreEval.reason;
      return;
   }

   if(gateEval.decision == RUNTIME_REJECT && scoreEval.decision == RUNTIME_REJECT)
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = "HYBRID reject | gate=" + gateEval.reason + " | score=" + scoreEval.reason;
      return;
   }

   eval.decision = RUNTIME_WAIT;
   eval.reason   = "HYBRID wait | gate=" + gateEval.reason + " | score=" + scoreEval.reason;
}

//---------------------------------------------------------
// Main runtime evaluator
//---------------------------------------------------------
void EvaluateCompiledPlan(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RuntimeEvaluation &eval
)
{
   eval.decision = RUNTIME_WAIT;
   eval.reason   = "No runtime trigger";

   if(!plan.enabled)
   {
      eval.decision = RUNTIME_REJECT;
      eval.reason   = "Plan disabled";
      return;
   }

   if(plan.decision_engine_mode == "GATE")
   {
      EvaluateByGateMode(plan, m1, m5, eval);
      return;
   }

   if(plan.decision_engine_mode == "SCORE")
   {
      EvaluateByScoreMode(plan, m1, m5, eval);
      return;
   }

   EvaluateByHybridMode(plan, m1, m5, eval);
}

#endif // STRATEGY_RUNTIME_DISABLE_ZONE2

#endif // __STRATEGY_RUNTIME_MQH__