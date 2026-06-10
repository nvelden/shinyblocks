// Style-ownership gate (issue #50).
//
// A user `style=` argument must apply to exactly one DOM node. The owner is the
// mount `<div data-shinyblocks-root>` emitted by runtime_component() in
// R/runtime.R, which carries the user style for every in-flow component. A React
// renderer must therefore NOT also spread `payload.style` onto its own root, or
// the style double-applies to two nested elements (border draws twice, padding
// nests, etc.).
//
// This gate scans the runtime component renderers and fails when any of them
// references `payload.style`. The single justified exception is a component
// whose visible root is rendered through a portal, outside the mount subtree:
// there the mount div can never reach it, so the renderer owns the user style on
// its portaled root and runtime_component() leaves the mount div plain (see
// RUNTIME_CONTENT_STYLE_COMPONENTS in R/runtime.R). Keep OWNERSHIP_ALLOWLIST in
// sync with that list.
//
// Usage:  node tools/theme/check-style-ownership.mjs

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");

const COMPONENTS_DIR = path.join(ROOT, "frontend", "src", "components");

// Portaled-content renderers that legitimately own the user style on their own
// root. Mirror RUNTIME_CONTENT_STYLE_COMPONENTS in R/runtime.R.
const OWNERSHIP_ALLOWLIST = [
  {
    file: "dialog.jsx",
    reason:
      "Dialog content is portaled to document.body, outside the mount subtree, so the mount div can never style it. runtime_component() leaves dialog's mount div plain and the content owns payload.style."
  },
  {
    file: "toaster.jsx",
    reason:
      "The toaster region is portaled to the package portal root, outside the mount subtree, so the mount div can never style it. runtime_component() leaves toaster's mount div plain and the portaled region owns payload.style."
  }
];

// Matches `payload.style` and `payload["style"]` / `payload['style']`.
const STYLE_REF = /payload\s*(?:\.\s*style\b|\[\s*["']style["']\s*\])/;

function isAllowlisted(file) {
  return OWNERSHIP_ALLOWLIST.some((a) => a.file === file);
}

function run() {
  const findings = [];
  let scanned = 0;

  const files = fs
    .readdirSync(COMPONENTS_DIR)
    .filter((f) => f.endsWith(".jsx"))
    .sort();

  for (const file of files) {
    const text = fs.readFileSync(path.join(COMPONENTS_DIR, file), "utf8");
    // Strip block and line comments so prose mentioning payload.style is ignored.
    const code = text
      .replace(/\/\*[\s\S]*?\*\//g, "")
      .replace(/\/\/[^\n]*/g, "");
    scanned += 1;

    const lines = code.split("\n");
    lines.forEach((line, idx) => {
      if (STYLE_REF.test(line) && !isAllowlisted(file)) {
        findings.push({ file, line: idx + 1, text: line.trim() });
      }
    });
  }

  if (findings.length > 0) {
    console.error(
      "Style ownership gate FAILED. These renderers spread `payload.style` onto " +
        "their own root, double-applying the user style (the mount div in " +
        "R/runtime.R already owns it):\n"
    );
    for (const f of findings) {
      console.error(`  frontend/src/components/${f.file}:${f.line}`);
      console.error(`    ${f.text}`);
    }
    console.error(
      "\nRemove the `payload.style` reference so the mount div is the single " +
        "owner. If the component's root is portaled (outside the mount subtree), " +
        "add a justified entry to OWNERSHIP_ALLOWLIST and " +
        "RUNTIME_CONTENT_STYLE_COMPONENTS in R/runtime.R."
    );
    process.exitCode = 1;
    return;
  }

  console.log(
    `Style ownership gate passed: scanned ${scanned} renderer(s), no double ` +
      `payload.style spread (allowlisted portaled components: ${OWNERSHIP_ALLOWLIST.length}).`
  );
}

run();
