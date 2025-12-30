from replay.hashing import canonical_hash

def evaluate_authority(mandate: dict, action: dict, reasons: list) -> dict:
    outcome = 'PERMIT'
    for r in reasons:
        if r.get('deny'):
            outcome = 'DENY'
    decision = {
        'mandate_id': mandate['mandate_id'],
        'mandate_version': mandate['version'],
        'action': action,
        'outcome': outcome,
        'reasons': reasons
    }
    decision['decision_hash'] = canonical_hash(decision)
    return decision
