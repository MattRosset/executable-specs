# TASK-NNN: <short imperative title>

**Status:** draft | reviewed | handed-off | done | blocked | killed
**Size:** S | M | L
**Depends on:** TASK-YYY (if any — say whether it's a hard block)
**Verified against code:** <date> at <commit sha>
**Provenance:** written by <who/model>; reviewed by <who/model> on <date>; contested
changes and post-review fixes get one line each here

Shipped work flips **Status** to `done` in the same change that ships it. A spec file with
no completion marker reads as pending work (EVALS experiment 4: a shipped task whose spec
still looked open made the repo's prose support a false premise).

## Goal

One paragraph: what exists after this task that doesn't now, and why it matters.
Name the thread/initiative it belongs to so the implementer knows what NOT to solve here.

## Step 0 — Verify the spec's facts (mandatory when spec and code can drift)

The spec was written by reading the code on <date>; the code may have moved. List the
2–4 load-bearing facts (file paths, symbol names, formats, line ranges) the implementer
must re-confirm before writing code. **Stack facts count as facts:** if a failure mode
or step names a library, framework idiom, or UI primitive, that name must come from the
repo's actual dependencies, not the ecosystem default (EVALS experiment 3: a spec said
"Radix" in a repo on `@base-ui` — the executor caught it; the template didn't). **If reality contradicts the spec: stop and update
the spec (or mark blocked) — do not improvise around it.**

If a bounded decision couldn't be resolved at spec time, state it here as a decision
*rule* (ordered options, each with a checkable precondition, and a STOP case), never as
an open question.

## Context (read these first)

- `<file:line>` — why it matters to this task
- `<ADR / research doc>` — the decision or mechanism this task builds on

Point at real files with a one-line "why" instead of re-explaining the architecture —
prose drifts, files don't. **Point at what the repo already teaches instead of restating
it:** if a lint rule, a gate, or an existing precedent already settles something, name it
here and spend the spec's words on what the repo does *not* say.

## Allowed paths — the only files this task may change

- `<glob>` — what changes there
- `<glob>` — what changes there
- `NOTES.md`, this spec's Status line, and the ledger/progress row

A changed file outside this list is a scope violation by definition, however reasonable it
looks. If the task seems to need one: STOP and mark blocked. This list is checked, not
trusted — see the Acceptance gate.

## Frozen — do not touch

- <public API / config / threshold / file format> (change requires a separate,
  explicitly-reviewed thaw task — if this task seems to need one, STOP and mark blocked)

Frozen is for surface *inside* the allowed paths, or values the implementer will be
tempted to "fix" on the way (a load-bearing constant, a gate threshold). Everything
outside the allowed paths is already off limits.

## Out of scope

Explicit non-goals, especially the adjacent improvements the implementer will be
tempted to make. "While you're in there" is how mechanical tasks go wrong. Name the
future task where each non-goal lives, if known.

Standing rule, verbatim in every spec: *"Findings during this task go to `docs/research/`
(or wherever this repo keeps investigation writeups — create it if there is none); scope
creep goes to a new task file, not into this diff."*

## Deliverables / Steps

Numbered, each independently checkable. For mechanical tasks: exact files and
operations, and what "done" looks like per step. Where a design decision was made at
spec time, state the decision *and* the rejected alternative (one line) so the
implementer doesn't relitigate it.

Standing rule, verbatim in every spec: *"Log every judgment call — anything this task
didn't decide and you had to — to `NOTES.md` beside the diff, visibly, as you go (not
reconstructed after)."*

## Failure modes to watch

The 2–3 ways this specific change classically goes wrong, and how to detect each.
This section is where the spec-writer's experience transfers — the weaker the
implementer, the more this section carries. If you can't fill it in, you don't
understand the task well enough to delegate it.

**If one of them already happened in this repo, lead with it** under its own heading
("THE TRAP — read before anything else") and cite the research doc or commit that records
it. A past regression is the failure mode most likely to recur and the one no code comment
may be guarding.

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

Always include the scope check: `git diff --name-only <base>...HEAD` lists only files
matching **Allowed paths**. Paste the output in the PR.

## Verification beyond the gate

What to manually confirm once (the feature is actually reachable, the scene actually
renders) — things the gate can't see. Verify the measurement before trusting the
number: a black screen has excellent frame times.

## Habitat delta — what this task leaves in the repo

A spec is read once; the repo is read by every agent that comes after. For each trap,
frozen item, and pre-resolved decision above, name where it lives once this task is done,
on the **highest rung available**:

1. **Lint / CI check** — the wrong move turns red and the message names the right one
2. **Gate test** with a control that must fail
3. **Comment at the site** where the wrong edit would be made
4. **Rule in the entry file** (`CLAUDE.md` / `AGENTS.md`)
5. **Research doc / ADR**

| Item from this spec | Destination (file) | Rung |
|---------------------|--------------------|------|
| | | |

- Rungs 3–5 land in this diff and are deliverables like any other (add their files to
  Allowed paths).
- Rungs 1–2 land in this diff only if they are already inside Allowed paths; otherwise
  name the follow-up task that adds them. Shared lint/CI config does not change as a side
  effect.
- "Nothing to leave" is a valid answer only with its reason: *already enforced by
  `<rule / test / comment>`*.
- A trap that already appeared in an earlier spec is **habitat debt**: it must reach
  rung 1–3 here, or get its own task. Writing it into a third spec is not an option.
