#ifndef __CORE_TRADE_ENGINE_MQH__
#define __CORE_TRADE_ENGINE_MQH__

#include <Trade/Trade.mqh>
#include "journal_analytics.mqh"

//---------------------------------------------------------
// Trade setup container
//---------------------------------------------------------
struct TradeLevels
{
   double entry;
   double sl;
   double tp;
   bool   valid;
   string reason;
};

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
int GetSymbolDigits()
{
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
}

double NormalizePriceEx(double price)
{
   return NormalizeDouble(price, GetSymbolDigits());
}

double GetSymbolPoint()
{
   return SymbolInfoDouble(_Symbol, SYMBOL_POINT);
}

int GetStopsLevelPoints()
{
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
}

int GetFreezeLevelPoints()
{
   return (int)SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
}

double GetBidPrice()
{
   return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

double GetAskPrice()
{
   return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
}

bool IsTradeModeAllowed()
{
   long tradeMode = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   return (tradeMode == SYMBOL_TRADE_MODE_FULL);
}

bool IsTradeAllowedNow()
{
   return (bool)TerminalInfoInteger(TERMINAL_TRADE_ALLOWED);
}

bool ReadATRRaw(ENUM_TIMEFRAMES tf, int period, int shift, double &atrVal)
{
   atrVal = 0.0;

   int h = iATR(_Symbol, tf, period);
   if(h == INVALID_HANDLE)
      return false;

   double buf[];
   ArraySetAsSeries(buf, true);

   bool ok = (CopyBuffer(h, 0, shift, 1, buf) == 1);
   if(ok)
      atrVal = buf[0];

   IndicatorRelease(h);
   return ok;
}

double NormalizeVolumeToStep(double lot)
{
   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(volStep <= 0.0)
      return lot;

   double normalized = MathFloor(lot / volStep) * volStep;

   if(normalized < volMin)
      normalized = volMin;

   if(normalized > volMax)
      normalized = volMax;

   int volDigits = 2;
   if(volStep < 0.1)  volDigits = 3;
   if(volStep < 0.01) volDigits = 4;

   return NormalizeDouble(normalized, volDigits);
}

bool ValidateVolume(double lot, string &reason)
{
   reason = "";

   double volMin  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double volMax  = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double volStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);

   if(lot <= 0.0)
   {
      reason = "Lot <= 0";
      return false;
   }

   if(volMin <= 0.0 || volMax <= 0.0 || volStep <= 0.0)
   {
      reason = "Invalid symbol volume settings";
      return false;
   }

   if(lot < volMin)
   {
      reason = "Lot below min volume";
      return false;
   }

   if(lot > volMax)
   {
      reason = "Lot above max volume";
      return false;
   }

   return true;
}

bool ValidateBuyStops(double entry, double sl, double tp, string &reason)
{
   reason = "";

   double point = GetSymbolPoint();
   if(point <= 0.0)
   {
      reason = "Invalid symbol point";
      return false;
   }

   int stopsLevelPts  = GetStopsLevelPoints();
   int freezeLevelPts = GetFreezeLevelPoints();

   double minStopDist = stopsLevelPts * point;
   double freezeDist  = freezeLevelPts * point;

   if(entry <= 0.0 || sl <= 0.0 || tp <= 0.0)
   {
      reason = "BUY price levels invalid";
      return false;
   }

   if(!(sl < entry && tp > entry))
   {
      reason = "BUY SL/TP not positioned correctly";
      return false;
   }

   if((entry - sl) <= minStopDist)
   {
      reason = "BUY SL too close to entry";
      return false;
   }

   if((tp - entry) <= minStopDist)
   {
      reason = "BUY TP too close to entry";
      return false;
   }

   if((entry - sl) <= freezeDist)
   {
      reason = "BUY SL inside freeze level";
      return false;
   }

   if((tp - entry) <= freezeDist)
   {
      reason = "BUY TP inside freeze level";
      return false;
   }

   return true;
}

