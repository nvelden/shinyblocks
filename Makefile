.PHONY: help setup watch-css build-preflight build-css build-runtime build-icons runtime-test runtime-shiny-test showcase-test dev showcase showcase-health \
	check-fast check-slice lint spell urls test docs docs-verify check check-local pkgdown budget \
	doc-links legacy-audit layout-audit theme-static theme-test style-parity style-leanness style-ownership style-registry parity-install parity-build-css parity-setup parity parity-stop \
	parity-ci gate gate-release clean deploy-showcase preview preview-docs \
	preview-shinylive

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
	@echo "  showcase-health - verify the local showcase responds on its configured port"
	@echo "  check-fast      - focused R tests + cheap static audits (quick signal only;"
	@echo "                    does NOT run the full suite or R CMD check)"
	@echo "  check-slice     - full tests + builds/static audits for a vertical slice;"
	@echo "                    fails if built assets in inst/www are not committed"
	@echo ""
	@echo "Phase exit:"
	@echo "  build-css       - compile inst/www/src -> inst/www"
	@echo "  build-runtime   - compile frontend/src -> inst/www runtime assets"
	@echo "  runtime-test    - browser smoke test for runtime mount/update behavior"
	@echo "  runtime-shiny-test - Shiny-backed browser smoke for runtime bindings"
	@echo "  showcase-test   - Shiny showcase smoke for documented interactive controls"
	@echo "  build-icons     - regenerate the Lucide sprite"
	@echo "  lint            - lintr::lint_package()"
	@echo "  spell           - devtools::spell_check()"
	@echo "  urls            - urlchecker::url_check()"
	@echo "  test            - devtools::test()"
	@echo "  docs            - devtools::document()"
	@echo "  docs-verify     - document() then fail if man/ or NAMESPACE is uncommitted"
	@echo "  check-local     - R CMD check, offline (no remote/URL checks); in gate"
	@echo "  check           - R CMD check with remote checks (release-only)"
	@echo "  pkgdown         - deprecated; docs are built from docs-site/"
	@echo "  budget          - tools/budget.R (asset size report)"
	@echo "  legacy-audit    - fail on unclassified legacy wrapper/CSS/JS hits"
	@echo "  layout-audit    - fail on hand-authored generic flex/grid in examples"
	@echo "  parity-install  - install parity/ React app dependencies"
	@echo "  parity-build-css- compile parity reference CSS"
	@echo "  parity-setup    - launch the parity reference app on :5173"
	@echo "  parity          - run the visual parity diff for COMPONENT=<name>"
	@echo "  parity-stop     - stop the parity reference app"
	@echo "  parity-ci       - automated run across registered parity components"
	@echo "  doc-links       - tools/check-doc-links.R"
	@echo "  gate            - automated PR/phase-exit gate (this is what CI runs):"
	@echo "                    check-slice + runtime/showcase tests + lint + spell +"
	@echo "                    docs-verify + budget + parity + offline R CMD check"
	@echo ""
	@echo "Local preview (visual sanity check after a phase slice):"
	@echo "  preview            - showcase + docs site side by side"
	@echo "  preview-docs       - build and serve docs-site/"
	@echo "  preview-shinylive  - build Shinylive export and serve site/showcase"
	@echo ""
	@echo "Release-only:"
	@echo "  gate-release    - run gate plus network/release-only checks"
	@echo "  deploy-showcase - push showcase to its hosted deployment"
	@echo "  clean           - remove generated artifacts"

# ---------- Inner loop ----------

setup:
	$(NPX) --version >/dev/null
	npm ci || npm install
	$(R) -e 'install.packages(c("devtools", "lintr", "urlchecker", "pkgdown", "shinytest2", "withr", "spelling"), repos = "https://cloud.r-project.org")'
	$(R) -e 'devtools::install_dev_deps(".")'
	git config core.hooksPath tools/git-hooks

watch-css:
	$(TAILWIND) --input $(CSS_INPUT) --output $(CSS_OUTPUT) --watch

dev:
	$(R) -e 'devtools::load_all(".")'

# `showcase` lives in the Local Preview section so it shares port
# defaults with the other preview targets.

