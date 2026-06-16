# Exec Plan 003: Doc-correctness cluster

## Goal

Clear the cluster of minor/nit doc and config defects from the v1 audit in one focused
sweep, with no behavioural change to the shipped harness mechanics. Addresses audit
findings #5 (ordering half), #8, #10, #11, #12, #13.

## In Scope

- `docs/harness/capability-layering.md` — reorder the preference list (lines 8-13) so it
  matches the canonical ladder (repo config → Skill → MCP → automation), i.e. Skill before
  MCP, per `harness-template-plan.md` §12.
- `docs/harness/metrics.md` — correct the `operational-doc-broken-path` scope line so it no
  longer understates the rule (it also covers any `docs/workflow/**.md`, not only
  README/AGENTS/CLAUDE).
- `.github/workflows/ci.yml` — narrow triggers so WIP feature-branch pushes don't red on an
  active plan: `pull_request` (all) + `push:` to `main` only. Quote `node-version: "22"`.
  SHA-pin the three third-party actions with a trailing `# vX.Y.Z` comment.
- `docs/bootstrap/smoke-fixture.md` — anchor the `TBD` assertion to the placeholder headings
  instead of a whole-file substring match.
- `harnesslint.json` — drop the dead `.archive/**` ignore (no `.archive/` dir exists).

## Out of Scope

- The semantic carve-out for known-stack MCPs in `capability-layering.md` Rung 3 — that is
  PR 4 (finding #5's second half).
- Any `metrics.md` Part-A single-active-review line / README quick-start note — listed as
  optional in the plan; skipped to keep the sweep tight unless review asks for it.
- Any linter source change (parallel track).

## Acceptance Criteria

- [x] `capability-layering.md` preference list orders Skill before MCP, matching the ladder.
- [x] `metrics.md` operational-doc scope line names `docs/workflow/**.md`.
- [x] `ci.yml` no longer triggers on non-`main` branch pushes; `node-version` quoted; the
      three third-party actions SHA-pinned with version comments.
- [x] `smoke-fixture.md` assertion anchors to `^### .*— TBD` headings; passes on a resolved
      tree, fails on a left-`TBD` heading.
- [x] `harnesslint.json` no longer carries `.archive/**`.
- [x] `make ci` green; `make lint-harness` clean.

## Steps

- [x] Reorder `capability-layering.md` preference list.
- [x] Fix `metrics.md` operational-doc scope line.
- [x] Narrow `ci.yml` triggers, quote node-version, SHA-pin actions.
- [x] Anchor `smoke-fixture.md` TBD assertion.
- [x] Remove dead `.archive/**` from `harnesslint.json`.
- [x] Run local checks; review; close plan; harness gate; push + PR.

## Open Questions

- None blocking. SHA pins for actions are resolved from the current published release tags.

## Decisions

Record every non-trivial choice made while executing this plan. One block per decision.

### D-1: Keep the sweep scoped to confirmed defects (2026-06-16)

- **Context:** §5 lists several edits as "optional" (a `metrics.md` Part-A line, a README
  quick-start note). Including speculative edits dilutes the review and risks churn.
- **Options considered:**
  - A: include the optional edits — rejected; they are not audit findings and add review surface.
  - B: ship only the six confirmed findings (#5-ordering, #8, #10, #11, #12, #13) — chosen.
- **Decision:** ship only the confirmed-defect edits; defer the optional items.

### D-2: SHA-pin third-party actions, leave the version comment as the human-readable tag (2026-06-16)

- **Context:** finding #13 wants the floating `@v4`/`@v4`/`@v4` major tags pinned to immutable
  SHAs. The three third-party actions are `actions/checkout`, `pnpm/action-setup`,
  `actions/setup-node`.
- **Decision:** pin each `uses:` to the full commit SHA of its current release, with a trailing
  `# vX.Y.Z` comment so the intended version stays legible.

## Notes

- Finding #8 verified against the linter source (`operational_docs.go:58-65`): the rule fires
  for `README.md`, any `AGENTS.md`/`CLAUDE.md`, and any path under `docs/workflow/` ending in
  `.md`.
- Finding #12 verified: no `.archive/` directory exists in the template, so the ignore is dead.
- PR 2's node_modules guidance points at the *live* `harnesslint.json` rather than a hardcoded
  default list, so removing `.archive/**` here needs no PR 2 doc edit (see PR 2 execution log).
