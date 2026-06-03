import { useEffect, useLayoutEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import { installNativeFocusForwarding, nativeSelect, setNativeChoices, setNativeValue } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

export function Select({ payload, root }) {
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
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [open, setOpen] = useState(false);
  const [highlighted, setHighlighted] = useState(-1);
  const [labelledBy, setLabelledBy] = useState(null);
  const [position, setPosition] = useState(null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
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

  // Natural (unclipped) height of the open popover, used to choose a side and
  // cap the box. Falls back to a per-item estimate before the first paint;
  // once the content is mounted we measure it so taller items (e.g. the `luma`
  // style profile's roomier spacing) don't get clipped by `overflow: hidden`.
  function measuredContentHeight() {
    const content = contentRef.current;
    if (!content) return null;
    const viewport = content.querySelector('[data-slot="select-viewport"]');
    if (!viewport) return null;
    const cs = window.getComputedStyle(content);
    const padY = parseFloat(cs.paddingTop || "0") + parseFloat(cs.paddingBottom || "0");
    const borderY =
      parseFloat(cs.borderTopWidth || "0") + parseFloat(cs.borderBottomWidth || "0");
    return viewport.scrollHeight + padY + borderY;
  }

  function updatePosition(contentHeight) {
    const trigger = triggerRef.current;
    if (!trigger) return;

    const rect = trigger.getBoundingClientRect();
    const viewportWidth = window.innerWidth || document.documentElement.clientWidth || 0;
    const viewportHeight = window.innerHeight || document.documentElement.clientHeight || 0;
    const gap = 4;
    const viewportPadding = 8;
    const maxContentHeight = 384;
    const estimatedItemHeight = 32;
    const naturalHeight = contentHeight != null
      ? contentHeight
      : Math.max(choicesRef.current.length * estimatedItemHeight + 16, estimatedItemHeight + 16);
    // `desiredHeight` is the natural content height, clamped only by the hard
    // 384px cap. It drives the side (top/bottom) decision but must NOT be the
    // box's maxHeight: pinning the border-box to the exact measured height
    // leaves the scrolling viewport a fraction short (scrollHeight is integer
    // rounded), so `overflow-y: auto` paints a scrollbar that isn't needed.
    const desiredHeight = Math.min(naturalHeight, maxContentHeight);
    const availableBelow = Math.max(0, viewportHeight - rect.bottom - gap - viewportPadding);
    const availableAbove = Math.max(0, rect.top - gap - viewportPadding);
    const side = availableBelow < desiredHeight && availableAbove > availableBelow
      ? "top"
      : "bottom";
    const availableHeight = side === "top" ? availableAbove : availableBelow;
    const minWidth = rect.width;
    const left = viewportWidth > 0
      ? Math.min(
        Math.max(viewportPadding, rect.left),
        Math.max(viewportPadding, viewportWidth - minWidth - viewportPadding)
      )
      : rect.left;

    setPosition({
      side,
      top: side === "top" ? rect.top - gap : rect.bottom + gap,
      left,
      minWidth,
      // Cap to the space actually available (never below the 384px ceiling).
      // The flex column shrinks to its content when shorter than this cap, so
      // a scrollbar only appears when the content truly overflows the viewport.
      maxHeight: Math.max(1, Math.min(maxContentHeight, availableHeight))
    });
  }

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
    setOpen(false);
    setHighlighted(-1);
    setPosition(null);
    if (focus) {
      requestAnimationFrame(() => triggerRef.current?.focus());
    }
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
        const next = nextData.selected == null ? "" : String(nextData.selected);
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

  useEffect(() => {
    if (!open) return undefined;

    updatePosition();

    const onPointerDown = (event) => {
      const target = event.target;
      if (
        triggerRef.current?.contains(target) ||
        contentRef.current?.contains(target)
      ) {
        return;
      }
      closeSelect();
    };
    const onWindowChange = () => updatePosition();

    document.addEventListener("pointerdown", onPointerDown);
    window.addEventListener("resize", onWindowChange);
    window.addEventListener("scroll", onWindowChange, true);

    return () => {
      document.removeEventListener("pointerdown", onPointerDown);
      window.removeEventListener("resize", onWindowChange);
      window.removeEventListener("scroll", onWindowChange, true);
    };
  }, [open]);

  // Once the popover is painted, reposition using its real height so the side
  // choice and clamp track the active style profile's item spacing instead of
  // a fixed estimate. Re-runs when the choices or size change the content box.
  useLayoutEffect(() => {
    if (!open) return;
    const height = measuredContentHeight();
    if (height != null) updatePosition(height);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, choices, size]);

  useEffect(() => {
    if (!open || highlighted < 0) return;
    const viewport = contentRef.current?.querySelector(
      '[data-slot="select-viewport"]'
    );
    const item = contentRef.current?.querySelector(
      `[data-sb-index="${highlighted}"]`
    );
    if (viewport && item) {
      const containerRect = viewport.getBoundingClientRect();
      const itemRect = item.getBoundingClientRect();
      if (itemRect.top < containerRect.top) {
        viewport.scrollTop -= (containerRect.top - itemRect.top);
      } else if (itemRect.bottom > containerRect.bottom) {
        viewport.scrollTop += (itemRect.bottom - containerRect.bottom);
      }
    }
  }, [highlighted, open]);

  function moveHighlight(delta) {
    if (choices.length === 0) return;
    setHighlighted((current) => {
      const base = current < 0 ? selectedIndex() : current;
      const next = (base + delta + choices.length) % choices.length;
      return next;
    });
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
  const portal = open ? ensurePortalRoot() : null;

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
          aria-activedescendant={highlightedId}
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
