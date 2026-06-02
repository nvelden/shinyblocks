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
    "[data-sb-component='textarea'][data-sb-input-id='showcase_button_doc_style'] [data-slot='textarea-control']",
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

  console.log("Showcase smoke test passed.");
} catch (error) {
  console.error(stdout);
  console.error(stderr);
  throw error;
} finally {
  if (browser) await browser.close();
  showcase.kill("SIGTERM");
}
