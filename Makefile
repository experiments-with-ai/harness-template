.PHONY: fmt fmt-check lint test build ci lint-harness clean-lifecycle guard-bootstrapped

# Bootstrap gate — Phase 1 (bootstrap) must complete before Phase 2 (product work). The stack
# targets below depend on this guard, so on a fresh CLONE that is still `unbootstrapped` they
# refuse to run product validation until the cold-start flow flips the bit. Mechanical backstop
# for the prose gate in AGENTS.md / docs/bootstrap/cold-start.md — the Makefile travels with the
# clone, so the rule can't be left behind. EXEMPT (reusing the clean-lifecycle origin idiom):
# template maintainers/CI (origin is the template repo), an already-bootstrapped repo (state flips
# to `bootstrapped`), and FORCE=1 (maintenance forks). A missing BOOTSTRAP_STATE is treated as
# bootstrapped, so deleting it never bricks a repo. Post-flip this guard is permanently inert, so
# the cold-start step-8 rewrite of the four targets below need not preserve it.
guard-bootstrapped:
	@state="$$(cat BOOTSTRAP_STATE 2>/dev/null || echo bootstrapped)"; \
	if [ "$$state" != "unbootstrapped" ]; then exit 0; fi; \
	origin="$$(git remote get-url origin 2>/dev/null || true)"; \
	case "$$origin" in *experiments-with-ai/harness-template*) exit 0 ;; esac; \
	if [ "$$FORCE" = "1" ]; then exit 0; fi; \
	echo "⛔ Repo is UNBOOTSTRAPPED — bootstrap before any product work."; \
	echo "   Phase 1 (bootstrap) has not run. Your only valid next action is the cold-start flow:"; \
	echo "       docs/bootstrap/cold-start.md"; \
	echo "   It interviews you, drafts a strawman, waits for your explicit approval, provisions the"; \
	echo "   stack, and writes 'bootstrapped' to BOOTSTRAP_STATE — which lifts this gate."; \
	echo "   (Template maintainers/CI are exempt by origin; FORCE=1 overrides for maintenance forks.)"; \
	exit 1

# Stack layer — wired to the disposable tracer bullet. The cold-start flow
# (docs/bootstrap/cold-start.md) rewrites these four targets when it provisions a stack.

# Stack formatter, WRITES in place. Use this in the inner dev loop.
fmt: guard-bootstrapped
	pnpm run fmt

# Stack formatter, CHECK only — non-zero exit on drift. Used by `ci` so unformatted code fails.
fmt-check: guard-bootstrapped
	pnpm run fmt:check

# Stack linters only (biome + tsc). Safe to loop on while an exec-plan is still active.
lint: guard-bootstrapped
	pnpm run lint

# Stack tests.
test: guard-bootstrapped
	pnpm run test

# Stack build.
build: guard-bootstrapped
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

# Template-maintenance ONLY. Empties the four lifecycle dirs back to .gitkeep so the distribution
# artifact ships clean (the clean-main / clean-state policy). GUARDED: refuses to run unless origin
# is the template repo, because in a real product repo completed plans/reports are REQUIRED
# history. FORCE=1 overrides (e.g. a maintenance fork). The origin guard is the safety; bootstrap
# may strip this target as hygiene (see docs/bootstrap/cold-start.md step 8).
clean-lifecycle:
	@origin="$$(git remote get-url origin 2>/dev/null || true)"; \
	case "$$origin" in \
	  *experiments-with-ai/harness-template*) : ;; \
	  *) if [ "$$FORCE" != "1" ]; then \
	       echo "refusing: clean-lifecycle is template-maintenance only (origin=$$origin)."; \
	       echo "In a product repo these dirs hold REQUIRED history. Use FORCE=1 to override."; \
	       exit 1; \
	     fi ;; \
	esac; \
	for d in docs/exec-plans/active docs/exec-plans/completed \
	         docs/review/reports/active docs/review/reports/closed; do \
	  find "$$d" -type f ! -name .gitkeep -delete; \
	  touch "$$d/.gitkeep"; \
	done; \
	echo "lifecycle dirs reset to .gitkeep-only."
