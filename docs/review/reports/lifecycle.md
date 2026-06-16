# Review Report Lifecycle

The reviewer is **READ-ONLY**. The **working agent** owns the lifecycle. The reviewer's only write is its single report in `docs/review/reports/active/`; it emits one verdict and stops. It does **not** move files, run builds/tests/linters/installs, or mutate source/git. Read-only git inspection (e.g. `git diff`, `git log`) is allowed.

The **unit of review is the branch diff against `main`** (`git diff main...HEAD`), not the working-tree diff — so it does not matter whether the work is committed at review time.

For the reviewer procedure, see [`../code-review-prompt.md`](../code-review-prompt.md).

## Verdicts

- **CHANGES_REQUESTED** — the working agent fixes the issues, reruns local checks, **commits the fix**, then re-spawns a **fresh** reviewer. Committing advances `HEAD`, so the prior report self-stales and the re-review is genuinely against the new HEAD.
- **APPROVED** — the working agent moves the report from `docs/review/reports/active/` to `docs/review/reports/closed/`, then proceeds to close the plan and run the harness gate.

## Single-active invariant

`docs/review/reports/active/` holds **at most one** report.

This is a documented v1 convention. v1 does **not** mechanically check it; a linter follow-up may enforce it later.

## SHA-keyed names

Reports are named `<branch>-<sha12>.md`, where `sha12` is `git rev-parse --short=12 HEAD` (a fixed 12-char abbreviation — not bare `--short`, whose length drifts as the repo grows):

- **Deterministic** — the same branch + HEAD always produces the same name.
- **Collision-free** across parallel PRs (each has a distinct branch/SHA).
- **Self-staling** — if a report's SHA resolves to a commit other than the current HEAD, the report is stale and a re-review is required.

No wall-clock timestamps: agents cannot always obtain a reliable time, so the SHA is the source of truth for freshness.
