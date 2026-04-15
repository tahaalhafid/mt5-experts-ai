param(
    [int]$Cycles = 6,
    [double]$CycleIntervalSec = 8,
    [switch]$RefreshMonitorOnce = $true
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$venvPython = Join-Path $scriptDir ".venv\Scripts\python.exe"
$pythonExe = if(Test-Path $venvPython) { $venvPython } else { "python" }

$args = @(
    "tools\atas_periodic_propagation_validation.py",
    "--cycles", "$Cycles",
    "--cycle-interval-sec", "$CycleIntervalSec"
)

if($RefreshMonitorOnce){
    $args += "--refresh-monitor-once"
}

Push-Location $scriptDir
try {
    & $pythonExe @args
}
finally {
    Pop-Location
}

