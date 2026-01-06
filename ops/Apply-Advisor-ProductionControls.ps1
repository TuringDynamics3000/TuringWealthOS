# ============================================================
# Apply-Advisor-ProductionControls.ps1
# Canonical Governance + Runtime + Audit Controls
# PowerShell-only | Windows-safe | Non-terminating
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================"
Write-Host "APPLYING ADVISOR PRODUCTION CONTROLS"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# DIRECTORIES
# ------------------------------------------------------------

$BaseDirs = @(
    "policies",
    "ops",
    "runtime",
    "audit_templates",
    "audit_exports"
)

foreach ($dir in $BaseDirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created $dir"
    }
}

# ------------------------------------------------------------
# POLICY LAYER (DECLARATIVE)
# ------------------------------------------------------------

@'
{
  "forbidden_terms": [
    "recommend",
    "recommended",
    "recommendation",
    "optimal",
    "best option",
    "we advise",
    "ai suggests",
    "our advice"
  ],
  "scope": ["src", "tenants", "docs"]
}
'@ | Set-Content policies\advisory-language.json -Encoding UTF8

@'
{
  "states": ["Draft", "Reviewed", "Authorised", "Issued"],
  "transitions": [
    {
      "from": "Draft",
      "to": "Reviewed",
      "requires": ["facts_complete", "consent_present"]
    },
    {
      "from": "Reviewed",
      "to": "Authorised",
      "requires": ["adviser_signature", "decision_log_complete"]
    },
    {
      "from": "Authorised",
      "to": "Issued",
      "requires": ["artefact_generated"]
    }
  ]
}
'@ | Set-Content policies\advicefile-states.json -Encoding UTF8

@'
{
  "Adviser": ["Prepare", "Authorise"],
  "Paraplanner": ["Prepare"],
  "Compliance": ["Audit"]
}
'@ | Set-Content policies\rbac.json -Encoding UTF8

Write-Host "✓ Policies written"

# ------------------------------------------------------------
# ENFORCEMENT LAYER (POWERSHELL)
# ------------------------------------------------------------

@'
param()

$policy = Get-Content policies\advisory-language.json | ConvertFrom-Json
$violations = @()

foreach ($path in $policy.scope) {
    if (Test-Path $path) {
        Get-ChildItem $path -Recurse -File | ForEach-Object {
            $hits = Select-String `
                -Path $_.FullName `
                -Pattern $policy.forbidden_terms `
                -SimpleMatch `
                -CaseSensitive:$false `
                -ErrorAction SilentlyContinue
            if ($hits) { $violations += $hits }
        }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "❌ Advisory language violation detected:"
    foreach ($v in $violations) {
        Write-Host "$($v.Path):$($v.LineNumber) -> $($v.Line.Trim())"
    }
    throw "Governance breach"
}

Write-Host "✓ Advisory language governance passed"
'@ | Set-Content ops\Invoke-AdvisoryLanguage.ps1 -Encoding UTF8

@'
param($From, $To, $Satisfied)

$policy = Get-Content policies\advicefile-states.json | ConvertFrom-Json
$transition = $policy.transitions | Where-Object { $_.from -eq $From -and $_.to -eq $To }

if (-not $transition) {
    throw "Invalid AdviceFile state transition"
}

foreach ($req in $transition.requires) {
    if ($Satisfied -notcontains $req) {
        throw "Missing requirement: $req"
    }
}

Write-Host "✓ AdviceFile transition permitted"
'@ | Set-Content ops\Invoke-AdviceFileStateGuard.ps1 -Encoding UTF8

@'
param($Role, $Action)

$rbac = Get-Content policies\rbac.json | ConvertFrom-Json

if (-not $rbac.$Role) {
    throw "Unknown role: $Role"
}

if ($rbac.$Role -notcontains $Action) {
    throw "RBAC violation: $Role cannot $Action"
}

Write-Host "✓ RBAC permitted"
'@ | Set-Content ops\Invoke-RBACGuard.ps1 -Encoding UTF8

@'
pwsh ops\Invoke-AdvisoryLanguage.ps1
'@ | Set-Content ops\Invoke-Governance.ps1 -Encoding UTF8

Write-Host "✓ Enforcement scripts written"

# ------------------------------------------------------------
# RUNTIME WIRING
# ------------------------------------------------------------

@'
. "$PSScriptRoot\..\ops\Invoke-Governance.ps1"
. "$PSScriptRoot\..\ops\Invoke-AdviceFileStateGuard.ps1"
. "$PSScriptRoot\..\ops\Invoke-RBACGuard.ps1"

Write-Host "✓ Runtime governance loaded"
'@ | Set-Content runtime\RuntimeGuard.ps1 -Encoding UTF8

Write-Host "✓ Runtime wired"

# ------------------------------------------------------------
# AUDIT TEMPLATES + POLICY SNAPSHOT
# ------------------------------------------------------------

@'
ASIC ADVICE FILE REVIEW
----------------------
System does NOT provide advice.
All decisions made by licensed adviser.
'@ | Set-Content audit_templates\ASIC.md -Encoding UTF8

@'
AFCA RESPONSE PACK
-----------------
Decision-support system only.
'@ | Set-Content audit_templates\AFCA.md -Encoding UTF8

Copy-Item policies audit_exports\policy_snapshot -Recurse -Force

Write-Host "✓ Audit templates and policy snapshot created"

# ------------------------------------------------------------
# COMPLETE
# ------------------------------------------------------------

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ CANONICAL GOVERNANCE STACK APPLIED"
Write-Host "============================================================"
Write-Host ""
Write-Host "No shell termination. Safe for Windows PowerShell."
Write-Host ""
