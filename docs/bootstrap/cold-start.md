# Cold Start

The root [AGENTS.md](../../AGENTS.md) points here under "Starting a new project": this is the
procedure an agent runs to turn the empty template into a real, harnessed project. It is written
to be executed by any agent — Claude Code or Codex — by reading it top to bottom. Follow the
numbered steps in order. They are MUST, not suggestions: if a step cannot be completed, STOP and
ask the human rather than skipping, reordering, or working around it.

**This one-time bootstrap is the project's genesis and runs on `main`** — it writes the
PRD/ARCHITECTURE/plan `001` and (post-approval) provisions the stack directly on `main`, with no
feature branch and no PR, because there is nothing to PR against yet. This is the single
documented exception to the root [AGENTS.md](../../AGENTS.md) "never edit on `main`/`dev`" rule.
Normal branch+PR discipline begins with the **first task after handoff** (step 10): implementing
plan `001`.

## The procedure

### 1. Trigger / detection

Before anything else, decide whether this flow even applies.

You are looking at an **un-bootstrapped template** when all of these hold:

- The **tracer bullet** is still present — a placeholder `src/` (e.g. `src/index.ts`) and the
  tracer-only toolchain (`tsconfig.json`, biome, vitest) wired to the stub `make` targets.
- There is **no committed product PRD** at `docs/references/product/prd.md`.
- There is **no product code** — only harness docs and the tracer bullet.

If those hold, run this flow. If the repo is **already bootstrapped** (a real PRD exists, the
tracer bullet is gone, the `make` targets point at a real stack), **skip this flow entirely** and
go straight to the normal task pipeline in the root [AGENTS.md](../../AGENTS.md). Do not re-run a
cold start on a live project.

### 2. Adaptive interview

Interview the human. The interview has a fixed **core** that is *always* asked, plus
**conditional follow-ups** that fire based on the answers. Typical total is ~20–25 questions, and
**none of them should be irrelevant** — a question only appears when prior answers make it matter.

**Every question carries a recommended default, stated up front.** A one-word answer, a "sure", or
silence means *take the default*. This keeps the interview cheap: the human steers only where they
have an opinion.

**Required core (~8–10 questions, always asked):**

1. **What / why** — what is this product, and what problem does it solve?
2. **Primary users** — who uses it, in what context?
3. **v1 scope** — what must the first version do?
4. **Explicit non-goals** — what is deliberately *out* of v1?
5. **Hard constraints** — budget, deadline, compliance, data-residency, anything non-negotiable.
6. **Stack family** — web app, CLI, service/API, library, mobile, data pipeline, …
   (default: recommend per [blessed-stacks.md](blessed-stacks.md)).
7. **Quality bar** — what does "good enough to ship v1" mean? (see step 4 for how to ask this).
8. **Deployment target** — where does it run / ship? (default: recommend per the stack family).
9. **Operations** — who runs and maintains it day to day? (default: the same individual / small team).
10. **Expected scale** — rough usage and data size for v1 (default: small — single user or a handful).

Items 8–10 are usually waved through on their defaults; ask them anyway so the assumption is on
the record, not implicit.

**Conditional follow-ups (fire on answers):**

- "web app" → UI questions: design direction, key screens, responsive targets, user roles.
- "has auth" / "has accounts" → roles, permissions, session model, sign-in methods.
- "no backend" / "static" → **skip** all persistence and server questions.
- "CLI" / "library" → **skip** all UI and design questions.
- "stores user data" → persistence model, retention, privacy posture.
- "handles money" → payments provider, idempotency, reconciliation expectations.
- "must integrate with X" → the integration's contract, auth, and failure modes.

Keep batching: ask a small batch, record the answers (step 3), then ask the next batch the answers
unlocked. Stop when the core is covered and no fired follow-up is still open.

### 3. Persist as you go

**Never hold 25 answers in context only.** After *each batch*, write the answers to the repo
artifacts they belong to. The repository is the system of record; context is volatile.

