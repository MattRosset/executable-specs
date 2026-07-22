# executable-specs

**Delegate implementation to AI agents without lowering your engineering standards.**

A working method — spec format, review doctrine, test philosophy, and Claude Code
skills — for running software projects where agents write most of the code and a
human owns the judgment. Extracted from a real project, not a thought experiment:
[cosmos](https://github.com/MattRosset/cosmos), a 5-million-star WebGL galaxy renderer
built and maintained almost entirely through agent-executed task specs, with
deterministic gates in CI.

---

## The idea in three sentences

1. **A spec is compressed judgment.** Every decision you make while writing the spec
   is one the implementing agent doesn't have to make — and agents fail on missing
   judgment far more often than on hard problems.
2. **A gate converts "I believe this works" into "this measurement holds, and a broken
   version fails it."** If a deliberately naive implementation also passes your test,
   the test is lying.
3. **The durable human skills are the two ends of the loop** — deciding what to build
   (specs, scope, taste) and verifying it was built (review, gates). The middle —
   typing the code — is the part that commoditizes.

## The loop

```
        ┌────────────────────────────────────────────────────────────────────┐
        │                                                                    │
   research ──► spec-task ──► implement ──► doctrine-review ──► gates in CI │
   (mint claims, (strong        (any           (checklist,        (determin- │
    kill, or      model or       model)         human owns         istic     │
    reframe)      human)                        the merge)         proxies)  │
        ▲                                                             │      │
        │                  root-cause ◄── failure ────────────────────┘      │
        │                  (measure, don't guess)                            │
        │                                                                    │
        └────────────────── distill-learning ◄───────────────────────────────┘
                            (portable patterns back into doctrine)
```

Each arrow is a skill or template in this repo. The strong model (or you) spends its
time where judgment lives; cheaper models execute mechanically inside a contract.
Every producer has a verifier — specs get spec-review, diffs get doctrine-review,
behavior gets gates — and `research` extends that invariant to the top of the chain:
it verifies **premises**, the one error class nothing downstream can catch.

## What's in the box

| Artifact | What it is |
|----------|------------|
| [`SPEC-TEMPLATE.md`](SPEC-TEMPLATE.md) | The executable-spec format: Goal, Frozen Interface, Out of scope, Failure modes, deterministic Acceptance gate |
| [`doctrine/BUILD-FOR-AGENTS.md`](doctrine/BUILD-FOR-AGENTS.md) | **How to build a repo an agent does the right thing in by default**: doctrine in the repo, reasons at the point of violation, machine-enforced boundaries, read seams, written-down failure history — and the honest boundary where the environment stops helping |
| [`doctrine/TESTING.md`](doctrine/TESTING.md) | Test philosophy: gates, anti-tests, test power, self-measuring probes, "fix the test, never the threshold" |
| [`skills/research`](skills/research/SKILL.md) | Claude Code skill: investigate before deciding what to build — mint re-checkable claims, or kill/reframe the work they were about to justify |
| [`skills/spec-task`](skills/spec-task/SKILL.md) | Claude Code skill: write a spec a weaker agent can execute without judgment calls |
| [`skills/doctrine-review`](skills/doctrine-review/SKILL.md) | Claude Code skill: review a diff against the doctrine — test power, determinism, scope, freeze |
| [`skills/spec-review`](skills/spec-review/SKILL.md) | Claude Code skill: verify a spec against the live code before handoff — facts, consistency, judgment quarantine (the pass EVALS proved non-optional) |
| [`skills/root-cause`](skills/root-cause/SKILL.md) | Claude Code skill: diagnose by measurement before proposing any fix; produces a mechanism, not a patch |
| [`skills/distill-learning`](skills/distill-learning/SKILL.md) | Claude Code skill: extract portable patterns from a finished phase back into your doctrine |
| [`templates/`](templates/) | Gate and test-spec worksheets (fatal risk, fixed scenario, PASS threshold, control that must fail) |
| [`starters/CLAUDE-starter.md`](starters/CLAUDE-starter.md) | Day-one CLAUDE.md for a new repo — the standing rules (write-it-down, testing, tasks) that make every future agent session better. Skills fire on demand; this is in context always. |
| [`examples/`](examples/) | **Real specs from a real repo** — including a case study of fact-checking a spec set against a moving codebase |
| [`EVALS.md`](EVALS.md) | **The method tested against a control** — spec vs. bare prompt, same model and task, predictions pre-registered, contaminated run reported rather than dropped |
| [`PROPAGATION.md`](PROPAGATION.md) | Which artifacts are originals here and which are derived snapshots, and how changes flow between them |

## Why the repo matters more than the prompt

The experiments turned up something that reframes the whole method: in a controlled pair
in cosmos — replicated in a second repo — an agent handed a *casual* prompt performed
nearly as well as one handed a full spec, **because the repo taught it.** Frozen
boundaries, a gate it can run, dense correct precedent, and doctrine written where it
reads did the work the spec was supposed to do.

So the leverage isn't the instruction you write per task; it's the world the agent wakes
up in. A spec is a one-shot message. The repo is a standing teacher, present at every
keystroke. [`doctrine/BUILD-FOR-AGENTS.md`](doctrine/BUILD-FOR-AGENTS.md) is how to build
that world — including §9, the honest boundary: a good repo makes cheap the judgment
**already made and left behind** as precedent. It does nothing for a decision the repo
has never faced. Those still need a human.

## Why specs and not prompts

A prompt asks a model to be smart. A spec **removes the need**: exact files, frozen
interfaces, explicit non-goals, the 2–3 ways this specific change classically goes
wrong, and a deterministic acceptance gate. The test of a good spec: *could a
competent-but-literal agent execute it without asking questions and without inventing
scope?*

This inverts the economics of model quality. Strong models are scarce and expensive;
their leverage is highest writing specs and reviewing output — work that transfers.
A weak model with a tightly-scoped mechanical task outperforms a strong model with
"improve this area."

## Why deterministic gates and not "tests pass"

Agent-written code needs *power-checked* verification, because agents optimize for
green. The doctrine's core device is the **anti-test**: run the deliberately naive
implementation through the same gate and require it to **fail**. If the control
passes, the scenario is too easy or the assertion is wrong — fix the test, never the
threshold.

The second device: **CI gates only deterministic proxies.** Screenshots and wall-clock
performance are reference-machine information, never blocking checks — a gate that can
fail on a loaded runner is a coin flip, and every retry you add hides the next real
bug behind it.

## Evidence (the part most methodologies skip)

**The method was tested against a control: [`EVALS.md`](EVALS.md).** The doctrine says a
test without a control has no power, so the same standard applies to the method itself —
if an agent handed a full spec ships no better than one handed a two-line prompt, the
format is decoration. Two arms, same model, same repo, same real task, predictions
written down before the results. All three arms passed the test suite; **every difference
that mattered was invisible to it** — scope violations, frozen-interface breaks, silent
judgment calls. One finding worth the click: an agent that *found* the spec in its
worktree violated its frozen interface anyway. A spec you discover is advice; a spec
handed to you as the contract is binding — so distribution is part of the method.

Everything here was extracted from [cosmos](https://github.com/MattRosset/cosmos),
where it runs for real. A few receipts:

- **The anti-test catching a real bug class:** star positions summed in f32 on the GPU
  caused sub-pixel jitter on close approach. The gate ran both paths on the same
  scenario — proper f64-subtract-then-round vs. naive f32 absolute positions — with
  a `< 0.5 px over 300 frames` threshold the naive path must violate.
  ([`packages/coords/test/jitter.test.ts`](https://github.com/MattRosset/cosmos/tree/main/packages/coords))
- **Root-cause taxonomy ending a flaky-test era:** months of intermittent e2e failures,
  classified across 16 commits: 3:1 test-environment coupling vs. real bugs. The fix
  wasn't patching specs — it was replacing the tests' parallel camera model with query
  hooks into the running app (`__cosmos.pickAt`, `projectToScreen`). The class died.
- **Specs drift; Step 0 catches it:** a six-spec backlog written from code reading was
  fact-checked one day later — three drift bugs found (a file cited in the wrong
  package, a signed/unsigned format error, a wiring plan that would have been dead
  code). See [the case study](examples/CASE-STUDY-fact-checking-a-spec-set.md).

## Quickstart

**Use the skills (Claude Code):**

```bash
# as a plugin
/plugin marketplace add MattRosset/executable-specs
/plugin install executable-specs

# or manually: copy skills/* into ~/.claude/skills/
```

**Adopt the method (any tooling):**

1. Next task bigger than a one-line fix: write it with [`SPEC-TEMPLATE.md`](SPEC-TEMPLATE.md).
   If you can't fill in "Failure modes," you don't understand the task well enough to
   delegate it — investigate first.
2. Put one **gate** on your riskiest invariant using
   [`templates/GATE-TEMPLATE.md`](templates/GATE-TEMPLATE.md), including the control
   that must fail. Add more gates only after the first one pays.
3. Review agent output with the
   [`doctrine-review`](skills/doctrine-review/SKILL.md) checklist before merging.
   Never merge agent output you couldn't have reviewed without the agent.

## Who this is for

Engineers operating coding agents on codebases they're accountable for. It assumes
you'd rather own five sharp judgment calls than fifty vague diffs — and that "the
agent wrote it" will never be an acceptable root cause.

## Scope and limits (read this before adopting it wholesale)

Calibration matters more than persuasion here, so: this is **a working method, not a
validated one.**

- **One codebase.** Everything was extracted from a single project — [cosmos](https://github.com/MattRosset/cosmos),
  a graphics-heavy TypeScript monorepo I own solo. It has never been run against a
  multi-team codebase, a legacy system, or a language where the tooling assumptions
  don't hold.
- **Small n.** The experiment in [`EVALS.md`](EVALS.md) is one task across three arms.
  That is enough to show the spec format changes what ships; it is not enough to
  quantify by how much, or to claim it generalizes.
- **Not solo-friendly by accident.** A single owner is why the doctrine can be this
  strict. On a team, the frozen-interface and scope rules need negotiation this repo
  doesn't model.

What I'd claim: the *devices* travel — anti-tests, deterministic gates, premise
research, judgment quarantine. What I wouldn't: that adopting the whole thing
unmodified will work in a context that looks nothing like mine.

---

*Method and docs by Matías Rosset, developed working with Claude. MIT licensed.*
