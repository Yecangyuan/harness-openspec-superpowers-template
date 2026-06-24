# Tech-Proposal Workflow

Use this workflow after an OpenSpec proposal exists and a team-reviewable design document is useful.

## Inputs

- `openspec/changes/<change-name>/proposal.md`
- `openspec/changes/<change-name>/design.md`, when present
- `openspec/changes/<change-name>/tasks.md`
- `openspec/changes/<change-name>/specs/**`

## Steps

1. Read `harness/skills/tech-proposal/SKILL.md`.
2. Resolve the active change name.
3. Read the current OpenSpec artifacts for that change.
4. Create or update `openspec/changes/<change-name>/tech-proposal.md`.
5. Preserve existing review notes and signoff state during updates.

## Output

A concrete proposal covering background, architecture, risks, open questions, milestones, and review signoff.
