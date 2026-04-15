#ifndef __ATAS_INTAKE_LAYER_MQH__
#define __ATAS_INTAKE_LAYER_MQH__

#include "atas_runtime_contract.mqh"
#undef ATAS_MAX_CONTEXT_AGE_SECONDS
#define ATAS_MAX_CONTEXT_AGE_SECONDS 15

string AtasRuntimeContextPath() { return "AI\\atas_microstructure_context.json"; }
string AtasRuntimeContextStatusPath() { return "AI\\atas_microstructure_status.json"; }
string AtasRuntimeContextLegacyMirrorPath() { return "AI\\atas_runtime_context.json"; }
string AtasRuntimeContextStatusLegacyMirrorPath() { return "AI\\atas_runtime_context_status.json"; }

double AtasClamp01(double v)
{
   if(v < 0.0) return 0.0;
   if(v > 1.0) return 1.0;
   return v;
}

string AtasEscapeJson(string value)
{
   string out = value;
   StringReplace(out, "\\", "\\\\");
   StringReplace(out, "\"", "\\\"");
   StringReplace(out, "\r", " ");
   StringReplace(out, "\n", " ");
   return out;
}

string AtasUpper(string value)
{
   value = TrimString(value);
   StringToUpper(value);
   return value;
}

datetime AtasFreshnessBaselineUtcNow()
{
   datetime now_utc = TimeGMT();
   if(now_utc > 0)
      return now_utc;
   return TimeCurrent();
}

bool AtasReadTextFileAll(const string rel_path, string &out_text)
{
   out_text = "";
   int h = FileOpen(rel_path, FILE_READ | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   while(!FileIsEnding(h))
      out_text += FileReadString(h);

   FileClose(h);
   return true;
}

bool AtasWriteTextFileAll(const string rel_path, const string text)
{
   int h = FileOpen(rel_path, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;
   FileWriteString(h, text);
   FileClose(h);
   return true;
}

datetime AtasParseTimestamp(string raw)
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

   bool has_timezone = false;
   int source_offset_seconds = 0;
   string ts_raw = raw;

   int z_pos = StringFind(ts_raw, "Z");
   if(z_pos < 0)
      z_pos = StringFind(ts_raw, "z");
   if(z_pos > 0)
   {
      has_timezone = true;
      source_offset_seconds = 0;
      ts_raw = StringSubstr(ts_raw, 0, z_pos);
   }
   else
   {
      int tz_pos = -1;
      int raw_len = StringLen(ts_raw);
      for(int i = 19; i < raw_len; i++)
      {
         ushort c = StringGetCharacter(ts_raw, i);
         if(c == '+' || c == '-')
         {
            tz_pos = i;
            break;
         }
      }

      if(tz_pos > 0)
      {
         string sign_text = StringSubstr(ts_raw, tz_pos, 1);
         string tz_body = StringSubstr(ts_raw, tz_pos + 1);
         int tz_hours = 0;
         int tz_minutes = 0;

         if(StringLen(tz_body) >= 5 && StringSubstr(tz_body, 2, 1) == ":")
         {
            tz_hours = (int)StringToInteger(StringSubstr(tz_body, 0, 2));
            tz_minutes = (int)StringToInteger(StringSubstr(tz_body, 3, 2));
         }
         else if(StringLen(tz_body) >= 4)
         {
            tz_hours = (int)StringToInteger(StringSubstr(tz_body, 0, 2));
            tz_minutes = (int)StringToInteger(StringSubstr(tz_body, 2, 2));
         }
         else if(StringLen(tz_body) >= 2)
         {
            tz_hours = (int)StringToInteger(StringSubstr(tz_body, 0, 2));
            tz_minutes = 0;
         }

         int sign = (sign_text == "-") ? -1 : 1;
         source_offset_seconds = sign * (tz_hours * 3600 + tz_minutes * 60);
         has_timezone = true;
         ts_raw = StringSubstr(ts_raw, 0, tz_pos);
      }
   }

   StringReplace(ts_raw, "T", " ");
   StringReplace(ts_raw, "-", ".");
   StringReplace(ts_raw, "/", ".");
   int frac_pos = -1;
   int ts_len = StringLen(ts_raw);
   for(int i = 19; i < ts_len; i++)
   {
      if(StringGetCharacter(ts_raw, i) == '.')
      {
         frac_pos = i;
         break;
      }
   }
   if(frac_pos > 0)
      ts_raw = StringSubstr(ts_raw, 0, frac_pos);
   if(StringLen(ts_raw) >= 19)
      ts_raw = StringSubstr(ts_raw, 0, 19);

   if(StringLen(ts_raw) < 19)
   {
      if(has_timezone)
         return 0;
      return StringToTime(ts_raw);
   }

   int year = (int)StringToInteger(StringSubstr(ts_raw, 0, 4));
   int month = (int)StringToInteger(StringSubstr(ts_raw, 5, 2));
   int day = (int)StringToInteger(StringSubstr(ts_raw, 8, 2));
   int hour = (int)StringToInteger(StringSubstr(ts_raw, 11, 2));
   int minute = (int)StringToInteger(StringSubstr(ts_raw, 14, 2));
   int second = (int)StringToInteger(StringSubstr(ts_raw, 17, 2));

   if(year < 1970 || month < 1 || month > 12 || day < 1 || day > 31 ||
      hour < 0 || hour > 23 || minute < 0 || minute > 59 || second < 0 || second > 59)
   {
      if(has_timezone)
         return 0;
      return StringToTime(ts_raw);
   }

   int month_days[] = {31,28,31,30,31,30,31,31,30,31,30,31};
   bool leap = ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0));
   if(leap)
      month_days[1] = 29;
   if(day > month_days[month - 1])
   {
      if(has_timezone)
         return 0;
      return StringToTime(ts_raw);
   }

   long days = 0;
   for(int y = 1970; y < year; y++)
   {
      bool y_leap = ((y % 4 == 0 && y % 100 != 0) || (y % 400 == 0));
      days += (y_leap ? 366 : 365);
   }
   for(int m = 1; m < month; m++)
      days += month_days[m - 1];
   days += (day - 1);

   long epoch = (days * 86400) + (hour * 3600) + (minute * 60) + second;
   if(has_timezone)
      epoch -= source_offset_seconds;

   return (datetime)epoch;
}

