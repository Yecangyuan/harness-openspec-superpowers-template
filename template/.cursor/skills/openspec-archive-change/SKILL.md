---
name: openspec-archive-change
description: Thin Harness adapter for archiving an OpenSpec change.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: harness
  version: "1.0"
---

This skill is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/archive.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/archive.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx archive`

Do not treat this file as the workflow source of truth. Follow the matching `openspec` commands from `harness/workflows/archive.md`.
