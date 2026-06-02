// Profile-parity check: proves every shipped component responds to the active
// visual style profile (block_style()/data-sb-style), or has explicitly
// declared that the profile does not affect it.
//
// Usage:  node tools/theme/check-style-parity.mjs
//         SHOWCASE_URL=http://127.0.0.1:4321 node tools/theme/check-style-parity.mjs
//
// Requires the local Shiny showcase running (default http://127.0.0.1:4321).
//
// This is the style-profile analogue of check-theme-response.mjs and is kept
// separate from it so failures stay diagnosable: a colour-token regression
// fails the theme check; a profile regression fails this one.
//
// Mechanism (per "profile" binding): measure the profile-sensitive computed
// property in the default profile, then toggle the page into Luma exactly as
// block_page(style = block_style("luma")) would — stamp data-sb-style="luma" on
// .sb-app and inject the shared --sb-* token overrides parsed from
// R/style-profiles.R — and assert the property *changes*. If a component stopped
// responding to the profile (e.g. a hardcoded radius), the property will not
// change and the check fails.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import { STYLE_REGISTRY, lumaTokenOverrides } from "./style-registry.mjs";
import { RSIDE_PRIMITIVES } from "./theme-registry.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");
const SHOWCASE_URL = process.env.SHOWCASE_URL || "http://127.0.0.1:4321";

// --- Completeness gate ----------------------------------------------------
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
  const registered = new Set(Object.keys(STYLE_REGISTRY));
  const missing = required.filter((name) => !registered.has(name));
  if (missing.length > 0) {
    console.error(
      "Style-profile completeness gate FAILED. These components declare no " +
        "profile coverage in tools/theme/style-registry.mjs:\n"
    );
    for (const name of missing) console.error(`  - ${name}`);
    console.error(
      "\nAdd a registry entry: mode \"profile\" with bindings that change under " +
        "Luma, \"overlay\" (with a reason) for portal surfaces, or " +
        "\"profile-neutral\" (with a reason) when Luma leaves the component alone."
    );
    return false;
  }
  // Validate that non-runtime modes carry a reason.
  let ok = true;
  for (const [name, config] of Object.entries(STYLE_REGISTRY)) {
    const mode = config.mode || "profile";
    if ((mode === "overlay" || mode === "profile-neutral") && !config.reason) {
      console.error(`Style registry: ${name} (mode ${mode}) is missing a reason.`);
      ok = false;
    }
  }
  return ok;
}

// --- Runtime profile-toggle check ----------------------------------------
async function disableMotion(page) {
  await page.addStyleTag({
    content:
      "*,*::before,*::after{transition:none !important;animation:none !important}"
  });
}

async function measureProfileShift(page, selector, property, tokenOverrides) {
  return await page.evaluate(
    ({ selector, property, tokenOverrides }) => {
      const el = document.querySelector(selector);
      if (!el) return { missing: true };
      const before = getComputedStyle(el)[property];

      const app = document.querySelector(".sb-app") || document.documentElement;
      const prevStyle = app.dataset.sbStyle;
      app.dataset.sbStyle = "luma";

      const style = document.createElement("style");
      style.id = "__sb_style_probe__";
      style.textContent = `[data-sb-style="luma"]{${tokenOverrides}}`;
      document.head.appendChild(style);

      void el.offsetHeight;
      const after = getComputedStyle(el)[property];

      style.remove();
      if (prevStyle === undefined) delete app.dataset.sbStyle;
      else app.dataset.sbStyle = prevStyle;

      return { before, after };
    },
    { selector, property, tokenOverrides }
  );
}

async function run() {
  let failures = 0;
  let passes = 0;
  const overlays = [];
  const neutrals = [];

  if (!checkCompleteness()) {
    process.exitCode = 1;
    return;
  }

  const tokenOverrides = lumaTokenOverrides();

  const browser = await chromium.launch();
  const page = await browser.newPage();

  for (const [name, config] of Object.entries(STYLE_REGISTRY)) {
    const mode = config.mode || "profile";
    if (mode === "overlay") {
      overlays.push(`${name} (overlay: ${config.reason})`);
      continue;
    }
    if (mode === "profile-neutral") {
      neutrals.push(`${name} (profile-neutral: ${config.reason})`);
      continue;
    }

    await page.goto(`${SHOWCASE_URL}/#${config.section}`, {
      waitUntil: "networkidle"
    });
    await page.waitForTimeout(600);
    await disableMotion(page);

    for (const b of config.bindings) {
      const r = await measureProfileShift(page, b.selector, b.property, tokenOverrides);
      const label = `${name} :: ${b.property} (${b.selector})`;
      if (r.missing) {
        failures += 1;
        console.error(`  FAIL ${label}  (element not found)`);
      } else if (r.after !== r.before) {
        passes += 1;
        console.log(`  ok   ${label}  ${r.before} -> ${r.after}`);
      } else {
        failures += 1;
        console.error(
          `  FAIL ${label}  unchanged under Luma (${r.before}) — component does not respond to the style profile`
        );
      }
    }
  }

  await browser.close();

  console.log(
    `\nStyle parity: ${passes} passed, ${failures} failed, ` +
      `${overlays.length} overlay, ${neutrals.length} profile-neutral.`
  );
  if (overlays.length) {
    console.log("Overlay (Luma CSS present, rendered on interaction):");
    for (const s of overlays) console.log(`  - ${s}`);
  }
  if (neutrals.length) {
    console.log("Profile-neutral (Luma intentionally leaves these unchanged):");
    for (const s of neutrals) console.log(`  - ${s}`);
  }
  if (failures > 0) {
    process.exitCode = 1;
  }
}

run().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
