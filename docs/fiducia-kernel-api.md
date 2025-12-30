# Fiducia Kernel – Canonical API

This document defines the **immutable kernel contract** for TuringWealthOS.

Scope:
- Mandate (compiled, versioned, immutable)
- AuthorityDecision (permit / deny)
- EvidencePack (hashable, replayable)
- Replay verification

Non-scope:
- UX
- Portfolio construction
- Broker execution
- Optimisation
- Advice explanations

---

## Kernel Flow

Mandate ? AuthorityDecision ? EvidencePack ? Replay

Every step is deterministic.
Every step is hash-addressable.
Nothing executes inside the kernel.

---

## Endpoints (Minimal Surface)

POST /mandates/compile  
POST /mandates/{id}/activate  
POST /authority/evaluate  
GET  /evidence/{decision_id}  
POST /replay/verify
