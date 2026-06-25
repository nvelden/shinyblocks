import type { Metadata } from "next";
import Link from "next/link";
import { ExternalLink } from "lucide-react";
import { GuideCodeBlock } from "@/components/guide-code-block";
import { GuideToc } from "@/components/guide-toc";
import { PlaygroundFrame } from "@/components/playground-frame";
import {
  GET_STARTED_TOC,
  CODE_INSTALL,
  CODE_IMPORTS,
  CODE_DATA,
  CODE_UI,
  CODE_SERVER,
  CODE_RUN,
  CODE_COMPLETE,
  CODE_SHELL_TREE,
  CODE_COMPOSITION_TREE,
  CODE_THEME_VARIANT,
  CODE_RUN_APP,
  CODE_RUN_SHOWCASE,
} from "@/content/guides/get-started";

export const metadata: Metadata = {
  title: "Get Started with shinyblocks",
  description:
    "Build a reactive sales dashboard with a sidebar, filters, metric cards, a plot, theming, and standard Shiny server logic.",
};

const REPO = "https://github.com/nvelden/shinyblocks";

// Section heading with a stable, linkable id. Ids are owned by the content
// module's TOC so the page and navigation can never drift apart.
function SectionHeading({ id, children }: { id: string; children: React.ReactNode }) {
  return (
    <h2
      id={id}
      className="scroll-mt-24 text-2xl font-bold tracking-tight text-foreground"
    >
      {children}
    </h2>
  );
}

function nextSteps() {
  return [
    { label: "Browse components", href: "/components/", desc: "Every block_*() with a live playground and API table." },
    { label: "Build forms", href: "/components/field/", desc: "Compose accessible labels, inputs, and validation." },
    { label: "Add reactive outputs", href: "/components/plot-output/", desc: "Style output frames around standard Shiny renderers." },
    { label: "Handle longer work", href: "/components/task-button/", desc: "Give slow actions an automatic busy state." },
  ];
}

