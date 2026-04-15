param(
    [Parameter(Mandatory = $false)]
    [string]$BundlePath = ""
)

$generator = Join-Path $PSScriptRoot "generate_phase3_candidate_bundle.py"
$validator = Join-Path $PSScriptRoot "validate_phase3_candidate_bundle.py"
$mql5Root = Resolve-Path (Join-Path $PSScriptRoot "..\\..\\..\\..")
if ([string]::IsNullOrWhiteSpace($BundlePath)) {
    $BundlePath = Join-Path $mql5Root "Files\\AI\\atas_micro_phase3_candidate\\phase3_candidate_state_bundle_latest.json"
}

python $generator
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

python $validator --bundle $BundlePath
exit $LASTEXITCODE
