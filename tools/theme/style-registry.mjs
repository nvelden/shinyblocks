// Declarative style-profile registry for the profile-parity check
// (check-style-parity.mjs).
//
// This is the style-profile analogue of theme-registry.mjs. Where the theme
// registry proves every component re-colours when a *colour* token changes,
// this registry proves every component responds to the active *visual profile*
// (block_style()/data-sb-style) — or explicitly declares that the profile does
// not affect it.
//
// Colour-token conformance (check-token-usage.mjs / check-theme-response.mjs)
// and profile parity (this file) are kept deliberately separate so a failure
// names the right layer: a colour regression vs a profile regression.
//
// For each component we declare a `mode`:
//   "profile"         -> A visual profile visibly changes the component. Each binding is a
//                        stable showcase selector + a profile-sensitive computed
//                        property (radius, padding, gap, height, border width,
//                        shadow, ...). The runtime check toggles the page into
//                        each profile and asserts the property *changes* from its
//                        default value, proving the profile actually reaches the
//                        component. If a specific profile intentionally leaves
//                        a measured component unchanged, add `neutralProfiles`
//                        with a reason keyed by profile name.
//   "overlay"         -> The profile changes the component, but the themed
//                        surface only renders after interaction (portal
//                        overlays). Instead of a runtime measurement, the parity
//                        check asserts the profile actually affects it: it sets
//                        at least one `<component>_*` token and/or has a
//                        [data-sb-style] rule for it. Requires a `reason`.
//   "profile-neutral" -> No shipped profile intentionally changes the component.
//                        Requires a `reason`. The completeness gate still
//                        requires the entry so a component is never silently
//                        uncovered when a profile later starts affecting it.
//
// Every component in RUNTIME_COMPONENT_NAMES (R/runtime.R) plus the R-side
// composition primitives (RSIDE_PRIMITIVES, shared with theme-registry.mjs) MUST
// have an entry, or the completeness gate fails. Selectors reuse the same stable
// `.sb-parity-*` showcase fixtures as the theme registry.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");

