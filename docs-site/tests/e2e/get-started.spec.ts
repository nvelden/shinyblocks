import { test, expect } from "@playwright/test";
import { PATH } from "./paths";
import {
  isPlaygroundConsoleNoise,
  isPlaygroundPageError,
} from "./playground-noise";
import {
  GET_STARTED_TOC,
  CODE_COMPLETE,
} from "../../content/guides/get-started";

// Slice 3 coverage for the Get Started manual: route, structure, copy
// behaviour, navigation, links, accessibility, and console hygiene.

test("get-started route renders with a single named h1", async ({ page }) => {
  await page.goto(PATH.getStarted);
  const h1 = page.getByRole("heading", { level: 1 });
  await expect(h1).toHaveCount(1);
  await expect(h1).toHaveText("Get Started with shinyblocks");
});

test("all 13 section ids exist and TOC links resolve to them", async ({ page }) => {
  await page.goto(PATH.getStarted);
  expect(GET_STARTED_TOC).toHaveLength(13);

  for (const entry of GET_STARTED_TOC) {
    await expect(page.locator(`#${entry.id}`)).toHaveCount(1);
    // Desktop and mobile TOC each carry one link to the section.
    const links = page.locator(`a[href="#${entry.id}"]`);
    expect(await links.count()).toBeGreaterThan(0);
  }
});

test("install and complete-example code blocks are visible", async ({ page }) => {
  await page.goto(PATH.getStarted);
  await expect(
    page.getByRole("region", { name: "Install command" }),
  ).toBeVisible();
  const complete = page.getByRole("region", { name: "Complete app.R" });
  await expect(complete).toBeVisible();
});

test("complete example contains the canonical API surface", async ({ page }) => {
  await page.goto(PATH.getStarted);
  const complete = page.getByRole("region", { name: "Complete app.R" });
  const text = await complete.innerText();
  for (const token of [
    "block_page",
    "block_select",
    "block_plot_output",
    "update_block_select",
    "shinyApp",
  ]) {
    expect(text).toContain(token);
  }
});

test("copy button writes the full canonical example to the clipboard", async ({
  page,
  context,
  browserName,
}) => {
  // Clipboard permissions/read are only reliably grantable in Chromium.
  test.skip(browserName !== "chromium", "clipboard access is chromium-only");
  await context.grantPermissions(["clipboard-read", "clipboard-write"]);

  await page.goto(PATH.getStarted);
  const copyButton = page.getByRole("button", { name: /copy complete app\.r/i });
  await expect(copyButton).toBeVisible();
  await copyButton.click();

  // The accessible name flips to a "copied" state.
  await expect(
    page.getByRole("button", { name: /complete app\.r copied/i }),
  ).toBeVisible();

  const clipboard = await page.evaluate(() => navigator.clipboard.readText());
  expect(clipboard).toBe(CODE_COMPLETE);
});

test("homepage primary CTA reaches the guide", async ({ page }) => {
  await page.goto(PATH.home);
  await page.getByRole("link", { name: "Get started", exact: true }).click();
  await expect(page).toHaveURL(/\/get-started\/?$/);
  await expect(
    page.getByRole("heading", { level: 1, name: "Get Started with shinyblocks" }),
  ).toBeVisible();
});

test("header link reaches the guide", async ({ page }) => {
  await page.goto(PATH.home);
  await page.getByRole("link", { name: "Get Started", exact: true }).click();
  await expect(page).toHaveURL(/\/get-started\/?$/);
});

test("next-step links resolve under the base path", async ({ page }) => {
  await page.goto(PATH.getStarted);
  for (const slug of ["components", "field", "plot-output", "task-button"]) {
    const expected =
      slug === "components"
        ? PATH.components
        : PATH.componentDetail(slug);
    const link = page.locator(`a[href="${expected}"]`).first();
    await expect(link).toHaveCount(1);
  }
});

test("no console or page errors on the guide", async ({ page }) => {
  // The guide embeds a Shinylive live preview; ignore its webR/WASM runtime
  // noise (see playground-noise.ts) so this stays a check of the docs chrome.
  const errors: string[] = [];
  page.on("pageerror", (e) => {
    if (!isPlaygroundPageError(e.message)) errors.push(e.message);
  });
  page.on("console", (m) => {
    if (m.type() === "error" && !isPlaygroundConsoleNoise(m.location())) {
      errors.push(m.text());
    }
  });
  await page.goto(PATH.getStarted);
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  await page.waitForTimeout(1000);
  expect(errors).toEqual([]);
});

test("narrow viewport scrolls code without widening the document", async ({
  page,
}) => {
  await page.setViewportSize({ width: 360, height: 800 });
  await page.goto(PATH.getStarted);
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  const overflow = await page.evaluate(() => {
    const doc = document.documentElement;
    return doc.scrollWidth - doc.clientWidth;
  });
  // Allow a 1px rounding tolerance.
  expect(overflow).toBeLessThanOrEqual(1);
});

test("embeds the finished app as a Shinylive live preview", async ({ page }) => {
  await page.goto(PATH.getStarted);
  const frame = page.locator(
    'iframe[title="Live preview of the finished Regional sales dashboard"]',
  );
  await expect(frame).toHaveCount(1);
  await expect(frame).toHaveAttribute("src", /\/playgrounds\/get-started\/?$/);
});

test("sidebar TOC highlights the section in view", async ({ page }) => {
  await page.setViewportSize({ width: 1440, height: 900 });
  await page.goto(PATH.getStarted);
  const toc = page.locator('aside nav[aria-label="On this page"]');

  // The first section is active on load.
  await expect(
    toc.getByRole("link", { name: "What you will build" }),
  ).toHaveAttribute("aria-current", "true");

  // Jumping to a later section moves the highlight to it.
  const target = toc.getByRole("link", { name: "Connect the server" });
  await target.click();
  await expect(target).toHaveAttribute("aria-current", "true");
  await expect(
    toc.getByRole("link", { name: "What you will build" }),
  ).not.toHaveAttribute("aria-current", "true");
});

test("long code blocks collapse and expand", async ({ page }) => {
  await page.goto(PATH.getStarted);
  // The Complete app.R block is collapsible; it starts clamped with a
  // "Show all" toggle, and full source stays in the DOM the whole time.
  const region = page.getByRole("region", { name: "Complete app.R" });
  await expect(region).toHaveClass(/guide-code-pre--collapsed/);

  const toggle = page.getByRole("button", { name: "Show all" }).first();
  await expect(toggle).toBeVisible();
  await expect(toggle).toHaveAttribute("aria-expanded", "false");

  await toggle.click();
  await expect(region).not.toHaveClass(/guide-code-pre--collapsed/);
  await expect(
    page.getByRole("button", { name: "Show less" }).first(),
  ).toHaveAttribute("aria-expanded", "true");
});
