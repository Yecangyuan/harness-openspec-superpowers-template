import { spawnSync } from 'node:child_process';

export function runOpenSpec(repoRoot, args, { allowInvalid = false } = {}) {
  const run = spawnSync('openspec', args, {
    cwd: repoRoot,
    encoding: 'utf8',
    maxBuffer: 16 * 1024 * 1024,
  });
  const command = `openspec ${args[0]}`;
  if (run.error) throw new Error(`${command}: ${run.error.message}`);
  if (run.status !== 0 && (!allowInvalid || run.status !== 1)) {
    throw new Error(`${command}: ${run.stderr.trim() || `failed (${run.signal || run.status})`}`);
  }
  try {
    return { data: JSON.parse(run.stdout), success: run.status === 0 };
  } catch {
    throw new Error(`${command}: ${run.stderr.trim() || 'expected a JSON response'}`);
  }
}

export function readChange(repoRoot, changeName) {
  const { data: status } = runOpenSpec(repoRoot, ['status', `--change=${changeName}`, '--json']);
  const { data: apply } = runOpenSpec(repoRoot, ['instructions', 'apply', `--change=${changeName}`, '--json']);
  const validation = runOpenSpec(repoRoot, [
    'validate', '--type', 'change', '--strict', '--json', '--no-interactive', '--', changeName,
  ], { allowInvalid: true });
  const item = validation.data.items.find(({ id, type }) => id === changeName && type === 'change');
  if (!item) throw new Error(`OpenSpec returned no validation result for ${changeName}.`);
  return { status, apply, valid: validation.success && item.valid, issues: item.issues };
}
