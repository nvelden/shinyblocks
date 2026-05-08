.PHONY: help setup watch-css build-css build-icons dev showcase \
	check-fast lint spell urls test docs check pkgdown budget \
	doc-links gate clean deploy-showcase

# Defaults you can override on the command line.
R          ?= env -u LC_ALL Rscript
NPX        ?= npx
TAILWIND   ?= $(NPX) @tailwindcss/cli
CSS_INPUT  := inst/www/src/shinyblocks.css
CSS_OUTPUT := inst/www/shinyblocks.css

help:
	@echo "shinyblocks make targets"
	@echo ""
	@echo "Inner loop (run constantly):"
	@echo "  setup           - install npm deps and R dev deps"
	@echo "  watch-css       - Tailwind v4 in --watch mode"
	@echo "  dev             - devtools::load_all() in an R session"
	@echo "  showcase        - load_all() and run inst/showcase"
	@echo "  check-fast      - lint + test + build-css (~20s)"
	@echo ""
	@echo "Phase exit:"
	@echo "  build-css       - compile inst/www/src -> inst/www"
	@echo "  build-icons     - regenerate the Lucide sprite"
	@echo "  lint            - lintr::lint_package()"
	@echo "  spell           - devtools::spell_check()"
	@echo "  urls            - urlchecker::url_check()"
	@echo "  test            - devtools::test()"
	@echo "  docs            - devtools::document()"
	@echo "  check           - R CMD check --as-cran"
	@echo "  pkgdown         - pkgdown::build_site()"
	@echo "  budget          - tools/budget.R (asset size report)"
	@echo "  doc-links       - tools/check-doc-links.R"
	@echo "  gate            - run the full Quality Gate"
	@echo ""
	@echo "Release-only:"
	@echo "  deploy-showcase - push showcase to its hosted deployment"
	@echo "  clean           - remove generated artifacts"

# ---------- Inner loop ----------

setup:
	$(NPX) --version >/dev/null
	npm ci || npm install
	$(R) -e 'install.packages(c("devtools", "lintr", "urlchecker", "pkgdown", "shinytest2", "withr", "spelling"), repos = "https://cloud.r-project.org")'
	$(R) -e 'devtools::install_dev_deps(".")'

watch-css:
	$(TAILWIND) --input $(CSS_INPUT) --output $(CSS_OUTPUT) --watch

dev:
	$(R) -e 'devtools::load_all(".")'

showcase:
	$(R) -e 'devtools::load_all("."); shiny::runApp("inst/showcase")'

check-fast: lint test build-css
	@echo "check-fast OK"

# ---------- Phase exit ----------

build-css:
	$(TAILWIND) --input $(CSS_INPUT) --output $(CSS_OUTPUT) --minify

build-icons:
	node tools/build-icons.mjs

lint:
	$(R) -e 'lintr::lint_package()'

spell:
	$(R) -e 'devtools::spell_check()'

urls:
	$(R) -e 'urlchecker::url_check()'

test:
	$(R) -e 'devtools::test()'

docs:
	$(R) -e 'devtools::document()'

check:
	$(R) -e 'devtools::check(remote = TRUE, manual = FALSE)'

pkgdown:
	$(R) -e 'pkgdown::build_site(preview = FALSE)'

budget:
	$(R) tools/budget.R

doc-links:
	$(R) tools/check-doc-links.R

# Quality Gate runs the same sequence as docs/ROADMAP.md. CI runs this.
# Order matters: cheap automated checks first, semi-automated next,
# review and document tracked manually. See docs/phase-exits/TEMPLATE.md.
gate: build-css lint spell urls test docs check pkgdown budget doc-links
	@echo ""
	@echo "Automated gate steps green."
	@echo "Remaining manual steps for phase exit:"
	@echo "  - shinytest2 showcase smoke + screenshots"
	@echo "  - manual a11y sweep on showcase"
	@echo "  - critical-code-reviewer on the diff"
	@echo "  - NEWS.md and DESCRIPTION version bump"
	@echo "  - phase-exit checklist file committed"
	@echo "  - git tag phase-N"

# ---------- Release-only ----------

deploy-showcase:
	$(R) -e 'rsconnect::deployApp("inst/showcase", appName = "shinyblocks-showcase")'

clean:
	rm -rf $(CSS_OUTPUT) docs/_pkgdown/ inst/doc/ man/*.Rd \
		*.Rcheck *.tar.gz node_modules
