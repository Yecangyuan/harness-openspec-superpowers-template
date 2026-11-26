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
export HOSI_STATE_DIR="$prefix_dir/state"

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

rm -rf "$existing_target/.claude/rules"
mkdir -p "$existing_target/.codex/skills/review-spec"
printf '# Custom spec review\n' > "$existing_target/.codex/skills/review-spec/SKILL.md"
if bash "$ROOT_DIR/install.sh" --target "$existing_target" >"$prefix_dir/existing-review.out" 2>&1; then
  fail "install should refuse to overwrite an existing review-spec skill"
fi
assert_contains "$prefix_dir/existing-review.out" ".codex/skills/review-spec"
assert_contains "$existing_target/.codex/skills/review-spec/SKILL.md" "Custom spec review"

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
assert_file "$target_dir/harness/lib/verify-change.mjs"
assert_file "$target_dir/harness/lib/openspec.mjs"
assert_file "$target_dir/harness/lib/review-spec.mjs"
assert_file "$target_dir/harness/workflows/review-spec.md"
for client in .claude .codex .cursor; do
  assert_contains "$target_dir/$client/skills/review-spec/SKILL.md" "harness/workflows/review-spec.md"
done
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

(
  cd "$target_dir"
  export OPENSPEC_TELEMETRY=0
  report="$prefix_dir/change-workflow.out"
  opsx_exit() {
    local expected="$1" actual=0
    shift
    ./harness/bin/opsx "$@" > "$report" 2>&1 || actual=$?
    if [[ "$actual" -ne "$expected" ]]; then
      cat "$report" >&2
      fail "opsx $* returned $actual, expected $expected"
    fi
  }

  ./harness/bin/opsx propose other-change >/dev/null
  ./harness/bin/opsx propose verify-settings >/dev/null
  opsx_exit 1 review-spec
  assert_contains "$report" "Usage: ./harness/bin/opsx review-spec <change-name>"
  opsx_exit 1 review-spec verify-settings
  assert_contains "$report" "Review inputs: NEED ATTENTION"
  assert_contains "$report" "proposal: ready"
  assert_not_contains "$report" "other-change"
  opsx_exit 1 verify --change verify-settings
  assert_contains "$report" "OpenSpec artifacts: incomplete"
  assert_contains "$report" "Archive readiness: BLOCKED"
  assert_not_contains "$report" "other-change"

  change_dir=openspec/changes/verify-settings
  mkdir -p "$change_dir/specs/settings"
  cat > "$change_dir/proposal.md" <<'EOF'
## Why

Save the user's preference.

## What Changes

- Store the preference.

## Capabilities

### New Capabilities
- `settings`: Store a user's preference.

## Impact

Project settings.
EOF
  printf '## Decisions\n\nStore preferences locally.\n' > "$change_dir/design.md"
  printf '## 1. Settings\n\n- [ ] 1.1 Persist settings\n' > "$change_dir/tasks.md"
  cat > "$change_dir/specs/settings/spec.md" <<'EOF'
## ADDED Requirements

### Requirement: Store preferences
The system SHALL store the selected preference.

#### Scenario: Reopen settings
- **WHEN** the user reopens settings
- **THEN** the previous selection is present

#### Scenario: Change preference
- **WHEN** the user chooses a different preference
- **THEN** the new selection is stored
EOF

  cp -R "$change_dir" "$prefix_dir/review-input"
  opsx_exit 0 review-spec verify-settings
  assert_contains "$report" "harness/workflows/review-spec.md"
  assert_contains "$report" "$change_dir/specs/settings/spec.md"
  assert_contains "$report" "Parsed implementation tasks: 1"
  assert_contains "$report" "Review inputs: AVAILABLE"
  assert_not_contains "$report" "other-change"
  diff -r "$prefix_dir/review-input" "$change_dir" || fail "spec review modified change artifacts"

  printf '## 1. Settings\n' > "$change_dir/tasks.md"
  opsx_exit 1 review-spec verify-settings
  assert_contains "$report" "OpenSpec validation: PASSED"
  assert_contains "$report" "Parsed implementation tasks: 0"
  assert_contains "$report" "Review inputs: NEED ATTENTION"
  cp "$prefix_dir/review-input/tasks.md" "$change_dir/tasks.md"

  opsx_exit 1 verify --change verify-settings
  assert_contains "$report" "OpenSpec validation: PASSED"
  assert_contains "$report" "Pending: 1.1 Persist settings"
  assert_contains "$report" "the previous selection is present"
  assert_contains "$report" "Archive readiness: BLOCKED"
  printf '## 1. Settings\n\n- [x] 1.1 Persist settings\n' > "$change_dir/tasks.md"

  opsx_exit 2 verify --change verify-settings
  assert_contains "$report" "Implementation tasks: 1/1 complete"
  assert_contains "$report" "0 passed, 0 failed, 2 unverified"
  assert_contains "$report" "Archive readiness: UNVERIFIED"
  first_id="$(awk '$1 == "[UNVERIFIED]" { print $2; exit }' "$report")"
  second_id="$(awk '$1 == "[UNVERIFIED]" && ++count == 2 { print $2; exit }' "$report")"
  [[ -n "$first_id" && -n "$second_id" && "$first_id" != "$second_id" ]] || fail "verify report missing distinct scenario IDs"

  evidence="$prefix_dir/change-evidence.json"
  first_pass='{"status":"passed","implementation":"src/settings.js:42","check":"npm test -- settings","result":"saved preference restored"}'
  second_pass='{"status":"passed","implementation":"src/settings.js:44","check":"npm test -- settings","result":"new preference stored"}'
  printf '{"%s":%s}\n' "$first_id" "$first_pass" > "$evidence"
  opsx_exit 2 verify --change verify-settings --evidence "$evidence"
  assert_contains "$report" "1 passed, 0 failed, 1 unverified"

  printf '{"%s":%s,"%s":%s}\n' "$first_id" "$first_pass" "$second_id" "$second_pass" > "$evidence"
  opsx_exit 0 verify --change verify-settings --evidence "$evidence"
  assert_contains "$report" "Implementation: src/settings.js:42"
  assert_contains "$report" "Check: npm test -- settings"
  assert_contains "$report" "Result: saved preference restored"
  assert_contains "$report" "Archive readiness: READY"

  printf '{"%s":{"status":"failed","implementation":"src/settings.js:42","check":"npm test -- settings","result":"saved preference was missing"}}\n' "$first_id" > "$evidence"
  opsx_exit 1 verify --change verify-settings --evidence "$evidence"
  assert_contains "$report" "0 passed, 1 failed, 1 unverified"
  assert_contains "$report" "Archive readiness: BLOCKED"

  printf '{"stale-id":{}}\n' > "$evidence"
  opsx_exit 1 verify --change verify-settings --evidence "$evidence"
  assert_contains "$report" "Unknown evidence ID stale-id"

  printf '## Why\n\nDamaged proposal.\n' > "$change_dir/proposal.md"
  printf '## ADDED Requirements\n\nDamaged spec.\n' > "$change_dir/specs/settings/spec.md"
  opsx_exit 1 review-spec verify-settings
  assert_contains "$report" "OpenSpec validation: FAILED"
  assert_contains "$report" "Review inputs: NEED ATTENTION"
  opsx_exit 1 verify --change verify-settings
  assert_contains "$report" "OpenSpec validation: FAILED"
  assert_contains "$report" "Implementation tasks: 1/1 complete"
  assert_contains "$report" "Archive readiness: BLOCKED"

  opsx_exit 1 review-spec no-such-change
  assert_contains "$report" "Cannot review no-such-change"
  opsx_exit 1 verify --change no-such-change
  assert_contains "$report" "no-such-change"
)

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
"$ROOT_DIR/hosi" --install-system --prefix "$prefix_dir/with spaces" >/tmp/harness-template-system.out
assert_executable "$prefix_dir/with spaces/bin/hosi"
[[ -L "$prefix_dir/with spaces/bin/hosi" ]] || fail "hosi system install should create a symlink"
(
  cd "$hosi_target"
  export PATH="$prefix_dir/with spaces/bin:$PATH"
  hosi >/tmp/harness-template-hosi.out
)

