# shinyblocks docs site

Static docs site for the `shinyblocks` R package. Next.js 15 + Tailwind v4, static export to GitHub Pages.

## Local dev

```bash
npm install
npm run dev
```

Site runs at <http://localhost:3000/shinyblocks> (note the `/shinyblocks` prefix — basePath is set in `next.config.ts` to match the eventual GitHub Pages URL).

## Build + local preview

```bash
npm run build            # static export → out/
npm run preview          # build + serve out/ at http://localhost:4173/shinyblocks/
```

## Tests

```bash
npm run test:e2e         # Playwright against the built site (auto-builds + serves)
npm run test:e2e:install # one-time browser install
```

## Plan & spec

Everything is documented under `../docs/agent-plans/`:

- `2026-05-19-custom-docs-site.md` — architecture & wireframes
- `2026-05-19-docs-site-build-plan.md` — the 8 phases
- `2026-05-19-docs-site-DESIGN.md` — tokens, typography, components per surface
- `2026-05-19-docs-site-DEVELOPMENT.md` — per-phase gates and Playwright suites

## Deploy

Push to `main` triggers `.github/workflows/docs-deploy.yml`, which builds and publishes to <https://nvelden.github.io/shinyblocks/>.
