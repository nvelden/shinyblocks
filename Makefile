.PHONY: help setup watch-css build-css build-runtime build-icons runtime-test dev showcase \
	check-fast lint spell urls test docs check pkgdown budget \
	doc-links parity-install parity-build-css parity-setup parity parity-stop \
	parity-ci gate clean deploy-showcase preview preview-pkgdown \
	preview-shinylive quarto-setup gallery skills-install

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
	@echo "  setup           - install npm deps, R dev deps, and agent skills"
	@echo "  skills-install  - mirror docs/skills/*.md into .claude/skills + .agents/skills"
	@echo "  watch-css       - Tailwind v4 in --watch mode"
	@echo "  dev             - devtools::load_all() in an R session"
	@echo "  showcase        - load_all() and run inst/showcase"
	@echo "  check-fast      - lint + test + build-css (~20s)"
	@echo ""
	@echo "Phase exit:"
	@echo "  build-css       - compile inst/www/src -> inst/www"
	@echo "  build-runtime   - compile frontend/src -> inst/www runtime assets"
	@echo "  runtime-test    - browser smoke test for runtime mount/update behavior"
	@echo "  build-icons     - regenerate the Lucide sprite"
	@echo "  lint            - lintr::lint_package()"
	@echo "  spell           - devtools::spell_check()"
	@echo "  urls            - urlchecker::url_check()"
	@echo "  test            - devtools::test()"
	@echo "  docs            - devtools::document()"
	@echo "  check           - R CMD check --as-cran"
	@echo "  pkgdown         - pkgdown::build_site()"
	@echo "  budget          - tools/budget.R (asset size report)"
	@echo "  parity-install  - install parity/ React app dependencies"
	@echo "  parity-build-css- compile parity reference CSS"
	@echo "  parity-setup    - launch the parity reference app on :5173"
	@echo "  parity          - run the visual parity diff for COMPONENT=<name>"
	@echo "  parity-stop     - stop the parity reference app"
	@echo "  parity-ci       - automated run across registered parity components"
	@echo "  doc-links       - tools/check-doc-links.R"
	@echo "  gate            - run the full Quality Gate"
	@echo ""
	@echo "Local preview (visual sanity check after a phase slice):"
	@echo "  preview            - showcase + pkgdown side by side"
	@echo "  preview-pkgdown    - build pkgdown site and serve site/pkgdown"
	@echo "  gallery            - render component gallery (.qmd) and serve"
	@echo "  preview-shinylive  - build Shinylive export and serve site/showcase"
	@echo ""
	@echo "Component gallery setup (run once per machine):"
	@echo "  quarto-setup       - install the quarto-ext/shinylive extension"
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
	@$(MAKE) skills-install

