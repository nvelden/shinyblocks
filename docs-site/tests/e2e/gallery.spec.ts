import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("landing page gallery lists featured components", async ({ page }) => {
  await page.goto(PATH.home);
  // Expect to find the component preview cards for button and card
  const buttonPreview = page.locator("[data-component-preview='button']");
  const cardPreview = page.locator("[data-component-preview='card']");
  await expect(buttonPreview).toBeVisible();
  await expect(cardPreview).toBeVisible();
});
