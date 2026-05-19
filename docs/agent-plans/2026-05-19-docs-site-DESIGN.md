# Docs Site — Design Spec

**Date:** 2026-05-19
**Companion to:** `2026-05-19-custom-docs-site.md` (architecture), `2026-05-19-docs-site-build-plan.md` (build plan)
**Scope:** Visual + component spec for the docs site (`docs-site/`). Single source of truth for tokens, typography, shadcn components used, and per-surface styling decisions.

> **Implementation deltas** (2026-05-19): no Fumadocs in v1, no shadcn CLI in v1 — shadcn-style components are hand-built where needed (e.g. `<ThemeToggle>`). The token system below is correct and lives in `docs-site/app/globals.css`. Substitute `npm install <pkg>` for `pnpm dlx shadcn@latest add <pkg>` when a phase calls for a primitive.

The goal is **shadcn.com fidelity** — same tokens, same type scale, same neutral palette, same component vocabulary. The shinyblocks runtime CSS (`inst/www/shinyblocks.css`) is the canonical token source; the docs site imports it directly so the gallery, component previews, and the docs chrome share one design system.

---

## 1. Design tokens

All tokens are CSS variables defined under `:root` and overridden under `.dark`. Lifted verbatim from `inst/www/shinyblocks.css` so the prerendered HTML fragments are styled identically.

### Color (oklch, neutral-zinc palette)

| Token | Light | Dark |
|---|---|---|
| `--background` | `oklch(1 0 0)` | `oklch(0.145 0 0)` |
| `--foreground` | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--card` | `oklch(1 0 0)` | `oklch(0.205 0 0)` |
| `--card-foreground` | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--popover` | `oklch(1 0 0)` | `oklch(0.205 0 0)` |
| `--popover-foreground` | `oklch(0.145 0 0)` | `oklch(0.985 0 0)` |
| `--primary` | `oklch(0.205 0 0)` | `oklch(0.922 0 0)` |
| `--primary-foreground` | `oklch(0.985 0 0)` | `oklch(0.205 0 0)` |
| `--secondary` | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--muted` | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--muted-foreground` | `oklch(0.556 0 0)` | `oklch(0.708 0 0)` |
| `--accent` | `oklch(0.97 0 0)` | `oklch(0.269 0 0)` |
| `--destructive` | `oklch(0.577 0.245 27.325)` | `oklch(0.704 0.191 22.216)` |
| `--border` | `oklch(0.922 0 0)` | `oklch(1 0 0 / 10%)` |
| `--input` | `oklch(0.922 0 0)` | `oklch(1 0 0 / 15%)` |
| `--ring` | `oklch(0.708 0 0)` | `oklch(0.556 0 0)` |

No brand color. The site reads as a serious tool, not a marketing splash.

### Radii

```
--radius: 0.625rem    /* base — buttons, inputs */
--radius-sm: calc(var(--radius) - 4px)
--radius-md: calc(var(--radius) - 2px)
--radius-lg: var(--radius)
--radius-xl: calc(var(--radius) + 4px)   /* cards, dialogs */
```

### Spacing

Tailwind's default scale (`0.25rem` increments). Site-wide layout uses a 4-px grid; component-page columns are `gap-8` (32 px); cards use `p-6` (24 px).

### Shadows

Only two used:
- `shadow-sm` — cards, popovers
- `shadow-lg` — open dialogs, command palette (deferred)

### Layout widths

| Surface | Max width |
|---|---|
| Site (`<html>`) | full bleed |
| Top nav inner | `max-w-screen-2xl` |
| Landing hero | `max-w-3xl` centered |
| Landing gallery | `max-w-screen-2xl`, CSS columns |
| Components index | `max-w-screen-2xl` |
| Component detail center column | `max-w-3xl` |
| Changelog | `max-w-3xl` |

---

## 2. Typography

### Families

| Use | Font | Source |
|---|---|---|
| UI + body | **Geist Sans** | `next/font/google` |
| Code | **Geist Mono** | `next/font/google` |
| Headings | Geist Sans (tracking-tight) | — |

No serif. Both fonts shipped subset and self-hosted by Next, so no external font load.

### Scale

| Class | Size / leading | Used for |
|---|---|---|
| `text-5xl font-bold tracking-tight` | 48 / 1.1 | Landing H1 |
| `text-3xl font-semibold tracking-tight` | 30 / 1.2 | Component page H1 |
| `text-2xl font-semibold tracking-tight` | 24 / 1.25 | Section `<h2>` (`##`) |
| `text-lg font-semibold` | 18 / 1.4 | Card titles |
| `text-base` | 16 / 1.6 | Body |
| `text-sm` | 14 / 1.5 | Sidebar items, TOC, captions |
| `text-xs uppercase tracking-wide` | 12 | Sidebar section labels |
| `font-mono text-sm` | 14 | Code blocks |

