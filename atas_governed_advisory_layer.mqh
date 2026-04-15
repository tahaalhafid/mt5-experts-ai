#ifndef __ATAS_GOVERNED_ADVISORY_LAYER_MQH__
#define __ATAS_GOVERNED_ADVISORY_LAYER_MQH__

#include "decision_mode_router.mqh"
#include "level_awareness_brake.mqh"
#include "atas_governed_advisory_contract.mqh"
#include "atas_governed_advisory_artifacts.mqh"

double AtasGovAdvisoryClamp01(const double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string AtasGovAdvisoryUpper(string s)
{
   s = TrimString(s);
   StringToUpper(s);
   return s;
}

bool AtasGovAdvisoryContains(const string src, const string token)
{
   string a = AtasGovAdvisoryUpper(src);
   string b = AtasGovAdvisoryUpper(token);
   return (StringFind(a, b) >= 0);
}

string AtasGovAdvisoryAppendReasonCode(const string csv, const string code)
{
   string reason = TrimString(code);
   if(StringLen(reason) <= 0)
      return csv;

   if(StringLen(TrimString(csv)) <= 0)
      return reason;

   string normalized = "," + AtasGovAdvisoryUpper(csv) + ",";
   string needle = "," + AtasGovAdvisoryUpper(reason) + ",";
   if(StringFind(normalized, needle) >= 0)
      return csv;

   return csv + "," + reason;
}

string AtasGovAdvisoryAppendStateTag(const string csv, const string tag)
{
   return AtasGovAdvisoryAppendReasonCode(csv, tag);
}

int AtasGovAdvisoryDirectionSign(const string direction)
{
   return (AtasGovAdvisoryUpper(direction) == "SELL" ? -1 : 1);
}

string AtasGovAdvisoryClassifyBlockClass(const string gateReasonCode)
{
   string r = AtasGovAdvisoryUpper(gateReasonCode);
   if(StringLen(r) <= 0 || r == "NONE" || r == "NOT_EVALUATED")
      return "NONE";

   if(StringFind(r, "PAYLOAD") >= 0 || StringFind(r, "SHADOW_NOT_ATTACHED") >= 0)
      return "ATTACHMENT_BLOCKED";
   if(StringFind(r, "FRESH") >= 0)
      return "FRESHNESS_BLOCKED";
   if(StringFind(r, "MAPPING") >= 0 || StringFind(r, "SYMBOL") >= 0)
      return "MAPPING_BLOCKED";
   if(StringFind(r, "SESSION") >= 0)
      return "SESSION_BLOCKED";
   if(StringFind(r, "TRANSLATION") >= 0 || StringFind(r, "SEMANTIC_ONLY") >= 0)
      return "TRANSLATION_BLOCKED";
   if(StringFind(r, "QUALITY") >= 0 || StringFind(r, "SOURCE") >= 0)
      return "SOURCE_QUALITY_BLOCKED";
   if(StringFind(r, "LEVEL_CONTEXT") >= 0)
      return "LEVEL_CONTEXT_BLOCKED";
   if(StringFind(r, "RELEVANCE") >= 0 || StringFind(r, "CONFLUENCE") >= 0)
      return "RELEVANCE_BLOCKED";
   if(StringFind(r, "RUNTIME_CONTEXT") >= 0 || StringFind(r, "COUNCIL") >= 0)
      return "STRUCTURAL_BLOCKED";

   return "OTHER_BLOCKED";
}

string AtasGovAdvisoryBuildAttachmentState(const AtasGovernedAdvisoryGateResult &gate)
{
   if(!gate.payload_present)
      return "ADVISORY_ABSENT";
   if(!gate.shadow_attached)
      return "ADVISORY_PRESENT_NOT_ATTACHED";
   if(!gate.source_valid)
      return "ADVISORY_ATTACHED_SOURCE_QUALITY_BLOCKED";
   if(!gate.freshness_valid)
      return "ADVISORY_ATTACHED_FRESHNESS_BLOCKED";
   if(!gate.session_valid)
      return "ADVISORY_ATTACHED_SESSION_BLOCKED";
   if(!gate.symbol_mapping_valid)
      return "ADVISORY_ATTACHED_MAPPING_BLOCKED";
   if(!gate.translation_valid && !gate.semantic_only_fallback_used)
      return "ADVISORY_ATTACHED_TRANSLATION_BLOCKED";
   if(gate.advisory_eligible)
      return "ADVISORY_ATTACHED_ELIGIBLE";
   return "ADVISORY_ATTACHED_INELIGIBLE";
}

string AtasGovAdvisoryBuildUsageState(const AtasGovernedAdvisoryPacket &packet,
                                      const AtasGovernedAdvisoryGateResult &gate)
{
   if(!gate.payload_present)
      return "ADVISORY_ABSENT";
   if(!gate.shadow_attached)
      return "ADVISORY_PRESENT_NOT_ATTACHED";
   if(!gate.advisory_eligible)
      return "ADVISORY_BLOCKED";

   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION)
      return "ADVISORY_USED_HOLD_SIGNAL";
   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR)
      return "ADVISORY_USED_SOFT_SIGNAL";
   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY)
      return "ADVISORY_DISPLAY_ONLY";
   if(packet.advisory_relevance_score <= 0.0 &&
      !packet.contradiction_flag &&
      !packet.hold_bias &&
      !packet.confirmation_support_flag)
      return "ADVISORY_ELIGIBLE_ZERO_EFFECT";
   return "ADVISORY_ELIGIBLE_NO_ACTION";
}

string AtasGovAdvisoryBuildZeroEffectReason(const AtasGovernedAdvisoryPacket &packet,
                                            const AtasGovernedAdvisoryGateResult &gate)
{
   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION ||
      gate.gate_outcome == ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR)
      return "SHAPING_SIGNAL_PRESENT";

   if(!gate.payload_present)
      return "ADVISORY_ABSENT";
   if(!gate.shadow_attached)
      return "SHADOW_NOT_ATTACHED";
   if(!gate.advisory_eligible)
      return "INELIGIBLE:" + gate.gate_reason_code;
   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY)
      return "DISPLAY_ONLY_OUTCOME";
   if(packet.advisory_relevance_score <= 0.0 &&
      !packet.contradiction_flag &&
      !packet.hold_bias &&
      !packet.confirmation_support_flag)
      return "NO_MATERIAL_ADVISORY_SIGNAL";
   return "NO_ZERO_EFFECT";
}

string AtasGovAdvisoryBuildCandidateSignature(const RoutedRuntimeEvaluation &routed, const string direction)
{
   string signature = AtasGovAdvisoryUpper(direction);
   signature += "|" + AtasGovAdvisoryUpper(routed.council.env.zone_name);
   signature += "|" + AtasGovAdvisoryUpper(routed.council.aggregate.best_strategy_id);
   return signature;
}

