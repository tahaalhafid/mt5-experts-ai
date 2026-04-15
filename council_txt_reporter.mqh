#ifndef __COUNCIL_TXT_REPORTER_MQH__
#define __COUNCIL_TXT_REPORTER_MQH__

#include "config_loader.mqh"
#include "council_mode_types.mqh"
#include "council_feedback.mqh"
#include "council_memory.mqh"


// Forward declaration to reduce header coupling
bool BuildZoneCoverageReport(CouncilStrategyReport &reports[], int reportCount, CouncilEnvironmentReport &env, ZoneCoverageReport &out);
//---------------------------------------------------------
// Basic helpers
//---------------------------------------------------------
bool SaveCouncilReportText(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

string CouncilBoolText(bool v)
{
   return (v ? "YES" : "NO");
}

string CouncilDoubleText(double v, int digits = 2)
{
   return DoubleToString(v, digits);
}

string CouncilDateTimeText(datetime t)
{
   if(t <= 0)
      return "0";

   return TimeToString(t, TIME_DATE | TIME_SECONDS);
}

string CouncilSafeText(string s)
{
   s = TrimString(s);
   if(StringLen(s) <= 0)
      return "-";
   return s;
}


string CouncilFindStrategyNameByIdEx(string id, CouncilStrategyReport &reports[], int reportCount)
{
   if(StringLen(id) <= 0) return "";
   for(int i = 0; i < reportCount; i++)
   {
      if(reports[i].strategy_id == id)
         return reports[i].strategy_name;
   }
   return "";
}

string CouncilFormatStrategyIdNameEx(string id, CouncilStrategyReport &reports[], int reportCount)
{
   string name = CouncilFindStrategyNameByIdEx(id, reports, reportCount);
   if(StringLen(name) <= 0) return id;
   return id + "(" + name + ")";
}

string CouncilFormatSupportStrategiesEx(string idsCsv, CouncilStrategyReport &reports[], int reportCount)
{
   idsCsv = TrimString(idsCsv);
   if(StringLen(idsCsv) <= 0) return "";

   string out = "";
   int p = 0;
   while(true)
   {
      int comma = StringFind(idsCsv, ",", p);
      string tok = "";
      if(comma < 0) tok = StringSubstr(idsCsv, p);
      else tok = StringSubstr(idsCsv, p, comma - p);

      tok = TrimString(tok);
      if(StringLen(tok) > 0)
      {
         if(StringLen(out) > 0) out += ",";
         out += CouncilFormatStrategyIdNameEx(tok, reports, reportCount);
      }

      if(comma < 0) break;
      p = comma + 1;
   }
   return out;
}



string CouncilFindStrategyNameById(string id, CouncilStrategyReport &s1, CouncilStrategyReport &s2, CouncilStrategyReport &s3, CouncilStrategyReport &s4, CouncilStrategyReport &s5)
{
   CouncilStrategyReport reports[5];
   reports[0] = s1; reports[1] = s2; reports[2] = s3; reports[3] = s4; reports[4] = s5;
   return CouncilFindStrategyNameByIdEx(id, reports, 5);
}

string CouncilFormatStrategyIdName(string id, CouncilStrategyReport &s1, CouncilStrategyReport &s2, CouncilStrategyReport &s3, CouncilStrategyReport &s4, CouncilStrategyReport &s5)
{
   CouncilStrategyReport reports[5];
   reports[0] = s1; reports[1] = s2; reports[2] = s3; reports[3] = s4; reports[4] = s5;
   return CouncilFormatStrategyIdNameEx(id, reports, 5);
}

string CouncilFormatSupportStrategies(string idsCsv, CouncilStrategyReport &s1, CouncilStrategyReport &s2, CouncilStrategyReport &s3, CouncilStrategyReport &s4, CouncilStrategyReport &s5)
{
   CouncilStrategyReport reports[5];
   reports[0] = s1; reports[1] = s2; reports[2] = s3; reports[3] = s4; reports[4] = s5;
   return CouncilFormatSupportStrategiesEx(idsCsv, reports, 5);
}

void CouncilAppendLine(string &out, string text)
{
   out += text + "\n";
}

void CouncilAppendSeparator(string &out)
{
   out += "------------------------------------------------------------\n";
}

void CouncilAppendTitle(string &out, string title)
{
   CouncilAppendSeparator(out);
   CouncilAppendLine(out, title);
   CouncilAppendSeparator(out);
}

//---------------------------------------------------------
// Section builders
//---------------------------------------------------------
void CouncilBuildEnvironmentSection(string &out, CouncilEnvironmentReport &env)
{
   CouncilAppendTitle(out, "COUNCIL ENVIRONMENT");

   CouncilAppendLine(out, "valid:                " + CouncilBoolText(env.valid));
   CouncilAppendLine(out, "tradable:             " + CouncilBoolText(env.tradable));
   CouncilAppendLine(out, "liquidity_ok:         " + CouncilBoolText(env.liquidity_ok));
   CouncilAppendLine(out, "spread_ok:            " + CouncilBoolText(env.spread_ok));
   CouncilAppendLine(out, "momentum_ok:          " + CouncilBoolText(env.momentum_ok));
   CouncilAppendLine(out, "volatility_ok:        " + CouncilBoolText(env.volatility_ok));
   CouncilAppendLine(out, "structure_ok:         " + CouncilBoolText(env.structure_ok));
   CouncilAppendLine(out, "sweep_context_ok:     " + CouncilBoolText(env.sweep_context_ok));
   CouncilAppendLine(out, "session_ok:           " + CouncilBoolText(env.session_ok));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "liquidity_score:      " + CouncilDoubleText(env.liquidity_score, 2));
   CouncilAppendLine(out, "spread_score:         " + CouncilDoubleText(env.spread_score, 2));
   CouncilAppendLine(out, "momentum_score:       " + CouncilDoubleText(env.momentum_score, 2));
   CouncilAppendLine(out, "volatility_score:     " + CouncilDoubleText(env.volatility_score, 2));
   CouncilAppendLine(out, "structure_score:      " + CouncilDoubleText(env.structure_score, 2));
   CouncilAppendLine(out, "sweep_context_score:  " + CouncilDoubleText(env.sweep_context_score, 2));
   CouncilAppendLine(out, "session_score:        " + CouncilDoubleText(env.session_score, 2));
   CouncilAppendLine(out, "total_score:          " + CouncilDoubleText(env.total_score, 2));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "zone_name:            " + CouncilSafeText(env.zone_name));
   CouncilAppendLine(out, "zone_confidence:      " + CouncilDoubleText(env.zone_confidence, 2));
   CouncilAppendLine(out, "preferred_style:      " + CouncilSafeText(env.preferred_style_text));
   CouncilAppendLine(out, "blocked_style:        " + CouncilSafeText(env.blocked_style_text));
   CouncilAppendLine(out, "exhaustion_hint:      " + CouncilBoolText(env.exhaustion_hint));
   CouncilAppendLine(out, "continuation_bias:    " + CouncilBoolText(env.continuation_bias));
   CouncilAppendLine(out, "reversal_bias:        " + CouncilBoolText(env.reversal_bias));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "regime_summary:       " + CouncilSafeText(env.regime_summary));
   CouncilAppendLine(out, "summary:              " + CouncilSafeText(env.summary));
   CouncilAppendLine(out, "reject_reason:        " + CouncilSafeText(env.reject_reason));
   CouncilAppendLine(out, "");
}

