import React, { useEffect, useRef, useState } from "react";
import { createRoot } from "react-dom/client";
import { createPortal } from "react-dom";
import {
  currentValue,
  ensurePortalRoot,
  labelIdForInput,
  readPayload,
  runtimeRoots
} from "./runtime/dom.js";
import {
  bindShinyChildren,
  forgetRevision,
  isFreshRevision,
  setInputValue,
  unbindShinyChildren
} from "./runtime/shiny.js";
import {
  bindRuntimeInputRoot,
  isRuntimeInputPayload,
  registerRuntimeInputBindings,
  unbindRuntimeInputRoot
} from "./runtime/bindings.js";
import {
  installNativeFocusForwarding,
  nativeCheckbox,
  nativeInput,
  nativeSelect,
  nativeSlider,
  nativeSwitch,
  nativeTextarea,
  normalizeSliderValue,
  setNativeCheckboxValue,
  setNativeChoices,
  setNativeInputValue,
  setNativeRadioGroupValue,
  setNativeSliderValue,
  setNativeSwitchValue,
  setNativeTextareaValue,
  setNativeValue,
  sliderValueToNative
} from "./runtime/native-inputs.js";

const mounted = new Map();

function RuntimeMount({ payload, root }) {
  if (payload.component === "button") {
    return <Button payload={payload} root={root} />;
  }

  if (payload.component === "badge") {
    return <Badge payload={payload} />;
  }

  if (payload.component === "separator") {
    return <Separator payload={payload} />;
  }

  if (payload.component === "spinner") {
    return <Spinner payload={payload} />;
  }

  if (payload.component === "skeleton") {
    return <Skeleton payload={payload} />;
  }

  if (payload.component === "empty") {
    return <Empty payload={payload} />;
  }

  if (payload.component === "value-box") {
    return <ValueBox payload={payload} />;
  }

  if (payload.component === "alert") {
    return <Alert payload={payload} />;
  }

  if (payload.component === "card") {
    return null;
  }

  if (payload.component === "dialog") {
    return <Dialog payload={payload} root={root} />;
  }

  if (payload.component === "popover") {
    return <Popover payload={payload} root={root} />;
  }

  if (payload.component === "tooltip") {
    return <Tooltip payload={payload} root={root} />;
  }

  if (payload.component === "checkbox") {
    return <Checkbox payload={payload} root={root} />;
  }

  if (payload.component === "switch") {
    return <Switch payload={payload} root={root} />;
  }

  if (payload.component === "textarea") {
    return <Textarea payload={payload} root={root} />;
  }

  if (payload.component === "input") {
    return <Input payload={payload} root={root} />;
  }

  if (payload.component === "radio-group") {
    return <RadioGroup payload={payload} root={root} />;
  }

  if (payload.component === "slider") {
    return <Slider payload={payload} root={root} />;
  }

  if (payload.component === "select") {
    return <Select payload={payload} root={root} />;
  }

  return (
    <span
      hidden
      data-shinyblocks-react-mounted={payload.component || "component"}
      data-shinyblocks-schema-version={payload.schemaVersion || 1}
    />
  );
}

function classNames(...values) {
  return values
    .flatMap((value) => String(value || "").split(/\s+/))
    .filter(Boolean)
    .filter((value, index, all) => all.indexOf(value) === index)
    .join(" ");
}

function passthroughAttrs(attrs) {
  const normalized = Object.fromEntries(
    Object.entries(attrs || {}).filter(([, value]) => value !== false && value !== null)
  );

  if (Object.prototype.hasOwnProperty.call(normalized, "style")) {
    if (
      typeof normalized.style !== "object" ||
      Array.isArray(normalized.style)
    ) {
      throw new Error("shinyblocks runtime style attrs must be objects.");
    }
  }

  return normalized;
}

function HtmlSlot({ html, className, ...attrs }) {
  if (!html) return null;
  return (
    <span
      className={className}
      dangerouslySetInnerHTML={{ __html: html }}
      {...attrs}
    />
  );
}

function Icon({ payload }) {
  const props = payload.props || {};
  const position = props.iconPosition || "inline-start";

  if (props.iconHtml) {
    return (
      <HtmlSlot
        html={props.iconHtml}
        data-icon={position}
      />
    );
  }

  if (!props.iconName) return null;

  return (
    <svg
      aria-hidden="true"
      focusable="false"
      data-icon={position}
    >
      <use href={`${props.spriteHref}#sb-icon-${props.iconName}`} />
    </svg>
  );
}

function Button({ payload, root }) {
  const initialProps = payload.props || {};
  const attrs = passthroughAttrs(initialProps.attrs);

  const [labelHtml, setLabelHtml] = useState(initialProps.labelHtml || "");
  const [variant, setVariant] = useState(initialProps.variant || "default");
  const [size, setSize] = useState(initialProps.size || "default");
  const [iconName, setIconName] = useState(initialProps.iconName || null);
  const [iconHtml, setIconHtml] = useState(initialProps.iconHtml || null);
  const [iconPosition, setIconPosition] = useState(initialProps.iconPosition || "inline-start");
  const [spriteHref, setSpriteHref] = useState(initialProps.spriteHref || "");
  const [disabled, setDisabled] = useState(Boolean(initialProps.disabled));
  const [style, setStyle] = useState(initialProps.style || {});
  const [className, setClassName] = useState(payload.className || "");

  useEffect(() => {
    if (!root) return undefined;

    root.__sbButtonReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "labelHtml")) {
        setLabelHtml(nextData.labelHtml == null ? "" : String(nextData.labelHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "variant")) {
        setVariant(nextData.variant || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconPosition")) {
        setIconPosition(nextData.iconPosition || "inline-start");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconName")) {
        setIconName(nextData.iconName == null ? null : String(nextData.iconName));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "iconHtml")) {
        setIconHtml(nextData.iconHtml == null ? null : String(nextData.iconHtml));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "spriteHref")) {
        setSpriteHref(nextData.spriteHref || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        setDisabled(Boolean(nextData.disabled));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style == null ? {} : nextData.style);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class == null ? "" : String(nextData.class));
      }
    };

    return () => {
      delete root.__sbButtonReceive;
    };
  }, [root]);

  const iconPayload = {
    props: { iconName, iconHtml, spriteHref, iconPosition }
  };

  return (
    <button
      type="button"
      data-slot="button"
      data-variant={variant}
      data-size={size}
      className={classNames(
        "sb-button",
        `sb-button-${variant}`,
        `sb-button-size-${size}`,
        className
      )}
      disabled={disabled}
      style={style}
      {...attrs}
    >
      {iconPosition === "inline-start" && <Icon payload={iconPayload} />}
      <HtmlSlot html={labelHtml} />
      {iconPosition === "inline-end" && <Icon payload={iconPayload} />}
    </button>
  );
}

