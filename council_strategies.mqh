#ifndef __COUNCIL_STRATEGIES_MQH__
#define __COUNCIL_STRATEGIES_MQH__

#include "council_mode_types.mqh"
#include "council_environment.mqh"
#include "strategy_runtime.mqh"

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
double CouncilClamp01_Strategy(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

double CouncilAvg2(double a, double b)
{
   return (a + b) / 2.0;
}

double CouncilAvg3(double a, double b, double c)
{
   return (a + b + c) / 3.0;
}

bool CouncilIsBullTrend()
{
   return (RT_M1TrendBull() || RT_M5TrendBull());
}

bool CouncilIsBearTrend()
{
   return (RT_M1TrendBear() || RT_M5TrendBear());
}

double CouncilEnvironmentFitBuy(CouncilEnvironmentReport &env)
{
   double fit = env.total_score;

   if(env.structure_ok)
      fit += 0.05;

   if(env.momentum_ok)
      fit += 0.05;

   if(env.preferred_style == COUNCIL_STYLE_REVERSAL ||
      env.preferred_style == COUNCIL_STYLE_MEAN_RECLAIM)
      fit += 0.03;

   return CouncilClamp01_Strategy(fit);
}

double CouncilEnvironmentFitSell(CouncilEnvironmentReport &env)
{
   double fit = env.total_score;

   if(env.structure_ok)
      fit += 0.05;

   if(env.momentum_ok)
      fit += 0.05;

   if(env.preferred_style == COUNCIL_STYLE_REVERSAL ||
      env.preferred_style == COUNCIL_STYLE_MEAN_RECLAIM)
      fit += 0.03;

   return CouncilClamp01_Strategy(fit);
}

double CouncilConflictFromDirectionBias(string bias, CouncilDecision d)
{
   bias = TrimString(bias);

   if(bias == "BOTH" || bias == "")
      return 0.0;

   if(bias == "BUY_ONLY" && d == COUNCIL_DECISION_SELL)
      return 0.35;

   if(bias == "SELL_ONLY" && d == COUNCIL_DECISION_BUY)
      return 0.35;

   return 0.0;
}

string CouncilDecisionReasonText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)
      return "BUY";

   if(d == COUNCIL_DECISION_SELL)
      return "SELL";

   if(d == COUNCIL_DECISION_REJECT)
      return "REJECT";

   return "WAIT";
}


//---------------------------------------------------------
// Range helpers (Phase B1 — Range Core Pack)
//---------------------------------------------------------
bool CouncilIsRangeContext(CouncilEnvironmentReport &env)
{
   if(env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)
      return true;

   // fallback: runtime regime summary includes trend_state token like "RANGE|..."
   if(CouncilStringContains(env.regime_summary, "RANGE"))
      return true;

   return false;
}

bool CouncilGetRecentRangeBounds(ENUM_TIMEFRAMES tf, int lookbackBars, int startShift,
                                 double &rangeHigh, double &rangeLow)
{
   rangeHigh = 0.0;
   rangeLow  = 0.0;

   if(lookbackBars <= 5)
      return false;

   int hiIndex = iHighest(_Symbol, tf, MODE_HIGH, lookbackBars, startShift);
   int loIndex = iLowest(_Symbol, tf, MODE_LOW,  lookbackBars, startShift);

   if(hiIndex < 0 || loIndex < 0)
      return false;

   rangeHigh = iHigh(_Symbol, tf, hiIndex);
   rangeLow  = iLow(_Symbol, tf, loIndex);

   return (rangeHigh > rangeLow && rangeLow > 0.0);
}

double CouncilGetATRPoints(ENUM_TIMEFRAMES tf, int period, int shift)
{
   int h = iATR(_Symbol, tf, period);
   if(h == INVALID_HANDLE)
      return 0.0;

   double v = 0.0;
   double buf[];
   ArraySetAsSeries(buf, true);
   if(CopyBuffer(h, 0, shift, 1, buf) == 1)
      v = buf[0];
   IndicatorRelease(h);

   if(v <= 0.0 || _Point <= 0.0)
      return 0.0;

   return v / _Point;
}
//---------------------------------------------------------
// Zone / role routing helpers
//---------------------------------------------------------

//---------------------------------------------------------
// Zone semantics inference (Phase: Family/Zone Internal Alignment)
//---------------------------------------------------------
// Keeps backward compatibility: no changes to env building, only local interpretation.
string CouncilInferZoneSemantic(CouncilEnvironmentReport &env)
{
   // Highest confidence: explicit zone_type
   if(env.zone_type == COUNCIL_ZONE_NO_TRADE)            return "NO_TRADE";
   if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION)  return "TREND_CONTINUATION";
   if(env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION) return "REVERSAL_EXHAUSTION";
   if(env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)  return "RANGE_MEAN_RECLAIM";
   if(env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)    return "EXPANSION_BREAKOUT";
   if(env.zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION) return "EXPANSION_CONTINUATION";
   if(env.zone_type == COUNCIL_ZONE_COMPRESSION)           return "COMPRESSION";
   if(env.zone_type == COUNCIL_ZONE_RANGE_BALANCED)        return "RANGE_BALANCED";
   if(env.zone_type == COUNCIL_ZONE_RANGE_DIRTY)           return "RANGE_DIRTY";

   // Fallback: text semantics (used by existing regime_summary / zone_name)
   string rs = env.regime_summary;
   string zn = env.zone_name;

   if(CouncilStringContains(rs, "COMPRESSION") || CouncilStringContains(zn, "COMPRESSION"))
      return "COMPRESSION";

   if(CouncilStringContains(rs, "EXPANSION") || CouncilStringContains(zn, "EXPANSION"))
   {
      if(CouncilStringContains(rs, "CONTINUATION") || CouncilStringContains(zn, "CONTINUATION"))
         return "EXPANSION_CONTINUATION";
      if(CouncilStringContains(rs, "MICRO") || CouncilStringContains(zn, "MICRO"))
         return "MICRO_RANGE_EXPANSION";
      return "EXPANSION_BREAKOUT";
   }

   // Range subtypes (text-only; do NOT alter zone_type)
   if(CouncilStringContains(rs, "RANGE_DIRTY") || CouncilStringContains(zn, "RANGE_DIRTY"))
      return "RANGE_DIRTY";
   if(CouncilStringContains(rs, "RANGE_BALANCED") || CouncilStringContains(zn, "RANGE_BALANCED"))
      return "RANGE_BALANCED";

   // Trend pullback subtype hint
   if(CouncilStringContains(rs, "PULLBACK") || CouncilStringContains(zn, "PULLBACK"))
      return "TREND_PULLBACK";

   return "UNSPECIFIED";
}

//---------------------------------------------------------
// Zone coverage awareness (passive only)
//---------------------------------------------------------
double CouncilSafeDiv(double num, double den)
{
   if(den <= 0.0) return 0.0;
   return num / den;
}

bool BuildZoneCoverageReport(
   CouncilStrategyReport &reports[],
   int reportCount,
   CouncilEnvironmentReport &env,
   ZoneCoverageReport &out
)
{
   out.zone_semantic = CouncilInferZoneSemantic(env);

   out.total_strategies  = reportCount;
   out.active_strategies = 0;

   out.aligned_count  = 0;
   out.opposing_count = 0;
   out.neutral_count  = 0;

   out.diversity_score      = 0.0;
   out.concentration_score  = 0.0;
   out.dominant_family      = "";
   out.dominant_strategy    = "";

   out.has_conflict  = false;
   out.weak_coverage = false;
   out.over_crowded  = false;

   out.coverage_label  = "NO_COVERAGE";
   out.coverage_reason = "no active strategies";

   // Votes by direction (BUY/SELL only).
   double buy_votes  = 0.0;
   double sell_votes = 0.0;

   // Dominant strategy selection (by vote contribution).
   double best_vote_mag = -1.0;
   int best_idx = -1;

   // Unique family counting among active strategies.
   string families[64];
   int familyCount = 0;

   for(int i = 0; i < reportCount; i++)
   {
      CouncilStrategyReport r = reports[i];
      if(!r.valid || !r.enabled) continue;

      if(r.decision != COUNCIL_DECISION_WAIT)
      {
         out.active_strategies++;

         // family set
         string fam = r.strategy_family;
         bool seen = false;
         for(int k = 0; k < familyCount; k++)
            if(families[k] == fam) { seen = true; break; }
         if(!seen && familyCount < 64)
            families[familyCount++] = fam;
      }

      if(r.decision == COUNCIL_DECISION_BUY || r.decision == COUNCIL_DECISION_SELL)
      {
         double v = r.vote_weight * r.score_final;
         double mag = MathAbs(v);

         if(r.decision == COUNCIL_DECISION_BUY)  buy_votes  += mag;
         if(r.decision == COUNCIL_DECISION_SELL) sell_votes += mag;

         if(mag > best_vote_mag)
         {
            best_vote_mag = mag;
            best_idx = i;
         }
      }
   }

   // Diversity score: unique families among active / active count
   if(out.active_strategies > 0)
      out.diversity_score = CouncilSafeDiv((double)familyCount, (double)out.active_strategies);

   // Dominant direction & concentration
   double total_votes = buy_votes + sell_votes;
   double max_votes   = MathMax(buy_votes, sell_votes);
   if(total_votes > 0.0)
      out.concentration_score = CouncilSafeDiv(max_votes, total_votes);
   else
      out.concentration_score = 0.0;

   CouncilDecision dominant_dir = COUNCIL_DECISION_WAIT;
   if(buy_votes > sell_votes) dominant_dir = COUNCIL_DECISION_BUY;
   else if(sell_votes > buy_votes) dominant_dir = COUNCIL_DECISION_SELL;

   // aligned/opposing/neutral counts vs dominant direction (REJECT treated neutral)
   for(int i = 0; i < reportCount; i++)
   {
      CouncilStrategyReport r = reports[i];
      if(!r.valid || !r.enabled) continue;
      if(r.decision == COUNCIL_DECISION_WAIT) continue;

      if(dominant_dir == COUNCIL_DECISION_WAIT)
      {
         out.neutral_count++;
         continue;
      }

      if(r.decision == dominant_dir)
         out.aligned_count++;
      else if(r.decision == COUNCIL_DECISION_BUY || r.decision == COUNCIL_DECISION_SELL)
         out.opposing_count++;
      else
         out.neutral_count++;
   }

   out.has_conflict  = (out.aligned_count > 0 && out.opposing_count > 0);
   out.weak_coverage = (out.active_strategies <= 1);
   out.over_crowded  = (out.active_strategies >= 5);

   if(best_idx >= 0)
   {
      out.dominant_strategy = reports[best_idx].strategy_id;
      out.dominant_family   = reports[best_idx].strategy_family;
   }

   // Coverage classification
   if(out.active_strategies == 0)
   {
      out.coverage_label  = "NO_COVERAGE";
      out.coverage_reason = "no active strategies";
   }
   else if(out.weak_coverage)
   {
      out.coverage_label  = "WEAK";
      out.coverage_reason = "single strategy active → weak coverage";
   }
   else if(out.over_crowded)
   {
      out.coverage_label  = "OVERCROWDED";
      out.coverage_reason = "many strategies active → potential crowding";
   }
   else if(out.has_conflict)
   {
      out.coverage_label  = "CONFLICTED";
      out.coverage_reason = "aligned and opposing strategies both active";
   }
   else if(out.diversity_score > 0.6)
   {
      out.coverage_label  = "STRONG_DIVERSE";
      out.coverage_reason = "multiple families active with good diversity";
   }
   else
   {
      out.coverage_label  = "BALANCED";
      out.coverage_reason = "coverage balanced";
   }

   return true;
}


