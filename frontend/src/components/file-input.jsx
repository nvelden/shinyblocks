import { useEffect, useRef, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeFileInput } from "../runtime/native-inputs.js";
import { classNames, HtmlSlot } from "./shared.jsx";

function selectedFileText(nativeInput) {
  const files = nativeInput?.files ? Array.from(nativeInput.files) : [];
  if (!files.length) return "";
  if (files.length === 1) return files[0].name;
  return `${files.length} files`;
}

// Parse the native `accept` attribute into matcher tokens. Empty accepts all.
function fileMatchesAccept(file, acceptAttr) {
  const accept = (acceptAttr || "").trim();
  if (!accept) return true;
  const tokens = accept
    .split(",")
    .map((t) => t.trim().toLowerCase())
    .filter(Boolean);
  if (!tokens.length) return true;
  const name = (file.name || "").toLowerCase();
  const type = (file.type || "").toLowerCase();
  return tokens.some((token) => {
    if (token.startsWith(".")) return name.endsWith(token);
    if (token.endsWith("/*")) return type.startsWith(token.slice(0, -1));
    return type === token;
  });
}

// Optional dropzone icon: author markup (iconHtml) or a sprite reference
// (iconName + spriteHref), rendered inside a muted circle above the label.
function renderDropzoneIcon(state) {
  if (state.dropzoneIconHtml) {
    return (
      <HtmlSlot
        html={state.dropzoneIconHtml}
        className="sb-file-dropzone-icon"
        data-slot="file-dropzone-icon"
        aria-hidden="true"
      />
    );
  }
  if (state.dropzoneIconName) {
    return (
      <span
        className="sb-file-dropzone-icon"
        data-slot="file-dropzone-icon"
        aria-hidden="true"
      >
        <svg aria-hidden="true" focusable="false">
          <use href={`${state.spriteHref}#sb-icon-${state.dropzoneIconName}`} />
        </svg>
      </span>
    );
  }
  return null;
}