function Badge({ payload }) {
  const props = payload.props || {};

  return (
    <span
      data-slot="badge"
      data-variant={props.variant || "default"}
      className={classNames(
        "sb-badge",
        `sb-badge-${props.variant || "default"}`,
        payload.className
      )}
    >
      <HtmlSlot html={props.labelHtml} />
    </span>
  );
}

function Separator({ payload }) {
  const props = payload.props || {};
  const orientation = props.orientation || "horizontal";
  const decorative = Boolean(props.decorative);

  return (
    <div
      data-slot="separator"
      data-orientation={orientation}
      className={classNames(
        "sb-separator",
        `sb-separator-${orientation}`,
        payload.className
      )}
      role={decorative ? undefined : "separator"}
      aria-orientation={decorative ? undefined : orientation}
      aria-hidden={decorative ? "true" : undefined}
    />
  );
}

function Spinner({ payload }) {
  const props = payload.props || {};

  return (
    <span
      data-slot="spinner"
      className={classNames("sb-spinner", payload.className)}
      role="status"
      aria-label={props.label || "Loading"}
    />
  );
}

function Skeleton({ payload }) {
  const props = payload.props || {};
  const attrs = passthroughAttrs(props.attrs);
  delete attrs["aria-hidden"];

  return (
    <div
      data-slot="skeleton"
      className={classNames("sb-skeleton", payload.className)}
      aria-hidden="true"
      {...attrs}
    />
  );
}

function Empty({ payload }) {
  const props = payload.props || {};

  return (
    <section
      data-slot="empty"
      className={classNames("sb-empty", payload.className)}
    >
      {props.iconHtml && (
        <div className="sb-empty-icon">
          <HtmlSlot html={props.iconHtml} />
        </div>
      )}
      <div className="sb-empty-body">
        <h3
          className="sb-empty-title"
          dangerouslySetInnerHTML={{ __html: props.titleHtml || "" }}
        />
        {props.descriptionHtml && (
          <p
            className="sb-empty-description"
            dangerouslySetInnerHTML={{ __html: props.descriptionHtml }}
          />
        )}
        {props.contentHtml && (
          <div
            className="sb-empty-content"
            dangerouslySetInnerHTML={{ __html: props.contentHtml }}
          />
        )}
        {props.actionHtml && (
          <div className="sb-empty-action">
            <HtmlSlot html={props.actionHtml} />
          </div>
        )}
      </div>
    </section>
  );
}

function ValueBox({ payload }) {
  const props = payload.props || {};

  return (
    <section
      data-slot="value-box"
      className={classNames("sb-value-box", payload.className)}
    >
      {props.iconHtml && (
        <div className="sb-value-box-icon">
          <HtmlSlot html={props.iconHtml} />
        </div>
      )}
      <div className="sb-value-box-body">
        <p
          className="sb-value-box-title"
          dangerouslySetInnerHTML={{ __html: props.titleHtml || "" }}
        />
        <div
          className="sb-value-box-value"
          dangerouslySetInnerHTML={{ __html: props.valueHtml || "" }}
        />
        {props.descriptionHtml && (
          <p
            className="sb-value-box-description"
            dangerouslySetInnerHTML={{ __html: props.descriptionHtml }}
          />
        )}
        {props.contentHtml && (
          <div
            className="sb-value-box-content"
            dangerouslySetInnerHTML={{ __html: props.contentHtml }}
          />
        )}
      </div>
    </section>
  );
}

function Alert({ payload }) {
  const props = payload.props || {};
  const variant = props.variant || "default";

  return (
    <div
      data-slot="alert"
      data-variant={variant}
      role="alert"
      className={classNames(
        "sb-alert",
        `sb-alert-${variant}`,
        payload.className
      )}
    >
      {props.iconHtml && (
        <div className="sb-alert-icon">
          <HtmlSlot html={props.iconHtml} />
        </div>
      )}
      <div
        className="sb-alert-content"
        dangerouslySetInnerHTML={{
          __html:
            (props.titleHtml || "") +
            (props.descriptionHtml || "") +
            (props.contentHtml || "")
        }}
      />
    </div>
  );
}

const FOCUSABLE_SELECTOR = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "[tabindex]:not([tabindex='-1'])"
].join(",");

function focusableChildren(container) {
  if (!container) return [];
  return Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR)).filter(
    (el) => !el.hasAttribute("aria-hidden") && el.offsetParent !== null
  );
}

function Dialog({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id || "dialog";
  const [open, setOpenState] = useState(Boolean(state.open));
  const [titleHtml, setTitleHtml] = useState(props.titleHtml || "");
  const [descriptionHtml, setDescriptionHtml] = useState(
    props.descriptionHtml || ""
  );
  const [footerHtml, setFooterHtml] = useState(props.footerHtml || "");
  const [size, setSize] = useState(props.size || "default");
  const hideTitle = Boolean(props.hideTitle);
  const titleId = `${inputId}-title`;
  const descriptionId = `${inputId}-description`;

  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);

  useEffect(() => {
    if (root) {
      root.__sbDialogValue = open;
      root.dataset.sbDialogOpen = open ? "true" : "false";
    }
  }, [open, root]);

  function notifyChange() {
    if (!root) return;
    root.dispatchEvent(new CustomEvent("sb:dialog-change"));
  }

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
    }
    setOpenState(nextOpen);
    if (notify !== false) {
      requestAnimationFrame(notifyChange);
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbDialogReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "titleHtml")) {
        setTitleHtml(nextData.titleHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "descriptionHtml")) {
        setDescriptionHtml(nextData.descriptionHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "footerHtml")) {
        setFooterHtml(nextData.footerHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "size")) {
        setSize(nextData.size || "default");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        setOpen(Boolean(nextData.open), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbDialogReceive;
    };
  }, [root]);

  useEffect(() => {
    if (!open) return undefined;

    const previousOverflow = document.body.style.overflow;
    const previousPaddingRight = document.body.style.paddingRight;
    const scrollbarWidth =
      window.innerWidth - document.documentElement.clientWidth;
    document.body.style.overflow = "hidden";
    if (scrollbarWidth > 0) {
      document.body.style.paddingRight = `${scrollbarWidth}px`;
    }

    const focusables = focusableChildren(contentRef.current);
    const initial = focusables[0] || contentRef.current;
    initial && initial.focus({ preventScroll: true });

    function onKeyDown(event) {
      if (event.key === "Escape") {
        event.stopPropagation();
        setOpen(false);
        return;
      }
      if (event.key !== "Tab") return;

      const items = focusableChildren(contentRef.current);
      if (items.length === 0) {
        event.preventDefault();
        contentRef.current && contentRef.current.focus();
        return;
      }

      const first = items[0];
      const last = items[items.length - 1];
      const active = document.activeElement;

      if (event.shiftKey && active === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && active === last) {
        event.preventDefault();
        first.focus();
      }
    }

    document.addEventListener("keydown", onKeyDown);

    return () => {
      document.removeEventListener("keydown", onKeyDown);
      document.body.style.overflow = previousOverflow;
      document.body.style.paddingRight = previousPaddingRight;

      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
  }, [open]);

  const portal = ensurePortalRoot();

  return (
    <>
      {props.triggerLabel && (
        <button
          type="button"
          className="sb-button sb-button-default sb-button-size-default"
          data-slot="dialog-trigger"
          aria-haspopup="dialog"
          aria-expanded={open ? "true" : "false"}
          onClick={() => setOpen(true)}
        >
          {props.triggerLabel}
        </button>
      )}
      {open &&
        createPortal(
          <div data-slot="dialog" data-sb-dialog-open="true">
            <div
              className="sb-dialog-overlay"
              data-slot="dialog-overlay"
              onClick={() => setOpen(false)}
            />
            <div
              role="dialog"
              aria-modal="true"
              aria-labelledby={titleId}
              aria-describedby={descriptionHtml ? descriptionId : undefined}
              tabIndex={-1}
              ref={contentRef}
              className={classNames(
                "sb-dialog-content",
                `sb-dialog-content-size-${size}`,
                payload.className
              )}
              data-slot="dialog-content"
              data-size={size}
            >
              <div className="sb-dialog-header" data-slot="dialog-header">
                <HtmlSlot
                  html={titleHtml}
                  id={titleId}
                  className={classNames(
                    "sb-dialog-title",
                    hideTitle && "sb-visually-hidden"
                  )}
                />
                {descriptionHtml && (
                  <HtmlSlot
                    html={descriptionHtml}
                    id={descriptionId}
                    className="sb-dialog-description"
                  />
                )}
              </div>
              {props.bodyHtml && (
                <div
                  className="sb-dialog-body"
                  data-slot="dialog-body"
                  dangerouslySetInnerHTML={{ __html: props.bodyHtml }}
                />
              )}
              {footerHtml && (
                <div
                  className="sb-dialog-footer"
                  data-slot="dialog-footer"
                  dangerouslySetInnerHTML={{ __html: footerHtml }}
                />
              )}
              <button
                type="button"
                className="sb-dialog-close"
                data-slot="dialog-close"
                aria-label="Close"
                onClick={() => setOpen(false)}
              >
                ×
              </button>
            </div>
          </div>,
          portal
        )}
    </>
  );
}

