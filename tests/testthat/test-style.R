test_that("block_style_profiles returns the supported profiles", {
  expect_identical(
    block_style_profiles(),
    c("default", "luma", "lyra", "maia", "mira", "nova", "rhea", "sera", "vega")
  )
  expect_identical(
    block_style_profiles(),
    shinyblocks:::style_profile_names()
  )
})

test_that("block_style validates the profile name", {
  expect_error(block_style("mono"), "Unknown style profile")
  expect_error(block_style("soft"), "Unknown style profile")
  expect_error(block_style("brutal"), "Unknown style profile")
  expect_error(block_style("glass"), "Unknown style profile")
  expect_error(
    block_style(c("default", "default")),
    "single supported style-profile"
  )
  expect_error(block_style(""), "single supported style-profile")
  expect_silent(block_style("default"))
  expect_silent(block_style("luma"))
  expect_silent(block_style("lyra"))
  expect_silent(block_style("maia"))
  expect_silent(block_style("mira"))
  expect_silent(block_style("nova"))
  expect_silent(block_style("rhea"))
  expect_silent(block_style("sera"))
  expect_silent(block_style("vega"))
})

test_that("block_style('luma') emits the luma profile tokens page-wide", {
  css <- as.character(block_style("luma")$style)

  expect_match(css, "sb-style-overrides", fixed = TRUE)
  expect_match(css, '.sb-app[data-sb-style="luma"]{', fixed = TRUE)
  # Shared tokens that differ from the default profile.
  expect_match(css, "--sb-control-padding-x: 0.75rem;", fixed = TRUE)
  expect_match(css, "--sb-control-gap: 0.375rem;", fixed = TRUE)
  expect_match(css, "--sb-control-shadow: none;", fixed = TRUE)
  expect_match(css, "--sb-overlay-gap: 1.5rem;", fixed = TRUE)
  expect_match(css, "--sb-focus-ring-opacity: 30%;", fixed = TRUE)
})

test_that("official shadcn style profiles emit representative tokens", {
  expectations <- list(
    lyra = c(
      "--sb-control-font-size: 0.75rem;",
      "--sb-focus-ring-width: 1px;",
      "--sb-card-radius: 0;"
    ),
    maia = c(
      "--sb-select-radius: 2rem;",
      "--sb-input-surface: color-mix(in oklch, var(--input) 50%, transparent);",
      "--sb-focus-ring-width: 3px;"
    ),
    mira = c(
      "--sb-control-height: 1.75rem;",
      "--sb-card-radius: 0.5rem;",
      "--sb-focus-ring-opacity: 30%;"
    ),
    nova = c(
      "--sb-control-height: 2rem;",
      "--sb-card-radius: 0.75rem;",
      "--sb-badge-radius: 2rem;"
    ),
    sera = c(
      "--sb-control-font-weight: 600;",
      "--sb-control-padding-x: 1.5rem;",
      "--sb-card-radius: 0;"
    ),
    vega = c(
      "--sb-control-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05);",
      "--sb-card-radius: 0.75rem;",
      "--sb-input-radius: 0.375rem;"
    )
  )

  for (profile in names(expectations)) {
    css <- as.character(block_style(profile)$style)
    expect_match(css, "sb-style-overrides", fixed = TRUE)
    expect_match(css, sprintf('.sb-app[data-sb-style="%s"]{', profile), fixed = TRUE)
    for (decl in expectations[[profile]]) {
      expect_match(css, decl, fixed = TRUE)
    }
  }
})

test_that("explicit overrides win over luma profile values", {
  css <- as.character(
    block_style(
      "luma",
      control_gap = "1rem",
      control_padding_x = "2rem"
    )$style
  )

  expect_match(css, "--sb-control-gap: 1rem;", fixed = TRUE)
  expect_match(css, "--sb-control-padding-x: 2rem;", fixed = TRUE)
  # Untouched luma tokens still emit their profile value.
  expect_match(css, "--sb-focus-ring-opacity: 30%;", fixed = TRUE)
})

test_that("block_style returns a shinyblocks_style object", {
  obj <- block_style("default", control_height = "2.5rem")
  expect_s3_class(obj, "shinyblocks_style")
  expect_identical(obj$profile, "default")
})

test_that("block_style with no overrides emits no style tag", {
  obj <- block_style("default")
  expect_null(obj$style)
})

test_that("block_style maps snake_case overrides to --sb-* properties", {
  css <- as.character(
    block_style(
      "default",
      control_height = "2.5rem",
      surface_gap = "2rem",
      focus_ring_width = "2px"
    )$style
  )

  expect_match(css, "sb-style-overrides", fixed = TRUE)
  expect_match(css, "--sb-control-height: 2.5rem;", fixed = TRUE)
  expect_match(css, "--sb-surface-gap: 2rem;", fixed = TRUE)
  expect_match(css, "--sb-focus-ring-width: 2px;", fixed = TRUE)
})

