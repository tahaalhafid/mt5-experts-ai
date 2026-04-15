param(
  [int]$Iterations = 0,
  [double]$IntervalSec = 2.0,
  [string]$TerminalRoot = "",
  [string]$OutputDir = "",
  [int]$MaxEvents = 2000
)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = "python"

$cmd = @(
  "$scriptRoot\\tools\\atas_live_capture_monitor.py",
  "--iterations", "$Iterations",
  "--interval-sec", "$IntervalSec",
  "--max-events", "$MaxEvents"
)

if($TerminalRoot -ne ""){
  $cmd += @("--terminal-root", $TerminalRoot)
}
if($OutputDir -ne ""){
  $cmd += @("--output-dir", $OutputDir)
}

Write-Host "[ATAS CAPTURE] Starting bounded live capture monitor..."
Write-Host "[ATAS CAPTURE] Command: $python $($cmd -join ' ')"
& $python @cmd