function Popover({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const [open, setOpenState] = useState(Boolean(state.open));
  const [position, setPosition] = useState(null);
  const [triggerLabel, setTriggerLabel] = useState(props.triggerLabel || "");
  const [bodyHtml, setBodyHtml] = useState(props.bodyHtml || "");
  const [side, setSide] = useState(props.side || "bottom");
  const [align, setAlign] = useState(props.align || "center");
  const [contentStyle, setContentStyle] = useState(props.contentStyle || null);
  const [contentClass, setContentClass] = useState(props.contentClass || null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const returnFocusRef = useRef(null);
  const contentId = `${payload.id || "popover"}-content`;

  useEffect(() => {
    if (root) {
      root.__sbPopoverValue = open;
      root.dataset.sbPopoverOpen = open ? "true" : "false";
    }
  }, [open, root]);

  function notifyChange() {
    if (!root) return;
    root.dispatchEvent(new CustomEvent("sb:popover-change"));
  }

  function setOpen(next, notify) {
    const nextOpen = Boolean(next);
    if (nextOpen && !open) {
      returnFocusRef.current = document.activeElement;
    }
    setOpenState(nextOpen);
    if (notify !== false) {
      requestAnimationFrame(notifyChange);
    }
  }

  useEffect(() => {
    if (!root) return undefined;

    root.__sbPopoverReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "triggerLabel")) {
        setTriggerLabel(nextData.triggerLabel || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "bodyHtml")) {
        setBodyHtml(nextData.bodyHtml || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "side")) {
        setSide(nextData.side || "bottom");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "align")) {
        setAlign(nextData.align || "center");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentStyle")) {
        setContentStyle(nextData.contentStyle || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "contentClass")) {
        setContentClass(nextData.contentClass || null);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "open")) {
        setOpen(Boolean(nextData.open), Boolean(nextData.notify));
      }
    };

    return () => {
      delete root.__sbPopoverReceive;
    };
  }, [root]);

  useEffect(() => {
    if (!open || !triggerRef.current) return undefined;

    function updatePosition() {
      const rect = triggerRef.current.getBoundingClientRect();
      const offset = 8;
      let top = 0;
      let left = 0;
      if (side === "bottom") {
        top = rect.bottom + offset;
      } else if (side === "top") {
        top = rect.top - offset;
      } else if (side === "left") {
        left = rect.left - offset;
        top = rect.top;
      } else if (side === "right") {
        left = rect.right + offset;
        top = rect.top;
      }
      if (side === "top" || side === "bottom") {
        if (align === "center") {
          left = rect.left + rect.width / 2;
        } else if (align === "start") {
          left = rect.left;
        } else {
          left = rect.right;
        }
      } else if (align === "center") {
        top = rect.top + rect.height / 2;
      } else if (align === "end") {
        top = rect.bottom;
      }
      setPosition({ top, left });
    }

    updatePosition();
    window.addEventListener("scroll", updatePosition, true);
    window.addEventListener("resize", updatePosition);
    return () => {
      window.removeEventListener("scroll", updatePosition, true);
      window.removeEventListener("resize", updatePosition);
    };
  }, [open, side, align]);

  useEffect(() => {
    if (!open) return undefined;

    const focusFrame = requestAnimationFrame(() => {
      const focusables = focusableChildren(contentRef.current);
      const initial = focusables[0] || contentRef.current;
      if (initial && typeof initial.focus === "function") {
        initial.focus({ preventScroll: true });
      }
    });

    function onDocumentPointerDown(event) {
      const target = event.target;
      if (triggerRef.current?.contains(target)) return;
      if (contentRef.current?.contains(target)) return;
      setOpen(false);
    }

    function onDocumentKeyDown(event) {
      if (event.key !== "Escape") return;
      event.stopPropagation();
      setOpen(false);
    }

    document.addEventListener("pointerdown", onDocumentPointerDown);
    document.addEventListener("keydown", onDocumentKeyDown);

    return () => {
      cancelAnimationFrame(focusFrame);
      document.removeEventListener("pointerdown", onDocumentPointerDown);
      document.removeEventListener("keydown", onDocumentKeyDown);

      const target = returnFocusRef.current;
      returnFocusRef.current = null;
      if (target && typeof target.focus === "function") {
        requestAnimationFrame(() => target.focus({ preventScroll: true }));
      }
    };
  }, [open]);

  const portal = ensurePortalRoot();

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        className="sb-button sb-button-default sb-button-size-default"
        data-slot="popover-trigger"
        aria-haspopup="dialog"
        aria-expanded={open ? "true" : "false"}
        aria-controls={open ? contentId : undefined}
        onClick={() => setOpen(!open)}
      >
        {triggerLabel}
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className={classNames("sb-popover-content", contentClass)}
            data-slot="popover-content"
            data-side={side}
            data-align={align}
            role="dialog"
            tabIndex={-1}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: popoverTransform(side, align),
              ...(contentStyle || {})
            }}
            dangerouslySetInnerHTML={{ __html: bodyHtml || "" }}
          />,
          portal
        )}
    </>
  );
}

