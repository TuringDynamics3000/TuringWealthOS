from replay.hashing import canonical_hash

def generate_evidence(decision: dict, mandate: dict) -> dict:
    evidence = {
        'decision': decision,
        'mandate_snapshot': mandate
    }
    evidence['evidence_hash'] = canonical_hash(evidence)
    return evidence
