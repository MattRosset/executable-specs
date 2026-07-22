---
name: distill-learning
description: Extract portable engineering patterns from a finished phase, gate, bug hunt, or research doc into a learnings file and your standing doctrine. Use after closing a gate/milestone, after a significant root-cause writeup, or when the user says "extract learnings", "distill this", or "update the playbook".
---

# Distill learnings into doctrine

Two outputs:
1. A case-study file: `docs/learnings/LEARN-<topic>-<YYYY-MM-DD>.md` in this repo, or
   the user's playbook repo if they keep one — ask once. Create the directory if it
   doesn't exist; don't skip the output for lack of a home.
2. Candidate rule updates to the user's standing doctrine (CLAUDE.md, a playbook file,
   or this repo's doctrine docs) — **proposed, never silently applied**.

## The distillation test

A learning is worth extracting only if it survives this rewrite:
**strip every project-specific noun and check that a useful sentence remains.**

- Raw: "the near-Sol perf gate failed because the 1M-point procedural cloud had no LOD."
- Portable: "when a budget gate fails, first check whether an *uncapped* data source
  entered the scene — the regression is often in what got drawn, not in the drawing."

If nothing survives the rewrite, it's project knowledge — leave it in the project's
docs, don't copy it to the doctrine.

## Procedure

1. **Collect the raw material.** Read the gate/task/research docs for the phase, and
   `git log` for the relevant window. List candidate lessons — aim wide first.
2. **Apply the distillation test** to each candidate. Keep the survivors.
3. For each survivor, write it in the case-study file as:
   - **Pattern** — one portable sentence (the distilled form).
   - **Seen in** — project, task/commit, one line of concrete context.
   - **When it applies / when it doesn't** — the boundaries are what make it usable.
   - **Cost of ignoring it** — what it cost this time (days lost, flaky weeks).
4. **Check the standing doctrine:**
   - Does a survivor confirm a provisional rule? Propose promoting it, citing the new
     evidence.
   - Is a survivor new and seen ≥2 times across learnings files? Propose it as a
     standing rule.
   - Seen once? Queue it with an explicit promotion condition ("promote when seen in
     a second project").
5. Present the proposed doctrine edits to the user before applying — the doctrine is
   their constitution; the skill drafts, the user ratifies.

## Style

Match the target file's existing voice and format. Short. Tables where the file
already uses tables. No motivational filler — every line either states a pattern or
evidences it.
