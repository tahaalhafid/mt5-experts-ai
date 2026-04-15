#ifndef __EXIT_INTELLIGENCE_MQH__
#define __EXIT_INTELLIGENCE_MQH__

#include "core_logger.mqh"
#include "trade_feedback.mqh"
#include "regime_classification_layer_v1.mqh"

//---------------------------------------------------------
// Exit Intelligence v1 (rule-based, conservative)
//---------------------------------------------------------
struct ExitIntelligence
{
   string exit_class;
   string exit_quality;
   string exit_reason_summary;
   string exit_basis;
};

void InitExitIntelligence(ExitIntelligence &e)
{
   e.exit_class = "MANUAL_OR_OTHER_EXIT";
   e.exit_quality = "UNKNOWN_EXIT_QUALITY";
   e.exit_reason_summary = "";
   e.exit_basis = "";
}

string EI_DealReasonText(long reason)
{
   if(reason == DEAL_REASON_TP) return "TP";
   if(reason == DEAL_REASON_SL) return "SL";
   if(reason == DEAL_REASON_SO) return "SO";
   if(reason == DEAL_REASON_ROLLOVER) return "ROLLOVER";
   if(reason == DEAL_REASON_CLIENT) return "CLIENT";
   if(reason == DEAL_REASON_EXPERT) return "EXPERT";
   if(reason == DEAL_REASON_MOBILE) return "MOBILE";
   if(reason == DEAL_REASON_WEB) return "WEB";
   return "OTHER";
}

bool ClassifyExitIntelligenceV1(
   ulong closeDealTicket,
   double profit,
   string regime_label_at_close,
   string rc_volatility_state,
   ExitIntelligence &out
)
{
   InitExitIntelligence(out);

   if(closeDealTicket == 0)
      return false;

   long entry = HistoryDealGetInteger(closeDealTicket, DEAL_ENTRY);
   if(entry != DEAL_ENTRY_OUT)
      return false;

   long reason = HistoryDealGetInteger(closeDealTicket, DEAL_REASON);
   string rtxt = EI_DealReasonText(reason);

   out.exit_basis = "DEAL_REASON:" + rtxt;

   if(reason == DEAL_REASON_TP)
   {
      out.exit_class = "TP_ACHIEVED";
      out.exit_quality = "GOOD_EXIT";
      out.exit_reason_summary = "closed_by_tp";
      return true;
   }

   if(reason == DEAL_REASON_SL)
   {
      out.exit_class = "DEFENSIVE_EXIT";
      out.exit_quality = "UNKNOWN_EXIT_QUALITY";
      out.exit_reason_summary = "closed_by_sl";
      return true;
   }

   // volatility abnormal exit heuristic
   if(rc_volatility_state == "HIGH_VOL" && profit < 0.0)
   {
      out.exit_class = "VOLATILITY_ABNORMAL_EXIT";
      out.exit_quality = "UNKNOWN_EXIT_QUALITY";
      out.exit_reason_summary = "high_vol_loss_close";
      return true;
   }

   // regime invalidation heuristic
   if((regime_label_at_close == "NO_TRADE" || regime_label_at_close == "RANGE_DIRTY") && profit < 0.0)
   {
      out.exit_class = "REGIME_INVALIDATION_EXIT";
      out.exit_quality = "UNKNOWN_EXIT_QUALITY";
      out.exit_reason_summary = "bad_regime_loss_close";
      return true;
   }

   // momentum collapse heuristic (profit flips negative, unknown reason)
   if(profit < 0.0)
   {
      out.exit_class = "MOMENTUM_COLLAPSE_EXIT";
      out.exit_quality = "UNKNOWN_EXIT_QUALITY";
      out.exit_reason_summary = "loss_close_other_reason";
      return true;
   }

   // time stop heuristic: very small profit/loss and expert close
   if((reason == DEAL_REASON_EXPERT) && MathAbs(profit) <= 0.05)
   {
      out.exit_class = "TIME_STOP_EXIT";
      out.exit_quality = "UNKNOWN_EXIT_QUALITY";
      out.exit_reason_summary = "expert_flat_close";
      return true;
   }

   out.exit_class = "MANUAL_OR_OTHER_EXIT";
   out.exit_quality = "UNKNOWN_EXIT_QUALITY";
   out.exit_reason_summary = "reason=" + rtxt;
   return true;
}

#endif