void CouncilBuildSingleStrategySection(
   string &out,
   string title,
   CouncilStrategyReport &sig
)
{
   CouncilAppendTitle(out, title);

   CouncilAppendLine(out, "enabled:              " + CouncilBoolText(sig.enabled));
   CouncilAppendLine(out, "valid:                " + CouncilBoolText(sig.valid));
   CouncilAppendLine(out, "strategy_id:          " + CouncilSafeText(sig.strategy_id));
   CouncilAppendLine(out, "strategy_name:        " + CouncilSafeText(sig.strategy_name));
   CouncilAppendLine(out, "strategy_family:      " + CouncilSafeText(sig.strategy_family));
   CouncilAppendLine(out, "direction_bias:       " + CouncilSafeText(sig.direction_bias));
   CouncilAppendLine(out, "decision:             " + CouncilDecisionToText(sig.decision));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "role_name:            " + CouncilSafeText(sig.role_name));
   CouncilAppendLine(out, "eligibility_text:     " + CouncilSafeText(sig.eligibility_text));
   CouncilAppendLine(out, "zone_name:            " + CouncilSafeText(sig.zone_name));
   CouncilAppendLine(out, "eligible_for_zone:    " + CouncilBoolText(sig.eligible_for_zone));
   CouncilAppendLine(out, "observe_only:         " + CouncilBoolText(sig.observe_only));
   CouncilAppendLine(out, "blocked_by_zone:      " + CouncilBoolText(sig.blocked_by_zone));
   CouncilAppendLine(out, "zone_block_reason:    " + CouncilSafeText(sig.zone_block_reason));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "confidence:           " + CouncilDoubleText(sig.confidence, 2));
   CouncilAppendLine(out, "trigger_quality:      " + CouncilDoubleText(sig.trigger_quality, 2));
   CouncilAppendLine(out, "confirmation_quality: " + CouncilDoubleText(sig.confirmation_quality, 2));
   CouncilAppendLine(out, "environment_fit:      " + CouncilDoubleText(sig.environment_fit, 2));
   CouncilAppendLine(out, "zone_alignment_score: " + CouncilDoubleText(sig.zone_alignment_score, 2));
   CouncilAppendLine(out, "priority_score:       " + CouncilDoubleText(sig.priority_score, 2));
   CouncilAppendLine(out, "conflict_score:       " + CouncilDoubleText(sig.conflict_score, 2));
   CouncilAppendLine(out, "score_final:          " + CouncilDoubleText(sig.score_final, 2));
   CouncilAppendLine(out, "vote_weight:          " + CouncilDoubleText(sig.vote_weight, 2));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "trigger_present:      " + CouncilBoolText(sig.trigger_present));
   CouncilAppendLine(out, "blocked_by_filter:    " + CouncilBoolText(sig.blocked_by_filter));
   CouncilAppendLine(out, "counter_trend:        " + CouncilBoolText(sig.counter_trend));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "short_reason:         " + CouncilSafeText(sig.short_reason));
   CouncilAppendLine(out, "explanation:          " + CouncilSafeText(sig.explanation));
   CouncilAppendLine(out, "");
}

