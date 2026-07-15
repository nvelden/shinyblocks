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
// property in the default profile, then toggle the page into each non-default
// profile exactly as block_page(style = block_style("<profile>")) would: stamp
// data-sb-style="<profile>" on .sb-app and inject the --sb-* token overrides
// parsed from that profile's list in R/style-profiles.R — and assert the
// property *changes*. If a component stopped responding to the profile (e.g. a
// hardcoded radius), the property will not change and the check fails.
//
// Profiles are swept generically (styleProfileNames()), so a new profile is
// checked with no edits here — mirroring the colour-preset sweep in
// check-theme-response.mjs. Each registry binding names a property the profile
// is expected to shift for most profiles (radii/surfaces are token-driven;
// switch/slider/radio geometry is CSS-driven), so "changed from default" is the
// portable invariant that proves the profile reaches every component. A
// registry entry can declare `neutralProfiles` for a specific profile that
// intentionally leaves a measured structural binding unchanged.

import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { chromium } from "playwright";
import {
  STYLE_REGISTRY,
  styleProfileNames,
  profileTokenOverrides,
  profileTokenNames
} from "./style-registry.mjs";
import { RSIDE_PRIMITIVES } from "./theme-registry.mjs";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, "..", "..");
const SHOWCASE_URL = process.env.SHOWCASE_URL || "http://127.0.0.1:4321";

// Navigate to the showcase, turning a connection failure into an actionable
// message instead of letting Playwright's raw error bubble up. The caller's
// try/finally still closes the browser so the process exits instead of hanging.
async function gotoShowcase(page, url) {
  try {
    await page.goto(url, { waitUntil: "networkidle" });
  } catch (err) {
    if (/ERR_CONNECTION_REFUSED|ERR_CONNECTION/.test(String(err))) {
      throw new Error(
        `Showcase not reachable at ${url}. Start it first: \`make showcase\` ` +
          `(or set SHOWCASE_URL). This browser check needs the live showcase.`
      );
    }
    throw err;
  }
}

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

// --- Overlay presence check -----------------------------------------------
// Portal overlays (dialog/popover/tooltip) only render after interaction, so we
// cannot measure them in a static page. Instead assert the profile actually
// affects the component: it sets at least one `<name>_*` token, or it has a
// [data-sb-style="<profile>"] rule referencing the component's `sb-<name>-`
// classes. This replaces the previous (false) "covered by a static CSS scan"
// claim — there was no such scan.
const RUNTIME_CSS = fs.readFileSync(
  path.join(ROOT, "frontend", "src", "styles", "runtime.css"),
  "utf8"
);

function overlayAffected(profile, name) {
  const tokens = profileTokenNames(profile);
  const hasToken = tokens.some((t) => t === name || t.startsWith(`${name}_`));
  const cssRe = new RegExp(`\\[data-sb-style="${profile}"\\][^{]*sb-${name}-`);
  const hasCss = cssRe.test(RUNTIME_CSS);
  return { hasToken, hasCss, ok: hasToken || hasCss };
}

// --- Runtime profile-toggle check ----------------------------------------
async function disableMotion(page) {
  await page.addStyleTag({
    content:
      "*,*::before,*::after{transition:none !important;animation:none !important}"
  });
}

async function measureProfileShift(page, selector, property, profile, tokenOverrides) {
  return await page.evaluate(
    ({ selector, property, profile, tokenOverrides }) => {
      const el = document.querySelector(selector);
      if (!el) return { missing: true };
      const before = getComputedStyle(el)[property];

      const app = document.querySelector(".sb-app") || document.documentElement;
      const prevStyle = app.dataset.sbStyle;
      app.dataset.sbStyle = profile;

      const style = document.createElement("style");
      style.id = "__sb_style_probe__";
      style.textContent = `[data-sb-style="${profile}"]{${tokenOverrides}}`;
      document.head.appendChild(style);

      void el.offsetHeight;
      const after = getComputedStyle(el)[property];

      style.remove();
      if (prevStyle === undefined) delete app.dataset.sbStyle;
      else app.dataset.sbStyle = prevStyle;

      return { before, after };
    },
    { selector, property, profile, tokenOverrides }
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

  const profiles = styleProfileNames();
  if (profiles.length === 0) {
    console.log("No non-default style profiles to check.");
    return;
  }

  const browser = await chromium.launch();
  try {
    const page = await browser.newPage();
    await gotoShowcase(page, SHOWCASE_URL);
    await disableMotion(page);

    for (const profile of profiles) {
      const tokenOverrides = profileTokenOverrides(profile);
      console.log(`\n--- profile: ${profile} ---`);

      for (const [name, config] of Object.entries(STYLE_REGISTRY)) {
        const neutralReason = config.neutralProfiles?.[profile];
        if (neutralReason) {
          neutrals.push(`${profile} :: ${name} (profile-neutral: ${neutralReason})`);
          continue;
        }

        const mode = config.mode || "profile";
        if (mode === "overlay") {
          const overlayName = config.overlayAlias || name;
          const a = overlayAffected(profile, overlayName);
          if (a.ok) {
            passes += 1;
            const via = [a.hasToken && "tokens", a.hasCss && "css"]
              .filter(Boolean)
              .join("+");
            overlays.push(`${profile} :: ${name} (overlay, via ${via})`);
          } else {
            failures += 1;
            console.error(
              `  FAIL ${profile} :: ${name} (overlay) — profile sets no ${overlayName}_* ` +
                `token and has no [data-sb-style="${profile}"] ${overlayName} rule`
            );
          }
          continue;
        }
        if (mode === "profile-neutral") {
          neutrals.push(`${profile} :: ${name} (profile-neutral: ${config.reason})`);
          continue;
        }

        await page.waitForSelector(config.bindings[0].selector, {
          state: "attached",
          timeout: 10000
        });

        for (const b of config.bindings) {
          const r = await measureProfileShift(
            page,
            b.selector,
            b.property,
            profile,
            tokenOverrides
          );
          const label = `${profile} :: ${name} :: ${b.property} (${b.selector})`;
          if (r.missing) {
            failures += 1;
            console.error(`  FAIL ${label}  (element not found)`);
          } else if (r.after !== r.before) {
            passes += 1;
            console.log(`  ok   ${label}  ${r.before} -> ${r.after}`);
          } else {
            failures += 1;
            console.error(
              `  FAIL ${label}  unchanged under ${profile} (${r.before}) — component does not respond to the style profile`
            );
          }
        }
      }
    }
  } finally {
    await browser.close();
  }

  console.log(
    `\nStyle parity: ${passes} passed, ${failures} failed, ` +
      `${overlays.length} overlay, ${neutrals.length} profile-neutral ` +
      `across ${profiles.length} profile(s): ${profiles.join(", ")}.`
  );
  if (overlays.length) {
    console.log("Overlay (rendered on interaction):");
    for (const s of overlays) console.log(`  - ${s}`);
  }
  if (neutrals.length) {
    console.log("Profile-neutral:");
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
