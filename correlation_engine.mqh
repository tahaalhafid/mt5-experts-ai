#ifndef __CORRELATION_ENGINE_MQH__
#define __CORRELATION_ENGINE_MQH__

#include "core_logger.mqh"
#include "performance_journal.mqh"
#include "trade_feedback.mqh"

#include "journal_analytics.mqh"

//---------------------------------------------------------
// Wrapper usage map (Phase 9B)
// Active: Correlation_RegisterTradeOpenV5() used by main_ea runtime.
// Legacy: V2/V3/V4 retained for compatibility and historical replay.
//---------------------------------------------------------
//---------------------------------------------------------
// Correlation Engine v1
// - Primary: position_id / entry_deal_id from TRADE_OPEN journal records
// - Secondary: deal comment "D:<decision_id>"
// - Tertiary: time proximity / symbol + magic (conservative)
//---------------------------------------------------------
struct TradeCorrelation
{
   string decision_id;
   string correlated_decision_id;

   ulong  position_id;
   ulong  entry_deal_id;
   ulong  entry_order_id;
   ulong  close_deal_id;

   // Optional metadata (v4+). Used for journal parity; safe defaults in InitTradeCorrelation.
   long     magic;
   string   order_type;
   string   timeframe;
   datetime entry_time;
   double   volume;

   string correlation_method;   // POSITION_ID / COMMENT / PROXIMITY / NONE
   double correlation_quality;  // 0..1
};

void InitTradeCorrelation(TradeCorrelation &c)
{
   c.decision_id = "";
   c.correlated_decision_id = "";
   c.position_id = 0;
   c.entry_deal_id = 0;
   c.entry_order_id = 0;
   c.close_deal_id = 0;
   c.correlation_method = "NONE";
   c.correlation_quality = 0.0;
   c.magic = 0;
   c.order_type = "";
   c.timeframe = "";
   c.entry_time = 0;
   c.volume = 0.0;
}

bool Correlation_RegisterTradeOpen(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   TradeCorrelation &out
)
{
   InitTradeCorrelation(out);
   out.decision_id = decision_id;
   out.entry_deal_id = entry_deal_id;
   out.entry_order_id = entry_order_id;
   out.correlation_method = "TRADE_OPEN";

   if(entry_deal_id == 0 && entry_order_id == 0)
   {
      out.correlation_quality = 0.20;
      return false;
   }

   ulong position_id = 0;
   if(entry_deal_id != 0)
      position_id = (ulong)HistoryDealGetInteger(entry_deal_id, DEAL_POSITION_ID);

   out.position_id = position_id;
   out.correlation_quality = (position_id != 0 ? 0.95 : 0.70);

   string logMessage = "";
   JournalAppendTradeOpen(decision_id, entry_deal_id, entry_order_id, position_id, logMessage);
   LogStateOnce(logMessage);

   return true;
}


bool Correlation_RegisterTradeOpenV2(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   TradeCorrelation &out
)
{
   InitTradeCorrelation(out);
   out.decision_id = decision_id;
   out.entry_deal_id = entry_deal_id;
   out.entry_order_id = entry_order_id;
   out.correlation_method = "TRADE_OPEN";

   if(entry_deal_id == 0 && entry_order_id == 0)
   {
      out.correlation_quality = 0.20;
      return false;
   }

   ulong position_id = 0;
   if(entry_deal_id != 0)
      position_id = (ulong)HistoryDealGetInteger(entry_deal_id, DEAL_POSITION_ID);

   out.position_id = position_id;
   out.correlation_quality = (position_id != 0 ? 0.95 : 0.70);

   string logMessage = "";
   if(!JournalAppendTradeOpenV2(
         decision_id, entry_deal_id, entry_order_id, position_id,
         magic, order_type, tf, entry_time, volume,
         logMessage
      ))
   {
      // fallback to v1 writer
      JournalAppendTradeOpen(decision_id, entry_deal_id, entry_order_id, position_id, logMessage);
   }

   LogStateOnce(logMessage);
   return true;
}

bool Correlation_RegisterTradeOpenV3(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   string entry_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   TradeCorrelation &out
)
{
   // Backward-compatible wrapper: v3 -> v4 with missing fields defaulted
   return Correlation_RegisterTradeOpenV4(
      decision_id,
      entry_deal_id,
      entry_order_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      0.0,
      0.0,
      strategy_regime_fit_score,
      decision_quality_score,
      entry_quality_label,
      "",
      "",
      strategy_regime_fit_label,
      decision_quality_label,
      out
   );
}