void CouncilBuildAggregateSection(string &out, CouncilAggregateReport &agg)
{
   CouncilAppendTitle(out, "COUNCIL AGGREGATE");

   CouncilAppendLine(out, "valid:                " + CouncilBoolText(agg.valid));
   CouncilAppendLine(out, "active_strategies:    " + IntegerToString(agg.active_strategies));
   CouncilAppendLine(out, "buy_votes:            " + IntegerToString(agg.buy_votes));
   CouncilAppendLine(out, "sell_votes:           " + IntegerToString(agg.sell_votes));
   CouncilAppendLine(out, "neutral_votes:        " + IntegerToString(agg.neutral_votes));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "total_buy_weight:     " + CouncilDoubleText(agg.total_buy_weight, 2));
   CouncilAppendLine(out, "total_sell_weight:    " + CouncilDoubleText(agg.total_sell_weight, 2));
   CouncilAppendLine(out, "total_neutral_weight: " + CouncilDoubleText(agg.total_neutral_weight, 2));
   CouncilAppendLine(out, "consensus_strength:   " + CouncilDoubleText(agg.consensus_strength, 2));
   CouncilAppendLine(out, "conflict_score:       " + CouncilDoubleText(agg.conflict_score, 2));
   CouncilAppendLine(out, "environment_score:    " + CouncilDoubleText(agg.environment_score, 2));
   CouncilAppendLine(out, "council_quality:      " + CouncilDoubleText(agg.council_quality, 2));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "consensus_label:      " + CouncilSafeText(agg.consensus_label));
   CouncilAppendLine(out, "family_diversity:     " + CouncilDoubleText(agg.family_diversity_score, 2));
   CouncilAppendLine(out, "zone_alignment:       " + CouncilDoubleText(agg.zone_alignment_score, 2));
   CouncilAppendLine(out, "confirm_role_present: " + CouncilBoolText(agg.confirm_role_present));
   CouncilAppendLine(out, "trend_judge_support:  " + CouncilBoolText(agg.trend_judge_supportive));
   CouncilAppendLine(out, "exhaustion_warning:   " + CouncilBoolText(agg.exhaustion_warning));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "dominant_side:        " + CouncilSafeText(agg.dominant_side));
   CouncilAppendLine(out, "best_strategy_id:     " + CouncilSafeText(agg.best_strategy_id));
   CouncilAppendLine(out, "support_strategy_ids: " + CouncilSafeText(agg.support_strategy_ids));
   CouncilAppendLine(out, "summary:              " + CouncilSafeText(agg.summary));
   CouncilAppendLine(out, "");
}

