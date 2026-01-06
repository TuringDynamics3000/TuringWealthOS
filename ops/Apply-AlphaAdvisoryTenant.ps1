# ============================================================
# Apply-AlphaAdvisoryTenant.ps1
# One-shot: scaffold AlphaAdvisory Co tenant + checklists + seed
# Windows | PowerShell-only | Non-terminating | Absolute paths
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# Args (BOM-safe)
# Usage:
#   pwsh -File ...\Apply-AlphaAdvisoryTenant.ps1
#   pwsh -File ...\Apply-AlphaAdvisoryTenant.ps1 NoGit
# ------------------------------------------------------------

$NoGit = $false
if ($args.Count -ge 1 -and $args[0].ToLower() -eq "nogit") { $NoGit = $true }

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"
$TenantDir = Join-Path $RepoRoot "tenants\alphaadvisory"
$SeedDir   = Join-Path $TenantDir "seed"
$ChkDir    = Join-Path $TenantDir "checklists"
$BrandDir  = Join-Path $TenantDir "brand"

Write-Host ""
Write-Host "============================================================"
Write-Host "APPLYING TENANT: AlphaAdvisory Co"
Write-Host "============================================================"
Write-Host ""
Write-Host "Repo:   $RepoRoot"
Write-Host "Tenant: $TenantDir"
Write-Host "NoGit:  $NoGit"
Write-Host ""

if (!(Test-Path (Join-Path $RepoRoot ".git"))) {
  throw "Not a git repository: $RepoRoot"
}

# --- Create directories
foreach ($d in @($TenantDir,$SeedDir,$ChkDir,$BrandDir)) {
  if (!(Test-Path $d)) {
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    Write-Host "Created $d"
  }
}

# ============================================================
# 1) Tenant config
# ============================================================

$tenantConfig = @{
  tenant_id   = "alphaadvisory"
  tenant_name = "AlphaAdvisory Co"
  tenant_type = "advisor_practice"

  branding = @{
    logo_path    = "tenants/alphaadvisory/brand/logo.svg"
    accent_hex   = "#1F4B99"
    display_name = "AlphaAdvisory Co"
  }

  ui_defaults = @{
    household_always_present = $true
    groups_workspace_visible_only_if_groupId_exists = $true
    groups_module_enabled = $true
  }

  permissions = @{
    actions = @(
      "Prepare",
      "Authorise",
      "Issue",
      "Audit",
      "GenerateAuditPack",
      "VerifyNotary",
      "CreateAdviceFile"
    )
    roles = @{
      Adviser      = @("Prepare","Authorise","Issue","CreateAdviceFile")
      Paraplanner  = @("Prepare")
      Compliance   = @("Audit","GenerateAuditPack","VerifyNotary")
      Admin        = @("Prepare","Authorise","Issue","Audit","GenerateAuditPack","VerifyNotary","CreateAdviceFile")
      Principal    = @()
    }
  }

  terminology = @{
    advice_file_types = @{
      SOA    = "Statement of Advice"
      ROA    = "Record of Advice"
      Review = "Review"
      Other  = "Advice File"
    }
  }

  slas = @{
    draft_to_review_days        = 7
    reviewed_to_authorised_days = 3
    authorised_to_issued_days   = 2
  }

  created_utc = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
}

$tenantConfig | ConvertTo-Json -Depth 10 |
  Set-Content (Join-Path $TenantDir "tenant.json") -Encoding UTF8

@"
# AlphaAdvisory Co (Adviser Tenant)

Locked decisions:
- Household always exists (household-of-1 allowed)
- Group workspace appears only if groupId exists
- Create AdviceFiles: Adviser/Admin only
- Generate Audit Packs: Compliance/Admin only

Contents:
- tenant.json
- checklists/
- seed/
- brand/
"@ | Set-Content (Join-Path $TenantDir "README.md") -Encoding UTF8

if (!(Test-Path (Join-Path $BrandDir "logo.svg"))) {
  Set-Content (Join-Path $BrandDir "logo.svg") "<svg xmlns='http://www.w3.org/2000/svg' width='1' height='1'></svg>" -Encoding UTF8
}

Write-Host "✓ tenant.json + README.md written"

# ============================================================
# 2) Checklists
# ============================================================

