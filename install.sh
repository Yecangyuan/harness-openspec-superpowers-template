#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$ROOT_DIR/template"
SNIPPET_FILE="$ROOT_DIR/assets/gitignore-snippet"

target_dir=""
project_name=""
tech_stack="Project-specific stack"
force=0
upgrade=0

usage() {
  cat <<'EOF'
Usage: ./install.sh --target <project-dir> [options]

Options:
  --project-name <name>   Project name used in generated agent instructions
  --tech-stack <text>     Tech stack summary for openspec/config.yaml
  --upgrade               Update managed Harness files; back up local modifications
  --force                 Overwrite existing Harness/OpenSpec workflow files
  -h, --help              Show this help
EOF
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --target)
      target_dir="${2:-}"
      shift 2
      ;;
    --project-name)
      project_name="${2:-}"
      shift 2
      ;;
    --tech-stack)
      tech_stack="${2:-}"
      shift 2
      ;;
    --force)
      force=1
      shift
      ;;
    --upgrade)
      upgrade=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$target_dir" ]]; then
  echo "Missing required --target <project-dir>" >&2
  usage >&2
  exit 1
fi

mkdir -p "$target_dir"
target_dir="$(cd "$target_dir" && pwd)"

if [[ -z "$project_name" ]]; then
  project_name="$(basename "$target_dir")"
fi

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

project_escaped="$(escape_sed_replacement "$project_name")"
stack_escaped="$(escape_sed_replacement "$tech_stack")"

render_template_file() {
  local source_file="$1"
  local output_file="$2"
  mkdir -p "$(dirname "$output_file")"
  sed \
    -e "s/{{PROJECT_NAME}}/$project_escaped/g" \
    -e "s/{{TECH_STACK}}/$stack_escaped/g" \
    "$source_file" > "$output_file"
}

file_hash() {
  LC_ALL=C shasum -a 256 "$1" | awk '{print $1}'
}

template_commit() {
  git -C "$ROOT_DIR" rev-parse --short HEAD 2>/dev/null || printf 'unknown'
}

manifest_path() {
  printf '%s/.harness-template-version\n' "$target_dir"
}

manifest_hash_for() {
  local rel_path="$1"
  local manifest_file
  manifest_file="$(manifest_path)"

  if [[ ! -f "$manifest_file" ]]; then
    return 0
  fi

  awk -v path="$rel_path" '
    $1 == "files:" { in_files = 1; next }
    in_files && $2 == path { print $1; exit }
  ' "$manifest_file"
}

write_manifest() {
  local hashes_file="$1"
  local manifest_file
  manifest_file="$(manifest_path)"

  {
    printf 'template_commit: %s\n' "$(template_commit)"
    printf 'installed_at: %s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    printf 'project_name: %s\n' "$project_name"
    printf 'tech_stack: %s\n' "$tech_stack"
    printf 'files:\n'
    sort -k2 "$hashes_file"
  } > "$manifest_file"
}

