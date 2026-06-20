# Exec Plan 007: Bootstrap/implement separation as an explicit state machine

## Goal

Make the "bootstrap first, implement second" rule **mechanically enforced** instead of
prose-only, so a freshly cloned template can't be talked past the cold-start gate by a "just
build X" request. Turn the two steps into an explicit two-phase state machine keyed on a single
machine-readable sentinel, gated by the Makefile (which travels with every clone) and routed at
the very top of `AGENTS.md`.

## In Scope

- New root sentinel `BOOTSTRAP_STATE` (ships `unbootstrapped`).
- A `guard-bootstrapped` Makefile recipe wired as a prerequisite of `fmt`/`fmt-check`/`lint`/
  `test`/`build`, reusing the existing `clean-lifecycle` origin-exempt idiom (template
  maintainers/CI exempt; `FORCE=1` override; only a still-`unbootstrapped` **clone** is blocked).
- A top-of-file binary state route in `AGENTS.md` (Phase 1 bootstrap vs Phase 2 pipeline), with
  the template-maintenance origin carve-out so maintainers aren't misrouted.
- `cold-start.md` updates: detection (§1) reads the sentinel; provisioning (§8) flips the bit as
  the explicit unlock; surrounding prose reframed as the two-phase machine.
- `docs/bootstrap/AGENTS.md` "Hard rule" references the sentinel.
- A template-only CI tripwire asserting the distribution artifact ships `unbootstrapped`.
- Short human-facing note (README + cold-start) so the stray root file is legible.

## Out of Scope

- Any change to the external harness linter (pinned npm package — we don't control its rules;
  the Makefile guard is the backstop instead).
- Touching the unrelated uncommitted whitespace edit in `docs/security/baseline.md`.
- Per-stack provisioning detail (blessed-stacks.md) beyond the bit-flip note.

## Acceptance Criteria

- [ ] `BOOTSTRAP_STATE` exists at root containing `unbootstrapped`.
- [ ] On a **clone** (non-template origin) with `unbootstrapped`, `make build`/`test`/`fmt`/`lint`
      print a STOP banner pointing at cold-start and exit non-zero; `FORCE=1` overrides.
- [ ] On the **template** origin (and in template CI), the guard is a no-op — `make ci` stays green.
- [ ] With `BOOTSTRAP_STATE=bootstrapped` (or absent), the guard is a no-op on any origin.
- [ ] `AGENTS.md` opens with the binary state route; it carves out template maintenance by origin.
- [ ] `cold-start.md` §1 detection is sentinel-first; §8 flips the bit as the documented unlock.
- [ ] `make ci` is green on this branch (template origin), `make lint-harness` clean (plan closed).

## Steps

- [ ] Add `BOOTSTRAP_STATE` (content: `unbootstrapped`).
- [ ] Add `guard-bootstrapped` to the Makefile and make the four stack targets depend on it.
- [ ] Add the top-of-file state route to `AGENTS.md`; reconcile "Starting a new project" + Workflow
      prose to the Phase 1/Phase 2 framing and the sentinel.
- [ ] Update `cold-start.md` §1 (detection) and §8 (bit-flip unlock) + intro framing.
- [ ] Update `docs/bootstrap/AGENTS.md` hard rule.
- [ ] Add the template-only CI tripwire for the shipped sentinel value.
- [ ] Add the human-facing one-liner (README) explaining the sentinel.
- [ ] Verify: simulate a clone (`make build` with a non-template origin / `FORCE` off) blocks;
      template origin passes; `make ci` green; `make lint-harness` clean after plan close.

## Open Questions

- (none)

## Decisions

Record every non-trivial choice made while executing this plan. One block per decision.

### D-1: Sentinel file + Makefile guard as the enforcement layer (2026-06-20)

- **Context:** The gate was prose-only and failed exactly when the agent was most motivated to
  skip it. Three failure layers: detection is a 3-part inference, routing shows both paths at
  once, and there is no mechanical backstop. The harness linter is an external pinned package, so
  we can't add a "no product code before bootstrap" rule there.
- **Options considered:**
  - A: Settings.json/pre-commit hooks — rejected: hooks don't travel with a clone and are
    tool-specific (Claude Code vs Codex).
  - B: New harness-linter rule — rejected: external pinned package, not ours to change.
  - C: Makefile guard keyed on a sentinel, reusing the `clean-lifecycle` origin idiom — chosen:
    the Makefile travels with every clone, and the agent's mandatory `make fmt/lint/test/build`
    loop becomes the chokepoint — it literally can't report "done" on product code without first
    flipping the bit, and the only sanctioned flip is cold-start.
- **Decision:** Ship `BOOTSTRAP_STATE=unbootstrapped`; block the four stack targets on a
  `guard-bootstrapped` recipe; cold-start flips the bit to `bootstrapped` at provision time.

### D-2: Block only a still-`unbootstrapped` clone; exempt template + bootstrapped (2026-06-20)

- **Context:** The guard must not break the template's own tracer CI/inner loop, nor a freshly
  bootstrapped clone — only the dangerous case (a clone writing product code before bootstrap).
- **Options considered:**
  - A: Block whenever state is `unbootstrapped` — rejected: bricks the template's own tracer
    build/test (the template permanently ships `unbootstrapped`).
  - B: Origin-exempt + state-exempt + `FORCE=1`, mirroring `clean-lifecycle` — chosen: identical,
    already-trusted idiom; template/CI exempt by origin, bootstrapped clones exempt by state,
    escape hatch for maintenance forks.
- **Decision:** Guard blocks iff `state == unbootstrapped` AND origin is not the template AND
  `FORCE != 1`. Post-flip the guard is permanently inert, so the §8 stack-target rewrite needn't
  worry about preserving it.

### D-3: Keep the file post-bootstrap (flip value) rather than delete it (2026-06-20)

- **Context:** Cold-start needs to record "bootstrap done" in a way both the guard and the
  AGENTS.md route read deterministically.
- **Options considered:**
  - A: Delete `BOOTSTRAP_STATE` on bootstrap — rejected: "absent" is ambiguous and loses the
    visible record of which phase the repo is in.
  - B: Flip content to `bootstrapped` — chosen: explicit, greppable, durable evidence; guard and
    route both treat absent as bootstrapped too, so a deleted file never bricks a repo.
- **Decision:** Cold-start writes `bootstrapped`. Guard/route: blocked iff explicit
  `unbootstrapped`; absent or `bootstrapped` ⇒ Phase 2.

## Notes

- Template-maintenance round: follows `docs/maintaining-the-template.md` (delete-before-merge;
  `make clean-lifecycle` before PR). This plan and its review report do not persist on `main`.
