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
- **Full** (important repositories): Lite, plus three workflows:
  - Claude Review on ready pull requests (`claude-review.yml`);
  - an automatic fixer that fixes every finding and failed check in one push, as the Claude GitHub App, for up to 3 rounds (`review-loop.yml` starts `review-loop-fix.yml`);
  - `@claude` fixes on request (`claude.yml`).

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
   - Install the Claude GitHub App on all repositories (github.com/apps/claude → Configure → All repositories). Once covers every repository.
   - Add the repository's Vercel project to Vercel Security Review (Vercel → Agent settings → Security Review). Vercel code review already covers every repository on the team.
   - A repository with no Vercel project gets no Vercel reviews.

## Full only

4. **Copy the workflows** from this skill's `assets/workflows/` into `.github/workflows/`, unchanged:
   - `claude-review.yml`
   - `review-loop.yml`
   - `review-loop-fix.yml`
   - `claude.yml`
5. **Match the repository:**
   - **CI names.** In `review-loop.yml`, set `on.workflow_run.workflows` to `Claude Review` plus the `name:` of each CI workflow the repository has.
   - **Node version.** In `claude.yml`, set `node-version` to the repository's Node version. For the fixer, tell the user to set the repository variable `REVIEW_LOOP_NODE_VERSION` if it is not 22.
   - **Existing files.** If the repository already has a workflow with one of these names, compare it with the asset, keep its repository-specific lines, and say what you changed.
6. **Write `REVIEW.md`** from `assets/REVIEW.md`. Replace the "Always check" section with the repository's real risks: read its auth, data access, payment or messaging code, deploy setup, and test layout first. Keep it short; generic advice belongs in the `pr-review` skill, not here.
7. **Add one line** to `AGENTS.md` or `CLAUDE.md`: "Pull requests follow Review Loop Full (steward skill from the review-loop plugin)."
8. **Tell the user what only they can do:**
   - Add the repository secret `CLAUDE_CODE_OAUTH_TOKEN` under Settings → Secrets and variables → Actions, from `claude setup-token`. Personal accounts cannot share secrets, so each Full repository needs its own. Do not also set `ANTHROPIC_API_KEY` unless they want per-token API billing.
   - The workflows start working only after the install pull request merges, because `workflow_run` and `check_run` use the default branch's copy.
   - After that, on the first pull request marked ready, check that a "Review Loop" run appears once the checks finish. On the first fix round, check that the push came from the Claude app and started CI again.

## Upgrading

To upgrade a repository's workflows, diff its copies against `assets/workflows/` and apply the changes, keeping the lines step 5 changed. Plugin skills update on their own through the marketplace.
