# Testing the method on itself

The doctrine says a test without a control has no power. The same applies to the
method: if an agent given a full executable spec performs no better than one given a
two-line prompt, the spec format is decoration. So before publishing, we ran the
experiment.

## Experiment 1 — spec-vs-prompt (executor invariance)

**Question:** does the executable spec measurably improve what a mid-tier model ships,
compared to casual delegation?

**Design:** two agents, same model (Claude Sonnet), same repo
([cosmos](https://github.com/MattRosset/cosmos)), same real task (TASK-071: make a
procedural point cloud's draw budget quality-tier-aware), isolated git worktrees,
identical operational rules (local verify gate, no e2e, log every judgment call to
NOTES.md instead of silently guessing).

- **Arm A (treatment):** receives the full hardened spec — frozen interfaces, out of
  scope, a "THE TRAP" section encoding a past regression, failure modes, deterministic
  acceptance gate.
- **Arm B (control):** receives the goal in three sentences plus the tier values.
  This is what prompt-level delegation looks like.

**Measured:**

| Metric | How |
|--------|-----|
| Local gate | `pnpm verify` exit 0 |
| Judgment calls | NOTES.md entries (the spec's job is to make this ~0 meaningful ones for A) |
| Scope violations | doctrine-review checklist C over the diff (files touched the claim doesn't explain, frozen surface) |
| The trap | did the change couple `drawFraction` to the visual fade (a known past regression class)? |
| Test power | is the mapping unit-tested as a pure function, incl. `Infinity/count → 1 not NaN`? |
| Contract adherence | `low` budget stays exactly 90_000 (load-bearing shipped fix); tier table in core-types untouched |

**Predictions (written before results, 2026-07-05):**

1. Both arms pass `pnpm verify` — a green suite does not discriminate; the differences
   will be in scope, contracts, and failure modes the suite doesn't gate.
2. Arm B touches frozen surface (most likely: extends the tier table in `core-types`,
   the "natural" place a spec-less agent puts a per-tier value) or misses the
   `Infinity → NaN` clamp edge.
3. Arm B produces ≥2 judgment-call NOTES entries (or worse, zero — meaning it guessed
   silently); Arm A produces ≤1.
4. Arm A's diff is smaller and confined to the one file the spec names.
5. Neither arm hits "the trap" outright (Sonnet is competent), but only Arm A leaves
   the comment/test evidence that *prevents* the next editor from hitting it.

**Methodology incident (reported, not hidden):** the first control run was
contaminated — the isolated worktree carried over untracked files from the main
checkout, *including the spec itself*, and the control agent found and followed it
("found TASK-071 spec in the repo — followed its guidance directly"). The control was
re-run with the spec files deleted unread. The contaminated run was kept and
reclassified as an unplanned third arm:

- **Arm B (contaminated → "spec discoverable"):** goal-only prompt, spec present in
  the tree. Notable early finding: even *having read* the spec, this agent violated
  its frozen interface — it modified `packages/streaming` to add a tier getter where
  the spec mandates the existing `useQuality()` hook and declares `packages/*`
  untouched — rationalized by a wrong judgment ("avoid threading a prop through 7
  entry points"; the mandated hook needs no props). A spec you *found* is advice; a
  spec you were *handed as the contract* is binding. Distribution of the spec is part
  of the method.
- **Arm B2 (clean control):** goal-only prompt, spec files deleted unread at start.

### Results (audited 2026-07-06, all three diffs reviewed by hand — not from agent self-reports)

All three arms passed `pnpm verify`. As predicted, **green does not discriminate** —
every difference that matters was invisible to the test suite.

| Metric | Arm A (spec as contract) | Arm B (spec discoverable) | Arm B2 (clean control) |
|--------|--------------------------|---------------------------|------------------------|
| Local gate | ✅ | ✅ | ✅ |
| Frozen surface | untouched | ❌ **modified a frozen package** (added a public getter the spec's mandated hook made unnecessary) | untouched |
| Test power | tests call the production mapping fn (extracted pure) | pure fn extracted, tested | ❌ **test re-derives the production math** ("Mirrors GalaxyScene's `Math.min(1, cap/count)`" — the real formula stays inline and ungated; breaking it keeps the suite green). Violates the repo's own rule 1. |
| The trap (perf knob coupled to visual fade) | avoided + contract re-documented at both sites | avoided | avoided (pre-existing comments carried it) |
| Forward breadcrumbs | `medium` flagged as placeholder pending calibration; task + research cross-refs | partial | ❌ none — the future calibration task loses its pointer |
| Judgment-call log | 2 entries (both real spec gaps — see below) | 4 entries | 2 entries |
| Diff | +163, 4 files, one package | +199, 6 files, two packages | +143, 4 files, one package |

**Prediction scoring (against the pre-registered five):** 1 ✓, 2 ✗ for the clean
control / ✓ for the discoverable arm, 3 ✗ (both logged 2), 4 ✗ (comparable sizes,
both confined), 5 ✓. Two clean hits, one split, two misses — reported as scored.

**The honest headline: the clean control did better than predicted, and the reason
is the finding.** Cosmos's code comments are dense with encoded doctrine — the
control agent *read the comment block above the constant*, learned that 90k was
load-bearing for a CI gate, kept it, and preserved the regression history. The
control was never methodology-free: **doctrine embedded in code comments is a spec
that never leaves the code.** The method leaked into its own control through the
codebase it built.

What the handed spec still bought, on a small task in a doctrine-dense repo:

1. **Bindingness.** The only frozen-surface violation came from the arm that *found*
   the spec but wasn't handed it as a contract — it treated the frozen list as advice
   and "improved" a frozen package with a wrong rationale. Distribution is part of
   the method.
2. **Test power.** The spec's explicit "extract the mapping as a pure exported
   function; unit-test it" is what put the production formula under test in Arm A.
   The control tested a *mirror* of the formula — the exact drift failure mode the
   testing doctrine names.
3. **Forward breadcrumbs.** Only the spec arm left the calibration placeholder note
   and cross-references the *next* task needs.

**Feeding the loop (spec gaps found by the experiment):** both A and the control
independently discovered that unit-testable code must live in `src/glue/**` (the
app's vitest scope) — the spec never said where the pure function goes. That's a
doctrine gap, now a template rule: *the acceptance gate must name where testable
code lives, not just that a test exists.*

**Limitations, stated plainly:** n=1 task, one executor model, S-size mechanical
task, in a repo whose comments already carry the contracts. The expectation (untested
here) is that the spec's edge grows with task size and with how much contract the
code *cannot* express — e.g. a task whose wiring trap is that the "natural" placement
compiles, passes, and never executes (see the case study's finding #3): no code
comment exists at the place you'd wrongly edit.

## Experiment 2 — who can write the spec? (spec-writer degradation)

**Question:** the specs in `examples/` were written by a stronger model; does the
method survive the spec-writer being a mid-tier model?

**Design (to run):** have a mid-tier model write a spec for a task already specced by
the strong model (without seeing that version), using the `spec-task` skill. Audit
the result on three counts: unverified facts (paths/symbols cited from memory),
unresolved judgment calls left to the implementer, and missing failure modes.
Baseline for calibration: the strong model's own specs, fact-checked one day later,
contained **3 drift bugs across 6 specs** (see
[the case study](examples/CASE-STUDY-fact-checking-a-spec-set.md)) — the bar is not
perfection, it's "cheap verification pass catches the rest."

**Hypothesis:** spec *structure* transfers through the skill; Step 0 pre-resolution
and failure-mode anticipation degrade with model strength — and the mandatory
fact-check pass compensates, making "mid-tier writes + checklist verifies"
approximately equivalent to "strong model writes."

## The self-improvement loop

Every executor failure gets classified with the `root-cause` taxonomy: **spec bug**
(a fact was missing/wrong) vs **executor bug** (the spec said it; the agent ignored
it) vs **doctrine gap** (the template never asks for what was needed). Doctrine gaps
become template/skill changes — that's how the mandatory Step 0 section entered
`SPEC-TEMPLATE.md` (from the drift found in the case study). Judgment accumulates in
the artifacts, not the model.