assert_file "$hosi_target/HARNESS.md"
assert_contains "$hosi_target/.codex/skills/harness/SKILL.md" "$(basename "$hosi_target")"
assert_contains "$hosi_target/.harness-template-version" "install_mode: local"

combined_target="$prefix_dir/one-command project"
combined_prefix="$prefix_dir/one-command prefix"
combined_state="$prefix_dir/one-command state"
git init -q "$combined_target"
(
  cd "$combined_target"
  HOSI_STATE_DIR="$combined_state" "$ROOT_DIR/hosi" . --install-system \
    --prefix "$combined_prefix" --project-name "One Command" --shared
) > "$prefix_dir/combined-install.out"
assert_executable "$combined_prefix/bin/hosi"
[[ -L "$combined_prefix/bin/hosi" ]] || fail "one-command install should create the hosi link"
assert_executable "$combined_target/harness/bin/opsx"
assert_contains "$combined_target/.harness-template-version" "install_mode: shared"
assert_contains "$combined_target/.codex/skills/harness/SKILL.md" "One Command"
combined_path="$(cd -P "$combined_target" && pwd -P)"
combined_key="$(printf '%s' "$combined_path" | shasum -a 256 | awk '{print $1}')"
[[ "$(readlink "$combined_state/projects/$combined_key.project")" == "$combined_path" ]] || fail "one-command install should register the project"

