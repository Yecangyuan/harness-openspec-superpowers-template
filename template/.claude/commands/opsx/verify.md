---
name: "OPSX: Verify"
description: Thin Harness adapter for running repository workflow verification
category: Workflow
tags: [workflow, harness, openspec]
---

This command is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/verify.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/verify.md`
4. Use `./harness/bin/opsx verify` for the current repo state

Do not maintain a second copy of the workflow here. Follow the matching commands from `harness/workflows/verify.md`.
