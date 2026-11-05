# CLAUDE.md

This repository is a Claude Code plugin marketplace (`.claude-plugin/marketplace.json`) with plugins under `plugins/`. `README.md` explains what each plugin does and how repositories turn them on.

## Rules for changes

- Keep plugins general. Nothing here may name or depend on a specific product, repository, or design system. Repository specifics belong in that repository's `AGENTS.md`, `CLAUDE.md`, `REVIEW.md`, or `DESIGN.md`, which the skills read.
- Prefer built-in Claude Code commands and official Anthropic or Vercel skills over writing our own. Vendored third-party skills keep their license notice and source. Never edit them; replace them with a newer upstream copy.
- When you change a plugin, raise its `version` in `.claude-plugin/plugin.json`, then run `claude plugin validate .` and `claude plugin validate plugins/<name>`, and fix what they report.
- No plugin here adds AI to GitHub Actions. CI in each repository runs only that repository's plain checks; the AI checks are the `pre-push` skill (in the session) and Vercel.
- `.github/workflows/` holds only this repository's own `Validate` check. Workflows pin every action to a full commit SHA with the release in a trailing comment (`uses: owner/action@<sha> # v1.2.3`). To bump one, take the SHA of the release tag (`git ls-remote --tags https://github.com/owner/action.git`, using the `^{}` line for an annotated tag) and update the comment too.
- Test hook scripts by piping sample hook JSON into them (see `plugins/review-loop/README.md`). `.github/workflows/validate.yml` runs those tests, actionlint, and `claude plugin validate` on every pull request; keep it passing and add a case when you change the hook.
