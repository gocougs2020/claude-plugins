# gocougs Claude plugins

Shared Claude Code plugins for gocougs2020 repositories. Turn them on once and every Claude session gets the same pre-push check.

## How a change gets checked

Every repository follows the same three steps:

1. **Before each push (Claude session):** the `pre-push` skill merges the default branch, checks other open pull requests for overlapping work, runs the repository's own checks, reviews the diff for bugs and security issues, and fixes what it finds. A hook blocks Claude's `git push` until that exact commit was checked. Your own pushes are never blocked.
2. **On the pull request (GitHub Actions):** the repository's own workflows run its lint, tests, build, and other plain checks. No AI runs in GitHub Actions.
3. **Vercel (no workflow file):** Vercel Security Review scans every push. Vercel Agent Review runs once when the pull request is marked ready.

Merge when every required check is green.

## Plugins

| Plugin | What it adds |
|---|---|
| [`review-loop`](plugins/review-loop/) | The `pre-push` skill, plus the hook that blocks Claude's `git push` until the commit was checked |
| [`web-design`](plugins/web-design/) | `design-review`, Vercel's `web-design-guidelines` (with a WCAG 2.2 AA fallback), and Vercel's `vercel-react-best-practices` |

Two official Anthropic plugins are turned on next to them:
- `security-guidance` warns about unsafe patterns while Claude edits.
- `frontend-design` guides UI building.

The `pre-push` skill also uses Claude Code's built-in `/security-review`.

## Add to a repository

1. Copy [`templates/settings.json`](templates/settings.json) to `.claude/settings.json`, or merge it into an existing one. Drop the `web-design` and `frontend-design` lines for a repository with no web UI.
2. Make sure `AGENTS.md` or `CLAUDE.md` names the repository's lint, test, and build commands, and any shared files many changes append to (route lists, config lists, API specs). The `pre-push` skill reads them. An optional `REVIEW.md` lists the repository's own risks to check.
3. Add a GitHub Actions workflow that runs those lint and test commands on pull requests, and require its checks in a branch ruleset on the default branch.
4. In Vercel, add the project to Security Review (Vercel → Agent settings → Security Review). Vercel Agent Review already covers every repository on the team.

### Cloud sessions

Cloud sessions (claude.ai/code, the mobile app) ignore the marketplaces in a repository's `.claude/settings.json`, so the plugins do not load from the repository alone. Paste [`templates/cloud-setup.sh`](templates/cloud-setup.sh) into your cloud environment's **Setup script** (environment menu → settings icon). It installs the plugins for every repository in that environment. The environment's network access must allow github.com.

This repository is public, so any session can fetch it without GitHub credentials.

## Changing a plugin

Edit the skill, raise `version` in that plugin's `.claude-plugin/plugin.json`, and run:

```bash
claude plugin validate .
```

The `Validate` workflow runs actionlint, `claude plugin validate`, and the push hook tests on every pull request. Sessions pick up the new version from the marketplace.
