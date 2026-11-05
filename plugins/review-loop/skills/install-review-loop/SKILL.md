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
   - For Full, install the Claude GitHub App on the repository (github.com/apps/claude → Configure). The plugin marketplace is public, so Lite needs no app access to it.
   - Add the repository's Vercel project to Vercel Security Review (Vercel → Agent settings → Security Review). Vercel code review already covers every repository on the team.
   - A repository with no Vercel project gets no Vercel reviews.

## Full only

The review, gate, fixer, and `@claude` workflows live once in this repository's `.github/workflows/` as reusable workflows. A repository gets thin caller files that point at them, so changing a shared workflow updates every repository on its next pull request event. Nothing is copied.

4. **Add the callers** from this skill's `assets/workflows/` into `.github/workflows/`:
   - `claude-review.yml`
   - `review-loop.yml`
   - `review-loop-fix.yml`
   - `claude.yml`
5. **Match the repository** (edit only the callers):
   - **CI names.** In `review-loop.yml`, set `on.workflow_run.workflows` to `Claude Review` plus the `name:` of each CI workflow the repository has. With no CI workflows, it is just `["Claude Review"]`, and the `AGENTS.md` commands matter more because the fixer's checks are the only test run.
   - **Node version.** In `review-loop-fix.yml` and `claude.yml`, set `node_version` to the repository's Node version.
   - **Model.** The review runs on `claude-sonnet-5-5`. For a low-risk repository, uncomment `model: claude-haiku-5-5` in `claude-review.yml` to cut cost further.
   - **Package manager.** The shared workflows run `corepack enable`, so pnpm and yarn work when `package.json` has a `packageManager` field. If the repository uses pnpm or yarn without that field, add it (for example `"packageManager": "pnpm@10.0.0"`, matching the lockfile).
   - **Existing files.** If the repository already has full copies of these workflows, replace them with the callers, carry any repository-specific values into the caller inputs, and say what you changed.
6. **Write `REVIEW.md`** from `assets/REVIEW.md`. Replace the "Always check" section with the repository's real risks: read its auth, data access, payment or messaging code, deploy setup, and test layout first. Keep it short; generic advice belongs in the `pr-review` skill, not here. Keep an existing `REVIEW.md`.
7. **Add one line** to `AGENTS.md` or `CLAUDE.md`: "Pull requests follow Review Loop Full (steward skill from the review-loop plugin)."
8. **Tell the user what only they can do:**
   - Add the repository secret `CLAUDE_CODE_OAUTH_TOKEN` under Settings → Secrets and variables → Actions, from `claude setup-token`. Personal accounts cannot share secrets, so each Full repository needs its own. Do not also set `ANTHROPIC_API_KEY` unless they want per-token API billing.
   - The callers start working only after the install pull request merges, because `workflow_run` and `check_run` use the default branch's copy.
   - Make `review / review` and the CI jobs required checks in a branch ruleset for the default branch.
   - After that, on the first pull request marked ready, check that a "Review Loop" run appears once the checks finish. On the first fix round, check that the push came from the Claude app and started CI again.

## Upgrading

Shared workflow changes need no per-repository step: callers use `@main`. Only a change to a caller template (new trigger, new input) needs each repository's caller updated. To roll a shared change out more carefully, point callers at a tag instead of `@main`.

## Cloud sessions

Cloud sessions (claude.ai/code) ignore the marketplaces in `.claude/settings.json`, so these plugins do not load there from the repository alone. Tell the user once to paste `templates/cloud-setup.sh` from `gocougs2020/claude-plugins` into their cloud environment's setup script. It covers every repository in that environment.
