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

The marketplace lives in this private repository. Cloud sessions reach it through the Claude GitHub App, so install the app on all repositories (github.com/apps/claude → Configure → All repositories). Local sessions use your own git credentials.

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

Sessions pick up the new version from the marketplace. Repositories with Review Loop Full keep their own copies of the workflows, so a workflow change also needs the `install-review-loop` skill's "Upgrading" step in each of them.
