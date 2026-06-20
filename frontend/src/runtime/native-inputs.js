export function nativeSelect(root) {
  return root ? root.querySelector(".sb-select-native") : null;
}

export function nativeCheckbox(root) {
  return root ? root.querySelector(".sb-checkbox-native") : null;
}

export function nativeTextarea(root) {
  return root.querySelector("textarea.sb-textarea-native");
}

export function setNativeTextareaValue(root, value, notify) {
  const native = nativeTextarea(root);
  if (!native) return;
  const next = value == null ? "" : String(value);
  if (native.value === next) return;
  native.value = next;
  if (notify) {
    native.dispatchEvent(new Event("input", { bubbles: true }));
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function nativeInput(root) {
  return root.querySelector("input.sb-input-native");
}

export function nativeFileInput(root) {
  return root ? root.querySelector("input.shiny-input-file") : null;
}

export function setNativeInputValue(root, value, notify) {
  const native = nativeInput(root);
  if (!native) return;
  const next = value == null ? "" : String(value);
  if (native.value === next) return;
  native.value = next;
  if (notify) {
    native.dispatchEvent(new Event("input", { bubbles: true }));
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

function nativeRadioGroup(root) {
  return root.querySelector("input.sb-radio-group-native");
}

export function setNativeRadioGroupValue(root, value) {
  const native = nativeRadioGroup(root);
  if (!native) return;
  native.value = value == null ? "" : String(value);
}

export function nativeSlider(root) {
  return root ? root.querySelector("input.sb-slider-native") : null;
}

export function sliderValueToNative(value) {
  if (Array.isArray(value)) return value.join(",");
  return value == null ? "" : String(value);
}

export function normalizeSliderValue(value, min, max) {
  const fallback = Number.isFinite(min) ? min : 0;
  const values = Array.isArray(value) ? value : [value];
  const normalized = values
    .slice(0, 2)
    .map((item) => Number(item))
    .filter((item) => Number.isFinite(item));
  if (!normalized.length) normalized.push(fallback);
  const low = Number.isFinite(min) ? min : Math.min(...normalized);
  const high = Number.isFinite(max) ? max : Math.max(...normalized);
  const clamped = normalized.map((item) => Math.min(high, Math.max(low, item)));
  if (clamped.length === 2 && clamped[0] > clamped[1]) clamped.sort((a, b) => a - b);
  return Array.isArray(value) ? clamped.slice(0, 2) : clamped[0];
}

export function setNativeSliderValue(root, value, notify) {
  const native = nativeSlider(root);
  if (!native) return;
  native.value = sliderValueToNative(value);
  if (notify) {
    native.dispatchEvent(new Event("input", { bubbles: true }));
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function nativeDatePicker(root) {
  return root ? root.querySelector("input.sb-date-picker-native") : null;
}

export function setNativeDatePickerValue(root, value, notify) {
  const native = nativeDatePicker(root);
  if (!native) return;
  const next = value == null ? "" : String(value);
  native.value = next;
  if (notify) {
    native.dispatchEvent(new Event("input", { bubbles: true }));
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function nativeDateRangePicker(root) {
  return root ? root.querySelector("input.sb-date-range-picker-native") : null;
}

// The hidden native input ferries a committed range as `"<startIso>/<endIso>"`
// (delimiter matches `DATE_RANGE_NATIVE_SEP` on the R side). An incomplete range
// writes an empty string so a half-open selection never round-trips.
//
// Intentional forward-compat / SSR scaffolding: the binding's `getValue` reads
// the `__sbDateRangePickerValue` expando, not this input (which carries
// `data-shiny-no-bind-input`), so nothing consumes the slash-encoded value
// today. It is kept as the server-rendered fallback and for parity with the
// other native-backed controls; the `id` also anchors `<label for>`.
export function setNativeDateRangePickerValue(root, start, end, notify) {
  const native = nativeDateRangePicker(root);
  if (!native) return;
  const next = start && end ? `${start}/${end}` : "";
  native.value = next;
  if (notify) {
    native.dispatchEvent(new Event("input", { bubbles: true }));
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function nativeSwitch(root) {
  return root ? root.querySelector(".sb-switch-native") : null;
}

export function setNativeCheckboxValue(root, checked, notify) {
  const native = nativeCheckbox(root);
  if (!native) return;

  native.checked = Boolean(checked);
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function setNativeSwitchValue(root, checked, notify) {
  const native = nativeSwitch(root);
  if (!native) return;

  native.checked = Boolean(checked);
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function setNativeChoices(root, choices, placeholder, selected) {
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

export function setNativeValue(root, value, notify) {
  const native = nativeSelect(root);
  if (!native) return;

  native.value = value == null ? "" : String(value);
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

// Multiple-mode mirror writers. The custom binding owns the Shiny value; these
// keep the hidden `<select multiple>` in sync so `getValue` (which reads the
// native selected options) and the pre-mount fallback agree with React state.
export function getNativeMultiValue(root) {
  const native = nativeSelect(root);
  if (!native) return [];
  return Array.from(native.selectedOptions).map((option) => option.value);
}

export function setNativeMultiValue(root, values, notify) {
  const native = nativeSelect(root);
  if (!native) return;

  const wanted = new Set((values || []).map((value) => String(value)));
  Array.from(native.options).forEach((option) => {
    option.selected = wanted.has(option.value);
  });
  if (notify) {
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }
}

export function setNativeMultiChoices(root, choices, selectedValues) {
  const native = nativeSelect(root);
  if (!native) return;

  native.textContent = "";
  const wanted = new Set((selectedValues || []).map((value) => String(value)));
  (choices || []).forEach((choice) => {
    const option = document.createElement("option");
    option.value = String(choice.value);
    option.textContent = String(choice.label);
    option.selected = wanted.has(option.value);
    native.appendChild(option);
  });
}

function focusSelectTrigger(root) {
  const trigger = root && root.querySelector(".sb-select-trigger");
  if (trigger && !trigger.disabled) {
    trigger.focus();
  }
}

export function installNativeFocusForwarding(root) {
  const native = nativeSelect(root);
  if (!native || native.__sbSelectFocusForwarding) return;

  const handler = () => focusSelectTrigger(root);
  native.addEventListener("focus", handler);
  native.__sbSelectFocusForwarding = handler;
}
