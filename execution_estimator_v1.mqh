#ifndef __EXECUTION_ESTIMATOR_V1_MQH__
#define __EXECUTION_ESTIMATOR_V1_MQH__

#include "core_market_data.mqh"
#include "market_regime.mqh"
#include "regime_classification_layer_v1.mqh"
#include "strategy_runtime.mqh"

//---------------------------------------------------------
// Execution Estimator v1 (rule-based, conservative)
// Purpose: estimate execution geometry BEFORE placing any order.
// No side effects. No dependence on actual SL/TP calculation.
//---------------------------------------------------------
enum ExecutionGeometryLabel
{
   EXEC_GEOM_STRONG = 0,
   EXEC_GEOM_ACCEPTABLE,
   EXEC_GEOM_THIN,
   EXEC_GEOM_POOR,
   EXEC_GEOM_ADVERSE
};

struct ExecutionEstimationResult
{
   // Distances are in points (not price).
   double expected_stop_distance;
   double expected_target_distance;
   double expected_rr_estimate;

   double adverse_excursion_risk_score;         // 0..1 (higher = worse)
   double favorable_excursion_potential_score;  // 0..1

   double execution_geometry_score;             // 0..1
   string execution_geometry_label;
   string execution_geometry_reason;

   bool valid;
};

double EE_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}

double EE_Clamp01(double v) { return EE_Clamp(v, 0.0, 1.0); }

double EE_SafeDiv(double a, double b)
{
   if(MathAbs(b) < 1e-12) return 0.0;
   return a / b;
}

string EE_LabelText(ExecutionGeometryLabel l)
{
   if(l == EXEC_GEOM_STRONG)     return "STRONG_EXECUTION_GEOMETRY";
   if(l == EXEC_GEOM_ACCEPTABLE) return "ACCEPTABLE_EXECUTION_GEOMETRY";
   if(l == EXEC_GEOM_THIN)       return "THIN_EXECUTION_GEOMETRY";
   if(l == EXEC_GEOM_POOR)       return "POOR_EXECUTION_GEOMETRY";
   return "ADVERSE_EXECUTION_GEOMETRY";
}

double EE_RecentHigh(ENUM_TIMEFRAMES tf, int shiftFrom, int lookback)
{
   double h = -DBL_MAX;
   for(int i = shiftFrom; i < shiftFrom + lookback; i++)
      h = MathMax(h, iHigh(_Symbol, tf, i));
   return h;
}

double EE_RecentLow(ENUM_TIMEFRAMES tf, int shiftFrom, int lookback)
{
   double l = DBL_MAX;
   for(int i = shiftFrom; i < shiftFrom + lookback; i++)
      l = MathMin(l, iLow(_Symbol, tf, i));
   return l;
}