bool AtasExtractArrayRaw(const string json, const string key, string &array_raw)
{
   array_raw = "";
   string pattern = "\"" + key + "\"";
   int p = StringFind(json, pattern);
   if(p < 0)
      return false;

   p = StringFind(json, ":", p);
   if(p < 0)
      return false;

   int s = StringFind(json, "[", p);
   if(s < 0)
      return false;

   int depth = 0;
   int len = StringLen(json);
   for(int i = s; i < len; i++)
   {
      ushort c = StringGetCharacter(json, i);
      if(c == '[')
         depth++;
      else if(c == ']')
      {
         depth--;
         if(depth == 0)
         {
            array_raw = StringSubstr(json, s + 1, i - s - 1);
            return true;
         }
      }
   }

   return false;
}

int AtasExtractArrayObjects(const string array_raw, string &objects[])
{
   ArrayResize(objects, 0);
   int depth = 0;
   int start = -1;
   int len = StringLen(array_raw);

   for(int i = 0; i < len; i++)
   {
      ushort c = StringGetCharacter(array_raw, i);
      if(c == '{')
      {
         if(depth == 0)
            start = i;
         depth++;
      }
      else if(c == '}')
      {
         if(depth > 0)
         {
            depth--;
            if(depth == 0 && start >= 0)
            {
               int n = ArraySize(objects);
               ArrayResize(objects, n + 1);
               objects[n] = StringSubstr(array_raw, start, i - start + 1);
               start = -1;
               if(ArraySize(objects) >= ATAS_MAX_LEVEL_CANDIDATES)
                  break;
            }
         }
      }
   }

   return ArraySize(objects);
}

