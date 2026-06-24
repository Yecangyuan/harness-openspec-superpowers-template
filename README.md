# Harness OpenSpec Superpowers Template

Reusable bootstrap template for the `Harness + OpenSpec + Superpowers` workflow.

## What This Installs

- `harness/bin/*`: repository workflow commands
- `harness/workflows/*`: shared workflow documentation
- `openspec/config.yaml`: project-local OpenSpec configuration
- `.codex/`, `.claude/`, `.cursor/`: thin agent/client adapters
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
