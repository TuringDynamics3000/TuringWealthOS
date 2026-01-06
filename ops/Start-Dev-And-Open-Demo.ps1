# ============================================================
# Start-Dev-And-Open-Demo.ps1
# PowerShell-only dev launcher + demo opener
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"
$Port     = 3000
$DemoUrl  = "http://localhost:$Port/advice/AF-DEMO"

Write-Host ""
Write-Host "============================================================"
Write-Host "STARTING TURINGWEALTHOS DEV SERVER"
Write-Host "============================================================"
Write-Host ""

if (!(Test-Path $RepoRoot)) {
    throw "Repo root not found: $RepoRoot"
}

Set-Location $RepoRoot

# ------------------------------------------------------------
# Detect package manager
# ------------------------------------------------------------

function Has-Command($cmd) {
    return (Get-Command $cmd -ErrorAction SilentlyContinue) -ne $null
}

$runner = $null

if (Has-Command "pnpm") {
    $runner = "pnpm dev"
} elseif (Has-Command "npm") {
    $runner = "npm run dev"
} elseif (Has-Command "yarn") {
    $runner = "yarn dev"
} else {
    throw "No package manager found (pnpm, npm, yarn)"
}

Write-Host "Using: $runner"

# ------------------------------------------------------------
# Start dev server in background
# ------------------------------------------------------------

Start-Process powershell -ArgumentList "-NoExit","-Command",$runner `
    -WorkingDirectory $RepoRoot | Out-Null

# ------------------------------------------------------------
# Wait for localhost to be ready
# ------------------------------------------------------------

Write-Host ""
Write-Host "Waiting for http://localhost:$Port …"

$ready = $false
for ($i = 0; $i -lt 60; $i++) {
    try {
        $req = Invoke-WebRequest "http://localhost:$Port" -UseBasicParsing -TimeoutSec 1
        $ready = $true
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}

if (-not $ready) {
    throw "Dev server did not start on port $Port"
}

Write-Host "✓ Dev server is running"

# ------------------------------------------------------------
# Open demo page
# ------------------------------------------------------------

Write-Host ""
Write-Host "Opening demo page:"
Write-Host "  $DemoUrl"
Start-Process $DemoUrl

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ DEV + DEMO READY"
Write-Host "============================================================"
Write-Host ""
Write-Host "AdviceFile → Audit → Notary proof should now load."
Write-Host "No shell termination."
Write-Host ""
