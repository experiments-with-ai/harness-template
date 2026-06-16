# Pre-commit review — fix/doc-correctness-cluster @ 2d5ff2a6d94d

Unit of review: `git diff main...HEAD` (three-dot). Fresh review — no prior report in
`docs/review/reports/active/`.

## Scope

Docs/config-only sweep (PR 3 of the dogfooding plan), six changed files:

- `docs/harness/capability-layering.md` — reorder preference list (Skill before MCP).
- `docs/harness/metrics.md` — correct `operational-doc-broken-path` scope sentence.
- `.github/workflows/ci.yml` — narrow `push` to `main`, SHA-pin three actions, quote `node-version`.
- `docs/bootstrap/smoke-fixture.md` — anchor the TBD grep assertion to placeholder headings.
- `harnesslint.json` — remove dead `.archive/**` ignore.
- `docs/exec-plans/active/003-doc-correctness-cluster.md` — new exec plan (expected; closed at gate before PR).

## Findings by criterion

**Correctness — verified, no issues.**
- Capability-layering: the body ladder already orders `Rung 2 — A Skill` (line 30) before
  `Rung 3 — An MCP` (line 41). The preference list previously contradicted the body (MCP at
  #2); the edit makes the list match the body. Now internally consistent.
- smoke-fixture anchor `^### .*— TBD` matches the two real placeholder headings in
  `ARCHITECTURE.md` (`### 1. Application(s) — TBD`, `### 2. Backend / Data — TBD`, em-dash).
  Assertion semantics hold: on a resolved tree grep finds nothing → exit 1 → `!` passes; on a
  left-TBD heading grep matches → exit 0 → `!` fails. Dropping `-q` (now `-nE`) only adds
  diagnostic output on failure — an improvement, not a regression. The narrower anchor also
  removes the old false-positive risk where any legitimate prose "TBD" tripped the whole-file
  substring match.
- metrics.md scope sentence broadened to "README.md, every `AGENTS.md`/`CLAUDE.md`, and any
  `docs/workflow/**.md`"; the linter rule name `operational-doc-broken-path` is unchanged. The
  plan's Notes cite the linter source (`operational_docs.go:58-65`) for the claim; consistent
  with the rule it describes.
- harnesslint.json: confirmed no `.archive/` directory exists in the tree — the removed ignore
  was dead. Remaining JSON is valid and well-formed.
- ci.yml: `push: branches: [main]` + `pull_request` is the intended narrowing. PRs from the
  feature branch still run; main pushes still run. The header comment correctly notes the
  exec-plan is closed before the PR (per root AGENTS.md pipeline: close plan at step 6, open PR
  at step 8), so `exec-plan-active-present` does not fire on the PR run. SHA pins carry
  human-readable `# vX.Y.Z` comments. `node-version: "22"` quoted to avoid YAML numeric coercion.

**Tests** — N/A. No executable behavior changed; the smoke-fixture assertion is itself the
test artifact and its logic is sound (above).

**Security** — Net positive. SHA-pinning the three third-party actions removes the mutable-tag
supply-chain surface that floating `@v4` tags carry. No secrets, no injection surface introduced.

**Simplicity** — Clean. Each edit is minimal and targeted; no dead code or shims added; the
exec plan documents scope and the two non-trivial decisions (D-1, D-2).

**Repo conventions** — Conforms. Exec plan follows the template (Goal/Scope/Acceptance/Steps/
Decisions). Directories referenced as inline code; markdown links reserved for real files.
New plan correctly lives in `docs/exec-plans/active/` and will be moved to `completed/` at the
gate per the workflow.

## Non-blocking note

- ci.yml comment block accurately describes why `pull_request` stays unrestricted while `push`
  is pinned to `main`; no action needed.

VERDICT: APPROVED
