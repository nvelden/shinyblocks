// Layer 1 of the theme-conformance framework: a fast, browserless check that
// fails when component CSS hardcodes a color instead of using a theme token
// (`var(--...)`). This guarantees every component re-colors under dark mode
// and `block_theme()` overrides at the source level.
//
// Usage:  node tools/theme/check-token-usage.mjs
//
// It scans the hand-authored stylesheets, not the built/minified output:
//   - frontend/src/styles/runtime.css   (runtime component styling)
//   - inst/www/src/shinyblocks.css      (R-side shell/nav/layout styling)
//
// Only *applied* color properties are checked. Custom-property definitions
// (`--token: <color>`) are the source of truth and are skipped, which also
// excludes the fixed syntax-highlight palette (`--sb-code-token-*`).

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { isAllowedColorValue } from "./color-allowlist.mjs";
import { readCssSource } from "../css-source.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");

const TARGETS = [
  "frontend/src/styles/runtime.css",
  "inst/www/src/shinyblocks.css"
];

// Applied color-bearing properties. `background` is included but only flagged
// when its value looks like a plain color (not a gradient/url/shorthand).
const COLOR_PROPS = new Set([
  "color",
  "background-color",
  "border-color",
  "border-top-color",
  "border-right-color",
  "border-bottom-color",
  "border-left-color",
  "outline-color",
  "fill",
  "stroke",
  "accent-color"
]);

// Strip /* ... */ comments (including multi-line) before scanning.
function stripComments(css) {
  return css.replace(/\/\*[\s\S]*?\*\//g, (m) => m.replace(/[^\n]/g, " "));
}

function lineNumberAt(text, index) {
  let line = 1;
  for (let i = 0; i < index && i < text.length; i += 1) {
    if (text[i] === "\n") line += 1;
  }
  return line;
}

function scanFile(relPath) {
  const abs = path.join(ROOT, relPath);
  const raw = relPath === "frontend/src/styles/runtime.css"
    ? readCssSource(ROOT, relPath)
    : fs.readFileSync(abs, "utf8");
  const css = stripComments(raw);
  const violations = [];

  // Match `property: value;` declarations. Skip custom properties (`--x:`).
  const declRe = /(^|[;{}])\s*([a-z-]+)\s*:\s*([^;{}]+)\s*(?=;|})/gi;
  let m;
  while ((m = declRe.exec(css)) !== null) {
    const prop = m[2].toLowerCase();
    const value = m[3].trim().replace(/\s*!important\s*$/i, "").trim();
    if (prop.startsWith("--")) continue;
    if (!COLOR_PROPS.has(prop)) continue;

    // `background` shorthand: only treat as a color when the value has no
    // gradient/url/image function. (We don't include bare `background` in
    // COLOR_PROPS, so this branch is for completeness if extended.)
    if (isAllowedColorValue(value)) continue;

    violations.push({
      file: relPath,
      line: lineNumberAt(css, m.index),
      prop,
      value
    });
  }
  return violations;
}

function main() {
  const all = TARGETS.flatMap(scanFile);
  if (all.length === 0) {
    console.log(
      `Theme token-usage check passed: ${TARGETS.length} stylesheet(s), no hardcoded colors.`
    );
    return;
  }

  console.error("Theme token-usage check FAILED. Hardcoded colors found:\n");
  for (const v of all) {
    console.error(`  ${v.file}:${v.line}  ${v.prop}: ${v.value}`);
  }
  console.error(
    "\nUse a theme token: var(--primary), var(--background), var(--border), etc."
  );
  console.error(
    "If a literal is intentional and shadcn-accurate, add a justified entry to"
  );
  console.error("tools/theme/color-allowlist.mjs.");
  process.exitCode = 1;
}

main();
