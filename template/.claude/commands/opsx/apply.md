---
name: "OPSX: Apply"
description: Thin Harness adapter for applying an OpenSpec change
category: Workflow
tags: [workflow, harness, openspec]
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/apply.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/apply.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx apply` for the current repo state

Do not maintain a second copy of the workflow here. Follow the matching `openspec` commands from `harness/workflows/apply.md`.
