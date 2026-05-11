# Parity Reference App

Dev-only React reference app for the ADR 0016 visual-parity harness.

Current scope:
- `button` route only

Workflow:
1. `make parity-install`
2. `make parity-build-css`
3. `make parity-setup`
4. `make parity`
5. `make parity-stop`

Routes:
- `http://127.0.0.1:5173/?component=button&theme=light`
- `http://127.0.0.1:5173/?component=button&theme=dark`

The app is intentionally small. New routes should be added one component
at a time, with matching baselines under `docs/component-specs/_parity/`.
