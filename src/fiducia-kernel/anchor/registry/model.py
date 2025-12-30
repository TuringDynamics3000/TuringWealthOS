from dataclasses import dataclass
from typing import List
from uuid import UUID
from datetime import datetime

@dataclass(frozen=True)
class AnchorRecord:
    anchor_id: UUID
    merkle_root: str
    evidence_hashes: List[str]
    network: str
    tx_reference: str
    anchored_at: datetime
