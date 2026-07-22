# Propagation — one original per artifact type, everything else derived

This repo is a **consumer** of some artifacts and the **original** of others. The rule:
every artifact type has exactly one editable original; every other copy is derived and
must say so. Editing a derived copy directly re-forks it — don't.

| Type | Original (authorship) | Consumers | How it propagates |
|------|------------------------|-----------|--------------------|
| **Doctrine** (`doctrine/TESTING.md`) | my private playbook repo | this repo (public snapshot); per-project docs (e.g. `cosmos/docs/testing-conventions.md`) | Deliberate, non-continuous export — see below. Per-project docs pull from either source when a pattern graduates; they are intentionally project-tuned subsets, not full mirrors. |
| **Doctrine** (`doctrine/BUILD-FOR-AGENTS.md`) | my private playbook repo | this repo (public snapshot) | Same export checklist as TESTING. Note: §14's stop-at-contradictions rule is *also* instanced in `SPEC-TEMPLATE.md` Step 0 and in my global standing rules — graduating it here never empties those. If the wording changes, all three move together, and the template is canonical as the **point of use** (it is what the agent actually hits). It is *not* the string that was measured — the lab tested a longer variant, and the deployed standing rules measured worse than both. Don't cite the template as the source of the effect size. |
| **Skills** (`skills/*`) | this repo | `~/.claude/skills/*` | **Install as a plugin** (`/plugin install executable-specs`) and this is handled for you. `sync-skills-to-claude.ps1` is the author-side mirror for editing skills in place — it is not the install path, and it overwrites same-named skill directories. |
| **Spec template** (`SPEC-TEMPLATE.md`) | this repo, at the root | `skills/spec-task/SPEC-TEMPLATE.md` | Byte-identical copy, bundled so the skill works on a manual install (where nothing outside `skills/` is copied). The root file is the original — the README links it. **They must stay identical**; `diff SPEC-TEMPLATE.md skills/spec-task/SPEC-TEMPLATE.md` is the check, and it belongs in the same commit as any template edit. |
| **Templates** (`templates/*`) | this repo | my private playbook repo | Identical byte-for-byte; the playbook links here rather than holding a second copy. If they ever diverge, this repo wins — reconcile back to identical. |
| **Learnings** | private, in the playbook repo | this repo cites a learning only once a pattern **graduates** into doctrine | One-way, manual, and rare. A learning is never linked from public docs by its private path — only its distilled content crosses, with the path dropped. |

## Doctrine export checklist (playbook → `doctrine/*.md`)

The playbook is the original because doctrine is born there via `/distill-learning`.
This repo's copy is a **generated, genericized snapshot** — each generated file says so
in its header ("Generated file — a genericized export of my private doctrine original").
When the playbook changes, re-export by hand:

1. Diff the playbook original against this file's body (ignore the header marker) to find
   what's new.
2. Port every new section over. Do not drop anything without checking first — a public
   file "looking clean" after a re-export is not evidence it's still a superset.
3. Genericize on the way out:
   - References to private learnings files → keep the *prose* (what happened, why it
     matters), drop the path. Those files aren't public; a link to them 404s.
   - Bare `cosmos/packages/...` / `cosmos/apps/...` paths → full
     `https://github.com/MattRosset/cosmos/blob/main/...` URLs (verify the file exists
     at that path before linking).
   - Drop the playbook's own tooling-map section and any row that only makes sense
     inside the playbook (editor-specific skill paths, playbook self-references).
4. Verify no private paths leaked — this file included:
   `grep -rn "learnings/\|playbook\|~/.cursor" doctrine/ *.md` must return nothing that
   names a private path. (This checklist itself failed that check until 2026-07-22.)
5. **Re-verify every claim the original makes about live code**, not just the paths. The
   export is faithful by construction; the *original* is what goes stale. Four false
   claims shipped publicly this way — a gitignored data pack still described as gated in
   CI, a "months-long" era that was three weeks and had not ended, and two numbers whose
   hedges had been stripped.
6. Verify nothing canonical got lost: grep the sections the playbook added since the
   last export (e.g. `8b\|8c\|conservation-invariant`) — they must all be present here.
   Content loss is a real failure mode here: whole paragraphs have been dropped because
   they mentioned a private project, when genericizing the *example* and keeping the
   *rule* was the correct move.

## Why this file exists

The failure this prevents: someone edits the public snapshot directly because it's
faster than round-tripping through the playbook. That re-forks TESTING doctrine in both
directions — exactly the bug this system already hit once.
The header marker on the generated file plus this doc are the only defense; without
them, the next person just resets the fork instead of closing it.
