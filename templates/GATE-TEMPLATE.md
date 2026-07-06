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
| Environment | unit / browser / built `dist` | |

---

## PASS criteria (machine-enforceable)

| Check | Threshold | Command / probe |
|-------|-----------|-----------------|
| Primary | e.g. `< 0.5 px`, `< 1 ms`, `100% 403` | `npm test -- gate-foo` |
| Secondary | | |
| Slow gate (optional) | same threshold | `e2e/gate-foo.spec.ts` |

---

## CONTROL — anti-test (must FAIL)

**Bug class:** [one sentence]

**Naive implementation:** [describe the wrong approach the control models]

**Assertion:** control result must **violate** the PASS threshold.

> If the control ever passes, the test lost power — **fix the test, not the gate**.

---

## Fast vs slow

| Layer | File / mode | Runs |
|-------|-------------|------|
| Fast | `test/gate-foo.test.ts` | every `verify` |
| Slow | `?debug=foo` + `e2e/gate-foo.spec.ts` | CI e2e job |

---

## Self-measuring probe (if slow gate)

- URL flag: `?debug=____`
- Warm-up: discard first N frames / requests
- Export: `window.__fooResult = { … }`
- E2E: read result only; no complex measurement in Playwright

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
- Prior art (cosmos TASK-006 pattern):
