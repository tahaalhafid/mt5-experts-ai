param(
    [Parameter(Mandatory = $false)]
    [int]$Cycles = 3,
    [Parameter(Mandatory = $false)]
    [int]$IntervalSeconds = 2
)

if ($Cycles -lt 1) {
    Write-Error "Cycles must be >= 1"
    exit 1
}

$generator = Join-Path $PSScriptRoot "generate_phase3_candidate_bundle.py"
$validator = Join-Path $PSScriptRoot "validate_phase3_candidate_bundle.py"
$mql5Root = Resolve-Path (Join-Path $PSScriptRoot "..\..\..\..")
$outputDir = Join-Path $mql5Root "Files\AI\atas_micro_phase3_candidate"
$bundlePath = Join-Path $outputDir "phase3_candidate_state_bundle_latest.json"
$validationPath = Join-Path $outputDir "phase3_validation_latest.json"
$cycleLatestPath = Join-Path $outputDir "phase3_1_refinement_cycles_latest.json"
$cycleStreamPath = Join-Path $outputDir "phase3_1_refinement_cycles_stream.jsonl"

if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$results = @()
for ($i = 1; $i -le $Cycles; $i++) {
    python $generator
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Generator failed at cycle $i"
        exit $LASTEXITCODE
    }

    python $validator --bundle $bundlePath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Validator failed at cycle $i"
        exit $LASTEXITCODE
    }

    $bundle = Get-Content -Raw -Path $bundlePath | ConvertFrom-Json
    $validation = Get-Content -Raw -Path $validationPath | ConvertFrom-Json
    $results += [ordered]@{
        cycle = $i
        evaluated_at_utc = [DateTime]::UtcNow.ToString("o")
        bundle_id = $bundle.candidate_bundle_id
        candidate_overall_status = $bundle.candidate_quality_summary.overall_status
        validator_result = $validation.result
        average_completeness_ratio = $bundle.candidate_quality_summary.average_completeness_ratio
        family_completeness = $bundle.candidate_quality_summary.family_completeness
        freshness_state_counts = $bundle.candidate_quality_summary.freshness_summary.freshness_state_counts
        source_state_counts = $bundle.candidate_quality_summary.source_completeness_summary.source_state_counts
        lineage_state = $bundle.candidate_quality_summary.lineage_continuity_summary.lineage_state
        lineage_first_break_stage = $bundle.candidate_quality_summary.lineage_continuity_summary.first_break_stage
    }

    if ($i -lt $Cycles -and $IntervalSeconds -gt 0) {
        Start-Sleep -Seconds $IntervalSeconds
    }
}

$payload = [ordered]@{
    schema_version = "ATAS_PHASE3_1_REFINEMENT_CYCLE_SUMMARY_V1"
    generated_at_utc = [DateTime]::UtcNow.ToString("o")
    cycles_requested = $Cycles
    interval_seconds = $IntervalSeconds
    cycles = $results
}

$payloadJson = $payload | ConvertTo-Json -Depth 12
Set-Content -Path $cycleLatestPath -Value $payloadJson -Encoding UTF8
Add-Content -Path $cycleStreamPath -Value ($payload | ConvertTo-Json -Depth 12 -Compress) -Encoding UTF8

Write-Output ($payload | ConvertTo-Json -Depth 12)