void CouncilBuildPreAIFilterSection(string &out, CouncilPreAIGateReport &pre)
{
   CouncilAppendTitle(out, "PRE-AI FILTER");

   CouncilAppendLine(out, "valid:                         " + CouncilBoolText(pre.valid));
   CouncilAppendLine(out, "passed:                        " + CouncilBoolText(pre.passed));
   CouncilAppendLine(out, "filtered_decision:             " + CouncilDecisionToText(pre.filtered_decision));
   CouncilAppendLine(out, "min_required_consensus:        " + CouncilDoubleText(pre.min_required_consensus, 2));
   CouncilAppendLine(out, "max_allowed_conflict:          " + CouncilDoubleText(pre.max_allowed_conflict, 2));
   CouncilAppendLine(out, "min_required_environment_score:" + CouncilDoubleText(pre.min_required_environment_score, 2));
   CouncilAppendLine(out, "min_required_council_quality:  " + CouncilDoubleText(pre.min_required_council_quality, 2));
   CouncilAppendLine(out, "reason:                        " + CouncilSafeText(pre.reason));
   CouncilAppendLine(out, "summary:                       " + CouncilSafeText(pre.summary));
   CouncilAppendLine(out, "");
}

void CouncilBuildFailureDetectorSection(string &out, CouncilFailurePatternReport &fd)
{
   CouncilAppendTitle(out, "AI FAILURE PATTERN DETECTOR");

   CouncilAppendLine(out, "valid:                      " + CouncilBoolText(fd.valid));
   CouncilAppendLine(out, "pressure_level:             " + CouncilSafeText(fd.pressure_label));
   CouncilAppendLine(out, "dominant_failure_tag:       " + CouncilSafeText(fd.dominant_failure_tag));
   CouncilAppendLine(out, "dominant_setup_type:        " + CouncilSafeText(fd.dominant_setup_type));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "recent_failure_pressure:    " + CouncilDoubleText(fd.recent_failure_pressure, 2));
   CouncilAppendLine(out, "continuation_risk_score:    " + CouncilDoubleText(fd.continuation_risk_score, 2));
   CouncilAppendLine(out, "reversal_risk_score:        " + CouncilDoubleText(fd.reversal_risk_score, 2));
   CouncilAppendLine(out, "mean_reclaim_risk_score:    " + CouncilDoubleText(fd.mean_reclaim_risk_score, 2));
   CouncilAppendLine(out, "breakout_risk_score:        " + CouncilDoubleText(fd.breakout_risk_score, 2));
   CouncilAppendLine(out, "confirm_gap_risk_score:     " + CouncilDoubleText(fd.confirm_gap_risk_score, 2));
   CouncilAppendLine(out, "exhaustion_ignore_risk:     " + CouncilDoubleText(fd.exhaustion_ignore_risk_score, 2));
   CouncilAppendLine(out, "conflict_risk_score:        " + CouncilDoubleText(fd.conflict_risk_score, 2));
   CouncilAppendLine(out, "zone_mismatch_risk_score:   " + CouncilDoubleText(fd.zone_mismatch_risk_score, 2));
   CouncilAppendLine(out, "low_quality_risk_score:     " + CouncilDoubleText(fd.low_quality_risk_score, 2));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "continuation_fragile:       " + CouncilBoolText(fd.continuation_fragile));
   CouncilAppendLine(out, "reversal_fragile:           " + CouncilBoolText(fd.reversal_fragile));
   CouncilAppendLine(out, "confirmation_gap_detected:  " + CouncilBoolText(fd.confirmation_gap_detected));
   CouncilAppendLine(out, "exhaustion_risk_detected:   " + CouncilBoolText(fd.exhaustion_risk_detected));
   CouncilAppendLine(out, "zone_mismatch_detected:     " + CouncilBoolText(fd.zone_mismatch_detected));
   CouncilAppendLine(out, "low_quality_cluster:        " + CouncilBoolText(fd.low_quality_cluster_detected));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "recommended_state:          " + CouncilSafeText(fd.recommended_state));
   CouncilAppendLine(out, "recommendation_summary:     " + CouncilSafeText(fd.recommendation_summary));
   CouncilAppendLine(out, "summary:                    " + CouncilSafeText(fd.summary));
   CouncilAppendLine(out, "");
}

