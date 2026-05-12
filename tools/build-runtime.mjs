import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.cwd();
const runtimeFiles = [
  "frontend/src/runtime/payload-schema.js",
  "frontend/src/runtime/portal-root.js",
  "frontend/src/runtime/revisions.js",
  "frontend/src/runtime/shiny-bridge.js",
  "frontend/src/runtime/shiny-bindings.js",
  "frontend/src/runtime/mount.js",
  "frontend/src/index.js"
];

function minifyJs(source) {
  return source
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/^\s*\/\/.*$/gm, "")
    .replace(/\s+/g, " ")
    .replace(/\s*([{}()[\];,:=+\-*/<>])\s*/g, "$1")
    .trim();
}

function minifyCss(source) {
  return source
    .replace(/\/\*[\s\S]*?\*\//g, "")
    .replace(/\s+/g, " ")
    .replace(/\s*([{}:;,>])\s*/g, "$1")
    .replace(/;}/g, "}")
    .trim();
}

async function readText(file) {
  return readFile(path.join(root, file), "utf8");
}

await mkdir(path.join(root, "inst/www"), { recursive: true });

const jsParts = await Promise.all(runtimeFiles.map(readText));
const js = `${jsParts.join("\n")}\n`;
await writeFile(
  path.join(root, "inst/www/shinyblocks-runtime.js"),
  `${minifyJs(js)}\n`
);

const css = await readText("frontend/src/styles/runtime.css");
await writeFile(
  path.join(root, "inst/www/shinyblocks-runtime.css"),
  `${minifyCss(css)}\n`
);

console.log("Built inst/www/shinyblocks-runtime.js");
console.log("Built inst/www/shinyblocks-runtime.css");