bool ValidateSellStops(double entry, double sl, double tp, string &reason)
{
   reason = "";

   double point = GetSymbolPoint();
   if(point <= 0.0)
   {
      reason = "Invalid symbol point";
      return false;
   }

   int stopsLevelPts  = GetStopsLevelPoints();
   int freezeLevelPts = GetFreezeLevelPoints();

   double minStopDist = stopsLevelPts * point;
   double freezeDist  = freezeLevelPts * point;

   if(entry <= 0.0 || sl <= 0.0 || tp <= 0.0)
   {
      reason = "SELL price levels invalid";
      return false;
   }

   if(!(sl > entry && tp < entry))
   {
      reason = "SELL SL/TP not positioned correctly";
      return false;
   }

   if((sl - entry) <= minStopDist)
   {
      reason = "SELL SL too close to entry";
      return false;
   }

   if((entry - tp) <= minStopDist)
   {
      reason = "SELL TP too close to entry";
      return false;
   }

   if((sl - entry) <= freezeDist)
   {
      reason = "SELL SL inside freeze level";
      return false;
   }

   if((entry - tp) <= freezeDist)
   {
      reason = "SELL TP inside freeze level";
      return false;
   }

   return true;
}

//---------------------------------------------------------
// Build robust BUY levels
//---------------------------------------------------------
bool BuildBuyTradeLevels(
   double rr,
   double atrMultiplier,
   int atrPeriod,
   double extraStopBufferPoints,
   double m5AtrFloorFraction,
   TradeLevels &levels
)
{
   levels.valid  = false;
   levels.reason = "";
   levels.entry  = 0.0;
   levels.sl     = 0.0;
   levels.tp     = 0.0;

   double ask = GetAskPrice();
   if(ask <= 0.0)
   {
      levels.reason = "Invalid ask price";
      return false;
   }

   double atrRaw = 0.0;
   if(!ReadATRRaw(PERIOD_M1, atrPeriod, 1, atrRaw))
   {
      levels.reason = "Failed to read ATR";
      return false;
   }

   double point = GetSymbolPoint();
   if(point <= 0.0)
   {
      levels.reason = "Invalid symbol point";
      return false;
   }

   int stopLevelPts = GetStopsLevelPoints();

   double brokerMinDistance = (stopLevelPts + extraStopBufferPoints) * point;
   double atrDistance       = atrRaw * atrMultiplier;
   double safeM5Fraction    = MathMax(0.0, m5AtrFloorFraction);
   double m5AtrFloor        = 0.0;

   if(safeM5Fraction > 0.0)
   {
      double m5AtrRaw = 0.0;
      if(ReadATRRaw(PERIOD_M5, atrPeriod, 1, m5AtrRaw) && m5AtrRaw > 0.0)
         m5AtrFloor = m5AtrRaw * safeM5Fraction;
   }

   double finalStopDistance = MathMax(brokerMinDistance, MathMax(atrDistance, m5AtrFloor));

   if(finalStopDistance <= 0.0)
   {
      levels.reason = "Invalid final stop distance";
      return false;
   }

   double sl = ask - finalStopDistance;
   double tp = ask + (finalStopDistance * rr);

   levels.entry = NormalizePriceEx(ask);
   levels.sl    = NormalizePriceEx(sl);
   levels.tp    = NormalizePriceEx(tp);

   string validationReason = "";
   if(!ValidateBuyStops(levels.entry, levels.sl, levels.tp, validationReason))
   {
      levels.reason = validationReason;
      return false;
   }

   levels.valid  = true;
   levels.reason = "BUY trade levels built successfully";
   return true;
}