void CouncilBuildGovernorSection(string &out, CouncilPolicyAdjustment &gov)
{
   CouncilAppendTitle(out, "COUNCIL GOVERNOR / POLICY ADJUSTMENT");

   CouncilAppendLine(out, "valid:                      " + CouncilBoolText(gov.valid));
   CouncilAppendLine(out, "change_strategy_enablement: " + CouncilBoolText(gov.change_strategy_enablement));
   CouncilAppendLine(out, "change_vote_weights:        " + CouncilBoolText(gov.change_vote_weights));
   CouncilAppendLine(out, "change_pre_ai_thresholds:   " + CouncilBoolText(gov.change_pre_ai_thresholds));
   CouncilAppendLine(out, "suggest_mode_exit:          " + CouncilBoolText(gov.suggest_mode_exit));
   CouncilAppendLine(out, "change_operating_state:     " + CouncilBoolText(gov.change_operating_state));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "target_operating_state:     " + CouncilSafeText(gov.target_operating_state_text));
   CouncilAppendLine(out, "target_strategy_id:         " + CouncilSafeText(gov.target_strategy_id));
   CouncilAppendLine(out, "adjustment_reason:          " + CouncilSafeText(gov.adjustment_reason));
   CouncilAppendLine(out, "summary:                    " + CouncilSafeText(gov.summary));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "new_vote_weight:            " + CouncilDoubleText(gov.new_vote_weight, 2));
   CouncilAppendLine(out, "new_min_consensus:          " + CouncilDoubleText(gov.new_min_consensus, 2));
   CouncilAppendLine(out, "new_max_conflict:           " + CouncilDoubleText(gov.new_max_conflict, 2));
   CouncilAppendLine(out, "new_min_environment_score:  " + CouncilDoubleText(gov.new_min_environment_score, 2));
   CouncilAppendLine(out, "new_min_council_quality:    " + CouncilDoubleText(gov.new_min_council_quality, 2));
   CouncilAppendLine(out, "");
}

