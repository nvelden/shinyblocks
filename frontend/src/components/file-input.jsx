import { useEffect, useState } from "react";
import { labelIdForInput } from "../runtime/dom.js";
import { nativeFileInput } from "../runtime/native-inputs.js";
import { classNames } from "./shared.jsx";

function selectedFileText(nativeInput) {
  const files = nativeInput?.files ? Array.from(nativeInput.files) : [];
  if (!files.length) return "";
  if (files.length === 1) return files[0].name;
  return `${files.length} files`;
}

export function FileInput({ payload, root }) {
  const props = payload.props || {};
  const native = nativeFileInput(root);
  const [state, setState] = useState({
    buttonLabel: props.buttonLabel || "Browse",
    placeholder: props.placeholder || "",
    disabled: Boolean(props.disabled),
    invalid: Boolean(props.invalid),
    style: props.style || {},
    className: payload.className || ""
  });
  // Empty string means "no file selected"; the placeholder is shown instead.
  const [selectedText, setSelectedText] = useState("");

  const inputId = native?.id || null;
  const labelledBy = inputId ? labelIdForInput(inputId) : null;
  const describedBy = root?.getAttribute("aria-describedby") || undefined;
  const wrapperInvalid = root?.getAttribute("aria-invalid") === "true";
  const isInvalid = state.invalid || wrapperInvalid;
  const hasFiles = selectedText.length > 0;
  const displayText = hasFiles ? selectedText : state.placeholder;

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

  // Install the receiver used by `update_block_file_input()`.
  useEffect(() => {
    if (!root) return undefined;
    root.__sbFileInputReceive = (data) => {
      setState((prev) => {
        const next = { ...prev };
        if ("buttonLabel" in data) next.buttonLabel = data.buttonLabel ?? "";
        if ("placeholder" in data) next.placeholder = data.placeholder ?? "";
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

  function handleClick() {
    if (state.disabled || !native) return;
    native.click();
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
        onClick={handleClick}
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
