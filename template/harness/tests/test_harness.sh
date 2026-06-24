#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$ROOT_DIR/harness/lib/common.sh"

fail() {
  echo "FAIL: $1" >&2
  exit 1
}

assert_eq() {
  local expected="$1"
  local actual="$2"
  local label="$3"
  if [[ "$expected" != "$actual" ]]; then
    fail "$label: expected '$expected' got '$actual'"
  fi
}

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local label="$3"
  if [[ "$haystack" != *"$needle"* ]]; then
    fail "$label: missing '$needle'"
  fi
}

assert_not_git_ignored() {
  local file="$1"
  if ! harness_has_cmd git || ! git -C "$ROOT_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 0
  fi
  if git -C "$ROOT_DIR" check-ignore -q "$file"; then
    fail "$file should not be ignored by git"
  fi
}

assert_adapter_points_to() {
  local file="$1"
  local workflow="$2"
  local content

  content="$(<"$ROOT_DIR/$file")"
  assert_contains "$content" "HARNESS.md" "$file harness link"
  assert_contains "$content" "./harness/bin/check" "$file check link"
  assert_contains "$content" "harness/workflows/$workflow.md" "$file workflow link"
}

assert_skill_adapter_points_to() {
  local file="$1"
  local skill="$2"
  local content

  content="$(<"$ROOT_DIR/$file")"
  assert_contains "$content" "HARNESS.md" "$file harness link"
  assert_contains "$content" "harness/skills/$skill/SKILL.md" "$file skill link"
}

find_archived_change() {
  local change_name="$1"
  if [[ ! -d "$ROOT_DIR/openspec/changes/archive" ]]; then
    return 0
  fi
  find "$ROOT_DIR/openspec/changes/archive" -maxdepth 1 -type d -name "*$change_name" -print -quit 2>/dev/null
}

temp_change="harness-smoke-$$"
cleanup_temp_change() {
  rm -rf "$ROOT_DIR/openspec/changes/$temp_change"
  local archived_dir
  archived_dir="$(find_archived_change "$temp_change")"
  if [[ -n "$archived_dir" ]]; then
    rm -rf "$archived_dir"
  fi
}

trap cleanup_temp_change EXIT
cleanup_temp_change

repo_root="$(harness_repo_root)"
assert_eq "$ROOT_DIR" "$repo_root" "repo root"

if harness_has_cmd bash; then
  :
else
  fail "expected bash to be available"
fi

missing_output="$(harness_check_required_cmd definitely-not-a-command 2>&1 || true)"
assert_contains "$missing_output" "definitely-not-a-command" "missing command output"

check_output="$(bash "$ROOT_DIR/harness/bin/check" 2>&1 || true)"
assert_contains "$check_output" "HARNESS CHECK" "check banner"
assert_contains "$check_output" "openspec" "check openspec line"
assert_contains "$check_output" "harness/bin/verify" "check verify command"

status_output="$(bash "$ROOT_DIR/harness/bin/status" 2>&1 || true)"
assert_contains "$status_output" "HARNESS STATUS" "status banner"
assert_contains "$status_output" "Repo Root:" "status repo root"

opsx_help="$(bash "$ROOT_DIR/harness/bin/opsx" help 2>&1 || true)"
assert_contains "$opsx_help" "Usage: ./harness/bin/opsx" "opsx usage"
assert_contains "$opsx_help" "propose" "opsx actions"
assert_contains "$opsx_help" "verify" "opsx verify action"

opsx_status="$(bash "$ROOT_DIR/harness/bin/opsx" status 2>&1 || true)"
assert_contains "$opsx_status" "HARNESS STATUS" "opsx status routing"

resolve_without_changes="$(
  harness_list_changes_json() { printf '{"changes":[]}\n'; }
  harness_resolve_change "" 2>&1 || true
)"
assert_contains "$resolve_without_changes" "No active changes" "resolve no active changes"

resolve_single_change="$(
  harness_list_changes_json() { printf '{"changes":[{"name":"one-change"}]}\n'; }
  harness_resolve_change "" 2>&1
)"
assert_eq "one-change" "$resolve_single_change" "resolve unique active change"

resolve_multiple_changes="$(
  harness_list_changes_json() { printf '{"changes":[{"name":"one-change"},{"name":"two-change"}]}\n'; }
  harness_resolve_change "" 2>&1 || true
)"
assert_contains "$resolve_multiple_changes" "Multiple active changes found" "resolve multiple active changes"

opsx_apply_without_change="$(bash "$ROOT_DIR/harness/bin/opsx" apply 2>&1 || true)"
case "$(harness_collect_change_names | wc -l | tr -d ' ')" in
  0)
    assert_contains "$opsx_apply_without_change" "No active changes" "opsx apply without change"
    ;;
  1)
    assert_contains "$opsx_apply_without_change" "Action: apply" "opsx apply unique active change"
    ;;
  *)
    assert_contains "$opsx_apply_without_change" "Multiple active changes found" "opsx apply multiple active changes"
    ;;
