import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeCheckbox, setNativeCheckboxValue } from "../runtime/native-inputs.js";
import { classNames, HtmlSlot } from "./shared.jsx";

export function Checkbox({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [checked, setCheckedState] = useState(Boolean(state.value));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const controlRef = useRef(null);
  const initialCheckedRef = useRef(checked);
  const invalid = root?.getAttribute("aria-invalid") === "true";
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const inlineLabelId = inputId ? `${inputId}__label` : undefined;

  useEffect(() => {
    if (!root) return undefined;

    setLabelledBy(labelIdForInput(inputId));

    const initialChecked = initialCheckedRef.current;
    root.__sbCheckboxValue = initialChecked;
    root.dataset.sbCheckboxChecked = initialChecked ? "true" : "false";
    setNativeCheckboxValue(root, initialChecked, false);

    root.__sbCheckboxReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "checked")) {
        const nextChecked = Boolean(nextData.checked);
        setCheckedState(nextChecked);
        root.__sbCheckboxValue = nextChecked;
        root.dataset.sbCheckboxChecked = nextChecked ? "true" : "false";
        setNativeCheckboxValue(root, nextChecked, Boolean(nextData.notify));
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:checkbox-change"));
        }
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

  function setChecked(nextChecked, notify = false) {
    const next = Boolean(nextChecked);
    setCheckedState(next);
    if (!root) return;
    root.__sbCheckboxValue = next;
    root.dataset.sbCheckboxChecked = next ? "true" : "false";
    setNativeCheckboxValue(root, next, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:checkbox-change"));
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
