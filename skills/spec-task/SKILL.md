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
     yet. Do the judgment part first (or run `root-cause` / write an ADR), then spec
     the now-mechanical remainder.
3. **Decide what is frozen.** Public APIs, thresholds, gate definitions. Changing
   frozen surface is a decision, not a side effect — it needs its own thaw task.
4. **Pre-resolve bounded decisions where the code already answers them.** An hour of
   inspection at spec time ("is there a global positions buffer? no → option 2") saves
   the implementer a judgment call they're not equipped to make. If a decision truly
   can't be resolved yet, write it as an ordered decision *rule* with checkable
   preconditions and a STOP case — never as an open question.

## Spec template

Use `SPEC-TEMPLATE.md` from this repo. Section order: Goal → Step 0 (facts to
re-verify) → Context files → Frozen → Out of scope → Deliverables/Steps → Failure
modes → Acceptance gate → Verification beyond the gate.

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
- **Every spec carries the standing rule** (verbatim, in or near Out of scope):
  *"Findings during this task go to `docs/research/`; scope creep goes to a new task
  file, not into this diff."* Failure modes an implementer discovers are the project's
  most valuable output after the diff itself — and the only channel through which
  repo-historical judgment reaches future spec writers (see EVALS.md experiment 2:
  it's the one thing no in-context method reproduced).
- If while writing you can't fill "Failure modes" — you don't understand the task
  well enough to delegate it. Investigate first.
