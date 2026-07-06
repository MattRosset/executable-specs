# Testing Doctrine — Gates, Power, and Anti-Tests

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

**Real example:** [cosmos `jitter.test.ts`](https://github.com/MattRosset/cosmos/blob/main/packages/coords/test/jitter.test.ts)
- `proper`: f64 subtract, then `Math.fround`
- `naive`: `Math.fround` absolute positions, then subtract in f32
- PASS: max screen deviation `< 0.5 px` over 300 frames

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
