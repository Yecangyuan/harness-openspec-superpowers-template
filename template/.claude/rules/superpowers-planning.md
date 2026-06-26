---
paths:
  - "docs/superpowers/specs/**/*.md"
  - "docs/superpowers/plans/**/*.md"
---

# Superpowers Planning Artifacts

## Roles

- Specs capture intent, scope, constraints, and acceptance criteria.
- Plans capture execution order, checkpoints, and verification steps.

## Expectations

- For behavior changes, write or update the spec before the plan.
- Keep plans checklist-oriented and implementation-facing.
- Include verification commands or observable checks for each meaningful milestone.
- Link a plan or spec to the relevant OpenSpec change when one exists.

## Boundaries

- Keep durable repository workflow policy in `HARNESS.md` and `harness/workflows/*`, not in individual spec or plan files.
- Remove stale `TODO`, `TBD`, and placeholder language before treating a spec or plan as ready to execute.
