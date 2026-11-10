---
name: habitat-audit
description: Audit a repository as a habitat for coding agents — entry file, one verify command, machine-enforced boundaries, reasons at the edit site, precedent, read seams, written failure history, test power — and name the single most expensive gap. Use when adopting the method in a repo for the first time, before writing the first spec in an unfamiliar or doctrine-free repo, when agents keep making the same class of mistake, or when the user says "audit this repo for agents", "habitat audit", or "is this repo ready for agents".
---

# Habitat audit

An agent arrives with no memory of the project; the repo is its entire world. This audit
measures how much of what an agent needs is **in the repo, where it will hit it** — and
how much still lives only in someone's head. The output is not a score. It is one gap to
close first, with the evidence that it is the expensive one.

**Evidence level, stated:** the eight areas come from the build-for-agents doctrine
([`doctrine/BUILD-FOR-AGENTS.md`](https://github.com/MattRosset/executable-specs/blob/main/doctrine/BUILD-FOR-AGENTS.md)
§2–§8) and the testing doctrine. Areas 1, 2, 3, and 5 held in two repos; areas 4, 6, and 7
rest on one. **This procedure itself is provisional — written 2026-11-09 and not yet run
against a repo.** Treat its ordering rule as a starting hypothesis and log where it was
wrong.

## Rules for the auditor

- **You are auditing, not fixing.** Change nothing. Every gap becomes a finding; the fix
  is a task someone specs afterwards.
- **Every finding is a claim with evidence** — a file you opened or a command you ran
  *now*, plus the command to re-check it. No finding from memory of "how repos like this
  usually are".
- **Absent is different from not found.** "No lint boundary rules" requires saying where
  you looked. Record the search.
- **"Not applicable" is a valid result** and must say why (area 6 in a CLI with no UI).
  Do not invent a gap to fill a row.
- **Count, don't characterize.** "14 inline lint disables, 9 of them in `src/api/`" is a
  finding. "Lint discipline is weak" is not.

## Procedure

### Step 1 — Find out what the repo is

Language, package manager, test runner, CI system, rough size. Read the manifest and the
CI config; do not infer the stack from the directory names. This fixes which commands the
checks below use.

### Step 2 — Run the eight checks

**1. Entry file** *(doctrine §2)*
- Is there one? `AGENTS.md`, `CLAUDE.md`, `.cursor/rules/`, or the agent's equivalent.
- Is it short, with the non-negotiable rules stated inline and depth linked out?
- Do its links and commands resolve? Open each linked file; run each named command.
- Does it name the verify command (check 2)?
- Stale content is a finding: a rule that the code visibly contradicts teaches the agent
  that the file can be ignored.

**2. One verify command, and an honest one** *(doctrine §5)*
- Is there a single command that says whether a change is done (lint + typecheck + tests
  + build)? Name it.
- **Run it.** Record exit code and wall time. A verify command that is red on the default
  branch, or takes so long nobody runs it, is the top finding of the whole audit.
- Does CI run the same command? Read the CI config. List every check CI runs that has no
  local command — each is a structural "passes local, fails CI".
- Are any *blocking* checks non-deterministic? Search for screenshot comparisons,
  wall-clock assertions, retries, and sleeps in tests and CI config. Count them.

**3. Boundaries enforced by machine** *(doctrine §4)*
- Does lint/CI encode architecture: restricted imports, banned APIs, layer or package
  boundaries? Quote one rule, or record that none exist and where you looked.
- Do the rules' messages say why and name the correct move?
- How often is enforcement switched off? Count inline lint disables, type-error
  suppressions, and skipped tests, by directory. A rule with many local exemptions is a
  documented boundary, not an enforced one.

**4. Reasons at the edit site** *(doctrine §3)*
- Sample the values most likely to be load-bearing: thresholds in tests and gates,
  limits, timeouts, caps, and magic numbers in the most-changed files
  (`git log --format= --name-only | sort | uniq -c | sort -rn` gives the churn list).
- For each of at least five: is there a comment saying what breaks if it changes and what
  enforces it? Report the ratio and list the bare ones.

**5. Precedent** *(doctrine §6)*
- Pick three things the repo does repeatedly (a data fetch, a test of a service, a UI
  dialog, an error path). For each, is there one way or several? Name the files.
- Two live ways of doing the same thing is a finding: an agent copies whichever it reads
  first. Say which one should win only if the repo itself says so; otherwise flag it as a
  decision for a human.

**6. Read seam** *(doctrine §7 — only if tests observe a running app)*
- Do end-to-end or integration tests ask the app for its state, or re-derive it? Search
  the tests for hard-coded coordinates, re-typed formulas, and helper files that model
  production logic.
- Is there a documented test hook or query surface? Name it, or record its absence.

**7. Written failure history** *(doctrine §8)*
- Is there a place for root-cause writeups and for decisions (`docs/research/`,
  `docs/decisions/`, or equivalent)? Count the documents and give the newest date.
- Take the last ten fix commits (`git log --grep` for fix/bug, or the repo's convention).
  How many have a writeup or a comment at the site explaining what the obvious fix got
  wrong? The ones without are what the next agent will re-commit.

**8. Test power** *(testing doctrine)*
- Sample five tests on critical logic (money, auth, state transitions, numeric precision,
  data migration — whatever this repo's are). For each: does it call production code or a
  copy? Would a naive implementation pass it? Is there any control that is required to
  fail?
- Count weak assertions across the suite (`toBeDefined`-style existence checks, tests
  whose only assertion is "does not throw") and mocks of the module under test.

### Step 3 — Pick the one gap

Rank by what the gap costs every future task, not by how easy it is to fix. Default order
when findings compete — a later item is rarely worth fixing while an earlier one is open:

1. No verify command, or one that is red, flaky, or unrunnable locally (check 2).
   Nothing else can be trusted until "done" is a command.
2. No entry file, or one that is stale (check 1).
3. Blocking non-deterministic checks (check 2). They teach everyone to ignore red.
4. No machine-enforced boundaries where the architecture clearly has some (check 3).
5. Competing precedents in an area with active work (check 5).
6. Everything else, by how many of the sampled items failed.

If the evidence in this repo argues for a different order, say so and say why — and
record it, because that is a correction to this skill.

### Step 4 — Write it down

`docs/research/habitat-audit-<YYYY-MM-DD>.md` (or the repo's equivalent; create it if
there is none — if the repo has nowhere to put this, that is finding 7).

## Output

```
## Repo
<stack, test runner, CI, verify command or "none">

## Findings
| # | Area | State | Evidence | Recheck |
|---|------|-------|----------|---------|
| 1 | Entry file | present / partial / absent / n.a. | file:line or command + output | command |
| … |

## What I looked for and didn't find
- <thing> — <the search that failed>

## The gap to close first
<one paragraph: which finding, what it costs each task, why it outranks the others>

## Task zero
<one sentence: the task that closes it — to be specced with spec-task, not started here>

## Not checked
<areas skipped or sampled thinly, and why>
```

## After the audit

- Task zero goes through `spec-task` like any other work. If it is "create the verify
  command" or "write the entry file", the starter in this repo
  ([`starters/AGENTS-starter.md`](https://github.com/MattRosset/executable-specs/blob/main/starters/AGENTS-starter.md))
  is the precedent to copy.
- **Confirm the audit with a probe.** Hand a real, small task to an agent with a
  three-sentence prompt and no spec, and see where it stumbles. If it stumbles somewhere
  the audit rated "present", the audit was wrong about this repo — record that in the same
  doc. The audit predicts; the probe measures.
- Re-run after the first few tasks. The findings table is a baseline: the same commands,
  run later, show whether the repo is getting easier to work in.

## Anti-patterns to refuse

- **The scorecard.** A percentage or a grade invites optimizing the number. Report the
  gap, not a score.
- **Fixing as you go.** An audit that edits the repo has no baseline to compare against,
  and its "findings" are now a diff nobody asked for.
- **Auditing the documents instead of the repo.** An entry file that *says* "run
  `make verify`" is not evidence that `make verify` exists or passes. Run it.
- **Listing all eight areas as equal.** The value is the ordering. Eight parallel
  recommendations is the same as none.
