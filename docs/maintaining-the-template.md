# Maintaining the template itself

> **STOP — scope check.** This applies ONLY when you are developing `harness-template` itself.
> Run `git remote -v`. If `origin` is NOT `…/experiments-with-ai/harness-template`, this file does
> **not** apply: you are a project *built with* the harness — follow the normal pipeline in
> [AGENTS.md](../AGENTS.md), **keep** your exec-plans and review reports as durable history, and
> **never** run `make clean-lifecycle`.

The template is dual-purpose: the repo we develop, and the artifact people clone. To keep `main`
clonable at every commit (the four lifecycle dirs `.gitkeep`-only), a template-improvement round's
own exec-plan and review report are scaffolding that must **not persist on `main`**.

## Delete-before-merge sequence (template maintenance only)

1. Create the round's plan in `docs/exec-plans/active/NNN-<slug>.md`; implement.
2. Pre-commit review → report `active/` → `closed/` on APPROVED (normal pipeline).
3. Close the plan → move to `docs/exec-plans/completed/`.
4. `make lint-harness` (gate).
5. **`make clean-lifecycle`** — empties the four lifecycle dirs back to `.gitkeep`. This is the
   step that keeps the plan/report off `main`'s **tree**. (Squash-merge only keeps the intermediate
   *commits* out of history — it does NOT drop a file present at branch tip. Do not rely on squash;
   actually delete here.)
6. Push → PR. The `clean-state` check + branch protection gate it green.

The durable record of the round lives in the external enhancement plans and the PR's pre-squash
commits — not in `main`'s tree. Note: the template's own history therefore models
delete-before-merge, the **opposite** of what a product repo does — intentional and template-only.
