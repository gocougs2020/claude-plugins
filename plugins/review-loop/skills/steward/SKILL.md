---
name: steward
description: How to drive a pull request to green and merged. Covers opening it as a draft, reviewing and fixing before each push, pushing in batches, and marking it ready once. It also covers handling Vercel Agent, Vercel Security Review, Claude Review, and CI findings, and merging only when asked. Read it when opening, pushing to, watching, or merging a pull request.
---

# Driving a pull request to green

Repository rules come first: `AGENTS.md` or `CLAUDE.md`, and `REVIEW.md` when the repository has one. This skill is the process around them.

## Which tier this repository uses

Check `.github/workflows/` once per session:

| What you find | Tier | Who fixes review findings after the pull request is ready |
|---|---|---|
| `review-loop.yml` and `review-loop-fix.yml` | **Full** | Review Loop's fixer, automatically. You wait, and take over only when it stops. |
| neither | **Lite** | You, when the user asked you to watch the pull request. |

Reviewers that run on the repository:

| Reviewer | Runs on |
|---|---|
| Vercel Security Review | every push, draft or not; it reads only that push's diff |
| Vercel Agent code review | marking the pull request ready, then every push to it; drafts are skipped |
| Claude Review (`claude-review.yml`, Full only) | marking the pull request ready, then every push to it; drafts are skipped |

Each one is metered per run, so fewer pushes after ready means less cost.

## Before every push

Commit locally as you go, and push in batches, not after each small fix.

1. Merge the default branch, so you review and test what will merge.
2. Run the checks `AGENTS.md` or `CLAUDE.md` names for what you changed: lint, tests, and a build when routes or bundling changed.
3. Run `/simplify` on your changes to remove duplication, dead code, and needless abstraction.
4. When the change touches auth, permissions, secrets, input handling, or data access, run `/security-review` and fix what it confirms.
5. When the change touches UI and the `design-review` skill is available (web-design plugin), run it and let it fix what it finds.
6. Commit, then run the `pr-review` skill last. It fixes what it finds, reruns the checks, commits, and records the reviewed commit.
7. Push. The review-loop plugin blocks `git push` until `pr-review` has recorded the exact commit you are pushing, so any change after step 6 needs another `pr-review`. Name any setup outside the repository (a secret, a scheduled job, a console setting) in the commit message.

## Open it as a draft

Create the pull request as a draft (`create_pull_request` with `draft: true`). Claude Review and Vercel Agent wait until it is ready, so the review in "Before every push" is the only one a draft gets.

If the pull request was opened ready, for example from the app's Create PR button, the reviews have already started. Leave it ready when the work is final. Convert it to a draft only if more work is coming.

## Mark it ready once

Mark it ready (`update_pull_request` with `draft: false`) only when all of these hold:

- the work the user asked for is done;
- the last push passed "Before every push";
- CI is green on it.

To make a further change after that, convert it back to a draft first. On Full, that also pauses Review Loop.

## After it is ready

**Full:** Review Loop owns fixes and failed checks.
- When the reviews and checks finish, it fixes every finding and failed check in one push.
- It records each round in a PR comment containing `<!-- review-loop:handled`, and repeats until clean, for at most 3 rounds.
- Do not fix findings or failed checks yourself while it runs, or you will push over each other.
- Take over only when it posts `<!-- review-loop:stopped`, when a round says it did not finish, or when the user asks. Add the `review-loop:off` label first.

**Lite, or Full after you take over:**
1. Collect the open findings on the current head:
   - Vercel Agent and Vercel Security Review comments from `vercel[bot]`;
   - Claude Review comments containing `<!-- claude-review -->`;
   - failed checks.
2. Verify each finding against the code. Trace it to a real `file:line` before you change anything.
3. Fix the real ones together and push once.
4. Reply once on each thread: what the fix changed, or the traced reason it is not a bug.
5. Never skip, disable, or weaken a test to get green.

When the default branch moves, merge it in with your next push. Push for it on its own only when there is a conflict.

## Merging

Never approve a pull request. Merge only when the user asked you to in this session (for example, "merge it when it's green"), and only when every one of these holds on the head:

- every check has finished, including the Vercel and Claude reviews, and none failed;
- on Full, no `Review Loop` or `Review Loop Fix` run is queued or in progress (check the repository's recent Actions runs after the last check finishes);
- every review thread from this head has a fix or a reply;
- there is no merge conflict.

Merge with `merge_pull_request`. If the user did not ask you to merge, tell them it is ready for their review.
