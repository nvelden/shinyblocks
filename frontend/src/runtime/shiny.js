const revisions = new Map();

function isShinyReady() {
  if (!window.Shiny || !window.Shiny.setInputValue) return false;
  if (!window.Shiny.shinyapp) return true;

  const socket = window.Shiny.shinyapp.$socket;
  return Boolean(socket && socket.readyState === 1);
}

export function setInputValue(id, value, priority) {
  if (!id || !isShinyReady()) return false;
  window.Shiny.setInputValue(id, value, { priority: priority || "event" });
  return true;
}

export function bindShinyChildren(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  const children = root.querySelector("[data-shinyblocks-children]") || root;
  window.Shiny.bindAll(children);
}

export function unbindShinyChildren(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  const children = root.querySelector("[data-shinyblocks-children]") || root;
  window.Shiny.unbindAll(children);
}

export function isFreshRevision(id, revision) {
  const next = Number(revision || 0);
  const current = revisions.get(id) || 0;
  if (next < current) return false;
  revisions.set(id, next);
  return true;
}

export function forgetRevision(id) {
  revisions.delete(id);
}
