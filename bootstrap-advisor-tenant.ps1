# ============================================================
# TuringWealthOS — Advisor Tenant Bootstrap (ONE SHOT)
# ============================================================

$ErrorActionPreference = "Stop"

Write-Host "BOOTSTRAPPING ADVISOR TENANT (PRODUCTION)"

$tenantRoot = "tenants\advisor"

$dirs = @(
    "$tenantRoot\domain",
    "$tenantRoot\workflows",
    "$tenantRoot\governance",
    "$tenantRoot\audit",
    "$tenantRoot\policies",
    "$tenantRoot\tests"
)

foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
        Write-Host "Created $dir"
    }
}

@"
Advisor Tenant (Production)

- Tenant = AFSL-holding advice business
- Adviser is sole decision authority
- System enforces evidence, audit, and process
"@ | Set-Content "$tenantRoot\README.md" -Encoding UTF8

$stateMachine = @{
    states = @("Draft","Reviewed","Authorised","Issued")
    transitions = @(
        @{ from="Draft"; to="Reviewed"; requires=@("facts_complete","consent_present") },
        @{ from="Reviewed"; to="Authorised"; requires=@("adviser_signature","decision_log_complete") },
        @{ from="Authorised"; to="Issued"; requires=@("artefact_generated") }
    )
}

$stateMachine |
  ConvertTo-Json -Depth 6 |
  Set-Content "$tenantRoot\domain\advicefile.states.json" -Encoding UTF8

$decisionSchema = @{
    type = "DecisionEvent"
    required = @(
        "eventId","adviserId","label",
        "rationale","evidenceRefs",
        "timestamp","immutableHash"
    )
}

$decisionSchema |
  ConvertTo-Json -Depth 5 |
  Set-Content "$tenantRoot\domain\decision-event.schema.json" -Encoding UTF8

& ".\scripts\03-enforce-language-governance.ps1"

Write-Host "✅ ADVISOR TENANT BOOTSTRAPPED SUCCESSFULLY"
