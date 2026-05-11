#ifndef __STRATEGY_INTELLIGENCE_LAYER_V1_MQH__
#define __STRATEGY_INTELLIGENCE_LAYER_V1_MQH__

#include "core_market_data.mqh"
#include "regime_classification_layer_v1.mqh"
#include "market_regime.mqh"
#include "strategy_runtime.mqh"
#include "execution_estimator_v1.mqh"
#include "council_mode_types.mqh"

//---------------------------------------------------------
// Strategy Intelligence Layer v1 (rule-based, explainable)
// - Entry Quality Scoring
// - Strategy-Regime Fit Scoring
//---------------------------------------------------------
enum EntryQualityLabel
{
   EQ_HIGH_QUALITY_ENTRY = 0,
   EQ_ACCEPTABLE_ENTRY,
   EQ_WEAK_ENTRY,
   EQ_POOR_ENTRY,
   EQ_NO_ENTRY_EDGE
};

enum StrategyRegimeFitLabel
{
   SR_STRONG_REGIME_FIT = 0,
   SR_MODERATE_REGIME_FIT,
   SR_WEAK_REGIME_FIT,
   SR_CONTRADICTED_BY_REGIME
};

enum DecisionQualityLabel
{
   DQ_HIGH_QUALITY_DECISION = 0,
   DQ_GOOD_DECISION,
   DQ_MARGINAL_DECISION,
   DQ_LOW_QUALITY_DECISION,
   DQ_BLOCK_WORTHY_DECISION
};


enum EntryEdgeLabel
{
   EE_STRONG_ENTRY_EDGE = 0,
   EE_ADEQUATE_ENTRY_EDGE,
   EE_THIN_ENTRY_EDGE,
   EE_POOR_ENTRY_EDGE,
   EE_NEGATIVE_ENTRY_EDGE
};

enum FollowThroughQualityLabel
{
   FT_STRONG_FOLLOW_THROUGH = 0,
   FT_ACCEPTABLE_FOLLOW_THROUGH,
   FT_WEAK_FOLLOW_THROUGH,
   FT_COLLAPSING_FOLLOW_THROUGH
};

struct EntryEdgeResult
{
   double rr_location_score;          // 0..1 (RR proxy)
   double expected_sl_stress_score;   // 0..1 (higher = healthier space vs structure)
   double expected_tp_space_score;    // 0..1 (room-to-move proxy)
   double entry_edge_score;           // 0..1
   string entry_edge_label;           // STRONG_ENTRY_EDGE / ...
   string entry_edge_reason;          // short
};

struct FollowThroughQualityResult
{
   double follow_through_quality_score; // 0..1
   string follow_through_quality_label; // STRONG_FOLLOW_THROUGH / ...
   string follow_through_reason;        // short
};
struct EntryQualityResult
{
   double entry_quality_score;     // 0..1
   double timing_quality_score;    // 0..1
   double location_quality_score;  // 0..1
   double volatility_fit_score;    // 0..1
   string entry_quality_label;     // HIGH_QUALITY_ENTRY / ...
   string entry_quality_reason;    // short
   string entry_quality_flags;     // CSV flags
};

struct StrategyRegimeFitResult
{
   double strategy_regime_fit_score; // 0..1
   string strategy_regime_fit_label; // STRONG_REGIME_FIT / ...
   string strategy_regime_reason;    // short
};

struct DecisionQualityResult
{
   double decision_quality_score;  // 0..1
   string decision_quality_label;  // HIGH_QUALITY_DECISION / ...
   string decision_quality_reason; // short
};

double SI_Clamp(double v, double lo, double hi)
{
   if(v < lo) return lo;
   if(v > hi) return hi;
   return v;
}
double SI_Clamp01(double v) { return SI_Clamp(v, 0.0, 1.0); }

double SI_SafeDiv(double a, double b)
{
   if(MathAbs(b) < 1e-12) return 0.0;
   return a / b;
}

string SI_AppendFlag(string csv, string f)
{
   if(StringLen(csv) <= 0) return f;
   return csv + "," + f;
}

string SI_EntryLabelToText(EntryQualityLabel l)
{
   if(l == EQ_HIGH_QUALITY_ENTRY) return "HIGH_QUALITY_ENTRY";
   if(l == EQ_ACCEPTABLE_ENTRY)   return "ACCEPTABLE_ENTRY";
   if(l == EQ_WEAK_ENTRY)         return "WEAK_ENTRY";
   if(l == EQ_POOR_ENTRY)         return "POOR_ENTRY";
   return "NO_ENTRY_EDGE";
}