bool Correlation_RegisterTradeOpenV4(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double entry_edge_score,
   double follow_through_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   string entry_quality_label,
   string entry_edge_label,
   string follow_through_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   TradeCorrelation &out
)
{
   InitTradeCorrelation(out);
   out.decision_id = decision_id;
   out.entry_deal_id = entry_deal_id;
   out.entry_order_id = entry_order_id;
   out.magic = magic;
   out.order_type = order_type;
   out.timeframe = tf;
   out.entry_time = entry_time;
   out.volume = volume;

   // Derive position id if available (best-effort)
   out.position_id = 0;
   if(entry_deal_id > 0)
   {
      long pid = (long)HistoryDealGetInteger(entry_deal_id, DEAL_POSITION_ID);
      if(pid > 0) out.position_id = (ulong)pid;
   }

   string logMessage = "";
   if(!JournalAppendTradeOpenV4(
      decision_id,
      entry_deal_id,
      entry_order_id,
      out.position_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      entry_edge_score,
      follow_through_quality_score,
      strategy_regime_fit_score,
      decision_quality_score,
      entry_quality_label,
      entry_edge_label,
      follow_through_quality_label,
      strategy_regime_fit_label,
      decision_quality_label,
      logMessage))
   {
      // Still return true to avoid breaking runtime flow; correlation remains best-effort
      out.correlation_method = "POSITION_ID";
      out.correlation_quality = 0.70;
      return true;
   }

   out.correlation_method = "POSITION_ID";
   out.correlation_quality = 0.85;
   return true;
}


bool Correlation_RegisterTradeOpenV5(
   string decision_id,
   ulong entry_deal_id,
   ulong entry_order_id,
   long magic,
   string order_type,
   string tf,
   datetime entry_time,
   double volume,
   double entry_quality_score,
   double entry_edge_score,
   double follow_through_quality_score,
   double strategy_regime_fit_score,
   double decision_quality_score,
   double expected_rr_estimate,
   double execution_geometry_score,
   string execution_geometry_label,
   string entry_quality_label,
   string entry_edge_label,
   string follow_through_quality_label,
   string strategy_regime_fit_label,
   string decision_quality_label,
   double requested_entry_price,
   double requested_stop_loss,
   double requested_take_profit,
   double actual_fill_price,
   double slippage_points,
   double base_confidence_score,
   double final_confidence_score,
   double policy_risk_score,
   double regime_fit_score,
   double learning_confidence_delta,
   double learning_caution_score,
   string learning_state_code,
   int learning_evidence_count,
   bool learning_evidence_threshold_met,
   bool learning_zero_influence_due_to_insufficient_evidence,
   double advisory_relevance_score,
   bool advisory_contradiction_flag,
   bool advisory_hold_bias_active,
   string support_resistance_confluence_state,
   string canonical_level_state,
   string sr_interaction_bucket,
   bool sr_confluence_flag,
   bool sr_rejection_risk_flag,
   bool sr_continuation_obstructed_flag,
   bool sr_canonical_near_flag,
   bool sr_conflicted_flag,
   double nearest_support_price,
   double nearest_resistance_price,
   int nearest_support_distance_points,
   int nearest_resistance_distance_points,
   string level_interaction_type,
   bool level_context_supported,
   bool level_context_obstructed,
   bool level_context_degraded,
   string support_resistance_observation_source,
   bool advisory_available,
   bool advisory_eligible,
   bool advisory_shadow_attached,
   AdvisoryEnvelopeFields &advisory,
   DecisionReasoningFields &decision_reasoning,
   TradeCorrelation &out
)
{
   InitTradeCorrelation(out);
   out.decision_id = decision_id;
   out.entry_deal_id = entry_deal_id;
   out.entry_order_id = entry_order_id;
   out.correlation_method = "NONE";
   out.correlation_quality = 0.0;

   // Resolve position_id if possible.
   ulong position_id = 0;
   if(entry_deal_id > 0)
   {
      if(HistorySelect(entry_time - 3600, entry_time + 3600))
      {
         if(HistoryDealSelect(entry_deal_id))
         {
            position_id = (ulong)HistoryDealGetInteger(entry_deal_id, DEAL_POSITION_ID);
         }
      }
   }

   out.position_id = position_id;
   out.correlation_method = (position_id > 0 ? "POSITION_ID" : "DEAL_ONLY");
   out.correlation_quality = (position_id > 0 ? 0.90 : 0.50);

   // Persist TRADE_OPEN (v5) with richer metadata.
   JournalAppendTradeOpenV5(
      gPlan,
      decision_id,
      entry_deal_id,
      entry_order_id,
      position_id,
      magic,
      order_type,
      tf,
      entry_time,
      volume,
      entry_quality_score,
      entry_edge_score,
      follow_through_quality_score,
      strategy_regime_fit_score,
      decision_quality_score,
      expected_rr_estimate,
      execution_geometry_score,
      execution_geometry_label,
      entry_quality_label,
      entry_edge_label,
      follow_through_quality_label,
      strategy_regime_fit_label,
      decision_quality_label,
      requested_entry_price,
      requested_stop_loss,
      requested_take_profit,
      actual_fill_price,
      slippage_points,
      base_confidence_score,
      final_confidence_score,
      policy_risk_score,
      regime_fit_score,
      learning_confidence_delta,
      learning_caution_score,
      learning_state_code,
      learning_evidence_count,
      learning_evidence_threshold_met,
      learning_zero_influence_due_to_insufficient_evidence,
      advisory_relevance_score,
      advisory_contradiction_flag,
      advisory_hold_bias_active,
      support_resistance_confluence_state,
      canonical_level_state,
      sr_interaction_bucket,
      sr_confluence_flag,
      sr_rejection_risk_flag,
      sr_continuation_obstructed_flag,
      sr_canonical_near_flag,
      sr_conflicted_flag,
      nearest_support_price,
      nearest_resistance_price,
      nearest_support_distance_points,
      nearest_resistance_distance_points,
      level_interaction_type,
      level_context_supported,
      level_context_obstructed,
      level_context_degraded,
      support_resistance_observation_source,
      advisory_available,
      advisory_eligible,
      advisory_shadow_attached,
      advisory,
      decision_reasoning
   );

   return true;
}


