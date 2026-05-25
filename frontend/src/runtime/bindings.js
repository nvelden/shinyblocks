import { currentValue, readPayload } from "./dom.js";
import {
  nativeCheckbox,
  nativeInput,
  nativeSelect,
  nativeSlider,
  nativeSwitch,
  nativeTextarea,
  setNativeChoices,
  setNativeValue
} from "./native-inputs.js";

const RUNTIME_INPUT_COMPONENTS = new Set([
  "select",
  "dialog",
  "popover",
  "checkbox",
  "switch",
  "textarea",
  "input",
  "radio-group",
  "slider"
]);

export function isRuntimeInputPayload(payload) {
  return Boolean(payload && RUNTIME_INPUT_COMPONENTS.has(payload.component));
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

function registerButtonBinding() {
  if (
    window.shinyblocksButtonBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksButtonBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='button'][data-sb-input-id]";
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
      if (typeof el.__sbButtonClickCount === "undefined") {
        el.__sbButtonClickCount = 0;
      }
      return el.__sbButtonClickCount;
    }

    setValue(el, value) {
      el.__sbButtonClickCount = Number(value) || 0;
    }

    subscribe(el, callback) {
      const handler = () => {
        if (el.hasAttribute("disabled") || el.querySelector("button:disabled")) {
          return;
        }
        if (typeof el.__sbButtonClickCount === "undefined") {
          el.__sbButtonClickCount = 0;
        }
        el.__sbButtonClickCount += 1;
        callback(false);
      };
      el.addEventListener("click", handler);
      el.__sbButtonClickHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbButtonClickHandler) return;
      el.removeEventListener("click", el.__sbButtonClickHandler);
      delete el.__sbButtonClickHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbButtonReceive === "function") {
        el.__sbButtonReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksButtonBinding(),
    "shinyblocks.button"
  );
  window.shinyblocksButtonBindingRegistered = true;
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
      if (typeof el.__sbCheckboxValue !== "undefined") {
        return Boolean(el.__sbCheckboxValue);
      }

      const native = nativeCheckbox(el);
      return native ? native.checked : false;
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
      if (typeof el.__sbSwitchValue !== "undefined") {
        return Boolean(el.__sbSwitchValue);
      }

      const native = nativeSwitch(el);
      return native ? native.checked : false;
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