bool AtasParseLevelEvidenceRecord(const string object_json, AtasLevelEvidenceRecord &r)
{
   InitAtasLevelEvidenceRecord(r);

   ExtractJsonDoubleField(object_json, "level_price", r.level_price);
   ExtractJsonStringField(object_json, "level_side_candidate", r.level_side_candidate);
   ExtractJsonStringField(object_json, "level_class", r.level_class);
   ExtractJsonStringField(object_json, "level_origin", r.level_origin);
   ExtractJsonStringField(object_json, "session_context", r.session_context);
   ExtractJsonDoubleField(object_json, "absorption_strength", r.absorption_strength);
   ExtractJsonBoolField(object_json, "sweep_detected", r.sweep_detected);
   ExtractJsonBoolField(object_json, "reclaim_confirmed", r.reclaim_confirmed);
   ExtractJsonDoubleField(object_json, "imbalance_ratio", r.imbalance_ratio);
   ExtractJsonStringField(object_json, "delta_divergence_state", r.delta_divergence_state);
   ExtractJsonStringField(object_json, "exhaustion_hint", r.exhaustion_hint);
   ExtractJsonIntField(object_json, "touch_count_local", r.touch_count_local);
   ExtractJsonDoubleField(object_json, "reaction_strength", r.reaction_strength);
   ExtractJsonDoubleField(object_json, "stability_score", r.stability_score);
   ExtractJsonStringField(object_json, "fresh_until", r.fresh_until);
   ExtractJsonDoubleField(object_json, "invalidation_distance_ticks", r.invalidation_distance_ticks);
   ExtractJsonStringField(object_json, "candidate_role", r.candidate_role);
   ExtractJsonStringField(object_json, "market_behavior_tag", r.market_behavior_tag);

   r.valid = (r.level_price > 0.0 && StringLen(TrimString(r.level_side_candidate)) > 0);
   return r.valid;
}

void AtasBuildLevelEvidenceBundle(
   const string context_json,
   const bool suppress_price_anchored_levels,
   AtasLevelEvidenceBundle &bundle)
{
   InitAtasLevelEvidenceBundle(bundle);

   if(suppress_price_anchored_levels)
   {
      bundle.summary = "LEVEL_PRICE_FIELDS_SUPPRESSED";
      return;
   }

   string array_raw = "";
   if(!AtasExtractArrayRaw(context_json, "level_candidates", array_raw))
   {
      bundle.summary = "NO_LEVEL_CANDIDATES";
      return;
   }

   string objects[];
   int object_count = AtasExtractArrayObjects(array_raw, objects);
   if(object_count <= 0)
   {
      bundle.summary = "NO_LEVEL_CANDIDATES";
      return;
   }

   int accepted = 0;
   for(int i = 0; i < object_count && accepted < ATAS_MAX_LEVEL_CANDIDATES; i++)
   {
      AtasLevelEvidenceRecord rec;
      if(AtasParseLevelEvidenceRecord(objects[i], rec))
      {
         bundle.candidates[accepted] = rec;
         accepted++;
      }
   }

   bundle.candidate_count = accepted;
   bundle.valid = (accepted > 0);
   if(bundle.valid)
      bundle.summary = "LEVEL_EVIDENCE_ATTACHED";
   else
      bundle.summary = "LEVEL_EVIDENCE_EMPTY";
}

void AtasBuildShadowOverlay(const AtasRuntimePacket &packet, AtasMicrostructureOverlay &overlay)
{
   InitAtasMicrostructureOverlay(overlay);
   if(!packet.valid)
      return;

   overlay.valid = true;
   overlay.non_authoritative = true;
   overlay.overlay_weight_cap = ATAS_MAX_OVERLAY_WEIGHT;
   overlay.overlay_weight = MathMin(ATAS_MAX_OVERLAY_WEIGHT, AtasClamp01(packet.packet_confidence) * ATAS_MAX_OVERLAY_WEIGHT);

   overlay.liquidity_sweep_state = packet.liquidity_sweep_state;
   overlay.absorption_state = packet.absorption_state;
   overlay.delta_bias_state = packet.delta_bias_state;
   overlay.imbalance_state = packet.imbalance_state;
   overlay.liquidity_stability_state = packet.liquidity_stability_state;
   overlay.continuation_exhaustion_hint = packet.continuation_exhaustion_hint;
   overlay.summary = "ATAS shadow overlay attached (non-authoritative, non-consumed).";
}

string AtasBuildEvaluationTraceId(const AtasRuntimePacket &packet, const datetime now_ts)
{
   string pid = TrimString(packet.packet_id);
   if(StringLen(pid) <= 0)
      pid = "NO_PACKET";
   if(StringLen(pid) > 40)
      pid = StringSubstr(pid, 0, 40);

   return "ATAS_EVAL_" + IntegerToString((int)now_ts) + "_" + pid;
}

