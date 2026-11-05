# review-loop

The check Claude runs before every push, and a hook that makes sure it ran.

## `pre-push` skill

Before each push, it:

1. merges the default branch;
2. checks other open pull requests for overlapping work (renamed names, shared data, shared lists) and fixes or notes it;
3. runs the lint, test, and build commands from `AGENTS.md` or `CLAUDE.md`;
4. reviews the diff for bugs, using `REVIEW.md` when the repository has one;
5. runs the built-in `/security-review` and checks the diff for data-access and input-handling gaps;
6. fixes what it confirms, commits, and records the commit for the hook.

It also covers the pull request itself: open as a draft, mark ready once (which starts Vercel Agent Review), fix the Vercel findings in one push, and merge only when asked.

## Push hook

`hooks/require-review-before-push.sh` runs before every Bash command Claude runs. When the command pushes (`git push`, `git -C <dir> push`, or `cd <dir> && git push`), it denies the push unless `<git dir>/review-loop/reviewed` holds the current `HEAD`. The `pre-push` skill writes that file. Words like "git push" inside a string or a heredoc are not treated as a push. Pushes by people are not affected, and the hook allows every push when `GITHUB_ACTIONS` is `true`.

To test a change to it:

```bash
echo '{"cwd":"'"$PWD"'","tool_input":{"command":"git push"}}' | plugins/review-loop/hooks/require-review-before-push.sh
```

Empty output means allowed. A JSON `deny` means blocked. The `Validate` workflow runs these cases on every pull request.

## Install for yourself

To use it outside a repository that turns it on:

```
/plugin install review-loop --marketplace gocougs2020/claude-plugins
```
