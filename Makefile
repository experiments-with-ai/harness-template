.PHONY: fmt fmt-check lint test build ci lint-harness

# Stack layer — wired to the disposable tracer bullet. The cold-start flow
# (docs/bootstrap/cold-start.md) rewrites these four targets when it provisions a stack.

# Stack formatter, WRITES in place. Use this in the inner dev loop.
fmt:
	pnpm run fmt

# Stack formatter, CHECK only — non-zero exit on drift. Used by `ci` so unformatted code fails.
fmt-check:
	pnpm run fmt:check

# Stack linters only (biome + tsc). Safe to loop on while an exec-plan is still active.
lint:
	pnpm run lint

# Stack tests.
test:
	pnpm run test

# Stack build.
build:
	pnpm run build

# Harness core — always present, never rewritten by bootstrap.
# External harness linter (pinned @andrew-semyonov/harness-linter). GATE/CI ONLY: run it
# after the active plan is moved to docs/exec-plans/completed/, never in the inner dev loop
# (else exec-plan-active-present is a guaranteed false positive). Assumes `pnpm install` has run.
lint-harness:
	npx harnesslint .

# Full gate. Run with the active exec-plan already closed (CI runs against the closed PR).
# Uses fmt-check (not the writing fmt) so format drift fails instead of being silently fixed.
ci: fmt-check lint test build lint-harness
