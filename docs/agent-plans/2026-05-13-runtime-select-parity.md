---
title: Runtime Select parity plan
date: 2026-05-13
status: development-ready
---

# Goal

Replace the current native-`<select>`-based runtime Select with a
package-owned custom Select that:

1. Matches shadcn/Radix Select visually and behaviorally in light
   mode, dark mode, closed state, and open dropdown state.
2. Integrates with Shiny the way `shiny::selectInput()` integrates
   with Bootstrap: hidden native `<select>` as the value source of
   truth, a registered `Shiny.InputBinding`, and
   `session$sendInputMessage()` for server updates.

The Shiny developer mental model is preserved: `input$<id>` is the
value of a real DOM element, `updateSelectInput()`-shaped APIs work,
`<label for="...">` focuses the form control, modules namespace
correctly, and bookmarking round-trips.

# Assumptions

- ADR 0017 governs the architecture: form wrappers are migration
  scaffolding, and migrated shadcn controls live in the
  package-local runtime.
- `block_select()` keeps its public API unless explicitly listed
  under "Proposed API" below.
- First parity target is single-select only.
- Choice labels are plain text. HTML labels are deferred (escaping,
  accessibility, XSS).
- Choice values must be unique; duplicates fail at R.
- Empty string `""` is reserved as the placeholder/clear sentinel
  and is not a valid choice value.
- No per-item disabled options in v1.
- Page-level dark mode only in v1: `data-theme="dark"` lives on
  `html` or `body`.
- The hidden native `<select>` is the canonical Shiny value source.
  It is not a fallback. The custom React UI is a controlled overlay.
- Select participates in the Shiny input lifecycle via a real
  `Shiny.InputBinding` (`shinyblocks.select`), not via the global
  `sb:update` custom-message bus.
- Server updates dispatch through `session$sendInputMessage()`.
- No fallback code paths; no positioning library unless the local
  implementation proves insufficient.
- Manual browser approval remains the gate before the next
  component.

# Proposed API

`block_select()` — signature unchanged:

```r
block_select(
  input_id,
  choices,
  selected = NULL,
  placeholder = NULL,
  disabled = FALSE,
  width = NULL,
  class = NULL,
  size = c("default", "sm", "lg"),
  style = NULL,
  invalid = FALSE
)
```

`update_block_select()` — reordered to match
`shiny::updateSelectInput()` ergonomics; `notify` defaults to `TRUE`
for parity with `updateSelectInput()`:

```r
update_block_select(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  choices,
  selected,
  placeholder,
  disabled,
  width,
  class,
  size,
  invalid,
  notify = TRUE
)
```

Tighten:

- Reject duplicate choice values in `block_select()` and
  `update_block_select()`.
- Reject `""` as a choice value (it is the placeholder sentinel).
- Validate `width` with `htmltools::validateCssUnit()`.
- `selected = NULL` continues to clear to the placeholder state.
  Documented behavior.
- `selected` updates fire `input$<id>` by default. Cosmetic-only
  updates (`width`, `class`, `style`, `size`, `invalid`,
  `placeholder`, `disabled`) never fire the input event regardless
  of `notify`.

Do not add: multi-select, searchable combobox, grouped choices, HTML
labels, per-item disabled, generic overlay library, or native
mobile-picker compatibility.

# Architecture overview

```
+--------------------------------------------------------+
|  R: block_select(input_id = "x", choices = c(...))     |
|     -> runtime_component("select", ..., input_id, ...) |
|     -> emits payload + hidden <select id="x">          |
+--------------------------------------------------------+
                          |
                          v
+--------------------------------------------------------+
|  DOM at render time                                    |
|  <div data-shinyblocks-runtime="true"                  |
|       data-sb-component="select"                       |
|       data-sb-input-id="x">                            |
|    <script data-shinyblocks-payload>...</script>       |
|    <div data-shinyblocks-react></div>     <- React UI  |
|    <select id="x" class="sb-select-native"             |
|            tabindex="-1" aria-hidden="true">           |
|      <option value="free">Free</option>...             |
|    </select>                                           |
|  </div>                                                |
+--------------------------------------------------------+
                          |
                          v
+--------------------------------------------------------+
|  JS runtime                                            |
|  - React mounts overlay into data-shinyblocks-react.   |
|  - ShinyblocksSelectBinding extends Shiny.InputBinding |
|    and is registered as "shinyblocks.select".          |
|  - getValue(el) = el.querySelector(".sb-select-native")|
|                     .value                             |
|  - subscribe(el, cb): listen "change.shinyblocks.select|
|    " on the hidden <select>.                           |
|  - User picks an item -> overlay updates hidden        |
|    <select>.value -> dispatches change event -> cb     |
|    fires -> Shiny reads input$x.                       |
|  - receiveMessage(el, data): consumes flat payload     |
|    {choices, selected, placeholder, disabled, ...}.    |
+--------------------------------------------------------+
                          |
                          v
+--------------------------------------------------------+
|  R: update_block_select(session, "x", choices = ...,   |
|                         selected = "pro")              |
|     -> session$sendInputMessage(session$ns("x"),       |
|                                 flat_payload)          |
|     -> Shiny routes to receiveMessage of the           |
|        registered binding.                             |
+--------------------------------------------------------+
```

# DOM contract

Root (rendered by `runtime_component()` already; existing shape kept):

```html
<div id="sb-runtime-select-{slug}"
     class="sb-runtime-mount {user_class}"
     style="{user_style}"
     data-shinyblocks-root=""
     data-shinyblocks-runtime="true"
     data-sb-component="select"
     data-sb-input-id="{input_id}">
  <script type="application/json" data-shinyblocks-payload>...</script>
  <div data-shinyblocks-react></div>
  <select id="{input_id}"
          class="sb-select-native"
          tabindex="-1"
          aria-hidden="true">
    <option value="free">Free</option>
    <option value="pro">Pro</option>
  </select>
  <div data-shinyblocks-children=""></div>
</div>
```

Overlay (rendered by React inside `data-shinyblocks-react`):