export const STYLE_REGISTRY = {
  // --- Runtime components: Luma changes them -----------------------------
  card: {
    section: "card",
    neutralProfiles: {
      maia: "Maia uses rounded-2xl cards, which matches the current shinyblocks card radius, so this radius binding is unchanged."
    },
    bindings: [{ selector: ".sb-parity-card-plain", property: "borderRadius" }]
  },
  "value-box": {
    section: "value-box",
    bindings: [{ selector: ".sb-parity-value-box-revenue", property: "borderRadius" }]
  },
  button: {
    section: "button",
    neutralProfiles: {
      nova: "Nova's default button radius maps to rounded-lg, matching the current shinyblocks default button radius."
    },
    bindings: [{ selector: ".sb-parity-button-default", property: "borderRadius" }]
  },
  badge: {
    section: "badge",
    bindings: [{ selector: ".sb-parity-badge-default", property: "borderRadius" }]
  },
  input: {
    section: "input",
    neutralProfiles: {
      lyra: "Lyra's official style uses square inputs; the default shinyblocks input is already square, so this radius binding is unchanged in this token-only slice.",
      sera: "Sera's official style uses square inputs; the default shinyblocks input is already square, so this radius binding is unchanged in this token-only slice."
    },
    bindings: [{ selector: ".sb-parity-input-default", property: "borderRadius" }]
  },
  "file-input": {
    section: "file_input",
    neutralProfiles: {
      lyra: "Lyra's official style uses square inputs; the default shinyblocks file input is already square, so this radius binding is unchanged in this token-only slice.",
      sera: "Sera's official style uses square inputs; the default shinyblocks file input is already square, so this radius binding is unchanged in this token-only slice."
    },
    bindings: [
      { selector: ".sb-parity-file-input[data-slot='file-input-control']", property: "borderRadius" }
    ]
  },
  textarea: {
    section: "textarea",
    neutralProfiles: {
      lyra: "Lyra's official style uses square textareas; the default shinyblocks textarea is already square, so this radius binding is unchanged in this token-only slice.",
      sera: "Sera's official style uses square textareas; the default shinyblocks textarea is already square, so this radius binding is unchanged in this token-only slice."
    },
    bindings: [{ selector: ".sb-parity-textarea-default", property: "borderRadius" }]
  },
  select: {
    section: "select",
    neutralProfiles: {
      nova: "Nova's select trigger radius maps to rounded-lg, matching the current shinyblocks default select radius."
    },
    bindings: [
      { selector: ".sb-parity-select-default [data-slot='select-trigger']", property: "borderRadius" }
    ]
  },
  checkbox: {
    section: "checkbox",
    neutralProfiles: {
      mira: "Mira's checkbox radius maps to 0.25rem, matching the current shinyblocks default checkbox radius.",
      nova: "Nova's checkbox radius maps to 0.25rem, matching the current shinyblocks default checkbox radius.",
      vega: "Vega's checkbox radius maps to 0.25rem, matching the current shinyblocks default checkbox radius."
    },
    bindings: [
      { selector: ".sb-parity-checkbox-checked [data-slot='checkbox-control']", property: "borderRadius" }
    ]
  },
  switch: {
    section: "switch",
    neutralProfiles: {
      lyra: "Lyra is token-only for switch in this slice; switch-specific border width and track/thumb metrics are not ported yet.",
      maia: "Maia is token-only for switch in this slice; switch-specific border width and track/thumb metrics are not ported yet.",
      mira: "Mira is token-only for switch in this slice; switch-specific border width and track/thumb metrics are not ported yet.",
      nova: "Nova is token-only for switch in this slice; switch-specific border width and track/thumb metrics are not ported yet.",
      sera: "Sera is token-only for switch in this slice; switch-specific border width and track/thumb metrics are not ported yet.",
      vega: "Vega is token-only for switch in this slice; switch-specific border width and track/thumb metrics are not ported yet."
    },
    bindings: [
      { selector: ".sb-parity-switch-checked [data-slot='switch-control']", property: "borderTopWidth" }
    ]
  },
  slider: {
    section: "slider",
    neutralProfiles: {
      maia: "Maia is token-only for slider in this slice; slider-specific track/thumb geometry CSS is not ported yet.",
      mira: "Mira is token-only for slider in this slice; slider-specific track/thumb geometry CSS is not ported yet.",
      nova: "Nova is token-only for slider in this slice; slider-specific track/thumb geometry CSS is not ported yet.",
      sera: "Sera is token-only for slider in this slice; slider-specific track/thumb geometry CSS is not ported yet.",
      vega: "Vega is token-only for slider in this slice; slider-specific track/thumb geometry CSS is not ported yet."
    },
    bindings: [
      { selector: ".sb-parity-slider-default [data-slot='slider-track']", property: "height" }
    ]
  },
  "radio-group": {
    section: "radio-group",
    neutralProfiles: {
      lyra: "Lyra keeps the default radio-group checked-fill model; its control_gap equals the default in this token-only slice.",
      maia: "Maia keeps the default radio-group checked-fill model; its control_gap equals the default in this token-only slice.",
      mira: "Mira keeps the default radio-group checked-fill model; radio-group spacing is structural CSS and is not ported in this token-only slice.",
      nova: "Nova keeps the default radio-group checked-fill model; its control_gap equals the default in this token-only slice.",
      sera: "Sera keeps the default radio-group checked-fill model; its control_gap equals the default in this token-only slice.",
      vega: "Vega keeps the default radio-group checked-fill model; its control_gap equals the default in this token-only slice."
    },
    bindings: [{ selector: ".sb-parity-radio-group-checked", property: "gap" }]
  },
  alert: {
    section: "alert",
    bindings: [{ selector: ".sb-parity-alert-destructive", property: "borderRadius" }]
  },
  empty: {
    section: "empty",
    neutralProfiles: {
      lyra: "Lyra keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only.",
      maia: "Maia keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only.",
      mira: "Mira keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only.",
      nova: "Nova keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only.",
      sera: "Sera keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only.",
      vega: "Vega keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only."
    },
    bindings: [{ selector: ".sb-parity-empty-default", property: "borderStyle" }]
  },
  skeleton: {
    section: "skeleton",
    neutralProfiles: {
      nova: "Nova's skeleton radius maps to rounded-lg, matching the current shinyblocks default skeleton radius.",
      vega: "Vega's skeleton radius maps to rounded-lg, matching the current shinyblocks default skeleton radius."
    },
    bindings: [{ selector: ".sb-parity-skeleton-default", property: "borderRadius" }]
  },
  code: {
    section: "code",
    neutralProfiles: {
      nova: "Nova's code radius maps to rounded-xl, matching the current shinyblocks default code radius.",
      vega: "Vega's code radius maps to rounded-xl, matching the current shinyblocks default code radius."
    },
    bindings: [{ selector: ".sb-parity-code-default", property: "borderRadius" }]
  },
  table: {
    section: "table",
    bindings: [
      { selector: ".sb-parity-table [data-slot='table-cell']", property: "paddingLeft" }
    ]
  },

  // --- Runtime components: overlay (rendered on interaction) --------------
  dialog: {
    section: "dialog",
    mode: "overlay",
    reason:
      "Dialog content (radius/ring tokens + blurred scrim) only renders when open; asserted by the overlay presence check (profile sets dialog_* tokens and/or a [data-sb-style] dialog rule)."
  },
  popover: {
    section: "popover",
    mode: "overlay",
    reason:
      "Popover content (radius + foreground-ring tokens) only renders when open; asserted by the overlay presence check (profile sets popover_* tokens and/or a [data-sb-style] popover rule)."
  },
  toaster: {
    section: "toaster",
    mode: "overlay",
    reason:
      "Toasts only render when fired from the server; asserted by the overlay presence check (profile sets a [data-sb-style] .sb-toast rule mirroring the alert surface)."
  },
  tooltip: {
    section: "tooltip",
    mode: "overlay",
    reason:
      "Tooltip content (radius token + tighter padding) only renders on hover/focus; asserted by the overlay presence check (profile sets tooltip_* tokens and/or a [data-sb-style] tooltip rule)."
  },

  // --- Runtime components: profile-neutral -------------------------------
  separator: {
    section: "separator",
    mode: "profile-neutral",
    reason: "A 1px rule has no profile-sensitive geometry; Luma leaves it unchanged."
  },
  spinner: {
    section: "spinner",
    mode: "profile-neutral",
    reason: "An icon-sized spinner has no profile-sensitive geometry; Luma leaves it unchanged."
  },
  progress: {
    section: "progress",
    mode: "profile-neutral",
    reason: "The progress track is a fixed 0.5rem fully-rounded (9999px) bar to match shadcn; its geometry is intentionally constant and not parameterized by a profile geometry token, so no shipped profile overrides it. Indicator colour conformance is covered by theme-registry.mjs."
  },
  "date-picker": {
    section: "date-picker",
    mode: "profile-neutral",
    reason: "The date-picker trigger inherits the base control radius (calc(var(--radius) * 0.8)); a date-picker-specific geometry token is not ported into the profile system in this token-only slice, so no shipped profile overrides it. Trigger colour conformance is covered by theme-registry.mjs."
  },
  "date-range-picker": {
    section: "date-range-picker",
    mode: "profile-neutral",
    reason: "The range trigger reuses the same base control radius (calc(var(--radius) * 0.8)) as the single-date picker; no range-specific geometry token is ported into the profile system, so no shipped profile overrides it. Trigger colour conformance is covered by theme-registry.mjs."
  },

  // --- R-side shell families: Luma ported (compiled into inst/www/shinyblocks.css) ---
  nav: {
    section: "nav-item",
    neutralProfiles: {
      lyra: "Lyra shell-family structural CSS is ported for compact square nav, but this registry's shared radius binding is unchanged because the default computed shell radius is already 0px.",
      maia: "Maia shell-family structural CSS is not ported in this token-only slice.",
      mira: "Mira shell-family structural CSS is not ported in this token-only slice.",
      nova: "Nova shell-family structural CSS is not ported in this token-only slice.",
      sera: "Sera shell-family structural CSS is not ported in this token-only slice.",
      vega: "Vega shell-family structural CSS is not ported in this token-only slice."
    },
    bindings: [
      { selector: ".sb-parity-nav-baseline .sb-nav-item", property: "borderRadius" }
    ]
  },
  sidebar: {
    section: "layout",
    neutralProfiles: {
      lyra: "Lyra shell-family structural CSS is ported for compact square sidebar toggle, but this registry's shared radius binding is unchanged because the default computed shell radius is already 0px.",
      maia: "Maia shell-family structural CSS is not ported in this token-only slice.",
      mira: "Mira shell-family structural CSS is not ported in this token-only slice.",
      nova: "Nova shell-family structural CSS is not ported in this token-only slice.",
      sera: "Sera shell-family structural CSS is not ported in this token-only slice.",
      vega: "Vega shell-family structural CSS is not ported in this token-only slice."
    },
    bindings: [{ selector: ".sb-sidebar-toggle", property: "borderRadius" }]
  },
  tabs: {
    section: "tabs",
    neutralProfiles: {
      lyra: "Lyra shell-family structural CSS is ported for compact square tabs, but this registry's shared radius binding is unchanged because the default computed shell radius is already 0px.",
      maia: "Maia shell-family structural CSS is not ported in this token-only slice.",
      mira: "Mira shell-family structural CSS is not ported in this token-only slice.",
      nova: "Nova shell-family structural CSS is not ported in this token-only slice.",
      sera: "Sera shell-family structural CSS is not ported in this token-only slice.",
      vega: "Vega shell-family structural CSS is not ported in this token-only slice."
    },
    bindings: [
      { selector: ".sb-parity-tabs-default .sb-tabs-list", property: "borderRadius" }
    ]
  },
  field: {
    section: "field",
    neutralProfiles: {
      lyra: "Lyra shell-family structural CSS is not ported in this token-only slice.",
      maia: "Maia shell-family structural CSS is not ported in this token-only slice.",
      mira: "Mira shell-family structural CSS is not ported in this token-only slice.",
      nova: "Nova shell-family structural CSS is not ported in this token-only slice.",
      sera: "Sera shell-family structural CSS is not ported in this token-only slice.",
      vega: "Vega shell-family structural CSS is not ported in this token-only slice."
    },
    bindings: [{ selector: ".sb-parity-field-default", property: "gap" }]
  },
  "input-group": {
    section: "input-group",
    neutralProfiles: {
      lyra: "Lyra shell-family structural CSS is ported for compact square input groups, but this registry's shared radius binding is unchanged because the default computed shell radius is already 0px.",
      maia: "Maia shell-family structural CSS is not ported in this token-only slice.",
      mira: "Mira shell-family structural CSS is not ported in this token-only slice.",
      nova: "Nova shell-family structural CSS is not ported in this token-only slice.",
      sera: "Sera shell-family structural CSS is not ported in this token-only slice.",
      vega: "Vega shell-family structural CSS is not ported in this token-only slice."
    },
    bindings: [
      { selector: ".sb-parity-input-group-leading", property: "borderRadius" }
    ]
  }
};

