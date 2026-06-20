# Harness Template

[![CI](https://github.com/experiments-with-ai/harness-template/actions/workflows/ci.yml/badge.svg)](https://github.com/experiments-with-ai/harness-template/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PRs welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/experiments-with-ai/harness-template/pulls)

A clone-and-go starting point for building software with a coding agent **inside a harness** —
a disciplined environment of docs, conventions, validation loops, and mechanical enforcement
that turns an unpredictable agent into a reliable one.

You don't start by writing code. You clone this template, open your agent, say *"I want to
build such-and-such,"* and the agent runs a structured interview, drafts a plan, waits for
your approval, and **then** builds — with every change flowing through the same validation and
review loop.

## The idea: harness engineering

The approach comes from OpenAI's "Harness Engineering": **humans steer, agents execute**; the
**repository is the system of record**; **`AGENTS.md` is a map, not an encyclopedia**;
**mechanical enforcement beats tribal knowledge**; **validation loops beat one-shot
generation**.

- Concept, for a human evaluating this template: [docs/harness/what-is-a-harness.md](docs/harness/what-is-a-harness.md).
- The principles we adopt: [docs/harness/principles.md](docs/harness/principles.md).
- The source article (kept verbatim): [docs/references/harness-engineering/harness-engineering.md](docs/references/harness-engineering/harness-engineering.md).

## How to start a new project

1. Clone this repository.
2. Open it with Claude Code or Codex (both read the same `AGENTS.md`).
3. Tell the agent what you want to build.
4. The agent follows [docs/bootstrap/cold-start.md](docs/bootstrap/cold-start.md): an
   **adaptive interview** (a required core of ~8–10 questions, then follow-ups that fire on
   your answers), each with a recommended default you can accept or override.
5. It persists your answers to repo artifacts as it goes, drafts a **strawman** (PRD +
   architecture + the intended first build step), and you react and revise.
6. **Explicit approval gate:** no product code until you say go.
7. It provisions the stack, replaces the tracer bullet, flips `BOOTSTRAP_STATE` to
   `bootstrapped`, and emits an honest harness scorecard.

From there, every change goes through the task pipeline in [AGENTS.md](AGENTS.md).

**Two phases, mechanically separated.** Building from this template is a two-phase state machine
recorded in the root `BOOTSTRAP_STATE` file. While it reads `unbootstrapped`, the only valid move
is the cold-start flow above (Phase 1); the stack `make` targets are **gated off on a clone** until
bootstrap flips the bit to `bootstrapped` (Phase 2). This stops an eager agent from skipping the
interview and approval gate to "just build it" — the separation is enforced by the Makefile, which
travels with the clone, not by prose alone.

## What's in the box

- **Two layers, kept separate.** *Harness core* (stack-agnostic: the map docs, `docs/` system
  of record, exec-plan lifecycle, reviewer loop, cold-start flow, linter wiring) ships always.
  The *stack layer* (real `fmt/lint/test/build`, language linters, UI validation, the app
  itself) is provisioned at bootstrap.
- **A tracer bullet** (`src/`) — a trivial "hello world" + test that already passes the full
  `make fmt && make lint && make test && make build` loop. It proves the harness loop works;
  the cold-start flow replaces it.
- **An external harness linter** — a pinned npm package (`@andrew-semyonov/harness-linter`)
  that mechanically enforces repository invariants. No Go toolchain ships here.
- **Execution plans** (`docs/exec-plans/`) — durable, reviewable records of complex work.
- **A read-only reviewer loop** (`docs/review/`) — fresh-context agent review with an
  `APPROVED` / `CHANGES_REQUESTED` contract.
- **A bootstrap-end harness scorecard** (`docs/harness/metrics.md`) — honest process artifacts
  and the failure classes the harness blocks; no fabricated counterfactuals.

## Quick start

The template ships green. With Node 22+ and pnpm:

```bash
pnpm install
make fmt      # format
make lint     # stack linters (biome + tsc)
make test     # tracer-bullet test
make build    # tsc build
```

> **On a clone, those four targets are gated until you bootstrap.** `BOOTSTRAP_STATE` ships
> `unbootstrapped`, so on your own repo `make fmt/lint/test/build` print a STOP banner pointing at
> the cold-start flow — that's the point: bootstrap first. To kick the tracer's tires before
> bootstrapping anyway, prefix with `FORCE=1` (e.g. `FORCE=1 make test`). The gate lifts on its own
> once bootstrap flips the bit.

`make lint-harness` runs the repository-policy linter; it is gate-timed (run it once an
execution plan is closed), and `make ci` chains the whole gate together. See [AGENTS.md](AGENTS.md)
for the full pipeline.

## Repo map

```text
harness-template/
├── README.md              # this file (human-facing)
├── AGENTS.md              # agent map + task pipeline (Claude reads CLAUDE.md → @AGENTS.md)
├── ARCHITECTURE.md        # layered model; bootstrap fills the project-specific parts
├── BOOTSTRAP_STATE        # phase sentinel: unbootstrapped → bootstrap; flipped at provision
├── Makefile               # fmt / fmt-check / lint / test / build / ci / lint-harness
├── package.json           # single root package; pinned packageManager + linter dep
├── biome.json             # tracer formatter + linter config (stack layer)
├── tsconfig.json          # tracer build config (stack layer)
├── harnesslint.json       # harness linter config (core)
├── src/                   # tracer bullet — replaced at bootstrap
└── docs/
    ├── harness/           # human concept docs (what-is, principles, metrics, capability-layering)
    ├── agents/            # neutral runner: Claude + Codex + manual command forms
    ├── bootstrap/         # the cold-start flow + blessed stacks + quality bar + smoke fixture
    ├── exec-plans/        # active/ + completed/ + template.md
    ├── review/            # read-only reviewer prompt + report lifecycle
    ├── security/          # security baseline checklist
    ├── observability/     # post-bootstrap observability checklist
    └── references/        # harness-engineering article; product/ (bootstrap writes the PRD)
```

This is a greenfield template. Brownfield adoption (adding a harness to an existing repo) is
a separate, later effort.
