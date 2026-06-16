# Running the Workflow

This is the neutral runner. It documents the workflow **contract** once and gives the
command forms for Claude Code, Codex, and manual operation side by side, so the harness is
genuinely multi-agent. `AGENTS.md` files describe *what* to do; this file describes *how to
drive it* with a specific tool.

When in doubt, prefer the contract described here over any single tool's defaults. CLI flags
and config formats change; re-verify before relying on them.

## 1. Project memory

`AGENTS.md` is the single source of truth for agent behavior. Both supported agents read the
same content; they just reach it differently:

- **Codex** reads `AGENTS.md` directly.
- **Claude Code** reads `CLAUDE.md`. In this repo every `CLAUDE.md` is exactly the one line
  `@AGENTS.md`, which imports the sibling `AGENTS.md`. (The harness linter enforces this
  pairing and contents.)
- **Manual / other tools** — read the nearest `AGENTS.md` yourself and follow it.

Never duplicate guidance into `CLAUDE.md`. If two files disagree, `AGENTS.md` wins; fix the
`CLAUDE.md` import instead.

## 2. Reviewer spawn (fresh context, read-only)

Code review runs as a **separate, fresh-context, read-only** agent. The full lifecycle lives
in [../review/reports/lifecycle.md](../review/reports/lifecycle.md); the reviewer's own
instructions live in [../review/code-review-prompt.md](../review/code-review-prompt.md). This
section only covers *how to launch it*.

Spawn the reviewer in a clean session — do not reuse the working agent's context:

```bash
# Claude Code
claude -p "follow instructions from docs/review/code-review-prompt.md"

# Codex
codex exec "follow instructions from docs/review/code-review-prompt.md"

# Manual / any other tool
# Open a fresh session and paste the contents of
# docs/review/code-review-prompt.md as the prompt.
```

### Reviewer permissions (hard boundary)

The reviewer is read-only with exactly one exception:

- **Its only write** is its own report under `docs/review/reports/active/` (one SHA-keyed
  file, one verdict, then it stops).
- **Read-only git is allowed** — e.g. `git diff`, `git rev-parse HEAD` — so it can see the
  change under review and key its report to the current `HEAD`.
- **Everything else is forbidden**: no `make`, no tests, no linters, no builds, no source
  edits, no installs, no other git mutations (no `commit`, `add`, `checkout`, `reset`, ...).

The reviewer **never** moves its own report. On `APPROVED`, the **working agent** performs the
`docs/review/reports/active/` → `docs/review/reports/closed/` move. On `CHANGES_REQUESTED`, the
working agent fixes the code and spawns a *new* fresh reviewer against the new `HEAD`.

> Note: the Codex flags and path conventions above can drift between releases. Re-verify the
> exact current `codex exec` invocation (and the Claude Code flags) against your installed CLI
> before relying on them in automation.

## 3. The harness gate + CI

Stack linters (`make lint` — formatter + type-check) are safe to loop on while an exec-plan is
active. The **harness** linter is different: it is a gate, not an inner-loop tool.

- Run `make lint-harness` **only after** the active exec-plan has been moved out of
  `docs/exec-plans/active/` into `docs/exec-plans/completed/`. The harness linter fails if a
  plan is still in `active/` at the gate, so running it mid-plan is a guaranteed false
  positive.
- `make ci` runs the full gate (`fmt-check lint test build lint-harness`). It **includes**
  `lint-harness`, so it carries the same precondition: clear the active exec-plan first.
- `make ci` is exactly what continuous integration runs. If `make ci` is green locally with no
  plan left in `active/`, CI should be green too.

```bash
# inner loop (safe while a plan is active in docs/exec-plans/active/):
make fmt        # writes
make lint       # stack linters only (formatter check + type-check)
make test
make build

# gate (only after moving the plan to docs/exec-plans/completed/):
make lint-harness
make ci         # full gate; this is what CI runs
```

## 4. Permissions, sandbox, and tool safety

> This section is also the tool-permission guidance referenced by
> [../security/baseline.md](../security/baseline.md).

**v1 ships no tool-specific permission or config files.** There is intentionally no
`.claude/settings.json` and no `.codex/config.toml` in this repo. Those files are
environment-specific, leak local assumptions, and go stale fast. Configure Claude Code / Codex
permissions in **your own environment**, and keep approvals and sandboxing **conservative**:

- **Do not auto-allow destructive commands.** Keep `rm -rf`, force-push, history rewrites,
  schema/data drops, and similar behind explicit approval.
- **Gate network installs.** Package installs and other network mutations should require
  approval, not run silently.
- **Scope external tool / MCP access.** Grant only the servers and capabilities a task
  actually needs; default to off.
- **Use a least-privilege GitHub token.** Minimum scopes for the task, short-lived where
  possible.
- **Prefer a sandbox** for command execution and limit the writable filesystem to the repo.

Keep `AGENTS.md` pointing **here** rather than hard-coding any one tool's commands or flags.
Tooling moves; this neutral runner is where the per-tool detail is allowed to change without
rewriting the agent memory files.
