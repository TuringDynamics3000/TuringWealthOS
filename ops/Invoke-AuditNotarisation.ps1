# ============================================================
# Invoke-AuditNotarisation.ps1
# Immutable Audit Notarisation (Hash Anchoring)
# PowerShell-only | Windows-safe | Non-terminating
# ============================================================

$ErrorActionPreference = "Stop"

# ------------------------------------------------------------
# ARGUMENT HANDLING (BOM / parser safe)
# ------------------------------------------------------------

if ($args.Count -lt 1) {
    throw "Usage: Invoke-AuditNotarisation.ps1 <AuditPackName>"
}

$AuditPackName = $args[0]

# ------------------------------------------------------------
# ROOT PATHS (EXPLICIT)
# ------------------------------------------------------------

$RepoRoot         = "C:\Users\mjmil\TuringDeploy\TuringWealthOS"
$AuditExportsRoot = Join-Path $RepoRoot "audit_exports"
$NotaryRoot       = Join-Path $RepoRoot "audit_notary"

$AuditPackPath = Join-Path $AuditExportsRoot $AuditPackName
$UtcNow = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

Write-Host "IMMUTABLE AUDIT NOTARISATION"
Write-Host "Audit pack: $AuditPackPath"
Write-Host "Timestamp:  $UtcNow"

# ------------------------------------------------------------
# PRECONDITIONS
# ------------------------------------------------------------

if (!(Test-Path $AuditPackPath)) {
    throw "Audit pack not found: $AuditPackPath"
}

if (!(Test-Path $NotaryRoot)) {
    New-Item -ItemType Directory -Path $NotaryRoot | Out-Null
}

# ------------------------------------------------------------
# HASH COLLECTION
# ------------------------------------------------------------

$Files = Get-ChildItem $AuditPackPath -Recurse -File | Sort-Object FullName
$LeafHashes = @()

foreach ($file in $Files) {
    $hash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash
    $LeafHashes += $hash
}

function Get-Sha256Hex {
    param ([string] $Input)
    $bytes = [System.Text.Encoding]::UTF8.GetBytes($Input)
    $sha   = [System.Security.Cryptography.SHA256]::Create()
    $hash  = $sha.ComputeHash($bytes)
    ($hash | ForEach-Object { $_.ToString("x2") }) -join ""
}

function Get-MerkleRoot {
    param ([string[]] $Hashes)
    if ($Hashes.Count -eq 1) { return $Hashes[0] }

    $Next = @()
    for ($i = 0; $i -lt $Hashes.Count; $i += 2) {
        $pair = if ($i + 1 -lt $Hashes.Count) {
            $Hashes[$i] + $Hashes[$i + 1]
        } else {
            $Hashes[$i] + $Hashes[$i]
        }
        $Next += Get-Sha256Hex $pair
    }
    Get-MerkleRoot $Next
}

$MerkleRoot = Get-MerkleRoot $LeafHashes

# ------------------------------------------------------------
# NOTARISATION OUTPUT
# ------------------------------------------------------------

$NotaryId  = "NOTARY-" + (Get-Date -Format "yyyyMMddHHmmss")
$NotaryDir = Join-Path $NotaryRoot $NotaryId
New-Item -ItemType Directory -Path $NotaryDir | Out-Null

Set-Content "$NotaryDir\merkle_root.txt" $MerkleRoot
Set-Content "$NotaryDir\timestamp_utc.txt" $UtcNow

$GitHead = git -C $RepoRoot rev-parse HEAD 2>$null
if ($GitHead) {
    Set-Content "$NotaryDir\git_anchor.txt" $GitHead
}

Write-Host "Merkle root: $MerkleRoot"
Write-Host "Notarised at: $NotaryDir"
Write-Host "✓ IMMUTABLE AUDIT NOTARISATION COMPLETE"