double CouncilZoneAlignmentScore(
   CouncilEnvironmentReport &env,
   CouncilStrategyRole role,
   string strategyFamily
)
{
   double score = 0.35;

   // zone style alignment
   string z = CouncilInferZoneSemantic(env);

   if(z == "REVERSAL_EXHAUSTION")
   {
      if(role == COUNCIL_ROLE_SCOUT || role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.95;
      else if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.90;
      else if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.45;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.80;
   }
   else if(z == "RANGE_MEAN_RECLAIM")
   {
      if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.95;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.82;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.78;
      else if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.40;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.80;
   }
   else if(z == "RANGE_BALANCED")
   {
      if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.93;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.80;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.70;
      else if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.42;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.78;
   }
   else if(z == "RANGE_DIRTY")
   {
      // dirty ranges: guards & confirms matter more, scouts less.
      if(role == COUNCIL_ROLE_GUARD)
         score = 0.88;
      else if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.82;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.70;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.62;
      else if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.38;
   }
   else if(z == "COMPRESSION")
   {
      // compression: scouting + confirmation are valuable, trend judge neutral.
      if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.88;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.86;
      else if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.62;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.45;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.78;
   }
   else if(z == "EXPANSION_CONTINUATION")
   {
      if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.94;
      else if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.70;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.46;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.40;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.76;
   }
   else if(z == "EXPANSION_BREAKOUT" || z == "MICRO_RANGE_EXPANSION")
   {
      if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = 0.92;
      else if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.68;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.48;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.38;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.76;
   }
   else if(z == "TREND_CONTINUATION" || z == "TREND_PULLBACK")
   {
      if(role == COUNCIL_ROLE_TREND_JUDGE)
         score = (z == "TREND_PULLBACK") ? 0.93 : 0.96;
      else if(role == COUNCIL_ROLE_CONFIRM)
         score = 0.72;
      else if(role == COUNCIL_ROLE_SCOUT)
         score = 0.45;
      else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
         score = 0.42;
      else if(role == COUNCIL_ROLE_GUARD)
         score = 0.78;
   }
   else if(z == "NO_TRADE")
   {
      if(role == COUNCIL_ROLE_GUARD)
         score = 0.70;
      else
         score = 0.10;
   }

   // family fine tuning
   if(strategyFamily == "LIQUIDITY_REVERSAL" && (env.reversal_bias || env.sweep_context_ok))
      score += 0.04;

   if(strategyFamily == "MEAN_RECLAIM" && (z == "RANGE_MEAN_RECLAIM" || z == "RANGE_BALANCED"))
      score += 0.05;

   if(strategyFamily == "TREND_CONTINUATION" && env.continuation_bias)
      score += 0.05;

   if(strategyFamily == "TREND_PULLBACK_CONTINUATION" && (z == "TREND_PULLBACK" || (z == "TREND_CONTINUATION" && CouncilStringContains(env.regime_summary, "PULLBACK"))))
      score += 0.04;

   if(strategyFamily == "MOMENTUM_REVERSAL_ASSIST" && env.exhaustion_hint)
      score += 0.05;

   if(strategyFamily == "COMPRESSION_BREAKOUT" && z == "COMPRESSION")
      score += 0.05;

   if(strategyFamily == "VOL_BREAKOUT" && z == "EXPANSION_BREAKOUT")
      score += 0.05;

   if(strategyFamily == "EXPANSION_CONTINUATION" && z == "EXPANSION_CONTINUATION")
      score += 0.05;

   if(strategyFamily == "MICRO_RANGE_BREAK" && (z == "MICRO_RANGE_EXPANSION" || z == "EXPANSION_CONTINUATION"))
      score += 0.04;
return CouncilClamp01_Strategy(score);
}

double CouncilPriorityScoreFromZone(
   CouncilEnvironmentReport &env,
   CouncilStrategyRole role,
   string strategyFamily
)
{
   double p = CouncilZoneAlignmentScore(env, role, strategyFamily);

   if(env.zone_confidence > 0.0)
      p = CouncilClamp01_Strategy((p * 0.75) + (env.zone_confidence * 0.25));

   return p;
}

void CouncilAssignStrategyMeta(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r,
   CouncilStrategyRole role
)
{
   r.role      = role;
   r.role_name = CouncilStrategyRoleToText(role);
   r.zone_name = env.zone_name;

   r.zone_alignment_score = CouncilZoneAlignmentScore(env, role, r.strategy_family);
   r.priority_score       = CouncilPriorityScoreFromZone(env, role, r.strategy_family);

   r.eligible_for_zone = true;
   r.observe_only      = false;
   r.blocked_by_zone   = false;
   r.zone_block_reason = "";

   // hard routing by no-trade zone
   if(env.zone_type == COUNCIL_ZONE_NO_TRADE)
   {
      if(role == COUNCIL_ROLE_GUARD)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_OBSERVE_ONLY;
         r.observe_only = true;
      }
      else
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_BLOCKED;
         r.blocked_by_zone = true;
         r.eligible_for_zone = false;
         r.zone_block_reason = "Environment zone is NO_TRADE";
      }

      r.eligibility_text = CouncilEligibilityStateToText(r.eligibility_state);
      return;
   }

   // role-specific routing
   if(role == COUNCIL_ROLE_SCOUT)
   {
      if(env.preferred_style == COUNCIL_STYLE_REVERSAL ||
         env.preferred_style == COUNCIL_STYLE_MEAN_RECLAIM)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_ACTIVE;
      }
      else if(env.preferred_style == COUNCIL_STYLE_CONTINUATION ||
              env.preferred_style == COUNCIL_STYLE_BREAKOUT)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_REDUCED;
      }
      else
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_OBSERVE_ONLY;
      }
   }
   else if(role == COUNCIL_ROLE_CONFIRM)
   {
      if(env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM ||
         env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_ACTIVE;
      }
      else if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
              env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_REDUCED;
      }
      else
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_OBSERVE_ONLY;
      }
   }
   else if(role == COUNCIL_ROLE_TREND_JUDGE)
   {
      if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
         env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_ACTIVE;
      }
      else if(env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION ||
              env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_OBSERVE_ONLY;
      }
      else
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_REDUCED;
      }
   }
   else if(role == COUNCIL_ROLE_EXHAUSTION_JUDGE)
   {
      if(env.zone_type == COUNCIL_ZONE_REVERSAL_EXHAUSTION)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_ACTIVE;
      }
      else if(env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_REDUCED;
      }
      else if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION ||
              env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_OBSERVE_ONLY;
      }
      else
      {
         r.eligibility_state = COUNCIL_ELIGIBILITY_REDUCED;
      }
   }
   else if(role == COUNCIL_ROLE_GUARD)
   {
      r.eligibility_state = COUNCIL_ELIGIBILITY_OBSERVE_ONLY;
      r.observe_only = true;
   }
   else
   {
      r.eligibility_state = COUNCIL_ELIGIBILITY_REDUCED;
   }

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
   {
      r.blocked_by_zone = true;
      r.eligible_for_zone = false;
   }

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      r.observe_only = true;

   r.eligibility_text = CouncilEligibilityStateToText(r.eligibility_state);
}

double CouncilApplyEligibilityWeight(
   CouncilStrategyReport &r,
   double rawWeight
)
{
   if(r.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
      return 0.0;

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      return 0.0;

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
      return rawWeight * 0.60;

   return rawWeight;
}

double CouncilApplyZoneAdjustedScore(
   CouncilStrategyReport &r,
   double rawScore
)
{
   double adjusted = rawScore;

   adjusted = adjusted * (0.60 + (r.zone_alignment_score * 0.40));
   adjusted = adjusted * (0.65 + (r.priority_score * 0.35));

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)
      adjusted *= 0.75;

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY)
      adjusted *= 0.10;

   if(r.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)
      adjusted = 0.0;

   return CouncilClamp01_Strategy(adjusted);
}

