// Generate a `.sb-app`-scoped copy of Tailwind's Preflight reset.
//
// shinyblocks ships compiled CSS that must be embeddable inside an existing
// Shiny/bslib page without resetting the host document. Tailwind's bundled
// Preflight (pulled in by `@import "tailwindcss"`) targets `*`, `html`,
// headings, lists, images, form controls, `[hidden]`, etc. document-wide. This
// script reads the upstream Preflight verbatim and rewrites every selector so
// it only applies under `.sb-app`, then writes the result to
// `inst/www/src/preflight.scoped.css`, which `inst/www/src/shinyblocks.css`
// imports into `@layer base` instead of the global bundle.
//
// Run via `make build-css` (chained before the Tailwind compile) or directly:
//   node tools/build-preflight.mjs
//
// Re-run on every Tailwind upgrade so the scoped reset stays in sync with the
// installed version. See ADR 0022 (CSS isolation).

import { readFileSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const root = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const SRC = resolve(root, "node_modules/tailwindcss/preflight.css");
const OUT = resolve(root, "inst/www/src/preflight.scoped.css");
const PKG = resolve(root, "node_modules/tailwindcss/package.json");
const SCOPE = ".sb-app";

function stripComments(css) {
  return css.replace(/\/\*[\s\S]*?\*\//g, "");
}

// Split a selector list on top-level commas only (commas inside :where(),
// :is(), [attr], etc. stay with their selector).
function splitSelectorList(list) {
  const parts = [];
  let depth = 0;
  let cur = "";
  for (const ch of list) {
    if (ch === "(" || ch === "[") depth++;
    else if (ch === ")" || ch === "]") depth--;
    if (ch === "," && depth === 0) {
      parts.push(cur);
      cur = "";
    } else {
      cur += ch;
    }
  }
  if (cur.trim()) parts.push(cur);
  return parts.map((s) => s.trim()).filter(Boolean);
}

// Scope one selector list under `.sb-app`.
//   html / :host  -> the .sb-app root itself
//   *             -> .sb-app and every descendant
//   anything else -> descendant of .sb-app
function scopeSelectorList(list) {
  const out = [];
  for (const sel of splitSelectorList(list)) {
    if (sel === "html" || sel === ":host") {
      out.push(SCOPE);
    } else if (sel === "*") {
      out.push(SCOPE);
      out.push(`${SCOPE} *`);
    } else {
      out.push(`${SCOPE} ${sel}`);
    }
  }
  return [...new Set(out)].join(",\n");
}

// Parse top-level rules: { prelude, body } where body keeps its outer braces.
function parseRules(css) {
  const rules = [];
  let i = 0;
  const n = css.length;
  while (i < n) {
    while (i < n && /\s/.test(css[i])) i++;
    if (i >= n) break;
    let prelude = "";
    while (i < n && css[i] !== "{") {
      prelude += css[i];
      i++;
    }
    if (i >= n) break;
    let depth = 0;
    let body = "";
    do {
      const ch = css[i];
      if (ch === "{") depth++;
      else if (ch === "}") depth--;
      body += ch;
      i++;
    } while (i < n && depth > 0);
    rules.push({ prelude: prelude.replace(/\s+/g, " ").trim(), body });
  }
  return rules;
}

function transform(css) {
  const rules = parseRules(stripComments(css));
  const out = [];
  for (const { prelude, body } of rules) {
    if (prelude.startsWith("@")) {
      // Conditional group rule (e.g. @supports): keep the prelude, scope the
      // selectors of the rules nested one level inside.
      const inner = body.slice(1, -1);
      const innerRules = parseRules(inner)
        .map((r) => `  ${scopeSelectorList(r.prelude)} ${r.body}`)
        .join("\n");
      out.push(`${prelude} {\n${innerRules}\n}`);
    } else {
      out.push(`${scopeSelectorList(prelude)} ${body}`);
    }
  }
  return out.join("\n\n");
}

const version = JSON.parse(readFileSync(PKG, "utf8")).version;
const header = `/*
 * GENERATED FILE — do not edit by hand.
 *
 * Tailwind Preflight (\`node_modules/tailwindcss/preflight.css\`, v${version}),
 * with every selector scoped under \`${SCOPE}\` so the reset never leaks into a
 * host page. Imported into \`@layer base\` by inst/www/src/shinyblocks.css.
 *
 * Regenerate with \`node tools/build-preflight.mjs\` (chained into
 * \`make build-css\`). Re-run on every Tailwind upgrade. See ADR 0022.
 */
`;

writeFileSync(OUT, `${header}\n${transform(readFileSync(SRC, "utf8"))}\n`);
console.log(`Wrote ${OUT} (scoped Preflight from Tailwind v${version}).`);
