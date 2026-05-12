import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";

const root = process.cwd();

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

const css = await readText("frontend/src/styles/runtime.css");
await writeFile(
  path.join(root, "inst/www/shinyblocks-runtime.css"),
  `${minifyCss(css)}\n`
);

console.log("Built inst/www/shinyblocks-runtime.css");