void CouncilFinalizeStrategyReport(CouncilStrategyReport &r)
{
   r.trigger_quality      = CouncilClamp01_Strategy(r.trigger_quality);
   r.confirmation_quality = CouncilClamp01_Strategy(r.confirmation_quality);
   r.environment_fit      = CouncilClamp01_Strategy(r.environment_fit);
   r.conflict_score       = CouncilClamp01_Strategy(r.conflict_score);
   r.zone_alignment_score = CouncilClamp01_Strategy(r.zone_alignment_score);
   r.priority_score       = CouncilClamp01_Strategy(r.priority_score);
   r.score_final          = CouncilClamp01_Strategy(r.score_final);

   if(r.vote_weight <= 0.0)
      r.vote_weight = 1.0;

   r.valid = true;
}



//---------------------------------------------------------
// Compression + Expansion helpers (Phase C)
//---------------------------------------------------------
bool CouncilIsCompressionContext(CouncilEnvironmentReport &env)
{
   if(env.zone_type == COUNCIL_ZONE_COMPRESSION)
      return true;

   // Prefer explicit regime label text. Zone COMPRESSION may not exist in baseline.
   if(CouncilStringContains(env.regime_summary, "COMPRESSION"))
      return true;

   if(CouncilStringContains(env.zone_name, "COMPRESSION"))
      return true;

   return false;
}

bool CouncilIsExpansionContext(CouncilEnvironmentReport &env)
{
   if(env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION || env.zone_type == COUNCIL_ZONE_EXPANSION_CONTINUATION)

      return true;

   if(CouncilStringContains(env.regime_summary, "EXPANSION"))
      return true;

   if(CouncilStringContains(env.zone_name, "EXPANSION"))
      return true;

   return false;
}

bool CouncilIsCompressionOrExpansionAllowedZone(CouncilEnvironmentReport &env)
{
   // Hard guard: do NOT run Phase C strategies in trend continuation / range / no-trade.
   if(env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION) return false;
   if(env.zone_type == COUNCIL_ZONE_RANGE_MEAN_RECLAIM) return false;
   if(env.zone_type == COUNCIL_ZONE_NO_TRADE) return false;
   return (CouncilIsCompressionContext(env) || CouncilIsExpansionContext(env));
}

double CouncilCandleBodyPoints(ENUM_TIMEFRAMES tf, int shift)
{
   double o = iOpen(_Symbol, tf, shift);
   double c = iClose(_Symbol, tf, shift);
   if(_Point <= 0.0) return 0.0;
   return MathAbs(c - o) / _Point;
}

bool CouncilCloseBreaksRange(ENUM_TIMEFRAMES tf, int shift,
                            double rangeHigh, double rangeLow,
                            double bufferPts,
                            CouncilDecision &d)
{
   double c = iClose(_Symbol, tf, shift);

   if(c > (rangeHigh + bufferPts * _Point))
   {
      d = COUNCIL_DECISION_BUY;
      return true;
   }

   if(c < (rangeLow - bufferPts * _Point))
   {
      d = COUNCIL_DECISION_SELL;
      return true;
   }

   d = COUNCIL_DECISION_WAIT;
   return false;
}

//---------------------------------------------------------
// Strategy 1: Sweep Reversal
//---------------------------------------------------------
void BuildCouncilStrategy_SweepReversal(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "sweep_reversal";
   r.strategy_family = "LIQUIDITY_REVERSAL";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 1.15;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_SCOUT);

   if(r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Blocked by zone";
      r.explanation   = "Sweep reversal blocked | " + r.zone_block_reason;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult sweep = DetectSweepDetectorTrigger();

   r.trigger_present = sweep.valid;
   r.trigger_quality = sweep.valid ? sweep.quality : 0.0;

   if(!sweep.valid)
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No sweep trigger";
      r.explanation     = "Liquidity sweep trigger not present";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(sweep.dir == CORE_BUY)
      r.decision = COUNCIL_DECISION_BUY;
   else if(sweep.dir == CORE_SELL)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   bool rejectionOk = false;
   bool trendConflict = false;

   if(r.decision == COUNCIL_DECISION_BUY)
   {
      rejectionOk      = RT_BullishRejection(PERIOD_M1, 1);
      trendConflict    = RT_M5TrendBear();
      r.environment_fit = CouncilEnvironmentFitBuy(env);
   }
   else if(r.decision == COUNCIL_DECISION_SELL)
   {
      rejectionOk      = RT_BearishRejection(PERIOD_M1, 1);
      trendConflict    = RT_M5TrendBull();
      r.environment_fit = CouncilEnvironmentFitSell(env);
   }
   else
   {
      r.environment_fit = env.total_score;
   }

   r.confirmation_quality = rejectionOk ? 0.80 : 0.45;
   r.counter_trend        = trendConflict;
   r.conflict_score       = trendConflict ? 0.20 : 0.05;

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.45) +
      (r.confirmation_quality * 0.25) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.15);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Sweep reversal " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Sweep trigger detected"
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | trigger_q=" + DoubleToString(r.trigger_quality, 2) +
      " | conf_q=" + DoubleToString(r.confirmation_quality, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2) +
      " | conflict=" + DoubleToString(r.conflict_score, 2);

   CouncilFinalizeStrategyReport(r);
}

//---------------------------------------------------------
// Strategy 2: Bollinger Reclaim
//---------------------------------------------------------
void BuildCouncilStrategy_BollingerReclaim(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "bollinger_reclaim";
   r.strategy_family = "MEAN_RECLAIM";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 1.00;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Blocked by zone";
      r.explanation   = "Bollinger reclaim blocked | " + r.zone_block_reason;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectBollingerReclaimTrigger();

   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;

   if(!tr.valid)
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No Bollinger reclaim";
      r.explanation     = "Bollinger reclaim trigger not present";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(tr.dir == CORE_BUY)
      r.decision = COUNCIL_DECISION_BUY;
   else if(tr.dir == CORE_SELL)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   bool rejectionOk = false;
   bool trendConflict = false;

   if(r.decision == COUNCIL_DECISION_BUY)
   {
      rejectionOk      = RT_BullishRejection(PERIOD_M1, 1);
      trendConflict    = RT_M5TrendBear();
      r.environment_fit = CouncilEnvironmentFitBuy(env);
   }
   else if(r.decision == COUNCIL_DECISION_SELL)
   {
      rejectionOk      = RT_BearishRejection(PERIOD_M1, 1);
      trendConflict    = RT_M5TrendBull();
      r.environment_fit = CouncilEnvironmentFitSell(env);
   }
   else
   {
      r.environment_fit = env.total_score;
   }

   r.confirmation_quality = rejectionOk ? 0.75 : 0.50;
   r.counter_trend        = trendConflict;
   r.conflict_score       = trendConflict ? 0.22 : 0.06;

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.42) +
      (r.confirmation_quality * 0.23) +
      (r.environment_fit * 0.28) -
      (r.conflict_score * 0.15);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Bollinger reclaim " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Bollinger reclaim active"
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | trigger_q=" + DoubleToString(r.trigger_quality, 2) +
      " | conf_q=" + DoubleToString(r.confirmation_quality, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2) +
      " | conflict=" + DoubleToString(r.conflict_score, 2);

   CouncilFinalizeStrategyReport(r);
}

//---------------------------------------------------------
// Strategy 3: Trend Momentum
//---------------------------------------------------------
void BuildCouncilStrategy_TrendMomentum(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "trend_momentum";
   r.strategy_family = "TREND_CONTINUATION";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.95;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_TREND_JUDGE);

   if(r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Blocked by zone";
      r.explanation   = "Trend momentum blocked | " + r.zone_block_reason;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectEMATrendAlignmentTrigger();

   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;

   if(!tr.valid)
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No EMA trend alignment";
      r.explanation     = "EMA trend continuation trigger not present";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(tr.dir == CORE_BUY)
      r.decision = COUNCIL_DECISION_BUY;
   else if(tr.dir == CORE_SELL)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   bool m1Align = false;
   bool m5Align = false;

   if(r.decision == COUNCIL_DECISION_BUY)
   {
      m1Align = RT_M1TrendBull();
      m5Align = RT_M5TrendBull();
      r.environment_fit = CouncilEnvironmentFitBuy(env);
   }
   else if(r.decision == COUNCIL_DECISION_SELL)
   {
      m1Align = RT_M1TrendBear();
      m5Align = RT_M5TrendBear();
      r.environment_fit = CouncilEnvironmentFitSell(env);
   }
   else
   {
      r.environment_fit = env.total_score;
   }

   r.confirmation_quality =
      (m1Align && m5Align) ? 0.85 :
      (m1Align || m5Align) ? 0.60 : 0.30;

   r.counter_trend  = false;
   r.conflict_score = 0.05;

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.40) +
      (r.confirmation_quality * 0.30) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.10);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Trend momentum " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "EMA trend continuation"
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | trigger_q=" + DoubleToString(r.trigger_quality, 2) +
      " | conf_q=" + DoubleToString(r.confirmation_quality, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2);

   CouncilFinalizeStrategyReport(r);
}

//---------------------------------------------------------
// Strategy 4: MFI Reversal Assist
//---------------------------------------------------------

