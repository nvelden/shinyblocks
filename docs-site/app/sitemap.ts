import type { MetadataRoute } from "next";
import manifest from "@/lib/preview-manifest.json";
import { SITE_URL } from "@/lib/site";

// Written to out/sitemap.xml at build time; served at
// https://nvelden.github.io/shinyblocks/sitemap.xml. Submit that URL in
// Google Search Console — robots.txt discovery doesn't work on a project
// page because robots.txt must live at the domain root.
export const dynamic = "force-static";

const BASE = SITE_URL;

export default function sitemap(): MetadataRoute.Sitemap {
  const pages: MetadataRoute.Sitemap = [
    { url: `${BASE}/`, priority: 1 },
    { url: `${BASE}/get-started/`, priority: 0.9 },
    { url: `${BASE}/components/`, priority: 0.9 },
    { url: `${BASE}/changelog/`, priority: 0.5 },
  ];

  const components: MetadataRoute.Sitemap = manifest
    .filter((c) => c.slug !== "gallery")
    .map((c) => ({
      url: `${BASE}/components/${c.slug}/`,
      priority: 0.8,
    }));

  return [...pages, ...components];
}
