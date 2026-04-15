#ifndef __STORAGE_RESET_PRE_STRATEGY_MEMORY_V1_MQH__
#define __STORAGE_RESET_PRE_STRATEGY_MEMORY_V1_MQH__

#include "core_logger.mqh"

#define STORAGE_RESET_ARCHIVE_DIR "AI\\archive_pre_strategy_memory_v1"
#define STORAGE_RESET_FLAG_PATH   "AI\\archive_pre_strategy_memory_v1\\_reset_done.flag"

// Conservative, best-effort file copy for MQL5 Files folder.
bool StorageReset_CopyFile(string srcRelPath, string dstRelPath)
{
   int inH = FileOpen(srcRelPath, FILE_READ | FILE_BIN);
   if(inH == INVALID_HANDLE)
      return false;

   FolderCreate("AI");
   int outH = FileOpen(dstRelPath, FILE_WRITE | FILE_BIN);
   if(outH == INVALID_HANDLE)
   {
      FileClose(inH);
      return false;
   }

   uchar buf[];
   ArrayResize(buf, 4096);

   while(!FileIsEnding(inH))
   {
      int n = (int)FileReadArray(inH, buf, 0, ArraySize(buf));
      if(n <= 0) break;
      FileWriteArray(outH, buf, 0, n);
   }

   FileClose(inH);
   FileClose(outH);
   return true;
}

bool StorageReset_WriteText(string relPath, string txt)
{
   FolderCreate("AI");
   int h = FileOpen(relPath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, txt);
   FileClose(h);
   return true;
}

bool StorageReset_FileExists(string relPath)
{
   return FileIsExist(relPath);
}

void StorageReset_ArchiveAndResetOne(string relPath, string resetContent, string &log)
{
   if(!StorageReset_FileExists(relPath))
      return;

   FolderCreate("AI");
   FolderCreate(STORAGE_RESET_ARCHIVE_DIR);

   string dst = STORAGE_RESET_ARCHIVE_DIR + "\\" + relPath;
   // relPath may already include "AI\\"
   string rel = relPath;
   StringReplace(rel, "AI\\", "");
   dst = STORAGE_RESET_ARCHIVE_DIR + "\\" + rel;

   bool copied = StorageReset_CopyFile(relPath, dst);
   if(copied)
   {
      FileDelete(relPath);
      if(StringLen(resetContent) > 0)
         StorageReset_WriteText(relPath, resetContent);

      log += "Archived+Reset: " + relPath + " -> " + dst + "\n";
   }
   else
   {
      log += "ArchiveSkip(copy failed): " + relPath + "\n";
   }
}

// One-time storage reset to separate legacy operational state from Strategy Confidence Memory v1 baseline.
// Passive: does not change runtime logic; only files under MQL5/Files/AI.
bool StorageReset_PreStrategyMemoryV1_RunOnce(string &logMessage)
{
   logMessage = "";

   FolderCreate("AI");
   FolderCreate(STORAGE_RESET_ARCHIVE_DIR);

   if(StorageReset_FileExists(STORAGE_RESET_FLAG_PATH))
      return false;

   // Archive known legacy operational/state files (best-effort) then start clean baselines.
   StorageReset_ArchiveAndResetOne("AI\\ai_performance_journal.jsonl", "", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_last_evolution_raw.txt", "", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_last_recorded_feedback_deal.txt", "0", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_trade_feedback.json", "", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\council_feedback.json", "", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\council_memory.txt", "", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\council_report.txt", "", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_strategy_memory.json", "{}", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_evolution_state.json", "{}", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_governor_state.json", "{}", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_rollback_state.json", "{}", logMessage);

   // Secondary files (best-effort; safe if absent)
   StorageReset_ArchiveAndResetOne("AI\\ai_last_recorded_feedback_deal.txt", "0", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_last_recorded_feedback_order.txt", "0", logMessage);
   StorageReset_ArchiveAndResetOne("AI\\ai_last_recorded_feedback_position.txt", "0", logMessage);

   // Mark reset complete.
   StorageReset_WriteText(STORAGE_RESET_FLAG_PATH, TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS));
   logMessage = "Storage reset baseline created (pre Strategy Memory v1)\n" + logMessage;
   return true;
}

#endif