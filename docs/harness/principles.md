# Harness Principles

These are the engineering principles a project built on this harness is expected
to follow. They are informed by external sources, but the sections below are not
meant to be a verbatim summary of those sources.

Sources: [Harness Engineering](https://openai.com/index/harness-engineering/)
([local copy](../references/harness-engineering/harness-engineering.md)).

---

## Adopted Now

### 1. Repository is the system of record

Anything an agent needs to do reliable work must live in the repo. If context
only exists in chat, in docs outside the repo, or in someone's head, it is not
legible to the agent and cannot be relied upon.

### 2. `AGENTS.md` is a map, not an encyclopedia

Keep `AGENTS.md` short and stable. It should point to the next documents the
agent needs, not try to inline every rule, decision, and workflow.

When a part of the repo needs local guidance, prefer adding another
directory-local `AGENTS.md` close to that code or doc area instead of creating a
separate `index.md` map file.

### 3. Structured docs with progressive disclosure

Documentation should be versioned, co-located, and easy to navigate. Agents
should be able to move from `AGENTS.md` to architecture docs to domain docs
without being flooded with context up front.

### 4. Boring, legible technology wins

Prefer tools, libraries, and patterns that are stable, well-documented, and easy
for both humans and agents to reason about. "Boring" is a feature when the goal
is predictable execution.

Use standard tools directly when they already fit the job. The repo should
document workflow-specific rules around those tools, not generic tutorials for
how they work.

### 5. Layered architecture with explicit boundaries

Strict dependency directions make large changes safer and easier to reason
about. Cross-cutting concerns should enter through explicit interfaces, not by
bleeding through every layer.

### 6. Mechanical enforcement beats tribal knowledge

When an invariant matters, encode it in linting, tests, CI, or tooling. If a
rule exists only in prose, it will drift.

### 7. Validation loops beat one-shot generation

The agent should validate its work, observe the result, fix issues, and rerun
checks until the change is clean. Minimum feedback loop: formatting, lint,
tests, and build.

### 8. Execution plans are first-class artifacts

Complex tasks should leave a durable trail in the repo: goal, steps, progress,
and decisions. Plans are part of the system, not disposable scratch notes.

---

## Directionally Important, Not Yet Canonical

These ideas are useful and likely relevant to most projects, but they are not
yet strong enough to be treated as repo-wide rules.

### 9. Agent-to-agent review can scale better than manual review

Agent review is promising because it reduces human copy-paste and can keep up
with higher throughput. Adopt this where it helps, while keeping human judgment
for merge decisions and product-level tradeoffs.

### 10. Doc-gardening should become a recurring maintenance loop

As a repo grows, stale docs and bad patterns will accumulate. A recurring
cleanup pass by agents is likely better than periodic manual cleanup bursts.

### 11. Richer observability should become agent-legible

Today the minimum validation loop is local checks and CI. Over time, logs,
metrics, traces, and UI/runtime signals should become directly queryable by
agents so they can debug behavior, not just compile correctness.

---

## Observability Principles To Adopt Later

These are useful defaults once a project has more runtime behavior to observe.

### 12. Structured logs over free-form text

If you emit logs, prefer machine-queryable fields over narrative strings.

### 13. Favor rich events over log spam

It is usually more useful to capture one context-rich event than many scattered
lines with partial information.

### 14. Debugging should feel like analytics

The end state is being able to ask targeted questions of runtime data instead of
grepping through unstructured output.

---

## Anti-patterns

- One giant `AGENTS.md` that tries to explain everything
- Important context that only exists outside the repo
- Architecture rules that depend on memory instead of enforcement
- Big-bang cleanup efforts instead of continuous maintenance
- Validation that stops at code generation without observing behavior