export default function GetStartedPage() {
  return (
    <div className="mx-auto w-full max-w-screen-xl px-6 py-10 md:py-14">
      <div className="grid grid-cols-1 gap-12 xl:grid-cols-[minmax(0,1fr)_16rem]">
        <main className="min-w-0 max-w-3xl">
          {/* Lead */}
          <div className="mb-10 flex flex-col gap-3 border-b border-border/60 pb-8">
            <h1 className="text-3xl font-extrabold tracking-tight text-foreground md:text-4xl">
              Get Started with shinyblocks
            </h1>
            <p className="text-lg leading-relaxed text-muted-foreground">
              Build a reactive sales dashboard with a sidebar, filters, metric
              cards, a plot, theming, and standard Shiny server logic.
            </p>
          </div>

          {/* Mobile TOC (in-flow) */}
          <nav
            aria-label="On this page"
            className="mb-10 rounded-lg border border-border bg-muted/30 p-4 xl:hidden"
          >
            <p className="mb-3 text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              On this page
            </p>
            <GuideToc entries={GET_STARTED_TOC} variant="mobile" />
          </nav>

          <div className="flex flex-col gap-14">
            {/* 1. What you will build */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="what-you-will-build">
                What you will build
              </SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                You will build a single-file <strong>Regional sales dashboard</strong>:
                a complete app shell with a collapsible sidebar, a header with a dark
                mode control, a region filter, two reactive metric cards, a reactive
                revenue plot, and a reset action. The whole thing is one{" "}
                <code>app.R</code> file with no frontend build step.
              </p>
              <ul className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li>Responsive page shell with sidebar and header</li>
                <li>Region filter that drives every value on the page</li>
                <li>Reactive metric cards and a reactive plot</li>
                <li>Reset action with an automatic busy state</li>
                <li>Light and dark mode toggle</li>
              </ul>
              <div className="rounded-lg border border-border bg-muted/30 p-4 text-sm leading-relaxed text-muted-foreground">
                <strong className="text-foreground">Prerequisites.</strong> You need R, a
                current Shiny installation, and the ability to install a package from
                GitHub. You do <em>not</em> need React, Tailwind, Vite, or any Node
                tooling. Plan on about 10–15 minutes.
              </div>

              {/* Live preview of the finished app, running in the browser via
                  Shinylive. Source is generated from the same CODE_COMPLETE the
                  Complete app.R block shows, so it can never drift. */}
              <figure className="flex flex-col gap-2">
                <div className="overflow-hidden rounded-lg border border-border bg-card">
                  <PlaygroundFrame
                    src="/shinyblocks/playgrounds/get-started/"
                    title="Live preview of the finished Regional sales dashboard"
                    className="w-full"
                    style={{ height: "880px", border: 0 }}
                  />
                </div>
                <figcaption className="flex flex-wrap items-center gap-x-2 gap-y-1 text-sm text-muted-foreground">
                  <span>
                    The finished app, running live in your browser. It boots in
                    WebAssembly (no server), so the first load takes a few seconds.
                  </span>
                  <a
                    href="/shinyblocks/playgrounds/get-started/"
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex items-center gap-1 font-medium text-foreground underline underline-offset-4"
                  >
                    Open full size
                    <ExternalLink className="h-3.5 w-3.5" />
                  </a>
                </figcaption>
              </figure>
            </section>

            {/* 2. Install */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="install">Install shinyblocks</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                shinyblocks is experimental and not yet on CRAN. Install the current
                GitHub development release with <code>pak</code>:
              </p>
              <GuideCodeBlock code={CODE_INSTALL} label="Install command" />
              <p className="leading-relaxed text-muted-foreground">
                Then load Shiny and shinyblocks at the top of your app. App authors do
                not need Node, React, Tailwind, or Vite — the package ships its compiled
                runtime, and this example targets the current GitHub development release.
              </p>
              <GuideCodeBlock code={CODE_IMPORTS} label="Library imports" />
            </section>

            {/* 3. Create app.R */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="create-app">Create app.R</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                Create an empty directory with a single <code>app.R</code> file. Start it
                with the imports and a small, deterministic sample dataset. Keeping the
                data local means the first run has no external failure modes.
              </p>
              <GuideCodeBlock code={CODE_DATA} label="Imports and sample data" collapsible />
            </section>

            {/* 4. Page shell */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="page-shell">Build the page shell</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                The outer container is <code>block_page()</code>. It owns the full app
                shell and accepts optional named <code>sidebar</code> and{" "}
                <code>header</code> regions, with body blocks passed through{" "}
                <code>...</code>.
              </p>
              <GuideCodeBlock code={CODE_SHELL_TREE} language="text" label="Page shell structure" />
              <ul className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li><code>block_page()</code> owns the full app shell.</li>
                <li><code>block_sidebar()</code> and <code>block_header()</code> are optional named regions.</li>
                <li>Page body blocks are supplied through <code>...</code>.</li>
                <li><code>block_theme()</code> controls semantic colours.</li>
                <li><code>block_style()</code> controls visual geometry and feel.</li>
              </ul>
              <p className="leading-relaxed text-muted-foreground">
                The full <code>ui &lt;- block_page(...)</code> definition is shown in the{" "}
                <a href="#complete-example" className="font-medium text-foreground underline underline-offset-4">complete example</a>{" "}
                below; the next two sections cover the body blocks it contains.
              </p>
            </section>

            {/* 5. Controls */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="controls">Add a filter and reset action</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                A filter card holds a labelled region select. The compact reset action
                shares the label row, so it does not create another control column:
              </p>
              <GuideCodeBlock
                label="Region field"
                code={`block_field(
  block_cluster(
    align = "center",
    justify = "between",
    wrap = FALSE,
    block_field_label("Region", \`for\` = "region"),
    block_task_button(
      "reset_filters",
      "Reset",
      label_busy = "Resetting...",
      variant = "ghost",
      size = "sm",
      icon = "refresh-cw"
    )
  ),
  block_select(
    "region",
    choices = c("Americas", "EMEA", "APAC"),
    selected = "Americas"
  ),
  block_field_description("All dashboard values use this region.")
)`}
              />
              <ul className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li><code>input$region</code> behaves as a normal Shiny input.</li>
                <li>The label uses a matching <code>for</code>/input id.</li>
                <li>The task button exposes a busy state for free.</li>
                <li>Layout around blocks can use ordinary <code>htmltools::div()</code> and inline CSS, as in the complete example&apos;s responsive grid.</li>
              </ul>
            </section>

            {/* 6. Outputs */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="outputs">Add reactive cards and a plot</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                shinyblocks blocks accept normal Shiny output tags as children. Two metric
                cards hold standard <code>textOutput()</code>:
              </p>
              <GuideCodeBlock
                label="Metric cards"
                code={`block_card(
  title = "Revenue",
  description = "Six-month total",
  value = textOutput("revenue", inline = TRUE)
)

block_card(
  title = "Orders",
  description = "Six-month total",
  value = textOutput("orders", inline = TRUE)
)`}
              />
              <p className="leading-relaxed text-muted-foreground">
                The plot card frames a <code>block_plot_output()</code>:
              </p>
              <GuideCodeBlock
                label="Plot card"
                code={`block_card(
  title = "Monthly revenue",
  description = "Revenue by month for the selected region",
  block_plot_output(
    "revenue_plot",
    aspect = "16/9",
    border = FALSE
  )
)`}
              />
              <ul className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li>shinyblocks accepts normal Shiny output tags as children.</li>
                <li><code>block_plot_output()</code> styles the frame; <code>renderPlot()</code> stays standard Shiny.</li>
                <li>Output ids must match the server assignments.</li>
              </ul>
            </section>

            {/* 7. Server logic */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="server-logic">Connect the server</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                The server is ordinary Shiny. A reactive filters the data by region, two
                render functions fill the cards, one renders the plot, and an observer
                resets the select.
              </p>
              <GuideCodeBlock code={CODE_SERVER} label="Server function" collapsible />
              <ul className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li><code>reactive()</code>, <code>renderText()</code>, <code>renderPlot()</code>, and <code>observeEvent()</code> are unchanged Shiny APIs.</li>
                <li><code>update_block_select()</code> follows the same server-update pattern as native <code>updateSelectInput()</code>.</li>
                <li>Plot <code>alt</code> text is supplied through <code>renderPlot()</code>, because Shiny owns the rendered image.</li>
              </ul>
            </section>

            {/* 8. Run app */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="run-app">Run the app</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                Finish the file with <code>shinyApp(ui, server)</code>:
              </p>
              <GuideCodeBlock code={CODE_RUN} label="App entry point" />
              <p className="leading-relaxed text-muted-foreground">
                Run it from the app directory, or use your IDE&apos;s <strong>Run App</strong> action:
              </p>
              <GuideCodeBlock code={CODE_RUN_APP} label="Run command" />
              <p className="leading-relaxed text-muted-foreground">Verify the app behaves as documented:</p>
              <ol className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-decimal">
                <li>The page loads with a sidebar and header.</li>
                <li>Changing Region updates both cards and the plot.</li>
                <li>Reset filters returns the select to Americas.</li>
                <li>The theme control switches light/dark mode.</li>
              </ol>
            </section>

            {/* 9. Complete example */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="complete-example">Complete app.R</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                Here is the entire app in one copyable block. This is the canonical source
                — the snippets above are slices of it.
              </p>
              <GuideCodeBlock code={CODE_COMPLETE} label="Complete app.R" collapsible />
            </section>

            {/* 10. Composition model */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="composition-model">Understand composition</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">Three rules cover almost every shinyblocks app:</p>
              <ol className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-decimal">
                <li>Start with a page or host-app container.</li>
                <li>Compose blocks with ordinary Shiny and <code>htmltools</code> tags.</li>
                <li>Read inputs and render outputs through normal Shiny server code.</li>
              </ol>
              <GuideCodeBlock code={CODE_COMPOSITION_TREE} language="text" label="Composition diagram" />
              <p className="leading-relaxed text-muted-foreground">
                Standalone blocks can also be embedded in an existing Shiny UI.{" "}
                <code>block_page()</code> is the full-page entry point, not a requirement
                for every component.
              </p>
            </section>

            {/* 11. Themes and styles */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="themes-and-styles">Customize the look</SectionHeading>
              <p className="leading-relaxed text-muted-foreground">
                Swap two arguments on <code>block_page()</code> to restyle the whole app:
              </p>
              <GuideCodeBlock code={CODE_THEME_VARIANT} label="Theme and style variant" />
              <ul className="flex flex-col gap-1.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li>Themes change semantic colour tokens.</li>
                <li>Styles change geometry, spacing, surfaces, and motion.</li>
                <li><code>theme_mode = &quot;dark&quot;</code> sets a fixed initial mode.</li>
                <li><code>block_dark_mode_toggle()</code> lets users switch modes.</li>
              </ul>
              <p className="leading-relaxed text-muted-foreground">
                See the{" "}
                <Link href="/components/theme/" className="font-medium text-foreground underline underline-offset-4">Theme</Link>{" "}
                and{" "}
                <Link href="/components/style/" className="font-medium text-foreground underline underline-offset-4">Style</Link>{" "}
                component pages for the full reference.
              </p>
            </section>

            {/* 12. Next steps */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="next-steps">Next steps</SectionHeading>
              <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
                {nextSteps().map((step) => (
                  <Link
                    key={step.href}
                    href={step.href}
                    className="flex flex-col gap-1 rounded-lg border border-border bg-card p-4 transition-colors hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
                  >
                    <span className="font-semibold text-foreground">{step.label}</span>
                    <span className="text-sm text-muted-foreground">{step.desc}</span>
                  </Link>
                ))}
              </div>
              <p className="leading-relaxed text-muted-foreground">
                You can also explore every component interactively in the bundled showcase:
              </p>
              <GuideCodeBlock code={CODE_RUN_SHOWCASE} label="Run the showcase" />
            </section>

            {/* 13. Troubleshooting */}
            <section className="flex flex-col gap-4">
              <SectionHeading id="troubleshooting">Troubleshooting</SectionHeading>
              <ul className="flex flex-col gap-2.5 pl-5 leading-relaxed text-muted-foreground [&>li]:list-disc">
                <li><strong className="text-foreground">Installation fails:</strong> update <code>pak</code> and verify your GitHub access.</li>
                <li><strong className="text-foreground">Output stays blank:</strong> confirm the UI and server output ids match.</li>
                <li><strong className="text-foreground">A server update does nothing:</strong> pass the constructor&apos;s input id to the matching <code>update_block_*()</code> helper.</li>
                <li><strong className="text-foreground">Layout looks unstyled:</strong> confirm the UI element is returned/rendered rather than printed or converted to text.</li>
                <li>
                  <strong className="text-foreground">Shinylive:</strong> deploying to Shinylive needs the release filesystem assets and is an advanced deployment path. See the{" "}
                  <a
                    href={`${REPO}/blob/main/docs/troubleshooting.md`}
                    target="_blank"
                    rel="noreferrer"
                    className="inline-flex items-center gap-1 font-medium text-foreground underline underline-offset-4"
                  >
                    troubleshooting notes on GitHub
                    <ExternalLink className="h-3.5 w-3.5" />
                  </a>.
                </li>
              </ul>
            </section>
          </div>
        </main>

        {/* Desktop TOC (sticky) */}
        <aside className="hidden xl:block">
          <nav aria-label="On this page" className="sticky top-20 flex flex-col gap-3">
            <p className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              On this page
            </p>
            <GuideToc entries={GET_STARTED_TOC} variant="desktop" />
          </nav>
        </aside>
      </div>
    </div>
  );
}
