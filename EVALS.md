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

> **Pre-registration honesty note.** Experiments 1–2's predictions were written before the
> audit but **committed alongside their results**, so the ordering is my word, not a git
> artifact. From Experiment 3 on, pre-registration is its own commit (`b355ec4`, `450558f`)
> and is checkable by anyone. The `research` skill this repo ships now mandates the latter —
> "write the kill condition before investigating, *and commit it*" — a rule this experiment
> is the reason for.

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
| Judgment-call log | 2 entries (one a real spec gap — see below; one a pattern-choice note) | 4 entries | 2 entries |
| Diff | +163, 4 files, one package | +199, 6 files, two packages | +143, 4 files, one package |

Diff totals include each arm's `NOTES.md` (A 27 lines, B 68, B2 23). **Code-only the
ranking inverts: A +136/3 files, B +131/5, B2 +120/3** — the spec arm ships the *largest*
code diff, and a third of the control's excess is judgment-call logging, which is the
behavior we wanted. Prediction 4 is scored ✗ either way, but a reader checking the merged
Arm A commit will find +136, not +163.

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

**Post-audit addendum (found while preparing the method arm's spec for merge):** Arm
C's spec contained an internal **direction contradiction** — its Goal said
near=visible/far=faded ("bloom in on approach"), while its function contract and
acceptance tests encoded the inverse (`fade(0, r) → ~0`, far → 1). A literal
implementer would have stopped at the contradiction (the Step 0 standing rule), so
the failure is contained — but it settles the protocol question: **the verification
pass before handoff is not optional, even for the method arm.** The hardened spec
merged as the real artifact, with the fix recorded in its provenance header.

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

## Experiment 3 — domain transfer (does the doctrine survive CRUD?)

**Status: pre-registered 2026-07-06 (commit `b355ec4`, before the arms ran), then run and
audited the same day — results below.**

**Question:** everything above ran in one repo, one domain — a WebGL renderer whose
invariants are unusually gate-friendly (`< 0.5 px` is a luxury a CRUD app doesn't
have). Does the method's edge appear in a bread-and-butter CRUD domain, where the
"numeric threshold" role must be played by invariants (idempotency, tenant scoping,
frozen semantics) instead of numbers?

**Design:** replica of Experiment 1 in a second, private repo of mine (Next.js + Drizzle
+ vitest, gym-membership billing; "gym-manager" below). Real pending task **E7.8**: add a confirmation dialog to
mark-paid and a revert paid→due action. S/M, mechanical, with real traps: revert
idempotency (already-`due` must return, not throw), frozen `markPaid` semantics
(extend around, never edit), a Radix-portal form-detach failure mode, and **two**
render sites (each with mobile + desktop variants) where missing one still compiles
and passes tests.

- **Arm A (spec as contract):** handed the existing hardened E7.8 spec in the prompt.
- **Arm B2 (clean control):** goal in three sentences. The spec file is untracked in
  the main checkout, so worktrees naturally exclude it — contamination check from
  Experiment 1 still performed explicitly.

Same model both arms (Claude Sonnet), isolated worktrees, identical operational
rules: local gate `pnpm run validate`, no e2e, log judgment calls to NOTES.md.
Confound acknowledged upfront: gym-manager, like cosmos, carries doctrine in
CLAUDE.md/AGENTS.md and dense sibling tests — so this also re-tests Experiment 1's
"the repo teaches the agent" finding in a second repo.

**Predictions (written before results, 2026-07-06):**

1. Both arms pass `pnpm run validate` — green does not discriminate (3rd repetition).
2. **Wiring completeness is the CRUD trap:** the control misses at least one of the
   four render surfaces (second list component, or a mobile/desktop variant) — the
   class of miss that compiles, passes tests, and looks done.
3. The control *does* write service tests (sibling-test density leaks the pattern)
   but misses at least one of the two contract cases: idempotent-on-`due`, or
   cross-tenant `TenantScopeError`.
4. The control leaves `markPaid` semantics untouched (pattern-mirroring makes a
   sibling natural) but violates the frozen surface somewhere else — most likely a
   shared-component abstraction beyond the spec's two modes, or a schema/enum touch.
5. **The domain claim (the reason this experiment exists):** every audited check is
   expressible as a deterministic invariant — no screenshot, no "looks right" needed.
   If auditing E7.8 *forces* a non-deterministic blocking check, the doctrine's gate
   concept does not transfer to CRUD as written, and that's a finding against the
   method.

**Deferred sibling (recorded, not forgotten):** an Arm E — strong model, no spec —
was proposed and deliberately deferred. Rationale: Experiments 1 and 3 test **executor
invariance** (the method survives weaker executors), which is the load-bearing claim
— Experiment 2 asks a different question (who can *write* the spec);
cost accounting is a collateral benefit of that future arm, not the reason for it.

### Results (audited 2026-07-06; both diffs reviewed by hand, both gates re-run by the auditor — not from agent self-reports)

**Prediction scoring: 1 ✓, 2 ✗, 3 ✗, 4 ✗, 5 ✓ — 2/5, the same score and the same
shape as Experiment 1.** Every prediction that bet on the control's incompetence
missed; every prediction about what discriminates (green doesn't; determinism does)
hit.

| Audited | Arm A (spec as contract) | Arm B2 (clean control) |
|---|---|---|
| Gate (`pnpm run validate`, auditor-run) | ✅ 565 tests | ✅ 565 tests |
| Render surfaces (2 components × mobile/desktop) | all four | **all four** |
| Service contract (idempotent-on-`due`, tenant scope, `paidAt: null`) | ✅ | ✅ — plus a `not-found` case the spec didn't ask for |
| Tests call production fn (no mirror) | ✅ | ✅ |
| `revalidatePath` pair (`/payments` + `/members`) | ✅ | ✅ |
| Portal form-detach trap | avoided (spec-warned; hidden form + `requestSubmit()`) | avoided (found the repo's own `duplicate-schedule-dialog` precedent) |
| Touch target `min-h-11` | ✅ | ✅ |
| Process integrity (ledger, runbook, component registry) | ✅ all updated | ❌ **ledger still says `pending` for shipped work**; no runbook entry |
| Shared component (no dialog duplication) | one `BillingPeriodActionButton` | ❌ dialog logic duplicated across two components |
| Diff | +792 (includes +187 generated UI primitive) | +486 |

**The headline, third repetition and strongest yet: the repo teaches the agent.** In
a conventions-dense CRUD repo (sibling tests, lint rules that force the right React
shape, an existing confirm-dialog precedent), the unaided arm converged on
essentially every correctness property — including one (confirming the revert too)
that was a product judgment call. The spec's surviving edge narrowed to **process
integrity** (the control's ledger now lies — the drift class that compounds across a
project, invisible to any test suite) and **architecture** (anti-duplication the
control had no reason to know was wanted).

**The new finding — the spec is a channel, and channels carry bugs both ways.** This
experiment produced the first case of the spec making the treatment arm *worse* in
places:

1. The spec's failure-mode section said "Radix dialog portal"; the repo is on
   `@base-ui`. Harmless here (Arm A caught and worked around it), but it's a spec
   fact error of exactly the class Step 0 exists for — and Step 0 as written covers
   paths/symbols/formats, not stack facts. Template gap.
2. The spec *prescribed* installing the ShadCN `AlertDialog` (+187 generated lines);
   the control found the repo's existing `Dialog` confirm precedent and reused it —
   a smaller, more consistent change. On this decision the unaided agent's judgment
   beat the spec's. A pre-resolved decision is only as good as the inspection behind
   it; this one was resolved from ShadCN convention, not from reading the repo's
   existing dialogs. The control is immune to spec bugs by construction.

**The domain claim held (prediction 5, the reason the experiment exists):** every
audited check above is a deterministic invariant — greps, diffs, unit tests. CRUD's
idempotency and tenant-scoping played the role WebGL's `< 0.5 px` plays; nothing in
the audit forced a screenshot or a "looks right" as a blocking check. Runtime dialog
behavior and the 320px layout remain layer-3 human checks, non-blocking, exactly as
the doctrine assigns them. **The gate doctrine transfers to CRUD as written.**

**Feeding the loop:** (a) Step 0 must include *stack facts* (UI library, framework
idioms cited in failure modes), not just paths and formats; (b) before pre-resolving
a UI-pattern decision, the spec writer must grep for the repo's existing precedent —
"does the codebase already do this somewhere?" is now a spec-time checklist item;
(c) the process-integrity delta suggests the cheapest possible intervention for
spec-less work: a repo-level standing rule ("shipped work updates its ledger row")
would have closed most of the control's remaining gap — consistent with the running
theme that CLAUDE.md-resident doctrine is the highest-leverage artifact per line.

## Experiment 4 — does `research` catch what the flow misses? (pre-registered 2026-07-06 in commit `450558f`, then run the same day — results below)

**Question:** the `research` skill claims to verify premises — the one error class
nothing downstream catches. Does it actually detect a false premise that the current
flow (`spec-task` directly) would embed into a spec?

**Design constraint discovered during setup (a finding in itself):** every candidate
premise mined from project history was unusable — the write-it-down doctrine means
each known falsehood is already documented in prose (`docs/research/`, task specs),
so any arm that skims docs "detects" it without investigating. Two candidates burnt
this way: "the Gaia sidecar already loads at runtime" (documented in
`gaia-visibility-and-realness-problem.md`) and "procgen already tier-scales"
(TASK-071/072 exist *because* it doesn't). **The premise class that works is
recent-state drift: docs lag code, so discoverable prose points the *wrong* way and
only verification (code/git) reveals the truth.** Fittingly, that is exactly the
drift class Step 0 exists for.

**The seed (auditor-verified 2026-07-06):** consigna asserts *"the Gaia octree
manifest URL is hardcoded in the web app; prepare the work to make it configurable
per environment."*

- Ground truth: **false on main.** TASK-065 shipped it — commit `8c6a0dc`, merged
  via PR #11. EVIDENCE: `apps/web/src/app/packs.ts:26` reads
  `import.meta.env.VITE_GAIA_OCTREE_MANIFEST_URL ?? '<sample fallback>'`;
  `vite-env.d.ts:5` declares it. RECHECK:
  `grep -rn "VITE_GAIA_OCTREE_MANIFEST_URL" apps/web/src` +
  `git log origin/main --oneline -5`.
- Documentation state: `docs/agent-tasks/TASK-065-*.md` exists **with no completion
  marker** — reads as pending. BACKLOG-2026-07 doesn't mention the manifest. The
  repo's prose *supports* the false premise; the truth lives in code + git log only.

**Arms** (same model — the strong one, per the skill's own "who runs this"; isolated
worktrees of cosmos; consigna identical, handed in the prompt; no access to auditor
memory or the design conversation):

- **Arm A (treatment):** consigna + the `research` SKILL.md as contract in the prompt.
- **Arm B (control):** consigna + the `spec-task` SKILL.md — the current flow, spec
  written directly.

**Measured (all binary or countable, from artifact + transcript):**

| Check | Arm A | Arm B |
|-------|-------|-------|
| False premise dies | verdict = kill ("already built") citing code or git evidence | Step 0 / spec body: does it repeat the premise, omit verifying it, or catch it? |
| Anti-theater | kill condition written in transcript *before* first code read | — |
| Claims with teeth | auditor executes every RECHECK; % that re-verify | — |
| Doc trap | did it find TASK-065's spec and *verify* vs *trust* it? | same |

**Predictions (written before running):**

1. Arm A reaches the kill verdict, citing `packs.ts` and/or the merge commit.
2. Arm A's kill condition precedes its first code read in the transcript.
3. ≥80% of Arm A's claims carry a RECHECK that passes when the auditor runs it.
4. Arm B finds `TASK-065-*.md`, reads it as confirmation the work is pending
   (docs point the wrong way), and produces a spec for already-shipped work —
   *despite* `spec-task`'s "read the actual code" rule, because the rule directs
   reading toward the files to change, not toward auditing the premise.
5. **Negative finding pre-committed:** if Arm B also detects the premise (its code
   reading reaches `packs.ts` organically), the skill's *detection* value is nil on
   this seed and its remaining value is the claim artifact alone — that gets
   reported as a finding against, not buried.

**Optional coupling step (the flow test):** hand Arm A's research doc to a Sonnet
`spec-task` arm; PASS = claims enter Step 0 cited with their RECHECK, no fact
re-derivation.

### Results (run + audited 2026-07-06, same day; auditor re-ran every RECHECK by hand)

**Methodology incidents (reported, not hidden):** (1) both arms were cut off
mid-run by a rate limit and their assigned worktrees were destroyed; both were
resumed from transcript, created fresh worktrees at the same base, and re-verified
their load-bearing facts there — logged in each arm's NOTES.md, runs kept.
(2) Contamination channel: the harness injected the auditor's MEMORY.md index into
*both* arms despite prompt instructions; both flagged it in NOTES.md per protocol.
The index contains no line about the manifest or TASK-065 → classified low-risk.
Lesson: "no memory to subagents" is not enforceable by prompt in this harness;
audit the NOTES flag instead.

**Auditability, stated:** unlike Experiments 1–3, **no arm artifact survives** this one —
the destroyed worktrees were never merged, so there is no branch or commit to inspect. The
*seed's* ground truth is independently checkable in cosmos (the manifest env var, the merge
of PR #11, the task file with no completion marker), but the arm results below are auditor
testimony, not artifacts. Weigh them accordingly.

**Predictions scored — 2/5 again:**

1. ✅ Arm A: verdict **KILL (as a code task)**, citing `packs.ts:25-26`, the
   PR #11 merge, and a two-build marker measurement (set → override in bundle,
   unset → sample restored).
2. ❌ **Anti-theater ordering not satisfied.** In the audited transcript, two
   investigation greps (`manifest`, `import.meta.env|VITE_`) precede the written
   questions/kill conditions; the doc's own header says "written before
   investigating" — contradicted by the transcript. Mild theater signal, worth a
   skill fix (see loop-feed). Original pre-cutoff transcript unauditable (lost).
3. ✅ **10/10 of Arm A's claims re-verified** when the auditor executed every
   RECHECK, including both builds of the marker sequence. 100% ≥ 80%.
4. ❌ **Arm B caught the false premise.** The doc trap never bit: B reached the
   truth through code + `git log` (spec-task's "read the actual code" rule), scoped
   TASK-076 to the verified remainder only, and logged the premise failure as
   judgment call #1. Fifth consecutive control-parity event across experiments —
   this time it's *contract*-teaches-agent rather than repo-teaches-agent.
5. **Negative finding fires, as pre-committed: the skill's *detection* value is
   nil on this seed.** The existing flow already catches recent-state drift.

**What survived — the artifact delta, and a real judgment fork:**

- Arm A's doc is a reusable claim set: 10 auditor-re-runnable claims, a verified-
  absences section (no staging env exists, nothing sets the var anywhere, no CDN
  tooling), and a **Beliefs quarantine** correctly holding the two unprovable
  externals (live site state, CDN upload status). Arm B's Step 0 facts are equally
  verified but packaged for one spec, not for reuse.
- The arms **disagree on the remainder**: B specced it as code (thread a repo
  variable through `deploy.yml` + an empty-string `??`→`||` trap — a real find A
  missed, though load-bearing only under B's own design); A classified it as
  ops-runbook + one-line doc fix and STOPped ("a staging split is a new decision").
  A's kill discipline prevented a spec for ops work; B's spec quietly extends
  TASK-065's frozen contract by one clause (flagged, but a thaw-shaped decision
  inside a task file). Both found the same dangling `.env` README reference.

**Feeding the loop:** (a) transcript order is a weak anti-theater check — the
skill should require Steps 1–2 be *written to the doc file and committed* before
investigation starts, making the ordering an artifact fact, not a transcript fact;
(b) the skill's differentiated value against a strong executor is the **claim
artifact and verdict discipline** (kill/reframe as first-class outcomes, beliefs
quarantine), not premise detection — position it that way; (c) the coupling step
(research doc → cheap spec-writer consumes claims as Step 0) is now the live
question, since the artifact is exactly what survived. Not yet run.

## The self-improvement loop

Every executor failure gets classified with the `root-cause` taxonomy: **spec bug**
(a fact was missing/wrong) vs **executor bug** (the spec said it; the agent ignored
it) vs **doctrine gap** (the template never asks for what was needed). Doctrine gaps
become template/skill changes — that's how the mandatory Step 0 section entered
`SPEC-TEMPLATE.md` (from the drift found in the case study). Judgment accumulates in
the artifacts, not the model.