void CouncilBuildFeedbackSection(string &out, CouncilFeedbackRecord &fb)
{
   CouncilAppendTitle(out, "LATEST COUNCIL FEEDBACK");

   CouncilAppendLine(out, "symbol:               " + CouncilSafeText(fb.symbol));
   CouncilAppendLine(out, "plan_id:              " + CouncilSafeText(fb.plan_id));
   CouncilAppendLine(out, "mode_name:            " + CouncilSafeText(fb.mode_name));
   CouncilAppendLine(out, "final_decision:       " + CouncilSafeText(fb.final_decision));
   CouncilAppendLine(out, "executed_direction:   " + CouncilSafeText(fb.executed_direction));
   CouncilAppendLine(out, "trade_result:         " + CouncilSafeText(fb.trade_result));
   CouncilAppendLine(out, "profit:               " + CouncilDoubleText(fb.profit, 2));
   CouncilAppendLine(out, "environment_score:    " + CouncilDoubleText(fb.environment_score, 2));
   CouncilAppendLine(out, "council_quality:      " + CouncilDoubleText(fb.council_quality, 2));
   CouncilAppendLine(out, "consensus_strength:   " + CouncilDoubleText(fb.consensus_strength, 2));
   CouncilAppendLine(out, "conflict_score:       " + CouncilDoubleText(fb.conflict_score, 2));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "zone_name:            " + CouncilSafeText(fb.zone_name));
   CouncilAppendLine(out, "zone_confidence:      " + CouncilDoubleText(fb.zone_confidence, 2));
   CouncilAppendLine(out, "preferred_style:      " + CouncilSafeText(fb.preferred_style));
   CouncilAppendLine(out, "governor_state:       " + CouncilSafeText(fb.governor_state));
   CouncilAppendLine(out, "consensus_label:      " + CouncilSafeText(fb.consensus_label));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "failure_tag:          " + CouncilSafeText(fb.failure_tag));
   CouncilAppendLine(out, "quality_band:         " + CouncilSafeText(fb.quality_band));
   CouncilAppendLine(out, "setup_type:           " + CouncilSafeText(fb.setup_type));
   CouncilAppendLine(out, "confirm_role_present: " + CouncilBoolText(fb.confirm_role_present));
   CouncilAppendLine(out, "trend_judge_support:  " + CouncilBoolText(fb.trend_judge_supportive));
   CouncilAppendLine(out, "exhaustion_warning:   " + CouncilBoolText(fb.exhaustion_warning));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "best_strategy_id:     " + CouncilSafeText(fb.best_strategy_id));
   CouncilAppendLine(out, "support_strategy_ids: " + CouncilSafeText(fb.support_strategy_ids));
   CouncilAppendLine(out, "regime_summary:       " + CouncilSafeText(fb.regime_summary));
   CouncilAppendLine(out, "explanation:          " + CouncilSafeText(fb.explanation));
   CouncilAppendLine(out, "close_time:           " + CouncilDateTimeText(fb.close_time));
   CouncilAppendLine(out, "");
}

