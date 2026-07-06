# CLAUDE.md starter — the standing rules that make agents compound

Copy this into a new repo's `CLAUDE.md` (trim to taste) **on day one**. These rules are
*push*-channel doctrine: skills only fire when invoked, but CLAUDE.md is in every
agent's context every session. This is how a repo starts teaching the agents that work
on it — measured effect in [EVALS.md](../EVALS.md): unaided agents in a repo carrying
these rules beat predictions on doctrine adherence in both experiments.

---

## Write it down (non-negotiable)

1. **Every nontrivial investigation ends in a research doc** — `docs/research/<slug>.md`:
   symptom (as a measurement) → experiments run (with the numbers) → mechanism (one
   sentence that explains every observation) → fix → what would have caught it earlier.
   Findings that live only in a chat are lost; the next agent session reads the repo,
   not your history.
2. **Findings during a task go to `docs/research/`; scope creep goes to a new task
   file** — never into the current diff.
3. **Architecture decisions get an ADR** in `docs/decisions/` — one page: context,
   decision, consequences. The code shows *what*; only the ADR remembers *why the
   alternatives lost*.
4. **Shipped work updates its ledger/progress row in the same change.** A tracking
   table that says `pending` for shipped work is drift no test suite catches — in
   EVALS experiment 3 it was the single biggest gap a spec-less agent left, and this
   one standing line closes it for free.
5. **Encode contracts as code comments at the load-bearing site.** A constant whose
   value is load-bearing (a shipped fix, a calibrated threshold) carries a comment
   saying so and pointing at the research doc. This is what lets a future agent — or a
   prompt-only one — avoid breaking it without reading anything else.

## Testing (the short form — see the testing doctrine for the full contract)

- Tests query real state; never re-derive production math in a test.
- CI gates deterministic proxies only; screenshots and wall-clock perf are
  reference-machine information, never blocking.
- For critical logic, the anti-test: a deliberately naive path must FAIL the same
  check. If the control passes, fix the test, never the threshold.
- A CI-only failure must be triagable from logs alone — log the chosen input and the
  measured quantity.

## Tasks

- Work larger than a one-line fix gets a spec (`docs/agent-tasks/`, per the
  spec template): frozen surface, out of scope, failure modes, deterministic
  acceptance gate.
- Frozen surface (public APIs, thresholds, gate definitions) changes only via an
  explicit thaw task — never as a side effect.
- If reality contradicts the spec: stop and update the spec (or mark blocked); do not
  improvise around it.

## Docs map

- `docs/decisions/` — ADRs (architecture decisions).
- `docs/research/` — investigations + root-cause writeups.
- `docs/agent-tasks/` — executable task specs.
