# Review Report Lifecycle

The reviewer is **READ-ONLY**. The **working agent** owns the lifecycle. The reviewer's only write is its single report in `docs/review/reports/active/`; it emits one verdict and stops. It does **not** move files, run builds/tests/linters/installs, or mutate source/git. Read-only git inspection (e.g. `git diff`, `git log`) is allowed.

For the reviewer procedure, see [`../code-review-prompt.md`](../code-review-prompt.md).

## Verdicts

- **CHANGES_REQUESTED** — the working agent fixes the issues, then re-spawns a **fresh** reviewer (new report against the new HEAD).
- **APPROVED** — the working agent moves the report from `docs/review/reports/active/` to `docs/review/reports/closed/`, then proceeds to close the plan and run the harness gate.

## Single-active invariant

`docs/review/reports/active/` holds **at most one** report.

This is a documented v1 convention. v1 does **not** mechanically check it; a linter follow-up may enforce it later.

## SHA-keyed names

Reports are named `<branch>-<short-sha>.md`:

- **Deterministic** — the same branch + HEAD always produces the same name.
- **Collision-free** across parallel PRs (each has a distinct branch/SHA).
- **Self-staling** — if a report's SHA `!=` current HEAD, the report is stale and a re-review is required.

No wall-clock timestamps: agents cannot always obtain a reliable time, so the SHA is the source of truth for freshness.
