import * as fs from "fs";
import * as path from "path";
import type { Metadata } from "next";
import Link from "next/link";
import { ExternalLink } from "lucide-react";

export const metadata: Metadata = {
  title: "Changelog",
  description: "Release notes and recent changes in shinyblocks.",
};

export default function ChangelogPage() {
  const changelogHtmlPath = path.join(process.cwd(), "content/changelog.html");
  const tocPath = path.join(process.cwd(), "lib/changelog-toc.json");

  let htmlContent = "";
  let toc: { title: string; slug: string }[] = [];

  try {
    htmlContent = fs.readFileSync(changelogHtmlPath, "utf-8");
    toc = JSON.parse(fs.readFileSync(tocPath, "utf-8"));
  } catch (error) {
    console.error("Failed to load changelog or TOC files:", error);
  }

  return (
    <div className="mx-auto w-full max-w-screen-xl px-6 py-10 md:py-14">
      <div className="grid grid-cols-1 gap-12 xl:grid-cols-[minmax(0,1fr)_16rem]">
        <main className="min-w-0 max-w-3xl">
          <div className="mb-10 flex flex-col gap-3">
            <div className="flex items-center gap-3">
              <h1 className="text-3xl font-bold tracking-tight text-foreground md:text-4xl">
                Changelog
              </h1>
              <Link
                href="https://github.com/nvelden/shinyblocks/blob/main/NEWS.md"
                className="inline-flex items-center gap-1 rounded-md border border-border px-2.5 py-1 text-xs font-medium text-muted-foreground transition-colors hover:bg-accent hover:text-accent-foreground"
              >
                NEWS
                <ExternalLink className="size-3" aria-hidden="true" />
              </Link>
            </div>
            <p className="text-base text-muted-foreground">
              Latest updates and announcements.
            </p>
          </div>

          <article 
            className="max-w-none text-foreground
              [&>h2]:mt-12 [&>h2]:scroll-m-20 [&>h2]:text-2xl [&>h2]:font-semibold [&>h2]:tracking-tight [&>h2]:text-foreground first:[&>h2]:mt-0
              [&>h3]:mt-8 [&>h3]:scroll-m-20 [&>h3]:text-lg [&>h3]:font-semibold [&>h3]:tracking-tight [&>h3]:text-foreground
              [&>p]:mt-4 [&>p]:text-sm [&>p]:leading-7 [&>p]:text-muted-foreground
              [&>ul]:my-5 [&>ul]:list-disc [&>ul]:space-y-2 [&>ul]:pl-5
              [&>ul>li]:pl-1 [&>ul>li]:text-sm [&>ul>li]:leading-7 [&>ul>li]:text-muted-foreground
              [&_a]:font-medium [&_a]:text-foreground [&_a]:underline [&_a]:underline-offset-4
              [&_code]:rounded-md [&_code]:bg-muted [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:font-mono [&_code]:text-xs [&_code]:text-foreground
              [&_pre]:mt-4 [&_pre]:overflow-x-auto [&_pre]:rounded-lg [&_pre]:border [&_pre]:bg-muted/50 [&_pre]:p-4
              [&_pre_code]:bg-transparent [&_pre_code]:p-0"
            dangerouslySetInnerHTML={{ __html: htmlContent }}
          />
        </main>

        <aside className="hidden xl:block">
          <div className="sticky top-20 flex flex-col gap-4 border-l border-border/60 pl-6">
            <h2 className="text-sm font-semibold text-foreground">On This Page</h2>
            <nav className="flex flex-col gap-2">
              {toc.map((item) => (
                <Link
                  key={item.slug}
                  href={`/changelog#${item.slug}`}
                  className="text-sm text-muted-foreground transition-colors hover:text-foreground"
                >
                  {item.title}
                </Link>
              ))}
            </nav>
          </div>
        </aside>
      </div>
    </div>
  );
}
