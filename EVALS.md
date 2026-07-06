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

## Experiment 2 — who can write the spec? (the method as the transferable part)

**Question:** the specs in `examples/` were written by a stronger model. When a
mid-tier model is the spec *writer*, does the method's artifact (the `spec-task`
skill + template, handed in-context) measurably lift the spec it produces?

**Design:** two agents, same model (Claude Sonnet), same assignment ("write the spec
for the next visual-quality improvement of the three overlay nebulae, per the Tier B
research doc — you decide the scope"), isolated worktrees, prior spec drafts deleted
unread (both arms).

- **Arm C (method):** receives the `spec-task` skill rules + template section order
  in the prompt.
- **Arm D (control):** receives "write a detailed task specification, detailed
  enough that another agent can implement it from the document alone."

**Answer key:** the strong model's hardened spec for the same task
([`TASK-073`](https://github.com/MattRosset/cosmos/blob/main/docs/agent-tasks/TASK-073-nebula-tier-b-distance-fade.md)),
which contains a deliberate judgment trap: of the four Tier B items, B4 (distance
fade) and B3 (domain warp) are mechanical, while B1 (dust absorption — needs a
blend-mode design decision; additive can't darken) and B2 (soft particles — needs
the depth texture) are design-first and must be *deferred, not specced*.

**Audited on:** scope judgment (the B1/B2 trap), fact accuracy (paths/symbols
verified vs recalled), gate determinism (any screenshot/"looks right" as a blocking
check?), executor-decidability (open questions left to the implementer), frozen
surface (is `createNebula`'s signature protected?).

**Predictions (written before results, 2026-07-06):**

1. Both produce plausible, well-organized documents — prose quality won't
   discriminate; the judgment calls will.
2. **The trap:** Arm C defers B1/B2 (the skill's mechanical-vs-judgment rule forces
   the classification); Arm D scopes in at least one design-first item as if it were
   mechanical.
3. **Facts:** Arm D cites at least one path/symbol it didn't verify (or none at
   all — prose-only spec); Arm C's Step 0 section exists and its facts check out.
4. **Gates:** Arm D's acceptance criteria include at least one non-deterministic
   blocking check (screenshot comparison or "visually verify"); Arm C's gate is
   deterministic with screenshots reference-only.
5. **Neither** reaches the answer key's depth on failure modes that require repo
   history (the transit pop-in risk; the procgen-vs-overlay systems confusion) —
   the honest ceiling of model-in-a-box spec-writing without accumulated context.

### Results (audited 2026-07-06; both specs read in full, sampled facts re-verified against code)

**Prediction scoring:** 1 ✓, 2 ✓, 3 ✗, 4 ✗, 5 half. Same pattern as Experiment 1:
the arms beat the predictions wherever the *repo* carries the doctrine, and split
exactly where only judgment can.

**Where the control was as good as the method (predictions 3–4 missed):** Arm D read
real code and its sampled facts all verified — it even independently discovered that
the data contract lacks the per-field radius the fade needs. Its acceptance criteria
were deterministic, screenshots reference-only, and it demanded the pure-function
extraction, citing the repo's own testing rules. CLAUDE.md and
`docs/testing-conventions.md` transferred that doctrine to an unaided agent — again.

**Where the split is unmistakable (the trap, prediction 2):**

| | Arm C (skill in context) | Arm D (unaided) |
|---|---|---|
| Scope decision | B4 only; deferred B1/B2/B3 as design-first, each with the reason | **Scoped in B1** — and made the blend-mode architecture decision *inline* (custom darken blend, second shader, new layer cap, data-contract extension) inside an implementation task |
| Frozen surface | 6 surfaces explicitly frozen (shader files, `setOpacity` contract, field params, the sibling fade's constants, core-types shape) | No frozen section; extends `core-types` three ways as a side effect |
| Open choices left to the implementer | 1, bounded (fade constants, with documentation obligations and guidance) | ≥7 explicit "or / pick one / prefer / if easy" forks, plus visual tuning delegated ("err on the side of too-subtle") |
| Latent bug | Step 0 fact #4 *forces* checking the camera-context/units frame before computing distance | Uses the render-offset magnitude with **no context guard** — the exact wrong-frame silent-bug class its sibling scene guards against; also ships an acknowledged-but-unresolved transparent-sort assumption |
| Resulting task | S/M, one system, mechanically executable | L, two systems + contract thaw + an unreviewed design decision fused in |

**Prediction 5 (the ceiling), half right:** both arms found the
procgen-vs-overlay systems-confusion guard (the research doc points to it — repo
writeups pay again). Neither arm carried the failure mode that lives only in repo
history: the galaxy transit flies *through* these fields, so a fade band too narrow
relative to flight speed pops mid-flight. The answer-key spec has it; no amount of
in-context method produced it. Accumulated project memory is the one input the
artifact can't replace — which is exactly why findings go in `docs/research/`.

**The conclusion that matters:** the unaided arm did not fail on competence — it
failed on *classification*. It produced an impressive document that is actually a
design proposal and an implementation task fused together, unreviewed. The skill's
mechanical-vs-judgment rule is what turned the same model into something that
quarantines design instead of smuggling it. **The method's irreducible core is
judgment quarantine + frozen surface + pre-resolved decisions; structure and test
doctrine transfer through repo docs; repo-historical failure modes transfer only
through written-down research.** Practical protocol for a mid-tier spec writer:
skill in context + a fact-check/doctrine-review pass on the spec before handing it
to an executor.

## The self-improvement loop

Every executor failure gets classified with the `root-cause` taxonomy: **spec bug**
(a fact was missing/wrong) vs **executor bug** (the spec said it; the agent ignored
it) vs **doctrine gap** (the template never asks for what was needed). Doctrine gaps
become template/skill changes — that's how the mandatory Step 0 section entered
`SPEC-TEMPLATE.md` (from the drift found in the case study). Judgment accumulates in
the artifacts, not the model.