$checklistReview = @{
  template_id = "alpha_review_v1"
  applies_to  = "Review"
  required_evidence = @(
    @{ key="consent_present"; label="Client consent recorded"; required=$true },
    @{ key="fact_find"; label="Fact find captured"; required=$true },
    @{ key="income_expense"; label="Income/expense evidence"; required=$true },
    @{ key="portfolio_statement"; label="Portfolio statement(s) attached"; required=$true }
  )
}

$checklistROA = @{
  template_id = "alpha_roa_v1"
  applies_to  = "ROA"
  required_evidence = @(
    @{ key="consent_present"; label="Client consent recorded"; required=$true },
    @{ key="scope_statement"; label="Scope statement captured"; required=$true },
    @{ key="supporting_docs"; label="Supporting documents attached"; required=$true }
  )
}

$checklistSOA = @{
  template_id = "alpha_soa_v1"
  applies_to  = "SOA"
  required_evidence = @(
    @{ key="consent_present"; label="Client consent recorded"; required=$true },
    @{ key="fact_find"; label="Fact find captured"; required=$true },
    @{ key="risk_profile"; label="Risk profile evidence"; required=$true },
    @{ key="disclosures"; label="Disclosures acknowledged"; required=$true }
  )
}

$checklistReview | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $ChkDir "Review.checklist.json") -Encoding UTF8
$checklistROA    | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $ChkDir "ROA.checklist.json") -Encoding UTF8
$checklistSOA    | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $ChkDir "SOA.checklist.json") -Encoding UTF8

Write-Host "✓ Checklist templates written"

# ============================================================
# 3) Seed dataset
# ============================================================

$households = @(
  @{ householdId="HH-001"; name="Morgan Household"; createdAt="2026-01-06T00:00:00Z" },
  @{ householdId="HH-002"; name="Singh Household";  createdAt="2026-01-06T00:00:00Z" },
  @{ householdId="HH-003"; name="Chen Household";   createdAt="2026-01-06T00:00:00Z" },
  @{ householdId="HH-004"; name="Harper Household"; createdAt="2026-01-06T00:00:00Z" },
  @{ householdId="HH-005"; name="Solo Household";   createdAt="2026-01-06T00:00:00Z" }
)

$groups = @(
  @{ groupId="GRP-001"; name="Harper Group"; type="family_office"; createdAt="2026-01-06T00:00:00Z" },
  @{ groupId="GRP-002"; name="Chen Group";   type="business_owner_group"; createdAt="2026-01-06T00:00:00Z" }
)

$users = @(
  @{ userId="USR-ADV-001"; role="Adviser"; name="Adviser One"; email="adviser1@alphaadvisory.example" },
  @{ userId="USR-ADV-002"; role="Adviser"; name="Adviser Two"; email="adviser2@alphaadvisory.example" },
  @{ userId="USR-PARA-001"; role="Paraplanner"; name="Para One"; email="para1@alphaadvisory.example" },
  @{ userId="USR-PARA-002"; role="Paraplanner"; name="Para Two"; email="para2@alphaadvisory.example" },
  @{ userId="USR-COMP-001"; role="Compliance"; name="Compliance One"; email="compliance@alphaadvisory.example" },
  @{ userId="USR-ADMIN-001"; role="Admin"; name="Admin One"; email="admin@alphaadvisory.example" }
)

$clients = @(
  @{ clientId="CL-001"; householdId="HH-001"; groupId=$null;     displayName="Alex Morgan";   classification="retail";    assignedAdviserId="USR-ADV-001" },
  @{ clientId="CL-002"; householdId="HH-002"; groupId=$null;     displayName="Priya Singh";   classification="retail";    assignedAdviserId="USR-ADV-002" },
  @{ clientId="CL-003"; householdId="HH-003"; groupId="GRP-002"; displayName="Wei Chen";      classification="wholesale"; assignedAdviserId="USR-ADV-001" },
  @{ clientId="CL-004"; householdId="HH-004"; groupId="GRP-001"; displayName="Jordan Harper"; classification="wholesale"; assignedAdviserId="USR-ADV-002" },
  @{ clientId="CL-005"; householdId="HH-005"; groupId=$null;     displayName="Single Client"; classification="retail";    assignedAdviserId="USR-ADV-001" }
)

