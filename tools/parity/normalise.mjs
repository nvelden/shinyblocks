function collapseWhitespace(value) {
  return String(value ?? "").trim().replace(/\s+/g, " ");
}

function normaliseZero(value) {
  return value
    .replace(/\b0(px|rem|em|%)\b/g, "0")
    .replace(/\btransparent\b/g, "rgba(0, 0, 0, 0)");
}

function roundNumberString(raw, digits = 3) {
  const number = Number(raw);
  if (Number.isNaN(number)) {
    return raw;
  }
  return String(Math.round(number * 10 ** digits) / 10 ** digits);
}

export function normaliseValue(property, value) {
  let out = collapseWhitespace(value);
  if (out === "none") {
    return out;
  }

  out = normaliseZero(out);

  // Tailwind v4 emits `rounded-full` as `calc(infinity * 1px)`, which Chromium
  // computes to ~3.35544e+07px; shinyblocks runtime CSS uses `9999px`. Both
  // collapse to the same pill shape at any realistic size.
  if (/border.*radius/i.test(property)) {
    const match = out.match(/^(-?\d+(?:\.\d+)?(?:e[+-]?\d+)?)px$/i);
    if (match) {
      const px = Number(match[1]);
      if (!Number.isNaN(px) && px >= 9999) {
        return "pill";
      }
    }
  }

  // Tailwind v4 emits `inline-flex` as the two-value `display: inline flex`,
  // which Chromium's getComputedStyle reports as `flex`. shinyblocks runtime
  // CSS uses single-keyword `inline-flex`. Both are inline-level flex
  // containers — visually identical — so collapse to one canonical form.
  if (property === "display" && (out === "flex" || out === "inline-flex" || out === "inline flex")) {
    return "inline-flex";
  }

  // `min-height: 0` and `min-height: auto` resolve to the same layout for
  // most flex/grid items — both effectively allow the item to shrink to its
  // content. Collapse to one form so UA defaults vs explicit `auto` don't
  // register as a drift.
  if ((property === "minHeight" || property === "minWidth") && (out === "0" || out === "0px" || out === "auto")) {
    return "auto";
  }

  if (property.toLowerCase().includes("color")) {
    return out.toLowerCase();
  }

  if (property === "boxShadow") {
    return out
      .replace(/okl(?:ab|ch)\(([^)]+)\)/g, (_match, body) => `okl(${body})`)
      .replace(/rgba\((\d+), (\d+), (\d+), ([\d.]+)\)/gi, (_match, r, g, b, a) => {
        return `rgba(${r}, ${g}, ${b}, ${roundNumberString(a, 2)})`;
      })
      .replace(/(-?\d+(?:\.\d+)?(?:e[+-]?\d+)?)(px|rem|em)/gi, (_match, value, unit) => {
        return `${roundNumberString(value, 2)}${unit}`;
      })
      .replace(/(?:rgba\(0, 0, 0, 0\) 0 0(?:px)? 0 0(?:px)?(?:,\s*)?)+/g, "")
      .replace(/(?:,\s*)?rgba\(0, 0, 0, 0\) 0 0(?:px)? 0 0(?:px)?/g, "")
      .replace(/,\s+/g, ", ");
  }

  if (/^rgba?\(/i.test(out)) {
    return out
      .replace(/rgba?\(([^)]+)\)/i, (_match, body) => {
        const parts = body.split(",").map((part) => part.trim());
        if (parts.length === 4) {
          const alpha = Number(parts[3]);
          if (!Number.isNaN(alpha)) {
            parts[3] = String(Math.round(alpha * 1000) / 1000);
          }
        }
        return `rgba(${parts.join(", ")})`;
      })
      .toLowerCase();
  }

  if (/^#/.test(out)) {
    return out.toLowerCase();
  }

  return out;
}

export function normaliseStyles(styles) {
  const out = Object.fromEntries(
    Object.entries(styles).map(([key, value]) => [key, normaliseValue(key, value)])
  );

  // When a border side has zero width, its computed color is visually
  // irrelevant but varies between Tailwind v4 reference (inherits `color`)
  // and runtime CSS (defaults to `currentColor` -> transparent for buttons).
  // Collapse those cases so we do not chase a non-visible drift.
  for (const side of ["Top", "Right", "Bottom", "Left"]) {
    const width = out[`border${side}Width`];
    if (width === "0" || width === "0px") {
      const colorKey = `border${side}Color`;
      if (colorKey in out) {
        out[colorKey] = "n/a (zero-width border)";
      }
    }
  }

  return out;
}
