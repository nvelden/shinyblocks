import { trapTabKey } from "./focus.js";

const stack = [];
let bodyStyles = null;

function topModal() {
  return stack[stack.length - 1] || null;
}

function updateStackLayers() {
  stack.forEach((entry, index) => {
    entry.layer()?.style.setProperty("--sb-modal-stack", String(index));
  });
}

function lockBody() {
  if (bodyStyles) return;
  bodyStyles = {
    overflow: document.body.style.overflow,
    paddingRight: document.body.style.paddingRight
  };
  const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
  document.body.style.overflow = "hidden";
  if (scrollbarWidth > 0) document.body.style.paddingRight = `${scrollbarWidth}px`;
  document.addEventListener("keydown", onKeyDown);
}

function unlockBody() {
  if (!bodyStyles) return;
  document.body.style.overflow = bodyStyles.overflow;
  document.body.style.paddingRight = bodyStyles.paddingRight;
  bodyStyles = null;
  document.removeEventListener("keydown", onKeyDown);
}

function restoreWithinTop(entry, target) {
  const container = entry?.container();
  const destination = target?.isConnected && container?.contains(target)
    ? target
    : container;
  destination?.focus({ preventScroll: true });
}

function onKeyDown(event) {
  const entry = topModal();
  if (!entry) return;
  if (event.key === "Escape" && entry.dismiss) {
    event.preventDefault();
    event.stopPropagation();
    entry.dismiss();
  } else if (event.key === "Tab") {
    trapTabKey(event, entry.container());
  }
}

export function registerModal(entry) {
  stack.push(entry);
  updateStackLayers();
  lockBody();

  return function unregisterModal() {
    const index = stack.indexOf(entry);
    if (index < 0) return;
    const wasTop = index === stack.length - 1;
    stack.splice(index, 1);
    updateStackLayers();

    if (!stack.length) {
      unlockBody();
      const target = entry.returnFocus;
      if (target?.focus) requestAnimationFrame(() => target.focus({ preventScroll: true }));
    } else if (wasTop) {
      requestAnimationFrame(() => restoreWithinTop(topModal(), entry.returnFocus));
    }
  };
}

export function isTopModal(container) {
  return topModal()?.container() === container;
}
