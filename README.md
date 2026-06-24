# Harness OpenSpec Superpowers Template

[中文说明](README.zh-CN.md)

Reusable bootstrap template for the `Harness + OpenSpec + Superpowers` workflow.

## Is This Ready Out Of The Box?

The template files are ready to install into a project, but the workflow is not zero-dependency. `install.sh` copies the Harness files into the target repository; it does not install global CLIs or editor applications.

Minimum required tools:

| Tool | Required | Purpose |
| --- | --- | --- |
| `bash` | Yes | Runs `install.sh` and `harness/bin/*` |
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

After those prerequisites are present, install this template into a target project and verify it:

```bash
./install.sh \
  --target /path/to/project \
  --project-name "MyProject" \
  --tech-stack "Android Kotlin Gradle"

cd /path/to/project
./harness/bin/check
./harness/bin/opsx verify
```

## What This Installs

- `harness/bin/*`: repository workflow commands
- `harness/workflows/*`: shared workflow documentation
- `harness/skills/*`: project-local multi-review, knowledge, and tech-proposal workflows
- `openspec/config.yaml`: project-local OpenSpec configuration
- `.codex/`, `.claude/`, `.cursor/`: thin agent/client adapters
- `.claude/settings.json` and `.claude/hooks/*`: project-level Claude Code workflow reminders
- `docs/superpowers/specs` and `docs/superpowers/plans`: planning document homes
- `AGENTS.md` and `HARNESS.md`: repository entry instructions

## Install Into A Project

```bash
./install.sh \
  --target /path/to/project \
  --project-name "MyProject" \
  --tech-stack "Android Kotlin Gradle"
```

Use `--force` only when intentionally replacing an existing Harness/OpenSpec workflow.

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