esac

opsx_verify="$(HARNESS_VERIFY_SKIP_TESTS=1 bash "$ROOT_DIR/harness/bin/opsx" verify 2>&1 || true)"
assert_contains "$opsx_verify" "HARNESS VERIFY" "opsx verify routing"
assert_contains "$opsx_verify" "Harness Tests" "opsx verify tests"

opsx_propose="$(bash "$ROOT_DIR/harness/bin/opsx" propose "$temp_change" 2>&1 || true)"
assert_contains "$opsx_propose" "Created change '$temp_change'" "opsx propose create"
[[ -d "$ROOT_DIR/openspec/changes/$temp_change" ]] || fail "proposed change missing"

opsx_explore="$(bash "$ROOT_DIR/harness/bin/opsx" explore 2>&1 || true)"
assert_contains "$opsx_explore" "$temp_change" "opsx explore list"

opsx_apply_change="$(bash "$ROOT_DIR/harness/bin/opsx" apply "$temp_change" 2>&1 || true)"
assert_contains "$opsx_apply_change" "\"state\": \"blocked\"" "opsx apply blocked state"
assert_contains "$opsx_apply_change" "\"missingArtifacts\"" "opsx apply missing artifacts"

opsx_sync_change="$(bash "$ROOT_DIR/harness/bin/opsx" sync "$temp_change" 2>&1 || true)"
assert_contains "$opsx_sync_change" "OpenSpec has no direct sync command" "opsx sync note"
assert_contains "$opsx_sync_change" "$temp_change" "opsx sync change name"

opsx_archive_change="$(bash "$ROOT_DIR/harness/bin/opsx" archive "$temp_change" -y 2>&1 || true)"
assert_contains "$opsx_archive_change" "archived as" "opsx archive result"
[[ ! -d "$ROOT_DIR/openspec/changes/$temp_change" ]] || fail "archived change still active"
archive_hit="$(find_archived_change "$temp_change")"
[[ -n "$archive_hit" ]] || fail "archived change missing"

[[ -f "$ROOT_DIR/HARNESS.md" ]] || fail "HARNESS.md missing"
[[ -f "$ROOT_DIR/AGENTS.md" ]] || fail "AGENTS.md missing"
[[ -f "$ROOT_DIR/harness/README.md" ]] || fail "harness/README.md missing"
[[ -f "$ROOT_DIR/harness/workflows/apply.md" ]] || fail "apply workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/archive.md" ]] || fail "archive workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/explore.md" ]] || fail "explore workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/propose.md" ]] || fail "propose workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/sync.md" ]] || fail "sync workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/verify.md" ]] || fail "verify workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/multi-review.md" ]] || fail "multi-review workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/compound-knowledge.md" ]] || fail "compound-knowledge workflow missing"
[[ -f "$ROOT_DIR/harness/workflows/tech-proposal.md" ]] || fail "tech-proposal workflow missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/SKILL.md" ]] || fail "multi-review skill missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/references/correctness-reviewer.md" ]] || fail "correctness reviewer missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/references/testing-reviewer.md" ]] || fail "testing reviewer missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/references/security-reviewer.md" ]] || fail "security reviewer missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/references/performance-reviewer.md" ]] || fail "performance reviewer missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/references/adversarial-reviewer.md" ]] || fail "adversarial reviewer missing"
[[ -f "$ROOT_DIR/harness/skills/multi-review/references/architecture-strategist.md" ]] || fail "architecture reviewer missing"
[[ -f "$ROOT_DIR/harness/skills/compound-knowledge/SKILL.md" ]] || fail "compound-knowledge skill missing"
[[ -f "$ROOT_DIR/harness/skills/tech-proposal/SKILL.md" ]] || fail "tech-proposal skill missing"
[[ -f "$ROOT_DIR/harness/bin/verify" ]] || fail "verify command missing"
[[ -f "$ROOT_DIR/.codex/skills/harness/SKILL.md" ]] || fail "codex harness skill missing"
[[ -x "$ROOT_DIR/.claude/hooks/workflow-reminder.sh" ]] || fail "workflow reminder hook missing or not executable"
assert_not_git_ignored "harness/bin/verify"
assert_not_git_ignored ".cursor/commands/opsx-verify.md"

agents_content="$(<"$ROOT_DIR/AGENTS.md")"
assert_contains "$agents_content" "HARNESS.md" "AGENTS harness link"
assert_contains "$agents_content" "./harness/bin/check" "AGENTS check link"
assert_contains "$agents_content" "./harness/bin/opsx" "AGENTS opsx link"

