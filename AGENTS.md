# AGENTS.md — working in this repo

This repo is a **method, published as documents**: a spec template, doctrine, skills,
templates, and the experiments that tested them. There is no build and no test suite.
The product is prose that other agents execute, so a wrong sentence here is a bug that
ships to every repo that installs it.

## What you may edit, and what you may not

Every artifact type has exactly one editable original. Full table:
[`PROPAGATION.md`](PROPAGATION.md).

| Path | Status | Rule |
|------|--------|------|
| `doctrine/*.md` | **Generated** export of a private original | Do not edit here. Propose the change; it is made upstream and re-exported with the checklist in `PROPAGATION.md`. |
| `starters/global-standing-rules.md` | **Generated**, genericized export | Same: do not edit here. |
| `skills/*`, `SPEC-TEMPLATE.md`, `templates/*`, `starters/AGENTS-starter.md` | **Original** | Edit here. |
| `EVALS.md`, `docs/research/*` | **Record** | Append; never rewrite a result, a prediction, or a score. Corrections are added as dated notes that say what was wrong. |
| `examples/*` | Unedited copies from another repo | Do not "fix" them to match the template. |
| `.agents/`, `skills-lock.json` | Installed copies of `skills/*` | Never edit. Change `skills/*`; the copies are refreshed by reinstalling. |

## Rules that hold for every change

- **One rule, many instances.** Some rules live in several files on purpose (the
  stop-at-contradictions line is in the template, the starter, and the doctrine). If you
  change the wording of one, find the others (`rg` the distinctive phrase) and say in the
  PR which ones moved and which ones can't (generated files).
- **Skill, template, and reviewers move together.** A section added to
  `SPEC-TEMPLATE.md` must appear in `skills/spec-task` (section order), be checked by
  `skills/spec-review`, and — if it constrains the diff — by `skills/doctrine-review`.
- **Claims carry their evidence level.** A new rule says where it came from: a numbered
  EVALS experiment, a cited incident, or *"provisional — proposed <date>, not yet
  measured."* Do not write a rule in the voice of a measured result when it is a proposal.
- **Claims about other repos are checked now, not recalled.** Anything said about
  [cosmos](https://github.com/MattRosset/cosmos) (a path, a number, "gated in CI") is
  re-verified against that repo before it is written. Four false claims shipped from this
  repo by skipping that.
- **Pre-registration is a commit.** Predictions and kill conditions for an experiment or
  a research doc are committed on their own, before any run or investigation. Results go
  in a later commit.
- **No private paths.** Nothing public links to the private playbook, learnings files,
  or a home-directory path.

## How you know you're done

There is no single verify command yet (that is a known gap). Until there is, run these
and report the actual output:

1. Relative links resolve: every `](path)` in a tracked `.md` file points at a file
   that exists.
2. Cross-references hold: if you renamed or renumbered a section, `rg` for the old
   name/number (`§N`, "check N", "experiment N") across the repo.
3. Skill frontmatter is intact: each `skills/<name>/SKILL.md` has `name` equal to its
   directory and a `description`.
4. `git status` shows only the files your change explains.

## Workflow

- Changes land through a branch and a PR, as the recent history does. Commit messages
  follow the existing style: `feat(skills): …`, `fix(doctrine): …`, `docs(evals): …`.
- Do not commit or push unless asked.
- Skills are installed elsewhere from this repo (`npx skills add`, the Claude plugin,
  `sync-skills-to-*.ps1`). The sync scripts overwrite directories in the user's home —
  do not run them without being asked.
