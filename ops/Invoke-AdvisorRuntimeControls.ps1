# ============================================================
# Invoke-AdvisorRuntimeControls.ps1
# Runtime Guard + RBAC + Audit Export
# Non-terminating | Production-grade | PS 5.1+
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================"
Write-Host "ADVISOR RUNTIME CONTROLS — LOADED"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# CONFIG
# ------------------------------------------------------------

$TenantRoot = "tenants\advisor"
$DomainRoot = "$TenantRoot\domain"
$AuditRoot  = "audit_exports"

# ------------------------------------------------------------
# 1. Runtime Guard — AdviceFile State Enforcement
# ------------------------------------------------------------

$StateMachinePath = "$DomainRoot\advicefile.states.json"

if (!(Test-Path $StateMachinePath)) {
    throw "AdviceFile state machine missing at $StateMachinePath"
}

$StateMachine = Get-Content $StateMachinePath | ConvertFrom-Json

function Invoke-AdviceFileStateGuard {
    param (
        [Parameter(Mandatory)][string] $From,
        [Parameter(Mandatory)][string] $To,
        [Parameter(Mandatory)][string[]] $SatisfiedRequirements
    )

    $transition = $StateMachine.transitions | Where-Object {
        $_.from -eq $From -and $_.to -eq $To
    }

    if (-not $transition) {
        throw "Invalid state transition: $From → $To"
    }

    foreach ($req in $transition.requires) {
        if ($SatisfiedRequirements -notcontains $req) {
            throw "State transition blocked — missing requirement: $req"
        }
    }

    Write-Host "✓ State transition permitted: $From → $To"
}

# ------------------------------------------------------------
# 2. RBAC Enforcement
# ------------------------------------------------------------

$RBAC = @{
    Adviser = @{
        CanAuthorise = $true
        CanPrepare   = $true
        CanAudit     = $false
    }
    Paraplanner = @{
        CanAuthorise = $false
        CanPrepare   = $true
        CanAudit     = $false
    }
    Compliance = @{
        CanAuthorise = $false
        CanPrepare   = $false
        CanAudit     = $true
    }
}

function Invoke-AdvisorRBACGuard {
    param (
        [Parameter(Mandatory)][string] $Role,
        [Parameter(Mandatory)][string] $Action
    )

    if (-not $RBAC.ContainsKey($Role)) {
        throw "Unknown role: $Role"
    }

    $key = "Can$Action"

    if (-not $RBAC[$Role].ContainsKey($key)) {
        throw "Unknown action: $Action"
    }

    if (-not $RBAC[$Role][$key]) {
        throw "RBAC violation — $Role cannot perform $Action"
    }

    Write-Host "✓ RBAC permitted: $Role → $Action"
}

# ------------------------------------------------------------
# 3. Audit Export (Hash-linked)
# ------------------------------------------------------------

function Export-AdvisorAuditPack {
    param (
        [Parameter(Mandatory)][string] $AdviceFileId,
        [Parameter(Mandatory)][string] $AdviserId,
        [Parameter(Mandatory)][string] $ClientId,
        [Parameter(Mandatory)][string[]] $DecisionLog
    )

    $ExportDir = Join-Path $AuditRoot $AdviceFileId
    New-Item -ItemType Directory -Path $ExportDir -Force | Out-Null

    $AuditPayload = @{
        AdviceFileId = $AdviceFileId
        AdviserId    = $AdviserId
        ClientId     = $ClientId
        Decisions    = $DecisionLog
        GeneratedAt  = (Get-Date -Format o)
    }

    $AuditPath = Join-Path $ExportDir "audit.json"
    $AuditPayload | ConvertTo-Json -Depth 6 |
        Set-Content $AuditPath -Encoding UTF8

    $Hash = (Get-FileHash $AuditPath -Algorithm SHA256).Hash
    Set-Content (Join-Path $ExportDir "audit.sha256") $Hash

    Write-Host "✓ Audit pack generated: $ExportDir"
    Write-Host "✓ SHA256: $Hash"
}

Write-Host ""
Write-Host "Runtime controls loaded. No shell termination."
Write-Host ""
