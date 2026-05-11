# Visual Parity Harness

ADR 0016 implementation scaffold.

Current scope:
- reference app under `parity/`
- baseline capture for `button`, `checkbox`, `select`, `slider`, `switch`, and `textarea`
- live diff against the local showcase

Commands:
- `make parity-install`
- `make parity-build-css`
- `make parity-setup`
- `make parity COMPONENT=button`
- `make parity-ci`
- `make parity-stop`

Current baseline path:
- `docs/component-specs/_parity/button.json`
- `docs/component-specs/_parity/checkbox.json`
- `docs/component-specs/_parity/select.json`
- `docs/component-specs/_parity/slider.json`
- `docs/component-specs/_parity/switch.json`
- `docs/component-specs/_parity/textarea.json`

Shared-harness coverage is whatever is currently registered in
`tools/parity/registry.mjs`. The remaining standalone POCs can be
deleted once their coverage is fully subsumed by the shared harness.
