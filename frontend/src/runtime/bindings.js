import { currentValue, readPayload } from "./dom.js";
import {
  nativeSelect,
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
  "file-input",
  "radio-group",
  "slider",
  "table",
  "toaster"
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
    getId = null,
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
    getId(el) { return getId ? getId(el) : el.dataset.sbInputId; }
    getType() { return type; }
    getValue(el) { return getValue ? getValue(el) : null; }
    setValue(el, value) { if (setValue) setValue(el, value); }
    subscribe(el, callback) { if (subscribe) subscribe(el, callback); }
    unsubscribe(el) { if (unsubscribe) unsubscribe(el); }
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

// Bindings prefer the value the React component just produced (held on a DOM
// expando). React commits asynchronously, but `Shiny.bindAll` may call
// `getValue` before the mount effect runs, so every binding falls back to the
// payload's initial `state.value` via `readPayload(el)`. After #24 the mount
// effect installs the expando synchronously, so this fallback covers the
// pre-mount window only.
function initialValue(el) {
  return currentValue(readPayload(el));
}

const checkboxEvents = rootEventListener("sb:checkbox-change", "__sbCheckboxChangeHandler");
const switchEvents = rootEventListener("sb:switch-change", "__sbSwitchChangeHandler");
const textareaEvents = rootEventListener("sb:textarea-change", "__sbTextareaChangeHandler", true);
const inputEvents = rootEventListener("sb:input-change", "__sbInputChangeHandler", true);
const radioGroupEvents = rootEventListener("sb:radio-group-change", "__sbRadioGroupChangeHandler");
const sliderEvents = rootEventListener("sb:slider-change", "__sbSliderChangeHandler", true);
const dialogEvents = rootEventListener("sb:dialog-change", "__sbDialogChangeHandler");
const popoverEvents = rootEventListener("sb:popover-change", "__sbPopoverChangeHandler");
const toasterEvents = rootEventListener("sb:toaster-change", "__sbToasterChangeHandler");

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
    getValue(el) {
      return Boolean(el.__sbDialogValue ?? initialValue(el));
    },
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
    getValue(el) {
      return Boolean(el.__sbPopoverValue ?? initialValue(el));
    },
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
      return Boolean(el.__sbCheckboxValue ?? initialValue(el));
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
      return Boolean(el.__sbSwitchValue ?? initialValue(el));
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
      const initial = initialValue(el);
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
      const initial = initialValue(el);
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
      if (typeof el.__sbRadioGroupValue === "string") return el.__sbRadioGroupValue;
      const initial = initialValue(el);
      return initial == null ? null : String(initial);
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
      return initialValue(el);
    },
    setValue(el, value) {
      if (typeof el.__sbSliderReceive === "function") {
        el.__sbSliderReceive({ value, notify: false });
      }
    },
    ...sliderEvents,
    ratePolicy: { policy: "throttle", delay: 100 }
  },
  {
    // The table is receive-only until `selection` is enabled. Registering an
    // InputBinding is how Shiny routes `update_block_table()` messages
    // (`sendInputMessage`) to this mount by its DOM id; `receiveMessage`
    // forwards the fresh payload to React via the `__sbTableReceive` expando.
    // When rows are selectable the mount also installs `__sbTableValue` and
    // dispatches `sb:table-change`, so the binding reports the selection.
    //
    // `getValue` mirrors DT: the bare `input$<id>` is the selected row indices
    // (null when non-selectable, preserving legacy behavior). `subscribe` also
    // publishes the DT-compatible derived inputs `<id>_rows_selected`,
    // `<id>_row_last_clicked`, and `<id>_cell_clicked`.
    component: "table",
    receiveProp: "__sbTableReceive",
    getValue(el) {
      const value = el.__sbTableValue;
      return value ? value.selected : null;
    },
    subscribe(el, callback) {
      const handler = () => {
        callback(false);
        const id = el.dataset.sbInputId;
        const value = el.__sbTableValue;
        if (!id || !value || !window.Shiny || !window.Shiny.setInputValue) return;
        window.Shiny.setInputValue(`${id}_rows_selected`, value.selected);
        if (value.lastClicked != null) {
          window.Shiny.setInputValue(`${id}_row_last_clicked`, value.lastClicked, {
            priority: "event"
          });
        }
        if (value.cell) {
          window.Shiny.setInputValue(`${id}_cell_clicked`, value.cell, {
            priority: "event"
          });
        }
      };
      el.addEventListener("sb:table-change", handler);
      el.__sbTableChangeHandler = handler;
    },
    unsubscribe(el) {
      if (!el.__sbTableChangeHandler) return;
      el.removeEventListener("sb:table-change", el.__sbTableChangeHandler);
      delete el.__sbTableChangeHandler;
    }
  },
  {
    // Receive-only binding. The uploaded file value belongs to Shiny's native
    // file binding (`input$<id>`), so this mount reports nothing — it exists
    // purely so `update_block_file_input()` (`sendInputMessage`) reaches React
    // via `__sbFileInputReceive`. Routing is by DOM id, so `getId` returns the
    // mount's deterministic `el.id` rather than a (absent) `data-sb-input-id`.
    component: "file-input",
    requireInputId: false,
    receiveProp: "__sbFileInputReceive",
    getId(el) { return el.id; },
    getValue() { return null; }
  },
  {
    // Server-driven broadcast region. `show_toast()` / `dismiss_toast()`
    // (`sendInputMessage`) reach React via `__sbToasterReceive`; the mount
    // reports the last shown/dismissed toast id as `input$<id>` and dispatches
    // `sb:toaster-change` when that value changes.
    component: "toaster",
    receiveProp: "__sbToasterReceive",
    getValue(el) {
      return el.__sbToasterValue == null ? null : el.__sbToasterValue;
    },
    ...toasterEvents
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
  "shinyblocks.slider",
  "shinyblocks.table",
  "shinyblocks.file-input",
  "shinyblocks.toaster"
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
