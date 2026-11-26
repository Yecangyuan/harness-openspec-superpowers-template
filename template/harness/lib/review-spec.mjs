import { readChange } from './openspec.mjs';

const [repoRoot, changeName] = process.argv.slice(2);

function reviewInputs() {
  const { status, apply, valid, issues } = readChange(repoRoot, changeName);
  const tracksTasks = apply.taskTrackingConfigured ?? status.artifacts.some(({ id }) => id === 'tasks');
  const emptyTasks = tracksTasks && apply.progress.total === 0;

  console.log('\nOpenSpec artifacts');
  for (const { id, status: artifactStatus, outputPath } of status.artifacts) {
    console.log(`  ${id}: ${artifactStatus} (${outputPath})`);
    const paths = status.artifactPaths?.[id]?.existingOutputPaths ?? apply.contextFiles?.[id] ?? [];
    for (const path of paths) console.log(`    ${path}`);
  }

  console.log(`\nOpenSpec validation: ${valid ? 'PASSED' : 'FAILED'}`);
  for (const issue of issues) {
    console.log(`  ${issue.level} ${issue.path}: ${issue.message}`);
  }
  if (tracksTasks) console.log(`Parsed implementation tasks: ${apply.progress.total}`);
  if (emptyTasks) console.log('  Add reviewable implementation tasks to the change.');
  if (apply.state === 'blocked') console.log(`  ${apply.instruction}`);

  if (!status.isComplete || !valid || emptyTasks || apply.state === 'blocked') {
    console.log('\nReview inputs: NEED ATTENTION');
    return 1;
  }
  console.log('\nReview inputs: AVAILABLE');
  console.log('Next: review the requirements, design and task coverage using the workflow above.');
  return 0;
}

try {
  process.exitCode = reviewInputs();
} catch (error) {
  console.error(`Cannot review ${changeName}: ${error.message}`);
  process.exitCode = 1;
}
