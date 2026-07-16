import { useEffect, useMemo, useRef, useState } from "react";
import { createPortal } from "react-dom";
import { ensurePortalRoot } from "../runtime/dom.js";
import { floatingTransform, useFloatingPosition } from "../runtime/overlays.js";
import { classNames, HtmlSlot, Icon } from "./shared.jsx";

// Strip tags from an item's label HTML so typeahead can match on plain text.
function htmlToText(html) {
  if (!html) return "";
  return String(html).replace(/<[^>]*>/g, "").replace(/\s+/g, " ").trim();
}

// Indices of the actionable rows (skip labels/separators/disabled items).
function enabledIndices(items) {
  const out = [];
  items.forEach((item, index) => {
    if (item.type === "item" && !item.disabled) out.push(index);
  });
  return out;
}

export function DropdownMenu({ payload, root }) {
  const props = payload.props || {};
  const [open, setOpenState] = useState(false);
  const [items, setItems] = useState(props.items || []);
  const [triggerHtml, setTriggerHtml] = useState(props.triggerHtml || "");
  const [triggerLabel, setTriggerLabel] = useState(props.triggerLabel || null);
  const [triggerVariant, setTriggerVariant] = useState(props.triggerVariant || "outline");
  const [side, setSide] = useState(props.side || "bottom");
  const [align, setAlign] = useState(props.align || "start");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [spriteHref, setSpriteHref] = useState(props.spriteHref || "");
  const [contentStyle, setContentStyle] = useState(props.contentStyle || null);
  const [contentClass, setContentClass] = useState(props.contentClass || null);
  const [highlighted, setHighlighted] = useState(-1);

  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const itemRefs = useRef([]);
  const returnFocusRef = useRef(null);
  const typeaheadRef = useRef({ buffer: "", timer: 0 });
  const menuId = `${payload.id || "dropdown-menu"}-menu`;
  const position = useFloatingPosition({ open, triggerRef, side, align });

  const actionable = useMemo(() => enabledIndices(items), [items]);

  function setOpen(next) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      const active = document.activeElement;
      returnFocusRef.current =
        active && active !== document.body ? active : triggerRef.current;
    }
    setOpenState(nextOpen);
    if (nextOpen) {
      setHighlighted(actionable.length ? actionable[0] : -1);
    } else {
      setHighlighted(-1);
    }
  }

  function activate(index) {
    const item = items[index];
    if (!item || item.type !== "item" || item.disabled) return;
    setOpen(false);
    if (root) {
      root.__sbDropdownMenuValue = item.value;
      root.dispatchEvent(new CustomEvent("sb:dropdown-menu-change"));
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDropdownMenuReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "items")) {
        setItems(nextData.items || []);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "triggerHtml")) {
        setTriggerHtml(nextData.triggerHtml == null ? "" : String(nextData.triggerHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "triggerLabel")) {
        setTriggerLabel(nextData.triggerLabel || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "triggerVariant")) {
        setTriggerVariant(nextData.triggerVariant || "outline");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "side")) {
        setSide(nextData.side || "bottom");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "align")) {
        setAlign(nextData.align || "start");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "spriteHref")) {
        setSpriteHref(nextData.spriteHref || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentStyle")) {
        setContentStyle(nextData.contentStyle || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentClass")) {
        setContentClass(nextData.contentClass || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        if (nextDisabled) setOpen(false);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        if (Boolean(nextData.open) && !disabled) setOpen(true);
        else setOpen(false);
      }
    };

    return () => {
      delete root.__sbDropdownMenuReceive;
    };
    // setOpen closes over `open`/`actionable`/`disabled`; the handler reads the
    // latest via functional intent, and re-installing on every change is cheap.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [root, open, disabled, actionable]);

  // Roving focus: move DOM focus onto the highlighted row while open.
  useEffect(() => {
    if (!open || highlighted < 0) return;
    const node = itemRefs.current[highlighted];
    if (node && typeof node.focus === "function") {
      node.focus({ preventScroll: false });
    }
  }, [open, highlighted]);

  useEffect(() => {
    if (!open) return undefined;

    const triggerNode = triggerRef.current;
    const focusFrame = requestAnimationFrame(() => {
      const first = actionable.length ? itemRefs.current[actionable[0]] : contentRef.current;
      if (first && typeof first.focus === "function") first.focus({ preventScroll: true });
    });

    function onDocumentPointerDown(event) {
      const target = event.target;
      if (triggerRef.current?.contains(target)) return;
      if (contentRef.current?.contains(target)) return;
      setOpen(false);
    }

    document.addEventListener("pointerdown", onDocumentPointerDown);

    return () => {
      cancelAnimationFrame(focusFrame);
      document.removeEventListener("pointerdown", onDocumentPointerDown);

      const stored = returnFocusRef.current;
      const target = stored && stored !== document.body ? stored : triggerNode;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        target.focus({ preventScroll: true });
      }
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [open]);

  function moveHighlight(delta) {
    if (actionable.length === 0) return;
    const pos = actionable.indexOf(highlighted);
    let nextPos;
    if (pos === -1) {
      nextPos = delta > 0 ? 0 : actionable.length - 1;
    } else {
      nextPos = (pos + delta + actionable.length) % actionable.length;
    }
    setHighlighted(actionable[nextPos]);
  }

  function typeahead(char) {
    const state = typeaheadRef.current;
    window.clearTimeout(state.timer);
    state.buffer += char.toLowerCase();
    state.timer = window.setTimeout(() => {
      state.buffer = "";
    }, 500);

    const needle = state.buffer;
    const startPos = actionable.indexOf(highlighted);
    const ordered = actionable
      .slice(startPos + 1)
      .concat(actionable.slice(0, startPos + 1));
    const match = ordered.find((index) =>
      htmlToText(items[index].labelHtml).toLowerCase().startsWith(needle)
    );
    if (match != null) setHighlighted(match);
  }

  function onKeyDown(event) {
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
      if (actionable.length) setHighlighted(actionable[0]);
      return;
    }
    if (event.key === "End") {
      event.preventDefault();
      if (actionable.length) setHighlighted(actionable[actionable.length - 1]);
      return;
    }
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      if (highlighted >= 0) activate(highlighted);
      return;
    }
    if (event.key === "Escape") {
      event.preventDefault();
      event.stopPropagation();
      setOpen(false);
      return;
    }
    if (event.key === "Tab") {
      setOpen(false);
      return;
    }
    if (event.key.length === 1 && !event.metaKey && !event.ctrlKey && !event.altKey) {
      typeahead(event.key);
    }
  }

  function onTriggerKeyDown(event) {
    if (disabled) return;
    if (event.key === "ArrowDown" || event.key === "Enter" || event.key === " ") {
      event.preventDefault();
      setOpen(true);
    }
  }

  itemRefs.current = [];
  const portal = ensurePortalRoot(root);
  const triggerVariantClass = `sb-button-${triggerVariant}`;

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        className={classNames(
          "sb-button",
          triggerVariantClass,
          "sb-button-size-default",
          "sb-dropdown-menu-trigger"
        )}
        data-slot="dropdown-menu-trigger"
        aria-haspopup="menu"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? menuId : undefined}
        aria-label={triggerLabel || undefined}
        disabled={disabled}
        onClick={() => {
          if (disabled) return;
          setOpen(!open);
        }}
        onKeyDown={onTriggerKeyDown}
      >
        <HtmlSlot html={triggerHtml} />
      </button>
      {open && position &&
        createPortal(
          <div
            id={menuId}
            ref={contentRef}
            className={classNames("sb-dropdown-menu-content", contentClass)}
            data-slot="dropdown-menu-content"
            data-side={side}
            data-align={align}
            role="menu"
            tabIndex={-1}
            aria-label={triggerLabel || undefined}
            onKeyDown={onKeyDown}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: floatingTransform(side, align),
              ...(contentStyle || {})
            }}
          >
            {items.map((item, index) => {
              if (item.type === "separator") {
                return (
                  <div
                    key={`sep-${index}`}
                    className="sb-dropdown-menu-separator"
                    data-slot="dropdown-menu-separator"
                    role="separator"
                    aria-orientation="horizontal"
                  />
                );
              }
              if (item.type === "label") {
                return (
                  <HtmlSlot
                    key={`label-${index}`}
                    as="div"
                    className="sb-dropdown-menu-label"
                    data-slot="dropdown-menu-label"
                    html={item.labelHtml}
                  />
                );
              }
              const iconPayload = {
                props: { iconName: item.iconName, iconHtml: item.iconHtml, spriteHref }
              };
              return (
                <div
                  key={`item-${index}-${item.value}`}
                  ref={(node) => {
                    itemRefs.current[index] = node;
                  }}
                  className="sb-dropdown-menu-item"
                  data-slot="dropdown-menu-item"
                  data-variant={item.variant || "default"}
                  data-highlighted={highlighted === index ? "true" : undefined}
                  data-disabled={item.disabled ? "true" : undefined}
                  role="menuitem"
                  tabIndex={highlighted === index ? 0 : -1}
                  aria-disabled={item.disabled ? "true" : undefined}
                  onMouseEnter={() => {
                    if (!item.disabled) setHighlighted(index);
                  }}
                  onClick={() => activate(index)}
                >
                  {(item.iconName || item.iconHtml) && (
                    <span className="sb-dropdown-menu-item-icon" aria-hidden="true">
                      <Icon payload={iconPayload} />
                    </span>
                  )}
                  <HtmlSlot as="span" className="sb-dropdown-menu-item-label" html={item.labelHtml} />
                  {item.shortcut && (
                    <span className="sb-dropdown-menu-shortcut">{item.shortcut}</span>
                  )}
                </div>
              );
            })}
          </div>,
          portal
        )}
    </>
  );
}
