---
name: /opsx-explore
id: opsx-explore
category: Workflow
description: Thin Harness adapter for exploring OpenSpec state
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/explore.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/explore.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx explore`

Do not maintain a second copy of the workflow here. Follow the matching `openspec` commands from `harness/workflows/explore.md`.
