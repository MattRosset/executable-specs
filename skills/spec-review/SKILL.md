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
   point the same direction. A spec carrying a stop-at-contradictions clause turns a
   contradiction into a *blocked task, found late*. If the repo has no such clause, the
   contradiction instead gets improvised around silently — which is worse, and invisible.
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
   add it. **Allowed paths** get the same scrutiny from the other side: every file the
   Deliverables name matches a glob (expand the globs and look — a glob that matches
   nothing is a path typo); no glob is wider than the task needs (`src/**` on a
   one-file task is not a scope); test files, NOTES.md, and the ledger row are covered.
6. **Executor-decidability.** Count the open forks ("or", "pick one", "prefer",
   "if easy"). More than one bounded, rule-formed decision is a finding — each needs
   ordered options, checkable preconditions, and a STOP case, or it gets resolved
   here and now.
7. **Gate determinism.** No screenshot, wall-clock, or "looks right" as a blocking
   check; the gate names where testable code must live; anything that can fail in CI
   logs its chosen input and measured quantity.
8. **Failure modes are mined, not invented.** Did the writer search `docs/research/`
   — or the repo's equivalent — and `git log -- <paths>` for this area's history? Repo-historical traps transfer
   only through written research (experiment 2: no in-context method reproduced the
   one failure mode that lived in repo history alone). If the mining wasn't done, do
   it now — it's the highest-value ten minutes of this review.
9. **The spec is a delta, and it pays the repo.** Two directions:
   - *Restating:* does the spec re-explain something a lint rule, gate, or existing
     precedent already settles? Replace the prose with a pointer. Restated rules are a
     second copy that can disagree with the first.
   - *Habitat delta:* every trap, frozen item, and pre-resolved decision has a row; the
     rung is the highest one actually available (a trap parked in "research doc" when a
     comment at the edit site would guard it is a finding); "nothing to leave" names
     what already enforces it. Grep earlier specs for the same trap — a repeat is
     habitat debt and must reach lint, a gate, or a site comment this time.
   *(Provisional check: proposed 2026-11-09, not yet measured.)*
10. **Header and standing lines.** Status, verified-against date and commit, and
    Provenance are filled in; the NOTES.md line and the findings/scope-creep line are
    present verbatim. Without the NOTES line the post-merge triage has no input.

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
