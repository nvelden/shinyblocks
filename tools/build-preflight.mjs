// Generate the minimal reset required by shinyblocks-owned shell elements.
//
// Tailwind Preflight cannot be scoped safely with a descendant prefix: a rule
// such as `.sb-app button` still rewrites a host-package button placed in a
// shinyblocks content slot. Instead, this generator emits an ownership reset
// only for the `.sb-app` root and elements carrying an `sb-*` class. Runtime
// components own their reset in `frontend/src/styles/runtime/`.

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const OUT = resolve(root, "inst/www/src/preflight.scoped.css");
const PKG = resolve(root, "node_modules/tailwindcss/package.json");
const version = JSON.parse(readFileSync(PKG, "utf8")).version;

const owned = [
  ".sb-app",
  ":where(.sb-app, [data-shinyblocks-scope]) :where([class^='sb-'], [class*=' sb-'])",
  "[data-shinyblocks-scope]:where([class^='sb-'], [class*=' sb-'])"
].join(",\n");

const ownedDescendants = [
  ":where(.sb-app, [data-shinyblocks-scope]) :where([class^='sb-'], [class*=' sb-'])",
  "[data-shinyblocks-scope]:where([class^='sb-'], [class*=' sb-'])"
];
const ownedDescendant = ownedDescendants.join(",\n");
const withSuffix = (suffix) => ownedDescendants.map((selector) => `${selector}${suffix}`).join(",\n");

const css = `/*
 * GENERATED FILE — do not edit by hand.
 *
 * Minimal ownership reset for Tailwind v${version}. Unlike Tailwind Preflight,
 * this targets only the .sb-app root and elements with shinyblocks-owned sb-*
 * classes. Host-package descendants and content-slot markup are untouched.
 * Regenerate with node tools/build-preflight.mjs.
 */

${owned} {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  border: 0 solid;
}

${withSuffix("::before")},
${withSuffix("::after")} {
  box-sizing: border-box;
  border: 0 solid;
}

.sb-app {
  line-height: 1.5;
  -webkit-text-size-adjust: 100%;
  tab-size: 4;
  font-family: ui-sans-serif, system-ui, sans-serif, 'Apple Color Emoji',
    'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  -webkit-tap-highlight-color: transparent;
}

${withSuffix(":is(button, input, select, optgroup, textarea)")} {
  font: inherit;
  letter-spacing: inherit;
  color: inherit;
}

${withSuffix(":is(button, input[type='button'], input[type='reset'], input[type='submit'])")} {
  appearance: button;
}

${withSuffix(":is(img, svg, video, canvas)")} {
  display: block;
  vertical-align: middle;
}

${withSuffix(":is(img, video)")} {
  max-width: 100%;
  height: auto;
}

${withSuffix("[hidden]:not([hidden='until-found'])")} {
  display: none !important;
}
`;

writeFileSync(OUT, css);
console.log(`Wrote ${OUT} (ownership-scoped reset for Tailwind v${version}).`);
