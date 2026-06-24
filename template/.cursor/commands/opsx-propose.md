---
name: /opsx-propose
id: opsx-propose
category: Workflow
description: Thin Harness adapter for creating an OpenSpec change
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/propose.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/propose.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx propose`

Do not maintain a second copy of the workflow here. Follow the matching `openspec` commands from `harness/workflows/propose.md`.