bool AtasTryCaptureExecutionReferencePrice(const string execution_symbol, double &reference_price)
{
   reference_price = 0.0;

   string symbol = TrimString(execution_symbol);
   if(StringLen(symbol) <= 0)
      symbol = _Symbol;

   double bid = 0.0;
   double ask = 0.0;
   bool has_bid = SymbolInfoDouble(symbol, SYMBOL_BID, bid);
   bool has_ask = SymbolInfoDouble(symbol, SYMBOL_ASK, ask);

   if(has_bid && has_ask && bid > 0.0 && ask > 0.0)
   {
      reference_price = (bid + ask) * 0.5;
      return true;
   }

   if(has_bid && bid > 0.0)
   {
      reference_price = bid;
      return true;
   }

   if(has_ask && ask > 0.0)
   {
      reference_price = ask;
      return true;
   }

   return false;
}

void AtasEmitRuntimeContextStatus(
   const string execution_symbol,
   const bool base_environment_valid,
   const bool atas_available,
   const bool atas_shadow_attached,
   const bool atas_quality_ok,
   const bool atas_fresh,
   const AtasFreshnessState freshness_state,
   const AtasRuntimePacket &packet,
   const AtasMicrostructureOverlay &overlay,
   const AtasLevelEvidenceBundle &bundle,
   const string acceptance_state,
   const AtasRejectionReason rejection_reason,
   const string summary
)
{
   datetime now_ts = AtasFreshnessBaselineUtcNow();
   datetime event_ts = AtasParseTimestamp(packet.event_time);
   long packet_age_ms = -1;
   if(event_ts > 0 && now_ts >= event_ts)
      packet_age_ms = (long)(now_ts - event_ts) * 1000;

   string quality_state = AtasQualityStateToText(packet.data_quality_state);
   string freshness_text = AtasFreshnessStateToText(freshness_state);
   string source_platform = TrimString(packet.source_platform);
   if(StringLen(source_platform) <= 0)
      source_platform = "ATAS";

   string status_timestamp_utc = TimeToString(now_ts, TIME_DATE | TIME_SECONDS);
   string trace_id = AtasBuildEvaluationTraceId(packet, now_ts);

   string json = "{";
   json += "\"artifact_role\":\"ATAS_MICROSTRUCTURE_STATUS\"";
   json += ",\"artifact_authority_class\":\"NON_AUTHORITATIVE_EXTERNAL_SHADOW_STATUS\"";
   json += ",\"schema_version\":\"" + AtasEscapeJson(ATAS_RUNTIME_STATUS_SCHEMA_VERSION) + "\"";
   json += ",\"source_platform\":\"" + AtasEscapeJson(source_platform) + "\"";
   json += ",\"last_packet_id\":\"" + AtasEscapeJson(packet.packet_id) + "\"";
   json += ",\"packet_id\":\"" + AtasEscapeJson(packet.packet_id) + "\"";
   json += ",\"last_acceptance_state\":\"" + AtasEscapeJson(acceptance_state) + "\"";
   json += ",\"last_rejection_reason\":\"" + AtasEscapeJson(AtasRejectionReasonToText(rejection_reason)) + "\"";
   json += ",\"packet_age_ms\":" + IntegerToString((int)packet_age_ms);
   json += ",\"source_symbol\":\"" + AtasEscapeJson(packet.source_symbol) + "\"";
   json += ",\"source_symbol_original\":\"" + AtasEscapeJson(packet.source_symbol_original) + "\"";
   json += ",\"execution_symbol\":\"" + AtasEscapeJson(packet.execution_symbol) + "\"";
   json += ",\"source_reference_price\":" + DoubleToString(packet.source_reference_price, 5);
   json += ",\"execution_reference_price\":" + DoubleToString(packet.execution_reference_price, 5);
   json += ",\"cross_instrument_translation_applied\":" + string(packet.cross_instrument_translation_applied ? "true" : "false");
   json += ",\"cross_instrument_basis_value\":" + DoubleToString(packet.cross_instrument_basis_value, 5);
   json += ",\"price_anchor_fields_suppressed\":" + string(packet.price_anchor_fields_suppressed ? "true" : "false");
   json += ",\"price_space_relation\":\"" + AtasEscapeJson(packet.price_space_relation) + "\"";
   json += ",\"source_mode\":\"" + AtasEscapeJson(AtasSourceModeToText(packet.source_mode)) + "\"";
   json += ",\"quality_state\":\"" + AtasEscapeJson(quality_state) + "\"";
   json += ",\"freshness_state\":\"" + AtasEscapeJson(freshness_text) + "\"";
   json += ",\"shadow_attached\":" + string(atas_shadow_attached ? "true" : "false");
   json += ",\"consumption_mode\":\"" + AtasEscapeJson(AtasConsumptionModeToText(ATAS_CONSUMPTION_SHADOW_ONLY)) + "\"";
   json += ",\"trace_id\":\"" + AtasEscapeJson(trace_id) + "\"";
   json += ",\"status_timestamp_utc\":\"" + AtasEscapeJson(status_timestamp_utc) + "\"";
   json += ",\"summary\":\"" + AtasEscapeJson(summary) + "\"";
   json += ",\"evaluated_at\":\"" + AtasEscapeJson(status_timestamp_utc) + "\"";
   json += ",\"base_environment_source\":\"MT5_RUNTIME_ENVIRONMENT\"";
   json += ",\"base_environment_valid\":" + string(base_environment_valid ? "true" : "false");
   json += ",\"atas_available\":" + string(atas_available ? "true" : "false");
   json += ",\"atas_shadow_attached\":" + string(atas_shadow_attached ? "true" : "false");
   json += ",\"atas_quality_ok\":" + string(atas_quality_ok ? "true" : "false");
   json += ",\"atas_fresh\":" + string(atas_fresh ? "true" : "false");
   json += ",\"acceptance_state\":\"" + AtasEscapeJson(acceptance_state) + "\"";
   json += ",\"rejection_reason\":\"" + AtasEscapeJson(AtasRejectionReasonToText(rejection_reason)) + "\"";
   json += "}";

   AtasWriteTextFileAll(AtasRuntimeContextStatusPath(), json);
   string legacy_status_path = AtasRuntimeContextStatusLegacyMirrorPath();
   if(legacy_status_path != AtasRuntimeContextStatusPath())
      AtasWriteTextFileAll(legacy_status_path, json);
}