function Tooltip({ payload }) {
  const props = payload.props || {};
  const [open, setOpen] = useState(false);
  const [position, setPosition] = useState(null);
  const triggerRef = useRef(null);
  const contentRef = useRef(null);
  const openTimerRef = useRef(null);
  const closeTimerRef = useRef(null);
  const triggerLabel = props.triggerLabel || "";
  const bodyHtml = props.bodyHtml || "";
  const side = props.side || "top";
  const align = props.align || "center";
  const delay = Number.isFinite(props.delayDuration) ? props.delayDuration : 700;
  const contentStyle = props.contentStyle || null;
  const contentClass = props.contentClass || null;
  const contentId = `${payload.id || "tooltip"}-content`;

  function clearTimers() {
    if (openTimerRef.current) {
      clearTimeout(openTimerRef.current);
      openTimerRef.current = null;
    }
    if (closeTimerRef.current) {
      clearTimeout(closeTimerRef.current);
      closeTimerRef.current = null;
    }
  }

  function scheduleOpen() {
    clearTimers();
    if (open) return;
    openTimerRef.current = setTimeout(() => {
      openTimerRef.current = null;
      setOpen(true);
    }, delay);
  }

  function scheduleClose() {
    clearTimers();
    if (!open) return;
    closeTimerRef.current = setTimeout(() => {
      closeTimerRef.current = null;
      setOpen(false);
    }, 150);
  }

  useEffect(() => () => clearTimers(), []);

  useEffect(() => {
    if (!open || !triggerRef.current) return undefined;

    function updatePosition() {
      const rect = triggerRef.current.getBoundingClientRect();
      const offset = 8;
      let top = 0;
      let left = 0;
      if (side === "bottom") {
        top = rect.bottom + offset;
      } else if (side === "top") {
        top = rect.top - offset;
      } else if (side === "left") {
        left = rect.left - offset;
        top = rect.top;
      } else if (side === "right") {
        left = rect.right + offset;
        top = rect.top;
      }
      if (side === "top" || side === "bottom") {
        if (align === "center") {
          left = rect.left + rect.width / 2;
        } else if (align === "start") {
          left = rect.left;
        } else {
          left = rect.right;
        }
      } else if (align === "center") {
        top = rect.top + rect.height / 2;
      } else if (align === "end") {
        top = rect.bottom;
      }
      setPosition({ top, left });
    }

    updatePosition();
    window.addEventListener("scroll", updatePosition, true);
    window.addEventListener("resize", updatePosition);
    return () => {
      window.removeEventListener("scroll", updatePosition, true);
      window.removeEventListener("resize", updatePosition);
    };
  }, [open, side, align]);

  useEffect(() => {
    if (!open) return undefined;

    function onKeyDown(event) {
      if (event.key !== "Escape") return;
      event.stopPropagation();
      clearTimers();
      setOpen(false);
    }

    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("keydown", onKeyDown);
    };
  }, [open]);

  const portal = ensurePortalRoot();

  return (
    <>
      <button
        ref={triggerRef}
        type="button"
        className="sb-button sb-button-outline sb-button-size-default"
        data-slot="tooltip-trigger"
        aria-describedby={open ? contentId : undefined}
        onMouseEnter={scheduleOpen}
        onMouseLeave={scheduleClose}
        onFocus={scheduleOpen}
        onBlur={scheduleClose}
      >
        {triggerLabel}
      </button>
      {open && position &&
        createPortal(
          <div
            id={contentId}
            ref={contentRef}
            className={classNames("sb-tooltip-content", contentClass)}
            data-slot="tooltip-content"
            data-side={side}
            data-align={align}
            role="tooltip"
            onMouseEnter={scheduleOpen}
            onMouseLeave={scheduleClose}
            style={{
              position: "fixed",
              top: `${position.top}px`,
              left: `${position.left}px`,
              transform: popoverTransform(side, align),
              ...(contentStyle || {})
            }}
            dangerouslySetInnerHTML={{ __html: bodyHtml || "" }}
          />,
          portal
        )}
    </>
  );
}

