---
name: design-review
description: Check UI work for accessibility, interface quality, React/Next.js performance, and consistency with the repository's own design system, then fix what it confirms. Use before pushing UI changes, when building or changing pages or components, or when asked for a design, UX, or accessibility review.
---

# Design review

General web practice, applied to the UI files a change touches. The repository's own design rules come first. This skill adds what any good web interface needs.

## 1. Find the repository's own design rules

Look for a `DESIGN.md`, a design system or tokens (a Tailwind config, CSS variables, a `components/ui/` folder), and any UI guidance in `AGENTS.md` or `CLAUDE.md`. Where they set a rule (colors, spacing, type scale, components to use), that rule wins over the general practice below. Do not invent a design system the repository does not have.

## 2. Collect the UI change

List the changed files that render UI: components, pages, layouts, styles. If there are none, say so and stop.

## 3. Review

Run each that applies, on those files only:

1. **Interface and accessibility**: the `web-design-guidelines` skill.
2. **React and Next.js performance**, when the files are React: the `vercel-react-best-practices` skill. Prioritize its CRITICAL and HIGH categories:
   - request waterfalls;
   - bundle size;
   - server-side performance.
3. **Consistency with the repository**:
   - uses existing components and tokens instead of new one-off styles;
   - matches spacing, type, and color from the design system;
   - no hard-coded colors or sizes where a token exists.
4. **Responsive behavior**: works from 320 px wide to wide desktop, with no horizontal scroll and no clipped or overlapping text.

Verify each finding in the code before keeping it. Drop anything that is already handled by a shared component or that you cannot point to a line for.

## 4. Fix and report

**Before a push, or when asked to fix**:
1. Fix accessibility failures, broken states, and performance problems in the CRITICAL and HIGH categories.
2. Fix inconsistencies whose fix is small and plainly correct.
3. Run the project's lint and build for what you touched.

**Review only** (asked to review, or reviewing someone else's work): list the findings without changing code.

Either way, report one line per finding (`path:line  what is wrong → the fix`), most severe first, and say what you fixed. When you can run the app and take a screenshot, check the changed screens at a phone width and a desktop width, and say if you could not.
