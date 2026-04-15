
#ifndef __CORE_LOGGER_MQH__
#define __CORE_LOGGER_MQH__

string LOG_PREFIX = "[AI-EA] ";

void LogInfo(string message)
{
   Print(LOG_PREFIX + "[INFO] " + message);
}

void LogWarn(string message)
{
   Print(LOG_PREFIX + "[WARN] " + message);
}

void LogError(string message)
{
   Print(LOG_PREFIX + "[ERROR] " + message);
}

void LogDecision(string title, string reason)
{
   Print(LOG_PREFIX + "[DECISION] " + title + " | " + reason);
}

void LogSeparator()
{
   Print("==================================================");
}

// يطبع الرسالة مرة واحدة فقط إذا لم تتغير
void LogStateOnce(string message)
{
   static string last_message = "";
   if(message != last_message)
   {
      LogInfo(message);
      last_message = message;
   }
}

#endif

