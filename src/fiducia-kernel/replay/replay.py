from hashing import canonical_hash

def replay(original: dict, reproduced: dict) -> bool:
    return canonical_hash(original) == canonical_hash(reproduced)
