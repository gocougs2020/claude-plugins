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

or `Full` for an important repository. The `install-review-loop` skill does the rest and lists the steps only you can do. Lite needs nothing else in the repository. Full adds four short caller workflows and one secret.

This repository is public, so any Claude session (cloud or local) can fetch the marketplace without GitHub credentials or extra repository access. Review Loop Full still needs the Claude GitHub App on each repository that uses it, because its fixer pushes as the app.

### Cloud sessions

Cloud sessions (claude.ai/code, the mobile app) ignore the marketplaces a repository's `.claude/settings.json` declares, so the plugins do not load there from the repository alone. Paste [`templates/cloud-setup.sh`](templates/cloud-setup.sh) into your cloud environment's **Setup script** (claude.ai/code → environment selector → settings icon). It installs the plugins at user scope before Claude starts, for every repository in that environment. If the setup finishes quickly, later sessions start from a snapshot without running it again.

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

Sessions pick up the new version from the marketplace.

## Shared CI workflows

Review Loop Full's pipeline lives here, in [`.github/workflows/`](.github/workflows/), as reusable workflows (`on: workflow_call`):

| Workflow | Called by the repository's | Does |
|---|---|---|
| `claude-review.yml` | `claude-review.yml` | Claude Review of a ready pull request against `REVIEW.md`; fails while a 🔴 finding is open |
| `review-loop-gate.yml` | `review-loop.yml` | When every check on a ready head has finished, starts the fixer if anything failed or Vercel commented |
| `review-loop-fix.yml` | `review-loop-fix.yml` | Fixes every open finding and failed check in one push, as the Claude GitHub App |
| `claude-mention.yml` | `claude.yml` | `@claude` on a pull request or issue |

Each repository keeps only the callers from [`install-review-loop/assets/workflows/`](plugins/review-loop/skills/install-review-loop/assets/workflows/): its triggers, its CI workflow names, its secrets, and a few inputs. They call `@v1`, so a change here reaches every repository when `v1` moves, and not before. These workflows never run in this repository.

Useful caller inputs: `model` on any of them (empty keeps claude-code-action's default), `skip_docs_only` on the review (default `true`: a pull request that changes only Markdown, text, or lockfiles passes without a review; set `false` where Markdown is code, such as prompts), `plugin_marketplaces` and `plugins` to load review skills in CI.

The callers pass `CLAUDE_CODE_OAUTH_TOKEN` (or `ANTHROPIC_API_KEY`) explicitly, since `secrets: inherit` only crosses repositories inside one organization or enterprise. Each job's check is named `<caller job> / <shared job>`, so the review's required check is `review / review`.

### Releasing workflows

1. Merge the change to `main`.
2. Try it from one repository first: point that repository's caller at the new commit SHA (`...@<sha>`) on a test pull request, and check a review run, a fix round, and an `@claude` run.
3. Move the tag:

   ```bash
   git fetch origin main && git tag -f v1 origin/main && git push -f origin v1
   ```

A breaking change (renamed input or job, new required secret or permission) gets a new major tag (`v2`), and repositories move to it with the `install-review-loop` skill's "Upgrading" step.
