---
name: harness
description: Use first for any {{PROJECT_NAME}} repository work: new features, bug fixes, refactors, reviews, OpenSpec changes, Superpowers planning/execution, or workflow/status questions. This skill makes Harness the repo-local entrypoint before using OpenSpec or Superpowers directly.
license: MIT
metadata:
  author: harness
  version: "1.0"
---

# {{PROJECT_NAME}} Harness Entry

This repository uses a three-layer workflow:

1. `Harness` is the repo-local entrypoint and orchestrator.
2. `OpenSpec` owns change state, artifacts, instructions, validation, and archive.
3. `Superpowers` owns design discipline, TDD, tactical plans, reviews, and execution habits.

## Required First Steps

Before choosing OpenSpec or Superpowers directly for repository work:

1. Read `HARNESS.md`.
2. Run `./harness/bin/check`.
3. Run `./harness/bin/status` when the current change state matters.
4. Use `./harness/bin/opsx <action>` to route the work.

Use these actions:

- `./harness/bin/opsx explore [change-name]` for investigation and status.
- `./harness/bin/opsx propose <change-name>` for new scoped changes.
- `./harness/bin/opsx apply [change-name]` for implementation context.
- `./harness/bin/opsx sync [change-name]` for spec-sync context.
- `./harness/bin/opsx archive [change-name] [flags]` for completed changes.
- `./harness/bin/opsx verify` for workflow verification before completion.

## Skill Disambiguation

- Do not jump directly from a new feature request into Superpowers `writing-plans`.
- For feature work, first use Harness to decide whether the next action is `explore` or `propose`.
- Use Superpowers after Harness has selected the phase and after OpenSpec artifacts exist or the user explicitly asks for a direct small edit.
- The `.codex/skills/openspec-*` files are thin adapters. They are not the workflow source of truth.
- The workflow source of truth is `HARNESS.md`, `harness/bin/*`, and `harness/workflows/*.md`.

## Important Boundary

Codex global skills may still load before this repository skill. That is acceptable. Once repo work begins, this Harness skill governs the local workflow choice.
