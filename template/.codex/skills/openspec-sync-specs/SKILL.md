---
name: openspec-sync-specs
description: Thin Harness adapter for syncing OpenSpec deltas into main specs.
license: MIT
compatibility: Requires openspec CLI.
metadata:
  author: harness
  version: "1.0"
---

This skill is a thin Harness adapter.

Repo-level workflow truth lives in:

- `HARNESS.md`
- `harness/workflows/sync.md`

Before acting:

1. Read `HARNESS.md`
2. Run `./harness/bin/check`
3. Read `harness/workflows/sync.md`
4. Use `./harness/bin/status` or `./harness/bin/opsx sync`

Do not treat this file as the workflow source of truth. Follow the matching `openspec` commands from `harness/workflows/sync.md`.
