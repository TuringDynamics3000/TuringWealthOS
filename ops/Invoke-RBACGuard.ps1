param($Role, $Action)

$rbac = Get-Content policies\rbac.json | ConvertFrom-Json

if (-not $rbac.$Role) {
    throw "Unknown role: $Role"
}

if ($rbac.$Role -notcontains $Action) {
    throw "RBAC violation: $Role cannot $Action"
}

Write-Host "✓ RBAC permitted"
