# Testing Doctrine — Gates, Power, and Anti-Tests

> Generado desde engineering-playbook/TESTING-DOCTRINE.md — no editar acá; editá el
> original y re-exportá (ver [PROPAGATION.md](../PROPAGATION.md)).

This is not a testing framework guide. It is a **philosophy and contract** for tests
that actually catch bugs — especially in AI-assisted or parallel development, where
the implementer optimizes for green.

Case study throughout: [cosmos](https://github.com/MattRosset/cosmos), where this
doctrine gates a 5M-star WebGL renderer in CI.

---

## 1. Core belief

> A green test suite is not proof of correctness. It is only proof that **what you
> measured** still holds.

**Strong tests** answer two questions:

1. Does the correct implementation pass a **hard scenario** with a **numeric threshold**?
2. Would an **obviously wrong** implementation **fail** the same check? (anti-test / control)

If you only have (1), you might have false confidence.

---

## 2. Vocabulary

| Term | Meaning |
|------|---------|
| **Gate** | A milestone test that **closes a phase**. Fixed scenario, numeric threshold, failure blocks progress. |
| **Anti-test / control** | A deliberately naive or broken path that **must fail** the gate. Proves the test has *power*. |
| **Test power** | Ability to detect a specific bug class. If the control passes, fix the **test**, not the threshold. |
| **Fast gate** | Cheap regression (unit/property test, no browser/GPU). Runs every commit. |
| **Slow gate** | Expensive truth (E2E, GPU, Lighthouse). Runs in CI on built artifacts. |
| **Self-measuring probe** | App mode (`?debug=…`) that runs the scenario and exports `window.__*Result`. E2E only reads the result. |
| **Re-asserted gate** | A later phase re-runs earlier gates so promises do not rot. |
| **Gate failure doctrine** | Gate task → `blocked`. Fix in a **separate reviewed bug task**. Never weaken the threshold in the gate PR. |

---

## 3. What makes a test weak (common failures)

| Weak pattern | Why it lies |
|--------------|-------------|
| `expect(x).toBeDefined()` | Passes on garbage |
| Happy-path only, tiny inputs | Bug hides at scale/edges |
| Mocks the code under test | You test the mock |
| Only asserts "does not throw" | Crashes are not the only failure |
| Correct path passes, no control | You don't know if the test would catch the bug |
| Threshold relaxed to green | Gate becomes decoration |
| Scenario "simplified" to pass | You stopped measuring the real risk |
| Gate exercises a **different code path** than production | Green while the real path is broken (cosmos: jitter probe ran the f64 CPU subtract; the bug lived in the shader's f32 sum) |
| Metric has a **floor/ceiling** that hides the cost | A vsync-paced FPS read identical numbers for a 12× GPU-cost difference; measure what the instrument reads on a known-idle vs known-heavy case first |
| Speed metric with **no work metric beside it** | An empty scene / dead pipeline benchmarks as "fast" trivially; log drawn points / bytes served next to the timing |

---

## 4. What makes a test strong (five requirements)

For any **critical** behavior (money, auth, precision, sync, safety):

1. **Named bug class** — one sentence: *"absolute positions stored in f32 before camera subtract"*
2. **Stress scenario** — inputs that **hurt** (large numbers, race, stale cache, 8 kpc not 0.001)
3. **Measurable property** — a number or invariant, not vibes (`< 0.5 px`, `< 1 ms`, `403`)
4. **Anti-test** — naive/broken implementation **must fail** the same gate
5. **Mutation check** — mentally break the fix; the test **must** go red

---

## 5. Gate anatomy (copy this structure)

Every gate document should include:

```markdown
## GATE — [phase/milestone name]

**Fatal risk:** If X is wrong, Y is wasted.
**Fixed scenario:** [exact inputs — do not simplify]
**PASS:** [numeric threshold]
**CONTROL (must FAIL):** [naive bug class]
**Fast gate:** [command + test file]
**Slow gate:** [optional E2E / probe command]
**On failure:** Block gate task; fix in separate bug task; do not relax threshold without sign-off.
**Re-asserted by:** [later gates that re-run this]
```

Template file: [`templates/GATE-TEMPLATE.md`](../templates/GATE-TEMPLATE.md)

---

## 6. Test + anti-test pattern

Run **both paths** on the **same inputs** in one test file:

```
proper  → implementation under test     → must PASS gate
naive   → obvious broken alternative    → must FAIL gate
```

**Rule:** If the control ever passes, the scenario is too easy or the assertion is wrong.
**Fix the test, never the gate threshold** (unless a documented refinement — see §9).

**For code that combines, partitions, or migrates data**, the natural anti-test is a
**conservation-invariant**: nothing dropped, nothing duplicated, order-independent
(total out == total in, each element lands exactly once). Prove the failure with a
measured before/after table, then gate the invariant itself.
**Cosmos reference:** BUG-8 combine push-down (dropped the shallower catalog on approach).

**Real example:** [cosmos `jitter.test.ts`](https://github.com/MattRosset/cosmos/blob/main/packages/coords/test/jitter.test.ts)
- `proper`: f64 subtract, then `Math.fround`
- `naive`: `Math.fround` absolute positions, then subtract in f32
- PASS: max screen deviation `< 0.5 px` over 300 frames

**CRUD example (no numeric threshold — the invariant plays that role):** a
"revert payment to pending" service, gated by its contract instead of a number
(measured working in EVALS experiment 3):
- *idempotency*: reverting an already-`due` period **returns the row** — the naive
  implementation throws or double-writes, and fails this case
- *tenant scope*: a cross-gym period id **must throw** — the naive implementation
  (query by id alone) silently succeeds, and fails this case
- *no silent no-op*: a missing id returns an **error state**, never a quiet success
Auth, money, idempotency, and state machines are CRUD's `< 0.5 px`. If you think
your domain has no gateable invariants, you haven't named your bug classes yet.

---

## 7. Two-layer gates (fast + slow)

| Layer | Purpose | When |
|-------|---------|------|
| **Fast** | Catch regressions cheaply | Every `verify` / every commit |
| **Slow** | Prove real pipeline (GPU, browser, network) | CI e2e job on `dist` |

Same **scenario** and **threshold** where possible. Different **machinery**.

---

## 8. Self-measuring probes (E2E stays dumb)

Put measurement logic **in the app** behind a URL flag:

1. `?debug=<name>` — zero cost when flag absent
2. Script runs fixed scenario (warm-up frames, then measure)
3. Publishes `window.__<name>Result = { …numeric fields }`
4. E2E runner: `goto`, `waitForFunction`, `evaluate`, assert threshold

**Cosmos:** [`JitterProbe.tsx`](https://github.com/MattRosset/cosmos/blob/main/apps/web/src/scene/JitterProbe.tsx) + [`e2e/tests/jitter.spec.ts`](https://github.com/MattRosset/cosmos/blob/main/e2e/tests/jitter.spec.ts)

Probe checklist:

- [ ] Isolated (no unrelated subsystems)
- [ ] Warm-up frames before measure
- [ ] Fixed scenario numbers match fast gate
- [ ] No data load / no user input required
- [ ] Structured result object for automation

**Corollary — tests query real state, never re-derive it.** A test that reimplements
production math (projection, picking, layout) drifts and leaks environment details
(OS font builds, GPU rasterization) into the assertion. Expose a read hook on the app
and *ask* it. In cosmos, replacing the tests' parallel camera model with query hooks
(`__cosmos.pickAt`, `__cosmos.projectToScreen`) ended a months-long flaky-e2e era —
the [taxonomy that proved it](https://github.com/MattRosset/cosmos/blob/main/docs/research/e2e-ci-flakiness-rootcause-and-query-hook.md)
classified 16 failures at 3:1 environment-coupling over real bugs.

---

## 8b. Query hooks — ask the app, don't re-derive it

When a test needs to know something the app already computes (a projected position,
what a click would select, a layout box, a running total), expose a **read-only query
hook** on the production code path and have the test *ask* — never re-implement the
computation inside the test.

A test-side parallel model charges two recurring taxes:

- **Maintenance:** every production change forces a hand-resync of the model — the test
  edit catches nothing, it just tracks.
- **Environment coupling:** the model bakes in machine details (font geometry, DPR,
  pixel boxes) that differ between dev and CI, producing "passes local, fails CI".

Pattern: `window.__app.queryX(...)` registered from the same scope that owns the real
objects; returns data, causes no side effect. For hit-testing, combine with the real
DOM (`document.elementFromPoint`) instead of hard-coded boxes.

**Exception:** if the test's purpose is to validate that computation itself, the oracle
must be independent (unit test with known cases) — asking the app would be circular.

**Cosmos:** `pickAt` / `projectToScreen` on `window.__cosmos` replaced a ~150-line
parallel camera model that was the source of nearly all CI-only flake.

---

## 8c. Pin the adaptive input — deterministic gates

A gate is only deterministic if it holds constant every input the *machine* steers.
If the measured quantity sits downstream of an adaptive controller — a quality tier
chosen by FPS, an autoscaled pool size, a timeout-driven retry count — pin that
controller to a constant for the measurement. Otherwise the gate measures how fast
the runner is, not the code (the incidental value CI gates forbid).

- Pin it **unconditionally**, not `if (CI)` — a CI-only pin recreates the local-vs-CI
  divergence you're trying to kill. The probe is a test fixture; the constant holds
  everywhere.
- **Exception:** when the gate *is* the test that the controller steps correctly, the
  adaptive state is the subject — test that in a deterministic unit with synthetic
  inputs, not inside the integration gate.

**Detection → mapping → integration are three tests, not one.** Cover "does the
controller step right?" and "does each mode yield the right value?" in units; the
integration gate *assumes* them and asserts only its invariant, with the mode pinned.
Letting an integration gate re-exercise a machine-adaptive detection layer is what
makes it flaky.

**Corollary:** turning a constant into an adaptive parameter invalidates every
baseline recorded under the old constant. And a comment claiming "branch X protects
gate Y" is not proof gate Y exercises branch X — confirm the gate's path first.

**Cosmos:** a procgen draw-cap became tier-aware; a budget gate let the live
PerformanceMonitor pick the tier, so CI's software renderer stepped it down mid-flight
and the near-Sol peak blew the baseline. Fix: pin the probe to a fixed tier.

---

## 9. Gate refinement ≠ threshold relaxation

Sometimes the **test** is wrong, not the code:

- Example: comparing visibility to `3 × median` when the median collapses to ~0 on
  empty frames.
- **Resolution:** change the yardstick, document it in the gate task with a deviation
  note, keep the user-visible intent.

**Not allowed:** silently changing `0.5` → `5` to green CI.

Precedent requires: evidence, human sign-off, ADR or task deviation note.

---

## 10. Three layers of "done"

| Layer | Owner | Examples |
|-------|-------|----------|
| **1 — Automated CI** | Machine | Unit gates, E2E probes, Lighthouse, bundle size |
| **2 — Re-asserted** | Machine | Prior phase gates still green in later CI |
| **3 — Human checklist** | Human | "Click the star, the flight feels smooth", demo recording |

CI cannot replace layer 3 for subjective UX. Humans own feel; machines own regressions.
And CI gates **deterministic proxies only**: screenshots and wall-clock performance
are reference-machine information, never blocking checks.

---

## 11. Designing a test (worksheet)

Before writing code, fill in:

```
Bug class:
Stress scenario (uncomfortable on purpose):
Property to measure:
PASS threshold:
Naive control (must FAIL):
Fast gate location:
Slow gate / probe (if needed):
What happens on failure:
```

Template: [`templates/TEST-SPEC-TEMPLATE.md`](../templates/TEST-SPEC-TEMPLATE.md)

---

## 12. Reviewing tests (checklist)

When reviewing a PR or agent output:

- [ ] Is there a **named bug class**, not just "it works"?
- [ ] Would **small/easy inputs** let a broken impl pass?
- [ ] Is there an **anti-test** or equivalent mutation argument?
- [ ] Are thresholds **numeric** and tied to product risk?
- [ ] For gates: is failure doctrine clear (block + separate fix)?
- [ ] For E2E: is the runner dumb and the app self-measuring?
- [ ] Does the gate exercise the **same code path as production**, or a model of it?
- [ ] Does a later gate **re-assert** this promise?
- [ ] If it fails in CI only, is it triagable from logs alone (input + measured
      quantity logged)?

---

## 13. When to use this doctrine

| Use gates + anti-tests | Skip (for now) |
|------------------------|----------------|
| Critical path (auth, money, precision, sync) | Throwaway weekend spike |
| Multi-phase / multi-agent projects | Single 200-line script |
| Bugs that are expensive if found late | Pure UI copy with no invariant |
| Flaky or "sometimes" failures | — (determinism first) |

Start with **one gate** on the riskiest decision. Add more after it passes.

---

## 14. One-line summary

*"If the naive path also passes, the test is lying — fix the test, not the gate."*
