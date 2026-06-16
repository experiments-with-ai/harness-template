# Observability Checklist

The validation loop does not stop at `fmt` / `lint` / `test` / `build`. Those tell the agent
whether the code is *well-formed*; they say nothing about whether the *running system* behaves.
The loop's final extension is to **make the running system legible to the agent**: what the
agent cannot observe, it cannot debug. An agent that can only read source — but cannot see logs,
runtime errors, or the rendered UI — is reduced to guessing, and guessing breaks the
fix → rerun → confirm loop that makes a harness reliable.

This is a **post-bootstrap** checklist. A greenfield template has nothing running yet, so do
**not** bake a full observability stack into it. Instead, the cold-start flow wires the
*relevant* items once the real stack is provisioned (see
[../bootstrap/cold-start.md](../bootstrap/cold-start.md), step 8), and richer observability is a
capability the project **graduates to** as runtime behavior accumulates — not scaffolding to
stand up before there is anything to observe (see
[../harness/capability-layering.md](../harness/capability-layering.md)).

## The checklist (applied per stack, post-bootstrap)

- **Structured logging.** Emit machine-queryable fields (level, event name, request/trace id,
  key attributes) over free-form prose strings. The agent should be able to *filter* logs, not
  scroll them. A line the agent can `grep` on a stable key beats a sentence it has to parse.
- **Surface runtime errors to the agent.** Exceptions, stack traces, and failed requests must
  land somewhere the agent can read after driving the system — console output, a log file, an
  error stream — not vanish into a UI toast or a swallowed `catch`. An unsurfaced error is an
  invisible bug.
- **Keep the app locally bootable per change.** Every change must leave the system runnable with
  a single, documented command so the agent can actually exercise it. If booting the app needs
  tribal knowledge or a broken step, the agent loses the ability to observe at all.
- **Screenshots for any UI.** If the change has a visible surface, the agent must be able to
  *see* it — capture before/after, on the relevant viewports. Pixels are ground truth; a passing
  test does not prove the screen renders.
- **Traces / metrics (optional, later).** Once there is real runtime behavior worth querying
  (latency, throughput, hot paths), distributed traces and metrics become worthwhile. They are a
  graduation target, not a day-one requirement.

## Provisioned per stack

Bootstrap wires the items that fit the chosen stack family. Map the checklist to the stack:

```
web-app          → UI validation (drive → snapshot → observe → loop)
                   + structured logs + runtime-error surfacing + local bootability
api-service      → runtime-error surfacing + structured logs + local bootability
cli              → runtime-error surfacing + structured logs + local bootability
```

### web-app — wire UI validation

A UI is only legible if the agent can both drive it and observe what happened. Wire the
**drive → snapshot → observe → loop** pattern (the Chrome DevTools pattern):

1. **Drive** the running app — navigate, click, fill, submit.
2. **Snapshot** before and after the interaction so the visual delta is inspectable.
3. **Observe** runtime events — console messages, network requests, thrown errors — not just the
   final pixels.
4. **Loop** — feed what was observed back into the fix, re-drive, re-snapshot, until the
   behavior is correct.

This is the runtime counterpart to the inner code loop: the agent changes the app, *watches the
real app react*, and iterates. Wire it in step 4 of the task pipeline (the **UI validation**
step in the root [../../AGENTS.md](../../AGENTS.md)).

### api-service / cli — wire the non-visual triad

With no UI to screenshot, legibility comes entirely from text the agent can read after running
the system:

- **Runtime-error surfacing** — failures print or log where the agent will see them.
- **Structured logs** — queryable fields the agent can filter to confirm a code path ran.
- **Local bootability** — one documented command to start the service / run the CLI, so the
  agent can exercise it on every change.

## Where this gets wired

- **Bootstrap (once):** [../bootstrap/cold-start.md](../bootstrap/cold-start.md) step 8
  provisions the stack and adds the observability hook that matches the stack family. The
  per-stack provisioning detail lives in
  [../bootstrap/blessed-stacks.md](../bootstrap/blessed-stacks.md).
- **Per task (every change):** the working agent keeps the system bootable and uses the wired
  hook to observe behavior — UI validation for a web app, logs and error output otherwise — as
  part of the validation loop in the root [../../AGENTS.md](../../AGENTS.md).
- **Later (graduate):** deeper observability — tracing, metrics, dashboards, supervisors — is a
  rung to climb when there is runtime behavior worth querying, per
  [../harness/capability-layering.md](../harness/capability-layering.md). Do not climb it before
  the cheaper rungs are pulling their weight.

The principle underneath all of it: **boring, legible feedback wins.** A plain structured log
the agent can read every run is worth more than an elaborate observability platform it has to be
taught to query.
