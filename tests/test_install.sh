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

assert_glob_exists() {
  local pattern="$1"
  compgen -G "$pattern" >/dev/null || fail "missing match: $pattern"
}

existing_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-existing.XXXXXX")"
target_dir="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-install.XXXXXX")"
shared_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-shared.XXXXXX")"
hosi_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-hosi.XXXXXX")"
nongit_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-nongit.XXXXXX")"
prefix_dir="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-prefix.XXXXXX")"
trap 'rm -rf "$existing_target" "$target_dir" "$shared_target" "$hosi_target" "$nongit_target" "$prefix_dir"' EXIT

if bash "$ROOT_DIR/install.sh" --target "$nongit_target" >/tmp/harness-template-nongit.out 2>&1; then
  fail "install should refuse to install outside a git repository"
fi
grep -Fq "git init" /tmp/harness-template-nongit.out || fail "non-git refusal should mention git init"

git -C "$existing_target" init -q
mkdir -p "$existing_target/.claude"
printf '{}\n' > "$existing_target/.claude/settings.json"

if bash "$ROOT_DIR/install.sh" --target "$existing_target" >/tmp/harness-template-existing.out 2>&1; then
  fail "install should refuse to overwrite existing .claude/settings.json"
fi
grep -Fq ".claude/settings.json" /tmp/harness-template-existing.out || fail "overwrite refusal should mention .claude/settings.json"

rm -rf "$existing_target"
existing_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-existing.XXXXXX")"
git -C "$existing_target" init -q
printf '# Existing Claude instructions\n' > "$existing_target/CLAUDE.md"

if bash "$ROOT_DIR/install.sh" --target "$existing_target" >/tmp/harness-template-existing-claude.out 2>&1; then
  fail "install should refuse to overwrite existing CLAUDE.md"
fi
grep -Fq "CLAUDE.md" /tmp/harness-template-existing-claude.out || fail "overwrite refusal should mention CLAUDE.md"

rm -rf "$existing_target"
existing_target="$(mktemp -d "${TMPDIR:-/tmp}/harness-template-existing.XXXXXX")"
git -C "$existing_target" init -q
mkdir -p "$existing_target/.claude/rules"
printf '# Existing rule\n' > "$existing_target/.claude/rules/markdown-docs.md"

if bash "$ROOT_DIR/install.sh" --target "$existing_target" >/tmp/harness-template-existing-rules.out 2>&1; then
  fail "install should refuse to overwrite existing .claude/rules"
fi
grep -Fq ".claude/rules" /tmp/harness-template-existing-rules.out || fail "overwrite refusal should mention .claude/rules"

cat >"$target_dir/.gitignore" <<'EOF'
bin/
/.cursor/
EOF
git -C "$target_dir" init -q

bash "$ROOT_DIR/install.sh" \
  --target "$target_dir" \
  --project-name "DemoProject" \
  --tech-stack "Android Kotlin Gradle"

assert_file "$target_dir/HARNESS.md"
assert_file "$target_dir/AGENTS.md"
assert_file "$target_dir/CLAUDE.md"
assert_file "$target_dir/.harness-template-version"
assert_file "$target_dir/openspec/config.yaml"
assert_file "$target_dir/.codex/skills/harness/SKILL.md"
assert_file "$target_dir/.claude/commands/opsx/verify.md"
assert_file "$target_dir/.cursor/commands/opsx-verify.md"
assert_file "$target_dir/.claude/settings.json"
assert_file "$target_dir/.claude/rules/harness-workflow-layer.md"
assert_file "$target_dir/.claude/rules/markdown-docs.md"
assert_file "$target_dir/.claude/rules/superpowers-planning.md"
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
assert_contains "$target_dir/CLAUDE.md" "@AGENTS.md"
assert_contains "$target_dir/CLAUDE.md" "Claude Code"
assert_contains "$target_dir/AGENTS.md" "create a focused git commit before reporting the work as complete"
assert_contains "$target_dir/CLAUDE.md" "create a focused git commit before reporting the work as complete"
assert_contains "$target_dir/.harness-template-version" "template_commit:"
assert_contains "$target_dir/.harness-template-version" "install_mode: local"
assert_contains "$target_dir/.gitignore" ".harness-template-backups/"
assert_contains "$target_dir/.gitignore" "Harness/OpenSpec/Superpowers local workflow files"
assert_contains "$target_dir/openspec/config.yaml" "Android Kotlin Gradle"
assert_contains "$target_dir/.claude/settings.json" "\"respectGitignore\": true"
assert_contains "$target_dir/.claude/settings.json" "\"plansDirectory\": \"./docs/superpowers/plans\""
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
  if ! git check-ignore -q harness/bin/verify; then
    fail "harness/bin/verify should be ignored after local install"
  fi
  if ! git check-ignore -q .cursor/commands/opsx-verify.md; then
    fail ".cursor verify adapter should be ignored after local install"
  fi
  if ! git check-ignore -q AGENTS.md; then
    fail "AGENTS.md should be ignored after local install"
  fi
  env LC_ALL=C ./harness/bin/check >/tmp/harness-template-check.out
  env LC_ALL=C ./harness/bin/opsx verify >/tmp/harness-template-verify.out
)

