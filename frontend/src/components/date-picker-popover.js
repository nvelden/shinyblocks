import { useEffect, useRef, useState } from "react";

// Shared popover shell for the single- and range-date pickers. Owns the open
// state, the trigger/content/day refs, return-focus capture, the outside-click
// dismiss, the active-day focus tracking, and the disabled -> native input
// mirroring. The pickers keep their own value/selection state and grids; this
// hook is purely the popover plumbing that was byte-identical between them.
//
// Params:
//   root           — the component root element (may be null pre-mount).
//   disabled       — current disabled flag; mirrored onto the root + native.
//   nativeSelector — CSS selector for the hidden native input to disable.
//   focused        — the ISO day that should hold keyboard focus while open.
//   onOpen         — called once per open transition to seed view/focus/draft.
export function useDatePickerPopover({ root, disabled, nativeSelector, focused, onOpen }) {
  const [open, setOpenState] = useState(false);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);
  const dayRefs = useRef({});

  // `onOpen` is read through a ref so the latest closure runs without making it
  // a dependency of every consumer's `setOpen` call site.
  const onOpenRef = useRef(onOpen);
  onOpenRef.current = onOpen;

  function setOpen(next) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
      onOpenRef.current?.();
    }
    setOpenState(nextOpen);
  }

  // Mirror disabled onto the root attribute and the hidden native input.
  useEffect(() => {
    if (!root) return undefined;
    root.toggleAttribute("data-disabled", disabled);
    const native = root.querySelector(nativeSelector);
    if (native) native.disabled = disabled;
    return undefined;
  }, [disabled, root, nativeSelector]);

  // On open: focus the active day (or the dialog), wire outside-click dismiss,
  // and on close return focus to whatever held it before opening.
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
      setOpenState(false);
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
    // Depend on `open` only: arrow-key navigation changes `focused`, and we must
    // not tear this effect down (returning focus to the trigger) while the
    // popover is still open. The separate `[focused, open]` effect below tracks
    // focus to the active day; the initial focus here reads `focused` once on open.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  // Move keyboard focus to the active day as the user arrows around.
  useEffect(() => {
    if (!open) return;
    const node = dayRefs.current[focused];
    if (node && typeof node.focus === "function") {
      node.focus({ preventScroll: true });
    }
  }, [focused, open]);

  return {
    open,
    setOpen,
    setOpenState,
    triggerRef,
    contentRef,
    returnFocusRef,
    dayRefs
  };
}