bool AtasLoadAndValidatePacket(
   const string execution_symbol,
   const bool base_environment_valid,
   bool &payload_present,
   AtasRuntimePacket &packet,
   AtasRejectionReason &rejection_reason,
   AtasFreshnessState &freshness_state,
   bool &quality_ok,
   bool &fresh,
   string &summary
)
{
   payload_present = false;
   quality_ok = false;
   fresh = false;
   summary = "ATAS shadow unavailable.";
   rejection_reason = ATAS_REJECT_NONE;
   freshness_state = ATAS_FRESHNESS_UNKNOWN;
   InitAtasRuntimePacket(packet);

   if(!base_environment_valid)
   {
      rejection_reason = ATAS_REJECT_BASE_ENVIRONMENT_UNAVAILABLE;
      summary = "Base MT5 environment invalid; ATAS shadow skipped.";
      return false;
   }

   string json = "";
   if(!AtasReadTextFileAll(AtasRuntimeContextPath(), json))
   {
      rejection_reason = ATAS_REJECT_MALFORMED_PAYLOAD;
      summary = "ATAS runtime context file unreadable.";
      return false;
   }
   payload_present = (StringLen(TrimString(json)) > 0);
   if(!payload_present)
   {
      rejection_reason = ATAS_REJECT_MALFORMED_PAYLOAD;
      summary = "ATAS runtime context payload is empty.";
      return false;
   }

   bool ok = true;
   ok = ok && ExtractJsonStringField(json, "schema_version", packet.schema_version);
   ok = ok && ExtractJsonStringField(json, "packet_id", packet.packet_id);
   string source_mode_text = "";
   ok = ok && ExtractJsonStringField(json, "source_mode", source_mode_text);
   packet.source_mode = AtasSourceModeFromText(source_mode_text);
   ok = ok && ExtractJsonStringField(json, "source_symbol", packet.source_symbol);
   ok = ok && ExtractJsonStringField(json, "execution_symbol", packet.execution_symbol);
   ok = ok && ExtractJsonStringField(json, "written_at", packet.event_time);
   packet.created_time = packet.event_time;
   ok = ok && ExtractJsonStringField(json, "fresh_until", packet.fresh_until);

   string packet_validity = "";
   string quality_text = "";
   bool suppression_active = false;
   ok = ok && ExtractJsonStringField(json, "packet_validity", packet_validity);
   ok = ok && ExtractJsonStringField(json, "quality_state", quality_text);
   ok = ok && ExtractJsonDoubleField(json, "confidence_ceiling", packet.packet_confidence);
   ExtractJsonBoolField(json, "suppression_active", suppression_active);

   if(!ExtractJsonStringField(json, "liquidity_sweep_state", packet.liquidity_sweep_state))
      packet.liquidity_sweep_state = "UNKNOWN";
   if(!ExtractJsonStringField(json, "absorption_state", packet.absorption_state))
      packet.absorption_state = "UNKNOWN";
   if(!ExtractJsonStringField(json, "delta_bias_state", packet.delta_bias_state))
      packet.delta_bias_state = "UNKNOWN";
   if(!ExtractJsonStringField(json, "imbalance_state", packet.imbalance_state))
      packet.imbalance_state = "UNKNOWN";
   if(!ExtractJsonStringField(json, "liquidity_stability_state", packet.liquidity_stability_state))
      packet.liquidity_stability_state = "UNKNOWN";
   if(!ExtractJsonStringField(json, "continuation_exhaustion_hint", packet.continuation_exhaustion_hint))
      packet.continuation_exhaustion_hint = "UNKNOWN";

   packet.source_platform = "ATAS_DIRECT_WRITE";
   packet.source_symbol_original = packet.source_symbol;
   packet.session_context = "";
   packet.data_quality_state = AtasQualityStateFromText(quality_text);
   packet.signal_stability_window_sec = ATAS_MAX_CONTEXT_AGE_SECONDS;
   packet.replay_flag = false;
   packet.market_state_class = "UNSPECIFIED";
   packet.ingestion_status = packet_validity;
   packet.overlay_enabled = true;
   packet.consumption_mode = ATAS_CONSUMPTION_SHADOW_ONLY;
   packet.source_reference_price = 0.0;
   packet.execution_reference_price = 0.0;
   packet.cross_instrument_basis_value = 0.0;
   packet.cross_instrument_translation_applied = false;
   packet.price_anchor_fields_suppressed = (AtasUpper(packet.source_symbol) != AtasUpper(packet.execution_symbol));
   packet.price_space_relation = packet.price_anchor_fields_suppressed ? "CROSS_INSTRUMENT" : "SAME_INSTRUMENT";
   InitAtasLevelEvidenceBundle(packet.level_evidence);
   packet.level_evidence.summary = "DIRECT_WRITE_NO_LEVEL_CANDIDATES";

   if(!ok)
   {
      rejection_reason = ATAS_REJECT_SCHEMA_INVALID;
      summary = "ATAS direct-write payload failed required schema checks.";
      return false;
   }

   if(packet.schema_version != ATAS_RUNTIME_CONTEXT_SCHEMA_VERSION)
   {
      rejection_reason = ATAS_REJECT_SCHEMA_INVALID;
      summary = "ATAS schema version mismatch for direct-write core contract.";
      return false;
   }

   if(packet.source_mode != ATAS_SOURCE_MODE_LIVE || packet.replay_flag)
   {
      rejection_reason = ATAS_REJECT_SOURCE_MODE_FORBIDDEN;
      summary = "ATAS source mode is forbidden for live shadow ingestion.";
      return false;
   }

   string exec_upper = AtasUpper(execution_symbol);
   if(AtasUpper(packet.execution_symbol) != exec_upper)
   {
      rejection_reason = ATAS_REJECT_SYMBOL_MISMATCH;
      summary = "ATAS execution symbol does not match MT5 execution symbol.";
      return false;
   }

   bool packet_valid = (AtasUpper(packet_validity) == "VALID");
   quality_ok =
      packet_valid &&
      !suppression_active &&
      ((packet.data_quality_state == ATAS_QUALITY_HIGH || packet.data_quality_state == ATAS_QUALITY_MEDIUM) &&
       packet.packet_confidence >= 0.35);
   if(!quality_ok)
   {
      rejection_reason = (packet_valid ? ATAS_REJECT_QUALITY_TOO_LOW : ATAS_REJECT_PACKET_INVALID);
      summary = packet_valid
         ? "ATAS packet quality below bounded minimum."
         : "ATAS packet marked invalid/suppressed by direct writer.";
      return false;
   }

   datetime now_ts = AtasFreshnessBaselineUtcNow();
   datetime written_ts = AtasParseTimestamp(packet.event_time);
   datetime fresh_until_ts = AtasParseTimestamp(packet.fresh_until);
   if(written_ts <= 0 || fresh_until_ts <= 0)
   {
      rejection_reason = ATAS_REJECT_SCHEMA_INVALID;
      summary = "ATAS temporal fields are malformed.";
      return false;
   }

   if(now_ts > fresh_until_ts)
   {
      freshness_state = ATAS_FRESHNESS_EXPIRED;
      rejection_reason = ATAS_REJECT_FRESHNESS_WINDOW_EXPIRED;
      summary = "ATAS freshness window expired.";
      return false;
   }

   int age_seconds = (int)(now_ts - written_ts);
   if(age_seconds > ATAS_MAX_CONTEXT_AGE_SECONDS)
   {
      freshness_state = ATAS_FRESHNESS_STALE;
      rejection_reason = ATAS_REJECT_PACKET_STALE;
      summary = "ATAS packet is stale for bounded direct-write intake.";
      return false;
   }

   freshness_state = ATAS_FRESHNESS_FRESH;
   fresh = true;

   packet.valid = true;
   summary = "ATAS direct-write packet accepted for bounded non-authoritative shadow attachment.";
   return true;
}

