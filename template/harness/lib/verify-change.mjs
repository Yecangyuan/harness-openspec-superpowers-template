import { createHash } from 'node:crypto';
import { readFileSync } from 'node:fs';
import { parseArgs } from 'node:util';
import { readChange, runOpenSpec } from './openspec.mjs';

const [repoRoot, ...args] = process.argv.slice(2);
const usage = 'Usage: ./harness/bin/opsx verify [--change <name> [--evidence <file>]]';

function acceptanceCases(changeName, deltas) {
  return deltas.flatMap((delta, deltaIndex) => {
    const requirement = delta.requirement ?? delta.requirements?.[0];
    const scenarios = requirement?.scenarios?.length ? requirement.scenarios : [null];
    return scenarios.map((scenario, scenarioIndex) => {
      const details = scenario?.rawText ?? requirement?.text ?? delta.description;
      const id = createHash('sha256').update(JSON.stringify([
        changeName, deltaIndex, scenarioIndex, delta.spec, delta.operation,
        delta.description, requirement?.name, requirement?.text, scenario?.name, details,
      ])).digest('hex').slice(0, 12);
      return { id, delta, requirement, scenario, details };
    });
  });
}

function readEvidence(path, cases) {
  if (!path) return {};
  const evidence = JSON.parse(readFileSync(path, 'utf8'));
  if (!evidence || typeof evidence !== 'object' || Array.isArray(evidence)) {
    throw new Error('Evidence must be a JSON object keyed by scenario ID.');
  }

  const validIds = new Set(cases.map(({ id }) => id));
  for (const [id, entry] of Object.entries(evidence)) {
    if (!validIds.has(id)) throw new Error(`Unknown evidence ID ${id}. Refresh the change report.`);
    if (entry?.status !== 'passed' && entry?.status !== 'failed') {
      throw new Error(`Evidence ${id} needs a status of passed or failed.`);
    }
    for (const field of ['implementation', 'check', 'result']) {
      if (typeof entry[field] !== 'string' || !entry[field].trim()) {
        throw new Error(`Evidence ${id} needs a non-empty ${field}.`);
      }
    }
  }
  return evidence;
}

function verifyChange(changeName, evidencePath) {
  const { status, apply, valid, issues } = readChange(repoRoot, changeName);

  // OpenSpec 1.x needs proposal.md before it can show even a partial change.
  const proposal = status.artifacts.find(({ id }) => id === 'proposal');
  let cases = [];
  let deltaError;
  if (!proposal || proposal.status === 'done') {
    try {
      const { data } = runOpenSpec(repoRoot, [
        'show', '--type', 'change', '--deltas-only', '--json', '--no-interactive', '--', changeName,
      ]);
      cases = acceptanceCases(changeName, data.deltas);
    } catch (error) {
      deltaError = error.message;
    }
  }
  const evidence = deltaError ? {} : readEvidence(evidencePath, cases);

  console.log('HARNESS VERIFY CHANGE');
  console.log(`Change: ${changeName}`);
  console.log(`\nOpenSpec artifacts: ${status.isComplete ? 'complete' : 'incomplete'}`);
  for (const artifact of status.artifacts) {
    console.log(`  ${artifact.id}: ${artifact.status} (${artifact.outputPath})`);
  }
  console.log(`OpenSpec validation: ${valid ? 'PASSED' : 'FAILED'}`);
  for (const issue of issues) {
    console.log(`  ${issue.level} ${issue.path}: ${issue.message}`);
  }

  console.log(`\nImplementation tasks: ${apply.progress.complete}/${apply.progress.total} complete`);
  for (const task of apply.tasks.filter(({ done }) => !done)) {
    console.log(`  Pending: ${task.description}`);
  }
  if (apply.state === 'blocked') console.log(`  ${apply.instruction}`);

  console.log('\nAcceptance evidence');
  if (deltaError) {
    console.log(`  Could not read spec deltas: ${deltaError}`);
  } else if (!cases.length) {
    console.log('  No spec deltas available for review.');
  }
  const counts = { passed: 0, failed: 0, unverified: 0 };
  for (const { id, delta, requirement, scenario, details } of cases) {
    const entry = evidence[id];
    const result = entry?.status ?? 'unverified';
    counts[result] += 1;
    const title = [delta.spec, delta.operation, requirement?.name, scenario?.name].filter(Boolean);
    console.log(`[${result.toUpperCase()}] ${id} ${title.join(' / ')}`);
    if (scenario && requirement?.text && !requirement.name) {
      console.log(`  Requirement: ${requirement.text.replaceAll('\n', ' ')}`);
    }
    console.log(`  ${details.replaceAll('\n', '\n  ')}`);
    if (entry) {
      console.log(`  Implementation: ${entry.implementation}`);
      console.log(`  Check: ${entry.check}`);
      console.log(`  Result: ${entry.result}`);
    }
  }
  console.log(`\n${counts.passed} passed, ${counts.failed} failed, ${counts.unverified} unverified`);

  if (!status.isComplete || !valid || deltaError || apply.state === 'blocked' ||
      apply.progress.remaining || counts.failed) {
    console.log('Archive readiness: BLOCKED');
    return 1;
  }
  if (!apply.progress.total || !cases.length || counts.unverified) {
    if (!apply.progress.total) console.log('No implementation tasks available for verification.');
    console.log('Archive readiness: UNVERIFIED');
    return 2;
  }
  console.log('Archive readiness: READY');
  return 0;
}

let requestedChange;
try {
  const { values } = parseArgs({
    args,
    options: {
      change: { type: 'string' },
      evidence: { type: 'string' },
      help: { type: 'boolean', short: 'h' },
    },
  });
  if (values.help) {
    console.log(usage);
  } else if (!values.change?.trim() || values.evidence === '') {
    throw new Error(usage);
  } else {
    requestedChange = values.change;
    process.exitCode = verifyChange(requestedChange, values.evidence);
  }
} catch (error) {
  console.error(requestedChange ? `Cannot verify ${requestedChange}: ${error.message}` : error.message);
  process.exitCode = 1;
}
