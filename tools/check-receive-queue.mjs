// Enforcement gate: receive-based runtime bindings must not silently drop a
// server update delivered before their React mount effect installs the receive
// handler.
//
// Background. Every `update_block_*()` / `inc_block_*()` reaches React through a
// DOM expando (`el[receiveProp]`) that the component installs from a mount
// effect. That effect runs a frame or two after Shiny binds the element, so an
// update fired in the same flush that inserts dynamic UI can arrive before the
// handler exists. The generic binding factory's `receiveMessage` handles this by
// queueing the message and draining it in order once the handler appears.
//
// Two ways a future change could regress this:
//   1. Someone removes the queueing fallback from the generic `receiveMessage`.
//   2. Someone adds a receive-based binding with its OWN `receiveMessage`, which
//      bypasses the generic queue. That is allowed only if the override itself
//      handles the pre-mount window — so every such override must be declared
//      here with a reason.
//
// This check is static (no browser): it parses frontend/src/runtime/bindings.js
// the same way the theme registry gate parses R/runtime.R. The behavioural proof
// that the queue works lives in tools/runtime-shiny-smoke.mjs (the
// insert-then-immediately-update progress case).

import { readFile } from "node:fs/promises";

const BINDINGS_PATH = "frontend/src/runtime/bindings.js";

// Receive-based bindings whose custom `receiveMessage` deliberately bypasses the
// generic queue because the override itself covers the pre-mount window. Keep
// the reason current; an entry here is a promise that the override delivers
// pre-mount messages rather than dropping them.
const CUSTOM_RECEIVE_ALLOWLIST = {
  select:
    "Custom receiveMessage writes pending `choices`/`selected` straight to the " +
    "native <select> before React mounts, so the pre-mount window is covered."
};

function fail(messages) {
  console.error("Receive-queue gate FAILED:\n");
  for (const m of messages) console.error(`  - ${m}`);
  console.error(
    "\nReceive-based bindings must keep the generic queued fallback, or declare " +
      "an allowlisted custom receiveMessage that handles the pre-mount window in " +
      `${BINDINGS_PATH}. See tools/check-receive-queue.mjs.`
  );
  process.exitCode = 1;
}

const src = await readFile(BINDINGS_PATH, "utf8");

// 1. The generic factory must still queue when the handler is not installed.
// Scope to the region before BINDING_CONFIGS so we read the factory, not a
// per-binding override.
const configsStart = src.indexOf("const BINDING_CONFIGS = [");
if (configsStart === -1) {
  fail(["Could not find `const BINDING_CONFIGS = [` in bindings.js."]);
} else {
  const factory = src.slice(0, configsStart);
  const requiredMarkers = ["__sbReceiveQueue", "__sbReceiveDraining", "receiveProp"];
  const missing = requiredMarkers.filter((m) => !factory.includes(m));
  if (missing.length) {
    fail([
      "The generic `receiveMessage` no longer implements the queued fallback " +
        `(missing: ${missing.join(", ")}). A pre-mount update would be dropped.`
    ]);
  }

  // 2. Every receive-based config either uses the generic path (covered) or has
  // an allowlisted custom receiveMessage.
  const configsEnd = src.indexOf("\n];", configsStart);
  const block = src.slice(configsStart, configsEnd === -1 ? undefined : configsEnd);

  // Slice the array into one segment per `component: "..."` entry.
  const componentRe = /component:\s*"([^"]+)"/g;
  const marks = [];
  let m;
  while ((m = componentRe.exec(block)) !== null) {
    marks.push({ name: m[1], index: m.index });
  }

  const problems = [];
  for (let i = 0; i < marks.length; i++) {
    const start = marks[i].index;
    const end = i + 1 < marks.length ? marks[i + 1].index : block.length;
    const segment = block.slice(start, end);
    const name = marks[i].name;

    const isReceiveBased = /receiveProp\s*:/.test(segment);
    const hasCustomReceive = /receiveMessage\s*\(/.test(segment);

    if (!isReceiveBased) continue;

    if (hasCustomReceive && !(name in CUSTOM_RECEIVE_ALLOWLIST)) {
      problems.push(
        `"${name}" defines a custom receiveMessage that bypasses the generic ` +
          "queue. Either remove the override (use the generic queued path) or, if " +
          "the override handles the pre-mount window itself, add it to " +
          "CUSTOM_RECEIVE_ALLOWLIST with a reason."
      );
    }
  }

  // Flag stale allowlist entries so the list cannot rot.
  const present = new Set(marks.map((x) => x.name));
  for (const name of Object.keys(CUSTOM_RECEIVE_ALLOWLIST)) {
    if (!present.has(name)) {
      problems.push(
        `CUSTOM_RECEIVE_ALLOWLIST has a stale entry "${name}" — no such binding ` +
          "config. Remove it."
      );
    } else {
      const seg = (() => {
        const idx = marks.findIndex((x) => x.name === name);
        const s = marks[idx].index;
        const e = idx + 1 < marks.length ? marks[idx + 1].index : block.length;
        return block.slice(s, e);
      })();
      if (!/receiveMessage\s*\(/.test(seg)) {
        problems.push(
          `CUSTOM_RECEIVE_ALLOWLIST lists "${name}" but its config no longer has ` +
            "a custom receiveMessage. Remove the allowlist entry."
        );
      }
    }
  }

  if (problems.length) {
    fail(problems);
  }
}

if (!process.exitCode) {
  console.log(
    "Receive-queue gate passed: generic receiveMessage queues pre-mount updates; " +
      "all custom overrides are allowlisted."
  );
}
