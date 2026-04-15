#ifndef __REGIME_CLASSIFICATION_LAYER_V1_MQH__
#define __REGIME_CLASSIFICATION_LAYER_V1_MQH__

#include "core_market_data.mqh"
#include "market_regime.mqh"

//---------------------------------------------------------
// Regime Classification Layer v1 (rule-based, reusable)
//---------------------------------------------------------
enum RegimeLabel
{
   REGIME_TREND_UP = 0,
   REGIME_TREND_DOWN,
   REGIME_RANGE_BALANCED,
   REGIME_RANGE_DIRTY,
   REGIME_EXPANSION,
   REGIME_COMPRESSION,
   REGIME_REVERSAL_RISK,
   REGIME_NO_TRADE
};

struct RegimeClassification
{
   string regime_label;        // TREND_UP / TREND_DOWN / ...
   double regime_confidence;   // 0..1
   double trend_bias;          // -1..+1
   double tradability_score;   // 0..1
   string volatility_state;    // HIGH_VOL / NORMAL_VOL / LOW_VOL / UNKNOWN_VOL
   string structure_state;     // CLEAN / NOISY / UNKNOWN_STRUCTURE
   string summary_reason;      // short debug summary
};

double RC_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}

double RC_Clamp01(double v) { return RC_Clamp(v, 0.0, 1.0); }

double RC_SafeDiv(double a, double b)
{
   if(MathAbs(b) < 1e-12) return 0.0;
   return a / b;
}

string RC_RegimeLabelToText(RegimeLabel r)
{
   if(r == REGIME_TREND_UP)        return "TREND_UP";
   if(r == REGIME_TREND_DOWN)      return "TREND_DOWN";
   if(r == REGIME_RANGE_BALANCED)  return "RANGE_BALANCED";
   if(r == REGIME_RANGE_DIRTY)     return "RANGE_DIRTY";
   if(r == REGIME_EXPANSION)       return "EXPANSION";
   if(r == REGIME_COMPRESSION)     return "COMPRESSION";
   if(r == REGIME_REVERSAL_RISK)   return "REVERSAL_RISK";
   return "NO_TRADE";
}

int RC_Sign(double v)
{
   if(v > 0.0) return 1;
   if(v < 0.0) return -1;
   return 0;
}

double RC_CandleEfficiency(CandleData &c)
{
   double r = c.high - c.low;
   if(r <= 0.0) return 0.0;
   return MathAbs(c.close - c.open) / r;
}

double RC_WickImbalance(CandleData &c)
{
   double upper = c.high - MathMax(c.open, c.close);
   double lower = MathMin(c.open, c.close) - c.low;
   double r = c.high - c.low;
   if(r <= 0.0) return 0.0;
   return (upper - lower) / r; // + => upper dominates, - => lower dominates
}

double RC_ComputeChurnM1(int barsLookback)
{
   int changes = 0;
   int lastSign = 0;

   for(int i = 1; i <= barsLookback; i++)
   {
      double o = iOpen(_Symbol, PERIOD_M1, i);
      double c = iClose(_Symbol, PERIOD_M1, i);
      int s = RC_Sign(c - o);

      if(s == 0) continue;
      if(lastSign != 0 && s != lastSign) changes++;
      lastSign = s;
   }

   return RC_Clamp01((double)changes / (double)MathMax(1, barsLookback - 1));
}

