import { classNames, HtmlSlot, passthroughAttrs } from "./shared.jsx";

export function Badge({ payload }) {
  const props = payload.props || {};
  const variant = props.variant || "default";
  const size = props.size || "default";

  return (
    <span
      data-slot="badge"
      data-variant={variant}
      data-size={size}
      className={classNames(
        "sb-badge",
        `sb-badge-${variant}`,
        `sb-badge-size-${size}`,
        payload.className
      )}
    >
      <HtmlSlot html={props.labelHtml} />
    </span>
  );
}

export function Separator({ payload }) {
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

export function Spinner({ payload }) {
  const props = payload.props || {};
  const size = props.size || "default";
  const color = props.color || "default";

  return (
    <svg
      data-slot="spinner"
      data-size={size}
      data-color={color}
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      strokeWidth="2"
      strokeLinecap="round"
      strokeLinejoin="round"
      className={classNames(
        "sb-spinner",
        `sb-spinner-size-${size}`,
        `sb-spinner-color-${color}`,
        payload.className
      )}
      role="status"
      aria-label={props.label || "Loading"}
    >
      <path d="M21 12a9 9 0 1 1-6.219-8.56" />
    </svg>
  );
}

export function Skeleton({ payload }) {
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

export function Empty({ payload }) {
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

export function ValueBox({ payload }) {
  const props = payload.props || {};
  const variant = props.variant || "default";
  const variantStyle = variant === "accent"
    ? {
      backgroundColor: "var(--accent)",
      borderLeft: "4px solid var(--accent-foreground)",
    }
    : variant === "destructive"
      ? { borderLeft: "4px solid var(--destructive)" }
      : {};

  return (
    <section
      data-slot="value-box"
      className={classNames("sb-value-box", `sb-value-box-${variant}`, payload.className)}
      style={variantStyle}
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

export function Alert({ payload }) {
  const props = payload.props || {};
  const variant = props.variant || "default";
  const actionStyle = {
    position: "absolute",
    top: "0.75rem",
    right: "1rem",
    display: "inline-flex",
    alignItems: "center",
    justifyContent: "flex-end"
  };

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
      style={props.actionHtml ? { paddingRight: "7rem" } : undefined}
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
      {props.actionHtml && (
        <div
          className="sb-alert-action"
          data-slot="alert-action"
          style={actionStyle}
          dangerouslySetInnerHTML={{ __html: props.actionHtml }}
        />
      )}
    </div>
  );
}
