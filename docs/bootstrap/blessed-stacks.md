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
so you must keep **every entry already present in `harnesslint.json`** and add the
per-package ignores alongside them — never retype the defaults from memory and risk
dropping one.

The **single-root web-app layout below avoids this trap** — one root `node_modules/`,
already in the defaults. Prefer it unless the product genuinely needs a workspace.

---

## Validation tooling: a gate and a loop, kept separate

"It builds and lints" says the code is well-formed; it says nothing about whether the
*running system* behaves. Provisioning closes that gap with **two distinct kinds of
tooling**, and the distinction is load-bearing — do not conflate them:

- **Gate tooling — `[mechanical]`.** A *deterministic check wired into `make test` / `make
  ci`*. It is CI-enforced and reproducible, so it turns "did the agent build a working UI /
  correct DB behaviour?" into a gate a machine stops, not a vibe. This is the strong move:
  prefer the **library-as-test** form (e.g. Playwright run from `vitest`/`make test`) because
  it is mechanically enforceable.
- **Loop tooling — `[process]`.** An *MCP that gives the agent eyes during the inner dev
  loop* — drive a browser, read console errors, introspect a DB. High-value for catching slop
  early, but **no checker verifies it ran**, so it is a convention, not an enforcement.

**Wire both, layered.** The gate is the floor (it must be green to merge); the MCP rides on
top for legibility. Keep the honesty tagging from
[../harness/metrics.md](../harness/metrics.md): **gate = `[mechanical]`, MCP/loop =
`[process]`**. Keep it **boring and minimal** — a Playwright smoke + screenshots is enough for
a UI; a seed + one assertion test against a throwaway DB is enough for persistence. Do not
balloon either into an observability platform.

### Per-stack validation-capability matrix

| Stack | Gate (in `make test` / CI — `[mechanical]`) | Loop (MCP, optional — `[process]`) |
|---|---|---|
| **web-app** | Playwright smoke driving **desktop + mobile** viewports, asserting rendered state + capturing screenshots | `chrome-devtools` or Playwright MCP |
| **api-service** | local-boot smoke + HTTP request/response assertion tests | an HTTP / DB MCP |
| **+ database** *(cross-cutting)* | migrations + assertion tests against an **ephemeral** DB (sqlite / testcontainers) | a SQL MCP |
| **cli** | stdin / stdout / exit-code assertion tests | — |

The `+ database` row is cross-cutting: fold it into whichever stack actually persists data.
Always assert against a **throwaway** DB (sqlite file or a testcontainer), never a shared or
real one.

### Template-neutral, provisioned-project-concrete

The **template** stays tool-neutral — it ships **no** `.claude/`, `.codex/`, `.mcp.json`, or
Playwright dependency (see [../agents/running-the-workflow.md](../agents/running-the-workflow.md)
§4). But the **provisioned project is the user's own repo**, so provisioning *does* write
concrete, project-local tool config there: a project `.mcp.json` (Claude Code) and the Codex
MCP-config equivalent for the chosen loop tool, plus the Playwright devDependency and its
`make test` wiring for the gate. State it plainly: **template neutral; provisioned project
concrete.** Network installs stay gated per [../security/baseline.md](../security/baseline.md)
— propose, never auto-install.

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
- **UI validation gate `[mechanical]`** — a **Playwright smoke wired into `make test`** drives
  the running app on **both desktop and mobile** viewports, asserts on rendered state, and
  captures screenshots. Because it runs in `make test`/CI it is a real mechanical gate, not a
  convention.
- **UI validation loop `[process]` (optional)** — a browser MCP (`chrome-devtools` or
  Playwright MCP), written **into the provisioned project**, gives the agent eyes in the inner
  dev loop. High-value, but not a gate.
- *Optional:* an FSD architecture linter wired into `make lint` if the user requests
  Feature-Sliced Design boundary enforcement (the agent picks a concrete tool at
  provisioning time).

**Observability wired:**

- Runtime-error surfacing (console + uncaught errors bubbled into validation).
- Screenshot capture (desktop + mobile) as part of the validation loop.

### Web-app scaffold recipe (copy-pasteable)

