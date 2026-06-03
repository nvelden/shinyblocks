import { useEffect, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeInput, setNativeInputValue } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

export function Input({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = typeof state.value === "string" ? state.value : "";
  const [value, setValueState] = useState(initialValue);
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [type, setType] = useState(props.type || "text");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;

  useEffect(() => {
    if (!root) return undefined;

    root.__sbInputValue = value;
    root.dataset.sbInputValue = value;
    setNativeInputValue(root, value, false);

    root.__sbInputReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        const nextValue = nextData.value == null ? "" : String(nextData.value);
        setValueState(nextValue);
        root.__sbInputValue = nextValue;
        root.dataset.sbInputValue = nextValue;
        setNativeInputValue(root, nextValue, Boolean(nextData.notify));
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:input-change"));
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder == null ? "" : String(nextData.placeholder));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "type")) {
        setType(nextData.type || "text");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeInput(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        setInvalid(Boolean(nextData.invalid));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbInputReceive;
    };
  }, [inputId, root]);

  function handleChange(event) {
    const next = event.target.value;
    setValueState(next);
    if (root) {
      root.__sbInputValue = next;
      root.dataset.sbInputValue = next;
      setNativeInputValue(root, next, true);
      root.dispatchEvent(new CustomEvent("sb:input-change"));
    }
  }

  return (
    <input
      className={classNames("sb-input-control", className)}
      data-slot="input-control"
      type={type}
      value={value}
      placeholder={placeholder || undefined}
      disabled={disabled}
      aria-invalid={isInvalid || undefined}
      aria-labelledby={labelledBy || undefined}
      aria-describedby={describedBy}
      style={style}
      onChange={handleChange}
    />
  );
}