| Captured | Goes to |
| --- | --- |
| Product brief (what/why, users, scope, non-goals) | `docs/references/product/prd.md` |
| Stack & architecture decisions **plus the reasoning** | [ARCHITECTURE.md](../../ARCHITECTURE.md) and the active exec-plan's **Decisions** |
| Design direction (only if there's a UI) | a new `docs/DESIGN.md` you author |
| Success criteria | [quality-bar.md](quality-bar.md), filled in place |

The template ships **no** `docs/DESIGN.md` and no generator — author it fresh only when the project
has a UI, with these sections: visual direction / style, key screens, responsive targets, and any
roles or states the UI must express. (For non-UI projects, skip it entirely.)

Record *reasoning*, not just choices — a decision without its "why" rots. The exec-plan template's
`### D-N` blocks (see [docs/exec-plans/template.md](../exec-plans/template.md)) exist for exactly
this.

### 4. Quality-bar elicitation, with an honesty escape

This is the step most likely to produce garbage if rushed. When you ask the quality-bar questions
— "what does success look like?", "what are the critical flows?", "what edge cases must hold?" —
**say this to the human, verbatim in spirit:**

> "If you are not sure, say **'I don't know'**. I will record it as unknown and will **not** guess."

If the human cannot give a **concrete, measurable** criterion, **do not invent one.** Instead:

- Record it as **unknown / deferred** in [quality-bar.md](quality-bar.md) and in the active
  exec-plan's **Open Questions**.
- **Do not** create a project-specific eval gate for that criterion. A badly-worded eval is worse
  than none — it gives false confidence and fails on the wrong thing.
- **Fall back to the harness-level checks** that are always real: build, lint, test, CI, and
  exec-plan traceability — plus whatever concrete criteria the human *did* give.

**Safety stop.** If an unknown touches **safety, compliance, privacy, authorization, payments, or
other high-risk behavior**, you may not paper over it. Either **scope that area out of v1** (and
record the cut), **or STOP and get an explicit human decision** before any implementation. Never
guess a security or compliance boundary.

### 5. Draft a strawman

Once the interview and persistence are done, draft a **concise** strawman and present it:

- A short **PRD** (`docs/references/product/prd.md`).
- An **architecture summary** ([ARCHITECTURE.md](../../ARCHITECTURE.md)): stack family, major
  components, the key decisions and their reasoning.
- The **first execution plan** at `docs/exec-plans/active/001-<slug>.md`, copied from
  [docs/exec-plans/template.md](../exec-plans/template.md). The first plan is always `001`.
- **If the project has a UI:** a short design direction in `docs/DESIGN.md` (style, key screens,
  responsive targets, roles/states). Skip this for non-UI projects.

Present it as a proposal, not a fait accompli.

### 6. React → revise

Let the human correct the strawman. Iterate **cheaply** — these are docs, not code, so churn is
free here. Update the persisted artifacts in place. Loop until the human is satisfied with the
shape of the thing.

### 7. Explicit approval gate (HARD MUST)

**No product code. No real-stack scaffolding. Nothing irreversible — until the human explicitly
approves the strawman.** "Looks fine" or a clear "go ahead" counts; silence does **not**. If you
are unsure whether you have approval, you do not have approval — ask. This gate is the whole point
of steps 1–6: cheap iteration before expensive commitment.

### 8. Provision the stack (post-approval)

Only after explicit approval, provision the stack per [blessed-stacks.md](blessed-stacks.md):

- **Scaffold** the application skeleton for the chosen stack family.
- **Rewrite** the Makefile `fmt` / `lint` / `test` / `build` targets to the real stack tooling.
  (The harness-core `lint-harness` and `ci` targets are **not** rewritten.)
- **Update** `.github/workflows/ci.yml` for the real stack.
- **Wire stack enforcement:** stack linters; **UI validation only if there is a UI**; coverage
  **only if the human asked for it**.
- **Wire** the [docs/observability/checklist.md](../observability/checklist.md) items relevant to
  the stack (logs, runtime errors, screenshots for a UI).
- **Remove the tracer bullet:** delete `src/`, `tsconfig.json`, and the tracer-only dependencies.

**Cross-cutting (applies even to a non-Node stack):** the harness linter is delivered over npm, so
every bootstrapped repo keeps a **minimal Node toolchain**, the **pinned `harness-linter`
devDependency**, and the **`npx harnesslint` CI step**. Do not strip Node thinking it is
stack-specific — it is harness-core plumbing.

**Multi-package workspace guard.** If you introduce a multi-package workspace (`apps/` +
`packages/`), the harness linter will otherwise descend into each package's `node_modules/` and
flag vendored `README.md` / unpaired `AGENTS.md`. Fix `harnesslint.json` `files.ignore` with a
**fully-literal** ignore per package — e.g. `apps/web/node_modules/**`,
`packages/api/node_modules/**` — plus the per-package build dirs (`apps/web/dist/**`). **Do NOT
use `**/node_modules/**` or `apps/*/node_modules/**`** — linter 0.1.2 does not expand globs; only
literal path prefixes match, so a `**` entry silently ignores nothing. Note that `files.ignore`
**replaces** the default ignore list (it does not merge), so you must **keep every entry already
present in `harnesslint.json`** and add the per-package ignores alongside them — never retype the
defaults from memory and risk dropping one. Then re-run `make lint-harness` with no active plan
and confirm zero issues. *(The single-root
web-app recipe sidesteps this entirely — there is one `node_modules/` at the root, already
ignored.)*

### 9. Emit the bootstrap-end scorecard

Print the honest scorecard per [docs/harness/metrics.md](../harness/metrics.md): the
**process-artifacts** produced (PRD, ARCHITECTURE, plan 001, quality-bar) and the
**guardrails-as-proof**, each tagged `[mechanical]` or `[process]`.

**Report the linter line honestly.** Stack lint is clean. The harness gate (`make lint-harness`)
runs at the **first plan close**, not now — and plan `001` is **legitimately active** at this
moment, so the exec-plan-active rule *would* fire. **Do not** claim "harness-clean" or
"`lint-harness` green" here; state that the harness gate is pending the first plan close. Claiming
otherwise is the exact dishonesty the metrics doc forbids.

### 10. Hand off

Bootstrap is complete. Hand off to the **normal task pipeline** in the root
[AGENTS.md](../../AGENTS.md): implement plan `001` through the inner loop (`make fmt` / `lint` /
`test` / `build`), pre-commit review, **then** close the plan, **then** run `make lint-harness`,
then push + PR + CI. From here the project is a normal harnessed repo; this flow does not run again.

## Worked example (smoke fixture)

Using the fixed smoke fixture — **"a simple habit tracker web app"** (see
[smoke-fixture.md](smoke-fixture.md)) — here is one interview batch and the artifact it persists.

**One batch (~3 core questions, each with a default):**

```text
Q1. What is this and why?  (default: a personal habit tracker — log daily habits, see streaks)
> a simple habit tracker web app

Q2. Primary users?  (default: a single individual tracking their own habits)
> (silence — take the default)

Q3. What does "good enough to ship v1" mean?
    If you are not sure, say "I don't know"; I will record it as unknown and not guess.
    (default: create/check-off habits persist across reloads; streaks compute correctly)
> that, plus it should work on my phone
```

"web app" fired the UI follow-ups (design, screens, responsive); "single individual" + no money
mentioned **skipped** the auth, roles, and payments branches.

**Persisted immediately to `docs/references/product/prd.md` (stub):**

```markdown
# PRD: Habit Tracker

## What & why
A simple habit tracker web app. Users log daily habits and see streaks build over time.

## Primary users
A single individual tracking their own habits. (No multi-user / accounts in v1.)

## v1 scope
- Create and name habits.
- Check a habit off for the day; check-offs persist across reloads.
- Show the current streak per habit.
- Usable on a phone (responsive).

## Non-goals (v1)
- Accounts / multi-user / sharing.
- Reminders / notifications.
- Payments.

## Success criteria
- Check-offs persist across reloads. [measurable]
- Streak counts are correct for a given check-off history. [measurable]
- Core flow works on a mobile viewport. [measurable]

## Open questions
- (none deferred in this batch)
```

The stack/architecture answers from later batches go to [ARCHITECTURE.md](../../ARCHITECTURE.md)
and `docs/exec-plans/active/001-habit-tracker.md`; the success criteria above are also mirrored
into [quality-bar.md](quality-bar.md). Had the human answered "I don't know" to Q3, the criterion
would be recorded as **unknown / deferred** in the quality bar and the plan's Open Questions — not
invented — and the harness-level checks (build/lint/test/CI/plan-traceability) would carry the
load.
