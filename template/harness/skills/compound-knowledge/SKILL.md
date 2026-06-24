---
name: compound-knowledge
description: Capture useful project learnings in knowledge/index.md and one topic file. Use after complex fixes, significant features, architectural decisions, or when the user asks to document learnings.
---

# Compound Knowledge

Preserve reusable project knowledge while the context is fresh. Keep the index lightweight and load detailed entries only when relevant.

## When To Use

- After fixing a complex bug
- After completing a significant feature
- After making or reversing an architectural decision
- After discovering a project-specific pattern or anti-pattern
- When the user asks to "document learnings", "compound knowledge", or "沉淀知识"

## Directory Structure

```text
knowledge/
  index.md
  patterns/
  anti-patterns/
  decisions/
  subsystem-specs/
```

`knowledge/index.md` is the only file that should be read by default. It contains one-line summaries that point to detailed files.

## Process

1. Extract the solved problem, failed attempts, final solution, and prevention rule from the current context.
2. Classify the entry as `patterns`, `anti-patterns`, `decisions`, or `subsystem-specs`.
3. Create one kebab-case Markdown file for the topic.
4. Update `knowledge/index.md` with one concise link line.
5. Check whether the new entry contradicts older index entries and update stale lines.
6. If project instructions do not mention `knowledge/index.md`, suggest adding that note.

## Entry Template

```markdown
# Title

Date: YYYY-MM-DD
Type: pattern | anti-pattern | decision | subsystem-spec
Tags: tag-one, tag-two

## Context

What situation produced this learning.

## Learning

The reusable rule, decision, or implementation pattern.

## Why It Works

The technical reason this prevents future work or avoids failure.

## Apply When

Concrete signals that this entry is relevant.

## Avoid When

Limits, tradeoffs, or cases where this does not apply.
```

## Index Rules

- One entry per line
- Keep summaries under 80 characters
- Keep the full index under 50 entries when practical
- Prefer specific links over broad prose
- Do not load every file in `knowledge/`; use the index to choose