bool AtasGovAdvisoryReadTextFileAll(const string relPath, string &outText)
{
   outText = "";
   int h = FileOpen(relPath, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
      outText += FileReadString(h);

   FileClose(h);
   return true;
}

datetime AtasGovAdvisoryParseTimestamp(string raw)
{
   raw = TrimString(raw);
   if(StringLen(raw) <= 0)
      return 0;

   bool allDigits = true;
   for(int i = 0; i < StringLen(raw); i++)
   {
      ushort c = StringGetCharacter(raw, i);
      if(c < '0' || c > '9')
      {
         allDigits = false;
         break;
      }
   }
   if(allDigits)
   {
      long epoch = StringToInteger(raw);
      if(epoch > 1000000000000)
         epoch /= 1000;
      if(epoch > 100000000)
         return (datetime)epoch;
   }

   bool hasTimezone = false;
   int sourceOffsetSeconds = 0;
   string tsRaw = raw;

   int zPos = StringFind(tsRaw, "Z");
   if(zPos < 0)
      zPos = StringFind(tsRaw, "z");
   if(zPos > 0)
   {
      hasTimezone = true;
      sourceOffsetSeconds = 0;
      tsRaw = StringSubstr(tsRaw, 0, zPos);
   }
   else
   {
      int tzPos = -1;
      int rawLen = StringLen(tsRaw);
      for(int i = 19; i < rawLen; i++)
      {
         ushort c = StringGetCharacter(tsRaw, i);
         if(c == '+' || c == '-')
         {
            tzPos = i;
            break;
         }
      }

      if(tzPos > 0)
      {
         string signText = StringSubstr(tsRaw, tzPos, 1);
         string tzBody = StringSubstr(tsRaw, tzPos + 1);
         int tzHours = 0;
         int tzMinutes = 0;
         if(StringLen(tzBody) >= 5 && StringSubstr(tzBody, 2, 1) == ":")
         {
            tzHours = (int)StringToInteger(StringSubstr(tzBody, 0, 2));
            tzMinutes = (int)StringToInteger(StringSubstr(tzBody, 3, 2));
         }
         else if(StringLen(tzBody) >= 4)
         {
            tzHours = (int)StringToInteger(StringSubstr(tzBody, 0, 2));
            tzMinutes = (int)StringToInteger(StringSubstr(tzBody, 2, 2));
         }
         else if(StringLen(tzBody) >= 2)
         {
            tzHours = (int)StringToInteger(StringSubstr(tzBody, 0, 2));
            tzMinutes = 0;
         }

         int sign = (signText == "-" ? -1 : 1);
         sourceOffsetSeconds = sign * (tzHours * 3600 + tzMinutes * 60);
         hasTimezone = true;
         tsRaw = StringSubstr(tsRaw, 0, tzPos);
      }
   }

   StringReplace(tsRaw, "T", " ");
   StringReplace(tsRaw, "-", ".");
   StringReplace(tsRaw, "/", ".");
   int fracPos = -1;
   int tsLen = StringLen(tsRaw);
   for(int i = 19; i < tsLen; i++)
   {
      if(StringGetCharacter(tsRaw, i) == '.')
      {
         fracPos = i;
         break;
      }
   }
   if(fracPos > 0)
      tsRaw = StringSubstr(tsRaw, 0, fracPos);
   if(StringLen(tsRaw) >= 19)
      tsRaw = StringSubstr(tsRaw, 0, 19);

   if(StringLen(tsRaw) < 19)
   {
      if(hasTimezone)
         return 0;
      return StringToTime(tsRaw);
   }

   int year = (int)StringToInteger(StringSubstr(tsRaw, 0, 4));
   int month = (int)StringToInteger(StringSubstr(tsRaw, 5, 2));
   int day = (int)StringToInteger(StringSubstr(tsRaw, 8, 2));
   int hour = (int)StringToInteger(StringSubstr(tsRaw, 11, 2));
   int minute = (int)StringToInteger(StringSubstr(tsRaw, 14, 2));
   int second = (int)StringToInteger(StringSubstr(tsRaw, 17, 2));

   if(year < 1970 || month < 1 || month > 12 || day < 1 || day > 31 ||
      hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59)
   {
      if(hasTimezone)
         return 0;
      return StringToTime(tsRaw);
   }

   int monthDays[] = {31,28,31,30,31,30,31,31,30,31,30,31};
   bool leap = ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0));
   if(leap)
      monthDays[1] = 29;
   if(day > monthDays[month - 1])
   {
      if(hasTimezone)
         return 0;
      return StringToTime(tsRaw);
   }

   long days = 0;
   for(int y = 1970; y < year; y++)
   {
      bool yLeap = ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0));
      days += (yLeap ? 366 : 365);
   }
   for(int m = 1; m < month; m++)
      days += monthDays[m - 1];
   days += (day - 1);

   long epoch = (days * 86400) + (hour * 3600) + (minute * 60) + second;
   if(hasTimezone)
      epoch -= sourceOffsetSeconds;

   return (datetime)epoch;
}

struct AtasGovernedRuntimeStatusProbe
{
   bool     present;
   string   packet_id;
   string   trace_id;
   string   source_symbol;
   string   source_symbol_original;
   string   execution_symbol;
   string   source_mode;
   string   freshness_state;
   string   price_space_relation;
   bool     price_anchor_fields_suppressed;
   bool     cross_instrument_translation_applied;
   double   source_reference_price;
   double   execution_reference_price;
   double   cross_instrument_basis_value;
   datetime evaluated_at;
};

void InitAtasGovernedRuntimeStatusProbe(AtasGovernedRuntimeStatusProbe &p)
{
   p.present = false;
   p.packet_id = "";
   p.trace_id = "";
   p.source_symbol = "";
   p.source_symbol_original = "";
   p.execution_symbol = "";
   p.source_mode = "";
   p.freshness_state = "UNKNOWN";
   p.price_space_relation = "";
   p.price_anchor_fields_suppressed = false;
   p.cross_instrument_translation_applied = false;
   p.source_reference_price = 0.0;
   p.execution_reference_price = 0.0;
   p.cross_instrument_basis_value = 0.0;
   p.evaluated_at = 0;
}

