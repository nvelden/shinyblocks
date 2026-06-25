import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import net from "node:net";
import { chromium } from "playwright";

async function canListen(port) {
  return new Promise((resolve) => {
    const server = net.createServer();
    server.once("error", () => resolve(false));
    server.once("listening", () => {
      server.close(() => resolve(true));
    });
    server.listen(port, "127.0.0.1");
  });
}

async function resolvePort() {
  const requested = process.env.PORT_SHOWCASE_SMOKE;
  if (requested) return Number(requested);

  for (let candidate = 4326; candidate < 4376; candidate += 1) {
    if (await canListen(candidate)) return candidate;
  }

  throw new Error("No available showcase smoke port found.");
}

const port = await resolvePort();
const url = `http://127.0.0.1:${port}`;

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForServer(process) {
  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    if (process.exitCode !== null) {
      throw new Error(`Showcase exited early with code ${process.exitCode}`);
    }
    try {
      const response = await fetch(url);
      if (response.ok) return;
    } catch {
      await delay(250);
    }
  }

  throw new Error(`Timed out waiting for ${url}`);
}

const showcase = spawn(
  "Rscript",
  [
    "-e",
    `devtools::load_all(".", quiet = TRUE); shiny::runApp("inst/showcase", port = ${port}, launch.browser = FALSE)`
  ],
  { stdio: ["ignore", "pipe", "pipe"] }
);

let stdout = "";
let stderr = "";
showcase.stdout.on("data", (chunk) => {
  stdout += chunk;
});
showcase.stderr.on("data", (chunk) => {
  stderr += chunk;
});

let browser;
let page;

