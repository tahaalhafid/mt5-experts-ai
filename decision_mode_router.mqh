#ifndef __DECISION_MODE_ROUTER_MQH__
#define __DECISION_MODE_ROUTER_MQH__

#include "strategy_runtime.mqh"
#include "council_mode_types.mqh"
#include "council_mode_runtime.mqh"
#include "council_adaptive_weights.mqh"

//---------------------------------------------------------
// Unified routed result
//---------------------------------------------------------
struct RoutedRuntimeEvaluation
{
   bool                 valid;
   string               active_mode;     // GATE / SCORE / HYBRID / COUNCIL
   RuntimeEvaluation    base_eval;       // legacy-compatible output
   CouncilRuntimeResult council;         // rich council result
   string               summary;
};

void InitRoutedRuntimeEvaluation(RoutedRuntimeEvaluation &r)
{
   r.valid = false;
   r.active_mode = "";

   r.base_eval.decision = RUNTIME_WAIT;
   r.base_eval.reason   = "";

   InitCouncilRuntimeResult(r.council);

   r.summary = "";
}

//---------------------------------------------------------
// Helpers
//---------------------------------------------------------
string NormalizeDecisionEngineModeEx(string mode)
{
   mode = TrimString(mode);

   if(mode == "GATE")
      return "GATE";

   if(mode == "SCORE")
      return "SCORE";

   if(mode == "HYBRID")
      return "HYBRID";

   if(mode == "COUNCIL")
      return "COUNCIL";

   return "HYBRID";
}

bool IsCouncilModeEnabled(CompiledPlan &plan)
{
   return (NormalizeDecisionEngineModeEx(plan.decision_engine_mode) == "COUNCIL");
}

RuntimeDecision ConvertCouncilDecisionToRuntimeDecision(CouncilDecision d)
{
   if(d == COUNCIL_DECISION_BUY)
      return RUNTIME_ENTER_BUY;

   if(d == COUNCIL_DECISION_SELL)
      return RUNTIME_ENTER_SELL;

   if(d == COUNCIL_DECISION_REJECT)
      return RUNTIME_REJECT;

   return RUNTIME_WAIT;
}

string BuildCouncilSummaryLine(CouncilRuntimeResult &r)
{
   string s =
      "Mode=COUNCIL"
      " | Final=" + CouncilDecisionToText(r.final_decision) +
      " | Zone=" + r.env.zone_name +
      " | ZoneConf=" + DoubleToString(r.env.zone_confidence, 2) +
      " | PrefStyle=" + r.env.preferred_style_text +
      " | EnvScore=" + DoubleToString(r.env.total_score, 2) +
      " | CouncilQ=" + DoubleToString(r.aggregate.council_quality, 2) +
      " | Consensus=" + DoubleToString(r.aggregate.consensus_strength, 2) +
      " | ConsensusLabel=" + r.aggregate.consensus_label +
      " | Conflict=" + DoubleToString(r.aggregate.conflict_score, 2) +
      " | Dominant=" + r.aggregate.dominant_side;

   if(StringLen(TrimString(r.aggregate.best_strategy_id)) > 0)
      s += " | Best=" + r.aggregate.best_strategy_id;

   if(StringLen(TrimString(r.env.regime_summary)) > 0)
      s += " | Regime=" + r.env.regime_summary;

   return s;
}

//---------------------------------------------------------
// Main router
//---------------------------------------------------------
void EvaluateDecisionModeRoutedEx(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   bool isShadow,
   RoutedRuntimeEvaluation &routed
)
{
   InitRoutedRuntimeEvaluation(routed);

   string mode = NormalizeDecisionEngineModeEx(plan.decision_engine_mode);
   routed.active_mode = mode;

   //------------------------------------------------------
   // Legacy modes
   //------------------------------------------------------
   if(mode == "GATE" || mode == "SCORE" || mode == "HYBRID")
   {
      EvaluateCompiledPlan(plan, m1, m5, routed.base_eval);

      routed.valid = true;
      routed.summary =
         "Legacy routed mode=" + mode +
         " | decision=" + IntegerToString((int)routed.base_eval.decision) +
         " | reason=" + routed.base_eval.reason;
      return;
   }

   //------------------------------------------------------
   // Council mode
   //------------------------------------------------------
   if(mode == "COUNCIL")
   {
      // Adaptive council weighting hook (no effect unless enabled)
      CouncilAdaptiveWeights_Set(plan.council_adaptive_weights_enabled, "V1", "plan_flag");

      string councilLog = "";

      // Generate a fresh decision_id for this council cycle BEFORE RunCouncilModePipeline
      // writes the DECISION_SNAPSHOT. This guarantees the DS decision_id and the trade
      // comment always carry the same ID, fixing 86.7% attribution failure on EA restarts.
      if(!isShadow)
         gCurrentDecisionId = PJ_MakeDecisionId();

      if(!RunCouncilModePipeline(
            routed.council,
            (isShadow ? "" : "AI\\council_feedback.json"),
            (isShadow ? "" : "AI\\council_report.txt"),
            (isShadow ? "" : "AI\\council_memory.txt"),
            councilLog,
            gCurrentDecisionId))
      {
         routed.base_eval.decision = RUNTIME_REJECT;
         routed.base_eval.reason   = "COUNCIL runtime failed | " + councilLog;

         routed.valid = true;
         routed.summary = routed.base_eval.reason;
         return;
      }

      routed.base_eval.decision =
         ConvertCouncilDecisionToRuntimeDecision(routed.council.final_decision);

      routed.base_eval.reason =
         BuildCouncilSummaryLine(routed.council) +
         " | " + routed.council.detailed_reason;

      routed.valid = true;
      routed.summary = routed.base_eval.reason;
      return;
   }

   //------------------------------------------------------
   // Fallback
   //------------------------------------------------------
   EvaluateCompiledPlan(plan, m1, m5, routed.base_eval);

   routed.valid = true;
   routed.active_mode = "HYBRID";
   routed.summary =
      "Unknown mode fallback to HYBRID"
      " | reason=" + routed.base_eval.reason;
}


// Backward-compatible wrapper
void EvaluateDecisionModeRouted(
   CompiledPlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   RoutedRuntimeEvaluation &routed
)
{
   EvaluateDecisionModeRoutedEx(plan, m1, m5, false, routed);
}



#endif
