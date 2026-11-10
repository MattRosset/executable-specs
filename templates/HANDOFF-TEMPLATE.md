# Handoff — the prompt that turns a spec into a contract

A spec the executor *finds* in the tree is advice; a spec it is *handed* is binding. In
EVALS experiment 1 the only frozen-surface violation came from the agent that discovered
the spec instead of receiving it. So the handoff is part of the method, and it is the same
text every time — which also makes runs comparable.

**Evidence level:** the bindingness finding is from one experiment (n = 1 task). The
operating rules below restate rules that already exist in `SPEC-TEMPLATE.md`. The final
report format is **provisional — proposed 2026-11-09, not measured.**

## How to use it

1. The spec has passed `spec-review`. Do not hand off a draft.
2. Paste the block below as the executor's prompt, with the **full spec inline** — not a
   path to it, not a summary of it.
3. Fill the three `<operator>` lines. Change nothing else; if a rule needs changing for
   one task, that is a spec change, not a prompt change.
4. Keep the executor's final report with the diff. It is the input to `doctrine-review`
   and to the post-merge triage.

## The prompt

```text
You are implementing one task. The spec below is the contract for this task — not
background, not a suggestion. Where the spec and your own preference differ, the spec wins.
Where the spec and reality differ, you stop.

=== SPEC ===
<paste the entire spec file here>
=== END SPEC ===

Operating rules

1. Step 0 first. Before writing any code, re-confirm every fact the spec lists in Step 0
   by opening the file or running the command now. Do not rely on what you remember.
2. If reality contradicts the spec: stop and update the spec (or mark blocked) — do not
   improvise around it. This covers a Step 0 fact that is false, two requirements that
   cannot both hold, and a test that conflicts with the stated goal. As the executor you
   mark it blocked and report; you do not rewrite the contract yourself.
3. Change only files that match the spec's Allowed paths. If the task seems to need any
   other file, stop and report — however small or reasonable the change looks.
4. Do not touch anything listed under Frozen.
5. Log every judgment call — anything this task didn't decide and you had to — to
   NOTES.md beside the diff, visibly, as you go (not reconstructed after).
6. Findings during this task go to docs/research/ (or wherever this repo keeps
   investigation writeups — create it if there is none); scope creep goes to a new task
   file, not into this diff.
7. Done means the Acceptance gate, run by you, with its real output. Passing is necessary,
   not the goal: never skip, delete, weaken, or special-case a check to get there. If a
   check looks wrong, that is rule 2.
8. Deliver every Habitat delta row the spec assigns to this diff.

Operator settings
- Verify command: <operator: the repo's one gate command>
- Base for the scope check: <operator: branch or commit the diff is measured against>
- Commit / push / open a PR: <operator: yes or no — default no>

Final report — use exactly this shape

STATUS: done | blocked | partial
STEP 0: <each fact> — confirmed | contradicted (what you found, file:line)
GATE: <command> → exit code and the relevant output, pasted
SCOPE: output of `git diff --name-only <base>...HEAD`
HABITAT DELTA: <each row> → file:line where it now lives | deferred to <task>
JUDGMENT CALLS: <count> — see NOTES.md
NOT DONE / NOT VERIFIED: <everything the above does not cover; "nothing" only if true>
```

## What the operator checks on receipt

- **STATUS: blocked is a good outcome.** It means rule 2 worked. Fix the spec and hand off
  again; do not answer the blocker in chat and let the run continue past a stale contract.
- **GATE is re-run, not read.** The report says what the executor saw; the merge decision
  rests on the command run by you or by CI.
- **SCOPE is compared against Allowed paths** before anything else is read.
- **An empty JUDGMENT CALLS on a non-trivial task** means silent guessing more often than
  it means a perfect spec. Read the diff for decisions the spec left open.
- **NOT DONE / NOT VERIFIED is the most useful line.** If it is always "nothing", the
  executor has learned that the line is decoration; check one claim by hand.