codex_harness_content="$(<"$ROOT_DIR/.codex/skills/harness/SKILL.md")"
assert_contains "$codex_harness_content" "Use first" "codex harness trigger"
assert_contains "$codex_harness_content" "HARNESS.md" "codex harness doc link"
assert_contains "$codex_harness_content" "./harness/bin/check" "codex harness check"
assert_contains "$codex_harness_content" "./harness/bin/opsx" "codex harness opsx"

openspec_config="$(<"$ROOT_DIR/openspec/config.yaml")"
assert_contains "$openspec_config" "Tech stack:" "openspec project context"
assert_contains "$openspec_config" "rules:" "openspec artifact rules"

assert_adapter_points_to ".claude/commands/opsx/apply.md" "apply"
assert_adapter_points_to ".claude/commands/opsx/archive.md" "archive"
assert_adapter_points_to ".claude/commands/opsx/explore.md" "explore"
assert_adapter_points_to ".claude/commands/opsx/propose.md" "propose"
assert_adapter_points_to ".claude/commands/opsx/sync.md" "sync"
assert_adapter_points_to ".claude/commands/opsx/verify.md" "verify"

assert_adapter_points_to ".claude/skills/openspec-apply-change/SKILL.md" "apply"
assert_adapter_points_to ".claude/skills/openspec-archive-change/SKILL.md" "archive"
assert_adapter_points_to ".claude/skills/openspec-explore/SKILL.md" "explore"
assert_adapter_points_to ".claude/skills/openspec-propose/SKILL.md" "propose"
assert_adapter_points_to ".claude/skills/openspec-sync-specs/SKILL.md" "sync"

assert_adapter_points_to ".cursor/commands/opsx-apply.md" "apply"
assert_adapter_points_to ".cursor/commands/opsx-archive.md" "archive"
assert_adapter_points_to ".cursor/commands/opsx-explore.md" "explore"
assert_adapter_points_to ".cursor/commands/opsx-propose.md" "propose"
assert_adapter_points_to ".cursor/commands/opsx-sync.md" "sync"
assert_adapter_points_to ".cursor/commands/opsx-verify.md" "verify"

assert_adapter_points_to ".cursor/skills/openspec-apply-change/SKILL.md" "apply"
assert_adapter_points_to ".cursor/skills/openspec-archive-change/SKILL.md" "archive"
assert_adapter_points_to ".cursor/skills/openspec-explore/SKILL.md" "explore"
assert_adapter_points_to ".cursor/skills/openspec-propose/SKILL.md" "propose"
assert_adapter_points_to ".cursor/skills/openspec-sync-specs/SKILL.md" "sync"

assert_adapter_points_to ".codex/skills/openspec-apply-change/SKILL.md" "apply"
assert_adapter_points_to ".codex/skills/openspec-archive-change/SKILL.md" "archive"
assert_adapter_points_to ".codex/skills/openspec-explore/SKILL.md" "explore"
assert_adapter_points_to ".codex/skills/openspec-propose/SKILL.md" "propose"
assert_adapter_points_to ".codex/skills/openspec-sync-specs/SKILL.md" "sync"

assert_skill_adapter_points_to ".claude/skills/multi-review/SKILL.md" "multi-review"
assert_skill_adapter_points_to ".claude/skills/compound-knowledge/SKILL.md" "compound-knowledge"
assert_skill_adapter_points_to ".claude/skills/tech-proposal/SKILL.md" "tech-proposal"
assert_skill_adapter_points_to ".cursor/skills/multi-review/SKILL.md" "multi-review"
assert_skill_adapter_points_to ".cursor/skills/compound-knowledge/SKILL.md" "compound-knowledge"
assert_skill_adapter_points_to ".cursor/skills/tech-proposal/SKILL.md" "tech-proposal"
assert_skill_adapter_points_to ".codex/skills/multi-review/SKILL.md" "multi-review"
assert_skill_adapter_points_to ".codex/skills/compound-knowledge/SKILL.md" "compound-knowledge"
assert_skill_adapter_points_to ".codex/skills/tech-proposal/SKILL.md" "tech-proposal"

hook_settings="$(<"$ROOT_DIR/.claude/settings.json")"
assert_contains "$hook_settings" "Stop" "claude hook stop event"
assert_contains "$hook_settings" "workflow-reminder.sh" "claude hook command"

if [[ ! -e "$ROOT_DIR/knowledge" ]]; then
  mkdir "$ROOT_DIR/knowledge"
  hook_output="$(CLAUDE_PROJECT_DIR="$ROOT_DIR" "$ROOT_DIR/.claude/hooks/workflow-reminder.sh" 2>&1 || true)"
  assert_contains "$hook_output" "knowledge/index.md is missing" "workflow reminder knowledge output"
  rmdir "$ROOT_DIR/knowledge"
fi

echo "PASS: harness common helpers"