bool AtasAttachShadowRuntimeContext(
   const string execution_symbol,
   const bool base_environment_valid,
   bool &atas_available,
   bool &atas_shadow_attached,
   bool &atas_quality_ok,
   bool &atas_fresh,
   string &atas_acceptance_state,
   string &atas_rejection_reason,
   string &atas_consumption_mode,
   string &atas_summary,
   AtasMicrostructureOverlay &atas_shadow_overlay,
   AtasLevelEvidenceBundle &atas_level_evidence_shadow,
   TwinInfluenceTrace &atas_trace
)
{
   atas_available = false;
   atas_shadow_attached = false;
   atas_quality_ok = false;
   atas_fresh = false;
   atas_acceptance_state = "SHADOW_NOT_ATTACHED";
   atas_rejection_reason = "NONE";
   atas_consumption_mode = AtasConsumptionModeToText(ATAS_CONSUMPTION_SHADOW_ONLY);
   atas_summary = "ATAS shadow not evaluated.";

   InitAtasMicrostructureOverlay(atas_shadow_overlay);
   InitAtasLevelEvidenceBundle(atas_level_evidence_shadow);
   InitTwinInfluenceTrace(atas_trace);

   AtasRuntimePacket packet;
   AtasRejectionReason reject_reason = ATAS_REJECT_NONE;
   AtasFreshnessState freshness_state = ATAS_FRESHNESS_UNKNOWN;
   bool payload_present = false;
   string validation_summary = "";

   bool accepted = AtasLoadAndValidatePacket(
      execution_symbol,
      base_environment_valid,
      payload_present,
      packet,
      reject_reason,
      freshness_state,
      atas_quality_ok,
      atas_fresh,
      validation_summary
   );

   atas_available = payload_present;
   atas_trace.valid = true;
   atas_trace.base_environment_valid = base_environment_valid;
   atas_trace.base_environment_source = "MT5_RUNTIME_ENVIRONMENT";
   atas_trace.atas_consumption_mode = AtasConsumptionModeToText(ATAS_CONSUMPTION_SHADOW_ONLY);
   atas_trace.atas_overlay_weight_cap = ATAS_MAX_OVERLAY_WEIGHT;
   atas_trace.live_influence_applied = false;
   atas_trace.live_influence_blocked = true;
   atas_trace.rejection_reason = AtasRejectionReasonToText(reject_reason);

   if(accepted)
   {
      AtasBuildShadowOverlay(packet, atas_shadow_overlay);
      atas_level_evidence_shadow = packet.level_evidence;

      atas_shadow_attached = true;
      atas_acceptance_state = "SHADOW_ATTACHED";
      atas_rejection_reason = "NONE";
      atas_summary =
         "ATAS shadow attached | mode=SHADOW_ONLY" +
         " | source_platform=" + packet.source_platform +
         " | source_mode=" + AtasSourceModeToText(packet.source_mode) +
         " | quality=" + AtasQualityStateToText(packet.data_quality_state) +
         " | freshness=" + AtasFreshnessStateToText(freshness_state) +
         " | overlay_weight=" + DoubleToString(atas_shadow_overlay.overlay_weight, 3) +
         " | overlay_cap=" + DoubleToString(ATAS_MAX_OVERLAY_WEIGHT, 3) +
         " | level_candidates=" + IntegerToString(atas_level_evidence_shadow.candidate_count) +
         " | note=non_authoritative_non_consumed";

      atas_trace.atas_overlay_weight_applied = atas_shadow_overlay.overlay_weight;
      atas_trace.trace_note =
         "ATTACHED_SHADOW_ONLY | base=MT5_VALID" +
         " | live_influence=false" +
         " | confidence_amplification=forbidden" +
         " | level_authority=MT5_CANONICAL_ONLY" +
         " | validation=" + validation_summary;
   }
   else
   {
      atas_shadow_attached = false;
      atas_acceptance_state = "SHADOW_NOT_ATTACHED";
      atas_rejection_reason = AtasRejectionReasonToText(reject_reason);
      atas_summary =
         "ATAS shadow not attached | mode=SHADOW_ONLY" +
         " | reason=" + AtasRejectionReasonToText(reject_reason) +
         " | source_mode=" + AtasSourceModeToText(packet.source_mode) +
         " | quality=" + AtasQualityStateToText(packet.data_quality_state) +
         " | freshness=" + AtasFreshnessStateToText(freshness_state) +
         " | fallback=MT5_BASE_ONLY" +
         " | validation=" + validation_summary;

      atas_trace.atas_overlay_weight_applied = 0.0;
      atas_trace.trace_note =
         "SHADOW_WITHHELD | reason=" + AtasRejectionReasonToText(reject_reason) +
         " | base_environment=MT5_ONLY" +
         " | live_influence=false" +
         " | canonical_levels=MT5_ONLY";
   }

   AtasEmitRuntimeContextStatus(
      execution_symbol,
      base_environment_valid,
      atas_available,
      atas_shadow_attached,
      atas_quality_ok,
      atas_fresh,
      freshness_state,
      packet,
      atas_shadow_overlay,
      atas_level_evidence_shadow,
      atas_acceptance_state,
      reject_reason,
      atas_summary
   );

   return atas_shadow_attached;
}

