function collapseWhitespace(value) {
  return String(value ?? "").trim().replace(/\s+/g, " ");
}

function normaliseZero(value) {
  return value
    .replace(/\b0(px|rem|em|%)\b/g, "0")
    .replace(/\btransparent\b/g, "rgba(0, 0, 0, 0)");
}

export function normaliseValue(property, value) {
  let out = collapseWhitespace(value);
  if (out === "none") {
    return out;
  }

  out = normaliseZero(out);

  if (property.toLowerCase().includes("color")) {
    return out.toLowerCase();
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

  if (property === "boxShadow") {
    return out.replace(/,\s+/g, ", ");
  }

  return out;
}

export function normaliseStyles(styles) {
  return Object.fromEntries(
    Object.entries(styles).map(([key, value]) => [key, normaliseValue(key, value)])
  );
}
