# Smoke Fixture

The fixed input used to verify the **cold-start flow itself** — the harness-template's own
eval, and the pre-release dogfood. It does not test any product; it tests that the flow in
[cold-start.md](cold-start.md) runs, that its artifacts land at the right paths, and that the
human approval gate actually blocks premature coding.

Run it before tagging a release. If the flow regresses, this catches it.

## The fixed input

When the cold-start interview asks what we are building, the operator answers — verbatim —
with the fixture prompt:

> **a simple habit tracker web app**

That is the entire input. Do not elaborate, do not pre-answer follow-ups in advance. Let the
adaptive interview ask its questions; answer them plausibly and minimally (a small front-end
web app, single user, in-memory or local persistence is fine). The point is to exercise the
flow's machinery, not to design a real product. Keep answers deterministic enough that a
re-run produces the **same artifact shapes**.

## Expected artifact shapes

The flow passes the smoke test when it produces artifacts of these **shapes** (structure and
location — not exact wording). Concrete text will vary run to run; the shapes must not.

### 1. A PRD at `docs/references/product/prd.md`

- File exists at exactly that path (the cold-start flow writes the new project's brief here).
- Names the product as a habit-tracker-shaped web app and captures problem, primary user,
  and a short scope / non-goals section — enough that an agent could plan against it.
- It is a brief, not a novel. Substance over length.

### 2. `ARCHITECTURE.md` with its placeholders filled

The template ships `ARCHITECTURE.md` with three placeholder slots — two marked `TBD`
(Application, Backend/Data) plus an Enforcement section to complete. After the flow they are
resolved (no bare `TBD` remains):

- **Application(s)** — no longer `TBD`. Records a web-app surface and a concrete chosen
  stack (e.g. a web app on Vite + React, or any blessed equivalent), with the directory
  layout.
- **Backend / Data** — either a decided datastore/service boundary **or** explicitly marked
  **none** (a front-end-only habit tracker with local persistence is a legitimate "none").
  An unfilled `TBD` here is a fail.
- **Enforcement & tooling** — lists the stack linters / type checkers / validators actually
  provisioned for this stack, on top of the always-present harness linter and validation loop.

### 3. A first execution plan at `docs/exec-plans/active/001-<slug>.md`

- Exactly one plan file under `docs/exec-plans/active/`, named `001-<slug>.md` (the
  cold-start flow's first plan is always `001`).
- Follows [the exec-plan template](../exec-plans/template.md): has Goal, In/Out of Scope,
  Acceptance Criteria, Steps, Open Questions, and a Decisions section.
- Describes the **first real build step** for the product — it is the work that begins *after*
  approval, not the bootstrap itself.

### 4. A populated `docs/bootstrap/quality-bar.md`

- The per-project success criteria from [quality-bar.md](quality-bar.md) are filled in for
  this product (what "good" means for the habit tracker), with unknowns marked honestly rather
  than invented.

### 5. THE KEY INVARIANT — no product code before the approval gate

This is the assertion the whole fixture exists to check:

- Before the flow reaches its explicit human **approval gate**, the **only** code in the repo
  is the disposable tracer bullet (`src/index.ts` + `src/index.test.ts`).
- No habit-tracker source, no provisioned stack scaffolding, no new app/package directories
  exist yet — those are produced *after* approval.
- The artifacts above (PRD, architecture, plan, quality bar) are **documents**, written before
  the gate. Product **code** is not.

If any product code appears before the gate, the flow has failed, regardless of how good the
documents look.

## How to run the check

Drive the cold-start interview with the fixture far enough to confirm three things: the
interview runs, the artifacts land at the right paths, and the gate blocks premature coding.

**Run it in a disposable worktree or a throwaway clone.** The published template must contain
**no** smoke artifacts — discard all scratch output when done. Never commit fixture runs.

```sh
# Throwaway clone (or: git worktree add ../smoke-scratch in a clean checkout)
git clone . /tmp/harness-smoke && cd /tmp/harness-smoke

# Drive cold-start.md with the fixed input, answering follow-ups minimally:
#   "a simple habit tracker web app"
# Stop AT the human approval gate — do NOT approve.

# --- Assert artifact shapes (pre-gate state) ---
test -f docs/references/product/prd.md            # PRD landed
! grep -q 'TBD' ARCHITECTURE.md                   # placeholders resolved (no bare TBD remains)
ls docs/exec-plans/active/001-*.md                # first plan is 001-<slug>
test -s docs/bootstrap/quality-bar.md             # quality bar populated

# --- Assert the KEY INVARIANT: tracer bullet is still the ONLY code ---
# Only src/index.ts and src/index.test.ts should exist; no provisioned product code.
find src -type f                                  # expect exactly the two tracer files

# Done. Discard the scratch checkout entirely.
cd - && rm -rf /tmp/harness-smoke
```

You do not need to push past the approval gate to pass the smoke test — confirming the gate
**halts** the flow with all documents in place and no product code is the success condition.
Optionally, a second run may approve to confirm provisioning starts, but that output is also
disposable.

## Pass / fail checklist

The run **passes** only if all of the following hold at the approval gate:

- [ ] The interview ran and asked adaptive follow-ups from the one-line fixture input.
- [ ] `docs/references/product/prd.md` exists and is a usable, scoped brief.
- [ ] `ARCHITECTURE.md` has no remaining `TBD`: application = web app, backend/data decided
      or explicitly **none**, enforcement/tooling listed.
- [ ] Exactly one plan exists at `docs/exec-plans/active/001-<slug>.md`, following the template.
- [ ] `docs/bootstrap/quality-bar.md` is populated (unknowns marked honestly, not fabricated).
- [ ] **No product code exists** — `src/` still contains only the tracer bullet; no stack
      scaffolding or app/package dirs.
- [ ] The flow **stopped** at the approval gate and did not provision or write product code on
      its own.
- [ ] The scratch worktree/clone was discarded; nothing from the run was committed to the
      template.

Any unchecked box is a **fail**: fix the flow (not the fixture) and re-run.