string SI_FitLabelToText(StrategyRegimeFitLabel l)
{
   if(l == SR_STRONG_REGIME_FIT)     return "STRONG_REGIME_FIT";
   if(l == SR_MODERATE_REGIME_FIT)   return "MODERATE_REGIME_FIT";
   if(l == SR_WEAK_REGIME_FIT)       return "WEAK_REGIME_FIT";
   return "CONTRADICTED_BY_REGIME";
}

string SI_DecisionQualityToText(DecisionQualityLabel l)
{
   if(l == DQ_HIGH_QUALITY_DECISION) return "HIGH_QUALITY_DECISION";
   if(l == DQ_GOOD_DECISION)         return "GOOD_DECISION";
   if(l == DQ_MARGINAL_DECISION)     return "MARGINAL_DECISION";
   if(l == DQ_LOW_QUALITY_DECISION)  return "LOW_QUALITY_DECISION";
   return "BLOCK_WORTHY_DECISION";
}


string SI_EntryEdgeLabelToText(EntryEdgeLabel l)
{
   if(l == EE_STRONG_ENTRY_EDGE)   return "STRONG_ENTRY_EDGE";
   if(l == EE_ADEQUATE_ENTRY_EDGE) return "ADEQUATE_ENTRY_EDGE";
   if(l == EE_THIN_ENTRY_EDGE)     return "THIN_ENTRY_EDGE";
   if(l == EE_POOR_ENTRY_EDGE)     return "POOR_ENTRY_EDGE";
   return "NEGATIVE_ENTRY_EDGE";
}

string SI_FollowThroughLabelToText(FollowThroughQualityLabel l)
{
   if(l == FT_STRONG_FOLLOW_THROUGH)     return "STRONG_FOLLOW_THROUGH";
   if(l == FT_ACCEPTABLE_FOLLOW_THROUGH) return "ACCEPTABLE_FOLLOW_THROUGH";
   if(l == FT_WEAK_FOLLOW_THROUGH)       return "WEAK_FOLLOW_THROUGH";
   return "COLLAPSING_FOLLOW_THROUGH";
}
bool SI_IsTradeDecision(RuntimeDecision d)
{
   return (d == RUNTIME_ENTER_BUY || d == RUNTIME_ENTER_SELL);
}

int SI_DirSign(RuntimeDecision d)
{
   if(d == RUNTIME_ENTER_BUY) return 1;
   if(d == RUNTIME_ENTER_SELL) return -1;
   return 0;
}

double SI_CandleEfficiency(CandleData &c)
{
   double r = c.high - c.low;
   if(r <= 0.0) return 0.0;
   return MathAbs(c.close - c.open) / r;
}

double SI_WickImbalance(CandleData &c)
{
   double upper = c.high - MathMax(c.open, c.close);
   double lower = MathMin(c.open, c.close) - c.low;
   double r = c.high - c.low;
   if(r <= 0.0) return 0.0;
   return (upper - lower) / r; // + upper dominates
}

bool SI_GetAtrPointsM5(double &atrPts)
{
   atrPts = 0.0;
   double atr = 0.0;
   if(!MR_GetATR(PERIOD_M5, 14, 1, atr))
      return false;
   atrPts = atr / _Point;
   if(atrPts <= 0.0) atrPts = 1.0;
   return true;
}

double SI_RangePositionM5(int lookbackBars, double price)
{
   int hiIdx = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, lookbackBars, 1);
   int loIdx = iLowest(_Symbol, PERIOD_M5, MODE_LOW, lookbackBars, 1);

   if(hiIdx < 0 || loIdx < 0) return 0.5;

   double hi = iHigh(_Symbol, PERIOD_M5, hiIdx);
   double lo = iLow(_Symbol, PERIOD_M5, loIdx);
   double r = hi - lo;
   if(r <= 0.0) return 0.5;
   return SI_Clamp01((price - lo) / r);
}

// Infer a coarse style tag for scoring (trend-follow vs mean-revert)
string SI_InferStyleTag(string activeMode, RegimeClassification &reg, RuntimeDecision d)
{
   string rl = reg.regime_label;

   if(activeMode == "COUNCIL")
   {
      // In council, prefer environment preferred style if present via regime label
      if(rl == "TREND_UP" || rl == "TREND_DOWN" || rl == "EXPANSION")
         return "TREND_FOLLOW";
      if(rl == "RANGE_BALANCED" || rl == "COMPRESSION")
         return "MEAN_REVERT";
   }

   if(rl == "TREND_UP" || rl == "TREND_DOWN" || rl == "EXPANSION")
      return "TREND_FOLLOW";

   if(rl == "RANGE_BALANCED" || rl == "RANGE_DIRTY" || rl == "COMPRESSION")
      return "MEAN_REVERT";

   if(rl == "REVERSAL_RISK")
      return "REVERSAL_CAUTION";

   return "NEUTRAL";
}

