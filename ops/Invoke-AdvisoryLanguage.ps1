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
