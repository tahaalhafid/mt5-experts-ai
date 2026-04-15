param(
    [Parameter(Mandatory = $false)]
    [string]$CandidateBundle = ".\atas_microstructure_phase2_kickoff_v1\samples\state_bundle_candidate_example.json",
    [Parameter(Mandatory = $false)]
    [string]$OutputDir = "",
    [Parameter(Mandatory = $false)]
    [string]$Phase1CorePacket = "",
    [Parameter(Mandatory = $false)]
    [string]$Phase1ExtendedPacket = ""
)

$scriptPath = Join-Path $PSScriptRoot "validate_phase2_kickoff.py"
$argsList = @("--candidate-bundle", $CandidateBundle)

if ($OutputDir -ne "") {
    $argsList += @("--output-dir", $OutputDir)
}
if ($Phase1CorePacket -ne "") {
    $argsList += @("--phase1-core-packet", $Phase1CorePacket)
}
if ($Phase1ExtendedPacket -ne "") {
    $argsList += @("--phase1-extended-packet", $Phase1ExtendedPacket)
}

python $scriptPath @argsList
exit $LASTEXITCODE