```html
<button id="{input_id}-trigger"
        type="button"
        class="sb-select-trigger sb-select-size-{size}"
        data-slot="select-trigger"
        role="combobox"
        aria-haspopup="listbox"
        aria-expanded="false"
        aria-controls="{contentId}"
        aria-invalid="{invalid}"
        data-state="closed"
        data-placeholder="{boolean}"
        data-size="{size}"
        data-invalid="{invalid}"
        disabled?>
  <span class="sb-select-trigger-value">Free</span>
  <svg class="sb-select-trigger-icon" aria-hidden="true">
    <use href="{spriteHref}#sb-icon-chevron-down"/>
  </svg>
</button>
```

Portal content (rendered into `[data-shinyblocks-portal-root]` when
open):

```html
<div class="sb-select-content"
     data-slot="select-content"
     role="listbox"
     id="{contentId}"
     aria-activedescendant="{itemId}"
     data-state="open"
     style="position: fixed; top: ...; left: ...; min-width: ...;">
  <div class="sb-select-viewport" data-slot="select-viewport">
    <div class="sb-select-item"
         data-slot="select-item"
         role="option"
         id="{itemId}"
         aria-selected="true"
         data-highlighted?
         data-state="checked">
      <span class="sb-select-item-indicator" aria-hidden="true">
        <svg><use href="{spriteHref}#sb-icon-check"/></svg>
      </span>
      <span class="sb-select-item-text">Free</span>
    </div>
    <!-- more items -->
  </div>
</div>
```

ID conventions (deterministic, derivable from `input_id`):

- mount node: `sb-runtime-select-{slug(input_id)}` (already
  generated by `runtime_mount_id()`).
- hidden control: `{input_id}` (the Shiny id — must match exactly).
- trigger: `{input_id}-trigger`.
- content: `{input_id}-content`.
- item: `{input_id}-item-{i}` for `i` in zero-based index.

# Shiny binding contract

Single source of truth: hidden `<select id="{input_id}">`.

`frontend/src/bindings/select.js` (new file; re-exported from
`index.jsx`):

```js
class ShinyblocksSelectBinding extends Shiny.InputBinding {
  find(scope) {
    const selector = '[data-shinyblocks-runtime="true"][data-sb-component="select"]';
    const scoped = $(scope);
    return scoped.is(selector) ? scoped.add(scoped.find(selector)) : scoped.find(selector);
  }
  getId(el) {
    return el.dataset.sbInputId;
  }
  getType() {
    return "shinyblocks.select";
  }
  getValue(el) {
    const native = el.querySelector(".sb-select-native");
    return native ? native.value : null;
  }
  setValue(el, value) {
    const native = el.querySelector(".sb-select-native");
    if (!native) return;
    native.value = value == null ? "" : String(value);
    // No event dispatch here; setValue is used by Shiny to seed
    // state, not to fire a callback.
  }
  subscribe(el, callback) {
    const native = el.querySelector(".sb-select-native");
    if (!native) return;
    const handler = () => callback(true);
    native.addEventListener("change", handler);
    el.__sbSelectChangeHandler = handler;
  }
  unsubscribe(el) {
    const native = el.querySelector(".sb-select-native");
    if (!native || !el.__sbSelectChangeHandler) return;
    native.removeEventListener("change", el.__sbSelectChangeHandler);
    delete el.__sbSelectChangeHandler;
  }
  receiveMessage(el, data) {
    // Flat payload: { choices, selected, placeholder, disabled,
    //                 width, class, size, invalid }
    // Forward to the React overlay through a registered callback
    // installed at mount time. The overlay owns visual state; the
    // binding owns the value source and the Shiny event.
    const apply = el.__sbSelectReceive;
    if (typeof apply === "function") apply(data);
  }
  getRatePolicy() {
    return null;
  }
}

if (window.Shiny && window.Shiny.inputBindings) {
  Shiny.inputBindings.register(
    new ShinyblocksSelectBinding(),
    "shinyblocks.select"
  );
}
```

Lifecycle rules:

- The binding is the *only* path that publishes `input$<id>` for
  Select. The React Select component must not call
  `Shiny.setInputValue()` directly.
- The binding's `find(scope)` must include `scope` itself when the
  scope is the runtime root. This matters because dynamic Shiny UI
  often calls binding discovery on the inserted root, not only on an
  ancestor.
- `mountRoot()` in `index.jsx` must skip the existing
  initial-value publish path *for Select* (`payload.component ===
  "select"`); the binding's `getValue()` is the canonical
  handshake.
- `applyUpdate()` in `index.jsx` must early-return for messages
  whose `component` field is `"select"` (defense in depth — R
  should not be sending such messages once `update_block_select()`
  is rerouted).
- On unmount (`unmountRoot()`), call `Shiny.unbindAll(root)` before
  the React unmount so the binding cleans up its event listener. Do
  not rely on the existing child-only binding helper for Select;
  the Select input binding is attached to the runtime root itself.
- Keep `bindShinyChildren()` / `unbindShinyChildren()` for nested
  Shiny children, htmlwidgets, and outputs, but do not treat those
  helpers as the Select input lifecycle.

# R-side data flow

`update_block_select()` rewrite — file: `R/select.R`. Replaces the
current `do.call(runtime_update, ...)` block.

```r
update_block_select <- function(
  session = shiny::getDefaultReactiveDomain(),
  input_id,
  choices,
  selected,
  placeholder,
  disabled,
  width,
  class,
  size,
  invalid,
  notify = TRUE
) {
  validate_input_id(input_id)

  payload <- list()

  if (!missing(choices)) {
    choices_df <- normalize_choices(choices)
    validate_select_choice_values(choices_df$value)
    payload$choices <- runtime_choice_records(choices_df)

    if (
      !missing(selected) &&
        !is.null(selected) &&
        !selected %in% choices_df$value
    ) {
      stop("`selected` must match one of `choices`.", call. = FALSE)
    }
  }

  if (!missing(selected)) {
    payload$selected <- selected %||% ""
  }
  if (!missing(placeholder)) {
    payload$placeholder <- placeholder
  }
  if (!missing(disabled)) {
    payload$disabled <- isTRUE(disabled)
  }
  if (!missing(width)) {
    payload$width <- if (is.null(width)) NULL else htmltools::validateCssUnit(width)
  }
  if (!missing(class)) {
    payload$class <- class
  }
  if (!missing(size)) {
    payload$size <- match_arg(size, c("default", "sm", "lg"))
  }
  if (!missing(invalid)) {
    payload$invalid <- isTRUE(invalid)
  }

  payload$notify <- isTRUE(notify) && "selected" %in% names(payload)

  session$sendInputMessage(session$ns(input_id), payload)
  invisible(NULL)
}
```