//---------------------------------------------------------
// Build robust SELL levels
//---------------------------------------------------------
bool BuildSellTradeLevels(
   double rr,
   double atrMultiplier,
   int atrPeriod,
   double extraStopBufferPoints,
   double m5AtrFloorFraction,
   TradeLevels &levels
)
{
   levels.valid  = false;
   levels.reason = "";
   levels.entry  = 0.0;
   levels.sl     = 0.0;
   levels.tp     = 0.0;

   double bid = GetBidPrice();
   if(bid <= 0.0)
   {
      levels.reason = "Invalid bid price";
      return false;
   }

   double atrRaw = 0.0;
   if(!ReadATRRaw(PERIOD_M1, atrPeriod, 1, atrRaw))
   {
      levels.reason = "Failed to read ATR";
      return false;
   }

   double point = GetSymbolPoint();
   if(point <= 0.0)
   {
      levels.reason = "Invalid symbol point";
      return false;
   }

   int stopLevelPts = GetStopsLevelPoints();

   double brokerMinDistance = (stopLevelPts + extraStopBufferPoints) * point;
   double atrDistance       = atrRaw * atrMultiplier;
   double safeM5Fraction    = MathMax(0.0, m5AtrFloorFraction);
   double m5AtrFloor        = 0.0;

   if(safeM5Fraction > 0.0)
   {
      double m5AtrRaw = 0.0;
      if(ReadATRRaw(PERIOD_M5, atrPeriod, 1, m5AtrRaw) && m5AtrRaw > 0.0)
         m5AtrFloor = m5AtrRaw * safeM5Fraction;
   }

   double finalStopDistance = MathMax(brokerMinDistance, MathMax(atrDistance, m5AtrFloor));

   if(finalStopDistance <= 0.0)
   {
      levels.reason = "Invalid final stop distance";
      return false;
   }

   double sl = bid + finalStopDistance;
   double tp = bid - (finalStopDistance * rr);

   levels.entry = NormalizePriceEx(bid);
   levels.sl    = NormalizePriceEx(sl);
   levels.tp    = NormalizePriceEx(tp);

   string validationReason = "";
   if(!ValidateSellStops(levels.entry, levels.sl, levels.tp, validationReason))
   {
      levels.reason = validationReason;
      return false;
   }

   levels.valid  = true;
   levels.reason = "SELL trade levels built successfully";
   return true;
}

//---------------------------------------------------------
// Execute trades
//---------------------------------------------------------
bool OpenBuyTrade(CTrade &trade_obj, ulong magic, double lot, double sl, double tp, string comment)
{
   if(!IsTradeAllowedNow())
   {
      Print("[AI-EA][TRADE] BUY blocked | terminal trading not allowed");
      return false;
   }

   if(!IsTradeModeAllowed())
   {
      Print("[AI-EA][TRADE] BUY blocked | symbol trade mode not full");
      return false;
   }

   double ask = GetAskPrice();
   if(ask <= 0.0)
   {
      Print("[AI-EA][TRADE] BUY blocked | invalid ask");
      return false;
   }

   string reason = "";
   double normalizedLot = NormalizeVolumeToStep(lot);

   if(!ValidateVolume(normalizedLot, reason))
   {
      Print("[AI-EA][TRADE] BUY blocked | invalid lot | ", reason);
      return false;
   }

   if(!ValidateBuyStops(ask, sl, tp, reason))
   {
      Print("[AI-EA][TRADE] BUY blocked | invalid stops | ", reason);
      return false;
   }

   trade_obj.SetExpertMagicNumber(magic);
   trade_obj.SetDeviationInPoints(50);

   bool ok = trade_obj.Buy(normalizedLot, _Symbol, 0.0, sl, tp, comment);

   if(!ok)
   {
      Print("[AI-EA][TRADE] BUY failed | retcode=",
            trade_obj.ResultRetcode(),
            " | ",
            trade_obj.ResultRetcodeDescription(),
            " | lot=",
            DoubleToString(normalizedLot, 2),
            " | sl=",
            DoubleToString(sl, GetSymbolDigits()),
            " | tp=",
            DoubleToString(tp, GetSymbolDigits()));
   }

   return ok;
}

