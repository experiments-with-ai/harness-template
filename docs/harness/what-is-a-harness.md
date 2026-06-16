# What Is a Harness?

You are evaluating a template. Before deciding whether it fits, it helps to know what
problem it solves and what shape the solution takes. This document is the conceptual tour:
no commands, no setup steps — just the idea and how this repository embodies it.

## The problem: fast, but unpredictable

A modern coding agent is astonishingly fast. Point it at a task and it will produce a
plausible diff in seconds, write tests, wire up CI, and explain its reasoning. For a small,
self-contained change in a small codebase, this often just works.

The trouble starts as the project grows. A raw agent — one operating with nothing but the
prompt and whatever it can scrape from the files in front of it — has no durable memory of
why things are the way they are. It re-derives intent on every run, sometimes correctly and
sometimes not. It copies whatever pattern it happens to see nearby, good or bad. It has no
reliable way to tell whether its change actually works beyond "the code looks right." Each
of these is a small source of variance, and variance compounds. A pattern guessed wrong in
week one becomes the template the agent imitates in week six. Drift breeds more drift.

The practical consequence is a difference in *how complexity scales*. With a good harness,
the cost of each additional feature stays roughly flat — the project grows about linearly,
because the environment keeps re-establishing the same ground truth for every task. Without
one, cost grows super-linearly: every new change has to fight the accumulated entropy of all
the changes before it, and the team spends an ever-larger fraction of its time cleaning up
after the agent instead of directing it. The bottleneck stops being the agent's speed and
becomes human attention — the one resource you cannot scale by buying more compute.

## What a harness *is*

A harness is **not the model**. Swapping in a smarter model helps at the margins, but it
does not fix an underspecified environment. The harness is the *environment* around the
agent: the disciplined operating context that turns an unpredictable generator into a
reliable contributor. Concretely, four kinds of things:

- **Docs** — a structured, versioned knowledge base that records intent, architecture,
  decisions, and conventions so the agent never has to guess them.
- **Conventions** — a small, explicit set of rules about how work is shaped, named, and
  organized, so every task starts from the same baseline.
- **Validation loops** — feedback mechanisms (format, lint, test, build, review, runtime
  observation) the agent runs *itself*, repeatedly, until the work is demonstrably correct.
- **Mechanical enforcement** — checkers that fail loudly and automatically when a rule is
  broken, so correctness does not depend on anyone remembering anything.

The model writes the code. The harness is everything that makes that code trustworthy.

## The core ideas

Six principles run through everything here. They are stated in full, with the reasoning, in
[principles.md](principles.md); the short version follows.

**Humans steer, agents execute.** The scarce resource is human time and attention, not
agent output. Humans set direction, specify intent, and define what "correct" means; the
agent does the mechanical work of getting there. The whole design exists to keep humans at
the high-leverage layer and off the keyboard.

**The repository is the system of record.** What the agent cannot see *does not exist*. A
decision settled in a chat thread, a constraint living in someone's head, a rationale buried
in a closed ticket — to the agent, none of it is real. Anything that must influence the
work has to be written down, in the repo, in a form the agent reads while it runs. Onboarding
an agent is exactly like onboarding a new hire who has access to nothing but the codebase.

**AGENTS.md is a map, not an encyclopedia.** Context is finite and precious. A giant
instruction file is self-defeating: it crowds out the actual task, and when everything is
marked important, nothing is. So the entrypoint stays short and points outward — progressive
disclosure. The agent starts from a stable, small map and is taught where to look next,
rather than being buried up front.

**Mechanical enforcement beats tribal knowledge.** A rule that lives only in prose rots; a
rule encoded in a checker applies everywhere, every time, for free. Once human taste is
captured as a lint or a structural test, it stops being something everyone has to remember
and becomes something nobody *can* forget. Prefer the checker over the paragraph.

