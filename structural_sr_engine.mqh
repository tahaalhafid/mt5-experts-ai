#ifndef __STRUCTURAL_SR_ENGINE_MQH__
#define __STRUCTURAL_SR_ENGINE_MQH__

/*
   Structural S/R Engine V1 — MT5 MVP
   Phase 3D-2

   Replaces the naive fractal-pivot scan in level_awareness_brake.mqh with a proper
   zone model: N=3 confirmed swings, 2-touch promotion, ATR-width zones, strength
   scoring, WEAK/MEDIUM/STRONG/MAJOR classification.

   Only STRONG and MAJOR zones are eligible to trigger a hard brake.
*/

// ─────────────────────────────────────────────
//  Enums
// ─────────────────────────────────────────────

enum StructuralZoneClass
{
   ZONE_WEAK   = 0,
   ZONE_MEDIUM = 1,
   ZONE_STRONG = 2,
   ZONE_MAJOR  = 3
};

enum StructuralZoneStatus
{
   ZONE_ACTIVE       = 0,
   ZONE_BROKEN       = 1,
   ZONE_CONSUMED     = 2,
   ZONE_STALE        = 3,
   ZONE_BREAK_RETEST = 4
};

enum StructuralZoneType
{
   ZONE_RESISTANCE = 0,
   ZONE_SUPPORT    = 1
};

// ─────────────────────────────────────────────
//  Zone struct
// ─────────────────────────────────────────────

struct StructuralZone
{
   int                  level_id;
   ENUM_TIMEFRAMES      source_timeframe;
   StructuralZoneType   zone_type;

   double               zone_low;
   double               zone_high;
   double               zone_mid;

   int                  touch_count;
   double               rejection_score;    // 0..1  avg wick-body ratio at touch bars
   double               moveaway_score;     // 0..1  avg post-touch move in ATR units
   double               recency_score;      // 0..1  decays with bar age
   double               confluence_score;   // 0..1  1 if multi-TF confirmed
   double               break_retest_score; // 0..1  bonus if broken then retested

   double               total_strength;     // 0..100
   StructuralZoneClass  strength_class;
   StructuralZoneStatus status;

   int                  age_bars_source_tf;
   datetime             created_time;
   datetime             last_touch_time;
   double               last_touch_price;

   bool                 multi_tf_confluent;

   // Slice 1 enrichment — freshness / persistence / credibility / crowding / openness
   double  freshness_score;    // 0..1: recency of latest engagement (max recency across merged cluster)
   double  persistence_score;  // 0..1: zone survival depth — grows with age_bars, saturates early
   double  credibility_score;  // 0..1: break/retest approach evidence beyond initial pivot
   double  openness_score;     // 0..1: clear space on far side — computed post-promotion
   double  crowding_penalty;   // 0..1: proximity density with peer zones — computed post-promotion
   bool    zone_tested;        // true if price returned near zone_mid after initial formation
   int     source_tf_rank;     // 0=M5 1=M15 2=H1 3=H4 — fast tier comparison
};

// ─────────────────────────────────────────────
//  Global cache (max 8 zones per side)
// ─────────────────────────────────────────────

#define SRE_MAX_ZONES 8

StructuralZone  gSRZonesResistance[SRE_MAX_ZONES];
StructuralZone  gSRZonesSupport[SRE_MAX_ZONES];
int             gSRZonesResistanceCount = 0;
int             gSRZonesSupportCount    = 0;
datetime        gSREngineLastUpdatedBar = 0;
string          gSRELastUpdateSummary   = "";

// ─────────────────────────────────────────────
//  Internal helpers
// ─────────────────────────────────────────────

double SRE_GetATR(string symbol, ENUM_TIMEFRAMES tf, int period)
{
   if(Bars(symbol, tf) < period + 5)
      return 0.0;
   int h = iATR(symbol, tf, period);
   if(h == INVALID_HANDLE) return 0.0;
   double buf[];
   ArrayResize(buf, 1);
   ArraySetAsSeries(buf, true);
   double v = 0.0;
   if(CopyBuffer(h, 0, 0, 1, buf) == 1) v = buf[0];
   IndicatorRelease(h);
   return v;
}