Notes:

- This bypasses `runtime_update()` entirely for Select. Other
  stateful components keep their existing path until they migrate.
- `payload$notify` is `TRUE` only when `selected` is present and the
  caller did not opt out — so cosmetic updates never trigger
  `input$<id>` even with `notify = TRUE`.
- The React `receiveMessage` handler reads `payload.notify` and
  decides whether to dispatch `change` on the hidden `<select>`
  after applying `selected`.

# Validator

`R/utils.R` — add at the bottom:

```r
validate_select_choice_values <- function(values) {
  if (any(!nzchar(values))) {
    stop(
      "`choices` values must be non-empty. `\"\"` is reserved as the placeholder sentinel.",
      call. = FALSE
    )
  }

  dupes <- unique(values[duplicated(values)])
  if (length(dupes) > 0) {
    stop(
      sprintf(
        "`choices` values must be unique. Duplicates: %s.",
        paste(sprintf('"%s"', dupes), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  invisible(values)
}
```

Call it from `block_select()` (right after `normalize_choices()`) and
from `update_block_select()` (right after `normalize_choices()` when
`choices` is supplied).

# `block_select()` rewrite — `R/select.R`

```r
block_select <- function(
  input_id,
  choices,
  selected = NULL,
  placeholder = NULL,
  disabled = FALSE,
  width = NULL,
  class = NULL,
  size = c("default", "sm", "lg"),
  style = NULL,
  invalid = FALSE
) {
  validate_input_id(input_id)
  size <- match_arg(size, c("default", "sm", "lg"))
  choices_df <- normalize_choices(choices)
  validate_select_choice_values(choices_df$value)
  choice_values <- choices_df$value

  if (!is.null(selected) && !selected %in% choice_values) {
    stop("`selected` must match one of `choices`.", call. = FALSE)
  }
  selected_value <- selected %||% if (is.null(placeholder)) choice_values[[1]] else ""

  width_value <- if (is.null(width)) "100%" else htmltools::validateCssUnit(width)

  hidden_native <- htmltools::tags$select(
    id = input_id,
    class = "sb-select-native",
    tabindex = "-1",
    `aria-hidden` = "true",
    lapply(seq_len(nrow(choices_df)), function(i) {
      htmltools::tags$option(
        value = choices_df$value[[i]],
        selected = if (identical(choices_df$value[[i]], selected_value)) NA else NULL,
        choices_df$label[[i]]
      )
    })
  )

  runtime_component(
    component = "select",
    props = list(
      choices = runtime_choice_records(choices_df),
      placeholder = placeholder,
      disabled = isTRUE(disabled),
      width = width_value,
      style = normalize_runtime_style(style),
      size = size,
      invalid = isTRUE(invalid)
    ),
    input_id = input_id,
    state = list(value = selected_value),
    binding = list(input = TRUE, type = "shinyblocks.select"),
    class = class,
    children = list(hidden_native)
  )
}
```

The hidden `<select>` rides in `children` so it lands inside
`[data-shinyblocks-children]` and is reachable from
`el.querySelector(".sb-select-native")`. If a future change moves
the hidden control out of the children slot, update both the
binding's `getValue()`/`subscribe()` selectors and the CSS hide
rule.

# React overlay

File: `frontend/src/index.jsx`. Replaces the existing `Select`
component. Pseudocode:

```jsx
function Select({ payload, root }) {
  const props = payload.props || {};
  const state = payload.state || {};
  const inputId = payload.id;

  const [choices, setChoices] = useState(props.choices || []);
  const [value, setValue] = useState(state.value ?? "");
  const [placeholder, setPlaceholder] = useState(props.placeholder ?? "");
  const [disabled, setDisabled] = useState(Boolean(props.disabled));
  const [invalid, setInvalid] = useState(Boolean(props.invalid));
  const [size, setSize] = useState(props.size || "default");
  const [width, setWidth] = useState(props.width || "100%");
  const [extraClass, setExtraClass] = useState(payload.className || "");
  const [open, setOpen] = useState(false);
  const [highlighted, setHighlighted] = useState(-1);

  const triggerRef = useRef(null);
  const contentRef = useRef(null);

  // Install the receiveMessage bridge so the binding can hand off
  // server updates into React state.
  useEffect(() => {
    root.__sbSelectReceive = (data) => {
      if ("choices" in data) {
        setChoices(data.choices);
        setOpen(false);
        setHighlighted(-1);
        // Reconcile hidden <select> options before applying value.
        syncHiddenOptions(root, data.choices);
      }
      if ("selected" in data) {
        const next = data.selected ?? "";
        setValue(next);
        const native = root.querySelector(".sb-select-native");
        if (native) {
          native.value = next;
          if (data.notify) {
            native.dispatchEvent(new Event("change", { bubbles: true }));
          }
        }
      }
      if ("placeholder" in data) setPlaceholder(data.placeholder ?? "");
      if ("disabled" in data) {
        setDisabled(Boolean(data.disabled));
        const native = root.querySelector(".sb-select-native");
        if (native) native.disabled = Boolean(data.disabled);
      }
      if ("width" in data) setWidth(data.width || "100%");
      if ("class" in data) setExtraClass(data.class || "");
      if ("size" in data) setSize(data.size || "default");
      if ("invalid" in data) setInvalid(Boolean(data.invalid));
    };
    return () => { delete root.__sbSelectReceive; };
  }, [root]);

  const commit = (next) => {
    setValue(next);
    setOpen(false);
    setHighlighted(-1);
    const native = root.querySelector(".sb-select-native");
    if (native) {
      native.value = next;
      native.dispatchEvent(new Event("change", { bubbles: true }));
    }
    requestAnimationFrame(() => triggerRef.current?.focus());
  };

  // Open / close logic, keyboard handlers, outside pointerdown,
  // scroll-into-view of highlighted on open: see Interaction Contract.

  return (
    <>
      <button
        ref={triggerRef}
        id={`${inputId}-trigger`}
        type="button"
        className={classNames(
          "sb-select-trigger",
          `sb-select-size-${size}`,
          extraClass
        )}
        data-slot="select-trigger"
        role="combobox"
        aria-haspopup="listbox"
        aria-expanded={open}
        aria-controls={`${inputId}-content`}
        aria-invalid={invalid || undefined}
        data-state={open ? "open" : "closed"}
        data-placeholder={!value ? "true" : undefined}
        data-size={size}
        data-invalid={invalid ? "true" : undefined}
        disabled={disabled}
        style={{ width }}
        onClick={() => !disabled && setOpen((o) => !o)}
        onKeyDown={onTriggerKeyDown}
      >
        <span className="sb-select-trigger-value">
          {labelFor(value, choices) || placeholder || ""}
        </span>
        <svg className="sb-select-trigger-icon" aria-hidden="true">
          <use href={`${props.spriteHref}#sb-icon-chevron-down`} />
        </svg>
      </button>

      {open && <SelectContent ... />}
    </>
  );
}
```

`SelectContent` is rendered through `ReactDOM.createPortal()` into
`[data-shinyblocks-portal-root]`, positioned with `position: fixed`
using `triggerRef.current.getBoundingClientRect()`, with
`min-width` equal to the trigger width. No collision logic in v1.

`syncHiddenOptions(root, choices)` rewrites the hidden `<select>`'s
options to match the new choice set, preserving the canonical value
source.

The label-forwarding handler — installed once, also in `mountRoot()`
or at binding registration time:

```js
function forwardNativeFocusToTrigger(root) {
  const native = root.querySelector(".sb-select-native");
  if (!native) return;
  native.addEventListener("focus", () => {
    const trigger = root.querySelector(".sb-select-trigger");
    if (trigger && !trigger.disabled) trigger.focus();
  });
}
```

# CSS

File: `frontend/src/styles/runtime.css`. Replace the entire
`.sb-select*` block (lines 257-323 in the current file) with:

```css
[data-shinyblocks-root] .sb-select-native {
  position: absolute;
  width: 1px;
  height: 1px;
  margin: -1px;
  padding: 0;
  border: 0;
  overflow: hidden;
  clip: rect(0 0 0 0);
  clip-path: inset(50%);
  white-space: nowrap;
}

[data-shinyblocks-root] .sb-select-trigger {
  display: inline-flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  gap: 0.5rem;
  border: 1px solid var(--input);
  border-radius: calc(var(--radius) * 0.8);
  background-color: var(--background);
  color: var(--foreground);
  font-size: 0.875rem;
  line-height: 1.25rem;
  padding-inline: 0.75rem 0.5rem;
  box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  outline: none;
  cursor: pointer;
  transition: color 0.15s, border-color 0.15s, box-shadow 0.15s;
}

[data-shinyblocks-root] .sb-select-trigger[data-placeholder="true"] {
  color: var(--muted-foreground);
}

[data-shinyblocks-root] .sb-select-trigger:focus-visible,
[data-shinyblocks-root] .sb-select-trigger[data-state="open"] {
  border-color: var(--ring);
  box-shadow: 0 0 0 3px color-mix(in oklch, var(--ring) 50%, transparent);
}

[data-shinyblocks-root] .sb-select-trigger[data-invalid="true"] {
  border-color: var(--destructive);
  box-shadow: 0 0 0 3px color-mix(in oklch, var(--destructive) 20%, transparent);
}

[data-shinyblocks-root] .sb-select-trigger:disabled {
  cursor: not-allowed;
  opacity: 0.5;
}

[data-shinyblocks-root] .sb-select-size-default { height: 2.25rem; }
[data-shinyblocks-root] .sb-select-size-sm      { height: 2rem;    padding-inline: 0.625rem 0.5rem; }
[data-shinyblocks-root] .sb-select-size-lg      { height: 2.5rem;  padding-inline: 1rem 0.5rem; }

[data-shinyblocks-root] .sb-select-trigger-icon {
  width: 1rem;
  height: 1rem;
  opacity: 0.5;
  pointer-events: none;
  flex-shrink: 0;
}

[data-shinyblocks-portal-root] .sb-select-content {
  z-index: 50;
  min-width: 8rem;
  overflow: hidden;
  border: 1px solid var(--border);
  border-radius: calc(var(--radius) * 0.8);
  background-color: var(--popover);
  color: var(--popover-foreground);
  box-shadow:
    0 10px 15px -3px rgb(0 0 0 / 0.1),
    0 4px 6px -4px rgb(0 0 0 / 0.1);
  padding: 0.25rem;
}

[data-shinyblocks-portal-root] .sb-select-viewport {
  max-height: 384px;
  overflow-y: auto;
  padding: 0.25rem 0;
}

[data-shinyblocks-portal-root] .sb-select-item {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  position: relative;
  padding: 0.375rem 2rem 0.375rem 0.5rem;
  font-size: 0.875rem;
  line-height: 1.25rem;
  border-radius: calc(var(--radius) * 0.5);
  cursor: pointer;
  user-select: none;
  outline: none;
}

[data-shinyblocks-portal-root] .sb-select-item[data-highlighted] {
  background-color: var(--accent);
  color: var(--accent-foreground);
}

[data-shinyblocks-portal-root] .sb-select-item-indicator {
  position: absolute;
  right: 0.5rem;
  width: 1rem;
  height: 1rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

[data-shinyblocks-portal-root] .sb-select-item:not([aria-selected="true"]) .sb-select-item-indicator {
  visibility: hidden;
}
```

CSS budget: ADR 0017 Phase 2 ceiling is 8 KB raw / 2 KB gzip. After
`npm run build:runtime`, record the delta. If we exceed, update ADR
0017 in the same PR.

# Files to edit — checklist

- [ ] `R/utils.R` — add `validate_select_choice_values()`.
- [ ] `R/select.R` — rewrite `block_select()` and
      `update_block_select()` per sketches above; emit hidden
      native control; route updates through `sendInputMessage()`.
- [ ] `frontend/src/index.jsx` — replace the `Select` React
      component with the overlay+portal design; register
      `ShinyblocksSelectBinding`; guard `mountRoot()` and
      `applyUpdate()` so they skip Select's input handshake; call
      `Shiny.unbindAll(root)` before React unmount for Select-bound
      roots.
- [ ] `frontend/src/styles/runtime.css` — replace the
      `.sb-select*` block (existing lines ~257-323) with the new
      rule set; add `.sb-select-native` visually-hidden style.
- [ ] `frontend/src/bindings/select.js` — new file (or co-located
      with `index.jsx`) for `ShinyblocksSelectBinding`. Keep it
      importable so future per-component bindings can follow the
      same layout.
- [ ] `inst/www/shinyblocks-runtime.js` and
      `inst/www/shinyblocks-runtime.css` — regenerated by
      `npm run build:runtime`. Do not hand-edit.
- [ ] `inst/showcase/R/examples/select.R` — remove the
      `c("<None>" = "", ...)` example (now invalid); add a
      module-namespacing example; add explicit "open in dark mode"
      panel; preserve the button/select playground structure with
      Preview, UI Definition source, Server Action source, grouped
      Data/State/Styling/Actions controls, value readback, and API
      Reference table.
- [ ] `inst/showcase/R/server_select.R` — update reactive code
      strings to reflect the new `update_block_select()` signature;
      drop `notify = TRUE` from the examples that change `selected`
      because it is now the default; keep the generated preview source,
      server action source, and API table in sync with the actual
      runtime behavior.
- [ ] `inst/showcase/www/` — decide before merge whether generated
      assets here are committed or `.gitignore`'d. Resolve the
      untracked state shown by `git status`.
- [ ] `docs/component-specs/select.md` — replace the "native
      select" wording; document the binding contract; list the
      stable `.sb-select-*` classes.
- [ ] `docs/component-specs/_parity/select.json` — recapture
      values for trigger, content, item, in both themes.
- [ ] `tools/parity/registry.mjs` — change `showcaseUrl` to
      `http://127.0.0.1:4321/#select`; change `showcaseReadySelector`
      to `[data-sb-section="select"]:not([hidden])`; split into
      `SELECT_TRIGGER_PROPS`, `SELECT_CONTENT_PROPS`,
      `SELECT_ITEM_PROPS`; replace `.selectize-*` selectors with
      `[data-slot="select-trigger"]`,
      `[data-shinyblocks-portal-root] [data-slot="select-content"]`,
      `[data-shinyblocks-portal-root] [data-slot="select-item"]`;
      replace `prepareSelectOpenState` so it clicks the new
      trigger and waits for `[data-slot="select-content"]`.
- [ ] `tools/parity/select-poc.mjs` — delete. Registry-driven
      capture covers it.
- [ ] `tools/drift/shadcn-source.mjs` and
      `tools/drift/check-shadcn-source.mjs` — new maintainer-side
      drift-detection scripts (see "Drift detection" below).
- [ ] `docs/component-specs/_parity/select.shadcn-source.json` —
      new pinned shadcn source snapshot.
- [ ] `package.json` — add `drift:capture` and `drift:check`
      scripts.
- [ ] `.github/workflows/ci.yml` — add a required `parity-select`
      job and an informational `drift-check` job (see "Drift
      detection" below).
- [ ] `tests/testthat/test-shell.R` — see "Required R tests" below.
- [ ] `tests/testthat/test-utils.R` — add validator tests.
- [ ] `tests/testthat/test-runtime-update.R` — add tests for the
      new `sendInputMessage()` path; existing `runtime_update()`
      tests stay for non-Select components.
- [ ] `tests/testthat/test-runtime-css.R` — assert the new
      `.sb-select-*` selectors and the absence of `.sb-select-control`.
- [ ] Browser/runtime tests under the npm suite — see "Required
      browser tests" below.
- [ ] `NEWS.md` — single bullet describing the rewrite and the new
      `shinyblocks.select` binding.
- [ ] ADR 0017 — only if the CSS bundle exceeds 8 KB raw / 2 KB
      gzip after `npm run build:runtime`. Record the new ceiling
      with the before/after numbers in the same PR.

# Implementation order

1. **Validator + R-side rewrite** (`R/utils.R`, `R/select.R`).
   Run `Rscript -e "devtools::test(filter='utils|shell')"` until
   green. No browser work yet.
2. **Hidden native control in the rendered HTML.** Confirm
   `render_html(block_select(...))` contains
   `<select id="..." class="sb-select-native"`. Snapshot in
   `test-shell.R`.
3. **JS binding skeleton.** Land `ShinyblocksSelectBinding` and the
   `mountRoot()`/`applyUpdate()` guards before changing the React
   Select UI. Confirm `Shiny.inputBindings.bindings` contains the
   registered binding and that `getValue()` reads the hidden
   `<select>`. Confirm binding discovery works when the discovery
   scope is the runtime root itself. The page still looks like a
   native select at this point; only the value-source plumbing
   changed.
4. **React overlay.** Build the trigger, content, item, indicator,
   and keyboard handlers. Wire commits to `change` on the hidden
   `<select>`. Visual parity arrives here.
5. **`update_block_select()` via `sendInputMessage()`.** Hook
   `receiveMessage` to the overlay and reconcile hidden options on
   `choices` updates. Run the runtime-update tests.
6. **CSS rewrite.** Drop `.sb-select-control`, `.sb-select-icon`,
   and the `!important` overrides. Add the new
   trigger/content/viewport/item rules.
7. **Showcase playground + parity selectors.** Keep the Select page on
   the shared playground contract established by Button and Select:
   Preview, UI Definition source, Server Action source, grouped
   controls, value readback, and API Reference table. Switch the
   parity showcase URL to `#select`, drop the empty-string choice
   example, and recapture parity values.
8. **Browser tests.** Add the suite below.
9. **Drift detection wiring.** Land
   `tools/drift/shadcn-source.mjs` and
   `tools/drift/check-shadcn-source.mjs`. Capture the initial
   `select.shadcn-source.json` snapshot. Add the `parity-select`
   required job and `drift-check` informational job to
   `.github/workflows/ci.yml`. Verify `parity-select` blocks merge
   on a forced drift, and `drift-check` posts a comment on a
   forced snapshot mismatch.
10. **Docs.** Spec doc, `NEWS.md`, and ADR 0017 (only if the CSS
    ceiling moves).
11. **Manual approval.** Run the showcase, follow the manual
    check list, then stop.

# Required R tests — `tests/testthat/`

Add to `test-utils.R`:

```r
test_that("validate_select_choice_values rejects empty strings", {
  expect_error(
    validate_select_choice_values(c("free", "")),
    "placeholder sentinel"
  )
})

test_that("validate_select_choice_values rejects duplicates", {
  expect_error(
    validate_select_choice_values(c("free", "pro", "free")),
    "must be unique"
  )
})

test_that("validate_select_choice_values returns invisibly on success", {
  expect_invisible(validate_select_choice_values(c("free", "pro")))
})
```

Add to `test-shell.R`:

```r
test_that("block_select renders a hidden native select with input_id", {
  html <- render_html(block_select("plan", choices = c(Free = "free", Pro = "pro"), selected = "pro"))

  expect_match(html, '<select id="plan" class="sb-select-native"', fixed = TRUE)
  expect_match(html, 'tabindex="-1"', fixed = TRUE)
  expect_match(html, 'aria-hidden="true"', fixed = TRUE)
  expect_match(html, '<option value="pro" selected', fixed = TRUE)
})

test_that("block_select does not render a visible native select", {
  html <- render_html(block_select("plan", choices = c("Free", "Pro")))
  # Hidden native control allowed; no visible <select> wrapper.
  expect_no_match(html, 'class="sb-select-control"', fixed = TRUE)
})

test_that("block_select rejects empty-string choice values", {
  expect_error(
    block_select("plan", choices = c(None = "", Free = "free")),
    "placeholder sentinel"
  )
})

test_that("block_select rejects duplicate choice values", {
  expect_error(
    block_select("plan", choices = c(Free = "free", AlsoFree = "free")),
    "must be unique"
  )
})

test_that("block_select runs width through validateCssUnit", {
  expect_error(block_select("plan", choices = "Free", width = "not-a-width"))
})
```

Replace `test-runtime-update.R` Select assertions with:

```r
test_session_input <- function() {
  sent <- new.env(parent = emptyenv())
  session <- new.env(parent = emptyenv())
  session$ns <- function(id) paste0("module-", id)
  session$sendInputMessage <- function(input_id, message) {
    sent$input_id <- input_id
    sent$message <- message
  }
  list(session = session, sent = sent)
}

test_that("update_block_select dispatches via sendInputMessage", {
  fixture <- test_session_input()
  update_block_select(
    session = fixture$session,
    input_id = "plan",
    selected = "pro"
  )
  expect_identical(fixture$sent$input_id, "module-plan")
  expect_identical(fixture$sent$message$selected, "pro")
  expect_identical(fixture$sent$message$notify, TRUE)
})

test_that("cosmetic update_block_select does not flag notify", {
  fixture <- test_session_input()
  update_block_select(
    session = fixture$session,
    input_id = "plan",
    width = "12rem"
  )
  expect_identical(fixture$sent$message$width, "12rem")
  expect_identical(fixture$sent$message$notify, FALSE)
})

test_that("update_block_select rejects invalid selected with new choices", {
  fixture <- test_session_input()
  expect_error(
    update_block_select(
      session = fixture$session,
      input_id = "plan",
      choices = c(Free = "free", Pro = "pro"),
      selected = "team"
    ),
    "must match one of"
  )
})

test_that("update_block_select inside a module namespaces", {
  fixture <- test_session_input()
  update_block_select(
    session = fixture$session,
    input_id = "plan",
    selected = "pro"
  )
  expect_identical(fixture$sent$input_id, "module-plan")
})
```

Add to `test-runtime-css.R`:

```r
test_that("runtime CSS exposes the new select selectors", {
  css <- readLines(system.file("www", "shinyblocks-runtime.css", package = "shinyblocks"))
  joined <- paste(css, collapse = "\n")
  expect_match(joined, ".sb-select-trigger", fixed = TRUE)
  expect_match(joined, ".sb-select-content", fixed = TRUE)
  expect_match(joined, ".sb-select-item", fixed = TRUE)
  expect_match(joined, ".sb-select-native", fixed = TRUE)
})

test_that("runtime CSS removes the legacy select-control selectors", {
  css <- readLines(system.file("www", "shinyblocks-runtime.css", package = "shinyblocks"))
  joined <- paste(css, collapse = "\n")
  expect_no_match(joined, ".sb-select-control", fixed = TRUE)
  expect_no_match(joined, ".sb-select-icon ", fixed = TRUE)
})
```

# Required browser tests — npm suite

Add cases under the existing runtime-shiny harness. Required
assertions:

- `window.Shiny.inputBindings.bindings` includes
  `{ binding: anything, priority: anything }` whose binding instance
  reports `binding.getType() === "shinyblocks.select"`.
- The binding's `find(root)` returns `root` when `root` is the
  Select runtime mount, not only when an ancestor scope is passed.
- After `Shiny.bindAll(document)`, `getValue(root)` returns the
  hidden `<select>`'s value.
- Clicking the trigger opens content under
  `[data-shinyblocks-portal-root]` and sets `data-state="open"` on
  the trigger.
- Clicking an item dispatches `change` on the hidden `<select>`
  exactly once and updates `input$<id>` exactly once.
- ArrowDown opens and highlights the selected item; if none
  selected, highlights index 0.
- Enter commits the highlighted item and restores focus to the
  trigger.
- Escape closes without committing and restores focus.
- Outside `pointerdown` closes without committing.
- `receiveMessage({ choices: [...], selected: "pro" })` while open:
  closes the dropdown, rewrites the hidden `<option>` set, and sets
  the hidden `<select>` value to `"pro"`.
- `receiveMessage({ choices: [...] })` with no `selected` keeps the
  previous value when it still exists in the new choices.
- `receiveMessage({ disabled: true })` sets `disabled` on both the
  trigger and the hidden `<select>`.
- Removing the runtime root removes any open portal content (no
  leaked node under `[data-shinyblocks-portal-root]`).
- In dark mode (`data-theme="dark"` on `<html>`), opened content
  resolves `background-color` to the dark `--popover` token.
- Bookmarking via `enableBookmarking("server")` round-trips the
  selected value (smoke test).
- Clicking a `<label for="{input_id}">` ends up with visible focus
  on the trigger button.

# Parity harness changes — `tools/parity/registry.mjs`

```js
export const SELECT_TRIGGER_PROPS = [
  // current SELECT_PROPS — already correct for the trigger
];

export const SELECT_CONTENT_PROPS = [
  "backgroundColor",
  "borderRadius",
  "borderTopColor",
  "borderTopStyle",
  "borderTopWidth",
  "boxShadow",
  "color",
  "minWidth",
  "padding",
];

export const SELECT_ITEM_PROPS = [
  "alignItems",
  "backgroundColor",
  "borderRadius",
  "color",
  "display",
  "fontSize",
  "lineHeight",
  "padding",
];

// Inside REGISTRY.select:
select: {
  component: "select",
  parityUrl: "http://127.0.0.1:5173/?component=select",
  showcaseUrl: "http://127.0.0.1:4321/#select",
  showcaseReadySelector: '[data-sb-section="select"]:not([hidden])',
  roles: {
    trigger: {
      props: SELECT_TRIGGER_PROPS,
      referenceSelectors: {
        default: '[data-parity-component="select"] [data-parity-state="default"] [data-slot="select-trigger"]',
        open:    '[data-parity-component="select"] [data-parity-state="open"]    [data-slot="select-trigger"]',
      },
      showcaseSelectors: {
        default: '[data-sb-section="select"] [data-slot="select-trigger"]',
        open:    '[data-sb-section="select"] [data-slot="select-trigger"][data-state="open"]',
      },
    },
    content: {
      props: SELECT_CONTENT_PROPS,
      referenceSelectors: {
        open: '[data-parity-component="select"] [data-slot="select-content"]',
      },
      showcaseSelectors: {
        open: '[data-shinyblocks-portal-root] [data-slot="select-content"]',
      },
    },
    item: {
      props: SELECT_ITEM_PROPS,
      referenceSelectors: {
        open: '[data-parity-component="select"] [data-slot="select-item"]',
      },
      showcaseSelectors: {
        open: '[data-shinyblocks-portal-root] [data-slot="select-item"]',
      },
    },
  },
  states: ["default", "open"],
  themes: ["light", "dark"],
  prepareShowcaseState: async (page, state) => {
    if (state === "open") {
      await page.locator('[data-sb-section="select"] [data-slot="select-trigger"]').first().click();
      await page.waitForSelector('[data-shinyblocks-portal-root] [data-slot="select-content"]', {
        state: "visible",
        timeout: 10000,
      });
      await page.waitForTimeout(200);
    }
  },
},
```

# Tests and checks command list

```bash
npm run build:runtime
Rscript -e "devtools::test(filter='shell|utils|runtime-update|runtime-css')"
npm run test:runtime
npm run test:runtime-shiny
npm run test:showcase
make parity COMPONENT=select
```

Then start the showcase at `http://127.0.0.1:4321/#select` and walk
the manual checklist below.

# Manual approval checklist

- [ ] Light mode: open the Select, highlight an item, commit with
      Enter — `input$showcase_select_preview` updates exactly once.
- [ ] Dark mode (`data-theme="dark"` on `<html>`): open the Select —
      content background matches dark `--popover` token.
- [ ] Click a `block_field_label(..., for = "showcase_select_preview")`
      — focus lands on the trigger button.
- [ ] "Set Pro" action button fires `update_block_select(selected =
      "pro")`; trigger visibly updates; `input$<id>` event fires.
- [ ] "Clear" action button clears to placeholder; trigger shows the
      placeholder text.
- [ ] "Disable" action button disables both the trigger button and
      the hidden `<select>`.
- [ ] "Replace choices" while the dropdown is open — dropdown
      force-closes; trigger reflects the new selected value.
- [ ] Module-namespacing showcase example: `input$mod-id` fires when
      the Select inside the module is updated.
- [ ] Tab key cycles past the trigger without committing.
- [ ] Escape closes the open dropdown and returns focus to the
      trigger.
- [ ] Outside click closes the open dropdown without committing.
- [ ] Bookmark the URL, reload, verify the selected value is
      restored.

# Drift detection

The `.sb-*` class strategy trades "upstream class-string drift" for
"translation drift": the runtime classes are hand-translations of
shadcn source, so a shadcn change in spacing, tokens, or DOM shape
can silently diverge from the shipped runtime. Two layered checks
make that drift loud instead of silent.

## Layer 1 — Parity harness, gated in CI

The existing computed-style harness under `tools/parity/` already
diffs the shadcn React reference app at
`http://127.0.0.1:5173/?component=select` against the shinyblocks
showcase. Once the Select entry is split into trigger / content /
item roles (see "Parity harness changes" above), promote the gate
from "run locally" to "required on every PR":

- [ ] `.github/workflows/ci.yml` — add a `parity-select` job that:
  1. installs Node + Playwright + R as the existing build jobs do;
  2. starts the reference app (`npm --prefix parity run dev &`) and
     the showcase (`make showcase &`);
  3. waits for both ports (`5173` and `4321`) with a short retry
     loop;
  4. runs `make parity COMPONENT=select`;
  5. uploads the produced `docs/component-specs/_parity/select.json`
     and any diff output as a workflow artifact.

The job must be a **required** check on PRs that touch any of:
`R/select.R`, `frontend/src/**`, `inst/www/shinyblocks-runtime.*`,
`tools/parity/**`, or `docs/component-specs/_parity/select.json`.

When parity goes red the workflow surfaces exactly which property
on which role (`trigger.borderRadius`, `content.boxShadow`,
`item.paddingLeft`, etc.) drifted, in which theme, in which state.
Re-translate `.sb-select-*` CSS until the diff is empty.

## Layer 2 — Shadcn source snapshot

The parity harness catches *visible* drift. It does not catch DOM
or class-string changes that don't change computed styles yet but
will when the next theme/preset lands. A small snapshot of the
upstream class strings adds early warning without changing the
styling strategy.

- [ ] `tools/drift/shadcn-source.mjs` — new maintainer-side script.
  It fetches the canonical shadcn `select.tsx` source from the
  pinned commit recorded in
  `docs/component-specs/_parity/select.shadcn-source.json` and
  extracts every `cn(...)` / `className=` literal into a stable
  shape:

  ```json
  {
    "source_commit": "shadcn-ui/ui@<sha>",
    "captured_at": "2026-05-14T00:00:00Z",
    "select-trigger":   "flex h-9 w-full items-center justify-between ...",
    "select-content":   "relative z-50 max-h-96 min-w-32 overflow-hidden ...",
    "select-viewport":  "p-1",
    "select-item":      "relative flex w-full cursor-default ...",
    "select-item-indicator": "absolute right-2 flex h-3.5 w-3.5 ..."
  }
  ```

  The script writes that JSON to
  `docs/component-specs/_parity/select.shadcn-source.json`.

- [ ] `tools/drift/check-shadcn-source.mjs` — companion script. Reads
  the committed snapshot, re-runs the fetch against the pinned
  commit, and exits non-zero if the canonical class strings have
  drifted from the snapshot. The pinned commit only changes when a
  maintainer explicitly bumps it.

- [ ] `package.json` scripts — add `drift:capture` (runs
  `shadcn-source.mjs`) and `drift:check` (runs
  `check-shadcn-source.mjs`).

- [ ] `.github/workflows/ci.yml` — add a `drift-check` job that
  runs `npm run drift:check`. The job is **informational** (does not
  block merge) so it never blocks a maintainer who is intentionally
  re-translating a shadcn change. It posts a PR comment when the
  snapshot is stale.

- [ ] Bump workflow — when a maintainer bumps the pinned commit in
  `select.shadcn-source.json`, the same PR must:
  1. re-run `npm run drift:capture` and commit the refreshed JSON;
  2. re-run `make parity COMPONENT=select` and commit any computed
     style snapshot updates;
  3. translate any visible-style or DOM-shape changes into the
     `.sb-select-*` CSS or React overlay;
  4. note the bump in `NEWS.md` (under a "Tracking shadcn" subhead
     if there is more than one such bump per release).

## What stays out

- The Select runtime never imports shadcn React source verbatim.
  The snapshot is read-only — it informs translation, it is not the
  build output.
- The runtime never ships Tailwind utilities. Class strings in the
  snapshot are reference material, not styling hooks.
- No Tailwind build runs against the shipped runtime. The frontend
  build still emits `.sb-select-*` rules into
  `inst/www/shinyblocks-runtime.css` as before.

## Why this is sufficient

Two complementary signals cover the realistic drift modes:

| Drift mode | Caught by |
| --- | --- |
| Spacing / color / radius / typography change | Parity harness (Layer 1) |
| DOM shape change (new slot, removed wrapper) | Source snapshot (Layer 2) — diff flags new `data-slot` strings |
| Token rename (e.g. `--input` → `--input-border`) | Parity harness shows a color drift; snapshot shows the class-string change |
| Pure refactor with no rendered difference | Neither — and that is fine, because the user-visible contract has not changed |

# Risks

- Accessibility is now shinyblocks-owned. Test, do not assume.
- Portal positioning can clip near viewport edges in v1.
  Documented limitation.
- Native mobile picker behavior is lost. Accepted tradeoff.
- Choice replacement while open can leave stale highlight/value
  state. Handled explicitly in `receiveMessage`.
- Duplicate or empty choice values create ambiguous state. Rejected
  at R.
- Label-to-trigger focus forwarding is custom, not native. Test the
  click path.
- Bundle size will rise. ADR 0017 budget is 8 KB raw / 2 KB gzip
  CSS. If exceeded, update ADR 0017 in the same PR with measured
  numbers.
- Two lifecycle paths exist: MutationObserver for stateless
  components, `Shiny.bindAll()` / `unbindAll()` for the Select
  binding. They must not double-publish the initial value — the
  binding owns the handshake; `mountRoot()` skips Select.
- Translation drift from upstream shadcn changes. Mitigated by the
  two-layer Drift detection wiring above: the parity harness is a
  required CI gate on visible style drift, and the shadcn source
  snapshot is an informational alarm on class-string or DOM-shape
  drift. If either signal turns red, re-translate before merging.

# Open questions

- Should typeahead ship in v1, or follow once the visual / keyboard
  / Shiny contract is stable?
- Should `selected = NULL` keep clearing to `""`, or grow an
  explicit clear sentinel later?
- Should grouped choices ever land in `block_select()`, or should
  grouped/searchable behavior become a separate `block_combobox()`?
- Should the parity harness use the shadcn docs or the pinned local
  React reference app?
- Should slider / checkbox / switch / textarea migrate from
  `sb:update` to per-component `Shiny.InputBinding`s now that
  Select establishes the pattern?
