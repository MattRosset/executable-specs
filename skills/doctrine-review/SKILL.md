---
name: doctrine-review
description: Review a diff or PR against the engineering doctrine — test power, determinism, scope discipline, and correctness. Use before merging, when the user says "doctrine review", "review this against the playbook", or after an agent produced a change that needs checking. Complements (does not replace) a general bug-hunting code review.
---

# Doctrine review

You are checking a diff against a fixed doctrine, not doing open-ended review.
Work through the checklists in order; report findings per section with file:line.
A finding must name **which rule** is violated and **what concretely goes wrong** —
"this could be cleaner" is not a doctrine finding.

## Step 0 — Understand the claim

Read the diff and state in one sentence what the change *claims* to do. Every check
below is relative to that claim. If you can't state the claim, that's finding #1.

## Checklist A — Tests (if the diff adds or modifies tests)

1. **Queries real state, never re-derives it.** A test that reimplements production
   math (projection, layout, picking) will drift and fail on environment differences.
   The app must expose a read hook; the test asks, never recomputes.
2. **No pixel/font/HUD geometry assumptions.** OS font builds differ between dev and
   CI. Positions come from real hit-testing (`elementFromPoint`, app-provided
   projection), never hard-coded coordinates.
3. **Test power: would a broken implementation fail this?** For critical logic,
   demand the anti-test — a deliberately naive path that must fail the same check.
   `toBeDefined()`, "doesn't throw", happy-path-only, and mocking the code under
   test are all findings.
4. **Blocking checks are deterministic.** Screenshots and wall-clock perf must be
   reference-only (skipped in CI or informational). A gate that can fail on a slow
   runner is a coin flip, not a gate.
5. **Asserts invariants, not incidental values.** A snapshot of a build-specific
   number breaks on the next legitimate change and trains people to update tests
   blindly.
6. **CI-failure triage: does the test log the chosen input and measured quantity?**
   If it fails in CI only, could you diagnose it from the logs alone?

## Checklist B — Gates and thresholds

7. **No threshold weakened to make the diff green.** If a gate fails, the fix is a
   separate reviewed change; relaxing the number in the same PR is the cardinal sin.
   *Carve-out:* lowering a number as part of an explicitly specced calibration (e.g.
   wiring a dormant gate to its measured value, with the measurement recorded in a
   comment and a ratchet-up-only rule) is not a weakening — the sin is lowering a
   *live* threshold to absorb a regression. Check the task spec before flagging.
8. **New behavior that matters has a gate.** If the diff's claim is "X now works,"
   ask: which deterministic check fails if X regresses next month?

## Checklist C — Scope and freeze

9. **The diff does only what its task/claim says.** Flag drive-by refactors,
   "improved" abstractions in mechanical tasks, and any touched file the claim
   doesn't explain.
10. **Frozen surface untouched.** Public APIs, gate definitions, and thresholds
    change only in explicit thaw tasks.

## Checklist D — Correctness spot-checks

11. **Boundary of the change:** what calls the changed code with what, and does every
    caller's assumption still hold? (Most bugs live one level above the diff.)
12. **Symmetric paths:** if the diff handles grow/open/add, check shrink/close/remove.
13. **Silent fallbacks:** flag `catch`-and-continue or defaulting that would mask the
    very failure the change is supposed to fix.

## Output format

```
## Claim
<one sentence>

## Findings (blocking)
- [rule N] file:line — what breaks and how

## Findings (non-blocking)
- [rule N] file:line — ...

## Verdict
merge / fix-first / needs-separate-task, one sentence why.
```

If there are zero findings, say so plainly — do not invent nitpicks to look thorough.