// Confirmed N=3 swing high: bar i must be strictly higher than N neighbors on each side
bool SRE_IsSwingHigh(string symbol, ENUM_TIMEFRAMES tf, int i, int N, int bars)
{
   if(i < N || i + N >= bars) return false;
   double h0 = iHigh(symbol, tf, i);
   for(int k = 1; k <= N; k++)
   {
      if(iHigh(symbol, tf, i - k) >= h0) return false;
      if(iHigh(symbol, tf, i + k) >= h0) return false;
   }
   return true;
}

bool SRE_IsSwingLow(string symbol, ENUM_TIMEFRAMES tf, int i, int N, int bars)
{
   if(i < N || i + N >= bars) return false;
   double l0 = iLow(symbol, tf, i);
   for(int k = 1; k <= N; k++)
   {
      if(iLow(symbol, tf, i - k) <= l0) return false;
      if(iLow(symbol, tf, i + k) <= l0) return false;
   }
   return true;
}

// Rejection score at a single bar: (high - close) / (high - low) for resistance touches,
// inverted for support. Clamped 0..1.
double SRE_RejectionAt(string symbol, ENUM_TIMEFRAMES tf, int i, StructuralZoneType zt)
{
   double h = iHigh(symbol, tf, i);
   double l = iLow(symbol, tf, i);
   double c = iClose(symbol, tf, i);
   double range = h - l;
   if(range <= 0.0) return 0.0;
   if(zt == ZONE_RESISTANCE)
      return MathMin(1.0, (h - c) / range);
   else
      return MathMin(1.0, (c - l) / range);
}

// Post-touch move score: how far price moved away over next 5 bars in ATR units (capped at 1)
double SRE_MoveAwayScore(string symbol, ENUM_TIMEFRAMES tf, int touchBar, StructuralZoneType zt, double atr, int bars)
{
   if(atr <= 0.0) return 0.0;
   int fwd = 5;
   if(touchBar < fwd) return 0.0; // need bars ahead (lower indices = newer)
   double touchPrice = (zt == ZONE_RESISTANCE) ? iHigh(symbol, tf, touchBar) : iLow(symbol, tf, touchBar);
   double extremeFwd = touchPrice;
   for(int k = touchBar - 1; k >= MathMax(0, touchBar - fwd); k--)
   {
      double v = (zt == ZONE_RESISTANCE) ? iLow(symbol, tf, k) : iHigh(symbol, tf, k);
      if(zt == ZONE_RESISTANCE && v < extremeFwd) extremeFwd = v;
      if(zt == ZONE_SUPPORT    && v > extremeFwd) extremeFwd = v;
   }
   double move = MathAbs(extremeFwd - touchPrice);
   return MathMin(1.0, move / (atr * 2.0));
}

// Recency score: 1.0 at bar 0, decays to 0 at bar = maxAge
double SRE_RecencyScore(int ageBars, int maxAge)
{
   if(ageBars <= 0)   return 1.0;
   if(ageBars >= maxAge) return 0.0;
   return 1.0 - (double)ageBars / (double)maxAge;
}

// TF weight for strength formula
double SRE_TFWeight(ENUM_TIMEFRAMES tf)
{
   if(tf == PERIOD_H4)  return 1.3;
   if(tf == PERIOD_H1)  return 1.0;
   if(tf == PERIOD_M15) return 0.7;
   if(tf == PERIOD_M5)  return 0.4;
   return 0.3;
}

int SRE_TFRank(ENUM_TIMEFRAMES tf)
{
   if(tf == PERIOD_H4)  return 3;
   if(tf == PERIOD_H1)  return 2;
   if(tf == PERIOD_M15) return 1;
   return 0;  // M5 and others
}

string SRE_BuildDiagnosticSummary(int rawResCount, int rawSupCount)
{
   int rMaj=0,rStr=0,rMed=0,rWk=0, sMaj=0,sStr=0,sMed=0,sWk=0;
   for(int i=0;i<gSRZonesResistanceCount;i++)
   {
      switch(gSRZonesResistance[i].strength_class)
      {
         case ZONE_MAJOR:  rMaj++; break;
         case ZONE_STRONG: rStr++; break;
         case ZONE_MEDIUM: rMed++; break;
         default:          rWk++;  break;
      }
   }
   for(int i=0;i<gSRZonesSupportCount;i++)
   {
      switch(gSRZonesSupport[i].strength_class)
      {
         case ZONE_MAJOR:  sMaj++; break;
         case ZONE_STRONG: sStr++; break;
         case ZONE_MEDIUM: sMed++; break;
         default:          sWk++;  break;
      }
   }
   return "SRE"
      + " | Pool R=" + IntegerToString(rawResCount) + " S=" + IntegerToString(rawSupCount)
      + " | Res[" + IntegerToString(gSRZonesResistanceCount) + "]"
         + " Maj=" + IntegerToString(rMaj)
         + " Str=" + IntegerToString(rStr)
         + " Med=" + IntegerToString(rMed)
         + " Wk="  + IntegerToString(rWk)
      + " | Sup[" + IntegerToString(gSRZonesSupportCount) + "]"
         + " Maj=" + IntegerToString(sMaj)
         + " Str=" + IntegerToString(sStr)
         + " Med=" + IntegerToString(sMed)
         + " Wk="  + IntegerToString(sWk);
}

