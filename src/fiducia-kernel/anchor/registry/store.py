from typing import List
from .model import AnchorRecord

_registry: List[AnchorRecord] = []

def record(anchor: AnchorRecord):
    _registry.append(anchor)

def all_anchors() -> List[AnchorRecord]:
    return list(_registry)