try {
  await waitForServer(showcase);

  browser = await chromium.launch({ headless: true });
  page = await browser.newPage();
  await page.addInitScript(() => {
    localStorage.setItem("sb-theme", "light");
  });
  await page.goto(`${url}/#button`, { waitUntil: "domcontentloaded" });

  await page.waitForSelector('#button:not([hidden])');
  await page.waitForSelector("[data-sb-theme-toggle]");
  assert.equal(
    await page.evaluate(() => document.documentElement.dataset.theme),
    "light"
  );
  await page.click("[data-sb-theme-toggle]");
  await page.waitForFunction(() => {
    return document.documentElement.dataset.theme === "dark";
  });
  assert.equal(
    await page.locator("[data-sb-theme-toggle]").first().getAttribute("aria-pressed"),
    "true"
  );

  await page.fill(
    "[data-sb-component='input'][data-sb-input-id='showcase_button_doc_style'] [data-slot='input-control']",
    "color: red;"
  );
  await page.waitForFunction(() => {
    const button = document.querySelector(
      "[data-sb-component='button'][data-sb-input-id='showcase_button_preview'] [data-slot='button']"
    );
    return button && getComputedStyle(button).color === "rgb(255, 0, 0)";
  });

  const preview = await page.locator(
    "[data-sb-component='button'][data-sb-input-id='showcase_button_preview'] [data-slot='button']"
  ).evaluate((node) => {
    const style = getComputedStyle(node);
    return {
      display: style.display,
      text: node.textContent.trim(),
      style: node.getAttribute("style")
    };
  });

  assert.equal(preview.display, "inline-flex");
  assert.equal(preview.text, "Continue");
  assert.equal(preview.style, "color: red;");

  await page.goto(`${url}/#tabs`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#tabs:not([hidden])");
  // Drive the stable parity instance (overview/usage tabs, defaults to overview).
  const tabsRoot = page.locator("#showcase_tabs_parity_default");
  await tabsRoot.locator(".sb-tabs-trigger[data-value='usage']").click();
  await page.waitForFunction(() => {
    const trigger = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-trigger[data-value='usage']"
    );
    const panel = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-panel[data-value='usage']"
    );
    return trigger?.getAttribute("aria-selected") === "true" &&
      trigger?.getAttribute("data-state") === "active" &&
      panel?.getAttribute("data-state") === "active" &&
      !panel.hasAttribute("hidden");
  });

  // ArrowRight from the last tab (usage) wraps roving focus back to overview
  // and activates it (automatic activation), hiding the usage panel.
  await tabsRoot.locator(".sb-tabs-trigger[data-value='usage']").press("ArrowRight");
  await page.waitForFunction(() => {
    const trigger = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-trigger[data-value='overview']"
    );
    const previousPanel = document.querySelector(
      "#showcase_tabs_parity_default .sb-tabs-panel[data-value='usage']"
    );
    return trigger?.getAttribute("aria-selected") === "true" &&
      trigger?.getAttribute("data-state") === "active" &&
      previousPanel?.hasAttribute("hidden");
  });

  await page.goto(`${url}/#layout-primitives`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#layout-primitives:not([hidden])");
  await page.waitForFunction(() => window.Shiny?.setInputValue);

  const setLayoutInputs = async (values) => {
    await page.evaluate((nextValues) => {
      for (const [name, value] of Object.entries(nextValues)) {
        window.Shiny.setInputValue(`showcase_layout_primitives_${name}`, value, {
          priority: "event"
        });
      }
    }, values);
  };

  await setLayoutInputs({
    type: "grid",
    count: "2",
    min_width: "10rem",
    align: "stretch",
    vary_heights: true
  });
  await page.waitForFunction(() => {
    const grids = document.querySelectorAll(
      "#showcase_layout_primitives_preview_ui .showcase-layout-primitives-viewport > .sb-grid"
    );
    if (!grids.length) return false;
    const grid = grids[grids.length - 1];
    return grid.querySelectorAll(":scope > .sb-card").length === 2 &&
      grid.style.getPropertyValue("--sb-grid-min") === "10rem" &&
      getComputedStyle(grid).gridTemplateColumns.split(" ").length === 2;
  });

  const gridSnapshot = await page.evaluate(() => {
    const grids = [...document.querySelectorAll(
      "#showcase_layout_primitives_preview_ui .showcase-layout-primitives-viewport > .sb-grid"
    )];
    const grid = grids.findLast((node) => node.isConnected && node.getClientRects().length);
    return {
      cards: [...grid.querySelectorAll(":scope > .sb-card")].map((node) => {
        const box = node.getBoundingClientRect();
        return { x: box.x, y: box.y, width: box.width, height: box.height };
      })
    };
  });
  const gridBoxes = gridSnapshot.cards;
  assert.ok(gridBoxes[1].x > gridBoxes[0].x);
  assert.ok(Math.abs(gridBoxes[1].y - gridBoxes[0].y) < 2);
  assert.ok(Math.abs(gridBoxes[1].height - gridBoxes[0].height) < 2);

  await page.setViewportSize({ width: 700, height: 800 });
  await page.goto(`${url}/#layout`, { waitUntil: "domcontentloaded" });
  await page.waitForSelector("#layout:not([hidden])");
  await page.locator(".sb-sidebar-mobile-trigger").click();
  await page.waitForFunction(() => {
    const shell = document.querySelector(".sb-page");
    const sidebar = document.querySelector(".sb-sidebar");
    return shell?.getAttribute("data-sidebar-mobile-open") === "true" &&
      getComputedStyle(sidebar).transform === "matrix(1, 0, 0, 1, 0, 0)";
  });

  const mobileSidebar = await page.evaluate(() => {
    const sidebar = document.querySelector(".sb-sidebar");
    const backdrop = document.querySelector(".sb-sidebar-backdrop");
    const sidebarStyle = getComputedStyle(sidebar);
    const rect = sidebar.getBoundingClientRect();
    const topElement = document.elementFromPoint(
      rect.left + rect.width / 2,
      rect.top + 100
    );

    return {
      backgroundColor: sidebarStyle.backgroundColor,
      sidebarToken: sidebarStyle.getPropertyValue("--sidebar").trim(),
      topElementIsSidebar: sidebar.contains(topElement),
      backdropPointerEvents: getComputedStyle(backdrop).pointerEvents
    };
  });

  assert.notEqual(mobileSidebar.backgroundColor, "rgba(0, 0, 0, 0)");
  assert.notEqual(mobileSidebar.backgroundColor, "transparent");
  assert.ok(mobileSidebar.sidebarToken);
  assert.equal(mobileSidebar.topElementIsSidebar, true);
  assert.equal(mobileSidebar.backdropPointerEvents, "auto");

  console.log("Showcase smoke test passed.");
} catch (error) {
  console.error(stdout);
  console.error(stderr);
  throw error;
} finally {
  if (browser) await browser.close();
  showcase.kill("SIGTERM");
}
