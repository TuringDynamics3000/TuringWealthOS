# Fiducia Kernel – Canonical API

Flow:
Mandate ? AuthorityDecision ? EvidencePack ? Replay

Endpoints:
POST /mandates/compile
POST /authority/evaluate
GET  /evidence/{decision_id}
POST /replay/verify

The kernel is deterministic, immutable, and replay-verifiable.