bool OpenSellTrade(CTrade &trade_obj, ulong magic, double lot, double sl, double tp, string comment)
{
   if(!IsTradeAllowedNow())
   {
      Print("[AI-EA][TRADE] SELL blocked | terminal trading not allowed");
      return false;
   }

   if(!IsTradeModeAllowed())
   {
      Print("[AI-EA][TRADE] SELL blocked | symbol trade mode not full");
      return false;
   }

   double bid = GetBidPrice();
   if(bid <= 0.0)
   {
      Print("[AI-EA][TRADE] SELL blocked | invalid bid");
      return false;
   }

   string reason = "";
   double normalizedLot = NormalizeVolumeToStep(lot);

   if(!ValidateVolume(normalizedLot, reason))
   {
      Print("[AI-EA][TRADE] SELL blocked | invalid lot | ", reason);
      return false;
   }

   if(!ValidateSellStops(bid, sl, tp, reason))
   {
      Print("[AI-EA][TRADE] SELL blocked | invalid stops | ", reason);
      return false;
   }

   trade_obj.SetExpertMagicNumber(magic);
   trade_obj.SetDeviationInPoints(50);

   bool ok = trade_obj.Sell(normalizedLot, _Symbol, 0.0, sl, tp, comment);

   if(!ok)
   {
      Print("[AI-EA][TRADE] SELL failed | retcode=",
            trade_obj.ResultRetcode(),
            " | ",
            trade_obj.ResultRetcodeDescription(),
            " | lot=",
            DoubleToString(normalizedLot, 2),
            " | sl=",
            DoubleToString(sl, GetSymbolDigits()),
            " | tp=",
            DoubleToString(tp, GetSymbolDigits()));
   }

   return ok;
}

//---------------------------------------------------------
// Open position management helpers
//---------------------------------------------------------
double ComputeProgressToTP(long posType, double entry, double tp)
{
   double currentPrice = (posType == POSITION_TYPE_BUY) ? GetBidPrice() : GetAskPrice();

   if(entry <= 0.0 || tp <= 0.0 || currentPrice <= 0.0)
      return 0.0;

   double totalDistance = 0.0;
   double currentDistance = 0.0;

   if(posType == POSITION_TYPE_BUY)
   {
      totalDistance = tp - entry;
      currentDistance = currentPrice - entry;
   }
   else
   {
      totalDistance = entry - tp;
      currentDistance = entry - currentPrice;
   }

   if(totalDistance <= 0.0)
      return 0.0;

   double progress = currentDistance / totalDistance;

   if(progress < 0.0) progress = 0.0;
   if(progress > 2.0) progress = 2.0;

   return progress;
}

bool IsStopImprovement(long posType, double currentSL, double proposedSL)
{
   if(proposedSL <= 0.0)
      return false;

   if(currentSL <= 0.0)
      return true;

   if(posType == POSITION_TYPE_BUY)
      return (proposedSL > currentSL);

   return (proposedSL < currentSL);
}

bool IsSLValidForPosition(long posType, double openPrice, double newSL, string &reason)
{
   reason = "";

   double point = GetSymbolPoint();
   if(point <= 0.0)
   {
      reason = "Invalid point";
      return false;
   }

   int stopsLevelPts  = GetStopsLevelPoints();
   int freezeLevelPts = GetFreezeLevelPoints();

   double minDist = stopsLevelPts * point;
   double freezeDist = freezeLevelPts * point;

   double bid = GetBidPrice();
   double ask = GetAskPrice();

   if(posType == POSITION_TYPE_BUY)
   {
      if(newSL >= bid)
      {
         reason = "BUY new SL above/equal bid";
         return false;
      }

      if((bid - newSL) <= minDist)
      {
         reason = "BUY new SL too close to bid";
         return false;
      }

      if((bid - newSL) <= freezeDist)
      {
         reason = "BUY new SL inside freeze level";
         return false;
      }
   }
   else
   {
      if(newSL <= ask)
      {
         reason = "SELL new SL below/equal ask";
         return false;
      }

      if((newSL - ask) <= minDist)
      {
         reason = "SELL new SL too close to ask";
         return false;
      }

      if((newSL - ask) <= freezeDist)
      {
         reason = "SELL new SL inside freeze level";
         return false;
      }
   }

   return true;
}

