from uuid import uuid4
from datetime import datetime
from merkle.tree import merkle_root
from registry.model import AnchorRecord
from registry.store import record
from adapters.redbelly import anchor_to_redbelly

def anchor_batch(
    evidence_hashes: list,
    network: str,
    endpoint: str
) -> AnchorRecord:

    root = merkle_root(evidence_hashes)
    tx_ref = anchor_to_redbelly(root, endpoint)

    anchor = AnchorRecord(
        anchor_id=uuid4(),
        merkle_root=root,
        evidence_hashes=evidence_hashes,
        network=network,
        tx_reference=tx_ref,
        anchored_at=datetime.utcnow()
    )

    record(anchor)
    return anchor
