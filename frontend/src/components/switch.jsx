import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeSwitch, setNativeSwitchValue } from "../runtime/native-inputs.js";
import { classNames, HtmlSlot } from "./shared.jsx";

export function Switch({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [checked, setCheckedState] = useState(Boolean(state.value));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [size, setSize] = useState(props.size || "default");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const controlRef = useRef(null);
  const invalid = root?.getAttribute("aria-invalid") === "true";
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const inlineLabelId = inputId ? `${inputId}__label` : undefined;

  useEffect(() => {
    if (!root) return undefined;

    setLabelledBy(labelIdForInput(inputId));

    root.__sbSwitchValue = checked;
    root.dataset.sbSwitchChecked = checked ? "true" : "false";
    setNativeSwitchValue(root, checked, false);

    root.__sbSwitchReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "checked")) {
        const nextChecked = Boolean(nextData.checked);
        setCheckedState(nextChecked);
        root.__sbSwitchValue = nextChecked;
        root.dataset.sbSwitchChecked = nextChecked ? "true" : "false";
        setNativeSwitchValue(root, nextChecked, Boolean(nextData.notify));
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:switch-change"));
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSwitch(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
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

  function setChecked(nextChecked, notify = false) {
    const next = Boolean(nextChecked);
    setCheckedState(next);
    if (!root) return;
    root.__sbSwitchValue = next;
    root.dataset.sbSwitchChecked = next ? "true" : "false";
    setNativeSwitchValue(root, next, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:switch-change"));
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
      data-size={size === "default" ? undefined : size}
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
