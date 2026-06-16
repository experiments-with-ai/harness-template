# Harness Template

Humans: read [README.md](README.md) and the docs under `docs/harness/` for what this
is and why. Agents: this file is your **map**, not an encyclopedia — follow the workflow
below and open the linked docs when you need detail.

## Key docs

- [ARCHITECTURE.md](ARCHITECTURE.md) — layered model; bootstrap fills the project-specific parts.
- [docs/AGENTS.md](docs/AGENTS.md) — documentation index (the `docs/` system of record).
- [docs/bootstrap/AGENTS.md](docs/bootstrap/AGENTS.md) — **cold-start entrypoint** for a new project.
- [docs/agents/running-the-workflow.md](docs/agents/running-the-workflow.md) — exact command forms per tool (Claude Code, Codex, manual).

## Starting a new project

If this repo is still the empty template — the tracer bullet in `src/` is present and no
product exists yet — **begin with [docs/bootstrap/cold-start.md](docs/bootstrap/cold-start.md)
before any implementation work.** It runs an adaptive interview, drafts a strawman, waits
for your explicit approval, then provisions the stack. Do not write product code before the
approval gate.

## Tooling (generic only)

- Use `gh` for GitHub: PRs, reviews, comments, CI status.
- `make lint-harness` runs the external harness linter (a pinned npm package). It is
  **gate-timed** — see the pipeline below.
- Stack-specific tooling — UI validation, architecture linters, coverage, observability —
  is **provisioned during bootstrap**, not assumed here.

## Repo safety

- Do **not** merge PRs or push directly to `main`/`dev`. Work on a feature branch and open a PR.
- Never commit secrets. See [docs/security/baseline.md](docs/security/baseline.md).

## Workflow

These rules are MUST, not suggestions. If a step cannot be completed, STOP and ask the user
— do not silently skip, reorder, or work around it.

- Pick a plan mode before starting: **lightweight** (mental, unwritten) for a small, obvious,
  single-domain change with no new deps and no architectural/schema/API change; otherwise an
  **execution plan** — copy [docs/exec-plans/template.md](docs/exec-plans/template.md) to
  `docs/exec-plans/active/NNN-<slug>.md`. When in doubt, go execution.
- Keep active plans in `docs/exec-plans/active/`; move finished plans to
  `docs/exec-plans/completed/` when the work lands.

### Task pipeline

1. **Prep.** Decide plan mode; if execution, create `docs/exec-plans/active/NNN-<slug>.md`.
   Branch off `main`. Never edit on `main`/`dev`.
2. **Implement.** Do the work; commit in logical chunks. Prefer a validation loop over
   one-shot generation.
3. **Local checks (inner loop).** Run `make fmt`, then `make lint`, `make test`, `make build`.
   `make lint` is **stack linters only** — loop fix → rerun until green. Do **not** run
   `make lint-harness` here (the harness linter's exec-plan rule will fail while a plan is
   still active — that is by design; it is a gate, not an inner-loop check).
4. **UI validation** *(only if the project has a UI)*. Validate on desktop and mobile per
   [docs/observability/checklist.md](docs/observability/checklist.md). After any change, return to step 3.
5. **Pre-commit review.** Spawn a fresh-context, **read-only** reviewer that follows
   [docs/review/code-review-prompt.md](docs/review/code-review-prompt.md) and emits exactly
   one verdict. On `CHANGES_REQUESTED`, fix → rerun local checks → re-spawn a fresh reviewer
   until `APPROVED`. The reviewer's only write is its own report in
   `docs/review/reports/active/`; **you** (the working agent) move that report to
   `docs/review/reports/closed/` on `APPROVED`. Exact spawn forms per tool:
   [docs/agents/running-the-workflow.md](docs/agents/running-the-workflow.md). If the reviewer
   keeps requesting the same change across three cycles and you disagree, STOP and ask the user.
6. **Close the plan** *(execution only)*. Tick off Steps, finalize Decisions, move the plan
   from `docs/exec-plans/active/` to `docs/exec-plans/completed/`.
7. **Harness gate.** With the plan now closed, run `make lint-harness` (and fix any issue)
   before pushing. This is the only place it runs locally.
8. **Push + PR.** Push the branch and open a PR with `gh pr create`. A PR is always required.
9. **CI.** Watch with `gh pr checks --watch`. CI runs `make ci` (which includes
   `lint-harness`). If red, fix → commit → push → wait. Do not report "done" until CI is green.

## Commands

Generic `make` targets only; the stack-layer targets are rewired at bootstrap.

- `make fmt` — stack formatter, writes in place (inner-loop use).
- `make fmt-check` — stack formatter, check only (fails on drift; used by CI).
- `make lint` — **stack** linters only (safe to loop on while a plan is active).
- `make test` — stack tests.
- `make build` — stack build.
- `make lint-harness` — external harness linter. **Gate/CI only** — run after the active
  plan is moved to `docs/exec-plans/completed/`, never in the inner loop.
- `make ci` — full gate: `fmt-check lint test build lint-harness`, in order.

## Quality checks

Run `make fmt`, `make lint`, `make test`, `make build` at the end of every task. All four are
mandatory; selective skipping is forbidden. "Done" is only reportable once they end green in
the same turn, with output visible. **Never hand-check what a checker can verify** — if a
checker's tooling is missing, install it and run the real check.

The validation loop does not stop at `fmt/lint/test/build`: it extends to **making the running
system legible to the agent** — surface logs, runtime errors, and (for a UI) screenshots. See
[docs/observability/checklist.md](docs/observability/checklist.md).

## Notes

- `AGENTS.md` is the canonical agent entrypoint; `CLAUDE.md` imports it via `@AGENTS.md`.
- Prefer a directory-local `AGENTS.md` when a subtree needs durable guidance that differs from
  its parent. Pair every committed `AGENTS.md` with a sibling `CLAUDE.md` containing `@AGENTS.md`.
- Treat thoughts/ as local scratch space only; it is not a source of truth for the repo.