//---------------------------------------------------------
// Resolve decision_id for a closed deal ticket (DEAL_ENTRY_OUT)
//---------------------------------------------------------
bool Correlation_ResolveForClosedDeal(
   ulong closeDealTicket,
   ulong magic,
   string fallback_decision_id,
   TradeCorrelation &out
)
{
   InitTradeCorrelation(out);

   if(closeDealTicket == 0)
      return false;

   out.close_deal_id = closeDealTicket;

   string symbol = HistoryDealGetString(closeDealTicket, DEAL_SYMBOL);
   long mg = HistoryDealGetInteger(closeDealTicket, DEAL_MAGIC);
   long entry = HistoryDealGetInteger(closeDealTicket, DEAL_ENTRY);

   if(symbol != _Symbol || (ulong)mg != magic || entry != DEAL_ENTRY_OUT)
      return false;

   ulong positionId = (ulong)HistoryDealGetInteger(closeDealTicket, DEAL_POSITION_ID);
   out.position_id = positionId;

   // 1) try comment extraction from ENTRY deal (broker overwrites close deal comment)
   string did = "";
   if(positionId != 0)
   {
      int histTotal = HistoryDealsTotal();
      for(int hi = histTotal - 1; hi >= 0; hi--)
      {
         ulong hTicket = HistoryDealGetTicket(hi);
         if(hTicket == 0) continue;
         long hEntry = HistoryDealGetInteger(hTicket, DEAL_ENTRY);
         if(hEntry != DEAL_ENTRY_IN) continue;
         ulong hPosId = (ulong)HistoryDealGetInteger(hTicket, DEAL_POSITION_ID);
         if(hPosId != positionId) continue;
         string entryComment = HistoryDealGetString(hTicket, DEAL_COMMENT);
         ExtractDecisionIdFromComment(entryComment, did);
         break;
      }
   }
   if(StringLen(did) > 0)
   {
      out.decision_id = did;
      out.correlation_method = "COMMENT";
      out.correlation_quality = 0.60;
      // still attempt to upgrade via position_id
   }

   // 2) primary: search journal TRADE_OPEN records by position_id
   if(positionId != 0)
   {
      string matchedId = "";
      string method = "";
      double q = 0.0;

      if(PJ_FindDecisionIdByPositionId(PERF_JOURNAL_PATH, positionId, 2000, matchedId, method, q))
      {
         out.decision_id = matchedId;
         out.correlation_method = method;
         out.correlation_quality = q;
         return true;
      }
   }

   // 3) fallback: use comment-derived decision_id if present
   if(StringLen(out.decision_id) > 0)
      return true;

   // 4) last resort: use provided fallback (e.g., last entry decision id)
   if(StringLen(fallback_decision_id) > 0)
   {
      out.decision_id = fallback_decision_id;
      out.correlation_method = "FALLBACK";
      out.correlation_quality = 0.25;
      return true;
   }

   return true;
}

#endif
