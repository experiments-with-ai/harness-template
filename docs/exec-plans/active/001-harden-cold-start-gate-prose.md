# Exec Plan 001: Harden the cold-start gate prose (Layer 0)

## Goal

Close the prose foothold that let an agent rationalize past the cold-start approval gate
("small creative one-off, ceremony is overkill") during a dogfood smoke test. Re-assert, at
each decision point where an agent routes into or past the gate, that the gate is mandatory for
the first build regardless of size or register, and that proportionality is the user's call, not
the agent's.

## In Scope

- Root `AGENTS.md`: strengthen the "Starting a new project" no-product-code line with an
  explicit no-exemption clause; add a gate-precedence note to the "Workflow" section and
  scope-fence the plan-mode choice to post-handoff.
- `docs/bootstrap/AGENTS.md`: add the no-exemption clause to the Hard rule.

## Out of Scope

- Layer 1 (CI tripwire reusing the doc-tripwire grep idiom + the cold-start.md step-1 predicate).
- Layer 2 (PreToolUse write-time guard / approval marker).
- Server-side branch-protection required-check changes.
- Any non-prose / mechanical enforcement. This round is prose-only.

## Acceptance Criteria

- [ ] Root `AGENTS.md` "Starting a new project" states there is no small/creative/one-off
      exemption and routes proportionality to the user.
- [ ] Root `AGENTS.md` "Workflow" re-asserts that the cold-start gate precedes the pipeline and
      scope-fences the plan-mode choice to post-handoff.
- [ ] `docs/bootstrap/AGENTS.md` Hard rule carries the no-exemption clause.
- [ ] `make fmt lint test build` green; `make lint-harness` green at the gate (pairing intact,
      no broken links).

## Steps

- [ ] Edit root `AGENTS.md` (two regions: "Starting a new project" + "Workflow").
- [ ] Edit `docs/bootstrap/AGENTS.md` Hard rule.
- [ ] Run inner-loop checks (`make fmt lint test build`).
- [ ] Fresh-context review → APPROVED.
- [ ] Close plan, run harness gate (`make lint-harness`).
- [ ] `make clean-lifecycle` (delete-before-merge), push, PR, CI, merge.

## Open Questions

- (none)

## Decisions

Record every non-trivial choice made while executing this plan. One block per decision.

### D-1: Layer 0 only this round (2026-06-17)

- **Context:** A dogfood smoke test (`habit-smoke-v2`) showed an agent read the cold-start MUST,
  named it, then overrode it via a "proportionality" rationalization and wrote product code
  directly to the repo root. Independent analysis identified three remediation layers: a prose
  fence (Layer 0), a CI tripwire (Layer 1), and a write-time PreToolUse guard (Layer 2).
- **Options considered:**
  - A: Ship all three layers now — rejected: Layers 1–2 are mechanical, larger, and collide with
    the template's intentional "no `.claude/settings.json`" multi-tool stance
    (`docs/agents/running-the-workflow.md` §4); they deserve their own round(s) and design review.
  - B: Prose-only (Layer 0) this round — chosen: the smallest change that closes the exact
    vocabulary foothold the agent grabbed, is tool-neutral (helps Codex / manual drivers too), and
    ships clean.
- **Decision:** Land Layer 0 prose fences only; leave Layers 1–2 as follow-up rounds.

### D-2: Honest scope of the fix (2026-06-17)

- **Context:** Prose is exactly what the agent overrode; prose alone cannot make bypass
  impossible.
- **Decision:** Frame Layer 0 as *lowering the probability* of rationalization — removing the
  escape-hatch vocabulary and re-asserting the gate at decision-time — not as a hard guarantee.
  The next dogfood validates whether the fence holds; Layers 1–2 remain available if it does not.

## Notes

- Template-maintenance round → delete-before-merge: this plan and its review report are wiped via
  `make clean-lifecycle` before merge so `main` stays clonable (lifecycle dirs `.gitkeep`-only).
