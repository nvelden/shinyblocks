import React, { useEffect, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import { createPortal } from "react-dom";

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

function isSelectPayload(payload) {
  return payload && payload.component === "select";
}

function isDialogPayload(payload) {
  return payload && payload.component === "dialog";
}

function isPopoverPayload(payload) {
  return payload && payload.component === "popover";
}

function isCheckboxPayload(payload) {
  return payload && payload.component === "checkbox";
}

function isSwitchPayload(payload) {
  return payload && payload.component === "switch";
}

function nativeSelect(root) {
  return root ? root.querySelector(".sb-select-native") : null;
}

function nativeCheckbox(root) {
  return root ? root.querySelector(".sb-checkbox-native") : null;
}

function nativeSwitch(root) {
  return root ? root.querySelector(".sb-switch-native") : null;
}

function setNativeCheckboxValue(root, checked, notify) {
  const native = nativeCheckbox(root);
  if (!native) return;

  native.checked = Boolean(checked);
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

function setNativeSwitchValue(root, checked, notify) {
  const native = nativeSwitch(root);
  if (!native) return;

  native.checked = Boolean(checked);
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

function cssEscape(value) {
  if (window.CSS && typeof window.CSS.escape === "function") {
    return window.CSS.escape(value);
  }
  return String(value).replace(/["\\#.;,[\]()=>+~*^$|!]/g, "\\$&");
}

function setNativeChoices(root, choices, placeholder, selected) {
  const native = nativeSelect(root);
  if (!native) return;

  native.textContent = "";

  if (placeholder != null && String(placeholder).length > 0) {
    const option = document.createElement("option");
    option.value = "";
    option.textContent = String(placeholder);
    native.appendChild(option);
  }

  (choices || []).forEach((choice) => {
    const option = document.createElement("option");
    option.value = String(choice.value);
    option.textContent = String(choice.label);
    native.appendChild(option);
  });

  native.value = selected == null ? "" : String(selected);
}

function setNativeValue(root, value, notify) {
  const native = nativeSelect(root);
  if (!native) return;

  native.value = value == null ? "" : String(value);
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

function labelIdForInput(inputId) {
  if (!inputId) return null;

  const label = document.querySelector(`label[for="${cssEscape(inputId)}"]`);
  if (!label) return null;

  if (!label.id) {
    label.id = `${inputId}-label`;
  }
  return label.id;
}

function focusSelectTrigger(root) {
  const trigger = root && root.querySelector(".sb-select-trigger");
  if (trigger && !trigger.disabled) {
    trigger.focus();
  }
}

function installNativeFocusForwarding(root) {
  const native = nativeSelect(root);
  if (!native || native.__sbSelectFocusForwarding) return;

  const handler = () => focusSelectTrigger(root);
  native.addEventListener("focus", handler);
  native.__sbSelectFocusForwarding = handler;
}

function registerSelectBinding() {
  if (
    window.shinyblocksSelectBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksSelectBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector = "[data-shinyblocks-runtime='true'][data-sb-component='select']";
      const root = scope || document;
      const matches = Array.from(root.querySelectorAll(selector));
      if (root.matches && root.matches(selector)) {
        matches.unshift(root);
      }
      return matches;
    }

    getId(el) {
      return el.dataset.sbInputId;
    }

    getType() {
      return null;
    }

    getValue(el) {
      const native = nativeSelect(el);
      return native ? native.value : null;
    }

    setValue(el, value) {
      setNativeValue(el, value, false);
      if (typeof el.__sbSelectReceive === "function") {
        el.__sbSelectReceive({ selected: value == null ? "" : String(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const native = nativeSelect(el);
      if (!native) return;

      const handler = () => callback(false);
      native.addEventListener("change", handler);
      el.__sbSelectChangeHandler = handler;
    }

    unsubscribe(el) {
      const native = nativeSelect(el);
      if (!native || !el.__sbSelectChangeHandler) return;

      native.removeEventListener("change", el.__sbSelectChangeHandler);
      delete el.__sbSelectChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbSelectReceive === "function") {
        el.__sbSelectReceive(data || {});
        return;
      }

      if (data && Object.prototype.hasOwnProperty.call(data, "choices")) {
        setNativeChoices(el, data.choices, data.placeholder, data.selected);
      }
      if (data && Object.prototype.hasOwnProperty.call(data, "selected")) {
        setNativeValue(el, data.selected, Boolean(data.notify));
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksSelectBinding(),
    "shinyblocks.select"
  );
  window.shinyblocksSelectBindingRegistered = true;
}

function bindSelectRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindSelectRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerDialogBinding() {
  if (
    window.shinyblocksDialogBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksDialogBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector = "[data-shinyblocks-runtime='true'][data-sb-component='dialog']";
      const root = scope || document;
      const matches = Array.from(root.querySelectorAll(selector));
      if (root.matches && root.matches(selector)) {
        matches.unshift(root);
      }
      return matches;
    }

    getId(el) {
      return el.dataset.sbInputId;
    }

    getType() {
      return null;
    }

    getValue(el) {
      return Boolean(el.__sbDialogValue);
    }

    setValue(el, value) {
      if (typeof el.__sbDialogReceive === "function") {
        el.__sbDialogReceive({ open: Boolean(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(false);
      el.addEventListener("sb:dialog-change", handler);
      el.__sbDialogChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbDialogChangeHandler) return;
      el.removeEventListener("sb:dialog-change", el.__sbDialogChangeHandler);
      delete el.__sbDialogChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbDialogReceive === "function") {
        el.__sbDialogReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksDialogBinding(),
    "shinyblocks.dialog"
  );
  window.shinyblocksDialogBindingRegistered = true;
}

function bindDialogRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindDialogRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerPopoverBinding() {
  if (
    window.shinyblocksPopoverBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksPopoverBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='popover'][data-sb-input-id]";
      const root = scope || document;
      const matches = Array.from(root.querySelectorAll(selector));
      if (root.matches && root.matches(selector)) {
        matches.unshift(root);
      }
      return matches.filter((el) => Boolean(el.dataset.sbInputId));
    }

    getId(el) {
      return el.dataset.sbInputId;
    }

    getType() {
      return null;
    }

    getValue(el) {
      return Boolean(el.__sbPopoverValue);
    }

    setValue(el, value) {
      if (typeof el.__sbPopoverReceive === "function") {
        el.__sbPopoverReceive({ open: Boolean(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(false);
      el.addEventListener("sb:popover-change", handler);
      el.__sbPopoverChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbPopoverChangeHandler) return;
      el.removeEventListener("sb:popover-change", el.__sbPopoverChangeHandler);
      delete el.__sbPopoverChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbPopoverReceive === "function") {
        el.__sbPopoverReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksPopoverBinding(),
    "shinyblocks.popover"
  );
  window.shinyblocksPopoverBindingRegistered = true;
}

function bindPopoverRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindPopoverRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerCheckboxBinding() {
  if (
    window.shinyblocksCheckboxBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksCheckboxBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='checkbox'][data-sb-input-id]";
      const root = scope || document;
      const matches = Array.from(root.querySelectorAll(selector));
      if (root.matches && root.matches(selector)) {
        matches.unshift(root);
      }
      return matches.filter((el) => Boolean(el.dataset.sbInputId));
    }

    getId(el) {
      return el.dataset.sbInputId;
    }

    getType() {
      return null;
    }

    getValue(el) {
      return Boolean(el.__sbCheckboxValue);
    }

    setValue(el, value) {
      if (typeof el.__sbCheckboxReceive === "function") {
        el.__sbCheckboxReceive({ checked: Boolean(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(false);
      el.addEventListener("sb:checkbox-change", handler);
      el.__sbCheckboxChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbCheckboxChangeHandler) return;
      el.removeEventListener("sb:checkbox-change", el.__sbCheckboxChangeHandler);
      delete el.__sbCheckboxChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbCheckboxReceive === "function") {
        el.__sbCheckboxReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksCheckboxBinding(),
    "shinyblocks.checkbox"
  );
  window.shinyblocksCheckboxBindingRegistered = true;
}

function bindCheckboxRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindCheckboxRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerSwitchBinding() {
  if (
    window.shinyblocksSwitchBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksSwitchBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='switch'][data-sb-input-id]";
      const root = scope || document;
      const matches = Array.from(root.querySelectorAll(selector));
      if (root.matches && root.matches(selector)) {
        matches.unshift(root);
      }
      return matches.filter((el) => Boolean(el.dataset.sbInputId));
    }

    getId(el) {
      return el.dataset.sbInputId;
    }

    getType() {
      return null;
    }

    getValue(el) {
      return Boolean(el.__sbSwitchValue);
    }

    setValue(el, value) {
      if (typeof el.__sbSwitchReceive === "function") {
        el.__sbSwitchReceive({ checked: Boolean(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(false);
      el.addEventListener("sb:switch-change", handler);
      el.__sbSwitchChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbSwitchChangeHandler) return;
      el.removeEventListener("sb:switch-change", el.__sbSwitchChangeHandler);
      delete el.__sbSwitchChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbSwitchReceive === "function") {
        el.__sbSwitchReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksSwitchBinding(),
    "shinyblocks.switch"
  );
  window.shinyblocksSwitchBindingRegistered = true;
}

function bindSwitchRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindSwitchRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function RuntimeMount({ payload, root }) {
  if (payload.component === "button") {
    return <Button payload={payload} />;
  }

  if (payload.component === "badge") {
    return <Badge payload={payload} />;
  }

  if (payload.component === "separator") {
    return <Separator payload={payload} />;
  }

  if (payload.component === "spinner") {
    return <Spinner payload={payload} />;
  }

  if (payload.component === "skeleton") {
    return <Skeleton payload={payload} />;
  }

  if (payload.component === "empty") {
    return <Empty payload={payload} />;
  }

  if (payload.component === "value-box") {
    return <ValueBox payload={payload} />;
  }

  if (payload.component === "alert") {
    return <Alert payload={payload} />;
  }

  if (payload.component === "card") {
    return null;
  }

  if (payload.component === "dialog") {
    return <Dialog payload={payload} root={root} />;
  }

  if (payload.component === "popover") {
    return <Popover payload={payload} root={root} />;
  }

  if (payload.component === "checkbox") {
    return <Checkbox payload={payload} root={root} />;
  }

  if (payload.component === "switch") {
    return <Switch payload={payload} root={root} />;
  }

  if (payload.component === "select") {
    return <Select payload={payload} root={root} />;
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
  const normalized = Object.fromEntries(
    Object.entries(attrs || {}).filter(([, value]) => value !== false && value !== null)
  );

  if (Object.prototype.hasOwnProperty.call(normalized, "style")) {
    if (
      typeof normalized.style !== "object" ||
      Array.isArray(normalized.style)
    ) {
      throw new Error("shinyblocks runtime style attrs must be objects.");
    }
  }

  return normalized;
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

function Separator({ payload }) {
  const props = payload.props || {};
  const orientation = props.orientation || "horizontal";
  const decorative = Boolean(props.decorative);

  return (
    <div
      data-slot="separator"
      data-orientation={orientation}
      className={classNames(
        "sb-separator",
        `sb-separator-${orientation}`,
        payload.className
      )}
      role={decorative ? undefined : "separator"}
      aria-orientation={decorative ? undefined : orientation}
      aria-hidden={decorative ? "true" : undefined}
    />
  );
}

function Spinner({ payload }) {
  const props = payload.props || {};

  return (
    <span
      data-slot="spinner"
      className={classNames("sb-spinner", payload.className)}
      role="status"
      aria-label={props.label || "Loading"}
    />
  );
}

function Skeleton({ payload }) {
  const props = payload.props || {};
  const attrs = passthroughAttrs(props.attrs);
  delete attrs["aria-hidden"];

  return (
    <div
      data-slot="skeleton"
      className={classNames("sb-skeleton", payload.className)}
      aria-hidden="true"
      {...attrs}
    />
  );
}

function Empty({ payload }) {
  const props = payload.props || {};

  return (
    <section
      data-slot="empty"
      className={classNames("sb-empty", payload.className)}
    >
      {props.iconHtml && (
        <div className="sb-empty-icon">
          <HtmlSlot html={props.iconHtml} />
        </div>
      )}
      <div className="sb-empty-body">
        <h3
          className="sb-empty-title"
          dangerouslySetInnerHTML={{ __html: props.titleHtml || "" }}
        />
        {props.descriptionHtml && (
          <p
            className="sb-empty-description"
            dangerouslySetInnerHTML={{ __html: props.descriptionHtml }}
          />
        )}
        {props.contentHtml && (
          <div
            className="sb-empty-content"
            dangerouslySetInnerHTML={{ __html: props.contentHtml }}
          />
        )}
        {props.actionHtml && (
          <div className="sb-empty-action">
            <HtmlSlot html={props.actionHtml} />
          </div>
        )}
      </div>
    </section>
  );
}

function ValueBox({ payload }) {
  const props = payload.props || {};

  return (
    <section
      data-slot="value-box"
      className={classNames("sb-value-box", payload.className)}
    >
      {props.iconHtml && (
        <div className="sb-value-box-icon">
          <HtmlSlot html={props.iconHtml} />
        </div>
      )}
      <div className="sb-value-box-body">
        <p
          className="sb-value-box-title"
          dangerouslySetInnerHTML={{ __html: props.titleHtml || "" }}
        />
        <div
          className="sb-value-box-value"
          dangerouslySetInnerHTML={{ __html: props.valueHtml || "" }}
        />
        {props.descriptionHtml && (
          <p
            className="sb-value-box-description"
            dangerouslySetInnerHTML={{ __html: props.descriptionHtml }}
          />
        )}
        {props.contentHtml && (
          <div
            className="sb-value-box-content"
            dangerouslySetInnerHTML={{ __html: props.contentHtml }}
          />
        )}
      </div>
    </section>
  );
}

function Alert({ payload }) {
  const props = payload.props || {};
  const variant = props.variant || "default";

  return (
    <div
      data-slot="alert"
      data-variant={variant}
      role="alert"
      className={classNames(
        "sb-alert",
        `sb-alert-${variant}`,
        payload.className
      )}
    >
      {props.iconHtml && (
        <div className="sb-alert-icon">
          <HtmlSlot html={props.iconHtml} />
        </div>
      )}
      <div
        className="sb-alert-content"
        dangerouslySetInnerHTML={{
          __html:
            (props.titleHtml || "") +
            (props.descriptionHtml || "") +
            (props.contentHtml || "")
        }}
      />
    </div>
  );
}

const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "[tabindex]:not([tabindex='-1'])"
].join(",");

function focusableChildren(container) {
  if (!container) return [];
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter(
    (el) => !el.hasAttribute("aria-hidden") && el.offsetParent !== null
  );
}

function Dialog({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id || "dialog";
  const [open, setOpenState] = useState(Boolean(state.open));
  const [titleHtml, setTitleHtml] = useState(props.titleHtml || "");
  const [descriptionHtml, setDescriptionHtml] = useState(
    props.descriptionHtml || ""
  );
  const [footerHtml, setFooterHtml] = useState(props.footerHtml || "");
  const [size, setSize] = useState(props.size || "default");
  const hideTitle = Boolean(props.hideTitle);
  const titleId = `${inputId}-title`;
  const descriptionId = `${inputId}-description`;

  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);

  useEffect(() => {
    if (root) {
      root.__sbDialogValue = open;
      root.dataset.sbDialogOpen = open ? "true" : "false";
    }
  }, [open, root]);

  function notifyChange() {
    if (!root) return;
    root.dispatchEvent(new CustomEvent("sb:dialog-change"));
  }

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
    }
    setOpenState(nextOpen);
    if (notify !== false) {
      requestAnimationFrame(notifyChange);
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDialogReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "titleHtml")) {
        setTitleHtml(nextData.titleHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "descriptionHtml")) {
        setDescriptionHtml(nextData.descriptionHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "footerHtml")) {
        setFooterHtml(nextData.footerHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        setOpen(Boolean(nextData.open), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbDialogReceive;
    };
  }, [root]);

  useEffect(() => {
    if (!open) return undefined;

    const previousOverflow = document.body.style.overflow;
    const previousPaddingRight = document.body.style.paddingRight;
    const scrollbarWidth =
      window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    if (scrollbarWidth > 0) {
      document.body.style.paddingRight = `${scrollbarWidth}px`;
    }

    const focusables = focusableChildren(contentRef.current);
    const initial = focusables[0] || contentRef.current;
    initial && initial.focus({ preventScroll: true });

    function onKeyDown(event) {
      if (event.key === "Escape") {
        event.stopPropagation();
        setOpen(false);
        return;
      }
      if (event.key !== "Tab") return;

      const items = focusableChildren(contentRef.current);
      if (items.length === 0) {
        event.preventDefault();
        contentRef.current && contentRef.current.focus();
        return;
      }

      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement;

      if (event.shiftKey && active === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && active === last) {
        event.preventDefault();
        first.focus();
      }
    }

    document.addEventListener("keydown", onKeyDown);

    return () => {
      document.removeEventListener("keydown", onKeyDown);
      document.body.style.overflow = previousOverflow;
      document.body.style.paddingRight = previousPaddingRight;

      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
  }, [open]);

  const portal = ensurePortalRoot();

  return (
    <>
      {props.triggerLabel && (
        <button
          type="button"
          className="sb-button sb-button-default sb-button-size-default"
          data-slot="dialog-trigger"
          aria-haspopup="dialog"
          aria-expanded={open ? "true" : "false"}
          onClick={() => setOpen(true)}
        >
          {props.triggerLabel}
        </button>
      )}
      {open &&
        createPortal(
          <div data-slot="dialog" data-sb-dialog-open="true">
            <div
              className="sb-dialog-overlay"
              data-slot="dialog-overlay"
              onClick={() => setOpen(false)}
            />
            <div
              role="dialog"
              aria-modal="true"
              aria-labelledby={titleId}
              aria-describedby={descriptionHtml ? descriptionId : undefined}
              tabIndex={-1}
              ref={contentRef}
              className={classNames(
                "sb-dialog-content",
                `sb-dialog-content-size-${size}`,
                payload.className
              )}
              data-slot="dialog-content"
              data-size={size}
            >
              <div className="sb-dialog-header" data-slot="dialog-header">
                <HtmlSlot
                  html={titleHtml}
                  id={titleId}
                  className={classNames(
                    "sb-dialog-title",
                    hideTitle && "sb-visually-hidden"
                  )}
                />
                {descriptionHtml && (
                  <HtmlSlot
                    html={descriptionHtml}
                    id={descriptionId}
                    className="sb-dialog-description"
                  />
                )}
              </div>
              {props.bodyHtml && (
                <div
                  className="sb-dialog-body"
                  data-slot="dialog-body"
                  dangerouslySetInnerHTML={{ __html: props.bodyHtml }}
                />
              )}
              {footerHtml && (
                <div
                  className="sb-dialog-footer"
                  data-slot="dialog-footer"
                  dangerouslySetInnerHTML={{ __html: footerHtml }}
                />
              )}
              <button
                type="button"
                className="sb-dialog-close"
                data-slot="dialog-close"
                aria-label="Close"
                onClick={() => setOpen(false)}
              >
                ×
              </button>
            </div>
          </div>,
          portal
        )}
    </>
  );
}

function Popover({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const [open, setOpenState] = useState(Boolean(state.open));
  const [position, setPosition] = useState(null);
  const [triggerLabel, setTriggerLabel] = useState(props.triggerLabel || "");
  const [bodyHtml, setBodyHtml] = useState(props.bodyHtml || "");
  const [side, setSide] = useState(props.side || "bottom");
  const [align, setAlign] = useState(props.align || "center");
  const [contentStyle, setContentStyle] = useState(props.contentStyle || null);
  const [contentClass, setContentClass] = useState(props.contentClass || null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);
  const contentId = `${payload.id || "popover"}-content`;

  useEffect(() => {
    if (root) {
      root.__sbPopoverValue = open;
      root.dataset.sbPopoverOpen = open ? "true" : "false";
    }
  }, [open, root]);

  function notifyChange() {
    if (!root) return;
    root.dispatchEvent(new CustomEvent("sb:popover-change"));
  }

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
    }
    setOpenState(nextOpen);
    if (notify !== false) {
      requestAnimationFrame(notifyChange);
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbPopoverReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "triggerLabel")) {
        setTriggerLabel(nextData.triggerLabel || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "bodyHtml")) {
        setBodyHtml(nextData.bodyHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "side")) {
        setSide(nextData.side || "bottom");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "align")) {
        setAlign(nextData.align || "center");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentStyle")) {
        setContentStyle(nextData.contentStyle || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentClass")) {
        setContentClass(nextData.contentClass || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        setOpen(Boolean(nextData.open), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbPopoverReceive;
    };
  }, [root]);

  useEffect(() => {
    if (!open || !triggerRef.current) return undefined;

    function updatePosition() {
      const rect = triggerRef.current.getBoundingClientRect();
      const offset = 8;
      let top = 0;
      let left = 0;
      if (side === "bottom") {
        top = rect.bottom + offset;
      } else if (side === "top") {
        top = rect.top - offset;
      } else if (side === "left") {
        left = rect.left - offset;
        top = rect.top;
      } else if (side === "right") {
        left = rect.right + offset;
        top = rect.top;
      }
      if (side === "top" || side === "bottom") {
        if (align === "center") {
          left = rect.left + rect.width / 2;
        } else if (align === "start") {
          left = rect.left;
        } else {
          left = rect.right;
        }
      } else if (align === "center") {
        top = rect.top + rect.height / 2;
      } else if (align === "end") {
        top = rect.bottom;
      }
      setPosition({ top, left });
    }

    updatePosition();
    window.addEventListener("scroll", updatePosition, true);
    window.addEventListener("resize", updatePosition);
    return () => {
      window.removeEventListener("scroll", updatePosition, true);
      window.removeEventListener("resize", updatePosition);
    };
  }, [open, side, align]);

  useEffect(() => {
    if (!open) return undefined;

    const focusFrame = requestAnimationFrame(() => {
      const focusables = focusableChildren(contentRef.current);
      const initial = focusables[0] || contentRef.current;
      if (initial && typeof initial.focus === "function") {
        initial.focus({ preventScroll: true });
      }
    });

    function onDocumentPointerDown(event) {
      const target = event.target;
      if (triggerRef.current?.contains(target)) return;
      if (contentRef.current?.contains(target)) return;
      setOpen(false);
    }

    function onDocumentKeyDown(event) {
      if (event.key !== "Escape") return;
      event.stopPropagation();
      setOpen(false);
    }

    document.addEventListener("pointerdown", onDocumentPointerDown);
    document.addEventListener("keydown", onDocumentKeyDown);

    return () => {
      cancelAnimationFrame(focusFrame);
      document.removeEventListener("pointerdown", onDocumentPointerDown);
      document.removeEventListener("keydown", onDocumentKeyDown);

      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
  }, [open]);

  const portal = ensurePortalRoot();

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        className="sb-button sb-button-default sb-button-size-default"
        data-slot="popover-trigger"
        aria-haspopup="dialog"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        onClick={() => setOpen(!open)}
      >
        {triggerLabel}
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className={classNames("sb-popover-content", contentClass)}
            data-slot="popover-content"
            data-side={side}
            data-align={align}
            role="dialog"
            tabIndex={-1}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: popoverTransform(side, align),
              ...(contentStyle || {})
            }}
            dangerouslySetInnerHTML={{ __html: bodyHtml || "" }}
          />,
          portal
        )}
    </>
  );
}

function Checkbox({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [checked, setCheckedState] = useState(Boolean(state.value));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const controlRef = useRef(null);
  const invalid = root?.getAttribute("aria-invalid") === "true";
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const inlineLabelId = inputId ? `${inputId}__label` : undefined;

  useEffect(() => {
    if (root) {
      root.__sbCheckboxValue = checked;
      root.dataset.sbCheckboxChecked = checked ? "true" : "false";
    }
  }, [checked, root]);

  useEffect(() => {
    if (!root) return;
    setNativeCheckboxValue(root, checked, false);
  }, [checked, root]);

  useEffect(() => {
    if (!root) return undefined;

    setLabelledBy(labelIdForInput(inputId));

    root.__sbCheckboxReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "checked")) {
        const nextChecked = Boolean(nextData.checked);
        setCheckedState(nextChecked);
        setNativeCheckboxValue(root, nextChecked, Boolean(nextData.notify));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeCheckbox(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbCheckboxReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    root.toggleAttribute("data-disabled", disabled);
    const native = nativeCheckbox(root);
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  function notifyChange(nextChecked) {
    if (!root) return;
    root.__sbCheckboxValue = nextChecked;
    root.dataset.sbCheckboxChecked = nextChecked ? "true" : "false";
    setNativeCheckboxValue(root, nextChecked, true);
    root.dispatchEvent(new CustomEvent("sb:checkbox-change"));
  }

  function setChecked(nextChecked, notify = false) {
    const next = Boolean(nextChecked);
    setCheckedState(next);
    if (notify) {
      requestAnimationFrame(() => notifyChange(next));
    }
  }

  function toggle() {
    if (disabled) return;
    setChecked(!checked, true);
  }

  return (
    <div
      data-slot="checkbox"
      className={classNames("sb-checkbox", className)}
      data-state={checked ? "checked" : "unchecked"}
      data-disabled={disabled ? "true" : undefined}
    >
      <button
        ref={controlRef}
        type="button"
        className="sb-checkbox-button"
        data-slot="checkbox-control"
        data-state={checked ? "checked" : "unchecked"}
        role="checkbox"
        aria-checked={checked ? "true" : "false"}
        aria-labelledby={labelledBy || inlineLabelId || undefined}
        aria-describedby={describedBy}
        aria-invalid={invalid || undefined}
        disabled={disabled}
        style={style}
        onClick={toggle}
        onKeyDown={(event) => {
          if (event.key === " " || event.key === "Enter") {
            event.preventDefault();
            toggle();
          }
        }}
      >
        <span className="sb-checkbox-indicator" aria-hidden="true">
          <svg viewBox="0 0 15 15" aria-hidden="true" focusable="false">
            <path
              d="M11.4669 3.72684C11.7598 3.43395 12.2347 3.43395 12.5276 3.72684C12.8205 4.01974 12.8205 4.49461 12.5276 4.7875L6.86095 10.4542C6.56806 10.7471 6.09318 10.7471 5.80029 10.4542L3.46696 8.12084C3.17407 7.82795 3.17407 7.35308 3.46696 7.06018C3.75986 6.76729 4.23473 6.76729 4.52762 7.06018L6.33062 8.86317L11.4669 3.72684Z"
              fill="currentColor"
            />
          </svg>
        </span>
      </button>
      <HtmlSlot
        id={inlineLabelId}
        html={props.labelHtml}
        className="sb-checkbox-text"
        onClick={() => {
          if (disabled) return;
          controlRef.current?.focus();
          toggle();
        }}
      />
    </div>
  );
}

function Switch({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [checked, setCheckedState] = useState(Boolean(state.value));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const controlRef = useRef(null);
  const invalid = root?.getAttribute("aria-invalid") === "true";
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const inlineLabelId = inputId ? `${inputId}__label` : undefined;

  useEffect(() => {
    if (root) {
      root.__sbSwitchValue = checked;
      root.dataset.sbSwitchChecked = checked ? "true" : "false";
    }
  }, [checked, root]);

  useEffect(() => {
    if (!root) return;
    setNativeSwitchValue(root, checked, false);
  }, [checked, root]);

  useEffect(() => {
    if (!root) return undefined;

    setLabelledBy(labelIdForInput(inputId));

    root.__sbSwitchReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "checked")) {
        const nextChecked = Boolean(nextData.checked);
        setCheckedState(nextChecked);
        setNativeSwitchValue(root, nextChecked, Boolean(nextData.notify));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSwitch(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbSwitchReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    root.toggleAttribute("data-disabled", disabled);
    const native = nativeSwitch(root);
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  function notifyChange(nextChecked) {
    if (!root) return;
    root.__sbSwitchValue = nextChecked;
    root.dataset.sbSwitchChecked = nextChecked ? "true" : "false";
    setNativeSwitchValue(root, nextChecked, true);
    root.dispatchEvent(new CustomEvent("sb:switch-change"));
  }

  function setChecked(nextChecked, notify = false) {
    const next = Boolean(nextChecked);
    setCheckedState(next);
    if (notify) {
      requestAnimationFrame(() => notifyChange(next));
    }
  }

  function toggle() {
    if (disabled) return;
    setChecked(!checked, true);
  }

  return (
    <div
      data-slot="switch"
      className={classNames("sb-switch", className)}
      data-state={checked ? "checked" : "unchecked"}
      data-disabled={disabled ? "true" : undefined}
    >
      <button
        ref={controlRef}
        type="button"
        className="sb-switch-button"
        data-slot="switch-control"
        data-state={checked ? "checked" : "unchecked"}
        role="switch"
        aria-checked={checked ? "true" : "false"}
        aria-labelledby={labelledBy || inlineLabelId || undefined}
        aria-describedby={describedBy}
        aria-invalid={invalid || undefined}
        disabled={disabled}
        style={style}
        onClick={toggle}
        onKeyDown={(event) => {
          if (event.key === " " || event.key === "Enter") {
            event.preventDefault();
            toggle();
          }
        }}
      >
        <span className="sb-switch-thumb" aria-hidden="true" />
      </button>
      <HtmlSlot
        id={inlineLabelId}
        html={props.labelHtml}
        className="sb-switch-text"
        onClick={() => {
          if (disabled) return;
          controlRef.current?.focus();
          toggle();
        }}
      />
    </div>
  );
}

function popoverTransform(side, align) {
  if (side === "top" || side === "bottom") {
    const y = side === "top" ? "-100%" : "0";
    if (align === "center") return `translate(-50%, ${y})`;
    if (align === "start") return `translate(0, ${y})`;
    return `translate(-100%, ${y})`;
  }
  const x = side === "left" ? "-100%" : "0";
  if (align === "center") return `translate(${x}, -50%)`;
  if (align === "end") return `translate(${x}, -100%)`;
  return `translate(${x}, 0)`;
}

function Select({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [choices, setChoices] = useState(props.choices || []);
  const [value, setValue] = useState(state.value ?? "");
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [open, setOpen] = useState(false);
  const [highlighted, setHighlighted] = useState(-1);
  const [labelledBy, setLabelledBy] = useState(null);
  const [position, setPosition] = useState(null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const valueRef = useRef(value);
  const choicesRef = useRef(choices);
  const placeholderRef = useRef(placeholder);

  useEffect(() => {
    valueRef.current = value;
  }, [value]);

  useEffect(() => {
    choicesRef.current = choices;
  }, [choices]);

  useEffect(() => {
    placeholderRef.current = placeholder;
  }, [placeholder]);

  function updatePosition() {
    const trigger = triggerRef.current;
    if (!trigger) return;

    const rect = trigger.getBoundingClientRect();
    setPosition({
      top: rect.bottom + 4,
      left: rect.left,
      minWidth: rect.width
    });
  }

  function selectedIndex() {
    return choicesRef.current.findIndex((choice) => choice.value === valueRef.current);
  }

  function openSelect() {
    if (disabled) return;

    const index = selectedIndex();
    setHighlighted(index >= 0 ? index : 0);
    setOpen(true);
    requestAnimationFrame(updatePosition);
  }

  function closeSelect({ focus = false } = {}) {
    setOpen(false);
    setHighlighted(-1);
    if (focus) {
      requestAnimationFrame(() => triggerRef.current?.focus());
    }
  }

  function commit(nextValue) {
    if (disabled) return;

    const next = nextValue == null ? "" : String(nextValue);
    setValue(next);
    setNativeValue(root, next, true);
    closeSelect({ focus: true });
  }

  function labelForCurrentValue() {
    if (!value) return placeholder || "";
    const choice = choices.find((item) => item.value === value);
    return choice ? choice.label : "";
  }

  useEffect(() => {
    if (!root) return undefined;

    installNativeFocusForwarding(root);
    setLabelledBy(labelIdForInput(inputId));

    root.__sbSelectReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        const nextPlaceholder = nextData.placeholder || "";
        placeholderRef.current = nextPlaceholder;
        setPlaceholder(nextPlaceholder);
        setNativeChoices(root, choicesRef.current, nextPlaceholder, valueRef.current);
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "choices")) {
        const nextChoices = nextData.choices || [];
        choicesRef.current = nextChoices;
        setChoices(nextChoices);
        setOpen(false);
        setHighlighted(-1);
        setNativeChoices(
          root,
          nextChoices,
          Object.prototype.hasOwnProperty.call(nextData, "placeholder")
            ? nextData.placeholder
            : placeholderRef.current,
          Object.prototype.hasOwnProperty.call(nextData, "selected")
            ? nextData.selected
            : valueRef.current
        );
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        const next = nextData.selected == null ? "" : String(nextData.selected);
        valueRef.current = next;
        setValue(next);
        setNativeValue(root, next, Boolean(nextData.notify));
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSelect(root);
        if (native) native.disabled = nextDisabled;
        if (nextDisabled) closeSelect();
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "width")) {
        setWidth(nextData.width || "100%");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        const nextInvalid = Boolean(nextData.invalid);
        setInvalid(nextInvalid);
        root.toggleAttribute("data-invalid", nextInvalid);
      }
    };

    return () => {
      delete root.__sbSelectReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    setNativeChoices(root, choices, placeholder, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, placeholder, root, value]);

  useEffect(() => {
    if (!open) return undefined;

    updatePosition();

    const onPointerDown = (event) => {
      const target = event.target;
      if (
        triggerRef.current?.contains(target) ||
        contentRef.current?.contains(target)
      ) {
        return;
      }
      closeSelect();
    };
    const onWindowChange = () => updatePosition();

    document.addEventListener("pointerdown", onPointerDown);
    window.addEventListener("resize", onWindowChange);
    window.addEventListener("scroll", onWindowChange, true);

    return () => {
      document.removeEventListener("pointerdown", onPointerDown);
      window.removeEventListener("resize", onWindowChange);
      window.removeEventListener("scroll", onWindowChange, true);
    };
  }, [open]);

  useEffect(() => {
    if (!open || highlighted < 0) return;
    const item = contentRef.current?.querySelector(
      `[data-sb-index="${highlighted}"]`
    );
    item?.scrollIntoView({ block: "nearest" });
  }, [highlighted, open]);

  function moveHighlight(delta) {
    if (choices.length === 0) return;
    setHighlighted((current) => {
      const base = current < 0 ? selectedIndex() : current;
      const next = (base + delta + choices.length) % choices.length;
      return next;
    });
  }

  function onTriggerKeyDown(event) {
    if (disabled) return;

    if (event.key === "ArrowDown") {
      event.preventDefault();
      if (!open) openSelect();
      else moveHighlight(1);
      return;
    }
    if (event.key === "ArrowUp") {
      event.preventDefault();
      if (!open) openSelect();
      else moveHighlight(-1);
      return;
    }
    if (event.key === "Home") {
      event.preventDefault();
      if (!open) openSelect();
      setHighlighted(0);
      return;
    }
    if (event.key === "End") {
      event.preventDefault();
      if (!open) openSelect();
      setHighlighted(Math.max(choices.length - 1, 0));
      return;
    }
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      if (!open) {
        openSelect();
      } else if (highlighted >= 0 && choices[highlighted]) {
        commit(choices[highlighted].value);
      }
      return;
    }
    if (event.key === "Escape" && open) {
      event.preventDefault();
      closeSelect({ focus: true });
      return;
    }
    if (event.key === "Tab" && open) {
      closeSelect();
    }
  }

  const contentId = `${inputId}-content`;
  const highlightedId = highlighted >= 0 ? `${inputId}-item-${highlighted}` : undefined;
  const triggerLabel = labelForCurrentValue();
  const portal = open ? ensurePortalRoot() : null;

  return (
    <div
      data-slot="select"
      data-size={size}
      className={classNames("sb-select", className)}
      style={{ width }}
      data-disabled={disabled ? "true" : undefined}
      data-invalid={invalid ? "true" : undefined}
    >
      <button
        ref={triggerRef}
        id={`${inputId}-trigger`}
        type="button"
        className={classNames("sb-select-trigger", `sb-select-size-${size}`)}
        data-slot="select-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={!value ? "true" : undefined}
        data-size={size}
        data-invalid={invalid ? "true" : undefined}
        role="combobox"
        aria-haspopup="listbox"
        aria-expanded={open ? "true" : "false"}
        aria-controls={contentId}
        aria-invalid={invalid || undefined}
        aria-labelledby={labelledBy || undefined}
        style={style}
        disabled={disabled}
        onClick={() => {
          if (open) closeSelect();
          else openSelect();
        }}
        onKeyDown={onTriggerKeyDown}
      >
        <span className="sb-select-trigger-value">{triggerLabel}</span>
        <svg className="sb-select-trigger-icon" aria-hidden="true" focusable="false">
          <use href={`${props.spriteHref}#sb-icon-chevron-down`} />
        </svg>
      </button>
      {open && portal && createPortal(
        <div
          ref={contentRef}
          className="sb-select-content"
          data-slot="select-content"
          data-state="open"
          id={contentId}
          role="listbox"
          aria-activedescendant={highlightedId}
          style={position ? {
            position: "fixed",
            top: `${position.top}px`,
            left: `${position.left}px`,
            minWidth: `${position.minWidth}px`
          } : undefined}
        >
          <div className="sb-select-viewport" data-slot="select-viewport">
            {choices.map((choice, index) => {
              const selected = choice.value === value;
              return (
                <div
                  key={choice.value}
                  id={`${inputId}-item-${index}`}
                  className="sb-select-item"
                  data-slot="select-item"
                  data-sb-index={index}
                  data-highlighted={highlighted === index ? "true" : undefined}
                  data-state={selected ? "checked" : "unchecked"}
                  role="option"
                  aria-selected={selected ? "true" : "false"}
                  onMouseEnter={() => setHighlighted(index)}
                  onMouseDown={(event) => event.preventDefault()}
                  onClick={() => commit(choice.value)}
                >
                  <span className="sb-select-item-text">{choice.label}</span>
                  <span className="sb-select-item-indicator" aria-hidden="true">
                    <svg aria-hidden="true" focusable="false">
                      <use href={`${props.spriteHref}#sb-icon-check`} />
                    </svg>
                  </span>
                </div>
              );
            })}
          </div>
        </div>,
        portal
      )}
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
  reactRoot.render(<RuntimeMount payload={payload} root={root} />);
  return reactRoot;
}

function mountRoot(root) {
  if (mounted.has(root)) return;

  const payload = readPayload(root);
  if (!payload) return;
  registerSelectBinding();
  registerDialogBinding();
  registerPopoverBinding();
  registerCheckboxBinding();
  registerSwitchBinding();
  payload.rootAttrs = {
    ariaInvalid: root.getAttribute("aria-invalid"),
    ariaDescribedby: root.getAttribute("aria-describedby")
  };

  ensurePortalRoot();
  const reactRoot = renderReactMount(root, payload);

  root.dataset.sbMounted = "true";
  root.dataset.sbSchemaVersion = String(payload.schemaVersion || 1);

  mounted.set(root, { payload, reactRoot });
  if (isSelectPayload(payload)) {
    bindSelectRoot(root);
  } else if (isDialogPayload(payload)) {
    bindDialogRoot(root);
  } else if (isPopoverPayload(payload)) {
    bindPopoverRoot(root);
  } else if (isCheckboxPayload(payload)) {
    bindCheckboxRoot(root);
  } else if (isSwitchPayload(payload)) {
    bindSwitchRoot(root);
  } else {
    bindShinyChildren(root);
  }

  if (
    payload.id &&
    payload.binding &&
    payload.binding.input &&
    !isSelectPayload(payload) &&
    !isDialogPayload(payload) &&
    !isPopoverPayload(payload) &&
    !isCheckboxPayload(payload) &&
    !isSwitchPayload(payload)
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

  if (isSelectPayload(mountedRoot.payload)) {
    unbindSelectRoot(root);
  } else if (isDialogPayload(mountedRoot.payload)) {
    unbindDialogRoot(root);
  } else if (isPopoverPayload(mountedRoot.payload)) {
    unbindPopoverRoot(root);
  } else if (isCheckboxPayload(mountedRoot.payload)) {
    unbindCheckboxRoot(root);
  } else if (isSwitchPayload(mountedRoot.payload)) {
    unbindSwitchRoot(root);
  } else {
    unbindShinyChildren(root);
  }
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
    if (
      !payload ||
      isSelectPayload(payload) ||
      isCheckboxPayload(payload) ||
      isSwitchPayload(payload) ||
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

function applyUpdate(message) {
  if (!message || !message.id) return;
  if (message.component === "select") return;
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
      if (key === "className") {
        payload.className = value;
        return;
      }
      if (
        key === "choices" ||
        key === "placeholder" ||
        key === "disabled" ||
        key === "width" ||
        key === "size" ||
        key === "invalid"
      ) {
        payload.props[key] = value;
      }
      payload.state[key] = value;
    });

    mountedRoot.reactRoot.render(<RuntimeMount payload={payload} root={root} />);

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
  registerSelectBinding();
  registerDialogBinding();
  registerPopoverBinding();
  registerCheckboxBinding();
  registerSwitchBinding();
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
  registerSelectBinding();
  registerDialogBinding();
  registerPopoverBinding();
  registerCheckboxBinding();
  registerSwitchBinding();
  flushPendingInputs(document);
  schedulePendingInputFlush();
});
