// Browser-free unit tests for the style-registry R parser
// (tools/theme/style-registry.mjs). The profile-parity sweep
// (check-style-parity.mjs) exercises this parser end-to-end, but only with a
// live showcase on :4321. These tests lock the parser's behaviour — especially
// resolving the recipe-helper splices `c(list(...), helper(), ...)` in
// R/style-profiles.R — without needing a browser, so a regression is caught in
// check-slice rather than only in the browser gate.
//
// Run: node --test tools/theme/style-registry.test.mjs

import test from "node:test";
import assert from "node:assert/strict";

import {
  styleProfileNames,
  profileTokenOverrides,
  profileTokenNames
} from "./style-registry.mjs";

// A profile's overrides as a { token: value } map, e.g. { "--sb-card-radius": "2rem" }.
function overridesMap(profile) {
  const out = {};
  for (const decl of profileTokenOverrides(profile).split(";")) {
    const m = decl.match(/^\s*(--[a-z0-9-]+):\s*(.*)$/);
    if (m) out[m[1]] = m[2];
  }
  return out;
}

test("styleProfileNames lists profiles, including c()-composed ones, excluding default", () => {
  const names = styleProfileNames();
  assert.deepEqual(names, ["mono", "soft", "brutal", "glass", "luma", "rhea"]);
  assert.ok(!names.includes("default"), "default is a no-op profile and must be excluded");
});

test("plain list() profiles (mono) still parse their literal tokens", () => {
  const mono = overridesMap("mono");
  assert.equal(mono["--sb-font-body"], "var(--sb-font-mono)");
  assert.equal(mono["--sb-control-height"], "2rem");
  assert.equal(mono["--sb-card-shadow"], "none");
});

test("c()-composed profiles resolve the spliced translucent-surface helper", () => {
  for (const profile of ["luma", "rhea", "glass"]) {
    const o = overridesMap(profile);
    // These tokens exist ONLY in style_translucent_surface_tokens(); a parser
    // that ignored the helper splice would drop them.
    assert.equal(
      o["--sb-input-surface"],
      "color-mix(in oklch, var(--input) 50%, transparent)",
      `${profile} should inherit input_surface from the translucent helper`
    );
    assert.equal(o["--sb-input-border"], "transparent", `${profile} input border`);
    assert.equal(o["--sb-switch-surface"], "color-mix(in oklch, var(--input) 90%, transparent)");
    assert.equal(o["--sb-slider-track-surface"], "color-mix(in oklch, var(--input) 90%, transparent)");
  }
});

test("c()-composed profiles resolve the spliced foreground-ring helper", () => {
  for (const profile of ["luma", "rhea", "glass"]) {
    const o = overridesMap(profile);
    // Tokens that exist ONLY in style_foreground_ring_tokens().
    assert.equal(o["--sb-card-border"], "transparent", `${profile} card border`);
    assert.match(o["--sb-card-shadow"], /^var\(--sb-surface-shadow\), 0 0 0 1px color-mix/);
    assert.equal(o["--sb-value-box-border"], "transparent");
    assert.match(o["--sb-select-content-shadow"], /^var\(--sb-overlay-shadow\), 0 0 0 1px color-mix/);
    assert.match(o["--sb-popover-shadow"], /^var\(--sb-overlay-shadow\), 0 0 0 1px color-mix/);
  }
});

test("per-profile helper argument (value_box_shadow) is scraped from the call site", () => {
  // value_box_shadow is a required arg of style_foreground_ring_tokens(), passed
  // literally at each call site — Luma keeps an explicit drop shadow, Rhea uses
  // the var-based recipe. The parser must read each profile's own value.
  const luma = overridesMap("luma");
  const rhea = overridesMap("rhea");
  assert.ok(
    luma["--sb-value-box-shadow"].startsWith("0 4px 6px"),
    "Luma keeps its explicit drop shadow"
  );
  assert.ok(
    rhea["--sb-value-box-shadow"].startsWith("var(--sb-surface-shadow)"),
    "Rhea uses the var-based recipe shadow"
  );
  assert.notEqual(luma["--sb-value-box-shadow"], rhea["--sb-value-box-shadow"]);
});

test("profileTokenNames includes both literal and helper-derived tokens", () => {
  const luma = profileTokenNames("luma");
  // literal (radius) + translucent helper (surface) + ring helper (border).
  for (const t of ["card_radius", "input_surface", "card_border", "value_box_shadow"]) {
    assert.ok(luma.includes(t), `luma token list should include ${t}`);
  }
});

test("profileTokenOverrides throws if a profile sets an unmapped token", () => {
  // A profile whose name has no `= list(` / `= c(` block parses to nothing,
  // which surfaces as an explicit error rather than silently emitting nothing.
  assert.throws(() => profileTokenOverrides("does_not_exist"), /Parsed no token overrides/);
});