function registerTextareaBinding() {
  if (
    window.shinyblocksTextareaBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksTextareaBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='textarea'][data-sb-input-id]";
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
      if (typeof el.__sbTextareaValue === "string") return el.__sbTextareaValue;
      // React mounts asynchronously; Shiny reports initial input values before
      // the first effect runs, so fall back to the payload's state.value.
      const initial = currentValue(readPayload(el));
      return typeof initial === "string" ? initial : "";
    }

    setValue(el, value) {
      if (typeof el.__sbTextareaReceive === "function") {
        el.__sbTextareaReceive({ value: value == null ? "" : String(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(true);
      el.addEventListener("sb:textarea-change", handler);
      el.__sbTextareaChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbTextareaChangeHandler) return;
      el.removeEventListener("sb:textarea-change", el.__sbTextareaChangeHandler);
      delete el.__sbTextareaChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbTextareaReceive === "function") {
        el.__sbTextareaReceive(data || {});
      }
    }

    getRatePolicy() {
      return { policy: "debounce", delay: 250 };
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksTextareaBinding(),
    "shinyblocks.textarea"
  );
  window.shinyblocksTextareaBindingRegistered = true;
}

function bindTextareaRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindTextareaRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerInputBinding() {
  if (
    window.shinyblocksInputBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksInputBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='input'][data-sb-input-id]";
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
      if (typeof el.__sbInputValue === "string") return el.__sbInputValue;
      const initial = currentValue(readPayload(el));
      return typeof initial === "string" ? initial : "";
    }

    setValue(el, value) {
      if (typeof el.__sbInputReceive === "function") {
        el.__sbInputReceive({ value: value == null ? "" : String(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(true);
      el.addEventListener("sb:input-change", handler);
      el.__sbInputChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbInputChangeHandler) return;
      el.removeEventListener("sb:input-change", el.__sbInputChangeHandler);
      delete el.__sbInputChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbInputReceive === "function") {
        el.__sbInputReceive(data || {});
      }
    }

    getRatePolicy() {
      return { policy: "debounce", delay: 250 };
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksInputBinding(),
    "shinyblocks.input"
  );
  window.shinyblocksInputBindingRegistered = true;
}

function bindInputRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindInputRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerRadioGroupBinding() {
  if (
    window.shinyblocksRadioGroupBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksRadioGroupBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='radio-group'][data-sb-input-id]";
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
      return typeof el.__sbRadioGroupValue === "string" ? el.__sbRadioGroupValue : null;
    }

    setValue(el, value) {
      if (typeof el.__sbRadioGroupReceive === "function") {
        el.__sbRadioGroupReceive({ selected: value == null ? null : String(value), notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(false);
      el.addEventListener("sb:radio-group-change", handler);
      el.__sbRadioGroupChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbRadioGroupChangeHandler) return;
      el.removeEventListener("sb:radio-group-change", el.__sbRadioGroupChangeHandler);
      delete el.__sbRadioGroupChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbRadioGroupReceive === "function") {
        el.__sbRadioGroupReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksRadioGroupBinding(),
    "shinyblocks.radio-group"
  );
  window.shinyblocksRadioGroupBindingRegistered = true;
}

function bindRadioGroupRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindRadioGroupRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

function registerSliderBinding() {
  if (
    window.shinyblocksSliderBindingRegistered ||
    !window.Shiny ||
    !window.Shiny.InputBinding ||
    !window.Shiny.inputBindings
  ) {
    return;
  }

  class ShinyblocksSliderBinding extends window.Shiny.InputBinding {
    find(scope) {
      const selector =
        "[data-shinyblocks-runtime='true'][data-sb-component='slider'][data-sb-input-id]";
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
      if (Object.prototype.hasOwnProperty.call(el, "__sbSliderValue")) {
        return el.__sbSliderValue;
      }
      return currentValue(readPayload(el));
    }

    setValue(el, value) {
      if (typeof el.__sbSliderReceive === "function") {
        el.__sbSliderReceive({ value, notify: false });
      }
    }

    subscribe(el, callback) {
      const handler = () => callback(false);
      el.addEventListener("sb:slider-change", handler);
      el.__sbSliderChangeHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbSliderChangeHandler) return;
      el.removeEventListener("sb:slider-change", el.__sbSliderChangeHandler);
      delete el.__sbSliderChangeHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbSliderReceive === "function") {
        el.__sbSliderReceive(data || {});
      }
    }

    getRatePolicy() {
      return null;
    }
  }

  window.Shiny.inputBindings.register(
    new ShinyblocksSliderBinding(),
    "shinyblocks.slider"
  );
  window.shinyblocksSliderBindingRegistered = true;
}

function bindSliderRoot(root) {
  if (!window.Shiny || !window.Shiny.bindAll) return;
  window.Shiny.bindAll(root);
}

function unbindSliderRoot(root) {
  if (!window.Shiny || !window.Shiny.unbindAll) return;
  window.Shiny.unbindAll(root);
}

export function registerRuntimeInputBindings() {
  registerButtonBinding();
  registerSelectBinding();
  registerDialogBinding();
  registerPopoverBinding();
  registerCheckboxBinding();
  registerSwitchBinding();
  registerTextareaBinding();
  registerInputBinding();
  registerRadioGroupBinding();
  registerSliderBinding();
}

export function bindRuntimeInputRoot(root, payload) {
  if (!isRuntimeInputPayload(payload)) return false;

  if (payload.component === "select") bindSelectRoot(root);
  if (payload.component === "dialog") bindDialogRoot(root);
  if (payload.component === "popover") bindPopoverRoot(root);
  if (payload.component === "checkbox") bindCheckboxRoot(root);
  if (payload.component === "switch") bindSwitchRoot(root);
  if (payload.component === "textarea") bindTextareaRoot(root);
  if (payload.component === "input") bindInputRoot(root);
  if (payload.component === "radio-group") bindRadioGroupRoot(root);
  if (payload.component === "slider") bindSliderRoot(root);

  return true;
}

export function unbindRuntimeInputRoot(root, payload) {
  if (!isRuntimeInputPayload(payload)) return false;

  if (payload.component === "select") unbindSelectRoot(root);
  if (payload.component === "dialog") unbindDialogRoot(root);
  if (payload.component === "popover") unbindPopoverRoot(root);
  if (payload.component === "checkbox") unbindCheckboxRoot(root);
  if (payload.component === "switch") unbindSwitchRoot(root);
  if (payload.component === "textarea") unbindTextareaRoot(root);
  if (payload.component === "input") unbindInputRoot(root);
  if (payload.component === "radio-group") unbindRadioGroupRoot(root);
  if (payload.component === "slider") unbindSliderRoot(root);

  return true;
}
