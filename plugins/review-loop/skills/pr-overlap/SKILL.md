---
name: pr-overlap
description: Check other open and just-merged pull requests for work that overlaps this branch, and handle it before pushing. Overlap means the same files, renamed or removed names, shared data shapes, routes, settings, or lists. Read it when starting work on a branch, before each push, and whenever another pull request merges into the default branch.
---

# Checking for overlap with other pull requests

When several sessions or people work on a repository at once, two branches can each pass CI and still break the default branch once both land:

- one renames a helper the other calls;
- both add the same database field with different meanings;
- both append to the same list.

Git reports a conflict only when the same lines change. This skill catches the rest.

Run it:

- when you start work on a branch, so you build on what is already in flight;
- before every push (the first step of the `steward` skill's "Before every push");
- when you learn another pull request merged into the default branch.

## 1. Bring in what already merged

```bash
git fetch origin <default-branch>
git log --oneline HEAD..origin/<default-branch>
```

When that lists commits, merge them now with `git merge origin/<default-branch>`. Never rebase or force-push a branch that is already pushed. Then:

- Check the merged changes against this branch as in step 3, not only the conflict markers.
- Run the checks the project rules (`AGENTS.md` or `CLAUDE.md`) name again.
- Regenerate lockfiles with the package manager instead of merging them by hand.

## 2. List what is still open

List the open pull requests against the default branch, and the files each one changes. Skip this branch's own pull request.

- **Cloud session**: use the GitHub MCP tools: `list_pull_requests`, then `pull_request_read` with the files or diff method.
- **Local**: `gh pr list --base <default-branch> --json number,title,headRefName,files`.

If there are none, skip to step 4.

Compare those files with this branch's files:

```bash
git diff --name-only origin/<default-branch>...HEAD
```

## 3. Look for overlap

For each other pull request that shares a file or an area, read its diff for those files. File names alone miss most real overlap, so also check names across the whole repository:

- **Names this branch renames or removes**: functions, exports, components, database fields, route paths, cache or query keys, store fields, environment or secret names. Search the other pull requests' diffs for the old name. If one still uses it, it will break once both merge.
- **Names another pull request renames or removes** that this branch uses or adds new calls to.
- **Shared data**: the same table, collection, or field written with a different shape or meaning; the same new index or migration; access rules changed on the same path.
- **Shared lists and registries**: files many features append to, such as route registration, config and secret lists, API specs, docs indexes, and package scripts. Two additions there usually merge cleanly but can duplicate an entry or break ordering. Check every file the project rules list as shared, if they list any.
- **Same behavior built twice**: both add a helper or setting that does the same job. Prefer reusing the one that merges first.

## 4. Act on it

- **Already on the default branch**: fix this branch now (update the calls, reuse the helper, match the data shape) and include it in this push.
- **Still open in another pull request**: do not push to or comment on that pull request unless the user asks. Keep this branch correct against the default branch as it is.
  - When this branch renames or removes something the other uses, keep the old name working (a re-export or alias) when that costs little.
  - Otherwise say which pull request should merge first.
- **Record it**:
  - Add one line per overlap to this pull request's description, for example: `Overlaps with owner/repo#41 in src/billing/send.js: both change sendBulk; merge #41 first`.
  - Tell the user the same in your summary, including what the second one to merge will need to do.
- **No overlap**: say nothing, and do not add an empty overlap section to the description.

When the other pull request merges later, step 1 brings it in. Check the overlap lines you recorded then.
