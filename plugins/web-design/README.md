# web-design

General web interface, accessibility, and React/Next.js performance practice. It is not tied to any product or design system: `design-review` reads the repository's own `DESIGN.md`, tokens, and components first, and those rules win.

| Skill | Source | Use |
|---|---|---|
| `design-review` | ours | Runs the two skills below on the UI files a change touches, checks consistency with the repository's design system and responsive layout, then fixes what it confirms. `steward` runs it before a push that changes UI. |
| `web-design-guidelines` | Vercel ([web-interface-guidelines](https://github.com/vercel-labs/web-interface-guidelines)) | Fetches Vercel's current guidelines each run. Has a WCAG 2.2 AA fallback checklist for when the fetch fails. |
| `vercel-react-best-practices` | Vercel ([agent-skills](https://github.com/vercel-labs/agent-skills)), MIT, vendored unchanged | 45 React and Next.js performance rules by priority. See its `NOTICE.md`. |

Anthropic's official `frontend-design` plugin, turned on next to this one in `templates/settings.json`, covers building new interfaces.

## Install for yourself

To use it outside a repository that turns it on (Claude Code 2.1.275 or later):

```
/plugin install web-design --marketplace gocougs2020/claude-plugins
```