string SI_InferStyleTag(string activeMode, RegimeClassification &reg, RuntimeDecision d, CouncilZoneType council_zone_type)
{
   if(activeMode == "COUNCIL" &&
      council_zone_type != COUNCIL_ZONE_UNDEFINED &&
      council_zone_type != COUNCIL_ZONE_NO_TRADE)
   {
      if(council_zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
         council_zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION ||
         council_zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION)
         return "TREND_FOLLOW";

      if(council_zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM ||
         council_zone_type == COUNCIL_ZONE_RANGE_BALANCED ||
         council_zone_type == COUNCIL_ZONE_RANGE_DIRTY ||
         council_zone_type == COUNCIL_ZONE_COMPRESSION ||
         council_zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
         return "MEAN_REVERT";
   }

   return SI_InferStyleTag(activeMode, reg, d);
}

void SI_InitEntryQuality(EntryQualityResult &e)
{
   e.entry_quality_score    = 0.55;
   e.timing_quality_score   = 0.55;
   e.location_quality_score = 0.55;
   e.volatility_fit_score   = 0.55;
   e.entry_quality_label    = "ACCEPTABLE_ENTRY";
   e.entry_quality_reason   = "default";
   e.entry_quality_flags    = "";
}

void SI_InitFit(StrategyRegimeFitResult &f)
{
   f.strategy_regime_fit_score = 0.55;
   f.strategy_regime_fit_label = "MODERATE_REGIME_FIT";
   f.strategy_regime_reason    = "default";
}

void SI_InitDecisionQuality(DecisionQualityResult &d)
{
   d.decision_quality_score  = 0.55;
   d.decision_quality_label  = "GOOD_DECISION";
   d.decision_quality_reason = "default";
}


void SI_InitEntryEdge(EntryEdgeResult &e)
{
   e.rr_location_score = 0.50;
   e.expected_sl_stress_score = 0.50;
   e.expected_tp_space_score = 0.50;
   e.entry_edge_score = 0.50;
   e.entry_edge_label = "ADEQUATE_ENTRY_EDGE";
   e.entry_edge_reason = "default";
}

void SI_InitFollowThrough(FollowThroughQualityResult &f)
{
   f.follow_through_quality_score = 0.50;
   f.follow_through_quality_label = "ACCEPTABLE_FOLLOW_THROUGH";
   f.follow_through_reason = "default";
}

double SI_ComputeChurnM1(int barsLookback)
{
   int changes = 0;
   int lastSign = 0;

   for(int i = 1; i <= barsLookback; i++)
   {
      double o = iOpen(_Symbol, PERIOD_M1, i);
      double c = iClose(_Symbol, PERIOD_M1, i);
      int s = 0;
      if(c > o) s = 1;
      else if(c < o) s = -1;
      else continue;

      if(lastSign != 0 && s != lastSign) changes++;
      lastSign = s;
   }

   return SI_Clamp01((double)changes / (double)MathMax(1, barsLookback - 1));
}
void ComputeEntryQualityV1(
   TimeframeSnapshot &m1,
   RegimeClassification &reg,
   string activeMode,
   RuntimeDecision decision,
   CouncilZoneType council_zone_type,
   EntryQualityResult &out
)
{
   SI_InitEntryQuality(out);

   if(!SI_IsTradeDecision(decision))
   {
      out.entry_quality_score  = 0.50;
      out.entry_quality_label  = "NO_ENTRY_EDGE";
      out.entry_quality_reason = "non_trade_decision";
      return;
   }

   double atrPts = 0.0;
   if(!SI_GetAtrPointsM5(atrPts))
   {
      out.entry_quality_reason = "atr_unavailable";
      return;
   }

   int dir = SI_DirSign(decision);
   double price = m1.bar1.close;

   // Location: position within recent M5 range
   double pos = SI_RangePositionM5(24, price); // 2h on M5
   double location = 0.55;

   bool trendish, rangish;
   if(activeMode == "COUNCIL" && council_zone_type != COUNCIL_ZONE_UNDEFINED)
   {
      trendish = (council_zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
                  council_zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION ||
                  council_zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION);
      rangish  = (council_zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM ||
                  council_zone_type == COUNCIL_ZONE_RANGE_BALANCED ||
                  council_zone_type == COUNCIL_ZONE_RANGE_DIRTY ||
                  council_zone_type == COUNCIL_ZONE_COMPRESSION);
   }
   else
   {
      trendish = (reg.regime_label == "TREND_UP" || reg.regime_label == "TREND_DOWN" || reg.regime_label == "EXPANSION");
      rangish  = (reg.regime_label == "RANGE_BALANCED" || reg.regime_label == "RANGE_DIRTY" || reg.regime_label == "COMPRESSION");
   }

   if(rangish)
   {
      // Prefer buying low / selling high in ranges
      if(dir > 0) location = 1.0 - SI_Clamp01((pos - 0.25) / 0.75); // best near bottom quartile
      else        location = SI_Clamp01((pos) / 0.75);             // best near top quartile
      if(pos > 0.80 && dir > 0) out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "RANGE_BUY_TOO_HIGH");
      if(pos < 0.20 && dir < 0) out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "RANGE_SELL_TOO_LOW");
   }
   else if(trendish)
   {
      // Prefer not buying extreme exhaustion / not selling extreme
      if(dir > 0)
      {
         if(pos >= 0.92) { location -= 0.25; out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "LATE_AT_EXTREME"); }
         else if(pos >= 0.75) location += 0.05;
      }
      else
      {
         if(pos <= 0.08) { location -= 0.25; out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "LATE_AT_EXTREME"); }
         else if(pos <= 0.25) location += 0.05;
      }
   }

   // Timing: stretched move / wickiness / opposite candle
   double timing = 0.55;

   // Stretch vs ATR (M1 close relative to last 10 M1 range)
   int hi = iHighest(_Symbol, PERIOD_M1, MODE_HIGH, 10, 1);
   int lo = iLowest(_Symbol, PERIOD_M1, MODE_LOW, 10, 1);
   if(hi >= 0 && lo >= 0)
   {
      double r = iHigh(_Symbol, PERIOD_M1, hi) - iLow(_Symbol, PERIOD_M1, lo);
      double rPts = r / _Point;
      if(rPts > atrPts * 0.85)
      {
         timing -= 0.10;
         out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "STRETCHED_M1");
      }
   }

   // If last candle opposes direction with low efficiency -> worse timing
   bool opp = (dir > 0 && m1.bar1.close < m1.bar1.open) || (dir < 0 && m1.bar1.close > m1.bar1.open);
   double eff = SI_CandleEfficiency(m1.bar1);
   if(opp && eff <= 0.35)
   {
      timing -= 0.12;
      out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "OPPOSITE_CANDLE");
   }

   // Wick imbalance against direction
   double imb = SI_WickImbalance(m1.bar1);
   if((dir > 0 && imb > 0.20) || (dir < 0 && imb < -0.20))
   {
      timing -= 0.10;
      out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "WICK_AGAINST");
   }

   // Volatility fit
   double volFit = 0.55;
   if(reg.volatility_state == "HIGH_VOL") volFit -= 0.12;
   if(reg.volatility_state == "LOW_VOL")  volFit -= 0.06;
   if(reg.regime_label == "EXPANSION")    volFit -= 0.05;

   // Dirty structure penalty
   if(reg.structure_state == "NOISY" || reg.regime_label == "RANGE_DIRTY")
   {
      location -= 0.08;
      timing   -= 0.06;
      out.entry_quality_flags = SI_AppendFlag(out.entry_quality_flags, "DIRTY_ENV");
   }

   out.location_quality_score = SI_Clamp01(location);
   out.timing_quality_score   = SI_Clamp01(timing);
   out.volatility_fit_score   = SI_Clamp01(volFit);

   // Composite entry quality (conservative weights)
   out.entry_quality_score =
      SI_Clamp01(
         0.42 * out.location_quality_score +
         0.38 * out.timing_quality_score +
         0.20 * out.volatility_fit_score);

   // Label
   EntryQualityLabel lab = EQ_ACCEPTABLE_ENTRY;
   if(out.entry_quality_score >= 0.75) lab = EQ_HIGH_QUALITY_ENTRY;
   else if(out.entry_quality_score >= 0.55) lab = EQ_ACCEPTABLE_ENTRY;
   else if(out.entry_quality_score >= 0.35) lab = EQ_WEAK_ENTRY;
   else if(out.entry_quality_score >= 0.20) lab = EQ_POOR_ENTRY;
   else lab = EQ_NO_ENTRY_EDGE;

   out.entry_quality_label = SI_EntryLabelToText(lab);

   out.entry_quality_reason =
      "eq=" + DoubleToString(out.entry_quality_score, 2) +
      "|loc=" + DoubleToString(out.location_quality_score, 2) +
      "|tim=" + DoubleToString(out.timing_quality_score, 2) +
      "|volfit=" + DoubleToString(out.volatility_fit_score, 2) +
      "|pos=" + DoubleToString(pos, 2) +
      "|flags=" + out.entry_quality_flags;
}

