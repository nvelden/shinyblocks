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
    bindings: [{ selector: ".sb-parity-card-plain", property: "borderRadius" }]
  },
  "value-box": {
    section: "value-box",
    bindings: [{ selector: ".sb-parity-value-box-revenue", property: "borderRadius" }]
  },
  button: {
    section: "button",
    bindings: [{ selector: ".sb-parity-button-default", property: "borderRadius" }]
  },
  badge: {
    section: "badge",
    bindings: [{ selector: ".sb-parity-badge-default", property: "borderRadius" }]
  },
  input: {
    section: "input",
    neutralProfiles: {
      brutal: "The default input radius is already 0 (square), and brutal's square geometry sets it to 0 too, so this radius binding is unchanged. Brutal's input difference is the token-driven solid --border colour and flat shadow, not radius."
    },
    bindings: [{ selector: ".sb-parity-input-default", property: "borderRadius" }]
  },
  textarea: {
    section: "textarea",
    neutralProfiles: {
      brutal: "The default textarea radius is already 0 (square), and brutal's square geometry sets it to 0 too, so this radius binding is unchanged. Brutal's textarea difference is the token-driven solid --border colour and flat shadow, not radius."
    },
    bindings: [{ selector: ".sb-parity-textarea-default", property: "borderRadius" }]
  },
  select: {
    section: "select",
    bindings: [
      { selector: ".sb-parity-select-default [data-slot='select-trigger']", property: "borderRadius" }
    ]
  },
  checkbox: {
    section: "checkbox",
    bindings: [
      { selector: ".sb-parity-checkbox-checked [data-slot='checkbox-control']", property: "borderRadius" }
    ]
  },
  switch: {
    section: "switch",
    neutralProfiles: {
      mono: "Mono is data-only for switch: it flattens the control shadow but does not change switch-specific border width or track/thumb metrics.",
      soft: "Soft is data-only for switch: it softens radii and shadows page-wide but does not change switch-specific border width or track/thumb metrics.",
      brutal: "Brutal is data-only for switch: it flattens the switch shadow but does not change switch-specific border width or track/thumb metrics."
    },
    bindings: [
      { selector: ".sb-parity-switch-checked [data-slot='switch-control']", property: "borderTopWidth" }
    ]
  },
  slider: {
    section: "slider",
    neutralProfiles: {
      mono: "Mono is data-only for slider: it does not introduce slider-specific track or thumb geometry CSS.",
      soft: "Soft is data-only for slider: it does not introduce slider-specific track or thumb geometry CSS.",
      brutal: "Brutal is data-only for slider: it does not introduce slider-specific track or thumb geometry CSS."
    },
    bindings: [
      { selector: ".sb-parity-slider-default [data-slot='slider-track']", property: "height" }
    ]
  },
  "radio-group": {
    section: "radio-group",
    neutralProfiles: {
      mono: "Mono keeps the default radio-group gap and checked-fill model; only token-driven surface/border/shadow values differ.",
      soft: "Soft keeps the default radio-group gap and checked-fill model; it does not change control_gap, so radio-group spacing stays at the default.",
      brutal: "Brutal keeps the default radio-group gap and checked-fill model; only token-driven border/shadow values differ."
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
      mono: "Mono keeps the default solid empty-state border; its empty-state profile difference is token-driven radius only.",
      soft: "Soft keeps the default solid empty-state border; its empty-state profile difference is the token-driven (larger) radius only.",
      brutal: "Brutal keeps the default solid empty-state border; its empty-state profile difference is the token-driven (square, zero) radius only."
    },
    bindings: [{ selector: ".sb-parity-empty-default", property: "borderStyle" }]
  },
  skeleton: {
    section: "skeleton",
    bindings: [{ selector: ".sb-parity-skeleton-default", property: "borderRadius" }]
  },
  code: {
    section: "code",
    bindings: [{ selector: ".sb-parity-code-default", property: "borderRadius" }]
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

  // --- R-side shell families: Luma ported (compiled into inst/www/shinyblocks.css) ---
  nav: {
    section: "nav-item",
    neutralProfiles: {
      mono: "Mono does not add shell-family structural CSS; nav item geometry stays at the default shell treatment.",
      soft: "Soft does not add shell-family structural CSS; nav item geometry stays at the default shell treatment.",
      brutal: "Brutal does not add shell-family structural CSS; nav item geometry stays at the default shell treatment."
    },
    bindings: [
      { selector: ".sb-parity-nav-baseline .sb-nav-item", property: "borderRadius" }
    ]
  },
  sidebar: {
    section: "layout",
    neutralProfiles: {
      mono: "Mono does not add shell-family structural CSS; sidebar toggle geometry stays at the default shell treatment.",
      soft: "Soft does not add shell-family structural CSS; sidebar toggle geometry stays at the default shell treatment.",
      brutal: "Brutal does not add shell-family structural CSS; sidebar toggle geometry stays at the default shell treatment."
    },
    bindings: [{ selector: ".sb-sidebar-toggle", property: "borderRadius" }]
  },
  tabs: {
    section: "tabs",
    neutralProfiles: {
      mono: "Mono does not add shell-family structural CSS; tabs keep the default flat list geometry.",
      soft: "Soft does not add shell-family structural CSS; tabs keep the default flat list geometry.",
      brutal: "Brutal does not add shell-family structural CSS; tabs keep the default flat list geometry."
    },
    bindings: [
      { selector: ".sb-parity-tabs-default .sb-tabs-list", property: "borderRadius" }
    ]
  },
  field: {
    section: "field",
    neutralProfiles: {
      mono: "Mono does not add shell-family structural CSS; field spacing stays at the default shell treatment.",
      soft: "Soft does not add shell-family structural CSS; field spacing stays at the default shell treatment.",
      brutal: "Brutal does not add shell-family structural CSS; field spacing stays at the default shell treatment."
    },
    bindings: [{ selector: ".sb-parity-field-default", property: "gap" }]
  },
  "input-group": {
    section: "input-group",
    neutralProfiles: {
      mono: "Mono does not add shell-family structural CSS; input-group radius stays at the default shell treatment.",
      soft: "Soft does not add shell-family structural CSS; input-group radius stays at the default shell treatment.",
      brutal: "Brutal does not add shell-family structural CSS; input-group radius stays at the default shell treatment."
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

function parseListBlock(src, listName) {
  const start = src.indexOf(`${listName} = list(`);
  if (start === -1) return {};
  let depth = 0;
  let i = src.indexOf("(", start);
  const open = i;
  for (; i < src.length; i++) {
    if (src[i] === "(") depth++;
    else if (src[i] === ")") {
      depth--;
      if (depth === 0) break;
    }
  }
  const body = src.slice(open + 1, i);
  const out = {};
  for (const m of body.matchAll(/([A-Za-z0-9_]+)\s*=\s*"([^"]*)"/g)) {
    out[m[1]] = m[2];
  }
  return out;
}

function parseNamedMap(src, fnName) {
  const fnStart = src.indexOf(`${fnName} <- function()`);
  if (fnStart === -1) return {};
  const cStart = src.indexOf("c(", fnStart);
  let depth = 0;
  let i = cStart + 1;
  const open = src.indexOf("(", cStart);
  for (i = open; i < src.length; i++) {
    if (src[i] === "(") depth++;
    else if (src[i] === ")") {
      depth--;
      if (depth === 0) break;
    }
  }
  const body = src.slice(open + 1, i);
  const out = {};
  for (const m of body.matchAll(/([A-Za-z0-9_]+)\s*=\s*"([^"]*)"/g)) {
    out[m[1]] = m[2];
  }
  return out;
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
        const m = head.match(/([A-Za-z0-9_.]+)\s*=\s*list$/);
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
