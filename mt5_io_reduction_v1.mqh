#ifndef MT5_IO_REDUCTION_V1_MQH
#define MT5_IO_REDUCTION_V1_MQH

//---------------------------------------------------------
// MT5_IO_REDUCTION_V1
// Telemetry/file-output IO reduction only.
// No trading, risk, execution, strategy, score, V1, IRREW,
// PCEA, cohort, CRR, DSN, or HIGH_CONVICTION authority.
//---------------------------------------------------------

#define MT5_IO_REDUCTION_STATUS_PATH "AI\\mt5_io_reduction_status.json"
#define MT5_IO_PJ_BUFFER_CAPACITY 200

input bool EnableMT5IOReductionV1        = true;
input bool EnablePJBuffer                = true;
input int  PJFlushIntervalBars           = 5;
input int  PJBufferMaxRecords            = 20;
input bool EnableGovernanceDirtyFlag     = true;
input int  RuntimeGovernanceHeartbeatSeconds = 300;
input bool EnableTrendContGate           = true;
input int  TrendContStatusIntervalBars   = 5;
input bool EnableOLSummaryRateLimit      = true;
input int  OLSummaryWriteEveryNRecords   = 5;
input int  OLSummaryIntervalBars         = 10;

long     g_mt5io_pj_buffered_records_total        = 0;
long     g_mt5io_pj_flushed_records_total         = 0;
long     g_mt5io_pj_immediate_flush_count         = 0;
long     g_mt5io_pj_batched_flush_count           = 0;
long     g_mt5io_pj_direct_write_count            = 0;
long     g_mt5io_pj_direct_write_avoided_estimate = 0;
long     g_mt5io_fileopen_calls_actual_after      = 0;
long     g_mt5io_filewrite_calls_actual_after     = 0;
long     g_mt5io_io_reduction_error_count         = 0;
int      g_mt5io_max_buffer_depth_observed        = 0;
string   g_mt5io_last_flush_reason                = "";
datetime g_mt5io_last_flush_time                  = 0;

long     g_mt5io_governance_write_count           = 0;
long     g_mt5io_governance_deferred_count        = 0;
long     g_mt5io_governance_heartbeat_count       = 0;
long     g_mt5io_trendcont_write_count            = 0;
long     g_mt5io_trendcont_deferred_count         = 0;
long     g_mt5io_ol_summary_write_count           = 0;
long     g_mt5io_ol_summary_deferred_count        = 0;
datetime g_mt5io_last_ol_summary_write_time       = 0;

bool MT5IO_MasterEnabled()
{
   return EnableMT5IOReductionV1;
}

bool MT5IO_PJBufferActive()
{
   return (EnableMT5IOReductionV1 && EnablePJBuffer);
}

int MT5IO_PJFlushIntervalBars()
{
   if(PJFlushIntervalBars < 1)
      return 1;
   return PJFlushIntervalBars;
}

int MT5IO_PJBufferCapacity()
{
   int n = PJBufferMaxRecords;
   if(n < 1)
      n = 1;
   if(n > MT5_IO_PJ_BUFFER_CAPACITY)
      n = MT5_IO_PJ_BUFFER_CAPACITY;
   return n;
}

int MT5IO_RuntimeGovernanceHeartbeatSeconds()
{
   if(RuntimeGovernanceHeartbeatSeconds < 30)
      return 30;
   return RuntimeGovernanceHeartbeatSeconds;
}

int MT5IO_TrendContStatusIntervalBars()
{
   if(TrendContStatusIntervalBars < 1)
      return 1;
   return TrendContStatusIntervalBars;
}

int MT5IO_OLSummaryWriteEveryNRecords()
{
   if(OLSummaryWriteEveryNRecords < 1)
      return 1;
   return OLSummaryWriteEveryNRecords;
}

int MT5IO_OLSummaryIntervalBars()
{
   if(OLSummaryIntervalBars < 1)
      return 1;
   return OLSummaryIntervalBars;
}

void MT5IO_RecordFileOpenCall()
{
   g_mt5io_fileopen_calls_actual_after++;
}

void MT5IO_RecordFileWriteCall()
{
   g_mt5io_filewrite_calls_actual_after++;
}

void MT5IO_RecordError(const string reason)
{
   g_mt5io_io_reduction_error_count++;
   g_mt5io_last_flush_reason = reason;
}

#endif
