from dataclasses import dataclass
from uuid import UUID
from datetime import datetime
from typing import List, Dict

@dataclass(frozen=True)
class Mandate:
    mandate_id: UUID
    version: int
    status: str
    compiled_hash: str

@dataclass(frozen=True)
class AuthorityDecision:
    decision_id: UUID
    mandate_id: UUID
    mandate_version: int
    outcome: str
    reasons: List[Dict[str, str]]
    decision_hash: str

@dataclass(frozen=True)
class EvidencePack:
    evidence_id: UUID
    decision_id: UUID
    evidence_hash: str