// Compute total strength 0..100
double SRE_ComputeStrength(StructuralZone &z)
{
   double tc  = MathMin(1.0, (z.touch_count - 1) / 4.0); // saturates at 5 touches
   double raw = tc                    * 0.22
              + z.rejection_score     * 0.18
              + z.moveaway_score      * 0.12
              + SRE_TFWeight(z.source_timeframe) * 0.15
              + z.recency_score       * 0.08
              + z.confluence_score    * 0.05
              + z.freshness_score     * 0.08
              + z.persistence_score   * 0.05
              + z.credibility_score   * 0.07;
   return MathMin(100.0, raw * 100.0);
}

void SRE_AssignClass(StructuralZone &z)
{
   if(z.total_strength >= 75.0)      z.strength_class = ZONE_MAJOR;
   else if(z.total_strength >= 50.0) z.strength_class = ZONE_STRONG;
   else if(z.total_strength >= 28.0) z.strength_class = ZONE_MEDIUM;
   else                               z.strength_class = ZONE_WEAK;
}

// ─────────────────────────────────────────────
//  Swing scan for one timeframe
//  Fills raw candidate arrays (before clustering)
// ─────────────────────────────────────────────

void SRE_ScanTF(
   string          symbol,
   ENUM_TIMEFRAMES tf,
   int             N,
   int             lookback,
   double          atr,
   double          atrM15,        // used for half-width calculation
   StructuralZone  &resOut[],
   int             &resCount,
   StructuralZone  &supOut[],
   int             &supCount,
   int             maxContribution  // max entries this TF may add to the shared pool
)
{
   int bars = Bars(symbol, tf);
   if(bars < lookback + N + 6) return;
   int limit = MathMin(lookback, bars - N - 5);

   // temporary arrays sized to max candidate count
   StructuralZone tmpRes[];
   StructuralZone tmpSup[];
   ArrayResize(tmpRes, limit);
   ArrayResize(tmpSup, limit);
   int rCnt = 0, sCnt = 0;

   double halfWidthMin = atrM15 * 0.20;
   double halfWidthMax = atrM15 * 0.50;

   for(int i = N; i < limit; i++)
   {
      if(SRE_IsSwingHigh(symbol, tf, i, N, bars))
      {
         double px  = iHigh(symbol, tf, i);
         double rej = SRE_RejectionAt(symbol, tf, i, ZONE_RESISTANCE);
         double maw = SRE_MoveAwayScore(symbol, tf, i, ZONE_RESISTANCE, atr, bars);
         double hw  = MathMax(halfWidthMin, MathMin(halfWidthMax, atr * 0.25));

         StructuralZone z;
         z.level_id           = rCnt;
         z.source_timeframe   = tf;
         z.zone_type          = ZONE_RESISTANCE;
         z.zone_mid           = px;
         z.zone_low           = px - hw;
         z.zone_high          = px + hw;
         z.touch_count        = 1;
         z.rejection_score    = rej;
         z.moveaway_score     = maw;
         z.recency_score      = SRE_RecencyScore(i, limit);
         z.confluence_score   = 0.0;
         z.break_retest_score = 0.0;
         z.age_bars_source_tf = i;
         z.created_time       = (datetime)iTime(symbol, tf, i);
         z.last_touch_time    = z.created_time;
         z.last_touch_price   = px;
         z.multi_tf_confluent = false;
         z.status             = ZONE_ACTIVE;
         z.total_strength     = 0.0;
         z.strength_class     = ZONE_WEAK;
         // Slice 1 enrichment fields
         z.freshness_score    = z.recency_score;
         z.persistence_score  = MathMin(1.0, (double)i / (double)MathMax(1, lookback / 4));
         z.credibility_score  = 0.0;
         z.openness_score     = 0.0;
         z.crowding_penalty   = 0.0;
         z.zone_tested        = false;
         z.source_tf_rank     = SRE_TFRank(tf);
         // Credibility: count bars newer than pivot that approached zone without breaking it
         {
            int retestCount = 0;
            int scanEnd = MathMax(0, i - 20);
            for(int k = i - 1; k >= scanEnd; k--)
            {
               double testH = iHigh(symbol, tf, k);
               if(testH >= z.zone_low - hw && testH < z.zone_high + hw)
                  retestCount++;
            }
            if(retestCount > 0)
            {
               z.zone_tested       = true;
               z.credibility_score = MathMin(1.0, (double)retestCount / 3.0);
            }
         }
         tmpRes[rCnt++] = z;
      }

      if(SRE_IsSwingLow(symbol, tf, i, N, bars))
      {
         double px  = iLow(symbol, tf, i);
         double rej = SRE_RejectionAt(symbol, tf, i, ZONE_SUPPORT);
         double maw = SRE_MoveAwayScore(symbol, tf, i, ZONE_SUPPORT, atr, bars);
         double hw  = MathMax(halfWidthMin, MathMin(halfWidthMax, atr * 0.25));

         StructuralZone z;
         z.level_id           = sCnt;
         z.source_timeframe   = tf;
         z.zone_type          = ZONE_SUPPORT;
         z.zone_mid           = px;
         z.zone_low           = px - hw;
         z.zone_high          = px + hw;
         z.touch_count        = 1;
         z.rejection_score    = rej;
         z.moveaway_score     = maw;
         z.recency_score      = SRE_RecencyScore(i, limit);
         z.confluence_score   = 0.0;
         z.break_retest_score = 0.0;
         z.age_bars_source_tf = i;
         z.created_time       = (datetime)iTime(symbol, tf, i);
         z.last_touch_time    = z.created_time;
         z.last_touch_price   = px;
         z.multi_tf_confluent = false;
         z.status             = ZONE_ACTIVE;
         z.total_strength     = 0.0;
         z.strength_class     = ZONE_WEAK;
         // Slice 1 enrichment fields
         z.freshness_score    = z.recency_score;
         z.persistence_score  = MathMin(1.0, (double)i / (double)MathMax(1, lookback / 4));
         z.credibility_score  = 0.0;
         z.openness_score     = 0.0;
         z.crowding_penalty   = 0.0;
         z.zone_tested        = false;
         z.source_tf_rank     = SRE_TFRank(tf);
         // Credibility: count bars newer than pivot that approached zone without breaking it
         {
            int retestCount = 0;
            int scanEnd = MathMax(0, i - 20);
            for(int k = i - 1; k >= scanEnd; k--)
            {
               double testL = iLow(symbol, tf, k);
               if(testL <= z.zone_high + hw && testL > z.zone_low - hw)
                  retestCount++;
            }
            if(retestCount > 0)
            {
               z.zone_tested       = true;
               z.credibility_score = MathMin(1.0, (double)retestCount / 3.0);
            }
         }
         tmpSup[sCnt++] = z;
      }
   }

   // Append to output arrays — respecting per-TF contribution quota
   int resBefore = resCount;
   for(int i = 0; i < rCnt && resCount < ArraySize(resOut) && (resCount - resBefore) < maxContribution; i++)
      resOut[resCount++] = tmpRes[i];

   int supBefore = supCount;
   for(int i = 0; i < sCnt && supCount < ArraySize(supOut) && (supCount - supBefore) < maxContribution; i++)
      supOut[supCount++] = tmpSup[i];
}