function Checkbox({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [checked, setCheckedState] = useState(Boolean(state.value));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const controlRef = useRef(null);
  const invalid = root?.getAttribute("aria-invalid") === "true";
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const inlineLabelId = inputId ? `${inputId}__label` : undefined;

  useEffect(() => {
    if (root) {
      root.__sbCheckboxValue = checked;
      root.dataset.sbCheckboxChecked = checked ? "true" : "false";
    }
  }, [checked, root]);

  useEffect(() => {
    if (!root) return;
    setNativeCheckboxValue(root, checked, false);
  }, [checked, root]);

  useEffect(() => {
    if (!root) return undefined;

    setLabelledBy(labelIdForInput(inputId));

    root.__sbCheckboxReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "checked")) {
        const nextChecked = Boolean(nextData.checked);
        setCheckedState(nextChecked);
        setNativeCheckboxValue(root, nextChecked, Boolean(nextData.notify));
        if (nextData.notify) {
          requestAnimationFrame(() => {
            root.__sbCheckboxValue = nextChecked;
            root.dispatchEvent(new CustomEvent("sb:checkbox-change"));
          });
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeCheckbox(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbCheckboxReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    root.toggleAttribute("data-disabled", disabled);
    const native = nativeCheckbox(root);
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  function notifyChange(nextChecked) {
    if (!root) return;
    root.__sbCheckboxValue = nextChecked;
    root.dataset.sbCheckboxChecked = nextChecked ? "true" : "false";
    setNativeCheckboxValue(root, nextChecked, true);
    root.dispatchEvent(new CustomEvent("sb:checkbox-change"));
  }

  function setChecked(nextChecked, notify = false) {
    const next = Boolean(nextChecked);
    setCheckedState(next);
    if (notify) {
      requestAnimationFrame(() => notifyChange(next));
    }
  }

  function toggle() {
    if (disabled) return;
    setChecked(!checked, true);
  }

  return (
    <div
      data-slot="checkbox"
      className={classNames("sb-checkbox", className)}
      data-state={checked ? "checked" : "unchecked"}
      data-disabled={disabled ? "true" : undefined}
    >
      <button
        ref={controlRef}
        type="button"
        className="sb-checkbox-button"
        data-slot="checkbox-control"
        data-state={checked ? "checked" : "unchecked"}
        role="checkbox"
        aria-checked={checked ? "true" : "false"}
        aria-labelledby={labelledBy || inlineLabelId || undefined}
        aria-describedby={describedBy}
        aria-invalid={invalid || undefined}
        disabled={disabled}
        style={style}
        onClick={toggle}
        onKeyDown={(event) => {
          if (event.key === " " || event.key === "Enter") {
            event.preventDefault();
            toggle();
          }
        }}
      >
        <span className="sb-checkbox-indicator" aria-hidden="true">
          <svg viewBox="0 0 15 15" aria-hidden="true" focusable="false">
            <path
              d="M11.4669 3.72684C11.7598 3.43395 12.2347 3.43395 12.5276 3.72684C12.8205 4.01974 12.8205 4.49461 12.5276 4.7875L6.86095 10.4542C6.56806 10.7471 6.09318 10.7471 5.80029 10.4542L3.46696 8.12084C3.17407 7.82795 3.17407 7.35308 3.46696 7.06018C3.75986 6.76729 4.23473 6.76729 4.52762 7.06018L6.33062 8.86317L11.4669 3.72684Z"
              fill="currentColor"
            />
          </svg>
        </span>
      </button>
      <HtmlSlot
        id={inlineLabelId}
        html={props.labelHtml}
        className="sb-checkbox-text"
        onClick={() => {
          if (disabled) return;
          controlRef.current?.focus();
          toggle();
        }}
      />
    </div>
  );
}

function Switch({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const [checked, setCheckedState] = useState(Boolean(state.value));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [labelledBy, setLabelledBy] = useState(null);
  const controlRef = useRef(null);
  const invalid = root?.getAttribute("aria-invalid") === "true";
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const inlineLabelId = inputId ? `${inputId}__label` : undefined;

  useEffect(() => {
    if (root) {
      root.__sbSwitchValue = checked;
      root.dataset.sbSwitchChecked = checked ? "true" : "false";
    }
  }, [checked, root]);

  useEffect(() => {
    if (!root) return;
    setNativeSwitchValue(root, checked, false);
  }, [checked, root]);

  useEffect(() => {
    if (!root) return undefined;

    setLabelledBy(labelIdForInput(inputId));

    root.__sbSwitchReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "checked")) {
        const nextChecked = Boolean(nextData.checked);
        setCheckedState(nextChecked);
        setNativeSwitchValue(root, nextChecked, Boolean(nextData.notify));
        if (nextData.notify) {
          requestAnimationFrame(() => {
            root.__sbSwitchValue = nextChecked;
            root.dispatchEvent(new CustomEvent("sb:switch-change"));
          });
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSwitch(root);
        if (native) native.disabled = nextDisabled;
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbSwitchReceive;
    };
  }, [inputId, root]);

  useEffect(() => {
    if (!root) return;
    root.toggleAttribute("data-disabled", disabled);
    const native = nativeSwitch(root);
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  function notifyChange(nextChecked) {
    if (!root) return;
    root.__sbSwitchValue = nextChecked;
    root.dataset.sbSwitchChecked = nextChecked ? "true" : "false";
    setNativeSwitchValue(root, nextChecked, true);
    root.dispatchEvent(new CustomEvent("sb:switch-change"));
  }

  function setChecked(nextChecked, notify = false) {
    const next = Boolean(nextChecked);
    setCheckedState(next);
    if (notify) {
      requestAnimationFrame(() => notifyChange(next));
    }
  }

  function toggle() {
    if (disabled) return;
    setChecked(!checked, true);
  }

  return (
    <div
      data-slot="switch"
      className={classNames("sb-switch", className)}
      data-state={checked ? "checked" : "unchecked"}
      data-disabled={disabled ? "true" : undefined}
    >
      <button
        ref={controlRef}
        type="button"
        className="sb-switch-button"
        data-slot="switch-control"
        data-state={checked ? "checked" : "unchecked"}
        role="switch"
        aria-checked={checked ? "true" : "false"}
        aria-labelledby={labelledBy || inlineLabelId || undefined}
        aria-describedby={describedBy}
        aria-invalid={invalid || undefined}
        disabled={disabled}
        style={style}
        onClick={toggle}
        onKeyDown={(event) => {
          if (event.key === " " || event.key === "Enter") {
            event.preventDefault();
            toggle();
          }
        }}
      >
        <span className="sb-switch-thumb" aria-hidden="true" />
      </button>
      <HtmlSlot
        id={inlineLabelId}
        html={props.labelHtml}
        className="sb-switch-text"
        onClick={() => {
          if (disabled) return;
          controlRef.current?.focus();
          toggle();
        }}
      />
    </div>
  );
}

function Textarea({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = typeof state.value === "string" ? state.value : "";
  const [value, setValueState] = useState(initialValue);
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [rows, setRows] = useState(Number(props.rows || 3));
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const textareaRef = useRef(null);

  useEffect(() => {
    if (root) {
      root.__sbTextareaValue = value;
      root.dataset.sbTextareaValue = value;
    }
  }, [value, root]);

  useEffect(() => {
    if (!root) return;
    setNativeTextareaValue(root, value, false);
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbTextareaReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        const nextValue = nextData.value == null ? "" : String(nextData.value);
        setValueState(nextValue);
        setNativeTextareaValue(root, nextValue, Boolean(nextData.notify));
        if (textareaRef.current) textareaRef.current.style.height = "";
        if (nextData.notify) {
          requestAnimationFrame(() => {
            root.__sbTextareaValue = nextValue;
            root.dispatchEvent(new CustomEvent("sb:textarea-change"));
          });
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder == null ? "" : String(nextData.placeholder));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "rows")) {
        const nextRows = Number(nextData.rows);
        if (Number.isFinite(nextRows) && nextRows >= 1) {
          setRows(nextRows);
          if (textareaRef.current) textareaRef.current.style.height = "";
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeTextarea(root);
        if (native) native.disabled = nextDisabled;
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
    };

    return () => {
      delete root.__sbTextareaReceive;
    };
  }, [inputId, root]);

  function handleChange(event) {
    const next = event.target.value;
    setValueState(next);
    if (root) {
      root.__sbTextareaValue = next;
      setNativeTextareaValue(root, next, true);
      root.dispatchEvent(new CustomEvent("sb:textarea-change"));
    }
  }

  return (
    <textarea
      ref={textareaRef}
      className={classNames("sb-textarea-control", className)}
      data-slot="textarea-control"
      value={value}
      placeholder={placeholder || undefined}
      rows={rows}
      disabled={disabled}
      aria-invalid={isInvalid || undefined}
      aria-labelledby={labelledBy || undefined}
      aria-describedby={describedBy}
      style={style}
      onChange={handleChange}
    />
  );
}

function RadioGroup({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = state.value == null ? null : String(state.value);
  const [value, setValueState] = useState(initialValue);
  const [choices, setChoices] = useState(Array.isArray(props.choices) ? props.choices : []);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [orientation, setOrientation] = useState(props.orientation || "vertical");
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const itemRefs = useRef(new Map());

  useEffect(() => {
    if (root) {
      root.__sbRadioGroupValue = value == null ? null : String(value);
      root.dataset.sbRadioGroupValue = value == null ? "" : String(value);
      setNativeRadioGroupValue(root, value);
    }
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbRadioGroupReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "selected")) {
        const nextValue = nextData.selected == null ? null : String(nextData.selected);
        setValueState(nextValue);
        if (nextData.notify) {
          requestAnimationFrame(() => {
            root.__sbRadioGroupValue = nextValue;
            root.dispatchEvent(new CustomEvent("sb:radio-group-change"));
          });
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "choices")) {
        setChoices(Array.isArray(nextData.choices) ? nextData.choices : []);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "invalid")) {
        setInvalid(Boolean(nextData.invalid));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "orientation")) {
        setOrientation(nextData.orientation || "vertical");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "class")) {
        setClassName(nextData.class || "");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "style")) {
        setStyle(nextData.style || {});
      }
    };

    return () => {
      delete root.__sbRadioGroupReceive;
    };
  }, [inputId, root]);

  function selectValue(nextValue) {
    if (disabled) return;
    const next = nextValue == null ? null : String(nextValue);
    setValueState(next);
    if (root) {
      root.__sbRadioGroupValue = next;
      setNativeRadioGroupValue(root, next);
      root.dispatchEvent(new CustomEvent("sb:radio-group-change"));
    }
  }

  function focusItem(itemValue) {
    const node = itemRefs.current.get(itemValue);
    if (node) node.focus();
  }

  function handleKeyDown(event, currentValue) {
    if (disabled || choices.length === 0) return;
    const idx = choices.findIndex((c) => String(c.value) === String(currentValue));
    if (idx < 0) return;
    let nextIdx = null;

    if (event.key === "ArrowDown" || event.key === "ArrowRight") {
      nextIdx = (idx + 1) % choices.length;
    } else if (event.key === "ArrowUp" || event.key === "ArrowLeft") {
      nextIdx = (idx - 1 + choices.length) % choices.length;
    } else if (event.key === " " || event.key === "Enter") {
      event.preventDefault();
      selectValue(currentValue);
      return;
    }

    if (nextIdx == null) return;
    event.preventDefault();
    const nextValue = choices[nextIdx].value;
    selectValue(nextValue);
    focusItem(nextValue);
  }

  return (
    <div
      role="radiogroup"
      aria-labelledby={labelledBy || undefined}
      aria-invalid={isInvalid || undefined}
      aria-disabled={disabled || undefined}
      data-orientation={orientation}
      data-disabled={disabled ? "true" : undefined}
      className={classNames("sb-radio-group-control", className)}
      style={style}
    >
      {choices.map((choice) => {
        const choiceValue = String(choice.value);
        const isChecked = String(value) === choiceValue;
        const itemId = inputId ? `${inputId}__opt_${choiceValue}` : undefined;
        return (
          <label
            key={choiceValue}
            className="sb-radio-group-item"
            data-state={isChecked ? "checked" : "unchecked"}
            data-disabled={disabled ? "true" : undefined}
          >
            <button
              ref={(node) => {
                if (node) itemRefs.current.set(choiceValue, node);
                else itemRefs.current.delete(choiceValue);
              }}
              type="button"
              role="radio"
              id={itemId}
              className="sb-radio-group-button"
              aria-checked={isChecked ? "true" : "false"}
              data-state={isChecked ? "checked" : "unchecked"}
              tabIndex={isChecked || (value == null && choices.indexOf(choice) === 0) ? 0 : -1}
              disabled={disabled}
              onClick={() => selectValue(choiceValue)}
              onKeyDown={(event) => handleKeyDown(event, choiceValue)}
            >
              <span className="sb-radio-group-indicator" aria-hidden="true" />
            </button>
            <span className="sb-radio-group-text">{choice.label}</span>
          </label>
        );
      })}
    </div>
  );
}