# Project-authored agent skills live under docs/skills/ (tracked).
# This target mirrors each one into the local .claude/skills/ and
# .agents/skills/ directories so Claude Code / Codex pick them up.
# Re-run after editing any file under docs/skills/.
skills-install:
	@for skill in docs/skills/*.md; do \
		name=$$(basename $$skill .md); \
		if [ "$$name" = "README" ]; then continue; fi; \
		echo "Installing skill: $$name"; \
		mkdir -p .claude/skills/$$name; \
		cp $$skill .claude/skills/$$name/SKILL.md; \
		if mkdir -p .agents/skills/$$name 2>/dev/null && \
			cp $$skill .agents/skills/$$name/SKILL.md 2>/dev/null; then \
			echo "  - mirrored to .agents/skills/$$name"; \
		else \
			echo "  - warning: could not mirror to .agents/skills/$$name"; \
		fi; \
	done
	@echo "Local skills installed under .claude/skills/."

watch-css:
	$(TAILWIND) --input $(CSS_INPUT) --output $(CSS_OUTPUT) --watch

dev:
	$(R) -e 'devtools::load_all(".")'

# `showcase` lives in the Local Preview section so it shares port
# defaults with the other preview targets.

check-fast: lint test build-css build-runtime
	@echo "check-fast OK"

# ---------- Phase exit ----------

build-css:
	$(TAILWIND) --input $(CSS_INPUT) --output $(CSS_OUTPUT) --minify

build-runtime:
	npm run build:runtime

build-icons:
	node tools/build-icons.mjs

runtime-test:
	npm run test:runtime

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
# Order matters: cheap automated checks first, review and parity last.
# See docs/phase-exits/TEMPLATE.md.
gate: build-css build-runtime runtime-test lint spell urls test docs check pkgdown budget doc-links parity-ci
	@echo ""
	@echo "Automated gate steps green! Parity tests passed."
	@echo "Remaining manual steps for phase exit:"
	@echo "  - shinytest2 showcase smoke (if applicable)"
	@echo "  - manual a11y sweep on showcase"
	@echo "  - critical-code-reviewer on the diff"
	@echo "  - NEWS.md and DESCRIPTION version bump"
	@echo "  - phase-exit checklist file committed"
	@echo "  - git tag phase-N"

# ---------- Local preview ----------
#
# Visual sanity check you can run after any slice. Each target uses a
# different port so two can run side by side without colliding:
#   showcase           -> http://127.0.0.1:4321
#   preview-pkgdown    -> http://127.0.0.1:4322
#   preview-shinylive  -> http://127.0.0.1:4323
#   gallery            -> http://127.0.0.1:4324

PORT_SHOWCASE   ?= 4321
PORT_PKGDOWN    ?= 4322
PORT_SHINYLIVE  ?= 4323
PORT_GALLERY    ?= 4324
PORT_PARITY     ?= 5173

# Re-bind showcase to a known port for the preview workflow.
showcase:
	$(R) -e 'devtools::load_all("."); shiny::runApp("inst/showcase", port = $(PORT_SHOWCASE), launch.browser = FALSE)'

parity-install:
	cd parity && npm ci

parity-build-css:
	$(TAILWIND) --input parity/src/tailwind.css --output parity/public/parity.css --minify

.parity-pids:
	@: # placeholder so the file is never an automatic prerequisite

parity-setup:
	@echo "Stopping any prior parity server..."
	@$(MAKE) parity-stop >/dev/null 2>&1 || true
	@echo "Building parity CSS..."
	@$(MAKE) parity-build-css >/dev/null
	@echo "Bundling parity app..."
	@cd parity && npm run build >/dev/null
	@echo "Starting parity app at http://127.0.0.1:$(PORT_PARITY)"
	@/bin/sh -c 'python3 -m http.server $(PORT_PARITY) --directory "$(CURDIR)/parity/dist" > "$(CURDIR)/.verify-parity.log" 2>&1 & echo $$! > "$(CURDIR)/.parity-pids"'
	@sleep 2
	@curl -sSI "http://127.0.0.1:$(PORT_PARITY)/?component=button&theme=light" >/dev/null || ( \
		echo "Parity app did not come up. See .verify-parity.log"; \
		exit 1 \
	)
	@echo "Parity app responding on :$(PORT_PARITY)"

COMPONENT ?= button

parity:
	node tools/parity/diff-styles.mjs --component $(COMPONENT)

parity-stop:
	@if [ -f .parity-pids ]; then \
		kill $$(cat .parity-pids) >/dev/null 2>&1 || true; \
		rm -f .parity-pids; \
	fi

.parity-ci-showcase-pid:
	@:

parity-ci:
	@echo "Running full automated visual parity suite..."
	@$(MAKE) parity-stop >/dev/null 2>&1 || true
	@$(MAKE) parity-setup
	@echo "Launching showcase app in background..."
	@$(R) -e 'devtools::load_all("."); shiny::runApp("inst/showcase", port = $(PORT_SHOWCASE), launch.browser = FALSE)' >/dev/null 2>&1 & echo $$! > .parity-ci-showcase-pid
	@echo "Waiting for showcase app to start..."
	@sleep 5
	@echo "Running parity tests across the shared registry..."
	@components=$$(node --input-type=module -e 'import { listComponentNames } from "./tools/parity/registry.mjs"; console.log(listComponentNames().join(" "))'); \
	status=0; \
	for component in $$components; do \
		echo ""; \
		echo "== parity :: $$component =="; \
		if ! $(MAKE) parity COMPONENT=$$component; then \
			status=1; \
			break; \
		fi; \
	done; \
	$(MAKE) parity-stop >/dev/null 2>&1 || true; \
	if [ -f .parity-ci-showcase-pid ]; then \
		kill $$(cat .parity-ci-showcase-pid) >/dev/null 2>&1 || true; \
		rm -f .parity-ci-showcase-pid; \
	fi; \
	if [ $$status -eq 0 ]; then \
		echo "Parity tests passed for all registered components."; \
	else \
		echo "Parity tests failed."; \
		exit 1; \
	fi

preview-pkgdown:
	$(R) -e 'pkgdown::build_site(preview = FALSE)'
	@echo ""
	@echo "Serving pkgdown site at http://127.0.0.1:$(PORT_PKGDOWN)"
	@echo "Press Ctrl+C to stop."
	python3 -m http.server $(PORT_PKGDOWN) --directory site/pkgdown

preview-shinylive:
	@if [ ! -f tools/export-shinylive.R ]; then \
		echo "tools/export-shinylive.R missing — Phase 1C punch-list item."; \
		echo "Once it lands, this target will run it and serve site/showcase."; \
		exit 1; \
	fi
	$(R) tools/export-shinylive.R
	@echo ""
	@echo "Serving Shinylive showcase at http://127.0.0.1:$(PORT_SHINYLIVE)"
	@echo "Press Ctrl+C to stop."
	python3 -m http.server $(PORT_SHINYLIVE) --directory site/showcase

# Run the showcase + pkgdown together. Useful before a phase exit so
# you can flip between the live components and their reference pages.
preview:
	@echo "Starting showcase at http://127.0.0.1:$(PORT_SHOWCASE)"
	@echo "Starting pkgdown  at http://127.0.0.1:$(PORT_PKGDOWN)"
	@echo "Press Ctrl+C to stop both."
	@$(MAKE) -j 2 showcase preview-pkgdown

# ---------- Component gallery (Quarto + shinylive, ADR 0013) ----------
#
# `quarto-setup` is a one-shot install. `gallery` renders the .qmd
# pages under vignettes/articles/components/ and serves them locally.

GALLERY_DIR := gallery
GALLERY_OUT := site/gallery

quarto-setup:
	@command -v quarto >/dev/null 2>&1 || { \
		echo "quarto CLI not found. Install from https://quarto.org/docs/get-started/"; \
		exit 1; \
	}
	@if [ -d $(GALLERY_DIR)/_extensions/quarto-ext/shinylive ]; then \
		echo "shinylive extension already installed under $(GALLERY_DIR)/_extensions/. Skipping."; \
	else \
		echo "Installing quarto-ext/shinylive into $(GALLERY_DIR)…"; \
		cd $(GALLERY_DIR) && quarto add quarto-ext/shinylive --no-prompt; \
	fi

gallery:
	@command -v quarto >/dev/null 2>&1 || { \
		echo "quarto CLI not found. Run 'make quarto-setup' first."; \
		exit 1; \
	}
	@if [ ! -d $(GALLERY_DIR)/_extensions/quarto-ext/shinylive ]; then \
		echo "shinylive extension missing. Run 'make quarto-setup' first."; \
		exit 1; \
	fi
	cd $(GALLERY_DIR) && quarto render
	@echo ""
	@echo "Serving component gallery at http://127.0.0.1:$(PORT_GALLERY)"
	@echo "Press Ctrl+C to stop."
	python3 -m http.server $(PORT_GALLERY) --directory $(GALLERY_OUT)

# ---------- Release-only ----------

deploy-showcase:
	$(R) -e 'rsconnect::deployApp("inst/showcase", appName = "shinyblocks-showcase")'

clean:
	rm -rf $(CSS_OUTPUT) docs/_pkgdown/ inst/doc/ man/*.Rd \
		*.Rcheck *.tar.gz node_modules
