param(
    [double]$IntervalSec = 5.0,
    [int]$MaxCycles = 0,
    [int]$CommandTimeoutSec = 90,
    [int]$MaxEvents = 5000
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$venvPython = Join-Path $scriptDir ".venv\Scripts\python.exe"
$pythonExe = if(Test-Path $venvPython) { $venvPython } else { "python" }

$args = @(
    "tools\atas_live_propagation_runner.py",
    "--interval-sec", "$IntervalSec",
    "--max-cycles", "$MaxCycles",
    "--command-timeout-sec", "$CommandTimeoutSec",
    "--max-events", "$MaxEvents"
)

$proc = Start-Process -FilePath $pythonExe -ArgumentList $args -WorkingDirectory $scriptDir -PassThru
Write-Host "[ATAS RUNNER] started"
Write-Host "[ATAS RUNNER] pid=$($proc.Id)"
Write-Host "[ATAS RUNNER] interval_sec=$IntervalSec max_cycles=$MaxCycles"
Write-Host "[ATAS RUNNER] status=MQL5/Files/AI/atas_live_capture/atas_propagation_runner_status.json"
