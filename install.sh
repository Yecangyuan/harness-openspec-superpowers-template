#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$ROOT_DIR/template"
SNIPPET_FILE="$ROOT_DIR/assets/gitignore-snippet"

target_dir=""
project_name=""
tech_stack="Project-specific stack"
force=0

usage() {
  cat <<'EOF'
Usage: ./install.sh --target <project-dir> [options]

Options:
  --project-name <name>   Project name used in generated agent instructions
  --tech-stack <text>     Tech stack summary for openspec/config.yaml
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

if [[ "$force" -ne 1 ]]; then
  for path in HARNESS.md AGENTS.md harness openspec/config.yaml .codex/skills/harness; do
    if [[ -e "$target_dir/$path" ]]; then
      echo "Refusing to overwrite existing $path; rerun with --force if intended." >&2
      exit 1
    fi
  done
fi

if command -v rsync >/dev/null 2>&1; then
  rsync -a "$TEMPLATE_DIR"/ "$target_dir"/
else
  cp -R "$TEMPLATE_DIR"/. "$target_dir"/
fi

escape_sed_replacement() {
  printf '%s' "$1" | sed 's/[\/&]/\\&/g'
}

project_escaped="$(escape_sed_replacement "$project_name")"
stack_escaped="$(escape_sed_replacement "$tech_stack")"

while IFS= read -r -d '' file; do
  tmp_file="$file.tmp.$$"
  sed \
    -e "s/{{PROJECT_NAME}}/$project_escaped/g" \
    -e "s/{{TECH_STACK}}/$stack_escaped/g" \
    "$file" > "$tmp_file"
  if cmp -s "$file" "$tmp_file"; then
    rm -f "$tmp_file"
  else
    mv "$tmp_file" "$file"
  fi
done < <(find "$target_dir" -type f ! -path '*/.git/*' -print0)

chmod +x "$target_dir"/harness/bin/* 2>/dev/null || true

gitignore_path="$target_dir/.gitignore"
if [[ ! -f "$gitignore_path" ]]; then
  touch "$gitignore_path"
fi

if ! grep -Fq "Harness/OpenSpec/Superpowers workflow files" "$gitignore_path"; then
  cat "$SNIPPET_FILE" >> "$gitignore_path"
fi

echo "Installed Harness + OpenSpec + Superpowers workflow into $target_dir"
echo "Next: cd \"$target_dir\" && ./harness/bin/check"
