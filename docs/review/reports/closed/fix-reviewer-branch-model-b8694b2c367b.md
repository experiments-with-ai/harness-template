# Review report: fix/reviewer-branch-model

- **Branch:** `fix/reviewer-branch-model`
- **HEAD SHA12:** `b8694b2c367b`
- **Unit of review:** `git diff main...HEAD` (merge-base `068907b675f3`)
- **Report state:** no prior report in `docs/review/reports/active/` — reviewed fresh.

## Scope

Documentation-only change (Markdown under `docs/` + root `AGENTS.md`); no source code.
This is "PR 1" of the dogfood plan: it changes the reviewer model itself and the
branching-discipline docs. Seven files:

- `AGENTS.md` — cold-start genesis-on-`main` exemption (step-1 prep); step-5 commit-before-re-spawn.
- `docs/bootstrap/cold-start.md` — genesis-on-`main` note, references step 10 / first task after handoff.
- `docs/agents/running-the-workflow.md` — branch-diff note + mechanical read-only spawn guidance.
- `docs/exec-plans/active/001-reviewer-branch-model.md` — new exec plan (the plan driving this PR).
- `docs/review/AGENTS.md` — branch-diff unit, commit-before-re-spawn, `--short=12` SHA-keying.
- `docs/review/code-review-prompt.md` — three-dot `main...HEAD`, `--short=12`, resolve-SHA comparison, simplified state machine.
- `docs/review/reports/lifecycle.md` — branch-diff unit, commit-before-re-spawn, `--short=12`.

## Findings by criterion

1. **Correctness.** N/A for executable code. The documented procedures are self-consistent:
   the three-dot `main...HEAD` choice is correctly described (changes since merge-base,
   robust to commit timing); `--short=12` is a stable abbreviation; the resolve-SHA
   comparison (`git rev-parse <report-sha>` vs `git rev-parse HEAD`) is sound. The prompt I
   am following is the new prompt, and it executed cleanly against this very PR (non-empty
   7-file `main...HEAD` diff — the finding-#2 empty-diff vacuous-pass cannot recur).

2. **Tests.** N/A (docs-only). The harness linter (path/link checks) is the relevant gate;
   see Links below — all introduced links/inline paths resolve.

3. **Security.** No secrets, no executable surface. The `--allowedTools` / `--sandbox`
   guidance tightens the reviewer's contract mechanically and is appropriately hedged
   ("flags drift between releases — re-verify").

4. **Simplicity.** The state-machine simplification (drop the incremental-since-stale-report
   branch; always judge full `main...HEAD`) is a net reduction. No dead abstractions added.

5. **Repo conventions.** Honors `docs/AGENTS.md` rule "reserve markdown links for files that
   exist; refer to directories with inline code" — directories (e.g. `docs/review/reports/active/`)
   are inline code, file references are links. Exec-plan 001 follows the template's
   Goal/Scope/Criteria/Steps/Decisions structure and lives in `active/` as required.

## Cross-doc consistency (acceptance-criterion check)

- **Branch-diff unit (`main...HEAD`):** agreed across `code-review-prompt.md`, `lifecycle.md`,
  `review/AGENTS.md`, `AGENTS.md` step 5, `running-the-workflow.md`. ✓
- **Commit-before-re-spawn:** present in `AGENTS.md` step 5, `review/AGENTS.md`, `lifecycle.md`. ✓
- **SHA-keying (`--short=12` / 12-char):** consistent in `code-review-prompt.md`,
  `review/AGENTS.md`, `lifecycle.md`; no lingering bare `--short`/`--short HEAD` anywhere. ✓
- **active→closed ownership:** reviewer writes only; working agent moves on APPROVED — stated
  consistently. ✓
- **Cold-start genesis-on-`main` exemption:** stated in both `AGENTS.md` (step-1 prep) and
  `cold-start.md`, and cross-referenced; `cold-start.md` "step 10 / first task after handoff"
  matches the actual `### 10. Hand off` heading. ✓
- Residual `git diff HEAD` mentions exist only inside exec-plan 001's Context/rejected-option
  prose, which deliberately describes the old model — not an operational instruction. ✓

## Links / inline paths

All markdown links and inline file paths introduced or touched resolve from their containing
file: `docs/review/code-review-prompt.md`, `docs/agents/running-the-workflow.md`
(`../review/...`), `docs/bootstrap/cold-start.md` (`../../AGENTS.md`), `docs/review/AGENTS.md`
(`reports/lifecycle.md`, `../agents/running-the-workflow.md`), and `AGENTS.md`. No broken
operational-doc paths introduced.

## Conclusion

The change is internally consistent across every doc it touches, introduces no broken
links/paths, and correctly self-applies (the reviewer reviewing this PR is the fixed one).
No correctness, security, or convention issues found.

VERDICT: APPROVED
