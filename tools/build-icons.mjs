#!/usr/bin/env node
// Build the Lucide icon sprite for shinyblocks.
//
// Reads the curated list from `inst/www/icons/MANIFEST.json`,
// pulls each icon's SVG from `lucide-static/icons/<name>.svg`,
// wraps it in `<symbol id="sb-icon-<name>">…</symbol>`, and writes
// the concatenated result to `inst/www/icons/sprite.svg`.
//
// The sprite is committed. End users do not run this script.
//
// See ADR 0008 for the icon strategy.

import { readFile, writeFile, mkdir } from "node:fs/promises";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const root = dirname(dirname(fileURLToPath(import.meta.url)));
const manifestPath = join(root, "inst/www/icons/MANIFEST.json");
const outPath = join(root, "inst/www/icons/sprite.svg");

const manifest = JSON.parse(await readFile(manifestPath, "utf8"));
const icons = manifest.icons ?? [];

if (!Array.isArray(icons) || icons.length === 0) {
  console.error("MANIFEST.json must list at least one icon under .icons[]");
  process.exit(1);
}

const symbols = [];
for (const name of icons) {
  const svgPath = join(
    root,
    "node_modules/lucide-static/icons",
    `${name}.svg`
  );
  let svg;
  try {
    svg = await readFile(svgPath, "utf8");
  } catch (e) {
    console.error(`Missing icon "${name}" at ${svgPath}`);
    process.exit(1);
  }
  // Extract the inner contents of the <svg> element. lucide-static
  // ships viewBox="0 0 24 24" stroke-based icons.
  const inner = svg
    .replace(/<\?xml[^?]*\?>\s*/g, "")
    .replace(/<svg[^>]*>/, "")
    .replace(/<\/svg>\s*$/, "")
    .trim();
  symbols.push(
    `<symbol id="sb-icon-${name}" viewBox="0 0 24 24" fill="none" ` +
    `stroke="currentColor" stroke-width="2" stroke-linecap="round" ` +
    `stroke-linejoin="round">${inner}</symbol>`
  );
}

const sprite =
  `<svg xmlns="http://www.w3.org/2000/svg" width="0" height="0" ` +
  `style="position:absolute" aria-hidden="true">` +
  symbols.join("") +
  `</svg>\n`;

await mkdir(dirname(outPath), { recursive: true });
await writeFile(outPath, sprite, "utf8");

const sizeKb = (Buffer.byteLength(sprite) / 1024).toFixed(1);
console.log(
  `Built sprite with ${icons.length} icons -> ${outPath} (${sizeKb} KB)`
);
