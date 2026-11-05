#!/usr/bin/env bash
# PreToolUse hook for Bash. When the command runs `git push`, deny it unless
# the pre-push skill recorded the current HEAD in
# <git dir>/review-loop/reviewed. Any other command passes through.
set -uo pipefail

input=$(cat)

# CI jobs push without a local pre-push stamp,
# so the hook only guards interactive sessions.
if [ "${GITHUB_ACTIONS:-}" = "true" ]; then
  exit 0
fi

# Only act on commands that push. Matches `git push` and `git -C <dir> push`.
if ! grep -Eq '("|[;&|(]|\\n)[[:space:]]*(cd +[^ ;&|"]+ *&& *)?git( +-C +[^ ]+)? +push( |"|$|\\n)' <<<"$input"; then
  exit 0
fi

# Work out which repository the push runs in: the session's cwd, then a
# leading `cd <dir> &&`, then `git -C <dir>`.
dir="."
if [[ "$input" =~ \"cwd\":\ *\"([^\"]+)\" ]]; then
  dir="${BASH_REMATCH[1]}"
fi
if [[ "$input" =~ cd\ +([^\ \;\&\"]+)\ *\&\& ]]; then
  case "${BASH_REMATCH[1]}" in
    /*) dir="${BASH_REMATCH[1]}" ;;
    *) dir="$dir/${BASH_REMATCH[1]}" ;;
  esac
fi
if [[ "$input" =~ git\ +-C\ +([^\ \"]+)\ +push ]]; then
  case "${BASH_REMATCH[1]}" in
    /*) dir="${BASH_REMATCH[1]}" ;;
    *) dir="$dir/${BASH_REMATCH[1]}" ;;
  esac
fi

head=$(git -C "$dir" rev-parse HEAD 2>/dev/null) || exit 0
git_dir=$(git -C "$dir" rev-parse --absolute-git-dir 2>/dev/null) || exit 0
stamp="$git_dir/review-loop/reviewed"

if [ -f "$stamp" ] && [ "$(tr -d '[:space:]' < "$stamp")" = "$head" ]; then
  exit 0
fi

reason="Review before pushing: HEAD ${head:0:7} has not been reviewed. Run the pre-push skill (merge the default branch, check overlapping pull requests, run the checks, review for bugs and security, fix, commit); it records HEAD in ${stamp}. Then push again. Only if the user explicitly said to push without review, write HEAD to that file yourself and say so."
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"%s"}}\n' "${reason//\"/\\\"}"
exit 0