bool BuildRegimeClassificationV1(TimeframeSnapshot &m1, TimeframeSnapshot &m5, RegimeClassification &out)
{
   out.regime_label      = "NO_TRADE";
   out.regime_confidence = 0.0;
   out.trend_bias        = 0.0;
   out.tradability_score = 0.0;
   out.volatility_state  = "UNKNOWN_VOL";
   out.structure_state   = "UNKNOWN_STRUCTURE";
   out.summary_reason    = "init";

   double ema20m1=0.0, ema50m1=0.0, ema20m5=0.0, ema50m5=0.0;
   double atr14m1=0.0, atr100m1=0.0, atr14m5=0.0;

   bool emaOk =
      MR_GetEMA(PERIOD_M1, 20, 1, ema20m1) &&
      MR_GetEMA(PERIOD_M1, 50, 1, ema50m1) &&
      MR_GetEMA(PERIOD_M5, 20, 1, ema20m5) &&
      MR_GetEMA(PERIOD_M5, 50, 1, ema50m5);

   bool atrOk =
      MR_GetATR(PERIOD_M1, 14, 1, atr14m1) &&
      MR_GetATR(PERIOD_M1, 100, 1, atr100m1) &&
      MR_GetATR(PERIOD_M5, 14, 1, atr14m5);

   out.structure_state  = DetectStructureState();
   out.volatility_state = DetectVolatilityState();

   if(!emaOk || !atrOk)
   {
      out.regime_label      = "NO_TRADE";
      out.regime_confidence = 0.25;
      out.tradability_score = 0.10;
      out.summary_reason    = "indicators_unavailable";
      return true;
   }

   double atrPts = atr14m5 / _Point;
   if(atrPts <= 0.0) atrPts = 1.0;

   double diffM5 = (ema20m5 - ema50m5) / _Point;
   double diffM1 = (ema20m1 - ema50m1) / _Point;

   int signM5 = RC_Sign(diffM5);
   int signM1 = RC_Sign(diffM1);

   bool aligned = (signM5 != 0 && signM1 != 0 && signM5 == signM1);

   double biasRaw = RC_SafeDiv(diffM5, (atrPts * 0.55));
   out.trend_bias = RC_Clamp(biasRaw, -1.0, 1.0);

   double effM1 = MR_ComputeAverageEfficiency(PERIOD_M1, 1, 5);
   double effM5 = MR_ComputeAverageEfficiency(PERIOD_M5, 1, 2);
   double effBlend = (effM1 * 0.70) + (effM5 * 0.30);

   double churn = RC_ComputeChurnM1(7);

   double atrRatio = RC_SafeDiv(atr14m1, atr100m1);
   bool compression = (atrRatio > 0.0 && atrRatio <= 0.72);
   bool expansion   = (atrRatio >= 1.35);

   double trad = 0.55;

   if(out.structure_state == "CLEAN") trad += 0.15;
   if(out.structure_state == "NOISY") trad -= 0.15;

   if(out.volatility_state == "NORMAL_VOL") trad += 0.10;
   if(out.volatility_state == "HIGH_VOL")   trad -= 0.12;
   if(out.volatility_state == "LOW_VOL")    trad -= 0.05;

   if(m1.spread_points >= 2500.0) trad -= 0.25;
   else if(m1.spread_points >= 1500.0) trad -= 0.15;

   trad -= churn * 0.20;
   trad += RC_Clamp((effBlend - 0.30) * 0.35, -0.10, 0.15);

   out.tradability_score = RC_Clamp01(trad);

   double lastEff = RC_CandleEfficiency(m1.bar1);
   double wickImb = RC_WickImbalance(m1.bar1);

   bool strongTrend = (MathAbs(out.trend_bias) >= 0.55 && aligned);
   bool trendWeak   = (MathAbs(out.trend_bias) <= 0.25 || !aligned);

   bool oppClose =
      (out.trend_bias > 0.0 && m1.bar1.close < m1.bar1.open) ||
      (out.trend_bias < 0.0 && m1.bar1.close > m1.bar1.open);

   bool wickAgainst =
      (out.trend_bias > 0.0 && wickImb > 0.18) ||
      (out.trend_bias < 0.0 && wickImb < -0.18);

   bool reversalRisk = (strongTrend && (oppClose || wickAgainst) && lastEff <= 0.30);

   RegimeLabel label = REGIME_RANGE_BALANCED;
   double conf = 0.55;
   string why = "";

   if(out.tradability_score <= 0.18)
   {
      label = REGIME_NO_TRADE;
      conf  = 0.70;
      why   = "low_tradability";
   }
   else if(reversalRisk)
   {
      label = REGIME_REVERSAL_RISK;
      conf  = 0.68;
      why   = "trend_reversal_risk";
      out.tradability_score = RC_Clamp01(out.tradability_score - 0.12);
   }
   else if(compression)
   {
      label = REGIME_COMPRESSION;
      conf  = 0.62;
      why   = "atr_compression";
   }
   else if(expansion)
   {
      label = REGIME_EXPANSION;
      conf  = 0.62;
      why   = "atr_expansion";
   }
   else if(!trendWeak && aligned && effBlend >= 0.36)
   {
      if(out.trend_bias >= 0.0)
      {
         label = REGIME_TREND_UP;
         why   = "aligned_trend_up";
      }
      else
      {
         label = REGIME_TREND_DOWN;
         why   = "aligned_trend_down";
      }

      conf = 0.60 + RC_Clamp(MathAbs(out.trend_bias) * 0.30, 0.0, 0.25);
      conf = RC_Clamp01(conf);
   }
   else
   {
      bool dirty = (out.structure_state == "NOISY") || (churn >= 0.45) || (effBlend <= 0.30);

      if(dirty)
      {
         label = REGIME_RANGE_DIRTY;
         conf  = 0.58;
         why   = "range_dirty";
      }
      else
      {
         label = REGIME_RANGE_BALANCED;
         conf  = 0.58;
         why   = "range_balanced";
      }
   }

   out.regime_label      = RC_RegimeLabelToText(label);
   out.regime_confidence = RC_Clamp01(conf);

   out.summary_reason =
      "label=" + out.regime_label +
      "|conf=" + DoubleToString(out.regime_confidence, 2) +
      "|bias=" + DoubleToString(out.trend_bias, 2) +
      "|trad=" + DoubleToString(out.tradability_score, 2) +
      "|vol=" + out.volatility_state +
      "|struct=" + out.structure_state +
      "|why=" + why;

   return true;
}

string RegimeClassificationToJson(RegimeClassification &r)
{
   string json = "{";
   json += "\"regime_label\":\"" + r.regime_label + "\",";
   json += "\"regime_confidence\":" + DoubleToString(r.regime_confidence, 3) + ",";
   json += "\"trend_bias\":" + DoubleToString(r.trend_bias, 3) + ",";
   json += "\"tradability_score\":" + DoubleToString(r.tradability_score, 3) + ",";
   json += "\"volatility_state\":\"" + r.volatility_state + "\",";
   json += "\"structure_state\":\"" + r.structure_state + "\",";
   json += "\"summary_reason\":\"" + r.summary_reason + "\"";
   json += "}";
   return json;
}

bool RegimeCsvAllows(string allowedCsv, string label)
{
   StringTrimLeft(allowedCsv);
   StringTrimRight(allowedCsv);
   if(StringLen(allowedCsv) <= 0) return true;

   string csv = allowedCsv;
   StringReplace(csv, " ", "");

   string needle = "," + label + ",";
   string hay = "," + csv + ",";
   return (StringFind(hay, needle) >= 0);
}

#endif
