import { useEffect, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeInput, setNativeInputValue } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

function finiteOrNull(raw) {
  if (raw == null || raw === "") return null;
  const parsed = Number(raw);
  return Number.isFinite(parsed) ? parsed : null;
}

function positiveOrNull(raw) {
  const parsed = finiteOrNull(raw);
  return parsed != null && parsed > 0 ? parsed : null;
}

function decimalsOf(number) {
  const text = String(number);
  const fraction = text.split(".")[1];
  return fraction ? fraction.length : 0;
}

export function Input({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = typeof state.value === "string" ? state.value : "";
  const [value, setValueState] = useState(initialValue);
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [type, setType] = useState(props.type || "text");
  const [min, setMin] = useState(finiteOrNull(props.min));
  const [max, setMax] = useState(finiteOrNull(props.max));
  const [step, setStep] = useState(positiveOrNull(props.step));
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
      if (Object.prototype.hasOwnProperty.call(nextData, "min")) {
        setMin(finiteOrNull(nextData.min));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "max")) {
        setMax(finiteOrNull(nextData.max));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "step")) {
        setStep(positiveOrNull(nextData.step));
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

  function commitValue(next) {
    setValueState(next);
    if (root) {
      root.__sbInputValue = next;
      root.dataset.sbInputValue = next;
      setNativeInputValue(root, next, true);
      root.dispatchEvent(new CustomEvent("sb:input-change"));
    }
  }

  function handleChange(event) {
    commitValue(event.target.value);
  }

  const isNumber = type === "number";
  const currentNumber = finiteOrNull(value);

  function stepBy(direction) {
    if (disabled) return;
    const usableStep = step == null ? 1 : step;
    let next;
    if (currentNumber == null) {
      // Empty field: step lands on a bound when one exists, else on 0,
      // matching native <input type="number"> stepUp/stepDown behavior.
      next = direction > 0 ? (min != null ? min : 0) : (max != null ? max : 0);
    } else {
      next = currentNumber + direction * usableStep;
    }
    if (min != null) next = Math.max(min, next);
    if (max != null) next = Math.min(max, next);
    const precision = Math.max(
      decimalsOf(usableStep),
      currentNumber == null ? 0 : decimalsOf(currentNumber)
    );
    commitValue(String(Number(next.toFixed(precision))));
  }

  const atMin = currentNumber != null && min != null && currentNumber <= min;
  const atMax = currentNumber != null && max != null && currentNumber >= max;

  const control = (
    <input
      className={classNames("sb-input-control", className)}
      data-slot="input-control"
      type={type}
      value={value}
      placeholder={placeholder || undefined}
      min={isNumber && min != null ? min : undefined}
      max={isNumber && max != null ? max : undefined}
      step={isNumber && step != null ? step : undefined}
      disabled={disabled}
      aria-invalid={isInvalid || undefined}
      aria-labelledby={labelledBy || undefined}
      aria-describedby={describedBy}
      style={style}
      onChange={handleChange}
    />
  );

  if (!isNumber) return control;

  // Stepper buttons stay outside the tab order: the input itself is the
  // spinbutton (arrow keys step natively); the buttons are a pointer affordance.
  return (
    <div className="sb-input-number" data-slot="input-number">
      {control}
      <div className="sb-input-stepper" data-slot="input-stepper">
        <button
          type="button"
          className="sb-input-stepper-btn"
          data-slot="input-stepper-up"
          aria-label="Increase value"
          tabIndex={-1}
          disabled={disabled || atMax}
          onClick={() => stepBy(1)}
        >
          <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="m18 15-6-6-6 6" />
          </svg>
        </button>
        <button
          type="button"
          className="sb-input-stepper-btn"
          data-slot="input-stepper-down"
          aria-label="Decrease value"
          tabIndex={-1}
          disabled={disabled || atMin}
          onClick={() => stepBy(-1)}
        >
          <svg aria-hidden="true" focusable="false" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="m6 9 6 6 6-6" />
          </svg>
        </button>
      </div>
    </div>
  );
}