void ComputeStrategyRegimeFitV1(
   RegimeClassification &reg,
   string activeMode,
   RuntimeDecision decision,
   StrategyRegimeFitResult &out
)
{
   ComputeStrategyRegimeFitV1(reg, activeMode, decision, COUNCIL_ZONE_UNDEFINED, out);
}

void ComputeStrategyRegimeFitV1(
   RegimeClassification &reg,
   string activeMode,
   RuntimeDecision decision,
   CouncilZoneType council_zone_type,
   StrategyRegimeFitResult &out
)
{
   SI_InitFit(out);

   if(!SI_IsTradeDecision(decision))
   {
      out.strategy_regime_fit_score = 0.50;
      out.strategy_regime_fit_label = "MODERATE_REGIME_FIT";
      out.strategy_regime_reason    = "non_trade_decision";
      return;
   }

   string style = SI_InferStyleTag(activeMode, reg, decision, council_zone_type);
   string rl = reg.regime_label;

   double score = 0.55;

   if(style == "TREND_FOLLOW")
   {
      if(rl == "TREND_UP" || rl == "TREND_DOWN") score += 0.20;
      else if(rl == "EXPANSION") score += 0.15;
      else if(rl == "RANGE_BALANCED") score -= 0.10;
      else if(rl == "RANGE_DIRTY") score -= 0.18;
      else if(rl == "COMPRESSION") score -= 0.12;
      else if(rl == "NO_TRADE") score -= 0.30;
      else if(rl == "REVERSAL_RISK") score -= 0.20;
   }
   else if(style == "MEAN_REVERT")
   {
      if(rl == "RANGE_BALANCED") score += 0.18;
      else if(rl == "COMPRESSION") score += 0.12;
      else if(rl == "RANGE_DIRTY") score -= 0.12;
      else if(rl == "TREND_UP" || rl == "TREND_DOWN") score -= 0.15;
      else if(rl == "EXPANSION") score -= 0.18;
      else if(rl == "NO_TRADE") score -= 0.30;
   }
   else if(style == "REVERSAL_CAUTION")
   {
      score -= 0.10;
      if(rl == "REVERSAL_RISK") score += 0.05;
   }

   // Tradability / confidence as mild modifiers
   score += (reg.tradability_score - 0.50) * 0.20;
   score += (reg.regime_confidence - 0.50) * 0.10;

   out.strategy_regime_fit_score = SI_Clamp01(score);

   StrategyRegimeFitLabel lab = SR_MODERATE_REGIME_FIT;
   if(out.strategy_regime_fit_score >= 0.78) lab = SR_STRONG_REGIME_FIT;
   else if(out.strategy_regime_fit_score >= 0.58) lab = SR_MODERATE_REGIME_FIT;
   else if(out.strategy_regime_fit_score >= 0.38) lab = SR_WEAK_REGIME_FIT;
   else lab = SR_CONTRADICTED_BY_REGIME;

   out.strategy_regime_fit_label = SI_FitLabelToText(lab);
   out.strategy_regime_reason =
      "style=" + style +
      "|fit=" + DoubleToString(out.strategy_regime_fit_score, 2) +
      "|reg=" + rl +
      "|trad=" + DoubleToString(reg.tradability_score, 2);
}

