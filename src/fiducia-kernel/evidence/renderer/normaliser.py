import json
from replay.hashing import canonical_hash

def normalise_evidence(evidence: dict) -> dict:
    # Canonical ordering for deterministic rendering
    return json.loads(
        json.dumps(evidence, sort_keys=True, separators=(',', ':'))
    )

def verify_integrity(evidence: dict) -> bool:
    clone = dict(evidence)
    supplied_hash = clone.pop('evidence_hash', None)
    return canonical_hash(clone) == supplied_hash
