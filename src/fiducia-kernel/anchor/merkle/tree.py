import hashlib
from typing import List

def _hash(x: str) -> str:
    return hashlib.sha256(x.encode()).hexdigest()

def merkle_root(hashes: List[str]) -> str:
    if not hashes:
        raise ValueError('No hashes to anchor')

    level = sorted(hashes)

    while len(level) > 1:
        next_level = []
        for i in range(0, len(level), 2):
            left = level[i]
            right = level[i+1] if i+1 < len(level) else left
            next_level.append(_hash(left + right))
        level = next_level

    return level[0]