void ComputeDecisionQualityV1(
   double confidence_score,
   double regime_fit_score,
   EntryQualityResult &eq,
   StrategyRegimeFitResult &fit,
   double policy_risk_score,
   DecisionQualityResult &out
)
{
   SI_InitDecisionQuality(out);

   // Conservative envelope
   double q =
      0.40 * SI_Clamp01(confidence_score) +
      0.22 * SI_Clamp01(regime_fit_score) +
      0.22 * SI_Clamp01(eq.entry_quality_score) +
      0.12 * SI_Clamp01(fit.strategy_regime_fit_score) +
      0.04 * (1.0 - SI_Clamp01(policy_risk_score));

   out.decision_quality_score = SI_Clamp01(q);

   DecisionQualityLabel lab = DQ_GOOD_DECISION;
   if(out.decision_quality_score >= 0.80) lab = DQ_HIGH_QUALITY_DECISION;
   else if(out.decision_quality_score >= 0.65) lab = DQ_GOOD_DECISION;
   else if(out.decision_quality_score >= 0.50) lab = DQ_MARGINAL_DECISION;
   else if(out.decision_quality_score >= 0.35) lab = DQ_LOW_QUALITY_DECISION;
   else lab = DQ_BLOCK_WORTHY_DECISION;

   out.decision_quality_label = SI_DecisionQualityToText(lab);

   out.decision_quality_reason =
      "dq=" + DoubleToString(out.decision_quality_score, 2) +
      "|conf=" + DoubleToString(confidence_score, 2) +
      "|regfit=" + DoubleToString(regime_fit_score, 2) +
      "|eq=" + DoubleToString(eq.entry_quality_score, 2) +
      "|fit=" + DoubleToString(fit.strategy_regime_fit_score, 2) +
      "|prisk=" + DoubleToString(policy_risk_score, 2);
}


