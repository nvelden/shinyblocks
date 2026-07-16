export function runtimeRoots(container) {
  return Array.from(
    (container || document).querySelectorAll("[data-shinyblocks-runtime='true']")
  );
}

export function readPayload(root) {
  const script = root.querySelector("script[data-shinyblocks-payload]");
  if (!script) return null;

  try {
    return JSON.parse(script.textContent || "{}");
  } catch (error) {
    root.dataset.sbRuntimeError = "payload";
    console.error("shinyblocks: invalid runtime payload", error);
    return null;
  }
}

export function currentValue(payload) {
  if (!payload || !payload.state) return null;
  if (!Object.prototype.hasOwnProperty.call(payload.state, "value")) return null;
  return payload.state.value;
}

export function ensurePortalRoot(originRoot) {
  const owner = originRoot || document.body;
  let portal = Array.from(owner.children || []).find((child) => {
    return child.hasAttribute?.("data-shinyblocks-portal-root");
  });
  if (portal) return portal;

  portal = document.createElement("div");
  portal.setAttribute("data-shinyblocks-portal-root", "");
  owner.appendChild(portal);
  return portal;
}

export function cssEscape(value) {
  if (window.CSS && typeof window.CSS.escape === "function") {
    return window.CSS.escape(value);
  }
  return String(value).replace(/["\\#.;,[\]()=>+~*^$|!]/g, "\\$&");
}

export function labelIdForInput(inputId) {
  if (!inputId) return null;

  const label = document.querySelector(`label[for="${cssEscape(inputId)}"]`);
  if (!label) return null;

  if (!label.id) {
    label.id = `${inputId}-label`;
  }
  return label.id;
}