if "$ROOT_DIR/hosi" "$nongit_target" --install-system --prefix "$prefix_dir/failed-prefix" \
    > "$prefix_dir/combined-failure.out" 2>&1; then
  fail "one-command install should report a failed project install"
fi
assert_contains "$prefix_dir/combined-failure.out" "Target is not inside a git repository"
[[ ! -L "$prefix_dir/failed-prefix/bin/hosi" ]] || fail "failed project install should leave the hosi link uncreated"

(
  bootstrap_source="$prefix_dir/bootstrap-source"
  bootstrap_project="$prefix_dir/bootstrap project"
  bootstrap_prefix="$prefix_dir/bootstrap prefix"
  export HOSI_TEMPLATE_DIR="$prefix_dir/template checkout"
  export HOSI_TEMPLATE_REPO="file://$bootstrap_source"
  export HOSI_STATE_DIR="$prefix_dir/bootstrap state"

  mkdir "$bootstrap_source"
  cp -R "$ROOT_DIR/template" "$ROOT_DIR/assets" "$ROOT_DIR/hosi" "$ROOT_DIR/install.sh" "$bootstrap_source/"
  git init -q "$bootstrap_source"
  git -C "$bootstrap_source" add .
  git -C "$bootstrap_source" -c user.name="Harness Test" -c user.email="harness-test@example.invalid" \
    -c commit.gpgsign=false -c core.hooksPath=/dev/null commit -qm "Add installer fixture"
  git init -q "$bootstrap_project"
  cd "$bootstrap_project"

  hosi_setup="$(<"$ROOT_DIR/bootstrap.sh")"
  bash -c "$hosi_setup" -- . --prefix "$bootstrap_prefix" --shared
  assert_executable "$bootstrap_project/harness/bin/opsx"
  assert_contains "$bootstrap_project/.harness-template-version" "install_mode: shared"
  assert_executable "$bootstrap_prefix/bin/hosi"
  [[ "$bootstrap_prefix/bin/hosi" -ef "$HOSI_TEMPLATE_DIR/hosi" ]] || fail "bootstrap link should point to the cached checkout"
  assert_glob_exists "$HOSI_STATE_DIR/projects/"'*.project'

  mv "$bootstrap_source" "$prefix_dir/offline-bootstrap-source"
  rm "$bootstrap_project/harness/bin/status"
  bash -c "$hosi_setup" -- . --prefix "$bootstrap_prefix" --upgrade
  assert_executable "$bootstrap_project/harness/bin/status"
  assert_contains "$bootstrap_project/.harness-template-version" "install_mode: shared"
)

cp "$shared_target/.gitignore" "$prefix_dir/shared-gitignore"
"$ROOT_DIR/hosi" "$shared_target" --upgrade
assert_contains "$shared_target/.harness-template-version" "install_mode: shared"
assert_contains "$shared_target/.codex/skills/harness/SKILL.md" "SharedProject"
assert_contains "$shared_target/openspec/config.yaml" "Shared Stack"
cmp -s "$shared_target/.gitignore" "$prefix_dir/shared-gitignore" || fail "shared upgrade changed .gitignore"

# Older manifests predate install_mode and used the original shared rules.
sed '/^install_mode: /d' "$shared_target/.harness-template-version" > "$prefix_dir/legacy-manifest"
cp "$prefix_dir/legacy-manifest" "$shared_target/.harness-template-version"
sed 's/Superpowers shared workflow files/Superpowers workflow files/' "$shared_target/.gitignore" > "$prefix_dir/legacy-gitignore"
cp "$prefix_dir/legacy-gitignore" "$shared_target/.gitignore"
"$ROOT_DIR/hosi" "$shared_target" --upgrade --tech-stack "Updated Shared Stack"
assert_contains "$shared_target/.harness-template-version" "install_mode: shared"
assert_contains "$shared_target/.codex/skills/harness/SKILL.md" "SharedProject"
assert_contains "$shared_target/openspec/config.yaml" "Tech stack: Updated Shared Stack"
cmp -s "$shared_target/.gitignore" "$prefix_dir/legacy-gitignore" || fail "legacy shared upgrade duplicated gitignore rules"

cp "$target_dir/CLAUDE.md" /tmp/harness-template-original-claude.md
printf '# User customized Claude instructions\n' > "$target_dir/CLAUDE.md"
printf '# User customized AGENTS instructions\n' > "$target_dir/AGENTS.md"
printf '# stale verify adapter\n' > "$target_dir/.claude/commands/opsx/verify.md"

(
  cd "$target_dir"
  PATH="$prefix_dir/with spaces/bin:$PATH" hosi . --upgrade
)