// --- Luma token overrides, parsed from R (single source of truth) ---------
// The runtime parity check toggles the page into a profile by stamping
// data-sb-style="<profile>" on .sb-app *and* injecting the --sb-* token
// overrides exactly as block_style("<profile>") would. To avoid a second
// editable copy of those values, we parse them out of R/style-profiles.R: the
// profile's list (snake_case -> value) plus the snake_case -> --sb-* map. This
// is profile-agnostic — a new profile is swept with no edits here, mirroring the
// colour-preset sweep in check-theme-response.mjs.

// Shared token recipes a profile may splice with `c(list(...), helper(), ...)`
// instead of inlining the tokens (see R/style-profiles.R). A call site is not a
// literal `key = "value"` pair, so the parser resolves each helper to its token
// list and merges it into the profile. Keep this list in sync with the recipe
// helpers defined in R/style-profiles.R.
const RECIPE_HELPER_FNS = [
  "style_translucent_surface_tokens",
  "style_foreground_ring_tokens"
];

// Slice the balanced `(...)` body that begins at the `(` at or after openFrom.
// Counts `(`/`)` bytes without skipping string literals, so it assumes every
// value string is itself paren-balanced (true for CSS values like
// `min(calc(var(--radius) * 2.6), 24px)` and `color-mix(...)`). A token value
// with an unbalanced paren inside a string would corrupt the depth tracking.
function balancedParenBody(src, openFrom) {
  const open = src.indexOf("(", openFrom);
  if (open === -1) return "";
  let depth = 0;
  for (let i = open; i < src.length; i++) {
    if (src[i] === "(") depth++;
    else if (src[i] === ")") {
      depth--;
      if (depth === 0) return src.slice(open + 1, i);
    }
  }
  return "";
}

