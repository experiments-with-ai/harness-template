# Docs

Index of the `docs/` system of record. Subdirectories that carry their own agent guidance
own an `AGENTS.md` — follow those for detail; do not duplicate their contents here. The
workflow itself lives in the root [AGENTS.md](../AGENTS.md), not under `docs/`.

## Subdirectories

- `docs/harness/` — human-facing concept docs: what a harness is, the principles, the honest
  metrics scorecard, and the capability-layering discipline. Off the agent hot path.
- `docs/agents/` — neutral runner: exact command forms for Claude Code, Codex, and manual use.
- `docs/bootstrap/` — the cold-start flow that turns this empty template into a real project.
- `docs/exec-plans/` — execution plans: `docs/exec-plans/active/`, `docs/exec-plans/completed/`,
  and the [template](exec-plans/template.md).
- `docs/review/` — the read-only reviewer prompt and report lifecycle.
- `docs/security/` — the security baseline checklist.
- `docs/observability/` — the post-bootstrap observability checklist.
- `docs/references/` — external material kept verbatim, including `docs/references/product/`
  where the cold-start flow writes the new project's PRD, and the harness-engineering source
  article under `docs/references/harness-engineering/`.

## Conventions

- This is the system of record: anything an agent needs to do reliable work lives here, not
  in chat or someone's head.
- Refer to directories with inline code (e.g. `docs/exec-plans/active/`); reserve markdown
  links for files that exist. This keeps the harness linter's path checks honest.
