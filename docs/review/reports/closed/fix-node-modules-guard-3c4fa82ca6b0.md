# Pre-commit review — fix/node-modules-guard @ 3c4fa82ca6b0

- Branch: `fix/node-modules-guard`
- HEAD: `3c4fa82ca6b0` ("Address review: don't hardcode the defaults list")
- Unit of review: `git diff main...HEAD` (three-dot)
- Report state: prior report keyed to `732967ece837` (a different commit) was stale; reviewed
  the full `main...HEAD` diff fresh and replaced it so the dir holds one report at current HEAD.

## Scope

Docs-only change (PR 2 of the dogfood plan). Documents the workaround for a harness-linter
limitation: a multi-package workspace (`apps/` + `packages/`) needs fully-literal per-package
`node_modules/**` ignores in `harnesslint.json`, because linter 0.1.2 does not expand `**` globs,
and `files.ignore` **replaces** (not merges) the default ignore list. Touches:

- `ARCHITECTURE.md` — one-line cross-reference on the `apps/`+`packages/` bullet.
- `docs/bootstrap/blessed-stacks.md` — new cross-cutting constraint section.
- `docs/bootstrap/cold-start.md` — multi-package workspace guard note (step 8).
- `docs/exec-plans/active/002-node-modules-guard.md` — new active exec-plan.

## Prior finding — resolved

The previous review (at `732967e`) flagged that both docs hardcoded an enumerated defaults list
(`.git/**, thoughts/**, vendor/**, bin/**, dist/**, node_modules/**`) that omitted the shipped
config's seventh entry `.archive/**`; an agent preserving that list literally would have dropped
`.archive/**`, the exact failure class this PR aims to prevent.

The latest commit removes the hardcoded enumeration entirely. Both docs now instruct the agent to
**keep "every entry already present in `harnesslint.json`"** and "never retype the defaults from
memory and risk dropping one":

- `docs/bootstrap/cold-start.md:170-171` — reworded; no enumerated list remains.
- `docs/bootstrap/blessed-stacks.md:45-48` — reworded; no enumerated list remains.

Verified against the shipped `harnesslint.json` (7 ignore entries, including `.archive/**`,
unchanged). The fix is correct and complete: the guidance can no longer drift from the shipped
config, which is the more robust of the two fixes the prior review proposed.

## Other checks (pass)

- **Glob caveat self-consistency.** The "literal path prefixes only; trailing `**` ok; `**/` and
  `apps/*/` not expanded in 0.1.2" claim is consistent across both docs and the plan's D-1, and
  consistent with the shipped config's own `node_modules/**`-style entries.
- **No change to shipped `harnesslint.json`.** Confirmed unchanged — matches the plan's
  Out-of-Scope and Acceptance Criteria (no speculative dead globs). By design.
- **Exec-plan well-formed.** `002-node-modules-guard.md` follows `docs/exec-plans/template.md`
  (Goal / In-Scope / Out-of-Scope / Acceptance Criteria / Steps / Open Questions / Decisions with
  a dated D-1 block / Notes). Lives in `docs/exec-plans/active/`; numbering `002` follows `001`.
- **Cross-doc consistency.** ARCHITECTURE → `blessed-stacks.md` pointer is accurate; cold-start
  and blessed-stacks tell the same story (remedy, caveat, replace-not-merge, single-root escape
  hatch). The prior "reding" typo no longer appears (plan reads "turning the harness gate red").
- **Repo conventions.** Inline code for directory refs; markdown links only to existing files (per
  `docs/AGENTS.md`). No secrets, no source/git mutation.

VERDICT: APPROVED