// ─────────────────────────────────────────────
//  Cluster + promote: merge zones within clusterThresh,
//  keep only those with touch_count >= 2,
//  cap at SRE_MAX_ZONES, sorted by strength desc
// ─────────────────────────────────────────────

void SRE_ClusterAndPromote(
   StructuralZone &raw[],
   int            rawCount,
   double         clusterThresh,   // ATR(M15)*0.40
   StructuralZone &out[],
   int            &outCount
)
{
   outCount = 0;
   if(rawCount <= 0) return;

   // merged[] marks which raw entries are consumed
   bool merged[];
   ArrayResize(merged, rawCount);
   ArrayInitialize(merged, false);

   // working cluster array (upper bound = rawCount)
   StructuralZone clusters[];
   ArrayResize(clusters, rawCount);
   int clusterCount = 0;

   for(int i = 0; i < rawCount; i++)
   {
      if(merged[i]) continue;
      StructuralZone base = raw[i];
      int groupSize = 1;
      double sumRej = base.rejection_score;
      double sumMaw = base.moveaway_score;
      double sumMid = base.zone_mid;
      datetime latestTouch = base.last_touch_time;
      double sumFresh   = base.freshness_score;
      double sumPersist = base.persistence_score;
      double sumCredib  = base.credibility_score;
      bool   anyTested  = base.zone_tested;
      int    highRank   = base.source_tf_rank;

      for(int j = i + 1; j < rawCount; j++)
      {
         if(merged[j]) continue;
         if(MathAbs(raw[j].zone_mid - base.zone_mid) <= clusterThresh)
         {
            merged[j] = true;
            groupSize++;
            sumRej += raw[j].rejection_score;
            sumMaw += raw[j].moveaway_score;
            sumMid += raw[j].zone_mid;
            sumFresh   += raw[j].freshness_score;
            sumPersist += raw[j].persistence_score;
            sumCredib  += raw[j].credibility_score;
            if(raw[j].zone_tested)                   anyTested = true;
            if(raw[j].source_tf_rank > highRank)     highRank  = raw[j].source_tf_rank;
            if(raw[j].last_touch_time > latestTouch)
            {
               latestTouch = raw[j].last_touch_time;
               base.last_touch_price = raw[j].last_touch_price;
            }
            // upgrade TF if higher
            if(raw[j].source_timeframe > base.source_timeframe)
               base.source_timeframe = raw[j].source_timeframe;
            if(raw[j].source_tf_rank > base.source_tf_rank)
               base.source_tf_rank = raw[j].source_tf_rank;
            if(raw[j].source_timeframe != base.source_timeframe)
               base.multi_tf_confluent = true;
            base.confluence_score = 1.0;
         }
      }

      base.touch_count       = groupSize;
      base.rejection_score   = sumRej / groupSize;
      base.moveaway_score    = sumMaw / groupSize;
      base.freshness_score   = sumFresh / groupSize;
      base.persistence_score = sumPersist / groupSize;
      base.credibility_score = sumCredib / groupSize;
      base.zone_tested       = anyTested;
      base.source_tf_rank    = highRank;
      base.openness_score    = 0.0;
      base.crowding_penalty  = 0.0;
      base.last_touch_time   = latestTouch;
      base.zone_mid          = sumMid / groupSize;
      // recalculate zone_low/high around merged mid using original half-width
      double hw = (base.zone_high - base.zone_low) / 2.0;
      base.zone_low  = base.zone_mid - hw;
      base.zone_high = base.zone_mid + hw;

      base.total_strength = SRE_ComputeStrength(base);
      SRE_AssignClass(base);

      clusters[clusterCount++] = base;
   }

   // Filter: require touch_count >= 2
   StructuralZone promoted[];
   ArrayResize(promoted, clusterCount);
   int promCount = 0;
   for(int i = 0; i < clusterCount; i++)
   {
      if(clusters[i].touch_count >= 2)
         promoted[promCount++] = clusters[i];
   }

   // Sort by total_strength descending (simple insertion sort — small array)
   for(int i = 1; i < promCount; i++)
   {
      StructuralZone key = promoted[i];
      int j = i - 1;
      while(j >= 0 && promoted[j].total_strength < key.total_strength)
      {
         promoted[j + 1] = promoted[j];
         j--;
      }
      promoted[j + 1] = key;
   }

   // Cap at SRE_MAX_ZONES
   outCount = MathMin(promCount, SRE_MAX_ZONES);
   ArrayResize(out, SRE_MAX_ZONES);
   for(int i = 0; i < outCount; i++)
      out[i] = promoted[i];
}

