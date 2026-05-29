// Allowlist for the static theme-conformance check (check-token-usage.mjs).
//
// The check fails when an *applied* color property (color, background-color,
// border-*-color, outline-color, fill, stroke, accent-color) uses a literal
// color instead of a `var(--token)`. Anything below is a deliberate,
// documented exception. Keep this list short and justify every entry.

// CSS-wide keywords that are not theme colors. These never need a token.
export const ALLOWED_KEYWORDS = new Set([
  "transparent",
  "currentcolor",
  "inherit",
  "initial",
  "unset",
  "revert",
  "none"
]);

// Specific literal values that are intentionally fixed and shadcn-accurate.
// Each entry must name the rule(s) it covers and why a token is wrong.
export const ALLOWED_LITERALS = [
  {
    // shadcn destructive button/badge foreground is `text-white` in both
    // light and dark themes; white-on-destructive is the upstream contract.
    value: "white",
    reason:
      "shadcn destructive surfaces use text-white (not a theme token) in both themes"
  },
  {
    // shadcn dialog overlay is `bg-black/50` — a fixed scrim, theme-independent.
    value: "rgb(0 0 0 / 0.5)",
    reason: "shadcn dialog overlay scrim is a fixed bg-black/50, not a token"
  }
];

const NORMALISED_LITERALS = new Set(
  ALLOWED_LITERALS.map((entry) => entry.value.replace(/\s+/g, " ").trim().toLowerCase())
);

// Custom-property *definitions* (e.g. `--primary: oklch(...)`,
// `--sb-code-token-keyword: #d73a49`) are the token source of truth and the
// fixed syntax-highlight palette — they are not "applied" colors and are
// skipped by the scanner entirely, so they need no entry here.

export function isAllowedColorValue(rawValue) {
  const value = rawValue.replace(/\s+/g, " ").trim().toLowerCase();
  if (value.length === 0) {
    return true;
  }
  if (value.startsWith("var(")) {
    return true;
  }
  if (ALLOWED_KEYWORDS.has(value)) {
    return true;
  }
  if (NORMALISED_LITERALS.has(value)) {
    return true;
  }
  // color-mix(...) expressions are token-driven when every color argument is a
  // var()/keyword. Treat the whole expression as allowed only if it contains
  // no bare hex / rgb / hsl / named literal outside an allowed keyword.
  if (value.startsWith("color-mix(")) {
    return !containsLiteralColor(value);
  }
  return false;
}

// Detects a literal color token (hex, rgb(), hsl(), or a small set of named
// colors) anywhere in an expression, ignoring var() references.
const LITERAL_COLOR = /#[0-9a-f]{3,8}\b|\brgba?\(|\bhsla?\(|\b(white|black|red|blue|green|gray|grey)\b/i;

export function containsLiteralColor(value) {
  const withoutVars = value.replace(/var\([^)]*\)/gi, "");
  // Allow the documented fixed scrim inside expressions.
  const cleaned = withoutVars.replace(/rgb\(0 0 0 \/ 0?\.5\)/gi, "");
  return LITERAL_COLOR.test(cleaned);
}
