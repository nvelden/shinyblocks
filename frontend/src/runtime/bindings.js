import { currentValue, readPayload } from "./dom.js";
import {
  nativeCheckbox,
  nativeSelect,
  nativeSwitch,
  setNativeChoices,
  setNativeValue
} from "./native-inputs.js";

const RUNTIME_INPUT_COMPONENTS = new Set([
  "button",
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

function makeRuntimeBinding(config) {
  const {
    component,
    type = null,
    requireInputId = true,
    receiveProp = null,
    getValue,
    setValue,
    subscribe,
    unsubscribe,
    receiveMessage = null,
    ratePolicy = null
  } = config;

  const selector = requireInputId
    ? `[data-shinyblocks-runtime='true'][data-sb-component='${component}'][data-sb-input-id]`
    : `[data-shinyblocks-runtime='true'][data-sb-component='${component}']`;

  return class extends window.Shiny.InputBinding {
    find(scope) {
      const root = scope || document;
      const matches = Array.from(root.querySelectorAll(selector));
      if (root.matches && root.matches(selector)) matches.unshift(root);
      return requireInputId
        ? matches.filter((el) => Boolean(el.dataset.sbInputId))
        : matches;
    }
    getId(el) { return el.dataset.sbInputId; }
    getType() { return type; }
    getValue(el) { return getValue(el); }
    setValue(el, value) { setValue(el, value); }
    subscribe(el, callback) { subscribe(el, callback); }
    unsubscribe(el) { unsubscribe(el); }
    receiveMessage(el, data) {
      if (receiveMessage) {
        receiveMessage(el, data || {});
        return;
      }
      const handler = el[receiveProp];
      if (typeof handler === "function") handler(data || {});
    }
    getRatePolicy() { return ratePolicy; }
  };
}

function rootEventListener(eventName, handlerProp, rateMode = false) {
  return {
    subscribe(el, callback) {
      const handler = () => callback(rateMode);
      el.addEventListener(eventName, handler);
      el[handlerProp] = handler;
    },
    unsubscribe(el) {
      if (!el[handlerProp]) return;
      el.removeEventListener(eventName, el[handlerProp]);
      delete el[handlerProp];
    }
  };
}

const checkboxEvents = rootEventListener("sb:checkbox-change", "__sbCheckboxChangeHandler");
const switchEvents = rootEventListener("sb:switch-change", "__sbSwitchChangeHandler");
const textareaEvents = rootEventListener("sb:textarea-change", "__sbTextareaChangeHandler", true);
const inputEvents = rootEventListener("sb:input-change", "__sbInputChangeHandler", true);
const radioGroupEvents = rootEventListener("sb:radio-group-change", "__sbRadioGroupChangeHandler");
const sliderEvents = rootEventListener("sb:slider-change", "__sbSliderChangeHandler");
const dialogEvents = rootEventListener("sb:dialog-change", "__sbDialogChangeHandler");
const popoverEvents = rootEventListener("sb:popover-change", "__sbPopoverChangeHandler");

const BINDING_CONFIGS = [
  {
    component: "button",
    type: "shinyblocks.button",
    receiveProp: "__sbButtonReceive",
    getValue(el) {
      if (typeof el.__sbButtonClickCount === "undefined") el.__sbButtonClickCount = 0;
      return el.__sbButtonClickCount;
    },
    setValue(el, value) {
      el.__sbButtonClickCount = Number(value) || 0;
    },
    subscribe(el, callback) {
      const handler = (event) => {
        const button = event.target && event.target.closest
          ? event.target.closest("[data-slot='button']")
          : null;
        if (!button || !el.contains(button)) return;
        if (button.disabled) return;
        if (typeof el.__sbButtonClickCount === "undefined") el.__sbButtonClickCount = 0;
        el.__sbButtonClickCount += 1;
        callback(false);
      };
      el.addEventListener("click", handler);
      el.__sbButtonClickHandler = handler;
    },
    unsubscribe(el) {
      if (!el.__sbButtonClickHandler) return;
      el.removeEventListener("click", el.__sbButtonClickHandler);
      delete el.__sbButtonClickHandler;
    }
  },
  {
    component: "select",
    requireInputId: false,
    receiveProp: "__sbSelectReceive",
    getValue(el) {
      const native = nativeSelect(el);
      return native ? native.value : null;
    },
    setValue(el, value) {
      setNativeValue(el, value, false);
      if (typeof el.__sbSelectReceive === "function") {
        el.__sbSelectReceive({ selected: value == null ? "" : String(value), notify: false });
      }
    },
    subscribe(el, callback) {
      const native = nativeSelect(el);
      if (!native) return;
      const handler = () => callback(false);
      native.addEventListener("change", handler);
      el.__sbSelectChangeHandler = handler;
    },
    unsubscribe(el) {
      const native = nativeSelect(el);
      if (!native || !el.__sbSelectChangeHandler) return;
      native.removeEventListener("change", el.__sbSelectChangeHandler);
      delete el.__sbSelectChangeHandler;
    },
    receiveMessage(el, data) {
      if (typeof el.__sbSelectReceive === "function") {
        el.__sbSelectReceive(data);
        return;
      }
      // Pre-mount fallback: React hasn't installed its receiver yet, but
      // Shiny is flushing pending input messages — write directly to native.
      if (Object.prototype.hasOwnProperty.call(data, "choices")) {
        setNativeChoices(el, data.choices, data.placeholder, data.selected);
      }
      if (Object.prototype.hasOwnProperty.call(data, "selected")) {
        setNativeValue(el, data.selected, Boolean(data.notify));
      }
    }
  },
  {
    component: "dialog",
    requireInputId: false,
    receiveProp: "__sbDialogReceive",
    getValue(el) { return Boolean(el.__sbDialogValue); },
    setValue(el, value) {
      if (typeof el.__sbDialogReceive === "function") {
        el.__sbDialogReceive({ open: Boolean(value), notify: false });
      }
    },
    ...dialogEvents
  },
  {
    component: "popover",
    receiveProp: "__sbPopoverReceive",
    getValue(el) { return Boolean(el.__sbPopoverValue); },
    setValue(el, value) {
      if (typeof el.__sbPopoverReceive === "function") {
        el.__sbPopoverReceive({ open: Boolean(value), notify: false });
      }
    },
    ...popoverEvents
  },
  {
    component: "checkbox",
    receiveProp: "__sbCheckboxReceive",
    getValue(el) {
      if (typeof el.__sbCheckboxValue !== "undefined") return Boolean(el.__sbCheckboxValue);
      const native = nativeCheckbox(el);
      return native ? native.checked : false;
    },
    setValue(el, value) {
      if (typeof el.__sbCheckboxReceive === "function") {
        el.__sbCheckboxReceive({ checked: Boolean(value), notify: false });
      }
    },
    ...checkboxEvents
  },
  {
    component: "switch",
    receiveProp: "__sbSwitchReceive",
    getValue(el) {
      if (typeof el.__sbSwitchValue !== "undefined") return Boolean(el.__sbSwitchValue);
      const native = nativeSwitch(el);
      return native ? native.checked : false;
    },
    setValue(el, value) {
      if (typeof el.__sbSwitchReceive === "function") {
        el.__sbSwitchReceive({ checked: Boolean(value), notify: false });
      }
    },
    ...switchEvents
  },
  {
    component: "textarea",
    receiveProp: "__sbTextareaReceive",
    getValue(el) {
      if (typeof el.__sbTextareaValue === "string") return el.__sbTextareaValue;
      // React mounts asynchronously; Shiny reports initial input values before
      // the first effect runs, so fall back to the payload's state.value.
      const initial = currentValue(readPayload(el));
      return typeof initial === "string" ? initial : "";
    },
    setValue(el, value) {
      if (typeof el.__sbTextareaReceive === "function") {
        el.__sbTextareaReceive({ value: value == null ? "" : String(value), notify: false });
      }
    },
    ...textareaEvents,
    ratePolicy: { policy: "debounce", delay: 250 }
  },
  {
    component: "input",
    receiveProp: "__sbInputReceive",
    getValue(el) {
      if (typeof el.__sbInputValue === "string") return el.__sbInputValue;
      const initial = currentValue(readPayload(el));
      return typeof initial === "string" ? initial : "";
    },
    setValue(el, value) {
      if (typeof el.__sbInputReceive === "function") {
        el.__sbInputReceive({ value: value == null ? "" : String(value), notify: false });
      }
    },
    ...inputEvents,
    ratePolicy: { policy: "debounce", delay: 250 }
  },
  {
    component: "radio-group",
    receiveProp: "__sbRadioGroupReceive",
    getValue(el) {
      return typeof el.__sbRadioGroupValue === "string" ? el.__sbRadioGroupValue : null;
    },
    setValue(el, value) {
      if (typeof el.__sbRadioGroupReceive === "function") {
        el.__sbRadioGroupReceive({ selected: value == null ? null : String(value), notify: false });
      }
    },
    ...radioGroupEvents
  },
  {
    component: "slider",
    receiveProp: "__sbSliderReceive",
    getValue(el) {
      if (Object.prototype.hasOwnProperty.call(el, "__sbSliderValue")) {
        return el.__sbSliderValue;
      }
      return currentValue(readPayload(el));
    },
    setValue(el, value) {
      if (typeof el.__sbSliderReceive === "function") {
        el.__sbSliderReceive({ value, notify: false });
      }
    },
    ...sliderEvents
  }
];

const BINDING_NAMES = [
  "shinyblocks.button",
  "shinyblocks.select",
  "shinyblocks.dialog",
  "shinyblocks.popover",
  "shinyblocks.checkbox",
  "shinyblocks.switch",
  "shinyblocks.textarea",
  "shinyblocks.input",
  "shinyblocks.radio-group",
  "shinyblocks.slider"
];

let bindingsRegistered = false;

export function registerRuntimeInputBindings() {
  if (bindingsRegistered) return;
  if (!window.Shiny || !window.Shiny.InputBinding || !window.Shiny.inputBindings) return;

  BINDING_NAMES.forEach((name, index) => {
    const BindingClass = makeRuntimeBinding(BINDING_CONFIGS[index]);
    window.Shiny.inputBindings.register(new BindingClass(), name);
  });
  bindingsRegistered = true;
}

export function bindRuntimeInputRoot(root, payload) {
  if (!isRuntimeInputPayload(payload)) return false;
  if (window.Shiny && window.Shiny.bindAll) window.Shiny.bindAll(root);
  return true;
}

export function unbindRuntimeInputRoot(root, payload) {
  if (!isRuntimeInputPayload(payload)) return false;
  if (window.Shiny && window.Shiny.unbindAll) window.Shiny.unbindAll(root);
  return true;
}
