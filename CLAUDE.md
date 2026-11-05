# CLAUDE.md

This repository is a Claude Code plugin marketplace (`.claude-plugin/marketplace.json`) with plugins under `plugins/`. `README.md` explains what each plugin does and how repositories turn them on.

## Rules for changes

- Keep plugins general. Nothing here may name or depend on a specific product, repository, or design system. Repository specifics belong in that repository's `AGENTS.md`, `CLAUDE.md`, `REVIEW.md`, or `DESIGN.md`, which the skills read.
- Prefer built-in Claude Code commands and official Anthropic or Vercel skills over writing our own. Vendored third-party skills keep their license notice and source. Never edit them; replace them with a newer upstream copy.
- When you change a plugin, raise its `version` in `.claude-plugin/plugin.json`, then run `claude plugin validate .` and `claude plugin validate plugins/<name>`, and fix what they report.
- A change to a workflow in `plugins/review-loop/skills/install-review-loop/assets/workflows/` reaches a repository only when someone upgrades its copy. Say so in the commit message.
- Test hook scripts by piping sample hook JSON into them (see `plugins/review-loop/README.md`).
