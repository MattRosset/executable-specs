---
name: research
description: Investigate before deciding what to build — convert unverified assumptions into re-checkable claims, or kill the work they were about to justify. Use before writing a backlog or spec for an area you haven't touched recently, when an expensive decision rests on an "obviously…", when a spec draft contains "probably" or "assuming", or when the user says "research this", "investigate this area", or "is it actually true that…". Not for failures — something that broke goes to root-cause.
---

# Research procedure

You are minting **claims** — facts about the system with evidence and a re-check
command — *before* anything prescriptive (a spec, a backlog, a "let's do X") gets
written on top of them. Everything downstream of you has a verifier (spec →
spec-review, implementation → doctrine-review, behavior → gates), but a wrong
premise passes through all of them intact and comes out the other side as correct
code solving the wrong problem. You are the verifier of premises. There isn't
another one.

**You are not here to enable the proposed work. You are here to find out what is
true.** The three outcomes below are all success — and (b) and (c) are worth *more*
than (a), because they are the errors nothing downstream can catch:

- **(a) Enable** — verified claims the spec writer consumes as Step 0 candidates.
- **(b) Kill** — "this direction should not be built, and here is the measurement."
- **(c) Reframe** — "the real question is different; here is what I found instead."

## When to run this (and when not)

- **Before a backlog or spec batch** in an area you haven't personally read this
  week. Writing specs from memory of the code produces drift the implementer
  can't resolve.
- **When "obviously" precedes an expensive decision** (delete, rewrite, build big).
  The comfort of an obvious conclusion is the trigger, not a reason to skip.
- **When a spec draft stalls** on "probably…", "assuming…", or an unfillable
  Failure-modes section. `spec-task` says *investigate first* — this is where that
  investigation goes, instead of a guess or an unrecorded detour.
- **When auditing a proposed task's premise** before investing in speccing it. You
  enter with permission to kill it, not a mandate to complete it.
- **Not when something failed** — reproduction and diagnosis under failure is
  `root-cause` (the special case of this skill for adversarial conditions).
- **Not for a two-minute grep** whose answer kills or redirects no decision.
  That's just reading the code; do it inline. This skill is for questions whose
  answer changes *what gets built*.
- **Never after tasks are created, to validate them.** Research that runs with
  finished tasks in hand degenerates into a justification pass — the question
  becomes "how do I support this?" instead of "what is true?". Premise-checking
  happens before spec effort, with the kill option live.

## Procedure

### Step 1 — Rewrite the request as falsifiable questions
Turn the incoming idea into 1–3 questions with yes/no answers obtainable by reading
or measuring. If you were handed a task or a plan, extract its **premise** and attack
that ("is it actually true that…?"). Bad: "look into the search feature." Good: "is
the catalog sidecar ever loaded at runtime? (grep the loader call sites, then verify
in the network log)".

### Step 2 — Write the kill condition before investigating
For each question, state *in writing, first*: **what answer would kill or redirect
the proposed work?** Then go looking for that answer before anything else. This is
the anti-test of research: if you cannot name what would change your mind, you are
not investigating, you are decorating a decision already made.

### Step 3 — Investigate by reading and measuring, never by recalling
Every finding traces to something you observed *now*: a file you opened, a command
you ran, a number you measured. Memory of the code — yours, the user's, a memory
file's — is a hypothesis to check, not a source. Prefer measurement over reading
where the question allows it (a runtime count beats an inferred one).

### Step 4 — Record findings as claims
A finding enters the doc only in this shape:

```
CLAIM:    <one falsifiable sentence>
EVIDENCE: <file:line, or command + observed output>
VERIFIED: <date>
RECHECK:  <the exact command or file to look at to re-verify this>
```

A finding without a mechanical `RECHECK` goes to a separate **Beliefs** section,
explicitly second-class — a spec may not cite a belief as a Step 0 fact. This is
what makes the doc consumable: claims are Step-0 candidates with the revalidation
already written; prose is not.

### Step 5 — Record verified absences
Keep a mandatory section: **What I looked for and didn't find** — with the search
that failed ("no global positions buffer: grepped X, Y; checked Z"). Verified
absences are the highest-value claims and the ones prose naturally omits, and they
are the difference between "I didn't see it" and "it isn't there."

### Step 6 — Verdict
Close with exactly one of the three outcomes — enable / kill / reframe — in one
paragraph, naming which claims carry it. If the verdict is *enable*, list the claims
a spec writer should lift into Step 0. If *kill* or *reframe*, say precisely which
premise died and what measurement killed it.

### Step 7 — Write it down
`docs/research/<slug>.md` (or the repo's equivalent), same status as a root-cause
writeup. Findings that live only in a chat are lost — and written research is the
only channel through which this work reaches future spec writers.

## Closing the loop

When a spec built on your doc later hits a false claim, triage it like a NOTES.md
entry — it is exactly one of:

- **Research bug** — the claim was wrong when minted (evidence didn't support it,
  or RECHECK checked the wrong thing). Fix the doc *and* ask which step above
  should have forced it.
- **Expired claim** — true when verified, rotted since. Not a failure: that's the
  system working. The RECHECK command existing is what made the rot cheap to detect.

## Anti-patterns to refuse

- **Research theater** — a long plausible doc with zero RECHECK-able claims. Prose
  is the easiest output to fake in the whole pipeline; the claim format is the gate.
- **The justification pass** — investigating in order to support a conclusion the
  requester already holds. Symptom: no kill condition written, or written after.
- **Recommending without evidence** — "I'd suggest X" with no claim underneath it.
  Recommendations are downstream of claims or they don't ship.
- **Answering from memory** — including memory files and prior conversations. They
  point at where to look; they are never EVIDENCE.
- **Skipping the absence section** because "nothing interesting turned up." What
  isn't wired is usually the finding.

## Who runs this

The strong model or the human — never delegated to a cheap executor. This is the
highest-leverage stage in the loop and the easiest to fake: exactly the combination
the doctrine says to keep where the judgment lives. The success metric is not "tasks
enabled" but **decisions changed** — including the ones killed.
