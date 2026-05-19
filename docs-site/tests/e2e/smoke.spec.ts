import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

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
    page.getByRole("link", { name: "Components", exact: true }),
  ).toBeVisible();
  await expect(
    page.getByRole("link", { name: "Changelog", exact: true }),
  ).toBeVisible();
  await expect(page.getByRole("link", { name: /github repository/i })).toBeVisible();
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
  const errors: string[] = [];
  page.on("pageerror", (e) => errors.push(e.message));
  page.on("console", (m) => {
    if (m.type() === "error") errors.push(m.text());
  });
  await page.goto(PATH.home);
  await page.waitForLoadState("networkidle");
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
