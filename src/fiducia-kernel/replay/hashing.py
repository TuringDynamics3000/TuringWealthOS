import hashlib
import json

def canonical_hash(obj: dict) -> str:
    payload = json.dumps(obj, sort_keys=True, separators=(',', ':'))
    return hashlib.sha256(payload.encode()).hexdigest()