// ─────────────────────────────────────────────
//  Multi-TF confluence pass:
//  If a resistance zone from M5/M15 aligns within clusterThresh of an H1 zone, mark confluent.
// ─────────────────────────────────────────────

void SRE_MarkConfluence(StructuralZone &res[], int resCnt, StructuralZone &sup[], int supCnt, double thresh)
{
   // Resistance
   for(int i = 0; i < resCnt; i++)
      for(int j = i + 1; j < resCnt; j++)
         if(MathAbs(res[i].zone_mid - res[j].zone_mid) <= thresh)
         {
            res[i].multi_tf_confluent = true;
            res[j].multi_tf_confluent = true;
            res[i].confluence_score = 1.0;
            res[j].confluence_score = 1.0;
            // recompute strength
            res[i].total_strength = SRE_ComputeStrength(res[i]);
            res[j].total_strength = SRE_ComputeStrength(res[j]);
            SRE_AssignClass(res[i]);
            SRE_AssignClass(res[j]);
         }
   // Support
   for(int i = 0; i < supCnt; i++)
      for(int j = i + 1; j < supCnt; j++)
         if(MathAbs(sup[i].zone_mid - sup[j].zone_mid) <= thresh)
         {
            sup[i].multi_tf_confluent = true;
            sup[j].multi_tf_confluent = true;
            sup[i].confluence_score = 1.0;
            sup[j].confluence_score = 1.0;
            sup[i].total_strength = SRE_ComputeStrength(sup[i]);
            sup[j].total_strength = SRE_ComputeStrength(sup[j]);
            SRE_AssignClass(sup[i]);
            SRE_AssignClass(sup[j]);
         }
}