void AtasGovAdvisoryLoadRuntimeStatusProbe(AtasGovernedRuntimeStatusProbe &probe)
{
   InitAtasGovernedRuntimeStatusProbe(probe);

   string json = "";
   if(!AtasGovAdvisoryReadTextFileAll("AI\\atas_microstructure_status.json", json))
   {
      // Transitional fallback for legacy mirrored surface during direct-write alignment cutover.
      if(!AtasGovAdvisoryReadTextFileAll("AI\\atas_runtime_context_status.json", json))
         return;
   }

   if(StringLen(TrimString(json)) <= 2)
      return;

   probe.present = true;
   ExtractJsonStringField(json, "last_packet_id", probe.packet_id);
   if(StringLen(TrimString(probe.packet_id)) <= 0)
      ExtractJsonStringField(json, "packet_id", probe.packet_id);
   ExtractJsonStringField(json, "trace_id", probe.trace_id);
   ExtractJsonStringField(json, "source_symbol", probe.source_symbol);
   ExtractJsonStringField(json, "source_symbol_original", probe.source_symbol_original);
   ExtractJsonStringField(json, "execution_symbol", probe.execution_symbol);
   ExtractJsonStringField(json, "source_mode", probe.source_mode);
   ExtractJsonStringField(json, "freshness_state", probe.freshness_state);
   ExtractJsonStringField(json, "price_space_relation", probe.price_space_relation);
   ExtractJsonBoolField(json, "price_anchor_fields_suppressed", probe.price_anchor_fields_suppressed);
   ExtractJsonBoolField(json, "cross_instrument_translation_applied", probe.cross_instrument_translation_applied);
   ExtractJsonDoubleField(json, "source_reference_price", probe.source_reference_price);
   ExtractJsonDoubleField(json, "execution_reference_price", probe.execution_reference_price);
   ExtractJsonDoubleField(json, "cross_instrument_basis_value", probe.cross_instrument_basis_value);

   string evaluatedText = "";
   if(ExtractJsonStringField(json, "evaluated_at", evaluatedText))
      probe.evaluated_at = AtasGovAdvisoryParseTimestamp(evaluatedText);
}

string AtasGovAdvisoryConfidenceBand(const double relevanceScore)
{
   if(relevanceScore >= 0.75) return "HIGH";
   if(relevanceScore >= 0.50) return "MEDIUM";
   return "LOW";
}

string AtasGovAdvisoryStrengthBand(const AtasGovernedAdvisoryState state, const double relevanceScore)
{
   if(state == ATAS_ADVISORY_STRONG_CAUTION) return "STRONG";
   if(state == ATAS_ADVISORY_CAUTION) return "ELEVATED";
   if(relevanceScore >= 0.75) return "HIGH";
   if(relevanceScore >= 0.50) return "MEDIUM";
   return "LOW";
}

string AtasGovAdvisoryDirectionClass(const string direction)
{
   string d = AtasGovAdvisoryUpper(direction);
   if(d == "BUY") return "CANDIDATE_BUY_CONTEXT";
   if(d == "SELL") return "CANDIDATE_SELL_CONTEXT";
   return "NEUTRAL";
}

string AtasGovAdvisoryBuildCanonicalSummary(const LevelAwarenessBrakeReport &brake)
{
   string s = "support=" + DoubleToString(brake.nearest_support_price, 5);
   s += "|resistance=" + DoubleToString(brake.nearest_resistance_price, 5);
   s += "|support_pts=" + IntegerToString(brake.nearest_support_distance_points);
   s += "|resistance_pts=" + IntegerToString(brake.nearest_resistance_distance_points);
   s += "|breakout_room=" + DoubleToString(brake.breakout_room_score, 2);
   s += "|rejection_risk=" + DoubleToString(brake.rejection_risk_score, 2);
   s += "|continuation_obstacle=" + DoubleToString(brake.continuation_obstacle_risk, 2);
   s += "|reversal_trap=" + DoubleToString(brake.reversal_trap_risk, 2);
   return s;
}

void AtasGovAdvisoryUpdateHoldStateTimeBudget(AtasGovernedAdvisoryHoldState &holdState)
{
   if(!holdState.active)
      return;

   int currentBarIndex = iBars(_Symbol, PERIOD_M1);
   if(currentBarIndex >= holdState.release_bar_index)
      holdState.active = false;
}

bool AtasGovAdvisoryCanApplyHold(AtasGovernedAdvisoryHoldState &holdState,
                                 const string candidateSignature,
                                 const int holdLimitPerSignature)
{
   AtasGovAdvisoryUpdateHoldStateTimeBudget(holdState);

   if(StringLen(TrimString(candidateSignature)) <= 0)
      return false;

   if(!holdState.active)
   {
      if(StringLen(TrimString(holdState.candidate_signature)) <= 0 || holdState.candidate_signature != candidateSignature)
      {
         holdState.candidate_signature = candidateSignature;
         holdState.holds_used_for_signature = 0;
      }
      return (holdState.holds_used_for_signature < holdLimitPerSignature);
   }

   if(holdState.candidate_signature != candidateSignature)
   {
      holdState.active = false;
      holdState.candidate_signature = candidateSignature;
      holdState.holds_used_for_signature = 0;
      return true;
   }

   return false;
}

void AtasGovAdvisoryApplyHold(AtasGovernedAdvisoryHoldState &holdState,
                              const AtasGovernedAdvisoryPacket &packet,
                              const string candidateSignature,
                              const int holdBars,
                              const string reasonCode)
{
   int currentBarIndex = iBars(_Symbol, PERIOD_M1);

   if(holdState.candidate_signature != candidateSignature)
   {
      holdState.holds_used_for_signature = 0;
      holdState.signature_anchor_bar_index = currentBarIndex;
   }

   holdState.active = true;
   holdState.candidate_signature = candidateSignature;
   holdState.decision_id = packet.candidate_decision_id;
   holdState.direction = packet.candidate_direction;
   holdState.advisory_packet_id = packet.advisory_packet_id;
   holdState.hold_reason_code = reasonCode;
   holdState.held_at = TimeCurrent();
   holdState.release_bar_index = currentBarIndex + MathMax(1, holdBars);
   holdState.holds_used_for_signature++;
}

void AtasGovAdvisoryTrackEffectiveness(AtasGovernedAdvisoryEffectiveness &e,
                                       const AtasGovernedAdvisoryPacket &p,
                                       const AtasGovernedAdvisoryGateResult &g)
{
   e.advisory_total++;

   if(p.advisory_state == ATAS_ADVISORY_OK)
      e.advisory_ok_total++;
   else if(p.advisory_state == ATAS_ADVISORY_CAUTION)
      e.advisory_caution_total++;
   else if(p.advisory_state == ATAS_ADVISORY_STRONG_CAUTION)
      e.advisory_strong_caution_total++;
   else if(p.advisory_state == ATAS_ADVISORY_INSUFFICIENT_EVIDENCE)
      e.advisory_insufficient_evidence_total++;

   if(g.gate_outcome == ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION && g.hold_applied)
      e.advisory_hold_total++;
   else if(g.gate_outcome == ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR)
      e.advisory_flag_total++;
   else if(g.gate_outcome == ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY)
      e.advisory_display_only_total++;

   if(p.semantic_only_mode)
      e.advisory_semantic_only_total++;

   if(p.cross_instrument_translation_applied)
      e.advisory_translation_applied_total++;
   if(p.price_anchor_fields_suppressed)
      e.advisory_translation_suppressed_total++;

   if(p.contradiction_flag)
      e.advisory_contradiction_total++;
   if(p.confirmation_support_flag)
      e.advisory_confirmation_total++;

   e.rebuilt_at = TimeCurrent();
}

