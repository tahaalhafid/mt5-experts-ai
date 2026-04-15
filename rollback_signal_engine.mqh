#ifndef __ROLLBACK_SIGNAL_ENGINE_MQH__
#define __ROLLBACK_SIGNAL_ENGINE_MQH__

#include "core_logger.mqh"
#include "journal_analytics.mqh"

//---------------------------------------------------------
// Rollback Signal Engine v1 (hooks only, conservative)
//---------------------------------------------------------
enum RollbackSignalState
{
   RB_NONE = 0,
   RB_SOFT_WARNING,
   RB_HARD_TRIGGER
};

struct RollbackSignal
{
   RollbackSignalState state;
   string state_text;

   double rollback_signal_score;  // 0..1
   string rollback_signal_reason;

   bool soft_warning_active;
   bool hard_trigger_active;
};

string RB_StateText(RollbackSignalState s)
{
   if(s == RB_SOFT_WARNING) return "SOFT_ROLLBACK_WARNING";
   if(s == RB_HARD_TRIGGER) return "HARD_ROLLBACK_TRIGGER";
   return "NONE";
}

void InitRollbackSignal(RollbackSignal &s)
{
   s.state = RB_NONE;
   s.state_text = "NONE";
   s.rollback_signal_score = 0.0;
   s.rollback_signal_reason = "";
   s.soft_warning_active = false;
   s.hard_trigger_active = false;
}

bool ComputeRollbackSignalV1(
   FailureClusterResult &cluster,
   RegimePerformanceSummary &perf,
   int consecutive_losses,
   RollbackSignal &out
)
{
   InitRollbackSignal(out);

   double score = 0.0;
   string why = "";

   if(cluster.clustered_failure_detected)
   {
      score += 0.45 + cluster.failure_cluster_score * 0.35;
      why += "failure_cluster;";
   }

   if(perf.total_trades >= 10 && perf.overall_winrate <= 30.0)
   {
      score += 0.35;
      why += "low_winrate_window;";
   }

   if(consecutive_losses >= 4)
   {
      score += 0.40;
      why += "loss_streak;";
   }

   score = JA_Clamp01(score);

   out.rollback_signal_score = score;

   if(score >= 0.75)
   {
      out.state = RB_HARD_TRIGGER;
   }
   else if(score >= 0.45)
   {
      out.state = RB_SOFT_WARNING;
   }
   else
   {
      out.state = RB_NONE;
   }

   out.state_text = RB_StateText(out.state);
   out.soft_warning_active = (out.state == RB_SOFT_WARNING);
   out.hard_trigger_active = (out.state == RB_HARD_TRIGGER);
   out.rollback_signal_reason =
      "score=" + DoubleToString(score, 2) +
      "|cluster=" + (cluster.clustered_failure_detected ? "1" : "0") +
      "|wr=" + DoubleToString(perf.overall_winrate, 1) +
      "|losses=" + (string)consecutive_losses +
      "|why=" + why;

   return true;
}

#endif
