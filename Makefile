.PHONY: fmt fmt-check lint test build ci lint-harness clean-lifecycle

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