double ComputeProtectedSL(long posType, double entry, double tp, double progress)
{
   double targetDistance = 0.0;

   if(posType == POSITION_TYPE_BUY)
      targetDistance = tp - entry;
   else
      targetDistance = entry - tp;

   if(targetDistance <= 0.0)
      return 0.0;

   double lockedRatio = 0.0;

   // Break-even phase
   if(progress >= 0.35 && progress < 0.60)
      lockedRatio = 0.02;

   // Start trailing at 60%
   else if(progress >= 0.60 && progress < 0.75)
      lockedRatio = 0.25;

   else if(progress >= 0.75 && progress < 0.90)
      lockedRatio = 0.45;

   // Near TP: tighten aggressively
   else if(progress >= 0.90)
      lockedRatio = 0.70;

   if(lockedRatio <= 0.0)
      return 0.0;

   double protectedDistance = targetDistance * lockedRatio;

   if(posType == POSITION_TYPE_BUY)
      return NormalizePriceEx(entry + protectedDistance);

   return NormalizePriceEx(entry - protectedDistance);
}

bool ModifyPositionSL(
   CTrade &trade_obj,
   ulong ticket,
   string symbol,
   long posType,
   double openPrice,
   double currentSL,
   double currentTP,
   double proposedSL
)
{
   string reason = "";

   if(!IsStopImprovement(posType, currentSL, proposedSL))
      return false;

   if(!IsSLValidForPosition(posType, openPrice, proposedSL, reason))
      return false;

   bool ok = trade_obj.PositionModify(symbol, proposedSL, currentTP);

   if(ok)
   {
      Print("[AI-EA][MANAGE] Position trailing updated | ticket=",
            (long)ticket,
            " | newSL=",
            DoubleToString(proposedSL, GetSymbolDigits()),
            " | tp=",
            DoubleToString(currentTP, GetSymbolDigits()));
   }
   else
   {
      Print("[AI-EA][MANAGE] Position trailing failed | ticket=",
            (long)ticket,
            " | retcode=",
            trade_obj.ResultRetcode(),
            " | ",
            trade_obj.ResultRetcodeDescription(),
            " | proposedSL=",
            DoubleToString(proposedSL, GetSymbolDigits()),
            " | reason=",
            reason);
   }

   return ok;
}

//---------------------------------------------------------
// Manage all open positions for this EA
//---------------------------------------------------------

//---------------------------------------------------------
// Council live exit (opt-in)
//---------------------------------------------------------
struct CouncilLiveExitPositionState
{
   ulong    position_id;
   datetime open_time;
   double   max_progress_seen;
   double   last_progress_seen;
   string   last_exit_reason;
   datetime last_update_time;
};

struct CouncilLiveExitConfig
{
   bool   enabled;
   int    premise_death_m5_bars;
   double min_progress_to_keep;
   double giveback_trigger_progress;
   double giveback_retained_floor;
};

void InitCouncilLiveExitConfig(CouncilLiveExitConfig &cfg)
{
   cfg.enabled = false;
   cfg.premise_death_m5_bars = 6;
   cfg.min_progress_to_keep = 0.18;
   cfg.giveback_trigger_progress = 0.55;
   cfg.giveback_retained_floor = 0.20;
}

int CouncilLiveExitFindStateIndex(CouncilLiveExitPositionState &arr[], ulong position_id)
{
   for(int i=0; i<ArraySize(arr); i++)
      if(arr[i].position_id == position_id) return i;
   return -1;
}


bool CouncilLiveExitLoadState(CouncilLiveExitPositionState &states[])
{
   ArrayResize(states, 0);

   int fh = FileOpen("AI\\council_live_exit_state.json", FILE_READ|FILE_TXT|FILE_ANSI);
   if(fh == INVALID_HANDLE) return false;

   string json = "";
   while(!FileIsEnding(fh))
      json += FileReadString(fh);
   FileClose(fh);

   if(StringLen(json) < 10) return false;

   // Parse as a loose list of JSON objects; use journal analytics extractors for tolerance.
   int pos = 0;
   while(true)
   {
      int a = StringFind(json, "{", pos);
      if(a < 0) break;
      int b = StringFind(json, "}", a);
      if(b < 0) break;

      string obj = StringSubstr(json, a, b-a+1);

      ulong pid = (ulong)JA_ExtractJsonUlong(obj, "position_id");
      if(pid == 0) { pos = b+1; continue; }

      CouncilLiveExitPositionState st;
      st.position_id = pid;
      st.open_time = (datetime)JA_ExtractJsonUlong(obj, "open_time");
      st.max_progress_seen = JA_ExtractJsonDouble(obj, "max_progress_seen");
      st.last_progress_seen = JA_ExtractJsonDouble(obj, "last_progress_seen");
      st.last_exit_reason = JA_ExtractJsonString(obj, "last_exit_reason");
      st.last_update_time = (datetime)JA_ExtractJsonUlong(obj, "last_update_time");

      int n = ArraySize(states);
      ArrayResize(states, n+1);
      states[n] = st;

      pos = b+1;
   }

   return (ArraySize(states) > 0);
}


