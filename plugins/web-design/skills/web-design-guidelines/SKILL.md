---
name: web-design-guidelines
description: Review UI code against Vercel's Web Interface Guidelines and WCAG 2.2 AA accessibility. Use when asked to review UI, check accessibility, audit design or UX, or check a site against best practices, and as part of design-review.
metadata:
  source: vercel-labs/web-interface-guidelines
  argument-hint: <file-or-pattern>
---

# Web Interface Guidelines

Review UI files against Vercel's Web Interface Guidelines, which are fetched fresh each time.

## How it works

1. **Fetch the guidelines** with WebFetch from `https://raw.githubusercontent.com/vercel-labs/web-interface-guidelines/main/command.md`. The fetched file has the rules and the output format.
2. **Read the files** you were given. With no files given, review the UI files the current branch changes. If there are none, ask which files.
3. **Check every rule** from the fetched guidelines.
4. **Report** in the guidelines' terse `file:line` format.

If the fetch fails (no network, or the host is blocked), say so in one line and use the checklist below instead.

## Fallback checklist

Use this only when the guidelines cannot be fetched. It follows WCAG 2.2 AA and common interface practice.

**Keyboard and focus**
- Every interactive element works with the keyboard, in a logical tab order. There is no `tabIndex` greater than 0.
- Focus is always visible (`:focus-visible`), and is never removed without a replacement.
- Dialogs and menus trap focus while open, close on Escape, and return focus to the trigger.
- A skip link or landmark structure lets keyboard users bypass repeated navigation.

**Semantics and names**
- Buttons are `<button>` and links are `<a href>`. There is no clickable `<div>`.
- Every control has an accessible name:
  - a visible `<label>`;
  - `aria-label` on an icon-only button;
  - `alt` on a meaningful image, and `alt=""` on a decorative one.
- Headings go in order, and the page has one `<h1>`.
- ARIA only where native HTML cannot express it. Roles and states match behavior (`aria-expanded`, `aria-pressed`, `aria-current`).

**Forms**
- Inputs use the right `type`, `autocomplete`, and `inputmode`.
- Errors appear next to the field, are tied to it with `aria-describedby`, and are announced. They are not shown by color alone.
- Submit is not blocked without saying why, and a double submit is prevented while a request is pending.

**Color, contrast, and motion**
- Text contrast is at least 4.5:1, and 3:1 for large text, icons, focus rings, and control borders.
- Information is never carried by color alone.
- Motion respects `prefers-reduced-motion`. Nothing flashes more than 3 times a second.
- Dark mode, when supported, sets `color-scheme` and keeps contrast.

**Layout and touch**
- Targets are at least 24×24 CSS px, ideally 44×44 on touch.
- Content reflows at 320 px wide and at 200% zoom without horizontal scrolling or clipped text.
- Long words, names, and URLs wrap or truncate with the full value available.
- Safe-area insets are respected on mobile.

**States and feedback**
- Every async view has loading, empty, and error states, and the error state offers a way to retry.
- Destructive actions confirm first or offer undo.
- Status changes (saved, failed, new results) are announced with `aria-live` or `role="status"`.
- URLs reflect state worth sharing or refreshing: filters, tabs, pagination.

**Content**
- Labels and buttons say what happens ("Save changes", not "Submit").
- Dates, numbers, and currency are formatted for the user's locale and time zone.
- Text is real text, not text in images.

## Output

Report one line per finding: `path:line  rule  what is wrong → the fix`. Group by file, most severe first. Say which source you used: the fetched guidelines, or the fallback checklist.
