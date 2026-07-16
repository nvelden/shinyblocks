test_that("block_theme validates named and known tokens", {
  expect_error(block_theme("bad"), "`block_theme\\(\\)` overrides must be named")

  expect_error(block_theme(not_a_token = "red"), "Unknown theme token")
})

test_that("block_theme emits every built-in semantic palette", {
  declarations <- function(values) {
    paste(sprintf("--%s: %s;", names(values), unlist(values)), collapse = "")
  }

  expect_identical(
    shinyblocks:::theme_preset_names(),
    c("neutral", "stone", "zinc", "mauve", "olive", "mist", "taupe")
  )

  for (preset in shinyblocks:::theme_preset_names()) {
    values <- shinyblocks:::theme_preset(preset)
    css <- as.character(block_theme(preset = preset))

    expect_match(
      css,
      paste0(".sb-app{", declarations(values$light), "}"),
      fixed = TRUE
    )
    expect_match(
      css,
      paste0(
        '[data-theme="dark"] .sb-app{',
        declarations(values$dark),
        "}"
      ),
      fixed = TRUE
    )
    expect_false("radius" %in% names(values$light))
    expect_false("radius" %in% names(values$dark))
  }
})

test_that("every palette exposes the same semantic token set in light and dark", {
  # Palette conformance matrix: no palette may silently drop a semantic token,
  # and every palette's light pack must match its dark pack name-for-name. This
  # keeps the palette sweep (tools/theme/check-theme-response.mjs) honest.
  reference <- names(shinyblocks:::theme_preset("neutral")$light)
  expect_true(length(reference) > 0)

  for (preset in shinyblocks:::theme_preset_names()) {
    values <- shinyblocks:::theme_preset(preset)
    expect_setequal(names(values$light), reference)
    expect_setequal(names(values$dark), reference)
  }
})

test_that("block_theme presets layer under explicit overrides", {
  css <- as.character(block_theme(
    preset = "olive",
    primary = "red",
    dark = list(primary = "blue"),
    scope = ".demo"
  ))

  expect_match(css, ".demo{--background: oklch(1 0 0);", fixed = TRUE)
  expect_match(css, "--primary: red;", fixed = TRUE)
  expect_match(
    css,
    '[data-theme="dark"] .demo{--background: oklch(0.153 0.006 107.1);',
    fixed = TRUE
  )
  expect_match(css, "--primary: blue;", fixed = TRUE)
  expect_false(grepl("--radius:", css, fixed = TRUE))
})

test_that("block_theme validates preset names", {
  expect_error(block_theme(), "requires a `preset`")
  expect_error(block_theme(preset = "unknown"), "Unknown theme preset")
  expect_error(block_theme(preset = c("olive", "taupe")), "one supported palette")
  expect_error(block_theme(preset = ""), "one supported palette")
})

test_that("block_theme defaults to page-wide selectors", {
  css <- as.character(block_theme(primary = "red"))
  expect_true(grepl(".sb-app{", css, fixed = TRUE))
  expect_true(grepl("[data-shinyblocks-scope]{", css, fixed = TRUE))
  expect_true(grepl(".sb-app [data-shinyblocks-scope]", css, fixed = TRUE))
  expect_true(grepl(".sb-app [data-shinyblocks-root]", css, fixed = TRUE))
  expect_true(grepl(
    ".sb-app [data-shinyblocks-portal-root]",
    css,
    fixed = TRUE
  ))
})

test_that("block_theme confines overrides to scope when supplied", {
  css <- as.character(block_theme(primary = "red", scope = ".demo"))
  expect_true(grepl(".demo{--primary: red;}", css, fixed = TRUE))
  expect_true(grepl(".demo [data-shinyblocks-root]", css, fixed = TRUE))
  expect_true(grepl(".demo [data-shinyblocks-scope]", css, fixed = TRUE))
  expect_true(grepl(".demo [data-shinyblocks-portal-root]", css, fixed = TRUE))
  # The page-wide selector must NOT appear when a scope is given.
  expect_false(grepl(".sb-app{", css, fixed = TRUE))
})

test_that("block_theme rejects an invalid scope", {
  expect_error(
    block_theme(primary = "red", scope = c(".a", ".b")),
    "single non-empty CSS selector"
  )
  expect_error(
    block_theme(primary = "red", scope = ""),
    "single non-empty CSS selector"
  )
})

test_that("block_theme dark overrides emit data-theme=dark rules", {
  css <- as.character(block_theme(
    primary = "red",
    dark = list(primary = "blue"),
    scope = ".demo"
  ))
  # Light/base value applies in both modes.
  expect_true(grepl(".demo{--primary: red;}", css, fixed = TRUE))
  # Dark value applies only under [data-theme="dark"].
  expect_true(grepl("[data-theme=\"dark\"] .demo{--primary: blue;}", css, fixed = TRUE))
  expect_true(grepl(
    "[data-theme=\"dark\"] .demo [data-shinyblocks-root]",
    css,
    fixed = TRUE
  ))
})

test_that("block_theme accepts dark-only overrides", {
  css <- as.character(block_theme(dark = list(primary = "blue")))
  # No light/base rule: style content begins straight with the dark selector.
  expect_true(grepl(">[data-theme", css, fixed = TRUE))
  expect_false(grepl(">.sb-app", css, fixed = TRUE))
  expect_true(grepl("[data-theme=\"dark\"] .sb-app{--primary: blue;}", css, fixed = TRUE))
})

test_that("block_theme validates dark token names and shape", {
  expect_error(block_theme(dark = list(not_a_token = "red")), "Unknown theme token")
  expect_error(block_theme(dark = list("red")), "non-empty named list")
  expect_error(block_theme(dark = list()), "non-empty named list")
})

test_that("block_theme_presets exposes the built-in palette names", {
  expect_identical(block_theme_presets(), shinyblocks:::theme_preset_names())
  expect_length(block_theme_presets(), 7L)
  expect_true(all(c("neutral", "olive", "taupe") %in% block_theme_presets()))
})

test_that("update_block_theme sends a custom message", {
  capture <- local_custom_message_session()

  expect_invisible(update_block_theme(capture$session, mode = "dark"))
  message <- capture$last_message()
  expect_identical(message$type, "sb:theme")
  expect_identical(message$payload$mode, "dark")
})

test_that("update_block_theme requires a session", {
  expect_error(update_block_theme(NULL), "`session` is required")
})
