# Security Baseline

Security here is **light now, deep later**. This page is the baseline that ships with
the harness core: a short checklist a human or agent can run through on any change.
Heavier, project-specific controls are provisioned per project (see
[Deferred](#deferred-to-per-project-provisioning)).

## Baked in now (run through this checklist)

- [ ] **Secrets are never committed or echoed.** No credentials, tokens, or keys in
      source, logs, commit messages, or chat output. The repo `.gitignore` covers
      `.env` and `.env.*`; keep real secrets there, not in tracked files.
- [ ] **New dependencies are reviewed and pinned.** Vet what you add, pin **exact**
      versions (no floating ranges), and commit the lockfile so installs are
      reproducible.
- [ ] **Destructive commands are confirmed, never auto-run.** Anything that deletes,
      overwrites, force-pushes, or mutates shared state requires explicit human
      confirmation — it is never silently executed.
- [ ] **External tool / MCP access is scoped to the task.** Grant only the tools and
      reach a task actually needs; do not wire up broad or standing access "just in
      case."
- [ ] **The GitHub token is least-privilege.** Scope it to the minimum permissions the
      work requires; prefer short-lived, narrowly-scoped tokens over broad ones.

> Conservative tool-permission and sandbox guidance — no auto-allow of destructive
> commands, gate network installs, keep approvals and sandboxing conservative — lives
> in [docs/agents/running-the-workflow.md](../agents/running-the-workflow.md).

## Deferred to per-project provisioning

The following are **out of scope for this baseline**. They are deliberately omitted
from the harness core and added when a project is provisioned, sized to that project's
stack and risk:

- **SAST** (static application security testing).
- **Secret-scanning in CI.**
- **Dependency provenance / SBOM.**
- **A `/security-review` step on product code.**
