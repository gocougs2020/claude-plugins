# gocougs Claude plugins

Shared Claude Code plugins for gocougs2020 repositories. Turn them on in a repository with one settings file, and every Claude session there gets the same review, fix, and design workflow.

| Plugin | What it adds |
|---|---|
| [`review-loop`](plugins/review-loop/) | `steward` (draft → review before each push → ready once → fix findings → merge when asked), `pr-overlap` (catch overlap with other open pull requests), `pr-review` (review and fix against the repo's `REVIEW.md`), `install-review-loop` (sets up a repository), and a hook that blocks `git push` until the pushed commit was reviewed |
| [`web-design`](plugins/web-design/) | `design-review`, Vercel's `web-design-guidelines` (with a WCAG 2.2 AA fallback), and Vercel's `vercel-react-best-practices` |

Two official Anthropic plugins are turned on next to them:
- `security-guidance` warns about unsafe patterns while Claude edits.
- `frontend-design` guides UI building.

## Add to a repository

Copy [`templates/settings.json`](templates/settings.json) to `.claude/settings.json` in the repository, or merge it into an existing one. Drop the `web-design` and `frontend-design` lines for a repository with no web UI.

The easier way is to open a Claude session that has this repository and the target repository, and say:

> Install Review Loop Lite in owner/repo

or `Full` for an important repository. The `install-review-loop` skill does the rest and lists the steps only you can do. Lite needs nothing else in the repository. Full adds GitHub workflows and one secret.

This repository is public, so any session can fetch the marketplace without GitHub credentials. Review Loop Full still needs the Claude GitHub App on each repository that uses it, because its fixer pushes as the app.

### Cloud sessions

Cloud sessions (claude.ai/code, the mobile app) ignore the marketplaces a repository's `.claude/settings.json` declares, so the plugins do not load there from the repository alone. Paste [`templates/cloud-setup.sh`](templates/cloud-setup.sh) into your cloud environment's **Setup script** (claude.ai/code → environment selector → settings icon). It installs the plugins at user scope before Claude starts, for every repository in that environment.

## Shared workflows

The CI review lives here once, as reusable workflows in [`.github/workflows/`](.github/workflows/). Each repository has four short caller files that point at them (`@main`), so an improvement here reaches every repository on its next pull request:

| Shared workflow | What it does |
|---|---|
| `claude-review.yml` | Reviews the diff of ready pull requests on a cheaper model (`claude-sonnet-5-5` by default; callers can pick `claude-haiku-5-5`). Skips docs-only changes. Fails while a 🔴 finding is open. |
| `review-loop.yml` | After all checks finish, starts the fixer if a check failed or Vercel Agent left new comments. |
| `review-loop-fix.yml` | Fixes every open finding and failed check in one push, up to 3 rounds. |
| `claude.yml` | Answers `@claude` in PR and issue comments. |

Vercel Agent and Vercel Security Review run alongside, from Vercel's side, with no workflow.

## Built-in commands the workflow uses

These ship with Claude Code, so nothing here copies them:
- `/simplify`: cleanup of the session's own changes.
- `/security-review`: security-only review of the branch.
- `/code-review`: general review, with `--fix` to apply fixes.

## Changing a plugin

Edit the skill, raise `version` in that plugin's `.claude-plugin/plugin.json`, and run:

```bash
claude plugin validate .
```

Sessions pick up the new version from the marketplace. A change to a shared workflow reaches every repository automatically. A change to a caller template needs each repository's caller updated.