// ─────────────────────────────────────────────
//  Post-promotion semantics: crowding and openness
//  Must be called after ClusterAndPromote + MarkConfluence on both sides.
// ─────────────────────────────────────────────

void SRE_ComputePostPromotionSemantics(
   StructuralZone &res[], int resCnt,
   StructuralZone &sup[], int supCnt,
   double atrM15
)
{
   double crowdThresh = atrM15 * 3.0;

   // Crowding: how many peer zones within 3*ATR on the same side
   for(int i = 0; i < resCnt; i++)
   {
      int n = 0;
      for(int j = 0; j < resCnt; j++)
         if(i != j && MathAbs(res[i].zone_mid - res[j].zone_mid) <= crowdThresh) n++;
      res[i].crowding_penalty = MathMin(1.0, (double)n / 3.0);
   }
   for(int i = 0; i < supCnt; i++)
   {
      int n = 0;
      for(int j = 0; j < supCnt; j++)
         if(i != j && MathAbs(sup[i].zone_mid - sup[j].zone_mid) <= crowdThresh) n++;
      sup[i].crowding_penalty = MathMin(1.0, (double)n / 3.0);
   }

   // Openness: clear space on far side, normalized by 5*ATR
   // Resistance openness = distance to nearest support zone below it
   for(int i = 0; i < resCnt; i++)
   {
      double nearestGap = 0.0;
      for(int j = 0; j < supCnt; j++)
      {
         if(sup[j].zone_high < res[i].zone_low)
         {
            double gap = res[i].zone_low - sup[j].zone_high;
            if(nearestGap <= 0.0 || gap < nearestGap) nearestGap = gap;
         }
      }
      res[i].openness_score = (nearestGap > 0.0 && atrM15 > 0.0)
         ? MathMin(1.0, nearestGap / (atrM15 * 5.0))
         : 1.0; // no support below = fully open
   }
   // Support openness = distance to nearest resistance zone above it
   for(int i = 0; i < supCnt; i++)
   {
      double nearestGap = 0.0;
      for(int j = 0; j < resCnt; j++)
      {
         if(res[j].zone_low > sup[i].zone_high)
         {
            double gap = res[j].zone_low - sup[i].zone_high;
            if(nearestGap <= 0.0 || gap < nearestGap) nearestGap = gap;
         }
      }
      sup[i].openness_score = (nearestGap > 0.0 && atrM15 > 0.0)
         ? MathMin(1.0, nearestGap / (atrM15 * 5.0))
         : 1.0;
   }
}

// ─────────────────────────────────────────────
//  Main update entry point — call once per bar
// ─────────────────────────────────────────────