void AtasGovAdvisoryUpdateStatus(AtasGovernedAdvisoryStatus &st,
                                 const bool integrationEnabled,
                                 const AtasGovernedAdvisoryPacket &packet,
                                 const AtasGovernedAdvisoryGateResult &gate,
                                 const AtasGovernedAdvisoryHoldState &holdState)
{
   st.update_source = "runtime_candidate_evaluation";
   st.advisory_integration_enabled = integrationEnabled;
   st.advisory_invocation_allowed = gate.gate_applied;
   st.advisory_eligible = gate.advisory_eligible;
   st.rollout_mode = gate.effective_rollout_mode;

   st.advisory_packet_id = packet.advisory_packet_id;
   st.advisory_state = packet.advisory_state;
   st.advisory_outcome = gate.gate_outcome;
   st.advisory_relevance_score = packet.advisory_relevance_score;
   st.advisory_confluence_score = packet.advisory_confluence_score;
   st.contradiction_flag = packet.contradiction_flag;
   st.hold_bias_active = packet.hold_bias;
   st.confirmation_support_flag = packet.confirmation_support_flag;
   st.advisory_reason_codes_csv = packet.advisory_reason_codes_csv;
   st.advisory_summary = packet.advisory_summary_short;
   st.advisory_attachment_state = packet.advisory_attachment_state;
   st.advisory_ineligibility_reason_code = packet.advisory_ineligibility_reason_code;
   st.advisory_block_class = packet.advisory_block_class;
   st.advisory_usage_state = packet.advisory_usage_state;
   st.advisory_zero_effect_reason = packet.advisory_zero_effect_reason;
   st.support_resistance_confluence_state = packet.support_resistance_confluence_state;
   st.advisory_level_context_state_csv = packet.advisory_level_context_state_csv;
   st.translation_state_summary = packet.translation_state_summary;
   st.nearest_support_price = packet.nearest_support_price;
   st.nearest_resistance_price = packet.nearest_resistance_price;
   st.nearest_support_distance_points = packet.nearest_support_distance_points;
   st.nearest_resistance_distance_points = packet.nearest_resistance_distance_points;
   st.level_interaction_type = packet.level_interaction_type;
   st.level_context_supportive = packet.level_context_supportive;
   st.level_context_obstructive = packet.level_context_obstructive;
   st.level_context_degraded = packet.level_context_degraded;
   st.sr_observation_source = packet.sr_observation_source;

   st.candidate_decision_id = packet.candidate_decision_id;
   st.candidate_direction = packet.candidate_direction;
   st.candidate_strategy_family = packet.candidate_strategy_family;

   st.source_symbol = packet.source_symbol;
   st.source_symbol_original = packet.source_symbol_original;
   st.execution_symbol = packet.execution_symbol;
   st.source_mode = packet.source_mode;
   st.freshness_state = packet.freshness_state;
   st.semantic_only_mode = packet.semantic_only_mode;
   st.price_anchor_fields_suppressed = packet.price_anchor_fields_suppressed;
   st.cross_instrument_translation_applied = packet.cross_instrument_translation_applied;
   st.source_reference_price = packet.source_reference_price;
   st.execution_reference_price = packet.execution_reference_price;
   st.cross_instrument_basis_value = packet.cross_instrument_basis_value;
   st.level_candidate_count = packet.level_candidate_count;

   st.gate_reason_code = gate.gate_reason_code;
   st.gate_block_class = gate.advisory_block_class;
   st.gate_ineligibility_reason_code = gate.advisory_ineligibility_reason_code;
   st.gate_attachment_state = gate.advisory_attachment_state;
   st.gate_note = gate.gate_note;
   st.gate_payload_present = gate.payload_present;
   st.gate_shadow_attached = gate.shadow_attached;
   st.gate_freshness_valid = gate.freshness_valid;
   st.gate_source_valid = gate.source_valid;
   st.gate_symbol_mapping_valid = gate.symbol_mapping_valid;
   st.gate_session_valid = gate.session_valid;
   st.gate_translation_valid = gate.translation_valid;
   st.gate_semantic_only_fallback_used = gate.semantic_only_fallback_used;
   st.gate_structural_relevance_valid = gate.structural_relevance_valid;
   st.gate_level_context_relevance_valid = gate.level_context_relevance_valid;
   st.hold_applied = gate.hold_applied;
   st.current_hold_active = holdState.active;
   st.current_hold_signature = holdState.candidate_signature;
   st.current_hold_release_bar_index = holdState.release_bar_index;
   st.current_hold_count_for_signature = holdState.holds_used_for_signature;
   st.evaluated_at = TimeCurrent();
}

