#!/usr/bin/env bash

harness_repo_root() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  cd "$script_dir/.." && pwd
}

harness_has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

harness_print_err() {
  printf '%s\n' "$*" >&2
}

harness_check_required_cmd() {
  local cmd="$1"
  if harness_has_cmd "$cmd"; then
    return 0
  fi
  harness_print_err "missing required command: $cmd"
  return 1
}

harness_check_optional_cmd() {
  harness_has_cmd "$1"
}

harness_abs_repo_path() {
  local root
  root="$(harness_repo_root)"
  printf '%s/%s\n' "$root" "$1"
}

harness_require_openspec() {
  harness_check_required_cmd openspec
}

harness_list_changes_json() {
  openspec list --json
}

harness_collect_change_names() {
  harness_list_changes_json | awk '
    {
      line = $0
      while (match(line, /"name"[[:space:]]*:[[:space:]]*"[^"]+"/)) {
        token = substr(line, RSTART, RLENGTH)
        sub(/.*"name"[[:space:]]*:[[:space:]]*"/, "", token)
        sub(/"$/, "", token)
        print token
        line = substr(line, RSTART + RLENGTH)
      }
    }
  '
}

harness_collect_complete_change_names() {
  harness_list_changes_json | awk '
    /"name":/ {
      line = $0
      sub(/.*"name":[[:space:]]*"/, "", line)
      sub(/".*/, "", line)
      name = line
    }
    /"status":/ {
      line = $0
      sub(/.*"status":[[:space:]]*"/, "", line)
      sub(/".*/, "", line)
      if (line == "complete" && name != "") {
        print name
      }
      name = ""
    }
  '
}

harness_resolve_change() {
  local requested="${1:-}"

  if [[ -n "$requested" ]]; then
    printf '%s\n' "$requested"
    return 0
  fi

  mapfile -t change_names < <(harness_collect_change_names)

  case "${#change_names[@]}" in
    0)
      harness_print_err "No active changes. Create one with: ./harness/bin/opsx propose <change-name>"
      return 1
      ;;
    1)
      printf '%s\n' "${change_names[0]}"
      return 0
      ;;
    *)
      harness_print_err "Multiple active changes found. Specify one explicitly:"
      printf '%s\n' "${change_names[@]}" >&2
      return 1
      ;;
  esac
}
