// Deterministic guardrail for the vendored default shadcn semantic scaffold.
//
// Source of truth:
//   https://ui.shadcn.com/docs/theming
// Synced:
//   2026-06-02
//
// Runtime roots intentionally redeclare the semantic and shared style-profile
// tokens needed by runtime-rendered components and portals. This audit fails
// when those defaults drift from the package shell values in
// inst/www/src/tokens.css.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { readCssSource } from "../css-source.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");

const shell = fs.readFileSync(path.join(ROOT, "inst/www/src/tokens.css"), "utf8");
const runtime = readCssSource(ROOT, "frontend/src/styles/runtime.css");

function block(css, selector) {
  const start = css.indexOf(`${selector} {`);
  if (start === -1) throw new Error(`Missing CSS block: ${selector}`);
  const open = css.indexOf("{", start);
  const close = css.indexOf("}", open);
  return css.slice(open + 1, close);
}

function declarations(body) {
  return Object.fromEntries(
    [...body.matchAll(/--([a-z0-9-]+)\s*:\s*([^;]+);/g)].map((m) => [
      m[1],
      m[2].trim()
    ])
  );
}

function normalise(value) {
  return value.replace(
    /(-?\d+(?:\.\d+)?)%/g,
    (_, n) => String(Number((Number(n) / 100).toFixed(6)))
  );
}

// Shell tokens are scoped to package-owned page and standalone roots (not
// global `:root`) for host-page isolation.
const pairs = [
  [".sb-app,\n[data-shinyblocks-scope]:not(.sb-app [data-shinyblocks-scope]):not([data-shinyblocks-scope] [data-shinyblocks-scope])", "[data-shinyblocks-root],\n[data-shinyblocks-portal-root]"],
  ['[data-theme="dark"] .sb-app,\n[data-theme="dark"] [data-shinyblocks-scope]:not(.sb-app [data-shinyblocks-scope]):not([data-shinyblocks-scope] [data-shinyblocks-scope])', '[data-theme="dark"] [data-shinyblocks-root],\n[data-theme="dark"] [data-shinyblocks-portal-root]']
];

const failures = [];
for (const [shellSelector, runtimeSelector] of pairs) {
  const expected = declarations(block(shell, shellSelector));
  const actual = declarations(block(runtime, runtimeSelector));
  for (const [token, value] of Object.entries(actual)) {
    if (!(token in expected)) {
      failures.push(`${runtimeSelector} --${token}: missing from ${shellSelector}`);
    } else if (normalise(value) !== normalise(expected[token])) {
      failures.push(
        `${runtimeSelector} --${token}: ${value} != ${shellSelector} ${expected[token]}`
      );
    }
  }
}

if (failures.length > 0) {
  console.error("Default token drift audit FAILED:\n");
  for (const failure of failures) console.error(`  - ${failure}`);
  process.exitCode = 1;
} else {
  console.log("Default token drift audit passed: runtime defaults match the shell scaffold.");
}