void SRE_UpdateZones(string symbol)
{
   datetime currentBar = (datetime)iTime(symbol, PERIOD_M15, 0);
   if(currentBar == gSREngineLastUpdatedBar) return;
   gSREngineLastUpdatedBar = currentBar;

   double atrM5  = SRE_GetATR(symbol, PERIOD_M5,  14);
   double atrM15 = SRE_GetATR(symbol, PERIOD_M15, 14);
   double atrH1  = SRE_GetATR(symbol, PERIOD_H1,  14);
   double atrH4  = SRE_GetATR(symbol, PERIOD_H4,  14);

   if(atrM15 <= 0.0) atrM15 = (atrM5 > 0.0 ? atrM5 * 2.0 : 0.001);

   double clusterThresh = atrM15 * 0.40;

   // Raw candidate pool: H4(8) + H1(12) + M15(16) + M5(12) = 48 max
   StructuralZone rawRes[];
   StructuralZone rawSup[];
   ArrayResize(rawRes, SRE_MAX_ZONES * 6);
   ArrayResize(rawSup, SRE_MAX_ZONES * 6);
   int rawResCount = 0, rawSupCount = 0;

   // H4 — macro context first: guaranteed pool entry, bounded lookback, quota=8
   double atrH4use = (atrH4 > 0.0 ? atrH4 : atrM15 * 8.0);
   SRE_ScanTF(symbol, PERIOD_H4,  3,  40, atrH4use, atrM15, rawRes, rawResCount, rawSup, rawSupCount, 8);

   // H1 — structural context: guaranteed pool entry, quota=12
   double atrH1use = (atrH1 > 0.0 ? atrH1 : atrM15 * 4.0);
   SRE_ScanTF(symbol, PERIOD_H1,  3,  80, atrH1use, atrM15, rawRes, rawResCount, rawSup, rawSupCount, 12);

   // M15 — primary structural timeframe, quota=16
   SRE_ScanTF(symbol, PERIOD_M15, 3, 200, atrM15,   atrM15, rawRes, rawResCount, rawSup, rawSupCount, 16);

   // M5 — secondary structural timeframe, quota=12
   double atrM5use = (atrM5 > 0.0 ? atrM5 : atrM15 * 0.5);
   SRE_ScanTF(symbol, PERIOD_M5,  3, 150, atrM5use, atrM15, rawRes, rawResCount, rawSup, rawSupCount, 12);

   // Cluster + promote (requires 2+ touches after clustering)
   SRE_ClusterAndPromote(rawRes, rawResCount, clusterThresh, gSRZonesResistance, gSRZonesResistanceCount);
   SRE_ClusterAndPromote(rawSup, rawSupCount, clusterThresh, gSRZonesSupport,    gSRZonesSupportCount);

   // Multi-TF confluence pass
   SRE_MarkConfluence(gSRZonesResistance, gSRZonesResistanceCount,
                      gSRZonesSupport,    gSRZonesSupportCount, clusterThresh);

   // Post-promotion semantics: crowding and openness
   SRE_ComputePostPromotionSemantics(gSRZonesResistance, gSRZonesResistanceCount,
                                      gSRZonesSupport,    gSRZonesSupportCount,
                                      atrM15);

   // Build SRE-side diagnostic summary
   gSRELastUpdateSummary = SRE_BuildDiagnosticSummary(rawResCount, rawSupCount);
}

// ─────────────────────────────────────────────
//  Query helpers — used by level_awareness_brake.mqh
// ─────────────────────────────────────────────

//  Returns the nearest STRONG/MAJOR resistance above price (0.0 if none)
double SRE_NearestStructuralResistance(double price, bool hardOnly)
{
   double best = 0.0;
   for(int i = 0; i < gSRZonesResistanceCount; i++)
   {
      StructuralZone z = gSRZonesResistance[i];
      if(z.status != ZONE_ACTIVE && z.status != ZONE_BREAK_RETEST) continue;
      if(hardOnly && z.strength_class < ZONE_STRONG) continue;
      if(z.zone_low <= price) continue;   // zone must be above current price
      if(best <= 0.0 || z.zone_low < best) best = z.zone_low;
   }
   return best;
}

//  Returns the nearest STRONG/MAJOR support below price (0.0 if none)
double SRE_NearestStructuralSupport(double price, bool hardOnly)
{
   double best = 0.0;
   for(int i = 0; i < gSRZonesSupportCount; i++)
   {
      StructuralZone z = gSRZonesSupport[i];
      if(z.status != ZONE_ACTIVE && z.status != ZONE_BREAK_RETEST) continue;
      if(hardOnly && z.strength_class < ZONE_STRONG) continue;
      if(z.zone_high >= price) continue;  // zone must be below current price
      if(best <= 0.0 || z.zone_high > best) best = z.zone_high;
   }
   return best;
}

