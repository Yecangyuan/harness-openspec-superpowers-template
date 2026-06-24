#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_file() {
  [[ -f "$1" ]] || fail "missing file: $1"
}

assert_dir() {
  [[ -d "$1" ]] || fail "missing dir: $1"
}

assert_executable() {
  [[ -x "$1" ]] || fail "not executable: $1"
}

assert_contains() {
  local file="$1"
  local needle="$2"
  if ! grep -Fq "$needle" "$file"; then
    fail "$file missing: $needle"
  fi
}

assert_not_contains() {
  local file="$1"
  local needle="$2"
  if grep -Fq "$needle" "$file"; then
    fail "$file still contains: $needle"
  fi
}

existing_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-existing.XXXXXX")"
target_dir="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-install.XXXXXX")"
trap 'rm -rf "$existing_target" "$target_dir"' EXIT

mkdir -p "$existing_target/.claude"
printf '{}\n' > "$existing_target/.claude/settings.json"

if bash "$ROOT_DIR/install.sh" --target "$existing_target" >/tmp/harness-template-existing.out 2>&1; then
  fail "install should refuse to overwrite existing .claude/settings.json"
fi
grep -Fq ".claude/settings.json" /tmp/harness-template-existing.out || fail "overwrite refusal should mention .claude/settings.json"

cat >"$target_dir/.gitignore" <<'EOF'
bin/
/.cursor/
EOF

bash "$ROOT_DIR/install.sh" \
  --target "$target_dir" \
  --project-name "DemoProject" \
  --tech-stack "Android Kotlin Gradle"

assert_file "$target_dir/HARNESS.md"
assert_file "$target_dir/AGENTS.md"
assert_file "$target_dir/openspec/config.yaml"
assert_file "$target_dir/.codex/skills/harness/SKILL.md"
assert_file "$target_dir/.claude/commands/opsx/verify.md"
assert_file "$target_dir/.cursor/commands/opsx-verify.md"
assert_file "$target_dir/.claude/settings.json"
assert_executable "$target_dir/.claude/hooks/workflow-reminder.sh"
assert_file "$target_dir/harness/skills/multi-review/SKILL.md"
assert_file "$target_dir/harness/skills/multi-review/references/correctness-reviewer.md"
assert_file "$target_dir/harness/skills/multi-review/references/testing-reviewer.md"
assert_file "$target_dir/harness/skills/multi-review/references/security-reviewer.md"
assert_file "$target_dir/harness/skills/multi-review/references/performance-reviewer.md"
assert_file "$target_dir/harness/skills/multi-review/references/adversarial-reviewer.md"
assert_file "$target_dir/harness/skills/multi-review/references/architecture-strategist.md"
assert_file "$target_dir/harness/skills/compound-knowledge/SKILL.md"
assert_file "$target_dir/harness/skills/tech-proposal/SKILL.md"
assert_file "$target_dir/.claude/skills/multi-review/SKILL.md"
assert_file "$target_dir/.claude/skills/compound-knowledge/SKILL.md"
assert_file "$target_dir/.claude/skills/tech-proposal/SKILL.md"
assert_file "$target_dir/.codex/skills/multi-review/SKILL.md"
assert_file "$target_dir/.codex/skills/compound-knowledge/SKILL.md"
assert_file "$target_dir/.codex/skills/tech-proposal/SKILL.md"
assert_file "$target_dir/.cursor/skills/multi-review/SKILL.md"
assert_file "$target_dir/.cursor/skills/compound-knowledge/SKILL.md"
assert_file "$target_dir/.cursor/skills/tech-proposal/SKILL.md"
assert_file "$target_dir/harness/workflows/verify.md"
assert_file "$target_dir/harness/workflows/multi-review.md"
assert_file "$target_dir/harness/workflows/compound-knowledge.md"
assert_file "$target_dir/harness/workflows/tech-proposal.md"
assert_file "$target_dir/harness/tests/test_harness.sh"
assert_executable "$target_dir/harness/bin/check"
assert_executable "$target_dir/harness/bin/status"
assert_executable "$target_dir/harness/bin/opsx"
assert_executable "$target_dir/harness/bin/verify"
assert_dir "$target_dir/docs/superpowers/specs"
assert_dir "$target_dir/docs/superpowers/plans"

assert_contains "$target_dir/.codex/skills/harness/SKILL.md" "DemoProject"
assert_contains "$target_dir/openspec/config.yaml" "Android Kotlin Gradle"
assert_contains "$target_dir/.claude/settings.json" "workflow-reminder.sh"
assert_contains "$target_dir/harness/skills/multi-review/SKILL.md" "Multi-Persona Code Review"
assert_contains "$target_dir/harness/skills/compound-knowledge/SKILL.md" "knowledge/index.md"
assert_contains "$target_dir/harness/skills/tech-proposal/SKILL.md" "tech-proposal.md"
old_project_name="LegacyProjectName"
old_local_path="/private/local/path"
assert_not_contains "$target_dir/.codex/skills/harness/SKILL.md" "$old_project_name"
assert_not_contains "$target_dir/AGENTS.md" "$old_local_path"

(
  cd "$target_dir"
  git init -q
  if git check-ignore -q harness/bin/verify; then
    fail "harness/bin/verify should not be ignored after install"
  fi
  if git check-ignore -q .cursor/commands/opsx-verify.md; then
    fail ".cursor verify adapter should not be ignored after install"
  fi
  env LC_ALL=C ./harness/bin/check >/tmp/harness-template-check.out
  env LC_ALL=C ./harness/bin/opsx verify >/tmp/harness-template-verify.out
)

grep -Fq "HARNESS VERIFY" /tmp/harness-template-verify.out || fail "verify output missing banner"
grep -Fq "OpenSpec Specs" /tmp/harness-template-verify.out || fail "verify output missing specs section"

echo "PASS: install.sh creates a runnable Harness template"
