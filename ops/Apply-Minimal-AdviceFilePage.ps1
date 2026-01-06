# ============================================================
# Apply-Minimal-AdviceFilePage.ps1
# One-shot: create canonical AdviceFile page + Audit deep link
# Founder-safe | Governance-enforced | Idempotent
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"
$AdviceDir = Join-Path $RepoRoot "src\pages\advice"

Write-Host ""
Write-Host "============================================================"
Write-Host "CREATING CANONICAL ADVICEFILE PAGE"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# 1) Create route directory
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $AdviceDir | Out-Null

$AdviceFilePath = Join-Path $AdviceDir "[adviceFileId].tsx"

if (Test-Path $AdviceFilePath) {
    Write-Host "✓ AdviceFile page already exists — skipping creation"
} else {

    $pageSource = @'
import { useRouter } from "next/router";
import Link from "next/link";

export default function AdviceFilePage() {
  const router = useRouter();
  const { adviceFileId } = router.query;

  // Demo-only stub data
  const auditPack = {
    notaryId: "NOTARY-DEMO"
  };

  return (
    <div style={{ padding: "2rem" }}>
      <h1>Advice File</h1>

      <p>
        <strong>Advice File ID:</strong> {adviceFileId}
      </p>

      <hr />

      <h2>Audit</h2>

      <p>
        This section presents immutable audit evidence captured at the time
        advice was issued.
      </p>

      {auditPack?.notaryId && (
        <div style={{ marginTop: "1rem" }}>
          <Link href={`/audit/notary/${auditPack.notaryId}`}>
            View Notary Proof
          </Link>
        </div>
      )}

      <p style={{ marginTop: "2rem", fontStyle: "italic" }}>
        TuringWealthOS does not provide financial advice. All advice decisions
        are made and authorised by licensed advisers.
      </p>
    </div>
  );
}
'@

    $pageSource | Out-File -LiteralPath $AdviceFilePath -Encoding utf8 -Force
    Write-Host "✓ AdviceFile page created at /advice/[adviceFileId]"
}

# ------------------------------------------------------------
# 2) Commit (governance enforced)
# ------------------------------------------------------------

Set-Location $RepoRoot
git add $AdviceFilePath | Out-Null

$status = git status --porcelain
if (-not $status) {
    Write-Host "✓ No changes to commit"
    exit 0
}

Write-Host ""
Write-Host "→ Committing AdviceFile page (governance hook will run)"
git commit -m "ui: add canonical AdviceFile page with notary audit deep link"

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ ADVICEFILE PAGE CREATED AND COMMITTED"
Write-Host "============================================================"
Write-Host ""
Write-Host "Route available:"
Write-Host "  /advice/[adviceFileId]"
Write-Host ""
Write-Host "Example:"
Write-Host "  http://localhost:3000/advice/AF-DEMO"
Write-Host ""
Write-Host "No shell termination."
Write-Host ""
