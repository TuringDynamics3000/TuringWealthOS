# ============================================================
# Apply-NotaryViewer.ps1
# One-shot: wire Notary Viewer into UI routes (read-only)
# FINAL VERSION (handles [] paths correctly)
# ============================================================

$ErrorActionPreference = "Stop"

$RepoRoot = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"

$ApiDir  = Join-Path $RepoRoot "src\pages\api\notary"
$UiDir   = Join-Path $RepoRoot "src\pages\audit\notary"
$CompDir = Join-Path $RepoRoot "src\components\audit"

Write-Host ""
Write-Host "============================================================"
Write-Host "APPLYING NOTARY VIEWER (READ-ONLY)"
Write-Host "============================================================"
Write-Host ""

# ------------------------------------------------------------
# 1) API endpoint: /api/notary/[notaryId]
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $ApiDir | Out-Null

$apiSource = @'
import fs from "fs";
import path from "path";

export default function handler(req, res) {
  const { notaryId } = req.query;

  const repoRoot = process.cwd();
  const notaryDir = path.join(repoRoot, "audit_notary", notaryId);

  if (!fs.existsSync(notaryDir)) {
    return res.status(404).json({ error: "Notary record not found" });
  }

  const read = (f) =>
    fs.existsSync(path.join(notaryDir, f))
      ? fs.readFileSync(path.join(notaryDir, f), "utf8").trim()
      : null;

  res.status(200).json({
    notaryId,
    merkleRoot: read("merkle_root.txt"),
    timestampUtc: read("timestamp_utc.txt"),
    gitCommit: read("git_anchor.txt"),
  });
}
'@

$apiPath = Join-Path $ApiDir "[notaryId].ts"
$apiSource | Out-File -LiteralPath $apiPath -Encoding utf8 -Force
Write-Host "✓ API endpoint created"

# ------------------------------------------------------------
# 2) UI route: /audit/notary/[notaryId]
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $UiDir | Out-Null

$uiSource = @'
import { useRouter } from "next/router";
import useSWR from "swr";
import NotaryViewer from "../../../components/audit/NotaryViewer";

const fetcher = (url) => fetch(url).then((r) => r.json());

export default function NotaryPage() {
  const router = useRouter();
  const { notaryId } = router.query;

  const { data, error } = useSWR(
    notaryId ? `/api/notary/${notaryId}` : null,
    fetcher
  );

  if (error) return <div>Notary record not found.</div>;
  if (!data) return <div>Loading notary record…</div>;

  return <NotaryViewer record={data} />;
}
'@

$uiPath = Join-Path $UiDir "[notaryId].tsx"
$uiSource | Out-File -LiteralPath $uiPath -Encoding utf8 -Force
Write-Host "✓ UI route created"

# ------------------------------------------------------------
# 3) NotaryViewer component
# ------------------------------------------------------------

New-Item -ItemType Directory -Force -Path $CompDir | Out-Null

$componentSource = @'
type Props = {
  record: {
    notaryId: string;
    merkleRoot: string;
    timestampUtc: string;
    gitCommit: string;
  };
};

export default function NotaryViewer({ record }: Props) {
  return (
    <div style={{ padding: "2rem" }}>
      <h1>Notary Record — Immutable Audit Proof</h1>

      <p>
        This view presents cryptographic proof that an audit pack has not changed
        since notarisation.
      </p>

      <h3>Cryptographic Anchors</h3>
      <ul>
        <li><strong>Merkle Root:</strong> {record.merkleRoot}</li>
        <li><strong>Timestamp (UTC):</strong> {record.timestampUtc}</li>
        <li><strong>Git Commit:</strong> {record.gitCommit}</li>
      </ul>

      <p style={{ marginTop: "2rem", fontStyle: "italic" }}>
        TuringWealthOS does not provide financial advice. All advice decisions are
        made and authorised by licensed advisers. This proof demonstrates that
        the audit record has not been altered since the time shown above.
      </p>
    </div>
  );
}
'@

$compPath = Join-Path $CompDir "NotaryViewer.tsx"
$componentSource | Out-File -LiteralPath $compPath -Encoding utf8 -Force
Write-Host "✓ NotaryViewer component created"

Write-Host ""
Write-Host "============================================================"
Write-Host "✓ NOTARY VIEWER WIRED"
Write-Host "============================================================"
Write-Host ""
Write-Host "Routes added:"
Write-Host "  /api/notary/[notaryId]"
Write-Host "  /audit/notary/[notaryId]"
Write-Host ""
Write-Host "No shell termination."
Write-Host ""
