---
paths:
  - "HARNESS.md"
  - "harness/**/*.md"
  - "harness/bin/*"
  - "harness/lib/*.sh"
  - "harness/tests/*.sh"
  - ".claude/commands/**/*.md"
  - ".claude/skills/**/*.md"
  - ".claude/rules/**/*.md"
  - ".cursor/commands/*.md"
  - ".cursor/skills/**/*.md"
  - ".codex/skills/**/*.md"
---

# Harness Workflow Layer

## Source Of Truth

- Treat `HARNESS.md`, `harness/bin/*`, `harness/workflows/*`, and `harness/skills/*` as the source of truth.
- Change the Harness layer first when workflow behavior or repository policy changes.
- Keep client adapters thin. They should point back to Harness instead of carrying their own full workflow copy.

## Adapter Boundaries

- `.claude/commands/*` and `.cursor/commands/*` are user-facing entrypoints.
- `.claude/skills/*`, `.cursor/skills/*`, and `.codex/skills/*` are focused adapters for reusable guidance.
- `.claude/rules/*` may add path-specific guidance, but they should reinforce the Harness layer rather than replace it.

## Extension Rules

- Add a new workflow by updating Harness first, then its client adapters, then the related tests.
- Prefer commands for entrypoints and skills for reusable focused guidance.
- Add subagents only when the workflow needs real delegation or isolation.
