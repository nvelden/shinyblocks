# shinyshadcn Plan

## Product Intent

Build an R package that gives Shiny developers a dashboard API with the simplicity of `shinydashboard` and a visual/component model inspired by shadcn/ui.

This is not a direct port of shadcn/ui. shadcn is a React/Tailwind/Radix pattern library; Shiny is server-rendered HTML plus reactive bindings. The package should borrow the design system concepts and component ergonomics while staying idiomatic to Shiny and `htmltools`.

## Audience

- R/Shiny developers who want modern dashboard UI without writing a frontend build pipeline.
- Scientific, data, and operational dashboards that need dense, usable interfaces.
- Developers who want themeable primitives rather than a fixed dashboard template.

## Core Principles

- R-first API: functions return `htmltools::tag` or `shiny.tag` objects.
- No required Node build step for package users.
- Accessibility is part of the component contract.
- Theming is token-based and override-friendly.
- Components should degrade to clean HTML/CSS where possible.
- JavaScript should be used for behavior, not for rendering everything.

## Initial API Surface

- `shadcn_page(...)`
- `shadcn_sidebar(...)`
- `shadcn_header(...)`
- `shadcn_nav_item(...)`
- `shadcn_card(...)`
- `shadcn_button(...)`
- `shadcn_badge(...)`
- `shadcn_tabs(...)`
- `shadcn_value_box(...)`
- `shadcn_theme(...)`

## Technical Questions

- Should assets be plain CSS/JS in `inst/www`, or generated from a small frontend package?
- Should icons be powered by inline SVG, lucide CSS classes, or an R helper that emits SVG?
- How close should function names stay to shadcn component names versus Shiny/dashboard conventions?
- Should Tailwind be a development-time build dependency only, or avoided entirely?
- Should this depend on `bslib`, or ship independent CSS variables?

## Milestones

1. Planning and design decisions.
2. Minimal static dashboard shell.
3. First interactive components.
4. Theme system.
5. Examples and documentation.
6. Package checks and release readiness.

## Non-Goals For The First Version

- Full shadcn/ui component parity.
- React runtime dependency.
- Drag-and-drop layout builders.
- A visual theme editor.
- Support for every Shiny input type on day one.
