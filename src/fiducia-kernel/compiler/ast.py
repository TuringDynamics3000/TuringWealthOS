from dataclasses import dataclass
from typing import Any, Dict

@dataclass(frozen=True)
class Rule:
    id: str
    condition: Dict[str, Any]
    outcome: str