Prose color: `text-foreground` for body, `text-muted-foreground` for descriptions and TOC.

---

## 3. shadcn components — what we use

Pull only what we need; don't drag the whole registry. Each is added via `pnpm dlx shadcn@latest add <name>` and lives under `docs-site/components/ui/`.

| shadcn component | Where used | Notes |
|---|---|---|
| **Button** | "Get started" / "View Components" / "Run example" / "View Code" / "Copy" | Variants: `default`, `outline`, `ghost`, `secondary`. Sizes: `default`, `sm`, `icon`. |
| **Tabs** | Component-page playground (Content / State / Styling / Actions), Installation block (Command / Manual) | The playground tabs need a custom underline-style trigger to match shadcn.com's docs. |
| **Card** | Landing gallery cards, components-index cards | Used as the `<ComponentPreview>` wrapper. |
| **Badge** | Changelog version pills, "New" tag in registry | Variants: `default`, `secondary`, `outline`. |
| **Separator** | Between hero and gallery, between sections | Horizontal only. |
| **ScrollArea** | Left components rail on desktop, mobile sheet contents | Sticky height = `calc(100vh - <nav-height>)`. |
| **Sheet** | Mobile components nav (slides in from left) | Triggered by hamburger button in top nav on `< md`. |
| **Tooltip** | Top-nav icon buttons, "Copy" feedback | 0 ms close delay. |
| **DropdownMenu** | Theme toggle menu (Light / Dark / System) | Single use only. |
| **Input** | Components-index filter | Plain, no icon, `aria-label="Filter components"`. |
| **Skeleton** | Shinylive iframe placeholder while WebR boots | Rectangular, matches iframe height. |
| **Toast (Sonner)** | "Copied to clipboard" feedback | One-line, top-right. |

### Explicitly **not** used in v1

- Accordion, Alert, AlertDialog, Avatar, Breadcrumb, Calendar, Carousel, Checkbox, Collapsible, Combobox, Command, ContextMenu, DataTable, DatePicker, Drawer, Form, HoverCard, Label, Menubar, NavigationMenu, Pagination, Popover, Progress, RadioGroup, Resizable, Select, Slider, Switch, Table, Textarea, Toggle, ToggleGroup.

If a v1 surface seems to need one of these, escalate before adding.

---

## 4. Layout primitives

### Top nav (`<SiteHeader>`)

- Sticky, `h-14`, `border-b`, `bg-background/95 backdrop-blur`
- Left: wordmark "shinyblocks" (`font-semibold`)
- Middle (≥ md): `Components`, `Changelog` (text links, `text-sm font-medium`)
- Right: GitHub icon button, theme toggle dropdown
- `< md`: hamburger button (left) opens the mobile components Sheet
- No search input in v1

### Left rail (`<ComponentsNav>`) — component-page only

- `w-56`, sticky, top offset = nav height
- Section label `Components` in `text-xs uppercase tracking-wide text-muted-foreground`
- Items: `text-sm` rows, full-width hit area, `rounded-md px-2 py-1.5`
- Active item: `bg-accent text-accent-foreground`
- Hover: `bg-accent/50`
- No icons, no badges — flat list

### Right rail (`<TableOfContents>`) — component-page + changelog

- `w-56`, sticky
- Section label `On This Page` in `text-xs uppercase tracking-wide text-muted-foreground`
- Items: `text-sm text-muted-foreground hover:text-foreground`
- Active heading (scroll-spy): `text-foreground font-medium`
- Indents one level for `<h3>`

### Footer (`<SiteFooter>`)

One thin line: `Built in R · Source on GitHub · MIT`. `text-sm text-muted-foreground`, `py-8`, centered.

---

## 5. Surface-specific styling

### Landing page

- Hero: vertical padding `py-24`, centered
- Small pill above title (shadcn `<Badge variant="secondary">`) — `New: vX.Y.Z released` linking to changelog
- H1: `text-5xl font-bold tracking-tight`
- Subtitle: `text-lg text-muted-foreground max-w-2xl`
- CTA row: primary `Button` + outline `Button`, `gap-3`
- **Gallery**: CSS columns (`columns-1 md:columns-2 lg:columns-4 gap-4`). Cards `break-inside-avoid`, no fixed heights — heights vary by content, that's the look.
- Card style: `<Card>` with `p-4`, inner preview area `pointer-events-none` (HTML imported via `?raw`), subtle hover: `hover:border-foreground/20 transition-colors`
- Whole card is a Next `<Link>` — cursor pointer at the card level only

### Components index

- Header: H1 `Components`, one-line subtitle, filter `<Input>` right-aligned
- Grid: `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4`
- Cards: same `<ComponentPreview>` as the landing gallery but with fixed `aspect-[4/3]` and `overflow-hidden` so the grid stays even
- Card footer: component name `font-medium`, one-line description `text-sm text-muted-foreground`

