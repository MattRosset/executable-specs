# AGENTS.md starter — the standing rules that make agents compound

Copy this into a new repo's entry file (trim to taste) **on day one**: `AGENTS.md` for
Cursor, Codex, and most other agents; `CLAUDE.md` for Claude Code (or keep one
`AGENTS.md` and make `CLAUDE.md` a single line: `@AGENTS.md`). Fill in the
`<placeholders>`. These rules are
*push*-channel doctrine: skills only fire when invoked, but the entry file is in every
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

## How you know you're done

- One command is the local gate: `<verify command>` (lint + typecheck + unit + build).
  Run it before saying a task is done and report its actual result. Green is necessary,
  never the goal.
- If a tier of tests only runs in CI, it has a local command too: `<e2e command>`.
  A check nobody can run locally produces "passes local, fails CI" by construction.
- If the gate goes red and it isn't the code's fault, that is a bug in the gate — report
  it; do not retry until green.

## Boundaries

- Architecture rules live in lint/CI, not in this file: see `<lint config>`. Each rule's
  message says why and names the correct move — read it instead of working around it.
- A new boundary becomes a lint rule or CI check, not a paragraph here. A documented
  boundary is one an agent can cross in an afternoon across twelve files.
- Never disable a rule inline to get to green. If a rule is wrong, say so and stop.

## Precedent

- Before introducing a pattern, component, or dependency, search for how this repo
  already does it and reuse that. A second way of doing the same thing is a finding,
  not a contribution.
- The first example of anything new gets copied. If your change is that first example,
  say so in the PR so it gets reviewed as a teaching artifact.

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
  spec template): allowed paths, frozen surface, out of scope, failure modes,
  deterministic acceptance gate, habitat delta.
- A task changes only the files its spec's Allowed paths list. Needing another file is
  a stop, not a judgment call.
- A lesson goes to the highest rung that can hold it: lint/CI check, then a gate with a
  failing control, then a comment at the edit site, then a rule in this file, then a
  research doc. A trap written into a second spec belongs in the repo instead.
- Frozen surface (public APIs, thresholds, gate definitions) changes only via an
  explicit thaw task — never as a side effect.
- If reality contradicts the spec: stop and update the spec (or mark blocked); do not
  improvise around it.
- Implementing agents log every judgment call (anything the task didn't decide) to a
  NOTES file; after merge, each entry gets triaged — spec bug, executor bug, or
  doctrine gap — and doctrine gaps become template/rule edits. Untriaged entries are
  lessons paid for and thrown away.

## Docs map

- `docs/decisions/` — ADRs (architecture decisions).
- `docs/research/` — investigations + root-cause writeups.
- `docs/agent-tasks/` — executable task specs.
