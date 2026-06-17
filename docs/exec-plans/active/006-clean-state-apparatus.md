# Exec Plan 006: Clean-state enforcement apparatus (PR 0)

## Goal

Build the §4-E clean-state enforcement apparatus and the §4-F maintenance-protocol doc that
together keep the template's distribution state (`main` HEAD) clonable at every commit — the four
lifecycle dirs (`docs/exec-plans/{active,completed}`, `docs/review/reports/{active,closed}`)
holding only `.gitkeep`. This is **PR 0** of the post-test enhancement round; it lands first so
every later PR in the round is genuinely gated against residue. Source of record:
`harness-template-post-test-enhancement-plan.md` §4-E/§4-F + appendix §2.

## In Scope

- A repo-gated `clean-state` CI job in `.github/workflows/ci.yml` with **only** the lifecycle-dirs
  step (appendix §2.1). Gated `if: github.repository == 'experiments-with-ai/harness-template'` so
  it never runs in a clone; **not** in `make ci`.
- A guarded, `.gitkeep`-preserving `make clean-lifecycle` target in the `Makefile` (appendix §2.2):
  refuses to run unless `origin` is the template repo, `FORCE=1` overrides.
- The bootstrap-strip bullet (optional hygiene, atomic) in `cold-start.md` step 8 (appendix §2.3).
- New file `docs/maintaining-the-template.md` documenting B's delete-before-merge protocol,
  self-gating on `git remote origin` (appendix §2.8), plus the one-line `AGENTS.md` pointer.

## Out of Scope

- The §1.9 doc-tripwire — it asserts the §1.2-cleaned `cold-start.md` and ships in **PR 1**;
  adding it here would red PR 0's own CI (it shares the `clean-state` job's pass/fail).
- The §1.2 model-change prose edits (7 files) and §2 recipe hardening — PR 1.
- Enabling branch protection in the GitHub UI — a human checkpoint after this PR's `clean-state`
  job runs once (appendix §2.7).
- Any default-on linter rule form of the clean-state check (would brick every clone).

## Acceptance Criteria

- [ ] `clean-state` job added, repo-gated, lifecycle-dirs step only, not in `make ci`.
- [ ] `make clean-lifecycle` is guarded (refuses outside template repo unless `FORCE=1`) and
      preserves `.gitkeep`; running it on this repo empties the four lifecycle dirs to `.gitkeep`.
- [ ] cold-start.md step 8 carries the atomic bootstrap-strip bullet.
- [ ] `docs/maintaining-the-template.md` exists with the `git remote -v` inoculation banner and the
      delete-before-merge sequence; `AGENTS.md` links it under a "Maintaining this template" note.
- [ ] `make fmt lint test build` green; `make lint-harness` green (after plan close).
- [ ] PR 0 leaves the lifecycle dirs `.gitkeep`-only on the branch tip (delete-before-merge).

## Steps

- [ ] Add the `clean-state` job to `.github/workflows/ci.yml` (appendix §2.1).
- [ ] Add `make clean-lifecycle` to the `Makefile` (appendix §2.2).
- [ ] Add the bootstrap-strip bullet to `cold-start.md` step 8 (appendix §2.3).
- [ ] Author `docs/maintaining-the-template.md` (appendix §2.8) + `AGENTS.md` pointer.
- [ ] Run `make fmt lint test build`; fresh-context reviewer; on APPROVED move report to closed/.
- [ ] Close this plan to `completed/`; `make lint-harness`; `make clean-lifecycle`; push; PR.

## Open Questions

- None blocking. Branch protection requires the `clean-state` check to have run once before it is
  selectable — handled by the post-PR human checkpoint (appendix §2.7).

## Decisions

Record every non-trivial choice made while executing this plan. One block per decision.

### D-1: PR 0 follows the delete-before-merge protocol it ships (2026-06-17)

- **Context:** PR 0 *creates* `make clean-lifecycle` and `docs/maintaining-the-template.md`. The
  round must not leave residue on `main`, and the plan says E gates from PR 0 onward.
- **Options considered:**
  - A: Skip the plan/report for PR 0 since the tooling is being introduced here — rejected: the
    plan's per-PR loop applies to every PR, and dogfooding the protocol on the PR that introduces
    it is the right proof.
  - B: Create the plan + review report, then run the just-built `make clean-lifecycle` before push
    — chosen: the tooling exists by the time it is needed at the end of the loop.
- **Decision:** Follow the full per-PR loop; build the apparatus early, use it to clean before push.

## Notes

- Durable record of this round lives in the external `harness-template-post-test-enhancement-plan.md`
  and the PR's pre-squash commits — not in `main`'s tree (this plan is deleted before merge).