string CouncilLiveExitJsonEscape(string s)
{
   StringReplace(s, "\\", "\\\\");
   StringReplace(s, "\"", "\\\"");
   StringReplace(s, "\r", "\\r");
   StringReplace(s, "\n", "\\n");
   return s;
}
bool CouncilLiveExitSaveState(CouncilLiveExitPositionState &states[])
{
   int fh = FileOpen("AI\\council_live_exit_state.json", FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(fh == INVALID_HANDLE) return false;

   string out = "[";
   for(int i=0; i<ArraySize(states); i++)
   {
      if(i>0) out += ",";
      out += "{";
      out += "\"position_id\":" + (string)states[i].position_id + ",";
      out += "\"open_time\":" + (string)states[i].open_time + ",";
      out += "\"max_progress_seen\":" + DoubleToString(states[i].max_progress_seen, 5) + ",";
      out += "\"last_progress_seen\":" + DoubleToString(states[i].last_progress_seen, 5) + ",";
      out += "\"last_exit_reason\":\"" + CouncilLiveExitJsonEscape(states[i].last_exit_reason) + "\",";
      out += "\"last_update_time\":" + (string)states[i].last_update_time;
      out += "}";
   }
   out += "]";

   FileWriteString(fh, out);
   FileClose(fh);
   return true;
}

string CouncilLiveExitBuildStatusText(string symbol, ulong position_id, string direction, double progress, double max_progress, double profit, int bars_open, string action, string reason_code)
{
   string t = "";
   t += "COUNCIL_LIVE_EXIT|symbol=" + symbol;
   t += "|position_id=" + (string)position_id;
   t += "|dir=" + direction;
   t += "|progress=" + DoubleToString(progress, 3);
   t += "|max_progress=" + DoubleToString(max_progress, 3);
   t += "|profit=" + DoubleToString(profit, 2);
   t += "|m5_bars_open=" + (string)bars_open;
   t += "|action=" + action;
   t += "|reason=" + reason_code;
   t += "|ts=" + TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS);
   return t;
}

string CouncilLiveExitBuildStatusJson(string symbol, ulong position_id, string direction, double progress, double max_progress, double profit, int bars_open, string action, string reason_code)
{
   string j = "{";
   j += "\"symbol\":\"" + CouncilLiveExitJsonEscape(symbol) + "\",";
   j += "\"position_id\":" + (string)position_id + ",";
   j += "\"direction\":\"" + CouncilLiveExitJsonEscape(direction) + "\",";
   j += "\"progress\":" + DoubleToString(progress, 5) + ",";
   j += "\"max_progress_seen\":" + DoubleToString(max_progress, 5) + ",";
   j += "\"profit\":" + DoubleToString(profit, 2) + ",";
   j += "\"m5_bars_open\":" + (string)bars_open + ",";
   j += "\"action\":\"" + CouncilLiveExitJsonEscape(action) + "\",";
   j += "\"reason_code\":\"" + CouncilLiveExitJsonEscape(reason_code) + "\",";
   j += "\"timestamp\":\"" + CouncilLiveExitJsonEscape(TimeToString(TimeCurrent(), TIME_DATE|TIME_MINUTES|TIME_SECONDS)) + "\"";
   j += "}";
   return j;
}

