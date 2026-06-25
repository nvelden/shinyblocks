import { test, expect } from "@playwright/test";
import { PATH } from "./paths";
import {
  isPlaygroundConsoleNoise,
  isPlaygroundPageError,
} from "./playground-noise";

// Phase 1 smoke tests — every PR must keep these green.
// These tests cover the chrome (nav, theme, no errors), NOT page content.
// Per-phase tests live in their own *.spec.ts files (added by later phases).

test("landing page renders", async ({ page }) => {
  await page.goto(PATH.home);
  await expect(page).toHaveTitle(/shinyblocks/i);
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
});

test("top nav links are present", async ({ page }) => {
  await page.goto(PATH.home);
  await expect(
    page.getByRole("link", { name: "Get Started", exact: true }),
  ).toBeVisible();
  await expect(
    page.getByRole("link", { name: "Components", exact: true }),
  ).toBeVisible();
  await expect(
    page.getByRole("link", { name: "Changelog", exact: true }),
  ).toBeVisible();
  await expect(page.getByRole("link", { name: /github repository/i })).toBeVisible();
});

test("get started page reachable from header", async ({ page }) => {
  await page.goto(PATH.home);
  await page.getByRole("link", { name: "Get Started", exact: true }).click();
  await expect(page).toHaveURL(/\/get-started\/?$/);
  await expect(
    page.getByRole("heading", { name: "Get Started with shinyblocks" }),
  ).toBeVisible();
});

test("theme toggle switches and persists", async ({ page }) => {
  await page.goto(PATH.home);

  await page.getByRole("radio", { name: "Light" }).click();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "light");

  await page.getByRole("radio", { name: "Dark" }).click();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");

  // Persists across reload.
  await page.reload();
  await expect(page.locator("html")).toHaveAttribute("data-theme", "dark");
});

test("no console errors on landing", async ({ page }) => {
  // The landing page embeds the Shinylive gallery; ignore its webR/WASM runtime
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
  await page.goto(PATH.home);
  await expect(page.getByRole("heading", { level: 1 })).toBeVisible();
  await page.waitForTimeout(1000);
  expect(errors).toEqual([]);
});

test("internal nav works (Components page reachable)", async ({ page }) => {
  await page.goto(PATH.home);
  await page.getByRole("link", { name: "Components", exact: true }).click();
  await expect(page).toHaveURL(/\/components\/?$/);
  await expect(page.getByRole("heading", { name: "Components" })).toBeVisible();
});

test("changelog page reachable", async ({ page }) => {
  await page.goto(PATH.home);
  await page.getByRole("link", { name: "Changelog", exact: true }).click();
  await expect(page).toHaveURL(/\/changelog\/?$/);
  await expect(page.getByRole("heading", { name: "Changelog" })).toBeVisible();
});
