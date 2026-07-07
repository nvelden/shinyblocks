import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { setNativeToggleGroupValue } from "../runtime/native-inputs.js";
import { classNames, HtmlSlot } from "./shared.jsx";

function toSingleValue(value) {
  if (Array.isArray(value)) value = value[0];
  return value == null ? null : String(value);
}

function toMultipleValue(value) {
  if (value == null) return [];
  const arr = Array.isArray(value) ? value : [value];
  return arr.map((item) => String(item));
}

export function ToggleGroup({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  // `type` is create-only: the binding's value shape (string vs array) is
  // fixed when Shiny binds, so it never changes after mount.
  const type = props.type === "multiple" ? "multiple" : "single";
  const multiple = type === "multiple";
  const initialValue = multiple ? toMultipleValue(state.value) : toSingleValue(state.value);
  const [value, setValueState] = useState(initialValue);
  const [choices, setChoices] = useState(Array.isArray(props.choices) ? props.choices : []);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [disabledValues, setDisabledValues] = useState(
    Array.isArray(props.disabledValues) ? props.disabledValues.map(String) : []
  );
  const [variant, setVariant] = useState(props.variant || "default");
  const [size, setSize] = useState(props.size || "default");
  const [spriteHref, setSpriteHref] = useState(props.spriteHref || "");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [focusedValue, setFocusedValue] = useState(null);
  const iconOnly = Boolean(props.iconOnly);
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const itemRefs = useRef(new Map());

  function writeValue(next) {
    if (!root) return;
    root.__sbToggleGroupValue = next;
    const joined = multiple ? next.join(",") : next == null ? "" : next;
    root.dataset.sbToggleGroupValue = joined;
    setNativeToggleGroupValue(root, joined);
  }

  useEffect(() => {
    if (!root) return undefined;

    writeValue(value);

    root.__sbToggleGroupReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        const nextValue = multiple
          ? toMultipleValue(nextData.selected)
          : toSingleValue(nextData.selected);
        setValueState(nextValue);
        writeValue(nextValue);
        if (nextData.notify) {
          root.dispatchEvent(new CustomEvent("sb:toggle-group-change"));
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "choices")) {
        setChoices(Array.isArray(nextData.choices) ? nextData.choices : []);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        setDisabled(Boolean(nextData.disabled));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabledValues")) {
        setDisabledValues(
          Array.isArray(nextData.disabledValues)
            ? nextData.disabledValues.map(String)
            : []
        );
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "variant")) {
        setVariant(nextData.variant || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "spriteHref")) {
        setSpriteHref(nextData.spriteHref || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbToggleGroupReceive;
    };
  }, [root]);

  function isItemDisabled(choiceValue) {
    return disabled || disabledValues.indexOf(choiceValue) !== -1;
  }

  function isPressed(choiceValue) {
    return multiple ? value.indexOf(choiceValue) !== -1 : value === choiceValue;
  }

  function toggleValue(choiceValue) {
    if (isItemDisabled(choiceValue)) return;
    let next;
    if (multiple) {
      next = isPressed(choiceValue)
        ? value.filter((item) => item !== choiceValue)
        : [...value, choiceValue];
    } else {
      next = isPressed(choiceValue) ? null : choiceValue;
    }
    setValueState(next);
    setFocusedValue(choiceValue);
    if (root) {
      writeValue(next);
      root.dispatchEvent(new CustomEvent("sb:toggle-group-change"));
    }
  }

  const enabledValues = choices
    .map((choice) => String(choice.value))
    .filter((choiceValue) => !isItemDisabled(choiceValue));
  // Roving tabindex: exactly one item is tabbable — the last focused item
  // when it is still enabled, otherwise the first pressed item, otherwise
  // the first enabled item.
  let tabStopValue = null;
  if (focusedValue != null && enabledValues.indexOf(focusedValue) !== -1) {
    tabStopValue = focusedValue;
  } else {
    tabStopValue =
      enabledValues.find((choiceValue) => isPressed(choiceValue)) ??
      enabledValues[0] ??
      null;
  }

  function handleKeyDown(event, currentValue) {
    if (enabledValues.length === 0) return;
    const idx = enabledValues.indexOf(currentValue);
    if (idx < 0) return;
    let nextIdx = null;

    if (event.key === "ArrowRight" || event.key === "ArrowDown") {
      nextIdx = (idx + 1) % enabledValues.length;
    } else if (event.key === "ArrowLeft" || event.key === "ArrowUp") {
      nextIdx = (idx - 1 + enabledValues.length) % enabledValues.length;
    } else if (event.key === "Home") {
      nextIdx = 0;
    } else if (event.key === "End") {
      nextIdx = enabledValues.length - 1;
    }

    if (nextIdx == null) return;
    event.preventDefault();
    const nextValue = enabledValues[nextIdx];
    setFocusedValue(nextValue);
    const node = itemRefs.current.get(nextValue);
    if (node) node.focus();
  }

  return (
    <div
      role="group"
      aria-labelledby={labelledBy || undefined}
      aria-disabled={disabled || undefined}
      data-type={type}
      data-variant={variant}
      data-size={size}
      data-disabled={disabled ? "true" : undefined}
      className={classNames("sb-toggle-group-control", className)}
      style={style}
    >
      {choices.map((choice) => {
        const choiceValue = String(choice.value);
        const pressed = isPressed(choiceValue);
        const itemDisabled = isItemDisabled(choiceValue);
        const label = choice.label == null ? choiceValue : String(choice.label);
        const iconNode = choice.iconHtml ? (
          <HtmlSlot html={choice.iconHtml} className="sb-toggle-group-icon" aria-hidden="true" />
        ) : choice.icon ? (
          <svg aria-hidden="true" focusable="false" className="sb-toggle-group-icon">
            <use href={`${spriteHref}#sb-icon-${choice.icon}`} />
          </svg>
        ) : null;
        return (
          <button
            key={choiceValue}
            ref={(node) => {
              if (node) itemRefs.current.set(choiceValue, node);
              else itemRefs.current.delete(choiceValue);
            }}
            type="button"
            role={multiple ? undefined : "radio"}
            aria-checked={multiple ? undefined : pressed ? "true" : "false"}
            aria-pressed={multiple ? (pressed ? "true" : "false") : undefined}
            aria-label={iconOnly ? label : undefined}
            className="sb-toggle-group-item"
            data-state={pressed ? "on" : "off"}
            data-variant={variant}
            data-size={size}
            data-disabled={itemDisabled ? "true" : undefined}
            tabIndex={choiceValue === tabStopValue ? 0 : -1}
            disabled={itemDisabled}
            onClick={() => toggleValue(choiceValue)}
            onFocus={() => setFocusedValue(choiceValue)}
            onKeyDown={(event) => handleKeyDown(event, choiceValue)}
          >
            {iconNode}
            {!iconOnly && <span className="sb-toggle-group-label">{label}</span>}
          </button>
        );
      })}
    </div>
  );
}
