import { useEffect, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot, labelIdForInput } from "../runtime/dom.js";
import { setNativeDatePickerValue } from "../runtime/native-inputs.js";
import {
  floatingTransform,
  useFloatingPosition
} from "../runtime/overlays.js";
import { Calendar, formatLabel, parseIso, todayIso } from "./calendar.jsx";
import { classNames } from "./shared.jsx";

export function DatePicker({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const spriteHref = props.spriteHref || "";

  const [value, setValueState] = useState(
    typeof state.value === "string" ? state.value : ""
  );
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [format, setFormat] = useState(props.format || "yyyy-mm-dd");
  const [min, setMin] = useState(props.min || null);
  const [max, setMax] = useState(props.max || null);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const weekstart = Number.isFinite(Number(props.weekstart)) ? Number(props.weekstart) : 0;

  const [open, setOpenState] = useState(false);
  const initialView = parseIso(value) || parseIso(todayIso());
  const [view, setView] = useState({ y: initialView.y, m: initialView.m - 1 });
  const [focused, setFocused] = useState(value || todayIso());

  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);
  const dayRefs = useRef({});
  const contentId = `${inputId || "date-picker"}-content`;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const position = useFloatingPosition({ open, triggerRef, side: "bottom", align: "start" });

  function isDisabledDay(iso) {
    if (min && iso < min) return true;
    if (max && iso > max) return true;
    return false;
  }

  // Single writer: expando + dataset + hidden native input are written together
  // from the mount effect, the user-action setter, and the receive handler.
  function writeValue(next) {
    if (!root) return;
    root.__sbDatePickerValue = next;
    root.dataset.sbDatePickerValue = next;
    setNativeDatePickerValue(root, next, false);
  }

  function setValue(next, notify) {
    const iso = typeof next === "string" ? next : "";
    setValueState(iso);
    if (!root) return;
    root.__sbDatePickerValue = iso;
    root.dataset.sbDatePickerValue = iso;
    setNativeDatePickerValue(root, iso, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:date-picker-change"));
  }

  function setOpen(next) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
      const anchor = parseIso(value) || parseIso(todayIso());
      setView({ y: anchor.y, m: anchor.m - 1 });
      setFocused(value || todayIso());
    }
    setOpenState(nextOpen);
  }

  function selectDay(iso) {
    if (disabled || isDisabledDay(iso)) return;
    setValue(iso, true);
    setOpen(false);
    requestAnimationFrame(() => triggerRef.current?.focus({ preventScroll: true }));
  }

  // Escape while the grid is focused: close and return focus to the trigger.
  function cancelFromGrid(event) {
    event.stopPropagation();
    setOpen(false);
    requestAnimationFrame(() => triggerRef.current?.focus({ preventScroll: true }));
  }

  // Single-writer: install the expando synchronously on mount and whenever the
  // committed value changes, so `getValue` reads a fresh value pre-bind.
  useEffect(() => {
    writeValue(value);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;
    root.toggleAttribute("data-disabled", disabled);
    const native = root.querySelector("input.sb-date-picker-native");
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDatePickerReceive = (data) => {
      const nextData = data || {};
      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "min")) {
        setMin(nextData.min || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "max")) {
        setMax(nextData.max || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        if (nextDisabled) setOpenState(false);
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
      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        setValue(nextData.value == null ? "" : String(nextData.value), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbDatePickerReceive;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [root]);

  useEffect(() => {
    if (!open) return undefined;

    const focusFrame = requestAnimationFrame(() => {
      const node = dayRefs.current[focused];
      if (node && typeof node.focus === "function") {
        node.focus({ preventScroll: true });
      } else if (contentRef.current) {
        contentRef.current.focus({ preventScroll: true });
      }
    });

    function onPointerDown(event) {
      const target = event.target;
      if (triggerRef.current?.contains(target)) return;
      if (contentRef.current?.contains(target)) return;
      setOpen(false);
    }

    document.addEventListener("pointerdown", onPointerDown);

    return () => {
      cancelAnimationFrame(focusFrame);
      document.removeEventListener("pointerdown", onPointerDown);
      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, focused]);

  // Move keyboard focus to the active day as the user arrows around.
  useEffect(() => {
    if (!open) return;
    const node = dayRefs.current[focused];
    if (node && typeof node.focus === "function") {
      node.focus({ preventScroll: true });
    }
  }, [focused, open]);

  const triggerLabel = value ? formatLabel(value, format) : (placeholder || "Pick a date");
  const portal = ensurePortalRoot();

  // Per-day selection / today markers for the shared calendar grid.
  function dayProps(iso) {
    const selected = iso === value;
    const isToday = iso === todayIso();
    return {
      "data-selected": selected ? "true" : undefined,
      "data-today": isToday ? "true" : undefined,
      "aria-selected": selected ? "true" : "false",
      "aria-current": isToday ? "date" : undefined
    };
  }

  return (
    <div
      className={classNames("sb-date-picker-shell", className)}
      data-slot="date-picker"
      data-disabled={disabled ? "true" : undefined}
      data-invalid={isInvalid ? "true" : undefined}
    >
      <button
        ref={triggerRef}
        type="button"
        className="sb-date-picker-trigger"
        data-slot="date-picker-trigger"
        data-state={open ? "open" : "closed"}
        data-placeholder={!value ? "true" : undefined}
        data-invalid={isInvalid ? "true" : undefined}
        aria-haspopup="dialog"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        aria-invalid={isInvalid || undefined}
        aria-labelledby={labelledBy || undefined}
        aria-describedby={describedBy}
        disabled={disabled}
        style={style}
        onClick={() => setOpen(!open)}
      >
        <svg className="sb-date-picker-icon" aria-hidden="true" focusable="false">
          <use href={`${spriteHref}#sb-icon-calendar`} />
        </svg>
        <span className="sb-date-picker-value">{triggerLabel}</span>
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className="sb-date-picker-content"
            data-slot="date-picker-content"
            role="dialog"
            aria-label="Choose date"
            tabIndex={-1}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: floatingTransform("bottom", "start")
            }}
          >
            <Calendar
              view={view}
              setView={setView}
              weekstart={weekstart}
              spriteHref={spriteHref}
              focused={focused}
              setFocused={setFocused}
              dayRefs={dayRefs}
              isDisabledDay={isDisabledDay}
              onSelect={selectDay}
              onCancel={cancelFromGrid}
              getDayProps={dayProps}
            />
          </div>,
          portal
        )}
    </div>
  );
}
