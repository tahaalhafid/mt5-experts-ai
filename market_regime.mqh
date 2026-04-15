#ifndef __MARKET_REGIME_MQH__
#define __MARKET_REGIME_MQH__

#include "core_market_data.mqh"

struct MarketRegimeSnapshot
{
   string trend_state;      // TREND_BULL / TREND_BEAR / RANGE
   string volatility_state; // HIGH_VOL / NORMAL_VOL / LOW_VOL
   string spread_state;     // TIGHT_SPREAD / NORMAL_SPREAD / WIDE_SPREAD
   string structure_state;  // CLEAN / NOISY
   string summary;
};

bool MR_CopyOne(int handle, int bufferIndex, int shift, double &outVal)
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

bool MR_GetEMA(ENUM_TIMEFRAMES tf, int period, int shift, double &ema)
{
   ema = 0.0;
   int h = iMA(_Symbol, tf, period, 0, MODE_EMA, PRICE_CLOSE);
   if(h == INVALID_HANDLE)
      return false;

   bool ok = MR_CopyOne(h, 0, shift, ema);
   IndicatorRelease(h);
   return ok;
}

bool MR_GetATR(ENUM_TIMEFRAMES tf, int period, int shift, double &atr)
{
   atr = 0.0;
   int h = iATR(_Symbol, tf, period);
   if(h == INVALID_HANDLE)
      return false;

   bool ok = MR_CopyOne(h, 0, shift, atr);
   IndicatorRelease(h);
   return ok;
}

double MR_BodySize(ENUM_TIMEFRAMES tf, int shift)
{
   return MathAbs(iClose(_Symbol, tf, shift) - iOpen(_Symbol, tf, shift));
}

double MR_RangeSize(ENUM_TIMEFRAMES tf, int shift)
{
   return iHigh(_Symbol, tf, shift) - iLow(_Symbol, tf, shift);
}

double MR_ComputeAverageEfficiency(ENUM_TIMEFRAMES tf, int startShift, int barsCount)
{
   if(barsCount <= 0)
      return 0.0;

   double totalBody  = 0.0;
   double totalRange = 0.0;

   for(int i = 0; i < barsCount; i++)
   {
      int shift = startShift + i;
      totalBody  += MR_BodySize(tf, shift);
      totalRange += MR_RangeSize(tf, shift);
   }

   double avgBody  = totalBody / barsCount;
   double avgRange = totalRange / barsCount;

   if(avgRange <= 0.0)
      return 0.0;

   return (avgBody / avgRange);
}

string DetectTrendState()
{
   double ema20m1=0.0, ema50m1=0.0, ema20m5=0.0, ema50m5=0.0;

   if(!MR_GetEMA(PERIOD_M1, 20, 1, ema20m1)) return "UNKNOWN_TREND";
   if(!MR_GetEMA(PERIOD_M1, 50, 1, ema50m1)) return "UNKNOWN_TREND";
   if(!MR_GetEMA(PERIOD_M5, 20, 1, ema20m5)) return "UNKNOWN_TREND";
   if(!MR_GetEMA(PERIOD_M5, 50, 1, ema50m5)) return "UNKNOWN_TREND";

   double closeM1 = iClose(_Symbol, PERIOD_M1, 1);
   double closeM5 = iClose(_Symbol, PERIOD_M5, 1);

   bool bull = (ema20m1 > ema50m1 && ema20m5 > ema50m5 && closeM1 >= ema20m1 && closeM5 >= ema20m5);
   bool bear = (ema20m1 < ema50m1 && ema20m5 < ema50m5 && closeM1 <= ema20m1 && closeM5 <= ema20m5);

   if(bull) return "TREND_BULL";
   if(bear) return "TREND_BEAR";
   return "RANGE";
}

string DetectVolatilityState()
{
   double atrM1=0.0, atrM5=0.0;
   if(!MR_GetATR(PERIOD_M1, 14, 1, atrM1)) return "UNKNOWN_VOL";
   if(!MR_GetATR(PERIOD_M5, 14, 1, atrM5)) return "UNKNOWN_VOL";

   double ptsM1 = atrM1 / _Point;
   double ptsM5 = atrM5 / _Point;

   double mixed = (ptsM1 * 0.6) + (ptsM5 * 0.4);

   if(mixed >= 250.0) return "HIGH_VOL";
   if(mixed <= 80.0)  return "LOW_VOL";
   return "NORMAL_VOL";
}

string DetectSpreadState(double spreadPoints)
{
   if(spreadPoints <= 80.0)  return "TIGHT_SPREAD";
   if(spreadPoints >= 250.0) return "WIDE_SPREAD";
   return "NORMAL_SPREAD";
}

string DetectStructureState()
{
   //------------------------------------------------------
   // Use a smoother blend:
   // - M1 recent micro-structure
   // - M5 broader candle cleanliness
   //------------------------------------------------------
   double effM1 = MR_ComputeAverageEfficiency(PERIOD_M1, 1, 5);
   double effM5 = MR_ComputeAverageEfficiency(PERIOD_M5, 1, 2);

   if(effM1 <= 0.0 && effM5 <= 0.0)
      return "UNKNOWN_STRUCTURE";

   double blendedEfficiency = (effM1 * 0.70) + (effM5 * 0.30);

   //------------------------------------------------------
   // More tolerant threshold than old 0.45 on only 3 M1 bars
   //------------------------------------------------------
   if(blendedEfficiency >= 0.38)
      return "CLEAN";

   return "NOISY";
}

bool BuildMarketRegimeSnapshot(TimeframeSnapshot &m1, TimeframeSnapshot &m5, MarketRegimeSnapshot &reg)
{
   reg.trend_state      = DetectTrendState();
   reg.volatility_state = DetectVolatilityState();
   reg.spread_state     = DetectSpreadState(m1.spread_points);
   reg.structure_state  = DetectStructureState();

   reg.summary =
      reg.trend_state + "|" +
      reg.volatility_state + "|" +
      reg.spread_state + "|" +
      reg.structure_state;

   return true;
}

string MarketRegimeToJson(MarketRegimeSnapshot &reg)
{
   string json = "{";
   json += "\"trend_state\":\"" + reg.trend_state + "\",";
   json += "\"volatility_state\":\"" + reg.volatility_state + "\",";
   json += "\"spread_state\":\"" + reg.spread_state + "\",";
   json += "\"structure_state\":\"" + reg.structure_state + "\",";
   json += "\"summary\":\"" + reg.summary + "\"";
   json += "}";
   return json;
}

#endif
