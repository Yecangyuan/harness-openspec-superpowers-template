# Multi-Review Workflow

Use this workflow after a feature module is complete or before opening a PR.

## Inputs

- User request or OpenSpec change context
- Diff against the intended base branch
- Relevant `knowledge/index.md` entries, when present

## Steps

1. Read `harness/skills/multi-review/SKILL.md`.
2. Identify the base branch and changed files.
3. Summarize the intent in 2-3 lines.
4. Select reviewer personas from `harness/skills/multi-review/references/`.
5. Run selected reviewers in parallel when the client supports it, otherwise sequentially.
6. Merge findings by severity, confidence, and duplicate fingerprint.
7. Fix P0/P1 findings before claiming the work is ready.

## Output

Findings first, then open questions, testing gaps, and a merge readiness verdict.
