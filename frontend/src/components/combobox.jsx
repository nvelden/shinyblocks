import { useCallback, useEffect, useRef, useState } from "react";
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
import {
  clampSelected,
  orderSelectedByChoices,
  reconcileMultiSelection,
  toMultiSelected
} from "../runtime/multi-select-state.js";
import { classNames } from "./shared.jsx";
import {
  ComboboxOptions,
  ComboboxPopover,
  ComboboxSearch,
  handleSearchNavigation,
  hasOwn,
  useComboboxPopover,
  useRuntimeControlProps
} from "./combobox-shared.jsx";

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

function ComboboxSingleView({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [choices, setChoices] = useState(props.choices || []);
  const [value, setValue] = useState(state.value ?? "");
  const [labelledBy, setLabelledBy] = useState(null);
  const control = useRuntimeControlProps(payload, root);
  const {
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
  } = control;
  const {
    open,
    setOpen,
    highlighted,
    setHighlighted,
    position,
    triggerRef,
    contentRef,
    query,
    setQuery,
    filtered,
    searchRef,
    openCombobox,
    closeCombobox,
    moveHighlight
  } = useComboboxPopover(choices, size);
  const valueRef = useRef(value);
  const choicesRef = useRef(choices);
  const placeholderRef = useRef(placeholder);

  useEffect(() => { valueRef.current = value; }, [value]);
  useEffect(() => { choicesRef.current = choices; }, [choices]);
  useEffect(() => { placeholderRef.current = placeholder; }, [placeholder]);

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

      if (hasOwn(nextData, "placeholder")) {
        const nextPlaceholder = nextData.placeholder || "";
        placeholderRef.current = nextPlaceholder;
        setNativeChoices(root, choicesRef.current, nextPlaceholder, valueRef.current);
      }

      if (hasOwn(nextData, "choices")) {
        const nextChoices = nextData.choices || [];
        choicesRef.current = nextChoices;
        setChoices(nextChoices);
        setOpen(false);
        setHighlighted(-1);
        setNativeChoices(
          root,
          nextChoices,
          hasOwn(nextData, "placeholder")
            ? nextData.placeholder
            : placeholderRef.current,
          hasOwn(nextData, "selected")
            ? nextData.selected
            : valueRef.current
        );
      }

      if (hasOwn(nextData, "selected")) {
        const next = toSingleSelected(nextData.selected);
        valueRef.current = next;
        setValue(next);
        setNativeValue(root, next, Boolean(nextData.notify));
      }

      applyCommonMessage(nextData, { closeCombobox });
    };

    return () => {
      delete root.__sbComboboxReceive;
    };
  }, [applyCommonMessage, closeCombobox, inputId, root, setHighlighted, setOpen]);

  useEffect(() => {
    if (!root) return;
    setNativeChoices(root, choices, placeholder, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, placeholder, root, value]);

  function onSearchKeyDown(event) {
    handleSearchNavigation(event, {
      filtered,
      highlighted,
      setHighlighted,
      moveHighlight,
      closeCombobox,
      onEnter: (choice) => commit(choice.value)
    });
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
  const portal = open ? ensurePortalRoot(root) : null;

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
      {open && (
        <ComboboxPopover
          portal={portal}
          contentRef={contentRef}
          contentId={contentId}
          position={position}
        >
          <ComboboxSearch
            searchRef={searchRef}
            spriteHref={props.spriteHref}
            listId={listId}
            highlightedId={highlightedId}
            searchPlaceholder={searchPlaceholder}
            query={query}
            setQuery={setQuery}
            onKeyDown={onSearchKeyDown}
          />
          <ComboboxOptions
            inputId={inputId}
            listId={listId}
            choices={filtered}
            highlighted={highlighted}
            setHighlighted={setHighlighted}
            emptyMessage={emptyMessage}
            spriteHref={props.spriteHref}
            isSelected={(choiceValue) => choiceValue === value}
            onSelect={commit}
          />
        </ComboboxPopover>
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
    const ordered = orderSelectedByChoices(props.choices || [], state.value);
    const cap = props.maxItems == null ? null : Number(props.maxItems);
    return clampSelected(ordered, cap);
  });
  const [maxItems, setMaxItems] = useState(props.maxItems == null ? null : Number(props.maxItems));
  const [labelledBy, setLabelledBy] = useState(null);
  const control = useRuntimeControlProps(payload, root);
  const {
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
  } = control;
  const {
    open,
    setOpen,
    highlighted,
    setHighlighted,
    position,
    triggerRef,
    contentRef,
    query,
    setQuery,
    filtered,
    searchRef,
    openCombobox,
    closeCombobox,
    moveHighlight
  } = useComboboxPopover(choices, size);
  const valueRef = useRef(value);
  const choicesRef = useRef(choices);
  const maxItemsRef = useRef(maxItems);

  useEffect(() => { valueRef.current = value; }, [value]);
  useEffect(() => { choicesRef.current = choices; }, [choices]);
  useEffect(() => { maxItemsRef.current = maxItems; }, [maxItems]);

  const atCap = maxItems != null && value.length >= maxItems;

  function orderByChoices(set) {
    return orderSelectedByChoices(choicesRef.current, set);
  }

  function clampToCap(ordered) {
    const cap = maxItemsRef.current;
    return clampSelected(ordered, cap);
  }

  const applyValue = useCallback((next, notify) => {
    valueRef.current = next;
    setValue(next);
    setNativeMultiValue(root, next, notify);
  }, [root]);

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

      if (hasOwn(nextData, "maxItems")) {
        const nextMax = nextData.maxItems == null ? null : Number(nextData.maxItems);
        maxItemsRef.current = nextMax;
        setMaxItems(nextMax);
      }

      if (hasOwn(nextData, "choices")) {
        const nextChoices = nextData.choices || [];
        choicesRef.current = nextChoices;
        setChoices(nextChoices);
        setOpen(false);
        setHighlighted(-1);
        const prior = valueRef.current;
        const carried = hasOwn(nextData, "selected")
          ? toMultiSelected(nextData.selected)
          : prior;
        const next = reconcileMultiSelection(nextChoices, carried, maxItemsRef.current);
        valueRef.current = next;
        setValue(next);
        setNativeMultiChoices(root, nextChoices, next);
        const changed =
          next.length !== prior.length || next.some((v, i) => v !== prior[i]);
        const shouldNotify = hasOwn(nextData, "selected")
          ? Boolean(nextData.notify)
          : changed;
        if (shouldNotify) {
          const native = nativeSelect(root);
          if (native) native.dispatchEvent(new Event("change", { bubbles: true }));
        }
      } else if (hasOwn(nextData, "selected")) {
        const requested = new Set(toMultiSelected(nextData.selected));
        const next = clampToCap(orderByChoices(requested));
        applyValue(next, Boolean(nextData.notify));
      }

      applyCommonMessage(nextData, { closeCombobox });
    };

    return () => {
      delete root.__sbComboboxReceive;
    };
  }, [applyCommonMessage, applyValue, closeCombobox, inputId, root, setHighlighted, setOpen]);

  useEffect(() => {
    if (!root) return;
    setNativeMultiChoices(root, choices, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, root, value]);

  function onSearchKeyDown(event) {
    handleSearchNavigation(event, {
      filtered,
      highlighted,
      setHighlighted,
      moveHighlight,
      closeCombobox,
      onEnter: (choice) => {
        if (!isRowDisabled(choice.value)) toggleValue(choice.value);
      },
      onBackspace: (backspaceEvent) => {
        if (query.length !== 0) return;
        backspaceEvent.preventDefault();
        removeLast();
      }
    });
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
  const portal = open ? ensurePortalRoot(root) : null;

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
      {open && (
        <ComboboxPopover
          portal={portal}
          contentRef={contentRef}
          contentId={contentId}
          position={position}
          multiple
        >
          <ComboboxSearch
            searchRef={searchRef}
            spriteHref={props.spriteHref}
            listId={listId}
            highlightedId={highlightedId}
            searchPlaceholder={searchPlaceholder}
            query={query}
            setQuery={setQuery}
            onKeyDown={onSearchKeyDown}
          />
          <ComboboxOptions
            inputId={inputId}
            listId={listId}
            choices={filtered}
            highlighted={highlighted}
            setHighlighted={setHighlighted}
            emptyMessage={emptyMessage}
            spriteHref={props.spriteHref}
            multiple
            isSelected={(choiceValue) => value.includes(choiceValue)}
            isDisabled={(choiceValue) => !value.includes(choiceValue) && atCap}
            onSelect={toggleValue}
          />
        </ComboboxPopover>
      )}
    </div>
  );
}
