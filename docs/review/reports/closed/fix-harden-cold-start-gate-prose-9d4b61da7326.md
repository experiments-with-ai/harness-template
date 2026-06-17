# Pre-commit review

- **Branch:** `fix/harden-cold-start-gate-prose`
- **HEAD:** `9d4b61da7326`
- **Base:** `main` (merge-base `e709e488974b`)
- **Unit of review:** `git diff main...HEAD`
- **Prior report:** none in `docs/review/reports/active/` (only `.gitkeep`) — fresh review.

## What changed

Prose-only hardening of the cold-start approval gate, plus the exec-plan that tracks it.

- `AGENTS.md` (+14/−4): adds a "no exemption for small/creative/one-off" clause to the
  "Starting a new project" no-product-code line; adds a gate-precedence paragraph to "Workflow"
  and scope-fences the plan-mode choice to *post-handoff only*.
- `docs/bootstrap/AGENTS.md` (+3/−1): extends the Hard rule with the same no-exemption clause and
  routes the proportionality call to the user.
- `docs/exec-plans/active/001-harden-cold-start-gate-prose.md` (new, 78 lines): the Layer-0 plan.

No source/code changes; no new dependencies; no mechanical/CI/settings changes.

## Judgement

**1. Correctness.** The new prose is internally consistent and consistent with the rest of the
docs. The gate-precedence paragraph (AGENTS.md:49–54) and Task-pipeline step 1 (AGENTS.md:67–74)
agree with `docs/bootstrap/cold-start.md` on the genesis model: genesis runs on `main`, writes no
exec-plan, and plan `001` is born on the first post-handoff branch (cold-start.md:9–16, 244–251).
The plan-mode scope-fence ("post-handoff only") matches the handoff boundary cold-start.md draws
at step 10. The strengthened `docs/bootstrap/AGENTS.md` Hard rule is consistent with cold-start.md
step 7 (the HARD MUST approval gate). No contradiction with the existing plan-mode guidance, the
bootstrap genesis model, or cold-start.md was found. The reflowed plan-mode list item
(AGENTS.md:56–61) is a source-wrap only and renders as one coherent bullet.

**2. Tests.** N/A — docs-only change; no behavior to cover. The plan's acceptance criteria
include `make fmt lint test build` and `make lint-harness` green at the gate, which are the
working agent's responsibility per the pipeline; the reviewer does not run them.

**3. Security.** No security surface. No secrets, no code, no config. Repo-safety prose unchanged.

**4. Simplicity.** Minimal, targeted edits that close exactly the "proportionality / small
creative one-off" vocabulary foothold described in plan D-1. No dead text, no redundant
restatement beyond the deliberate (and useful) reinforcement at each decision point. The plan is
honest about scope: D-2 frames Layer 0 as *lowering the probability* of rationalization, not a
hard guarantee, and explicitly defers Layers 1–2.

**5. Repo conventions.**
- All markdown links added in the diff resolve to real files
  (`docs/bootstrap/cold-start.md`, `docs/exec-plans/template.md`, `docs/security/baseline.md`
  pre-existing); directory references stay as inline code — honoring the
  `docs/AGENTS.md` links-vs-inline-code rule the harness linter enforces. No directory is linked.
- No new `AGENTS.md` is added, so the AGENTS.md/CLAUDE.md pairing rule is not triggered; the new
  plan is correctly named `001-harden-cold-start-gate-prose.md` (not an `AGENTS.md`).
- The exec-plan follows `docs/exec-plans/template.md` structure (Goal, In/Out Scope, Acceptance
  Criteria, Steps, Open Questions, Decisions with `### D-N` blocks, Notes).
- Plan claims verified against the repo: `make clean-lifecycle` exists and is origin-guarded
  (`Makefile:42`); the delete-before-merge lifecycle matches `docs/maintaining-the-template.md`;
  the cited "no `.claude/settings.json`" tool-neutral stance is real
  (`docs/agents/running-the-workflow.md` §4) and no `settings.json` is tracked; the "doc-tripwire
  grep idiom" Layer 1 would reuse exists in `.github/workflows/ci.yml`; the `habit-smoke` dogfood
  is referenced in `docs/bootstrap/blessed-stacks.md:139` (`habit-smoke-v2` appears only inside
  this plan's D-1 context, which is acceptable as a historical reference).

## Conclusion

Clean, internally consistent, convention-conforming prose-only template-maintenance change. The
hardening is correct and contradicts nothing; the exec-plan is coherent and its load-bearing
claims are grounded in the repo. No defects found across correctness, tests (N/A), security,
simplicity, or conventions.

VERDICT: APPROVED