> **Verified against Vite 6 / React 19, Tailwind 4, Playwright 1.5x as of 2026-06-16.**
> These tools move fast. Treat the recipe as the shape; re-check the create command and the
> two or three pinned versions against the current releases before relying on it, and update
> this dated note when you do. (Decision: a dated recipe over hard-pinned versions that rot
> silently — see the active exec-plan's Decisions.)

**1. Scaffold into the repo root (single-root layout — avoids the multi-package
`node_modules` trap):**

```sh
# Scaffold in place, at the repo root — NOT into apps/web. One root node_modules/,
# already covered by the default harnesslint.json ignores.
pnpm create vite@latest . --template react-ts
pnpm install
```

`src/` holds the app (`src/main.tsx`, `src/App.tsx`, components, routes). The disposable
tracer `src/index.ts` + `src/index.test.ts` are deleted as part of provisioning.

**2. Tailwind + shadcn/ui:**

```sh
pnpm add -D tailwindcss @tailwindcss/vite      # Tailwind v4: Vite plugin, no PostCSS config
pnpm dlx shadcn@latest init                     # generates components.json + the cn() util
```

Add the Tailwind plugin to `vite.config.ts` and the `@import "tailwindcss";` line to the root
stylesheet per the current Tailwind-v4 + Vite guide. React Router: `pnpm add react-router-dom`.

**3. The Playwright UI-validation gate (the `[mechanical]` move):**

```sh
pnpm add -D @playwright/test
pnpm exec playwright install --with-deps chromium
```

Add **one** smoke spec under `e2e/` that boots the app, asserts a real rendered element, and
screenshots **desktop and mobile** viewports — e.g. `e2e/smoke.spec.ts` with two
`test.use({ viewport })` blocks (a desktop `1280×800` and a mobile `390×844`). Keep it
minimal: one happy-path flow + screenshots is the whole gate. Wire it so `make test` runs it
(either a combined `vitest run && playwright test`, or a `test:e2e` script invoked by the
`make test` target).

**4. The four `make`-target rewrites:**

| Target | New command |
|---|---|
| `make fmt` | `biome format --write .` |
| `make lint` | `biome check . && tsc --noEmit` |
| `make test` | `vitest run && playwright test` |
| `make build` | `tsc -b && vite build` |

(`make lint-harness` and `make ci` are harness-core — **not** rewritten.)

**5. The CI diff** (`.github/workflows/ci.yml`): keep the `npx harnesslint .` step verbatim;
add a `pnpm exec playwright install --with-deps chromium` step before the test run so the
Playwright gate has a browser in CI; the existing `make ci` chaining is unchanged.

**Provisioning checklist:**

- [ ] Scaffold the Vite + React + TS app **at the repo root** per the recipe above
      (Tailwind/shadcn, React Router) — single-root layout.
- [ ] Add the Playwright UI-validation gate: one `e2e/` smoke spec (desktop + mobile, asserts
      rendered state, screenshots) wired into `make test`.
- [ ] *(Optional)* Write a browser MCP config (`chrome-devtools` / Playwright MCP) into the
      project for the inner-loop `[process]` tool — installs gated.
- [ ] Rewrite the four `make` targets (`fmt`, `lint`, `test`, `build`) per the table above.
- [ ] Update `.github/workflows/ci.yml` to run the new targets + install the Playwright
      browser, keeping the `npx harnesslint .` step.
- [ ] Wire enforcement: biome + tsc; the Playwright UI gate (desktop + mobile); add an FSD
      architecture linter only if requested.
- [ ] Wire observability: runtime-error surfacing + screenshot capture.
- [ ] Remove the tracer source (`src/index.ts` + `src/index.test.ts`); keep the Node sliver +
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
- **Local-boot + HTTP assertion gate `[mechanical]`** — tests that boot the service locally
  and assert on real request/response pairs, wired into `make test`/CI (the api-service row of
  the matrix above).
- Boundary / schema validation at the edges (validate inbound requests and outbound
  responses against schemas; reject malformed input at the boundary).
- **If the service persists data** — add the `+ database` gate: run migrations and assert
  against an **ephemeral** DB (sqlite / testcontainers), never a shared or real one. An
  HTTP/SQL MCP is the optional `[process]` loop tool.

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
- **stdin/stdout/exit-code assertion gate `[mechanical]`** — tests that run the built CLI and
  assert on stdout, stderr, and exit codes, wired into `make test`/CI (the cli row of the
  matrix above). No loop MCP applies here.

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
