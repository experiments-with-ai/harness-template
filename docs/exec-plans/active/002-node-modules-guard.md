# Exec Plan 002: `node_modules` provisioning guard (doc workaround)

## Goal

Stop a freshly-provisioned multi-package web app from reding the harness gate with no
guidance. Document the fully-literal `files.ignore` remedy a multi-package workspace needs,
the `**`-glob-does-not-work caveat (linter 0.1.2), and that `files.ignore` **replaces** (not
merges) the defaults. This is the **doc workaround** for audit finding #1; the real fix
(linter glob expansion) lives in the parallel linter track and will retire this guidance.

## In Scope

- `docs/bootstrap/cold-start.md` — provisioning step (step 8) note for multi-package layouts.
- `docs/bootstrap/blessed-stacks.md` — guidance reachable from the multi-package provisioning
  path (cross-cutting note, since several stacks can produce `apps/` + `packages/`).
- `ARCHITECTURE.md` — one-line cross-reference on the existing `apps/` + `packages/` note.

## Out of Scope

- Any change to the linter source (the real glob fix — parallel track §7.2).
- Changing the shipped single-package `harnesslint.json` (no speculative globs that match
  nothing — that is the dead-config smell the plan dislikes).

## Acceptance Criteria

- [ ] The docs name the exact literal-path remedy (`apps/web/node_modules/**`,
      `packages/api/node_modules/**`, per-package `dist/**`) and the `**`/`apps/*`-does-not-work
      caveat for linter 0.1.2.
- [ ] The docs state that `files.ignore` **replaces** the default ignore list, so any added
      entry must preserve the existing defaults.
- [ ] A manual repro — scaffold `apps/web/node_modules/{README.md,AGENTS.md}`, apply the
      documented literal ignore, run the linter — exits 0.
- [ ] No change to the shipped single-package `harnesslint.json`.
- [ ] `make lint-harness` clean (after plan close); `make ci` green.

## Steps

- [ ] Add the multi-package ignore guidance to `cold-start.md` step 8.
- [ ] Add a cross-cutting multi-package note to `blessed-stacks.md`.
- [ ] Add a one-line cross-reference to `ARCHITECTURE.md`'s `apps/`+`packages/` bullet.
- [ ] Manual repro to prove the remedy (scaffold vendored docs → apply ignore → linter exit 0).
- [ ] Inner loop: `make fmt` / `make lint` / `make test` / `make build`.
- [ ] Pre-commit review (branch-diff reviewer) → APPROVED.
- [ ] Close plan, `make lint-harness`, `make ci`, push + PR.

## Open Questions

- (none)

## Decisions

### D-1: Doc workaround now, do not pre-empt the linter fix (2026-06-16)

- **Context:** finding #1 has two halves — a doc gap (no shipped guidance for the
  multi-package `node_modules` red) and a linter limitation (`**/node_modules/**` does not
  expand; only literal path prefixes match in 0.1.2). The real fix is glob expansion in the
  linter, tracked separately (§7.2).
- **Options considered:**
  - A: ship a `**/node_modules/**` glob in `harnesslint.json` now — rejected: it does not work
    in 0.1.2 (silently matches nothing) and would be dead config.
  - B: document the literal-path remedy and the caveat, leave the shipped single-package config
    untouched — chosen: it is correct for the current linter, adds no dead config, and is
    cleanly retired when the glob fix lands.
- **Decision:** doc-only workaround; literal per-package ignores documented as the remedy; no
  change to the shipped `harnesslint.json`.

## Notes

- This guidance is intended to be **retired** by the linter track's glob fix (§7.2 of the
  dogfood plan). When `**/node_modules/**` expands, the literal-path instruction can be
  simplified back to a single glob.