void CouncilBuildMemorySection(string &out, CouncilMemorySummary &mem)
{
   CouncilAppendTitle(out, "COUNCIL MEMORY SUMMARY");

   CouncilAppendLine(out, "total_records:         " + IntegerToString(mem.total_records));
   CouncilAppendLine(out, "executed_records:      " + IntegerToString(mem.executed_records));
   CouncilAppendLine(out, "wins:                  " + IntegerToString(mem.wins));
   CouncilAppendLine(out, "losses:                " + IntegerToString(mem.losses));
   CouncilAppendLine(out, "flats:                 " + IntegerToString(mem.flats));
   CouncilAppendLine(out, "total_profit:          " + CouncilDoubleText(mem.total_profit, 2));
   CouncilAppendLine(out, "avg_profit:            " + CouncilDoubleText(mem.avg_profit, 4));
   CouncilAppendLine(out, "overall_win_rate:      " + CouncilDoubleText(mem.overall_win_rate, 2));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "high_quality_records:  " + IntegerToString(mem.high_quality_records));
   CouncilAppendLine(out, "medium_quality_records:" + IntegerToString(mem.medium_quality_records));
   CouncilAppendLine(out, "low_quality_records:   " + IntegerToString(mem.low_quality_records));
   CouncilAppendLine(out, "confirm_supported:     " + IntegerToString(mem.confirm_supported_records));
   CouncilAppendLine(out, "trend_judge_supported: " + IntegerToString(mem.trend_judge_supported_records));
   CouncilAppendLine(out, "exhaustion_warnings:   " + IntegerToString(mem.exhaustion_warning_records));

   CouncilAppendLine(out, "");
   CouncilAppendLine(out, "top_failure_tag:       " + CouncilSafeText(mem.top_failure_tag));
   CouncilAppendLine(out, "top_setup_type:        " + CouncilSafeText(mem.top_setup_type));
   CouncilAppendLine(out, "best_overall_strategy: " + CouncilSafeText(mem.best_overall_strategy));
   CouncilAppendLine(out, "best_buy_strategy:     " + CouncilSafeText(mem.best_buy_strategy));
   CouncilAppendLine(out, "best_sell_strategy:    " + CouncilSafeText(mem.best_sell_strategy));
   CouncilAppendLine(out, "best_strategy_id:      " + CouncilSafeText(mem.best_strategy_id));
   CouncilAppendLine(out, "support_strategy_ids:  " + CouncilSafeText(mem.support_strategy_ids));
   CouncilAppendLine(out, "");
}

//---------------------------------------------------------
// Main report builder
//---------------------------------------------------------
string BuildCouncilSystemReportTextEx(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &reports[],
   int reportCount,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &pre,
   CouncilFailurePatternReport &failDet,
   CouncilPolicyAdjustment &gov,
   CouncilFeedbackRecord &fb,
   CouncilMemorySummary &mem
)
{
   string out = "";

   CouncilAppendTitle(out, "COUNCIL MODE / SYSTEM REPORT");
   CouncilAppendLine(out, "generated_at: " + CouncilDateTimeText(TimeCurrent()));
   CouncilAppendLine(out, "symbol:       " + _Symbol);
   CouncilAppendLine(out, "");

   CouncilBuildEnvironmentSection(out, env);

   for(int i = 0; i < reportCount; i++)
   {
      CouncilBuildSingleStrategySection(out, "STRATEGY REPORT / " + IntegerToString(i + 1), reports[i]);
   }

   CouncilBuildAggregateSection(out, agg);
   CouncilBuildPreAIFilterSection(out, pre);
   CouncilBuildFailureDetectorSection(out, failDet);
   CouncilBuildGovernorSection(out, gov);
   CouncilBuildFeedbackSection(out, fb);
   CouncilBuildMemorySection(out, mem);

   //-----------------------------------------------------
   // ZONE COVERAGE (passive)
   //-----------------------------------------------------
   ZoneCoverageReport zc;
   BuildZoneCoverageReport(reports, reportCount, env, zc);

   out += "\n[ZONE COVERAGE]\n";
   out += "zone_semantic: " + zc.zone_semantic + "\n";
   out += "coverage: " + zc.coverage_label + "\n";
   out += "active_strategies: " + IntegerToString(zc.active_strategies) + "\n";
   out += "diversity: " + DoubleToString(zc.diversity_score, 2) + "\n";
   out += "concentration: " + DoubleToString(zc.concentration_score, 2) + "\n";
   out += "dominant_family: " + zc.dominant_family + "\n";
   out += "dominant_strategy: " + zc.dominant_strategy + "\n";
   out += "conflict: " + (zc.has_conflict ? "true" : "false") + "\n";
   out += "reason: " + zc.coverage_reason + "\n";

   return out;
}

