from replay.hashing import canonical_hash

def replay_verify(original: dict, reproduced: dict) -> bool:
    return canonical_hash(original) == canonical_hash(reproduced)
