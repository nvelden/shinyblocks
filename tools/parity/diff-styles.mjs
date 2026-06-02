import { chromium } from "playwright";
import { getComponentConfig, listComponentNames } from "./registry.mjs";

function getArg(flag) {
  const index = process.argv.indexOf(flag);
  if (index === -1) {
    return null;
  }
  return process.argv[index + 1] ?? null;
}

// Navigate to the showcase, turning a connection failure into an actionable
// message instead of letting Playwright's raw error bubble up. The caller's
// try/finally still closes the browser so the process exits instead of hanging.
async function gotoShowcase(page, url) {
  try {
    await page.goto(url, { waitUntil: "networkidle" });
  } catch (err) {
    if (/ERR_CONNECTION_REFUSED|ERR_CONNECTION/.test(String(err))) {
      throw new Error(
        `Showcase not reachable at ${url}. Start it first: \`make showcase\`. ` +
          `This render check needs the live showcase.`
      );
    }
    throw err;
  }
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

async function setShowcaseTheme(page, theme) {
  await page.evaluate((mode) => {
    document.documentElement.dataset.theme = mode;
  }, theme);
  await page.waitForTimeout(100);
}

async function forceHover(page, selector) {
  const client = await page.context().newCDPSession(page);
  await client.send("DOM.enable");
  await client.send("CSS.enable");
  const { root } = await client.send("DOM.getDocument");
  const { nodeId } = await client.send("DOM.querySelector", {
    nodeId: root.nodeId,
    selector
  });
  if (!nodeId) {
    throw new Error(`Cannot force :hover for missing selector "${selector}".`);
  }
  await client.send("CSS.forcePseudoState", {
    nodeId,
    forcedPseudoClasses: ["hover"]
  });
}

async function checkRendered(page, selector, label) {
  await page.waitForSelector(selector, { state: "attached", timeout: 10000 });
  return await page.evaluate(
    ({ target, label: targetLabel }) => {
      const el = document.querySelector(target);
      if (!el) {
        return [`${targetLabel}: missing (${target})`];
      }

      const style = window.getComputedStyle(el);
      const rect = el.getBoundingClientRect();
      const issues = [];

      if (style.display === "none") {
        issues.push(`${targetLabel}: display is none`);
      }
      if (style.visibility === "hidden" || style.visibility === "collapse") {
        issues.push(`${targetLabel}: visibility is ${style.visibility}`);
      }
      if (Number(style.opacity) === 0) {
        issues.push(`${targetLabel}: opacity is 0`);
      }
      if (rect.width <= 0 || rect.height <= 0) {
        issues.push(
          `${targetLabel}: empty layout (${Math.round(rect.width)}x${Math.round(rect.height)})`
        );
      }

      return issues;
    },
    { target: selector, label }
  );
}

async function prepareState(page, config, state, selectors) {
  await page.mouse.move(1270, 10);
  await page.evaluate(() => {
    if (document.activeElement && document.activeElement !== document.body) {
      document.activeElement.blur();
    }
  });
  await page.keyboard.press("Escape");
  await page.waitForTimeout(100);

  if (config.prepareShowcaseState) {
    await config.prepareShowcaseState(page, state, selectors);
    return;
  }

  if (state === "hover") {
    await forceHover(page, selectors);
    await page.waitForTimeout(300);
  }
}

async function checkState(page, config, theme, state) {
  const selectors = config.roles
    ? roleSelectorMap(config.roles, "showcase", state)
    : selectorForState(config.showcaseSelectors, state);
  if (!selectors) {
    throw new Error(`Missing showcase selector(s) for ${config.component} state "${state}".`);
  }

  await prepareState(page, config, state, selectors);

  const issues = [];
  if (config.roles) {
    for (const [roleName, selector] of Object.entries(selectors)) {
      issues.push(
        ...(await checkRendered(page, selector, `${config.component}/${theme}/${state}/${roleName}`))
      );
    }
  } else {
    issues.push(
      ...(await checkRendered(page, selectors, `${config.component}/${theme}/${state}`))
    );
  }

  if (config.extraShowcaseChecks) {
    const extraDrifts = await config.extraShowcaseChecks(page, theme, state, selectors, {}, {});
    if (extraDrifts > 0) {
      issues.push(`${config.component}/${theme}/${state}: failed structural geometry checks`);
    }
  }

  return issues;
}

async function main() {
  const component = getArg("--component");
  const components = process.argv.includes("--all")
    ? listComponentNames()
    : [component];
  if (!component && !process.argv.includes("--all")) {
    throw new Error("Pass --component <name> or --all.");
  }

  const browser = await chromium.launch();
  const issues = [];
  try {
    const context = await browser.newContext({
      viewport: { width: 1280, height: 800 },
      deviceScaleFactor: 1
    });
    const page = await context.newPage();

    for (const name of components) {
      const config = getComponentConfig(name);
      for (const theme of config.themes) {
        await page.goto("about:blank");
        await gotoShowcase(page, config.showcaseUrl);
        await page.waitForSelector(config.showcaseReadySelector, {
          state: "attached",
          timeout: 10000
        });
        await setShowcaseTheme(page, theme);

        for (const state of config.states) {
          const stateIssues = await checkState(page, config, theme, state);
          if (stateIssues.length > 0) {
            issues.push(...stateIssues);
            console.log(`FAIL ${config.component} ${theme}/${state}`);
          } else {
            console.log(`OK   ${config.component} ${theme}/${state}`);
          }
        }
      }
    }
  } finally {
    await browser.close();
  }

  if (issues.length > 0) {
    console.error("\nRender check failed:");
    for (const issue of issues) {
      console.error(`- ${issue}`);
    }
    process.exit(1);
  }

  console.log(`\nRender check OK for ${components.join(", ")}.`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
