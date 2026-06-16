# Exec Plan 004: Scaffold recipes + gate/loop validation tooling

## Goal

Turn "harness-involved" into "reliably high-quality" for the default stacks by making
provisioning concrete and giving the agent **real quality checks** — a mechanical **gate**
(validation wired into `make test` / `make ci`) plus an observability **loop** (an MCP that
gives the agent eyes during the inner dev loop). This consciously expands
`harness-template-plan.md` §16 (which deferred full scaffolds to runtime). Addresses audit
findings #3 (non-deterministic web provisioning) and #4 (UI/runtime validation documented but
no runnable mechanism), the capability-layering carve-out (#5 semantic half), and the user's
"should the harness acquire Playwright/CDT/DB tools?" question.

Docs/config only — no product code, no change to the shipped tracer bullet or `make` targets.

## In Scope

- `docs/bootstrap/blessed-stacks.md` — add the **gate-vs-loop** split, a per-stack
  **validation-capability matrix**, and a copy-pasteable single-root **web-app scaffold
  recipe** with a dated "verified-against" note.
- `docs/bootstrap/cold-start.md` — add **interview-driven detect-and-suggest** of validation
  capabilities folded into the existing approval gate (installs gated, choice recorded); the
  **template-neutral / provisioned-project-concrete** distinction (project-local MCP config);
  and a **presentation-reset** provisioning step (§6.8: README/badges/version/license for the
  new project).
- `docs/harness/capability-layering.md` — Rung 3 **known-stack carve-out** so the
  "no speculative MCP" rule permits a UI-to-drive / DB-to-inspect loop tool at bootstrap.
- `docs/harness/metrics.md` — Part-B line(s) tagging **gate tooling `[mechanical]`** and
  **MCP/loop tooling `[process]`**.
- `docs/observability/checklist.md` and root `AGENTS.md` step 4 — point at the now-concrete
  mechanism (Playwright smoke gate + browser MCP loop), not only the abstract
  drive→snapshot→observe→loop pattern.

## Out of Scope

- Any product code, real-stack scaffold committed into the template, or `make`-target rewrite
  (those happen at bootstrap, in the user's repo — not here).
- Shipping a `.mcp.json` / `.codex` config into the **template** (it stays tool-neutral; the
  concrete config is written into the *provisioned project*).
- The linter glob fix / new linter rules (parallel `harness-linter` track).
- Branch protection (deferred, paid).

## Acceptance Criteria

- [ ] `blessed-stacks.md` carries the gate-vs-loop split, the per-stack capability matrix, and
      a copy-pasteable web-app recipe with a dated "verified-against" note.
- [ ] `cold-start.md` surfaces the tooling/validation plan at the **existing** approval gate
      with installs gated and the choice recorded in the exec-plan Decisions; states the
      template-neutral vs provisioned-project-concrete distinction; and carries the
      presentation-reset step (README/badges/version/license).
- [ ] `capability-layering.md` Rung 3 carries the known-stack carve-out.
- [ ] `metrics.md` tags gate tooling `[mechanical]` and MCP/loop tooling `[process]`.
- [ ] `observability/checklist.md` and `AGENTS.md` step 4 point at the concrete mechanism.
- [ ] Kept boring and minimal — a Playwright smoke + screenshots for UI; a seed + one
      assertion test against a throwaway DB for persistence. No observability-platform balloon.
- [ ] `make ci` green; `make lint-harness` clean (no broken inline paths/links introduced).

## Steps

- [ ] Branch `feat/scaffold-recipes-validation-tooling` off `main`; create this plan.
- [ ] `blessed-stacks.md`: gate-vs-loop split + capability matrix + web-app recipe.
- [ ] `cold-start.md`: detect-and-suggest + neutrality distinction + presentation reset.
- [ ] `capability-layering.md`: Rung 3 known-stack carve-out.
- [ ] `metrics.md`: gate `[mechanical]` / loop `[process]` tags.
- [ ] `observability/checklist.md` + `AGENTS.md` step 4: point at concrete mechanism.
- [ ] Inner loop (`make fmt`/`lint`/`test`/`build`); review; close plan; harness gate; PR; CI.

## Open Questions

- None blocking. The three open decisions from the dogfood plan §9 are resolved below per its
  stated recommendations (D-1, D-2, D-3).

## Decisions

Record every non-trivial choice made while executing this plan. One block per decision.

### D-1: Web scaffold pinning — recipe + dated "verified-against" note (2026-06-16)

- **Context:** dogfood plan §9.2. Three options: exact-pin every version (deterministic but
  rots silently), a maintained reference scaffold app (most deterministic, highest maintenance,
  bakes a stack near the neutral template), or a recipe + dated note.
- **Options considered:**
  - A: exact-pin versions — rejected; pins rot and the template would carry stale numbers.
  - B: maintained reference scaffold — rejected; high maintenance, couples the neutral template
    to one concrete app.
  - C: copy-pasteable recipe (exact create command + single-root layout + target rewrites) with
    a dated "verified against (e.g. Vite 6 / React 19 as of 2026-06-16)" note — chosen.
- **Decision:** ship the recipe + dated note, defaulting to the single-root layout (which also
  sidesteps the #1 nested-`node_modules` trap).

### D-2: Default UI-validation mechanism — Playwright-as-test gate, browser MCP as optional loop (2026-06-16)

- **Context:** dogfood plan §9.3. The strong move is a *mechanical* gate, not a loop-only tool.
- **Decision:** the default is a **Playwright smoke wired into `make test`/CI** (a real
  `[mechanical]` UI gate driving desktop + mobile viewports, asserting rendered state +
  screenshots). A browser MCP (chrome-devtools or Playwright MCP) is layered **on top** as an
  optional `[process]` loop for inner-dev legibility. Both wired, honestly tagged.

### D-3: Project-local tool config — write concrete config into the provisioned project (2026-06-16)

- **Context:** dogfood plan §9.4 / §6.5. The **template** stays tool-neutral (ships no
  `.claude/`/`.codex/`). But the **provisioned project is the user's own repo**.
- **Decision:** provisioning may write concrete project-local tool config into the new repo — a
  project `.mcp.json` (Claude Code) and the Codex MCP-config equivalent, plus the Playwright
  devDependency and `make test` wiring. Stated explicitly as: *template neutral; provisioned
  project concrete.* Network installs stay gated per `docs/security/baseline.md`.

## Notes

- This PR expands `harness-template-plan.md` §16 by choice — it is a scope expansion, not a bug
  fix. Keep the bias toward **boring, legible, minimal**: a Playwright smoke + screenshots is
  enough for UI; a seed + one assertion test against a throwaway DB is enough for persistence.
- The capability matrix and recipe live in `blessed-stacks.md` so the cold-start flow has one
  place to point at; `cold-start.md` references them rather than duplicating.
