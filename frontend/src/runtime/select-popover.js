import { useCallback, useEffect, useLayoutEffect, useRef, useState } from "react";

// Shared popover positioning/keyboard plumbing for the single- and multi-select
// views. Extracted from `select.jsx` verbatim so single-select behavior stays
// byte-for-byte identical; the multi-select view consumes the same hook so chip
// and listbox positioning track the single-select rules (side flip, 384px cap,
// viewport clamp) without a second copy.

const GAP = 4;
const VIEWPORT_PADDING = 8;
const MAX_CONTENT_HEIGHT = 384;
const ESTIMATED_ITEM_HEIGHT = 32;

// Natural (unclipped) height of the open popover, used to choose a side and cap
// the box. Falls back to a per-item estimate before the first paint; once the
// content is mounted we measure it so taller items (e.g. the `luma` style
// profile's roomier spacing) don't get clipped by `overflow: hidden`.
export function measuredContentHeight(content) {
  if (!content) return null;
  const viewport = content.querySelector('[data-slot="select-viewport"]');
  if (!viewport) return null;
  const cs = window.getComputedStyle(content);
  const padY = parseFloat(cs.paddingTop || "0") + parseFloat(cs.paddingBottom || "0");
  const borderY =
    parseFloat(cs.borderTopWidth || "0") + parseFloat(cs.borderBottomWidth || "0");
  return viewport.scrollHeight + padY + borderY;
}

export function computeSelectPosition(trigger, contentHeight, choicesCount) {
  if (!trigger) return null;

  const rect = trigger.getBoundingClientRect();
  const viewportWidth = window.innerWidth || document.documentElement.clientWidth || 0;
  const viewportHeight = window.innerHeight || document.documentElement.clientHeight || 0;
  const naturalHeight = contentHeight != null
    ? contentHeight
    : Math.max(choicesCount * ESTIMATED_ITEM_HEIGHT + 16, ESTIMATED_ITEM_HEIGHT + 16);
  // `desiredHeight` is the natural content height, clamped only by the hard
  // 384px cap. It drives the side (top/bottom) decision but must NOT be the
  // box's maxHeight: pinning the border-box to the exact measured height leaves
  // the scrolling viewport a fraction short (scrollHeight is integer rounded),
  // so `overflow-y: auto` paints a scrollbar that isn't needed.
  const desiredHeight = Math.min(naturalHeight, MAX_CONTENT_HEIGHT);
  const availableBelow = Math.max(0, viewportHeight - rect.bottom - GAP - VIEWPORT_PADDING);
  const availableAbove = Math.max(0, rect.top - GAP - VIEWPORT_PADDING);
  const side = availableBelow < desiredHeight && availableAbove > availableBelow
    ? "top"
    : "bottom";
  const availableHeight = side === "top" ? availableAbove : availableBelow;
  const minWidth = rect.width;
  const left = viewportWidth > 0
    ? Math.min(
      Math.max(VIEWPORT_PADDING, rect.left),
      Math.max(VIEWPORT_PADDING, viewportWidth - minWidth - VIEWPORT_PADDING)
    )
    : rect.left;

  return {
    side,
    top: side === "top" ? rect.top - GAP : rect.bottom + GAP,
    left,
    minWidth,
    // Cap to the space actually available (never below the 384px ceiling). The
    // flex column shrinks to its content when shorter than this cap, so a
    // scrollbar only appears when the content truly overflows the viewport.
    maxHeight: Math.max(1, Math.min(MAX_CONTENT_HEIGHT, availableHeight))
  };
}

// Wrapping highlight movement. `fallbackIndex` seeds the cursor when nothing is
// highlighted yet (single-select uses the active value's row).
export function moveHighlightIndex(current, delta, count, fallbackIndex) {
  if (count === 0) return current;
  const base = current < 0 ? fallbackIndex : current;
  return (base + delta + count) % count;
}

export function useSelectPopover({ choicesCount, layoutDeps = [] }) {
  const [open, setOpenState] = useState(false);
  const [highlighted, setHighlightedState] = useState(-1);
  const [position, setPosition] = useState(null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const choicesCountRef = useRef(choicesCount);

  useEffect(() => {
    choicesCountRef.current = choicesCount;
  }, [choicesCount]);

  const setOpen = useCallback((next) => setOpenState(next), []);
  const setHighlighted = useCallback((next) => setHighlightedState(next), []);

  const updatePosition = useCallback((contentHeight) => {
    const next = computeSelectPosition(triggerRef.current, contentHeight, choicesCountRef.current);
    if (next) setPosition(next);
  }, []);

  const closePopover = useCallback(({ focus = false } = {}) => {
    setOpen(false);
    setHighlighted(-1);
    setPosition(null);
    if (focus) {
      requestAnimationFrame(() => triggerRef.current?.focus());
    }
  }, [setHighlighted, setOpen]);

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
      closePopover();
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
  }, [closePopover, open, updatePosition]);

  // Once the popover is painted, reposition using its real height so the side
  // choice and clamp track the active style profile's item spacing instead of a
  // fixed estimate. Re-runs when the choices or size change the content box.
  useLayoutEffect(() => {
    if (!open) return;
    const height = measuredContentHeight(contentRef.current);
    if (height != null) updatePosition(height);
    // `layoutDeps` is an explicit list of values that can change the measured
    // content box; spreading it is the hook's public contract.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open, ...layoutDeps]);

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

  return {
    open,
    setOpen,
    highlighted,
    setHighlighted,
    position,
    triggerRef,
    contentRef,
    updatePosition,
    closePopover
  };
}
