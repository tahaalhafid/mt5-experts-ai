#ifndef __COUNCIL_ATTRIBUTION_INTELLIGENCE_MQH__
#define __COUNCIL_ATTRIBUTION_INTELLIGENCE_MQH__

#include "council_mode_types.mqh"

//---------------------------------------------------------
// Phase 8A: Council attribution extraction (best-effort)
//---------------------------------------------------------
double CouncilAttrClamp01(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string CouncilAttrDecisionToText(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)    return "BUY";
   if(d == COUNCIL_DECISION_SELL)   return "SELL";
   if(d == COUNCIL_DECISION_REJECT) return "REJECT";
   return "WAIT";
}

bool CouncilAttrStringInCsv(string csv, string token)
{
   string padded = "," + csv + ",";
   string target = "," + token + ",";
   return (StringFind(padded, target) >= 0);
}

void CouncilAttrAppendCsvUnique(string &csv, string token)
{
   token = TrimString(token);
   if(StringLen(token) <= 0) return;

   if(CouncilAttrStringInCsv(csv, token)) return;

   if(StringLen(csv) > 0) csv += ",";
   csv += token;
}

string CouncilAttrSafeToken(string s)
{
   s = TrimString(s);
   if(StringLen(s) <= 0) return "";
   StringReplace(s, "|", "/");
   StringReplace(s, ";", "/");
   StringReplace(s, "\n", " ");
   StringReplace(s, "\r", " ");
   return s;
}


string CouncilAttrRoleToText(CouncilStrategyReport &s)
{
   string t = CouncilAttrSafeToken(s.role_name);
   if(StringLen(t) > 0) return t;

   if(s.role == COUNCIL_ROLE_SCOUT)            return "SCOUT";
   if(s.role == COUNCIL_ROLE_CONFIRM)          return "CONFIRM";
   if(s.role == COUNCIL_ROLE_TREND_JUDGE)      return "TREND_JUDGE";
   if(s.role == COUNCIL_ROLE_EXHAUSTION_JUDGE) return "EXHAUSTION_JUDGE";
   if(s.role == COUNCIL_ROLE_GUARD)            return "GUARD";
   return "UNKNOWN_ROLE";
}

string CouncilAttrEligibilityToText(CouncilStrategyReport &s)
{
   string t = CouncilAttrSafeToken(s.eligibility_text);
   if(StringLen(t) > 0) return t;

   if(s.eligibility_state == COUNCIL_ELIGIBILITY_ACTIVE)       return "ACTIVE";
   if(s.eligibility_state == COUNCIL_ELIGIBILITY_REDUCED)      return "REDUCED";
   if(s.eligibility_state == COUNCIL_ELIGIBILITY_OBSERVE_ONLY) return "OBSERVE_ONLY";
   if(s.eligibility_state == COUNCIL_ELIGIBILITY_BLOCKED)      return "BLOCKED";
   return "ELIGIBLE_UNKNOWN";
}

string CouncilAttrAlignmentText(CouncilDecision finalDecision, CouncilDecision strategyDecision)
{
   if(finalDecision != COUNCIL_DECISION_BUY && finalDecision != COUNCIL_DECISION_SELL)
      return "UNKNOWN";

   if(strategyDecision == finalDecision)
      return "ALIGNED";

   if(strategyDecision == COUNCIL_DECISION_BUY || strategyDecision == COUNCIL_DECISION_SELL)
   {
      if(strategyDecision != finalDecision)
         return "OPPOSING";
   }

   return "NEUTRAL";
}

double CouncilAttrVoteStrengthProxy(CouncilStrategyReport &s)
{
   // Best-effort, conservative scaling to 0..1
   double raw = s.score_final * s.vote_weight;
   // vote_weight can exceed 1, clamp and compress
   double scaled = raw / (1.0 + raw);
   return CouncilAttrClamp01(scaled);
}

string CouncilAttrCompactOne(CouncilStrategyReport &s, string alignText)
{
   string id  = CouncilAttrSafeToken(s.strategy_id);
   string dir = CouncilAttrSafeToken(CouncilAttrDecisionToText(s.decision));
   string al  = CouncilAttrSafeToken(alignText);

   double w = CouncilAttrVoteStrengthProxy(s);
   double c = CouncilAttrClamp01(s.confidence);

   string r = CouncilAttrSafeToken(s.short_reason);
   if(StringLen(r) <= 0)
      r = CouncilAttrSafeToken(s.explanation);

   if(StringLen(r) > 80)
      r = StringSubstr(r, 0, 80);

   string role = CouncilAttrRoleToText(s);
   string elig = CouncilAttrEligibilityToText(s);

   return id + "|" + dir + "|" + al + "|" + role + "|" + elig + "|" + DoubleToString(w, 3) + "|" + DoubleToString(c, 3) + "|" + r;
}

