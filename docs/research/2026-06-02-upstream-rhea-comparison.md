# Upstream Radix Rhea Comparison

## Source

- Official announcement: <https://ui.shadcn.com/docs/changelog/2026-05-rhea>
- Official CSS: `apps/v4/registry/styles/style-rhea.css`
- Compared against: `apps/v4/registry/styles/style-luma.css`
- Reviewed: 2026-06-02

## Summary

Rhea is the compact sibling of Luma. It keeps rounded translucent controls,
foreground surface rings, flat controls, the blurred dialog scrim, and the
primary-filled checkbox/switch/radio model. It reduces density directly at the
component level instead of changing Tailwind's global spacing scale.

## Shipped Family Inventory

| Family | Classification | Rhea treatment |
| --- | --- | --- |
| Card / value box | internal profile tokens | Smaller surface gap/padding, shadow-sm elevation, capped soft radius |
| Button / badge | public + internal profile tokens | 2rem default button height, tighter padding, `1rem` radius |
| Input / textarea / select | public + internal tokens; small scoped CSS remainder | Compact heights, `input/50` surface, `1rem` radii, tighter textarea and select-item padding |
| Checkbox / radio | internal tokens; scoped checked geometry | Luma-like `input/90` surface and primary checked fill |
| Switch | internal tokens + scoped structural CSS | Compact `32x20` default track, square-pill thumb, shorter translate |
| Slider | internal tokens + scoped structural CSS | `4px` track and `16x16` thumb |
| Dialog / popover / tooltip | internal tokens; scoped scrim/padding remainder | Soft ringed overlays, capped dialog radius, blurred `/30` scrim |
| Alert / empty / skeleton / code | internal tokens; small scoped geometry remainder | Rounded compact surfaces; empty keeps dashed treatment |
| Tabs / nav / sidebar / field / input group | shell scoped CSS | Compact hit targets, spacing, radii, and translucent input-group surface |
| Separator / spinner | unsupported profile delta | Intentionally profile-neutral |

## Deferred Families

The upstream CSS includes families not yet shipped by shinyblocks, including
combobox, menus, table, pagination, progress, toggle group, and drawer. Port
their Rhea differences when the corresponding runtime component lands.