//---------------------------------------------------------
// Decision Quality v3: includes execution geometry estimation
//---------------------------------------------------------
void ComputeDecisionQualityV3(
   double confidence_score,
   double regime_fit_score,
   EntryQualityResult &eq,
   StrategyRegimeFitResult &fit,
   EntryEdgeResult &edge,
   FollowThroughQualityResult &ft,
   ExecutionEstimationResult &ee,
   double policy_risk_score,
   DecisionQualityResult &out
)
{
   SI_InitDecisionQuality(out);

   double geoScore = SI_Clamp01(ee.execution_geometry_score);
   double rrScore  = SI_Clamp01((ee.expected_rr_estimate - 0.80) / 1.40); // rr 0.8..2.2 -> 0..1
   double riskInv  = 1.0 - SI_Clamp01(ee.adverse_excursion_risk_score);

   double q =
      0.26 * SI_Clamp01(confidence_score) +
      0.13 * SI_Clamp01(regime_fit_score) +
      0.11 * SI_Clamp01(eq.entry_quality_score) +
      0.08 * SI_Clamp01(fit.strategy_regime_fit_score) +
      0.14 * SI_Clamp01(edge.entry_edge_score) +
      0.09 * SI_Clamp01(ft.follow_through_quality_score) +
      0.13 * geoScore +
      0.04 * rrScore +
      0.02 * riskInv +
      0.00 * (1.0 - SI_Clamp01(policy_risk_score));

   out.decision_quality_score = SI_Clamp01(q);

   DecisionQualityLabel lab = DQ_GOOD_DECISION;
   if(out.decision_quality_score >= 0.84) lab = DQ_HIGH_QUALITY_DECISION;
   else if(out.decision_quality_score >= 0.66) lab = DQ_GOOD_DECISION;
   else if(out.decision_quality_score >= 0.50) lab = DQ_MARGINAL_DECISION;
   else if(out.decision_quality_score >= 0.34) lab = DQ_LOW_QUALITY_DECISION;
   else lab = DQ_BLOCK_WORTHY_DECISION;

   out.decision_quality_label = SI_DecisionQualityToText(lab);

   out.decision_quality_reason =
      "dq3=" + DoubleToString(out.decision_quality_score, 2) +
      "|conf=" + DoubleToString(confidence_score, 2) +
      "|regfit=" + DoubleToString(regime_fit_score, 2) +
      "|eq=" + DoubleToString(eq.entry_quality_score, 2) +
      "|fit=" + DoubleToString(fit.strategy_regime_fit_score, 2) +
      "|edge=" + DoubleToString(edge.entry_edge_score, 2) +
      "|ft=" + DoubleToString(ft.follow_through_quality_score, 2) +
      "|geo=" + DoubleToString(ee.execution_geometry_score, 2) +
      "|rr=" + DoubleToString(ee.expected_rr_estimate, 2) +
      "|arisk=" + DoubleToString(ee.adverse_excursion_risk_score, 2);
}