$adviceFiles = @(
  @{ adviceFileId="AF-001"; clientId="CL-001"; householdId="HH-001"; groupId=$null;     type="Review"; status="Draft";      assignedAdviserId="USR-ADV-001"; assignedPreparerId="USR-PARA-001"; dueDate="2026-01-20T00:00:00Z" },
  @{ adviceFileId="AF-002"; clientId="CL-001"; householdId="HH-001"; groupId=$null;     type="ROA";    status="Reviewed";   assignedAdviserId="USR-ADV-001"; assignedPreparerId="USR-PARA-001"; dueDate="2026-01-14T00:00:00Z" },
  @{ adviceFileId="AF-003"; clientId="CL-002"; householdId="HH-002"; groupId=$null;     type="SOA";    status="Authorised"; assignedAdviserId="USR-ADV-002"; assignedPreparerId="USR-PARA-002"; dueDate="2026-01-10T00:00:00Z" },
  @{ adviceFileId="AF-004"; clientId="CL-004"; householdId="HH-004"; groupId="GRP-001"; type="Review"; status="Issued";     assignedAdviserId="USR-ADV-002"; assignedPreparerId="USR-PARA-002"; dueDate="2026-01-05T00:00:00Z" },
  @{ adviceFileId="AF-005"; clientId="CL-003"; householdId="HH-003"; groupId="GRP-002"; type="ROA";    status="Draft";      assignedAdviserId="USR-ADV-001"; assignedPreparerId="USR-PARA-001"; dueDate="2026-01-25T00:00:00Z" }
)

$evidence = @(
  @{ evidenceId="EV-001"; kind="Consent";  source="upload"; createdAt="2026-01-06T00:00:00Z"; capturedByUserId="USR-PARA-001"; linked=@{ clientId="CL-001"; adviceFileIds=@("AF-001","AF-002") }; filename="consent.pdf" },
  @{ evidenceId="EV-002"; kind="Document"; source="upload"; createdAt="2026-01-06T00:00:00Z"; capturedByUserId="USR-PARA-001"; linked=@{ clientId="CL-001"; adviceFileIds=@("AF-002") }; filename="portfolio_statement.pdf" },
  @{ evidenceId="EV-003"; kind="Document"; source="upload"; createdAt="2026-01-06T00:00:00Z"; capturedByUserId="USR-PARA-002"; linked=@{ clientId="CL-004"; groupId="GRP-001"; adviceFileIds=@("AF-004") }; filename="group_structure.pdf" }
)

$decisions = @(
  @{ decisionId="DE-001"; adviceFileId="AF-002"; authorUserId="USR-ADV-001"; label="Scope confirmed"; rationale="Scope recorded by adviser. Evidence referenced."; evidenceRefs=@("EV-001","EV-002"); createdAt="2026-01-06T00:00:00Z" },
  @{ decisionId="DE-002"; adviceFileId="AF-003"; authorUserId="USR-ADV-002"; label="Client objectives recorded"; rationale="Objectives captured and linked to evidence where available."; evidenceRefs=@(); createdAt="2026-01-06T00:00:00Z" },
  @{ decisionId="DE-003"; adviceFileId="AF-004"; authorUserId="USR-ADV-002"; label="Authorisation completed"; rationale="Adviser authorisation recorded. Audit pack generated on issue."; evidenceRefs=@("EV-003"); createdAt="2026-01-06T00:00:00Z" }
)

@{ households=$households } | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "households.json") -Encoding UTF8
@{ groups=$groups }         | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "groups.json") -Encoding UTF8
@{ users=$users }           | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "users.json") -Encoding UTF8
@{ clients=$clients }       | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "clients.json") -Encoding UTF8
@{ adviceFiles=$adviceFiles } | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "advicefiles.json") -Encoding UTF8
@{ evidence=$evidence }     | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "evidence.json") -Encoding UTF8
@{ decisions=$decisions }   | ConvertTo-Json -Depth 10 | Set-Content (Join-Path $SeedDir "decisions.json") -Encoding UTF8

Write-Host "✓ Seed dataset written"

# ============================================================
# 4) Git add/commit/push
# ============================================================

Set-Location $RepoRoot

if (-not $NoGit) {
  Write-Host "→ Git: add/commit/push"
  git add "tenants\alphaadvisory" | Out-Null

  $status = git status --porcelain
  if ($status) {
    git commit -m "tenant: add AlphaAdvisory Co config and seed dataset" | Out-Null
    git push origin main | Out-Null
    Write-Host "✓ Committed and pushed"
  } else {
    Write-Host "✓ Nothing to commit"
  }
} else {
  Write-Host "→ Skipped git commit/push (NoGit)"
}

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ AlphaAdvisory Co tenant applied"
Write-Host "============================================================"
Write-Host ""
Write-Host "No shell termination."
Write-Host ""
