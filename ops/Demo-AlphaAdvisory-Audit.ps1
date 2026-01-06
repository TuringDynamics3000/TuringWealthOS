
# ============================================================
# Demo-AlphaAdvisory-Audit.ps1
# Creates + notarises a demo audit pack for AlphaAdvisory Co
# Founder-safe | Idempotent | No git side effects
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot     = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"
$AuditExports = Join-Path $RepoRoot "audit_exports"
$PoliciesDir  = Join-Path $RepoRoot "policies"
$Notariser    = Join-Path $RepoRoot "ops\Invoke-AuditNotarisation.ps1"

$AuditId    = "AF-DEMO"
$AuditDir   = Join-Path $AuditExports $AuditId
$PolicySnap = Join-Path $AuditDir "policy_snapshot"

Write-Host ""
Write-Host "============================================================"
Write-Host "ALPHAADVISORY — DEMO AUDIT PACK"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# Preconditions
# ------------------------------------------------------------

if (!(Test-Path $Notariser)) {
    throw "Missing Invoke-AuditNotarisation.ps1"
}

# ------------------------------------------------------------
# Create audit pack structure
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $AuditDir | Out-Null
New-Item -ItemType Directory -Force -Path $PolicySnap | Out-Null

Write-Host "✓ Audit pack directories created"

# ------------------------------------------------------------
# Write demo audit content
# ------------------------------------------------------------

@{
    auditPackId = $AuditId
    tenant      = "alphaadvisory"
    adviceFile  = @{
        adviceFileId = "AF-002"
        type         = "ROA"
        status       = "Issued"
        adviser      = "Adviser One"
    }
    generatedAtUtc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    notes = "Demo audit pack for AlphaAdvisory Co"
} | ConvertTo-Json -Depth 5 |
    Set-Content (Join-Path $AuditDir "audit.json") -Encoding UTF8

@"
# AlphaAdvisory Co — Demo Advice Audit

This audit pack demonstrates:

- Advice issued by a licensed adviser
- Evidence and decisions captured at the time
- Policies in force preserved
- Immutable notarisation applied post-issue

This file is for demonstration purposes only.
"@ | Set-Content (Join-Path $AuditDir "report.md") -Encoding UTF8

Write-Host "✓ Demo audit.json and report.md written"

# ------------------------------------------------------------
# Snapshot current policies
# ------------------------------------------------------------

Copy-Item "$PoliciesDir\*.json" $PolicySnap -Force

Write-Host "✓ Policy snapshot copied"

# ------------------------------------------------------------
# Run notarisation
# ------------------------------------------------------------

Write-Host ""
Write-Host "→ Running immutable notarisation..."
pwsh $Notariser $AuditId

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ DEMO AUDIT NOTARISED"
Write-Host "============================================================"
Write-Host ""
Write-Host "Audit pack:"
Write-Host "  $AuditDir"
Write-Host "Notary records:"
Write-Host "  $RepoRoot\audit_notary"
Write-Host ""
Write-Host "No shell termination."
Write-Host ""
