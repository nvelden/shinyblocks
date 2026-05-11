import fs from "node:fs/promises";
import path from "node:path";
import { chromium } from "playwright";
import { getComponentConfig } from "./registry.mjs";
import { normaliseStyles, normaliseValue } from "./normalise.mjs";

function getArg(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1) {
    return null;
  }
  return process.argv[index + 1] ?? null;
}

async function captureSelector(page, selector, props) {
  return await page.evaluate(
    ([target, names]) => {
      const normaliseColor = (property, raw) => {
        if (!property.toLowerCase().includes("color")) {
          return raw;
        }
        const ctx = document.createElement("canvas").getContext("2d");
        if (!ctx) {
          return raw;
        }
        ctx.canvas.width = 1;
        ctx.canvas.height = 1;
        ctx.clearRect(0, 0, 1, 1);
        ctx.fillStyle = "#000";
        ctx.fillStyle = raw;
        ctx.fillRect(0, 0, 1, 1);
        const [r, g, b, a] = ctx.getImageData(0, 0, 1, 1).data;
        return `rgba(${r}, ${g}, ${b}, ${Math.round((a / 255) * 1000) / 1000})`;
      };
      const el = document.querySelector(target);
      if (!el) {
        return { __missing: target };
      }
      const style = window.getComputedStyle(el);
      return Object.fromEntries(
        names.map((prop) => {
          const value = style.getPropertyValue(
            prop.replace(/[A-Z]/g, (match) => `-${match.toLowerCase()}`)
          );
          return [prop, normaliseColor(prop, value)];
        })
      );
    },
    [selector, props]
  );
}

async function setShowcaseTheme(page, theme) {
  await page.evaluate((mode) => {
    document.documentElement.dataset.theme = mode;
  }, theme);
  await page.waitForTimeout(100);
}

async function captureShowcaseState(page, config, theme, state) {
  await page.goto(config.showcaseUrl, { waitUntil: "networkidle" });
  await page.waitForSelector(config.showcaseReadySelector, {
    state: "attached",
    timeout: 10000
  });
  await setShowcaseTheme(page, theme);

  const selector =
    state === "disabled" ? config.showcaseSelectors.disabled : config.showcaseSelectors.default;
  await page.waitForSelector(selector, { state: "visible", timeout: 10000 });
  await page.mouse.move(1270, 10);
  await page.waitForTimeout(250);
  if (state === "hover") {
    await page.locator(selector).first().hover();
    await page.waitForTimeout(250);
  }

  return normaliseStyles(await captureSelector(page, selector, config.props));
}

async function main() {
  const component = getArg("--component");
  if (!component) {
    throw new Error("Missing required --component <name> argument.");
  }

  const config = getComponentConfig(component);
  const baselinePath =
    getArg("--baseline") ??
    path.join("docs", "component-specs", "_parity", `${config.component}.json`);
  const baseline = JSON.parse(await fs.readFile(baselinePath, "utf8"));

  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1
  });
  const page = await context.newPage();

  let drifts = 0;
  for (const theme of config.themes) {
    for (const state of config.states) {
      const live = await captureShowcaseState(page, config, theme, state);
      const expected = baseline.themes?.[theme]?.[state];
      if (!expected) {
        throw new Error(`Missing baseline for ${config.component} ${theme}/${state}.`);
      }

      console.log(`\n== ${config.component} :: ${theme} :: ${state} ==`);
      for (const prop of config.props) {
        const a = normaliseValue(prop, expected[prop] ?? "");
        const b = normaliseValue(prop, live[prop] ?? "");
        if (a === b) {
          console.log(`  ${prop.padEnd(20)} match  ${a}`);
          continue;
        }
        drifts += 1;
        console.log(`  ${prop.padEnd(20)} drift  expected=${a}  shinyblocks=${b}`);
      }
    }
  }

  await browser.close();

  if (drifts > 0) {
    console.error(`\n${drifts} parity drift(s) detected.`);
    process.exit(1);
  }

  console.log(`\nParity OK for ${config.component}.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
