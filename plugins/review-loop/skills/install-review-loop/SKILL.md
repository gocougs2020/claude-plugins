---
name: install-review-loop
description: Install Review Loop in a repository. Lite needs only Vercel and the shared Claude plugins. Full adds Claude Review and the automatic fixer as GitHub workflows. Use when asked to add, install, set up, or upgrade Review Loop, the review workflow, or the Claude plugins in a repository.
---

# Install Review Loop

Review Loop is how a pull request gets reviewed and fixed until it is green.

- **Lite** (most repositories):
  - Vercel Security Review on every push, and Vercel Agent code review on ready pull requests.
  - The session that opened the pull request watches it and fixes findings (`steward` skill).
  - No workflows and no secrets in the repository.
- **Full** (important repositories): Lite, plus four small caller workflows that run the shared pipeline in `gocougs2020/claude-plugins/.github/workflows/` at `@v1`:
  - Claude Review on ready pull requests (`claude-review.yml`);
  - an automatic fixer that fixes every finding and failed check in one push, as the Claude GitHub App, for up to 3 rounds (`review-loop.yml` starts `review-loop-fix.yml`);
  - `@claude` fixes on request (`claude.yml`).

  The pipeline itself (prompts, checks, pins) lives only in this repository, so a change here reaches every Full repository when the `v1` tag moves, with no copy to update.

Ask which tier when the user did not say. Do every step in one draft pull request in the target repository, then follow the `steward` skill for it.

## Both tiers

1. **Turn on the plugins.** Create or merge `.claude/settings.json` with the content of `templates/settings.json` from the `gocougs2020/claude-plugins` repository.
   - Keep any settings already there.
   - Drop the `web-design` and `frontend-design` lines for a repository with no web UI.
2. **Project rules.** Make sure an `AGENTS.md` or `CLAUDE.md` exists and names:
   - the repository's lint, test, and build commands;
   - the shared files many changes append to (route registration, config and secret lists, API specs, migrations or indexes), for `pr-overlap`.

   Add a short section for anything missing. Do not rewrite an existing file.
3. **Tell the user what only they can do:**
   - For Full, install the Claude GitHub App on the repository (github.com/apps/claude → Configure). The plugin marketplace is public, so Lite needs no app access to it.
   - Add the repository's Vercel project to Vercel Security Review (Vercel → Agent settings → Security Review). Vercel code review already covers every repository on the team.
   - A repository with no Vercel project gets no Vercel reviews.

## Full only

4. **Copy the caller workflows** from this skill's `assets/workflows/` into `.github/workflows/`:
   - `claude-review.yml`
   - `review-loop.yml`
   - `review-loop-fix.yml`
   - `claude.yml`

   Keep the job ids (`review`, `review-loop`, `review-loop-fix`, `claude`): the gate skips its own checks by the `review-loop` prefix, and the required check is named `review / review`.
5. **Match the repository** in the callers, not in the shared workflows:
   - **CI names.** In `review-loop.yml`, set `on.workflow_run.workflows` to `Claude Review` plus the `name:` of each CI workflow the repository has. If there are none, it is just `["Claude Review"]`; then the fixer's checks are its only test run, so the `AGENTS.md` commands matter more.
   - **Node version.** In `claude.yml`, set `node_version`. For the fixer, add `node_version: "<version>"` under `with:` in `review-loop-fix.yml` (or set the repository variable `REVIEW_LOOP_NODE_VERSION`) if it is not 22.
   - **Tools for `@claude`.** To narrow what `@claude` may run, pass `allowed_tools` in `claude.yml` with the repository's own commands.
   - **Plugins in CI (optional).** Pass `plugin_marketplaces` (Git URLs, one per line) and `plugins` (`name@marketplace`, one per line) to `claude-review.yml` to let the review use extra review skills, for example `https://github.com/gocougs2020/claude-plugins.git` and `web-design@gocougs` for a repository with UI.
   - **Package manager.** The shared workflows run `corepack enable`, so pnpm and yarn work when `package.json` has a `packageManager` field. If the repository uses pnpm or yarn without that field, add it (for example `"packageManager": "pnpm@10.0.0"`, matching the lockfile).
   - **Existing files.** If the repository already has a workflow with one of these names, replace it with the caller, move its repository-specific lines into the caller's inputs, and say what you changed.
6. **Write `REVIEW.md`** from `assets/REVIEW.md`. Replace the "Always check" section with the repository's real risks: read its auth, data access, payment or messaging code, deploy setup, and test layout first. Keep it short; generic advice belongs in the `pr-review` skill, not here.
7. **Add one line** to `AGENTS.md` or `CLAUDE.md`: "Pull requests follow Review Loop Full (steward skill from the review-loop plugin)."
8. **Tell the user what only they can do:**
   - Add the repository secret `CLAUDE_CODE_OAUTH_TOKEN` under Settings → Secrets and variables → Actions, from `claude setup-token`. Personal accounts cannot share secrets, so each Full repository needs its own. Do not also set `ANTHROPIC_API_KEY` unless they want per-token API billing.
   - The workflows start working only after the install pull request merges, because `workflow_run` and `check_run` use the default branch's copy.
   - If the repository had the old `review` required check (from full-copy workflows), change it to `review / review` in the branch ruleset in the same merge, or every pull request waits on a check that never reports.
   - After that, on the first pull request marked ready, check that a "Review Loop" run appears once the checks finish. On the first fix round, check that the push came from the Claude app and started CI again.

## Upgrading

Callers pin `@v1`, a tag in `gocougs2020/claude-plugins` that is moved to a tested commit on `main` (see the README's "Releasing workflows"). Changes within `v1` reach every Full repository on their own. A breaking change (a renamed input, a new required secret or permission, a renamed job) ships as `v2`; upgrade a repository by diffing its callers against `assets/workflows/`, applying the changes, and keeping the lines step 5 changed. Plugin skills update on their own through the marketplace.

A repository with the older full-copy workflows (long files with the prompts inline) upgrades by replacing them with the callers as in steps 4 and 5, and renaming the required check `review` to `review / review`.
