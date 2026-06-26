---
paths:
  - "**/*.md"
---

# Markdown Docs

## Documentation Standards

- Keep each file focused on one responsibility.
- Prefer short sections, concrete bullets, and runnable examples over long narrative.
- Use relative links for repository-local references.

## Workflow Documentation

- For workflow docs, include preconditions, real commands, and failure handling.
- If a document describes generated OpenSpec state, prefer pointing readers to the relevant CLI command instead of pasting stale snapshots.
- Do not duplicate long-form workflow instructions in thin client adapters when the Harness layer already owns that material.
