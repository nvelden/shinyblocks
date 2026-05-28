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

## Deploy

Push to `main` triggers `.github/workflows/docs-deploy.yml`, which builds and publishes to <https://nvelden.github.io/shinyblocks/>.
