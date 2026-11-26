#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  printf 'Usage: bash bootstrap.sh [project-dir] [hosi options]\n'
  exit 0
fi

project_dir="."
if [[ "$#" -gt 0 && "$1" != -* ]]; then
  project_dir="$1"
  shift
fi

if ! command -v git >/dev/null 2>&1; then
  printf 'Install Git before running the installer.\n' >&2
  exit 1
fi
if [[ "$(git -C "$project_dir" rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]]; then
  printf 'Run the installer in a Git project or pass a project directory.\n' >&2
  exit 1
fi

template_repo="${HOSI_TEMPLATE_REPO:-https://github.com/Yecangyuan/harness-openspec-superpowers-template.git}"
template_dir="${HOSI_TEMPLATE_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/hosi/template}"

prepare_checkout() (
  local lock="$template_dir.clone-lock"
  mkdir -p -- "$(dirname "$template_dir")"
  if ! mkdir -- "$lock" 2>/dev/null; then
    printf 'Could not lock the template checkout at %s\n' "$lock" >&2
    exit 1
  fi
  trap 'rmdir -- "$lock"' EXIT

  if [[ ! -e "$template_dir" && ! -L "$template_dir" ]]; then
    git clone --depth 1 -- "$template_repo" "$template_dir"
  fi

  if [[ ! -e "$template_dir/.git" ||
        "$(git -C "$template_dir" config --get remote.origin.url 2>/dev/null)" != "$template_repo" ]]; then
    printf 'Could not use the template checkout at %s. Set HOSI_TEMPLATE_DIR to a fresh path.\n' "$template_dir" >&2
    exit 1
  fi
  if [[ ! -x "$template_dir/hosi" || ! -f "$template_dir/install.sh" ]]; then
    printf 'The template checkout at %s is missing hosi. Update the checkout and try again.\n' "$template_dir" >&2
    exit 1
  fi
)

prepare_checkout
exec "$template_dir/hosi" "$project_dir" --install-system "$@"
