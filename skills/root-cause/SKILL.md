---
name: root-cause
description: Diagnose a bug, regression, or flaky behavior by measurement before proposing any fix. Use when something fails intermittently, fails only in one environment (CI vs local), regressed without an obvious cause, or when the user says "root-cause", "why is this happening", or "debug this properly". Produces a research writeup, not just a patch.
---

# Root-cause procedure

You are diagnosing, not fixing. The fix comes out of the diagnosis, never before it.
The deliverable is a **mechanism** — a sentence that explains every observation — plus
the minimal fix that removes it.

## Non-negotiables

1. **Reproduce before you theorize.** If you cannot reproduce it, your first task is
   building the reproduction, not reading code for suspects.
2. **Measure, don't infer.** Every claim in your diagnosis must trace to something you
   observed: a log line, a number, a bisect result. "This is probably X" is a
   hypothesis, not a finding.
3. **One hypothesis at a time.** Rank them by prior probability × cheapness to test.
   Test the cheapest discriminating experiment first.
4. **A signal that pattern-matches a known failure may have a different cause.**
   Confirm the mechanism in *this* instance before applying a known fix.
5. **Never ship a shotgun fix** (several changes at once, hoping one works). If you
   changed three things and it's green, you learned nothing and shipped two no-ops.

## Procedure

### Step 1 — Pin the symptom as a measurement
Write one sentence: *what quantity, measured how, expected vs observed.*
Bad: "the animation looks wrong." Good: "during the transition, drawn point count
drops to 0 for ~40 frames (counted via the app's debug hook)."
If you can't phrase it as a measurement yet, add instrumentation until you can.

### Step 2 — Taxonomy (for recurring/flaky failures)
Before debugging instance N, classify instances 1..N-1. Pull the history
(`git log --oneline -- <path>`, CI runs) and label each prior occurrence:
**product bug** vs **test–environment coupling** vs **infra**. The ratio tells you
whether to fix the product, the test architecture, or the environment — these have
completely different fixes and mixing them up wastes weeks.
*(Worked example: [cosmos' e2e flakiness root-cause](https://github.com/MattRosset/cosmos/blob/main/docs/research/e2e-ci-flakiness-rootcause-and-query-hook.md)
— 16 commits classified, ratio 3:1 env-coupling over real bugs, which redirected the
fix from "patch specs" to "replace the tests' parallel camera model with query hooks
into the running app.")*

### Step 3 — Bisect the space
Halve the search space before reading code in detail. Pick whichever axis is cheapest:
- **Time:** `git bisect` with the reproduction as the test.
- **Config:** toggle flags/features to A/B the failure (LOD on/off, cap high/low).
- **Data:** shrink the input until the failure disappears; the boundary is information.
- **Layer:** log at each boundary (input → transform → output) to find where the value
  goes wrong. The bug is between the last good log and the first bad one.

### Step 4 — Discriminating experiment
For your top hypothesis, design the cheapest experiment where hypothesis-true and
hypothesis-false produce **different observable outputs**. An experiment that passes
either way is worthless — don't run it. State the prediction *before* running.

### Step 5 — Confirm the mechanism
You are done diagnosing when one mechanism explains **all** observations, including
the weird ones ("why only in CI?", "why only at this scale?"). An explanation that
covers 80% of the observations is a different bug plus a coincidence — keep going.

### Step 6 — Fix and verify the fix removes the *measured* symptom
Re-run the Step 1 measurement, not just the test suite. If the fix is in a frozen or
gated area, propose it as a separate reviewed change — never weaken a threshold or
gate in the same PR that makes it pass.

### Step 7 — Write it down
Produce a short research doc (`docs/research/<slug>.md` or equivalent):
symptom → taxonomy → experiments run (with the numbers) → mechanism → fix → what
would have caught this earlier. Findings that live only in a chat are lost.

## Anti-patterns to refuse

- Fixing the test to green without classifying whether the test or the product is wrong.
- "It's flaky, add a retry" — retries are coping tooling; find the nondeterminism.
- Trusting a metric without verifying the thing measured is real (e.g., "smooth
  frame times" on a scene that renders black — verify render before perf).
- Stopping at the *proximate* cause (the line that crashed) instead of the mechanism
  (why that line received a bad value).
