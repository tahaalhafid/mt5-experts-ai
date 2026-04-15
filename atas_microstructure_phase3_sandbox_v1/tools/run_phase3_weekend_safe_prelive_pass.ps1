param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("MARKET_CLOSED", "LIVE_WINDOW")]
    [string]$MarketState = "MARKET_CLOSED",
    [Parameter(Mandatory = $false)]
    [int]$Cycles = 5,
    [Parameter(Mandatory = $false)]
    [int]$IntervalSeconds = 1
)

$ErrorActionPreference = "Stop"

function Get-UtcNowIso {
    return [DateTime]::UtcNow.ToString("o")
}

if ($Cycles -lt 1) {
    Write-Error "Cycles must be >= 1"
    exit 1
}

$toolDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$phase3Root = Resolve-Path (Join-Path $toolDir "..")
$aiRoot = Resolve-Path (Join-Path $phase3Root "..")
$terminalRoot = Resolve-Path (Join-Path $aiRoot "..\\..\\..")
$filesAi = Join-Path $terminalRoot "MQL5\\Files\\AI"
$outputDir = Join-Path $filesAi "atas_micro_phase3_candidate"
$statusPath = Join-Path $outputDir "phase3_weekend_safe_tool_readiness_latest.json"
$statusStreamPath = Join-Path $outputDir "phase3_weekend_safe_tool_readiness_stream.jsonl"

if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$pipelineScript = Join-Path $toolDir "run_phase3_candidate_pipeline.ps1"
$refinementScript = Join-Path $toolDir "run_phase3_1_refinement_cycles.ps1"
$comparisonScript = Join-Path $toolDir "build_phase3_closure_before_after_comparison.py"
$packBuilderScript = Join-Path $toolDir "build_phase3_weekend_safe_prelive_pack.py"

$toolChecks = @{}
$scriptChecks = @()
$executionSteps = @()
$overallResult = "PASS"
$fatalError = ""

function Add-StepResult {
    param(
        [string]$StepId,
        [string]$Command,
        [string]$Status,
        [int]$ExitCode,
        [string]$StartedAtUtc,
        [string]$FinishedAtUtc,
        [string]$Message
    )
    $script:executionSteps += [ordered]@{
        step_id = $StepId
        command = $Command
        status = $Status
        exit_code = $ExitCode
        started_at_utc = $StartedAtUtc
        finished_at_utc = $FinishedAtUtc
        message = $Message
    }
}

function Invoke-ExternalStep {
    param(
        [string]$StepId,
        [string]$Command,
        [scriptblock]$Action
    )

    $started = Get-UtcNowIso
    $status = "PASS"
    $exitCode = 0
    $message = ""
    try {
        & $Action
        if ($LASTEXITCODE -ne 0) {
            $exitCode = [int]$LASTEXITCODE
            throw "Command exited with code $exitCode"
        }
    }
    catch {
        if ($exitCode -eq 0) {
            if ($LASTEXITCODE -is [int] -and $LASTEXITCODE -ne 0) {
                $exitCode = [int]$LASTEXITCODE
            }
            else {
                $exitCode = 1
            }
        }
        $status = "FAIL"
        $message = $_.Exception.Message
    }
    $finished = Get-UtcNowIso
    Add-StepResult -StepId $StepId -Command $Command -Status $status -ExitCode $exitCode -StartedAtUtc $started -FinishedAtUtc $finished -Message $message
    if ($status -eq "FAIL") {
        throw "Step $StepId failed: $message"
    }
}

