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
