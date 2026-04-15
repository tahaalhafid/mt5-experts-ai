param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$venvPython = Join-Path $scriptDir ".venv\Scripts\python.exe"
$pythonExe = if(Test-Path $venvPython) { $venvPython } else { "python" }

Push-Location $scriptDir
try {
    & $pythonExe "tools\atas_live_propagation_runner.py" --stop-only | Out-Host
}
finally {
    Pop-Location
}

$terminalRoot = Resolve-Path (Join-Path $scriptDir "..\..\..\..")
$statusPath = Join-Path $terminalRoot "MQL5\Files\AI\atas_live_capture\atas_propagation_runner_status.json"

if(!(Test-Path $statusPath))
{
    Write-Host "[ATAS RUNNER] stop signal sent; status file not found yet."
    return
}

try
{
    $status = Get-Content -LiteralPath $statusPath -Raw | ConvertFrom-Json
    if($null -eq $status.pid)
    {
        Write-Host "[ATAS RUNNER] stop signal sent; PID unavailable in status."
        return
    }

    $runnerPid = [int]$status.pid
    $process = Get-Process -Id $runnerPid -ErrorAction SilentlyContinue
    if($null -eq $process)
    {
        Write-Host "[ATAS RUNNER] process already stopped."
        return
    }

    if($Force)
    {
        Stop-Process -Id $runnerPid -Force -ErrorAction SilentlyContinue
        Write-Host "[ATAS RUNNER] process force-stopped pid=$runnerPid"
        return
    }

    Write-Host "[ATAS RUNNER] awaiting graceful shutdown pid=$runnerPid"
}
catch
{
    Write-Host "[ATAS RUNNER] stop signal sent; status parse failed."
}
