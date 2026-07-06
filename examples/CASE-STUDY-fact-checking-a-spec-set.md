# Case study: fact-checking a spec set against a moving codebase

**Context:** [cosmos](https://github.com/MattRosset/cosmos), 2026-07-05. Six task
specs (TASK-069…074) had been written the previous day from research docs plus code
reading. Before handing them to implementing agents, a verification pass re-checked
every factual claim — file paths, line numbers, symbol names, binary formats — against
the actual code.

**Result: three drift bugs found and fixed, and three open decisions pre-resolved.**
One day of drift. Specs written by reading code are snapshots; this is why the spec
format has a mandatory Step 0.

## The three drift bugs

### 1. A load-bearing file cited in the wrong package

The spec said the combine-path fix belonged in `packages/data/src/octree-combined.ts`.
That file doesn't exist — the combine path lives in `apps/web/src/glue/octree-combined.ts`.
A literal implementer would have searched the wrong package and either stalled or,
worse, *moved* the code to match the spec.

**Lesson:** specs must cite paths the way a compiler would — verified, not recalled.
The fix took one `Glob`; the bug it prevented was an agent restructuring a package
to satisfy a typo.

### 2. A signed/unsigned format error

The spec said to decode a binary sidecar as `BigUint64`. Reading the only writer
showed `BigInt64Array` — signed, via `BigInt.asIntN(64, …)`. Harmless for this data
(all values positive), which is exactly what makes it dangerous: it would have worked
until the day it didn't, and the spec would have been the thing that taught the bug.

**Lesson:** for any binary format, the spec's authority is the writer code, not the
design doc. Cite the writer function by name.

### 3. A wiring plan that would have been dead code

The spec said: add boot-time GPU detection "in scene-host init" to choose the initial
quality tier. Verified reality: the `initialQualityTier` prop was passed **explicitly
by seven call sites** (the real app plus six deterministic test fixtures), and the
prop always wins — detection buried inside the library would never fire. The spec was
rewritten to wire detection at the one call site that should use it, keeping the six
test fixtures pinned (they must not depend on host hardware).

**Lesson:** "where does this go" is a judgment call that requires reading the call
sites, not the target file. This is the class of error that makes agent output *look*
done — the code compiles, tests pass, and the feature silently never activates.

## The pre-resolved decisions

The same pass spent its remaining time answering questions the specs had left as
bounded decision rules, by reading code:

- **Index-space question** (which index maps into a binary sidecar): answered by
  finding that tiles already carry a per-star `catalogIds` buffer that survives the
  merge path — the spec now states the exact mapping instead of a warning to verify it.
- **Reverse-lookup strategy** (scan vs. build-time index): option 1's precondition
  ("position derivable without fetching tiles") was checked against the actual pack
  layout — no global positions buffer exists — so the spec now decides option 2 and
  says why option 1 is closed.
- **Payload math:** the chosen option's index file is ~74 MB at production scale; the
  spec now mandates range-request binary search (fixed 16-byte records) with a
  worker-decoded full fetch as fallback, instead of leaving the size for the
  implementer to discover on first keystroke.

## The transferable pattern

A spec is compressed judgment, and judgment has a freshness date. Two practices keep
it honest:

1. **Step 0 in every spec:** list the load-bearing facts (paths, symbols, formats)
   the implementer must re-confirm, with the standing rule *"if reality contradicts
   the spec, stop and update the spec — do not improvise around it."*
2. **A verification pass before handing off a batch:** an hour of `grep`/read by the
   spec author (or a strong model) is cheaper than any one of the failure modes above
   reaching a PR.

The hardened specs are in the cosmos repo under
[`docs/agent-tasks/`](https://github.com/MattRosset/cosmos/tree/main/docs/agent-tasks);
[`TASK-069`](TASK-069-gaia-pick-identity.md) in this folder is the post-hardening
version — its Step 0 shows what "resolved, re-confirm before coding" looks like.
