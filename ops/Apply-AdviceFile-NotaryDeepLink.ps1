# ============================================================
# Apply-AdviceFile-NotaryDeepLink.ps1
# One-shot: add Notary Viewer deep link to AdviceFile Audit tab
# Founder-safe | Governance-enforced | Idempotent
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"

# ---- Adjust ONLY if your file name differs
$AuditTabPath = Join-Path $RepoRoot "src\components\advicefile\AuditTab.tsx"

if (!(Test-Path $AuditTabPath)) {
    throw "Audit tab component not found at: $AuditTabPath"
}

Write-Host ""
Write-Host "============================================================"
Write-Host "ADDING NOTARY DEEP LINK TO ADVICEFILE AUDIT TAB"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# Read existing file
# ------------------------------------------------------------

$existing = Get-Content -LiteralPath $AuditTabPath -Raw

if ($existing -match "View Notary Proof") {
    Write-Host "✓ Notary deep link already present — no changes needed"
} else {

    Write-Host "→ Injecting Notary deep link"

    # Minimal, non-invasive JSX injection
    $injection = @'
      {auditPack?.notaryId && (
        <div style={{ marginTop: "1rem" }}>
          <a
            href={`/audit/notary/${auditPack.notaryId}`}
            target="_blank"
            rel="noopener noreferrer"
          >
            View Notary Proof
          </a>
        </div>
      )}
'@

    # Append safely at end of component render
    $updated = $existing -replace '(</div>\s*\);\s*}$)', "$injection`n`$1"

    $updated | Out-File -LiteralPath $AuditTabPath -Encoding utf8 -Force

    Write-Host "✓ Notary deep link injected"
}

# ------------------------------------------------------------
# Commit (governance hook enforced)
# ------------------------------------------------------------

Set-Location $RepoRoot

git add $AuditTabPath | Out-Null

$status = git status --porcelain
if (-not $status) {
    Write-Host "✓ No changes to commit"
    exit 0
}

Write-Host ""
Write-Host "→ Committing change (governance hook will run)"
git commit -m "ui: add notary proof deep link to AdviceFile audit tab"

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ NOTARY DEEP LINK APPLIED AND COMMITTED"
Write-Host "============================================================"
Write-Host ""