function Slider({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialMin = Number(props.min);
  const initialMax = Number(props.max);
  const [min, setMin] = useState(Number.isFinite(initialMin) ? initialMin : 0);
  const [max, setMax] = useState(Number.isFinite(initialMax) ? initialMax : 100);
  const [step, setStep] = useState(Number(props.step) > 0 ? Number(props.step) : 1);
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const [activeThumb, setActiveThumb] = useState(0);
  const rangeMode = Array.isArray(state.value) && state.value.length > 1;
  const [value, setValueState] = useState(
    normalizeSliderValue(rangeMode ? state.value.slice(0, 2) : state.value, min, max)
  );
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;
  const trackRef = useRef(null);

  function valuesArray(nextValue = value) {
    return Array.isArray(nextValue) ? nextValue : [nextValue];
  }

  function percentFor(item) {
    if (max === min) return 0;
    return ((Number(item) - min) / (max - min)) * 100;
  }

  function quantize(raw, nextMin = min, nextMax = max, nextStep = step) {
    const usableStep = Number(nextStep) > 0 ? Number(nextStep) : 1;
    const clamped = Math.min(nextMax, Math.max(nextMin, Number(raw)));
    const snapped = Math.round((clamped - nextMin) / usableStep) * usableStep + nextMin;
    const precision = Math.max(0, String(usableStep).split(".")[1]?.length || 0);
    return Number(Math.min(nextMax, Math.max(nextMin, snapped)).toFixed(precision));
  }

  function normalized(nextValue, nextMin = min, nextMax = max, nextStep = step) {
    const next = normalizeSliderValue(nextValue, nextMin, nextMax);
    if (Array.isArray(next)) return next.map((item) => quantize(item, nextMin, nextMax, nextStep));
    return quantize(next, nextMin, nextMax, nextStep);
  }

  function commit(nextValue, notify = false) {
    const next = normalized(nextValue);
    setValueState(next);
    if (!root) return;
    root.__sbSliderValue = next;
    root.dataset.sbSliderValue = sliderValueToNative(next);
    setNativeSliderValue(root, next, notify);
    if (notify) root.dispatchEvent(new CustomEvent("sb:slider-change"));
  }

  function valueFromPointer(event) {
    const track = trackRef.current;
    if (!track) return min;
    const rect = track.getBoundingClientRect();
    const ratio = rect.width <= 0 ? 0 : (event.clientX - rect.left) / rect.width;
    return quantize(min + Math.min(1, Math.max(0, ratio)) * (max - min));
  }

  function chooseThumb(nextValue) {
    const values = valuesArray();
    if (values.length < 2) return 0;
    return Math.abs(nextValue - values[0]) <= Math.abs(nextValue - values[1]) ? 0 : 1;
  }

  function updateThumb(index, nextValue, notify = true) {
    const values = valuesArray();
    if (values.length === 1) {
      commit(nextValue, notify);
      return;
    }
    const nextValues = values.slice(0, 2);
    nextValues[index] = nextValue;
    if (index === 0) nextValues[0] = Math.min(nextValues[0], nextValues[1]);
    if (index === 1) nextValues[1] = Math.max(nextValues[0], nextValues[1]);
    commit(nextValues, notify);
  }

  function handlePointerDown(event) {
    if (disabled) return;
    event.preventDefault();
    const nextValue = valueFromPointer(event);
    const thumb = chooseThumb(nextValue);
    setActiveThumb(thumb);
    updateThumb(thumb, nextValue, true);
    event.currentTarget.setPointerCapture?.(event.pointerId);
  }

  function handlePointerMove(event) {
    if (disabled || event.buttons !== 1) return;
    updateThumb(activeThumb, valueFromPointer(event), true);
  }

  function handleKeyDown(event, index) {
    if (disabled) return;
    const values = valuesArray();
    const current = values[index] ?? values[0] ?? min;
    let next = null;

    if (event.key === "ArrowRight" || event.key === "ArrowUp") next = current + step;
    if (event.key === "ArrowLeft" || event.key === "ArrowDown") next = current - step;
    if (event.key === "PageUp") next = current + step * 10;
    if (event.key === "PageDown") next = current - step * 10;
    if (event.key === "Home") next = min;
    if (event.key === "End") next = max;
    if (next == null) return;

    event.preventDefault();
    setActiveThumb(index);
    updateThumb(index, next, true);
  }

  useEffect(() => {
    if (root) {
      root.__sbSliderValue = value;
      root.dataset.sbSliderValue = sliderValueToNative(value);
      setNativeSliderValue(root, value, false);
    }
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbSliderReceive = (data) => {
      const nextData = data || {};
      let nextMin = min;
      let nextMax = max;
      let nextStep = step;

      if (Object.prototype.hasOwnProperty.call(nextData, "min")) {
        const parsedMin = Number(nextData.min);
        if (Number.isFinite(parsedMin)) {
          nextMin = parsedMin;
          setMin(parsedMin);
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "max")) {
        const parsedMax = Number(nextData.max);
        if (Number.isFinite(parsedMax)) {
          nextMax = parsedMax;
          setMax(parsedMax);
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "step")) {
        const parsedStep = Number(nextData.step);
        nextStep = parsedStep > 0 ? parsedStep : 1;
        setStep(nextStep);
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        const nextValue = normalizeSliderValue(nextData.value, nextMin, nextMax);
        const next = Array.isArray(nextValue)
          ? nextValue.map((item) => quantize(item, nextMin, nextMax, nextStep))
          : quantize(nextValue, nextMin, nextMax, nextStep);
        setValueState(next);
        setNativeSliderValue(root, next, Boolean(nextData.notify));
        if (nextData.notify) {
          requestAnimationFrame(() => {
            root.__sbSliderValue = next;
            root.dispatchEvent(new CustomEvent("sb:slider-change"));
          });
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeSlider(root);
        if (native) native.disabled = nextDisabled;
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
    };

    return () => {
      delete root.__sbSliderReceive;
    };
  }, [max, min, root, step, value]);

  useEffect(() => {
    if (!root) return;
    root.toggleAttribute("data-disabled", disabled);
    const native = nativeSlider(root);
    if (native) native.disabled = disabled;
  }, [disabled, root]);

  const values = valuesArray();
  const lower = values.length > 1 ? values[0] : min;
  const upper = values.length > 1 ? values[1] : values[0];
  const left = Math.min(100, Math.max(0, percentFor(lower)));
  const right = Math.min(100, Math.max(0, percentFor(upper)));

  return (
    <div
      className={classNames("sb-slider", className)}
      data-slot="slider"
      data-disabled={disabled ? "true" : undefined}
      data-invalid={isInvalid ? "true" : undefined}
      style={style}
    >
      <div
        ref={trackRef}
        className="sb-slider-track"
        data-slot="slider-track"
        onPointerDown={handlePointerDown}
        onPointerMove={handlePointerMove}
      >
        <div
          className="sb-slider-range"
          data-slot="slider-range"
          style={{ left: `${left}%`, width: `${Math.max(0, right - left)}%` }}
        />
      </div>
      {values.map((item, index) => (
        <button
          key={index}
          type="button"
          className="sb-slider-thumb"
          data-slot="slider-thumb"
          role="slider"
          aria-valuemin={min}
          aria-valuemax={max}
          aria-valuenow={item}
          aria-labelledby={labelledBy || undefined}
          aria-describedby={describedBy}
          aria-invalid={isInvalid || undefined}
          disabled={disabled}
          style={{ left: `${percentFor(item)}%` }}
          onFocus={() => setActiveThumb(index)}
          onKeyDown={(event) => handleKeyDown(event, index)}
        />
      ))}
    </div>
  );
}

function Input({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;
  const initialValue = typeof state.value === "string" ? state.value : "";
  const [value, setValueState] = useState(initialValue);
  const [placeholder, setPlaceholder] = useState(props.placeholder || "");
  const [type, setType] = useState(props.type || "text");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [style, setStyle] = useState(props.style || {});
  const [className, setClassName] = useState(payload.className || "");
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = invalid || wrapperInvalid;

  useEffect(() => {
    if (root) {
      root.__sbInputValue = value;
      root.dataset.sbInputValue = value;
    }
  }, [value, root]);

  useEffect(() => {
    if (!root) return;
    setNativeInputValue(root, value, false);
  }, [value, root]);

  useEffect(() => {
    if (!root) return undefined;

    root.__sbInputReceive = (data) => {
      const nextData = data || {};

      if (Object.prototype.hasOwnProperty.call(nextData, "value")) {
        const nextValue = nextData.value == null ? "" : String(nextData.value);
        setValueState(nextValue);
        setNativeInputValue(root, nextValue, Boolean(nextData.notify));
        if (nextData.notify) {
          requestAnimationFrame(() => {
            root.__sbInputValue = nextValue;
            root.dispatchEvent(new CustomEvent("sb:input-change"));
          });
        }
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "placeholder")) {
        setPlaceholder(nextData.placeholder == null ? "" : String(nextData.placeholder));
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "type")) {
        setType(nextData.type || "text");
      }
      if (Object.prototype.hasOwnProperty.call(nextData, "disabled")) {
        const nextDisabled = Boolean(nextData.disabled);
        setDisabled(nextDisabled);
        root.toggleAttribute("data-disabled", nextDisabled);
        const native = nativeInput(root);
        if (native) native.disabled = nextDisabled;
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
    };

    return () => {
      delete root.__sbInputReceive;
    };
  }, [inputId, root]);

  function handleChange(event) {
    const next = event.target.value;
    setValueState(next);
    if (root) {
      root.__sbInputValue = next;
      setNativeInputValue(root, next, true);
      root.dispatchEvent(new CustomEvent("sb:input-change"));
    }
  }

  return (
    <input
      className={classNames("sb-input-control", className)}
      data-slot="input-control"
      type={type}
      value={value}
      placeholder={placeholder || undefined}
      disabled={disabled}
      aria-invalid={isInvalid || undefined}
      aria-labelledby={labelledBy || undefined}
      aria-describedby={describedBy}
      style={style}
      onChange={handleChange}
    />
  );
}

function popoverTransform(side, align) {
  if (side === "top" || side === "bottom") {
    const y = side === "top" ? "-100%" : "0";
    if (align === "center") return `translate(-50%, ${y})`;
    if (align === "start") return `translate(0, ${y})`;
    return `translate(-100%, ${y})`;
  }
  const x = side === "left" ? "-100%" : "0";
  if (align === "center") return `translate(${x}, -50%)`;
  if (align === "end") return `translate(${x}, -100%)`;
  return `translate(${x}, 0)`;
}

function Select({ payload, root }) {
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

  function updatePosition() {
    const trigger = triggerRef.current;
    if (!trigger) return;

    const rect = trigger.getBoundingClientRect();
    setPosition({
      top: rect.bottom + 4,
      left: rect.left,
      minWidth: rect.width
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
            minWidth: `${position.minWidth}px`
          } : undefined}
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

function renderReactMount(root, payload) {
  let target = root.querySelector("[data-shinyblocks-react]");
  if (!target) {
    target = document.createElement("div");
    target.setAttribute("data-shinyblocks-react", "");
    root.insertBefore(target, root.firstChild);
  }

  const reactRoot = createRoot(target);
  reactRoot.render(<RuntimeMount payload={payload} root={root} />);
  return reactRoot;
}

function mountRoot(root) {
  if (mounted.has(root)) return;

  const payload = readPayload(root);
  if (!payload) return;
  registerRuntimeInputBindings();
  payload.rootAttrs = {
    ariaInvalid: root.getAttribute("aria-invalid"),
    ariaDescribedby: root.getAttribute("aria-describedby")
  };

  ensurePortalRoot();
  const reactRoot = renderReactMount(root, payload);

  root.dataset.sbMounted = "true";
  root.dataset.sbSchemaVersion = String(payload.schemaVersion || 1);

  mounted.set(root, { payload, reactRoot });
  if (!bindRuntimeInputRoot(root, payload)) {
    bindShinyChildren(root);
  }

  if (
    payload.id &&
    payload.binding &&
    payload.binding.input &&
    !isRuntimeInputPayload(payload)
  ) {
    const initialized = setInputValue(payload.id, currentValue(payload), "event");
    if (!initialized) {
      root.dataset.sbPendingInput = "true";
      schedulePendingInputFlush();
    }
  }
}

function unmountRoot(root) {
  const mountedRoot = mounted.get(root);
  if (!mountedRoot) return;

  if (!unbindRuntimeInputRoot(root, mountedRoot.payload)) {
    unbindShinyChildren(root);
  }
  mountedRoot.reactRoot.unmount();
  if (mountedRoot.payload.id) forgetRevision(mountedRoot.payload.id);
  mounted.delete(root);
}

function mountAll(container) {
  runtimeRoots(container).forEach(mountRoot);
}

function flushPendingInputs(container) {
  runtimeRoots(container || document).forEach(function flushRoot(root) {
    if (!root.hasAttribute("data-sb-pending-input")) return;

    const mountedRoot = mounted.get(root);
    const payload = mountedRoot && mountedRoot.payload;
    if (
      !payload ||
      isRuntimeInputPayload(payload) ||
      !payload.id ||
      !payload.binding ||
      !payload.binding.input
    ) {
      return;
    }

    const initialized = setInputValue(payload.id, currentValue(payload), "event");
    if (initialized) root.removeAttribute("data-sb-pending-input");
  });
}

function hasPendingInputs(container) {
  return runtimeRoots(container || document).some(function pendingRoot(root) {
    return root.hasAttribute("data-sb-pending-input");
  });
}

function schedulePendingInputFlush() {
  if (window.shinyblocksRuntimePendingInputFlushTimer) return;

  let attempts = 0;
  window.shinyblocksRuntimePendingInputFlushTimer = window.setInterval(function retryPendingInputs() {
    flushPendingInputs(document);
    attempts += 1;

    if (!hasPendingInputs(document) || attempts >= 200) {
      window.clearInterval(window.shinyblocksRuntimePendingInputFlushTimer);
      window.shinyblocksRuntimePendingInputFlushTimer = null;
    }
  }, 50);
}

function applyUpdate(message) {
  if (!message || !message.id) return;
  if (message.component === "select") return;
  if (!isFreshRevision(message.id, message.revision)) return;

  runtimeRoots(document).forEach(function updateRoot(root) {
    const mountedRoot = mounted.get(root);
    const payload = mountedRoot && mountedRoot.payload;
    if (!payload || payload.id !== message.id) return;

    payload.state ||= {};
    payload.props ||= {};

    Object.keys(message.updates || {}).forEach(function applyField(key) {
      const value = message.updates[key];
      if (key === "disabled") {
        root.toggleAttribute("data-disabled", Boolean(value));
      }
      if (key === "className") {
        payload.className = value;
        return;
      }
      if (
        key === "choices" ||
        key === "placeholder" ||
        key === "disabled" ||
        key === "width" ||
        key === "size" ||
        key === "invalid"
      ) {
        payload.props[key] = value;
      }
      payload.state[key] = value;
    });

    mountedRoot.reactRoot.render(<RuntimeMount payload={payload} root={root} />);

    if (message.notify && Object.prototype.hasOwnProperty.call(message.updates || {}, "value")) {
      setInputValue(message.id, message.updates.value, "event");
    }
  });
}

function registerUpdateHandler() {
  if (!window.Shiny || !window.Shiny.addCustomMessageHandler) return;
  if (window.shinyblocksRuntimeUpdateHandlerRegistered) return;

  window.Shiny.addCustomMessageHandler("sb:update", applyUpdate);
  window.shinyblocksRuntimeUpdateHandlerRegistered = true;
}

function observeDynamicUi() {
  if (window.shinyblocksRuntimeDynamicObserver) return;

  window.shinyblocksRuntimeDynamicObserver = new MutationObserver(function observeRecords(records) {
    records.forEach(function observeRecord(record) {
      Array.from(record.removedNodes).forEach(function removedNode(node) {
        if (node.nodeType !== Node.ELEMENT_NODE) return;
        if (node.matches && node.matches("[data-shinyblocks-runtime='true']")) {
          unmountRoot(node);
        }
        runtimeRoots(node).forEach(unmountRoot);
      });

      Array.from(record.addedNodes).forEach(function addedNode(node) {
        if (node.nodeType !== Node.ELEMENT_NODE) return;
        if (node.matches && node.matches("[data-shinyblocks-runtime='true']")) {
          mountRoot(node);
        }
        mountAll(node);
      });
    });
  });

  window.shinyblocksRuntimeDynamicObserver.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
}

function init() {
  registerRuntimeInputBindings();
  mountAll(document);
  observeDynamicUi();
  registerUpdateHandler();
  flushPendingInputs(document);
}

window.shinyblocksRuntime = {
  init,
  mountAll,
  applyUpdate
};

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init, { once: true });
} else {
  init();
}

document.addEventListener("shiny:connected", function connected() {
  registerRuntimeInputBindings();
  flushPendingInputs(document);
  schedulePendingInputFlush();
});
