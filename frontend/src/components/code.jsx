import { useEffect, useRef, useState } from "react";
import { highlightCodeLine } from "../highlighting/code.jsx";
import { classNames } from "./shared.jsx";

export function Code({ payload }) {
  const props = payload.props || {};
  const [copied, setCopied] = useState(false);
  const copyTimer = useRef(null);

  useEffect(
    () => () => {
      if (copyTimer.current) clearTimeout(copyTimer.current);
    },
    []
  );

  const handleCopy = () => {
    if (!props.code) return;
    const clipboard = window.navigator && window.navigator.clipboard;
    if (!clipboard) return;
    clipboard
      .writeText(props.code)
      .then(() => {
        setCopied(true);
        if (copyTimer.current) clearTimeout(copyTimer.current);
        copyTimer.current = setTimeout(() => setCopied(false), 2000);
      })
      .catch(() => {
        // writeText() rejects in insecure contexts or when the user denies
        // clipboard permission; swallow it rather than leak an unhandled
        // rejection and leave the button in its default state.
      });
  };

  const hasHeader = props.header === true;
  const isCopyable = props.copyable !== false;
  const isLineNumbers = props.line_numbers !== false;
  const variant = props.variant || "default";

  const lines = (props.code || "").split("\n");
  if (lines.length > 1 && lines[lines.length - 1] === "") {
    lines.pop();
  }

  return (
    <figure
      data-slot="code"
      data-variant={variant}
      className={classNames(
        "sb-code-block",
        `sb-code-block-${variant}`,
        hasHeader && "sb-code-block-with-header",
        payload.className
      )}
    >
      {hasHeader && (
        <div className="sb-code-block-header">
          <div className="sb-code-block-dots">
            <span className="sb-code-block-dot sb-code-block-dot-red" />
            <span className="sb-code-block-dot sb-code-block-dot-yellow" />
            <span className="sb-code-block-dot sb-code-block-dot-green" />
          </div>
          <div className="sb-code-block-header-right">
            {props.language && (
              <span className="sb-code-block-lang">{props.language}</span>
            )}
            {isCopyable && (
              <button
                type="button"
                className="sb-code-block-copy-btn"
                onClick={handleCopy}
                aria-label={copied ? "Copied" : "Copy code"}
                title={copied ? "Copied" : "Copy code"}
                data-copied={copied ? "true" : "false"}
              >
                {copied ? (
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="sb-code-block-icon-check">
                    <polyline points="20 6 9 17 4 12" />
                  </svg>
                ) : (
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="sb-code-block-icon-copy">
                    <rect x="9" y="9" width="13" height="13" rx="2" ry="2" />
                    <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1" />
                  </svg>
                )}
              </button>
            )}
          </div>
        </div>
      )}

      {!hasHeader && isCopyable && (
        <button
          type="button"
          className="sb-code-block-copy-btn sb-code-block-copy-absolute"
          onClick={handleCopy}
          aria-label={copied ? "Copied" : "Copy code"}
          title={copied ? "Copied" : "Copy code"}
          data-copied={copied ? "true" : "false"}
        >
          {copied ? (
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" className="sb-code-block-icon-check">
              <path d="M5 12l5 5l10 -10" />
            </svg>
          ) : (
            <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="sb-code-block-icon-copy">
              <path d="M7 7m0 2.667a2.667 2.667 0 0 1 2.667 -2.667h8.666a2.667 2.667 0 0 1 2.667 2.667v8.666a2.667 2.667 0 0 1 -2.667 2.667h-8.666a2.667 2.667 0 0 1 -2.667 -2.667z" />
              <path d="M4.012 16.737a2.005 2.005 0 0 1 -1.012 -1.737v-10c0 -1.1 .9 -2 2 -2h10c.75 0 1.158 .385 1.5 1" />
            </svg>
          )}
        </button>
      )}

      <pre className="sb-code-block-pre">
        <code
          className="sb-code-block-code"
          data-line-numbers={isLineNumbers ? "" : undefined}
          tabIndex={0}
        >
          {lines.map((line, idx) => (
            <span key={idx} className="sb-code-block-line" data-line="">
              {highlightCodeLine(line, props.language)}
            </span>
          ))}
        </code>
      </pre>
    </figure>
  );
}
