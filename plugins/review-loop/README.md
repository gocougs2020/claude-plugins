# review-loop

Drives a pull request from first commit to merged, with as few paid review runs as possible.

## Skills

| Skill | Use |
|---|---|
| `steward` | The process: review and fix before each push, open a draft, mark it ready once, handle Vercel Agent, Vercel Security Review, Claude Review, and CI findings, and merge only when asked. It detects the tier from the repository's workflows. |
| `pr-overlap` | Before each push and when the default branch moves: merges it in and checks other open pull requests for overlap git does not flag (renamed names, shared data, shared lists), using any shared files the repository's `AGENTS.md` or `CLAUDE.md` lists. |
| `pr-review` | Reviews the diff against `REVIEW.md` (or general defaults), verifies each finding against the code, fixes what it confirms, and records the reviewed commit. |
| `install-review-loop` | Sets up a repository for Lite or Full, and upgrades Full's workflows. The caller workflows and a `REVIEW.md` template are in its `assets/`; the shared pipeline they call is in this repository's `.github/workflows/`. |

## Tiers

| | Lite | Full |
|---|---|---|
| Vercel Security Review (every push) and Vercel Agent (ready pull requests) | yes | yes |
| Review and fix before each push (`steward`, `pr-review`, push hook) | yes | yes |
| Claude Review on ready pull requests | no | yes |
| Who fixes findings after ready | the session that opened the pull request, when asked to watch it | the automatic fixer, up to 3 rounds |
| In the repository | `.claude/settings.json` | plus 4 short caller workflows (pipeline shared at `@v1`), `REVIEW.md`, and the `CLAUDE_CODE_OAUTH_TOKEN` secret |

## Push hook

`hooks/require-review-before-push.sh` runs before every Bash command Claude runs. When the command pushes (`git push`, `git -C <dir> push`, or `cd <dir> && git push`), it denies the push unless `<git dir>/review-loop/reviewed` holds the current `HEAD`. `pr-review` writes that file when it finishes with no 🔴 finding. The deny message tells Claude how to proceed, including when the user explicitly asked to push without review. Pushes by people are not affected, and the hook allows every push when `GITHUB_ACTIONS` is `true`, so Review Loop's fixer and `@claude` can push even when CI loads this plugin.

To test a change to it:

```bash
echo '{"cwd":"'"$PWD"'","tool_input":{"command":"git push"}}' | plugins/review-loop/hooks/require-review-before-push.sh
```

Empty output means allowed. A JSON `deny` means blocked.

## Install for yourself

To use it outside a repository that turns it on (Claude Code 2.1.275 or later):

```
/plugin install review-loop --marketplace gocougs2020/claude-plugins
```
