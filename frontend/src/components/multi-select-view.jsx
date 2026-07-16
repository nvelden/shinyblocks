import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import {
  installNativeFocusForwarding,
  nativeSelect,
  setNativeMultiChoices,
  setNativeMultiValue
} from "../runtime/native-inputs.js";
import { moveHighlightIndex, useSelectPopover } from "../runtime/select-popover.js";
import {
  clampSelected,
  orderSelectedByChoices,
  reconcileMultiSelection,
  toMultiSelected
} from "../runtime/multi-select-state.js";
import { classNames } from "./shared.jsx";

// Multiple-mode select. The trigger is a `div role="combobox"` (not a button)
// so chip remove `<button>`s are legally nested; the popup is a checkable
// `role="listbox" aria-multiselectable="true"` that stays open on toggle. The
// custom binding owns the Shiny value (a character vector); this view is the
// single writer that mirrors every change into the hidden `<select multiple>`.

// Coerce a received `selected` into a clean string array. Multiple mode has no
// placeholder `""` row, so an empty string is never a real value — drop it so a
// `NULL`/`""` clear and a `character(0)` clear behave identically.
export function MultiSelectView({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [choices, setChoices] = useState(props.choices || []);
  // Normalize the initial selection into choice order (deduped) so chips, the
  // listbox, Backspace-removes-last, and the `max_items` count all agree with
  // the rest of the lifecycle — `state.value` may arrive in any order or with
  // repeats.
  const [value, setValue] = useState(() => {
    const ordered = orderSelectedByChoices(props.choices || [], state.value);
    // R rejects an over-cap initial `selected`, but clamp defensively so the
    // mounted view can never start above the cap.
    const cap = props.maxItems == null ? null : Number(props.maxItems);
    return clampSelected(ordered, cap);
  });
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [style] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [maxItems, setMaxItems] = useState(
    props.maxItems == null ? null : Number(props.maxItems)
  );
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
  const maxItemsRef = useRef(maxItems);

  useEffect(() => {
    valueRef.current = value;
  }, [value]);

  useEffect(() => {
    choicesRef.current = choices;
  }, [choices]);

  useEffect(() => {
    maxItemsRef.current = maxItems;
  }, [maxItems]);

  const atCap = maxItems != null && value.length >= maxItems;

  // Keep the membership in choice order so chips, the listbox, and the native
  // `getValue` (which reads selected options in DOM order) all agree.
  function orderByChoices(set) {
    return orderSelectedByChoices(choicesRef.current, set);
  }

  // Truncate to the active cap, keeping the leading (choice-order) values.
  // Toggling already blocks adds beyond the cap; this guards values that
  // arrive whole (initial mount, choices reconcile, server `selected`).
  function clampToCap(ordered) {
    const cap = maxItemsRef.current;
    return clampSelected(ordered, cap);
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

  function openSelect() {
    if (disabled) return;
    const firstSelected = choices.findIndex((choice) =>
      valueRef.current.includes(choice.value)
    );
    setHighlighted(firstSelected >= 0 ? firstSelected : 0);
    setOpen(true);
    updatePosition();
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

    root.__sbSelectReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder || "");
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
        // Reconcile the selection against the new choices: drop values that no
        // longer exist, preserve choice order. An explicit `selected` in the
        // same message overrides the carried-over membership.
        const prior = valueRef.current;
        const carried = Object.prototype.hasOwnProperty.call(nextData, "selected")
          ? toMultiSelected(nextData.selected)
          : prior;
        const next = reconcileMultiSelection(nextChoices, carried, maxItemsRef.current);
        valueRef.current = next;
        setValue(next);
        setNativeMultiChoices(root, nextChoices, next);
        // Rebuilding the options does not fire a native `change`, so dispatch
        // one ourselves. An explicit `selected` honors its `notify` flag even
        // when the membership is unchanged (matching single-select's
        // `setNativeValue(..., notify)` contract, so re-asserting the same
        // vector with `notify = TRUE` still reaches observers); a choices-only
        // refresh notifies whenever reconciliation changed the membership.
        const changed =
          next.length !== prior.length || next.some((value, i) => value !== prior[i]);
        const shouldNotify = Object.prototype.hasOwnProperty.call(nextData, "selected")
          ? Boolean(nextData.notify)
          : changed;
        if (shouldNotify) {
          const native = nativeSelect(root);
          if (native) native.dispatchEvent(new Event("change", { bubbles: true }));
        }
      } else if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        const requested = new Set(toMultiSelected(nextData.selected));
        // Clamp a server `selected` to the cap so it can never exceed what a
        // user could reach by toggling (R also rejects an over-cap initial
        // `selected`; this guards a `max_items`-aware update path).
        const next = clampToCap(orderByChoices(requested));
        applyValue(next, Boolean(nextData.notify));
      }

      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSelect(root);
        if (native) native.disabled = nextDisabled;
        if (nextDisabled) closePopover();
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

  // Single-writer mount sync: mirror the initial membership and disabled state
  // into the hidden `<select multiple>` so the binding reads a correct value
  // even before the first toggle.
  useEffect(() => {
    if (!root) return;
    setNativeMultiChoices(root, choices, value);
    const native = nativeSelect(root);
    if (native) native.disabled = disabled;
  }, [choices, disabled, root, value]);

  function moveHighlight(delta) {
    if (choices.length === 0) return;
    setHighlighted((current) =>
      moveHighlightIndex(current, delta, choices.length, 0)
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
        const choiceValue = choices[highlighted].value;
        if (!isRowDisabled(choiceValue)) toggleValue(choiceValue);
      }
      return;
    }
    if (event.key === "Backspace") {
      // Only act when the field itself is focused (not a chip remove button),
      // matching the selectize "backspace pops the last chip" affordance.
      if (event.target === triggerRef.current) {
        event.preventDefault();
        removeLast();
      }
      return;
    }
    if (event.key === "Escape" && open) {
      event.preventDefault();
      closePopover({ focus: true });
      return;
    }
    if (event.key === "Tab" && open) {
      closePopover();
    }
  }

  const contentId = `${inputId}-content`;
  const highlightedId = highlighted >= 0 ? `${inputId}-item-${highlighted}` : undefined;
  const selectedChoices = choices.filter((choice) => value.includes(choice.value));
  const showPlaceholder = selectedChoices.length === 0;
  const portal = open ? ensurePortalRoot(root) : null;

  return (
    <div
      data-slot="select"
      data-size={size}
      data-multiple="true"
      className={classNames("sb-select", className)}
      style={{ width }}
      data-disabled={disabled ? "true" : undefined}
      data-invalid={invalid ? "true" : undefined}
    >
      <div
        ref={triggerRef}
        id={`${inputId}-trigger`}
        className={classNames(
          "sb-select-trigger",
          "sb-select-trigger-multi",
          `sb-select-size-${size}`
        )}
        data-slot="select-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={showPlaceholder ? "true" : undefined}
        data-size={size}
        data-invalid={invalid ? "true" : undefined}
        role="combobox"
        tabIndex={disabled ? -1 : 0}
        aria-haspopup="listbox"
        aria-expanded={open ? "true" : "false"}
        aria-controls={contentId}
        // Focus stays on this combobox while the listbox is portaled, so
        // `aria-activedescendant` belongs here (not on the listbox) for AT to
        // announce the highlighted option.
        aria-activedescendant={open ? highlightedId : undefined}
        aria-disabled={disabled ? "true" : undefined}
        aria-invalid={invalid || undefined}
        aria-labelledby={labelledBy || undefined}
        style={style}
        onClick={() => {
          if (disabled) return;
          if (open) closePopover();
          else openSelect();
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
          className="sb-select-content"
          data-slot="select-content"
          data-state="open"
          data-multiple="true"
          id={contentId}
          role="listbox"
          aria-multiselectable="true"
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
        </div>,
        portal
      )}
    </div>
  );
}
