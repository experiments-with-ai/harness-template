# Review

Agent-to-agent code review for this repo. Two roles, kept strictly separate:

- **Reviewer** — a fresh-context, **read-only** agent that follows
  [code-review-prompt.md](code-review-prompt.md). It judges the branch diff against `main`
  (`git diff main...HEAD`). Its only write is a single report under
  `docs/review/reports/active/`; it emits exactly one verdict and stops. It does not run
  builds, tests, linters, or installs, and never mutates source or git (read-only git like
  `git diff` is allowed).
- **Working agent** — owns the lifecycle. On `CHANGES_REQUESTED` it fixes, reruns local
  checks, **commits the fix**, and re-spawns a fresh reviewer; on `APPROVED` it moves the
  report from `docs/review/reports/active/` to `docs/review/reports/closed/`.

Reports are SHA-keyed — named by branch and the 12-char HEAD SHA (`--short=12`) — so they self-stale when `HEAD` moves.
`docs/review/reports/active/` holds **at most one** report. The full lifecycle is in
[reports/lifecycle.md](reports/lifecycle.md). Exact spawn commands per tool:
[running-the-workflow.md](../agents/running-the-workflow.md).
