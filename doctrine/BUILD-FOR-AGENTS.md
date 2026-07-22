# Build-for-Agents Doctrine — Making the Repo the Agent's World

> Generated file — a genericized export of my private doctrine original. Don't edit it
> here; edits belong upstream and get re-exported (see [PROPAGATION.md](../PROPAGATION.md)).

**Status:** Living document
**Case studies:** [cosmos](https://github.com/MattRosset/cosmos) — its
[`CLAUDE.md`](https://github.com/MattRosset/cosmos/blob/main/CLAUDE.md),
[`docs/testing-conventions.md`](https://github.com/MattRosset/cosmos/blob/main/docs/testing-conventions.md),
[`eslint.config.js`](https://github.com/MattRosset/cosmos/blob/main/eslint.config.js), the
[`__cosmos` test hook](https://github.com/MattRosset/cosmos/blob/main/apps/web/src/glue/test-hook.ts),
and [`docs/research/`](https://github.com/MattRosset/cosmos/tree/main/docs/research) — plus a
second, private project (a gym-management CRUD app, referred to below as *gym-manager*); and
the spec-vs-control experiments in [`EVALS.md`](../EVALS.md).

This is not a patterns catalog. It is a **philosophy and contract** for building a codebase in which an agent — with no memory of your project and no access to your intentions — does the right thing by default.

---

## 1. Core belief

> An agent arrives with **no memory of your project** and leaves with none. The repo is
> its **entire world**. Everything it needs to act correctly must be reachable from the
> files in front of it, at the moment it makes the decision.

This inverts the usual framing. I caught myself asking "how do I write a better prompt/spec?" The experiments ([`EVALS.md`](../EVALS.md)) answered a different question: across five controlled runs, an agent given a *casual* prompt in cosmos performed nearly as well as one given a full spec — because **the repo taught it**. Green suites, frozen boundaries, dense correct precedent, and written-down doctrine did the work the spec was supposed to do.

Corollary: **your leverage is not in the instruction you give per task; it's in the world the agent wakes up in.** A spec is a one-shot message; the repo is a standing teacher that never gets tired and is present at every keystroke. Invest there.

Every rule below is a way of putting the right knowledge *where the agent will hit it*.

---

## 2. Doctrine lives in the repo, not in your head

The single most-replicated finding: unaided control agents re-derived the project's testing doctrine **correctly, without being told** — because it was written down where they read (`CLAUDE.md` → `docs/testing-conventions.md`). In gym-manager the same held (`CLAUDE.md`/`AGENTS.md` + dense sibling tests).

**Rules:**
- A short entry file (`CLAUDE.md`) that an agent reads first, pointing to deep docs. Keep the entry short; depth lives in `docs/`.
- State the *non-negotiable* rules inline in the entry file so they're always in context, then link the full guide. (cosmos does exactly this with the six testing rules.)
- If a rule matters, it must exist as prose an agent will encounter — not as tribal knowledge, not only in your memory, not only in a closed PR conversation.

**Test:** delete yourself from the project for a month. Could a competent stranger — human or agent — recover *why* the code is shaped this way from the repo alone? What they couldn't recover is what you failed to write down.

---

## 3. The reason rides with the constraint, at the point of violation

The strongest single teaching mechanism observed: a load-bearing constant (`90_000`) carried a **comment block** explaining it was pinned for a CI gate. A spec-less agent editing nearby *read it and kept it*, preserving a regression history nobody handed it. Doctrine embedded in code comments is a spec that never leaves the code.

Contrast: the eslint boundary rules don't just forbid an import — each message says *why* and *names the correct move* (`Math.random()` → "Use `createPrng` from @cosmos/core-types"; a cross-group import → "Only apps/web glue crosses groups (§4)").

**Rules:**
- Put the reason **where the change happens**, not in a wiki page the agent won't open. A comment at the edit site beats a doc three clicks away.
- A constraint should explain itself *and* point to the right alternative at the moment it's tripped. "Don't do X" teaches less than "Don't do X because Y; do Z instead."
- Load-bearing values get a comment naming what breaks if they change and which gate enforces them.

**Anti-pattern:** a magic number with no comment. The next editor — human or agent — has no way to know it's load-bearing, so they "clean it up," and the regression returns.

---

## 4. Machine-enforced boundaries beat documented ones

cosmos freezes its architecture in [`eslint.config.js`](https://github.com/MattRosset/cosmos/blob/main/eslint.config.js): `no-restricted-imports` per package group, deep-imports banned, `Math.random()` banned in pure packages. An agent **cannot** cross a boundary without a red gate that tells it the correct move — no judgment required, no chance to rationalize.

Where this held, frozen surfaces stayed frozen. The one frozen-surface *violation* in the experiments came from a package the lint didn't cover, rationalized by a plausible-but-wrong judgment. Documentation says "please don't"; a failing lint rule makes "don't" the path of least resistance.

**Rules:**
- Encode architecture as **lint/CI, not documentation**, wherever it's mechanizable. Boundaries, banned APIs, determinism rules, public-API-only imports.
- Every enforced rule's error message teaches (see §3).
- Prefer **one tool with complete rules** over two tools with partial coverage — a half-covered boundary is the gap the next violation walks through. (Cosmos completed the existing lint rules rather than adding a second enforcer on top of an incomplete one.)

**Corollary:** the cheaper code gets, the more an agent will *write*, fast — so the guardrails have to be automatic. You cannot review your way to a boundary an agent can violate in one afternoon across twelve files.

---

## 5. One deterministic gate, and keep it honest

cosmos gives one command — `pnpm verify` (lint + typecheck + unit + build) — that *is* the local gate. Its CI counterpart gates **deterministic proxies only**: correctness assertions and work-budget caps block; screenshots and wall-clock perf are reference-machine only.

"Green doesn't discriminate" was true in every experiment — both arms always passed. That is the *point*, not a flaw: the gate clears the entire mechanical class so the human and the agent spend their attention on judgment, which is the only thing the gate can't check. Equally important, the gate is **not flaky** — a gate that cries wolf (CI screenshots on a contended runner) teaches the agent, correctly, to ignore it.

**Rules:**
- One command an agent can run to know if it's done. Fast enough to run often.
- Gate on **invariants and deterministic proxies**, never on incidental machine/build-specific values. Non-deterministic checks (screenshots, wall-clock perf) are reference-only, tagged, and excluded from the blocking gate.
- If a tier of tests only ever runs in CI, it never "passed locally" — give it a local command too, or "passes local, fails CI" is structural, not bad luck.

**Test for gate honesty:** if the gate goes red, is it *always* the code's fault? If sometimes it's the runner's fonts or CPU, the gate is teaching everyone — human and agent — to disregard red. Fix the gate, not the symptom.

---

## 6. Correct precedent is the strongest teacher — the first example gets copied

Agents mirror what's already in the repo. In gym-manager the unaided agent **found and reused** the existing confirm-dialog precedent (a `Dialog` component already in the tree) instead of inventing one — producing a smaller, more consistent change than the spec that prescribed a heavier component. Dense, correct sibling tests produced dense, correct new tests.

This cuts both ways, and that's the whole point: **precedent is the strongest teacher, so bad precedent teaches bad, at scale.** The first time you do anything in a repo, you are writing a teaching artifact that will be copied.

**Rules:**
- The **first** example of any pattern (the first test, the first store slice, the first API route, the first data-fetch) is doctrine-by-example. Spend disproportionate care on it.
- Before pre-resolving a "how should this be built" decision, **grep for whether the repo already does it somewhere** — reuse the existing precedent rather than introduce a second way. (A spec-time and code-time checklist item.)
- Prune or fix bad precedents actively; a wrong pattern left in the tree recruits copies.

---

## 7. Expose a read seam, so the agent asks instead of re-deriving

Cosmos's chronically flaky spec was the one that kept a **parallel model** of production (≈150 lines re-implementing camera projection, picking, HUD geometry). Given a task that needs to know app state, an agent will happily build such a model — long, drifting, and leaking environment details. The fix was a thin [read hook](https://github.com/MattRosset/cosmos/blob/main/apps/web/src/glue/test-hook.ts) (`window.__cosmos`: `pickAt`, `projectToScreen`, `selectedId`, error counts) that lets the test **ask the app** for the real value.

**Rules:**
- Expose a **thin, documented read seam** onto real runtime state — the same path production uses — so tests (and agents) query truth instead of re-deriving it.
- When a new task needs to observe app state, add a field to the seam rather than scraping the DOM or modelling the app.
- Generalizes beyond tests: any place an agent would otherwise reconstruct production logic to observe it, give it a query instead. Two copies of the same logic drift; the seam has one.
- **Extend the same rule to your own reasoning:** current state — the code you open, the value you measure *now* — is truth; **recall is a hypothesis to check, never evidence.** Memory (yours, the user's, a memory file's) points at where to look; it is never the finding. Re-deriving a fact from memory is the same default move as re-deriving production logic, and the same fix applies: read or measure the real thing. (Independently re-stated in the [`research`](../skills/research/SKILL.md), [`root-cause`](../skills/root-cause/SKILL.md), and [`spec-task`](../skills/spec-task/SKILL.md) skills — "never by recalling", "measure, don't infer", "a spec written from memory produces contradictions"; graduated here as the epistemic floor those three share.)

**Why it matters for agents specifically:** re-derivation is an agent's *default* move — it's locally reasonable and it compiles. A visible seam makes "ask" easier than "reimplement," which is the only reliable way to win that default.

---

## 8. Write down why things *failed*, not just how things work

The one thing that did **not** transfer through code in the experiments: **repo-historical failure modes.** Both unaided agents missed a failure that lives only in project history (a fade band too narrow relative to flight speed pops mid-transit) — no code comment sits at the place you'd wrongly edit, because the wrong edit *compiles and passes*. Only the written answer-key had it.

Contracts and structure transfer through code; **scar tissue transfers only if you write it down.** This is what [`docs/research/`](https://github.com/MattRosset/cosmos/tree/main/docs/research) is for — root-cause writeups that carry the "we tried the obvious thing and here's why it broke" that no type signature can hold.

**Rules:**
- Keep a `docs/research/` (or equivalent) of root-cause writeups: symptom, measurement, root cause, the fix, and the **blind spot** (why the existing gate/obvious edit missed it).
- Write down the failures whose wrong fix is *invisible* — the ones that compile, pass, and look done. Those are exactly the ones an agent (or future you) will re-commit.
- A fix isn't real until it's **committed and gated**; a fix that lived only in a working tree got lost once and the bug shipped for weeks. The writeup records the gate that now guards it.

---

## 9. The honest boundary — replayed decisions are cheap, novel decisions are not

This doctrine has a hard limit, and stating it is what keeps the rest credible.

The blunt version is "the environment makes *correctness* cheap but not *judgment*." That's close, but the evidence sharpens it. The real line is:

> A well-built repo makes cheap the judgment that has **already been made and left behind** — as precedent, contract, or convention. It does **not** make cheap **novel** judgment: a decision the repo has never encountered and no convention settles.

Both halves are in the experiments, and the second one is why the line isn't just "correctness vs judgment":

- **Replayed judgment looks like judgment but isn't.** In the CRUD run, an unaided agent *out-judged the spec twice* — it reused the repo's existing confirm-dialog precedent instead of the heavier component the spec prescribed, and added a confirmation the spec never asked for. Both feel like reasoning; neither is. The first is precedent-copying (§6) — the decision was made by whoever wrote the first dialog. The second is a generic convention ("destructive action gets a confirm") the agent brought from training. The repo (and broad norms) **replayed** decisions already made.
- **Novel judgment stays expensive.** In the spec-writing run, the same tier of agent, in the same scaffolded repo, fused an *un-precedented* design decision into an implementation task (a blend-mode architecture choice — additive blending can't darken) and extended a core type as a silent side effect. No precedent existed for that call, so nothing in the environment caught it, and the agent smuggled it in as if it were mechanical.

**Rules:**
- Use the environment to delegate everything mechanical **and everything already-decided**; **keep genuinely new decisions explicitly quarantined** for a human — or for a method that forces the mechanical-vs-judgment split before work starts.
- Do not read "the agent did great in my repo" as "the agent has judgment." It replayed *your* judgment, pre-installed in the world you built. The test of judgment is a decision the repo has **never** faced.
- The scarce input the repo cannot supply is **accumulated project memory** and **un-precedented design calls** — which is exactly why §8 exists and why design stays quarantined.
- **A spec is a channel: it transmits your judgment *and your errors* with equal fidelity.** An authored instruction reaches the executor with the same authority whether it is right or wrong, so a *prescribed* wrong decision is worse than none — the executor obeys it instead of falling back on the repo's precedent. In [`EVALS.md`](../EVALS.md) exp 3 a spec that prescribed a new primitive where the repo already had the pattern produced a *worse* diff than the unaided control. Consequence: a pre-resolved decision must clear a **higher** bar than an unaided reading would — before prescribing, grep the repo for existing precedent and earn the obedience you are about to command. (Graduated from the [`spec-task`](../skills/spec-task/SKILL.md) skill's rule 5.)

**Open confound (stated, not hidden):** every run behind this section used a **mid-tier executor**. A stronger model might natively defer a decision it isn't sure about — which would mean novel judgment gets cheaper with *model capability*, independent of scaffolding. The one experiment that could soften this claim (strong model, no spec) was deliberately deferred and **not yet run**. **What would falsify §9:** a strong agent, in a repo with *no precedent* for a decision, reliably flagging "this needs a human call" instead of smuggling it — with no method prompt, from the environment alone. That did not happen at the tier tested; it has not been tested at the top tier.

---

## 10. Anti-patterns (the weak-environment table)

| Weak pattern | Why it costs you |
|---|---|
| Doctrine only in your head / closed PRs | The agent (and the next hire) can't reach it; it re-derives or guesses |
| Magic number with no comment | Read as noise; "cleaned up"; the regression returns |
| Boundaries enforced by documentation, not lint/CI | "Please don't" loses to the path of least resistance |
| Two partial enforcers instead of one complete one | The gap between them is where the next violation walks |
| Flaky gate (CI screenshots, wall-clock perf) | Teaches everyone to ignore red |
| Gate on incidental machine-specific values | Passes local, fails CI; noise, not signal |
| A sloppy *first* example of a pattern | Gets copied at scale before you notice |
| No read seam onto real state | The agent reconstructs production logic — long, drifting, env-coupled |
| Failure history unwritten | The invisible-wrong-fix gets re-committed; scar tissue lost |
| Reading agent success as agent judgment | You ship an unreviewed design decision fused into a task |
| Improvising around a spec/reality contradiction | Fakes progress past the point the contract broke; the divergence ships silently (§14) |
| Prescribing a decision without grepping the repo's precedent | The spec's authority carries your error too — a worse diff than no spec (§9) |
| Asserting from recall instead of reading/measuring now | Memory is a hypothesis; unverified, it drifts into the artifact as fact (§7) |

---

## 11. Evidence and confidence

Stated plainly, in this project's own promotion discipline: this is **two repos** (cosmos, gym-manager), a **mid-tier executor model**, and **small/mechanical tasks**. These are strong hypotheses **with one replication** — rules §2, §4, §5, §6, and the boundary in §9 held across *both* projects (§9's "replayed vs novel" split is drawn from the CRUD run *and* cosmos); §3, §7, §8 rest primarily on cosmos so far. A pattern earns "law" status when it survives contact with a genuinely different domain and executor. Treat the single-project rules as 🟡 (promote on second sighting) and the replicated ones as 🟢 — with §9 carrying its own open confound (untested top-tier executor).

**Separate open question (deliberately out of scope here):** this doctrine describes the *habitat* an agent works in; it does **not** claim credit for how the habitat got built. The loop *itself* is now stated doctrine (§13); what remains an untested **attribution** is whether running that loop reliably *produces* such a habitat — a distinct claim, with a real reverse-causality confound, since several of these skills were distilled *from* this project. It is tracked in my private learnings and promotable via a cross-project validation step.

---

## 12. Prediction-first hook (how to learn this, not just run it)

Before your next project (or your next big feature in an existing one), write 5 lines: which of §2–§8 your repo currently satisfies, and the *one* you predict will bite an agent first. Then hand a real task to an agent with a deliberately thin prompt and watch where it stumbles. **The gap between your prediction and where it actually stumbled is the lesson** — when the same gap repeats across projects, it's a rule for your own playbook.

---

## 13. The method improves itself — triage every judgment call

The habitat (§2–§8) is not static; it is the *output* of a loop, and the loop is doctrine of its own. Every task an executor runs surfaces decisions the task didn't settle — *judgment calls*. Logged and triaged, each one either hardens the world the next agent wakes up in, or is a lesson paid for and thrown away.

**Rules:**
- Implementing agents **log every judgment call** (anything the task didn't decide) to a NOTES file — visibly, as they go, not reconstructed after the fact.
- After merge, triage **every** entry into exactly one of three:
  - **Spec bug** — a fact was missing or wrong. Fix the spec.
  - **Executor bug** — the spec said it; the agent ignored it. An executor-quality signal, *not* a doctrine change.
  - **Doctrine gap** — the template/skill/doctrine never asked for what was needed. Edit it *now*, citing the incident.
- An untriaged NOTES entry is a lesson paid for and thrown away. The triage, not the logging, is the load-bearing half.

**Evidence (provenance, not A/B):** this loop is *how* the mandatory Step 0 section and the stack-facts rule entered [`SPEC-TEMPLATE.md`](../SPEC-TEMPLATE.md), and how the grep-for-precedent checklist item entered the [`spec-task`](../skills/spec-task/SKILL.md) skill — each from a triaged judgment call in a real run ([`EVALS.md`](../EVALS.md) Experiment 3 "Feeding the loop" and §"The self-improvement loop"). Graduated from the `spec-task` skill, where it lived siloed: the loop is cross-cutting (it governs implementation, review, *and* the evolution of this doctrine), so it belongs in the doctrine it feeds. It answers the open question in §11 only halfway — the loop is now *stated*; the attribution that running it *produces* the habitat is still untested.

---

## 14. Stop at contradictions — the honesty floor

The one executor-conduct rule strong enough to be doctrine, and the only rule in this file with a **controlled measurement** behind it.

> If reality contradicts the spec — the code has moved, two requirements can't both hold, the visible test conflicts with the stated goal — **stop and update the spec (or mark blocked). Do not improvise around it.**

**Why it's doctrine, not a template detail:** it is cross-cutting — spec-review enforces it as internal consistency, the executor obeys it at implementation, review checks for it — and its *wording* is load-bearing.

**Evidence (measured):** in a separate agent-integrity experiment (a slugify task with a seeded spec/test conflict, `gpt-oss-20b`, n=20), from a **90% baseline** cheat rate this **firm** phrasing as a system-prompt clause cut cheating to **0%**, while the doctrine's softer equivalent ("permission to fail honestly is a valid answer") only reached **40%** — same model, the other clauses byte-identical, so firmness was the only variable. It did **not** over-refuse: **95% solve** on a feasible task, 0% false blockers — the rule fires only when a contradiction actually exists.

**Rules:**
- **Use the firm wording.** The [`SPEC-TEMPLATE.md`](../SPEC-TEMPLATE.md) Step 0 phrasing is the **canonical source** of the words (it is what measured the effect); this doctrine adopts it and adds the *why*. Keep the instance in the template — graduating a principle to doctrine never empties its point-of-use instance (doctrine holds the *why*; the template holds the *instance where the agent hits it*).
- **Caveat, stated (do not over-claim):** the measurement is one model, a *blatant* conflict. On a *buried* conflict — where the model never registers the contradiction — firm wording is **untested** and predicted not to help; you can't stop at a contradiction you don't see (there the *soft* doctrine stayed at ~85% cheat, and firm wording was deliberately not yet run on it). The general law "firm always beats soft" is **not** graduated; only this specific, blatant-conflict rule is.
