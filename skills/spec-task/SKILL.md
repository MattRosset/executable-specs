---
name: spec-task
description: Write an executable task spec — a contract detailed enough that a less capable agent (or future you) can implement it mechanically without judgment calls. Use when planning a task larger than a one-line fix, when delegating to an agent, or when the user says "spec this", "write a task for", or "plan this properly".
---

# Task spec as contract

A spec is **compressed judgment**: every decision you make now is one the implementer
doesn't have to make later. The test of a good spec: could a competent-but-literal
agent execute it without asking questions and without inventing scope?

## Before writing: make the judgment calls

Do these yourself — they are the expensive part; the spec is just their record.

1. **Read the actual code** the task touches. A spec written from memory of the code
   produces contradictions the implementer can't resolve. Cite what you verified and
   when — and put the load-bearing facts in a Step 0 the implementer must re-confirm,
   because code moves after specs are written.
2. **Classify the task: mechanical or judgment.**
   - *Mechanical* (move, rename, wire-up, apply known pattern): spec lists exact files
     and operations; forbid the implementer from "improving" anything on the way.
     When a constraint doesn't fit (a cap, a limit), fix the task-local value — don't
     let the implementer add an abstraction to accommodate it.
   - *Judgment* (design, tradeoff, unknown root cause): don't spec it for a weak agent
     yet. Do the judgment part first (run `research` for open premises, `root-cause`
     for failures, or write an ADR), then spec the now-mechanical remainder.
3. **Decide what is frozen.** Public APIs, thresholds, gate definitions. Changing
   frozen surface is a decision, not a side effect — it needs its own thaw task.
4. **Pre-resolve bounded decisions where the code already answers them.** An hour of
   inspection at spec time ("is there a global positions buffer? no → option 2") saves
   the implementer a judgment call they're not equipped to make. If a decision truly
   can't be resolved yet, write it as an ordered decision *rule* with checkable
   preconditions and a STOP case — never as an open question.
5. **Before pre-resolving a pattern or component choice, grep for the repo's existing
   precedent.** "Does the codebase already do this somewhere?" outranks the ecosystem's
   default answer. A spec is a channel: it transmits your judgment *and your errors*
   with equal fidelity — a prescribed new primitive where the repo already had the
   pattern produced a worse diff than no spec at all (EVALS experiment 3). An unaided
   agent reads the repo; a specced agent obeys you. Earn the obedience.

## Spec template

Use `SPEC-TEMPLATE.md`. If installed as a plugin it sits at
`${CLAUDE_PLUGIN_ROOT}/SPEC-TEMPLATE.md`; otherwise fetch it from
[the repo](https://github.com/MattRosset/executable-specs/blob/main/SPEC-TEMPLATE.md).
**If you can't reach it, don't invent a format** — the section order below is the
contract and is enough to write a valid spec:

Goal → Step 0 (facts to re-verify) → Context files → Frozen → Out of scope →
Deliverables/Steps → Failure modes → Acceptance gate → Verification beyond the gate.

## Rules

- **Acceptance gates must be deterministic proxies.** Screenshots and wall-clock
  performance are reference-machine information, never blocking checks (they turn the
  gate into a coin flip on a loaded CI runner).
- **Every step must be triagable from logs alone.** If a step can fail in CI, spec
  what gets logged so the failure is diagnosable without a local reproduction.
- **Context files over context prose.** Point at real files with a one-line "why"
  instead of re-explaining the architecture — prose drifts, files don't.
- **Size the spec to the executor.** The weaker the implementer, the more the
  failure-modes and out-of-scope sections carry. For yourself, they can be terse;
  for a cheap agent, they are the spec.
- **Every spec must ask the executor to log judgment calls.** Put this in the spec,
  verbatim: *"Log every judgment call — anything this task didn't decide and you had
  to — to `NOTES.md` beside the diff, visibly, as you go (not reconstructed after)."*
  Without this line there is no NOTES.md, and the triage section at the bottom of this
  skill has no input. It is the single cheapest thing a spec buys you.
- **Every spec carries the standing rule** (verbatim, in or near Out of scope):
  *"Findings during this task go to `docs/research/` (or wherever this repo keeps
  investigation writeups — create it if there is none); scope creep goes to a new task
  file, not into this diff."* Failure modes an implementer discovers are the project's
  most valuable output after the diff itself — and the only channel through which
  repo-historical judgment reaches future spec writers (see EVALS.md experiment 2:
  it's the one thing no in-context method reproduced).
- **Mine failure modes; don't invent them.** Before writing that section, search
  `docs/research/` — or the repo's equivalent — and `git log -- <the paths this task
  touches>` for the area's history. If the repo keeps no written history, `git log` is
  all you have: say so in the spec rather than leaving Failure modes thin, because an
  empty section reads as "no traps here" and that is the lie this rule exists to stop. The traps that matter are the ones that already happened — and they
  transfer *only* through written research (EVALS experiment 2: no in-context method
  reproduced the one failure mode that lived in repo history alone).
- If while writing you can't fill "Failure modes" — you don't understand the task
  well enough to delegate it. Investigate first (run `research`; its claims come
  back as Step 0 candidates with the re-check already written).

## After execution: close the loop (this is how the method improves itself)

Handing off is half the contract; the other half fires when the diff lands. Triage
**every** judgment-call entry in the executor's NOTES.md — each one is exactly one of:

- **Spec bug** — the spec was wrong or silent where it should have decided. Fix the
  spec file, and ask: which template section should have forced this? If one exists,
  the spec writer erred; if none does →
- **Doctrine gap** — the template/skill never asks for what was needed. Edit the
  template or skill *now*, citing the incident (that's how Step 0, stack facts, and
  the precedent-grep rule all entered this repo).
- **Executor bug** — the spec said it; the agent ignored it. Tighten the handoff
  (spec-as-contract in the prompt, not discoverable in the tree) before blaming the
  model.

An untriaged NOTES.md entry is a lesson paid for and thrown away. Ten minutes per
task; this is the flywheel, not the experiments.
