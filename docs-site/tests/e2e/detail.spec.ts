import { test, expect } from "@playwright/test";
import { PATH } from "./paths";

test("component detail page displays preview and code block", async ({ page }) => {
  await page.goto(PATH.componentDetail("button"));
  
  // Renders the header and details.
  await expect(page.getByRole("heading", { level: 1, name: "Button" })).toBeVisible();
  
  // Displays R Code section and recipe content.
  await expect(page.getByRole("heading", { level: 2, name: "R Code" })).toBeVisible();
  const codeBlock = page.locator("[data-sb-component='code']").last();
  await expect(codeBlock).toContainText("shinyblocks::block_button");
  await expect(codeBlock.locator(".sb-code-block-pre")).toHaveCSS("overflow-x", "hidden");
  const overflow = await codeBlock.locator(".sb-code-block-pre").evaluate((node) => {
    return node.scrollWidth > node.clientWidth + 1;
  });
  expect(overflow).toBe(false);
  
  // Navigation back works.
  await page.getByRole("link", { name: /Back to Components/ }).click();
  await expect(page).toHaveURL(PATH.components);
});
