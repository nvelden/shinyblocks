import fs from "node:fs/promises";
import path from "node:path";
import { chromium } from "playwright";
import { getComponentConfig } from "./registry.mjs";
import { normaliseStyles } from "./normalise.mjs";

function getArg(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1) {
    return null;
  }
  return process.argv[index + 1] ?? null;
}

function hasFlag(flag) {
  return process.argv.includes(flag);
}

function cssName(property) {
  return property.replace(/[A-Z]/g, (match) => `-${match.toLowerCase()}`);
}

async function captureSelector(page, selector, props) {
  return await page.evaluate(
    ([target, names]) => {
      const toRgba = (raw) => {
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
      const normaliseColor = (property, raw) => {
        if (property === "boxShadow") {
          return raw.replace(
            /(rgba?\([^)]+\)|hsla?\([^)]+\)|oklab\([^)]+\)|oklch\([^)]+\)|okl\([^)]+\)|#[0-9a-f]+|transparent)/gi,
            (match) => toRgba(match)
          );
        }
        if (!property.toLowerCase().includes("color")) {
          return raw;
        }
        return toRgba(raw);
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

function selectorForState(selectors, state) {
  if (typeof selectors === "string") {
    return selectors;
  }
  return selectors?.[state] ?? selectors?.default;
}

function roleSelectorMap(roles, kind, state) {
  return Object.fromEntries(
    Object.entries(roles).map(([roleName, roleConfig]) => [
      roleName,
      selectorForState(roleConfig[`${kind}Selectors`], state)
    ])
  );
}

async function captureRoles(page, roles, selectors) {
  const out = {};
  for (const [roleName, roleConfig] of Object.entries(roles)) {
    const selector = selectors[roleName];
    if (!selector) {
      throw new Error(`Missing selector for role "${roleName}".`);
    }
    await page.waitForSelector(selector, { state: "visible", timeout: 10000 });
    out[roleName] = normaliseStyles(await captureSelector(page, selector, roleConfig.props));
  }
  return out;
}

async function captureReferenceState(page, config, theme, state) {
  const url = new URL(config.parityUrl);
  url.searchParams.set("theme", theme);
  await page.goto(url.toString(), { waitUntil: "networkidle" });
  const selectors = config.roles
    ? roleSelectorMap(config.roles, "reference", state)
    : selectorForState(config.referenceSelectors, state);
  if (!selectors) {
    throw new Error(`Missing reference selector(s) for ${config.component} state "${state}".`);
  }
  if (!config.roles) {
    await page.waitForSelector(selectors, { state: "visible", timeout: 10000 });
  }
  await page.mouse.move(1270, 10);
  await page.waitForTimeout(100);
  if (config.prepareReferenceState) {
    await config.prepareReferenceState(page, state, selectors);
  } else if (state === "hover") {
    await page.locator(selectors).hover();
    await page.waitForTimeout(250);
  }
  if (config.roles) {
    return await captureRoles(page, config.roles, selectors);
  }
  return normaliseStyles(await captureSelector(page, selectors, config.props));
}

async function main() {
  const component = getArg("--component");
  if (!component) {
    throw new Error("Missing required --component <name> argument.");
  }

  const config = getComponentConfig(component);
  const baselinePath =
    getArg("--out") ??
    path.join("docs", "component-specs", "_parity", `${config.component}.json`);

  const browser = await chromium.launch();
  const context = await browser.newContext({
    viewport: { width: 1280, height: 800 },
    deviceScaleFactor: 1
  });
  const page = await context.newPage();

  const capture = {
    component: config.component,
    source: config.parityUrl,
    captured_at: new Date().toISOString(),
    props: config.roles
      ? Object.fromEntries(
          Object.entries(config.roles).map(([roleName, roleConfig]) => [
            roleName,
            roleConfig.props.map(cssName)
          ])
        )
      : config.props.map(cssName),
    themes: {}
  };

  for (const theme of config.themes) {
    capture.themes[theme] = {};
    for (const state of config.states) {
      capture.themes[theme][state] = await captureReferenceState(
        page,
        config,
        theme,
        state
      );
    }
  }

  await browser.close();

  if (hasFlag("--write-baseline")) {
    await fs.mkdir(path.dirname(baselinePath), { recursive: true });
    await fs.writeFile(baselinePath, `${JSON.stringify(capture, null, 2)}\n`);
    console.log(`Wrote parity baseline: ${baselinePath}`);
  } else {
    process.stdout.write(`${JSON.stringify(capture, null, 2)}\n`);
  }
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