string BuildCouncilSystemReportText(
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &s1,
   CouncilStrategyReport &s2,
   CouncilStrategyReport &s3,
   CouncilStrategyReport &s4,
   CouncilStrategyReport &s5,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &pre,
   CouncilFailurePatternReport &failDet,
   CouncilPolicyAdjustment &gov,
   CouncilFeedbackRecord &fb,
   CouncilMemorySummary &mem
)
{
   CouncilStrategyReport reports[5];
   reports[0] = s1; reports[1] = s2; reports[2] = s3; reports[3] = s4; reports[4] = s5;
   return BuildCouncilSystemReportTextEx(env, reports, 5, agg, pre, failDet, gov, fb, mem);
}

//---------------------------------------------------------
// Convenience save function
//---------------------------------------------------------
bool SaveCouncilSystemReportEx2(
   string relativePath,
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &reports[],
   int reportCount,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &pre,
   CouncilFailurePatternReport &failDet,
   CouncilPolicyAdjustment &gov,
   CouncilFeedbackRecord &fb,
   CouncilMemorySummary &mem,
   string &logMessage
)
{
   if(StringLen(relativePath) <= 0)
      return true;

   logMessage = "";

   string report = BuildCouncilSystemReportTextEx(
      env, reports, reportCount, agg, pre, failDet, gov, fb, mem
   );

   if(!SaveCouncilReportText(relativePath, report))
   {
      logMessage = "Council TXT reporter failed: could not save report";
      return false;
   }

   logMessage =
      "Council TXT report saved"
      " | zone=" + CouncilSafeText(env.zone_name) +
      " | dominant_side=" + CouncilSafeText(agg.dominant_side) +
      " | consensus=" + CouncilSafeText(agg.consensus_label) +
      " | fail_pressure=" + CouncilSafeText(failDet.pressure_label) +
      " | best_strategy=" + CouncilFormatStrategyIdNameEx(agg.best_strategy_id, reports, reportCount) +
      " | support=" + CouncilFormatSupportStrategiesEx(agg.support_strategy_ids, reports, reportCount);

   return true;
}

bool SaveCouncilSystemReportEx(
   string relativePath,
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &s1,
   CouncilStrategyReport &s2,
   CouncilStrategyReport &s3,
   CouncilStrategyReport &s4,
   CouncilStrategyReport &s5,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &pre,
   CouncilFailurePatternReport &failDet,
   CouncilPolicyAdjustment &gov,
   CouncilFeedbackRecord &fb,
   CouncilMemorySummary &mem,
   string &logMessage
)
{
   CouncilStrategyReport reports[5];
   reports[0] = s1; reports[1] = s2; reports[2] = s3; reports[3] = s4; reports[4] = s5;
   return SaveCouncilSystemReportEx2(relativePath, env, reports, 5, agg, pre, failDet, gov, fb, mem, logMessage);
}


// Backward-compatible wrapper (legacy 4-strategy signature)
bool SaveCouncilSystemReport(
   string relativePath,
   CouncilEnvironmentReport &env,
   CouncilStrategyReport &s1,
   CouncilStrategyReport &s2,
   CouncilStrategyReport &s3,
   CouncilStrategyReport &s4,
   CouncilAggregateReport &agg,
   CouncilPreAIGateReport &pre,
   CouncilFailurePatternReport &failDet,
   CouncilPolicyAdjustment &gov,
   CouncilFeedbackRecord &fb,
   CouncilMemorySummary &mem,
   string &logMessage
)
{
   CouncilStrategyReport s5;
   InitCouncilStrategyReport(s5);
   s5.strategy_id = "";
   s5.strategy_name = "";
   return SaveCouncilSystemReportEx(relativePath, env, s1, s2, s3, s4, s5, agg, pre, failDet, gov, fb, mem, logMessage);
}

#endif