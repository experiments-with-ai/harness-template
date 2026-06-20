# Architecture

## Purpose

This is the top-level architecture map. It describes the **harness-core** structure that is
true for every project started from this template, plus **placeholders** that the cold-start
flow (`docs/bootstrap/cold-start.md`) rewrites with project-specific decisions once a stack is
chosen and approved.

Keep this document short, stable, and easy for both humans and agents to navigate. Detailed,
concrete designs belong in focused docs under `docs/` once they exist.

## Harness-core structure (stable across projects)

- **Two-phase bootstrap state machine.** Building from the template has two non-overlapping
  phases — Phase 1 (bootstrap: interview → approval → provision) and Phase 2 (normal task
  pipeline) — recorded in the root `BOOTSTRAP_STATE` sentinel (`unbootstrapped` → `bootstrapped`,
  flipped by cold-start at provision time). A `guard-bootstrapped` Makefile prerequisite blocks the
  stack `make` targets on a clone until the bit flips, so the "bootstrap before product code" rule
  is enforced mechanically (the Makefile travels with the clone), not by prose. Template
  maintainers/CI are origin-exempt, mirroring `clean-lifecycle`.
- **Monorepo-friendly layout.** The template ships as a single root package (the tracer
  bullet). If a provisioned stack is genuinely multi-package, bootstrap introduces an
  `apps/` + `packages/` workspace at that point — not before, and must add a fully-literal
  per-package `node_modules/**` ignore to `harnesslint.json` (see
  `docs/bootstrap/blessed-stacks.md`).
- **`docs/` is the system of record.** Anything an agent needs to do reliable work lives in
  the repo: product brief, architecture, plans, decisions, references. If it only exists in
  chat or someone's head, it is invisible to the agent.
- **Execution-plan lifecycle.** Complex work is captured as a plan in
  `docs/exec-plans/active/`, then moved to `docs/exec-plans/completed/` when it lands. Goal,
  steps, open questions, and decisions live with the plan.
- **External harness linter.** Repository invariants (doc pairing, operational-doc paths,
  exec-plan lifecycle) are enforced mechanically by a pinned npm package, not by prose.
- **Validation loop.** Every change runs `fmt → lint → test → build`, extended after bootstrap
  to make the running system legible to the agent (logs, runtime errors, screenshots).
- **Honest scorecard.** At the end of bootstrap the flow emits a deterministic harness
  scorecard (`docs/harness/metrics.md`): process artifacts + the failure classes the harness
  blocks or makes visible. No fabricated "vs no-harness" numbers.

## System parts (bootstrap fills these in)

### 1. Application(s) — TBD

The user-facing surface(s). Filled at bootstrap with the chosen stack, the application
shape (one app with role-based areas vs. several), routing/permission model if relevant, and
the directory layout. Until then: the disposable tracer bullet in `src/`.

### 2. Backend / Data — TBD

Persistence and business logic, if the project has any. Filled at bootstrap with the chosen
datastore and service boundaries, or explicitly marked **none** for front-end-only or CLI
projects. Business rules and authorization belong here, not only in the UI.

### 3. Enforcement & tooling

- **Always present:** the external harness linter (repository-policy enforcement) and the
  `fmt/lint/test/build/ci` validation loop.
- **Provisioned per stack:** language linters and type checkers, UI/architecture validation,
  coverage gates, and observability wiring — added at bootstrap only where they apply.

## Boundaries

The system should preserve these high-level boundaries, whatever the stack turns out to be:

- The application owns presentation, interaction flow, and local UI state.
- The backend (if any) owns business logic, persistence, and authorization decisions — not
  presentation.
- The harness linter owns repository-policy enforcement, not product runtime behavior; it
  validates repository invariants, it does not replace application tests.

Cross-cutting concerns (auth, telemetry, configuration) should enter through explicit
interfaces rather than bleeding through every layer. Strict, mechanically-enforced dependency
directions are what let agents make large changes without architectural drift.