double CouncilAttrComputeAttributionConfidence(double consensusStrength, double conflictScore, int aligned, int active)
{
   if(active <= 0) return 0.0;

   double alignFrac = (double)aligned / (double)active;
   double c = consensusStrength * (1.0 - conflictScore) * (0.60 + 0.40 * alignFrac);
   return CouncilAttrClamp01(c);
}

bool CouncilBuildDecisionAttributionV1(
   CouncilStrategyReport &reports[],
   int reportCount,
   CouncilAggregateReport &agg,
   CouncilEnvironmentReport &env,
   CouncilDecision finalDecision,
   CouncilDecisionAttribution &outAttr
)
{
   InitCouncilDecisionAttribution(outAttr);

   int active = 0;

   string alignedCsv = "";
   string opposingCsv = "";
   string neutralCsv = "";

   string compact = "";

   for(int i = 0; i < reportCount; i++)
   {
      CouncilStrategyReport s = reports[i];
      if(!s.valid || !s.enabled) continue;

      active++;

      string alignText = CouncilAttrAlignmentText(finalDecision, s.decision);

      if(alignText == "ALIGNED")
      {
         outAttr.aligned_count++;
         CouncilAttrAppendCsvUnique(alignedCsv, s.strategy_id);
      }
      else if(alignText == "OPPOSING")
      {
         outAttr.opposing_count++;
         CouncilAttrAppendCsvUnique(opposingCsv, s.strategy_id);
      }
      else
      {
         outAttr.neutral_count++;
         CouncilAttrAppendCsvUnique(neutralCsv, s.strategy_id);
      }

      string one = CouncilAttrCompactOne(s, alignText);
      if(StringLen(one) > 0)
      {
         if(StringLen(compact) > 0) compact += ";";
         compact += one;
      }
   }

   outAttr.available = (active > 0);

   outAttr.dominant_strategy_id = TrimString(agg.best_strategy_id);
   outAttr.dominant_strategy_role = "UNKNOWN_ROLE";
   outAttr.dominant_strategy_eligibility_state = "ELIGIBLE_UNKNOWN";

   // best-effort: extract dominant role/elig from reports
   for(int di = 0; di < reportCount; di++)
   {
      CouncilStrategyReport ds = reports[di];
      if(!ds.valid) continue;
      if(TrimString(ds.strategy_id) == outAttr.dominant_strategy_id)
      {
         outAttr.dominant_strategy_role = CouncilAttrRoleToText(ds);
         outAttr.dominant_strategy_eligibility_state = CouncilAttrEligibilityToText(ds);
         break;
      }
   }

   outAttr.consensus_strength = CouncilAttrClamp01(agg.consensus_strength);
   outAttr.conflict_score     = CouncilAttrClamp01(agg.conflict_score);

   outAttr.aligned_strategy_ids  = alignedCsv;
   outAttr.opposing_strategy_ids = opposingCsv;
   outAttr.neutral_strategy_ids  = neutralCsv;

   outAttr.strategies_compact = compact;

   outAttr.attribution_confidence =
      CouncilAttrComputeAttributionConfidence(outAttr.consensus_strength, outAttr.conflict_score, outAttr.aligned_count, active);

   // Human-readable dominant strategy name (observability only).
   string dominantName = "";
   if(StringLen(outAttr.dominant_strategy_id) > 0)
   {
      for(int si = 0; si < reportCount; si++)
      {
         if(reports[si].strategy_id == outAttr.dominant_strategy_id)
         {
            dominantName = reports[si].strategy_name;
            break;
         }
      }
   }


   outAttr.attribution_summary =
      "dominant=" + (StringLen(outAttr.dominant_strategy_id) > 0 ? (outAttr.dominant_strategy_id + (StringLen(dominantName) > 0 ? "(" + dominantName + ")" : "")) : "NONE") +
      " | aligned=" + IntegerToString(outAttr.aligned_count) +
      " | opp=" + IntegerToString(outAttr.opposing_count) +
      " | neut=" + IntegerToString(outAttr.neutral_count) +
      " | consensus=" + DoubleToString(outAttr.consensus_strength, 2) +
      " | conflict=" + DoubleToString(outAttr.conflict_score, 2);

   // Optionally include environment context (short)
   if(StringLen(TrimString(env.zone_name)) > 0)
      outAttr.attribution_summary += " | zone=" + env.zone_name;

   return outAttr.available;
}

#endif