**Validation loops beat one-shot generation.** Do not ask the agent to be right the first
time; ask it to *make itself* right by running checks and fixing what they surface, over and
over, until green. A tight fix-rerun loop turns an unreliable single shot into a reliable
process. This extends past the obvious checks: the running system itself — logs, errors,
screenshots — should be made legible so the agent can observe real behavior, not just guess
at it.

**Boring, legible technology wins.** Stable, well-understood, composable tools are easier
for an agent to model correctly than clever or opaque ones. The agent has seen boring
technology in its training data, can reason about it without surprises, and can inspect and
modify it directly. Legibility to the agent is a first-class selection criterion, not an
afterthought.

## Two layers: the harness core and the stack

This template draws a deliberate line between two things that are usually tangled together:

- The **harness core** — stack-agnostic and always present. The principles above, the
  documentation system of record, the workflow, the plan and review discipline, and the
  enforcement that keeps it honest. None of it assumes a language, framework, or product.
- The **stack layer** — the concrete technology: language, framework, formatter, test
  runner, build tool, UI and observability tooling. This is *provisioned once*, at
  bootstrap, when the template becomes a real project.

Keeping them separate matters for a few reasons. The discipline is the durable, reusable
part; it should not have to be reinvented for every new project, and it should not be held
hostage to a stack choice you might later regret. Bootstrapping becomes a clean, one-time
event — choose the stack deliberately rather than inheriting it by accident. And the two
audiences stay cleanly served: humans get concept prose (this document and its siblings),
while agents get a terse operational map. You can read and trust the harness before you have
committed to a single line of product technology.

## How this template embodies it

The ideas above are not aspirational here; they are wired into the repository's structure.

- **A `docs/` system of record.** Intent, architecture, conventions, and references live in
  versioned markdown, indexed from [../AGENTS.md](../AGENTS.md) outward. This *is* the
  "repository is the system of record" principle made physical. The short root `AGENTS.md`
  is the map; the docs are the territory.
- **Execution plans.** Non-trivial work is captured as a first-class, checked-in plan under
  `docs/exec-plans/active/` (copied from [../exec-plans/template.md](../exec-plans/template.md)),
  with steps and a decision log, then moved to `docs/exec-plans/completed/` when it lands.
  The plan is the agent's working memory, durable across runs and visible to the next one.
- **A read-only reviewer loop.** Before anything is committed, a fresh-context reviewer
  evaluates the diff against [../review/code-review-prompt.md](../review/code-review-prompt.md)
  and returns a single verdict; the working agent fixes and re-spawns until approved. This is
  a validation loop applied to *judgment*, not just to tests — a second set of eyes that
  never gets tired or attached to its own work.
- **An external harness linter.** A pinned, independent checker mechanically enforces the
  harness's own invariants — the entrypoint pairing, plan lifecycle, path integrity, and
  more. It is the "mechanical enforcement beats tribal knowledge" principle pointed at the
  harness itself, run as a gate so the rules cannot quietly erode.
- **A cold-start interview.** A new project does not begin with code. It begins with the
  bootstrap flow ([../bootstrap/cold-start.md](../bootstrap/cold-start.md)), which interviews
  you, drafts a strawman, waits for your *explicit* approval, then provisions the stack. This
  is "humans steer" enforced at the moment of highest leverage: before the first line exists.
- **A tracer bullet.** The template ships a minimal end-to-end slice in `src/` — a working
  thread from entrypoint to build to CI. It proves the validation loops are real and green
  before any product logic arrives, and gives the bootstrap something concrete to replace
  rather than a blank page to fill.

Each of these is small on its own. Together they are the difference between an agent that is
fast-and-hopefully-right and one that is fast-and-demonstrably-right.

## Where to go next

- [principles.md](principles.md) — the six core ideas in full, with the reasoning behind each.
- [../references/harness-engineering/harness-engineering.md](../references/harness-engineering/harness-engineering.md)
  — the source article this template generalizes, kept verbatim for reference.
- [../../AGENTS.md](../../AGENTS.md) — the root entrypoint and the agent's map into the
  workflow. If this document explained the *why*, that one is the *how*.
