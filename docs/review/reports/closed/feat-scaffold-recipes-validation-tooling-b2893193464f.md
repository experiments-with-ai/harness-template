# Pre-commit review — feat/scaffold-recipes-validation-tooling @ b2893193464f

- **Branch:** feat/scaffold-recipes-validation-tooling
- **HEAD SHA12:** b2893193464f
- **Merge-base with main:** f3d4c219ed3b
- **Unit of review:** `git diff main...HEAD` (three-dot)
- **Prior report:** none (fresh review)

## Scope

Docs-only change set (PR 4 of the dogfood plan). Seven files, +316/-17:

- `AGENTS.md` — step 4 (UI validation) rewired to the concrete Playwright gate + browser-MCP loop, pointing at `blessed-stacks.md` and `observability/checklist.md`.
- `docs/bootstrap/blessed-stacks.md` — new "gate vs loop" split, per-stack validation-capability matrix, copy-pasteable single-root web-app scaffold recipe (dated verified-against note), gate/loop tags on web-app/api-service/cli sections, provisioning-checklist updates.
- `docs/bootstrap/cold-start.md` — validation-capability detect-and-suggest in the interview, tooling/validation plan folded into the existing approval gate, template-neutral/provisioned-concrete distinction, presentation-reset provisioning step (README/badges/version/license).
- `docs/harness/capability-layering.md` — Rung 3 known-stack carve-out.
- `docs/harness/metrics.md` — two Part-B lines: validation gate `[mechanical]`, loop MCP `[process]`.
- `docs/observability/checklist.md` — concrete-mechanism block (Playwright gate + browser MCP).
- `docs/exec-plans/active/004-scaffold-recipes-validation-tooling.md` — new exec plan.

## Findings

### Correctness / internal consistency

- All six described components are present and match the PR description and the exec-plan's acceptance criteria.
- The gate-`[mechanical]` / loop-`[process]` tagging is applied consistently across `blessed-stacks.md`, `metrics.md`, `observability/checklist.md`, `cold-start.md`, and `AGENTS.md`. No instance of calling the loop MCP an enforced gate (the honesty thesis is respected).
- `metrics.md` additions use the repo's exact Part-B line style (`— **[mechanical]** (...)` / `— **[process]** (...)`) and sit correctly within the enumerated list.
- The Rung 3 carve-out ("known stack need" permits a loop tool at bootstrap; speculative MCPs still forbidden) does **not** contradict the same file's "Out of scope for v1 → Rungs 2 and 3 are likewise unbuilt by default" paragraph: that paragraph concerns what the *template* ships, while the carve-out concerns what *provisioning* may wire into the user's own repo. This is the same "template neutral; provisioned project concrete" thesis carried throughout the PR. Consistent, not a defect.

### Claims verified against repo

- All referenced files exist (metrics, blessed-stacks, cold-start, running-the-workflow, security/baseline, observability/checklist, exec-plans/template, README, LICENSE, package.json, capability-layering).
- `running-the-workflow.md §4` exists and discusses `.claude/settings.json` / `.codex/config.toml` neutrality — backs the "template ships no `.claude/`/`.codex/`" and "§4" references in `blessed-stacks.md` and `cold-start.md`.
- Presentation-reset claims are accurate against the actual template: `README.md` carries CI/License/PR badges pointing at `experiments-with-ai/harness-template` plus an MIT `LICENSE` link; `package.json` `version` is `0.1.0` (cold-start says reset to `0.1.0`/`0.0.0` — consistent).
- Recipe claim "root `node_modules/` already covered by the default harnesslint.json ignores" is accurate — `harnesslint.json` ignore list includes `node_modules/**`. The single-root claim also matches pre-existing prose in `blessed-stacks.md` (main).
- Tracer-deletion claim ("delete `src/index.ts` + `src/index.test.ts`") matches the actual tracer (`src/index.ts`, `src/index.test.ts` present).

### Links / paths (harness-linter surface)

- All `AGENTS.md` markdown links resolve (it is in the linter's `brokenLinks` + path scope).
- All new relative markdown links in `blessed-stacks.md`, `cold-start.md`, and `observability/checklist.md` resolve.
- Directories are referenced as inline code, files as markdown links — per the `docs/AGENTS.md` convention that keeps path checks honest.

### Tests / security / simplicity

- Tests: N/A (docs-only; no runnable behavior changed). The change explicitly defers all real `make`-target/scaffold work to bootstrap in the user's repo.
- Security: the PR repeatedly gates network installs behind `docs/security/baseline.md` ("propose, never auto-install"; "detection only, do not install"). Consistent with the baseline. No secrets, no injection surface.
- Simplicity: prose is dense but each addition is load-bearing and cross-referenced rather than duplicated (matrix/recipe live once in `blessed-stacks.md`; other docs point at it). The exec-plan records D-1/D-2/D-3 with rejected alternatives. No dead content or backwards-compat shims.

### Repo conventions

- Exec plan follows `docs/exec-plans/template.md` structure (Goal / In Scope / Out of Scope / Acceptance / Steps / Open Questions / Decisions / Notes) and is correctly placed under `docs/exec-plans/active/`.
- Tagging vocabulary, link discipline, and tone match the surrounding docs.

## Conclusion

The change is internally consistent, every new path/link resolves, no claim contradicts a shipped doc, and the diff faithfully implements its stated scope. No correctness, security, or convention issues found.

VERDICT: APPROVED
