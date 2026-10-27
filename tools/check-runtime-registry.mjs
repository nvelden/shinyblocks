// Cross-layer runtime registration gate.
//
// Runtime components are declared independently by R, React dispatch, and the
// Shiny input-binding layer. A missing entry in any one list produces a mount
// that looks valid in generated HTML but never renders or binds. Keep these
// lists mechanically identical where their contracts overlap.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..");

function read(relativePath) {
  return fs.readFileSync(path.join(ROOT, relativePath), "utf8");
}

function quotedValues(body) {
  return [...body.matchAll(/"([^"]+)"/g)].map((match) => match[1]);
}

function assignedRVector(source, name) {
  const match = source.match(new RegExp(`${name}\\s*<-\\s*c\\(([\\s\\S]*?)\\)`));
  if (!match) throw new Error(`Could not find ${name} in R/runtime.R.`);
  return quotedValues(match[1]);
}

function assignedJsSet(source, name) {
  const match = source.match(new RegExp(`${name}\\s*=\\s*new Set\\(\\[([\\s\\S]*?)\\]\\)`));
  if (!match) throw new Error(`Could not find ${name} in bindings.js.`);
  return quotedValues(match[1]);
}

function componentObjectKeys(source) {
  const match = source.match(/const COMPONENTS\s*=\s*\{([\s\S]*?)\n\};/);
  if (!match) throw new Error("Could not find COMPONENTS in frontend/src/index.jsx.");
  return [...match[1].matchAll(/^\s*(?:"([^"]+)"|([a-z][a-z0-9-]*))\s*:/gm)]
    .map((entry) => entry[1] || entry[2]);
}

function bindingComponents(source) {
  const start = source.indexOf("const BINDING_CONFIGS = [");
  const end = source.indexOf("\n];", start);
  if (start < 0 || end < 0) throw new Error("Could not find BINDING_CONFIGS in bindings.js.");
  return [...source.slice(start, end).matchAll(/^\s*component:\s*"([^"]+)"/gm)]
    .map((entry) => entry[1]);
}

function bindingNames(source) {
  const match = source.match(/const BINDING_NAMES\s*=\s*\[([\s\S]*?)\n\];/);
  if (!match) throw new Error("Could not find BINDING_NAMES in bindings.js.");
  return quotedValues(match[1]).map((name) => name.replace(/^shinyblocks\./, "").replaceAll("_", "-"));
}

function compare(label, expected, actual, findings) {
  const expectedSet = new Set(expected);
  const actualSet = new Set(actual);
  const missing = expected.filter((value) => !actualSet.has(value));
  const extra = actual.filter((value) => !expectedSet.has(value));
  const duplicates = actual.filter((value, index) => actual.indexOf(value) !== index);
  if (missing.length || extra.length || duplicates.length) {
    findings.push({ label, missing, extra, duplicates: [...new Set(duplicates)] });
  }
}

const rRuntime = read("R/runtime.R");
const indexSource = read("frontend/src/index.jsx");
const bindingsSource = read("frontend/src/runtime/bindings.js");
const runtimeComponents = assignedRVector(rRuntime, "RUNTIME_COMPONENT_NAMES");
const inputComponents = assignedJsSet(bindingsSource, "RUNTIME_INPUT_COMPONENTS");
const findings = [];

compare("React COMPONENTS vs RUNTIME_COMPONENT_NAMES", runtimeComponents, componentObjectKeys(indexSource), findings);
compare("BINDING_CONFIGS vs RUNTIME_INPUT_COMPONENTS", inputComponents, bindingComponents(bindingsSource), findings);
compare("BINDING_NAMES vs RUNTIME_INPUT_COMPONENTS", inputComponents, bindingNames(bindingsSource), findings);

const unknownInputs = inputComponents.filter((name) => !runtimeComponents.includes(name));
if (unknownInputs.length) {
  findings.push({
    label: "RUNTIME_INPUT_COMPONENTS must be runtime components",
    missing: [],
    extra: unknownInputs,
    duplicates: []
  });
}

if (findings.length) {
  console.error("Runtime registry gate FAILED:\n");
  for (const finding of findings) {
    console.error(`  ${finding.label}`);
    if (finding.missing.length) console.error(`    missing: ${finding.missing.join(", ")}`);
    if (finding.extra.length) console.error(`    extra: ${finding.extra.join(", ")}`);
    if (finding.duplicates.length) console.error(`    duplicate: ${finding.duplicates.join(", ")}`);
  }
  process.exitCode = 1;
} else {
  console.log(
    `Runtime registry gate passed: ${runtimeComponents.length} renderers and ` +
      `${inputComponents.length} input bindings are in cross-layer lockstep.`
  );
}
