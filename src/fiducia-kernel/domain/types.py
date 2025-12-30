# Fiducia Kernel – Domain Types (Authoritative)

from dataclasses import dataclass
from typing import List
from uuid import UUID
from datetime import datetime

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
    outcome: str
    decision_hash: str

@dataclass(frozen=True)
class EvidencePack:
    evidence_id: UUID
    decision_id: UUID
    evidence_hash: str