export function FileInput({ payload, root }) {
  const props = payload.props || {};
  const native = nativeFileInput(root);
  const [state, setState] = useState({
    variant: props.variant === "dropzone" ? "dropzone" : "button",
    buttonLabel: props.buttonLabel || "Browse",
    placeholder: props.placeholder || "",
    dropzoneLabel: props.dropzoneLabel ?? "Drag files here or click to browse",
    dropzoneHint: props.dropzoneHint ?? "",
    dropzoneIconName: props.dropzoneIconName ?? null,
    dropzoneIconHtml: props.dropzoneIconHtml ?? null,
    dropzoneContentHtml: props.dropzoneContentHtml ?? null,
    spriteHref: props.spriteHref ?? "",
    disabled: Boolean(props.disabled),
    invalid: Boolean(props.invalid),
    style: props.style || {},
    className: payload.className || ""
  });
  // Empty string means "no file selected"; the placeholder is shown instead.
  const [selectedText, setSelectedText] = useState("");
  const [dragover, setDragover] = useState(false);
  const dropRef = useRef(null);
  const rejectTimer = useRef(null);

  const inputId = native?.id || null;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = state.invalid || wrapperInvalid;
  const hasFiles = selectedText.length > 0;
  const displayText = hasFiles ? selectedText : state.placeholder;
  const hintId = inputId ? `${inputId}_dz_hint` : undefined;

  // Keep the native input's disabled state in sync with React state.
  useEffect(() => {
    if (native) native.disabled = state.disabled;
  }, [native, state.disabled]);

  // Mirror native file selection into the visible label.
  useEffect(() => {
    if (!native) return undefined;
    const handleChange = () => setSelectedText(selectedFileText(native));
    native.addEventListener("change", handleChange);
    handleChange();
    return () => native.removeEventListener("change", handleChange);
  }, [native]);

  useEffect(() => () => {
    if (rejectTimer.current) clearTimeout(rejectTimer.current);
  }, []);

  // Install the receiver used by `update_block_file_input()`.
  useEffect(() => {
    if (!root) return undefined;
    root.__sbFileInputReceive = (data) => {
      setState((prev) => {
        const next = { ...prev };
        if ("variant" in data) {
          next.variant = data.variant === "dropzone" ? "dropzone" : "button";
        }
        if ("buttonLabel" in data) next.buttonLabel = data.buttonLabel ?? "";
        if ("placeholder" in data) next.placeholder = data.placeholder ?? "";
        if ("dropzoneLabel" in data) next.dropzoneLabel = data.dropzoneLabel ?? "";
        if ("dropzoneHint" in data) next.dropzoneHint = data.dropzoneHint ?? "";
        if ("dropzoneIconName" in data) next.dropzoneIconName = data.dropzoneIconName ?? null;
        if ("dropzoneIconHtml" in data) next.dropzoneIconHtml = data.dropzoneIconHtml ?? null;
        if ("dropzoneContentHtml" in data) next.dropzoneContentHtml = data.dropzoneContentHtml ?? null;
        if ("spriteHref" in data) next.spriteHref = data.spriteHref ?? "";
        if ("disabled" in data) next.disabled = Boolean(data.disabled);
        if ("invalid" in data) next.invalid = Boolean(data.invalid);
        if ("style" in data) next.style = data.style || {};
        if ("className" in data) next.className = data.className || "";
        return next;
      });
      if (native) {
        if ("accept" in data) {
          if (data.accept == null || data.accept === "") native.removeAttribute("accept");
          else native.setAttribute("accept", data.accept);
        }
        if ("multiple" in data) {
          if (data.multiple) native.setAttribute("multiple", "");
          else native.removeAttribute("multiple");
        }
        if (data.reset) {
          native.value = "";
          setSelectedText("");
        }
      }
    };
    return () => {
      if (root.__sbFileInputReceive) delete root.__sbFileInputReceive;
    };
  }, [root, native]);

  function openPicker() {
    if (state.disabled || !native) return;
    native.click();
  }

  // Custom-content mode: the surface is a drop region, not a button, so only a
  // click landing on an explicit `[data-dropzone-trigger]` element opens the
  // picker. A real <button>/<a> trigger handles keyboard activation natively;
  // its click bubbles here. Plain surface clicks are inert (no nested-button
  // double-trigger).
  function handleTriggerClick(event) {
    if (state.disabled) return;
    const trigger =
      event.target && event.target.closest
        ? event.target.closest("[data-dropzone-trigger]")
        : null;
    if (trigger && dropRef.current && dropRef.current.contains(trigger)) {
      event.preventDefault();
      openPicker();
    }
  }

  function flashReject() {
    const el = dropRef.current;
    if (!el) return;
    el.setAttribute("data-reject", "true");
    if (rejectTimer.current) clearTimeout(rejectTimer.current);
    rejectTimer.current = setTimeout(() => {
      if (dropRef.current) dropRef.current.removeAttribute("data-reject");
    }, 600);
  }

  // Drop bridge (D2): `FileList` is immutable, so build a fresh DataTransfer
  // from the accepted files, assign it to the native input, and dispatch a
  // bubbling `change` so Shiny's native upload binding takes over unchanged.
  function handleDrop(event) {
    event.preventDefault();
    setDragover(false);
    if (state.disabled || !native) return;
    const dropped = Array.from(event.dataTransfer?.files || []);
    if (!dropped.length) return;
    const acceptAttr = native.getAttribute("accept") || "";
    let accepted = dropped.filter((file) => fileMatchesAccept(file, acceptAttr));
    if (!native.multiple) accepted = accepted.slice(0, 1);
    if (!accepted.length) {
      // Reject-all: keep the prior selection, no event, flash invalid pulse.
      flashReject();
      return;
    }
    const dt = new DataTransfer();
    accepted.forEach((file) => dt.items.add(file));
    native.files = dt.files;
    native.dispatchEvent(new Event("change", { bubbles: true }));
  }

  function handleDragOver(event) {
    if (state.disabled) return;
    event.preventDefault();
    setDragover(true);
  }

  function handleDragLeave(event) {
    // Ignore leaves bubbling from descendants still inside the dropzone.
    if (event.currentTarget.contains(event.relatedTarget)) return;
    setDragover(false);
  }

  function handleKeyDown(event) {
    if (event.key === "Enter" || event.key === " " || event.key === "Spacebar") {
      event.preventDefault();
      openPicker();
    }
  }

  if (state.variant === "dropzone") {
    const isCustom = Boolean(state.dropzoneContentHtml);
    const sharedProps = {
      ref: dropRef,
      className: classNames("sb-file-dropzone", state.className),
      "data-slot": "file-dropzone",
      "data-disabled": state.disabled ? "true" : undefined,
      "data-dragover": dragover ? "true" : undefined,
      "aria-invalid": isInvalid || undefined,
      "aria-controls": inputId || undefined,
      "aria-disabled": state.disabled || undefined,
      style: state.style,
      onDragOver: handleDragOver,
      onDragLeave: handleDragLeave,
      onDrop: handleDrop
    };
    // Always present so the aria-live filename summary can announce updates.
    const selectedSummary = (
      <span
        className="sb-file-dropzone-text"
        data-slot="file-input-text"
        data-placeholder={!hasFiles ? "true" : undefined}
        aria-live="polite"
      >
        {isCustom ? selectedText : displayText}
      </span>
    );

    if (isCustom) {
      // Drop region: author owns the interior; an explicit
      // `[data-dropzone-trigger]` element opens the picker (see handleTriggerClick).
      return (
        <div
          {...sharedProps}
          data-content="custom"
          role="group"
          aria-labelledby={labelledBy || undefined}
          aria-describedby={describedBy || undefined}
          onClick={handleTriggerClick}
        >
          <HtmlSlot
            html={state.dropzoneContentHtml}
            className="sb-file-dropzone-content"
            data-slot="file-dropzone-content"
          />
          {selectedSummary}
        </div>
      );
    }

    // Easy path: the whole surface is the picker button (click anywhere /
    // Enter-Space), optionally fronted by an icon above the label/hint.
    return (
      <div
        {...sharedProps}
        role="button"
        tabIndex={state.disabled ? -1 : 0}
        aria-labelledby={labelledBy || undefined}
        aria-describedby={[describedBy, state.dropzoneHint ? hintId : null]
          .filter(Boolean)
          .join(" ") || undefined}
        onClick={openPicker}
        onKeyDown={handleKeyDown}
      >
        {renderDropzoneIcon(state)}
        <span className="sb-file-dropzone-label" data-slot="file-dropzone-label">
          {state.dropzoneLabel || "Drag files here or click to browse"}
        </span>
        {state.dropzoneHint ? (
          <span
            id={hintId}
            className="sb-file-dropzone-hint"
            data-slot="file-dropzone-hint"
          >
            {state.dropzoneHint}
          </span>
        ) : null}
        {selectedSummary}
      </div>
    );
  }

  return (
    <div
      className={classNames("sb-file-input-control", state.className)}
      data-slot="file-input-control"
      data-disabled={state.disabled ? "true" : undefined}
      aria-invalid={isInvalid || undefined}
      style={state.style}
    >
      <button
        type="button"
        className="sb-file-input-button"
        data-slot="file-input-button"
        disabled={state.disabled}
        aria-controls={inputId || undefined}
        aria-labelledby={labelledBy || undefined}
        aria-describedby={describedBy}
        onClick={openPicker}
      >
        {state.buttonLabel || "Browse"}
      </button>
      <span
        className="sb-file-input-text"
        data-slot="file-input-text"
        data-placeholder={!hasFiles ? "true" : undefined}
        aria-live="polite"
      >
        {displayText}
      </span>
    </div>
  );
}