grep -Fq "HARNESS VERIFY" /tmp/harness-template-verify.out || fail "verify output missing banner"
grep -Fq "OpenSpec Specs" /tmp/harness-template-verify.out || fail "verify output missing specs section"

cat >"$shared_target/.gitignore" <<'EOF'
bin/
/.cursor/
EOF
git -C "$shared_target" init -q

bash "$ROOT_DIR/install.sh" \
  --target "$shared_target" \
  --project-name "SharedProject" \
  --tech-stack "Shared Stack" \
  --shared

assert_contains "$shared_target/.harness-template-version" "install_mode: shared"
assert_contains "$shared_target/.gitignore" "Harness/OpenSpec/Superpowers shared workflow files"
(
  cd "$shared_target"
  if git check-ignore -q harness/bin/verify; then
    fail "harness/bin/verify should not be ignored after shared install"
  fi
  if git check-ignore -q .cursor/commands/opsx-verify.md; then
    fail ".cursor verify adapter should not be ignored after shared install"
  fi
)

git -C "$hosi_target" init -q
(
  cd "$hosi_target"
  "$ROOT_DIR/hosi" . \
    --project-name "HosiProject" \
    --tech-stack "CLI Stack" >/tmp/harness-template-hosi.out
)

assert_file "$hosi_target/HARNESS.md"
assert_contains "$hosi_target/.codex/skills/harness/SKILL.md" "HosiProject"
assert_contains "$hosi_target/.harness-template-version" "install_mode: local"

"$ROOT_DIR/hosi" --install-system --prefix "$prefix_dir" >/tmp/harness-template-system.out
assert_executable "$prefix_dir/bin/hosi"
[[ -L "$prefix_dir/bin/hosi" ]] || fail "hosi system install should create a symlink"

cp "$target_dir/CLAUDE.md" /tmp/harness-template-original-claude.md
printf '# User customized Claude instructions\n' > "$target_dir/CLAUDE.md"
printf '# User customized AGENTS instructions\n' > "$target_dir/AGENTS.md"
printf '# stale verify adapter\n' > "$target_dir/.claude/commands/opsx/verify.md"

bash "$ROOT_DIR/install.sh" \
  --target "$target_dir" \
  --project-name "DemoProject" \
  --tech-stack "Android Kotlin Gradle" \
  --upgrade

assert_contains "$target_dir/CLAUDE.md" "User customized Claude instructions"
assert_contains "$target_dir/AGENTS.md" "User customized AGENTS instructions"
assert_glob_exists "$target_dir/.harness-template-backups/"'*'"/CLAUDE.md"
assert_glob_exists "$target_dir/.harness-template-backups/"'*'"/AGENTS.md"
assert_contains "$target_dir/.claude/commands/opsx/verify.md" "stale verify adapter"
assert_contains "$target_dir/.harness-template-version" "installed_at:"
assert_glob_exists "$target_dir/.harness-template-backups/"'*'"/.claude/commands/opsx/verify.md"

echo "PASS: install.sh creates a runnable Harness template"
