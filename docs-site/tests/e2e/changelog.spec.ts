import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("changelog lists at least one version", async ({ page }) => {
  await page.goto(PATH.changelog);
  const headings = page.locator("h2");
  expect(await headings.count()).toBeGreaterThan(0);
});

test("version anchors work", async ({ page }) => {
  await page.goto(PATH.changelog);
  const first = page.locator("h2").first();
  const id = await first.getAttribute("id");
  if (!id) throw new Error("first h2 has no id");
  await page.goto(`${PATH.changelog}#${id}`);
  await expect(first).toBeInViewport();
});