function scrapeStringPairs(body) {
  const out = {};
  for (const m of body.matchAll(/([A-Za-z0-9_]+)\s*=\s*"([^"]*)"/g)) {
    out[m[1]] = m[2];
  }
  return out;
}

// The token list a recipe-helper function returns (its `list(...)` body).
function parseHelperTokens(src, fnName) {
  const start = src.indexOf(`${fnName} <- function`);
  if (start === -1) return {};
  const listStart = src.indexOf("list(", start);
  if (listStart === -1) return {};
  return scrapeStringPairs(balancedParenBody(src, listStart));
}

// A profile's tokens: the literal `key = "value"` pairs in its
// `name = list(...)` / `name = c(...)` block, plus the tokens from any recipe
// helper it splices in.
function parseListBlock(src, listName) {
  let start = src.indexOf(`${listName} = list(`);
  if (start === -1) start = src.indexOf(`${listName} = c(`);
  if (start === -1) return {};
  const body = balancedParenBody(src, start);
  const out = scrapeStringPairs(body);
  for (const fn of RECIPE_HELPER_FNS) {
    if (body.includes(`${fn}(`)) Object.assign(out, parseHelperTokens(src, fn));
  }
  return out;
}

function parseNamedMap(src, fnName) {
  const fnStart = src.indexOf(`${fnName} <- function()`);
  if (fnStart === -1) return {};
  return scrapeStringPairs(balancedParenBody(src, src.indexOf("c(", fnStart)));
}

