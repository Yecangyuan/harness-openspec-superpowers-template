---
name: tech-proposal
description: Generate a team-reviewable technical proposal from OpenSpec artifacts. Use after an OpenSpec proposal exists and before implementation when cross-team review is useful.
---

# Tech Proposal

Create or update `openspec/changes/<change-name>/tech-proposal.md` from the active OpenSpec change.

## When To Use

- After `./harness/bin/opsx propose <change-name>` creates an OpenSpec change
- Before implementation, when a formal technical design is useful
- When multiple reviewers, teams, or clients need a concrete design artifact

Skip this for small local changes where the OpenSpec proposal and tasks are enough.

## Inputs

Read these files for the selected change:

- `openspec/changes/<change-name>/proposal.md`
- `openspec/changes/<change-name>/design.md`, when present
- `openspec/changes/<change-name>/tasks.md`
- `openspec/changes/<change-name>/specs/**`

If multiple active changes exist, ask for the change name.

## Output

Write:

```text
openspec/changes/<change-name>/tech-proposal.md
```

## Document Structure

Adapt sections to the change, but keep Background, Architecture, Risks, and Open Questions.

```markdown
# Technical Proposal: <change-name>

## 1. Background And Goals

## 2. Non-Goals

## 3. Architecture Overview

## 4. Core Feature Design

## 5. API Design

## 6. Data And Migration Design

## 7. Rollout And Compatibility

## 8. Risks And Mitigations

## 9. Open Questions

## 10. Milestones

## 11. Review Signoff
```

Remove irrelevant subsections, but do not leave placeholders. Mark true unknowns as open questions with an owner or next action.

## Update Mode

If `tech-proposal.md` already exists:

1. Compare it against current OpenSpec artifacts.
2. Preserve reviewer notes and signoff status unless contradicted.
3. Add a short update note near the top.
4. Modify only changed sections.
