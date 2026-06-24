---
name: /opsx-archive
id: opsx-archive
category: Workflow
description: Thin Harness adapter for archiving an OpenSpec change
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/archive.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/archive.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx archive`

Do not maintain a second copy of the workflow here. Follow the matching `openspec` commands from `harness/workflows/archive.md`.
