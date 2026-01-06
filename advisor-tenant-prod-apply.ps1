# ============================================================
# Advisor Tenant — Production Apply (ONE SHOT, SEQUENTIAL)
# TuringWealthOS
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================"
Write-Host "APPLYING ADVISOR TENANT — PRODUCTION SEQUENCE"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# 0. Pre-flight validation
# ------------------------------------------------------------

if (!(Test-Path ".git")) {
    Write-Error "❌ Not in a Git repository. Abort."
    exit 1
}

$branch = git branch --show-current
if ($branch -ne "main") {
    Write-Error "❌ Must be on main branch (current: $branch)"
    exit 1
}

# ------------------------------------------------------------
# 1. Enforce compliant Advisor README wording
# ------------------------------------------------------------

$advisorReadme = "tenants\advisor\README.md"

if (Test-Path $advisorReadme) {
    Set-Content $advisorReadme @"
Advisor Tenant (Production)

Tenant = Licensed advice business (AFSL holder)

Invariants:
- Platform does NOT give advice
- Adviser is sole decision authority
- System enforces evidence, process, and auditability
- No execution, no optimisation, no system-generated advice
"@ -Encoding UTF8

    Write-Host "✓ Advisor README normalised"
}

# ------------------------------------------------------------
# 2. Language governance enforcement
# ------------------------------------------------------------

$forbidden = @(
    "recommend",
    "recommended",
    "recommendation",
    "optimal",
    "best option",
    "we advise",
    "ai suggests",
    "our advice"
)

$paths = @("src", "tenants", "docs")
$violations = @()

Write-Host "Scanning for forbidden advisory language..."

foreach ($path in $paths) {
    if (Test-Path $path) {
        Get-ChildItem -Path $path -Recurse -File | ForEach-Object {
            $matches = Select-String `
                -Path $_.FullName `
                -Pattern $forbidden `
                -SimpleMatch `
                -CaseSensitive:$false `
                -ErrorAction SilentlyContinue

            if ($matches) { $violations += $matches }
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host ""
    Write-Host "❌ Advisory language violations detected:"
    Write-Host ""

    foreach ($v in $violations) {
        Write-Host "$($v.Path):$($v.LineNumber)"
        Write-Host "  -> $($v.Line.Trim())"
        Write-Host ""
    }

    Write-Error "Governance breach. Abort."
    exit 1
}

Write-Host "✓ Language governance passed"

# ------------------------------------------------------------
# 3. Verify Advisor tenant artefacts
# ------------------------------------------------------------

$requiredFiles = @(
    "tenants\advisor\domain\advicefile.states.json",
    "tenants\advisor\domain\decision-event.schema.json"
)

foreach ($f in $requiredFiles) {
    if (!(Test-Path $f)) {
        Write-Error "❌ Missing required artefact: $f"
        exit 1
    }
}

Write-Host "✓ Advisor tenant artefacts verified"

# ------------------------------------------------------------
# 4. Git commit (only if needed)
# ------------------------------------------------------------

$gitStatus = git status --porcelain

if ($gitStatus) {
    Write-Host "Changes detected — committing"

    git add tenants\advisor scripts bootstrap-advisor-tenant.ps1
    git commit -m "chore: apply production-grade Advisor tenant governance"
} else {
    Write-Host "✓ No uncommitted changes"
}

# ------------------------------------------------------------
# 5. Push to origin/main
# ------------------------------------------------------------

Write-Host "Pushing to origin/main"
git push origin main

Write-Host ""
Write-Host "============================================================"
Write-Host "✅ ADVISOR TENANT PRODUCTION APPLY COMPLETE"
Write-Host "============================================================"
Write-Host ""