//---------------------------------------------------------
// Trend Pullback Continuation v1
//---------------------------------------------------------
TriggerResult DetectTrendPullbackContinuationTrigger()
{
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "No trend pullback continuation";
   tr.valid = false;

   // Require aligned trend on both M1 and M5 to avoid mixed regimes.
   bool bull = RT_M1TrendBull() && RT_M5TrendBull();
   bool bear = RT_M1TrendBear() && RT_M5TrendBear();

   if(!bull && !bear)
      return tr;

   double emaFastM5 = 0.0, emaSlowM5 = 0.0, atrM1 = 0.0;
   if(!RT_GetEMA(PERIOD_M5, 20, 1, emaFastM5)) return tr;
   if(!RT_GetEMA(PERIOD_M5, 50, 1, emaSlowM5)) return tr;
   if(!RT_GetATR(PERIOD_M1, 14, 1, atrM1)) return tr;
   if(atrM1 <= 0.0) return tr;

   // Pullback candle (shift=2) + continuation candle (shift=1) on M1.
   double o1 = RT_Open(PERIOD_M1, 1), c1 = RT_Close(PERIOD_M1, 1);
   double o2 = RT_Open(PERIOD_M1, 2), c2 = RT_Close(PERIOD_M1, 2);
   double h2 = RT_High(PERIOD_M1, 2), l2 = RT_Low(PERIOD_M1, 2);

   if(bull)
   {
      bool pullback = (c2 < o2) && (l2 <= emaFastM5 + atrM1 * 0.25) && (l2 >= emaSlowM5 - atrM1 * 0.50);
      bool confirm  = (c1 > o1) && (RT_BullishRejection(PERIOD_M1, 1) || (c1 >= emaFastM5));
      bool not_late  = ((c1 - emaFastM5) <= atrM1 * 1.20);

      if(pullback && confirm && not_late)
      {
         double depth = (emaFastM5 - l2) / atrM1; // 0..?
         double depthScore = 1.0 - MathMin(MathAbs(depth - 0.70), 1.20) / 1.20;
         depthScore = CouncilClamp01_Strategy(depthScore);

         double confirmScore = RT_BullishRejection(PERIOD_M1, 1) ? 1.0 : 0.70;
         double locationScore = 1.0 - MathMin((c1 - emaFastM5) / (atrM1 * 1.20), 1.0);

         tr.dir = CORE_BUY;
         tr.valid = true;
         tr.quality = CouncilClamp01_Strategy(depthScore * 0.45 + confirmScore * 0.35 + locationScore * 0.20);
         tr.reason = "Trend pullback -> continuation (BUY)";
      }
      return tr;
   }

   // bear
   bool pullback = (c2 > o2) && (h2 >= emaFastM5 - atrM1 * 0.25) && (h2 <= emaSlowM5 + atrM1 * 0.50);
   bool confirm  = (c1 < o1) && (RT_BearishRejection(PERIOD_M1, 1) || (c1 <= emaFastM5));
   bool not_late  = ((emaFastM5 - c1) <= atrM1 * 1.20);

   if(pullback && confirm && not_late)
   {
      double depth = (h2 - emaFastM5) / atrM1;
      double depthScore = 1.0 - MathMin(MathAbs(depth - 0.70), 1.20) / 1.20;
      depthScore = CouncilClamp01_Strategy(depthScore);

      double confirmScore = RT_BearishRejection(PERIOD_M1, 1) ? 1.0 : 0.70;
      double locationScore = 1.0 - MathMin((emaFastM5 - c1) / (atrM1 * 1.20), 1.0);

      tr.dir = CORE_SELL;
      tr.valid = true;
      tr.quality = CouncilClamp01_Strategy(depthScore * 0.45 + confirmScore * 0.35 + locationScore * 0.20);
      tr.reason = "Trend pullback -> continuation (SELL)";
   }

   return tr;
}

void BuildCouncilStrategy_TrendPullbackContinuation(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "trend_pullback_cont_v1";
   r.strategy_name   = "Trend Pullback Continuation v1";
   r.strategy_family = "TREND_PULLBACK_CONTINUATION";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.80;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   // Strict scope: TREND_CONTINUATION zone only.
   if(env.zone_type != COUNCIL_ZONE_TREND_CONTINUATION)
   {
      r.decision     = COUNCIL_DECISION_WAIT;
      r.short_reason = "Non-trend zone";
      r.explanation  = "Trend pullback continuation only active in TREND_CONTINUATION zone";
      r.score_final  = 0.0;
      r.vote_weight  = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Blocked by zone";
      r.explanation   = "Trend pullback blocked | " + r.zone_block_reason;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectTrendPullbackContinuationTrigger();

   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;
   r.short_reason    = tr.reason;

   if(!tr.valid)
   {
      r.decision     = COUNCIL_DECISION_WAIT;
      r.explanation  = "No healthy pullback+resume pattern detected";
      r.score_final  = 0.0;
      r.vote_weight  = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(tr.dir == CORE_BUY)
   {
      r.decision          = COUNCIL_DECISION_BUY;
      r.environment_fit   = CouncilEnvironmentFitBuy(env);
      r.conflict_score    = 0.08;
      r.confirmation_quality = 0.65; // keep conservative
      r.score_final       = CouncilClamp01_Strategy(r.trigger_quality * 0.55 + r.environment_fit * 0.30 + r.confirmation_quality * 0.15);
      r.explanation       = "Continuation after pullback | " + tr.reason;
   }
   else if(tr.dir == CORE_SELL)
   {
      r.decision          = COUNCIL_DECISION_SELL;
      r.environment_fit   = CouncilEnvironmentFitSell(env);
      r.conflict_score    = 0.08;
      r.confirmation_quality = 0.65;
      r.score_final       = CouncilClamp01_Strategy(r.trigger_quality * 0.55 + r.environment_fit * 0.30 + r.confirmation_quality * 0.15);
      r.explanation       = "Continuation after pullback | " + tr.reason;
   }
   else
   {
      r.decision     = COUNCIL_DECISION_WAIT;
      r.explanation  = "No directional trigger";
      r.score_final  = 0.0;
      r.vote_weight  = 0.0;
   }

   CouncilFinalizeStrategyReport(r);
}

void BuildCouncilStrategy_MFIReversalAssist(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "mfi_reversal_assist";
   r.strategy_family = "MOMENTUM_REVERSAL_ASSIST";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.90;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_EXHAUSTION_JUDGE);

   if(r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Blocked by zone";
      r.explanation   = "MFI reversal assist blocked | " + r.zone_block_reason;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double mfi1 = 0.0;
   double mfi2 = 0.0;

   bool ok1 = RT_GetMFI(PERIOD_M1, 14, 1, mfi1);
   bool ok2 = RT_GetMFI(PERIOD_M1, 14, 2, mfi2);

   if(!ok1 || !ok2)
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "MFI unavailable";
      r.explanation     = "Could not read MFI";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   bool buySignal  = (mfi1 > mfi2 && mfi1 < 45.0 && RT_BullishRejection(PERIOD_M1, 1));
   bool sellSignal = (mfi1 < mfi2 && mfi1 > 55.0 && RT_BearishRejection(PERIOD_M1, 1));

   if(buySignal && !sellSignal)
      r.decision = COUNCIL_DECISION_BUY;
   else if(sellSignal && !buySignal)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   r.trigger_present = (r.decision != COUNCIL_DECISION_WAIT);
   r.trigger_quality = r.trigger_present ? 0.65 : 0.0;

   if(r.decision == COUNCIL_DECISION_WAIT)
   {
      r.short_reason    = "No MFI reversal assist";
      r.explanation     = "No clean MFI reversal setup";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   bool trendConflict = false;

   if(r.decision == COUNCIL_DECISION_BUY)
   {
      trendConflict     = RT_M5TrendBear();
      r.environment_fit = CouncilEnvironmentFitBuy(env);
   }
   else
   {
      trendConflict     = RT_M5TrendBull();
      r.environment_fit = CouncilEnvironmentFitSell(env);
   }

   r.confirmation_quality = 0.70;
   r.counter_trend        = trendConflict;
   r.conflict_score       = trendConflict ? 0.25 : 0.08;

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.35) +
      (r.confirmation_quality * 0.30) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.12);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "MFI reversal assist " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "MFI reversal assist"
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | mfi1=" + DoubleToString(mfi1, 2) +
      " | mfi2=" + DoubleToString(mfi2, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2) +
      " | conflict=" + DoubleToString(r.conflict_score, 2);

   CouncilFinalizeStrategyReport(r);
}

//---------------------------------------------------------
// Public strategy set runner
//---------------------------------------------------------

//---------------------------------------------------------
// Strategy Injection 2: Trend Expansion Pack
//---------------------------------------------------------
TriggerResult DetectMomentumBreakoutContinuationTrigger()
{
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "";
   tr.valid = false;

   double atr = 0.0;
   if(!RT_GetATR(PERIOD_M1, 14, 1, atr) || atr <= 0.0)
      return tr;

   double o1 = RT_Open(PERIOD_M1, 1);
   double c1 = RT_Close(PERIOD_M1, 1);
   double h1 = RT_High(PERIOD_M1, 1);
   double l1 = RT_Low(PERIOD_M1, 1);

   double h2 = RT_High(PERIOD_M1, 2);
   double l2 = RT_Low(PERIOD_M1, 2);

   double body = MathAbs(c1 - o1);
   double bodyRatio = body / atr;

   // Conservative: require a healthy momentum candle
   if(bodyRatio < 0.55)
      return tr;

   bool bull = (c1 > o1) && (c1 > h2);
   bool bear = (c1 < o1) && (c1 < l2);

   if(bull)
   {
      tr.dir = CORE_BUY;
      tr.valid = true;
      tr.quality = CouncilClamp01_Strategy(0.55 + MathMin(0.35, (bodyRatio - 0.55)));
      tr.reason = "Momentum breakout continuation (bull)";
      return tr;
   }

   if(bear)
   {
      tr.dir = CORE_SELL;
      tr.valid = true;
      tr.quality = CouncilClamp01_Strategy(0.55 + MathMin(0.35, (bodyRatio - 0.55)));
      tr.reason = "Momentum breakout continuation (bear)";
      return tr;
   }

   return tr;
}

TriggerResult DetectMicroStructureReentryTrigger(CoreDirection trendDir)
{
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "";
   tr.valid = false;

   double atr = 0.0;
   if(!RT_GetATR(PERIOD_M1, 14, 1, atr) || atr <= 0.0)
      return tr;

   // micro structure: pullback bar (2) then reclaim bar (1)
   double o1 = RT_Open(PERIOD_M1, 1);
   double c1 = RT_Close(PERIOD_M1, 1);
   double h1 = RT_High(PERIOD_M1, 1);
   double l1 = RT_Low(PERIOD_M1, 1);

   double h2 = RT_High(PERIOD_M1, 2);
   double l2 = RT_Low(PERIOD_M1, 2);
   double o2 = RT_Open(PERIOD_M1, 2);
   double c2 = RT_Close(PERIOD_M1, 2);

   if(trendDir == CORE_BUY)
   {
      // pullback then reclaim
      if(!(c2 < o2)) return tr;
      if(!(c1 > o1)) return tr;
      if(!(c1 > h2)) return tr;

      double pullDepth = MathMax(0.0, (h2 - l2)) / atr;
      double q = 0.60;
      if(pullDepth < 0.9) q += 0.10;
      if(RT_BullishRejection(PERIOD_M1, 1)) q += 0.08;

      tr.dir = CORE_BUY;
      tr.valid = true;
      tr.quality = CouncilClamp01_Strategy(q);
      tr.reason = "Micro structure re-entry (bull)";
      return tr;
   }

   if(trendDir == CORE_SELL)
   {
      if(!(c2 > o2)) return tr;
      if(!(c1 < o1)) return tr;
      if(!(c1 < l2)) return tr;

      double pullDepth = MathMax(0.0, (h2 - l2)) / atr;
      double q = 0.60;
      if(pullDepth < 0.9) q += 0.10;
      if(RT_BearishRejection(PERIOD_M1, 1)) q += 0.08;

      tr.dir = CORE_SELL;
      tr.valid = true;
      tr.quality = CouncilClamp01_Strategy(q);
      tr.reason = "Micro structure re-entry (bear)";
      return tr;
   }

   return tr;
}

TriggerResult DetectBreakdownMomentumTrigger()
{
   // bearish specialized continuation
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "";
   tr.valid = false;

   double atr = 0.0;
   if(!RT_GetATR(PERIOD_M1, 14, 1, atr) || atr <= 0.0)
      return tr;

   double o1 = RT_Open(PERIOD_M1, 1);
   double c1 = RT_Close(PERIOD_M1, 1);
   double l1 = RT_Low(PERIOD_M1, 1);

   // compare vs last 3 lows
   double l2 = RT_Low(PERIOD_M1, 2);
   double l3 = RT_Low(PERIOD_M1, 3);
   double l4 = RT_Low(PERIOD_M1, 4);

   double body = MathAbs(c1 - o1);
   double bodyRatio = body / atr;

   if(!(c1 < o1)) return tr;
   if(bodyRatio < 0.60) return tr;

   double priorLow = MathMin(l2, MathMin(l3, l4));
   if(!(c1 < priorLow)) return tr;

   tr.dir = CORE_SELL;
   tr.valid = true;
   tr.quality = CouncilClamp01_Strategy(0.62 + MathMin(0.28, (bodyRatio - 0.60)));
   tr.reason = "Breakdown momentum continuation";
   return tr;
}

TriggerResult DetectLowerHighRejectionTrigger()
{
   // bearish specialized continuation: lower high then rejection
   TriggerResult tr;
   tr.dir = CORE_NONE;
   tr.quality = 0.0;
   tr.reason = "";
   tr.valid = false;

   double atr = 0.0;
   if(!RT_GetATR(PERIOD_M1, 14, 1, atr) || atr <= 0.0)
      return tr;

   double h2 = RT_High(PERIOD_M1, 2);
   double h3 = RT_High(PERIOD_M1, 3);
   double h4 = RT_High(PERIOD_M1, 4);

   // detect lower-high structure (simple, conservative)
   double priorHigh = MathMax(h3, h4);
   if(!(h2 < priorHigh - (0.15 * atr)))
      return tr;

   // confirmation: bearish rejection candle
   if(!RT_BearishRejection(PERIOD_M1, 1))
      return tr;

   tr.dir = CORE_SELL;
   tr.valid = true;
   tr.quality = 0.72;
   tr.reason = "Lower high rejection (bear)";
   return tr;
}

void BuildCouncilStrategy_MomentumBreakoutContinuation(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "momentum_breakout_cont_v1";
   r.strategy_name   = "Momentum Breakout Continuation";
   r.strategy_family = "TREND_CONTINUATION";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.72;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(env.zone_type != COUNCIL_ZONE_TREND_CONTINUATION || r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Inactive outside trend zone";
      r.explanation   = "Trend breakout continuation inactive | zone=" + r.zone_name;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectMomentumBreakoutContinuationTrigger();

   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;

   if(!tr.valid)
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No momentum breakout";
      r.explanation     = "No clean breakout continuation candle detected";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision        = (tr.dir == CORE_BUY ? COUNCIL_DECISION_BUY : COUNCIL_DECISION_SELL);
   r.short_reason    = tr.reason;
   r.explanation     = tr.reason + " | zone=" + r.zone_name;
   r.environment_fit = env.total_score;

   r.conflict_score  = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);
   r.score_final     = CouncilClamp01_Strategy(
      0.55 * r.trigger_quality +
      0.30 * r.zone_alignment_score +
      0.15 * r.environment_fit
   );

   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);
   CouncilFinalizeStrategyReport(r);
}

