# Harness OpenSpec Superpowers Template

[中文说明](README.zh-CN.md)

Reusable bootstrap template for the `Harness + OpenSpec + Superpowers` workflow.

## Is This Ready Out Of The Box?

The template files are ready to install into a git-backed project, but the workflow is not zero-dependency. `hosi` copies the Harness files into the target repository; it does not install global CLIs or editor applications.

Minimum required tools:

| Tool | Required | Purpose |
| --- | --- | --- |
| `bash` | Yes | Runs `hosi`, `install.sh`, and `harness/bin/*` |
| `git` | Yes | Supports status, diff, branch, and review workflows |
| Node.js `>= 20.19.0` plus `npm` | Yes | Required to install and run OpenSpec |
| `openspec` CLI | Yes | Powers `check`, `status`, `opsx`, and `verify` |
| Claude Code, Codex, or Cursor | Pick at least one | Reads the matching `.claude`, `.codex`, or `.cursor` adapter |
| Superpowers plugin | Recommended | Provides brainstorming, planning, TDD, and review discipline |
| `rtk` | Optional | Local command proxy; `harness/bin/check` only warns if missing |

Install OpenSpec:

```bash
npm install -g @fission-ai/openspec@latest
openspec -V
```

If you use Claude Code and want the full Superpowers workflow, install the plugin inside Claude Code:

```text
/plugin install superpowers@claude-plugins-official
```

For a new machine, the usual setup is:

```bash
# 1. Install Node.js >= 20.19.0

# 2. Install OpenSpec
npm install -g @fission-ai/openspec@latest

# 3. Install the AI client you use: Claude Code, Codex, Cursor, or more than one

# 4. Optional but recommended for Claude Code: install Superpowers
# /plugin install superpowers@claude-plugins-official
```

After those prerequisites are present, install the `hosi` command from this template checkout:

```bash
./hosi --install-system
```

Make sure `~/.local/bin` is on `PATH`, then install into a target project that already has a git repository:

```bash
cd /path/to/project
git init  # only if the project is not already a git repository
hosi . \
  --project-name "MyProject" \
  --tech-stack "Android Kotlin Gradle"
./harness/bin/check
./harness/bin/opsx verify
```

By default, `hosi` installs in local mode and adds the installed workflow files to `.gitignore`. Use `hosi . --shared` only when you intentionally want the workflow files to be committed and shared with the team.

## Upgrade An Installed Project

When this template repository changes, projects that already installed it do not update automatically. Use `--upgrade` after updating the template checkout:

```bash
cd /path/to/project
hosi . --upgrade
```

Upgrade behavior:

- Adds new managed Harness files that are missing from the target project.
- Updates managed files that still match the previously installed template version.
- Keeps locally modified managed files unchanged and writes copies under `.harness-template-backups/<timestamp>/`.
- Writes `.harness-template-version` with the template commit, install mode, install time, project metadata, and managed file hashes.

After upgrading:

```bash
cd /path/to/project
git status --ignored
./harness/bin/check
./harness/bin/opsx verify
```

Review any backups before deleting them. If you intentionally want to replace local Harness edits, use `--force` instead of `--upgrade`.

## What This Installs

- `harness/bin/*`: repository workflow commands
- `harness/workflows/*`: shared workflow documentation
- `harness/skills/*`: project-local multi-review, knowledge, and tech-proposal workflows
- `openspec/config.yaml`: project-local OpenSpec configuration
- `.codex/`, `.claude/`, `.cursor/`: thin agent/client adapters
- `.claude/settings.json`, `.claude/hooks/*`, and `.claude/rules/*`: project-level Claude Code shared settings, workflow reminders, and path-scoped guidance
- `docs/superpowers/specs` and `docs/superpowers/plans`: planning document homes
- `AGENTS.md`, `CLAUDE.md`, and `HARNESS.md`: repository entry instructions
- `.harness-template-version`: installed template metadata, install mode, and managed file hashes

Default local installs add these files to `.gitignore`. Shared installs use `--shared` and leave the workflow files available for normal git tracking.

## Install Into A Project

```bash
cd /path/to/project
hosi . \
  --project-name "MyProject" \
  --tech-stack "Android Kotlin Gradle"
```

Use `--force` only when intentionally replacing an existing Harness/OpenSpec workflow. `install.sh --target <project-dir>` remains available for compatibility, but `hosi` is the preferred entrypoint.

## Verify This Template

```bash
bash tests/test_install.sh
```

## Verify An Installed Project

```bash
cd /path/to/project
./harness/bin/check
./harness/bin/opsx verify
```

## Notes

This repository is a template. Generated OpenSpec changes, archived changes, and project-specific specs belong in each target project, not in this template repository.
