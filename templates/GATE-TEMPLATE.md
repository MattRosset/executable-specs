# GATE — [Phase / milestone name]

**ID:** GATE-[NNN]  
**Status:** pending | done | blocked  
**Blocks:** [what cannot start until this is green]  
**Owner:** [human/agent lane]

---

## Fatal risk

If **[X]** is wrong, **[Y]** is wasted / the project fails at week N.

One sentence. Be specific.

---

## Fixed scenario

**Do not simplify these numbers/inputs without explicit review.**

| Parameter | Value | Why |
|-----------|-------|-----|
| Input A | | Stresses the bug class |
| Input B | | |
| Duration / iterations | | |
| Environment | unit / integration / built artifact | |
| Pinned adaptive inputs | e.g. quality tier, pool size, retry count, clock, PRNG seed | Anything the machine would otherwise steer is held constant — unconditionally, not `if (CI)` |

**Production path:** [the function / route / shader the gate exercises] — the same code
production runs, not a model of it. A gate on a parallel path stays green while the real
one is broken.

---

## PASS criteria (machine-enforceable)

A threshold is a number **or an invariant**. Where the domain has no natural number, the
contract plays that role: idempotency, tenant scope, conservation (nothing dropped,
nothing duplicated), a state machine's forbidden transitions.

| Check | Threshold or invariant | Command / probe |
|-------|------------------------|-----------------|
| Primary | e.g. `< 0.5 px`, `< 1 ms`, every cross-tenant id → `403`, second call returns the same row, `count(out) == count(in)` | `npm test -- gate-foo` |
| Secondary | | |
| Work metric (required beside any speed/size metric) | e.g. items processed, points drawn, bytes served `> 0` and as expected | same run |
| Slow gate (optional) | same threshold | `e2e/gate-foo.spec.ts` |

**On failure, the check logs:** the chosen input and the measured quantity — enough to
triage a CI-only failure without a local reproduction.

---

## Scope (who the gate covers)

**Computed by:** [glob or scan that finds everything at risk, e.g. `lib/**` modules that write a tenant table]

**Exceptions:** [empty, or one line per entry with its reason]

> Not only a hand-written list of what is covered: if a registry is needed (per-item
> numbers), a computed scan must cross-check it. Code written after this gate must land
> inside it without anyone editing the gate. Check: a new file that violates the rule,
> in a new directory, turns CI red.

---

## CONTROL — anti-test (must FAIL)

**Bug class:** [one sentence]

**Naive implementation:** [describe the wrong approach the control models]

**Assertion:** control result must **violate** the PASS threshold.

**Observed (fill in after running, don't predict):**

| Path | Measured | Verdict |
|------|----------|---------|
| Proper | | PASS |
| Naive control | | FAIL |

> If the control ever passes, the test lost power — **fix the test, not the gate**.
> A control that was never run is a hypothesis about the test, not evidence of its power.

---

## Fast vs slow

| Layer | File / mode | Runs |
|-------|-------------|------|
| Fast | `test/gate-foo.test.ts` | every `verify` |
| Slow | integration / E2E on the built artifact | CI job — and a local command: `…` |

---

## Self-measuring probe (optional — only if the slow gate needs the running system)

The system measures itself; the test runner only reads the result.

- Entry point: a debug flag, diagnostic endpoint, or CLI switch (browser apps:
  `?debug=____`) — zero cost when absent
- Warm-up: discard first N frames / requests
- Export: a structured result object (browser apps: `window.__fooResult = { … }`)
- Runner: read the result and assert; no measurement logic in the test

---

## Failure doctrine

1. Gate task status → **blocked**
2. Note: `"[gate name] failed"`
3. Fix in **separate reviewed bug task** — not in the gate PR
4. **Do not relax thresholds** without human sign-off + deviation note

---

## Re-asserted by

- [ ] GATE-[later] re-runs this command in CI
- [ ] Phase [N] integration gate includes this check

---

## Human checklist (layer 3)

Manual items CI cannot judge:

- [ ] …
- [ ] Demo recording captured

---

## References

- Architecture / ADR:
- Research doc for the bug class (if it already happened):
- Prior art (an earlier gate in this repo to copy the shape from):