chmod_installed_tools() {
  chmod +x "$target_dir"/harness/bin/* 2>/dev/null || true
  chmod +x "$target_dir"/.claude/hooks/* 2>/dev/null || true
}

ensure_gitignore_snippet() {
  local gitignore_path="$target_dir/.gitignore"
  if [[ ! -f "$gitignore_path" ]]; then
    touch "$gitignore_path"
  fi

  if ! grep -Fq "Harness/OpenSpec/Superpowers workflow files" "$gitignore_path"; then
    cat "$SNIPPET_FILE" >> "$gitignore_path"
  fi
}

render_all_template_files() {
  local hashes_file="$1"
  local source_file rel_path target_file

  while IFS= read -r -d '' source_file; do
    rel_path="${source_file#"$TEMPLATE_DIR"/}"
    target_file="$target_dir/$rel_path"
    render_template_file "$source_file" "$target_file"
    printf '%s %s\n' "$(file_hash "$target_file")" "$rel_path" >> "$hashes_file"
  done < <(find "$TEMPLATE_DIR" -type f -print0)
}

upgrade_template_files() {
  local backup_root hashes_file source_file rel_path target_file tmp_file
  local previous_hash current_hash new_hash
  local updated=0 added=0 skipped=0

  backup_root="$target_dir/.harness-template-backups/$(date -u '+%Y%m%dT%H%M%SZ')"
  hashes_file="$(mktemp "${TMPDIR:-/tmp}/harness-template-hashes.XXXXXX")"
  tmp_file="$(mktemp "${TMPDIR:-/tmp}/harness-template-render.XXXXXX")"
  trap 'rm -f "$hashes_file" "$tmp_file"' RETURN

  while IFS= read -r -d '' source_file; do
    rel_path="${source_file#"$TEMPLATE_DIR"/}"
    target_file="$target_dir/$rel_path"
    render_template_file "$source_file" "$tmp_file"
    new_hash="$(file_hash "$tmp_file")"

    if [[ ! -e "$target_file" ]]; then
      mkdir -p "$(dirname "$target_file")"
      cp "$tmp_file" "$target_file"
      printf '%s %s\n' "$new_hash" "$rel_path" >> "$hashes_file"
      added=$((added + 1))
      continue
    fi

    previous_hash="$(manifest_hash_for "$rel_path")"
    current_hash="$(file_hash "$target_file")"

    if [[ -n "$previous_hash" && "$current_hash" != "$previous_hash" ]]; then
      mkdir -p "$backup_root/$(dirname "$rel_path")"
      cp "$target_file" "$backup_root/$rel_path"
      printf '%s %s\n' "$previous_hash" "$rel_path" >> "$hashes_file"
      skipped=$((skipped + 1))
      continue
    fi

    if [[ -z "$previous_hash" && "$current_hash" != "$new_hash" ]]; then
      mkdir -p "$backup_root/$(dirname "$rel_path")"
      cp "$target_file" "$backup_root/$rel_path"
    fi

    cp "$tmp_file" "$target_file"
    printf '%s %s\n' "$new_hash" "$rel_path" >> "$hashes_file"
    updated=$((updated + 1))
  done < <(find "$TEMPLATE_DIR" -type f -print0)

  write_manifest "$hashes_file"
  chmod_installed_tools
  ensure_gitignore_snippet

  printf 'Upgraded Harness + OpenSpec + Superpowers workflow in %s\n' "$target_dir"
  printf 'Summary: %s added, %s updated, %s local modification(s) kept with backups.\n' "$added" "$updated" "$skipped"
  if [[ -d "$backup_root" ]]; then
    printf 'Backups: %s\n' "$backup_root"
  fi
  printf 'Next: cd "%s" && ./harness/bin/check\n' "$target_dir"
}

if [[ "$upgrade" -eq 1 ]]; then
  upgrade_template_files
  exit 0
fi

if [[ "$force" -ne 1 ]]; then
  for path in \
    HARNESS.md \
    AGENTS.md \
    CLAUDE.md \
    harness \
    openspec/config.yaml \
    .claude/settings.json \
    .claude/rules \
    .claude/hooks/workflow-reminder.sh \
    .claude/skills/multi-review \
    .claude/skills/compound-knowledge \
    .claude/skills/tech-proposal \
    .codex/skills/harness \
    .codex/skills/multi-review \
    .codex/skills/compound-knowledge \
    .codex/skills/tech-proposal \
    .cursor/skills/multi-review \
    .cursor/skills/compound-knowledge \
    .cursor/skills/tech-proposal
  do
    if [[ -e "$target_dir/$path" ]]; then
      echo "Refusing to overwrite existing $path; rerun with --force if intended." >&2
      exit 1
    fi
  done
fi

hashes_file="$(mktemp "${TMPDIR:-/tmp}/harness-template-hashes.XXXXXX")"
trap 'rm -f "$hashes_file"' EXIT

if command -v rsync >/dev/null 2>&1; then
  rsync -a "$TEMPLATE_DIR"/ "$target_dir"/
else
  cp -R "$TEMPLATE_DIR"/. "$target_dir"/
fi

render_all_template_files "$hashes_file"
write_manifest "$hashes_file"
chmod_installed_tools
ensure_gitignore_snippet

echo "Installed Harness + OpenSpec + Superpowers workflow into $target_dir"
echo "Next: cd \"$target_dir\" && ./harness/bin/check"
