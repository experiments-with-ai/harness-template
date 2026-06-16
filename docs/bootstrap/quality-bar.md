# Quality Bar

This doc answers one question per project: **what does "done" actually mean here, and how do
we know we hit it?**

The *requirement* to define measurable success criteria is baked into the template — this
file exists in every harness. The *content* is empty until bootstrap. The cold-start
interview elicits it: see [cold-start.md](cold-start.md) step 4, which populates the template
at the bottom of this file.

This bar depends on **no external eval platform** — no hosted grader, no scoring service. It
is markdown plus a small, self-contained check (ideally a test the stack already runs). Keep
it that way: boring, legible, and in the repo.

## Why this exists

An agent with a precise target produces reliable work; an agent guessing at "good enough"
produces plausible work that drifts from intent. Vague criteria are the single biggest source
of confidently-wrong output. So we force the target to be written down, measurable, and — where
possible — checkable by code rather than by judgment.

## What "done" means per project

"Done" is **the success criteria below, demonstrably met**, plus the harness gate (green
build/lint/test/CI and a closed, traceable exec-plan). Both halves are required. A passing
build with unmet criteria is not done; met criteria with a red gate is not done either.

## What to capture

When you fill in the template, capture each of these. Be concrete — if a section is vague, it
is not yet usable.

- **Success criteria** — specific *and* measurable. "Search is fast" is not a criterion;
  "search returns results in under 200 ms for the seed dataset" is. Every criterion must be
  something a person or a check can unambiguously mark pass/fail.
- **Critical smoke flows** — the handful of end-to-end paths that *must* work for the product
  to be worth shipping. These are the flows you would test first by hand and the ones the
  smoke fixture exercises (see [smoke-fixture.md](smoke-fixture.md)).
- **Edge cases** — inputs and states that are known to break naive implementations: empty
  input, very large input, concurrent access, missing permissions, malformed data, the
  boundary values. Name the ones that matter; you cannot enumerate all of them.
- **Grading method** — *how* each criterion is judged. **Prefer code-based, deterministic
  grading**: a test, an assertion, a script that exits non-zero on failure. Reserve human or
  model judgment for things genuinely not mechanizable, and say so explicitly when you do.
- **High-risk unknowns** — anything you are unsure about that touches safety, compliance,
  privacy, authorization, payments, or other high-risk behavior. See the rule below.
- **Deferred / unknown** — everything you could not pin down. This is a first-class section,
  not a failure. An honest "we don't know yet" is more valuable than an invented metric.

## The honesty escape

> If you are not sure, say "I don't know"; record it as unknown/deferred and do not invent an
> eval gate.

> A badly-worded eval is worse than none.

A wrong or fuzzy criterion actively misleads: the agent optimizes toward it, the gate signs
off, and everyone trusts an answer that was never validated. When you cannot state a criterion
crisply, leave it in **Deferred / unknown** and move on. Do not paper over uncertainty with a
metric you cannot defend.

## High-risk unknowns

If an unknown affects **safety, compliance, privacy, authorization, payments, or other
high-risk behavior**, do one of two things — never guess:

1. **Scope it out of v1.** Explicitly exclude the behavior from the first version and record
   the exclusion, or
2. **Stop for an explicit human decision** before any implementation that touches it.

In both cases, record the unknown **here** (in **High-risk unknowns** and/or **Deferred /
unknown**) *and* in the active exec-plan's **Open Questions** section
(`docs/exec-plans/active/NNN-<slug>.md`; see [../exec-plans/template.md](../exec-plans/template.md)).
High-risk behavior is the one place where "I'll figure it out while coding" is forbidden.

## Fallback when criteria are absent

A new or thin project may not yet have concrete product criteria. That is acceptable — but the
bar does not drop to zero. Fall back to **harness-level checks**:

- `make build`, `make lint`, `make test` green, and CI (`make ci`) green.
- **Plan traceability**: every change maps to an exec-plan (or a justified lightweight change),
  the plan's Acceptance Criteria are ticked, Decisions are recorded, and the plan is moved to
  `docs/exec-plans/completed/`.

These are always in force. Project-specific criteria are added *on top* of them as they become
knowable; they never replace them.

## Template

The cold-start flow fills the block below **in place** — a fresh clone of the template *is* one
project, so this file becomes that project's quality bar (there is no second project in the same
clone to preserve a blank copy for). Replace the placeholders directly. Keep filled sections
concrete; keep honest gaps in **Deferred / unknown** rather than inventing content.

```markdown
## Success criteria

- [ ] <specific, measurable statement — pass/fail is unambiguous>
- [ ] <...>

## Critical smoke flows

- <end-to-end path that must work, described as a user would experience it>
- <...>

## Edge cases

- <input/state known to break naive implementations and how it should behave>
- <...>

## Grading method

- <criterion> → <how it is judged; prefer a code-based / deterministic check>
- <criterion> → <test / script / assertion, or "human judgment because …">

## High-risk unknowns

(Safety / compliance / privacy / authorization / payments / other high-risk.)
For each: scoped OUT of v1, or STOP for explicit human decision. Mirror in the active
exec-plan's Open Questions.

- <unknown> — <scoped out of v1 | needs human decision before implementation>

## Deferred / unknown

- <thing we could not pin down yet — recorded honestly, no invented metric>
```