void EvaluateAtasGovernedAdvisoryForCandidate(
   RoutedRuntimeEvaluation &routed,
   const string decisionId,
   const string direction,
   const bool integrationEnabled,
   const AtasGovernedAdvisoryRolloutMode rolloutMode,
   const int holdBars,
   const int holdLimitPerSignature,
   const double minRelevanceScore,
   const double minConfluenceScore,
   const bool requireFreshShadow,
   const bool allowSemanticOnly,
   const int levelNearThresholdPoints,
   const double rejectionRiskElevatedThreshold,
   const double breakoutRoomTightThreshold,
   AtasGovernedAdvisoryPacket &packet,
   AtasGovernedAdvisoryGateResult &gate,
   AtasGovernedAdvisoryStatus &status,
   AtasGovernedAdvisoryEffectiveness &effectiveness,
   AtasGovernedAdvisoryHoldState &holdState)
{
   InitAtasGovernedAdvisoryPacket(packet);
   InitAtasGovernedAdvisoryGateResult(gate);

   gate.gate_applied = true;
   gate.effective_rollout_mode = rolloutMode;
   gate.effective_hold_bars = MathMax(1, holdBars);
   gate.effective_hold_limit_per_signature = MathMax(1, holdLimitPerSignature);
   gate.reserved_future_block_eligible = false;

   packet.advisory_generation_time = TimeCurrent();
   packet.candidate_decision_id = TrimString(decisionId);
   packet.candidate_direction = AtasGovAdvisoryUpper(direction);
   packet.candidate_strategy_family = LAB_InferFamilyFromStrategyId(routed.council.aggregate.best_strategy_id);
   packet.advisory_direction_class = AtasGovAdvisoryDirectionClass(direction);
   packet.advisory_packet_id = "ATASADV_" + IntegerToString((int)packet.advisory_generation_time) + "_" + packet.candidate_decision_id;

   gate.payload_present = routed.council.env.atas_available;
   gate.shadow_attached = routed.council.env.atas_shadow_attached;
   gate.source_valid = routed.council.env.atas_quality_ok;
   gate.freshness_valid = (!requireFreshShadow || routed.council.env.atas_fresh);
   gate.session_valid = routed.council.env.session_ok;
   gate.structural_relevance_valid = (routed.valid && routed.active_mode == "COUNCIL" && routed.council.valid && routed.council.env.valid);

   AtasGovernedRuntimeStatusProbe probe;
   AtasGovAdvisoryLoadRuntimeStatusProbe(probe);

   packet.packet_lineage_shadow_packet_id = probe.packet_id;
   packet.packet_lineage_trace_id = probe.trace_id;
   packet.source_symbol = (StringLen(TrimString(probe.source_symbol)) > 0 ? probe.source_symbol : _Symbol);
   packet.source_symbol_original = (StringLen(TrimString(probe.source_symbol_original)) > 0 ? probe.source_symbol_original : packet.source_symbol);
   packet.execution_symbol = (StringLen(TrimString(probe.execution_symbol)) > 0 ? probe.execution_symbol : _Symbol);
   packet.source_mode = probe.source_mode;
   packet.freshness_state = (StringLen(TrimString(probe.freshness_state)) > 0 ? probe.freshness_state : (routed.council.env.atas_fresh ? "FRESH" : "STALE"));
   packet.price_space_relation = probe.price_space_relation;
   packet.source_reference_price = probe.source_reference_price;
   packet.execution_reference_price = probe.execution_reference_price;
   packet.cross_instrument_basis_value = probe.cross_instrument_basis_value;
   packet.cross_instrument_translation_applied = probe.cross_instrument_translation_applied;
   packet.price_anchor_fields_suppressed = probe.price_anchor_fields_suppressed;
   packet.semantic_only_mode = probe.price_anchor_fields_suppressed;

   if(routed.council.env.atas_level_evidence_shadow.valid && routed.council.env.atas_level_evidence_shadow.candidate_count > 0)
      packet.session_context = routed.council.env.atas_level_evidence_shadow.candidates[0].session_context;
   else
      packet.session_context = "";
   packet.level_candidate_count = routed.council.env.atas_level_evidence_shadow.candidate_count;

   gate.symbol_mapping_valid = (StringLen(TrimString(packet.execution_symbol)) > 0);
   if(StringLen(TrimString(packet.source_symbol)) <= 0)
      gate.symbol_mapping_valid = false;

   gate.translation_valid = (!packet.price_anchor_fields_suppressed);
   gate.semantic_only_fallback_used = packet.price_anchor_fields_suppressed;

   if(packet.price_anchor_fields_suppressed)
   {
      packet.translation_state_summary = (allowSemanticOnly
         ? "SEMANTIC_ONLY_FALLBACK_ACTIVE"
         : "TRANSLATION_REQUIRED_BUT_SUPPRESSED");
   }
   else if(packet.cross_instrument_translation_applied)
   {
      packet.translation_state_summary = "TRANSLATED_PRICE_ANCHORS_ACTIVE";
   }
   else if(AtasGovAdvisoryUpper(packet.price_space_relation) == "SAME_INSTRUMENT")
   {
      packet.translation_state_summary = "NATIVE_PRICE_SPACE";
   }
   else
   {
      packet.translation_state_summary = "PRICE_ANCHOR_STATE_AVAILABLE";
   }

   int directionSign = AtasGovAdvisoryDirectionSign(direction);
   LevelAwarenessBrakeReport brake;
   bool brakeOk = BuildLevelAwarenessBrakeReport(_Symbol, directionSign, routed.council, brake);
   packet.canonical_level_context_summary = (brakeOk
      ? AtasGovAdvisoryBuildCanonicalSummary(brake)
      : "canonical_level_context_unavailable");
   packet.nearest_support_price = (brakeOk ? brake.nearest_support_price : 0.0);
   packet.nearest_resistance_price = (brakeOk ? brake.nearest_resistance_price : 0.0);
   packet.nearest_support_distance_points = (brakeOk ? brake.nearest_support_distance_points : -1);
   packet.nearest_resistance_distance_points = (brakeOk ? brake.nearest_resistance_distance_points : -1);
   packet.sr_observation_source = (brakeOk ? "DIRECT_OBSERVED_CANONICAL" : "UNAVAILABLE_NOT_CAPTURED");

   string levelStates = "";
   double confluenceScore = 0.0;

   bool canonicalSupportNear = false;
   bool canonicalResistanceNear = false;
   if(brakeOk)
   {
      if(brake.nearest_support_distance_points >= 0 && brake.nearest_support_distance_points <= levelNearThresholdPoints)
      {
         canonicalSupportNear = true;
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "CANONICAL_SUPPORT_NEAR");
      }
      if(brake.nearest_resistance_distance_points >= 0 && brake.nearest_resistance_distance_points <= levelNearThresholdPoints)
      {
         canonicalResistanceNear = true;
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "CANONICAL_RESISTANCE_NEAR");
      }

      if(directionSign > 0 && canonicalSupportNear)
         confluenceScore += 0.20;
      if(directionSign < 0 && canonicalResistanceNear)
         confluenceScore += 0.20;

      if(brake.breakout_room_score <= breakoutRoomTightThreshold)
      {
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "BREAKOUT_ROOM_TIGHT");
         confluenceScore += 0.10;
      }
      if(brake.rejection_risk_score >= rejectionRiskElevatedThreshold)
      {
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "REJECTION_RISK_ELEVATED");
         confluenceScore += 0.15;
      }
      if(brake.continuation_obstacle_risk >= 0.60)
      {
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "CONTINUATION_PATH_OBSTRUCTED");
         confluenceScore += 0.10;
      }
      if(brake.reversal_trap_risk >= 0.60)
      {
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "REVERSAL_TRAP_RISK_ELEVATED");
         confluenceScore += 0.10;
      }
   }

   int directionalMatches = 0;
   int directionalConflicts = 0;
   int proximityMatches = 0;
   int proximityConflicts = 0;

   if(routed.council.env.atas_level_evidence_shadow.valid &&
      routed.council.env.atas_level_evidence_shadow.candidate_count > 0 &&
      !packet.price_anchor_fields_suppressed)
   {
      for(int i = 0; i < routed.council.env.atas_level_evidence_shadow.candidate_count; i++)
      {
         AtasLevelEvidenceRecord rec = routed.council.env.atas_level_evidence_shadow.candidates[i];
         if(!rec.valid || rec.level_price <= 0.0)
            continue;

         bool sideSupport = AtasGovAdvisoryContains(rec.level_side_candidate, "SUPPORT");
         bool sideResistance = AtasGovAdvisoryContains(rec.level_side_candidate, "RESISTANCE");
         bool directionalMatch = ((directionSign > 0 && sideSupport) || (directionSign < 0 && sideResistance));
         bool directionalConflict = ((directionSign > 0 && sideResistance) || (directionSign < 0 && sideSupport));

         if(directionalMatch)
            directionalMatches++;
         if(directionalConflict)
            directionalConflicts++;

         if(brakeOk)
         {
            double canonicalRef = (directionSign > 0 ? brake.nearest_support_price : brake.nearest_resistance_price);
            if(canonicalRef > 0.0)
            {
               double distPts = MathAbs(rec.level_price - canonicalRef) / _Point;
               if(distPts <= levelNearThresholdPoints)
               {
                  if(directionalMatch)
                     proximityMatches++;
                  if(directionalConflict)
                     proximityConflicts++;
               }
            }
         }
      }

      if(directionalMatches > 0)
         confluenceScore += 0.10;
      if(proximityMatches > 0)
      {
         confluenceScore += 0.15;
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "EXTERNAL_LEVEL_CONFLUENT");
      }
      else if(directionalConflicts > 0 || proximityConflicts > 0)
      {
         levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "EXTERNAL_LEVEL_CONFLICTED");
      }
   }
   else if(packet.price_anchor_fields_suppressed)
   {
      levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "LEVEL_CONTEXT_SEMANTIC_ONLY");
      if(allowSemanticOnly)
         confluenceScore += 0.05;
      if(!brakeOk)
         packet.sr_observation_source = "SEMANTIC_ONLY_NO_CANONICAL_LEVELS";
   }

   bool contradiction = false;
   bool confirmation = false;
   string deltaState = AtasGovAdvisoryUpper(routed.council.env.atas_shadow_overlay.delta_bias_state);
   string imbalanceState = AtasGovAdvisoryUpper(routed.council.env.atas_shadow_overlay.imbalance_state);

   if(directionSign > 0)
   {
      contradiction = (AtasGovAdvisoryContains(deltaState, "NEGATIVE") || AtasGovAdvisoryContains(imbalanceState, "SELL_IMBALANCE"));
      confirmation = (AtasGovAdvisoryContains(deltaState, "POSITIVE") || AtasGovAdvisoryContains(imbalanceState, "BUY_IMBALANCE"));
   }
   else
   {
      contradiction = (AtasGovAdvisoryContains(deltaState, "POSITIVE") || AtasGovAdvisoryContains(imbalanceState, "BUY_IMBALANCE"));
      confirmation = (AtasGovAdvisoryContains(deltaState, "NEGATIVE") || AtasGovAdvisoryContains(imbalanceState, "SELL_IMBALANCE"));
   }

   if(confirmation)
      confluenceScore += 0.10;
   if(contradiction)
      levelStates = AtasGovAdvisoryAppendStateTag(levelStates, "EXTERNAL_LEVEL_CONFLICTED");

   bool levelSupportive =
      ((directionSign > 0 && canonicalSupportNear) ||
       (directionSign < 0 && canonicalResistanceNear) ||
       proximityMatches > 0 ||
       directionalMatches > 0 ||
       confirmation);
   bool levelObstructive =
      ((brakeOk && brake.rejection_risk_score >= rejectionRiskElevatedThreshold) ||
       (brakeOk && brake.continuation_obstacle_risk >= 0.60) ||
       directionalConflicts > 0 ||
       proximityConflicts > 0 ||
       contradiction);
   bool levelDegraded =
      (AtasGovAdvisoryContains(levelStates, "BREAKOUT_ROOM_TIGHT") ||
       AtasGovAdvisoryContains(levelStates, "REVERSAL_TRAP_RISK_ELEVATED") ||
       packet.price_anchor_fields_suppressed);

   packet.level_context_supportive = levelSupportive;
   packet.level_context_obstructive = levelObstructive;
   packet.level_context_degraded = levelDegraded;
   if(levelSupportive && !levelObstructive)
      packet.level_interaction_type = "LEVEL_CONTEXT_SUPPORTED";
   else if(levelObstructive && !levelSupportive)
      packet.level_interaction_type = "LEVEL_CONTEXT_OBSTRUCTED";
   else if(levelSupportive && levelObstructive)
      packet.level_interaction_type = "LEVEL_CONTEXT_MIXED_CONFLICTED";
   else if(levelDegraded)
      packet.level_interaction_type = "LEVEL_CONTEXT_DEGRADED";
   else if(brakeOk || routed.council.env.atas_level_evidence_shadow.valid)
      packet.level_interaction_type = "LEVEL_CONTEXT_NEUTRAL";
   else
      packet.level_interaction_type = "LEVEL_CONTEXT_UNAVAILABLE";

   confluenceScore = AtasGovAdvisoryClamp01(confluenceScore);

   double overlayStrength = 0.0;
   if(routed.council.env.atas_shadow_overlay.valid && routed.council.env.atas_shadow_overlay.overlay_weight_cap > 0.0)
      overlayStrength = AtasGovAdvisoryClamp01(routed.council.env.atas_shadow_overlay.overlay_weight / routed.council.env.atas_shadow_overlay.overlay_weight_cap);

   double relevanceScore = AtasGovAdvisoryClamp01(0.35 * routed.council.env.total_score + 0.35 * confluenceScore + 0.30 * overlayStrength);
   packet.advisory_relevance_score = relevanceScore;
   packet.advisory_confluence_score = confluenceScore;
   packet.advisory_confidence_band = AtasGovAdvisoryConfidenceBand(relevanceScore);
   packet.advisory_strength_band = "LOW";
   packet.advisory_level_context_state_csv = levelStates;
   packet.contradiction_flag = contradiction;
   packet.confirmation_support_flag = confirmation;
   packet.external_level_confluence_summary =
      "directional_matches=" + IntegerToString(directionalMatches) +
      "|directional_conflicts=" + IntegerToString(directionalConflicts) +
      "|proximity_matches=" + IntegerToString(proximityMatches) +
      "|proximity_conflicts=" + IntegerToString(proximityConflicts);

   gate.effective_relevance_score = relevanceScore;
   gate.effective_confluence_score = confluenceScore;
   gate.contradiction_flag = contradiction;
   gate.level_context_relevance_valid =
      (brakeOk ||
       routed.council.env.atas_level_evidence_shadow.valid ||
       packet.semantic_only_mode);

   bool eligible = true;
   string gateReason = "";

   if(!integrationEnabled)
   {
      eligible = false;
      gateReason = "atas_governed_advisory_disabled";
   }
   else if(!gate.structural_relevance_valid)
   {
      eligible = false;
      gateReason = "runtime_context_not_council_ready";
   }
   else if(!gate.payload_present)
   {
      eligible = false;
      gateReason = "atas_shadow_payload_unavailable";
   }
   else if(!gate.shadow_attached)
   {
      eligible = false;
      gateReason = "atas_shadow_not_attached";
   }
   else if(!gate.source_valid)
   {
      eligible = false;
      gateReason = "atas_shadow_quality_insufficient";
   }
   else if(!gate.freshness_valid)
   {
      eligible = false;
      gateReason = "atas_shadow_freshness_invalid";
   }
   else if(!gate.session_valid)
   {
      eligible = false;
      gateReason = "session_not_eligible";
   }
   else if(!gate.symbol_mapping_valid)
   {
      eligible = false;
      gateReason = "symbol_mapping_invalid";
   }
   else if(!allowSemanticOnly && gate.semantic_only_fallback_used)
   {
      eligible = false;
      gateReason = "semantic_only_fallback_disallowed";
   }
   else if(!gate.level_context_relevance_valid)
   {
      eligible = false;
      gateReason = "level_context_insufficient";
   }

   gate.advisory_eligible = eligible;
   packet.advisory_eligibility_state = (eligible ? "ELIGIBLE" : "INELIGIBLE");
   packet.advisory_ineligibility_reason_code = (eligible ? "NONE" : gateReason);

   if(!eligible)
   {
      packet.valid = false;
      packet.advisory_state = (gate.payload_present ? ATAS_ADVISORY_INELIGIBLE : ATAS_ADVISORY_UNAVAILABLE);
      packet.advisory_reason_codes_csv = AtasGovAdvisoryAppendReasonCode(packet.advisory_reason_codes_csv, gateReason);
      packet.advisory_summary_short = "ATAS advisory unavailable/ineligible; runtime fallback remains MT5 canonical path.";
      packet.advisory_strength_band = "NONE";
      gate.gate_outcome = (integrationEnabled ? ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY : ATAS_ADVISORY_OUTCOME_IGNORE);
      gate.gate_reason_code = gateReason;
      gate.gate_note = "bounded_fallback_mt5_only";
   }
   else
   {
      packet.valid = true;

      if(relevanceScore < minRelevanceScore || confluenceScore < minConfluenceScore)
      {
         packet.advisory_state = ATAS_ADVISORY_INSUFFICIENT_EVIDENCE;
         packet.advisory_reason_codes_csv = AtasGovAdvisoryAppendReasonCode(packet.advisory_reason_codes_csv, "INSUFFICIENT_RELEVANCE_OR_CONFLUENCE");
         if(relevanceScore < minRelevanceScore)
            packet.advisory_reason_codes_csv = AtasGovAdvisoryAppendReasonCode(packet.advisory_reason_codes_csv, "LOW_RELEVANCE");
         if(confluenceScore < minConfluenceScore)
            packet.advisory_reason_codes_csv = AtasGovAdvisoryAppendReasonCode(packet.advisory_reason_codes_csv, "LOW_CONFLUENCE");
         packet.advisory_summary_short = "ATAS advisory evidence exists but remains below bounded relevance/confluence threshold.";
         gate.gate_outcome = ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY;
         gate.gate_reason_code = "insufficient_relevance_or_confluence";
         gate.gate_note = "display_only";
      }
      else if(contradiction)
      {
         bool strong = (relevanceScore >= 0.75 || confluenceScore >= 0.75);
         packet.advisory_state = (strong ? ATAS_ADVISORY_STRONG_CAUTION : ATAS_ADVISORY_CAUTION);
         packet.caution_bias = true;
         packet.reevaluation_bias = true;
         packet.hold_bias = strong;
         packet.advisory_reason_codes_csv = AtasGovAdvisoryAppendReasonCode(packet.advisory_reason_codes_csv, "CONTRADICTION_SIGNAL");
         packet.advisory_summary_short = "ATAS bounded advisory detects contradiction versus candidate context.";

         if(rolloutMode == ATAS_ADVISORY_ROLLOUT_HOLD_REEVALUATE && strong)
         {
            gate.gate_outcome = ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION;
            gate.gate_reason_code = "strong_contradiction_hold_eligible";
            gate.gate_note = "bounded_hold_candidate";
         }
         else if(rolloutMode == ATAS_ADVISORY_ROLLOUT_SOFT_INFLUENCE || rolloutMode == ATAS_ADVISORY_ROLLOUT_HOLD_REEVALUATE)
         {
            gate.gate_outcome = ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR;
            gate.gate_reason_code = "contradiction_flag_operator";
            gate.gate_note = "soft_influence_only";
         }
         else
         {
            gate.gate_outcome = ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY;
            gate.gate_reason_code = "observe_only_contradiction_display";
            gate.gate_note = "observe_only";
         }
      }
      else
      {
         packet.advisory_state = ATAS_ADVISORY_OK;
         packet.confirmation_support_flag = true;
         packet.advisory_reason_codes_csv = AtasGovAdvisoryAppendReasonCode(packet.advisory_reason_codes_csv, "CONFLUENT_CONTEXT");
         packet.advisory_summary_short = "ATAS advisory context is confluent and non-contradictory for current candidate.";

         if(rolloutMode == ATAS_ADVISORY_ROLLOUT_SOFT_INFLUENCE && relevanceScore >= 0.70)
         {
            gate.gate_outcome = ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR;
            gate.gate_reason_code = "confirmation_flag_for_operator";
            gate.gate_note = "soft_influence_confirmation";
         }
         else
         {
            gate.gate_outcome = ATAS_ADVISORY_OUTCOME_DISPLAY_ONLY;
            gate.gate_reason_code = "bounded_confirmation_display";
            gate.gate_note = "display_only_confirmation";
         }
      }

      packet.advisory_strength_band = AtasGovAdvisoryStrengthBand(packet.advisory_state, relevanceScore);
   }

   gate.advisory_attachment_state = AtasGovAdvisoryBuildAttachmentState(gate);
   gate.advisory_ineligibility_reason_code = (gate.advisory_eligible ? "NONE" : gate.gate_reason_code);
   gate.advisory_block_class = AtasGovAdvisoryClassifyBlockClass(gate.gate_reason_code);
   packet.advisory_attachment_state = gate.advisory_attachment_state;
   packet.advisory_block_class = gate.advisory_block_class;
   packet.advisory_usage_state = AtasGovAdvisoryBuildUsageState(packet, gate);
   packet.advisory_zero_effect_reason = AtasGovAdvisoryBuildZeroEffectReason(packet, gate);

   if(gate.gate_outcome == ATAS_ADVISORY_OUTCOME_HOLD_FOR_REEVALUATION)
   {
      string candidateSignature = AtasGovAdvisoryBuildCandidateSignature(routed, direction);
      if(AtasGovAdvisoryCanApplyHold(holdState, candidateSignature, gate.effective_hold_limit_per_signature))
      {
         AtasGovAdvisoryApplyHold(
            holdState,
            packet,
            candidateSignature,
            gate.effective_hold_bars,
            gate.gate_reason_code
         );
         gate.hold_applied = true;
      }
      else
      {
         gate.gate_outcome = ATAS_ADVISORY_OUTCOME_FLAG_FOR_OPERATOR;
         gate.gate_reason_code = "hold_budget_exhausted_display_only";
         gate.gate_note = "hold_budget_exhausted";
         gate.hold_applied = false;
      }
   }
   else
   {
      AtasGovAdvisoryUpdateHoldStateTimeBudget(holdState);
   }

   gate.advisory_attachment_state = AtasGovAdvisoryBuildAttachmentState(gate);
   gate.advisory_ineligibility_reason_code = (gate.advisory_eligible ? "NONE" : gate.gate_reason_code);
   gate.advisory_block_class = AtasGovAdvisoryClassifyBlockClass(gate.gate_reason_code);
   packet.advisory_attachment_state = gate.advisory_attachment_state;
   packet.advisory_ineligibility_reason_code = gate.advisory_ineligibility_reason_code;
   packet.advisory_block_class = gate.advisory_block_class;
   packet.advisory_usage_state = AtasGovAdvisoryBuildUsageState(packet, gate);
   packet.advisory_zero_effect_reason = AtasGovAdvisoryBuildZeroEffectReason(packet, gate);

   packet.support_resistance_confluence_state = levelStates;
   gate.contradiction_flag = packet.contradiction_flag;

   AtasGovAdvisoryUpdateStatus(status, integrationEnabled, packet, gate, holdState);
   AtasGovAdvisoryTrackEffectiveness(effectiveness, packet, gate);

   routed.council.env.atas_advisory_available = gate.payload_present;
   routed.council.env.atas_advisory_eligible = gate.advisory_eligible;
   routed.council.env.atas_advisory_state = AtasGovernedAdvisoryStateToText(packet.advisory_state);
   routed.council.env.atas_advisory_outcome = AtasGovernedAdvisoryOutcomeToText(gate.gate_outcome);
   routed.council.env.atas_advisory_relevance_score = packet.advisory_relevance_score;
   routed.council.env.atas_advisory_contradiction = packet.contradiction_flag;
   routed.council.env.atas_advisory_hold_bias_active = packet.hold_bias;
   routed.council.env.atas_advisory_level_confluence_state = packet.support_resistance_confluence_state;
   routed.council.env.atas_advisory_summary = packet.advisory_summary_short;
   routed.council.env.atas_canonical_level_context_summary = packet.canonical_level_context_summary;
   routed.council.env.atas_advisory_attachment_state = packet.advisory_attachment_state;
   routed.council.env.atas_advisory_ineligibility_reason_code = packet.advisory_ineligibility_reason_code;
   routed.council.env.atas_advisory_gate_reason_code = gate.gate_reason_code;
   routed.council.env.atas_advisory_block_class = packet.advisory_block_class;
   routed.council.env.atas_advisory_usage_state = packet.advisory_usage_state;
   routed.council.env.atas_advisory_zero_effect_reason = packet.advisory_zero_effect_reason;

   routed.council.env.atas_nearest_support_price = packet.nearest_support_price;
   routed.council.env.atas_nearest_resistance_price = packet.nearest_resistance_price;
   routed.council.env.atas_nearest_support_distance_points = packet.nearest_support_distance_points;
   routed.council.env.atas_nearest_resistance_distance_points = packet.nearest_resistance_distance_points;
   routed.council.env.atas_level_interaction_type = packet.level_interaction_type;
   routed.council.env.atas_level_context_supported = packet.level_context_supportive;
   routed.council.env.atas_level_context_obstructed = packet.level_context_obstructive;
   routed.council.env.atas_level_context_degraded = packet.level_context_degraded;
   routed.council.env.atas_sr_observation_source = packet.sr_observation_source;

   SaveAtasGovernedAdvisoryArtifactsBestEffort(status, effectiveness, packet, gate);
}

