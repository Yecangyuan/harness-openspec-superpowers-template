---
name: "OPSX: Explore"
description: Thin Harness adapter for exploring OpenSpec state without implementing
category: Workflow
tags: [workflow, harness, openspec]
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/explore.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/explore.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx explore` for the current repo state

Do not maintain a second copy of the workflow here. Follow the matching `openspec` commands from `harness/workflows/explore.md`.
