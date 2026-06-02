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
//   "profile"         -> Luma visibly changes the component. Each binding is a
//                        stable showcase selector + a profile-sensitive computed
//                        property (radius, padding, gap, height, border width,
//                        shadow, ...). The runtime check toggles the page into
//                        Luma and asserts the property *changes* from its
//                        default value, proving the profile actually reaches the
//                        component.
//   "overlay"         -> Luma changes the component, but the themed surface only
//                        renders after interaction (portal overlays). Covered by
//                        the presence of [data-sb-style="luma"] CSS rather than a
//                        runtime measurement. Requires a `reason`.
//   "profile-neutral" -> Luma intentionally does not change the component.
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
    bindings: [{ selector: ".sb-parity-input-default", property: "borderRadius" }]
  },
  textarea: {
    section: "textarea",
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
    bindings: [
      { selector: ".sb-parity-switch-checked [data-slot='switch-control']", property: "borderTopWidth" }
    ]
  },
  slider: {
    section: "slider",
    bindings: [
      { selector: ".sb-parity-slider-default [data-slot='slider-track']", property: "height" }
    ]
  },
  "radio-group": {
    section: "radio-group",
    bindings: [{ selector: ".sb-parity-radio-group-checked", property: "gap" }]
  },
  alert: {
    section: "alert",
    bindings: [{ selector: ".sb-parity-alert-destructive", property: "borderRadius" }]
  },
  empty: {
    section: "empty",
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
      "Dialog content (rounded-4xl, blurred /30 scrim) only renders when open; the [data-sb-style='luma'] rules are present and covered by the static CSS scan."
  },
  popover: {
    section: "popover",
    mode: "overlay",
    reason:
      "Popover content (rounded-3xl, foreground ring) only renders when open; the [data-sb-style='luma'] rules are present and covered by the static CSS scan."
  },
  tooltip: {
    section: "tooltip",
    mode: "overlay",
    reason:
      "Tooltip content (rounded-xl, tighter padding) only renders on hover/focus; the [data-sb-style='luma'] rules are present and covered by the static CSS scan."
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

  // --- R-side composition primitives: shell port deferred (Slice 4) ------
  nav: {
    section: "nav-item",
    mode: "profile-neutral",
    reason:
      "Shell family. The Luma shell port is deferred (requires recompiling the Tailwind shell CSS, make build-css); Luma is not advertised across the shell yet. See Slice 4."
  },
  sidebar: {
    section: "layout",
    mode: "profile-neutral",
    reason:
      "Shell family. The Luma shell port is deferred (requires recompiling the Tailwind shell CSS, make build-css); Luma is not advertised across the shell yet. See Slice 4."
  },
  tabs: {
    section: "tabs",
    mode: "profile-neutral",
    reason:
      "Shell family. The Luma shell port is deferred (requires recompiling the Tailwind shell CSS, make build-css); Luma is not advertised across the shell yet. See Slice 4."
  },
  field: {
    section: "field",
    mode: "profile-neutral",
    reason:
      "Shell family. The Luma shell port is deferred (requires recompiling the Tailwind shell CSS, make build-css); Luma is not advertised across the shell yet. See Slice 4."
  },
  "input-group": {
    section: "input-group",
    mode: "profile-neutral",
    reason:
      "Shell family. The Luma shell port is deferred (requires recompiling the Tailwind shell CSS, make build-css); Luma is not advertised across the shell yet. See Slice 4."
  }
};

// --- Luma token overrides, parsed from R (single source of truth) ---------
// The runtime parity check toggles the page into Luma by stamping
// data-sb-style="luma" on .sb-app *and* injecting the shared --sb-* token
// overrides exactly as block_style("luma") would. To avoid a second editable
// copy of those values, we parse them out of R/style-profiles.R: the luma list
// (snake_case -> value) plus the snake_case -> --sb-* property map.

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

function parseTokenMap(src) {
  const fnStart = src.indexOf("style_token_map <- function()");
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

export function lumaTokenOverrides() {
  const src = fs.readFileSync(path.join(ROOT, "R", "style-profiles.R"), "utf8");
  const luma = parseListBlock(src, "luma");
  const map = parseTokenMap(src);
  const decls = [];
  for (const [name, value] of Object.entries(luma)) {
    const cssVar = map[name];
    if (!cssVar) {
      throw new Error(`Luma token \`${name}\` has no entry in style_token_map().`);
    }
    decls.push(`--${cssVar}: ${value};`);
  }
  if (decls.length === 0) {
    throw new Error("Parsed no Luma token overrides from R/style-profiles.R.");
  }
  return decls.join("");
}
