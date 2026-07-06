---
name: spec-review
description: Verify a task spec before handing it to an executor — fact-check against the live code, internal consistency, judgment quarantine, gate determinism. Use after writing a spec (yours or an agent's), before delegating a batch, or when the user says "review this spec" or "harden this spec".
---

# Spec review — the pre-handoff pass

A spec is compressed judgment, and judgment ships with bugs. The evidence that this
pass is not optional (EVALS.md): a method-written spec whose Goal said one fade
direction while its acceptance tests encoded the inverse (experiment 2); three drift
bugs in specs one day old (the case study); a spec citing the wrong UI library and
prescribing a primitive the repo already had (experiment 3). All were caught — or
would have been — by this checklist, run against the *live code*, before handoff.

You are reviewing the spec, not implementing it. Every finding cites the spec
section and the code evidence that contradicts or confirms it.

## Checklist

1. **Facts.** Every path, symbol, format, and line range the spec cites: re-verify
   against the code *now* (Glob / grep / read — never from memory). Stack facts
   count: library names, framework idioms named in failure modes must match the
   repo's actual dependencies, not the ecosystem default. For binary formats, the
   authority is the writer code — cite the writer function.
2. **Internal consistency.** Goal, function contracts, and acceptance gate must
   point the same direction. A literal implementer stops at a contradiction (that's
   the standing rule) — so a contradiction is a blocked task, found late.
3. **Judgment quarantine.** Any design decision smuggled in as if mechanical
   (an architecture choice, a contract extension, a blend-mode/algorithm pick)?
   Quarantine it: defer to a design task or resolve it now with evidence — never
   leave it fused inside an implementation task (experiment 2's control failure).
4. **Pre-resolved decisions hold.** For each decision the spec pre-resolved: does
   the code actually answer it the way the spec claims? Grep for the repo's existing
   precedent before accepting any prescribed new pattern or primitive — the spec
   writer may have answered from convention, not from this repo (experiment 3).
5. **Frozen surface: present, specific, complete.** Ask: what would the executor
   most *naturally* touch that they must not? If the frozen list doesn't name it,
   add it.
6. **Executor-decidability.** Count the open forks ("or", "pick one", "prefer",
   "if easy"). More than one bounded, rule-formed decision is a finding — each needs
   ordered options, checkable preconditions, and a STOP case, or it gets resolved
   here and now.
7. **Gate determinism.** No screenshot, wall-clock, or "looks right" as a blocking
   check; the gate names where testable code must live; anything that can fail in CI
   logs its chosen input and measured quantity.
8. **Failure modes are mined, not invented.** Did the writer search `docs/research/`
   and `git log -- <paths>` for this area's history? Repo-historical traps transfer
   only through written research (experiment 2: no in-context method reproduced the
   one failure mode that lived in repo history alone). If the mining wasn't done, do
   it now — it's the highest-value ten minutes of this review.

## Output

```
## Spec under review
<file>

## Findings
- [check N] <spec section> — what's wrong + the code evidence (file:line)

## Verdict
hand-off / fix-first — with the corrected text for each finding, not just the complaint.
```

Fix the spec in place when the fix is unambiguous; record contested changes in the
spec's provenance header. Zero findings: say so plainly and hand off.
