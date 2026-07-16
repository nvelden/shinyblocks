import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { setNativeRadioGroupValue } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

export function RadioGroup({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = state.value == null ? null : String(state.value);
  const [value, setValueState] = useState(initialValue);
  const [choices, setChoices] = useState(Array.isArray(props.choices) ? props.choices : []);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [orientation, setOrientation] = useState(props.orientation || "vertical");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const itemRefs = useRef(new Map());
  const initialValueRef = useRef(value);

  useEffect(() => {
    if (!root) return undefined;

    const mountValue = initialValueRef.current;
    root.__sbRadioGroupValue = mountValue == null ? null : String(mountValue);
    root.dataset.sbRadioGroupValue = mountValue == null ? "" : String(mountValue);
    setNativeRadioGroupValue(root, mountValue);

    root.__sbRadioGroupReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        const nextValue = nextData.selected == null ? null : String(nextData.selected);
        setValueState(nextValue);
        root.__sbRadioGroupValue = nextValue;
        root.dataset.sbRadioGroupValue = nextValue == null ? "" : nextValue;
        setNativeRadioGroupValue(root, nextValue);
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:radio-group-change"));
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "choices")) {
        setChoices(Array.isArray(nextData.choices) ? nextData.choices : []);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        setInvalid(Boolean(nextData.invalid));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "orientation")) {
        setOrientation(nextData.orientation || "vertical");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbRadioGroupReceive;
    };
  }, [inputId, root]);

  function selectValue(nextValue) {
    if (disabled) return;
    const next = nextValue == null ? null : String(nextValue);
    setValueState(next);
    if (root) {
      root.__sbRadioGroupValue = next;
      root.dataset.sbRadioGroupValue = next == null ? "" : next;
      setNativeRadioGroupValue(root, next);
      root.dispatchEvent(new CustomEvent("sb:radio-group-change"));
    }
  }

  function focusItem(itemValue) {
    const node = itemRefs.current.get(itemValue);
    if (node) node.focus();
  }

  function handleKeyDown(event, currentValue) {
    if (disabled || choices.length === 0) return;
    const idx = choices.findIndex((c) => String(c.value) === String(currentValue));
    if (idx < 0) return;
    let nextIdx = null;

    if (event.key === "ArrowDown" || event.key === "ArrowRight") {
      nextIdx = (idx + 1) % choices.length;
    } else if (event.key === "ArrowUp" || event.key === "ArrowLeft") {
      nextIdx = (idx - 1 + choices.length) % choices.length;
    } else if (event.key === " " || event.key === "Enter") {
      event.preventDefault();
      selectValue(currentValue);
      return;
    }

    if (nextIdx == null) return;
    event.preventDefault();
    const nextValue = choices[nextIdx].value;
    selectValue(nextValue);
    focusItem(nextValue);
  }

  return (
    <div
      role="radiogroup"
      aria-labelledby={labelledBy || undefined}
      aria-invalid={isInvalid || undefined}
      aria-disabled={disabled || undefined}
      data-orientation={orientation}
      data-disabled={disabled ? "true" : undefined}
      className={classNames("sb-radio-group-control", className)}
      style={style}
    >
      {choices.map((choice) => {
        const choiceValue = String(choice.value);
        const isChecked = String(value) === choiceValue;
        const itemId = inputId ? `${inputId}__opt_${choiceValue}` : undefined;
        return (
          <label
            key={choiceValue}
            className="sb-radio-group-item"
            data-state={isChecked ? "checked" : "unchecked"}
            data-disabled={disabled ? "true" : undefined}
          >
            <button
              ref={(node) => {
                if (node) itemRefs.current.set(choiceValue, node);
                else itemRefs.current.delete(choiceValue);
              }}
              type="button"
              role="radio"
              id={itemId}
              className="sb-radio-group-button"
              aria-checked={isChecked ? "true" : "false"}
              data-state={isChecked ? "checked" : "unchecked"}
              tabIndex={isChecked || (value == null && choices.indexOf(choice) === 0) ? 0 : -1}
              disabled={disabled}
              onClick={() => selectValue(choiceValue)}
              onKeyDown={(event) => handleKeyDown(event, choiceValue)}
            >
              <span className="sb-radio-group-indicator" aria-hidden="true" />
            </button>
            <span className="sb-radio-group-text">{choice.label}</span>
          </label>
        );
      })}
    </div>
  );
}
