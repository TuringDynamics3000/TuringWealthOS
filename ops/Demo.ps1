# ============================================================
# Demo.ps1
# "make demo" equivalent for AlphaAdvisory Co
# One command → tenant + audit + notarisation
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"

$ApplyTenant = Join-Path $RepoRoot "ops\Apply-AlphaAdvisoryTenant.ps1"
$DemoAudit   = Join-Path $RepoRoot "ops\Demo-AlphaAdvisory-Audit.ps1"

Write-Host ""
Write-Host "============================================================"
Write-Host "TURINGWEALTHOS — DEMO (AlphaAdvisory Co)"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# 1) Ensure tenant exists (idempotent)
# ------------------------------------------------------------

if (!(Test-Path $ApplyTenant)) {
    throw "Missing Apply-AlphaAdvisoryTenant.ps1"
}

Write-Host "→ Applying AlphaAdvisory tenant (safe to re-run)"
pwsh $ApplyTenant NoGit

# ------------------------------------------------------------
# 2) Generate + notarise demo audit pack
# ------------------------------------------------------------

if (!(Test-Path $DemoAudit)) {
    throw "Missing Demo-AlphaAdvisory-Audit.ps1"
}

Write-Host ""
Write-Host "→ Generating demo audit pack + notarisation"
pwsh $DemoAudit

# ------------------------------------------------------------
# DONE
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ DEMO READY"
Write-Host "============================================================"
Write-Host ""
Write-Host "Next:"
Write-Host "  • Open audit_exports/AF-DEMO"
Write-Host "  • Open audit_notary/NOTARY-*"
Write-Host "  • Show UI viewer (read-only)"
Write-Host ""
Write-Host "No shell termination."
Write-Host ""
