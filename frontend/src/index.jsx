import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";

const mounted = new Map();
const revisions = new Map();

function runtimeRoots(container) {
  return Array.from(
    (container || document).querySelectorAll("[data-shinyblocks-runtime='true']")
  );
}

function readPayload(root) {
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

function currentValue(payload) {
  if (!payload || !payload.state) return null;
  if (!Object.prototype.hasOwnProperty.call(payload.state, "value")) return null;
  return payload.state.value;
}

function ensurePortalRoot() {
  let portal = document.querySelector("[data-shinyblocks-portal-root]");
  if (portal) return portal;

  portal = document.createElement("div");
  portal.setAttribute("data-shinyblocks-portal-root", "");
  document.body.appendChild(portal);
  return portal;
}

function isShinyReady() {
  if (!window.Shiny || !window.Shiny.setInputValue) return false;
  if (!window.Shiny.shinyapp) return true;

  const socket = window.Shiny.shinyapp.$socket;
  return Boolean(socket && socket.readyState === 1);
}

function setInputValue(id, value, priority) {
  if (!id || !isShinyReady()) return false;
  window.Shiny.setInputValue(id, value, { priority: priority || "event" });
  return true;
}

function bindShinyChildren(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  const children = root.querySelector("[data-shinyblocks-children]") || root;
  window.Shiny.bindAll(children);
}

function unbindShinyChildren(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  const children = root.querySelector("[data-shinyblocks-children]") || root;
  window.Shiny.unbindAll(children);
}

function isFreshRevision(id, revision) {
  const next = Number(revision || 0);
  const current = revisions.get(id) || 0;
  if (next < current) return false;
  revisions.set(id, next);
  return true;
}

function forgetRevision(id) {
  revisions.delete(id);
}

function RuntimeMount({ payload }) {
  if (payload.component === "button") {
    return <Button payload={payload} />;
  }

  if (payload.component === "badge") {
    return <Badge payload={payload} />;
  }

  if (payload.component === "select") {
    return <Select payload={payload} />;
  }

  return (
    <span
      hidden
      data-shinyblocks-react-mounted={payload.component || "component"}
      data-shinyblocks-schema-version={payload.schemaVersion || 1}
    />
  );
}

function classNames(...values) {
  return values
    .flatMap((value) => String(value || "").split(/\s+/))
    .filter(Boolean)
    .filter((value, index, all) => all.indexOf(value) === index)
    .join(" ");
}

function passthroughAttrs(attrs) {
  return Object.fromEntries(
    Object.entries(attrs || {}).filter(([, value]) => value !== false && value !== null)
  );
}

function HtmlSlot({ html, className, ...attrs }) {
  if (!html) return null;
  return (
    <span
      className={className}
      dangerouslySetInnerHTML={{ __html: html }}
      {...attrs}
    />
  );
}

function Icon({ payload }) {
  const props = payload.props || {};
  const position = props.iconPosition || "inline-start";

  if (props.iconHtml) {
    return (
      <HtmlSlot
        html={props.iconHtml}
        data-icon={position}
      />
    );
  }

  if (!props.iconName) return null;

  return (
    <svg
      aria-hidden="true"
      focusable="false"
      data-icon={position}
    >
      <use href={`${props.spriteHref}#sb-icon-${props.iconName}`} />
    </svg>
  );
}

function Button({ payload }) {
  const props = payload.props || {};
  const iconPosition = props.iconPosition || "inline-start";
  const attrs = passthroughAttrs(props.attrs);

  return (
    <button
      type="button"
      data-slot="button"
      data-variant={props.variant || "default"}
      data-size={props.size || "default"}
      className={classNames(
        "sb-button",
        `sb-button-${props.variant || "default"}`,
        `sb-button-size-${props.size || "default"}`,
        payload.className
      )}
      disabled={Boolean(props.disabled)}
      {...attrs}
    >
      {iconPosition === "inline-start" && <Icon payload={payload} />}
      <HtmlSlot html={props.labelHtml} />
      {iconPosition === "inline-end" && <Icon payload={payload} />}
    </button>
  );
}

function Badge({ payload }) {
  const props = payload.props || {};

  return (
    <span
      data-slot="badge"
      data-variant={props.variant || "default"}
      className={classNames(
        "sb-badge",
        `sb-badge-${props.variant || "default"}`,
        payload.className
      )}
    >
      <HtmlSlot html={props.labelHtml} />
    </span>
  );
}

function Select({ payload }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const choices = props.choices || [];
  const disabled = Boolean(props.disabled || state.disabled);
  const [value, setValue] = useState(state.value ?? "");

  useEffect(() => {
    setValue(payload.state?.value ?? "");
  }, [payload.state?.value]);

  return (
    <div
      data-slot="select"
      className={classNames("sb-select", payload.className)}
      style={{ width: props.width || "100%" }}
      data-disabled={disabled ? "true" : undefined}
    >
      <select
        className="sb-select-control"
        value={value}
        disabled={disabled}
        aria-invalid={payload.rootAttrs?.ariaInvalid || undefined}
        aria-describedby={payload.rootAttrs?.ariaDescribedby || undefined}
        onChange={(event) => {
          const nextValue = event.target.value;
          payload.state ||= {};
          payload.state.value = nextValue;
          setValue(nextValue);
          setInputValue(payload.id, nextValue, "event");
        }}
      >
        {props.placeholder && (
          <option value="">{props.placeholder}</option>
        )}
        {choices.map((choice) => (
          <option key={choice.value} value={choice.value}>
            {choice.label}
          </option>
        ))}
      </select>
      <span className="sb-select-icon" aria-hidden="true" />
    </div>
  );
}

function renderReactMount(root, payload) {
  let target = root.querySelector("[data-shinyblocks-react]");
  if (!target) {
    target = document.createElement("div");
    target.setAttribute("data-shinyblocks-react", "");
    root.insertBefore(target, root.firstChild);
  }

  const reactRoot = createRoot(target);
  reactRoot.render(<RuntimeMount payload={payload} />);
  return reactRoot;
}

function mountRoot(root) {
  if (mounted.has(root)) return;

  const payload = readPayload(root);
  if (!payload) return;
  payload.rootAttrs = {
    ariaInvalid: root.getAttribute("aria-invalid"),
    ariaDescribedby: root.getAttribute("aria-describedby")
  };

  ensurePortalRoot();
  const reactRoot = renderReactMount(root, payload);

  root.dataset.sbMounted = "true";
  root.dataset.sbSchemaVersion = String(payload.schemaVersion || 1);

  mounted.set(root, { payload, reactRoot });
  bindShinyChildren(root);

  if (payload.id && payload.binding && payload.binding.input) {
    const initialized = setInputValue(payload.id, currentValue(payload), "event");
    if (!initialized) {
      root.dataset.sbPendingInput = "true";
      schedulePendingInputFlush();
    }
  }
}

function unmountRoot(root) {
  const mountedRoot = mounted.get(root);
  if (!mountedRoot) return;

  unbindShinyChildren(root);
  mountedRoot.reactRoot.unmount();
  if (mountedRoot.payload.id) forgetRevision(mountedRoot.payload.id);
  mounted.delete(root);
}

function mountAll(container) {
  runtimeRoots(container).forEach(mountRoot);
}

function flushPendingInputs(container) {
  runtimeRoots(container || document).forEach(function flushRoot(root) {
    if (!root.hasAttribute("data-sb-pending-input")) return;

    const mountedRoot = mounted.get(root);
    const payload = mountedRoot && mountedRoot.payload;
    if (!payload || !payload.id || !payload.binding || !payload.binding.input) {
      return;
    }

    const initialized = setInputValue(payload.id, currentValue(payload), "event");
    if (initialized) root.removeAttribute("data-sb-pending-input");
  });
}

function hasPendingInputs(container) {
  return runtimeRoots(container || document).some(function pendingRoot(root) {
    return root.hasAttribute("data-sb-pending-input");
  });
}

function schedulePendingInputFlush() {
  if (window.shinyblocksRuntimePendingInputFlushTimer) return;

  let attempts = 0;
  window.shinyblocksRuntimePendingInputFlushTimer = window.setInterval(function retryPendingInputs() {
    flushPendingInputs(document);
    attempts += 1;

    if (!hasPendingInputs(document) || attempts >= 200) {
      window.clearInterval(window.shinyblocksRuntimePendingInputFlushTimer);
      window.shinyblocksRuntimePendingInputFlushTimer = null;
    }
  }, 50);
}

function applyUpdate(message) {
  if (!message || !message.id) return;
  if (!isFreshRevision(message.id, message.revision)) return;

  runtimeRoots(document).forEach(function updateRoot(root) {
    const mountedRoot = mounted.get(root);
    const payload = mountedRoot && mountedRoot.payload;
    if (!payload || payload.id !== message.id) return;

    payload.state ||= {};
    payload.props ||= {};

    Object.keys(message.updates || {}).forEach(function applyField(key) {
      const value = message.updates[key];
      if (key === "disabled") {
        root.toggleAttribute("data-disabled", Boolean(value));
      }
      if (key === "choices" || key === "placeholder" || key === "disabled") {
        payload.props[key] = value;
      }
      payload.state[key] = value;
    });

    mountedRoot.reactRoot.render(<RuntimeMount payload={payload} />);

    if (message.notify && Object.prototype.hasOwnProperty.call(message.updates || {}, "value")) {
      setInputValue(message.id, message.updates.value, "event");
    }
  });
}

function registerUpdateHandler() {
  if (!window.Shiny || !window.Shiny.addCustomMessageHandler) return;
  if (window.shinyblocksRuntimeUpdateHandlerRegistered) return;

  window.Shiny.addCustomMessageHandler("sb:update", applyUpdate);
  window.shinyblocksRuntimeUpdateHandlerRegistered = true;
}

function observeDynamicUi() {
  if (window.shinyblocksRuntimeDynamicObserver) return;

  window.shinyblocksRuntimeDynamicObserver = new MutationObserver(function observeRecords(records) {
    records.forEach(function observeRecord(record) {
      Array.from(record.removedNodes).forEach(function removedNode(node) {
        if (node.nodeType !== Node.ELEMENT_NODE) return;
        if (node.matches && node.matches("[data-shinyblocks-runtime='true']")) {
          unmountRoot(node);
        }
        runtimeRoots(node).forEach(unmountRoot);
      });

      Array.from(record.addedNodes).forEach(function addedNode(node) {
        if (node.nodeType !== Node.ELEMENT_NODE) return;
        if (node.matches && node.matches("[data-shinyblocks-runtime='true']")) {
          mountRoot(node);
        }
        mountAll(node);
      });
    });
  });

  window.shinyblocksRuntimeDynamicObserver.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
}

function init() {
  mountAll(document);
  observeDynamicUi();
  registerUpdateHandler();
  flushPendingInputs(document);
}

window.shinyblocksRuntime = {
  init,
  mountAll,
  applyUpdate
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true });
} else {
  init();
}

document.addEventListener("shiny:connected", function connected() {
  flushPendingInputs(document);
  schedulePendingInputFlush();
});
