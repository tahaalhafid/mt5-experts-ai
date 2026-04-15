$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

$venvPath = Join-Path $scriptDir ".venv"
if (!(Test-Path $venvPath)) {
    python -m venv $venvPath
}

$pythonExe = Join-Path $venvPath "Scripts\\python.exe"
if (!(Test-Path $pythonExe)) {
    throw "Python executable was not found in virtual environment."
}

& $pythonExe -m pip install --upgrade pip
& $pythonExe -m pip install -r "requirements.txt"

Write-Host "Starting external dashboard on http://127.0.0.1:8010" -ForegroundColor Green
& $pythonExe -m uvicorn app.main:app --host 127.0.0.1 --port 8010 --reload
