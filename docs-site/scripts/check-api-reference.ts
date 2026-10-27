import { spawnSync } from "node:child_process";
import { API_REFERENCE_DATABASE } from "../lib/api-reference";

// `run_showcase()` launches a development application rather than documenting
// a component contract, so it belongs in package docs but not a component page.
const API_EXCLUSIONS = new Set(["run_showcase"]);

const rExpression = [
  'suppressMessages(devtools::load_all("..", quiet = TRUE))',
  'exports <- sort(getNamespaceExports("shinyblocks"))',
  'functions <- exports[vapply(exports, function(name) is.function(getExportedValue("shinyblocks", name)), logical(1))]',
  'signatures <- setNames(lapply(functions, function(name) { args <- names(formals(getExportedValue("shinyblocks", name))); if (is.null(args)) character() else args }), functions)',
  'cat(jsonlite::toJSON(signatures, auto_unbox = FALSE))',
].join(";");

const result = spawnSync("Rscript", ["-e", rExpression], {
  cwd: process.cwd(),
  encoding: "utf8",
});

if (result.status !== 0) {
  process.stderr.write(result.stderr);
  throw new Error("Could not read exported R function signatures.");
}

const signatures = JSON.parse(result.stdout) as Record<string, string[]>;
const entries = Object.values(API_REFERENCE_DATABASE).flat();
const documented = new Set(entries.map((entry) => entry.name));
const missing = Object.keys(signatures).filter(
  (name) => !API_EXCLUSIONS.has(name) && !documented.has(name),
);
const stale = [...documented].filter((name) => !(name in signatures));
const mismatches: string[] = [];

for (const entry of entries) {
  const expected = signatures[entry.name];
  if (!expected) continue;
  // The UI permits a compact comma-separated row for arguments that share one
  // description. Treat those as individual formal names for coverage.
  const actual = entry.arguments.flatMap((argument) =>
    argument.argument.split(",").map((name) => name.trim()),
  );
  const missingArguments = expected.filter((name) => !actual.includes(name));
  const unknownArguments = actual.filter((name) => !expected.includes(name));
  if (missingArguments.length || unknownArguments.length) {
    mismatches.push(
      `${entry.name}: missing (${missingArguments.join(", ") || "none"}); ` +
        `unknown (${unknownArguments.join(", ") || "none"})`,
    );
  }
}

if (missing.length || stale.length || mismatches.length) {
  console.error("API reference gate FAILED:\n");
  if (missing.length) console.error(`  Missing exported functions: ${missing.join(", ")}`);
  if (stale.length) console.error(`  Unknown documented functions: ${stale.join(", ")}`);
  for (const mismatch of mismatches) console.error(`  Signature mismatch: ${mismatch}`);
  process.exitCode = 1;
} else {
  console.log(
    `API reference gate passed: ${documented.size} exported functions have current signatures.`,
  );
}
