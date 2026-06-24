---
name: /opsx-sync
id: opsx-sync
category: Workflow
description: Thin Harness adapter for syncing OpenSpec deltas into main specs
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/sync.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/sync.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx sync`

Do not maintain a second copy of the workflow here. Follow the matching `openspec` commands from `harness/workflows/sync.md`.
