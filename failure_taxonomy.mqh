
#ifndef __FAILURE_TAXONOMY_MQH__
#define __FAILURE_TAXONOMY_MQH__

#include "trade_feedback.mqh"
#include "unified_confidence.mqh"
#include "regime_classification_layer_v1.mqh"

//---------------------------------------------------------
// Failure Taxonomy v1 (rule-based, conservative)
// - Produces a failure_class even when information is partial
// - Distinguishes decision-context vs trade-result classification
//---------------------------------------------------------
enum FailureClass
{
   FAIL_LATE_ENTRY = 0,
   FAIL_CHOP,
   FAIL_WEAK_CONSENSUS,
   FAIL_VOLATILITY_SPIKE,
   FAIL_SESSION_EDGE,
   FAIL_BAD_LOCATION,
   FAIL_OVER_FILTER,
   FAIL_PREMATURE_EXIT,
   FAIL_LOW_QUALITY_TRADE,
   FAIL_UNKNOWN
};

struct FailureClassification
{
   string failure_class;          // required label
   string failure_reason_summary; // short debug reason
   double failure_severity;       // 0..1 (optional-ish, provided)
   string failure_basis;          // DECISION / TRADE / BOTH
};

string FailureClassText(FailureClass c)
{
   if(c == FAIL_LATE_ENTRY)         return "LATE_ENTRY_FAILURE";
   if(c == FAIL_CHOP)              return "CHOP_FAILURE";
   if(c == FAIL_WEAK_CONSENSUS)    return "WEAK_CONSENSUS_FAILURE";
   if(c == FAIL_VOLATILITY_SPIKE)  return "VOLATILITY_SPIKE_FAILURE";
   if(c == FAIL_SESSION_EDGE)      return "SESSION_EDGE_FAILURE";
   if(c == FAIL_BAD_LOCATION)      return "BAD_LOCATION_FAILURE";
   if(c == FAIL_OVER_FILTER)       return "OVER_FILTER_FAILURE";
   if(c == FAIL_PREMATURE_EXIT)    return "PREMATURE_EXIT_FAILURE";
   if(c == FAIL_LOW_QUALITY_TRADE) return "LOW_QUALITY_TRADE_FAILURE";
   return "UNKNOWN_FAILURE";
}

void InitFailureClassification(FailureClassification &f)
{
   f.failure_class = "UNKNOWN_FAILURE";
   f.failure_reason_summary = "";
   f.failure_severity = 0.25;
   f.failure_basis = "UNKNOWN";
}

bool FT_TextHas(string hay, string needleLower)
{
   string s = hay;
   StringToLower(s);
   return (StringFind(s, needleLower) >= 0);
}

// Overload to avoid implicit bool->string conversions at call sites
bool FT_TextHas(bool hay, string needleLower)
{
   string s = (hay ? "true" : "false");
   return FT_TextHas(s, needleLower);
}

//---------------------------------------------------------
// Decision-level classification (mostly OVER_FILTER vs UNKNOWN)
//---------------------------------------------------------
bool ClassifyDecisionFailureV1(
   UnifiedDecisionConfidence &conf,
   RegimeClassification &reg,
   string policy_result,
   string council_summary,
   FailureClassification &out
)
{
   InitFailureClassification(out);
   out.failure_basis = "DECISION";

   // Only relevant when we *wanted* to trade but got blocked or rejected.
   bool wantedTrade = (conf.direction == "BUY" || conf.direction == "SELL");

   if(!wantedTrade)
      return true;

   bool blocked = (!conf.final_permission) || FT_TextHas(policy_result, "blocked");

   if(blocked)
   {
      // Over-filter if regime looks decent and confidence is decent
      if(reg.tradability_score >= 0.55 && reg.regime_confidence >= 0.55 && conf.confidence_score >= 0.55)
      {
         out.failure_class = "OVER_FILTER_FAILURE";
         out.failure_reason_summary = "blocked_with_decent_quality";
         out.failure_severity = 0.45;
         return true;
      }

      out.failure_class = "UNKNOWN_FAILURE";
      out.failure_reason_summary = "blocked_low_or_unknown_quality";
      out.failure_severity = 0.30;
      return true;
   }

   // If it was rejected (not blocked) and council says weak consensus, classify that.
   if(FT_TextHas(council_summary, "weak") || FT_TextHas(council_summary, "conflict") || FT_TextHas(council_summary, "low"))
   {
      out.failure_class = "WEAK_CONSENSUS_FAILURE";
      out.failure_reason_summary = "council_weak_consensus";
      out.failure_severity = 0.40;
      return true;
   }

   return true;
}

//---------------------------------------------------------
// Trade-level classification (v1 conservative heuristics)
//---------------------------------------------------------
bool ClassifyTradeFailureV1(TradeFeedbackRecord &fb, FailureClassification &out)
{
   InitFailureClassification(out);
   out.failure_basis = "TRADE";

   bool isLoss = (fb.result == "LOSS");
   bool isFlat = (fb.result == "FLAT");

   if(!isLoss && !isFlat)
      return true; // winning trade => no failure classification needed (keep UNKNOWN)

   // VOLATILITY_SPIKE: high vol regimes + loss/flat
   if(fb.regime_label == "EXPANSION" || fb.rc_volatility_state == "HIGH_VOL")
   {
      out.failure_class = "VOLATILITY_SPIKE_FAILURE";
      out.failure_reason_summary = "loss_in_high_vol";
      out.failure_severity = 0.65;
      return true;
   }

   // CHOP: dirty range or noisy structure + loss
   if(fb.regime_label == "RANGE_DIRTY" || fb.rc_structure_state == "NOISY")
   {
      out.failure_class = "CHOP_FAILURE";
      out.failure_reason_summary = "loss_in_dirty_range";
      out.failure_severity = 0.55;
      return true;
   }

   // LATE_ENTRY: reversal risk context (if present) + loss
   if(fb.regime_label == "REVERSAL_RISK" || FT_TextHas(fb.rc_summary_reason, "reversal"))
   {
      out.failure_class = "LATE_ENTRY_FAILURE";
      out.failure_reason_summary = "loss_near_reversal_risk";
      out.failure_severity = 0.55;
      return true;
   }

   // BAD_LOCATION: high spread + loss/flat
   if(fb.spread_points >= 1500.0)
   {
      out.failure_class = "BAD_LOCATION_FAILURE";
      out.failure_reason_summary = "loss_with_wide_spread";
      out.failure_severity = 0.50;
      return true;
   }

   // LOW_QUALITY_TRADE: low tradability or low regime confidence
   if(fb.tradability_score <= 0.35 || fb.regime_confidence <= 0.45)
   {
      out.failure_class = "LOW_QUALITY_TRADE_FAILURE";
      out.failure_reason_summary = "loss_with_low_quality_regime";
      out.failure_severity = 0.45;
      return true;
   }

   out.failure_class = "UNKNOWN_FAILURE";
   out.failure_reason_summary = "insufficient_signals";
   out.failure_severity = 0.30;
   return true;
}

#endif