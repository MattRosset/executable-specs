# Examples — real specs from a real repo

These are unedited task specs from [cosmos](https://github.com/MattRosset/cosmos)
(a 5M-star WebGL galaxy renderer maintained through agent-executed specs), reproduced
here so you can see the format carrying real weight — not toy examples written for a
README.

| File | What to look at |
|------|-----------------|
| [`TASK-071-procgen-tier-lod.md`](TASK-071-procgen-tier-lod.md) | A small (S) mechanical task done right: a "THE TRAP" section encoding a past regression, frozen values that are load-bearing (`low` = 90k is a shipped bug fix), a placeholder value explicitly marked as pending calibration, and a pure-function extraction so the mapping is unit-testable. |
| [`TASK-069-gaia-pick-identity.md`](TASK-069-gaia-pick-identity.md) | A medium task with a **resolved Step 0**: the binary-format and index-space questions were answered by reading the writer code at spec time, so the implementer re-confirms facts instead of making decisions. Note the failure-modes section doing the heavy lifting (BigInt truncation, wrong index space, combine reordering). |
| [`CASE-STUDY-fact-checking-a-spec-set.md`](CASE-STUDY-fact-checking-a-spec-set.md) | Why Step 0 exists: what a verification pass over a six-spec backlog found one day after the specs were written. |

Repo-specific terms you'll see (`pnpm verify`, `__cosmos` query hooks, "frozen
package"): they instantiate the doctrine in this repo — a local all-green command,
app-exposed read hooks for tests, and interfaces that only change via explicit thaw
tasks.
