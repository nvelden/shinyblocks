# Plan: Reactive Bidirectional block_button()

This plan details the upgrade of `block_button()` from a receive-only visual component to a fully reactive, bidirectional Shiny input component. This allows developers to use the native `block_button()` directly with observers on the R server (e.g. `observeEvent(input$my_button)`) just like standard `shiny::actionButton()`, while retaining the high-fidelity shadcn look and server-side updatability.

## Goal
Make `block_button()` fully interactive by updating its JavaScript Shiny binding to capture clicks and report click counts back to the Shiny server, modifying its R API to specify `input = TRUE`, updating specifications, and verifying the new reactive behavior inside R tests and the select playground.

## Assumptions
- Bubbling click events from React's `<button>` element can be captured at the root DOM mount node `el` of the component.
- The R package test suite asserts the structure of button binding properties, which we must update to reflect `input = TRUE`.
- The showcase and documentation playgrounds can transition from `shiny::actionButton()` to `shinyblocks::block_button()` for all server action triggers.

## Proposed API Changes

### JavaScript Binding
Update `ShinyblocksButtonBinding` in `frontend/src/runtime/bindings.js`:
- Maintain a click count state property on the element: `el.__sbButtonClickCount`.
- Initialize it to `0`.
- In `subscribe(el, callback)`, listen to `"click"` events on the root element. If the button is not disabled, increment `el.__sbButtonClickCount` and invoke `callback(false)`.
- In `getValue(el)`, return `el.__sbButtonClickCount`.
- In `setValue(el, value)`, allow setting the counter value.

### R Component
Update `block_button` in `R/components.R`:
- Change the binding list to enable inputs:
  ```R
  binding <- if (is.null(input_id)) list() else list(
    input = TRUE,
    type = "shinyblocks.button"
  )
  ```

---

## Files to Edit

### 1. [bindings.js](../../frontend/src/runtime/bindings.js)
Upgrade the receive-only button input binding to handle event listeners and click counts:
```javascript
  class ShinyblocksButtonBinding extends window.Shiny.InputBinding {
    find(scope) { ... }
    getId(el) { ... }
    getType() { return null; }
    
    getValue(el) {
      if (typeof el.__sbButtonClickCount === "undefined") {
        el.__sbButtonClickCount = 0;
      }
      return el.__sbButtonClickCount;
    }

    setValue(el, value) {
      el.__sbButtonClickCount = Number(value) || 0;
    }

    subscribe(el, callback) {
      const handler = (e) => {
        if (el.hasAttribute("disabled") || el.querySelector("button:disabled")) {
          return;
        }
        if (typeof el.__sbButtonClickCount === "undefined") {
          el.__sbButtonClickCount = 0;
        }
        el.__sbButtonClickCount += 1;
        callback(false);
      };
      el.addEventListener("click", handler);
      el.__sbButtonClickHandler = handler;
    }

    unsubscribe(el) {
      if (!el.__sbButtonClickHandler) return;
      el.removeEventListener("click", el.__sbButtonClickHandler);
      delete el.__sbButtonClickHandler;
    }

    receiveMessage(el, data) {
      if (typeof el.__sbButtonReceive === "function") {
        el.__sbButtonReceive(data || {});
      }
    }
  }
```

### 2. [components.R](../../R/components.R)
Change `binding$input` from `FALSE` to `TRUE`.

### 3. [button.md](../../docs/component-specs/button.md)
Update the specification to document the new bidirectional reactive input binding.

### 4. [test-utils.R](../../tests/testthat/test-utils.R)
Update tests to assert `"input":true` for buttons with an ID:
```R
expect_match(html, '"binding":\\{"input":true,"type":"shinyblocks\\.button"\\}')
```

### 5. [app.R](../../docs-site/playgrounds/select/app.R)
Refactor the custom `showcase_action_button` R helper to use native `block_button` instead of Shiny's `actionButton`:
```R
showcase_action_button <- function(input_id, label) {
  block_button(
    label,
    id = input_id,
    variant = "outline",
    size = "sm"
  )
}
```

---

## Verification Plan

### Automated Checks & Tests
1. **Compilation**: Run `npm run build` from the workspace root to compile the JavaScript change.
2. **R Unit Tests**: Run `Rscript -e "devtools::test()"` to ensure everything builds and passes.
3. **Playground Recompilation**: Run `Rscript scripts/generate-playgrounds.R` in `docs-site/` to package the updated playground with native reactive `block_button`s.

### Manual Verification
- Launch the select playground inside Next.js/Shinylive and verify that clicking the custom action buttons updates the select trigger and state reactively on the server.

---

## Open Questions
- None. The bidirectional input binding architecture matches exactly how other interactive widgets in `shinyblocks` communicate, keeping it highly idiomatic and consistent.
