# ============================================================
# SmokeTest-Demo.ps1
# End-to-end smoke test for AlphaAdvisory demo
# PowerShell-only | Read-only | Deterministic
# ============================================================

$ErrorActionPreference = "Stop"

$BaseUrl = "http://localhost:3000"
$AdviceUrl = "$BaseUrl/advice/AF-DEMO"

Write-Host ""
Write-Host "============================================================"
Write-Host "SMOKE TEST — TURINGWEALTHOS DEMO"
Write-Host "============================================================"
Write-Host ""

function Assert-Ok($url, $name) {
    Write-Host "→ Checking $name"
    try {
        $r = Invoke-WebRequest $url -UseBasicParsing -TimeoutSec 3
        if ($r.StatusCode -ne 200) {
            throw "$name returned status $($r.StatusCode)"
        }
        Write-Host "✓ $name OK"
    } catch {
        throw "FAIL: $name not reachable at $url"
    }
}

# ------------------------------------------------------------
# 1) AdviceFile page
# ------------------------------------------------------------

Assert-Ok $AdviceUrl "AdviceFile page"

# ------------------------------------------------------------
# 2) Discover latest NOTARY id
# ------------------------------------------------------------

$NotaryRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS\audit_notary"

if (!(Test-Path $NotaryRoot)) {
    throw "No audit_notary directory found"
}

$LatestNotary = Get-ChildItem $NotaryRoot -Directory |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1

if (-not $LatestNotary) {
    throw "No notary records found"
}

$NotaryId = $LatestNotary.Name
Write-Host "✓ Found notary record: $NotaryId"

# ------------------------------------------------------------
# 3) Notary API
# ------------------------------------------------------------

Assert-Ok "$BaseUrl/api/notary/$NotaryId" "Notary API"

# ------------------------------------------------------------
# 4) Notary Viewer UI
# ------------------------------------------------------------

Assert-Ok "$BaseUrl/audit/notary/$NotaryId" "Notary Viewer page"

# ------------------------------------------------------------
# DONE
# --------------
