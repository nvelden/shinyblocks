import React from "react";
import { createRoot } from "react-dom/client";
import {
  currentValue,
  ensurePortalRoot,
  readPayload,
  runtimeRoots
} from "./runtime/dom.js";
import {
  bindShinyChildren,
  setInputValue,
  unbindShinyChildren
} from "./runtime/shiny.js";
import {
  bindRuntimeInputRoot,
  isRuntimeInputPayload,
  registerRuntimeInputBindings,
  unbindRuntimeInputRoot
} from "./runtime/bindings.js";
import {
  Alert,
  Badge,
  Empty,
  Separator,
  Skeleton,
  Spinner,
  ValueBox
} from "./components/basic.jsx";
import { Button } from "./components/button.jsx";
import { Code } from "./components/code.jsx";
import { Dialog } from "./components/dialog.jsx";
import { Popover } from "./components/popover.jsx";
import { Checkbox } from "./components/checkbox.jsx";
import { FileInput } from "./components/file-input.jsx";
import { Input } from "./components/input.jsx";
import { RadioGroup } from "./components/radio-group.jsx";
import { Select } from "./components/select.jsx";
import { Slider } from "./components/slider.jsx";
import { Switch } from "./components/switch.jsx";
import { Table } from "./components/table.jsx";
import { Textarea } from "./components/textarea.jsx";
import { Tooltip } from "./components/tooltip.jsx";

const mounted = new Map();

function CardRuntimeMount() {
  return null;
}

const COMPONENTS = {
  button: Button,
  badge: Badge,
  separator: Separator,
  spinner: Spinner,
  skeleton: Skeleton,
  empty: Empty,
  code: Code,
  "value-box": ValueBox,
  alert: Alert,
  card: CardRuntimeMount,
  dialog: Dialog,
  popover: Popover,
  tooltip: Tooltip,
  checkbox: Checkbox,
  "file-input": FileInput,
  switch: Switch,
  textarea: Textarea,
  input: Input,
  "radio-group": RadioGroup,
  slider: Slider,
  select: Select,
  table: Table
};

function RuntimeMount({ payload, root }) {
  const Component = COMPONENTS[payload.component];

  if (Component) {
    return <Component payload={payload} root={root} />;
  }

  return (
    <span
      hidden
      data-shinyblocks-react-mounted={payload.component || "component"}
      data-shinyblocks-schema-version={payload.schemaVersion || 1}
    />
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
  reactRoot.render(<RuntimeMount payload={payload} root={root} />);
  return reactRoot;
}

function mountRoot(root) {
  if (mounted.has(root)) return;

  const payload = readPayload(root);
  if (!payload) return;
  registerRuntimeInputBindings();
  payload.rootAttrs = {
    ariaInvalid: root.getAttribute("aria-invalid"),
    ariaDescribedby: root.getAttribute("aria-describedby")
  };

  ensurePortalRoot();
  const reactRoot = renderReactMount(root, payload);

  root.dataset.sbMounted = "true";
  root.dataset.sbSchemaVersion = String(payload.schemaVersion || 1);

  mounted.set(root, { payload, reactRoot });
  if (!bindRuntimeInputRoot(root, payload)) {
    bindShinyChildren(root);
  }

  if (
    payload.id &&
    payload.binding &&
    payload.binding.input &&
    !isRuntimeInputPayload(payload)
  ) {
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

  if (!unbindRuntimeInputRoot(root, mountedRoot.payload)) {
    unbindShinyChildren(root);
  }
  mountedRoot.reactRoot.unmount();
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
    if (
      !payload ||
      isRuntimeInputPayload(payload) ||
      !payload.id ||
      !payload.binding ||
      !payload.binding.input
    ) {
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
  registerRuntimeInputBindings();
  mountAll(document);
  observeDynamicUi();
  flushPendingInputs(document);
}

window.shinyblocksRuntime = {
  init,
  mountAll
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true });
} else {
  init();
}

document.addEventListener("shiny:connected", function connected() {
  registerRuntimeInputBindings();
  flushPendingInputs(document);
  schedulePendingInputFlush();
});
