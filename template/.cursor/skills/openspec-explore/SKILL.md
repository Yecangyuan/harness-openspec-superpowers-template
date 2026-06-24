---
name: openspec-explore
description: Thin Harness adapter for exploring OpenSpec state.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: harness
  version: "1.0"
---

This skill is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/explore.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/explore.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx explore`

Do not treat this file as the workflow source of truth. Follow the matching `openspec` commands from `harness/workflows/explore.md`.
