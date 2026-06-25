// Style-profile leanness gate (issue #34).
//
// A style profile must be DATA, not CSS: the default runtime CSS owns each
// repeated recipe once and reads it from a `--sb-*` token, and a profile is a
// list of token values in R/style-profiles.R plus, at most, a few genuinely
// structural CSS rules. This gate stops the recipe-expressible rules from
// creeping back into `[data-sb-style="…"]` selectors instead of becoming tokens.
//
// It scans the profile-scoped CSS in the runtime stylesheet (see STYLESHEETS)
// and fails when a `[data-sb-style]` rule sets a property that should be a token:
//   - border-radius                              -> `<component>_radius`
//   - a translucent `color-mix(... var(--input) …)` background  -> `_surface`
//   - a foreground-ring box-shadow (`color-mix(... var(--foreground) …)`) -> `_shadow`
//
// Genuine exceptions (a value a single static token cannot express, e.g. a
// per-colour-mode ring) live in LEANNESS_ALLOWLIST with a reason, mirroring the
// colour-allowlist pattern in check-token-usage.mjs.
//
// Usage:  node tools/theme/check-style-leanness.mjs

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { readCssSource } from "../css-source.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");

// Scope: the runtime stylesheet, the layer issue #34 converted to data. Its
// profile rules are flat top-level selectors that parseRules() handles directly.
//
// NOT scanned (intentional): the shell-family profile CSS in
// inst/www/src/shinyblocks.css (tabs/nav/sidebar/field/input-group) still
// hardcodes radii and translucent surfaces inside an `@layer` block. That layer
// is a separate Tailwind-compiled token system and was out of scope for #34's
// runtime-component tokenization; migrating it to `--sb-*` tokens (so the gate
// can cover it too) is the natural follow-up.
const STYLESHEETS = ["frontend/src/styles/runtime.css"];

// Justified exceptions: a recipe property that genuinely cannot be a single
// static profile token. Matched when the rule selector includes `selector` and
// the flagged `property` equals this entry's property.
const LEANNESS_ALLOWLIST = [
  {
    // block_card() renders as static htmltools markup (a bare `.sb-card`, not a
    // `[data-shinyblocks-root]` mount; see R/card.R), so the selector is no
    // longer root-scoped.
    selector: '[data-theme="dark"] [data-sb-style="luma"] .sb-card',
    property: "box-shadow",
    reason:
      "Luma and Rhea use a stronger dark-mode card ring (10% vs 5%). block_style() emits one static token value and cannot vary it per colour mode, so the dark ring stays in CSS."
  }
];

// Recipe detectors: [label, property, predicate(valueString)].
const RECIPES = [
  ["border-radius", "border-radius", () => true],
  [
    "translucent --input surface",
    "background-color",
    (v) => /color-mix\([^)]*var\(--input\)/.test(v)
  ],
  [
    "foreground-ring shadow",
    "box-shadow",
    (v) => /color-mix\([^)]*var\(--foreground\)/.test(v)
  ]
];

// Split a stylesheet into top-level rules { selector, body }. Good enough for
// these flat stylesheets (no nested at-rules around the profile blocks).
function parseRules(css) {
  // Strip comments so braces/semicolons inside them are ignored.
  const clean = css.replace(/\/\*[\s\S]*?\*\//g, "");
  const rules = [];
  let depth = 0;
  let selStart = 0;
  let selector = "";
  for (let i = 0; i < clean.length; i++) {
    const ch = clean[i];
    if (ch === "{") {
      if (depth === 0) {
        selector = clean.slice(selStart, i).trim();
      }
      depth++;
    } else if (ch === "}") {
      depth--;
      if (depth === 0) {
        const body = clean.slice(clean.indexOf("{", selStart) + 1, i);
        rules.push({ selector, body });
        selStart = i + 1;
      }
    }
  }
  return rules;
}

function declarations(body) {
  const out = [];
  for (const decl of body.split(";")) {
    const idx = decl.indexOf(":");
    if (idx === -1) continue;
    out.push({ prop: decl.slice(0, idx).trim(), value: decl.slice(idx + 1).trim() });
  }
  return out;
}

function isAllowlisted(selector, property) {
  return LEANNESS_ALLOWLIST.some(
    (a) => selector.includes(a.selector) && a.property === property
  );
}

function run() {
  const findings = [];
  let scanned = 0;

  for (const rel of STYLESHEETS) {
    const file = path.join(ROOT, rel);
    if (!fs.existsSync(file)) continue;
    const css = readCssSource(ROOT, rel);
    for (const { selector, body } of parseRules(css)) {
      if (!selector.includes("[data-sb-style=")) continue;
      scanned += 1;
      for (const { prop, value } of declarations(body)) {
        for (const [label, property, predicate] of RECIPES) {
          if (prop === property && predicate(value)) {
            if (isAllowlisted(selector, property)) continue;
            findings.push({ rel, selector, prop, value, label });
          }
        }
      }
    }
  }

  if (findings.length > 0) {
    console.error(
      "Style leanness gate FAILED. These [data-sb-style] rules set a recipe " +
        "property that must instead be a profile token (R/style-profiles.R):\n"
    );
    for (const f of findings) {
      console.error(`  ${f.rel}`);
      console.error(`    ${f.selector}`);
      console.error(`      ${f.prop}: ${f.value};  (${f.label})`);
    }
    console.error(
      "\nMove the value into the profile's list as a `--sb-<component>-<role>` " +
        "token (style_internal_token_map()), or, if it genuinely cannot be a " +
        "single static token, add a justified entry to LEANNESS_ALLOWLIST."
    );
    process.exitCode = 1;
    return;
  }

  console.log(
    `Style leanness gate passed: scanned ${scanned} [data-sb-style] rule(s), ` +
      `no recipe property hardcoded (allowlisted exceptions: ${LEANNESS_ALLOWLIST.length}).`
  );
}

run();