// Every token block_style() may emit: the public allowlist plus the internal
// per-component geometry tokens (radii, surfaces, borders, shadows).
function parseTokenMap(src) {
  return {
    ...parseNamedMap(src, "style_token_map"),
    ...parseNamedMap(src, "style_internal_token_map")
  };
}

function readProfilesSrc() {
  return fs.readFileSync(path.join(ROOT, "R", "style-profiles.R"), "utf8");
}

// Top-level profile names in `style_profiles <- list(...)`, excluding the
// no-op `default`. Parsed by tracking nesting depth so only the direct
// `name = list(` children of `style_profiles` count.
export function styleProfileNames(src = readProfilesSrc()) {
  const anchor = src.indexOf("style_profiles <- list(");
  if (anchor === -1) {
    throw new Error("Could not find `style_profiles <- list(` in R/style-profiles.R.");
  }
  const open = src.indexOf("(", anchor);
  let depth = 0;
  const names = [];
  for (let i = open; i < src.length; i++) {
    const ch = src[i];
    if (ch === "(") {
      depth++;
      // A direct child `name = list(` opens while we are inside the outer
      // `style_profiles <- list(` (depth 1), taking depth to 2.
      if (depth === 2) {
        const head = src.slice(0, i);
        // A profile is either `name = list(` or `name = c(` (the latter
        // composes recipe helpers; see parseListBlock).
        const m = head.match(/([A-Za-z0-9_.]+)\s*=\s*(?:list|c)$/);
        if (m) names.push(m[1]);
      }
    } else if (ch === ")") {
      depth--;
      if (depth === 0) break;
    }
  }
  return names.filter((n) => n !== "default");
}

// The snake_case token names a profile sets (keys of its `style_profiles` list).
export function profileTokenNames(profile, src = readProfilesSrc()) {
  return Object.keys(parseListBlock(src, profile));
}

// The --sb-* override declarations a given profile emits, exactly as
// block_style("<profile>") would. Throws if the profile sets a token with no
// entry in either token-map tier.
export function profileTokenOverrides(profile, src = readProfilesSrc()) {
  const values = parseListBlock(src, profile);
  const map = parseTokenMap(src);
  const decls = [];
  for (const [name, value] of Object.entries(values)) {
    const cssVar = map[name];
    if (!cssVar) {
      throw new Error(
        `Profile \`${profile}\` token \`${name}\` has no entry in ` +
          "style_token_map() or style_internal_token_map()."
      );
    }
    decls.push(`--${cssVar}: ${value};`);
  }
  if (decls.length === 0) {
    throw new Error(`Parsed no token overrides for profile \`${profile}\`.`);
  }
  return decls.join("");
}

// Back-compat alias.
export function lumaTokenOverrides() {
  return profileTokenOverrides("luma");
}
