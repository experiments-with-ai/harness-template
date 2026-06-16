# Harness Metrics

This doc defines what the harness honestly measures — and, just as importantly, what it refuses to claim.

## Hard rule: no fabricated counterfactuals

A greenfield project is **never built both with and without the harness**. There is no parallel universe to diff against. So any number of the form "X% faster" or "Y fewer bugs vs. no-harness" would be **invented**. For a template whose entire thesis is *deterministic, provable outcomes*, an invented comparison is not a harmless rounding error — it is fatal. It poisons the one thing the harness is selling: that you can trust the numbers because they come from facts, not vibes.

Real before/after metrics (`was → now`) only exist for a **brownfield** effort: take an existing codebase, apply the harness, and measure the delta on the *same* system. That is legitimate, but it is a future, project-specific exercise and is **out of scope** for this template. This repo ships no counterfactual, and this doc forbids inventing one.

## What we do ship: a deterministic harness scorecard

We ship a **bootstrap-end summary**: a deterministic scorecard that the cold-start flow prints once the project is bootstrapped. It is:

- **Provider-neutral** — no LLM is involved in producing it, so there is nothing to "guess."
- **Reproducible** — any later run can regenerate it from documented repo contents.
- **Fact-sourced** — it reads only **repo state + git history + CI status**. Every line traces to something on disk or in the CI log.

In v1 this scorecard is a **documented summary, here**, that the cold-start flow emits at the end of bootstrap. It can **later** be promoted to a standing script (`scripts/harness-report.*`, exposed as `make harness-report`) so any contributor can reprint it on demand — but that promotion is **not required for v1**.

## The scorecard has two parts

### Part A — Process artifacts (the discipline happened)

Counts and statuses drawn straight from repo + git + CI. These show that the workflow was actually followed, not just described:

- **Exec-plans created with Decisions logged** — number of plans in `docs/exec-plans/completed/` (plus the active one) that carry a populated Decisions section.
- **Reviewer iterations to APPROVED** — how many review rounds each plan took to reach an APPROVED report under `docs/review/reports/closed/`.
- **Validation-loop runs / CI green** — count of green `make ci` / CI runs in the history.
- **Linter status** — with this nuance stated verbatim:

  > stack lint clean now; the harness gate runs at the first plan close

  At bootstrap end, the just-created **plan `001` is legitimately active** in `docs/exec-plans/active/`. The harness gate (`make lint-harness`) is therefore expected to flag an active plan and is **not** run yet. So **do NOT report a false `harness-clean` here** — report the stack lint status (clean) and note the gate fires at the first plan close.

- **Share of changes traceable to a reviewed plan** — fraction of post-bootstrap changes that map back to an exec-plan that went through the reviewer gate.

### Part B — Guardrails-as-proof (the strong framing)

This is the part that earns trust. Instead of a fabricated speedup, we enumerate the **classes of failure** the harness either blocks outright or forces into a visible review/CI path before merge. Each is tagged:

- **[mechanical]** — a linter rule or CI gate fails; a machine stops it.
- **[process]** — a workflow step the pipeline forces, but **no checker verifies** it. Honest framing: this is a convention, not an enforcement.

The tags are load-bearing. For an honesty-thesis doc, calling a `[process]` convention "enforced" is exactly the overclaim to avoid. Keep them verbatim:

- No unpaired agent docs — **[mechanical]** (linter pairing + `claudeInclude`)
- No stale path in an operational doc — **[mechanical]** (linter `operational-doc-broken-path`; plus `brokenLinks` for AGENTS.md markdown links). Scope: README.md, every `AGENTS.md`/`CLAUDE.md`, and any `docs/workflow/**.md` inline paths + AGENTS.md links — not every doc.
- No abandoned/unclosed exec-plan at the gate — **[mechanical]** (linter `exec-plan-active-present` / `completed-open-checkbox` / `duplicate-id`, run at the gate)
- No merge without green CI — **[mechanical iff branch protection is enabled]** (CI is the check; blocking merge needs the GitHub branch-protection setting, which the template documents but cannot ship — so this is only mechanical once that setting is turned on)
- No unvalidated running system for a provisioned stack — **[mechanical]** (the stack's **validation gate** — a Playwright UI smoke / local-boot HTTP test / CLI stdout+exit-code test / ephemeral-DB assertion — runs in `make test`/CI; see [../bootstrap/blessed-stacks.md](../bootstrap/blessed-stacks.md). Present only after bootstrap provisions a stack; the empty template ships only the tracer test.)
- Loop/observability MCP wired for the inner dev loop — **[process]** (a browser/SQL MCP gives the agent eyes while iterating, but **no checker verifies it ran** — it is legibility, not a gate. The gate above is the enforced floor; the MCP rides on top.)
- No undocumented architectural decision — **[process]** (decisions live in the plan's Decisions section; no checker verifies presence)
- No silent unplanned product work after bootstrap — **[process]** (work flows through an exec-plan + reviewer gate; the initial scaffold is explicitly exempt)
- No encyclopedic root agent map — **[process]** (documented guidance; not mechanically enforced in v1)

## The honest claim

This scorecard is **not** "trust our number." It is:

> here are N failure modes the harness either blocks mechanically or forces into a visible review/CI path.

Of the list above, the `[mechanical]` items are stopped by a machine; the `[process]` items are forced by the workflow but proven only by the artifacts in Part A. That distinction is the whole point.

This doc forbids dressing these counts up as counterfactuals. A guardrail count is a statement about *what cannot pass*, not a claim about how much faster or cleaner the project is than some no-harness version that was never built.
