# TuringWealthOS

**TuringWealthOS** is a **fiduciary operating system** for regulated wealth decisions.

It is not a robo-advisor.
It is not a portfolio platform.
It is not a broker wrapper.

It is a **deterministic authority and proof kernel** that turns discretionary wealth actions into
**provable, replayable, regulator-grade operations**.

---

## Core Insight

Modern wealth systems fail not because they cannot trade, but because they cannot **prove**:

- why a decision was made
- whether it was authorised
- whether it complied with a mandate
- whether the evidence can be reproduced later

TuringWealthOS makes **authority and evidence first-class primitives**.

---

## Architectural Model

    Applications / UX (non-authoritative)
            ▲
    Adapters (broker, custody, reporting)
            ▲
      Fiducia Kernel (authoritative)

Only the **Fiducia Kernel** can authorise actions.

---

## Fiducia Kernel Flow

    Mandate → AuthorityDecision → EvidencePack → Replay → Anchor

Each step is:
- deterministic
- immutable
- hash-addressable
- replay-verifiable

---

## Kernel Pillars

### Mandates
Compiled, versioned, immutable contracts.
No implicit discretion. No mutation.

### Authority Decisions
Pure functions that return **PERMIT** or **DENY** with explicit reason codes.

### Evidence Packs
Structured proof explaining *why* an outcome occurred.
Evidence is not logging.

### Replay Verification
Identical inputs must reproduce identical outcomes.
Replay divergence = invalid decision.

### Public Anchoring
Evidence hashes are Merkle-batched and anchored to a public network
(e.g. RedBelly) for external, time-stamped proof.

---

## Repository Structure

    src/fiducia-kernel/
    schemas/
    docs/
    .github/
    CONSTITUTION.md

---

## What This Is Not

- No portfolio optimisation
- No asset selection
- No market prediction
- No CRM
- No broker replacement
- No UX engagement logic

Those live **outside** the kernel.

---

## Determinism & Compliance

- No clocks
- No randomness
- No hidden state
- Every decision emits evidence
- Every decision is replayable
- Evidence is externally verifiable

This is what regulators actually require.

---

## Governance

This repository is governed by **CONSTITUTION.md**.

Kernel invariants are enforced by CI.
Violations are rejected by design.
