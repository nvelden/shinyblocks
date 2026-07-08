import { currentValue, readPayload } from "./dom.js";
import {
  getNativeMultiValue,
  nativeSelect,
  setNativeChoices,
  setNativeMultiChoices,
  setNativeMultiValue,
  setNativeValue,
  toSingleSelected
} from "./native-inputs.js";

// Coerce a `setValue`/`receiveMessage` `selected` into a string array for
// multiple mode. Mirrors `toMultiSelected` in `multi-select-view.jsx`: empty
// strings are dropped because multiple mode has no placeholder row.
function toMultiSelectedArray(value) {
  if (value == null) return [];
  const arr = Array.isArray(value) ? value : [value];
  return arr.map((item) => String(item)).filter((item) => item.length > 0);
}

const RUNTIME_INPUT_COMPONENTS = new Set([
  "button",
  "task-button",
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
  "toaster",
  "toggle-group",
  "date-picker",
  "date-range-picker",
  "progress"
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
    getType(el) { return typeof type === "function" ? type(el) : type; }
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
      if (typeof handler === "function") {
        handler(data || {});
        return;
      }
      // The component installs `el[receiveProp]` from a React mount effect, which
      // runs a frame or two after the element is inserted and bound. If Shiny
      // delivers a `sendInputMessage` in that window (e.g. an update fired in the
      // same flush that inserted dynamic UI), the handler is not ready yet. Queue
      // the message and drain it in order once the handler appears, instead of
      // silently dropping it. Bounded so a never-mounting element cannot leak a
      // timer or an unbounded queue.
      const queue = el.__sbReceiveQueue || (el.__sbReceiveQueue = []);
      queue.push(data || {});
      if (el.__sbReceiveDraining) return;
      el.__sbReceiveDraining = true;
      let tries = 0;
      const drain = () => {
        const ready = el[receiveProp];
        if (typeof ready === "function") {
          el.__sbReceiveDraining = false;
          const pending = el.__sbReceiveQueue || [];
          el.__sbReceiveQueue = [];
          for (const message of pending) ready(message);
          return;
        }
        if (++tries > 120) {
          // ~2s at 16ms: the element never mounted a handler; drop the queue.
          el.__sbReceiveDraining = false;
          el.__sbReceiveQueue = [];
          return;
        }
        setTimeout(drain, 16);
      };
      setTimeout(drain, 16);
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
const toggleGroupEvents = rootEventListener("sb:toggle-group-change", "__sbToggleGroupChangeHandler");
const sliderEvents = rootEventListener("sb:slider-change", "__sbSliderChangeHandler", true);
const dialogEvents = rootEventListener("sb:dialog-change", "__sbDialogChangeHandler");
const popoverEvents = rootEventListener("sb:popover-change", "__sbPopoverChangeHandler");
const toasterEvents = rootEventListener("sb:toaster-change", "__sbToasterChangeHandler");
const datePickerEvents = rootEventListener("sb:date-picker-change", "__sbDatePickerChangeHandler");
const dateRangePickerEvents = rootEventListener("sb:date-range-picker-change", "__sbDateRangePickerChangeHandler");

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
    // Like `button`, the value is a click count classed as a
    // `shinyActionButtonValue` server-side, but the reported value also carries
    // `autoReset` so the typed handler knows whether to schedule a post-flush
    // ready reset. The click handler installs a synchronous DOM lock before
    // React reconciles, so a rapid second click is rejected immediately.
    component: "task-button",
    type: "shinyblocks.task_button",
    receiveProp: "__sbTaskButtonReceive",
    getValue(el) {
      if (typeof el.__sbTaskButtonClickCount === "undefined") el.__sbTaskButtonClickCount = 0;
      // A per-element mount id, generated once. It uniquely identifies this
      // instance so the server can detect when a new instance binds to a reused
      // input id (renderUI/removeUI/insertUI churn) and drop any stale manual
      // state — even when the click count is unchanged and would otherwise be
      // deduplicated. It is client-generated (not in the R payload), so it never
      // affects rendered-HTML snapshots.
      if (typeof el.__sbTaskButtonMountId === "undefined") {
        el.__sbTaskButtonMountId =
          `tb-${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 10)}`;
      }
      let autoReset = el.__sbTaskButtonAutoReset;
      if (typeof autoReset === "undefined") {
        const payload = readPayload(el);
        autoReset = Boolean(payload && payload.props && payload.props.autoReset);
      }
      return {
        value: el.__sbTaskButtonClickCount,
        autoReset: Boolean(autoReset),
        mountId: el.__sbTaskButtonMountId
      };
    },
    setValue(el, value) {
      const next = value && typeof value === "object" ? value.value : value;
      el.__sbTaskButtonClickCount = Number(next) || 0;
    },
    subscribe(el, callback) {
      const handler = (event) => {
        const button = event.target && event.target.closest
          ? event.target.closest("[data-slot='task-button']")
          : null;
        if (!button || !el.contains(button)) return;
        if (button.disabled || button.getAttribute("data-state") === "busy") return;
        if (typeof el.__sbTaskButtonClickCount === "undefined") el.__sbTaskButtonClickCount = 0;
        el.__sbTaskButtonClickCount += 1;
        // Synchronous lock: React's setState is async, so mutate the real
        // button now to reject a same-tick double click and show busy instantly.
        button.disabled = true;
        button.setAttribute("data-state", "busy");
        button.setAttribute("aria-busy", "true");
        // Reconcile React state (re-applies the lock and busy accessible name).
        if (typeof el.__sbTaskButtonSetState === "function") el.__sbTaskButtonSetState("busy");
        callback(false);
      };
      el.addEventListener("click", handler);
      el.__sbTaskButtonClickHandler = handler;
    },
    unsubscribe(el) {
      if (!el.__sbTaskButtonClickHandler) return;
      el.removeEventListener("click", el.__sbTaskButtonClickHandler);
      delete el.__sbTaskButtonClickHandler;
    }
  },
  {
    component: "select",
    requireInputId: false,
    receiveProp: "__sbSelectReceive",
    getValue(el) {
      const native = nativeSelect(el);
      if (!native) return null;
      // Multiple mode reports a JS array (Shiny → character vector); single
      // mode keeps the scalar `native.value`. The custom view is the single
      // writer that keeps the native options synchronized, so reading native
      // here matches the established select pattern in both modes.
      return native.multiple ? getNativeMultiValue(el) : native.value;
    },
    setValue(el, value) {
      const native = nativeSelect(el);
      if (native && native.multiple) {
        const selected = toMultiSelectedArray(value);
        setNativeMultiValue(el, selected, false);
        if (typeof el.__sbSelectReceive === "function") {
          el.__sbSelectReceive({ selected, notify: false });
        }
        return;
      }
      const single = toSingleSelected(value);
      setNativeValue(el, single, false);
      if (typeof el.__sbSelectReceive === "function") {
        el.__sbSelectReceive({ selected: single, notify: false });
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
      const native = nativeSelect(el);
      const multiple = Boolean(native && native.multiple);
      if (Object.prototype.hasOwnProperty.call(data, "choices")) {
        if (multiple) {
          setNativeMultiChoices(
            el,
            data.choices,
            Object.prototype.hasOwnProperty.call(data, "selected")
              ? toMultiSelectedArray(data.selected)
              : getNativeMultiValue(el)
          );
        } else {
          setNativeChoices(el, data.choices, data.placeholder, data.selected);
        }
      }
      if (Object.prototype.hasOwnProperty.call(data, "selected")) {
        if (multiple) {
          setNativeMultiValue(el, toMultiSelectedArray(data.selected), Boolean(data.notify));
        } else {
          setNativeValue(el, data.selected, Boolean(data.notify));
        }
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
    // Number inputs report through the typed "shinyblocks.number" handler so
    // `input$<id>` is numeric like numericInput(). The type is read from the
    // mount payload because Shiny resolves getType once at bind time — a later
    // `update_block_input(type = ...)` cannot change how the value is decoded.
    type(el) {
      const payload = readPayload(el);
      return payload?.props?.type === "number" ? "shinyblocks.number" : null;
    },
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
    // Single mode reports a string (or null when nothing is pressed);
    // multiple mode reports a JS array (Shiny → character vector). The value
    // shape follows the mount payload's `type`, which is create-only.
    component: "toggle-group",
    receiveProp: "__sbToggleGroupReceive",
    getValue(el) {
      if (Object.prototype.hasOwnProperty.call(el, "__sbToggleGroupValue")) {
        return el.__sbToggleGroupValue;
      }
      return initialValue(el);
    },
    setValue(el, value) {
      if (typeof el.__sbToggleGroupReceive === "function") {
        el.__sbToggleGroupReceive({ selected: value, notify: false });
      }
    },
    ...toggleGroupEvents
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
  },
  {
    // Single-date control. Reports an ISO `yyyy-mm-dd` string typed as
    // `shiny.date`, so the server deserializes `input$<id>` to a length-1
    // `Date` (matching `dateInput()`). An empty selection reports `null`.
    component: "date-picker",
    type: "shiny.date",
    receiveProp: "__sbDatePickerReceive",
    getValue(el) {
      const value = Object.prototype.hasOwnProperty.call(el, "__sbDatePickerValue")
        ? el.__sbDatePickerValue
        : initialValue(el);
      return value ? String(value) : null;
    },
    setValue(el, value) {
      if (typeof el.__sbDatePickerReceive === "function") {
        el.__sbDatePickerReceive({ value: value == null ? "" : String(value), notify: false });
      }
    },
    ...datePickerEvents
  },
  {
    // Range-date control. Reports `[startIso, endIso]` typed `shiny.date`, so
    // the server's `as.Date(unlist(val))` yields a length-2 `Date`
    // `c(start, end)` (matching `dateRangeInput()`). An empty or incomplete
    // range reports `null`.
    component: "date-range-picker",
    type: "shiny.date",
    receiveProp: "__sbDateRangePickerReceive",
    getValue(el) {
      let range;
      if (Object.prototype.hasOwnProperty.call(el, "__sbDateRangePickerValue")) {
        range = el.__sbDateRangePickerValue;
      } else {
        const payload = readPayload(el);
        range = payload && payload.state ? payload.state : {};
      }
      const startIso = range && range.start ? String(range.start) : "";
      const endIso = range && range.end ? String(range.end) : "";
      return startIso && endIso ? [startIso, endIso] : null;
    },
    setValue(el, value) {
      if (typeof el.__sbDateRangePickerReceive === "function") {
        const arr = Array.isArray(value) ? value : [];
        el.__sbDateRangePickerReceive({
          start: arr[0] == null ? "" : String(arr[0]),
          end: arr[1] == null ? "" : String(arr[1]),
          notify: false
        });
      }
    },
    ...dateRangePickerEvents
  },
  {
    // Display-only, receive-only binding. Progress carries no meaningful
    // `input$<id>` value (`getValue` → null); the binding exists purely so
    // `update_block_progress()` / `inc_block_progress()` (`sendInputMessage`,
    // routed by the mount's element id) reach React via `__sbProgressReceive`.
    component: "progress",
    type: "shinyblocks.progress",
    receiveProp: "__sbProgressReceive",
    getValue() { return null; }
  }
];

const BINDING_NAMES = [
  "shinyblocks.button",
  "shinyblocks.task_button",
  "shinyblocks.select",
  "shinyblocks.dialog",
  "shinyblocks.popover",
  "shinyblocks.checkbox",
  "shinyblocks.switch",
  "shinyblocks.textarea",
  "shinyblocks.input",
  "shinyblocks.radio-group",
  "shinyblocks.toggle-group",
  "shinyblocks.slider",
  "shinyblocks.table",
  "shinyblocks.file-input",
  "shinyblocks.toaster",
  "shinyblocks.date-picker",
  "shinyblocks.date-range-picker",
  "shinyblocks.progress"
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