### Component detail page

Three-column grid: `grid-cols-[14rem_minmax(0,1fr)_14rem] gap-8` on `xl:`, two-column (drop left rail under Sheet) on `lg:`, single column on `< md`.

Center column:
- **Title block**: H1, one-line description in `text-muted-foreground`
- **Playground card**: rounded `<Card>`, no padding on the preview area, internal `<Tabs>` for Content / State / Styling / Actions
  - Tabs trigger style: underline, not pill — matches shadcn.com docs (custom variant)
  - Preview area: `min-h-[320px]`, prerendered static HTML as placeholder until "Run example" mounts the iframe
  - Code area: full-width `<pre>` under the preview, max-height `300px` with scroll, `View Code` toggle on small screens
- **Installation block**: standalone `<Card>`, `<Tabs>` for Command / Manual; inside Command another row of pills for `remotes` / `pak` / `devtools`
- **Usage**: short prose section, `prose-sm` typography
- **API Reference**: `<ApiTable>` — rendered as a styled `<table>`, not a real shadcn table component, because shadcn's Table is too generic
  - Header row: `text-xs uppercase tracking-wide text-muted-foreground bg-muted/40`
  - Body rows: `border-b last:border-0`
  - Arg name in `font-mono text-sm`, type in `font-mono text-xs text-muted-foreground`, default in `font-mono text-xs`

### Changelog

- Single center column, no rails on the left, version TOC on the right
- Each `## X.Y.Z` heading: H2 with a Badge `<Badge variant="secondary">2026-05-12</Badge>` to its right
- `### Added` / `### Fixed` / `### Changed` headings: `text-sm uppercase tracking-wide text-muted-foreground`
- Bullet rows: `text-sm`, code-style spans for function names (`<code>block_button()</code>`)

---

## 6. Icons (Lucide)

Single icon library: **`lucide-react`**. No other icon sets.

Sizes: `h-4 w-4` (default in body), `h-5 w-5` (top-nav icons), `h-3.5 w-3.5` (inline indicators).

Vocabulary used:
| Icon | Use |
|---|---|
| `Github` | Top nav GitHub link |
| `Sun` / `Moon` / `Monitor` | Theme toggle |
| `Play` | "Run example" button |
| `Copy` / `Check` | Code copy button (Check on success) |
| `ExternalLink` | Outbound links |
| `Menu` | Mobile hamburger |
| `ChevronRight` | Card link affordance (subtle) |
| `Search` | Components-index filter input prefix |

---

## 7. Code blocks

- Library: **Shiki** (Fumadocs default)
- Theme: `github-light` / `github-dark`, switched by `data-theme` on `<html>`
- Languages enabled: `r`, `bash`, `json`, `tsx`
- Block chrome: `<Card variant="outline">` wrapper, `<pre>` with `p-4`, copy button absolutely positioned top-right
- Inline code: `font-mono text-[0.92em] bg-muted px-1 py-0.5 rounded`

---

## 8. Dark mode

- Controlled by `next-themes` (`<ThemeProvider attribute="class">`)
- Default: `system`
- Three-state toggle (Light / Dark / System) via shadcn `DropdownMenu`
- Both light and dark are first-class — every preview, every screenshot, every card must look right in both. Test every component page in both before merging.

---

## 9. Motion

Minimal, mostly shadcn defaults:
- Page transitions: none (full reload feel kept simple)
- Tab content swap: default Radix Tabs animation (150 ms opacity)
- Dropdown / Sheet: shadcn defaults
- Card hover: `transition-colors duration-150` on border only — no scale, no lift

---

## 10. Accessibility floor

Non-negotiable; check on every PR:
- All interactive controls reachable by keyboard, focus visible (Tailwind `focus-visible:ring-2 focus-visible:ring-ring`)
- All images / icons in interactive contexts have `aria-label`
- Color contrast ≥ WCAG AA in both themes (the token palette is built to satisfy this)
- Component-preview cards: the card-level `<Link>` carries the accessible name (e.g. `aria-label="Button component"`) since the inner HTML is `aria-hidden="true"` and non-interactive
- Skip-to-content link in the top nav, visually hidden until focused

---

## 11. Open questions

- **Custom Tabs variant** — shadcn.com docs use an underline-tab style not in the default registry. We'll need to fork the shadcn Tabs into a `tabs-underline.tsx` variant. Confirm before Phase 5.
- **OG / social images** — out of v1 scope, but mentally reserve a token style. Likely a static PNG per component generated from the prerendered HTML.
- **Anchor link icons** — should `##` headings show a "#" link affordance on hover? Default Fumadocs does this; we keep it on.