//  Returns the nearest zone of any class above price for distance computation
double SRE_NearestResistanceAny(double price)
{
   double best = 0.0;
   for(int i = 0; i < gSRZonesResistanceCount; i++)
   {
      StructuralZone z = gSRZonesResistance[i];
      if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
      if(z.zone_low <= price) continue;
      if(best <= 0.0 || z.zone_low < best) best = z.zone_low;
   }
   return best;
}

double SRE_NearestSupportAny(double price)
{
   double best = 0.0;
   for(int i = 0; i < gSRZonesSupportCount; i++)
   {
      StructuralZone z = gSRZonesSupport[i];
      if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
      if(z.zone_high >= price) continue;
      if(best <= 0.0 || z.zone_high > best) best = z.zone_high;
   }
   return best;
}

// Returns the strength class of the nearest resistance above price (ZONE_WEAK if none)
StructuralZoneClass SRE_NearestResistanceClass(double price)
{
   double best = 0.0;
   StructuralZoneClass cls = ZONE_WEAK;
   for(int i = 0; i < gSRZonesResistanceCount; i++)
   {
      StructuralZone z = gSRZonesResistance[i];
      if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
      if(z.zone_low <= price) continue;
      if(best <= 0.0 || z.zone_low < best)
      {
         best = z.zone_low;
         cls  = z.strength_class;
      }
   }
   return cls;
}

StructuralZoneClass SRE_NearestSupportClass(double price)
{
   double best = 0.0;
   StructuralZoneClass cls = ZONE_WEAK;
   for(int i = 0; i < gSRZonesSupportCount; i++)
   {
      StructuralZone z = gSRZonesSupport[i];
      if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
      if(z.zone_high >= price) continue;
      if(best <= 0.0 || z.zone_high > best)
      {
         best = z.zone_high;
         cls  = z.strength_class;
      }
   }
   return cls;
}

// Returns credibility_score of nearest opposing zone
// direction: +1 = BUY (opposing = resistance above), -1 = SELL (opposing = support below)
double SRE_NearestOpposingCredibility(double price, int direction)
{
   double best = 0.0; double cred = 0.0;
   if(direction > 0)
   {
      for(int i = 0; i < gSRZonesResistanceCount; i++)
      {
         StructuralZone z = gSRZonesResistance[i];
         if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
         if(z.zone_low <= price) continue;
         if(best <= 0.0 || z.zone_low < best) { best = z.zone_low; cred = z.credibility_score; }
      }
   }
   else
   {
      for(int i = 0; i < gSRZonesSupportCount; i++)
      {
         StructuralZone z = gSRZonesSupport[i];
         if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
         if(z.zone_high >= price) continue;
         if(best <= 0.0 || z.zone_high > best) { best = z.zone_high; cred = z.credibility_score; }
      }
   }
   return cred;
}

double SRE_NearestOpposingFreshness(double price, int direction)
{
   double best = 0.0; double val = 0.0;
   if(direction > 0)
   {
      for(int i = 0; i < gSRZonesResistanceCount; i++)
      {
         StructuralZone z = gSRZonesResistance[i];
         if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
         if(z.zone_low <= price) continue;
         if(best <= 0.0 || z.zone_low < best) { best = z.zone_low; val = z.freshness_score; }
      }
   }
   else
   {
      for(int i = 0; i < gSRZonesSupportCount; i++)
      {
         StructuralZone z = gSRZonesSupport[i];
         if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
         if(z.zone_high >= price) continue;
         if(best <= 0.0 || z.zone_high > best) { best = z.zone_high; val = z.freshness_score; }
      }
   }
   return val;
}

double SRE_NearestOpposingOpenness(double price, int direction)
{
   double best = 0.0; double val = 0.0;
   if(direction > 0)
   {
      for(int i = 0; i < gSRZonesResistanceCount; i++)
      {
         StructuralZone z = gSRZonesResistance[i];
         if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
         if(z.zone_low <= price) continue;
         if(best <= 0.0 || z.zone_low < best) { best = z.zone_low; val = z.openness_score; }
      }
   }
   else
   {
      for(int i = 0; i < gSRZonesSupportCount; i++)
      {
         StructuralZone z = gSRZonesSupport[i];
         if(z.status == ZONE_BROKEN || z.status == ZONE_STALE) continue;
         if(z.zone_high >= price) continue;
         if(best <= 0.0 || z.zone_high > best) { best = z.zone_high; val = z.openness_score; }
      }
   }
   return val;
}

#endif // __STRUCTURAL_SR_ENGINE_MQH__
