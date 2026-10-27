import type { NextConfig } from "next";

// GitHub Pages serves the site at https://nvelden.github.io/shinyblocks/
// so every path needs the `/shinyblocks` prefix. If you ever rename the repo,
// change BOTH basePath and assetPrefix here.
const basePath = "/shinyblocks";

const nextConfig: NextConfig = {
  output: "export",
  basePath,
  assetPrefix: `${basePath}/`,
  trailingSlash: true,
  images: { unoptimized: true },
  // The maintainer checkout can sit below unrelated lockfiles. Pin discovery
  // here so Turbopack does not select an ancestor as the workspace root.
  turbopack: { root: process.cwd() },
  // The static export lands in `out/`. CI copies it to GitHub Pages.
  // `.nojekyll` is created in public/ so GH Pages doesn't eat `_next/`.
};

export default nextConfig;
