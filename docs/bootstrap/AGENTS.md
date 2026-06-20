# Bootstrap

This directory holds the **cold-start flow**: how an agent turns the empty template into a
real, harnessed project.

To start a new project from this template, follow [cold-start.md](cold-start.md) end to end.

- Stack catalog and per-stack provisioning checklist: [blessed-stacks.md](blessed-stacks.md).
- Per-project success criteria (and the honesty rule for unknowns): [quality-bar.md](quality-bar.md).
- Fixed fixture used to verify the flow itself: [smoke-fixture.md](smoke-fixture.md).

**Hard rule:** do not write product code or scaffold a real stack until the cold-start flow
reaches its explicit human **approval gate** — no matter how small, creative, or self-contained
the build seems. "It's just a quick one-off" is not an exemption, and whether the flow is overkill
is the user's call, not the agent's. Persist interview answers to repo artifacts as
you go; draft a strawman; get approval; only then provision.

This is **Phase 1** of the template's two-phase state machine, recorded in the root
`BOOTSTRAP_STATE` file (`unbootstrapped` → run this flow; `bootstrapped`/absent → it's already a
live project, skip). Provisioning flips the bit to `bootstrapped` as its final unlock, and the
Makefile guard mechanically blocks the stack `make` targets on a clone until it does — so the
gate is enforced, not merely asked for.
