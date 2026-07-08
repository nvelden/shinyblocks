import { useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import {
  installNativeFocusForwarding,
  nativeSelect,
  setNativeChoices,
  setNativeMultiChoices,
  setNativeMultiValue,
  setNativeValue,
  toSingleSelected
} from "../runtime/native-inputs.js";
import { moveHighlightIndex, useSelectPopover } from "../runtime/select-popover.js";
import { classNames } from "./shared.jsx";

// One runtime identity (`component = "combobox"`), two implementations. The
// combobox is a searchable [block_select()]: same hidden `<select>` value
// bridge and portal popup, but the popup's first row is a type-to-filter search
// box. Multiple mode renders removable chips like the multi-select. Hooks must
// run unconditionally, so the mode branch lives in this wrapper and each view
// owns its own hook calls.
export function Combobox({ payload, root }) {
  if ((payload.props || {}).multiple) {
    return <ComboboxMultiView payload={payload} root={root} />;
  }
  return <ComboboxSingleView payload={payload} root={root} />;
}

// Case-insensitive substring filter over choice labels (falling back to value).
function filterChoices(choices, query) {
  const needle = query.trim().toLowerCase();
  if (!needle) return choices;
  return choices.filter((choice) => {
    const label = String(choice.label == null ? choice.value : choice.label);
    return (
      label.toLowerCase().includes(needle) ||
      String(choice.value).toLowerCase().includes(needle)
    );
  });
}

function toMultiSelected(selected) {
  if (selected == null) return [];
  const arr = Array.isArray(selected) ? selected : [selected];
  return arr.map((value) => String(value)).filter((value) => value.length > 0);
}

function ComboboxSingleView({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [choices, setChoices] = useState(props.choices || []);
  const [value, setValue] = useState(state.value ?? "");
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [searchPlaceholder, setSearchPlaceholder] = useState(props.searchPlaceholder || "Search...");
  const [emptyMessage, setEmptyMessage] = useState(props.emptyMessage || "No results found.");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const [query, setQuery] = useState("");
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
  } = useSelectPopover({ choicesCount: choices.length, layoutDeps: [choices, size, query] });
  const searchRef = useRef(null);
  const valueRef = useRef(value);
  const choicesRef = useRef(choices);
  const placeholderRef = useRef(placeholder);

  useEffect(() => { valueRef.current = value; }, [value]);
  useEffect(() => { choicesRef.current = choices; }, [choices]);
  useEffect(() => { placeholderRef.current = placeholder; }, [placeholder]);

  const filtered = useMemo(() => filterChoices(choices, query), [choices, query]);

  function openCombobox() {
    if (disabled) return;
    setQuery("");
    setHighlighted(0);
    setOpen(true);
    updatePosition();
  }

  function closeCombobox({ focus = false } = {}) {
    closePopover({ focus });
    setQuery("");
  }

  function commit(nextValue) {
    if (disabled) return;
    const next = nextValue == null ? "" : String(nextValue);
    setValue(next);
    setNativeValue(root, next, true);
    closeCombobox({ focus: true });
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

    root.__sbComboboxReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        const nextPlaceholder = nextData.placeholder || "";
        placeholderRef.current = nextPlaceholder;
        setPlaceholder(nextPlaceholder);
        setNativeChoices(root, choicesRef.current, nextPlaceholder, valueRef.current);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "searchPlaceholder")) {
        setSearchPlaceholder(nextData.searchPlaceholder || "Search...");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "emptyMessage")) {
        setEmptyMessage(nextData.emptyMessage || "No results found.");
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
        if (nextDisabled) closeCombobox();
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
      delete root.__sbComboboxReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    setNativeChoices(root, choices, placeholder, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, placeholder, root, value]);

  // Focus the filter box whenever the popover opens so typing filters at once.
  useEffect(() => {
    if (open) requestAnimationFrame(() => searchRef.current?.focus());
  }, [open]);

  // Keep the highlight in range as the filtered list shrinks/grows.
  useEffect(() => {
    if (!open) return;
    setHighlighted(filtered.length ? 0 : -1);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query]);

  function moveHighlight(delta) {
    if (filtered.length === 0) return;
    setHighlighted((current) => moveHighlightIndex(current, delta, filtered.length, 0));
  }

  function onSearchKeyDown(event) {
    if (event.key === "ArrowDown") {
      event.preventDefault();
      moveHighlight(1);
      return;
    }
    if (event.key === "ArrowUp") {
      event.preventDefault();
      moveHighlight(-1);
      return;
    }
    if (event.key === "Home") {
      event.preventDefault();
      setHighlighted(0);
      return;
    }
    if (event.key === "End") {
      event.preventDefault();
      setHighlighted(Math.max(filtered.length - 1, 0));
      return;
    }
    if (event.key === "Enter") {
      event.preventDefault();
      if (highlighted >= 0 && filtered[highlighted]) commit(filtered[highlighted].value);
      return;
    }
    if (event.key === "Escape") {
      event.preventDefault();
      closeCombobox({ focus: true });
      return;
    }
    if (event.key === "Tab") {
      closeCombobox();
    }
  }

  function onTriggerKeyDown(event) {
    if (disabled) return;
    if (event.key === "ArrowDown" || event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      openCombobox();
    }
  }

  const contentId = `${inputId}-content`;
  const listId = `${inputId}-listbox`;
  const highlightedId = highlighted >= 0 ? `${inputId}-item-${highlighted}` : undefined;
  const triggerLabel = labelForCurrentValue();
  const portal = open ? ensurePortalRoot() : null;

  return (
    <div
      data-slot="combobox"
      data-size={size}
      className={classNames("sb-select", "sb-combobox", className)}
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
        aria-haspopup="listbox"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        aria-invalid={invalid || undefined}
        aria-labelledby={labelledBy || undefined}
        style={style}
        disabled={disabled}
        onClick={() => {
          if (open) closeCombobox();
          else openCombobox();
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
          className="sb-select-content sb-combobox-content"
          data-slot="select-content"
          data-state="open"
          id={contentId}
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
          <div className="sb-combobox-search" data-slot="combobox-search">
            <svg className="sb-combobox-search-icon" aria-hidden="true" focusable="false">
              <use href={`${props.spriteHref}#sb-icon-search`} />
            </svg>
            <input
              ref={searchRef}
              type="text"
              className="sb-combobox-input"
              role="combobox"
              aria-expanded="true"
              aria-controls={listId}
              aria-activedescendant={highlightedId}
              aria-autocomplete="list"
              autoComplete="off"
              spellCheck={false}
              placeholder={searchPlaceholder}
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              onKeyDown={onSearchKeyDown}
            />
          </div>
          {filtered.length === 0 ? (
            <div className="sb-combobox-empty" data-slot="combobox-empty" role="presentation">
              {emptyMessage}
            </div>
          ) : (
            <div
              className="sb-select-viewport"
              data-slot="select-viewport"
              id={listId}
              role="listbox"
            >
              {filtered.map((choice, index) => {
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
          )}
        </div>,
        portal
      )}
    </div>
  );
}

function ComboboxMultiView({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [choices, setChoices] = useState(props.choices || []);
  const [value, setValue] = useState(() => {
    const wanted = new Set(toMultiSelected(state.value));
    const ordered = (props.choices || [])
      .map((choice) => choice.value)
      .filter((choiceValue) => wanted.has(choiceValue));
    const cap = props.maxItems == null ? null : Number(props.maxItems);
    return cap != null && ordered.length > cap ? ordered.slice(0, cap) : ordered;
  });
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [searchPlaceholder, setSearchPlaceholder] = useState(props.searchPlaceholder || "Search...");
  const [emptyMessage, setEmptyMessage] = useState(props.emptyMessage || "No results found.");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [style] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [maxItems, setMaxItems] = useState(props.maxItems == null ? null : Number(props.maxItems));
  const [labelledBy, setLabelledBy] = useState(null);
  const [query, setQuery] = useState("");
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
  } = useSelectPopover({ choicesCount: choices.length, layoutDeps: [choices, size, query] });
  const searchRef = useRef(null);
  const valueRef = useRef(value);
  const choicesRef = useRef(choices);
  const maxItemsRef = useRef(maxItems);

  useEffect(() => { valueRef.current = value; }, [value]);
  useEffect(() => { choicesRef.current = choices; }, [choices]);
  useEffect(() => { maxItemsRef.current = maxItems; }, [maxItems]);

  const atCap = maxItems != null && value.length >= maxItems;
  const filtered = useMemo(() => filterChoices(choices, query), [choices, query]);

  function orderByChoices(set) {
    return choicesRef.current
      .map((choice) => choice.value)
      .filter((choiceValue) => set.has(choiceValue));
  }

  function clampToCap(ordered) {
    const cap = maxItemsRef.current;
    return cap != null && ordered.length > cap ? ordered.slice(0, cap) : ordered;
  }

  function applyValue(next, notify) {
    valueRef.current = next;
    setValue(next);
    setNativeMultiValue(root, next, notify);
  }

  function toggleValue(choiceValue) {
    if (disabled) return;
    const set = new Set(valueRef.current);
    if (set.has(choiceValue)) {
      set.delete(choiceValue);
    } else {
      if (maxItemsRef.current != null && set.size >= maxItemsRef.current) return;
      set.add(choiceValue);
    }
    applyValue(orderByChoices(set), true);
  }

  function removeValue(choiceValue) {
    if (disabled) return;
    const set = new Set(valueRef.current);
    if (!set.has(choiceValue)) return;
    set.delete(choiceValue);
    applyValue(orderByChoices(set), true);
  }

  function removeLast() {
    if (disabled) return;
    const current = valueRef.current;
    if (current.length === 0) return;
    removeValue(current[current.length - 1]);
  }

  function openCombobox() {
    if (disabled) return;
    setQuery("");
    setHighlighted(0);
    setOpen(true);
    updatePosition();
  }

  function closeCombobox({ focus = false } = {}) {
    closePopover({ focus });
    setQuery("");
  }

  function isRowDisabled(choiceValue) {
    if (disabled) return true;
    if (maxItemsRef.current == null) return false;
    if (valueRef.current.includes(choiceValue)) return false;
    return valueRef.current.length >= maxItemsRef.current;
  }

  useEffect(() => {
    if (!root) return undefined;

    installNativeFocusForwarding(root);
    setLabelledBy(labelIdForInput(inputId));

    root.__sbComboboxReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "searchPlaceholder")) {
        setSearchPlaceholder(nextData.searchPlaceholder || "Search...");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "emptyMessage")) {
        setEmptyMessage(nextData.emptyMessage || "No results found.");
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "maxItems")) {
        const nextMax = nextData.maxItems == null ? null : Number(nextData.maxItems);
        maxItemsRef.current = nextMax;
        setMaxItems(nextMax);
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "choices")) {
        const nextChoices = nextData.choices || [];
        choicesRef.current = nextChoices;
        setChoices(nextChoices);
        setOpen(false);
        setHighlighted(-1);
        const prior = valueRef.current;
        const carried = Object.prototype.hasOwnProperty.call(nextData, "selected")
          ? toMultiSelected(nextData.selected)
          : prior;
        const allowed = new Set(nextChoices.map((choice) => String(choice.value)));
        const next = clampToCap(
          nextChoices
            .map((choice) => choice.value)
            .filter((choiceValue) => carried.includes(choiceValue) && allowed.has(choiceValue))
        );
        valueRef.current = next;
        setValue(next);
        setNativeMultiChoices(root, nextChoices, next);
        const changed =
          next.length !== prior.length || next.some((v, i) => v !== prior[i]);
        const shouldNotify = Object.prototype.hasOwnProperty.call(nextData, "selected")
          ? Boolean(nextData.notify)
          : changed;
        if (shouldNotify) {
          const native = nativeSelect(root);
          if (native) native.dispatchEvent(new Event("change", { bubbles: true }));
        }
      } else if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        const requested = new Set(toMultiSelected(nextData.selected));
        const next = clampToCap(orderByChoices(requested));
        applyValue(next, Boolean(nextData.notify));
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSelect(root);
        if (native) native.disabled = nextDisabled;
        if (nextDisabled) closeCombobox();
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
      delete root.__sbComboboxReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    setNativeMultiChoices(root, choices, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, root, value]);

  useEffect(() => {
    if (open) requestAnimationFrame(() => searchRef.current?.focus());
  }, [open]);

  useEffect(() => {
    if (!open) return;
    setHighlighted(filtered.length ? 0 : -1);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [query]);

  function moveHighlight(delta) {
    if (filtered.length === 0) return;
    setHighlighted((current) => moveHighlightIndex(current, delta, filtered.length, 0));
  }

  function onSearchKeyDown(event) {
    if (event.key === "ArrowDown") {
      event.preventDefault();
      moveHighlight(1);
      return;
    }
    if (event.key === "ArrowUp") {
      event.preventDefault();
      moveHighlight(-1);
      return;
    }
    if (event.key === "Home") {
      event.preventDefault();
      setHighlighted(0);
      return;
    }
    if (event.key === "End") {
      event.preventDefault();
      setHighlighted(Math.max(filtered.length - 1, 0));
      return;
    }
    if (event.key === "Enter") {
      event.preventDefault();
      if (highlighted >= 0 && filtered[highlighted]) {
        const choiceValue = filtered[highlighted].value;
        if (!isRowDisabled(choiceValue)) toggleValue(choiceValue);
      }
      return;
    }
    if (event.key === "Backspace" && query.length === 0) {
      event.preventDefault();
      removeLast();
      return;
    }
    if (event.key === "Escape") {
      event.preventDefault();
      closeCombobox({ focus: true });
      return;
    }
    if (event.key === "Tab") {
      closeCombobox();
    }
  }

  function onTriggerKeyDown(event) {
    if (disabled) return;
    if (event.key === "ArrowDown" || event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      openCombobox();
      return;
    }
    if (event.key === "Backspace" && event.target === triggerRef.current) {
      event.preventDefault();
      removeLast();
    }
  }

  const contentId = `${inputId}-content`;
  const listId = `${inputId}-listbox`;
  const highlightedId = highlighted >= 0 ? `${inputId}-item-${highlighted}` : undefined;
  const selectedChoices = choices.filter((choice) => value.includes(choice.value));
  const showPlaceholder = selectedChoices.length === 0;
  const portal = open ? ensurePortalRoot() : null;

  return (
    <div
      data-slot="combobox"
      data-size={size}
      data-multiple="true"
      className={classNames("sb-select", "sb-combobox", className)}
      style={{ width }}
      data-disabled={disabled ? "true" : undefined}
      data-invalid={invalid ? "true" : undefined}
    >
      <div
        ref={triggerRef}
        id={`${inputId}-trigger`}
        className={classNames("sb-select-trigger", "sb-select-trigger-multi", `sb-select-size-${size}`)}
        data-slot="select-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={showPlaceholder ? "true" : undefined}
        data-size={size}
        data-invalid={invalid ? "true" : undefined}
        role="combobox"
        tabIndex={disabled ? -1 : 0}
        aria-haspopup="listbox"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        aria-disabled={disabled ? "true" : undefined}
        aria-invalid={invalid || undefined}
        aria-labelledby={labelledBy || undefined}
        style={style}
        onClick={() => {
          if (disabled) return;
          if (open) closeCombobox();
          else openCombobox();
        }}
        onKeyDown={onTriggerKeyDown}
      >
        <span className="sb-select-chips" data-slot="select-chips">
          {showPlaceholder ? (
            <span className="sb-select-trigger-value" data-placeholder="true">
              {placeholder}
            </span>
          ) : (
            selectedChoices.map((choice) => (
              <span key={choice.value} className="sb-select-chip" data-slot="select-chip">
                <span className="sb-select-chip-label">{choice.label}</span>
                <button
                  type="button"
                  className="sb-select-chip-remove"
                  data-slot="select-chip-remove"
                  tabIndex={-1}
                  aria-label={`Remove ${choice.label}`}
                  disabled={disabled}
                  onPointerDown={(event) => event.stopPropagation()}
                  onClick={(event) => {
                    event.stopPropagation();
                    removeValue(choice.value);
                  }}
                >
                  <svg aria-hidden="true" focusable="false">
                    <use href={`${props.spriteHref}#sb-icon-x`} />
                  </svg>
                </button>
              </span>
            ))
          )}
        </span>
        <svg className="sb-select-trigger-icon" aria-hidden="true" focusable="false">
          <use href={`${props.spriteHref}#sb-icon-chevron-down`} />
        </svg>
      </div>
      {open && portal && createPortal(
        <div
          ref={contentRef}
          className="sb-select-content sb-combobox-content"
          data-slot="select-content"
          data-state="open"
          data-multiple="true"
          id={contentId}
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
          <div className="sb-combobox-search" data-slot="combobox-search">
            <svg className="sb-combobox-search-icon" aria-hidden="true" focusable="false">
              <use href={`${props.spriteHref}#sb-icon-search`} />
            </svg>
            <input
              ref={searchRef}
              type="text"
              className="sb-combobox-input"
              role="combobox"
              aria-expanded="true"
              aria-controls={listId}
              aria-activedescendant={highlightedId}
              aria-autocomplete="list"
              autoComplete="off"
              spellCheck={false}
              placeholder={searchPlaceholder}
              value={query}
              onChange={(event) => setQuery(event.target.value)}
              onKeyDown={onSearchKeyDown}
            />
          </div>
          {filtered.length === 0 ? (
            <div className="sb-combobox-empty" data-slot="combobox-empty" role="presentation">
              {emptyMessage}
            </div>
          ) : (
            <div
              className="sb-select-viewport"
              data-slot="select-viewport"
              id={listId}
              role="listbox"
              aria-multiselectable="true"
            >
              {filtered.map((choice, index) => {
                const selected = value.includes(choice.value);
                const rowDisabled = !selected && atCap;
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
                    aria-disabled={rowDisabled ? "true" : undefined}
                    onMouseEnter={() => setHighlighted(index)}
                    onMouseDown={(event) => event.preventDefault()}
                    onClick={() => {
                      if (!rowDisabled) toggleValue(choice.value);
                    }}
                  >
                    <span className="sb-select-item-indicator" aria-hidden="true">
                      <svg aria-hidden="true" focusable="false">
                        <use href={`${props.spriteHref}#sb-icon-check`} />
                      </svg>
                    </span>
                    <span className="sb-select-item-text">{choice.label}</span>
                  </div>
                );
              })}
            </div>
          )}
        </div>,
        portal
      )}
    </div>
  );
}
