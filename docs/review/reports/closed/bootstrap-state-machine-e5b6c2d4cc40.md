# Pre-commit review — `bootstrap-state-machine` @ e5b6c2d4cc40

Unit of review: `git diff main...HEAD` (three-dot). Fresh review — no prior report in
`docs/review/reports/active/`.

## Scope

Introduces an explicit two-phase "bootstrap state machine":

- New root `BOOTSTRAP_STATE` sentinel shipping `unbootstrapped`.
- `guard-bootstrapped` Makefile recipe wired as a prerequisite of `fmt`/`fmt-check`/`lint`/
  `test`/`build`.
- Top-of-file binary phase route in `AGENTS.md` + reframed "Starting a new project" / Workflow prose.
- `cold-start.md` §1 (sentinel-first detection) and §8 (bit-flip unlock) updates; intro framing.
- `docs/bootstrap/AGENTS.md` hard-rule note.
- Template-only CI tripwire asserting the artifact ships `unbootstrapped`.
- README + ARCHITECTURE documentation.
- Exec-plan `docs/exec-plans/active/007-bootstrap-state-machine.md`.

## Findings

### Correctness — guard recipe

- Make `$$` escaping is correct throughout; the recipe is a single `;`/`\`-joined shell line.
- Missing file: `cat BOOTSTRAP_STATE 2>/dev/null || echo bootstrapped` → absent treated as
  bootstrapped (exit 0). Matches the documented "deleting it never bricks a repo" claim.
- Value comparison: `BOOTSTRAP_STATE` is `unbootstrapped\n`; command substitution strips the
  trailing newline, so `[ "$state" != "unbootstrapped" ]` evaluates correctly. A
  `bootstrapped` (or any other) value yields exit 0 — consistent with "blocked iff explicit
  `unbootstrapped`".
- Origin exemption: real origin is `https://github.com/experiments-with-ai/harness-template.git`,
  which matches the `*experiments-with-ai/harness-template*` `case` glob → template + template CI
  are exempt. Verified the pattern mirrors the existing `clean-lifecycle` idiom.
- `FORCE=1` escape and the `git remote ... || true` fallback are correct; a repo with no origin
  falls through to the `FORCE`/block path, which is the intended (block) behavior for a non-template
  unbootstrapped repo.

### Will it wrongly block CI or a bootstrapped clone? — No

- Template CI runs `make ci` on the template origin → guard exits 0 at the origin `case`. Stack
  targets run as today. The new tripwire step only asserts the shipped sentinel value and uses an
  independent `|| echo MISSING` (correctly distinct from the guard's `|| echo bootstrapped`, since
  a missing artifact value *should* fail the tripwire).
- A freshly bootstrapped clone has state `bootstrapped` → guard exits 0 on any origin. Not blocked.
- Make runs `guard-bootstrapped` once per invocation even though four targets depend on it; under
  `make ci` it is evaluated per top-level target build but is idempotent and side-effect-free.

### Doc / mechanism consistency — Consistent

- Absent-file semantics are stated identically in the guard, the `AGENTS.md` route, and
  `cold-start.md` §1 (absent ⇒ Phase 2 / bootstrapped).
- §8 documents the flip as the LAST provisioning action and explicitly notes the guard becomes
  inert post-flip, so the §8 rewrite of the four stack targets need not preserve the prerequisite —
  internally coherent.
- All newly referenced links resolve to existing files: `docs/maintaining-the-template.md`,
  `docs/bootstrap/cold-start.md`, `docs/agents/running-the-workflow.md`, `README.md`,
  `ARCHITECTURE.md`, `docs/bootstrap/AGENTS.md`. No broken markdown links found by inspection.

### Repo conventions

- The exec-plan sits in `docs/exec-plans/active/`, which is expected at review time; the working
  agent closes it (step 6) before `lint-harness` (step 7), per the root pipeline.
- ARCHITECTURE/README/AGENTS framing matches existing house style and the `clean-lifecycle` prior art.

## Non-blocking observations (no action required)

- The `⛔` emoji in the Makefile banner is recipe stdout, not agent-to-user prose, so the
  no-emoji guidance for agent communication does not apply; left as a stylistic call for the author.
- The guard checks state before origin (the inverse of `clean-lifecycle`'s order); behavior is
  equivalent and correct, just a deliberate ordering difference.

No correctness, security, or convention defects warranting changes.

VERDICT: APPROVED
