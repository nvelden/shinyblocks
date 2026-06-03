import fs from "node:fs";
import path from "node:path";

const IMPORT_RE = /^\s*@import\s+["']([^"']+)["'];\s*$/gm;

export function readCssSource(root, relPath, seen = new Set()) {
  const abs = path.join(root, relPath);
  const key = path.normalize(abs);

  if (seen.has(key)) {
    throw new Error(`Circular CSS import detected: ${relPath}`);
  }

  seen.add(key);

  const raw = fs.readFileSync(abs, "utf8");
  const baseDir = path.dirname(relPath);

  const inlined = raw.replace(IMPORT_RE, (_, specifier) => {
    const imported = path.normalize(path.join(baseDir, specifier));
    return readCssSource(root, imported, seen).trimEnd();
  });

  seen.delete(key);
  return inlined;
}