try {
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue
    $dotnetCmd = Get-Command dotnet -ErrorAction SilentlyContinue
    $powershellCmd = Get-Command powershell -ErrorAction SilentlyContinue

    $toolChecks.python = [ordered]@{
        available = $null -ne $pythonCmd
        version = if ($null -ne $pythonCmd) { ((& python --version) 2>&1 | Out-String).Trim() } else { "" }
    }
    $toolChecks.dotnet = [ordered]@{
        available = $null -ne $dotnetCmd
        version = if ($null -ne $dotnetCmd) { ((& dotnet --version) 2>&1 | Out-String).Trim() } else { "" }
    }
    $toolChecks.powershell = [ordered]@{
        available = $null -ne $powershellCmd
        version = if ($null -ne $powershellCmd) { $PSVersionTable.PSVersion.ToString() } else { "" }
    }

    $scriptChecks += [ordered]@{ name = "run_phase3_candidate_pipeline.ps1"; path = $pipelineScript; exists = (Test-Path $pipelineScript) }
    $scriptChecks += [ordered]@{ name = "run_phase3_1_refinement_cycles.ps1"; path = $refinementScript; exists = (Test-Path $refinementScript) }
    $scriptChecks += [ordered]@{ name = "build_phase3_closure_before_after_comparison.py"; path = $comparisonScript; exists = (Test-Path $comparisonScript) }
    $scriptChecks += [ordered]@{ name = "build_phase3_weekend_safe_prelive_pack.py"; path = $packBuilderScript; exists = (Test-Path $packBuilderScript) }

    if (-not $toolChecks.python.available) {
        throw "python is required but not available"
    }
    if (-not $toolChecks.dotnet.available) {
        throw "dotnet is required for live-window tooling readiness but not available"
    }
    if ($scriptChecks | Where-Object { -not $_.exists }) {
        throw "One or more required scripts are missing"
    }

    Set-Location $aiRoot

    Invoke-ExternalStep `
        -StepId "S1_PHASE3_PIPELINE" `
        -Command "powershell -ExecutionPolicy Bypass -File .\\atas_microstructure_phase3_sandbox_v1\\tools\\run_phase3_candidate_pipeline.ps1" `
        -Action { powershell -ExecutionPolicy Bypass -File $pipelineScript }

    Invoke-ExternalStep `
        -StepId "S2_PHASE3_REFINEMENT_CYCLES" `
        -Command "powershell -ExecutionPolicy Bypass -File .\\atas_microstructure_phase3_sandbox_v1\\tools\\run_phase3_1_refinement_cycles.ps1 -Cycles $Cycles -IntervalSeconds $IntervalSeconds" `
        -Action { powershell -ExecutionPolicy Bypass -File $refinementScript -Cycles $Cycles -IntervalSeconds $IntervalSeconds }

    Invoke-ExternalStep `
        -StepId "S3_PHASE3_CLOSURE_COMPARISON" `
        -Command "python .\\atas_microstructure_phase3_sandbox_v1\\tools\\build_phase3_closure_before_after_comparison.py --output-dir .\\..\\..\\Files\\AI\\atas_micro_phase3_candidate" `
        -Action { python $comparisonScript --output-dir $outputDir }

    Invoke-ExternalStep `
        -StepId "S4_BUILD_WEEKEND_SAFE_PACK" `
        -Command "python .\\atas_microstructure_phase3_sandbox_v1\\tools\\build_phase3_weekend_safe_prelive_pack.py --output-dir .\\..\\..\\Files\\AI\\atas_micro_phase3_candidate --market-state $MarketState" `
        -Action { python $packBuilderScript --output-dir $outputDir --market-state $MarketState }
}
catch {
    $overallResult = "FAIL"
    $fatalError = $_.Exception.Message
}
finally {
    $payload = [ordered]@{
        schema_version = "ATAS_PHASE3_WEEKEND_SAFE_TOOL_READINESS_V1"
        generated_at_utc = Get-UtcNowIso
        market_state_assumption = $MarketState
        required_tools = @("python", "dotnet", "powershell")
        tool_checks = $toolChecks
        script_checks = $scriptChecks
        execution_steps = $executionSteps
        overall_result = $overallResult
        fatal_error = $fatalError
        produced_artifacts = [ordered]@{
            weekend_safe_status = (Join-Path $outputDir "phase3_weekend_safe_prelive_status_latest.json")
            weekend_safe_pack = (Join-Path $outputDir "phase3_weekend_safe_verification_pack_latest.md")
            closure_comparison = (Join-Path $outputDir "phase3_closure_before_after_comparison_latest.json")
            validation_latest = (Join-Path $outputDir "phase3_validation_latest.json")
            refinement_latest = (Join-Path $outputDir "phase3_1_refinement_cycles_latest.json")
        }
    }

    $payloadJson = $payload | ConvertTo-Json -Depth 12
    Set-Content -Path $statusPath -Value $payloadJson -Encoding UTF8
    Add-Content -Path $statusStreamPath -Value ($payload | ConvertTo-Json -Depth 12 -Compress) -Encoding UTF8

    Write-Output $payloadJson
    if ($overallResult -ne "PASS") {
        exit 1
    }
}

