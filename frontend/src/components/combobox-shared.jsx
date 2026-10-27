import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { nativeSelect } from "../runtime/native-inputs.js";
import { moveHighlightIndex, useSelectPopover } from "../runtime/select-popover.js";

export function hasOwn(object, key) {
  return Object.prototype.hasOwnProperty.call(object, key);
}

export function useRuntimeControlProps(payload, root) {
  const props = payload.props || {};
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [searchPlaceholder, setSearchPlaceholder] = useState(props.searchPlaceholder || "Search...");
  const [emptyMessage, setEmptyMessage] = useState(props.emptyMessage || "No results found.");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [style] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");

  const applyCommonMessage = useCallback((nextData, { closeCombobox } = {}) => {
    if (hasOwn(nextData, "placeholder")) {
      setPlaceholder(nextData.placeholder || "");
    }
    if (hasOwn(nextData, "searchPlaceholder")) {
      setSearchPlaceholder(nextData.searchPlaceholder || "Search...");
    }
    if (hasOwn(nextData, "emptyMessage")) {
      setEmptyMessage(nextData.emptyMessage || "No results found.");
    }
    if (hasOwn(nextData, "disabled")) {
      const nextDisabled = Boolean(nextData.disabled);
      setDisabled(nextDisabled);
      root.toggleAttribute("data-disabled", nextDisabled);
      const native = nativeSelect(root);
      if (native) native.disabled = nextDisabled;
      if (nextDisabled) closeCombobox?.();
    }
    if (hasOwn(nextData, "width")) setWidth(nextData.width || "100%");
    if (hasOwn(nextData, "class")) setClassName(nextData.class || "");
    if (hasOwn(nextData, "size")) setSize(nextData.size || "default");
    if (hasOwn(nextData, "invalid")) {
      const nextInvalid = Boolean(nextData.invalid);
      setInvalid(nextInvalid);
      root.toggleAttribute("data-invalid", nextInvalid);
    }
  }, [root]);

  return {
    placeholder,
    searchPlaceholder,
    emptyMessage,
    disabled,
    invalid,
    size,
    width,
    style,
    className,
    applyCommonMessage
  };
}

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

export function useComboboxPopover(choices, size) {
  const [query, setQuery] = useState("");
  const filtered = useMemo(() => filterChoices(choices, query), [choices, query]);
  const popover = useSelectPopover({
    choicesCount: choices.length,
    layoutDeps: [choices, size, query]
  });
  const { open, setOpen, setHighlighted, updatePosition, closePopover } = popover;
  const searchRef = useRef(null);

  const openCombobox = useCallback(() => {
    setQuery("");
    setHighlighted(0);
    setOpen(true);
    updatePosition();
  }, [setHighlighted, setOpen, updatePosition]);

  const closeCombobox = useCallback(({ focus = false } = {}) => {
    closePopover({ focus });
    setQuery("");
  }, [closePopover]);

  useEffect(() => {
    if (open) requestAnimationFrame(() => searchRef.current?.focus());
  }, [open]);

  useEffect(() => {
    if (!open) return;
    setHighlighted(filtered.length ? 0 : -1);
  }, [filtered, open, setHighlighted]);

  const moveHighlight = useCallback((delta) => {
    if (filtered.length === 0) return;
    setHighlighted((current) => (
      moveHighlightIndex(current, delta, filtered.length, 0)
    ));
  }, [filtered.length, setHighlighted]);

  return {
    ...popover,
    query,
    setQuery,
    filtered,
    searchRef,
    openCombobox,
    closeCombobox,
    moveHighlight
  };
}

export function handleSearchNavigation(event, controls) {
  const {
    filtered,
    highlighted,
    setHighlighted,
    moveHighlight,
    closeCombobox,
    onEnter,
    onBackspace
  } = controls;

  if (event.key === "ArrowDown" || event.key === "ArrowUp") {
    event.preventDefault();
    moveHighlight(event.key === "ArrowDown" ? 1 : -1);
    return;
  }
  if (event.key === "Home" || event.key === "End") {
    event.preventDefault();
    setHighlighted(event.key === "Home" ? 0 : Math.max(filtered.length - 1, 0));
    return;
  }
  if (event.key === "Enter") {
    event.preventDefault();
    if (highlighted >= 0 && filtered[highlighted]) onEnter(filtered[highlighted]);
    return;
  }
  if (event.key === "Backspace" && onBackspace) {
    onBackspace(event);
    return;
  }
  if (event.key === "Escape") {
    event.preventDefault();
    closeCombobox({ focus: true });
    return;
  }
  if (event.key === "Tab") closeCombobox();
}

export function ComboboxSearch({
  searchRef,
  spriteHref,
  listId,
  highlightedId,
  searchPlaceholder,
  query,
  setQuery,
  onKeyDown
}) {
  return (
    <div className="sb-combobox-search" data-slot="combobox-search">
      <svg className="sb-combobox-search-icon" aria-hidden="true" focusable="false">
        <use href={`${spriteHref}#sb-icon-search`} />
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
        onKeyDown={onKeyDown}
      />
    </div>
  );
}

export function ComboboxOptions({
  inputId,
  listId,
  choices,
  highlighted,
  setHighlighted,
  emptyMessage,
  spriteHref,
  multiple = false,
  isSelected,
  isDisabled = () => false,
  onSelect
}) {
  if (choices.length === 0) {
    return (
      <div className="sb-combobox-empty" data-slot="combobox-empty" role="presentation">
        {emptyMessage}
      </div>
    );
  }

  return (
    <div
      className="sb-select-viewport"
      data-slot="select-viewport"
      id={listId}
      role="listbox"
      aria-multiselectable={multiple ? "true" : undefined}
    >
      {choices.map((choice, index) => {
        const selected = isSelected(choice.value);
        const rowDisabled = isDisabled(choice.value);
        const indicator = (
          <span className="sb-select-item-indicator" aria-hidden="true">
            <svg aria-hidden="true" focusable="false">
              <use href={`${spriteHref}#sb-icon-check`} />
            </svg>
          </span>
        );
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
              if (!rowDisabled) onSelect(choice.value);
            }}
          >
            {multiple && indicator}
            <span className="sb-select-item-text">{choice.label}</span>
            {!multiple && indicator}
          </div>
        );
      })}
    </div>
  );
}

export function ComboboxPopover({
  portal,
  contentRef,
  contentId,
  position,
  multiple = false,
  children
}) {
  if (!portal) return null;
  return createPortal(
    <div
      ref={contentRef}
      className="sb-select-content sb-combobox-content"
      data-slot="select-content"
      data-state="open"
      data-multiple={multiple ? "true" : undefined}
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
      {children}
    </div>,
    portal
  );
}