void RefreshAtasGovernedAdvisoryArtifactsBestEffort(
   const bool integrationEnabled,
   const int rolloutModeInput,
   AtasGovernedAdvisoryStatus &status,
   bool &statusInitialized,
   AtasGovernedAdvisoryEffectiveness &effectiveness,
   bool &effectivenessInitialized,
   AtasGovernedAdvisoryHoldState &holdState,
   bool &holdInitialized)
{
   if(!statusInitialized)
   {
      InitAtasGovernedAdvisoryStatus(status);
      statusInitialized = true;
   }
   if(!effectivenessInitialized)
   {
      InitAtasGovernedAdvisoryEffectiveness(effectiveness);
      effectivenessInitialized = true;
   }
   if(!holdInitialized)
   {
      InitAtasGovernedAdvisoryHoldState(holdState);
      holdInitialized = true;
   }

   status.advisory_integration_enabled = integrationEnabled;
   status.rollout_mode = AtasGovernedAdvisoryRolloutModeFromInput(rolloutModeInput);
   if(status.evaluated_at <= 0)
      status.evaluated_at = TimeCurrent();
   status.current_hold_active = holdState.active;
   status.current_hold_signature = holdState.candidate_signature;
   status.current_hold_release_bar_index = holdState.release_bar_index;
   status.current_hold_count_for_signature = holdState.holds_used_for_signature;

   AtasGovernedAdvisoryPacket packet;
   AtasGovernedAdvisoryGateResult gate;
   InitAtasGovernedAdvisoryPacket(packet);
   InitAtasGovernedAdvisoryGateResult(gate);
   packet.advisory_generation_time = status.evaluated_at;
   packet.advisory_state = status.advisory_state;
   packet.advisory_relevance_score = status.advisory_relevance_score;
   packet.advisory_confluence_score = status.advisory_confluence_score;
   packet.advisory_reason_codes_csv = status.advisory_reason_codes_csv;
   packet.advisory_summary_short = status.advisory_summary;
   packet.advisory_attachment_state = status.advisory_attachment_state;
   packet.advisory_ineligibility_reason_code = status.advisory_ineligibility_reason_code;
   packet.advisory_block_class = status.advisory_block_class;
   packet.advisory_usage_state = status.advisory_usage_state;
   packet.advisory_zero_effect_reason = status.advisory_zero_effect_reason;
   packet.support_resistance_confluence_state = status.support_resistance_confluence_state;
   packet.nearest_support_price = status.nearest_support_price;
   packet.nearest_resistance_price = status.nearest_resistance_price;
   packet.nearest_support_distance_points = status.nearest_support_distance_points;
   packet.nearest_resistance_distance_points = status.nearest_resistance_distance_points;
   packet.level_interaction_type = status.level_interaction_type;
   packet.level_context_supportive = status.level_context_supportive;
   packet.level_context_obstructive = status.level_context_obstructive;
   packet.level_context_degraded = status.level_context_degraded;
   packet.sr_observation_source = status.sr_observation_source;
   packet.translation_state_summary = status.translation_state_summary;

   gate.gate_applied = false;
   gate.gate_outcome = status.advisory_outcome;
   gate.gate_reason_code = status.gate_reason_code;
    gate.advisory_attachment_state = status.gate_attachment_state;
   gate.advisory_ineligibility_reason_code = status.gate_ineligibility_reason_code;
   gate.advisory_block_class = status.gate_block_class;
   gate.advisory_eligible = status.advisory_eligible;
   gate.payload_present = status.gate_payload_present;
   gate.shadow_attached = status.gate_shadow_attached;
   gate.freshness_valid = status.gate_freshness_valid;
   gate.source_valid = status.gate_source_valid;
   gate.symbol_mapping_valid = status.gate_symbol_mapping_valid;
   gate.session_valid = status.gate_session_valid;
   gate.translation_valid = status.gate_translation_valid;
   gate.semantic_only_fallback_used = status.gate_semantic_only_fallback_used;
   gate.structural_relevance_valid = status.gate_structural_relevance_valid;
   gate.level_context_relevance_valid = status.gate_level_context_relevance_valid;
   gate.effective_rollout_mode = status.rollout_mode;
   gate.hold_applied = status.hold_applied;

   SaveAtasGovernedAdvisoryArtifactsBestEffort(status, effectiveness, packet, gate);
}

#endif