void BuildCouncilStrategy_MicroStructureReentry(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "micro_structure_reentry_v1";
   r.strategy_name   = "Micro Structure Re-entry";
   r.strategy_family = "TREND_CONTINUATION";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.70;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(env.zone_type != COUNCIL_ZONE_TREND_CONTINUATION || r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Inactive outside trend zone";
      r.explanation   = "Micro re-entry inactive | zone=" + r.zone_name;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   CoreDirection dir = CORE_NONE;
   if(RT_M1TrendBull() && RT_M5TrendBull()) dir = CORE_BUY;
   if(RT_M1TrendBear() && RT_M5TrendBear()) dir = CORE_SELL;

   if(dir == CORE_NONE)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No trend alignment";
      r.explanation   = "Micro re-entry requires M1+M5 alignment";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectMicroStructureReentryTrigger(dir);
   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;

   if(!tr.valid)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No micro re-entry";
      r.explanation   = "No clean micro structure reclaim/break found";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision        = (tr.dir == CORE_BUY ? COUNCIL_DECISION_BUY : COUNCIL_DECISION_SELL);
   r.short_reason    = tr.reason;
   r.explanation     = tr.reason + " | zone=" + r.zone_name;
   r.environment_fit = env.total_score;

   r.conflict_score  = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);
   r.score_final     = CouncilClamp01_Strategy(
      0.52 * r.trigger_quality +
      0.33 * r.zone_alignment_score +
      0.15 * r.environment_fit
   );

   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);
   CouncilFinalizeStrategyReport(r);
}

void BuildCouncilStrategy_BreakdownMomentum(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "breakdown_momentum_v1";
   r.strategy_name   = "Breakdown Momentum";
   r.strategy_family = "TREND_CONTINUATION";
   r.direction_bias  = "SELL_ONLY";
   r.vote_weight     = 0.68;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(env.zone_type != COUNCIL_ZONE_TREND_CONTINUATION || r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Inactive outside trend zone";
      r.explanation   = "Breakdown momentum inactive | zone=" + r.zone_name;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(!(RT_M1TrendBear() && RT_M5TrendBear()))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not bearish aligned";
      r.explanation   = "Requires M1+M5 bearish alignment";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectBreakdownMomentumTrigger();
   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;

   if(!tr.valid)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No breakdown momentum";
      r.explanation   = "No clean bearish breakdown momentum candle detected";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision        = COUNCIL_DECISION_SELL;
   r.short_reason    = tr.reason;
   r.explanation     = tr.reason + " | zone=" + r.zone_name;
   r.environment_fit = env.total_score;

   r.conflict_score  = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);
   r.score_final     = CouncilClamp01_Strategy(
      0.58 * r.trigger_quality +
      0.28 * r.zone_alignment_score +
      0.14 * r.environment_fit
   );

   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);
   CouncilFinalizeStrategyReport(r);
}

void BuildCouncilStrategy_LowerHighRejection(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "lower_high_rejection_v1";
   r.strategy_name   = "Lower High Rejection";
   r.strategy_family = "TREND_CONTINUATION";
   r.direction_bias  = "SELL_ONLY";
   r.vote_weight     = 0.66;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(env.zone_type != COUNCIL_ZONE_TREND_CONTINUATION || r.blocked_by_zone)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Inactive outside trend zone";
      r.explanation   = "Lower-high rejection inactive | zone=" + r.zone_name;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(!(RT_M1TrendBear() && RT_M5TrendBear()))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not bearish aligned";
      r.explanation   = "Requires M1+M5 bearish alignment";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   TriggerResult tr = DetectLowerHighRejectionTrigger();
   r.trigger_present = tr.valid;
   r.trigger_quality = tr.valid ? tr.quality : 0.0;

   if(!tr.valid)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No lower-high rejection";
      r.explanation   = "No clear lower-high rejection detected";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision        = COUNCIL_DECISION_SELL;
   r.short_reason    = tr.reason;
   r.explanation     = tr.reason + " | zone=" + r.zone_name;
   r.environment_fit = env.total_score;

   r.conflict_score  = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);
   r.score_final     = CouncilClamp01_Strategy(
      0.54 * r.trigger_quality +
      0.31 * r.zone_alignment_score +
      0.15 * r.environment_fit
   );

   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);
   CouncilFinalizeStrategyReport(r);
}


//---------------------------------------------------------
// Phase B1 — Range Core Pack
//---------------------------------------------------------

