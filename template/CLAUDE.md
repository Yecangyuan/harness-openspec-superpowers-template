@AGENTS.md

# Claude Code Instructions

Claude Code reads `CLAUDE.md`, not `AGENTS.md`, so this file imports the shared repository agent instructions and adds Claude-specific loading, settings, and adapter guidance.

## Workflow Entry

For repository work, use Harness before invoking OpenSpec or Superpowers directly:

1. Read `HARNESS.md`.
2. Run `./harness/bin/check`.
3. Run `./harness/bin/status` when change state matters.
4. Use `.claude/commands/opsx/*` or `./harness/bin/opsx <action>` to route workflow actions.

## Source Of Truth Layers

When repository workflow behavior changes, update these layers in order:

1. `HARNESS.md`
2. `harness/bin/*`
3. `harness/workflows/*`
4. `harness/skills/*`
5. Thin client adapters in `.claude/`, `.cursor/`, and `.codex/`

Do not maintain a second full workflow copy in the Claude adapters.

## Claude Loading Model

- `CLAUDE.md` is always loaded for this repository.
- `.claude/rules/*.md` files are path-scoped guidance. Keep them focused on the matching files instead of restating whole workflows.
- Personal overrides belong in `.claude/settings.local.json` and should stay uncommitted.

## Commands, Skills, And Agents

- `.claude/commands/opsx/*` are user-facing workflow entrypoints.
- `.claude/skills/*` are focused adapters for reusable guidance.
- Add subagents only when a workflow genuinely benefits from delegation or isolation. Do not add them by default.

If an adapter grows into long-form process documentation, move that content back into `HARNESS.md`, `harness/workflows/*`, or `harness/skills/*`.

## Claude Code Project Settings And Hooks

Project-level Claude Code shared settings live in `.claude/settings.json`.

- The shared baseline respects `.gitignore`.
- Plan documents are stored under `docs/superpowers/plans`.
- The Stop hook runs `.claude/hooks/workflow-reminder.sh`.

The Stop hook only emits workflow reminders; it does not write global `~/.claude` files and does not block shutdown.

## Skill Adapters

The `.claude/skills/*` entries are thin adapters. Treat `HARNESS.md`, `harness/workflows/*`, and `harness/skills/*` as the source of truth.
