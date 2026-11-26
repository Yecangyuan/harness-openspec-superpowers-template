# Harness OpenSpec Superpowers Template

[中文说明](README.zh-CN.md)

Reusable bootstrap template for the `Harness + OpenSpec + Superpowers` workflow.

## Install With One Command

Paste this command in the target Git project. On first use, the installer downloads the template.

```bash
hosi_setup="$(curl -fsSL https://raw.githubusercontent.com/Yecangyuan/harness-openspec-superpowers-template/main/bootstrap.sh)" && bash -c "$hosi_setup" -- .
```

This installs and registers the current project, then links `hosi` into `~/.local/bin`. Local mode adds the workflow files to `.gitignore`. Append `--shared` to make them available for the team to commit.

The checkout defaults to `~/.local/share/hosi/template`, or `$XDG_DATA_HOME/hosi/template` when set. Set `HOSI_TEMPLATE_DIR` to choose another location.

If you already cloned the template, run its local installer from the target project.

```bash
"/path/to/template/hosi" . --install-system
```

## Is This Ready Out Of The Box?

`hosi` copies the workflow files into a Git project. To run the workflow, install OpenSpec and at least one supported client.

Minimum required tools:

| Tool | Required | Purpose |
| --- | --- | --- |
| `bash` | Yes | Runs `hosi`, `install.sh`, and `harness/bin/*` |
| `git` | Yes | Supports status, diff, branch, and review workflows |
| `curl` | GitHub install only | Downloads the one-command installer |
| Node.js `>= 22.20.0` plus `npm` | Yes | Required by the recommended OpenSpec 2.2.0 |
| `openspec` CLI | Yes | Powers `check`, `status`, `opsx`, and `verify` |
| Claude Code, Codex, or Cursor | Pick at least one | Reads the matching `.claude`, `.codex`, or `.cursor` adapter |
| Superpowers plugin | Recommended | Provides brainstorming, planning, TDD, and review discipline |
| `rtk` | Optional | Local command proxy; `harness/bin/check` only warns if missing |

Install OpenSpec:

```bash
npm install -g @fission-ai/openspec@2.2.0
openspec -V
```

If you use Claude Code and want the full Superpowers workflow, install the plugin inside Claude Code:

```text
/plugin install superpowers@claude-plugins-official
```

For a new machine, the usual setup is:

```bash
# 1. Install Node.js >= 22.20.0

# 2. Install OpenSpec
npm install -g @fission-ai/openspec@2.2.0

# 3. Install the AI client you use: Claude Code, Codex, Cursor, or more than one

# 4. Optional but recommended for Claude Code: install Superpowers
# /plugin install superpowers@claude-plugins-official
```

### Check the `hosi` Command

```bash
command -v hosi
hosi --help
```

The installer links `~/.local/bin/hosi` to this checkout. If you move the checkout or the link points to an old location, rerun `./hosi --install-system` from the current checkout.

If zsh still cannot find `hosi`, add `~/.local/bin` to `PATH` in `~/.zshrc` and open a new terminal.

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Upgrade An Installed Project

After updating the template checkout, upgrade a single project by passing its path from any directory.

```bash
hosi "/path/to/project" --upgrade
```

Upgrade behavior:

- Reuses the recorded project name, tech stack, and install mode when those options are omitted. Older manifests without an install mode are treated as shared installs.
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

### Upgrade Registered Projects Together

Successful installs and upgrades through `hosi` record the project path for the current user. After updating the template checkout, run the bulk upgrade from any directory.

```bash
hosi --upgrade-all
```

For a template downloaded by the one-command installer, update the default checkout with `git -C "$HOME/.local/share/hosi/template" pull --ff-only` first.

Register an older installation once to include it in future bulk upgrades. Registration updates the local registry.

```bash
hosi "/path/to/project" --register
```

Registration uses the project's `.harness-template-version`. For an installation that predates the manifest, `--upgrade` creates it and backs up differing files before replacing them when an earlier hash is unavailable.

View the project links with `ls -l ~/.local/state/hosi/projects/`. If `XDG_STATE_HOME` is set, the state directory is `$XDG_STATE_HOME/hosi`. Set `HOSI_STATE_DIR` to override it. When a project moves, register its new location.

Bulk upgrades preserve each project's install mode, metadata, and local modifications using the normal upgrade behavior. The command skips unavailable paths and missing manifests, attempts the remaining projects, and returns a nonzero exit status if any upgrade fails.

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

## Set the Project Name and Tech Stack

```bash
hosi "/path/to/project" --project-name "MyProject" --tech-stack "Android Kotlin Gradle"
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

Before implementing a complex change, run `./harness/bin/opsx review-spec <name>` to check the OpenSpec artifacts. Follow the [specification review workflow](template/harness/workflows/review-spec.md) to check acceptance scenarios, design decisions, and task coverage.

Before archiving a change, run `./harness/bin/opsx verify --change <name>` to see its tasks, scenario evidence, and archive readiness. The [change verification workflow](template/harness/workflows/verify.md#change-verification) shows how to attach observed test results.

This repository is a template. Generated OpenSpec changes, archived changes, and project-specific specs belong in each target project, not in this template repository.