bool AtasRefreshRuntimeContextStatusHeartbeat(
   const string execution_symbol,
   const bool base_environment_valid,
   string &heartbeat_acceptance_state,
   string &heartbeat_rejection_reason
)
{
   heartbeat_acceptance_state = "SHADOW_NOT_ATTACHED";
   heartbeat_rejection_reason = "NONE";

   bool payload_present = false;
   bool quality_ok = false;
   bool fresh = false;
   AtasRuntimePacket packet;
   AtasRejectionReason rejection_reason = ATAS_REJECT_NONE;
   AtasFreshnessState freshness_state = ATAS_FRESHNESS_UNKNOWN;
   string validation_summary = "";

   bool accepted = AtasLoadAndValidatePacket(
      execution_symbol,
      base_environment_valid,
      payload_present,
      packet,
      rejection_reason,
      freshness_state,
      quality_ok,
      fresh,
      validation_summary
   );

   AtasMicrostructureOverlay overlay;
   InitAtasMicrostructureOverlay(overlay);
   AtasLevelEvidenceBundle bundle;
   InitAtasLevelEvidenceBundle(bundle);

   if(accepted)
   {
      AtasBuildShadowOverlay(packet, overlay);
      bundle = packet.level_evidence;
      heartbeat_acceptance_state = "SHADOW_ATTACHED";
      heartbeat_rejection_reason = "NONE";
      validation_summary =
         "ATAS status heartbeat refresh accepted latest packet | validation=" + validation_summary;
   }
   else
   {
      heartbeat_acceptance_state = "SHADOW_NOT_ATTACHED";
      heartbeat_rejection_reason = AtasRejectionReasonToText(rejection_reason);
      validation_summary =
         "ATAS status heartbeat refresh withheld | reason=" + heartbeat_rejection_reason +
         " | validation=" + validation_summary;
   }

   AtasEmitRuntimeContextStatus(
      execution_symbol,
      base_environment_valid,
      payload_present,
      accepted,
      quality_ok,
      fresh,
      freshness_state,
      packet,
      overlay,
      bundle,
      heartbeat_acceptance_state,
      rejection_reason,
      validation_summary
   );

   return accepted;
}

#endif
