#ifndef __PLAN_AUTO_APPLY_MQH__
#define __PLAN_AUTO_APPLY_MQH__

#include "plan_validator.mqh"
#include "config_loader.mqh"
#include "performance_memory.mqh"

// Rollback bridge forward declarations.
string RollbackStatePath();
bool StartRollbackMonitoring(
   string relativePath,
   string candidatePlanId,
   int baselineClosedTrades,
   int minTradesBeforeJudgment,
   double minWinRate,
   int maxConsecutiveLosses,
   double minAvgProfitPerTrade,
   string &logMessage
);

bool SaveTextFileAuto(string relativePath, string text)
{
   int h = FileOpen(relativePath, FILE_WRITE | FILE_TXT | FILE_ANSI);
   if(h == INVALID_HANDLE)
      return false;

   FileWriteString(h, text);
   FileClose(h);
   return true;
}

bool CopyFileText(string fromPath, string toPath)
{
   string txt = "";
   if(!LoadTextFile(fromPath, txt))
      return false;

   return SaveTextFileAuto(toPath, txt);
}

string NormalizeAutoApplyText(string s)
{
   s = TrimString(s);
   return s;
}

bool ExtractPlanIdFromJsonText(string jsonText, string &planId)
{
   planId = "";
   return ExtractJsonStringField(jsonText, "plan_id", planId);
}

bool AutoApplyPlanProposal(
   string currentPlanPath,
   string nextProposalPath,
   string backupPlanPath,
   string &logMessage,
   bool armRollbackOnSuccessfulApply = true,
   ulong rollbackMagic = 0,
   int rollbackMinTradesBeforeJudgment = 6,
   double rollbackMinWinRate = 35.0,
   int rollbackMaxConsecutiveLosses = 3,
   double rollbackMinAvgProfitPerTrade = -1.0
)
{
   logMessage = "";

   //------------------------------------------------------
   // Load current plan text
   //------------------------------------------------------
   string currentJson = "";
   if(!LoadTextFile(currentPlanPath, currentJson))
   {
      logMessage = "Auto-apply rejected: failed to load current plan";
      return false;
   }

   currentJson = NormalizeAutoApplyText(currentJson);

   if(StringLen(currentJson) < 20)
   {
      logMessage = "Auto-apply rejected: current plan is empty or invalid";
      return false;
   }

   //------------------------------------------------------
   // Load proposal text
   //------------------------------------------------------
   string proposalJson = "";
   if(!LoadTextFile(nextProposalPath, proposalJson))
   {
      logMessage = "No proposal file found";
      return false;
   }

   proposalJson = NormalizeAutoApplyText(proposalJson);

   if(StringLen(proposalJson) < 50)
   {
      logMessage = "Proposal rejected: proposal is empty or too short";
      return false;
   }

   //------------------------------------------------------
   // Reject identical content
   //------------------------------------------------------
   if(proposalJson == currentJson)
   {
      string samePlanId = "";
      ExtractPlanIdFromJsonText(proposalJson, samePlanId);

      logMessage =
         "Proposal skipped: identical to current plan" +
         (StringLen(samePlanId) > 0 ? " | plan_id=" + samePlanId : "");

      return false;
   }

   //------------------------------------------------------
   // Validate JSON schema
   //------------------------------------------------------
   PlanValidationResult vr;
   if(!ValidatePlanJsonBasic(proposalJson, vr))
   {
      logMessage = "Proposal rejected: " + vr.reason;
      return false;
   }

   //------------------------------------------------------
   // Validate loader compatibility by parsing proposal plan
   //------------------------------------------------------
   RuntimePlan proposedPlan;
   if(!LoadRuntimePlanFromJson(nextProposalPath, proposedPlan))
   {
      logMessage = "Proposal rejected: loader failed to parse proposed plan";
      return false;
   }

   if(StringLen(proposedPlan.plan_id) <= 0)
   {
      logMessage = "Proposal rejected: parsed plan_id is empty";
      return false;
   }

   //------------------------------------------------------
   // Parse current plan too
   //------------------------------------------------------
   RuntimePlan currentPlan;
   if(!LoadRuntimePlanFromJson(currentPlanPath, currentPlan))
   {
      logMessage = "Proposal rejected: loader failed to parse current plan";
      return false;
   }

   //------------------------------------------------------
   // Reject same plan_id with identical or stale proposal logic
   //------------------------------------------------------
   if(StringLen(currentPlan.plan_id) > 0 &&
      currentPlan.plan_id == proposedPlan.plan_id)
   {
      logMessage =
         "Proposal skipped: proposed plan_id matches current plan_id" +
         " | plan_id=" + proposedPlan.plan_id;

      return false;
   }

   //------------------------------------------------------
   // Backup current plan
   //------------------------------------------------------
   if(!CopyFileText(currentPlanPath, backupPlanPath))
   {
      logMessage = "Failed to backup current plan";
      return false;
   }

   //------------------------------------------------------
   // Apply proposal
   //------------------------------------------------------
   if(!SaveTextFileAuto(currentPlanPath, proposalJson))
   {
      logMessage = "Failed to apply new plan";
      return false;
   }

   //------------------------------------------------------
   // Success log
   //------------------------------------------------------
   logMessage =
      "New AI plan applied successfully"
      " | old_plan_id=" + currentPlan.plan_id +
      " | new_plan_id=" + proposedPlan.plan_id +
      " | plan_mode=" + proposedPlan.plan_mode +
      " | decision_engine_mode=" + proposedPlan.decision_engine_mode +
      " | experiment_family=" + proposedPlan.experiment_family;

   // Structural-readiness rollback bridge:
   // Attach arming only at true plan-apply lifecycle location.
   // This does not create live activation by itself; runtime still needs a caller.
   string rollbackBridgeLog = "";
   if(armRollbackOnSuccessfulApply)
   {
      if(rollbackMagic == 0)
      {
         rollbackBridgeLog = "rollback_bridge=present_but_not_armed_magic_missing";
      }
      else
      {
         PerformanceSnapshot perf;
         if(!BuildPerformanceSnapshot(rollbackMagic, perf))
         {
            rollbackBridgeLog = "rollback_bridge=present_but_not_armed_baseline_unavailable";
         }
         else
         {
            string startRollbackLog = "";
            if(StartRollbackMonitoring(
                  RollbackStatePath(),
                  proposedPlan.plan_id,
                  perf.closed_trades,
                  rollbackMinTradesBeforeJudgment,
                  rollbackMinWinRate,
                  rollbackMaxConsecutiveLosses,
                  rollbackMinAvgProfitPerTrade,
                  startRollbackLog))
            {
               rollbackBridgeLog =
                  "rollback_bridge=armed"
                  " | baseline_closed_trades=" + IntegerToString(perf.closed_trades) +
                  " | " + startRollbackLog;
            }
            else
            {
               rollbackBridgeLog = "rollback_bridge=present_but_not_armed_start_failed | reason=" + startRollbackLog;
            }
         }
      }
   }
   else
   {
      rollbackBridgeLog = "rollback_bridge=disabled_for_apply_invocation";
   }

   if(StringLen(rollbackBridgeLog) > 0)
      logMessage += " | " + rollbackBridgeLog;

   return true;
}

#endif
