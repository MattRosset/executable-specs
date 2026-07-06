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

What measurable thing must hold?

- Metric: (e.g. error < 1 ms, all unauthorized → 403, deviation < 0.5 px)
- Invariant: (e.g. idempotent, monotonic, round-trip loss < 1e-6)

---

## Implementation test (must PASS)

```text
File: path/to/feature.test.ts
Describe: '…'
It: 'proper path …'
Assert: …
```

---

## Control / anti-test (must FAIL)

Model the **obvious wrong fix** or **naive algorithm**:

```text
It: 'CONTROL: naive path FAILS …'
Assert: opposite of PASS (or exceeds threshold)
```

If this test ever passes → scenario too easy or assertion wrong.

---

## Mutation sanity check

"If I remove [specific fix], this test goes red" — yes / no

---

## Fast / slow split

| | |
|---|---|
| Fast (unit) | |
| Slow (probe + E2E) | optional |

---

## Notes

- Determinism: seeded PRNG / fixed clock / no `Math.random()` in core
- No allocations in hot path (if applicable)
- Forbidden mocks: [what must not be mocked]
