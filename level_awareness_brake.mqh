#ifndef __LEVEL_AWARENESS_BRAKE_MQH__
#define __LEVEL_AWARENESS_BRAKE_MQH__

/*
   Level Awareness v2 — Environmental Brake Mode
   Passive late-stage execution brake. Never touches council scoring or votes.
*/

#include "council_mode_types.mqh"

enum LevelBrakeVerdict
{
   LEVEL_BRAKE_ALLOW = 0,
   LEVEL_BRAKE_HARD_REJECT = 1
};

struct LevelAwarenessBrakeReport
{
   string direction_under_review;   // BUY / SELL
   string zone_semantic;

   string strategy_family;
   string strategy_id;

   double nearest_support_price;
   double nearest_resistance_price;

   int    nearest_support_distance_points;
   int    nearest_resistance_distance_points;

   double breakout_room_score;            // 0..1
   double rejection_risk_score;           // 0..1
   double continuation_obstacle_risk;     // 0..1
   double reversal_trap_risk;             // 0..1

   string location_context_summary;

   string brake_verdict;                  // ALLOW / HARD_REJECT
   string brake_reason;
   string brake_reason_code;
};

double LAB_Clamp01(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string LAB_InferFamilyFromStrategyId(string strategy_id)
{
   // Range core + prior
   if(strategy_id == "sweep_reversal") return "LIQUIDITY_REVERSAL";
   if(strategy_id == "bollinger_reclaim") return "MEAN_RECLAIM";
   if(strategy_id == "mean_reversion_bounce") return "MEAN_RECLAIM";
   if(strategy_id == "range_edge_fade") return "MEAN_RECLAIM";
   if(strategy_id == "fake_break_reversal") return "LIQUIDITY_REVERSAL";

   // Phase C
   if(strategy_id == "range_compression_breakout") return "COMPRESSION_BREAKOUT";
   if(strategy_id == "volatility_squeeze_release") return "COMPRESSION_BREAKOUT";
   if(strategy_id == "volatility_breakout") return "VOL_BREAKOUT";
   if(strategy_id == "expansion_continuation") return "EXPANSION_CONTINUATION";
   if(strategy_id == "micro_range_expansion") return "MICRO_RANGE_BREAK";

   // Trend pack (exact overrides — declared TREND_CONTINUATION in council_strategies.mqh)
   if(strategy_id == "momentum_breakout_cont_v1") return "TREND_CONTINUATION";
   if(strategy_id == "breakdown_momentum_v1") return "TREND_CONTINUATION";
   if(strategy_id == "micro_structure_reentry_v1") return "TREND_CONTINUATION";
   if(strategy_id == "lower_high_rejection_v1") return "TREND_CONTINUATION";

   // Trend pack (fallback buckets)
   if(StringFind(strategy_id, "trend") >= 0) return "TREND_CONTINUATION";
   if(StringFind(strategy_id, "pullback") >= 0) return "TREND_PULLBACK_CONTINUATION";
   if(StringFind(strategy_id, "momentum") >= 0) return "MOMENTUM_REVERSAL_ASSIST";

   return "UNKNOWN";
}

bool LAB_IsContinuationFamily(string fam)
{
   return (fam == "TREND_CONTINUATION" || fam == "TREND_PULLBACK_CONTINUATION" || fam == "EXPANSION_CONTINUATION");
}

bool LAB_IsReclaimFamily(string fam)
{
   return (fam == "MEAN_RECLAIM");
}

bool LAB_IsBreakoutFamily(string fam)
{
   return (fam == "COMPRESSION_BREAKOUT" || fam == "VOL_BREAKOUT" || fam == "MICRO_RANGE_BREAK");
}

bool LAB_IsLiquidityReversalFamily(string fam)
{
   return (fam == "LIQUIDITY_REVERSAL" || fam == "MOMENTUM_REVERSAL_ASSIST");
}

bool LAB_GetPrevDayLevels(string symbol, double &prevHigh, double &prevLow)
{
   prevHigh = 0.0;
   prevLow  = 0.0;

   if(Bars(symbol, PERIOD_D1) < 2)
      return false;

   prevHigh = iHigh(symbol, PERIOD_D1, 1);
   prevLow  = iLow(symbol, PERIOD_D1, 1);

   return (prevHigh > 0.0 && prevLow > 0.0 && prevHigh > prevLow);
}

bool LAB_GetTodaySessionLevels(string symbol, double &sessHigh, double &sessLow)
{
   sessHigh = 0.0;
   sessLow  = 0.0;

   datetime now = TimeCurrent();
   MqlDateTime dt;
   TimeToStruct(now, dt);
   dt.hour = 0; dt.min = 0; dt.sec = 0;
   datetime dayStart = StructToTime(dt);

   int bars = Bars(symbol, PERIOD_M5);
   if(bars < 10)
      return false;

   sessHigh = -DBL_MAX;
   sessLow  = DBL_MAX;

   for(int i=0; i<bars && i<500; i++)
   {
      datetime t = (datetime)iTime(symbol, PERIOD_M5, i);
      if(t < dayStart)
         break;

      double h = iHigh(symbol, PERIOD_M5, i);
      double l = iLow(symbol, PERIOD_M5, i);

      if(h > sessHigh) sessHigh = h;
      if(l < sessLow)  sessLow  = l;
   }

   if(sessHigh <= sessLow || sessHigh <= 0.0 || sessLow <= 0.0)
      return false;

   return true;
}

double LAB_GetATRPrice(string symbol, ENUM_TIMEFRAMES tf, int period)
{
   if(Bars(symbol, tf) < period + 5)
      return 0.0;

   int h = iATR(symbol, tf, period);
   if(h == INVALID_HANDLE)
      return 0.0;

   double buf[];
   ArrayResize(buf, 1);
   ArraySetAsSeries(buf, true);
   double v = 0.0;
   if(CopyBuffer(h, 0, 0, 1, buf) == 1)
      v = buf[0];

   IndicatorRelease(h);
   return v;
}

void LAB_UpdateNearestLevels(double price, double level, double &bestSupport, double &bestResist)
{
   if(level <= 0.0) return;

   if(level <= price)
   {
      if(level > bestSupport) bestSupport = level;
   }
   else
   {
      if(bestResist <= 0.0 || level < bestResist) bestResist = level;
   }
}

void LAB_CollectFractalLevels(string symbol, ENUM_TIMEFRAMES tf, double price, double &bestSupport, double &bestResist)
{
   int bars = Bars(symbol, tf);
   if(bars < 50)
      return;

   int lookback = MathMin(200, bars-5);

   // iFractals returns handles in MQL5, but in this codebase we rely on iFractals() as series access via CopyBuffer is heavy.
   // Conservative approach: approximate pivots using local extrema scan.
   for(int i=3; i<lookback; i++)
   {
      double h0 = iHigh(symbol, tf, i);
      double h1 = iHigh(symbol, tf, i-1);
      double h2 = iHigh(symbol, tf, i-2);
      double h3 = iHigh(symbol, tf, i-3);

      double l0 = iLow(symbol, tf, i);
      double l1 = iLow(symbol, tf, i-1);
      double l2 = iLow(symbol, tf, i-2);
      double l3 = iLow(symbol, tf, i-3);

      bool pivotHigh = (h0 > h1 && h0 > h2 && h0 > h3);
      bool pivotLow  = (l0 < l1 && l0 < l2 && l0 < l3);

      if(pivotHigh)
         LAB_UpdateNearestLevels(price, h0, bestSupport, bestResist);
      if(pivotLow)
         LAB_UpdateNearestLevels(price, l0, bestSupport, bestResist);
   }
}

void LAB_CollectSwingExtremes(string symbol, ENUM_TIMEFRAMES tf, double price, double &bestSupport, double &bestResist)
{
   int bars = Bars(symbol, tf);
   if(bars < 30)
      return;

   int lookback = MathMin(120, bars-1);
   int hiIdx = iHighest(symbol, tf, MODE_HIGH, lookback, 1);
   int loIdx = iLowest(symbol, tf, MODE_LOW, lookback, 1);

   if(hiIdx >= 0)
      LAB_UpdateNearestLevels(price, iHigh(symbol, tf, hiIdx), bestSupport, bestResist);
   if(loIdx >= 0)
      LAB_UpdateNearestLevels(price, iLow(symbol, tf, loIdx), bestSupport, bestResist);
}

void LAB_CollectRangeBoundsIfNeeded(string zone_semantic, string symbol, double price, double &bestSupport, double &bestResist)
{
   if(StringFind(zone_semantic, "RANGE") < 0)
      return;

   int bars = Bars(symbol, PERIOD_M5);
   if(bars < 50)
      return;

   int lookback = MathMin(80, bars-1);

   double hi = -DBL_MAX;
   double lo = DBL_MAX;

   for(int i=1; i<=lookback; i++)
   {
      double h = iHigh(symbol, PERIOD_M5, i);
      double l = iLow(symbol, PERIOD_M5, i);
      if(h > hi) hi = h;
      if(l < lo) lo = l;
   }

   if(hi > lo && hi > 0.0 && lo > 0.0)
   {
      LAB_UpdateNearestLevels(price, lo, bestSupport, bestResist);
      LAB_UpdateNearestLevels(price, hi, bestSupport, bestResist);
   }
}

bool BuildLevelAwarenessBrakeReport(
   string symbol,
   int direction, // +1 BUY, -1 SELL
   CouncilRuntimeResult &rt,
   LevelAwarenessBrakeReport &out
)
{
   out.direction_under_review = (direction > 0 ? "BUY" : "SELL");
   out.zone_semantic = CouncilInferZoneSemantic(rt.env);

   out.strategy_id = rt.aggregate.best_strategy_id;
   out.strategy_family = LAB_InferFamilyFromStrategyId(out.strategy_id);

   double price = 0.0;
   if(direction > 0)
      SymbolInfoDouble(symbol, SYMBOL_ASK, price);
   else
      SymbolInfoDouble(symbol, SYMBOL_BID, price);

   double bestSupport = 0.0;
   double bestResist  = 0.0;

   // Structure pivots + extremes
   LAB_CollectFractalLevels(symbol, PERIOD_M5, price, bestSupport, bestResist);
   LAB_CollectSwingExtremes(symbol, PERIOD_M15, price, bestSupport, bestResist);

   // Intraday + prev day
   double sessH=0.0, sessL=0.0;
   if(LAB_GetTodaySessionLevels(symbol, sessH, sessL))
   {
      LAB_UpdateNearestLevels(price, sessH, bestSupport, bestResist);
      LAB_UpdateNearestLevels(price, sessL, bestSupport, bestResist);
   }

   double prevH=0.0, prevL=0.0;
   if(LAB_GetPrevDayLevels(symbol, prevH, prevL))
   {
      LAB_UpdateNearestLevels(price, prevH, bestSupport, bestResist);
      LAB_UpdateNearestLevels(price, prevL, bestSupport, bestResist);
   }

   // Range bounds hint
   LAB_CollectRangeBoundsIfNeeded(out.zone_semantic, symbol, price, bestSupport, bestResist);

   out.nearest_support_price = bestSupport;
   out.nearest_resistance_price = bestResist;

   double pt = SymbolInfoDouble(symbol, SYMBOL_POINT);
   int distSupportPts = 999999;
   int distResistPts  = 999999;

   if(bestSupport > 0.0)
      distSupportPts = (int)MathRound((price - bestSupport) / pt);
   if(bestResist > 0.0)
      distResistPts  = (int)MathRound((bestResist - price) / pt);

   out.nearest_support_distance_points = distSupportPts;
   out.nearest_resistance_distance_points = distResistPts;

   double atr = LAB_GetATRPrice(symbol, PERIOD_M5, 14);
   double atrPts = (atr > 0.0 ? atr / pt : 0.0);

   int roomPts = (direction > 0 ? distResistPts : distSupportPts);
   double roomNorm = (atrPts > 1.0 ? (roomPts / (atrPts * 1.20)) : 1.0);
   out.breakout_room_score = LAB_Clamp01(roomNorm);

   int opposePts = (direction > 0 ? distResistPts : distSupportPts);
   double rejThresh = (atrPts > 1.0 ? atrPts * 0.60 : 80.0);
   double rejRisk = 0.0;
   if(opposePts < 999999)
      rejRisk = LAB_Clamp01((rejThresh - opposePts) / rejThresh);
   out.rejection_risk_score = rejRisk;

   out.continuation_obstacle_risk = LAB_IsContinuationFamily(out.strategy_family) ? LAB_Clamp01(1.0 - out.breakout_room_score) : 0.0;

   // Reversal trap: reversal families that are not near the expected edge.
   double revTrap = 0.0;
   if(LAB_IsLiquidityReversalFamily(out.strategy_family))
   {
      int edgePts = (direction > 0 ? distSupportPts : distResistPts); // reversal BUY expects support proximity, SELL expects resistance proximity
      double edgeThresh = (atrPts > 1.0 ? atrPts * 0.55 : 90.0);
      if(edgePts > (int)edgeThresh)
         revTrap = LAB_Clamp01((edgePts - edgeThresh) / (edgeThresh * 1.5));
   }
   out.reversal_trap_risk = revTrap;

   out.location_context_summary =
      "zone=" + out.zone_semantic +
      " fam=" + out.strategy_family +
      " room=" + DoubleToString(out.breakout_room_score, 2) +
      " rej=" + DoubleToString(out.rejection_risk_score, 2) +
      " supPts=" + IntegerToString(distSupportPts) +
      " resPts=" + IntegerToString(distResistPts);

   // Default verdict
   out.brake_verdict = "ALLOW";
   out.brake_reason = "";
   out.brake_reason_code = "";

   bool exhausted = (rt.aggregate.exhaustion_warning || rt.env.exhaustion_hint);

   // ----------------------------
   // Rule A — Continuation Into Obstacle
   // ----------------------------
   if(LAB_IsContinuationFamily(out.strategy_family))
   {
      double hardOppose = (atrPts > 1.0 ? atrPts * 0.35 : 55.0);
      if(opposePts < (int)hardOppose && out.breakout_room_score < 0.35)
      {
         out.brake_verdict = "HARD_REJECT";
         out.brake_reason_code = "continuation_entry_blocked_by_near_opposing_level";
         out.brake_reason = "continuation into near obstacle without sufficient room";
         return true;
      }
   }

   // ----------------------------
   // Rule B — Reclaim Into Rejection
   // ----------------------------
   if(LAB_IsReclaimFamily(out.strategy_family))
   {
      // block only when reclaim is clearly driving straight into rejection with low room
      if(out.rejection_risk_score > 0.80 && out.breakout_room_score < 0.40)
      {
         out.brake_verdict = "HARD_REJECT";
         out.brake_reason_code = "reclaim_entry_conflicts_with_rejection_zone";
         out.brake_reason = "reclaim/mean entry points into strong rejection zone";
         return true;
      }
   }

   // ----------------------------
   // Rule C — Exhausted Breakout Entry
   // ----------------------------
   if(LAB_IsBreakoutFamily(out.strategy_family))
   {
      if(out.breakout_room_score < 0.25 || exhausted)
      {
         out.brake_verdict = "HARD_REJECT";
         out.brake_reason_code = "exhausted_breakout_with_insufficient_room";
         out.brake_reason = exhausted ? "breakout entry in exhausted context" : "breakout entry with insufficient room";
         return true;
      }
   }

   // ----------------------------
   // Rule D — Strategy/Location Misfit
   // ----------------------------
   if(StringFind(out.zone_semantic, "NO_TRADE") >= 0)
   {
      out.brake_verdict = "HARD_REJECT";
      out.brake_reason_code = "strategy_location_misfit_no_trade_zone";
      out.brake_reason = "trade candidate produced in NO_TRADE semantic zone";
      return true;
   }

   bool zoneIsRange = (StringFind(out.zone_semantic, "RANGE") >= 0);
   bool zoneIsTrend = (StringFind(out.zone_semantic, "TREND") >= 0);
   bool zoneIsCompression = (StringFind(out.zone_semantic, "COMPRESSION") >= 0);

   if(zoneIsTrend && out.strategy_family == "MEAN_RECLAIM")
   {
      out.brake_verdict = "HARD_REJECT";
      out.brake_reason_code = "strategy_location_misfit_reclaim_in_trend_zone";
      out.brake_reason = "reclaim family misfit in trend semantic zone";
      return true;
   }

   if(zoneIsRange && (out.strategy_family == "TREND_CONTINUATION" || out.strategy_family == "TREND_PULLBACK_CONTINUATION"))
   {
      out.brake_verdict = "HARD_REJECT";
      out.brake_reason_code = "strategy_location_misfit_trend_in_range_zone";
      out.brake_reason = "trend continuation misfit in range semantic zone";
      return true;
   }

   if(zoneIsCompression && out.strategy_family == "MEAN_RECLAIM")
   {
      out.brake_verdict = "HARD_REJECT";
      out.brake_reason_code = "strategy_location_misfit_reclaim_in_compression";
      out.brake_reason = "reclaim family misfit in compression zone";
      return true;
   }

   // conservative default: allow
   return true;
}

#endif // __LEVEL_AWARENESS_BRAKE_MQH__