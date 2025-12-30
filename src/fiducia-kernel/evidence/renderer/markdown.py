from datetime import datetime

def render_markdown(evidence: dict) -> str:
    decision = evidence['decision']
    mandate = evidence['mandate_snapshot']

    lines = []
    lines.append('# Fiducia Evidence Pack')
    lines.append('')
    lines.append('## Decision')
    lines.append(f\"- Outcome: **{decision['outcome']}**\")
    lines.append(f\"- Mandate ID: {decision['mandate_id']}\")
    lines.append(f\"- Mandate Version: {decision['mandate_version']}\")
    lines.append('')
    lines.append('## Reasons')
    for r in decision.get('reasons', []):
        lines.append(f\"- {r['rule_id']}: {r['outcome']}\")
    lines.append('')
    lines.append('## Mandate Snapshot')
    lines.append(f\"- Compiled Hash: {mandate['compiled_hash']}\")
    lines.append('')
    lines.append('## Integrity')
    lines.append(f\"- Evidence Hash: {evidence['evidence_hash']}\")
    lines.append(f\"- Generated At: {datetime.utcnow().isoformat()}Z\")

    return '\\n'.join(lines)