void CouncilLiveExitSaveStatusBestEffort(string txt, string json)
{
   int fh1 = FileOpen("AI\\council_live_exit_status.txt", FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(fh1 != INVALID_HANDLE) { FileWriteString(fh1, txt); FileClose(fh1); }

   int fh2 = FileOpen("AI\\council_live_exit_status.json", FILE_WRITE|FILE_TXT|FILE_ANSI);
   if(fh2 != INVALID_HANDLE) { FileWriteString(fh2, json); FileClose(fh2); }
}

int CouncilLiveExitM5BarsSince(datetime open_time)
{
   if(open_time <= 0) return 0;
   int shift = iBarShift(_Symbol, PERIOD_M5, open_time, true);
   if(shift < 0) shift = iBarShift(_Symbol, PERIOD_M5, open_time, false);
   if(shift < 0) return 0;
   return shift;
}

void CouncilLiveExitClampConfig(CouncilLiveExitConfig &cfg)
{
   if(cfg.premise_death_m5_bars < 1) cfg.premise_death_m5_bars = 1;
   if(cfg.premise_death_m5_bars > 200) cfg.premise_death_m5_bars = 200;

   if(cfg.min_progress_to_keep < 0.01) cfg.min_progress_to_keep = 0.01;
   if(cfg.min_progress_to_keep > 0.95) cfg.min_progress_to_keep = 0.95;

   if(cfg.giveback_trigger_progress < 0.05) cfg.giveback_trigger_progress = 0.05;
   if(cfg.giveback_trigger_progress > 0.95) cfg.giveback_trigger_progress = 0.95;

   if(cfg.giveback_retained_floor < 0.01) cfg.giveback_retained_floor = 0.01;
   if(cfg.giveback_retained_floor > 0.90) cfg.giveback_retained_floor = 0.90;

   if(cfg.giveback_retained_floor >= cfg.giveback_trigger_progress)
   {
      double floor = cfg.giveback_trigger_progress - 0.05;
      if(floor < 0.01) floor = 0.01;
      cfg.giveback_retained_floor = floor;
   }
}

// Advanced live exit manager (COUNCIL-only; fail-open to baseline when unresolved)
void ManageOpenPositionsAdvanced(CTrade &trade_obj, ulong magic, CouncilLiveExitConfig &cfg)
{
   if(!IsTradeAllowedNow() || !IsTradeModeAllowed())
      return;

   CouncilLiveExitClampConfig(cfg);

   trade_obj.SetExpertMagicNumber(magic);
   trade_obj.SetDeviationInPoints(50);

   CouncilLiveExitPositionState states[];
   CouncilLiveExitLoadState(states); // best-effort

   bool stateChanged = false;

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0) continue;
      if(!PositionSelectByTicket(ticket)) continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      long   posMagic = PositionGetInteger(POSITION_MAGIC);
      if(symbol != _Symbol || (ulong)posMagic != magic) continue;

      ulong position_id = (ulong)PositionGetInteger(POSITION_IDENTIFIER);
      datetime open_time = (datetime)PositionGetInteger(POSITION_TIME);

      string active_mode = "";
      bool mode_ok = JA_FindTradeOpenActiveModeByPositionId(position_id, active_mode);
      bool isCouncil = (mode_ok && active_mode == "COUNCIL");

      long   posType   = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);
      double profit    = PositionGetDouble(POSITION_PROFIT);

      // Always preserve baseline protection behavior
      double progress = -1.0;
      if(openPrice > 0.0 && currentTP > 0.0)
         progress = ComputeProgressToTP(posType, openPrice, currentTP);

      // Track only if we can resolve as COUNCIL
      if(isCouncil && cfg.enabled && progress >= 0.0)
      {
         int idx = CouncilLiveExitFindStateIndex(states, position_id);
         if(idx < 0)
         {
            CouncilLiveExitPositionState st;
            st.position_id = position_id;
            st.open_time = open_time;
            st.max_progress_seen = MathMax(0.0, progress);
            st.last_progress_seen = MathMax(0.0, progress);
            st.last_exit_reason = "";
            st.last_update_time = TimeCurrent();
            int n = ArraySize(states);
            ArrayResize(states, n+1);
            states[n] = st;
            idx = n;
            stateChanged = true;
         }

         states[idx].open_time = open_time;
         states[idx].last_progress_seen = progress;
         if(progress > states[idx].max_progress_seen)
            states[idx].max_progress_seen = progress;
         states[idx].last_update_time = TimeCurrent();

         int bars_open = CouncilLiveExitM5BarsSince(open_time);

         string direction = (posType == POSITION_TYPE_BUY ? "BUY" : "SELL");

         // Rule 1: premise-death timeout exit
         if(bars_open >= cfg.premise_death_m5_bars &&
            states[idx].max_progress_seen < cfg.min_progress_to_keep &&
            profit <= 0.0)
         {
            bool closed = trade_obj.PositionClose(ticket);
            string action = closed ? "CLOSE" : "CLOSE_FAILED";
            string reason = "premise_dead_timeout";
            states[idx].last_exit_reason = reason;
            stateChanged = true;

            CouncilLiveExitSaveStatusBestEffort(
               CouncilLiveExitBuildStatusText(symbol, position_id, direction, progress, states[idx].max_progress_seen, profit, bars_open, action, reason),
               CouncilLiveExitBuildStatusJson(symbol, position_id, direction, progress, states[idx].max_progress_seen, profit, bars_open, action, reason)
            );

            continue; // do not further manage if we attempted close
         }

         // Rule 2: giveback / deterioration exit
         if(states[idx].max_progress_seen >= cfg.giveback_trigger_progress &&
            progress <= cfg.giveback_retained_floor &&
            profit <= 0.0)
         {
            bool closed = trade_obj.PositionClose(ticket);
            string action = closed ? "CLOSE" : "CLOSE_FAILED";
            string reason = "progress_giveback_kill";
            states[idx].last_exit_reason = reason;
            stateChanged = true;

            CouncilLiveExitSaveStatusBestEffort(
               CouncilLiveExitBuildStatusText(symbol, position_id, direction, progress, states[idx].max_progress_seen, profit, CouncilLiveExitM5BarsSince(open_time), action, reason),
               CouncilLiveExitBuildStatusJson(symbol, position_id, direction, progress, states[idx].max_progress_seen, profit, CouncilLiveExitM5BarsSince(open_time), action, reason)
            );

            continue;
         }
      }

      // Baseline protection logic (unchanged)
      if(openPrice <= 0.0 || currentTP <= 0.0)
         continue;

      double baselineProgress = ComputeProgressToTP(posType, openPrice, currentTP);
      if(baselineProgress < 0.35)
         continue;

      double proposedSL = ComputeProtectedSL(posType, openPrice, currentTP, baselineProgress);
      if(proposedSL <= 0.0)
         continue;

      ModifyPositionSL(
         trade_obj,
         ticket,
         symbol,
         posType,
         openPrice,
         currentSL,
         currentTP,
         proposedSL
      );
   }

   if(stateChanged)
      CouncilLiveExitSaveState(states); // best-effort

   // cleanup: remove states for positions no longer open (compact pass)
   // keep minimal to avoid heavy scans; next save will overwrite anyway
}


