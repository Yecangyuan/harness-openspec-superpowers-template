@AGENTS.md

# Claude Code Instructions

Claude Code reads `CLAUDE.md`, not `AGENTS.md`, so this file imports the shared repository agent instructions and adds Claude-specific entry points.

## Workflow Entry

For repository work, use Harness before invoking OpenSpec or Superpowers directly:

1. Read `HARNESS.md`.
2. Run `./harness/bin/check`.
3. Run `./harness/bin/status` when change state matters.
4. Use `.claude/commands/opsx/*` or `./harness/bin/opsx <action>` to route workflow actions.

## Claude Code Project Hooks

Project-level Claude Code hooks live in `.claude/settings.json`.

The Stop hook runs `.claude/hooks/workflow-reminder.sh`. It only emits workflow reminders; it does not write global `~/.claude` files and does not block shutdown.

## Skill Adapters

The `.claude/skills/*` entries are thin adapters. Treat `HARNESS.md`, `harness/workflows/*`, and `harness/skills/*` as the source of truth.
