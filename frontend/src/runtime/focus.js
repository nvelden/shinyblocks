const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "[tabindex]:not([tabindex='-1'])"
].join(",");

export function focusableElements(container) {
  if (!container) return [];
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter((element) => {
    const styles = getComputedStyle(element);
    return !element.closest("[inert]") &&
      !element.closest("[aria-hidden='true']") &&
      element.tabIndex >= 0 &&
      styles.display !== "none" &&
      styles.visibility !== "hidden" &&
      (element.offsetParent !== null || styles.position === "fixed");
  });
}

export function trapTabKey(event, container) {
  const items = focusableElements(container);
  if (!items.length) {
    event.preventDefault();
    container?.focus();
    return;
  }
  const first = items[0];
  const last = items[items.length - 1];
  const currentIndex = items.indexOf(document.activeElement);
  const next = event.shiftKey
    ? items[currentIndex > 0 ? currentIndex - 1 : items.length - 1]
    : items[currentIndex >= 0 && currentIndex < items.length - 1 ? currentIndex + 1 : 0];
  event.preventDefault();
  (next || (event.shiftKey ? last : first)).focus();
}
