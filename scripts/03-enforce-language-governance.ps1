# ============================================================
# Language Governance Enforcement (PS 5.1+ safe)
# ============================================================

$ErrorActionPreference = "Stop"

$forbidden = @(
    "recommend",
    "recommended",
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

            if ($matches) {
                $violations += $matches
            }
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

    exit 1
}

Write-Host "✅ Language governance passed."
