# Test spec — [feature / module name]

**Not a gate** unless promoted to `GATE-TEMPLATE.md`.  
Use this for individual tests that must have **power**.

---

## Bug class

What specific mistake are we trying to detect?

> Example: "Permission checked only on login, not on subsequent requests with stale JWT."

---

## Stress scenario

Inputs that hurt — not the happy path.

| Field | Value | Rationale |
|-------|-------|-----------|
| | | |

---

## Property under test

What measurable thing must hold? One of these is enough; a number is not required.

- Metric: (e.g. error < 1 ms, deviation < 0.5 px)
- Invariant: (e.g. idempotent, monotonic, round-trip loss < 1e-6, all unauthorized → 403)
- Conservation, for code that combines, partitions, or migrates data: (total out ==
  total in, each element lands exactly once, order-independent)

---

## Implementation test (must PASS)

```text
File: path/to/feature.test.ts
Calls: <the production function / route, by name and path> — not a copy of its logic
Describe: '…'
It: 'proper path …'
Assert: …
```

If the production logic is inline and can't be called from a test, the first deliverable
is extracting it. A test that re-types the formula tests the copy.

---

## Control / anti-test (must FAIL)

Model the **obvious wrong fix** or **naive algorithm**:

```text
It: 'CONTROL: naive path FAILS …'
Assert: opposite of PASS (or exceeds threshold)
```

If this test ever passes → scenario too easy or assertion wrong.

---

## Seen red (run it — don't reason about it)

Remove the fix (or apply the mutant: `<the one-line change>`), run the test, paste the
failing output:

```text
Command:
Output (the failing assertion, with its measured value):
```

"This would fail without the fix" is a prediction. A test nobody has seen fail has
unknown power — including the day it is written.

---

## Fast / slow split

| | |
|---|---|
| Fast (unit) | |
| Slow (integration / E2E) | optional |

---

## Notes

- Determinism: seeded PRNG / fixed clock / pinned adaptive inputs — no unseeded
  randomness or wall-clock in the assertion
- On failure, logs the chosen input and the measured quantity
- Forbidden mocks: [what must not be mocked — at minimum, the code under test]
- Domain constraints the test must not violate: [e.g. no allocations in a hot path, no
  network, no shared database state — or none]
