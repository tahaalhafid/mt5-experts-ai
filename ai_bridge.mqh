#ifndef __AI_BRIDGE_MQH__
#define __AI_BRIDGE_MQH__

#include "config_loader.mqh"
#include "core_market_data.mqh"

struct AIDecision
{
   bool   valid;
   string action;     // BUY / SELL / WAIT
   string reason;
   int    confidence;
   string raw_response;
};

//---------------------------------------------------------
// Basic string helpers
//---------------------------------------------------------
string TrimStringEx(string s)
{
   int start = 0;
   int end   = StringLen(s) - 1;

   while(start <= end)
   {
      ushort c = StringGetCharacter(s, start);
      if(c == ' ' || c == '\t' || c == '\r' || c == '\n')
         start++;
      else
         break;
   }

   while(end >= start)
   {
      ushort c = StringGetCharacter(s, end);
      if(c == ' ' || c == '\t' || c == '\r' || c == '\n')
         end--;
      else
         break;
   }

   if(end < start)
      return "";

   return StringSubstr(s, start, end - start + 1);
}

string JsonEscape(string src)
{
   string out = "";

   for(int i = 0; i < StringLen(src); i++)
   {
      string ch = StringSubstr(src, i, 1);
      ushort c  = StringGetCharacter(src, i);

      if(c == '\\')      out += "\\\\";
      else if(c == '"')  out += "\\\"";
      else if(c == '\n') out += "\\n";
      else if(c == '\r') out += "\\r";
      else if(c == '\t') out += "\\t";
      else               out += ch;
   }

   return out;
}

string JsonUnescape(string src)
{
   string out = src;
   StringReplace(out, "\\n", "\n");
   StringReplace(out, "\\r", "\r");
   StringReplace(out, "\\t", "\t");
   StringReplace(out, "\\\"", "\"");
   StringReplace(out, "\\\\", "\\");
   return out;
}

string StripMarkdownJsonFence(string s)
{
   string out = TrimStringEx(s);

   StringReplace(out, "```json", "");
   StringReplace(out, "```JSON", "");
   StringReplace(out, "```", "");

   out = TrimStringEx(out);
   return out;
}

//---------------------------------------------------------
// Prompt builders
//---------------------------------------------------------
string BuildAISystemPrompt(PersonalityProfile &personality)
{
   string prompt =
      "You are the trading brain for an MT5 EA. "
      "You must respect the personality and red-line behavior below. "
      "Return only strict JSON with fields action, reason, confidence. "
      "Allowed actions: BUY, SELL, WAIT. "
      "Do not wrap your answer in markdown code fences. "
      "Do not add commentary before or after the JSON. "
      "Personality profile: " + personality.raw_json;

   return prompt;
}

string BuildAIUserPrompt(RuntimePlan &plan, TimeframeSnapshot &m1, TimeframeSnapshot &m5)
{
   string text = "";

   text += "Current plan id: " + plan.plan_id + "\n";
   text += "Main timeframe: " + plan.main_timeframe + "\n";
   text += "Confirmation timeframe: " + plan.confirmation_timeframe + "\n";
   text += "Main trigger: " + plan.main_trigger_name + "\n";

   text += "M1 OHLC: ";
   text += "O=" + DoubleToString(m1.bar1.open, 2) + ", ";
   text += "H=" + DoubleToString(m1.bar1.high, 2) + ", ";
   text += "L=" + DoubleToString(m1.bar1.low, 2) + ", ";
   text += "C=" + DoubleToString(m1.bar1.close, 2) + "\n";

   text += "M5 OHLC: ";
   text += "O=" + DoubleToString(m5.bar1.open, 2) + ", ";
   text += "H=" + DoubleToString(m5.bar1.high, 2) + ", ";
   text += "L=" + DoubleToString(m5.bar1.low, 2) + ", ";
   text += "C=" + DoubleToString(m5.bar1.close, 2) + "\n";

   text += "Current spread points: " + DoubleToString(m1.spread_points, 2) + "\n";

   text += "Decide whether the EA should BUY, SELL, or WAIT right now. "
           "Return only JSON like: "
           "{\"action\":\"BUY\",\"reason\":\"...\",\"confidence\":78}";

   return text;
}

//---------------------------------------------------------
// AI runtime readiness
//---------------------------------------------------------
bool AIIsReady(AISecrets &cfg)
{
   return (cfg.ai_enabled &&
           StringLen(cfg.api_key) > 20 &&
           StringLen(cfg.model) > 0 &&
           StringLen(cfg.base_url) > 0);
}