test_that("block_style rejects unknown and raw CSS-variable override names", {
  expect_error(
    block_style("default", not_a_token = "x"),
    "Unknown style override"
  )
  expect_error(
    block_style("default", `--sb-control-height` = "2.5rem"),
    "Unknown style override"
  )
  expect_error(block_style("default", "2.5rem"), "must be named")
})

test_that("block_style targets the profile selector and portal roots page-wide", {
  css <- as.character(block_style("default", control_height = "2.5rem")$style)

  expect_match(css, '.sb-app[data-sb-style="default"]{', fixed = TRUE)
  expect_match(
    css,
    '[data-shinyblocks-scope][data-sb-style="default"]{',
    fixed = TRUE
  )
  expect_match(css, "[data-shinyblocks-scope],", fixed = TRUE)
  expect_match(css, "[data-shinyblocks-root],", fixed = TRUE)
  expect_match(css, "[data-shinyblocks-portal-root]{", fixed = TRUE)
})

test_that("block_style confines overrides to scope when supplied", {
  css <- as.character(
    block_style("default", control_height = "2.5rem", scope = ".demo")$style
  )

  expect_match(css, ".demo{", fixed = TRUE)
  expect_match(css, ".demo [data-shinyblocks-scope],", fixed = TRUE)
  expect_match(css, ".demo [data-shinyblocks-root],", fixed = TRUE)
  expect_match(css, ".demo [data-shinyblocks-portal-root]{", fixed = TRUE)
  expect_no_match(css, "data-sb-style", fixed = TRUE)
})

test_that("block_style rejects an invalid scope", {
  expect_error(
    block_style("default", control_height = "2.5rem", scope = c(".a", ".b")),
    "single non-empty CSS selector"
  )
  expect_error(
    block_style("default", control_height = "2.5rem", scope = ""),
    "single non-empty CSS selector"
  )
})

test_that("style_token_map covers every public override name", {
  expect_setequal(
    shinyblocks:::style_override_names(),
    names(shinyblocks:::style_token_map())
  )
  expect_true(all(grepl("^sb-", shinyblocks:::style_token_map())))
})

test_that("internal tokens are emittable but not public overrides", {
  internal <- shinyblocks:::style_internal_token_map()
  expect_true(all(grepl("^sb-", internal)))
  # Internal geometry tokens are a separate tier: they are not accepted via `...`.
  expect_length(
    intersect(names(internal), shinyblocks:::style_override_names()),
    0
  )
  # block_style() emits both tiers; names must be unique across them.
  emit <- shinyblocks:::style_emit_token_map()
  expect_setequal(
    names(emit),
    c(names(shinyblocks:::style_token_map()), names(internal))
  )
  expect_false(any(duplicated(names(emit))))
})

test_that("block_style rejects internal geometry tokens passed via ...", {
  expect_error(
    block_style("default", card_radius = "1rem"),
    "Unknown style override"
  )
  expect_error(
    block_style("default", input_surface = "red"),
    "Unknown style override"
  )
})

test_that("built-in profiles only use emittable tokens", {
  # The style-profile parity harness (tools/theme/style-registry.mjs) parses the
  # luma list and maps each key through the public + internal token maps. Every
  # luma key must be an emittable token name with a non-empty value, or that
  # parse breaks.
  for (profile in setdiff(shinyblocks:::style_profile_names(), "default")) {
    values <- shinyblocks:::style_profiles[[profile]]
    expect_true(length(values) > 0)
    expect_true(all(
      names(values) %in% names(shinyblocks:::style_emit_token_map())
    ))
    expect_true(all(nzchar(unlist(values))))
  }
})

test_that("block_style('luma') emits internal radius and surface tokens", {
  css <- as.character(block_style("luma")$style)
  expect_match(css, "--sb-card-radius: 2rem;", fixed = TRUE)
  expect_match(
    css,
    "--sb-input-surface: color-mix(in oklch, var(--input) 50%, transparent);",
    fixed = TRUE
  )
  expect_match(css, "--sb-input-border: transparent;", fixed = TRUE)
})

test_that("block_style('rhea') emits compact profile tokens", {
  css <- as.character(block_style("rhea")$style)
  expect_match(css, "--sb-control-height: 2rem;", fixed = TRUE)
  expect_match(
    css,
    "--sb-card-radius: min(calc(var(--radius) * 2.6), 24px);",
    fixed = TRUE
  )
  expect_match(css, "--sb-input-radius: 1rem;", fixed = TRUE)
})