check-fast:
	$(R) -e 'devtools::test(filter = "style|utils")'
	$(MAKE) layout-audit
	npm run test:themes-static
	npm run test:themes-drift
	npm run test:style-leanness
	npm run test:style-ownership
	git diff --check
	@echo "check-fast OK"

# ---------- Slice boundary ----------

check-slice: build-css build-runtime test doc-links legacy-audit layout-audit theme-static style-leanness style-ownership style-registry
	@git diff --exit-code -- inst/www/shinyblocks.css inst/www/shinyblocks-runtime.js inst/www/shinyblocks-runtime.css \
		|| ( echo ""; echo "Built assets differ from what is committed. Rebuild (make build-css build-runtime) and commit the output."; exit 1 )
	git diff --check
	@echo "check-slice OK"

# ---------- PR / phase exit ----------

build-preflight:
	node tools/build-preflight.mjs

build-css: build-preflight
	$(TAILWIND) --input $(CSS_INPUT) --output $(CSS_OUTPUT) --minify

build-runtime:
	npm run build:runtime

build-icons:
	node tools/build-icons.mjs

runtime-test:
	npm run test:runtime

runtime-shiny-test:
	npm run test:runtime-shiny

showcase-test:
	npm run test:showcase

lint:
	$(R) -e 'lintr::lint_package()'

spell:
	$(R) -e 'devtools::spell_check()'

urls:
	$(R) -e 'urlchecker::url_check()'

test:
	$(R) -e 'devtools::test()'

docs:
	# Force a UTF-8 LC_CTYPE so roxygen writes non-ASCII defaults (e.g. the
	# date-range `separator` en-dash) as real characters instead of <U+NNNN>
	# escapes, which would otherwise trip R CMD check's codoc comparison.
	# C.UTF-8 is portable (always present); en_US.UTF-8 is the macOS fallback.
	LC_ALL=$${SB_DOCS_LOCALE:-$$(locale -a 2>/dev/null | grep -iE '^(C\.UTF-?8|en_US\.UTF-?8)$$' | head -n1)}; \
	LANG=$${LC_ALL:-C.UTF-8} LC_CTYPE=$${LC_ALL:-C.UTF-8} $(R) -e 'devtools::document()'

# Regenerate roxygen docs, then fail if the result differs from what is
# committed. `docs` alone mutates man/ + NAMESPACE silently, so a gate that
# runs it can go green while shipping stale generated docs. This makes
# staleness a hard error. Used by `gate` in place of `docs`.
docs-verify: docs
	@git diff --exit-code -- man NAMESPACE \
		|| ( echo ""; echo "man/ or NAMESPACE is out of date. Run 'make docs' and commit the result."; exit 1 )
	@echo "docs-verify OK"

# `document = FALSE`: do not let check re-run roxygen. devtools::check()
# documents by default, but this recipe runs under `env -u LC_ALL` (no UTF-8
# LC_CTYPE), so roxygen would rewrite non-ASCII defaults as <U+NNNN> escapes and
# corrupt man/. Documentation is owned by the `docs` / `docs-verify` targets,
# which set a UTF-8 locale; `gate` runs `docs-verify` before this.
check:
	$(R) -e 'devtools::check(remote = TRUE, manual = FALSE, document = FALSE)'

# R CMD check without the network-dependent remote checks (CRAN incoming
# feasibility, remote URL probes). This is the routine correctness gate and
# is safe to run in CI on every push/PR. The remote superset stays in
# `gate-release` via `urls` + `check`. See `check` re: `document = FALSE`.
check-local:
	$(R) -e 'devtools::check(remote = FALSE, manual = FALSE, document = FALSE)'

pkgdown:
	@echo "pkgdown has been decommissioned; build the custom docs site under docs-site/."

budget:
	$(R) tools/budget.R

doc-links:
	$(R) tools/check-doc-links.R

legacy-audit:
	$(R) tools/check-legacy-audit.R

# Fail when example/playground/preview code hand-authors generic flex/grid
# layout instead of using block_stack()/block_cluster()/block_grid(). Narrow
# fixed-geometry exceptions live in the script's allowlist.
layout-audit:
	$(R) tools/check-example-layout-primitives.R --strict

