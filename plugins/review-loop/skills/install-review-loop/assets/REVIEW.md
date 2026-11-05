# Review instructions

These rules are for AI pull request review in this repository: the `Claude Review` workflow, the `/pr-review` skill, and the Review Loop fixer. `AGENTS.md` (or `CLAUDE.md`) is the project context. A change that breaks one of its rules is a finding.

Review for correctness first: bugs that would break production, leak data, or change behavior the PR description does not mention. Formatting and style are not findings, and neither is anything lint, the build, or the tests already enforce.

## Severity

- 🔴 **Important**: blocks merge. Use it only for:
  - incorrect logic on a reachable path;
  - an auth or data-access gap;
  - data loss or a destructive write;
  - a secret in code or logs;
  - a behavior change the PR description does not state.
- 🟡 **Nit**: worth fixing but not blocking. Report at most five per review.
- 🟣 **Pre-existing**: a real bug in code this PR touches or calls that was already there. It does not block.

Each 🔴 finding needs a concrete path: a real caller or input, the `file:line` where it goes wrong, and the wrong result. If you cannot trace it, drop it or file it as 🟡 with the open question.

## Intended behavior

Compare the diff with the PR title and description. Flag as 🔴 any user-visible or API-visible change the description does not mention. Flag as 🟡 a stated goal the diff does not do.

## Always check

<!-- Replace this section with this repository's own risks: where auth is
enforced, what data must stay separated, what sends messages or charges money,
what deploys on merge, and which tests must accompany which changes. -->

- Auth: every new or changed route or handler checks who the caller is and what they may access.
- Secrets come from the platform's secret store, never from committed files or logs.
- An error response does not return stack traces or provider error bodies.
- A retry, crash, or concurrent request cannot send twice, charge twice, or overwrite a newer write.
- A bug fix comes with a test that fails before the fix (🟡 when missing).

## Slop in the diff

Check only code this PR adds or changes. Each item is 🟡 unless it hides a defect. They count toward the five-nit cap.

- A new helper, hook, or component that duplicates one the repo already has. Name the existing one.
- Dead code the PR adds: an unused export, parameter, branch, or flag.
- Work the PR description does not ask for: an unrelated refactor, a renamed file, or a new option no caller sets.
- An abstraction with one caller and no stated second use.
- Defensive code that cannot trigger: a try/catch around code that cannot throw, or a null check on a value that is always set.
- Comments that restate the next line or describe the change.
- A test that only checks its own mocks.
- Docs longer than the change needs, or repeating another doc instead of linking to it.

## Before you report

- Search before claiming something is missing or unused. Calls often live in other files.
- Read the code that calls a changed function, and the middleware or rules in front of it, before reporting an access gap.

## Do not report

- Anything lint, the build, or the tests already enforce.
- Style, naming, or refactors of existing code that fix no defect.
- Lockfiles and generated files.
