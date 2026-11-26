---
name: "OPSX: Verify"
description: Verify the repository workflow or assess an OpenSpec change for archive
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
4. Run `./harness/bin/opsx verify` for the repository or follow the change verification steps when a change is named

Do not maintain a second copy of the workflow here. Follow the matching commands from `harness/workflows/verify.md`.
