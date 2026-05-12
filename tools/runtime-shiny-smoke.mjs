import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { chromium } from "playwright";

const port = Number(process.env.PORT_RUNTIME_SHINY || 4325);
const url = `http://127.0.0.1:${port}`;

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitForServer(process) {
  const deadline = Date.now() + 20000;
  while (Date.now() < deadline) {
    if (process.exitCode !== null) {
      throw new Error(`Shiny fixture exited early with code ${process.exitCode}`);
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

const shiny = spawn("Rscript", ["tools/runtime-shiny-fixture.R", String(port)], {
  stdio: ["ignore", "pipe", "pipe"]
});

let stdout = "";
let stderr = "";
shiny.stdout.on("data", (chunk) => {
  stdout += chunk;
});
shiny.stderr.on("data", (chunk) => {
  stderr += chunk;
});

let browser;
let page;

try {
  await waitForServer(shiny);

  browser = await chromium.launch({ headless: true });
  page = await browser.newPage();
  await page.goto(url);

  await page.waitForFunction(() => {
    return document.querySelector("#runtime-choice")?.dataset.sbMounted === "true";
  });

  await page.locator("#child_text").waitFor({ state: "visible" });
  await assertText(page, "#child_text", "child-ready");
  await assertText(page, "#choice_value", "a");

  await page.fill("#nested", "from-browser");
  await assertText(page, "#nested_value", "from-browser");

  await page.click("#set_b");
  await assertText(page, "#choice_value", "b");

  await page.click("#disable_choice");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-choice")?.hasAttribute("data-disabled");
  });

  await page.click("#toggle_dynamic");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-dynamic")?.dataset.sbMounted === "true";
  });
  await assertText(page, "#dynamic_value", "x");
  await assertText(page, "#dynamic_child", "dynamic-child-ready");

  await page.click("#toggle_dynamic");
  await page.waitForFunction(() => !document.querySelector("#runtime-dynamic"));

  await page.click("#toggle_dynamic");
  await page.waitForFunction(() => {
    return document.querySelector("#runtime-dynamic")?.dataset.sbMounted === "true";
  });
  await assertText(page, "#dynamic_value", "x");

  assert.equal(
    await page.locator("[data-shinyblocks-portal-root]").count(),
    1,
    "page should include one portal root"
  );

  console.log("Runtime Shiny smoke test passed.");
} catch (error) {
  if (page) {
    console.error(await page.evaluate(() => ({
      choiceText: document.querySelector("#choice_value")?.textContent,
      rootDataset: { ...document.querySelector("#runtime-choice")?.dataset },
      pending: document.querySelector("#runtime-choice")?.hasAttribute("data-sb-pending-input"),
      shinyExists: Boolean(window.Shiny),
      hasSetInputValue: Boolean(window.Shiny?.setInputValue),
      hasShinyApp: Boolean(window.Shiny?.shinyapp),
      socketReadyState: window.Shiny?.shinyapp?.$socket?.readyState ?? null
    })));
  }
  console.error(stdout);
  console.error(stderr);
  throw error;
} finally {
  if (browser) await browser.close();
  shiny.kill("SIGTERM");
}

async function assertText(page, selector, expected) {
  await page.waitForFunction(
    ([target, value]) => document.querySelector(target)?.textContent?.trim() === value,
    [selector, expected]
  );
}
