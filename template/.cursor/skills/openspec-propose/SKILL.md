---
name: openspec-propose
description: Thin Harness adapter for creating an OpenSpec change.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: harness
  version: "1.0"
---

This skill is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/propose.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/propose.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx propose`

Do not treat this file as the workflow source of truth. Follow the matching `openspec` commands from `harness/workflows/propose.md`.