// Strategy: Mean Reversion Bounce
void BuildCouncilStrategy_MeanReversionBounce(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "mean_reversion_bounce";
   r.strategy_name   = "Mean Reversion Bounce";
   r.strategy_family = "MEAN_RECLAIM";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.92;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   // Hard scope: range contexts only
   if(!CouncilIsRangeContext(env) || env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION || env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not a RANGE context";
      r.explanation   = "Mean reversion bounce inactive outside range";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   // Avoid dirty collapse / panic continuation
   if(env.volatility_score >= 0.78 && env.structure_score < 0.45)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Dirty/high-vol range";
      r.explanation   = "Mean reversion bounce blocked: volatility high + structure weak";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double hi=0.0, lo=0.0;
   if(!CouncilGetRecentRangeBounds(PERIOD_M5, 36, 1, hi, lo))
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No range bounds";
      r.explanation     = "Mean reversion bounce missing: failed to compute bounds";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double mid = (hi + lo) / 2.0;
   double atrPts = CouncilGetATRPoints(PERIOD_M5, 14, 1);
   double buf = MathMax(4.0, atrPts * 0.18) * _Point;

   double c1 = iClose(_Symbol, PERIOD_M1, 1);
   double o1 = iOpen(_Symbol, PERIOD_M1, 1);
   double h1 = iHigh(_Symbol, PERIOD_M1, 1);
   double l1 = iLow(_Symbol, PERIOD_M1, 1);

   bool bullRej = RT_BullishRejection(PERIOD_M1, 1);
   bool bearRej = RT_BearishRejection(PERIOD_M1, 1);

   // Two conservative patterns:
   // (A) Lower support bounce -> buy
   bool buyBounce =
      (c1 > o1) &&
      bullRej &&
      (l1 <= (lo + buf)) &&
      (c1 >= (lo + (buf * 0.60)));

   // (B) Upper resistance bounce -> sell
   bool sellBounce =
      (c1 < o1) &&
      bearRej &&
      (h1 >= (hi - buf)) &&
      (c1 <= (hi - (buf * 0.60)));

   // (C) Mid reclaim continuation inside range (not breakout)
   bool buyMidReclaim  = (iClose(_Symbol, PERIOD_M1, 2) < mid && c1 > mid && bullRej);
   bool sellMidReclaim = (iClose(_Symbol, PERIOD_M1, 2) > mid && c1 < mid && bearRej);

   if(buyBounce || buyMidReclaim)
      r.decision = COUNCIL_DECISION_BUY;
   else if(sellBounce || sellMidReclaim)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   r.trigger_present = (r.decision != COUNCIL_DECISION_WAIT);

   if(!r.trigger_present)
   {
      r.trigger_quality   = 0.0;
      r.environment_fit   = env.total_score;
      r.decision          = COUNCIL_DECISION_WAIT;
      r.short_reason      = "No bounce / reclaim";
      r.explanation       = "Mean reversion bounce trigger not present";
      r.score_final       = 0.0;
      r.vote_weight       = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   bool trendConflict = (r.decision == COUNCIL_DECISION_BUY) ? RT_M5TrendBear() : RT_M5TrendBull();

   r.trigger_quality = 0.70 + (env.structure_score * 0.15);
   r.trigger_quality = CouncilClamp01_Strategy(r.trigger_quality);

   r.confirmation_quality = ((r.decision == COUNCIL_DECISION_BUY) ? bullRej : bearRej) ? 0.78 : 0.55;
   r.environment_fit      = (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) : CouncilEnvironmentFitSell(env);
   r.counter_trend        = trendConflict;
   r.conflict_score       = trendConflict ? 0.18 : 0.06;

   double rawScore =
      (r.trigger_quality * 0.40) +
      (r.confirmation_quality * 0.25) +
      (r.environment_fit * 0.28) -
      (r.conflict_score * 0.15);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Mean reversion bounce " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Mean reversion bounce active" +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | trigger_q=" + DoubleToString(r.trigger_quality, 2) +
      " | conf_q=" + DoubleToString(r.confirmation_quality, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2) +
      " | conflict=" + DoubleToString(r.conflict_score, 2);

   CouncilFinalizeStrategyReport(r);
}

// Strategy: Range Edge Fade
void BuildCouncilStrategy_RangeEdgeFade(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "range_edge_fade";
   r.strategy_name   = "Range Edge Fade";
   r.strategy_family = "MEAN_RECLAIM";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.88;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(!CouncilIsRangeContext(env) || env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION || env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not a RANGE context";
      r.explanation   = "Range edge fade inactive outside range";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double hi=0.0, lo=0.0;
   if(!CouncilGetRecentRangeBounds(PERIOD_M5, 42, 1, hi, lo))
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No range bounds";
      r.explanation     = "Range edge fade missing: failed to compute bounds";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double atrPts = CouncilGetATRPoints(PERIOD_M5, 14, 1);
   double edgeBuf = MathMax(5.0, atrPts * 0.20) * _Point;

   double c1 = iClose(_Symbol, PERIOD_M1, 1);
   double o1 = iOpen(_Symbol, PERIOD_M1, 1);
   double h1 = iHigh(_Symbol, PERIOD_M1, 1);
   double l1 = iLow(_Symbol, PERIOD_M1, 1);

   bool bullRej = RT_BullishRejection(PERIOD_M1, 1);
   bool bearRej = RT_BearishRejection(PERIOD_M1, 1);

   // Edge-specific: require touch/overextension + close back inside + rejection
   bool buyEdge =
      bullRej &&
      (l1 <= (lo - edgeBuf * 0.15) || l1 <= (lo + edgeBuf * 0.10)) &&
      (c1 > lo + edgeBuf * 0.20);

   bool sellEdge =
      bearRej &&
      (h1 >= (hi + edgeBuf * 0.15) || h1 >= (hi - edgeBuf * 0.10)) &&
      (c1 < hi - edgeBuf * 0.20);

   if(buyEdge)
      r.decision = COUNCIL_DECISION_BUY;
   else if(sellEdge)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   r.trigger_present = (r.decision != COUNCIL_DECISION_WAIT);

   if(!r.trigger_present)
   {
      r.trigger_quality   = 0.0;
      r.environment_fit   = env.total_score;
      r.short_reason      = "No edge rejection";
      r.explanation       = "Range edge fade trigger not present";
      r.score_final       = 0.0;
      r.vote_weight       = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   bool trendConflict = (r.decision == COUNCIL_DECISION_BUY) ? RT_M5TrendBear() : RT_M5TrendBull();

   r.trigger_quality      = CouncilClamp01_Strategy(0.68 + (env.structure_score * 0.18));
   r.confirmation_quality = ((r.decision == COUNCIL_DECISION_BUY) ? bullRej : bearRej) ? 0.82 : 0.55;
   r.environment_fit      = (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) : CouncilEnvironmentFitSell(env);
   r.counter_trend        = trendConflict;
   r.conflict_score       = trendConflict ? 0.17 : 0.06;

   double rawScore =
      (r.trigger_quality * 0.40) +
      (r.confirmation_quality * 0.26) +
      (r.environment_fit * 0.27) -
      (r.conflict_score * 0.15);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Range edge fade " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Range edge fade active" +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | trigger_q=" + DoubleToString(r.trigger_quality, 2) +
      " | conf_q=" + DoubleToString(r.confirmation_quality, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2) +
      " | conflict=" + DoubleToString(r.conflict_score, 2);

   CouncilFinalizeStrategyReport(r);
}

// Strategy: Fake Break Reversal
void BuildCouncilStrategy_FakeBreakReversal(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "fake_break_reversal";
   r.strategy_name   = "Fake Break Reversal";
   r.strategy_family = "LIQUIDITY_REVERSAL";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.94;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_SCOUT);

   if(!CouncilIsRangeContext(env) || env.zone_type == COUNCIL_ZONE_TREND_CONTINUATION || env.zone_type == COUNCIL_ZONE_BREAKOUT_EXPANSION)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not a RANGE context";
      r.explanation   = "Fake break reversal inactive outside range";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double hi=0.0, lo=0.0;
   if(!CouncilGetRecentRangeBounds(PERIOD_M5, 48, 1, hi, lo))
   {
      r.decision        = COUNCIL_DECISION_WAIT;
      r.short_reason    = "No range bounds";
      r.explanation     = "Fake break reversal missing: failed to compute bounds";
      r.environment_fit = env.total_score;
      r.score_final     = 0.0;
      r.vote_weight     = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double atrPts = CouncilGetATRPoints(PERIOD_M5, 14, 1);
   double sweepBuf = MathMax(6.0, atrPts * 0.22) * _Point;

   double c1 = iClose(_Symbol, PERIOD_M1, 1);
   double c2 = iClose(_Symbol, PERIOD_M1, 2);
   double h1 = iHigh(_Symbol, PERIOD_M1, 1);
   double l1 = iLow(_Symbol, PERIOD_M1, 1);

   bool bullRej = RT_BullishRejection(PERIOD_M1, 1);
   bool bearRej = RT_BearishRejection(PERIOD_M1, 1);

   // Failed break definition: previous close outside, current close back inside + wick sweep
   bool fakeDown =
      (c2 < (lo - sweepBuf * 0.20)) &&
      (l1 < (lo - sweepBuf * 0.40)) &&
      (c1 > (lo + sweepBuf * 0.10)) &&
      bullRej;

   bool fakeUp =
      (c2 > (hi + sweepBuf * 0.20)) &&
      (h1 > (hi + sweepBuf * 0.40)) &&
      (c1 < (hi - sweepBuf * 0.10)) &&
      bearRej;

   if(fakeDown)
      r.decision = COUNCIL_DECISION_BUY;
   else if(fakeUp)
      r.decision = COUNCIL_DECISION_SELL;
   else
      r.decision = COUNCIL_DECISION_WAIT;

   r.trigger_present = (r.decision != COUNCIL_DECISION_WAIT);

   if(!r.trigger_present)
   {
      r.trigger_quality   = 0.0;
      r.environment_fit   = env.total_score;
      r.short_reason      = "No failed-break reclaim";
      r.explanation       = "Fake break reversal trigger not present";
      r.score_final       = 0.0;
      r.vote_weight       = CouncilApplyEligibilityWeight(r, r.vote_weight);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   bool trendConflict = (r.decision == COUNCIL_DECISION_BUY) ? RT_M5TrendBear() : RT_M5TrendBull();

   r.trigger_quality      = CouncilClamp01_Strategy(0.74 + (env.sweep_context_score * 0.18));
   r.confirmation_quality = ((r.decision == COUNCIL_DECISION_BUY) ? bullRej : bearRej) ? 0.85 : 0.60;
   r.environment_fit      = (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) : CouncilEnvironmentFitSell(env);
   r.counter_trend        = trendConflict;
   r.conflict_score       = trendConflict ? 0.20 : 0.07;

   double rawScore =
      (r.trigger_quality * 0.43) +
      (r.confirmation_quality * 0.22) +
      (r.environment_fit * 0.28) -
      (r.conflict_score * 0.15);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Fake break reversal " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Fake break reversal active" +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text +
      " | trigger_q=" + DoubleToString(r.trigger_quality, 2) +
      " | conf_q=" + DoubleToString(r.confirmation_quality, 2) +
      " | env_fit=" + DoubleToString(r.environment_fit, 2) +
      " | zone_align=" + DoubleToString(r.zone_alignment_score, 2) +
      " | priority=" + DoubleToString(r.priority_score, 2) +
      " | conflict=" + DoubleToString(r.conflict_score, 2);

   CouncilFinalizeStrategyReport(r);
}



//---------------------------------------------------------
// Phase C1 — Compression Core
//---------------------------------------------------------

// Strategy 13: Range Compression Breakout
void BuildCouncilStrategy_RangeCompressionBreakout(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "range_compression_breakout";
   r.strategy_name   = "Range Compression Breakout";
   r.strategy_family = "COMPRESSION_BREAKOUT";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.95;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_SCOUT);

   if(!CouncilIsCompressionOrExpansionAllowedZone(env) || !CouncilIsCompressionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not compression zone";
      r.explanation   = "Compression breakout inactive outside compression context";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(CouncilIsExpansionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Already expanded";
      r.explanation   = "Compression breakout skipped (expansion already active)";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double hi=0.0, lo=0.0;
   if(!CouncilGetRecentRangeBounds(PERIOD_M5, 24, 1, hi, lo))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No range bounds";
      r.explanation   = "Failed to derive compression bounds (M5)";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double widthPts = (hi - lo) / _Point;
   double atrPts   = CouncilGetATRPoints(PERIOD_M5, 14, 1);

   bool compressionOk =
      (atrPts > 0.0) &&
      (widthPts > 0.0) &&
      (widthPts <= atrPts * 3.0) &&
      (env.volatility_score <= 0.60) &&
      env.structure_ok;

   r.trigger_present = compressionOk;
   r.trigger_quality = compressionOk ? 0.75 : 0.0;

   if(!compressionOk)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No compression";
      r.explanation   = "Compression criteria not met (width/ATR/structure)";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   CouncilDecision d;
   bool broke = CouncilCloseBreaksRange(PERIOD_M5, 1, hi, lo, MathMax(atrPts*0.20, 6.0), d);

   if(!broke || d == COUNCIL_DECISION_WAIT)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No breakout";
      r.explanation   = "Compression present but no clean breakout close";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = CouncilApplyEligibilityWeight(r, 0.0);
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision = d;

   double bodyPts = CouncilCandleBodyPoints(PERIOD_M5, 1);
   bool displacementOk = (atrPts > 0.0 && bodyPts >= atrPts * 0.80);

   r.confirmation_quality =
      displacementOk ? 0.78 : 0.55;

   r.environment_fit =
      (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) :
      (r.decision == COUNCIL_DECISION_SELL) ? CouncilEnvironmentFitSell(env) :
      env.total_score;

   r.conflict_score = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.45) +
      (r.confirmation_quality * 0.25) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.10);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason =
      "Compression breakout " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Tight M5 range + breakout close"
      " | widthPts=" + DoubleToString(widthPts, 0) +
      " | atrPts=" + DoubleToString(atrPts, 0) +
      " | bodyPts=" + DoubleToString(bodyPts, 0) +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text;

   CouncilFinalizeStrategyReport(r);
}


// Strategy 14: Volatility Squeeze Release
void BuildCouncilStrategy_VolatilitySqueezeRelease(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "volatility_squeeze_release";
   r.strategy_name   = "Volatility Squeeze Release";
   r.strategy_family = "COMPRESSION_BREAKOUT";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.92;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_CONFIRM);

   if(!CouncilIsCompressionOrExpansionAllowedZone(env) || !CouncilIsCompressionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not compression zone";
      r.explanation   = "Squeeze release inactive outside compression context";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(CouncilIsExpansionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Already expanded";
      r.explanation   = "Squeeze release skipped (expansion already active)";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double atrNow  = CouncilGetATRPoints(PERIOD_M5, 14, 1);
   double atrPrev = CouncilGetATRPoints(PERIOD_M5, 14, 10);
   double atrLong = CouncilGetATRPoints(PERIOD_M5, 50, 10);

   bool squeezeOk =
      (atrNow > 0.0 && atrPrev > 0.0 && atrLong > 0.0) &&
      (atrPrev <= atrLong * 0.85) &&
      (atrNow >= atrPrev * 1.25) &&
      env.structure_ok;

   r.trigger_present = squeezeOk;
   r.trigger_quality = squeezeOk ? 0.72 : 0.0;

   if(!squeezeOk)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No squeeze release";
      r.explanation   = "ATR squeeze/release criteria not met";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double hi=0.0, lo=0.0;
   CouncilDecision d = COUNCIL_DECISION_WAIT;

   if(CouncilGetRecentRangeBounds(PERIOD_M5, 20, 1, hi, lo))
      CouncilCloseBreaksRange(PERIOD_M5, 1, hi, lo, MathMax(atrNow*0.15, 5.0), d);

   if(d == COUNCIL_DECISION_WAIT)
   {
      // fallback: direction via last candle
      double o = iOpen(_Symbol, PERIOD_M5, 1);
      double c = iClose(_Symbol, PERIOD_M5, 1);
      if(c > o) d = COUNCIL_DECISION_BUY;
      else if(c < o) d = COUNCIL_DECISION_SELL;
   }

   if(d == COUNCIL_DECISION_WAIT)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No direction";
      r.explanation   = "Squeeze release present but direction unclear";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision = d;

   double bodyPts = CouncilCandleBodyPoints(PERIOD_M5, 1);
   bool displacementOk = (atrNow > 0.0 && bodyPts >= atrNow * 0.70);

   r.confirmation_quality = displacementOk ? 0.76 : 0.58;

   r.environment_fit =
      (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) :
      (r.decision == COUNCIL_DECISION_SELL) ? CouncilEnvironmentFitSell(env) :
      env.total_score;

   r.conflict_score = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.45) +
      (r.confirmation_quality * 0.25) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.10);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason = "Squeeze release " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Volatility squeeze then release"
      " | atrPrev=" + DoubleToString(atrPrev, 0) +
      " | atrNow=" + DoubleToString(atrNow, 0) +
      " | bodyPts=" + DoubleToString(bodyPts, 0) +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text;

   CouncilFinalizeStrategyReport(r);
}


//---------------------------------------------------------
// Phase C2 — Expansion Pack
//---------------------------------------------------------

// Strategy 15: Volatility Breakout
void BuildCouncilStrategy_VolatilityBreakout(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "volatility_breakout";
   r.strategy_name   = "Volatility Breakout";
   r.strategy_family = "VOL_BREAKOUT";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.92;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_TREND_JUDGE);

   if(!CouncilIsCompressionOrExpansionAllowedZone(env) || !CouncilIsExpansionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not expansion zone";
      r.explanation   = "Volatility breakout inactive outside expansion context";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(CouncilIsRangeContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Range context";
      r.explanation   = "Volatility breakout skipped in range context";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double atrPts = CouncilGetATRPoints(PERIOD_M5, 14, 1);
   double bodyPts = CouncilCandleBodyPoints(PERIOD_M5, 1);
   double o = iOpen(_Symbol, PERIOD_M5, 1);
   double c = iClose(_Symbol, PERIOD_M5, 1);

   bool displacementOk = (atrPts > 0.0 && bodyPts >= atrPts * 1.10);
   bool momentumOk = env.momentum_ok && (env.volatility_score >= 0.65) && env.structure_ok;

   r.trigger_present = (displacementOk && momentumOk);
   r.trigger_quality = r.trigger_present ? 0.78 : 0.0;

   if(!r.trigger_present)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Weak expansion";
      r.explanation   = "Displacement/momentum not strong enough for vol breakout";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(c > o) r.decision = COUNCIL_DECISION_BUY;
   else if(c < o) r.decision = COUNCIL_DECISION_SELL;
   else r.decision = COUNCIL_DECISION_WAIT;

   if(r.decision == COUNCIL_DECISION_WAIT)
   {
      r.short_reason  = "No direction";
      r.explanation   = "Expansion present but candle direction neutral";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.confirmation_quality = 0.74;

   r.environment_fit =
      (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) :
      (r.decision == COUNCIL_DECISION_SELL) ? CouncilEnvironmentFitSell(env) :
      env.total_score;

   r.conflict_score = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.50) +
      (r.confirmation_quality * 0.20) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.10);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason = "Vol breakout " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Strong displacement in expansion"
      " | atrPts=" + DoubleToString(atrPts, 0) +
      " | bodyPts=" + DoubleToString(bodyPts, 0) +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text;

   CouncilFinalizeStrategyReport(r);
}


// Strategy 16: Expansion Continuation
void BuildCouncilStrategy_ExpansionContinuation(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "expansion_continuation";
   r.strategy_name   = "Expansion Continuation";
   r.strategy_family = "EXPANSION_CONTINUATION";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.90;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_TREND_JUDGE);

   if(!CouncilIsCompressionOrExpansionAllowedZone(env) || !CouncilIsExpansionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not expansion zone";
      r.explanation   = "Expansion continuation inactive outside expansion context";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   if(env.exhaustion_hint)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Exhaustion hint";
      r.explanation   = "Continuation skipped due to exhaustion risk hint";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double atrPts = CouncilGetATRPoints(PERIOD_M5, 14, 1);
   double bodyPrev = CouncilCandleBodyPoints(PERIOD_M5, 2);
   double o1 = iOpen(_Symbol, PERIOD_M5, 1);
   double c1 = iClose(_Symbol, PERIOD_M5, 1);
   double h2 = iHigh(_Symbol, PERIOD_M5, 2);
   double l2 = iLow(_Symbol, PERIOD_M5, 2);
   double o2 = iOpen(_Symbol, PERIOD_M5, 2);
   double c2 = iClose(_Symbol, PERIOD_M5, 2);

   bool bull = RT_M5TrendBull();
   bool bear = RT_M5TrendBear();

   bool pullbackSmall = (atrPts > 0.0) ? (bodyPrev <= atrPts * 0.60) : true;

   bool contBuy  = bull && (c2 < o2) && pullbackSmall && (c1 > h2);
   bool contSell = bear && (c2 > o2) && pullbackSmall && (c1 < l2);

   if(contBuy) r.decision = COUNCIL_DECISION_BUY;
   else if(contSell) r.decision = COUNCIL_DECISION_SELL;
   else r.decision = COUNCIL_DECISION_WAIT;

   r.trigger_present = (r.decision != COUNCIL_DECISION_WAIT);
   r.trigger_quality = r.trigger_present ? 0.72 : 0.0;

   if(!r.trigger_present)
   {
      r.short_reason  = "No continuation trigger";
      r.explanation   = "No clean pullback+resume continuation pattern";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.confirmation_quality = env.momentum_ok ? 0.72 : 0.58;

   r.environment_fit =
      (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) :
      (r.decision == COUNCIL_DECISION_SELL) ? CouncilEnvironmentFitSell(env) :
      env.total_score;

   r.conflict_score = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.45) +
      (r.confirmation_quality * 0.25) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.10);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason = "Expansion cont " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Expansion continuation after small pullback"
      " | atrPts=" + DoubleToString(atrPts, 0) +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text;

   CouncilFinalizeStrategyReport(r);
}


// Strategy 17: Micro Range Expansion
void BuildCouncilStrategy_MicroRangeExpansion(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &r
)
{
   InitCouncilStrategyReport(r);

   r.strategy_id     = "micro_range_expansion";
   r.strategy_name   = "Micro Range Expansion";
   r.strategy_family = "MICRO_RANGE_BREAK";
   r.direction_bias  = "BOTH";
   r.vote_weight     = 0.88;

   CouncilAssignStrategyMeta(env, r, COUNCIL_ROLE_SCOUT);

   if(!CouncilIsCompressionOrExpansionAllowedZone(env) || !CouncilIsExpansionContext(env))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "Not expansion zone";
      r.explanation   = "Micro range expansion inactive outside expansion context";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double hi=0.0, lo=0.0;
   if(!CouncilGetRecentRangeBounds(PERIOD_M1, 12, 1, hi, lo))
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No micro range";
      r.explanation   = "Failed to derive micro-range bounds (M1)";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   double widthPts = (hi - lo) / _Point;
   double atrPts   = CouncilGetATRPoints(PERIOD_M1, 14, 1);

   bool microOk =
      (atrPts > 0.0) &&
      (widthPts > 0.0) &&
      (widthPts <= atrPts * 2.0) &&
      env.structure_ok;

   r.trigger_present = microOk;
   r.trigger_quality = microOk ? 0.70 : 0.0;

   if(!microOk)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No micro compression";
      r.explanation   = "Micro-range too wide or structure weak";
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   CouncilDecision d;
   bool broke = CouncilCloseBreaksRange(PERIOD_M1, 1, hi, lo, MathMax(atrPts*0.10, 3.0), d);

   if(!broke || d == COUNCIL_DECISION_WAIT)
   {
      r.decision      = COUNCIL_DECISION_WAIT;
      r.short_reason  = "No micro breakout";
      r.explanation   = "Micro-range present but no breakout close";
      r.environment_fit = env.total_score;
      r.score_final   = 0.0;
      r.vote_weight   = 0.0;
      CouncilFinalizeStrategyReport(r);
      return;
   }

   r.decision = d;

   double bodyPts = CouncilCandleBodyPoints(PERIOD_M1, 1);
   bool dispOk = (atrPts > 0.0 && bodyPts >= atrPts * 0.60);

   r.confirmation_quality = dispOk ? 0.72 : 0.55;

   r.environment_fit =
      (r.decision == COUNCIL_DECISION_BUY) ? CouncilEnvironmentFitBuy(env) :
      (r.decision == COUNCIL_DECISION_SELL) ? CouncilEnvironmentFitSell(env) :
      env.total_score;

   r.conflict_score = CouncilConflictFromDirectionBias(r.direction_bias, r.decision);

   if(!env.tradable)
      r.blocked_by_filter = true;

   double rawScore =
      (r.trigger_quality * 0.45) +
      (r.confirmation_quality * 0.25) +
      (r.environment_fit * 0.25) -
      (r.conflict_score * 0.10);

   r.score_final = CouncilApplyZoneAdjustedScore(r, rawScore);
   r.vote_weight = CouncilApplyEligibilityWeight(r, r.vote_weight);

   r.short_reason = "Micro breakout " + CouncilDecisionReasonText(r.decision);

   r.explanation =
      "Micro-range breakout inside expansion"
      " | widthPts=" + DoubleToString(widthPts, 0) +
      " | atrPts=" + DoubleToString(atrPts, 0) +
      " | bodyPts=" + DoubleToString(bodyPts, 0) +
      " | role=" + r.role_name +
      " | eligibility=" + r.eligibility_text;

   CouncilFinalizeStrategyReport(r);
}

void RunCouncilStrategySet(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &s1,
   CouncilStrategyReport &s2,
   CouncilStrategyReport &s3,
   CouncilStrategyReport &s4,
   CouncilStrategyReport &s5,
   CouncilStrategyReport &s6,
   CouncilStrategyReport &s7,
   CouncilStrategyReport &s8,
   CouncilStrategyReport &s9,
   CouncilStrategyReport &s10,
   CouncilStrategyReport &s11,
   CouncilStrategyReport &s12,
   CouncilStrategyReport &s13,
   CouncilStrategyReport &s14,
   CouncilStrategyReport &s15,
   CouncilStrategyReport &s16,
   CouncilStrategyReport &s17
)
{
   BuildCouncilStrategy_SweepReversal(env, s1);
   if(StringLen(TrimString(s1.strategy_name)) == 0) s1.strategy_name = s1.strategy_id;

   BuildCouncilStrategy_BollingerReclaim(env, s2);
   if(StringLen(TrimString(s2.strategy_name)) == 0) s2.strategy_name = s2.strategy_id;

   BuildCouncilStrategy_TrendMomentum(env, s3);
   if(StringLen(TrimString(s3.strategy_name)) == 0) s3.strategy_name = s3.strategy_id;

   BuildCouncilStrategy_MFIReversalAssist(env, s4);
   if(StringLen(TrimString(s4.strategy_name)) == 0) s4.strategy_name = s4.strategy_id;

   BuildCouncilStrategy_TrendPullbackContinuation(env, s5);
   if(StringLen(TrimString(s5.strategy_name)) == 0) s5.strategy_name = s5.strategy_id;

   BuildCouncilStrategy_MomentumBreakoutContinuation(env, s6);
   if(StringLen(TrimString(s6.strategy_name)) == 0) s6.strategy_name = s6.strategy_id;

   BuildCouncilStrategy_MicroStructureReentry(env, s7);
   if(StringLen(TrimString(s7.strategy_name)) == 0) s7.strategy_name = s7.strategy_id;

   BuildCouncilStrategy_BreakdownMomentum(env, s8);
   if(StringLen(TrimString(s8.strategy_name)) == 0) s8.strategy_name = s8.strategy_id;

   BuildCouncilStrategy_LowerHighRejection(env, s9);
   if(StringLen(TrimString(s9.strategy_name)) == 0) s9.strategy_name = s9.strategy_id;

   BuildCouncilStrategy_MeanReversionBounce(env, s10);
   if(StringLen(TrimString(s10.strategy_name)) == 0) s10.strategy_name = s10.strategy_id;

   BuildCouncilStrategy_RangeEdgeFade(env, s11);
   if(StringLen(TrimString(s11.strategy_name)) == 0) s11.strategy_name = s11.strategy_id;

   BuildCouncilStrategy_FakeBreakReversal(env, s12);
   if(StringLen(TrimString(s12.strategy_name)) == 0) s12.strategy_name = s12.strategy_id;

   BuildCouncilStrategy_RangeCompressionBreakout(env, s13);
   if(StringLen(TrimString(s13.strategy_name)) == 0) s13.strategy_name = s13.strategy_id;

   BuildCouncilStrategy_VolatilitySqueezeRelease(env, s14);
   if(StringLen(TrimString(s14.strategy_name)) == 0) s14.strategy_name = s14.strategy_id;

   BuildCouncilStrategy_VolatilityBreakout(env, s15);
   if(StringLen(TrimString(s15.strategy_name)) == 0) s15.strategy_name = s15.strategy_id;

   BuildCouncilStrategy_ExpansionContinuation(env, s16);
   if(StringLen(TrimString(s16.strategy_name)) == 0) s16.strategy_name = s16.strategy_id;

   BuildCouncilStrategy_MicroRangeExpansion(env, s17);
   if(StringLen(TrimString(s17.strategy_name)) == 0) s17.strategy_name = s17.strategy_id;
}



#endif