# Blessed Stacks

A small, opinionated catalog of stacks the cold-start flow can provision. It is a
starting point, not a constraint — refine it once the product is real.

In this doc, **Default** means the product stack the cold-start flow *proposes when
the user states no preference*. That is distinct from the disposable **tracer
toolchain** — the minimal TS/Node setup the template ships with so the harness is
self-validating from commit zero. The tracer exists to be deleted: provisioning a
stack rewrites the Makefile targets, scaffolds the real project, and removes the
tracer source (`src/index.ts`).

## Cross-cutting constraint: the harness linter is npm-delivered

The harness linter is shipped as an npm package
(`@andrew-semyonov/harness-linter`, pinned in `package.json`, invoked via
`npx harnesslint .`). It is the mechanical enforcement for the **harness core**
itself (AGENTS.md/CLAUDE.md pairing, exec-plan lifecycle, operational-doc path
checks, etc.) and is stack-agnostic.

Therefore **every stack below — including the Go options — keeps a minimal Node
toolchain**:

- `package.json` with the pinned `@andrew-semyonov/harness-linter` devDependency.
- The `npx harnesslint .` step in CI (and the `make lint-harness` target).

Go (or any non-Node) stack adds its own toolchain *alongside* this Node sliver; it
does not replace it. `make lint-harness` runs at the **gate / CI only**, after the
active exec-plan has moved to `docs/exec-plans/completed/` — never in the inner
loop.

## Cross-cutting constraint: multi-package `node_modules` must be ignored literally

If a provisioned stack is genuinely multi-package (`apps/` + `packages/`), each
package gets its own `node_modules/`. The harness linter would otherwise descend into
them and flag vendored `README.md` / unpaired `AGENTS.md`. Add a **fully-literal**
`files.ignore` entry per package to `harnesslint.json` — e.g.
`apps/web/node_modules/**`, `packages/api/node_modules/**` — plus the per-package
build dirs (`apps/web/dist/**`).

**Do NOT use `**/node_modules/**` or `apps/*/node_modules/**`** — linter 0.1.2 does
not expand globs; only literal path prefixes match, so a `**` entry silently ignores
nothing. And `files.ignore` **replaces** the default ignore list (it does not merge),
so any added entry must keep the existing defaults (`.git/**`, `thoughts/**`,
`vendor/**`, `bin/**`, `dist/**`, `node_modules/**`).

The **single-root web-app layout below avoids this trap** — one root `node_modules/`,
already in the defaults. Prefer it unless the product genuinely needs a workspace.

---

## web-app — suggested default product stack

The cold-start flow proposes this when the user has no preference and is building
something with a UI.

**Default toolchain:** Vite + React + TypeScript, Tailwind + shadcn/ui, React Router.

**Make targets:**

```sh
make fmt     # biome format --write
make lint    # biome check + tsc --noEmit
make test    # vitest run
make build   # vite build (tsc for typecheck)
```

**Enforcement wired:**

- `biome` (format + lint) and `tsc` (types) via `make lint`.
- **UI validation** — because it has a UI, both desktop and mobile viewports are
  exercised (drive the running app, assert on rendered state, capture screenshots).
- *Optional:* an FSD architecture linter wired into `make lint` if the user requests
  Feature-Sliced Design boundary enforcement (the agent picks a concrete tool at
  provisioning time).

**Observability wired:**

- Runtime-error surfacing (console + uncaught errors bubbled into validation).
- Screenshot capture (desktop + mobile) as part of the validation loop.

**Provisioning checklist:**

- [ ] Scaffold the Vite + React + TS app (Tailwind/shadcn, React Router).
- [ ] Rewrite the four `make` targets (`fmt`, `lint`, `test`, `build`) for biome /
      vitest / vite.
- [ ] Update `.github/workflows/ci.yml` to run the new targets, keeping the
      `npx harnesslint .` step.
