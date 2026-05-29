// Layer 2 + 3 of the theme-conformance framework: a Playwright check that
// proves every component re-colors when a theme token changes, plus a
// completeness gate that fails when an exported component is not registered.
//
// Usage:  node tools/theme/check-theme-response.mjs
//         SHOWCASE_URL=http://127.0.0.1:4321 node tools/theme/check-theme-response.mjs
//
// Requires the local Shiny showcase running (default http://127.0.0.1:4321).
//
// Mechanism (per binding): scope a `--token: <sentinel>` override to the
// component's section, then assert the element's computed property becomes the
// sentinel rgb. If the property is hardcoded (not var(--token)) it will not
// change and the check fails. Runs in light and dark.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import { THEME_REGISTRY, RSIDE_PRIMITIVES } from "./theme-registry.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");
const SHOWCASE_URL = process.env.SHOWCASE_URL || "http://127.0.0.1:4321";

const SENTINELS = {
  light: "rgb(1, 2, 3)",
  dark: "rgb(4, 5, 6)"
};

// --- Completeness gate ----------------------------------------------------
// Read RUNTIME_COMPONENT_NAMES from R/runtime.R so the gate tracks the single
// source of truth without duplicating the list here.
function runtimeComponentNames() {
  const src = fs.readFileSync(path.join(ROOT, "R", "runtime.R"), "utf8");
  const m = src.match(/RUNTIME_COMPONENT_NAMES\s*<-\s*c\(([\s\S]*?)\)/);
  if (!m) {
    throw new Error("Could not find RUNTIME_COMPONENT_NAMES in R/runtime.R");
  }
  return [...m[1].matchAll(/"([^"]+)"/g)].map((x) => x[1]);
}

function checkCompleteness() {
  const required = [...runtimeComponentNames(), ...RSIDE_PRIMITIVES];
  const registered = new Set(Object.keys(THEME_REGISTRY));
  const missing = required.filter((name) => !registered.has(name));
  if (missing.length > 0) {
    console.error(
      "Theme completeness gate FAILED. These components have no theme bindings " +
        "declared in tools/theme/theme-registry.mjs:\n"
    );
    for (const name of missing) console.error(`  - ${name}`);
    console.error(
      "\nAdd a registry entry (mode \"runtime\" with bindings, or \"static-only\" " +
        "with a reason) so the component is covered by the theme framework."
    );
    return false;
  }
  return true;
}

// --- Runtime token-override check ----------------------------------------
async function setTheme(page, mode) {
  await page.evaluate((m) => {
    document.documentElement.dataset.theme = m;
  }, mode);
  await page.waitForTimeout(80);
}

// Components animate color/background changes (transition: ...). Disable all
// transitions/animations so getComputedStyle reports the settled value
// immediately after a token override instead of the mid-transition value.
async function disableMotion(page) {
  await page.addStyleTag({
    content:
      "*,*::before,*::after{transition:none !important;animation:none !important}"
  });
}

async function measureWithOverride(page, section, selector, property, token, sentinel) {
  return await page.evaluate(
    ({ section, selector, property, token, sentinel }) => {
      const el = document.querySelector(selector);
      if (!el) return { missing: true };
      const before = getComputedStyle(el)[property];

      const style = document.createElement("style");
      style.id = "__sb_theme_probe__";
      // Force the token to a sentinel on every element. `* { --token: x
      // !important }` makes any `var(--token)` resolve to the sentinel
      // regardless of which ancestor (html/body/.sb-app/runtime root) declares
      // it, so both component-owned and inherited colors are exercised. We
      // measure one element per binding and remove the style afterwards.
      style.textContent = `*{${token}: ${sentinel} !important;}`;
      document.head.appendChild(style);

      // Force reflow so the override is applied before measuring.
      void el.offsetHeight;
      const after = getComputedStyle(el)[property];
      style.remove();
      return { before, after };
    },
    { section, selector, property, token, sentinel }
  );
}

async function run() {
  let failures = 0;
  let passes = 0;
  const skips = [];

  if (!checkCompleteness()) {
    process.exitCode = 1;
    return;
  }

  const browser = await chromium.launch();
  const page = await browser.newPage();

  for (const [name, config] of Object.entries(THEME_REGISTRY)) {
    if (config.mode === "static-only") {
      skips.push(`${name} (static-only: ${config.reason})`);
      continue;
    }

    await page.goto(`${SHOWCASE_URL}/#${config.section}`, {
      waitUntil: "networkidle"
    });
    await page.waitForTimeout(600);
    await disableMotion(page);

    for (const mode of ["light", "dark"]) {
      await setTheme(page, mode);
      const sentinel = SENTINELS[mode];

      for (const b of config.bindings) {
        const r = await measureWithOverride(
          page,
          config.section,
          b.selector,
          b.property,
          b.token,
          sentinel
        );
        const label = `${name} :: ${mode} :: ${b.property} -> ${b.token}`;
        if (r.missing) {
          failures += 1;
          console.error(`  FAIL ${label}  (element not found: ${b.selector})`);
        } else if (r.after === sentinel) {
          passes += 1;
          console.log(`  ok   ${label}`);
        } else {
          failures += 1;
          console.error(
            `  FAIL ${label}  expected ${sentinel}, got ${r.after} (before ${r.before}) — property not bound to ${b.token}`
          );
        }
      }
    }
  }

  await browser.close();

  console.log(
    `\nTheme response: ${passes} passed, ${failures} failed, ${skips.length} static-only.`
  );
  if (skips.length) {
    console.log("Static-only (CSS token-driven, behaviourally covered by Layer 1):");
    for (const s of skips) console.log(`  - ${s}`);
  }
  if (failures > 0) {
    process.exitCode = 1;
  }
}

run().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
