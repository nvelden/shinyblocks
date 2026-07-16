import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import { installNativeFocusForwarding, nativeSelect, setNativeChoices, setNativeValue, toSingleSelected } from "../runtime/native-inputs.js";
import { moveHighlightIndex, useSelectPopover } from "../runtime/select-popover.js";
import { MultiSelectView } from "./multi-select-view.jsx";
import { classNames } from "./shared.jsx";

// One runtime identity (`component = "select"`), two implementations. Multiple
// mode delegates to `MultiSelectView`; the binding and `update_block_select()`
// routing stay shared. Hooks must run unconditionally, so the branch lives in
// this wrapper and each view owns its own hook calls.
export function Select({ payload, root }) {
  if ((payload.props || {}).multiple) {
    return <MultiSelectView payload={payload} root={root} />;
  }
  return <SingleSelectView payload={payload} root={root} />;
}

function SingleSelectView({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [choices, setChoices] = useState(props.choices || []);
  const [value, setValue] = useState(state.value ?? "");
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [style] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const {
    open,
    setOpen,
    highlighted,
    setHighlighted,
    position,
    triggerRef,
    contentRef,
    updatePosition,
    closePopover
  } = useSelectPopover({ choicesCount: choices.length, layoutDeps: [choices, size] });
  const valueRef = useRef(value);
  const choicesRef = useRef(choices);
  const placeholderRef = useRef(placeholder);

  useEffect(() => {
    valueRef.current = value;
  }, [value]);

  useEffect(() => {
    choicesRef.current = choices;
  }, [choices]);

  useEffect(() => {
    placeholderRef.current = placeholder;
  }, [placeholder]);

  function selectedIndex() {
    return choicesRef.current.findIndex((choice) => choice.value === valueRef.current);
  }

  function openSelect() {
    if (disabled) return;

    const index = selectedIndex();
    setHighlighted(index >= 0 ? index : 0);
    setOpen(true);
    updatePosition();
  }

  function closeSelect({ focus = false } = {}) {
    closePopover({ focus });
  }

  function commit(nextValue) {
    if (disabled) return;

    const next = nextValue == null ? "" : String(nextValue);
    setValue(next);
    setNativeValue(root, next, true);
    closeSelect({ focus: true });
  }

  function labelForCurrentValue() {
    if (!value) return placeholder || "";
    const choice = choices.find((item) => item.value === value);
    return choice ? choice.label : "";
  }

  useEffect(() => {
    if (!root) return undefined;

    installNativeFocusForwarding(root);
    setLabelledBy(labelIdForInput(inputId));

    root.__sbSelectReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        const nextPlaceholder = nextData.placeholder || "";
        placeholderRef.current = nextPlaceholder;
        setPlaceholder(nextPlaceholder);
        setNativeChoices(root, choicesRef.current, nextPlaceholder, valueRef.current);
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "choices")) {
        const nextChoices = nextData.choices || [];
        choicesRef.current = nextChoices;
        setChoices(nextChoices);
        setOpen(false);
        setHighlighted(-1);
        setNativeChoices(
          root,
          nextChoices,
          Object.prototype.hasOwnProperty.call(nextData, "placeholder")
            ? nextData.placeholder
            : placeholderRef.current,
          Object.prototype.hasOwnProperty.call(nextData, "selected")
            ? nextData.selected
            : valueRef.current
        );
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        // A vector `selected` (legal in multiple mode) reaching a single select
        // collapses to its first element rather than stringifying to "a,b".
        const next = toSingleSelected(nextData.selected);
        valueRef.current = next;
        setValue(next);
        setNativeValue(root, next, Boolean(nextData.notify));
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSelect(root);
        if (native) native.disabled = nextDisabled;
        if (nextDisabled) closeSelect();
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "width")) {
        setWidth(nextData.width || "100%");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        const nextInvalid = Boolean(nextData.invalid);
        setInvalid(nextInvalid);
        root.toggleAttribute("data-invalid", nextInvalid);
      }
    };

    return () => {
      delete root.__sbSelectReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    setNativeChoices(root, choices, placeholder, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, placeholder, root, value]);

  function moveHighlight(delta) {
    if (choices.length === 0) return;
    setHighlighted((current) =>
      moveHighlightIndex(current, delta, choices.length, selectedIndex())
    );
  }

  function onTriggerKeyDown(event) {
    if (disabled) return;

    if (event.key === "ArrowDown") {
      event.preventDefault();
      if (!open) openSelect();
      else moveHighlight(1);
      return;
    }
    if (event.key === "ArrowUp") {
      event.preventDefault();
      if (!open) openSelect();
      else moveHighlight(-1);
      return;
    }
    if (event.key === "Home") {
      event.preventDefault();
      if (!open) openSelect();
      setHighlighted(0);
      return;
    }
    if (event.key === "End") {
      event.preventDefault();
      if (!open) openSelect();
      setHighlighted(Math.max(choices.length - 1, 0));
      return;
    }
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      if (!open) {
        openSelect();
      } else if (highlighted >= 0 && choices[highlighted]) {
        commit(choices[highlighted].value);
      }
      return;
    }
    if (event.key === "Escape" && open) {
      event.preventDefault();
      closeSelect({ focus: true });
      return;
    }
    if (event.key === "Tab" && open) {
      closeSelect();
    }
  }

  const contentId = `${inputId}-content`;
  const highlightedId = highlighted >= 0 ? `${inputId}-item-${highlighted}` : undefined;
  const triggerLabel = labelForCurrentValue();
  const portal = open ? ensurePortalRoot(root) : null;

  return (
    <div
      data-slot="select"
      data-size={size}
      className={classNames("sb-select", className)}
      style={{ width }}
      data-disabled={disabled ? "true" : undefined}
      data-invalid={invalid ? "true" : undefined}
    >
      <button
        ref={triggerRef}
        id={`${inputId}-trigger`}
        type="button"
        className={classNames("sb-select-trigger", `sb-select-size-${size}`)}
        data-slot="select-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={!value ? "true" : undefined}
        data-size={size}
        data-invalid={invalid ? "true" : undefined}
        role="combobox"
        aria-haspopup="listbox"
        aria-expanded={open ? "true" : "false"}
        aria-controls={contentId}
        // Focus stays on the trigger while the listbox is portaled, so
        // `aria-activedescendant` must live here (the focused combobox) for AT
        // to announce the highlighted option.
        aria-activedescendant={open ? highlightedId : undefined}
        aria-invalid={invalid || undefined}
        aria-labelledby={labelledBy || undefined}
        style={style}
        disabled={disabled}
        onClick={() => {
          if (open) closeSelect();
          else openSelect();
        }}
        onKeyDown={onTriggerKeyDown}
      >
        <span className="sb-select-trigger-value">{triggerLabel}</span>
        <svg className="sb-select-trigger-icon" aria-hidden="true" focusable="false">
          <use href={`${props.spriteHref}#sb-icon-chevron-down`} />
        </svg>
      </button>
      {open && portal && createPortal(
        <div
          ref={contentRef}
          className="sb-select-content"
          data-slot="select-content"
          data-state="open"
          id={contentId}
          role="listbox"
          style={position ? {
            position: "fixed",
            top: `${position.top}px`,
            left: `${position.left}px`,
            minWidth: `${position.minWidth}px`,
            maxHeight: `${position.maxHeight}px`,
            transform: position.side === "top" ? "translateY(-100%)" : undefined
          } : undefined}
          data-side={position?.side}
        >
          <div className="sb-select-viewport" data-slot="select-viewport">
            {choices.map((choice, index) => {
              const selected = choice.value === value;
              return (
                <div
                  key={choice.value}
                  id={`${inputId}-item-${index}`}
                  className="sb-select-item"
                  data-slot="select-item"
                  data-sb-index={index}
                  data-highlighted={highlighted === index ? "true" : undefined}
                  data-state={selected ? "checked" : "unchecked"}
                  role="option"
                  aria-selected={selected ? "true" : "false"}
                  onMouseEnter={() => setHighlighted(index)}
                  onMouseDown={(event) => event.preventDefault()}
                  onClick={() => commit(choice.value)}
                >
                  <span className="sb-select-item-text">{choice.label}</span>
                  <span className="sb-select-item-indicator" aria-hidden="true">
                    <svg aria-hidden="true" focusable="false">
                      <use href={`${props.spriteHref}#sb-icon-check`} />
                    </svg>
                  </span>
                </div>
              );
            })}
          </div>
        </div>,
        portal
      )}
    </div>
  );
}