assert_contains "$target_dir/.codex/skills/harness/SKILL.md" "DemoProject"
assert_contains "$target_dir/openspec/config.yaml" "Android Kotlin Gradle"
assert_contains "$target_dir/.harness-template-version" "install_mode: local"
assert_contains "$target_dir/CLAUDE.md" "User customized Claude instructions"
assert_contains "$target_dir/AGENTS.md" "User customized AGENTS instructions"
assert_glob_exists "$target_dir/.harness-template-backups/"'*'"/CLAUDE.md"
assert_glob_exists "$target_dir/.harness-template-backups/"'*'"/AGENTS.md"
assert_contains "$target_dir/.claude/commands/opsx/verify.md" "stale verify adapter"
assert_contains "$target_dir/.harness-template-version" "installed_at:"
assert_glob_exists "$target_dir/.harness-template-backups/"'*'"/.claude/commands/opsx/verify.md"

hosi_cli="$prefix_dir/with spaces/bin/hosi"
batch_output="$prefix_dir/batch.out"
HOSI_STATE_DIR="$prefix_dir/empty-state" "$hosi_cli" --upgrade-all > "$batch_output"
assert_contains "$batch_output" "No projects registered"

if "$hosi_cli" --upgrade-all --force > "$batch_output" 2>&1; then
  fail "bulk upgrade should reject per-project options"
fi
assert_contains "$batch_output" "Use --upgrade-all on its own."

if "$hosi_cli" "$existing_target" --register > "$batch_output" 2>&1; then
  fail "registration should require an existing installation"
fi
assert_contains "$batch_output" "No installed Harness workflow"

ln -s "$hosi_target" "$prefix_dir/alias to installed project"
"$hosi_cli" "$prefix_dir/alias to installed project" --register

legacy_target="$prefix_dir/previous installation"
cp -R "$hosi_target" "$legacy_target"
cp "$legacy_target/.harness-template-version" "$prefix_dir/previous-manifest"
"$hosi_cli" "$legacy_target" --register
cmp -s "$legacy_target/.harness-template-version" "$prefix_dir/previous-manifest" || fail "registration changed the installed manifest"

moved_target="$prefix_dir/moved project"
broken_target="$prefix_dir/broken project"
cp -R "$hosi_target" "$moved_target"
cp -R "$hosi_target" "$broken_target"
"$hosi_cli" "$moved_target" --register >/dev/null &
moved_registration=$!
"$hosi_cli" "$broken_target" --register >/dev/null &
broken_registration=$!
wait "$moved_registration"
wait "$broken_registration"
mv "$moved_target" "$prefix_dir/relocated project"
mv "$broken_target/.git" "$prefix_dir/broken-project-git"

printf '# Local change to preserve during bulk upgrade\n' > "$hosi_target/AGENTS.md"
rm "$hosi_target/harness/bin/status" "$shared_target/harness/bin/status" "$legacy_target/harness/bin/status"
verify_hash="$(shasum -a 256 "$shared_target/harness/bin/verify" | awk '{print $1}')"
awk '$2 == "harness/bin/verify" { $1 = "previous-hash" } { print }' \
  "$shared_target/.harness-template-version" > "$prefix_dir/interrupted-manifest"
cp "$prefix_dir/interrupted-manifest" "$shared_target/.harness-template-version"

if (cd "$nongit_target" && "$hosi_cli" --upgrade-all) > "$batch_output" 2>&1; then
  fail "partial batch failure should return a nonzero exit status"
fi
assert_contains "$batch_output" "Upgrade summary: 4 upgraded, 1 skipped, 1 failed."
assert_contains "$batch_output" "Upgrade failed: $(cd -P "$broken_target" && pwd -P)"
assert_contains "$batch_output" "Skipped: project path or installation manifest is unavailable."
[[ ! -e "$moved_target" ]] || fail "bulk upgrade should not recreate a moved project"
assert_executable "$hosi_target/harness/bin/status"
assert_executable "$shared_target/harness/bin/status"
assert_executable "$legacy_target/harness/bin/status"
assert_contains "$hosi_target/AGENTS.md" "Local change to preserve during bulk upgrade"
assert_glob_exists "$hosi_target/.harness-template-backups/"'*'"/AGENTS.md"
assert_contains "$shared_target/.harness-template-version" "install_mode: shared"
assert_contains "$shared_target/.harness-template-version" "$verify_hash harness/bin/verify"
assert_contains "$shared_target/openspec/config.yaml" "Tech stack: Updated Shared Stack"

mv "$prefix_dir/broken-project-git" "$broken_target/.git"
(cd "$nongit_target" && "$hosi_cli" --upgrade-all) > "$batch_output" 2>&1
assert_contains "$batch_output" "Upgrade summary: 5 upgraded, 1 skipped, 0 failed."

echo "PASS: install.sh creates a runnable Harness template"