# Layer 1 of the theme-conformance framework: static, no browser. Fails when
# component CSS hardcodes a color instead of a theme token.
theme-static:
	npm run test:themes-static
	npm run test:themes-drift

# Layers 2 + 3: behavioural token-override check + completeness gate + palette
# sweep + style-profile parity. Requires the local showcase running
# (make showcase) on port 4321.
theme-test:
	npm run test:themes

# Style-profile parity only: proves every component responds to the active
# visual profile (default vs Luma) or declares why it does not. Kept separate
# from the colour-token checks so a failure names the right layer. Requires the
# local showcase running on port 4321.
style-parity:
	npm run test:style-parity

# Static leanness gate (no browser): fails when a [data-sb-style] profile rule
# hardcodes a recipe property (radius / translucent surface / foreground ring)
# that must instead be a profile token. Keeps profiles data, not CSS (issue #34).
style-leanness:
	npm run test:style-leanness

# Static ownership gate (no browser): fails when a runtime renderer spreads
# `payload.style` onto its own root, double-applying the user `style=` that the
# mount div already owns. Keeps style on exactly one DOM node (issue #50).
style-ownership:
	npm run test:style-ownership

# Browser-free unit tests for the style-registry R parser (resolves the profile
# recipe-helper splices). Runs in check-slice so a parser regression is caught
# without needing the showcase browser gate (style-parity).
style-registry:
	npm run test:style-registry

# Quality Gate runs automated PR/phase-exit checks. Network and release-only
# checks stay in gate-release so routine development does not pay for them.
gate: check-slice runtime-test runtime-shiny-test showcase-test lint spell docs-verify budget parity-ci check-local
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
#   preview-docs       -> http://127.0.0.1:4173/shinyblocks/
#   preview-shinylive  -> http://127.0.0.1:4323

PORT_SHOWCASE   ?= 4321
PORT_DOCS       ?= 4173
PORT_SHINYLIVE  ?= 4323
PORT_PARITY     ?= 5173

# Re-bind showcase to a known port for the preview workflow. In sandboxed
# agent sessions, run this target and showcase-health outside the sandbox:
# an isolated process may print "Listening" without being externally reachable.
showcase:
	$(R) -e 'devtools::load_all("."); shiny::runApp("inst/showcase", port = $(PORT_SHOWCASE), launch.browser = FALSE)'

showcase-health:
	curl -fsSI "http://127.0.0.1:$(PORT_SHOWCASE)/"

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
	@echo "Running parity tests across the shared registry in one browser..."
	@status=0; \
	node tools/parity/diff-styles.mjs --all || status=1; \
	if [ $$status -eq 0 ]; then \
		echo ""; \
		echo "== palette sweep + style-profile parity (themes-browser) =="; \
		npm run test:themes-browser || status=1; \
	fi; \
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

preview-docs:
	cd docs-site && PORT=$(PORT_DOCS) npm run preview

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

# Run the showcase + docs site together. Useful before a phase exit so
# you can flip between the live components and their reference pages.
preview:
	@echo "Starting showcase at http://127.0.0.1:$(PORT_SHOWCASE)"
	@echo "Starting docs site at http://127.0.0.1:$(PORT_DOCS)/shinyblocks/"
	@echo "Press Ctrl+C to stop both."
	@$(MAKE) -j 2 showcase preview-docs

# ---------- Release-only ----------

# `gate` runs the offline R CMD check (check-local); release additionally runs
# the network-enabled superset (`urls` + remote `check`). The local check is
# repeated here as part of `gate` — an accepted, infrequent cost so that one
# command fully clears a release.
gate-release: gate urls check
	@echo "gate-release OK"

deploy-showcase:
	$(R) -e 'rsconnect::deployApp("inst/showcase", appName = "shinyblocks-showcase")'

clean:
	rm -rf $(CSS_OUTPUT) docs/_pkgdown/ inst/doc/ man/*.Rd \
		*.Rcheck *.tar.gz node_modules
