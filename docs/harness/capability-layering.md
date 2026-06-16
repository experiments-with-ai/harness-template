# Capability Layering

Complexity is a one-way ladder. You climb a rung only when the current rung
visibly fails — never speculatively, never "to be ready." Each rung you add is
permanent surface area: more to configure, version, secure, and explain to the
next agent. Start at the bottom and stay there as long as it holds.

The principle, in order of preference:

1. **Durable repo config first.** Prose and config checked into the repo.
2. **MCP only for a real external loop.** A UI, live logs, an external API.
3. **Skills for proven, repeated workflows.** Not for one-off tasks.
4. **Automations last.** Only over a workflow already known to be reliable.

See [principles.md](./principles.md) for why "the repository is the system of
record" and "mechanical enforcement beats tribal knowledge" sit underneath this.

## The ladder

### Rung 1 — Prose in the repo

- **What it is:** Markdown and config committed to the repo — `AGENTS.md`,
  `docs/**`, `Makefile` targets, lint config. The agent reads it on every run.
- **Graduate FROM it when:** you have written the same multi-step instructions
  into a plan or a prompt three times, or an agent keeps getting a repeatable
  workflow wrong despite the prose being correct and present.
- **Cost it adds:** essentially none. This is the floor. It is versioned,
  diffable, reviewable, and legible to humans and agents alike. Default here.

### Rung 2 — A Skill

- **What it is:** A named, reusable workflow (a Claude/Codex skill) that packages
  a sequence the agent invokes by name instead of re-deriving from prose.
- **Graduate TO it when:** a workflow has proven *repeatable* — same shape, run
  often enough that re-reading and re-assembling the prose each time is the
  bottleneck, and the steps are stable enough to name.
- **Cost it adds:** a second place a behavior lives. The skill can drift from the
  prose it was distilled from. Keep skills *thin*: have them point back at the
  authoritative doc rather than copy it, so the repo stays the system of record.

### Rung 3 — An MCP

- **What it is:** A Model Context Protocol server giving the agent a live tool —
  read logs, drive a browser/UI, call an external API.
- **Graduate TO it when:** the task genuinely requires a **real external loop**:
  observing or acting on a system that lives outside the repo and changes
  independently of it. If a file in the repo could answer the question, you do
  not need an MCP.
- **Cost it adds:** a running dependency — auth, network, version skew, failure
  modes, and a new trust/security boundary. It is the least legible rung: its
  behavior is not in the diff. Reach for it only when in-repo data cannot suffice.

### Rung 4 — An Automation / supervisor

- **What it is:** Something that drives the agent on a loop without a human in
  the turn — a scheduler, a watcher, a supervisor (e.g. a "Ralph-loop").
- **Graduate TO it when:** the underlying workflow is *already reliable* run by
  hand — it passes its validation loop unattended, repeatedly, with no babysitting.
- **Cost it adds:** the most. An unreliable workflow on a loop manufactures
  failures faster than a human can read them, and removes the steering human who
  would catch drift. Automate only what you would be comfortable ignoring.

## Out of scope for v1

The supervisor / Ralph-loop (Rung 4) is **intentionally out of scope for v1**.
No workflow here has yet earned it — which is exactly what "automations last"
prescribes. Shipping without it is the discipline working, not a gap.

Rungs 2 and 3 are likewise unbuilt by default. If the cold-start prose in
[`docs/bootstrap/cold-start.md`](../bootstrap/cold-start.md) proves reliable in
practice, it is a candidate to later graduate into **thin** native Claude/Codex
skills that *point back at* `docs/bootstrap/cold-start.md` rather than duplicate
it — keeping the repo as the single source of truth and the skill as a shortcut
to it.
