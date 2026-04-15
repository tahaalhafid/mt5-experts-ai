#ifndef __CORE_MARKET_DATA_MQH__
#define __CORE_MARKET_DATA_MQH__

struct CandleData
{
   double open;
   double high;
   double low;
   double close;
};

struct TimeframeSnapshot
{
   ENUM_TIMEFRAMES tf;
   CandleData bar1;
   CandleData bar2;
   CandleData bar3;
   double bid;
   double ask;
   double spread_points;
};

bool LoadCandle(ENUM_TIMEFRAMES tf, int shift, CandleData &candle)
{
   candle.open  = iOpen(_Symbol, tf, shift);
   candle.high  = iHigh(_Symbol, tf, shift);
   candle.low   = iLow(_Symbol, tf, shift);
   candle.close = iClose(_Symbol, tf, shift);

   if(candle.open <= 0 || candle.high <= 0 || candle.low <= 0 || candle.close <= 0)
      return false;

   return true;
}

bool BuildTimeframeSnapshot(ENUM_TIMEFRAMES tf, TimeframeSnapshot &snap)
{
   snap.tf = tf;
   snap.bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   snap.ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   snap.spread_points = (snap.ask - snap.bid) / _Point;

   if(!LoadCandle(tf, 1, snap.bar1)) return false;
   if(!LoadCandle(tf, 2, snap.bar2)) return false;
   if(!LoadCandle(tf, 3, snap.bar3)) return false;

   return true;
}

#endif