- [ ] Wire enforcement: biome + tsc; UI validation (desktop + mobile); add an FSD
      architecture linter only if requested.
- [ ] Wire observability: runtime-error surfacing + screenshot capture.
- [ ] Remove the tracer source (`src/index.ts`); keep the Node sliver +
      pinned linter devDependency.

---

## api-service

A headless service with no UI.

**Default toolchain:** TypeScript on Node, Hono or Express. Go is an option if the
user asks for it (Node sliver still retained for the linter).

**Make targets (TypeScript default):**

```sh
make fmt     # biome format --write
make lint    # biome check + tsc --noEmit
make test    # vitest run
make build   # tsc (or bundle)
```

**Enforcement wired:**

- biome + tsc (or `gofmt` + `go vet` + `golangci-lint` for the Go option).
- **No UI validation** — there is no UI.
- Boundary / schema validation at the edges (validate inbound requests and outbound
  responses against schemas; reject malformed input at the boundary).

**Observability wired:**

- Structured (JSON) logging.
- Local bootability — the service must start and respond locally as part of the
  validation loop.

**Provisioning checklist:**

- [ ] Scaffold the TS service (Hono/Express) — or the Go service if chosen.
- [ ] Rewrite the four `make` targets for the chosen toolchain.
- [ ] Update CI to run the new targets, keeping the `npx harnesslint .` step.
- [ ] Wire enforcement: biome + tsc (or Go linters); boundary/schema validation at
      edges; no UI validation.
- [ ] Wire observability: structured logging + a local-boot smoke step.
- [ ] Remove the tracer source; keep the Node sliver + pinned linter devDependency.

---

## cli

A command-line tool.

**Default toolchain:** TypeScript on Node. Go is an option.

**Make targets (TypeScript default):**

```sh
make fmt     # biome format --write
make lint    # biome check + tsc --noEmit
make test    # vitest run
make build   # tsc / bundle to a runnable entrypoint
```

**Enforcement wired:**

- biome + tsc (or `gofmt` + `go vet` + `golangci-lint` for the Go option).
- **No UI validation.**

**Observability wired:**

- Structured logs / runtime-error surfacing (exit codes + diagnostics on stderr).

**Provisioning checklist:**

- [ ] Scaffold the CLI (TS entrypoint, or `cmd/` for Go).
- [ ] Rewrite the four `make` targets for the chosen toolchain.
- [ ] Update CI to run the new targets, keeping the `npx harnesslint .` step.
- [ ] Wire enforcement: biome + tsc (or Go linters); no UI validation.
- [ ] Wire observability: structured logs / runtime-error surfacing.
- [ ] Remove the tracer source; keep the Node sliver + pinned linter devDependency.

---

## Escape hatch — "something else"

If none of the above fit, the agent does **not** force a fit. It proposes a boring,
legible toolchain for the actual problem, gets the user's sign-off, and records the
choice **and its rationale** in the exec-plan's Decisions section (see
`../exec-plans/template.md`). Then it wires the same four `make` targets and CI.

**Prefer boring, legible technology** — widely understood tools, stable releases,
and obvious mechanics beat novel or clever ones. The harness rewards anything an
agent can format, lint, test, and build with one command each.

**Provisioning checklist:**

- [ ] Propose a boring, legible toolchain; get user sign-off.
- [ ] Record the stack choice + rationale in the active exec-plan's Decisions.
- [ ] Scaffold the project.
- [ ] Define all four `make` targets (`fmt`, `lint`, `test`, `build`) for the
      chosen toolchain.
- [ ] Update CI to run the new targets, keeping the `npx harnesslint .` step.
- [ ] Wire enforcement appropriate to the stack (UI validation only if there is a
      UI; boundary/schema validation for services).
- [ ] Wire observability appropriate to the stack (structured logs at minimum).
- [ ] Remove the tracer source; keep the Node sliver + pinned linter devDependency.
