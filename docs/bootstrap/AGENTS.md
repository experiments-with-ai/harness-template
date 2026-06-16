# Bootstrap

This directory holds the **cold-start flow**: how an agent turns the empty template into a
real, harnessed project.

To start a new project from this template, follow [cold-start.md](cold-start.md) end to end.

- Stack catalog and per-stack provisioning checklist: [blessed-stacks.md](blessed-stacks.md).
- Per-project success criteria (and the honesty rule for unknowns): [quality-bar.md](quality-bar.md).
- Fixed fixture used to verify the flow itself: [smoke-fixture.md](smoke-fixture.md).

**Hard rule:** do not write product code or scaffold a real stack until the cold-start flow
reaches its explicit human **approval gate**. Persist interview answers to repo artifacts as
you go; draft a strawman; get approval; only then provision.
