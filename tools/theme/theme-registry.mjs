// Declarative theme-binding registry for the runtime theme-conformance check
// (check-theme-response.mjs).
//
// For each component we declare one or more *bindings*: a stable showcase
// selector, a computed CSS property, and the theme token that property must be
// bound to. The runtime check overrides that token (scoped to the section) to a
// sentinel color and asserts the rendered property changes to the sentinel —
// proving the component is token-driven (re-colors under dark mode and
// block_theme() overrides) rather than hardcoded.
//
// Every component in RUNTIME_COMPONENT_NAMES (R/runtime.R) plus the R-side
// composition primitives below MUST have an entry, or the completeness gate
// fails. Selectors reuse the stable `.sb-parity-*` showcase fixtures.
//
// `mode`:
//   "runtime"      -> behaviourally verified by token override (default).
//   "static-only"  -> CSS is token-driven (Layer 1 covers it) but the themed
//                     surface only renders after interaction (overlays). Must
//                     carry a `reason`. The completeness gate still requires the
//                     entry so the component is never silently uncovered.

export const THEME_REGISTRY = {
  // --- Runtime components -------------------------------------------------
  alert: {
    section: "alert",
    bindings: [
      { selector: ".sb-parity-alert-destructive", property: "color", token: "--destructive" },
      { selector: ".sb-parity-alert-destructive", property: "borderColor", token: "--destructive-border" }
    ]
  },
  badge: {
    section: "badge",
    bindings: [
      { selector: ".sb-parity-badge-default", property: "backgroundColor", token: "--primary" },
      { selector: ".sb-parity-badge-default", property: "color", token: "--primary-foreground" },
      { selector: ".sb-parity-badge-success", property: "backgroundColor", token: "--success" },
      { selector: ".sb-parity-badge-success", property: "color", token: "--success-foreground" },
      { selector: ".sb-parity-badge-success", property: "borderColor", token: "--success-border" },
      { selector: ".sb-parity-badge-warning", property: "backgroundColor", token: "--warning" },
      { selector: ".sb-parity-badge-warning", property: "color", token: "--warning-foreground" },
      { selector: ".sb-parity-badge-warning", property: "borderColor", token: "--warning-border" },
      { selector: ".sb-parity-badge-info", property: "backgroundColor", token: "--info" },
      { selector: ".sb-parity-badge-info", property: "color", token: "--info-foreground" },
      { selector: ".sb-parity-badge-info", property: "borderColor", token: "--info-border" }
    ]
  },
  button: {
    section: "button",
    bindings: [
      { selector: ".sb-parity-button-default[data-slot='button']", property: "backgroundColor", token: "--primary" },
      { selector: ".sb-parity-button-default[data-slot='button']", property: "color", token: "--primary-foreground" }
    ]
  },
  "task-button": {
    section: "task-button",
    bindings: [
      { selector: ".sb-parity-task-button-default[data-slot='task-button']", property: "backgroundColor", token: "--primary" },
      { selector: ".sb-parity-task-button-default[data-slot='task-button']", property: "color", token: "--primary-foreground" }
    ]
  },
  card: {
    section: "card",
    bindings: [
      { selector: ".sb-parity-card-plain", property: "backgroundColor", token: "--card" }
    ]
  },
  checkbox: {
    section: "checkbox",
    bindings: [
      { selector: ".sb-parity-checkbox-checked [data-slot='checkbox-control']", property: "backgroundColor", token: "--primary" }
    ]
  },
  code: {
    section: "code",
    bindings: [
      { selector: ".sb-parity-code-default", property: "backgroundColor", token: "--muted" }
    ]
  },
  "date-picker": {
    section: "date-picker",
    bindings: [
      { selector: ".sb-parity-date-picker-default .sb-date-picker-trigger", property: "color", token: "--foreground" },
      { selector: ".sb-parity-date-picker-default .sb-date-picker-trigger", property: "borderColor", token: "--input" }
    ]
  },
  "date-range-picker": {
    section: "date-range-picker",
    bindings: [
      { selector: ".sb-parity-date-range-picker-default .sb-date-range-picker-trigger", property: "color", token: "--foreground" },
      { selector: ".sb-parity-date-range-picker-default .sb-date-range-picker-trigger", property: "borderColor", token: "--input" }
    ]
  },
  dialog: {
    section: "dialog",
    mode: "static-only",
    reason: "Dialog content (bg --background, border --border) only renders when the overlay is open; CSS is token-driven and covered by the static check."
  },
  "dropdown-menu": {
    section: "dropdown_menu",
    mode: "static-only",
    reason: "Menu content (bg --popover, items --accent/--destructive) only renders when open; CSS is token-driven and covered by the static check."
  },
  empty: {
    section: "empty",
    bindings: [
      { selector: ".sb-parity-empty-default", property: "color", token: "--card-foreground" }
    ]
  },
  "file-input": {
    section: "file_input",
    bindings: [
      { selector: ".sb-parity-file-input[data-slot='file-input-control']", property: "backgroundColor", token: "--background" },
      { selector: ".sb-parity-file-input [data-slot='file-input-text']", property: "color", token: "--muted-foreground" },
      { selector: ".sb-parity-file-dropzone[data-slot='file-dropzone']", property: "backgroundColor", token: "--background" },
      { selector: ".sb-parity-file-dropzone .sb-file-dropzone-hint", property: "color", token: "--muted-foreground" },
      { selector: ".sb-parity-file-dropzone .sb-file-dropzone-icon", property: "backgroundColor", token: "--muted" }
    ]
  },
  input: {
    section: "input",
    bindings: [
      { selector: ".sb-parity-input-default", property: "backgroundColor", token: "--background" }
    ]
  },
  popover: {
    section: "popover",
    mode: "static-only",
    reason: "Popover content (bg --popover, border --border) only renders when open; CSS is token-driven and covered by the static check."
  },
  toaster: {
    section: "toaster",
    mode: "static-only",
    reason: "Toasts only render when fired from the server; toast surfaces reuse the alert variant tokens (--card, --success, --warning, --info, --destructive), which the static check covers."
  },
  progress: {
    section: "progress",
    bindings: [
      { selector: ".sb-parity-progress-default .sb-progress-indicator", property: "backgroundColor", token: "--primary" },
      { selector: ".sb-parity-progress-success .sb-progress-indicator", property: "backgroundColor", token: "--success-foreground" },
      { selector: ".sb-parity-progress-destructive .sb-progress-indicator", property: "backgroundColor", token: "--destructive" }
    ]
  },
  "radio-group": {
    section: "radio-group",
    bindings: [
      { selector: ".sb-parity-radio-group-checked .sb-radio-group-button[data-state='checked'] .sb-radio-group-indicator", property: "backgroundColor", token: "--primary" }
    ]
  },
  "toggle-group": {
    section: "toggle-group",
    bindings: [
      { selector: ".sb-parity-toggle-group-on .sb-toggle-group-item[data-state='on']", property: "backgroundColor", token: "--accent" },
      { selector: ".sb-parity-toggle-group-on .sb-toggle-group-item[data-state='on']", property: "color", token: "--accent-foreground" },
      { selector: ".sb-parity-toggle-group-on .sb-toggle-group-item[data-state='off']", property: "borderColor", token: "--input" }
    ]
  },
  select: {
    section: "select",
    bindings: [
      { selector: ".sb-parity-select-default [data-slot='select-trigger']", property: "color", token: "--foreground" },
      // Multiple mode: the `div role="combobox"` trigger reuses the single-select
      // foreground/border tokens, and the wrapping removable chips map to the
      // secondary palette (chips render statically from the pre-selected fixture,
      // no popup needed). Confirms multi mode is token-driven, not hardcoded.
      { selector: ".sb-parity-multi-select [data-slot='select-trigger']", property: "color", token: "--foreground" },
      { selector: ".sb-parity-multi-select .sb-select-chip", property: "backgroundColor", token: "--secondary" },
      { selector: ".sb-parity-multi-select .sb-select-chip", property: "color", token: "--secondary-foreground" },
      { selector: ".sb-parity-multi-select .sb-select-chip", property: "borderColor", token: "--border" }
    ]
  },
  combobox: {
    section: "combobox",
    bindings: [
      // The combobox trigger reuses the select trigger surface; its portaled
      // search box / empty state only render on interaction, so the static
      // fixture only exercises the trigger foreground (single) plus the multi
      // chip palette (rendered from the pre-selected fixture).
      { selector: ".sb-parity-combobox-default [data-slot='select-trigger']", property: "color", token: "--foreground" },
      { selector: ".sb-parity-multi-combobox [data-slot='select-trigger']", property: "color", token: "--foreground" },
      { selector: ".sb-parity-multi-combobox .sb-select-chip", property: "backgroundColor", token: "--secondary" },
      { selector: ".sb-parity-multi-combobox .sb-select-chip", property: "color", token: "--secondary-foreground" },
      { selector: ".sb-parity-multi-combobox .sb-select-chip", property: "borderColor", token: "--border" }
    ]
  },
  separator: {
    section: "separator",
    bindings: [
      { selector: ".sb-parity-separator-horizontal", property: "backgroundColor", token: "--border" }
    ]
  },
  skeleton: {
    section: "skeleton",
    bindings: [
      { selector: ".sb-parity-skeleton-default", property: "backgroundColor", token: "--muted" }
    ]
  },
  slider: {
    section: "slider",
    bindings: [
      { selector: ".sb-parity-slider-default [data-slot='slider-range']", property: "backgroundColor", token: "--primary" }
    ]
  },
  spinner: {
    section: "spinner",
    bindings: [
      { selector: ".sb-parity-spinner-default", property: "color", token: "--foreground" }
    ]
  },
  switch: {
    section: "switch",
    bindings: [
      { selector: ".sb-parity-switch-checked [data-slot='switch-control']", property: "backgroundColor", token: "--primary" }
    ]
  },
  table: {
    section: "table",
    bindings: [
      { selector: ".sb-parity-table [data-slot='table']", property: "color", token: "--foreground" },
      { selector: ".sb-parity-table [data-slot='table-head']", property: "color", token: "--muted-foreground" },
      { selector: ".sb-parity-table [data-slot='table-row']", property: "borderBottomColor", token: "--border" },
      { selector: ".sb-parity-table .sb-table-cell[data-intent='primary']", property: "color", token: "--primary" },
      { selector: ".sb-parity-table .sb-table-head[data-intent='destructive']", property: "color", token: "--destructive" }
    ]
  },
  textarea: {
    section: "textarea",
    bindings: [
      { selector: ".sb-parity-textarea-default", property: "backgroundColor", token: "--background" }
    ]
  },
  tooltip: {
    section: "tooltip",
    mode: "static-only",
    reason: "Tooltip content (bg --primary) only renders on hover/focus; CSS is token-driven and covered by the static check."
  },
  "value-box": {
    section: "value-box",
    bindings: [
      { selector: ".sb-parity-value-box-revenue", property: "backgroundColor", token: "--card" }
    ]
  },

  // --- R-side composition primitives -------------------------------------
  nav: {
    section: "nav-item",
    bindings: [
      { selector: ".sb-parity-nav-baseline", property: "color", token: "--sidebar-foreground" }
    ]
  },
  sidebar: {
    section: "layout",
    bindings: [
      { selector: ".sb-sidebar", property: "backgroundColor", token: "--sidebar" },
      { selector: ".sb-sidebar", property: "color", token: "--sidebar-foreground" }
    ]
  },
  tabs: {
    section: "tabs",
    bindings: [
      { selector: ".sb-parity-tabs-default", property: "color", token: "--foreground" }
    ]
  },
  field: {
    section: "field",
    bindings: [
      { selector: ".sb-parity-field-default", property: "color", token: "--foreground" }
    ]
  },
  "input-group": {
    section: "input-group",
    bindings: [
      { selector: ".sb-parity-input-group-fixtures", property: "color", token: "--foreground" }
    ]
  },
  "image-output": {
    section: "image-output",
    bindings: [
      { selector: ".sb-parity-image-output .sb-output-media", property: "borderColor", token: "--border" },
      { selector: ".sb-parity-image-output .sb-output-caption", property: "color", token: "--muted-foreground" }
    ]
  },
  "plot-output": {
    section: "plot-output",
    bindings: [
      { selector: ".sb-parity-plot-output .sb-output-media", property: "borderColor", token: "--border" },
      { selector: ".sb-parity-plot-output .sb-output-caption", property: "color", token: "--muted-foreground" }
    ]
  },
  stack: {
    section: "layout-primitives",
    mode: "static-only",
    reason: "Stack is a color-neutral structural primitive; its profile-sensitive gap is covered by style-registry.mjs."
  },
  cluster: {
    section: "layout-primitives",
    mode: "static-only",
    reason: "Cluster is a color-neutral structural primitive; its profile-sensitive gap is covered by style-registry.mjs."
  },
  grid: {
    section: "layout-primitives",
    mode: "static-only",
    reason: "Grid is a color-neutral structural primitive; its profile-sensitive gap is covered by style-registry.mjs."
  }
};

// R-side primitives that have no entry in RUNTIME_COMPONENT_NAMES but must still
// be covered by the theme framework (and therefore present in THEME_REGISTRY).
export const RSIDE_PRIMITIVES = [
  "nav",
  "sidebar",
  "tabs",
  "field",
  "input-group",
  "image-output",
  "plot-output",
  "stack",
  "cluster",
  "grid"
];