void ComputeEntryEdgeV1(
   TimeframeSnapshot &m1,
   RegimeClassification &reg,
   RuntimeDecision decision,
   EntryEdgeResult &out
)
{
   SI_InitEntryEdge(out);

   if(!SI_IsTradeDecision(decision))
   {
      out.entry_edge_label = "NEGATIVE_ENTRY_EDGE";
      out.entry_edge_reason = "non_trade_decision";
      out.entry_edge_score = 0.15;
      return;
   }

   double atrPts = 0.0;
   if(!SI_GetAtrPointsM5(atrPts))
   {
      out.entry_edge_reason = "atr_unavailable";
      return;
   }

   int dir = SI_DirSign(decision);
   double price = m1.bar1.close;

   // Estimate expected stop stress using distance to recent M1 swing (proxy for structure)
   int lookback = 12;
   int hi = iHighest(_Symbol, PERIOD_M1, MODE_HIGH, lookback, 1);
   int lo = iLowest(_Symbol, PERIOD_M1, MODE_LOW, lookback, 1);

   double distToSwingPts = atrPts * 0.35;
   if(hi >= 0 && lo >= 0)
   {
      double swingHigh = iHigh(_Symbol, PERIOD_M1, hi);
      double swingLow  = iLow(_Symbol, PERIOD_M1, lo);

      if(dir > 0) distToSwingPts = (price - swingLow) / _Point;
      else        distToSwingPts = (swingHigh - price) / _Point;
   }

   // Normalize: >=0.65 ATR => good space; <=0.20 ATR => stressed
   double stress = SI_Clamp01((distToSwingPts / (atrPts * 0.65)));
   stress = SI_Clamp01(stress);

   // Estimate expected TP space using room-to-move in recent M5 range (proxy)
   int rLb = 24;
   int rHi = iHighest(_Symbol, PERIOD_M5, MODE_HIGH, rLb, 1);
   int rLo = iLowest(_Symbol, PERIOD_M5, MODE_LOW, rLb, 1);

   double tpSpacePts = atrPts * 0.55;
   if(rHi >= 0 && rLo >= 0)
   {
      double rh = iHigh(_Symbol, PERIOD_M5, rHi);
      double rl = iLow(_Symbol, PERIOD_M5, rLo);
      double rangePts = (rh - rl) / _Point;

      if(dir > 0) tpSpacePts = (rh - price) / _Point;
      else        tpSpacePts = (price - rl) / _Point;

      // guard tiny ranges
      if(rangePts > 0.0)
         tpSpacePts = MathMax(0.0, tpSpacePts);
   }

   // Normalize TP room: >=1.0 ATR => excellent; <=0.30 ATR => thin
   double tpSpace = SI_Clamp01((tpSpacePts / (atrPts * 1.00)));
   tpSpace = SI_Clamp01(tpSpace);

   // RR proxy: tpSpace / max(expectedStop, small)
   double expectedStopPts = MathMax(atrPts * 0.35, MathMin(distToSwingPts, atrPts * 0.90));
   double rr = SI_SafeDiv(tpSpacePts, expectedStopPts);
   double rrLoc = SI_Clamp01(rr / 2.0); // rr=2 => 1.0

   // Regime quality moderation (don't overclaim edge in dirty/no_trade)
   double regMod = 0.0;
   if(reg.regime_label == "NO_TRADE") regMod -= 0.20;
   if(reg.regime_label == "RANGE_DIRTY") regMod -= 0.10;
   if(reg.regime_label == "REVERSAL_RISK") regMod -= 0.08;
   regMod += (reg.tradability_score - 0.50) * 0.10;

   out.rr_location_score = rrLoc;
   out.expected_sl_stress_score = stress;
   out.expected_tp_space_score = tpSpace;

   double edge = 0.46 * rrLoc + 0.28 * stress + 0.26 * tpSpace + regMod;
   out.entry_edge_score = SI_Clamp01(edge);

   EntryEdgeLabel lab = EE_ADEQUATE_ENTRY_EDGE;
   if(out.entry_edge_score >= 0.78) lab = EE_STRONG_ENTRY_EDGE;
   else if(out.entry_edge_score >= 0.60) lab = EE_ADEQUATE_ENTRY_EDGE;
   else if(out.entry_edge_score >= 0.42) lab = EE_THIN_ENTRY_EDGE;
   else if(out.entry_edge_score >= 0.28) lab = EE_POOR_ENTRY_EDGE;
   else lab = EE_NEGATIVE_ENTRY_EDGE;

   out.entry_edge_label = SI_EntryEdgeLabelToText(lab);

   out.entry_edge_reason =
      "edge=" + DoubleToString(out.entry_edge_score, 2) +
      "|rr=" + DoubleToString(rrLoc, 2) +
      "|stress=" + DoubleToString(stress, 2) +
      "|tp=" + DoubleToString(tpSpace, 2) +
      "|atrPts=" + DoubleToString(atrPts, 0);
}

