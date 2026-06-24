#!/usr/bin/env bash
set -euo pipefail

project_dir="${CLAUDE_PROJECT_DIR:-$(pwd)}"

if [[ ! -d "$project_dir" ]]; then
  exit 0
fi

cd "$project_dir" 2>/dev/null || exit 0

reminders=()

if [[ -d "openspec/changes" ]]; then
  while IFS= read -r -d '' tasks_file; do
    change_dir="$(dirname "$tasks_file")"
    change_name="$(basename "$change_dir")"

    case "$change_dir" in
      */archive/*)
        continue
        ;;
    esac

    reminders+=("Active OpenSpec change '$change_name' still has tasks.md; archive it when the change is complete.")
  done < <(find openspec/changes -mindepth 2 -maxdepth 3 -name tasks.md -type f -print0 2>/dev/null)
fi

if [[ -d "knowledge" && ! -f "knowledge/index.md" ]]; then
  reminders+=("knowledge/ exists but knowledge/index.md is missing; run compound-knowledge to create the lightweight index.")
fi

if [[ "${#reminders[@]}" -eq 0 ]]; then
  exit 0
fi

message="Harness workflow reminders:"
for reminder in "${reminders[@]}"; do
  message+=$'\n'
  message+="- $reminder"
done

if command -v node >/dev/null 2>&1; then
  MESSAGE="$message" node -e 'process.stdout.write(JSON.stringify({systemMessage: process.env.MESSAGE}) + "\n")'
elif command -v python3 >/dev/null 2>&1; then
  MESSAGE="$message" python3 - <<'PY'
import json
import os

print(json.dumps({"systemMessage": os.environ.get("MESSAGE", "")}))
PY
fi