void ManageOpenPositions(CTrade &trade_obj, ulong magic)
{
   if(!IsTradeAllowedNow() || !IsTradeModeAllowed())
      return;

   trade_obj.SetExpertMagicNumber(magic);
   trade_obj.SetDeviationInPoints(50);

   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket == 0)
         continue;

      if(!PositionSelectByTicket(ticket))
         continue;

      string symbol = PositionGetString(POSITION_SYMBOL);
      long   posMagic = PositionGetInteger(POSITION_MAGIC);

      if(symbol != _Symbol || (ulong)posMagic != magic)
         continue;

      long   posType   = PositionGetInteger(POSITION_TYPE);
      double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
      double currentSL = PositionGetDouble(POSITION_SL);
      double currentTP = PositionGetDouble(POSITION_TP);

      if(openPrice <= 0.0 || currentTP <= 0.0)
         continue;

      double progress = ComputeProgressToTP(posType, openPrice, currentTP);
      if(progress < 0.35)
         continue;

      double proposedSL = ComputeProtectedSL(posType, openPrice, currentTP, progress);
      if(proposedSL <= 0.0)
         continue;

      ModifyPositionSL(
         trade_obj,
         ticket,
         symbol,
         posType,
         openPrice,
         currentSL,
         currentTP,
         proposedSL
      );
   }
}

#endif