bool ComputeExecutionEstimationV1(TimeframeSnapshot &m1, TimeframeSnapshot &m5, RegimeClassification &reg, CoreDirection dir, ExecutionEstimationResult &out)
{
   out.expected_stop_distance = 0.0;
   out.expected_target_distance = 0.0;
   out.expected_rr_estimate = 0.0;
   out.adverse_excursion_risk_score = 0.5;
   out.favorable_excursion_potential_score = 0.5;
   out.execution_geometry_score = 0.5;
   out.execution_geometry_label = "ACCEPTABLE_EXECUTION_GEOMETRY";
   out.execution_geometry_reason = "init";
   out.valid = false;

   if(dir != CORE_BUY && dir != CORE_SELL)
   {
      out.execution_geometry_label = "POOR_EXECUTION_GEOMETRY";
      out.execution_geometry_reason = "no_direction";
      return true;
   }

   double atr14m5 = 0.0;
   if(!MR_GetATR(PERIOD_M5, 14, 1, atr14m5) || atr14m5 <= 0.0)
   {
      out.execution_geometry_label = "POOR_EXECUTION_GEOMETRY";
      out.execution_geometry_reason = "atr_unavailable";
      return true;
   }

   const double atrPts = MathMax(atr14m5 / _Point, 1.0);
   const double price = (dir == CORE_BUY ? m1.ask : m1.bid);

   const double m1Hi = EE_RecentHigh(PERIOD_M1, 1, 12);
   const double m1Lo = EE_RecentLow(PERIOD_M1, 1, 12);
   const double m5Hi = EE_RecentHigh(PERIOD_M5, 1, 24);
   const double m5Lo = EE_RecentLow(PERIOD_M5, 1, 24);

   const double adverseSwing = (dir == CORE_BUY ? MathMin(m1Lo, m5Lo) : MathMax(m1Hi, m5Hi));
   const double favorableSwing = (dir == CORE_BUY ? MathMax(m1Hi, m5Hi) : MathMin(m1Lo, m5Lo));

   double distToAdversePts = MathAbs(price - adverseSwing) / _Point;
   double distToFavorablePts = MathAbs(favorableSwing - price) / _Point;

   // Baselines: conservative, ATR-driven
   double stopBase = atrPts * 0.95;
   double targetBase = atrPts * 1.35;

   // Use structure if it is closer than baseline (avoid unrealistic optimism).
   double stopEst = MathMax(stopBase, distToAdversePts * 0.85);
   double targetEst = MathMax(targetBase, distToFavorablePts * 0.75);

   // Regime adjustments (conservative)
   if(reg.volatility_state == "HIGH_VOL")  stopEst *= 1.15;
   if(reg.volatility_state == "LOW_VOL")   targetEst *= 0.92;

   if(reg.regime_label == "COMPRESSION")   targetEst *= 0.85;
   if(reg.regime_label == "EXPANSION")     stopEst *= 1.10;
   if(reg.regime_label == "RANGE_DIRTY")   targetEst *= 0.88;
   if(reg.regime_label == "NO_TRADE")      { stopEst *= 1.20; targetEst *= 0.75; }

   // Avoid nonsense
   stopEst = EE_Clamp(stopEst, atrPts * 0.60, atrPts * 2.20);
   targetEst = EE_Clamp(targetEst, atrPts * 0.70, atrPts * 3.50);

   double rr = EE_SafeDiv(targetEst, stopEst);
   rr = EE_Clamp(rr, 0.10, 5.0);

   // Risk: higher when stop is "too tight" vs ATR and when structure/noise is bad.
   double stopStress = EE_Clamp01(EE_SafeDiv(atrPts, stopEst)); // >1 => tight
   double noisePenalty = 0.0;
   if(reg.structure_state == "NOISY") noisePenalty += 0.15;
   if(reg.regime_label == "RANGE_DIRTY") noisePenalty += 0.15;
   if(reg.regime_label == "REVERSAL_RISK") noisePenalty += 0.10;

   double adverseRisk = EE_Clamp01((stopStress - 0.75) * 0.90 + noisePenalty);

   // Potential: higher when target has space vs ATR and tradability is decent.
   double targetSpace = EE_Clamp01(EE_SafeDiv(targetEst, atrPts) / 2.0); // 0..~1
   double trad = EE_Clamp01(reg.tradability_score);
   double potential = EE_Clamp01((targetSpace * 0.70) + (trad * 0.30));

   // Execution geometry score: combine RR, potential, and inverse risk.
   double rrScore = EE_Clamp01((rr - 0.8) / 1.4); // rr 0.8..2.2 -> 0..1
   double score = (rrScore * 0.42) + (potential * 0.33) + ((1.0 - adverseRisk) * 0.25);

   // Penalize very low RR hard
   if(rr < 0.65) score -= 0.18;
   if(reg.regime_label == "NO_TRADE") score -= 0.25;

   score = EE_Clamp01(score);

   ExecutionGeometryLabel lab = EXEC_GEOM_ACCEPTABLE;
   if(score >= 0.72) lab = EXEC_GEOM_STRONG;
   else if(score >= 0.50) lab = EXEC_GEOM_ACCEPTABLE;
   else if(score >= 0.35) lab = EXEC_GEOM_THIN;
   else if(score >= 0.20) lab = EXEC_GEOM_POOR;
   else lab = EXEC_GEOM_ADVERSE;

   out.expected_stop_distance = stopEst;
   out.expected_target_distance = targetEst;
   out.expected_rr_estimate = rr;
   out.adverse_excursion_risk_score = adverseRisk;
   out.favorable_excursion_potential_score = potential;
   out.execution_geometry_score = score;
   out.execution_geometry_label = EE_LabelText(lab);

   out.execution_geometry_reason =
      "stopPts=" + DoubleToString(stopEst, 0) +
      "|targetPts=" + DoubleToString(targetEst, 0) +
      "|rr=" + DoubleToString(rr, 2) +
      "|risk=" + DoubleToString(adverseRisk, 2) +
      "|pot=" + DoubleToString(potential, 2) +
      "|score=" + DoubleToString(score, 2) +
      "|reg=" + reg.regime_label;

   out.valid = true;
   return true;
}

#endif
