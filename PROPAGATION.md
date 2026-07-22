# Propagation — one original per artifact type, everything else derived

This repo is a **consumer** of some artifacts and the **original** of others. The rule:
every artifact type has exactly one editable original; every other copy is derived and
must say so. Editing a derived copy directly re-forks it — don't.

| Type | Original (authorship) | Consumers | How it propagates |
|------|------------------------|-----------|--------------------|
| **Doctrine** (`doctrine/TESTING.md`) | `engineering-playbook/TESTING-DOCTRINE.md` | this repo (public snapshot); per-project docs (e.g. `cosmos/docs/testing-conventions.md`) | Deliberate, non-continuous export — see below. Per-project docs pull from either source when a pattern graduates; they are intentionally project-tuned subsets, not full mirrors. |
| **Doctrine** (`doctrine/BUILD-FOR-AGENTS.md`) | `engineering-playbook/BUILD-FOR-AGENTS-DOCTRINE.md` | this repo (public snapshot) | Same export checklist as TESTING. Note: §14's firm wording is *also* instanced in `SPEC-TEMPLATE.md` Step 0 and in my global standing rules — graduating it here never empties those. If the wording changes, all three move together, and the template is canonical (it's what measured the effect). |
| **Skills** (`skills/*`) | this repo | `~/.claude/skills/*` | `sync-skills-to-claude.ps1` mirrors `skills/*` into `~/.claude/skills/`. Run it after editing a skill or after `git pull`. No plugin is installed today — the script is the mechanism until one is. |
| **Templates** (`templates/*`) | this repo | `engineering-playbook/templates/*` | Identical byte-for-byte; the playbook links here rather than holding a second copy. If they ever diverge, this repo wins — reconcile back to identical. |
| **Learnings** | `engineering-playbook/learnings/` (raw, private) | this repo cites specific learnings once a pattern **graduates** into doctrine | One-way, manual, and rare. A learning is never linked from public docs by its private path — only its distilled content crosses, with the path dropped. |

## Doctrine export checklist (playbook → `doctrine/TESTING.md`)

The playbook is the original because doctrine is born there via `/distill-learning`.
This repo's copy is a **generated, genericized snapshot** — the header says so
("Generado desde engineering-playbook/TESTING-DOCTRINE.md — no editar acá"). When the
playbook changes, re-export by hand:

1. Diff `engineering-playbook/TESTING-DOCTRINE.md` against this file's body (ignore the
   header marker) to find what's new.
2. Port every new section over. Do not drop anything without checking first — a public
   file "looking clean" after a re-export is not evidence it's still a superset.
3. Genericize on the way out:
   - `learnings/cosmos/LEARN-*.md` references → keep the *prose* (what happened, why it
     matters), drop the private path. These files aren't public; a link to them 404s
     or leaks that private notes exist.
   - Bare `cosmos/packages/...` / `cosmos/apps/...` paths → full
     `https://github.com/MattRosset/cosmos/blob/main/...` URLs (verify the file exists
     at that path before linking).
   - Drop the playbook's own tooling-map section and any row that only makes sense
     inside the playbook (Cursor skill path, `engineering-playbook/` self-references).
4. Verify no private paths leaked: `grep -c "learnings/\|~/.cursor" doctrine/TESTING.md`
   must be `0`.
5. Verify nothing canonical got lost: grep the sections the playbook added since the
   last export (e.g. `8b\|8c\|conservation-invariant`) — they must all be present here.

## Why this file exists

The failure this prevents: someone edits the public snapshot directly because it's
faster than round-tripping through the playbook. That re-forks TESTING doctrine in both
directions — exactly the bug this system already hit once (see
`engineering-playbook/docs/research/doctrine-home-and-build-for-agents-publish.md`).
The header marker on the generated file plus this doc are the only defense; without
them, the next person just resets the fork instead of closing it.