//---------------------------------------------------------
// HTTP call
//---------------------------------------------------------
bool CallOpenAIChat(
   AISecrets &cfg,
   string systemPrompt,
   string userPrompt,
   string &responseText,
   string &errorText
)
{
   responseText = "";
   errorText = "";

   string body =
      "{"
      "\"model\":\"" + JsonEscape(cfg.model) + "\","
      "\"messages\":["
         "{\"role\":\"system\",\"content\":\"" + JsonEscape(systemPrompt) + "\"},"
         "{\"role\":\"user\",\"content\":\"" + JsonEscape(userPrompt) + "\"}"
      "],"
      "\"temperature\":0.2"
      "}";

   char postData[];
   char result[];
   string resultHeaders;

   StringToCharArray(body, postData, 0, StringLen(body));

   string headers =
      "Content-Type: application/json\r\n"
      "Authorization: Bearer " + cfg.api_key + "\r\n";

   ResetLastError();
   int httpCode = WebRequest(
      "POST",
      cfg.base_url,
      headers,
      cfg.timeout_seconds * 1000,
      postData,
      result,
      resultHeaders
   );

   if(httpCode == -1)
   {
      errorText = "WebRequest failed. LastError=" + IntegerToString(GetLastError());
      return false;
   }

   responseText = CharArrayToString(result, 0, -1);

   if(httpCode != 200)
   {
      errorText = "HTTP code=" + IntegerToString(httpCode) + " | body=" + responseText;
      return false;
   }

   return true;
}

//---------------------------------------------------------
// Extract assistant content from OpenAI chat response
//---------------------------------------------------------
bool ExtractAssistantContentFromChatResponse(string rawResponse, string &assistantContent)
{
   assistantContent = "";

   int p = StringFind(rawResponse, "\"content\":");
   if(p < 0)
      return false;

   p = StringFind(rawResponse, "\"", p + StringLen("\"content\":"));
   if(p < 0)
      return false;

   int e = p + 1;
   while(true)
   {
      e = StringFind(rawResponse, "\"", e);
      if(e < 0)
         return false;

      if(StringGetCharacter(rawResponse, e - 1) != '\\')
         break;

      e++;
   }

   assistantContent = StringSubstr(rawResponse, p + 1, e - p - 1);
   assistantContent = JsonUnescape(assistantContent);
   assistantContent = StripMarkdownJsonFence(assistantContent);

   return (StringLen(assistantContent) > 0);
}

//---------------------------------------------------------
// Main AI decision request
//---------------------------------------------------------
bool RequestAIDecision(
   AISecrets &cfg,
   PersonalityProfile &personality,
   RuntimePlan &plan,
   TimeframeSnapshot &m1,
   TimeframeSnapshot &m5,
   AIDecision &decision
)
{
   decision.valid = false;
   decision.action = "WAIT";
   decision.reason = "AI inactive";
   decision.confidence = 0;
   decision.raw_response = "";

   if(!AIIsReady(cfg))
   {
      decision.reason = "AI not ready";
      return false;
   }

   string systemPrompt = BuildAISystemPrompt(personality);
   string userPrompt   = BuildAIUserPrompt(plan, m1, m5);

   string rawApiResponse = "";
   string err = "";

   if(!CallOpenAIChat(cfg, systemPrompt, userPrompt, rawApiResponse, err))
   {
      decision.reason = err;
      decision.raw_response = rawApiResponse;
      return false;
   }

   decision.raw_response = rawApiResponse;

   string assistantJson = "";
   if(!ExtractAssistantContentFromChatResponse(rawApiResponse, assistantJson))
   {
      decision.reason = "Failed to extract assistant content";
      return false;
   }

   assistantJson = StripMarkdownJsonFence(assistantJson);

   string action = "";
   string reason = "";
   int confidence = 0;

   if(!ExtractJsonStringField(assistantJson, "action", action))
      action = "WAIT";

   if(!ExtractJsonStringField(assistantJson, "reason", reason))
      reason = "No reason";

   if(!ExtractJsonIntField(assistantJson, "confidence", confidence))
      confidence = 0;

   decision.valid = true;
   decision.action = action;
   decision.reason = reason;
   decision.confidence = confidence;
   decision.raw_response = assistantJson;

   return true;
}

#endif
