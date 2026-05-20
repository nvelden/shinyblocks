import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("components index page renders sidebar and main grid", async ({ page }) => {
  await page.goto(PATH.components);
  
  // Sidebar component links.
  await expect(page.getByRole("link", { name: "Button", exact: true })).toBeVisible();
  await expect(page.getByRole("link", { name: "Card", exact: true })).toBeVisible();
});
