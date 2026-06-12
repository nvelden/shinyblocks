import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";
import { readCssSource } from "./css-source.mjs";

const root = process.cwd();

function minifyCss(source) {
  return source
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/\s+/g, " ")
    .replace(/\s*([{};,>])\s*/g, "$1")
    // Colon is handled separately from the set above: only the *trailing* space
    // is dropped. A leading space before `:` is a descendant combinator into a
    // pseudo-class (e.g. `[root] :is(.a, .b)`); stripping it would silently turn
    // the rule into the compound `[root]:is(...)`, which matches nothing.
    // Declarations never have a space before their colon, so this is lossless.
    .replace(/:\s+/g, ":")
    .replace(/;}/g, "}")
    .trim();
}

await mkdir(path.join(root, "inst/www"), { recursive: true });

const css = readCssSource(root, "frontend/src/styles/runtime.css");
await writeFile(
  path.join(root, "inst/www/shinyblocks-runtime.css"),
  `${minifyCss(css)}\n`
);

console.log("Built inst/www/shinyblocks-runtime.css");
