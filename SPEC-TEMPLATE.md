# TASK-NNN: <short imperative title>

**Size:** S | M | L
**Depends on:** TASK-YYY (if any — say whether it's a hard block)

## Goal

One paragraph: what exists after this task that doesn't now, and why it matters.
Name the thread/initiative it belongs to so the implementer knows what NOT to solve here.

## Step 0 — Verify the spec's facts (mandatory when spec and code can drift)

The spec was written by reading the code on <date>; the code may have moved. List the
2–4 load-bearing facts (file paths, symbol names, formats, line ranges) the implementer
must re-confirm before writing code. **If reality contradicts the spec: stop and update
the spec (or mark blocked) — do not improvise around it.**

If a bounded decision couldn't be resolved at spec time, state it here as a decision
*rule* (ordered options, each with a checkable precondition, and a STOP case), never as
an open question.

## Context (read these first)

- `<file:line>` — why it matters to this task
- `<ADR / research doc>` — the decision or mechanism this task builds on

Point at real files with a one-line "why" instead of re-explaining the architecture —
prose drifts, files don't.

## Frozen — do not touch

- <public API / config / threshold / file format> (change requires a separate,
  explicitly-reviewed thaw task — if this task seems to need one, STOP and mark blocked)

## Out of scope

Explicit non-goals, especially the adjacent improvements the implementer will be
tempted to make. "While you're in there" is how mechanical tasks go wrong. Name the
future task where each non-goal lives, if known.

## Deliverables / Steps

Numbered, each independently checkable. For mechanical tasks: exact files and
operations, and what "done" looks like per step. Where a design decision was made at
spec time, state the decision *and* the rejected alternative (one line) so the
implementer doesn't relitigate it.

## Failure modes to watch

The 2–3 ways this specific change classically goes wrong, and how to detect each.
This section is where the spec-writer's experience transfers — the weaker the
implementer, the more this section carries. If you can't fill it in, you don't
understand the task well enough to delegate it.

## Acceptance gate

Deterministic checks only — commands the implementer runs and their expected output,
numeric thresholds where applicable. When a check demands a unit test, name **where
testable code must live** (the pure-function extraction and its location per the
repo's test scoping), or the implementer will test a *mirror* of the production code
instead of the code (found in EVALS.md experiment 1 — the control arm's test
re-derived the production formula, leaving the real one ungated). No "looks right," no wall-clock perf, no
screenshots as blocking checks (those are reference-machine information for the PR).
Every check that can fail in CI must log the chosen input and measured quantity, so a
CI-only failure is triagable from logs alone.

## Verification beyond the gate

What to manually confirm once (the feature is actually reachable, the scene actually
renders) — things the gate can't see. Verify the measurement before trusting the
number: a black screen has excellent frame times.
