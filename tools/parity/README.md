# Visual Parity Harness

ADR 0016 implementation scaffold.

Current scope:
- reference app under `parity/`
- baseline capture for `button`
- live diff against the local showcase

Commands:
- `make parity-install`
- `make parity-build-css`
- `make parity-setup`
- `make parity`
- `make parity-stop`

Current baseline path:
- `docs/component-specs/_parity/button.json`

Existing POCs remain in place for `select` and `slider` until those
components are migrated into the shared registry.