void ComputeFollowThroughQualityV1(
   TimeframeSnapshot &m1,
   RegimeClassification &reg,
   RuntimeDecision decision,
   FollowThroughQualityResult &out
)
{
   SI_InitFollowThrough(out);

   if(!SI_IsTradeDecision(decision))
   {
      out.follow_through_quality_label = "WEAK_FOLLOW_THROUGH";
      out.follow_through_reason = "non_trade_decision";
      out.follow_through_quality_score = 0.40;
      return;
   }

   int dir = SI_DirSign(decision);

   double eff = SI_CandleEfficiency(m1.bar1);
   double imb = SI_WickImbalance(m1.bar1);

   // Close location within candle
   double r = m1.bar1.high - m1.bar1.low;
   double closePos = 0.5;
   if(r > 0.0) closePos = (m1.bar1.close - m1.bar1.low) / r; // 0..1

   double cl = 0.55;
   if(dir > 0)
   {
      if(closePos >= 0.75) cl += 0.10;
      if(closePos <= 0.35) cl -= 0.12;
      if(imb > 0.20) cl -= 0.10;
   }
   else
   {
      if(closePos <= 0.25) cl += 0.10;
      if(closePos >= 0.65) cl -= 0.12;
      if(imb < -0.20) cl -= 0.10;
   }

   double churn = SI_ComputeChurnM1(7);
   cl -= churn * 0.18;

   // Alignment with regime bias
   double align = 0.0;
   if(reg.trend_bias * (double)dir >= 0.25) align = 0.08;
   else if(reg.trend_bias * (double)dir <= -0.15) align = -0.10;

   // Avoid overclaiming in dirty/no_trade
   double env = 0.0;
   if(reg.structure_state == "NOISY") env -= 0.08;
   if(reg.regime_label == "RANGE_DIRTY") env -= 0.08;
   if(reg.regime_label == "NO_TRADE") env -= 0.18;

   double score = 0.36 * SI_Clamp01(eff) + 0.44 * SI_Clamp01(cl) + 0.20 * SI_Clamp01(reg.tradability_score) + align + env;
   out.follow_through_quality_score = SI_Clamp01(score);

   FollowThroughQualityLabel lab = FT_ACCEPTABLE_FOLLOW_THROUGH;
   if(out.follow_through_quality_score >= 0.78) lab = FT_STRONG_FOLLOW_THROUGH;
   else if(out.follow_through_quality_score >= 0.58) lab = FT_ACCEPTABLE_FOLLOW_THROUGH;
   else if(out.follow_through_quality_score >= 0.40) lab = FT_WEAK_FOLLOW_THROUGH;
   else lab = FT_COLLAPSING_FOLLOW_THROUGH;

   out.follow_through_quality_label = SI_FollowThroughLabelToText(lab);

   out.follow_through_reason =
      "ft=" + DoubleToString(out.follow_through_quality_score, 2) +
      "|eff=" + DoubleToString(eff, 2) +
      "|clpos=" + DoubleToString(closePos, 2) +
      "|churn=" + DoubleToString(churn, 2) +
      "|align=" + DoubleToString(align, 2);
}

void ComputeDecisionQualityV2(
   double confidence_score,
   double regime_fit_score,
   EntryQualityResult &eq,
   StrategyRegimeFitResult &fit,
   EntryEdgeResult &edge,
   FollowThroughQualityResult &ft,
   double policy_risk_score,
   DecisionQualityResult &out
)
{
   SI_InitDecisionQuality(out);

   double q =
      0.32 * SI_Clamp01(confidence_score) +
      0.16 * SI_Clamp01(regime_fit_score) +
      0.14 * SI_Clamp01(eq.entry_quality_score) +
      0.10 * SI_Clamp01(fit.strategy_regime_fit_score) +
      0.16 * SI_Clamp01(edge.entry_edge_score) +
      0.10 * SI_Clamp01(ft.follow_through_quality_score) +
      0.02 * (1.0 - SI_Clamp01(policy_risk_score));

   out.decision_quality_score = SI_Clamp01(q);

   DecisionQualityLabel lab = DQ_GOOD_DECISION;
   if(out.decision_quality_score >= 0.82) lab = DQ_HIGH_QUALITY_DECISION;
   else if(out.decision_quality_score >= 0.66) lab = DQ_GOOD_DECISION;
   else if(out.decision_quality_score >= 0.50) lab = DQ_MARGINAL_DECISION;
   else if(out.decision_quality_score >= 0.34) lab = DQ_LOW_QUALITY_DECISION;
   else lab = DQ_BLOCK_WORTHY_DECISION;

   out.decision_quality_label = SI_DecisionQualityToText(lab);

   out.decision_quality_reason =
      "dq2=" + DoubleToString(out.decision_quality_score, 2) +
      "|conf=" + DoubleToString(confidence_score, 2) +
      "|regfit=" + DoubleToString(regime_fit_score, 2) +
      "|eq=" + DoubleToString(eq.entry_quality_score, 2) +
      "|fit=" + DoubleToString(fit.strategy_regime_fit_score, 2) +
      "|edge=" + DoubleToString(edge.entry_edge_score, 2) +
      "|ft=" + DoubleToString(ft.follow_through_quality_score, 2) +
      "|prisk=" + DoubleToString(policy_risk_score, 2);
}

#endif
