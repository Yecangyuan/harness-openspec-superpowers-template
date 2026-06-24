# Repository Agent Instructions

## Workflow Entry

For this repository, use Harness as the local workflow entrypoint before invoking OpenSpec or Superpowers directly.

Required sequence for repository work:

1. Read `HARNESS.md`.
2. Run `./harness/bin/check`.
3. Run `./harness/bin/status` when change state matters.
4. Use `./harness/bin/opsx <action>` to route the work.

The Harness actions are:

- `explore [change-name]`
- `propose <change-name>`
- `apply [change-name]`
- `sync [change-name]`
- `archive [change-name] [flags]`
- `verify`
- `multi-review` skill for completed feature modules
- `compound-knowledge` skill for durable project learnings
- `tech-proposal` skill for team-reviewable OpenSpec designs

## Tool Roles

- Harness is the repository entrypoint and orchestration layer.
- OpenSpec owns change state, artifacts, instructions, validation, and archive.
- Superpowers owns design discipline, TDD, implementation planning, execution, and reviews.

## Skill Priority

For new feature work, do not go directly from brainstorming to Superpowers `writing-plans`. First route through Harness and create or inspect the OpenSpec change when appropriate.

The `.codex/skills/openspec-*` files are thin adapters. Treat `HARNESS.md`, `harness/bin/*`, and `harness/workflows/*.md` as the source of truth.

The `.codex/skills/multi-review`, `.codex/skills/compound-knowledge`, and `.codex/skills/tech-proposal` entries are also thin adapters. Treat `harness/skills/*` as the source of truth for those workflows.
