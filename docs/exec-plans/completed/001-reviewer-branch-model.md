# Exec Plan 001: Reviewer branch-diff model + branching discipline

## Goal

Make the pre-commit reviewer review the *right thing* deterministically — the branch's full
delta against `main` (`git diff main...HEAD`) — and make the read-only contract and the
cold-start branching exemption explicit. This is the keystone PR of the dogfood plan
(`harness-template-dogfood-plan.md` §3). Fixes audit findings #2, #6, #7, #9.

## In Scope

- Reviewer reviews `git diff main...HEAD` (three-dot, since merge-base with `main`), not the
  working-tree `git diff HEAD`.
- Mandate commit-before-re-spawn in the CHANGES_REQUESTED loop, so HEAD advances and reports
  self-stale each round.
- Pin SHA abbreviation to `git rev-parse --short=12 HEAD`; compare report SHA by resolving it.
- Simplify the reviewer state machine: unit of review is always `main...HEAD`; drop the
  "incremental review only the delta since the stale report" branch.
- Document the mechanical read-only option (Codex `--sandbox read-only`; Claude Code
  allowlist / read-only permission mode) alongside the prose contract.
- Document the cold-start genesis-on-`main` exemption to the "never edit on `main`/`dev`" rule.

## Out of Scope

- `node_modules` provisioning guard (PR 2).
- Doc-correctness cluster — capability-layering ordering, metrics scope, CI triggers, etc.
  (PR 3).
- Scaffold recipes + validation tooling (PR 4).
- Any linter code change (parallel linter track).

## Acceptance Criteria

- [x] A reviewer following the new prompt, run on a feature branch with **committed** changes,
  reviews a non-empty `main...HEAD` diff (the #2 empty-diff vacuous-pass cannot occur).
- [x] `lifecycle.md`, `code-review-prompt.md`, `review/AGENTS.md`, `AGENTS.md` step 5, and
  `running-the-workflow.md` agree on: branch-diff unit, commit-before-re-spawn, SHA-keying
  (`--short=12`), active→closed ownership.
- [x] Cold-start genesis-on-`main` exemption stated in `AGENTS.md` and `cold-start.md`.
- [x] `make lint-harness` clean (no broken inline paths/links introduced); `make ci` green.
- [x] This PR is reviewed by the new branch-diff reviewer (self-applying) and reaches APPROVED.

## Steps

- [x] Rewrite `code-review-prompt.md`: branch-diff against `main`, `--short=12`, resolve-SHA
  comparison, simplified state machine.
- [x] Update `lifecycle.md`: branch-diff unit, commit-before-re-spawn wording, `--short=12`.
- [x] Update `review/AGENTS.md` if it restates diff semantics (SHA-key wording).
- [x] Update root `AGENTS.md` step 5 (commit-before-re-spawn) and the "never edit on
  `main`/`dev`" rule (cold-start genesis exemption).
- [x] Update `running-the-workflow.md`: branch-diff reference + mechanical read-only spawn
  guidance.
- [x] Update `cold-start.md`: one-line genesis-on-`main` note.
- [x] Local checks: `make fmt`/`lint`/`test`/`build`.
- [x] Review loop to APPROVED (first pass); close plan; harness gate; PR.

## Open Questions

- (none — the one open decision, cold-start branching, is resolved in D-1)

## Decisions

### D-1: Cold-start runs on `main` (genesis-on-main) (2026-06-16)

- **Context:** finding #6 — cold-start writes PRD/ARCHITECTURE/plan-001 to the working tree
  with no branch step, contradicting the "never edit on `main`/`dev`" rule. The dogfood plan
  §9.1 left this as an explicit pick.
- **Options considered:**
  - A: `bootstrap/<slug>` branch for the genesis work — rejected: there is no `main` to PR
    against yet at genesis; the first commit *is* the project, so a branch+PR adds ceremony
    with nothing to merge into and no reviewer baseline.
  - B: genesis-on-`main` — chosen: matches the template's own "initial scaffold exempt"
    philosophy (`harness-template-plan.md` decision #9). The one-time bootstrap is the
    project's genesis; normal branch+PR discipline begins with the first task after handoff
    (implementing plan `001`).
- **Decision:** Document genesis-on-`main` as an explicit, one-time exception to the "never
  edit on `main`/`dev`" rule, scoped to the cold-start bootstrap only.

### D-2: Three-dot `main...HEAD` as the review unit (2026-06-16)

- **Context:** finding #2 — the working-tree `git diff HEAD` reviewer sees an empty diff after
  "commit in chunks", so the gate vacuously passes.
- **Options considered:**
  - A: keep `git diff HEAD` but forbid committing before review — rejected: fragile, depends on
    commit timing, and conflicts with "commit in logical chunks."
  - B: `git diff main...HEAD` (three-dot = changes since merge-base with `main`) — chosen:
    robust to commit timing; the branch's delta vs `main` is always the unit of review whether
    or not work is committed.
- **Decision:** Reviewer reviews `git diff main...HEAD`. Pair with commit-before-re-spawn so
  HEAD advances each round and SHA-keyed reports self-stale.

## Notes

- This plan lives in `active/` during execution; per the pipeline, `make lint-harness` is NOT
  run in the inner loop (the exec-plan-active rule fires by design). It runs only after this
  plan moves to `completed/`.
- Self-applying: the branch carries the corrected reviewer prompt, so the reviewer reviewing
  this PR is already the fixed one.
