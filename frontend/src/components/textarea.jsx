import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeTextarea, setNativeTextareaValue } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

export function Textarea({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = typeof state.value === "string" ? state.value : "";
  const [value, setValueState] = useState(initialValue);
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [rows, setRows] = useState(Number(props.rows || 3));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [resize, setResize] = useState(props.resize || "vertical");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const textareaRef = useRef(null);
  const initialValueRef = useRef(value);

  useEffect(() => {
    if (!root) return undefined;

    const mountValue = initialValueRef.current;
    root.__sbTextareaValue = mountValue;
    root.dataset.sbTextareaValue = mountValue;
    setNativeTextareaValue(root, mountValue, false);

    root.__sbTextareaReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        const nextValue = nextData.value == null ? "" : String(nextData.value);
        setValueState(nextValue);
        root.__sbTextareaValue = nextValue;
        root.dataset.sbTextareaValue = nextValue;
        setNativeTextareaValue(root, nextValue, Boolean(nextData.notify));
        if (textareaRef.current) textareaRef.current.style.height = "";
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:textarea-change"));
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder == null ? "" : String(nextData.placeholder));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "rows")) {
        const nextRows = Number(nextData.rows);
        if (Number.isFinite(nextRows) && nextRows >= 1) {
          setRows(nextRows);
          if (textareaRef.current) textareaRef.current.style.height = "";
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeTextarea(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        setInvalid(Boolean(nextData.invalid));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "resize")) {
        setResize(nextData.resize || "vertical");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbTextareaReceive;
    };
  }, [inputId, root]);

  function handleChange(event) {
    const next = event.target.value;
    setValueState(next);
    if (root) {
      root.__sbTextareaValue = next;
      root.dataset.sbTextareaValue = next;
      setNativeTextareaValue(root, next, true);
      root.dispatchEvent(new CustomEvent("sb:textarea-change"));
    }
  }

  return (
    <textarea
      ref={textareaRef}
      className={classNames("sb-textarea-control", className)}
      data-slot="textarea-control"
      value={value}
      placeholder={placeholder || undefined}
      rows={rows}
      disabled={disabled}
      aria-invalid={isInvalid || undefined}
      aria-labelledby={labelledBy || undefined}
      aria-describedby={describedBy}
      data-resize={resize}
      style={{ ...style, resize }}
      onChange={handleChange}
    />
  );
}
