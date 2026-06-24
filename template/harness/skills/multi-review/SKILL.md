---
name: multi-review
description: Multi-persona code review using selected reviewer personas. Use after completing a feature module, before creating a PR, or when the user asks for a comprehensive review.
---

# Multi-Persona Code Review

Run a cross-cutting review of the current change by selecting reviewer personas, collecting findings, and merging them into one actionable report.

## When To Use

- After a feature module or significant code change is complete
- Before creating a PR
- When asked for "full review", "comprehensive review", "multi-review", or similar
- After tactical implementation reviews, when a wider architecture and risk pass is needed

## Stage 1: Determine Scope

Use the nearest reliable base branch:

```bash
BASE=$(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo HEAD~10)
git diff --name-only "$BASE"
git diff -U10 "$BASE"
```

If the repository does not have `main` or `origin/main`, use the user's stated base or the smallest relevant local diff.

## Stage 2: Discover Intent

Write a 2-3 line intent summary from:

- User request
- Branch name
- Recent commits
- OpenSpec proposal or task files, when present

If `knowledge/index.md` exists, read it first and load only entries relevant to the touched files or domain.

## Stage 3: Select Reviewers

Always include:

- `correctness-reviewer`
- `testing-reviewer`

Add conditional reviewers:

| Reviewer | Use when the diff touches |
| --- | --- |
| `security-reviewer` | auth, public endpoints, user input, permissions, secrets |
| `performance-reviewer` | database queries, loops over large data, caching, network or filesystem I/O |
| `adversarial-reviewer` | 50+ changed lines, data mutation, external APIs, concurrency, payments, auth |
| `architecture-strategist` | new services, boundaries, shared abstractions, structural refactors |

## Stage 4: Review

If parallel subagents are available, dispatch selected reviewers concurrently. Otherwise, run them sequentially.

Each reviewer receives:

- The intent summary
- The changed file list
- The relevant diff
- Its persona file from `harness/skills/multi-review/references/`
- Any relevant knowledge entries

## Stage 5: Merge Findings

1. Drop malformed or non-actionable findings.
2. Suppress findings with confidence below `0.60`, except P0 issues at `0.50+`.
3. Deduplicate by file, nearby line, and normalized title.
4. Increase confidence by `0.10` when multiple reviewers identify the same issue.
5. Sort by severity, then confidence, then file path.

## Output Format

Return findings first, ordered by severity:

```markdown
## Findings

- P1 file/path.ext:123 - Short title
  Evidence, impact, and suggested fix.

## Open Questions

## Testing Gaps

## Verdict
Ready to merge / Ready with fixes / Not ready
```

If no issues are found, say so clearly and list remaining test gaps or residual risks.
